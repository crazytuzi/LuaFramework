GuideXuanBao = class("GuideXuanBao", SequenceContent);

function GuideXuanBao.GetSteps()
    return {
    	GuideXuanBao.A
      	,GuideContent.OpenActPanelEnd
      	,GuideXuanBao.B
        ,GuideXuanBao.B1
        ,GuideXuanBao.B2
        ,GuideXuanBao.DelayForPanel
        ,GuideXuanBao.C
    };
end

--点击右侧活动栏
function GuideXuanBao.A(seq)
	return GuideContent.OpenActPanelStart(seq, LanguageMgr.Get("guide/GuideXuanBao/1"));
end

--点击活动按钮
function GuideXuanBao.B(seq)
    return GuideContent.OpenActItem(seq, LanguageMgr.Get("guide/GuideXuanBao/2"), "500", "UI_SysExpandPanel", GuideXuanBao.A);
end

function GuideXuanBao.B1(seq)
    return SequenceCommand.WaitForEvent(SequenceEventType.Guide.SYS_EXPAND_OPEN);
end

function GuideXuanBao.B2(seq)
    return GuideContent.OpenExpand(seq, LanguageMgr.Get("guide/GuideXuanBao/2"), "77", "UI_XuanBaoPanel", GuideXuanBao.B);
end

function GuideXuanBao.DelayForPanel(seq)
    seq:RemoveCache("openExpandItem");
    return SequenceCommand.WaitForEvent(SequenceEventType.Guide.XUANBAO_UPDATE);
end

function GuideXuanBao.C(seq)
	if seq.errorFlag then
        return nil;
    end
    if seq:GetCache("GuideXuanBao3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType("UI_XuanBaoPanel");
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local list = panel:GetTransformByPath("trsContent/trsList/phalanx");
		local item = GuideTools.GetChildByIndex(list, 2);
		if item == nil then
        	seq:SetError();
            return nil;
        end
        
        local btn = UIUtil.GetChildByName(item, "Transform", "btnAward");
        if btn.gameObject.activeSelf == false then
        	seq:SetError();
            return nil;
        end
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideXuanBao/3"), GuideTools.Pos.LEFT, Vector3.New(-70, 0, 0));

        seq:AddToCache("GuideXuanBao3", effect);
    end

    seq:SetCacheDisplay("GuideXuanBao3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.XUANBAO_AWARD);
    GuideContent.AddCloseFun(wait, "UI_XuanBaoPanel", function() Warning("qqqqqqq") seq:RemoveCache("GuideXuanBao3"); seq:SkipAfterStep(GuideXuanBao.A); end);
   	return wait;
end


