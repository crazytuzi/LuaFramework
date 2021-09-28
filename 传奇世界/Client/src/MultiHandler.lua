MONEY_GOLD_UPDATE = 1
local isRunning = false

function registMultiHandler(key,func, call) 
    if not isRunning then
        g_multi_handler[key] =  g_multi_handler[key] or {}
        table.insert(g_multi_handler[key],func)
    else
        g_multi_handler_ex[key] =  g_multi_handler_ex[key] or {}
        table.insert(g_multi_handler_ex[key],func)
    end
	
	if call then func() end
end

function unRegistMultiHandler(key,func)
    if g_multi_handler[key] then
        for k,v in pairs(g_multi_handler[key])do
            if v==func then
                table.remove(g_multi_handler[key],k)
            end
        end
    end
end

function handlerMultiFunc(key,param)
    if g_multi_handler[key] then
        isRunning = true
        for k,v in ipairs(g_multi_handler[key])do
            v(param)
        end
        isRunning = false
    end
    
    if g_multi_handler_ex[key] then
        for k,v in pairs(g_multi_handler_ex[key])do
            v(param)
        end
    end
end