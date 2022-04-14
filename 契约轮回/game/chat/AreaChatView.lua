--
-- @Author: chk
-- @Date:   2018-09-05 10:03:16
--
AreaChatView = AreaChatView or class("AreaChatView",BaseChatView)
local AreaChatView = AreaChatView

function AreaChatView:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatView"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.channel = ChatModel.AreaChannel
	AreaChatView.super.Load(self)

	self.settors = self.model.channelSettors[self.model.AreaChannel] or {}
	self.model.channelSettors[self.model.AreaChannel] = self.settors
end

function AreaChatView:OnEnable()
	local sceneId = SceneManager.GetInstance():GetSceneId()
	local sceneCfg = Config.db_scene[sceneId]
	if (sceneCfg.type == 1 and sceneCfg.stype == 5) or sceneCfg.type == 2 then
		SetVisible(self.cantChatTip.gameObject,false)
		SetVisible(self.bottom.gameObject,true)
	else
		SetVisible(self.cantChatTip.gameObject,true)
		SetVisible(self.bottom.gameObject,false)
	end
	self:UpdateButtom()
end