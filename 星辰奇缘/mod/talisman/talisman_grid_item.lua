TalismanGridItem = TalismanGridItem or BaseClass()

function TalismanGridItem:__init(gameObject, assetWrapper)
    self.gameObject = gameObject.gameObject
    self.assetWrapper = assetWrapper
    self.canClick = false

    self.isLock = false    --默认不锁定

    -- 点击回调
    self.clickCallback = nil

    self:InitPanel()

    self:SetDefault()
end

function TalismanGridItem:__delete()
    self.gameObject = nil
    self.assetWrapper = nil

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.setImage ~= nil then
        self.setImage.sprite = nil
    end
end

function TalismanGridItem:InitPanel()
    self.transform = self.gameObject.transform
    self.bgImg = self.transform:Find("Bg"):GetComponent(Image)
    self.imgLoader = SingleIconLoader.New(self.transform:Find("Icon").gameObject)

    self.numBg = self.transform:Find("NumBg")
    self.numText = self.numBg:Find("Text"):GetComponent(Text)
    self.transitionBtn = self.gameObject:GetComponent(TransitionButton)
    self.select = self.transform:Find("Select")
    self.suiting = self.transform:Find("Suiting").gameObject
    self.setImage = self.transform:Find("Set"):GetComponent(Image)
    if self.select ~= nil then
        self.select = self.select.gameObject
    end
    self.arrow = self.transform:Find("UpArrow")
    if self.arrow ~= nil then
        self.arrow = self.arrow.gameObject
    end
    self.add = self.transform:Find("Add")
    if self.add ~= nil then
        self.add = self.add.gameObject
    end
    self.new = self.transform:Find("New")
    if self.new ~= nil then
        self.new = self.new.gameObject
    end

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function TalismanGridItem:SetData(data,index)
    self.data = data
    if data ~= nil then
        self.numText.text = data.id
    end
    if data == nil or TalismanManager.Instance.model.useItemDic[data.id] ~= nil then
        self:SetDefault()
        local model = TalismanManager.Instance.model
        if index ~= nil and index > model.hasLockGridNum then
            self.isLock = true
            self:SetLock()
        end
    else
        self.transitionBtn.scaleSetting = true
        self.transitionBtn.soundSetting = true
        self.canClick = true

        if data.base_id == nil then
            self:SetDefault()
            self:Add(true)
            self.canClick = true
            self.isLock = false
        else
            self:Add(false)
            local cfgData = DataTalisman.data_get[data.base_id]
            self.imgLoader:SetSprite(SingleIconType.Item, cfgData.icon)

            self.setImage.gameObject:SetActive(true)
            self.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
            self.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
            self:Up(self:CheckForUp())
        end

        self:SetNum(1)
        self:SetNew(TalismanManager.Instance.model.newItemId[data.id] ~= nil)
    end
end

function TalismanGridItem:SetDefault()
    self.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")
    self.imgLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Twills"))
    self.transitionBtn.scaleSetting = false
    self.transitionBtn.soundSetting = false
    self.setImage.gameObject:SetActive(false)

    self.canClick = false
    self.suiting:SetActive(false)

    self:Select(false)
    self:Up(false)
    self:Add(false)
    self:SetNew(false)

    self:SetNum(0)
end

function TalismanGridItem:Add(bool)
    if self.add ~= nil then
        self.add:SetActive(bool == true)
    end
end

function TalismanGridItem:Up(bool)
    if self.arrow ~= nil then
        self.arrow:SetActive(bool == true)
    end
end

function TalismanGridItem:SetNum(num)
    if num < 2 then
        self.numBg.gameObject:SetActive(false)
    else
        self.numBg.gameObject:SetActive(true)
        self.numText.text = tostring(num)
    end
end

function TalismanGridItem:OnClick()
    if self.canClick == true and self.clickCallback ~= nil then
        if self.data ~= nil and self.data.base_id ~= nil then
            self.clickCallback(self.data)
        else
            if self.isLock then
                --弹框
                local times = 0
                local cost = 1000
                local moneyType = 90000
                local gridNum = TalismanManager.Instance.model.hasLockGridNum
                if gridNum >= 3*16 and gridNum <= 4*16 then
                    times = (gridNum - 3*16)/4 + 1
                end
                if times ~= 0 then
                    local cost_two = DataTalisman.data_get_add_volume[times].cost
                    cost = cost_two[1][2]
                    moneyType = cost_two[1][1]
                end
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.content = string.format(TI18N("是否消耗<color='#ffff00'>%s</color>{assets_2,%s}开启<color='#ffff00'>4格</color>宝物背包？"), cost, moneyType)
                confirmData.sureLabel = TI18N("确认")
                confirmData.cancelLabel = TI18N("取消")
                confirmData.sureCallback = function()
                    --发开格子的协议
                    TalismanManager.Instance:send19612()
                end
                NoticeManager.Instance:ConfirmTips(confirmData)
            else
                TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = DataItem.data_get[21240]})
            end
        end
    end
end

function TalismanGridItem:Select(bool)
    if self.select ~= nil then
        self.select:SetActive(bool == true)
    end
end

function TalismanGridItem:CheckForUp()
    if self.data == nil then
        return false
    end

    local model = TalismanManager.Instance.model

    local cfgData = DataTalisman.data_get[self.data.base_id]

    local type = TalismanEumn.TypeProto[cfgData.type]
    local wearTalisman = model.itemDic[(model.planList[model.use_plan][type] or {id = -1}).id] or {}


    local mark = false
    local wearSetId = (DataTalisman.data_get[wearTalisman.base_id] or {}).set_id
    local data_absorb_set_id_map = DataTalisman.data_absorb_set_id_map[cfgData.set_id]
    if data_absorb_set_id_map ~= nil and BaseUtils.ContainValueTable(data_absorb_set_id_map.dst_map, wearSetId) then
        mark = true
    end
    if not mark and cfgData.set_id ~= (DataTalisman.data_get[wearTalisman.base_id or 0] or {}).set_id then
        return false
    end


    -- local wearTalisman = model.itemDic[model.planList[model.use_plan or 0][TalismanEumn.TypeProto[DataTalisman.data_get[self.data.base_id].type]].id] or {}

    local thisMax = 0
    for _,attr in ipairs(self.data.attr) do
        if thisMax < TalismanEumn.DecodeFlag(attr.flag, 2) then
            thisMax = TalismanEumn.DecodeFlag(attr.flag, 2)
        end
    end
    local wearMin = 6
    for _,attr in ipairs(wearTalisman.attr or {}) do
        if wearMin > TalismanEumn.DecodeFlag(attr.flag, 2) then
            wearMin = TalismanEumn.DecodeFlag(attr.flag, 2)
        end
    end

    return thisMax > wearMin
end

function TalismanGridItem:SetNew(bool)
    if self.new ~= nil then
        self.new:SetActive(bool == true)
    end
end

--设置是否锁定
function TalismanGridItem:SetLock(bool)
    self.bgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")
    self.imgLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Lock"))
    if self.imgLoader.image ~= nil then
        self.imgLoader.image:SetNativeSize()
    end

    self.transitionBtn.scaleSetting = false
    self.transitionBtn.soundSetting = false
    self.setImage.gameObject:SetActive(false)

    self.canClick = true
    self.suiting:SetActive(false)

    self:Select(false)
    self:Up(false)
    self:Add(false)
    self:SetNew(false)

    self:SetNum(0)
end
