BibleDailyPanel = BibleDailyPanel or BaseClass(BasePanel)

function BibleDailyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.effectPath = "prefabs/effect/20103.unity3d"
    self.guideEffect = nil
    self.resList = {
        {file = AssetConfig.bible_daily_panel, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
        {file = AssetConfig.signreward_texture,type =AssetType.Dep},
        {file = AssetConfig.signreward_big_bg, type = AssetType.Main}
        -- {file = AssetConfig.bg,type = AssetType.Main}
    }

    self.checkedObjList = {}
    self.panelList = {}
    self.btnList = {}
    self.slotList = {}
    self.slotData = {}
    self.tagImage = {}
    self.tagText = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:UpdateEveryday() end

    self.replyDaily = function(data) self:ReplyDaily(data) end
    self.canReceive = {}

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
    self.isChoujiang = false
    self.monthDays = nil
    self.nowBtnIndex = 0

    self.firstEffect = nil
end

function BibleDailyPanel:__delete()
    self.OnHideEvent:Fire()

    self.checkedObjList = nil
    self.btnList = nil
    self.panelList = nil
    self.tagText = nil
    self.tagImage = nil

    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end
    if self.slotList ~= nil then
        for k,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.slotData ~= nil then
        for k,v in pairs(self.slotData) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotData = nil
    end
    if self.dailyGridLayout ~= nil then
        self.dailyGridLayout:DeleteMe()
        self.dailyGridLayout = nil
    end
    if self.dailyEffect ~= nil then
        self.dailyEffect:DeleteMe()
        self.dailyEffect = nil
    end

    if self.signRewardEffect ~= nil then
        self.signRewardEffect:DeleteMe()
        self.signRewardEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleDailyPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_daily_panel))
    self.gameObject.name = "DailyPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local dayRewardLength = DataCheckin.data_everyday_data_length
    local everyday_data = DataCheckin.data_everyday_data

    self.dailyGridLayout = nil
    local setting = {
        column = 5
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 100
        ,cellSizeY = 84
    }

    self.transform = self.gameObject.transform
    local panel = self.transform
    self.dailyContainer = panel:Find("DaysPanel/Container")
    self.dailyGridLayout = LuaGridLayout.New(self.dailyContainer, setting)
    self.dailyItemList = {}

    self.topText = panel:Find("DaysRewardPanel/SignTimes/SignImtesText"):GetComponent(Text)
    self.DaysPanelRect = panel:Find("DaysRewardPanel/DaysRewardImage"):GetComponent(RectTransform)
    self.DaysPanelRect.anchoredPosition = Vector2(self.DaysPanelRect.anchoredPosition.x,45)
    UIUtils.AddBigbg(self.DaysPanelRect, GameObject.Instantiate(self:GetPrefab(AssetConfig.signreward_big_bg)))
    -- UIUtils.AddBigbg(self.DaysPanelRect, GameObject.Instantiate(self:GetPrefab(self.bg)))

    self.leftText = panel:Find("DaysRewardPanel/Left/TimesText"):GetComponent(Text)
    self.rightText = panel:Find("DaysRewardPanel/Right/TimesText"):GetComponent(Text)
    self.signedRewardBtn = panel:Find("DaysRewardPanel/RewardButton"):GetComponent(Button)
    self.signedRewardTr = panel:Find("DaysRewardPanel/RewardButton")
    -- self.signedRewardTr:GetComponent(RectTransform).localPosition = Vector3(165.1,-1.9,0)
    self.signrewardNoticeBtn = panel:Find("DaysRewardPanel/Right/Notice"):GetComponent(Button)

     self.signrewardNoticeBtn.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.signrewardNoticeBtn.gameObject, itemData ={
            TI18N("1、累计充值<color='#ffff00'>600</color>钻每月补签次数<color='#ffff00'>3</color>次"),
            TI18N("2、累计充值<color='#ffff00'>5000</color>钻每月补签次数<color='#ffff00'>5</color>次"),
            TI18N("3、补签不触发额外奖励")
            }})
    end)

    self.topLeftText = panel:Find("DaysRewardPanel/ImageBg/Text"):GetComponent(Text)

    self.topLeftBg = panel:Find("DaysRewardPanel/ImageBg")
    self.topLeftText.text = TI18N("当天充值<color='#ffff00'>任意金额</color>签到可<color='#ffff00'>额外</color>获得一次奖励")

    self.signedRewardBtn.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.signreward_window,{self.model.dailyCheckData,self.monthDays})
    end)



    self.dailyItemTemplate = panel:Find("DaysPanel/Container/Item").gameObject

    local obj = nil
    local data = nil
    for i=1,dayRewardLength do
        obj= GameObject.Instantiate(self.dailyItemTemplate)
        data = everyday_data[i]
        obj:SetActive(true)
        self.dailyGridLayout:AddCell(obj)
        obj.name = tostring(i)
        self.dailyItemList[i] = obj
        local t = obj.transform
        self.checkedObjList[i] = t:Find("Checked").gameObject

        local btnTab = {btn = nil, transition = nil}
        btnTab.btn = t:GetComponent(Button)
        btnTab.transition = t:GetComponent(TransitionButton)
        self.btnList[i] = btnTab
        t:Find("Panel").gameObject:SetActive(true)
        self.checkedObjList[i]:SetActive(false)
        local labelObj = t:Find("Label").gameObject
        local rewardLabelObj = t:Find("rewardLabel").gameObject
        local labelChongZhiObj = t:Find("ChongZhiLabel").gameObject
        labelChongZhiObj:SetActive(false)
        -- labelObj:SetActive(false)
        self.slotList[i] = ItemSlot.New()
        self.slotData[i] = ItemData.New()
        local cell
        if data.reward[1][1]  == 0  then
           cell = DataItem.data_get[20006]
        else
           cell = DataItem.data_get[data.reward[1][1]]
        end
        self.tagImage[i] = t:Find("LabelMod5To2"):GetComponent(Image)
        self.tagText[i] = t:Find("LabelMod5To2/I18N_Text"):GetComponent(Text)
        self.tagText[i].horizontalOverflow = 1
        self.tagText[i].gameObject:GetComponent(RectTransform).sizeDelta = Vector2(20, 30)


        if data.reward[1][1]  == 0 then
           self.slotData[i]:SetBase(cell)
           -- self.slotList[i]:SetAll(self.slotData[i], {inbag = false, nobutton = true})
           self.slotList[i]:SetItemSprite(self.assetWrapper:GetSprite(AssetConfig.signreward_texture,"reward"))
           self.slotList[i]:SetNotips()
           rewardLabelObj:SetActive(true)
        else
           self.slotData[i]:SetBase(cell)
           self.slotData[i].quantity = data.reward[1][2]
           self.slotList[i]:SetAll(self.slotData[i], {inbag = false, nobutton = true})
           rewardLabelObj:SetActive(false)
        end

        NumberpadPanel.AddUIChild(t:Find("Slot").gameObject, self.slotList[i].gameObject)
        if i % 5 == 2 then
            self.tagImage[i].gameObject:SetActive(true)
            self.tagText[i].text = string.format(TI18N("%s天"), tostring(i))
        else
            self.tagImage[i].gameObject:SetActive(false)
        end

        if data.icon == 1 and data.reward[1][1] ~= 0 then
            labelObj:SetActive(true)
        else
            labelObj:SetActive(false)
        end

        -- if data.reward[1][1] == 0 then
        --     labelObj:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.signreward_texture,"I18Laber")
        --     labelObj:SetActive(true)
        -- end


        local choujiangbtn = self.dailyItemList[i].transform:Find("ChongZhiLabel"):GetComponent(Button)
         if self.dailyItemList[i].transform.transform:Find("ChongZhiLabel").gameObject.activeSelf == true then
              self.isChoujiang = false
            -- BaseUtils.dump(self.model.dailyCheckData, "数据")
            -- BaseUtils.dump(SevendayManager.Instance.model.todayChargeData.day_charge, "数据")
                if SevendayManager.Instance.model.todayChargeData.day_charge > 0 and self.model.dailyCheckData.repeatflag == 0 then
                    if self.firstEffect == nil then
                        self.firstEffect = BibleRewardPanel.ShowEffect(20053, choujiangbtn.transform, Vector3.one, Vector3(0, 0, -400))
                        self.firstEffect:SetActive(false)
                    end
                    self.firstEffect:SetActive(true)
                else
                    if self.firstEffect ~= nil then
                        self.firstEffect:SetActive(false)
                    end
                end
        else
            if self.firstEffect ~= nil then
                self.firstEffect:SetActive(false)
            end
        end


        choujiangbtn.onClick:AddListener(function ()
              if self.dailyItemList[i].transform.transform:Find("ChongZhiLabel").gameObject.activeSelf == true then
                      self.isChoujiang = false
                      self.nowBtnIndex = i
                    -- BaseUtils.dump(self.model.dailyCheckData, "数据")
                    -- BaseUtils.dump(SevendayManager.Instance.model.todayChargeData.day_charge, "数据")
                      if SevendayManager.Instance.model.todayChargeData.day_charge > 0 and self.model.dailyCheckData.repeatflag == 0 then

                          if everyday_data[i].reward[1][1]  == 0 then
                             self.isChoujiang = true
                           end
                           self.isCanChongZhi = false
                           BibleManager.Instance:send14109()
                      elseif self.model.dailyCheckData.repeatflag == 1 and SevendayManager.Instance.model.todayChargeData.day_charge > DataCheckin.data_everyday_data[self.nowBtnIndex].gold  then
                           if everyday_data[i].reward[1][1]  == 0 then
                             self.isChoujiang = true
                           end
                           self.isCanChongZhi = false
                           BibleManager.Instance:send14109()
                      else
                           self.isCanChongZhi = true
                           BibleManager.Instance:send14109(true)
                      end


                end
            end)


        local btn = self.btnList[i].btn
        btn.onClick:AddListener(function()
            if self.canReceive[i] then
                if everyday_data[i].reward[1][1] == 0 then
                   BibleManager.Instance:send14103(self.monthDays)
                   if not BaseUtils.is_null(self.guideEffect) then
                     self.guideEffect:SetActive(false)
                   end
                   local data = {}
                   for k,v in pairs(self.model.dailyCheckData) do
                       data[k] = v
                   end
                else
                   BibleManager.Instance:send14103()
                   if not BaseUtils.is_null(self.guideEffect) then
                     self.guideEffect:SetActive(false)
                   end
                end
            else

                self.isChoujiang = false
                if self.dailyItemList[i].transform:Find("ChongZhiLabel").gameObject.activeSelf == true then
                    -- BaseUtils.dump(self.model.dailyCheckData, "数据")
                    -- BaseUtils.dump(SevendayManager.Instance.model.todayChargeData.day_charge, "数据")
                    self.nowBtnIndex = i
                      if SevendayManager.Instance.model.todayChargeData.day_charge > 0 and self.model.dailyCheckData.repeatflag == 0 then
                           self.isCanChongZhi = false
                           if everyday_data[i].reward[1][1]  == 0 then
                             self.isChoujiang = true
                           end
                           BibleManager.Instance:send14109()
                      elseif self.model.dailyCheckData.repeatflag == 1 and SevendayManager.Instance.model.todayChargeData.day_charge > DataCheckin.data_everyday_data[self.nowBtnIndex].gold  then
                           self.isCanChongZhi = false
                           if everyday_data[i].reward[1][1]  == 0 then
                             self.isChoujiang = true
                           end
                           BibleManager.Instance:send14109()
                      else
                           self.isCanChongZhi = true
                           BibleManager.Instance:send14109(true)
                      end
                end



                self.slotList[i].button.onClick:Invoke()
            end
        end)
        btn.enabled = false
        self.btnList[i].transition.enabled = true
    end
    self.dailyItemTemplate:SetActive(false)

    for i,v in ipairs(self.dailyItemList) do
        local rect = v:GetComponent(RectTransform)
        local pos = rect.anchoredPosition
        local size = rect.sizeDelta
        rect.pivot = Vector2(0.5, 0.5)
        rect.anchoredPosition = Vector2(pos.x + size.x / 2, pos.y - size.y / 2)

        self.btnList[i].btn.transition = 1
        self.btnList[i].transition.enabled = true
        self.btnList[i].transition.scaleSetting = true
        self.btnList[i].transition.scaleRate = 1.1
    end

    self.guideEffect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    local etrans = self.guideEffect.transform
    etrans:SetParent(self.dailyItemList[1].transform)
    Utils.ChangeLayersRecursively(etrans, "UI")
    etrans.localScale = Vector3.one
    etrans.localPosition = Vector3(0, 0, -500)
    self.guideEffect:SetActive(false)

    self.OnOpenEvent:Fire()
end

function BibleDailyPanel:RemoveListeners()
    self.mgr.onUpdateDaily:RemoveListener(self.updateListener)
    self.mgr.replyDailyEvent:RemoveListener(self.replyDaily)
end

function BibleDailyPanel:OnOpen()
    self:UpdateEveryday()

    self:RemoveListeners()
    self.mgr.onUpdateDaily:AddListener(self.updateListener)
    self.mgr.replyDailyEvent:AddListener(self.replyDaily)

    if self.openArgs ~= self.model.lastSelect then
        self:Hiden()
    end
end

function BibleDailyPanel:OnHide()
     if self.signRewardEffect ~= nil then
        self.signRewardEffect:DeleteMe()
    end
    self.signRewardEffect = nil
    self:RemoveListeners()
end

function BibleDailyPanel:UpdateEveryday()
    if self.dailyEffect ~= nil then
        self.dailyEffect:DeleteMe()
        self.dailyEffect = nil
    end

    if self.signRewardEffect ~= nil then
        self.signRewardEffect:DeleteMe()
    end
    self.signRewardEffect = nil

    if self.model.dailyCheckData == nil then
        return
    end

    if self.model.dailyCheckData.rand_reward >= 1 then
         self.signRewardEffect = BibleRewardPanel.ShowEffect(20053,self.signedRewardTr.transform,Vector3(1.6, 0.8, 1),Vector3(-52, -19, -400))
    end

    local regTime = RoleManager.Instance.RoleData.time_reg
    local regYear = tonumber(os.date("%Y", regTime))
    local regMonth = tonumber(os.date("%m", regTime))
    local regDay = tonumber(os.date("%d", regTime))
    -- self:CheckRedPoint()
    self.mgr.onUpdateRedPoint:Fire()

    local daysInMonth = {
        [false] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
        , [true] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    }
    local currentYear = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
    local currentMonth = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local currentDay = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local isLeap = false
    local dailyCheckData = self.model.dailyCheckData

    -- local dis = 31
    -- print(regYear.."_"..regMonth.."_"..regDay)
    -- if regYear == currentYear and regMonth == currentMonth then
    --     dis = currentDay - regDay
    -- end
    local add_sign = dailyCheckData.add_sign
    -- add_sign = math.min(add_sign, dis)

    if currentYear % 100 == 0 then
        isLeap = (currentYear % 400 == 0)
    else
        isLeap = (currentYear % 4 == 0)
    end

    local days = daysInMonth[isLeap][currentMonth]
    self.monthDays = days
    local dayRewardLength = DataCheckin.data_everyday_data_length

    self.rightText.text = string.format(TI18N("%s天"),tostring(add_sign))
    self.topText.text = string.format(TI18N("%s天"),tostring(dailyCheckData.signed))
    self.leftText.text = string.format(TI18N("%s天"),tostring(dailyCheckData.continue_num))


    for i=1,dayRewardLength do
        if i > days then
            self.dailyItemList[i]:SetActive(false)
        else
            self.dailyItemList[i]:SetActive(true)
        end
        self.btnList[i].btn.enabled = true
        self.btnList[i].transition.enabled = true
    end

    for i=1,dailyCheckData.signed do
        self.checkedObjList[i]:SetActive(true)
    end
    for i=dailyCheckData.signed + 1, #self.checkedObjList do
        self.checkedObjList[i]:SetActive(false)
    end

    local lastDay = tonumber(os.date("%d", dailyCheckData.last_time))
    local lastMonth = tonumber(os.date("%m", dailyCheckData.last_time))

    local signedToday = 1
    if lastDay == currentDay then
        signedToday = 0
    end
    for i=1,days do
        if i > dailyCheckData.signed + signedToday and i <= currentDay and i <= dailyCheckData.signed + signedToday + add_sign then
            self.tagImage[i].gameObject:SetActive(true)
            self.tagText[i].text = TI18N("补签")
        elseif i % 5 == 2 then
            self.tagImage[i].gameObject:SetActive(true)
            self.tagText[i].text = string.format(TI18N("%s天"), tostring(i))
        else
            self.tagImage[i].gameObject:SetActive(false)
        end
        self.canReceive[i] = false
    end

     -- if self.dailyItemList[dailyCheckData.signed] ~= nil then
     --    self.dailyItemList[dailyCheckData.signed].transform:Find("ChongZhiLabel").gameObject:SetActive(false)
     -- end
     -- for i,v in ipairs(self.dailyItemList) do
     --    if i == currentday - add_sign then
     --          v.transform:Find("ChongZhiLabel").gameObject:SetActive(true)
     --    else
     --        v.transform:Find("ChongZhiLabel").gameObject:SetActive(false)
     --    end
     -- end
    self.nowRewardId = 0
    if lastDay == currentDay then
        for i,v in ipairs(self.model.dailyCheckData.log) do
            if v.day == currentDay then
                self.nowRewardId = self.nowRewardId + self.model.dailyCheckData.log[i].rewarded
            end
        end
    else
        self.nowRewardId = self.model.dailyCheckData.signed + 1
    end




    if dailyCheckData.signed == 0 or currentMonth ~= lastMonth then
        lastDay = -1
    end

    if not BaseUtils.is_null(self.guideEffect) then
        self.guideEffect:SetActive(false)
    end

    if currentDay > lastDay or (currentDay == lastDay and add_sign > 0 and dailyCheckData.signed < currentDay) then
        self.btnList[dailyCheckData.signed + 1].btn.enabled = true
        self.btnList[dailyCheckData.signed + 1].transition.enabled = true

        self.canReceive[dailyCheckData.signed + 1] = true

        if self.dailyEffect ~= nil then
            self.dailyEffect:DeleteMe()
        end
        if currentDay ~= lastDay then
            self.dailyEffect = BibleRewardPanel.ShowEffect(20053, self.dailyItemList[dailyCheckData.signed + 1].transform, Vector3(1, 1, 1), Vector3(-31.86,-24.5,-400))
            if self:CheckGuide() then
                if not BaseUtils.is_null(self.guideEffect) then
                    self.guideEffect:SetActive(true)
                    TipsManager.Instance:ShowGuide({gameObject = self.dailyItemList[1], data = TI18N("每天<color='#ffff00'>签到</color>可在这里<color='#ffff00'>领取签到奖励</color>哦"), forward = TipsEumn.Forward.Right})
                end
            end
        end
    end


    for i,v in ipairs(self.dailyItemList) do
        if i == self.nowRewardId and self.canReceive[i] ~= true and self.model.dailyCheckData.repeatflag == 0 and RoleManager.Instance.RoleData.lev >= 40 then
            if DataCheckin.data_everyday_data[i].gold ~=  0 then
                   v.transform:Find("ChongZhiLabel").gameObject:SetActive(true)

            elseif DataCheckin.data_everyday_data[i].gold == 0 then
                v.transform:Find("ChongZhiLabel").gameObject:SetActive(false)
            end
        else
            v.transform:Find("ChongZhiLabel").gameObject:SetActive(false)
        end
    end

    if RoleManager.Instance.RoleData.lev >= 40 and self.canReceive[i] ~= true and self.model.dailyCheckData.repeatflag == 0 then
        if DataCheckin.data_everyday_data[self.nowRewardId] ~= nil  then
            if DataCheckin.data_everyday_data[self.nowRewardId].gold ~= 1 then
                self.topLeftText.text = string.format(TI18N("当天充值<color='#ffff00'>%d钻石</color>可<color='#ffff00'>额外</color>获得一次奖励"),DataCheckin.data_everyday_data[self.nowRewardId].gold)
            else
                self.topLeftText.text = TI18N("当天充值<color='#ffff00'>任意金额</color>可<color='#ffff00'>额外</color>获得一次奖励")
            end
        else
            self.topLeftText.text = TI18N("当天充值<color='#ffff00'>任意金额</color>可<color='#ffff00'>额外</color>获得一次奖励")
        end
        self.topLeftBg.gameObject:SetActive(true)
        self.topLeftText.gameObject:SetActive(true)
    else
         self.topLeftText.gameObject:SetActive(false)
         self.topLeftBg.gameObject:SetActive(false)
    end

    self.dailyContainer:GetComponent(RectTransform).sizeDelta = Vector2(538, 89 * math.ceil(days / 5))

    self:UpdateEffect()

end

function BibleDailyPanel:UpdateEffect()

     if self.dailyItemList[self.nowRewardId] ~= nil and self.dailyItemList[self.nowRewardId].transform.transform:Find("ChongZhiLabel").gameObject.activeSelf == true then
          local choujiangbtn = self.dailyItemList[self.nowRewardId].transform:Find("ChongZhiLabel"):GetComponent(Button)
          self.isChoujiang = false
        -- BaseUtils.dump(self.model.dailyCheckData, "数据")
        -- BaseUtils.dump(SevendayManager.Instance.model.todayChargeData.day_charge, "数据")
            if SevendayManager.Instance.model.todayChargeData ~= nil and SevendayManager.Instance.model.todayChargeData.day_charge > 0 and self.model.dailyCheckData.repeatflag == 0 then
                if self.firstEffect == nil then
                    self.firstEffect = BibleRewardPanel.ShowEffect(20053, choujiangbtn.transform, Vector3(1.15,0.5,1), Vector3(-74.5, -25.7, -400))
                    self.firstEffect:SetActive(false)
                end
                self.firstEffect:SetActive(true)
            else
                if self.firstEffect ~= nil then
                    self.firstEffect:SetActive(false)
                end
            end
    else
        if self.firstEffect ~= nil then
            self.firstEffect:SetActive(false)
        end
    end
end

function BibleDailyPanel:CheckGuide()
    local quest = QuestManager.Instance:GetQuest(10084)
    if quest ~= nil then
        if quest.progress_ser[1].finish == 0 then
            return true
        end
    end

    local quest1 = QuestManager.Instance:GetQuest(22084)
    if quest1 ~= nil then
        if quest1.progress_ser[1].finish == 0 then
            return true
        end
    end

    return false
end


function BibleDailyPanel:ReplyDaily(data)
    if data.flag == 0 then
        if self.isCanChongZhi == true then
            if DataCheckin.data_everyday_data[self.nowBtnIndex].gold ~=  0 then
                local dataN = NoticeConfirmData.New()
                dataN.type = ConfirmData.Style.Sure

                if DataCheckin.data_everyday_data[self.nowBtnIndex].gold == 1 then
                      dataN.content = TI18N("当天充值<color='#ffff00'>任意金额</color>可<color='#ffff00'>额外</color>获得一次奖励")
                else
                      dataN.content = string.format(TI18N("当天充值<color='#ffff00'>%d钻石</color>可<color='#ffff00'>额外</color>获得一次奖励"),DataCheckin.data_everyday_data[self.nowBtnIndex].gold)
                end
                dataN.sureLabel = TI18N("立即充值")
                -- data.cancelLabel = self.buyBtnString
                dataN.sureCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3}) end
                dataN.showClose = 1
                dataN.blueSure = false
                dataN.greenCancel = true
                dataN.cancelCallback = sure
                NoticeManager.Instance:ConfirmTips(dataN)
            end
        else
            NoticeManager.Instance:FloatTipsByString(data.msg)
        end
    else
        if self.isChoujiang == true then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.signreward_window,{self.model.dailyCheckData,self.monthDays})
        end
    end
end

