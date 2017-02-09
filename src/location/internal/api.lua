--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 11:11
    @Name:       api.lua
    @Version:    1.0.0
    @TODO 
--]]

local cjson = require "cjson"
local base64 = require "libbase64"
local postgresutils = require "commons.postgresutils"



local function controller()
    local base64encode_sql = "c2VsZWN0ICogZnJvbSB0X3NlcnZpY2U7" --select * from t_service;
    local sql, in_len, out_len = base64.decode(base64encode_sql)
    local res = postgresutils.executeSql(sql, true)
    ngx.say(cjson.encode(res))
end

controller()