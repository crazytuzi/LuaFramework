-- @author 黄耀聪
-- @date 2017年3月7日

GuildSiegeStarSelect = GuildSiegeStarSelect or BaseClass(BasePanel)

function GuildSiegeStarSelect:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.name = "GuildSiegeStarSelect"

    self.buttonList = {}
    self.rewardList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self:InitPanel()
end

function GuildSiegeStarSelect:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                v.imageLoader:DeleteMe()
                v.imageLoader = nil
            end
        end
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    self:AssetClearAll()
end

function GuildSiegeStarSelect:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.infoArea = t:Find("InfoArea").gameObject
    self.infoText = t:Find("InfoArea/Info"):GetComponent(Text)
    self.starArea = t:Find("StarArea").gameObject
    for i=1,3 do
        self.buttonList[i] = {}
        local trans = t:Find("StarArea"):GetChild(i - 1)
        self.buttonList[i].image = trans:GetComponent(Image)
        self.buttonList[i].text = trans:Find("Text"):GetComponent(Text)
        self.buttonList[i].text.text = string.format(TI18N("%s星"), tostring(i))
        self.buttonList[i].btn = trans:GetComponent(Button)
        local j = i
        self.buttonList[i].btn.onClick:AddListener(function() self:OnClick(j) end)
    end
    self.rewardArea = t:Find("RewardArea").gameObject
    self.rewardContainer = t:Find("RewardArea/Container")
    self.rewardLayout = LuaBoxLayout.New(self.rewardContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.rewardCloner = t:Find("RewardArea/Reward").gameObject
    self.button = t:Find("RewardArea/Button"):GetComponent(Button)
    self.layout = LuaBoxLayout.New(t, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 0})
    self.rewardCloner:SetActive(false)

    self.button.onClick:AddListener(function() if self.targetCastle ~= nil then GuildSiegeManager.Instance:send19103(self.targetCastle.order, self.selectStar) end end)
end

function GuildSiegeStarSelect:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeStarSelect:OnOpen()
    self:RemoveListeners()

    self.targetCastle = self.openArgs or {
        loss_star = 0
    }

    self:Reload()
    -- self:Default()
end

function GuildSiegeStarSelect:Default()
    if self.targetCastle.loss_star < 2 then
        self:OnClick(2)
    else
        self:OnClick(3)
    end
end

function GuildSiegeStarSelect:OnHide()
    self:RemoveListeners()
end

function GuildSiegeStarSelect:RemoveListeners()
end

function GuildSiegeStarSelect:Reload()
    if self.targetCastle.loss_star == 0 then
        self.infoText.text = TI18N("请选择难度:")
    elseif self.targetCastle.loss_star == 1 then
        self.infoText.text = TI18N("当前1星已战胜，还可选择<color='#ffff00'>2星3星</color>难度")
    elseif self.targetCastle.loss_star == 2 then
        self.infoText.text = TI18N("当前2星已战胜，还可选择<color='#ffff00'>3星</color>难度")
    elseif self.targetCastle.loss_star == 3 then
        self.infoText.text = TI18N("已攻陷")
    end
    for i=1,3 do
        if i <= self.targetCastle.loss_star then
            self.buttonList[i].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.buttonList[i].text.color = ColorHelper.DefaultButton4
        else
            self.buttonList[i].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.buttonList[i].text.color = ColorHelper.DefaultButton1
        end
    end
    self.selectStar = nil
    self:Layout()
end

function GuildSiegeStarSelect:Layout()
    self.rewardArea:SetActive(false)
    self.layout:ReSet()
    self.layout:AddCell(self.infoArea)
    self.layout:AddCell(self.starArea)
    if self.selectStar ~= nil then
        self.layout:AddCell(self.rewardArea)
    end
    self.transform.sizeDelta = Vector2(self.layout.panelRect.sizeDelta.x, self.layout.panelRect.sizeDelta.y + 20)
end

function GuildSiegeStarSelect:OnClick(i)
    if i > self.targetCastle.loss_star then
        for j=self.targetCastle.loss_star + 1,3 do
            if j == i then
                self.buttonList[j].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                self.buttonList[j].text.color = ColorHelper.DefaultButton2
            else
                self.buttonList[j].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                self.buttonList[j].text.color = ColorHelper.DefaultButton1
            end
        end
        self.selectStar = i
        self:ReloadReward(i)
    end
    self:Layout()
end

function GuildSiegeStarSelect:ReloadReward(star)
    self.rewardArea:SetActive(true)

    local rewardList = nil
    if star == 1 then
        rewardList = DataGuildSiege.data_castle[self.targetCastle.order].first_reward
    elseif star == 2 then
        rewardList = DataGuildSiege.data_castle[self.targetCastle.order].second_reward
    elseif star == 3 then
        rewardList = DataGuildSiege.data_castle[self.targetCastle.order].final_reward
    else
        rewardList = {}
    end

    for i,reward in ipairs(rewardList) do
        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.rewardCloner)
            tab.transform = tab.gameObject.transform
            tab.imageLoader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
            tab.text = tab.transform:Find("Text"):GetComponent(Text)
            self.rewardList[i] = tab
            self.rewardLayout:AddCell(tab.gameObject)
        end
        tab.imageLoader:SetSprite(SingleIconType.Item, DataItem.data_get[reward[1]].icon)
        tab.text.text = string.format("×%s", tostring(reward[2]))
        tab.gameObject:SetActive(true)
    end
    for i=#rewardList + 1,#self.rewardList do
        self.rewardList[i].gameObject:SetActive(false)
    end
end

