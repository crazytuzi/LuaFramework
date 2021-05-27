------------------------------------------------------------
-- 社交列表视图 搜索添加
------------------------------------------------------------
local SocietySearchAddView = BaseClass(SubView)


function SocietySearchAddView:__init()
	self.texture_path_list[1] = 'res/xui/society.png'
	self.config_tab = {
		{"society_ui_cfg", 5, {0},},
	}

	self.list_view = nil -- 社交列表视图
end

function SocietySearchAddView:__delete()

end


function SocietySearchAddView:ReleaseCallBack()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end


end

function SocietySearchAddView:LoadCallBack(index, loaded_times)
	self:CreateList()
	self.node_t_list["btn_search"].node:addClickEventListener(BindTool.Bind(self.OnSearchClicked, self))
	self.node_t_list["edit_search_name"].node:setPlaceHolder(Language.Society.EditBoxDefContent)
	self.node_t_list["edit_search_name"].node:setFontSize(22)
	self.node_t_list["edit_search_name"].node:setFontColor(COLOR3B.WHITE)

	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SHOW_RULES_CHANGE, BindTool.Bind(self.FlushList, self))
	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SOCIETY_LIST_CHANGE, BindTool.Bind(self.FlushList, self))
	
end

--显示索引回调
function SocietySearchAddView:ShowIndexCallBack(index)
	self:FlushList()
end

function SocietySearchAddView:OnFlush()


end

----------视图函数----------

function SocietySearchAddView:CreateList()
	if self.list_view then return end
	local ph = self.ph_list.ph_info_list
	self.list_view = ListView.New()
	self.list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, self.InfoListItem, gravity, bounce, self.ph_list.ph_add_list_item)
	self.node_t_list["layout_add_list"].node:addChild(self.list_view:GetView(), 99)
	self.list_view:SetItemsInterval(2)
	self.list_view:SetAutoSupply(true)
	self.list_view:SetMargin(2)
	self.list_view:SetJumpDirection(ListView.Top)
end

function SocietySearchAddView:FlushList()
	local data_list = SocietyData.Instance:GetSearchResult()
	self.list_view:SetDataList(data_list)
end

----------end----------

function SocietySearchAddView:OnSearchClicked()
	local name = self.node_t_list["edit_search_name"].node:getText()
	if name ~= "" then
		SocietyCtrl.SearchSomeOneByName(name)
	end
end

----------信息列表----------
-- 信息列表Item（搜索添加）
SocietySearchAddView.InfoListItem= BaseClass(BaseRender)
local InfoListItem = SocietySearchAddView.InfoListItem
function InfoListItem:__init()

end

function InfoListItem:__delete()

end

function InfoListItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree["btn_add"].node:addClickEventListener(BindTool.Bind(self.OnAddClicked, self))
	self.node_tree["btn_add"].node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree["lbl_name"].node, BindTool.Bind(self.OnRoleNameClick, self))
end

function InfoListItem:OnFlush()
	-- self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if nil == self.data then 
		self.node_tree["lbl_name"].node:setString("")
		self.node_tree["lbl_level"].node:setString("")
		self.node_tree["lbl_profession"].node:setString("")
		self.node_tree["lbl_guild_name"].node:setString("")
		self.node_tree["btn_add"].node:setVisible(false)
		self:SetSelect(false)
		return 
	end
	if self.data.guild_name=="" then
		self.node_tree["lbl_guild_name"].node:setString(Language.RankingList.Wu)
	else
		self.node_tree["lbl_guild_name"].node:setString(self.data.guild_name)
	end
	self.node_tree["btn_add"].node:setVisible(self.data ~= nil)
	self.node_tree["lbl_name"].node:setString(self.data.name)
	self.node_tree["lbl_level"].node:setString(self.data.level)
	self.node_tree["lbl_profession"].node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
end

function InfoListItem:OnAddClicked()
	if not self.data then return end
	local role_id = self.data.role_id
	local role_name = self.data.name
	local relate_column = SOCIETY_RELATION_TYPE.FRIEND
	SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.ADD, relate_column, role_id, role_name)
end

function InfoListItem:OnRoleNameClick()
	if not self.data then return end
	if self.data.role_id and self.data.name then
		self:ChoseCustomMenuBtnsAndOpen()
	end
end

function InfoListItem:ChoseCustomMenuBtnsAndOpen()
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
	for i = SOCIETY_RELATION_TYPE.FRIEND, SOCIETY_RELATION_TYPE.BLACKLIST do
		local _type = i
		local relate_list = SocietyData.Instance:GetRelationshipList(_type)
		if next(relate_list) then
			for k,v in pairs(relate_list) do
				if self.data.role_id == v.role_id then
					if i ~= SOCIETY_RELATION_TYPE.BLACKLIST then
						table.insert(menu_list, {menu_index = 19})
						if i == SOCIETY_RELATION_TYPE.FRIEND then
							table.insert(menu_list, {menu_index = 17})
						elseif i == SOCIETY_RELATION_TYPE.ENEMY then
							table.insert(menu_list, {menu_index = 31})
							table.insert(menu_list, {menu_index = 32})
						end
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

function InfoListItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("InfoListItem:CreateSelectEffect fail")
	end
	self.view:addChild(self.select_effect, 99)
end

function InfoListItem:SetSelect(is_select)
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

return SocietySearchAddView