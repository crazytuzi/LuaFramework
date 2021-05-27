
-- 鍔熻兘寮�鍚�
FunOpen = FunOpen or BaseClass(BaseController)
FunOpenTriggerType = {
	UpLevel = 1,			-- 鍗囩骇
	AddTask = 1,			-- 鎺ヤ换鍔�
	CompleteTask = 2,		-- 瀹屾垚浠诲姟
	FinishTask = 3,			-- 浜や换鍔�
}
FunOpenUiType = {
	Modular = 1,			-- 妯″潡
	Tab = 2,				-- 鏍囩
}

FunOpenTabType = {
	Vis = 1,				-- 闅愯棌
	Enable = 2,				-- 涓嶅彲鐐�
}

CIRCLEMAXLEVEl = 255  --姣忚浆瀵瑰簲绛夌骇

function FunOpen:__init()
	self.remind_cache = {}

	ViewManager.Instance:RegisterCheckFunOpen(BindTool.Bind(self.CheckFunOpen, self))
	RoleData.Instance:NotifyAttrChange(BindTool.Bind(self.OnRoleAttrChange, self))
	TaskData.Instance:ListenerTaskChange(BindTool.Bind(self.OnTaskChange, self))
	self.funopen_cfg = ConfigManager.Instance:GetAutoConfig("funopen_auto").funopen_list
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))

	self.back_stage_timer_acts_open_t = {}			-- 鍚庡彴銆侀檺鏃舵椿鍔ㄥ紑鍚�
	self.back_stage_timer_act_close_t = {}			-- 鍚庡彴銆侀檺鏃舵椿鍔ㄥ叧闂椿鍔�
	self:RegisterAllProtocols()
	self.hero_attr_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_ATTR_CHANGE, BindTool.Bind(self.HeroAttrChange, self))
end

function FunOpen:__delete()
	self.remind_cache = {}
	self.back_stage_timer_acts_open_t = {}
	self.back_stage_timer_act_close_t = {}
end

function FunOpen:CheckFunOpen(view_name, index)
	--print(view_name,index)
	local open_day = OtherData.Instance:GetOpenServerDays()
	for k,v in pairs(self.funopen_cfg) do
		if v.view_name == view_name and (v.ui_type ~= FunOpenUiType.Tab or TabIndex[v.index] == index) then
			if v.trigger_type == FunOpenTriggerType.UpLevel then
				if CHECKVIEWNAME[v.view_name] == view_name then
					if IS_AUDIT_VERSION == true then
						return false, ""
					else
						local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
						local role_circl = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
						--local true_level = role_circl*CIRCLEMAXLEVEl + role_level
						--local need_level = v.trigger_param[1]*CIRCLEMAXLEVEl + v.trigger_param[2]
						local txt = ""
						if v.trigger_param[1] ~= 0 then
							txt = string.format(Language.Common.FunOpenCirlceTip, v.trigger_param[1])
						end
						if role_circl < v.trigger_param[1] or role_level < v.trigger_param[2] then
							return false, string.format(Language.Common.FunOpenRoleLevelLimit, txt , v.trigger_param[2])
						end
						-- if  true_level < need_level then
						-- 	return false, string.format(Language.Common.FunOpenRoleLevelLimit, txt, v.trigger_param[2])
						-- end
						
					end
				else
					local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
					local role_circl = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
					--local true_level = role_circl*CIRCLEMAXLEVEl + role_level
					if view_name == ViewName.Zhanjiang and index == TabIndex.hero_circle then
						role_level = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
						role_circl = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
						--true_level = role_circl*CIRCLEMAXLEVEl + role_level
					end 
					--local need_level = v.trigger_param[1]*CIRCLEMAXLEVEl + v.trigger_param[2]
					local txt = ""
					if v.trigger_param[1] ~= 0 then
						txt = string.format(Language.Common.FunOpenCirlceTip, v.trigger_param[1])
					end
					if role_circl < v.trigger_param[1] or role_level < v.trigger_param[2] then
						return false, string.format(Language.Common.FunOpenRoleLevelLimit, txt , v.trigger_param[2])
					end
					-- if  true_level < need_level then
					-- 	return false, string.format(Language.Common.FunOpenRoleLevelLimit, txt , v.trigger_param[2])
					-- end
				end
			end 
			if v.open_day ~= "" and v.open_day > 0 then
				if  v.open_day > open_day then
					return false, string.format(Language.Common.FunOpenDayLimit, v.open_day)
				end
			end
		end	
	end
	if view_name == ViewName.NpcDialog then
		if GuideCtrl.Instance:IsFuncGuideing() then
			return false
		end
	elseif view_name == ViewName.Welfare then
		return not IS_AUDIT_VERSION, ""
	elseif view_name == ViewName.OpenServiceAcitivity then
		return not OpenServiceAcitivityData.Instance:GetIsAllTabNoVisible()
	elseif view_name == ViewName.RefiningExp then
		return RefiningExpData.Instance:GetIconIsOpen()
	elseif view_name == ViewName.ChargeFirst then
		return ChargeFirstData.Instance:GetFirstChargeIconOpen()
	-- elseif view_name == ViewName.ActOpenRemind then
	-- 	if Scene.Instance:GetSceneLogic():GetFubenType() > 0 then
	-- 		return false
	-- 	end
		--灞忚斀绁堢闈㈡澘
	-- elseif view_name == ViewName.Pray then
	-- 	return false
	elseif view_name == ViewName.ChargeFashion then
		return ChargeFashionData.Instance:GetChargeFasionIconOpen()
	elseif view_name == ViewName.Knight then --渚犲琛�
		return KnightData.Instance:OpenKnight()	
	elseif view_name == ViewName.ActiveDegree then
		return ActiveDegreeData.Instance:IsDisplay()
	elseif view_name == ViewName.RecycleYB then --鍥炴敹鍏冨疂
		return RecycleYBData.Instance:RecycleYBOpen()		
	elseif view_name ==  ViewName.SuperVip then
		return false
		-- if SuperVipData.Instance:GetSvipSpidInfo() then
		-- 	return true
		-- else
		-- 	return false
		-- end
		-- 姣忔棩鍏呭��
	elseif view_name == ViewName.RedPackage then
		return not IS_AUDIT_VERSION, ""

	--elseif view_name == ViewName.CompleteBag then

	-- 	if self.back_stage_timer_act_close_t[BACK_STAGE_TIMER_.ACTIVITY_ID.DAILY_RECHARGE] then
	-- 		ViewManager.Instance:Close(ViewName.ChargeEveryDay)
	-- 		return false
	-- 	end
	-- 	for k, v in pairs(self.back_stage_timer_acts_open_t) do
	-- 		if v.act_id == BACK_STAGE_TIMER_ACTIVITY_ID.DAILY_RECHARGE then
	-- 			return true
	-- 		end
	-- 	end
	-- 	return false
	-- 	-- 闄愭椂娲诲姩
	-- elseif view_name == ViewName.LimitedActivity then
	-- 	local vis = false
	-- 	if self.back_stage_timer_act_close_t[BACK_STAGE_TIMER_ACTIVITY_ID.TIME_LIMITED_GOODS] and 
	-- 		self.back_stage_timer_act_close_t[BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_RECHARGE] and 
	-- 		 self.back_stage_timer_act_close_t[BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_SPEND] then

	-- 		ViewManager.Instance:Close(ViewName.LimitedActivity)
	-- 		vis = false
	-- 	else
	-- 		for k, v in pairs(self.back_stage_timer_acts_open_t) do
	-- 			if v.act_id == BACK_STAGE_TIMER_ACTIVITY_ID.TIME_LIMITED_GOODS or
	-- 			v.act_id == BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_RECHARGE or
	-- 			v.act_id == BACK_STAGE_TIMER_ACTIVITY_ID.ACCUMULATE_SPEND then
	-- 				vis = true
	-- 				break
	-- 			end
	-- 		end
	-- 		ViewManager.Instance:FlushView(ViewName.LimitedActivity, 0, "tab_vis", self.back_stage_timer_act_close_t)
	-- 	end
	-- 	return vis
	elseif view_name == ViewName.CombineServerActivity then
		return CombineServerData.Instance:BoolOpen()
		-- 杩愯惀娲诲姩(闄愭椂绂忓埄)
	elseif view_name == ViewName.OperateActivity then
		return OperateActivityData.Instance:IsMainuiActivityIconShow()
		-- 闄愭椂姣忔棩鍏呭��
	elseif view_name == ViewName.LimitDailyCharge then
		return LimitDailyChargeData.Instance:GetEveryDayChargeIconOpen()
	elseif view_name == ViewName.ChellengeKBoss then
		return ChellengeKBossData.Instance:IsChellengeKBossOpen()
	elseif view_name == ViewName.ExtremeVip then
		return ExtremeVipData.Instance:IsExtremeVipIconShow()
	elseif view_name == ViewName.Feedback then
		return FeedbackData.Instance:IsShowFeedback()
	elseif view_name == ViewName.Carnival then
		return CarnivalData.Instance:AllActivityOpen()	
	elseif view_name == ViewName.CompleteBag then
		if IS_AUDIT_VERSION then --濡傛灉鏄鏍告湇锛岄殣钘�
			return not IS_AUDIT_VERSION, ""
		else  --涓嶆槸锛屾牴鎹暟鎹喅瀹�
			return CompleteBagData.Instance:IsShowCompleteBagIcon()
		end
	elseif view_name == ViewName.OpenSerRaceStandard then
		return OpenSerRaceStandardData.Instance:IsShowMainUiEntryIcon()
	elseif view_name == ViewName.FirstChargePayback then		-- 棣栧厖杩斿埄
		return OperateActivityData.Instance:IsShowFirstChargePayback()
	elseif view_name == ViewName.NationalDayActs then		-- 鍥藉簡娲诲姩
		return OperateActivityData.Instance:IsShowNationalDayActIcon()
	-- elseif view_name == ViewName.SpringFestival then		-- 鏂版槬娲诲姩
	-- 	return OperateActivityData.Instance:IsShowSpringFestival()
			
	elseif view_name == ViewName.HeroGoldBing then--英雄神兵
		local money,oper_cnt = HeroGoldBingData.Instance:getChargeInfo()
		print("oper_cnt ----- "..oper_cnt)
		if oper_cnt == 1 then
			return false
		end
	elseif view_name == ViewName.HeroGoldDun then--英雄神盾
		if HeroGoldDunData.Instance:GetEquipDunState() == 1 then
			return false
		end
	end
	return true
end

function FunOpen:OnRoleAttrChange(key, value, old_value)
	if key == OBJ_ATTR.CREATURE_LEVEL then			-- 绾ф暟
		local role_circl = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		for k,v in pairs(self.funopen_cfg) do
			--if v.trigger_type == FunOpenTriggerType.UpLevel  then
				-- local true_level = role_circl*CIRCLEMAXLEVEl + value
				-- local need_level = v.trigger_param[1]*CIRCLEMAXLEVEl + v.trigger_param[2]
				-- if true_level >= need_level then
				if v.trigger_type == FunOpenTriggerType.UpLevel and v.trigger_param[2] <= value and v.trigger_param[1] <= role_circl then
					if v.ui_type == FunOpenUiType.Tab then
						ViewManager.Instance:SetFunOpenTabVisible(v.view_name, TabIndex[v.index], v.tab_param)
					elseif v.ui_type == FunOpenUiType.Modular then
						ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
					end
					--寮�鍚悗鎻愰啋
					if self.remind_cache[v.view_name] == nil then
						if v.view_name == ViewName.ActiveDegree then
							RemindManager.Instance:DoRemind(RemindName.ActiveDegree)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Compose then
							RemindManager.Instance:DoRemind(RemindName.XFUpLv)
							RemindManager.Instance:DoRemind(RemindName.ShieldUpGrade)
							RemindManager.Instance:DoRemind(RemindName.DiamondUpLv)
							RemindManager.Instance:DoRemind(RemindName.SoulBeadUpLv)
							RemindManager.Instance:DoRemind(RemindName.SaintballUpGrade)
							RemindManager.Instance:DoRemind(RemindName.SpecialRingUpGrade)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Achieve then
							RemindManager.Instance:DoRemind(RemindName.AchieveMedal)
							RemindManager.Instance:DoRemind(RemindName.AchieveAchievement)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Role then
							RemindManager.Instance:DoRemind(RemindName.InnerUpGrade)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.InvestPlan then	-- 鎶曡祫璁″垝
							RemindManager.Instance:DoRemind(RemindName.InvestPlan)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Exploit then		-- 鍔熷媼
							RemindManager.Instance:DoRemind(RemindName.Exploit)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Zhanjiang then
							RemindManager.Instance:DoRemind(RemindName.HeroCanEquip)
							self.remind_cache[v.view_name] = 1
						end
					end
				end
			--end
		end	
	elseif key == OBJ_ATTR.ACTOR_CIRCLE then		--杞暟
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		for k,v in pairs(self.funopen_cfg) do
			if v.trigger_type == FunOpenTriggerType.UpLevel and v.trigger_param[2] <= role_lv and v.trigger_param[1] <= value then
				-- local true_level = value*CIRCLEMAXLEVEl + role_lv
				-- local need_level = v.trigger_param[1]*CIRCLEMAXLEVEl + v.trigger_param[2]
				-- if true_level >= need_level then
					if v.ui_type == FunOpenUiType.Tab then
						ViewManager.Instance:SetFunOpenTabVisible(v.view_name, TabIndex[v.index], v.tab_param)
					elseif v.ui_type == FunOpenUiType.Modular then
						ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
					end
					--寮�鍚悗鎻愰啋
					if self.remind_cache[v.view_name] == nil then
						if v.view_name == ViewName.ActiveDegree then
							RemindManager.Instance:DoRemind(RemindName.ActiveDegree)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Compose then
							RemindManager.Instance:DoRemind(RemindName.XFUpLv)
							RemindManager.Instance:DoRemind(RemindName.ShieldUpGrade)
							RemindManager.Instance:DoRemind(RemindName.DiamondUpLv)
							RemindManager.Instance:DoRemind(RemindName.SoulBeadUpLv)
							RemindManager.Instance:DoRemind(RemindName.SaintballUpGrade)
							RemindManager.Instance:DoRemind(RemindName.SpecialRingUpGrade)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Achieve then
							RemindManager.Instance:DoRemind(RemindName.AchieveMedal)
							RemindManager.Instance:DoRemind(RemindName.AchieveAchievement)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Role then
							RemindManager.Instance:DoRemind(RemindName.InnerUpGrade)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.InvestPlan then
							RemindManager.Instance:DoRemind(RemindName.InvestPlan)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Exploit then
							RemindManager.Instance:DoRemind(RemindName.Exploit)
							self.remind_cache[v.view_name] = 1
						elseif v.view_name == ViewName.Zhanjiang then
							RemindManager.Instance:DoRemind(RemindName.HeroCanEquip)
							self.remind_cache[v.view_name] = 1
						end
					end
				--end
			end

			-- 寮�鍚悗鎻愰啋
			-- if v.trigger_type == FunOpenTriggerType.UpLevel  then
			-- 	local bool = false
			-- 	if value >= 1 then
			-- 		bool = true
			-- 	else
			-- 		if v.trigger_param[2] <= role_lv then
			-- 			bool = true
			-- 		end
			-- 	end
				-- if bool then
					
				-- end
			--end
		end	
	end
end

function FunOpen:OnRecvMainRoleInfo()
	self:CommonAllBackStageActsDataReq()
	ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
end

function FunOpen:OnTaskChange(reason, task_id)
	if "finish" == reason then
	end
end

function FunOpen:RegisterAllProtocols()
	--鍚庡彴娲诲姩銆侀檺鏃舵椿鍔ㄥ紑鍚�佸叧闂�
	self:RegisterProtocol(SCCommonBackStageActOpenIss, "OnCommonBackStageActOpenIss")
	self:RegisterProtocol(SCCommonBackStageActCloseIss, "OnCommonBackStageActCloseIss")
end

--[閫氱敤娲诲姩]閫氱煡瀹㈡埛绔煇娲诲姩(鍚庡彴娲诲姩銆佸畾鏃舵椿鍔ㄧ瓑)寮�鍚� 鍙姹傘�傘�傜涓�娆＄櫥闄嗚姹�
function FunOpen:OnCommonBackStageActOpenIss(protocol)
	--print("娲诲姩寮�鍚�")
	-- PrintTable(protocol)
	if not next(self.back_stage_timer_acts_open_t) then
		for k, v in pairs(protocol.open_acts_info) do
			table.insert(self.back_stage_timer_acts_open_t, v.act_id, v)
		end
	else
		for k, v in pairs(protocol.open_acts_info) do
			if not self.back_stage_timer_acts_open_t[v.act_id] then
				table.insert(self.back_stage_timer_acts_open_t, v.act_id, v)
			end
		end
	end
	self.back_stage_timer_act_close_t = {}
	for i = BACK_STAGE_TIMER_ACTIVITY_ID.DAILY_RECHARGE, BACK_STAGE_TIMER_ACTIVITY_ID.ACT_MAX - 1 do
		if not self.back_stage_timer_acts_open_t[i] then
			self.back_stage_timer_act_close_t[i] = i
		end
	end
	-- PrintTable(self.back_stage_timer_acts_open_t)

	ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
end

--[閫氱敤娲诲姩]閫氱煡瀹㈡埛绔煇娲诲姩(鍚庡彴娲诲姩銆佸畾鏃舵椿鍔ㄧ瓑)鍏抽棴
function FunOpen:OnCommonBackStageActCloseIss(protocol)
	--print("娲诲姩鍏抽棴 id = ", protocol.act_id)
	self.back_stage_timer_act_close_t[protocol.act_id] = protocol.act_id
	if protocol.act_id == BACK_STAGE_TIMER_ACTIVITY_ID.DAILY_RECHARGE then
		ChargeEveryDayCtrl.Instance:CloseAct()
	else 
		LimitedActivityCtrl.Instance:CloseAct()
	end
end

--[閫氱敤娲诲姩]璇锋眰鍚庡彴娲诲姩鐨勬墍鏈夋暟鎹� 涓婄嚎璇锋眰(杩斿洖 0 80)
function FunOpen:CommonAllBackStageActsDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCommonAllBackStageActsDataReq)
	protocol:EncodeAndSend()
end

function FunOpen:HeroAttrChange(key, value, old_value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		local circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local level = circle * CIRCLEMAXLEVEl + value
		if (old_value == nil or old_value < ZhanjiangData.ZSActiveLv) and level >= ZhanjiangData.ZSActiveLv then
			self:CheckFunOpen(ViewName.Zhanjiang, TabIndex.hero_circle)
		end
	end
end