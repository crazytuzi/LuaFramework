require "Core.Module.Pattern.Mediator"
require "Core.Module.OtherInfo.OtherInfoNotes"

require "Core.Module.Common.ResID"
require "Core.Module.OtherInfo.View.OtherInfoPanel"
-- require "Core.Module.OtherInfo.View.OtherSkillPanel"
-- require "Core.Module.OtherInfo.View.OtherPetPanel"
require "Core.Module.OtherInfo.View.OtherFightPanel"

OtherInfoMediator = Mediator:New();
local _notification = {
	OtherInfoNotes.OPEN_INFO_PANEL,
	OtherInfoNotes.CLOSE_INFO_PANEL,
	OtherInfoNotes.OPEN_SKILL_PANEL,
	OtherInfoNotes.CLOSE_SKILL_PANEL,
	OtherInfoNotes.OPEN_PET_PANEL,
	OtherInfoNotes.CLOSE_PET_PANEL,
	OtherInfoNotes.OPEN_FIGHT_PANEL,
	OtherInfoNotes.CLOSE_FIGHT_PANEL
};
function OtherInfoMediator:OnRegister()
	MessageManager.AddListener(OtherInfoNotes, OtherInfoNotes.RSP_DETAIL_INFO, OtherInfoMediator.OnDetailInfo, self);
	MessageManager.AddListener(OtherInfoNotes, OtherInfoNotes.RSP_SKILL_INFO, OtherInfoMediator.OnSkillInfo, self);
	MessageManager.AddListener(OtherInfoNotes, OtherInfoNotes.RSP_PET_INFO, OtherInfoMediator.OnPetInfo, self);
	MessageManager.AddListener(OtherInfoNotes, OtherInfoNotes.RSP_FIGHT_INFO, OtherInfoMediator.OnFightInfo, self);
end

function OtherInfoMediator:OnRemove()
	MessageManager.RemoveListener(OtherInfoNotes, OtherInfoNotes.RSP_DETAIL_INFO, OtherInfoMediator.OnDetailInfo);
	MessageManager.RemoveListener(OtherInfoNotes, OtherInfoNotes.RSP_SKILL_INFO, OtherInfoMediator.OnSkillInfo);
	MessageManager.RemoveListener(OtherInfoNotes, OtherInfoNotes.RSP_PET_INFO, OtherInfoMediator.OnPetInfo);
	MessageManager.RemoveListener(OtherInfoNotes, OtherInfoNotes.RSP_FIGHT_INFO, OtherInfoMediator.OnFightInfo);
	
	self:CloseInfoPanel();
	self:CloseSkillPanel();
	self:ClosePetPanel();
end

function OtherInfoMediator:_ListNotificationInterests()
	return _notification
end

function OtherInfoMediator:_HandleNotification(notification)
	if notification:GetName() == OtherInfoNotes.OPEN_INFO_PANEL then
		
		local id = notification:GetBody();
		self.reqId = id;
		OtherInfoProxy.ReqOtherInfo(id);
		
	elseif notification:GetName() == OtherInfoNotes.CLOSE_INFO_PANEL then		
		self:CloseInfoPanel();
		
	elseif notification:GetName() == OtherInfoNotes.OPEN_SKILL_PANEL then
		
		local id = notification:GetBody();
		self.reqSklId = id;
		OtherInfoProxy.ReqOtherSkill(id);
		
	elseif notification:GetName() == OtherInfoNotes.CLOSE_SKILL_PANEL then
		self:CloseSkillPanel();
		
	elseif notification:GetName() == OtherInfoNotes.OPEN_PET_PANEL then
		
		local d = notification:GetBody();
		self.reqPetId = d.pid;
		OtherInfoProxy.ReqOtherPet(d.id, d.pid);
		
	elseif notification:GetName() == OtherInfoNotes.CLOSE_PET_PANEL then
		self:ClosePetPanel();
	elseif notification:GetName() == OtherInfoNotes.OPEN_FIGHT_PANEL then
		
		local id = notification:GetBody();
		OtherInfoProxy.ReqOtherFight(id);
		
	elseif notification:GetName() == OtherInfoNotes.CLOSE_FIGHT_PANEL then
		self:CloseFightPanel();
	end
	
end

function OtherInfoMediator:CloseInfoPanel()
	if(self._panel ~= nil) then
		PanelManager.RecyclePanel(self._panel, ResID.UI_OTHERINFO);
		self._panel = nil;
	end
end

function OtherInfoMediator:CloseSkillPanel()
	if(self._skillPanel ~= nil) then
		PanelManager.RecyclePanel(self._skillPanel, ResID.UI_OTHERSKILL);
		self._skillPanel = nil;
	end
end

function OtherInfoMediator:ClosePetPanel()
	if(self._petPanel ~= nil) then
		PanelManager.RecyclePanel(self._petPanel, ResID.UI_OTHERPET);
		self._petPanel = nil;
	end
end

function OtherInfoMediator:CloseFightPanel()
	if(self._fightPanel ~= nil) then
		PanelManager.RecyclePanel(self._fightPanel, ResID.UI_OTHERFIGHT);
		self._fightPanel = nil;
	end
end

function OtherInfoMediator:OnDetailInfo(data)
	if self.reqId == data.id then
		if(self._panel == nil) then
			self._panel = PanelManager.BuildPanel(ResID.UI_OTHERINFO, OtherInfoPanel);
		end
		self._panel:Update(data);
	end
end

function OtherInfoMediator:OnSkillInfo(data)
	-- if self.reqSklId == data.id then
	-- 	if(self._skillPanel == nil) then
	-- 		self._skillPanel = PanelManager.BuildPanel(ResID.UI_OTHERSKILL, OtherSkillPanel);
	-- 	end
	-- 	self._skillPanel:Update(data);
	-- end
end

function OtherInfoMediator:OnPetInfo(data)
	
	-- if self.reqPetId == data.pet_id then
	-- 	if(self._petPanel == nil) then
	-- 		self._petPanel = PanelManager.BuildPanel(ResID.UI_OTHERPET, OtherPetPanel);
	-- 	end
		
	-- 	self._petPanel:Update(data);
	-- end
end

function OtherInfoMediator:OnFightInfo(data)
	
	if(self._fightPanel == nil) then
		self._fightPanel = PanelManager.BuildPanel(ResID.UI_OTHERFIGHT, OtherFightPanel);
	end
	
	self._fightPanel:Update(data);
	
end 