--[[
    战报存储中心
]]
local reportcenter = {}

local http = require("socket.http")
http.TIMEOUT= 3

local serverInfo = {
    "http://",
    getConfig("config.reportCenter.host"),
    "/",
}

local module2type = {
    ["across"] = 1, -- 跨服军团战
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

local function mkParams(datas)
    for k,v in pairs(datas) do
        if type(v) == 'table' then datas[k] = json.encode(v) end
    end

    return http_build_query(datas)
end

local function log(logData)
    writeLog(logData,'reportcenter')
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
-- param table datas 战报数组 
function reportcenter.set(datas)
    return call(mkRequestUrl("addReport"),mkParams(datas))
end

-- 获取战报
function reportcenter.get(datas,isAllItem)
    local url = isAllItem and mkRequestUrl("selectReportAllItem") or mkRequestUrl("selectReportPartItem")
    local result = call(url,mkParams(datas))

    if result then
        result = json.decode(result)
    end

    if type(result) == 'table' then
        for k,v in pairs(result) do
            if type(v) == 'table' then
                for m,n in pairs(v) do
                    local ndata = json.decode(n.data)
                    if type(ndata) == 'table' then
                        n.data = ndata
                    end
                end
            end
        end
    end

    return result
end

-- 删除战报
function reportcenter.delete()

end

-- 每个功能模块战报的type类型
-- 只要是存到战报中心的战报类型必需从这里获取
function reportcenter.getModuleType(moduleName)
    return module2type[moduleName]
end

return reportcenter