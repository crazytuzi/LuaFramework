-- 模块管理器基类
BaseManager = BaseManager or BaseClass()

function BaseManager:__init()
end

function BaseManager:__delete()
end

function BaseManager:AddNetHandler(cmd, handler)
    if handler == nil then return end
    local tmp = function(dat)
        handler(self, dat)
    end
    Connection.Instance:add_handler(cmd, tmp)
    return tostring(tmp)
end

function BaseManager:Send(cmd, data)
    data = data or { }
    Connection.Instance:send(cmd, data)
end

function BaseManager:RemoveNetHandler(cmd,tmp)
    if tmp == nil or tmp == "" then
        return
    end
   Connection.Instance:remove_handler(cmd, tmp)
end