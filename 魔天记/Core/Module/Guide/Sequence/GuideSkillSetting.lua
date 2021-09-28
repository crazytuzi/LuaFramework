--技能配置提示

GuideSkillSetting = class("GuideSkillSetting", SequenceContent)

function GuideSkillSetting.GetSteps()
    return {
        GuideSkillSetting.A
        ,GuideContent.OpenSysPanelEnd
        ,GuideSkillSetting.B
        ,GuideSkillSetting.DelayForPanel
        ,GuideSkillSetting.C
        ,GuideSkillSetting.D
        ,GuideSkillSetting.E
        ,GuideSkillSetting.F
    };
end

local panelName = "UI_SkillPanel"

--清除面板上的引导特效
function GuideSkillSetting._ClearEffect(seq)
    -- 删除特效.
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
end

--监听面板关闭按钮事件
function GuideSkillSetting._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
     return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK,nil,filter,function()
        GuideSkillSetting._ClearEffect(seq)
        seq:SkipAfterStep(GuideSkillSetting.A);    
    end );
end

--监听面板Tab事件
function GuideSkillSetting._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.SKILL_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 2) then
            seq:SkipAfterStep(GuideSkillSetting.C);
        end
    end);
end

function GuideSkillSetting.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuideSkillSetting.A(seq)
    local msg = LanguageMgr.Get("guide/GuideSkillSetting/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击技能按钮
function GuideSkillSetting.B(seq)
    local msg = LanguageMgr.Get("guide/GuideSkillSetting/2");
    return GuideContent.OpenSysItem(seq,msg,"3",panelName,GuideSkillSetting.A);
end

-- 引导点击配置标签
function GuideSkillSetting.C(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem1") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end
        local btn = panel:GetTransformByPath("trsContent/btnSetting/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideSkillSetting/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
        seq:AddToCache("guideReqItem1", effect);
    end
    seq:SetCacheDisplay("guideReqItem1");
    local filter = function(index) return index == 2 end;
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_CHANGE_PANEL,nil,filter);
    wait:AddEvent(GuideSkillSetting._OnCloseEvent(seq));
    wait:AddEvent(GuideSkillSetting._OnTabChangeEvent(seq));
    return wait;
end

-- 引导点击技能按钮
function GuideSkillSetting.D(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem2") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/panels/settingPanel/skillList/phalanx/item_0_0/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideSkillSetting/4"), GuideTools.Pos.UP, Vector3.New(0, 55, 0));
        seq:AddToCache("guideReqItem2", effect);
    end
    seq:SetCacheDisplay("guideReqItem2");
    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_SETTING_TOUCH_BEGIN);    
    wait:AddEvent(GuideSkillSetting._OnCloseEvent(seq));
    wait:AddEvent(GuideSkillSetting._OnTabChangeEvent(seq));
    return wait;
end

-- 引导拖动到技能按钮
function GuideSkillSetting.E(seq)
    -- 如果已经加过引导特效 则直接激活.
    if seq:GetCache("guideReqItem3") == nil then
        -- 找按钮
        local panel = PanelManager.GetPanelByType(panelName);
        if panel == nil then
            seq:SetError();
            return nil;
        end

        local btn = panel:GetTransformByPath("trsContent/panels/settingPanel/curSkill/skill1/icon");
        local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuideSkillSetting/5"), GuideTools.Pos.UP, Vector3.New(0, 55, 0));
        seq:AddToCache("guideReqItem3", effect);
    end
    seq:SetCacheDisplay("guideReqItem3");

    local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.SKILL_SETTING_TOUCH_END);
    wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.SKILL_SETTING_TOUCH_CANCEL, nil, nil,
    function()
        seq:SkipAfterStep(GuideSkillSetting.D);
    end ));
    return wait;
end

-- 点击返回主界面
function GuideSkillSetting.F(seq)
    -- 如果引导出错了 返回nil.
    GuideSkillSetting._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end