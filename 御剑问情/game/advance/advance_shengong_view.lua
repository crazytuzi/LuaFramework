AdvanceShengongView = AdvanceShengongView or BaseClass(BaseRender)

ShengongImageFulingType = {    --伙伴光环
	Type = 4
}

function AdvanceShengongView:__init(instance)
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

	self.shengong_name = self:FindVariable("Name")
	self.shengong_rank = self:FindVariable("Rank")
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
	-- self.show_star:SetValue(ShengongData.Instance:GetShengongInfo().grade < ShengongData.Instance:GetMaxGrade())
	-- self.show_chengzhang_redpoint = self:FindVariable("ShowChengzhangRedPoint")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_skill_arrow1 = self:FindVariable("ShowSkillUplevel1")
	self.show_skill_arrow2 = self:FindVariable("ShowSkillUplevel2")
	self.show_skill_arrow3 = self:FindVariable("ShowSkillUplevel3")
	self.show_equip_remind = self:FindVariable("ShowEquipRemind")
	self.show_fuling_remind = self:FindVariable("ShowFulingRemind")
	self.shengong_display = self:FindObj("ShengongDisplay")
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

	self.shengong_skill_list = {}

	self.bipin_redpoint = self:FindVariable("BiPinRedPoint")
	self.bipin_reward = self:FindVariable("BiPinIconReward")
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_shengong)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.goddess_shengong)
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

	self:GetShengongSkill()

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

function AdvanceShengongView:__delete()
	self:RemoveCountDown()
	
	self.index = nil
	self.grade = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.shengong_skill_list = nil
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
	if self.shengong_model  then
		self.shengong_model:DeleteMe()
		self.shengong_model = nil
	end
end

-- 提升一次
function AdvanceShengongView:OnStartAdvance(is_click)
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	local data = ShengongData.Instance
	local shengong_info = data:GetShengongInfo()
	if nil == shengong_info.grade then return end
	local shengong_grade_cfg = data:GetShengongGradeCfg(shengong_info.grade)
	if nil == shengong_grade_cfg then return end
	local pack_num = shengong_grade_cfg.upgrade_stuff_count
	local num = ItemData.Instance:GetItemNumInBagById(shengong_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shengong_grade_cfg.upgrade_stuff2_id)

	--判断神弓比拼是否开启
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and shengong_info.grade == 6 then
	-- 	TipsCtrl.Instance:GetBiPingView():SetTipViewFiveLevelcfg()
	-- 	return
	-- end

	if num < pack_num and not is_auto_buy_toggle then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()

		if is_click then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[shengong_grade_cfg.upgrade_stuff_id]
			if item_cfg == nil then
				-- TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
				TipsCtrl.Instance:ShowItemGetWayView(shengong_grade_cfg.upgrade_stuff_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(shengong_grade_cfg.upgrade_stuff_id, 2)
				return
			end

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
				if is_buy_quick then
					self.auto_buy_toggle.toggle.isOn = true
				end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, shengong_grade_cfg.upgrade_stuff_id, nil, 1)
		end

		return
	end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local next_time = shengong_grade_cfg.next_time
	ShengongCtrl.Instance:SendUpGradeReq(is_auto_buy, self.is_auto, math.floor(num / pack_num))
	self.jinjie_next_time = Status.NowTime + next_time
end

function AdvanceShengongView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_select_grade > 0 and self.cur_select_grade <= ShengongData.Instance:GetMaxGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnStartAdvance, self), jinjie_next_time)
		end
	end
end

function AdvanceShengongView:FlushView()
	self:OnFlush("shengong")
	self:SetAutoButtonGray()
	self:SetPropItemCellsData()
	self:OpenCallBack()
	self:SetModle(true)
	self:SetArrowState(self.cur_select_grade)
end

function AdvanceShengongView:ShengongUpGradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

-- 一键提升
function AdvanceShengongView:OnAutomaticAdvance()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if not shengong_info or not next(shengong_info) then return end

	if shengong_info.grade == 0 then
		return
	end
	--判断神弓比拼是否开启
	-- if TipsCtrl.Instance:GetBiPingView():IsOpen() and shengong_info.grade == 6 then
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

function AdvanceShengongView:OnClickSendMsg()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if not shengong_info or not next(shengong_info) then return end

	-- 发送冷却CD
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		time = math.ceil(time)
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
		return
	end

	local shengong_grade = shengong_info.grade
	local name = ""
	local color = TEXT_COLOR.WHITE
	local btn_color = 0
	if shengong_grade > 1000 then
		local image_list = ShengongData.Instance:GetSpecialImageCfg(shengong_grade - 1000)
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local item_cfg = ItemData.Instance:GetItemConfig(image_list.item_id)
			if nil ~= item_cfg then
				color = SOUL_NAME_COLOR_CHAT[item_cfg.color]
				btn_color = item_cfg.color
			end
		end
	else
		local image_list = ShengongData.Instance:GetShengongImageCfg()[shengong_info.used_imageid]
		if nil ~= image_list and nil ~= image_list.image_name then
			name = image_list.image_name
			local temp_grade = ShengongData.Instance:GetShengongGradeByUseImageId(shengong_info.used_imageid)
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
function AdvanceShengongView:OnClickFuLing()
	ViewManager.Instance:Open(ViewName.ImageFuLing, TabIndex.img_fuling_content, "fuling_type_tab", {IMG_FULING_JINGJIE_TYPE.IMG_FULING_JINGJIE_TYPE_SHENGONG})
end

function AdvanceShengongView:OnClickBiPingReward()
	if self.btn_tip_anim_flag then
		self.btn_tip_anim.animator:SetBool("isClick", false)
	end
	ViewManager.Instance:Open(ViewName.CompetitionTips)
end

-- 使用当前坐骑
function AdvanceShengongView:OnClickUse()
	if self.cur_select_grade == nil then
		return
	end
	local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShengongCtrl.Instance:SendUseShengongImage(grade_cfg.image_id)
end

-- 显示全属性加成面板
function AdvanceShengongView:OnClickAllAttrBtn()
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	self:FlushAllAttrPanel()
	self.all_attr_panel:SetActive(not self.all_attr_panel.gameObject.activeSelf)
end

function AdvanceShengongView:SetAllAttrPanel()
	local all_attr_percent = ShengongData.Instance:GetAllAttrPercent()
	local active_need_grade = ShengongData.Instance:GetActiveNeedGrade()
	local cur_grade = ShengongData.Instance:GetGrade()
	local jinjie_attr_percent, jinjie_name = JinJieRewardData.Instance:GetSystemShowPercentAndName(JINJIE_TYPE.JINJIE_TYPE_SHENGONG)

	self.all_attr_percent:SetValue(all_attr_percent)
	self.active_need_grade:SetValue(active_need_grade - 1) --客户端显示的阶数比服务端少一，所以这里减一
	self.jin_jie_add_per:SetValue(jinjie_attr_percent)
	self.jin_jie_str:SetValue(jinjie_name)
end

function AdvanceShengongView:FlushAllAttrPanel()
	local active_need_grade = ShengongData.Instance:GetActiveNeedGrade()
	local cur_grade = ShengongData.Instance:GetGrade()
	self.all_attr_btn_gray:SetValue(cur_grade >= active_need_grade)
end

--显示上一阶形象
function AdvanceShengongView:OnClickLastButton()
	if not self.cur_select_grade or self.cur_select_grade <= 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade - 1
	self:SetArrowState(self.cur_select_grade)
	local image_id = ShengongData.Instance:GetShengongGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShengongData.Instance:GetShengongImageCfg()[image_id].image_name.."</color>" --根据品质更改颜色
	self.shengong_name:SetValue(name_str)
	self:SwitchGradeAndName(self.cur_select_grade)
	if self.shengong_display ~= nil then
		self.shengong_display.ui3d_display:ResetRotation()
	end
end

--显示下一阶形象
function AdvanceShengongView:OnClickNextButton()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if not self.cur_select_grade or self.cur_select_grade > shengong_info.grade or shengong_info.grade == 0 then
		return
	end
	self.cur_select_grade = self.cur_select_grade + 1
	self:SetArrowState(self.cur_select_grade)
	local image_id = ShengongData.Instance:GetShengongGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShengongData.Instance:GetShengongImageCfg()[image_id].image_name.."</color>" --根据品质更改颜色
	self.shengong_name:SetValue(name_str)
	self:SwitchGradeAndName(self.cur_select_grade)
	if self.shengong_display ~= nil then
		self.shengong_display.ui3d_display:ResetRotation()
	end
end

function AdvanceShengongView:SwitchGradeAndName(index, no_flush_modle)
	if index == nil then return end

	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(index)
	local image_cfg = ShengongData.Instance:GetShengongImageCfg()
	if shengong_grade_cfg == nil then return end

	local bundle, asset = nil, nil
	if math.floor(index / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetShengongGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetShengongGradeQualityBG(math.floor(index / 3 + 1))
	end
	self.quality:SetAsset(bundle, asset)
	self.shengong_rank:SetValue(shengong_grade_cfg.gradename)
	if not no_flush_modle then
		self:SetModle(true)
	end
end

-- 资质
function AdvanceShengongView:OnClickZiZhi()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shengongzizhi", {item_id = ShengongDanId.ZiZhiDanId})
end

-- 点击进阶装备
function AdvanceShengongView:OnClickEquipBtn()
	local is_active, activite_grade = ShengongData.Instance:IsOpenEquip()
	if not is_active then
		local name = Language.Advance.PercentAttrNameList[TabIndex.goddess_shengong] or ""
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
		return
	end
	ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.goddess_shengong)
end

-- 幻化
function AdvanceShengongView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.ShengongHuanHua)
	ShengongHuanHuaCtrl.Instance:FlushView("shengonghuanhua")
end

-- 点击坐骑技能
function AdvanceShengongView:OnClickShengongSkill(index)
	ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "shengongskill", {index = index - 1})
end

function AdvanceShengongView:GetShengongSkill()
	for i = 1, 4 do
		local skill = self:FindObj("ShengongSkill"..i)
		local Icon = skill:FindObj("Icon")
		local icon = Icon:FindObj("Image")
		local mask = Icon:FindObj("Mask")
		table.insert(self.shengong_skill_list, {skill = skill, icon = icon, mask = mask})
	end
	for k, v in pairs(self.shengong_skill_list) do
		local bundle, asset = ResPath.GetShengongSkillIcon(k)
		v.icon.image:LoadSprite(bundle, asset)
		v.skill.toggle:AddValueChangedListener(BindTool.Bind(self.OnClickShengongSkill, self, k))
	end
end

function AdvanceShengongView:FlushSkillIcon()
	local shengong_skill_list = ShengongData.Instance:GetShengongInfo().skill_level_list
	if nil == shengong_skill_list then return end

	for k, v in pairs(self.shengong_skill_list) do
		if v.icon.grayscale then
			v.icon.grayscale.GrayScale = shengong_skill_list[k - 1] > 0 and 0 or 255
		end
		v.mask:SetActive(shengong_skill_list[k - 1] <= 0)
	end
end

-- 设置提升物品格子数据
function AdvanceShengongView:SetPropItemCellsData()
	local data = ShengongData.Instance
	local info = data:GetShengongInfo()
	if nil == info.grade then return end
	local shengong_grade_cfg = data:GetShengongGradeCfg(info.grade)
	if nil == shengong_grade_cfg then return end

	self.item_cell:SetData({item_id = shengong_grade_cfg.upgrade_stuff_id, num = 0})

	local count = ItemData.Instance:GetItemNumInBagById(shengong_grade_cfg.upgrade_stuff_id) + ItemData.Instance:GetItemNumInBagById(shengong_grade_cfg.upgrade_stuff2_id)
	if count < shengong_grade_cfg.upgrade_stuff_count  then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Common.ShowYellowStr, count)
	end
	self.have_pro_num:SetValue(count)
	self.need_pro_num:SetValue(shengong_grade_cfg.upgrade_stuff_count)
end

-- 设置坐骑属性
function AdvanceShengongView:SetShengongAtrr()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local image_cfg = ShengongData.Instance:GetShengongImageCfg()
	if shengong_info == nil or shengong_info.shengong_level == nil then
		self:SetAutoButtonGray()
		return
	end
	if shengong_info.shengong_level == 0 or shengong_info.grade == 0 then
		local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(1)
		self:SetAutoButtonGray()
		return
	end
	local shengong_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(shengong_info.grade)

	if not shengong_grade_cfg then return end

	if not self.temp_grade then
		if shengong_grade_cfg.show_grade == 0 then
			self.cur_select_grade = shengong_info.grade
		else
			self.cur_select_grade = shengong_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shengong_info.grade
									or ShengongData.Instance:GetShengongGradeByUseImageId(shengong_info.used_imageid)
		end
		self:SetAutoButtonGray()
		self:SetArrowState(self.cur_select_grade, true)
		self:SwitchGradeAndName(self.cur_select_grade, true)
		self.temp_grade = shengong_info.grade
	else
		if self.temp_grade < shengong_info.grade then
			local new_attr = ShengongData.Instance:GetShengongAttrSum(nil, true)
			local old_capability = CommonDataManager.GetCapability(self.old_attrs) + self.skill_fight_power
			local new_capability = CommonDataManager.GetCapability(new_attr) + self.skill_fight_power
			TipsCtrl.Instance:ShowAdvanceSucceView(image_cfg[shengong_grade_cfg.image_id], new_attr, self.old_attrs, "shengong_view", new_capability, old_capability)

			if shengong_grade_cfg.show_grade == 0 then
				self.cur_select_grade = shengong_info.grade
			else
				self.cur_select_grade = shengong_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and shengong_info.grade
										or ShengongData.Instance:GetShengongGradeByUseImageId(shengong_info.used_imageid)
			end
			self.is_auto = false
			self:SetAutoButtonGray()
			self:SetArrowState(self.cur_select_grade, true)
			self:SwitchGradeAndName(shengong_info.grade, true)
		end
		self.temp_grade = shengong_info.grade
	end
	self.clear_luck_val:SetValue(shengong_grade_cfg.is_clear_bless == 1)
	self:SetUseImageButtonState(self.cur_select_grade, true)

	if shengong_info.grade >= ShengongData.Instance:GetMaxGrade() then
		self:SetAutoButtonGray()
		self.cur_bless:SetValue(Language.Common.YiMan)
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(shengong_info.grade_bless_val.." / "..shengong_grade_cfg.bless_val_limit)
		if self.is_first then
			self.exp_radio:InitValue(shengong_info.grade_bless_val/shengong_grade_cfg.bless_val_limit)
			self.is_first = false
		else
			self.exp_radio:SetValue(shengong_info.grade_bless_val/shengong_grade_cfg.bless_val_limit)
		end
	end

	local skill_capability = 0
	for i = 0, 3 do
		if ShengongData.Instance:GetShengongSkillCfgById(i) then
			skill_capability = skill_capability + ShengongData.Instance:GetShengongSkillCfgById(i).capability
		end
	end
	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(shengong_grade_cfg)
	local capability = CommonDataManager.GetCapability(attr)
	local all_attr_percent_cap = ShengongData.Instance:CalculateAllAttrCap(capability)
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
	self.show_zizhi_redpoint:SetValue(ShengongData.Instance:IsShowZizhiRedPoint())
	-- self.show_chengzhang_redpoint:SetValue(ShengongData.Instance:IsShowChengzhangRedPoint())
	self.show_huanhua_redpoint:SetValue(ShengongData.Instance:IsCanHuanhuaUpgrade() ~= false)
	local can_uplevel_skill_list = ShengongData.Instance:CanSkillUpLevelList()
	self.show_skill_arrow1:SetValue(can_uplevel_skill_list[1] ~= nil)
	self.show_skill_arrow2:SetValue(can_uplevel_skill_list[2] ~= nil)
	self.show_skill_arrow3:SetValue(can_uplevel_skill_list[3] ~= nil)

	local image_id = ShengongData.Instance:GetShengongGradeCfg(self.cur_select_grade).image_id
	local color = (self.cur_select_grade / 3 + 1) >= 5 and 5 or math.floor(self.cur_select_grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..ShengongData.Instance:GetShengongImageCfg()[image_id].image_name.."</color>" --根据品质更改颜色
	self.shengong_name:SetValue(name_str)

	self.show_equip_remind:SetValue(ShengongData.Instance:CalAllEquipRemind() > 0)
	self.show_fuling_remind:SetValue(AdvanceData.Instance:CalFulingRemind(ShengongImageFulingType.Type))
end

function AdvanceShengongView:SetArrowState(cur_select_grade, no_flush_modle)
	local cur_select_grade = cur_select_grade or self.cur_select_grade
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local max_grade = ShengongData.Instance:GetMaxGrade()
	local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(cur_select_grade)
	if not shengong_info or not shengong_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_right_button:SetValue(cur_select_grade < shengong_info.grade + 1 and cur_select_grade < max_grade)
	self.show_left_button:SetValue(grade_cfg.image_id > 1 or (shengong_info.grade  == 1 and cur_select_grade > shengong_info.grade))
	self:SetUseImageButtonState(cur_select_grade, no_flush_modle)
end

function AdvanceShengongView:SetUseImageButtonState(cur_select_grade, no_flush_modle)
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	local max_grade = ShengongData.Instance:GetMaxGrade()
	local grade_cfg = ShengongData.Instance:GetShengongGradeCfg(cur_select_grade)

	if not shengong_info or not shengong_info.grade or not cur_select_grade or not max_grade or not grade_cfg then
		return
	end
	self.show_use_button:SetValue(cur_select_grade <= shengong_info.grade and grade_cfg.image_id ~= shengong_info.used_imageid)
	self.show_use_image:SetValue(grade_cfg.image_id == shengong_info.used_imageid)
	self:SwitchGradeAndName(self.cur_select_grade, no_flush_modle)
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceShengongView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if nil == shengong_info.grade then
		return
	end
	self:SetPropItemCellsData()
end

-- 设置进阶按钮状态
function AdvanceShengongView:SetAutoButtonGray()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if shengong_info.grade == nil then return end

	local max_grade = ShengongData.Instance:GetMaxGrade()
	local text1= "进阶"
	if not shengong_info or not shengong_info.grade or shengong_info.grade <= 0
		or shengong_info.grade >= max_grade then
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

function AdvanceShengongView:SetModle(is_show, grade, flush_flag)
	if is_show then
		if not ShengongData.Instance:IsActiviteShengong() then
			return
		end
		local goddess_data = GoddessData.Instance
		local info = {}
		info.role_res_id = goddess_data:GetShowXiannvResId()
		if grade then
			self.cur_select_grade = grade
		else
			if self.cur_select_grade == nil or self.is_in_preview == true or flush_flag then
				self.is_in_preview = false
				self.cur_select_grade = ShengongData.Instance:GetShengongInfo().grade
			end
		end
		info.weapon_res_id = ShengongData.Instance:GetShowShengongRes(self.cur_select_grade)
		self:Set3DModel(info)
	end
end

function AdvanceShengongView:Set3DModel(info)
	self.shengong_model:SetGoddessModelResInfo(info)
	local resid = GoddessData.Instance:GetShowXiannvResId()
	self:CalToShowAnim(true)
end

function AdvanceShengongView:CancelTheQuest()
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

function AdvanceShengongView:CalToShowAnim()
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

function AdvanceShengongView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function AdvanceShengongView:RemoveNotifyDataChangeCallBack()
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

function AdvanceShengongView:OnAutoBuyToggleChange(isOn)

end

function AdvanceShengongView:OpenCallBack()
	local shengong_info = ShengongData.Instance:GetShengongInfo()
	if not shengong_info or not next(shengong_info) then return end
	self.is_first = true

	--用于显示模型
	if self.shengong_model == nil then
		self.shengong_model = RoleModel.New("goddess_info_panel")
		self.shengong_model:SetDisplay(self.shengong_display.ui3d_display)
	end

	self.now_level = shengong_info.grade
	self:ShowTextTip()
	self:SetAllAttrPanel()
end

function AdvanceShengongView:ShowTextTip()
	local shengong_info = ShengongData.Instance:GetShengongInfo() or {}
	local level = shengong_info.grade or 0

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

function AdvanceShengongView:CancelPreviewToggle()
	if self.preview_go.toggle.isOn then
		self.preview_go.toggle.isOn = false
	end
end

function AdvanceShengongView:OnFlush(param_list)
	if not ShengongData.Instance:IsActiviteShengong() then
		return
	end
	
	self:JinJieReward()
	
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_shengong)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.goddess_shengong)
	self.bipin_reward:SetValue(vis and not is_get_reward)
	local bipin_redpoint = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.goddess_shengong)
    self.bipin_redpoint:SetValue(bipin_redpoint)

	if self.shengong_display ~= nil then
		self.shengong_display.ui3d_display:ResetRotation()
	end
	self:SetPropItemCellsData()

	if param_list == "shengong" then
		self:SetShengongAtrr()
		self:FlushSkillIcon()
		self:FlushAllAttrPanel()
		return
	end
	for k, v in pairs(param_list) do
		if k == "shengong" then
			self:SetShengongAtrr()
			self:FlushSkillIcon()
		end
	end
end

--------------------------------------------------进阶奖励相关显示---------------------------------------------------
--进阶奖励相关
function AdvanceShengongView:JinJieReward()
	local system_type = JINJIE_TYPE.JINJIE_TYPE_SHENGONG
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
function AdvanceShengongView:ClearJinJieFreeData(target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue("")
		self.free_get_small_target_is_end:SetValue(false)
	else    --大目标
		self.jin_jie_free_time:SetValue("")
		self.jin_jie_is_free:SetValue(false)		
	end
end

--大目标 变动显示
function AdvanceShengongView:BigTargetNotConstantData(system_type, target_type)
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
function AdvanceShengongView:SmallTargetNotConstantData(system_type, target_type)
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
function AdvanceShengongView:SmallTargetConstantData(system_type, target_type)
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
function AdvanceShengongView:BigTargetConstantData(system_type, target_type)
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
function AdvanceShengongView:FulshJinJieFreeTime(end_time, target_type)
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
function AdvanceShengongView:SetJinJieFreeTime(time, target_type)
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
function AdvanceShengongView:FreeTimeShow(time, target_type)
	if target_type and target_type == JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue(time)
	else    --大目标
		self.jin_jie_free_time:SetValue(time)
	end
end

--移除倒计时
function AdvanceShengongView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--打开大目标面板
function AdvanceShengongView:OnClickJinJieAward()
	JinJieRewardCtrl.Instance:OpenJinJieAwardView(JINJIE_TYPE.JINJIE_TYPE_SHENGONG)
end

--打开小目标面板
function AdvanceShengongView:OnClickOpenSmallTarget()
	local function callback()
		local param1 = JINJIE_TYPE.JINJIE_TYPE_SHENGONG
		local param2 = JIN_JIE_REWARD_TARGET_TYPE.SMALL_TARGET
		local req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY

		local is_can_free = JinJieRewardData.Instance:GetSystemSmallIsCanFreeLingQuFromInfo(param1)
		if is_can_free then
			req_type = JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH
		end
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(req_type, param1, param2)
	end

	local data = JinJieRewardData.Instance:GetSmallTargetShowData(JINJIE_TYPE.JINJIE_TYPE_SHENGONG, callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end
