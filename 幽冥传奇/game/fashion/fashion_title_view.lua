------------------------------------------------------------
-- "称号-全部" "称号-拥有" "称号-定制"  配置 TitleUpgradeConfig
------------------------------------------------------------

local FashionTitleView = BaseClass(SubView)

function FashionTitleView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self.config_tab = {
		{"fashion_ui_cfg", 5, {0}},
	}

end

function FashionTitleView:__delete()
end

function FashionTitleView:ReleaseCallBack()

end

function FashionTitleView:LoadCallBack(index, loaded_times)
	self:CreateTitleList()
	self:CreateAttrList()

	-- 获取途径文本 上下居中
	local rich = self.node_t_list["rich_1"].node
	rich:setVerticalAlignment(RichVAlignment.VA_CENTER)
	rich:setHorizontalAlignment(RichHAlignment.HA_CENTER)

	--按钮监听
	-- XUI.AddClickEventListener(self.node_t_list.btn_re.node, BindTool.Bind(self.MyShopRefreshCallBack, self), true)

	-- 数据监听
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE, BindTool.Bind(self.OnRoleAttrChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	if self.view_def == ViewDef.Fashion.Title.TitlePossession or self.view_def == ViewDef.Fashion.Title.TitleCustom then
		EventProxy.New(TitleData.Instance, self):AddEventListener(TitleData.TITLE_LEVEL_DATA_CHANGE, BindTool.Bind(self.OnTitleLevelDataChange, self))
	end
end

--显示索引回调
function FashionTitleView:ShowIndexCallBack(index)
	self:FlushTitleList()
	self.title_list:JumpToTop()
	self.title_list:SelectItemByIndex(1)
end

function FashionTitleView:OnFlush(index)
	self:FlushAttrList()

	-- 获取途径
	local text = TitleData.GetCond(self.select_data.titleId) or ""
	local rich = self.node_t_list["rich_1"].node
	RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.GREEN)
end

----------视图函数----------

function FashionTitleView:CreateTitleList()
	local ph = self.ph_list["ph_title_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_title_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_title"].node
	local item_render = {New = BindTool.Bind(self.TitleItem.New, self.view_def)}
	local line_dis = ph_item.h
	local direction = ScrollDir.Vertical -- 滑动方向-竖向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnTitle, self))
	self.title_list = grid_scroll
	self:AddObj("title_list")
end

function FashionTitleView:CreateAttrList()
	local ph = self.ph_list["ph_attr_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_attr_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_title"].node
	local item_render = self.AttrTextRender
	local line_dis = ph_item.w
	local direction = ScrollDir.Vertical -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local list = ListView.New() 
	list:Create(ph.x, ph.y, ph.w, ph.h, direction, item_render, nil, nil, ph_item)
	list:SetItemsInterval(2)
	list:SetMargin(2)
	parent:addChild(list:GetView(), 50)
	self.attr_list = list
	self:AddObj("attr_list")
end

function FashionTitleView:FlushAttrList()
	local attr_list = {}
	if self.view_def == ViewDef.Fashion.Title.TitlePreview -- 装扮-称号-全部
	or self.view_def == ViewDef.Fashion.Title.TitleCustom then -- 装扮-称号-定制
		attr_list = TitleData.Instance.GetTitleAttrCfg(self.select_data.titleId)
	elseif self.view_def == ViewDef.Fashion.Title.TitlePossession then -- 装扮-称号-拥有
		local data_list = self.title_list:GetDataList()
		for i, data in ipairs(data_list) do
			local cur_attr_list = TitleData.Instance.GetTitleAttrCfg(data.titleId)
			attr_list = CommonDataManager.AddAttr(attr_list, cur_attr_list)
		end
	end
	table.sort(attr_list, function(a, b)
		return a.type < b.type
	end)

	attr_list = RoleData.FormatRoleAttrStr(attr_list)
	if self.view_def == ViewDef.Fashion.Title.TitlePossession then -- 装扮-称号-拥有
		local select_attr_list = TitleData.Instance.GetTitleAttrCfg(self.select_data.titleId)
		select_attr_list = RoleData.FormatRoleAttrStr(select_attr_list)
		local list = {}
		for i, v in ipairs(select_attr_list) do
			list[v.type] = v.value_str
		end
		for i, v in ipairs(attr_list) do
			v.add_value_str = list[v.type]
		end
	end

	self.attr_list:SetDataList(attr_list)
end

function FashionTitleView:FlushTitleList()
	local list = {}
	local data_list = TitleData.Instance:GetAllTitlelist()
	if self.view_def == ViewDef.Fashion.Title.TitlePreview then -- 装扮-称号-全部
		for key, data in ipairs(data_list) do
			table.insert(list, data)
		end
	elseif self.view_def == ViewDef.Fashion.Title.TitleCustom then -- 装扮-称号-定制
		list = TitleData.Instance:GetCustomTitleList()
	elseif self.view_def == ViewDef.Fashion.Title.TitlePossession then -- 装扮-称号-拥有
		for index, data in ipairs(data_list) do
			if TitleData.Instance:GetTitleActive(data.titleId) == 1 then
				table.insert(list, data)
			end
		end
	end

	self.title_list:SetDataList(list)
end

----------end----------

--------------------

function FashionTitleView:OnTitle(item)
	self.select_data = item:GetData()
	self:Flush()
end

function FashionTitleView:OnRoleAttrChange()
	if self:IsOpen() then
		self:FlushTitleList()
	end
end

function FashionTitleView:OnTitleLevelDataChange()
	if self:IsOpen() then
		self:FlushTitleList()
	end
end

function FashionTitleView:OnBagItemChange(event)
	if ViewManager.Instance:IsOpen(self.view_def) then
		local need_flush = false
		for i, v in ipairs(event.GetChangeDataList()) do
			if v.change_type == ITEM_CHANGE_TYPE.LIST then
				need_flush = true
			else
				local item_data = v.data or {}
				if item_data.type == ItemData.ItemType.itFunctionItem then
					need_flush = true
				end
			end

			if need_flush then
				self:FlushTitleList()
				self:Flush()
				break
			end
		end
	end
end


----------------------------------------
-- "称号"项目渲染
----------------------------------------
FashionTitleView.TitleItem = BaseClass(BaseRender)
local TitleItem = FashionTitleView.TitleItem
function TitleItem:__init(view_def)
	self.view_def = view_def
end

function TitleItem:__delete()
	if self.title then
		self.title:DeleteMe()
		self.title = nil
	end
end

function TitleItem:CreateChild()
	BaseRender.CreateChild(self)
	if nil == self.title then
		local size = self.view:getContentSize()
		local title = Title.New()
		title:GetView():setPosition(185 or size.width / 2, size.height / 2)
		self.view:addChild(title:GetView(), 100)
		title:SetScale(0.7)
		self.title = title
	end
	
	if self.view_def == ViewDef.Fashion.Title.TitlePossession or self.view_def == ViewDef.Fashion.Title.TitleCustom then
		XUI.AddClickEventListener(self.node_tree["btn_wear"].node, BindTool.Bind(self.OnClickTitleBtn, self))
	else
		self.node_tree["btn_wear"].node:setVisible(false)
	end

	local rich = self.node_tree["rich_1"].node
	rich:setVerticalAlignment(RichVAlignment.VA_CENTER)
	rich:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function TitleItem:OnFlush()
	if self.data == nil then return end
	local title_id = self.data.titleId or 0
	self.title:SetTitleId(title_id)

	if self.view_def == ViewDef.Fashion.Title.TitlePossession or self.view_def == ViewDef.Fashion.Title.TitleCustom then
		local title_upgrade_cfg = TitleData.Instance:GetTitleUpgradeCfg(title_id)
		local text, can_upgrade = "", nil
		if title_upgrade_cfg then
			local title_level = TitleData.Instance:GetTitleLevelData(title_id)
			if title_level >= 2 then
				for num in string.gmatch(title_level, "%d") do
					text = text .. string.format("{image;res/xui/common/num_15_%s.png;}", num)
				end
				text = text .. "{image;res/xui/fashion/fashion_15.png;}" -- 美术字-"级"
			end

			local levels_cfg = title_upgrade_cfg.levels or {}
			if title_level >= #levels_cfg then
				text = text .. "\n{color;ff2828;(满级)}"
			else
				local next_upgrade_cfg = levels_cfg[title_level + 1] or {}
				local consumes = next_upgrade_cfg.consumes
				can_upgrade = BagData.CheckConsumesCount(consumes)
			end
		end
		local rich = self.node_tree["rich_1"].node
		RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)

		local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
		local title_1 = bit:_and(head_title, 0x000000ff)
		local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
		local item = BagData.Instance:GetItem(TITLE_CLIENT_CONFIG[self.data.titleId].item_id)
		local title_text = ""
		if self.data.titleId == title_1 or self.data.titleId == title_2 then
			title_text = "脱  下"
		elseif (TitleData.Instance:GetTitleActive(self.data.titleId) == 1) then
			title_text = "佩  戴"
		end

		self.can_upgrade = title_text ~= "" and can_upgrade
		title_text = self.can_upgrade and "升  级" or title_text

		self.node_tree["btn_wear"].node:setTitleText(title_text)
		self.node_tree["btn_wear"].node:setVisible(title_text ~= "")

		if self.can_upgrade and nil == self.node_tree["btn_wear"].node.UpdateReimd then
			XUI.AddRemingTip(self.node_tree["btn_wear"].node)
		end

		if self.node_tree["btn_wear"].node.UpdateReimd then
			self.node_tree["btn_wear"].node:UpdateReimd(self.can_upgrade)
		end
	end

end

function TitleItem:OnClickTitleBtn()
	-- 持宝人称号不能取消佩戴
	if StdActivityCfg[DAILY_ACTIVITY_TYPE.DUO_BAO_QI_BING].titleId == self.data.titleId then return end
	-- if TitleData.Instance:GetTitleActive(self.data.titleId) == 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Role.NoActTitle)
	-- 	return
	-- end

	-- 使用物品激活 已废弃
	-- local item = BagData.Instance:GetItem(TITLE_CLIENT_CONFIG[self.data.titleId].item_id)
	-- if TitleData.Instance:GetTitleActive(self.data.titleId) == 0 and nil ~= item then
	-- 	BagCtrl.Instance:SendUseItem(item.series, 0, 1)

	if self.can_upgrade then
		local title_id = self.data and self.data.titleId
		TitleCtrl.SendUpgradeTitleReq(title_id)
	else
		local head_title = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE)
		local title_1 = bit:_and(head_title, 0x000000ff)
		local title_2 = bit:_rshift(bit:_and(head_title, 0x0000ff00), 8)
		if self.data.titleId == title_1 or self.data.titleId == title_2 then
			if title_1 == self.data.titleId then
				title_1 = 0
			elseif title_2 == self.data.titleId then
				title_2 = 0
			else
				return
			end
		else
			if title_1 == 0 then
				title_1 = self.data.titleId
			else
				title_2 = self.data.titleId
			end
		end
		TitleCtrl.SendTitleReq(title_1, title_2)
	end
end

----------------------------------------
-- 属性文本
----------------------------------------

FashionTitleView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = FashionTitleView.AttrTextRender
function AttrTextRender:__init()
	
end

function AttrTextRender:__delete()

end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrTextRender:OnFlush()
	if nil == self.data then 
		self.node_tree["lbl_attr_name"].node:setString("")
		local rich = self.node_tree["rich_attr_txt"].node
		RichTextUtil.ParseRichText(rich, "", 20, Str2C3b("bfc0c0"))
		return 
	end
	self.node_tree["lbl_attr_name"].node:setString(self.data.type_str .. "：")

	local text = ""
	if self.data.add_value_str then
		text = string.format("%s {color;%s;↑%s}", self.data.value_str, COLORSTR.GREEN, self.data.add_value_str or "")
	else
		text = self.data.value_str
	end
	local rich = self.node_tree["rich_attr_txt"].node
	RichTextUtil.ParseRichText(rich, text, 20, Str2C3b("bfc0c0"))
end

function AttrTextRender:CreateSelectEffect()
end


return FashionTitleView