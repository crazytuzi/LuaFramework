--[[
    跨服活动
]]
local crossActivity = {}

local http = require("socket.http")
http.TIMEOUT= 3

local serverInfo = {
    "http://",
    getConfig("config.crossrank.httphost"),
    "/tank-server/public/index.php/crossActivity/ranking/",
}

local centerUrl = table.concat(serverInfo);

local function mkRequestUrl(...)
    return table.concat({centerUrl,...})
end

local function http_build_query(tb)
   local t = {}
   for k,v in pairs(tb) do
       table.insert(t,tostring(k) .. "=" .. tostring(v))
   end
   return table.concat(t,'&')
end

local function createSign(ts)
    local secret = "231e1f156e8e22fb8ef9b9d8817b1783"
    return require("lib.sha1")(secret .. "|" .. tostring(ts))
end

local function mkParams(data)
    for k,v in pairs(data) do
        if type(v) == 'table' then data[k] = json.encode(v) end
    end

    data.ts = os.time()
    data.sign = createSign(data.ts)
    return http_build_query(data)
end

local function log(logData)
    writeLog(logData,'crossActivity')
end

local function call(url,data)
    local respbody, code = http.request(url,data)

    if sysDebug() then
        ptb:p({tostring(url) .. '?' .. tostring(data),respbody,code})
    end

    if tonumber(code) == 200 then
        return respbody
    end

    -- faild log
    log({url=url,data=data,code=code,respbody=respbody})

    return false
end

-- 新增战报
-- param table data 战报数组 
function crossActivity.setRankingData(data)
    return call(mkRequestUrl("set"),mkParams(data))
end

-- 获取战报
function crossActivity.getRankingList(data,isAllItem)
    local result = call(mkRequestUrl("list"),mkParams(data))

    if result then
        result = json.decode(result)
    end

    if type(result) == 'table' and result.data and result.data.list then
        return result.data.list,result.data.other or {}
    end
end

-- 跨服通讯校验码
function crossActivity.kuafuSign(ts)
    return createSign(ts)
end

-- 获取攻击目标(番茄大作战)
function crossActivity.gettargets(data,isAllItem)
    local result = call(mkRequestUrl("targets"),mkParams(data))

    if result then
        result = json.decode(result)
    end

    if type(result) == 'table' and result.data and result.data.list then
        return result.data.list
    end
end

-- 扣除其他军团的积分（番茄大作战）
function crossActivity.subaPoint(senddata)
    local respbody = call(mkRequestUrl("subPoint"),mkParams(senddata))
    respbody = json.decode(respbody)
    if respbody.ret ~= 0 then
        writeLog(json.encode(senddata),'fqdzz_subaPoint')
        return false
    end
    return true
end

-- 幸运锦鲤
function crossActivity.upxyjl(senddata)
    local respbody = call(mkRequestUrl("upxyjl"),mkParams(senddata))
    respbody = json.decode(respbody)
    if respbody.ret ~= 0 then
        writeLog(json.encode(senddata),'xyjl')
        return false
    end
    return true
end

-- 查询上一轮锦鲤结果
function crossActivity.lastresult(senddata)
    local respbody = call(mkRequestUrl("getxyjl"),mkParams(senddata))
    respbody = json.decode(respbody)
    if type(respbody.data)~='table' then
        return {}
    end
    return respbody.data
end

-- 记录各服充值人数（充值团购）
function crossActivity.cztgNum(senddata)
    local respbody = call(mkRequestUrl("addNum"),mkParams(senddata))
    respbody = json.decode(respbody)
    if respbody.ret ~= 0 then
        writeLog(json.encode(senddata),'cztg_cztgNum')
        return false
    end
    return true
end

-- 统计各服人数（充值团购）
function crossActivity.cztgFind(senddata)
    local respbody = call(mkRequestUrl("findNum"),mkParams(senddata))
    respbody = json.decode(respbody)
    if respbody.ret ~= 0 then
        writeLog(json.encode(senddata),'cztg_cztgFind')
        return false
    end
    return respbody
end

return crossActivity
