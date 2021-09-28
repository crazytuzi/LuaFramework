GuideGuildTask = class("GuideGuildTask", SequenceContent)

function GuideGuildTask.GetSteps()
    return {
    	GuideGuildTask.A
      	,GuideContent.OpenActPanelEnd
      	,GuideGuildTask.B
        ,GuideGuildTask.DelayForPanel
        ,GuideGuildTask.C
		,GuideGuildTask.D
		,GuideGuildTask.E
		,GuideGuildTask.F
		,GuideGuildTask.F1
		,GuideGuildTask.G
    };
end

function GuideGuildTask.ReturnA(seq)
	seq:RemoveCache("GuideGuildTask3");
	seq:RemoveCache("GuideGuildTask4");
	seq:RemoveCache("GuideGuildTask5");
	seq:SkipAfterStep(GuideGuildTask.A);
end

--点击右侧活动栏
function GuideGuildTask.A(seq)
	local msg = LanguageMgr.Get("guide/guildTask/1");
	return GuideContent.OpenActPanelStart(seq, msg);
end

--点击活动按钮
function GuideGuildTask.B(seq)
	local msg = LanguageMgr.Get("guide/guildTask/2");
    return GuideContent.OpenActItem(seq,msg,"72", "UI_ActivityPanel", GuideGuildTask.A);
end

function GuideGuildTask.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_ActivityPanel");
end

--跳过D
function GuideGuildTask.C(seq)
	seq:SkipAfterStep(GuideGuildTask.D);
	return nil;
end

--选择日常活动tab
function GuideGuildTask.D(seq)
	if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideGuildTask3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/trsToggle/btnRiChangActivity/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/guildTask/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 15, 0));
        seq:AddToCache("GuideGuildTask3", effect);
    end
    seq:SetCacheDisplay("GuideGuildTask3");

    local filter = function(index) return index == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, filter);

	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() GuideGuildTask.ReturnA(seq) end);
	return wait;
end

--判断仙盟状态
function GuideGuildTask.E(seq)
	if GuildDataManager.InGuild() then
		seq:RemoveCache("GuideGuildTask5");
		seq:SkipAfterStep(GuideGuildTask.F);
	else
		seq:RemoveCache("GuideGuildTask4");
		seq:SkipAfterStep(GuideGuildTask.E);
	end
	return nil;
end

--引导点击icon
function GuideGuildTask.F(seq)
	if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideGuildTask4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local icon = panel:GetTransformByPath("trsContent/mainView/RiChangActivityPanel/ScrollView/bag_phalanx/page_0_0/4/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(icon, "ui_guide_1", LanguageMgr.Get("guide/guildTask/4"), GuideTools.Pos.DOWN, Vector3.New(0, -45, 0));
        seq:AddToCache("GuideGuildTask4", effect);
    end
    seq:SetCacheDisplay("GuideGuildTask4");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.FOREVER);
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideGuildTask.D); end));
	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() GuideGuildTask.ReturnA(seq) end);
	--如果显示了仙盟任务的tips 则跳转到完成
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_SHOW_TIPS, nil, function(id) return id == 4 end, function() seq:SkipAfterStep(GuideGuildTask.G); end));
	return wait;
end

--引导点击按钮
function GuideGuildTask.F1(seq)
	if seq.errorFlag then
        return nil;
    end

	if seq:GetCache("GuideGuildTask5") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/mainView/RiChangActivityPanel/ScrollView/bag_phalanx/page_0_0/4/doBt");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/guildTask/5"), GuideTools.Pos.DOWN, Vector3.New(0, -45, 0));
        seq:AddToCache("GuideGuildTask5", effect);
    end
    seq:SetCacheDisplay("GuideGuildTask5");

	local wait = SequenceCommand.UI.PanelOpened("UI_GuildTaskPanel");
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideGuildTask.D); end));
	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() GuideGuildTask.ReturnA(seq) end);
	return wait;
end



--结束
function GuideGuildTask.G(seq)
	return nil;
end