GuideMingXing = class("GuideMingXing", SequenceContent);

function GuideMingXing.GetSteps()
    return {
    	GuideMingXing.START
    	,GuideMingXing.A1
    	,GuideMingXing.A1_1
    	,GuideMingXing.A2
    	,GuideMingXing.A3
    	,GuideMingXing.A4
    	,GuideMingXing.CHECK
    	,GuideMingXing.B1
    	,GuideContent.GuideSysPanelEnd
    	,GuideMingXing.B2
    	,GuideMingXing.DelayForPanel
    	,GuideMingXing.B3
    	,GuideMingXing.B4
    	,GuideContent.ForceEnd
    };
end

local panelName1 = "UI_ActivityPanel"
local panelName2 = "UI_XLTInstancePanel"
local panelName3 = "UI_StarPanel";
local panelName4 = "UI_StarBagPanel";

--检查名星塔层数
function GuideMingXing.START(seq)
	local val = InstanceDataManager.GetXLTHasPassCen();
	if val > 0 then
		--如果层数大于0 则直接进入装配流程
		seq:SkipAfterStep(GuideMingXing.CHECK);
	end
	return nil;
end

--流程A引导挑战虚灵塔
--A1 点击日常按钮
function GuideMingXing.A1(seq)
    local msg = LanguageMgr.Get("guide/GuideMingXing/A1");
	return GuideContent.GuideActItem(seq, msg, "72", panelName1);
end

function GuideMingXing.A1_1(seq)
	return SequenceCommand.UI.PanelOpened(panelName1);
end

--A2 点击命星塔按钮
function GuideMingXing.A2(seq)
    if seq.errorFlag then
        return nil;
    end

	local msg = LanguageMgr.Get("guide/GuideMingXing/A2");
	local panel = PanelManager.GetPanelByType(panelName1);
	local btn = panel:GetTransformByPath("trsContent/mainView/RiChangActivityPanel/ScrollView/bag_phalanx/page_0_0/8/doBt");

	if btn == nil then
		seq:SetError("can't find btn ");
		return nil;
	end

    local wait = SequenceCommand.UI.PanelOpened(panelName2);
    return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45, 0), true);
end

--A3 点击命星塔挑战按钮
function GuideMingXing.A3(seq)
	if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideMingXing/A3");
	local panel = PanelManager.GetPanelByType(panelName2);
	local btn = panel:GetTransformByPath("trsContent/mainView/rightPanel/tiaozhanBt").gameObject;

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.XLT_TIAOZHAN);
    return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.TOP_LEFT, Vector3.New(0, 45, 0), true);
end

--A4 等待切换出野外场景
function GuideMingXing.A4(seq)

	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);

	if seq.errorFlag then
        return nil;
    end

    --检测场景 从虚灵塔->野外
	local filter = function(mapId) 
		local cfg = ConfigManager.GetMapById(mapId);
		if cfg.type == InstanceDataManager.MapType.Field and GameSceneManager.old_id then
			local oCfg = InstanceDataManager.GetInsByMapId(GameSceneManager.old_id);
			return oCfg and oCfg.type == InstanceDataManager.InstanceType.XuLingTaInstance;
		end
		return false;
	end;
	return SequenceCommand.WaitForEvent(SequenceEventType.Base.MOVE_TO_SCENE, nil, filter);
end

--检查步骤
--如果命星塔层数>1则进入B流程
--如果命星塔层数<=1 则是命星塔挑战失败 终止引导。
function GuideMingXing.CHECK(seq)

	if seq.errorFlag then
        return nil;
    end
    local err = false;
    local star = StarManager.GetDataBydIdx(0);

    if star ~= nil then 
    	seq:SetError("already embed star in slot");
    	err = true;
    end

	local val = InstanceDataManager.GetXLTHasPassCen();
	if star ~= nil or val <= 0 then
		seq:SetError("xlt fight lose..");
		err = true;
	end

	if err then
		seq:SkipAfterStep(GuideMingXing.B4);
	end
	return nil;
end

--流程B 引导装配命星
--B1 点击左上角头像
function GuideMingXing.B1(seq)
	if seq.errorFlag then
        return nil;
    end

	local msg = LanguageMgr.Get("guide/GuideMingXing/B1");
    return GuideContent.GuideSysPanelStart(seq, msg, true);
end

--B2 点击命星功能
function GuideMingXing.B2(seq)
	if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideMingXing/B2");
	return GuideContent.GuideSysItem(seq, msg, "6", panelName3);
end

function GuideMingXing.DelayForPanel(seq)
	if seq.errorFlag then
        return nil;
    end
    return SequenceCommand.UI.PanelOpened(panelName3);
end

--B3 点击命星位+号
function GuideMingXing.B3(seq)
	if seq.errorFlag then
        return nil;
    end

	local msg = LanguageMgr.Get("guide/GuideMingXing/B3");
	local panel = PanelManager.GetPanelByType(panelName3);
	local btn = panel:GetTransformByPath("trsContent/trsStar/stars/item1").gameObject;

    local wait = SequenceCommand.UI.PanelOpened(panelName4);
    return SequenceCommand.Guide.GuideClickUI(msg, btn, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0), true);
end

--B4 点击命星背包第一格
function GuideMingXing.B4(seq)
	if seq.errorFlag then
        return nil;
    end

    local msg = LanguageMgr.Get("guide/GuideMingXing/B4");
	local panel = PanelManager.GetPanelByType(panelName4);
	--local btn = panel:GetTransformByPath("trsContent/scrollView/phalanx/item_0_0").gameObject;
	local list = panel:GetTransformByPath("trsContent/scrollView/phalanx");
	local btn = GuideTools.GetChildByIndex(list, 2)
	if btn == nil then
    	seq:SetError();
        return nil;
    end

    local wait = SequenceCommand.UI.PanelClosed(panelName4);
    return SequenceCommand.Guide.GuideClickUI(msg, btn.gameObject, nil, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end
