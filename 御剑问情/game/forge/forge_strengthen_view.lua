--装备-强化
ForgeStrengthen = ForgeStrengthen or BaseClass(ForgeBaseView)

function ForgeStrengthen:__init()
	-- print_error("ForgeStrengthen-----__init")
	ForgeStrengthen.Instance = self
	--两个效果格子
	self.current_effect_obj = self:FindObj("CurrentEffect")
	self.current_effect = StrengthEffectCell.New(self.current_effect_obj)
	self.next_effect = StrengthEffectCell.New(self:FindObj("NextEffect"),"strengthen_level")
	--成功率
	self.success_rate = self:FindVariable("SuccessRate")
	self.xianzun_add = self:FindVariable("xianzun_add")
	--幸运符
	self.lucky_item_number = self:FindVariable("LuckyItemNumber")
	self.need_lucky_item = self:FindVariable("NeedLuckyItem")
	self.enough_lucky_item = self:FindVariable("EnoughLuckyItem")
	self.va_use_lucky_item = self:FindVariable("UseLuckyItem")
	self.lucky_item_icon = self:FindVariable("LuckyItemIcon")

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self:FindObj("CurEquipCell"))

	--强化按钮
	self:ListenEvent("StrengthenClick", BindTool.Bind(self.OnClickStrengthen, self))
	-- self:ListenEvent("OneKeyStrength", BindTool.Bind(self.OnClickOneKeyStrengthen, self))
	--自动购买Toggle
	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle
	self:ListenEvent("AutoBuyChange", BindTool.Bind(self.AutoBuyChange, self))
	-- 绑定滚动条点击事件
	self.mother_view:SetClickCallBack(TabIndex.forge_strengthen, BindTool.Bind(self.OpenCallback, self))
	--全身强化Tips
	-- self.total_strength_tips = FullStrengthTips.New(self:FindObj("FullStrengthTips"))
	-- self.total_strength_tips:SetActive(false)
	self:ListenEvent("OpenTotalStrenthTips", BindTool.Bind(self.OpenTotalStrenthTips, self))
	-- self:ListenEvent("CloseTotalStrengthTips", BindTool.Bind(self.CloseTotalStrengthTips, self))
	self:ListenEvent("LuckyItemClick", BindTool.Bind(self.LuckyItemClick, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))
	self:ReSetFlag()
	-- self:AutoBuy()
	--满级和普通时的位置
	-- self.normal_pos = self:FindObj("NormalPos")
	-- self.max_level_pos = self:FindObj("MaxLevelPos")

	--self.root_node:SetActive(false)

	--模型展示
	self.model_display = self:FindObj("ModelDisplay")
	if nil ~= self.model_display then
		self.model = RoleModel.New()
		self.model:SetDisplay(self.model_display.ui3d_display)
	end

	self.qianghua_effect = self:FindObj("QianghuaEffect")
	self.show_qianghua_effect = self:FindVariable("show_qianghua_effect")
	self.show_qianghua_effect:SetValue(false)

	self.effect_obj = nil
	self.is_load_effect = false

	self.model_bg_effect = self:FindObj("ModelBgEffect")
	self.model_glow_effect = self:FindObj("ModelGlowEffect")
	self.equip_bg_effect_obj = nil
	self.equip_glow_effect_obj = nil
	self.color = 0
	self.color_glow = 0
	self.timer = 0
	self.timer_quest = nil
	self.is_auto_buy_stone = 0

	--引导用按钮
	self.btn_strength = self:FindObj("BtnStrength")
	self:OpenCallback()

	--强化成功/失败位置
	self.qhcg_effect = self:FindObj("QhcgEffect")
	--self.qhsb_effect = self:FindObj("QhsbEffect")
end

function ForgeStrengthen:ReSetFlag()
	--是否一键开启一键强化
	self.one_key_strengthen = false
	--隐藏全身强化奖励
	-- self.total_strength_tips:SetActive(false)
	--不使用幸运符
	self.use_lucky_item = 0

end

function ForgeStrengthen:AutoBuy()
	--勾选自动购买
	self.auto_buy_toggle.isOn = true
	self.is_auto_buy_stone = 1
end

function ForgeStrengthen:OpenCallback()
	self.color = 0
	self.color_glow = 0
	self.show_qianghua_effect:SetValue(false)
	self:ReSetFlag()
	self:Flush()
	if self.data and self.data.item_id then
		self:SetEquipModel(self.data)
	end

end

function ForgeStrengthen:__delete()
	self.mother_view = nil
	if nil ~= self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if nil ~= self.current_effect then
		self.current_effect:DeleteMe()
		self.current_effect = nil
	end
	if nil ~= self.next_effect then
		self.next_effect:DeleteMe()
		self.next_effect = nil
	end

	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
	if self.equip_bg_effect_obj then
		GameObject.Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end
	if self.equip_glow_effect_obj then
		GameObject.Destroy(self.equip_glow_effect_obj)
		self.equip_glow_effect_obj = nil
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function ForgeStrengthen:SetNextCfg()
	self.next_cfg = ForgeData.Instance:GetStrengthCfg(self.data, true)

end

function ForgeStrengthen:SetEquipModel(data)
	if data == nil or data.item_id == nil or data.item_id == 0 then
		return
	end
	self.equip_cell:SetData(data)
	self.equip_cell:NotShowStar()
	--设置模型
	-- local model_index = "000" .. data.data_index + 1
	-- local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)

	-- if nil ~= self.model then
		-- self.model:SetMainAsset(ResPath.GetForgeEquipModel(model_index))
		-- self:SetEquipModelBgEffect(item_cfg.color)
		-- self:SetEquipModelGlowEffect(item_cfg.color)
		-- self.model:SetLoadComplete(BindTool.Bind(self.FlushFlyAni, self))
	-- end
end

--模型出场动作
-- function ForgeStrengthen:FlushFlyAni()
	-- if self.tweener then
		-- self.tweener:Pause()
	-- end
	-- self.model_display.rect:SetLocalScale(0, 0, 0)
	-- local target_scale = Vector3(1, 1, 1)
	-- self.tweener = self.model_display.rect:DOScale(target_scale, 0.5)
-- end

function ForgeStrengthen:CloseUpStarView()
	-- if self.tweener then
		-- self.tweener:Pause()
		-- self.tweener = nil
	-- end
end

-- function ForgeStrengthen:SetEquipModelBgEffect(color)
-- 	if self.color ~= color then
-- 		local bundle, asset = ResPath.GetForgeEquipBgEffect(color)
-- 		self.color = color
-- 		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
-- 			if prefab then
-- 				if self.equip_bg_effect_obj  ~= nil then
-- 					GameObject.Destroy(self.equip_bg_effect_obj)
-- 					self.equip_bg_effect_obj = nil
-- 				end
-- 				local obj = GameObject.Instantiate(prefab)
-- 				local transform = obj.transform
-- 				transform:SetParent(self.model_bg_effect.transform, false)
-- 				self.equip_bg_effect_obj = obj.gameObject
-- 				self.color = 0
-- 				PrefabPool.Instance:Free(prefab)
-- 			end
-- 		end)
-- 	end
-- end

-- function ForgeStrengthen:SetEquipModelGlowEffect(color)
-- 	if self.color_glow ~= color then
-- 		local bundle, asset = ResPath.GetForgeEquipGlowEffect(color)
-- 		self.color_glow = color
-- 		PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
-- 			if prefab then
-- 				if self.equip_glow_effect_obj then
-- 					GameObject.Destroy(self.equip_glow_effect_obj)
-- 					self.equip_glow_effect_obj = nil
-- 				end
-- 				local obj = GameObject.Instantiate(prefab)
-- 				local transform = obj.transform
-- 				transform:SetParent(self.model_glow_effect.transform, false)
-- 				self.equip_glow_effect_obj = obj.gameObject
-- 				self.color_glow = 0
-- 				PrefabPool.Instance:Free(prefab)
-- 			end
-- 		end)
-- 	end
-- end

function ForgeStrengthen:Flush()
	self:CommonFlush()
	--幸运符
	if self.data and self.data.item_id then
		self:SetEquipModel(self.data)
	end
	if self.next_cfg == nil then
		--升到满级时
		self.need_lucky_item:SetValue(false)
	else
		if self:GetIsNeedLuckyItem() then
			--需要幸运符"
			self.need_lucky_item:SetValue(true)
			local is_enough = false
			local need_num = 0
			local had_num = 0
			is_enough, had_num, need_num = self:GetIsEnoughLuckyItem()
			if is_enough then
				--可用足够时
				self.enough_lucky_item:SetValue(true)
				self:SetLuckyItemNum(need_num, had_num)
			else
				--可用但不足够时
				self:SetLuckyItemNum(need_num, had_num)
				self.enough_lucky_item:SetValue(false)
				self.use_lucky_item = 0
			end
			--是否使用中
			self.va_use_lucky_item:SetValue(self.use_lucky_item == 1)
		else
			-- print("不需要幸运符")
			self.need_lucky_item:SetValue(false)
		end
	end
	self.current_effect_obj.rect.anchoredPosition3D = Vector3(0,0,0)
	self:CalculateSuccessRata()
end

-- 显示使用幸运符图标
function ForgeStrengthen:SetLuckyItemNum(need_num, had_num)
	local had_text = ""
	local need_text = " / "..need_num
	if had_num >= need_num then
		had_text = ToColorStr(had_num,TEXT_COLOR.BLUE_SPECIAL)
	else
		had_text = ToColorStr(had_num,TEXT_COLOR.RED)
	end
	self.lucky_item_number:SetValue(had_text..need_text)

	local item_cfg = ItemData.Instance:GetItemConfig(self.next_cfg.lucky_stuff_id)
	self.lucky_item_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
end

function ForgeStrengthen:HelpClick()
	local tips_id = 146    -- 强化tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

-- 不显示数据
function ForgeStrengthen:ShowEmpty()
	self.success_rate:SetValue(" ")
	self.need_lucky_item:SetValue(false)
end

--使用幸运符按钮按下
function ForgeStrengthen:LuckyItemClick()
	-- print("使用幸运符按钮按下使用幸运符按钮按下")
	if self.use_lucky_item == 1 then
		--使用中
		self.va_use_lucky_item:SetValue(false)
		self.use_lucky_item = 0
	else
		--未使用中
		if self:GetIsEnoughLuckyItem() then
			--足够
			self.va_use_lucky_item:SetValue(true)
			self.use_lucky_item = 1
		else
			--不足够
			self.va_use_lucky_item:SetValue(false)
			self.use_lucky_item = 0
			TipsCtrl.Instance:ShowItemGetWayView(self.next_cfg.lucky_stuff_id)
		end
	end
	-- self:CalculateSuccessRata()
end

-- 强化按钮
function ForgeStrengthen:OnClickStrengthen()
	if self.data == nil or self.data.item_id == nil then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	local is_can_strength, item_id, need_num = self:CheckIsCanStrength()
	if is_can_strength == 0 or (need_num and need_num < 1) then
		ForgeCtrl.Instance:SendQianghua(self.is_auto_buy_stone, self.use_lucky_item)
	elseif is_can_strength == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.MaxLevel)
	elseif is_can_strength == 2 then
		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			--勾选自动购买
			if is_buy_quick then
				self.auto_buy_toggle.isOn = true
				self.is_auto_buy_stone = 1
			end
		end
		local shop_item_cfg = ShopData.Instance:GetShopItemCfg(item_id)
		if need_num == nil then
			MarketCtrl.Instance:SendShopBuy(item_id, 999, 0, 1)
		else
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, need_num)
		end

	elseif is_can_strength == 3 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NotEnoughGrade)
	end
end

-- 一键强化按钮
function ForgeStrengthen:OnClickOneKeyStrengthen()
	if self.data == nil or self.data.item_id == nil then
		self.one_key_strengthen = false
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NoSelectEquip)
		return
	end
	if self.one_key_strengthen then
		return
	end
	local is_can_strength = self:CheckIsCanStrength()
	if is_can_strength == 0 then
		self.target_level = self.data.param.strengthen_level + 1
		self.one_key_strengthen = true
	elseif is_can_strength == 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.MaxLevel)
	elseif is_can_strength == 2 then
		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id)
	elseif is_can_strength == 3 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.NotEnoughGrade)
	end
	self:OnClickStrengthen()
end

--强化装备后的回调
function ForgeStrengthen:OnAfterStrengthen(result)
	self.show_qianghua_effect:SetValue(true)
	-- self.one_key_strengthen_btn.button.interactable = true
	if self.one_key_strengthen then
		if self.data.param.strengthen_level >= self.target_level then
			self.one_key_strengthen = false
		else
			local is_can_strength = self:CheckIsCanStrength()
			if is_can_strength ~= 0 then
				self.one_key_strengthen = false
			end
			self:OnClickStrengthen()
		end
	end
	if result == 1 then
		if not self.is_show_cg_effect then
			self.is_show_cg_effect = true
			GlobalTimerQuest:AddDelayTimer(function()
				self.is_show_cg_effect = false
			end, 1)
			EffectManager.Instance:PlayAtTransform("effects2/prefab/ui_x/ui_qhcg_prefab", "UI_qhcg", self.qhcg_effect.transform, 1, nil, nil)  --强化成功特效
		end
	end
	if result ~= 1 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Forge.PromoteFail)
		if not self.is_show_sb_effect then
			self.is_show_sb_effect = true
			GlobalTimerQuest:AddDelayTimer(function()
				self.is_show_sb_effect = false
			end, 1)
			--EffectManager.Instance:PlayAtTransform("effects2/prefab/ui_x/ui_qhsb_prefab", "UI_qhsb", self.qhsb_effect.transform, 1, nil, nil)	--强化失败特效
		end
	end
end

--检查是否能强化,加上自动购买的条件 0、可以 1、到达顶级 2、不够材料
function ForgeStrengthen:CheckIsCanStrength()
	local flag, item_id, need_num = ForgeData.Instance:CheckIsCanImprove(self.data, TabIndex.forge_strengthen)
	if flag == 0 then
		return 0
	elseif flag == 1 then
		return 1
	elseif flag == 2 then
		if self.is_auto_buy_stone == 1 then
			local stuff_id = self.next_cfg["stuff_id"]
			local stuff_count = self.next_cfg["stuff_count"]

			local test_shop_data = ConfigManager.Instance:GetAutoConfig("shop_auto").item

			local item_cfg = test_shop_data[stuff_id]

			if item_cfg ~= nil then
				local total_need_gold = item_cfg.gold * stuff_count
				local player_had_gold = PlayerData.Instance:GetRoleVo().gold + PlayerData.Instance:GetRoleVo().bind_gold
				if player_had_gold >= total_need_gold then
					return 0
				else
					return 2, stuff_id
				end
			else
				-- print("找不到物,ID:",stuff_id)
			end
		else
			return 2, item_id, need_num
		end
	elseif flag == 3 then
		return 3
	end
end

--自动购买强化石Toggle点击时
function ForgeStrengthen:AutoBuyChange(is_on)
	-- print("自动购买强化石Toggle点击时")
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

--计算成功率
function ForgeStrengthen:CalculateSuccessRata()
	if self.next_cfg == nil then
		self.success_rate:SetValue("")
		return
	end
	-- if self.use_lucky_item == 1 then
	-- 	self.success_rate:SetValue("100%")
	-- 	return
	-- end
	local card_type, card_name = ForgeData.Instance:GetXianZunCardType()
	local end_timestamp = XianzunkaData.Instance:GetCardEndTimestamp(card_type)
	local xianzun_addition = ""
	local addition = XianzunkaData.Instance:GetAdditionCfg(card_type).add_equip_strength_succ_rate/100 or 0
	local vip_str = ""
	local vip_param = VipPower.Instance:GetParam(VipPowerId.qianghua_suc)
	
	if vip_param ~= nil and vip_param > 0 then
		vip_str = vip_param and "+" .. vip_param .. "%" or ""
	end

	local rate_str = self.next_cfg.show_succ_rate .. "%"
	rate_str = rate_str
	self.success_rate:SetValue(rate_str)

	if XianzunkaData.Instance:IsActiveForever(card_type) or end_timestamp - TimeCtrl.Instance:GetServerTime() > 0 then
		xianzun_addition = string.format(Language.Forge.XianZunAddition, addition.."%", card_name)
	end

	self.xianzun_add:SetValue(xianzun_addition)
end

--是否需要luck符
function ForgeStrengthen:GetIsNeedLuckyItem()
	if self.next_cfg.lucky_stuff_count >0 then
		return true
	else
		return false
	end
end

--身上是否有足够的luck符
function ForgeStrengthen:GetIsEnoughLuckyItem()
	local item_num = ItemData.Instance:GetItemNumInBagById(self.next_cfg.lucky_stuff_id)
	if item_num >= self.next_cfg.lucky_stuff_count then
		return true, item_num, self.next_cfg.lucky_stuff_count
	else
		return false, item_num, self.next_cfg.lucky_stuff_count
	end
end

--打开总强化奖励
function ForgeStrengthen:OpenTotalStrenthTips()
	local level = ForgeData.Instance:GetTotalStrengthLevel()
	local cu_cfg, ne_cfg = ForgeData.Instance:GetTotalStrengthCfgByLevel(level)
	TipsCtrl.Instance:ShowTotalAttrView(Language.Forge.ForgeSuitAtt, level, cu_cfg, ne_cfg)
end

----------------------------
-- 效果格子
----------------------------
StrengthEffectCell = StrengthEffectCell or BaseClass(ForgeBaseCell)
function StrengthEffectCell:__init()
	self.level = self:FindVariable("Level")
end

function StrengthEffectCell:FlushCallBack()
	self.level:SetValue(self.data.param.strengthen_level)
end