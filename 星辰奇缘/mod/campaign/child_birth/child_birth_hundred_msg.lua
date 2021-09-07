ChildBirthHundredMsg = ChildBirthHundredMsg or BaseClass()

function ChildBirthHundredMsg:__init(container, cloner)
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

    self.recordList = {}
    for i=1,6 do
        local go = GameObject.Instantiate(cloner)
        go.transform:SetParent(container)
        go.transform.localScale = Vector3.one
        go.transform.anchoredPosition = Vector2(0, 17.48 * (1 - i))
        self.recordList[i] = MsgItemExt.New(go:GetComponent(Text), 224, 16, 17.48)
        go:SetActive(false)
        self.recordList[i]:SetData("")
    end

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

    self.msgListener = function(msg) self:AddMsg(msg, true) end

    ChildBirthManager.Instance.onMsgEvent:AddListener(self.msgListener)
end

function ChildBirthHundredMsg:__delete()
    ChildBirthManager.Instance.onMsgEvent:RemoveListener(self.msgListener)

    if self.recordList ~= nil then
        for _,v in pairs(self.recordList) do
            if v ~= nil then
                v:DeleteMe()
            end
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
function ChildBirthHundredMsg:InitMsg()
    if ChildBirthManager.Instance.model.history ~= nil then
        local y = 0
        for i,v in ipairs(ChildBirthManager.Instance.model.history) do
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

function ChildBirthHundredMsg:TweenContainer()
    if ChildBirthManager.Instance.model.history ~= nil and #ChildBirthManager.Instance.model.history > 4 then
        local y = self.container.anchoredPosition.y
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:ValueChange(y, y + 38, 1, function() self:SetPosition() end, LeanTweenType.linear, function(value) self.container.anchoredPosition = Vector2(0, value) end).id
    end
    self:SetPosition()
end

function ChildBirthHundredMsg:SetPosition()
    if ChildBirthManager.Instance.model.history ~= nil and #ChildBirthManager.Instance.model.history > 4 then
        if self.recordList[self.topIndex].contentTrans.sizeDelta.y - self.recordList[self.topIndex].contentTrans.anchoredPosition.y < self.container.anchoredPosition.y then
            local y = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.anchoredPosition.y
            local h = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.sizeDelta.y
            self.recordList[self.topIndex].contentTrans.anchoredPosition = Vector2(0, y - h)
            self.topIndex = self.topIndex % #self.recordList + 1
        end
    end
end

function ChildBirthHundredMsg:SetPosition1()
    if self.timeCounter == 0 then
        local y = 0
        for i,v in ipairs(self.recordList) do
            v.contentTrans.anchoredPosition = Vector2(0, -y)
            if  v.contentTrans.sizeDelta.x > 1 then
                y = y + v.contentTrans.sizeDelta.y
            end
            v.contentTrans.gameObject:SetActive(true)
        end
        self.topIndex = 1
    else
        if ChildBirthManager.Instance.model.history ~= nil and #ChildBirthManager.Instance.model.history > 4 then
            local nextIndex = self.topIndex % #self.recordList + 1
            local next2Index = nextIndex % #self.recordList + 1
            local y = 0

            if self.recordList[next2Index].contentTrans.anchoredPosition.y + self.recordList[nextIndex].contentTrans.sizeDelta.y >= 0 then
                y = self.recordList[nextIndex].contentTrans.anchoredPosition.y + self.speed
                self.topIndex = nextIndex
            else
                y = self.recordList[self.topIndex].contentTrans.anchoredPosition.y + self.speed
            end

            -- local y = -self.recordList[self.topIndex].contentTrans.anchoredPosition.y + self.speed
            for i,_ in ipairs(self.recordList) do
                j = (i + self.topIndex - 2) % #self.recordList + 1
                self.recordList[j].contentTrans.anchoredPosition = Vector2(0, y)
                if self.recordList[j].contentTrans.sizeDelta.x > 1 then
                    y = y - self.recordList[j].contentTrans.sizeDelta.y
                end
            end
        else
            local y = 0
            for i,v in ipairs(self.recordList) do
                v.contentTrans.anchoredPosition = Vector2(0, -y)
                if  v.contentTrans.sizeDelta.x > 1 then
                    y = y + v.contentTrans.sizeDelta.y
                end
                v.contentTrans.gameObject:SetActive(true)
            end
            self.topIndex = 1
        end
    end
    self.timeCounter = self.timeCounter + 1
end

function ChildBirthHundredMsg:AddMsg(msg, isNew)
    if isNew == true then
        table.insert(ChildBirthManager.Instance.model.history, {msg = msg})
    end
    local lastIndex = (self.topIndex - 2) % #self.recordList + 1
    local index = (self.topIndex + 4) % #self.recordList + 1
    self.recordList[index]:SetData(msg)
    -- local y = self.recordList[index].contentTrans.anchoredPosition.y
    -- while index < lastIndex do
    --     self.recordList[index].contentTrans.anchoredPosition = Vector2(0, y)
    --     y = y - self.recordList[index].contentTrans.sizeDelta.y
    --     index = index + 1
    -- end
end

