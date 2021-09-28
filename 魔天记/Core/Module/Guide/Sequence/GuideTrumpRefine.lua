-- 法宝炼制提示

GuideTrumpRefine = class("GuideTrumpRefine", SequenceContent)

function GuideTrumpRefine.GetSteps()
    return {
        GuideTrumpRefine.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideTrumpRefine.B
        ,GuideTrumpRefine.DelayForPanel
        ,GuideTrumpRefine.C
        ,GuideTrumpRefine.D1
        ,GuideTrumpRefine.D
        ,GuideTrumpRefine.E
        --,GuideTrumpRefine.F
        ,GuideTrumpRefine.G
    };
end

local panelName = "UI_NewTrumpPanel"

--清除面板上的引导特效
function GuideTrumpRefine._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
    seq:RemoveCache("guideReqItem4");
end

--监听面板关闭按钮事件
function GuideTrumpRefine._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideTrumpRefine._ClearEffect(seq)
        seq:SkipAfterStep(GuideTrumpRefine.A);
    end );
end

--监听面板Tab事件
function GuideTrumpRefine._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.TRUMP_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        GuideTrumpRefine.tabIndex = args;
        if (args ~= 2) then
            seq:SkipAfterStep(GuideTrumpRefine.C);
        end
    end );
end

--监听选择法宝事件
function GuideTrumpRefine._OnTrumpChangeEvent(seq)
    local filter = function(trump) return GuideTrumpRefine.tabIndex == 2 end;
    return SequenceEvent.Create(SequenceEventType.Guide.TRUMP_CHANGE, nil, filter,
    function(eventType, args)        
        seq:SkipAfterStep(GuideTrumpRefine.D1);
    end );
end

function GuideTrumpRefine.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideTrumpRefine.A(seq)
    local msg = LanguageMgr.Get("guide/GuideTrumpRefine/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击法宝按钮
function GuideTrumpRefine.B(seq)
    local msg = LanguageMgr.Get("guide/GuideTrumpRefine/2");
    return GuideContent.OpenSysItem(seq, msg, "14", panelName, GuideTrumpRefine.A);
end

-- 引导点击炼制标签
function GuideTrumpRefine.C(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnRefine/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpRefine/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), 11);
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

     local filter = function(index) 
        GuideTrumpRefine.tabIndex = index;
        return index == 2 
    end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_CHANGE_PANEL,nil,filter);
    wait:AddEvent(GuideTrumpRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTabChangeEvent(seq));
    return wait;
end

function GuideTrumpRefine.D1(seq)
    local trump = NewTrumpManager.GetCurrentSelectTrump();
    local selectRefineLevel = NewTrumpManager.GetSelectRefineLevel()
    local refineData = trump:GetAllRefineData()[selectRefineLevel]
    if (refineData and trump.state > NewTrumpInfo.State.CanActive) then
        if (HeroController:GetInstance().info.level >= refineData.req_lev) then
            if (refineData.state == 0) then
                seq:SkipAfterStep(GuideTrumpRefine.D);
            else
                seq:SkipAfterStep(GuideTrumpRefine.E);
            end
        end
    else
        seq:SetError();
        return nil;
    end
    return nil;
end

-- 引导选择法宝
function GuideTrumpRefine.D(seq)
    if seq.errorFlag then
        return nil;
    end

    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_NewTrumpPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/scrollView/phalanx/item_0_0/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpRefine/4"), GuideTools.Pos.LEFT, Vector3.New(-50, 0, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");
    local filter = function(trump) return false end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_CHANGE,nil,filter);
    wait:AddEvent(GuideTrumpRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTabChangeEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTrumpChangeEvent(seq));
    return wait;
end

-- 引导点击激活按钮
function GuideTrumpRefine.E(seq)

    if seq.errorFlag then
        return nil;
    end
    
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/trsRefine/btnActive");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpRefine/5"), GuideTools.Pos.UP, Vector3.New(0, 45, 0));
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_REFINE_ACTIVITY);
    wait:AddEvent(GuideTrumpRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTabChangeEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTrumpChangeEvent(seq));
    return wait;
end

--[[
-- 引导点击精炼按钮
function GuideTrumpRefine.F(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/trsRefine/btnRefine");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpRefine/6"), GuideTools.Pos.UP, Vector3.New(0, 45, 0), 1);
        seq:AddToCache("guideReqItem4", effect);
    end
    seq:SetCacheDisplay("guideReqItem4");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_REFINE);
    wait:AddEvent(GuideTrumpRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTabChangeEvent(seq));
    wait:AddEvent(GuideTrumpRefine._OnTrumpChangeEvent(seq));
    return wait;
end
]]

-- 点击返回主界面
function GuideTrumpRefine.G(seq)
    -- 如果引导出错了 返回nil.
    GuideTrumpRefine._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end