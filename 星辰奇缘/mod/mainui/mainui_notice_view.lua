-- 主界面 通知栏
MainuiNoticeView = MainuiNoticeView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function MainuiNoticeView:__init()
    self.model = model
    self.resList = {
        {file = AssetConfig.mainuinotice, type = AssetType.Main}
    }

    self.activenoticeOriginY = -124

    self.name = "MainuiNoticeView"

    self.gameObject = nil
    self.transform = nil
    self.hasHead = false
    ------------------------------------
    self.examnotice = nil
    self.zonenotice = nil
    self.momentnotice = nil
    self.friendnotice = nil
    self.chatnotice = nil
    self.teamnotice = nil
    self.mailnotice = nil

    self.zonenotice_text = nil
    self.momentnotice_text = nil
    self.friendnotice_text = nil
    self.chatnotice_text = nil
    self.teamnotice_text = nil
    self.mailnotice_text = nil

    self.zonenotice_num = 0
    self.momentnotice_num = 0
    self.friendnotice_num = 0
    self.chatnotice_num = 0
    self.teamnotice_num = 0
    self.mailnotice_num = 0
    self.guildnotice_num = 0
    self.guildfightnotice_num = 0

    self.Last_zonenotice_num = 0
    self.Last_momentnotice_num = 0
    self.Last_friendnotice_num = 0
    self.Last_chatnotice_num = 0
    self.Last_teamnotice_num = 0
    self.Last_mailnotice_num = 0
    self.Last_guildnotice_num = 0
    self.Last_guildfightnotice_num = 0
    ------------------------------------

    self.adaptListener = function() self:AdaptIPhoneX() end

    self:LoadAssetBundleBatch()
end

function MainuiNoticeView:__delete()
    BaseUtils.CancelIPhoneXTween(self.transform)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MainuiNoticeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mainuinotice))
    self.gameObject.name = "MainuiNoticeView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.transform = self.gameObject.transform
    -----------------------------
    self.activenotice = self.transform:FindChild("ActiveButton").gameObject
    self.activenoticeRect = self.activenotice:GetComponent(RectTransform)

    self.activenoticeRect.anchoredPosition = Vector2(-324, self.activenoticeOriginY)

    self.examnotice = self.transform:FindChild("ExamButton").gameObject
    self.zonenotice = self.transform:FindChild("Notice/ZoneNotice").gameObject
    self.momentnotice = self.transform:FindChild("Notice/MomentNotice").gameObject
    self.friendnotice = self.transform:FindChild("Notice/FriendNotice").gameObject
    self.chatnotice = self.transform:FindChild("Notice/ChatNotice").gameObject
    self.teamnotice = self.transform:FindChild("Notice/TeamNotice").gameObject
    self.mailnotice = self.transform:FindChild("Notice/MailNotice").gameObject
    self.guildnotice = self.transform:FindChild("Notice/GuildNotice").gameObject
    self.guildfightnotice = self.transform:FindChild("Notice/GuildFightNotice").gameObject
    self.guildfightnotice.gameObject:SetActive(false)

    self.zonenotice_text = self.transform:FindChild("Notice/ZoneNotice/Text"):GetComponent(Text)
    self.momentnotice_text = self.transform:FindChild("Notice/MomentNotice/Text"):GetComponent(Text)
    self.friendnotice_text = self.transform:FindChild("Notice/FriendNotice/Text"):GetComponent(Text)
    self.chatnotice_text = self.transform:FindChild("Notice/ChatNotice/Text"):GetComponent(Text)
    self.teamnotice_text = self.transform:FindChild("Notice/TeamNotice/Text"):GetComponent(Text)
    self.mailnotice_text = self.transform:FindChild("Notice/MailNotice/Text"):GetComponent(Text)
    self.guildnotice_text = self.transform:FindChild("Notice/GuildNotice/Text"):GetComponent(Text)
    self.guildfightnotice_text = self.transform:FindChild("Notice/GuildFightNotice/Text"):GetComponent(Text)

    self.zonenotice:GetComponent(Button).onClick:AddListener(function() self:zonenotice_click() end)
    self.momentnotice:GetComponent(Button).onClick:AddListener(function() self:momentnotice_click() end)
    self.friendnotice:GetComponent(Button).onClick:AddListener(function() self:friendnotice_click() end)
    self.chatnotice:GetComponent(Button).onClick:AddListener(function() self:chatnotice_click() end)
    self.teamnotice:GetComponent(Button).onClick:AddListener(function() self:teamnotice_click() end)
    self.mailnotice:GetComponent(Button).onClick:AddListener(function() self:mailnotice_click() end)
    self.guildnotice:GetComponent(Button).onClick:AddListener(function() self:guildnotice_click() end)
    self.activenotice:GetComponent(Button).onClick:AddListener(function() self:activenotice_click() end)
    self.guildfightnotice:GetComponent(Button).onClick:AddListener(function() self:guildfightnotice_click() end)

    self.isShow = true
    self:MoveActiceNotice(false)

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    -----------------------------
    EventMgr.Instance:Fire(event_name.mainui_notice_init)

    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)
    self:AdaptIPhoneX()
    self:update()

    if BaseUtils.IsVerify then
        self.gameObject:SetActive(false)
    end
end


function MainuiNoticeView:update()
    if self.gameObject == nil then return end

    if self.zonenotice_num == 0 then
        self.zonenotice:SetActive(false)
    else
        if self.Last_zonenotice_num < self.zonenotice_num then
            SoundManager.Instance:Play(257)
        end
        self.Last_zonenotice_num = self.zonenotice_num
        self.zonenotice:SetActive(true)
        self.zonenotice_text.text = tostring(self.zonenotice_num)
    end

    if self.momentnotice_num == 0 then
        self.momentnotice:SetActive(false)
    else
        if self.Last_momentnotice_num < self.momentnotice_num then
            SoundManager.Instance:Play(257)
        end
        self.Last_momentnotice_num = self.momentnotice_num
        self.momentnotice:SetActive(true)
        self.momentnotice_text.text = tostring(self.momentnotice_num)
    end

    if self.friendnotice_num == 0 then
        self.friendnotice:SetActive(false)
    else
        if self.Last_friendnotice_num < self.friendnotice_num then
            SoundManager.Instance:Play(257)
        end
        self.Last_friendnotice_num = self.friendnotice_num
        self.friendnotice:SetActive(true)
        self.friendnotice_text.text = tostring(self.friendnotice_num)
    end

    if self.chatnotice_num == 0 then
        self.chatnotice:SetActive(false)
    else
        self.chatnotice:SetActive(true)
        self.chatnotice_text.text = tostring(self.chatnotice_num)
    end

    if self.teamnotice_num == 0 then
        self.teamnotice:SetActive(false)
    else
        if self.Last_teamnotice_num < self.teamnotice_num then
            SoundManager.Instance:Play(257)
        end
        self.Last_teamnotice_num = self.teamnotice_num
        self.teamnotice:SetActive(true)
        self.teamnotice_text.text = tostring(self.teamnotice_num)
    end

    if self.mailnotice_num == 0 then
        self.mailnotice:SetActive(false)
    else
        if self.Last_mailnotice_num < self.mailnotice_num then
            SoundManager.Instance:Play(257)
        end
        self.Last_mailnotice_num = self.mailnotice_num
        self.mailnotice:SetActive(true)
        self.mailnotice_text.text = tostring(self.mailnotice_num)
    end

    if self.guildnotice_num == 0 then
        self.guildnotice:SetActive(false)
    else
        self.guildnotice:SetActive(true)
        self.guildnotice_text.text = ""--tostring(self.guildnotice_num)
    end

    EventMgr.Instance:Fire(event_name.mainui_notice_update)
end

function MainuiNoticeView:AddAtiveIcon(data)
    if self.examnotice == nil then return end
    self.examnotice:SetActive(true)
    self.examnotice:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, data.iconPath)

    self.examnotice:GetComponent(Button).onClick:AddListener(function() data.clickCallBack() end)
    data.icon = self.examnotice

    if data.text ~= nil then
        local textBG = self.examnotice.transform:FindChild("TextBG").gameObject
        local text = textBG.transform:FindChild("Text"):GetComponent(Text)
        text.text = data.text
        textBG:SetActive(true)
    end

    if data.timestamp ~= nil then
        local timeBG = self.examnotice.transform:FindChild("TimeBG").gameObject
        local timeText = timeBG.transform:FindChild("TimeText"):GetComponent(Text)
        local timeOut = data.timestamp
        local callBack = data.timeoutCallBack
        local timerId = nil
        local fun = function()
            if timeOut >= Time.time then
                timeText.text = self:GetTimeStr(timeOut - Time.time)
            else
                if callBack ~= nil then
                    LuaTimer.Delete(timerId)
                    callBack()
                end
            end
        end
        timerId = LuaTimer.Add(10, 1000, fun)
        data.timerId = timerId
        if timeOut >= Time.time then
            timeText.text = self:GetTimeStr(timeOut - Time.time)
            timeText.gameObject:SetActive(true)
            timeBG:SetActive(true)
        end
    end

    if data.createCallBack ~= nil then
        data.createCallBack(self.examnotice)
    end
end

function MainuiNoticeView:DelAtiveIcon(data)
    if self.examnotice ~= nil then
        self.examnotice:SetActive(false)
    end
end

function MainuiNoticeView:set_zonenotice_num(num)
    self.zonenotice_num = num
    self:update()
end

function MainuiNoticeView:set_momentnotice_num(num)
    self.momentnotice_num = num
    self:update()
end

function MainuiNoticeView:set_friendnotice_num(num)
    self.friendnotice_num = num
    self:update()
end

function MainuiNoticeView:set_chatnotice_num(num)
    self.chatnotice_num = num
    self:update()
end

function MainuiNoticeView:set_teamnotice_num(num)
    self.teamnotice_num = num
    self:update()
end

function MainuiNoticeView:set_mailnotice_num(num)
    self.mailnotice_num = num
    self:update()
end

function MainuiNoticeView:set_guildnotice_num(num)
    self.guildnotice_num = num
    self:update()
end

function MainuiNoticeView:zonenotice_click()
    ZoneManager.Instance:OpenSelfZone({2})
    self.zonenotice_num = 0
    self:update()
end

function MainuiNoticeView:momentnotice_click()
    ZoneManager.Instance:Require11875(0)
    ZoneManager.Instance:OpenSelfZone({1,2})
    self.momentnotice_num = 0
    self:update()
end

function MainuiNoticeView:friendnotice_click()
    if FriendManager.Instance.noReadReq > 0 then
        FriendManager.Instance.model:OpenWindow({2})
    else
        FriendManager.Instance.model:OpenWindow({3})
    end
    self.friendnotice_num = 0
    self:update()
end

function MainuiNoticeView:chatnotice_click()
    if FriendManager.Instance.noReadMsg > 0 then
        FriendManager.Instance.model:OpenWindow({1})
    else
        FriendManager.Instance.model:OpenWindow({3})
    end
    self.chatnotice_num = 0
    self:update()
end

function MainuiNoticeView:teamnotice_click()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {0,1})
    self.teamnotice_num = 0
    self:update()
end

function MainuiNoticeView:mailnotice_click()
    self.mailnotice_num = 0
    self:update()
    FriendManager.Instance.model:OpenWindow({4})
end

function MainuiNoticeView:guildnotice_click()
    self.guildnotice_num = 0
    self:update()
    GuildManager.Instance.model:InitStoreUI()
end

function MainuiNoticeView:guildfightnotice_click()
    -- self.guildfightnotice_num = 0
    -- self:update()
    -- WindowConfig.OpenFunc[WindowConfig.WinID.guildfight_team_window]({})
    GuildfightManager.Instance.model:ShowGuildFightTeamWindow(true,args)
end


function MainuiNoticeView:GetTimeStr(time)
    if time < 60 then
        return string.format(TI18N("剩余%s秒"), math.floor(time))
    elseif time < 3600 then
        return string.format(TI18N("剩余%s分"), math.floor(time/60))
    else
        return string.format(TI18N("剩余%s小时"), math.floor(time/3600))
    end
end

function MainuiNoticeView:activenotice_click()
    UnitStateManager.Instance.model:OpenStatePanel()
end

function MainuiNoticeView:ShowActiceNoticeIcon(bool)
    local mapid = SceneManager.Instance:CurrentMapId()
    if not BaseUtils.isnull(self.activenotice) and bool ~= nil then
        self.activenotice:SetActive(bool and DataAgenda.data_show_active[mapid] ~= nil and not CombatManager.Instance.isFighting)
    end
end

function MainuiNoticeView:MoveActiceNotice(hasHead)
    self.hasHead = hasHead
    -- if hasHead then
    --     if MainUIManager.Instance.playerInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.playerInfoView.transform) then
    --         local pos = MainUIManager.Instance.playerInfoView.transform.anchoredPosition
    --         self.activenoticeRect.anchoredPosition = Vector3(pos.x - (33.5 + 28)-480, self.activenoticeOriginY, 0)
    --     else
    --         self.activenoticeRect.anchoredPosition = Vector3(-327, self.activenoticeOriginY, 0)
    --     end
    -- else
    --     if MainUIManager.Instance.playerInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.playerInfoView.transform) then
    --         local pos = MainUIManager.Instance.playerInfoView.transform.anchoredPosition
    --         self.activenoticeRect.anchoredPosition = Vector3(pos.x + (33.5 - 28)-480, self.activenoticeOriginY, 0)
    --     else
    --         self.activenoticeRect.anchoredPosition = Vector3(-262, self.activenoticeOriginY, 0)
    --     end
    -- end
    self:TraceSwitch(self.isShow)
end

function MainuiNoticeView:TraceSwitch(isshow)
    if BaseUtils.isnull(self.gameObject) then return end
    
    if isshow then
        if self.hasHead then
            Tween.Instance:Move(self.activenoticeRect, Vector3(-327, self.activenoticeOriginY, 0), 0.2, nil)
        else
            Tween.Instance:Move(self.activenoticeRect, Vector3(-262, self.activenoticeOriginY, 0), 0.2, nil)
        end
    else
        if self.hasHead then
            Tween.Instance:Move(self.activenoticeRect, Vector3(-138.5, self.activenoticeOriginY, 0), 0.2, nil)
        else
            Tween.Instance:Move(self.activenoticeRect, Vector3(-70, self.activenoticeOriginY, 0), 0.2, nil)
        end
    end
    self.isShow = isshow
end

function MainuiNoticeView:AdaptIPhoneX()
    -- if MainUIManager.Instance.adaptIPhoneX then
    --     if Screen.orientation == ScreenOrientation.LandscapeRight then
    --         self.activenoticeOriginY = -113
    --     else
    --         self.activenoticeOriginY = -124
    --     end
    -- else
    --     self.activenoticeOriginY = -124
    -- end

    -- self:TraceSwitch(self.isShow)
    BaseUtils.AdaptIPhoneX(self.transform)
end
