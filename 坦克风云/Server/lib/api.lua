--[[
    api
]]
local TankApi = {}
TankApi.validator = require "lib.validator"

local function getApi(cmdArray)
    return string.format("api.%s.%s", cmdArray[1], cmdArray[2])
end

local function regAfterFilter(self, filterName, filterFunc)
    if not self.afterFilters then
        self.afterFilters = {}
    end
    
    self.afterFilters[filterName] = filterFunc
end

local function initApi(api)
    api.regAfterFilter = regAfterFilter
end

-- 兼容新旧api写法
local function load(file)
    local api = require(file)
    if type(api) == 'function' then
        return api()
    end
    
    return api
end

local function getFunc(cmdArray)
    return string.format("api_%s_%s", cmdArray[1], cmdArray[2])
end

-- 获取执行的方法,默认执行index方法
local function getMethod(cmdArray)
    if #cmdArray == 3 then
        return string.format("action_%s", cmdArray[3])
    else
        return string.format("action_index")
    end
end

local function getFilters(request)
    local filters = {}
    
    local routeKeys = {}
    local cmdArray = string.split(request.cmd, "%.")
    for i = #cmdArray, 1, -1 do
        table.insert(routeKeys, table.concat(cmdArray, "_"))
        table.remove(cmdArray)
    end
    
    table.insert(routeKeys, "ALL")
    
    local routeCfg = getConfig("route")
    for _, v in pairs(routeKeys) do
        if routeCfg[v] then
            for event, eventFiters in pairs(routeCfg[v]) do
                if not filters[event] then filters[event] = {} end
                
                for _, filter in pairs(eventFiters) do
                    local filterName = filter
                    if type(filter) == "table" then
                        filterName = filter[1]
                        filter = copyTable(filter)
                        table.remove(filter, 1)
                    end
                    
                    if not filters[event][filterName] then
                        filters[event][filterName] = filter
                    end
                end
            end
        end
    end

    return filters
end

local function getRules(api,method)
	local rules
	if api.getRules then
		local apiRules = api.getRules()
		if apiRules["*"] then
			rules = copyTable(apiRules["*"])
		end

		if apiRules[method] then
			rules = table.merge(rules or {},apiRules[method])
		end

		apiRules = nil
	end

	return rules
end

local requestChildren = {["_uid"]="uid"}

local function parseRule(rule)
	if type(rule) == "table" then
		return table.remove(rule,1),rule
	end
	return rule
end

local function ruleCheck(request,rules)
	for k,v in pairs(rules) do
		local value = requestChildren[k] and request[requestChildren[k]] or request.params[k]

		if v[1] == "required" or value then
			for _,ruleInfo in pairs(v) do
				local rule,parameters = parseRule(ruleInfo)

				if not (TankApi.validator[rule]) then
					return {ret=-1,err=string.format("not %s validator",tostring(rule))}
				end
				 
				if not TankApi.validator[rule](value,parameters) then
					return {ret=-102,err = string.format("The %s must be a %s",tostring(k),tostring(rule))}
				end
			end
		end
	end
end

-- 要对API执行最后结果作处理可以在这里做
local function formatResult(result)
	if type(result) ~= "table" then
		result = {ret=-1,err="api not return",outres=result}
	end

    if result.response then
        result = result.response
    end
    
    return result
end

local function call(api, method, request)
    local response
    
    if not request._REQUESTCHECK and not sysDebug() then
        if request.secret and api._cronApi and (api._cronApi[method] or api._cronApi["*"]) then
            if request.secret ~= getConfig("base").SECRETKEY then
                return { ret = -124 }
            end
        else
            local ret,code = checkAccessToken(request.uid,request.logints,request.access_token)
            if not ret then
                return { ret = code }
            end
        end
    end

    request._REQUESTCHECK = nil

    local rules = getRules(api,method)
    if rules then
    	response = ruleCheck(request,rules)
    	if response then return response end
    end

    if type(api.before) == 'function' then
        response = api.before(request)
    end
    
    if not response then
        response = api[method](request)
    end
    
    if type(api.after) == 'function' then
        api.after(response)
    end
    
    if type(api.afterFilters) == "table" then
        -- Filter.runApiFilters(api.afterFilters,copyTable(response))
        Filter.runApiFilters(api.afterFilters, response)
        api.afterFilters = nil
    end
    
    return response
end

local function response(request)
    local result
    
    local cmdArray = string.split(request.cmd, "%.")
    if next(cmdArray) then
        local apiFile = getApi(cmdArray)
        local api = load(apiFile)
        
        if type(api) == "table" then
            initApi(api)
            local method = getMethod(cmdArray)
            if api[method] then
                api._method = method
                result = call(api, method, request)
            else
                result = { ret = -1, err = "request's api name is not existed" }
            end
            api,method= nil,nil
        else
            local func = getFunc(cmdArray)
            result = _ENV[func](request)
            func = nil
        end
    else
        result = { ret = -1, err = "request's cmd invalid" }
    end
    
    return result
end

function TankApi.run(request)
    local filters = getFilters(request)
    local result = Filter.run(filters.before, request)

    if not result or (result and result.ret == 0) then
        result = response(request)
    end
    
    Filter.run(filters.after, result)
    
    return formatResult(result)
end

return TankApi