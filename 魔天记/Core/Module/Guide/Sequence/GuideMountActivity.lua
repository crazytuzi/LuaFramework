GuideMountActivity = class("GuideMountActivity", SequenceContent)

function GuideMountActivity.GetSteps()
    return {
      	GuideMountActivity.A
      	,GuideContent.OpenSysPanelEnd
      	,GuideMountActivity.B
      	,GuideMountActivity.DelayForPanel
      	,GuideMountActivity.C
      	,GuideMountActivity.D
      	,GuideMountActivity.E
    };
end

--点击玩家头像
function GuideMountActivity.A(seq)
	local msg = LanguageMgr.Get("guide/mountActivity/1")
	return GuideContent.OpenSysPanelStart(seq, msg);
end

--点击坐骑按钮
function GuideMountActivity.B(seq)
	local msg = LanguageMgr.Get("guide/mountActivity/2")
	return GuideContent.OpenSysItem(seq, msg, "7", "UI_RidePanel", GuideMountActivity.A);
end


function GuideMountActivity.B1(seq)
	return SequenceCommand.DelayFrame();
end

function GuideMountActivity.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_RidePanel");
end

--点击激活按钮
function GuideMountActivity.C(seq)

	if seq.errorFlag then
        return nil;
    end

	if seq:GetCache("GuideMountActivity3") == nil then
		local panel = PanelManager.GetPanelByType("UI_RidePanel");

		local trsBtn = panel:GetTransformByPath("trsContent/btnActive");
		if trsBtn == nil or trsBtn.gameObject.activeSelf == false then
		  seq:SetError();
		  return nil;
		end

		local msg = LanguageMgr.Get("guide/mountActivity/3");
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsBtn, "ui_guide_1", msg, GuideTools.Pos.UP, Vector3.New(0, 70 ,0));

		seq:AddToCache("GuideMountActivity3", effect);
	end

	seq:SetCacheDisplay("GuideMountActivity3");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.MOUNT_ACITVITY);
	GuideContent.AddCloseFun(wait, "UI_RidePanel", function() 
		seq:RemoveCache("GuideMountActivity3");
		seq:SkipAfterStep(GuideMountActivity.A);
	end);

	return wait;
end

--点击使用按钮
function GuideMountActivity.D(seq)
	if seq.errorFlag then
		return nil;
	end

	if seq:GetCache("GuideMountActivity4") == nil then
		local panel = PanelManager.GetPanelByType("UI_RidePanel");

		local trsBtn = panel:GetTransformByPath("trsContent/btnUse");
		if trsBtn == nil or trsBtn.gameObject.activeSelf == false then
		  seq:SetError();
		  return nil;
		end

		local msg = LanguageMgr.Get("guide/mountActivity/4");
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsBtn, "ui_guide_1", msg, GuideTools.Pos.UP, Vector3.New(0, 70 ,0));

		seq:AddToCache("GuideMountActivity4", effect);
	end

	seq:SetCacheDisplay("GuideMountActivity4");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.MOUNT_USE);
	GuideContent.AddCloseFun(wait, "UI_RidePanel", function() 
		seq:RemoveCache("GuideMountActivity3");
		seq:RemoveCache("GuideMountActivity4");
		seq:SkipAfterStep(GuideMountActivity.A);
	end);

	return wait;
end

--点击返回主界面
function GuideMountActivity.E(seq)
	if seq.errorFlag then
		return nil;
	end

	if seq:GetCache("GuideMountActivity5") == nil then
		local panel = PanelManager.GetPanelByType("UI_RidePanel");

		local trsBtn = panel:GetTransformByPath("trsContent/btn_close");
		local msg = LanguageMgr.Get("guide/mountActivity/5");
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsBtn, "ui_guide_1", msg, GuideTools.Pos.RIGHT, Vector3.New(70, -13, 0));

		seq:AddToCache("GuideMountActivity5", effect);
	end

	seq:SetCacheDisplay("GuideMountActivity5");

	local filter = function(name) return name == "UI_RidePanel" end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter);
	return wait;
end
