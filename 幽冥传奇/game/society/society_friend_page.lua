--好友页面
SocietyFriendPage = SocietyFriendPage or BaseClass()


function SocietyFriendPage:__init()
	self.view = nil
end	

function SocietyFriendPage:__delete()
	self:RemoveEvent()
	if self.friend_list_view then
		self.friend_list_view:DeleteMe()
		self.friend_list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function SocietyFriendPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	local ph = view.ph_list.ph_friend_list
	self.friend_list_view = ListView.New()
	self.friend_list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, InfoListItem, gravity, bounce, view.ph_list.ph_friend_list_item)
	view.node_t_list["layout_friend"].node:addChild(self.friend_list_view:GetView(), 99)
	self.friend_list_view:SetItemsInterval(2)
	self.friend_list_view:SetAutoSupply(true)
	self.friend_list_view:SetMargin(2)
	self.friend_list_view:SetJumpDirection(ListView.Top)
	self:InitEvent()
end	

--初始化事件
function SocietyFriendPage:InitEvent()
	

end

--移除事件
function SocietyFriendPage:RemoveEvent()

end

--更新视图界面
function SocietyFriendPage:UpdateData(data)
	local data_tbl = SocietyData.Instance:GetRelationshipList(SOCIETY_RELATION_TYPE.FRIEND)
	if data_tbl == nil then return end
	local friend_list = self.view:SetShowOnlineOrAll(data_tbl)	
	self.friend_list_view:SetDataList(friend_list)
end	



