-- 
-- @Author: LaoY
-- @Date:   2018-07-27 20:23:55
-- 

require('game.fight.RequireFight')
FightController = FightController or class("FightController", BaseController)
local FightController = FightController

function FightController:ctor()
    FightController.Instance = self
    FightManager:GetInstance()
    AutoFightManager:GetInstance()

    self.skillMgr = SkillManager:GetInstance()
    self.mgr = FightManager:GetInstance()

    self:AddEvents()
    self:RegisterAllProtocal()
end

function FightController:dctor()
end

function FightController:Reset()
    self.last_ordinary_time = 0
    self.last_skill_time = 0
end

function FightController:GetInstance()
    if not FightController.Instance then
        FightController.new()
    end
    return FightController.Instance
end

function FightController:RegisterAllProtocal()
    self.pb_module_name = "pb_1201_fight_pb"
    self:RegisterProtocal(proto.FIGHT_ATTACK, self.HandleFightAttack)
    self:RegisterProtocal(proto.FIGHT_REVIVE, self.HandleFightRevive)
    self:RegisterProtocal(proto.FIGHT_DEAD, self.HandleFightDead);
    self:RegisterProtocal(proto.FIGHT_PKMODE, self.HandlePkMode)
    self:RegisterProtocal(proto.FIGHT_COLLECT, self.HandleFightCollect)
    self:RegisterProtocal(proto.FIGHT_PICKUP, self.HandleFightPickup)
    self:RegisterProtocal(proto.FIGHT_AUTOPICK, self.HandleAutoFightPickup)
    self:RegisterProtocal(proto.FIGHT_DAMAGE, self.HandleFightDamage)
    self:RegisterProtocal(proto.FIGHT_ENEMIES, self.HandleEnemies)
    self:RegisterProtocal(proto.FIGHT_ENEMY, self.HandleEnemy)
end

function FightController:AddEvents()
    local function ON_REQ_REVIVE(type)
        self:RequestFightRevive(type)
    end
    GlobalEvent:AddListener(FightEvent.Revive, ON_REQ_REVIVE)

    local function ON_REQ_PKMODE(pkmode)
        if pkmode == self.mgr.pkmode then
            return
        end
        self:RequestPkMode(pkmode)
    end
    GlobalEvent:AddListener(FightEvent.ReqPKMode, ON_REQ_PKMODE)

    local function ON_REQ_COLLECT(uid, type)
        self:RequestFightCollect(uid, type)
    end
    GlobalEvent:AddListener(FightEvent.ReqCollect, ON_REQ_COLLECT)

    local function ON_REQ_PICKUP(uid, scene_id)
        self:RequestFightPickup(uid, scene_id)
    end
    GlobalEvent:AddListener(FightEvent.ReqPickUp, ON_REQ_PICKUP)

    local function call_back()
        -- 模式改变，需要判断当前选择的人能不能攻击
        self.mgr:CheckLockFightTarget()
    end
    GlobalEvent:AddListener(FightEvent.AccPKMode, call_back)


    local function call_back(uids, scene_id)  --自动拾取
        self:RequestAutoFightPickup(uids, scene_id)
    end
    GlobalEvent:AddListener(FightEvent.ReqAutoPickUp, call_back)

	
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    local function call_back(pkmode)
        FightManager:GetInstance().pkmode = pkmode
    end
    main_role_data:BindData("pkmode",call_back)
end

-- overwrite
function FightController:GameStart()

    GlobalSchedule:StartOnce(handler(self,self.RequestEnemies), Constant.GameStartReqLevel.VLow)
end

local last_ordinary_time = 0
----请求基本信息
function FightController:RequestFightAttack(unit, skill, dir, defid, seq)
    -- Yzprint('--LaoY FightController.lua,line 44-- data=',unit,skill,dir,defid)
    local pb = self:GetPbObject("m_fight_attack_tos")
    pb.unit = unit
    pb.skill = skill
    pb.dir = dir
    pb.defid = defid
    pb.seq = seq

    if AppConfig.Debug then
        local skill_key = skill .. "_" .. seq
        Yzprint('--LaoY FightController.lua,line 94--', skill_key , Time.time)
    end

    local object = defid and SceneManager:GetInstance():GetObject(defid)
    if object then
        local pos = object.position
        pb.coord.x = pos.x
        pb.coord.y = pos.y
    else
        pb.coord.x = 0
        pb.coord.y = 0
    end
    local ordinary_index = SkillManager:GetInstance():IsOrdinarySkill(skill)
    if ordinary_index then
        if Time.time - last_ordinary_time <= FightConfig.PublicOrdinaryCD and AppConfig.Debug then
            Notify.ShowText("<color=#ffe27c>Client attack is too fast</color>", Time.time - last_ordinary_time)
        end
        last_ordinary_time = Time.time
    end
    self:WriteMsg(proto.FIGHT_ATTACK, pb)

    if not ordinary_index then
        SkillManager:GetInstance():SetSkillPublickCD(skill)
    end

    DebugManager.ProtoLog("m_fight_attack_tos",true,"Character sends pack")
end

----服务的返回信息
function FightController:HandleFightAttack()
    local data = self:ReadMsg("m_fight_attack_toc")
    data.message_time = Time.time
    FightManager:GetInstance():ReceiveFightMessage(data)

    -- local object = SceneManager:GetInstance():GetObject(data.atkid)
    -- Yzprint('--LaoY FightController.lua,line 63--',data.atkid)
    -- if data.atkid == RoleInfoModel:GetInstance():GetMainRoleId() then 
    --     Yzprint('--LaoY FightController.lua,line 111--')
    --     Yzdump(data,"data")
    -- elseif (object and object.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE) then
    --     Yzprint('--LaoY FightController.lua,line 115--')
    --     --dump(data,"data")
    -- end

    -- Yzprint('--LaoY FightController.lua,line 123--',Time.time)
    -- Yzdump(data,"data")

    if data.atkid == RoleInfoModel:GetInstance():GetMainRoleId() then
        SkillUIModel:GetInstance():UpdateSKillCd(data.skill, tonumber(data.cd))

        if SkillManager:GetInstance():IsPetSkill(data.skill) then
            Yzprint('--LaoY FightController.lua,line 143--', data.skill, tonumber(data.cd))
        end
        SkillModel:GetInstance():Brocast(SkillEvent.UPDATE_SKILL_CD, data.skill, tonumber(data.cd))
        SkillManager:GetInstance():ReciveSkillSuccess(data.skill)

        DebugManager.ProtoLog("m_fight_attack_toc",false,"Character receives pack")
    end
end

function FightController:RequestFightRevive(type)
    -- Yzprint('--LaoY FightController.lua,line 82-- type=',type)
    local pb = self:GetPbObject("m_fight_revive_tos")
    pb.type = type
    self:WriteMsg(proto.FIGHT_REVIVE, pb)
end

function FightController:HandleFightRevive()
    local data = self:ReadMsg("m_fight_revive_toc")
    local object = SceneManager:GetInstance():GetObject(data.uid)
    local force = FightManager:GetInstance():Revive(data.uid)
    -- print('--LaoY FightController.lua,line 135--',data.uid,object and object.__cname)
    if object then
        if data.type == enum.REVIVE_TYPE.REVIVE_TYPE_SAFE then
            local pos = data.dest
            object:SetPosition(pos.x, pos.y)
            if object.is_main_role then
                object:SetLastSynchronousePos(pos)
            end
        end
        object:Revive(force)
    end
end

function FightController:HandleFightDead()
    local data = self:ReadMsg("m_fight_dead_toc")
    local object = SceneManager:GetInstance():GetObject(data.uid);
    if object then
        object:PlayDeath()
    end
    local type = data.type;

    --新版本直接读who,不需要自已串
    local bossName = data.who;

    local auto_revive = data.args["auto_revive"];
    auto_revive = auto_revive or os.time() + 60;
    print(auto_revive, os.time())
    auto_revive = tonumber(auto_revive) - os.time();

    if type == enum.DEAD_TYPE.DEAD_TYPE_NORM or type == enum.DEAD_TYPE.DEAD_TYPE_TIRED then
        local okfun = function()
            --local sceneConfig = Config.db_scene[SceneManager:GetInstance():GetSceneId()]
            --local cost = nil;
            --if sceneConfig then
                --cost = String2Table(sceneConfig.revive_cost);
                ----RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold]
                --local costNum = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldIDMap[cost[1] ]];--Constant.GoldType.Gold
                --if costNum and tonumber(costNum) < tonumber(cost[2]) then
                    --Notify.ShowText(enumName.ITEM[cost[1]] .. "不足,无法复活");
                    --return
                --end
            --end
            local panel = lua_panelMgr:GetPanel(RevivePanel)
            if panel then
                panel:Close();
            end
            panel = lua_panelMgr:GetPanel(RevivePanel2)
            if panel then
                panel:Close();
            end
            FightController:GetInstance():RequestFightRevive(enum.REVIVE_TYPE.REVIVE_TYPE_SITU);
        end

        local cancelfun = function(rp)
            if rp then
                rp:Close();
            end
            FightController:GetInstance():RequestFightRevive(enum.REVIVE_TYPE.REVIVE_TYPE_SAFE);
        end

        local cancelfun2 = function()
            auto_revive = data.args["auto_revive"] and data.args["auto_revive"] - os.time() or 60
            Dialog.ShowRevive2("Tip", nil, "Revive on spot", okfun, auto_revive, "Cancel", nil, 60, "%s");
        end

        if type == enum.DEAD_TYPE.DEAD_TYPE_NORM then
            Dialog.ShowRevive("Revive", "You have been <color=#0ba807>" .. bossName .. "</color> defeated!!", "Revive on spot", okfun, nil, "Normal resurrection", cancelfun, auto_revive, "(Resurrect at the resurrection point in %s sec)");
        elseif type == enum.DEAD_TYPE.DEAD_TYPE_TIRED then
            Dialog.ShowRevive("Revive", "You have been <color=#0ba807>" .. bossName .. "</color> defeated!!", "Revive on spot", okfun, nil, "Normal resurrection", cancelfun2, auto_revive, "(Resurrect at the resurrection point in %s sec)");
        end
    elseif type == enum.DEAD_TYPE.DEAD_TYPE_AUTO then
        DungeonCtrl:GetInstance():OpenDungeonCountDownRevivePanel(auto_revive);
    end
    -- Yzprint('--LaoY FightController.lua,line 90--',data.uid,object)
    --if object then
    --    object:Revive()
    --end
end

--切换pk模式
function FightController:RequestPkMode(pkmode)
    local pb = self:GetPbObject("m_fight_pkmode_tos")
    pb.pkmode = pkmode
    self:WriteMsg(proto.FIGHT_PKMODE, pb)
end
function FightController:HandlePkMode()
    local data = self:ReadMsg("m_fight_pkmode_toc")
    -- self.mgr.pkmode = data.pkmode
    -- GlobalEvent:Brocast(FightEvent.AccPKMode,data.pkmode)
    local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    role_data:ChangeData("pkmode", data.pkmode)
    SceneManager:GetInstance():CheckLockCreep(true)
end

-- 采集
function FightController:RequestFightCollect(uid, type)
    SceneManager:GetInstance():GetMainRole():TrySynchronousPosition(true)

    local pb = self:GetPbObject("m_fight_collect_tos")
    --pb.uid = tonumber(uid)
    pb.uid = uid
    pb.type = type
    -- Yzprint('--LaoY FightController.lua,line 118-- data=', uid, type)
    self:WriteMsg(proto.FIGHT_COLLECT, pb)
    local main_role = SceneManager:GetInstance():GetMainRole()
    main_role.is_waiting_collect = true

    self:StopWaitCollectTime()
    local function step()
        main_role.is_waiting_collect = false
    end
    self.waiting_collect_time_id = GlobalSchedule:StartOnce(step,0.5)
end

function FightController:StopWaitCollectTime()
    if self.waiting_collect_time_id then
        GlobalSchedule:Stop(self.waiting_collect_time_id)
        self.waiting_collect_time_id = nil
    end
end

function FightController:HandleFightCollect()
    local data = self:ReadMsg("m_fight_collect_toc")
    -- GlobalEvent:Brocast(FightEvent.AccCollect, data.uid, data.type)

    local main_role = SceneManager:GetInstance():GetMainRole()
    self:StopWaitCollectTime()
    main_role.is_waiting_collect = false
    if data.type == 1 then
        local object = SceneManager:GetInstance():GetObject(data.uid)
        if object then
            FightManager:GetInstance():DoCollect(main_role,object)
        end
    elseif data.type == 2 then
        local object = SceneManager:GetInstance():GetObject(data.uid)
        if object then
            object:PlayCollectSuccess()
        end
    elseif data.type == 3 then
        if main_role and main_role:IsCollecting() then
            main_role:ChangeToMachineDefalutState()
        end
        -- local object = SceneManager:GetInstance():GetObject(data.uid)
        -- if object and object:IsCollecting() then
        --     object:ChangeToMachineDefalutState()
        -- end
    end
end

-- 拾取
function FightController:RequestFightPickup(uid, scene_id)
    local pb = self:GetPbObject("m_fight_pickup_tos")
    pb.uid = uid
    pb.scene = scene_id
    self:WriteMsg(proto.FIGHT_PICKUP, pb)
end
function FightController:HandleFightPickup()
    local data = self:ReadMsg("m_fight_pickup_toc")
    print('--LaoY FightController.lua,line 140--')
    dump(data, "data")
    -- if data.type == 2 then
        GlobalEvent:Brocast(FightEvent.AccPickUp, data.uid)
    -- end
end

--自动拾取
function FightController:RequestAutoFightPickup(uids, scene_id)
    local pb = self:GetPbObject("m_fight_autopick_tos")
    for i, tab in pairs(uids) do
        pb.uids:append(tab.id)
    end
    pb.scene = scene_id
    self:WriteMsg(proto.FIGHT_AUTOPICK, pb)
end

function FightController:HandleAutoFightPickup()
    local data = self:ReadMsg("m_fight_autopick_toc")

    GlobalEvent:Brocast(FightEvent.AccAutoPickUp, data.uids)
end

--获取敌对列表
function FightController:RequestEnemies()
    local pb = self:GetPbObject("m_fight_enemies_tos")
    self:WriteMsg(proto.FIGHT_ENEMIES, pb)
end

function FightController:HandleEnemies()
    local data = self:ReadMsg("m_fight_enemies_toc")

    SiegewarModel.GetInstance():SetEnemies(data.enemies)
end

--设置敌对
function FightController:SetEnemy(suid, op)
    local pb = self:GetPbObject("m_fight_enemy_tos")
    pb.suid = suid
    pb.type = op
    self:WriteMsg(proto.FIGHT_ENEMY, pb)
end

function FightController:HandleEnemy()
    local data = self:ReadMsg("m_fight_enemy_toc")

    SiegewarModel.GetInstance():UpdateEnemy(data)
    GlobalEvent:Brocast(FightEvent.UpdateEnemy)
end




function FightController:RequestNewBie(uid, id, skill, dir, seq)
    -- Yzprint('--LaoY FightController.lua,line 44-- data=',unit,skill,dir,defid)
    Yzprint('--LaoY FightController.lua,line 256--', uid, id, skill, dir, seq)
    local pb = self:GetPbObject("m_fight_newbie_tos")
    pb.uid = uid
    pb.id = id
    pb.skill = skill
    pb.dir = dir
    pb.seq = seq

    local ordinary_index = SkillManager:GetInstance():IsOrdinarySkill(skill)
    if ordinary_index then
        if Time.time - last_ordinary_time <= FightConfig.PublicOrdinaryCD and AppConfig.Debug then
            Notify.ShowText("<color=#ffe27c>Client attack is too fast</color>", Time.time - last_ordinary_time)
        end
        last_ordinary_time = Time.time
    end
    self:WriteMsg(proto.FIGHT_NEWBIE, pb)

    if not ordinary_index then
        SkillManager:GetInstance():SetSkillPublickCD(skill)
    end
end

function FightController:HandleFightDamage()
    local data = self:ReadMsg("m_fight_damage_toc")
    local cur_time = Time.time
    local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
    for k,damage in pairs(data.dmgs) do
        local object = SceneManager:GetInstance():GetObject(damage.uid)
        if object then
            object:SetHp(damage.hp,cur_time)
            if damage.hp <= 0 then
                object:PlayDeath(nil,true)
            end
        end
        if damage.uid == main_role_id then
            local info = {damage = damage,coord = data.coord}
            FightManager:GetInstance():AddTextInfo(info)
        else
            local damagetext = DamageText(nil,nil,damage)
            damagetext:SetData(nil,damage,nil,data.coord)
        end
    end
    Yzprint('--LaoY FightController.lua,line 390--')
    Yzdump(data,"data")
end