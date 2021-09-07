SingleDogPanel = SingleDogPanel or BaseClass(BasePanel)

function SingleDogPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "SingleDogPanel"
    self.mgr = DoubleElevenManager.Instance
    self.resList = {
        {file = AssetConfig.singledog, type = AssetType.Main}
        ,{file = AssetConfig.doubleeleven_res, type = AssetType.Dep}
        ,{file = AssetConfig.beginautum, type = AssetType.Dep}
        -- ,{file = AssetConfig.base_textures, type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        ,{file = AssetConfig.singledog_bg1, type = AssetType.Main}
        ,{file = AssetConfig.singledog_bg2, type = AssetType.Main}
        ,{file = AssetConfig.singledog_bg3, type = AssetType.Main}
        ,{file = AssetConfig.worldlevgiftitem3,type = AssetType.Dep}
        ,{file = AssetConfig.worldlevgiftitem1,type = AssetType.Dep}
    }
    self.checkReward = function (data)
        self:CheckReward(data)
    end
    self.checkQuest = function (data)
        self:CheckQuest(data)
    end
    self.refreshData = function (data)
        if data == 1 then
            self:SetData()
        end
    end
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SingleDogPanel:__delete()
    self:AssetClearAll()
    --self:EndTime()
    --DoubleElevenManager.Instance.singleDogIsOpen = false
    for i=1,3 do
        if self.list[i].slot ~= nil then
            self.list[i].slot:DeleteMe()
            self.list[i].slot = nil
        end
    end
    for i=1,3 do
        if self.list[i].bg ~= nil then
           BaseUtils.ReleaseImage(self.list[i].bg)
        end
        if self.list[i].shine ~= nil then
            BaseUtils.ReleaseImage(self.list[i].shine)
        end
    end
    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.possibleReward = nil
    end
    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
        self.iconloader = nil
    end
    if self.tweenId ~= nil then
      Tween.Instance:Cancel(self.tweenId)
      self.tweenId = nil
    end
    if self.effTimerId ~= nil then
       LuaTimer.Delete(self.effTimerId)
       self.effTimerId = nil
    end
    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
    end

    if self.effectRewardId ~= nil then
        self.effectRewardId:DeleteMe()
        self.effectRewardId = nil
    end
    if self.shakeTimer ~= nil then
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end
end

function SingleDogPanel:OnHide()
    if self.effectRewardId ~= nil then
        self.effectRewardId:SetActive(false)
    end
    --self:EndTime()
    if self.tweenId ~= nil then
      Tween.Instance:Cancel(self.tweenId)
      self.tweenId = nil
    end
    if self.effTimerId ~= nil then
       LuaTimer.Delete(self.effTimerId)
       self.effTimerId = nil
    end
    if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
    end
    --DragonBoatFestivalManager.Instance.dumplingEvent:RemoveListener(self.checkReward)
    DragonBoatFestivalManager.Instance.exchangeEvent:RemoveListener(self.refreshData)
    --QuestManager.Instance.getQuestStatus:RemoveListener(self.checkQuest)
    DoubleElevenManager.Instance.closeSingleDog:Fire()

    DoubleElevenManager.Instance.singleDogIsOpen = false
end

function SingleDogPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.singledog))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent,self.gameObject)
    UIUtils.AddBigbg(t:Find("BigBgTop"), GameObject.Instantiate(self:GetPrefab(AssetConfig.singledog_bg1)))
    UIUtils.AddBigbg(t:Find("BigBgBottom"), GameObject.Instantiate(self:GetPrefab(AssetConfig.singledog_bg2)))
    UIUtils.AddBigbg(t:Find("TopI18N"), GameObject.Instantiate(self:GetPrefab(AssetConfig.singledog_bg3)))
    local list = t:Find("List")
    self.list = {}
    for i=1,3 do
        local item = list:GetChild(i-1)
        self.list[i] = {}
        self.list[i].bgbutton = item:Find("Bg"):GetComponent(Button)
        self.list[i].bg = item:Find("Bg"):GetComponent(Image)
        self.list[i].shine = item:Find("shine"):GetComponent(Image)
        self.list[i].num = item:Find("Num"):GetComponent(Text)
        self.list[i].name = item:Find("Name"):GetComponent(Text)
        self.list[i].item = item:Find("Item")
        self.list[i].slot = nil
    end
    self.rewardTrans = self.gameObject.transform:Find("Reward")
    self.reward = t:Find("Reward"):GetComponent(Button)
    self.questBtn = t:Find("Button"):GetComponent(Button)
    self.questBtnImg = t:Find("Button"):GetComponent(Image)
    self.BtnTxt = t:Find("Button/Text"):GetComponent(Text)
    self.infoBtn = t:Find("InfoBtn"):GetComponent(Button)
    --t:Find("Desc1"):GetComponent(Text).text = TI18N("单身汪逆袭大作战，集齐三宝领好礼")
    --t:Find("Desc2"):GetComponent(Text).text = TI18N("每天只可领取一个礼包")
    local timeData = DataCampaign.data_list[self.campId]
    t:Find("TimeText"):GetComponent(Text).text = string.format(TI18N("%s月%s日-%s月%s日"),timeData.cli_start_time[1][2],timeData.cli_start_time[1][3],timeData.cli_end_time[1][2],timeData.cli_end_time[1][3])

    self.infoBtn.onClick:AddListener(function ()
        -- local tipsText = TI18N("1.<color='#ffff00'>每天可领取一次</color><color='#00ff00'>单身汪逆袭</color>任务，完成任务可获得单身汪的日常必需品\n2.活动任务将在<color='#00ff00'>每日零点重置</color>，请在当天完成所有任务哟\n3.收集齐三种指定的单身汪日常必需品可领取一份<color='#00ff00'>惊喜大礼包</color>\n4.每种单身汪日常必需品均可进行<color='#00ff00'>赠送</color>，可与好友互相交换\n5.<color='#ffff00'>每日只可领取一个神犬大礼包</color>哟，请在当天收集齐三种物品，不要错过了哟~")
        local tipsText = DataCampRiceDumplingData.data_get[1].reward_title
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {tipsText}})
    end)
    self.rotationBg = t:Find("Shine")
    self.rotationBg.anchoredPosition = Vector2(8.7,35.5)
    self.rotationBg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem3,"worldlevitemlight3")
    self.rewardTrans.sizeDelta = Vector2(100,100)
    self:OnOpen()
 end


function SingleDogPanel:OnOpen()

    self:CalculateTime()
    self:SetData()
    --DragonBoatFestivalManager.Instance.dumplingEvent:AddListener(self.checkReward)
    DragonBoatFestivalManager.Instance.exchangeEvent:AddListener(self.refreshData)
    --QuestManager.Instance.getQuestStatus:AddListener(self.checkQuest)
    DoubleElevenManager.Instance.singleDogOpened = true
    DoubleElevenManager.Instance.singleDogIsOpen = true
    --DoubleElevenManager.Instance.openSingleDog:Fire()
    -- CampaignManager.Instance.model:CheckRed(780)
    -- CampaignManager.Instance.model:CheckMainIconRed(56)

end


function SingleDogPanel:SetData()
    local cost = DataCampRiceDumplingData.data_get[1].cost
    self.ownCount = 0
    for i=1,3 do
        self.list[i].name.text = BackpackManager.Instance:GetItemBase(cost[i][1]).name
        local need = DataCampRiceDumplingData.data_get[1].cost[i][2]
        local own = BackpackManager.Instance:GetItemCount(cost[i][1])
        if need > own then
            self.list[i].num.text = string.format("<color='#df3435'>%s</color>/%s", own, need)
            self.list[i].bg.sprite = self.assetWrapper:GetSprite(AssetConfig.doubleeleven_res, "ItemBg")
            self.list[i].shine.sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1,"worldlevitemlight1")
        else
            self.list[i].num.text = string.format("<color='#06E712'>%s</color>/%s", own, need)
            self.list[i].bg.sprite = self.assetWrapper:GetSprite(AssetConfig.doubleeleven_res, "ItemBg")
            self.list[i].shine.sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1,"worldlevitemlight1")
            self.ownCount = self.ownCount + 1
        end
        if self.list[i].slot == nil then
            self.list[i].slot = ItemSlot.New()
            UIUtils.AddUIChild(self.list[i].item, self.list[i].slot.gameObject)
        end
        --print(cost[i][1].."cost[i][1]")
       -- local itemBaseData = BackpackManager.Instance:GetItemBase(cost[i][1])
        local itemBaseData = DataItem.data_get[cost[i][1]]
        local itemData = ItemData.New()
        itemData:SetBase(itemBaseData)
        self.list[i].slot:SetAll(itemData, { nobutton = true , noselect = true , noqualitybg = true })
        self.list[i].slot.bgImg.enabled = false
        self.list[i].slot.gameObject:AddComponent(TransitionButton)
        self.list[i].bgbutton.onClick:RemoveAllListeners()
        -- self.list[i].slot.gameObject:GetComponent(Button).onClick:RemoveAllListeners()
        self.list[i].bgbutton.onClick:AddListener(function ()
            local base_data = DataItem.data_get[cost[i][1]]
            local info = { itemData = base_data, gameObject = self.list[i].bg.gameObject }
            TipsManager.Instance:ShowItem(info)
        end)
        -- self.list[i].slot.gameObject:GetComponent(Button).onClick:AddListener(function ()
        --     local base_data = DataItem.data_get[cost[i][1]]
        --     local info = { itemData = base_data, gameObject = self.list[i].slot.gameObject }
        --     TipsManager.Instance:ShowItem(info)
        -- end)
    end

    -- local iconId = BackpackManager.Instance:GetItemBase(DataCampRiceDumplingData.data_get[1].reward[1][1]).icon
    -- if self.iconloader == nil then
    --     self.iconloader = SingleIconLoader.New(self.reward.gameObject)
    -- end
    -- self.iconloader:SetSprite(SingleIconType.Item, iconId, true)
    -- self.reward.transform.localScale = Vector3(0.7, 0.7, 1)
    self.reward.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.doubleeleven_res, "rewardItem")
    self.reward.onClick:RemoveAllListeners()
    self.reward.onClick:AddListener(function() self:ApplyBoxBtn() end)

    --DragonBoatFestivalManager.Instance:send17863()
    self:CheckReward()
end



function SingleDogPanel:ApplyBoxBtn()
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end
    local itemShow = {}
    for k,v in pairs(DataCampRiceDumplingData.data_get[1].reward_show) do
        local temp = {}
        temp.item_id = v[1]
        temp.is_bind = v[2]
        temp.num = v[3]
        temp.is_effet = v[4]
        table.insert(itemShow,temp)
    end
    self.possibleReward:Show({itemShow,4,{150,120,100,120},"使用可获得以下道具"})
end


function SingleDogPanel:CalculateTime()
    --self:EndTime()
    local baseTime = BaseUtils.BASE_TIME
    local timeData = DataCampaign.data_list[self.campId].cli_end_time[1]
    local endTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    self.timestamp = endTime - baseTime
    print(self.timestamp.."454545")
    --self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

-- function SingleDogPanel:TimeLoop()
--     if self.timestamp > 0 then
--         local h = math.modf(self.timestamp / 3600)
--         local m = math.modf((self.timestamp - h * 3600) / 60)
--         local s = math.modf(self.timestamp - h * 3600 - m * 60)
--         self.clockText.text = string.format("%s%s%s%s%s%s",h,TI18N("时"),m,TI18N("分"),s,TI18N("秒"))
--         self.timestamp = self.timestamp - 1
--     else
--         self:EndTime()
--     end
-- end

-- function SingleDogPanel:EndTime()
--     if self.timerId ~= nil then
--         LuaTimer.Delete(self.timerId)
--         self.timerId = nil
--     end
-- end


function SingleDogPanel:CheckReward()
    -- --print("ssddfff")
    -- --BaseUtils.dump(data,"CheckReward(data)")
    -- -- if #data.list > 0 then
    -- --     if DoubleElevenManager.Instance.questGet == true then
    -- --         self.BtnTxt.text = TI18N("<color='#E0E0E0'>已领取</color>")
    -- --         self.questBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    -- --         self.questBtn.onClick:RemoveAllListeners()
    -- --         self.questBtn.onClick:AddListener(function ()
    -- --             NoticeManager.Instance:FloatTipsByString("您今天已经领取过礼包了哟，请明天再来吧~汪")
    -- --         end)
    -- --         self:CancelRotate()
    -- --     else
    --         print("##########")
    --         self.BtnTxt.text = TI18N("<color='#906014'>领取逆袭任务</color>")
    --         self.questBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    --         self.questBtn.onClick:RemoveAllListeners()
    --         self.questBtn.onClick:AddListener(function ()
    --             SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    --             SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    --             SceneManager.Instance.sceneElementsModel:Self_PathToTarget("90_1")
    --             WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
    --          end)
    --     -- end

    -- else
    --end
    self:Shake()
    if self.ownCount > 3 or self.ownCount == 3 then
        self.BtnTxt.text = TI18N("<color='#906014'>领取奖励</color>")
        self.questBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.questBtn.onClick:RemoveAllListeners()
        self.questBtn.onClick:AddListener(function ()
            DragonBoatFestivalManager.Instance:send17862(1, 1)
            DoubleElevenManager.Instance.canGetReward = false
            self:PlayEffect()
        end)
        if self.effTimerId == nil then
           self.effTimerId = LuaTimer.Add(1000, 3000, function()
               self.questBtn.gameObject.transform.localScale = Vector3(1.1,1.1,1)
               if self.tweenId == nil then
                 self.tweenId = Tween.Instance:Scale(self.questBtn.gameObject, Vector3(1,1,1), 1.2, function() self.tweenId = nil end, LeanTweenType.easeOutElastic).id
               end
           end)
        end
        self.rotationBg.localRotation = Vector3(0,0,0)
        self:RotationBg()
    else
        self:CancelRotate()
        -- local curDay = math.modf(self.timestamp / 3600 / 24)
        -- local curQuest = 83670 - 10 * curDay
        -- print(curQuest.."curQuest")
        -- QuestManager.Instance:Send10212(curQuest)
        self.questBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.BtnTxt.text = TI18N("<color='#E0E0E0'>领取奖励</color>")
        self.questBtn.onClick:RemoveAllListeners()
        self.questBtn.onClick:AddListener(function ()
            NoticeManager.Instance:FloatTipsByString("快去收集三种必需品，领取豪华大礼包吧！")
        end)

    end
end

function SingleDogPanel:PlayEffect()
    if self.effectRewardId == nil then
        self.effectRewardId = BibleRewardPanel.ShowEffect(20049,self.rewardTrans,Vector3(1,1,1), Vector3(0,0,-400))
    else
        self.effectRewardId:SetActive(false)
    end
    self.effectRewardId:SetActive(true)
end


function SingleDogPanel:CheckQuest(data)
    -- if  data.state == 1 or data.state == 2  then
        -- self.questBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        -- self.BtnTxt.text = TI18N("<color='#E0E0E0'>领取奖励</color>")
        -- self.questBtn.onClick:RemoveAllListeners()
        -- self.questBtn.onClick:AddListener(function ()
        --     NoticeManager.Instance:FloatTipsByString("快去收集三种必需品，领取豪华大礼包吧！")
        -- end)
    -- else
    --     self.questBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    --     self.BtnTxt.text = TI18N("<color='#906014'>领取逆袭任务</color>")
    --     self.questBtn.onClick:RemoveAllListeners()
    --     self.questBtn.onClick:AddListener(function ()
    --         SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    --         SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    --         SceneManager.Instance.sceneElementsModel:Self_PathToTarget("90_1")
    --         WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
    --     end)
    -- end
end

function SingleDogPanel:RotationBg()
    self.rotationTweenId  = Tween.Instance:ValueChange(0,360,4, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
end

function SingleDogPanel:RotationChange(value)
   self.rotationBg.localRotation = Quaternion.Euler(0, 0, value)
end

function SingleDogPanel:CancelRotate()
    if self.tweenId ~= nil then
      Tween.Instance:Cancel(self.tweenId)
      self.tweenId = nil
    end
    if self.effTimerId ~= nil then
       LuaTimer.Delete(self.effTimerId)
       self.effTimerId = nil
    end
    if self.rotationTweenId ~= nil then
       Tween.Instance:Cancel(self.rotationTweenId)
       self.rotationTweenId = nil
    end
end


function SingleDogPanel:Shake()
    if self.shakeTimer == nil then
        self.shakeTimer = LuaTimer.Add(1000, 3000, function()
            self.rewardTrans.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.rewardTrans.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end
end
