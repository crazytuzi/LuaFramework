function xzy() end; function cgq() end; function lhp() end
function lfl() end; function wcy() end; function zwx() end
function wyy() end; function mjb() end; function fei() end

function mjb(...) debug_Print("mjb",...) end
function gjj(...) debug_Print("gjj",...) end
function fei(...) debug_Print("fei",...) end

function childNum()
    local child_num
    local num_sum = 0
    child_num = function(parent)
        local all_child = parent:getChildren()
        if all_child and #all_child > 0 then 
            num_sum = num_sum + #all_child
            for _, v in pairs(all_child) do 
                v.is_add = true
                child_num(v)
            end
        elseif parent.is_add == nil then
            num_sum = num_sum + 1
        end
        if #all_child > 100 then
            -- parent:removeAllChildren()
            print("all_child", #all_child, getCCName(parent), tolua.isnull(parent), parent.getString and parent:getString())
        end
    end
    local view = ViewManager:getInstance()
    local layer = {}
    layer[1] = {"scene_layer ", view.scene_layer}
    layer[2] = {"effect_layer", view.effect_layer}
    layer[3] = {"ui_layer    ", view.ui_layer}
    layer[4] = {"top_layer   ", view.top_layer}
    layer[5] = {"buttom_layer", view.buttom_layer}
    layer[6] = {"msg_layer   ", view.msg_layer}
    layer[7] = {"gm_layer    ", view.gm_layer}
    for i, v2 in pairs(layer) do 
        num_sum = 0
        child_num(v2[2])
        print(v2[1].."層孩子數:"..num_sum)
    end
end

-- 顯示所有
function showAll()
    local num_sum = 0
    local show_fun
    show_fun = function(parent)
        local all_child = parent:getChildren()
        if all_child and #all_child > 0 then 
            num_sum = num_sum + #all_child
            for _, v in pairs(all_child) do 
                v.is_add = true
                show_fun(v)
            end
        else
            parent:setVisible(true)
            if parent.is_add == nil then
                num_sum = num_sum + 1
            end
            if parent.setBackGroundColorOpacity then
                showLayoutRect(parent)
            end
        end
    end
    local view = ViewManager:getInstance()
    local layer = {}
    layer[1] = {"scene_layer ", view.scene_layer}
    layer[2] = {"effect_layer", view.effect_layer}
    layer[3] = {"ui_layer    ", view.ui_layer}
    layer[4] = {"top_layer   ", view.top_layer}
    layer[5] = {"buttom_layer", view.buttom_layer}
    layer[6] = {"msg_layer   ", view.msg_layer}
    layer[7] = {"gm_layer    ", view.gm_layer}
    for i, v2 in pairs(layer) do 
        num_sum = 0
        show_fun(v2[2])
        print(v2[1].."層孩子數:"..num_sum)
    end
end

function debug_Print(name, ... )
    printParent(4)
    print("↓--------"..name.."----print--------↓")
    for _, v in pairs({...}) do 
        if type(v) == "table" then
            printLuaTable(v)
        else
            print(v)
        end
    end 
    print("↑--------"..name.."----print--------↑")
end

-------------------------------------用於打印錯誤輸出的方法

print_log = function(...)
    local str = string.format(...)
    print(str)
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" or PLATFORM_NAME == "release2" then         -- 只有测试服提示出来
        ErrorMessage.show(str)
    end
end

local error_raw = error
error = function(...)
     print_log(string.format(...))
     error_raw(string.format(...))
end

-- 简化栈堆为文件名和行
function simpleTrace(str)
    local a, b = string.find(str, '[_a-z]+.luac?"]:?%d*')
    if a and b then
        local s = string.sub(str, a, b)
        return string.format("|%s,%s%s", string.sub(s, string.find(s, '[_a-z]+')),
                            string.sub(s, string.find(s, '%d+')),
                            simpleTrace(string.gsub(str, s, ""))
                )
    else 
        return ""
    end
end

-- 简单的错误日志
function simleLogErrorMsg(error_msg, trace)
    local a, b = string.find(error_msg, '[_a-z]+.lua')
    error_msg = string.sub(error_msg, a)            -- 去掉之前没用的部分
    error_msg = string.gsub(error_msg, '"]', "")
    return error_msg .. simpleTrace(trace)
end

__error_log = {}
function writeErrorLog(error_msg, trace)
    if debugger or __error_log[error_msg] then return end       -- 已经记录过了
    __error_log[error_msg] = true
    if buglyReportLuaException then 
        buglyReportLuaException(error_msg, trace)
    elseif ProtocalRulesMgr then
        local msg = simleLogErrorMsg(error_msg, trace)
        Send(10999, {msg = msg}) -- 上报服务端
    else
        print(msg)
    end
    return true
end

function sendErrorToSrv(error_msg)
    if not GameNet:getInstance():IsServerConnect() or __error_log[error_msg] then return end       -- 已经记录过了
    __error_log[error_msg] = true
     local trace = debug.traceback()
     local msg = ""
     msg = msg .. "-------------------------------------------------\n"
     msg = msg .. "now_ver: " .. now_ver() .. "\n"
     msg = msg .. "LUA ERROR: " .. error_msg .. "\n"
     msg = msg .. "-------------------------------------------------\n"
     msg = msg .. trace .. "\n"
     msg = msg .. "-------------------------------------------------\n"
     Send(10999, {msg = msg}) -- 上报服务端
end

--for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
     local error_msg = msg
     local trace = debug.traceback()
     local msg = ""
     msg = msg .. "-------------------------------------------------\n"
     msg = msg .. "LUA ERROR: " .. error_msg .. "\n"
     msg = msg .. "-------------------------------------------------\n"
     msg = msg .. trace .. "\n"
     msg = msg .. "-------------------------------------------------\n"
     sdkSendErrorToBugly(msg)
     if writeErrorLog(error_msg, trace) then
         print_log(msg)
     elseif debugger then
        print_log(msg)
     end
     if SHOW_ERROR then
         error(msg)
     end
end

