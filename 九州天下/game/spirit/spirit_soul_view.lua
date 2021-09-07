SpiritSoulView = SpiritSoulView or BaseClass(BaseRender)

local MAX_NUM = 36
local ROW = 3
local COLUMN = 4

local SOUL_BAOXIANG_NUM = 5	-- 抽命魂宝箱
local SOUL_SLOT_NUM = 8		-- 命魂槽数量
local SOUL_POOL_ROW = 3 	-- 命魂池的行数

function SpiritSoulView:__init(instance)
	-- self:ListenEvent("OnClickSpecial1",BindTool.Bind(self.OnClickSpecial, self, 1))
	-- self:ListenEvent("OnClickSpecial2",BindTool.Bind(self.OnClickSpecial, self, 2))
	-- self:ListenEvent("OnClickSpecial3",BindTool.Bind(self.OnClickSpecial, self, 3))
	-- self:ListenEvent("OnClickSpecial4",BindTool.Bind(self.OnClickSpecial, self, 4))
	-- self:ListenEvent("OnClickSoul1",BindTool.Bind(self.OnClickSoul, self, 1))
	-- self:ListenEvent("OnClickSoul2",BindTool.Bind(self.OnClickSoul, self, 2))
	-- self:ListenEvent("OnClickSoul3",BindTool.Bind(self.OnClickSoul, self, 3))
	-- self:ListenEvent("OnClickSoul4",BindTool.Bind(self.OnClickSoul, self, 4))
	self:ListenEvent("OnClickGetSoul", BindTool.Bind(self.OnClickGetSoul, self))
	self:ListenEvent("OnClickCombineSoul", BindTool.Bind(self.OnClickCombineSoul, self))
	self:ListenEvent("OnClickSoulBag", BindTool.Bind(self.OnClickSoulBag, self))
	self:ListenEvent("OnClickOneKeySale", BindTool.Bind(self.OnClickOneKeySale, self))
	self:ListenEvent("OnClickOneKeyCall", BindTool.Bind(self.OnClickOneKeyCall, self))
	self:ListenEvent("OnClickChangeLife", BindTool.Bind(self.OnClickChangeLife, self))
	self:ListenEvent("OnClickOneKeyPutInBag", BindTool.Bind(self.OnClickOneKeyPutInBag, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickAttrsBtn", BindTool.Bind(self.OnClickAttrsBtn, self))
	-- self:ListenEvent("OnClickCloseAttrs", BindTool.Bind(self.OnClickCloseAttrs, self))
	self:ListenEvent("OnClickHandbook",BindTool.Bind(self.OnClickHandbook,self))
	self:ListenEvent("OnClickChouHun1", BindTool.Bind(self.OnClickChouHun, self, 1))
	self:ListenEvent("OnClickChouHun2", BindTool.Bind(self.OnClickChouHun, self, 2))
	self:ListenEvent("OnClickChouHun3", BindTool.Bind(self.OnClickChouHun, self, 3))
	self:ListenEvent("OnClickChouHun4", BindTool.Bind(self.OnClickChouHun, self, 4))
	self:ListenEvent("OnClickChouHun5", BindTool.Bind(self.OnClickChouHun, self, 5))

	self.storage_exp = self:FindVariable("StorageExp")
	self.show_get_redpoint = self:FindVariable("ShowGetRed")
	-- self.attr_list = {
	-- 		["gongji"] = self:FindVariable("Gongji"),
	-- 		["fangyu"] = self:FindVariable("Fangyu"),
	-- 		["maxhp"] = self:FindVariable("Maxhp"),
	-- 		["mingzhong"] = self:FindVariable("Mingzhong"),
	-- 		["shanbi"] = self:FindVariable("Shanbi"),
	-- 		["baoji"] = self:FindVariable("Baoji"),
	-- 		["jianren"] = self:FindVariable("Jianren"),
	-- }
	-- self.show_attr_label = self:FindVariable("ShowAttrsLabel")
	-- self.all_attr_fight_power = self:FindVariable("FightPower")

	self.soul_bag_toggle = self:FindObj("SoulBagToggle").toggle
	self.get_soul_toggle = self:FindObj("GetSoulToggle").toggle
	self.display = self:FindObj("Display")

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSoulNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSoulBagCell, self)

	self.get_soul_items = {}
	for i = 1, SOUL_POOL_ROW do
		self.get_soul_items[i] = SpiritSoulItemGroupSixLengt.New(self:FindObj("ItemGroup"..i))
	end

	self.page_toggle_list = {
			self:FindObj("PageToggle1").toggle,
			self:FindObj("PageToggle2").toggle,
			self:FindObj("PageToggle3").toggle,
	}

	self.dress_soul_items = {}
	for i = 1, SOUL_SLOT_NUM do
		self.dress_soul_items[i] = SpiritDressSoulItem.New(self:FindObj("DressItem"..i))
	end

	self.cur_click_slot_index = -1

	self.color_items = {}
	self.color_btn_costs = {}
	for i = 1, SOUL_BAOXIANG_NUM do
		local icon = self:FindObj("Icon"..i)
		self.color_items[i] = icon
		self.color_btn_costs[i] = self:FindVariable("CostNum"..i)
	end

	self.soul_items = {}
	-- self.chou_hun_list = {}
	self.fix_show_time = 8
	self.is_one_key_chou = false
	self.total_zhanli = self:FindVariable("total_zhanli")

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritSoulGet)
end

function SpiritSoulView:OnClickHandbook()
	ViewManager.Instance:Open(ViewName.SoulHandBook)
end

function SpiritSoulView:__delete()
	for k, v in pairs(self.soul_items) do
		v:DeleteMe()
	end
	self.soul_items = {}

	for k, v in pairs(self.get_soul_items) do
		v:DeleteMe()
	end
	self.get_soul_items = {}
	self.cur_click_slot_index = nil
	self.fix_show_time = nil
	self.total_zhanli = nil

	-- for k, v in pairs(self.chou_hun_list) do
	-- 	GameObject.Destroy(v)
	-- end
	-- self.chou_hun_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.is_one_key_chou = nil

	for k, v in pairs(self.dress_soul_items) do
		v:DeleteMe()
	end
	self.dress_soul_items = {}
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function SpiritSoulView:RemindChangeCallBack(remind_name, num)
	if RemindName.SpiritSoulGet == remind_name then
		self.show_get_redpoint:SetValue(num > 0)
	end
end

function SpiritSoulView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function SpiritSoulView:GetSoulNumberOfCells()
	return MAX_NUM / ROW
end

function SpiritSoulView:RefreshSoulBagCell(cell, data_index)
	local group = self.soul_items[cell]
	local bag_list= SpiritData.Instance:GetSpiritSoulBagInfo().grid_list
	if nil == group then
		group = SpiritSoulItemGroup.New(cell.gameObject)
		self.soul_items[cell] = group
	end
	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN + column + (page * grid_count)
		if group:GetData(i) and group:GetData(i).id == bag_list[index].id then
			group:IsDestroyEffect(i, false)
		else
			group:IsDestroyEffect(i, true)
		end
		group:SetData(i, bag_list and bag_list[index] or {})
		group:ListenClick(i, BindTool.Bind(self.OnClickBagSoulItem, self, index))
	end
end

-- 打开总属性面板
function SpiritSoulView:OnClickAttrsBtn()
	-- self.show_attr_label:SetValue(true)
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	local temp_attr_list = CommonDataManager.GetAttributteNoUnderline()
	if slot_soul_info and next(slot_soul_info) then
		for k, v in pairs(slot_soul_info.slot_list) do
			if v.id > 0 then
				local cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
				local attr_list = SpiritData.Instance:GetSoulAttrCfg(v.id, v.level) or {}
				if temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] then
					temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] = temp_attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]] + attr_list[SOUL_ATTR_NAME_LIST[cfg.hunshou_type]]
				end
			end
		end
	-- else
	-- 	for k, v in pairs(self.attr_list) do
	-- 		v:SetValue(0)
	-- 	end
	end
	-- for k, v in pairs(self.attr_list) do
	-- 	v:SetValue(temp_attr_list[k])
	-- end
	TipsCtrl.Instance:ShowAttrView(temp_attr_list)
	-- self.all_attr_fight_power:SetValue(CommonDataManager.GetCapabilityCalculation(temp_attr_list))
end

-- 关闭总属性面板
-- function SpiritSoulView:OnClickCloseAttrs()
-- 	self.show_attr_label:SetValue(false)
-- end

-- 背包命魂格子
function SpiritSoulView:OnClickBagSoulItem(index)
	if index == nil then return end
	local bag_list= SpiritData.Instance:GetSpiritSoulBagInfo().grid_list
	local data = bag_list and bag_list[index] or {}
	if nil == data or nil == next(data) then return end
	if data.id <= 0 then return end
	data.item_data = {id = data.id, index = data.index}
	TipsCtrl.Instance:ShowSpiritSoulPropView(data, SOUL_FROM_VIEW.SOUL_BAG)
end

-- 获取命魂按钮
function SpiritSoulView:OnClickGetSoul()
	self.soul_bag_toggle.isOn = false
	self.is_one_key_chou = false
end

-- 合并命魂
function SpiritSoulView:OnClickCombineSoul()
	local grid_list = SpiritData.Instance:GetSpiritSoulBagInfo().grid_list
	local count = -1
	if grid_list then
		for k, v in pairs(grid_list) do
			if v.id > 0 then
				count = count + 1
			end
		end
	end
	if count < 1 then return end
	local ok_func = function ()
		SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.MERGE)
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulCombineStr , nil, nil, true, false, "combinesoul")
end

-- 命魂背包
function SpiritSoulView:OnClickSoulBag()
	self.get_soul_toggle.isOn = false
	self.is_one_key_chou = false
	self:FlushBagView()
end

-- 从链接进来，显示抽命魂页面
function SpiritSoulView:SetGetSoulPanel()
	self.get_soul_toggle.isOn = true
end

-- 默认显示背包那一面
function SpiritSoulView:ResetOpenState()
	self.get_soul_toggle.isOn = false
end

function SpiritSoulView:FlushBagView()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function SpiritSoulView:JumpToPage(page)
	page = page or 1
	local jump_index = 0
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.2
	local scroll_complete = function()
		self.current_page = page
	end
	self.list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	self.page_toggle_list[1].isOn = true
end

-- 一键卖经验
function SpiritSoulView:OnClickOneKeySale()
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local liehun_pool = soul_bag_info.liehun_pool
	if not liehun_pool or not next(liehun_pool) then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanSale)
		return
	end

	local can_sale = false
	for k, v in pairs(liehun_pool) do
		if v.id > 0 then
			can_sale = true
		end
	end
	if not can_sale then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanSale)
		return
	end

	local ok_func = function ()
		self.is_one_key_chou = false
		SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.CONVERT_TO_EXP)
	end
	if SpiritData.Instance:IsHadMoreThenPurpleSoul() then
		self.is_one_key_chou = false
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulOneKeySaleSoulPoolStr , nil, nil, true, false, "onekeysalepurple")
		return
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulOneKeySaleCallStr , nil, nil, true, false, "onekeysale")
end

function SpiritSoulView:OnClickHelp()
	local tip_id = 41
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 一键放入背包
function SpiritSoulView:OnClickOneKeyPutInBag()
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local liehun_pool = soul_bag_info.liehun_pool
	if not liehun_pool or not next(liehun_pool) then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanPutBag)
		return
	end

	local can_sale = false
	for k, v in pairs(liehun_pool) do
		if v.id > 0 and v.id ~= GameEnum.HUNSHOU_EXP_ID then
			can_sale = true
		end
	end
	if not can_sale then
		TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolNoCanPutBag)
		return
	end
	local ok_func = function ()
		SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.PUT_BAG_ONE_KEY)
		self.is_one_key_chou = false
	end
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.PutBagOnekey , nil, nil, true, false, "putbagonekey")
end

-- 一键召唤
function SpiritSoulView:OnClickOneKeyCall()
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local liehun_pool = soul_bag_info.liehun_pool
	local index = 0
	local cfg = SpiritData.Instance:GetSpiritCallSoulCfg()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if liehun_pool then
		for k, v in pairs(liehun_pool) do
			if v.id and v.id <= 0 then
				index = index + 1
			end
		end
		local ok_func = function ()
			SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.BATCH_HUNSHOU)
			self.is_one_key_chou = true
		end
		if index <= 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.SoulPoolFull)
			return
		end
		for k, v in pairs(cfg) do
			if v.chouhun_color == color then
				if vo.hunli < v.cost_hun_li then
					local item_id = 22606
					local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
					if item_cfg == nil then
						TipsCtrl.Instance:ShowItemGetWayView(item_id)
						return
					end

					-- if item_cfg.bind_gold == 0 then
					-- 	TipsCtrl.Instance:ShowShopView(item_id, 2)
					-- 	return
					-- end

					local func = function(_item_id, item_num, is_bind, is_use)
						MarketCtrl.Instance:SendShopBuy(_item_id, item_num, is_bind, is_use)
					end

					TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
					return
				end
			end
		end
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.JingLing.SoulMultipleCallStr , nil, nil, true, false, "multiplecall")
	end
end

-- 逆天改命
function SpiritSoulView:OnClickChangeLife()
	local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
	local ok_func = function ()
		SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SUPER_CHOUHUN)
		self.is_one_key_chou = false
	end

	local str = string.format(Language.JingLing.SoulChangeLifeStr, lieming_cfg.other[1].super_chouhun_price)
	TipsCtrl.Instance:ShowCommonTip(ok_func, nil, str, nil, nil, true, false, "changelife")
end

-- function SpiritSoulView:OnClickSpecial(index)
-- 	TipsCtrl.Instance:ShowSpiritDressSoulView()
-- end

-- 点击命魂槽
function SpiritSoulView:OnClickSlotSoul(index, is_lock)
	if nil == index then return end

	self.cur_click_slot_index = index
	local slot_list = SpiritData.Instance:GetSpiritSlotSoulInfo().slot_list
	local data = slot_list and slot_list[index] or {}
	local hunge_activity_condition = ConfigManager.Instance:GetAutoConfig("lieming_auto").hunge_activity_condition
	if is_lock then
		local msg = ""
		if index == 7 then
			msg = Language.JingLing.NoOpen
		else
			local level = hunge_activity_condition[index + 1].role_level
			local level_befor = math.floor(level % 100) ~= 0 and math.floor(level % 100) or 100
			local level_behind = math.floor(level % 100) ~= 0 and math.floor(level / 100) or math.floor(level / 100) - 1
			local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind)
			msg = string.format(Language.JingLing.SoulSlotOpenAdition, level_zhuan)
		end
		TipsCtrl.Instance:ShowSystemMsg(msg)
		return
	end

	if nil == data.id or data.id <= 0 then return end

	data.slot_index = index
	local callback = function()
		self.cur_click_slot_index = -1
	end
	TipsCtrl.Instance:ShowSpiritDressSoulView(data, callback)
end

-- 刷新弹出Tip数据
function SpiritSoulView:FlushSlotSoulTip()
	if -1 >= self.cur_click_slot_index then return end

	local slot_list = SpiritData.Instance:GetSpiritSlotSoulInfo().slot_list
	local data = slot_list and slot_list[self.cur_click_slot_index] or {}
	if nil == data.id or data.id <= 0 then return end
	data.slot_index = self.cur_click_slot_index
	local callback = function()
		self.cur_click_slot_index = -1
	end
	TipsCtrl.Instance:ShowSpiritDressSoulView(data, callback)
end

-- 点击召唤出来的命魂
function SpiritSoulView:OnClickHadCallSoulItem(index)
	if nil == index then return end
	local liehun_pool = SpiritData.Instance:GetSpiritSoulBagInfo().liehun_pool
	local data = liehun_pool and liehun_pool[index] or {}

	if not data.id or data.id <= 0 then return end

	data.item_data = {id = data.id, index = data.index}
	TipsCtrl.Instance:ShowSpiritSoulPropView(data, SOUL_FROM_VIEW.SOUL_POOL)
	self.is_one_key_chou = false
end

-- 命魂抽取存放池
function SpiritSoulView:SetSoulPoolItemData()
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	local bit_list = bit:d2b(slot_soul_info.slot_activity_flag)
	if soul_bag_info and next(soul_bag_info) then
		local liehun_pool = soul_bag_info.liehun_pool
		for k, v in pairs(self.get_soul_items) do
			for n = 0, 5 do
				if v:GetData(n + 1) and v:GetData(n + 1).id == liehun_pool[(k - 1) * 6 + n].id then
					v:IsDestroyEffect(n + 1, false)
				else
					v:IsDestroyEffect(n + 1, true)
				end
				v:SetData(n + 1, liehun_pool[(k - 1) * 6 + n])
				v:ListenClick(n + 1, BindTool.Bind(self.OnClickHadCallSoulItem, self, (k - 1) * 6 + n))
			end
		end
	end

	-- 显示替换命魂面板
	-- if self.is_one_key_chou then
	-- 	local list = SpiritData.Instance:GetSoulPoolHighQuality()
	-- 	if next(list) then
	-- 		local func = function ()
	-- 			self.is_one_key_chou = false
	-- 		end
	-- 		TipsCtrl.Instance:ShowSpiritSoulChangeView(func, list)
	-- 	end
	-- end
end

-- 设置抽命魂颜色
function SpiritSoulView:SetItemColor()
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local chou_hun_cfg = SpiritData.Instance:GetSpiritCallSoulCfg()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	local baoxiang_index = 0
	for k, v in pairs(self.color_items) do
		if k == (color + 1) then
			baoxiang_index = k
			v.grayscale.GrayScale = 0
		else
			v.grayscale.GrayScale = 255
			if self.get_soul_toggle.isOn then
				v.animator:SetBool("Shake", false)
			end
		end
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if not self.time_quest then
		local time = 0
		if self.color_items[baoxiang_index] and self.get_soul_toggle.isOn then
			self.color_items[baoxiang_index].animator:SetBool("Shake", true)
		end
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			time = time - 1
			if self.color_items[baoxiang_index] and time <= 0 and self.get_soul_toggle.isOn then
				self.color_items[baoxiang_index].animator:SetBool("Shake", true)
				time = 1
			end
		end, 1)
	end
end

function SpiritSoulView:OnClickChouHun(index)
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local color = soul_bag_info and soul_bag_info.liehun_color or -1
	local cfg = SpiritData.Instance:GetSpiritCallSoulCfg()
	if index ~= (color + 1) or not cfg then return end

	for k, v in pairs(cfg) do
		if v.chouhun_color == color then
			if vo.hunli < v.cost_hun_li then
				local item_id = 22606
				local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
				if item_cfg == nil then
					TipsCtrl.Instance:ShowItemGetWayView(item_id)
					return
				end

				-- if item_cfg.bind_gold == 0 then
				-- 	TipsCtrl.Instance:ShowShopView(item_id, 2)
				-- 	return
				-- end

				local func = function(_item_id, item_num, is_bind, is_use)
					MarketCtrl.Instance:SendShopBuy(_item_id, item_num, is_bind, is_use)
				end

				TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc, 1)
				return
			end
		end
	end

	self.is_one_key_chou = false
	SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.CHOUHUN)
end

-- 设置抽猎命的消耗魂力数值
function SpiritSoulView:SetCostHunli()
	local cfg = SpiritData.Instance:GetSpiritCallSoulCfg()
	for k, v in pairs(self.color_btn_costs) do
		v:SetValue(cfg[k] and cfg[k].cost_hun_li or 0)
	end
end

function SpiritSoulView:SetModel()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	if not spirit_info or not spirit_info.use_jingling_id or not spirit_info.jingling_list then return end

	if nil == self.model then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.display.ui3d_display)
	end
	if self.model then
		if spirit_info.use_jingling_id > 0 then
			local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(spirit_info.use_jingling_id)
			if spirit_cfg and self.res_id ~= spirit_cfg.res_id then
				self.model:SetMainAsset(ResPath.GetSpiritModel(spirit_cfg.res_id))
			end
			self.res_id = spirit_cfg.res_id
		elseif spirit_info.use_jingling_id <= 0 and next(spirit_info.jingling_list) then
			local spirit_cfg = nil
			for k, v in pairs(spirit_info.jingling_list) do
				spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(v.item_id)
				break
			end
			if spirit_cfg and self.res_id ~= spirit_cfg.res_id then
				self.model:SetMainAsset(ResPath.GetSpiritModel(spirit_cfg.res_id))
			end
			self.res_id = spirit_cfg.res_id
		else
			local item_id = 15016
			local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(item_id)
			if spirit_cfg and self.res_id ~= spirit_cfg.res_id then
				self.model:SetMainAsset(ResPath.GetSpiritModel(spirit_cfg.res_id))
			end
			self.res_id = spirit_cfg.res_id
		end
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], self.res_id, DISPLAY_PANEL.PROP_TIP)
		self.display.ui3d_display:ResetRotation()
		self:SetModleRestAni()
	end
end

function SpiritSoulView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.model then
					self.model:SetTrigger(ANIMATOR_PARAM.REST)
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function SpiritSoulView:Flush()

	self:SetSoulPoolItemData()

	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local slot_soul_info = SpiritData.Instance:GetSpiritSlotSoulInfo()
	if slot_soul_info and next(slot_soul_info) then
		local bit_list = bit:d2b(slot_soul_info.slot_activity_flag)
		for k, v in pairs(self.dress_soul_items) do		
			local id = slot_soul_info.slot_list[k - 1].id or -1
			local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(id, slot_soul_info.slot_list[k - 1].level)
			local data = {}
			data.is_lock = (bit_list and bit_list[32 - k] or 0) ~= 1
			data.show_level = (slot_soul_info.slot_list[k - 1] and slot_soul_info.slot_list[k - 1].level or 0) > 0
			data.level = slot_soul_info.slot_list[k - 1].level or 0
			if attr_cfg ~= nil and soul_bag_info and soul_bag_info.hunshou_exp and slot_soul_info.slot_list[k - 1].exp then
				data.show_redpoint = soul_bag_info.hunshou_exp > attr_cfg.exp - slot_soul_info.slot_list[k - 1].exp
			else
				data.show_redpoint = false
			end
			v:SetData(data)

			if not v:GetEffectId() or v:GetEffectId() ~= id then
				v:LoadEffect(id)
			end
			v:ListenClick(BindTool.Bind(self.OnClickSlotSoul, self, k - 1, data.is_lock))
		end
	else
		for k, v in pairs(self.dress_soul_items) do
			local data = {}
			data.is_lock = true
			data.show_redpoint = false
			data.level = 0
			v:SetData(data)
			v:LoadEffect(-2)
		end
	end
	self.storage_exp:SetValue(soul_bag_info and soul_bag_info.hunshou_exp or 0)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.show_get_redpoint:SetValue(vo.hunli >= 50000)
	self:FlushBagView()
	self:SetItemColor()
	self:SetCostHunli()
	self:FlushSlotSoulTip()
	self:SetModel()
	if soul_bag_info.notify_reason == LIEMING_BAG_NOTIFY_REASON.LIEMING_BAG_NOTIFY_REASON_BAG_MERGE then
		self:JumpToPage()
	end

	local zhanli = 0
	for k,v in pairs(slot_soul_info.slot_list) do
		local cfg = SpiritData.Instance:GetSoulAttrCfg(v.id, v.level)
		local soul_cfg = SpiritData.Instance:GetSpiritSoulCfg(v.id)
		if cfg then
			local cap_table = {}
			cap_table[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]] = cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]]
			zhanli = zhanli + CommonDataManager.GetCapabilityCalculation(cap_table)
		end
	end
	self.total_zhanli:SetValue(zhanli)
end

-- 3个长度的命魂格子组，在命魂背包
SpiritSoulItemGroup = SpiritSoulItemGroup or BaseClass(BaseRender)

function SpiritSoulItemGroup:__init(instance)
	self.items = {
		SpiritSoulItem.New(self:FindObj("SoulItem1")),
		SpiritSoulItem.New(self:FindObj("SoulItem2")),
		SpiritSoulItem.New(self:FindObj("SoulItem3")),
	}
end

function SpiritSoulItemGroup:__delete()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function SpiritSoulItemGroup:ListenClick(i, handler)
	self.items[i]:ListenClick(handler)
end

function SpiritSoulItemGroup:SetData(i, data)
	self.items[i]:SetData(data)
end

function SpiritSoulItemGroup:IsDestroyEffect(i, enable)
	self.items[i]:IsDestroyEffect(enable)
end

function SpiritSoulItemGroup:GetData(i)
	return self.items[i]:GetData()
end


-- 6个长度的命魂格子组，在命魂获取面板
SpiritSoulItemGroupSixLengt = SpiritSoulItemGroupSixLengt or BaseClass(BaseRender)

function SpiritSoulItemGroupSixLengt:__init(instance)
	self.items = {
		SpiritSoulItem.New(self:FindObj("SoulItem1")),
		SpiritSoulItem.New(self:FindObj("SoulItem2")),
		SpiritSoulItem.New(self:FindObj("SoulItem3")),
		SpiritSoulItem.New(self:FindObj("SoulItem4")),
		SpiritSoulItem.New(self:FindObj("SoulItem5")),
		SpiritSoulItem.New(self:FindObj("SoulItem6")),
	}
end

function SpiritSoulItemGroupSixLengt:__delete()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function SpiritSoulItemGroupSixLengt:ListenClick(i, handler)
	self.items[i]:ListenClick(handler)
end

function SpiritSoulItemGroupSixLengt:SetItemActive(i, enable)
	self.items[i]:SetActive(enable)
end

function SpiritSoulItemGroupSixLengt:SetData(i, data)
	self.items[i]:SetData(data, false, true)
end

function SpiritSoulItemGroupSixLengt:IsDestroyEffect(i, enable)
	self.items[i]:IsDestroyEffect(enable)
end

function SpiritSoulItemGroupSixLengt:GetData(i)
	return self.items[i]:GetData()
end


-- 穿着的命魂格子
SpiritDressSoulItem = SpiritDressSoulItem or BaseClass(BaseRender)

function SpiritDressSoulItem:__init(instance)
	self.level = self:FindVariable("Level")
	self.show_level = self:FindVariable("ShowLevel")
	self.show_lock = self:FindVariable("ShowLock")
	self.show_redpoint = self:FindVariable("ShowRedpoint")
	self.effect = nil
	self.is_load = false
	self.is_stop_load_effect = false
end

function SpiritDressSoulItem:__delete()
	self.is_load = nil
	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	end
	self.id = nil
end

function SpiritDressSoulItem:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end

function SpiritDressSoulItem:SetData(data)
	self.level:SetValue(data.level)
	self.show_level:SetValue(data.show_level)
	self.show_lock:SetValue(data.is_lock)
	self.show_redpoint:SetValue(data.show_redpoint)
end

function SpiritDressSoulItem:LoadEffect(id)
	self.id = id
	local cfg = SpiritData.Instance:GetSpiritSoulCfg(id)

	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	elseif self.is_load and id < 0 then
		self.is_stop_load_effect = true
	end

	if id == GameEnum.HUNSHOU_EXP_ID then
		cfg = {name = Language.JingLing.ExpHun, hunshou_color = 1, hunshou_effect = "minghun_g_01"}
	end
	if cfg then
		if cfg.hunshou_effect and not self.effect and not self.is_load then
			self.is_load = true

			PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/" .. string.lower(cfg.hunshou_effect) .. "_prefab", cfg.hunshou_effect), function (prefab)
				if not prefab then return end

				if self.is_stop_load_effect then
					self.is_stop_load_effect = false
					return
				end

				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.root_node.transform, false)
				self.effect = obj.gameObject
				self.is_load = false
			end)
		end
	end
end

function SpiritDressSoulItem:GetEffectId()
	return self.id
end