require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"

local RedColor = Color.New(255 / 0xFF, 60 / 0xFF, 60 / 0xFF);
local GreenColor = Color.New(127 / 0xFF, 255 / 0xFF, 70 / 0xFF);

RealmSkillPanel = class("RealmSkillPanel", UIComponent);

function RealmSkillPanel:New(transform)
	self = { };
	setmetatable(self, { __index = RealmSkillPanel });
	if (transform) then
		self:Init(transform);
	end
	return self
end

function RealmSkillPanel:_Init()
	self._isSelected = false;
	self._isEnabled = false;
	self:_InitReference();
	self:_InitListener();
end

function RealmSkillPanel:AddClickListener(owner, selectHandler, upgradeHandler)
	self._owner = owner;
	self._selectHandler = selectHandler;
	self._upgradeHandler = upgradeHandler;
end

function RealmSkillPanel:_InitReference()
	self._imgFlag = UIUtil.GetChildByName(self._transform, "UISprite", "imgFlag");

	self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
	self._txtLevel = UIUtil.GetChildByName(self._transform, "UILabel", "txtLevel");

	self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName");
	self._txtDesc = UIUtil.GetChildByName(self._transform, "UILabel", "txtDesc");

	self._txtSpend = UIUtil.GetChildByName(self._transform, "UILabel", "txtSpend");

	self._txtCondition = UIUtil.GetChildByName(self._transform, "UILabel", "txtCondition");

	self._btnUpgrade = UIUtil.GetChildByName(self._transform, "UIButton", "btnUpgrade");
	--self._btnUpgrade.isEnabled = false;
	self._goActived = UIUtil.GetChildByName(self._transform, "UILabel", "actived").gameObject;
    
	self:_RefreshSelectedUI();
end

function RealmSkillPanel:_RefreshSelectedUI()
	if (self._imgFlag) then
		self._imgFlag.gameObject:SetActive(self._isSelected);
		--self._btnUpgrade.gameObject:SetActive(self._isEnabled and self._isSelected);
        self:SetUpgrade()
	end
end

function RealmSkillPanel:_RefreshEnabledUI()
	if (self._btnUpgrade) then
		--self._btnUpgrade.gameObject:SetActive(self._isEnabled and self._isSelected);
        self:SetUpgrade()
        self:SetCondition()
        --[[
		if (self._isEnabled) then
			self._txtCondition.color = GreenColor;
		else
			self._txtCondition.color = RedColor;
		end
        --]]
	end
end
function RealmSkillPanel:_IsFullLev()
    if not self.skill then return false end
    local c = SkillManager:GetSkillById(self.skill.id)
    --Warning(tostring(self.skill.id) .. '-' .. tostring(c) .. '---' .. tostring(self.skill.max_lv))
	return c.max_lv <= self.skill.skill_lv
end
function RealmSkillPanel:SetUpgrade()
    local fullLev = self:_IsFullLev()
    self._goActived:SetActive(fullLev)
    self._btnUpgrade.gameObject:SetActive(self._isEnabled and not fullLev)
end

function RealmSkillPanel:_InitListener()
--	self._onClickHandler = function(go) self:_OnClickHandler(self) end
--	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);

	self._onUpgradeClickHandler = function(go) self:_OnUpgradeClickHandler() end
	UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onUpgradeClickHandler);
end

function RealmSkillPanel:SetSkillAndRealm(skill, realm)
	if (skill and realm) then
		self.skill = skill;
		self.realm = realm
		self:Refresh();
	end
end
function RealmSkillPanel:SetCondition()
	if (self._isEnabled) then
		self._txtCondition.color = GreenColor;
        self._txtCondition.text = LanguageMgr.Get("wing/wingSelectItem/active")
	else
		self._txtCondition.color = RedColor;
        self._txtCondition.text = LanguageMgr.Get("realm/condition2",{ n  = self.realm.num })
	end
end

function RealmSkillPanel:Refresh()
	local skill = self.skill;
	local realm = self.realm;    
	if (skill and realm) then
		self._imgIcon.spriteName = skill.icon_id;
		self._txtName.text = skill.name;
		self._txtLevel.text = skill.skill_lv;
		self._txtDesc.text = skill.skill_desc;
		self._txtSpend.text = skill.coin_cost;
	 
        self:SetCondition()
		if (PlayerManager.vp >= skill.coin_cost) then
			self._txtSpend.color = GreenColor 
		else
			self._txtSpend.color = RedColor 
		end
	end
end

function RealmSkillPanel:SetSelected(value)
	if (self._isSelected ~= value) then
		self._isSelected = value;
		self:_RefreshSelectedUI();
	end
end

function RealmSkillPanel:SetEnabled(value)
	if (self._isEnabled ~= value) then
		self._isEnabled = value
		self:_RefreshEnabledUI();
	end
end

function RealmSkillPanel:_OnUpgradeClickHandler()
	--if (self.skill and self._isEnabled and self._isSelected) then
    --Warning(tostring(self.skill) .. '-' .. tostring(self._isEnabled) .. '---' .. tostring(self._owner))
    if (self.skill and self._isEnabled) then
		if (self._owner and self._upgradeHandler) then	
			if (PlayerManager.vp < self.skill.coin_cost) then
				ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, {id = 6, msg= RealmNotes.CLOSE_REALM})
			else
				self._upgradeHandler(self._owner, self);
			end
		end
	end
end

function RealmSkillPanel:_OnClickHandler()
	if (self._isEnabled) then
		if (self._owner and self._selectHandler) then
			self._selectHandler(self._owner, self);
		end
	end
end
  
function RealmSkillPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RealmSkillPanel:_DisposeListener()
--	UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickHandler = nil
    self._onUpgradeClickHandler = nil
	self._owner = nil;
	self._selectHandler = nil;
    self._upgradeHandler = nil;
end

function RealmSkillPanel:_DisposeReference()
    self._imgFlag = nil;
	self._imgIcon = nil;
	self._txtLevel = nil;
	self._txtName = nil;
	self._txtDesc = nil;
	self._txtSpend = nil;
	self._txtCondition = nil;
	self._btnUpgrade = nil;
end