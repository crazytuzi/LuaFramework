HeroMainUIPanel = HeroMainUIPanel or BaseClass(BasePanel)

function HeroMainUIPanel:__init(model)
    self.model = model
    self.mgr = HeroManager.Instance

    self.resList = {
        {file = AssetConfig.warriorMainUIPanel, type = AssetType.Main},
        {file = AssetConfig.hero_textures, type = AssetType.Dep},
        {file = AssetConfig.warrior_textures, type = AssetType.Dep},
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.timeListener = function() self:OnTime() end
    self.fieldListener = function() self:OnScore() end
    self.beginFightListener = function() self:ShowScoreBar(false) end
    self.endFightListener = function() self:ShowScoreBar(true) end
    self.teamListener = function() self:OnTeam() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function HeroMainUIPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HeroMainUIPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.warriorMainUIPanel))
    self.gameObject.name = "ScoreBar"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)

    local main = self.transform:Find("Main")
    self.camp1Image = main:Find("Image1"):GetComponent(Image)
    self.camp2Image = main:Find("Image2"):GetComponent(Image)
    self.group1NameImage = main:Find("Group1"):GetComponent(Image)
    self.group2NameImage = main:Find("Group2"):GetComponent(Image)
    self.score1Text = main:Find("Score1"):GetComponent(Text)
    self.score2Text = main:Find("Score2"):GetComponent(Text)
    self.myCamp1Obj = main:Find("MyCamp1").gameObject
    self.myCamp2Obj = main:Find("MyCamp2").gameObject
    self.descText1 = main:Find("Desc1"):GetComponent(Text)
    self.descText2 = main:Find("Desc2"):GetComponent(Text)

    self.camp1Image.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "Camp1")
    self.camp2Image.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "Camp2")
    self.group1NameImage.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "I18NCampName2")
    self.group2NameImage.sprite = self.assetWrapper:GetSprite(AssetConfig.hero_textures, "I18NCampName1")
    self.group1NameImage.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(150, 20)
    self.group2NameImage.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(150, 20)

    self.btn = main.gameObject:GetComponent(Button)
    if self.btn == nil then
        self.btn = main.gameObject:AddComponent(Button)
    end

    self.mainObj = main.gameObject
    local btn = self.transform:Find("MapMask"):GetComponent(Button)
    self.mapMaskObj = btn.gameObject
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
        -- self.mgr:OnQuit()
    end)
    self.mapMaskObj:SetActive(false)

    self.countDownObj = main:Find("CountDown").gameObject
    self.countDownText = main:Find("CountDown/Text"):GetComponent(Text)
    self.dropDownBtn = self.transform:Find("Dropdown"):GetComponent(Button)
    self.dropDownRect = self.dropDownBtn.gameObject:GetComponent(RectTransform)
    self.dropDownTrans = self.dropDownBtn.gameObject.transform

    self.dropDownBtn.gameObject:SetActive(true)
    self.dropDownBtn.onClick:AddListener(function()
        if not self.isMainHide then
            self:ShowScoreBar(false)
        else
            self:ShowScoreBar(true)
        end
    end)

    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function()

    end)
end

function HeroMainUIPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function HeroMainUIPanel:OnOpen()
    self:OnScore()
    self:OnTime()

    self:RemoveListeners()
    self.mgr.onUpdateTime:AddListener(self.timeListener)
    self.mgr.onUpdateField:AddListener(self.fieldListener)
    self.mgr.onUpdateInfo:AddListener(self.fieldListener)
    self.mgr.onUpdateTeam:AddListener(self.teamListener)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFightListener)
end

function HeroMainUIPanel:OnTime()
    local restTime = self.model.restTime
    if restTime == nil or restTime < 0 then restTime = 0 end

    if self.mgr.phase == HeroEumn.Phase.Battle then
        self.countDownObj:SetActive(true)
        local min = math.floor(restTime / 60)
        local sec = restTime % 60
        if min < 10 then min = "0"..tostring(min) end
        if sec < 10 then sec = "0"..tostring(sec) end
        self.countDownText.text = string.format("%s:%s", min, sec)
    else
        self.countDownObj:SetActive(false)
    end
end

function HeroMainUIPanel:RemoveListeners()
    self.mgr.onUpdateTime:RemoveListener(self.timeListener)
    self.mgr.onUpdateField:RemoveListener(self.fieldListener)
    self.mgr.onUpdateInfo:RemoveListener(self.fieldListener)
    self.mgr.onUpdateTeam:RemoveListener(self.teamListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFightListener)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFightListener)
end

function HeroMainUIPanel:OnScore()
    local model = self.model
    if self.score1Text ~= nil then self.score1Text.text = string.format("%s%s", tostring(model.campList[1].score), TI18N("分")) end
    if self.score2Text ~= nil then self.score2Text.text = string.format("%s%s", tostring(model.campList[2].score), TI18N("分")) end

    local group = model.myInfo.group
    self.myCamp1Obj:SetActive(group == 2)
    self.myCamp2Obj:SetActive(group == 1)

    -- self.descText1.text = ""
    -- self.descText2.text = ""
    -- if model.campList[1].num ~= nil and model.campList[1].num <= 15 then
    --     self.descText1.text = "剩余<color=#FF0000>"..tostring(model.campList[1].num).."</color>人"
    -- end
    -- if model.campList[2].num ~= nil and model.campList[2].num <= 15 then
    --     self.descText2.text = "剩余<color=#FF0000>"..tostring(model.campList[2].num).."</color>人"
    -- end
end

function HeroMainUIPanel:OnTeam()
    local setEmpty = true
    if self.model.teamList ~= nil then
        for i,v in ipairs(self.model.teamList) do
            setEmpty = setEmpty and (v.match == 0 and v.fight == 0)
            self["descText"..v.group].text = string.format("<color=#FFFF00>%s<color=#00FF00>%s</color>%s\n%s<color=#00FF00>%s</color>%s</color>", TI18N("匹配中"), tostring(v.match), TI18N("队"), TI18N("战斗中"), tostring(v.fight), TI18N("队"))
        end
    end
    if setEmpty then
        self.descText1.text = ""
        self.descText2.text = ""
    end
end

function HeroMainUIPanel:OnHide()
    self:RemoveListeners()
end

function HeroMainUIPanel:ShowScoreBar(bool)
    self.mainObj:SetActive(bool)
    self.isMainHide = not bool
    if bool then
        self.dropDownRect.anchoredPosition = Vector2(0, -90)
        self.dropDownTrans.localScale = Vector3.one
    else
        self.dropDownRect.anchoredPosition = Vector2(0, -16)
        self.dropDownTrans.localScale = Vector3(1, -1, 1)
    end
end
