HeroRankWindow = HeroRankWindow or BaseClass(BaseWindow)

function HeroRankWindow:__init(model)
    self.model = model
    self.mgr = HeroManager.Instance
    self.windowId = WindowConfig.WinID.hero_rank_window

    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.is_open = false
    self.resList = {
        {file = AssetConfig.warriorRankWindow, type = AssetType.Main}
        , {file = AssetConfig.hero_textures, type = AssetType.Dep}
        , {file = AssetConfig.warrior_textures, type = AssetType.Dep}
    }

    self.updateListener = function() self:Update() end

    self.heroPanel = nil
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function HeroRankWindow:__delete()
    self.OnHideEvent:Fire()
    if self.heroPanel ~= nil then
        self.heroPanel:DeleteMe()
        self.heroPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HeroRankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warriorRankWindow))
    self.gameObject.name = "HeroRankWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    local t = self.transform
    self.main = t:Find("Main")
    self.rect = self.main:Find("RankPanel"):GetComponent(RectTransform)
    self.closeBtn = self.main:Find("CloseButton"):GetComponent(Button)

    local title = self.main:Find("Title")
    self.name1Text = title:Find("Group1/IconBg/NameBg/Text"):GetComponent(Text)
    self.name2Text = title:Find("Group2/IconBg/NameBg/Text"):GetComponent(Text)
    self.camp1Image = title:Find("Group1/IconBg/Icon"):GetComponent(Image)
    self.camp2Image = title:Find("Group2/IconBg/Icon"):GetComponent(Image)
    self.score1Text = title:Find("Group1/Score1"):GetComponent(Text)
    self.score2Text = title:Find("Group2/Score2"):GetComponent(Text)
    self.vic1Obj = title:Find("Group1/Vic").gameObject
    self.vic2Obj = title:Find("Group2/Vic").gameObject
    self.myCamp1Obj = title:Find("Group1/MyCamp").gameObject
    self.myCamp2Obj = title:Find("Group2/MyCamp").gameObject

    self.myRankText = self.main:Find("MyData/MyRank"):GetComponent(Text)
    self.myScoreText = self.main:Find("MyData/MyScore"):GetComponent(Text)
    self.rewardBtn = self.main:Find("MyData/Button"):GetComponent(Button)
    self.main:Find("MyData/Button/Text"):GetComponent(Text).text = TI18N("查看奖励")

    self.camp1Image.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "Camp1")
    self.camp2Image.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "Camp2")
    self.name1Text.text = self.mgr.campNames[1]
    self.name2Text.text = self.mgr.campNames[2]
    title:Find("Group1/IconBg/NameBg"):GetComponent(RectTransform).sizeDelta = Vector2(self.name1Text.preferredWidth + 20, 24)
    title:Find("Group2/IconBg/NameBg"):GetComponent(RectTransform).sizeDelta = Vector2(self.name2Text.preferredWidth + 20, 24)

    self.rect.gameObject:SetActive(false)
    self.closeBtn.onClick:AddListener(function() self.model:CloseRankWindow() end)
    self.rewardBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.hero_settle_window, self.model.rewardData) end)

    self.main:Find("Question").gameObject:SetActive(false)
end

function HeroRankWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function HeroRankWindow:OnOpen()
    if self.heroPanel == nil then
        self.heroPanel = HeroRankPanel.New(self.model, self.main)
    end
    self.heroPanel:Show({self.rect})
    self.is_open = true
    self.mgr.noRank = false

    self:RemoveListeners()
    self.mgr.onUpdateInfo:AddListener(self.updateListener)
    self.mgr.onUpdateReward:AddListener(self.updateListener)
    self:Update()
end

function HeroRankWindow:OnHide()
    if self.heroPanel ~= nil then
        self.heroPanel:Hiden()
    end
    self.is_open = false
    self:RemoveListeners()
end

function HeroRankWindow:RemoveListeners()
    self.mgr.onUpdateInfo:RemoveListener(self.updateListener)
    self.mgr.onUpdateReward:RemoveListener(self.updateListener)
end

function HeroRankWindow:Update()
    local model = self.model
    if model.rankHasMe then
        self.myRankText.text = string.format("%s%s", TI18N("我的排名: "), model.rank)
    else
        self.myRankText.text = string.format("%s--", TI18N("我的排名:"))
    end
    self.myScoreText.text = string.format("%s%s", TI18N("我的积分: "), tostring(model.myInfo.score))

    local score1 = model.settleData.group_list[1].score
    local score2 = model.settleData.group_list[2].score
    self.score1Text.text = tostring(score1)
    self.score2Text.text = tostring(score2)

    local bool = score1 > score2
    self.vic1Obj:SetActive(bool)
    self.vic2Obj:SetActive(not bool)
    self.myCamp1Obj:SetActive(model.myInfo.group == 1)
    self.myCamp2Obj:SetActive(model.myInfo.group == 2)

    self.rewardBtn.gameObject:SetActive(self.mgr.getReward == true)
end
