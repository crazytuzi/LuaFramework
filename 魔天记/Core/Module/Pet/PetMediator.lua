require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.Pet.PetNotes"
require "Core.Module.Pet.View.PetPanel"
require "Core.Module.Pet.View.PetSkillDesPanel"
require "Core.Module.Pet.View.PetActivePanel"

-- require "Core.Module.Pet.View.PetChangeSkillPanel"
-- require "Core.Module.Pet.View.PetMotifyNamePanel"
-- require "Core.Module.Pet.View.PetSkillTalentPanel"
-- require "Core.Module.Pet.View.PetUpdateSkillPanel"
-- require "Core.Module.Pet.View.PetAdvancePropertyPanel"
-- require "Core.Module.Pet.View.PetAdvanceSuccessPanel"
-- require "Core.Module.Pet.View.PetRandAptitudePanel"
-- local PetRandAptitudeNewPanel = require "Core.Module.Pet.View.PetRandAptitudeNewPanel"
-- require "Core.Module.Pet.View.PetExplainPanel"
-- require "Core.Module.Pet.View.PetFormationListPanel"
PetMediator = class("PetMediator", Mediator)

local notes = {
	PetNotes.OPEN_PETPANEL,
	PetNotes.CLOSE_PETPANEL,
	PetNotes.UPDATE_PETPANEL,
	
	PetNotes.UPDATE_PETPANEL_NAME,
	PetNotes.OPEN_PETSKILLDESPANEL,
	PetNotes.CLOSE_PETSKILLDESPANEL,	
	
	PetNotes.OPEN_UPDATELEVELPANEL,
	
	PetNotes.UPDATETIPSTATE,
	PetNotes.UPDATE_PETFASHIONPANEL,
	
	PetNotes.OPEN_PETACTIVEPANEL,
	PetNotes.CLOSE_PETACTIVEPANEL,
	
	PetNotes.SHOW_UPEFFECT,
	
	PetNotes.UPDATE_ADDEXPPANEL,	
	
	
	PetNotes.UPDATE_SUBPETINFOLEVEL,
	PetNotes.UPDATE_SUBPETINFOEXP,
	
	PetNotes.UPDATE_SUBPETADVENCELEVEL,
	PetNotes.UPDATE_SUBPETADVENCEEXP,
	PetNotes.SHOW_PETUPDATELEVELLABEL,
	
	PetNotes.SHOW_PETUPDATELEVELEFFECT,
	PetNotes.SHOW_PETUPDATERANKEFFECT,
	PetNotes.SHOW_PETFASHIONEFFECT,
	PetNotes.UPDATE_PETADVANCEFASHIONDATA,
}

function PetMediator:OnRegister()
	
end

function PetMediator:_ListNotificationInterests()
	return notes
end

function PetMediator:_HandleNotification(notification)
	local notificationName = notification:GetName()
	if notificationName == PetNotes.OPEN_PETPANEL then
		local tab = notification:GetBody();
		if(self._petPanel == nil) then
			self._petPanel = PanelManager.BuildPanel(ResID.UI_PETPANEL, PetPanel, true);
		end
		self._petPanel:OpenTab(tab);
	elseif notificationName == PetNotes.UPDATE_PETPANEL then
		if(self._petPanel ~= nil) then
			self._petPanel:UpdatePetPanel()
		end
	elseif notificationName == PetNotes.UPDATETIPSTATE then
		if(self._petPanel ~= nil) then
			self._petPanel:UpdateTipState()
		end		
	elseif notificationName == PetNotes.CLOSE_PETPANEL then
		if(self._petPanel ~= nil) then
			PanelManager.RecyclePanel(self._petPanel, ResID.UI_PETPANEL)
			self._petPanel = nil
		end
	elseif notificationName == PetNotes.UPDATE_PETADVANCEFASHIONDATA then
		if(self._petPanel) then
			self._petPanel:UpdateFashionData(notification:GetBody())
		end		
		
	elseif notificationName == PetNotes.CLOSE_PETSKILLDESPANEL then
		if(self._petSkillDesPanel ~= nil) then
			PanelManager.RecyclePanel(self._petSkillDesPanel, ResID.UI_PETSKILLDESPANEL)
			self._petSkillDesPanel = nil
		end
	elseif notificationName == PetNotes.OPEN_PETSKILLDESPANEL then
		if(self._petSkillDesPanel == nil) then
			self._petSkillDesPanel = PanelManager.BuildPanel(ResID.UI_PETSKILLDESPANEL, PetSkillDesPanel);
			self._petSkillDesPanel:UpdatePetSkillDesPanel(notification:GetBody())
		end
	elseif notificationName == PetNotes.OPEN_UPDATELEVELPANEL then
		if(self._petPanel ~= nil) then
			self._petPanel:OpenUpdateLevelPanel()
		end
	elseif notificationName == PetNotes.OPEN_PETACTIVEPANEL then
		if(self._petActivePanel == nil) then
			self._petActivePanel = PanelManager.BuildPanel(ResID.UI_PETACTIVEPANEL, PetActivePanel, false, PetNotes.CLOSE_PETACTIVEPANEL)
			local body = notification:GetBody()
			self._petActivePanel:UpdatePanel(body[1], body[2])
		end
	elseif notificationName == PetNotes.CLOSE_PETACTIVEPANEL then
		if(self._petActivePanel ~= nil) then
			PanelManager.RecyclePanel(self._petActivePanel, ResID.UI_PETACTIVEPANEL)
			self._petActivePanel = nil
		end
	elseif notificationName == PetNotes.SHOW_UPEFFECT then
		if(self._petPanel ~= nil) then
			self._petPanel:ShowUpEffect()
		end
	elseif notificationName == PetNotes.UPDATE_ADDEXPPANEL then
		if(self._petPanel) then
			self._petPanel:UpdateAddExpPanel()
		end
	elseif notificationName == PetNotes.UPDATE_PETFASHIONPANEL then
		if(self._petPanel) then
			self._petPanel:UpdatePetFashionPanel(notification:GetBody())
		end
	elseif notificationName == PetNotes.UPDATE_SUBPETINFOLEVEL then
		if(self._petPanel) then
			self._petPanel:UpdateLevel(notification:GetBody())
		end
	elseif notificationName == PetNotes.UPDATE_SUBPETINFOEXP then
		if(self._petPanel) then
			self._petPanel:UpdateExp(notification:GetBody())
		end
	elseif notificationName == PetNotes.UPDATE_SUBPETADVENCELEVEL then
		if(self._petPanel) then
			self._petPanel:UpdateAdvanceLevel(notification:GetBody())
		end
	elseif notificationName == PetNotes.UPDATE_SUBPETADVENCEEXP then
		if(self._petPanel) then
			self._petPanel:UpdateAdvanceExp(notification:GetBody())
		end
	elseif notificationName == PetNotes.SHOW_PETUPDATELEVELLABEL then
		if(self._petPanel) then
			self._petPanel:ShowUpdateLevelLabel(notification:GetBody())
		end
	elseif notificationName == PetNotes.SHOW_PETUPDATELEVELEFFECT then
		if(self._petPanel) then
			self._petPanel:ShowUpdateLevelEffect()
		end
	elseif notificationName == PetNotes.SHOW_PETUPDATERANKEFFECT then
		if(self._petPanel) then
			self._petPanel:ShowUpdateRankEffect()
		end
	elseif notificationName == PetNotes.SHOW_PETFASHIONEFFECT then
		if(self._petPanel) then
			self._petPanel:ShowFashionEffect()
		end
	end
end

function PetMediator:OnRemove()
	if(self._petPanel) then
		PanelManager.RecyclePanel(self._petPanel, ResID.UI_PETPANEL)
		self._petPanel = nil
	end
	
	if(self._petSkillDesPanel ~= nil) then
		PanelManager.RecyclePanel(self._petSkillDesPanel, ResID.UI_PETSKILLDESPANEL)
		self._petSkillDesPanel = nil
	end
	
end

