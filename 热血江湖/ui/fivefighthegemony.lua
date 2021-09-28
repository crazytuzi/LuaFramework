-------------------------------------------------------
module(..., package.seeall)

local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_fiveFightHegemony = i3k_class("wnd_fiveFightHegemony", ui.wnd_base)

local STATE_SKILL = 1
local STATE_ARRANGEMENT = 2
local STATE_FIGHT = 3
local stateDesc = {
	[STATE_SKILL] = 17819,
	[STATE_ARRANGEMENT]	= 17820,
	[STATE_FIGHT] = 17821,
}

function wnd_fiveFightHegemony:ctor()
	self.haveShowedShootMsg = 0
	self.shootMsgIndex = 1
	self.shootMsgState = i3k_usercfg:GetIsShowHegemonyShootMsg()
	self._state = nil
	
	self._canSend  = false
	self._canUse = false
	self._supportNpc = 0			-- 支持npc
	self._isRandomAnswer = false	-- 是否可随机
	self._selectSkill = 0			-- 选择技能
	self._oldTime = i3k_game_get_time()
	
	self._shootMsgData = {}
	self._shootMsgItems = {}
end

function wnd_fiveFightHegemony:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.showReward:onClick(self, self.openReward)
	self._layout.vars.helpBtn:onClick(self,function()g_i3k_ui_mgr:ShowHelp(i3k_get_string(17835)) end)
	self:ctrlShootMsg(self.shootMsgState)
	widgets.shootMsg_btn:onClick(self,function ()
		if not self._supportNpc or self._supportNpc == 0 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17824))
		end
		g_i3k_ui_mgr:OpenUI(eUIID_ShootMsg)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShootMsg, g_SHOOT_MSG_TYPE_HEGEMONY, self._supportNpc)
	end)
	widgets.showMsgBtn:onClick(self,function ()
		self:ctrlShootMsg(not self.shootMsgState)
		i3k_usercfg:SetIsShowHegemonyShootMsg(self.shootMsgState)
	end)
	
	--初始化技能，血条
	self._hpNode =  {}
	self._skills = {}  --技能按钮存储
	for i = 1, 2 do
		--技能
		local items = {}
		local index = (i-1)*3
		for k = 1, 3 do
			local item = {}
			item.icon = widgets["skillicon"..index + k]
			item.btn = widgets["skillbtn"..index + k]
			item.btnIcon = widgets["skillBtnIcon"..index + k]
			table.insert(items, item)
		end
		table.insert(self._skills, items)
		--血条
		local node = {}
		node.bloodLabel = widgets["npcxl"..i] --npc血量
		node.bloodBar = widgets["npcBar"..i]
		node.bloodNext = widgets["npcxd"..i] --下层血量
		table.insert(self._hpNode, node)
	end
	
	--初始化弹幕
	for i = 1, 20, 1 do
		local item = self._layout.vars["shootMsg" .. i]
		table.insert(self._shootMsgItems, item)
	end
	
end

function wnd_fiveFightHegemony:refresh(info)
	--是否支持npc
	self._supportNpc = info.roleInfo and  info.roleInfo.npcID or 0
	self:loadNpc(info)
	--状态
	self:updateActivityState(info)
	
end

--当前状态
function wnd_fiveFightHegemony:updateActivityState(logs)
	self:updateSupportInfo(logs, true)
	local state =  g_i3k_db.i3k_db_get_five_Contend_hegemony_state() 
	if state == g_FIVE_CONTEND_HEGEMONY_ACTIVITY or state == g_FIVE_CONTEND_HEGEMONY_PRESELECTION then		--活动开始状态
		self._canUse = true
		self:updateRound(logs)
	end
	
end

--初始化npc信息
function wnd_fiveFightHegemony:loadNpc(info)
	local cfgBlood = i3k_db_five_contend_hegemony.cfg.npcHp
	local widgets = self._layout.vars
	for k = 1, 2, 1 do	
		local npcInfo = info.npcInfo[k]
		local npcCfg = i3k_db_five_contend_hegemony.npcRole[npcInfo.npcID]
		local modelId = npcCfg.modelID
		widgets["npcIcon"..k]:setImage((g_i3k_db.i3k_db_get_icon_path(npcCfg.icon))) 
		widgets["chooseSupport"..k]:onClick(self, self.supportBtn, npcInfo.npcID)
		widgets["npcAttribute"..k]:onClick(self, self.showNpcAttribute, npcInfo.npcID)
		self:updateHp(cfgBlood, self._hpNode[k])
		local rotation = i3k_db_five_contend_hegemony.rotation[k]
		self:updateModelState(widgets["npcModel"..k], modelId, "stand", rotation )
	end
	self:updateSupportState()
	self:loadSkill(info)
	self:refreshNpcIcon()
end

--更新支持状态
function wnd_fiveFightHegemony:updateSupportState()
	local widgets = self._layout.vars
	local index = self:getSupportPosition()
	
	for k = 1, 2, 1 do
		local support = k == index
		widgets["support"..k]:setVisible(support)
		widgets["chooseSupport"..k]:setVisible(index == 0)
		self:setOption(self._skills[k], 0, not support)
	end
	
end

--loadskill
function wnd_fiveFightHegemony:loadSkill(info)
	local npcInfo = info.npcInfo
	local cfg = i3k_db_five_contend_hegemony.npcRole
	local skillCfg = i3k_db_five_contend_hegemony.skills
	--local skills = cfg[roldID].skills
	for i, npc in ipairs(npcInfo) do	
		local skills = cfg[npc.npcID].skills
		local items = self._skills[i]
		for k, id in ipairs(skills) do
			local item = items[k]
		    item.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg[id].icon))
			item.btn:onClick(self, self.selectSkill, id)
			item.btn:setTag(id)
			item.btnIcon:setVisible(false)
		end
	end
	
end

--更新npc
function wnd_fiveFightHegemony:updateSupportInfo(info, isLoad)
	local isSupport = self._supportNpc
	if isSupport == 0 then
		self._layout.vars.showdDesc:setVisible(true)
	else
		self._layout.vars.showdDesc:setVisible(false)
		self:setWarReport(info, isLoad) --刷新战报
		if info and info.npcInfo then
			for k = 1, 2, 1 do
				self:updateHp(info.npcInfo[k].curBlood, self._hpNode[k])
			end
		end	
	end
end

--获取支持npc位置
function wnd_fiveFightHegemony:getSupportPosition()
	local hegemonyInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
	local npcInfo = hegemonyInfo.npcInfo
	for i, npc in pairs(npcInfo) do
		if npc.npcID == self._supportNpc then
			return i
		end
	end
	return 0
end

--npc模型
function wnd_fiveFightHegemony:updateModelState(model, showId, action, rotation)
	local path = i3k_db_models[showId].path
	local uiscale = i3k_db_models[showId].uiscale
	model:setSprite(path)
	model:setSprSize(uiscale)
	model:pushActionList(action, -1)
	model:playActionList()
	if rotation then
		model:setRotation(rotation)
	end
end
-----------------InvokeUIFunction---------------------------------

--刷新回合
function wnd_fiveFightHegemony:updateRound(info)
	local cfg = i3k_db_five_contend_hegemony.cfg
	self._hegemonyTimes = self:getCurRoundTime()											 
	if self._hegemonyTimes >= cfg.guessingTime then	 -- 展示动作状态
		self._result = false
		if info and info.skillInfo then		
			self:PlayAction(info.skillInfo)														 
			self:updateSupportInfo(info)	
			if self._addExp then --加经验
				g_i3k_ui_mgr:OpenUI(eUIID_QuizShowExp)
				g_i3k_ui_mgr:RefreshUI(eUIID_QuizShowExp,self._addExp)
				self._addExp = nil
			end			
		end
	else																						 --猜技能状态
		local index = self:getSupportPosition()
		if info and info.roleInfo and info.curRound == info.roleInfo.skillRound and info.roleInfo.tempSkillID then --本题答完中途再次进入需要记录状态
			self:setOption(self._skills[index], info.roleInfo.tempSkillID)
		else
			self:setOption(self._skills[index], 0) --技能选择·
		end
		--self._canNext = false
		self._isRandomAnswer = true
		self._canUse = true
		self:updateSupportInfo(nil, true)
	end
end

--播放动画
function wnd_fiveFightHegemony:PlayAction(info)
	if not info then return end
	local widgets = self._layout.vars
	for k = 1, 2 do
		local skillInfo = info[k]
		local action = i3k_db_five_contend_hegemony.skills[skillInfo.skillID].actionID
		widgets["npcModel"..k]:pushActionList(action, 1)
		widgets["npcModel"..k]:pushActionList("stand", -1)
		widgets["npcModel"..k]:playActionList()
	end 
end

-- 设置技能选项 skillBtn 技能按钮 result选中技能id  disableAll -- 隐藏所有
function wnd_fiveFightHegemony:setOption(skillBtn ,result, disableAll)
	if not skillBtn then return end
	for i, e in ipairs(skillBtn) do
		if e.btn:getTag() == result then
			e.btnIcon:show()
		else
			e.btnIcon:hide()
		end
		if not result or result == 0 and not disableAll then	
			e.btn:enable()
		else
			e.btn:disable()
		end
	end
	self._selectSkill = result
end

--技能选择回调
function wnd_fiveFightHegemony:chooseSkillResult(result)
	local index = self:getSupportPosition()
	self:setOption(self._skills[index], result)
end

--支持npc
function wnd_fiveFightHegemony:selectNpc(npcID)
	local cfg = g_i3k_game_context:getFiveHegemonyManagerInfo()
	self._supportNpc = npcID
	self:updateSupportState()
	self:updateSupportInfo(cfg, true)
end

--添加经验
function wnd_fiveFightHegemony:addExpShow(iexp)
	self._addExp = iexp
end


-----------------InvokeUIFunctionEnd-------------------------------

-----------刷新--------------------------------------------
function wnd_fiveFightHegemony:onUpdate(Time)

	local cur_Time = i3k_game_get_time()
	local cfg = i3k_db_five_contend_hegemony.cfg
	local openTime = g_i3k_get_day_time(cfg.openTime)
	local PreselectionTime = openTime + cfg.PreselectionTime
	local state = g_i3k_db.i3k_db_get_five_Contend_hegemony_state()
	if state == g_FIVE_CONTEND_HEGEMONY_PRESELECTION then
		self:excessTime()
		self._canSend = true
	else	--开始活动
		if state == g_FIVE_CONTEND_HEGEMONY_SHOW then
			g_i3k_ui_mgr:AddTask(self, {}, function(ui)
				g_i3k_ui_mgr:OpenUI(eUIID_FiveHegemonyShow)
				g_i3k_ui_mgr:RefreshUI(eUIID_FiveHegemonyShow)
				g_i3k_ui_mgr:CloseUI(eUIID_FiveHegemony)
			end, 1)
			
		elseif state == g_FIVE_CONTEND_HEGEMONY_ACTIVITY then
			if self._canUse then
				if self._canSend then
					self._canUse = false
					self._canSend = false
					i3k_sbean.five_hegemony_sync(g_HEGEMONY_PROTOCOL_STATE_ROUND)		
				else
					self:onUpdateCurrentMid()
				end
			end
		end
	end	
	--弹幕
	if self.shootMsgState and self._supportNpc ~= 0 and cur_Time - self._oldTime > 3 then
		self._oldTime = cur_Time
		i3k_sbean.five_hegemony_barrage(g_i3k_game_context:getHegemonyShootMsgId())
	end
	--弹幕
	if table.nums(self._shootMsgData) >= 1 then
		self:showOneShootMsg(self._shootMsgData[1], true)
	end
end

--状态转换
function wnd_fiveFightHegemony:onUpdateCurrentMid()
	local cfg = i3k_db_five_contend_hegemony.cfg
	local startTime = self:getStartTime()
	local curtime, curFloat = i3k_game_get_time()	
	local roundTime, round = self:getCurRoundTime()
	local skillTime = cfg.guessingTime - cfg.arrangementTime
	local actionTime = cfg.guessingTime +  cfg.requestTime
	if roundTime < skillTime then                          --选择技能		
		self._isRandomAnswer = true
		if self._canNext and curtime ~= startTime then
			self._canNext = false
			i3k_sbean.five_hegemony_sync(g_HEGEMONY_PROTOCOL_STATE_ROUND)
		end
	elseif roundTime >= skillTime and roundTime < cfg.guessingTime  then --随机答案状态
		self._result = true
		if self._supportNpc and self._supportNpc ~= 0 and self._selectSkill == 0 and  self._isRandomAnswer then
			self._isRandomAnswer = false
			local skills = i3k_db_five_contend_hegemony.npcRole[self._supportNpc].skills
			local skillIndex = math.random(1, #skills)
			local maxSenTime =  cfg.guessingTime - roundTime - curFloat
			if maxSenTime > 0 then
				
				self._chooseCo = g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForSeconds(math.random(0, maxSenTime*100-10)/100)
					self:selectSkill(nil, skills[skillIndex], true)
				end)
			end
		end
	elseif roundTime == actionTime then --请求结果状态
		if self._result then
			--self._result = false
			local managerInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
			i3k_sbean.five_hegemony_round_result(managerInfo.curRound)
		end
	elseif roundTime >  actionTime then --动作状态
		self._canNext = true
	end
	self:setStateDesc()
end


--设置状态信息
function wnd_fiveFightHegemony:setStateDesc()
	local hegemonyInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
	local indexDesc, time = self:getCountDown()
	local desc = stateDesc[indexDesc]
	--i3k_log(desc)
	--local roundDesc = "第"..hegemonyInfo.curRound.."回合"
	self._layout.vars.descState:setText(i3k_get_string(desc, hegemonyInfo.curRound, time))
end

----活动倒计时
function wnd_fiveFightHegemony:excessTime()
	local cur_Time = i3k_game_get_time()
	local startTime = self:getStartTime()
	local time = i3k_get_time_show_text(startTime - cur_Time)
	self._layout.vars.descState:setText(i3k_get_string(17822, time))
end

--倒计时
function wnd_fiveFightHegemony:getCountDown()
	local cfg = i3k_db_five_contend_hegemony.cfg
	local curRoundTime = self:getCurRoundTime() 
	local have_time = cfg.guessingTime - curRoundTime - cfg.arrangementTime
	if have_time > 0 then
		return STATE_SKILL, have_time
	end
	local infoTime = cfg.guessingTime - curRoundTime + cfg.requestTime
	if infoTime > 0 then
		return STATE_ARRANGEMENT, infoTime 
	end
	local action = cfg.guessingTime + cfg.actionTime - curRoundTime 
	if action > 0 then
		return STATE_FIGHT, action
	end
	return STATE_FIGHT, 0
end
-------------------------------------刷新end---------------------------

--当前轮次时间和轮次
function wnd_fiveFightHegemony:getCurRoundTime()
	local cfg = i3k_db_five_contend_hegemony.cfg
	local startTime = self:getStartTime()
	local curtime = math.modf(i3k_game_get_time())
	local roundTime = cfg.actionTime + cfg.guessingTime 
	return math.modf((curtime - startTime) %  roundTime) , math.ceil((curtime - startTime) / roundTime )
end

--获取开始时间
function wnd_fiveFightHegemony:getStartTime()
	local cfg = i3k_db_five_contend_hegemony.cfg
	local openTime = g_i3k_get_day_time(cfg.openTime)
	local startTime = openTime + cfg.PreselectionTime
	return startTime
end

local bloodLayerIconsId =
{
	[0] = 0,
	[1] = 26,
	[2] = 25,
	[3] = 24,
	[4] = 23,
	[5] = 22,
	[6] = 21,
}
--血量更新
function wnd_fiveFightHegemony:updateHp(curHp, node)
	local boss = node
	local cfg = i3k_db_five_contend_hegemony.cfg
	local curHp = curHp and curHp or cfg.npcHp
	local bloodlayer = math.ceil(curHp * 6 / cfg.npcHp)
	bloodlayer = bloodlayer == 0 and 1 or bloodlayer
	boss.bloodBar:setImage(g_i3k_db.i3k_db_get_icon_path(bloodLayerIconsId[bloodlayer]))
	boss.bloodNext:setImage(g_i3k_db.i3k_db_get_icon_path(bloodLayerIconsId[bloodlayer-1]))
	boss.bloodNext:setVisible(bloodlayer ~= 1)
	boss.bloodBar:setPercent((curHp-cfg.npcHp*(bloodlayer-1)/6)/(cfg.npcHp/6)*100)
	boss.bloodLabel:show()
	boss.bloodLabel:setText("x" .. bloodlayer)
end

--设置战报 --isLoad 初始化所有战报
function wnd_fiveFightHegemony:setWarReport(info, isLoad)
	local scroll = self._layout.vars.scroll
	local children = scroll:getAllChildren()
	local hegemonyInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
	--local roleInfo = g_i3k_game_context:getFiveHegemonyInfo()
	if not isLoad then
		if info and info.skillInfo and info.round ~= #children then
			local item = require("ui/widgets/wjzbt")()
			self:setWarReportItem(item, info, self._selectSkill)
			scroll:addItem(item)
			scroll:jumpToChildWithIndex(#children)
			self:setNpcHp(info)
		end
	else
		if hegemonyInfo then
			local chooseResults =  hegemonyInfo.chooseResults
			local chooseRoleSkill = hegemonyInfo.roleInfo and hegemonyInfo.roleInfo.rightCnt
			for k, v in ipairs(chooseResults) do
				local item
				if k > #children then
					item = require("ui/widgets/wjzbt")()
				else
					item = children[k]
				end
					
				local right = false
				if chooseRoleSkill then
					for i, j in pairs(chooseRoleSkill) do
						if k == i then
							right = j
							break
						end
					end
				end
				self:setWarReportItem(item, v, nil, right)
				if k > #children then scroll:addItem(item)	end		
			end
			if #children > #chooseResults then
				local itemNum = #children
				local warReportNum = #chooseResults + 1
				for k =  warReportNum, itemNum do
					scroll:removeChildAtIndex(k)
				end
			end
			scroll:jumpToChildWithIndex(#children)
		end
	end
end

--设置npc hp
function wnd_fiveFightHegemony:setNpcHp(info)
	local hegemonyInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
	if hegemonyInfo then
		local npcHp1 = hegemonyInfo.npcInfo[1].curBlood
		local npcHp2 = hegemonyInfo.npcInfo[2].curBlood
		npcHp1 = npcHp1 - info.skillInfo[2].damage
		npcHp2 = npcHp2 - info.skillInfo[1].damage
		self:updateHp(npcHp1, self._hpNode[1])
		self:updateHp(npcHp2, self._hpNode[2])
		hegemonyInfo.npcInfo[1].curBlood = npcHp1
		hegemonyInfo.npcInfo[2].curBlood = npcHp2
	end
	
	
	self:refreshNpcIcon(hegemonyInfo.npcInfo)
end

--设置战报item
function wnd_fiveFightHegemony:setWarReportItem(item, info, chooseSkillID, isRight)
	local skillCfg = i3k_db_five_contend_hegemony.skills
	local iconCfg = i3k_db_five_contend_hegemony.restraintIcon
	local widgets = item.vars
	local nopcIndex = self:getSupportPosition()
	for i, v in ipairs(info.skillInfo) do
		--v.skillID
		local damageIndex = #info.skillInfo - i + 1
		widgets["skillIcon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg[v.skillID].icon))
		--v.damage
		widgets["damage"..damageIndex]:setText("-"..v.damage)
		if chooseSkillID and chooseSkillID == v.skillID  then
			--caidui
			widgets["right"..i]:setVisible(true)
		else
			widgets["right"..i]:setVisible(false)
		end
		if isRight and nopcIndex == i then
			widgets["right"..i]:setVisible(true)
		end
	end
	widgets.round:setText(i3k_get_string(17823, info.round))
	if skillCfg[info.skillInfo[1].skillID].skillType == skillCfg[info.skillInfo[2].skillID].skillType then --1 相克 2 相平 ， 3 被克
		widgets.state:setImage(g_i3k_db.i3k_db_get_icon_path(iconCfg[2].restraintIcon)) --icon iconCfg[2].restraintIcon		
	elseif skillCfg[info.skillInfo[1].skillID].restraintType == skillCfg[info.skillInfo[2].skillID].skillType then
		widgets.state:setImage(g_i3k_db.i3k_db_get_icon_path(iconCfg[1].restraintIcon)) 
		--iconCfg[1].restraintIcon
	else
		widgets.state:setImage(g_i3k_db.i3k_db_get_icon_path(iconCfg[3].restraintIcon))
		--iconCfg[3].restraintIcon
	end
end

--刷新头像显示
function wnd_fiveFightHegemony:refreshNpcIcon(info)
	local widgets = self._layout.vars
	if not info  then
		local hegemonyInfo  = g_i3k_game_context:getFiveHegemonyManagerInfo()
		if hegemonyInfo then
			info = hegemonyInfo.npcInfo
		end
	end
	if not info or self._supportNpc == 0 then return end
	for k = 1, 2, 1 do
		local npcInfo = info[k]
		local npcCfg = i3k_db_five_contend_hegemony.npcRole[npcInfo.npcID]
		local Index = 1 + #info - k 
		if npcInfo.curBlood > info[Index].curBlood then
			widgets["npcIcon"..k]:setImage((g_i3k_db.i3k_db_get_icon_path(npcCfg.goodIcon)))
		elseif npcInfo.curBlood == info[Index].curBlood then
			widgets["npcIcon"..k]:setImage((g_i3k_db.i3k_db_get_icon_path(npcCfg.icon))) 
		else
			widgets["npcIcon"..k]:setImage((g_i3k_db.i3k_db_get_icon_path(npcCfg.badIcon))) 
		end
		
	end
end

-----------btn-------------------------------------------------

--打开展示界面
function wnd_fiveFightHegemony:openReward(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FiveHegemonyShow)
	g_i3k_ui_mgr:RefreshUI(eUIID_FiveHegemonyShow)
end

---点击选择答案选项
function wnd_fiveFightHegemony:selectSkill(sender,skillID, isRandom)
	local state = g_i3k_db.i3k_db_get_five_Contend_hegemony_state()
	if not self._supportNpc  or  self._supportNpc == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17824))
	end
	if state == g_FIVE_CONTEND_HEGEMONY_PRESELECTION then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17825))
	end	
	
	if g_i3k_game_context:IsExcNeedShowTip(g_FIVE_HEGEMONY_TYPE) and not isRandom then
		local cfg = g_i3k_game_context:GetUserCfg()
		local function callbackRadioButton(randioButton,yesButton,noButton)
			
		end
		local callback = function(btn, state) 
			if btn then
				if state then
					cfg:SetTipNotShowDay(g_FIVE_HEGEMONY_TYPE, g_i3k_get_day(i3k_game_get_time()))
				end
				i3k_sbean.five_hegemony_choose_skill(self._supportNpc, skillID)
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			else
				if state then
					cfg:SetTipNotShowDay(g_FIVE_HEGEMONY_TYPE, g_i3k_get_day(i3k_game_get_time()))
				end
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			end
		end
		g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex(i3k_get_string(1139), i3k_get_string(1140), i3k_get_string(17826), i3k_get_string(17827), callback, callbackRadioButton)
	else
		i3k_sbean.five_hegemony_choose_skill(self._supportNpc, skillID)
	end
	
end

--支持btn
function wnd_fiveFightHegemony:supportBtn(sender, npcID)
	local curRoundTime, curRound = self:getCurRoundTime()
	local cfg = i3k_db_five_contend_hegemony.cfg
	if cfg.roundCount == curRound and curRoundTime > cfg.guessingTime - cfg.arrangementTime then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17829))
	end
	local fun = function(ok)
		if ok then
			i3k_sbean.five_hegemony_choose_npc(npcID)
		end
	end
	g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(17828), fun)
	
end

--查看属性
function wnd_fiveFightHegemony:showNpcAttribute(sender, npcID)
	g_i3k_ui_mgr:OpenUI(eUIID_FiveHegemonySkill)
	g_i3k_ui_mgr:RefreshUI(eUIID_FiveHegemonySkill, npcID)
end
----------btn--end--------------------------------------------

function wnd_fiveFightHegemony:runOneAction(shootLabel, msg)
	if not msg then
		return
	end
	shootLabel:setText(msg)
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	local posY = shootLabel:getPositionY()
	shootLabel:setPosition(visibleSize.width,posY)
	local randomColor = i3k_db_five_contend_hegemony.shootMsg.color
	shootLabel:setTextColor(randomColor[i3k_engine_get_rnd_u(1,#randomColor)])
	g_i3k_ui_mgr:AddTask(self, {shootLabel}, function(ui)
		if shootLabel then
			local width = shootLabel:getInnerSize().width
			local s = visibleSize.width + width + 50
			local speedMax = i3k_db_five_contend_hegemony.shootMsg.speedMax
			local speedMin = i3k_db_five_contend_hegemony.shootMsg.speedMin
			local v = i3k_engine_get_rnd_f(speedMin,speedMax)
			local t = s / v
			shootLabel:runAction(
				cc.Sequence:create(
					cc.MoveTo:create(t, cc.p(-(width + 50),posY)),
					cc.CallFunc:create(function ()
						table.insert(self._shootMsgItems, shootLabel)
					end)
				)
			)
		end
	end,1)
end

function wnd_fiveFightHegemony:showOneShootMsg(data, isupdate)
	if table.nums(self._shootMsgItems) >=1 then
		if isupdate then table.remove(self._shootMsgData, 1) end
		local shootLabel = table.remove(self._shootMsgItems, 1)
		self:runOneAction(shootLabel, data)
	else
		if not isupdate then table.insert(self._shootMsgData, data) end
	end

end

function wnd_fiveFightHegemony:ctrlShootMsg(state)
	self.shootMsgState = state
	self._layout.vars.shootMsg_btn:setVisible(state)
	if state then		
		self._layout.vars.showMsgBtn:stateToNormal()
	else
		self._layout.vars.showMsgBtn:stateToPressed()
	end

	for i = 1,20,1 do
		local shootLabel = self._layout.vars["shootMsg" .. i]
		shootLabel:setVisible(state)
	end
	--if state then i3k_sbean.five_hegemony_barrage(0) end
end
-----------------------------------弹幕end--------------------
function wnd_fiveFightHegemony:onHide()
	if self._chooseCo then
		g_i3k_coroutine_mgr:StopCoroutine(self._chooseCo)
		self._chooseCo = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_fiveFightHegemony.new();
		wnd:create(layout, ...);
	return wnd;
end
