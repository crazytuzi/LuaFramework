MainuiTraceUnlimitedChallenge = MainuiTraceUnlimitedChallenge or BaseClass(BaseTracePanel)


function MainuiTraceUnlimitedChallenge:__init(main)
    self.main = main
    self.isInit = false
    self.resList = {
        {file = AssetConfig.unlimited_trace, type = AssetType.Main},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
    }
    self.on_update_times = function()
        self:UpdateTimes()
    end
end

function MainuiTraceUnlimitedChallenge:__delete()

end

function MainuiTraceUnlimitedChallenge:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimited_trace))
    self.gameObject.name = "MainuiTraceUnlimitedChallenge"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.mainObj.transform)
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector2(0, -46)
    self.transform.localPosition = Vector3(self.transform.localPosition.x, self.transform.localPosition.y, 0)

    self.Titletext = self.transform:Find("Clearance/ActiveTitle/Text"):GetComponent(Text)
    self.Targettext = self.transform:Find("Clearance/Target"):GetComponent(Text)
    self.resetText = self.transform:Find("ReSetButton/Text"):GetComponent(Text)
    self.transform:Find("RankButton"):GetComponent(Button).onClick:AddListener(function()
        UnlimitedChallengeManager.Instance.model:OpenRankPanel()
    end)
    self.redPoint = self.transform:Find("SkillSetButton/Red")
    self.transform:Find("SkillSetButton"):GetComponent(Button).onClick:AddListener(function()
        PlayerPrefs.SetString("Unlimit", "1")
        self.redPoint.gameObject:SetActive(PlayerPrefs.GetString("Unlimit") ~= "1")
        UnlimitedChallengeManager.Instance.model:OpenSkillSetPanel()
    end)
    self.transform:Find("ReSetButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnReset()
    end)
    self.transform:Find("InfoButton"):GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.transform:Find("InfoButton").gameObject, itemData = {
            TI18N("1、无尽挑战每<color='#ffff00'>周三、日</color>开放"),
            TI18N("2、开放当天<color='#ffff00'>未挑战</color>的玩家，可获得一次重置机会，重置机会最多累计<color='#ffff00'>2次</color>"),
            TI18N("3、<color='#ffff00'>重置</color>无尽挑战后，可再次获得波次与翻牌奖励"),
            TI18N("4、排行榜取当天<color='#ffff00'>最好</color>成绩"),
            }})
    end)
    self.transform:Find("BtnArea/Exit"):GetComponent(Button).onClick:AddListener(function()
        self:OnExitbtn()
    end)
    self.transform:Find("BtnArea/Team"):GetComponent(Button).onClick:AddListener(function()
        self:OnTeambtn()
    end)
    self.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnClickSelf()
    end)
    self.resetText.text = string.format(TI18N("重置：%s"), UnlimitedChallengeManager.Instance.fight_times)
    self.isInit = true
    UnlimitedChallengeManager.Instance.UnlimitedChallengeFightTimesUpdate:AddListener(self.on_update_times)
    self:OnOpen()
end


function MainuiTraceUnlimitedChallenge:OnOpen()
    self.gameObject:SetActive(true)
    UnlimitedChallengeManager.Instance:Require17215()
end

function MainuiTraceUnlimitedChallenge:Hiden()
    -- self.isInit = false
    -- self:StopTimer()
    self.gameObject:SetActive(false)
end


function MainuiTraceUnlimitedChallenge:OnTeambtn()

    UnlimitedChallengeManager.Instance:AutoMatch()
end

function MainuiTraceUnlimitedChallenge:OnExitbtn()
    if RoleManager.Instance.RoleData.event == 29 then
        UnlimitedChallengeManager.Instance:Require17204(0)
    end
    SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
end

function MainuiTraceUnlimitedChallenge:OnClickSelf()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("59_1")
end

function MainuiTraceUnlimitedChallenge:UpdateTimes()
    print("MainuiTraceUnlimitedChallenge")
    print(PlayerPrefs.GetString("Unlimit"))
    self.redPoint.gameObject:SetActive(PlayerPrefs.GetString("Unlimit") ~= "1")
    self.resetText.text = string.format(TI18N("重置：%s"), UnlimitedChallengeManager.Instance.fight_times)
    UnlimitedChallengeManager.Instance.UnlimitedChallengeUpdate:Fire()
end

function MainuiTraceUnlimitedChallenge:OnReset()
    if UnlimitedChallengeManager.Instance.best_wave > 0 and UnlimitedChallengeManager.Instance.fight_times > 0 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("重置后，所有波次均可再次获得挑战奖励")
        data.sureLabel = TI18N("重置")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            UnlimitedChallengeManager.Instance:Require17216()
        end
        NoticeManager.Instance:ConfirmTips(data)
    elseif UnlimitedChallengeManager.Instance.best_wave <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("无需重置"))
    elseif UnlimitedChallengeManager.Instance.fight_times <= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("无重置次数"))
    end
end