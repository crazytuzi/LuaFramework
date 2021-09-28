require "Core.Module.Common.Panel"
require "Core.Module.Pet.PetNotes"

PetSkillDesPanel = class("PetSkillDesPanel", Panel);
function PetSkillDesPanel:New()
	self = {};
	setmetatable(self, {__index = PetSkillDesPanel});
	return self
end


function PetSkillDesPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function PetSkillDesPanel:GetUIOpenSoundName()
	return ""
end

function PetSkillDesPanel:_InitReference()
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	-- self._txtLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtLevel");
	self._txtDes = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDes");
	self._txtGet = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtGet")
	self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "icon")
	--    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
	--    self._imgQuality = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgQuality");
end

function PetSkillDesPanel:_InitListener()
	
end

function PetSkillDesPanel:_Dispose()
	self:_DisposeReference();
end

function PetSkillDesPanel:_DisposeReference()
	
end

local notice = LanguageMgr.Get("Pet/PetSkillDesPanel/skillDes")
function PetSkillDesPanel:UpdatePetSkillDesPanel(data)
	self._imgIcon.spriteName = data.info.icon_id
	self._txtName.text = data.info.name
	-- self._txtLevel.text = GetLvDes(data.info.skill_lv)
	self._txtDes.text = notice .. data.info.skill_desc
	self._txtGet.text = LanguageMgr.Get("Pet/PetSkillDesPanel/get", {rank = math.ceil((data.unlockStartLev+1) / 10), star = data.unlockStartLev % 10})
end

function PetSkillDesPanel:_OnClickMask()
	ModuleManager.SendNotification(PetNotes.CLOSE_PETSKILLDESPANEL)
end

