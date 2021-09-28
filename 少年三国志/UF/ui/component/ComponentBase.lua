--ComponentBase.lua


local ComponentBase = class("ComponentBase", function(name)
    return ComponentExtend.extend(CCComponentEx:create(name))
end)

function ComponentBase:init(  )
	self:addScriptHandler()
end

function ComponentBase:onComponentEnter(  )
end

function ComponentBase:onComponentExit(  )
end

function ComponentBase:onComponentUpdate(  )
end

function ComponentBase:onComponentSerialize(  )
end

return ComponentBase
