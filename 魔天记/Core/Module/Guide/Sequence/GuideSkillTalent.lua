-- 技能功法提示

GuideSkillTalent = class("GuideSkillTalent", SequenceContent)

function GuideSkillTalent.GetSteps()
    return {
        GuideSkillTalent.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideSkillTalent.B
        ,GuideSkillTalent.C
        ,GuideSkillTalent.D
        ,GuideSkillTalent.E
        ,GuideSkillTalent.F
    };
end

local panelName = "UI_SkillPanel"

--清除面板上的引导特效
function GuideSkillTalent._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
end

--监听面板关闭按钮事件
function GuideSkillTalent._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuideSkillTalent._ClearEffect(seq)
        seq:SkipAfterStep(GuideSkillTalent.A);
    end );
end

--监听面板Tab事件
function GuideSkillTalent._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.SKILL_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 3) then
            seq:SkipAfterStep(GuideSkillTalent.C);
        end
    end );
end

-- 引导点击玩家头像
function GuideSkillTalent.A(seq)
    local msg = LanguageMgr.Get("guide/GuideSkillTalent/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击技能按钮
function GuideSkillTalent.B(seq)
    local msg = LanguageMgr.Get("guide/GuideSkillTalent/2");
    return GuideContent.OpenSysItem(seq, msg, "3", panelName, GuideSkillTalent.A);
end

-- 引导点击功法标签
function GuideSkillTalent.C(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnTalent/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideSkillTalent/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");

    local filter = function(index) return index == 3 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_CHANGE_PANEL, nil, filter);
    wait:AddEvent(GuideSkillTalent._OnCloseEvent(seq));
    wait:AddEvent(GuideSkillTalent._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击技能按钮
function GuideSkillTalent.D(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/panels/talentPanel/trsTalentDetail/detail1/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideSkillTalent/4"), GuideTools.Pos.UP, Vector3.New(0, 55, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_TALENT_SKILL_CHANGE);
    wait:AddEvent(GuideSkillTalent._OnCloseEvent(seq));
    wait:AddEvent(GuideSkillTalent._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击确认使用按钮
function GuideSkillTalent.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/panels/talentPanel/btnConfirm");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideSkillTalent/4"), GuideTools.Pos.UP, Vector3.New(0, 55, 0));
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_TALENT_CONFIRM);
    wait:AddEvent(GuideSkillTalent._OnCloseEvent(seq));
    wait:AddEvent(GuideSkillTalent._OnTabChangeEvent(seq));
    return wait;
end

-- 点击返回主界面
function GuideSkillTalent.F(seq)
    -- 如果引导出错了 返回nil.
    GuideSkillTalent._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end