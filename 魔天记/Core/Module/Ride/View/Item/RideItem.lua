require "Core.Module.Common.UIItem"
RideItem = class("RideItem", UIItem);
RideItem.ACTIVATE = LanguageMgr.Get("ride/rideItem/isGet")
RideItem.CANACTIVATE = LanguageMgr.Get("ride/rideItem/canActive")

RideItem.NEEDITEM = LanguageMgr.Get("ride/rideItem/piectChange")
function RideItem:New()
	self = {};
	setmetatable(self, {__index = RideItem});
	return self
end

function RideItem:_Init()
	local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
	self._txtName = UIUtil.GetChildInComponents(txts, "rideName")
	self._txtState = UIUtil.GetChildInComponents(txts, "rideState")
	self._txtTimeLimit = UIUtil.GetChildInComponents(txts, "rideTimeLimit")
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "rideIcon")
	self._widget = UIUtil.GetComponent(self.transform, "UIWidget")
	-- self._imgIcon = UIUtil.GetChildByName(self.transform, "Transform", "rideIcon").gameObject
	-- self._imgIcon.atlas = nil
	--    self._imgFrame = UIUtil.GetChildByName(self.transform, "UISprite", "rideQulity")
	self._goUsedTag = UIUtil.GetChildByName(self.transform, "goUsedTag").gameObject
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle");
	self._onClickItem = function(go) self:_OnClickItem(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
	self:UpdateItem(self.data)
end

function RideItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
	
	self._imgIcon = nil
	self._toggle = nil
	self._goUsedTag = nil
end

function RideItem:_OnClickItem()
	RideProxy.SetCurrentRideId(self.data.info.id)
end

local one = Vector3.one
local zeropointseven = Vector3.one * 0.7

function RideItem:UpdateItem(data)
	if(data == nil) then return end
	self.data = data
	if(self.data.info.id ~= RideManager.GetCurrentRideId()) then
		self.transform.localScale = zeropointseven
		self._widget.alpha = 0.7
	else
		self.transform.localScale = one
		self._widget.alpha = 1
	end
	self._imgIcon.spriteName = tostring(self.data.info.icon_id)
	-- UIUtil.SetUISpriteName(self._imgIcon,self.data.info.icon_id)
	self._txtName.text = self.data.info.name
	self._txtName.color = ColorDataManager.GetColorByQuality(self.data.info.quality)
	--    self._imgFrame.spriteName = ProductManager.GetQulitySpriteName(self.data.info.quality)
	local isUsed = self.data.info:GetIsUse()
	local isActivate = self.data.info:GetIsActivate()
	
	self._goUsedTag:SetActive(isUsed)
	if(self.data.info.id == RideManager.GetCurrentRideId()) then
		self._toggle.value = true
	end
	
	if(isActivate) then	
		self._txtTimeLimit.text = TimeTranslate(self.data.info:GetTimeLimit())
		self._txtState.text = RideItem.ACTIVATE
	else
		local need = self.data.info:GetSynthetic()
		local count = BackpackDataManager.GetProductTotalNumBySpid(need.itemId)
		
		self._txtTimeLimit.text = TimeTranslate(self.data.info.effective_time * 1000)
		if(count >= need.itemCount) then
			self._txtState.text = RideItem.CANACTIVATE
		else
			self._txtState.text = RideItem.NEEDITEM .. count .. "/" .. need.itemCount
		end
		
		
	end
	
end 