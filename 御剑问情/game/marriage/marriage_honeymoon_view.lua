MarriageHoneymoonView = MarriageHoneymoonView or BaseClass(BaseRender)

local EFFECT_CD = 1
local SEND_CD = 10 				--发送脱单宣言CD
local MarryTabIndex = {
	Lover = 1,
	Ring = 2,
	Hunyan = 3,
	Equip = 4,
	LoveContract = 5,
}
function MarriageHoneymoonView:__init()
	self.effect_cd = 0
	self.marry_figt_endtime = 0

	self.self_display = self:FindObj("SelfDisplay")
	self.love_display = self:FindObj("LoveDisplay")
	self.effect_root = self:FindObj("EffectRoot")

	self.bless_reward_icon = self:FindVariable("BlessRewardIcon")
	self.progress_value = self:FindVariable("ProgressValue")
	self.progress_text = self:FindVariable("ProgressText")
	self.is_marry = self:FindVariable("IsMarry")
	self.lover_name = self:FindVariable("LoverName")
	self.lover_is_girl = self:FindVariable("LoverIsGirl")
	self.ring_can_upgrade = self:FindVariable("RingCanUpgrade")
	self.ring_had_active = self:FindVariable("RingHadActive")
	self.button_text = self:FindVariable("ButtonText")
	self.self_name = self:FindVariable("SelfName")
	self.self_name:SetValue(GameVoManager.Instance:GetMainRoleVo().name)
	self.self_level = self:FindVariable("SelfLevel")
	self.lover_level = self:FindVariable("LoverLevel")
	self.self_ring = self:FindVariable("SelfRing")
	self.lover_ring = self:FindVariable("LoverRing")

	self.is_max = self:FindVariable("IsMax")
	self.now_level = self:FindVariable("NowLevel")
	self.now_gongji = self:FindVariable("NowGongJi")
	self.now_fangyu = self:FindVariable("NowFangYu")
	self.now_hp = self:FindVariable("NowHp")
	self.next_level = self:FindVariable("NextLevel")
	self.next_gongji = self:FindVariable("NextGongJi")
	self.next_fangyu = self:FindVariable("NextFangYu")
	self.next_hp = self:FindVariable("NextHp")
	self.tuodan_btn_text = self:FindVariable("TuoDanBtnText")
	self.show_cd_time = self:FindVariable("ShowCDTime")
	self.btn_hunyan = self:FindVariable("BtnHunYan")
	self.btn_qiyue = self:FindVariable("BtnQiYue")
	self.show_marry_gift = self:FindVariable("ShowMarryGift")
	self.marry_gift_time = self:FindVariable("MarryGiftTime")
	self.show_marry_gift_eff = self:FindVariable("ShowMarryGiftEff")

	self.power = self:FindVariable("Power")
	self.had_ring_item = self:FindVariable("HadRingItem")

	self.red_point_list = {
		[RemindName.MarryParty] = self:FindVariable("ShowWeddingRedPoint"),
		[RemindName.MarryLoveContent] = self:FindVariable("ShowLoveContentRedPoint"),
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.ring_cell = ItemCell.New()
	self.ring_cell:SetInstanceParent(self:FindObj("RingCell"))
	self.ring_cell:SetData(nil)
	self.ring_cell:SetInteractable(false)
	self.now_ring_item_id = 0

	self.heart_list = {}
	local obj_group = self:FindObj("HeartGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "Little_Heart") ~= nil then
			self.heart_list[count] = U3DObject(obj)
			count = count + 1
		end
	end
	self.ring_item_cell = ItemCellReward.New()
	self.ring_item_cell:SetInstanceParent(self:FindObj("RingItemCell"))

	self.button_text:SetValue(Language.Common.AutoUpgrade)

	self:ListenEvent("UpgradeRingClick", BindTool.Bind(self.UpgradeRingClick, self))
	self:ListenEvent("GoToMarryClick", BindTool.Bind(self.GoToMarryClick, self))
	self:ListenEvent("AutoUpgradeClick", BindTool.Bind(self.AutoUpgradeRingClick, self))
	self:ListenEvent("OpenMail", BindTool.Bind(self.OpenMail, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickDivorce", BindTool.Bind(self.ClickDivorce, self))
	self:ListenEvent("ClickMonomer", BindTool.Bind(self.ClickMonomer, self))
	self:ListenEvent("HideOrShowMonomer", BindTool.Bind(self.HideOrShowMonomer, self))
	self:ListenEvent("OpenHunYan", BindTool.Bind(self.OpenHunYan, self))
	self:ListenEvent("OpenLoverContact", BindTool.Bind(self.OpenLoverContact, self))
	self:ListenEvent("ClickTitleShow", BindTool.Bind(self.ClickTitleShow, self))
	self:ListenEvent("ClickMarryGift", BindTool.Bind(self.ClickMarryGift, self))

	self.start_level = 0		--开始自动升级的等级
	self.now_ring_level = 0

	self:InitDisPlay()

	self:Flush()

	RemindManager.Instance:Fire(RemindName.MarryParty)
	-- RemindManager.Instance:Fire(RemindName.MarryLoveContent)
	self:FLushMarryGiftBtn()
end

function MarriageHoneymoonView:__delete()

	if self.self_model then
		self.self_model:DeleteMe()
		self.self_model = nil
	end

	if self.love_model then
		self.love_model:DeleteMe()
		self.love_model = nil
	end

	if self.ring_item_cell then
		self.ring_item_cell:DeleteMe()
		self.ring_item_cell = nil
	end

	self.effect_cd = 0

	if self.ring_cell then
		self.ring_cell:DeleteMe()
		self.ring_cell = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.marry_gift_timer then
		GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
		self.marry_gift_timer = nil
	end
end

function MarriageHoneymoonView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] ~= nil then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function MarriageHoneymoonView:ShowOrHideTab()
	local open_fun_data = OpenFunData.Instance
	local equip_visible = open_fun_data:CheckIsHide("marriage_equip")
	-- 爱情契约
	local love_contract_visible = open_fun_data:CheckIsHide("marriage_love_contract")
	if self.btn_qiyue then
		self.btn_qiyue:SetValue(love_contract_visible and self:CheckIsMarry() and true or false)
	end
	if self.btn_hunyan then
		self.btn_hunyan:SetValue(MarriageData.Instance.can_open == 0 and self:CheckIsMarry())
	end
end


function MarriageHoneymoonView:CloseCallBack()
	self:CancelTuoDanQuest()
end

function MarriageHoneymoonView:OpenHunYan()
	RemindManager.Instance:SetRemindToday(RemindName.MarryParty)
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[3])
end

function MarriageHoneymoonView:OpenLoverContact()
	ViewManager.Instance:Open(ViewName.LoveContract)
end

function MarriageHoneymoonView:OpenMail()
	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_mail)
end

function MarriageHoneymoonView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(9)
end

function MarriageHoneymoonView:ClickMonomer()
	-- local is_in_list = MarriageData.Instance:IsInTuoDanList()
	-- if is_in_list then
	-- 	MarriageCtrl.Instance:SendTuodanReq(TUODAN_OPERA_TYPE.TUODAN_DELETE)
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.DownTuoDanDes)
	-- else
	MarriageCtrl.Instance:ShowMonomerView()
	-- end
end

function MarriageHoneymoonView:ClickDivorce()
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[2])
end

function MarriageHoneymoonView:StopAutoUpgrade()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.button_text:SetValue(Language.Common.AutoUpgrade)
end

function MarriageHoneymoonView:InitDisPlay()
	if not self.self_model then
		self.self_model = RoleModel.New("marriage_role_model")
		self.self_model:SetDisplay(self.self_display.ui3d_display)
	end
	if not self.love_model then
		self.love_model = RoleModel.New("marriage_role_model")
		self.love_model:SetDisplay(self.love_display.ui3d_display)
	end
end

function MarriageHoneymoonView:FlushDisPlay()
	self:InitDisPlay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo = {}
	role_vo.prof = main_role_vo.prof
	role_vo.sex = main_role_vo.sex
	role_vo.appearance = {}
	-- role_vo.appearance.fashion_wuqi = 1
	--结婚时装显示
	role_vo.appearance.fashion_body = 9
	self.self_model:SetModelResInfo(role_vo, true)

	--有伴侣才加载伴侣模型
	GlobalTimerQuest:AddDelayTimer(function()
		if main_role_vo.lover_uid > 0 then
			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_body = 9
			-- print_error(lover_vo)
			self.love_model:SetModelResInfo(lover_vo, true)
		end
	end, 0)

end

function MarriageHoneymoonView:CancelTuoDanQuest()
	if self.tuo_dan_count_down then
		CountDown.Instance:RemoveCountDown(self.tuo_dan_count_down)
		self.tuo_dan_count_down = nil
	end
end

function MarriageHoneymoonView:ChangeTuoDanBtnText()
	--开始倒计时
	self:CancelTuoDanQuest()
	local send_time = MarriageData.Instance:GetSendTuoDanTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	if send_time <= 0 or (server_time - send_time) > SEND_CD then
		self.show_cd_time:SetValue(false)
		self.tuodan_btn_text:SetValue(Language.Marriage.TuoDanDes)
		return
	end

	local left_time = math.ceil(SEND_CD - (server_time - send_time))
	left_time = left_time > SEND_CD and SEND_CD or left_time

	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:CancelTuoDanQuest()
			self.show_cd_time:SetValue(false)
			self.tuodan_btn_text:SetValue(Language.Marriage.TuoDanDes)
			return
		end
		local temp_time = math.ceil(total_time - elapse_time)
		local time_des = string.format(Language.Chat.ResetTimes, temp_time)
		self.show_cd_time:SetValue(true)
		self.tuodan_btn_text:SetValue(time_des)
	end

	self.tuo_dan_count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	self.show_cd_time:SetValue(true)
	local time_des = string.format(Language.Chat.ResetTimes, left_time)
	self.tuodan_btn_text:SetValue(time_des)
end

function MarriageHoneymoonView:Flush()
	self:ChangeTuoDanBtnText()

	--戒指图标
	local ring_cfg = MarriageData.Instance:GetRingCfg()
	local ring_id = nil
	if ring_cfg ~= nil then
		ring_id = ring_cfg.equip_id
	else
		ring_id = MarriageData.Instance:GetLevelOneRingCfg().equip_id
	end
	if self.now_ring_item_id ~= ring_id then
		self.ring_cell:SetData({item_id = ring_id, is_bind = 0}, true)
		self.ring_cell:SetInteractable(false)
		self.now_ring_item_id = ring_id
	end
	local item_data = {}
	item_data.item_id = ring_id
	--是否结婚
	self.is_marry:SetValue(self:CheckIsMarry())
	--设定伴侣性别名称
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.lover_name:SetValue(main_role_vo.lover_name)
	self.lover_is_girl:SetValue(main_role_vo.sex == 1)
	--设置戒指信息
	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 3 then
		--未激活
		self.ring_had_active:SetValue(false)
		if self.init_proess then
			self.init_proess = false
			self.progress_value:InitValue(0)
		else
			self.progress_value:SetValue(0)
		end
	else
		--已激活
		self.ring_had_active:SetValue(true)
		local ring_cfg2, is_max = MarriageData.Instance:GetRingCfg()
		local ring_exp = MarriageData.Instance:GetRingExp()
		if is_max then
			self.progress_text:SetValue("-/-")
			if self.init_proess then
				self.init_proess = false
				self.progress_value:InitValue(1)
			else
				self.progress_value:SetValue(1)
			end
		else
			local progress_value = ring_exp / ring_cfg2.exp
			if self.init_proess then
				self.init_proess = false
				self.progress_value:InitValue(progress_value)
			else
				self.progress_value:SetValue(progress_value)
			end
			self.progress_text:SetValue(ring_exp.."/"..ring_cfg2.exp)
		end
		--能否升级
		self.ring_can_upgrade:SetValue(flag == 1)
	end

	local level_des = PlayerData.GetLevelString(GameVoManager.Instance:GetMainRoleVo().level)
	self.self_level:SetValue(level_des)

	local lover_level = MarriageData.Instance:GetLoverLevel()
	local lover_star = MarriageData.Instance:GetLoverStar()

	level_des = PlayerData.GetLevelString(lover_level)
	self.lover_level:SetValue(level_des)

	self.lover_ring:SetValue(lover_star)

	--设置材料信息
	local id = MarriageData.Instance:GetRingUpgradeItem().stuff_id
	local num = ItemData.Instance:GetItemNumInBagById(id)
	self.had_ring_item:SetValue(num)
	local data = {}
	data.item_id = id
	self.ring_item_cell:SetData(data)

	if ring_cfg then
		local attrs = CommonDataManager.GetAttributteByClass(ring_cfg, true)
		local capability = CommonDataManager.GetCapability(attrs)
		local item_cfg = ItemData.Instance:GetItemConfig(ring_cfg.equip_id)
		self.power:SetValue(capability)
		for k,v in pairs(self.heart_list) do
			v.grayscale.GrayScale = 255
		end
		for i=1,ring_cfg.star do
			self.heart_list[i].grayscale.GrayScale = 0
		end

		local _,big_lev = math.modf(ring_cfg.equip_id/10)
		big_lev = string.format("%.2f", big_lev or 0) * 100
		local level = big_lev + ring_cfg.star
		self.self_ring:SetValue(level)

		if self.now_ring_level > 0 and level > self.now_ring_level then
			--播放升级特效
			self:PlayUpStarEffect()
		end

		self.now_ring_level = level		--记录开始升级前的等级

		--设置当前信息
		self.now_level:SetValue(level)
		self.now_gongji:SetValue(ring_cfg.gongji)
		self.now_fangyu:SetValue(ring_cfg.fangyu)
		self.now_hp:SetValue(ring_cfg.maxhp)

		--获取下一级效果
		local next_cfg = MarriageData.Instance:GetNextRingCfg()
		if next_cfg then
			self.is_max:SetValue(false)
			self.next_level:SetValue(level + 1)
			self.next_gongji:SetValue(next_cfg.gongji)
			self.next_fangyu:SetValue(next_cfg.fangyu)
			self.next_hp:SetValue(next_cfg.maxhp)
		else
			self.is_max:SetValue(true)
		end
	end
end

--升级戒指按下时
function MarriageHoneymoonView:FLushMarryGiftBtn()
	local cur_seq = MarryGiftData.Instance:CurPurchasedSeq()
	local cfg = MarryGiftData.Instance:GetMarryGiftSeqCfg(cur_seq + 1)
	self.show_marry_gift:SetValue(cfg ~= nil)
	self.show_marry_gift_eff:SetValue(cfg ~= nil and not MarryGiftData.HAS_REMIND)
	if cfg then
		self.marry_figt_endtime = TimeUtil.NowDayTimeEnd(TimeCtrl.Instance:GetServerTime())
		if self.marry_gift_timer == nil then
			self.marry_gift_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
			self:FlushNextTime()
		end
	else
		if self.marry_gift_timer then
			GlobalTimerQuest:CancelQuest(self.marry_gift_timer)
			self.marry_gift_timer = nil
		end
		self.marry_gift_time:SetValue("")
	end
end

function MarriageHoneymoonView:FlushNextTime()
	local time = self.marry_figt_endtime - TimeCtrl.Instance:GetServerTime()
	if time > 0 then
		if time > 3600 then
			self.marry_gift_time:SetValue(TimeUtil.FormatSecond(time, 1))
		else
			self.marry_gift_time:SetValue(TimeUtil.FormatSecond(time, 2))
		end
	else
		self:FLushMarryGiftBtn()
	end
end

--升级戒指按下时
function MarriageHoneymoonView:UpgradeRingClick()
	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 0 then
		--满级了
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Ring_Max_Level)
	elseif flag == 1 then
		--未满级-可升级
		MarriageCtrl.Instance:SendUpgradeRing(1, 0)
	elseif flag == 2 then
		--不够材料
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		-- TipsCtrl.Instance:ShowCommonBuyView(BindTool.Bind(self.BuyFunc, self), item_id, nil, 1)
	elseif flag == 3 then
		--未激活
		if self:CheckIsMarry() then
			--已结婚
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			--未结婚
			self:ShowGoToMarryTips()
		end
	end
end

--自动升级戒指
function MarriageHoneymoonView:AutoUpgradeRingClick()
	if self.time_quest ~= nil then
		self:StopAutoUpgrade()
	else
		local flag, item_id = MarriageData.Instance:GetRingInfo()

		local function ok_callback()
			self.start_level = self.now_ring_level
			local time_per_once = MarriageData.Instance:GetRingUpgradeItem().interval_time
			self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.AutoUpgrade, self), time_per_once)
		end

		if flag == 0 then
			--满级了
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Ring_Max_Level)
		elseif flag == 1 then
			--未满级-可升级
			local des = Language.Marriage.AutoUpLevelRing
			TipsCtrl.Instance:ShowCommonAutoView("auto_ring_up", des, ok_callback)
		elseif flag == 2 then
			--不够材料
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
		elseif flag == 3 then
			--未激活
			if self:CheckIsMarry() then
				--已结婚
				TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
			else
				--未结婚
				self:ShowGoToMarryTips()
			end
		end
	end
end

function MarriageHoneymoonView:AutoUpgrade()
	local ring_cfg = MarriageData.Instance:GetRingCfg()
	local _,big_lev = math.modf(ring_cfg.equip_id/10)
	big_lev = string.format("%.2f", big_lev or 0) * 100
	local level = big_lev + ring_cfg.star
	local stop_big_level = math.modf((self.start_level + 10)/10)
	local stop_level = stop_big_level * 10
	if level >= stop_level then
		self:StopAutoUpgrade()
		return
	end

	local flag, item_id = MarriageData.Instance:GetRingInfo()
	if flag == 1 then
		MarriageCtrl.Instance:SendUpgradeRing(1, 0)
		self.button_text:SetValue(Language.Common.Stop)
	elseif flag == 2 then
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		self:StopAutoUpgrade()
	else
		self:StopAutoUpgrade()
	end
end

--是否已婚
function MarriageHoneymoonView:CheckIsMarry()
	return MarriageData.Instance:CheckIsMarry()
end

--前往结婚
function MarriageHoneymoonView:GoToMarryClick()
	if self:CheckIsMarry() then
		if not ScoietyData.Instance:GetTeamState() then
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 2
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(GameVoManager.Instance:GetMainRoleVo().lover_uid)
	else
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(self.GoToMarryNpc, self), nil, Language.Marriage.GoToMarryTip[1])
	end
end

--前往月老
function MarriageHoneymoonView:GoToMarryNpc()
	local cfg = MarriageData.Instance:GetMarriageConditions()
	if nil == cfg then return end
	local npc_info = MarryMeData.Instance:GetNpcInfo(cfg.qingyuannpc_sceneid, cfg.qingyuannpc_id)
	if npc_info then
		MoveCache.end_type = MoveEndType.NpcTask
		MoveCache.param1 = cfg.qingyuannpc_id
		GuajiCtrl.Instance:MoveToPos(cfg.qingyuannpc_sceneid, npc_info.x, npc_info.y, 1, 1, false)
	end
	ViewManager.Instance:Close(ViewName.Marriage)
end

--前往结婚提示板
function MarriageHoneymoonView:ShowGoToMarryTips()
	local click_func = BindTool.Bind(self.GoToMarryClick, self)
	TipsCtrl.Instance:ShowOneOptionView(Language.Marriage.Not_Marry_Can_Not_Use, click_func, Language.Marriage.Go_To_Marry)
end

--问号按下时
function MarriageHoneymoonView:HelpClick()
	local is_show = self.is_show_help:GetBoolean()
	self.is_show_help:SetValue(not is_show)
end

--戒指按下时
function MarriageHoneymoonView:RingClick()
	local ring_had_active = MarriageData.Instance:GetRingHadActive()
	if ring_had_active then
		--戒指已激活
		TipsCtrl.Instance:ShowRingInfo()
	else
		--戒指未激活
		if self:CheckIsMarry() then
			--已结婚
			TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Activate_Ring)
		else
			--未结婚
			self:ShowGoToMarryTips()
		end
	end
end

--播放升级特效
function MarriageHoneymoonView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function MarriageHoneymoonView:OpenTuoDanList()
	self:HideOrShowMonomer()
end

function MarriageHoneymoonView:HideOrShowMonomer()
	ViewManager.Instance:Open(ViewName.MonomerListView)
end

function MarriageHoneymoonView:MarryStateChange()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self.is_marry:SetValue(self:CheckIsMarry())

	self:FlushDisPlay()
	self:Flush()
end

function MarriageHoneymoonView:ShowIndexCallBack()
	self:StopAutoUpgrade()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	self:FlushDisPlay()
end

function MarriageHoneymoonView:ClickTitleShow()
    local title_show = MarriageData.Instance:GetMarryTitleShow()
    if title_show then
      TipsCtrl.Instance:OpenItem({item_id = title_show})
    end
end

function MarriageHoneymoonView:ClickMarryGift()
	ViewManager.Instance:Open(ViewName.MarryGift)
	MarryGiftData.HAS_REMIND = true
	RemindManager.Instance:Fire(RemindName.MarryGift)
	self.show_marry_gift_eff:SetValue(false)
end