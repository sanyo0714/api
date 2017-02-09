#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* lua wrapper gcc -shared -fPIC -o libbase64.so base64.c*/
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

const char base[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
/* BASE 64 encode table */
const char base64en[] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3',
	'4', '5', '6', '7', '8', '9', '+', '/',
};
#define BASE64_PAD	'='


#define BASE64DE_FIRST	'+'
#define BASE64DE_LAST	'z'
/* ASCII order for BASE 64 decode, -1 in unused character */
const signed char base64de[] = {
	/* '+', ',', '-', '.', '/', '0', '1', '2', */
	    62,  -1,  -1,  -1,  63,  52,  53,  54,

	/* '3', '4', '5', '6', '7', '8', '9', ':', */
	    55,  56,  57,  58,  59,  60,  61,  -1,

	/* ';', '<', '=', '>', '?', '@', 'A', 'B', */
	    -1,  -1,  -1,  -1,  -1,  -1,   0,   1,

	/* 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', */
	     2,   3,   4,   5,   6,   7,   8,   9,

	/* 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', */
	    10,  11,  12,  13,  14,  15,  16,  17,

	/* 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', */
	    18,  19,  20,  21,  22,  23,  24,  25,

	/* '[', '\', ']', '^', '_', '`', 'a', 'b', */
	    -1,  -1,  -1,  -1,  -1,  -1,  26,  27,

	/* 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', */
	    28,  29,  30,  31,  32,  33,  34,  35,

	/* 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', */
	    36,  37,  38,  39,  40,  41,  42,  43,

	/* 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', */
	    44,  45,  46,  47,  48,  49,  50,  51,
};
static char find_pos(char ch);
/* */
static int base64_encode(lua_State *L)
{
    const char *data = luaL_checkstring(L, 1);
    int data_len = strlen(data);
    //int data_len = strlen(data);
    int prepare = 0;
    int ret_len;
    int temp = 0;
    char *ret = NULL;
    char *f = NULL;
    int tmp = 0;
    char changed[4];
    int i = 0;
    ret_len = data_len / 3;
    temp = data_len % 3;
    if (temp > 0)
    {
        ret_len += 1;
    }
    ret_len = ret_len*4 + 1;
    ret = (char *)malloc(ret_len);

    if ( ret == NULL)
    {
        printf("No enough memory.\n");
        exit(0);
    }
    memset(ret, 0, ret_len);
    f = ret;
    while (tmp < data_len)
    {
        temp = 0;
        prepare = 0;
        memset(changed, '\0', 4);
        while (temp < 3)
        {
            //printf("tmp = %d\n", tmp);
            if (tmp >= data_len)
            {
                break;
            }
            prepare = ((prepare << 8) | (data[tmp] & 0xFF));
            tmp++;
            temp++;
        }
        prepare = (prepare<<((3-temp)*8));
        //printf("before for : temp = %d, prepare = %d\n", temp, prepare);
        for (i = 0; i < 4 ;i++ )
        {
            if (temp < i)
            {
                changed[i] = 0x40;
            }
            else
            {
                changed[i] = (prepare>>((3-i)*6)) & 0x3F;
            }
            *f = base[changed[i]];
            //printf("%.2X", changed[i]);
            f++;
        }
    }

    *f = '\0';
    lua_pushlstring(L, (char *) data, strlen(data));
    return 1;
}
/* */
static char find_pos(char ch)
{
    char *ptr = (char*)strrchr(base, ch);//the last position (the only) in base[]
    return (ptr - base);
}
/* */
static int base64_decode(lua_State *L)
{
    const char *data = luaL_checkstring(L, 1);
    int data_len = strlen(data);
    int ret_len = (data_len / 4) * 3;
    int equal_count = 0;
    char *ret = NULL;
    char *f = NULL;
    int tmp = 0;
    int temp = 0;
    int prepare = 0;
    int i = 0;
    if (*(data + data_len - 1) == '=')
    {
        equal_count += 1;
    }
    if (*(data + data_len - 2) == '=')
    {
        equal_count += 1;
    }
    switch (equal_count)
    {
        case 1:
            ret_len -= 1;//Ceil((6*3)/8)+1
            break;
        case 2:
            ret_len -= 2;//Ceil((6*2)/8)+1
            break;
    }
    ret = (char *)malloc(ret_len);
    if (ret == NULL)
    {
        printf("No enough memory.\n");
        exit(0);
    }
    memset(ret, 0, ret_len);
    f = ret;
    while (tmp < (data_len - equal_count))
    {
        temp = 0;
        prepare = 0;
        //memset(need, 0, 4);
        while (temp < 4)
        {
            if (tmp >= (data_len - equal_count))
            {
                break;
            }
            prepare = (prepare << 6) | (find_pos(data[tmp]));
            temp++;
            tmp++;
        }
        prepare = prepare << ((4-temp) * 6);
        for (i=0; i<3 ;i++ )
        {
            if (i == temp)
            {
                break;
            }
            *f = (char)((prepare>>((2-i)*8)) & 0xFF);
            f++;
        }
    }
    //*f = '\0';

    lua_pushlstring(L, (char *) ret, ret_len);
    lua_pushinteger(L, data_len);
    lua_pushinteger(L, ret_len);
    //if (ret != NULL) free(ret);

    return 3;
}


static const struct luaL_Reg util[] = {
    {"decode",          base64_decode},
    {"encode",          base64_encode},
    {NULL, NULL} /* 必须以NULL结尾 */
};

//http://stackoverflow.com/questions/19041215/lual-openlib-replacement-for-lua-5-2
int luaopen_libbase64(lua_State *L)
{
    luaL_openlib(L, "libbase64", util, 0);
    return 1;
}
