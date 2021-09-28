-- 宠物法阵提示

GuidePetFormation = class("GuidePetFormation", SequenceContent)

function GuidePetFormation.GetSteps()
    return {
        GuidePetFormation.A
        ,GuideContent.OpenSysPanelEnd
        ,GuidePetFormation.B
        ,GuidePetFormation.DelayForPanel
        ,GuidePetFormation.C
        ,GuidePetFormation.D
        ,GuidePetFormation.E
        ,GuidePetFormation.F
    };
end

local panelName = "UI_PetPanel"

-- 清除面板上的引导特效
function GuidePetFormation._ClearEffect(seq)
    seq:RemoveCache("guideReqItem1");
    seq:RemoveCache("guideReqItem2");
    seq:RemoveCache("guideReqItem3");
end

-- 监听面板关闭按钮事件
function GuidePetFormation._OnCloseEvent(seq)
    local filter = function(name) return name == panelName end;
    return SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter, function()
        GuidePetFormation._ClearEffect(seq)
        seq:SkipAfterStep(GuidePetFormation.A);
    end );
end

-- 监听面板Tab事件
function GuidePetFormation._OnTabChangeEvent(seq)
    return SequenceEvent.Create(SequenceEventType.Guide.PET_CHANGE_PANEL, nil, nil,
    function(eventType, args)
        if (args ~= 4) then
            seq:SkipAfterStep(GuidePetFormation.C);
        end
    end );
end

function GuidePetFormation.DelayForPanel(seq)
    return SequenceCommand.UI.PanelOpened(panelName);
end

-- 引导点击玩家头像
function GuidePetFormation.A(seq)
    local msg = LanguageMgr.Get("guide/GuidePetFormation/1")
    return GuideContent.OpenSysPanelStart(seq, msg);
end

-- 引导点击伙伴按钮
function GuidePetFormation.B(seq)
    local msg = LanguageMgr.Get("guide/GuidePetFormation/2");
    return GuideContent.OpenSysItem(seq, msg, "5", panelName, GuidePetFormation.A);
end

-- 引导点击法阵标签
function GuidePetFormation.C(seq)
    if (PetManager.GetPetsCount() > 0) then
        -- 如果已经加过引导特效 则直接激活.
        if seq:GetCache("guideReqItem1") == nil then
            -- 找按钮
            local panel = PanelManager.GetPanelByType(panelName);
            if panel == nil then
                seq:SetError();
                return nil;
            end
            local btn = panel:GetTransformByPath("trsContent/btnFormation/icon");
            local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuidePetFormation/3"), GuideTools.Pos.RIGHT, Vector3.New(80, 0, 0));
            seq:AddToCache("guideReqItem1", effect);
        end
        seq:SetCacheDisplay("guideReqItem1");

        local filter = function(index) return index == 4 end;
        local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.PET_CHANGE_PANEL, nil, filter);
        wait:AddEvent(GuidePetFormation._OnCloseEvent(seq));
        wait:AddEvent(GuidePetFormation._OnTabChangeEvent(seq));
        return wait;
    else
        seq:SkipAfterStep(GuidePetFormation.F);
    end
    return nil;
end

-- 引导点击法阵按钮
function GuidePetFormation.D(seq)
    if (PetManager.GetPetsCount() > 0) then
        -- 如果已经加过引导特效 则直接激活.
        if seq:GetCache("guideReqItem2") == nil then
            -- 找按钮
            local panel = PanelManager.GetPanelByType(panelName);
            if panel == nil then
                seq:SetError();
                return nil;
            end

            local btn = panel:GetTransformByPath("trsContent/leftParent2/petList/petItem1/add");
            local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuidePetFormation/4"), GuideTools.Pos.DOWN, Vector3.New(0, -45, 0), 1);
            seq:AddToCache("guideReqItem2", effect);
        end
        seq:SetCacheDisplay("guideReqItem2");

        local wait = SequenceCommand.UI.PanelOpened("UI_PetFormationListPanel");
        wait:AddEvent(GuidePetFormation._OnCloseEvent(seq));
        wait:AddEvent(GuidePetFormation._OnTabChangeEvent(seq));
        return wait;
    else
        seq:SkipAfterStep(GuidePetFormation.F);
    end
    return nil;
end

-- 引导点击上阵按钮
function GuidePetFormation.E(seq)
    if (PetManager.GetPetsCount() > 0) then
        -- 如果已经加过引导特效 则直接激活.
        if seq:GetCache("guideReqItem3") == nil then
            -- 找按钮
            local panel = PanelManager.GetPanelByType("UI_PetFormationListPanel");
            if panel == nil then
                seq:SetError();
                return nil;
            end

            local btn = panel:GetTransformByPath("trsContent/scrollView/pha/petFormationListItem_0_0/btnAdd");
            local effect = GuideTools.AddEffectAndTitleToGameObject(btn, "ui_guide_1", LanguageMgr.Get("guide/GuidePetFormation/5"), GuideTools.Pos.DOWN, Vector3.New(0, -45, 0));
            seq:AddToCache("guideReqItem3", effect);
        end
        seq:SetCacheDisplay("guideReqItem3");

        local wait = SequenceCommand.WaitForEvent(SequenceEventType.Guide.PET_TOGGLE);
        local filter = function(name) return name == "UI_PetFormationListPanel" end;
        wait:AddEvent(SequenceEvent.Create(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, nil, filter,
        function()
            -- 删除升级加入的特效.
            seq:RemoveCache("guideReqItem3");
            seq:SkipAfterStep(GuidePetFormation.D);
        end ));
        return wait;
    else
        seq:SkipAfterStep(GuidePetFormation.F);
    end
    return nil;
end

-- 点击返回主界面
function GuidePetFormation.F(seq)
    -- 如果引导出错了 返回nil.
    GuidePetFormation._ClearEffect(seq)
    if seq.errorFlag then
        return nil;
    end
end