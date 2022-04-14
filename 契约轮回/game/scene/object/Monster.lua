-- 
-- @Author: LaoY
-- @Date:   2018-08-01 20:15:09
-- 

Monster = Monster or class("Monster", SceneObject)

function Monster:ctor()
    self.default_res = self._default_res

    self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_CREEP
    self.body_size = { width = 90, height = 160, length = 90 }
    self:InitMachine()
    self.move_speed = self.object_info.speed
    self.idle_action_time = 0

    local config = Config.db_creep[self.object_info.id];

    Yzprint('--LaoY Monster.lua,line 18--', self.object_info.name, self.object_info.id, self.object_id)
    if self.object_info and self.object_info.name and self.object_info then
        if AppConfig.Debug then
            --@ling注: 墓碑直接由服务端生成等级
            if config.kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
                self.name_container:SetName(self.object_info.name .. self.object_id);
            else
                self.name_container:SetName(string.format(ConfigLanguage.Common.Level, self.object_info.level) .. " " .. self.object_info.name .. self.object_id);
            end
        else
            if config.kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
                self.name_container:SetName(self.object_info.name);
            else
                self.name_container:SetName(string.format(ConfigLanguage.Common.Level, self.object_info.level) .. " " .. self.object_info.name);
            end
        end
        -- self.name_container:SetName(self.object_info.uid .. self.object_info.name .. "_Lv." .. config.level);
    end

    self.config = config
    if config then
        self.creep_kind = config.kind
        self.body_size.volume = config.volume

        if self.object_info and self.object_info["ext"] and self.object_info["ext"]["boss_reborn"] and self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
            local time = self.object_info["ext"]["boss_reborn"];
            self.name_container:StartCountDown(time);
        end
        --print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        --print2(Table2String(self.object_info["ext"]));
        if self.object_info and self.object_info["ext"] and self.object_info["ext"]["disappear"] then
            self.name_container:StartBoom(self.object_info["ext"]["disappear"]);
        end
        --蛮荒boss和时空裂缝特有怒气值
        local scene_id = SceneManager.GetInstance():GetSceneId()
        local is_spacetimecrack = false
        if scene_id then
            local scene_cfg = Config.db_scene[scene_id]
            if scene_cfg then
                is_spacetimecrack = scene_cfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE
            end
        end
        
        if config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or is_spacetimecrack then
            if tonumber(config.opts) ~= 0 and tonumber(config.opts) ~= nil then
                self.name_container:ShowAngry(true);
                self.name_container:SetAngryNum(tonumber(config.opts));
            end
        end

        if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
            --dump(self.object_info,"tab")
            self.object_info.dir = 0
        end
    end
    self:ChangeBody()

    if self.creep_kind ~= enum.CREEP_KIND.CREEP_KIND_TOMB and self.config.rarity ~= enum.CREEP_RARITY.CREEP_RARITY_BOMB then
        self.name_container:SetVisible(false);
    end

    if self.config and (self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2) then
        if self.shadow_image then
            self.shadow_image:SetScale(300)
        end
    end
    -- if self.object_info and self.object_info.name then
    --     self.parent_node.name = self.object_info.name
    -- end

    --if self.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE and self.object_info.ext then
    --    if self.object_info.ext["boss_belong"] then
    --        self.name_container.ShowBelong(true);
    --    end
    --end

    Yzprint('--LaoY Monster.lua,line 72--', self.object_info.coord.x, self.object_info.coord.y, self.object_info.dest.x, self.object_info.dest.y)
end

-- 需要影子派生类的重写
function Monster:CreateShadowImage()
    local config = Config.db_creep[self.object_info.id]
    if not config and AppConfig.Debug then
        logError("creep config is nil , the id is ", self.object_info.id)
    end
    if config.is_shadow == 1 then
        self.shadow_image = ShadowImage()
    end
end

function Monster:dctor()
    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end
    if self:IsGM() then
        local actor = clone(self.object_info)
        local time_id
        local function step()
            if actor then
                actor:clear()
                SceneManager:GetInstance():SetObjectInfo(actor)
                SceneManager:GetInstance():AddObject(actor.uid)
            end
            actor = nil
            -- if time_id then
            -- 	GlobalSchedule:Stop(time_id)
            -- 	time_id = nil
            -- end
        end
        time_id = GlobalSchedule:StartOnce(step, 0.02)
    end
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    self.schedule = nil;
    --if self.preRoleBelong and self.preRoleBelong.name_container then
    --    self.preRoleBelong.name_container:ShowBelong(false);
    --end
    --self.preRoleBelong = nil;
    self:ClearBelong();
    self.preRoleBelong = nil;

    self:RemoveCollectEffect()
    -- Yzprint('--LaoY Monster.lua,line 113--',self.object_info.name,self.object_info.id,self.object_id)
    -- traceback()

    if self.hit_fresnel_mat then
        self:SetFresnelColor(nil,nil,0)
        -- destroy(self.hit_fresnel_mat)
    end
    self.hit_fresnel_mat = nil
end

function Monster:BeforeDestroyGameobject()
    if self.render_materials then
        for mat,v in pairs(self.render_materials) do
            destroy(mat)
        end
        self.render_materials = nil
    end
    Monster.super.BeforeDestroyGameobject(self)
end

--用于缓存
function Monster:Reset()
end

function Monster:AddEvent()
    self:UpdateBlood(self.object_info.hp)
    local function call_back()
        self:UpdateBlood(self.object_info.hp)
    end
    self.object_info:BindData("hp", call_back)

    self.global_event_list = self.global_event_list or {}
    local function call_back()
        if self.position then
            self:SetPosition(self.position.x,self.position.y)
        end
    end
    self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function Monster:ChangeBody()
    local config = self.config
    local res_id = config and config.figure or "model_monster_1001001"
    local abName = res_id
    if AppConfig.IsSupportGPU and self.config.GPU_res == 1 then
        abName = abName .. "_gpu"
        -- Yzprint('--LaoY Monster.lua,line 108--', data)
    end
    local assetName = abName

    local scene_type = self.config and SceneConfigManager:GetInstance():GetSceneType(self.config.scene_id)
    if self.config and (self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2) then
        poolMgr:AddConfig(abName, assetName, 1, Constant.InPoolTime, true)
    elseif self.config and (scene_type == SceneConstant.SceneType.Feild or scene_type == SceneConstant.SceneType.City) then
        local scene_cf = SceneConfigManager:GetInstance():GetSceneConfig(self.config.scene_id)
        local monster_scene_cf = scene_cf.Monsters[self.object_info.id]
        if monster_scene_cf then
            -- 场景种了多少怪就缓存多少只
            -- local num = math.ceil(#monster_scene_cf.pos_list/2)
            local num = #monster_scene_cf.pos_list
            -- poolMgr:AddConfig(abName, assetName, num, Constant.InPoolTime, true)
        end
        poolMgr:AddConfig(abName, assetName, 2, Constant.InPoolTime * 0.5, true)
    else
        -- 其他副本怪物缓存问题
        poolMgr:AddConfig(abName, assetName, 2, Constant.InPoolTime * 0.5, true)
    end

    self:CreateBodyModel(abName, assetName)
    -- if self:CreateBodyModel(abName, assetName) and self.default_res then
    --     SetVisible(self.default_res,true)
    -- end
end

function Monster:LoadBodyCallBack()
    -- if self.default_res then
    --     SetVisible(self.default_res,false)
    -- end
    if self.config.height ~= 0 then
        self.body_size.height = self.config.height
    end

    if self.config.scale ~= 1 then
        self.body_size.width = self.body_size.width * self.config.scale
        self.body_size.height = self.body_size.height * self.config.scale
        self.body_size.length = self.body_size.length * self.config.scale

        self:SetScale(self.config.scale)

        self:SetPosition(self.position.x, self.position.y)
    end

    if self.config.wait_direct ~= 0 then
        self:SetRotateY(self.config.wait_direct)
    end

    if self.object_info:IsFission() then
        self:StartFountain()
    end

    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
        self:LoadCollectEffect()
    end

    if self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or
            self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 or
            self.config.rarity == enum.CREEP_RARITY.CREEP_GUILD_BOSS then
        self:SetTargetEffect("effect_guaiwuchusheng_daguai_zise", false)
    end
end

function Monster:LoadCollectEffect()
    if not self.collect_effect then
        self.collect_effect = self:SetTargetEffect("effect_shiquwupin", true)
    end
end

function Monster:RemoveCollectEffect()
    if self.collect_effect then
        self.collect_effect:destroy()
        self.collect_effect = nil
    end
end

function Monster:StartFountain()
    self:StopFountain()
    local pos = self.object_info:GetFissionPos()
    local start_pos = pos
    self:SetPosition(start_pos.x, start_pos.y)
    local end_pos = Vector2(self.object_info.coord.x, self.object_info.coord.y)
    local distance = Vector2.Distance(start_pos, end_pos)
    local radian = math.angle2radian(60)
    local cos = math.cos(radian)
    local dir = GetDirByVector(start_pos, end_pos, distance)
    local dis1 = distance * 0.1
    local dis2 = distance * 0.6
    local config = {
        control_1 = Vector2(start_pos.x + dir.x * dis1, start_pos.y + 350 + cos * (distance - dis1)),
        control_2 = Vector2(start_pos.x + dir.x * dis2, start_pos.y + 350 + cos * (distance - dis2)),
        end_pos = end_pos,
    }
    local time = 1.2
    local delay_rate = 0.2
    if delay_rate > 0.5 then
        delay_rate = 0.5
    end
    local action = cc.BezierTo(time, config)
    local rotate_action = cc.RotateTo(time * (1 - delay_rate * 2), { x = 360, y = 0, z = 0 }, self.parent_transform)
    rotate_action = cc.Sequence(cc.DelayTime(time * delay_rate), rotate_action, cc.DelayTime(time * delay_rate))
    action = cc.Spawn(action, rotate_action)
    action = cc.EaseInOut(action, 0.7)
    local function call_back()
        if self.is_dctored then
            return
        end
        self:StopFountain()
        self:SetPosition(self.position.x, self.position.y)
    end
    local call_action = cc.CallFunc(call_back)
    action = cc.Sequence(action, call_action)
    self.fountain_action = cc.ActionManager:GetInstance():addAction(action, self)
    self:ChangeToMachineDefalutState()
end

function Monster:StopFountain()
    if self.fountain_action then
        cc.ActionManager:GetInstance():removeAction(self.fountain_action)
        self.fountain_action = nil
    end
end

function Monster:InitMachine()

    self:RegisterMachineState(SceneConstant.ActionName.idle, true);

    local run_func_list = {
        Update = handler(self, self.UpdateRunState),
    }
    self:RegisterMachineState(SceneConstant.ActionName.run, true, run_func_list)

    local attack_func_list = {
        OnEnter = handler(self, self.AttackOnEnter),
        OnExit = handler(self, self.AttackOnExit),
        CheckInFunc = handler(self, self.AttackCheckInFunc),
        CheckOutFunc = handler(self, self.AttackCheckOutFunc),
    }
    self:RegisterMachineState(SceneConstant.ActionName.attack, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack1, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack2, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack3, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack4, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.Bigger, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill1, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill2, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.show, false, attack_func_list)

    self:RegisterMachineState(SceneConstant.ActionName.casual, false)

    local death_func_list = {
        OnEnter = handler(self, self.DeathOnEnter),
        OnExit = handler(self, self.DeathOnExit),
    }
    self:RegisterMachineState(SceneConstant.ActionName.death, false, death_func_list)

    self:RegisterMachineState(SceneConstant.ActionName.hited, false)
end

function Monster:ChangeMachineState(state_name, force)
    if self.fountain_action and state_name ~= SceneConstant.ActionName.death then
        return false
    end
    return Monster.super.ChangeMachineState(self, state_name, force)
end

function Monster:SetNameColor()
    self.name_container:SetColor(Color(253, 237, 103), Color(6, 0, 1))
    -- self.name_container:SetColor(Color.green, Color.black)
end
function Monster:UpdateBlood(hp)
    self.name_container:UpdateBlood(hp, self.object_info.hpmax)
end
function Monster:BeLock(flag)
    Monster.super.BeLock(self, flag);
    self.name_container:SetVisible(flag)
    if self.creep_kind ~= enum.CREEP_KIND.CREEP_KIND_COLLECT and self.config.rarity ~= enum.CREEP_RARITY.CREEP_RARITY_BOSS and self.config.rarity ~= enum.CREEP_RARITY.CREEP_RARITY_BOSS2 then
        self.name_container:ShowBlood(flag);
    else
        self.name_container:ShowBlood(false);
    end
    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
        self.name_container:ShowBlood(false);
        --self.name_container:ShowName(false);
    end
    --if self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or 
       --self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS3 then
        BrocastModelEvent(EventName.MONSTER_BE_LOCK, nil, self, flag);
    --end
end

function Monster:LoopActionOnceEnd()
    if self.cur_state_name == SceneConstant.ActionName.idle then
        local action = self.action_list[self.cur_state_name]
        if action.total_time >= 30 then
            -- self:ChangeMachineState(SceneConstant.ActionName.casual)
        end
    end
end

function Monster:PlayHit()
    if self:IsBoss() then
        return
    end
    if self:ChangeMachineState(SceneConstant.ActionName.hited) then
        return false
    end
end

function Monster:DeathOnExit()
    if self.config.id == 20702014 or self.config.id ==  20702015 then
        if self.animator then
            self.animator.speed = 0
        end
        return
    end
    Monster.super.DeathOnExit(self)
    self:destroy()
end

---当在公会战时，检测已水晶点击
function Monster:GuildBattleCheck()

    local config = Config.db_scene[SceneManager:GetInstance():GetSceneId()]

    if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR then
        return FactionBattleModel.GetInstance():IsSelfSideCrystal(self.object_info.id)
    end

    return false
end

function Monster:OnClick()

    if (self:IsDeath() and self.config.rarity ~= enum.CREEP_RARITY.CREEP_RARITY_COLL2) or self:GuildBattleCheck() then
        return
    end
    local config = Config.db_creep[self.object_info.id]
    if self.creep_kind and (self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT or self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB) then
        if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
            local scene_id = SceneManager:GetInstance():GetSceneId()
            local scenecfg = Config.db_scene[scene_id]
            if scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_TIMEBOSS then
                GlobalEvent:Brocast(TimeBossEvent.OpenBoxPanel)
            elseif scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR and self.object_info.id == 1099998 then
                GlobalEvent:Brocast(SiegewarEvent.OpenBoxPanel, self.object_info.uid)
            end
        end
        if self.is_collecting or self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
            return
        end
        if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT and not self:IsCanBeCollect() then
            return
        end
        local main_role = SceneManager:GetInstance():GetMainRole()
        local main_pos = main_role:GetPosition()
        local distance = Vector2.DistanceNotSqrt(main_pos, self.position)
        local range_square = SceneConstant.PickUpDis * SceneConstant.PickUpDis
        if distance <= range_square then
            -- self.is_collecting = true
            -- FightManager:GetInstance():DoCollect(main_role, self)
            GlobalEvent:Brocast(FightEvent.ReqCollect, self.object_info.uid, 1)
        else
            -- Notify.ShowText(self.object_info.name,self.object_info.uid,"采集距离不够")
            local function call_back()
                if self.is_dctored then
                    return
                end
                self:OnClick()
            end
            -- local move_dis = math.max(math.sqrt(distance) - SceneConstant.PickUpDis - 1, 0)
            -- local end_pos = GetDirDistancePostion(main_pos, self.position, move_dis)
            OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, self.position, call_back, SceneConstant.PickUpDis)
        end
    else

        -- Notify.ShowText(self.object_info.name, self.object_info.uid, "想打架吗？")

        -- 同组的直接显示选中特效
        if SceneManager:GetInstance():IsSameGroup(self.object_info.group) then
            SceneManager:GetInstance():LockNpc(self.object_id)
        else
            SceneManager:GetInstance():OnClickAttackObject(self.object_info.uid)
        end
    end
    return true
end

function Monster:Update(delta_time)
    Monster.super.Update(self, delta_time)
end

function Monster:CheckServerPosition(delta_time)
    if not self.is_loaded then
        Monster.super.CheckServerPosition(self, delta_time)
        return
    end
    local dis = Vector2.DistanceNotSqrt(self.server_pos, self.position)
    if dis < 1 or
            (self:IsRunning() and self.move_pos and Vector2.DistanceNotSqrt(self.move_pos, self.server_pos) < 1) then
        return
    end
    if self:IsAttacking() then
        return
    end
    -- if self.object_id == "2004914" then
    --     Yzprint('--LaoY Monster.lua,line 394--',Vector2.DistanceNotSqrt(self.server_pos,self.position),self:IsRunning(),self.move_pos and Vector2.DistanceNotSqrt(self.move_pos,self.position))
    -- end
    if dis <= self.move_speed * 0.08 * self.move_speed * 0.08 then
        self:SetPosition(self.server_pos.x, self.server_pos.y)
    else
        self:SetMovePosition(self.server_pos)
    end
end

function Monster:SetPosition(x, y)
    -- Monster.super.SetPosition(self,x,y)
    -- local block_x,block_y = SceneManager:GetInstance():GetBlockPos(x,y)
    -- if self.block_pos.x ~= block_x or self.block_pos.y ~= block_y then
    -- 	local block_value = MapManager:GetInstance():GetMask(block_x,block_y)
    -- 	if not BitState.StaticContain(block_value) and not self:IsCorssBlock() then
    -- 		return
    -- 	end
    -- 	self.block_pos.x = block_x
    -- 	self.block_pos.y = block_y
    -- 	self.block_info:SetValue(block_value)
    -- end

    self.position.x = x
    self.position.y = y
    if self.fountain_action then
        -- self.position.z = self:GetDepth(self.object_info.coord.y)
        self.position.z = self:GetDepth(0)
    else
        self.position.z = self:GetDepth(y)
    end
    -- if self.is_loaded then
    local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
    SetGlobalPosition(self.parent_transform, world_pos.x, world_pos.y, self.position.z)
    self:SetNameContainerPos()
    self:SetAdvanceItemPos();
    self:SetShadowImagePos()
    -- end
end

function Monster:PlayDeath(attack_object,other_damage)
    if not self.is_loaded then
        self:destroy()
        return
    end
    if self.is_death then
        return
    end
    self.is_death = true
    local function call_back()
        if self.is_dctored then
            return
        end

        if self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or
                self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 or
                self.config.rarity == enum.CREEP_RARITY.CREEP_GUILD_BOSS then
            SoundManager:GetInstance():PlayById(44)
        end
        
        self.is_death = false
        self:SetHp(0)
        self:ChangeMachineState(SceneConstant.ActionName.death, true)
    end
    -- enum.CREEP_KIND.CREEP_KIND_COLLECT

    if not attack_object or attack_object == SceneManager:GetInstance():GetMainRole() then
        GlobalEvent:Brocast(SceneEvent.KILL_MONSTER)
    end
        
    local is_bomb = self.object_info.id == 1100004
    if is_bomb or ( other_damage and (self.object_info.id == 6000902 or self.object_info.id == 6000903) ) then
        call_back()
        EffectManager:GetInstance():PlayPositionEffect("effect_zadanguai_baozha", self.position)
    elseif self.config and self.config.repel > 0 and attack_object then
        local vec = GetDirByVector(attack_object:GetPosition(), self.position)
        vec:Mul(280)
        local end_pos = { x = self.position.x + vec.x, y = self.position.y + vec.y }
        end_pos = Vector3(end_pos.x, end_pos.y, self.position.z)
        self:PlaySlip(end_pos, self.config.repel, call_back, 1, 8)
    else
        call_back()
    end
end

--给击退
function Monster:BeRepel(attack_object, distance, time, rate_type, rate)
    if not time or time <= 0 then
        return
    end
    if self.config and self.config.repel > 0 and attack_object then
        local vec = GetDirByVector(attack_object:GetPosition(), self.position)
        vec:Mul(distance)
        local speed = distance / time
        local end_pos = { x = self.position.x + vec.x, y = self.position.y + vec.y }
        end_pos = Vector3(end_pos.x, end_pos.y, self.position.z)
        self:PlaySlip(end_pos, speed, nil, rate_type, rate)
    end
end

--[[
@author LaoY
@des 	同步服务器坐标
--]]
function Monster:SetServerPosition(pos, dir, state)
    local distance = Vector2.Distance(pos, self.position)
    if distance <= self.move_speed * 0.05 then
        self:SetPosition(pos.x, pos.y)

        self:SetServerPosInfo(pos, state)
        return
    end

    Monster.super.SetServerPosition(self, pos, nil, state)
    -- self:SetMovePosition(pos, dir)
end

----检测人物是否在范围内
--function Monster:HandleGuard(state_name, delta_time)
--    local config = Config.db_creep[self.object_info.id];
--    local bossConfig = Config.db_boss[self.object_info.id];
--    if config and self.object_info and bossConfig then
--        local coord = String2Table(bossConfig.coord);
--        coord = { x = coord[1], y = coord[2] };
--        local main_role = SceneManager:GetInstance():GetMainRole();
--        if main_role then
--            local main_role_data = main_role.object_info;
--            --if Vector2.Distance()
--            if Vector2.Distance(main_role_data.coord, coord) < config.guard then
--                GlobalEvent.BrocastEvent(DungeonEvent.SHOW_BOSS_BLOOD, self.object_info);
--            end
--        end
--
--        if self.object_info["ext"] and (self.object_info["ext"]["belong_role"] or self.object_info["belong_role"]) then
--            local belong_role = self.object_info["ext"]["belong_role"];
--            if belong_role == "0" or belong_role == nil then
--                belong_role = self.object_info["belong_role"]
--            end
--            local role = SceneManager:GetInstance():GetObject(belong_role);
--            local role_info = SceneManager:GetInstance():GetObjectInfo(belong_role);
--
--            if self.preRoleBelong and self.preRoleBelong.object_info then
--                if role_info and self.preRoleBelong.object_info.id == role_info.id then
--
--                else
--                    if self.preRoleBelong.name_container then
--                        self.preRoleBelong.name_container:ShowBelong(false);
--                    end
--                end
--            end
--
--            if role_info and role then
--                local isInGuard = Vector2.Distance(role.position, coord) < config.guard;
--                role.name_container:ShowBelong(isInGuard);
--                --role.name_container:SetName(self.object_info.uid .. self.object_info.name .. Table2String(role_info.coord));
--                self.preRoleBelong = role;
--            end
--            GlobalEvent.BrocastEvent(SceneEvent.MONSTER_BELONG_CHANGE, role_info);
--        end
--    elseif config and self.object_info and self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 then
--        local coord = self.object_info.coord;
--        local main_role = SceneManager:GetInstance():GetMainRole();
--        if main_role then
--            local main_role_data = main_role.object_info;
--            --if Vector2.Distance()
--            if Vector2.Distance(main_role_data.coord, coord) < config.guard then
--                GlobalEvent.BrocastEvent(DungeonEvent.SHOW_BOSS_BLOOD, self.object_info);
--            end
--            if self.object_info.hp <= 0 then
--                StopSchedule(self.schedule);
--            end
--        end
--    end
--end

function Monster:GetLockEffectName()
    if SceneManager:GetInstance():IsSameGroup(self.object_info.group) then
        return "effect_xuanzhong_npc"
    end
    if self:IsBoss() then
        return "effect_xuanzhong_boss"
    else
        return "effect_xuanzhong_xiaoguai"
    end
end

function Monster:GetDepth(y)
    --logError("self.is_in_pickuping------>" .. tostring(self.is_in_pickuping))
    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
        y = MapManager:GetInstance().map_pixels_height
    elseif self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
        y = MapManager:GetInstance().map_pixels_height + 100
    end
    return LayerManager:GetInstance():GetSceneObjectDepth(y or 0)
end

-- local last_rotateY = 0
-- function Monster:SetRotateY(rotateY, vec, is_rotating, is_transition)
--     if not is_transition then
--         Yzprint('--LaoY Monster.lua,line 562--',rotateY, vec, is_rotating, is_transition)
--         traceback()
--     else
--         if rotateY - last_rotateY > 40 then 
--             Yzprint('--LaoY Monster.lua,line 567--',rotateY, vec, is_rotating, is_transition)
--             Yzprint('--LaoY Monster.lua,line 570--',rotateY,last_rotateY,Vector2.Distance(self.server_pos,self.position),self.server_pos.x,self.server_pos.y,self.position.x,self.position.y)
--             traceback()
--         end
--         last_rotateY = rotateY
--     end
--     Monster.super.SetRotateY(self,rotateY, vec, is_rotating, is_transition)
-- end

-- function Monster:CheckInBound(x, y)
--     if IgnoreClickObject[self.object_info.id] then
--         return false
--     end
--     return Monster.super.CheckInBound(self,x, y)
-- end


function Monster:IsCanBeAttack()
    -- if self:IsInSafe() then
    --        return false
    --    end

    if SceneManager:GetInstance():IsSameGroup(self.object_info.group) or
            self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT or self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
        return false
    end
    return true
end

function Monster:AutoSelect()
    if SceneManager:GetInstance():IsSameGroup(self.object_info.group) then
        return false
    end
    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB then
        return false
    end
    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
        return self:IsCanBeCollect()
    end
    return true
end

function Monster:IsCanBeCollect()
    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
        local picktype = self.config.picktype
        if string.isempty(picktype) then
            return true
        end
        local task_id = tonumber(picktype)
        local info = TaskModel:GetInstance():GetTask(task_id)
        return info ~= nil
    end
    return true
end

function Monster:IsGM()
    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
    return self.object_info.id == 1100101 and lv and lv <= 5
end

function Monster:AddBelong(role, bool)
    bool = toBool(bool);
    if not self.preRoleBelong then
        self.preRoleBelong = {};
    end
    if not table.indexof(self.preRoleBelong, role) then
        if bool then
            table.insert(self.preRoleBelong, role);
        end
    else
        if not bool then
            table.removebyvalue(self.preRoleBelong, role);
        end
    end
end

function Monster:ClearBelong()
    if self.preRoleBelong then
        for k, role in pairs(self.preRoleBelong) do
            if not role.is_dctored and role.is_loaded and role.name_container then
                role.name_container:ShowBelong(false);
            end
        end
    end
    self.preRoleBelong = {};
end

function Monster:OnExitMachineState(state_name,last_state_name)
    Monster.super.OnExitMachineState(self, state_name,last_state_name)
    if self:IsCanInterruption() then
        FightManager:GetInstance():CheckWaitAttack(self.object_id)
    end
end

function Monster:BeHit(color, scale, value, time)
    if not self.gameObject then
        return
    end
    if self.last_shadow_state then
        return
    end
    self:StopBeHitTime()
    scale = scale or 0
    value = value or 0
    self:SetFresnelColor(color, scale, value)
    if value == 0 or not time or time == 0 then
        return
    end
    local function step()
        self:SetFresnelColor(color, 0, 0)
    end
    -- time = 10
    self.be_hit_time_id = GlobalSchedule:StartOnce(step, time)
end

function Monster:SetFresnelColor(color, scale, value)
    -- do
    --     return
    -- end
    self:InitHitFresnel()
     scale = scale or 0
     value = value or 0
     color = color or { 255, 255, 255, 255 }
     -- color = Color(unpack(color))
     local a = color[4]
     if value == 0 then
        a = 0
     end

     SetMaterialColor(self.hit_fresnel_mat,"_TintColor",color[1],color[2],color[3],a)

     -- self.hit_fresnel_mat:SetColor("_TintColor",Color(color[1]/255,color[2]/255,color[3]/255,a/255))
     -- self.hit_fresnel_mat:SetFloat("_FresnelBias",value)
     -- SetMaterialFloat(self.hit_fresnel_mat,"_FresnelScale",scale)
     -- SetMaterialFloat(self.hit_fresnel_mat,"_FresnelBias",value)
end

function Monster:InitHitFresnel()
    if self.hit_fresnel_mat then
        return
    end
    self.render_materials = {}
    if self.gameObject then
        local renders = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer))
        local len = renders.Length
        for j = 0, len - 1 do
            local mats = renders[j].materials
            local need_load_mat = true
            local _mats = {}
            local isModel = false
			local matLen = mats.Length
            for i = 0, matLen - 1 do
                local mat = mats[i]
                self.render_materials[mat] = true
                _mats[i + 1] = mat
                local name = mat.name
                -- if name:find("model_") or (not string.find(name, ShaderManager.FresnelMatName) and matLen == 1) then
                if name:find("model_") then
                    isModel = true
                end
                if not self.hit_fresnel_mat and string.find(name, ShaderManager.FresnelMatName) then
                    self.hit_fresnel_mat = mat
                    need_load_mat = false
                    break
                end
            end
            if isModel and need_load_mat then
                local hit_mat = ShaderManager:GetInstance():GetFresnelMat()
                self.hit_fresnel_mat = hit_mat
                _mats[mats.Length + 1] = hit_mat
                self.render_materials[hit_mat] = true
                -- self.hit_fresnel_mat = _mats[1]
                -- self.hit_fresnel_mat.shader = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Outline2)
                renders[j].materials = _mats
            end
            if self.hit_fresnel_mat then
                break
            end
        end

        if self.hit_fresnel_mat then
            local function step()
                -- self.hit_fresnel_mat.shader = ShaderManager:GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Fresnel)
                
                SetMaterialFloat(self.hit_fresnel_mat,"_FresnelScale",1.96)
                SetMaterialFloat(self.hit_fresnel_mat,"_FresnelBias",3)
            end
            -- GlobalSchedule:StartOnce(step,2.0)   
            step()  
        end
        -- self:SetFresnelColor(0, true)
    end
end

function Monster:IsBoss()
    return self.config and (self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS 
        or self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 
        or self.config.rarity == enum.CREEP_RARITY.CREEP_GUILD_BOSS
        )
end

function Monster:PlayCollectSuccess()
    if self.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT then
        self:SetTargetEffect("effect_caijichenggong", false)
    end
end

function Monster:SetTransformLayer()
    if self.config.id == 20702014 or self.config.id ==  20702015 then
        return
    end
    Monster.super.SetTransformLayer(self)
end

function Monster:OnEnterMachineState(state_name)
    local action = self.action_list[state_name]
    if not action then
        logWarn((state_name or "") .. " is not Register !!!!!! cname = " .. self.__cname)
        if AppConfig.Debug then
            logError(string.format("action = %s,state_name = %s",tostring(action),tostring(state_name)))
        end
        return
    end
    -- self.animator:Play(state_name)

    local reset_time = 0.1
    if self.cur_state_name and self.action_list[state_name] then
        reset_time = action.reset_time
    end
    -- reset_time = 0.3
    -- self.animator:CrossFade(state_name,reset_time,0,0)
    if self.gpu_player ~= nil then
        self.gpu_player:Play(action.action_name)
    else
        if self.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_CGW_CRYSTAL and action.action_name == SceneConstant.ActionName.death  then
            self:destroy()
            return
        else
            self.animator:CrossFadeInFixedTime(action.action_name, reset_time)
        end

    end
    self.cur_state_name = state_name
    -- Yzprint('--LaoY SceneObject.lua,line 686-- data=',state_name)
    action.is_playing = true
    action.pass_time = 0
    action.loop_count = 0
    action.total_time = 0
    -- 用speed，每次时间必须重新拿
    -- self.animator.speed =  2

    if action.error_action_time then
        action.action_time = false
        action.error_action_time = false
    end

    if not action.action_time then
        -- 真正获取时间的方法
        -- 文件名必须是输出的动作名字
        if self.animator then
            action.action_time = GetClipLength(self.animator, action.action_name)
        else
            action.action_time = self.gpu_player:GetClipLength(action.action_name)
        end
        action.check_dynamic_time = false
        -- if state_name == SceneConstant.ActionName.collect2 then
        --     Yzprint('--LaoY ======>', state_name, action.action_name, action.action_time)
        -- end
        if action.action_time == 0 then
            -- 这个时间长度会受到speed影响
            -- local cur_state = self.animator:GetCurrentAnimatorStateInfo(0)
            -- action.action_time = cur_state.length
            -- 这个时间长度不会受到speed影响 因为动作融合，当前拿到的是上个动作时间
            -- 所以必须动态拿时间
            local count, ClipInfo
            if self.animator then
                count, ClipInfo = self.animator:GetCurrentAnimatorClipInfo(0)
                if count > 0 then
                    action.action_time = ClipInfo[0].clip.length
                end
            end

            -- Yzprint('--LaoY SceneObject.lua,line 882-- data=',state_name,action.action_time)
            if self.last_state_name and self.action_list[self.last_state_name] then
                logWarn("动作控制器不存在该动作：", state_name, ",使用的类为：", self.__cname, ",名字为：", self.object_info and self.object_info.name or "空")
                local last_action = self.action_list[self.last_state_name]
                local reset_time = last_action.action_time - last_action.pass_time % last_action.action_time
                reset_time = reset_time > 0 and reset_time or 0
                action.check_dynamic_time = action.action_time > reset_time and reset_time or action.reset_time

            end
            if action.action_time == 0 then
                action.action_time = 0.6
            end
        end
    end
    if action.action_time == nil or type(action.action_time) ~= "number" then
        if AppConfig.Debug then
            logError("动作不能获取时间：", state_name, ",使用的类为：", self.__cname, ",名字为：", self.object_info and self.object_info.name or "空",",action.action_time = ",tostring(action.action_time))
        else
            logWarn("动作不能获取时间：", state_name, ",使用的类为：", self.__cname, ",名字为：", self.object_info and self.object_info.name or "空",",action.action_time = ",tostring(action.action_time))
        end
        action.action_time = 1.0
    end
    if action.OnEnter then
        action.OnEnter(state_name)
    end

    local depend_object_list = self:GetDependObjectList()
    if not table.isempty(depend_object_list) then
        for actor_type,list in pairs(depend_object_list) do
            for index,depend_object in pairs(list) do
                depend_object:OwnerEnterState(state_name)
            end
        end
    end
end