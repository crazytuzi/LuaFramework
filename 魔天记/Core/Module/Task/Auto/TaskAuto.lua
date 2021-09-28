require "Core.Module.Task.Auto.TaskSequence";
require "Core.Module.Task.Auto.TaskAutoAction";
require "Core.Module.Task.Auto.TaskAutoKill";
require "Core.Module.Task.Auto.TaskAutoComit";
require "Core.Module.Task.Auto.TaskAutoEscort";
require "Core.Module.Task.Auto.TaskAutoTalkToNpc";
require "Core.Module.Task.Auto.TaskSeqStartEscort";
require "Core.Module.Task.Auto.TaskAutoFlyVehicle";
require "Core.Module.Task.Auto.TaskAutoVehicleKill";
require "Core.Module.Task.Auto.TaskAutoVehicleAction";
require "Core.Module.Task.Auto.TaskAutoCollect";

TaskAuto = class("TaskAuto");



function TaskAuto.Trans(seq)
    local cfg = seq:GetCfg();
    return SequenceCommand.Task.TaskTransmit(cfg);
end

function TaskAuto:Init()
    self.content = nil;
    self.enabled = false;
    self.running = false;

    self.isSeq = false;
    self.isGuide = false;

    self.curSeqName = "";
    UpdateBeat:Add(self.OnUpdate, self); 
    --self._timer = FixedTimer.New( function(val) self:OnUpdate(val) end, 0, -1, false);
    --self._timer:Start();
end

function TaskAuto:Close()
    UpdateBeat:Remove(self.OnUpdate, self);
end

function TaskAuto:Start(task)
    if PlayerManager.hero:IsOnFlyVehicle() then
        MsgUtils.ShowTips("task/error/flyVehicle");
        return;
    end

    --防止切换场景的时候执行任务出错
    if GameSceneManager.map then
        if GameSceneManager.map.info.type == InstanceDataManager.MapType.ArathiWar or GameSceneManager.map.info.type == InstanceDataManager.MapType.GuildWar then
            return;
        elseif InstanceDataManager.IsInInstance() == true then
        --MsgUtils.ShowTips("task/error/inInstance");
            PlayerManager.hero:StartAutoFight()
            return;
        end
    end
    if self.task then
        if self.task.id ~= task.id then--and self.taskSt == task.status then
            self:StopGuideAndSeq();
        end
    end

    if task.type ~= TaskConst.Type.BRANCH then
        PlayerManager.hero:StopAutoFight();
    end

    self.enabled = true;
    self.task = task;
    
    --self.taskSt = task.status;
    --UpdateBeat:Add(self.OnUpdate, self);
    self._startToExecute = true;
    TaskManager.DiapatchEvent(TaskNotes.ENV_TASK_ITEM_CHG);
end

function TaskAuto:_CanExecute()
    local act = PlayerManager.hero:GetAction();
    if act and act.actionType == ActionType.BLOCK then
        return false;
    end

    if GuideManager.isForceGuiding then
        log("正在强制引导. return")
        return false;
    end

    return true
end

function TaskAuto:Stop()
    if self.enabled == true then
        self.task = nil;
        --self.taskSt = nil;
        self.enabled = false;

        self:StopGuideAndSeq();
    end
    --停止护送AI.
    HeroController.GetInstance():StopAutoEscort();
end

function TaskAuto:StopGuideAndSeq()
    --[[
    if self.isGuide then
        GuideManager.Stop();
        self.isGuide = false;
    end
    ]]

    if self.isSeq then
        SequenceManager.Stop(self.curSeqName);
        self.isSeq = false;
    end
end

function TaskAuto:OnEvent(eventType, param)
    if(eventType == SequenceEventType.Base.MANUALLY_MOVE or eventType == SequenceEventType.Base.MANUALLY_SKILL) then
        self:Stop();
    end
end

function TaskAuto:OnUpdate()    
    --Warning(self.enabled)
    if (self.enabled == false) then
        return;
    end 

    --人物动作对自动的控制. 有些动作未做完时 不允许执行.
    if self._startToExecute == true then
        if (self:_CanExecute()) then
            self:OnExecute();
            self._startToExecute = false;
        end
    end
end

function TaskAuto:OnExecute()
    --Warning("TaskAuto:OnExecute - > " .. tostring(self.task.id));
    local d = self.task;
    if d == nil then
        --logTrace("task is nil")
        return;
    end

    if d.__cname == "TaskInfo" then
        local task = d;

        --处理仙盟任务
        if task.type == TaskConst.Type.GUILD and task.status == TaskConst.Status.FINISH or task.tType == TaskConst.Target.COLLECT_ITEM then
            ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.TASK);
            return;
        end

        local myInfo = PlayerManager.GetPlayerInfo();
        local cfg = task:GetConfig();
        if (task.status == TaskConst.Status.FINISH) then

            --特定类型 如果在副本里 停止自动.
            if TaskUtils.IsInInst() == true and ( task.tType == TaskConst.Target.INSTANCE_CLEAR or task.tType == TaskConst.Target.B_ZONGMEN_LILIAN or task.tType == TaskConst.Target.B_XLT or task.tType == TaskConst.Target.B_GOTO_INSTANCE ) then
                log("特定类型 如果在副本里 停止自动.")
                return;
            end
            
            if task.type == TaskConst.Type.REWARD then
                --已完成的悬赏任务自动打开界面
                ModuleManager.SendNotification(TaskNotes.OPEN_REWARDTASKPANEL);
                return;
            elseif task.type == TaskConst.Type.BRANCH then
                --已完成的分支任务,自动领取.
                TaskProxy.ReqTaskFinish(task.id);
                return;
            
            elseif (task.type == TaskConst.Type.MAIN and cfg.auto_complete) or task.type == TaskConst.Type.DAILY then
                --针对后端存在的问题数据进行特殊处理
                TaskProxy.ReqTaskFinish(task.id);
                return;
            end
            
            self:PlaySeq("TaskAutoComit", task);

        elseif (task.status == TaskConst.Status.IMPLEMENTATION) then
            local p = cfg.target;
            if (task.tType == TaskConst.Target.FIND) then
                self:PlaySeq("TaskAutoTalkToNpc", task);
            --杀怪&&掉落&&刷怪
            elseif (task.tType == TaskConst.Target.KILL or task.tType == TaskConst.Target.DROP or task.tType == TaskConst.Target.MONSTER ) then
                self:PlaySeq("TaskAutoKill", task);
            --功能类
            elseif (task.tType == TaskConst.Target.USE_ITEM or task.tType == TaskConst.Target.EXPLORE) then
                self:PlaySeq("TaskAutoAction", task);
            --护送
            elseif (task.tType == TaskConst.Target.ESCORT) then
                self:PlaySeq("TaskAutoEscort", task);
            elseif (task.tType == TaskConst.Target.COLLECT) then
                self:PlaySeq("TaskAutoCollect", task);
            --副本通关
            elseif (task.tType == TaskConst.Target.INSTANCE_CLEAR) then
                local fbId = tonumber(p[1]);
                local inFb = TaskUtils.InInst(fbId);
                if inFb == false then
                    local fgCfg = InstanceDataManager.GetMapCfById(fbId);
                    local onConfirm = nil; 

                    if fgCfg.type == InstanceDataManager.InstanceType.MainInstance then
                        onConfirm = function() HeroController.GetInstance():StopCurrentActAndAI(); InstanceDataManager.TryGotoInstanceFb(fbId); end;
                    else
                        onConfirm = function() HeroController.GetInstance():StopCurrentActAndAI(); GameSceneManager.GoToFB(fbId); end;    
                    end
                    
                    MsgUtils.ShowConfirm(self, "task/GotoInstance", {name = fgCfg.name}, onConfirm);
                end
            --答题
            elseif (task.tType == TaskConst.Target.QUESTION) then
                local ds = DialogSet.InitWithTaskQA(task.id);
                ModuleManager.SendNotification(DialogNotes.OPEN_DIALOGPANEL, ds);
            --飞行载具
            elseif (task.tType == TaskConst.Target.VEHICLE) then
                self:PlaySeq("TaskAutoFlyVehicle", task);
            --载具杀怪.
            elseif (task.tType == TaskConst.Target.VKILL) then
                if task:IsPay() then
                    self:PlaySeq("TaskAutoVipVehicleKill", task);
                else
                    self:PlaySeq("TaskAutoVehicleKill", task);
                end
            --载具动作.
            elseif (task.tType == TaskConst.Target.VACTION) then
                if task:IsPay() then
                    self:PlaySeq("TaskAutoVipVehicleAction", task);
                else
                    self:PlaySeq("TaskAutoVehicleAction", task);
                end
            else  
                local isBranch = self:TryDealBranchType(task);
                if isBranch == false then
                    log("不支持的任务类型");
                end
            end
        end
    else
        local todo = d;
        if todo.type == TodoConst.Type.NORMAL then
            
        elseif todo.type == TodoConst.Type.GOTONPC then
            self:PlaySeq("TodoGoToNpc", todo);
        end
    end
    
end

function TaskAuto:PlaySeq(seqName, data, cls)
    cls = cls or TaskSequence;
    local seq = SequenceManager.Play(seqName, data, cls);
    self.curSeqName = seqName;
    self.isSeq = true;
end

function TaskAuto:PlayGuide(guideName, data)
    --local seq = GuideManager.Guide(guideName, data);
    GuideManager.AddToGuide(guideName, data);
    self.isGuide = true;
end

--引导任务完成触发.
function TaskAuto.GuideTaskFinish(task)
    if task.tType == TaskConst.Target.GUIDE_AUTOFIGHT then
        TaskProxy.ReqTaskTrigger(task.id);
    end
end

--分支任务类型处理.
function TaskAuto:TryDealBranchType(task)
    if (task.tType == TaskConst.Target.GUIDE_AUTOFIGHT) then
    --药品设置
        self:PlayGuide("GuideAutoFightSetting", task);
        return true;
    elseif (task.tType == TaskConst.Target.GUIDE_PET) then
    --宠物上阵
        if TaskAuto.CheckGuide("GuidePet") then
            self:PlayGuide("GuidePet");
        else
            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL);  
        end
        return true;
    elseif (task.tType == TaskConst.Target.GUIDE_EQUIP_QH) then
    --装备强化
        --if TaskAuto.CheckGuide("GuideEquip") then
        --    self:PlayGuide("GuideEquip");
        --else
            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_1);
        --end
        return true;
    elseif (task.tType == TaskConst.Target.GUIDE_SKILL_UP) then
    --技能升级
        if TaskAuto.CheckGuide("GuideSkillUpgrade") then
            self:PlayGuide("GuideSkillUpgrade");
        else
            ModuleManager.SendNotification(SkillNotes.OPEN_SKILLPANEL);
        end
        return true;
    elseif task.tType == TaskConst.Target.B_TRUMP_REFINE then
    --法宝炼制x次（点击打开法宝炼制界面）
        ModuleManager.SendNotification(NewTrumpNotes.OPEN_NEWTRUMPPANEL, 2);
        return true;
    elseif task.tType == TaskConst.Target.B_PET_UPGRADE then
        --伙伴等级升至x级（点击打开伙伴升级界面）
        if TaskAuto.CheckGuide("GuidePetLvUp") then
            self:PlayGuide("GuidePetLvUp");
        else
            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL);  
        end
        return true;
    elseif task.tType == TaskConst.Target.B_DAILY_TASK then
    --完成循环任务X次（点击打开活动界面日常活动标签页）
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, {type=ActivityNotes.PANEL_RICHANGACTIVITY});
        return true;
    elseif task.tType == TaskConst.Target.B_ZONGMEN_LILIAN then
    --完成宗门试炼x次（点击打开活动界面日常副本标签页）
        ModuleManager.SendNotification(ActivityNotes.OPEN_ACTIVITY, {type=ActivityNotes.PANEL_RICHANGFB});
        return true;
    elseif task.tType == TaskConst.Target.B_GUILD_JOIN then
    --加入仙盟（点击打开仙盟列表界面）
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_REQLIST_PANEL);
        return true;
    elseif task.tType == TaskConst.Target.B_EQUIP_REFINE then
    --装备精炼x级（点击打开装备精炼界面）
        ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_2);
        return true;
    elseif task.tType == TaskConst.Target.B_EQUIP_GEM then
    --镶嵌x颗宝石（点击打开宝石镶嵌界面）
        if TaskAuto.CheckGuide("GuideEquipInlay") then
            self:PlayGuide("GuideEquipInlay");
        else
            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_4);
        end
        return true;
    elseif task.tType == TaskConst.Target.B_REALM_UPGRADE then
    --境界提升x级（点击打开境界提升界面）
        ModuleManager.SendNotification(RealmNotes.OPEN_REALM);
        return true;
    elseif task.tType == TaskConst.Target.B_PET_FORMATION then
    --上阵x个伙伴（点击打开伙伴阵法界面）
        if TaskAuto.CheckGuide("GuidePetFormation") then
            self:PlayGuide("GuidePetFormation");    
        else
            ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL, 4);
        end        
        return true;
    elseif task.tType == TaskConst.Target.B_WINGS_UPGRADE then
    --翅膀升星x次（点击打开翅膀升星界面）
        ModuleManager.SendNotification(WingNotes.OPEN_WINGPANEL);
        return true;
    elseif task.tType == TaskConst.Target.B_REALM_COMPACT then
    --境界凝练x次（点击打开境界凝练界面）
        ModuleManager.SendNotification(RealmNotes.OPEN_REALM, 2);
        return true;
    elseif task.tType == TaskConst.Target.B_PET_RANDAPTITUDE then
    --宠物资质洗练
        ModuleManager.SendNotification(PetNotes.OPEN_PETPANEL);
        -- ModuleManager.SendNotification(PetNotes.OPEN_PETRANDAPTITUDEPANEL);
        return true;
    elseif task.tType == TaskConst.Target.B_XLT then
    --虚灵塔
        ModuleManager.SendNotification(XLTInstanceNotes.OPEN_XLTINSTANCE_PANEL);
        return true;
    elseif task.tType == TaskConst.Target.B_GOTO_INSTANCE then
    --非剧情副本, 包括竞技场
        local cfg = task:GetConfig();
        local p = cfg.target;
        --local instanceCfg = InstanceDataManager.GetMapCfById(tonumber(p[1]));
        local type = tonumber(p[1])
        if type == InstanceDataManager.InstanceType.PVPInstance and TaskAuto.CheckGuide("GuideArena") then
            self:PlayGuide("GuideArena");
        else
            InstanceDataManager.OpenFBUI(type);
        end
        return true;
    
    elseif task.tType == TaskConst.Target.B_MINGXING_EMBED then
        --镶嵌命星
        
        if TaskAuto.CheckGuide("GuideMingXing") then
            self:PlayGuide("GuideMingXing");    
        else
            ModuleManager.SendNotification(StarNotes.OPEN_STAR_PANEL);
        end
        return true;
    
    elseif task.tType == TaskConst.Target.B_WILDBOSS then
    --古魔来袭
        if TaskAuto.CheckGuide("GuideGuMoAttack") then
            self:PlayGuide("GuideGuMoAttack");    
        else
            ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSPANEL);
        end
        return true;
    elseif task.tType == TaskConst.Target.B_EQUIP_NEW_QH then
    --新装备强化
        if TaskAuto.CheckGuide("GuideEquipStrength") then
            self:PlayGuide("GuideEquipStrength");    
        else
            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_5);
        end
        return true;
    elseif task.tType == TaskConst.Target.B_ENDLESS_EXP then
    --无尽试炼经验
        SystemManager.Nav(152);
        return true;
    elseif task.tType == TaskConst.Target.B_EQUIP_GEM then
    --镶嵌x颗宝石（点击打开宝石镶嵌界面）
        if TaskAuto.CheckGuide("GuideEquipInlay") then
            self:PlayGuide("GuideEquipInlay");
        else
            ModuleManager.SendNotification(EquipNotes.OPEN_EQUIPMAINPANEL, EquipNotes.classify_4);
        end
        return true;
    end
    return false;
end

function TaskAuto.CheckGuide(seq)
    local heroInfo = PlayerManager.GetPlayerInfo();
    if seq == "" then
    --[[
    elseif seq == "GuideAutoFightSetting" then
        --引导自动战斗药物设置
        if AutoFightManager.use_Drug_HP_id and AutoFightManager.use_Drug_MP_id then
            return false;
        end
    ]]
    elseif seq == "GuidePet" then
        --引导伙伴出战
        if PetManager.IsPetFighting() or PetManager.HasPet() == false then
            return false;
        end
    elseif seq == "GuideEquip" then
        --引导装备强化
        for i = 1, 8 do
            local eqQhInfo = EquipLvDataManager.getItem(idx);
            if eqQhInfo and eqQhInfo.slv then
                return false;
            end
        end
    elseif seq == "GuideSkillUpgrade" then
        --引导技能升级
        local skills = heroInfo:GetSkills();
        for i, v in ipairs(skills) do
            if v.skill_lv > 1 then
                return false;
            end
        end
    elseif seq == "GuidePetLvUp" then
        --伙伴升级
        local pets = PetManager.GetAllPetData();
        for i, v in ipairs(pets) do
            if v.exp > 0 then
                return false;
            end
        end

    elseif seq == "GuidePetFormation" then
        --宠物法阵
        local pets = PetManager.GetFormationPets()
        if table.getCount(pets) > 0 then
            return false;
        end

    elseif seq == "GuideJoinGuild" then
        --加入仙盟
        if GuildDataManager.InGuild() then
            return false;
        end
    
    elseif seq == "GuideEquipInlay" then
        --装备镶嵌
        local gems = GemDataManager.data
        if (gems) then
            for i,v in pairs(gems) do
                if (v) then
                    for ii,vv in pairs(v) do  
                        if (vv and vv > 0) then
                            return false;
                        end
                    end
                end
            end
        end
    elseif seq == "GuideEquipStrength" then
        --新装备强化
        for i = 1, 8 do
            local v = NewEquipStrongManager.GetEquipStrongDataByIdx(i);
            if v.level > 1 then
                return false;
            end
        end
    elseif seq == "GuideMingXing" then

        local star = StarManager.GetDataBydIdx(0);
        if star ~= nil then
            return false;
        end
        
    end

    return true;
end