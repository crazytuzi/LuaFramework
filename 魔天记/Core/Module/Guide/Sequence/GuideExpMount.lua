GuideExpMount = class("GuideExpMount", SequenceContent)

function GuideExpMount.GetSteps()
    return {
    	GuideExpMount.A
		,GuideExpMount.B
		,GuideExpMount.C
		,GuideExpMount.C2
		,GuideExpMount.D
		,GuideExpMount.E
		,GuideExpMount.End
    };
end

function GuideExpMount.A(seq)
	TaskManager.StopAuto();
	local msg = LanguageMgr.Get("guide/GuideExpMount/1");
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local btn = panel:GetTransformByPath("UI_Bottom/btnBackPack").gameObject;
	local wait = SequenceCommand.UI.PanelOpened("UI_BackpackPanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.TOP_LEFT, Vector3.New(0, 45, 0), true);
end

local itemId = 505053;
--打开背包
function GuideExpMount.B(seq)
	if seq.errorFlag then
        return nil;
    end

    local item = BackpackDataManager.GetProductBySpid(itemId);
    if item == nil or item.am < 1 then
    	seq:SetError("can't find item - " .. itemId);
    	return nil;
    end
	ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = item, type = ProductCtrl.TYPE_FROM_BACKPACK });
    return SequenceCommand.UI.PanelOpened("UI_SampleProductTipPanel");
end

--打开对比tip引导使用，并打开坐骑界面
function GuideExpMount.C(seq)
	if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideExpMount/2");
	local panel = PanelManager.GetPanelByType("UI_SampleProductTipPanel");
	local btn = panel:GetTransformByPath("trsContent/btn_menu3").gameObject;
	local filter = function(info) return info:GetSpId() == tmpId end;
	local wait = SequenceCommand.UI.PanelOpened("UI_RidePanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-70, 0, 0), true);
end

function GuideExpMount.C2(seq)
	return SequenceCommand.DelayFrame();
end

--引导点击使用
function GuideExpMount.D(seq)
	if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideExpMount/3");
	local panel = PanelManager.GetPanelByType("UI_RidePanel");
	local btn = panel:GetTransformByPath("trsContent/RidePanel/btnUse").gameObject;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.MOUNT_USE);
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.TOP_LEFT, Vector3.New(0, 45, 0), true);
end

--引导点击返回
function GuideExpMount.E(seq)
	if seq.errorFlag then
        return nil;
    end
    
    local msg = LanguageMgr.Get("guide/GuideExpMount/4");
	local panel = PanelManager.GetPanelByType("UI_RidePanel");
	local btn = panel:GetTransformByPath("trsContent/btn_close").gameObject;
	local wait = SequenceCommand.UI.CloseBtnClick("UI_RidePanel");
	return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0), true);
end

function GuideExpMount.End()
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return nil;
end