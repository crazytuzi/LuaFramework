GuideOfflineExp = class("GuideOfflineExp", SequenceContent);

function GuideOfflineExp.GetSteps()
    return {
      	--GuideOfflineExp.A
      	--,GuideContent.GuideActPanelEnd
      	GuideOfflineExp.B
      	,GuideOfflineExp.B1
      	,GuideOfflineExp.C
      	,GuideOfflineExp.D
      	,GuideOfflineExp.E
      	,GuideOfflineExp.F
      	,GuideContent.ForceEnd
    };
end

function GuideOfflineExp.A(seq)
	return GuideContent.GuideActPanelStart(seq, LanguageMgr.Get("guide/GuideOfflineExp/1"));
end

function GuideOfflineExp.B(seq)
	local msg = LanguageMgr.Get("guide/GuideOfflineExp/2");
	return GuideContent.GuideActItem(seq, msg, "72", "UI_ActivityPanel");
end

function GuideOfflineExp.B1(seq)
	return SequenceCommand.UI.PanelOpened("UI_ActivityPanel");
end

function GuideOfflineExp.C(seq)
	if seq.errorFlag then
        return nil;
    end

	local msg = LanguageMgr.Get("guide/GuideOfflineExp/3");
	local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
	local txtGo = panel:GetTransformByPath("trsContent/txtOffLine").gameObject;

    local wait = SequenceCommand.Delay(0.5);
    return SequenceCommand.Guide.GuideClickUI(msg, txtGo, nil, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end

function GuideOfflineExp.D(seq)
	if seq.errorFlag then
        return nil;
    end

    return SequenceCommand.Guide.GuideClickBlank;
end

function GuideOfflineExp.E(seq)
	if seq.errorFlag then
        return nil;
    end

    if not MessageProxy.HasOffLineItem() then
    	seq:SetError("没有离线经验物品");
		return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideOfflineExp/4");
	local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
	local btn = panel:GetTransformByPath("trsContent/btnOffLine").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ACTIVITY_OFFLINE_BTN);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end

function GuideOfflineExp.F(seq)
	if seq.errorFlag then
        return nil;
    end

    local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
    if panel == nil then
		seq:SetError();
		return nil;
	end

	local trsBtn = panel:GetTransformByPath("trsContent/btn_close");
	local msg = LanguageMgr.Get("guide/GuideOfflineExp/5");

	local filter = function(name) return name == "UI_ActivityPanel" end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter);
	return SequenceCommand.Guide.GuideClickUI(msg, trsBtn.gameObject, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0), true);
end

