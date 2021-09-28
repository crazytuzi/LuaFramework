GuideJoinGuild = class("GuideJoinGuild", SequenceContent)

function GuideJoinGuild.GetSteps()
    return {
      	GuideJoinGuild.A
      	,GuideContent.OpenSysPanelEnd
      	,GuideJoinGuild.B
      	,GuideJoinGuild.B2
      	,GuideJoinGuild.C
      	,GuideJoinGuild.D
    };
end

--引导点击玩家头像
function GuideJoinGuild.A(seq)
	local msg = LanguageMgr.Get("guide/guild/1")
	return GuideContent.OpenSysPanelStart(seq, msg);
end

--引导点击仙盟按钮
function GuideJoinGuild.B(seq)
	local msg = LanguageMgr.Get("guide/guild/2");
	local wait = GuideContent.OpenSysItem(seq, msg, "9", "UI_GuildReqListPanel", GuideJoinGuild.A);
	wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.PANEL_INIT, nil, function(panel) return panel == "UI_GuildPanel"; end, function() seq:SetError("GuideJoinGuild.B"); seq:SkipAfterStep(GuideJoinGuild.D); end));
	return wait;
end

--延迟等待数据.
function GuideJoinGuild.B2(seq)
	seq:SetCacheDisplay("");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.GUILD_REQ_LIST);
	GuideContent.AddCloseFun(wait, "UI_GuildReqListPanel", function() 
		seq:SkipAfterStep(GuideJoinGuild.A); 
	end);
	return wait;
end

--引导点击申请仙盟
function GuideJoinGuild.C(seq)

	if seq.errorFlag then
        return nil;
    end
    
	if seq:GetCache("guideReqItem") == nil then

		local panel = PanelManager.GetPanelByType("UI_GuildReqListPanel");

		if panel  == nil then
			seq:SetError();
			return nil;
		end

		local listTr = panel:GetTransformByPath("trsContent/trsList/phalanx");

		--没有仙盟
		if listTr.childCount <= 1 then
			--log("[ff0000]error - > no guild in list [-]");
			seq:SetError();
			return nil;
		end
		local max = math.min(listTr.childCount - 2, 6);
		local idx = math.random(0, max);
		local trsItem = UIUtil.GetChildByName(listTr.gameObject, "item_"..idx.."_0");
		local trsBtn = UIUtil.GetChildByName(trsItem, "Transform", "btnJoin");
		--已经申请了
		if trsItem == nil or trsBtn.gameObject.activeSelf == false then
			--log("[ff0000]error - > req is already [-]");
			seq:SetError();
			return nil;
		end

		--local icoBtn = UIUtil.GetChildByName(trsItem, "UISprite", "btnJoin");
		local msg = LanguageMgr.Get("guide/guild/3");
		local effect = GuideTools.AddEffectAndTitleToGameObject(trsBtn, "ui_guide_1", msg, GuideTools.Pos.DOWN, Vector3.New(0, -45 ,0));

    	seq:AddToCache("guideReqItem", effect);
	end

	seq:SetCacheDisplay("guideReqItem");

	local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.GUILD_REQ_JOIN);

	GuideContent.AddCloseFun(wait, "UI_GuildReqListPanel", function() 
		--删除申请加入的特效.
		seq:RemoveCache("guideReqItem");
		seq:SkipAfterStep(GuideJoinGuild.A); 
	end);
	
	return wait;
end

--点击返回主界面
function GuideJoinGuild.D(seq)
	--如果引导出错了 返回nil.
	if seq.errorFlag then
		return nil;
	end
	--todo
end
