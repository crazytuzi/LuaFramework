--时装颜值提升界面
--2017/2/8
--zzl

FashionFaceScoreWindow  =  FashionFaceScoreWindow or BaseClass(BaseWindow)

function FashionFaceScoreWindow:__init(model)
    self.name  =  "FashionFaceScoreWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.fashion_face_win
    self.resList  =  {
        {file = AssetConfig.fashion_facescore, type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20272), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.is_open = false

    self.updateListener = function() self:UpdateInfo() end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)

    return self
end

function FashionFaceScoreWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)

    self.is_open  =  false

    if self.bottomSlot ~= nil then
        self.bottomSlot:DeleteMe()
        self.bottomSlot = nil
    end

    if self.Levbtn ~= nil then
        self.Levbtn:DeleteMe()
        self.Levbtn = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function FashionFaceScoreWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_facescore))
    self.gameObject:SetActive(false)
    self.gameObject.name = "FashionFaceScoreWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main = self.transform:FindChild("MainCon")
    self.CloseButton = self.main:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self.model:CloseFashionFaceUI()
    end)

    self.BottomFaceScoreCon = self.main:FindChild("BottomFaceScoreCon")
    self.TxtLev = self.BottomFaceScoreCon:FindChild("ImgFaceScoreLev/TxtLev"):GetComponent(Text)
    self.ImgProgBarRect = self.BottomFaceScoreCon:FindChild("ImgProg/ImgProgBar"):GetComponent(RectTransform)
    self.TxtProgBar = self.BottomFaceScoreCon:FindChild("ImgProg/TxtProgBar"):GetComponent(Text)

    self.itemList = {}
    for i = 1, 6 do
        local itemGo = self.main:Find(string.format("MidCon/ItemProp%s", i)).gameObject
        local item = self:CreateMidItem(itemGo, i)
        table.insert(self.itemList, item)
        item.go:SetActive(false)
    end
    self.itemList[6].transform:GetComponent(Button).onClick:AddListener(function()
        self.model:OpenFashionFaceRewardUI()
    end)


    self.BottomCon = self.main:Find("BottomCon")
    self.SlotCon = self.BottomCon:Find("ItemCon/SlotCon").gameObject
    self.SlotTxtName = self.BottomCon:Find("ItemCon/TxtName"):GetComponent(Text)
    self.SlotTxtNeed = self.BottomCon:Find("ItemCon/TxtNeed"):GetComponent(Text)
    self.ImgCoin = self.BottomCon:Find("ItemCon/ImgCoin"):GetComponent(Image)
    self.BtnLevUp = self.BottomCon:Find("BtnLevUp")

    self.BtnUpEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnUpEffect.transform:SetParent(self.BtnLevUp)
    self.BtnUpEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnUpEffect.transform, "UI")
    self.BtnUpEffect.transform.localScale = Vector3(1.8, 0.8, 1)
    self.BtnUpEffect.transform.localPosition = Vector3(-55, -19, -400)
    self.BtnUpEffect.gameObject:SetActive(false)

    self.ProgEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20272)))
    self.ProgEffect.transform:SetParent(self.BottomFaceScoreCon:FindChild("ImgProg"))
    self.ProgEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.ProgEffect.transform, "UI")
    self.ProgEffect.transform.localScale = Vector3(1, 1, 1)
    self.ProgEffect.transform.localPosition = Vector3(-14, 0, -400)
    self.ProgEffect.gameObject:SetActive(false)

    self.Levbtn = BuyButton.New(self.BtnLevUp, TI18N("升级"))
    self.Levbtn.key = "FashionUpgrade"
    self.Levbtn.protoId = 13204
    self.Levbtn:Show()

    self.bottomSlot = self:CreateSlot(self.SlotCon)

    self.onLevUp = function()
        FashionManager.Instance:request13204()
    end
    self.onPricesBack = function(prices)
        local cfgData = DataFashion.data_face[string.format("%s_%s", self.model.collect_lev+1, RoleManager.Instance.RoleData.classes)]
        if prices[cfgData.loss[1][1]] ~= nil then
            local price_str
            local allprice = prices[cfgData.loss[1][1]].allprice
            local price_str = ""
            if allprice >= 0 then
                price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], allprice)
            else
                price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], -allprice)
            end
            self.SlotTxtNeed.text = price_str
            self.ImgCoin.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[prices[cfgData.loss[1][1]].assets])
            self.ImgCoin.gameObject:SetActive(true)
        else
            self.SlotTxtNeed.text = ""
            self.ImgCoin.gameObject:SetActive(false)
        end
    end
    self.is_open  =  true
    self:UpdateInfo()
end

--播放升级成功特效
function FashionFaceScoreWindow:OnLevUpSuccess()
    if self.is_open == false then
        return
    end
    self.ProgEffect.gameObject:SetActive(false)
    self.ProgEffect.gameObject:SetActive(true)
end

function FashionFaceScoreWindow:UpdateInfo()
    if self.is_open == false then
        return
    end
    local cfgData = DataFashion.data_face[string.format("%s_%s", self.model.collect_lev+1, RoleManager.Instance.RoleData.classes)]
    self.TxtLev.text = tostring(self.model.collect_lev)
    local percent = self.model.collect_val/cfgData.loss_collect
    self.BtnUpEffect.gameObject:SetActive(false)
    if percent >= 1 then
        percent = 1
        self.BtnUpEffect.gameObject:SetActive(true)
    end
    self.ImgProgBarRect.sizeDelta = Vector2(324*percent, 21)
    self.TxtProgBar.text = string.format(TI18N("总颜值：%s/%s"), self.model.collect_val, cfgData.loss_collect)

    local lastLevAttrDic = {}
    local curIsZero = true
    if self.model.collect_lev ~= 0 then
        curIsZero = false
        local tempCfgData = DataFashion.data_face[string.format("%s_%s", self.model.collect_lev, RoleManager.Instance.RoleData.classes)]
        for i = 1, #tempCfgData.attrs do
            local temp = tempCfgData.attrs[i]
            lastLevAttrDic[temp.effect_type] = temp
        end
    end
    for i = 1, #self.itemList do
        self.itemList[i].go:SetActive(false)
    end
    for i = 1, #cfgData.attrs do
        local attr = cfgData.attrs[i]
        local item = self.itemList[i]
        item.go:SetActive(true)
        if curIsZero then
            item.TxtName.text = KvData.attr_name[attr.effect_type]
            item.TxtVal_1.text = 0
            item.TxtVal_2.text = attr.val
        else
            item.TxtName.text = KvData.attr_name[attr.effect_type]
            item.TxtVal_1.text = lastLevAttrDic[attr.effect_type].val
            item.TxtVal_2.text = attr.val
        end
    end
    if #cfgData.gain > 0 then
        local rewardItem = self.itemList[5]
        rewardItem.TxtName.text = ""
        for i = 1, #cfgData.gain do
            local base_data = DataItem.data_get[cfgData.gain[i][1]]
            rewardItem.TxtName.text = string.format(TI18N("升级可获得：<color='#02FC6F'>%s</color>"), base_data.name) --string.format("%s %s", rewardItem.TxtName.text, base_data.name)
            rewardItem.transform:GetComponent(Button).onClick:RemoveAllListeners()
            rewardItem.transform:GetComponent(Button).onClick:AddListener(function()
                local info = {itemData = base_data, gameObject = rewardItem.go}
                TipsManager.Instance:ShowItem(info)
            end)
            rewardItem.go:SetActive(true)
            break
        end
    end
    local nextItem = self.itemList[6]
    -- local nextIndex = #cfgData.attrs+1
    -- local newX = nextIndex%2 == 0 and 120 or -120
    -- local newY = 42.5 - (math.ceil(nextIndex/2) - 1)*40
    -- nextItem.go:GetComponent(RectTransform).anchoredPosition = Vector2(newX, newY)
    nextItem.go:SetActive(true)

    local base_data = DataItem.data_get[cfgData.loss[1][1]]
    self:SetSlotData(self.bottomSlot, base_data)
    self.SlotTxtName.text = base_data.name

    local needNum = cfgData.loss[1][2]
    local hasNum =BackpackManager.Instance:GetItemCount(cfgData.loss[1][1])
    self.bottomSlot:SetNum(hasNum, needNum)
    local buy_list = {}
    buy_list[cfgData.loss[1][1]] = {need = needNum}
    self.Levbtn:Layout(buy_list, self.onLevUp , self.onPricesBack)
end

function FashionFaceScoreWindow:CreateMidItem(go, index)
    local item = {}
    item.go = go
    item.transform = go.transform
    item.TxtName = item.transform:Find("TxtName"):GetComponent(Text)
    if index ~= 6 and index ~= 5 then
        item.TxtVal_1 = item.transform:Find("TxtVal_1"):GetComponent(Text)
        item.TxtVal_2 = item.transform:Find("TxtVal_2"):GetComponent(Text)
    end
    return item
end


--创建slot
function FashionFaceScoreWindow:CreateSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function FashionFaceScoreWindow:SetSlotData(slot, data)
    if data == nil then
        slot:SetAll(nil, nil)
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end