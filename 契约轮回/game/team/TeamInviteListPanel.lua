TeamInviteListPanel = TeamInviteListPanel or class("TeamInviteListPanel",WindowPanel)
local TeamInviteListPanel = TeamInviteListPanel

function TeamInviteListPanel:ctor()
	self.abName = "team"
	self.assetName = "TeamInviteListPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 3

	self.item_list = {}
	self.height = 0

	self.model = TeamModel:GetInstance()
end

function TeamInviteListPanel:dctor()

	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function TeamInviteListPanel:Open( )
	TeamInviteListPanel.super.Open(self)
end

function TeamInviteListPanel:LoadCallBack()
	self.nodes = {
		"invite_scroll/Viewport/Content", "btn_rejectall"
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
	self:SetPanelSize(642, 487)
	self:SetTileTextImage("team_image", "team_f_3")
end

function TeamInviteListPanel:AddEvent()


	local function call_back(target,x,y)
		TeamController:GetInstance():RequestHandleInvite(nil, 1)
	end
	AddClickEvent(self.btn_rejectall.gameObject,call_back)

	local function call_back()
		self:UpdateView( )
	end
	self.event_id = GlobalEvent:AddListener(TeamEvent.UpdateInviteList, call_back)
end

function TeamInviteListPanel:OpenCallBack()
	self:UpdateView()
end

function TeamInviteListPanel:UpdateView( )
	for _, item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
	local invite_list = self.model:GetInivteList()
	if invite_list then
		for i=1, #invite_list do
			local item = invite_list[i]
			local inviteItem = TeamMemberItem3(self.Content)
			inviteItem:SetData(item)
			self.item_list[i] = inviteItem
		end
	end
end

function TeamInviteListPanel:CloseCallBack(  )

end
