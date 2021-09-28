local require = require;
mapBase = i3k_class("mapBase");

----常量重命名为大写
local HERO_IMG_ID       = 610
local NPC_IMG_ID        = 611
local TEAMMATE_IMG_ID   = 612
local MONSTER_IMG_ID    = 613
local TRANS_IMG_ID      = 614
local ROAD_IMG_ID       = 935
local ESCORTCAR_IMG_ID  = 2425
local DRAGON_IMG_ID     = 4853
local PVE_PEACE_BOSS_IMG_ID = 5758
local PVE_BATTLE_BOSS_IMG_ID = 5759
local PVE_BATTLE_SUPERBOSS_IMG_ID = 5760
local DESERT_BATTLE_RES = 7819
local PRINCESS_MARRY_RES = 8722
local TASK_SPY_STORY = 6553

-- 帮派夺旗底图背景图片id
local HEIGH_LEVEL_FLAG_UNOCCUPIED = 5125
local LOW_LEVEL_FLAG_OCCUPIED = 5126
local HEIGH_LEVEL_FLAG_OCCUPIED = 5127


local FACTION_FLAG_TANWEI_IMGS =
{
    4115, -- 帮派夺旗摊位，未占领的摊位旗子图标
    4116, -- 己方占领
    4117, -- 敌方占领
}
local FACTION_FLAG_IMGS =
{
    4118, -- 帮派夺旗 旗子 未占领
    4119, -- 己方占领
    4120, -- 敌方占领
}

local DEFENCE_WAR_TYPE_FLAG = "flag"
local DEFENCE_WAR_TYPE_TOWER = "tower"
local DEFENCE_WAR_TYPE_REBORN = "reborn"

function mapBase:ctor()
    self._teamMateSprites = {}
    self._npcSpriteTable = {}
    self._transSpriteTable = {}
    self._forcewarMateSprites = {}
    self._forcewarTowerSprites = {}
    self._timeCounter = 0

    -- 保存创建出来精灵的引用
    self._heroSprite = nil
    self._teammateSprites = {} -- 不是一个数组
    self._escortCarSprite = nil
    self._targetImg = nil
    ------
    self._parent = nil
    self._scroll = nil
    self._nodeSize = nil

    self._isForceWar = false -- 这个变量最好也弄成该类中的全局量，因为在onUpdate的时候会用到这个参数
    self._isMiniMap = false
    self._forcewarTeammateSprite = nil

    self._factionFlags = {}
	self._princessSprite = nil --除了角色之外的动态图片 公主出嫁
	self._catchSpiritBoss = nil
end

-- 根据图片id创建一个精灵
function mapBase:createSprite(imgId)
	local img = i3k_db_icons[imgId].path
	local imgExcept = i3k_checkPList(img)
	local sprite = cc.Sprite:createWithSpriteFrameName(imgExcept)
	if g_i3k_ui_mgr:JudgeIsPad() then
		sprite:setScale(0.75)
	end
    if sprite == nil then
        error("精灵创建失败,"..imgExcept.." 没有找到该资源.")
    end
	return sprite
end

-- 创建寻路目标终点位置特效
function mapBase:createTargetPosImg()
	local path = "ui/widgets/sjdttx"
	local node = require(path)()
	local anis = node.anis.c_dakai
	if anis then
		anis.stop()
		anis.play()
	end
	return node
end
---------------------------------
--龙运
function mapBase:createDragonPoint(mapID,nodeSize)
    local spriteTable = {}
    local npcTable = i3k_db_faction_dragon.dragonCfg.dragonIDs
    for i, v in ipairs(npcTable) do
        local sprite = self:createSprite(DRAGON_IMG_ID)
        local npcPos = i3k_db_faction_dragon.dragonInfo[v].position
		local needPos = i3k_engine_world_pos_to_minmap_pos(npcPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
        table.insert(spriteTable, {sprite = sprite, needPos = needPos})
    end
    return spriteTable
end
function mapBase:addDragonPoint(parent, mapID, nodeSize)
    local spriteTable = self:createDragonPoint(mapID,nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end

--跨服pve 和平区 boss图标
function mapBase:createPveBossIcon(mapID,nodeSize)
    local spriteTable = {}
	if g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.peaceMapID then
		local bossTable = i3k_db_peaceMapMonster
		for i, v in ipairs(bossTable) do
			local sprite = self:createSprite(PVE_PEACE_BOSS_IMG_ID)
			local bossPos = v.position
			local needPos = i3k_engine_world_pos_to_minmap_pos(bossPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
			table.insert(spriteTable, {sprite = sprite, needPos = needPos})
		end
	elseif g_i3k_game_context:GetWorldMapID() == i3k_db_crossRealmPVE_cfg.battleMapID then
		local bossTable = i3k_db_battleMapMonster
		for i, v in ipairs(bossTable) do
			local sprite = self:createSprite(PVE_BATTLE_BOSS_IMG_ID)
			local bossPos = v.position
			local needPos = i3k_engine_world_pos_to_minmap_pos(bossPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
			table.insert(spriteTable, {sprite = sprite, needPos = needPos})
		end
		local superBossPos = i3k_db_crossRealmPVE_cfg.battleMapSuperBoss.superBossLocation
		local needPos = i3k_engine_world_pos_to_minmap_pos(superBossPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
		table.insert(spriteTable, {sprite = self:createSprite(PVE_BATTLE_SUPERBOSS_IMG_ID), needPos = needPos})
	end
    return spriteTable
end

function mapBase:addPveBossIcon(parent, mapID, nodeSize)
    local spriteTable = self:createPveBossIcon(mapID,nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end

---------------------------------
--创建决战荒漠宝箱
function mapBase:createResPoint(mapID,nodeSize)
	--TODO
    local spriteTable = {}
    local resTable = i3k_db_desert_resInfo.resPos --i3k_db_desert_resInfo[1]
    for i, v in ipairs(resTable) do
        local sprite = self:createSprite(DESERT_BATTLE_RES)
        local resPos = v.pos
		local needPos = i3k_engine_world_pos_to_minmap_pos(resPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
        table.insert(spriteTable, {sprite = sprite, needPos = needPos})
    end
    return spriteTable
end
--添加宝箱
function mapBase:addResPoint(parent, mapID, nodeSize)
    local spriteTable = self:createResPoint(mapID,nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end
--创建密探任务标识
function mapBase:createSpyPoint(mapID,nodeSize)
    --TODO
    local spriteTable = {}
    local taskTable = g_i3k_game_context:getSpyStoryTasks()
    local camp = g_i3k_game_context:getSpyStoryCampType()
    local cfg = i3k_db_spy_story_task[camp]
    for i, v in pairs(taskTable) do
        if cfg[i] then
            local sprite = self:createSprite(TASK_SPY_STORY)
            local tbl = { point = nil, mapId = nil, transport = nil, taskCat = TASK_CATEGORY_SPYSTORY}
            g_i3k_game_context:switchDoTask(tbl, cfg[i], i,TASK_CATEGORY_SPYSTORY)
            local resPos = tbl.point
            local needPos = i3k_engine_world_pos_to_minmap_pos(resPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
            table.insert(spriteTable, {sprite = sprite, needPos = needPos})
        end
    end
    return spriteTable
end
--添加密探任务提示
function mapBase:addSpyPoint(parent, mapID, nodeSize)
    local spriteTable = self:createSpyPoint(mapID,nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end
---------------------------------
-- 创建并返回npc列表
function mapBase:createNPCs(mapID, nodeSize)
    local spriteTable = {}
    local npcTable = i3k_db_dungeon_base[mapID].npcs
    for i, v in ipairs(npcTable) do
        local realNpcID = i3k_db_npc_area[v].NPCID
        if i3k_db_npc[realNpcID].isShowInMapList == 1 then -- 只显示在右侧列表的npc
        local imgID = g_i3k_db.i3k_db_get_npc_minimap_img(realNpcID)
        local sprite = self:createSprite(imgID or NPC_IMG_ID)
        local npcPos = i3k_db_npc_area[v].pos
		local needPos = i3k_engine_world_pos_to_minmap_pos(npcPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
        local tag = i3k_db_npc_area[v].NPCID -- 这个id就是npc表中的id
        table.insert(spriteTable, {sprite = sprite, needPos = needPos, tag = tag})
        end
    end
    return spriteTable
end
-- 将创建出来的npc精灵添加到父控件中
function mapBase:addNPCs(parent, mapID, nodeSize)
    local spriteTable = self:createNPCs(mapID, nodeSize) -- TODO 这个表应该全局存起来，在释放的时候释放掉？？
    local mapNPC = g_i3k_game_context:getMiniMapNPC()
    for i,v in ipairs(spriteTable) do
        if not mapNPC or mapID ~= g_i3k_game_context:GetWorldMapID() then
            parent:addChild(v.sprite)
            v.sprite:setPosition(v.needPos)
            v.sprite:setRotation(-self._roate or 0)
        else
            if mapNPC[v.tag] then
                parent:addChild(v.sprite)
                v.sprite:setPosition(v.needPos)
                v.sprite:setRotation(-self._roate or 0)
            end
        end
    end
end

----------------------------------
-- 创建旗子
function mapBase:createFlag(mapID, nodeSize)
    local roleLine = g_i3k_game_context:GetCurrentLine()
    local spriteTable = {}
    if i3k_db_faction_map_flag[mapID]  and roleLine == i3k_db_faction_rob_flag.faction_rob_flag.faction_rob_line then
        local flag_data = g_i3k_game_context:GetFactionFlagData()
		local mySectId = g_i3k_game_context:GetSectId()
		local npcTable = i3k_db_faction_map_flag[mapID].npcs
		local mapPos = i3k_db_faction_map_flag[mapID].flagPos
		local tmpPos = {x =mapPos[1],z = mapPos[3] }
		local tmp_icon = i3k_db_faction_rob_flag.faction_rob_flag.faction_rob_flag_icon
        if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(mapID) then
            tmp_icon = HEIGH_LEVEL_FLAG_UNOCCUPIED -- 高等级未被占领
        end
		if flag_data[mapID] and flag_data[mapID].curSect.sectId ~= 0 then
			if flag_data[mapID].curSect.sectId == mySectId then
				tmp_icon = i3k_db_faction_rob_flag.faction_rob_flag.faction_my_flag_icon
			else
				tmp_icon = i3k_db_faction_rob_flag.faction_rob_flag.faction_enemy_flag_icon
			end
		end
		local sprite = self:createSprite(tmp_icon)
        local needPos = i3k_engine_world_pos_to_minmap_pos(tmpPos, nodeSize.width, nodeSize.height, mapID, self._isForceWar)
        table.insert(spriteTable, {sprite = sprite, needPos = needPos})
    end
    return spriteTable
end
-- 添加旗子
function mapBase:addMapFlag(parent, mapID, nodeSize)
    local spriteTable = self:createFlag(mapID, nodeSize) -- 可能是一个空表
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end

-------------------------------------
-- 创建传送点
function mapBase:createTransPoint(mapId, nodeSize)
    local spriteTable = {}
    local transPointTable = i3k_db_dungeon_base[mapId].tranferpoints
    for i,v in ipairs(transPointTable) do
        local sprite = self:createSprite(TRANS_IMG_ID)
        local transPos = i3k_db_transfer_point[v].pos
		local needPos = i3k_engine_world_pos_to_minmap_pos(transPos, nodeSize.width, nodeSize.height,mapId, self._isForceWar)
        table.insert(spriteTable, {sprite = sprite, needPos = needPos})
    end
    return spriteTable
end
-- 添加传送点
function mapBase:addTransPoint(parent, mapId, nodeSize)
    local spriteTable = self:createTransPoint(mapId, nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
        v.sprite:setRotation(-self._roate or 0)
    end
end

----------------------------------------
-- 创建队友精灵
function mapBase:createTeammate(mapId, nodeSize)
    local teamMembers = g_i3k_game_context:GetTeamMembers()
    local spriteTable = {}
    for i,v in ipairs(teamMembers) do
        local merberState = g_i3k_game_context:GetTeamMemberState(v)
		if merberState and merberState ~= 0 then
			local location = g_i3k_game_context:GetTeamMemberPosition(v)
			if location then
				if mapId == location.mapId then
					local sprite = self:createSprite(TEAMMATE_IMG_ID)
					local needPos = i3k_engine_world_pos_to_minmap_pos(location.pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                    table.insert(spriteTable, {id = v, sprite = sprite, needPos = needPos, mapId = mapId})
				end
			end
		end
    end
    return spriteTable
end
-- 添加队友到父控件
function mapBase:addTeammate(parent, mapId, nodeSize)
    local spriteTable = self:createTeammate(mapId, nodeSize)
    self._teammateSprites = spriteTable
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end
-- 更新队友节点
function mapBase:updateTeamMate(roleId, mapId, pos)
    local isHave = false
    local nodeSize = self._nodeSize
    for i = #self._teammateSprites, 1, -1 do
        local v = self._teammateSprites[i]
        local state = g_i3k_game_context:GetTeamMemberState(v.id)
		local isTeamMember = g_i3k_game_context:IsTeamMember(v.id)
        -- TODO 离开队伍并不会执行到这个函数，故不会清除掉
		if not state or state == 0 or not isTeamMember or (v.id == roleId and mapId ~= self._mapId) then
			self._parent:removeChild(v.sprite)
            -- self._teammateSprites[k] = nil
            table.remove(self._teammateSprites, i)
            isHave = true
        else
            if v.id == roleId and mapId == self._mapId then
				local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
				v.sprite:setPosition(needPos)
				isHave = true
				break
			end
        end
    end
    if not isHave and mapId == self._mapId then
		local heroId = g_i3k_game_context:GetRoleId()
		if heroId ~= roleId then
			local teamSprite = self:createSprite(TEAMMATE_IMG_ID)
			if teamSprite then
				local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                table.insert(self._teammateSprites, {id = roleId, sprite = teamSprite, needPos = needPos, mapId = mapId})
				self._parent:addChild(teamSprite)
				teamSprite:setPosition(needPos)
			end
		end
	end
end
------------------------------------------

--创建双方阵营雕像水晶
function mapBase:createDoubleSideTowers(mapId, nodeSize)
    local spriteTable = {}
    local teamStatues = g_i3k_game_context:getForceWarStatuesInfo()--己方，敌方
    --local bwtype = g_i3k_game_context:GetTransformBWtype()
	local forceType = g_i3k_game_context:GetForceType()
    for i, e in pairs(teamStatues) do
    local location = g_i3k_game_context:GetForceWarStatuesPosition(e.id)
		if location and mapId == location.mapId then
            local sprite = nil
            if e.bwtype == forceType then--己方
				sprite = self:createSprite(TEAMMATE_IMG_ID)
			else--敌方
				sprite = self:createSprite(MONSTER_IMG_ID)
			end
            local needPos = i3k_engine_world_pos_to_minmap_pos(location.pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
            table.insert(spriteTable, {id = e.id, sprite = sprite, needPos = needPos })
        end
    end
    return spriteTable
end
--添加双方阵营雕像水晶
function mapBase:addDoubleSideTowers(parent, mapId, nodeSize)
    local spriteTable = self:createDoubleSideTowers(mapId, nodeSize)
    self._forcewarTowerSprites = spriteTable
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
        v.sprite:setRotation(-self._roate or 0)
    end
end
--更新双方阵营雕像水晶(Invoke Function)
function mapBase:updateDoubleSideMateTowers(roleId, mapId, pos, tfbwtype)
    if self._scroll then
        local nodeSize = self._scroll:getContainerSize()
    	local world = i3k_game_get_logic():GetWorld()
    	local nowMapId = world._cfg.id
        --local bwtype = g_i3k_game_context:GetTransformBWtype()
		local forceType = g_i3k_game_context:GetForceType()
        local isHave = false
        local teamSprite = nil
        for i = #self._forcewarTowerSprites, 1, -1 do
            local v = self._forcewarTowerSprites[i]
            local isMember = g_i3k_game_context:IsForceWarStatues(v.id)--判断是否死亡
            if isMember then
                self._parent:removeChild(v.sprite)
                table.remove(self._forcewarTowerSprites, i)
                isHave = true
            else
                if v.id == roleId and mapId==nowMapId then
    				local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height,mapId, self._isForceWar)
    				v.sprite:setPosition(needPos)
    				isHave = true
    			end
            end
        end
        if not isHave and mapId == nowMapId then
            if tfbwtype == forceType then--己方
    			teamSprite = self:createSprite(TEAMMATE_IMG_ID)
    		else--敌方
    			teamSprite = self:createSprite(MONSTER_IMG_ID)
    		end
            local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
            table.insert(self._forcewarTowerSprites, {id = roleId, sprite = teamSprite, needPos = needPos})
            self._parent:addChild(teamSprite)
            teamSprite:setPosition(needPos)
        end
    end
end
-------------------------------
-- 势力战创建双方阵营成员
function mapBase:createDoubleSideMate(mapId, nodeSize)
    local teamMembers = g_i3k_game_context:getForceWarMemberInfo()--己方，敌方
    local heroId = g_i3k_game_context:GetRoleId()
	--local bwtype = g_i3k_game_context:GetTransformBWtype()
	local forceType = g_i3k_game_context:GetForceType()
    local spriteTable = {}
    for i,v in ipairs(teamMembers) do
        local location = g_i3k_game_context:GetForceWarMemberPosition(v.id)
		if location then
            if mapId == location.mapId and heroId ~= v.id then
                local spriteImgId = v.bwtype == forceType and TEAMMATE_IMG_ID or MONSTER_IMG_ID
                local sprite = self:createSprite(spriteImgId)
                local needPos = i3k_engine_world_pos_to_minmap_pos(location.pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                -- table.insert(spriteTable, {id = v.id, sprite = sprite, needPos = needPos})
                spriteTable[v.id] = {sprite = sprite, needPos = needPos, bwtype = v.bwtype}
            end
        end
    end
    return spriteTable
end

-- 势力战添加双方阵营成员
function mapBase:addDoubleSideMate(parent, mapId, nodeSize)
    local spriteTable = self:createDoubleSideMate(mapId, nodeSize)
    self._forcewarMateSprites = spriteTable
    for i,v in pairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
        v.sprite:setRotation(-self._roate or 0)
    end
end

function mapBase:updateDoubleSideMate(roleId, mapId, pos, tfbwtype)
    if not self._isMiniMap then
        return
    end
    if self._scroll then
        local nodeSize = self._scroll:getContainerSize()
        --local bwtype = g_i3k_game_context:GetTransformBWtype()
		local forceType = g_i3k_game_context:GetForceType()
        local v = self._forcewarMateSprites[roleId]
        if v then
            local isMember = g_i3k_game_context:IsForceWarMember(roleId)
            if not isMember then
                self._scroll.removeChild(v.sprite)
                self._forcewarMateSprites[roleId] = nil
            else
                if tfbwtype ~= v.bwtype then
                    self._scroll:removeChild(v.sprite)
                    local imageId = forceType == tfbwtype and TEAMMATE_IMG_ID or MONSTER_IMG_ID
                    local sprite = self:createSprite(imageId)
                    self._scroll:addChild(sprite)
                    v.sprite = sprite
                    v.bwtype = tfbwtype
                end
                if pos then
                    local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                    v.sprite:setPosition(needPos)
                else -- 超出视野范围
                    self._scroll:removeChild(v.sprite)
                    self._forcewarMateSprites[roleId] = nil
                end
            end
        else
            if pos then
                local imageId = forceType == tfbwtype and TEAMMATE_IMG_ID or MONSTER_IMG_ID
                local sprite = self:createSprite(imageId)
                self._scroll:addChild(sprite)
                local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                sprite:setPosition(needPos)
                self._forcewarMateSprites[roleId] = {sprite = sprite, needPos = needPos, bwtype = tfbwtype}
            end
        end
    end
end

-------------------------------------------
-- 势力战场景地图，只创建队友（上面的方法需要移除掉）
function mapBase:createForcewarTeammate(data, iconId)
    local spriteTable = {}
    local nodeSize = self._nodeSize
    local mapId = self._mapId
    for k, v in pairs(data) do
        local pos = i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(v))
		local sprite = self:createSprite(iconId or TEAMMATE_IMG_ID)
        local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
        spriteTable[k] = {sprite = sprite, needPos = needPos}
    end
    return spriteTable
end
-- 势力战场景地图，添加/更新队友的位置
function mapBase:updateTeammatePos(data, iconId)
    if not self._forcewarTeammateSprite then -- 添加
		if not self._nodeSize then return end
        local sprites = self:createForcewarTeammate(data, iconId)
        for k, v in pairs(sprites) do
            self._parent:addChild(v.sprite)
            v.sprite:setPosition(v.needPos)
        end
        self._forcewarTeammateSprite = sprites
    else -- 更新
        for k, v in pairs(self._forcewarTeammateSprite) do
            if not data[k] then
                self._parent:removeChild(v.sprite)
                self._forcewarTeammateSprite[k] = nil
            else
                local nodeSize = self._nodeSize
                local mapId = self._mapId
                local pos = i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(data[k]))
                local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                v.sprite:setPosition(needPos)
            end
        end
    end
end
function mapBase:updateSpiritBossPos(data, iconId)
    if not self._catchSpiritBoss then -- 添加
		if not self._nodeSize then return end
        local sprites = self:createForcewarTeammate(data, iconId)
        for k, v in pairs(sprites) do
            self._parent:addChild(v.sprite)
            v.sprite:setPosition(v.needPos)
        end
        self._catchSpiritBoss = sprites
    else -- 更新
        for k, v in pairs(self._catchSpiritBoss) do
            if not data[k] then
                self._parent:removeChild(v.sprite)
                self._catchSpiritBoss[k] = nil
            else
                local nodeSize = self._nodeSize
                local mapId = self._mapId
                local pos = i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(data[k]))
                local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
                v.sprite:setPosition(needPos)
            end
        end
    end
end

-------------------------------------------
-- 创建人物主将
function mapBase:createHero(nodeSize)
    local hero = i3k_game_get_player_hero()
	local heroPos = hero._curPosE
    local mapId = self._mapId
	local needPos = i3k_engine_world_pos_to_minmap_pos(heroPos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
    local heroSprite = self:createSprite(HERO_IMG_ID)
    return heroSprite, needPos
end
-- 添加人物到父控件中
function mapBase:addHero(parent, scroll, nodeSize)
    local heroSprite, needPos = self:createHero(nodeSize)
    local containerSize = scroll:getContainerSize()
    if needPos.x < 0 or needPos.y < 0 or needPos.x > containerSize.width or needPos.y > containerSize.height then
		return
	end
    self._heroSprite = heroSprite -- 绑定引用
    parent:addChild(heroSprite, 1)
    heroSprite:setPosition(needPos)
    self:updateHeroDirect()
end
-- 更新人物朝向(传入一个引用)
function mapBase:updateHeroDirect()
    local sprite = self._heroSprite
    local hero = i3k_game_get_player_hero()
    if hero and hero._entity and sprite then
        local rotation = hero._entity:GetRotation()
        local dir = i3k_vec3_clone(rotation)
        local angle = math.deg(dir.y-math.pi)
        sprite:setRotation(angle)
    end
end
function mapBase:updateHeroPos()
    local sprite = self._heroSprite
    local hero = i3k_game_get_player_hero()
    if hero and sprite then
        local heroPos = hero._curPosE
        local size = nil
        if self._isMiniMap then
            if self._scroll then
                size = self._scroll:getContainerSize()
            end
        else
            size = self._parent:getContentSize()
        end
        local needPos = i3k_engine_world_pos_to_minmap_pos(heroPos, size.width, size.height, nil, self._isForceWar)
        if self._isMiniMap then
            self:setInnerContainerPos(needPos)
        end
        sprite:setPosition(needPos)
    end
end
function mapBase:onUpdateHero(dTime)
    if self._heroSprite then
        self:updateHeroDirect()
        self:updateHeroPos()
    end
end
------------------------------
-- 创建镖车
function mapBase:createEscortCar(mapId, nodeSize)
    local spriteTable = {}
    if g_i3k_game_context:GetTransportState() == 1 then
		local hero = i3k_game_get_player_hero()
		local MapId, pos, rotate = g_i3k_game_context:GetEscortCarLocation()
		if MapId and MapId == mapId then
			local CarSprite = self:createSprite(ESCORTCAR_IMG_ID)
			pos = i3k_logic_pos_to_world_pos(pos)
			local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
            table.insert(spriteTable, {sprite = CarSprite, needPos = needPos})
		end
	end
    return spriteTable
end
-- 添加镖车, #spriteTable = 1
function mapBase:addEscortCar(parent, mapId, nodeSize)
    local spriteTable = self:createEscortCar(mapId, nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
        self._escortCarSprite = v
    end
end
-- 更新镖车位置
function mapBase:updateEscortCar()
    local spriteTable = self._escortCarSprite
    local hero = i3k_game_get_player_hero()
	local MapId, pos, rotate = g_i3k_game_context:GetEscortCarLocation()
    if spriteTable then
        local size = self._parent:getContentSize()
        pos = i3k_logic_pos_to_world_pos(pos)
    	local needPos = i3k_engine_world_pos_to_minmap_pos(pos, size.width, size.height, MapId, self._isForceWar)
        spriteTable.sprite:setPosition(needPos.x, needPos.y)
    end
end
--------------------------------
-- 创建寻路路径点
function mapBase:createPathPoints(posTable, nodeSize, mapId)
	local spriteTable = {}
	for i,v in ipairs(posTable) do
		if i%10==0 then
			local needPos = i3k_engine_world_pos_to_minmap_pos(v, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
			local pathSprite = self:createSprite(ROAD_IMG_ID)
			table.insert(spriteTable, {sprite = pathSprite, needPos = needPos})
		end
	end
	return spriteTable
end
-- 添加寻路路径点
function mapBase:addPathPoints(parent, posTable, nodeSize, mapId)
    local spriteTable = self:createPathPoints(posTable, nodeSize, mapId)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end
------------------------------------
-- 创建怪物
function mapBase:createMonster(mapId, nodeSize)
    local hero = i3k_game_get_logic():GetPlayer():GetHero()
	local monsterTable = hero._alives[2]
    local spriteTable = {}
    for i,v in pairs(monsterTable) do
        local guid = string.split(v.entity._guid, "|")
		local superClass = guid[1]
		local onlyId = tonumber(guid[2])
		if superClass=="i3k_monster" then
			local sprite = self:createSprite(MONSTER_IMG_ID)
            local needPos = i3k_engine_world_pos_to_minmap_pos(v.entity._curPosE, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
            table.insert(spriteTable, {sprite = sprite, needPos = needPos})
        end
    end
    return spriteTable
end
-- 添加怪物
function mapBase:addMonster(parent, mapId, nodeSize)
    local spriteTable = self:createMonster(mapId, nodeSize)
    for i,v in ipairs(spriteTable) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
        v.sprite:setRotation(-self._roate or 0)
    end
end

-- 创建刷怪区域刷怪点，并显示怪的数量
function mapBase:createMonsterWithCount(mapId, nodeSize, monsters)
    local sprites = {}
    for k, v in pairs(monsters) do
        local spawnPoint = i3k_db_spawn_point[k].pos
        local count = v
        local sprite = self:createSprite(MONSTER_IMG_ID)
        local needPos = i3k_engine_world_pos_to_minmap_pos(spawnPoint, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
        table.insert(sprites, {sprite = sprite, needPos = needPos})
    end
    return sprites
end

function mapBase:addMonsterWithCount(parent, mapId, nodeSize, monsters)
    local sprites = self:createMonsterWithCount(mapId, nodeSize, monsters)
    for i, v in ipairs(sprites) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end

function mapBase:getFactionFlagImgID(statusID, flagID)
    local flag_center_id = 7005 -- 帮派战表-帮派战通用配置表-旗子矿-旗子id
    local myType = g_i3k_game_context:GetForceType()
    if flagID == flag_center_id then
        local index = statusID -- == 0 and 0 or (myType == statusID and 1 or 2 )
        return FACTION_FLAG_IMGS[index + 1]
    else
        local index = statusID -- == 0 and 0 or (myType == statusID and 1 or 2 )
        return FACTION_FLAG_TANWEI_IMGS[index + 1]
    end
end

function mapBase:createFactionFightFlag(mapId, nodeSize, status)
    local cfg = i3k_db_faction_fight_cfg.flags
    local sprites = {}
    local myType = g_i3k_game_context:GetForceType()
    for i, v in ipairs(cfg) do
        local imgID = self:getFactionFlagImgID(status[i], v.flagID)
        local sprite = self:createSprite(imgID)
        local needPos = i3k_engine_world_pos_to_minmap_pos(v.pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
        table.insert(sprites, {sprite = sprite, needPos = needPos})
    end
    return sprites
end
-- 添加帮派夺旗战的旗子
function mapBase:addFactionFightFlagImpl(parent, mapId, nodeSize, status)
    local sprites = self:createFactionFightFlag(mapId, nodeSize, status)
    for i, v in ipairs(sprites) do
        parent:addChild(v.sprite)
        table.insert(self._factionFlags, v.sprite)
        v.sprite:setPosition(v.needPos)
    end
end

function mapBase:removeAllFactionFlags()
    for i, e in ipairs(self._factionFlags) do
        self._parent:removeChild(e)
    end
    self._factionFlags = {}
end

--------------城战相关地图-------------------
function mapBase:getDefenceWarIcon(type, forceType)
    local icons = i3k_db_defenceWar_minimap_icons
    return icons[type][forceType]
end

function mapBase:createDefenceWarSprite(list, nodeSize, mapId, type)
    local sprites = {}
    local res = g_i3k_db.i3k_db_parase_position_list(list)
    for k, v in ipairs(res) do 
        local imgID = self:getDefenceWarIcon(type, v.forceType)
        local sprite = self:createSprite(imgID)
        local needPos = i3k_engine_world_pos_to_minmap_pos(v.pos, nodeSize.width, nodeSize.height, mapId, self._isForceWar)
        table.insert(sprites, {sprite = sprite, needPos = needPos})
    end
    return sprites
end

function mapBase:addDefenceWarIcons(reviveFlag, arrayTower)
    local parent = self._parent
    local mapId = self._mapId   
    local nodeSize = self._nodeSize
    if not parent then return end
    if not mapId then return end
    if not nodeSize then return end

    local sprites = self:createDefenceWarSprite(reviveFlag, nodeSize, mapId, DEFENCE_WAR_TYPE_FLAG)
    for i, v in ipairs(sprites) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end

    local sprites2 = self:createDefenceWarSprite(arrayTower, nodeSize, mapId, DEFENCE_WAR_TYPE_TOWER)
    for i, v in ipairs(sprites2) do
        parent:addChild(v.sprite)
        v.sprite:setPosition(v.needPos)
    end

    self:addDefenceWarRebornPlace()
end

-- 添加城战 复活点
function mapBase:addDefenceWarRebornPlace()
    local parent = self._parent
    if i3k_game_get_map_type() == g_DEFENCE_WAR then
        local mapID = self._mapId
        local cfg = i3k_db_defenceWar_dungeon[mapID]
        local pos = {cfg.rebornSide1, cfg.rebornSide2, cfg.rebornSide3,}
        for k, v in ipairs(pos) do 
            local imgID = self:getDefenceWarIcon(DEFENCE_WAR_TYPE_REBORN, k)
            local sprite = self:createSprite(imgID)
            local needPos = i3k_engine_world_pos_to_minmap_pos(v, self._nodeSize.width, self._nodeSize.height, mapID, self._isForceWar)
            if parent then
                parent:addChild(sprite)
                sprite:setPosition(needPos)
            end
        end
    end
end


---------------------------------
-- 小地图的通用函数
function mapBase:setInnerContainerPos(needPos)
    local containerSize = self._scroll:getContainerSize()
	local innerContainer = self._scroll:getInnerContainer()
	innerContainer:setAnchorPoint(needPos.x / containerSize.width, needPos.y / containerSize.height)
	local f_scrollContentSize = self._scroll:getContentSize()
	local anchorPoint = innerContainer:getAnchorPoint()
	if needPos.x > containerSize.width / 2 and (containerSize.width - needPos.x) <= f_scrollContentSize.width / 2 then
		anchorPoint.x = (containerSize.width - f_scrollContentSize.width / 2) / containerSize.width
	elseif needPos.x < containerSize.width / 2 and needPos.x <= f_scrollContentSize.width / 2 then
		anchorPoint.x = f_scrollContentSize.width / 2 / containerSize.width
	end
	if needPos.y > containerSize.height / 2 and (containerSize.height - needPos.y) <= f_scrollContentSize.height / 2 then
		anchorPoint.y = (containerSize.height - f_scrollContentSize.height / 2) / containerSize.height
	elseif needPos.y < containerSize.height / 2 and needPos.y <= f_scrollContentSize.height / 2 then
		anchorPoint.y = f_scrollContentSize.height / 2 / containerSize.height
	end
	innerContainer:setAnchorPoint(anchorPoint)
	innerContainer:setPosition(f_scrollContentSize.width / 2, f_scrollContentSize.height / 2)
end
function mapBase:isShowFunc(SpriteTable, heroPos, size)
	for k,v in pairs(SpriteTable) do
		local posx = v.sprite:getPositionX()
		local posy = v.sprite:getPositionY()
		if (math.abs(posx-heroPos.x)>size.width/2) or (math.abs(posy-heroPos.y)>size.height/2) then
			v.sprite:setVisible(false)
		else
			v.sprite:setVisible(true)
		end
	end
end
--控制加载的子节点的显隐
function mapBase:updateVisible(heroPos, size)
	self:isShowFunc(self._teammateSprites, heroPos, size)
	self:isShowFunc(self._npcSpriteTable, heroPos, size)
	self:isShowFunc(self._transSpriteTable, heroPos, size)
end
------------------------------ 下面是对外的接口 ----------------------------------
-- 该类不继承自base，所以需要手动调用onUpdate
-- 重构前的cocos的schedule方法替换为onUpdate
-- usage: 在需要打开地图的界面，在其onUpdate方法中，获取mapBase的实例然后调用
function mapBase:onUpdate(dTime)
    self._timeCounter = self._timeCounter + dTime
    if self._timeCounter > 0.1 then
        self:onUpdateHero(dTime)
        self._timeCounter = 0
    end
end
-- 释放引用资源
function mapBase:onRelease()
    self._teamMateSprites = {}
    self._npcSpriteTable = {}
    self._transSpriteTable = {}
    self._forcewarMateSprites = {}
    self._forcewarTowerSprites = {}
    self._timeCounter = 0

    self._heroSprite = nil
    self._teammateSprites = {}
    self._escortCarSprite = nil
    self._targetImg = nil

    self._parent = nil -- scene_map 中的父控件
    self._scroll = nil -- 小地图的父控件？
    self._nodeSize = nil

    self._isForceWar = false
    self._isMiniMap = false

    self._forcewarTeammateSprite = nil
	self._princessSprite = nil 
	self._catchSpiritBoss = nil
end

-- 创建寻路终点精灵
function mapBase:createTargetPos(needPos, mapId)
	if not self._parent then return end 
	self:clearTargetImg()
    local scale = i3k_engine_get_minimap_scale(mapId)
    if mapId == 3 then
        -- 由于三邪圣地的地图图片大小为512*512，而其他的地图为1024*1024，这里在程序中做一个特殊处理，保证显示的大小相同
        scale = scale / 2
    elseif mapId == 4001 then -- 泡温泉地图
        scale = scale / 3
    -- elseif i3k_game_get_map_type() == g_DEFENCE_WAR then
    --     scale = scale / 3
    end
	local img = self:createTargetPosImg()
	self._parent:addChild(img)
	img.rootVar:setPosition(needPos)
	if i3k_db_field_map[mapId] then
		img.rootVar:setRotation(-i3k_db_field_map[mapId].rotate)
	end
    if scale then
        img.rootVar:setScale(1 / scale / 4)
    end
	self._targetImg = img
    self._targetImg.root._alive = true -- 对象不是野指针的标志
end
-- 清除掉寻路目标的引用
function mapBase:clearTargetImg()
	if self._targetImg and self._targetImg.root._alive then
        self._targetImg.anis.c_dakai.stop()
		self._parent:removeChild(self._targetImg)
	end
    self._targetImg = nil
end

--添加地图中的图钉
function mapBase:addThumbtackNode(info, imageSize)
	local mapPos = i3k_engine_world_pos_to_minmap_pos(info.pos, imageSize.width, imageSize.height, info.mapId, false)
	local img = self:createSprite(6648)
	self._parent:addChild(img)
	img:setPosition(mapPos)

	if i3k_db_field_map[info.mapId] then
		img:setRotation(-i3k_db_field_map[info.mapId].rotate)
	end

	g_i3k_game_context:setThumbtack(info.index, info.mapId, {node = img, index = info.index, mapId = info.mapId, remarks = info.remarks, position = info.pos, thumbAddTime = info.thumbAddTime})
end

-- 清除掉图钉的引用
function mapBase:clearThumbtackImgBYID(index, mapid)
	local thumbtack = g_i3k_game_context:getThumbtack()[mapid]
	if thumbtack[index] == nil then return false end

	if thumbtack[index].node ~= nil then
		local allChild = self._parent:getAddChild()

		for _, v in pairs(allChild) do
			if v == thumbtack[index].node then
				self._parent:removeChild(v)
			end
		end
	end

	g_i3k_game_context:setThumbtack(index, mapid, nil)
end

-- 添加公主到父控件中
function mapBase:addPrincessSprite(parent, scroll, nodeSize)
	local pos = g_i3k_game_context:getPrincessMarryPosAndRotation()
	
	if not pos or not scroll or not nodeSize then
		return
	end
	
    local dynamicSprite = self:createSprite(PRINCESS_MARRY_RES)
    local containerSize = scroll:getContainerSize()
	local needPos = i3k_engine_world_pos_to_minmap_pos(pos, nodeSize.width, nodeSize.height, nil, false)
	
    if needPos.x < 0 or needPos.y < 0 or needPos.x > containerSize.width or needPos.y > containerSize.height then
		return
	end
	
    self._princessSprite = dynamicSprite -- 绑定引用
    parent:addChild(dynamicSprite, 1)
    dynamicSprite:setPosition(needPos)	
	return pos
end

function mapBase:updatePrincessPosAndRotation()
	local pos
	
	if not self._princessSprite then
		pos = self:addPrincessSprite(self._parent, self._scroll, self._nodeSize)
	else
		pos = g_i3k_game_context:getPrincessMarryPosAndRotation()			
	end
	
	if not pos then return end
	
    if self._princessSprite then
        local size = nil
		
        if self._isMiniMap then
            if self._scroll then
                size = self._scroll:getContainerSize()
            end
        else
            size = self._parent:getContentSize()
        end
		
        local needPos = i3k_engine_world_pos_to_minmap_pos(pos, size.width, size.height, nil, false)
		
        if self._isMiniMap then
            self:setInnerContainerPos(needPos)
        end
		
        self._princessSprite:setPosition(needPos)		
    end	
end
-----------------------------------------------------------------------------------
--创建场景地图（非主界面显示的miniMap)
function mapBase:createMap(scroll, nodeSize, mapId, node, isHeroCreate, isForceWar, roate)

    self._isMiniMap = false -- local isUpdateMap = false 旧代码中的这个值，改名字，用来判断是否是小地图
    self._isForceWar = isForceWar
	local parent = node
	local f_scroll = scroll

    self._parent = parent
    self._scroll = scroll
    self._mapId = mapId
    self._nodeSize = nodeSize
    self._roate = roate or 0  -- 旋转角度

    --创建并添加地图中的NPC
	self:addNPCs(parent, mapId, nodeSize)
    self:addMapFlag(parent, mapId, nodeSize)
    self:addTransPoint(parent, mapId, nodeSize)
    self:addEscortCar(parent, mapId, nodeSize)
    if isForceWar then
        if i3k_game_get_map_type() == g_FACTION_TEAM_DUNGEON then
            self:addTeammate(parent, mapId, nodeSize)
        else
            -- self:addDoubleSideMate(parent, mapId, nodeSize)
            self:addDoubleSideTowers(parent, mapId, nodeSize)--创建雕像水晶
        end
    else
		if i3k_game_get_map_type() == g_DESERT_BATTLE then
			self:addResPoint(parent, mapId, nodeSize)
		else
        self:addTeammate(parent, mapId, nodeSize)
		end
    end
    if isHeroCreate then
		self:addHero(parent, scroll, nodeSize)
	-- elseif heroSprite then -- 删掉这个精灵
	-- 	f_scroll:removeChild(heroSprite)
	-- 	heroSprite = nil
    end
    if g_i3k_game_context:GetIsInFactionZone() then
        self:addDragonPoint(parent, mapId, nodeSize)
    end
	if i3k_game_get_map_type() == g_GLOBAL_PVE then
		self:addPveBossIcon(parent, mapID, nodeSize)
	end
    if i3k_game_get_map_type() == g_SPY_STORY then 
        self:addSpyPoint(parent, mapID, nodeSize)
    end
end

-- 创建正邪势力战小地图
function mapBase:createForceWarMiniMap(scroll, nodeSize, mapId)
    self._isMiniMap = true -- local isUpdateMap = true
	local isForceWar = true
    self._isForceWar = true
    self._mapId = mapId
	local parent = scroll
    self._scroll = scroll
    self._parent = scroll
    self._nodeSize = nodeSize
    self._roate = 0  -- 旋转角度
    self:addHero(parent, scroll, nodeSize)
    self:addNPCs(parent, mapId, nodeSize)
    self:addMonster(parent, mapId, nodeSize)
    self:addTransPoint(parent, mapId, nodeSize)

    self:addDoubleSideMate(parent, mapId, nodeSize)
    self:addDoubleSideTowers(parent, mapId, nodeSize)--创建雕像水晶
end

-- 添加地图中帮派战旗子状态的对外接口
function mapBase:addFactionFightFlag(status)
    local parent = self._parent
    local mapId = self._mapId
    local nodeSize = self._nodeSize
    self:addFactionFightFlagImpl(parent, mapId, nodeSize, status)
end
