------------------------------------------------------------
-- 物品合成
------------------------------------------------------------
ItemSynthesisView = ItemSynthesisView or BaseClass(BaseView)

function ItemSynthesisView:__init()
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"item_synthesis_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
	}
	self.synthesis_type = ITEM_SYNTHESIS_TYPES.FUWEN
	self.select_list_index = 1

	self.synthesis_view_cfg = ConfigManager.Instance:GetClientConfig("item_synthesis_view_cfg")
end

function ItemSynthesisView:__delete()
end

function ItemSynthesisView:ReleaseCallBack()
	if self.list then
		self.list:DeleteMe()
		self.list = nil
	end

	if self.type_list then
		self.type_list:DeleteMe()
		self.type_list = nil
	end

	self.bottom_items = {}
end

function ItemSynthesisView:LoadCallBack(index, loaded_times)
	self:CreateTypeList()
	self:CreateList()
	self:CreateBottomBagItemShow()

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function ItemSynthesisView:OpenCallBack()
	self.select_list_index = 1
end

function ItemSynthesisView:ShowIndexCallBack(index)
	self:CreateTopTitle(ResPath.GetWord(string.format("word_synthesis_%d", self.synthesis_type)), 275, 695)

	self:Flush()
end

function ItemSynthesisView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushList()
			for k, v in pairs(self.bottom_items) do
				v:FlushNum()
			end
			self.type_list:SetDataList(self:GetTypeDataList())
		elseif k == "group_list" then
			self:FlushTypeList()
		end
	end
end
-------------------------------------------------------------------------
function ItemSynthesisView:SetSynthesisType(type)
	self.synthesis_type = type
end

function ItemSynthesisView:OnGameCondChange(cond_def)
	self:Flush(0, "group_list")
end

function ItemSynthesisView:OnBagItemChange()
	self:Flush()
end

function ItemSynthesisView:CreateBottomBagItemShow()
	local bottom_show_cfg = self.synthesis_view_cfg[self.synthesis_type].bottom_show
	self.bottom_items = {}
	local count = 0
	for k, v in pairs(bottom_show_cfg) do
		if v.item_id then
			count = count + 1
			local item = XUI.CreateLayout(85 + (count - 1) * 230, 38, 0, 0)
			self.node_t_list.layout_synthesis.node:addChild(item, 99)

			local bg = XUI.CreateImageViewScale9(4, 0, 150, 26, ResPath.GetCommon("img9_200"), true, cc.rect(5, 5, 10, 5))
			bg:setAnchorPoint(0, 0.5)
			local num_txt = XUI.CreateText(4 + 10, 0, 200, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.OLIVE)
			num_txt:setAnchorPoint(0, 0.5)
			local rich = XUI.CreateRichText(0, 0, 100, 30, true)
			rich:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
			rich:setAnchorPoint(1, 0.5)
			RichTextUtil.ParseRichText(rich, string.format("{image;%s;30,30;0.35}", ResPath.GetItem(v.item_id)))
			item:addChild(bg, 1)
			item:addChild(rich, 1)
			item:addChild(num_txt, 1)
			item.FlushNum = function()
				local num = BagData.Instance:GetItemNumInBagById(v.item_id)
				num_txt:setString(num)
			end
			item:FlushNum()

			table.insert(self.bottom_items, item)
		end
	end
end

function ItemSynthesisView:FlushList()
	local group_cfg = self.synthesis_view_cfg[self.synthesis_type].group_list
	local type_cfg = group_cfg and group_cfg[self.select_list_index]
	local items_cfg = ItemSynthesisConfig[self.synthesis_type]
	if nil == type_cfg or nil == items_cfg then
		return
	end

	local list = {}
	for k, v in pairs(type_cfg.list) do
		table.insert(list, {item_index = v, synthesis_type = self.synthesis_type})
	end
	self.list:SetDataList(list)
	self.type_list:ChangeToIndex(self.select_list_index)
end

function ItemSynthesisView:CreateList()
	self.list = ListView.New()
	local ph_list = self.ph_list.ph_list
	self.list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, nil, ItemSynthesisView.SynthesisItem, nil, nil, self.ph_list.ph_item)
	self.node_t_list.layout_synthesis.node:addChild(self.list:GetView(), 100, 100)
	self.list:GetView():setAnchorPoint(0.5, 0.5)
	self.list:SetItemsInterval(8)
	-- self.list:JumpToTop(true)
	self.list:SetJumpDirection(ListView.Top)

	self:FlushList()
end

function ItemSynthesisView:FlushTypeList()
	self.type_list:SetDataList(self:GetTypeDataList())
end

function ItemSynthesisView:GetTypeDataList()
	local group_list = {}
	for k, v in pairs(self.synthesis_view_cfg[self.synthesis_type].group_list) do
		if v.cond == nil or GameCondMgr.Instance:GetValue(v.cond) then
			table.insert(group_list, v)
		end
	end
	return group_list
end

function ItemSynthesisView:CreateTypeList()
	self.type_list = ListView.New()
	local ph_list = self.ph_list.ph_type_list
	self.type_list:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, nil, ItemSynthesisView.TypeItem)
	self.node_t_list.layout_synthesis.node:addChild(self.type_list:GetView(), 100, 100)
	self.type_list:GetView():setAnchorPoint(0.5, 0.5)
	self.type_list:SetItemsInterval(15)
	self.type_list:JumpToTop(true)
	self.type_list:SetSelectCallBack(BindTool.Bind(self.OnSelectSynthesisType, self))

	self:FlushTypeList()
end

function ItemSynthesisView:OnSelectSynthesisType(item, list_index)
	if self.select_list_index ~= list_index then
		self.select_list_index = list_index
		self:FlushList()
	end
end

---------------------------------------------
ItemSynthesisView.SynthesisItem = BaseClass(BaseRender)
local SynthesisItem = ItemSynthesisView.SynthesisItem
function SynthesisItem:__init()
	self.is_bullet_window = false
end

function SynthesisItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.is_bullet_window = nil
end

function SynthesisItem:CreateChildCallBack()
	self.cell = BaseCell.New()
	self.cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(true)
	self.view:addChild(self.cell:GetView(), 10)

	self.txt_level = XUI.CreateText(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y - 45, 100, 16, nil, "", nil, 16, COLOR3B.WHITE, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
	self.view:addChild(self.txt_level, 10)

	self.node_tree.btn_1.node:setTitleText("兑换")
	self.node_tree.btn_1.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_tree.btn_1.node:setTitleFontSize(22)
	self.node_tree.btn_1.node:setTitleColor(COLOR3B.G_W2)

	XUI.AddClickEventListener(self.node_tree.btn_1.node, BindTool.Bind(self.OnClickBtn, self))
end

function SynthesisItem:OnClickBtn()
	if self.data == nil then return end
	if self.is_bullet_window then
		TipCtrl.Instance:OpenGetStuffTip(CLIENT_GAME_GLOBAL_CFG.fuwen_equip_id)
	else
		BagCtrl.SendComposeItem(self.data.synthesis_type, self.data.item_index, 0)
	end
end

function SynthesisItem:OnFlush()
	if self.data == nil then return end
	local items_cfg = ItemSynthesisConfig[self.data.synthesis_type]
	local synthesis_cfg = items_cfg.itemList[self.data.item_index]
	if nil == synthesis_cfg then
		return
	end

	local one_item_data = ItemData.FormatItemData(synthesis_cfg.award[1])
	self.cell:SetData(one_item_data)
	RichTextUtil.ParseRichText(self.node_tree.rich_name.node, ItemData.Instance:GetItemNameRich(one_item_data.item_id))

	local ji, zhuan = ItemData.GetItemLevel(one_item_data.item_id)
	local text = ""
	if zhuan > 0 then
		text = zhuan .. Language.Common.Zhuan
	else
		text = ji .. Language.Common.Ji
	end
	self.txt_level:setString(text)

	local one_consume_data = ItemData.FormatItemData(synthesis_cfg.consume[1])
	local need_icon_id = one_consume_data.item_id
	local bag_num = BagData.Instance:GetItemNumInBagById(one_consume_data.item_id)
	local is_enough = bag_num >= one_consume_data.num
	local color = is_enough and COLORSTR.GREEN or COLORSTR.RED
	local desc = string.format("消耗:%s{color;%s;%d}/%d", string.format("{image;%s;30,20;0.3}", ResPath.GetItem(need_icon_id)), color, bag_num, one_consume_data.num)
	RichTextUtil.ParseRichText(self.node_tree.rich_desc.node, desc, 18, COLOR3B.OLIVE)

	local bool = false
	if FuwenData.Instance:GetIsBetterFuwen(one_item_data) and is_enough then
		local _, fuwen_index = ItemData.GetItemFuwenIndex(one_item_data.item_id)
		local item_bag = FuwenData.Instance:GetMaxFuwenByInBag(fuwen_index)
		bool = nil == item_bag
	end
	self:SetRemind(self.node_tree.btn_1.node, bool)
	self.is_bullet_window = not is_enough
end

-- 设置提醒
function SynthesisItem:SetRemind(node, vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite then
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind_bg_sprite, 1, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

function SynthesisItem:CreateSelectEffect()
end

---------------------------------------------
ItemSynthesisView.TypeItem = BaseClass(BaseRender)
local TypeItem = ItemSynthesisView.TypeItem
function TypeItem:__init()
	self.tabbar_btn = TabbarBtn.New(ResPath.GetCommon("btn_144_normal"), ResPath.GetCommon("btn_144_select"), false)
	self.tabbar_btn:setTitleFontSize(20)
	self.tabbar_btn:setTitleFontName(COMMON_CONSTS.FONT)
	self.view:addChild(self.tabbar_btn:GetView(), 10)

	self.tabbar_btn.view:setTouchEnabled(false)

	self.view:setContentSize(self.tabbar_btn:getContentSize())
end

function TypeItem:__delete()
	self.tabbar_btn:DeleteMe()
	self.tabbar_btn = nil
end

function TypeItem:CreateChildCallBack()
	self.tabbar_btn.img_select:addChild(XUI.CreateImageView(10, 27.5, ResPath.GetCommon("arrow_100")), 1)
end

function TypeItem:OnFlush()
	self.tabbar_btn:setTitleText(self.data.name)

	local items_cfg = ItemSynthesisConfig[3]
	local synthesis_cfg = items_cfg.itemList[(self.index * 8)]
	local one_consume_data = ItemData.FormatItemData(synthesis_cfg.consume[1])
	local bag_num = BagData.Instance:GetItemNumInBagById(one_consume_data.item_id)

	local one_item_data = ItemData.FormatItemData(synthesis_cfg.award[1])

	-- 碎片数量满足时,判断身上是否有比当前套装低级
	local boor = false
	if bag_num >= one_consume_data.num then
		for i = 1, 8 do
			synthesis_cfg = items_cfg.itemList[(i + (self.index - 1) * 8)]
			one_item_data = ItemData.FormatItemData(synthesis_cfg.award[1])
			boor = FuwenData.Instance:GetIsBetterFuwen(one_item_data)
			if boor then
				break
			end
		end
	end
	self:SetRemind(self.tabbar_btn.view, boor)
end

-- 设置提醒
function TypeItem:SetRemind(node, vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite then
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind_bg_sprite, 1, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

function TypeItem:OnSelectChange(is_select)
	self.tabbar_btn:setTogglePressed(is_select)
end

function TypeItem:CreateSelectEffect()
end

function TypeItem:OnClickBtn()
	if self.data == nil then return end
end
