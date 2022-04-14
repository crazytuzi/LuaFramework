MyFriendItem = MyFriendItem or class("MyFriendItem",BaseItem)
local MyFriendItem = MyFriendItem

function MyFriendItem:ctor(parent_node,layer)
	self.abName = "friendGift"
	self.assetName = "MyFriendItem"
	self.layer = layer

	self.model = FriendModel:GetInstance()
	MyFriendItem.super.Load(self)
end

function MyFriendItem:dctor()
end

function MyFriendItem:LoadCallBack()
	self.nodes = {
		"name","friendlyvalue","level","selectbtn", "bg2", "bg"
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.friendlyvalue = GetText(self.friendlyvalue)
	self.level = GetText(self.level)

	self:AddEvent()

	self:UpdateView()
end

function MyFriendItem:AddEvent()
	local function call_back(target,x,y)
		self.model:Brocast(FriendEvent.SelectFriend, self.data.base)
	end
	AddClickEvent(self.selectbtn.gameObject,call_back)
end

--data:p_friend
function MyFriendItem:SetData(data, index)
	self.data = data
	self.index = index
	if self.is_loaded then
		self:UpdateView()
	end
end

function MyFriendItem:UpdateView()
	local role = self.data.base
	self.name.text = role.name
	self.friendlyvalue. text = self.data.intimacy
	self.level.text = GetLevelShow(role.level)
	if self.index % 2 == 0 then
		SetVisible(self.bg, true)
		SetVisible(self.bg2, false)
	else
		SetVisible(self.bg, false)
		SetVisible(self.bg2, true)
	end
end
