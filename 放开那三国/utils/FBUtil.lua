-- Filename：	FBUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-5-17
-- Purpose：		副本的一些解析方法

-- 参数说明str csv 格式字符串，seq 分隔符 如果不传则默认是 逗号
-- added by huxiaozhou. 2013-06-05

function convertCSVStrToTable( str ,seq)
    require "scipt/utils/LuaUtil"
    local count = 0
    seq = seq or ","
    local res = {}
    local temp = string.split(str,"\n")
    local t = {}
    for i=1,#temp do
        local sub_res = {}
        if i == 1 then
            t = string.split(temp[i],seq)
        else
            local tt = string.split(temp[i],seq)
            for k,v in pairs(t) do
                sub_res[v] = tt[k]
            end
            res["id_" .. tt[1]] = sub_res
        end        
    end
    return res
end
--转换 CSV 格式字符串成table 格式如下
--[[
res = {
    id_10001 = { copy_id = 10001, name = "huxiaozhou"}
    id_10002 = { copy_id = 10002, name = "chengliang"}
    id_10003 = { copy_id = 10002, name = "chengliang"}
}
--]]







