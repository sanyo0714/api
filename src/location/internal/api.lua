--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 11:11
    @Name:       api.lua
    @Version:    1.0.0
    @TODO 
--]]

local ctr = require "commons.controller"
local cjson = require "cjson"

local function controller()
    local all_args = ngx.ctx.all_args
    ngx.log(ngx.ERR, cjson.encode(all_args))
    local request_body = all_args.request_body
    local method = all_args.method
    ngx.say(ctr.controller[method](request_body))
end

controller()