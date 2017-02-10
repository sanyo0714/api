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
    local method = all_args.method
    local func = ctr.controller[method]
    if func then
        ngx.say(func(all_args))
    else
        ngx.say("no controller for method.")
    end
end

controller()