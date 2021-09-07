-- ---------------------------------
-- 道具格子
-- hosr
-- ---------------------------------
ItemSlot = ItemSlot or BaseClass()

function ItemSlot:__init(gameObject,isHasDoubleClick)
    self.isItemSlot = true
    self.prefab_path = AssetConfig.slot_item
    self.NotAlpha = Color(1,1,1,1)
    self.Alpha = Color(1,1,1,0)

    self.isHasDoubleClick = isHasDoubleClick

    self:Create(gameObject)

    self.lockCallback = function() self:ClickLock() end
    self.addCallback = function() self:ClickAdd() end
    self.lockFunc = nil
    self.addFunc = nil
    self.doubleClickFunc = nil
    self.clickSelfFunc = nil

    self.itemData = nil
    -- 不需要tips
    self.noTips = false
    self.lastClickTime = os.time()
    --格子位置
    self.pos = 1

    self.imgLoader = nil

    self.effect = nil

    if ctx.IsDebug then
        ZTest.ItemSlotTab[tostring(self)] = self
        self.trace = debug.traceback()
    end
end

function ItemSlot:__delete()
    if ctx.IsDebug then
        ZTest.ItemSlotTab[tostring(self)] = nil
    end

    self.qualityBg = nil
    self.bgImg = nil
    -- self.itemImg = nil
    self.stateImg = nil
    self.lockCallback = nil
    self.addCallback = nil
    self.lockFunc = nil
    self.addFunc = nil
    self.doubleClickFunc = nil
    self.clickSelfFunc = nil
    self.lastClickTime = nil
    self.NotAlpha = nil
    self.Alpha = nil

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if self.pieceImg ~= nil then
        BaseUtils.ReleaseImage(self.pieceImg)
    end

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    self.itemData = nil
    self.extra = nil

    if not BaseUtils.isnull(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        -- BackpackManager.Instance:PutSlotBack(self.gameObject)
    end

    self.gameObject = nil

end

-- --------------------------------------
-- 创建一个预设
-- 如果在New的时候传人预设gameObject,这里就不会去instantiate
-- --------------------------------------
function ItemSlot:Create(gameObject)
    if self.gameObject == nil then
        if gameObject == nil then
            gameObject = GameObject.Instantiate(BackpackManager.Instance:GetPrefab(self.prefab_path))
            -- gameObject = BackpackManager.Instance:GetSlotObject()
            gameObject.name = "ItemSlot"
        end

        self.gameObject = gameObject
        self.transform = self.gameObject.transform
        self.bgImg = self.gameObject:GetComponent(Image)
        self.nameTxt = self.transform:Find("Name"):GetComponent(Text)
        self.itemBg = self.transform:GetComponent(Image)
        if self.imgLoader == nil then
            local go = self.transform:Find("ItemImg").gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end

        self.transform:Find("ItemImg").gameObject:SetActive(true)
        self.itemImgRect = self.transform:Find("ItemImg"):GetComponent(RectTransform)
        self.itemImgRect.anchorMax = Vector2.one * 0.5
        self.itemImgRect.anchorMin = Vector2.one * 0.5
        self.itemImgRect.offsetMin = Vector2.zero
        self.itemImgRect.offsetMax = Vector2.zero
        -- self.itemImgRect.sizeDelta = Vector2(52, 52)

        if self.transform:Find("ImgFrame") ~= nil then
            self.stepCon = self.transform:Find("ImgFrame").gameObject
            self.stepTxt = self.transform:Find("ImgFrame"):Find("TxtLev"):GetComponent(Text)
        end
        self.numTxt = self.transform:Find("Num"):GetComponent(Text)
        self.numRect = self.numTxt.gameObject:GetComponent(RectTransform)
        self.enchantTxt = self.transform:Find("Strengthen"):GetComponent(Text)
        self.addBtn = self.transform:Find("AddButton"):GetComponent(Button)
        self.lockBtn = self.transform:Find("Lock"):GetComponent(Button)
        self.selectObj = self.transform:Find("SelectImg").gameObject
        self.stateObj = self.transform:Find("State").gameObject
        self.stateImg = self.stateObj:GetComponent(Image)
        self.stateRect = self.stateObj:GetComponent(RectTransform)
        self.equipLevelObj = self.transform:Find("EquipLevel").gameObject
        self.equipLevelTxt = self.equipLevelObj.transform:Find("Text"):GetComponent(Text)
        self.newObj = self.transform:Find("New")

        self.setImage = self.transform:Find("Set")
        if self.setImage ~= nil then
            self.setImage = self.setImage:GetComponent(Image)
            self.setImage.gameObject:SetActive(false)
        end

        if self.newObj ~= nil then self.newObj = self.newObj.gameObject end

        local sellTrans = self.transform:Find("Tag")
        if sellTrans ~= nil then
            self.sellableObj = sellTrans.gameObject
            self.TagText = sellTrans:Find("Text"):GetComponent(Text)
            self.sellableObj:SetActive(false)
        end

        local qualityBgTrans = self.transform:Find("QualityBg")
        if qualityBgTrans ~= nil then
            self.qualityBg = qualityBgTrans.gameObject:GetComponent(Image)
        end
        -- Mark 补丁补丁
        local rect = self.qualityBg.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(0.5, 0.5)
        rect.anchorMin = Vector2(0.5, 0.5)
        -- rect.offsetMin = Vector2(0.5, 0.5)
        -- rect.offsetMax = Vector2(0.5, 0.5)
        rect.sizeDelta = Vector2(self.transform.rect.width, self.transform.rect.width)

        local nbg = self.transform:Find("NumBg")
        if nbg ~= nil then
            self.numBg = nbg.gameObject
            self.numBg:SetActive(false)
            self.numBgRect = self.numBg:GetComponent(RectTransform)
        end

        local sbg = self.transform:Find("StrengthBg")
        if sbg ~= nil then
            self.strengthBg = sbg.gameObject
            self.strengthBg:SetActive(false)
        end

        local piece = self.transform:Find("Piece")
        if piece ~= nil then
            self.pieceObj = piece.gameObject
            self.pieceObj:SetActive(false)
            self.pieceImg = self.pieceObj:GetComponent(Image)
        end
        
        local fruitTagBg = self.transform:Find("StreTopBg")
        local fruitTag = self.transform:Find("StreTopTxt")
        --StreTopTxt
        if fruitTagBg ~= nil then
            self.fruitTagBg = fruitTagBg.gameObject
            self.fruitTagBg:SetActive(false)
        end
        if fruitTag ~= nil then
            self.fruitTag = fruitTag.gameObject
            self.fruitTag:SetActive(false)
            self.fruitTagText = self.fruitTag:GetComponent(Text)
        end

        self.addBtn.onClick:AddListener(function() self:ClickAdd() end)
        self.lockBtn.onClick:AddListener(function() self:ClickLock() end)

        self.button = self.gameObject:GetComponent(Button)
        self.button.onClick:AddListener(function() self:ClickSelf() end)

        self:Default()
    end
end

function ItemSlot:DoubleClick(item)
    self.doubleClickFunc(item)
end

function ItemSlot:ClickSelf()
    if self.itemData == nil then
        return
    end

    if self.clickSelfFunc ~= nil then
        self.clickSelfFunc(self.itemData)
    end

    local timeTemp = os.time()
    local timeBetween = timeTemp - self.lastClickTime
    self.lastClickTime = timeTemp
    if timeBetween < 1 then
        if self.doubleClickFunc ~= nil then
            if self.timerId ~= nil then
                LuaTimer.Delete(self.timerId)
            end
            self:DoubleClick(self)
            return
        end
    end
    if self.isHasDoubleClick ~= nil and self.isHasDoubleClick == true then
        self.timerId = LuaTimer.Add(200, function () self:SureClick() end)
    else
        self:SureClick()
    end

    MarketManager.Instance.onReloadGoldMarket:Fire()
end

function ItemSlot:SureClick()
    if self.click_self_call_back ~= nil then
        self.click_self_call_back(self.itemData) --执行点击自己回调
    end

    if not self.noTips then
        if self.extra ~= nil and self.extra.inbag and self.itemData.expire_time ~= 0 and self.itemData.expire_time ~= nil then
            if self.itemData.expire_type ~= BackpackEumn.ExpireType.StartTime and self.itemData.expire_type ~= BackpackEumn.ExpireType.StartDate then
                if self.itemData.expire_time - BaseUtils.BASE_TIME <= 0 then
                    --已过期失效
                    if self.itemData.alchemy ~= 0 then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = string.format("%s%s%s{assets_2, 90017}", ColorHelper.color_item_name(self.itemData.quality , "["..self.itemData.name.."]") , TI18N("已过期，可炼化为"), self.itemData.alchemy*self.itemData.quantity)
                        data.sureLabel = TI18N("确认")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function()
                            AlchemyManager.Instance:request14908(self.itemData.id)
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    else
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = string.format("%s%s", ColorHelper.color_item_name(self.itemData.quality , "["..self.itemData.name.."]"), TI18N("已过期，是否删除"))
                        data.sureLabel = TI18N("确认")
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function()
                            BackpackManager.Instance:Send10320({id = self.itemData.id, storage = BackpackEumn.StorageType.Backpack})
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    end
                    TipsManager.Instance.model.currentItem = self
                    self:ShowSelect(true)
                    return
                end
            end
        end

        -- if self.itemData.type == BackpackEumn.ItemType.petattrgem or self.itemData.type == BackpackEumn.ItemType.petskillgem then
        --     TipsManager.Instance:ShowPetEquip(self)
        -- elseif self.itemData.type == BackpackEumn.ItemType.childattreqm or self.itemData.type == BackpackEumn.ItemType.childskilleqm then
        --     TipsManager.Instance:ShowPetEquip(self)
        -- elseif self.itemData.func == TI18N("变身") then
        --     local isRandom = false
        --     local isNewFruit = false
        --     for i,v in ipairs(self.itemData.effect) do
        --         if v.effect_type == 52 then
        --             isNewFruit = true
        --             break
        --         end

        --         if v.effect_type == 20 then
        --             isRandom = true
        --             break
        --         end
        --     end
        --     if isNewFruit then
        --         TipsManager.Instance:ShowFruitNew(self)
        --     elseif isRandom then
        --         TipsManager.Instance:ShowRandomFruit(self)
        --     else
        --         TipsManager.Instance:ShowFruit(self)
        --     end
        -- else
        --     if BackpackManager.Instance:IsEquip(self.itemData.type) then
        --         TipsManager.Instance:ShowEquip(self)
        --     else
        --         TipsManager.Instance:ShowItem(self)
        --     end
        -- end

        TipsManager.Instance:ShowAllItemTips(self)
        self:ShowSelect(true)
    end
end

function ItemSlot:Default(default)
    self:ShowBg(true)
    self:ShowEnchant(false)
    self:ShowSelect(false)
    self:ShowState(false)
    self:ShowLock(false)
    self:ShowAddBtn(false)
    self:ShowImg(false)
    self:ShowSell(false)
    self:ShowStep(false)
    self:SetNew(false)
    if self.numBg ~= nil then
        self.numBg:SetActive(false)
    end
    if self.pieceObj ~= nil then
        self.pieceObj:SetActive(false)
    end

    self.nameTxt.text = ""
    self.numTxt.text = ""
    self.enchantTxt.text = ""
    self.lockFunc = nil
    self.addFunc = nil
    self:DefaultQuality()

    if default == 1 then
        self:SetDefaultTalisman()
    else
        if self.qualityBg ~= nil then
            self.qualityBg.gameObject:SetActive(false)
        end
    end
end

-- --------------------------------
-- 设置所有
-- 调用这个方法就会把所有参数的设成默认值
-- 建议创建的时候调用一次，然后之后的修改调用单个方法来修改
-- 参数格式说明:
-- info = 道具数据结构 查看item_data.lua
-- extra = 扩展参数,tips用
-- ---- inbag = 是否在背包
-- ---- nobutton = 是否不要任何按钮
-- ---- allowZero = 是否允许零个物品
-- ---- noshowTag = 是否不显示可售标签
-- ---- noselect = 是否不点击选中
-- ---- noqualitybg = 没品质框
-- ---- white_list = 自定义列表 {id,show}
-- ---- 注意，传人white_list就直接根据该列表处理，不做默认处理
-- --------------------------------
function ItemSlot:SetAll(info, extra)
    local icon = nil
    if info ~= nil then
        icon = info.icon
        if info.extra ~= nil then
            --装备神器图标统一处理
            for i=1,#info.extra do
                 if info.extra[i].name == 9 then
                   local temp_id = info.extra[i].value
                    icon = DataItem.data_get[temp_id].icon
                    break
                 end
            end
        end
    end
    self.extra = extra
    self.itemData = info
    -- 法宝统一无选中无按钮
    if self.itemData ~= nil and (self.itemData.type == BackpackEumn.ItemType.talismanring or self.itemData.type == BackpackEumn.ItemType.talismanmask or self.itemData.type == BackpackEumn.ItemType.talismancloak or self.itemData.type == BackpackEumn.ItemType.talismanbadge) then
        if self.extra == nil then
            self.extra = {}
        end
        self.extra.noselect = true
        self.extra.nobutton = true
    end
    self:Default()
    if info ~= nil and icon ~= nil then
        self:SetNum(info.quantity, info.need)
        if self.qualityBg ~= nil then
            self:DefaultQuality()
            self:SetQualityInBag(info.quality)
        end
        self:SetImg(icon)
        self:SetEnchant(info.enchant)
        self:SetLevel(info.lev)
        self:SetSell(info.tips_type, info.bind)

        if self.itemData.type == BackpackEumn.ItemType.ride_piece then
            self:ShowPiece()
        end
        if self.itemData.type == BackpackEumn.ItemType.limit_fruit then
            self:ShowFruittrengthenTag(extra, info.extra)
        end
        if HandbookManager.Instance.model:GetIdNeed(info.base_id) and extra ~= nil and (extra.inbag == true or extra.insliver == true or extra.instore == true) then
            if self.TagText ~= nil then
                self.TagText.text = TI18N("需求")
                self:ShowSell(true)
            end
        elseif self.TagText ~= nil then
            self.TagText.text = TI18N("可售")
        end

        --75-雷暴六技能标志
        if extra ~= nil and not extra.inbag and info.base_id == 20185 and extra.isSix == true then
            if self.TagText ~= nil then
                self.TagText.text = TI18N("6技能")
                self:ShowSell(true)
                extra.isSix = false
            end
        end

        if self.extra ~= nil and self.extra.inbag then
            self.itemImgRect.sizeDelta = Vector2.one * 52
        else
            self.itemImgRect.sizeDelta = Vector2.one * 56
        end

        if DataTalisman.data_get[info.base_id] ~= nil then
            self:ShowTalismanSet(true, DataTalisman.data_get[info.base_id].set_id)
        else
            self:ShowTalismanSet(false)
        end
    end
end

function ItemSlot:ShowTalismanSet(bool, set_id)
    if bool then
        if self.setImage ~= nil then
            self.setImage.gameObject:SetActive(true)
            self.setImage.sprite = BackpackManager.Instance.assestWrapper:GetSprite(AssetConfig.talisman_set, tostring(set_id))
        end
    else
        if self.setImage ~= nil then
            self.setImage.gameObject:SetActive(false)
        end
    end
end

function ItemSlot:ShowPiece()
    if self.pieceObj ~= nil then
        self.pieceObj:SetActive(true)
        local val = 1
        for i,v in ipairs(self.itemData.effect_client) do
            if v.effect_type_client == BackpackEumn.ItemUseClient.ride_piece then
                val = v.val_client[1]
            end
        end
        self.pieceImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, string.format("SlotPiece%s", val))
    end
end

function ItemSlot:ShowFruittrengthenTag(extra,extra2)
    if extra ~= nil and extra.inbag then
        if self.fruitTagBg ~= nil and self.fruitTag ~= nil then
            self.fruitTagBg:SetActive(false)
            self.fruitTag:SetActive(false)
            local fruit_lev = 0
            for i,v in pairs(extra2) do
                if v.name == BackpackEumn.ExtraName.fruit_lev then
                    fruit_lev = v.value
                end
            end
            if fruit_lev == 0 then
                self.fruitTagBg:SetActive(false)
                self.fruitTag:SetActive(false)
            else
                self.fruitTagText.text = string.format(TI18N("+%s"), fruit_lev)
                self.fruitTagBg:SetActive(true)
                self.fruitTag:SetActive(true)
            end
        end
    end
end

-- --------------------------------
-- 设置品阶
-- --------------------------------
function ItemSlot:SetStep(step)
    self.stepCon:SetActive(true)
    self.stepTxt.text = tostring(step)
end

-- --------------------------------
-- 设置数量显示
-- --------------------------------
function ItemSlot:SetNum(_num, _need, _forceShow)
    local num = _num or 1
    local need = _need or 0
    if _forceShow ~= nil then
        local color = ColorHelper.color[0]
        self.numTxt.text = string.format("<color='%s'>%s</color>/%s", color, self:FormatNum(num), self:FormatNum(need))
        self.numTxt.gameObject:SetActive(true)
    elseif self.extra ~= nil and self.extra.inbag or need == 0 then
        self.numTxt.text = self:FormatNum(num)
        if self.extra ~= nil and self.extra.allowZero ~= nil then
            self.numTxt.gameObject:SetActive(true)
            self.numBg:SetActive(true)
        else
            self.numTxt.gameObject:SetActive(num>1)
            self.numBg:SetActive(num>1)
        end
    else
        local color = (num < need) and ColorHelper.color[6] or  "#00ff00"
        self.numTxt.text = string.format("<color='%s'>%s</color>/%s", color, self:FormatNum(num), self:FormatNum(need))
        self.numTxt.gameObject:SetActive(true)
    end

    local w = math.max(math.ceil(self.numTxt.preferredWidth) + 1, 18)
    self.numRect.sizeDelta = Vector2(w, 24)

    if self.extra ~= nil then
        if ((num > 1 or need >= 1) or (self.extra.noZero == true and num == 0)) and self.numBg ~= nil then
            self.numBg:SetActive(true)
            -- w = math.max(25, w + 2)
            self.numBgRect.sizeDelta = Vector2(w + 2, 18)
        end
    elseif ((num > 1 or need >= 1) or _forceShow ~= nil) and self.numBg ~= nil then
        self.numBg:SetActive(true)
        -- w = math.max(25, w + 2)
        self.numBgRect.sizeDelta = Vector2(w + 2, 18)
    end
    local xprefix = -4.37
    if w >= 56 then
        xprefix = 0
    end
    self.numBgRect.anchoredPosition = Vector2(xprefix, self.numBgRect.anchoredPosition.y)
    self.numTxt.transform.anchoredPosition = Vector2(xprefix, self.numBgRect.anchoredPosition.y + 0.5)
    self.numTxt.transform.sizeDelta = self.numBgRect.sizeDelta
end

function ItemSlot:FormatNum(val)
    if val >= 10000 and val < 100000 then
        local temp = math.floor(val/10000)
        return string.format("%s%s", temp, TI18N("万"))
    elseif val >= 100000 and val < 1000000 then
        local temp = math.floor(val/1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 1000000 and val < 10000000 then
        local temp = math.floor(val/1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 10000000 and val < 100000000 then
        local temp = math.floor(val/10000000)
        return string.format("%s%s", temp, TI18N("千万"))
    elseif val >= 100000000 and val < 1000000000 then
        local temp = math.floor(val/10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    elseif val >= 1000000000 then
        local temp = math.floor(val/10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    end
    return tostring(val)
end

-- ---------------------------------
-- 设置道具品质，更新背景图标
-- ---------------------------------
function ItemSlot:DefaultQuality()
    if self.itemData ~= nil and (self.itemData.type == BackpackEumn.ItemType.talismanring or self.itemData.type == BackpackEumn.ItemType.talismanmask or self.itemData.type == BackpackEumn.ItemType.talismancloak or self.itemData.type == BackpackEumn.ItemType.talismanbadge) then
        self.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level"..tostring(quality))
        self.bgImg.enabled = false
        self.qualityBg.gameObject:SetActive(true)
    else
        self.bgImg.enabled = true
        -- self.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        self.qualityBg.gameObject:SetActive(false)
    end
end

function ItemSlot:SetQuality(quality)
    quality = quality or 0
    quality = quality + 1
    if quality < 4 then
        self:DefaultQuality()
    else
        if self.extra ~= nil and self.extra.inbag then
            self:DefaultQuality()
        else
            if self.itemData ~= nil and (self.itemData.type == BackpackEumn.ItemType.talismanring or self.itemData.type == BackpackEumn.ItemType.talismanmask or self.itemData.type == BackpackEumn.ItemType.talismancloak or self.itemData.type == BackpackEumn.ItemType.talismanbadge) then
                self.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level"..tostring(quality))
                self.qualityBg.gameObject:SetActive(true)
                self.bgImg.enabled = false
            else
                self.bgImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, tostring(quality))
                self.qualityBg.gameObject:SetActive(false)
                self.bgImg.enabled = true
            end
        end
    end
end

function ItemSlot:SetQualityInBag(quality)
    quality = quality or 0
    quality = quality + 1
    if self.itemData ~= nil and (self.itemData.type == BackpackEumn.ItemType.talismanring or self.itemData.type == BackpackEumn.ItemType.talismanmask or self.itemData.type == BackpackEumn.ItemType.talismancloak or self.itemData.type == BackpackEumn.ItemType.talismanbadge) then
        self.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level"..tostring(quality-1))
        -- self.qualityBg.gameObject.transform.sizeDelta = Vector2(self.transform.rect.width, self.transform.rect.width) * 1.2 -- self.transform.sizeDelta*1.2
        self.qualityBg.gameObject.transform.anchorMin = Vector2(-0.1,-0.1)
        self.qualityBg.gameObject.transform.anchorMax = Vector2(1.1,1.1)
        self.qualityBg.gameObject.transform.offsetMin = Vector2.zero
        self.qualityBg.gameObject.transform.offsetMax = Vector2.zero
        self.qualityBg.gameObject:SetActive(true)
    elseif quality < 5 or (self.extra ~= nil and self.extra.noqualitybg) then
        self.qualityBg.gameObject:SetActive(false)
    else
        self.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Item%s", quality))
        self.qualityBg.gameObject.transform.anchorMin = Vector2.zero
        self.qualityBg.gameObject.transform.anchorMax = Vector2.one
        self.qualityBg.gameObject.transform.offsetMin = Vector2.zero
        self.qualityBg.gameObject.transform.offsetMax = Vector2.zero
        self.qualityBg.gameObject:SetActive(true)
    end
end

-- ------------------------------------
-- 设置道具图标
-- ------------------------------------
function ItemSlot:SetImg(iconId)
    if self.imgLoader == nil then
        local go = self.transform:Find("ItemImg").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, iconId)
    self:ShowImg(true)
end

-- ------------------------------------
-- 设置道具图标
-- ------------------------------------
function ItemSlot:SetGrey(gray)
    if gray then
        if self.imgLoader ~= nil then
            self.imgLoader:SetIconColor(Color.grey)
        end
    else
        if self.imgLoader ~= nil then
            self.imgLoader:SetIconColor(Color.white)
        end
    end
end

function ItemSlot:SetColor(color)
    if self.imgLoader ~= nil then
        self.imgLoader:SetIconColor(color)
    end
end

-- ------------------------------
-- 设置装备道具等级
-- ------------------------------
function ItemSlot:SetLevel(lev)
    self.equipLevelTxt.text = tostring(lev)
    -- self.equipLevelObj:SetActive(self.isShowLevel)
end

-- ------------------------------
-- 设置装备强化等级
-- ------------------------------
function ItemSlot:SetEnchant(enchant)
    if enchant ~= nil and enchant >= 1 then
        self.enchantTxt.text = string.format("+%s", enchant)
        self.enchantTxt.gameObject:SetActive(true)
        if self.strengthBg ~= nil then
            self.strengthBg:SetActive(true)
        end
    else
        self.enchantTxt.text = ""
        self.enchantTxt.gameObject:SetActive(false)
        if self.strengthBg ~= nil then
            self.strengthBg:SetActive(false)
        end
    end
    -- self.enchantTxt.gameObject:SetActive(self.isShowEnchant)
end

-- -----------------------------------
-- 设置点击加号回调
-- -----------------------------------
function ItemSlot:SetAddCallback(func)
    if func == nil then 
        self.addBtn.enabled = false
    else
        self.addBtn.enabled = true
    end
    self.addFunc = func
end

-- -----------------------------------
-- 设置点击锁回调
-- -----------------------------------
function ItemSlot:SetLockCallback(func)
    self.lockFunc = func
end

-- -----------------------------------
-- 设置点击回调
-- -----------------------------------
function ItemSlot:SetSelectSelfCallback(func)
    self.click_self_call_back = func
end

-- ===================================================================
-- 以下显示隐藏设置
-- ===================================================================
-- -----------------------------
-- 是否显示道具强化等级
-- -----------------------------
function ItemSlot:ShowEnchant(bool)
    self.enchantTxt.gameObject:SetActive(bool)
end

-- -----------------------------
-- 是否显示道具等级
-- -----------------------------
function ItemSlot:ShowLevel(bool)
    self.equipLevelObj:SetActive(bool)
end

-- ------------------------------
-- 是否显示选中状态
-- ------------------------------
function ItemSlot:ShowSelect(bool)
    if BaseUtils.is_null(self.selectObj) then
        return
    end
    if self.extra ~= nil and self.extra.noselect == true then
        self.selectObj:SetActive(false)
    else
        self.selectObj:SetActive(bool)
    end
end

-- ------------------------------
-- 是否显示状态红点
-- ------------------------------
function ItemSlot:ShowState(bool)
    if self.stateObj ~= nil then
        self.stateObj:SetActive(bool)
    end
end
--显示红点/绿点，
function ItemSlot:ShowState_ImgPos(bo,imgStr,pos)
    if bo == true then
        self.stateObj:SetActive(true)
        if imgStr ~= nil and imgStr ~= "" then
            self.stateImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, imgStr)
        else
            self.stateImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
        end
        if pos ~= nil then
            self.stateRect.anchoredPosition = pos
        end
    else
        self.stateObj:SetActive(false)
        self.stateImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
        self.stateRect.anchoredPosition = Vector3(-25,25,0)
    end
end

-- ------------------------------
-- 是否显示加号
-- ------------------------------
function ItemSlot:ShowAddBtn(bool)
    self.addBtn.gameObject:SetActive(bool)
end

-- ------------------------------
-- 是否显示img
-- ------------------------------
function ItemSlot:ShowImg(bool)
    if bool then
        if self.imgLoader ~= nil then
            self.imgLoader:SetIconColor(Color(1,1,1,1))
        end
    else
        if self.imgLoader ~= nil then
            self.imgLoader:SetIconColor(Color(1,1,1,0))
        end
    end
end

-- -----------------------------
-- 是否显示背景
-- -----------------------------
function ItemSlot:ShowBg(bool)
    if bool then
        if self.NotAlpha ~= nil then
            self.bgImg.color = self.NotAlpha
        end
    else
        if self.Alpha ~= nil then
            self.bgImg.color = self.Alpha
        end
    end
end

-- ------------------------------
-- 是否显示锁
-- ------------------------------
function ItemSlot:ShowLock(bool)
    self.lockBtn.gameObject:SetActive(bool)
end

-- ------------------------------
-- 是否显示数字
-- ------------------------------
function ItemSlot:ShowNum(bool)
    self.numTxt.gameObject:SetActive(bool)
    if self.numBg ~= nil then
        self.numBg:SetActive(bool)
    end
end

-- ------------------------------
-- 是否显示品阶
-- ------------------------------
function ItemSlot:ShowStep(bool)
    if self.stepCon ~= nil then
        self.stepCon:SetActive(bool)
    end
end

-- ------------------------------
-- 是否显示可售
-- ------------------------------
function ItemSlot:ShowSell(bool)
    if self.sellableObj ~= nil then
        self.sellableObj.gameObject:SetActive(bool)
    end
end

-- ----------------------------
-- 显示格子名称
-- ----------------------------
function ItemSlot:ShowName(str)
    self.nameTxt.text = str
    self.nameTxt.gameObject:SetActive(str ~= "")
end

-- -----------------------
-- 设置不要tips
-- -----------------------
function ItemSlot:SetNotips(btn_state)
    self.noTips = true
    if btn_state == nil then
        self.button.enabled = false
    else
        self.button.enabled = btn_state
    end
end

function ItemSlot:ClickLock()
    if self.lockFunc ~= nil then
        self.lockFunc()
    end
end

function ItemSlot:ClickAdd()
    if self.addFunc ~= nil then
        self.addFunc()
    end
end

function ItemSlot:SetSell(tips_type, bind)
    self:ShowSell(false)
    if self.extra ~= nil and self.extra.noshowTag == false and self.sellableObj ~= nil and bind == BackpackEumn.BindType.unbind then
        self:ShowSell(self:CanSell(tips_type))
    end
end

function ItemSlot:CanSell(tips_type)
    for k,v in pairs(tips_type) do
        local icon = StringHelper.MatchBetweenSymbols(v.val, "%[", "%]")[1]
        if (v.tips == TipsEumn.ButtonType.Sell and icon == "1") or DataMarketGold.data_market_gold_exchange[self.itemData.base_id] ~= nil then
            return true
        end
    end
    return false
end

function ItemSlot:SetPos(position)
    self.pos = position
    if self.gameObject ~= nil then
        self.gameObject.name = tostring(self.pos)
    end
end

function ItemSlot:SetItemSprite(sprite)
    if self.imgLoader == nil then
        local go = self.transform:Find("ItemImg").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetOtherSprite(sprite)
    self.itemImgRect.sizeDelta = Vector2.one * 56
    self:ShowImg(true)
end

-- -----------------------
-- 设置默认宝物格子的底
-- -----------------------
function ItemSlot:SetDefaultTalisman()
    if self.qualityBg ~= nil then
        self.qualityBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level2")
        self.qualityBg.gameObject.transform.sizeDelta = Vector2(self.transform.rect.width, self.transform.rect.width) * 1.2 -- self.transform.sizeDelta*1.2
        self.qualityBg.gameObject:SetActive(true)
        self:ShowTalismanSet(false)
    else
        self.qualityBg.gameObject.transform.sizeDelta = Vector2(self.transform.rect.width, self.transform.rect.width)
    end
end

-- -----------------------
-- 设置ItemSlot的底
-- -----------------------
function ItemSlot:SetItemBg(img_name)
    if self.itemBg ~= nil then
        if img_name ~= nil then 
            self.itemBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, img_name)
        else
            self.itemBg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        end
    end
end

-- ---------------------------
-- 设置“新”的戳
-- ---------------------------
function ItemSlot:SetNew(bool)
    if self.newObj ~= nil then
        self.newObj:SetActive(bool == true)
    end
    if self.pieceObj ~= nil and bool then
        self.pieceObj:SetActive(false)
    end
end


-- 添加特效
function ItemSlot:ShowEffect(t,id)
    if t == true then
        if self.effect == nil then
             self.effect = BibleRewardPanel.ShowEffect(id,self.transform:Find("ItemImg"), Vector3(1, 1, 1), Vector3(0, 0, -100))
        end
        self.effect:SetActive(true)
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

function ItemSlot:SetItemImgSize(x,y)
    self.itemImgRect.sizeDelta = Vector2(x,y)
end