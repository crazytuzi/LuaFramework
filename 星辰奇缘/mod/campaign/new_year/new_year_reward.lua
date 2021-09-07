NewYearReward = NewYearReward or BaseClass(BasePanel)

function NewYearReward:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "NewYearReward"

    self.resList = {
        {file = AssetConfig.new_year_reward, type = AssetType.Main},
        {file = AssetConfig.new_year_reward_bg_new, type = AssetType.Main},
        --{file = AssetConfig.new_year_recharge_bg, type = AssetType.Main},

        -- {file = AssetConfig.fashion_big_icon2, type = AssetType.Dep},
    }

    table.insert(self.resList,{file = AssetConfig.newyear_textures, type = AssetType.Dep})

    self.reloadListener = function()
        -- self.lanternList[self.currentIndex or 1]:OnClick()
        self:OnOpen()

        if self.reward ~= nil then
            OpenServerManager.Instance:OpenRewardPanel({{id = self.reward[1], num = self.reward[2]}, TI18N("确定"), 3})
        end
    end
    self.rechargeString = "%s{assets_2,90002}"
    self.itemList = {}
    self.lanternList = {}
    self.setting = {
            notAutoSelect = true,
            noCheckRepeat = true,
            openLevel = {},
            perWidth = 110,
            perHeight = 116,
            isVertical = false,
            spacing = 0,
        }

    self.isTurnPage = false

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function NewYearReward:__delete()
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.lanternLayout ~= nil then
        self.lanternLayout:DeleteMe()
        self.lanternLayout = nil
    end
    if self.lanternTabGroup ~= nil then
        self.lanternTabGroup:DeleteMe()
        self.lanternTabGroup = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end
    if self.lanternList ~= nil then
        for _,v in pairs(self.lanternList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.lanternList = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                if v.effect ~= nil then
                    v.effect:DeleteMe()
                end
                v.data:DeleteMe()
                v.slot:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.sliderEffect ~= nil then
        self.sliderEffect:DeleteMe()
        self.sliderEffect = nil
    end
    if self.specilLoader ~= nil then
        self.specilLoader:DeleteMe()
        self.specilLoader = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.markEffect ~= nil then
        self.markEffect:DeleteMe()
        self.markEffect = nil
    end
    self:AssetClearAll()
end

function NewYearReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_reward))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    --t:Find("Desc"):GetComponent(Text).text = TI18N("宝箱宝物，参加活动免费送")
    self.descExt = MsgItemExt.New(t:Find("Desc"):GetComponent(Text), 180, 18, 20)

    self.TimeText = t:Find("Time/Text"):GetComponent(Text)

    -- 灯笼展示
    self.lanternContainer = t:Find("LanternArea/Scroll/Container")
    self.lanternLayout = LuaBoxLayout.New(self.lanternContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.lanternCloner = t:Find("LanternArea/Scroll/Cloner").gameObject
    self.tabbedPanel = TabbedPanel.New(self.lanternLayout.panel.parent.gameObject, 0, 110, 0.5)
    self.leftNormal = t:Find("LanternArea/Left/Normal").gameObject
    self.leftSelect = t:Find("LanternArea/Left/Select").gameObject
    self.rightNormal = t:Find("LanternArea/Right/Normal").gameObject
    self.rightSelect = t:Find("LanternArea/Right/Select").gameObject
    self.leftBtn = t:Find("LanternArea/Left"):GetComponent(Button)
    self.rightBtn = t:Find("LanternArea/Right"):GetComponent(Button)
    self.tabbedPanel.MoveEndEvent:AddListener(function(index) self:OnMoveEnd(index) end)
    self.leftBtn.onClick:AddListener(function() self:GoNextPage(2) end)
    self.rightBtn.onClick:AddListener(function() self:GoNextPage(1) end)
    self.leftBtn.transform.gameObject:SetActive(true)
    self.rightBtn.transform.gameObject:SetActive(true)
    self.tabbedPanel.panel:GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChange()  end)

    -- 奖励展示
    self.rewardAreaScroll = t:Find("RewardArea/Scroll"):GetComponent(ScrollRect)
    self.rewardAreaScroll.onValueChanged:AddListener(function(val)
             self:ScrollValueChange(val)
    end)


    self.layout = LuaBoxLayout.New(t:Find("RewardArea/Scroll/Container"), {axis = BoxLayoutAxis.X, border = 5, cspacing = 5})
    self.cloner = t:Find("RewardArea/Scroll/Cloner").gameObject

    self.slider = t:Find("RechargeArea/Slider"):GetComponent(Slider)
    self.sliderText = t:Find("RechargeArea/Slider/Text"):GetComponent(Text)
    self.rechargeText = t:Find("RechargeArea/Money/Text"):GetComponent(Text)
    self.rechargeMoneyTrans = t:Find("RechargeArea/Money")

    UIUtils.AddBigbg(t:Find("Bg1"), GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_reward_bg_new)))
    --t:Find("Bg1").gameObject:SetActive(false)
    self.previewContainer = t:Find("Preview")

    self.rechargeBtn = t:Find("RechargeButton"):GetComponent(Button)
    self.button = t:Find("Button"):GetComponent(Button)
    self.receiveText = t:Find("ReceiveI18N"):GetComponent(Text)

    self.rechargeBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) self.tempindex = self.currentIndex end)
    self.specilLoader = SingleIconLoader.New(t:Find("Image").gameObject)

    self.cloner:SetActive(false)
end

function NewYearReward:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function NewYearReward:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.reloadListener)

    self:Reload()

    local index = 0
    local bool = false
    for i,v in ipairs(self.campaignGroup.sub) do
        index = i
        if v.status == CampaignEumn.Status.Finish then
            bool = true
            break
        end
    end

    if bool == false then
        for i,v in ipairs(self.campaignGroup.sub) do
            index = i
            if v.status == CampaignEumn.Status.Doing then
                bool = true
                break
            end
        end
        if bool == false then
            index = 1
        end
    end

    index = self.tempindex or index

    if index > self.tabbedPanel.pageCount then
        self.tabbedPanel:TurnPage(self.tabbedPanel.pageCount)
    else
        self.tabbedPanel:TurnPage(index)
    end

    self.lanternList[index]:OnClick()

    self.tempindex = nil


    self:OnValueChange()
end

function NewYearReward:OnHide()
    self:RemoveListeners()

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end

    if self.lanternList ~= nil then
        for _,v in pairs(self.lanternList) do
            if v ~= nil then
                v:Hide()
            end
        end
    end

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end

    if self.weaponTimerId ~= nil then
        LuaTimer.Delete(self.weaponTimerId)
        self.weaponTimerId = nil
    end
end

function NewYearReward:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.reloadListener)
end

function NewYearReward:Reload()
    local campaignData = DataCampaign.data_list[self.campId]
    local startTime = campaignData.cli_start_time[1]
    local endTime = campaignData.cli_end_time[1]
    self.TimeText.text = string.format(TI18N("活动时间:<color=#ffff00>%s月%s日</color>-<color=#ffff00>%s月%s日</color>"), startTime[2], startTime[3], endTime[2], endTime[3])

    self.campaignGroup = CampaignManager.Instance.campaignTree[self.iconIndex][self.mainIndex] or {}   --mainIndex -> index
    self.lanternLayout:ReSet()

    self.reward = nil
    for i,v in ipairs(self.campaignGroup.sub) do
        local tab = self.lanternList[i]
        if tab == nil then
            tab = NewYearLanternItem.New(GameObject.Instantiate(self.lanternCloner), self.assetWrapper)
            self.lanternList[i] = tab
        end
        self.lanternLayout:AddCell(tab.gameObject)
        self.setting.openLevel[i] = 0

        if self.reward == nil and tab.protoData ~= nil and v.status == CampaignEumn.Status.Finish and v.status ~= tab.protoData.status then
            self.reward = DataCampaign.data_list[tab.protoData.id].reward[1]
        end

        tab:SetData({protoData = v, baseData = DataCampaign.data_list[v.id]})

        local j = i
        tab.clickCallback = function() self:ChangeTab(j) end
    end
    for i=#self.campaignGroup.sub + 1,#self.lanternList do
        self.lanternList[i].gameObject:SetActive(false)
    end

    local c = #self.campaignGroup.sub - 3
    self.tabbedPanel:SetPageCount(c)
    self.lanternCloner:SetActive(false)
end

function NewYearReward:OnClick(id)
    if CampaignManager.Instance.campaignTab[id].status ~= CampaignEumn.Status.Finish then
        NoticeManager.Instance:FloatTipsByString(TI18N("尚未完成"))
    else
        CampaignManager.Instance:Send14001(id)
    end
end

function NewYearReward:OnClickShow()
    NoticeManager.Instance:FloatTipsByString(TI18N("已领取"))
end

function NewYearReward:ChangeTab(index)

    if self.effect2 == nil then
        self.effect2 = BaseUtils.ShowEffect(20237, self.lanternList[index].transform, Vector3(1.3, 1.3, 1), Vector3(53, 15, -400))
    else
        self.effect2.transform:SetParent(self.lanternList[index].transform)
        self.effect2.transform.localPosition = Vector3(53, 15, -400)
        self.effect2:SetActive(true)
    end

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end

    if self.weaponTimerId ~= nil then
        LuaTimer.Delete(self.weaponTimerId)
        self.weaponTimerId = nil
    end

    if self.currentIndex ~= nil then
        self.lanternList[self.currentIndex]:TweenUp()
    end
    self.currentIndex = index
    local id = self.lanternList[index].id
    local campaignBase = DataCampaign.data_list[self.lanternList[index].id]

    local list = CampaignManager.ItemFilter(campaignBase.rewardgift)

    self:ReloadReward(list, BaseUtils.unserialize(campaignBase.cond_desc))

    self.button.onClick:RemoveAllListeners()
    self.button.onClick:AddListener(function() CampaignManager.Instance:Send14001(id) end)

    local protoData = CampaignManager.Instance.campaignTab[id]

    if protoData.status == CampaignEumn.Status.Doing then
        self.button.gameObject:SetActive(false)
        self.rechargeBtn.gameObject:SetActive(true)
        self.receiveText.gameObject:SetActive(false)
    elseif protoData.status == CampaignEumn.Status.Finish then
        self.button.gameObject:SetActive(true)
        self.rechargeBtn.gameObject:SetActive(false)
        self.receiveText.gameObject:SetActive(false)
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20118, self.button.transform, Vector3(1, 0.7, 1), Vector3(-50, 20, -400))
        end
    elseif protoData.status == CampaignEumn.Status.Accepted then
        self.button.gameObject:SetActive(false)
        self.rechargeBtn.gameObject:SetActive(false)
        self.receiveText.gameObject:SetActive(true)
    end



    if protoData.value > protoData.target_val then
        self.slider.value = 1
        self.sliderText.text = string.format("%s/%s", tostring(protoData.target_val), tostring(protoData.target_val))
        self.rechargeText.text = "0"
    else
        if protoData.target_val == 0 then
            self.slider.value = 1
        else
            self.slider.value = protoData.value / protoData.target_val
        end
        self.sliderText.text = string.format("%s/%s", tostring(protoData.value), tostring(protoData.target_val))
        self.rechargeText.text = protoData.target_val - protoData.value
    end

    local w = 270
    if self.slider.value < 1 then
        if self.sliderEffect == nil then
            self.sliderEffect = BibleRewardPanel.ShowEffect(20161, self.slider.transform, Vector3(1, 1, 1), Vector3(-w / 2 + self.slider.value * w, 0, -400))
        else
            self.sliderEffect:SetActive(true)
            if not BaseUtils.isnull(self.sliderEffect.gameObject) then
                self.sliderEffect.gameObject.transform.localPosition = Vector3(-w / 2 + self.slider.value * w, 0, -400)
            end
        end
    else
        if self.sliderEffect ~= nil then
            self.sliderEffect:SetActive(false)
        end
    end

    self.previewContainer.anchoredPosition = Vector2(-159, -68)
    self.rechargeText.transform.sizeDelta = Vector2(self.rechargeText.preferredWidth + 10, 36.1)
    self.rechargeMoneyTrans.sizeDelta = Vector2(168 + 15 + self.rechargeText.preferredWidth, 24)

    -- print(campaignBase.reward_content .. "需要剪切的字符串")

    local stringList = StringHelper.Split(campaignBase.reward_content, "|")
    --BaseUtils.dump(stringList,"dsfsdfsdf")

    -- 判断左边展示的内容
    if stringList[1] == "0" then        -- 浮动图片
        if self.previewComp ~= nil then
            self.previewComp:Hide()
            self.previewComp.rawImage.gameObject:SetActive(false)
        end
        self.specilLoader.image.gameObject:SetActive(true)
        
        if self.assetWrapper:GetSprite(AssetConfig.newyear_textures, stringList[2] .. "_" .. RoleManager.Instance.RoleData.classes) ~= nil then 
            self.specilLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.newyear_textures, stringList[2] .. "_" .. RoleManager.Instance.RoleData.classes))
        else
            self.specilLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.newyear_textures, stringList[2]))
        end

        local size = nil
        if self.specilLoader.image.sprite ~= nil then
            size = self.specilLoader.image.sprite.textureRect.size
        else
            size = Vector2.zero
        end

        if size.x > 200 then
            size = Vector2(size.x / 2, size.y / 2)
        end
        self.specilLoader.image.transform.sizeDelta = size
        if self.timer == nil then
            self.timer = LuaTimer.Add(0, 20, function() self:FloatSlot() end)
            --print("创建计时器！！！！！！！".. self.timer)
        end
        if self.markEffect ~= nil then
            self.markEffect:SetActive(false)
        end
    elseif stringList[1] == "1" then    -- 时装人物模型
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end

        --BaseUtils.dump(stringList[2],"反序列化前")
        local tab = BaseUtils.unserialize(stringList[2])
        --BaseUtils.dump(tab,"反序列化后")
        local list = {}
        local classes = RoleManager.Instance.RoleData.classes
        local sex = RoleManager.Instance.RoleData.sex
        for i,v in ipairs(tab) do
            if #v == 4 then
                if (v[1] == 0 or v[1] == classes) and (v[2] == 2 or v[2] == sex) then
                    table.insert(list,v[3])
                    break
                end
            elseif #v == 2 then
                table.insert(list,v[1])
                break
            end
        end
        if #list > 0 then
            self:ReloadShow(list)
        end
        if self.markEffect ~= nil then
            self.markEffect:SetActive(false)
        end
    elseif stringList[1] == "2" then        -- 特效浮标
        if self.markEffect == nil then
            self.markEffect = BibleRewardPanel.ShowEffect(tonumber(stringList[2]), self.previewContainer, Vector3(300, 300, 300), Vector3(-7, 20, -400))
        end
        self.markEffect:SetActive(true)
        self.specilLoader.image.gameObject:SetActive(false)
        if self.previewComp ~= nil then
            self.previewComp:Hide()
            self.previewComp.rawImage.gameObject:SetActive(false)
        end
    elseif stringList[1] == "3" then
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end

       -- BaseUtils.dump(stringList[2],"反序列化前")
        local tab = BaseUtils.unserialize(stringList[2])
        -- BaseUtils.dump(tab,"反序列化后")
        local classes = RoleManager.Instance.RoleData.classes
        local sex = RoleManager.Instance.RoleData.sex
        local weapon_id = nil
        local enchant = nil
        -- BaseUtils.dump(tab)
        for i,v in ipairs(tab) do
            if #v == 4 then
                if (v[1] == 0 or v[1] == classes) and (v[2] == 2 or v[2] == sex) then
                    weapon_id = v[3]
                    enchant = v[4]
                    break
                end
            elseif #v == 2 then
                weapon_id = v[1]
                enchant = v[2]
                break
            end
        end
        if weapon_id ~= nil then
            self:ReloadWeapon(weapon_id, enchant)
        end
        if self.markEffect ~= nil then
            self.markEffect:SetActive(false)
        end
    elseif stringList[1] == "4" then
    end
    self.descExt:SetData(campaignBase.cond_rew)
    local size = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition = Vector2(-168.6 - size.x / 2, -170.4 + size.y / 2)

    if not self.isTurnPage then
        if self.currentIndex == self.tabbedPanel.currentPage + 4 then   -- 单页最后一个
            if self.currentIndex > self.tabbedPanel.pageCount then
                self.tabbedPanel:TurnPage(self.tabbedPanel.pageCount)
            else
                self.tabbedPanel:TurnPage(self.currentIndex)
            end
        elseif self.currentIndex == self.tabbedPanel.currentPage - 1 then
            self.tabbedPanel:TurnPage(1)
        elseif self.currentIndex == self.tabbedPanel.currentPage then   -- 单页第一个
            if self.currentIndex < 4 then
                self.tabbedPanel:TurnPage(1)
            else
                self.tabbedPanel:TurnPage(self.currentIndex - 4)
            end
        end
    end
end

function NewYearReward:ReloadReward(rewardList, effectLists)
    self.layout:ReSet()
    for i,v in ipairs(rewardList) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.slot = ItemSlot.New()
            tab.data = ItemData.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Slot"), tab.slot.gameObject)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        tab.data:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        tab.slot:SetNum(v[2])
        local hasEffect = false
        for _,id in ipairs(effectLists) do
            if v[1] == id then
                hasEffect = true
                break
            end
        end

        if hasEffect then
            if tab.effect == nil then
                tab.effect = BibleRewardPanel.ShowEffect(20223, tab.slot.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
            end
        else
            if tab.effect ~= nil then
                tab.effect:DeleteMe()
                tab.effect = nil
            end
        end
    end
    for i=#rewardList + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.layout.panelRect.anchoredPosition = Vector2(0, 0)
end

function NewYearReward:ReloadShow(baseIdList)
    -- print("=============================================================================================================================武器外观")
    -- BaseUtils.dump(baseIdList,"武器外观")
    self.specilLoader.image.gameObject:SetActive(false)
    local setting = {
        name = "NewYearShow"
        ,orthographicSize = 0.6
        ,width = 300
        ,height = 300
        ,offsetY = -0.35
        ,offsetX = -0.02
    }

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)
    local kvLooks = {}
    local roledata = RoleManager.Instance.RoleData
    for _,v in pairs(unitData.looks) do
        kvLooks[v.looks_type] = v
    end

    -- BaseUtils.dump(kvLooks,"武器类型1")
    self.has_belt = false
    for _,base_id in ipairs(baseIdList) do
        print("id" .. base_id)
        local baseData = DataItem.data_get[base_id]
        for k,v in pairs(baseData.effect[1].val) do
            local fashionData = DataFashion.data_base[v[1]]
            -- if kvLooks[fashionData.type] == nil then
            if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
                kvLooks[fashionData.type] = {looks_str = "", looks_val = fashionData.model_id, looks_mode = fashionData.texture_id, looks_type = fashionData.type}
                if fashionData.type == SceneConstData.lookstype_belt then
                    self.has_belt = true
                end
            end
        end
    end
    -- BaseUtils.dump(kvLooks,"武器类型2")
    self.temp_looks = {}
    for k,v in pairs(kvLooks) do
        table.insert(self.temp_looks, v)
    end

    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = self.temp_looks}

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
    end
end

function NewYearReward:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    if self.has_belt then
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.Backward, 0))
    end

    self.previewContainer.gameObject:SetActive(true)
end

function NewYearReward:FloatSlot()
    self.counter = (self.counter or 0) + 1
    self.specilLoader.image.transform.anchoredPosition = Vector2(-170, -50 + 10 * math.sin(self.counter / 9))
end

function NewYearReward:OnMoveEnd(pageIndex)
    if pageIndex > 1 then
        self.leftSelect:SetActive(true)
        self.leftNormal:SetActive(false)
    else
        self.leftSelect:SetActive(false)
        self.leftNormal:SetActive(true)
    end
    if pageIndex < self.tabbedPanel.pageCount then
        self.rightSelect:SetActive(true)
        self.rightNormal:SetActive(false)
    else
        self.rightSelect:SetActive(false)
        self.rightNormal:SetActive(true)
    end
    if self.isTurnPage then
        self.lanternList[pageIndex]:OnClick()
    end
    self.isTurnPage = false
end

function NewYearReward:GoNextPage(direct)
    local pageIndex = self.tabbedPanel.currentPage
    self.isTurnPage = true
    if direct == 1 then -- 向右
        if pageIndex < self.tabbedPanel.pageCount then
            if pageIndex + 5 > self.tabbedPanel.pageCount then
                self.tabbedPanel:TurnPage(self.tabbedPanel.pageCount)
            else
                self.tabbedPanel:TurnPage(pageIndex + 5)
            end
        end
    elseif direct == 2 then -- 向左
        if pageIndex > 1 then
            if pageIndex - 5 < 1 then
                self.tabbedPanel:TurnPage(1)
            else
                self.tabbedPanel:TurnPage(pageIndex - 5)
            end
        end
    end
end

function NewYearReward:OnValueChange()
    local x = self.lanternContainer.anchoredPosition.x
    local w = self.tabbedPanel.panel.transform.sizeDelta.x
    for _,v in pairs(self.lanternList) do
        if v ~= nil then
            if v.transform.anchoredPosition.x >= -x - 105 and v.transform.anchoredPosition.x <= -x + w then
                v:ShowEffect(v.isDown)
                if v.effect2 == true then
                    self.effect2:SetActive(true)
                end
            else
                v:Hide()
                if v.effect2 == true then
                    self.effect2:SetActive(false)
                end
            end
        end
    end
end


function NewYearReward:ScrollValueChange(value)
    local container = self.rewardAreaScroll.content
    local left = -container.anchoredPosition.x
    local right = self.rewardAreaScroll.transform.sizeDelta.x + left
    -- local Left = (value.x-1)*(self.rewardAreaScroll.content.sizeDelta.x - 310) - 30
    -- local Right = Left + 310 + 128
    for i,v in ipairs(self.itemList) do
        local ax = v.transform.anchoredPosition.x
        local sx = v.transform.sizeDelta.x

        if ax + sx > right or ax < left then
            if v.effect ~= nil then
                v.effect:SetActive(false)
            end
        else
            if v.effect ~= nil then
                v.effect:SetActive(true)
            end
        end
    end
end

function NewYearReward:ReloadWeapon(baseid, enchant)
    self.specilLoader.image.gameObject:SetActive(false)

    local previewComp = nil
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "NewYearShow"
        ,orthographicSize = 0.6
        ,width = 300
        ,height = 300
        ,offsetY = 0
        ,offsetX = -0.02
        ,noDrag = true
    }

    local weaponData = DataLook.data_weapon[string.format("%s_%s", baseid, enchant)]

    if weaponData == nil then
        weaponData = DataLook.data_nomal_weapon_effect[string.format("%s_%s", baseid, enchant)]
    end

    local _looks = BaseUtils.copytab(SceneManager.Instance:MyData().looks)
    for k,v in pairs(_looks) do
        if v.looks_type == 1 then
            v.looks_val = baseid
            if weaponData ~= nil then
                v.looks_mode = weaponData.effect_id
            else
                v.looks_mode = 0
            end
            break
        end
    end
    local modelData = {type = PreViewType.Weapon, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
    end

    if self.weaponTimerId == nil then
        self.weaponTimerId = LuaTimer.Add(0, 22, function()
            self.counter = (self.counter or 0) + 1
            self.previewContainer.anchoredPosition = Vector2(-159,-68 + 3 * math.sin(self.counter * 0.3))
        end)
    end
end
