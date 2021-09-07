-- @author 黄耀聪
-- @date 2016年10月13日

BigDipperPanel = BigDipperPanel or BaseClass(BasePanel)

function BigDipperPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BigDipperPanel"
    if NewMoonManager.Instance == nil then
        NewMoonManager.New()
    end
    self.mgr = NewMoonManager.Instance

    self.resList = {
        {file = AssetConfig.newmoon_bigdipper, type = AssetType.Main},
        {file = AssetConfig.arena_textures, type = AssetType.Dep},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep},
    }

    self.effectPosList = {}
    self.stepList = {}
    self.scrollExt = {}
    self.rewardList = {}
    self.effectList = {}

    -- 存放等待滚动的消息
    self.currentMsg = nil
    self.tail = nil

    self.count = 0
    self.lastRollingIndex = nil
    self.moveSpeed = 50          -- 移动速率单位：像素每秒
    self.rollCount = 0
    self.currentPos = 0
    self.target = 0

    self.rewardString = TI18N("你获得了{item_2, %s, %s, %s}")
    self.campaignBaseData = DataCampaign.data_list[337]

    self.addMsgListener = function(msg) self:ShowMsg(msg) end
    self.reloadListener = function() self:Reload() end
    self.infoListener = function(success, val) self:DoEndRoll(success, val) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BigDipperPanel:__delete()
    self.OnHideEvent:Fire()
    if self.btnImage ~= nil then
        self.btnImage.sprite = nil
    end
    if self.diceImage ~= nil then
        self.diceImage.sprite = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.duangTimerId ~= nil then
        LuaTimer.Delete(self.duangTimerId)
        self.duangTimerId = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end
    if self.effectPosList ~= nil then
        for _,v in pairs(self.effectPosList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectPosList = nil
    end
    if self.scrollExt ~= nil then
        for _,v in pairs(self.scrollExt) do
            if v ~= nil then
                if v.rolling == true then Tween.Instance:Cancel(v.tweenId) end
                v.ext:DeleteMe()
            end
        end
        self.scrollExt = nil
    end
    if self.stepList ~= nil then
        for _,v in ipairs(self.stepList) do
            if v ~= nil then
                v.itemData:DeleteMe()
                v.btn.onClick:RemoveAllListeners()
                v.iconLoader:DeleteMe()
            end
        end
        self.stepList = nil
    end
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                if v.slot ~= nil then
                    v.slot:DeleteMe()
                end
            end
        end
        self.rewardList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BigDipperPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newmoon_bigdipper))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local items = t:Find("Path"):GetComponentsInChildren(Button)
    for i,v in ipairs(items) do
        local tab = {}
        tab.btn = v
        tab.gameObject = v.gameObject
        tab.transform = tab.gameObject.transform
        if DataCampLoginRoll.data_roll[i].special == 1 then
            tab.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "SpecilBg")
            self.effectPosList[i] = BibleRewardPanel.ShowEffect(20154, tab.transform, Vector3(0.6, 0.4, 1), Vector3(-2, -20, -400))
        else
            tab.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "NormalBg")
        end
        tab.itemData = ItemData.New()
        tab.itemData:SetBase(DataItem.data_get[DataCampLoginRoll.data_roll[i].reward[1][1]])
        tab.transform:Find("NumBg").gameObject:SetActive(false)
        if DataCampLoginRoll.data_roll[i].reward[1][3] > 1 then
            tab.transform:Find("Num").anchoredPosition = Vector2(19, -11)
            tab.transform:Find("Num"):GetComponent(Text).text = tostring(DataCampLoginRoll.data_roll[i].reward[1][3])
        else
            tab.transform:Find("Num").gameObject:SetActive(false)
        end
        tab.iconLoader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
        tab.iconLoader:SetSprite(tab.itemData.icon)
        tab.iconLoader.gameObject.transform.sizeDelta = Vector2(48.5,42.1)
        tab.iconLoader.gameObject:SetActive(true)
        tab.select = tab.transform:Find("Select").gameObject
        tab.mask = tab.transform:Find("Mask").gameObject
        tab.mask:SetActive(false)
        tab.select:SetActive(false)
        tab.btn.onClick:AddListener(function() tab.transform:SetAsLastSibling() TipsManager.Instance:ShowItem({gameObject = tab.gameObject, itemData = tab.itemData, extra = {nobutton = true, inbag = false}}) end)
        self.stepList[i] = tab
    end
    self.maxCount = #self.stepList

    local inside = t:Find("Inside")
    self.descExt = MsgItemExt.New(inside:Find("Desc"):GetComponent(Text), 199, 15, 17)
    self.diceImage = inside:Find("Dice"):GetComponent(Image)
    local scrollNotice = inside:Find("ScrollNoticeBg/Mask")
    self.scrollLength = scrollNotice.sizeDelta.x
    for i=1,3 do
        local tab = {}
        tab.transform = scrollNotice:Find(tostring(i))
        tab.gameObject = tab.transform.gameObject
        tab.ext = MsgItemExt.New(tab.transform:Find("Text"):GetComponent(Text), 960, 15, 18)
        self.scrollExt[i] = tab
    end

    local buttonArea = t:Find("RewardArea/ButtonArea")
    self.btn = buttonArea:Find("Button"):GetComponent(Button)
    self.btnImage = buttonArea:Find("Button"):GetComponent(Image)
    self.btnText = buttonArea:Find("Button/Text"):GetComponent(Text)
    self.btn.onClick:AddListener(function() self:OnClick() end)

    local rewardCloner = t:Find("RewardArea/Scroll/Cloner").gameObject
    local arrowCloner = t:Find("RewardArea/Scroll/Arrow").gameObject
    local rewardLayout = LuaBoxLayout.New(t:Find("RewardArea/Scroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 5, border = 5})

    local obj = nil
    for i,v in ipairs(DataCampLoginRoll.data_reward) do
        if i ~= 1 then
            obj = GameObject.Instantiate(arrowCloner)
            rewardLayout:AddCell(obj)
        end
        local tab = {}
        tab.gameObject = GameObject.Instantiate(rewardCloner)
        rewardLayout:AddCell(tab.gameObject)
        tab.transform = tab.gameObject.transform
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.transform:Find("Slot").gameObject, tab.slot.gameObject)
        -- tab.timeText = tab.transform:Find("Title"):GetComponent(Text)
        tab.transform:Find("Title"):GetComponent(Text).horizontalOverflow = 1
        tab.transform:Find("Title"):GetComponent(Text).text = string.format(TI18N("累计%s次"), tostring(v.day))
        tab.numText = tab.transform:Find("Num"):GetComponent(Text)
        tab.data = v
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[v.reward[1][1]])
        tab.slot:SetAll(itemData, {inbag = false, nobutton = true, noselect = true})
        tab.slot:SetNum(v.reward[1][3])
        local transitionBtn = tab.slot.gameObject:GetComponent(TransitionButton)
        if transitionBtn == nil then
            transitionBtn = tab.slot.gameObject:AddComponent(TransitionButton)
        end
        transitionBtn.scaleRate = 1.1
        self.rewardList[i] = tab
        tab.numText.text = string.format("<color='#00ff00'>%s</color>/%s", tostring(0), tostring(v.day))
    end
    rewardLayout:DeleteMe()
    rewardCloner:SetActive(false)
    arrowCloner:SetActive(false)

    self.descExt:SetData(self.campaignBaseData.cond_desc)
end

function BigDipperPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()

    -- self.mgr:send14087()
end

function BigDipperPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.diceMsgEvent:AddListener(self.addMsgListener)
    self.mgr.diceUpdateEvent:AddListener(self.reloadListener)
    self.mgr.diceInfoEvent:AddListener(self.infoListener)

    -- self.timerId = LuaTimer.Add(0, 200, function() self:Roll() end)
    if self.scrollExt ~= nil then
        for i,v in ipairs(self.scrollExt) do
            if v.rolling then
                Tween.Instance:Resume(v.tweenId)
            end
        end
    end

    self:Reload()

    if self.model.circleCount > 0 then
        self:Add(self.model.circleHead)
    end
end

function BigDipperPanel:OnHide()
    self:RemoveListeners()
    if self.scrollExt ~= nil then
        for i,v in ipairs(self.scrollExt) do
            if v.rolling then
                Tween.Instance:Pause(v.tweenId)
            end
        end
    end
    if self.timerId ~= nil then
        LuaTimer.DeleteMe(self.timerId)
        self.timerId = nil

        self:send14093()
    end
    if self.diceTimerId ~= nil then
        LuaTimer.Delete(self.diceTimerId)
        self.diceTimerId = nil
    end
end

function BigDipperPanel:RemoveListeners()
    self.mgr.diceMsgEvent:RemoveListener(self.addMsgListener)
    self.mgr.diceUpdateEvent:RemoveListener(self.reloadListener)
    self.mgr.diceInfoEvent:RemoveListener(self.infoListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.diceTimerId ~= nil then
        LuaTimer.Delete(self.diceTimerId)
        self.diceTimerId = nil
    end
end

function BigDipperPanel:Roll()
    self.currentPos = (self.currentPos - 1) % self.maxCount + 1
    self.stepList[self.currentPos].select:SetActive(false)
    self.currentPos = self.currentPos % self.maxCount + 1
    self.stepList[self.currentPos].select:SetActive(true)
    if self.currentPos == self.target then
        self:Reload()

        LuaTimer.Delete(self.timerId)
        self.timerId = nil

        self:Duang(self.target)

        self.mgr:send14093()
    end
end

function BigDipperPanel:ScrollText()
    local currentIndex = nil
    for i,v in ipairs(self.scrollExt) do
        if v.rolling ~= true then
            currentIndex = i
            break
        end
    end

    -- 没有闲置的滚动容器
    if currentIndex == nil then
        return
    end

    self:SetScrollString(currentIndex, self.currentMsg.str)
end

function BigDipperPanel:Add(node)
    local str = node.str
    if self.tail == nil then
        self.tail = {str = str, next = nil}
    else
        local tab = {str = str, next = nil}
        self.tail.next = tab
        self.tail = tab
    end
    self.currentMsg = node
    self:ScrollText()
end

function BigDipperPanel:SetScrollString(index, str)
    local tab = self.scrollExt[index]
    tab.ext:SetData(str)
    tab.transform.sizeDelta = Vector2(tab.ext.contentRect.sizeDelta.x, 34)

    local xBegin = self.scrollLength
    for i,v in ipairs(self.scrollExt) do
        if v.rolling == true then
            if xBegin < v.transform.anchoredPosition.x + v.transform.sizeDelta.x + 20 then
                xBegin = v.transform.anchoredPosition.x + v.transform.sizeDelta.x + 20
            end
        end
    end
    tab.transform.anchoredPosition = Vector2(xBegin, 0)
    tab.rolling = true
    -- self.currentMsg = self.currentMsg.next
    if self.currentMsg == nil then
        self.tail = nil
    end

    local w = tab.transform.sizeDelta.x + tab.transform.anchoredPosition.x
    tab.tweenId = Tween.Instance:MoveX(tab.transform, -tab.transform.sizeDelta.x, w / self.moveSpeed, function() self:AfterScrolling(index) end, LeanTweenType.linear).id
end

function BigDipperPanel:OnClick()
    if self.model.diceData ~= nil and self.model.diceData.status == 1 then
        if self.timerId == nil and self.diceTimerId == nil then
            self:BeginRoll()
        end
        self.mgr:send14089()
    else
        -- local dat = {"111111111111111", "2222222222222222", "33333333333333", "44444444444444444", "55555555555555"}
        -- local index = math.random(1, #dat)
        -- self:ShowMsg(dat[index])
        -- print("----------------------------" .. dat[index])
        NoticeManager.Instance:FloatTipsByString(TI18N("今天掷骰子次数已用完~"))
    end
end

function BigDipperPanel:AfterScrolling(index)
    -- print(tostring(self.model.circleCount))
    self.scrollExt[index].rolling = false
    if self.currentMsg ~= nil then
        self:Add(self.currentMsg.next)
    end
end

function BigDipperPanel:BeginRoll()
    if self.diceTimerId ~= nil then
        LuaTimer.Delete(self.diceTimerId)
    end
    self.rollCount = math.random(0,3)
    self.diceTimerId = LuaTimer.Add(0, 30, function() self:RollDice() end)
end

function BigDipperPanel:RollDice()
    self.rollCount = (self.rollCount + 1) % 4
    self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_Action_" .. tostring(self.rollCount))
end

function BigDipperPanel:EndRoll(num)
    if num ~= 0 then
        local final = num
        LuaTimer.Add(2000, function()
            if self.diceTimerId ~= nil then
                LuaTimer.Delete(self.diceTimerId)
                self.diceTimerId = nil
            end
            self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_" .. tostring(final))
            self.target = (self.currentPos + final - 1) % self.maxCount + 1
            if self.timerId == nil then
                self.timerId = LuaTimer.Add(0, 400, function() self:Roll() end)
            end
        end)
    else
        if self.diceTimerId ~= nil then
            LuaTimer.Delete(self.diceTimerId)
            self.diceTimerId = nil
        end
        self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_" .. tostring(math.random(1,6)))
    end
end

function BigDipperPanel:Reload()
    local data = self.model.diceData
    if data == nil then
        return
    end

    if self.timerId == nil and self.diceTimerId == nil then
        local length = #self.stepList
        if self.currentPos ~= nil then
            self.stepList[(self.currentPos - 1) % length + 1].select:SetActive(false)
        end
        self.currentPos = (data.id - 1) % length + 1
        self.stepList[self.currentPos].select:SetActive(true)
        local isMask = {}
        for i,v in pairs(data.reward) do
            isMask[v.reward_id] = true
            -- self.stepList[v.reward_id].mask:SetActive(true)
        end

        for i,v in ipairs(self.stepList) do
            v.mask:SetActive(isMask[i] == true)
        end
    end

    -- BaseUtils.dump(data.reward_get, "data.reward_get")
    for i,v in ipairs(self.rewardList) do
        local day = v.data.day
        v.slot.clickSelfFunc = nil
        local reward_id = i
        if data.roll_times >= day then
            v.numText.text = string.format("<color='#00ff00'>%s</color>/%s", tostring(day), tostring(day))
            if data.reward_get[i] == nil then
                v.slot.clickSelfFunc = function() self.mgr:send14088(reward_id) end
                if self.effectList[i] == nil then
                    self.effectList[i] = BibleRewardPanel.ShowEffect(20118, v.transform, Vector3(0.5, 1, 1), Vector3(4.9, 28.9, -400))
                end
            else
                if self.effectList[i] ~= nil then
                    self.effectList[i]:DeleteMe()
                    self.effectList[i] = nil
                end
            end
        else
            if self.effectList[i] ~= nil then
                self.effectList[i]:DeleteMe()
                self.effectList[i] = nil
            end
            v.numText.text = string.format("<color='#00ff00'>%s</color>/%s", tostring(data.roll_times), tostring(day))
        end
        v.slot:SetGrey(data.reward_get[i] ~= nil)
    end

    if data.status == 1 then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.btn.transform, Vector3(1, 0.75, 1), Vector3(-50, 20, -400))
        end
        self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.btnText.text = TI18N("投掷")
    else
        if self.effect ~= nil then
            self.effect:DeleteMe()
            self.effect = nil
        end
        self.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.btnText.text = TI18N("已投掷")
    end
end

function BigDipperPanel:DoEndRoll(success, val)
    if success == true then
        self:EndRoll(val)
    else
        self:EndRoll(0)
    end
end

function BigDipperPanel:Duang(index)
    local halfT = 120   -- 半周期
    local n = 3         -- 周期数
    local t = 0
    local scale = 0.2   -- 增量放缩
    if self.duangTimerId == nil then
        local trans = self.stepList[index].transform
        trans:SetAsLastSibling()
        self.duangTimerId = LuaTimer.Add(0, 30, function()
            t = t + 30
            local c = 1 + scale - scale * math.cos(math.pi * t / halfT)
            trans.localScale = Vector3(c, c, 1)
            if t > halfT * n * 2 then
                trans.localScale = Vector3.one
                LuaTimer.Delete(self.duangTimerId)
                self.duangTimerId = nil
            end
        end)
    end
end

function BigDipperPanel:ShowMsg(msg)
    self.model:AddToCircle(msg, self.currentMsg)
    if self.model.circleCount == 1 then
        self:Add(self.model.circleHead)
    else
        self:Add(self.model.circleHead.next)
    end
end
