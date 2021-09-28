--翅膀升星提示

GuideWingUpgrade = class("GuideWingUpgrade", SequenceContent)

function GuideWingUpgrade.GetSteps()
    return {
        GuideWingUpgrade.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideWingUpgrade.B
        ,GuideWingUpgrade.DelayForPanel
        ,GuideWingUpgrade.C
        ,GuideWingUpgrade.D
        ,GuideWingUpgrade.E
        ,GuideWingUpgrade.F
    };
end

local panelName = "UI_WingPanel"

--清除面板上的引导特效
function GuideWingUpgrade._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
end

--监听面板关闭按钮事件
function GuideWingUpgrade._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideWingUpgrade._ClearEffect(seq)
        seq:SkipAfterStep(GuideWingUpgrade.A);
    end );
end

--监听面板Tab事件
function GuideWingUpgrade._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.WING_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 1) then
            seq:SkipAfterStep(GuideWingUpgrade.C);
        end
    end );
end

function GuideWingUpgrade.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideWingUpgrade.A(seq)
    local msg = LanguageMgr.Get("guide/GuideWingUpgrade/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击翅膀按钮
function GuideWingUpgrade.B(seq)
    local msg = LanguageMgr.Get("guide/GuideWingUpgrade/2");
    return GuideContent.OpenSysItem(seq,msg,"8",panelName,GuideWingUpgrade.A);
end

function GuideWingUpgrade.C(seq)
    --seq:SkipAfterStep(GuideWingUpgrade.D);
    return nil;
end

function GuideWingUpgrade.D(seq)
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnWing/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideWingUpgrade/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 1 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.WING_CHANGE_PANEL,nil,filter);
    wait:AddEvent(GuideWingUpgrade._OnCloseEvent(seq));
    wait:AddEvent(GuideWingUpgrade._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击升星按钮
function GuideWingUpgrade.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/trsWing/trsUp/btnUpdateLevel");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideWingUpgrade/4"), GuideTools.Pos.LEFT, Vector3.New(-120, 10, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.WING_UPGRADE);
    wait:AddEvent(GuideWingUpgrade._OnCloseEvent(seq));
    wait:AddEvent(GuideWingUpgrade._OnTabChangeEvent(seq));
    return wait;
end


-- 点击返回主界面
function GuideWingUpgrade.F(seq)
    -- 如果引导出错了 返回nil.
    GuideWingUpgrade._ClearEffect(seq);
    if seq.errorFlag then
        return nil;
    end
end