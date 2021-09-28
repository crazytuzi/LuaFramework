GuideRewardTask = class("GuideRewardTask", SequenceContent);

function GuideRewardTask.GetSteps()
	return {
		--GuideRewardTask.A
		--,GuideContent.GuideSysPanelEnd
		GuideRewardTask.B
		,GuideRewardTask.DelayForPanel
		,GuideRewardTask.C
		--,GuideRewardTask.D
		--,GuideRewardTask.D2
		--,GuideRewardTask.E
		,GuideContent.ForceEnd
	}
end

function GuideRewardTask.A(seq)
	return GuideContent.GuideActPanelStart(seq, LanguageMgr.Get("guide/GuideRewardTask/1"));
end

function GuideRewardTask.B(seq)
	if seq.errorFlag then
        return nil;
    end
	local msg = LanguageMgr.Get("guide/GuideRewardTask/2");
	return GuideContent.GuideActItem(seq, msg, "72", "UI_ActivityPanel");
end

function GuideRewardTask.DelayForPanel(seq)
	return SequenceCommand.UI.PanelOpened("UI_ActivityPanel");
end

--点击悬赏任务
function GuideRewardTask.C(seq)
	if seq.errorFlag then
        return nil;
    end
    local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
    if panel == nil then
        seq:SetError();
        return nil;
    end
    local msg = LanguageMgr.Get("guide/GuideRewardTask/3");
    local btn = panel:GetTransformByPath("trsContent/mainView/RiChangActivityPanel/ScrollView/bag_phalanx/page_0_0/1/doBt");
    local wait = SequenceCommand.UI.PanelOpened("UI_RewardTaskPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.TOP_RIGHT, Vector3.New(0, 45, 0), true);
end

--点击接取
function GuideRewardTask.D(seq)
	if seq.errorFlag then
        return nil;
    end
    local panel = PanelManager.GetPanelByType("UI_RewardTaskPanel");
    if panel == nil then
        seq:SetError();
        return nil;
    end
    local msg = LanguageMgr.Get("guide/GuideRewardTask/4");
    local tr = panel:GetTransformByPath("trsContent/taskListView/task_phalanx");
    local btn = tr:GetChild(1);
    btn = btn:Find("btnAcc");
    
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.REWARD_TASK_ACC);
	return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45, 0), true);
end

--等待刷新
function GuideRewardTask.D2(seq)
	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.REWARD_TASK_UPDATE);
end

--点击前往
function GuideRewardTask.E(seq)
	if seq.errorFlag then
        return nil;
    end
    local panel = PanelManager.GetPanelByType("UI_RewardTaskPanel");
    if panel == nil then
        seq:SetError();
        return nil;
    end
    local msg = LanguageMgr.Get("guide/GuideRewardTask/5");
    local tr = panel:GetTransformByPath("trsContent/taskListView/task_phalanx");
    local btn = tr:GetChild(1);
    btn = btn:Find("btnCancel");
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.REWARD_TASK_GO);
	return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45, 0), true);
end
