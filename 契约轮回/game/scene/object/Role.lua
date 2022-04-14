-- 
-- @Author: LaoY
-- @Date:   2018-07-24 15:10:44
-- 角色类

Role = Role or class("Role", SceneObject)
local this = Role

function Role:ctor()
    --Yzprint('--LaoY Role.lua,line 10--', self.object_info.name, self.object_info.uid, RoleInfoModel:GetInstance():GetMainRoleId())
    -- traceback()

    self.default_res = self.parent_transform:Find("default")

    self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_ROLE

    self.body_size = { width = 90, height = 180 }

    self.load_level = Constant.LoadResLevel.Super

    -- 上次冲刺的时间 保证马上就能用
    self.last_rush_time = -SceneConstant.RushCD

    if self.object_info and self.object_info then
        self.move_speed = self.object_info.speed
    end

    self.jump_hand_effect = {}

    self.is_main_role = self.__cname == "MainRole"

    self:InitMachine()
    self:ChangeBody()

    if self.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE and self.object_info.ext then
        if self.object_info.ext["boss_belong"] then
            self.name_container.ShowBelong(true);
        end

        self:SetGuildWarTitle()
    end

    -- self:InitData(object_id)

    self:UpdateMachineArmorShield()

    self.ride_up_on_enter_callback  = nil  --上坐骑
    self.remove_mount_callback = nil  --下坐骑

end

function Role:dctor()

    if self.object_event_ids then
        self.object_info:RemoveTabListener(self.object_event_ids)
    end
    self.object_event_ids = {}

    self.horse_skin_renderer = nil
    if self.horse_mat then
        -- destroy(self.horse_mat)
        self.horse_mat = nil
    end

    if self.event_id_list then
        GlobalEvent:RemoveTabListener(self.event_id_list)
        self.event_id_list = {}
    end
    self:BeLock(false);

    -- 移除冲刺特效
    self:RemoveRushEffect()

    self:RemoveSwimEffect()
    self:RemoveJumpHandEffect(true)

end

-- 需要影子派生类的重写
function Role:CreateShadowImage()
    self.shadow_image = ShadowImage()
end

--用于缓存
function Role:Reset()

end

--增加事件侦听
function Role:AddEvent()
    Role.super.AddEvent(self)

    self.object_event_ids = {}

    local function call_back()
        self.move_speed = self.object_info.speed
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("speed", call_back)

    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("level", handler(self, self.UpdateTopLvShow))

    local function call_back(order)
        if not self.object_info.figure.mount or self.object_info.figure.mount.model == 0 or not self.object_info.figure.mount.show then
            if self:IsRiding() then
                self:PlayDismount(nil, force)
            else
                self:RemoveMount()
            end
        else
            if self:IsRiding() then
                self:LoadMount()
            else
                self:PlayMount()
            end
        end
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.mount", call_back)

    local function call_back()
        self:LoadTailsMan()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.talis", call_back)

    local function call_back()
        self:LoadPet()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.pet", call_back)

    --
    -- local function call_back()
    --     self:LoadGod()
    -- end
    -- self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.god", call_back)

    local function call_back()
        self:LoadWing()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.wing", call_back)

    local function call_back()
        self:LoadLHand()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.offhand", call_back)


    -- 下个版本再改
    local function call_back()
        self:LoadWeapon()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.weapon", call_back)

    local function call_back()
        self:SetJobTitle()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.jobtitle", call_back)

    local function call_back()
        self:SetTitle()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.title", call_back)

    local function call_back()
        self:ChangeBody()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.fashion_clothes", call_back)

    local function call_back()
        self:LoadHead()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.fashion_head", call_back)

    local function call_back()
        self:LoadFairy()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.baby", call_back)


    local function call_back()
        self:LoadMagicArray()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("figure.fashion_footprint", call_back)

    local function call_back()
        self:UpdateEscort()
        self:UpdateEffect()
        self:UpdateDance()
        self:ChangeBody()
        self:UpdateMachineArmorShield()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("buffs", call_back)

    local function call_back()
        --dump(self.object_info.ext.melee_score)
        self:SetMeleeScore()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("ext.melee_score", call_back)

    local function call_back()
        self:SetGuildWarTitle()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("group", call_back)

    local function call_back()
        --self:SetGuildWarTitle()
        self:SetMarryText()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("marry", call_back)

    local function call_back()
        --self:SetGuildWarTitle()
        self:SetMarryText()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("mname", call_back)

    local function call_back()
        self:SetGuildText()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("guild", call_back)

    local function call_back()
        self:SetGuildText()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("gname", call_back)

    local function call_back()
        self:SetReName()
    end
    self.object_event_ids[#self.object_event_ids + 1] = self.object_info:BindData("name", call_back)

    self.event_id_list = self.event_id_list or {}

    local function call_back(slot, data)
        if slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY or slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY2 then
            self:LoadFairy()
        end
    end
    self.event_id_list[#self.event_id_list + 1] = GlobalEvent:AddListener(EquipEvent.PutOnEquip, call_back)
    self.event_id_list[#self.event_id_list + 1] = GlobalEvent:AddListener(EquipEvent.PutOffEquip, call_back)

    local function change_scene_end_fly_down()
        self:ChangeSceneEndFlyDown()
    end
    local function call_back()
        -- 切换完场景，主角强制设置到服务端的目标点
        if self.is_main_role then
            -- self:ChangeToMachineDefalutState()
            local sceneMgr = SceneManager:GetInstance()
            self:SetPosition(sceneMgr.scene_info_data.actor.coord.x, sceneMgr.scene_info_data.actor.coord.y)
            -- if sceneMgr.scene_info_data.type == enum.SCENE_CHANGE.SCENE_CHANGE_SHOES then

            if not LoadingCtrl:GetInstance().loadingPanel then
                change_scene_end_fly_down()
            end

            local last_scene_id = SceneManager:GetInstance():GetLastSceneId()
            local last_scene_is_cross = SceneManager:GetInstance():IsCrossScene(last_scene_id)
            local cur_scene_is_cross = SceneManager:GetInstance():IsCrossScene()
            if not last_scene_id or last_scene_is_cross ~= cur_scene_is_cross then
                -- local name = self.object_info.name
                -- if cur_scene_is_cross and not self.is_main_role then
                --     name = string.format("s%s.%s", self.object_info.zoneid, name)
                -- end
                -- self.name_container:SetName(name)

                self:SetReName()
            end
        else
            self:SetPosition(self.object_info.coord.x, self.object_info.coord.y)
        end
        -- self:ChangeSceneCheckMount()
        self:LoadPet()
        self:SetNameColor()
    end
    self.event_id_list[#self.event_id_list + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

    local function call_back()
        if self.is_main_role then
            Yzprint('--LaoY Role.lua,line 181--', nil)
            change_scene_end_fly_down()
        end
    end
    self.event_id_list[#self.event_id_list + 1] = GlobalEvent:AddListener(EventName.DestroyLoading, call_back)

    --local function call_back(data)move_dircn
    --    if data.end_time ~= 0 then --护送进行中
    --
    --        self.name_container:SetEscortFlag(true,"ersort_flag1")
    --
    --    else
    --        self.name_container:SetEscortFlag(false,"ersort_flag1")
    --    end
    --end
    --self.event_id_list[#self.event_id_list + 1] = GlobalEvent:AddListener(FactionEscortEvent.FactionEscortInfo, call_back) --护送

end

function Role:ChangeSceneEndFlyDown()
    if self.is_loaded then
        local function callback()
            -- self:ChangeSceneCheckMount()
            local sceneMgr = SceneManager:GetInstance()
            local fly_call_back = sceneMgr:GetFlyCallBack()
            local function step()
                if fly_call_back then
                    fly_call_back()
                end
            end
            GlobalSchedule:StartOnce(step, 0.6)
        end
        self:PlayFlyDown(callback)
    end
end

function Role:InitData(uid)
    Role.super.InitData(self, uid)
    self:SetJobTitle()
    self:SetGuildText()
    self:SetMarryText()
    --self:SetTitle();

    if self.name_container and self.object_info and self.object_info.name then
        self:UpdateTopLvShow()
        -- local name = self.object_info.name
        -- if SceneManager:GetInstance():IsCrossScene() and not self.is_main_role then
        --     name = string.format("s%s.%s", self.object_info.zoneid, name)
        -- end
        -- self.name_container:SetName(name)
        self:SetReName()
    end
end

--更新巅峰等级显示
function Role:UpdateTopLvShow()
    local lv = self.object_info.level
    if not lv then
        return
    end
    local is_show_top_icon = false
    if lv > String2Table(Config.db_game.level_max.val)[1] then
        is_show_top_icon = true
    end
    self.name_container:UpdateTopLevelIconShow(is_show_top_icon)
end

function Role:SetReName()
    --logError("名字更新")
    if self.object_info then
        local name = self.object_info.name
        if SceneManager:GetInstance():IsCrossScene() and not self.is_main_role then
            local server_name = RoleInfoModel:GetInstance():GetServerName(self.object_info.suid)
            if server_name then
                name = string.format("%s.%s", server_name, name)
            end
        end
        self.name_container:SetName(name)
    end
end

function Role:SetMeleeScore()
    if self.object_info and self.object_info.ext and self.object_info.ext.melee_score then
        self.name_container:SetAthleticsScore(true, self.object_info.ext.melee_score)
    end
end

function Role:SetJobTitle()
    if self.object_info then
        local title_id = self.object_info.figure.jobtitle and self.object_info.figure.jobtitle.model
        local config = Config.db_jobtitle[title_id]
        if not config then
            return
        end
        local show = self.object_info.figure.jobtitle and self.object_info.figure.jobtitle.show;
        if show then
            self.name_container:SetJobTitle(config.name)
            self.name_container:SetJobTitleOutLine(config.color)
        else
            self.name_container:SetJobTitle("")
        end
    end
end

function Role:SetGuildWarTitle()
    if self.object_info then
        local config = Config.db_scene[SceneManager:GetInstance():GetSceneId()]
        if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and (config.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR or config.stype == enum.SCENE_STYPE.SCENE_STYPE_CROSS_GUILDWAR)then
            self.name_container:ShowGuildWar(true, self.object_info.group, self.object_info.gname)
        else
            self.name_container:ShowGuildWar(false)
        end
    end
end

function Role:SetTitle()
    if self.object_info then
        local title_id = self.object_info.figure.title and self.object_info.figure.title.model or 0;
        local show = self.object_info.figure.title and self.object_info.figure.title.show;
        if show then
            self.name_container:ShowTitle(title_id)
        else
            self.name_container:ShowTitle(0);
        end

    end
end

--设置公会信息
function Role:SetGuildText()
    if self.object_info then
        --print2(self.object_info.guild)
        if self.object_info.guild == "0" or self.object_info.guild == 0 then
            self.name_container:ShowGuildName(false)
            return
        end
        self.name_container:ShowGuildName(true, "[Guild] " .. self.object_info.gname)
        --if self.object_info.guild ~= "0" then
        --    --有公会
        --    self.name_container:ShowGuildName(true, "[公]" .. self.object_info.gname)
        --else
        --    print2("隱藏")
        --    self.name_container:ShowGuildName(false)
        --end
    end
end
--设置结婚信息
function Role:SetMarryText()
    if self.object_info then
        if self.object_info.marry ~= 0 then
            local str = self.object_info.mname .. "X's Wife"
            if self.object_info.gender == 1 then
                str = self.object_info.mname .. "X's husband"
            end
            self.name_container:ShowMarryName(true, str)
        else
            self.name_container:ShowMarryName(false)
        end
    end
end





function Role:InitMachine()
    local idle_func_list = {
        OnEnter = handler(self, self.IdleOnEnter),
        -- CheckInFunc = handler(self,self.IsCanSwitchToMove),
    }
    self:RegisterMachineState(SceneConstant.ActionName.idle, true, idle_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.ride, true, idle_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.idle2, true, idle_func_list)

    local run_func_list = {
        OnEnter = handler(self, self.RunOnEnter),
        OnExit = handler(self, self.RunOnExit),
        Update = handler(self, self.UpdateRunState),
        -- CheckInFunc = handler(self,self.IsCanSwitchToMove),
    }
    self:RegisterMachineState(SceneConstant.ActionName.run, true, run_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.riderun, true, run_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.run2, true, run_func_list)

    local attack_func_list = {
        OnEnter = handler(self, self.AttackOnEnter),
        OnExit = handler(self, self.AttackOnExit),
        Update = handler(self, self.UpdateAttack),
        CheckInFunc = handler(self, self.AttackCheckInFunc),
        CheckOutFunc = handler(self, self.AttackCheckOutFunc),
    }
    self:RegisterMachineState(SceneConstant.ActionName.attack, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack1, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack2, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack3, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.attack4, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill1, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill2, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill3, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill4, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill5, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill6, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill7, false, attack_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.skill8, false, attack_func_list)

    local rush_func_list = {
        OnEnter = handler(self, self.RushOnEnter),
        Update = handler(self, self.UpdateRushState),
        OnExit = handler(self, self.RushOnExit),
        CheckOutFunc = handler(self, self.RushCheckOutFunc)
    }
    self:RegisterMachineState(SceneConstant.ActionName.rush, false, rush_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.rush2, false, rush_func_list)

    local death_func_list = {
        OnEnter = handler(self, self.DeathOnEnter),
        OnExit = handler(self, self.DeathOnExit),
    }
    self:RegisterMachineState(SceneConstant.ActionName.death, false, death_func_list)

    local collect_func_list = {
        OnEnter = handler(self, self.CollectOnEnter),
        OnExit = handler(self, self.CollectOnExit),
        Update = handler(self, self.CollectUpdate),
    }
    self:RegisterMachineState(SceneConstant.ActionName.collect, true, collect_func_list, nil)
    self:RegisterMachineState(SceneConstant.ActionName.collect2, true, collect_func_list, nil, SceneConstant.ActionName.idle2)

    local jump_func_list = {
        OnEnter = handler(self, self.JumpOnEnter),
        OnExit = handler(self, self.JumpOnExit),
        Update = handler(self, self.JumpUpdate),
        CheckOutFunc = handler(self, self.JumpCheckOutFunc)
    }
    self:RegisterMachineState(SceneConstant.ActionName.jump1, false, jump_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.jump2, false, jump_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.jump3, false, jump_func_list)

    local jump_fall_func_list = {
        OnEnter = handler(self, self.JumpFallOnEnter),
        OnExit = handler(self, self.JumpFallOnExit),
        Update = handler(self, self.JumpFallUpdate),
        CheckOutFunc = handler(self, self.JumpCheckOutFunc)
    }
    self:RegisterMachineState(SceneConstant.ActionName.jump4, true, jump_fall_func_list)

    local rideup_func_list = {
        OnEnter = handler(self, self.RideUpOnEnter),
        OnExit = handler(self, self.RideUpOnExit),
        Update = handler(self, self.RideUpUpdate),
        CheckOutFunc = function()
            return not self.is_riding_up
        end
    }
    self:RegisterMachineState(SceneConstant.ActionName.rideup, false, rideup_func_list)

    local ridedown_func_list = {
        OnEnter = handler(self, self.RideDownOnEnter),
        OnExit = handler(self, self.RideDownOnExit),
        Update = handler(self, self.RideDownUpdate),
        CheckOutFunc = function()
            return false
        end
    }
    self:RegisterMachineState(SceneConstant.ActionName.ridedown, false, ridedown_func_list)

    local dance_func_list = {
        OnEnter = handler(self, self.DanceOnEnter),
        OnExit = handler(self, self.DanceOnExit),
        -- Update = handler(self, self.DanceUpdate),
    }
    self:RegisterMachineState(SceneConstant.ActionName.dance1, true, dance_func_list)
    self:RegisterMachineState(SceneConstant.ActionName.dance2, true, dance_func_list)
end

function Role:RegisterMachineState(state_name, is_loop, func_list, reset_time, true_action_name)
    reset_time = reset_time or SceneConstant.ResetTime[state_name]
    Role.super.RegisterMachineState(self, state_name, is_loop, func_list, reset_time, true_action_name)
end

function Role:SetNameColor()
    -- self.name_container:SetColor(Color.yellow,Color.black)
    self.name_container:SetColor(Color(254, 249, 210), Color(6, 0, 1))
    -- self.name_container:SetVisible(false)
end

function Role:SetNameColor2(color,outlineColor)
    -- self.name_container:SetColor(Color.yellow,Color.black)
    self.name_container:SetColor(color, outlineColor)
    -- self.name_container:SetVisible(false)
end

function Role:ChangeBody()
    local res_id = self.object_info.body_res_id
    local clothes = self.object_info.figure.fashion_clothes
    if clothes and clothes.show then
        res_id = clothes.model
    end
    local abName = "model_clothe_" .. res_id
    local assetName = "model_clothe_" .. res_id
    local mecha_morph_buff_id = self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
    if mecha_morph_buff_id and not self:IsDeath() then
        local p_buff = self.object_info:GetBuffByID(mecha_morph_buff_id)
        if p_buff then
            res_id = p_buff.value
            abName = "model_machiaction_" .. res_id
            assetName = "model_machiaction_" .. res_id
        end
    end

    poolMgr:AddConfig(abName, assetName, Constant.CacheRoleObject, 0, false)

    self:CreateBodyModel(abName, assetName)
    -- if self:CreateBodyModel(abName, assetName) and  self.default_res then
    --  SetVisible(self.default_res,true)
    -- end
end

function Role:ClearDependStaticObject()
    local actors = self:GetDependObjectList()
    if not actors then
        return
    end
    local t = {}
    for _actor_type, actorList in pairs(actors) do
        for index, object in pairs(actorList) do
            if iskindof(object, "DependStaticObject") then
                t[#t + 1] = object
            end
        end
    end
    for k, object in pairs(t) do
        self:RemoveDependObject(object.object_type, object.depend_index)
    end
end

function Role:LoadBodyCallBack()

    -- if self.default_res then
    --  SetVisible(self.default_res,false)
    -- end

    -- if self.default_texture then
    --  SetMaterialTexture(self.body_skin_renderer.material,self.default_texture)
    -- end

    -- local boneName = SceneConstant.BoneNode.Ride_Root
    -- local horse_info = self.boneObject_list[boneName]
    -- local horse_res = self.boneRes_list[boneName]
    -- self.boneRes_list[boneName] = nil
    -- self.boneObject_list[boneName] = nil
    -- -- self.boneRes_list = {}
    -- -- self.boneObject_list = {}
    -- self:ClearBoneNode()
    -- self.boneNode_list = {}

    self:ShowBody(true)
    -- self.boneRes_list[boneName] = horse_res
    -- self.boneObject_list[boneName] = horse_info
    self.is_riding = false

    self:ClearBoneNode(SceneConstant.BoneNode.Ride_Root)
    self.boneNode_list = {}
    self:ClearDependStaticObject()

    local buff_id = self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
    if buff_id then
        local cf = Config.db_buff[buff_id]
        local show = String2Table(cf.scale_show)
        local scale_value = 1
        if not table.isempty(show) then
            for k,v in pairs(show) do
                if v[1] == "scale" then
                    scale_value = v[2]
                    break
                end
            end
        end
        if scale_value then
            self:SetScale(scale_value)
        end
    else
        self:SetScale(1)
        -- 进入默认的状态
        self:LoadHead()
        self:LoadLHand()
        self:LoadWeapon()
        self:LoadWing()
        self:LoadMagicArray()
        self:SetTitle();
        self:SetMeleeScore()
        -- self:LoadGod()

        -- 后续要判断是否要上坐骑
        if self:GetEscortMountID() then
            self:UpdateEscort()
        elseif (self.object_info.figure.mount and self.object_info.figure.mount.show) then
            -- self:PlayMount()
            self:LoadMount()
        end

        self:UpdateEffect()
    end

    self:LoadTailsMan()
    self:LoadFairy()
    self:LoadPet()

    if self.is_swing_block then
        self:SetSwimBoneState(false)
    else
        self:SetSwimBoneState(true)
    end

    if self.object_info.hp == 0 then
        self:PlayDeath()

        if self.__cname == "MainRole" then
            local okfun = function()
                FightController:GetInstance():RequestFightRevive(enum.REVIVE_TYPE.REVIVE_TYPE_SITU);
            end

            local cancelfun = function(rp)
                FightController:GetInstance():RequestFightRevive(enum.REVIVE_TYPE.REVIVE_TYPE_SAFE);
            end

            Dialog.ShowRevive("Revive", "You have been defeated!", "Revive on spot", okfun, nil, "Normal resurrection", cancelfun, auto_revive, "(Resurrect at the resurrection point in %s sec)");
        end
    end

    self:StartSetNameContainerPos()
end

-- function Role:SetBoneResource(boneName, abName, assetName, load_func, remove_cache_func)
--     if boneName ~= SceneConstant.BoneNode.Wing then
--         poolMgr:AddConfig(abName, assetName, Constant.CacheRoleObject, 0, false)
--     end
--     Role.super.SetBoneResource(self, boneName, abName, assetName, load_func, remove_cache_func)
-- end

function Role:LoadHead()
    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end
    self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_HEAD, 1)
end

function Role:LoadLHand()
    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end
    self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_HAND, 1)
end

function Role:LoadWeapon()
    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end
    local res_id = self.object_info.figure.weapon and self.object_info.figure.weapon.model
    if not res_id or res_id == 0 then
        res_id = self.object_info.body_res_id
    end
    local show = self.object_info.figure.weapon and self.object_info.figure.weapon.show;
    if res_id == self.object_info.body_res_id or show then
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_Weapon, 1)
    else
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_Weapon, 1)
    end
end

function Role:LoadWing()
    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end
    -- if not self.object_info.figure.wing then
    --  return
    -- end
    -- local res_id = self.object_info.figure.wing.model or 0;
    -- local abName = "model_wing_" .. res_id
    -- local assetName = "model_wing_" .. res_id
    -- local boneName = SceneConstant.BoneNode.Wing
    -- if res_id == 0 then
    --  self:RemoveBoneResource(boneName)
    --  return
    -- end

    -- local show = self.object_info.figure.wing and self.object_info.figure.wing.show;

    -- if show then
    --  local function load_func()
    --      -- Yzprint('--LaoY Role.lua,line 69-- data=',boneName)

    --  end
    --  self:SetBoneResource(boneName, abName, assetName, load_func, nil)
    -- else
    --  self:RemoveBoneResource(boneName)
    --  return
    -- end


    local res_id = self.object_info.figure.wing and self.object_info.figure.wing.model
    local show = self.object_info.figure.wing and self.object_info.figure.wing.show;
    if not res_id or res_id == 0 or not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_WING, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_WING, 1)
    end
end

function Role:LoadTailsMan()
    local res_id = self.object_info.figure.talis and self.object_info.figure.talis.model
    local show = self.object_info.figure.talis and self.object_info.figure.talis.show;
    if not res_id or res_id == 0 or not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_TALISMAN, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_TALISMAN, 1)
    end
end

function Role:LoadFairy()
    local scene_type = SceneConfigManager:GetInstance():GetSceneType()

    local res_id = self.object_info.figure.baby and self.object_info.figure.baby.model
    local show = self.object_info.figure.baby and self.object_info.figure.baby.show
    if not show then
        res_id = nil
    end
    if not res_id then
        res_id = EquipModel:GetInstance():GetEquipDevilOrFairy()
    end
    if not res_id then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_FAIRY, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_FAIRY, 1)
    end
end

function Role:LoadPet()
    if ArenaModel:GetInstance():IsArenaFight() then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_PET, 1)
        return
    end
    local res_id = self.object_info.figure.pet and self.object_info.figure.pet.model
    local show = self.object_info.figure.pet and self.object_info.figure.pet.show;
    if not res_id or res_id == 0 or not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_PET, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_PET, 1)
    end
end

function Role:LoadGod()
    -- if ArenaModel:GetInstance():IsArenaFight() then
    --     self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_GOD, 1)
    --     return
    -- end

    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end

    local res_id = self.object_info.figure.god and self.object_info.figure.god.model
    local show = self.object_info.figure.god and self.object_info.figure.god.show;
    if not res_id or res_id == 0 or not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_GOD, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_GOD, 1)
    end
end

--加载魔法阵 
function Role:LoadMagicArray(  )


    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end

    local res_id = self.object_info.figure.fashion_footprint and self.object_info.figure.fashion_footprint.model
    local show = self.object_info.figure.fashion_footprint and self.object_info.figure.fashion_footprint.show;
    if not res_id or res_id == 0 or not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_MAG, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_MAG, 1)
    end
end

function Role:LoadMount(is_move, move_pos)
    -- if is_move == nil then
    --     move_pos = self.move_pos
    --     local move_dir = self.move_dir
    --     if not self.move_state then
    --         move_pos = nil
    --     end
    --     is_move = self.move_state
    -- end
    self.is_riding = true
    self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_MOUNT, 1)
end

function Role:SetAlpha(a, gameObject)
    Role.super.SetAlpha(self, a, gameObject)
    if not gameObject then
        -- local outline_shader = ShaderManager:GetInstance():FindShaderByName("Custom/Outline2")
        -- self:SetHorseAlpha(a, outline_shader)
        local mount_list = self:GetDependObjectList(enum.ACTOR_TYPE.ACTOR_TYPE_MOUNT)
        if not table.isempty(mount_list) then
            for k,object in pairs(mount_list) do
                object:SetHorseAlpha(a)
                -- object:SetAlpha(a)
            end
        end
    end
end


--切换场景检查是否能上坐骑
function Role:ChangeSceneCheckMount()
    local is_can_mount = SceneConfigManager:GetInstance():GetSceneCanPlayMount()
    if is_can_mount then
        self:PlayMount()
    else
        local last_state_name = self.cur_state_name
        if Role.RemoveMount(self) then
            if self.is_main_role then
                GlobalEvent:Brocast(SceneEvent.ChangeMount, false)
            end
            self:ChangeMachineState(last_state_name, true)
        end
    end
end

--上坐骑
function Role:PlayMount(end_call_back, is_move, move_pos, force)
    if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
        return
    end
    local is_can_mount = SceneConfigManager:GetInstance():GetSceneCanPlayMount()
    if not is_can_mount then
        return
    end
    if self:IsAttacking() then
        return false
    end
    if (not self.object_info.figure or not self.object_info.figure.mount or self.object_info.figure.mount.model == 0) and not self:GetEscortMountID() then
        return false
    end
    if self:IsRiding() or self.is_swing_block then
        return false
    end
    if self.is_first_time_load_body then
        self.is_riding = true
        self:LoadMount(is_move, move_pos)
        self:ChangeMachineState(SceneConstant.ActionName.ride)
        return
    end
    local action_name = SceneConstant.ActionName.rideup
    local action = self.action_list[action_name]
    local last_state_name = self.cur_state_name
    if not self:ChangeMachineState(action_name, force) then
        return false
    end
    self.is_riding = true
    self.is_riding_up = true
    -- action.last_state_name = cur_state_name
    action.is_move = self.move_state
    action.move_pos = move_pos
    action.action_call_back = end_call_back
    self:LoadMount(is_move, move_pos)
    return true
end

function Role:RideUpOnEnter(action_name)
    if self.ride_up_on_enter_callback then
        self.ride_up_on_enter_callback()
    end
end

function Role:RideUpUpdate(action_name, delta_time)
    local action = self.action_list[action_name]
    self:SetNameContainerPos()
    -- if action.is_move then
    if self.move_state then
        if self.is_main_role then
            SoundManager:GetInstance():RunEff(true)
        end
        local x, y
        local cur_dis
        if action.move_pos then
            cur_dis = Vector2.DistanceNotSqrt(action.move_pos, self.position)
        end

        local move_speed = self.move_speed * GetSpeedRate(self.direction)
        x = self.position.x + self.direction.x * move_speed * delta_time
        y = self.position.y + self.direction.y * move_speed * delta_time
        -- 表示超过了
        if action.move_pos and Vector2.DistanceNotSqrt(Vector2(x, y), self.position) >= cur_dis then
            x = action.move_pos.x
            y = action.move_pos.y
            action.is_move = false
            -- if self.horse_animator then
            --     self:SetPosition(x, y)
            --     self:ChangeToMachineDefalutState()
            --     return
            -- end
        end
        if not action.is_move then
            self:ChangeToMachineDefalutState()
        end
        self:SetPosition(x, y)
    end
end

function Role:RideUpOnExit(action_name)
    self.is_riding_up = false
    -- local action = self.action_list[action_name]
    -- Yzprint('--LaoY Role.lua,line 737--',action.is_move,IsNil(self.horse_animator),action.move_pos and action.move_pos.x,action.move_pos and action.move_pos.y)
    -- if action.is_move and not IsNil(self.horse_animator) and action.move_pos then
    --     self:SetMovePosition(action.move_pos)
    -- end
    -- self:SetHorseAlpha(1.0)
    if self.is_main_role then
        FightManager:GetInstance():CheckWaitAttack(self.object_id)
    end
    self:StartSetNameContainerPos()
end

--下坐骑
-- force 强制下坐骑 比如：服务端下发下坐骑
function Role:PlayDismount(end_call_back, force)
    if not force and self:GetEscortMountID() then
        Notify.ShowText("Escorting, unable to actively demount")
        return
    end

    if not self:IsRiding() then
        return false
    end

    local boneName = SceneConstant.BoneNode.Ride_Root
    local horse_info = self.boneObject_list[boneName]

    local action_name = SceneConstant.ActionName.ridedown
    local action = self.action_list[action_name]
    action.last_state_name = self.cur_state_name
    -- action.action_time = 0.733
    local is_move = self.move_state
    local move_pos = self.move_pos
    local move_dir = self.move_dir
    if not self:ChangeMachineState(action_name) then
        action.last_state_name = nil
        return false
    end
    action.is_ride_down = false

    self.animator.speed = 1
    
    if not end_call_back then
        local last_state_name = action.last_state_name
        end_call_back = function()
            if is_move then
                self:SetMovePosition(move_pos)
            elseif last_state_name then
                -- Yzprint('--LaoY Role.lua,line 267-- data=', last_state_name)
                self:ChangeMachineState(last_state_name)
            end
        end
    end
    self:RemoveMount(0.1)
     -- action.ridedown_call_back = call_back
    action.action_call_back = end_call_back
    -- self:SetHorseAlpha(0.5)


    return true
end

function Role:RemoveMount(delay_time, is_ignore_syn)
    if not self:IsRiding() then
        return false
    end
    self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_MOUNT, 1)
    self:SetMachineDefaultState(SceneConstant.ActionName.idle)
    self.is_riding = false

    if self.remove_mount_callback then
        self.remove_mount_callback()
    end

    return true
end

function Role:IsRiding()
    return self.is_riding
end

function Role:IsRideDown()
    return self.is_ride_down
end

function Role:RideDownOnEnter()
    self.is_ride_down = true
end

function Role:RideDownOnExit()
    self.is_ride_down = false
    self:StartSetNameContainerPos()

    if self.ride_down_on_exit_call_back then
       self.ride_down_on_exit_call_back()
    end
end

function Role:RideDownUpdate(action_name, delta_time)
    self:SetNameContainerPos()
    local action = self.action_list[action_name]
    if not action.is_ride_down and action.pass_time >= action.action_time * 0.4 then
        action.is_ride_down = true
        if action.ridedown_call_back then
            action.ridedown_call_back()
        end
    end
end

function Role:PlayIdle()

end

function Role:EnterSwimBlock(is_need_jump)
    if self.is_swing_block then
        return
    end
    local pos = self:GetJumpPos()
    if not pos then
        return
    end
    self.is_swing_block = true
    local function call_back()
        if not self:IsJumping() and is_need_jump then
            self:PlayJump(pos)
        end
        self:SetMachineDefaultState(SceneConstant.ActionName.idle2)
        if self.shadow_image then
            self.shadow_image:SetVisible(false)
        end
        if not is_need_jump then
            self:ChangeToMachineDefalutState()
        end
        self:SetSwimBoneState(false)
    end
    if self:IsRiding() and not is_need_jump then
        -- self:PlayDismount()
        self:RemoveMount(0)
        call_back()
    else
        call_back()
    end
end

function Role:LeaveSwimBlock(is_need_jump)
    if not self.is_swing_block then
        return
    end
    local pos = self:GetJumpPos()
    if not pos then
        return
    end
    self.is_swing_block = false
    local function call_back()
        if not self:IsJumping() and is_need_jump then
            self:PlayJump(pos)
        end
        self:SetMachineDefaultState(SceneConstant.ActionName.idle)
        if self.shadow_image then
            self.shadow_image:SetVisible(true)
        end
        if not is_need_jump then
            self:ChangeToMachineDefalutState()
        end
        self:SetSwimBoneState(true)
        self:RemoveSwimEffect()
    end
    call_back()
end

function Role:SetSwimBoneState(state)
    for k, v in pairs(SceneConstant.SwimHideBone) do
        self:SetBoneVisible(v, state)
    end
end

function Role:PlaySwimEffect()
    if not self.swim_effect then
        if self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect() then
            self.swim_effect = self:SetTargetEffect("effect_xingzoushuiwen", true)
        end
    end
end

function Role:RemoveSwimEffect()
    if self.swim_effect then
        self.swim_effect:destroy()
        self.swim_effect = nil
    end
end

function Role:PlayCollect(info)
    local action_name = SceneConstant.ActionName.collect
    if self.is_swing_block then
        action_name = SceneConstant.ActionName.collect2
    end
    local action = self.action_list[action_name]
    if self:ChangeMachineState(action_name) then
        action.collect_time = info.action_time
        action.target_id = info.target_id
        self:RemoveMount()
        return true
    end
    return false
end

function Role:CollectOnEnter(action_name)
    self.is_collecting = true
end

function Role:CollectOnExit(action_name)
    self.is_collecting = false
end

function Role:CollectUpdate(action_name, delta_time)
end

function Role:IsCollecting()
    return self.is_collecting
end

function Role:GetJumpPos(index)
    index = index or 1
    local pos
    local start_pos = self.position
    local vec = Vector2(self.direction.x, self.direction.y)
    vec:Mul(SceneConstant.JumpDis[index])
    local end_pos = { x = start_pos.x + vec.x, y = start_pos.y + vec.y }
    local block_x, block_y = SceneManager:GetInstance():GetBlockPos(end_pos.x, end_pos.y)
    local block_value = MapManager:GetInstance():GetMask(block_x, block_y)
    if not self:IsCurBlockContain(SceneConstant.MaskBitList.Block, block_value) and
            not self:IsCurBlockContain(SceneConstant.MaskBitList.JumpPath, block_value) then
        pos = { x = end_pos.x, y = end_pos.y }
    else
        local bo, x, y = OperationManager:GetInstance():GetNearest(end_pos, start_pos, false)
        if bo then
            pos = { x = x, y = y }
        else
            pos = { x = self.position.x, y = self.position.y }
        end
    end
    return pos
end

function Role:PlayJump(pos, jump_type, is_continuous_jump, is_fly, callback)
    jump_type = jump_type or 0
    local jump_count = self.jump_count or 0
    jump_count = jump_count + 1
    if (jump_type == 0 and not is_fly) and jump_count > 3 then
        return
    end
    if jump_type == 0 and not is_fly and (jump_count > 1 and self.jump_info and Time.time - self.jump_info.start_time < SceneConstant.JumpCd[jump_count - 1]) then
        return
    end

    -- 跳跃点跳跃不能接普通跳
    if self.jump_info and self.jump_info.jump_type > 0 and jump_type == 0 then
        return
    end

    local start_pos = self.jump_info and self.jump_info.start_pos or Vector2(self.position.x, self.position.y)
    local fly_jump_config
    local index
    local jump_config, is_last_count = SceneManager:GetInstance():GetJumpConfig(jump_type, jump_count)
    local jump_list = { SceneConstant.ActionName.jump1, SceneConstant.ActionName.jump2, SceneConstant.ActionName.jump3 }
    local action_name
    if is_fly then
        fly_jump_config = self.jump_info and self.jump_info.fly_jump_config or GetFlyJumpConfig(start_pos, pos)
        jump_config = fly_jump_config[jump_count]
        is_last_count = jump_count == #fly_jump_config
    end

    if not jump_config then
        if jump_count > 3 then
            jump_count = 1
        end
        index = jump_count
        action_name = jump_list[index]
        if not index then
            return
        end
        if not pos then
            pos = self:GetJumpPos(index)
        end
    else
        local action_key = string.format("jump%s", jump_config.action_index)
        pos = jump_config.end_pos
        index = jump_config.action_index
        action_name = jump_list[index]
    end

    local distance = 0
    if pos then
        distance = Vector2.Distance(self.position, pos)
        if distance >= 2 then
            local vec = GetVector(self.position, pos)
            local angle = Vector2.GetAngle(vec)
            self:SetRotateY(angle, vec)
        end
    end
    local jump_pos = pos
    if not jump_config and (jump_type > 0 or is_fly) then
        local jump_dis = SceneConstant.JumpDis[index]
        if distance > 400 then
            for i = 10, 1, -1 do
                if distance >= i * 400 then
                    distance = distance / (i + 1)
                    jump_pos = GetDirDistancePostion(self.position, pos, distance)
                    break
                end
            end
        end
    end

    local action_speed = 1.0

    local jumptimeconfig = SceneConstant.JumpTimeConfig[self.object_info.gender]

    self.jump_speed = jumptimeconfig.h_speed[index]
    if jump_config and jump_config.h_speed then
        self.jump_speed = jump_config.h_speed
    end

    local v_speed = jumptimeconfig.v_speed[index]
    if jump_config and jump_config.v_speed then
        v_speed = jump_config.v_speed
    end

    local jump_action_time = SceneConstant.JumpConfig[self.object_info.gender].ActionTime[index]
    local jump_start_time = SceneConstant.JumpConfig[self.object_info.gender].StartTime[index]

    local jump_move_time = jump_action_time
    local jump_time = distance / self.jump_speed
    -- if distance ~= 0 then
    --     jump_time = distance/self.jump_speed
    -- end
    if jump_time < jump_action_time then
        jump_time = jump_action_time
        self.jump_speed = distance / jump_time
    end

    action_speed = jump_move_time / jump_time

    local start_y = self.body_pos.y

    local action = self.action_list[action_name]
    local is_riding = self.jump_info and self.jump_info.is_riding or self:IsRiding()
    if self:ChangeMachineState(action_name, true) then
        -- 是否播放跳跃特效
        action.is_play_jump_start_effect = false
        -- 是否播放落地特效
        action.is_play_jump_end_effect = false
        self:RemoveMount()
        self:SetBodyPosition(0, start_y)
        self:SetNameContainerPos()

        self.jump_pos = jump_pos
        self.jump_count = jump_count
        self.jump_info = {
            jump_config = jump_config,
            is_last_count = is_last_count,
            action_index = index,
            jump_action_time = jump_action_time,
            jump_start_time = jump_start_time,

            jump_time = jump_time,
            jump_pass_time = 0,

            v_speed = v_speed,
            action_speed = action_speed,
            reset_speed = false,
            cur_speed = nil,
            start_y = start_y,
            end_height = start_y,

            start_pos = start_pos,
            target_pos = pos,
            jump_type = jump_type,
            start_time = Time.time,
            is_riding = is_riding,

            is_fly = is_fly,
            callback = callback,

            fly_jump_config = fly_jump_config,
        }
        return true
    end
end

function Role:GetJumpEndPos()
    if not self:IsJumping() then
        return nil
    end
    local jump_config_endpos = SceneManager:GetInstance():GetJumpEndPos(self.jump_info.jump_type)    
    return jump_config_endpos or self.jump_info.target_pos
end

function Role:JumpUpdate(action_name, delta_time)
    local action = self.action_list[action_name]
    if not self.jump_info then
        logWarn("没有跳跃信息")
        return
    end
    if action.pass_time < self.jump_info.jump_start_time or action.jump_action_finish or not self.jump_pos then
        return
    end

    if not action.is_play_jump_start_effect then
        action.is_play_jump_start_effect = true
        if not self:IsCurBlockContain(SceneConstant.MaskBitList.Swim) then
            if self.body_pos.y > 0 then
                if self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect() then
                    EffectManager:GetInstance():PlayPositionEffect("effect_tiaoyueyan_kz", { x = self.position.x, y = self.position.y + self.body_pos.y, z = self.position.z })
                end
            else
                if self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect() then
                    EffectManager:GetInstance():PlayPositionEffect("effect_tiaoyueyan", { x = self.position.x, y = self.position.y, z = self.position.z })
                end
            end
        end
    end

    if not self.jump_info.reset_speed then
        self.jump_info.reset_speed = true
        self.animator.speed = self.jump_info.action_speed
    end

    if self.jump_info.reset_speed then
        action.pass_time = action.pass_time - delta_time
    end
    self.jump_info.jump_pass_time = self.jump_info.jump_pass_time + delta_time

    local jump_action_time = self.jump_info.jump_time
    local t = self.jump_info.jump_pass_time
    local rate = t / jump_action_time
    local height
    local p
    local half_time = jump_action_time * 0.5
    if self.jump_info.action_index == 4 then
        half_time = jump_action_time * 0.9
    end
    if t <= half_time then
        p = t / jump_action_time
        local speed = (1 - p) * self.jump_info.v_speed
        height = self.body_pos.y + speed * delta_time
        self.jump_info.end_height = height
    else
        p = (t - half_time) / (jump_action_time - half_time)
        p = p > 1 and 1 or p
        local r = cc.tweenfunc.easeIn(p, 1.3)
        height = self.jump_info.end_height - self.jump_info.end_height * r
    end

    self:SetBodyPosition(0, height)

    local error_off = self.jump_speed * delta_time + 1
    local is_jump_to_target = false
    local cur_dis = Vector2.DistanceNotSqrt(self.jump_pos, self.position)
    local x, y
    if self.jump_info.jump_config and self.jump_info.jump_config.rate then
        x = self.position.x + self.direction.x * self.jump_speed * delta_time / self.jump_info.jump_config.rate
        y = self.position.y + self.direction.y * self.jump_speed * delta_time / self.jump_info.jump_config.rate
    else
        x = self.position.x + self.direction.x * self.jump_speed * delta_time
        y = self.position.y + self.direction.y * self.jump_speed * delta_time
    end
    if Vector2.DistanceNotSqrt(Vector2(x, y), self.jump_pos) >= cur_dis then
        x = self.jump_pos.x
        y = self.jump_pos.y
        is_jump_to_target = true
    end

    -- Yzprint('--LaoY Role.lua,line 1291--',height,is_jump_to_target,t,jump_action_time)

    self:SetPosition(x, y)

    if self.jump_info.jump_config and not self.jump_info.is_last_count and rate > self.jump_info.jump_config.rate then
        self:PlayJump(self.jump_info.target_pos, self.jump_info.jump_type, true, self.jump_info.is_fly, self.jump_info.callback)
        return
    end

    if t >= half_time and not (self.jump_info.jump_config and not self.jump_info.is_last_count and self.jump_info.jump_config.rate) then
        if self.jump_info.action_index ~= 1 then
            self:ChangeMachineState(SceneConstant.ActionName.jump4, true)
            return
        end
        -- self:ChangeMachineState(SceneConstant.ActionName.jump4,true)
        -- return
    end

    if is_jump_to_target and self.jump_info and self.jump_info.jump_pass_time >= jump_action_time then
        action.jump_action_finish = true
        if not action.is_play_jump_end_effect then
            action.is_play_jump_end_effect = true
            if not self:IsCurBlockContain(SceneConstant.MaskBitList.Swim) then
                if self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect() then
                    EffectManager:GetInstance():PlayPositionEffect("effect_tiaoyueyan", { x = self.position.x, y = self.position.y, z = self.position.z })
                end
            end
        end

        self:SetBodyPosition(0, 0)
        self:SetNameContainerPos()
        if self.jump_info.reset_speed then
            action.pass_time = self.jump_info.jump_action_time + self.jump_info.jump_pass_time % self.jump_info.jump_time
            self.jump_info.reset_speed = false
            self.animator.speed = 1
        end
        if not self.jump_info.jump_config and self.jump_info.target_pos and Vector2.DistanceNotSqrt(self.jump_info.target_pos, self.position) > 2 then
            self:PlayJump(self.jump_info.target_pos, self.jump_info.jump_type, true, self.jump_info.is_fly, self.jump_info.callback)
        else
            self.jump_pos = nil
            self.jump_count = 0

            if self.is_main_role then
                if self.jump_info.is_riding and
                        (self.jump_info.jump_type > 0 and not OperationManager:GetInstance():IsAutoWay()) then
                    self:PlayMount(self.jump_info.callback, nil, nil, true)
                    return
                else
                    local callback = self.jump_info.callback
                    self:ChangeToMachineDefalutState()
                    if callback then
                        callback()
                        return
                    end
                end
            else
                self:ChangeToMachineDefalutState()
            end
        end
        return
    end
end

function Role:IsJumping()
    return self.is_jumping
end

function Role:JumpCheckOutFunc()
    return false
end

function Role:RemoveJumpHandEffect(remove_now)
    self:StopRemoveJumpEffectTime()
    local function step()
        for k, v in pairs(self.jump_hand_effect) do
            v:destroy()
        end
        self.jump_hand_effect = {}
    end
    if not remove_now then
        self.remove_jump_effect_time = GlobalSchedule:StartOnce(step, 0.2)
    else
        step()
    end
end

function Role:StopRemoveJumpEffectTime()
    if self.remove_jump_effect_time then
        GlobalSchedule:Stop(self.remove_jump_effect_time)
    end
    self.remove_jump_effect_time = nil
end

function Role:AddJumpEffect()
    if self.is_main_role then
        self:StopRemoveJumpEffectTime()
        local bone_name_list = { SceneConstant.BoneNode.BRHand, SceneConstant.BoneNode.BRLand }

        local effect_name = self.object_info.gender == 1 and "effect_male_tiaoyuetuowei" or "effect_female_tiaoyuetuowei"
        for k, bone_name in pairs(bone_name_list) do
            if not self.jump_hand_effect[bone_name] then
                local bone_node = self:GetBoneNode(bone_name)
                if bone_node then
                    local effect = self:SetTargetEffect(effect_name, true, bone_node)
                    self.jump_hand_effect[bone_name] = effect
                end
            end
        end
    end
end

function Role:JumpOnEnter(action_name)
    self.move_state = false
    self.is_jumping = true
    local action = self.action_list[action_name]
    action.jump_action_finish = false

    self:AddJumpEffect()
end

function Role:JumpOnExit(action_name,last_state_name)
    if not self.jump_info then
        return
    end
    if self.jump_info.reset_speed then
        self.jump_info.reset_speed = false
        self.animator.speed = 1
    end
    local jump_state_list = {
        [SceneConstant.ActionName.jump1] = true,
        [SceneConstant.ActionName.jump2] = true,
        [SceneConstant.ActionName.jump3] = true,
        [SceneConstant.ActionName.jump4] = true,
    }
    if self.jump_info.action_index == 1 or (last_state_name and not jump_state_list[last_state_name]) then
        -- self.jump_info = nil
        self:ClearJumpInfo()
    end
end

function Role:ClearJumpInfo()
    if not self.is_jumping then
        return
    end
    self.jump_info = nil
    self.is_jumping = false
    -- self.jump_pos = nil
    self.jump_count = 0
    self:SetBodyPosition(0, 0)
    self:SetNameContainerPos()
    self:RemoveJumpHandEffect()
end

-- 跳跃分两段
-- 落下的共用同一个
function Role:JumpFallOnEnter(action_name)
    self.is_jumping = true

    self:AddJumpEffect()
end

function Role:JumpFallOnExit(action_name)
    self.is_jumping = false
    self.jump_info = nil
    self.jump_pos = nil
    self.jump_count = 0
    self:SetBodyPosition(0, 0)
    self:SetNameContainerPos()
    self:RemoveJumpHandEffect()
end

function Role:JumpFallUpdate(action_name, delta_time)
    local action = self.action_list[action_name]
    if not self.jump_info then
        logWarn("没有跳跃信息")
        self:ChangeToMachineDefalutState()
        return
    end

    local jump_action_time = self.jump_info.jump_time
    local t = action.total_time
    local height = 0
    local p
    local half_time = jump_action_time * 0.5
    if t <= half_time then
        p = t / (jump_action_time - half_time)
        p = p > 1 and 1 or p
        local r = cc.tweenfunc.easeIn(p, 1.3)
        height = self.jump_info.end_height - self.jump_info.end_height * r
    end
    self:SetBodyPosition(0, height)

    local is_jump_to_target = false
    if not self.jump_pos then
        -- if AppConfig.Debug then
        --     logError('--LaoY Role.lua,line not self.jump_pos--', self.jump_pos, self.position)
        -- else
        --     logError('--LaoY Role.lua,line not self.jump_pos--', self.jump_pos, self.position)
        -- end
        logError('--LaoY Role.lua,line JumpFallUpdate not self.jump_pos--', self.jump_pos, self.position)
        self:ChangeToMachineDefalutState()
        return
    end
    local cur_dis = Vector2.DistanceNotSqrt(self.jump_pos, self.position)
    local x, y
    x = self.position.x + self.direction.x * self.jump_speed * delta_time
    y = self.position.y + self.direction.y * self.jump_speed * delta_time
    if Vector2.DistanceNotSqrt(Vector2(x, y), self.jump_pos) >= cur_dis then
        x = self.jump_pos.x
        y = self.jump_pos.y
        is_jump_to_target = true
    end
    self:SetPosition(x, y)

    local rate = (t + half_time) / jump_action_time
    if self.jump_info.jump_config and not self.jump_info.is_last_count and rate >= self.jump_info.jump_config.rate then
        self:PlayJump(self.jump_info.target_pos, self.jump_info.jump_type, true, self.jump_info.is_fly, self.jump_info.callback)
        return
    end

    -- if t >= half_time then
    --     print('--LaoY Role.lua,line 1227--',t >= half_time,rate)
    -- end

    if is_jump_to_target and rate >= 1 then
        if self.jump_info then
            action.jump_action_finish = true
            if not action.is_play_jump_end_effect then
                action.is_play_jump_end_effect = true
                if not self:IsCurBlockContain(SceneConstant.MaskBitList.Swim) then
                    if self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect() then
                        EffectManager:GetInstance():PlayPositionEffect("effect_tiaoyueyan", { x = self.position.x, y = self.position.y, z = self.position.z })
                    end
                end
            end

            self:SetBodyPosition(0, 0)
            self:SetNameContainerPos()
            if self.jump_info.reset_speed then
                action.pass_time = self.jump_info.jump_action_time + self.jump_info.jump_pass_time % self.jump_info.jump_time
                self.jump_info.reset_speed = false
                self.animator.speed = 1
            end
            if not self.jump_info.jump_config and self.jump_info.target_pos and Vector2.DistanceNotSqrt(self.jump_info.target_pos, self.position) > 2 then
                self:PlayJump(self.jump_info.target_pos, self.jump_info.jump_type, true, self.jump_info.is_fly, self.jump_info.callback)
                return
            else
                self.jump_pos = nil
                self.jump_count = 0
                local callback = self.jump_info.callback
                if self.is_main_role then
                    if self.jump_info.is_riding and
                            (self.jump_info.jump_type > 0 and not OperationManager:GetInstance():IsAutoWay()) and self:PlayMount(callback, nil, nil, true) then
                        return
                    else
                        if callback then
                            self:ChangeToMachineDefalutState()
                            callback()
                            return
                        end
                    end
                end
            end
        end
        self:ChangeToMachineDefalutState()
    end
end

function Role:PlayAttack(...)
    if self:IsRushing() then
        return
    end
    local bo = Role.super.PlayAttack(self, ...)
    if bo then
        self:RemoveMount()
    end
    return bo
end

function Role:UpdateAttack(state_name, delta_time)
    local action = self.action_list[state_name]
    if not action.check_combo_skill and action.skill_vo and action.skill_vo.fuse_time and action.pass_time >= action.skill_vo.fuse_time then
        if self:CheckWaitAttackCombo(action.skill_vo.skill_id) then
            action.check_combo_skill = true
            return
        end
    end
end

function Role:AttackCheckOutFunc()
    local action = self.action_list[self.cur_state_name]
    return Role.super.AttackCheckOutFunc(self) or self:IsCanPlayNextAttack()
            or (action.skill_vo and action.skill_vo.fuse_time and action.pass_time >= action.skill_vo.fuse_time)
end

function Role:PlayRush(rush_pos, callback, is_fly)
    if self:GetEscortMountID() then
        OperationManager:GetInstance():TryMoveToPosition(nil, self.position, rush_pos, callback)
        return false
    end
    -- if self:IsRushing() or self:IsJumping() or self.is_fly then 
    if self:IsJumping() then
        return
    end
    local rush_list = {
        SceneConstant.ActionName.rush,
        -- SceneConstant.ActionName.rush2,
    }
    local rush_start_time = {
        [SceneConstant.ActionName.rush] = 0.200,
        [SceneConstant.ActionName.rush2] = 0.200,
    }
    local index = math.random(#rush_list)
    local action_name = rush_list[index]
    local action = self.action_list[action_name]
    if not action then
        return false
    end
    if self:ChangeMachineState(action_name, true) then
        self:RemoveMount()
        local distance = Vector2.Distance(rush_pos, self.position)
        -- self.rush_speed = distance/action.action_time
        -- action.action_time
        if not action.action_time then
            action.action_time = 1.0
        end
        self.rush_speed = 900
        action.start_time = rush_start_time[action_name]
        action.rush_time = distance / self.rush_speed + 0.1
        if action.rush_time <= action.start_time then
            action.rush_time = action.start_time + 0.1
        end
        local vec = GetVector(self.position, rush_pos)
        self:SetDirection(vec, false)
        action.action_call_back = callback
        action.speed = (action.action_time - action.start_time) / (action.rush_time - action.start_time)
        if action.speed > 1 then
            action.speed = 1
        end
        action.reset_speed = false
        -- Notify.ShowText(action.speed)
        self.rush_pos = rush_pos
        return true
    end
    return false
end

function Role:LoadRushEffect()
    if not self.rush_effect then
        if self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect() then
            local root_name = SceneConstant.BoneNode.Root
            local root_node = self:GetBoneNode(root_name)
            self.rush_effect = self:SetTargetEffect("effect_zhujuechongci", true, root_node)
        end
    end
end

function Role:RemoveRushEffect()
    if self.rush_effect then
        self.rush_effect:destroy()
        self.rush_effect = nil
    end
end

function Role:RushOnEnter(action_name)
    -- _g_role_rush = true
    self.move_state = false
    self.last_rush_time = Time.time
    self:LoadRushEffect()
end

function Role:RushOnExit(action_name)
    -- local action = self.action_list[action_name]
    -- if not action then
    --  return
    -- end
    local action = self.action_list[action_name]
    if action.reset_speed then
        self.animator.speed = 1
    end
    self.rush_pos = nil

    if self.is_main_role then
        self:RemoveRushEffect()
    end
end

function Role:OnExitMachineState(state_name,last_state_name)
    Role.super.OnExitMachineState(self, state_name,last_state_name)
    -- 不是主角要检查是否有攻击序列
    if self.__cname ~= "MainRole" and self:IsCanInterruption() then
        FightManager:GetInstance():CheckWaitAttack(self.object_id)
    end
end

function Role:RushCheckOutFunc()
    return not self:IsRushing()
end

function Role:UpdateRushState(action_name, delta_time)
    if not self.rush_pos then
        return
    end
    local action = self.action_list[action_name]
    local action_time = action.reset_time and (action.action_time - action.reset_time) or action.action_time
    if action.pass_time >= action.start_time and not action.reset_speed then
        self.animator.speed = action.speed
        action.reset_speed = true
    end
    if action.total_time >= action.rush_time then
        -- action.pass_time = action.action_time
        action.pass_time = action.action_time + 1.0
    elseif action.reset_speed then
        action.pass_time = action.pass_time - delta_time
    end
    local x, y
    local cur_dis
    if self.rush_pos then
        cur_dis = Vector2.DistanceNotSqrt(self.rush_pos, self.position)
    end

    x = self.position.x + self.direction.x * self.rush_speed * delta_time
    y = self.position.y + self.direction.y * self.rush_speed * delta_time

    if self.rush_pos and Vector2.DistanceNotSqrt(self.position, pos(x, y)) >= cur_dis then
        x = self.rush_pos.x
        y = self.rush_pos.y
        self.rush_pos = nil
        action.pass_time = action.action_time + 1.0
    end
    self:SetPosition(x, y)
end

function Role:IsRushing()
    return self.rush_pos ~= nil
end

function Role:DeathOnExit()
    Role.super.DeathOnExit(self)
    -- if self.__cname ~= "MainRole" then
    --  self:destroy()
    -- end
end

function Role:IsCanSwitchToMove()
    --释放技能时是否可以打断
    return self:IsCanInterruption()
            -- 不在冲刺阶段
            and not self:IsRushing()
end

function Role:IsCanSwitchToRush()
    return Time.time - self.last_rush_time >= SceneConstant.RushCD
            and not self.is_attacking
end

function Role:IsCanSwitchToAttack(skill_vo)
    return self:IsCanInterruption()
            and not self:IsRushing()
            and not self:IsJumping()
end

function Role:Update(delta_time)
    Role.super.Update(self, delta_time)
end

function Role:OnEnterMachineState(state_name)
    Role.super.OnEnterMachineState(self, state_name)

    if not IsSameStateGroup(state_name,SceneConstant.ActionName.jump1) then
        self:ClearJumpInfo()
    end

    local info = self.boneObject_list[SceneConstant.BoneNode.Head]
    if info and info.animator then
        info.animator:CrossFadeInFixedTime(state_name, 0)
    end

    local info = self.boneObject_list[SceneConstant.BoneNode.LHand]
    if info and info.animator then
        info.animator:CrossFadeInFixedTime(state_name, 0)
    end
end

function Role:ResetAction()
    local state_name = self.cur_state_name

    local info = self.boneObject_list[SceneConstant.BoneNode.Head]
    if info and info.animator then
        info.animator:CrossFadeInFixedTime(state_name, 0)
    end

    local info = self.boneObject_list[SceneConstant.BoneNode.LHand]
    if info and info.animator then
        info.animator:CrossFadeInFixedTime(state_name, 0)
    end

    if self.gpu_player ~= nil then
        self.gpu_player:Play(state_name)
    else
        self.animator:CrossFadeInFixedTime(state_name, 0)
    end
end

function Role:ChangeMachineState(state_name, ...)
    if self.is_swing_block then
        if state_name == SceneConstant.ActionName.idle then
            state_name = SceneConstant.ActionName.idle2
        elseif state_name == SceneConstant.ActionName.run then
            state_name = SceneConstant.ActionName.run2
        end
    elseif not table.isempty(self:GetDependObjectList(enum.ACTOR_TYPE.ACTOR_TYPE_MOUNT)) then
        if state_name == SceneConstant.ActionName.idle then
            state_name = SceneConstant.ActionName.ride
        elseif state_name == SceneConstant.ActionName.run then
            state_name = SceneConstant.ActionName.riderun
        end
    else
        if state_name == SceneConstant.ActionName.ride then
            state_name = SceneConstant.ActionName.idle
        elseif state_name == SceneConstant.ActionName.riderun then
            state_name = SceneConstant.ActionName.run
        end
    end

    return Role.super.ChangeMachineState(self, state_name, ...)
end

function Role:IsCorssBlock()
    return self:IsRushing()
            or self:IsJumping()
    -- or self:IsJumping()
end

function Role:SetDirection(vec, is_move)
    if self:IsJumping() then
        return
    end
    Role.super.SetDirection(self, vec, is_move)
end

function Role:SetServerPosition(pos, dir, state)
    Role.super.SetServerPosition(self, pos, dir, state)
end

function Role:SetMovePosition(pos, dir, state)
    if self:IsJumping() then
        return
    end
    -- if self:IsAttacking() then
    --  local end_pos = pos
    --  self:PlaySlip(end_pos,self.move_speed)
    --  return
    -- end

    if not self.is_main_role then
        --Yzprint('----SetMovePosition--',pos and pos.x , pos and pos.y , dir, state, Time.time)
        --traceback()
    end

    self:StopSlip()
    Role.super.SetMovePosition(self, pos, dir, state)
end

function Role:SetPosition(x, y)
    local bo = Role.super.SetPosition(self, x, y)

    if not self.is_main_role then
        --Yzprint('--SetPosition--',x,y,Time.time)
        --traceback()
    end

    if not bo then
        return false
    end
    if not self.object_info then
        return
    end

    local cur_block_is_water = self:IsCurBlockContain(SceneConstant.MaskBitList.Water)
    if cur_block_is_water and not self:IsJumping() then
        local is_show_effect = self.is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect()
        if is_show_effect and self.move_state and (self.object_info.coord.x ~= self.position.x or self.object_info.coord.y ~= self.position.y) and
                (not self.last_play_water_effect_time or os.clock() - self.last_play_water_effect_time >= 400) then
            self.last_play_water_effect_time = os.clock()
            EffectManager:GetInstance():PlayPositionEffect("effect_xingzoushuiwen", self.position)
        end
    end

    if not self.is_brocast_pos or self.object_info.coord.x ~= self.position.x or self.object_info.coord.y ~= self.position.y then
        self.is_brocast_pos = true
        self.object_info.coord.x = self.position.x
        self.object_info.coord.y = self.position.y
        if self.is_main_role then
            GlobalEvent:Brocast(SceneEvent.MainRolePos, self.position.x, self.position.y, self.block_pos.x, self.block_pos.y)
        end
    end
    return true
    -- local x = self.object_info.coord.x
    -- local y = self.object_info.coord.y
    -- local vec1 = SceneManager:GetInstance():WorldToScreenPoint(x/SceneConstant.PixelsPerUnit,y/SceneConstant.PixelsPerUnit)
    -- Yzprint('--LaoY MainRole.lua,line 77-- data=',vec1.x,vec1.y)
end

function Role:StartSetNameContainerPos(delay_time)
    self:StopSetNameContainerPos()
    delay_time = delay_time or 0.1
    local function step()
        if self.is_dctored then
            return
        end
        self:SetNameContainerPos()
    end
    self.set_name_pos_time_id = GlobalSchedule:StartOnce(step, delay_time)
end

function Role:StopSetNameContainerPos()
    if self.set_name_pos_time_id then
        GlobalSchedule:Stop(self.set_name_pos_time_id)
        self.set_name_pos_time_id = nil
    end
end

function Role:SetNameContainerPos()
    if self.name_container then
		if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
			local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
			local body_height = 375 + (self.body_pos.y <= 0 and 0 or (self.body_pos.y + 30))
			self.name_container:SetGlobalPosition(world_pos.x, world_pos.y + body_height / SceneConstant.PixelsPerUnit, self.position.z * 1.1)
        elseif not self.transform_layer_is_self then
            local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
            local body_height = 180 + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30)
            self.name_container:SetGlobalPosition(world_pos.x, world_pos.y + body_height / SceneConstant.PixelsPerUnit, self.position.z * 1.1)
        elseif self:IsJumping() or (self.__cname == "MainRole" and self:IsFlying()) or self.is_riding_up or self:IsRideDown() then
            local waist_node = self:GetBoneNode(SceneConstant.BoneNode.Waist)
            if not waist_node then
                waist_node = self:GetBoneNode(SceneConstant.BoneNode.Root)
            end
            local y = GetGlobalPositionY(waist_node)
            local offset = 0.801
            if self:IsJumping() then
                offset = 0.801
            elseif self:IsRideDown() then
                offset = 1.031
            end
            self.name_container:SetGlobalPosition(self.position.x / SceneConstant.PixelsPerUnit, y + offset, self.position.z * 1.1)
            self:StopSetNameContainerPos()
        elseif not table.isempty(self:GetDependObjectList(enum.ACTOR_TYPE.ACTOR_TYPE_MOUNT)) and self.is_riding and self.horse_bone_height then
            self.name_container:SetGlobalPosition(self.position.x / SceneConstant.PixelsPerUnit, self.position.y / SceneConstant.PixelsPerUnit + self.horse_bone_height + 0.92, self.position.z * 1.1)
            self:StopSetNameContainerPos()
        else
            local world_pos = { x = self.position.x / SceneConstant.PixelsPerUnit, y = self.position.y / SceneConstant.PixelsPerUnit }
            local body_height = 180 + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30)
            self.name_container:SetGlobalPosition(world_pos.x, world_pos.y + body_height / SceneConstant.PixelsPerUnit, self.position.z * 1.1)
        end

    end
end

function Role:CheckNextBlock(x, y)
    if not MapManager:GetInstance().is_loaded then
        return false
    end
    local bo, block_value = Role.super.CheckNextBlock(self, x, y)
    if block_value then
        -- local last_block_is_swim = self:IsLastBlockContain(SceneConstant.MaskBitList.Swim)
        local is_need_jump = true
        if (self.block_pos.x <= 0 and self.block_pos.y <= 0) then
            is_need_jump = false
        end
        local cur_block_is_swim = self:IsCurBlockContain(SceneConstant.MaskBitList.Swim, block_value)
        if cur_block_is_swim and not self.is_swing_block then
            self:EnterSwimBlock(is_need_jump)
            if is_need_jump then
                return false
            end
        elseif not cur_block_is_swim and self.is_swing_block then
            self:LeaveSwimBlock(is_need_jump)
            if is_need_jump then
                return false, block_value
            end
        end
        if cur_block_is_swim and not self:IsJumping() then
            self:PlaySwimEffect()
        end
    end
    if self.is_runing and not self.is_main_role and (not self.server_pos_is_block or
            self.server_move_state ~= SceneConstant.SynchronousType.Rocker) then
        bo = true
    end
    return bo, block_value
end

function Role:BeHit()
end

function Role:PlayDeath(attack_object,...)
    local jump_pos = self.jump_pos
    local is_jumping = self:IsJumping()
    local bo = Role.super.PlayDeath(self,attack_object, ...)
    if bo then
        if not attack_object or attack_object == SceneManager:GetInstance():GetMainRole() then
            GlobalEvent:Brocast(SceneEvent.KILL_MONSTER)
        end

        if self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH) then
            self:ChangeBody()
        end
        self:RemoveMount(0)
        if is_jumping then
            self:SetPosition(jump_pos.x, jump_pos.y)
            self:ClearJumpInfo()
        end
    end
    return bo
end

function Role:GetEscortMountID()
    local escort_lv_tab = {
        [130150011] = 30001,
        [130150012] = 30002,
        [130150013] = 30003,
        [130150014] = 30004,
    }
    for i, v in pairs(self.object_info.buffs) do
        if escort_lv_tab[v.id] then
            return escort_lv_tab[v.id]
        end
    end
    return nil
end

function Role:GetQuaByBuff()
    local escort_lv_tab = {
        [130150011] = 1,
        [130150012] = 2,
        [130150013] = 3,
        [130150014] = 4,
    }
    for i, v in pairs(self.object_info.buffs) do
        if escort_lv_tab[v.id] then
            return escort_lv_tab[v.id]
        end
    end
    return nil
end

function Role:UpdateEscort()

    local isEscort = self:GetEscortMountID()
    isEscort = isEscort ~= nil and true or false
    self.last_escort_state = self.last_escort_state ~= nil and self.last_escort_state or false
    if self.last_escort_state ~= isEscort then
        self.last_escort_state = isEscort
        local qua
        if self:GetQuaByBuff() then
            qua = self:GetQuaByBuff()
        else
            qua = 1
        end
        self.name_container:SetEscortFlag(isEscort, "ersort_flag" .. qua)
        if isEscort then
            if self:IsRiding() then
                self:LoadMount()
            else
                self:PlayMount()
            end
        else
            self:PlayDismount()
        end
    end
end

function Role:UpdateEffect()
    -- self.object_info.buffs
    -- print('--LaoY Role.lua,line 1449--',self.object_info.buffs)
    -- Yzdump(self.object_info.buffs,"tab")
end

function Role:IsCanBeAttack()
    if self:IsInSafe() then
        return false
    end
    -- 第一优先级
    -- 同一分组 各个战斗模式都不能攻击
    if SceneManager:GetInstance():IsSameGroup(self.object_info.group) then
        return false
    end

    local pkmode = FightManager:GetInstance().pkmode
    -- 第二优先级
    -- 强制模式 非帮会非队友 其他都可以打
    if (pkmode == enum.PKMODE.PKMODE_ALLY) then
        return not TeamController:GetInstance():IsSameTeam(self.object_info.team) and not FactionModel:GetInstance():IsSameGuild(self.object_info.gname)
        -- 全体模式
    elseif (pkmode == enum.PKMODE.PKMODE_WHOLE) then
        -- 场景支持杀戮模式全部都可以打
        if SceneConfigManager:GetInstance():IsWhole() then
            return true
        end
        -- 全体模式
        -- 不可攻击帮会和队友
        -- return not TeamController:GetInstance():IsSameTeam(self.object_info.team) and not FactionModel:GetInstance():IsSameGuild(self.object_info.gname)
        -- 后面改为不可攻击队友，可以攻击帮会
        return not TeamController:GetInstance():IsSameTeam(self.object_info.team)
    -- 跨服
    elseif pkmode == enum.PKMODE.PKMODE_CROSS then
        return not RoleInfoModel:GetInstance():IsSameServer(self.object_info.suid)
    -- 敌对
    elseif pkmode == enum.PKMODE.PKMODE_ENEMY then
        return SiegewarModel:GetInstance():IsEnemy(self.object_info.suid)
    end

    -- if TeamController:GetInstance():IsSameTeam(self.object_info.team) or FactionModel:GetInstance():IsSameGuild(self.object_info.gname) then
    --  return false
    -- end

    return false
end

function Role:GetLockEffectName()
    if self:IsCanBeAttack() then
        return "effect_xuanzhong_xiaoguai"
    else
        return "effect_xuanzhong_npc"
    end
end

function Role:BeLock(flag)
    Role.super.BeLock(self, flag);
    BrocastModelEvent(EventName.ROLE_BE_LOCK, nil, self, flag);
end

function Role:OnClick()
    local bo = self:AutoSelect()
    if bo then
        SceneManager:GetInstance():OnClickAttackObject(self.object_info.uid)
    else
        SceneManager:GetInstance():LockNpc(self.object_id)
    end
    return true
end

function Role:IdleOnEnter()
    self.last_dance_time = Time.time - SceneConstant.God.showTime
end

-- 角色待机，需要判断神灵
function Role:LoopActionOnceEnd()
    if IsSameStateGroup(self.cur_state_name, SceneConstant.ActionName.idle) then
        local action = self.action_list[self.cur_state_name]
        if (Time.time - self.last_dance_time) > (SceneConstant.God.intervalTime + SceneConstant.God.showTime) and table.isempty(self:GetDependObjectList(enum.ACTOR_TYPE.ACTOR_TYPE_GOD)) then
            -- local action_name = SceneConstant.ActionName.show
            -- self:ChangeMachineState(action_name)
            -- FightController:GetInstance():RequestFightAttack(0,403000,0,self.object_id,0)
            self.last_dance_time = Time.time
            self:LoadGod()
        end
    end
end

function Role:UpdateDance()
    local cur_is_dance = self:IsDanceing()
    local have_dance_buff = self.object_info:IsContainBuffGroup(25)
    if cur_is_dance == have_dance_buff then
        return
    end
    if have_dance_buff then
        self:PlayDance()
    else
        self:ChangeToMachineDefalutState()
    end
end

function Role:PlayDance()
    local action_name = SceneConstant.ActionName.dance1
    local action = self.action_list[action_name]

    local danceTab = {
        [1] = {
            [SceneConstant.ActionName.dance1] = 5.267,
            [SceneConstant.ActionName.dance2] = 4.7,
        },
        [2] = {
            [SceneConstant.ActionName.dance1] = 5.233,
            [SceneConstant.ActionName.dance2] = 6.5,
        },
    }

    if self:ChangeMachineState(action_name) then
        local action_time = danceTab[self.object_info.gender][action_name]
        local cur_time_ms = os.clock()
        action.start_dance_time = cur_time_ms
        if action_time then
            action.action_time = action_time
        end
        local first_info = SceneManager:GetInstance():GetFirstDanceInfo(self.object_info.gender, cur_time_ms)
        local reset_time = 0
        if first_info then
            reset_time = first_info.pass_time
            -- local cur_state = role_object.animator:GetCurrentAnimatorStateInfo(0)
            -- local normalizedTime = cur_state.normalizedTime
            -- Yzprint('--LaoY Role.lua,line 2398--',reset_time,cur_state.normalizedTime)
        end
        action.pass_time = reset_time
        if self.animator then
            self.animator:PlayInFixedTime(action.action_name, -1, reset_time)
        end

        action.action_call_back = function()
            if self:ChangeMachineState(action.action_name) then
                -- self.animator:PlayInFixedTime(action.action_name, -1, 0)
                self.animator:CrossFadeInFixedTime(action.action_name, 0.1)
            end
        end
    end
end

function Role:GetDanceActionInfo(time_ms)
    if IsSameStateGroup(self.cur_state_name, SceneConstant.ActionName.dance1) then
        local action = self.action_list[self.cur_state_name]
        return action
    end
    return nil
end

function Role:IsDanceing()
    return self.is_danceing == true
end

function Role:DanceOnEnter()
    self.is_danceing = true
end
function Role:DanceOnExit()
    self.is_danceing = false
end

function Role:GetSkinnedMeshRenderer(gameObject)
    gameObject = gameObject or self.gameObject
    if not gameObject then
        return {}
    end
    local check_name_list = {
        -- "model_head","model_hand","model_clothe","model_weapon","model_wing"
        "model_clothe",
    }
    local function checkFunc(name)
        if not name then
            return false
        end
        for k, v in pairs(check_name_list) do
            if name:find(v) then
                return true
            end
        end
        return false
    end
    local renders = gameObject:GetComponentsInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
    local index = 0
    local t = {}
    for i = 0, renders.Length - 1 do
        local render = renders[i]
        local name = render.name
        if checkFunc(name) then
            t[index] = render
            index = index + 1
        end
    end
    t.Length = index
    return t
end

function Role:CheckServerPosition(delta_time)
    -- if self:IsJumping() and self:IsJumping() then
    --     return
    -- end
    -- Role.super.CheckServerPosition(self,delta_time)
end

function Role:UpdateMachineArmorShield()
    local shield_buff_id = self.object_info:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_SHIELD)
    if shield_buff_id then
        if self.name_container then
            local p_buff = self.object_info:GetBuffByID(shield_buff_id)
            self.name_container:UpdateMachineArmorShield(p_buff.value,p_buff.origin)
        end
    else
        if self.name_container then
            self.name_container:RemoveMachineArmorShield()
        end
    end
end