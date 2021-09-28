-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarMap = i3k_class("wnd_defenceWarMap", ui.wnd_base)

-- 城战小地图
-- [eUIID_DefenceWarMap]	= {name = "defenceWarMap", layout = "chengzhandt", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarMap:ctor()

end

function wnd_defenceWarMap:configure()
	self:setButtons()
end

function wnd_defenceWarMap:refresh(mapID, reviveFlag, arrayTower)
	self:setScrolls(mapID)
	self:setTouchScroll(mapID)
	self:addIcons(reviveFlag, arrayTower)
end

function wnd_defenceWarMap:setTouchScroll(mapId)
	self._curMapID = mapId
	local cfg = i3k_db_defenceWar_dungeon[mapId]
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
	local spriteTable = createMap(scroll, nodeSize, mapId, node.vars.image, nowMapId == mapId)
	self._parent = node.vars.image
	local needValue = {size = size, mapId = mapId}
	local sizeImg = node.vars.image:getContentSize()
	local sizeBtn = node.vars.btn:getContentSize()
	node.vars.btn:onClick(self, self.searchPath, needValue)
end


function wnd_defenceWarMap:onUpdate(dTime)
	local mapBase = GetBaseMap()
	mapBase:onUpdate(dTime)
	-- 清空寻路状态
	if self._beginSearchPath then
		self._beginSearchPath = self._beginSearchPath - dTime
		if self._beginSearchPath <= 0 then
			self._beginSearchPath = nil
		end
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		if not self._beginSearchPath then
			if not hero:IsMoving() and g_i3k_game_context:getMiniMapTargetPos() then
				g_i3k_game_context:setMiniMapTargetPos(nil)
				g_i3k_game_context:setMiniMapTargetPosMapID(nil)
			end
		end
	end

end

function wnd_defenceWarMap:onShow()

end

function wnd_defenceWarMap:onHide()
	releaseSchedule()
end

function wnd_defenceWarMap:setScrolls(mapID)
	-- local npcs = i3k_db_dungeon_base[mapID].npcs
	local npcs = i3k_db_defenceWar_minimap_icons.mapList
	self:setScroll_scrollList(npcs)
end

function wnd_defenceWarMap:addIcons(reviveFlag, arrayTower)
	local mapBase = GetBaseMap()
	mapBase:addDefenceWarIcons(reviveFlag, arrayTower)
end


-- TODO
function wnd_defenceWarMap:setScroll_scrollList(list)
	local widgets = self._layout.vars
	local scroll = widgets.scrollList
	scroll:removeAllChildren()
	-- for k, v in ipairs(list) do
	-- 	local ui = require("ui/widgets/chengzhandtt2")()
	-- 	local npc = i3k_db_npc[i3k_db_npc_area[v].NPCID]
	-- 	ui.vars.name:setText(npc.remarkName) --  ..npc.typeDesc
	-- 	-- ui.vars.flagImg:setImage()
	-- 	local targetPos = i3k_db_npc_area[v].pos
	-- 	local NPCID = i3k_db_npc_area[v].NPCID
	-- 	local needValue = {pos = targetPos, mapId = mapId, size = size,areaId = NPCID,flage = 1}
	-- 	ui.vars.selectBtn:onClick(self, self.walkToPos, needValue)
	-- 	scroll:addItem(ui)
	-- end

	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhandtt2")()
		ui.vars.name:setText(v.name) 
		ui.vars.flagImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.imageID))
		scroll:addItem(ui)
	end
end

function wnd_defenceWarMap:setImages()
	local widgets = self._layout.vars
	--	widgets.abc:setImage()
	--	widgets.titleImage:setImage()
end

function wnd_defenceWarMap:setButtons()
	local widgets = self._layout.vars
	widgets.Close:onClick(self, self.onCloseBtn)
end


function wnd_defenceWarMap:searchPath(sender, needValue)
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
function wnd_defenceWarMap:createTargetPos(toPos, size, mapId)
	local mapPos = i3k_engine_world_pos_to_minmap_pos(toPos, size.width, size.height, mapId, nil, true)
	createTargetPos(mapPos, mapId)
end

-- InvokeUIFunction
function wnd_defenceWarMap:createTargetPosWithoutSize(toPos)
	local size = self._size
	if size then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		if self._curMapID and targetMapId and targetMapId == self._curMapID then
			self:createTargetPos(toPos, size, targetMapId)
		end
	end
end

function wnd_defenceWarMap:walkToPos(sender, needValue)
	local targetMapId = needValue.mapId
	local targetPos = needValue.pos
	local size = needValue.size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	if nowMapId == targetMapId then
		local pos = i3k_vec3_to_engine(targetPos)
		self:toTargetPos(nowMapId, pos, size, needValue)
	else
		g_i3k_game_context:SeachPathWithMap(targetMapId, targetPos, nil, nil)
	end
end

function wnd_defenceWarMap:toTargetPos(mapId, pos, size, needValue, taskType)
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

	g_i3k_game_context:SeachPathWithMap(mapId, pos, taskType, nil)
	self._targetPos = pos
end

function wnd_defenceWarMap:close()
	releaseSchedule()
	g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
end

function wnd_defenceWarMap:onCloseBtn(sender)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_defenceWarMap.new()
	wnd:create(layout, ...)
	return wnd;
end
