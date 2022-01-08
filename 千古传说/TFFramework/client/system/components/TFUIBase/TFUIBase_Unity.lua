--
-- Author: Bai Yun
-- Date: 2014-07-17 15:46:11
--

local component = {}

TFCOMPONENT_UPDATE = 1

local function _getComponentType(name)
	local tp = type(name) 
	if tp == 'string' then 
		if _G[name] then return _G[name] end
		return require(name)
	elseif tp == 'table' then 
		return name
	end
	return NULL
end

function component:lazyInitComponentEvent()
	if not self.localComponents__ then 
		self:addMEListener(TFWIDGET_ENTER, self.componentEnableHandle)
		self:addMEListener(TFWIDGET_EXIT, self.componentDisableHandle)
		self:addMEListener(TFWIDGET_CLEANUP, self.componentDestroyHandle)
		self:addMEListener(TFWIDGET_ENTERFRAME, self.componentUpdateHandle)

		self.localComponents__ = self.localComponents__ or {}
		if not self.transform or type(self.transform) ~= 'table' then 
			self:addComponent(TFLuaTransform)
			self.transform = self:getComponent(TFLuaTransform)
		end
	end
end

function component:enableUseComponent()
	self:lazyInitComponentEvent()
end

function component:addComponent(name)
	self:lazyInitComponentEvent()

	self.localComponents__ = self.localComponents__ or {}
	name = _getComponentType(name)
	local comp
	if not self.localComponents__[name] then 
		comp = name:create(self)
		self.localComponents__[name] = comp
		comp.transform = self.transform
		comp:Awake()
	else 
		comp = self.localComponents__[name] 
	end
	return comp
end

function component:getComponent(name)
	self:lazyInitComponentEvent()
	if self.localComponents__ then 
		name = _getComponentType(name)
		return self.localComponents__[name]
	end
end

function component:removeComponent(name)
	local bRet = false
	name = _getComponentType(name)
	if self.localComponents__[name] then 
		local comp = self.localComponents__[name]
		self.localComponents__[name] = nil

		comp:OnDestroy()
		bRet = true
	end
	return bRet
end

function component:removeAllComponent()
	if self.localComponents__ then 
		for k, comp in pairs(self.localComponents__) do 
			comp:OnDestroy()
		end
		self.localComponents__ = {}
	end
end

function component:enableCompOPT(nOPT)
	if nOPT == TFCOMPONENT_UPDATE then 
		self:scheduleUpdate()
	end
end

function component:disableCompOPT(nOPT)
	if nOPT == TFCOMPONENT_UPDATE then 
		self:unscheduleUpdate()
	end
end

function component:sendCompMessage(msg, ...)
	if self.localComponents__ then 
		for name, comp in pairs(self.localComponents__) do 
			if comp.isEnabled then 
				local func = comp[msg]
				if func and type(func) == 'function' then 
					func(comp, ...)
				end
			end
		end
	end
end

function component:componentEnableHandle(nDT)
	self:sendCompMessage("OnEnable")
end

function component:componentDisableHandle(nDT)
	self:sendCompMessage("OnDisable")
end

function component:componentUpdateHandle(nDT)
	if self.__isStart__ then 
		self:sendCompMessage('Update', nDT)
	else
		self.__isStart__ = true
		self:sendCompMessage('Start', nDT)
	end
end

function component:componentDestroyHandle(nDT)
	self:sendCompMessage('OnDestroy')
end

for name, func in pairs(component) do 
	if type(func) == 'function' then 
		rawset(CCNode, name, func)
	end
end