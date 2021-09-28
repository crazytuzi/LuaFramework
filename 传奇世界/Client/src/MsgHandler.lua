local MsgHandle = class("MsgHandle", function() return cc.Node:create() end)
MsgHandle.has_regist_tab = {}
function MsgHandle:ctor(handler_node,msgids,callbacks,noclean)
    self:init(handler_node,msgids,callbacks,noclean)
end
function MsgHandle:init(handler_node,msgids,callbacks,noclean)
    local func = function(buff,msgid,params)
        if callbacks then
            for k,v in pairs(msgids)do
                if v == msgid then 
                    callbacks[k](buff)
                end
            end
        elseif handler_node and handler_node.networkHander then
            handler_node:networkHander(buff,msgid,params)
        end
    end
    local msg_t = 0
    local function eventCallback(eventType)
        if eventType == "enter" then
            if not MsgHandle.has_regist_tab[msg_t] then
                for k,v in pairs(msgids)do 
                    g_msgHandlerInst:registerMsgHandler(v,func)
                end
            end
        elseif eventType == "exit" then
            self:unregistMsgHander(msgids)       
        end
    end
    for k,v in pairs(msgids)do 
        msg_t = msg_t + v
        g_msgHandlerInst:registerMsgHandler(v,func)
    end
    MsgHandle.has_regist_tab[msg_t] = true
    self:registerScriptHandler(eventCallback)
    if handler_node and (not noclean) then
        handler_node:addChild(self)
    end
end

function MsgHandle:unregistMsgHander(msgids)
    local msg_t = 0
    for k,v in pairs(msgids)do 
        msg_t = msg_t + v
        g_msgHandlerInst:registerMsgHandler(v,nil)
    end 
    MsgHandle.has_regist_tab[msg_t] = nil
    msgids = {}
end

return MsgHandle