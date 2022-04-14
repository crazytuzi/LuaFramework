TeamRemindPanel = TeamRemindPanel or class("TeamRemindPanel",WindowPanel)
local TeamRemindPanel = TeamRemindPanel

function TeamRemindPanel:ctor()
	self.abName = "team"
	self.assetName = "TeamRemindPanel"
	self.layer = "UI"

	self.use_background = false
	self.change_scene_close = true
	self.panel_type = 4

	self.model = TeamModel:GetInstance()
end

function TeamRemindPanel:dctor()
end

function TeamRemindPanel:Open( roleName )
	self.roleName = roleName
	TeamRemindPanel.super.Open(self)
end

function TeamRemindPanel:LoadCallBack()
	self.nodes = {
		"btn_cancel", "btn_ok", "content"
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
	self:SetPanelSize(505, 336)
	self:SetTileText("Member notice")
end

function TeamRemindPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_cancel.gameObject,call_back)

	local function call_back(target,x,y)
		local team_info = self.model:GetTeamInfo()
		local type_id = team_info.type_id
		local teamtarget = Config.db_team_target_sub[type_id]
		if teamtarget and teamtarget.dunge_id > 0 then
			local dunge_id = teamtarget.dunge_id
			TeamController:GetInstance():DungeEnterAsk(dunge_id, 1)
		end
		self:Close()
	end
	AddClickEvent(self.btn_ok.gameObject,call_back)
end

function TeamRemindPanel:OpenCallBack()
	self:UpdateView()
end

function TeamRemindPanel:UpdateView( )
	local teamInfo = TeamModel.GetInstance():GetTeamInfo()
	local type_id = teamInfo.type_id
	local teamtarget = Config.db_team_target_sub[type_id]
	self.content:GetComponent('Text').text = string.format(ConfigLanguage.Team.EnterTip,
			table.nums(teamInfo.members or {}) ,self.roleName, teamtarget.name)
end

function TeamRemindPanel:CloseCallBack(  )

end