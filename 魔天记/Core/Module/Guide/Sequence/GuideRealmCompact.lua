-- 境界凝练提示

GuideRealmCompact = class("GuideRealmCompact", SequenceContent)

function GuideRealmCompact.GetSteps()
    return {
        GuideRealmCompact.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideRealmCompact.B
        ,GuideRealmCompact.DelayForPanel
        ,GuideRealmCompact.C
        ,GuideRealmCompact.D
        ,GuideRealmCompact.E
    };
end

local panelName = "UI_RealmPanel"

--清除面板上的引导特效
function GuideRealmCompact._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
end

--监听面板关闭按钮事件
function GuideRealmCompact._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideRealmCompact._ClearEffect(seq)
        seq:SkipAfterStep(GuideRealmCompact.A);
    end );
end

--监听面板Tab事件
function GuideRealmCompact._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.REALM_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 2) then
            seq:SkipAfterStep(GuideRealmCompact.C);
        end
    end );
end

function GuideRealmCompact.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideRealmCompact.A(seq)
    local msg = LanguageMgr.Get("guide/GuideRealmCompact/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击境界按钮
function GuideRealmCompact.B(seq)
    local msg = LanguageMgr.Get("guide/GuideRealmCompact/2");
    return GuideContent.OpenSysItem(seq, msg, "4", panelName, GuideRealmCompact.A);
end

-- 引导点击凝练按钮
function GuideRealmCompact.C(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnTab2/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideRealmCompact/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 2 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.REALM_CHANGE_PANEL,nil,filter);
    wait:AddEvent(GuideRealmCompact._OnCloseEvent(seq));
    wait:AddEvent(GuideRealmCompact._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击境界升级按钮
function GuideRealmCompact.D(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/panels/panel2/btnCompact");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideRealmCompact/4"), GuideTools.Pos.LEFT, Vector3.New(-120, 10, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.REALM_COMPACT);
    wait:AddEvent(GuideRealmCompact._OnCloseEvent(seq));
    wait:AddEvent(GuideRealmCompact._OnTabChangeEvent(seq));
    return wait;
end

-- 点击返回主界面
function GuideRealmCompact.E(seq)
    -- 如果引导出错了 返回nil.
    GuideRealmCompact._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end