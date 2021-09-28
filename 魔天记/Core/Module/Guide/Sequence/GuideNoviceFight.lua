GuideNoviceFight = class("GuideNoviceFight", SequenceContent)

function GuideNoviceFight.GetSteps()
    return {
        GuideNoviceFight.A
      	,GuideNoviceFight.A0
        ,GuideNoviceFight.A1
        ,GuideNoviceFight.A2
        ,GuideNoviceFight.A3
--        ,GuideNoviceFight.B
--        ,GuideNoviceFight.C
        ,GuideNoviceFight.D
        ,GuideNoviceFight.E
    };
end

function GuideNoviceFight.A(seq)   
    local hero = PlayerManager.hero;     
    hero:StopAction(3);
    hero:Stand();
    return nil;
end

--选目标
function GuideNoviceFight.A0(seq)    
    local map = GameSceneManager.map;
    if (map) then
        local hero = PlayerManager.hero; 
        local target = GameSceneManager.map:GetCanAttackTarget(hero.info.camp, hero:GetPos(), 20, 0, nil, 1, false, true);
        if (target and target.transform) then            
            local msg = LanguageMgr.Get("guide/GuideNoviceOperation/2");
            local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.NOVICE_OPERATION_SELECT_TARGET, nil, nil);         
            return SequenceCommand.Guide.GuideSelectRoleUI(msg, target, wait, GuideTools.Pos.DOWN, Vector3.New(0, -120, 0), true, false);
        else
            MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE,false);
            seq:SkipAfterStep(GuideNoviceFight.A1);
        end
    end
	return nil;
end

function GuideNoviceFight.A1(seq)    
      seq:SkipAfterStep(GuideNoviceFight.A3);
end

function GuideNoviceFight.A2(seq)    
      return SequenceCommand.Delay(0.1)
end

function GuideNoviceFight.A3(seq)    
    seq:SkipAfterStep(GuideNoviceFight.A);
end

--[[
--攻击
function GuideNoviceFight.B(seq)
	local msg = LanguageMgr.Get("guide/GuideNoviceOperation/3");
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local frameGo = panel:GetTransformByPath("UI_CastSkillPanel/trsContent/btnAttack").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.NOVICE_OPERATION_ATTACK, nil, nil);  
    MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE,true);  
	return SequenceCommand.Guide.GuideClickUI(msg, frameGo, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-100, 0, 0), true);
end

--多次攻击提示
function GuideNoviceFight.C(seq)
    --MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("guide/GuideNoviceFight/4"));
    local msg = LanguageMgr.Get("guide/GuideNoviceOperation/4");
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local frameGo = panel:GetTransformByPath("UI_CastSkillPanel/trsContent/btnAttack").gameObject;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.NOVICE_OPERATION_ATTACK_COMPLETE, nil, nil);
    return SequenceCommand.Guide.GuideClickUI(msg, frameGo, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-100, 0, 0), true);
end
]]

--释放技能
function GuideNoviceFight.D(seq)	
	local msg = LanguageMgr.Get("guide/GuideNoviceOperation/5");
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local frameGo = panel:GetTransformByPath("UI_CastSkillPanel/trsContent/btnSkill1").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.NOVICE_OPERATION_SKILL, nil, nil);
	return SequenceCommand.Guide.GuideClickUI(msg, frameGo, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-100, 0, 0), true, nil, false);
end


function GuideNoviceFight.E(seq)
    MessageManager.Dispatch(MainUINotes, MainUINotes.OPERATE_ENABLE,true);
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return nil;
end