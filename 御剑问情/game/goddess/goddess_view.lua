require("game/goddess/goddess_info_view")
require("game/goddess/camp/goddess_camp_view")
require("game/goddess/goddess_role_view")
require("game/goddess/goddess_shengwu_all_view")
require("game/goddess/goddess_shengwu_view")
require("game/goddess/goddess_gongming_view")
require("game/goddess/goddess_shouhu/goddess_shouhu_view")
--------------------------------------------------------------------------
--GoddessView 	女神总面板
--------------------------------------------------------------------------
local EFFECT_CD = 1
local FIX_SHOW_TIME = 8
GoddessView = GoddessView or BaseClass(BaseView)
local risingstar_img_path = {
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_MOUNT] = "Function_Open_Moqi",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_WING] = "Function_Open_Yuyi",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_SHENGONG] = "Function_Open_Guanghuan",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_HALO] = "Function_Open_ZhuJueGuanghuan",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_PIFENG] = "Icon_Function_Fazhen",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FIGHT_MOUNT] = "Function_Open_Zuoqi",
	[SHENGXINGZHULI_SYSTEM_TYPE.SHENGXINGZHULI_SYSTEM_TYPE_FOOT_PRINT] = "Function_Open_Zuji"
}

function GoddessView:__init()
	self.ui_config = {"uis/views/goddess_prefab","GoddessView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenGoddess)
	end
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.tab_index = 0
	self.effect_cd = 0
	self.def_index = TabIndex.goddess_info
	self.prefab_preload_id = 0
end

--关闭女神面板
function GoddessView:BackOnClick()
	AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Goddess, self.show_index)
end

function GoddessView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GoddessView:__delete()
	self.tab_index = nil
	self.effect_cd = nil
end

function GoddessView:LoadCallBack()
	-- 监听UI事件
	self:ListenEvent("close_view", BindTool.Bind(self.BackOnClick, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))
	self:ListenEvent("OpenRisingStar",BindTool.Bind(self.OpenRisingStar,self))

	self.toggle_list = {}
	for i=1,7 do
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
		self:ListenEvent("tab_" .. i, BindTool.Bind2(self.OpenIndexCheck, self, i))
	end

	self.role_content_go = self:FindObj("role_content")
	UtilU3d.PrefabLoad("uis/views/goddess_prefab", "RoleContent",
		function(obj)
			obj.transform:SetParent(self.role_content_go.transform, false)
			obj = U3DObject(obj)
			self.role_content_view = GoddessRoleView.New(obj)
		end)

	self.goddess_info_go = self:FindObj("goddess_info_content")
	self.camp_content_go = self:FindObj("camp_content")
	self.shengong_content_go = self:FindObj("shengong_content_view")
	self.shenyi_content_go = self:FindObj("shenyi_content_view")
	self.shengwu_content_all_go = self:FindObj("shengwu_content_all_view")
	self.gongming_content_go = self:FindObj("gongming_content_view")

	self.biping_icon = self:FindObj("BiPingIcon")

	self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
	self.bipingredpoint = self:FindVariable("ShowBipingRedPoint")
	self.show_shengwu_bg = self:FindVariable("ShowShengWuBg")


	self.btn_close = self:FindObj("BtnClose")
	self.diamond = self:FindVariable("diamond")
	self.bind_gold = self:FindVariable("bind_gold")
	self.camp_red_point = self:FindVariable("camp_red_point")
	self.shengong_red_point = self:FindVariable("shengong_red_point")
	self.shenyi_red_point = self:FindVariable("shenyi_red_point")
	self.shouhu_red_point = self:FindVariable("shouhu_red_point")
	self.sheng_wu_red_point = self:FindVariable("shengwu_red_point")
	self.gong_ming_red_point = self:FindVariable("gong_ming_red_point")
	self.show_blue_bg = self:FindVariable("show_blue_bg")
	self.effect_root = self:FindObj("EffectRoot")
	self.rising_star_flag = self:FindVariable("RisingStarFlag")
	self.rising_type = self:FindVariable("RisingType")
	self.show_rising_star_red = self:FindVariable("ShowRisingStarRed")

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Goddess, BindTool.Bind(self.GetUiCallBack, self))

	self.red_point_list = {
		[RemindName.Goddess] = self:FindVariable("info_red_point"),
		--[RemindName.Goddess_Camp] = self:FindVariable("camp_red_point"),
		[RemindName.Goddess_HuanHua] = self:FindVariable("huan_hua_red_point"),
		[RemindName.Goddess_Shengong] = self:FindVariable("shengong_red_point"),
		[RemindName.Goddess_Shenyi] = self:FindVariable("shenyi_red_point"),
		[RemindName.Goddess_ShengWu] = self:FindVariable("shengwu_red_point"),
		[RemindName.Goddess_GongMing] = self:FindVariable("gong_ming_red_point"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.bipin_remind_change = function()
		RemindManager.Instance:Fire(RemindName.Goddess)
		self:FlushGoddessInfoView()
	end
	RemindManager.Instance:Bind(self.bipin_remind_change,  RemindName.BiPin)

	self.rising_star_remind_change = function()
		self:FlushRisingStarRed()
	end
	RemindManager.Instance:Bind(self.rising_star_remind_change,  RemindName.RisingStar)
end

function GoddessView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function GoddessView:GetGoddessInfoView()
	return self.goddess_info_view
end

function GoddessView:GetGoddessCampView()
	return self.camp_content_view
end

function GoddessView:GetGoddessShenGongView()
	return self.shengong_content_view
end

function GoddessView:GetGoddessShenyiView()
	return self.shenyi_content_view
end

function GoddessView:GetGoddessShouhuView()
	return self.shouhu_content_view
end

function GoddessView:GetGoddessRoleView()
	return self.role_content_view
end

function GoddessView:GetGoddessShengWuAllView()
	return self.shengwu_content_all_view
end

function GoddessView:CancelSGPreviewToggle()
	if self.shengong_content_view then
		self.shengong_content_view:CancelPreviewToggle()
	end
end

function GoddessView:CancelSYPreviewToggle()
	if self.shenyi_content_view then
		self.shenyi_content_view:CancelPreviewToggle()
	end
end

function GoddessView:Open(index)
	BaseView.Open(self, index)
end

function GoddessView:OpenCallBack()
	self.is_jump_open = true
	self.time_bipin_quest = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SetBiPinIcon, self))

	self.item_data_event = nil
	self:SetNotifyDataChangeCallBack()

	if self.goddess_info_view then
		self.goddess_info_view:Flush()
	end
	if self.shengong_content_view then
		self.shengong_content_view:SetNotifyDataChangeCallBack()
	end
	if self.shenyi_content_view then
		self.shenyi_content_view:SetNotifyDataChangeCallBack()
	end
	if self.camp_content_view then
		self.camp_content_view:FlushShowShadow()
	end
	self:ShowOrHideTab()
	self.event_quest = GlobalEventSystem:Bind(
		OpenFunEventType.OPEN_TRIGGER,
		BindTool.Bind(self.ShowOrHideTab, self))
	self:SetBiPinIcon()
	self:Flush()
end

function GoddessView:OnClickBiPin()
	-- ViewManager.Instance:Open(ViewName.CompetitionActivity)
	local cur_index = self:GetShowIndex()
	local activity_type = KaiFuDegreeRewardsData.Instance:GetBiPingActivity(cur_index)
	KaiFuDegreeRewardsCtrl.Instance:SetDegreeRewardsActivityType(activity_type)
	ViewManager.Instance:Open(ViewName.KaiFuDegreeRewardsView)
	self:Close()
end

function GoddessView:SetBiPinIcon()
	-- local activity_type = CompetitionActivityData.Instance:GetTabIndexToActType(self:GetShowIndex()) or 0
	-- self.show_bipin_icon:SetValue(activity_type > 0 and ActivityData.Instance:GetActivityIsOpen(activity_type))
	local cur_index = self:GetShowIndex()
	local isopen = KaiFuDegreeRewardsData.Instance:GetIsOpenBiPing(cur_index) or false
	self.show_bipin_icon:SetValue(isopen)
end

function GoddessView:ShowBiPinIcon()
	local activity_type = CompetitionActivityData.Instance:GetTabIndexToActType(self:GetShowIndex()) or 0
	return activity_type > 0 and ActivityData.Instance:GetActivityIsOpen(activity_type)
end

function GoddessView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list[1] = open_fun_data:CheckIsHide("goddess_info")
	show_list[2] = false --open_fun_data:CheckIsHide("goddess_camp") 	--阵型
	show_list[3] = open_fun_data:CheckIsHide("goddess_shouhu")
	show_list[4] = open_fun_data:CheckIsHide("goddess_shengong")
	show_list[5] = open_fun_data:CheckIsHide("goddess_shenyi")
	show_list[6] = open_fun_data:CheckIsHide("goddess_shengwu")
	show_list[7] = open_fun_data:CheckIsHide("goddess_shengwu")  ---共鸣
	for k,v in pairs(show_list) do
		self.toggle_list[k].transform.parent.gameObject:SetActive(v == true)
	end
	self:UpdataShengWuShowOrHideTab()
end

function GoddessView:ShengongUpGradeResult(result)
	if self.shengong_content_view then
		self.shengong_content_view:ShengongUpGradeResult(result)
	end
end

function GoddessView:ShenyiUpGradeResult(result)
	if self.shenyi_content_view then
		self.shenyi_content_view:ShenyiUpGradeResult(result)
	end
end

function GoddessView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Goddess)
	end
	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end

	if self.goddess_info_view then
		self.goddess_info_view:DeleteMe()
		self.goddess_info_view = nil
	end

	if self.camp_content_view then
		self.camp_content_view:DeleteMe()
		self.camp_content_view = nil
	end

	if self.shengong_content_view then
		self.shengong_content_view:DeleteMe()
		self.shengong_content_view = nil
	end

	if self.shenyi_content_view then
		self.shenyi_content_view:DeleteMe()
		self.shenyi_content_view = nil
	end

	if self.role_content_view then
		self.role_content_view:DeleteMe()
		self.role_content_view = nil
	end

	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:DeleteMe()
		self.shengwu_content_all_view = nil
	end

	if self.gongming_content_view  then
		self.gongming_content_view:DeleteMe()
		self.gongming_content_view = nil
	end

	-- 清理变量和对象
	self.goddess_info_go = nil
	self.camp_content_go = nil
	self.shengong_content_go = nil
	self.shenyi_content_go = nil
	self.shouhu_content_go = nil
	self.role_content_go = nil
	self.shengwu_content_all_go = nil
	self.gongming_content_go = nil
	self.rotate_event_trigger = nil
	self.btn_close = nil
	self.toggle_list = nil
	self.diamond = nil
	self.bind_gold = nil
	self.shengong_red_point = nil
	self.shenyi_red_point = nil
	self.shouhu_red_point = nil
	self.sheng_wu_red_point = nil
	self.gong_ming_red_point = nil
	self.show_blue_bg = nil
	self.effect_root = nil
	self.godess_active_btn = nil
	self.godess_up_btn = nil
	self.godess_line_up_fight = nil
	self.show_bipin_icon = nil
	self.show_shengwu_bg = nil
	self.red_point_list = nil
	self.camp_red_point = nil
	self.biping_icon = nil
	self.rising_star_flag = nil
	self.rising_type = nil
	self.show_rising_star_red = nil
	self.bipingredpoint = nil

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if nil ~= self.bipin_remind_change then
		RemindManager.Instance:UnBind(self.bipin_remind_change)
		self.bipin_remind_change = nil
	end

	if nil ~= self.rising_star_remind_change then
		RemindManager.Instance:UnBind(self.rising_star_remind_change)
		self.rising_star_remind_change = nil
	end
end

-- 玩家钻石改变时
function GoddessView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.diamond:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function GoddessView:CloseCallBack()
	AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T = {}
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.shengong_content_view then
		self.shengong_content_view:RemoveNotifyDataChangeCallBack()
	end
	if self.shenyi_content_view then
		self.shenyi_content_view:RemoveNotifyDataChangeCallBack()
	end
	self:StopAutoJinjie()
	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end

	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end
	if self.camp_content_view then
		self.camp_content_view:SetIsOpen(false)
		self.camp_content_view:CancelAllQuest()
	end
	if self.goddess_info_view then
		-- self.goddess_info_view:SetCurrentXiannvID(0)
		self.goddess_info_view:CanCelTheQuest()
	end

	if self.time_bipin_quest ~= nil then
		GlobalEventSystem:UnBind(self.time_bipin_quest)
		self.time_bipin_quest = nil
	end
	if TipsCtrl.Instance:GetBiPingView() then
		TipsCtrl.Instance:GetBiPingView():Close()
	end
end

function GoddessView:SetModel()
	local xiannv_id = self.goddess_info_view and self.goddess_info_view:GetCurrentXiannvID() or 0
	local resid = 0
	--根据是否幻化去取不同的模型ID
	if GoddessData.Instance:GetHuanHuaId() == -1 then
		resid = GoddessData.Instance:GetXianNvCfg(xiannv_id).resid
	else
		resid = GoddessData.Instance:GetXianNvHuanHuaCfg(GoddessData.Instance:GetHuanHuaId()).resid
	end
	self.goddess_info_view.model_view:SetMainAsset(ResPath.GetGoddessModel(resid))
	local bundle, asset = ResPath.GetGoddessModel(GoddessData.Instance:GetShowInfoRes(xiannv_id))
end

function GoddessView:OnFlush(param_list)
	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.goddess_shengong then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetShenGongDegreeRemind() == 1)
	elseif cur_index == TabIndex.goddess_shenyi then
		self.bipingredpoint:SetValue(KaiFuDegreeRewardsData.Instance:GetShenYiDegreeRemind() == 1)
	end
	if cur_index == TabIndex.goddess_info then
		local the_xiannv_id = -1
		if param_list.all then
			if param_list.all.item_id then
				the_xiannv_id = GoddessData.Instance:GetXianIdByActiveId(param_list.all.item_id)
			end
		end
		if self.is_jump_open == true then
			if the_xiannv_id > -1 then
				if self.goddess_info_view then
					self.goddess_info_view:SetToIconIndex(the_xiannv_id)
					self.is_jump_open = false
					self:SetModel()
				end
			else
				if self.goddess_info_view then
					local jump_xn_id = GoddessData.Instance:GetCanActiveXiannvId()
					if jump_xn_id ~= -1 then
						self.goddess_info_view:SetToIconIndex(jump_xn_id)
						self.is_jump_open = false
					else
						self.goddess_info_view:ReloadData()
						self:SetModel()
					end
				end
			end
		end
	end

	for k,v in pairs(param_list) do
		if "shengwu_red" == k then
			if cur_index == TabIndex.goddess_shengwu or cur_index == TabIndex.goddess_gongming then
				if self.shengwu_content_all_view then
					self.shengwu_content_all_view:FlushRed()
				end
			end
			if cur_index == TabIndex.goddess_gongming then
				if self.gongming_content_view then
					self.gongming_content_view:OnFlush()
				end
			end
		elseif "miling_change" == k then
			if cur_index == TabIndex.goddess_shengwu or cur_index == TabIndex.goddess_gongming then
				if self.shengwu_content_all_view then
					self.shengwu_content_all_view:UpdataView()
				end
			end
		end
	end

	if param_list == "shengong" then
		if cur_index == TabIndex.goddess_shengong then
			if self.shengong_content_view then
				self.shengong_content_view:OnFlush(param_list)
			end
		end
		return
	elseif param_list == "shenyi" then
		if cur_index == TabIndex.goddess_shenyi then
			if self.shenyi_content_view then
				self.shenyi_content_view:OnFlush(param_list)
			end
		end
		return
	end
	for k,v in pairs(param_list) do
		if k == "shengong" then
			if cur_index == TabIndex.goddess_shengong then
				if self.shengong_content_view then
					self.shengong_content_view:OnFlush(param_list)
				end
			end
		elseif k == "shenyi" then
			if cur_index == TabIndex.goddess_shenyi then
				if self.shenyi_content_view then
					self.shenyi_content_view:OnFlush(param_list)
				end
			end
		elseif k == "sg" then
			self:CancelSGPreviewToggle()
		elseif k == "sy" then
			self:CancelSYPreviewToggle()
		end
	end
end

function GoddessView:FlushRisingStarRed()
	if self.show_rising_star_red then
		self.show_rising_star_red:SetValue(KaifuActivityData.Instance:GetRisingStarRemind())
	end
end

function GoddessView:OpenIndexCheck(i)
	AdvanceCtrl.Instance:OpenClearBlessView(ViewName.Goddess, self.show_index, BindTool.Bind(self.OnToggleClick, self, i))
end

function GoddessView:OnToggleClick(i)
	if self.toggle_list[i] and not self.toggle_list[i].toggle.isOn then
		self.toggle_list[i].toggle.isOn = true
	end
	if i == 1 then
		if self.tab_index ~= TabIndex.goddess_info then
			self.tab_index = TabIndex.goddess_info
			self:ChangeToIndex(self.tab_index)
			--切换到信息刷新一下
			if self.goddess_info_view then
				self.goddess_info_view:Flush()
			end
		end
	elseif i == 2 then
		if self.tab_index ~= TabIndex.goddess_camp then
			self.tab_index = TabIndex.goddess_camp
			self:ChangeToIndex(self.tab_index)
		end
	elseif i == 3 then
		if self.tab_index ~= TabIndex.goddess_shouhu then
			self.tab_index = TabIndex.goddess_shouhu
			self:ChangeToIndex(self.tab_index)
		end
	elseif i == 4 then
		if self.tab_index ~= TabIndex.goddess_shengong then
			self.tab_index = TabIndex.goddess_shengong
			self:ChangeToIndex(self.tab_index)
		end
	elseif i == 5 then
		if self.tab_index ~= TabIndex.goddess_shenyi then
			self.tab_index = TabIndex.goddess_shenyi
			self:ChangeToIndex(self.tab_index)
		end
	elseif i == 6 then
		if self.tab_index ~= TabIndex.goddess_shengwu  then
			self.tab_index = TabIndex.goddess_shengwu
			self:ChangeToIndex(self.tab_index)
		end
	elseif i == 7 then
		if self.tab_index ~= TabIndex.goddess_gongming then
			self.tab_index = TabIndex.goddess_gongming
			self:ChangeToIndex(self.tab_index)
			--切换到共鸣刷新一下
			if self.gongming_content_view then
				self.gongming_content_view:OnFlush()
			end
		end
	end
	self:SetBiPinIcon()
end

function GoddessView:FlushShengongModel()
	if self.shengong_content_view then
		self.shengong_content_view:FlushView()
		self.shengong_content_view:SetArrowState(nil, true)
	end
end

function GoddessView:FlushShenyiModel()
	if self.shenyi_content_view then
		self.shenyi_content_view:FlushView()
		self.shenyi_content_view:SetArrowState(nil, true)
	end
end

function GoddessView:StopAutoJinjie(tab_index)
	if self.shengong_content_view and self.shenyi_content_view then
		if self.shengong_content_view.is_auto or self.shenyi_content_view.is_auto then
			if self.tab_index ~= tab_index then
				if self.tab_index == TabIndex.goddess_shengong then
					self.shengong_content_view:OnAutomaticAdvance()
				elseif self.tab_index == TabIndex.goddess_shenyi then
					self.shenyi_content_view:OnAutomaticAdvance()
				end
			end
		end
	end
end

function GoddessView:OpenRisingStar()
	ViewManager.Instance:Open(ViewName.KiaFuRisingStarView)
end

--移除物品回调
function GoddessView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function GoddessView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GoddessView:ItemDataChangeCallback()
	if self.shouhu_content_view then
		self.shouhu_content_view:FlushItemNum()
	end
	if self.show_index == TabIndex.goddess_shengong and self.shengong_content_view then
		self.shengong_content_view:SetPropItemCellsData()
	elseif self.show_index == TabIndex.goddess_shenyi and self.shenyi_content_view then
		self.shenyi_content_view:SetPropItemCellsData()
	end

end

--引导用函数
function GoddessView:GodessIcon1Click()
	if self:IsLoaded() and self.toggle_list[2].toggle.isOn then
		if self.camp_content_view.goddess_select_view then
			if self.camp_content_view.goddess_select_view.cell_list[0] then
				self.camp_content_view.goddess_select_view.cell_list[0].cell.root_node.toggle.isOn = true
			end
		end
	end
end

function GoddessView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.goddess_info then
		self.toggle_list[1].toggle.isOn = true
	elseif index == TabIndex.goddess_camp then
		self.toggle_list[2].toggle.isOn = true
	end
end

function GoddessView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.goddess_info then
			if self.toggle_list[1].gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.goddess_info)
				return self.toggle_list[1], callback
			end
		elseif index == TabIndex.goddess_camp then
			if self.toggle_list[2].gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.goddess_camp)
				return self.toggle_list[2], callback
			end
		end
	elseif ui_name == GuideUIName.GodessIcon1 then
		if self[ui_name].gameObject.activeInHierarchy then
			local callback = BindTool.Bind(self.GodessIcon1Click, self)
			return self[ui_name], callback
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function GoddessView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value == false then
		if self.shenyi_content_view then
			self.shenyi_content_view:CancelTheQuest()
		end

		if self.shengong_content_view then
			self.shengong_content_view:CancelTheQuest()
		end

		if self.shouhu_content_view then
			self.shouhu_content_view:ReSetAutoState(false)
		end

		self:StopAutoJinjie(TabIndex.goddess_shengong)
		self:StopAutoJinjie(TabIndex.goddess_shenyi)

		if self.camp_content_view then
			self.camp_content_view:CancelAllQuest()
		end
	end
end

function GoddessView:AsyncLoadView(index)
	if index == TabIndex.goddess_info and self.goddess_info_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "GoddessContent",
			function(obj)
				obj.transform:SetParent(self.goddess_info_go.transform, false)
				obj = U3DObject(obj)
				self.goddess_info_view = GoddessInfoView.New(obj)
				self.goddess_info_view:Flush()
				self:InInfo()
				self:SetModel()
				self.godess_up_btn = self.goddess_info_view:GetUpGradeBtn()
				self.godess_active_btn = self.goddess_info_view:GetActiveBtn()
			end)
	elseif index == TabIndex.goddess_camp and self.camp_content_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "CampContent",
			function(obj)
				obj.transform:SetParent(self.camp_content_go.transform, false)
				obj = U3DObject(obj)
				self.camp_content_view = GoddessCampView.New(obj)
				self:InCamp()
				self.godess_line_up_fight = self.camp_content_view.line_up_fight
				self.godess_icon1 = self.camp_content_view.godess_icon1
			end)
	elseif index == TabIndex.goddess_shengong and self.shengong_content_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "ShenGongContent",
			function(obj)
				obj.transform:SetParent(self.shengong_content_go.transform, false)
				obj = U3DObject(obj)
				self.shengong_content_view = AdvanceShengongView.New(obj)
				self:InShengong()
			end)
	elseif index == TabIndex.goddess_shenyi and self.shenyi_content_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "ShenYiContent",
			function(obj)
				obj.transform:SetParent(self.shenyi_content_go.transform, false)
				obj = U3DObject(obj)
				self.shenyi_content_view = AdvanceShenyiView.New(obj)
				self:InShenyi()
			end)
	elseif index == TabIndex.goddess_shengwu and self.shengwu_content_all_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "ShengWuAllContent",
			function(obj)
				obj.transform:SetParent(self.shengwu_content_all_go.transform, false)
				obj = U3DObject(obj)
				self.shengwu_content_all_view = GoddessShengWuALLView.New(obj)
				if self.show_index == TabIndex.goddess_gongming then
					self.shengwu_content_all_view:OnSelectedView(1)
				end
			end)
	elseif index == TabIndex.goddess_gongming and self.gongming_content_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/goddess_prefab", "GongMingContent",
			function(obj)
				obj.transform:SetParent(self.gongming_content_go.transform, false)
				obj = U3DObject(obj)
				self.gongming_content_view = GoddessGongMingView.New(obj)
				self.gongming_content_view:OnFlush()
			end)
	end
end

function GoddessView:ShowIndexCallBack(index)
	AdvanceData.Instance:SetViewOpenFlag(ViewName.Goddess, index)
	self.tab_index = index
	self:AsyncLoadView(index)
	if index == TabIndex.goddess_camp then
		self.show_shengwu_bg:SetValue(false)
	elseif index == TabIndex.goddess_shengwu or index == TabIndex.goddess_gongming then
		self.show_blue_bg:SetValue(true)
		self.show_shengwu_bg:SetValue(true)
	else
		self.show_shengwu_bg:SetValue(false)
	end

	if index == TabIndex.goddess_info then
		self:OnToggleClick(1)
		self:InInfo()
	elseif index == TabIndex.goddess_camp then
		self:OnToggleClick(2)
		self:InCamp()
	elseif index == TabIndex.goddess_shouhu then
		self:OnToggleClick(3)
		self:InShouhu()
	elseif index == TabIndex.goddess_shengong then
		self:OnToggleClick(4)
		self:InShengong()
	elseif index == TabIndex.goddess_shenyi then
		self:OnToggleClick(5)
		self:InShenyi()
	elseif index == TabIndex.goddess_shengwu then
		self:OnToggleClick(6)
		self:InShengWuAll(index)
	elseif index == TabIndex.goddess_gongming then
		self:OnToggleClick(7)
		self:InGongMing()
	end
	local index_cfg = CompetitionActivityData.Instance:GetBiPinTips(index) or false

	if self:ShowBiPinIcon() then
		TipsCtrl.Instance:ShowTipBiPingView(index_cfg, self.biping_icon)
	end

	local flag = -1--KaifuActivityData.Instance:GetIsShowUpStarBtn(index)
	-- 是否显示升星助力图标
	self.rising_star_flag:SetValue(flag)
	if flag ~= -1 then
		self.rising_type:SetAsset(ResPath.GetRisingStarActivityRes(risingstar_img_path[flag] .. ".png"))
	end
	self:SetBiPinIcon()
end

function GoddessView:InGongMing()
	if not self.toggle_list[7].toggle.isOn then
		self.toggle_list[7].toggle.isOn = true
	end

	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end

	if self.shengong_content_view then
		self.shengong_content_view:CancelTheQuest()
	end

	if self.shouhu_content_view then
		self.shouhu_content_view:ReSetAutoState(false)
	end

	if self.goddess_camp_view then
		local goddess_select_view = self.goddess_camp_view:GetSelectIconView()
		if goddess_select_view then
			goddess_select_view:SetViewOpenOrNot(false)
		end
	end
end

function GoddessView:InInfo()
	if not self.toggle_list[1].toggle.isOn then
	 	self.toggle_list[1].toggle.isOn = true
	end
	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end
	if self.shengong_content_view then
		self.shengong_content_view:CancelTheQuest()
	end

	if self.goddess_camp_view then
		local goddess_select_view = self.goddess_camp_view:GetSelectIconView()
		if goddess_select_view then
			goddess_select_view:SetViewOpenOrNot(false)
		end
	end
	if self.camp_content_view then
		self.camp_content_view:SetIsOpen(false)
		self.camp_content_view:CancelAllQuest()
	end
	if self.shouhu_content_view then
		self.shouhu_content_view:ReSetAutoState(false)
	end
end

function GoddessView:InCamp()
	if not self.toggle_list[2].toggle.isOn then
	 	self.toggle_list[2].toggle.isOn = true
	end

	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end

	if self.shengong_content_view then
		self.shengong_content_view:CancelTheQuest()
	end

	if self.camp_content_view then
		self.camp_content_view:AllCellListOnFlush()
		self.camp_content_view:SetIsOpen(true)
		self.camp_content_view:SetBlockActive(false)
		self.camp_content_view:ReflushLineupView(true)
		self.camp_content_view:FlushShowShadow()
	end

	if self.shouhu_content_view then
		self.shouhu_content_view:ReSetAutoState(false)
	end
end

function GoddessView:InShouhu()
	if not self.toggle_list[3].toggle.isOn then
	 	self.toggle_list[3].toggle.isOn = true
	end
	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end
	if self.shengong_content_view then
		self.shengong_content_view:CancelTheQuest()
	end
	if self.shouhu_content_view then
		self.shouhu_content_view:OpenCallBack()
	end

	if self.goddess_camp_view then
		self.camp_content_view:CancelAllQuest()
		local goddess_select_view = self.goddess_camp_view:GetSelectIconView()
		if goddess_select_view then
			goddess_select_view:SetViewOpenOrNot(false)
		end
	end
end

function GoddessView:InShengong()
	if not self.toggle_list[4].toggle.isOn then
	 	self.toggle_list[4].toggle.isOn = true
	end
	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end
	if self.shouhu_content_view then
		self.shouhu_content_view:ReSetAutoState(false)
	end

	if self.goddess_camp_view then
		local goddess_select_view = self.goddess_camp_view:GetSelectIconView()
		if goddess_select_view then
			goddess_select_view:SetViewOpenOrNot(false)
		end
	end

	if self.shengong_content_view then
		self.shengong_content_view:FlushView()
		self.shengong_content_view:CancelPreviewToggle()
	end

	if self.camp_content_view then
		self.camp_content_view:CancelAllQuest()
	end
	self:StopAutoJinjie(TabIndex.goddess_shengong)
end

function GoddessView:InShenyi()
	if not self.toggle_list[5].toggle.isOn then
		self.toggle_list[5].toggle.isOn = true
	end
	if self.shengong_content_view then
		self.shengong_content_view:CancelTheQuest()
	end

	if self.shouhu_content_view then
		self.shouhu_content_view:ReSetAutoState(false)
	end

	if self.goddess_camp_view then
		local goddess_select_view = self.goddess_camp_view:GetSelectIconView()
		if goddess_select_view then
			goddess_select_view:SetViewOpenOrNot(false)
		end
	end

	if self.shenyi_content_view then
		self.shenyi_content_view:FlushView()
		self.shenyi_content_view:CancelPreviewToggle()
	end

	if self.camp_content_view then
		self.camp_content_view:CancelAllQuest()
	end
	self:StopAutoJinjie(TabIndex.goddess_shenyi)
end

function GoddessView:InShengWuAll(index)
	if not self.toggle_list[6].toggle.isOn then
		self.toggle_list[6].toggle.isOn = true
	end

	if self.shenyi_content_view then
		self.shenyi_content_view:CancelTheQuest()
	end

	if self.shengong_content_view then
		self.shengong_content_view:CancelTheQuest()
	end

	if self.shouhu_content_view then
		self.shouhu_content_view:ReSetAutoState(false)
	end

	if self.goddess_camp_view then
		local goddess_select_view = self.goddess_camp_view:GetSelectIconView()
		if goddess_select_view then
			goddess_select_view:SetViewOpenOrNot(false)
		end
	end

end

function GoddessView:PlayUpStarEffect()
	if self:IsLoaded() then
		if self.effect_cd and self.effect_cd - Status.NowTime <= 0 and self.effect_root then
			EffectManager.Instance:PlayAtTransformCenter(
				"effects2/prefab/ui/ui_huoban_jinjiechenggong_prefab",
				"UI_huoban_jinjiechenggong",
				self.effect_root.transform,
				2.0)
			self.effect_cd = Status.NowTime + EFFECT_CD
		end
	end
end

function GoddessView:UpdataShengWuView()
	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:UpdataView()
	end
end

function GoddessView:ShowShengWuViewFly()
	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:ShowShengWuViewFly()
	end
end

function GoddessView:UpdataGongMingGrid(grid_id)
	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:UpdataGongMingGrid(grid_id)
	end
end

function GoddessView:UpdataGongMingLingYe()
	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:UpdataGongMingLingYe()
	end
end

function GoddessView:SetAllViewIndex(index)
	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:SetAllViewIndex(index)
	end
end

function GoddessView:UpdataShengWuShowOrHideTab()
	if self.shengwu_content_all_view then
		self.shengwu_content_all_view:ShowOrHideTab()
	end
end

function GoddessView:FlushGoddessInfoView()
	if self.goddess_info_view and self.toggle_list[1].toggle.isOn then
		--self.goddess_info_view:FlushRightView()
		self.goddess_info_view:Flush()
		self.goddess_info_view:AllCellOnFlush()
	end
end