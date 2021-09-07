WingsHandbookInfo = WingsHandbookInfo or BaseClass(BasePanel)

function WingsHandbookInfo:__init(model, gameObject)
    self.name = "WingsHandbookInfo"
    self.originObject = gameObject
    self.model = model

    self.resList = {
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.playkillbgcycle, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.wing_textures, type = AssetType.Dep},
    }

    self.useListener = function() self:ReloadUse() self:ReloadExchange() self:ReloadAttr() self:ReloadWing() end
    self.itemListener = function() self:ReloadUse() self:ReloadExchange() end
    self.getrewardListener = function(group_id) self:ShowReward(group_id) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingsHandbookInfo:__delete()
    self.OnHideEvent:Fire()
    self.transform:Find("Bottom"):GetComponent(Image).sprite = nil
    self.transform:Find("WingBg"):GetComponent(Image).sprite = nil
    if self.useImage ~= nil then
        self.useImage.sprite = nil
    end
    if self.activeImage ~= nil then
        self.activeImage.sprite = nil
    end
    if self.attrList ~= nil then
        for _,v in pairs(self.attrList) do
            v.iconImage.sprite = nil
        end
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.exchangeExt ~= nil then
        self.exchangeExt:DeleteMe()
        self.exchangeExt = nil
    end
    if self.rewardEft ~= nil then
        self.rewardEft:DeleteMe()
        self.rewardEft = nil
    end
    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.possibleReward = nil
    end
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
    if self.faceShow ~= nil then
        self.faceShow:DeleteMe()
        self.faceShow = nil
    end
    self.model = nil
    self.gameObject = nil
end

function WingsHandbookInfo:InitPanel()
    self.gameObject = self.originObject
    self.transform = self.gameObject.transform
    self.gameObject.name = self.name

    local t = self.transform

    t:Find("Bottom"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgcycle, "PlayKillBgCycle")
    t:Find("WingBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    t:Find("Bottom"):GetComponent(Image).color = Color(1,1,1,0.45)
    t:Find("WingBg"):GetComponent(Image).color = Color(1,1,1)

    self.nameText = t:Find("Name/Text"):GetComponent(Text)
    self.previewContainer = t:Find("Preview")
    self.useText = t:Find("Use/Text"):GetComponent(Text)
    self.useBtn = t:Find("Use"):GetComponent(Button)
    self.useImage = t:Find("Use"):GetComponent(Image)
    self.useNotify = t:Find("Use/Notify").gameObject
    self.useText = t:Find("Use/Text"):GetComponent(Text)
    self.exchangeBtn = t:Find("Exchange"):GetComponent(Button)
    self.exchangeNotify = t:Find("Exchange/Notify").gameObject
    self.exchangeExt = MsgItemExt.New(t:Find("Exchange/Text"):GetComponent(Text), 110, 18, 21)
    self.exchangeDescText = t:Find("ExchangeText"):GetComponent(Text)
    self.using = t:Find("Using").gameObject
    self.slider = t:Find("Slider"):GetComponent(Slider)
    self.noticeBtn = t:Find("Notice"):GetComponent(Button)
    self.descText = t:Find("Text"):GetComponent(Text)
    self.mark = t:Find("Mark").gameObject
    self.illusionText = t:Find("Illusion"):GetComponent(Text)
    self.attrDescText = t:Find("Attr/Desc"):GetComponent(Text)
    self.attrContainer = t:Find("Attr/Container")
    self.attrPos = self.attrContainer:GetComponent(RectTransform)
    self.attrList = {}
    for i=1,4 do
        local tab = {}
        tab.transform = self.attrContainer:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.iconImage = tab.transform:Find("Icon"):GetComponent(Image)
        tab.nameText = tab.transform:Find("Attrname"):GetComponent(Text)
        tab.nameText.alignment = 3
        tab.nameText.transform.anchoredPosition = Vector2(-10, 0)
        tab.nameText.horizontalOverflow = 1
        tab.valueText = tab.transform:Find("Val"):GetComponent(Text)
        tab.valueText.text = ""

        self.attrList[i] = tab
    end

    self.activeImage = t:Find("Active"):GetComponent(Image)
    self.activePos = self.activeImage.gameObject:GetComponent(RectTransform)

    self.rewardBox = t:Find("RewardBox"):GetComponent(Button)
    self.boxImg = t:Find("RewardBox"):GetComponent(Image)
    self.rewardPos = self.rewardBox.gameObject:GetComponent(RectTransform)
    self.rewardPoint = t:Find("RewardBox/RedPoint").gameObject


    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.useBtn.onClick:AddListener(function() self:OnUse() end)
    self.exchangeBtn.onClick:AddListener(function() self:OnExchange() end)
end

function WingsHandbookInfo:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingsHandbookInfo:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.useListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
    WingsManager.Instance.onGetReward:AddListener(self.getrewardListener)

    self.wingId = self.openArgs[1]
    self.index = self.openArgs[2]

    if DataWing.data_base[self.wingId] == nil then
        self.wingId = nil
    end

    if self.wingId ~= nil then
        self:ReloadUse()
        self:ReloadExchange()
        self:ReloadWing()
        self:ReloadAttr()
    else
        self:Default()
    end
end

function WingsHandbookInfo:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.useListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
    WingsManager.Instance.onGetReward:RemoveListener(self.getrewardListener)
end

function WingsHandbookInfo:OnHide()
    self:RemoveListeners()

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.timerid ~= nil then
        LuaTimer.Delete(self.timerid)
        self.timerid = nil
    end
    if self.rewardEft ~= nil then
        self.rewardEft:SetActive(false)
    end
end

function WingsHandbookInfo:ReloadUse()
    if WingsManager.Instance.wing_id == self.wingId then
        self.using:SetActive(true)
        self.useBtn.gameObject:SetActive(false)
    else
        local baseData = DataWing.data_base[self.wingId]
        self.useBtn.transform.anchoredPosition = Vector2(0, -40)
        if baseData == nil then
            return
        end
        if baseData.grade >= 2000 then
            -- 幻化翅膀
            if WingsManager.Instance.illusionTab[self.wingId] ~= nil and (BaseUtils.BASE_TIME <= WingsManager.Instance.illusionTab[self.wingId].timeout or WingsManager.Instance.illusionTab[self.wingId].timeout == 0) then
                self.useText.text = TI18N("使 用")
                self.useImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.useText.color = ColorHelper.DefaultButton1
            else
                self.useText.text = TI18N("获取途径")
                self.useImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.useText.color = ColorHelper.DefaultButton3
            end

            self.useNotify:SetActive(false)
        else
            if WingsManager.Instance.hasGetIds[self.wingId] ~= nil then
                self.useText.text = TI18N("使 用")
                self.useImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.useText.color = ColorHelper.DefaultButton1
                self.useNotify:SetActive(false)
            else
                self.useText.text = TI18N("抽 取")
                self.useBtn.transform.anchoredPosition = Vector2(-65, -40)
                self.useImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.useText.color = ColorHelper.DefaultButton1
                self.useNotify:SetActive(BackpackManager.Instance:GetItemCount(DataWing.data_group_info[baseData.group_id].loss_item[1][1]) >= DataWing.data_group_info[baseData.group_id].loss_item[1][2])
            end
        end
        self.using:SetActive(false)
        self.useBtn.gameObject:SetActive(true)
    end
end

function WingsHandbookInfo:ReloadWing()
    local cfgData = DataWing.data_base[self.wingId]
    self.nameText.text = cfgData.name
    if WingsManager.Instance.hasGetIds[self.wingId] == nil and WingsManager.Instance.illusionTab[self.wingId] == nil then
        self.mark:SetActive(true)
        self.previewContainer.gameObject:SetActive(false)
        if self.previewComp ~= nil then
            self.previewComp:Hide()
        end
    else
        local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = self.wingId}}}

        self.previewCallback = self.previewCallback or function(composite) self:SetRawImage(composite) end
        self.setting = self.setting or {
            name = "wing"
            ,orthographicSize = 0.4
            ,width = 320
            ,height = 220
            ,offsetY = -0.1
            ,noDrag = true
            -- ,noMaterial = true
        }
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
            self.previewComp:Show()
        end
        self.mark:SetActive(false)
    end
end

function WingsHandbookInfo:SetRawImage(composite)
    composite.rawImage.transform:SetParent(self.previewContainer)
    composite.rawImage.transform.localScale = Vector3.one
    composite.rawImage.transform.localPosition = Vector3.zero
    self.previewContainer.gameObject:SetActive(true)
end

function WingsHandbookInfo:ReloadAttr()
    self.lastGroupId = DataWing.data_base[self.wingId].group_id
    self.attrContainer.transform.anchoredPosition = Vector2(0, -15)

    local attrList = nil
    if self.lastGroupId == 100 then
        if DataWing.data_attribute[BaseUtils.Key(RoleManager.Instance.RoleData.classes, DataWing.data_base[self.wingId].grade, DataWing.data_base[self.wingId].lev)] == nil then
            Log.Error(BaseUtils.Key(RoleManager.Instance.RoleData.classes, DataWing.data_base[self.wingId].grade, DataWing.data_base[self.wingId].lev))
        end
        attrList = DataWing.data_attribute[BaseUtils.Key(RoleManager.Instance.RoleData.classes, DataWing.data_base[self.wingId].grade, DataWing.data_base[self.wingId].lev)].attr
        self.descText.text = ""
        self.slider.gameObject:SetActive(false)
        self.noticeBtn.gameObject:SetActive(false)
        self:ShowCountdown(true)
        self.attrDescText.text = string.format(TI18N("获得<color='#ffff00'>%s</color>后激活以下属性"), DataWing.data_base[self.wingId].name)
    else
        self.illusionText.gameObject:SetActive(false)
        self.slider.gameObject:SetActive(true)
        self.noticeBtn.gameObject:SetActive(true)
        self.descText.text = string.format(TI18N("%s星收集度"), self.lastGroupId)
        if WingsManager.Instance.wing_groups[self.lastGroupId] ~= nil and #DataWing.data_group_info[self.lastGroupId].wing_ids > 0 then
            self.slider.value = #WingsManager.Instance.wing_groups[self.lastGroupId].wing_ids / #DataWing.data_group_info[self.lastGroupId].wing_ids
        else
            self.slider.value = 0
        end
        self:ShowCountdown(false)
        attrList = DataWing.data_group_attr[BaseUtils.Key(self.lastGroupId, RoleManager.Instance.RoleData.classes)].attr
        self.attrDescText.text = string.format(TI18N("集齐4个<color='#ffff00'>%s翅膀</color>可获得"), DataWing.data_group_info_show[self.lastGroupId].short_title)
    end

    self.attrContainer.gameObject:SetActive(true)

    local str = nil
    for i,attr in ipairs(attrList) do
        self.attrList[i].iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format(
            "AttrIcon%s", attr.attr_name))
        self.attrList[i].iconImage.gameObject:SetActive(true)
        if KvData.prop_percent[attr.attr_name] == nil then
            str = "+" .. attr.val
        else
            str = "+" .. (attr.val / 10) .. "%"
        end
        self.attrList[i].nameText.text = string.format("%s %s", KvData.attr_name[attr.attr_name], string.format(ColorHelper.DefaultButton1Str, str))
        self.attrList[i].gameObject:SetActive(true)
    end
    for i=#attrList+1,#self.attrList do
        self.attrList[i].gameObject:SetActive(false)
    end

    self.activeImage.gameObject:SetActive(true)


    if self.lastGroupId == 100 then
        self.rewardBox.gameObject:SetActive(false)
        self.attrPos.anchoredPosition = Vector2(0, -15)
        self.activePos.anchoredPosition = Vector2(80, -180)
        self.activePos.localRotation = Quaternion.Euler(0, 0, 7)
        if self.rewardEft ~= nil then
            self.rewardEft:SetActive(false)
        end
        if (WingsManager.Instance.illusionTab[self.wingId] ~= nil and (WingsManager.Instance.illusionTab[self.wingId].timeout >= BaseUtils.BASE_TIME or WingsManager.Instance.illusionTab[self.wingId].timeout == 0)) then
            -- or (WingsManager.Instance.wing_groups[self.lastGroupId] ~= nil and #WingsManager.Instance.wing_groups[self.lastGroupId].wing_ids == #DataWing.data_group_info[self.lastGroupId].wing_ids) then
            self.activeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "ActivedI18N")
        else
            self.activeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "DisactiveI18N")
        end
    else
        self.rewardBox.gameObject:SetActive(true)
        self.attrPos.anchoredPosition = Vector2(-45, -15)
        self.activePos.anchoredPosition = Vector2(122, -205)
        self.activePos.localRotation = Quaternion.Euler(0, 0, 25)
        -- self.rewardPos.anchoredPosition = Vector2(68.2, -180)
        if WingsManager.Instance.wing_groups[self.lastGroupId] == nil or WingsManager.Instance.wing_groups[self.lastGroupId].fullCollected == false then
            self.activeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "dontget")
            self.boxImg.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "closeBox")
            self.rewardPoint:SetActive(false)
            if self.rewardEft ~= nil then
                self.rewardEft:SetActive(false)
            end
            self.rewardBox.onClick:RemoveAllListeners()
            self.rewardBox.onClick:AddListener(function ()
                self:RewardPreview()
            end)
        elseif WingsManager.Instance.wing_groups[self.lastGroupId].fullCollected == true then
            if WingsManager.Instance.wing_groups[self.lastGroupId].rewarded == 0 then
                self.rewardPoint:SetActive(true)
                if self.rewardEft == nil then
                    self.rewardEft = BibleRewardPanel.ShowEffect(20053,self.rewardBox.transform, Vector3(0.9, 0.7, 1),Vector3(-30, -20, -400))
                end
                self.rewardEft:SetActive(true)
                self.activeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "ActivedI18N")
                self.boxImg.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "closeBox")
                self.rewardBox.onClick:RemoveAllListeners()
                self.rewardBox.onClick:AddListener(function ()
                    WingsManager.Instance:Send11618(self.lastGroupId)
                end)
            elseif WingsManager.Instance.wing_groups[self.lastGroupId].rewarded == 1 then
                self.rewardPoint:SetActive(false)
                self.activeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "get")
                self.boxImg.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_textures, "openBox")
                if self.rewardEft ~= nil then
                    self.rewardEft:SetActive(false)
                end
                self.rewardBox.onClick:RemoveAllListeners()
                self.rewardBox.onClick:AddListener(function ()
                    NoticeManager.Instance:FloatTipsByString("您已领取奖励")
                end)
            end
        end
    end

    self.attrContainer.sizeDelta = Vector2(200, #attrList * 25)
end

function WingsHandbookInfo:OnNotice()
    local baseData = DataWing.data_base[self.wingId]
    if baseData.grade < 2000 then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {string.format(TI18N("<color='#ffff00'>集齐</color>%s，可获得以下<color='#ffff00'>属性加成</color>"), DataWing.data_group_info_show[baseData.group_id].long_title)}})
    else
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {string.format(TI18N("获得<color='#ffff00'>%s</color>后激活以下属性"), baseData.name)}})
    end
end

function WingsHandbookInfo:OnUse()
    if WingsManager.Instance.wing_id == self.wingId then
        NoticeManager.Instance:FloatTipsByString(TI18N("您正在使用此翅膀"))
    else
        local baseData = DataWing.data_base[self.wingId]
        if baseData.grade >= 2000 then
            -- 幻化翅膀
            if WingsManager.Instance.illusionTab[self.wingId] ~= nil and ((BaseUtils.BASE_TIME <= WingsManager.Instance.illusionTab[self.wingId].timeout or WingsManager.Instance.illusionTab[self.wingId].timeout == 0)) then
                WingsManager.Instance:Send11613(self.wingId)
            else
                TipsManager.Instance:ShowItem({gameObject = self.useBtn.gameObject, itemData = DataItem.data_get[DataWing.data_base[self.wingId].item_id]})
            end
        else
            if WingsManager.Instance.hasGetIds[self.wingId] == nil and WingsManager.Instance.illusionTab[self.wingId] == nil then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wings_turnplant, {group_id = baseData.group_id})
            else
                WingsManager.Instance:Send11613(self.wingId)
            end
        end
    end
end

function WingsHandbookInfo:ShowCountdown(bool)
    if self.timerid ~= nil then
        LuaTimer.Delete(self.timerid)
    end


    if bool then
        local d = nil
        local h = nil
        local m = nil
        local s = nil
        self.illusionText.gameObject:SetActive(true)
        self.timerid = LuaTimer.Add(0, 100, function()
            if WingsManager.Instance.illusionTab[self.wingId] ~= nil and BaseUtils.BASE_TIME < WingsManager.Instance.illusionTab[self.wingId].timeout then

                d,h,m,s = BaseUtils.time_gap_to_timer(WingsManager.Instance.illusionTab[self.wingId].timeout - BaseUtils.BASE_TIME)
                if d > 10 then
                    self.illusionText.text = string.format(TI18N("幻化剩余：%s天"), d)
                elseif d > 0 then
                    self.illusionText.text = string.format(TI18N("幻化剩余：%s天%s小时"), d, h)
                elseif h > 0 then
                    self.illusionText.text = string.format(TI18N("幻化剩余：%s小时%s分钟"), h, m)
                elseif m > 0 then
                    self.illusionText.text = string.format(TI18N("幻化剩余：%s分钟%s秒"), m, s)
                else
                    self.illusionText.text = string.format(TI18N("幻化剩余：%s秒"), s)
                end
            else
                self.illusionText.text = ""
            end
        end)
    else
        self.timerid = nil
        self.illusionText.gameObject:SetActive(false)
    end
end

function WingsHandbookInfo:Default()
    self.slider.gameObject:SetActive(true)
    self.slider.value = 0
    self.descText.text = TI18N("收集度")
    self.attrContainer.gameObject:SetActive(false)
    self.attrContainer.anchoredPosition = Vector2.zero
    self.attrDescText.text = ""
    self.activeImage.gameObject:SetActive(false)
    self.illusionText.text = ""
    self.useBtn.gameObject:SetActive(false)
    self.exchangeBtn.gameObject:SetActive(false)
    self.using.gameObject:SetActive(false)
    self.nameText.text = "-------"
    self.exchangeDescText.text = ""

    self.previewContainer.gameObject:SetActive(false)
    self.mark.gameObject:SetActive(true)
end

function WingsHandbookInfo:ReloadExchange()
    if WingsManager.Instance.wing_id == self.wingId then
        self.exchangeBtn.gameObject:SetActive(false)
        self.exchangeDescText.gameObject:SetActive(false)
    else
        local baseData = DataWing.data_base[self.wingId]
        if baseData ~= nil and baseData.grade >= 2000 then
            -- 幻化翅膀
            self.exchangeBtn.gameObject:SetActive(false)
            self.exchangeDescText.gameObject:SetActive(false)
        else
            if WingsManager.Instance.hasGetIds[self.wingId] ~= nil then
                self.exchangeBtn.gameObject:SetActive(false)
                self.exchangeDescText.gameObject:SetActive(false)
            else
                self.exchangeBtn.gameObject:SetActive(true)
                self.exchangeExt:SetData(string.format(TI18N("%s{assets_2, %s}兑换"), baseData.loss_item[1][2], baseData.loss_item[1][1]))
                local size = self.exchangeExt.contentTrans.sizeDelta
                self.exchangeExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
                self.exchangeNotify:SetActive(BackpackManager.Instance:GetItemCount(baseData.loss_item[1][1]) >= baseData.loss_item[1][2])
                self.exchangeDescText.gameObject:SetActive(true)
                self.exchangeDescText.text = string.format(TI18N("当前拥有:<color='#00ff00'>%s</color>"), BackpackManager.Instance:GetItemCount(baseData.loss_item[1][1]))
            end
        end
    end
end

function WingsHandbookInfo:OnExchange()
    local baseData = DataWing.data_base[self.wingId]
    local item_id = baseData.loss_item[1][1]

    if BackpackManager.Instance:GetItemCount(item_id) < baseData.loss_item[1][2] then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("{item_2, %s, %s, %s}物品不足"), item_id, 1, 0))
        TipsManager.Instance:ShowItem({gameObject = self.exchangeBtn.gameObject, itemData = DataItem.data_get[item_id]})
    else
        WingsManager.Instance.lastIndex = 2
        WingsManager.Instance.currentTab = baseData.group_id + 1
        WingsManager.Instance.wingIndex = self.index
        WingsManager.Instance:Send11616(baseData.group_id, baseData.wing_id)
    end
end


function WingsHandbookInfo:RewardPreview()
    local key = self.lastGroupId.."_"..RoleManager.Instance.RoleData.classes
    local data = DataWing.group_attrData[key]
    local itemShow = {}
    if #data.base_reward ~= 0 then
        for k,v in pairs(data.base_reward) do
            local temp = {}
            temp.item_id = v[1]
            temp.num = v[2]
            table.insert(itemShow,temp)
        end
    elseif #data.express_reward ~= 0 then
        for k,v in pairs(data.express_reward) do
            local temp = {}
            temp.item_id = v[1]
            temp.isface = true
            table.insert(itemShow,temp)
        end
    end
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end
    self.possibleReward:Show({itemShow,4,{100,100,200,120}, string.format("收集全部%s星翅膀后可获得：", self.lastGroupId)})
end


function WingsHandbookInfo:ShowReward(group_id)
    local key = group_id.."_"..RoleManager.Instance.RoleData.classes
    local data = DataWing.group_attrData[key]
    local myData = {}
    if #data.base_reward ~= 0 then
        myData.item_list = {}
        for k,v in pairs(data.base_reward) do
            local temp = {}
            temp.type = 1
            temp.number = v[2]
            temp.item_id = v[1]
            table.insert(myData.item_list,temp)
        end
    elseif #data.express_reward ~= 0 then
        myData.item_list = {}
        for k,v in pairs(data.express_reward) do
            local temp = {}
            temp.type = 2
            temp.number = v[2]
            temp.item_id = v[1]
            table.insert(myData.item_list,temp)
        end
    end
    myData.descExtra = TI18N("<color='#ffff00'>翅膀收藏</color>奖励")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.itemsavegetwindow,myData)
end
