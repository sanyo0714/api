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

--省市县查询
--test curl "http://192.168.200.100/api.html?method=intersects_district&tablename=geom_data&district=town&pagesize=3&page=3" --data "MzM3"
local function intersects_district(all_args)
    --request_body "MzM3"  337
    local back_result = {}
    local data, in_len, out_len = base64.decode(all_args.request_body)
    local sql = string.format("SELECT g.*, st_astext (g.geom) FROM %s g, %s t WHERE ST_Intersects (g.geom, t.geom) AND t.gid = %s  limit %s OFFSET %s;",
                all_args.tablename, all_args.district, data, all_args.pagesize, all_args.pagesize * (all_args.page - 1))
    local list_res = postgresutils.executeSql(sql, true)

    sql = string.format("SELECT st_astext (t.geom) FROM %s t WHERE t.gid = %s;", all_args.district, data)
    local district_res = postgresutils.executeSql(sql, true)

    sql = string.format("SELECT g.*, st_astext (g.geom) FROM %s g, %s t WHERE ST_Intersects (g.geom, t.geom) AND t.gid = %s;",
        all_args.tablename, all_args.district, data)
    local count_res = postgresutils.executeSql(sql, true)

    back_result = {
        ["list_res"] = list_res,
        ["district_res"] = district_res,
        ["count_res"] = count_res,
    }
    return cjson.encode(back_result)
end

_M.controller = {
    ["common"] = common,
    ["getarea"] = get_area,
    ["intersects"] = intersects,
    ["intersects_district"] = intersects_district,
}


return _M
