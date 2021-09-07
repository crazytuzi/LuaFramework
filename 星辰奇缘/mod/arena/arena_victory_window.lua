ArenaVictoryWindow = ArenaVictoryWindow or BaseClass(BaseWindow)

function ArenaVictoryWindow:__init(model)
    self.model = model
    self.mgr = ArenaManager.Instance
    self.resList = {
        {file = AssetConfig.arena_victory_window, type = AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
    }
    self.windowId = WindowConfig.WinID.arena_victory_window

    self.showNum = 6
    self.spendingTime = 0
    self.rollTimes = 0
    self.currentStep = 0
    self.stepList = {}
    self.gotList = {}
    self.isFinish = false
    math.randomseed(BaseUtils.BASE_TIME)

    self.updateTimeListener = function() self:UpdateTimes() end
    self.updateItemListener = function() self:UpdateItem() end
    self.updateRollListener = function() self:UpdateRoll() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ArenaVictoryWindow:__delete()
    self.OnHideEvent:Fire()
    self.model:CloseGiftPreview()

    if self.stepList ~= nil then
        for _,v in pairs(self.stepList) do
            v:DeleteMe()
        end
    end
    self.stepList = nil

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.stepTimerId ~= nil then
        LuaTimer.Delete(self.stepTimerId)
        self.stepTimerId = nil
    end
    if self.soulImageTimerId ~= nil then
        LuaTimer.Delete(self.soulImageTimerId)
        self.soulImageTimerId = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ArenaVictoryWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arena_victory_window))
    self.gameObject.name = "ArenaVictoryWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.closeBtn = t:Find("Main/Close"):GetComponent(Button)

    local descArea = t:Find("Main/Bg/DescArea")
    self.diceImage = descArea:Find("Dice"):GetComponent(Image)
    self.diceBtn = self.diceImage.gameObject:GetComponent(Button)
    self.dropDiceBtn = descArea:Find("Bg/Button"):GetComponent(Button)
    self.shareBtn = descArea:Find("Bg/Share"):GetComponent(Button)
    self.noticeBtn = descArea:Find("Bg/Notice"):GetComponent(Button)
    self.diceBtnImage = self.dropDiceBtn.gameObject:GetComponent(Image)
    self.diceBtnTxt = descArea:Find("Bg/Button/Text"):GetComponent(Text)
    self.descText = descArea:Find("Bg/Desc"):GetComponent(Text)
    self.dropDiceRedPoint = descArea:Find("Bg/Button/NotifyPoint").gameObject

    local rollArea = t:Find("Main/Bg/RoleArea")
    for i=1,16 do
        self.stepList[i] = ArenaVictoryItem.New(self.model, rollArea:Find(tostring(i)).gameObject)
    end
    self.stepList[17] = ArenaVictoryItem.New(self.model, rollArea:Find("End").gameObject)

    self.diceImage.gameObject:SetActive(false)
    if self.closeBtn == nil then self.closeBtn = t:Find("Main/Close").gameObject:AddComponent(Button) end
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    self.diceBtn.onClick:AddListener(function() self:OnRoll() end)
    self.dropDiceBtn.onClick:AddListener(function() self:OnRoll() end)

    self.shareBtn.onClick:AddListener(function() self.mgr:send12213() end)
    self.noticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {
            TI18N("1、竞技场每胜利一场可进行一次胜利之路roll点"),
            TI18N("2、到达<color=#00FF00>终点</color>可获得稀有的道具奖励"),
            TI18N("3、胜利之路每日<color=#00FF00>5:00</color>重置回到<color=#00FF00>起点</color>")
            }})
    end)
end

function ArenaVictoryWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ArenaVictoryWindow:OnOpen()
    self.showNum = (BaseUtils.BASE_TIME - 1) % 6 + 1
    self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_"..self.showNum)
    self.diceImage.gameObject:SetActive(true)

    -- print("<color=#FF0000>"..self.model.roll_time.."</color>")
    self.currentStep = self.model.roll_id
    self.descText.text = string.format(TI18N("剩余次数:<color=#00FF00>%s</color>"), tostring(self.model.roll_time))

    if self.model.roll_time > 0 then
        self.diceBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.diceBtnTxt.color =  ColorHelper.DefaultButton3
    else
        self.diceBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.diceBtnTxt.color =  ColorHelper.DefaultButton4
    end

    self.dropDiceRedPoint:SetActive(self.model.roll_time > 0)
    self:UpdateItem()

    if self.model.roll_id == 17 then
        self.isFinish = true
        self:CalculateRandomList()
    end

    self:RemoveListeners()
    self.mgr.onUpdateTime:AddListener(self.updateTimeListener)
    self.mgr.onUpdateVic:AddListener(self.updateItemListener)
    self.mgr.onUpdateRoll:AddListener(self.updateRollListener)

    if self.model.vicData == nil then
        self.mgr:send12211()
    end
end

function ArenaVictoryWindow:OnHide()
    self:RemoveListeners()
end

function ArenaVictoryWindow:OnClose()
    self.model:CloseVic()
end

function ArenaVictoryWindow:OnRoll()
    -- self.targetNum = (BaseUtils.BASE_TIME - 1) % 6 + 1

    if self.model.roll_time > 0 then
        if self.rolling == true then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在摇骰子，请稍后再试~"))
        elseif BackpackManager.Instance:GetNilPos() == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理背包"))
        else
            SoundManager.Instance:Play(239)
            self.mgr:send12212()
            self.spendingTime = 31
            if self.timerId ~= nil then LuaTimer.Delete(self.timerId) end
            self.timerId = LuaTimer.Add(0, 60, function() self:GoNextFrame() end)
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("次数不足，竞技场胜利可增加次数"))
    end
end

function ArenaVictoryWindow:RemoveListeners()
    self.mgr.onUpdateTime:RemoveListener(self.updateTimeListener)
    self.mgr.onUpdateVic:RemoveListener(self.updateItemListener)
    self.mgr.onUpdateRoll:RemoveListener(self.updateRollListener)
end

function ArenaVictoryWindow:GoNextFrame()
    if self.spendingTime == 30 then
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        self.spendingTime = 0
        self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_"..self.targetNum)

        self.stepTimerId = LuaTimer.Add(50, 300, function() self:GoNextStep() end)
        return
    end

    self.spendingTime = self.spendingTime + 1
    self.rolling = true
    self.diceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "dice_Action_"..(self.spendingTime % 4))
end

function ArenaVictoryWindow:GoNextStep()
    SoundManager.Instance:StopId(278)
    SoundManager.Instance:Play(278)
    if self.targetNum > 0 and self.model.failed ~= true then
        self.targetNum = self.targetNum - 1
        if self.stepList[self.currentStep] ~= nil then
            self.stepList[self.currentStep]:Select(false)
        end
        self:GetNextStep()
        self.stepList[self.currentStep]:Select(true)
        if self.currentStep > 16 then
            if self.isFinish ~= true then
                self.targetNum = 0
                self.isFinish = true
            end
        end
        if self.targetNum == 0 then
        end
    else
        if self.stepTimerId ~= nil then
            LuaTimer.Delete(self.stepTimerId)
            self.stepTimerId = nil
        end
        self.rolling = false
        self.gotList[self.currentStep] = true
        self:CalculateRandomList()

        self.soulImageCounter = 1
        if self.model.failed ~= true then
            -- if self.model.roll_time == 0 then
            --     local confirmData = NoticeConfirmData.New()
            --     confirmData.type = ConfirmData.Style.Normal
            --     confirmData.content = "当前已经没有Roll点次数，是否返回竞技场？"
            --     confirmData.sureLabel = "确 定"
            --     confirmData.cancelLabel = "取 消"
            --     confirmData.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window, {1}) end
            --     NoticeManager.Instance:ConfirmTips(confirmData)
            -- end

            if self.soulImageTimerId ~= nil then LuaTimer.Delete(self.soulImageTimerId) end
            self.soulImageTimerId = LuaTimer.Add(0, 50, function() self:SoulImageTween(self.currentStep) end)

            for i,v in ipairs(self.model.rollPointData.gain) do
                LuaTimer.Add(1000 * (i - 1), function() NoticeManager.Instance:FloatTipsByString(string.format("{item_2, %s, 1, %s}", v.base_id, v.num)) end)
            end
        end
    end
end

-- 获取下一步位置
function ArenaVictoryWindow:GetNextStep()
    if self.isFinish then
        -- 随机
        if self.targetNum == 0 then
            self.currentStep = self.targetStep
        else
            self.currentStep = self.randomList[math.random(#self.randomList)]
        end
    else
        -- 顺序
        self.currentStep = self.currentStep + 1
    end
end

function ArenaVictoryWindow:CalculateRandomList()
    self.randomList = {}
    for k,v in pairs(self.model.vicData.roll_graph) do
        if v.status == 1 then
            self.gotList[v.id] = true
        end
    end
    self.gotList[self.model.roll_id] = true
    for i=1,17 do
        if self.gotList[i] ~= true then
            table.insert(self.randomList, i)
        end
    end
end

function ArenaVictoryWindow:UpdateTimes()
    local model = self.model
    self.rollTimes = model.roll_time
end

function ArenaVictoryWindow:UpdateItem()
    local model = self.model
    local datalist = {}
    local status17 = 0
    if model.vicData ~= nil then
        datalist = model.vicData.roll_graph
        if model.roll_id == 17 then status17 = 1 end
        model.vicData.roll_graph[17] = {id = 17, status = status17, quality = 5}
    else
        return
    end

    for i=1,17 do
        self.stepList[datalist[i].id]:SetData(datalist[i], i)
    end
end

function ArenaVictoryWindow:UpdateRoll()
    local model = self.model

    self.spendingTime = 0
    -- self.currentStep = model.roll_id - model.rollPointData.roll_val
    if model.rollPointData == nil then
        return
    end
    self.targetStep = model.rollPointData.id
    self.targetNum = model.rollPointData.roll_val or 1

    self.descText.text = string.format(TI18N("剩余次数:<color=#00FF00>%s</color>"), tostring(self.model.roll_time))

    self.model.vicData.roll_graph[model.rollPointData.id].status = 1

    if self.model.roll_time > 0 then
        self.diceBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.diceBtnTxt.color =  ColorHelper.DefaultButton3
    else
        self.diceBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.diceBtnTxt.color =  ColorHelper.DefaultButton4
    end

    self.dropDiceRedPoint:SetActive(self.model.roll_time > 0)
end

function ArenaVictoryWindow:SoulImageTween(id)
    if self.soulImageCounter > 14 then
        if self.soulImageTimerId ~= nil then
            LuaTimer.Delete(self.soulImageTimerId)
            self.soulImageTimerId = nil
        end
        self.stepList[id].slotTransform.localScale = Vector3.one
        self.stepList[self.currentStep]:HasGot()
        return
    end
    local scale = 1.2 + (math.sin(math.pi / 3.5 * self.soulImageCounter) / 6)
    self.soulImageCounter = self.soulImageCounter + 1
    self.stepList[id].slotTransform.localScale = Vector3(scale, scale, 1)
end

ArenaVictoryItem = ArenaVictoryItem or BaseClass()

function ArenaVictoryItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.slotContainer = t:Find("Slot")
    self.gotObj = t:Find("Got").gameObject
    self.selectObj = t:Find("Select").gameObject
    self.maskBtn = t:Find("Mask"):GetComponent(Button)
    self.itemimgObj = t:Find("ItemImg")

    self.itemData = ItemData.New()
    self.itemSlot = ItemSlot.New()
    NumberpadPanel.AddUIChild(self.slotContainer.gameObject, self.itemSlot.gameObject)
    self.maskBtn.onClick:AddListener(function() self:OnClick() end)

    self.slotTransform = nil
end

function ArenaVictoryItem:__delete()
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
end

function ArenaVictoryItem:SetData(data, index)
    self.index = index
    self.data = data

    self.slotTransform = self.itemimgObj
    if data.base_id ~= nil then
        self.itemData:SetBase(DataItem.data_get[data.base_id])
        self.itemSlot:SetAll(self.itemData, {inbag = false, nobutton = true})
        self.itemSlot:SetNum(data.num)
        -- self.itemSlot:ShowNum(data.num > 1)
        self.itemSlot:SetQuality(data.quality)
        self.slotTransform = self.itemSlot.gameObject.transform
    else
        self.itemSlot.bgImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, tostring(data.quality))
    end
    self.itemSlot:SetGrey(data.status == 1)
    self.gotObj:SetActive(data.status == 1)
    if self.itemimgObj ~= nil and data.status == 1 then
        self.itemimgObj.gameObject:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
    end
end

function ArenaVictoryItem:Select(bool)
    self.selectObj:SetActive(bool)
end

function ArenaVictoryItem:HasGot()
    self.gotObj:SetActive(true)
    if self.data.base_id ~= nil then
        self.itemSlot:SetGrey(true)
    end
    if self.itemimgObj ~= nil then
        self.itemimgObj.gameObject:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
    end
end

function ArenaVictoryItem:OnClick()
    if self.index == 17 then
        local itemTab = {}
        for k,v in pairs(DataArena.data_get_terminal) do
            if v.is_show == 1 then
                table.insert(itemTab, {v.base_id, v.num})
            end
        end
        self.model:OpenGiftPreview({reward = itemTab, text = TI18N("到达终点有可能获得以下随机奖励"), autoMain = true})
    else
        TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = self.itemData, extra = {nobutton = true, inbag = false}})
    end
end


