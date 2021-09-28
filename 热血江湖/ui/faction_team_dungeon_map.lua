module(..., package.seeall)

local require = require;

require("ui/map_set_funcs")
local ui = require("ui/base")

wnd_faction_team_dungeon_map = i3k_class("wnd_faction_team_dungeon_map", ui.wnd_base)
local LAYER_ZDT = "ui/widgets/zdt"
local g_mapSize = nil
function wnd_faction_team_dungeon_map:ctor()
	self._pathSpriteTable = {}
	self._targetPos = false
end

function wnd_faction_team_dungeon_map:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		releaseSchedule()
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMiniMap, "updateMapInfo")
	end)
end

function wnd_faction_team_dungeon_map:onShow()

end

function wnd_faction_team_dungeon_map:onUpdate(dTime)
	local mapInstance = GetBaseMap()
	mapInstance:onUpdate(dTime)
end

function wnd_faction_team_dungeon_map:refresh(mapId, cfg)
	local imgPath = g_i3k_db.i3k_db_get_icon_path(cfg[mapId].titleImgId)
	self._layout.vars.titleImage:setImage(imgPath)

	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	local node = require(LAYER_ZDT)()
	local size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id

	local oneMap = cfg[mapId]
	local img = i3k_checkPList(i3k_db_icons[oneMap.imageId].path)
	local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
	size = heroSprite:getContentSize()
	size = {width = size.width*oneMap.worldMapScale, height = size.height*oneMap.worldMapScale}
	local mapImg = node.vars.image
	self:SetMapImageContentsize(node,size)  --根据是不是PAD设置地图大小
	node.vars.btn:setContentSize(size.width, size.height)
	mapImg:setImage(g_i3k_db.i3k_db_get_icon_path(oneMap.imageId))
	scroll:addItem(node, true)

	local width = scroll:getContainerSize().width
	local height = scroll:getContainerSize().height
	mapImg:setPositionInScroll(scroll, oneMap.worldMapScaleX*width, oneMap.worldMapScaleY*height)

	local nodeSize = node.vars.image:getContentSize()
	local spriteTable = createMap(scroll, nodeSize, mapId, node.vars.image, nowMapId==mapId, false)


	self._parent = node.vars.image
	self._mapId = mapId
	self._nodeSize = nodeSize

	local needValue = {size = size, mapId = mapId}
	local sizeImg = node.vars.image:getContentSize()
	local sizeBtn = node.vars.btn:getContentSize()

	node.vars.btn:onClick(self, self.searchPath, needValue)

end

function wnd_faction_team_dungeon_map:onUpdateTeamMate(roleId, mapId, pos)
	updateTeamMate(roleId, mapId, pos)
end

function wnd_faction_team_dungeon_map:searchPath(sender, needValue)
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
	if nowMapId==targetMapId then
		self:toTargetPos(nowMapId, toPos, size)
	else
--		g_i3k_game_context:SeachBestPathWithMap(targetMapId, needPos)
		g_i3k_game_context:SeachPathWithMap(targetMapId, needPos)
		--self:close()
	end
end
function wnd_faction_team_dungeon_map:toTargetPos(mapId, pos, size)
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
	g_i3k_game_context:SeachPathWithMap(mapId, pos)
	self._targetPos = pos
end

function wnd_faction_team_dungeon_map:updateMonsterNums(monsters)
	local scroll = self._layout.vars.scroll
	local mapBase = GetBaseMap()
	mapBase:addMonsterWithCount(self._parent, self._mapId, self._nodeSize, monsters)
end


function wnd_create(layout, ...)
	local wnd = wnd_faction_team_dungeon_map.new();
	wnd:create(layout, ...);

	return wnd;
end
