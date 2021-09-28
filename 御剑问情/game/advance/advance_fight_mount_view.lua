AdvanceFightMountView = AdvanceFightMountView or BaseClass(BaseRender)

FightMountImageFulingType = {
	Type = 3
}

local DISPLAYNAME = {
	[7109001] = "fight_mount_panel_special_1",
	[7106001] = "fight_mount_panel_special_2",
	[7102001] = "fight_mount_panel_special_3",
	[7112001] = "fight_mount_panel_special_3",
}

local EFFECT_CD = 1.8
function AdvanceFightMountView:__init(instance)
	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",
		BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickZiZhi",
		BindTool.Bind(self.OnClickZiZhi, self))
	self:ListenEvent("OnClickHuanHua",
		BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickEquipBtn",
		BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSendMsg",
		BindTool.Bind(self.OnClickSendMsg, self))
	self:ListenEvent("OnClickFuLing",
		BindTool.Bind(self.OnClickFuLing, self))
	self:ListenEvent("OnClickBiPingReward",
		BindTool.Bind(self.OnClickBiPingReward, self))
	self:ListenEvent("OnClickAllAttrBtn",
		BindTool.Bind(self.OnClickAllAttrBtn, self))
	self:ListenEvent("OnClickJinJieAward",
		BindTool.Bind(self.OnClickJinJieAward, self))
	--self:ListenEvent("OnClickOpenSmallTarget",
	--  BindTool.Bind(self.OnClickOpenSmallTarget, self))

	self.mount_name = self:FindVariable("Name")
	self.mount_rank = self:FindVariable("Rank")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.max_hp = self:FindVariable("HPValue")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.jian_ren = self:FindVariable("JianRen")
	self.su_du = self:FindVariable("SuDu")

	self.prop_bag_num = self:FindVariable("RemainderNum")
	self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.prop_name = self:FindVariable("PropName")
	self.cur_bless = self:FindVariable("CurBless")
	self.look_btn_text = self:FindVariable("LookBtnText")

	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image_sprite = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_effect = self:FindVariable("ShowEffect")
	self.hide_effect = self:FindVariable("HideEffect")
	self.show_on_look = self:FindVariable("IsOnLookState")
	self.show_equip_remind = self:FindVariable("ShowEquipRemind")
	self.show_fuling_remind = self:FindVariable("ShowFulingRemind")
	self.show_stars = self:FindVariable("ShowStars")
	self.show_stars:SetValue(false)
	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	self.gray_use_button = self:FindObj("GrayUseButton")
	self.button_text = self:FindVariable("button_text")
	self.button_ismax = self:FindVariable("button_ismax")
	self.bipin_reward = self:FindVariable("BiPinIconReward")
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.fight_mount)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.fight_mount)
	self.bipin_reward:SetValue(vis and not is_get_reward)
	self.bipin_redpoint = self:FindVariable("BiPinRedPoint")
	self.clear_luck_val = self:FindVariable("ClearLuckVal")

	self.all_attr_panel = self:FindObj("AllAttrPanel")
	self.all_attr_percent = self:FindVariable("AllAttrPercent")
	self.active_need_grade = self:FindVariable("ActiveNeedGrade")
	self.all_attr_btn_gray = self:FindVariable("AllAttrBtnGray")

	--进阶奖励相关
	self.show_jin_jie_reward = self:FindVariable("ShowJinJieAward")
	self.jin_jie_image = self:FindVariable("JinJieImage")
	self.add_text = self:FindVariable("AddText")
	self.show_jin_jie_reward_red_point = self:FindVariable("ShowJinjieRedPoint")
	self.jin_jie_add_per = self:FindVariable("JinJieAddPer")
	self.jin_jie_str = self:FindVariable("JinJieStr")
	self.jin_jie_free_time = self:FindVariable("JinJieFreeTime")
	self.jin_jie_is_free = self:FindVariable("JinJieIsFree")
	self.jin_jie_is_active = self:FindVariable("JinJieIsActive")
	--小目标相关
	self.is_show_small_target = self:FindVariable("IsShowSmallTarget")
	self.small_target_title_image = self:FindVariable("SmallTargetTitleImage")
	self.is_can_free_get_small_target = self:FindVariable("IsCanFreeGetSmallTarget")
	self.small_target_power = self:FindVariable("SmallTargetPower")
	self.small_target_free_time = self:FindVariable("SmallTargetFreeTime")
	self.free_get_small_target_is_end = self:FindVariable("FreeGetSmallTargetIsEnd")

	self.btn_tip_anim = self:FindObj("BtnTipAnim")
	self.btn_tip_anim_flag = true

	self.stars_list = {}
	local stars_obj = self:FindObj("Stars")
	for i = 1, 10 do
		self.stars_list[i] = stars_obj:FindObj("Star"..i)
	end

	self.stars_hide_list = {}
	for i=1,10 do
		self.stars_hide_list[i] = {
		hide_star = self:FindVariable("HideStar"..i)
	}
	end

	self.display = self:FindObj("display")
	self.model_view = RoleModel.New("fight_mount_panel")
	self.model_view:SetDisplay(self.display.ui3d_display)

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("item"))

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.old_attrs = {}
	self.res_id = -1
	self.is_on_look = false
	self.prefab_preload_id = 0
	self.mount_asset_id = 0
	self.now_level = 0
end

function AdvanceFightMountView:__delete()
	self:RemoveCountDown()
	self.cur_select_grade = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.mount_skill_list = nil
	self.temp_grade = nil
	self.res_id = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.show_jin_jie_reward = nil
	self.jin_jie_image = nil
	self.add_text = nil
	self.show_jin_jie_reward_red_point = nil
	self.jin_jie_add_per = nil
	self.jin_jie_str = nil
	self.jin_jie_free_time = nil
	self.jin_jie_is_free = nil
	self.jin_jie_is_active = nil
	self.is_show_small_target = nil
	self.small_target_title_image = nil
	self.is_can_free_get_small_target = nil
	self.small_target_power = nil
	self.small_target_free_time = nil
	self.free_get_small_target_is_end = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.old_attrs = {}
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	self.btn_tip_anim = nil
	self.btn_tip_anim_flag = nil
	self.bipin_redpoint = nil

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

-- 开始进阶
function AdvanceFightMountView:OnStartAdvance()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end

	if mount_info.grade == 0 then
		return
	end
	--判断羽翼比拼是否开启
	--策划需求屏蔽
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and mount_info.grade == 6 then
	-- 	TipsCtrl.Instance:GetBiPingView():SetTipViewFiveLevelcfg()
	-- 	return
	-- end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)

	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn

	if nil == mount_grade_cfg or mount_info.grade >= FightMountData.Instance:GetMaxGrade() then
		return
	end

	local stuff_item_id = mount_grade_cfg.upgrade_stuff_id
	local pack_num = mount_grade_cfg.upgrade_stuff_count
	local num = ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff2_id)
	if num < pack_num and not is_auto_buy_toggle then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[stuff_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(stuff_item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
		return
	end


	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local next_time = mount_grade_cfg and mount_grade_cfg.next_time or 0.1
	FightMountCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto, math.floor(num / pack_num))
	self.jinjie_next_time = Status.NowTime + next_time
end


function AdvanceFightMountView:CallOnStartAdvance()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end

	if mount_info.grade == 0 then
		return
	end
	--判断羽翼比拼是否开启
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and mount_info.grade == 6 then
	-- 	TipsCtrl.Instance:GetBiPingView():SetTipViewFiveLevelcfg()
	-- 	return
	-- end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)

	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn

	if mount_grade_cfg == nil or mount_info.grade >= FightMountData.Instance:GetMaxGrade() then
		return
	end

	local stuff_item_id = mount_grade_cfg.upgrade_stuff_id
	local pack_num = mount_grade_cfg.upgrade_stuff_count
	local num = ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff2_id)
	if num < pack_num and not is_auto_buy_toggle then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[stuff_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(stuff_item_id, 2)
			return
		end
		return
	end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local next_time = mount_grade_cfg and mount_grade_cfg.next_time or 0.1
	FightMountCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto, math.floor(num / pack_num))
	self.jinjie_next_time = Status.NowTime + next_time
end

function AdvanceFightMountView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade and self.cur_select_grade > 0 and self.cur_select_grade <= MountData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CallOnStartAdvance,self), jinjie_next_time)
		end
	end
end

function AdvanceFightMountView:OnFightMountUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 自动进阶
function AdvanceFightMountView:OnAutomaticAdvance()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end

	if mount_info.grade == 0 then
		return
	end
	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	if nil == mount_grade_cfg then
		return
	end
	--判断羽翼比拼是否开启
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and mount_info.grade == 6 then
	-- 	TipsCtrl.Instance:GetBiPingView():SetTipViewFiveLevelcfg()
	-- 	return
	-- end
	if not self.is_can_auto then
		return
	end

	--物品不足，弹出购买UI
	local stuff_item_id = mount_grade_cfg.upgrade_stuff_id
	local pack_num = mount_grade_cfg.upgrade_stuff_count
	local num = ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff2_id)
	if num < pack_num and not self.auto_buy_toggle.toggle.isOn then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, stuff_item_id, nofunc, 1)
	end

	self.is_auto = self.is_auto == false
	self.is_can_auto = false
	self:CallOnStartAdvance()
	self:SetAutoButtonGray()
end

function AdvanceFightMountView:OnClickSendMsg()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end

	-- 发送冷却CD
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		time = math.ceil(time)
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
		return
	end

	local mount_grade = mount_info.grade
	local name = ""
	local color = TEXT_COLOR.WHITE
	local btn_color = 0
	if mount_grade > 1000 then
		local image_list = FightMountData.Instance:GetSpecialImageCfg(mount_grade - 1000)
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local item_cfg = ItemData.Instance:GetItemConfig(image_list.item_id)
			if nil ~= item_cfg then
				color = SOUL_NAME_COLOR_CHAT[item_cfg.color]
				btn_color = item_cfg.color
			end
		end
	else
		local image_list = FightMountData.Instance:GetMountImageCfg()[mount_info.used_imageid]
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local temp_grade = FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
			local temp_color = (temp_grade / 3 + 1) >= 5 and 5 or math.floor(temp_grade / 3 + 1)
			color = SOUL_NAME_COLOR_CHAT[temp_color]
			btn_color = temp_color
		end
	end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local content = string.format(Language.Chat.AdvancePreviewLinkList[5], game_vo.role_id, name, color, btn_color, CHECK_TAB_TYPE.FIGHT_MOUNT)
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)

	ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
	TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendSucc)
end

--形象赋灵
function AdvanceFightMountView:OnClickFuLing()
	ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_content, "fuling_type_tab", {IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_FIGHT_MOUNT})
end

function AdvanceFightMountView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.FightMountHuanHua)
	FightMountHuanHuaCtrl.Instance:FlushView("fightmounthuanhua")
end

function AdvanceFightMountView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "fightmountzizhi", {item_id = FightMountDanId.ZiZhiDanId})
end

-- 点击进阶装备
function AdvanceFightMountView:OnClickEquipBtn()
	local is_active, activite_grade = FightMountData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.fight_mount] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.fight_mount)
end

function AdvanceFightMountView:OnClickBiPingReward()
	if self.btn_tip_anim_flag then
		self.btn_tip_anim.animator:SetBool("isClick", false)
	end
	ViewManager.Instance:Open(ViewName.CompetitionTips)
end

-- 使用当前坐骑
function AdvanceFightMountView:OnClickUse()
	if not self.cur_select_grade then
		return
	end
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	FightMountCtrl.Instance:SendUseFightMountImage(grade_cfg.image_id)
end

-- 显示全属性加成面板
function AdvanceFightMountView:OnClickAllAttrBtn()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	self.all_attr_panel:SetActive(not self.all_attr_panel.gameObject.activeSelf)
end

function AdvanceFightMountView:SetAllAttrPanel()
	local all_attr_percent = FightMountData.Instance:GetAllAttrPercent()
	local active_need_grade = FightMountData.Instance:GetActiveNeedGrade()
	local cur_grade = FightMountData.Instance:GetGrade()
	local jinjie_attr_percent, jinjie_name = JinJieRewardData.Instance:GetSystemShowPercentAndName(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT)

	self.all_attr_percent:SetValue(all_attr_percent)
	self.active_need_grade:SetValue(active_need_grade - 1) --客户端显示的阶数比服务端少一，所以这里减一
	self.jin_jie_add_per:SetValue(jinjie_attr_percent)
	self.jin_jie_str:SetValue(jinjie_name)
end

function AdvanceFightMountView:FlushAllAttrPanel()
	local active_need_grade = FightMountData.Instance:GetActiveNeedGrade()
	local cur_grade = FightMountData.Instance:GetGrade()
	self.all_attr_btn_gray:SetValue(cur_grade >= active_need_grade)
end

--显示上一阶形象
function AdvanceFightMountView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
	self:OnFlush()
end

--显示下一阶形象
function AdvanceFightMountView:OnClickNextButton()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end
	local image_cfg = FightMountData.Instance:GetMountImageCfg()
	if not self.cur_select_grade or self.cur_select_grade > mount_info.grade or mount_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	self:SwitchGradeAndName(self.cur_select_grade)
	self:OnFlush()
end

function AdvanceFightMountView:SwitchGradeAndName(cur_select_grade)
	if cur_select_grade == nil then return end

	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(cur_select_grade)
	local image_cfg = FightMountData.Instance:GetMountImageCfg()
	if mount_grade_cfg == nil or not image_cfg then return end

	local bundle, asset = nil, nil
	if math.floor(cur_select_grade / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(cur_select_grade / 3 + 1))
	end
	self.quality:SetAsset(bundle, asset)

	self.mount_rank:SetValue(mount_grade_cfg.gradename)
	local color = (cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(cur_select_grade / 3 + 1)
	local name_str = image_cfg[mount_grade_cfg.image_id].image_name
	self.mount_name:SetValue(string.format("<color=%s>%s</color>", SOUL_NAME_COLOR[color], name_str))
	if mount_grade_cfg and self.res_id ~= image_cfg[mount_grade_cfg.image_id].res_id then
		local call_back = function(model, obj)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FIGHT_MOUNT], image_cfg[mount_grade_cfg.image_id].res_id)
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
		end
		UIScene:SetModelLoadCallBack(call_back)
		bundle, asset = ResPath.GetFightMountModel(image_cfg[mount_grade_cfg.image_id].res_id)
		self.mount_bundle = bundle
		self.mount_asset = asset

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
				UIScene:ModelBundle(bundle_list, asset_list)
			end)

		self.res_id = image_cfg[mount_grade_cfg.image_id].res_id
	end
end

-- 设置坐骑属性
function AdvanceFightMountView:SetMountAtrr()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local image_cfg = FightMountData.Instance:GetMountImageCfg()
	if mount_info == nil or mount_info.grade == nil then
		self:SetAutoButtonGray()
		return
	end

	if mount_info.mount_level == 0 or mount_info.grade == 0 then
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(1)
		self:SetAutoButtonGray()
		return
	end
	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)

	if not mount_grade_cfg then return end
	local stuff_item_id = mount_grade_cfg.upgrade_stuff_id

	self.clear_luck_val:SetValue(mount_grade_cfg.is_clear_bless == 1)
	local data = {item_id = stuff_item_id, is_bind = 0}
	self.item:SetData(data)
	if self.temp_grade < 0 then
		if mount_grade_cfg.show_grade == 0 then
			self.cur_select_grade = mount_info.grade
		else
			self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.grade
									or FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade)
		self:SwitchGradeAndName(self.cur_select_grade)
		self.temp_grade = mount_info.grade
	else
		if self.temp_grade < mount_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.show_effect:SetValue(false)
				self.show_effect:SetValue(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			if mount_grade_cfg.show_grade == 0 then
				self.cur_select_grade = mount_info.grade
			else
				self.cur_select_grade = mount_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and mount_info.grade
										or FightMountData.Instance:GetMountGradeByUseImageId(mount_info.used_imageid)
			end
			self.is_auto = false
			self.res_id = -1
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade)
			self:SwitchGradeAndName(mount_info.grade)

			self.show_on_look:SetValue(false)
			self.look_btn_text:SetValue(Language.Common.Look)
		end
		self.temp_grade = mount_info.grade
	end
	self:SetUseImageButtonState(self.cur_select_grade)

	if mount_info.grade >= FightMountData.Instance:GetMaxGrade() then
		self:SetAutoButtonGray()
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
		self.hide_effect:SetValue(true)
	else
		self.cur_bless:SetValue(mount_info.grade_bless_val.."/"..mount_grade_cfg.bless_val_limit)
		if self.is_first then
			self.exp_radio:InitValue(mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit)
			self.is_first = false
		else
			self.exp_radio:SetValue(mount_info.grade_bless_val/mount_grade_cfg.bless_val_limit)
		end
	end

	local attr =  CommonDataManager.GetAttributteByClass(mount_grade_cfg)--FightMountData.Instance:GetFightMountAttrSum()
	local capability = CommonDataManager.GetCapabilityCalculation(attr)
	local all_attr_percent_cap = FightMountData.Instance:CalculateAllAttrCap(capability)
	self.old_attrs = attr

	self.fight_power:SetValue(capability + all_attr_percent_cap)
	self.max_hp:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	self.ming_zhong:SetValue(attr.ming_zhong)
	self.shan_bi:SetValue(attr.shan_bi)
	self.bao_ji:SetValue(attr.bao_ji)
	self.jian_ren:SetValue(attr.jian_ren)
	local speed = math.floor((attr.move_speed / GameEnum.BASE_SPEED) * 100 + 0.5)
	self.su_du:SetValue(speed..'%')

	local item_cfg = ItemData.Instance:GetItemConfig(stuff_item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)

	self.show_zizhi_redpoint:SetValue(FightMountData.Instance:IsShowZizhiRedPoint())
	self.show_huanhua_redpoint:SetValue(FightMountData.Instance:IsCanHuanhuaUpgrade() ~= false)
	self.show_equip_remind:SetValue(FightMountData.Instance:CalAllEquipRemind() > 0)
	self.show_fuling_remind:SetValue(AdvanceData.Instance:CalFulingRemind(FightMountImageFulingType.Type))
end


function AdvanceFightMountView:SetArrowState(cur_select_grade)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(cur_select_grade)
	if not mount_info or not mount_info.grade or not cur_select_grade or not max_grade then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < mount_info.grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (mount_info.grade  == 1 and cur_select_grade > mount_info.grade))
	self:SetUseImageButtonState(cur_select_grade)
end

function AdvanceFightMountView:SetUseImageButtonState(cur_select_grade)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	local max_grade = FightMountData.Instance:GetMaxGrade()
	local grade_cfg = FightMountData.Instance:GetMountGradeCfg(cur_select_grade)

	if not mount_info or not mount_info.grade or not cur_select_grade or not max_grade then
		return
	end
	self.show_use_button:SetValue(cur_select_grade <= mount_info.grade and grade_cfg.image_id ~= mount_info.used_imageid)
	self.show_use_image_sprite:SetValue(grade_cfg.image_id == mount_info.used_imageid)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceFightMountView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if not mount_info or not next(mount_info) then return end
	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
	if mount_grade_cfg == nil then
		return
	end

	local bag_num = ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff2_id)
	local bag_num_str = string.format(Language.Common.ShowYellowStr, bag_num)
	if bag_num <= 0 then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end
	self.have_pro_num:SetValue(bag_num_str)
end

-- 设置进阶按钮状态
function AdvanceFightMountView:SetAutoButtonGray()
	local mount_info = FightMountData.Instance:GetFightMountInfo()
	if mount_info.grade == nil then return end

	local max_grade = FightMountData.Instance:GetMaxGrade()

	if not mount_info or not mount_info.grade or mount_info.grade <= 0
		or mount_info.grade >= max_grade then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = false
		self.auto_button.button.interactable = false
		self.button_ismax:SetValue(false)
		return
	end

	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.start_button.button.interactable = false
		self.auto_button.button.interactable = true
		self.button_text:SetValue(false)
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = true
		self.auto_button.button.interactable = true
		self.button_text:SetValue(true)
		self.button_ismax:SetValue(true)
	end
end

function AdvanceFightMountView:SetModle(is_show)
	if is_show then
		if not FightMountData.Instance:IsActiviteMount() then
			return
		end
		local mount_info = FightMountData.Instance:GetFightMountInfo()
		if not mount_info or not next(mount_info) then return end
		local used_imageid = mount_info.used_imageid
		if used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
			local grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)
			used_imageid = grade_cfg and grade_cfg.image_id
		end
		local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(mount_info.grade)

		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		if used_imageid and mount_grade_cfg and self.cur_select_grade < 0 then
			local cur_select_grade = mount_grade_cfg.show_grade == 0 and mount_info.grade or FightMountData.Instance:GetMountGradeByUseImageId(used_imageid)
			self:SetArrowState(cur_select_grade)
			self:SwitchGradeAndName(cur_select_grade)
			self.cur_select_grade = self.cur_select_grade and cur_select_grade
		end
	else
		self.temp_grade = -1
		self.cur_select_grade = -1
		if self.show_effect then
			self.show_effect:SetValue(false)
		end
	end
end

function AdvanceFightMountView:ClearTempData()
	self.res_id = -1
	self.cur_select_grade = -1
	self.temp_grade = -1
	self.is_auto = false
	self:RemoveCountDown()
end

function AdvanceFightMountView:RemoveNotifyDataChangeCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_grade = -1
	self.cur_select_grade = -1
	self.res_id = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self:RemoveCountDown()
end

function AdvanceFightMountView:ResetModleRotation()
	if self.mount_display ~= nil then
		self.mount_display.ui3d_display:ResetRotation()
	end
end

function AdvanceFightMountView:OpenCallBack()
	if self.show_effect then
		self.show_effect:SetValue(false)
	end
	self.is_first = true

	local info = FightMountData.Instance:GetFightMountInfo() or {}
	self.now_level = info.grade or 0

	self:ShowTextTip()
	self:SetAllAttrPanel()
end

function AdvanceFightMountView:ShowTextTip()
	local info = FightMountData.Instance:GetFightMountInfo() or {}
	local level = info.grade or 0

	if level > 5 and level < 8 then
		if self.delay_timer then
			GlobalTimerQuest:CancelQuest(self.delay_timer)
			self.delay_timer = nil
		end

		if self.all_attr_panel then
			self.all_attr_panel:SetActive(true)
		end

		self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ()
			if self.all_attr_panel then
				self.all_attr_panel:SetActive(false)
			end
		end, 3)
	end
end

function AdvanceFightMountView:OnFlush(param_list)
	if not FightMountData.Instance:IsActiviteMount() then
		return
	end

	self:JinJieReward()
	
	self:GetMountProNum( )
	if param_list == "fightmount" or type(param_list) == "table" then
		self:SetMountAtrr()
	end

	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.fight_mount)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.fight_mount)
	self.bipin_reward:SetValue(vis and not is_get_reward)
	local bipin_redpoint = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.fight_mount)
    self.bipin_redpoint:SetValue(bipin_redpoint)

	local bundle = self.mount_bundle
	local asset = self.mount_asset

	if nil ~= bundle and nil ~= asset and self.mount_asset_id ~= asset then
		self.model_view:SetPanelName(self:SetSpecialModle(asset))
		self.model_view:SetMainAsset(bundle, asset)
		self.mount_asset_id = asset
	end

	local info = FightMountData.Instance:GetFightMountInfo() or {}
	local level = info.grade or 0
	if self.now_level ~= level and level > 5 and level < 8 then
		self.now_level = level
		self:ShowTextTip()
	end

	self:FlushAllAttrPanel()
end

function AdvanceFightMountView:GetMountProNum()
	local info = FightMountData.Instance:GetFightMountInfo()
	if not info or not next(info) then return end
	local mount_grade_cfg = FightMountData.Instance:GetMountGradeCfg(info.grade)
	if not mount_grade_cfg then return end
	local pack_num = mount_grade_cfg.upgrade_stuff_count
	local count = ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(mount_grade_cfg.upgrade_stuff2_id)

	if count < pack_num  then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Common.ShowYellowStr, count)
	end
	self.have_pro_num:SetValue(count)
	self.need_pro_num:SetValue(pack_num)
end

function AdvanceFightMountView:SetSpecialModle(modle_id)
	local display_name = "fight_mount_panel"
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceFightMountView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT
	local is_show_small_target = JinJieRewardData.Instance:IsShowSmallTarget(system_type)
	self.is_show_small_target:SetValue(is_show_small_target)
	if is_show_small_target then --小目标
	--	local target_type = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
	--	self:SmallTargetConstantData(system_type, target_type)
	--	self:SmallTargetNotConstantData(system_type, target_type)
	else -- 大目标
		local target_type = JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET
		self:BigTargetConstantData(system_type, target_type)
		self:BigTargetNotConstantData(system_type, target_type)
	end
	
	JinJieRewardData.Instance:SetCurSystemType(system_type)
end

--清除大目标/小目标免费数据 target_type 目标类型  不传默认大目标
function AdvanceFightMountView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue("")
		self.free_get_small_target_is_end:SetValue(false)
	else    --大目标
		self.jin_jie_free_time:SetValue("")
		self.jin_jie_is_free:SetValue(false)		
	end
end

--大目标 变动显示
function AdvanceFightMountView:BigTargetNotConstantData(system_type, target_type)
	local is_show_jin_jie = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	local speical_is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(system_type)
	local active_is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(system_type)

	self.show_jin_jie_reward:SetValue(is_show_jin_jie)
	self.show_jin_jie_reward_red_point:SetValue(not speical_is_active)
	self.jin_jie_is_active:SetValue(speical_is_active)
	self.jin_jie_is_free:SetValue(not active_is_end)
	self:RemoveCountDown()

	if active_is_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--小目标 变动显示
function AdvanceFightMountView:SmallTargetNotConstantData(system_type, target_type)
	local is_free_end = JinJieRewardData.Instance:GetSystemSmallTargetFreeIsEnd(system_type)
	local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(system_type)
	self.is_can_free_get_small_target:SetValue(is_can_free)
	self.free_get_small_target_is_end:SetValue(not is_free_end)
	self:RemoveCountDown()

	if is_free_end then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(system_type, target_type)
	self:FulshJinJieFreeTime(end_time, target_type)
end

--小目标固定显示
function AdvanceFightMountView:SmallTargetConstantData(system_type, target_type)
	if self.set_small_target then
		return 
	end

	self.set_small_target = true
	local small_target_title_image = JinJieRewardData.Instance:GetSingleRewardCfgParam0(system_type, target_type)
	local bundle, asset = ResPath.GetTitleIcon(small_target_title_image)
	self.small_target_title_image:SetAsset(bundle, asset)

	local power = JinJieRewardData.Instance:GetSmallTargetTitlePower(target_type)
	self.small_target_power:SetValue(power)
end

--大目标固定显示
function AdvanceFightMountView:BigTargetConstantData(system_type, target_type)
	local flag = JinJieRewardData.Instance:IsShowJinJieRewardIcon(system_type)
	if not flag or self.set_big_target then
		return
	end

	self.set_big_target = true
	local item_id = JinJieRewardData.Instance:GetSingleRewardCfgRewardId(system_type, target_type)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and self.jin_jie_image then
		local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.jin_jie_image:SetAsset(item_bundle, item_asset)
	end

	local per = JinJieRewardData.Instance:GetSingleAttrCfgAttrAddPer(system_type)
	local per_text = per * 0.01
	self.add_text:SetValue(per_text)
end

--刷新免费时间
function AdvanceFightMountView:FulshJinJieFreeTime(end_time, target_type)
	if end_time == 0 then
		self:ClearJinJieFreeData(target_type)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:SetJinJieFreeTime(rest_time, target_type)
	if rest_time >= 0 and nil == self.least_time_timer then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetJinJieFreeTime(rest_time, target_type)
		end)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
	end	
end

--设置进阶时间
function AdvanceFightMountView:SetJinJieFreeTime(time, target_type)
	if time > 0 then
		local time_str = ""
		if time > 3600 * 24 then
			time_str = TimeUtil.FormatSecond(time, 7)
		else
			local time_list = TimeUtil.Format2TableDHMS(time)
			if time > 3600 then
				time_str = time_list.hour .. Language.Common.TimeList.h
			elseif time > 60 then
				time_str = time_list.min .. Language.Common.TimeList.min
			else
				time_str = time_list.s .. Language.Common.TimeList.s
			end
		end
		self:FreeTimeShow(time_str, target_type)
	else
		self:RemoveCountDown()
		self:ClearJinJieFreeData(target_type)
		self:JinJieReward()
	end
end

--免费时间显示
function AdvanceFightMountView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue(time)
	else    --大目标
		self.jin_jie_free_time:SetValue(time)
	end
end

--移除倒计时
function AdvanceFightMountView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceFightMountView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT)
end

--打开小目标面板
function AdvanceFightMountView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end
