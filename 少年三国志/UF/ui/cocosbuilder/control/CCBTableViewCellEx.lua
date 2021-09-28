--CCBTableViewCellEx.lua

local  CCBTableViewCellEx = class ("CCBTableViewCellEx", function (  )
	return CCTableViewCell:create()
end)

function CCBTableViewCellEx:init( ccbFile )
	__Log("load card cell = %s", ccbFile)
	self._ccbFile = NormalLayer.new(ccbFile)
	self:addChild(self._ccbFile)

	self:_onCellLoad()
end

function CCBTableViewCellEx:_onCellLoad(  )
	self:onCellLoad()
end

function CCBTableViewCellEx:onCellLoad(  )
end

function CCBTableViewCellEx:getNode( name )
	if self._ccbFile ~= nil then 
		return self._ccbFile:getNode(name)
	end

	return nil
end

function CCBTableViewCellEx:registerMenuHandler( menuName, fun, target )
	if self._ccbFile ~= nil then 
		return self._ccbFile:registerMenuHandler(menuName, fun, target)
	end

	return false
end

return CCBTableViewCellEx