CampBoxLeftItem = CampBoxLeftItem or BaseClass()

function CampBoxLeftItem:__init(gameObject, isHasDoubleClick, posId, parent)
    self.parent = parent
    self.posId = posId
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    local obj = self.gameObject.transform:Find("ItemSlot").gameObject
    self.ItemSlot = ItemSlot.New(obj, isHasDoubleClick)
    -- self.isBackActive = true
    self.step = 0

    local resources = {
        { file = AssetConfig.campbox_texture, type = AssetType.Dep }
        ,{ file = string.format(AssetConfig.effect, 20393), type = AssetType.Main }
    }
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources)

    self.ImgBack = self.gameObject.transform:Find("BackBg")
    self.ForwardBg = self.gameObject.transform:Find("ForwardBg")

    self.backBtn = self.gameObject.transform:Find("BackBg"):GetComponent(Button)

    self.nameBg = self.gameObject.transform:Find("ItemNameBg")
    self.nameText = self.gameObject.transform:Find("ItemNameBg/ItemName"):GetComponent(Text)
    self.nameBg.gameObject:SetActive(false)

    self.backBtn.onClick:AddListener( function() self:ApplyActiveBtn() end)

    self.activeBtn = self.gameObject.transform:Find("Button"):GetComponent(Button)

    self.timerID1 = nil
    self.hasSetName = false
end

function CampBoxLeftItem:__delete()
    if self.ItemSlot ~= nil then
        self.ItemSlot:DeleteMe()
    end
    if self.timerID1 ~= nil then
        LuaTimer.Delete(self.timerID1)
        self.timerID1 = nil
    end
    if self.timerID2 ~= nil then
        LuaTimer.Delete(self.timerID2)
        self.timerID2 = nil
    end
    if self.tweenID1 ~= nil then
        Tween.Instance:Cancel(self.tweenID1)
        self.tweenID1 = nil
    end
    if self.tweenID2 ~= nil then
        Tween.Instance:Cancel(self.tweenID2)
        self.tweenID2 = nil
    end
    if self.timerID3 ~= nil then
        LuaTimer.Delete(self.timerID3)
        self.timerID3 = nil
    end
end

function CampBoxLeftItem:SetData(itemData, extra, status, n)
    local num = n or 0
    if status == true then
        self.ItemSlot:SetAll(itemData, extra)
        self.ItemSlot:SetNum(num)
        self.ItemSlot.qualityBg.gameObject:SetActive(false)
        self.nameText.text = string.format("%s", ColorHelper.color_item_name(itemData.quality, itemData.name))
        self.ItemSlot.button.onClick:RemoveAllListeners()
        self.activeBtn.onClick:RemoveAllListeners()
        self.activeBtn.onClick:AddListener( function() self.ItemSlot:ClickSelf() self.ItemSlot:ShowSelect(false) end)
    end
    self:SetStatus(status)
    -- self.isBackActive = status
end

function CampBoxLeftItem:SetStatus(t)
    if t == false then
        self.ImgBack.gameObject:SetActive(true)
        self.hasSetName = false
    elseif t == true then
        self.ImgBack.gameObject:SetActive(false)
    end
end

function CampBoxLeftItem:SetName(t)
    if t == false then
        self.nameBg.gameObject:SetActive(false)
    elseif t == true then
        self.nameBg.gameObject:SetActive(true)
    end
end

function CampBoxLeftItem:ApplyActiveBtn()
    if self.parent.lastRewardItem ~= nil then
        self.parent.lastRewardItem:SetName(false)
        self.parent.lastRewardItem.hasSetName = true
    end
    self.parent.lastRewardItem = self


    if not CampBoxManager.Instance.needRefresh then
        CampBoxManager.Instance:send17866(self.posId)

        if self.parent.hasNum < self.parent.costNum then
            local itemData = ItemData.New()
            local gameObject = self.gameObject
            itemData:SetBase(DataItem.data_get[self.parent.costItemId])
            TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData})
        end
    end
end

function CampBoxLeftItem:PlayOpenEffect()

    self.ImgBack.gameObject:SetActive(false)
    self.ItemSlot.gameObject:SetActive(false)
    self.ForwardBg.gameObject:SetActive(false)
    if self.openEffect == nil then
        self.openEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20393)))
        self.openEffect.transform:SetParent(self.transform)
        self.openEffect.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(self.openEffect.transform, "UI")
        self.openEffect.transform.localScale = Vector3(1, 1, 1)
        self.openEffect.transform.localPosition = Vector3(45, -45, -400)
    end
    self.openEffect.gameObject:SetActive(true)
    if self.timerID1 ~= nil then
        LuaTimer.Delete(self.timerID1)
    end
    self.timerID1 = LuaTimer.Add(1600,
    function()
        if self.timerID1 ~= nil then
            LuaTimer.Delete(self.timerID1)
            self.timerID1 = nil
        end
        self.openEffect.gameObject:SetActive(false)
    end )
    self.timerID3 = LuaTimer.Add(600, function()
        if self.timerID3 ~= nil then
            LuaTimer.Delete(self.timerID3)
            self.timerID3 = nil
        end
        self.ForwardBg.gameObject:SetActive(true)
        self.ItemSlot.gameObject:SetActive(true)
        if self.hasSetName == false then
            self:SetName(true)
        end
    end )


end

function CampBoxLeftItem:PlayRefresEffect(toPos)
    local curPos = self.transform.anchoredPosition;
    self.localPos = Vector3(curPos.x, curPos.y, 0)
    if self.tweenID1 ~= nil then
        Tween.Instance:Cancel(self.tweenID1)
    end
    self.tweenID1 = Tween.Instance:MoveLocal(self.gameObject, toPos, 0.2,
    function()
        if self.tweenID1 ~= nil then
            Tween.Instance:Cancel(self.tweenID1)
            self.tweenID1 = nil
        end
        if self.timerID2 ~= nil then
            LuaTimer.Delete(self.timerID2)
        end
        self.timerID2 = LuaTimer.Add(200,
        function()
            if self.tweenID2 ~= nil then
                Tween.Instance:Cancel(self.tweenID2)
            end
            self.tweenID2 = Tween.Instance:MoveLocal(self.gameObject, self.localPos, 0.3,
            function()
                if self.tweenID2 ~= nil then
                    Tween.Instance:Cancel(self.tweenID2)
                    self.tweenID2 = nil
                end
                CampBoxManager.Instance.isRefreshing = false;
                CampBoxManager.Instance.needRefresh = false;
            end ,
            LeanTweenType.linear).id;
        end );
    end ,
    LeanTweenType.linear).id;
end