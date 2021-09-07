MainuiTraceParade = MainuiTraceParade or BaseClass(BaseTracePanel)

function MainuiTraceParade:__init(main)
    self.main = main
    self.isInit = false

    self.remain_time = 0
    self.Timer = nil
    self.currfigure = 0
    self.lastTime = Time.time

    self.resList = {
        {file = AssetConfig.parade_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceParade:__delete()
    self.OnHideEvent:Fire()
end

function MainuiTraceParade:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.parade_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)

    self.TimeText = self.transform:Find("EaterContainer/taskItem/mobnameText"):GetComponent(Text)
    self.ExpText = self.transform:Find("EaterContainer/taskItem2/mobnameText"):GetComponent(Text)
    self.Point = self.transform:Find("EaterContainer/taskItem4/point")
    self.LevMask = self.transform:Find("EaterContainer/taskItem4/Mask")
    self.ExpSpeedText = self.transform:Find("EaterContainer/taskItem5/ActText"):GetComponent(Text)
    self.ExitButton = self.transform:Find("GiveUP/Button"):GetComponent(Button)
    self.ExitButton.onClick:AddListener(function() ParadeManager.Instance:Require13302() end)
    self.isInit = true
end

function MainuiTraceParade:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function MainuiTraceParade:OnShow()
    SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
    self.lastTime = Time.time
    self:SetTime()
    self:StarTimer()
    self:Update()
    SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
end

function MainuiTraceParade:OnHide()
    -- self.isInit = false
    -- self:StopTimer()
end

function MainuiTraceParade:Update()
    if self.isInit == false then
        return
    end
    local levPointX = {
        [0] = -90,
        [1] = -35,
        [2] = 20,
        [3] = 90,
    }
    local Explev = {
        [0] = 100,
        [1] = 110,
        [2] = 120,
        [3] = 150,
    }
    local barW =
    {
        [0] = 40,
        [1] = 95,
        [2] = 152,
        [3] = 222
    }
    self.ExpText.text = tostring(ParadeManager.Instance.getexp)
    local currfigure = 0
    local figure_score = ParadeManager.Instance.figure_score
    if figure_score == 145 then
        currfigure = 3
        figure_score = 0
    elseif figure_score > 65 then
        currfigure = 2
        figure_score = figure_score - 65
    elseif figure_score > 20 then
        currfigure = 1
        figure_score = figure_score - 20
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Sure
    data.content = TI18N("看到我表示出错了，快去报告=_=！")
    -- data.sureLabel = "确定"
    -- data.cancelLabel = "取消"
    data.sureSecond = 5
    if self.currfigure == 0 and currfigure == 1 then
        data.content = TI18N("又胖了一圈，经验获取速度提升到<color='#FFFF00'>110%</color>！")

        NoticeManager.Instance:ConfirmTips(data)
    elseif self.currfigure == 1 and currfigure == 2 then
        data.content = TI18N("又胖了一圈，经验获取速度提升到<color='#FFFF00'>120%</color>！")
        NoticeManager.Instance:ConfirmTips(data)
    elseif self.currfigure == 2 and currfigure == 3 then
        data.content = TI18N("又胖了一圈，经验获取速度提升到<color='#FFFF00'>150%</color>！")
        NoticeManager.Instance:ConfirmTips(data)
    end
    self.currfigure = currfigure
    local sizex = 222
    if currfigure == 3 then
        sizex = 222
    elseif currfigure == 2 then
        sizex = barW[currfigure]+ (figure_score /80)*(barW[currfigure+1]-barW[currfigure])
    elseif currfigure == 1 then
        sizex = barW[currfigure]+ (figure_score /45)*(barW[currfigure+1]-barW[currfigure])
    elseif currfigure == 0 then
        sizex = barW[currfigure]+ (figure_score /20)*(barW[currfigure+1]-barW[currfigure])
    else
        sizex = 222
    end
    self.Point.localPosition = Vector3(-90+sizex-35, 0, 0)
    self.LevMask.sizeDelta = Vector2(sizex, 29)
    self.ExpSpeedText.text = string.format(TI18N("经验获取速度：%s%%"), tostring(Explev[currfigure]))
end

function MainuiTraceParade:StarTimer()
    self.lastTime = Time.time
    if self.Timer == nil then
        self.Timer = LuaTimer.Add(0, 1000, function() self:DescTime() end)
    else
        LuaTimer.Delete(self.Timer)
        self.Timer = LuaTimer.Add(0, 1000, function() self:DescTime() end)
    end
end

function MainuiTraceParade:StopTimer()
    if self.Timer ~= nil then
        LuaTimer.Delete(self.Timer)
        self.Timer = nil
    end
end

function MainuiTraceParade:SetTime()
    self.remain_time = ParadeManager.Instance.remain_time
end

function MainuiTraceParade:DescTime()
    if self.remain_time>0 then
        self.remain_time = ParadeManager.Instance.remain_time
        -- self.lastTime = Time.time
        -- ParadeManager.Instance.remain_time = self.remain_time
        local m = math.floor(self.remain_time%3600/60)>9 and math.floor(self.remain_time%3600/60) or string.format("0%s", tostring(math.floor(self.remain_time%3600/60)))
        local s = math.floor(self.remain_time%60)>9 and math.floor(self.remain_time%60) or string.format("0%s", tostring(math.floor(self.remain_time%60)))
        self.TimeText.text = string.format("%s:%s", tostring(m), tostring(s))
    else
        self.TimeText.text = "00:00"
        -- if ParadeManager.Instance.status == 1 then
        --     ParadeManager.Instance.onlyUpdate_time = true
        --     ParadeManager.Instance:Require13300()
        -- end
    end
end
