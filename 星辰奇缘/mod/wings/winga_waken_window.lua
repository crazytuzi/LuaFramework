-- 翅膀觉醒技能
-- ljh 20161208

WingaWakenWindow = WingaWakenWindow or BaseClass(BasePanel)

function WingaWakenWindow:__init()
    self.Mgr = WingsManager.Instance
    self.model = self.Mgr.model
    self.name = "WingaWakenWindow"
    self.canHoldPath = "prefabs/effect/20237.unity3d"
    self.holdPath = "prefabs/effect/20238.unity3d"
    self.breakPath = "prefabs/effect/20239.unity3d"
    self.resList = {
        {file = AssetConfig.wingawakenwindow, type = AssetType.Main}
        ,{file = AssetConfig.wing_textures, type = AssetType.Dep}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
        ,{file = AssetConfig.equip_strength_res, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20049), type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20161), type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20240), type = AssetType.Main}
        ,{file = self.holdPath, type = AssetType.Main}
        ,{file = self.breakPath, type = AssetType.Main}
        ,{file = self.canHoldPath, type = AssetType.Main}
    }

    self.holdTimeId = nil
    self.isOnDowm = false
    self.canUp = true

    self.type = 0
    self.enough = false
    self.needItemId = nil

    self.priceByBaseid = {}
    ----------------------------------------------------------
    self._update = function(changeValue)
        self:ChargeImgBarTween(changeValue)
    end

    self._QuickBuyReturn = function(priceByBaseid)
        self:QuickBuyReturn(priceByBaseid)
    end

    self._UpdateItem = function()
        self:UpdateItem()
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function WingaWakenWindow:__delete()
    if self.skillLoader ~= nil then
        self.skillLoader:DeleteMe()
        self.skillLoader = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    self:OnHide()
end

function WingaWakenWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wingawakenwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    -- self.transform.localPosition = Vector3(0, 0, -200)

    self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
        self.Mgr:CloseWingaWakenWindow()
    end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self.Mgr:CloseWingaWakenWindow()
    end)

    self.skillIcon = self.transform:Find("Main/SkillItem/Icon").gameObject
    self.skillLoader = SingleIconLoader.New(self.skillIcon)

    self.nameText = self.transform:Find("Main/NameText"):GetComponent(Text)
    self.levelText = self.transform:Find("Main/LevelText"):GetComponent(Text)
    self.descText = self.transform:Find("Main/DescText"):GetComponent(Text)

    self.chargeCon = self.transform:Find("Main/ChargeCon").gameObject
    self.okButton = self.transform:Find("Main/ChargeCon/OkButton"):GetComponent(CustomButton)
    self.okButton.onUp:AddListener(function() self:OnUp() end)
    self.okButtonText = self.okButton.transform:Find("Text"):GetComponent(Text)
    self.descButton = self.transform:Find("Main/DescButton"):GetComponent(Button)
    self.descButton.onClick:AddListener(function() self:ShowTips() end)

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Main/ChargeCon/Item").gameObject, self.itemSlot.gameObject)
    self.itemText = self.transform:Find("Main/ChargeCon/Item/TxtName"):GetComponent(Text)

    self.quickBuyText = self.transform:Find("Main/ChargeCon/Num"):GetComponent(Text)
    self.quickBuyText.gameObject:SetActive(false)

    self.chargeConDescText = self.transform:Find("Main/ChargeCon/DescText"):GetComponent(Text)
    self.gridCon = self.transform:Find("Main/ChargeCon/GridCon").gameObject
    self.chargeImgBarRect = self.gridCon.transform:FindChild("ImgBar"):GetComponent(RectTransform)
    self.imgReward = self.gridCon.transform:FindChild("ImgReward").gameObject
    self.imgRewardText = self.imgReward.transform:FindChild("Text"):GetComponent(Text)

    self.effectBar = self:GetEffect(self.gridCon.transform:FindChild("ImgBar"):FindChild("EffectCon"), 20161)
    self.effectBar.transform.localPosition = Vector3(0, 0, -400)
    self.effectBar.gameObject:SetActive(true)

    self.effectHold = GameObject.Instantiate(self:GetPrefab(self.holdPath))
    self.effectHold.transform:SetParent(self.itemSlot.transform)
    self.effectHold.transform.localScale = Vector3.one
    self.effectHold.transform.localPosition = Vector3(0, 0, -500)
    Utils.ChangeLayersRecursively(self.effectHold.transform, "UI")
    self.effectHold:SetActive(false)

    self.effectBreak = GameObject.Instantiate(self:GetPrefab(self.breakPath))
    self.effectBreak.transform:SetParent(self.itemSlot.transform)
    self.effectBreak.transform.localScale = Vector3.one
    self.effectBreak.transform.localPosition = Vector3(0, 0, -500)
    Utils.ChangeLayersRecursively(self.effectBreak.transform, "UI")
    self.effectBreak:SetActive(false)

    self.effectCanHold = GameObject.Instantiate(self:GetPrefab(self.canHoldPath))
    self.effectCanHold.transform:SetParent(self.okButton.transform)
    self.effectCanHold.transform.localScale = Vector3.one
    self.effectCanHold.transform.localPosition = Vector3(0, 0, -500)
    Utils.ChangeLayersRecursively(self.effectCanHold.transform, "UI")
    self.effectCanHold:SetActive(false)

    self.tipsPanel = self.transform:Find("Main/RewardPanel").gameObject
    self.tipsPanel.transform:Find("MainCon"):GetComponent(Button).onClick:AddListener(function() self:HideTips() end)
    self.tipsPanel.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideTips() end)

    self.tipsPanel_NextDescText = self.tipsPanel.transform:Find("MainCon/NextLevel/DescText"):GetComponent(Text)
    self.tipsPanel_MaxDescText = self.tipsPanel.transform:Find("MainCon/MaxLevel/DescText"):GetComponent(Text)
    -----------------------------------------
    self:OnShow()
    -- self:ClearMainAsset()
end

function WingaWakenWindow:OnShow()
    self:update()
    self:UpdateImgBarTween()
    self:HideTips()
    WingsManager.Instance.hasClickRedPoint = true
    WingsManager.Instance:CheckRedPointDic1()
    WingsManager.Instance.onUpdateRed:Fire()

    WingsManager.Instance.onUpdateAwakenSkill:Add(self._update)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._UpdateItem)
end

function WingaWakenWindow:OnHide()
    WingsManager.Instance.onUpdateAwakenSkill:Remove(self._update)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateItem)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.notify ~= nil then
        self.notify:DeleteMe()
        self.notify = nil
    end
end

function WingaWakenWindow:update()
    local break_skillData = WingsManager.Instance.break_skills[1]
    if break_skillData == nil then
        break_skillData = { skill_id = WingsManager.Instance.mainModel.wingModel:GetAwakenSkill(WingsManager.Instance.grade+1), skill_lev = -1, skill_grade = WingsManager.Instance.grade+1, skill_val = 0 }
    end
    self.showGrade = WingsManager.Instance.grade
    local skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, break_skillData.skill_lev)]
    if skillData == nil then
        skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, 1)]
    end
    local data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade, break_skillData.skill_id, break_skillData.skill_lev)]
    if data_get_action_break == nil then
        data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade+1, break_skillData.skill_id, 1)]
    end
    if data_get_action_break == nil then
        local array = DataWing.data_grade_action_break[break_skillData.skill_id]
        table.sort(array, function(a,b) return a<b end)
        local tab = BaseUtils.BinarySearch(WingsManager.Instance.grade, array)

        self.showGrade = array[tab.index]
        data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", array[tab.index], break_skillData.skill_id, break_skillData.skill_lev)]
    end

    self.break_skillData = break_skillData
    self.skillData = skillData
    self.data_get_action_break = data_get_action_break

    self.skillIcon:SetActive(true)
    self.skillLoader:SetSprite(SingleIconType.SkillIcon, skillData.icon)

    self.nameText.text = skillData.name
    if break_skillData.skill_lev == 0 then
        self.levelText.text = TI18N("<color='#ffff00'>未激活</color>")
    else
        self.levelText.text = string.format("<color='#ffff00'>Lv.%s</color>", break_skillData.skill_lev)
    end
    self.descText.text = skillData.desc

    local itembase = nil
    local itemData = ItemData.New()

    if break_skillData.skill_lev == -1 then
        self.chargeCon:SetActive(false)
        self.transform:Find("Main"):GetComponent(RectTransform).sizeDelta= Vector2(375, 245)
        self.levelText.text = TI18N("<color='#ffff00'>未激活</color>")
        self.descButton.gameObject:SetActive(false)
        return
    end

    if break_skillData.skill_lev == 0 then
        self.type = 1
        self.okButton.onDown:RemoveAllListeners()
        self.okButton.onClick:RemoveAllListeners()
        self.okButton.onDown:AddListener(function() self:OnDown() end)

        self.okButtonText.text = TI18N("长按\n觉醒")
        itembase = BackpackManager.Instance:GetItemBase(data_get_action_break.uplev_loss[1][1])
        itemData:SetBase(itembase)
        itemData.quantity = BackpackManager.Instance:GetItemCount(data_get_action_break.uplev_loss[1][1])
        itemData.need = data_get_action_break.uplev_loss[1][2]

        self.enough = itemData.quantity >= itemData.need
        self.needItemId = itembase.id

        self.chargeConDescText.gameObject:SetActive(true)
        self.gridCon:SetActive(false)
        self.effectCanHold:SetActive(true)

        self.itemText.gameObject:SetActive(true)
        self.quickBuyText.gameObject:SetActive(false)

        self.descButton.gameObject:SetActive(false)
    elseif break_skillData.skill_val < data_get_action_break.max_charge_val or data_get_action_break.max_charge_val == 0 then
        self.type = 2
        self.okButton.onDown:RemoveAllListeners()
        self.okButton.onClick:RemoveAllListeners()
        self.okButton.onClick:AddListener(function() self:OnClick() end)

        self.okButtonText.text = TI18N("充能")
        itembase = BackpackManager.Instance:GetItemBase(data_get_action_break.charge_loss[1][1])
        itemData:SetBase(itembase)
        itemData.quantity = BackpackManager.Instance:GetItemCount(data_get_action_break.charge_loss[1][1])
        itemData.need = data_get_action_break.charge_loss[1][2]

        self.enough = itemData.quantity >= itemData.need
        self.needItemId = itembase.id
        if self.enough then
            self.itemText.gameObject:SetActive(true)
            self.quickBuyText.gameObject:SetActive(false)
        else
            self.itemText.gameObject:SetActive(false)
            self.quickBuyText.gameObject:SetActive(true)
            self:GetQuickBuy(itembase.id, itemData.need - itemData.quantity)
        end

        if DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, break_skillData.skill_lev + 1)] == nil then
            self.chargeConDescText.text = TI18N("觉醒之舞已达到最高等级")
            self.chargeConDescText.gameObject:SetActive(true)
            self.gridCon:SetActive(false)

            self.chargeConDescText.transform.localPosition = Vector3(187, -100, 0)
            self.okButton.gameObject:SetActive(false)
            self.okButton.gameObject:SetActive(false)
            self.itemSlot.gameObject:SetActive(false)
            self.itemText.gameObject:SetActive(false)
            self.quickBuyText.gameObject:SetActive(false)

            self.descButton.gameObject:SetActive(false)
        else
            self.chargeConDescText.gameObject:SetActive(false)
            self.gridCon:SetActive(true)

            self.descButton.gameObject:SetActive(true)
        end
    else
        self.type = 3
        self.okButton.onDown:RemoveAllListeners()
        self.okButton.onClick:RemoveAllListeners()
        self.okButton.onDown:AddListener(function() self:OnDown() end)

        self.okButtonText.text = TI18N("长按\n进阶")
        itembase = BackpackManager.Instance:GetItemBase(data_get_action_break.uplev_loss[1][1])
        itemData:SetBase(itembase)
        itemData.quantity = BackpackManager.Instance:GetItemCount(data_get_action_break.uplev_loss[1][1])
        itemData.need = data_get_action_break.uplev_loss[1][2]

        self.enough = itemData.quantity >= itemData.need
        self.needItemId = itembase.id

        self.chargeConDescText.gameObject:SetActive(false)
        self.gridCon:SetActive(true)
        self.effectCanHold:SetActive(true)

        self.itemText.gameObject:SetActive(true)
        self.quickBuyText.gameObject:SetActive(false)

        self.descButton.gameObject:SetActive(false)

        local fenzi = break_skillData.skill_val
        local fenmu = data_get_action_break.max_charge_val
        if fenzi < fenmu then
            self:PlayChargeProgBarEffect(false)
        else
            self:PlayChargeProgBarEffect(true)
        end
    end

    -- self.itemSlot:SetAll(itemData, {nobutton = true})
    self.itemSlot:SetAll(itemData)
    self.itemText.text = itemData.name
end

-- 进度条效果
function WingaWakenWindow:ChargeImgBarTween(changeValue)
    if self.effectHold ~= nil then
        self.effectHold:SetActive(false)
        self.effectCanHold:SetActive(false)
    end
    if self.type == 3 then
        self:update()
        print("3")
        self.chargeImgBarRect.sizeDelta = Vector2(0, self.chargeImgBarRect.rect.height)
        self.okButton.enabled = true
        self:PlayBreak()
    else
        local break_skillData = WingsManager.Instance.break_skills[1]
        if break_skillData == nil then
            return
        end
        local data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade, break_skillData.skill_id, break_skillData.skill_lev)]
        if data_get_action_break == nil then
            local array = DataWing.data_grade_action_break[break_skillData.skill_id]
            table.sort(array, function(a,b) return a<b end)
            local tab = BaseUtils.BinarySearch(WingsManager.Instance.grade, array)

            self.showGrade = array[tab.index]
            data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", array[tab.index], break_skillData.skill_id, break_skillData.skill_lev)]
        end
        if data_get_action_break == nil then
            return
        end
        self.chargeConDescText.gameObject:SetActive(false)
        self.gridCon:SetActive(true)

        local fenzi = break_skillData.skill_val
        local fenmu = data_get_action_break.max_charge_val
        if fenmu == 0 then
            fenmu = 1
        end
        if changeValue > 10 then
            self.imgReward:SetActive(true)
            self.imgRewardText.text = string.format("X%s", math.floor(changeValue/10))
        end
        local barEffectFuncEnd = function()
            self:PlayChargeProgBarEffect(false)
            self.imgReward:SetActive(false)
            if fenzi >= fenmu then -- 播放充能满条特效
                -- if curPointSocketExp >= nextWakeUpCfgData.need_exp then
                    self:PlayChargeProgBarEffect(true)
                -- end
            end
            self.okButton.enabled = true
            self:update()
        end
        local endWidth = (fenzi/fenmu)*235
        if endWidth > self.chargeImgBarRect.rect.width then
            SoundManager.Instance:Play(241)
            self.tweenId = Tween.Instance:ValueChange(self.chargeImgBarRect.rect.width, endWidth, 1, barEffectFuncEnd, LeanTweenType.linear, function(v)
        print("4")
                            self.chargeImgBarRect.sizeDelta = Vector2(v, self.chargeImgBarRect.rect.height)
                        end).id
        else
            -- self.chargeImgBarRect.sizeDelta = Vector2(endWidth, self.chargeImgBarRect.rect.height)
            -- barEffectFuncEnd()
            self.tweenId = Tween.Instance:ValueChange(self.chargeImgBarRect.rect.width, endWidth, 1, barEffectFuncEnd, LeanTweenType.linear, function(v)
        print("5")
                            self.chargeImgBarRect.sizeDelta = Vector2(v, self.chargeImgBarRect.rect.height)
                        end).id
        end
        self:ShowStarEffect()
    end
end

function WingaWakenWindow:UpdateImgBarTween()
    local break_skillData = WingsManager.Instance.break_skills[1]
    if break_skillData == nil then
        return
    end
    local data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade, break_skillData.skill_id, break_skillData.skill_lev)]
    if data_get_action_break == nil then
        local array = DataWing.data_grade_action_break[break_skillData.skill_id]
        table.sort(array, function(a,b) return a<b end)
        local tab = BaseUtils.BinarySearch(WingsManager.Instance.grade, array)

        self.showGrade = array[tab.index]
        data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", array[tab.index], break_skillData.skill_id, break_skillData.skill_lev)]
    end
    if data_get_action_break == nil then
        return
    end

    if DataWing.data_get_action_break[string.format("%s_%s_%s", data_get_action_break.grade, break_skillData.skill_id, break_skillData.skill_lev+1)] == nil then
        self.chargeImgBarRect.sizeDelta = Vector2(235, self.chargeImgBarRect.rect.height)
    else
        local fenzi = break_skillData.skill_val
        local fenmu = data_get_action_break.max_charge_val

        -- print(string.format("%s / %s", fenzi, fenmu))
        print("1")
        self.chargeImgBarRect.sizeDelta = Vector2((fenzi/fenmu)*235, self.chargeImgBarRect.rect.height)
    end
end

function WingaWakenWindow:OnDown()
    self.isOnDowm = true
    if not self.enough then
        self.isOnDowm = false
        local baseItemData = BackpackManager.Instance:GetItemBase(self.needItemId)
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("{assets_2, %s}%s不足，无法进阶"), baseItemData.id, baseItemData.name))
        self.itemSlot:SureClick()
        return
    end

    self:StayTimeOut()

    if self.effectHold ~= nil then
        self.effectHold:SetActive(false)
        self.effectHold:SetActive(true)
    end
    LuaTimer.Add(100,function()
        SoundManager.Instance:Play(232)
    end)
    self:BeginTime()
end

function WingaWakenWindow:OnUp()
    LuaTimer.Add(50, function() self.isOnDowm = false end)
    if self.effectHold ~= nil then
        self.effectHold:SetActive(false)
    end
    SoundManager.Instance:StopId(232)
    self:StopTime()
end

function WingaWakenWindow:OnClick()
    if not self.isOnDowm then
        if self.enough or RoleManager.Instance.RoleData.gold_bind >= self:GetNeedMoney() then
            WingsManager.Instance:Send11611(self.showGrade, self.break_skillData.skill_id)
            self.okButton.enabled = false
        else
            self:ShowNotice()
        end
    else
        self.isOnDowm = false
    end
end

function WingaWakenWindow:BeginTime()
    self:StopTime()
    self.holdTimeId = LuaTimer.Add(1800, function() self:Beng() end)
end

function WingaWakenWindow:StopTime()
    if self.holdTimeId ~= nil then
        LuaTimer.Delete(self.holdTimeId)
        self.holdTimeId = nil
    end
end

function WingaWakenWindow:Beng()
    -- 特效结束，发送升级协议
    self:StopTime()
    WingsManager.Instance:Send11611(self.showGrade, self.break_skillData.skill_id)
    self:PlayChargeProgBarEffect(false)
end

function WingaWakenWindow:PlayBreak()
    self.canUp = false
    self.effectBreak:SetActive(false)
    self.effectBreak:SetActive(true)
    SoundManager.Instance:Play(232)
    self.effectStayId = LuaTimer.Add(500, function() self:StayTimeOut() end)
end

function WingaWakenWindow:StayTimeOut()
    self.canUp = true
    if self.effectStayId ~= nil then
        LuaTimer.Delete(self.effectStayId)
        self.effectStayId = nil
    end

    if self.effectBreak ~= nil then
        self.effectBreak:SetActive(false)
    end
end

--设置充能进度条满条特效显示状态
function WingaWakenWindow:PlayChargeProgBarEffect(state)
    if self.pointEffect20240 == nil then
        self.pointEffect20240 = self:GetEffect(self.gridCon.transform, 20240)
        self.pointEffect20240.transform:Find("20219liuguang/guangtiao").gameObject:SetActive(false)
    end
    self.pointEffect20240.transform.localPosition = Vector3(-29, -100, -400)
    self.pointEffect20240:SetActive(state)

    self.effectBar:SetActive(not state)
end

--传入特效id获取一个特效
function WingaWakenWindow:GetEffect(trans, effectId)
    local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, effectId)))
    self:SetEffectTrans(trans, effect)
    effect:SetActive(false)
    return effect
end

--设置特效所在的trans
function WingaWakenWindow:SetEffectTrans(trans, effect)
    effect.transform:SetParent(trans)
    effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, -400)
end

function WingaWakenWindow:ShowStarEffect()
    if self.starEffect ~= nil then self.starEffect:DeleteMe() self.starEffect = nil end

    self.starEffect = BibleRewardPanel.ShowEffect(20049, self.itemSlot.transform, Vector3(0.5, 0.5, 0.5), Vector3(-0.5, -18.5, 1))
end

function WingaWakenWindow:GetQuickBuy(id, num)
    self.quickBuyId = id
    self.quickBuyNum = num
    if self.priceByBaseid[id] == nil then
        MarketManager.Instance:send12416({ base_ids = { {base_id = id} } }, self._QuickBuyReturn)
    else
        self:ShowQuickBuy()
    end
end

function WingaWakenWindow:QuickBuyReturn(priceByBaseid)
    self.priceByBaseid = priceByBaseid
    self:ShowQuickBuy()
end

function WingaWakenWindow:ShowQuickBuy()
    local price = self.priceByBaseid[self.quickBuyId].price * self.quickBuyNum
    if price > RoleManager.Instance.RoleData.gold_bind then
        self.quickBuyText.text = string.format("<color='ff0000'>%s</color>", price)
    else
        self.quickBuyText.text = tostring(price)
    end
end

function WingaWakenWindow:GetNeedMoney()
    if self.priceByBaseid[self.quickBuyId] ~= nil then
        return self.priceByBaseid[self.quickBuyId].price * self.quickBuyNum
    else
        return 0
    end
end

function WingaWakenWindow:ShowNotice()
    local world_lev = RoleManager.Instance.world_lev
    local glodbind_to_gold = DataMarketGold.data_market_gold_ratio[world_lev].rate
    self.idToNumPrice = {
        [self.quickBuyId] = {
            isDouble = true,
            asset = 90003,
            num = self.quickBuyNum,
            money = math.ceil(self.priceByBaseid[self.quickBuyId].price * self.quickBuyNum / glodbind_to_gold),
            assets = 90003,
            assets_num = self.priceByBaseid[self.quickBuyId].price * self.quickBuyNum,
            source = MarketEumn.SourceType.Shop,
        }
    }
    self.baseidToNeed = {
        [self.quickBuyId] = {
            need = self.quickBuyNum,
        }
    }
    if self.notify == nil  then
        self.notify = BuyNotify.New(self.idToNumPrice, self.baseidToNeed, function() WingsManager.Instance:Send11611(self.showGrade, self.break_skillData.skill_id) end, TI18N("购买"))
    else
        self.notify.content = TI18N("购买")
        if self.notify.loading ~= true then
            self.notify:ResetData(self.idToNumPrice, self.baseidToNeed)
        end
    end
    self.notify:Show()
end

function WingaWakenWindow:UpdateItem()
    local break_skillData = WingsManager.Instance.break_skills[1]
    if break_skillData == nil then
        break_skillData = { skill_id = WingsManager.Instance.mainModel.wingModel:GetAwakenSkill(WingsManager.Instance.grade+1) }
    end
    local skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, break_skillData.skill_lev)]
    if skillData == nil then
        skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, 1)]
    end
    local data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade, break_skillData.skill_id, break_skillData.skill_lev)]
    if data_get_action_break == nil then
        data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade+1, break_skillData.skill_id, 1)]
    end
    if data_get_action_break == nil then
        local array = DataWing.data_grade_action_break[break_skillData.skill_id]
        table.sort(array, function(a,b) return a<b end)
        local tab = BaseUtils.BinarySearch(WingsManager.Instance.grade, array)

        -- self.showGrade = array[tab.index]
        data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", array[tab.index], break_skillData.skill_id, break_skillData.skill_lev)]
    end

    local itembase = nil
    local itemData = ItemData.New()

    if break_skillData.skill_lev == 0 then
        self.type = 1
        self.okButton.onDown:RemoveAllListeners()
        self.okButton.onClick:RemoveAllListeners()
        self.okButton.onDown:AddListener(function() self:OnDown() end)

        self.okButtonText.text = TI18N("长按\n觉醒")
        itembase = BackpackManager.Instance:GetItemBase(data_get_action_break.uplev_loss[1][1])
        itemData:SetBase(itembase)
        itemData.quantity = BackpackManager.Instance:GetItemCount(data_get_action_break.uplev_loss[1][1])
        itemData.need = data_get_action_break.uplev_loss[1][2]

        self.enough = itemData.quantity >= itemData.need
        self.needItemId = itembase.id
    elseif break_skillData.skill_val < data_get_action_break.max_charge_val then
        self.type = 2
        self.okButton.onDown:RemoveAllListeners()
        self.okButton.onClick:RemoveAllListeners()
        self.okButton.onClick:AddListener(function() self:OnClick() end)

        self.okButtonText.text = TI18N("充能")
        itembase = BackpackManager.Instance:GetItemBase(data_get_action_break.charge_loss[1][1])
        itemData:SetBase(itembase)
        itemData.quantity = BackpackManager.Instance:GetItemCount(data_get_action_break.charge_loss[1][1])
        itemData.need = data_get_action_break.charge_loss[1][2]

        self.enough = itemData.quantity >= itemData.need
        self.needItemId = itembase.id
        if self.enough then
            self.itemText.gameObject:SetActive(true)
            self.quickBuyText.gameObject:SetActive(false)
        else
            self.itemText.gameObject:SetActive(false)
            self.quickBuyText.gameObject:SetActive(true)
            self:GetQuickBuy(itembase.id, itemData.need - itemData.quantity)
        end
    else
        self.type = 3
        self.okButton.onDown:RemoveAllListeners()
        self.okButton.onClick:RemoveAllListeners()
        self.okButton.onDown:AddListener(function() self:OnDown() end)

        self.okButtonText.text = TI18N("长按\n进阶")
        itembase = BackpackManager.Instance:GetItemBase(data_get_action_break.uplev_loss[1][1])
        itemData:SetBase(itembase)
        itemData.quantity = BackpackManager.Instance:GetItemCount(data_get_action_break.uplev_loss[1][1])
        itemData.need = data_get_action_break.uplev_loss[1][2]

        self.enough = itemData.quantity >= itemData.need
        self.needItemId = itembase.id
    end

    self.itemSlot:SetAll(itemData)
    self.itemText.text = itemData.name
end

function WingaWakenWindow:ShowTips()
    self.tipsPanel:SetActive(true)

    local break_skillData = WingsManager.Instance.break_skills[1]
    if break_skillData == nil then
        break_skillData = { skill_id = WingsManager.Instance.mainModel.wingModel:GetAwakenSkill(WingsManager.Instance.grade+1) }
    end
    local skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, break_skillData.skill_lev+1)]
    if skillData == nil then
        skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, 1)]
    end

    self.tipsPanel_NextDescText.text = skillData.desc

    local lev = 1
    while DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, lev)] ~= nil do
        skillData = DataSkill.data_wing_skill[string.format("%s_%s", break_skillData.skill_id, lev)]
        lev = lev + 1
    end
    self.tipsPanel_MaxDescText.text = skillData.desc
end

function WingaWakenWindow:HideTips()
    self.tipsPanel:SetActive(false)
end