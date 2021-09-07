ChristmasDescPanel = ChristmasDescPanel or BaseClass(BasePanel)

function ChristmasDescPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ChristmasDescPanel"

    self.resList = {
        {file = AssetConfig.christmas_desc, type = AssetType.Main}
        , {file = AssetConfig.christmas_textures, type = AssetType.Dep}
        , {file = AssetConfig.backend_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.christmas_bg, type = AssetType.main}
        , {file = AssetConfig.guidesprite, type = AssetType.Main}
    }

    self.target = nil
    self.bg = nil
    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChristmasDescPanel:__delete()
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

function ChristmasDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.christmas_desc))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")
    t:Find("Girl"):GetComponent(Image):SetNativeSize()

    self.rewardScrollTrans = t:Find("Reward/Scroll")
    self.containerExt = MsgItemExt.New(t:Find("Scroll/Container"):GetComponent(Text), 420, 18, 21)

    self.layout = LuaBoxLayout.New(t:Find("Reward/Scroll/Container"), {axis = BoxLayoutAxis.X, border = 10, cspacing = 10})
    self.button = t:Find("Reward/Button"):GetComponent(Button)

    self.timeText = t:Find("TimeBg/Text"):GetComponent(Text)
    t:Find("TimeBg/Image").gameObject:SetActive(false)
    t:Find("TimeBg"):GetComponent(Image).enabled = false

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    self.button.onClick:AddListener(function() QuestManager.Instance.model:FindNpc(self.target) WindowManager.Instance:CloseWindowById(WindowConfig.WinID.spring_festival) end)
end

function ChristmasDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChristmasDescPanel:OnOpen()
    self:RemoveListeners()
    if self.campId ~= nil then
        self:InitUI()
        self:Reload()
    end
end

function ChristmasDescPanel:OnHide()
    self:RemoveListeners()
end

function ChristmasDescPanel:RemoveListeners()
end

function ChristmasDescPanel:InitUI()
    self.timeText.text = DataCampaign.data_list[self.campId].timestr
end

function ChristmasDescPanel:Reload()
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

    -- if self.campId == 380 then
    --     self.rewardScrollTrans.sizeDelta = Vector2(256, 60)
    --     self.button.gameObject:SetActive(true)
    -- else
    --     self.rewardScrollTrans.sizeDelta = Vector2(360, 60)
        self.button.gameObject:SetActive(false)
    --end
end
