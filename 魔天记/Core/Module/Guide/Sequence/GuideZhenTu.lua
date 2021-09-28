GuideZhenTu = class("GuideZhenTu", SequenceContent)

local panelName = "UI_RolePanel";
function GuideZhenTu.GetSteps()
    return {
    	GuideZhenTu.A
		,GuideContent.GuideSysPanelEnd
		,GuideZhenTu.B
		,GuideZhenTu.DelayForPanel
		,GuideZhenTu.C
		,GuideZhenTu.D
		,GuideZhenTu.E
		,GuideContent.ForceEnd
    }
end

function GuideZhenTu.A(seq)
	return GuideContent.GuideSysPanelStart(seq, LanguageMgr.Get("guide/GuideZhenTu/1"), true);
end

function GuideZhenTu.B(seq)
	local msg = LanguageMgr.Get("guide/GuideZhenTu/2");
	return GuideContent.GuideSysItem(seq, msg, "1", panelName);
end

function GuideZhenTu.DelayForPanel(seq)
	return SequenceCommand.UI.PanelOpened(panelName);
end

function GuideZhenTu.C(seq)
	if seq.errorFlag then
        return nil;
    end
	local msg = LanguageMgr.Get("guide/GuideZhenTu/3");
	local panel = PanelManager.GetPanelByType(panelName);
	local btn = panel:GetTransformByPath("trsContent/btnArtifact").gameObject;
	local atr = panel:GetTransformByPath("trsContent/btnArtifact/tltle");
	local filter = function(index) return index == 4 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ROLE_TAB, nil, filter);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, atr, wait, GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), true);
end

function GuideZhenTu.D(seq)
	if seq.errorFlag then
        return nil;
    end
	local msg = LanguageMgr.Get("guide/GuideZhenTu/4");
	local panel = PanelManager.GetPanelByType(panelName);
	local btn = panel:GetTransformByPath("trsContent/UI_ArtifactPanel/levels/item1").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ZHENTU_SELECT);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(40, 0, 0), true);
end

function GuideZhenTu.E(seq)
	if seq.errorFlag then
        return nil;
    end
	local msg = LanguageMgr.Get("guide/GuideZhenTu/5");
	local panel = PanelManager.GetPanelByType(panelName);
	local btn = panel:GetTransformByPath("trsContent/UI_ArtifactPanel/trsGrade/product1").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ZHENTU_TISHENG);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.TOP_LEFT, Vector3.New(0, 45, 0), true);
end
