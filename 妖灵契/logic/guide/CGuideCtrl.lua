local CGuideCtrl = class("CGuideCtrl", CCtrlBase)

define.Guide = {
	Event = 
	{
		StartGuide = 1,
		EndGuide = 2,
	},
}

CGuideCtrl.LogToggle = 0

function CGuideCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:InitValue()
end

function CGuideCtrl.ResetUpdateInfo(self)
	self:SetGuideKey(nil)
	self.m_UpdateInfo = {
		guide_type = nil,
		guide_key = nil,
		cur_idx = 1,
		continue_condition = nil,
		complete_type = 0,
		after_process = nil,
		after_mask = nil,
	}
end

function CGuideCtrl.TriggerAll(self)
	for k, v in pairs(data.guidedata.Trigger_Check) do
		self:TriggerCheck(k)
	end
end

--触发式检测，非Update
function CGuideCtrl.TriggerCheck(self, sTrigger)
	if not self.m_IsInit then
		return
	end
	self:GuideLog("TriggerCheck step 1 ", sTrigger)

	--如果当前在组队，则不处理新手
	if sTrigger ~= "war" and g_TeamCtrl:IsJoinTeam() then
		return
	end

	--检测剧场播放,如果有剧场播放，则不需要处理新手
	if self:CheckStroyAni() then
		return
	end

	self:GuideLog("TriggerCheck step 3 ", sTrigger)

	--如果当前在修行中 护送，自动师门， 探索 无法触发引导
	if (g_TaskCtrl:IsAutoDoingShiMen() and self:IsCustomGuideFinishByKey("Dialogue_Shimen") )
		or g_AnLeiCtrl:IsInAnLei() 
		or g_ActivityCtrl:IsDailyCultivating() 
		or g_ActivityCtrl:IsDailyTraining() 
		or g_ConvoyCtrl:IsConvoying() then
		return
	end

	self:GuideLog("TriggerCheck step 4 ", sTrigger)

	local lGuideTypes = data.guidedata.Trigger_Check[sTrigger] or {}
	local lTypes = {}
	for i, sGuideType in ipairs(lGuideTypes) do
		if self:IsNeedGuide(sGuideType) then
			local sCondition = data.guidedata[sGuideType].necessary_condition
			if self:TriggerCheckWarType(sTrigger) and (not sCondition or self:CallGuideFunc(sCondition) ) then
				table.insert(lTypes, sGuideType)
			end
		end
	end
	if next(lTypes) then
		self:GuideLog("TriggerCheck step 5 ", sTrigger)
		self.m_CheckTypes[sTrigger] = lTypes
		self:StartCheck()

	else
		self:GuideLog("TriggerCheck step 6 ", sTrigger)
		self.m_CheckTypes[sTrigger] = nil
	end
end

function CGuideCtrl.RestartGuide(self, sGuideType)
	if not self.m_Flags then
		return
	end	
	for k, _ in ipairs(self.m_Flags) do
		if string.find(k, sGuideType) == nil then
			self.m_Flags[k] = nil
		end
	end
end

function CGuideCtrl.CheckCurGuide(self)	
	self:GuideLog(" self.m_UpdateInfo.guide_type, ", self.m_UpdateInfo.guide_type)
	if not self.m_UpdateInfo.guide_type then
		return false
	end

	if #self.m_CheckAllGuides > 0 then
		local d = data.guideprioritydata.DATA
		local oGuide = d[self.m_UpdateInfo.guide_type]
		local nGuide = d[self.m_CheckAllGuides[1]]
		if nGuide and oGuide and nGuide.sort < oGuide.sort then			
			CGuideView:CloseView()
			self:ResetUpdateInfo()
			return false
		end
	end

	local sGuideType = self.m_UpdateInfo.guide_type
	local sGuideData = data.guidedata[sGuideType]
	local sCondition = sGuideData.necessary_condition
	self:GuideLog(" CheckCurGuide  step 1   " , sCondition, sGuideData)
	if not sCondition or self:CallGuideFunc(sCondition) then
		self:GuideLog(" CheckCurGuide  step 2   ", self.m_UpdateInfo.guide_key)
		if self.m_UpdateInfo.guide_key then
			self:GuideLog(" CheckCurGuide  step 3   ", self.m_UpdateInfo.continue_condition)
			if self.m_UpdateInfo.continue_condition then--检查继续条件
				if self:CallGuideFunc(self.m_UpdateInfo.continue_condition) then
					self:GuideLog(" CheckCurGuide  step 4  ")
					self:Continue()
				end
			end
			self:GuideLog(" CheckCurGuide  step 5   ")
			return true 
		end

		local iStart = self.m_UpdateInfo.cur_idx or 1
		local lGuides = sGuideData.guide_list
		self:GuideLog(" CheckCurGuide  step 6   ", iStart, #lGuides)
		for i = iStart, #lGuides do
			local v = lGuides[i]
			v["guide_key"] = sGuideType.."_"..tostring(i)
			self:GuideLog(" CheckCurGuide  step 7 ", v.guide_key, self:IsNeedGuide(v.guide_key))
			if self:IsNeedGuide(v.guide_key) then		
				self:GuideLog(" CheckCurGuide  step 8  ", v.guide_key, v.start_condition, self:CallGuideFunc(v.start_condition))	
				if not v.start_condition or self:CallGuideFunc(v.start_condition) then
					if not self.m_UpdateInfo.cur_idx then
						self.m_UpdateInfo.cur_idx = i
					end
					self:GuideLog(" CheckCurGuide  step 9 ", iStart)
					self:StartGuide(v)--有一个满足条件, 则后面都不检查
				end
				break
			end
		end
		self:GuideLog(" CheckCurGuide  step 10 ", iStart)
		return true
	else
		if self.m_UpdateInfo.complete_type == 1 then
			self:RestartGuide(sGuideType)
		end
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
		end
		self:ResetUpdateInfo() --没满足必备条件，重置引导
		return false
	end
end

function CGuideCtrl.Update(self)
	self:GuideLog(" CheckCurGuide  Update 1")
	if self.m_CheckTypes and next(self.m_CheckTypes) then
		local list = {}
		for k, v in pairs(self.m_CheckTypes) do
			for i, sGuideType in ipairs(v) do
				table.insert(list, sGuideType)
			end
		end
		if #list > 1 then
			table.sort(list, function (a, b)
				local d = data.guideprioritydata.DATA
				return d[a].sort < d[b].sort
			end)
		end
		self.m_CheckAllGuides = list
		self.m_CheckTypes = {}
	end
	if self:CheckCurGuide() then --一次只执行一个引导
		return true
	end
	self:GuideLog(" CheckCurGuide  Update 2")
	if not self.m_CheckAllGuides or not next(self.m_CheckAllGuides) then
		return false
	end
	self:GuideLog(" CheckCurGuide  Update 3")
	local list = {}
	for i, sGuideType in ipairs(self.m_CheckAllGuides) do
		if self:IsNeedGuide(sGuideType) then				
			local sGuideData = data.guidedata[sGuideType]
			local sCondition = sGuideData.necessary_condition	
			if not sCondition or self:CallGuideFunc(sCondition) then --找到新引导
				printc("找到新的引导类型", sGuideType)
				self.m_UpdateInfo.guide_type = sGuideType
				self.m_UpdateInfo.complete_type = sGuideData.complete_type	
				self.m_UpdateInfo.cur_idx = nil				
				return true
			end
			table.insert(list, sGuideType)
		end
	end

	self.m_CheckAllGuides = list

	if next(self.m_CheckAllGuides) then
		self:GuideLog(" CheckCurGuide  Update 4")
		return true
	else
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
		printc("停止引导检查,并且下一帧再检测引导")
		Utils.AddTimer(callback(self, "TriggerAll"), 0, 0)
		return false
	end
end

function CGuideCtrl.StartCheck(self)
	printc("开始引导检查")
	table.print(self.m_CheckTypes)
	printtrace()
	if not self.m_Timer then
		self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0, 0)
	end
end

function CGuideCtrl.AddGuideUI(self, sUIKey, oUI)
	if oUI then
		oUI.m_GuideKey = sUIKey
		self.m_UIRefs[sUIKey] = weakref(oUI)
	else
		self.m_UIRefs[sUIKey] = nil
	end
end

function CGuideCtrl.GetGuideUI(self, sUIKey)
	if not sUIKey then
		return
	end
	return getrefobj(self.m_UIRefs[sUIKey])
end

function CGuideCtrl.LoginInit(self, d)
	local list = table.copy(d)
	list.key = list.key or {}
	local bBan = IOTools.GetClientData("banguide")
	--只初始化一次
	if not self.m_Flags then
		self.m_Flags = {}
		for i, key in ipairs(list.key) do
			local temp = data.guideconfigdata.KeyToValue[key]
			if temp and temp.value then
				local t = temp.value
				if string.find(t, "N1Guide_") then
					t = string.gsub(t, "N1Guide_", "")
				end			
				self.m_Flags[t] = true
			else
				local t = key
				if string.find(t, "N1Guide_") then
					t = string.gsub(t, "N1Guide_", "")
				end			
				self.m_Flags[t] = true
				printc(" guide value is not exit ----> ", key)
			end		
		end
	end

	if Utils.IsEditor() and bBan == true then
		return
	end

	
	if not g_GuideCtrl:IsCustomGuideFinishByKey("welcome_three_end") then		
		g_NotifyCtrl:ShowAniSwitchBlackBg(5)
	end
	
	--登陆引时引进度处理
	self:LoginReCheckGuidedProgress(self.m_IsInit == false)

	--加载提示型引导
	self:LoginTipsGuide()
	self.m_IsInit = true
end

function CGuideCtrl.Continue(self)
	if not self.m_Flags then
		return
	end
	if self.m_UpdateInfo.guide_type and self.m_UpdateInfo.guide_key then
		printc("引导结束", self.m_UpdateInfo.guide_type, self.m_UpdateInfo.guide_key, self.m_UpdateInfo.cur_idx)
		self.m_IsGuide = false
		local dGuideType = data.guidedata[self.m_UpdateInfo.guide_type]
		self:CallGuideFunc(dGuideType.after_guide)
		local key = self.m_UpdateInfo.guide_key
		--complete_type
		--[[
		 参数为0：pass的时候，会完成那一步
		 参数为1：全部完成时才会完成引导
		 参数为3：管理类不会去记录引导
		]] 

		if self.m_UpdateInfo.complete_type == 0 then
			self.m_Flags[key] = true
			self:CtrlCC2GSFinishGuidance({[1] = key})
		elseif self.m_UpdateInfo.complete_type == 1 then
			 self.m_Flags[key] = true
			-- self:CtrlCC2GSFinishGuidance({[1] = key})
		elseif self.m_UpdateInfo.complete_type == 2 then	
			if self.m_Flags[key] == nil then
				self.m_Flags[key] = false	
			end
		elseif self.m_UpdateInfo.complete_type == 3 then	
			--什么也不做
		end	
		self.m_UpdateInfo.continue_condition = nil
		
		self:SetGuideKey(nil) --清空正在指引键

		local oView = CGuideView:GetView()
		local iMax = #data.guidedata[self.m_UpdateInfo.guide_type].guide_list
		if self.m_UpdateInfo.cur_idx >= iMax then
			if oView then
				oView:CloseView()
			end			
			if self.m_UpdateInfo.complete_type ~= 2 and self.m_UpdateInfo.complete_type ~= 3 then
				print("已完成引导"..self.m_UpdateInfo.guide_type)
				self.m_Flags[self.m_UpdateInfo.guide_type] = true
				self:CtrlCC2GSFinishGuidance({[1] = self.m_UpdateInfo.guide_type})
				self.m_UpdateInfo.guide_type = nil
				self.m_UpdateInfo.cur_idx = nil
				self:TriggerAll()
			end
		else
			if oView then
				oView:DelayClose()
			end
			self.m_UpdateInfo.cur_idx = self.m_UpdateInfo.cur_idx + 1
		end
	end
end

function CGuideCtrl.View2WorldPos(self, x, y)
	local oCam = g_CameraCtrl:GetUICamera()
	return oCam:ViewportToWorldPoint(Vector3.New(x, y, 0))
end

function CGuideCtrl.SetGuideKey(self, key)
	if self.m_UpdateInfo.after_process then
		self:CallGuideFunc(self.m_UpdateInfo.after_process.func_name, unpack(self.m_UpdateInfo.after_process.args))
		self.m_UpdateInfo.after_process = nil
	end
	if self.m_UpdateInfo.after_mask then
		self:CallGuideFunc(self.m_UpdateInfo.after_mask.func_name, unpack(self.m_UpdateInfo.after_mask.args))
		self.m_UpdateInfo.after_mask = nil
	end
	self.m_UpdateInfo.guide_key = key
end

function CGuideCtrl.GetGuidePos(self, dGuideEffect)
	local vPos
	if dGuideEffect.ui_key and dGuideEffect.ui_key ~= "" then
		local oUI = self:GetGuideUI(dGuideEffect.ui_key)
		vPos = oUI:GetCenterPos()
		if dGuideEffect.near_pos then
			local rootw, rooth = UITools.GetRootSize()
			vPos.x = vPos.x + dGuideEffect.near_pos.x * rootw 
			vPos.y = vPos.y + dGuideEffect.near_pos.y * rooth
		end
	else
		local v3= Vector3.New(dGuideEffect.fixed_pos.x+0.5,  dGuideEffect.fixed_pos.y+0.5, 0)
		vPos = g_CameraCtrl:GetUICamera():ViewportToWorldPoint(v3)
	end
	return vPos
end

function CGuideCtrl.ProcessText(self, dGuideEffect)
	if not dGuideEffect.text_list then
		return
	end
	local function process(match)
		local s = string.gsub(match, "[<>]", "")
		if s == "name" then
			return g_AttrCtrl.name
		else
			return s
		end
	end
	for i, text in ipairs(dGuideEffect.text_list) do
		dGuideEffect.text_list[i] = string.gsub(text, "%b<>", process)
	end
end

function CGuideCtrl.IsNeedGuide(self, key)	
	if not self.m_Flags then
		return false
	end
	return self.m_Flags[key] == nil
end

function CGuideCtrl.ShowWrongTips(self)
	local cb1 = function ()
		local list = {
			[[你点错地方了，本喵有点忧伤(╯﹏╰)]],
			[[你调皮了哟，点错地方了~喵~(￣︶￣)↗]],
			[[你点的地方不对劲哈~喵~(。_。)]],
			[[乖，点那里哈。(￣︶￣)↗ ]],
			[[别点那里，别点那里~喵~o(*////▽////*)q]],
		}
		g_NotifyCtrl:FloatMsg(table.randomvalue(list))
	end
	local cb2 = function (isClickUI, offsetPos)
		if isClickUI then
			local oUI = self.m_EffecTipsTable.m_UI
			if oUI then
				oUI:AddEffect("round2", nil, offsetPos)				
			end			
		else
			local oView = CGuideView:GetView()
			if oView and oView.m_FocusBox and oView.m_FocusBox.m_FocusSpr then
				oView.m_FocusBox.m_FocusSpr:AddEffect("round2", nil, offsetPos)
			end
		end
	end
	if self.m_EffecTipsTable and self.m_EffecTipsTable.m_Enum == 1 then		
		cb2(self.m_EffecTipsTable.m_Pos == nil , self.m_EffecTipsTable.m_OffSetPos)
	elseif self.m_EffecTipsTable and self.m_EffecTipsTable.m_Enum == 2 then
		cb1()
		cb2(self.m_EffecTipsTable.m_Pos == nil, self.m_EffecTipsTable.m_OffSetPos)
	else
		cb1()
	end

	self.m_ClickWrongCnt = self.m_ClickWrongCnt + 1
	if self.m_ClickWrongCnt >= 3 then
		local oView = CGuideView:GetView()
		if oView then
			oView:SetJumpBtnActive(true)
		end
	end
end

function CGuideCtrl.CallGuideFunc(self, sFuncName, ...)
	if sFuncName then
		local f = data.guidedata.FuncMap[sFuncName]
		if f then
			return f(...)
		end
	end
end

function CGuideCtrl.OnSwipe(self, vSwipePos)
	for key, func in pairs(self.m_SwipeCancel) do
		if func(vSwipePos) == true then
			self.m_SwipeCancel[key] = nil
		end
	end
end

function CGuideCtrl.StartGuide(self, dGuideInfo)
	if not self.m_Flags or not self.m_UpdateInfo or not self.m_UpdateInfo.guide_type then
		return
	end	

	--必须存在的ui
	if dGuideInfo.necessary_ui_list then
		for i, key in ipairs(dGuideInfo.necessary_ui_list) do
			local oUI = self:GetGuideUI(key)
			if not oUI or not oUI:GetActiveHierarchy() then		
				self:GuideLog(" StartGuide  step 1   " , oUI, key)					
				return
			end
		end
	end
	local oView = CGuideView:GetView()
	if dGuideInfo.need_guide_view == false then
		if oView then
			CGuideView:CloseView()
		end
	else
		if oView then
			oView:StopDelayClose()
			oView:SetActive(true)
			oView:ResetView()
			oView.m_ContinueLabel:SetActive(dGuideInfo.click_continue and dGuideInfo.force_hide_continue_label~=true)
		else
			CGuideView:ShowView()
			return
		end

	end
	--执行下一个引导，把引导遮罩界面关闭
	CGuideMaskView:CloseView()

	self:SetGuideKey(dGuideInfo.guide_key)
	printc("执行指引",dGuideInfo.guide_key, self.m_UpdateInfo.cur_idx)
	self.m_IsGuide = true
	if dGuideInfo.pass then --只要执行到了这个指引，就不再执行
		if self.m_UpdateInfo.complete_type == 0 then
			self.m_Flags[dGuideInfo.guide_key] = true
			self:CtrlCC2GSFinishGuidance({[1] = dGuideInfo.guide_key})
		end
		self.m_Flags[dGuideInfo.guide_key] = true
		local iMax = #data.guidedata[self.m_UpdateInfo.guide_type].guide_list
		if self.m_UpdateInfo.cur_idx >= iMax then
			self.m_Flags[self.m_UpdateInfo.guide_type] = true
			self:CtrlCC2GSFinishGuidance({[1] = self.m_UpdateInfo.guide_type})
		end
	end

	--执行到这里，则完成后面的步骤
	if dGuideInfo.end_pass_guide then 
		self.m_Flags[self.m_UpdateInfo.guide_type] = true
		self:CtrlCC2GSFinishGuidance({[1] = self.m_UpdateInfo.guide_type})
	end
	
	if dGuideInfo.before_process then
		self:CallGuideFunc(dGuideInfo.before_process.func_name, unpack(dGuideInfo.before_process.args))
	end
	if not self.m_UpdateInfo.guide_type then
		return
	end	
	self.m_UpdateInfo.after_process = dGuideInfo.after_process
	self.m_UpdateInfo.after_mask = dGuideInfo.after_mask
	if not self.m_UpdateInfo.after_mask then
		self.m_UpdateInfo.after_mask = self.m_DefaultAfterMask
	end

	if dGuideInfo.stop_walk and dGuideInfo.stop_walk == true then
		self:StopHeroWalk()
	end

	local dGuideType = data.guidedata[self.m_UpdateInfo.guide_type]
	self:CallGuideFunc(dGuideType.before_guide)

	self.m_EffecTipsTable = {}
	self.m_EffecTipsTable.m_Enum = 0
	self.m_EffecTipsTable.m_OffSetPos = Vector2.New(0, 0)
	self.m_ClickWrongCnt = 0
	for i, dGuideEffect in ipairs(dGuideInfo.effect_list) do
		self:ProcessText(dGuideEffect)
		if dGuideEffect.effect_type == "func" then
			local func = data.guidedata.FuncMap[dGuideEffect.funcname]
			func(self)
		elseif dGuideEffect.effect_type == "click_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			--战斗技能选中界面特殊处理
			if string.find(dGuideEffect.ui_key, "war_skill_box") then
				if oUI.m_IconSpr then
					local lPos = oUI.m_IconSpr:GetLocalPos()
					oUI:AddEffect(dGuideEffect.ui_effect, nil, Vector2.New(0, lPos.y))
				end			
			else
				local off
				if dGuideEffect.near_pos then
					local rootw, rooth = UITools.GetRootSize()
					local x = dGuideEffect.near_pos.x * rootw
					local y = dGuideEffect.near_pos.y * rooth
					off = oUI:AddEffect(dGuideEffect.ui_effect, nil, Vector2.New(x, y))
				elseif dGuideEffect.offset_pos then
					self.m_EffecTipsTable.m_OffSetPos = Vector2.New(dGuideEffect.offset_pos.x, dGuideEffect.offset_pos.y)					
					off = oUI:AddEffect(dGuideEffect.ui_effect, nil, Vector2.New(dGuideEffect.offset_pos.x, dGuideEffect.offset_pos.y))
				else
					off = oUI:AddEffect(dGuideEffect.ui_effect)
				end

				--反转处理
				if string.find(dGuideEffect.ui_key, "close_wh_result_rt") or string.find(dGuideEffect.ui_key, "operate_arena_btn")
					or string.find(dGuideEffect.ui_key, "mainmenu_minimap_btn") or string.find(dGuideEffect.ui_key, "close_wl_result_rt") 
					or string.find(dGuideEffect.ui_key, "partner_gain_close_btn") 
					or string.find(dGuideEffect.ui_key, "drawcard_close_rt") then
					local cb = function ()
						if not Utils.IsNil(off) then
							off:SetLocalScale(Vector3.New(-1, 1,1))
						end						
					end
					Utils.AddTimer(cb, 0, 0)
				end 

			end
			local cbFunc
			if dGuideEffect.click_ui_cb then
				cbFunc = data.guidedata.FuncMap[dGuideEffect.click_ui_cb]
			end			

			self.m_EffecTipsTable.m_Enum = dGuideEffect.effect_tips_enum or 1
			self.m_EffecTipsTable.m_UI = oUI


			oView:ClickGuide(oUI, cbFunc, dGuideEffect.aplha, dGuideEffect.owner_view_name)
		elseif dGuideEffect.effect_type == "focus_ui" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			local oUIRoot = UITools.GetUIRoot()
			local rootw, rooth = UITools.GetRootSize()
			local vLocalPos = UITools.GetUIRootObj(false):InverseTransformPoint(oUI:GetCenterPos())
			local x = vLocalPos.x / rootw + 0.5
			local y = vLocalPos.y / rooth + 0.5
			if dGuideEffect.near_pos then
				x = x + dGuideEffect.near_pos.x
				y = y + dGuideEffect.near_pos.y
			end
			local w = dGuideEffect.w or (oUI:GetWidth()*dGuideEffect.focus_ui_size/2/rootw)
			local h = dGuideEffect.h or (oUI:GetHeight()*dGuideEffect.focus_ui_size/2/rooth)			
			if dGuideEffect.aplha then
				oView:SetCoverAplha(dGuideEffect.aplha)
			end
			self.m_EffecTipsTable.m_Enum = dGuideEffect.effect_tips_enum or 0
			self.m_EffecTipsTable.m_UI = oUI
			local mode = dGuideEffect.mode or 1
			local pos = dGuideEffect.effect_offset_pos or {x=0, y=0}
			oView:SetFocus(x, y, w, h, dGuideEffect.ui_effect, dGuideInfo.click_continue, dGuideInfo.aplha, mode, pos)			
		elseif dGuideEffect.effect_type == "focus_common" then
			oView:SetFocus(dGuideEffect.x, dGuideEffect.y, dGuideEffect.w, dGuideEffect.h, dGuideEffect.ui_effect, dGuideInfo.click_continue)
		elseif dGuideEffect.effect_type == "focus_pos" then
			local vPos = self:CallGuideFunc(dGuideEffect.pos_func)
			if vPos then
				self.m_EffecTipsTable.m_Enum = dGuideEffect.effect_tips_enum or 1
				self.m_EffecTipsTable.m_Pos = vPos
				oView:SetFocus(vPos.x, vPos.y, dGuideEffect.w, dGuideEffect.h, dGuideEffect.ui_effect, dGuideInfo.click_continue, dGuideEffect.aplha)
			end			
		elseif dGuideEffect.effect_type == "dlg" then
			local vPos = self:GetGuidePos(dGuideEffect)	
			local d = dGuideEffect
			oView:DlgGuide(d.text_list, d.play_tween, d.dlg_sprite, vPos, d.next_tip, d.dlg_tips_sprite, d.dlg_is_left, d.aplha)
		elseif dGuideEffect.effect_type == "bigdlg" then
			local vPos = self:GetGuidePos(dGuideEffect)	
			local d = dGuideEffect
			oView:BigDlgGuide(d.text_list, d.play_tween, vPos, d.next_tip, d.dlg_is_left, d.dlg_is_flip, d.aplha)
		elseif dGuideEffect.effect_type == "textdlg" then
			local vPos = self:GetGuidePos(dGuideEffect)	
			local d = dGuideEffect
			oView:TextDlgGuide(d.text_list, d.play_tween, vPos, d.next_tip, d.dlg_is_left, d.aplha)			
		elseif dGuideEffect.effect_type == "texture" then
			local vPos = self:GetGuidePos(dGuideEffect)
			oView:TextureGuide(dGuideEffect.texture_name, dGuideEffect.play_tween, dGuideEffect.flip_y, vPos)
		elseif dGuideEffect.effect_type == "open" then
			local oUI = self:GetGuideUI(dGuideEffect.ui_key)
			oView:OpenEffect(dGuideEffect.sprite_name, dGuideEffect.open_text, oUI)
		elseif dGuideEffect.effect_type == "spine" then	
			local d = dGuideEffect
			local guide_voice_list = {[1]=d.guide_voice_list_1,[2]=d.guide_voice_list_2}
			oView:SpineGuide(d.spine_left_shape, d.spine_right_shape, d.text_list, d.side_list, d.aplha, d.spine_left_motion, d.spine_right_motion, guide_voice_list)			
		elseif dGuideEffect.effect_type == "none" then
			oView:SetNone()		
		elseif dGuideEffect.effect_type == "hide_click_event" then
			oView:SetEventWidgetActive(false)	
		elseif dGuideEffect.effect_type == "hide_focus_box" then
			oView:SetFocusBoxActive(false)				
		elseif dGuideEffect.effect_type == "teach_guide" then
			printc("CTeachGuideView已弃用")
		end
	end
	if oView then
		oView:StopClickContineuTimer()
	end

	self:CheckTeamStateInGuide(dGuideInfo.leave_team)

	if dGuideInfo.continue_condition then
		self.m_UpdateInfo.continue_condition = dGuideInfo.continue_condition
	else
		if oView then
			oView.m_ClickContinue = dGuideInfo.click_continue
			oView:StartClickContineuTimer(dGuideInfo.click_continue_time, dGuideInfo.click_continue and dGuideInfo.force_hide_continue_label~=true)
		end		
	end
end

function CGuideCtrl.IsGuide(self)
	return self.m_IsGuide
end

function CGuideCtrl.IsInTargetGuide(self, key, step)
	local b = false 
	if self:IsGuide() and self.m_UpdateInfo and key == self.m_UpdateInfo.guide_type then
		b = true
		if step then
			return self.m_UpdateInfo.cur_idx == step
		end
	end
	return b
end

--特殊效果代码写
function CGuideCtrl.WarPrepareGuide(self)
	local oView = CGuideView:GetView()
	oView:SwipeGuide(true)
	oView:SetCenterText("滑动调整镜头")
	self.m_SwipeCancel["War_prepare"] = function(vSwipePos) 
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
			return true
		else
			return false
		end
	end
end

function CGuideCtrl.ReqCustomGuideFinish(self, key)
	if not self.m_Flags then
		self:CtrlCC2GSFinishGuidance({[1] = key})
	elseif self.m_Flags[key] ~= true then
		self:CtrlCC2GSFinishGuidance({[1] = key})
		self.m_Flags[key] = true
	end	
end

function CGuideCtrl.IsCustomGuideFinishByKey(self, key)
	if not self.m_Flags then
		return false
	end
	return self.m_Flags[key] ~= nil
end

function CGuideCtrl.IsCompleteTipsGuideByKey(self, key)
	if not self.m_Flags then
		return false
	end	
	return self.m_Flags[key] == true
end

function CGuideCtrl.IsDongTargetGuide(self, key)
	local b = false
	if CGuideView:GetView() and self.m_UpdateInfo.guide_type == key then
		b = true
	end
	return b 
end

function CGuideCtrl.ShowSoloPKGuide(self)
	printc("CTeachGuideView已弃用")
end

function CGuideCtrl.StarDelayClose(self)
	local function cb()		
		local oView = CGuideView:GetView()
		if oView then
			oView:OnGuideUIClick()
		end
	end
	self.m_DelayCloseTimer = Utils.AddTimer(cb, 0, 5)
end

function CGuideCtrl.StopDelayClose(self)
	if self.m_DelayCloseTimer then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
end

function CGuideCtrl.AddGuideUIEffect(self, UIKey, effect, bTipsGuide)
	if UIKey == "house_walker_1001" then
		if g_HouseCtrl:GetCurHouse() then
			local oHousePartner = g_HouseCtrl:GetCurHouse():GetPartner(1001)
			if oHousePartner then
				oHousePartner:SetGuideTipsHud(true)
			end
		end
		return
	end

	local oBox = self:GetGuideUI(UIKey)
	if oBox and effect ~= "" then
		local eff = oBox:GetdEffect(effect)
		local p = Vector2.New(0,0)
		if not eff then		
			if bTipsGuide then						
				local pos = data.guidedata.Tips_Guide_UI_NearPos[UIKey]
				if pos then
					p.x = pos.x 
					p.y = pos.y			
				end		
			else
				if string.find(UIKey, "war_skill_box") then
					if oBox.m_IconSpr then
						local lPos = oBox.m_IconSpr:GetLocalPos()					
						p.y = lPos.y
						--round的特效要延时一帧设置（原因未知）
						eff = oBox:AddEffect( effect, nil, p)	
						local cb = function ()					
							if not Utils.IsNil(eff) then
								eff:SetLocalPos(p)
							end
						end
						Utils.AddTimer(cb, 0, 0)
						return
					end
				end
			end
			eff = oBox:AddEffect(effect, nil, p)			
		else
			if bTipsGuide then						
				local pos = data.guidedata.Tips_Guide_UI_NearPos[UIKey]
				if pos then
					p.x = pos.x 
					p.y = pos.y			
				end	
			end
			eff:SetLocalPos(p)
		end
	end
end

function CGuideCtrl.DelGuideUIEffect(self, UIKey, effect)
	if UIKey == "house_walker_1001" then
		if g_HouseCtrl:GetCurHouse() then
			local oHousePartner = g_HouseCtrl:GetCurHouse():GetPartner(1001)
			if oHousePartner then
				oHousePartner:SetGuideTipsHud(false)
			end
		end
		return
	end
	local oBox = self:GetGuideUI(UIKey)
	if oBox then
		oBox:DelEffect(effect)
	end
end

--重建检测引导中，需要显示的引导
function CGuideCtrl.ReContinuGuide(self)
	if not self.m_Flags then
		return
	end	
	local iStart 
	local sGuideType = self.m_UpdateInfo.guide_type
	if not sGuideType then
		return 
	end
	local sGuideData = data.guidedata[sGuideType]	
	if not sGuideData then
		return 
	end
	local lGuides = sGuideData.guide_list
	if next(lGuides) then
		for i = 1, #lGuides do
			local v = lGuides[i]
			v["guide_key"] = sGuideType.."_"..tostring(i)
			if self.m_Flags[v.guide_key] == false then
				self.m_Flags[v.guide_key] = nil
				if not iStart then
					iStart = i		
				end 
			end
		end
	end
	self.m_UpdateInfo.cur_idx = iStart or self.m_UpdateInfo.cur_idx
end

--延时点击按钮
function CGuideCtrl.DelayClick(self, UIKey, time)
	if self.m_DelayClickTimer then
		Utils.DelTimer(self.m_DelayClickTimer)
		self.m_DelayClickTimer = nil
	end
	local oBox = self:GetGuideUI(UIKey)
	if oBox then
		local cb = function ( )
			if not Utils.IsNil(oBox) then
				oBox:Notify(enum.UIEvent["click"])
				oBox:DelEffect("Finger")
				self:Continue()
			end
		end
		self.m_DelayClickTimer = Utils.AddTimer(cb, 0, time)
	end
end

--延时停止点击按钮
function CGuideCtrl.StopDelayClick(self, UIKey)
	if self.m_DelayClickTimer then
		Utils.DelTimer(self.m_DelayClickTimer)
		self.m_DelayClickTimer = nil
	end
end

function CGuideCtrl.War3StepThreeBefore(self)
	local oView = CGuideView:GetView()
	if oView then
		oView.m_Contanier:SetActive(false)
	end
	local cb = function ()
		g_WarTouchCtrl:SetLock(false)
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
		if self.m_War3GuideTimer then
			Utils.DelTimer(self.m_War3GuideTimer)
			self.m_War3GuideTimer = nil			
		end
		local wrap = function ()
			self.m_War3RemainTime = g_WarOrderCtrl:GetRemainTime()
			if self.m_War3GuideAnyTouchTime == nil and self.m_War3RemainTime then
				self.m_War3GuideAnyTouchTime = self.m_War3RemainTime
			end
			local oView = CGuideView:GetView()
			if not Utils.IsNil(oView) then
				if self.m_War3RemainTime == nil then
					return false
				elseif self.m_War3GuideAnyTouchInGuide == false then
					if oView.m_Contanier:GetActive() ~= true then
						oView.m_Contanier:SetActive(true)
						local skill_box_1 = self:GetGuideUI("war_skill_box1")
						if skill_box_1 and skill_box_1:GetSelected() then
							self:AddGuideUIEffect("war_skill_box1", "round")
						end
						local skill_box_2 = self:GetGuideUI("war_skill_box2")
						if skill_box_2 and skill_box_2:GetSelected() then
							self:AddGuideUIEffect("war_skill_box2", "round")
						end	
					end				
					return true					
				elseif self.m_War3RemainTime <= 20 then
					self:DelGuideUIEffect("war_skill_box1", "round")
					self:DelGuideUIEffect("war_skill_box2", "round")
					self:AddGuideUIEffect("war_order_all", "Finger", true)
					netwar.C2GSWarStart(g_WarCtrl:GetWarID())
					oView.m_Contanier:SetActive(true)
					--oView.m_DlgBox:SetLocalScale(Vector3.New(1,1,1))
					return false
				else
					return true
				end		
			else
				return false
			end	
		end
		self.m_War3GuideTimer = Utils.AddTimer(wrap, 0.5, 0)
	end
	Utils.AddTimer(cb, 0, 0)
end

function CGuideCtrl.War3StepThreeAfter(self)
	printtrace()
	if self.m_War3GuideTimer then
		Utils.DelTimer(self.m_War3GuideTimer)
		self.m_War3GuideTimer = nil			
	end
	self:DelGuideUIEffect("war_order_all", "Finger")
end

function CGuideCtrl.War3StepFourBefore(self)	
	local oView = CGuideView:GetView()
	if oView and oView.m_Contanier then
		oView.m_Contanier:SetActive(true)
	end
	self.m_War3CurWid = g_WarOrderCtrl:GetOrderWid()	
end

function CGuideCtrl.War3StepThree0Continue(self)	
	if (self.m_War3GuideAnyTouchTime and self.m_War3RemainTime and (self.m_War3GuideAnyTouchTime - self.m_War3RemainTime > 3) ) then		
		if self.m_War3GuideAnyTouchInGuide == nil then
			self.m_War3GuideAnyTouchInGuide = false
		end
	end	
	if self.m_War3GuideAnyTouchInGuide == true then
		local oView = CGuideView:GetView()
		if oView and oView.m_DlgBox then
			oView.m_DlgBox:SetLocalScale(Vector3.New(0.01,0.01,0.01))
		end
	end
	return self.m_War3GuideAnyTouchInGuide == true or g_WarCtrl.m_ProtoBout > 1 or (self.m_War3RemainTime ~= nil and self.m_War3RemainTime < 21)
end

function CGuideCtrl.War3StepFourContinue(self)	
	return self.m_War3CurWid ~= g_WarOrderCtrl:GetOrderWid()
end

--提示型引导,登陆初始化
function CGuideCtrl.LoginTipsGuide(self)
	if not self.m_Flags then
		return
	end	
	local t = {}
	local del_table = table.copy(self.m_TipsGuideFlags)
	--先加载新的特效，在删除不需要的特效
	--self:ClearTipsGuideEffect()
	self.m_TipsGuideFlags = {}
	for k, v in pairs(self.m_Flags) do
		if string.find(k, "_0") then
			local guide_key = string.gsub(k, "_0", "")
			table.insert(t, guide_key)
		end
	end
	if #t > 0 then
		for i, v in ipairs(t) do
			if not self.m_Flags[v] then
				self.m_Flags[v] = false

				local guide_data = data.guidedata[v]
				if guide_data and guide_data.guide_list then
					for j = 1, #guide_data.guide_list do
						local guide_key = v .. "_".. tostring(i)
						if self.m_Flags[guide_key] ~= true then
							self.m_Flags[guide_key] = false
						end
					end
				end
				--登陆时，触发引导
				self:StartTipsGuide(v)
			end
		end
	end


	--删除那些不需要的特效
	if del_table and next(del_table) then
		for k,v in pairs(del_table) do
			if k and self.m_TipsGuideFlags[k] == nil and table.count(v) > 0 then
				self:DelGuideUIEffect(k, v[1].ui_effect)
			end
		end
	end
	del_table = nil
end

function CGuideCtrl.StartTipsGuide(self, key)
	if not self.m_Flags then
		return
	end	
	if not key or self.m_Flags[key] == true then
		return
	end
	local isExit = false
	for i, v in ipairs(data.guidedata.Tips_Trigger) do
		if v == key then
			isExit = true
			break
		end
	end
	if isExit then		
		--请求服务器记录已经触发过的引导
		local trigger_key = key.."_".."0"
		if self.m_Flags[trigger_key] ~= true then
			self.m_Flags[trigger_key] = true
			self:CtrlCC2GSFinishGuidance({[1] = trigger_key})
		end
		local guideinfo = data.guidedata[key]
		if guideinfo and #guideinfo.guide_list > 0 then
			for i,v in ipairs(guideinfo.guide_list) do
				local guide_key = key.."_"..tostring(i)
				local ui_key = v.necessary_ui
				if self.m_Flags[guide_key] ~= true then
					self.m_Flags[guide_key] = false
					self.m_TipsGuideFlags[ui_key] = self.m_TipsGuideFlags[ui_key] or {}
					local temp_open_priority = guideinfo.open_priority or 0
					local guide_step_info = {step = i, max_step = #guideinfo.guide_list, guide_type = key,
						ui_effect = v.ui_effect, open_id = v.open_id, condition_pass = v.condition_pass, open_priority = temp_open_priority,
						 showFinishForward = v.showFinishForward}

					local inExit = false
					for _i, _v in ipairs(self.m_TipsGuideFlags[ui_key]) do
						if _v.guide_type == guide_step_info.guide_type then
							inExit = true
						end
					end
					if v.func_process then
						self:CallGuideFunc(v.func_process.func_name, unpack(v.func_process.args))
					end
					if not inExit then
						table.insert(self.m_TipsGuideFlags[ui_key] , guide_step_info)		
						--冒险的特效，通过界面刷新特效
						if ui_key ~= "schedule_allday_go_btn" then
							self:AddGuideUIEffect(ui_key, v.ui_effect, true)								
						end								
					end																
				end
			end
		end		
		--printy("StartTipsGuide ......... ")
		--table.print(self.m_TipsGuideFlags)
	end
end

function CGuideCtrl.LoadTipsGuideEffect(self, uiList)
	if next(uiList) then
		for i, v in ipairs(uiList) do
			local oBox = self:GetGuideUI(v)
			if oBox then
				oBox:ClearEffect()
			end
			if self.m_TipsGuideFlags[v] and #self.m_TipsGuideFlags[v] > 0 then
				local ui_effect = self.m_TipsGuideFlags[v][1].ui_effect
				self:AddGuideUIEffect(v, ui_effect, true)
				if self.m_TipsGuideFlags[v][1].showFinishForward then
					self:LoadReqForwardTipsGuide({{key=v,type=self.m_TipsGuideFlags[v][1].guide_type}})
				end
			end
		end
	end
end

function CGuideCtrl.ClearTipsGuideEffect(self)
	if not next(self.m_TipsGuideFlags) then
		return
	end
	for k, v in pairs(self.m_TipsGuideFlags) do
		if table.count(v) > 0 then
			self:DelGuideUIEffect(k, v[1].ui_effect)
		end
	end
	self.m_TipsGuideFlags = {}
end

--ReqForwardTipsGuideFinish 类似
function CGuideCtrl.ReqTipsGuideFinish(self, key, open_id, finish)
	if not self.m_Flags then
		return
	end	
	local guide_type 
	local key_pool = self.m_TipsGuideFlags[key]
	if key_pool and #key_pool > 0 then
		if #key_pool > 1 then
			table.sort(key_pool, function (a, b)
				return a.open_priority > b.open_priority
			end)
		end
		
		local del_info = {} 

		for i, v in ipairs(key_pool) do		
			if v.open_id == open_id and open_id ~= nil then
				del_info.idx = i	
				del_info.info = v		
				break
			end
		end

		del_info.idx = del_info.idx or 1		
		del_info.info = del_info.info or key_pool[1]

		local guide_key = del_info.info.guide_type .."_".. tostring(del_info.info.step)				
		guide_type = del_info.info.guide_type

		if del_info.info.condition_pass ~= true or finish == true then
			table.remove(key_pool, del_info.idx)				
		end

		--如果引导需要条件就关闭，则不会再点击的时候完成引导
		if del_info.info.condition_pass ~= true or finish == true then
			self:DelGuideUIEffect(key, del_info.info.ui_effect)
			self.m_Flags[guide_key] = true
			self:CtrlCC2GSFinishGuidance({[1] = guide_key})
			if del_info.info.step == del_info.info.max_step then
				self.m_Flags[del_info.info.guide_type] = true
				self:CtrlCC2GSFinishGuidance({[1] = del_info.info.guide_type})				
			end					
		end					
		if #key_pool > 0 then
			self:AddGuideUIEffect(key, key_pool[1].ui_effect)
		else
			self.m_TipsGuideFlags[key] = nil
		end
	end
	return guide_type
end

-- ReqTipsGuideFinish 类似(会调用ReqTipsGuideFinish完成前面步骤的引导) --支线任务使用
function CGuideCtrl.ReqForwardTipsGuideFinish(self, key)
if not self.m_Flags then
		return
	end	
	local guide_type 
	local key_pool = self.m_TipsGuideFlags[key]
	if key_pool and #key_pool > 0 then
		if #key_pool > 1 then
			table.sort(key_pool, function (a, b)
				return a.open_priority > b.open_priority
			end)
		end
		
		local del_info = {} 
		del_info.idx = del_info.idx or 1		
		del_info.info = del_info.info or key_pool[1]

		local guide_key = del_info.info.guide_type .."_".. tostring(del_info.info.step)				
		guide_type = del_info.info.guide_type

		if del_info.info.condition_pass ~= true or finish == true then
			table.remove(key_pool, del_info.idx)				
		end

		--完成当前步骤
		self:CtrlCC2GSFinishGuidance({[1] = guide_key})

		--完成之前步骤的引导
		local guidedata = data.guidedata[del_info.info.guide_type]
		if del_info.info.step > 1 and guidedata then
			for j = 1, del_info.info.step - 1 do
				local key = del_info.info.guide_type .."_".. tostring(j)
				if self.m_Flags[key] ~= true and guidedata.guide_list[j] then
					self:ReqTipsGuideFinish(guidedata.guide_list[j].necessary_ui)
				end
			end
		end	

		--完成此引导
		if del_info.info.step == del_info.info.max_step then
			self.m_Flags[del_info.info.guide_type] = true
			self:CtrlCC2GSFinishGuidance({[1] = del_info.info.guide_type})				
		end
			
		if #key_pool > 0 then
			self:AddGuideUIEffect(key, key_pool[1].ui_effect)
		else
			self.m_TipsGuideFlags[key] = nil
		end
	end
end

--显示特效的时候，就完成该引导前面的tips引导
function CGuideCtrl.LoadReqForwardTipsGuide(self, d)
	if next(d) then
		for k, v in pairs(d) do
			local key = v.key
			local guide_type = v.type
			local t = self.m_TipsGuideFlags[key]
			if t then
				local step = t[1].step
				for _k, _v in pairs(self.m_TipsGuideFlags) do					
					if _v[1].guide_type == guide_type and step > _v[1].step then
						self:ReqTipsGuideFinish(_k)
					end
				end
			end
		end
	end
end

--检测王者契约提示引导(累计获得第二个时，出现该提示)
function CGuideCtrl.CheckWZQYTipsGuide(self, count)
	-- if not self.m_Flags then
	-- 	return
	-- end	
	-- if self.m_Flags["Tips_WZQY"] == true then
	-- 	return
	-- end
	-- local trigger = false
	-- if count >= 2 then
	-- 	trigger = true
	-- else
	-- 	local guide_chage_key = "Tips_WZQY".."1" 
	-- 	if self.m_Flags[guide_chage_key] then
	-- 		trigger = true
	-- 	else
	-- 		self.m_Flags[guide_chage_key] = true
	-- 		self:CtrlCC2GSFinishGuidance({[1] = guide_chage_key})
	-- 	end
	-- end
	-- if trigger then
	-- 	self.m_Flags["get_two_wzqy_open"] = true
	-- 	self:CtrlCC2GSFinishGuidance({"get_two_wzqy_open"})
	-- 	self:TriggerCheck("view")
	-- end
end

function CGuideCtrl.IsInTipsGuide(self, key, open_id)
	local b
	for k, v in pairs(self.m_TipsGuideFlags) do
		if k == key then										
			if #v > 0 then
				b = 0
				local open_priority = -1
				for _k, _v in ipairs(v) do
					if open_id ~= nil then
						if _v.open_id == open_id then
							return _v.open_id
						end
					else
						if open_priority < _v.open_priority then
							b = _v.open_id
							open_priority = _v.open_priority
						end		
					end			
				end							
			end
		end
	end
	return b
end

function CGuideCtrl.GetTipsGuideDataByOpenId(self, key, openId)
	local t = {}
	for k, v in pairs(self.m_TipsGuideFlags) do
		if k == key then
			for _i, _v in ipairs(v) do
				if _v.open_id == openId then
					t = _v
					return t
				end
			end 
		end
	end
	return t
end

--战斗引导4 特殊处理开始
function CGuideCtrl.TriggerCheckWarGuide(self)
	if not self.m_Flags then
		return
	end	
	if self.m_Flags["War4"] == true and self.m_Flags["War5"] == true then
		return
	end
	local warType = g_WarCtrl:GetWarType()
	if self.m_WarSpeedGuide == true or 
		warType == define.War.Type.Guide1 or 
		warType == define.War.Type.Guide2 or 
		warType == define.War.Type.Guide3 or
		warType == define.War.Type.Guide4 or
		self.m_ShowIngWarReplaceGuide or 
		self:IsInTargetGuide("warCommand") then		
		return
	end
	local b = false
	if not self.m_Flags["War4"] and not self:IsInTargetGuide("War5") then
		if self:GetGuideWar4Step() == 2 then
			b = true
		else
			self:StoptWar4StepOne()
			self:StoptWar4StepTwo()
			b = self:StartCheckGuideWar4()
			if b then
				self.m_War4WarId = g_WarCtrl:GetWarID()
			end	
		end
	end

	if b ~= true and g_WarCtrl:GetWarID() ~= self.m_War4WarId then
		self:StartCheckGuideWar5()
	end
end

function CGuideCtrl.StartCheckGuideWar4(self)	
	local b = false
	local isWar = g_WarCtrl:IsWar()
	local fightCnt = g_PartnerCtrl:GetFightPartnerCnt()
	local isJoinTeam = g_TeamCtrl:IsJoinTeam()
	local warType = g_WarCtrl:GetWarType()

	local function CheckWarType(type)
		local isPvp = false
		if type == define.War.Type.PVP or type == define.War.Type.Arena or type == define.War.Type.EqualArena
			or type == define.War.Type.Terrawar then
			isPvp = true
		end
		return isPvp
	end
	self:SetGuideWar4Step(0)
	local isExitSkillBox = true
	self.m_War4AutoSkillBox = {}
	self.m_War4AutoBoxSelectIdx = {}
	for i = 1, 5 do 
		local oUI = self:GetGuideUI(string.format("war_auto_skill_box%d", i))
		if oUI then
			table.insert(self.m_War4AutoSkillBox, oUI)
		else
			if i < 3 then
				isExitSkillBox = false
			end		
		end
	end
	if isWar == true and fightCnt >= 2 and not isJoinTeam and not CheckWarType(warType) and isExitSkillBox == true then
		self:SetGuideWar4Step(1)
		for i = 2, #self.m_War4AutoSkillBox do
			local oUI = self.m_War4AutoSkillBox[i]
			if oUI then
				local skillId = oUI.m_MagicID
				local magic = data.magicdata.DATA[skillId]
				--40402 是狸猫的生命转换
				if magic and magic.sp == 0 and skillId ~= 40402 then
					table.insert(self.m_War4AutoBoxSelectIdx, i)
				end
			end			
		end
	end
	b = self:StartWar4StepOne()
	return b
end

function CGuideCtrl.StoptWar4StepOne(self)
	if next(self.m_War4AutoSkillBox) then
		for k, v in pairs(self.m_War4AutoSkillBox) do
			if not Utils.IsNil(v) then
				self:DelGuideUIEffect(string.format("war_auto_skill_box%d", k), "round")
			end
		end		
	end
end

function CGuideCtrl.StartWar4StepOne(self)
	if next(self.m_War4AutoBoxSelectIdx) and CWarSelAutoView:GetView() == nil then
		for i = 1, #self.m_War4AutoBoxSelectIdx do
			local idx = self.m_War4AutoBoxSelectIdx[i]
			local oUI = self.m_War4AutoSkillBox[idx]
			if oUI then
				oUI:AddEffect("round")
				return true
			end			
			break			
		end
	end
end

function CGuideCtrl.StartWar4StepTwo(self)
	self:StoptWar4StepOne()
	self:AddGuideUIEffect(string.format("war_select_auto_skill_box%d", 2), "round")
	CGuideView:ShowView(function (oView)
	local guide_data = data.guidedata.War4.guide_list[2].effect_list
		if guide_data then			
			for i, v in ipairs(guide_data) do
				if v.effect_type == "dlg" then
					local vPos = self:GetGuidePos(v)	
					oView:DlgGuide(v.text_list, v.play_tween, v.dlg_sprite, vPos, v.next_tip, v.dlg_tips_sprite, v.dlg_is_left, v.aplha)
				elseif v.effect_type == "hide_click_event" then
					oView:SetEventWidgetActive(false)	
				elseif v.effect_type == "hide_focus_box" then
					oView:SetFocusBoxActive(false)						
				end
			end
		end
	end)
end

function CGuideCtrl.StoptWar4StepTwo(self)
	local oView = CGuideView:GetView()
	if oView then
		oView:CloseView()
	end
	self:DelGuideUIEffect(string.format("war_select_auto_skill_box%d", 2), "round")
end

function CGuideCtrl.SetGuideWar4Step(self, step)
	self.m_War4GuideStep = step
end

function CGuideCtrl.GetGuideWar4Step(self)
	return self.m_War4GuideStep 
end

function CGuideCtrl.ReqCustomGuideWar4Finish(self)
	if not self.m_Flags then
		return
	end	
	self:StoptWar4StepOne()
	self:StoptWar4StepTwo()
	self.m_Flags["War4"] = true
	self:SetGuideWar4Step(0)
	self.m_War4AutoSkillBox = {}
	self.m_War4AutoBoxSelectIdx = {}
	self:CtrlCC2GSFinishGuidance({"War4"})		
end

--战斗引导4 特殊处理结束

function CGuideCtrl.StartCheckGuideWar5(self)
	local b = false
	local isWar = g_WarCtrl:IsWar()
	local fightCnt = g_PartnerCtrl:GetFightPartnerCnt()
	local isJoinTeam = g_TeamCtrl:IsJoinTeam()
	local warType = g_WarCtrl:GetWarType()

	local function CheckWarType(type)
		local isPvp = false
		if type == define.War.Type.PVP or type == define.War.Type.Arena or type == define.War.Type.EqualArena
			or type == define.War.Type.Terrawar then
			isPvp = true
		end
		return isPvp
	end
	local enemyCnt = 0
	for i = 1, 3 do
		local oWarrior = WarTools.GetWarriorByCampPos(false, i)
		if oWarrior then
			enemyCnt = enemyCnt + 1
		end
	end
	
	local oUI = self:GetGuideUI("war_speed_tips_bg")
	if isWar == true and fightCnt >= 3 and enemyCnt >= 2 and not isJoinTeam and not CheckWarType(warType) 
		and oUI and oUI:GetActive() == true then
		b = true
		self:StartWar5StepOne()
	end

end

function CGuideCtrl.StartWar5StepOne(self)
	if not self:IsCustomGuideFinishByKey("War5") then
		self.m_War5JiHuo = true
		self:TriggerCheck("war")
	end
end

function CGuideCtrl.CheckWar5Guide(self, type)
	if self.m_War5JiHuo == true then
		if type == 1 then
			self.m_War5JiHuo = nil
			local oWarrior = WarTools.GetWarriorByCampPos(false, 1)		
			if oWarrior then
				oWarrior:SetGuideTips(false)
			end
			self.m_Flags["War5"] = true
			self:CtrlCC2GSFinishGuidance({"War5"})	
		end
	end
end

function CGuideCtrl.StopWar5Guide(self)
	if self:IsInTargetGuide("War5") then
		self:ResetUpdateInfo()
	end
end

--特殊检测，中途退出的指引
function CGuideCtrl.TriggerCacheGuide(self)
	if not self.m_Flags then
		return
	end
	if self.m_IsCheckLoginCacheGuide then
		return
	end

	-- printy(" >>>>>>>>>>>>>>>>>>> TriggerCacheGuide ", self:IsCustomGuideFinishByKey("Open_ZhaoMu") , self:IsCustomGuideFinishByKey("DrawCard"))
	-- table.print(self.m_Flags)

	self.m_IsCheckLoginCacheGuide = true

	local result
	self.m_ClearGuideTable = {}
	-- if not self:IsCustomGuideFinishByKey("welcome_one") then
	-- 	g_DialogueAniCtrl:InsetUnPlayList(self.m_WelcomeTable.welcome_one.id)
	-- 	result = "welcome_one"	

	if not g_GuideCtrl:IsCustomGuideFinishByKey("welcome_three_end") then	
		result = "welcome_three"
		
	elseif self:IsCustomGuideFinishByKey("OpenChapterFuBenMainView") and not self:IsCustomGuideFinishByKey("OpenChapterDialogueView") then
		self:ResetTargetGuide({"OpenChapterFuBenMainView", "OpenChapterDialogueView"})		
		result = "OpenChapterDialogueView"				

	elseif self:IsCustomGuideFinishByKey("Partner_FWCD_One_MainMenu") and not self:IsCustomGuideFinishByKey("Partner_FWCD_One_PartnerMain") then
		if self:IsCustomGuideFinishByKey("Partner_FWCD_One_PartnerMain_4") then
			local cb = function(  )
				CPartnerMainView:ShowView( function (oView)
					oView:ShowEquipPage()	
				end)		
			end
			Utils.AddTimer(cb, 0, 1)			
		else
			self:ResetTargetGuide({"Partner_FWCD_One_MainMenu", "Partner_FWCD_One_PartnerMain"})	
		end	
		result = "Partner_FWCD_Onen"

	elseif self:IsCustomGuideFinishByKey("Partner_FWQH_MainMenu") and not self:IsCustomGuideFinishByKey("Partner_FWQH_PartnerMain") then
		self:ResetTargetGuide({"Partner_FWQH_MainMenu", "Partner_FWQH_PartnerMain"})		
		result = "Partner_FWQH_PartnerMain"		

	elseif self:IsCustomGuideFinishByKey("Open_ZhaoMu_2") and not self:IsCustomGuideFinishByKey("Open_ZhaoMu") then
		self:ResetTargetGuide({"Open_ZhaoMu"})
		self.m_Flags["Open_ZhaoMu_1"] = true
		result = "Open_ZhaoMu"		

	elseif self:IsCustomGuideFinishByKey("Open_ZhaoMu") and not self:IsCustomGuideFinishByKey("DrawCard") then
		self:ResetTargetGuide({"DrawCard"})
		CPartnerHireView:ShowView()
		result = "DrawCard"

	elseif self:IsCustomGuideFinishByKey("DrawCardLineUp_MainMenu") and not self:IsCustomGuideFinishByKey("DrawCardLineUp_PartnerMain") then
		self:ResetTargetGuide({"DrawCardLineUp_PartnerMain"})
		CPartnerHireView:ShowView()
		result = "DrawCardLineUp_PartnerMain"

	elseif self:IsCustomGuideFinishByKey("DrawCardLineUp_PartnerMain") and not self:IsCustomGuideFinishByKey("Partner_FWCD_Two_PartnerMain") then
		local cb = function(  )			
			CPartnerMainView:ShowView()		
		end
		Utils.AddTimer(cb, 0, 1)				
		self:ResetTargetGuide({"Partner_FWCD_Two_PartnerMain"})	
		result = "Partner_FWCD_Two"

	elseif self:IsCustomGuideFinishByKey("Open_ZhaoMu_Two") and not self:IsCustomGuideFinishByKey("DrawCard_Two") then
		self:ResetTargetGuide({"Open_ZhaoMu_Two", "DrawCard_Two"})
		result = "DrawCard_Two"

	elseif self:IsCustomGuideFinishByKey("DrawCardLineUp_Two_MainMenu") and not self:IsCustomGuideFinishByKey("DrawCardLineUp_Two_PartnerMain") then
		self:ResetTargetGuide({"DrawCardLineUp_Two_MainMenu", "DrawCardLineUp_Two_PartnerMain"})
		result = "DrawCardLineUp_Two_PartnerMain"

	elseif self:IsCustomGuideFinishByKey("Open_ZhaoMu_Three") and not self:IsCustomGuideFinishByKey("DrawCard_Three") then
		self:ResetTargetGuide({"Open_ZhaoMu_Three", "DrawCard_Three"})
		result = "DrawCard_Three"

	elseif self:IsCustomGuideFinishByKey("Partner_HBPY_MainMenu") and not self:IsCustomGuideFinishByKey("Partner_HPPY_PartnerMain") then
		self:ResetTargetGuide({"Partner_HBPY_MainMenu", "Partner_HPPY_PartnerMain"})
		result = "Partner_HPPY"

	elseif self:IsCustomGuideFinishByKey("Partner_HPPY_PartnerMain") and not self:IsCustomGuideFinishByKey("DrawCardLineUp_Three_PartnerMain") then
		self:ResetTargetGuide({"DrawCardLineUp_Three_PartnerMain"})
		local cb = function(  )
			local oView = CLoginRewardView:GetView()
			if oView then
				oView:CloseView()
			end
			local targetPartner = g_PartnerCtrl:GetPartnerByName("阿坊")
			if targetPartner then
				local parid = targetPartner:GetValue("parid")
				CPartnerMainView:ShowView( function (oView)
					oView.m_CurParID = parid
					oView:ShowMainPage()	
				end)		
			end
		end
		Utils.AddTimer(cb, 0, 1)
		result = "DrawCardLineUp_Three_PartnerMain"

	elseif self:IsCustomGuideFinishByKey("Open_Skill_Three") and not self:IsCustomGuideFinishByKey("Skill_Three") then
		self:ResetTargetGuide({"Open_Skill_Three", "Skill_Three"})
		result = "Skill_Three"

	elseif self:IsCustomGuideFinishByKey("Open_Skill_Four") and not self:IsCustomGuideFinishByKey("Open_Skill_Four") then
		self:ResetTargetGuide({"Open_Skill_Four"})
		result = "Open_Skill_Four"

	elseif self:IsCustomGuideFinishByKey("Open_Skill_Four") and not self:IsCustomGuideFinishByKey("Skill_Four") then
		self:ResetTargetGuide({"Open_Skill_Four", "Skill_Four"})
		result = "Skill_Four"		

	elseif self:IsCustomGuideFinishByKey("Open_Shimen") and self:IsCustomGuideFinishByKey("Dialogue_Shimen_1") and  not self:IsCustomGuideFinishByKey("Dialogue_Shimen") then
		self:ResetTargetGuide({"Dialogue_Shimen"})
		local cb = function ()
			g_OpenUICtrl:WalkToShiMen()
		end
		Utils.AddTimer(cb, 0, 1)
		result = "Dialogue_Shimen"		

	elseif self:IsCustomGuideFinishByKey("HuntPartnerSoulView_1") and not self:IsCustomGuideFinishByKey("HuntPartnerSoulView") then
		local cb = function ()
			local oView = CLoginRewardView:GetView()
			if oView then
				oView:CloseView()
			end
			g_OpenUICtrl:OpenHuntPartnerSoul()
		end
		Utils.AddTimer(cb, 0, 1)
		result = "HuntPartnerSoulView"	

	elseif self:IsCustomGuideFinishByKey("Open_Yuling") and not self:IsCustomGuideFinishByKey("Yuling_PartnerMain") then
		self:ResetTargetGuide({"Open_Yuling", "Yuling_PartnerMain"})
		result = "Open_Yuling"					
	end
	
	printc("result ", result)
	if next(self.m_ClearGuideTable) then
		self:CtrlC2GSClearGuidance(self.m_ClearGuideTable)
		self.m_ClearGuideTable = {}
	end

	if result then
		return true
	end
end

function CGuideCtrl.War3GuideTouchAnyway(self)
	--self:DelGuideUIEffect("war_skill_box1", "round")
	--self:DelGuideUIEffect("war_skill_box2", "round")	
	self.m_War3GuideAnyTouchTime = self.m_War3RemainTime
	if self.m_War3GuideAnyTouchInGuide == false then
		self.m_War3GuideAnyTouchInGuide = true
	end
end

--触发第一场战斗
function CGuideCtrl.TriggerWar1(self)		
	if not self.m_Flags then
		return
	end	
	local cb = function (  )
		if not g_MainMenuCtrl:GetMainmenuViewActive() then
			return true
		end
		if self.m_Flags["DrawCard"] == true and self.m_Flags["Complete_Task_10002"] ~= true then
			local oTask = g_TaskCtrl:GetTaskById(10001)
			if oTask then
				local mapId = g_MapCtrl:GetMapID()
				if mapId then
					g_TaskCtrl:ClickTaskLogic(oTask)
				else
					g_TaskCtrl:SetRecordLogic(oTask)
				end
			end
		end
		return false
	end
	Utils.AddTimer(cb, 0, 0)
end

function CGuideCtrl.TriggerCheckWarType(self, TriggerType)	
	local b = true
	if TriggerType == "war" then
		b = g_WarCtrl:IsWar()
	else
		b = not g_WarCtrl:IsWar()
	end
	return b
end

function CGuideCtrl.IsFinishAllHouseGuide(self)
	return (self:IsCustomGuideFinishByKey("Open_House") 
		and self:IsCustomGuideFinishByKey("HouseView") 
		and self:IsCustomGuideFinishByKey("HouseTwoView") 
		and self:IsCustomGuideFinishByKey("HouseExchangeView") 
		and self:IsCustomGuideFinishByKey("HouseTeaartView")		
		)
end

--清除引导的记录
function CGuideCtrl.ResetTargetGuide(self, keyTable)
	if not self.m_Flags then
		return
	end
	if not keyTable or not next(keyTable) then
		return
	end
	for i,v in ipairs(keyTable) do
		local d = data.guidedata[v]
		if d then
			for i, _v in ipairs(d.guide_list) do
				local guide_key = v.."_"..tostring(i)			
				if self.m_Flags[guide_key] ~= nil then
					self.m_Flags[guide_key] = nil				
					table.insert(self.m_ClearGuideTable, guide_key) 
				end
			end
			if self.m_Flags[v] ~= nil then
				self.m_Flags[v] = nil
				table.insert(self.m_ClearGuideTable, v) 
			end			
		end	
	end
end

--清除引导的记录
function CGuideCtrl.ResetCtrl(self)
	self:InitValue()
end

--完成所有引导
function CGuideCtrl.FinishAllGuide(self)
	if not self.m_Flags then
		return
	end
	local t = {}	
	local d = data.guideconfigdata.DATA
	for i, v in ipairs(d) do
		if v.main and v.main == true then
			local key = v.key
			key = string.gsub(key, "N1Guide_", "")
			table.insert(t, key)			
			self.m_Flags[key] = true
		end
	end
	self:CtrlCC2GSFinishGuidance(t)
	--netplayer.C2GSLeaveWatchWar()
	local cb = function ()
		CDialogueAniView:CloseView()
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			local pos_info = {x=27,y=25,face_y=125}
			netscene.C2GSFlyToPos(pos_info, 101000)								
		end	
	end
	Utils.AddTimer(cb, 0, 1)
end

--跳过开居
function CGuideCtrl.JumpStart(self)	
	if not self.m_Flags then
		return
	end
	local t = {}	
	local other = {"welcome_one", "welcome_two", "welcome_three"}
	for k, v in pairs(other) do
		table.insert(t, v)
		self.m_Flags[v] = true
	end
	self:CtrlCC2GSFinishGuidance(t)
	--netplayer.C2GSLeaveWatchWar()
	local cb = function ()
		CDialogueAniView:CloseView()
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			local pos_info = {x=27,y=25,face_y=125}
			netscene.C2GSFlyToPos(pos_info, 101000)								
		end	
	end
	Utils.AddTimer(cb, 0, 1)
end

function CGuideCtrl.InitValue(self)
	self.m_UIRefs = {}
	self.m_Flags = nil
	self.m_SwipeCancel = {}
	self.m_CheckTypes = {}
	self.m_CheckAllGuides = {}
	self.m_UpdateInfo = {}
	self.m_CustomKey = {}
	if self.m_TipsGuideFlags == nil then
		self.m_TipsGuideFlags = {}
	else
		if next(self.m_TipsGuideFlags) then
			self:ClearTipsGuideEffect()
		else
			self.m_TipsGuideFlags = {}
		end
	end
	self.m_IsInit = false
	self.m_IsGuide = false
	self.m_IsCanAutoWar = false
	self.m_IsJiHuo = false 
	self.m_DelayClickTimer = nil
	self.m_War3GuideAnyTouchTime = nil
	self.m_War3GuideAnyTouchInGuide = nil
	self.m_War3RemainTime = nil
	self.m_War3GuideTimer = nil
	self.m_IsCheckLoginCacheGuide = false
	self.m_ViewOpenTable = {}
	self.m_War4AutoSkillBox = {}
	self.m_War4AutoBoxSelectIdx = {}
	self.m_War4GuideStep = 0	
	self.m_EffecTipsTable = {}
	self.m_TaskNvGuideTimer = nil
	self.m_IsShowWarReplaceGuideEnd = false
	self.m_IsCanShoWWarReplaceGuide = nil
	self.m_ShowIngWarReplaceGuide = false
	self.m_MapLoadDownTriggerKey = nil
	self.m_WarSpeedGuide = nil
	self.m_War5JiHuo = nil
	self.m_AutoWarGuide = false
	self.m_WelcomeTable = 
	{
		welcome_one = {id=10509},
	}
	self.m_ClearGuideTable = {}
	self:ResetUpdateInfo()
	self.m_DefaultAfterMask = {args={[1]=0.3,},func_name=[[after_mask_process]],}
	self.m_ClickWrongCnt = 0
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
		CGuideView:CloseView()
	end
end

function CGuideCtrl.CheckTaskNvGuide(self, isHeroStop, isWalk)
	if not g_TaskCtrl:HaveNvTipsGuide() then
		return
	end
	if self.m_TaskNvGuideTimer then
		Utils.DelTimer(self.m_TaskNvGuideTimer)
		self.m_TaskNvGuideTimer = nil
	end

	local oView = CMainMenuView:GetView()
	if not oView or not oView:GetActive() then
		return
	end

	if not oView or not oView.m_LT or not oView.m_LT.m_ExpandBox or not oView.m_LT.m_ExpandBox.m_TaskPage then
		return
	end

	local oUITable  = oView.m_LT.m_ExpandBox.m_TaskPage.m_ItemTable
	if not oUITable then
		return
	end

	local needFresh = false
	for i = 1, oUITable:GetCount() do
		local oBox = oUITable:GetChild(i)
		--没有特效		
		if oBox and oBox:GetActive() == true and not oBox.m_TaskBgBtn:GetdEffect("Finger") and 
			(
				--主线任务10002 和 10036之间
				oBox.m_TaskData:GetValue("taskid") >= 10001 and oBox.m_TaskData:GetValue("taskid") <= 10036 or			
					 (
					 	--师门任务
					 	oBox.m_TaskData:GetValue("taskid") == CTaskCtrl.ShiMenAccectTaskId 
			   		 )
			 ) then

			needFresh = true 
			break
		end
	end

	if not needFresh then
		return
	end

	if isHeroStop then
		if isWalk then
			return
		end
		local cb = function ()
			g_TaskCtrl:RefreshUI()
		end
		self.m_TaskNvGuideTimer = Utils.AddTimer(cb, 0, 5)
	else
		local oHero = g_MapCtrl:GetHero()
		if oHero and not oHero:IsWalking() then
			g_TaskCtrl:RefreshUI()
		end
	end
end

function CGuideCtrl.DelayShowDrawCloseLBEffect(self)
	local cb = function ()
		self:AddGuideUIEffect("drawcard_close_lb", "circle")
	end
	Utils.AddTimer(cb, 0, 0.3)
end

function CGuideCtrl.StartHouseViewTouchMove(self)
	if self.m_HouseDoorTimer then
		Utils.DelTimer(self.m_HouseDoorTimer)
		self.m_HouseDoorTimer = nil
	end

	local update = function (dt)	
		time = time + dt		
		local oView = CHouseMainView:GetView()
		if time >= t then
			local oHouse =  g_HouseCtrl:GetCurHouse()			
			local oCam = g_CameraCtrl:GetHouseCamera()	
			local oUICam = g_CameraCtrl:GetUICamera()		
			if oView and oView.m_GuideBtn and oHouse and oHouse.m_CookingEffect and oCam and oUICam then
				local wPos = oHouse.m_CookingEffect:GetPos()				
				local p = oCam:WorldToScreenPoint(wPos)
				p.y = p.y - 70		
				p.z = 0
				local pp = oUICam:ScreenToWorldPoint(p)
				oView.m_GuideBtn:SetActive(true)
				oView.m_GuideBtn:SetPos(Vector2.New(pp.x, pp.y))
			end
			return false
		end		
		local touch = {x = speed, y = 0}
		g_HouseTouchCtrl:OnSwipe(touch)		
		return true
	end
	self.m_HouseDoorTimer = Utils.AddTimer(update, 0, 0)
end

function CGuideCtrl.PlayGuideAudio(self, voice)
	if not voice or voice == "0" then
		g_AudioCtrl:OnStopPlay()
		return
	end
	g_AudioCtrl:PlayGuideVoice(voice)
end

function CGuideCtrl.CheckStartWarReplaceGuide(self, bout)
	if not self.m_Flags then
		return
	end	
	if self.m_Flags["WarReplace"] ~= nil then
		return
	end

	if self.m_IsCanShoWWarReplaceGuide == nil then
		self.m_IsCanShoWWarReplaceGuide = true
		self.m_IsShowWarReplaceGuideEnd = false
	elseif self.m_IsCanShoWWarReplaceGuide == false then
		return
	end

	local isInTeam = g_TeamCtrl:IsInTeam()
	local lMemberList = g_TeamCtrl:GetMemberList()
	if not isInTeam or #lMemberList == 1 then
		return
	end
	local havePartnerDie = false
	for i, oWarrior in pairs(g_WarCtrl.m_Warriors) do
		if oWarrior then
			if oWarrior.m_PartnerID and oWarrior.m_OwnerWid and not oWarrior:IsAlive() then
				local oHeroWarrior = g_WarCtrl:GetWarrior(oWarrior.m_OwnerWid)
				if oHeroWarrior and g_AttrCtrl.pid == oHeroWarrior.m_Pid then
					havePartnerDie  = true
					break
				end
			end		
		end
	end

	if havePartnerDie == true and self.m_IsCanShoWWarReplaceGuide == true then
		self.m_IsShowWarReplaceGuideEnd = true
		self.m_IsCanShoWWarReplaceGuide = false
		self.m_ShowIngWarReplaceGuide = true
		self:TriggerAll()			
	end	
end

function CGuideCtrl.StopWarReplaceGuide(self)
	self.m_IsShowWarReplaceGuideEnd = false
	self.m_IsCanShoWWarReplaceGuide = nil
	self.m_ShowIngWarReplaceGuide = false
	local oView = CGuideView:GetView()
	if oView then
		oView:CloseView()
	end
	self:DelGuideUIEffect("war_replace_btn", "round")
end

function CGuideCtrl.FinishWarReplaceGuide(self)
	if not self.m_Flags then
		return
	end	
	if self.m_Flags["WarReplace"] ~= nil then
		return
	end	

	if self.m_IsShowWarReplaceGuideEnd then
		self:ReqCustomGuideFinish("WarReplace")
	end
end

function CGuideCtrl.CheckTeamStateInGuide(self, key)
	if not key or key == "" then
		return
	end
	local isInTeam = g_TeamCtrl:IsInTeam()
	local lMemberList = g_TeamCtrl:GetMemberList()
	if isInTeam or #lMemberList > 1 then
		netteam.C2GSLeaveTeam()
	end
end

function CGuideCtrl.LoginCheckStarAni(self, scene_id, eid)
	local mapInfo = g_DialogueAniCtrl:GetStroyAniMapInfo(self.m_WelcomeTable.welcome_one.id) 
	if mapInfo then
		if mapInfo.mapId == g_MapCtrl:GetMapID() then
			return
		end
		local sceneData = DataTools.GetSceneDataForMapid(mapInfo.mapId)
		if sceneData and g_AttrCtrl.model_info and g_AttrCtrl.model_info.shape then
			local posinfo = {}
			posinfo.x = mapInfo.x
			posinfo.y = mapInfo.y
			posinfo.z = 0
			g_MapCtrl:ShowScene(scene_id, mapInfo.mapId, "")
			g_MapCtrl:EnterScene(eid, posinfo)
		end
	end
end

function CGuideCtrl.LoginReCheckGuidedProgress(self, b)
	self:ReCheckChapterFubenGuide(b)
	self:ReCheckEquipFubenGuide(b)
	--self:ReCheckTwoWZQYGuide(b)
end

function CGuideCtrl.ReCheckChapterFubenGuide(self, b)
	if not self.m_Flags then
		return
	end	

	if b and g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 1) then
		self:ReqCustomGuideFinish("GetPartner302")
	end

	if g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 2) then
		self:ReqCustomGuideFinish("War2")
	end	

	if g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 4) then
		self:ReqCustomGuideFinish("Complete_Task_ChaterFb_1_4")
	end	

	if g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 3, 8) then
		self:StartTipsGuide("Tips_HardChapterFb")
	end		

end

function CGuideCtrl.ReCheckEquipFubenGuide(self, b)
	if not self.m_Flags then
		return
	end	
	--老号如果已经完成装备副本，则会完成第一次进入副本
	if b and self:IsCompleteEquipTipsGuide() then
		self:ReqCustomGuideFinish("FirstEnterEquipFb")
	end
end

function CGuideCtrl.ReCheckTwoWZQYGuide(self, isLogin)
	if not self.m_Flags or isLogin == false then
		return 
	end
	if self.m_Flags["Tips_WZQY_0"] == true and self.m_Flags["Tips_WZQY"] ~= true and self.m_Flags["Tips_WZQY_1"] == true then
		self.m_Flags["Tips_WZQY_1"] = nil
	end
end

function CGuideCtrl.GuideLog(self, ...)
	if CGuideCtrl.LogToggle ~= 0 then
		printc(...)
	end
end

--某些引导必要要等到地图加载完成之后，才能触发
function CGuideCtrl.MapLoadDownTriggerGuide(self)
	if self.m_MapLoadDownTriggerKey == "DrawCard" then
		local cb = function ()
			g_ChoukaCtrl:StartChouka()
		end
		Utils.AddTimer(cb, 0, 0)
		self.m_MapLoadDownTriggerKey = nil
	end
end

function CGuideCtrl.IsGuideKeyActive(self, key)
	local b = false
	local oUI = self:GetGuideUI(key)
	if oUI and oUI:GetActive() == true then
		return true
	end
	return b
end


function CGuideCtrl.TriggerTeamHandyBuildGuide(self)
	-- if not self:IsCustomGuideFinishByKey("Refresh_Minglei") or not self.m_Flags or self:IsCustomGuideFinishByKey("TeamMainView_HandyBuild") then
	-- 	return
	-- end
	-- local finishStep
	-- local oUI = self:GetGuideUI("teamtarget_minglei_btn") 
	-- if CTeamTargetSetView:GetView() ~= nil and g_GuideCtrl:IsCustomGuideFinishByKey("Refresh_Minglei") and (oUI and oUI:GetActiveHierarchy()) then
	-- 	finishStep = {"Tips_TeamHandyBuild_1", "Tips_TeamHandyBuild_2", "Tips_TeamHandyBuild_3"}
	-- elseif CTeamMainView:GetView() ~= nil then
	-- 	local oView = CTeamMainView:GetView()
	-- 	if oView.m_HandyBuildPage == oView.m_CurPage then
	-- 		finishStep = {"Tips_TeamHandyBuild_1", "Tips_TeamHandyBuild_2",}
	-- 	else
	-- 		finishStep = {"Tips_TeamHandyBuild_1",}
	-- 	end
	-- end
	-- if finishStep then
	-- 	for k, v in pairs(finishStep) do
	-- 		self.m_Flags[v] = true
	-- 		self:CtrlCC2GSFinishGuidance({[1] = v})
	-- 	end
	-- end
	-- self:StartTipsGuide("Tips_TeamHandyBuild")
	-- self:TriggerAll()
end

function CGuideCtrl.FinishTeamHandyBuildTipsStep(self, step)
	if not self:IsCustomGuideFinishByKey("Refresh_Minglei") or not self.m_Flags or self:IsCustomGuideFinishByKey("TeamMainView_HandyBuild") then
		return
	end
	for i = 1, step - 1 do
		local key = string.format("Tips_TeamHandyBuild_%d", i)
		if self.m_Flags[key] ~= true then			
			local d = data.guidedata["Tips_TeamHandyBuild"]
			if d and d.guide_list and d.guide_list[i] then								
				self:DelGuideUIEffect( d.guide_list[i].necessary_ui	,  d.guide_list[i].ui_effect)
				self.m_TipsGuideFlags[d.guide_list[i].necessary_ui] = nil
			end
			self.m_Flags[key] = true		
			self:CtrlCC2GSFinishGuidance({[1] = key})
		end
	end
end

function CGuideCtrl.CtrlGS2CRefreshMinglei(self)
	-- if not self:IsCustomGuideFinishByKey("Refresh_Minglei") and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.minglei.open_grade then
	-- 	self:ReqCustomGuideFinish("Refresh_Minglei")						
	-- 	self:TriggerTeamHandyBuildGuide()
	-- end
end

function CGuideCtrl.CheckStroyAni(self)
	local b = false
	--10014 任务剧场剧场
	local oTask = g_TaskCtrl:GetTaskById(10014)
	if oTask and not self:IsCustomGuideFinishByKey("Task_Stroy_10014") then
		local acceptgrade = oTask:GetValue("acceptgrade")
		local acceptcallplot = oTask:GetValue("acceptcallplot")		
		if acceptcallplot and acceptcallplot ~= 0 and g_AttrCtrl.grade >= acceptgrade then
			if not g_DialogueAniCtrl:IsInPlayStoryAni() then
				g_DialogueAniCtrl:InsetUnPlayList(acceptcallplot, g_MapCtrl:GetHero() == nil)
				b = true
			end			
		end
	end
	return b
end

function CGuideCtrl.StopHeroWalk(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:StopWalk()
	end
end

function CGuideCtrl.TriggerJQFBGuide(self)
	if g_ChapterFuBenCtrl:CheckChapterLevelOpen(define.ChapterFuBen.Type.Simple, 1, 3) and not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 3) then
		self.m_Flags["AutoWar"] = nil	
	end	

	if g_ChapterFuBenCtrl:CheckChapterLevelOpen(define.ChapterFuBen.Type.Difficult, 1, 1)  then
		if not g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Difficult, 1, 1) then
			self:TriggerAll()
		else
			self:ReqCustomGuideFinish("ChapterFuBen_Hard")
		end
	end
end

function CGuideCtrl.IsCanPartnerHBHCMainMenu(self)
	local cnt = g_ItemCtrl:GetTargetItemCountBySid(20302)
	return cnt >= 40
end

function CGuideCtrl.IsCanPartnerHBSXMainMenu(self)
	local cnt = g_ItemCtrl:GetTargetItemCountBySid(20302)
	return cnt >= 20
end

function CGuideCtrl.IsCanPartnerHBJNMainMenu(self)
	local b = false
	if self:IsCompleteTipsGuideByKey("Tips_PartnerChip_Compose") then
		local cnt = 0
		local list = g_PartnerCtrl:GetPartnerList(true)
		if next(list) then
			for k, v in pairs(list) do
				if v:GetValue("partner_type") == 302 then
					cnt = cnt + 1 
				end
			end
			if cnt >= 2 then
				b = true
			end
		end
	end
	return b
end
	
function CGuideCtrl.GetHBSXPartner(self)
	local t = nil
	local list = g_PartnerCtrl:GetPartnerList(true)
	for parid, oPartner in pairs(list) do
		if oPartner:GetValue("grade") >= 20 then
			if oPartner:GetValue("star") >= 2 then
				self:ReqCustomGuideFinish("Partner_HBSX_MainMenu")
				self:ReqCustomGuideFinish("Partner_HBSX_PartnerMain")
				break
			else
				t = oPartner
				break
			end
		end
	end
	return t
end

function CGuideCtrl.IsCompleteEquipTipsGuide(self)
	local b = false
	if self.m_Flags then
		b = self.m_Flags["PassEquipWarGuide"] == true
	end
	return b
end

function CGuideCtrl.CompleteEquipTipsGuide(self)
	if self.m_Flags and self.m_Flags["PassEquipWarGuide"] ~= true then
		self.m_Flags["PassEquipWarGuide"] = true
		self:CtrlCC2GSFinishGuidance({"PassEquipWarGuide"})
	end
end

function CGuideCtrl.IsFirstEquipFuben(self)
	return not self:IsCustomGuideFinishByKey("FirstQuitEquipFb") and not self:IsCustomGuideFinishByKey("PassEquipWarGuide")
end

function CGuideCtrl.SetEquipFbQuitGuide(self)
	self:CtrlCC2GSFinishGuidance({"FirstQuitEquipFb", "Forge_Strength_View","Forge_Strength_Open", "QuickUse_View", "PassEquipWarGuide"})
end

function CGuideCtrl.ShowQuickUseGuideItem(self)
	if self:IsCustomGuideFinishByKey("QuickUse_View") then
		return
	end
	local cb = function ()
		local list = g_ItemCtrl:GetAllItemsByTypeAndSort(define.Item.ItemType.Equip, define.Item.SortType.Level)
		if list and next(list) then
			for k, v in pairs(list) do
				g_ItemCtrl:CheckLocalQuickEquip(v)
			end
		end
	end
	Utils.AddTimer(cb, 0, 0.5)
end

function CGuideCtrl.LoadShowWarGuide(self )
	if self:IsCustomGuideFinishByKey("welcome_two") then
		return
	end
	local cb = function ()
		self:ReqCustomGuideFinish("welcome_two")
		g_NotifyCtrl:ShowAniSwitchTextureBg("guide_black", 5, true)
		if g_AttrCtrl.grade <= 5 then
			g_DialogueAniCtrl:InsetUnPlayList(888)
		end
		local cb2 = function ()
			g_ShowWarCtrl:StopShowWar()
		end
		Utils.AddTimer(cb2, 0, 1)
	end
	g_ShowWarCtrl:LoadShowWar("Boss", cb)
end

function CGuideCtrl.JumpShowWar(self)
	self:ReqCustomGuideFinish("welcome_two")
	g_NotifyCtrl:ShowAniSwitchTextureBg("guide_black", 5, true)
	local cb = function ()
		if g_AttrCtrl.grade <= 5 then
			g_DialogueAniCtrl:InsetUnPlayList(888)
		end
		g_ShowWarCtrl.m_EndCb = nil
		g_ShowWarCtrl:StopShowWar()
	end
	Utils.AddTimer(cb, 0, 1)	
end

function CGuideCtrl.CtrlCC2GSFinishGuidance(self, d)
	if not d or not next(d) then
		return
	end
	local t = {}
	local cacheKey = {}
	for i, v in ipairs(d) do
		local value = string.format("N1Guide_%s", v)
		local temp = data.guideconfigdata.ValueToKey[value]
		if temp then
			table.insert(t, temp.key)		
		else
			printc(" finish guide key is not exit ----> ", value)
		end	
		table.insert(cacheKey, value)	
	end
	print("C2GSFinishGuidance>>>>>>>>>>>>>")
	table.print(cacheKey)
	netteach.C2GSFinishGuidance(t)
end

function CGuideCtrl.CtrlC2GSClearGuidance(self, d)
	if not d or not next(d) then
		return
	end
	local t = {}
	for i, v in ipairs(d) do
		local value = string.format("N1Guide_%s", v)
		local temp = data.guideconfigdata.ValueToKey[value]
		if temp and temp.key then
			table.insert(t, temp.key)		
		else
			printc(" clear guide key is not exit ----> ", value)
		end	
	end
	netteach.C2GSClearGuidance(t)
end

--触发引导时候，停止某些操作
function CGuideCtrl.StopActionWhenGuide(self)
	if not self:IsInTargetGuide("Dialogue_Shimen") then
		g_TaskCtrl:StartAutoDoingShiMen(false)
		g_TaskCtrl:ChekcAutoShimen(CTaskCtrl.AutoSM.None)
	end
	g_TaskCtrl:StopWalingTask()
end

function CGuideCtrl.SetWarSpeedLevel(self, chapter, level)
	self.m_WarSpeedGuide = nil
	if not self:IsCustomGuideFinishByKey("WarSpeed") and chapter == 1 and level == 3 then
		self.m_WarSpeedGuide = false
	end
end

function CGuideCtrl.CheckWarSpeedGuide(self, speed)
	if self.m_WarSpeedGuide ~= nil then
		if speed == 1 then
			self:TriggerCheck("war")
			self.m_WarSpeedGuide = true
		else
			self:ReqCustomGuideFinish("WarSpeed")
			self.m_WarSpeedGuide = nil
		end
	end
end

function CGuideCtrl.CompleteWarSpeedGuide(self)
	local oView = CGuideView:GetView()
	if oView then
		oView:CloseView()	
	end
	self.CtrlCC2GSFinishGuidance({"WarSpeed"})
	self.m_UpdateInfo.guide_type = nil
	self.m_UpdateInfo.guide_key = nil
	self.m_UpdateInfo.cur_idx = 1
end


function CGuideCtrl.HouseGuideTouchAnyway(self)
	if CHouseExchangeView:GetView() then
		self.m_HouseViewStepTwoAnyTouch = true
	end
end

--进入宅邸时，重新设置宅邸引导
function CGuideCtrl.CheckHouseOpenGuide(self)
	if self:IsCustomGuideFinishByKey("HouseView_1") then
		self:ReqCustomGuideFinish("HouseView")
		self:ReqCustomGuideFinish("HouseTwoView")
		self:ReqCustomGuideFinish("HouseTeaartView")
	end
end

--从宅邸交互界面返回主界面时，重新设置宅邸引导
function CGuideCtrl.CheckHouseBackGuide(self, isClose)	
	if isClose and self.m_UpdateInfo and "HouseView" == self.m_UpdateInfo.guide_type then
		self:ResetUpdateInfo()
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
		end		
	end
	g_GuideCtrl:DelGuideUIEffect("house_walker_1001")
end

function CGuideCtrl.CheckOtherGuideWhenTeaar(self)
	if self.m_UpdateInfo then
		if "HouseTeaartView" == self.m_UpdateInfo.guide_type then
			self:ResetTargetGuide({"HouseTeaartView"})
		end
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
		end		
		self:ResetUpdateInfo()
		self:TriggerCheck("view")
	end
	g_GuideCtrl:DelGuideUIEffect("house_walker_1001")
end

function CGuideCtrl.CheckOtherGuideWhenBuff(self)
	if self.m_UpdateInfo then
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
		end		
		self:ResetUpdateInfo()
		self:TriggerCheck("view")
	end
	g_GuideCtrl:DelGuideUIEffect("house_walker_1001")
end

--完成所有宅邸的引导
function CGuideCtrl.FinishAllHouseGuide(self)
	if not self.m_Flags then
		return
	end
	self:ReqCustomGuideFinish("HouseView")
	self:ReqCustomGuideFinish("HouseTwoView")
	self:ReqCustomGuideFinish("HouseTeaartView")
end

function CGuideCtrl.TargetGuideStepContinu(self, guideKey , step)
	if guideKey and guideKey ~= "guideKey" then
		if self:IsInTargetGuide(guideKey) and self.m_UpdateInfo.cur_idx == step then
			self:Continue()
		end
	end 
end

function CGuideCtrl.CheckTeaarViewGuide(self)
	if not self:IsCustomGuideFinishByKey("HouseTeaartView") then
		self:ResetTargetGuide({"HouseTeaartView"})
	end
end

function CGuideCtrl.ReCheckHouseGuideEffect(self)
	if not self:IsCustomGuideFinishByKey("HouseView") and not self:IsCustomGuideFinishByKey("HouseView_2") then
		self:AddGuideUIEffect("house_walker_1001")		
	end
end

function CGuideCtrl.NoLoginRewardView(self)
	return CLoginRewardView:GetView() == nil
end

function CGuideCtrl.ResetAutoWarGuide(self)
	self.m_AutoWarGuide = false
	if self.m_UpdateInfo and "WarAutoWar" == self.m_UpdateInfo.guide_type then
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
		end
		self:ResetTargetGuide({"HouseTeaartView"})
		self:ResetUpdateInfo()		
	end
end

function CGuideCtrl.StartAutoWarGuide(self)
	if not self:IsCustomGuideFinishByKey("WarAutoWar") then
		self.m_AutoWarGuide = true
		self:TriggerCheck("War")
	end
end

function CGuideCtrl.SwitchEnv(self, bWar)
	if not bWar and not self:IsCustomGuideFinishByKey("GetPartner302") and g_ChapterFuBenCtrl:CheckChapterLevelPass(define.ChapterFuBen.Type.Simple, 1, 1) then
		local cb = function ()
			self:ReqCustomGuideFinish("GetPartner302")
		end
		g_MainMenuCtrl:SetMainViewCallback(cb)
	end
end

function CGuideCtrl.OnJumpGuide(self)
	if self.m_UpdateInfo and self.m_UpdateInfo.guide_type then		
		self:JumpTargetGuideList(self.m_UpdateInfo.guide_type)
		self.m_UpdateInfo.after_mask = nil
		self:ResetUpdateInfo()
		local oView = CGuideView:GetView()
		if oView then
			oView:CloseView()
		end
		if g_WarCtrl:IsWar() then
			netwar.C2GSWarStart(g_WarCtrl:GetWarID())
		end
	end
end

function CGuideCtrl.JumpTargetGuideList(self, guide_type)
	local d = data.guideprioritydata.DATA[guide_type]
	if d then		
		if d.jump_func and d.jump_func ~= "" and self[d.jump_func] then
			self[d.jump_func](self)
		end
		if d.list and next(d.list) then
			for i, v in ipairs(d.list) do				
				self:ReqCustomGuideFinish(v)
			end
		end
		if d.other_list and next(d.other_list) then
			for i, v in ipairs(d.other_list) do					
				self:ReqCustomGuideFinish(v)
			end
		end
	end
end

return CGuideCtrl