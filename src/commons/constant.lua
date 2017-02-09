--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 12:14
    @Name:       constant.lua
    @Version:    1.0.0
    @TODO 
--]]


local _M = {}

_M["postgresql"] = {
    ["default"] = {
        ["host"] = "127.0.0.1",
        ["port"] = 5432,
        ["database"] = "postgres",
        ["user"] = "postgres",
        ["password"] = "postgres",
    }
}



return _M