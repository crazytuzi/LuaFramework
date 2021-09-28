local Util = require "Zeus.Logic.Util"

local NumInputExt = {}
Util.WrapOOPSelf(NumInputExt)

function NumInputExt.New(inputLabel, subBtn, addBtn, maxBtn, cb, maxValue, minValue, defaultValue, isCenter)
    local o = {}
    setmetatable(o, NumInputExt)
    o:_init(inputLabel, subBtn, addBtn, maxBtn, cb, maxValue, minValue, defaultValue, isCenter)
    return o
end

function NumInputExt:setMaxMinValue(maxValue, minValue)
    self._minValue = minValue or self._minValue
    self._maxValue = maxValue or self._maxValue
end

function NumInputExt:setValue(value, isForceCallback)
    if value < self._minValue then
        value = self._minValue
    elseif value > self._maxValue then
        value = self._maxValue
    end
    self._value = value
    self._inputLabel.Input.Text = tostring(value)
    if isForceCallback and self._cb then
        self._cb(value)
    end
end

function NumInputExt:getValue()
    return self._value
end

function NumInputExt:_init(inputLabel, subBtn, addBtn, maxBtn, cb, maxValue, minValue, defaultValue, isCenter)
    inputLabel.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self._inputLabel = inputLabel
    self._subBtn = subBtn
    self._addBtn = addBtn
    self._maxBtn = maxBtn
    self._cb = cb
    self._maxValue = maxValue
    self._minValue = minValue or 0
    self.showTips = false
    defaultValue = defaultValue or self._minValue
    inputLabel.Input.Text = tostring(defaultValue)

    if isCenter then
        self._inputLabel.TextSprite.Anchor = TextAnchor.C_C
        self._inputLabel.PlaceHolder.Anchor = TextAnchor.C_C
    end
    self:_registerEvent()
end

function NumInputExt:_registerEvent()
    self._inputLabel.event_endEdit = self._self__onTextChange
    if self._subBtn then
        self._subBtn.event_LongPoniterDown = self._self__onBtnClick
        self._subBtn.LongPressSecond = 0.5
        self._subBtn.event_LongPoniterDownStep = self._self__onBtnClick
        self._subBtn.TouchClick = self._self__onBtnClick
    end
    if self._addBtn then
        self._addBtn.event_LongPoniterDown = self._self__onBtnClick
        self._addBtn.LongPressSecond = 0.5
        self._addBtn.event_LongPoniterDownStep = self._self__onBtnClick
        self._addBtn.TouchClick = self._self__onBtnClick
    end
    if self._maxBtn then
        self._maxBtn.TouchClick = self._self__onBtnClick
    end
end

function NumInputExt:_onTextChange(sender, text)
    local num = tonumber(text) or 0
    num = math.floor(num)
    self:setValue(num, true)
end

function NumInputExt:_onBtnClick(sender, e)
    local oldValue = self._value
    local err = nil
    if sender == self._subBtn then
        self:setValue(self._value - 1, true)
    elseif sender == self._addBtn then
        self:setValue(self._value + 1, true)
    elseif sender == self._maxBtn then
        self:setValue(self._maxValue, true)
    end
    if self.showTips and oldValue == self._value then
        local text = sender == self._subBtn and "alreadMinNum" or "alreadMaxNum"
        text = Util.GetText(TextConfig.Type.PUBLICCFG, text)
        GameAlertManager.Instance:ShowNotify(text)
    end
end

return NumInputExt
