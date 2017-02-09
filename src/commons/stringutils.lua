--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 11:11
    @Name:       stringutils.lua
    @Version:    1.0.0
    @TODO 
--]]



local json = require "cjson"


local _M = {}


--替换部分字符串
function _M.strReplace(s, pattern, replace)
    return string.gsub(s, pattern, replace)
end


--替换部分字符串
function _M.stringReplace(s, pattern, replace, times)


    local ret = nil
    while times >= 0 do
        times =  times - 1
        local s_start,s_stop = string.find(s, pattern , 1, true ) -- 1,true means plain searches from index 1
        if s_start ~= nil and s_stop ~= nil then
            s = string.sub( s, 1, s_start-1 ) .. replace .. string.sub( s, s_stop+1 )
        end
    end

    return s
end

--split函数实现
function _M.split(str, delimiter)
    if str == nil then
        return nil
    end

    if delimiter == nil then
        delimiter = "%s" --默认以空白字符切割
    end

    local res = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do -- 进行的是最短匹配，会匹配到 “空”开始到“delimiter”之前的部分
        table.insert(res, match)
    end
    return res
end

--***@desc get current millisecond value***--
function _M.getMsec(self)
    return string.sub(math.floor(ngx.now()*1000),11,14)
end

--"12" 这种类型 decode不会报错，但是对于我们的业务使用是一种异常，所以此处封装方法进行特殊处理
function _M.json_decode(str)
    local json_value = nil
    if "string" ~= type(str) then
        ngx.log(ngx.ERR,"json_decode arg:str need to be string")
        return json_value
    end
    local ok, err = pcall(function() json_value = json.decode(str) end)
    if not ok or ("table" ~= type(json_value)) then
        ngx.log(ngx.ERR,"fail to decode json string :".. tostring(str) .. ". errorMessage is :" .. tostring(err))
        return nil, tostring(err)
    else
        return json_value
    end
    --    return json.decode(str)
end

function _M.json_encode(jsonTable)
    return json.encode(jsonTable)
end

function _M.list_merge(dest, src)
    if dest ~= nil and ("table" == type(dest)) then
        if src ~= nil and ("table" == type(src)) then
            for i, item in ipairs(src) do
                table.insert(dest, item)
            end
        else
            ngx.log(ngx.ERR,"table_merge arg:src is nil or not a table type，src：".. tostring(src))
        end
    else
        ngx.log(ngx.ERR,"table_merge arg:dest is nil or not a table type，dest：".. tostring(dest))
    end

    return dest

end


function _M.table_merge(dest, src)
    if dest ~= nil and ("table" == type(dest)) then
        if src ~= nil and ("table" == type(src)) then
            for k, v in pairs(src) do
                dest[k] = v
            end
        else
            ngx.log(ngx.ERR,"table_merge arg:src is nil or not a table type，src：".. tostring(src))
        end
    else
        ngx.log(ngx.ERR,"table_merge arg:dest is nil or not a table type，dest：".. tostring(dest))
    end

    return dest
end
-- 获取当前天和当前小时
function _M.get_day_and_hour()
    --  2016-05-25 23:45:06
    local local_time = ngx.localtime()
    return string.sub(local_time,0,10), string.sub(local_time,12,13)
end
-- 获取客户端请求的真实uri
function _M.get_uri(uri)
    local start_index = string.find(uri,"?",1)
    if start_index then
        return string.sub(uri,0,(start_index-1))
    else
        return uri
    end
end
--  arg1/arg2 : ngx.time()类型的数据
function _M.compare_time_in_same_day(arg1, arg2)
    if (not arg1) or (not arg2) then
        return false
    end
    return (string.sub(ngx.http_time(arg1),6,-14) == string.sub(ngx.http_time(arg2),6,-14))
end

function _M.is_in_table(value, tbl)
    for k,v in ipairs(tbl) do
        if v == value then
            return true;
        end
    end
    return false;
end

--20160706
function _M.get_day_format()
    return os.date("%Y%m%d")
end
--20160706
function _M.get_time_format()
    return os.date("%Y%m%d%H")
end

--2016-07-07 14:29:58
function _M.getDate()
    return os.date("%Y-%m-%d %H:%M:%S")
end

--保留几位小数
function _M.get_precise_decimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end

    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

return _M