-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_home_pet_operate = i3k_class("wnd_home_pet_operate", ui.wnd_base)

local PETWIDGET = "ui/widgets/jiayuanshouhut"

function wnd_home_pet_operate:ctor()
	self._listPercent = 0
end

function wnd_home_pet_operate:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.batchBtn:onClick(self, self.onBatchActionBtn)
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_home_pet_operate:refresh()
	self._layout.vars.homeLevel:setText(g_i3k_game_context:GetHomeLandLevel())
	self._layout.vars.kindValue:setText(g_i3k_game_context:gethomelandRelease())
	self:setHomePetScroll()
end

function wnd_home_pet_operate:setHomePetScroll()
	self._layout.vars.scroll:removeAllChildren()
	local petInfo = g_i3k_game_context:getHomePetData()
	for k, v in ipairs(i3k_db_home_pet_pos) do
		local node = require(PETWIDGET)()
		node.vars.petInfoNode:hide()
		node.vars.canUnlockNode:hide()
		node.vars.lockNode:hide()
		if petInfo[k] then
			node.vars.petInfoNode:show()
			if petInfo[k].curPet == 0 then
				node.vars.moodIcon:hide()
				node.vars.loading:hide()
				node.vars.rewardNode:hide()
				node.vars.findwayBtn:hide()
				node.vars.name:hide()
				node.vars.playTimes:hide()
				node.vars.changeText:setText(i3k_get_string(17885))
			else
				local petName = g_i3k_game_context:getPetName(petInfo[k].curPet)
				local trueName = petName ~= "" and petName or i3k_db_mercenaries[petInfo[k].curPet].name
				local moodCfg = g_i3k_db.i3k_db_get_home_pet_mood_icon(petInfo[k].mood)
				if g_i3k_game_context:getPetWakenUse(petInfo[k].curPet) then
					node.vars.petHead:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_mercenariea_waken_property[petInfo[k].curPet].headIcon, true))
				else
					node.vars.petHead:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_mercenaries[petInfo[k].curPet].icon, true))
				end
				node.vars.petHeadBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[petInfo[k].curPet].rank))
				node.vars.moodIcon:setImage(g_i3k_db.i3k_db_get_icon_path(moodCfg.moodIcon))
				node.vars.moodIcon:onClick(self, self.onMoodTip, moodCfg)
				node.vars.findwayBtn:onClick(self, self.onFindwayBtn, k)
				node.vars.name:setText(trueName)
				node.vars.playTimes:setText(petInfo[k].daySelfActionTime.."/"..i3k_db_home_pet.common.masterPlayTimes)
				if petInfo[k].mood >= i3k_db_home_pet.common.petMaxMood then
					node.anis.c_bx3.play()
					node.vars.rewardBtn:onClick(self, self.onRewardBtn, {id = k, name = trueName})
				else
					node.anis.c_bx3.stop()
					node.vars.rewardBtn:onClick(self, self.onShowRewardBtn, trueName)
				end
				node.vars.loading:setPercent(petInfo[k].mood / i3k_db_home_pet.common.petMaxMood * 100)
				node.vars.changeText:setText(i3k_get_string(17886))
			end
			node.vars.changeBtn:onClick(self, self.onChangeBtn, k)
		elseif v.needHomeLevel <= g_i3k_game_context:GetHomeLandLevel() then
			node.vars.canUnlockNode:show()
			node.vars.lockBtn:onClick(self, self.onUnlockBtn, k)
			node.vars.changeBtn:hide()
		else
			node.vars.lockNode:show()
			node.vars.needLevel:setText(i3k_get_string(17847, v.needHomeLevel))
			node.vars.changeBtn:hide()
		end
		self._layout.vars.scroll:addItem(node)
	end
	self._layout.vars.scroll:jumpToListPercent(self._listPercent)
end

function wnd_home_pet_operate:onUnlockBtn(sender, id)
	self._listPercent = self._layout.vars.scroll:getListPercent()
	i3k_sbean.homeland_pet_position_open(id)
end

function wnd_home_pet_operate:onMoodTip(sender, moodCfg)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17836, moodCfg.name))
end

function wnd_home_pet_operate:onChangeBtn(sender, id)
	self._listPercent = self._layout.vars.scroll:getListPercent()
	local petInfo = g_i3k_game_context:getHomePetData()
	local callback = function(isOk)
		if isOk then
			g_i3k_ui_mgr:OpenUI(eUIID_HomePetChoose)
			g_i3k_ui_mgr:RefreshUI(eUIID_HomePetChoose, id)
		end
	end
	if petInfo and petInfo[id] and petInfo[id].curPet ~= 0 and petInfo[id].mood > 0 then
		if petInfo[id].mood >= i3k_db_home_pet.common.petMaxMood then
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17851), callback)
		else
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17850), callback)
		end
	else
		callback(true)
	end
end

function wnd_home_pet_operate:onFindwayBtn(sender, id)
	local targetMapId = g_i3k_game_context:GetWorldMapID()
	local pos = i3k_db_home_pet_pos[id].pos
	g_i3k_game_context:SeachPathWithMap(targetMapId, pos, nil, nil,nil, nil, nil, nil, nil)
	self:onCloseUI()
end

function wnd_home_pet_operate:onBatchActionBtn(sender)
	self._listPercent = self._layout.vars.scroll:getListPercent()
	local petInfo = g_i3k_game_context:getHomePetData()
	local havePet = false
	local canBatch = false
	for k, v in pairs(petInfo) do
		if v.curPet ~= 0 then
			havePet = true
			if v.daySelfActionTime < i3k_db_home_pet.common.masterPlayTimes then
				canBatch = true
				break
			end
		end
	end
	if havePet then
		if canBatch then
			local callback = function(isOk)
				if isOk then
					i3k_sbean.homeland_pet_position_onekey_action()
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17852, i3k_db_home_pet.patchPlay.count), callback)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17871))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17883))
	end
end

function wnd_home_pet_operate:onRewardBtn(sender, data)
	local callback = function(isOk)
		if isOk then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomePetOperate, "onFindwayBtn", nil, data.id)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17853, data.name), callback)
end

function wnd_home_pet_operate:onShowRewardBtn(sender, name)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17842, name))
end

function wnd_home_pet_operate:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17857))
end

function wnd_create(layout)
	local wnd = wnd_home_pet_operate.new()
	wnd:create(layout)
	return wnd
end