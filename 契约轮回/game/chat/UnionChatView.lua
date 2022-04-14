--
-- @Author: chk
-- @Date:   2018-09-05 10:14:09
--
UnionChatView = UnionChatView or class("UnionChatView",BaseChatView)
local UnionChatView = UnionChatView

function UnionChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.UnionChannel
	UnionChatView.super.Load(self)
end

function UnionChatView:SendMsg()
	if self.roleData.guild ~= nil and self.roleData.guild ~= "" and  self.roleData.guild ~= "0" then
		UnionChatView.super.SendMsg(self)
	else
		Notify.ShowText(ConfigLanguage.Faction.PleaseEnterFaction)
	end
end

function UnionChatView:SendInScenePos()

	local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
	if roleData.guild == nil or roleData.guild == "" or  roleData.guild == "0" then
		Notify.ShowText(ConfigLanguage.Faction.PleaseEnterFaction)
		return
	end
	UnionChatView.super.SendInScenePos(self,self.channel)
end