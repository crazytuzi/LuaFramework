--黑名单页面
SocietyBlackPage = SocietyBlackPage or BaseClass()


function SocietyBlackPage:__init()
	self.view = nil
end	

function SocietyBlackPage:__delete()
	self:RemoveEvent()
	if self.blacklist_list_view then
		self.blacklist_list_view:DeleteMe()
		self.blacklist_list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function SocietyBlackPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	local ph = view.ph_list.ph_black_list
	self.blacklist_list_view = ListView.New()
	self.blacklist_list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, InfoListItem, gravity, bounce, view.ph_list.ph_black_list_item)
	view.node_t_list["layout_blacklist"].node:addChild(self.blacklist_list_view:GetView(), 99)
	self.blacklist_list_view:SetItemsInterval(2)
	self.blacklist_list_view:SetAutoSupply(true)
	self.blacklist_list_view:SetMargin(2)
	self.blacklist_list_view:SetJumpDirection(ListView.Top)
	self:InitEvent()

	
end	

--初始化事件
function SocietyBlackPage:InitEvent()
	
	self.view.node_t_list["btn_blacklist_remove"].node:addClickEventListener(BindTool.Bind(self.OnBlacklistRemvClicked, self))
end

--移除事件
function SocietyBlackPage:RemoveEvent()

end

--更新视图界面
function SocietyBlackPage:UpdateData(data)
	local data_tbl = SocietyData.Instance:GetRelationshipList(SOCIETY_RELATION_TYPE.BLACKLIST)
	if data_tbl == nil then return end
	local black_list = self.view:SetShowOnlineOrAll(data_tbl)
	self.blacklist_list_view:SetDataList(black_list)
end	

function SocietyBlackPage:OnBlacklistRemvClicked()
	if self.blacklist_list_view:GetSelectItem() then
		local select_item_data = self.blacklist_list_view:GetSelectItem():GetData()
		if select_item_data then
			local name = select_item_data.name
			local id = select_item_data.role_id
			SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.DEL, SOCIETY_RELATION_TYPE.BLACKLIST, id, name)
		end
	end
end