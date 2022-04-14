SkillGetPanel = SkillGetPanel or class("SkillGetPanel", BasePanel)
local SkillGetPanel = SkillGetPanel

function SkillGetPanel:ctor()
    self.abName = "system"
    self.assetName = "SkillGetPanel"
    self.layer = "UI"

    --self.use_background = true
    self.change_scene_close = false
    self.is_hide_other_panel = false
    self.opening = false
    self.model = SkillUIModel:GetInstance()

    self.panel_type = 2
    self.is_hide_other_panel = true
end

function SkillGetPanel:dctor()
    if self.countdowntext then
        self.countdowntext:destroy();
    end
    self.countdowntext = nil
    self.opening = false

    if self.uieffect then
        self.uieffect:destroy()
    end

    self.model:Brocast(SkillUIEvent.SkillGet)
end

--data:p_skill
function SkillGetPanel:Open(data)
    SkillGetPanel.super.Open(self)
    self.data = data
    self.opening = true
    TaskModel:GetInstance():PauseTask()
end

function SkillGetPanel:LoadCallBack()
    self.nodes = {
        "bg/confirm_btn", "bg", "icon", "bg/iconContent/des", "title", "bg/eft_content", "block",
    }
    self:GetChildren(self.nodes)
    self.icon_img = GetImage(self.icon)
    self.des = GetText(self.des)
    self.title = GetText(self.title)
    --self.isCloseCheckNext=false
    local params = {
        formatText = "Confirm (%s sec)",
        formatTime = "%d",
        isShowMin = false,
        isShowHour = false,
        isShowDay = false
    }
    self.countdowntext = CountDownText(self.confirm_btn, params);
    self.canvas_order = 421
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.icon.transform, nil, true, self.canvas_order + 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.title.transform, nil, true, self.canvas_order + 5)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.block.transform, nil, true, nil, false, -420)

    self:AddEvent()
end

function SkillGetPanel:AddEvent()
    local function call_back(target, x, y)
        SetVisible(self.bg, false)
        SetVisible(self.title, false)
        SetVisible(self.block, false)
        local bottom = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Bottom)
        SetVisible(bottom, true)
        local time = 0.5
        local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
        local x, y = mainpanel.main_bottom_right:GetSkillSlotPos(self.data.pos)
        if self.data.pos == 0 then
            x, y = mainpanel.main_bottom_right:GetRightIconPos("skill")
        end
        local moveAction = cc.Spawn(cc.MoveTo(time, x, y, 0), cc.ScaleTo(0.75, 0.75))
        moveAction = cc.EaseExponentialOut(moveAction)
        local function end_call_back()
            self.model:AddToSkillList(self.data)
            GlobalEvent:Brocast(SkillUIEvent.UpdateSkillSlots)
            GlobalEvent:Brocast(SkillUIEvent.RequsetAutoUseBeforeGetNewSkill)
            self:Close()
        end
        local delay_action = cc.DelayTime(0)
        local call_action = cc.CallFunc(end_call_back)
        local skillaction = cc.Sequence(delay_action, moveAction, call_action)
        cc.ActionManager:GetInstance():addAction(skillaction, self.icon)
    end
    AddClickEvent(self.confirm_btn.gameObject, call_back)
    --AddButtonEvent(self.background_transform.gameObject,call_back)
    self.countdowntext:StartSechudle(os.time() + 9, call_back)
end

function SkillGetPanel:OpenCallBack()
    local bottom = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Bottom)
    SetVisible(bottom, false)
    SoundManager.GetInstance():PlayById(53)
    local flag = false
    if self.data.pos == 0 then
        flag = true
    end
    local main_b_r = lua_panelMgr:GetPanelOrCreate(MainUIView).main_bottom_right
    if main_b_r then
        main_b_r:SwitchToIcons(flag)
    end
    self:UpdateView()
    GlobalEvent:Brocast(MainEvent.CloseGMPanel)
end

function SkillGetPanel:UpdateView()
    local skill_id = self.data.id
    local icon = Config.db_skill[self.data.id].icon
    local pos = self.data.pos
    lua_resMgr:SetImageTexture(self, self.icon_img, 'iconasset/icon_skill', icon .. "", true, nil, false)
    local skill = Config.db_skill[skill_id]
    self.des.text = skill.ad_desc
    self.title.text = skill.name
    self.uieffect = UIEffect(self.eft_content, 10102, false, self.layer)
    self.uieffect:SetOrderIndex(199)
    --SetOrderIndex(self.uieffect.gameObject, false, self.canvas_order + 2)
end

function SkillGetPanel:CloseCallBack()
    TaskModel:GetInstance():ResumeTask()
end

