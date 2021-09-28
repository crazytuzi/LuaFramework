require "Core.Module.Guide.Sequence.Item.GuideSceneEffect";

GuideNoviceMove = class("GuideNoviceMove", SequenceContent)

GuideNoviceMove.EffectPos = Vector3.New(15.74, 0, -33.44)
GuideNoviceMove.MoveEnd = {w = 10, h = 3, r = 0 / 180 * math.pi}

function GuideNoviceMove.GetSteps()
    return {
        GuideNoviceMove.A0
        ,GuideNoviceMove.A
        ,GuideNoviceMove.B
        ,GuideNoviceMove.B1
        ,GuideNoviceMove.C
        ,GuideNoviceMove.D
        ,GuideNoviceMove.E        
    };
end

function GuideNoviceMove.A0(seq)    
      return SequenceCommand.Delay(0.8)
end

function GuideNoviceMove.A(seq)    
    local posEff = GuideSceneEffect.New("Effect/UIEffect", "ui_guide_2");
    --local posEff2 = GuideSceneEffect.New("Effect/UIEffect", "ui_guide_2");
    posEff:SetPos(GuideNoviceMove.EffectPos); 
    --posEff2:SetPos(GuideNoviceMove.EffectPos); 
    GuideNoviceMove.EndRect = {};
    GuideNoviceMove.EndRect.xMin = GuideNoviceMove.EffectPos.x - GuideNoviceMove.MoveEnd.h / 2;
    GuideNoviceMove.EndRect.xMax = GuideNoviceMove.EffectPos.x + GuideNoviceMove.MoveEnd.h / 2;
    GuideNoviceMove.EndRect.zMin = GuideNoviceMove.EffectPos.z - GuideNoviceMove.MoveEnd.w / 2;
    GuideNoviceMove.EndRect.zMax = GuideNoviceMove.EffectPos.z + GuideNoviceMove.MoveEnd.w / 2;
    --posEff:SetPos(Vector3.New(0, 0, 0)); 
    seq:AddToCache("posEff", posEff)
    --seq:AddToCache("posEff2", posEff2)
end

-- 移动
function GuideNoviceMove.B(seq)    
    local msg = LanguageMgr.Get("guide/GuideNoviceOperation/1");
    local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
    local frameGo = panel:GetTransformByPath("UI_JoystickPanel/trsContent/imgJoystick").gameObject;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.NOVICE_OPERATION_MOVE_START, nil, nil);    
    return SequenceCommand.Guide.GuideClickUI(msg, frameGo, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(193 + 100, 181, 0), true, Vector3.New(193, 181, 0),false, 0.01);
end

function GuideNoviceMove.B1(seq)    
    ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
    return nil
end

function GuideNoviceMove.C(seq)
    local wait = SequenceCommand.Delay(0.1);
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.NOVICE_OPERATION_MOVE_END, nil, nil,
    function()
        seq:SkipAfterStep(GuideNoviceMove.B);
    end ));
   return wait;
end

--60
--1
--10

function GuideNoviceMove.D(seq)    
    local posEff = seq:GetCache("posEff");
    --local posEff2 = seq:GetCache("posEff2");
    if (posEff and posEff.transform) then
        local heroPos = PlayerManager.hero.transform.position;
        local effPos = GuideNoviceMove.EffectPos;
        local d = Vector3.Distance2(effPos,heroPos);
        local r = math.atan2(heroPos.x - effPos.x, heroPos.z - effPos.z) - GuideNoviceMove.MoveEnd.r;
        local tx = effPos.x + math.sin(r) * d;
        local tz = effPos.z + math.cos(r) * d;
        --posEff2.transform.position = Vector3.New(tx,posEff2.transform.position.y,tz);
        if (tx >= GuideNoviceMove.EndRect.xMin and tx <= GuideNoviceMove.EndRect.xMax and tz >= GuideNoviceMove.EndRect.zMin and tz <= GuideNoviceMove.EndRect.zMax) then
        --if (d <= 1) then
            seq:SkipAfterStep(GuideNoviceMove.D);            
        else
            seq:SkipAfterStep(GuideNoviceMove.B);
        end
    else
        seq:SkipAfterStep(GuideNoviceMove.D);
    end
end

function GuideNoviceMove.E(seq)    
    ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
    return nil;
end