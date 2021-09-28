GuideOfflineTips = class("GuideOfflineTips", SequenceContent);

function GuideOfflineTips.GetSteps()
    return {
      	GuideOfflineTips.A
      	--,GuideOfflineTips.B
      	,GuideOfflineTips.C
      	,GuideContent.ForceEnd
    };
end

local panelName = "UI_OffLinePanel";

function GuideOfflineTips.A(seq)
	local msg = LanguageMgr.Get("guide/GuideOfflineTips/1");
	local panel = PanelManager.GetPanelByType(panelName);
	local txtGo = panel:GetTransformByPath("trsContent/txtExp").gameObject;
    local aTr = panel:GetTransformByPath("trsContent/trsHolder");
    local wait = SequenceCommand.Guide.GuideClickBlank;
    return SequenceCommand.Guide.GuideClickUI(msg, txtGo, aTr, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end

function GuideOfflineTips.C(seq)
	local msg = LanguageMgr.Get("guide/GuideOfflineTips/2");
	local panel = PanelManager.GetPanelByType(panelName);
	local btnGo = panel:GetTransformByPath("trsContent/btnCancel").gameObject;

    local wait = SequenceCommand.UI.PanelClosed(panelName);
    return SequenceCommand.Guide.GuideClickUI(msg, btnGo, nil, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end

