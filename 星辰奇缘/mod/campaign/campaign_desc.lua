-- 黄耀聪 2017-10-25 创建

CampaignDesc = CampaignDesc or BaseClass(BasePanel)

function CampaignDesc:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "CampaignDesc"

    self.resList = {
        {file = AssetConfig.campaign_desc, type = AssetType.Main}
        -- , {file = AssetConfig.textures_campaign, type = AssetType.Dep}
        -- , {file = AssetConfig.christmas_bg, type = AssetType.main}
        , {file = AssetConfig.guidesprite, type = AssetType.Main}
    }

    self.campId = nil
    self.bg = nil
    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CampaignDesc:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.itemdata:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.containerExt ~= nil then
        self.containerExt:DeleteMe()
        self.containerExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CampaignDesc:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaign_desc))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    t:Find("ConditionTitleBg").gameObject:SetActive(false)
    t:Find("ConditionText").gameObject:SetActive(false)
    t:Find("ContentTitleBg").gameObject:SetActive(false)
    t:Find("ContentText").gameObject:SetActive(false)

    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))

    self.rewardScrollTrans = t:Find("Reward/Scroll")
    self.containerExt = MsgItemExt.New(t:Find("Scroll/Container"):GetComponent(Text), 450, 17, 19)

    self.layout = LuaBoxLayout.New(t:Find("Reward/Scroll/Container"), {axis = BoxLayoutAxis.X, border = 10, cspacing = 10})

    self.timeText = t:Find("TimeBg/Text"):GetComponent(Text)
end

function CampaignDesc:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CampaignDesc:OnOpen()
    self:RemoveListeners()

    -- self.campId = self.openArgs
    if self.campId ~= nil then
        self:InitUI()
        self:Reload()
    end
end

function CampaignDesc:OnHide()
    self:RemoveListeners()
end

function CampaignDesc:RemoveListeners()
end

function CampaignDesc:InitUI()
    self.timeText.text = DataCampaign.data_list[self.campId].timestr
end

function CampaignDesc:Reload()
    local campData = DataCampaign.data_list[self.campId]
    self.layout:ReSet()
    for i,v in ipairs(campData.rewardgift) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.itemdata = ItemData.New()
            self.itemList[i] = tab
        end
        tab.itemdata:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.itemdata)
        tab.slot:SetNum(v[2])
        self.layout:AddCell(tab.slot.gameObject)
    end
    for i=#campData.rewardgift + 1,#self.itemList do
        self.itemList[i].slot.gameObject:SetActive(false)
    end

    local str = string.format(TI18N("%s\n%s"), campData.cond_desc, campData.cond_rew)
    self.containerExt:SetData(str)
end
