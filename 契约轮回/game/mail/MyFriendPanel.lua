MyFriendPanel = MyFriendPanel or class("MyFriendPanel",WindowPanel)
local MyFriendPanel = MyFriendPanel
local tableInsert = table.insert

function MyFriendPanel:ctor()
	self.abName = "friendGift"
	self.assetName = "MyFriendPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.model = FriendModel:GetInstance()

	self.item_list = {}
end

function MyFriendPanel:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function MyFriendPanel:Open( )
	MyFriendPanel.super.Open(self)
end

function MyFriendPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content",
	}
	self:GetChildren(self.nodes)

	self:SetTileTextImage("friendGift_image", "myfreinds_title_img")
	self:AddEvent()
	self:SetPanelSize(630, 460)
end

function MyFriendPanel:AddEvent()
	local function call_back()
		self:Close()
	end
	self.event_id = self.model:AddListener(FriendEvent.SelectFriend, call_back)
end

function MyFriendPanel:OpenCallBack()
	self:UpdateView()
end

local function sort_friend(a, b)
	return a.intimacy > b.intimacy
end

function MyFriendPanel:UpdateView( )
	local friends = self.model:GetFriendList()
	local arr_friend = {}
	for _, friend in pairs(friends) do
		if friend.is_online then
			tableInsert(arr_friend, friend)
		end
	end
	table.sort(arr_friend, sort_friend)
	for i=1, #arr_friend do
		local friend = arr_friend[i]
		local item = MyFriendItem(self.Content)
		item:SetData(friend, i)
		tableInsert(self.item_list, item)
	end
end

function MyFriendPanel:CloseCallBack(  )

end
function MyFriendPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
end