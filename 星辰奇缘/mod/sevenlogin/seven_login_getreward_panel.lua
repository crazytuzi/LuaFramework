--2017/6/17
--zhongyuhan
--七天登录活动
SevenLoginGetRewardPanel = SevenLoginGetRewardPanel or BaseClass(BasePanel)

function SevenLoginGetRewardPanel:__init(model)
    self.model = model
    self.name = "SevenLoginGetRewardPanel"
    self.Effect = "prefabs/effect/20298.unity3d"
        self.resList = {
        {file = AssetConfig.treasuremazerewardpanel, type = AssetType.Main}
        ,{file = self.Effect, type = AssetType.Main}
        ,{file = AssetConfig.treasuremazetexture, type = AssetType.Dep}
        ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.effectbg, type  =  AssetType.Dep}
    }

    self.itemSlotList = {}
    self.rotateIdList = nil

end

function SevenLoginGetRewardPanel:OnInitCompleted()

end

function SevenLoginGetRewardPanel:__delete()
    if self.rotateIdList ~= nil then
       for k,v in pairs(self.rotateIdList) do
          Tween.Instance:Cancel(v.id)
       end
       self.rotateIdList = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.itemSlotList ~= nil then
        for k,v in pairs(self.itemSlotList) do
            v:DeleteMe()
        end
        self.itemSlotList = {}
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()

end

function SevenLoginGetRewardPanel:InitPanel()
    self.rotateIdList = {}
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasuremazerewardpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "SevenLoginGetRewardPanel"
    self.transform = self.gameObject.transform

    self.TitleCon = self.transform:Find("MainCon/TitleCon")
    self.effectObj = GameObject.Instantiate(self:GetPrefab(self.Effect))
    self.effectObj.transform:SetParent(self.TitleCon)
    self.effectObj.transform.localScale = Vector3(1, 1, 1)
    self.effectObj.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effectObj.transform, "UI")
    self.effectObj:SetActive(true)

    -- self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() end)
    self.transform:Find("MainCon/ItemCon/effect"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")

    self.itemContainerTr = self.transform:Find("MainCon")
    self.itemCon = self.transform:Find("MainCon/ItemCon")
    self.itemCon.gameObject:SetActive(false)

    local numberI = 1
    for i=1,#self.openArgs[1] do
        numberI = numberI * -1
        local gameObject = GameObject.Instantiate(self.itemCon.gameObject)
        local rectTr = gameObject.transform:GetComponent(RectTransform)
        gameObject.transform:SetParent(self.itemContainerTr)
        gameObject.transform.localScale = Vector3(1, 1, 1)
        gameObject:SetActive(true)
        if #self.openArgs[1] % 2 == 0 then
            rectTr.anchoredPosition = Vector2(math.floor((i - 1)/2)*90*numberI + numberI*55,0,0)

        else
            if i == 1 then
               rectTr.anchoredPosition = Vector2(0,0,0)
            else
               rectTr.anchoredPosition = Vector2(math.floor((i - 2)/2)*90*numberI + numberI*90,0,0)
            end
        end
        self:CreatSlot(self.openArgs[1][i],gameObject)

    end



    self.confirmBtnString = self.openArgs[2] or TI18N("确定")
    self.countTime = self.openArgs[3] or 3
    self.confirmText = self.transform:Find("MainCon/ImgConfirmBtn/Text"):GetComponent(Text)
    self.transform:Find("MainCon/ImgConfirmBtn"):GetComponent(Button).onClick:AddListener(function()
        self:DeleteMe()
    end)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    end
end


function SevenLoginGetRewardPanel:CreatSlot(data, parent)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[data[1]]
    if base == nil then
        Log.Error("道具id配错():[baseid:" .. tostring(data[1]) .. "]")
    end
    parent.transform:Find("NameText"):GetComponent(Text).text = ColorHelper.color_item_name(base.quality,base.name)
    info:SetBase(base)
    info.quantity = data[2]
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    slot:SetNum(data[3])
    table.insert(self.itemSlotList,slot)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)

    local rotateID = Tween.Instance:RotateZ(parent.transform:Find("effect").gameObject, -720, 30, function() end):setLoopClamp()
    table.insert(self.rotateIdList,rotateID)
end

function SevenLoginGetRewardPanel:OnTime()
    if self.countTime <= 0 then
        self:DeleteMe()
    else
        self.countTime = self.countTime - 1
        self.confirmText.text = self.confirmBtnString .. string.format("(%ss)", tostring(self.countTime))
    end
end
