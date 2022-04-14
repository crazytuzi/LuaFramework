DungeTeamMemberItem = DungeTeamMemberItem or class("DungeTeamMemberItem",BaseCloneItem)
local DungeTeamMemberItem = DungeTeamMemberItem

function DungeTeamMemberItem:ctor(obj,parent_node,layer)
	DungeTeamMemberItem.super.Load(self)
end

function DungeTeamMemberItem:dctor()
	if self.item_list then
		destroyTab(self.item_list)
		self.item_list = nil
	end
end

function DungeTeamMemberItem:LoadCallBack()
	self.nodes = {
		"gender", "captain_name", "Content",
		"Content/DungeTeamMemberRoleItem",
	}
	self:GetChildren(self.nodes)
	self.captain_name = GetText(self.captain_name)
	self.gender = GetImage(self.gender)
	self.DungeTeamMemberRoleItem_go = self.DungeTeamMemberRoleItem.gameObject
	SetVisible(self.DungeTeamMemberRoleItem_go, false)
	self.item_list = {}
	self:AddEvent()
end

function DungeTeamMemberItem:AddEvent()
	local function call_back(target,x,y)
		TeamController.GetInstance():RequestApply(self.data.id)
	end
	AddClickEvent(self.gameObject,call_back)
end

--data:team_info
function DungeTeamMemberItem:SetData(data)
	self.data = data
	self:UpdateView()
end

function DungeTeamMemberItem:UpdateView()
	local members = self.data.members
	for i=1, 3 do
		local member = members[i]
		if member and member.role_id == self.data.captain_id then
			self.captain_name.text = member.role.name
			lua_resMgr:SetImageTexture(self, self.gender, 'common_image', string.format('sex_icon_%s', member.role.gender), true)
		end
		local item = self.item_list[i] or DungeTeamMemberRoleItem(self.DungeTeamMemberRoleItem_go, self.Content)
		item:SetData(member)
		self.item_list[i] = item
	end
end