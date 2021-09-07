-- @date 3.12
-- 活动获奖记录
--model.history = {[1] = {msg = "xxx"},[2] = {msg = "yyy"}}


CustomRecordMsg = CustomRecordMsg or BaseClass()

function CustomRecordMsg:__init(manager, container, cloner, maxWidth)
    self.Manager = manager
    self.container = container
    self.cloner = cloner

    cloner:SetActive(false)

    self.topIndex = 1

    self.msgMaxCount = 6
    self.maxWidth = maxWidth or 200

    self.msgCount = 0

    self.msgIndex = 0

    self.MsgItems = { }

    self.speed = 0
    self.timeCounter = 0

    self.originSpeed = 39 / (1 * 1000 / 20)

    self.circleHead = nil
    self.circleTail = nil
    self.currentNode = nil

    self.ExtList = {}

    self.recordList = {}
    for i=1,self.msgMaxCount do
        if self.ExtList[i] == nil then
            local go = GameObject.Instantiate(cloner)
            go.transform:SetParent(container)
            go.transform.localScale = Vector3.one
            go.transform.anchoredPosition = Vector2(0, 17.48 * (1 - i))
            self.recordList[i] = MsgItemExt.New(go:GetComponent(Text), self.maxWidth, 16, 17.48)
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

    self.Manager.onMsgEvent:AddListener(self.msgListener)
end

function CustomRecordMsg:__delete()
    self.Manager.onMsgEvent:RemoveListener(self.msgListener)

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
function CustomRecordMsg:InitMsg()
    if self.Manager.model.history ~= nil then
        self.msgCount = #self.Manager.model.history
        --BaseUtils.dump(ArborDayShakeManager.Instance.model.history,"ArborDayShakeManager.Instance.model.history")
        local y = 0
        for i,v in ipairs(self.Manager.model.history) do
            table.insert(self.MsgItems,v)
            if self.recordList[i] ~= nil then
                self.recordList[i]:SetData(v.msg)
                self.recordList[i].contentTrans.anchoredPosition = Vector2(0, y)
                self.recordList[i].contentTrans.gameObject:SetActive(true)
                y = y - self.recordList[i].contentTrans.sizeDelta.y
                self.msgIndex = self.msgIndex + 1
            end
        end
        self.topIndex = 1
    end
end

function CustomRecordMsg:TweenContainer()
    if self.container == nil then
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        return
    end
    if self.Manager.model.history ~= nil and #self.Manager.model.history > 4 then
        local y = self.container.anchoredPosition.y
        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:ValueChange(y, y + 38, 1, function() self:SetPosition() end, LeanTweenType.linear, function(value) self.container.anchoredPosition = Vector2(0, value) end).id
    end
    self:SetPosition()
end

function CustomRecordMsg:SetPosition()
    if self.Manager.model.history ~= nil and #self.Manager.model.history > 4 then
        if self.recordList[self.topIndex].contentTrans.sizeDelta.y - self.recordList[self.topIndex].contentTrans.anchoredPosition.y < self.container.anchoredPosition.y then
            self.msgIndex = (self.msgIndex % (#self.MsgItems)) + 1
            local y = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.anchoredPosition.y
            local h = self.recordList[(self.topIndex - 2) % #self.recordList + 1].contentTrans.sizeDelta.y
            self.recordList[self.topIndex].contentTrans.anchoredPosition = Vector2(0, y - h)
            --print(self.msgIndex.."self.msgIndex")
            if self.msgIndex ~= nil and self.MsgItems[self.msgIndex] ~= nil and self.MsgItems[self.msgIndex].msg ~= nil then
                self.recordList[self.topIndex]:SetData(self.MsgItems[self.msgIndex].msg)
            else
                self.recordList[self.topIndex]:SetData("")
            end
            self.topIndex = self.topIndex % #self.recordList + 1
        end
    end
end

function CustomRecordMsg:AddMsg(msg, isNew)
    if isNew == true then
        --table.insert(self.Manager.model.history, {msg = msg}) --注意history的结构
    end
    local lastIndex = (self.topIndex - 2) % #self.recordList + 1
    local index = (self.topIndex + 4) % #self.recordList + 1
    self.recordList[index]:SetData(msg)
end

-- if self.msgBox == nil then
--     self.msgBox = CustomRecordMsg.New(ArborDayShakeManager.Instance, self.msgContainer, self.msgItem, 265)
--     self.msgBox.container.anchoredPosition = Vector2(0,0)
-- end
