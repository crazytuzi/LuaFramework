-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battle_treasure = i3k_class("wnd_battle_treasure", ui.wnd_base)

local imageTable = {
	xun = 1652,
	wa  = 1653,
	hua = 1654,
}

function wnd_battle_treasure:ctor()

end

function wnd_battle_treasure:configure()
	self.targetMapId = 0
	self.targetPos = {x=0, y=0, z=0}
	self.isUpdate = false

	self.targetType = 0
end

function wnd_battle_treasure:onShow()

end

function wnd_battle_treasure:refresh()
	self.neverToPlace = true
	self.radius = i3k_db_treasure_base.other.radius/100
	local operationBtn = self._layout.vars.operationBtn
	local transBtn = self._layout.vars.transBtn

	local mapType = i3k_game_get_map_type()

	local mapInfo = g_i3k_game_context:getTreasureMapInfo()
	if mapInfo and mapInfo.open~=0 and mapType==g_FIELD then
		local mapCfg = i3k_db_treasure[mapInfo.mapID]
		local spotTable = mapCfg.clueSpotList
		local spotCfg
		local pointIndex = 0
		for i,v in ipairs(mapInfo.points) do
			if v==0 then
				pointIndex = i
				spotCfg = i3k_db_spot_list[spotTable[i]]
				self._layout.anis.c_box.quit()
				self._layout.vars.takeBtn:hide()
				self._layout.vars.findRoot:show()
				break
			elseif v==1 and not mapInfo.points[i+1] then
				self._layout.vars.findRoot:hide()
				self._layout.vars.takeBtn:show()
				self._layout.anis.c_box.play()
				self._layout.vars.takeBtn:onClick(self, self.onTrans)
				return
			end
		end
		local nowMapId = g_i3k_game_context:GetWorldMapID()
		local hero = i3k_game_get_player_hero()
		local curPos = hero._curPosE
		local targetPos = {x = hero._curPosE.x, y = hero._curPosE.y, z = hero._curPosE.z}
		local targetMapId = nowMapId
		local isDialogue = false--判断对话任务是否目标在本地图
		local spotType, id = spotCfg.spotType, spotCfg.arg1
		self.targetType = spotType
		local dis = 0

		operationBtn:show()
		operationBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imageTable.xun))
		operationBtn:setTag(imageTable.xun)

		if spotType==g_KILL_MONSTER then
			targetPos = g_i3k_db.i3k_db_get_monster_pos(id)
			targetMapId = g_i3k_db.i3k_db_get_monster_map_id(id)
			if targetMapId==nowMapId then
				dis = i3k_vec3_dist(curPos, targetPos)
				if dis<=self.radius then
					operationBtn:hide()
				end
			end

			self._layout.vars.descLabel:setText(spotCfg.name)
			local monsterName = g_i3k_db.i3k_db_get_monster_name(id)
			self._layout.vars.taskNameLabel:setText(i3k_get_string(15059, monsterName))
		elseif spotType==g_DIALOGUE then
			targetMapId = g_i3k_db.i3k_db_get_npc_map_id(id)
			if targetMapId==nowMapId then
				isDialogue = true
				operationBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imageTable.hua))
				operationBtn:setTag(imageTable.hua)
			else
				targetPos = i3k_db_dungeon_base[targetMapId].revivePos
			end
			self._layout.vars.taskNameLabel:setText(spotCfg.name)
			self._layout.vars.descLabel:setText(i3k_get_string(15061))
			operationBtn:show()
		elseif spotType==g_DIG then
			self._layout.vars.taskNameLabel:setText(spotCfg.name)
			targetPos = i3k_db_dungeon_base[id].revivePos
			targetPos.x = spotCfg.arg2
			targetPos.z = spotCfg.arg3
			self.radius = spotCfg.arg4/100
			targetMapId = id

			if targetMapId==nowMapId then
				operationBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imageTable.wa))
				operationBtn:setTag(imageTable.wa)
			end
			self._layout.vars.descLabel:setText(i3k_get_string(15060))
		else
			self._layout.vars.taskNameLabel:setText(spotCfg.name)
			targetPos = g_i3k_db.i3k_db_get_npc_pos(id)
			targetMapId = g_i3k_db.i3k_db_get_npc_map_id(id)
			if targetMapId==nowMapId then
				dis = i3k_vec3_dist(curPos, targetPos)
				if dis<=self.radius then
					operationBtn:hide()
				end
			end
			self._layout.vars.descLabel:setText(i3k_get_string(15062))
		end

		transBtn:onClick(self, self.onTrans)
		operationBtn:onClick(self, self.operation, {mapId = targetMapId, pos = targetPos, pointIndex = pointIndex, mapDialogue = isDialogue})

		self.targetMapId = targetMapId
		self.targetPos = targetPos
		self.isUpdate = true

		--self:show()
	else
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTreasure)
		return
	end

	local guideArrow = self._layout.vars.guide
	guideArrow:setVisible(self.targetType == g_DIG and g_i3k_game_context:GetWorldMapID() == self.targetMapId)

end


function wnd_battle_treasure:updateSceneGuideDir(dir, distance) -- InvokeUIFunction
	local r = i3k_db_common.digmine.DigMineDistance / 100
	local guideArrow = self._layout.vars.guide
	if distance > r * r then
		guideArrow:show();
		guideArrow:setImage(g_i3k_db.i3k_db_get_icon_path(6264))
		guideArrow:setRotation(math.deg(dir))
	else
		guideArrow:setImage(g_i3k_db.i3k_db_get_icon_path(6263))
		guideArrow:setRotation(math.deg(0))
	end
end


function wnd_battle_treasure:setFuncBtnEnabled(isEnabled)
	self._layout.vars.operationBtn:setTouchEnabled(isEnabled)
end

function wnd_battle_treasure:onTrans(sender)
	g_i3k_logic:OpenWithTreasure()
end

function wnd_battle_treasure:operation(sender, needValue)
	local spotType=sender:getTag()
	if spotType==imageTable.xun then
		if needValue.mapDialogue then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15069))
		else
--			g_i3k_game_context:SeachBestPathWithMap(needValue.mapId, needValue.pos)
			g_i3k_game_context:SeachPathWithMap(needValue.mapId, needValue.pos)
		end
	elseif spotType==imageTable.hua then
		self:setFuncBtnEnabled(false)
		i3k_sbean.explore_spot(needValue.pointIndex)
	elseif spotType==imageTable.wa then
		self:setFuncBtnEnabled(false)
		i3k_sbean.explore_spot(needValue.pointIndex)
	end
end

function wnd_battle_treasure:findPath(sender, needValue)
	--g_i3k_ui_mgr:CloseAllOpenedUI(eUIID_BattleBase)
--	g_i3k_game_context:SeachBestPathWithMap(needValue.mapId, needValue.pos)
	g_i3k_game_context:SeachPathWithMap(needValue.mapId, needValue.pos)
end

function wnd_battle_treasure:onUpdate(dTime)
	--挖和秘匣需要固定位置，杀怪寻路之后不需要在提示寻路
	if self.targetType == g_DIG and g_i3k_game_context:GetWorldMapID() == self.targetMapId then
		local world = i3k_game_get_world()
		world:ChangeTreasureGuideDir(self.targetPos)
	end
	if self.isUpdate then
		local xun = 1652
		local wa  = 1653
		local hua = 1654
		local hero = i3k_game_get_player_hero()
		local nowMapId = g_i3k_game_context:GetWorldMapID()
		if hero and g_i3k_game_context and g_i3k_game_context:IsHeroMove() and self.targetMapId==nowMapId then--当所处地图为目标地图时
			local dis = i3k_vec3_dist(hero._curPosE, self.targetPos)
			local operationBtn = self._layout.vars.operationBtn
			if operationBtn:getTag()==xun then
				if dis>self.radius and self.neverToPlace then
					--operationBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imageTable.xun))
					--operationBtn:setTag(imageTable.xun)
				else
					self.neverToPlace = false
					if self.targetType==g_KILL_MONSTER then
						operationBtn:hide()
					elseif self.targetType==g_DIG then
						operationBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imageTable.wa))
						operationBtn:setTag(wa)

					elseif self.targetType==g_DIALOGUE then
						operationBtn:setImage(g_i3k_db.i3k_db_get_icon_path(imageTable.hua))
						operationBtn:setTag(hua)
					else
						operationBtn:hide()
					end
				end
			end
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_battle_treasure.new()
	wnd:create(layout, ...)
	return wnd;
end
