--
-- @Author: chk
-- @Date:   2018-09-05 10:12:29
--
TeamChatView = TeamChatView or class("TeamChatView",BaseChatView)
local TeamChatView = TeamChatView

function TeamChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.TeamChannel
	TeamChatView.super.Load(self)
end


function TeamChatView:SendMsg()

	if TeamModel.GetInstance():GetTeamInfo() ~= nil then
		TeamChatView.super.SendMsg(self)
	else
		Notify.ShowText(ConfigLanguage.ChatChn.PleaseEnterTeam)
	end
end

function TeamChatView:SendInScenePos()

	if TeamModel.GetInstance():GetTeamInfo() == nil then
		Notify.ShowText(ConfigLanguage.ChatChn.PleaseEnterTeam)
		return
	end
	TeamChatView.super.SendInScenePos(self,self.channel)
end