module(..., package.seeall)

local require = require;

require("ui/map_set_funcs")
local ui = require("ui/base")

wnd_factionFightMap = i3k_class("wnd_factionFightMap", ui.wnd_base)

local g_mapSize = nil
function wnd_factionFightMap:ctor()
	self._pathSpriteTable = {}
	self._targetPos = false
	self._timeCounter = 0
	self._timeCounter2 = 0
end

function wnd_factionFightMap:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI, function ()
		releaseSchedule()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightMiniMap, "updateMapInfo")
	end)
end

function wnd_factionFightMap:onShow()
	self:queryTeammatePos()
	self:queryWarFlagStatus()
end

function wnd_factionFightMap:onUpdate(dTime)
	local mapInstance = GetBaseMap()
	mapInstance:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 0.2 then -- 0.2s 请求一次，刷新地图中队友节点的位置
		self:queryTeammatePos()
		self._timeCounter = 0
	end

	-- 查询旗子状态
	self._timeCounter2 = self._timeCounter2 + dTime
	if self._timeCounter2 > 3 then
		self:queryWarFlagStatus()
		self._timeCounter2 = 0
	end
end


function wnd_factionFightMap:refresh(mapId)
	--local imgPath = g_i3k_db.i3k_db_get_icon_path(i3k_db_field_map[mapId].titleImgId)
	--self._layout.vars.titleImage:setImage(imgPath)

	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	local node = require("ui/widgets/zdt")()
	local size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	for i,v in pairs(i3k_db_factionFight_dungon) do
		if v.id==mapId then
			local img = i3k_checkPList(i3k_db_icons[v.imageId].path)
			local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
			size = heroSprite:getContentSize()
			size = {width = size.width*v.worldMapScale,height = size.height*v.worldMapScale}
			local mapImg = node.vars.image
			self:SetMapImageContentsize(node,size)  --根据是不是PAD设置地图大小
			node.vars.btn:setContentSize(size.width, size.height)
			mapImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.imageId))
			scroll:addItem(node, true)

			local width = scroll:getContainerSize().width
			local height = scroll:getContainerSize().height
			mapImg:setPositionInScroll(scroll,v.worldMapScaleX*width,v.worldMapScaleY*height)
		end
	end
	local nodeSize = node.vars.image:getContentSize()
	local spriteTable = createMap(scroll, nodeSize, mapId, node.vars.image, nowMapId==mapId, false)

	self._parent = node.vars.image

	local needValue = {size = size, mapId = mapId}
	local sizeImg = node.vars.image:getContentSize()
	local sizeBtn = node.vars.btn:getContentSize()

	node.vars.btn:onClick(self, self.searchPath, needValue)

end

-- 异步协议同步队友的位置
function wnd_factionFightMap:queryTeammatePos(dTime)
	i3k_sbean.queryFactionWarMemberPos()
end

function wnd_factionFightMap:queryWarFlagStatus(dTime)
	i3k_sbean.querySectWarFlagStatus()
end


function wnd_factionFightMap:updateTeammatePos(data)
	updateTeammatePos(data)
end

function wnd_factionFightMap:searchPath(sender, needValue)
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
function wnd_factionFightMap:toTargetPos(mapId, pos, size)
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
--	g_i3k_game_context:SeachBestPathWithMap(mapId, pos)
	g_i3k_game_context:SeachPathWithMap(mapId, pos)
	self._targetPos = pos
end

function wnd_factionFightMap:updateFlagStatus(status)
	local mapBase = GetBaseMap()
	mapBase:removeAllFactionFlags()
	mapBase:addFactionFightFlag(status)
end


function wnd_create(layout, ...)
	local wnd = wnd_factionFightMap.new();
	wnd:create(layout, ...);

	return wnd;
end
