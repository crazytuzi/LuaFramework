-- 法宝激活提示

GuideTrumpActivity = class("GuideTrumpActivity", SequenceContent)

function GuideTrumpActivity.GetSteps()
    return {
        GuideTrumpActivity.A
        ,GuideContent.OpenSysPanelEnd        
        ,GuideTrumpActivity.B
        --,GuideTrumpActivity.WaitPanelInit
        ,GuideTrumpActivity.C
        ,GuideTrumpActivity.D
        ,GuideTrumpActivity.E1
        ,GuideTrumpActivity.E
        ,GuideTrumpActivity.F
        ,GuideTrumpActivity.G
        ,GuideTrumpActivity.H
    };
end

local panelName = "UI_NewTrumpPanel"

--清除面板上的引导特效
function GuideTrumpActivity._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
    seq:RemoveCache("guideReqItem4");
end

--监听面板关闭按钮事件
function GuideTrumpActivity._OnCloseEvent(seq)
    local filter = function(name) return name == "UI_NewTrumpPanel" end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideTrumpActivity._ClearEffect(seq)
        seq:SkipAfterStep(GuideTrumpActivity.A);
    end );
end

--监听面板Tab事件
function GuideTrumpActivity._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.TRUMP_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        GuideTrumpActivity.tabIndex = args;
        if (args ~= 1) then
            seq:SkipAfterStep(GuideTrumpActivity.D);
        end
    end );
end

--监听选择法宝事件
function GuideTrumpActivity._OnTrumpChangeEvent(seq)
    local filter = function(trump) return GuideTrumpActivity.tabIndex == 1 end;
    return SequenceEvent.Create(SequenceEventType.Guide.TRUMP_CHANGE, nil, filter,
    function(eventType, args)
        seq:SkipAfterStep(GuideTrumpActivity.E1);
    end );
end

function GuideTrumpActivity.WaitPanelInit(seq)
	seq:SetCacheDisplay("");
	return SequenceCommand.Delay(0.2);
end

-- 引导点击玩家头像
function GuideTrumpActivity.A(seq)
    local msg = LanguageMgr.Get("guide/GuideTrumpActivity/1")
    GuideTrumpActivity.tabIndex = 1;
    return GuideContent.OpenSysPanelStart(seq, msg);
end


-- 引导点击法宝按钮
function GuideTrumpActivity.B(seq)
    local msg = LanguageMgr.Get("guide/GuideTrumpActivity/2");
    return GuideContent.OpenSysItem(seq, msg, "14", "UI_NewTrumpPanel", GuideTrumpActivity.A);
end

-- 跳过引导点击法宝标签
function GuideTrumpActivity.C(seq)
    seq:SkipAfterStep(GuideTrumpActivity.D);
    return nil;
end

-- 引导点击法宝标签
function GuideTrumpActivity.D(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_NewTrumpPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnTrump/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpActivity/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), 1);
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) 
        GuideTrumpActivity.tabIndex = index;
        return index == 1 
    end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_CHANGE_PANEL,nil,filter);
    wait:AddEvent(GuideTrumpActivity._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTabChangeEvent(seq));
    return wait;
end

function GuideTrumpActivity.E1(seq)
    local trump = NewTrumpManager.GetCurrentSelectTrump();
    if (trump) then
        if (trump.state == 1) then
            seq:SkipAfterStep(GuideTrumpActivity.E);
            return nil;
        elseif (trump.state == 2) then
            seq:SkipAfterStep(GuideTrumpActivity.F);
            return nil;
        end        
    end
    return nil;
end

-- 引导选择法宝
function GuideTrumpActivity.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_NewTrumpPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/scrollView/phalanx/item_0_0/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpActivity/4"), GuideTools.Pos.LEFT, Vector3.New(-50, 0, 0), 1);
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");
    local filter = function(trump) return false end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_CHANGE,nil,filter);
    wait:AddEvent(GuideTrumpActivity._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTabChangeEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTrumpChangeEvent(seq));
    return wait;
end

-- 引导点击激活按钮
function GuideTrumpActivity.F(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_NewTrumpPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/trsTrump/1/btnActive");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpActivity/5"), GuideTools.Pos.UP, Vector3.New(0, 45, 0), 1);
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_ACTIVITY);
    wait:AddEvent(GuideTrumpActivity._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTabChangeEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTrumpChangeEvent(seq));
    return wait;
end

-- 引导点击佩戴按钮
function GuideTrumpActivity.G(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_NewTrumpPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/trsTrump/2/btnEquip");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideTrumpActivity/6"), GuideTools.Pos.UP, Vector3.New(0, 45, 0), 1);
        seq:AddToCache("guideReqItem4", effect);
    end
    seq:SetCacheDisplay("guideReqItem4");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.TRUMP_EQUIP);
   wait:AddEvent(GuideTrumpActivity._OnCloseEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTabChangeEvent(seq));
    wait:AddEvent(GuideTrumpActivity._OnTrumpChangeEvent(seq));
    return wait;
end

-- 点击返回主界面
function GuideTrumpActivity.H(seq)
    -- 如果引导出错了 返回nil.
    GuideTrumpActivity._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end