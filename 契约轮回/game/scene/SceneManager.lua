--
-- @Author: chk
-- @Date:   2018-07-19 10:24:02
--

SceneManager = SceneManager or class("SceneManager", BaseManager)
local this = SceneManager;

local math_floor = math.floor
local table_insert = table.insert
local table_remove = table.remove

-- 和其他不是互斥的可以用相同的数字
SceneManager.SceneObjectVisibleState = {
    -- 场景对象
    NoOperate       = BitState.State[1],  -- 没有操作
    OpenUI          = BitState.State[2],  -- 打开UI层
    SettingVisible  = BitState.State[3],  -- 设置显示状态
    SettingNum      = BitState.State[4],  -- 设置显示数量状态

    -- 跟随对象
    OwenState       = BitState.State[1],  -- 跟随对象的主人状态隐藏
}

function SceneManager:ctor()
    SceneManager.Instance = self
    self.main_role = nil
    self.is_chang_scene = false

    self.object_type_show_num = {}
    self.object_type_has_show_number = {}

    -- 同屏最多显示 5个 宠物 法宝 子女（精灵） 神灵
    self:SetObjectTypeShowType(enum.ACTOR_TYPE.ACTOR_TYPE_PET,5)
    self:SetObjectTypeShowType(enum.ACTOR_TYPE.ACTOR_TYPE_TALISMAN,5)
    self:SetObjectTypeShowType(enum.ACTOR_TYPE.ACTOR_TYPE_FAIRY,5)
    self:SetObjectTypeShowType(enum.ACTOR_TYPE.ACTOR_TYPE_GOD,5)

    self:InitData()
    self:Reset()

    LateUpdateBeat:Add(self.Update, self, 3, 1)
end

function SceneManager:Reset()

    -- 每帧增加对象的状态
    -- true 当前帧有增加
    -- false当前帧无增加
    -- 已经去除  资源加载方面已经做了处理，不需要再而外处理
    -- self.fram_add_object_state = {}
    self.showRoleList = {};
    self.showMonList = {};
    -- 延迟添加对象列表
    if self.wait_create_object_list then
        for k, delay_list in pairs(self.wait_create_object_list) do
            delay_list:clear()
        end
    else
        self.wait_create_object_list = {}
    end
    -- 分裂怪 直接生成
    self.wait_create_fission_list = {}

    -- 掉落物要额外处理
    self.wait_create_drop_list = {}

    self.object_info_list = {}
    if self.object_list then
        local del_tab = {}
        for actor_type, list in pairs(self.object_list) do
            for k, object in pairs(list) do
                del_tab[#del_tab + 1] = object
            end
        end

        for k, object in pairs(del_tab) do
            object:destroy()
        end
        self.object_list = {}
    else
        self.object_list = {}
    end

    -- 附属对象，包括 宠物、法宝、精灵、神器等
    if self.depend_object_list then
        local del_tab = {}
        for owner_id, actor_list in pairs(self.depend_object_list) do
            for actor_type, list in pairs(actor_list) do
                for k, object in pairs(list) do
                    del_tab[#del_tab + 1] = object
                end
            end
        end
        for k, object in pairs(del_tab) do
            object:destroy()
        end
    end
    self.depend_object_list = {}

    if self.scene_info_data then
        self.scene_info_data:destroy()
    end
    self.scene_info_data = SceneInfoData()

    -- 检测锁定列表
    self.check_lock_list = {}

    -- 锁定NPC
    self.lock_npc_id = nil

    if self.wait_remove_object_list then
        self:RemoveWaitObjectList()
    else
        self.wait_remove_object_list = {}
    end

    self.wait_add_object_list = {}

    self.is_transition = false

    if not self.object_visible_bit_list then
        self.object_visible_bit_list = {}
        for k,v in pairs(enum.ACTOR_TYPE) do
            self.object_visible_bit_list[v] = BitState()
        end
    else
        for k,v in pairs(self.object_visible_bit_list) do
            self.object_visible_bit_list.value = 0
        end
    end

    self:Clear()

    self.object_type_has_show_number = {}
end

function SceneManager:Clear()
    if self.main_role then
        self.main_role:destroy()
        self.main_role = nil
    end
    self:RemoveAllObject()
end

function SceneManager:ClearList(list)
    if list then
        for k, object in pairs(list) do
            object:destroy()
        end
    end
end

function SceneManager.GetInstance()
    if SceneManager.Instance == nil then
        SceneManager()
    end
    return SceneManager.Instance
end

function SceneManager:CreateScene(SceneId)
    -- Chkprint('--chk SceneManager.lua,line 81-- data=',data)
    MapManager:GetInstance():LoadMapInfo(SceneId)
    self:CreateSceneAddObject()
end

function SceneManager:CreateSceneAddObject()
    self.is_transition = false
    self:SetMainRoleSceneInfo()
    self:RemoveWaitObjectList()
    if not table.isempty(self.wait_add_object_list) then
        self:AddObjectList(self.wait_add_object_list)
        self.wait_add_object_list = {}
    end
end

function SceneManager:InitData()
    MapManager()
end

function SceneManager:SetChangeSceneState(state)
    self.is_chang_scene = state
end

function SceneManager:GetChangeSceneState()
    return self.is_chang_scene
end

function SceneManager:ChangeScene(scene_info)
    self:CleanLockList()
    local last_scene_id = self:GetSceneId()
    if scene_info.scene == last_scene_id then
        self:SetSceneInfo(scene_info)
		if not table.isempty(scene_info.actors) then
			self:AddObjectList(scene_info.actors)
		end
        self:CreateSceneAddObject()
        if WarriorModel:GetInstance():IsWarriorScene(scene_info.scene) and self.main_role then
            self.main_role:SetPosition(scene_info.actor.coord.x, scene_info.actor.coord.y)
        end
        if GodCelebrationModel:GetInstance():IsGodScoreScene(scene_info.scene) and self.main_role then
            self.main_role:SetPosition(scene_info.actor.coord.x, scene_info.actor.coord.y)
        end
        if LimitTowerModel:GetInstance():IsLimitTower(scene_info.scene) and self.main_role then
            self.main_role:SetPosition(scene_info.actor.coord.x, scene_info.actor.coord.y)
        end
        self:SetChangeSceneState(false)
        GlobalEvent:Brocast(EventName.ChangeSameScene)
        return
    end
    if last_scene_id then
        local last_scene_type = SceneConfigManager:GetInstance():GetSceneType(last_scene_id)
        local last_scene_is_city = last_scene_type == SceneConstant.SceneType.Feild or last_scene_type == SceneConstant.SceneType.City

        local cur_scene_type = SceneConfigManager:GetInstance():GetSceneType(scene_info.scene)
        local cur_scene_is_city = cur_scene_type == SceneConstant.SceneType.Feild or cur_scene_type == SceneConstant.SceneType.City
        -- 当前场景和上一个场景是不同类型时，需要停止寻路
        -- 主城和野外在这里判断为同一个大类型
        if (last_scene_is_city ~= cur_scene_is_city or not last_scene_type) and not OperationManager:GetInstance():IsCheckWaitStar() then
            OperationManager:GetInstance():StopAStarMove()
        end
    end

    if last_scene_id then
        local cf = Config.db_scene[last_scene_id]
        local hideTab = String2Table(cf.hide)
        for k,v in pairs(hideTab) do
            self:SetObjectBitStateByType(v,false,SceneManager.SceneObjectVisibleState.SettingVisible)
        end
    end

    local cf = Config.db_scene[scene_info.scene]
    local hideTab = String2Table(cf.hide)
    for k,v in pairs(hideTab) do
        self:SetObjectBitStateByType(v,true,SceneManager.SceneObjectVisibleState.SettingVisible)
    end

    -- 切换场景 释放lua内存 改到加载loading界面的时候 gc
    -- collectgarbage("collect")

    self.last_scene_id = last_scene_id
    self:SetSceneInfo(scene_info)

    self.SceneId = scene_info.scene
    PreloadManager:GetInstance():ChangeScene()

    Yzprint('--LaoY SceneManager.lua,line 210--',Time.time)
    GlobalEvent:Brocast(EventName.ChangeSceneStart, scene_info.scene)


    if not table.isempty(scene_info.actors) then
        Yzprint('--LaoY SceneManager.lua,line 170--', #scene_info.actors)
        self:AddObjectList(scene_info.actors)
    end
end

function SceneManager:SetSceneInfo(scene_info)
    self.scene_info_data:ChangeMessage(scene_info)
    GlobalEvent:Brocast(SceneEvent.UpdateInfo)
end

function SceneManager:GetSceneInfo()
    return self.scene_info_data
end

function SceneManager:GetSceneId()
    if self.scene_info_data then
        return self.scene_info_data.scene
    end
end

function SceneManager:IsCrossScene(scene_id)
    local cf = SceneConfigManager:GetDBSceneConfig(scene_id)
    if not cf then
        return false
    end
    return cf.kind == enum.SCENE_KIND.SCENE_KIND_CROSS
end

function SceneManager:GetLastSceneId()
    return self.last_scene_id
end

function SceneManager:GetSceneName()
    local scene_id = self:GetSceneId()
    if not scene_id then
        return
    end
    local config = Config.db_scene[scene_id]
    if not config then
        return
    end
    return config.name
end

function SceneManager:CreateMainRole(uid)
    if not uid then
        return
    end
    if not self.main_role then
        -- if self.is_chang_scene then
        --     self.need_create_main_role_id = uid
        --     return
        -- end
        -- self.need_create_main_role_id = nil
        self.main_role = MainRole(uid)
        GlobalEvent:Brocast(SceneEvent.CreateMainRole)
    end
end

function SceneManager:GetMainRole()
    return self.main_role
end

function SceneManager:SetMainRoleSceneInfo()
    local mainrole_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if mainrole_data then

        mainrole_data:SetCoord(self.scene_info_data.actor.coord)
        local role = self.scene_info_data.actor.role
        if self.main_role and self.main_role:IsDeath() and role.hp > 0 then
            self.main_role:Revive()
        end
        if not mainrole_data.dir then
            mainrole_data:ChangeData("dir", role.dir)
        end
        mainrole_data:ChangeData("attr.hp", role.hp)
        mainrole_data:ChangeData("attr.hpmax", role.hpmax)
        mainrole_data:ChangeData("attr.speed", role.speed)
        mainrole_data:ChangeData("group", role.group)
		mainrole_data:ChangeData("pkmode", role.pkmode)
        if role.ext and role.ext.melee_score then
            mainrole_data:ChangeData("ext.melee_score", role.ext.melee_score)
        else
            if self.main_role then
                self.main_role:SetMarryText();
                self.main_role:SetTitle();
            end
        end


        local last_buffs = clone(mainrole_data.buffs) or {}
        local new_buffs = clone(role.buffs)
        for k, p_buff in pairs(last_buffs) do
            mainrole_data:RemoveBuff(p_buff.id, true)
        end
        mainrole_data:AddBuffList(new_buffs)

        if mainrole_data.figure then

            if mainrole_data.figure.mount then
                MountModel:GetInstance():SetMorphMountModel(mainrole_data.figure.mount.model);
            end

            if mainrole_data.figure.offhand then
                MountModel:GetInstance():SetMorphOffhandModel(mainrole_data.figure.offhand.model);
            end

            if mainrole_data.figure.wing then
                MountModel:GetInstance():SetMorphWingModel(mainrole_data.figure.wing.model);
            end

            if mainrole_data.figure.talis then
                MountModel:GetInstance():SetMorphTalisModel(mainrole_data.figure.talis.model);
            end

            if mainrole_data.figure.weapon then
                MountModel:GetInstance():SetMorphWeaponModel(mainrole_data.figure.weapon.model);
            end
        end

        -- local role = self.scene_info_data.actor.role
        -- role.attr = {}
        -- role.attr.hp    = role.hp
        -- role.attr.hpmax = role.hpmax
        -- role.attr.speed = role.speed
        -- mainrole_data:ChangeMessage(self.scene_info_data.actor.role,false)
    end
end

function SceneManager:GetSceneBuff()
    if self.scene_info_data and self.scene_info_data.actor and self.scene_info_data.actor.role then
        return self.scene_info_data.actor.role.buffs
    end
end

function SceneManager:SetMainRoleRotateY(rotateY)
    if self.main_role then
        self.main_role:SetRotateY(rotateY)
    end
end

--[[
	@author LaoY
	@des	新加场景对象
	@param1 tab  table 场景对象列表
	@return number
--]]
function SceneManager:AddObjectList(tab)
    for i = 1, #tab do
        local actor = tab[i]
        if not self:GetObject(actor.uid) then
            local is_add = true
            -- not(actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP and actor.creep.owner ~= 0 and actor.creep.owner ~= RoleInfoModel:GetInstance():GetMainRoleId())
            if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
                local cf = Config.db_creep[actor.creep.id]
                if cf and cf.creep_kind == enum.CREEP_RARITY.CREEP_RARITY_HUNT and actor.creep.owner ~= RoleInfoModel:GetInstance():GetMainRoleId() then
                    is_add = false
                end
            end
            if is_add then
                self:SetObjectInfo(actor)
                self:AddObject(actor.uid)
            end
        end
    end
end

--[[
	@author LaoY
	@des	逐帧创建场景对象，每个类型每帧只创建一个
	@param1 uid number 唯一ID
--]]
function SceneManager:AddObject(uid)
    local actor = self:GetObjectInfo(uid)
    if not actor or self:GetObject(actor.uid) then
        return
    end

    -- 掉落物特殊处理
    if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_DROP then
        self.wait_create_drop_list = self.wait_create_drop_list or {}
        -- self.wait_create_drop_list[actor.from] = self.wait_create_drop_list[actor.from] or {}
        if not self.wait_create_drop_list[actor.from] then
            self.wait_create_drop_list[actor.from] = {}
            self.wait_create_drop_list[actor.from].drop_time = Time.time
            local object = self:GetObject(actor.from)
            if object then
                self.wait_create_drop_list[actor.from].drop_from_pos = object:GetPosition()
            end
        end
        local count = #self.wait_create_drop_list[actor.from]
        self.wait_create_drop_list[actor.from][count + 1] = uid
        return
    end

    self:CreateObject(uid)
    -- self.wait_create_object_list[actor.type] = self.wait_create_object_list[actor.type] or list()
    -- self.wait_create_object_list[actor.type]:push(uid)
end

--[[
	@author LaoY
	@des	当前帧已经创建过该对象不再创建
	@param1 uid number 唯一ID
--]]
function SceneManager:CreateObject(uid)
    local actor = self:GetObjectInfo(uid)
    if not actor then
        return
    end
    if self.object_list[actor.type] and self.object_list[actor.type][uid] then
        return
    end

    local object_create_func_list = {
        [enum.ACTOR_TYPE.ACTOR_TYPE_ROLE] = Role,
        [enum.ACTOR_TYPE.ACTOR_TYPE_CREEP] = Monster,
        [enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT] = Robot,

        [enum.ACTOR_TYPE.ACTOR_TYPE_NPC] = Npc,
        [enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL] = Door,
        [enum.ACTOR_TYPE.ACTOR_TYPE_DROP] = Drop,
        [enum.ACTOR_TYPE.ACTOR_TYPE_JUMP] = JumpPoint,
        [enum.ACTOR_TYPE.ACTOR_TYPE_EFFECT] = Effect,
        [enum.ACTOR_TYPE.ACTOR_TYPE_MACHINEARMOR] = MachineArmor,
    }
    local create_object_func = object_create_func_list[actor.type]
    --if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP  then
    --	Yzprint('--LaoY SceneManager.lua,line 223-- data=',uid)
    --end
    if not create_object_func then
        logError("CreateObject can not find function ,the type is " .. tostring(actor.type), ",id:", uid, ",name:", tostring(actor.name))
        return
    end
    if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
        --print("dddddddddddd")
    end

    self.object_list[actor.type] = self.object_list[actor.type] or {}
    local object = create_object_func(uid)
    self.object_list[actor.type][uid] = object

    if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE or actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT then
        self:UpdateObjectVisible(actor.type,object)
        if table.nums(self.showRoleList) >= SettingModel:GetInstance().maxShowRoleNum and not self.showRoleList[uid] then
            object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingNum)
            object:UpdateVisible()
            self.showRoleList[uid] = nil
        else
            self.showRoleList[uid] = true
        end
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        self:UpdateObjectVisible(actor.type,object)
    end
end

function SceneManager:UpdateObjectVisible(actor_type,object)
    local bitStateList = {
        SceneManager.SceneObjectVisibleState.NoOperate,
        SceneManager.SceneObjectVisibleState.OpenUI,
        SceneManager.SceneObjectVisibleState.SettingVisible,
        SceneManager.SceneObjectVisibleState.SettingNum,
    }

    local is_update = false
    for k,v in pairs(bitStateList) do
        local cur_state_bool = self:GetObjectBitStateByType(actor_type,v)
        if not cur_state_bool then
            object:SetVisibleStateBit(true,v)
            is_update = true
        end
    end
    if is_update then
        object:UpdateVisible()
    end
end

function SceneManager:AddDependObjcet(be_depend_object,owner_id, actor_type, index)
    local object_object = self:GetObject(owner_id)
    local object_info = self:GetObjectInfo(owner_id)
    if not object_info then
        return
    end
    self:CreateDependObjcet(be_depend_object,owner_id, actor_type, index)
end

local function getDependCreateFunc(actor_type)
    local object_create_func_list = {
        [enum.ACTOR_TYPE.ACTOR_TYPE_TALISMAN] = Talisman,
        [enum.ACTOR_TYPE.ACTOR_TYPE_PET] = Pet,
        [enum.ACTOR_TYPE.ACTOR_TYPE_FAIRY] = Fairy,
        [enum.ACTOR_TYPE.ACTOR_TYPE_MAGIC] = Magic,
        [enum.ACTOR_TYPE.ACTOR_TYPE_GOD] = God,
        [enum.ACTOR_TYPE.ACTOR_TYPE_WING] = Wing,
        [enum.ACTOR_TYPE.ACTOR_TYPE_Weapon] = Weapon,
        [enum.ACTOR_TYPE.ACTOR_TYPE_MACHINEARMOR] = MachineArmor,
        [enum.ACTOR_TYPE.ACTOR_TYPE_MOUNT] = Mount,
        [enum.ACTOR_TYPE.ACTOR_TYPE_HEAD] = Head,
        [enum.ACTOR_TYPE.ACTOR_TYPE_HAND] = Hand,
        [enum.ACTOR_TYPE.ACTOR_TYPE_MAG] = MagicArray,
    }
    return object_create_func_list[actor_type]
end


function SceneManager:CreateDependObjcet(be_depend_object,owner_id, actor_type, index)

    index = index or 1
    self.depend_object_list[be_depend_object] = self.depend_object_list[be_depend_object] or {}
    self.depend_object_list[be_depend_object][actor_type] = self.depend_object_list[be_depend_object][actor_type] or {}
    -- 如果已经存在就不加载
    if self.depend_object_list[be_depend_object][actor_type][index] then
        return
    end

    
    local create_object_func = getDependCreateFunc(actor_type)
    if not create_object_func then
        logError("CreateDependObjcet can not find function ,the type is " .. tostring(actor_type) .. "__" .. owner_id)
        return
    end
    local object = create_object_func(owner_id, actor_type, index,be_depend_object)
    self.depend_object_list[be_depend_object][actor_type][index] = object

    self:SetObjectStateByNumber(object)
    -- 主角自己的需要重新排序
    if owner_id == RoleInfoModel:GetInstance():GetMainRoleId() then
        self:SetObjectTypeStateByNumber(actor_type)
    end
end

function SceneManager:GetDependObject(be_depend_object, actor_type, index)
    if not self.depend_object_list[be_depend_object] or not self.depend_object_list[be_depend_object][actor_type] then
        return nil
    end
    index = index or 1
    return self.depend_object_list[be_depend_object][actor_type][index]
end

function SceneManager:GetDependObjectList(be_depend_object,actor_type)
    if not self.depend_object_list[be_depend_object] then
        return nil
    end
    if not actor_type then
        return self.depend_object_list[be_depend_object]
    end
    return self.depend_object_list[be_depend_object][actor_type]
end

function SceneManager:GetDependObjectListByType(actor_type)
    local list
    for be_depend_object,actors in pairs(self.depend_object_list) do
        for _actor_type,actorList in pairs(actors) do
            if _actor_type == actor_type then
                for index,object in pairs(actorList) do
                    if not object.is_dctored then
                        list = list or {}
                        list[#list+1] = object
                    end
                end
            end
        end
    end
    return list
end

function SceneManager:RemoveDependObject(be_depend_object, actor_type, index)
    -- 删除已经存在的对象
    if not self.depend_object_list[be_depend_object] then
        return
    end
    if not actor_type then
        for actor_type, list in pairs(self.depend_object_list[be_depend_object]) do
            for k, object in pairs(list) do
                object:Remove()
            end
            self:SetObjectTypeStateByNumber(actor_type)
        end
        self.depend_object_list[be_depend_object] = nil

        return
    end
    if not self.depend_object_list[be_depend_object][actor_type] then
        return
    end
    if not index then
        for k, object in pairs(self.depend_object_list[be_depend_object][actor_type]) do
            object:Remove()
        end
        self.depend_object_list[be_depend_object][actor_type] = nil
        self:SetObjectTypeStateByNumber(actor_type)
        return
    end
    local object = self.depend_object_list[be_depend_object][actor_type][index]
    if not object then
        return
    end
    object:Remove()
    self.depend_object_list[be_depend_object][actor_type][index] = nil
    self:SetObjectTypeStateByNumber(actor_type)
end

function SceneManager:SetObjectInfo(actor)
    -- 切场景过渡时期 先不添加，缓存起来
    if self.is_transition then
        self.wait_add_object_list[#self.wait_add_object_list + 1] = actor
        return
    end

    local data = nil
    --服务端对象
    if isClass(actor) then
        data = actor
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
        --角色
        data = RoleData:create(actor.role, actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        --怪物
        data = MonsterData:create(actor.creep, actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_DROP then
        -- 如果超出九宫格范围，不创建
        if DropData.IsOutOfMainRole(actor) then
            return
        end
        --掉落
        data = DropData:create(actor.drop, actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT then
        -- 机器人
        data = RobotData:create(actor.role, actor)
        -- 客户端对象
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
        --NPC
        data = NpcData:create(actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL then
        --传送门
        data = DoorData:create(actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_JUMP then
        --跳跃点
        data = JumpPointData:create(actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_EFFECT then
        --场景特效
        data = EffectData:create(actor)
    elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_MACHINEARMOR then
        --机甲
        data = MachineArmorData:create(actor)
    else
        -- data = ObjectData:create(actor)
    end

    if not data or not isClass(data) then
        logError("SetObjectInfo set a nil class")
    end
    if not data.uid then
        logError("SetObjectInfo set a nil id")
    end
    -- Yzprint('--LaoY SceneManager.lua,line 196--')
    -- Yzdump(data,"data")
    --data.uid = tonumber(data.uid
    self.object_info_list[data.uid] = data
end

function SceneManager:GetObjectInfo(uid)
    if not uid then
        return
    end
	if uid == RoleInfoModel:GetInstance():GetMainRoleId() then
		return RoleInfoModel:GetInstance():GetMainRoleData()	
	end
    return self.object_info_list[uid]
end

function SceneManager:AddWaitRemoveObjectList()
    for object_type, object_list in pairs(self.object_list) do
        for uid, object in pairs(object_list) do
            self.wait_remove_object_list[#self.wait_remove_object_list + 1] = uid
        end
    end
end

function SceneManager:RemoveWaitObjectList()
    self:RemoveObjectList(self.wait_remove_object_list)
    Yzprint('--LaoY SceneManager.lua,line 583--')
    Yzdump(self.wait_remove_object_list, "self.wait_remove_object_list")
    self.wait_remove_object_list = {}
end

--[[
	@author LaoY
	@des	切换场景，清除场景内所有，主角除外
	@param1 param1
	@return number
--]]
function SceneManager:RemoveAllObject()
    local list = {}
    for object_type, object_list in pairs(self.object_list) do
        for uid, object in pairs(object_list) do
            list[#list + 1] = uid
        end
    end
    self:RemoveObjectList(list)
end

function SceneManager:RemoveObjectListByServer(tab)
    local scene_id = self:GetSceneId()
    local cf = Config.db_scene[scene_id]
    local is_gold_dungeon = false
    if cf and cf.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and cf.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COIN then
        is_gold_dungeon = true
    end

    if is_gold_dungeon then
        for i = 1, #tab do
            local uid = tab[i]
            local object = self:GetObject(uid)
            if object then
                object:PlayDeath()
            end
        end
    else
        self:RemoveObjectList(tab)
    end
end

function SceneManager:RemoveObjectList(tab)
    -- Yzprint('--LaoY SceneManager.lua,line 191-- data=',#tab)
    for i = 1, #tab do
        local uid = tab[i]
        self:RemoveObject(uid)
    end
end

function SceneManager:RemoveObject(uid, isPick,isAuto)
    if not uid then
        return
    end

    local _isPick = isPick or false

    local actor = self.object_info_list[uid]
    self.object_info_list[uid] = nil
    if actor and self.object_list[actor.type] then
        local object = self.object_list[actor.type][uid]
        if object then
            self.object_list[actor.type][uid] = nil
            if not object.is_dctored then
                self.check_lock_list[uid] = nil;

                if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_DROP and _isPick then
                    if isAuto then
                        object:destroyWithAutoPick()
                    else
                        object:destroyWithPick()
                    end

                else
                    object:destroy()
                end

                if actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP and object.creep_kind == enum.CREEP_KIND.CREEP_KIND_MONSTER then
                    self.showMonList[uid] = nil;
                elseif actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE or actor.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT then
                    self.showRoleList[uid] = nil
                    self:UpdateRoleVisibleState()
                end
            end
        end
    end
    FightManager:GetInstance():RemoveObject(uid)
end

--[[
	@author LaoY
	@des	获取场景对象
	@param1 uid number 唯一ID
--]]
function SceneManager:GetObject(uid)
    if not uid then
        return
    end
    if uid == RoleInfoModel:GetInstance():GetMainRoleId() then
        return self:GetMainRole()
    end
    local actor = self:GetObjectInfo(uid)
    if actor and self.object_list[actor.type] then
        return self.object_list[actor.type][uid]
    end
    -- return next(next(self.object_list))
    return nil
end

function SceneManager:GetObjectListByType(type)
    return self.object_list[type]
end

function SceneManager:GetObjectInScreen(object_type)
    local list = self:GetObjectListByType(object_type)
    if table.isempty(list) then
        return
    end
    local caster_pos = self.main_role:GetPosition()

    local target_object
    local min_dis_square
    for k, object in pairs(list) do
        local dis_square = Vector2.DistanceNotSqrt(caster_pos, object:GetPosition())
        -- if not object.is_death and not object.is_dctored and object.is_loaded and MapLayer:GetInstance():IsInScreen(object:GetPosition()) and (not min_dis_square or dis_square < min_dis_square) then
        if not object.is_death and not object.is_dctored and MapLayer:GetInstance():IsInScreen(object:GetPosition()) and (not min_dis_square or dis_square < min_dis_square) then
            min_dis_square = dis_square
            target_object = object
        end
    end
    return target_object
end

function SceneManager:GetDropInScreen()
    local list = self:GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_DROP)
    if table.isempty(list) then
        return
    end
    local caster_pos = self.main_role:GetPosition()

    local target_object
    local min_dis_square
    for k, object in pairs(list) do
        local dis_square = Vector2.DistanceNotSqrt(caster_pos, object:GetPosition())
        -- if not object.is_death and not object.is_dctored and object.is_loaded and MapLayer:GetInstance():IsInScreen(object:GetPosition()) and (not min_dis_square or dis_square < min_dis_square) then
        if not object.is_death and not object.is_dctored and MapLayer:GetInstance():IsInScreen(object:GetPosition()) and (not min_dis_square or dis_square < min_dis_square) and object:IsCanOClick() then
            min_dis_square = dis_square
            target_object = object
        end
    end
    return target_object
end

function SceneManager:GetCollectObject()
    return self:GetCreepInScreen(nil, enum.CREEP_KIND.CREEP_KIND_COLLECT)
end

function SceneManager:GetCreepInScreen(type_id, creep_kind,check_func)
    local list = self:GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
    if table.isempty(list) then
        return
    end
    local caster_pos = self.main_role:GetPosition()
    local main_group = self.main_role.object_info.group;

    local target_object
    local min_dis_square
    for k, object in pairs(list) do
        local dis_square = Vector2.DistanceNotSqrt(caster_pos, object:GetPosition())
        local objectInfo = object.object_info;
        local group = objectInfo.group;
        -- if not object.is_death and not object.is_dctored and object.is_loaded
        if not object.is_death and not object.is_dctored
                and (not creep_kind or object.creep_kind == creep_kind) and (not type_id or type_id == object.object_info.id)
                and MapLayer:GetInstance():IsInScreen(object:GetPosition()) and (not min_dis_square or dis_square < min_dis_square) and
                (group == 0 or main_group == 0 or group ~= main_group) and 
                (not check_func or check_func(object)) then
            min_dis_square = dis_square
            target_object = object
        end
    end
    return target_object
end

function SceneManager:GetCreepByTypeId(type_id, range, creep_kind, start_pos)
    if not self.main_role and not start_pos then
        return
    end
    local caster_pos = start_pos or self.main_role:GetPosition();
    local main_group = self.main_role.object_info.group;
    local range_square
    if range then
        range_square = range * range
    end
    local target_object
    local min_dis_square
    local object_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_CREEP]
    if not object_list then
        return nil
    end
    for k, object in pairs(object_list) do
        local dis_square = Vector2.DistanceNotSqrt(caster_pos, object:GetPosition())
        local objectInfo = object.object_info;
        local group = objectInfo.group;
        -- if (not type_id or type_id == object.object_info.id) and not object:IsDeath() and not object.is_dctored and object.is_loaded
        if (not type_id or type_id == object.object_info.id) and not object:IsDeath() and not object.is_dctored
                and (not creep_kind or object.creep_kind == creep_kind) and (not min_dis_square or dis_square < min_dis_square) and
                (group == 0 or main_group == 0 or group ~= main_group) then
            min_dis_square = dis_square
            target_object = object
        end
    end
    if range_square and min_dis_square and range_square < min_dis_square then
        return nil
    end
    return target_object
end

function SceneManager:AttackCreepByTypeId(target_id,is_same_scene,errorRange)

    local cf = Config.db_creep[target_id]
    if not cf then
        return
    end
	local cur_scene_id = self:GetSceneId()
    local target_scene_id = cf.scene_id
    local target_pos = SceneConfigManager:GetInstance():GetCreepPosition(target_scene_id, target_id)
    local error_range = SceneConstant.RushDis + cf.volume * 0.5 + SceneConstant.AttactDis
    if cf.rarity == enum.CREEP_RARITY.CREEP_RARITY_COLL then
        error_range = SceneConstant.PickUpDis - 1
        --elseif cf.rarity == enum.CREEP_RARITY.CREEP_RARITY_COMM then
        --    error_range = 0
    end
    if errorRange then
        error_range = errorRange
    end
    local function call_back()
        local object = self:GetCreepByTypeId(target_id, nil, nil, target_pos)
        if object then
            object:OnClick()
            AutoFightManager:GetInstance():Start()
        else
            if error_range > 200 then
                self:AttackCreepByTypeId(target_id,true,200)
            end
        end
    end
    if target_scene_id == cur_scene_id or is_same_scene then
        OperationManager:GetInstance():TryMoveToPosition(cur_scene_id, nil, target_pos, call_back, error_range)
    else
        OperationManager:GetInstance():CheckMoveToPosition(target_scene_id, nil, target_pos, call_back, error_range)
    end
end

function SceneManager:FindNpc(npc_id)
    local function call_back()
        local object = self:GetObject(npc_id)
        if object then
            object:OnClick()
        end
    end
    local cf = Config.db_npc[npc_id]
    if not cf then
        return
    end
    local target_scene_id = cf.scene
    local target_pos = SceneConfigManager:GetInstance():GetNpcPosition(target_scene_id, npc_id)
    local fly_pos = SceneConfigManager:GetInstance():GetNPCFlyPos(npc_id)
    OperationManager:GetInstance():TryMoveToPosition(target_scene_id, nil, target_pos, call_back, SceneConstant.NPCRange,nil,nil,nil,fly_pos)
end

function SceneManager:GetJumpPointInfo(caster_pos, range_square)
    local jump_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_JUMP]
    local is_config = false
    if table.isempty(jump_list) then
        is_config = true
        jump_list = SceneConfigManager:GetInstance():GetJumpPointList()
    end
    if table.isempty(jump_list) then
        return nil
    end
    caster_pos = caster_pos or self.main_role:GetPosition()
    local min_dis_square
    local target_object
    for k, object in pairs(jump_list) do
        local dis_square
        if is_config then
            dis_square = Vector2.DistanceNotSqrt(caster_pos, object.coord)
        else
            dis_square = Vector2.DistanceNotSqrt(caster_pos, object:GetPosition())
        end
        if (not min_dis_square or dis_square < min_dis_square) then
            min_dis_square = dis_square
            target_object = object
        end
    end
    if range_square and range_square < min_dis_square then
        return nil
    end

    if is_config then
        return self:GetObjectInfo(target_object.id)
    else
        return self:GetObjectInfo(target_object.object_id)
    end
end

function SceneManager:ReviveTip()
    -- REVIVE_TYPE = {
    -- 	REVIVE_TYPE_MANU_SITU = 1, -- 手动原地复活
    -- 	REVIVE_TYPE_MANU_SAFE = 2, -- 手动安全区复活
    -- 	REVIVE_TYPE_AUTO_SITU = 3, -- 自动原地复活
    -- 	REVIVE_TYPE_AUTO_SAFE = 4, -- 自动安全区复活
    -- },
    local cost_gold = 10
    local auto_time = 10
    local ok_last_time = nil
    local cancel_last_time = nil
    local scene_id = self:GetSceneId()
    local config = Config.db_scene[scene_id]
    local ok_func
    local cancel_func
    local tip_str
    if config and config.can_revive == 1 then
        local revive = String2Table(config.revive)
        local function CheckReviveType(revive_type)
            for k, v in pairs(revive) do
                if v == revive_type then
                    return true
                end
            end
            return false
        end
        local check_ok_list = {
            { revive_type = enum.REVIVE_TYPE.REVIVE_TYPE_SITU, str = string.format("Spend %s diamond to resurrection immediately?", cost_gold) },
            { revive_type = enum.REVIVE_TYPE.REVIVE_TYPE_SAFE, str = string.format("Use %s diamond to resurrect in the safe zone?", cost_gold) },
        }
        for i, info in ipairs(check_ok_list) do
            if CheckReviveType(info.revive_type) then
                ok_func = function()
                    GlobalEvent:Brocast(FightEvent.Revive, info.revive_type)
                end
                tip_str = info.str
                break
            end
        end
    else
        -- local check_cancel_list = {
        -- 	{revive_type = enum.REVIVE_TYPE.REVIVE_TYPE_AUTO_SITU,str = string.format("等待%s秒后原地复活",auto_time)},
        -- 	{revive_type = enum.REVIVE_TYPE.REVIVE_TYPE_AUTO_SAFE,str = string.format("等待%s秒后安全区原地复活",auto_time)},
        -- }
        -- for i,info in ipairs(check_cancel_list) do
        -- 	if CheckReviveType(info.revive_type) then
        -- 		cancel_func = function()
        -- 			GlobalEvent:Brocast(FightEvent.Revive,info.revive_type)
        -- 		end
        -- 		if not tip_str then
        -- 			tip_str = info.str
        -- 		end
        -- 		cancel_last_time = auto_time
        -- 		break
        -- 	end
        -- end
    end
    if not ok_func and not cancel_func then
        return
    end
    local title_str = "Tip"
    if not ok_func or not cancel_func then
        if not ok_func then
            ok_func = cancel_func
            ok_last_time = auto_time
        else
            ok_last_time = nil
        end
        Dialog.ShowOne(title_str, tip_str, "Confirm", ok_func, ok_last_time)
    else
        Dialog.ShowTwo(title_str, tip_str, "Confirm", ok_func, ok_last_time, "Cancel", cancel_func, cancel_last_time)
    end
    -- Dialog.ShowTwo("",string.format("是否消费%s元宝立即复活？",cost_gold),"确定",ok_func,nil,"取消",cancel_func,10)
end

function SceneManager:GetTouchTargetList(x, y)
    -- local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    -- if lv <= 7 then
    --     return {}
    -- end
    local list = {}
    local ignore_list = {}
    for _, type_list in pairs(self.object_list) do
        for _, object in pairs(type_list) do
            -- 特效忽略
            if object.__cname == "Effect" then
            elseif object.__cname == "Monster" and IgnoreClickObject[object.object_info.id] then
                if object:CheckInBound(x, y) then
                    ignore_list[#ignore_list + 1] = object
                end
            elseif object:CheckInBound(x, y) then
                list[#list + 1] = object
            end
        end
    end
    --根据y轴方向排序 y越小越靠前
    local function onSortHandler(v1, v2)
        if v1.position.y == v2.position.y then
            -- if AppConfig.Debug then
            --     if not tonumber(v1.object_id) then
            --         logError("=========onSortHandler=========",v1.__cname,v1.object_info.name,v1.object_id)
            --     elseif not tonumber(v2.object_id) then
            --         logError("=========onSortHandler=========",v2.__cname,v2.object_info.name,v2.object_id)
            --     end
            -- end
            local object_id_1 = tonumber(v1.object_id) or 0
            local object_id_2 = tonumber(v2.object_id) or 0
            return object_id_1 < object_id_2
        end
        return v1.position.y < v2.position.y
    end
    if table.isempty(list) and not table.isempty(ignore_list) then
        table.sort(ignore_list, onSortHandler)
        return ignore_list
    elseif #list > 1 then
        table.sort(list, onSortHandler)
    end
    return list
end

--[[
	@author LaoY
	@des	检测主角停下来的位置
			传送门
			NPC
--]]
function SceneManager:CheckMainRoleStop()
    if not self.main_role then
        return
    end
    local pos = self.main_role.position
    local check_list = {}
    -- 检测传送门
    local door_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL]
    if door_list then
        local door_range = SceneConstant.DoorRange * SceneConstant.DoorRange
        check_list[#check_list + 1] = { range = door_range, list = door_list }
    end
    -- 检测NPC
    -- local npc_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_NPC]
    -- if npc_list then
    -- 	local npc_range = SceneConstant.NPCRange * SceneConstant.NPCRange
    -- 	check_list[#check_list+1] = {range = npc_range,list = npc_list}
    -- end

    local drop_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_DROP]
    if drop_list then
        local drop_range = SceneConstant.DropRange * SceneConstant.DropRange
        check_list[#check_list + 1] = { range = drop_range, list = drop_list }
    end

    local info
    for i = 1, #check_list do
        info = check_list[i]
        for _, object in pairs(info.list) do
            -- if not object.is_dctored and object.is_loaded and Vector2.DistanceNotSqrt(pos, object:GetPosition()) <= info.range then
            if not object.is_dctored and Vector2.DistanceNotSqrt(pos, object:GetPosition()) <= info.range then
                -- Yzprint('--LaoY SceneManager.lua,line 397-- data=',object.object_info.name)
                object:OnMainRoleStop()
                return
            end
        end
    end
end

function SceneManager:CheckMainRolePosition()
    if not self.main_role or self.main_role:IsJumping() or self.main_role:IsRushing() then
        return
    end

    local x = self.main_role.position.x
    local y = self.main_role.position.y
    local block_pos_x = self.main_role.block_pos.x
    local block_pos_y = self.main_role.block_pos.y

    if self.last_check_block_pos and (self.last_check_block_pos.x == block_pos_x and self.last_check_block_pos.y == block_pos_y) then
        return
    end
    local pos = pos(x, y)
    self.last_check_block_pos = self.last_check_block_pos or {}
    self.last_check_block_pos.x = block_pos_x
    self.last_check_block_pos.y = block_pos_y


    local check_list = {}
    local drop_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_DROP]
    if drop_list then
        local drop_range = SceneConstant.DropRange * SceneConstant.DropRange
        check_list[#check_list + 1] = { range = drop_range, list = drop_list }
    end

    local info
    for i = 1, #check_list do
        info = check_list[i]
        for _, object in pairs(info.list) do
            if not object.is_dctored and Vector2.DistanceNotSqrt(pos, object:GetPosition()) <= info.range then
                object:OnMainRoleTouch()
                return
            end
        end
    end

    -- 检测是否碰到跳跃点
    -- local jump_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_DROP]
    -- if jump_list then
    -- 	local range = 60*60
    -- 	for _,object in pairs(jump_list) do
    -- 		local jump_pos = object:GetPosition()
    -- 		if Vector2.DistanceNotSqrt(pos, jump_pos) < range  then
    -- 			-- Yzprint('--LaoY SceneManager.lua,line 397-- data=',object.object_info.name)
    -- 			local object_info = object.object_info
    -- 			if OperationManager:GetInstance():CheckJumpPointAStar(x,y) then
    -- 				OperationManager:GetInstance():StopAStarMove()
    -- 			end
    -- 			self.main_role:PlayJump(object_info.target_coord,object_info.id)
    -- 			return
    -- 		end
    -- 	end
    -- end
end

function SceneManager:LockNpc(npc_id)
    if self.lock_npc_id == npc_id then
        return
    end
    local last_object = self:GetObject(self.lock_npc_id)
    if last_object then
        last_object:BeLock(false)
    end

    local object = self:GetObject(npc_id)
    if object then
        self.lock_npc_id = npc_id
        object:BeLock(true)
    end
end

function SceneManager:UnLockNpc(npc_id)
    if not self.lock_npc_id then
        return
    end
    if npc_id and npc_id ~= self.lock_npc_id then
        return
    end
    local last_object = self:GetObject(self.lock_npc_id)
    if last_object then
        last_object:BeLock(false)
    end
    self.lock_npc_id = nil
end

function SceneManager:CheckLockCreep(force, scene_auto_fight)
    if not self.main_role then
        return
    end
    local cur_time = os.clock()
    self.last_check_lock_creep_time = self.last_check_lock_creep_time or -cur_time
    if not force and cur_time - self.last_check_lock_creep_time < 200 then
        return
    end
    self.last_check_lock_creep_time = cur_time
    -- 检测锁定怪物
    local pos = self.main_role:GetPosition()
    local client_lock_target_id = FightManager:GetInstance().client_lock_target_id
    local creep_range = SceneConstant.LockRange * SceneConstant.LockRange
    if client_lock_target_id then
        local target = self:GetObject(client_lock_target_id)
        if target and not target:IsDeath() and target:AutoSelect() then
            if MapLayer:GetInstance():IsInScreen(target:GetPosition()) then
                if self.check_lock_list[client_lock_target_id] or self.main_role.attack_list[client_lock_target_id] then
                    return
                end
            else
                client_lock_target_id = nil
            end
        else
            client_lock_target_id = nil
        end
    end

    if not client_lock_target_id then
        FightManager:GetInstance():LockFightTarget(nil)
    end

    local hate_target = self.main_role:GetHateObject()
    if hate_target then
        self:LockCreep(hate_target.object_id)
        -- self.check_lock_list[hate_target.object_id] = true
    end
    if not hate_target then
        local target_id = self:SwitchLockCreep(true, force, scene_auto_fight)
        if target_id and target_id ~= client_lock_target_id then
            local old_dis
            local old_target = self:GetObject(client_lock_target_id)
            local new_target = self:GetObject(target_id)
            if new_target then
                local new_dis = Vector2.DistanceNotSqrt(pos, new_target:GetPosition())
                if client_lock_target_id then
                    old_dis = Vector2.DistanceNotSqrt(pos, old_target:GetPosition())
                end
                if not old_dis or new_dis < old_dis or old_target.object_type ~= new_target.object_type then
                    self:LockCreep(target_id)
                end
            end
        end
    end
    self:CleanLockList()
end

function SceneManager:CleanLockList()
    for k, v in pairs(self.check_lock_list) do
        self.check_lock_list[k] = nil
    end
end

-- 手动选择怪物 角色等
function SceneManager:OnClickAttackObject(target_id)
    self.check_lock_list[target_id] = true
    self:LockCreep(target_id)
    -- if not AutoFightManager:GetInstance():GetAutoFightState() and not AutoTaskManager:GetInstance():IsAutoFight() then
    --     GlobalEvent:Brocast(FightEvent.AutoFight)
    -- end

    AutoFightManager:GetInstance():Start(true)
end

function SceneManager:SwitchLockCreep(is_auto_check, force, scene_auto_fight)
    local creep_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_CREEP]
    local role_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_ROLE]
    local robot_list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT]
    local check_list = {}
    table.insert(check_list, role_list)
    table.insert(check_list, robot_list)
    table.insert(check_list, creep_list)
    if table.isempty(check_list) then
        return false
    end

    if not is_auto_check then
        local client_lock_target_id = FightManager:GetInstance().client_lock_target_id
        if client_lock_target_id then
            self.check_lock_list[client_lock_target_id] = true
        end
    end

    local pos = self.main_role:GetPosition()
    local max_count = 0
    local cur_count = 0
    local first_target_id = nil
    local min_range = nil
    local target_id = nil
    local collect_target_id = nil
    local collect_min_range = nil

    local len = #check_list
    for i = 1, len do
        local list = check_list[i]
        for k, object in pairs(list) do
            -- if not object:IsDeath() and object.is_loaded and
            if not object:IsDeath() and
                    (scene_auto_fight == true or MapLayer:GetInstance():IsInScreen(object:GetPosition())) and
                    object:AutoSelect() then
                max_count = max_count + 1
                if self.check_lock_list[object.object_id] then
                    cur_count = cur_count + 1
                end
                if not self.check_lock_list[object.object_id] and not first_target_id then
                    local distance = Vector2.DistanceNotSqrt(pos, object:GetPosition())
                    if (object.__cname ~= "Monster" or object.creep_kind ~= enum.CREEP_KIND.CREEP_KIND_COLLECT) then
                        if not min_range or distance < min_range then
                            min_range = distance
                            target_id = object.object_id
                        end
                    else
                        if not collect_min_range or distance < collect_min_range then
                            collect_min_range = distance
                            collect_target_id = object.object_id
                        end
                    end
                end
            end
        end

        if list == creep_list then
            if not target_id and not is_auto_check then
                -- if is_auto_check and collect_target_id then
                --     Yzprint('--LaoY SceneManager.lua,line 1117--',data)
                -- end
                target_id = collect_target_id
            end
        end
        first_target_id = target_id
    end

    if not is_auto_check and cur_count >= max_count then
        self:CleanLockList()
    end

    if target_id then
        if is_auto_check then
            return target_id
        end
        self:LockCreep(target_id)
        self.check_lock_list[target_id] = true
        return true
    end
    return false
end

function SceneManager:LockCreep(target_id)
    self:UnLockNpc()
    FightManager:GetInstance():LockFightTarget(target_id)
end

function SceneManager:GetBlockPos(x, y)
    return math_floor(x / SceneConstant.BlockSize.w), math_floor(y / SceneConstant.BlockSize.h)
end

function SceneManager:GetJumpConfig(jump_id, jump_count)
    if not jump_id or jump_id == enum.JUMP.JUMP_TYPE_NORMAL then
        return nil
    end
    local scene_id = self:GetSceneId()
    if not JumpConfig[scene_id] or not JumpConfig[scene_id][jump_id] then
        return
    end
    local count = #JumpConfig[scene_id][jump_id]
    return JumpConfig[scene_id][jump_id][jump_count], count == jump_count
end

function SceneManager:GetJumpEndPos(jump_id)
    if not jump_id or jump_id == enum.JUMP.JUMP_TYPE_NORMAL then
        return nil
    end
    local scene_id = self:GetSceneId()
    if not JumpConfig[scene_id] or not JumpConfig[scene_id][jump_id] then
        return nil
    end
    local count = #JumpConfig[scene_id][jump_id]
    local end_jump_config = JumpConfig[scene_id][jump_id][count]
    return end_jump_config and end_jump_config.end_pos
end

function SceneManager:Update(deltaTime)
    if self.main_role then
        self.main_role:Update(deltaTime)
    end

    if not self.is_chang_scene then
        for k, delay_list in pairs(self.wait_create_object_list) do
            while delay_list.length > 0 do
                local object_uid = delay_list:shift()
                self:CreateObject(object_uid)
            end
        end

        if not table.isempty(self.wait_create_drop_list) then
            local delete_tab
            for from, info in pairs(self.wait_create_drop_list) do
                local from_object = self:GetObject(from)
                if not from_object or from_object:IsDeath() or Time.time - info.drop_time > 3.0 then
                    for i = 1, #info do
                        local object_uid = info[i]
                        self:CreateObject(object_uid)
                    end
                    delete_tab = delete_tab or {}
                    delete_tab[#delete_tab + 1] = from
                end
            end
            if delete_tab then
                for k, from in pairs(delete_tab) do
                    self.wait_create_drop_list[from] = nil
                end
            end
        end
    end

    -- if self.need_create_main_role_id then
    --     self:CreateMainRole(self.need_create_main_role_id)
    -- end

    for _, type_list in pairs(self.object_list) do
        for _, object in pairs(type_list) do
            object:Update(deltaTime)
        end
    end

    for owner_id, actor_list in pairs(self.depend_object_list) do
        for actor_type, object_list in pairs(actor_list) do
            for index, object in pairs(object_list) do
                object:Update(deltaTime)
            end
        end
    end

    self:CheckMainRolePosition()
    if not self.is_chang_scene then
        self:CheckLockCreep()
    end

    if self.lock_npc_id and (not self.last_check_lock_npc_time or Time.time - self.last_check_lock_npc_time > 0.2) then
        self.last_check_lock_npc_time = Time.time
        local object = self:GetObject(self.lock_npc_id)
        if not object or object:IsDeath() or object.is_dctored or
        not MapLayer:GetInstance():IsInScreen(object:GetPosition()) then
            self:UnLockNpc(self.lock_npc_id)
        end
    end
end

function SceneManager:ShowRole(object)
    if object and object.object_info then
        local id = object.object_info.uid;
        if SettingModel:GetInstance().isShowRole == false then
            -- role:ShowBody(false)
            object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingVisible)
            object:UpdateVisible()
        end

        if table.nums(self.showRoleList) >= SettingModel:GetInstance().maxShowRoleNum and not self.showRoleList[id] then
            object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingNum)
            object:UpdateVisible()
            self.showRoleList[id] = nil;
        else
            self.showRoleList[id] = true;
        end
    end
end

function SceneManager:ShowMonster(object)
    if object and object.object_info then
        local id = object.object_info.uid;
        if not SettingModel:GetInstance().isHideMonster then
            -- or not self.showRoleList[id]
            --print2(id, "显示", mon.object_info.name);

            -- mon:ShowBody(true);
            -- self.showMonList[id] = mon;
        else
            --print2(id, "不显示", mon.object_info.name);
            -- mon:ShowBody(false);
            -- self.showMonList[id] = nil;

            object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingVisible)
            object:UpdateVisible()
        end
    end
end

function SceneManager:UpdateRoleVisibleState()
    local list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_ROLE];
    local t = {}
    if list then
        for k, role in pairs(list) do
            -- self:ShowRole(role);
            t[#t+1] = role
        end
        table.sort(t,sortClassFunc)
    end
    local robotList = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT]

    local t2 = {}
    if robotList then
        for k, role in pairs(robotList) do
            t2[#t2+1] = role
        end
        table.sort(t2,sortClassFunc)
    end
    table.insertarray(t, t2)

    for i=1,SettingModel:GetInstance().maxShowRoleNum do
        local object = t[i]
        if object then
            local id = object.object_info.uid
            if not self.showRoleList[id] then
                object:SetVisibleStateBit(false,SceneManager.SceneObjectVisibleState.SettingNum)
                object:UpdateVisible()
                self.showRoleList[id] = true
            end
        end
    end
    for i=SettingModel:GetInstance().maxShowRoleNum+1,#t do
        local object = t[i]
        if object then
            local id = object.object_info.uid
            if self.showRoleList[id] then
                object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingNum)
                object:UpdateVisible()
                self.showRoleList[id] = nil
            end
        end
    end
end

-- 弃用
function SceneManager:ShowAllMonster(bool)
    bool = toBool(bool);
    local list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_CREEP];
    if list then
        for k, monster in pairs(list) do
            -- monster:ShowBody(bool);
            monster:SetVisibleStateBit(not bool,SceneManager.SceneObjectVisibleState.SettingVisible)
            monster:UpdateVisible()
        end
    end
end

function SceneManager:ShowAllTitle()
    local list = self.object_list[enum.ACTOR_TYPE.ACTOR_TYPE_ROLE];
    if list then
        for k, role in pairs(list) do
            role:SetTitle();
        end
    end
    if self.main_role then
        self.main_role:SetTitle();
    end
end

function SceneManager:SetFlyCallBack(callback)
    self.fly_call_back = callback
end

function SceneManager:GetFlyCallBack()
    if not self.fly_call_back then
        return nil
    end
    local fly_call_back = self.fly_call_back
    return function()
        if fly_call_back ~= self.fly_call_back then
            return
        end
        if self.fly_call_back then
            self.fly_call_back()
        end
        self.fly_call_back = nil
    end
end

function SceneManager:IsSameGroup(group)
    if not self.main_role or not self.main_role.object_info then
        return false
    end
    return not (self.main_role.object_info.group == 0 or group == 0 or self.main_role.object_info.group ~= group)
end

function SceneManager:IsSameServer(suid)
    if not self.main_role or not self.main_role.object_info then
        return false
    end
    return self.main_role.object_info.suid == suid
end

function SceneManager:SetObjectBitStateByType(type,is_add,state)
    if not self.object_visible_bit_list[type] then
        logError("===SetObjectBitStateByType==type is nil",type)
        return
    end
    local old_state_bool = self:GetObjectBitStateByType(type)
    if is_add then
        if self.object_visible_bit_list[type]:Contain(state) then
            return
        end
        self.object_visible_bit_list[type]:Add(state)
    else
        if not self.object_visible_bit_list[type]:Contain(state) then
            return
        end
        self.object_visible_bit_list[type]:Remove(state)
    end
    local cur_state_bool = self:GetObjectBitStateByType(type)
    -- if old_state_bool == cur_state_bool then
    --     return
    -- end

    if getDependCreateFunc(type) then
        local list = self:GetDependObjectListByType(type)
        if not list then
            return
        end
        for k,object in pairs(list) do
            object:SetVisibleStateBit(is_add,state)
            object:UpdateVisible()
        end
    else
        local list = self:GetObjectListByType(type)
        if not list then
            return
        end
        for k,object in pairs(list) do
            object:SetVisibleStateBit(is_add,state)
            object:UpdateVisible()
        end
    end
end

function SceneManager:GetObjectBitStateByType(type,state)
    if not self.object_visible_bit_list[type] then
        logError("===SetObjectBitStateByType==type is nil",type)
        return
    end
    return not self.object_visible_bit_list[type]:Contain(state)
end

function SceneManager:SetObjectsBitState(is_add,state)
	self:SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP,is_add,state)
	self:SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_NPC,is_add,state)
	self:SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_DROP,is_add,state)
	self:SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL,is_add,state)
	self:SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_EFFECT,is_add,state)
	self:SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_JUMP,is_add,state)
end

function SceneManager:SetObjectBitStateByID(id,is_add,state)
    local object = self:GetObject(id)
    if not object then
        return
    end
    object:SetVisibleStateBit(is_add,state)
    object:UpdateVisible()
end

function SceneManager:SetObjectTypeShowType(actor_type,value)
    self.object_type_show_num[actor_type] = value
end
function SceneManager:GetObjectTypeShowType(actor_type)
    return self.object_type_show_num[actor_type]
end

function SceneManager:SetObjectStateByNumber(object)
    if not object then
        return
    end
    local actor_type = object.object_type

    local cur_state_bool = self:GetObjectBitStateByType(actor_type,SceneManager.SceneObjectVisibleState.SettingVisible)
    if not cur_state_bool then
        object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingVisible)
        object:UpdateVisible()
    end

    local num = self:GetObjectTypeShowType(actor_type)
    if not num then
        return
    end

    self.object_type_has_show_number[actor_type] = self.object_type_has_show_number[actor_type] or 0
    local object_type_has_show_number = self.object_type_has_show_number[actor_type]
    if object_type_has_show_number >= num then
        object:SetVisibleStateBit(true,SceneManager.SceneObjectVisibleState.SettingNum)
        object:UpdateVisible()
    else
        self.object_type_has_show_number[actor_type] = self.object_type_has_show_number[actor_type] + 1
    end
end

function SceneManager:SetObjectTypeStateByNumber(actor_type)
    local num = self:GetObjectTypeShowType(actor_type)
    if not num then
        return
    end
    local list
    local is_depend_obejct = getDependCreateFunc(actor_type) ~= nil
    if is_depend_obejct then
        list = self:GetDependObjectListByType(actor_type)
    else
        local t = self:GetObjectListByType(actor_type)
        if not t then
            return
        end
        list = {}
        for k,object in pairs(t) do
            if not object.is_dctored then
                list[#list+1] = object
            end
        end
    end
    if table.isempty(list) then
        return
    end
    -- 主角自己的要优先显示
    if is_depend_obejct then
        local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
        local function sortFunc(a,b)
            local is_main_role_1 = a.owner_id == main_role_id
            local is_main_role_2 = b.owner_id == main_role_id
            if is_main_role_1 == is_main_role_2 then
                return sortClassFunc(a.owner_info,b.owner_info)
            else
                return is_main_role_1
            end
        end
        table.sort(list,sortFunc)
    else
        table.sort(list,sortClassFunc)
    end
    local len = #list
    for i=1,len do
        local object = list[i]
        object:SetVisibleStateBit(i > num,SceneManager.SceneObjectVisibleState.SettingNum)
        object:UpdateVisible()
    end

    self.object_type_has_show_number[actor_type] = len > num and num or len
end

function SceneManager:GetFirstDanceInfo(gender,start_time)
    local role_list = self:GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE)
    if not role_list then
        return nil
    end
    local first_start_time = start_time
    local info
    for k,object in pairs(role_list) do
        if object.object_info.gender == gender then
            local dance_info = object:GetDanceActionInfo()
            if dance_info and dance_info.start_dance_time < first_start_time then
                first_start_time = dance_info.start_dance_time
                info = dance_info
            end
        end
    end

    if self.main_role then
        local dance_info = self.main_role:GetDanceActionInfo()
        if dance_info and dance_info.start_dance_time < first_start_time then
            first_start_time = dance_info.start_dance_time
            info = dance_info
        end
    end
    return info
end

function SceneManager:ShowMapTitle(sceneId)
    local item = SceneObjTitle(panelMgr:GetLayer("UI"))
    item:ShowAni(sceneId)
end

local monster_object_list = {}
function SceneManager:TestScene()
    self:StopTestSceneTimeID()
    if self:GetSceneId() ~= 99998 then
        return
    end
    local monster_list = SceneConfigManager:GetInstance():GetAllMonsterDataByRes()
    local index = 1

    local main_role = self:GetMainRole()
    local main_role_pos = main_role:GetPosition()

    local function step()
        for k,v in pairs(monster_object_list) do
            v:destroy()
        end
        monster_object_list = {}

        local p_creep = monster_list[index]
        for i=1,5 do
            local p_actor = {
                uid = "-" .. i .. "0" .. p_creep.id,
                name = p_creep.name,
                coord = _G.pos(main_role_pos.x + (i-3) * 200 ,main_role_pos.y + 200),
                dest = _G.pos(0,0),
                dir = 180,
                creep = clone(p_creep),
                type = enum.ACTOR_TYPE.ACTOR_TYPE_CREEP,
            }

            p_actor.dest.x = p_actor.coord.x
            p_actor.dest.y = p_actor.coord.y

            p_actor.creep.dest.x = p_actor.coord.x
            p_actor.creep.dest.y = p_actor.coord.y

            self:SetObjectInfo(p_actor)
            self:AddObject(p_actor.uid)
            monster_object_list[p_actor.uid] = self:GetObject(p_actor.uid)
        end
        index = index + 1
        if index > #monster_list then
            index = 1
        end
    end
    self.test_scene_time_id = GlobalSchedule:Start(step,20,-1)
end

function SceneManager:StopTestSceneTimeID()
    if self.test_scene_time_id then
        GlobalSchedule:Stop(self.test_scene_time_id)
        self.test_scene_time_id = nil
    end
    for k,v in pairs(monster_object_list) do
        v:destroy()
    end
    monster_object_list = {}
end