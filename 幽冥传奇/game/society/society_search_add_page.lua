--搜索页面
SocietyAskAddPage = SocietyAskAddPage or BaseClass()


function SocietyAskAddPage:__init()
	self.view = nil
end	

function SocietyAskAddPage:__delete()
	self:RemoveEvent()
	if self.search_list_view then
		self.search_list_view:DeleteMe()
		self.search_list_view = nil
	end
	self.view = nil
end	

--初始化页面接口
function SocietyAskAddPage:InitPage(view)
	--绑定要操作的元素
	
	self.view = view
	local ph = view.ph_list.ph_add_list
	self.search_list_view = ListView.New()
	self.search_list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, SearchResultInfoItem, gravity, bounce, view.ph_list.ph_add_list_item)
	view.node_t_list["layout_add_list"].node:addChild(self.search_list_view:GetView(), 99)
	self.search_list_view:SetItemsInterval(2)
	self.search_list_view:SetAutoSupply(true)
	self.search_list_view:SetMargin(2)
	self.search_list_view:SetJumpDirection(ListView.Top)

	view.node_t_list["edit_search_name"].node:setPlaceHolder(Language.Society.EditBoxDefContent)
	view.node_t_list["edit_search_name"].node:setFontSize(22)
	view.node_t_list["edit_search_name"].node:setFontColor(COLOR3B.WHITE)
	self:InitEvent()

	
end	

--初始化事件
function SocietyAskAddPage:InitEvent()
	self.view.node_t_list["btn_search"].node:addClickEventListener(BindTool.Bind(self.OnSearchClicked, self))
end

--移除事件
function SocietyAskAddPage:RemoveEvent()

end

--更新视图界面
function SocietyAskAddPage:UpdateData(data)
	local search_data = SocietyData.Instance:GetSearchResult()
	self.search_list_view:SetDataList(search_data)
end	


function SocietyAskAddPage:OnSearchClicked()
	local name = self.view.node_t_list["edit_search_name"].node:getText()
	if name ~= "" then
		SocietyCtrl.SearchSomeOneByName(name)
	end
end



--右边信息列表Item
SearchResultInfoItem = SearchResultInfoItem or BaseClass(BaseRender)
function SearchResultInfoItem:__init()

end

function SearchResultInfoItem:__delete()

end

function SearchResultInfoItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree["btn_add"].node:addClickEventListener(BindTool.Bind(self.OnAddClicked, self))
	self.node_tree["btn_add"].node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree["lbl_name"].node, BindTool.Bind(self.OnRoleNameClick, self))
end

function SearchResultInfoItem:OnFlush()
	self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if nil == self.data then 
		self.node_tree["lbl_name"].node:setString("")
		self.node_tree["lbl_level"].node:setString("")
		self.node_tree["lbl_profession"].node:setString("")
		self.node_tree["lbl_guild_name"].node:setString("")
		self.node_tree["btn_add"].node:setVisible(false)
		self:SetSelect(false)
		return 
	end
	self.node_tree["btn_add"].node:setVisible(self.data ~= nil)
	self.node_tree["lbl_name"].node:setString(self.data.name)
	self.node_tree["lbl_level"].node:setString(self.data.level)
	self.node_tree["lbl_profession"].node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
	self.node_tree["lbl_guild_name"].node:setString(self.data.guild_name)
end

function SearchResultInfoItem:OnAddClicked()
	if not self.data.role_id then return end
	local role_id = self.data.role_id
	local role_name = self.data.name
	local relate_column = SOCIETY_RELATION_TYPE.FRIEND
	SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.ADD, relate_column, role_id, role_name)
end

function SearchResultInfoItem:OnRoleNameClick()
	if not self.data then return end
	if self.data.role_id and self.data.name then
		self:ChoseCustomMenuBtnsAndOpen()
	end
end

function SearchResultInfoItem:ChoseCustomMenuBtnsAndOpen()
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

function SearchResultInfoItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("SearchResultInfoItem:CreateSelectEffect fail")
	end
	self.view:addChild(self.select_effect, 99)
end

function SearchResultInfoItem:SetSelect(is_select)
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