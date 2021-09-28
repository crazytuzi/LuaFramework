--CompoentExtend.lua


ComponentExtend = class("ComponentExtend", ComponentExtend)
ComponentExtend.__index = ComponentExtend

function ComponentExtend.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, ComponentExtend)
    return target
end

function ComponentExtend:addScriptHandler()
    local handler = function(event)
        if event == "enter" then
            self:onComponentEnter()
        elseif event == "exit" then
            self:unregisterScriptHandler()
            self:onComponentExit()
        elseif event == "update" then
            self:onComponentUpdate()
        elseif event == "serialize" then 
            self:onComponentSerialize()
        end
    end
    self:registerScriptHandler(handler)
end

function ComponentExtend:onComponentEnter(  )
end

function ComponentExtend:onComponentExit(  )
end

function ComponentExtend:onComponentUpdate(  )
end

function ComponentExtend:onComponentSerialize(  )
end