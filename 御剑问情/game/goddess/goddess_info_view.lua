--------------------------------------------------------------------------
-- GoddessInfoView 女神信息面板
--------------------------------------------------------------------------
local DisCountGoddessPrase = 2
GoddessInfoView = GoddessInfoView or BaseClass(BaseRender)

function GoddessInfoView:__init(instance)
	self:InitView()
	local id = GoddessData.Instance:GetMainCampID()
	self.xiannv_id = id
	self:SetCurrentXiannvID(id)
end

function GoddessInfoView:__delete()
	self.right_info_view:DeleteMe()
	self.right_info_view = nil

	self.left_info_view:DeleteMe()
	self.left_info_view = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.goddess_display = nil
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.time_runquest then
		GlobalTimerQuest:CancelQuest(self.time_runquest)
		self.time_runquest = nil
	end
	self:RemoveCountDown()
	self.btn_tip_anim = nil
	self.btn_tip_anim_flag = nil
	self.bipin_redpoint = nil
end

function GoddessInfoView:InitView()
	self:ListenEvent("huan_hua_click", BindTool.Bind(self.HuanHuaBtnOnClick, self))
	self:ListenEvent("cancel_click", BindTool.Bind(self.CancelBtnOnClick, self))
	self:ListenEvent("OnClickGoTo", BindTool.Bind(self.OnClickGoTo, self))
	self:ListenEvent("OnClickSendMsg", BindTool.Bind(self.OnClickSendMsg, self))
	self:ListenEvent("OnClickChuZhan", BindTool.Bind(self.OnClickChuZhan, self))
	self:ListenEvent("OnClickBiPingReward", BindTool.Bind(self.OnClickBiPingReward, self))
	self:ListenEvent("OnClickOpenSpecialGoddess", BindTool.Bind(self.OnClickOpenSpecialGoddess, self))
	self:ListenEvent("OnClickSpecialTitle",BindTool.Bind(self.OnClickSpecialTitle, self))

	self.goddess_display = self:FindObj("goddess_display")

	self.bipin_redpoint = self:FindVariable("BiPinRedPoint")
	self.bipin_reward = self:FindVariable("BiPinIconReward")
	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_info)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.goddess_info)
	self.bipin_reward:SetValue(vis and not is_get_reward)
	self.btn_tip_anim = self:FindObj("BtnTipAnim")
	self.btn_tip_anim_flag = true

	self.model_view = RoleModel.New("goddess_info_panel")
	self.model_view:SetDisplay(self.goddess_display.ui3d_display)

	self.right_info_view = GoddessInfoRightView.New(self:FindObj("talent_content"))
	self.right_info_view.parent = self
	self.left_info_view = GoddessInfoLeftView.New(self:FindObj("goddess_icon_content"))
	self.left_info_view.parent = self
	self.is_show_in_camp = self:FindVariable("is_show_in_camp")
	self.show_cancel_btn = self:FindVariable("show_cancel_btn")
	self.get_way_text = self:FindVariable("get_way_text")
	self.show_get_way = self:FindVariable("show_get_way")
	self.huanhua_red_point = self:FindVariable("huanhua_red_point")
	self.show_goto = self:FindVariable("ShowGoto")
	self.show_chuzhan = self:FindVariable("show_chuzhan")

	self.show_limit_text = self:FindVariable("ShowLimitText")
	self.free_time = self:FindVariable("LimitFreeTime")
	self.show_special_effect = self:FindVariable("ShowSpecialEffect")
	self.add_attr_per = self:FindVariable("AddAtrrPer")
	self.show_title_btn = self:FindVariable("ShowTitleBtn")
    self.show_specia_btn =self:FindVariable("ShowSpecialBtn")
    self.special_goddess_icon = self:FindVariable("SpecialGoddessIcon")
    self.title_asset = self:FindVariable("TitleAsset")
    self.title_power = self:FindVariable("TitlePower")
    self.title_gray = self:FindVariable("TitleGray")
    self.show_title_time = self:FindVariable("ShowTitleTime")

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.Goddess_HuanHua)
end

function GoddessInfoView:RemindChangeCallBack(remind_name, num)
	if RemindName.Goddess_HuanHua == remind_name then
		self.huanhua_red_point:SetValue(num > 0)
	end
end

--引导用函数
function GoddessInfoView:GetUpGradeBtn()
	return self.right_info_view and self.right_info_view:GetUpGradeBtn()
end

function GoddessInfoView:GetActiveBtn()
	return self.right_info_view and self.right_info_view:GetActiveBtn()
end

function GoddessInfoView:OnFlush(param_t)
	if self.time_runquest then
		GlobalTimerQuest:CancelQuest(self.time_runquest)
		self.time_runquest = nil
	end

	local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.goddess_info)
	local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.goddess_info)
	self.bipin_reward:SetValue(vis and not is_get_reward)
	local bipin_redpoint = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.goddess_info)
    self.bipin_redpoint:SetValue(bipin_redpoint)

	self.model_view:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
	self.time_runquest = GlobalTimerQuest:AddRunQuest(function()
	self.model_view:SetTrigger(GoddessData.Instance:GetShowTriggerName(1))
	end,15) --播放一次动画

	local resid = 0
	--判断是否幻化
	if GoddessData.Instance:GetHuanHuaId() == -1 then
		resid = GoddessData.Instance:GetXianNvCfg(self.current_xiannv_id).resid
	else
		resid = GoddessData.Instance:GetXianNvHuanHuaCfg(GoddessData.Instance:GetHuanHuaId()).resid
	end
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
	-- self:CalToShowAnim(true) --循环随机播放动画
	self:SetCurrentXiannvID(self.xiannv_id)  --设置已出战状态
	self:FlushRightView()

	local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
	if goddess_role_view then
		local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(self.xiannv_id)
		local name = xian_nv_cfg.name
		local quality =ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item).color
		goddess_role_view:OnFlush(name, quality, self.xiannv_id)
	end

	--特殊伙伴限时时间
    local free_remind_time = GoddessData.Instance:GetSpecialGoddessFreeTime()
    if free_remind_time <= 0 then
        self.show_limit_text:SetValue(false) 
    else
        self:RemoveCountDown()
        self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
    end
    self:FlushSpecialButtonState()
    self:ShowSpecialButton()
end

function GoddessInfoView:CalToShowAnim(is_change_tab)
	self:PlayAnim(is_change_tab)
end

function GoddessInfoView:PlayAnim(is_change_tab)
	local count = 1
	self.model_view:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
end

function GoddessInfoView:HuanHuaBtnOnClick()
	ViewManager.Instance:Open(ViewName.GoddessHuanHua)
end

function GoddessInfoView:CancelBtnOnClick()
	GoddessCtrl.Instance:SentXiannvImageReq(-1)
end

function GoddessInfoView:UpdateAttributeView(xiannv_id,xiannv_zhi_zi)
	local attr = GoddessData.Instance:GetXiannvAttr(xiannv_id)
	if self.right_info_view then
		self.right_info_view:UpdateAttributeView(attr)
	end
	local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
	if goddess_role_view then
		local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
		local quality =ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item).color
		goddess_role_view:SetLevelValue(xiannv_zhi_zi, quality)
	end
end

function GoddessInfoView:FlushRightView()
	if self.current_xiannv_id == nil then return end
	local level = GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi
	self:UpdateAttributeView(self.current_xiannv_id, level > 0 and level or 1)
end

function GoddessInfoView:ActiveOrUgrageBtn(xiannv_level)
	if self.right_info_view then
		self.right_info_view:ActiveOrUgrageBtn(xiannv_level)
	end
	if xiannv_level <= 0 then
		self.show_chuzhan:SetValue(false)
	else
		self.show_chuzhan:SetValue(true)
	end
end

function GoddessInfoView:SetCurrentXiannvID(xiannv_id)
	local goddess_data = GoddessData.Instance
	self.current_xiannv_id = xiannv_id
	self.is_show_in_camp:SetValue(goddess_data:JudgeXiannvIsInMainCamp(xiannv_id))
	self.show_get_way:SetValue(not (goddess_data:GetXianNvItem(xiannv_id).xn_zizhi > 0) and self:IsHideGoTo(xiannv_id))
	self.get_way_text:SetValue(goddess_data:GetXianNvCfg(xiannv_id).get_way)

	local open_panel = goddess_data:GetXianNvCfg(xiannv_id).open_panel
	self.show_goto:SetValue(nil ~= open_panel and "" ~= open_panel)
	self:FlushCancelBtn()
end

function GoddessInfoView:IsHideGoTo(xiannv_id)
	local is_activity_open = true
	local is_active = false
	local attr = GoddessData.Instance:GetXiannvAttr(xiannv_id)
	-- 策划需求一折抢购-女神特惠专场没结束，即使有了相关激活卡，也依然显示获取途径
	if nil ~= attr and attr.need_mat_value <= attr.have_mat_value and (xiannv_id ~= 5 or xiannv_id == 2) then
		is_active = true
	end

	if xiannv_id == 5 or xiannv_id == 2 then
		-- 一折抢购(女神特惠)
		is_activity_open = nil ~= DisCountData.Instance:GetDiscountInfoByType(DisCountGoddessPrase)
	elseif xiannv_id == 1 or xiannv_id == 3 or xiannv_id == 4 then
		-- 嘉年华
		is_activity_open = OpenFunData.Instance:CheckIsHide("molongmibaoview") and MolongMibaoData.Instance:IsShowMolongMibao()
	end

	return is_activity_open and not is_active
end

function GoddessInfoView:FlushGetWay()
	self.show_get_way:SetValue(not (GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi > 0))
end

function GoddessInfoView:FlushCancelBtn()
	local goddess_data = GoddessData.Instance
	local huanhua_id = goddess_data:GetHuanHuaId()
	local chuzhan_id = goddess_data:GetXianNvPos()[1]
	if self.show_cancel_btn then
		--self.show_cancel_btn:SetValue(huanhua_id >= 0)  --屏蔽使用幻化之后女神信息面板中的“取消使用幻化”按钮
	end
end

function GoddessInfoView:GetCurrentXiannvID()
	return self.current_xiannv_id
end

function GoddessInfoView:UpgradeXiannv()
	local xn_zizhi = GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi
	local zhi_zhi_cfg = GoddessData.Instance:GetXianNvZhiziCfg(self.current_xiannv_id,xn_zizhi)
	if nil == zhi_zhi_cfg then
		return
	end
	local upgrade_item_id = zhi_zhi_cfg.uplevel_stuff_id
	local upgrade_num = zhi_zhi_cfg.uplevel_stuff_num
	local item_num = ItemData.Instance:GetItemNumInBagById(upgrade_item_id)
	if item_num < upgrade_num then
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[upgrade_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(upgrade_item_id)
			return
		end
		return
	end
	if xn_zizhi >= GODDRESS_MAX_LEVEL then
		return
	end
	GoddessCtrl.Instance:SentXiannvAddZizhiReq(self.current_xiannv_id)
end

function GoddessInfoView:ActiveXiannv()
	local active_cfg = GoddessData.Instance:GetXianNvCfg(self.current_xiannv_id)
	local active_item_id = active_cfg.active_item
	local item_num = ItemData.Instance:GetItemNumInBagById(active_item_id)
	if item_num > 0 then
		GoddessCtrl.Instance:SendCSXiannvActiveReq(self.current_xiannv_id, active_item_id)
		self.right_info_view:ActiveOrUgrageBtn(1)
	else
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[active_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(active_item_id)
			return
		end
	end
end

function GoddessInfoView:OnClickSendMsg()
	local name = ""
	local color = TEXT_COLOR.WHITE
	local btn_color = 0

	local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(self.current_xiannv_id)
	local xn_zizhi = GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi
	if xn_zizhi <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.NeedActiveGoddess)
		return
	end

	-- 发送冷却CD
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		time = math.ceil(time)
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item)
	if nil ~= item_cfg then
		color = SOUL_NAME_COLOR_CHAT[item_cfg.color]
		name = xian_nv_cfg.name
		btn_color = item_cfg.color
	end

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local content = string.format(Language.Chat.AdvancePreviewLinkList[6], game_vo.role_id, name, color, btn_color, CHECK_TAB_TYPE.GODDESS)
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)

	ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
	TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendSucc)
end

--响应出战按钮
function GoddessInfoView:OnClickChuZhan()
	local temp_table = {self.xiannv_id, -1, -1, -1}
	GoddessCtrl.Instance:SendCSXiannvCall(temp_table)	--出战当前选择的伙伴
end

function GoddessInfoView:OnClickBiPingReward()
	if self.btn_tip_anim_flag then
		self.btn_tip_anim.animator:SetBool("isClick", false)
	end
	ViewManager.Instance:Open(ViewName.CompetitionTips)
end

function GoddessInfoView:OnClickOpenSpecialGoddess()
	ViewManager.Instance:Open(ViewName.GoddessSpecialTipView)
end

function GoddessInfoView:OnClickSpecialTitle()
    local title_cfg = GoddessData.Instance:GetSpecialTitleCfg()
    if title_cfg == nil then
        return
    end
    local time_stamp = GoddessData.Instance:GetSpecialGoddessFreeTime()
    local is_new_player = GoddessData.Instance:IsNewGoddessSystemPlayer()
   	if is_new_player == 0 then
   		time_stamp = 0 
   	end
    local can_fetch = GoddessData.Instance:CanGetTitleFetchFlag()
    local function fetch_callback()
    	if can_fetch == 0 then
        	GoddessCtrl.Instance:SentXiannvSmallTargetOperaReq(SPECIAL_TITLE_OPER_TYPE.OPERA_TYPE_BUY_SMALL_TARGET_TITLE_CARD)
        else
        	GoddessCtrl.Instance:SentXiannvSmallTargetOperaReq(SPECIAL_TITLE_OPER_TYPE.OPERA_TYPE_GET_SMALL_TARGET_TITLE_CARD)
        end
    end
    local other_cfg = GoddessData.Instance:GetXianNvOtherCfg()
    if next(other_cfg) == nil then
    	return
    end
    local stitle_target_info = CommonStruct.TimeLimitTitleInfo()
    stitle_target_info.item_id = title_cfg.item_id
    stitle_target_info.cost = title_cfg.cost
    stitle_target_info.left_time = time_stamp or 0
    stitle_target_info.can_fetch = can_fetch == 1
    stitle_target_info.from_panel = "goddess"
    stitle_target_info.call_back = fetch_callback

    TipsCtrl.Instance:ShowTimeLimitTitleView(stitle_target_info)
end

--设置时间
function GoddessInfoView:SetTime(time)
    local show_time_str = ""
    if time > 3600 * 24 then
        show_time_str = TimeUtil.FormatSecond(time, 7)
    elseif time > 3600 then
        show_time_str = TimeUtil.FormatSecond(time, 1)
    else
        show_time_str = TimeUtil.FormatSecond(time, 4)
    end
    self.free_time:SetValue(show_time_str)
end

function GoddessInfoView:FlushCountDown(elapse_time, total_time)
    local time_interval = total_time - elapse_time
    if time_interval > 0 then
        self:SetTime(time_interval)
    else
        self.show_limit_text:SetValue(false)
    end
end

function GoddessInfoView:RemoveCountDown()
    if CountDown.Instance:HasCountDown(self.count_down) then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end

function GoddessInfoView:FlushSpecialButtonState()
	local item_id = GoddessData.Instance:GetSpecialGoddessItemId()
	local has_card_in_bad = ItemData.Instance:GetItemIndex(item_id)
	local active_flag = GoddessData.Instance:GetSpecialGoddessActiveFlag() or 0  --是否激活
	local can_fetch = GoddessData.Instance:GetSpecialGoddessFetchFlag() or 0    --能否领取
	local has_fetch = GoddessData.Instance:HasGetSpecialGoddess() or 0           --是否领取
	local is_new_player = GoddessData.Instance:IsNewGoddessSystemPlayer() or 0   --是否是新玩家
	local free_remind_time = GoddessData.Instance:GetSpecialGoddessFreeTime() or 0
	local other_cfg = GoddessData.Instance:GetXianNvOtherCfg()
	if next(other_cfg) == nil then
		return 
	end
	local can_title_fetch = GoddessData.Instance:CanGetTitleFetchFlag()
	self.title_gray:SetValue(can_title_fetch)
	self.show_title_time:SetValue(is_new_player == 1 and free_remind_time > 0 and can_title_fetch == 0)
	self.special_goddess_icon:SetAsset(ResPath.GetItemIcon(item_id))
	self.add_attr_per:SetValue(other_cfg.attr_percent / 100)
	self.show_special_effect:SetValue(active_flag ~= 1)
    self.show_limit_text:SetValue(is_new_player == 1 and can_fetch ~= 1 and free_remind_time > 0 and has_card_in_bad == -1 and active_flag ~= 1 and has_fetch ~= 1)
end

--称号/超级按钮
function GoddessInfoView:ShowSpecialButton()
	local title_cfg = GoddessData.Instance:GetSpecialTitleCfg()
	if title_cfg == nil then
		return
	end
   local show_big_btn = GoddessData.Instance:ShowSmallTargetBtn()
   -- self.show_title_btn:SetValue(show_title_btn)
   self.show_specia_btn:SetValue(show_big_btn)
   self.title_power:SetValue(title_cfg.power)
   local bundle,asset = ResPath.GetTitleIcon(title_cfg.title_id)
   self.title_asset:SetAsset(bundle,asset)
end

-- 点击前往
function GoddessInfoView:OnClickGoTo()
	local cfg = GoddessData.Instance:GetXianNvCfg(self.current_xiannv_id)
	if nil == cfg then return end
	--一折抢购女神特惠
	if self.current_xiannv_id == 5 or self.current_xiannv_id == 2 then
		local info_list = Split(cfg.open_panel, "#")
		local view_name = info_list[1]
		if view_name == ViewName.VipView then
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
			VipData.Instance:SetOpenParam(tonumber(info_list[3]))
			ViewManager.Instance:OpenByCfg(cfg.open_panel)
		end

        if nil ~= DisCountData.Instance:GetDiscountInfoByType(DisCountGoddessPrase) then
			local v, k = DisCountData.Instance:GetDiscountInfoByType(DisCountGoddessPrase)
			VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
            ViewManager.Instance:Open(view_name, nil, "index", {k})
			return
		end
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.GoddessActiveEndTip)

	else
		ViewManager.Instance:OpenByCfg(cfg.open_panel)
	end
end

function GoddessInfoView:AllCellOnFlush()
	if self.left_info_view then
		self.left_info_view:AllCellOnFlush()
	end
end

function GoddessInfoView:SetScrollSelect()
	if self.left_info_view then
		self.left_info_view:SetCellSelectActive()
		self.left_info_view:SetSingleCellSelectActive(self.current_xiannv_id)
	end
	self:ActiveOrUgrageBtn(GoddessData.Instance:GetXianNvItem(self.current_xiannv_id).xn_zizhi)
end

function GoddessInfoView:SetToIconIndex(index)
	if self.time_quest then return end
	-- self.current_xiannv_id = index
	self:SetCurrentXiannvID(index)
	if self.left_info_view then
		self.left_info_view:ReloadData()
	end
	self:JumpToIcon(index)

	local goddess_view = GoddessCtrl.Instance:GetView()
	if goddess_view then
		goddess_view:SetModel(index)
	end
	self.xiannv_id = index
	self:OnFlush()
end

function GoddessInfoView:ReloadData()
	if self.left_info_view then
		self.left_info_view:ReloadData()
	end
end

function GoddessInfoView:JumpToIcon(index)
	self:CanCelTheQuest()
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		if self.left_info_view then
			self.left_info_view:DownBtnOnClick(index)
			self.left_info_view:ToClickIcon()
		end
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end, 0.2)
end

function GoddessInfoView:CanCelTheQuest()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end
--------------------------------------------------------------------------
-- 左面板
--------------------------------------------------------------------------
GoddessInfoLeftView = GoddessInfoLeftView or BaseClass(BaseRender)
function GoddessInfoLeftView:__init(instance)
	self.up_btn = self:FindObj("up_btn")
	self.down_btn = self:FindObj("down_btn")

	self:ListenEvent("up_btn", BindTool.Bind(self.UpBtnOnClick, self))
	self:ListenEvent("down_btn", BindTool.Bind(self.DownBtnOnClick, self))

	self.icon_cell_list = {}
	self.current_icon_index = 0
	self.is_select = false
	self:InitListView()

	self.current_icon_cell = nil
	self.index_list = {}
	self.up_btn:SetActive(false)
end

function GoddessInfoLeftView:UpBtnOnClick(turn_page)
	local turn_page = turn_page or 1
	local position = self.scroller_list_view.scroller.ScrollPosition
	local index = self.scroller_list_view.scroller:GetCellViewIndexAtPosition(position)
	self:BagJumpPage(index - turn_page)
	self:SetBtnActive()
end

function GoddessInfoLeftView:DownBtnOnClick(turn_page)
	local turn_page = turn_page or 1
	local position = self.scroller_list_view.scroller.ScrollPosition
	local index = self.scroller_list_view.scroller:GetCellViewIndexAtPosition(position)
	self:BagJumpPage(index + turn_page)
	self:SetBtnActive()
end

function GoddessInfoLeftView:BagJumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.scroller_list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.scroller_list_view.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

function GoddessInfoLeftView:SetBtnActive()
	local position = self.scroller_list_view.scroller.ScrollPosition
	local index  = self.scroller_list_view.scroller:GetCellViewIndexAtPosition(position)
	if index < 1 then
		self.up_btn:SetActive(false)
	else
		self.up_btn:SetActive(true)
	end
	if index < 3 then
		self.down_btn:SetActive(true)
	else
		self.down_btn:SetActive(false)
	end
end

function GoddessInfoLeftView:AllCellOnFlush()
	if self.scroller_list_view.scroller.isActiveAndEnabled then
		self.scroller_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--ListView逻辑
function GoddessInfoLeftView:InitListView()
	self.scroller_list_view = self:FindObj("icon_list_view")
	self.scroller_list_view.scroller.scrollerScrollingChanged = function ()
		self:SetBtnActive()
	end
	self.scroller_list_view.scroller.scrollerScrolled = function ()

	end

	local list_delegate = self.scroller_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function GoddessInfoLeftView:GetNumberOfCells()
	return GameEnum.MAX_XIANNV_ID + 1
end

function GoddessInfoLeftView:RefreshCell(cell, data_index, cell_index)
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = GoddessIconCell.New(cell.gameObject, self)
		self.icon_cell_list[cell] = icon_cell
	end
	data_index = data_index + 1
	icon_cell:SetXiannvId(data_index)
	icon_cell:OnFlush()
end

function GoddessInfoLeftView:SetCellSelectActive()
	for k,v in pairs(self.icon_cell_list) do
		v:SetCellSelectActive(false)
	end
end

function GoddessInfoLeftView:SetSingleCellSelectActive(xiannv_id)
	for k,v in pairs(self.icon_cell_list) do
		if v:GetXiannvId() == xiannv_id then
			v:SetCellSelectActive(true)
			local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(xiannv_id)
			local name = xian_nv_cfg.name
			local quality =ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item).color
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(name, quality, xiannv_id)
			end

			local level = GoddessData.Instance:GetXianNvItem(xiannv_id).xn_zizhi
			if level > 0 then
				self.parent:UpdateAttributeView(xiannv_id,level)
			else
				self.parent:UpdateAttributeView(xiannv_id,0)
			end
			break
		end
	end
end

function GoddessInfoLeftView:SetIsSelect(is_select)
	self.is_select = is_select
end

function GoddessInfoLeftView:ToClickIcon()
	for k,v in pairs(self.icon_cell_list) do
		v:ToClickIcon()
	end
end

function GoddessInfoLeftView:ReloadData()
	self.scroller_list_view.scroller:ReloadData(0)
end
--------------------------------------------------------------------------
--GoddessInfoRightView 	女神信息面板的右面板
--------------------------------------------------------------------------
GoddessInfoRightView = GoddessInfoRightView or BaseClass(BaseRender)
function GoddessInfoRightView:__init(instance)
	self:InitView()
	self.current_xiannv_level = 0
end

function GoddessInfoRightView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function GoddessInfoRightView:InitView()
	self:ListenEvent("upgrade",BindTool.Bind(self.UpGradeBtnOnClick, self))
	self:ListenEvent("active",BindTool.Bind(self.ActiveBtnOnClick, self))
	self.upgrade_btn = self:FindObj("upgrade_btn")
	self.active_btn = self:FindObj("active_btn")
	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
			self.item_cell:SetToggle(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ListenClick(handler)

	self.power_value = self:FindVariable("power_value")
	self.skill_name = self:FindVariable("skill_name")
	self.gongji = self:FindVariable("attack_value")
	self.fangyu = self:FindVariable("defense_value")
	self.maxhp = self:FindVariable("hp_value")
	self.xiannv_gongji = self:FindVariable("shanghai_value")
	self.need_mat_value = self:FindVariable("need_mat_value")
	self.have_mat_value = self:FindVariable("have_mat_value")
	self.skill_desc = self:FindVariable("skill_desc")
	self.skill_image = self:FindVariable("skill_image")
	self.the_desc = self:FindVariable("the_desc")
	self.need_value_text = self:FindVariable("need_value_text")
	self.show_frame = self:FindVariable("show_frame")
	self.show_tips_text = self:FindVariable("show_tips_text")
end

function GoddessInfoRightView:GetUpGradeBtn()
	return self.upgrade_btn
end

function GoddessInfoRightView:GetActiveBtn()
	return self.active_btn
end

function GoddessInfoRightView:ActiveOrUgrageBtn(xiannv_level)
	self.upgrade_btn.button.interactable = true
	self.upgrade_btn.grayscale.GrayScale = 0
	if xiannv_level <= 0 then
		self.show_frame:SetValue(true)
		self.show_tips_text:SetValue(false)
		self.upgrade_btn:SetActive(false)
		self.active_btn:SetActive(true)
		self.the_desc:SetValue(Language.Common.ActiveNeed)
	elseif xiannv_level > 0 and xiannv_level < GODDRESS_MAX_LEVEL then
		self.show_frame:SetValue(true)
		self.show_tips_text:SetValue(false)
		self.upgrade_btn:SetActive(true)
		self.active_btn:SetActive(false)
		self.the_desc:SetValue(Language.Common.UpgradeNeed)
	elseif xiannv_level == GODDRESS_MAX_LEVEL then
		self.show_frame:SetValue(false)
		self.show_tips_text:SetValue(true)
		self.active_btn:SetActive(false)
		self.upgrade_btn:SetActive(true)
		self.upgrade_btn.grayscale.GrayScale = 255
		self.upgrade_btn.button.interactable = false
		self.the_desc:SetValue(Language.Common.UpgradeNeed)
	end
end

function GoddessInfoRightView:UpGradeBtnOnClick()
	self.parent:UpgradeXiannv()
end

function GoddessInfoRightView:ActiveBtnOnClick()
	self.parent:ActiveXiannv()
end

function GoddessInfoRightView:UpdateAttributeView(attr)
	self.gongji:SetValue(attr.gongji)
	self.fangyu:SetValue(attr.fangyu)
	self.maxhp:SetValue(attr.maxhp)
	self.xiannv_gongji:SetValue(attr.xiannv_gongji)
	local value_text = ""
	if attr.have_mat_value < attr.need_mat_value then
		value_text = ToColorStr(attr.have_mat_value .. "", TEXT_COLOR.RED) .. ToColorStr(" / " .. attr.need_mat_value .. "", TEXT_COLOR.BLACK_1)
	else
		value_text = ToColorStr(attr.have_mat_value .. "", TEXT_COLOR.BLUE_SPECIAL) .. ToColorStr(" / " .. attr.need_mat_value .. "", TEXT_COLOR.BLACK_1)
	end
	self.need_value_text:SetValue(value_text)
	self.skill_name:SetValue(attr.skill_name)
	self.power_value:SetValue(attr.power)
	self.skill_image:SetAsset(attr.bundle,attr.asset)
	self.skill_desc:SetValue(attr.skill_desc)
	self.item_cell:SetData(attr.info)
end
--------------------------------------------------------------------------
--GoddessIconCell 	格子
--------------------------------------------------------------------------
GoddessIconCell = GoddessIconCell or BaseClass(BaseCell)

function GoddessIconCell:__init(instance, left_view)
	self.left_view = left_view
	self:IconInit()
end

function GoddessIconCell:IconInit()
	self.icon_select = self:FindObj("icon_select")
	self.icon_name = self:FindVariable("icon_name")
	self.show_red_point = self:FindVariable("show_red_point")
	self.show_icon_white = self:FindVariable("show_icon_white")
	self.icon = self:FindVariable("icon")
	self:ListenEvent("icon_btn_click",BindTool.Bind(self.IconOnClick, self))
	self:ListenEvent("grey_image_click",BindTool.Bind(self.GreyImageOnClick, self))
	self.set_grey_image = self:FindObj("set_grey_image")
	self.sprite_grayscale = self:FindObj("sprite")
	self.xiannv_id = -1
	self.is_select = false
end

function GoddessIconCell:IconOnClick()
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view then
		if goddess_info_view:GetCurrentXiannvID() ~= self.xiannv_id then
			local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(self.xiannv_id)
			local xiannv_name = xian_nv_cfg.name
			local quality =ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item).color
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(xiannv_name, quality, self.xiannv_id)
			end
			self.left_view:SetCellSelectActive()
			self.is_select = true
			self.icon_select:SetActive(true)
			local xiannv_level = GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi
			goddess_info_view:SetCurrentXiannvID(self.xiannv_id)
			goddess_info_view:UpdateAttributeView(self.xiannv_id,xiannv_level)
			goddess_info_view:ActiveOrUgrageBtn(xiannv_level)
			local goddess_view = GoddessCtrl.Instance:GetView()
			if goddess_view then
				goddess_view:SetModel(self.xiannv_id)
			end
			goddess_info_view.xiannv_id = self.xiannv_id
			goddess_info_view:OnFlush()
		end
	end
end

function GoddessIconCell:GreyImageOnClick()
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view then
		if goddess_info_view:GetCurrentXiannvID() ~= self.xiannv_id then
			local xian_nv_cfg = GoddessData.Instance:GetXianNvCfg(self.xiannv_id)
			local xiannv_name = xian_nv_cfg.name
			local quality =ItemData.Instance:GetItemConfig(xian_nv_cfg.active_item).color
			local goddess_role_view = GoddessCtrl.Instance:GetRoleView()
			if goddess_role_view then
				goddess_role_view:OnFlush(xiannv_name, quality, self.xiannv_id)
			end
			self.left_view:SetCellSelectActive()
			self.is_select = true
			self.icon_select:SetActive(true)
			goddess_info_view:SetCurrentXiannvID(self.xiannv_id)
			goddess_info_view:UpdateAttributeView(self.xiannv_id,1)
			goddess_info_view:ActiveOrUgrageBtn(0)
			local goddess_view = GoddessCtrl.Instance:GetView()
			if goddess_view then
				goddess_view:SetModel(self.xiannv_id)
			end
			goddess_info_view.xiannv_id = self.xiannv_id
			goddess_info_view:OnFlush()
		end
	end
end

function GoddessIconCell:ToClickIcon() --手动
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view:GetCurrentXiannvID() == self.xiannv_id then
		if GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi > 0 then
			self:IconOnClick()
		else
			self:GreyImageOnClick()
		end
	end
end

function GoddessIconCell:SetIsSelect(is_select)
	self.is_select = is_select
end

function GoddessIconCell:SetCellSelectActive(is_active)
	self.icon_select:SetActive(is_active)
end

function GoddessIconCell:SetXiannvId(index)
	self.xiannv_id = GoddessData.Instance:GetShowXnIdList()[index]
end

function GoddessIconCell:GetXiannvId()
	return self.xiannv_id
end

function GoddessIconCell:OnFlush()
	local xiannv_item = GoddessData.Instance:GetXianNvItem(self.xiannv_id)
	if nil == xiannv_item then
		return
	end
	local goddess_info_view = GoddessCtrl.Instance:GetGoddessInfoView()
	if goddess_info_view then
		goddess_info_view:SetScrollSelect()
	end
	self.set_grey_image:SetActive(xiannv_item.xn_zizhi <= 0)
	if xiannv_item.xn_zizhi <= 0 then
		self.sprite_grayscale.grayscale.GrayScale = 254
		self.show_icon_white:SetValue(true)
	else
		self.sprite_grayscale.grayscale.GrayScale = 0
		self.show_icon_white:SetValue(false)
	end
	self.icon_name:SetValue(GoddessData.Instance:GetXianNvCfg(self.xiannv_id).name)
	if xiannv_item.xn_zizhi > 0 and goddess_info_view and self.xiannv_id == goddess_info_view:GetCurrentXiannvID() then
		goddess_info_view:UpdateAttributeView(self.xiannv_id,xiannv_item.xn_zizhi)
	end
	local res_id = GoddessData.Instance:GetXianNvCfg(self.xiannv_id).resid
	local bundle, asset = ResPath.GetGoddessIcon(res_id)
	self.icon:SetAsset(bundle, asset)
	local is_chuzhan = false
	self:SetRedPoint()
end

function GoddessIconCell:SetRedPoint()
	self.show_red_point:SetValue(false)
	local level = GoddessData.Instance:GetXianNvItem(self.xiannv_id).xn_zizhi
	local zhizhi_cfg = GoddessData.Instance:GetXianNvZhiziCfg(self.xiannv_id, level)
	local need_item = 0
	local need_num = 0
	if level < 1 then
		need_item = GoddessData.Instance:GetXiannvActiveItemID(self.xiannv_id, level)
		need_num = 1
	else
		need_item = zhizhi_cfg.uplevel_stuff_id
		need_num = zhizhi_cfg.uplevel_stuff_num
	end
	local bag_item_count = ItemData.Instance:GetItemNumInBagById(need_item)
	if bag_item_count >= need_num and level < GODDRESS_MAX_LEVEL then
		self.show_red_point:SetValue(true)
	end
end

