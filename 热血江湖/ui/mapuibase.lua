-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require('ui/base')

-------------------------------------------------------
wnd_MapBase = i3k_class('wnd_MapBase', ui.wnd_base)


--右侧列表展示3种状态,按钮数量不同


function wnd_MapBase:ctor()
    --列表索引
    self.NpcList = 1
    self.MonsterList = 2
    self.SpecialMonsterList = 3
    --列表状态索引
    self.List_State_One = 1
    self.List_State_Two = 2
    self.List_State_Three = 3
    --npc名字后缀类型
    self.NpcFunSuffix = 1   --Npc功能后缀，如'<道具销毁>'
    self.NpcTypeSuffix = 2  --Npc归属后缀，如'<正派使者>'

    self.NpcSuffix =  self.NpcFunSuffix
    --右侧列表使用UI组件
	self.widgetsTitile = "ui/widgets/fmddtt"
    self.widgetsitem = "ui/widgets/fmddtt2"
    --[1] = _isNpcOpen, [2] = _isMonsterPointOpen, [3] = _isSpecalOpen
	self.BtnState = { true, false, false}
	--self.list_info.btnname为i3k_db_string.lua 的id值
    self.list_info = { 	[self.List_State_One] = { AllList = false, Btn11 = true, Btn21 = false, Btn22 = false},
                        [self.List_State_Two] = { AllList = false, Btn11 = false, Btn21 = true, Btn22 = true},
                        [self.List_State_Three] = { AllList = true, Btn11 = false, Btn21 = false, Btn22 = false}}
    self.btnName ={ 5712, 5713, 5714}

end

function wnd_MapBase:configure()
end

function wnd_MapBase:refresh()
end

function wnd_MapBase:RefreshList(mapId, size, isNpc, isMonster, isSpecialMonster, _isShowTransBtn)
    self._layout.vars.list:removeAllChildren()
    self._layout.vars.list2:removeAllChildren()

    local InfoTab, state, monsterIsNil = self:GetRightListState(mapId)
    local cfg = self.list_info[state]
    if not cfg then
        self._layout.vars.BtnThree:setVisible(false)
        self._layout.vars.BtnOneOrTwo:setVisible(false)
    else
        self._layout.vars.BtnThree:setVisible(cfg.AllList)
        self._layout.vars.BtnOneOrTwo:setVisible(not cfg.AllList)
        self._layout.vars.Btn11:setVisible(cfg.Btn11)
        self._layout.vars.Btn21:setVisible(cfg.Btn21)
        self._layout.vars.Btn22:setVisible(cfg.Btn22)

        if state == self.List_State_One then
            self._layout.vars.Btn11:onClick(self, self.openList, {mapId = mapId, size = size, isShowNpc = true})
            self._layout.vars.BtnName11:setText(i3k_get_string( self.btnName[monsterIsNil and 1 or 2]))
            self._layout.vars.Btn11:stateToPressed(true, true)
            if monsterIsNil then
                self:CreatNpcItem(InfoTab[self.NpcList], mapId, size, self._layout.vars.list2)
            else
                self:CreatMonsterItem(InfoTab[self.MonsterList], mapId, size,self._layout.vars.list2)
            end
        elseif state == self.List_State_Two then
            self._layout.vars.Btn21:onClick(self, self.openList, {mapId = mapId, size = size, isShowNpc = true})
            self._layout.vars.BtnName21:setText(i3k_get_string( self.btnName[1]))
            self._layout.vars.Btn22:onClick(self, self.openList, {mapId = mapId, size = size, isShowNpc = false})
            self._layout.vars.BtnName22:setText(i3k_get_string( self.btnName[monsterIsNil and 3 or 2]))
            if isNpc then
                self._layout.vars.Btn21:stateToPressed(true)
                self._layout.vars.Btn22:stateToNormal(true)
            else
                self._layout.vars.Btn21:stateToNormal(true)
                self._layout.vars.Btn22:stateToPressed(true)
            end
            if isNpc then
                self:CreatNpcItem(InfoTab[self.NpcList], mapId, size, self._layout.vars.list2)
            else
                if monsterIsNil then
                    --创建未添加的第三个列表
                    self:CreatSpecialMonsterItem(InfoTab[self.SpecialMonsterList], mapId, size, self._layout.vars.list2)
                else
                    self:CreatMonsterItem(InfoTab[self.MonsterList], mapId, size,self._layout.vars.list2)
                end
            end
        else
            self:rightNpcList(mapId, size, InfoTab[self.NpcList], isNpc, i3k_get_string(self.btnName[1]), self._layout.vars.list, _isShowTransBtn)
            self:rightMonsterList(mapId, size, InfoTab[self.MonsterList], isMonster, i3k_get_string(self.btnName[2]), self._layout.vars.list, _isShowTransBtn)
            self:rightSpecialMonsterList(mapId, size, InfoTab[self.SpecialMonsterList], isSpecialMonster, i3k_get_string(self.btnName[3]), self._layout.vars.list,_isShowTransBtn)
        end

        -- self:rightNpcList(mapId, size)
        -- self:rightMonsterList(mapId, size)
    end
end

function wnd_MapBase:GetRightListState(mapId)
    local InfoTab = {}
    local count = 0

    --npc列表信息
    InfoTab[self.NpcList] = g_i3k_db.i3k_db_get_npc_list_info(mapId)

    --怪物列表信息（大于0） 有怪物才存储
    InfoTab[self.MonsterList] = g_i3k_db.i3k_db_get_monsters_list_info(mapId)

    --特殊怪物信息列表，邪灵怪
    InfoTab[self.SpecialMonsterList] = g_i3k_db.i3k_db_get_specal_monsters_list_info(mapId)

    for k, v in pairs(InfoTab) do
        if v then
            count = count + 1
        end
    end

    return InfoTab, count, InfoTab[self.MonsterList] == nil
end

function wnd_MapBase:CreatNpcItem(sortedList, mapId, size, rootListNode, isShowTranBtn)
    for i, v in ipairs(sortedList) do
        local npc = i3k_db_npc[i3k_db_npc_area[v].NPCID]
        local festivalTime = g_i3k_db.i3k_db_check_npc_show_time(npc)
        local isShow = npc.isShowInMapList == 1 and festivalTime
        if isShow then
            node = require(self.widgetsitem)()
            local npcFunctionName
            if self.NpcSuffix == self.NpcFunSuffix then
                npcFunctionName = g_i3k_db.i3k_db_get_npc_list_function(npc.ID)
            else  --if self.NpcSuffix == self.NpcTypeSuffix then  --只有两种类型不做两次判断
                npcFunctionName = npc.typeDesc
            end
            node.vars.name:setText(npc.remarkName .. npcFunctionName)
            local targetPos = i3k_db_npc_area[v].pos
            local NPCID = i3k_db_npc_area[v].NPCID
            local needValue = {pos = targetPos, mapId = mapId, size = size, areaId = NPCID, flage = 1}
            node.vars.selectBtn:onClick(self, self.walkToPos, needValue)
            local needValue2 = {isNpc = true, mapId = mapId, areaId = v, pos = targetPos}
            node.vars.transBtn:onClick(self, self.transToPos, needValue2)
            if self._isShowNpcTransBtn ~= nil then --dungeonmap.lua 中需要控制是否显示传送按钮
                node.vars.transBtn:setVisible(self._isShowNpcTransBtn)
            end
			if node.vars.lamp_icon then
				local isSpringRollOpen = g_i3k_game_context:checkSpringRollOpen()
				local isSpringRollNpc = g_i3k_game_context:checkSpringRollNpc(NPCID)
				node.vars.lamp_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_spring_roll.rollConfig.npcImageID))
				node.vars.lamp_icon:setVisible(isSpringRollOpen and isSpringRollNpc)
				if not isSpringRollOpen then
					local world = i3k_game_get_world()
					g_i3k_game_context:setSpringRollGroupID(0)
					for i, e in ipairs(i3k_db_spring_roll.npcConfig) do
						for k, v in pairs(e) do
							local Entity = world:GetNPCEntityByID(k)
							if Entity then
								Entity:ChangeSpringRollIcon()
							end
						end
					end
				end
			end
            rootListNode:addItem(node)
        end
    end
end

function wnd_MapBase:CreatMonsterItem(points, mapID, size, rootListNode, isShowTranBtn)
    for _, v in ipairs(points) do
        local id = v.cfg.monsters[1]
        local node = require(self.widgetsitem)()
        node.vars.name:setText(g_i3k_db.i3k_db_get_monster_lvl_name(id))
        local needValue = {pos = v.cfg.pos, mapId = mapID, size = size, areaId = id, flage = 3}
        node.vars.selectBtn:onClick(self, self.walkToPos, needValue)
        local needValue2 = {isNpc = false, mapId = mapID, areaId = v.point, pos = v.cfg.pos}
        node.vars.transBtn:onClick(self, self.transToPos, needValue2)
        if self._isShowMonsterTransBtn ~= nil then --dungeonmap.lua 中需要控制是否显示传送按钮
            node.vars.transBtn:setVisible(self._isShowMonsterTransBtn)
        end
		if node.vars.lamp_icon then
			node.vars.lamp_icon:setVisible(false)
        end
        rootListNode:addItem(node)
    end
end

function wnd_MapBase:CreatSpecialMonsterItem(points, mapID, size, rootListNode)
    local showMonsters = {}
    for _, id in ipairs(points) do
        local monsterId = i3k_db_war_zone_map_monster[id]
        if not showMonsters[monsterId] then
            showMonsters[monsterId] = true
            local node = require('ui/widgets/fmddtt2')()
            node.vars.name:setText(g_i3k_db.i3k_db_get_monster_lvl_name(monsterId))
            node.vars.transBtn:setVisible(false)
            node.vars.selectBtn:onClick(self,function(sender)
                    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5776))
                end
            )
            
            rootListNode:addItem(node)
        end
    end
end

function wnd_MapBase:rightNpcList( mapId, size, sortedList, isNpc, btnName, rootListNode)
    local hasAddNpc = false
    for i, v in ipairs(sortedList) do
        local npc = i3k_db_npc[i3k_db_npc_area[v].NPCID]
        local isShow = npc.isShowInMapList == 1
        if isShow then
            if not hasAddNpc then
                local node = require(self.widgetsTitile)()
                rootListNode:addItem(node)
                node.vars.btn:onClick(self, self.openOrPickup, {mapId = mapId, size = size, BtnIndex = self.NpcList})
                hasAddNpc = true
                if isNpc then
                    node.vars.pickup:hide()
                    node.vars.open:show()
                    node.vars.btn:stateToPressed(true)
                else
                    node.vars.pickup:show()
                    node.vars.open:hide()
                    node.vars.btn:stateToNormal(true)
                end
                node.vars.name:setText(btnName)
            end
            if isNpc then
                local node = require(self.widgetsitem)()
                local npcFunctionName
                if self.NpcSuffix == self.NpcFunSuffix then
                    npcFunctionName = g_i3k_db.i3k_db_get_npc_list_function(npc.ID)
                else  --if self.NpcSuffix == self.NpcTypeSuffix then  --只有两种类型不做两次判断
                    npcFunctionName = npc.typeDesc
                end
                node.vars.name:setText(npc.remarkName .. npcFunctionName)
                local targetPos = i3k_db_npc_area[v].pos
                local NPCID = i3k_db_npc_area[v].NPCID
                local needValue = {pos = targetPos, mapId = mapId, size = size, areaId = NPCID, flage = 1}
                node.vars.selectBtn:onClick(self, self.walkToPos, needValue)
                local needValue2 = {isNpc = true, mapId = mapId, areaId = v, pos = targetPos}
                node.vars.transBtn:onClick(self, self.transToPos, needValue2)
				if node.vars.lamp_icon then
					local isSpringRollOpen = g_i3k_game_context:checkSpringRollOpen()
					local isSpringRollNpc = g_i3k_game_context:checkSpringRollNpc(NPCID)
					node.vars.lamp_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_spring_roll.rollConfig.npcImageID))
					node.vars.lamp_icon:setVisible(isSpringRollOpen and isSpringRollNpc)
				end
                rootListNode:addItem(node)
            end
        end
    end
end

function wnd_MapBase:rightMonsterList( mapId, size, haveMonsterArea, isMonster, btnName, rootListNode)
    local node = require(self.widgetsTitile)()
    node.vars.btn:onClick(self, self.openOrPickup, {mapId = mapId, size = size, BtnIndex = self.MonsterList})
    rootListNode:addItem(node)
    if isMonster then
        node.vars.open:show()
        node.vars.pickup:hide()
        node.vars.btn:stateToPressed(true)
    else
        node.vars.pickup:show()
        node.vars.open:hide()
        node.vars.btn:stateToNormal(true)
    end
    node.vars.name:setText(btnName)
	if node.vars.lamp_icon then
		node.vars.lamp_icon:setVisible(false)
	end
    if isMonster then
        self:addMonsterItem(haveMonsterArea, mapId, size, rootListNode)
    end
end

function wnd_MapBase:addMonsterItem( points, mapID, size, rootListNode)
    for _, v in ipairs(points) do
        local id = v.cfg.monsters[1]
        local node = require(self.widgetsitem)()
        node.vars.name:setText(g_i3k_db.i3k_db_get_monster_lvl_name(id))
        local needValue = {pos = v.cfg.pos, mapId = mapID, size = size, areaId = id, flage = 3}
        node.vars.selectBtn:onClick(self, self.walkToPos, needValue)
        local needValue2 = {isNpc = false, mapId = mapID, areaId = v.point, pos = v.cfg.pos}
        node.vars.transBtn:onClick(self, self.transToPos, needValue2)
        rootListNode:addItem(node)
    end
end

function wnd_MapBase:rightSpecialMonsterList( mapId, size, haveMonsterArea, isMonsterSpecial, btnName, rootListNode)
    local mapType = i3k_game_get_map_type()
    if mapType == g_GOLD_COAST then
        local open = self.BtnState[self.SpecialMonsterList]
        local showMonsters = {}
        if #haveMonsterArea > 0 then
            local node = require("ui/widgets/fmddtt")()
            local isOpen = self.BtnState[self.SpecialMonsterList]
            node.vars.open:setVisible(isOpen)
            node.vars.pickup:setVisible(not isOpen)
            node.vars.btn[isOpen and "stateToPressed" or  "stateToNormal"](node.vars.btn)
            node.vars.name:setText(i3k_get_string(self._rightType[self.SpecialMonsterList].txtID))
            node.vars.btn:onClick(self, self.openOrPickup, {mapId = self._curMapID, size = size, BtnIndex = self.SpecialMonsterList})
            self._layout.vars.list:addItem(node)
        end
        if open then
            for _, id in ipairs(haveMonsterArea) do
                local monsterId = i3k_db_war_zone_map_monster[id]
                if not showMonsters[monsterId] then
                    showMonsters[monsterId] = true
                    local node = require('ui/widgets/fmddtt2')()
                    node.vars.name:setText(g_i3k_db.i3k_db_get_monster_lvl_name(monsterId))
                    node.vars.transBtn:setVisible(false)
                    node.vars.selectBtn:onClick(
                        self,
                        function(sender)
                            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5776))
                        end
                    )
                    self._layout.vars.list:addItem(node)
                end
            end
        end
        self._layout.vars.specialDesc:setVisible(#haveMonsterArea > 0)
        self._layout.vars.specialDesc:setText(i3k_get_string(5709))
    end
end

function wnd_MapBase:openList(sender, needValue)

	for i,v in ipairs(self.BtnState) do
		if i == 1 then
			self.BtnState[i] = needValue.isShowNpc
		else
			self.BtnState[i] = not needValue.isShowNpc
		end
	end
	self:RefreshList(needValue.mapId, needValue.size, self.BtnState[self.NpcList], self.BtnState[self.MonsterList], self.BtnState[self.SpecialMonsterList])
	-- RefreshList(self._layout.vars, needValue.mapId, needValue.size, self.BtnState[1], self.BtnState[2], self.BtnState[3], self, self.btnName)
	-- self:onRefreshList(needValue.mapId, self._size, self._isNpcOpen, self._isMonsterPointOpen)
end
function wnd_MapBase:openOrPickup(sender, needValue)
    g_i3k_ui_mgr:PopupTipMessage(needValue.BtnIndex)
	self.BtnState[needValue.BtnIndex]=not self.BtnState[needValue.BtnIndex]
	self:RefreshList(needValue.mapId, needValue.size, self.BtnState[self.NpcList], self.BtnState[self.MonsterList], self.BtnState[self.SpecialMonsterList])
	-- RefreshList(self._layout.vars, needValue.mapId, needValue.size, self.BtnState[1], self.BtnState[2], self.BtnState[3], self, self.btnName)
	-- self:onRefreshList(needValue.mapId, self._size, self._isNpcOpen, self._isMonsterPointOpen)
end

function wnd_MapBase:AllowTransToPos(sender, needValue, needName)
    local descText = string.format(i3k_get_string(1491, needName, 1))
	local function callback(isOk)
		if isOk then
			self._targetPos = needValue.pos
			local hero = i3k_game_get_player_hero()
			g_i3k_game_context:ClearFindWayStatus()
			hero:StopMove(true);
			g_i3k_game_context:setUnlockSkillStatus(false)
			if needValue.isNpc then
				i3k_sbean.transToNpc(needValue.mapId, needValue.areaId)
			else
				i3k_sbean.transToMonster(needValue.mapId, needValue.areaId)
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

function wnd_MapBase:RefreshPathSpriteTable(mapId, pos, size, needValue, taskType)
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
	self._targetPos = pos
end


function wnd_MapBase:searchPath(sender, needValue)
	local size = needValue.size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local targetMapId = needValue.mapId
	local mousePos = g_i3k_ui_mgr:GetMousePos()
	local pos = sender:convertToNodeSpace(mousePos)
	local hero = i3k_game_get_player_hero()
	local needPos = i3k_minmap_pos_to_engine_world_pos(pos, size.width, size.height, targetMapId, needValue.isForcewar)
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
function wnd_MapBase:createTargetPos(toPos, size, mapId)
	local mapPos = i3k_engine_world_pos_to_minmap_pos(toPos, size.width, size.height, mapId, nil, true)
	createTargetPos(mapPos, mapId)
end

function wnd_create(layout)
	local wnd = wnd_MapBase.new();
	wnd:create(layout);

	return wnd;
end
