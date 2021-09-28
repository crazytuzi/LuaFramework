-- 装备精炼提示

GuideEquipRefine = class("GuideEquipRefine", SequenceContent)

function GuideEquipRefine.GetSteps()
    return {
        GuideEquipRefine.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideEquipRefine.B
        ,GuideEquipRefine.DelayForPanel
        ,GuideEquipRefine.C
        ,GuideEquipRefine.D
        ,GuideEquipRefine.E
        ,GuideEquipRefine.F
        ,GuideEquipRefine.G
    };
end

local panelName = "UI_EquipPanel"

-- 清除面板上的引导特效
function GuideEquipRefine._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
end

-- 监听面板关闭按钮事件
function GuideEquipRefine._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideEquipRefine._ClearEffect(seq)
        seq:SkipAfterStep(GuideEquipRefine.A);
    end );
end

-- 监听面板Tab事件
function GuideEquipRefine._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 2) then
            seq:SkipAfterStep(GuideEquipRefine.C);
        end
    end );
end

function GuideEquipRefine.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideEquipRefine.A(seq)
    local msg = LanguageMgr.Get("guide/GuideEquipRefine/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击铸造按钮
function GuideEquipRefine.B(seq)
    local msg = LanguageMgr.Get("guide/GuideEquipRefine/2");
    return GuideContent.OpenSysItem(seq, msg, "2", panelName, GuideEquipRefine.A);
end

-- 引导点击精炼标签
function GuideEquipRefine.C(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/product_tabs/classify_2/bts/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipRefine/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 2 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, filter);
    wait:AddEvent(GuideEquipRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipRefine._OnTabChangeEvent(seq));
    return wait;
end

-- 引导判断，如果穿戴了跳到F
function GuideEquipRefine.D(seq)
    local eq = EquipDataManager.GetProductByKind(1);
    if (eq ~= nil) then
        seq:SkipAfterStep(GuideEquipRefine.E);
        return nil;
    end
    return nil;
end

-- 引导点击装备按钮
function GuideEquipRefine.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/equipDressTipPanel/ScrollView/pd_phalanx/ProductDressPanel_0_0/gettoGet_bt");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipRefine/4"), GuideTools.Pos.DOWN, Vector3.New(0, -45, 0), 1);
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_DRESS);
    wait:AddEvent(GuideEquipRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipRefine._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击精炼按钮
function GuideEquipRefine.F(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/jingnian/rightPanel/panel3/btn_jinglian");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipRefine/5"), GuideTools.Pos.UP, Vector3.New(0, 45, 0), 1);
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_REFINE);
    wait:AddEvent(GuideEquipRefine._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipRefine._OnTabChangeEvent(seq));
    return wait;
end

-- 点击返回主界面
function GuideEquipRefine.G(seq)
    -- 如果引导出错了 返回nil.
    GuideEquipRefine._ClearEffect(seq);
    if seq.errorFlag then
        return nil;
    end
end