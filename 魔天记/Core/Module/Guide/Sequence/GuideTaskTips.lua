GuideTaskTips = class("GuideTaskTips", SequenceContent)

function GuideTaskTips.GetSteps()
    return {
      	GuideTaskTips.A
      	,GuideTaskTips.B
    };
end

local panelName = "UI_MainUIPanel";

--引导自动任务
function GuideTaskTips.A(seq)

	if seq:GetCache("GuideTaskTips") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
		local item = panel:GetTransformByPath("UI_PartyAndTaskPanel/trsContent/taskPanel/trsList/scrollView/Table/840080");
		--local item = GuideTools.GetChildByIndex(list, 1);
		if item == nil then
            seq:SetError("can't find task - 840080");
            return nil;
        end

        local effect = GuideTools.AddEffectAndTitleToGameObject(item, nil, LanguageMgr.Get("guide/GuideTaskTips/1"), GuideTools.Pos.RIGHT, Vector3.New(260, 0, 0));
        seq:AddToCache("GuideTaskTips", effect);
    end
    seq:SetCacheDisplay("GuideTaskTips");

    return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_TASK_AUTO, nil, function(id) return id == 840080 end);
end

function GuideTaskTips.B(seq)
	if seq.errorFlag then
        return nil;
    end

	return nil;
end