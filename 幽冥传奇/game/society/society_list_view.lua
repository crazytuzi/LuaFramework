------------------------------------------------------------
-- 社交列表视图 好友 仇人 黑名单
------------------------------------------------------------
local SocietyListView = BaseClass(SubView)


function SocietyListView:__init()
	self:InitViewData()

	self.texture_path_list[1] = 'res/xui/society.png'
	self.config_tab = {
		{"society_ui_cfg", 3, {0}, false},
	}

	self.list_view = nil -- 社交列表视图
end

function SocietyListView:__delete()

end

-- 初始化视图数据
function SocietyListView:InitViewData()
	local index = self:GetViewDef()
	self.list_index = nil -- 列表类型索引

	if index == ViewDef.Society.Friend then
		self.list_index = SOCIETY_RELATION_TYPE.FRIEND
		self.btn = false

	elseif index == ViewDef.Society.Enemy then
		self.list_index = SOCIETY_RELATION_TYPE.ENEMY
		self.btn = true

	elseif index == ViewDef.Society.BlackList then
		self.list_index = SOCIETY_RELATION_TYPE.BLACKLIST
		self.btn = true

	end
end

function SocietyListView:ReleaseCallBack()

	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end


end

function SocietyListView:LoadCallBack(index, loaded_times)
	self:CreateList()
	if self.btn then
		self.node_t_list["btn_remove_the_col"].node:addClickEventListener(BindTool.Bind(self.OnClickRemoveBtn, self))
	else
		self.node_t_list["btn_remove_the_col"].node:setVisible(false)
	end

	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SHOW_RULES_CHANGE, BindTool.Bind(self.FlushList, self))
	EventProxy.New(SocietyData.Instance, self):AddEventListener(SocietyData.SOCIETY_LIST_CHANGE, BindTool.Bind(self.FlushList, self))
	
end

--显示索引回调
function SocietyListView:ShowIndexCallBack(index)

	self:FlushList()
	self.node_t_list["layout_society_list"].node:setVisible(true)
end

function SocietyListView:OnFlush()

end

----------视图函数----------

function SocietyListView:CreateList()
	if nil ~= self.list_view then return end
	local ph = self.ph_list["ph_info_list"]
	self.list_view = ListView.New()
	self.list_view:Create(ph.x, ph.y, ph.w, ph.h, dir, self.InfoListItem, gravity, bounce, self.ph_list["ph_common_list_item"])
	self.node_t_list["layout_society_list"].node:addChild(self.list_view:GetView(), 99)
	self.list_view:SetItemsInterval(2)
	self.list_view:SetAutoSupply(true)
	self.list_view:SetMargin(2)
	self.list_view:SetJumpDirection(ListView.Top)
end

function SocietyListView:FlushList()
	local data_tbl = SocietyData.Instance:GetRelationshipList(self.list_index)
	if data_tbl == nil then return end
	local list = self:SetShowOnlineOrAll(data_tbl)
	self.list_view:SetDataList(list)
end

----------end----------

-- 根据设置,只显示在线或显示所有
function SocietyListView:SetShowOnlineOrAll(data_tbl)
	local data_list = {}
	local bool = SocietyData.Instance:GetShowRules()
	if bool then
		return data_tbl
	else
		for k,v in pairs(data_tbl) do
			if v.is_online == SOCIETY_ONLINE then
				data_list[#data_list + 1] =  v
			end
		end
		return data_list
	end
end

-- 单击移除按钮回调
function SocietyListView:OnClickRemoveBtn()
	local list = SocietyData.Instance:GetRelationshipList(self.list_index)
	if type(list) == "table" and next(list) then
		for k,v in pairs(list) do
			local name = v.name
			local id = v.role_id
			SocietyCtrl.Instance:AskAddOrDeleteSomeBody(SOCIETY_OPERATE_TYPE.DEL, self.list_index, id, name)
		end
	end
end

----------信息列表----------
-- 信息列表Item（好友、仇人、黑名单）
SocietyListView.InfoListItem = BaseClass(BaseRender)
local InfoListItem = SocietyListView.InfoListItem
function InfoListItem:__init()

end

function InfoListItem:__delete()

end

function InfoListItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree["lbl_name"].node, BindTool.Bind(self.OnClickRoleName, self))
end

function InfoListItem:OnFlush()
	-- self.node_tree["img9_bg"].node:setColor((self.index % 2 == 0) and COLOR3B.GRAY or COLOR3B.WHITE)
	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)
	if nil == self.data then
		self.node_tree["lbl_name"].node:setString("")
		self.node_tree["lbl_level"].node:setString("")
		self.node_tree["lbl_profession"].node:setString("")
		self.node_tree["lbl_guild_name"].node:setString("")
		self:SetSelect(false)
		return 
	end
	local lbl_color = COLOR3B.G_W
	if self.data.is_online == SOCIETY_ONLINE then 
		lbl_color = COLOR3B.WHITE
	end
	self:SetLblColor(lbl_color)
	self:SetLblString()
end

function InfoListItem:SetLblColor(color)
	self.node_tree["lbl_name"].node:setColor(color)
	self.node_tree["lbl_level"].node:setColor(color)
	self.node_tree["lbl_profession"].node:setColor(color)
	self.node_tree["lbl_guild_name"].node:setColor(color)
end

function InfoListItem:SetLblString()
	if self.data.guild_name == "" then
		self.node_tree["lbl_guild_name"].node:setString(Language.RankingList.Wu)
	else
		self.node_tree["lbl_guild_name"].node:setString(self.data.guild_name)
	end
	self.node_tree["lbl_name"].node:setString(self.data.name)
	self.node_tree["lbl_level"].node:setString(self.data.level)
	self.node_tree["lbl_profession"].node:setString(RoleData.Instance:GetProfNameByType(self.data.prof))
end

function InfoListItem:OnClickRoleName()
	if not self.data then return end
	if self.data.role_id and self.data.name then
		if self.data.type and self.data.type >= 0 then
			self:ChoseCustomMenuBtnsAndOpen()
		end
	end
end

function InfoListItem:ChoseCustomMenuBtnsAndOpen()
	local menu_list = {
		{menu_index = 0},
		{menu_index = 2},
		{menu_index = 3},
		{menu_index = 5},
		{menu_index = 6},
	}
	if self.data.guild_name == "" then
		table.insert(menu_list, {menu_index = 10})
	end
	local is_exist = nil
	if self.data.type == SOCIETY_RELATION_TYPE.FRIEND then
		table.insert(menu_list, {menu_index = 17})
		table.insert(menu_list, {menu_index = 19})
	elseif self.data.type == SOCIETY_RELATION_TYPE.ENEMY then
		table.insert(menu_list, {menu_index = 32})
		table.insert(menu_list, {menu_index = 31})
		local relate_list = SocietyData.Instance:GetRelationshipList(SOCIETY_RELATION_TYPE.BLACKLIST)
		if next(relate_list) then
			for k,v in pairs(relate_list) do
				if self.data.role_id == v.role_id then
					is_exist = 1
				end
			end
		end
		if not is_exist then
			table.insert(menu_list, {menu_index = 19})
		end
	elseif self.data.type == SOCIETY_RELATION_TYPE.BLACKLIST then
		table.insert(menu_list, {menu_index = 18})
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

return SocietyListView