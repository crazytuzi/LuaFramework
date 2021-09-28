GuideEndnessInstance = class("GuideEndnessInstance", SequenceContent)

function GuideEndnessInstance.GetSteps()
    return {
    	--GuideEndnessInstance.A
        --,GuideContent.GuideActPanelEnd
		GuideEndnessInstance.B
		,GuideEndnessInstance.DelayForPanel
		,GuideEndnessInstance.C
		,GuideEndnessInstance.D
		,GuideEndnessInstance.E
        ,GuideEndnessInstance.F
        ,GuideContent.ForceEnd
    };
end

--点击右侧活动栏
function GuideEndnessInstance.A(seq)
	return GuideContent.GuideActPanelStart(seq, LanguageMgr.Get("guide/GuideEndnessInstance/1"));
end

--点击活动按钮
function GuideEndnessInstance.B(seq)
	local msg = LanguageMgr.Get("guide/GuideEndnessInstance/2");
    return GuideContent.GuideActItem(seq, msg, "72", "UI_ActivityPanel");
end

function GuideEndnessInstance.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_ActivityPanel");
end

--点击标签页
function GuideEndnessInstance.C(seq)
    
    if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideEndnessInstance/3");
    local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
    local btn = panel:GetTransformByPath("trsContent/trsToggle/btnRiChangFB");
    local anchor = panel:GetTransformByPath("trsContent/trsToggle/btnRiChangFB/Checkmark");
	local filter = function(index) return index == 2 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, filter);
	return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, anchor, wait, GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), true);
end

--点击无尽试练
function GuideEndnessInstance.D(seq)
	if seq.errorFlag then
		return nil;
	end
    local msg = LanguageMgr.Get("guide/GuideEndnessInstance/4");
    local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
    local btn = panel:GetTransformByPath("trsContent/mainView/RiChangFBPanel/ScrollView/bag_phalanx/page_0_0/18");
	local wait = SequenceCommand.UI.PanelOpened("UI_LSInstancePanel1");
    return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), true);
end

--点击挑战按钮
function GuideEndnessInstance.E(seq)
	if seq.errorFlag then
		return nil;
	end
    local msg = LanguageMgr.Get("guide/GuideEndnessInstance/5");
    local panel = PanelManager.GetPanelByType("UI_LSInstancePanel1");
    local btn = panel:GetTransformByPath("trsContent/mainView/bottomPanel/btnSangleTiaozhan");
	--local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ENDLESS_SINGLE_MATCH);
    local wait = SequenceCommand.UI.PanelOpened("UI_Confirm1Panel");
    return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.UP, Vector3.New(0, 50, 0), true);
end

function GuideEndnessInstance.F(seq)
    if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideEndnessInstance/6");
    local panel = PanelManager.GetPanelByType("UI_Confirm1Panel");
    local btn = panel:GetTransformByPath("trsContent/btn_ok");
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ENDLESS_SINGLE_MATCH);
    return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.UP, Vector3.New(0, 50, 0), true);
end