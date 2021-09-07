-- 雪球大战追踪面板
-- hzf
MainuiTraceSnowBall = MainuiTraceSnowBall or BaseClass(BaseTracePanel)


function MainuiTraceSnowBall:__init(main)
    self.main = main
    self.isInit = false
    self.resList = {
        {file = AssetConfig.snowball_trace, type = AssetType.Main},
        {file = AssetConfig.teamquest, type = AssetType.Dep},
    }
    self.idList = {
        [1] = {id = 82150},
        [2] = {id = 82151},
        [3] = {id = 82155},
        [4] = {id = 82156},
    }
    self.sourceList = {
        [82150] = TI18N("熊孩子专属"),
        [82151] = TI18N("熊孩子专属"),
        [82155] = TI18N("熊孩子专属"),
        [82156] = TI18N("熊孩子专属"),
    }
    self.OnUpdateListener = function()
        self:UpdateTimes()
    end
end

function MainuiTraceSnowBall:__delete()
    for i,v in pairs(self.skillSlotList) do
        v:DeleteMe()
    end
    self.skillSlotList = nil

end

function MainuiTraceSnowBall:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.snowball_trace))
    self.gameObject.name = "MainuiTraceSnowBall"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.mainObj.transform)
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector2(0, -46)
    self.transform.localPosition = Vector3(self.transform.localPosition.x, self.transform.localPosition.y, 0)
    self.skillSlotList = {}
    for i=1,4 do
        local item = self.transform:Find("ScrollMask/List/Slot"..tostring(i))
        local slot = SkillSlot.New()
        self.skillSlotList[i] = slot
        UIUtils.AddUIChild(item.gameObject, slot.gameObject)
        slot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1
    end
    self.TimesText = self.transform:Find("SkillTitle/Text"):GetComponent(Text)
    self.TimesText.gameObject.transform.anchoredPosition3D = Vector3(-9.79, 0.73, 0)

    -- self.TextMask = self.transform:Find("TextMask"):GetComponent(Text)
    -- self.TextCon = self.transform:Find("TextMask/TextCon"):GetComponent(Text)
    self.DescText = self.transform:Find("TextMask/TextCon/DescText"):GetComponent(Text)
    self.DescText.text = TI18N("1.随机变身<color='#ffff00'>熊孩子</color>参与游戏\n2.用雪球使对手附带<color='#ffff00'>冰冻</color>\n3.满3层<color='#ffff00'>冰冻</color>会变成雪人\n4.将敌人全<color='#ffff00'>变成雪人</color>即获胜")
    self.DescText.gameObject.transform.sizeDelta = Vector2(self.DescText.gameObject.transform.sizeDelta.x, self.DescText.preferredHeight)



    self.transform:Find("BtnArea/Exit"):GetComponent(Button).onClick:AddListener(function()
        self:OnExitbtn()
    end)
    self.transform:Find("BtnArea/Team"):GetComponent(Button).onClick:AddListener(function()
        self:OnTeambtn()
    end)
    self.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnClickSelf()
    end)
    self.isInit = true
    self:LoadSlot()
    self:OnOpen()

end

function MainuiTraceSnowBall:LoadSlot()
    for i=1,4 do
        local data = BaseUtils.copytab(DataSkill.data_skill_other[self.idList[i].id])
        if data ~= nil then
            self.transform:Find("ScrollMask/List/Slot"..tostring(i)):Find("name"):GetComponent(Text).text = data.name
        end
        self.skillSlotList[i]:SetAll(Skilltype.endlessskill, data, {source = self.sourceList[self.idList[i].id]})
        self.skillSlotList[i]:ShowName(true)
        self.skillSlotList[i]:ShowLevel(false)
    end
end


function MainuiTraceSnowBall:OnOpen()
    EventMgr.Instance:AddListener(event_name.match_times_change, self.OnUpdateListener)
    self.gameObject:SetActive(true)
    if self.singup == nil then
        self.singup = SnowBallSingupPanel.New()
    end
    self.singup:Show()
    self:UpdateTimes()
end

function MainuiTraceSnowBall:Hiden()
    EventMgr.Instance:RemoveListener(event_name.match_times_change, self.OnUpdateListener)
    if self.singup ~= nil then
        self.singup:DeleteMe()
        self.singup = nil
    end
    self.gameObject:SetActive(false)
end


function MainuiTraceSnowBall:OnTeambtn()

    -- UnlimitedChallengeManager.Instance:AutoMatch()
end

function MainuiTraceSnowBall:OnExitbtn()
    -- SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
    MatchManager.Instance:Require18302()
end

function MainuiTraceSnowBall:OnClickSelf()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("59_1")
end

function MainuiTraceSnowBall:UpdateTimes()
    print("更新")
    local try = MatchManager.Instance.timesData[1000] ~= nil and MatchManager.Instance.timesData[1000] or 0
    local maxtimes = 3
    local times = maxtimes-try

    local str
    if times > 0 then
        str = string.format(TI18N("剩余次数：(<color='#00ff00'>%s</color>/%s)"), tostring(times), tostring(maxtimes))
    else
        str = string.format(TI18N("剩余次数：(<color='#ff0000'>%s</color>/%s)"), tostring(times), tostring(maxtimes))
    end
    self.TimesText.text =str
    BaseUtils.dump(MatchManager.Instance.timesData)
end
