GodsWarMainTop = GodsWarMainTop or BaseClass(BasePanel)

function GodsWarMainTop:__init(model, parent)
    self.model = model
    self.name = "GodsWarMainTop"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.godswartoppanel, type = AssetType.Main},
        {file = AssetConfig.ingotcrash_textures, type = AssetType.Dep},
    }

    self.status = 0
    self.buttonY = -40

    --self.endFightListener = function() self:EndFight() end

    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GodsWarMainTop:__delete()
    self.OnHideEvent:Fire()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end
    self:AssetClearAll()
end

function GodsWarMainTop:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswartoppanel))
    local t = self.gameObject.transform
    self.transform = t

    self:SetParent(self.parent)

    self.gameObject.name = self.name

    self.top = t:Find("Top")
    self.top.anchoredPosition = Vector2(0,72)
    self.button = t:Find("Top/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.buttonArrow = t:Find("Top/Button/Image"):GetComponent(Image)

    self.battle = self.top:Find("Battle")
    self.battleText = self.battle:Find("Text"):GetComponent(Text)
    self.battleTimeText = self.battle:Find("Time"):GetComponent(Text)
    self.battleClockImage = self.battle:Find("Clock"):GetComponent(Image)

    self.isShow = false
    self.battleText.transform.sizeDelta = Vector2(300, 30)
end

function GodsWarMainTop:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GodsWarMainTop:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.end_fight, self.updateListener)
    
    self:Update()
    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 40, function() self:OnTime() end)
    end
end

function GodsWarMainTop:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end

function GodsWarMainTop:TweenShow()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.tweenButtonId ~= nil then
        Tween.Instance:Cancel(self.tweenButtonId)
        self.tweenButtonId = nil
    end
    local y = self.button.transform.anchoredPosition.y
    self.button.transform.localScale = Vector2.one

    self.tweenId = Tween.Instance:MoveY(self.top, 2, 0.5, function() self.tweenId = nil end, LeanTweenType.linear).id
    self.tweenButtonId = Tween.Instance:MoveY(self.button.transform, self.buttonY, math.abs(self.buttonY - self.button.transform.anchoredPosition.y) / 180, function() self.tweenButtonId = nil end, LeanTweenType.linear).id
    self.isShow = true
end

function GodsWarMainTop:TweenHide()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.tweenButtonId ~= nil then
        Tween.Instance:Cancel(self.tweenButtonId)
        self.tweenButtonId = nil
    end
    self.tweenId = Tween.Instance:MoveY(self.top, 14 - self.buttonY, 0.5, function() self.tweenId = nil end, LeanTweenType.linear).id

    self.isShow = false

    self.button.transform.localScale = Vector2(1, -1, 1)
end

function GodsWarMainTop:SetBattle()
    self.status = 1
    self.battle.gameObject:SetActive(true)

    self.battleText.text = TI18N("战斗剩余时间:")

    self.battleText.transform.anchoredPosition = Vector2(-5, 0)
    self.battleClockImage.transform.anchoredPosition = Vector2(10, 0)
    self.battleTimeText.transform.anchoredPosition = Vector2(22, 0)

    self.isShow = true
    self.buttonY = -40
    self.button.transform.localScale = Vector2.one

    if CombatManager.Instance.isFighting then
        self:TweenShow()
    end
end



function GodsWarMainTop:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.updateListener)
end



function GodsWarMainTop:OnTime()
    if self.status == 0 then
        return
    end

    local timeText = nil
    local dis = (GodsWarManager.Instance.model.countDownTime or 0) - BaseUtils.BASE_TIME
    local min_str = nil
    local sec_str = nil
    local time_str = nil
    if dis < 0 then
        dis = 0
    end
    min_str = math.floor(dis / 60)
    sec_str = dis % 60
    if min_str < 10 then
        min_str = string.format("0%s", min_str)
    end
    if sec_str < 10 then
        sec_str = string.format("0%s", sec_str)
    end

    if self.status == 1 then
        self.battleTimeText.text = string.format("<color='#00ff00'>%s:%s</color>", min_str, sec_str)
    end
end

function GodsWarMainTop:OnClick()
    if self.isShow then
        self:TweenHide()
    else
        self:TweenShow()
    end
end

function GodsWarMainTop:SetParent(parent)
    self.parent = parent
    self.transform:SetParent(parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform.anchoredPosition = Vector2(0,0)
    -- if self.isShow == false then
    --     self.transform.anchoredPosition = Vector2(0,72) 
    -- end
end

function GodsWarMainTop:Update()
    if CombatManager.Instance.isFighting == true and (CombatManager.Instance.combatType == 110 or CombatManager.Instance.combatType == 111) and CombatManager.Instance.isWatching == false and CombatManager.Instance.isWatchRecorder == false then
        self.top.gameObject:SetActive(true)
        self:SetBattle()
    else
        self.model:CloseTopPanel()
    end
end

function GodsWarMainTop:BeginMove()
    self:TweenHide()
end
