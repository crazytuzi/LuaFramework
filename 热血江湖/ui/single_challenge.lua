
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_single_challenge = i3k_class("wnd_single_challenge",ui.wnd_base)

local NOT_OPEN_STATE 	= 1 --未开启
local PLAY_STATE 		= 2 --正在进行
local FINISH_STATE 		= 3 --已结束
local NO_SELECT_STATE 	= 4 --不能选择

--线条暗和亮
local lineImg = {6238, 6239}
--状态图片
local stateImg = {6240, 6241, 6242, 6240}
--文字颜色
local textColor = {"ff929294", "ffffffff", "ffffffff", "ff929294"}
--文字描边
local textOutline = {"ff051022", "ffb96721", "ff1e4481", "ff051022"}

function wnd_single_challenge:ctor()
	self._id = 0
	self._info = {}
	self._enterGroupId = 0
	self._enterNpcGroupId = {}
end

function wnd_single_challenge:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.ui = widgets

	self.ui.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17221))
	end)

	self.stage = {}
	for i = 1, 6 do
		self.stage[i] = {
			bg = widgets["bg" .. i],
	      	name = widgets["name" .. i],
	        btn  = widgets["btn" .. i],
	        isFinish = widgets["isFinish" .. i],
	        selectBg = widgets["select" .. i],
	        animation = self._layout.anis["c_jh0"..i],
        }
	end

	self.line = {}
	for i = 1, 5 do
		self.line[i] = widgets["line" .. i]
	end

	self.ui.startBtn:onClick(self, self.onStart)
	self.ui.petBtn:onClick(self, self.onChoosePet)
end

function wnd_single_challenge:refresh(id, info)
	self._id = id
	self._info = info

	if info.curMapGroup == 0 then
		local curMapGroup = i3k_db_single_challenge_cfg[id].startPoint
		local groupInfo = g_i3k_db.i3k_db_get_single_challenge_groupInfo(curMapGroup)
		self._info = 
		{
			curMapGroup = curMapGroup,
			curNpcMapGroup = groupInfo.npcGroupId[1],
			isFinish = info.isFinish or 0,
			buffs = info.buffs or {},
			buffIndex = info.buffIndex or {},
			pets = info.pets or {},
		}
	end
	local groupInfo = g_i3k_db.i3k_db_get_single_challenge_groupInfo(self._info.curMapGroup)

	self._enterGroupId = self._info.curMapGroup
	self._enterNpcGroupId = groupInfo.npcGroupId

	if self._info.isFinish > 0 then
		if #groupInfo.nextGroupId == 1 then  --如果下一层只有一关,自动选择下一关
			self._enterGroupId = groupInfo.nextGroupId[1]
			self._enterNpcGroupId = groupInfo.npcGroupId
			groupInfo = g_i3k_db.i3k_db_get_single_challenge_groupInfo(groupInfo.nextGroupId[1])
		end
	end

	self:updateFinishState()
	self:updateLineState()
	self:updateBuffList()

	self:chooseStage(nil, groupInfo)

	g_i3k_game_context:SetSingleChallengePets(self._info.pets)
end

function wnd_single_challenge:updateFinishState()
	local mapGroup = i3k_db_single_challenge_cfg[self._id].startPoint

	for _, v in ipairs(self.stage) do
		local groupInfo = g_i3k_db.i3k_db_get_single_challenge_groupInfo(mapGroup)
		local state = self:getChallengeState(groupInfo)
		if state == PLAY_STATE then
			v.animation.play()
		end
		v.bg:setImage(g_i3k_db.i3k_db_get_icon_path(stateImg[state]))
		v.name:setText(groupInfo.challengeName)
		v.name:setTextColor(textColor[state])
		v.name:enableOutline(textOutline[state])
		v.isFinish:setVisible(self:getFinishState(mapGroup))
		v.btn:onClick(self, self.chooseStage, groupInfo)
		v.mapGroup = mapGroup
		v.state = state

		mapGroup = mapGroup + 1
	end
end

function wnd_single_challenge:updateLineState()
	local mapGroup = i3k_db_single_challenge_cfg[self._id].startPoint
	local lineID = 0

	for _, v in ipairs(self.line) do
		mapGroup = mapGroup + 1

		if self:isFinalGroup(mapGroup) then
			lineID = self._info.curMapGroup == mapGroup and lineImg[2] or lineImg[1]
		else
			lineID = self:getFinishState(mapGroup - 1) and lineImg[2] or lineImg[1]
		end
		v:setImage(g_i3k_db.i3k_db_get_icon_path(lineID))
	end
end

--获得关卡完成状态
function wnd_single_challenge:getFinishState(mapGroup)
	local isFinish = false
	if self._info.isFinish > 0 then
		if not self:isCanChallenge(mapGroup) then
			if mapGroup == self._info.curMapGroup then
				isFinish = true
			elseif mapGroup < self._info.curMapGroup then
				if not self:isFinalGroup(mapGroup) then
					isFinish = true
				end
			end
		end
	else
		if not self:isFinalGroup(mapGroup) then
			if mapGroup < self._enterGroupId then
				isFinish = true
			end
		end
	end
	return isFinish
end

--该关卡是否可以挑战
function wnd_single_challenge:isCanChallenge(mapGroup)
	local curGroupInfo = g_i3k_db.i3k_db_get_single_challenge_groupInfo(self._info.curMapGroup)
	local nextGroupId = curGroupInfo.nextGroupId  --vector
	if g_i3k_game_context:vectorContain(nextGroupId, mapGroup) then
		return true
	end
	return false
end

--该关卡是否是最后一关
function wnd_single_challenge:isFinalGroup(mapGroup)
	local selectGroupInfo = g_i3k_db.i3k_db_get_single_challenge_groupInfo(mapGroup)
	return #selectGroupInfo.nextGroupId == 0
end

function wnd_single_challenge:getChallengeState(groupInfo)
	local mapGroup = groupInfo.groupId
	local state = NOT_OPEN_STATE

	if self._info.isFinish > 0 then
		if self:isCanChallenge(mapGroup) then
			state = PLAY_STATE
		else
			if mapGroup == self._info.curMapGroup then
				state = FINISH_STATE
			elseif mapGroup < self._info.curMapGroup then
				if self:isFinalGroup(mapGroup) then
					state = NOT_OPEN_STATE
				else
					state = FINISH_STATE
				end
			else
				state = NOT_OPEN_STATE
			end
		end
	else
		if mapGroup == self._enterGroupId then
			state = PLAY_STATE
		else
			if self:isFinalGroup(self._info.curMapGroup) and self:isFinalGroup(mapGroup) then
				state = NO_SELECT_STATE
			else
				if mapGroup > self._enterGroupId then
					state = NOT_OPEN_STATE
				else
					state = FINISH_STATE
				end
			end
		end
	end
	return state
end

function wnd_single_challenge:chooseStage(sender, groupInfo)
	self.ui.tips:show()
	self.ui.startBtn:disableWithChildren()

	self.ui.curName:setText(groupInfo.challengeName)
	self.ui.curDesc:setText(groupInfo.challengeDesc)
	
	local mapGroup = groupInfo.groupId

	for _, v in ipairs(self.stage) do
		v.selectBg:setVisible(mapGroup == v.mapGroup)
	end

	if self._info.isFinish > 0 and self:isFinalGroup(self._info.curMapGroup) then
		self.ui.tips:setText(i3k_get_string(17219))
	else
		local state = self:getChallengeState(groupInfo)
		if state == NOT_OPEN_STATE then
			self.ui.tips:setText("本关卡尚未开启")
		elseif state == PLAY_STATE then
			self.ui.tips:hide()
			self.ui.startBtn:enableWithChildren()
			self._enterGroupId = mapGroup
			self._enterNpcGroupId = groupInfo.npcGroupId
		elseif state == FINISH_STATE then
			self.ui.tips:setText("本关卡已完成")
		elseif state == NO_SELECT_STATE then
			self.ui.tips:setText(i3k_get_string(17220))
		end
	end
end

function wnd_single_challenge:updateBuffList()
	local info = self._info
	self.ui.buffList:removeAllChildren()
	self.ui.buffList:stateToNoSlip()

	for i = 1, 5 do
		local ui = require("ui/widgets/danrenchuangguant")()
		local icon = 0
		local buffId = info.buffIndex[i]  --获取buffId
		local buffCfg = g_i3k_db.i3k_db_get_single_challenge_buffInfo(buffId)
		if buffCfg then
			icon = buffCfg.activeIcon
			ui.vars.grayImg:setVisible(info.buffs[buffId] == 0)
			local desc = (info.buffs[buffId] == 0) and buffCfg.buffInactiveDesc or buffCfg.buffDesc
			ui.vars.btn:onClick(self, self.onShowBuffInfo, desc)
		else
			ui.vars.grayImg:hide()
			icon = i3k_db_single_challenge_cfg[self._id].sealIconId
		end
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		self.ui.buffList:addItem(ui)
	end
end

function wnd_single_challenge:onShowBuffInfo(sender, desc)
	local pos = sender:getPosition()
	pos = sender:getParent():convertToWorldSpace(pos)

	g_i3k_ui_mgr:CloseUI(eUIID_SingleBuffTips)
	g_i3k_ui_mgr:OpenUI(eUIID_SingleBuffTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_SingleBuffTips, desc, pos)
end

function wnd_single_challenge:onStart(sender)
	local function func1()
		local function func()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SingleChallenge, "startCB")
		end
		g_i3k_game_context:CheckMulHorse(func)
	end

	local desc = i3k_get_string(17218)
	local callback = (function(ok)
	    if ok then
	    	func1()
	    end
	end)

	local canPlayCnt = 0
	for _, v in ipairs(self.stage) do
		if v.state == PLAY_STATE then
			canPlayCnt = canPlayCnt + 1
		end
	end
	if canPlayCnt > 1 then  --超过1个可以选择的关卡 就需要弹出关卡选择
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		func1()
	end
end

function wnd_single_challenge:startCB()
	local hero_lvl = g_i3k_game_context:GetLevel()

	local func3 = function () -- 随从
		local mapGroup = i3k_db_single_challenge_cfg[self._id].startPoint  --起始节点
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local count = table.nums(g_i3k_game_context:GetSingleChallengePets())
		local have = 0
		for k,v in pairs(allPets) do
			have = have + 1
		end
		local max_count = 1
		local first = g_i3k_db.i3k_db_get_common_cfg().posUnlock.first
		local second = g_i3k_db.i3k_db_get_common_cfg().posUnlock.second
		local third = g_i3k_db.i3k_db_get_common_cfg().posUnlock.third
		if hero_lvl >= third then
			max_count = 3
		elseif hero_lvl >= second then
			max_count = 2
		end
		if count < max_count and have - count > 0 and self._enterGroupId == mapGroup then
			local fun = (function(ok)
				if ok then
					g_i3k_ui_mgr:OpenUI(eUIID_SuicongDungeonPlay)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuicongDungeonPlay, self._id)
				else
					self:enterDungeon()
				end
			end)
			local desc = i3k_get_string(286)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			return
		else
			self:enterDungeon()
		end
	end

	local func2 = function ()  --队伍
		if g_i3k_game_context:IsInRoom() then -- 房间状态
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
			return
		end
		if g_i3k_game_context:getMatchState() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
			return
		end
		local teamId = g_i3k_game_context:GetTeamId()
		if teamId ~= 0 then
			local fun = (function(ok)
				if not ok then
					return
				else
					func3()
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(68), fun)
			return
		else
			func3()
			return
		end
	end

	func2()
end

function wnd_single_challenge:enterDungeon()
	local fun = function(ok)
		if ok then
			g_i3k_game_context:ClearFindWayStatus()
			i3k_sbean.single_explore_start(self._id, self._enterGroupId, self._enterNpcGroupId)
		end
	end
	g_i3k_game_context:CheckJudgeEmailIsFull(fun, true)
end

function wnd_single_challenge:onChoosePet(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SuicongDungeonPlay)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuicongDungeonPlay, self._id)
end

function wnd_create(layout, ...)
	local wnd = wnd_single_challenge.new()
	wnd:create(layout, ...)
	return wnd;
end

