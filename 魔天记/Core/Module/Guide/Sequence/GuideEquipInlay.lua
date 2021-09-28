-- 装备镶嵌提示

GuideEquipInlay = class("GuideEquipInlay", SequenceContent)

function GuideEquipInlay.GetSteps()
    return {
        GuideEquipInlay.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideEquipInlay.B
        ,GuideEquipInlay.DelayForPanel
        ,GuideEquipInlay.C
        ,GuideEquipInlay.D
        ,GuideEquipInlay.E
        ,GuideEquipInlay.F
        ,GuideEquipInlay.G
    };
end

local panelName = "UI_EquipPanel"

-- 清除面板上的引导特效
function GuideEquipInlay._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
end

-- 监听面板关闭按钮事件
function GuideEquipInlay._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideEquipInlay._ClearEffect(seq)
        seq:SkipAfterStep(GuideEquipInlay.A);
    end );
end

-- 监听面板Tab事件
function GuideEquipInlay._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 4) then
            seq:SkipAfterStep(GuideEquipInlay.C);
        end
    end );
end

function GuideEquipInlay.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideEquipInlay.A(seq)
    local msg = LanguageMgr.Get("guide/GuideEquipInlay/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击铸造按钮
function GuideEquipInlay.B(seq)
    local msg = LanguageMgr.Get("guide/GuideEquipInlay/2");
    return GuideContent.OpenSysItem(seq, msg, "2", panelName, GuideEquipInlay.A);
end

-- 引导点击宝石标签
function GuideEquipInlay.C(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/product_tabs/classify_4/bts/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipInlay/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), 1);
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 4 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, filter);
    wait:AddEvent(GuideEquipInlay._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipInlay._OnTabChangeEvent(seq));
    return wait;
end

-- 引导判断，如果穿戴了跳到F
function GuideEquipInlay.D(seq)
    
    if seq.errorFlag then
        return nil;
    end

    local eq = EquipDataManager.GetProductByKind(1);
    if (eq ~= nil) then
        local slot = GemDataManager.GetSlotData(1);
        for i,v in ipairs(slot) do
            if v == 0 then
                seq:SkipAfterStep(GuideEquipInlay.E);
                return nil;
            end
        end
        --如果没有空位 则直接跳到结束.
        seq:SkipAfterStep(GuideEquipInlay.F);
        return nil;
    end
    return nil;
end

-- 引导点击装备按钮
function GuideEquipInlay.E(seq)
    if seq.errorFlag then
        return nil;
    end

    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/equipDressTipPanel/ScrollView/pd_phalanx/ProductDressPanel_0_0/gettoGet_bt");
        if btn == nil then
            seq:SetError();
            return nil; 
        end
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipInlay/4"), GuideTools.Pos.DOWN, Vector3.New(0, -45, 0), 1);
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_DRESS);
    wait:AddEvent(GuideEquipInlay._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipInlay._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击镶嵌按钮
function GuideEquipInlay.F(seq)
    if seq.errorFlag then
        return nil;
    end

    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        local btn = panel:GetTransformByPath("trsContent/gem/rightPanel/panel3/trsGemList/btnXiangQian");

        if btn.gameObject.activeSelf == false then
            seq:SetError();
            return nil;
        end

        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipInlay/5"), GuideTools.Pos.UP, Vector3.New(0, 45, 0), 1);
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_INLAY);
    wait:AddEvent(GuideEquipInlay._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipInlay._OnTabChangeEvent(seq));
    return wait;
end

-- 点击返回主界面
function GuideEquipInlay.G(seq)
    -- 如果引导出错了 返回nil.
    return nil;
end