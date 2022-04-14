---
--- Created by  R2D2
--- DateTime: 2019/1/17 14:19
---
WelfareGrailPanel = WelfareGrailPanel or class("WelfareGrailPanel", BaseItem)
local this = WelfareGrailPanel

function WelfareGrailPanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfareGrailPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel

    self.model = WelfareModel.GetInstance():GetGrailModel()
    self.events = {}

    self.prevLevel = 0
    self.prevExp = 0
    --self.prevPercent = 0

    WelfareGrailPanel.super.Load(self)
end

function WelfareGrailPanel:dctor()
    self.model = nil
    GlobalEvent:RemoveTabListener(self.events)

    if self.effect_slider ~= nil then
        self.effect_slider:destroy()
        self.effect_slider = nil
    end

    if self.effect_success ~= nil then
        self.effect_success:destroy()
        self.effect_success = nil
    end

    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end

    self:StopAction()
    self:StopEffect()
end

function WelfareGrailPanel:LoadCallBack()
    self.nodes = { "GainDouble", "DoubleTip", "TimesTip", "TimesTip/TimesValue", "NoTimesTip",
                   "Earning", "Earning/ExpValue", "Remain/RemainValue",
                   "Button", "Button/CostNum", "EffectParent",
                   "Slider", "Slider/SliderValue", "Level/LevelValue", "Slider/Fill Area/Fill/Effect",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:LoadEffect()
    self:RefreshView()
    self:SetSlider()
end

function WelfareGrailPanel:InitUI()

    self.gainDoubleImage = GetImage(self.GainDouble)

    self.doubleTipImage = GetImage(self.DoubleTip)
    self.timesValueText = GetText(self.TimesValue)
    self.expValueText = GetText(self.ExpValue)
    self.expValueRect = self.ExpValue:GetComponent("RectTransform")
    self.remainText = GetText(self.RemainValue)
    self.costText = GetText(self.CostNum)
    self.costRect = self.CostNum:GetComponent("RectTransform")
    self.expSlider = GetSlider(self.Slider)
    self.expSliderText = GetText(self.SliderValue)
    self.levelText = GetText(self.LevelValue)

    self.effectStartPos = self.gainDoubleImage.rectTransform.localPosition
    self:ResetGainImage()
    --self.gainDoubleImage.enabled = false
end

function WelfareGrailPanel:LoadEffect()
    self.effect_slider = UIEffect(self.Effect, 10113, false, self.layer)
    --self.effect_success = UIEffect(self.EffectParent, 10118, false, self.layer)
    SetVisible(self.Effect.gameObject, false)
    --SetVisible(self.EffectParent.gameObject, false)
end

--function WelfareGrailPanel:ShowSuccessEffect()
--    SetVisible(self.EffectParent.gameObject, false)
--    SetVisible(self.EffectParent.gameObject, true)
--end
--
--function WelfareGrailPanel:HideSuccessEffect()
--    SetVisible(self.EffectParent.gameObject, false)
--end

function WelfareGrailPanel:ShowEffect()
    SetVisible(self.Effect.gameObject, false)
    SetVisible(self.Effect.gameObject, true)
end

function WelfareGrailPanel:HideEffect()
    SetVisible(self.Effect.gameObject, false)
end

function WelfareGrailPanel:AddEvent()
    --local function helpTip ()
    --    ShowHelpTip(HelpConfig.Welfare.Grail)
    --    --self:PlayAction(1, 10, 4, 100)
    --
    --end
    --AddClickEvent(self.HelpBtn.gameObject, helpTip)

    local function blessing()

        if self.model:GetRemainCount() <= 0 then
            Notify.ShowText("Prayer attempts used up")
            return
        end

        local currNum = self.model.Count + 1
        local costData = self.model:GetConsumable(currNum)

        if RoleInfoModel:GetInstance():CheckGold(costData[1][2], costData[1][1]) then
            WelfareController:GetInstance():RequestGrailReward()
        end
    end
    AddClickEvent(self.Button.gameObject, blessing)

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_GrailRefreshEvent, handler(self, self.OnGrailRefresh))
end

function WelfareGrailPanel:OnDisable()
    self:StopAction()
    self:StopEffect()

    self:SetSlider()
end

function WelfareGrailPanel:StopEffect()
    if self.effectAction then
        cc.ActionManager:GetInstance():removeAction(self.effectAction)
        self.effectAction = nil
    end
end

function WelfareGrailPanel:ResetGainImage()
    self.gainDoubleImage.transform.localPosition = self.effectStartPos
    self.gainDoubleImage.transform.localScale = Vector3.zero
    SetAlpha(self.gainDoubleImage, 1)
end

function WelfareGrailPanel:StartEffect()
    self:StopEffect()
    self:ResetGainImage()

    self.effectAction = cc.Sequence(cc.ScaleTo(0.3, 1), cc.DelayTime(0.1))
    local spawnAction = cc.Spawn(cc.MoveTo(0.5, self.effectStartPos.x, 290, self.effectStartPos.z), cc.FadeOut(0.5, self.gainDoubleImage))
    self.effectAction = cc.Sequence(self.effectAction, spawnAction)
    --self.effectAction = cc.EaseBackInOut(self.effectAction)
    cc.ActionManager:GetInstance():addAction(self.effectAction, self.GainDouble)
end

function WelfareGrailPanel:StopAction()

    if self.sliderAction then
        cc.ActionManager:GetInstance():removeAction(self.sliderAction)
        self.sliderAction = nil

    end
end

function WelfareGrailPanel:PlayAction(startLv, startValue, endLv, endValue)

    if (startLv == endLv and endValue > startValue) then
        self:StopAction()
        local levelValue = Config.db_role_level[startLv].exp
        local t = (endValue - startValue) / levelValue
        local endPercent = endValue / levelValue

        self.sliderAction = cc.Spawn(cc.ValueTo(t, endPercent),
                cc.NumberTo(t, startValue, endValue, true, "%s&" .. levelValue, self.expSliderText), cc.CallFunc(handler(self, self.ShowEffect)))
        self.sliderAction = cc.Sequence(self.sliderAction, cc.CallFunc(handler(self, self.HideEffect)))
        cc.ActionManager:GetInstance():addAction(self.sliderAction, self.expSlider)

    elseif (endLv > startLv) then
        self:StopAction()

        local function SetLevelText(v)
            self.levelText.text = v
        end

        local levelValue = Config.db_role_level[startLv].exp
        local endLevelValue = Config.db_role_level[endLv].exp
        local startPercent = startValue / levelValue
        local endPercent = endValue / endLevelValue

        local t = 1 - startPercent
        local lv = startLv + 1

        self.sliderAction = cc.Spawn(cc.ValueTo(t, 1),
                cc.NumberTo(t, startValue, levelValue, true, "%s&" .. levelValue, self.expSliderText), cc.CallFunc(handler(self, self.ShowEffect)))
        self.sliderAction = cc.Sequence(self.sliderAction, cc.CallFunc(function()
            SetLevelText(lv)
        end), cc.DelayTime(0.1), cc.ValueTo(0, 0))

        for i = lv, endLv - 1, 1 do
            levelValue = Config.db_role_level[i].exp

            local action1 = cc.Spawn(cc.ValueTo(1, 1),
                    cc.NumberTo(1, 0, levelValue, true, "%s&" .. levelValue, self.expSliderText))
            local action2 = cc.Sequence(action1, cc.CallFunc(function()
                SetLevelText(i + 1)
            end), cc.DelayTime(0.1), cc.ValueTo(0, 0))

            self.sliderAction = cc.Sequence(self.sliderAction, action2)
        end

        local action3 = cc.Spawn(cc.ValueTo(endPercent, endPercent),
                cc.NumberTo(endPercent, 0, endValue, true, "%s&" .. endLevelValue, self.expSliderText))
        self.sliderAction = cc.Sequence(self.sliderAction, action3, cc.CallFunc(handler(self, self.HideEffect)))

        cc.ActionManager:GetInstance():addAction(self.sliderAction, self.expSlider)
    end
end

function WelfareGrailPanel:OnGrailRefresh()

    self:RefreshView()

    local reachNum = self.model:GetReachDoubleNum()
    --如果剩余5次才能Double，说明本次返回的是Double
    if (reachNum == self.model.DoublePoint) then
        self:StartEffect()
    end

    self.effect_success = UIEffect(self.EffectParent, 10118, false, self.layer)

    local roleLevel = RoleInfoModel:GetInstance():GetRoleValue("level")
    local roleExp = RoleInfoModel:GetInstance():GetRoleValue("exp")
    local exp = 0

    if (roleLevel <= self.prevLevel) then
        exp = roleExp - self.prevExp
    else
        local cfg = Config.db_role_level[self.prevLevel]
        exp = roleExp + cfg.exp - self.prevExp
    end
    Notify.ShowText("Prayer successful! EXP:" .. exp)

    if Config.db_role_level[roleLevel] then
        self:PlayAction(self.prevLevel, self.prevExp, roleLevel, roleExp)
        self.prevLevel = roleLevel
        self.prevExp = roleExp
    end
end

function WelfareGrailPanel:RefreshView()

    local data = self.model:GetGrailData()
    --剩余次数
    local remainNum = #data - self.model.Count
    self:SetRemain(remainNum, #data)

    if remainNum <= 0 then
        SetGameObjectActive(self.Earning, false)
        SetGameObjectActive(self.Button, false)
        self.doubleTipImage.enabled = false
        SetGameObjectActive(self.TimesTip, false)
        SetGameObjectActive(self.NoTimesTip, true)

        self:SetRedPoint(false)
        return
    else
        SetGameObjectActive(self.Earning, true)
        SetGameObjectActive(self.Button, true)
        SetGameObjectActive(self.NoTimesTip, false)

        self:SetRedPoint(WelfareModel.GetInstance():HadGrailTimes())
    end

    --当前次数
    local currNum = self.model.Count + 1
    --达到双倍的还需次数
    local reachNum = self.model:GetReachDoubleNum()

    local costData = self.model:GetConsumable(currNum)

    self.timesValueText.text = reachNum

    self:SetCost(costData[1][2])

    if reachNum == 1 then
        self:SetExp(data[currNum].reward[1][2] * 2)
        self.doubleTipImage.enabled = true
        SetGameObjectActive(self.TimesTip, false)
    else
        self:SetExp(data[currNum].reward[1][2])
        self.doubleTipImage.enabled = false
        SetGameObjectActive(self.TimesTip, true)
    end
end

function WelfareGrailPanel:SetExp(num)
    self.expValueText.text = num
    self.expValueRect.sizeDelta = Vector2(self.expValueText.preferredWidth, self.expValueRect.sizeDelta.y)
end

function WelfareGrailPanel:SetCost(num)
    self.costText.text = num
    self.costRect.sizeDelta = Vector2(self.costText.preferredWidth, self.costRect.sizeDelta.y)
end

function WelfareGrailPanel:SetRemain(num, total)
    if num <= 0 then
        self.remainText.text = "Daily attempts left：<color=#ff0000>0</color>/" .. total
    else
        self.remainText.text = "Daily attempts left:" .. num .. "/" .. total
    end
end

function WelfareGrailPanel:SetSlider()
    --local roleData = RoleInfoModel.GetInstance():GetMainRoleData()

    self.prevLevel = RoleInfoModel:GetInstance():GetRoleValue("level")
    self.prevExp = RoleInfoModel:GetInstance():GetRoleValue("exp")

    self.levelText.text = tostring(self.prevLevel)

    local cfg = Config.db_role_level[self.prevLevel]
    if cfg then
        self.expSlider.value = self.prevExp / cfg.exp
        self.expSliderText.text = self.prevExp .. "&" .. cfg.exp
    end
end

function WelfareGrailPanel:SetRedPoint(isShow)
    if self.redPoint == nil then
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(72, -132)
    end

    self.redPoint:SetRedDotParam(isShow)
end