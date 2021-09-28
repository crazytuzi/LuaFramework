GuideAutoStrengthen = class("GuideAutoStrengthen", SequenceContent)

function GuideAutoStrengthen.GetSteps()
    return {
      	GuideAutoStrengthen.A
      	,GuideContent.GuideSysPanelEnd
      	,GuideAutoStrengthen.B
      	,GuideAutoStrengthen.DelayForPanel
      	,GuideAutoStrengthen.C
      	,GuideAutoStrengthen.D
      	,GuideAutoStrengthen.E
      	,GuideAutoStrengthen.F
      	,GuideAutoStrengthen.G
    };
end

function GuideAutoStrengthen.ReturnA(seq)
	seq:RemoveCache("GuideAutoStrengthen3");
	seq:RemoveCache("GuideAutoStrengthen4");
	seq:RemoveCache("GuideAutoStrengthen5");
	seq:SkipAfterStep(GuideAutoStrengthen.A);
end

function GuideAutoStrengthen.ReturnEQ(seq)
	seq:RemoveCache("GuideAutoStrengthen6");
	seq:SkipAfterStep(GuideAutoStrengthen.F);
end

function GuideAutoStrengthen.A(seq)
	return GuideContent.OpenSysPanelStart(seq, LanguageMgr.Get("guide/GuideAutoStrengthen/1"));
end

--打开设置面板
function GuideAutoStrengthen.B(seq)
	local msg = LanguageMgr.Get("guide/GuideAutoStrengthen/2");
	return GuideContent.OpenSysItem(seq, msg, "12", "UI_AutoFightPanel", GuideAutoStrengthen.A);
end

function GuideAutoStrengthen.DelayForPanel(seq)
	return SequenceCommand.UI.PanelOpened("UI_AutoFightPanel");
end

--跳过C
function GuideAutoStrengthen.C(seq)
	seq:SkipAfterStep(GuideAutoStrengthen.D);
	return nil;
end

--引导点击挂机设置切页
function GuideAutoStrengthen.D(seq)
	if seq:GetCache("GuideAutoStrengthen3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_AutoFightPanel");
        local btn = panel:GetTransformByPath("trsContent/guajiSetBt/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideAutoStrengthen/3"), GuideTools.Pos.DOWN, Vector3.New(0, -10, 0));
        seq:AddToCache("GuideAutoStrengthen3", effect);
    end
    seq:SetCacheDisplay("GuideAutoStrengthen3");

    local filter = function(index) return index == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.AUTO_FIGHT_TAB, nil, filter);
	GuideContent.AddCloseFun(wait, "UI_AutoFightPanel", function() GuideAutoStrengthen.ReturnA(seq) end);
	return wait;
end

--引导点击白色装备选项
function GuideAutoStrengthen.E(seq)

	if AutoFightManager.strengthen_eq_quality1 then
		return nil;
	end

	if seq:GetCache("GuideAutoStrengthen4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_AutoFightPanel");
        local btn = panel:GetTransformByPath("trsContent/guajiSetPanel/rightPanel/checkEq1/Background");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideAutoStrengthen/4"), GuideTools.Pos.LEFT, Vector3.New(-50, 0, 0));
        seq:AddToCache("GuideAutoStrengthen4", effect);
    end
    seq:SetCacheDisplay("GuideAutoStrengthen4");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.AUTO_STRENGTH_QUALITY);
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.AUTO_FIGHT_TAB, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideAutoStrengthen.D); end));
    GuideContent.AddCloseFun(wait, "UI_AutoFightPanel", function() GuideAutoStrengthen.ReturnA(seq) end);
    return wait;
end

--引导点击装备按钮
function GuideAutoStrengthen.F(seq)
	if seq:GetCache("GuideAutoStrengthen5") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_AutoFightPanel");
        local btn = panel:GetTransformByPath("trsContent/guajiSetPanel/rightPanel/eqpanel/bg");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideAutoStrengthen/5"), GuideTools.Pos.RIGHT, Vector3.New(45, 0, 0));
        seq:AddToCache("GuideAutoStrengthen5", effect);
    end
    seq:SetCacheDisplay("GuideAutoStrengthen5");

    local wait = SequenceCommand.UI.PanelOpened("UI_AutoFightEQSetPanel");
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.AUTO_FIGHT_TAB, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideAutoStrengthen.D); end));
    GuideContent.AddCloseFun(wait, "UI_AutoFightPanel", function() GuideAutoStrengthen.ReturnA(seq) end);
    return wait;
end

--引导点击装备位置
function GuideAutoStrengthen.G(seq)
	if seq:GetCache("GuideAutoStrengthen6") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_AutoFightEQSetPanel");
        local btn = panel:GetTransformByPath("trsContent/epPanel/eq_1/icon_quality");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideAutoStrengthen/6"), GuideTools.Pos.RIGHT, Vector3.New(45, 0, 0));
        seq:AddToCache("GuideAutoStrengthen6", effect);
    end
    seq:SetCacheDisplay("GuideAutoStrengthen6");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.AUTO_STRENGTH_EQ_SELECT);
	GuideContent.AddCloseFun(wait, "UI_AutoFightEQSetPanel", function() GuideAutoStrengthen.ReturnEQ(seq) end);
	return wait;
end
