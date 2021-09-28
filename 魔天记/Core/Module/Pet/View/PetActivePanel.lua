require "Core.Module.Common.Panel"

PetActivePanel = class("PetActivePanel", Panel);
local PetSkillGroupItem = require "Core.Module.Pet.View.Item.PetSkillGroupItem"

function PetActivePanel:New()
	self = {};
	self.count = 0
	setmetatable(self, {__index = PetActivePanel});
	return self
end

function PetActivePanel:_Opened()
	-- UpdateBeat:Add(self.Update, self)
	self._uiEffect = UIUtil.GetUIEffect("ui_trump_show", self._effectParent, self._bg, 1);
end

function PetActivePanel:GetUIOpenSoundName()
	return UISoundManager.ui_win
end

-- function PetActivePanel:Update()
-- 	self.count = self.count + 1
-- 	if self.count > 2 then	
-- 		UpdateBeat:Remove(self.Update, self)
-- 	end
-- end
function PetActivePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function PetActivePanel:_InitReference()
	
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._btnEquip = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnEquip");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg")
	self._effectParent = UIUtil.GetChildByName(self._trsContent, "effectParent")	
	self._trsRoleParent = UIUtil.GetChildByName(self._trsContent, "TexturePanel/imgRole/heroCamera/trsRoleParent");
	self._txtNotice = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNotice");
	
	
	local skillParent = UIUtil.GetChildByName(self._trsContent, "skillParent")
	self._skillGroup = PetSkillGroupItem:New()
	self._skillGroup:Init(skillParent)	
	
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
end



function PetActivePanel:_InitListener()
	self._onClickBtnEquip = function(go) self:_OnClickBtnEquip(self) end
	UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEquip);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function PetActivePanel:_OnClickBtnEquip()
	if(PetManager.GetCurUsePetId() ~= self.data:GetId()) then
		PetProxy.SendPetFight(self.data:GetId())
	end
	self:_OnClickBtn_close()
end

function PetActivePanel:IsPopup()
	return false
end

function PetActivePanel:_OnClickBtn_close()
	ModuleManager.SendNotification(PetNotes.CLOSE_PETACTIVEPANEL)
end

function PetActivePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	if(self._uiEffect) then
		Resourcer.Recycle(self._uiEffect, false);
		self._uiEffect = nil;
	end
end

function PetActivePanel:_DisposeListener()
	UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnEquip = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function PetActivePanel:_DisposeReference()
	self._btnEquip = nil;
	self._btn_close = nil;
	self._txtName = nil;
	self._trsRoleParent = nil;
	if(self._uiAnimationModel ~= nil) then
		self._uiAnimationModel:Dispose()
		self._uiAnimationModel = nil
	end
	
	self._curPropertyPhalanx:Dispose()
	self._curPropertyPhalanx = nil
	
	self._skillGroup:Dispose()
	self._skillGroup = nil
end
local notice1 = LanguageMgr.Get("Pet/PetActivePanel/notice1")
local notice2 = LanguageMgr.Get("Pet/PetActivePanel/notice2")

function PetActivePanel:UpdatePanel(data, attrs)
	
	self.data = data
	if(self.data) then
		if(self._uiAnimationModel == nil) then
			self._uiAnimationModel = UIAnimationModel:New(self.data, self._trsRoleParent, PetModelCreater)
		else
			self._uiAnimationModel:ChangeModel(self.data, self._trsRoleParent)
		end
		
		self._uiAnimationModel:SetScale(self.data:GetScale())
		
		
		self._txtName.text = self.data:GetName()
		
		
		local allSkills = self.data:GetAllAddSkills()
		self._skillGroup:UpdateItem(allSkills)
		self._skillGroup:UnSetGray()
		if(attrs) then
			self._txtNotice.text = notice1
			local p = attrs:GetPropertyAndDes()
			self._curPropertyPhalanx:Build(2, 2, p)
		else
			self._txtNotice.text = notice2
			local p = self.data:GetAttr():GetPropertyAndDes()
			self._curPropertyPhalanx:Build(2, 2, p)
		end
		
		
		
	end
	
end 