PropTween = {}
PropTween.__index = PropTween
function PropTween:new(target, property, start, change, name, isPlugin, nextNode, priority)
	local self = {}
	setmetatable(self, PropTween)
	self.__index = self

	function init()
		self.target = target
		self.property = property
		self.start = start
		self.name = name
		self.isPlugin = isPlugin
		self.change = change
		if nextNode then
			self.nextNode = nextNode
			nextNode.preNode = self
		end
		self.priority = priority or 0
	end
	init()
	return self
end

------//////////
return PropTween