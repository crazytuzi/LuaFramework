require "Core.Module.Guide.Sequence.GuideSequence";
require "Core.Module.Guide.Sequence.GuideContent";
--require "Core.Module.Guide.Sequence.GuideTest";

require "Core.Module.Guide.Sequence.GuideArena";
require "Core.Module.Guide.Sequence.GuideAutoDrug"
require "Core.Module.Guide.Sequence.GuideAutoFightSetting";
require "Core.Module.Guide.Sequence.GuideAutoStrengthen";
require "Core.Module.Guide.Sequence.GuideEndnessInstance";
require "Core.Module.Guide.Sequence.GuideEquip";
require "Core.Module.Guide.Sequence.GuideEquipInlay";
require "Core.Module.Guide.Sequence.GuideEquipRefine";
require "Core.Module.Guide.Sequence.GuideEquipStrength";
require "Core.Module.Guide.Sequence.GuideEquipWear";
require "Core.Module.Guide.Sequence.GuideExpMount";
require "Core.Module.Guide.Sequence.GuideFirstCharge";
require "Core.Module.Guide.Sequence.GuideFirstChargeAlert";
require "Core.Module.Guide.Sequence.GuideGuildTask";
require "Core.Module.Guide.Sequence.GuideGuMoAttack";
require "Core.Module.Guide.Sequence.GuideJoinGuild";
require "Core.Module.Guide.Sequence.GuideLoopTack";
require "Core.Module.Guide.Sequence.GuideMingXing";
require "Core.Module.Guide.Sequence.GuideMountActivity";
require "Core.Module.Guide.Sequence.GuideNoviceCastTrumpSkill";
require "Core.Module.Guide.Sequence.GuideNoviceFight";
require "Core.Module.Guide.Sequence.GuideNoviceMove";
require "Core.Module.Guide.Sequence.GuideOfflineExp";
require "Core.Module.Guide.Sequence.GuideOfflineTips";
require "Core.Module.Guide.Sequence.GuidePet";
require "Core.Module.Guide.Sequence.GuidePetFormation";
require "Core.Module.Guide.Sequence.GuidePetLvUp";
require "Core.Module.Guide.Sequence.GuideRealmCompact";
require "Core.Module.Guide.Sequence.GuideRealmUpgrade";
require "Core.Module.Guide.Sequence.GuideRewardTask";
require "Core.Module.Guide.Sequence.GuideSevenDaySign";
require "Core.Module.Guide.Sequence.GuideSkillSetting";
require "Core.Module.Guide.Sequence.GuideSkillTalent";
require "Core.Module.Guide.Sequence.GuideSkillUpgrade";
require "Core.Module.Guide.Sequence.GuideTask";
require "Core.Module.Guide.Sequence.GuideTrumpActivity";
require "Core.Module.Guide.Sequence.GuideTrumpRefine";
require "Core.Module.Guide.Sequence.GuideWingUpgrade";
require "Core.Module.Guide.Sequence.GuideXuanBao";
require "Core.Module.Guide.Sequence.GuideZhenTu";
require "Core.Module.Guide.Sequence.GuideZongMenLiLian";
require "Core.Module.Guide.Sequence.GuideTaskTips";

GuideManager = { }

--需要在操作时标识完成的引导ID配置.
GuideManager.Id = {
    GuideAutoFightSetting = 3;
    GuideSkillUpgrade = 4;
    GuideTrumpActivity = 5;
    GuideTrumpRefine = 6;
    GuidePet = 7;
    GuidePetLvUp = 8;
    GuideSevenDaySign = 9;
    GuideEquip = 10;
    GuideLoopTack = 11;
    GuideZongMenLiLian = 12;
    GuideJoinGuild = 13;
    GuideSkillSetting = 14;
    GuideEquipRefine = 15;
    GuideGuildTask = 16;
    GuideMountActivity = 17;
    GuideEquipInlay = 19;
    GuideRealmUpgrade = 20;
    GuidePetFormation = 21;
    GuideWingUpgrade = 22;
    GuideRealmCompact = 23;
    GuideAutoDrug = 25;
    GuideOfflineTips = 36;
}

GuideManager.Novice = {
    "GuideNoviceMove",
    "GuideNoviceFight",
    "GuideNoviceCastTrumpSkill"
}

GuideManager.Type = {
    LEVEL = 1;
    TASK = 2;
}

--[[
    引导系统流程:
    完成的引导id保存至服务端.  升级,时
]]

--[[
GuideManager.Status = {
    1：获取，2开始，3：结束, 4中止
}
]]

GuideManager.list = {};
GuideManager.data = {};

GuideManager.isForceGuiding = false;    --是否强制引导
GuideManager.forceSysGo = nil;

GuideManager.currentId = 0;

local insert = table.insert
local allCfgs = nil;

function GuideManager.Init(data)

    GuideManager.toGuideSeq = nil;
    GuideManager.toManualSeq = nil;

    --初始化引导数据.
    GuideManager.data = {};
    for i, v in ipairs(data) do
        GuideManager.data[v.id] = v.st;
    end
    
    --根据分类构建需要开放引导的缓存.
    GuideManager.list = {};

    allCfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUIDE);
    for k, v in pairs(allCfgs) do
        --把所有未完成的引导加入缓存. 
        if v.openType > 0 and v.script ~= "" and GuideManager.GetGuideSt(k) < 3 then
            if GuideManager.list[v.openType] == nil then
                GuideManager.list[v.openType] = {};
            end
            insert(GuideManager.list[v.openType], v);
        end
    end

    
    if not GuideManager.initUpdate then
        UpdateBeat:Add(GuideManager.OnUpdate, nil)
        --UpdateBeat:Remove(GuideManager.OnUpdate, nil)
        GuideManager.initUpdate = true;
    end
    
    --GuideManager._SetTimer(0);

end

function GuideManager._StopTimer()
    if (GuideManager._timer) then
        GuideManager._timer:Stop();
        GuideManager._timer = nil;
    end
end

function GuideManager._SetTimer(duration)
    if (GuideManager._timer) then
        GuideManager._timer:Reset( function(val) GuideManager.OnUpdate(val) end, duration, -1, false);
    else
        GuideManager._timer = Timer.New( function(val) GuideManager.OnUpdate(val) end, duration, -1, false);
    end
    GuideManager._timer:Start();
end

--获取最后引导的id
function GuideManager.GetGuideSt(id)
    return GuideManager.data[id] or 0;
end

--设置最后引导的id
function GuideManager.SetGuideSt(id, st)
    --log("set status ---- > " .. id .. " = " .. st);
    GuideManager.data[id] = st;
    
    if st >= 3 then
        --把已结束的引导删掉.
        for k, v in pairs(GuideManager.list) do
            if #v >= 1 then
                for i = #v, 1 , -1 do
                    local cfg = v[i];
                    if cfg.id == id then
                        --log("remove ".. i .. " _ " .. id);
                        table.remove(v, i);
                    end
                end
            end
        end
    end
end

function GuideManager.Dispose()
    GuideManager._StopTimer();
end

function GuideManager.OnUpdate()
    if GuideManager.toGuideSeq and PanelManager.IsOnMainUI() then
        --log("开启等待中的引导 " .. GuideManager.toGuideSeq);
        GuideManager.Guide(GuideManager.toGuideSeq, GuideManager.toGuideParam, GuideManager.currentId);
    end

    --主界面显示的时候 开启手动触发的引导
    if GuideManager.toManualSeq and PanelManager.MainUIShow then
        local data = GuideManager.toManualSeq;
        GuideManager.Guide(data.seq, data.p, data.id);
        GuideManager.toManualSeq = nil;
    end
end

function GuideManager.OnMainUI()
    
end

function GuideManager.AddToGuide(seq, param, gid)
    --[[
    if GuideManager.CanGuide(seq) == false then
        log(seq .. " 引导条件已达成, 跳过引导.");
        GuideManager.Finish(param);
        return;
    end
    ]]
    Warning("GuideManager.AddToGuide - > " .. seq);
    GuideManager.toGuideSeq = seq;
    GuideManager.toGuideParam = param;
    GuideManager.currentId = gid or 0;
end


function GuideManager.Stop()

    GuideManager.isForceGuiding = false;
    GuideManager.forceSysGo = nil;
    
    GuideManager.toGuideSeq = nil;
    GuideManager.toGuideParam = nil;
    GuideManager.currentId = 0;

    GuideManager.toManualSeq = nil;

    if GuideManager.currentGuideName then
        SequenceManager.Stop(GuideManager.currentGuideName);
        GuideManager.currentGuideName = nil;
    end
    MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE,true);
    ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE);
end

function GuideManager.StopGuide(name)
    
    SequenceManager.Stop(name);

    if GuideManager.toGuideSeq and GuideManager.toGuideSeq.name == name then
        GuideManager.toGuideSeq = nil;
        GuideManager.toGuideParam = nil;
        GuideManager.currentId = 0;
    end

    if GuideManager.toManualSeq and GuideManager.toManualSeq.seq == name then
        GuideManager.toManualSeq = nil;
    end

    if GuideManager.currentGuideName == name then
        GuideManager.isForceGuiding = false;
        GuideManager.forceSysGo = nil;
        GuideManager.currentGuideName = nil;
        MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE,true);
        ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE);
    end
end

function GuideManager.Guide(gSeq, data, gid)
    
    GuideManager.Stop();

    --只能存字符串. 不能存引用(引用不会销毁)
    local seq = SequenceManager.Play(gSeq, data, GuideSequence);
    GuideManager.currentGuideName = seq.name;

    GuideManager.toGuideSeq = nil;
    GuideManager.toGuideParam = nil;
    GuideManager.currentId = gid or 0;

    return seq;
end

function GuideManager.GuideNovice(step)
    local gSeq = GuideManager.Novice[step];
    if (gSeq ~= nil) then
        GuideManager.Guide(gSeq);
    end
end

--根据条件检查是否需要引导.
function GuideManager.Check(cType, param)
    local list = GuideManager.list[cType];
    if list then
        for i, v in ipairs(list) do
            if param == v.openVal then
                if GuideManager.GetGuideSt(k) < 3 then
                    if GuideManager.CanGuide(v.script) then
                        log(v.script .. " 符合条件 开启引导.");
                        GuideManager.AddToGuide(v.script, v, v.id);
                    else
                        log(v.script .. " 引导条件已达成, 跳过引导.");
                        GuideProxy.ReqFinish(v.id);
                    end
                end
            end
        end
    end
end

--重新激活所有符合条件, 又未完成的引导.
function GuideManager.CheckAll()
    local openId = 0; --当前需要重新激活的id 
    local roleLv = NoviceManager.oldLevel or PlayerManager.hero.info.level;
    local taskId = TaskManager.GetMainTaskId();
    for k, v in pairs(allCfgs) do
        if v.reOpen and v.openType > 0 and v.script ~= "" and GuideManager.GetGuideSt(k) < 3 and GuideManager.CanGuide(v.script) then
            if v.openType == GuideManager.Type.LEVEL then
                if v.openVal <= roleLv then
                    openId = v.id;
                end
            elseif v.openType == GuideManager.Type.TASK then
                if v.openVal <= taskId then
                    openId = v.id;
                end
            end
        end
    end
    --初始化时找回最后一个可开启的引导
    if openId ~= 0 then
        log("重新激活未完成的引导id -> " .. openId);
        GuideManager.ManualGuide(openId);
    end
end

--手动激发引导 force: 强制打开引导，无视界面遮挡
function GuideManager.ManualGuide(id, force)
    local cfg = allCfgs[id];
    if force then
        --防止界面在loading时 触发引导
        if PanelManager.MainUIShow then
            GuideManager.Guide(cfg.script, cfg, id);
        else
            GuideManager.toManualSeq = {seq = cfg.script, p = cfg, id = id};    
        end
    else
        GuideManager.AddToGuide(cfg.script, cfg, cfg.id);
    end
end

function GuideManager.Start(data)
    if data and data.__cname ~= "TaskInfo" and GuideManager.GetGuideSt(data.id) < 1 then
        GuideProxy.ReqNew(data.id);
    end
end

function GuideManager.Doing(data) 
    if data and data.__cname ~= "TaskInfo" and GuideManager.GetGuideSt(data.id) < 2 then
        GuideProxy.ReqDo(data.id);
    end
end

function GuideManager.Finish(data)
    if data then
        if data.__cname == "TaskInfo" then
            TaskAuto.GuideTaskFinish(data);
        elseif GuideManager.GetGuideSt(data.id) < 3 then
            GuideProxy.ReqFinish(data.id);
        end
    end
end

function GuideManager.Error(data)
    if data then
        GuideProxy.ReqFinish(data.id);
    end
end

function GuideManager.IsGuiding()
    if GuideManager.currentGuideName then 
        return SequenceManager.GetInstance(GuideManager.currentGuideName) ~= nil;
    end
    return false;
end


local equipIds = {[101000] = 301410; [102000] = 302410; [103000] = 303410; [104000] = 304410}
--引导条件判断.
function GuideManager.CanGuide(seq)
    local heroInfo = PlayerManager.GetPlayerInfo();
    if seq == "" then
    
    
    
    elseif seq == "GuideSevenDaySign" then
        --七天签到
        if Login7RewardManager.GetHasGetAward() then
            return false;
        end
    
    
    elseif seq == "GuideMountActivity" then
        --坐骑激活
        if RideManager.GetIsRideUse() then
            return false;
        end
    --elseif seq == "GuideSkillSetting" then
        --技能配置
    --elseif seq == "GuideSkillTalent" then
        --技能天赋
    elseif seq == "GuideTrumpActivity" then
        --法宝激活
        if NewTrumpManager.IsTrumpDress() then
            return false;
        end
    elseif seq == "GuideTrumpRefine" then
        --法宝精炼
        if NewTrumpManager.IsTrumpHadRefine() then
            return false;
        end
    elseif seq == "GuideWingUpgrade" then
        --翅膀升级
        if WingManager.GetCurrentWingStar() > 1 then
            return false;
        end
    elseif seq == "GuideZongMenLiLian" then
        if TeamMatchDataManager.ZongMengLiLian_is_pipei_ing() then
            return false;
        end
    elseif seq == "GuideRealmUpgrade" then
        --境界
        if RealmManager.GetRealmLevel() > 0 then
            return false;
        end
    elseif seq == "GuideRealmCompact" then
        --凝练
        if RealmManager.GetCompactLevel() > 0 then
            return false;
        end
    
    elseif seq == "GuideLoopTack" then
        --循环任务
        local tasks = TaskManager.GetAllTask()
        if (tasks) then
            for i,v in pairs(tasks) do
                if (v.type == 2) then
                    return false;
                end
            end
        end
    
    elseif seq == "GuideEquip" then
        --装备附灵
        local equips = EquipLvDataManager.GetEquip_lv();
        if (equips) then
            for i,v in pairs(equips) do
                if (v and v.slv > 0) then
                    return false;
                end
            end
        end

    elseif seq == "GuideEquipRefine" then
        --装备精炼
        local equips = EquipLvDataManager.GetEquip_lv();
        if (equips) then
            for i,v in pairs(equips) do
                if (v and v.rlv > 0) then
                    return false;
                end
            end
        end

    elseif seq == "GuideAutoStrengthen" then
        --自动强化
        local kind = AutoFightManager.strengthen_eq_kind;
        if kind then
            return false;
        end

    elseif seq == "GuideEquipWear" then
        
        local kind = PlayerManager.GetPlayerKind();
        local tmpId = equipIds[kind];
        local item = BackpackDataManager.GetProductBySpid(tmpId);
        local eq = EquipDataManager.GetProductByKind(1);
        if eq and item and eq:GetFight() >= item:GetFight() then
            return false;
        end

    elseif seq == "GuideExpMount" then

        if RideManager.GetIsRideUse() then
            return false;
        end

    elseif seq == "GuideRewardTask" then

        if TaskManager.data.rewardNum > 9 then
            return false;
        end

        local list = TaskManager.GetRewardList();
        --for i, v in ipairs(list) do

        --end
        if list[1] and list[1].status == TaskConst.Status.IMPLEMENTATION then
            return false;
        end
    elseif seq == "GuideMingXing" then

        local star = StarManager.GetDataBydIdx(0);
        if star ~= nil then
            return false;
        end
    elseif seq == "GuideJoinGuild" then

        if GuildDataManager.InGuild() then
            return false;
        end
    end
    return true;
end

function GuideManager.OptSetStatus(id)
    if GuideManager.GetGuideSt(id) < 3 then
        GuideProxy.ReqFinish(id);
    end
end

