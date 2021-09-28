GuideContent = {};

--强制引导打开系统列表
function GuideContent.GuideSysPanelStart(seq, tipsMsg, showMask)
	showMask = showMask or true;
	tipsMsg = tipsMsg or LanguageMgr.Get("guide/sys/1");

	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");

	if panel:SysPanelIsExpand() then
		seq:SkipAfterStep(GuideContent.GuideSysPanelEnd);
		return nil;
	end

	local heroIcon = panel:GetTransformByPath("UI_HeroHeadPanel/trsContent/imgIcon");
	local heroMask = panel:GetTransformByPath("UI_HeroHeadPanel/trsContent/trsHeadMask");
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_HERO_HEAD_TOGGLE);
	return SequenceCommand.Guide.GuideClickUI(tipsMsg, {heroIcon.gameObject, heroMask.gameObject}, nil, wait, GuideTools.Pos.RIGHT, Vector3.New(70, 0, 0), showMask);
end

function GuideContent.GuideSysPanelEnd(seq)
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_SYSLIST_SHOW);
end

--强制引导点击系统图标
function GuideContent.GuideSysItem(seq, tipsMsg, btnId, panelName)
	local trsBtn = GuideContent.GetSysItem(btnId);
	local btnGo = nil;
	if trsBtn then 
		btnGo = trsBtn.gameObject;
	end
	if btnGo == nil then
		seq:SetError();
		return nil;
	end
	GuideManager.forceSysGo = btnGo;
	local wait = SequenceCommand.UI.ForcePanelInit(panelName);
	return SequenceCommand.Guide.GuideClickUI(tipsMsg, btnGo, nil, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end

--强制引导打开活动列表
function GuideContent.GuideActPanelStart(seq, tipsMsg)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");

	if panel:ActPanelIsExpand() then
		seq:SkipAfterStep(GuideContent.GuideActPanelEnd);
		return nil;
	end

	local btn = panel:GetTransformByPath("UI_SysPanel/togAct");
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_ACTLIST_TOGGLE);
	return SequenceCommand.Guide.GuideClickUI(tipsMsg, btn, nil, wait, GuideTools.Pos.LEFT, Vector3.New(-70, 0, 0), true);
end

function GuideContent.GuideActPanelEnd(seq)
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_ACTLIST_SHOW);
end

function GuideContent.GuideActItem(seq, tipsMsg, btnId, panelName)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local actListGo = nil;
	local trsIcon = nil;

	if panel:ActPanelIsExpand() then
		trsIcon = GuideContent._GetActItem1(btnId);
	else
		trsIcon = GuideContent._GetActItem2(btnId);
	end

	--找不到, 系统未开放.
	if trsIcon == nil then
		seq:SetError();
		return nil;
	end

	--等待panelName打开.
	local wait = SequenceCommand.UI.PanelInit(panelName);
	return SequenceCommand.Guide.GuideClickUI(tipsMsg, trsIcon.gameObject, nil, wait, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45, 0), true);
end
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

--给触发器新增一个带参数的事件
function GuideContent.AddEvent(trigger, event, param, func)
	local filter = nil;
	if param then 
		filter = function(p) return p == param end;
	end
	trigger:AddEvent(SequenceEvent.Create(event, nil, filter, func));
	return trigger;
end

--给触发器新增一个关闭事件
function GuideContent.AddCloseFun(trigger, panelName, func)
	GuideContent.AddEvent(trigger, SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, panelName, func);
	return trigger;
end

--开放引导打开系统列表
function GuideContent.OpenSysPanelStart(seq, tipsMsg)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");

	if panel:SysPanelIsExpand() then
		seq:SkipAfterStep(GuideContent.OpenSysPanelEnd);
		return nil;
	end

	if seq:GetCache("openSysPanel") == nil then
		local heroIcon = panel:GetTransformByPath("UI_HeroHeadPanel/trsContent/imgIcon");
    	local effect = GuideTools.AddEffectAndTitleToGameObject(heroIcon, "ui_guide_1", tipsMsg, GuideTools.Pos.RIGHT, Vector3.New(70, 0 ,0), 1);
		seq:AddToCache("openSysPanel", effect);
	end

	seq:SetCacheDisplay("openSysPanel");

	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_HERO_HEAD_TOGGLE);
end

function GuideContent.OpenSysPanelEnd(seq)
	seq:SetCacheDisplay("");
	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_SYSLIST_SHOW_START);
end

-------------------------------------------------
--开放引导打开活动列表
function GuideContent.OpenActPanelStart(seq, tipsMsg)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");

	if panel:ActPanelIsExpand() then
		seq:SkipAfterStep(GuideContent.OpenActPanelEnd);
		return nil;
	end

	if seq:GetCache("openActPanel") == nil then
		local btn = panel:GetTransformByPath("UI_SysPanel/togAct");
		local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", tipsMsg, GuideTools.Pos.LEFT, Vector3.New(-70, 0, 0));
		seq:AddToCache("openActPanel", effect);
	end

	seq:SetCacheDisplay("openActPanel");

	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_ACTLIST_TOGGLE);
end

function GuideContent.OpenActPanelEnd(seq)
	seq:SetCacheDisplay("");
	return SequenceCommand.WaitForEvent(SequenceEventType.Guide.MAINUI_ACTLIST_SHOW);
end

-------------------------------------------------
--开放引导点击系统图标
function GuideContent.OpenSysItem(seq, tipsMsg, btnId, panelName, cancelStep)
	--如果已经加过引导特效 则直接激活.
	if seq:GetCache("openSysItem") == nil then
		--找到系统按钮
		local trsBtn = GuideContent.GetSysItem(btnId);
		local trsIcon = UIUtil.GetChildByName(trsBtn, "icon");
		--找不到, 系统未开放.
		if trsIcon == nil then
			seq:SetError();
			return nil;
		end
		--添加引导特效
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsIcon, "ui_guide_1", tipsMsg, GuideTools.Pos.BOTTOM_RIGHT, Vector3.New(0, -45 ,0));
		--缓存gameObject
		seq:AddToCache("openSysItem", effect); 
	end

	seq:SetCacheDisplay("openSysItem");

	--等待panelName打开.
	local wait = SequenceCommand.UI.PanelInit(panelName);
	--监听系统按钮栏隐藏时, 触发回滚到cancelStep
	
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.MAINUI_SYSLIST_HIDE, nil, nil, function() seq:SkipAfterStep(cancelStep); end));
	return wait;
end

-------------------------------------------------
--开放引导点击活动图标
function GuideContent.OpenActItem(seq, tipsMsg, btnId, panelName, cancelStep)
	if seq:GetCache("openActItem") == nil then
		--local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
		--local actListGo = panel:GetTransformByPath("UI_SysPanel/trsAct/actPhalanx").gameObject;
		local trsIcon = GuideContent._GetActItem1(btnId) --UIUtil.GetChildByName(actListGo, btnId .. "/icon");
		if trsIcon then
			trsIcon = UIUtil.GetChildByName(trsIcon.gameObject, "icon");
		end
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsIcon, "ui_guide_1", tipsMsg, GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45 ,0));
		seq:AddToCache("openActItem", effect);
	end

	seq:SetCacheDisplay("openActItem");
	
	local wait = SequenceCommand.UI.PanelInit(panelName);
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.MAINUI_ACTLIST_HIDE, nil, nil, function() seq:SkipAfterStep(cancelStep); end));
	return wait;
end

function GuideContent.OpenActItem2(seq, tipsMsg, btnId, panelName)
	if seq:GetCache("openActItem") == nil then
		--local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
		--local actListGo = panel:GetTransformByPath("UI_SysPanel/trsAct2/actPhalanx").gameObject;
		local trsIcon = GuideContent._GetActItem2(btnId) --UIUtil.GetChildByName(actListGo, btnId .. "/icon");
		if trsIcon then
			trsIcon = UIUtil.GetChildByName(trsIcon.gameObject, "icon");
		end
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsIcon, "ui_guide_1", tipsMsg, GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45 ,0));
		seq:AddToCache("openActItem", effect);
	end

	seq:SetCacheDisplay("openActItem");
	
	local wait = SequenceCommand.UI.PanelInit(panelName);
	return wait;
end

function GuideContent.OpenExpand(seq, tipsMsg, btnId, panelName, cancelStep)
	seq:SetCacheDisplay("");
	if seq:GetCache("openExpandItem") == nil then
		local panel = PanelManager.GetPanelByType("UI_SysExpandPanel");
		local listGo = panel:GetTransformByPath("trsContent/phalanx").gameObject;
		local trsIcon = UIUtil.GetChildByName(listGo, btnId .. "/icon");
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsIcon, "ui_guide_1", tipsMsg, GuideTools.Pos.BOTTOM_LEFT, Vector3.New(0, -45 ,0));
		seq:AddToCache("openExpandItem", effect);
	end

	seq:SetCacheDisplay("openExpandItem");
	
	local wait = SequenceCommand.UI.PanelInit(panelName);
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.SYS_EXPAND_CLOSE, nil, nil, function() seq:RemoveCache("openExpandItem"); seq:SkipAfterStep(cancelStep); end));
	return wait;
end


--延迟一帧,等待界面初始化  
function GuideContent.DelayForPanel()
	return SequenceCommand.DelayFrame();
end

function GuideContent.ForceEnd(seq)
	ModuleManager.SendNotification(GuideNotes.CLOSE_GUIDE_CLICK);
    return nil;
end

function GuideContent.GetSysItem(sysId)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel")
	local sysListGo = panel:GetTransformByPath("UI_SysPanel/trsSys/sysPhalanx").gameObject;
	local trsItem = UIUtil.GetChildByName(sysListGo, tostring(sysId));
	return trsItem;
end

function GuideContent.GetActItem(sysId)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel")
	if panel:ActPanelIsExpand() then
		return GuideContent._GetActItem1(sysId);
	else
		return GuideContent._GetActItem2(sysId);
	end
end

function GuideContent._GetActItem1(sysId)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local actListGo = panel:GetTransformByPath("UI_SysPanel/trsAct").gameObject;

	for i = 1, 3 do
		local trsItem = UIUtil.GetChildByName(actListGo, "actPhalanx" .. i .. "/" .. sysId);
		if trsItem then
			return trsItem;
		end
	end

	return nil;
end

function GuideContent._GetActItem2(sysId)
	local panel = PanelManager.GetPanelByType("UI_MainUIPanel");
	local actListGo = panel:GetTransformByPath("UI_SysPanel/trsAct2").gameObject;

	for i = 1, 3 do
		local trsItem = UIUtil.GetChildByName(actListGo, "actPhalanx" .. i .. "/" .. sysId);
		if trsItem then
			return trsItem;
		end
	end
	
	return nil;
end
