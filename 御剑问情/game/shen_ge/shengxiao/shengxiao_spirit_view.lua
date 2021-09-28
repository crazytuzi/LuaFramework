ShengXiaoSpiritView = ShengXiaoSpiritView or BaseClass(BaseRender)

function ShengXiaoSpiritView:__init()
	--获取组件
	self.bless = self:FindVariable("bless")
	self.bless_val = self:FindVariable("bless_val")
	self.shenxiao_img = self:FindVariable("shenxiao_img")
	self.now_chapter = self:FindVariable("now_chapter")
	self.xingtu_attr = self:FindVariable("xingtu_attr")
	self.next_xingtu_attr = self:FindVariable("next_xingtu_attr")
	self.show_attr = self:FindVariable("show_attr")
	self.stuff_num = self:FindVariable("stuff_num")
	self.zhan_dou_li = self:FindVariable("zhan_dou_li")
	self.show_get_Btn = self:FindVariable("show_get_Btn")
	self.cur_name = self:FindVariable("cur_name")
	self.cur_level = self:FindVariable("cur_level")
	self.show_xingtuattr = self:FindVariable("show_xingtuattr")

	self.slider = self:FindObj("slider")				--进度条 Obj
	self.last_bless_val = self.slider.slider.value
	self.now_att = {}
	self.next_att = {}
	for i = 1, 4 do
		self.now_att[i] = self:FindVariable("now_att_" .. i)
		self.next_att[i] = self:FindVariable("next_att_" .. i)
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))

	self.image_postion_list = {}
	self.effect_postion_list = {}
	for i = 1, 8 do
		self.image_postion_list[i] = self:FindVariable("item_image_" .. i)
		self.effect_postion_list[i] = self:FindVariable("item_effect_" .. i)
	end

	self.center_display = self:FindObj("center_display")
	self.point_effect_list = {}
	self.point_effect_root = self:FindObj("point_effect")

	self:ListenEvent("OnPageUp", BindTool.Bind(self.OnPageUp, self))
	self:ListenEvent("OnPageDown", BindTool.Bind(self.OnPageDown, self))
	self:ListenEvent("OnClickUplevel", BindTool.Bind(self.OnClickUplevel, self))
	self:ListenEvent("OnClickTip", BindTool.Bind(self.OnClickTip, self))

	self.attr_cell_list = {}
	self.attr_list = self:FindObj("attr_list")
	local list_delegate = self.attr_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfAttrCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)

	self.cur_select = self:SetOpenSelect()
	self.last_select = self.cur_select
	self.last_level = nil
	-- self:FlushFlyAni(self.cur_select)
	self:FlushItemImage()
	self:FlushAll()

	--自动购买Toggle
	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
	self:ListenEvent("AutoBuyChange", BindTool.Bind(self.AutoBuyChange, self))
	self.is_auto_buy_stone = 0

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function ShengXiaoSpiritView:__delete()
	self.bless = nil
	self.bless_val = nil
	self.shenxiao_img = nil
	self.center_display = nil
	self.now_chapter = nil
	self.xingtu_attr = nil
	self.next_xingtu_attr = nil
	self.show_attr = nil
	self.stuff_num = nil
	self.zhan_dou_li = nil
	self.cur_name = nil
	self.cur_level = nil
	self.slider = nil
	self.show_xingtuattr = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for k,v in pairs(self.image_postion_list) do
		self.image_postion_list[k] = nil
	end

	for k,v in pairs(self.effect_postion_list) do
		self.effect_postion_list[k] = nil
	end

	self.cur_select = nil
	self.is_auto_buy_stone = 0

	self:DelePointEffectList()

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ShengXiaoSpiritView:OpenCallBack()
	self.is_first = true
end

function ShengXiaoSpiritView:ItemDataChangeCallback(item_id)
	if item_id == COMMON_CONSTS.SPIRIT_ID then
		self:FlushAll()
	end
end

function ShengXiaoSpiritView:SetOpenSelect()
	local info = ShengXiaoData.Instance:GetXingLingAllInfo()
	local max_select = self:SetMaxSelect()
	local now_chatpter = 1
	for k, v in ipairs(info.xingling_list) do
		if v.level < 39 or max_select <= k then
			return k
		end
	end
end

function ShengXiaoSpiritView:SetMaxSelect()
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	local max_select = 1
	if max_chatpter > 1 then
		max_select = max_chatpter - 1
	end
	if max_chatpter == 5 and ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		max_select = 5
	end
	return max_select
end

function ShengXiaoSpiritView:OnPageUp()
	if self.cur_select <= 1 then return end
	self.cur_select = self.cur_select - 1
	self:OnBtnRecharge(self.cur_select, false)
end

function ShengXiaoSpiritView:OnPageDown()
	local max_select = self:SetMaxSelect()
	if self.cur_select >= GameEnum.TIAN_XIANG_SPIRIT_CHAPTER_NUM then
		return
	end
	if self.cur_select >= max_select and self.cur_select ~= 5 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.LastChapter)
		return
	end
	self.cur_select = self.cur_select + 1
	self:OnBtnRecharge(self.cur_select, false)
end

function ShengXiaoSpiritView:OnBtnRecharge(index, is_click)
	self.cur_select = index
	-- self:FlushFlyAni(self.cur_select)
	self:FlushItemImage()
	self:FlushAll()
end

function ShengXiaoSpiritView:FlushAll()
	local info = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select)
	local chapter_info = ShengXiaoData.Instance:GetChapterAttrByChapter(self.cur_select)
	self.cur_name:SetValue(chapter_info.xingling_name)
	local level = info.level
	self.cur_level:SetValue(level + 1)
	local cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, level)
	local item_num = ItemData.Instance:GetItemNumInBagById(cfg.uplevel_stuff_id)
	if item_num == 0 then
		item_num = string.format(Language.Common.ShowRedNum, item_num)
	else
		item_num = string.format(Language.Common.ShowBlueNum, item_num)
	end
	local max_chatpter = ShengXiaoData.Instance:GetMaxChapter()
	local now_chatpter = 1
	if max_chatpter > 1 then
		now_chatpter = max_chatpter - 1
	end
	if max_chatpter == 5 and ShengXiaoData.Instance:GetIsFinishAll() == 1 then
		now_chatpter = 5
	end
	local total_cap = 0
	local num = ShengXiaoData.Instance:GetChapterActiveNum(self.cur_select)
	-- if max_chatpter > 1 then
	-- 	num = 3
	-- end
	local one_combine_cfg = ShengXiaoData.Instance:GetCombineCfgByIndex((self.cur_select - 1) * 3)
	local capability = CommonDataManager.GetCapability(one_combine_cfg)
	local bass_zhan_li = CommonDataManager.GetCapability(cfg)
	local add_zhan_li = math.floor(capability * (cfg.xingtu_add_prob / 10000) * num)
	local xingtu_add_prob = cfg.xingtu_add_prob / 100
	if level == -1 then
		bass_zhan_li = 0
		xingtu_add_prob = 0
	end
	self.zhan_dou_li:SetValue(bass_zhan_li + add_zhan_li)
	self.xingtu_attr:SetValue(xingtu_add_prob)
	self.show_attr:SetValue(info.level < 39)
	local bless = info.bless
	local bless_val = bless / cfg.bless_val_limit
	local item_cfg = {}
	if info.level < 39 then
		local next_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, level + 1)
		item_cfg = ShengXiaoData.Instance:GetShowItems(self.cur_select - 1, level + 1)
		bless_val = bless / next_cfg.bless_val_limit
		bless = bless .. " / " .. next_cfg.bless_val_limit
		self.next_xingtu_attr:SetValue(next_cfg.xingtu_add_prob / 100 - xingtu_add_prob)
		self.stuff_num:SetValue("(" .. item_num .. " / " .. next_cfg.uplevel_stuff_num .. ")")
		self.show_get_Btn:SetValue(true)
		self.show_xingtuattr:SetValue(true)
	else
		item_cfg = ShengXiaoData.Instance:GetShowItems(self.cur_select - 1, level)
		bless = Language.Common.YiMan
		bless_val = 1
		self.stuff_num:SetValue(string.format(Language.Common.ShowBlackStr, Language.ShengXiao.MaxSpirit))
		self.show_get_Btn:SetValue(false)
		self.show_xingtuattr:SetValue(false)
	end
	self.item_cell:SetData(item_cfg)
	self.bless:SetValue(bless)

	--进度条控制
	if not self.last_level then self.last_level = level end
	if self.last_bless_val > bless_val then
		if not(self.last_level ~= level and self.last_select == self.cur_select) then --如果不是刚升级
			self.slider.slider.value = 0 
		end
	end
	if self.is_first then
		self.bless_val:InitValue(bless_val)
		self.is_first = false
	else
		self.bless_val:SetValue(bless_val)
	end
	self.last_bless_val = bless_val
	self.last_select = self.cur_select
	self.last_level = level


	local bundle, asset = nil, nil
	bundle1, asset1 = ResPath.GetShenXiaoRes(self.cur_select)
	self.shenxiao_img:SetAsset(bundle1, asset1)
	self.now_chapter:SetValue(self.cur_select.. " / ".. now_chatpter)

	self:FlushItemImage()
	self.attr_list.scroller:ReloadData(0)
end

function ShengXiaoSpiritView:GetNumberOfAttrCells()
	return 3
end

function ShengXiaoSpiritView:RefreshAttrCell(cell, data_index)
	data_index = data_index + 1
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = AttrItem.New(cell.gameObject)
		self.attr_cell_list[cell] = attr_cell
	end

	local cur_level = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select).level
	local cur_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, cur_level)
	local one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)

	-- local show_attr = CommonDataManager.GetAttrNameAndValueByClass(one_level_attr)
	local new_show_attr = CommonDataManager.GetNewAttrNameAndValueByClass(one_level_attr)
	local data = {}
	if cur_level < 0 then
		cur_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, 0)
		one_level_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)
		new_show_attr = CommonDataManager.GetNewAttrNameAndValueByClass(one_level_attr)
		data = new_show_attr[data_index]
		data.value = 0
	else
		data = new_show_attr[data_index]
	end

	data.show_add = cur_level < 39
	if cur_level < 39 then
		local next_equip_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, cur_level + 1)
		local attr_cfg = CommonDataManager.GetAttributteNoUnderline(next_equip_cfg)
		local next_show_attr = CommonDataManager.GetNewAttrNameAndValueByClass(attr_cfg)
		data.add_attr = next_show_attr[data_index].value - data.value
	else
		data.add_attr = 0
	end
	attr_cell:SetData(data)
end

function ShengXiaoSpiritView:OnClickUplevel()
	local cur_level = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select).level
	if cur_level < 39 then
		local cur_cfg = ShengXiaoData.Instance:GetXingLingCfg(self.cur_select - 1, cur_level + 1)
		local bag_num = ItemData.Instance:GetItemNumInBagById(cur_cfg.uplevel_stuff_id)
		if bag_num >= cur_cfg.uplevel_stuff_num then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGLING, self.cur_select - 1, self.is_auto_buy_stone)
		elseif self.auto_buy_toggle.isOn then
			ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_XINGLING, self.cur_select - 1, self.is_auto_buy_stone)
		else
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			--勾选自动购买
			if is_buy_quick then
				self.auto_buy_toggle.isOn = true
				self.is_auto_buy_stone = 1
			end
			end
			local shop_item_cfg = ShopData.Instance:GetShopItemCfg(cur_cfg.uplevel_stuff_id)
			if cur_cfg.uplevel_stuff_num - bag_num == nil then
				MarketCtrl.Instance:SendShopBuy(cur_cfg.uplevel_stuff_id, 999, 0, 1)
			else
				TipsCtrl.Instance:ShowCommonBuyView(func, cur_cfg.uplevel_stuff_id, nil, cur_cfg.uplevel_stuff_num - bag_num)
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.Max)
	end
end

function ShengXiaoSpiritView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(181)
end

--自动购买强化石Toggle点击时
function ShengXiaoSpiritView:AutoBuyChange(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

-- 升级时刷新特效
function ShengXiaoSpiritView:FlushEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function ShengXiaoSpiritView:DelePointEffectList()
	if self.point_effect_list then
		for k,v in pairs(self.point_effect_list) do
			GameObject.Destroy(v)
			v = nil
		end
	end
	self.point_effect_list = {}
end

function ShengXiaoSpiritView:FlushFlyAni(index)
	if self.tweener1 then
		self.tweener1:Pause()
	end

	self:DelePointEffectList()
	self.center_display.rect:SetLocalPosition(0, 0, 0)
	self.center_display.rect:SetLocalScale(0, 0, 0)

	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(1, 1, 1)
	self.tweener1 = self.center_display.rect:DOAnchorPos(target_pos, 0.7, false)
	self.tweener1 = self.center_display.rect:DOScale(target_scale, 0.7)
	self.tweener1:OnComplete(BindTool.Bind(self.FlushPointEffect, self))
end

function ShengXiaoSpiritView:FlushPointEffect()
	local point_effect_pos_cfg = ShengXiaoData.Instance:GetXinglingPointEffectCfg(self.cur_select)
	if not next(point_effect_pos_cfg) then return end
	for k,v in pairs(point_effect_pos_cfg) do
		local bundle, asset = "effects/prefabs", "UI_guangdian1_01"
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

function ShengXiaoSpiritView:FlushItemImage()
	local level = ShengXiaoData.Instance:GetXingLingInfo(self.cur_select).level
	if nil ~= level then
		level = level + 1
		local whole = math.floor(level / 8)
		local more = level % 8
		for i = 1, 8 do
			local key = whole
			if more >= i then
				key = whole + 1
			end
			if key == 0 then
				self.image_postion_list[i]:SetValue(true)
			else
			-- local bundle2, asset2 = ResPath.GetRuiShouImage(key)
			local bundle2, asset2 = ResPath.GetXingLingEffect(key)
			self.effect_postion_list[i]:SetAsset(bundle2, asset2)
			self.image_postion_list[i]:SetValue(false)
			end
		end
	end
end

