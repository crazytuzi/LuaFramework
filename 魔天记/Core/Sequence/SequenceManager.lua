require "Core.Sequence.SequencePool";
require "Core.Sequence.SequenceInstance";
require "Core.Sequence.SequenceContent";
require "Core.Sequence.SequenceTrigger";
require "Core.Sequence.SequenceEvent";
require "Core.Sequence.SequenceCommand";

SequenceManager = class("SequenceManager");
SequenceManager._seqs = { };

SequenceManager.DEBUG = false;

function SequenceManager.Init()
    SequenceManager._SetTimer(0);
    if SequenceManager.DEBUG and SequenceManager.debugGo == nil then
        SequenceManager.debugGo = GameObject.New("SequenceManager");
        SequenceManager.debugGo:DontDestroyOnLoad();
    end
end


function SequenceManager.Dispose()
    SequenceManager._StopTimer();
end

function SequenceManager._SetTimer(duration)
    if (SequenceManager._timer) then
        SequenceManager._timer:Reset( function(val) SequenceManager._Update(val) end, duration, -1, false);
    else
        SequenceManager._timer = Timer.New( function(val) SequenceManager._Update(val) end, duration, -1, false);
    end
    SequenceManager._timer:Start();
end

function SequenceManager._StopTimer()
    if (SequenceManager._timer) then
        SequenceManager._timer:Stop();
        SequenceManager._timer = nil;
    end
end

function SequenceManager._Update()
    for k, v in pairs(SequenceManager._seqs) do
        v:UpdateSequence();
    end
end

-- 判断某个seq脚本是否正在运行
function SequenceManager.IsPlaying(seqName)
    local seq = SequenceManager.GetInstance(seqName);
    if seq == nil then
        return false;
    end
    return true;
    -- 同名根据Test方法进行判断
    -- return seq:Test(param);
end

function SequenceManager.GetInstance(seqName)
    return SequenceManager._seqs[seqName];
end

function SequenceManager.Create(seqName, param, instClass)
    instClass = instClass or SequenceInstance;
    local seq = instClass.New(seqName, param);
    return seq;
end

--[[
    执行Seq脚本命令.
    seqName 脚本名
    param 脚本参数
    instClass 脚本类别
]]
function SequenceManager.Play(seqName, param, instClass)
    local seq = SequenceManager.GetInstance(seqName);
    if (seq == nil) then
        seq = SequenceManager.Create(seqName, param, instClass);
        SequenceManager._seqs[seqName] = seq;

        if SequenceManager.DEBUG then
            seq.gameObject = NGUITools.AddChild(SequenceManager.debugGo);
            seq.gameObject.name = seqName;
            seq.stepGo = NGUITools.AddChild(seq.gameObject);
        end
    else
        seq:UpdateParam(param);
    end

    seq:Start();
    return seq;
end

function SequenceManager.ReStart(seqName)
    local seq = SequenceManager.GetInstance(seqName);
    if seq then
        seq:Start();
    end
end

function SequenceManager.TriggerEvent(eType, args)
    -- 触发器
    TriggerManager.TriggerEvent(eType, args);
    -- 任务自动控制器
    TaskManager.TriggerEvent(eType, args);
    -- 序列控制器
    for k, v in pairs(SequenceManager._seqs) do
        v:TriggerEvent(eType, args);
    end
end

function SequenceManager.Stop(seqName)

    local inst = SequenceManager.GetInstance(seqName);
    if inst then
        if SequenceManager.DEBUG then
            local go = inst.gameObject;
            NGUITools.Destroy(go);
        end

        inst:Dispose();
        inst = nil;
        SequenceManager._seqs[seqName] = nil;
    end

end

function SequenceManager.StopAll()
    for k, v in pairs(SequenceManager._seqs) do
        SequenceManager.Stop(k);
    end

    --[[
    for k,v in pairs(SequenceManager._seqs) do
        v:Dispose();
        v = nil;
        SequenceManager._seqs[k] = nil;
    end

    if SequenceManager.DEBUG then
        local transform = SequenceManager.debugGo.transform;
        if transform.childCount > 0 then
            while transform.childCount > 0 do
                local go = transform:GetChild(0).gameObject;
                go:SetActive(false);
                NGUITools.Destroy(go);
            end
        end
    end
    ]]
end

function SequenceManager.Skip()
    -- todo
end

function SequenceManager.Getfunctionlocation()
    local w = debug.getinfo(2, "S")
    return w.short_src .. ":" .. w.linedefined
end

