require "Core.Module.Common.UIItem"

MobaoItem = class("MobaoItem", UIItem);
function MobaoItem:New()
	self = {};
	setmetatable(self, {__index = MobaoItem});
	return self
end


function MobaoItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function MobaoItem:_InitReference()
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
	self._onClickItem = function(go) self:_OnClickItem(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function MobaoItem:_InitListener()
end

function MobaoItem:_OnClickItem()
	NewTrumpManager.SetCurrentMobao(self.data)
	ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPPANEL)
    --ModuleManager.SendNotification(NewTrumpNotes.OPEN_MOBAO_NOTICE, self.data)
end

function MobaoItem:_Dispose()
	self:_DisposeReference();
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function MobaoItem:_DisposeReference()
	self._imgIcon = nil
	self._imgQuality = nil
	self._txtName = nil
	self._toggle = nil
end

function MobaoItem:SetToggleActive()
	self:SetToggle(true)
	self:_OnClickItem()
end

function MobaoItem:SetToggle(active)
	self._toggle.value = active
end

function MobaoItem:UpdateItem(data)
	self.data = data	
	if(self.data) then
		self._imgIcon.spriteName = tostring(self.data.icon)
		self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.quality)
		self._txtName.text = self.data.name
		if not NewTrumpManager.IsMobaoEnable(self.data.id) then
			self._txtName.color = Color.gray
		else
			self._txtName.color = ColorDataManager.GetColorByQuality(self.data.quality)
		end		
	end
	
end 