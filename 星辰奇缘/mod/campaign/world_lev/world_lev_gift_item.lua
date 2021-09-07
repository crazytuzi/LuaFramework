-- region *.lua
-- Date jia
-- 此文件由[BabeLua]插件自动生成
-- 世界等级活动礼包item
-- endregion
WorldLevGiftItem = WorldLevGiftItem or BaseClass()
function WorldLevGiftItem:__init(origin_item, _index)
    self.index = _index
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.gameObject:SetActive(true)

    self.ImgBg = self.transform:Find("Bg"):GetComponent(Image)
    self.ImgLignt = self.transform:Find("IconLignt"):GetComponent(Image)

    self.ImgIcon1 = self.transform:Find("PriceBg1/Currency"):GetComponent(Image)
    self.ImgIcon2 = self.transform:Find("PriceBg2/Currency"):GetComponent(Image)

    self.ConIcon = self.transform:Find("IconCon")

    self.TxtOld = self.transform:Find("PriceBg1/Text"):GetComponent(Text)
    self.TxtCur = self.transform:Find("PriceBg2/Text"):GetComponent(Text)
    self.BtnBuy = self.transform:Find("Buy"):GetComponent(Button)
    self.TxtName = self.transform:Find("NameBg/Name"):GetComponent(Text)
    self.BtnBuy.onClick:AddListener(
    function()
        if self.status == CampaignEumn.Status.Accepted then
            return
        end
        if self.baseData.loss_items[1][1] == 90002 then
            local asset =  RoleManager.Instance.RoleData:GetMyAssetById(90002)
            if asset < self.baseData.loss_items[1][2] then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
            else
                self:BuyItem()
            end
        else
            self:BuyItem()
        end
    end )

    local newX =(_index - 1) * 170
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, 0)
    self.imgLoader = nil
    self.slot = nil
    self.baseData = nil
end

function WorldLevGiftItem:SetData(data,status)
    self.baseData = data
    self.status = status
    if self.baseData ~= nil then
        self.TxtOld.text = self.baseData.camp_cond_client
        self.TxtCur.text = string.format("<color='#00ffaa'>%s</color>", self.baseData.loss_items[1][2]);
        if self.slot == nil then
            self.slot = ItemSlot.New()
        end
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[self.baseData.rewardgift[1][1]])
        self.slot:SetAll(itemData, { inbag = false, nobutton = true })
        self.slot:SetNum(self.baseData.rewardgift[1][2])
        self.slot.gameObject:SetActive(true)
        UIUtils.AddUIChild(self.ConIcon.gameObject, self.slot.gameObject)
        self.slot.localScale = Vector3.one
        self.slot.localPosition = Vector3.zero
        -- self.slot:ShowBg(false)
        self.TxtName.text = ColorHelper.color_item_name(itemData.qualify, itemData.name)

        if self.status == CampaignEumn.Status.Accepted then
            self.transform:Find("Buy"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.transform:Find("Buy/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
            self.transform:Find("Buy/Text"):GetComponent(Text).text = TI18N("已购买")
        else
            self.transform:Find("Buy"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.transform:Find("Buy/Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
            self.transform:Find("Buy/Text"):GetComponent(Text).text = TI18N("购买")
        end
    end
    -- self:StartRotate()
    -- self:DoRefresh()
end

function WorldLevGiftItem:BuyItem()
    local id = tonumber(self.baseData.loss_items[1][1]);
    local num = tonumber(self.baseData.loss_items[1][2]);
    if RoleManager.Instance.RoleData:GetMyAssetById(id) < num then
        local base_data = DataItem.data_get[id]
        local info = { itemData = base_data, gameObject = self.BtnBuy.gameObject }
        TipsManager.Instance:ShowItem(info)
        return
    end
    WorldLevManager.Instance.GiftRefreshIndex = self.baseData.group_index
    CampaignManager.Instance:Send14001(self.baseData.id)
end

function WorldLevGiftItem:__delete()
    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
    end
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    self.ImgBg.sprite = nil
    self.ImgLignt.sprite = nil
    self.transform:Find("Buy"):GetComponent(Image).sprite = nil
end


function WorldLevGiftItem:StartRotate()
    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
    end
    self.rotationTweenId = Tween.Instance:ValueChange(0, 360, 4,
    function()
        if self.rotationTweenId ~= nil then
            Tween.Instance:Cancel(self.rotationTweenId)
            self.rotationTweenId = nil
        end
        self:StartRotate()
    end , LeanTweenType.Linear,
    function(value)
        self.transform:Find("IconLignt").localRotation = Quaternion.Euler(0, 0, value)
    end ).id
end

function WorldLevGiftItem:DoRefresh()
    self.ConIcon:GetComponent(RectTransform).anchoredPosition = Vector2(0, 200)
    self.ConIcon:GetComponent(RectTransform).localScale = Vector2(0.5, 0.5)
    self.ConIcon.gameObject:SetActive(true)
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    if self.scaleID ~= nil then
        Tween.Instance:Cancel(self.scaleID)
        self.scaleID = nil
    end
    self.scaleID = Tween.Instance:Scale(self.ConIcon.gameObject, Vector3(1, 1, 1), 0.5,
    function()
        if self.scaleID ~= nil then
            Tween.Instance:Cancel(self.scaleID)
            self.scaleID = nil
        end
    end , LeanTweenType.easeOutBounce).id

    self.shakeID = Tween.Instance:MoveLocalY(self.ConIcon.gameObject, 72, 0.5,
    function()
        if self.shakeID ~= nil then
            Tween.Instance:Cancel(self.shakeID)
            self.shakeID = nil
        end
    end , LeanTweenType.easeOutBounce).id
end
