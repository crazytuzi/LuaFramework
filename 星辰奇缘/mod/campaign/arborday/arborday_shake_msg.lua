-- @author pwj
-- @date 2018年2月27日,星期二
--ArborDayShakeMsg

ArborDayShakeMsg = ArborDayShakeMsg or BaseClass()

function ArborDayShakeMsg:__init(container, cloner)
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
            self.recordList[i] = MsgItemExt.New(go:GetComponent(Text), 265, 16, 17.48)
            go:SetActive(false)
            self.recordList[i]:SetData("")
            self.ExtList[i] = go
        end
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

    ArborDayShakeManager.Instance.onMsgEvent:AddListener(self.msgListener)
end

function ArborDayShakeMsg:__delete()
    ArborDayShakeManager.Instance.onMsgEvent:RemoveListener(self.msgListener)

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
function ArborDayShakeMsg:InitMsg()
    if ArborDayShakeManager.Instance.model.history ~= nil then
        --BaseUtils.dump(ArborDayShakeManager.Instance.model.history,"ArborDayShakeManager.Instance.model.history")
        local y = 0
        for i,v in ipairs(ArborDayShakeManager.Instance.model.history) do
            if self.recordList[i] ~= nil then
                self.recordList[i]:SetData(v)
                self.recordList[i].contentTrans.anchoredPosition = Vector2(0, y)
                self.recordList[i].contentTrans.gameObject:SetActive(true)
                y = y - self.recordList[i].contentTrans.sizeDelta.y
            end
        end
        self.topIndex = 1
    end
end

function ArborDayShakeMsg:TweenContainer()
    if self.container == nil then
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        return
    end
    if ArborDayShakeManager.Instance.model.history ~= nil and #ArborDayShakeManager.Instance.model.history >= 6 then
        local y = self.container.anchoredPosition.y
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:ValueChange(y, y + 38, 1, function() self:SetPosition() end, LeanTweenType.linear, function(value) self.container.anchoredPosition = Vector2(0, value) end).id
    end
    self:SetPosition()
end

function ArborDayShakeMsg:SetPosition()
    if ArborDayShakeManager.Instance.model.history ~= nil and #ArborDayShakeManager.Instance.model.history >= 6 then
        if self.recordList[self.topIndex].contentTrans.sizeDelta.y - self.recordList[self.topIndex].contentTrans.anchoredPosition.y < self.container.anchoredPosition.y then
            local y = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.anchoredPosition.y
            local h = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.sizeDelta.y
            self.recordList[self.topIndex].contentTrans.anchoredPosition = Vector2(0, y - h)
            self.topIndex = self.topIndex % #self.recordList + 1
        end
    end
end

function ArborDayShakeMsg:AddMsg(msg, isNew)
    if isNew == true then
        --table.insert(ArborDayShakeManager.Instance.model.history, {msg = msg})
    end
    local lastIndex = (self.topIndex - 2) % #self.recordList + 1
    local index = (self.topIndex + 4) % #self.recordList + 1
    self.recordList[index]:SetData(msg)
end


