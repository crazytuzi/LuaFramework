AdvanceShenyiView = AdvanceShenyiView or BaseClass(BaseRender)

ShenyiImageFulingType = {    --伙伴法阵
	Type = 5
}

function AdvanceShenyiView:__init(instance)
	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self, true))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",
		BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickZiZhi",
		BindTool.Bind(self.OnClickZiZhi, self))
	-- self:ListenEvent("OnClickChengZhang",
	-- 	BindTool.Bind(self.OnClickChengZhang, self))
	self:ListenEvent("OnClickHuanHua",
		BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickEquipBtn",
		BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSendMsg",
		BindTool.Bind(self.OnClickSendMsg, self))
	self:ListenEvent("OnClickFuLing",
		BindTool.Bind(self.OnClickFuLing, self))
	self:ListenEvent("OnClickAllAttrBtn",
		BindTool.Bind(self.OnClickAllAttrBtn, self))
	self:ListenEvent("OnClickBiPingReward",
		BindTool.Bind(self.OnClickBiPingReward, self))
	self:ListenEvent("OnClickJinJieAward",
		BindTool.Bind(self.OnClickJinJieAward, self))
	--self:ListenEvent("OnClickOpenSmallTarget",
	--	BindTool.Bind(self.OnClickOpenSmallTarget, self))

	self.shenyi_name = self:FindVariable("Name")
	self.shenyi_rank = self:FindVariable("Rank")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.sheng_ming = self:FindVariable("HPValue")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.jian_ren = self:FindVariable("JianRen")
	self.jia_shang = self:FindVariable("JiaShang")
	self.jian_shang = self:FindVariable("JianShang")
	self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.cur_bless = self:FindVariable("CurBless")
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")
	self.show_star = self:FindVariable("show_star")
	self.show_star:SetValue(false)
	self.show_auto_buy = self:FindVariable("show_auto_buy")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_skill_arrow1 = self:FindVariable("ShowSkillUplevel1")
	self.show_skill_arrow2 = self:FindVariable("ShowSkillUplevel2")
	self.show_skill_arrow3 = self:FindVariable("ShowSkillUplevel3")
	self.show_equip_remind = self:FindVariable("ShowEquipRemind")
	self.show_fuling_remind = self:FindVariable("ShowFulingRemind")
	self.shenyi_display = self:FindObj("ShenyiDisplay")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))
	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	self.gray_use_button = self:FindObj("GrayUseButton")
	self.preview_go = self:FindObj("preview_go")
	self.advance_txt = self:FindObj("advanceTxt")
	self.auto_txt = self:FindObj("autoTxt")
	self.preview_text = self:FindVariable("preview_text")
	self.preview_text:SetValue(Language.Common.Look)
	self.show_preview = self:FindVariable("show_preview")
	self.clear_luck_val = self:FindVariable("ClearLuckVal")
	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")

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

	self.shenyi_skill_list = {}

	self.bipin_redpoint = self:FindVariable("BiPinRedPoint")
	self.bipin_reward = self:FindVariable("BiPinIconReward")
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_shenyi)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.goddess_shenyi)
	self.bipin_reward:SetValue(vis and not is_get_reward)

	self.btn_tip_anim = self:FindObj("BtnTipAnim")
	self.btn_tip_anim_flag = true

	local item1 = ItemCell.New()
	item1:SetInstanceParent(self:FindObj("Item1"))
	item1:ShowHighLight(false)
	self.item_cell = item1

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindObj("Star"..i)
	end

	self:GetShenyiSkill()

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.grade = nil
	self.old_attrs = {}
	self.skill_fight_power = 0
	self.is_in_preview = false

	self.prefab_preload_id = 0
	self.now_level = 0
end

function AdvanceShenyiView:__delete()
	self:RemoveCountDown()
	
	self.index = nil
	self.grade = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.shenyi_skill_list = nil
	self.old_attrs = {}
	self.skill_fight_power = nil
	self.advance_txt = nil
	self.auto_txt = nil
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

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	if self.shenyi_model  then
		self.shenyi_model:DeleteMe()
		self.shenyi_model = nil
	end
end

-- 提升一次
function AdvanceShenyiView:OnStartAdvance(is_click)
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	local data = ShenyiData.Instance
	local shenyi_info = data:GetShenyiInfo()
	if nil == shenyi_info.grade then return end
	local shenyi_grade_cfg = data:GetShenyiGradeCfg(shenyi_info.grade)
	if nil == shenyi_grade_cfg then return end
	local pack_num = shenyi_grade_cfg.upgrade_stuff_count
	local num = ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff2_id)

	--判断神弓比拼是否开启
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and shenyi_info.grade == 6 then
	-- 	TipsCtrl.Instance:GetBiPingView():SetTipViewFiveLevelcfg()
	-- 	return
	-- end

	if num < pack_num and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()

		if is_click then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[shenyi_grade_cfg.upgrade_stuff_id]
			if item_cfg == nil then
				-- TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
				TipsCtrl.Instance:ShowItemGetWayView(shenyi_grade_cfg.upgrade_stuff_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(shenyi_grade_cfg.upgrade_stuff_id, 2)
				return
			end

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				if is_buy_quick then
					self.auto_buy_toggle.toggle.isOn = true
				end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, shenyi_grade_cfg.upgrade_stuff_id, nil, 1)
		end

		return
	end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local next_time = shenyi_grade_cfg.next_time
	ShenyiCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto, math.floor(num / pack_num))
	self.jinjie_next_time = Status.NowTime + next_time
end

function AdvanceShenyiView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade > 0 and self.cur_select_grade <= ShenyiData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnStartAdvance, self), jinjie_next_time)
		end
	end
end

function AdvanceShenyiView:FlushView()
	self:OnFlush("shenyi")
	self:SetAutoButtonGray()
	self:SetPropItemCellsData()
	self:OpenCallBack()
	self:SetModle(true)
	self:SetArrowState(self.cur_select_grade)
end

function AdvanceShenyiView:ShenyiUpGradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 一键提升
function AdvanceShenyiView:OnAutomaticAdvance()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not shenyi_info or not next(shenyi_info) then return end

	if shenyi_info.grade == 0 then
		return
	end
	--判断神弓比拼是否开启
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and shenyi_info.grade == 6 then
	-- 	TipsCtrl.Instance:GetBiPingView():SetTipViewFiveLevelcfg()
	-- 	return
	-- end

	if not self.is_can_auto then
		return
	end

	self.is_auto = self.is_auto == false
	self.is_can_auto = false
	self:OnStartAdvance(true)
	self:SetAutoButtonGray()
end

function AdvanceShenyiView:OnClickSendMsg()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not shenyi_info or not next(shenyi_info) then return end

	-- 发送冷却CD
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		time = math.ceil(time)
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
		return
	end

	local shenyi_grade = shenyi_info.grade
	local name = ""
	local color = TEXT_COLOR.WHITE
	local btn_color = 0
	if shenyi_grade > 1000 then
		local image_list = ShenyiData.Instance:GetSpecialImageCfg(shenyi_grade - 1000)
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local item_cfg = ItemData.Instance:GetItemConfig(image_list.item_id)
			if nil ~= item_cfg then
				color = SOUL_NAME_COLOR_CHAT[item_cfg.color]
				btn_color = item_cfg.color
			end
		end
	else
		local image_list = ShenyiData.Instance:GetShenyiImageCfg()[shenyi_info.used_imageid]
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local temp_grade = ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)
			local temp_color = (temp_grade / 3 + 1) >= 5 and 5 or math.floor(temp_grade / 3 + 1)
			color = SOUL_NAME_COLOR_CHAT[temp_color]
			btn_color = temp_color
		end
	end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local content = string.format(Language.Chat.AdvancePreviewLinkList[4], game_vo.role_id, name, color, btn_color, CHECK_TAB_TYPE.SHEN_GONG)
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)

	ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
	TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendSucc)
end

-- 形象赋灵
function AdvanceShenyiView:OnClickFuLing()
	ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_content, "fuling_type_tab", {IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENYI})
end

function AdvanceShenyiView:OnClickBiPingReward()
	if self.btn_tip_anim_flag then
		self.btn_tip_anim.animator:SetBool("isClick", false)
	end
	ViewManager.Instance:Open(ViewName.CompetitionTips)
end


-- 使用当前坐骑
function AdvanceShenyiView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShenyiCtrl.Instance:SendUseShenyiImage(grade_cfg.image_id)
end

-- 显示全属性加成面板
function AdvanceShenyiView:OnClickAllAttrBtn()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	self:FlushAllAttrPanel()
	self.all_attr_panel:SetActive(not self.all_attr_panel.gameObject.activeSelf)
end

function AdvanceShenyiView:SetAllAttrPanel()
	local all_attr_percent = ShenyiData.Instance:GetAllAttrPercent()
	local active_need_grade = ShenyiData.Instance:GetActiveNeedGrade()
	local cur_grade = ShenyiData.Instance:GetGrade()
	local jinjie_attr_percent, jinjie_name = JinJieRewardData.Instance:GetSystemShowPercentAndName(JINJIE_TYPE.JINJIE_TYPE_SHENYI)

	self.all_attr_percent:SetValue(all_attr_percent)
	self.active_need_grade:SetValue(active_need_grade - 1) --客户端显示的阶数比服务端少一，所以这里减一
	self.jin_jie_add_per:SetValue(jinjie_attr_percent)
	self.jin_jie_str:SetValue(jinjie_name)
end

function AdvanceShenyiView:FlushAllAttrPanel()
	local active_need_grade = ShenyiData.Instance:GetActiveNeedGrade()
	local cur_grade = ShenyiData.Instance:GetGrade()
	self.all_attr_btn_gray:SetValue(cur_grade >= active_need_grade)
end

--显示上一阶形象
function AdvanceShenyiView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	local image_id = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetShenyiImageCfg()[image_id].image_name.."</color>" --根据品质更改颜色
	self.shenyi_name:SetValue(name_str)
	self:SwitchGradeAndName(self.cur_select_grade)
	if self.shenyi_display ~= nil then
		self.shenyi_display.ui3d_display:ResetRotation()
	end
end

--显示下一阶形象
function AdvanceShenyiView:OnClickNextButton()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not self.cur_select_grade or self.cur_select_grade > shenyi_info.grade or shenyi_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	local image_id = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetShenyiImageCfg()[image_id].image_name.."</color>" --根据品质更改颜色
	self.shenyi_name:SetValue(name_str)
	self:SwitchGradeAndName(self.cur_select_grade)
	if self.shenyi_display ~= nil then
		self.shenyi_display.ui3d_display:ResetRotation()
	end
end

function AdvanceShenyiView:SwitchGradeAndName(index, no_flush_modle)
	if index == nil then return end

	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(index)
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg()
	if shenyi_grade_cfg == nil then return end

	local bundle, asset = nil, nil
	if math.floor(index / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetShenyiGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetShenyiGradeQualityBG(math.floor(index / 3 + 1))
	end
	self.quality:SetAsset(bundle, asset)
	self.shenyi_rank:SetValue(shenyi_grade_cfg.gradename)
	if not no_flush_modle then
		self:SetModle(true)
	end
end

-- 资质
function AdvanceShenyiView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shenyizizhi", {item_id = ShenyiDanId.ZiZhiDanId})
end

-- 点击进阶装备
function AdvanceShenyiView:OnClickEquipBtn()
	local is_active, activite_grade = ShenyiData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.goddess_shenyi] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.goddess_shenyi)
end

-- 幻化
function AdvanceShenyiView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.ShenyiHuanHua)
	ShenyiHuanHuaCtrl.Instance:FlushView("shenyihuanhua")
end

-- 点击坐骑技能
function AdvanceShenyiView:OnClickShenyiSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "shenyiskill", {index = index - 1})
end

function AdvanceShenyiView:GetShenyiSkill()
	for i = 1, 4 do
		local skill = self:FindObj("ShenyiSkill"..i)
		local Icon = skill:FindObj("Icon")
		local icon = Icon:FindObj("Image")
		local mask = Icon:FindObj("Mask")
		table.insert(self.shenyi_skill_list, {skill = skill, icon = icon, mask = mask})
	end
	for k, v in pairs(self.shenyi_skill_list) do
		local bundle, asset = ResPath.GetShenyiSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickShenyiSkill, self, k))
	end
end

function AdvanceShenyiView:FlushSkillIcon()
	local shenyi_skill_list = ShenyiData.Instance:GetShenyiInfo().skill_level_list
	if nil == shenyi_skill_list then return end

	for k, v in pairs(self.shenyi_skill_list) do
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = shenyi_skill_list[k - 1] > 0 and 0 or 255
		end
		v.mask:SetActive(shenyi_skill_list[k - 1] <= 0)
	end
end

-- 设置提升物品格子数据
function AdvanceShenyiView:SetPropItemCellsData()
	local data = ShenyiData.Instance
	local info = data:GetShenyiInfo()
	if nil == info.grade then return end
	local shenyi_grade_cfg = data:GetShenyiGradeCfg(info.grade)
	if nil == shenyi_grade_cfg then return end

	self.item_cell:SetData({item_id = shenyi_grade_cfg.upgrade_stuff_id, num = 0})

	local count = ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shenyi_grade_cfg.upgrade_stuff2_id)
	if count < shenyi_grade_cfg.upgrade_stuff_count  then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Common.ShowYellowStr, count)
	end
	self.have_pro_num:SetValue(count)
	self.need_pro_num:SetValue(shenyi_grade_cfg.upgrade_stuff_count)
end

-- 设置坐骑属性
function AdvanceShenyiView:SetShenyiAtrr()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local image_cfg = ShenyiData.Instance:GetShenyiImageCfg()
	if shenyi_info == nil or shenyi_info.shenyi_level == nil then
		self:SetAutoButtonGray()
		return
	end
	if shenyi_info.shenyi_level == 0 or shenyi_info.grade == 0 then
		local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(1)
		self:SetAutoButtonGray()
		return
	end
	local shenyi_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(shenyi_info.grade)

	if not shenyi_grade_cfg then return end

	if not self.temp_grade then
		if shenyi_grade_cfg.show_grade == 0 then
			self.cur_select_grade = shenyi_info.grade
		else
			self.cur_select_grade = shenyi_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shenyi_info.grade
									or ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade, true)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.temp_grade = shenyi_info.grade
	else
		if self.temp_grade < shenyi_info.grade then
			local new_attr = ShenyiData.Instance:GetShenyiAttrSum(nil, true)
			local old_capability = CommonDataManager.GetCapability(self.old_attrs) + self.skill_fight_power
			local new_capability = CommonDataManager.GetCapability(new_attr) + self.skill_fight_power
			TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[shenyi_grade_cfg.image_id], new_attr, self.old_attrs, "shenyi_view", new_capability, old_capability)

			if shenyi_grade_cfg.show_grade == 0 then
				self.cur_select_grade = shenyi_info.grade
			else
				self.cur_select_grade = shenyi_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shenyi_info.grade
										or ShenyiData.Instance:GetShenyiGradeByUseImageId(shenyi_info.used_imageid)
			end
			self.is_auto = false
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade, true)
			self:SwitchGradeAndName(shenyi_info.grade, true)
		end
		self.temp_grade = shenyi_info.grade
	end
	self.clear_luck_val:SetValue(shenyi_grade_cfg.is_clear_bless == 1)
	self:SetUseImageButtonState(self.cur_select_grade, true)

	if shenyi_info.grade >= ShenyiData.Instance:GetMaxGrade() then
		self:SetAutoButtonGray()
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(shenyi_info.grade_bless_val.." / "..shenyi_grade_cfg.bless_val_limit)
		if self.is_first then
			self.exp_radio:InitValue(shenyi_info.grade_bless_val/shenyi_grade_cfg.bless_val_limit)
			self.is_first = false
		else
			self.exp_radio:SetValue(shenyi_info.grade_bless_val/shenyi_grade_cfg.bless_val_limit)
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if ShenyiData.Instance:GetShenyiSkillCfgById(i) then
			skill_capability = skill_capability + ShenyiData.Instance:GetShenyiSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(shenyi_grade_cfg)
	local capability = CommonDataManager.GetCapability(attr)
	local all_attr_percent_cap = ShenyiData.Instance:CalculateAllAttrCap(capability)
	self.old_attrs = attr
	self.fight_power:SetValue(capability + skill_capability + all_attr_percent_cap)

	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	self.ming_zhong:SetValue(attr.ming_zhong)
	self.shan_bi:SetValue(attr.shan_bi)
	self.bao_ji:SetValue(attr.bao_ji)
	self.jian_ren:SetValue(attr.jian_ren)


	self.jia_shang:SetValue(attr.per_pofang)
	self.jian_shang:SetValue(attr.per_mianshang)
	self.show_zizhi_redpoint:SetValue(ShenyiData.Instance:IsShowZizhiRedPoint())
	-- self.show_chengzhang_redpoint:SetValue(ShenyiData.Instance:IsShowChengzhangRedPoint())
	self.show_huanhua_redpoint:SetValue(ShenyiData.Instance:IsCanHuanhuaUpgrade() ~= false)
	local can_uplevel_skill_list = ShenyiData.Instance:CanSkillUpLevelList()
	self.show_skill_arrow1:SetValue(can_uplevel_skill_list[1] ~= nil)
	self.show_skill_arrow2:SetValue(can_uplevel_skill_list[2] ~= nil)
	self.show_skill_arrow3:SetValue(can_uplevel_skill_list[3] ~= nil)

	local image_id = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShenyiData.Instance:GetShenyiImageCfg()[image_id].image_name.."</color>" --根据品质更改颜色
	self.shenyi_name:SetValue(name_str)

	self.show_equip_remind:SetValue(ShenyiData.Instance:CalAllEquipRemind() > 0)
	self.show_fuling_remind:SetValue(AdvanceData.Instance:CalFulingRemind(ShenyiImageFulingType.Type))
end

function AdvanceShenyiView:SetArrowState(cur_select_grade, no_flush_modle)
	local cur_select_grade = cur_select_grade or self.cur_select_grade
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(cur_select_grade)
	if not shenyi_info or not shenyi_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < shenyi_info.grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (shenyi_info.grade  == 1 and cur_select_grade > shenyi_info.grade))
	self:SetUseImageButtonState(cur_select_grade, no_flush_modle)
end

function AdvanceShenyiView:SetUseImageButtonState(cur_select_grade, no_flush_modle)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(cur_select_grade)

	if not shenyi_info or not shenyi_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_use_button:SetValue(cur_select_grade <= shenyi_info.grade and grade_cfg.image_id ~= shenyi_info.used_imageid)
	self.show_use_image:SetValue(grade_cfg.image_id == shenyi_info.used_imageid)
	self:SwitchGradeAndName(self.cur_select_grade, no_flush_modle)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceShenyiView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if nil == shenyi_info.grade then
		return
	end
	self:SetPropItemCellsData()
end

-- 设置进阶按钮状态
function AdvanceShenyiView:SetAutoButtonGray()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if shenyi_info.grade == nil then return end

	local max_grade = ShenyiData.Instance:GetMaxGrade()
	local text1= "进阶"
	if not shenyi_info or not shenyi_info.grade or shenyi_info.grade <= 0
		or shenyi_info.grade >= max_grade then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = false
		self.advance_txt.grayscale.GrayScale = 255
		self.auto_button.button.interactable = false
		self.auto_txt.grayscale.GrayScale = 255
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.start_button.button.interactable = false
		self.advance_txt.grayscale.GrayScale = 255
		self.auto_button.button.interactable = true
		self.auto_txt.grayscale.GrayScale = 0
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = true
		self.advance_txt.grayscale.GrayScale = 0
		self.auto_button.button.interactable = true
		self.auto_txt.grayscale.GrayScale = 0
	end
end

function AdvanceShenyiView:SetModle(is_show, grade, flush_flag)
	if is_show then
		if not ShenyiData.Instance:IsActiviteShenyi() then
			return
		end
		local goddess_data = GoddessData.Instance
		local info = {}
		info.role_res_id = goddess_data:GetShowXiannvResId()
		info.wing_res_id = -1

		if grade then
			self.cur_select_grade = grade
		else
			if self.cur_select_grade == nil or self.is_in_preview == true or flush_flag then
				self.is_in_preview = false
				self.cur_select_grade = ShenyiData.Instance:GetShenyiInfo().grade
			end
		end

		local grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.cur_select_grade).image_id
		if grade_cfg then
			info.wing_res_id = ShenyiData.Instance:GetShowShenyiRes(self.cur_select_grade)
			self:Set3DModel(info)
		end
	end
end

function AdvanceShenyiView:Set3DModel(info)
	self.shenyi_model:SetGoddessModelResInfo(info)
	local resid = GoddessData.Instance:GetShowXiannvResId()
	self:CalToShowAnim(true)
end

function AdvanceShenyiView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
	self:RemoveCountDown()
end

function AdvanceShenyiView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	local part = nil
	if UIScene.role_model then
		part = UIScene.role_model.draw_obj:GetPart(SceneObjPart.Main)
	end
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			if part then
				-- part:SetTrigger("attack1")
			end
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end

function AdvanceShenyiView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function AdvanceShenyiView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.temp_grade = nil
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function AdvanceShenyiView:OnAutoBuyToggleChange(isOn)

end

function AdvanceShenyiView:OpenCallBack()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo()
	if not shenyi_info or not next(shenyi_info) then return end
	self.is_first = true

	--用于显示模型
	if self.shenyi_model == nil then
		self.shenyi_model = RoleModel.New("goddess_info_panel")
		self.shenyi_model:SetDisplay(self.shenyi_display.ui3d_display)
	end

	self.now_level = shenyi_info.grade
	self:ShowTextTip()
	self:SetAllAttrPanel()
end

function AdvanceShenyiView:ShowTextTip()
	local shenyi_info = ShenyiData.Instance:GetShenyiInfo() or {}
	local level = shenyi_info.grade or 0

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

function AdvanceShenyiView:CancelPreviewToggle()
	if self.preview_go.toggle.isOn then
		self.preview_go.toggle.isOn = false
	end
end

function AdvanceShenyiView:OnFlush(param_list)
	if not ShenyiData.Instance:IsActiviteShenyi() then
		return
	end
	
	self:JinJieReward()
	
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_shenyi)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.goddess_shenyi)
	self.bipin_reward:SetValue(vis and not is_get_reward)
	local bipin_redpoint = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.goddess_shenyi)
    self.bipin_redpoint:SetValue(bipin_redpoint)

	if self.shenyi_display ~= nil then
		self.shenyi_display.ui3d_display:ResetRotation()
	end
	self:SetPropItemCellsData()

	if param_list == "shenyi" then
		self:SetShenyiAtrr()
		self:FlushSkillIcon()
		self:FlushAllAttrPanel()
		return
	end
	for k, v in pairs(param_list) do
		if k == "shenyi" then
			self:SetShenyiAtrr()
			self:FlushSkillIcon()
		end
	end
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceShenyiView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_SHENYI
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
function AdvanceShenyiView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue("")
		self.free_get_small_target_is_end:SetValue(false)
	else    --大目标
		self.jin_jie_free_time:SetValue("")
		self.jin_jie_is_free:SetValue(false)		
	end
end

--大目标 变动显示
function AdvanceShenyiView:BigTargetNotConstantData(system_type, target_type)
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
function AdvanceShenyiView:SmallTargetNotConstantData(system_type, target_type)
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
function AdvanceShenyiView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceShenyiView:BigTargetConstantData(system_type, target_type)
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
function AdvanceShenyiView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceShenyiView:SetJinJieFreeTime(time, target_type)
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
function AdvanceShenyiView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue(time)
	else    --大目标
		self.jin_jie_free_time:SetValue(time)
	end
end

--移除倒计时
function AdvanceShenyiView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceShenyiView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_SHENYI)
end

--打开小目标面板
function AdvanceShenyiView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_SHENYI
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_SHENYI, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end
