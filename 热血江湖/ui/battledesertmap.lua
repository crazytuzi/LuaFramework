module(..., package.seeall)

local require = require;

require("ui/map_set_funcs")
local ui = require("ui/mapUIBase")

wnd_battleDesertMap = i3k_class("wnd_battleDesertMap", ui.wnd_MapBase)

local g_mapSize = nil
local g_colorGreen = cc.c4f(0 /255, 128/255, 0 / 255, 1)
local g_colorRed = cc.c4f(255 /255, 0/255, 0 / 255, 1)

function wnd_battleDesertMap:ctor()
	self._pathSpriteTable = {}
	self._targetPos = nil
	self._curMapID = nil

	self._isResOpen = true
	self._isMonsterPointOpen = true
	
	self._isShrinkRing = false
	self._isShowSafe = false
end

function wnd_battleDesertMap:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_battleDesertMap:onShow()

end

function wnd_battleDesertMap:onHide()
	releaseSchedule()
end

--更新毒圈
function wnd_battleDesertMap:updatePoisonFog()
	self._isShrinkRing = false
	local safeInfo, poisonInfo, surplusTime = g_i3k_db.i3k_db_get_desert_battle_poisonCircle() --获取毒圈信息
	if not safeInfo then return end
	self._safeInfo = self:transformationPoisonPos(safeInfo)
	self._poisonInfo = self:transformationPoisonPos(poisonInfo)
	self:drawCircular(self._poisonInfo.pos, self._poisonInfo.radius, true)
	local sleepTime, safeTime = g_i3k_db.i3k_db_get_poisonCircle_sleepTime()
	if  safeTime and safeTime <= 0 then
		self._isShowSafe = true
		self:drawCircular(self._safeInfo.pos, self._safeInfo.radius, false)	
	else
		self._isShowSafe = false
    end
	
	if self._poisonInfo then
		if sleepTime and sleepTime <= 0 then
			self:drawCircular(self._poisonInfo.pos, self._poisonInfo.radius, true)
			self._isShrinkRing = true
			self._speed = self:getSpeed(surplusTime)
		end
	end
end


--坐标转换
function wnd_battleDesertMap:transformationPoisonPos(info)
	local pos = i3k_engine_world_pos_to_minmap_pos(info.pos, self._size.width, self._size.height, self._curMapID, nil, true)
	return {pos = pos, radius = info.radius * self._curMapScale }
end	

function wnd_battleDesertMap:refresh(mapId, cfg)
	local imgPath = g_i3k_db.i3k_db_get_icon_path(cfg.titleImgId)
	self._layout.vars.titleImage:setImage(imgPath)
	self._curMapID = mapId
	self._curMapScale = cfg.worldMapScale

	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	local node = require("ui/widgets/zdt")()
	local weight = node.vars
	local size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local img = i3k_checkPList(i3k_db_icons[cfg.imageId].path)
	local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
	size = heroSprite:getContentSize()
	size = {width = size.width * cfg.worldMapScale, height = size.height * cfg.worldMapScale}
	local mapImg = weight.image
	self:SetMapImageContentsize(node,size)  --根据是不是PAD设置地图大小
	weight.btn:setContentSize(size.width, size.height)
	mapImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageId))
	scroll:addItem(node, true)
	local width = scroll:getContainerSize().width
	local height = scroll:getContainerSize().height
	mapImg:setPositionInScroll(scroll,cfg.worldMapScaleX * width, cfg.worldMapScaleY * height)

	local nodeSize = weight.image:getContentSize()
	local spriteTable = createMap(scroll, nodeSize, mapId, weight.image, nowMapId == mapId)
	self._parent = weight.image
	local needValue = {size = size, mapId = mapId}
	local sizeImg = weight.image:getContentSize()
	local sizeBtn = weight.btn:getContentSize()
	weight.btn:onClick(self, self.searchPath, needValue)
	
	self._layout.vars.goSafe:show()
	self._layout.vars.goSafe:onClick(self, self.goToSafetyZone)
	-------------右侧NPC以及刷怪区域---------------
	self._size = size
	self:onRefreshList(mapId, size)
	local targetPos = g_i3k_game_context:getMiniMapTargetPos()
	
	if targetPos then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		if targetMapId and targetMapId == self._curMapID then
			self:createTargetPos(targetPos, size, targetMapId)
		end
	else
		clearTargetImg()
	end
	-------------毒圈---------------------------
	local scroll = self._layout.vars.scroll
	local layerFarm = cc.Layer:create()
	self._parent:addChild(layerFarm)
	self._layerFarm = layerFarm
	self:updatePoisonFog()
	self.record_time = 0
	self._timeCounter = 0
end

function wnd_battleDesertMap:onRefreshList(mapId,size)
	self._layout.vars.list:removeAllChildren()
    self._layout.vars.list2:removeAllChildren()
    -- local InfoTab, state, monsterIsNil = self:GetRightListState(mapId)
    local cfg = self.list_info[1]  -- 此页面只有一个列表
    self._layout.vars.BtnThree:setVisible(cfg.AllList)
    self._layout.vars.BtnOneOrTwo:setVisible(not cfg.AllList)
    self._layout.vars.Btn11:setVisible(cfg.Btn11)
    self._layout.vars.Btn21:setVisible(cfg.Btn21)
	self._layout.vars.Btn22:setVisible(cfg.Btn22)
	-- self._layout.vars.Btn11:onClick(self, self.openList, {mapId = mapId, size = size, isShowNpc = true})
	self._layout.vars.BtnName11:setText(i3k_get_string(17629))
	self._layout.vars.Btn11:stateToPressed(true, true)
	self:rightResList(mapId, size,  self._layout.vars.list2)
end

function wnd_battleDesertMap:rightResList(mapId, size, rootNode)
	--TODO
	local haveRes = i3k_db_desert_resInfo.resPos
	local hasAddRes = false
	local index = 0
	for i,v in pairs(haveRes) do
		index = index +1
				
				
			
		if self._isResOpen then
			local node = require("ui/widgets/sjdtt2")()
			local weight = node.vars
			weight.name:setText(i3k_get_string(17630, index))
			local targetPos = v.pos
			local needValue = {pos = targetPos, mapId = mapId, size = size,areaId = nil,flage = 1}
			weight.selectBtn:onClick(self, self.walkToPos, needValue) 
			weight.transBtn:hide()
			weight.transImg:hide()
			rootNode:addItem(node)
		end
	end
end

function wnd_battleDesertMap:openOrPickup(sender, needValue)
	self._isResOpen = not self._isResOpen	
	self:onRefreshList(needValue.mapId,self._size)
end


function wnd_battleDesertMap:walkToPos(sender, needValue)
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

function wnd_battleDesertMap:searchPath(sender, needValue)
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
function wnd_battleDesertMap:createTargetPos(toPos, size, mapId)
	local mapPos = i3k_engine_world_pos_to_minmap_pos(toPos, size.width, size.height, mapId, nil, true)
	createTargetPos(mapPos, mapId)
end

-- InvokeUIFunction
function wnd_battleDesertMap:createTargetPosWithoutSize(toPos)
	local size = self._size
	
	if size then
		local targetMapId = g_i3k_game_context:getMiniMapTargetPosMapID()
		
		if self._curMapID and targetMapId and targetMapId == self._curMapID then
			self._beginSearchPath = 0.2
			self:createTargetPos(toPos, size, targetMapId)
		end
	end
end

function wnd_battleDesertMap:toTargetPos(mapId, pos, size, needValue, taskType)
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

function wnd_battleDesertMap:close()
	releaseSchedule()
	g_i3k_ui_mgr:CloseUI(eUIID_SceneMap)
end

function wnd_battleDesertMap:onUpdate(dTime)
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
		
		if disX < 2 and disZ < 2 then
			self._targetPos = nil
			
			for i,v in pairs(self._pathSpriteTable) do
				self._parent:removeChild(v)
			end
			
			self._pathSpriteTable = {}
		end
		-- 移除走过的路径点
		if g_mapSize ~= nil then
			local mapPos = i3k_engine_world_pos_to_minmap_pos(pos, g_mapSize.width, g_mapSize.height, nil, true)
			
			for i = #self._pathSpriteTable, 1, -1 do
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
	------------毒圈---------------
	self.record_time = self.record_time + dTime
	if  self.record_time >  1 then
		self:shrinkRing()
		self.record_time = 0
		
		if not self._isShrinkRing then
			local sleepTime, safeTime = g_i3k_db.i3k_db_get_poisonCircle_sleepTime()
			if sleepTime and sleepTime <= 0 then
				self:updatePoisonFog()
			end
			
			if not self._isShowSafe then
				if safeTime and  safeTime <= 0 then
					self:updatePoisonFog()
				end
			end
		end
		
	
	end
	------------ 更新队友位置 ----------
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 0.2 then
		self:queryTeammatePos()
		self._timeCounter = 0
	end
end

--更新队友
function wnd_battleDesertMap:queryTeammatePos(dTime)
	
	i3k_sbean.request_query_mapcopy_members_pos()
	
end

function wnd_battleDesertMap:updateTeammatePos(data)
	local roleID = g_i3k_game_context:GetRoleId()
	if data[roleID] then
		data[roleID] = nil
	end
	updateTeammatePos(data)
end


--缩圈
function wnd_battleDesertMap:shrinkRing()
	if self._isShrinkRing then
		local pos, r = self:getPoisonInfo()
		self:drawCircular(pos, r, true)
	end
end

--画圈
function wnd_battleDesertMap:drawCircular(pos, radius, isBig)
	if isBig then
		if self._nodeBig then
			--self._nodeBig:clear()
		else
			
			local node = require("ui/widgets/fmddtt3")()	
			self._nodeBig = node
			self._parent:addChild(node)			
			node.rootVar:setContentSize(self._size.width,self._size.height)
		end
		self._nodeBig.rootVar:setPosition(pos)
		self._nodeBig.rootVar:setScale(radius/(94*self._size.width/256)) --毒圈圆ui 94半径
	else
		if self._nodeSmall then
			self._nodeSmall:clear()
		else
			self._nodeSmall = cc.DrawNode:create()	
		end
		self._nodeSmall:drawCircle(pos, radius, 180, 30, false, g_colorGreen)
		self._layerFarm:addChild(self._nodeSmall)
	end
end

--毒圈圆心半径
function wnd_battleDesertMap:getPoisonInfo()
	local speed = self._speed
	local safePos = self._safeInfo.pos
	local poisonPos = self._poisonInfo.pos
	local absX = math.abs(poisonPos.x + speed.x - safePos.x)
	local absY = math.abs(poisonPos.y + speed.y - safePos.y)
	local r = math.abs(self._poisonInfo.radius + speed.radius - self._safeInfo.radius)
	if absX <= math.abs(speed.x) and absY <= math.abs(speed.y) and r <= math.abs(speed.radius) then
		self._isShrinkRing = false
		return self._safeInfo.pos, self._safeInfo.radius
	end
	self._poisonInfo.pos = {x = poisonPos.x + speed.x, y = poisonPos.y + speed.y}
	self._poisonInfo.radius = self._poisonInfo.radius + speed.radius
	return self._poisonInfo.pos, self._poisonInfo.radius
end

--获取速度
function wnd_battleDesertMap:getSpeed(lastTime)
	local x = (self._safeInfo.pos.x - self._poisonInfo.pos.x) / lastTime
	local y = (self._safeInfo.pos.y - self._poisonInfo.pos.y) / lastTime
	local r = (self._safeInfo.radius - self._poisonInfo.radius) / lastTime
	return {x = x, y = y, radius = r}
end

--前往安全区
function wnd_battleDesertMap:goToSafetyZone(sender)
	g_i3k_db.i3k_db_is_safety_zone() --前往安全区
end

function wnd_create(layout, ...)
	local wnd = wnd_battleDesertMap.new();
	wnd:create(layout, ...);
	return wnd;
end
