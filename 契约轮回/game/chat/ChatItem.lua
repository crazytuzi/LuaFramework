require("game.roleinfo.RoleInfoModel")

ChatItem = ChatItem or class("ChatItem", BaseWidget)
local ChatItem = ChatItem

function ChatItem:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatItem"

	self.height = 0
	--self.model = 2222222222222end:GetInstance()
	BaseWidget.Load(self)
end

function ChatItem:dctor()
end

function ChatItem:LoadCallBack()
	self.nodes = {
		"othercon", "othercon/Icon", "othercon/top/vip", "othercon/top/name", "othercon/top/server", "othercon/msgbg", "othercon/Content",
		"selfcon", "selfcon/SIcon", "selfcon/stop/svip", "selfcon/stop/sname", "selfcon/stop/sserver", "selfcon/smsgbg", "selfcon/SContent"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function ChatItem:AddEvent()

end

function ChatItem:SetData(data)
	if data.role_id ~= RoleInfoModel:GetInstance():GetMainRoleId() then
		SetVisible(self.othercon, true)
		SetVisible(self.selfcon, false)
		self.vip:GetComponent('Text').text = data.viplevel
		self.name:GetComponent('Text').text = data.role_nick
		local content_text = self.Content:GetComponent('Text')
		content_text.text = data.content

		self.height = content_text.preferredHeight
	else
		SetVisible(self.othercon, false)
		SetVisible(self.selfcon, true)
		self.svip:GetComponent('Text').text = data.viplevel
		self.sname:GetComponent('Text').text = data.role_nick
		local content_text = self.SContent:GetComponent('Text')
		content_text.text = data.content

		self.height = content_text.preferredHeight
		self.smsgbg.sizeDelta = Vector2(self.smsgbg.sizeDelta.x, self.height+5)
	end
	return self.height+30+15
end


function ChatItem:GetHeight()
	return 30 + 15 + self.height
end
