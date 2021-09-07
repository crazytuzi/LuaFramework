NewYearTurnableMsg = NewYearTurnableMsg or BaseClass()

function NewYearTurnableMsg:__init(container, cloner)
    self.container = container
    self.cloner = cloner

    cloner:SetActive(false)

    self.topIndex = 1

    self.msgMaxCount = 6
    self.msgCount = 0
    self.speed = 0
    self.timeCounter = 0

    self.originSpeed = 39 / (1 * 1000 / 20)

    self.circleHead = nil
    self.circleTail = nil
    self.currentNode = nil

    self.ExtList = {}

    self.recordList = {}
    for i=1,6 do
        if self.ExtList[i] == nil then
            local go = GameObject.Instantiate(cloner)
            go.transform:SetParent(container)
            go.transform.localScale = Vector3.one
            go.transform.anchoredPosition = Vector2(0, 17.48 * (1 - i))
            self.recordList[i] = MsgItemExt.New(go:GetComponent(Text), 224, 16, 17.48)
            go:SetActive(false)
            self.recordList[i]:SetData("")
            self.ExtList[i] = go
        end
    end
    self.container.anchoredPosition = Vector2(0,0)
    self.timerId = LuaTimer.Add(0, 3000, function() self:TweenContainer() end)
    self.tempCount1 = 0
    self.speedTimerId = LuaTimer.Add(1000, 1000, function()
        self.tempCount1 = self.tempCount1 + 1
        if self.tempCount1 >= 4 then self.tempCount1 = 1 end
        if self.tempCount1 == 1 then
            self.speed = self.originSpeed
        else
            self.speed = 0
        end
    end)
    self:InitMsg()

    --self.msgListener = function(msg) self:AddMsg(msg, true) end
    --NewYearTurnableManager.Instance.OnMsgUpdate:AddListener(self.msgListener)
end

function NewYearTurnableMsg:__delete()
    --NewYearTurnableManager.Instance.OnMsgUpdate:RemoveListener(self.msgListener)
    if self.recordList ~= nil then
        for _,v in pairs(self.recordList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
    end

    for i = 1,#self.ExtList do
        if self.ExtList[i] ~= nil then
            GameObject.DestroyImmediate(self.ExtList[i])
            self.ExtList[i] = nil
        end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.speedTimerId ~= nil then
        LuaTimer.Delete(self.speedTimerId)
        self.speedTimerId = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self.cloner = nil
    self.container = nil
end

-- 初始化列表
function NewYearTurnableMsg:InitMsg()
    if NewYearTurnableManager.Instance.model.recordExt ~= nil then
        local y = 0
        for i,v in ipairs(NewYearTurnableManager.Instance.model.recordExt) do
            if self.recordList[i] ~= nil then
                self.recordList[i]:SetData(v.msg)
                self.recordList[i].contentTrans.anchoredPosition = Vector2(0, y)
                self.recordList[i].contentTrans.gameObject:SetActive(true)
                y = y - self.recordList[i].contentTrans.sizeDelta.y
            end
        end
        self.topIndex = 1
    end
end

function NewYearTurnableMsg:TweenContainer()
    if NewYearTurnableManager.Instance.model.recordExt ~= nil and #NewYearTurnableManager.Instance.model.recordExt > 5 then
        local y = self.container.anchoredPosition.y
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        --Tween:ValueChange(from, to, time, callback, type, updateback)   callback:当from变成to时回调    updateback:在from变成to的过程中都在回调
        self.tweenId = Tween.Instance:ValueChange(y, y + 38, 1, function() self:SetPosition() end, LeanTweenType.linear, function(value) self.container.anchoredPosition = Vector2(0, value) end).id
    end
    self:SetPosition()
end

function NewYearTurnableMsg:SetPosition()
    if NewYearTurnableManager.Instance.model.recordExt ~= nil and #NewYearTurnableManager.Instance.model.recordExt > 5 then
        if self.recordList[self.topIndex].contentTrans.sizeDelta.y - self.recordList[self.topIndex].contentTrans.anchoredPosition.y < self.container.anchoredPosition.y then
            local y = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.anchoredPosition.y
            local h = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.sizeDelta.y
            self.recordList[self.topIndex].contentTrans.anchoredPosition = Vector2(0, y - h)
            self.topIndex = self.topIndex % #self.recordList + 1
        end
    end
end