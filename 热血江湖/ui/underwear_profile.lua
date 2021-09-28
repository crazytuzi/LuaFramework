-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_underwear_profile = i3k_class("wnd_underwear_profile",ui.wnd_base)

--开始点击事件和结束时间
local startTime
local endTime
--开始位置和结束位置
local startPos
local endPos
local dis --距离
local speed --速度 
local time --时间

function wnd_underwear_profile:ctor()
	self.revolve = nil --旋转模型的btn
	self.talentRp = nil
	self.forgeRp = nil
	self.upgradeRp = nil
	-- self.lang_up_items = nil
end

function wnd_underwear_profile:configure()

end


function wnd_underwear_profile:onRotateBtn(sender, eventType)
	if eventType == ccui.TouchEventType.began then
		self.rotate = self.hero_module:getRotation()
		self.hero_module:setRotation(self.rotate.y)
		startTime = i3k_game_get_time()
		startPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	else
		endPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
		endTime = i3k_game_get_time()
		self:getRotate()
		if eventType==ccui.TouchEventType.ended then
			self.indexData = 0
		end
	end
end

function wnd_underwear_profile:getRotate()
	local btnPos = self.revolve:getPosition()
	local btnContentSize = self.revolve:getContentSize()
	local minPosX = btnPos.x - btnContentSize.width / 2
	local maxPosX = btnPos.x + btnContentSize.width / 2
	if endPos.x < minPosX then
		endPos.x = minPosX
	elseif endPos.x > maxPosX then
		endPos.x = maxPosX
	end
	dis = endPos.x - startPos.x
	time = endTime - startTime
	speed = dis / time
	local angel = self.rotate.y + math.rad(-dis)
	self.hero_module:setRotation(angel)
	
	self.indexData = self.indexData or 0
	
	-- if math.abs(math.floor(speed)) > 1000 then --速度过快播放眩晕动作
	-- 	if self.indexData<1 then
	-- 		self.indexData = self.indexData + 1
	-- 		local action = i3k_db_common.engine.swoonEffect
	-- 		self.hero_module:pushActionList(action, 1)
	-- 		self.hero_module:pushActionList("stand", -1)
	-- 		self.hero_module:playActionList()
	-- 	end
	-- end
end

function wnd_underwear_profile:ShowRedPoint(index, info)
	self.talentRp:hide()
	self.forgeRp:show()
	self.upgradeRp:hide()
	self.runeRp:hide()

	local upgradeCfg = i3k_db_under_wear_update[index]
	if info.underwear_level < #upgradeCfg then
		local upg = upgradeCfg[info.underwear_level].updateProp
		for i = 1 , #upg do
			if g_i3k_game_context:GetCommonItemCount(upg[i]) > 0 then
				self.upgradeRp:show()
				break
			end
		end
	end

	if info.underwear_stage < #i3k_db_under_wear_upStage[index] then
		local stageCfg = i3k_db_under_wear_upStage[index][info.underwear_stage]
		for i = 1 , 2 do
			local itemid = stageCfg[string.format("upStageTakeId%s",i)]
			if g_i3k_game_context:GetCommonItemCanUseCount(itemid)<stageCfg[string.format("upStageTakeValue%s",i)] then
				self.forgeRp:hide()
				break
			end
		end
	else
		self.forgeRp:hide()
	end

	local totalPoint = 0
	for i=1 ,self.tab.underwear_level do
		totalPoint = totalPoint + upgradeCfg[i].talentPoint
	end
	local useTalentPoint = 	g_i3k_game_context:getAnyUnderWearAnyData(index,"useTalentPoint")
	if totalPoint > useTalentPoint then
		self.talentRp:show()
	end

	if self:getUnderWearRuneNeedRed(index) then
		self.runeRp:show()
	end
end

function wnd_underwear_profile:runeInBag()
	local runeItemTab = {}
	local _canSave = false
	local _,items = g_i3k_game_context:GetBagInfo()	
	for k ,v in pairs(items) do 
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(k)
		if  item_cfg and item_cfg.type == UseItemRune then    --存入（符文背包）
			runeItemTab[k] = v.count
			_canSave = true
		end
	end
	return _canSave, runeItemTab
end

function wnd_underwear_profile:setUnderWearRuneNeedRed(index, RedPoint)
	local cur_level = g_i3k_game_context:GetLevel()
	local totalFeats = g_i3k_game_context:getForceWarAddFeat()
	local heroPower = i3k_game_get_player_hero():Appraise()

	local cfg = i3k_db_under_wear_slot[index]
	local cfgOne = nil
	oneRed = RedPoint[index]

	for i, data in ipairs(g_i3k_game_context:getAnyUnderWearAnyData(index,"soltGroupData")) do
		cfgOne = cfg[i]
		if data.unlocked ~= 1 then
			local isbreak = false
			if cur_level >= cfgOne.unlockNeedLvl and heroPower >= cfgOne.unlockNeedPower and totalFeats >= cfgOne.unlockNeedWuXun then
				for i2 = 1, 4 do
					local itemId = cfgOne[string.format("unlockNeedItemId%d", i2)]
					if itemId ~= 0 then
						if cfgOne[string.format("unlockNeedItemCount%d", i2)] > g_i3k_game_context:GetCommonItemCanUseCount(itemId) then
							isbreak = true
							break
						end
					end
				end

				if not isbreak then
					oneRed[i] = 0
				else
					oneRed[i] = nil
				end
			end
		end
		
		if data.unlocked == 1 and (not RedPoint[index] or not RedPoint[index][i]) then
			local count = 0
			for k,v in ipairs(data.solts) do
				if v ~= 0 then
					count = count + 1
				end
			end
			if count < cfgOne.slotAmount then
				oneRed[i] = 0
			else
				oneRed[i] = 1
			end
		end
	end
end

function wnd_underwear_profile:getUnderWearRuneNeedRed(index)
	local cur_level = g_i3k_game_context:GetLevel() or 0
	if g_i3k_game_context:GetLevel() < i3k_db_under_wear_alone.underWearRuneOpenLvl then
		return false
	end
	local RedPoint = g_i3k_game_context:getRuneRedTip()
	local red = RedPoint[index] or {}
	RedPoint[index] = red
	self:setUnderWearRuneNeedRed(index, RedPoint)

	-- if not self.lang_up_items then
	-- 	self.lang_up_items = {}
	-- 	for i,v in ipairs(i3k_db_under_wear_rune_lang) do
	-- 		self.lang_up_items[i] = {v.slotRuneId1, v.slotRuneId2, v.slotRuneId3, v.slotRuneId4, v.slotRuneId5, v.slotRuneId6}
	-- 	end
	-- end
	--local langCanUp = self:getLangUpRed()

	for i, v in pairs(red) do
		if v == 0 then
			return true
		end
	end

	if self:runeInBag() then
		return true
	end

	if langCanUp then
		return true
	end

	return false
end

function wnd_underwear_profile:getLangUpRed()
	for i = 1 , #self.lang_up_items do
		local nextLvl = g_i3k_game_context:getRuneLangLevel(i) + 1
		if g_i3k_game_context:getUpLangRuneEnough(i, nextLvl, self.lang_up_items[i]) then
			return true
		end
	end
	return false
end

function wnd_create(layout)
	local wnd = wnd_underwear_profile.new()
		wnd:create(layout)
	return wnd
end
