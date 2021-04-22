--[[
    Class name QNode
    Create by julian 
--]]

local QNode = class("QNode")

--[[
    options is a table. Valid key below:
--]]
function QNode:ctor( options )
    self._children = {}
    self._childCount = 0
    self._parent = nil
    self._options = options or {}
end

function QNode:getOptions()
    return self._options
end

function QNode:addChild( child )
    if child == nil then
        assert(false, "QNode:addChild invalid child")
        return
    end

    if child:getParent() ~= nil then
        assert(false, "QNode:addChild child already added. It can't be added again")
        return
    end

    table.insert(self._children, child)
    self._childCount = self._childCount + 1
    child:setParent(self)
    child:onEnter()
end

function QNode:removeChild( child )
    if child == nil or child:getParent() == nil or child:getParent() ~= self then
        assert(false, "QNode:removeChild invalid child")
        return
    end

    for i, value in ipairs(self._children) do
        if value == child then
            child:onExit()
            child:setParent(nil)
            table.remove(self._children, i)
            self._childCount = self._childCount - 1
            return
        end
    end

    assert(false, "QNode:removeChild can not find child")
end

function QNode:hasChild( child )
    if child == nil then return false end

    for i, value in ipairs(self._children) do
        if value == child then
            return true
        end
    end

    return false
end

function QNode:removeFromParent()
    if self:getParent() ~= nil then
        self:getParent():removeChild(self)
    end
end

function QNode:getChildren()
    return self._children
end

-- index start from 1
function QNode:getChildAtIndex( index )
    if index == nil or self:getChildrenCount() < index then
        assert(false, "QNode:getChildAtIndex index out of children's count")
        return nil
    end
    return self._children[index]
end

function QNode:getChildrenCount()
    -- return table.nums(self._children)
    return self._childCount
end

function QNode:getParent()
    return self._parent
end

function QNode:setParent(parent)
    self._parent = parent
end

function QNode:onEnter()

end

function QNode:onExit()

end

return QNode