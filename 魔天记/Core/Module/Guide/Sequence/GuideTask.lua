GuideTask = class("GuideTask", SequenceContent)

function GuideTask.GetSteps()
    return {
      	GuideTask.A
      	,GuideTask.B
      	,GuideTask.C
    };
end

--引导自动任务
function GuideTask.A(seq)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local msg = LanguageMgr.Get("guide/task/1");
	local list = panel:GetTransformByPath("UI_PartyAndTaskPanel/trsContent/taskPanel/trsList/scrollView/Table");
	local item = GuideTools.GetChildByIndex(list, 1);
	local itemHolder = UIUtil.GetChildByName(item, "Transform", "tipsHolder");
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_TASK_AUTO);
	return SequenceCommand.Guide.GuideClickUI(msg, item.gameObject, itemHolder, wait, GuideTools.Pos.RIGHT, Vector3.New(140, 0, 0), true);
end

--关闭引导
function GuideTask.B(seq)
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return SequenceCommand.Delay(0.2);
end

--延迟上报完成引导.
function GuideTask.C(seq)
	return nil;
end