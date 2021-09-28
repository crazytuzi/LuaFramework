--FlyAttributeInstance.lua


local FlyAttributeInstance = class("FlyAttributeInstance", function ( ... )
	return CCNodeExtend.extend(CCNode:create())
end)


function FlyAttributeInstance:ctor( ... )
	self._collectAttri = {}
	self._finish = true
end

function FlyAttributeInstance:addNormalText( desc, clr, destCtrl, offset, startPos, fontSize)
	G_flyAttribute.addNormalText(desc, clr, destCtrl, offset, startPos, fontSize)
end

function FlyAttributeInstance:play( func, speed, flag )
	if type(G_flyAttribute._attributes) ~= "table" or #G_flyAttribute._attributes < 1 then 
		return false
	end

	self._collectAttri = G_flyAttribute._attributes or {}
	self._finish = false
	local _callback = function ( ... )
		self._finish = true
		if func then 
			func()
		end
	end
	G_flyAttribute.play(_callback, speed, flag)

	return true
end

function FlyAttributeInstance:onExit()
	if not self._finish then 
		self:onClearAttri()
	end
end

function FlyAttributeInstance:onClearAttri( ... )
	for key, value in pairs(self._collectAttri) do 
		if value.text then 
			value.text:removeFromParentAndCleanup(true)
		end
		if value.dest then 
			value.dest:stopAllActions()
			value.dest:setScale(1)
		end
	end
	self._collectAttri = {}
end

return FlyAttributeInstance
