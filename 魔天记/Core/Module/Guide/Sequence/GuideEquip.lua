GuideEquip = class("GuideEquip", SequenceContent)

function GuideEquip.GetSteps()
    return {
    	GuideEquip.A
		,GuideContent.GuideSysPanelEnd
		,GuideEquip.B
		,GuideEquip.DelayForPanel
		 ,GuideEquip.C
		 ,GuideEquip.D
		 ,GuideEquip.E
		 ,GuideEquip.E2
		 ,GuideEquip.F
		,GuideContent.ForceEnd
    };
end

function GuideEquip.A(seq)
	return GuideContent.GuideSysPanelStart(seq, LanguageMgr.Get("guide/equip/1"), true);
end

--点击锻造按钮
function GuideEquip.B(seq)
	local msg = LanguageMgr.Get("guide/equip/2");
	return GuideContent.GuideSysItem(seq, msg, "2", "UI_EquipPanel");
end

function GuideEquip.DelayForPanel(seq)
	return SequenceCommand.UI.PanelOpened("UI_EquipPanel");
end

--选中武器部位
function GuideEquip.C(seq)
	local eq = EquipDataManager.GetProductByKind(1);
    if eq == nil then
    	seq:SetError("没有穿戴装备");
    	seq:SkipAfterStep(GuideEquip.F);
    	return nil;
    end

	return SequenceCommand.DelayFrame();
end

--点击附灵tab
function GuideEquip.D(seq)
	--[[
	local msg = LanguageMgr.Get("guide/equip/4");
	local panel = PanelManager.GetPanelByType("UI_EquipPanel");
	local btn = panel:GetTransformByPath("trsContent/product_tabs/classify_1");
	local anchorTr = UIUtil.GetChildByName(btn, "bts/icon");
	local filter = function(index) return index == 1 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_CHANGE_PANEL, nil, filter);
    return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, anchorTr, wait, GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), true);
    ]]
    return SequenceCommand.DelayFrame();
end

--选中吞噬道具
function GuideEquip.E(seq)
	local msg = LanguageMgr.Get("guide/equip/5");
	local panel = PanelManager.GetPanelByType("UI_EquipPanel");
	local itemTr = panel:GetTransformByPath("trsContent/fuling/rightPanel/panel3/ScrollView/es_phalanx/ProductCostPanel_0_0");
	if itemTr == nil then
    	seq:SetError("没有强化道具");
    	seq:SkipAfterStep(GuideEquip.F);
    	return nil;
	end
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_FL_SELECT);
	return SequenceCommand.Guide.GuideClickUI(msg, itemTr.gameObject, nil, wait, GuideTools.Pos.UP, Vector3.New(0, 45, 0), true);
end

--延迟1帧等待刷新界面
function GuideEquip.E2(seq)
	if seq.errorFlag then
        return nil;
    end
	return SequenceCommand.DelayFrame();
end

--点击强化按钮
function GuideEquip.F(seq)
	if seq.errorFlag then
        return nil;
    end
	local msg = LanguageMgr.Get("guide/equip/6");
	local panel = PanelManager.GetPanelByType("UI_EquipPanel");
	local btn = panel:GetTransformByPath("trsContent/fuling/rightPanel/panel3/btn_fuling").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_FL_OPT);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.UP, Vector3.New(0, 45, 0), true);
end
--[[
--点击返回主界面
function GuideEquip.G(seq)
	if seq.errorFlag then
        return nil;
    end
	local msg = LanguageMgr.Get("guide/equip/7");
	local panel = PanelManager.GetPanelByType("UI_EquipPanel");
	local btn = panel:GetTransformByPath("trsContent/btn_close").gameObject;
	local wait = SequenceCommand.UI.CloseBtnClick("UI_EquipPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0), true);
end
]]

