--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 12:42
    @Name:       postgresutils.lua
    @Version:    1.0.0
    @TODO 
--]]

local constant = require "commons.constant"
local pgmoon = require "pgmoon"

local _M = {}

--执行数据库操作
function _M.executeSql(sql_statement, is_openresty_environ)
    ngx.log(ngx.DEBUG, "Execute sql: " .. sql_statement)
    local db_config = constant.postgresql.default
    local pg = pgmoon.new(db_config)
    assert(pg:connect())
    local res = assert(pg:query(sql_statement))
    if is_openresty_environ then
        pg:keepalive()
    else
        pg:disconnect()
    end
    return res
end

return _M