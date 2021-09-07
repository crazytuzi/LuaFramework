-- --------------------
-- 场景虚拟单位管理
-- hosr
-- --------------------
DramaVirtualUnit = DramaVirtualUnit or BaseClass()

function DramaVirtualUnit:__init()
    if DramaVirtualUnit.Instance then
        return
    end
    DramaVirtualUnit.Instance = self
    self.unitTable = {}
    self.listener = function() self:OnMapLoaded() end
    EventMgr.Instance:AddListener(event_name.scene_load, self.listener)
end

function DramaVirtualUnit:OnMapLoaded()
    for i,v in pairs(self.unitTable) do
        local map = v.map
        if SceneManager.Instance:CurrentMapId() == map then
            SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(v.uniqueid, v.dat, nil) -- 创建虚拟单位
            DataWorldNpc.data_world_npc[v.uniqueid] = {battleid = v.dat.battle_id, id = v.dat.id, baseid = v.dat.baseid , mapbaseid = map, posx = v.dat.x, posy = v.dat.y}
        end
    end
end

-- -------------------------
-- 参数说明：
-- unitId      单位场景ID
-- battleId    战场ID(1普通场景，0剧情场景)
-- baseId      单位的配置数据ID
-- name        单位的显示名称
-- mapId       单位所在的地图iD
-- x           单位X坐标
-- y           单位Y坐标
-- dir         单位朝向
-- act         单位动作
-- mode        单位创建后的出现方式
-- looks       单位外观数据
-- --------------------------
function DramaVirtualUnit:CreateUnit(action)
    local unitId = action.unit_id
    local battleId = action.battle_id
    local baseId = action.unit_base_id
    local name = action.msg
    local mapId = action.mapid
    local x = action.x
    local y = action.y
    local dir = action.val or 0
    local act = action.ext_msg
    local mode = action.mode
    local looks = action.looks
    local sex = action.sex
    local classes = action.classes
    local newType = action.newType
    if self.unitTable[unitId] ~= nil then
        --不处理相同单位重复创建
        return
    end

    --取出单位配置数据
    local baseData = DataUnit.data_unit[baseId]

    --组装单位场景key id
    local uniquenpcid = BaseUtils.get_unique_npcid(unitId, battleId)

    --模拟场景单位数据
    local data = {
        battle_id = battleId,
        id = unitId,
        base_id = baseId,
        type = newType or baseData.type,
        name = name,
        status = 0,
        guide_lev = 0,
        speed = RoleManager.Instance.RoleData.speed,
        x = x,
        y = y,
        gx = 0,
        gy = 0,
        looks = looks,
        prop = {},
        dir = SceneConstData.UnitFaceToIndex[dir + 1],
        sex = sex,
        classes = classes,
        action = SceneConstData.UnitActionStr[act],
        no_hide = true,
    }

    local npc = NpcData.New()
    npc:update_data(data)

    -- 在当前场景就创建，不在就只记录下来
    if mapId == SceneManager.Instance:CurrentMapId() then
        SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniquenpcid, npc, nil) -- 创建虚拟单位
    end

    --把新创建的单位加入到场景寻路信息表
    DataWorldNpc.data_world_npc[uniquenpcid] = {battleid = battleId, id = unitId, baseid = baseId , mapbaseid = mapId, posx = x, posy = y}

    self.unitTable[unitId] = {uniqueid = uniquenpcid, map = mapId, dat = npc}
    -- print(string.format("创建虚拟单位 %s", uniquenpcid))
end

function DramaVirtualUnit:RemoveUnit(action)
    local unitId = action.unit_id
    local info = self.unitTable[unitId]
    if info ~= nil then
        -- print(string.format("删除虚拟单位 %s", info.uniqueid))
        SceneManager.Instance.sceneElementsModel:RemoveVirtual_Unit(info.uniqueid) -- 删除虚拟单位
        DataWorldNpc.data_world_npc[info.uniqueid] = nil
        self.unitTable[unitId] = nil
    end
end

function DramaVirtualUnit:Clear()
    print("清除场景上剧情创建的虚拟单位")
    for k,info in pairs(self.unitTable) do
        SceneManager.Instance.sceneElementsModel:RemoveVirtual_Unit(info.uniqueid) -- 删除虚拟单位
        DataWorldNpc.data_world_npc[info.uniqueid] = nil
    end
    self.unitTable = {}
end

function DramaVirtualUnit:OnJump()
end