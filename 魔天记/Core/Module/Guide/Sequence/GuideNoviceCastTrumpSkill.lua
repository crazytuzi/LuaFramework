GuideNoviceCastTrumpSkill = class("GuideNoviceCastTrumpSkill", SequenceContent)

function GuideNoviceCastTrumpSkill.GetSteps()
    return {
        GuideNoviceCastTrumpSkill.A0
        ,GuideNoviceCastTrumpSkill.A
        ,GuideNoviceCastTrumpSkill.B
    };
end

function GuideNoviceCastTrumpSkill.A0(seq)    
      return SequenceCommand.Delay(0.8)
end

--释放法宝技能
function GuideNoviceCastTrumpSkill.A(seq)	

	if seq:GetCache("guideCastTrump1") == nil then
		local msg = LanguageMgr.Get("guide/GuideNoviceOperation/6");
		local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
		local frameGo = panel:GetTransformByPath("UI_CastSkillPanel/trsContent/btnSkill5");
		local effect = GuideTools.AddEffectAndTitleToGameObject(frameGo, "ui_guide_1", msg, GuideTools.Pos.LEFT, Vector3.New(-100, 0, 0), 1);
		seq:AddToCache("guideCastTrump1", effect);
	end
	seq:SetCacheDisplay("guideCastTrump1");

	local filter = function(id) return id == 212050 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Base.MANUALLY_SKILL, nil, filter);

	return wait;
end


function GuideNoviceCastTrumpSkill.B(seq)
	--ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	GuideManager.StopGuide("GuideNoviceCastTrumpSkill");
	return nil;
end