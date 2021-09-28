ShengXiaoUpLevelView = ShengXiaoUpLevelView or BaseClass(BaseRender)
local EFFECT_CD = 1

function ShengXiaoUpLevelView:__init()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
  	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)

	--获取组件
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("StuffCell"))
	self.cur_star_name = self:FindVariable("cur_star_name")
	self.lbl_cost_desc = self:FindVariable("lbl_cost_desc")
	self.cur_star_level = self:FindVariable("cur_star_level")
	self.btn_text = self:FindVariable("btn_text")
	self.power = self:FindVariable("Power")
	self.big_pic_path = self:FindVariable("big_pic_path")
	self.can_level_up = self:FindVariable("can_level_up")
	self.total_power = self:FindVariable("total_power")
	--获取生肖名称绑定变量
	for i = 1,12 do 
		local shengxiao_name = self:FindVariable("shengxiao_name_"..i)
		--根据配置表设置名称
		local cfg =  ShengXiaoData.Instance:GetZodiacInfoByIndex(i, 1)
		if cfg then 
			shengxiao_name:SetValue(cfg.name)
		end
	end
	--自动购买Toggle
	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
	self:ListenEvent("AutoBuyChange", BindTool.Bind(self.AutoBuyChange, self))
	self.is_auto_buy_stone = 0

	self.effect_cd = 0
	self.boom_effect_index = 0
	self.old_zodiac_progress = 0

	self.effect_root = self:FindObj("EffectRoot")

	self.point_effect_list = {}
	self.point_effect_root = self:FindObj("PointEffect")

	self.attr_cell_list = {}
	self.attr_list = self:FindObj("attr_list")
	local list_delegate = self.attr_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.button = self:FindObj("button")
	self.txt_level_up = self:FindObj("txt_level_up")

	self.show_up_list = {}
	self.star_level_list = {}
	self.toggle_list = {}

	--装备位置列表
	self.equip_position_list = {}
	for i = 1, 12 do
		self:ListenEvent("ClickStar" .. i, BindTool.Bind(self.ClickItem, self, i))
		self:ListenEvent("ClickLock" .. i, BindTool.Bind(self.ClickLock, self, i))
		self.show_up_list[i] = self:FindVariable("show_up_" .. i)
		self.star_level_list[i] = self:FindVariable("star_level_" .. i)
		self.toggle_list[i] = self:FindObj("item" .. i).toggle

		local equip_obj = self:FindObj("item" .. i)
		local position = equip_obj.rect.position
		table.insert(self.equip_position_list, position)
	end

	self.center_display = self:FindObj("center_display")
	self.Bg = self:FindObj("Bg")

	self.show_lock_list = {}
	self.show_lock_effect_list = {}
	self.boom_effect_list = {}
	for i = 1, 12 do
		self.show_lock_list[i] = self:FindVariable("show_lock_" .. i)
		self.show_lock_effect_list[i] = self:FindVariable("show_lock_effect" .. i)
		self.boom_effect_list[i] = self:FindObj("Effect" .. i)
		self.boom_effect_list[i]:SetActive(false)
	end

	self.img_bg = self:FindObj("img_bg")

	self:ListenEvent("ClickLevelUp", BindTool.Bind(self.ClickLevelUp, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
--	self:ListenEvent("OnClickMiji", BindTool.Bind(self.OnClickMiji, self))
	self:ListenEvent("OpenAtrrTips", BindTool.Bind(self.OpenAtrrTips, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))

	self.select_index = ShengXiaoData.Instance:GetUplevelIndex()
	self.cur_level = 0
	self:FlushFlyAni(self.select_index)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.show_enter_effect = self:FindVariable("ShowEnterEffect")
	self.enter_btn_detail = self:FindVariable("YiJiEnterBtnDetail")
end

function ShengXiaoUpLevelView:__delete()
	if nil ~= self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if self.tweener1 then
		self.tweener1:Pause()
		self.tweener1 = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self:DelePointEffectList()
	if ShengXiaoData.Instance then
		ShengXiaoData.Instance:SetUplevelIndex(1)
	end

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end

	self:RemoveDelayTime()
	self.is_auto_buy_stone = 0
end

function ShengXiaoUpLevelView:ItemDataChangeCallback(item_id)
	if item_id == 27584 then
		self:FlushAll()
	end
end

--自动购买强化石Toggle点击时
function ShengXiaoUpLevelView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ShengXiaoUpLevelView:OpenAtrrTips()
	local attr_list, is_show_cur, is_show_next = ShengXiaoData.Instance:GetTotalAttrListAndAttrState()
	local cur_attr_list = nil
	local next_attr_list = nil

	if is_show_cur then
		cur_attr_list = attr_list
		if is_show_next then
			next_attr_list = ShengXiaoData.Instance:GetTotalAttrListAndAttrState(true)
		end
	else
		next_attr_list = attr_list
	end
	TipsCtrl.Instance:ShowSuitAttrView(cur_attr_list, next_attr_list, ShengXiaoData.Instance:GetTotalLevel())
end

function ShengXiaoUpLevelView:GetNumberOfCells()
	return 3
end

function ShengXiaoUpLevelView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end

	local cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index)
	local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, cur_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
	local data = {}
	if cur_level == 0 then
		cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, 1)
		one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
		show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
		data = show_attr[data_index]
		data.value = 0
	else
		data = show_attr[data_index]
	end
	data.show_add = cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT
	if cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
		local next_equip_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, cur_level + 1)
		local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
		local next_show_attr = CommonDataManager.GetAttrNameAndValueByClass(attr_cfg)
		data.add_attr = next_show_attr[data_index].value - data.value
	else
		data.add_attr = 0
	end
	attr_cell:SetData(data)
end

function ShengXiaoUpLevelView:ClickItem(index)
	if index == self.select_index then
		return
	end
	self.select_index = index
	self:FlushRightInfo()
	self:FlushFlyAni(index)
end

function ShengXiaoUpLevelView:ClickLock(index)
	if ShengXiaoData.Instance:GetCurCanUpByIndex(index) then
		ShengXiaoCtrl:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_UNLOCK_REQ)
		self.boom_effect_index = index
		self.old_zodiac_progress = ShengXiaoData.Instance:GetZodiacProgress()
	else
		local cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(index, 1)
		local lase_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(index - 1, 1)
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.ShengXiao.OpenNext, lase_cfg.name, cfg.level_limit))
	end
end

function ShengXiaoUpLevelView:FlushPointEffect()
	local point_effect_pos_cfg = ShengXiaoData.Instance:GetPointEffectCfg(self.select_index)
	if not next(point_effect_pos_cfg) then return end
	for k,v in pairs(point_effect_pos_cfg) do
		local bundle, asset = "effects2/prefab/ui_x/ui_guangdian1_prefab", "UI_guangdian1"
		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
			if prefab then
				local obj = GameObject.Instantiate(prefab)
				PrefabPool.Instance:Free(prefab)
				local transform = obj.transform
				transform:SetParent(self.point_effect_root.transform, false)
				local tttt = transform:GetComponent(typeof(UnityEngine.RectTransform))
				tttt.anchoredPosition = Vector2(v.x, v.y)
				self.point_effect_list[k] = obj.gameObject
			end
		end)
	end

end

--刷新右边面板
function ShengXiaoUpLevelView:FlushRightInfo()
	self.can_level_up:SetValue(true)
	self.big_pic_path:SetAsset(ResPath.GetShengXiaoBigIcon(self.select_index))
	self.cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index)
	self.btn_text:SetValue(self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT and Language.ShengXiao.UpGrade or Language.ShengXiao.btnMaxLevel)
	self.button.grayscale.GrayScale = self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT and 0 or 255
	self.txt_level_up.grayscale.GrayScale = self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT and 0 or 255
	self.can_level_up:SetValue(self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT)

	local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level)
	self.stuff_cell:SetData({item_id = cur_cfg.item_id})
	self.cur_star_name:SetValue(cur_cfg.name)
	self.cur_star_level:SetValue(self.cur_level)

	if self.cur_level >= GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
		self.lbl_cost_desc:SetValue(string.format(Language.Common.ShowBlackStr, Language.ShengXiao.Max))
	else
		local next_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level + 1)
		local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.item_id)
		local item_name = ItemData.Instance:GetItemName(cur_cfg.item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(cur_cfg.item_id)
		local item_color = SOUL_NAME_COLOR[item_cfg.color] or TEXT_COLOR.WHITE
		local cost_desc = string.format(Language.ShengXiao.StuffDecs, bag_num, next_cfg.expend)
		local cost_desc1 = string.format(Language.ShengXiao.StuffDecs2, item_color, bag_num, next_cfg.expend)
		self.lbl_cost_desc:SetValue(bag_num >= next_cfg.expend and cost_desc or cost_desc1)

		if self.select_index > 1 then
			local level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index)
			if level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
				local cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, level + 1)
				local last_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index - 1, 1)
				local limit_level = string.format(Language.ShengXiao.Levellimit, last_cfg.name, cfg.level_limit)
				local last_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(self.select_index - 1)
				if last_level < cfg.level_limit then
					self.lbl_cost_desc:SetValue(limit_level)
					--self.can_level_up:SetValue(false)     --升级按钮置灰
					--self.button.grayscale.GrayScale = 255
					--self.txt_level_up.grayscale.GrayScale = 255
				end
			end
		end
	end

	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
	local one_level_power = CommonDataManager.GetCapability(one_level_attr)
	self.power:SetValue(one_level_power)
	self.attr_list.scroller:ReloadData(0)
end

function ShengXiaoUpLevelView:FlushLeftInfo()
	local level_data_list = ShengXiaoData.Instance:GetZodiacLevelList()
	for k,v in pairs(level_data_list) do
		self.star_level_list[k]:SetValue(v)
		self.toggle_list[k].isOn = k == self.select_index
	end
	for k,v in pairs(self.show_up_list) do
		v:SetValue(ShengXiaoData.Instance:GetCanUpLevelRemindByIndex(k))
	end
	for k,v in pairs(self.show_lock_list) do
		v:SetValue(not ShengXiaoData.Instance:GetCurCanUpByIndex(k))
	end

	local zodiac_progress = ShengXiaoData.Instance:GetZodiacProgress()
	for k,v in pairs(self.show_lock_effect_list) do
		v:SetValue(ShengXiaoData.Instance:GetCurCanUpByIndex(k) and k > zodiac_progress)
	end
	self.img_bg.image.fillAmount = (ShengXiaoData.Instance:GetShowRate() - 2) / 12
	if ShengXiaoData.Instance:GetCurCanUpByIndex(12) then
		self.img_bg.image.fillAmount = 1
	end
	if self.boom_effect_index > 0 then
		if self.old_zodiac_progress < zodiac_progress then
			self.old_zodiac_progress = zodiac_progress
			local index = self.boom_effect_index
			self.boom_effect_index = 0
			self.boom_effect_list[index]:SetActive(true)
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self.boom_effect_list[index]:SetActive(false) end, 0.5)
		end
	end
	self:CalculateTotalPower()
	self:SetRelicInfo()
end
--计算总战力
function  ShengXiaoUpLevelView:CalculateTotalPower()
	local totalPower = 0
	for i = 1,12 do
		local cur_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(i)
		local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(i, cur_level)
		local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
		local one_level_power = CommonDataManager.GetCapability(one_level_attr)
		totalPower = totalPower + one_level_power
	end
	self.total_power:SetValue(totalPower)
end

function ShengXiaoUpLevelView:ActivityCallBack(activity_type)
	if activity_type ~= ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI then
		return
	end
	self:SetRelicInfo()
end

function ShengXiaoUpLevelView:SetRelicInfo()
	self.show_enter_effect:SetValue(ShengXiaoData.Instance:GetXingzuoYijiRedPoint())

	local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum()
	local max_count = RelicData.Instance:GetOneDayGatherBoxMaxNum()
    local cfg = RelicData.Instance:GetRelicCfg().other[1]
	self.enter_btn_detail:SetValue(is_open and Language.Boss.HasRefresh or string.format(Language.ShengXiao.FlushTime, (cfg.common_box_gather_limit - gahter_count)))
end

function ShengXiaoUpLevelView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(175)
end


--function ShengXiaoUpLevelView:OnClickMiji()
--	local min_level = ShengXiaoData.Instance:GetZodiacLevelByIndex(1)
--	if min_level > 0 then
--		ViewManager.Instance:Open(ViewName.ShengXiaoMijiView)
--	else
--		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ActiveFirst)
--	end
--end

function ShengXiaoUpLevelView:ClickLevelUp()
	if self.cur_level < GameEnum.CHINESE_ZODIAC_LEVEL_MAX_LIMIT then
		local cur_cfg = ShengXiaoData.Instance:GetZodiacInfoByIndex(self.select_index, self.cur_level + 1)
		local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.item_id)
		if bag_num >= cur_cfg.expend then
			ShengXiaoCtrl.Instance:SendPromoteZodiacRequest(self.select_index - 1, self.is_auto_buy_stone)
		elseif self.auto_buy_toggle.isOn then
			ShengXiaoCtrl.Instance:SendPromoteZodiacRequest(self.select_index - 1, self.is_auto_buy_stone)
		else
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				--勾选自动购买
				if is_buy_quick then
					self.auto_buy_toggle.isOn = true
					self.is_auto_buy_stone = 1
				end
			end
			local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.item_id)
			if cur_cfg.expend - bag_num == nil then
				MarketCtrl.Instance:SendShopBuy(cur_cfg.item_id, 999, 0, 1)
			else
				TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.item_id, nil, cur_cfg.expend - bag_num)
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.Max)
	end
	self:ClickLock(self.select_index)  --尝试开启下一个生肖
end

function ShengXiaoUpLevelView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ShengXiaoUpLevelView:ClickEnter()
	local ok_func = function()
		-- if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI) then
		-- 	TipsCtrl.Instance:ShowSystemMsg(Language.ShengXiao.YiJiNoOpen)
		-- 	return
		-- end
		ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
		ViewManager.Instance:CloseAll()
	end
	TipsCtrl.Instance:ShowCommonExplainView(Language.ShengXiao.XingZuoYiJiExplain, ok_func, "enter_xingzuoyiji",false)
end

function ShengXiaoUpLevelView:FlushAll()
	self:FlushLeftInfo()
	self:FlushRightInfo()
end

-- 升级时刷新特效
function ShengXiaoUpLevelView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ShengXiaoUpLevelView:DelePointEffectList()
	if self.point_effect_list then
		for k,v in pairs(self.point_effect_list) do
			GameObject.Destroy(v)
			v = nil
		end
	end
	self.point_effect_list = {}
end

function ShengXiaoUpLevelView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end
	self:DelePointEffectList()
	local position = self.equip_position_list[index]


	--获取指引按钮的屏幕坐标
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, position)

	--转换屏幕坐标为本地坐标
	local rect = self.Bg:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))


	self.center_display.rect:SetLocalPosition(local_pos_tbl.x, local_pos_tbl.y-10, 0)
	self.center_display.rect:SetLocalScale(0, 0, 0)

	local target_pos = {x = 0, y = -10, z = 0}
	local target_scale = Vector3(1, 1, 1)
	self.tweener1 = self.center_display.rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.center_display.rect:DOScale(target_scale, 0.7)
	--self.tweener1:OnComplete(BindTool.Bind(self.FlushPointEffect, self))
end


---------------------AttrItem--------------------------------
AttrItem = AttrItem or BaseClass(BaseCell)

function AttrItem:__init()
	self.value = self:FindVariable("value")
	self.add_attr = self:FindVariable("add_attr")
	self.show_add = self:FindVariable("show_add")
	self.attr_name = self:FindVariable("attr_name")
	self.attr_img = self:FindVariable("attr_img")
end

function AttrItem:__delete()
end
function AttrItem:OnFlush()
	if self.data == nil then return end
	self.value:SetValue(self.data.value)
	self.add_attr:SetValue(self.data.add_attr)
	self.show_add:SetValue(self.data.show_add)
	self.attr_name:SetValue(self.data.attr_name)
	self.attr_img:SetAsset("uis/images_atlas", Language.Forge.AttImageTab[self.data.attr_name])
end