require "Core.Module.Common.Panel"

NewTrumpActivePanel = class("NewTrumpActivePanel", Panel);
function NewTrumpActivePanel:New()
	self = {};
	self.count = 0
	setmetatable(self, {__index = NewTrumpActivePanel});
	return self
end

function NewTrumpActivePanel:_Opened()
	UpdateBeat:Add(self.Update, self)
end

function NewTrumpActivePanel:GetUIOpenSoundName()
	return UISoundManager.ui_win
end

function NewTrumpActivePanel:Update()
	self.count = self.count + 1
	if self.count > 2 then	
		UpdateBeat:Remove(self.Update, self)
		self._uiEffect = UIUtil.GetUIEffect("ui_trump_show", self._trsImgRole, self._bg, 1);
	end
end

local equip = LanguageMgr.Get("NewTrump/NewTrumpActivePanel/equip")
local sure = LanguageMgr.Get("NewTrump/NewTrumpActivePanel/sure")

function NewTrumpActivePanel:_Init()
	self:_InitReference();
	self:_InitListener();
	
	self._txtEquip.text = NewTrumpManager.IsTrumpDress() and sure or equip
end

function NewTrumpActivePanel:_InitReference()
	self._txtSkillDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtSkillDes");
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._txtPower = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtPower")
	self._txtProperty1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtProperty1");
	self._txtProperty2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtProperty2");
	self._btnEquip = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnEquip");
	self._txtEquip = UIUtil.GetChildByName(self._btnEquip, "UILabel", "Label")
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg")
	self._trsImgRole = UIUtil.GetChildByName(self._trsContent, "TexturePanel/imgRole")
	self._trsRoleParent = UIUtil.GetChildByName(self._trsContent, "TexturePanel/imgRole/heroCamera/trsRoleParent");
end



function NewTrumpActivePanel:_InitListener()
	self._onClickBtnEquip = function(go) self:_OnClickBtnEquip(self) end
	UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEquip);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function NewTrumpActivePanel:_OnClickBtnEquip()
	if(not NewTrumpManager.IsTrumpDress()) then
		NewTrumpProxy.SendEquipTrump(self.data.id)
	end
	self:_OnClickBtn_close()
end

function NewTrumpActivePanel:IsPopup()
	return false
end


function NewTrumpActivePanel:_OnClickBtn_close()
	ModuleManager.SendNotification(NewTrumpNotes.CLOSE_NEWTRUMPACTIVEPANEL)
end

function NewTrumpActivePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	if(self._uiEffect) then
		Resourcer.Recycle(self._uiEffect, false);
		self._uiEffect = nil;
	end
end

function NewTrumpActivePanel:_DisposeListener()
	UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnEquip = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function NewTrumpActivePanel:_DisposeReference()
	self._btnEquip = nil;
	self._btn_close = nil;
	self._txtSkillDes = nil;
	self._txtName = nil;
	self._txtProperty1 = nil;
	self._txtProperty2 = nil;
	self._trsRoleParent = nil;
	if(self._uiAnimationModel ~= nil) then
		self._uiAnimationModel:Dispose()
		self._uiAnimationModel = nil
	end
end


function NewTrumpActivePanel:UpdatePanel(data)
	self.data = data
	if(self.data) then
		if(self._uiAnimationModel == nil) then
			self._uiAnimationModel = UIAnimationModel:New(self.data, self._trsRoleParent, NewTrumpModeCreater)
		else
			self._uiAnimationModel:ChangeModel(self.data, self._trsRoleParent)
		end
		local attr = self.data.attr
		local propertyData = attr:GetPropertyAndDes()
		
		if(propertyData[1]) then
			self._txtProperty1.text = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[1].property)
		else
			self._txtProperty1.text = ""
		end
		
		if(propertyData[2]) then
			self._txtProperty2.text = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), "+" .. propertyData[2].property)
		else
			self._txtProperty2.text = ""
		end
		
		self._txtName.text = self.data.configData.name
		self._txtPower.text = "+" .. CalculatePower(self.data:GetSelfAttr())
		self._txtSkillDes.text = self.data:GetTrumpSkillInfo().name .. ":" .. self.data:GetTrumpSkillInfo().skill_desc
	end
	
end 