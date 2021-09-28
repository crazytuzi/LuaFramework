GuideZongMenLiLian = class("GuideZongMenLiLian", SequenceContent);

function GuideZongMenLiLian.GetSteps()
    return {
        GuideZongMenLiLian.A
      	,GuideContent.OpenActPanelEnd
      	,GuideZongMenLiLian.B
        ,GuideZongMenLiLian.DelayForPanel
        ,GuideZongMenLiLian.C
        ,GuideZongMenLiLian.C2
        ,GuideZongMenLiLian.D
        ,GuideZongMenLiLian.E
    };
end
--点击右侧活动栏
function GuideZongMenLiLian.A(seq)
	local msg = LanguageMgr.Get("guide/GuideZongMenLiLian/1");
	return GuideContent.OpenActPanelStart(seq, msg);
end

--点击活动按钮
function GuideZongMenLiLian.B(seq)
	local msg = LanguageMgr.Get("guide/GuideZongMenLiLian/2");
    return GuideContent.OpenActItem(seq,msg,"72", "UI_ActivityPanel", GuideZongMenLiLian.A);
end

function GuideZongMenLiLian.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened("UI_ActivityPanel");
end

--点击日常副本标签
function GuideZongMenLiLian.C(seq)
    
    if seq.errorFlag then
        return nil;
    end

	if seq:GetCache("GuideZongMenLiLian3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/trsToggle/btnRiChangFB/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideZongMenLiLian/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 15, 0));
        seq:AddToCache("GuideZongMenLiLian3", effect);
    end
    seq:SetCacheDisplay("GuideZongMenLiLian3");
	
	local filter = function(index) return index == 2 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, filter);

	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() 
	    seq:RemoveCache("GuideZongMenLiLian3");
	    seq:SkipAfterStep(GuideZongMenLiLian.A);
	  end);
	return wait;
end

--延迟一帧等待显示.
function GuideZongMenLiLian.C2(seq)
    return SequenceCommand.DelayFrame();
end

--点击宗门历练图片
function GuideZongMenLiLian.D(seq)
	if seq.errorFlag then
		return nil;
	end

	if seq:GetCache("GuideZongMenLiLian4") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ActivityPanel");
        local btn = panel:GetTransformByPath("trsContent/mainView/RiChangFBPanel/ScrollView/bag_phalanx/page_0_0/25/fbIcon");
        if btn == nil then
            seq:SetError();
            return nil;
        end
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideZongMenLiLian/4"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("GuideZongMenLiLian4", effect);
    end
    seq:SetCacheDisplay("GuideZongMenLiLian4");
	
	local wait = SequenceCommand.UI.PanelOpened("UI_ZongMenLiLianPanel");

    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.ACTIVITY_CHANGE_PANEL, nil, function(idx) return idx~= 2 end, function() seq:SkipAfterStep(GuideZongMenLiLian.C); end));

	GuideContent.AddCloseFun(wait, "UI_ActivityPanel", function() 
	    seq:RemoveCache("GuideZongMenLiLian3");
	    seq:RemoveCache("GuideZongMenLiLian4");
	    seq:SkipAfterStep(GuideZongMenLiLian.A);
	  end);
	return wait;
end

--点击匹配按钮
function GuideZongMenLiLian.E(seq)
	if seq.errorFlag then
		return nil;
	end

	if seq:GetCache("GuideZongMenLiLian5") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_ZongMenLiLianPanel");
        local btn = panel:GetTransformByPath("trsContent/mainView/bottomPanel/btnpipei");
        if btn == nil then
            seq:SetError();
            return nil;
        end
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideZongMenLiLian/5"), GuideTools.Pos.UP, Vector3.New(0, 50, 0));
        seq:AddToCache("GuideZongMenLiLian5", effect);
    end
    seq:SetCacheDisplay("GuideZongMenLiLian5");

    local filter = function(index) return index == 1 end;
	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.ZONGMEN_MATCH);
	GuideContent.AddCloseFun(wait, "UI_ZongMenLiLianPanel", function() 
	    seq:RemoveCache("GuideZongMenLiLian5");
	    seq:SkipAfterStep(GuideZongMenLiLian.D);
	  end);
	return wait;
end