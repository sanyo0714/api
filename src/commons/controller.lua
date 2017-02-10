--[[
    @Author:     sanyo
    @Since Date: 2017/2/10
    @Since Time: 16:47
    @Name:       controller.lua
    @Version:    1.0.0
    @TODO 
--]]

local cjson = require "cjson"
local base64 = require "libbase64"
local postgresutils = require "commons.postgresutils"

local _M = {}

--通用方法可以执行各种语句
--test curl "http://192.168.200.100/api.html?method=common" --data "c2VsZWN0ICogZnJvbSB0X3NlcnZpY2Ugd2hlcmUgaWQgPSAy"
local function common(all_args)
    --request_body "c2VsZWN0ICogZnJvbSB0X3NlcnZpY2U7"  select * from t_service;
    local sql, in_len, out_len = base64.decode(all_args.request_body)
    local res = postgresutils.executeSql(sql, true)
    return cjson.encode(res)
end


--获取传进来POLYGON的面积
--test curl "http://192.168.200.100/api.html?method=getarea" --data "LTgwLjUgNDIuMyAsLTc0LjcgNDIuMyAsLTc0LjcgMzkuNyAsLTgwLjUgMzkuNyAsLTgwLjUgNDIuMw=="
local function get_area(all_args)
    --request_body "LTgwLjUgNDIuMyAsLTc0LjcgNDIuMyAsLTc0LjcgMzkuNyAsLTgwLjUgMzkuNyAsLTgwLjUgNDIuMw=="  -80.5 42.3 ,-74.7 42.3 ,-74.7 39.7 ,-80.5 39.7 ,-80.5 42.3
    local data, in_len, out_len = base64.decode(all_args.request_body)
    local sql = string.format("SELECT round(CAST (ST_Area (Geography (ST_GeomFromText ('POLYGON ((%s))'))) AS NUMERIC) / 10000,2) AS area;", data)
    local res = postgresutils.executeSql(sql, true)
    return cjson.encode(res)
end

--获取传进来POLYGON，来匹配区域
--test curl "http://192.168.200.100/api.html?method=intersects&tablename=geom_test" --data "LTgwLjUgNDIuMyAsLTc0LjcgNDIuMyAsLTc0LjcgMzkuNyAsLTgwLjUgMzkuNyAsLTgwLjUgNDIuMw=="
local function intersects(all_args)
    --request_body "LTgwLjUgNDIuMyAsLTc0LjcgNDIuMyAsLTc0LjcgMzkuNyAsLTgwLjUgMzkuNyAsLTgwLjUgNDIuMw=="  -80.5 42.3 ,-74.7 42.3 ,-74.7 39.7 ,-80.5 39.7 ,-80.5 42.3
    local data, in_len, out_len = base64.decode(all_args.request_body)
    local sql = string.format("SELECT * FROM %s WHERE ST_Intersects ( geom, 'POLYGON((%s))');", all_args.tablename, data)
    local res = postgresutils.executeSql(sql, true)
    return cjson.encode(res)
end

_M.controller = {
    ["common"] = common,
    ["getarea"] = get_area,
    ["intersects"] = intersects,
}


return _M
