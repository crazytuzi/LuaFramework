-- ----------------------------------------------------------
-- UI - Pumpkin
-- ----------------------------------------------------------
HalloweenPumpkingoblinPanel = HalloweenPumpkingoblinPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function HalloweenPumpkingoblinPanel:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "HalloweenPumpkingoblinPanel"
    self.resList = {
        {file = AssetConfig.pumpkingoblin, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
        , {file = AssetConfig.bigatlas_halloweenbg, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    self.slotList = {}

    self.campId = nil

    ------------------------------------------------

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HalloweenPumpkingoblinPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pumpkingoblin))
    self.gameObject.name = "HalloweenPumpkingoblinPanel"
    self.gameObject.transform:SetParent(self.parent.rightTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform
    UIUtils.AddBigbg(transform:Find("HalloweenBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_halloweenbg)))


    -- 按钮功能绑定
    local btn
    self.okBtuuton = transform:FindChild("OkButton"):GetComponent(Button)
    self.okBtuuton.onClick:AddListener(function() self:OnOkButton() end)

    local campaign_data = DataCampaign.data_list[self.campId]
    if campaign_data == nil then
        Log.Error(string.format("DataCampaign 配置缺少%s项", tostring(self.campId)))
        return
    end
    -- transform:FindChild("TimeText"):GetComponent(Text).text = string.format(TI18N("%s年%s月%s日-%s月%s日"), campaign_data.cli_start_time[1][1], campaign_data.cli_start_time[1][2], campaign_data.cli_start_time[1][3], campaign_data.cli_end_time[1][2], campaign_data.cli_end_time[1][3])
    transform:FindChild("TimeBg/TimeText"):GetComponent(Text).text = campaign_data.timestr
    transform:FindChild("TimeBg/Image").gameObject:SetActive(false)
    transform:FindChild("TimeBg/TimeText").anchoredPosition = Vector2(8, 0)

    self.textExt = MsgItemExt.New(transform:FindChild("Mask/Text"):GetComponent(Text), 520, 16, 30)
    self.textExt.contentTxt.color = Color(49/255,102/255,173/255)
    self.textExt:SetData(campaign_data.cond_desc)

    -- 创建物品solt
    self.container = self.transform:FindChild("RewardPanel/Mask/Container").gameObject
    local itemObject = self.container.transform:FindChild("Item").gameObject
    itemObject:SetActive(false)

    local rewardgift = CampaignManager.ItemFilter(campaign_data.rewardgift)
    for i=1, #rewardgift do
        local item = GameObject.Instantiate(itemObject)
        UIUtils.AddUIChild(self.container, item.gameObject)
        local slot = ItemSlot.New()
        UIUtils.AddUIChild(item, slot.gameObject)

        local itembase = BackpackManager.Instance:GetItemBase(rewardgift[i][1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = rewardgift[i][2]
        slot:SetAll(itemData)
        table.insert(self.slotList, slot)
    end

    self.times_text = transform:FindChild("Text"):GetComponent(Text)
    -----------------------------------------
    self.init = true
    self.slotList = {}
    self:OnShow()
    self:ClearMainAsset()
end

function HalloweenPumpkingoblinPanel:__delete()
    self:OnHide()
    if self.slotList ~= nil then
        for k,v in pairs(self.slotList) do
            v:DeleteMe()
        end
        self.slotList = nil
    end
    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HalloweenPumpkingoblinPanel:OnShow()
    self:update()
end

function HalloweenPumpkingoblinPanel:OnHide()
end

function HalloweenPumpkingoblinPanel:update()
    local times = HalloweenManager.Instance.model.less_times
    local color = "#ffff00"
    if times == HalloweenManager.Instance.pumpkingoblinTimes then
        color = "#ff0000"
        self.okBtuuton.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.okBtuuton.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
    else
        self.okBtuuton.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.okBtuuton.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
    end
    self.times_text.text = string.format(TI18N("参与次数:<color='%s'>%s</color><color='#ffff00'>/%s</color>"), color, HalloweenManager.Instance.pumpkingoblinTimes - times, HalloweenManager.Instance.pumpkingoblinTimes)
end

function HalloweenPumpkingoblinPanel:OnOkButton()
    -- SceneManager.Instance.sceneElementsModel:Self_PathToTarget("72_1")
    if HalloweenManager.Instance.model.less_times == HalloweenManager.Instance.pumpkingoblinTimes then
        NoticeManager.Instance:FloatTipsByString(TI18N("今天的活动次数用完了，明天再战吧！{face_1,7}"))
        return
    end

    -- local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    -- if hour >= 16 and hour <= 18 then
    if HalloweenManager.Instance.model.status == 2 then
        -- HalloweenManager.Instance:Send17801()
        HalloweenManager.Instance.model:GoCheckIn()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动开启时段为<color='#ffff00'>17:00-18:00</color>，请准时参加哦！{face_1,7}"))
        return
    end
    self.parent:OnClose()
end