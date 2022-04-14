--
-- @Author: chk
-- @Date:   2018-07-19 11:35:32
--

require "game.scene.RequireScene"

SceneControler = SceneControler or class("SceneControler", BaseController)

function SceneControler:ctor()
    SceneControler.Instance = self
    self.mgr = SceneManager:GetInstance()

    SceneConfigManager()
    OperationManager()
    BuffManager()

    self:AddEvents()
    self:RegisterAllProtocal()

    self.last_syn_pos = {}
end

function SceneControler:dctor()
end

function SceneControler:GetInstance()
    if not SceneControler.Instance then
        SceneControler.new()
    end
    return SceneControler.Instance
end

function SceneControler:AddEvents()
    local function call_back(vec2)
        local main_role = SceneManager:GetInstance():GetMainRole()
        if not main_role then
            return
        end

        local bo, buff_effect_type = main_role.object_info:IsCanMoveByBuff()
        if not bo then
            main_role:MoveDebuffTip(buff_effect_type)
            return
        end
        Rocker.IsRocking = vec2 ~= nil
        main_role:SetDirection(vec2)
    end
    GlobalEvent:AddListener(MainEvent.MoveRocker, call_back)

    local function call_back(x, y)
        self:RequestSceneMove(x, y)
    end
    GlobalEvent:AddListener(SceneEvent.RequestMove, call_back)

    local function call_back(x, y, dir, state)
        self:RequestSceneDest(x, y, dir, state)
    end
    GlobalEvent:AddListener(SceneEvent.RequestDest, call_back)

    -- 请求冲刺
    local function call_back(x, y)
        self:RequestSceneRush(x, y)
    end
    GlobalEvent:AddListener(SceneEvent.RequestRush, call_back)

    -- 请求跳跃
    local function call_back(start, dest, type)
        self:RequestSceneJump(start, dest, type)
    end
    GlobalEvent:AddListener(SceneEvent.RequestJump, call_back)

    local function call_back(scene_id, change_type, coord, portal)
        if self.mgr:GetSceneId() == scene_id then
            return
        end
        self:RequestSceneChange(scene_id, change_type, coord, portal)
    end
    GlobalEvent:AddListener(SceneEvent.RequestChangeScene, call_back)

    local function ON_SCENE_TALK(npc_id, task_id)
        local main_role = SceneManager:GetInstance():GetMainRole()
        if main_role then
            main_role:TrySynchronousPosition(true)
        end

        self:RequestSceneTalk(npc_id, task_id)
    end
    GlobalEvent:AddListener(SceneEvent.RequestTalk, ON_SCENE_TALK)

    --切换场景开始
    -- local function call_back()
    --     self.mgr:SetChangeSceneState(true)
    -- end
    -- GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)

    local function call_back()
        self.mgr:SetChangeSceneState(false)
        self.mgr:TestScene()
        lua_resMgr:CheckUnLoadSceneAssset()
        local sceneId = SceneManager:GetInstance():GetSceneId()
        local cfg = Config.db_scene[sceneId]
        if cfg and cfg.map_float == 1 and cfg.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER then
            self.mgr:ShowMapTitle(sceneId)
        end
    end
    GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

    local function call_back(x, y, block_pos_x, block_pos_y)
        -- self.mgr:CheckMainRolePosition(x,y,block_pos_x,block_pos_y)
    end
    GlobalEvent:AddListener(SceneEvent.MainRolePos, call_back)

    local function call_back(x, y, type)
        self:RequestSceneTeleport(x, y, type)
    end
    GlobalEvent:AddListener(SceneEvent.RequestTeleport, call_back)

    local function call_back()
        self.mgr:CheckLockCreep()
    end
    GlobalEvent:AddListener(FightEvent.StartAutoFight, call_back)

    local function call_back()
        --logError(SceneManager:GetInstance():GetSceneId())
        local sceneId = SceneManager:GetInstance():GetSceneId()
        local cfg = Config.db_scene[sceneId]
        if cfg and cfg.map_float == 1  then
            self.mgr:ShowMapTitle(sceneId)
        end
    end
    GlobalEvent:AddListener(EventName.DestroyLoading, call_back)

end

-- overwrite
function SceneControler:GameStart()
    self.mgr:CreateMainRole()
end


--[[
	@author LaoY
	@des	使用小飞鞋 后续要支持跨场景
	@param1 free 	当次免费使用
--]]
local last_use_fly_time = 0
function SceneControler:UseFlyShoeToPos(scene_id, x, y, free, callback)
    if FactionEscortModel:GetInstance().isEscorting then
        Notify.ShowText("You can't use fly kicks when traveling")
        return
    end
    if Time.time - last_use_fly_time < 0.1 then
        return
    end
    last_use_fly_time = Time.time

    local is_can_use = true
    -- if free then
    -- 	is_can_use = true
    -- end
    -- Yzprint('--LaoY SceneControler.lua,line 123--',data)
    -- traceback()

    -- 需要判断VIP 小飞鞋材料数量
    local num = BagModel:GetInstance():GetItemNumByItemID(enum.ITEM.ITEM_SHOES)
    local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
    if not viplv and num <= 0 then
        return
    end

    if viplv < 1 and num <= 0 then
        if not free then
            local function call_back()
                GlobalEvent:Brocast(VipEvent.OpenVipPanel)
            end
            Dialog.ShowTwo("Tip", "You fly kicks is 0\nYour usage on fly kicks will not be limited when you are or above VIP1, upgrade your vip?", "Upgrade VIP", call_back, nil, "Close", nil, nil)
        end
        return
    end

    if not is_can_use then
        return
    end
    local main_role = self.mgr:GetMainRole()
    if main_role then
        if main_role:IsJumping() then
            Notify.ShowText("You can't use fly kicks when jumping")
            return
            -- elseif main_role:IsAttacking() then
        elseif main_role:IsFightRole() then
            Notify.ShowText("You can't use fly kicks when in combat")
            return
        elseif main_role:IsFlying() then
            Notify.ShowText("Using fly kicks")
            return
        end

        local bo, buff_effect_type = main_role.object_info:IsCanMoveByBuff()
        if not bo then
            main_role:MoveDebuffTip(buff_effect_type, "Use fly kicks")
            return
        end
    end
    if Vector2.DistanceNotSqrt(main_role.position, pos(x, y)) <= 1e-5 then
        if callback then
            callback()
        end
        return
    end

    if main_role then
        main_role:SetLastSynchronousePos(main_role.position)
    end


    if scene_id ~= self.mgr:GetSceneId() then
        self:RequestSceneChange(scene_id, enum.SCENE_CHANGE.SCENE_CHANGE_SHOES, { x = x, y = y })
    else
        GlobalEvent:Brocast(SceneEvent.RequestTeleport, x, y, enum.TELEPORT.TELEPORT_SHOES)
    end
    self.mgr:SetFlyCallBack(callback)
    return true
end

-- 协议相关
function SceneControler:RegisterAllProtocal()
    self.pb_module_name = "pb_1200_scene_pb"
    self:RegisterProtocal(proto.SCENE_CHANGE, self.HandleSceneChange)
    self:RegisterProtocal(proto.SCENE_LEAVE, self.HandleSceneLeave)
    self:RegisterProtocal(proto.SCENE_MOVE, self.HandleSceneMove)
    self:RegisterProtocal(proto.SCENE_DEST, self.HandleSceneDest)
    self:RegisterProtocal(proto.SCENE_SWITCH, self.HandleSceneSwitch)
    self:RegisterProtocal(proto.SCENE_TELEPORT, self.HandleSceneTeleport)
    self:RegisterProtocal(proto.SCENE_UPDATE, self.HandleSceneUpdate)

    self:RegisterProtocal(proto.ACTOR_UPDATE, self.HandleActorUpdate)
    self:RegisterProtocal(proto.BUFF_UPDATE, self.HandleBuffUpdate)
    self:RegisterProtocal(proto.SCENE_RUSH, self.HandleSceneRush)
    self:RegisterProtocal(proto.SCENE_JUMP, self.HandleSceneJump)
    self:RegisterProtocal(proto.SCENE_TALK, self.HandleSceneTalk)        --场景对话

    self:RegisterProtocal(proto.SCENE_DROP, self.HandleSceneDrop)        --虚拟掉落

    self:RegisterProtocal(proto.ACTOR_UPDATEHP, self.HandleActorHpUpdate);        --特殊血条修改
    self:RegisterProtocal(proto.ACTOR_HEAL, self.HandleActorHeal);        --特殊血条修改

    self:RegisterProtocal(proto.SCENE_ENTER, self.HandleSceneEnter);        --切换网络重连 刷新场景


    -- self:RegisterProtocal(proto.ACTOR_ADD_BUFF, self.HandleAddBuff);        --
end

--切换场景,进入场景时也是用这个
function SceneControler:RequestSceneChange(sceneId, change_type, coord, portal, actid)
    if not SceneConfigManager:GetInstance():CheckEnterScene(sceneId, true) then
        return
    end
    portal = portal or 0
    change_type = change_type or enum.SCENE_CHANGE.SCENE_CHANGE_PROTAL
    local pb = self:GetPbObject("m_scene_change_tos")
    if sceneId then
        pb.scene = tonumber(sceneId)
    end
    pb.portal = portal
    pb.type = change_type
    if coord then
        pb.coord.x = coord.x
        pb.coord.y = coord.y
    end
    if actid then
        pb.act_id = actid;
    end
    self:WriteMsg(proto.SCENE_CHANGE, pb)
end

function SceneControler:HandleSceneChange()
    local data = self:ReadMsg("m_scene_change_toc")
    local status , value = pcall(self.mgr.RemoveAllObject,self.mgr)
    if not status then
        if AppConfig.Debug then
            logError("切场景报错：",value)
        end
    end
    BrocastModelEvent(EventName.CLEAR_BLOOD_MONSTER);
    local main_role = self.mgr:GetMainRole()
    -- self.mgr.is_transition = true
    self.mgr:SetChangeSceneState(true)


    local last_scene_id = self.mgr:GetSceneId()


    Yzprint('--LaoY SceneControler.lua,line 260--',last_scene_id,data.scene,data.type,data.actor.coord.x, data.actor.coord.y)
    
    local function callback()
        self.mgr:ChangeScene(data)
    end
    -- if data.type == enum.SCENE_CHANGE.SCENE_CHANGE_SHOES and main_role and main_role.is_loaded then
    if main_role and main_role.is_loaded and data.scene ~= self.mgr:GetSceneId() then
        if data.type == enum.SCENE_CHANGE.SCENE_CHANGE_SHOES then
            OperationManager:GetInstance():StopAStarMove()
        end
        if DungeonModel:GetInstance():IsNoviceDungeon(data.scene)then
            callback()
            return
        end
        main_role:PlayFlyUp(callback)
    else
        callback()
    end
end

-- 断线重连后重新走一次 进入场景
function SceneControler:HandleSceneEnter()
    local data = self:ReadMsg("m_scene_enter_toc")
    BrocastModelEvent(EventName.CLEAR_BLOOD_MONSTER);
    self.mgr:SetChangeSceneState(true)

    self.mgr:RemoveAllObject()
    MapLayer:GetInstance():ClearAllObjectState()

    local last_scene_id = self.mgr:GetSceneId()
    Yzprint('---LaoY SceneControler.lua,HandleSceneEnter--',last_scene_id,data.scene,data.type,data.actor.coord.x, data.actor.coord.y)

    local function callback()
        self.mgr:ChangeScene(data)
        MapLayer:GetInstance():UpdateObject()
    end
    callback()
end

--离开场景
function SceneControler:RequestSceneLeave(flag)
    local pb = self:GetPbObject("m_scene_leave_tos")
    if flag ~= nil then
        pb.mchunt = flag
    else
        pb.mchunt = false
    end
    self:WriteMsg(proto.SCENE_LEAVE, pb)
end

function SceneControler:HandleSceneLeave()
    local data = self:ReadMsg("m_scene_leave_toc")
end

--自己在场景移动，固定时间刷新
function SceneControler:RequestSceneMove(x, y)
    local pb = self:GetPbObject("m_scene_move_tos")
    pb.x = tonumber(x)
    pb.y = tonumber(y)
    self:WriteMsg(proto.SCENE_MOVE, pb)
    -- x = tonumber(x)
    -- y = tonumber(y)
    -- self:WriteBinaryMsg(proto.SCENE_MOVE,{"d","d"},x,y)
    self.last_syn_pos = { x = x, y = y }
end

function SceneControler:HandleSceneMove()
    local pb = self:ReadMsg("m_scene_move_toc")
    local x, y = pb.x, pb.y
    -- local x,y = self:ReadBinaryMsg({"d","d"})
    if not self.last_syn_pos or self.last_syn_pos.x ~= x or self.last_syn_pos.y ~= y then

    end
    -- MapManager.Instance:CreateMap(data.x,data.y)
end


--行走目的地
function SceneControler:RequestSceneDest(x, y, dir, state)
    -- Yzprint('--LaoY SceneControler.lua,line 256--', x, y, dir, state)
    local pb = self:GetPbObject("m_scene_dest_tos")
    pb.dest.x = tonumber(x)
    pb.dest.y = tonumber(y)
    if dir then
        pb.dir = dir
    end
    pb.state = state
    -- logWarn('--LaoY SceneControler.lua,line 174-- x,y=',x,y,dir)
    self:WriteMsg(proto.SCENE_DEST, pb)
end

function SceneControler:HandleSceneDest()
    local data = self:ReadMsg("m_scene_dest_toc")
    if data.uid == RoleInfoModel:GetInstance():GetMainRoleId() then
        return
    end
    -- if data.dest then
    -- logWarn('--LaoY SceneControler.lua,line 184--',data.uid,data.dest.x,data.dest.y,data.dir)
    -- end

    local object = SceneManager:GetInstance():GetObject(data.uid)
    local object_type = object and object.object_type
    if object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
        --print("------",data)
    end
    if object then
        -- object:SetMovePosition(data.dest,data.dir)
        object:SetServerPosition(data.dest, data.dir, data.state)
    end
end


--切换分线
function SceneControler:RequestSceneSwitch(line)
    local pb = self:GetPbObject("m_scene_switch_tos")
    pb.line = line
    self:WriteMsg(proto.SCENE_SWITCH, pb)
end

function SceneControler:HandleSceneSwitch()
    local data = self:ReadMsg("m_scene_switch_toc")
    local scene_data = SceneManager:GetInstance():GetSceneInfo()
    scene_data:ChangeData("line", data.line)
end

--瞬移
function SceneControler:RequestSceneTeleport(x, y, type)
    local pb = self:GetPbObject("m_scene_teleport_tos")
    pb.dest.x = x
    pb.dest.y = y
    pb.type = type or enum.TELEPORT.TELEPORT_SHOES
    self:WriteMsg(proto.SCENE_TELEPORT, pb)
end

function SceneControler:HandleSceneTeleport()
    local data = self:ReadMsg("m_scene_teleport_toc")
    -- MapManager.Instance:CreateMap(Vector3(data.x,data.y,0))

    if data.uid == RoleInfoModel:GetInstance():GetMainRoleId() then
        local main_role = self.mgr:GetMainRole()
        if data.type == enum.TELEPORT.TELEPORT_SHOES and main_role and main_role.is_loaded then
            OperationManager:GetInstance():StopAStarMove()
            local dis = Vector2.Distance(data.dest, main_role.position)

            if dis <= SceneConstant.FlyDisConfig.Rush then
                local function callback()
                    local callback = self.mgr:GetFlyCallBack()
                    if callback then
                        callback()
                    end
                end
                main_role:PlayRush(data.dest, callback, true)
                main_role:SetLastSynchronousePos(data.dest)
            elseif dis <= SceneConstant.FlyDisConfig.Jump then
                local function callback()
                    local callback = self.mgr:GetFlyCallBack()
                    if callback then
                        callback()
                    end
                end
                main_role:PlayJump(data.dest, 0, nil, true, callback)
                main_role:SetLastSynchronousePos(data.dest)
            else
                local function callback()
                    main_role:SetPosition(data.dest.x, data.dest.y)
                    main_role:TrySynchronousPosition(true)
                    local function step()
                        main_role:SetLastSynchronousePos(data.dest)
                        main_role:PlayFlyDown(self.mgr:GetFlyCallBack())
                        -- local callback = self.mgr:GetFlyCallBack()
                        -- if callback then
                        --     callback()
                        -- end
                    end
                    -- GlobalSchedule:StartOnce(step, 0.12)
                    step()
                end
                main_role:PlayFlyUp(callback)
            end
        end
        return
    end
    -- print("111")


    local object = SceneManager:GetInstance():GetObject(data.uid)
    if object then
        object:SetPosition(data.dest.x, data.dest.y)
    end
end


--场景对象(玩家，怪物)更新
function SceneControler:HandleSceneUpdate()
    local data = self:ReadMsg("m_scene_update_toc")
    -- print('--LaoY SceneControler.lua,line 222--')
    -- dump(data,"data")

    if not table.isempty(data.del) then
        -- SceneManager:GetInstance():RemoveObjectList(data.del)
        -- SceneManager:GetInstance():RemoveObjectListByServer(data.del)
        local status, err = pcall(self.mgr.RemoveObjectListByServer,self.mgr,data.del)
        if not status then
            logError(err)
        end
    end

    if not table.isempty(data.add) then
        SceneManager:GetInstance():AddObjectList(data.add)
    end
end

-- 场景对象更新(更新部分属性
function SceneControler:HandleActorUpdate()
    local data = self:ReadMsg("m_actor_update_toc")
    local scene_data = self.mgr:GetObjectInfo(data.uid)
    if not scene_data then
        return
    end
    -- if scene_data.__cname == "MonsterData" then
    -- 	Yzprint('--LaoY SceneControler.lua,line 359--')
    -- 	Yzdump(tab,"tab")
    -- end

    -- 玩家状态要额外处理 后续处理
    if data.upint.state then
        local object = self.mgr:GetObject(data.uid)
    end

    for k, v in pairs(data.upint) do
        if k ~= "state" then
            scene_data:ChangeData(k, v)
        end
    end
    for k, v in pairs(data.upstr) do
        scene_data:ChangeData(k, v)
    end
    for k, v in pairs(data.aspect) do
        scene_data:ChangeData(k, v)
    end

    if data.icon and not string.isempty(data.icon.pic) then
        scene_data:ChangeData("icon", data.icon)
    end
end

-- buff列表更新
function SceneControler:HandleBuffUpdate()
    local data = self:ReadMsg("m_buff_update_toc")
    local object_data = self.mgr:GetObjectInfo(data.uid)
    if not object_data then
        return
    end

    if not table.isempty(data.del) then
        object_data:RemoveBuffList(data.del)
    end

    if not table.isempty(data.add) then
        object_data:AddBuffList(data.add)
    end

    if not table.isempty(data.chg) then
        object_data:ChangeBuffList(data.chg)
    end
end

--冲刺
function SceneControler:RequestSceneRush(x, y)
    local pb = self:GetPbObject("m_scene_rush_tos")
    pb.coord.x = x
    pb.coord.y = y
    self:WriteMsg(proto.SCENE_RUSH, pb)
end

function SceneControler:HandleSceneRush()
    local data = self:ReadMsg("m_scene_rush_toc")
    local scene_data = SceneManager:GetInstance():GetSceneInfo()
    local callback
    local object = SceneManager:GetInstance():GetObject(data.uid)
    if data.uid == RoleInfoModel:GetInstance():GetMainRoleId() then
        object:SetLastSynchronousePos(data.coord)
        if not ArenaModel:GetInstance():IsArenaFight(scene_data.scene) then
            return
        else
            callback = function()
                local function step()
                    AutoFightManager:GetInstance():StartAutoFight()
                end
                GlobalSchedule:StartOnce(step, 0.2)
            end
        end
    end
    if object then
        object:PlayRush(data.coord, callback)
    end
end

--jump
function SceneControler:RequestSceneJump(start, dest, jump_type)
    local pb = self:GetPbObject("m_scene_jump_tos")
    pb.start.x = start.x
    pb.start.y = start.y
    pb.dest.x = dest.x
    pb.dest.y = dest.y
    pb.type = jump_type
    self:WriteMsg(proto.SCENE_JUMP, pb)
end

function SceneControler:HandleSceneJump()
    local data = self:ReadMsg("m_scene_jump_toc")
    local object = SceneManager:GetInstance():GetObject(data.uid)
    if object and data.uid == RoleInfoModel:GetInstance():GetMainRoleId() then
        object:SetLastSynchronousePos(data.dest)
        return
    end
    if object then
        object:PlayJump(data.dest, data.type)
    end
end

function SceneControler:RequestSceneTalk(npc_id, task_id)
    local pb = self:GetPbObject("m_scene_talk_tos")
    pb.npc_id = npc_id
    pb.task_id = task_id or 0
    Yzprint('--LaoY SceneControler.lua,line 294-- data=', proto.SCENE_TALK, npc_id)
    self:WriteMsg(proto.SCENE_TALK, pb)
end

function SceneControler:HandleSceneTalk()
    local data = self:ReadMsg("m_scene_talk_toc")
end

function SceneControler:HandleSceneDrop()
    -- Yzprint('--LaoY SceneControler.lua,line 292-- data=',data)
    local pb = self:ReadMsg("m_scene_drop_toc")
    local drops = pb.drops
    local main_role = SceneManager:GetInstance():GetMainRole()
    local main_pos = main_role:GetPosition()
    local pos = { x = main_pos.x, y = main_pos.y }
    local cur_ms_time = os.clock()
    for k, message in pairs(drops) do
        -- local param = {}
        -- param.id = v.id
        -- param.num = v.num
        -- param.coord = v.coord
        -- GlobalEvent:Brocast(FightEvent.AccPickUp,param)
        local drop_data = DropData:create(message)
        local uid = string.format("%s_%s_%s", cur_ms_time, message.id, k)
        drop_data.uid = uid
        -- drop_data.drop_type = 2
        drop_data.type = enum.ACTOR_TYPE.ACTOR_TYPE_DROP
        self.mgr:SetObjectInfo(drop_data)
        self.mgr:AddObject(uid)
    end
end

function SceneControler:HandleActorHpUpdate()
    local data = self:ReadMsg("m_actor_updatehp_toc");
    local uid = data.uid;--uid
    local hp = data.hp;--当前血量
    local hpmax = data.hpmax;--最大血量

    BrocastModelEvent(SceneEvent.UPDATE_ACTOR_HP, nil, data);
end

-- 技能回血，扣血等
function SceneControler:HandleActorHeal()
    local data = self:ReadMsg("m_actor_heal_toc")

    local object = self.mgr:GetObject(data.uid)
    if object then
        object:SetHp(data.hp)
        Yzprint('--LaoY SceneControler.lua,line 545--', object.object_info and object.object_info.name, data.hp, data.heal, data.type)
    end

    if data.type == enum.HEAL_TYPE.HEAL_TYPE_BLEED then
        FightManager:GetInstance():AddHeal(data.uid, data.heal,enum.DAMAGE.DAMAGE_BLEED)
    end
    if data.uid == RoleInfoModel:GetInstance():GetMainRoleId() then
        if data.type == enum.HEAL_TYPE.HEAL_TYPE_SKILL then
            FightManager:GetInstance():AddHeal(data.uid, data.heal)
        end
    end
end

function SceneControler:RequestAddBuff(id, uid)
    local pb = self:GetPbObject("m_actor_add_buff_tos")
    pb.id = id
    if uid then
        pb.uid = uid
    end
    self:WriteMsg(proto.ACTOR_ADD_BUFF,pb)
end

-- function SceneControler:HandleAddBuff()
--     local data = self:ReadMsg("m_actor_add_buff_toc")
-- end

function SceneControler:RequestDelBuff(id, uid)
    local pb = self:GetPbObject("m_actor_del_buff_tos")
    pb.id = id
    if uid then
        pb.uid = uid
    end
    self:WriteMsg(proto.ACTOR_DEL_BUFF,pb)
end
-- function SceneControler:HandleDelBuff()
--     local data = self:ReadMsg("m_actor_del_buff_toc")
-- end