ChainTreasureWindow = ChainTreasureWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function ChainTreasureWindow:__init(model)
    self.model = model

    self.name = "ChainTreasureWindow"
    self.Type = {
        normal = 1,
        rare = 2,
    }
    self.resList = {
        {file = AssetConfig.chaintreasurewindow, type = AssetType.Main}
        , {file = AssetConfig.chain_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebgstand, type = AssetType.Dep}
    }
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.iconloader = {}
    self.getReward = true
    self.times = 0
    self.rewardDataList = {}
    self.sendMarkList = {}
    self.timeNum = 60

    self.clickTimes = 1

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ChainTreasureWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self:ClearDepAsset()
end

function ChainTreasureWindow:InitPanel()
    self.opentime = Time.time
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.chaintreasurewindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.Con = self.transform:Find("Main/Con")
    self.normalbox = self.transform:Find("Main/Normal")
    self.rarebox = self.transform:Find("Main/Rare")
    self.bottom = self.transform:Find("Main/Bottom")
    self.bottom:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")

    self.descText = self.transform:Find("Main/DescText"):GetComponent(Text)
    self.descText2Ext = MsgItemExt.New(self.transform:Find("Main/DescText2"):GetComponent(Text), 520, 16, 30)
    -- self.descText2Ext.contentTxt.color = Color(49/255,102/255,173/255)

    self.buttonText = self.transform:Find("Main/Button/Text"):GetComponent(Text)
    -- self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:OnButtonClick() end)
    -- self.transform:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function () self:OnButtonClick() end)
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.transform:Find("Main/Button").gameObject:SetActive(false)
    self.buttonText.text = TI18N("关 闭")

    self:InitBox(1)

    self:OnShow()
end

function ChainTreasureWindow:OnClose()
    TipsManager.Instance.model:Closetips()
    self.model:CloseChainTreasureWindow()
end

function ChainTreasureWindow:OnHide()

end

function ChainTreasureWindow:OnShow()
    self.sendMarkList = {}
    self.times = 0
    for index=1,3 do
        if self.rewardDataList[index] ~= nil then
            self.times = self.times + 1
            self.sendMarkList[index] = true
        end
    end
end

function ChainTreasureWindow:AddTips(go, base_id)
    local cell = DataItem.data_get[base_id]
    local itemdata = ItemData.New()
    itemdata:SetBase(cell)
    local btn = go.transform:GetComponent(Button) or go.transform:AddComponent(Button)
    btn.onClick:AddListener(
        function ()
            TipsManager.Instance:ShowItem({["gameObject"] = go, ["itemData"] = itemdata})
        end
    )
end

function ChainTreasureWindow:Reset()
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self.getReward = true
    self.times = 0
    self.rewardDataList = {}
    self.sendMarkList = {}
    self.timeNum = 60
    self.clickTimes = 1

    if self.showOpenEffect ~= nil then
        self.showOpenEffect:DeleteMe()
        self.showOpenEffect = nil
    end

    for i = 1,3 do
        local destroyObject = self.Con:Find(string.format("bottom%s", i))
        if destroyObject ~= nil and not BaseUtils.isnull(destroyObject.gameObject) then
            GameObject.DestroyImmediate(destroyObject.gameObject)
        end
        destroyObject = self.Con:Find(tostring(i))
        if destroyObject ~= nil and not BaseUtils.isnull(destroyObject.gameObject) then
            GameObject.DestroyImmediate(destroyObject.gameObject)
        end
    end

    self:InitBox(1)
end

function ChainTreasureWindow:InitBox(_type)
    if _type == self.Type.normal then
        for i = 1,3 do
            local location = Vector3((i-2)*175, 0, 0)
            local bottom = GameObject.Instantiate(self.bottom.gameObject)
            bottom.gameObject.name = string.format("bottom%s", i)
            UIUtils.AddUIChild(self.Con.gameObject, bottom.gameObject)
            bottom.transform.localPosition = location

            local box = GameObject.Instantiate(self.normalbox.gameObject)
            box.gameObject.name = tostring(i)
            UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
            box.transform.localPosition = location
            self:CloseBox(box.transform, i)
        end
    else
        for i = 1,3 do
            local location = Vector3((i-2)*175, 0, 0)
            local bottom = GameObject.Instantiate(self.bottom.gameObject)
            bottom.gameObject.name = string.format("bottom%s", i)
            UIUtils.AddUIChild(self.Con.gameObject, bottom.gameObject)
            bottom.transform.localPosition = location

            local box = GameObject.Instantiate(self.rarebox.gameObject)
            box.gameObject.name = tostring(i)
            UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
            box.transform.localPosition = location
            self:CloseBox(box.transform, i)
        end
    end
    self:UpdateText()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTimer() end)
end

function ChainTreasureWindow:CloseBox(boxTs, index)
    boxTs:Find("Close").gameObject:SetActive(true)
    boxTs:Find("Open").gameObject:SetActive(false)
    boxTs:Find("Item").gameObject:SetActive(false)
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:GetComponent(Button).onClick:AddListener(function ()
        if self.times < 2 and self.sendMarkList[index] ~= true then
            if self.times > 0 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("确定花费{assets_1,90002,200}再打开一个历练宝箱吗？")
                data.sureLabel = TI18N("确定")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                        if not BaseUtils.isnull(self.gameObject) then
                            QuestManager.Instance:Send10255(index, self.times+1)
                            self.sendMarkList[index] = true
                        end
                    end
                NoticeManager.Instance:ConfirmTips(data)
            else
                QuestManager.Instance:Send10255(index, self.times+1)
                self.sendMarkList[index] = true
            end
        end
    end)
end

function ChainTreasureWindow:ShowBox(index, data)
    if self.Con == nil then
        return
    end
    local boxTs = self.Con:Find(tostring(index))
    if boxTs ~= nil then
        self.times = self.times + 1
        self:DuangEffect(boxTs,function() self:OpenBox(index, data) end)
    end
end

function ChainTreasureWindow:OpenBox(index, data)
    if self.Con == nil then
        return
    end
    if self.getReward then
        self:ShowOpenEffect(index)
    end

    self.rewardDataList[index] = data
    local boxTs = self.Con:Find(tostring(index))
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:Find("Close").gameObject:SetActive(false)
    boxTs:Find("Open").gameObject:SetActive(true)
    boxTs:Find("Item").gameObject:SetActive(true)
    local base_id = data.item_id1
    local num = data.num1
    local baseData = DataItem.data_get[base_id]
    local Item = boxTs:Find("Item")
    local id = Item:Find("Icon").gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(Item:Find("Icon").gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, baseData.icon)
    -- if num > 9999 then
    --     Item:Find("Text"):GetComponent(Text).text = string.format(TI18N("%s万"), math.floor(num/10000))
    -- else
    --     Item:Find("Text"):GetComponent(Text).text = tostring(num)
    -- end
    Item:Find("Text"):GetComponent(Text).text = ""
    Item:Find("Text").sizeDelta = Vector2(Item:Find("Text"):GetComponent(Text).preferredWidth, 20)
    Item:Find("Imagebg").sizeDelta = Vector2(Item:Find("Text").sizeDelta.x + 5, 20)
    Item:Find("ItemName/Text"):GetComponent(Text).text = baseData.name
    Item:Find("Get").gameObject:SetActive(self.getReward)
    self:AddTips(Item.gameObject, base_id)

    self:UpdateText()
    if self.times == 2 then
        LuaTimer.Add(1000, function()
            self:GetShowRewardData()
        end)
    elseif self.times == 3 then
        LuaTimer.Add(3000, function()
                if self.gameObject ~= nil then
                    self:OnClose()
                end
            end)

        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        -- self.buttonText.text = TI18N("关闭中")
    end
end

function ChainTreasureWindow:DuangEffect(target, callback)
    local second = function () Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one, 0.5, function() end , LeanTweenType.easeOutElastic)   end
    local descr1 = Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one*0.7, 0.2, function() second() callback() end, LeanTweenType.linear)
end

function ChainTreasureWindow:GetShowRewardData()
    for index=1,3 do
        if self.rewardDataList[index] == nil then
            self.times = self.times + 1
            QuestManager.Instance:Send10255(index, 3)
        end
    end
    self.getReward = false
end

function ChainTreasureWindow:UpdateText()
    if self.times > 0 then
        self.descText2Ext:SetData(string.format("花费{assets_1,90002,%s}可再打开一个历练宝箱", 200))
        self.descText.gameObject:SetActive(false)
        self.descText2Ext.contentTxt.gameObject:SetActive(true)

        self.transform:Find("Main/Button").gameObject:SetActive(true)
    else
        local num = 200
        if QuestManager.Instance.round_chain >= 100 and  QuestManager.Instance.round_chain < 200 then
            num = 100
        end
        self.descText.text = string.format("完成%s环历练任务，获得1次免费开启历练宝箱机会", num)
        self.descText.gameObject:SetActive(true)
        self.descText2Ext.contentTxt.gameObject:SetActive(false)

        self.transform:Find("Main/Button").gameObject:SetActive(false)
    end
end

function ChainTreasureWindow:OnTimer()
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    if self.timeNum >= 0 then
        -- self.buttonText.text = string.format("%sS自动关闭", self.timeNum)
        self.timeNum = self.timeNum - 1
    else
        -- self.buttonText.text = TI18N("关闭中")
        -- self:OnButtonClick()
        self:AutoGetReward()
    end
end

-- function ChainTreasureWindow:OnButtonClick()
--     if self.times == 0 then
--         local callback = function () self.times = self.times + 1 QuestManager.Instance:Send10255(2, self.times) end
--         self:DuangEffect(self.Con:Find(tostring(2)),callback)

--         LuaTimer.Add(2000, function()
--             self.times = self.times + 1
--             QuestManager.Instance:Send10255(1, 3)
--             self.times = self.times + 1
--             QuestManager.Instance:Send10255(3, 3)
--             self.getReward = false
--         end)

--         if self.timerId ~= nil then
--             LuaTimer.Delete(self.timerId)
--             self.timerId = nil
--         end
--         -- self.buttonText.text = TI18N("关闭中")
--     else
--         self:GetShowRewardData()
--         if self.timerId ~= nil then
--             LuaTimer.Delete(self.timerId)
--             self.timerId = nil
--         end
--         -- self.buttonText.text = TI18N("关闭中")
--     end
-- end

function ChainTreasureWindow:AutoGetReward()
    if self.times == 0 then
        QuestManager.Instance:Send10255(2, self.times+1)
        self.sendMarkList[2] = true

        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
    end
end

function ChainTreasureWindow:ShowOpenEffect(index)
    if self.Con == nil then
        return
    end
    local boxTs = self.Con:Find(tostring(index))
    if boxTs ~= nil then
        if self.showOpenEffect == nil or BaseUtils.isnull(self.showOpenEffect.gameObject) then
            local fun = function(effectView)
                if BaseUtils.isnull(boxTs) then
                    return
                end

                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(boxTs)
                effectObject.name = "Effect"
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 0, -400)

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")

                self.showOpenEffect = effectView
            end
            self.showOpenEffect = BaseEffectView.New({effectId = 20146, callback = fun})
        else
            self.showOpenEffect.gameObject.transform:SetParent(boxTs)
            self.showOpenEffect.gameObject.transform.localPosition = Vector3(0, 0, -400)

            self.showOpenEffect:SetActive(false)
            self.showOpenEffect:SetActive(true)
        end
    end
end