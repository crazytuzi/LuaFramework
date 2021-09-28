module(..., package.seeall)

local require = require;

require("ui/map_set_funcs")
local ui = require("ui/mapUIBase")

wnd_scene_map = i3k_class("wnd_scene_map", ui.wnd_MapBase)

local g_mapSize = nil

-- 帮派夺旗底图背景图片id
local HEIGH_LEVEL_FLAG_UNOCCUPIED = 5125
local LOW_LEVEL_FLAG_OCCUPIED = 5126
local HEIGH_LEVEL_FLAG_OCCUPIED = 5127


function wnd_scene_map:ctor()
	self._pathSpriteTable = {}
	self._targetPos = false
	self._targetPos = nil
	self._curMapID = nil
	self.widgetsTitile = "ui/widgets/sjdtt"
    self.widgetsitem = "ui/widgets/sjdtt2"
	self.BtnState = { true, false, false}
end

function wnd_scene_map:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		-- releaseSchedule()
--		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap, "updateMapInfo")
	end)
	--self._layout.vars.mapImage:setImage(i3k_checkPList("xuanbozhulin.png"))
	self._layout.vars.sceneMapBtn:onClick(self, self.toSceneMap)

	self.flag_icon = self._layout.vars.flag_icon
	self.flag_text = self._layout.vars.flag_text
	self.flag_btn = self._layout.vars.flag_btn
	self.fction_flag_root = self._layout.vars.fction_flag_root
	self.fction_flag_root:hide()

	-- self._layout.vars.targetImg:
end

function wnd_scene_map:onShow()

end

function wnd_scene_map:onHide()
	releaseSchedule()
end

function wnd_scene_map:refresh(mapId)
	local imgPath = g_i3k_db.i3k_db_get_icon_path(i3k_db_field_map[mapId].titleImgId)
	self._layout.vars.titleImage:setImage(imgPath)
	self._curMapID = mapId

	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	--创建小地图，设置地图背景以及按钮
	local node = require("ui/widgets/zdt")()
	local size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local roateAngle = 0
	for i,v in pairs(i3k_db_field_map) do
		if v.id==mapId then
			local img = i3k_checkPList(i3k_db_icons[v.imageId].path)
			local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
			size = heroSprite:getContentSize()
			size = {width = size.width*v.worldMapScale,height = size.height*v.worldMapScale}
			local mapImg = node.vars.image
			self:SetMapImageContentsize(node,size)  --根据是不是PAD设置地图大小
			node.vars.btn:setContentSize(size.width, size.height)
			scroll:addItem(node, true)
			mapImg:setRotation(v.rotate)
			roateAngle = v.rotate
			mapImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.imageId))

			local width = scroll:getContainerSize().width
			local height = scroll:getContainerSize().height
			mapImg:setPositionInScroll(scroll,v.worldMapScaleX*width,v.worldMapScaleY*height)
		end
	end
	local nodeSize = node.vars.image:getContentSize()
	--创建Npc位置点,以及英雄的指针
	local spriteTable = createMap(scroll, nodeSize, mapId, node.vars.image, nowMapId==mapId, nil, roateAngle)
	self._parent = node.vars.image
	local needValue = {size = size, mapId = mapId}
	local sizeImg = node.vars.image:getContentSize()
	local sizeBtn = node.vars.btn:getContentSize()

	node.vars.btn:onClick(self, self.searchPath, needValue)
	-------------右侧NPC以及刷怪区域---------------
	self._size = size
	-- RefreshList(self._layout.vars, mapId, size, self.BtnState[1], self.BtnState[2], self.BtnState[3], self, self.btnName)
	self:RefreshList(mapId, size, self.BtnState[self.NpcList], self.BtnState[self.MonsterList], self.BtnState[self.SpecialMonsterList])
	self:onUpdateFlagData(mapId)
	local targetPos = g_i3k_game_context:getMiniMapTargetPos()
	if targetPos then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		if targetMapId and targetMapId == self._curMapID then
			self:createTargetPos(targetPos, size, targetMapId)
		end
	else
		clearTargetImg()
	end
	
	self:refreshThumbtackImage(mapId)
end

function wnd_scene_map:onUpdateEscortCar()
	updateEscortCar()
end

function wnd_scene_map:onUpdateTeamMate(roleId, mapId, pos)
	updateTeamMate(roleId, mapId, pos)
end


function wnd_scene_map:onUpdateFlagData(mapId)
	self.flag_btn:onClick(self,self.onFlagTips,mapId)
	local roleLine = g_i3k_game_context:GetCurrentLine()
	local flag_data = g_i3k_game_context:GetFactionFlagData()
	if i3k_db_faction_map_flag[mapId] and roleLine == i3k_db_faction_rob_flag.faction_rob_flag.faction_rob_line  then
		self.fction_flag_root:show()
		if flag_data[mapId] and flag_data[mapId].curSect.sectId ~= 0 then
			self.flag_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[flag_data[mapId].curSect.sectIcon].iconid))
			local tmp_str = string.format("%s占领中",flag_data[mapId].curSect.sectName)
			self.flag_text:setText(tmp_str)
		else
			self.flag_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_rob_flag.faction_rob_flag.faction_rob_flag_icon))
			if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(mapId) then
				self.flag_icon:setImage(g_i3k_db.i3k_db_get_icon_path(HEIGH_LEVEL_FLAG_UNOCCUPIED)) -- 高等级未被占领
			end
			self.flag_text:setText("尚无帮派占领")
		end
	else
		self.fction_flag_root:hide()
	end
end

function wnd_scene_map:onFlagTips(sender,mapID)
	local flag_data = g_i3k_game_context:GetFactionFlagData()
	if i3k_db_faction_map_flag[mapID]  then
		if flag_data[mapID] and flag_data[mapID].curSect.sectId ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_FactionRobFlagAward)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionRobFlagAward,flag_data[mapID],mapID)
		else
			--没有人占领 判断是否是开战期
			local serverTime = i3k_integer(i3k_game_get_time())
			if g_i3k_get_day_time(i3k_db_faction_rob_flag.faction_rob_flag.rob_start_time) <= serverTime and
			serverTime < g_i3k_get_day_time(i3k_db_faction_rob_flag.faction_rob_flag.rob_end_time) then
				return g_i3k_ui_mgr:PopupTipMessage("旗帜尚未被占领，请速速占领")
			else
				return g_i3k_ui_mgr:PopupTipMessage("帮派夺旗战尚未开始")
			end
		end
	end
end

function wnd_scene_map:GetTable(task_btn,typeValue,arg,taskType)
	local tag = nil
	local mapID = nil
	local point = nil
	local btnState = false
	if typeValue == g_TASK_KILL then
		btnState = true
		task_btn:enableWithChildren()
		point = g_i3k_db.i3k_db_get_monster_pos(arg);
		mapID = g_i3k_db.i3k_db_get_monster_map_id(arg);
		tag = 3
	elseif typeValue == g_TASK_COLLECT then
		btnState = true
		task_btn:enableWithChildren()
		point = g_i3k_db.i3k_db_get_res_pos(arg);
		mapID = g_i3k_db.i3k_db_get_res_map_id(arg);
		tag = 2
	elseif typeValue == g_TASK_NPC_DIALOGUE then
		btnState = true
		task_btn:enableWithChildren()
		point = g_i3k_db.i3k_db_get_npc_pos(arg);
		mapID = g_i3k_db.i3k_db_get_npc_map_id(arg);

		tag = 1
	elseif typeValue == g_TASK_NEW_NPC_DIALOGUE then
		btnState = true
		task_btn:enableWithChildren()
		point = g_i3k_db.i3k_db_get_npc_pos(arg);
		mapID = g_i3k_db.i3k_db_get_npc_map_id(arg);
		tag = 1
	end
	if btnState == true then
		if taskType==TASK_CATEGORY_MAIN then
			 self._layout.anis.c_zhuxian.play()
		elseif taskType == TASK_CATEGORY_WEAPON then
			self._layout.anis.c_shenbing.play()
		elseif taskType == TASK_CATEGORY_SECT then
			self._layout.anis.c_bangpai.play()
		end
	end
	if typeValue == g_TASK_NPC_DIALOGUE or typeValue == g_TASK_NEW_NPC_DIALOGUE then
		local ids = i3k_db_dungeon_base[mapID].npcs
		for k,v in pairs(ids) do
			if i3k_db_npc_area[v].NPCID == arg then
				arg = v
			end
		end
	end
	local needValue = {flage = tag, mapId = mapID, areaId = arg, pos = point}
	return needValue
end






function wnd_scene_map:transToPos(sender, needValue)
	local mapId = needValue.mapId
	local areaId = needValue.areaId
	local needId = i3k_db_common.activity.transNeedItemId
	local itemCount = g_i3k_game_context:GetBagMiscellaneousCanUseCount(needId)
	local needName = g_i3k_db.i3k_db_get_common_item_name(needId)
	-- if itemCount<1 then
	if not g_i3k_game_context:CheckCanTrans(needId, 1) then
		local tips = string.format("%s", "所需物品数量不足,请步行前往")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		descText = i3k_get_string(1491,needName, 1)
		local function callback(isOk)
			if isOk then
				self._targetPos = needValue.pos
				local hero = i3k_game_get_player_hero()
				g_i3k_game_context:ClearFindWayStatus()
				hero:StopMove(true);
				g_i3k_game_context:setUnlockSkillStatus(false)
				if needValue.isNpc then
					i3k_sbean.transToNpc(mapId, areaId)
				else
					i3k_sbean.transToMonster(mapId, areaId)
				end
			end
		end
		if g_i3k_game_context:IsTransNeedItem() then
			local function func()
				g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
			end
			g_i3k_game_context:CheckMulHorse(func,true)
		else
			local function func()
				callback(true)
			end
			g_i3k_game_context:CheckMulHorse(func,true)
		end
	end
end

function wnd_scene_map:walkToPos(sender, needValue)
	local targetMapId = needValue.mapId
	local targetPos = needValue.pos
	local size = needValue.size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	if nowMapId==targetMapId then
		local pos = i3k_vec3_to_engine(targetPos)
		self:toTargetPos(nowMapId, pos, size, needValue)
	else
		self:close()
--		g_i3k_game_context:SeachBestPathWithMap(targetMapId, targetPos)
		g_i3k_game_context:SeachPathWithMap(targetMapId, targetPos, nil,nil,needValue)
	end
end

function wnd_scene_map:toSceneMap(sender)
	self:close()
	g_i3k_ui_mgr:OpenUI(eUIID_WorldMap)
	--[[local user_cfg = g_i3k_game_context:GetUserCfg()
	local catchSpirit = user_cfg:GetCatchSpiritPreview()
	if table.indexof(catchSpirit, g_i3k_game_context:GetRoleId()) then
	else
		g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritPreview)
		g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritPreview)
		user_cfg:SetCatchSpiritPreview(g_i3k_game_context:GetRoleId())
	end--]]
end

function wnd_scene_map:searchPath(sender, needValue)
	local size = needValue.size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local targetMapId = needValue.mapId
	local mousePos = g_i3k_ui_mgr:GetMousePos()
	local pos = sender:convertToNodeSpace(mousePos)
	local hero = i3k_game_get_player_hero()
	local needPos = i3k_minmap_pos_to_engine_world_pos(pos, size.width, size.height, targetMapId, false)
	needPos.y = hero._curPosE.y
	local toPos = i3k_vec3_to_engine(i3k_vec3(needPos.x, needPos.y, needPos.z))
	if nowMapId == targetMapId then
		self:toTargetPos(nowMapId, toPos, size, nil, -1)
	else
		g_i3k_game_context:SeachPathWithMap(targetMapId, needPos, -1)
	end
	self:createTargetPos(toPos, size, targetMapId)
	self._beginSearchPath = 0.2
	g_i3k_game_context:setMiniMapTargetPos(toPos)
	g_i3k_game_context:setMiniMapTargetPosMapID(targetMapId)
end

-- 创建寻路位置目标
function wnd_scene_map:createTargetPos(toPos, size, mapId)
	local mapPos = i3k_engine_world_pos_to_minmap_pos(toPos, size.width, size.height, mapId, nil, true)
	createTargetPos(mapPos, mapId)
end

-- InvokeUIFunction
function wnd_scene_map:createTargetPosWithoutSize(toPos)
	local size = self._size
	if size then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		if self._curMapID and targetMapId and targetMapId == self._curMapID then
			self:createTargetPos(toPos, size, targetMapId)
		end
	end
end

function wnd_scene_map:toTargetPos(mapId, pos, size, needValue, taskType)
	local hero = i3k_game_get_player_hero()
	local paths = g_i3k_mmengine:FindPath(hero._curPosE, pos)  -- 我怀疑这个东西的返回值有改动 menglei
	local _size = paths:size();
	local posTable = {}
	if _size > 1 then
		for k = 1, _size do
			local posPoint = paths[k - 1];
			table.insert(posTable, posPoint)
		end
	end
	for i,v in pairs(self._pathSpriteTable) do
		self._parent:removeChild(v)
	end
	self._pathSpriteTable = {}
	self._pathSpriteTable = createPath(posTable, size)
	-- i3k_log("size ===".._size..":"..#self._pathSpriteTable)
	g_mapSize = size
--	g_i3k_game_context:SeachBestPathWithMap(mapId, pos)
	g_i3k_game_context:SeachPathWithMap(mapId, pos, taskType, nil, needValue)
	self._targetPos = pos

end

--[[function wnd_scene_map:onClose(sender)
	self:close()
end--]]

function wnd_scene_map:close()
	releaseSchedule()
--	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap, "updateMapInfo")
	g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
end

function wnd_scene_map:onUpdate(dTime)
	if self._beginSearchPath then
		self._beginSearchPath = self._beginSearchPath - dTime
		if self._beginSearchPath <= 0 then
			self._beginSearchPath = nil
		end
	end
	local mapInstance = GetBaseMap()
	mapInstance:onUpdate(dTime)
	local hero = i3k_game_get_player_hero()
	if hero then
		if not self._beginSearchPath then
			if not hero:IsMoving() and g_i3k_game_context:getMiniMapTargetPos() then
				g_i3k_game_context:setMiniMapTargetPos(nil)
				g_i3k_game_context:setMiniMapTargetPosMapID(nil)
			end
		end
	end
	if self._targetPos then
		local pos = hero._curPosE
		pos = {x = pos.x, y = pos.y, z = pos.z}
		local pos2 = {x = self._targetPos.x, y = self._targetPos.y, z = self._targetPos.z}
		local disX = math.abs(pos.x-self._targetPos.x)
		local disZ = math.abs(pos.z-self._targetPos.z)
		if disX<2 and disZ<2 then
			self._targetPos = nil
			for i,v in pairs(self._pathSpriteTable) do
				self._parent:removeChild(v)
			end
			self._pathSpriteTable = {}
		end
		-- 移除走过的路径点
		if g_mapSize ~= nil then
			local mapPos = i3k_engine_world_pos_to_minmap_pos(pos, g_mapSize.width, g_mapSize.height, nil,nil)
--[[			for k,v in pairs(self._pathSpriteTable) do
				deltX = math.abs(v:getPositionX() - mapPos.x)
				deltY = math.abs(v:getPositionY() - mapPos.y)
				if deltX < 3 and deltY < 3 then
					self._parent:removeChild(v)
					table.remove(self._pathSpriteTable, k)
				end
			end--]]
			for i=#self._pathSpriteTable,1,-1 do
				local v = self._pathSpriteTable[i]
				deltX = math.abs(v:getPositionX() - mapPos.x)
				deltY = math.abs(v:getPositionY() - mapPos.y)
				if deltX < 3 and deltY < 3 then
					self._parent:removeChild(v)
					table.remove(self._pathSpriteTable, i)
				end
			end
		end
	end
end

----图钉逻辑-----
function wnd_scene_map:refreshThumbtackImage(mapId)
	local common = i3k_db_common.tuDingInfo
	local tuding = self._layout.vars.tuding
	--等级不足
	if g_i3k_game_context:GetLevel() < common.openlevle then
		tuding:hide()
		return
	end
	
	local level = g_i3k_game_context:GetVipLevel()	
	local vipUseCount = i3k_db_kungfu_vip[level].useTuDingCount
	
	if vipUseCount <= 0 then 
		tuding:hide()
		return
	end
	
	--地图ID不在范围
	for _, v in ipairs(common.mapID) do
		if v == mapId then
			tuding:show()
			tuding:onClick(self, self.onThumbtackClick)
			local info = g_i3k_game_context:getThumbtack()
			
			if info == nil or #info == 0 then
				i3k_sbean.thumbtack_getinfo()
			else
				self:refreshMapBaseData(info, true)
			end
			
			return
		end
	end
	
	tuding:hide()	
end

--图钉按钮点击事件
function wnd_scene_map:onThumbtackClick()
	local thumbtackOrderTable = g_i3k_game_context:getThumbtackOrderTable()
	
	if #thumbtackOrderTable == 0 and g_i3k_game_context:GetWorldMapID() ~= self._curMapID then
		g_i3k_ui_mgr:PopupTipMessage("您还没有添加图钉")
		return
	end
	
	g_i3k_logic:OpenThumbtackScollUI(self._curMapID, self._size)
end

function wnd_scene_map:refreshMapBaseData(info, localData)
 	if info == nil or self._curMapID == nil then return end
	
	if localData then
		local mapInfo = info[self._curMapID]
		if mapInfo == nil then return end
		
		for _, v in pairs(mapInfo) do
			if v ~= nil and v ~= 0 and self._curMapID == v.mapId then
				local thumbInfo = {mapId = v.mapId,  index = v.index, remarks = v.remarks, pos = v.position, thumbAddTime = v.thumbAddTime}						
				self:addThumbtackImage(thumbInfo)				
			end
		end
	else
		for _, v in pairs(info) do
			if v ~= 0 and v ~= nil then
				local position = {x = v.position.x / 100, y = v.position.y / 100, z = v.position.z / 100}
				local thumbInfo = {mapId = v.mapId,  index = v.index, remarks = v.remarks, pos = position, thumbAddTime = v.addTime}
				
				if self._curMapID == v.mapId then						
					self:addThumbtackImage(thumbInfo)
				else
					g_i3k_game_context:setThumbtack(thumbInfo.index, thumbInfo.mapId, 
					{node = nil, index = thumbInfo.index, mapId = thumbInfo.mapId, remarks = thumbInfo.remarks, position = thumbInfo.pos, thumbAddTime = thumbInfo.thumbAddTime})
				end
			end
		end
	end
end

function wnd_scene_map:addThumbtackImage(info)
	if info == nil then return end	
	GetBaseMap():addThumbtackNode(info, self._size)
end

function wnd_create(layout, ...)
	local wnd = wnd_scene_map.new();
	wnd:create(layout, ...);

	return wnd;
end
