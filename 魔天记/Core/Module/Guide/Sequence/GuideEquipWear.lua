GuideEquipWear = class("GuideEquipWear", SequenceContent)

function GuideEquipWear.GetSteps()
    return {
    	GuideEquipWear.A
		,GuideEquipWear.B
		,GuideEquipWear.C
		,GuideEquipWear.D
		,GuideEquipWear.End
    };
end

function GuideEquipWear.A(seq)
	TaskManager.StopAuto();
	local msg = LanguageMgr.Get("guide/equipwear/1");
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local btn = panel:GetTransformByPath("UI_Bottom/btnBackPack").gameObject;
	local wait = SequenceCommand.UI.PanelOpened("UI_BackpackPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.UP, Vector3.New(0, 45, 0), true);
end

local panelName = "";
local equipIds = {[101000] = 301410; [102000] = 302410; [103000] = 303410; [104000] = 304410}
local tmpId = 0;
--打开背包
function GuideEquipWear.B(seq)
	if seq.errorFlag then
        return nil;
    end
    local kind = PlayerManager.GetPlayerKind();
    tmpId = equipIds[kind];
    local item = BackpackDataManager.GetProductBySpid(tmpId);
    if item == nil or item.am < 1 then
    	seq:SetError("can't find equip - " .. tmpId);
    	return nil;
    end

    local eq = EquipDataManager.GetProductByKind(1);
    if eq then
    	panelName = "UI_EquipComparisonTipPanel";
    else
    	panelName = "UI_EquipTipPanel";
    end

	ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = item, type = ProductCtrl.TYPE_FROM_BACKPACK });
    --local wait = SequenceCommand.WaitForEvent(SequenceEventType.FOREVER);
	--wait:AddEvent(SequenceCommand.UI.PanelOpened("UI_EquipComparisonTipPanel"));

    return SequenceCommand.UI.PanelOpened(panelName);
end

--打开对比tip引导穿戴
function GuideEquipWear.C(seq)
	if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/equipwear/2");
	local panel = PanelManager.GetPanelByType(panelName);
	if not panel then
		seq:SetError("can't find panel - " .. panelName);
		return nil;
	end

	local btn = panel:GetMenuBt(ProducTipsManager.fun_equip_chuandai);
	if not btn then
		seq:SetError("can't find btn - dressEq");
		return nil;
	end
	btn = btn.gameObject;

	--local filter = function(info) return info:GetSpId() == tmpId end;
	--local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.EQUIP_WEAR, nil, filter);
	local wait = SequenceCommand.UI.PanelClosed(panelName);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-70, 0, 0), true);
end

--点击返回
function GuideEquipWear.D(seq)
	if seq.errorFlag then
        return nil;
    end

	local msg = LanguageMgr.Get("guide/equipwear/3");
	local panel = PanelManager.GetPanelByType("UI_BackpackPanel");
	local btn = panel:GetTransformByPath("trsContent/btn_close").gameObject;
	local wait = SequenceCommand.UI.CloseBtnClick("UI_BackpackPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0), true);
end

function GuideEquipWear.End()
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return nil;
end
