GuideAutoFightSetting = class("GuideAutoFightSetting", SequenceContent)

function GuideAutoFightSetting.GetSteps()
    return {
      	GuideAutoFightSetting.A
      	,GuideContent.OpenSysPanelEnd
      	,GuideAutoFightSetting.B
      	,GuideAutoFightSetting.DelayForPanel
      	,GuideAutoFightSetting.C
      	,GuideAutoFightSetting.D
      	,GuideAutoFightSetting.E
      	,GuideAutoFightSetting.F
      	,GuideAutoFightSetting.G
      	,GuideAutoFightSetting.H
      	,GuideAutoFightSetting.END
    };
end

function GuideAutoFightSetting.ReturnA(seq)
	seq:RemoveCache("GuideAutoFightSetting3");
	seq:RemoveCache("GuideAutoFightSetting4");
	seq:RemoveCache("GuideAutoFightSetting5");
	seq:RemoveCache("GuideAutoFightSetting6");
	seq:SkipAfterStep(GuideAutoFightSetting.A);
end


function GuideAutoFightSetting.A(seq)
	ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTPANEL);
	return GuideContent.OpenSysPanelStart(seq, LanguageMgr.Get("guide/setAutoFight/1"));
end

--打开设置面板
function GuideAutoFightSetting.B(seq)
	local msg = LanguageMgr.Get("guide/setAutoFight/2");
	return GuideContent.OpenSysItem(seq, msg, "12", "UI_AutoFightPanel", GuideAutoFightSetting.A0);
end

function GuideAutoFightSetting.DelayForPanel(seq)
	return SequenceCommand.UI.PanelOpened("UI_AutoFightPanel");
end

--默认跳过TAB
function GuideAutoFightSetting.C(seq)
	seq:SkipAfterStep(GuideAutoFightSetting.D);
	return nil;
end

--引导点击挂机设置切页
function GuideAutoFightSetting.D(seq)
	if seq:GetCache("GuideAutoFightSetting2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_AutoFightPanel");
        local btn = panel:GetTransformByPath("trsContent/guajiSetBt/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/setAutoFight/2_1"), GuideTools.Pos.DOWN, Vector3.New(0, -10, 0));
        seq:AddToCache("GuideAutoFightSetting2", effect);
    end
    seq:SetCacheDisplay("GuideAutoFightSetting2");

    local filter = function(index) return index == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.AUTO_FIGHT_TAB, nil, filter);
	GuideContent.AddCloseFun(wait, "UI_AutoFightPanel", function() GuideAutoFightSetting.ReturnA(seq) end);
	return wait;
end

--点击生命框
function GuideAutoFightSetting.E(seq)

	if seq:GetCache("GuideAutoFightSetting3") == nil then
        local panel = PanelManager.GetPanelByType("UI_AutoFightPanel");
        local btn = panel:GetTransformByPath("trsContent/guajiSetPanel/leftPanel/proPanel1");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/setAutoFight/3"), GuideTools.Pos.RIGHT, Vector3.New(100, 0, 0));
        seq:AddToCache("GuideAutoFightSetting3", effect);
    end
    seq:SetCacheDisplay("GuideAutoFightSetting3");
    
    local wait = SequenceCommand.UI.PanelOpened("UI_AutoUseDrugPanel");
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.AUTO_FIGHT_TAB, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideAutoFightSetting.D); end));
	GuideContent.AddCloseFun(wait, "UI_AutoFightPanel", function() GuideAutoFightSetting.ReturnA(seq) end);
	return wait;

end

--选中回复Hp药物
function GuideAutoFightSetting.F(seq)
	if seq:GetCache("GuideAutoFightSetting4") == nil then
		local panel = PanelManager.GetPanelByType("UI_AutoUseDrugPanel");
		local btn = panel:GetTransformByPath("trsContent/listPanel/subPanel/table/item_0_0/product/icon");
		local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/setAutoFight/4"), GuideTools.Pos.RIGHT, Vector3.New(100, 0, 0));
		seq:AddToCache("GuideAutoFightSetting4", effect);
	end
	seq:SetCacheDisplay("GuideAutoFightSetting4");

	local filter = function(data) return data.name == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.AUTO_USE_DRUG, nil, filter);
	GuideContent.AddCloseFun(wait, "UI_AutoUseDrugPanel", function() seq:RemoveCache("GuideAutoFightSetting4"); seq:SkipAfterStep(GuideAutoFightSetting.E); end);
	return wait;
end

--点击魔法框
function GuideAutoFightSetting.G(seq)
	
	seq:RemoveCache("GuideAutoFightSetting4");

	if seq:GetCache("GuideAutoFightSetting5") == nil then
        local panel = PanelManager.GetPanelByType("UI_AutoFightPanel");
        local btn = panel:GetTransformByPath("trsContent/guajiSetPanel/leftPanel/proPanel2");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/setAutoFight/5"), GuideTools.Pos.RIGHT, Vector3.New(100, 0, 0));
        seq:AddToCache("GuideAutoFightSetting5", effect);
    end
    seq:SetCacheDisplay("GuideAutoFightSetting5");
    
    local wait = SequenceCommand.UI.PanelOpened("UI_AutoUseDrugPanel");
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.AUTO_FIGHT_TAB, nil, function(idx) return idx~= 1 end, function() seq:SkipAfterStep(GuideAutoFightSetting.D); end));
	GuideContent.AddCloseFun(wait, "UI_AutoFightPanel", function() GuideAutoFightSetting.ReturnA(seq) end);
	return wait;
end

--选中回复MP药物
function GuideAutoFightSetting.H(seq)

	if seq:GetCache("GuideAutoFightSetting6") == nil then
		local panel = PanelManager.GetPanelByType("UI_AutoUseDrugPanel");
		local btn = panel:GetTransformByPath("trsContent/listPanel/subPanel/table/item_0_0/product/icon");
		local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/setAutoFight/6"), GuideTools.Pos.RIGHT, Vector3.New(100, 0, 0));
		seq:AddToCache("GuideAutoFightSetting6", effect);
	end

	seq:SetCacheDisplay("GuideAutoFightSetting6");

	local filter = function(data) return data.name == 2 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.AUTO_USE_DRUG, nil, filter);
	GuideContent.AddCloseFun(wait, "UI_AutoUseDrugPanel", function() seq:RemoveCache("GuideAutoFightSetting6"); seq:SkipAfterStep(GuideAutoFightSetting.G); end);
	return wait;
end

function GuideAutoFightSetting.END(seq)
	return nil;
end