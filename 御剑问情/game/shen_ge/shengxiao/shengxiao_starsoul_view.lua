ShengXiaoStarSoulView = ShengXiaoStarSoulView or BaseClass(BaseRender)

local HIDE_NUM = 8

local Effect_Res_List = {
	[1] = "UI_xingzuo_01",
	[2] = "UI_xingzuo_02",
	[3] = "UI_xingzuo_03",
	[4] = "UI_xingzuo_04",
	[5] = "UI_xingzuo_05",
}

function ShengXiaoStarSoulView:__init()
	self.max_cell = 12

	self.can_level_up = self:FindVariable("can_level_up")
	self.effect_obj_list = {}
	self.effect_res_list = {}
	for i = 1, 10 do
		self.effect_obj_list[i] = self:FindObj("Effect" .. i)
		self.effect_res_list[i] = self:FindVariable("effect_res_" .. i)
	end
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("StuffItem"))
	self.star_gray_list = {}
	for i = 1, 5 do
		self.star_gray_list[i] = self:FindVariable("star_gray_" .. i)
	end
	self.lucky_item_icon = self:FindVariable("lucky_item_icon")
	self.va_use_lucky_item = self:FindVariable("use_lucky_item")
	self.need_lucky_item = self:FindVariable("need_lucky_item")
	self.prostuff_str = self:FindVariable("prostuff_str")
	self.stuff_str = self:FindVariable("stuff_str")
	self.success_rate = self:FindVariable("success_rate")
	self.star_soul_level = self:FindVariable("star_soul_level")
	self.cur_level = self:FindVariable("cur_level")
	self.extra_attr = self:FindVariable("extra_attr")
	self.extra_value = self:FindVariable("extra_value")
	self.extra_add = self:FindVariable("extra_add")
	self.is_max = self:FindVariable("is_max")
	self.show_extra_attr = self:FindVariable("show_extra_attr")

	self.big_pic_path = self:FindVariable("big_pic_path")
	self.up_level_btn_txt = self:FindVariable("UpLevelBtnTxt")
	self.all_power = self:FindVariable("AllPower")

	--自动购买Toggle
	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
	self:ListenEvent("AutoBuyChange", BindTool.Bind(self.AutoBuyChange, self))
	self.is_auto_buy_stone = 0

	self.cell_list = {}
	self.list_view = self:FindObj("ShengXiaoList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("ClickLevelUp", BindTool.Bind(self.ClickLevelUp, self))
	self:ListenEvent("OnClickListLeft", BindTool.Bind(self.OnClickListLeft, self))
	self:ListenEvent("OnClickListRight", BindTool.Bind(self.OnClickListRight, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("LuckyItemClick", BindTool.Bind(self.LuckyItemClick, self))
	self:ListenEvent("OnClickTotalAttr", BindTool.Bind(self.OnClickTotalAttr, self))

	self.attr_cell_list = {}
	self.attr_list = self:FindObj("AttrList")
	local list_delegate = self.attr_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAttrCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)

	self.equip_index = self.equip_index or 1
	self.list_index = self.list_index or 1

	self.center_display = self:FindObj("CenterDisplay")

	-- self:FlushFlyAni(self.list_index)
	self:ReSetFlag()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShengXiaoStarSoulView:__delete()
	if nil ~= self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.is_auto_buy_stone = 0
end

function ShengXiaoStarSoulView:CloseCallBack()
end

function ShengXiaoStarSoulView:OpenCallBack()
	ShengXiaoData.Instance:SetShengXiaoOldLevelList()
end

function ShengXiaoStarSoulView:HideEffectList()
	for k,v in pairs(self.effect_obj_list) do
		v:SetActive(false)
	end
end

function ShengXiaoStarSoulView:ItemDataChangeCallback(item_id)
	self:FlushRightInfo()
	self:FlushListView()
end

--自动购买强化石Toggle点击时
function ShengXiaoStarSoulView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ShengXiaoStarSoulView:GetNumberOfAttrCells()
	return 3
end

function ShengXiaoStarSoulView:RefreshAttrCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end

	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
	local data = {}
	if cur_starsoul_level == 0 then
		cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, 1)
		one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
		show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
		data = show_attr[data_index]
		data.value = 0
	else
		data = show_attr[data_index]
	end
	data.show_add = cur_starsoul_level < ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
	if cur_starsoul_level < ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index) then
		local next_equip_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level + 1)
		local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
		local next_show_attr = CommonDataManager.GetAttrNameAndValueByClass(attr_cfg)
		data.add_attr = next_show_attr[data_index].value - data.value
	else
		data.add_attr = 0
	end
	attr_cell:SetData(data)
end

function ShengXiaoStarSoulView:GetNumberOfCells()
	return self.max_cell
end

function ShengXiaoStarSoulView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = StarSoulItem.New(cell.gameObject)
		star_cell.shengxiao_starsoul_view = self
		self.cell_list[cell] = star_cell
	end
	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
end

function ShengXiaoStarSoulView:ReSetFlag()
	self.use_lucky_item = 0
	self.va_use_lucky_item:SetValue(false)
end

--使用幸运符按钮按下
function ShengXiaoStarSoulView:LuckyItemClick()
	if self.use_lucky_item == 1 then
		self.va_use_lucky_item:SetValue(false)
		self.use_lucky_item = 0
	else
		if self:GetIsEnoughLuckyItem() then
			self.va_use_lucky_item:SetValue(true)
			self.use_lucky_item = 1
		else
			self.va_use_lucky_item:SetValue(false)
			self.use_lucky_item = 0
			local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
			local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
			TipsCtrl.Instance:ShowItemGetWayView(cur_cfg.protect_item_id)
		end
	end
end

--身上是否有足够的luck符
function ShengXiaoStarSoulView:GetIsEnoughLuckyItem()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.protect_item_id)
	if item_num >= cur_cfg.protect_item_num then
		return true, item_num, cur_cfg.protect_item_num
	else
		return false, item_num, cur_cfg.protect_item_num
	end
end

--是否需要luck符
function ShengXiaoStarSoulView:GetIsNeedLuckyItem()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	return cur_cfg.is_protect_level ~= 1
end

-- 显示使用幸运符图标
function ShengXiaoStarSoulView:SetLuckyItemNum(need_num, had_num)
	local had_text = ""
	local need_text = ToColorStr(' / '..need_num,TEXT_COLOR.BLACK_1)
	if had_num >= need_num then
		had_text = ToColorStr(had_num,TEXT_COLOR.TONGYONG_TS)
	else
		had_text = ToColorStr(had_num,COLOR.RED)
	end
	self.prostuff_str:SetValue(had_text..need_text)

	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local item_cfg = ItemData.Instance:GetItemConfig(cur_cfg.protect_item_id)
	self.lucky_item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
end

-- 物品
function ShengXiaoStarSoulView:SetStuffItemInfo(need_num, had_num, item_id)
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
	if max_level > 0 and cur_starsoul_level >= max_level then
		self.stuff_str:SetValue(string.format(Language.Common.ShowBlackStr, Language.ShengXiao.MaxStarSoul))
		self.stuff_cell:SetData({item_id = item_id or 26000})
		return 
	end
	local had_text = ""
	local need_text = ToColorStr(' / '..need_num,TEXT_COLOR.BLACK_1)
	if had_num >= need_num then
		had_text = ToColorStr(had_num,TEXT_COLOR.TONGYONG_TS)
	else
		had_text = ToColorStr(had_num,COLOR.RED)
	end
	self.stuff_str:SetValue(had_text..need_text)
	self.stuff_cell:SetData({item_id = item_id or 26000})
end

function ShengXiaoStarSoulView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(231)
end

function ShengXiaoStarSoulView:OnClickTotalAttr()
	local cur_suit_cfg , next_suit_cfg, total_level = ShengXiaoData.Instance:GetStarSoulTotal()
	TipsCtrl.Instance:ShowSuitAttrView(cur_suit_cfg, next_suit_cfg, total_level)
end

function ShengXiaoStarSoulView:OnClickListRight()
	if self.list_view.scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM >= 1 then
		self.list_view.scroll_rect.horizontalNormalizedPosition = 1
		return
	end
	self.list_view.scroll_rect.horizontalNormalizedPosition = self.list_view.scroll_rect.horizontalNormalizedPosition + 1 / HIDE_NUM
end

function ShengXiaoStarSoulView:OnClickListLeft()
	if self.list_view.scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM <= 0 then
		self.list_view.scroll_rect.horizontalNormalizedPosition = 0
		return
	end
	self.list_view.scroll_rect.horizontalNormalizedPosition = self.list_view.scroll_rect.horizontalNormalizedPosition - 1 / HIDE_NUM
end

function ShengXiaoStarSoulView:ClickLevelUp()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)

	if cur_starsoul_level < max_level then
		local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
		local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
		if bag_num >= cur_cfg.consume_stuff_num then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1,
				self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
		elseif self.is_auto_buy_stone == 1 then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1, 
				self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
		else
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				--勾选自动购买
				if is_buy_quick then
					self.auto_buy_toggle.isOn = true
					self.is_auto_buy_stone = 1
				end
			end
			local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.consume_stuff_id)
			if cur_cfg.consume_stuff_num - bag_num == nil then
				MarketCtrl.Instance:SendShopBuy(cur_cfg.consume_stuff_id, 999, 0, 1)
			else
				TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.consume_stuff_id, nil, cur_cfg.consume_stuff_num - bag_num)
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.MaxXingHun)
	end
	if ShengXiaoData.Instance:GetStarSoulCanUp(self.list_index) then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGHUN_UNLOCK)
	end
end

--刷新右边面板
function ShengXiaoStarSoulView:FlushRightInfo()
	local cur_starsoul_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = ShengXiaoData.Instance:GetStarSoulMaxLevel(self.list_index)
	local cur_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	if cur_cfg == nil then return end
	local next_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level + 1)
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
	local max_cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, max_level)
	local show_attr = CommonDataManager.GetAdvanceAddNameAndValueByClass(max_cfg)
	local next_add_cfg = ShengXiaoData.Instance:GetNextStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level, show_attr[1].attr)
	if next(show_attr) then
		self.extra_attr:SetValue(show_attr[1].attr_name)
		self.extra_value:SetValue(cur_cfg[show_attr[1].attr] / 100)
		self.show_extra_attr:SetValue(true)
		if nil ~= next_cfg then
			self.extra_add:SetValue((next_add_cfg[show_attr[1].attr] -  cur_cfg[show_attr[1].attr]) / 100 .. "%(" .. ToColorStr(cur_starsoul_level, COLOR.RED) .. " / " .. next_add_cfg.level .. ")")
			-- self.extra_add:SetValue((next_cfg[show_attr[1].attr] - cur_cfg[show_attr[1].attr]) / 100)
		end
	else
		self.extra_attr:SetValue("")
		self.extra_value:SetValue("")
		self.extra_add:SetValue("")
		self.show_extra_attr:SetValue(false)
	end

	self:FlushPointEffect()
	self.attr_list.scroller:ReloadData(0)
	self.big_pic_path:SetAsset(ResPath.GetShengXiaoStarSoul(self.list_index))
	self.star_soul_level:SetValue(ShengXiaoData.Instance:GetStarSoulMaxLevelByIndex(self.list_index))
	self.cur_level:SetValue(cur_starsoul_level)
	self.is_max:SetValue(max_level > 0 and cur_starsoul_level >= max_level)
	self.success_rate:SetValue(cur_cfg.succ_percent)
	self:SetStuffItemInfo(cur_cfg.consume_stuff_num, item_num, cur_cfg.consume_stuff_id)
	for i = 1, 5 do
		self.star_gray_list[i]:SetValue(i <= ShengXiaoData.Instance:GetStarSoulBaojiByIndex(self.list_index))
	end
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local one_level_power = CommonDataManager.GetCapability(one_level_attr)
	self.all_power:SetValue(one_level_power)
	if self:GetIsNeedLuckyItem() then
		self.need_lucky_item:SetValue(true)
		local is_enough = false
		local need_num = 0
		local had_num = 0
		is_enough, had_num, need_num = self:GetIsEnoughLuckyItem()
		if not is_enough then
			self.use_lucky_item = 0
		end
		self:SetLuckyItemNum(need_num, had_num)
		self.va_use_lucky_item:SetValue(self.use_lucky_item == 1)
	else
		self.need_lucky_item:SetValue(false)
	end
end

function ShengXiaoStarSoulView:FlushLeftInfo()
	
end

function ShengXiaoStarSoulView:GetSelectIndex()
	return self.list_index or 1
end

function ShengXiaoStarSoulView:SetSelectIndex(index)
	if index == self.list_index then
		return
	end
	self.list_index = index
	-- self:FlushFlyAni(index)
end

function ShengXiaoStarSoulView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

--刷新所有装备格子信息
function ShengXiaoStarSoulView:FlushListCell()
	for k,v in pairs(self.cell_list) do
		v:OnFlush()
	end

	-- 有可激活的帮他移动到可激活的位置
	-- local boom_effect_index = 0
	-- local zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	-- for i=1,self.max_cell do
	-- 	if ShengXiaoData.Instance:GetStarSoulCanUp(i) and i > zodiac_progress then
	-- 		boom_effect_index = i
	-- 		break
	-- 	end
	-- end
	-- print_error("bbbbb", boom_effect_index)
	-- if boom_effect_index > 1 then
	-- 	self.list_view.scroller:ReloadData((boom_effect_index - 1) / self.max_cell)
	-- end
end

function ShengXiaoStarSoulView:FlushAll()
	self:FlushListCell()
	self:FlushLeftInfo()
	self:FlushRightInfo()
end

function ShengXiaoStarSoulView:AfterSuccessUp(is_success)
	local old_level = ShengXiaoData.Instance:GetShengXiaoOldLevelByIndex(self.list_index)
	local cur_level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	ShengXiaoData.Instance:SetShengXiaoOldLevelList()
	if cur_level > old_level then
		TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui_x/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1)
	end
end

function ShengXiaoStarSoulView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end
	self.center_display.rect:SetLocalPosition(0, 0, 0)
	self.center_display.rect:SetLocalScale(0, 0, 0)
	self:HideEffectList()
	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(1, 1, 1)
	self.tweener1 = self.center_display.rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.center_display.rect:DOScale(target_scale, 0.7)
	self.tweener1:OnComplete(BindTool.Bind(self.FlushPointEffect, self))
end

function ShengXiaoStarSoulView:FlushPointEffect()
	local level = ShengXiaoData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local big_level, small_level = math.modf(level/10)
	small_level = string.format("%.2f", small_level * 10)
	small_level = math.floor(small_level)
	local image_list = {}
	
	if big_level > 0 then
		for j = 1, small_level do
			local res_id = Effect_Res_List[big_level + 1]
			local bubble, asset = ResPath.GetShenXiaoStarEfect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end

		for i = small_level + 1, 10 do
			local res_id = Effect_Res_List[big_level]
			local bubble, asset = ResPath.GetShenXiaoStarEfect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	else
		for i = 1, small_level do
			local res_id = Effect_Res_List[big_level + 1]
			local bubble, asset = ResPath.GetShenXiaoStarEfect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	end
	
	local point_effect_pos_cfg = ShengXiaoData.Instance:GetStarSoulPointCfg(self.list_index)
	for i = 1, #image_list do
		self.effect_obj_list[i]:SetActive(true)
		self.effect_obj_list[i]:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(point_effect_pos_cfg[i].x, point_effect_pos_cfg[i].y)
		local va_res_path = image_list[i]
		self.effect_res_list[i]:SetAsset(va_res_path[1], va_res_path[2])
	end
	-- for i = 1, #image_list do
	-- 	self.effect_obj_list[i]:SetActive(false)
	-- 	self.effect_obj_list[i]:SetActive(true)
	-- end

	for i = #image_list + 1,10 do
		self.effect_obj_list[i]:SetActive(false)
	end

end

function ShengXiaoStarSoulView:FlushListView()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------StarSoulItem--------------------------------
StarSoulItem = StarSoulItem or BaseClass(BaseCell)

function StarSoulItem:__init()
	self.shengxiao_starsoul_view = nil
	self.show_hl = self:FindVariable("show_hl")
	self.show_rp = self:FindVariable("show_rp")
	-- self.level = self:FindVariable("level")
	self.image_path = self:FindVariable("image_path")
	self.shengxiao_name = self:FindVariable("shengxiao_name")
	self.show_lock = self:FindVariable("show_lock")
	self.show_lock_effect = self:FindVariable("show_lock_effect")
	self.boom_effect_obj = self:FindObj("LockEffectObj")
	self.boom_effect_obj:SetActive(false)
	self.boom_effect_index = 0
	self.old_zodiac_progress = 0

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
	self:ListenEvent("ClickLock", BindTool.Bind(self.ClickLock, self))
end

function StarSoulItem:__delete()

	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end

	self.shengxiao_starsoul_view = nil
end

function StarSoulItem:SetItemIndex(index)
	self.item_index = index
end

function StarSoulItem:OnFlush()
	self:FlushHL()
	local zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	self.show_lock:SetValue(not ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) or self.item_index > zodiac_progress )
	-- self.show_rp:SetValue(ShengXiaoData.Instance:GetEquipRemindByStarIndex(self.item_index))
	self.image_path:SetAsset(ResPath.GetShengXiaoIcon(self.item_index))

	self.show_lock_effect:SetValue(ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) and self.item_index > zodiac_progress )

	if self.boom_effect_index > 0 then
		if self.old_zodiac_progress < zodiac_progress then
			self.old_zodiac_progress = zodiac_progress
			self.boom_effect_index = 0
			self.boom_effect_obj:SetActive(true)
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.boom_effect_obj:SetActive(false) end, 0.5)
		end
	end
	self.show_rp:SetValue(ShengXiaoData.Instance:GetStarSoulRemindByStarIndex(self.item_index))

	local cfg =  ShengXiaoData.Instance:GetZodiacInfoByIndex(self.item_index, 1)
	if not cfg then print_log("cfg is nil") return end
	self.shengxiao_name:SetValue(cfg.name)
end

function StarSoulItem:OnClickItem()
	local list_index = self.shengxiao_starsoul_view:GetSelectIndex()
	if list_index == self.item_index then
		return
	end
	local zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	if not ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) or self.item_index > zodiac_progress then
		return
	end
	self.shengxiao_starsoul_view:SetSelectIndex(self.item_index)
	self.shengxiao_starsoul_view:ReSetFlag()
	self.shengxiao_starsoul_view:FlushAllHL()
	self.shengxiao_starsoul_view:FlushLeftInfo()
	self.shengxiao_starsoul_view:FlushRightInfo()
end


function StarSoulItem:ClickLock()
	if ShengXiaoData.Instance:GetStarSoulCanUp(self.item_index) then
		ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGHUN_UNLOCK)
		self.boom_effect_index = self.item_index
		self.old_zodiac_progress = ShengXiaoData.Instance:GetStarSoulProgress()
	else
		local cfg = ShengXiaoData.Instance:GetStarSoulInfoByIndexAndLevel(self.item_index, 0)
		local lase_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.item_index - 1, 0)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShengXiao.OpenCondition, lase_cfg.name, cfg.backwards_highest_level))
	end
end

function StarSoulItem:FlushHL()
	local list_index = self.shengxiao_starsoul_view:GetSelectIndex()
	self.show_hl:SetValue(list_index == self.item_index)
end