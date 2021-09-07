-- 彩虹魔盒 抽奖界面

FairylandLuckDrawWindow = FairylandLuckDrawWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2

function FairylandLuckDrawWindow:__init(model)
    self.model = model
    self.name = "FairylandLuckDrawWindow"
    self.windowId = WindowConfig.WinID.fairylandluckdrawwindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.fairylandluckdrawwindow, type = AssetType.Main}
        ,{file = AssetConfig.treasuremazetexture, type = AssetType.Dep}
        ,{file = AssetConfig.dropicon, type  =  AssetType.Dep}
        ,{file = AssetConfig.effectbg, type  =  AssetType.Dep}
        ,{file = "prefabs/effect/20301.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20299.unity3d", type = AssetType.Main}
        ,{file = AssetConfig.fairylandluckdrawbg, type  =  AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    ------------------------------------------------
    self.oneButton = nil
    self.tenButton = nil
    self.moneyText = nil
    self.select = nil
    self.itemList = {}
    self.itemSlotList = {}
    self.rollCount = 0
	self.selectId = 1
    self.show = false

    self.rollSpeed = 1
    self.itemNum = 16

    self.specialReward = 0
    ------------------------------------------------
    self.hearsayItemList = {}
    self.itemList_tenReward = {}
    self.itemSlotList_tenReward = {}

    ------------------------------------------------
    self._Update = function()
        self:Update()
    end

    self._OnUpdate = function(args)
        self:OnUpdate(args)
    end

    self._Roll = function()
    	self:Roll()
	end

    self._UpdateAsset = function()
        self:UpdateAsset()
    end

    ------------------------------------------------
    self.descTips = {TI18N("1.在<color='#ffff00'>彩虹幻境</color>中roll点未抽中时，可能获得{assets_2,90035}")
                    , TI18N("2.彩虹幻境中获得的{assets_2,90035}未使用部分会支持<color='#00ff00'>累积</color>")
                    , TI18N("3.彩虹魔盒<color='#ffff00'>持续1小时</color>，未抽奖的玩家可在下次活动结束时抽奖")}

    ------------------------------------------------

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FairylandLuckDrawWindow:__delete()
    self:OnHide()

    for _, itemSlot in pairs(self.itemSlotList) do
        itemSlot:DeleteMe()
    end
    self.itemSlotList = {}

    if self.itemSlot_oneReward ~= nil then
        self.itemSlot_oneReward:DeleteMe()
        self.itemSlot_oneReward = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function FairylandLuckDrawWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fairylandluckdrawwindow))
    self.gameObject.name = "FairylandLuckDrawWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    local transform = self.transform

    local closeBtn = transform:FindChild("Main/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    -- FairylandLuckDrawBg
    UIUtils.AddBigbg(self.transform:Find("Main/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.fairylandluckdrawbg)))

    -- Main
    self.mainTransform = transform:FindChild("Main")
    self.oneButtonText = self.mainTransform:FindChild("OneButton/NumText"):GetComponent(Text)
    self.tenButtonText = self.mainTransform:FindChild("TenButton/NumText"):GetComponent(Text)
	self.oneButton = self.mainTransform:FindChild("OneButton"):GetComponent(Button)
    self.oneButton.onClick:AddListener( function() self:LuckDraw(1) end )
    self.tenButton = self.mainTransform:FindChild("TenButton"):GetComponent(Button)
    self.tenButton.onClick:AddListener( function() self:LuckDraw(2)  end )

    self.oneButtonText_freeze = self.mainTransform:FindChild("OneButton_Freeze/NumText"):GetComponent(Text)
    self.tenButtonText_freeze = self.mainTransform:FindChild("TenButton_Freeze/NumText"):GetComponent(Text)
    self.oneButton_freeze = self.mainTransform:FindChild("OneButton_Freeze")
    self.tenButton_freeze = self.mainTransform:FindChild("TenButton_Freeze")

    self.moneyText = self.mainTransform:FindChild("Money/NumText"):GetComponent(Text)

    local item = nil
    for i = 1, 18 do
    	item = self.mainTransform:FindChild("Panel/"..i).gameObject
    	table.insert(self.itemList, item)

        local itemSlot = ItemSlot.New()
        UIUtils.AddUIChild(item, itemSlot.gameObject)
        table.insert(self.itemSlotList, itemSlot)
    end
    local effectObj = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20299.unity3d"))
    effectObj.transform:SetParent(self.itemList[17].transform)
    effectObj.transform.localScale = Vector3(1, 1, 1)
    effectObj.transform.localPosition = Vector3(0, 0, -100)
    Utils.ChangeLayersRecursively(effectObj.transform, "UI")
    effectObj = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20299.unity3d"))
    effectObj.transform:SetParent(self.itemList[18].transform)
    effectObj.transform.localScale = Vector3(1, 1, 1)
    effectObj.transform.localPosition = Vector3(0, 0, -100)
    Utils.ChangeLayersRecursively(effectObj.transform, "UI")

    self.select = self.mainTransform:FindChild("Panel/Select").gameObject
    self.select.transform:SetAsLastSibling()
    local p = self.itemList[1].transform.position
    self.select.transform.position = p
    self.select:SetActive(false)

    self.hearsayContainer = self.mainTransform.transform:FindChild("HearsayPanel/Container")
    self.hearsayItem = self.hearsayContainer.transform:FindChild("HearsayItem").gameObject
    self.hearsayItem:SetActive(false)

    self.descButton = self.mainTransform.transform:FindChild("DescButton"):GetComponent(Button)
    self.descButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.descButton.gameObject, itemData = self.descTips})
        --TipsManager.Instance.model:OpenChancePanel(207)
    end)

    -- OneReward
    self.oneRewardGameObject = transform:FindChild("OneReward").gameObject
    self.oneRewardTransform = transform:FindChild("OneReward/Main")
    self.transform:Find("OneReward/Panel"):GetComponent(Button).onClick:AddListener(function() self:HideOneReward() end)

    self.titleCon_oneReward = self.oneRewardTransform:Find("TitleCon")
    self.effectObj_oneReward = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20301.unity3d"))
    self.effectObj_oneReward.transform:SetParent(self.titleCon_oneReward)
    self.effectObj_oneReward.transform.localScale = Vector3(1, 1, 1)
    self.effectObj_oneReward.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effectObj_oneReward.transform, "UI")
    self.effectObj_oneReward:SetActive(true)
    self.oneRewardTransform:Find("ItemCon/effect"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")
    if self.rotateID == nil then
        self.rotateID = Tween.Instance:RotateZ(self.oneRewardTransform:Find("ItemCon/effect").gameObject, -720, 30, function() end):setLoopClamp()
    end

    self.itemCom_oneReward = self.oneRewardTransform:Find("ItemCon").gameObject
    self.itemSlot_oneReward = ItemSlot.New()
    UIUtils.AddUIChild(self.oneRewardTransform:Find("ItemCon/Slot"), self.itemSlot_oneReward.gameObject)
    self.nameText_oneReward = self.oneRewardTransform:Find("ItemCon/NameText"):GetComponent(Text)

    self.oneButtonText_oneReward = self.oneRewardTransform:FindChild("OneButton/NumText"):GetComponent(Text)
    self.tenButtonText_oneReward = self.oneRewardTransform:FindChild("TenButton/NumText"):GetComponent(Text)
    self.oneButton_oneReward = self.oneRewardTransform:FindChild("OneButton"):GetComponent(Button)
    self.oneButton_oneReward.onClick:AddListener( function() self:HideOneReward() self:LuckDraw(1) end )
    self.tenButton_oneReward = self.oneRewardTransform:FindChild("TenButton"):GetComponent(Button)
    self.tenButton_oneReward.onClick:AddListener( function() self:HideOneReward() self:LuckDraw(2) end )
    self.okButton_oneReward = self.oneRewardTransform:FindChild("OkButton"):GetComponent(Button)
    self.okButton_oneReward.onClick:AddListener( function() self:HideOneReward() end )
    self.tenButton_oneReward.gameObject:SetActive(false)

    -- TenReward
    self.tenRewardGameObject = transform:FindChild("TenReward").gameObject
    self.tenRewardTransform = transform:FindChild("TenReward/Main")
    self.transform:Find("TenReward/Panel"):GetComponent(Button).onClick:AddListener(function() self:HideTenReward() end)

    self.titleCon_tenReward = self.tenRewardTransform:Find("TitleCon")
    self.effectObj_tenReward = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20301.unity3d"))
    self.effectObj_tenReward.transform:SetParent(self.titleCon_tenReward)
    self.effectObj_tenReward.transform.localScale = Vector3(1, 1, 1)
    self.effectObj_tenReward.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effectObj_tenReward.transform, "UI")
    self.effectObj_tenReward:SetActive(true)

    for i = 1, 10 do
        item = self.tenRewardTransform:FindChild("Mask/Container"):GetChild(i-1).gameObject
        table.insert(self.itemList_tenReward, item)

        local itemSlot = BackpackGiftShowItem.New(item, self)
        UIUtils.AddUIChild(item, itemSlot.gameObject)
        table.insert(self.itemSlotList_tenReward, itemSlot)
    end
    self.container_tenReward = self.tenRewardTransform:FindChild("Mask/Container")
    self.containerRect_tenReward = self.container_tenReward:GetComponent(RectTransform)
    self.scrollCon_tenReward = self.tenRewardTransform:FindChild("Mask")
    self.scroll_tenReward = self.scrollCon_tenReward:GetComponent(ScrollRect)
    self.scroll_tenReward.enabled = false
    self.scroll_tenReward.onValueChanged:AddListener(function() self:OnChange_TenReward() end)

    self.leftButtonTransform_tenReward = self.tenRewardTransform:FindChild("LeftButton")
    self.rightButtonTransform_tenReward = self.tenRewardTransform:FindChild("RightButton")

    self.oneButtonText_tenReward = self.tenRewardTransform:FindChild("OneButton/NumText"):GetComponent(Text)
    self.tenButtonText_tenReward = self.tenRewardTransform:FindChild("TenButton/NumText"):GetComponent(Text)
    self.oneButton_tenReward = self.tenRewardTransform:FindChild("OneButton"):GetComponent(Button)
    self.oneButton_tenReward.onClick:AddListener( function() self:HideTenReward() self:LuckDraw(1) end )
    self.tenButton_tenReward = self.tenRewardTransform:FindChild("TenButton"):GetComponent(Button)
    self.tenButton_tenReward.onClick:AddListener( function() self:HideTenReward() self:LuckDraw(2) end )
    self.okButton_tenReward = self.tenRewardTransform:FindChild("OkButton"):GetComponent(Button)
    self.okButton_tenReward.onClick:AddListener( function() self:HideTenReward() end )
    self.tenButton_tenReward.gameObject:SetActive(false)

    local num = DataRaffle.data_cost[1].cost[1][2]
    self.oneButtonText.text = tostring(num)
    self.oneButtonText_freeze.text = tostring(num)
    self.oneButtonText_tenReward.text = tostring(num)
    self.oneButtonText_oneReward.text = tostring(num)
    num = DataRaffle.data_cost[2].cost[1][2]
    self.tenButtonText.text = tostring(num)
    self.tenButtonText_freeze.text = tostring(num)
    self.tenButtonText_oneReward.text = tostring(num)
    self.tenButtonText_tenReward.text = tostring(num)
    -------------------------------------------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function FairylandLuckDrawWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function FairylandLuckDrawWindow:OnShow()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._UpdateAsset)
    FairyLandManager.Instance.OnUpdate:Remove(self._OnUpdate)
    FairyLandManager.Instance.OnUpdate:Add(self._OnUpdate)

    self.show = true
    self:Update()
    self:UpdateHearsay()
    self:UpdateAsset()
    self:FreezeButton(false)

    -- FairyLandManager.Instance:request19201()
    self.hearsayTimerId = LuaTimer.Add(0, 10000, function()
        FairyLandManager.Instance:request19201()
    end)
end

function FairylandLuckDrawWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._UpdateAsset)
    FairyLandManager.Instance.OnUpdate:Remove(self._OnUpdate)
	self.show = false

     if self.rotateID ~= nil then
        Tween.Instance:Cancel(self.rotateID.id)
        self.rotateID = nil
    end

    if self.timeId_oneReward ~= nil then
      LuaTimer.Delete(self.timeId_oneReward)
      self.timeId_oneReward = nil
    end

    if self.timeId_tenReward ~= nil then
      LuaTimer.Delete(self.timeId_tenReward)
      self.timeId_tenReward = nil
    end

    if self.timeId1_tenReward ~= nil then
      LuaTimer.Delete(self.timeId1_tenReward)
      self.timeId1_tenReward = nil
    end

    if self.hearsayTimerId ~= nil then
      LuaTimer.Delete(self.hearsayTimerId)
      self.hearsayTimerId = nil
    end

    FairyLandManager.Instance:request19203()
end

------------------------------------------------------------
function FairylandLuckDrawWindow:OnUpdate(args)
    if args == "LuckdrawBegin" then
        self:RollStart()
    elseif args == "LuckdrawHearsay" then
        self:UpdateHearsay()
    end
end

function FairylandLuckDrawWindow:Update()
	if self.gameObject == nil or not self.show then return end

    self.rewardDataList = self.model:get_reward()
    for i = 1, 18 do
        local itemSlot = self.itemSlotList[i]
        local data = self.rewardDataList[i]
        local item_basedata = BackpackManager.Instance:GetItemBase(data.item_id)
        if item_basedata ~= nil then
            local itemData = ItemData.New()
            itemData:SetBase(item_basedata)
            itemData.quantity = data.item_num
            itemSlot:SetAll(itemData, {nobutton = true})
        end
    end
end

function FairylandLuckDrawWindow:LuckDraw(times)
    if self.gameObject == nil or not self.show then return end

    if times == 1 then
        if RoleManager.Instance.RoleData.crystal < DataRaffle.data_cost[1].cost[1][2] then
            NoticeManager.Instance:FloatTipsByString(TI18N("{assets_2,90035}不足，无法抽奖"))
            return
        end
    elseif times == 2 then
        if RoleManager.Instance.RoleData.crystal < DataRaffle.data_cost[2].cost[1][2] then
            NoticeManager.Instance:FloatTipsByString(TI18N("{assets_2,90035}不足，无法抽奖"))
            return
        end
    end

    if self.buttonFreeze then
        return
    end

    self.rollSpeed = 2


    FairyLandManager.Instance:request19202(times)

    self:FreezeButton(true)
end

function FairylandLuckDrawWindow:Roll()
    if self.gameObject == nil or not self.show then return end

	if self.rollCount == 0 then
        -- self:OnClickClose()
        self:RollEnd()
    else
        local p = self.itemList[self.selectId].transform.position
        self.select.transform.position = p
        if self.selectId == 17 or self.selectId == 18 then
            self.select.transform.sizeDelta = Vector2(72, 72)
        end

		self.rollCount = self.rollCount - 1
		if self.rollCount > self.itemNum * 2 then
    		LuaTimer.Add(25, self._Roll)
    	elseif self.rollCount > self.itemNum then
    		LuaTimer.Add(40, self._Roll)
    	elseif self.rollCount > 8 then
    		LuaTimer.Add(100, self._Roll)
    	elseif self.rollCount > 5 then
    		LuaTimer.Add(120, self._Roll)
    	elseif self.rollCount > 4 then
    		LuaTimer.Add(150, self._Roll)
    	elseif self.rollCount > 3 then
    		LuaTimer.Add(250, self._Roll)
    	elseif self.rollCount > 2 then
    		LuaTimer.Add(300, self._Roll)
    	elseif self.rollCount > 1 then
    		LuaTimer.Add(400, self._Roll)
    	else
    		LuaTimer.Add(800, self._Roll)
    	end

        if self.rollSpeed == 2 and self.rollCount > self.itemNum and self.rollCount % self.itemNum == 1 then self.rollCount = self.itemNum + 1 end

        self.selectId = self.selectId + 1
        if self.selectId > self.itemNum then self.selectId = 1 end

        if self.rollCount == 1 then
            if self.specialReward == 1 then
                self.selectId = 17
            elseif self.specialReward == 2 then
                self.selectId = 18
            end
        end

        if self.soundIndex < 4 then
            SoundManager.Instance:Play(278)
            self.soundIndex = self.soundIndex + 1
        end
    end
end

function FairylandLuckDrawWindow:RollStart()
    local index = 1 -- Random.Range(1, self.itemNum + 1)
    for i = 1, #self.rewardDataList do
        if self.model.luckDrawId == self.rewardDataList[i].id then
            index = i
            break
        end
    end
    self.selectId = 1
    self.rollCount = self.itemNum * 2 + index
    self.rollSpeed = 1
    self.soundIndex = 1
    LuaTimer.Add(500, self._Roll)

    self.select:SetActive(true)
    self.select.transform.sizeDelta = Vector2(64, 64)

    if index == 17 then
        self.rollCount = self.itemNum * 4 + 7
        self.specialReward = 1
    elseif index == 18 then
        self.rollCount = self.itemNum * 4 + 15
        self.specialReward = 2
    end
end

function FairylandLuckDrawWindow:RollEnd()
    FairyLandManager.Instance:request19203()
    FairyLandManager.Instance:request19201()
    self:FreezeButton(false)
    if self.model.luckDrawTimes == 1 then
        self:ShowOneReward()
    elseif self.model.luckDrawTimes == 2 then
        self:ShowTenReward()
    end
end

function FairylandLuckDrawWindow:FreezeButton(freeze)
    self.buttonFreeze = freeze
    if freeze then
        self.oneButton.gameObject:SetActive(false)
        self.tenButton.gameObject:SetActive(false)

        self.oneButton_freeze.gameObject:SetActive(true)
        self.tenButton_freeze.gameObject:SetActive(false)
    else
        self.oneButton.gameObject:SetActive(true)
        self.tenButton.gameObject:SetActive(false)

        self.oneButton_freeze.gameObject:SetActive(false)
        self.tenButton_freeze.gameObject:SetActive(false)
    end
end

function FairylandLuckDrawWindow:UpdateHearsay()
    BaseUtils.dump(self.model.luckDrawLogs, "self.model.luckDrawLogs")
    local index = 0
    for i = #self.model.luckDrawLogs, 1, -1 do
        local data = self.model.luckDrawLogs[i]
        for j = 1, #data.prizes do
            index = index + 1
            self:AddHearsay(index, data.rid, data.platform, data.zone_id, data.name, data.time, data.prizes[j].item_id, data.prizes[j].item_num)
            if index >= 20 then
                return
            end
        end
    end
end

function FairylandLuckDrawWindow:AddHearsay(index, rid, platform, zone_id, name, time, item_id, item_num)
    local hearsayItem = self.hearsayItemList[index]
    if hearsayItem == nil then
        local item = GameObject.Instantiate(self.hearsayItem)
        item:SetActive(true)
        item.transform:SetParent(self.hearsayContainer.transform)
        item.transform:SetAsFirstSibling()
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        local text = item.transform:FindChild("Text"):GetComponent(Text)
        local textExt = MsgItemExt.New(text, 190, 16, 26)

        self.hearsayItemList[index] = {}
        self.hearsayItemList[index].item = item
        self.hearsayItemList[index].text = text
        self.hearsayItemList[index].textExt = textExt
        hearsayItem = self.hearsayItemList[index]
    end

    local itemBase = BaseUtils.copytab(DataItem.data_get[item_id])
    local itemText = itemBase.name
    if item_num > 1 then
        itemText = string.format("%sx%s", itemText, item_num)
    end
    local showMsg = string.format(TI18N("<color='#ffff00'>[%s]</color>运气爆棚，在魔盒中抽中了<color='#b031d5'>%s</color>"), name, itemText)
    hearsayItem.textExt:SetData(showMsg)
    local size = hearsayItem.text.transform.sizeDelta
    hearsayItem.item:GetComponent(LayoutElement).preferredHeight = size.y + 4
end

function FairylandLuckDrawWindow:UpdateAsset()
    self.moneyText.text = tostring(RoleManager.Instance.RoleData.crystal)
end

---------------------------------------------------
function FairylandLuckDrawWindow:ShowOneReward()
    self.oneRewardGameObject:SetActive(true)

    self:Update_OneReward()
end

function FairylandLuckDrawWindow:HideOneReward()
    self.oneRewardGameObject:SetActive(false)
end

function FairylandLuckDrawWindow:ShowTenReward()
    self.tenRewardGameObject:SetActive(true)

    self:Update_TenReward()
end

function FairylandLuckDrawWindow:HideTenReward()
    self.tenRewardGameObject:SetActive(false)
end

---------------------------------------------------
function FairylandLuckDrawWindow:Update_OneReward()
    SoundManager.Instance:Play(269)

    local base = BaseUtils.copytab(DataItem.data_get[self.model.luckDrawPrizes[1].item_id])
    local item = ItemData.New()
    item:SetBase(base)
    item.quantity = self.model.luckDrawPrizes[1].item_num
    self.itemSlot_oneReward:SetAll(item, {nobutton = true})
    self.nameText_oneReward.text = base.name

    -- self.itemCom_oneReward:SetActive(false)
    -- if self.timeId_oneReward ~= nil then
    --   LuaTimer.Delete(self.timeId_oneReward)
    --   self.timeId_oneReward = nil
    -- end

    -- self.timeId_oneReward = LuaTimer.Add(800, function()
    --     self.itemCom_oneReward:SetActive(true)
    --     self.itemCom_oneReward.transform.localScale = Vector3.one * 2.5
    --     Tween.Instance:Scale(self.itemCom_oneReward.gameObject, Vector3.one, 0.2, nil, LeanTweenType.linear)
    -- end)
end

---------------------------------------------------
function FairylandLuckDrawWindow:Update_TenReward()
    SoundManager.Instance:Play(269)

    self.data_tenReward = self.model.luckDrawPrizes
    for i,v in ipairs(self.data_tenReward) do
        local item = self.itemSlotList_tenReward[i]
        item:SetData({item_id = v.item_id, bind = 0, num = v.item_num})
    end

    self:EndShow_TenReward()
    self:BeginShow_TenReward()
end

function FairylandLuckDrawWindow:EndShow_TenReward()
    if self.timeId_tenReward ~= nil then
      LuaTimer.Delete(self.timeId_tenReward)
      self.timeId_tenReward = nil
    end

    self.currIndex_tenReward = 0
end

function FairylandLuckDrawWindow:BeginShow_TenReward()
    self.containerRect_tenReward.anchoredPosition = Vector3.zero
    self.timeId_tenReward = LuaTimer.Add(0, 100, function() self:Loop_TenReward() end)
end

function FairylandLuckDrawWindow:Loop_TenReward()
    self.currIndex_tenReward = self.currIndex_tenReward + 1
    if self.currIndex_tenReward > #self.data_tenReward then
        self:EndShow_TenReward()
        self.timeId1_tenReward = LuaTimer.Add(1000, function() self:Reset_TenReward() end)
    else
        if self.currIndex_tenReward > 5 then
            local t = self.container_tenReward.localPosition + Vector3(-160, 0, 0)
            self.tweenId = Tween.Instance:MoveLocal(self.container_tenReward.gameObject, t, 0.2).id
        end

        local item = self.itemSlotList_tenReward[self.currIndex_tenReward]
        item:Show()
    end
end

function FairylandLuckDrawWindow:Reset_TenReward()
    self.scroll_tenReward.enabled = true
    self:OnChange_TenReward()
end

function FairylandLuckDrawWindow:OnChange_TenReward()
    if self.containerRect_tenReward.anchoredPosition.x < -50 then
        self.leftButtonTransform_tenReward:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.leftButtonTransform_tenReward.localScale = Vector3(-1, 1, 1)
    else
        self.leftButtonTransform_tenReward:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.leftButtonTransform_tenReward.localScale = Vector3.one
    end

    local m = self.containerRect_tenReward.rect.width
    if self.containerRect_tenReward.anchoredPosition.x < - m / 2 + 50 then
        self.rightButtonTransform_tenReward:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow13")
        self.rightButtonTransform_tenReward.localScale = Vector3(-1, 1, 1)
    else
        self.rightButtonTransform_tenReward:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow7")
        self.rightButtonTransform_tenReward.localScale = Vector3.one
    end
end
