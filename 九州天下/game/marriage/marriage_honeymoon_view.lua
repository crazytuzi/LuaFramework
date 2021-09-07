require("game/marriage/marriage_equip_view")
require("game/marriage/marriage_love_contract_view")
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
	-- 生成滚动条
	self.monomer_cell_list = {}
	self.monomer_data = {}
	self.monomer_scroller = self:FindObj("MonomerList")
	local scroller_delegate = self.monomer_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.effect_cd = 0

	self.self_display = self:FindObj("SelfDisplay")
	self.love_display = self:FindObj("LoveDisplay")
	self.effect_root = self:FindObj("EffectRoot")

	self.marriage_wedding_view = MarriageWeddingView.New(self:FindObj("WeddingView"))
	self.marriage_equip_view = MarriageEquipView.New(self:FindObj("CoupleEquip"))

	-- 爱情契约
	self.love_contract_view = MarriageLoveContractView.New(self:FindObj("LoveContract"))

	self.bless_reward_icon = self:FindVariable("BlessRewardIcon")
	self.progress_value = self:FindVariable("ProgressValue")
	self.progress_text = self:FindVariable("ProgressText")
	self.is_marry = self:FindVariable("IsMarry")
	self.lover_name = self:FindVariable("LoverName")
	self.lover_is_girl = self:FindVariable("LoverIsGirl")
	-- self.is_show_help = self:FindVariable("IsShowHelp")
	self.ring_can_upgrade = self:FindVariable("RingCanUpgrade")
	self.ring_had_active = self:FindVariable("RingHadActive")
	self.qi_yue_red = self:FindVariable("QiYueRedPoint")
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

	self.power = self:FindVariable("Power")
	self.had_ring_item = self:FindVariable("HadRingItem")

	self.show_ring_redpoint = self:FindVariable("ShowRingRedPoint")
	self.show_wedding_redpoint = self:FindVariable("ShowWeddingRedPoint")
	self.show_lovecontent_redpoint = self:FindVariable("ShowLoveContentRedPoint")

	self.tab1 = self:FindObj("Tab1")
	self.tab2 = self:FindObj("Tab2")
	self.tab3 = self:FindObj("Tab3")
	-- self.tab4 = self:FindObj("Tab4")
	self.tab5 = self:FindObj("Tab5")

	self.ring_cell = ItemCell.New()
	self.ring_cell:SetInstanceParent(self:FindObj("RingCell"))
	self.ring_cell:SetData(nil)
	self.ring_cell:SetInteractable(false)
	self.now_ring_item_id = 0

	for i = 1, 5 do
		if i ~= 4 then
		self["tab" .. i] = self:FindObj("Tab" .. i)
		self["tab" .. i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, i))
		end
	end

	self.onlysex_checkbox = self:FindObj("OnlySexCheckBox")
	self.onlysex_checkbox.toggle:AddValueChangedListener(BindTool.Bind(self.OnCheckBoxChange,self))

	self.lover_view = self:FindObj("LoverView")
	self.monomer_animator = self.lover_view.animator

	self.button_arrow = self:FindObj("ButtonArrow")
	self.arrow_animator = self.button_arrow.animator

	self.heart_list = {}
	local obj_group = self:FindObj("HeartGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "Little_Heart") ~= nil then
			local love_obj = obj.transform:GetChild(0).gameObject
			self.heart_list[count] = U3DObject(love_obj)
			count = count + 1
		end
	end
	self.ring_item_cell = ItemCellReward.New()
	self.ring_item_cell:SetInstanceParent(self:FindObj("RingItemCell"))

	-- self.is_show_help:SetValue(false)
	self.button_text:SetValue(Language.Common.AutoUpgrade)

	self:ListenEvent("UpgradeRingClick", BindTool.Bind(self.UpgradeRingClick, self))
	self:ListenEvent("GoToMarryClick", BindTool.Bind(self.GoToMarryClick, self))
	-- self:ListenEvent("CloseHelp", BindTool.Bind(self.CloseHelp, self))
	-- self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))
	self:ListenEvent("AutoUpgradeClick", BindTool.Bind(self.AutoUpgradeRingClick, self))
	self:ListenEvent("OpenMail", BindTool.Bind(self.OpenMail, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickDivorce", BindTool.Bind(self.ClickDivorce, self))
	self:ListenEvent("ClickMonomer", BindTool.Bind(self.ClickMonomer, self))
	self:ListenEvent("HideOrShowMonomer", BindTool.Bind(self.HideOrShowMonomer, self))

	self.start_level = 0		--开始自动升级的等级
	self.now_ring_level = 0

	self:InitDisPlay()

	self:Flush()
end

function MarriageHoneymoonView:__delete()
	if self.marriage_wedding_view then
		self.marriage_wedding_view:DeleteMe()
		self.marriage_wedding_view = nil
	end

	if self.marriage_equip_view then
		self.marriage_equip_view:DeleteMe()
		self.marriage_equip_view = nil
	end

	if self.love_contract_view then
		self.love_contract_view:DeleteMe()
		self.love_contract_view = nil
	end

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

	for k, v in pairs(self.monomer_cell_list) do
		v:DeleteMe()
	end
	self.monomer_cell_list = {}

	if self.ring_cell then
		self.ring_cell:DeleteMe()
		self.ring_cell = nil
	end
end

function MarriageHoneymoonView:ShowOrHideTab()
	local open_fun_data = OpenFunData.Instance
	-- local equip_visible = open_fun_data:CheckIsHide("marriage_equip")
	-- if self.tab4 then
	-- 	self.tab4:SetActive(equip_visible)
	-- end

	-- 爱情契约
	local love_contract_visible = open_fun_data:CheckIsHide("marriage_love_contract")
	if self.tab5 then
		self.tab5:SetActive(love_contract_visible and self:CheckIsMarry() and true or false)
	end
end

function MarriageHoneymoonView:OnToggleChange(index, ison)
	if ison then
		if index == MarryTabIndex.Ring then
			self.init_proess = true
			self:Flush()
		elseif index == MarryTabIndex.Hunyan then
			self.marriage_wedding_view:OpenCallBack()
		elseif index == MarryTabIndex.Equip then
			self.marriage_equip_view:OpenEquipViewCallBack()
		elseif index == MarryTabIndex.LoveContract then
			self.love_contract_view:FlushLoveContractView()
			self.love_contract_view:OpenLoveContaractView()
		end
	end
end

function MarriageHoneymoonView:FlushLoveContractView()
	if self.tab5.toggle.isOn then
		self.love_contract_view:FlushLoveContractView()
	end
end

function MarriageHoneymoonView:SelectLoveContractToggle()
	GlobalTimerQuest:AddDelayTimer(function()
		self.tab5.toggle.isOn = true
	end, 0)
end

function MarriageHoneymoonView:SelectEquipToggle()
	self.tab4.toggle.isOn = true
end

function MarriageHoneymoonView:FlushEquipView()
	if self.tab4.toggle.isOn then
		self.marriage_equip_view:FlushEquipView()
	end
end

function MarriageHoneymoonView:FlushWedding()
	self.marriage_wedding_view:Flush()
end

function MarriageHoneymoonView:CloseCallBack()
	self:StopAutoUpgrade()
	self:CancelTuoDanQuest()
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
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.lover_name == nil or main_role_vo.lover_name == "" then
		TipsCtrl.Instance:ShowSystemMsg(Language.Marriage.Not_Marry)
		return
	end

	local is_online = ScoietyData.Instance:GetFriendIsOnlineById(main_role_vo.lover_uid)
	local divorce_intimacy_dec = MarriageData.Instance:GetIntimacyCost()

	if is_online == 1 then
		local function func()
			MarriageCtrl.Instance:SendDivorceReq(0)
		end
		local des = string.format(Language.Marriage.DivorceQuestionDes, main_role_vo.lover_name)
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	else
		local function ok_func()
			MarriageCtrl.Instance:SendDivorceReq(1)
		end
		local diamond_cost = MarriageData.Instance:GetDivorceCost()
		local des = string.format(Language.Marriage.OneSideDivorceQuestion, diamond_cost)
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_func)
	end
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
		self.self_model = RoleModel.New("honey_moon_view",200)
		self.self_model:SetDisplay(self.self_display.ui3d_display)
	end
	if not self.love_model then
		self.love_model = RoleModel.New("honey_moon_view",400)
		self.love_model:SetDisplay(self.love_display.ui3d_display)
	end
end

function MarriageHoneymoonView:FlushDisPlay()
	self:InitDisPlay()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_vo = {}
	role_vo.prof = main_role_vo.prof
	role_vo.sex = main_role_vo.sex

	local model_data =  MarriageData.Instance:GetModelCfgById(role_vo.prof)
	role_vo.appearance = {}
	role_vo.appearance.fashion_wuqi = model_data.weapon_model
	role_vo.appearance.fashion_body = model_data.role_model
	self.self_model:SetModelResInfo(role_vo, true)

	--有伴侣才加载伴侣模型
	GlobalTimerQuest:AddDelayTimer(function()
		if main_role_vo.lover_uid > 0 then

			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			local model_data =  MarriageData.Instance:GetModelCfgById(lover_vo.prof)
			lover_vo.appearance = {}
			lover_vo.appearance.fashion_wuqi = model_data.weapon_model
			lover_vo.appearance.fashion_body = model_data.role_model
			self.love_model:SetModelResInfo(lover_vo, true)
		end
	end, 0)
end

-- self.show_ring_redpoint = self:FindVariable("ShowRingRedPoint")
-- self.show_wedding_redpoint = self:FindVariable("ShowWeddingRedPoint")
-- self.show_lovecontent_redpoint = self:FindVariable("ShowLoveContentRedPoint")

function MarriageHoneymoonView:OpenHoneyMoonCallBack()
	GlobalTimerQuest:AddDelayTimer(function()
		local ring_red_point = MarriageData.Instance:GetRedPointByKey("Ring")
		local love_content_red_point = MarriageData.Instance:GetRedPointByKey("love_content")
		self.show_ring_redpoint:SetValue(ring_red_point)
		self.show_lovecontent_redpoint:SetValue(love_content_red_point)
	end, 0)
end

function MarriageHoneymoonView:FlushRingRedPoint()
	local ring_red_point = MarriageData.Instance:GetRedPointByKey("Ring")
	self.show_ring_redpoint:SetValue(ring_red_point)
end

function MarriageHoneymoonView:FlushLoverContentRedPoint()
	local love_content_red_point = MarriageData.Instance:GetRedPointByKey("love_content")
	self.show_lovecontent_redpoint:SetValue(love_content_red_point)
end

function MarriageHoneymoonView:RingInfoChange(value)
	self:Flush()
	if value then
		self.tab2.toggle.isOn = true
	end
end

function MarriageHoneymoonView:CancelTuoDanQuest()
	if self.tuo_dan_count_down then
		CountDown.Instance:RemoveCountDown(self.tuo_dan_count_down)
		self.tuo_dan_count_down = nil
	end
end

function MarriageHoneymoonView:ChangeTuoDanBtnText()
	-- local is_in_list = MarriageData.Instance:IsInTuoDanList()
	-- if is_in_list then
	-- 	self.tuodan_btn_text:SetValue(Language.Marriage.DanShengDes)
	-- else
	-- 	self.tuodan_btn_text:SetValue(Language.Marriage.TuoDanDes)
	-- end

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
		self.ring_had_active:SetValue(self:CheckIsMarry())
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

	local lv, zhuan = PlayerData.GetLevelAndRebirth(GameVoManager.Instance:GetMainRoleVo().level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.self_level:SetValue(level_des)

	local lover_level = MarriageData.Instance:GetLoverLevel()
	local lover_star = MarriageData.Instance:GetLoverStar()

	lv, zhuan = PlayerData.GetLevelAndRebirth(lover_level)
	level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.lover_level:SetValue(level_des)

	self.lover_ring:SetValue(lover_star)

	--设置材料信息
	local id = MarriageData.Instance:GetRingUpgradeItem().stuff_id
	local num = ItemData.Instance:GetItemNumInBagById(id)
	self.had_ring_item:SetValue(num)
	local data = {}
	data.item_id = id
	data.is_bind = 0
	self.ring_item_cell:SetData(data)

	if ring_cfg then
		local attrs = CommonDataManager.GetAttributteByClass(ring_cfg, true)
		local capability = CommonDataManager.GetCapabilityCalculation(attrs)
		local item_cfg = ItemData.Instance:GetItemConfig(ring_cfg.equip_id)
		self.power:SetValue(capability)
		for k,v in pairs(self.heart_list) do
			v.grayscale.GrayScale = 255
		end
		for i=1,ring_cfg.star do
			self.heart_list[i].grayscale.GrayScale = 0
		end

		local _,big_lev = math.modf(ring_cfg.equip_id/100)
		big_lev = string.format("%.2f", big_lev or 0) * 1000
		local level = big_lev + ring_cfg.star
		self.self_ring:SetValue(level)

		-- if self.now_ring_level > 0 and level > self.now_ring_level then
		-- 	--播放升级特效
		-- 	-- self:PlayUpStarEffect()
		-- end

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
	self:QiYueRedPoint()
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
			-- if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
			-- 	ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.society_team)
			-- else
			-- 	ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
			-- end
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 2
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(GameVoManager.Instance:GetMainRoleVo().lover_uid)
	else
		ViewManager.Instance:Open(ViewName.Wedding)
	end
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
			"effects2/prefab/ui/ui_shengjichenggong_prefab",
			"UI_shengjichenggong",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

function MarriageHoneymoonView:OnCheckBoxChange(isOn)
	self.monomer_data = MarriageData.Instance:GetAllTuoDanList(isOn)
	self.monomer_scroller.scroller:ReloadData(0)
end

function MarriageHoneymoonView:OpenTuoDanList()
	self.tab1.toggle.isOn = true
	self:HideOrShowMonomer()
end

function MarriageHoneymoonView:HideOrShowMonomer()
	local arrow = self.arrow_animator:GetBool("IsClick")
	self.arrow_animator:SetBool("IsClick", not arrow)

	local bool = self.monomer_animator:GetBool("open")
	bool = not bool

	if bool then
		self.onlysex_checkbox.toggle.isOn = true
		local only_other_sex = true
		self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
		self.monomer_scroller.scroller:ReloadData(0)
	end
	self.monomer_animator:SetBool("open", bool)
end

function MarriageHoneymoonView:GetNumberOfCell()
	return #self.monomer_data
end

function MarriageHoneymoonView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local monomer_cell = self.monomer_cell_list[cell]
	if not monomer_cell then
		monomer_cell = MonomerItemCell.New(cell.gameObject)
		self.monomer_cell_list[cell] = monomer_cell
	end
	monomer_cell:SetIndex(data_index)
	monomer_cell:SetData(self.monomer_data[data_index])
end

function MarriageHoneymoonView:FlushTuoDanList()
	if self.tab1.toggle.isOn and self.monomer_scroller then
		self:ChangeTuoDanBtnText()
		local only_other_sex = self.onlysex_checkbox.toggle.isOn
		self.monomer_data = MarriageData.Instance:GetAllTuoDanList(only_other_sex)
		if self.monomer_scroller.scroller.isActiveAndEnabled then
			self.monomer_scroller.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function MarriageHoneymoonView:QiYueRedPoint()
	-- local flag = 0
	-- local is_open = true
	-- local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num
	-- for i = 0, 6 do
	-- 	flag = MarriageData.Instance:GetQingyuanLoveContractRewardFlag(i)
	-- 	is_open = flag == 1 and i <= can_receive_day_num
	-- 	if is_open then
	-- 		break
	-- 	end
	-- end
	-- self.qi_yue_red:SetValue(not is_open)
	local flag = MarriageData.Instance:GetQingyuanLoveContractReward()
	self.qi_yue_red:SetValue(flag)
end

-------------我要脱单ItemCell------------------------
MonomerItemCell = MonomerItemCell or BaseClass(BaseCell)

function MonomerItemCell:__init()
	self.raw_image = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.raw_image_res = self:FindVariable("RawImageRes")
	self.is_image = self:FindVariable("IsImage")

	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.power = self:FindVariable("Power")
	self.declaration = self:FindVariable("Declaration")
	self.is_boy = self:FindVariable("IsBoy")
	self.btn_time = self:FindVariable("BtnTime")
	self.is_send_time = self:FindVariable("IsSendTime")

	self:ListenEvent("ClickGood", BindTool.Bind(self.ClickGood, self))
	self:ListenEvent("ClickHead", BindTool.Bind(self.ClickHead, self))
end

function MonomerItemCell:__delete()

end

function MonomerItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	if self.data.sex == 1 then
		self.is_boy:SetValue(true)
	else
		self.is_boy:SetValue(false)
	end

	self.name:SetValue(self.data.name)
	self.power:SetValue(self.data.capability)

	local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.level:SetValue(level_des)

	self.declaration:SetValue(self.data.notice)

	--设置头像
	local role_id = self.data.uid
	AvatarManager.Instance:SetAvatarKey(role_id, self.data.avatar_key_big, self.data.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(role_id)
	if avatar_path_small == 0 then
		self.is_image:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.raw_image.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(role_id, false)
			end
			self.raw_image.raw_image:LoadSprite(path, function ()
				self.is_image:SetValue(false)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, false, callback)
	end
	self:StartCountDown()
end

--示好
function MonomerItemCell:ClickGood()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.uid == main_vo.role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotGoodDes)
		return
	end

	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.data.uid) then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = self.data.uid
		private_obj.username = self.data.name
		private_obj.sex = self.data.sex
		private_obj.prof = self.data.prof
		private_obj.avatar_key_small = self.data.avatar_key_small
		private_obj.level = self.data.level
		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end

	local text = MarriageData.Instance:GetTuoDanDes()

	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = main_vo.role_id
	msg_info.username = main_vo.name
	msg_info.sex = main_vo.sex
	msg_info.camp = main_vo.camp
	msg_info.prof = main_vo.prof
	msg_info.authority_type = main_vo.authority_type
	msg_info.avatar_key_small = main_vo.avatar_key_small
	msg_info.level = main_vo.level
	msg_info.vip_level = main_vo.vip_level
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.content = text
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
	msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
	msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
	msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框

	ChatData.Instance:AddPrivateMsg(self.data.uid, msg_info)

	ChatCtrl.SendSingleChat(self.data.uid, text, CHAT_CONTENT_TYPE.TEXT)

	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.GoodSuccDes)

	--设置冷却时间
	MarriageData.Instance:AddSendGoodTimeList(self.data.uid)
	self:StartCountDown()
end

--开始倒计时
function MonomerItemCell:StartCountDown()
	self:StopCountDown()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local last_send_time = MarriageData.Instance:GetSendGoodTime(self.data.uid) or 0
	local end_cd_time = last_send_time + 10
	if server_time >= end_cd_time then
		self.is_send_time:SetValue(false)
		return
	end

	local function timer_func(elapse_time, total_time)
		if not self.root_node or not self.root_node.gameObject or IsNil(self.root_node.gameObject) then
			self:StopCountDown()
			return
		end
		if elapse_time >= total_time then
			self:StopCountDown()
			self.is_send_time:SetValue(false)
			return
		end
		local time = math.ceil(total_time - elapse_time)
		self.btn_time:SetValue(time)
		self.is_send_time:SetValue(true)
	end

	local left_time = math.ceil(end_cd_time - server_time)
	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	self.btn_time:SetValue(left_time)
	self.is_send_time:SetValue(true)
end

--停止倒计时
function MonomerItemCell:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function MonomerItemCell:ClickHead()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if self.data.uid == main_vo.role_id then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotGoodDes)
		return
	end
	local open_type = ScoietyData.DetailType.Default
	ScoietyCtrl.Instance:ShowOperateList(open_type, self.data.name)
end