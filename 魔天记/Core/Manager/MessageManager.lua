-- 与EventManager相同功能，但MessageManager仅用于Lua内部通讯，且不延迟调用
MessageManager = { };
local _messages = { };

-- 例子：
--    MessageManager.AddListener(PlayerManager,"test",MyRolePanel.Test,self)
--    MessageManager.Dispatch(PlayerManager,"test","11")
--    MessageManager.RemoveListener(PlayerManager,"test",MyRolePanel.Test)
-- manager监视对象(一般为Manager), --messageType监视消息标识  --handler处理函数 --监听事件的对象
-- 模块内的更新通过SendNotifition去通知
function MessageManager.AddListener(manager, messageType, handler, owner)
    local mList = _messages[manager]
    if not mList then
        mList = {}
        _messages[manager] = mList;
    end
    local handlerMap = mList[messageType]
    if not handlerMap then
        handlerMap = {}
        mList[messageType] = handlerMap;
    end
    local ownerList = handlerMap[handler]
    if not ownerList then
        ownerList = {}
        handlerMap[handler] = ownerList
    end
    owner = owner or 1
    if ownerList[owner] then
        -- Error("已经有监听了啊！！想重复监听？？"..debug.traceback())
    end
    ownerList[owner] = true
end

function MessageManager.RemoveListener(manager, messageType, handler, owner)
    local mList = _messages[manager]
    if not mList then
        return;
    end
    local handlerMap = mList[messageType]
    if not handlerMap then
        return;
    end
    local ownerList = handlerMap[handler]
    if not ownerList then
        return;
    end
    if not owner then
        handlerMap[handler] = nil
    else
        ownerList[owner] = nil
        if not next(ownerList) then
            handlerMap[handler] = nil
        end
    end
    
    if not next(handlerMap) then
        mList[messageType] = nil
        if not next(mList) then
            _messages[manager] = nil
        end
    end
end

function MessageManager.Dispatch(manager, messageType, ...)
    local mList = _messages[manager]
    if not mList then
        return;
    end
    local handlerMap = mList[messageType]
    if not handlerMap then
        return;
    end 

    for handler, ownerList in pairs(handlerMap) do 
        for owner, _ in pairs(ownerList) do
            if owner ~= 1 then 
                handler(owner, ...);
            else
                handler(...);
            end
        end
    end
end


