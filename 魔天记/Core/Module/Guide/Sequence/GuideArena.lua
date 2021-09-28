GuideArena = class("GuideArena", SequenceContent);

function GuideArena.GetSteps()
    return {
    	GuideArena.A
      	,GuideContent.OpenActPanelEnd
      	,GuideArena.B
        ,GuideArena.DelayForPanel
        ,GuideArena.C
		,GuideArena.D
		,GuideArena.E
		,GuideArena.F
    };
end

function GuideArena.ReturnA(seq)
	seq:RemoveCache("GuideArena3");
	seq:RemoveCache("GuideArena4");
	seq:RemoveCache("GuideArena5");
	seq:SkipAfterStep(GuideArena.A);
end

--点击右侧活动栏
function GuideArena.A(seq)
	return GuideContent.OpenActPanelStart(seq, LanguageMgr.Get("guide/GuideArena/1"));
end

--点击活动按钮
function GuideArena.B(seq)
    return GuideContent.OpenActItem(seq, LanguageMgr.Get("guide/GuideArena/2"), "72", "UI_ActivityPanel", GuideArena.A);
end

function GuideArena.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_ActivityPanel");
end

--跳过D
function GuideArena.C(seq)
	seq:SkipAfterStep(GuideArena.D);
	return nil;
end

--选择日常活动tab
function GuideArena.D(seq)
	if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideArena3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/trsToggle/btnRiChangActivity/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideArena/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 15, 0));
        seq:AddToCache("GuideArena3", effect);
    end
    seq:SetCacheDisplay("GuideArena3");

    local filter = function(index) return index == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, filter);

	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() GuideArena.ReturnA(seq) end);
	return wait;
end

-- 引导点击竞技场
function GuideArena.E(seq)
	if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideArena4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/mainView/RiChangActivityPanel/ScrollView/bag_phalanx/page_0_0/3/doBt");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideArena/4"), GuideTools.Pos.TOP_LEFT, Vector3.New(0, 45, 0));
        seq:AddToCache("GuideArena4", effect);
    end
    seq:SetCacheDisplay("GuideArena4");

    local wait = SequenceCommand.UI.PanelOpened("UI_PVPPanel");
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideArena.D); end));
	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() GuideArena.ReturnA(seq) end);
	return wait;
end

function GuideArena.F(seq)
	if seq.errorFlag then
        return nil;
    end

    --判断竞技场次数
    if PVPManager.GetPVPLimitTime() == 0 then
    	return nil;
    end

    if seq:GetCache("GuideArena5") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_PVPPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/btnFight");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideArena/5"), GuideTools.Pos.TOP_RIGHT, Vector3.New(0, 55, 0));
        seq:AddToCache("GuideArena5", effect);
    end
    seq:SetCacheDisplay("GuideArena5");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ARENA_DOFIGHT);
    GuideContent.AddCloseFun(wait, "UI_PVPPanel", function() seq:RemoveCache("GuideArena5"); seq:SkipAfterStep(GuideArena.E); end);
   	return wait;
end


