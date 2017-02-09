--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 11:15
    @Name:       rewrite.lua
    @Version:    1.0.0
    @TODO 
--]]


local util = require "commons.stringutils"
local sub     = string.sub
local req     = ngx.req
local var     = ngx.var
local read_body = req.read_body
local get_body_data = req.get_body_data
local get_body_file = req.get_body_file
local get_header  = req.get_headers

local _M = {}


--检查post body是否接收完成，如果有tmp文件的情况就得去读取文件
function _M.check_post_body(post_body)
    if nil == post_body then
        local file_name = get_body_file()
        if file_name then
            local f = assert(io.open(file_name, 'r'))
            post_body = f:read("*all")
            f:close()
        end
    end
    return post_body
end

--  初始化基于request的全局变量all_args
function _M.init_all_args()
    local all_args = {}
    all_args["uri"] = util.get_uri(var.request_uri)
    --初始化header信息
    all_args = util.table_merge(all_args, get_header())

    read_body()
    --根据content_type初始化postbody信息
    local ct = var.content_type
    if ct ~= nil and (sub(ct, 1, 16) == "application/json") then
        local post_body = get_body_data()
        all_args["request_body"] = _M.check_post_body(post_body)
    else
        local post_body = get_body_data()
        all_args["request_body"] = _M.check_post_body(post_body)
    end

    --设置错误码 初始值
    all_args["err"] = {}
    --  设置到context中，供其他阶段使用
    ngx.ctx.all_args = all_args
end

_M.init_all_args()