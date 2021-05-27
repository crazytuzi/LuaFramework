--好友申请页面
SocietyApplyPage = SocietyApplyPage or BaseClass()


function SocietyApplyPage:__init()
	self.view = nil
end	

function SocietyApplyPage:__delete()
	self:RemoveEvent()
	if self.apply_list_view then
		self.apply_list_view:DeleteMe()
		self.apply_list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function SocietyApplyPage:InitPage(view)
	--绑定要操作的元素
	
	self.view = view
	local ph = view.ph_list.ph_apply_list
	self.apply_list_view = ListView.New()
	self.apply_list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, ApplyListItem, gravity, bounce, view.ph_list.ph_apply_list_item)
	view.node_t_list["layout_apply_list"].node:addChild(self.apply_list_view:GetView(), 99)
	self.apply_list_view:SetItemsInterval(2)
	self.apply_list_view:SetAutoSupply(true)
	self.apply_list_view:SetMargin(2)
	self.apply_list_view:SetJumpDirection(ListView.Top)
	self:InitEvent()
	
end	

--初始化事件
function SocietyApplyPage:InitEvent()
	
	self.view.node_t_list["btn_all_refuse"].node:addClickEventListener(BindTool.Bind(self.OnAllRefuseClicked, self))
	self.view.node_t_list["btn_all_agree"].node:addClickEventListener(BindTool.Bind(self.OnAllAgreeClicked, self))
end

--移除事件
function SocietyApplyPage:RemoveEvent()

end

--更新视图界面
function SocietyApplyPage:UpdateData(data)
	local data_list = SocietyData.Instance:GetApplyListData()				
	self.apply_list_view:SetDataList(data_list)
end	



function SocietyApplyPage:OnAllRefuseClicked()
	local data_list = SocietyData.Instance:GetApplyListData()
	if data_list == nil then return end
	for k, v in pairs(data_list) do
		local relate_column = SOCIETY_RELATION_TYPE.FRIEND
		local opposite_id = v.role_id
		SocietyCtrl.Instance:ReplyOppsiteAddAsk(SOCIETY_IS_AGREE_FRIEND.NO, relate_column, opposite_id)
	end
	SocietyData.Instance:EmptyApplyList()
	self.view:Flush({TabIndex.society_apply_list,})
	SocietyCtrl.Instance:CheckFriendApplyTip()
end

function SocietyApplyPage:OnAllAgreeClicked()
	local data_list = SocietyData.Instance:GetApplyListData()	
	if data_list == nil then return end			
	for k, v in pairs(data_list) do
		local relate_column = SOCIETY_RELATION_TYPE.FRIEND
		local opposite_id = v.role_id
		SocietyCtrl.Instance:ReplyOppsiteAddAsk(SOCIETY_IS_AGREE_FRIEND.YES, relate_column, opposite_id)
	end
end


--右边信息列表Item
ApplyListItem = ApplyListItem or BaseClass(BaseRender)
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
	self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if nil == self.data then 
		self.node_tree["lbl_name"].node:setString("")
		self.node_tree["lbl_level"].node:setString("")
		self.node_tree["lbl_profession"].node:setString("")
		self.node_tree["lbl_guild_name"].node:setString("")
		self.node_tree["btn_agree"].node:setVisible(false)
		self:SetSelect(false)
		return 
	end
	self.node_tree["btn_agree"].node:setVisible(self.data ~= nil)
	self.node_tree["lbl_name"].node:setString(self.data.name)
	self.node_tree["lbl_level"].node:setString(self.data.level)
	self.node_tree["lbl_profession"].node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
	self.node_tree["lbl_guild_name"].node:setString(self.data.guild_name)
end

function ApplyListItem:OnAgreeClicked()
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
						-- table.insert(menu_list, {menu_index = 31})
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
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width+10, size.height+10, ResPath.GetCommon("img9_173"), true)
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