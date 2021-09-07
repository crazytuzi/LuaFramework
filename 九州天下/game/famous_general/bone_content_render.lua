BoneRenderView = BoneRenderView or BaseClass(BaseRender)

local Effect_Res_List = {
	[1] = "UI_xingzuo_01",
	[2] = "UI_xingzuo_02",
	[3] = "UI_xingzuo_03",
	[4] = "UI_xingzuo_04",
	[5] = "UI_xingzuo_05",
}

function BoneRenderView:__init()
	self.is_auto_buy_stone = 0
	self.use_lucky_item = 0
	self.cell_list = {}
	self.list_index = self.list_index or 1
	self.cur_select_index = 1
end

function BoneRenderView:LoadCallBack()
	self.effect_obj_list = {}
	self.effect_res_list = {}
	for i = 1, 10 do
		self.effect_obj_list[i] = self:FindObj("Effect" .. i)
		self.effect_res_list[i] = self:FindVariable("effect_res_" .. i)
	end

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
	self.is_max = self:FindVariable("is_max")
	self.is_active = self:FindVariable("is_active")
	self.big_pic_path = self:FindVariable("big_pic_path")
	self.all_power = self:FindVariable("AllPower")
	self.general_name = self:FindVariable("Name")
	self.general_des = self:FindVariable("Des")
	self.quality_image = self:FindVariable("QualityImage")

	self.center_display = self:FindObj("CenterDisplay")
	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
	self.cur_attr_obj = self:FindObj("CurAttr")

	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("StuffItem"))
	
	self:ListenEvent("ClickLevelUp", BindTool.Bind(self.ClickLevelUp, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("LuckyItemClick", BindTool.Bind(self.LuckyItemClick, self))
	self:ListenEvent("OnClickTotalAttr", BindTool.Bind(self.OnClickTotalAttr, self))
	self:ListenEvent("AutoBuyChange", BindTool.Bind(self.AutoBuyChange, self))

	self.list_view = self:FindObj("ShengXiaoList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ReSetFlag()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.cur_select_index = FamousGeneralData.Instance:GetSelectIndex()
	self.list_index = FamousGeneralData.Instance:AfterSortListWithOpenLevel()[self.cur_select_index].seq + 1
end

function BoneRenderView:__delete()
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

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.is_auto_buy_stone = 0
	self.use_lucky_item = 0
end

function BoneRenderView:ReSetFlag()
	self.use_lucky_item = 0
	self.va_use_lucky_item:SetValue(false)
	self:SetLuckyItemQuality(false)
end

function BoneRenderView:ItemDataChangeCallback(item_id)
	self:FlushRightInfo()
	self:FlushListView()
end

--自动购买强化石Toggle点击时
function BoneRenderView:AutoBuyChange(is_on)
	self.is_auto_buy_stone = is_on and 1 or 0
end

function BoneRenderView:GetNumberOfCells()
	return #FamousGeneralData.Instance:AfterSortListWithOpenLevel()
end

function BoneRenderView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = BoneItem.New(cell.gameObject)
		self.cell_list[cell] = star_cell
	end
	star_cell:SetParent(self)
	star_cell:SetIndex(data_index)
	local data_list = FamousGeneralData.Instance:AfterSortListWithOpenLevel()
	star_cell:SetData(data_list[data_index])
	star_cell:ListenClick(BindTool.Bind(self.OnClickRoleListCell, self, data_index, data_list[data_index], star_cell))
end

function BoneRenderView:OnClickRoleListCell(data_index, cell_data, star_cell)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local cur_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(cell_data.seq + 1)
	local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(cell_data.seq + 1, cur_level)
	local is_active = FamousGeneralData.Instance:CheckGeneralIsActive(cell_data.seq)
	local select_data = FamousGeneralData.Instance:GetSingleDataBySeq(cell_data.seq)
	if main_role_vo.level < cur_cfg.open_level or not is_active then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.FamousGeneral.UnlockDesc, select_data.name, cur_cfg.open_level))
	end

	if self.cur_select_index == data_index then return end
	FamousGeneralData.Instance:SetSelectIndex(data_index)
	self.list_index = cell_data.seq + 1
	self.cur_select_index = data_index
	self:FlushAllHL()
	self:ReSetFlag()
	self:FlushRightInfo()
end

function BoneRenderView:GetSelectIndex()
	return self.cur_select_index
end

--使用幸运符按钮按下
function BoneRenderView:LuckyItemClick()
	if self.use_lucky_item == 1 then
		self.va_use_lucky_item:SetValue(false)
		self:SetLuckyItemQuality(false)
		self.use_lucky_item = 0
	else
		--if self:GetIsEnoughLuckyItem() then
			self.va_use_lucky_item:SetValue(true)
			self:SetLuckyItemQuality(true)
			self.use_lucky_item = 1
		--else
			-- self.va_use_lucky_item:SetValue(false)
			-- self:SetLuckyItemQuality(false)
			-- self.use_lucky_item = 0
			-- local cur_starsoul_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
			-- local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
			--TipsCtrl.Instance:ShowItemGetWayView(cur_cfg.protect_item_id)
		--end
	end
end

--身上是否有足够的luck符
function BoneRenderView:GetIsEnoughLuckyItem()
	local cur_starsoul_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.protect_item_id)
	if item_num >= cur_cfg.protect_item_num then
		return true, item_num, cur_cfg.protect_item_num
	else
		return false, item_num, cur_cfg.protect_item_num
	end
end

--是否需要luck符
function BoneRenderView:GetIsNeedLuckyItem()
	local cur_starsoul_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	return cur_cfg.is_protect_level ~= 1
end

-- 显示使用幸运符图标
function BoneRenderView:SetLuckyItemNum(need_num, had_num)
	self.prostuff_str:SetValue(string.format("%s/%s", ToColorStr(had_num, had_num >= need_num and COLOR.GREEN or COLOR.RED), need_num))
	local cur_starsoul_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
	local item_cfg = ItemData.Instance:GetItemConfig(cur_cfg.protect_item_id)
	self.lucky_item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
end

-- 显示幸运符图标质量
function BoneRenderView:SetLuckyItemQuality(is_show)
	if is_show then
		local cur_starsoul_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
		local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_starsoul_level)
		local item_cfg = ItemData.Instance:GetItemConfig(cur_cfg.protect_item_id)
		self.quality_image:SetAsset(ResPath.GetQualityIcon(item_cfg.color))
	else
		self.quality_image:SetAsset(ResPath.GetQualityIcon(0))
	end
end

-- 物品
function BoneRenderView:SetStuffItemInfo(need_num, had_num, item_id)
	local cur_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = FamousGeneralData.Instance:GetStarSoulMaxLevel(self.list_index)
	if not cur_level and not max_level then return end

	self.stuff_cell:SetData({item_id = item_id})
	if max_level > 0 and cur_level >= max_level then
		self.stuff_str:SetValue(Language.FamousGeneral.MaxBoneLevel)
	else
		self.stuff_str:SetValue(string.format("%s/%s", ToColorStr(had_num, had_num >= need_num and COLOR.GREEN or COLOR.RED), need_num))
	end
end

function BoneRenderView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(221)
end

function BoneRenderView:OnClickTotalAttr()
	local cur_suit_cfg , next_suit_cfg, total_level = FamousGeneralData.Instance:GetStarSoulTotal()
	TipsCtrl.Instance:ShowSuitAttrView(cur_suit_cfg, next_suit_cfg, total_level)
end

function BoneRenderView:ClickLevelUp()
	local cur_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local max_level = FamousGeneralData.Instance:GetStarSoulMaxLevel(self.list_index)
	if cur_level < max_level then
		local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_level)
		local bag_num1 = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
		local bag_num2 = ItemData.Instance:GetItemNumInBagById(cur_cfg.protect_item_id)
		local protect_item_use = (1 == self.use_lucky_item)
		if (bag_num1 >= cur_cfg.consume_stuff_num and (bag_num2 >= cur_cfg.protect_item_num or not protect_item_use)) or self.is_auto_buy_stone == 1 then
			if not protect_item_use and cur_cfg.succ_percent < 70 then
				local ok = function ()
					FamousGeneralCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1, self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
				end
				TipsCtrl.Instance:ShowCommonAutoView("low_bone_uprise_succ", Language.FamousGeneral.LowPercentSucc, ok)
			else
				FamousGeneralCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1, self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
			end
		else
			if not protect_item_use and cur_cfg.succ_percent < 70 then
				local ok = function ()
					FamousGeneralCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1, self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
				end
				TipsCtrl.Instance:ShowCommonAutoView("low_bone_uprise_succ", Language.FamousGeneral.LowPercentSucc, ok)
			else
				local func = function ()
					FamousGeneralCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_UPLEVEL_XINGHUN, self.list_index - 1, self.is_auto_buy_stone, cur_cfg.is_protect_level == 0 and self.use_lucky_item or 0)
				end
				local con_stuff_price = bag_num1 >= cur_cfg.consume_stuff_num and 0 or cur_cfg.consume_stuff_num * cur_cfg.consume_stuff_gold
				local pro_stuff_price = bag_num2 >= cur_cfg.protect_item_num and 0 or cur_cfg.protect_item_num * cur_cfg.protect_gold * self.use_lucky_item
				local auto_desc = string.format(Language.FamousGeneral.FillItemsDesc, con_stuff_price + pro_stuff_price)
				TipsCtrl.Instance:ShowCommonAutoView(nil, auto_desc, func)
			end
		end
	end
end

-- 刷新属性
function BoneRenderView:FlushAttrInfo()
	local cur_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	if cur_level then
		local cur_attr_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_level)
		local next_attr_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_level + 1)
		CommonDataManager.SetRoleChangeAttr(self.cur_attr_obj, cur_attr_cfg, next_attr_cfg)
	end
end

--刷新右边面板
function BoneRenderView:FlushRightInfo()
	local cur_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.list_index, cur_level)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local is_active = FamousGeneralData.Instance:CheckGeneralIsActive(self.list_index - 1)
	if cur_cfg == nil then return end

	local max_level = FamousGeneralData.Instance:GetStarSoulMaxLevel(self.list_index)
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)

	self:FlushPointEffect()
	self:FlushAttrInfo()

	self.big_pic_path:SetAsset(ResPath.GetShengXiaoStarSoul(self.list_index % 5 == 0 and 5 or self.list_index % 5))
	self.star_soul_level:SetValue(FamousGeneralData.Instance:GetStarSoulMaxLevelByIndex(self.list_index))
	self.is_max:SetValue(max_level > 0 and cur_level >= max_level)
	self.is_active:SetValue(is_active and (main_role_vo.level >= cur_cfg.open_level))
	self.success_rate:SetValue(cur_cfg.succ_percent)
	self:SetStuffItemInfo(cur_cfg.consume_stuff_num, item_num, cur_cfg.consume_stuff_id)
	for i = 1, 5 do
		self.star_gray_list[i]:SetValue(i <= FamousGeneralData.Instance:GetStarSoulBaojiByIndex(self.list_index))
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
		-- if not is_enough then
		-- 	self.use_lucky_item = 0
		-- end
		self:SetLuckyItemNum(need_num, had_num)
		self.va_use_lucky_item:SetValue(self.use_lucky_item == 1)
		self:SetLuckyItemQuality(self.use_lucky_item == 1)
	else
		self.need_lucky_item:SetValue(false)
	end

	local select_data = FamousGeneralData.Instance:GetSingleDataBySeq(self.list_index - 1)
	local name_str = ToColorStr(select_data.name, ITEM_COLOR[select_data.color])
	self.general_name:SetValue(string.format(Language.FamousGeneral.Name, name_str, cur_level))
	self.general_des:SetValue(select_data.synopsis)
end

function BoneRenderView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

--刷新所有装备格子信息
function BoneRenderView:FlushListCell()
	for k,v in pairs(self.cell_list) do
		v:Flush()
	end
end

function BoneRenderView:OnFlush()
	self:FlushListCell()
	self:FlushRightInfo()
end

function BoneRenderView:AfterSuccessUp(is_success)
	TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1.5)
end

function BoneRenderView:FlushPointEffect()
	local level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.list_index)
	local big_level, small_level = math.modf(level/10)
	small_level = string.format("%.2f", small_level * 10)
	small_level = math.floor(small_level)
	local image_list = {}
	
	if big_level > 0 then
		for j = 1, small_level do
			local res_id = Effect_Res_List[big_level + 1]
			local bubble, asset = ResPath.GetUiEffect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end

		for i = small_level + 1, 10 do
			local res_id = Effect_Res_List[big_level]
			local bubble, asset = ResPath.GetUiEffect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	else
		for i = 1, small_level do
			local res_id = Effect_Res_List[big_level + 1]
			local bubble, asset = ResPath.GetUiEffect(res_id)
			local res_path = {bubble, asset}
			table.insert(image_list, res_path)
		end
	end
	
	local point_effect_pos_cfg = FamousGeneralData.Instance:GetStarSoulPointCfg(self.list_index % 5 == 0 and 5 or self.list_index % 5)
	for i = 1, 10 do
		self.effect_obj_list[i]:SetActive(false)
		if i <= #image_list then
			local va_res_path = image_list[i]
			self.effect_res_list[i]:SetAsset(va_res_path[1], va_res_path[2])
			self.effect_obj_list[i]:SetActive(true)
			self.effect_obj_list[i]:GetComponent(typeof(UnityEngine.RectTransform)).anchoredPosition = Vector2(point_effect_pos_cfg[i].x, point_effect_pos_cfg[i].y)
		end
	end
end

function BoneRenderView:FlushListView()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------BoneItem--------------------------------
BoneItem = BoneItem or BaseClass(BaseCell)

function BoneItem:__init()
	self.parent = nil
	self.show_hl = self:FindVariable("show_hl")
	self.show_rp = self:FindVariable("show_rp")
	self.image_path = self:FindVariable("image_path")
	self.is_active = self:FindVariable("IsActive")
	self.quality = self:FindVariable("Quality")
	self.level = self:FindVariable("Level")
	self.show_lock = self:FindVariable("show_lock")
	self.open_desc = self:FindVariable("open_desc")
	self.show_open_desc = self:FindVariable("show_open_desc")
end

function BoneItem:SetParent(parent)
	self.parent = parent
end

function BoneItem:__delete()
	self.parent = nil
end

function BoneItem:OnFlush()
	if not self.data or not next(self.data) then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id) or {}
	self.image_path:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id or 0))
	self.quality:SetAsset(ResPath.GetQualityIcon(self.data.color))
	
	local cur_level = FamousGeneralData.Instance:GetStarSoulLevelByIndex(self.data.seq + 1)
	if not cur_level then return end
	local cur_cfg = FamousGeneralData.Instance:GetStarSoulInfoByIndexAndLevel(self.data.seq + 1, cur_level)
	if not cur_cfg then return end
	local item_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.consume_stuff_id)
	local max_level = FamousGeneralData.Instance:GetStarSoulMaxLevel(self.data.seq + 1)
	self.level:SetValue(cur_level)
	local is_unlock = main_role_vo.level >= cur_cfg.open_level
	local is_active = (FamousGeneralData.Instance:CheckGeneralIsActive(self.data.seq) and is_unlock)
	self:FlushHL()
	self.show_lock:SetValue(not is_active)
	self.is_active:SetValue(is_active)

	local lowest_general_seq = FamousGeneralData.Instance:GetLowestOpenLevelGeneralSeq()
	if lowest_general_seq ~= -1 and lowest_general_seq == self.data.seq and not is_active then
		self.open_desc:SetValue(string.format(Language.Common.OpenDesc, cur_cfg.open_level))
		self.show_open_desc:SetValue(true)
	else
		self.show_open_desc:SetValue(false)
	end

	if item_num >= cur_cfg.consume_stuff_num and max_level > cur_level and is_active then
		self.show_rp:SetValue(true)
	else
		self.show_rp:SetValue(false)
	end
end

function BoneItem:ListenClick(handler)
	self:ClearEvent("ClickItem")
	self:ListenEvent("ClickItem", handler)
end

function BoneItem:FlushHL()
	local list_index = self.parent:GetSelectIndex()
	self.show_hl:SetValue(list_index == self.index)
end