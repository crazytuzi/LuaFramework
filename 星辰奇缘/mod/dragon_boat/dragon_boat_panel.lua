-- -- ----------------------------------------------------------
-- -- UI
-- -- ----------------------------------------------------------
-- DragonBoatPanel = DragonBoatPanel or BaseClass(BasePanel)

-- local GameObject = UnityEngine.GameObject
-- local Vector3 = UnityEngine.Vector3
-- local Color = UnityEngine.Color

-- function DragonBoatPanel:__init(parent)
-- 	self.parent = parent
--     self.model = parent.model
--     self.name = "DragonBoatPanel"
--     self.resList = {
--         {file = AssetConfig.dragonboatpanel, type = AssetType.Main}
--         , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
--         , {file = AssetConfig.bigatlas_halloweenbg, type = AssetType.Main}
--     }

--     self.gameObject = nil
--     self.transform = nil
--     self.init = false

--     self.slotList = {}

--     self.campId = nil

--     ------------------------------------------------

--     ------------------------------------------------
--     self.OnOpenEvent:Add(function() self:OnShow() end)
--     self.OnHideEvent:Add(function() self:OnHide() end)
-- end

-- function DragonBoatPanel:InitPanel()
-- 	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pumpkingoblin))
--     self.gameObject.name = "DragonBoatPanel"
--     self.gameObject.transform:SetParent(self.parent.rightTransform)
--     self.gameObject.transform.localPosition = Vector3(0, 0, 0)
--     self.gameObject.transform.localScale = Vector3(1, 1, 1)

--     self.transform = self.gameObject.transform

--     -----------------------------------------
--     local transform = self.transform
--     UIUtils.AddBigbg(transform:Find("HalloweenBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_halloweenbg)))


--     -- 按钮功能绑定
--     local btn
--     self.okBtuuton = transform:FindChild("OkButton"):GetComponent(Button)
--     self.okBtuuton.onClick:AddListener(function() self:OnOkButton() end)

--     local campaign_data = DataCampaign.data_list[self.campId]
--     if campaign_data == nil then
--         Log.Error(string.format("DataCampaign 配置缺少%s项", tostring(self.campId)))
--         return
--     end
--     -- transform:FindChild("TimeText"):GetComponent(Text).text = string.format(TI18N("%s年%s月%s日-%s月%s日"), campaign_data.cli_start_time[1][1], campaign_data.cli_start_time[1][2], campaign_data.cli_start_time[1][3], campaign_data.cli_end_time[1][2], campaign_data.cli_end_time[1][3])
--     transform:FindChild("TimeBg/TimeText"):GetComponent(Text).text = campaign_data.timestr
--     transform:FindChild("TimeBg/Image").gameObject:SetActive(false)
--     transform:FindChild("TimeBg/TimeText").anchoredPosition = Vector2(8, 0)

--     self.textExt = MsgItemExt.New(transform:FindChild("Mask/Text"):GetComponent(Text), 520, 16, 30)
--     self.textExt.contentTxt.color = Color(49/255,102/255,173/255)
--     self.textExt:SetData(campaign_data.cond_desc)

--     -- 创建物品solt
--     self.container = self.transform:FindChild("RewardPanel/Mask/Container").gameObject
--     local itemObject = self.container.transform:FindChild("Item").gameObject
--     itemObject:SetActive(false)

--     local rewardgift = CampaignManager.ItemFilter(campaign_data.rewardgift)
--     for i=1, #rewardgift do
--         local item = GameObject.Instantiate(itemObject)
--         UIUtils.AddUIChild(self.container, item.gameObject)
--         local slot = ItemSlot.New()
--         UIUtils.AddUIChild(item, slot.gameObject)

--         local itembase = BackpackManager.Instance:GetItemBase(rewardgift[i][1])
--         local itemData = ItemData.New()
--         itemData:SetBase(itembase)
--         itemData.quantity = rewardgift[i][2]
--         slot:SetAll(itemData)
--         table.insert(self.slotList, slot)
--     end

--     self.times_text = transform:FindChild("Text"):GetComponent(Text)
--     -----------------------------------------
--     self.init = true
--     self.slotList = {}
--     self:OnShow()
--     self:ClearMainAsset()
-- end

-- function DragonBoatPanel:__delete()
--     self:OnHide()
--     if self.slotList ~= nil then
--         for k,v in pairs(self.slotList) do
--             v:DeleteMe()
--         end
--         self.slotList = nil
--     end
--     if self.gameObject ~= nil then
--         self.gameObject = nil
--     end
--     self:AssetClearAll()
-- end

-- function DragonBoatPanel:OnShow()
--     self:update()
-- end

-- function DragonBoatPanel:OnHide()
-- end

-- function DragonBoatPanel:update()
--     local times = HalloweenManager.Instance.model.less_times
--     local color = "#ffff00"
--     if times == HalloweenManager.Instance.pumpkingoblinTimes then
--         color = "#ff0000"
--         self.okBtuuton.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
--         self.okBtuuton.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
--     else
--         self.okBtuuton.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
--         self.okBtuuton.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
--     end
--     self.times_text.text = string.format(TI18N("参与次数:<color='%s'>%s</color><color='#ffff00'>/%s</color>"), color, HalloweenManager.Instance.pumpkingoblinTimes - times, HalloweenManager.Instance.pumpkingoblinTimes)
-- end

-- function DragonBoatPanel:OnOkButton()
--     -- SceneManager.Instance.sceneElementsModel:Self_PathToTarget("72_1")
--     if HalloweenManager.Instance.model.less_times == HalloweenManager.Instance.pumpkingoblinTimes then
--         NoticeManager.Instance:FloatTipsByString(TI18N("今天的活动次数用完了，明天再战吧！{face_1,7}"))
--         return
--     end

--     -- local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
--     -- if hour >= 16 and hour <= 18 then
--     if HalloweenManager.Instance.model.status == 2 then
--         -- HalloweenManager.Instance:Send17801()
--         HalloweenManager.Instance.model:GoCheckIn()
--     else
--         NoticeManager.Instance:FloatTipsByString(TI18N("活动开启时段为<color='#ffff00'>17:00-18:00</color>，请准时参加哦！{face_1,7}"))
--         return
--     end
--     self.parent:OnClose()
-- end


DragonBoatPanel = DragonBoatPanel or BaseClass(BasePanel)

function DragonBoatPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "DragonBoatPanel"

    --self.titleString = TI18N("龙舟龙舟")
    --self.titleString2 = TI18N("龙舟龙舟龙舟龙舟")
    self.dateFormatString = TI18N("%s月%s日")
    self.btnString = TI18N("前 往")

    self.timeFormatString = TI18N("活动时间:<color=#C7F9FF>%s-%s</color>")
    self.descExtString = TI18N("<color=#7EB9F7>活动内容:</color>")
    self.descFormatString = TI18N("%s")

    self.resList = {
        {file = AssetConfig.dragonboatpanel, type = AssetType.Main}
        , {file = AssetConfig.may_textures, type = AssetType.Dep}
        , {file = AssetConfig.guidesprite, type = AssetType.Main}
        , {file = AssetConfig.midAutumn_textures, type = AssetType.Dep}
        , {file = AssetConfig.teamquest, type = AssetType.Dep}
        , {file = AssetConfig.backend_textures, type = AssetType.Dep}
        ,{file = AssetConfig.fastskiingi18n, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DragonBoatPanel:__delete()
    self.icon = nil
    self.OnHideEvent:Fire()

    if self.descMsgExtText ~= nil then
        self.descMsgExtText:DeleteMe()
        self.descMsgExtText = nil
    end
    self:AssetClearAll()
end

function DragonBoatPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonboatpanel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.timeText = t:Find("Bg/Time"):GetComponent(Text)
    self.timeText.transform.anchoredPosition = Vector2(-127, -70)
    self.gotoMarryBtn = t:Find("Button"):GetComponent(Button)
    t:Find("Info2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.backend_textures,"TalkBg")--AssetConfig.backend_textures,"TalkBg"
    t:Find("Info2"):GetComponent(Image).type = Image.Type.Sliced
    --self.titleText = t:Find("Bg/Title/Text"):GetComponent(Text)
    --self.iconLoader = SingleIconLoader.New(t:Find("Bg/Title/Icon").gameObject)
    --t:Find("Title/Text"):GetComponent(Text).text = self.titleString2
    t:Find("Button/Text"):GetComponent(Text).text = self.btnString
    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")
    --t:Find("Bg/Title/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "dragonboat2")

    if self.bg ~= nil then
        UIUtils.AddBigbg(t:Find("Bg/Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    end
    self.bigtitle = t:Find("Bg/Text")
    self.bigtitle.anchoredPosition = Vector2(-21, 4)
    --self.bigtitle:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fastskiingi18n, "fastSkiingI18N")
    self.bigtitle.gameObject:SetActive(false)

    self.scroll = t:Find("Scroll")

    self.gotoMarryBtn.onClick:AddListener(function() self:OnButtonClick() end)

    self.descMsgExtText = MsgItemExt.New(t:Find("Scroll/Desc"):GetComponent(Text), 400, 17, 20)
end

function DragonBoatPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DragonBoatPanel:OnOpen()
    self:InitUI()

    self:RemoveListeners()
end

function DragonBoatPanel:OnHide()
    self:RemoveListeners()
end

function DragonBoatPanel:RemoveListeners()
end

function DragonBoatPanel:InitUI()

    self.scroll.transform.anchoredPosition = Vector2(63, -176)

    local campaignData = DataCampaign.data_list[self.campId]

    self.descMsgExtText:SetData(string.format(self.descFormatString, campaignData.cond_desc), true)

    self.timeText.text = string.format(self.timeFormatString,
        string.format(self.dateFormatString, tostring(campaignData.cli_start_time[1][2]),tostring(campaignData.cli_start_time[1][3])),
        string.format(self.dateFormatString, tostring(campaignData.cli_end_time[1][2]),tostring(campaignData.cli_end_time[1][3])))
    --self.titleText.text = campaignData.timestr
end

function DragonBoatPanel:OnButtonClick()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.DragonBoat then
        DragonBoatManager.Instance:GoNext()
    else -- 没报名的，去报名
        local target = BaseUtils.get_unique_npcid(32025, 1)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, target, nil, nil, true)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        --SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        --SceneManager.Instance.sceneElementsModel:Self_PathToTarget("86_1")
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
    end
end
