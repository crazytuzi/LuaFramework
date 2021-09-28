module(..., package.seeall)

local require = require;

require("ui/map_set_funcs")
local ui = require("ui/base")

wnd_demonhole_map = i3k_class("wnd_demonhole_map", ui.wnd_base)

local g_mapSize = nil
function wnd_demonhole_map:ctor()
	self._pathSpriteTable = {}
	self._targetPos = false
	self._targetPos = nil
	self._curMapID = nil

	self._isNpcOpen = true
	self._isMonsterPointOpen = true
end

function wnd_demonhole_map:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_demonhole_map:onShow()

end

function wnd_demonhole_map:onHide()
	releaseSchedule()
end

function wnd_demonhole_map:refresh(mapId, cfg)
	local imgPath = g_i3k_db.i3k_db_get_icon_path(cfg.titleImgId)
	self._layout.vars.titleImage:setImage(imgPath)
	self._curMapID = mapId

	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	local node = require("ui/widgets/zdt")()
	local size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local img = i3k_checkPList(i3k_db_icons[cfg.imageId].path)
	local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
	size = heroSprite:getContentSize()
	size = {width = size.width*cfg.worldMapScale,height = size.height*cfg.worldMapScale}
	local mapImg = node.vars.image
	self:SetMapImageContentsize(node,size)  --根据是不是PAD设置地图大小
	node.vars.btn:setContentSize(size.width, size.height)
	mapImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageId))
	scroll:addItem(node, true)
	local width = scroll:getContainerSize().width
	local height = scroll:getContainerSize().height
	mapImg:setPositionInScroll(scroll,cfg.worldMapScaleX*width, cfg.worldMapScaleY*height)

	local nodeSize = node.vars.image:getContentSize()
	local spriteTable = createMap(scroll, nodeSize, mapId, node.vars.image, nowMapId==mapId)
	self._parent = node.vars.image
	local needValue = {size = size, mapId = mapId}
	local sizeImg = node.vars.image:getContentSize()
	local sizeBtn = node.vars.btn:getContentSize()
	node.vars.btn:onClick(self, self.searchPath, needValue)
	-------------右侧NPC以及刷怪区域---------------
	self._size = size
	self:onRefreshList(mapId,size)
	local targetPos = g_i3k_game_context:getMiniMapTargetPos()
	if targetPos then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		if targetMapId and targetMapId == self._curMapID then
			self:createTargetPos(targetPos, size, targetMapId)
		end
	else
		clearTargetImg()
	end
end

function wnd_demonhole_map:onRefreshList(mapId,size)
	self._layout.vars.list:removeAllChildren()
	self:rightNpcList(mapId, size)
	self:rightMonsterList(mapId, size)
end

function wnd_demonhole_map:rightNpcList(mapId, size)
	local haveNpc = i3k_db_dungeon_base[mapId].npcs
	local hasAddNpc = false
	for i,v in pairs(haveNpc) do
		local npc = i3k_db_npc[i3k_db_npc_area[v].NPCID]
		local isShow = npc.isShowInMapList == 1
		if isShow then
			if not hasAddNpc then
				local node = require("ui/widgets/fmddtt")()
				self._layout.vars.list:addItem(node)
				node.vars.btn:onClick(self, self.openOrPickup, {mapId = mapId, isNpc = true})
				hasAddNpc = true
				node.vars.open:setVisible(self._isNpcOpen)
				node.vars.pickup:setVisible(not self._isNpcOpen)
				if self._isNpcOpen then
					node.vars.btn:stateToPressed()
				else
					node.vars.btn:stateToNormal()
				end
				node.vars.name:setText(string.format("%s", "人物列表"))
			end
			if self._isNpcOpen then
				local node = require("ui/widgets/fmddtt2")()
				node.vars.name:setText(npc.remarkName)
				local targetPos = i3k_db_npc_area[v].pos
				local NPCID = i3k_db_npc_area[v].NPCID
				local needValue = {pos = targetPos, mapId = mapId, size = size,areaId = NPCID,flage = 1}
				node.vars.selectBtn:onClick(self, self.walkToPos, needValue)
				self._layout.vars.list:addItem(node)
			end
		end
	end
end

function wnd_demonhole_map:rightMonsterList(mapId, size)
	local haveMonsterArea = i3k_db_dungeon_base[mapId].areas
	local areasTable = {}
	if #haveMonsterArea>0 then
		local node = require("ui/widgets/fmddtt")()
		node.vars.btn:onClick(self, self.openOrPickup, {mapId = mapId, isNpc = false})
		self._layout.vars.list:addItem(node)
		if self._isMonsterPointOpen then
			node.vars.open:show()
			node.vars.pickup:hide()
			node.vars.btn:stateToPressed()
		else
			node.vars.pickup:show()
			node.vars.open:hide()
			node.vars.btn:stateToNormal()
		end
		node.vars.name:setText(string.format("%s", "刷怪点"))
	end
	if self._isMonsterPointOpen then
		for i,v in pairs(haveMonsterArea) do
			local monsterPointTable = i3k_db_spawn_area[v].spawnPoints
			--还要有个刷怪点表要读
			for j,k in pairs(monsterPointTable) do
				local pointCfg = i3k_db_spawn_point[k]
				local monsterId = pointCfg.monsters[1]
				local isHave = false
				for _,t in pairs(areasTable) do
					if t.monsters[1]==monsterId then
						isHave = true
						break
					end
				end
				if not isHave then
					local node = require("ui/widgets/fmddtt2")()
					node.vars.name:setText(g_i3k_db.i3k_db_get_monster_lvl_name(monsterId))
					local needValue = {pos = pointCfg.pos, mapId = mapId, size = size,areaId = monsterId, flage = 3}
					node.vars.selectBtn:onClick(self, self.walkToPos, needValue)
					self._layout.vars.list:addItem(node)
					table.insert(areasTable, pointCfg)
				end
			end
		end
	end
end

function wnd_demonhole_map:walkToPos(sender, needValue)
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
		g_i3k_game_context:SeachPathWithMap(targetMapId, targetPos, nil, nil)
	end
end

function wnd_demonhole_map:searchPath(sender, needValue)
	local size = needValue.size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local targetMapId = needValue.mapId
	local mousePos = g_i3k_ui_mgr:GetMousePos()
	local pos = sender:convertToNodeSpace(mousePos)
	local hero = i3k_game_get_player_hero()
	local needPos = i3k_minmap_pos_to_engine_world_pos(pos, size.width, size.height, targetMapId, true)
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
function wnd_demonhole_map:createTargetPos(toPos, size, mapId)
	local mapPos = i3k_engine_world_pos_to_minmap_pos(toPos, size.width, size.height, mapId, nil, true)
	createTargetPos(mapPos, mapId)
end

-- InvokeUIFunction
function wnd_demonhole_map:createTargetPosWithoutSize(toPos)
	local size = self._size
	if size then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		if self._curMapID and targetMapId and targetMapId == self._curMapID then
			self:createTargetPos(toPos, size, targetMapId)
		end
	end
end

function wnd_demonhole_map:toTargetPos(mapId, pos, size, needValue, taskType)
	local hero = i3k_game_get_player_hero()
	local paths = g_i3k_mmengine:FindPath(hero._curPosE, pos)
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
	g_mapSize = size
	g_i3k_game_context:SeachPathWithMap(mapId, pos, taskType, nil)
	self._targetPos = pos
end

function wnd_demonhole_map:openOrPickup(sender, needValue)
	if needValue.isNpc then
		self._isNpcOpen = not self._isNpcOpen
	else
		self._isMonsterPointOpen = not self._isMonsterPointOpen
	end
	self:onRefreshList(needValue.mapId,self._size)
end

function wnd_demonhole_map:close()
	releaseSchedule()
	g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
end

function wnd_demonhole_map:onUpdate(dTime)
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
			local mapPos = i3k_engine_world_pos_to_minmap_pos(pos, g_mapSize.width, g_mapSize.height, nil, true)
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

function wnd_create(layout, ...)
	local wnd = wnd_demonhole_map.new();
	wnd:create(layout, ...);
	return wnd;
end
