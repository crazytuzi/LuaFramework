--循环任务提示

GuideLoopTack = class("GuideLoopTack", SequenceContent)

function GuideLoopTack.GetSteps()
    return {
        GuideLoopTack.A
        ,GuideContent.OpenActPanelEnd
        ,GuideLoopTack.B
        ,GuideLoopTack.DelayForPanel
        ,GuideLoopTack.C
        ,GuideLoopTack.D
        ,GuideLoopTack.E
        ,GuideLoopTack.F
        ,GuideLoopTack.End
    };
end

local panelName = "UI_ActivityPanel"

--清除面板上的引导特效
function GuideLoopTack._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
end

--监听面板关闭按钮事件
function GuideLoopTack._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideLoopTack._ClearEffect(seq)
        seq:SkipAfterStep(GuideLoopTack.A);
    end );
end

--监听面板Tab事件
function GuideLoopTack._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 1) then
            seq:SkipAfterStep(GuideLoopTack.D);
        end
    end );
end

function GuideLoopTack.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击右上角功能按钮
function GuideLoopTack.A(seq)
    local msg = LanguageMgr.Get("guide/GuideLoopTack/1")
    return GuideContent.OpenActPanelStart(seq, msg);
end

-- 点击活动按钮
function GuideLoopTack.B(seq)
    local msg = LanguageMgr.Get("guide/GuideLoopTack/2");
    return GuideContent.OpenActItem(seq,msg,"72",panelName,GuideLoopTack.A);
end

function GuideLoopTack.C(seq)
    seq:SkipAfterStep(GuideLoopTack.D);
    return nil;
end

-- 引导点击标签
function GuideLoopTack.D(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/trsToggle/btnRiChangActivity/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideLoopTack/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 1 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, filter);
    wait:AddEvent(GuideLoopTack._OnCloseEvent(seq));
    wait:AddEvent(GuideLoopTack._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击循环任务前往按钮
function GuideLoopTack.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/mainView/RiChangActivityPanel/ScrollView/bag_phalanx/page_0_0/2/doBt");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideLoopTack/4"), GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.UI.PanelOpened("UI_TaskPanel");
    local filter = function(id) return id ~= ActivityDataManager.interface_id_2 end;
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_SELECTED, nil, filter,
    function(eventType, args)
        GuideLoopTack._ClearEffect(seq);
        seq:SkipAfterStep(GuideLoopTack.A);
    end));
    wait:AddEvent(GuideLoopTack._OnCloseEvent(seq));
    wait:AddEvent(GuideLoopTack._OnTabChangeEvent(seq));
    return wait;
end

function GuideLoopTack.F(seq)

    if not TaskManager.HasDailyTask() then
        seq:SetError("No DailyTask in list");
        return nil;
    end

    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_TaskPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/taskDetailView/trsBtns/btnGoNow");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideLoopTack/5"), GuideTools.Pos.UP, Vector3.New(0, 45, 0));
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.UI.CloseBtnClick("UI_TaskPanel");
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.TASK_ITEM_CLICK, nil, 
        function(type) return type ~= TaskConst.Type.DAILY end, function() seq:SkipAfterStep(GuideLoopTack.End); end));
    return wait;
end

function GuideLoopTack.End(seq)
    -- 如果引导出错了 返回nil.
    GuideLoopTack._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end
