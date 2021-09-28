GuideEquipStrength = class("GuideEquipStrength", SequenceContent);

function GuideEquipStrength.GetSteps()
    return {
    	GuideEquipStrength.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideEquipStrength.B
        ,GuideEquipStrength.DelayForPanel
        ,GuideEquipStrength.C
        ,GuideEquipStrength.D
        ,GuideEquipStrength.E
        ,GuideEquipStrength.F
    };
end

local panelName = "UI_EquipPanel"

-- 清除面板上的引导特效
function GuideEquipStrength._ClearEffect(seq)
    seq:RemoveCache("GuideEquipStrength3");
    seq:RemoveCache("GuideEquipStrength4");
end

-- 监听面板关闭按钮事件
function GuideEquipStrength._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideEquipStrength._ClearEffect(seq)
        seq:SkipAfterStep(GuideEquipStrength.A);
    end );
end

-- 监听面板Tab事件
function GuideEquipStrength._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 5) then
            seq:SkipAfterStep(GuideEquipStrength.D);
        end
    end );
end

function GuideEquipStrength.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideEquipStrength.A(seq)
    local msg = LanguageMgr.Get("guide/GuideEquipStrength/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击铸造按钮
function GuideEquipStrength.B(seq)
    local msg = LanguageMgr.Get("guide/GuideEquipStrength/2");
    return GuideContent.OpenSysItem(seq, msg, "2", panelName, GuideEquipStrength.A);
end

function GuideEquipStrength.C(seq)
	local eq = EquipDataManager.GetProductByKind(1);
    if (eq == nil) then
        seq:SetError();
        seq:SkipAfterStep(GuideEquipStrength.E);
        return nil;
    end
    --seq:SkipAfterStep(GuideEquipStrength.D);
	return nil;
end

--点击强化tab
function GuideEquipStrength.D(seq)
	if seq.errorFlag then
        return nil;
    end

	if seq:GetCache("GuideEquipStrength3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        local btn = panel:GetTransformByPath("trsContent/product_tabs/classify_5/bts/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipStrength/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("GuideEquipStrength3", effect);
    end
    seq:SetCacheDisplay("GuideEquipStrength3");

    local filter = function(index) return index == 5 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, filter);
    wait:AddEvent(GuideEquipStrength._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipStrength._OnTabChangeEvent(seq));
    return wait;
end

--点击强化按钮
function GuideEquipStrength.E(seq)
	if seq.errorFlag then
        return nil;
    end

	if seq:GetCache("GuideEquipStrength4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        local btn = panel:GetTransformByPath("trsContent/qianghua/canActive/imgQianghua");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideEquipStrength/4"), GuideTools.Pos.UP, Vector3.New(0, 45, 0), 1);
        seq:AddToCache("GuideEquipStrength4", effect);
    end
    seq:SetCacheDisplay("GuideEquipStrength4");
    
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_QH);
    wait:AddEvent(GuideEquipStrength._OnCloseEvent(seq));
    wait:AddEvent(GuideEquipStrength._OnTabChangeEvent(seq));
    return wait;
end

function GuideEquipStrength.F(seq)
	return nil;
end

