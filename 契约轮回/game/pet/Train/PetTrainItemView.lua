---
--- Created by R2D2.
--- DateTime: 2019/4/22 14:35
---
PetTrainItemView = PetTrainItemView or class("PetTrainItemView", Node)
local this = PetTrainItemView

function PetTrainItemView:ctor(obj, data)
    self.transform = obj.transform

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
end

function PetTrainItemView:dctor()
    self:StopAction()
end

function PetTrainItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Icon", "Slider", "Title", "Value", "FloatText" }
    self:GetChildren(self.nodes)

    self.iconImage = GetImage(self.Icon)
    self.sliderBar = GetSlider(self.Slider)
    self.titleText = GetText(self.Title)
    self.valueText = GetText(self.Value)
    self.floatText = GetText(self.FloatText)

    self.floatText.text = ""

    self.floatStartPos = self.FloatText.localPosition
end

function PetTrainItemView:SetData(data, isMax)

    self.Data = data

    lua_resMgr:SetImageTexture(self, self.iconImage, "pet_image", "Icon_Train_" .. data[1])
    self.titleText.text = enumName.ATTR[data[1]] .. "Train"

    self.sliderBar.value = data[2] / data[3]
    if (isMax and (data[2] == data[3])) then
        self.valueText.text = string.format("%d/%d%s", data[2], data[3], ConfigLanguage.Pet.FullAndMax)
    else
        self.valueText.text = string.format("%d/%d", data[2], data[3])
    end

end

function PetTrainItemView:RefreshData(data, isMax)

    local isEquality = true

    for i, v in ipairs(data) do
        if self.Data[i] < v then
            isEquality = false
            break
        end
    end

    if (isEquality) then
        return
    end

    local tempData = self.Data
    self.Data = data

    self.sliderBar.value = tempData[2] / data[3]
    local sliderValue = data[2] / data[3]
    --self.sliderBar.value = data[2] / data[3]
    --self.valueText.text = string.format("%d/%d", data[2], data[3])

    self:PlayAction(0.5, sliderValue, tempData[2], data[2], data[3], isMax)
end

function PetTrainItemView:PlayAction(s, sliderValue, startValue, endValue, maxValue, isMax)
    self:StopAction()

    local action = nil
    self.trainActions = {}

    action = cc.Spawn(cc.ValueTo(s, sliderValue), cc.NumberTo(s, startValue, endValue, true, "%d/" .. maxValue, self.valueText))
    action = cc.Sequence(action, cc.CallFunc(function()
        if isMax and (maxValue == endValue) then
            self.valueText.text = string.format("%d/%d%s", endValue, maxValue, ConfigLanguage.Pet.FullAndMax)
        end
    end))
    cc.ActionManager:GetInstance():addAction(action, self.sliderBar)
    table.insert(self.trainActions, action)

    action = cc.Sequence(cc.EaseBounceOut(cc.ScaleTo(0.3, 1.1)), cc.ScaleTo(0.2, 1))
    cc.ActionManager:GetInstance():addAction(action, self.Slider)
    table.insert(self.trainActions, action)

    action = cc.Sequence(cc.EaseBounceOut(cc.ScaleTo(0.3, 1.1)), cc.ScaleTo(0.2, 1))
    cc.ActionManager:GetInstance():addAction(action, self.Title)
    table.insert(self.trainActions, action)

    local p = self.floatStartPos
    self.floatText.text = "+" .. tostring(endValue - startValue)
    SetLocalPosition(self.FloatText, p.x, p.y, p.z)
    SetAlpha(self.floatText, 255)

    action = cc.Sequence(cc.DelayTime(0.2), cc.FadeOut(0.3, self.floatText))
    action = cc.Spawn(action, cc.MoveTo(0.5, 60, 20, p.z))
    cc.ActionManager:GetInstance():addAction(action, self.FloatText)
    table.insert(self.trainActions, action)
end

function PetTrainItemView:StopAction()

    if (self.trainActions == nil or #self.trainActions == 0) then
        return
    end

    for _, v in ipairs(self.trainActions) do
        cc.ActionManager:GetInstance():removeAction(v)
    end
    self.trainActions = nil

    --if self.sliderAction then
    --    cc.ActionManager:GetInstance():removeAction(self.sliderAction)
    --    self.sliderAction = nil
    --end


end