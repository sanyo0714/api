--[[
    @Author:     sanyo
    @Since Date: 2017/2/9
    @Since Time: 11:19
    @Name:       rewrite.lua
    @Version:    1.0.0
    @TODO 
--]]

ngx.exec("/api_internal",ngx.req.get_uri_args())