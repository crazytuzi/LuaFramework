GuideGuMoAttack = class("GuideGuMoAttack", SequenceContent);

function GuideGuMoAttack.GetSteps()
    return {
        GuideGuMoAttack.A
      	,GuideContent.OpenActPanelEnd
      	,GuideGuMoAttack.B
        ,GuideGuMoAttack.DelayForPanel
        ,GuideGuMoAttack.C0
        ,GuideGuMoAttack.C1
        ,GuideGuMoAttack.C
        ,GuideGuMoAttack.D
        ,GuideGuMoAttack.E
        --,GuideGuMoAttack.F
    };
end

function GuideGuMoAttack.ReturnA(seq)
	seq:RemoveCache("GuideGuMoAttack3");
	seq:RemoveCache("GuideGuMoAttack4");
    seq:RemoveCache("GuideGuMoAttack5");
	seq:SkipAfterStep(GuideGuMoAttack.A);
end

--点击右侧活动栏
function GuideGuMoAttack.A(seq)
	return GuideContent.OpenActPanelStart(seq, LanguageMgr.Get("guide/GuideGuMoAttack/1"));
end

--点击活动按钮
function GuideGuMoAttack.B(seq)
    return GuideContent.OpenActItem(seq, LanguageMgr.Get("guide/GuideGuMoAttack/2"), "75", "UI_WildBossNewPanel", GuideZongMenLiLian.A);
end

function GuideGuMoAttack.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_WildBossNewPanel");
end

function GuideGuMoAttack.C0(seq)
    return SequenceCommand.WaitForEvent(SequenceEventType.Guide.WILD_BOSS_SHOW);
end

function GuideGuMoAttack.C1(seq)
    seq:SkipAfterStep(GuideGuMoAttack.C);
    return nil;
end

--点击普通古魔标签
function GuideGuMoAttack.C(seq)
    if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideGuMoAttack3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_WildBossNewPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/trsTabs/classify_1/bts/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideGuMoAttack/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 15, 0));
        seq:AddToCache("GuideGuMoAttack3", effect);
    end
    seq:SetCacheDisplay("GuideGuMoAttack3");

    local filter = function(index) return index == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.WILD_BOSS_TAB_CHG, nil, filter);
	GuideContent.AddCloseFun(wait, "UI_WildBossNewPanel", function() GuideGuMoAttack.ReturnA(seq) end);
	return wait;
end

--点击古魔BOSS
function GuideGuMoAttack.D(seq)
    if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideGuMoAttack4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_WildBossNewPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/trsView/trsField/scrollview/phalanx/2/bg");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideGuMoAttack/4"), GuideTools.Pos.RIGHT, Vector3.New(100, 0, 0));
        seq:AddToCache("GuideGuMoAttack4", effect);
    end
    seq:SetCacheDisplay("GuideGuMoAttack4");

    
    local filter = function(id) return id == 2 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.WILD_BOSS_SELECT, nil, filter);
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.WILD_BOSS_TAB_CHG, nil, function(idx) return idx ~= 1 end, function() seq:SkipAfterStep(GuideGuMoAttack.C); end));
	GuideContent.AddCloseFun(wait, "UI_WildBossNewPanel", function() GuideGuMoAttack.ReturnA(seq) end);
	return wait;
end

--点击奖励
function GuideGuMoAttack.E(seq)
	if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideGuMoAttack5") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_WildBossNewPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local tr = panel:GetTransformByPath("trsContent/trsView/trsField/DynamicPanel/phalanx");
        local btn = tr:GetChild(1);
        btn = btn:Find("icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideGuMoAttack/5"), GuideTools.Pos.UP, Vector3.New(0, 45, 0));
        seq:AddToCache("GuideGuMoAttack5", effect);
    end
    seq:SetCacheDisplay("GuideGuMoAttack5");
    
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.WILD_BOSS_ITEM_CLICK);
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.WILD_BOSS_SELECT, nil, function(idx) return idx ~= 2 end, function() seq:SkipAfterStep(GuideGuMoAttack.D); end));
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.WILD_BOSS_TAB_CHG, nil, function(idx) return idx ~= 1 end, function() seq:SkipAfterStep(GuideGuMoAttack.C); end));
    GuideContent.AddCloseFun(wait, "UI_WildBossNewPanel", function() seq:RemoveCache("GuideGuMoAttack5"); GuideGuMoAttack.D(seq) end);
    return wait;
end

--[[
--点击挑战
function GuideGuMoAttack.F(seq)
	if seq.errorFlag then
        return nil;
    end

    if seq:GetCache("GuideGuMoAttack6") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_WildBossInfoPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/btnGo");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideGuMoAttack/6"), GuideTools.Pos.TOP_LEFT, Vector3.New(0, 45, 0));
        seq:AddToCache("GuideGuMoAttack6", effect);
    end
    seq:SetCacheDisplay("GuideGuMoAttack6");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ARENA_DOFIGHT);
    GuideContent.AddCloseFun(wait, "UI_WildBossInfoPanel", function() seq:RemoveCache("GuideGuMoAttack6"); seq:SkipAfterStep(GuideGuMoAttack.E); end);
   	return wait;
end
]]