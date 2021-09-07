SevenLoginPanel = SevenLoginPanel or BaseClass(BasePanel)

function SevenLoginPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "SevenLoginPanel"
    -- self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.seven_login_panel, type = AssetType.Main}
        ,{file = AssetConfig.seven_login_panel_texture, type = AssetType.Dep}
        ,{file = AssetConfig.seven_login_big_bg, type = AssetType.Main}
        ,{file = AssetConfig.worldlevgiftitem1, type = AssetType.Dep}
        ,{file = AssetConfig.rolebgnew, type = AssetType.Dep}
    }

    self.slotList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.lastBgId = nil
    self.data = nil
    self.rewardId = nil
    self.extra = {inbag = false, nobutton = true}
    self.signRewardEffect = nil
    self.itemSlotEffect = nil
    self.sevenDayItemSlot = nil
    self.getRewardPanel = SevenLoginGetRewardPanel.New()

    self.OpenPanelListener = function() self:OpenRewardPanel() end
    self.SetDataListener = function() self:SetData() end

    self.rewardList = {}
    self.wishExt = nil

    self.campId = nil
    self.bg = nil

end

function SevenLoginPanel:OnInitCompleted()

end

function SevenLoginPanel:__delete()
    ValentineManager.Instance.onUpdateSevenLogin:RemoveListener(self.OpenPanelListener)
    ValentineManager.Instance.onUpdateSevenLoginBegin:RemoveListener(self.SetDataListener)

    if self.sevenDayItemSlot ~= nil then
        self.sevenDayItemSlot:DeleteMe()
    end


    if  self.itemSlotEffect~= nil then
        self.itemSlotEffect:DeleteMe()
    end
    if self.signRewardEffect ~= nil then
        self.signRewardEffect:DeleteMe()
    end

    if self.slotList ~= nil then
         for i,v in ipairs(self.slotList) do
             self.slotList[i]:DeleteMe()
         end
         self.slotList = nil
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function SevenLoginPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.seven_login_panel))
    self.gameObject.name = "SevenLoginPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0,0,0)



    local t = self.transform
    self.topContainerTr = t:Find("Bg/TopContainer")
    local bigObj = GameObject.Instantiate(self:GetPrefab(self.bg))
    UIUtils.AddBigbg(self.topContainerTr,bigObj)

    self.MiddleContainerTr = t:Find("Bg/MiddleContainer")
    self.itemTemplateTr = t:Find("Bg/MiddleContainer/ItemTemplate")
    self.itemTemplateTr.gameObject:SetActive(false)
    self.itemTemplateTr:Find("Bg/ItemMiddle/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1, "worldlevitemlight1")
    self.itemTemplateTr:Find("Bg/IconBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

    self.getButton = t:Find("Bg/BottomContainer/GetButton"):GetComponent(Button)
    self.getButton.onClick:AddListener(function() self:ApplyGetButton() end)
    self.getButtonText = t:Find("Bg/BottomContainer/GetButton/Text"):GetComponent(Text)

    self.iconBg = t:Find("Bg/MiddleContainer/SevenItemTemplate/IconBg").gameObject:SetActive(false)

    self.activeText = t:Find("Bg/BottomContainer/ActiveText"):GetComponent(Text)


    self.bgButton = t:Find("Bg/MiddleContainer/SevenItemTemplate/BgButton"):GetComponent(Button)
    self.bgButton.onClick:AddListener(function() self:BgClick() end)

    self.sevenItemText = t:Find("Bg/MiddleContainer/SevenItemTemplate/BottomBg/Text"):GetComponent(Text)
    self.seventItem = t:Find("Bg/MiddleContainer/SevenItemTemplate")
    self.hasGetPanel = t:Find("Bg/MiddleContainer/SevenItemTemplate/HasGetPanel")


    self.sevenItemTr = t:Find("Bg/MiddleContainer/SevenItemTemplate/ItemSlot")
    self.sevenItemTr.anchoredPosition = Vector2(0,0)

    self.noticeButton = t:Find("Bg/BottomContainer/Notice"):GetComponent(Button)
    self.noticeButton.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeButton.gameObject, itemData ={
            TI18N("1、登陆当天可领取对应天数奖励，未领取奖励<color='#ffff00'>下次登陆</color>可继续领取（每天至多领取一次）"),
            TI18N("2、活动期间累计登陆<color='#ffff00'>7</color>天可领取<color='#ffff00'>超值奖励</color>"),
            }})
    end)



     for i=1,6 do
        local gameObject = GameObject.Instantiate(self.itemTemplateTr.gameObject)
        local rectTr = gameObject.transform:GetComponent(RectTransform)
        gameObject.transform:SetParent(self.MiddleContainerTr )
        gameObject.transform.localScale = Vector3(1, 1, 1)
        gameObject.transform.localPosition = Vector3(0,0,0)
        gameObject:SetActive(true)

        local slot = SevenLoginItem.New(gameObject,nil,i,self)

        if i <=4 then
            rectTr.anchoredPosition = Vector2(-7 + ((i-1)*137),16)
        else
            rectTr.anchoredPosition = Vector2(-7 + ((i-5)*137),-137)
        end

        self.slotList[i] = slot

    end


    self:OnOpen()

    -- self.TitleCon = self.transform:Find("MainCon/TitleCon")
    -- self.effectObj = GameObject.Instantiate(self:GetPrefab(self.Effect))
    -- self.effectObj.transform:SetParent(self.TitleCon)
    -- self.effectObj.transform.localScale = Vector3(1, 1, 1)
    -- self.effectObj.transform.localPosition = Vector3(0, 0, -400)
    -- Utils.ChangeLayersRecursively(self.effectObj.transform, "UI")
    -- self.effectObj:SetActive(true)
    -- self.NameText = self.transform:Find("MainCon/ItemCon/NameText"):GetComponent(Text)
    -- -- self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() end)
    -- self.transform:Find("MainCon/ItemCon/effect"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")
    -- if self.rotateID == nil then
    --     self.rotateID = Tween.Instance:RotateZ(self.transform:Find("MainCon/ItemCon/effect").gameObject, -720, 30, function() end):setLoopClamp()
    -- end
    -- self.itemCon = self.transform:Find("MainCon/ItemCon")
    -- self:CreatSlot(self.openArgs[1], self.itemCon)
    -- self.confirmBtnString = self.openArgs[2] or TI18N("确定")
    -- self.countTime = self.openArgs[3] or 3
    -- self.confirmText = self.transform:Find("MainCon/ImgConfirmBtn/Text"):GetComponent(Text)
    -- self.transform:Find("MainCon/ImgConfirmBtn"):GetComponent(Button).onClick:AddListener(function()
    --     self.model:CloseRewardPanel()
    -- end)

    -- if self.timerId == nil then
    --     self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    -- end
end


function SevenLoginPanel:SetData()

    self.data = ValentineManager.Instance.sevenLoginData
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endData = DataCampaign.data_list[self.campId].cli_end_time[1]
           -- local time = DataCampaign.data_list[3].day_time[1]
    local beginTime = tonumber(os.time{year = beginData[1], month = beginData[2], day = beginData[3], hour = beginData[4], min = beginData[5], sec = beginData[6]})
    self.rewardId = self.data.num


    -- if baseTime > beginTime then
    if self.data.flag == 0 then
        if self.signRewardEffect == nil and self.data.num < 7 then
            self.signRewardEffect = BibleRewardPanel.ShowEffect(20053,self.getButton.transform,Vector3(1.9, 0.7, 1),Vector3(-58, -14.5, -400))
        end
        self.signRewardEffect:SetActive(true)
----------------------

        if self.data.num < 6 then
          self.slotList[self.data.num + 1]:SetTag(true)
        end
        self.getButtonText.text = "领取奖励"
    else
        if self.data.num < 7 then
            self.getButtonText.text = "明日可领"
        else
            self.getButton.gameObject:SetActive(false)
        end

        if self.signRewardEffect~= nil then
            self.signRewardEffect:SetActive(false)
        end
        if self.data.num <= 6 then
          self.slotList[self.data.num]:SetTag(false)
        end
    end

    for i,v in ipairs(self.slotList) do
        v:SetData(self.data)
    end

    self.data = ValentineManager.Instance.sevenLoginData

    if self.itemSlotEffect == nil then
           self.itemSlotEffect = BibleRewardPanel.ShowEffect(20362,self.bgButton.transform,Vector3(1, 1, 1),Vector3(128, -77, -20))
        end
    self.itemSlotEffect:SetActive(true)
    if self.data.num  == 7 then

        if self.itemSlotEffect~= nil then
            print("lala")
            self.itemSlotEffect:SetActive(false)
        end

        self.getButton.gameObject:SetActive(false)
    end

    if 7 <= self.data.num then
        self.hasGetPanel.gameObject:SetActive(true)
    end


end

function SevenLoginPanel:OnOpen()

   ValentineManager.Instance.onUpdateSevenLogin:AddListener(self.OpenPanelListener)
   ValentineManager.Instance.onUpdateSevenLoginBegin:AddListener(self.SetDataListener)
   ValentineManager.Instance:send17843()


    if self.sevenDayItemSlot == nil then
       self.sevenDayItemSlot = ItemSlot.New(self.sevenItemTr.gameObject)
    end


    self.rewardList = {}
    for i,v in ipairs(DataCampSign.data_sevenlogin[7].item_list) do
            print(RoleManager.Instance.RoleData.sex .. "sfsdfsdf" .. v[4])
        if v[4] == 2 or v[4] == RoleManager.Instance.RoleData.sex then
            table.insert(self.rewardList,v)
        end
    end

    local baseid = self.rewardList[1][1]
    local data = DataItem.data_get[baseid]
    self.sevenDayItemSlot:SetAll()
    self.sevenDayItemSlot:ShowBg(false)
    self.sevenDayItemSlot.qualityBg.gameObject:SetActive(false)
    self.sevenDayItemSlot:SetNum(self.rewardList[1][3])


    local sevenImg = self.sevenDayItemSlot.transform:Find("ItemImg"):GetComponent(RectTransform)
    sevenImg.sizeDelta = Vector2(80,80)
    sevenImg.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.seven_login_panel_texture,"sevenReward")
    local color  = Color(1,1,1,1)
    sevenImg.transform:GetComponent(Image).color = color
    -- sevenImg:SetNativeSize()

    self:ReLoadSlot()

    self:SetBaseData()
end

function SevenLoginPanel:SetBaseData()

    local startTime = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endTime = DataCampaign.data_list[self.campId].cli_end_time[1]
    self.activeText.text = string.format(TI18N("%s年%s月%s日 ~ %s年%s月%s日"),startTime[1],startTime[2],startTime[3],endTime[1],endTime[2],endTime[3])


    -- local baseId = DataCampSign.data_sevenlogin[7].item_list[1][1]
    -- local data = DataItem.getGetFunc(baseId)
    self.sevenItemText.text = DataCampSign.data_sevenlogin[7].name
end

function SevenLoginPanel:OnHide()
    ValentineManager.Instance.onUpdateSevenLogin:RemoveListener(self.OpenPanelListener)
    ValentineManager.Instance.onUpdateSevenLoginBegin:RemoveListener(self.SetDataListener)
    if self.slotList ~= nil then
         for i,v in ipairs(self.slotList) do
             self.slotList[i]:OnHide()
         end
    end
end

function SevenLoginPanel:ReLoadSlot()
    if self.slotList ~= nil then
         for i,v in ipairs(self.slotList) do
             self.slotList[i]:OnOpen()
         end
    end
end

-- function SevenLoginPanel:ChangeBgId(id)
--     print("点击的id" .. id)
--      if self.lastBgId == id then
--            return
--      end

--      if self.lastBgId ~= nil then
--         self.slotList[self.lastBgId]:SetColorRed(false)
--      end
--      self.slotList[id]:SetColorRed(true)
--      self.lastBgId = id
-- end


function SevenLoginPanel:OpenRewardPanel()
    local data = DataCampSign.data_sevenlogin[self.rewardId]
    local dataList = {}

    for i,v in ipairs(data.item_list) do
        table.insert(dataList,v)
    end

   if self.getRewardPanel == nil then
        self.getRewardPanel = SevenLoginGetRewardPanel.New(self)
    end
    self.getRewardPanel:Show({dataList, TI18N("确定"), 5})
    ValentineManager.Instance:send17843()

end

function SevenLoginPanel:ApplyGetButton()
       ValentineManager.Instance:send17844()
end

function SevenLoginPanel:BgClick()

    if #self.rewardList <=1 then
         local baseId = self.rewardList[1][1]
         local data = DataItem.data_get[baseId]
         local itemData = ItemData.New()
         itemData:SetBase(data)
         TipsManager.Instance:ShowItem({gameObject = self.gameObject, itemData = itemData,extra = self.extra})
    else
         local data = self.rewardList
         local dataList = {}

         for i,v in ipairs(self.rewardList) do
             table.insert(dataList,v)
         end

        if self.tipsPanel == nil then
             self.tipsPanel = SevenLoginTipsPanel.New(self)
         end
         self.tipsPanel:Show({dataList})
    end
end


-- function SevenLoginPanel:ApplyGetRewardEnd()
--     ValentineManager.Instance.onUpdateSevenLogin:RemoveListener(self.OpenPanelListener)
-- end
-- function SevenLoginPanel:CloseItemEffect()
--     if self.slotList ~= nil then
--          for i,v in ipairs(self.slotList) do
--              self.slotList[i]:SetItemSlotEffect(false)
--          end
--     end
-- end


