GuideSkillUpgrade = class("GuideSkillUpgrade", SequenceContent)

function GuideSkillUpgrade.GetSteps()
    return {
		GuideSkillUpgrade.A
      	,GuideContent.GuideSysPanelEnd
      	,GuideSkillUpgrade.C
      	,GuideSkillUpgrade.DelayForPanel
      	,GuideSkillUpgrade.D
      	,GuideSkillUpgrade.E
      	,GuideSkillUpgrade.F
    };
end


function GuideSkillUpgrade.A(seq)
	return GuideContent.GuideSysPanelStart(seq, LanguageMgr.Get("guide/skillUpgrade/1"));
end

--打开技能界面
function GuideSkillUpgrade.C(seq)
	local msg = LanguageMgr.Get("guide/skillUpgrade/2");
	return GuideContent.GuideSysItem(seq, msg, "3", "UI_SkillPanel");
end

function GuideSkillUpgrade.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_SkillPanel");
end

--点击升级按钮
function GuideSkillUpgrade.D(seq)
	local msg = LanguageMgr.Get("guide/skillUpgrade/4");
	local panel = PanelManager.GetPanelByType("UI_SkillPanel");
	local btn = panel:GetTransformByPath("trsContent/panels/upgradePanel/btnUpgrade").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_UPGRADE);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-120, 6, 0), true);
end

function GuideSkillUpgrade.E(seq)
	local msg = LanguageMgr.Get("guide/skillUpgrade/5");
	local panel = PanelManager.GetPanelByType("UI_SkillPanel");
	local btn = panel:GetTransformByPath("trsContent/btnClose").gameObject;
	local wait = SequenceCommand.UI.CloseBtnClick("UI_SkillPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0), true);
end

function GuideSkillUpgrade.F(seq)
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return nil;
end