------------------------------------------------------------
-- 社交列表视图 申请列表
------------------------------------------------------------
local SocietyApplyListView = BaseClass(SubView)


function SocietyApplyListView:__init()
	self.texture_path_list[1] = 'res/xui/society.png'
	self.config_tab = {
		{"society_ui_cfg", 4, {0},},
	}

	self.list_view = nil -- 社交列表视图
end

function SocietyApplyListView:__delete()

end


function SocietyApplyListView:ReleaseCallBack()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end


end

function SocietyApplyListView:LoadCallBack(index, loaded_times)
	self:CreateList()
	self.node_t_list["btn_all_refuse"].node:addClickEventListener(BindTool.Bind(self.OnAllRefuseClicked, self))
	self.node_t_list["btn_all_agree"].node:addClickEventListener(BindTool.Bind(self.OnAllAgreeClicked, self))

	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SHOW_RULES_CHANGE, BindTool.Bind(self.FlushList, self))
	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SOCIETY_LIST_CHANGE, BindTool.Bind(self.FlushList, self))
end

--显示索引回调
function SocietyApplyListView:ShowIndexCallBack(index)
	self:FlushList()
end

function SocietyApplyListView:OnFlush()		
end

----------视图函数----------

function SocietyApplyListView:CreateList()
	if nil ~= self.list_view then return end
	local ph = self.ph_list.ph_info_list
	self.list_view = ListView.New()
	self.list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, self.InfoListItem, gravity, bounce, self.ph_list.ph_apply_list_item)
	self.node_t_list["layout_apply_list"].node:addChild(self.list_view:GetView(), 99)
	self.list_view:SetItemsInterval(2)
	self.list_view:SetAutoSupply(true)
	self.list_view:SetMargin(2)
	self.list_view:SetJumpDirection(ListView.Top)
end

function SocietyApplyListView:FlushList()
	local data_list = SocietyData.Instance:GetApplyListData()				
	self.list_view:SetDataList(data_list)
end


----------end----------

function SocietyApplyListView:OnAllRefuseClicked()
	local data_list = SocietyData.Instance:GetApplyListData()
	if data_list == nil then return end
	for k, v in pairs(data_list) do
		local relate_column = SOCIETY_RELATION_TYPE.FRIEND
		local opposite_id = v.role_id
		SocietyCtrl.Instance:ReplyOppsiteAddAsk(SOCIETY_IS_AGREE_FRIEND.NO, relate_column, opposite_id)
	end
	SocietyData.Instance:EmptyApplyList()
	SocietyCtrl.Instance:CheckFriendApplyTip()
	self:FlushList()
	RemindManager.Instance:DoRemindDelayTime(RemindName.ApplyAddFriends)
end

function SocietyApplyListView:OnAllAgreeClicked()
	local data_list = SocietyData.Instance:GetApplyListData()	
	if data_list == nil then return end			
	for k, v in pairs(data_list) do
		local relate_column = SOCIETY_RELATION_TYPE.FRIEND
		local opposite_id = v.role_id
		SocietyCtrl.Instance:ReplyOppsiteAddAsk(SOCIETY_IS_AGREE_FRIEND.YES, relate_column, opposite_id)
	end
end


----------信息列表----------
-- 信息列表Item（申请列表）
SocietyApplyListView.InfoListItem = BaseClass(BaseRender)
local ApplyListItem = SocietyApplyListView.InfoListItem
function ApplyListItem:__init()

end

function ApplyListItem:__delete()

end

function ApplyListItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree["btn_agree"].node:addClickEventListener(BindTool.Bind(self.OnAgreeClicked, self))
	self.node_tree["btn_agree"].node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree["lbl_name"].node, BindTool.Bind(self.OnRoleNameClick, self))
end

function ApplyListItem:OnFlush()
	-- self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if nil == self.data then 
		self.node_tree["lbl_name"].node:setString("")
		self.node_tree["lbl_level"].node:setString("")
		self.node_tree["lbl_profession"].node:setString("")
		self.node_tree["lbl_guild_name"].node:setString("")
		self.node_tree["btn_agree"].node:setVisible(false)
		self:SetSelect(false)
		return 
	end
	if self.data.guild_name=="" then
		self.node_tree["lbl_guild_name"].node:setString(Language.RankingList.Wu)
	else
		self.node_tree["lbl_guild_name"].node:setString(self.data.guild_name)
	end
	self.node_tree["btn_agree"].node:setVisible(self.data ~= nil)
	self.node_tree["lbl_name"].node:setString(self.data.name)
	self.node_tree["lbl_level"].node:setString(self.data.level)
	self.node_tree["lbl_profession"].node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
end

function ApplyListItem:OnAgreeClicked()
	if nil == self.data then return end
	local relate_column = SOCIETY_RELATION_TYPE.FRIEND
	local opposite_id = self.data.role_id
	SocietyCtrl.Instance:ReplyOppsiteAddAsk(SOCIETY_IS_AGREE_FRIEND.YES, relate_column, opposite_id)
end

function ApplyListItem:OnRoleNameClick()
	if not self.data then return end
	if self.data.role_id and self.data.name then
		self:ChoseCustomMenuBtnsAndOpen()
	end
end

function ApplyListItem:ChoseCustomMenuBtnsAndOpen()
	if nil == self.data then return end
	local menu_list = {}
	table.insert(menu_list, {menu_index = 0})
	table.insert(menu_list, {menu_index = 2})
	table.insert(menu_list, {menu_index = 3})
	table.insert(menu_list, {menu_index = 5})
	table.insert(menu_list, {menu_index = 6})
	if self.data.guild_name == "" then
		table.insert(menu_list, {menu_index = 10})
	end
	local is_exist = false
	for i = SOCIETY_RELATION_TYPE.ENEMY, SOCIETY_RELATION_TYPE.BLACKLIST do
		local relate_list = SocietyData.Instance:GetRelationshipList(i)
		if next(relate_list) then
			for k,v in pairs(relate_list) do
				if self.data.role_id == v.role_id then
					if i ~= SOCIETY_RELATION_TYPE.BLACKLIST then
						table.insert(menu_list, {menu_index = 19})
						table.insert(menu_list, {menu_index = 31})
						table.insert(menu_list, {menu_index = 32})
					else
						table.insert(menu_list, {menu_index = 18})
					end
					is_exist = true
					break
				end
			end
		end
		if true == is_exist then
			break
		end
	end
	if false == is_exist then
		table.insert(menu_list, {menu_index = 19})
	end
	UiInstanceMgr.Instance:OpenCustomMenu(menu_list, self.data) 
end

function ApplyListItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("ApplyListItem:CreateSelectEffect fail")
	end
	self.view:addChild(self.select_effect, 99)
end

function ApplyListItem:SetSelect(is_select)
	if self.is_select == is_select or ((not self:CanSelect()) and is_select == true) then
		return
	end
	self.is_select = is_select
	if self.is_select then
		if nil == self.select_effect then
			self:CreateSelectEffect()
		else
			self.select_effect:setVisible(true)
		end
	else
		if nil ~= self.select_effect then
			self.select_effect:setVisible(false)
		end
	end

	self:OnSelectChange(self.is_select)
end
----------end----------	

return SocietyApplyListView