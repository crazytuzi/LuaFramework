require "Core.Module.Common.UIItem"

NewTrumpItem = class("NewTrumpItem", UIItem);
function NewTrumpItem:New()
	self = {};
	setmetatable(self, {__index = NewTrumpItem});
	return self
end


function NewTrumpItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function NewTrumpItem:_InitReference()
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtRefineLev = UIUtil.GetChildByName(self.transform, "UILabel", "refineLev")
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
	self._onClickItem = function(go) self:_OnClickItem(self) end
	self._goCanActive = UIUtil.GetChildByName(self.transform, "state").gameObject
	self._goTag = UIUtil.GetChildByName(self.transform, "tag").gameObject
	self._tip = UIUtil.GetChildByName(self.transform, "tip")
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function NewTrumpItem:_InitListener()
end

function NewTrumpItem:_OnClickItem()
	NewTrumpManager.SetCurrentSelectTrump(self.data)
	ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
end

function NewTrumpItem:_Dispose()
	self:_DisposeReference();
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function NewTrumpItem:_DisposeReference()
	self._imgIcon = nil
	self._imgQuality = nil
	self._tip = nil
end

function NewTrumpItem:SetToggleActive(active)
	self._toggle.value = active
	NewTrumpManager.SetCurrentSelectTrump(self.data)
	ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
end

function NewTrumpItem:SetToggle(active)
	self._toggle.value = active
end

function NewTrumpItem:UpdateItem(data)
	self.data = data
	
	if(self.data) then
		self._imgIcon.spriteName = tostring(self.data.configData.icon)
		self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		if(self.data.state == NewTrumpInfo.State.NotActive) then
			self._txtName.color = Color.gray
			self._txtRefineLev.text = ""
		else
			self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
			self._txtRefineLev.text = self.data:GetCurRefineLev()
		end
		
		self._txtName.text = self.data.configData.name
		self._goCanActive:SetActive(self.data.state == NewTrumpInfo.State.CanActive)
		self._goTag:SetActive(self.data.state == NewTrumpInfo.State.HadDress)
		self._tip.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.NewTrumpRefine) and self.data:CanTrumpRefine())
	end
	
end 