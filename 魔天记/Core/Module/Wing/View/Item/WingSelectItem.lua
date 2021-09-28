require "Core.Module.Common.UIItem"

WingSelectItem = class("WingSelectItem", UIItem);
local ACTIVEDES = ColorDataManager.GetColorText(ColorDataManager.Get_green(), LanguageMgr.Get("wing/wingSelectItem/active"))
local UNACTIVATE = ColorDataManager.GetColorText(ColorDataManager.Get_red(), LanguageMgr.Get("wing/wingSelectItem/unActive"))
local CANACTIVATE = ColorDataManager.GetColorText(ColorDataManager.Get_green(), LanguageMgr.Get("wing/wingSelectItem/canActive"))


local _activeTopColor = Color.New(236 / 255, 1, 228 / 255)
local _activeBottomColor = Color.New(88 / 255, 1, 66 / 255)
local _activeOutLineColor = Color.New(30 / 255, 142 / 255, 4 / 255)
local _unActiveTopColor = Color.New(1, 240 / 255, 240 / 255)
local _unActiveBottomColor = Color.New(1, 192 / 255, 192 / 255)
local _unActiveOutLineColor = Color.New(196 / 255, 0, 0)


function WingSelectItem:New()
	self = {};
	setmetatable(self, {__index = WingSelectItem});
	return self
end


function WingSelectItem:_Init()
	self._txtStateName = UIUtil.GetChildByName(self.transform, "UILabel", "stateName")
	self._goDress = UIUtil.GetChildByName(self.transform, "trsDress").gameObject
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	
	self._onClickItem = function(go) self:_OnClickItem(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
	self:UpdateItem(self.data)
end

function WingSelectItem:UpdateItem(data)
	self.data = data
	local tempDes = ""
	local dressWingData = WingManager.GetCurDressWingData()
	local currentWingData = WingManager.GetCurrentWingData()
	if(dressWingData and dressWingData.id == data.id) then
		self._goDress:SetActive(true)
		tempDes = ""
	else		
		self._goDress:SetActive(false)
		
		--已激活
		if(self.data.state == WingManager.WingState.HadActive) then
			tempDes = ACTIVEDES
			self._txtStateName.gradientBottom = _activeBottomColor
			self._txtStateName.gradientTop = _activeTopColor
			self._txtStateName.effectColor = _activeOutLineColor
		else --未激活			
			if(self.data.active_cost == 0 or BackpackDataManager.GetProductTotalNumBySpid(self.data.active_cost) == 0) then
				tempDes = UNACTIVATE
				self._txtStateName.gradientBottom = _unActiveBottomColor
				self._txtStateName.gradientTop = _unActiveTopColor
				self._txtStateName.effectColor = _unActiveOutLineColor
			else
				tempDes = CANACTIVATE
				self._txtStateName.gradientBottom = _activeBottomColor
				self._txtStateName.gradientTop = _activeTopColor
				self._txtStateName.effectColor = _activeOutLineColor
			end
		end
	end	
	
	self._txtName.text = self.data.name
	self._imgIcon.spriteName = tostring(self.data.icon_id)
	self._txtStateName.text = tempDes
end

function WingSelectItem:_OnClickItem()
	WingProxy.SetCurSelectWingId(self.data.id)
	ModuleManager.SendNotification(WingNotes.UPDATE_WINGPANEL, self.data)
end

function WingSelectItem:_Dispose()
	
	self._imgIcon = nil
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function WingSelectItem:SetToggleActive()
	self._toggle.value = true
	self:_OnClickItem()
end
