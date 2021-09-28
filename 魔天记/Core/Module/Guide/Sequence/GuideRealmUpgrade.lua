-- 境界提升提示

GuideRealmUpgrade = class("GuideRealmUpgrade", SequenceContent)

function GuideRealmUpgrade.GetSteps()
    return {
        GuideRealmUpgrade.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideRealmUpgrade.B
        ,GuideRealmUpgrade.DelayForPanel
        ,GuideRealmUpgrade.C
        ,GuideRealmUpgrade.D
        ,GuideRealmUpgrade.E
        ,GuideRealmUpgrade.F
    };
end

local panelName = "UI_RealmPanel"

--清除面板上的引导特效
function GuideRealmUpgrade._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
end

--监听面板关闭按钮事件
function GuideRealmUpgrade._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideRealmUpgrade._ClearEffect(seq)
        seq:SkipAfterStep(GuideRealmUpgrade.A);
    end );
end

--监听面板Tab事件
function GuideRealmUpgrade._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.REALM_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 1) then
            seq:SkipAfterStep(GuideRealmUpgrade.D);
        end
    end );
end

function GuideRealmUpgrade.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideRealmUpgrade.A(seq)
    local msg = LanguageMgr.Get("guide/GuideRealmUpgrade/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击境界按钮
function GuideRealmUpgrade.B(seq)
    local msg = LanguageMgr.Get("guide/GuideRealmUpgrade/2");
    return GuideContent.OpenSysItem(seq, msg, "4", "UI_RealmPanel", GuideRealmUpgrade.A);
end

function GuideRealmUpgrade.C(seq)
    seq:SkipAfterStep(GuideRealmUpgrade.D);
    return nil;
end

-- 引导点击凝练按钮
function GuideRealmUpgrade.D(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnTab1/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideRealmUpgrade/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 1 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.REALM_CHANGE_PANEL,nil,filter);
    wait:AddEvent(GuideRealmUpgrade._OnCloseEvent(seq));
    wait:AddEvent(GuideRealmUpgrade._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击境界升级按钮
function GuideRealmUpgrade.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_RealmPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/panels/panel1/btnUpgrade");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideRealmUpgrade/4"), GuideTools.Pos.UP, Vector3.New(0, 50, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.REALM_UPGRADE);
    wait:AddEvent(GuideRealmUpgrade._OnCloseEvent(seq));
    wait:AddEvent(GuideRealmUpgrade._OnTabChangeEvent(seq));
    return wait;
end

-- 点击返回主界面
function GuideRealmUpgrade.F(seq)
    -- 如果引导出错了 返回nil.
    GuideRealmUpgrade._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end