require "Core.Module.Common.UIItem"

RealmUpgradeLevel = class("RealmUpgradeLevel", UIItem);

require "Core.Module.Common.UIEffect"

function RealmUpgradeLevel:New(gameObject, index)
	self = {};
	setmetatable(self, {__index = RealmUpgradeLevel});
	self:SetIndex(index)
	if(gameObject) then
		self._isInit = true
		self:Init(gameObject);
	end
	self.data = 0
	return self
end

--data为境界等级 上限为63
function RealmUpgradeLevel:UpdateItem(data)
	if(data) then
		-- log(data)
		if(self.data ~= data) then
			local olv = math.ceil(self.data / 9)
			local lv = math.ceil(data / 9)
			if(lv ~= 0 and lv ~= olv) then
				self._uiEffect:ChangeEffect("jingjie_" .. lv)
			end
		end
	 
		self.data = data
		
		local slv = self.data % 9
		slv =(slv == 0) and 9 or slv
		if(self.data and self.data ~= 0) then	
			-- log(self._isInit)
			if(self._isInit) then	
				if(self._index <= slv) then
				 
					self._uiEffect:Play()
				else
					self._uiEffect:Stop()
				end
			else
				if(self._index == slv) then
					self._uiEffect:Play()
				end
			end
		end
		
		if(self._isInit) then
			self._isInit = false
		end
	end
end

function RealmUpgradeLevel:SetIndex(index)
	self._index = index
end

function RealmUpgradeLevel:_Init()
	self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg")
	self._uiEffect = UIEffect:New()
	self._uiEffect:Init(self.transform, self._bg, 0, "jingjie_1")
end

function RealmUpgradeLevel:_Dispose()
	self._bg = nil
	if(self._uiEffect) then
		self._uiEffect:Dispose()
		self._uiEffect = nil
	end
end 