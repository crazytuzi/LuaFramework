-- @author zgs
SettingWindow = SettingWindow or BaseClass(BaseWindow)

function SettingWindow:__init(model)
    self.model = model
    self.name = "SettingWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.url = "http://gm.3k.com/?page_code=2&game_id=3"

    self.resList = {
        {file = AssetConfig.setting, type = AssetType.Main},
        {file = AssetConfig.pet_textures,type = AssetType.Dep},
        {file = AssetConfig.shareicon, type = AssetType.Dep},
        {file = AssetConfig.settingres, type  =  AssetType.Dep},
    }

    self.selectedTabIndex = 1 -- 1 = 系统设置，

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    -- self.listener = function() self:UpdateTab() end

    -- self.lockpanel = LockScreenPanel.New()
    self.updatenoticeWin = nil

    self.shareMainPanel = nil
    self.shareBindPanel = nil

    self.rollbackBut = nil

    self.bigbgPanel_fuli = nil
    self.bigbgPanel_haoli = nil
end

function SettingWindow:OnShow()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil and tonumber(self.openArgs[1]) ~= nil then
        self.selectedTabIndex = tonumber(self.openArgs[1])
    end
    if self.tabGroup ~= nil then
        self.tabGroup:ChangeTab(self.selectedTabIndex)
    end

    -- if BaseUtils.GetLocation() == KvData.localtion_type.cn and ctx.PlatformChanleId ~= 110 then
        -- EventMgr.Instance:AddListener(event_name.share_info_update, self.listener)
        -- ShareManager.Instance:Send17502()
    -- end
    self.tHideTransformLooks.isOn = not SceneManager.Instance.sceneElementsModel.Show_Transform_Mark

    self:CheckRed()
end

function SettingWindow:OnHide()
    -- EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
end

function SettingWindow:OnInitCompleted()
    self:OnShow()
end

function SettingWindow:__delete()
    -- EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
    if self.shareMainPanel ~= nil then
        self.shareMainPanel:DeleteMe()
        self.shareMainPanel = nil
    end

    if self.shareBindPanel ~= nil then
        self.shareBindPanel:DeleteMe()
        self.shareBindPanel = nil
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.updatenoticeWin ~= nil then
        self.updatenoticeWin:DeleteMe()
        self.updatenoticeWin = nil
    end

    if self.bigbgPanel_fuli ~= nil then
        self.bigbgPanel_fuli:DeleteMe()
        self.bigbgPanel_fuli = nil
    end

    if self.bigbgPanel_haoli ~= nil then
        self.bigbgPanel_haoli:DeleteMe()
        self.bigbgPanel_haoli = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.gaWin = nil
    self.model = nil
end

function SettingWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.setting))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:Find("Main")

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)

    self.tabGroupObj = self.gameObject.transform:Find("Main/TabButtonGroup").gameObject
    self.setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 20, 1, 50, 999, 999, 999},
        levelLimit = {0, 0, 20, 0, 0, 0, 0},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }

    if not ShareManager.Instance:IsOpen() then
        self.setting.openLevel = {0, 20, 999, 999, 999, 999, 999}
    end


    if BaseUtils.IsVerify then
        self.setting.openLevel[3] = 999
        self.setting.openLevel[4] = 999
    end

    if BaseUtils.GetLocation() ~= KvData.localtion_type.cn or ctx.PlatformChanleId == 110 or ctx.PlatformChanleId == 33 then
        self.setting.openLevel[5] = 1
    end

    self:OpenHaoli()        --优先开豪礼
    self:OpenFuli()

    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:UpdateWindow(index) end, self.setting)
    self.tabGroup.buttonTab[7].normal.transform:Find("Text"):GetComponent(Text).text = TI18N("公\n布")
    self.tabGroup.buttonTab[7].select.transform:Find("Text"):GetComponent(Text).text = TI18N("公\n布")

    self.titleText = self.transform:Find("Main/Title/Text"):GetComponent(Text)

    self.Maincontent = self.transform:Find("Main").gameObject

    self.content = self.transform:Find("Main/SystemSettingContent")

    self.container2 = self.content:Find("Container2").gameObject
    self.container2Rect = self.container2:GetComponent(RectTransform)
    self.container1 = self.content:Find("Container").gameObject
    self.container1Rect = self.container1:GetComponent(RectTransform)

    self.tMusic = self.content:Find("ToggleMusic"):GetComponent(Toggle)
    self.tVolume = self.content:Find("ToggleVolume"):GetComponent(Toggle)
    self.tLowerFrame = self.content:Find("Container2/ScrollRect2/Container2/ToggleLowerFrame"):GetComponent(Toggle)
    self.tHideEffect = self.content:Find("Container2/ScrollRect2/Container2/ToggleHideEffect"):GetComponent(Toggle)
    self.tAddFriend = self.content:Find("Container2/ScrollRect2/Container2/ToggleAddFriend"):GetComponent(Toggle)
    self.tAddFriend.gameObject.transform:Find("LabelI18N"):GetComponent(Text).text = TI18N("不接收好友请求")
    self.tHidePerson = self.content:Find("Container2/ScrollRect2/Container2/ToggleHidePerson"):GetComponent(Toggle)
    self.tHidePersonRide = self.content:Find("Container2/ScrollRect2/Container2/ToggleHidePersonRide"):GetComponent(Toggle)
    self.tHidePersonRide.gameObject.transform:Find("LabelI18N"):GetComponent(Text).text = TI18N("屏蔽坐骑及传音特效")
    self.tPush = self.content:Find("Container2/ScrollRect2/Container2/TogglePush"):GetComponent(Toggle)
    self.tHideTransformLooks = self.content:Find("Container2/ScrollRect2/Container2/ToggleHideTransformLooks"):GetComponent(Toggle)
    self.tRefusingStrangers = self.content:Find("Container2/ScrollRect2/Container2/ToggleRefusingStrangers"):GetComponent(Toggle)
    self.tTeamVoice = self.content:Find("ToggleTeamVoice"):GetComponent(Toggle)
    self.tGuildVoice = self.content:Find("ToggleGuildVoice"):GetComponent(Toggle)
    self.tWorldVoice = self.content:Find("ToggleWorldVoice"):GetComponent(Toggle)
    self.tTeamChannel = self.content:Find("ToggleTeamChannel"):GetComponent(Toggle)
    self.tSceneChannel = self.content:Find("ToggleSceneChannel"):GetComponent(Toggle)
    self.tWorldChannel = self.content:Find("ToggleWorldChannel"):GetComponent(Toggle)
    self.tGuildChannel = self.content:Find("ToggleGuildChannel"):GetComponent(Toggle)

    self.sMusic = self.content:Find("SliderMusic"):GetComponent(Slider)
    self.sVolume = self.content:Find("SliderVolume"):GetComponent(Slider)
    self.sVoice = self.content:Find("SliderVoice"):GetComponent(Slider)

    self.tRefusingStrangers.onValueChanged:AddListener(function()
        self:on_click_tRefusingStrangers()
    end)

    self.tHideTransformLooks.onValueChanged:AddListener(function()
        self:on_click_tHideTransformLooks()
    end)

    self.tPush.onValueChanged:AddListener(function()
        self:on_click_tPush()
    end)

    self.tMusic.onValueChanged:AddListener( function()
        self:on_click_tMusic()
    end)
    self.tVolume.onValueChanged:AddListener( function()
        self:on_click_tVolume()
    end)
    self.tLowerFrame.onValueChanged:AddListener( function()
        self:on_click_tLowerFrame()
    end)
    self.tHideEffect.onValueChanged:AddListener( function()
        self:on_click_tHideEffect()
    end)
    self.tAddFriend.onValueChanged:AddListener( function()
        self:on_click_tAddFriend()
    end)
    self.tHidePerson.onValueChanged:AddListener( function()
        self:on_click_tHidePerson()
    end)
    self.tHidePersonRide.onValueChanged:AddListener( function()
        self:on_click_tHidePersonRide()
    end)
    self.tTeamVoice.onValueChanged:AddListener( function()
        self:on_click_tTeamVoice()
    end)
    self.tGuildVoice.onValueChanged:AddListener( function()
        self:on_click_tGuildVoice()
    end)
    self.tWorldVoice.onValueChanged:AddListener( function()
        self:on_click_tWorldVoice()
    end)
    self.tTeamChannel.onValueChanged:AddListener( function()
        self:on_click_tTeamChannel()
    end)
    self.tSceneChannel.onValueChanged:AddListener( function()
        self:on_click_tSceneChannel()
    end)
    self.tWorldChannel.onValueChanged:AddListener( function()
        self:on_click_tWorldChannel()
    end)
    self.tGuildChannel.onValueChanged:AddListener( function()
        self:on_click_tGuildChannel()
    end)

    self.sMusic.onValueChanged:AddListener( function()
        self:on_vc_sMusic()
    end)
    self.sVolume.onValueChanged:AddListener( function()
        self:on_vc_sVolume()
    end)
    self.sVoice.onValueChanged:AddListener( function()
        self:on_vc_sVoice()
    end)

    self.connectGmBtn = self.content:Find("Button"):GetComponent(Button)
    self.connectGmBtn.onClick:AddListener(function()
            --联系gm
            self:ShowConnectGM()
        end)
    if BaseUtils.IsVerify or BaseUtils.IsIosVest() then
        self.connectGmBtn.gameObject:SetActive(false)
    end
    if ctx.PlatformChanleId == 22 then
        self.connectGmBtn.gameObject:SetActive(false)
    end
    self.cleanBtn = self.content:Find("CleanButton"):GetComponent(Button)
    self.content:Find("CleanButton/Text"):GetComponent(Text).text = TI18N("解决卡机")
    self.cleanBtn.onClick:AddListener(function()
            self:OnClickClean()
        end)
    self.lockBtn = self.content:Find("LockButton"):GetComponent(Button)
    self.lockBtn.onClick:AddListener(function()
            self:OnClickLockScreen()
        end)
    self.cmdsetBtn = self.content:Find("CmdSetButton"):GetComponent(Button)
    self.cmdsetBtn.onClick:AddListener(function()
            CombatManager.Instance:OpenCmdSetting()
        end)
    -- self.languageBtn = self.content:Find("RightBottom/Button"):GetComponent(Button)
    -- self.languageBtn.onClick:AddListener(function()
    --         NoticeManager.Instance:FloatTipsByString("游戏暂时只支持一种语言")
    --     end)

    -- 版本修复
    self.rollbackBut = self.content:Find("RollbackButton"):GetComponent(Button)
    self.rollbackBut.onClick:AddListener(function()
        self:OnClickRollback()
    end)

    -- 复制绑定ID（GUID）
    self.copyGUIDButton = self.content:Find("CopyGUIDButton"):GetComponent(Button)
    self.copyGUIDButton.onClick:AddListener(function()
            Utils.CopyTextToClipboard(SdkManager.Instance.guid)
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("绑定ID复制成功（%s）"), SdkManager.Instance.guid))
        end)
    if SdkManager.Instance.guid ~= nil and SdkManager.Instance.guid ~= 0 and SdkManager.Instance.guid ~= "" then
        self.copyGUIDButton.gameObject:SetActive(true)
    else
        self.copyGUIDButton.gameObject:SetActive(false)
    end

    self.connectGMContent = self.transform:Find("ConnectGM")
    self.subCloseBtn = self.connectGMContent:Find("Main/CloseButton"):GetComponent(Button)
    self.subCloseBtn.onClick:AddListener(function()
            self:CloseConnetPanel()
        end)

    self.connectGMContent:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
            self:CloseConnetPanel()
        end)
    self.inputField = self.connectGMContent:Find("Main/InputField"):GetComponent(InputField)
    self.inputField.onValueChange:AddListener( function()
        self:on_vc_inputField()
    end)
    self.inputCount = self.connectGMContent:Find("Main/Text"):GetComponent(Text)
    self.inputCount.text = string.format("%d/150",string.utf8len(self.inputField.text))
    self.submitBtn = self.connectGMContent:Find("Main/Button"):GetComponent(Button)
    self.submitBtn.gameObject:SetActive(true)
    self.submitBtn.onClick:AddListener(function()
            self:SubmitContent()
        end)
    self.submitBtnRect = self.submitBtn.gameObject:GetComponent(RectTransform)

    self.linkBtn = self.connectGMContent:Find("Main/Button2"):GetComponent(Button)
    self.linkBtn.onClick:AddListener(function()
        self:OpenGMOnlineURL()
    end)
    self.linkBtnObj = self.linkBtn.gameObject
    self.linkBtnRect = self.linkBtnObj:GetComponent(RectTransform)

    self.qqInputField = self.connectGMContent:Find("Main/QQInputField"):GetComponent(InputField)
    self.connectGMContent.gameObject:SetActive(false)

    self.qqDesc = self.qqInputField.gameObject.transform:Find("Placeholder"):GetComponent(Text)
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        self.qqDesc.text = ""
    else
        if ctx.PlatformChanleId == 13 then
            self.qqDesc.text = ""
        else
            self.qqDesc.text = TI18N("请填写你的联系QQ")
        end
    end

    self.wechat = self.content:Find("Container/Btn1").gameObject
    self.timeline = self.content:Find("Container/Btn2").gameObject
    self.qq = self.content:Find("Container/Btn3").gameObject
    self.weibo = self.content:Find("Container/Btn4").gameObject

    self.wechat:GetComponent(Button).onClick:AddListener(function() ShareManager.Instance.model:TOWeChat() end)
    self.timeline:GetComponent(Button).onClick:AddListener(function() ShareManager.Instance.model:TOWeChatTimeline() end)
    self.weibo:GetComponent(Button).onClick:AddListener(function() ShareManager.Instance.model:TOWeibo() end)
    self.qq:GetComponent(Button).onClick:AddListener(function() ShareManager.Instance.model:TOQQ() end)

    -- if Application.platform == RuntimePlatform.Android then
    if Application.platform == RuntimePlatform.IPhonePlayer and not BaseUtils.IsVerify and not BaseUtils.IsIosVest() then -- 马甲包没有分享的控件和配置，不能开分享
        self.container1:SetActive(true)
        self.container2Rect.anchoredPosition = Vector2(-200, -54)
    else
        self.container2Rect.anchoredPosition = Vector2(-200, -96)
        self.container1:SetActive(false)
    end

    self:CheckPlatform()

    self.content:Find("RightCenter").gameObject:SetActive(false)
    self.tTeamChannel.gameObject:SetActive(false)
    self.tGuildChannel.gameObject:SetActive(false)
    self.tWorldChannel.gameObject:SetActive(false)
    self.tSceneChannel.gameObject:SetActive(false)

end

--锁定屏幕
function SettingWindow:OnClickLockScreen()
    self:OnClickClose()
    SettingManager.Instance.lockpanel:Show()
end

function SettingWindow:OnClickClean()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("解决卡机后游戏将会自动关闭，请<color='#ffff00'>重新启动</color>")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function ()
        -- -- print("--------")
        LoginManager.Instance:send1020()
        Application.Quit()
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function SettingWindow:OnClickRollback()
    -- 判断C#版本
    if not UtilsIO then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("当前版本不支持该功能，需要安装最新应用")
        data.sureLabel = TI18N("确认")
        NoticeManager.Instance:ConfirmTips(data)
        return
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("此操作仅限于特殊情况下使用，修正后客户端将<color='#ffff00'>重新加载更新内容</color>，请在客服指引下慎重使用，是否继续？")
    -- data.cancelSecond = 30
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        self:DoRollback()
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function SettingWindow:DoRollback()
    local url = ctx.PatchPath .. "/patch_list.json?version=" .. ctx.ResVersion
    local callback = function(msg)
        if string.find(msg, "error:") ~= nil then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            data.content = TI18N("读取版本信息出错：" .. msg .. " 请重试")
            data.sureLabel = TI18N("确认")
            NoticeManager.Instance:ConfirmTips(data)
            return
        end
        local JsonData = NormalJson(msg)
        local resVerion = ctx.ResVersion
        -- 比较大小，7M以上算大版本
        local compareSize = 1024 * 1024 * 7 * 0.7
        local matchVersion = nil
        if JsonData.table ~= nil then
            local size = #JsonData.table
            local find = false
            for i = size, 1, -1 do
                local info = JsonData.table[i]
                if find then
                    matchVersion = info.version
                    break
                end
                if tonumber(info.size) > compareSize then
                    if info.version <= resVerion then
                        find = true
                    end
                end
            end
            if matchVersion == nil then
                matchVersion = "notfind"
            end
            local callback = function(msg)
                local succ = true
                local content = TI18N("修复成功，请重启游戏")
                if msg ~= "true" then
                    content = TI18N("操作失败，请联系客服")
                    succ = false
                end
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Sure
                data.content = content
                data.sureLabel = TI18N("确认")
                data.sureCallback = function()
                    if succ then
                        Application.Quit()
                    end
                end
                NoticeManager.Instance:ConfirmTips(data)
                return
            end
            UtilsIO.RollbackResVersion(matchVersion, callback, 3)
        end
    end
    ctx:GetRemoteTxt(url, callback, 3)
end

function SettingWindow:on_vc_inputField()
    -- body
    self.inputCount.text = string.format("%d/150",string.utf8len(self.inputField.text))
end

function SettingWindow:trim (s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function SettingWindow:SubmitContent()
    -- body
    local contentTemp = self:trim(self.inputField.text)
    local qq = self.qqInputField.text
    if contentTemp == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先输入问题或建议再提交"))
    else
        SettingManager.Instance:send14700(contentTemp,qq)
    end
end

function SettingWindow:CloseConnetPanel()
    -- body
    self.connectGMContent.gameObject:SetActive(false)
end

function SettingWindow:ShowConnectGM()
    -- body
    self.inputField.text = ""
    self.connectGMContent.gameObject:SetActive(true)
end


-- 不接收陌生人切磋邀请
function SettingWindow:on_click_tRefusingStrangers()
    --不接收陌生人切磋请求
    if self.tRefusingStrangers.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TRefusingStrangers,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TRefusingStrangers,0)
    end
    print(SettingManager.Instance:GetResult(SettingManager.Instance.TRefusingStrangers))
end

-- 变身显示原外观开关
function SettingWindow:on_click_tHideTransformLooks()
    local curr = not SceneManager.Instance.sceneElementsModel.Show_Transform_Mark
    if curr ~= self.tHideTransformLooks.isOn then
        if self.tHideTransformLooks.isOn then
            BuffPanelManager.Instance:send12802(0)
        else
            BuffPanelManager.Instance:send12802(1)
        end
    end
end

-- 私聊消息推送开关
function SettingWindow:on_click_tPush()
    local curr = (FriendManager.Instance.offline_push == 1)
    if curr ~= self.tPush.isOn then
        if self.tPush.isOn then
            FriendManager.Instance:Require11888(1)
        else
            FriendManager.Instance:Require11888(0)
        end
    end
end

function SettingWindow:on_click_tMusic()
    -- body
    --音乐开关
    if self.tMusic.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TMusic,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TMusic,0)
    end
    SoundManager.Instance:SetMusicIsCan(SettingManager.Instance:GetResult(SettingManager.Instance.TMusic))
end

function SettingWindow:on_vc_sMusic()
    -- body
    --音乐音量
    SettingManager.Instance:SetResult(SettingManager.Instance.SliderMusic,self.sMusic.value,2)
    SoundManager.Instance:SetMusicValue(SettingManager.Instance:GetResult(SettingManager.Instance.SliderMusic,2))
end

function SettingWindow:on_click_tVolume()
    -- body
    --音效开关
    --Log.Error("on_click_tVolume="..tostring(self.tVolume.isOn))
    if self.tVolume.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TVolume,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TVolume,0)
    end
    SoundManager.Instance:SetVolumeIsCan(SettingManager.Instance:GetResult(SettingManager.Instance.TVolume))
end

function SettingWindow:on_vc_sVolume()
    -- body
    --音效音量
    SettingManager.Instance:SetResult(SettingManager.Instance.SliderVolume,self.sVolume.value,2)
    SoundManager.Instance:SetVolumeValue(SettingManager.Instance:GetResult(SettingManager.Instance.SliderVolume,2))
end

function SettingWindow:on_vc_sVoice()
    -- body
    --语音音量
    SettingManager.Instance:SetResult(SettingManager.Instance.SliderVoice,self.sVoice.value,2)
    SoundManager.Instance:SetChatVolumeValue(SettingManager.Instance:GetResult(SettingManager.Instance.SliderVoice, 2))
end

function SettingWindow:setFrame()
    if self.model.isLowerFrame == true then
        --
        if Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android then
            Application.targetFrameRate = 30
        end
    else
        if Application.platform == RuntimePlatform.IPhonePlayer then
            Application.targetFrameRate = 60
        elseif Application.platform == RuntimePlatform.Android then
            Application.targetFrameRate = 45
        end
    end
end

function SettingWindow:on_click_tLowerFrame()
    if self.tLowerFrame.isOn == true then
        self.model.isLowerFrame = true
    else
       self.model.isLowerFrame = false
    end
    self:setFrame()
end

function SettingWindow:on_click_tHideEffect()
    if self.tHideEffect.isOn ~= SettingManager.Instance:GetResult(SettingManager.Instance.THideEffect) then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("1.圣心城每天<color='#ffff00'>18:00-23:00</color>下雪喔{face_1,56}\n2.若出现卡顿或闪退可勾选屏蔽")
        data.sureLabel = TI18N("确定")
        data.sureCallback = function()

        end
        NoticeManager.Instance:ConfirmTips(data)
    end

    --隐藏场景特效
    if self.tHideEffect.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.THideEffect,1)
        --self.tHideEffect.isOn = false
        --NoticeManager.Instance:FloatTipsByString("该功能暂未开放")
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.THideEffect,0)
    end
    SceneManager.Instance.sceneModel:ShowEffect()
    --true = 不屏蔽
    --false = 屏蔽
    -- SceneManager.Instance.MainCamera:set_effectmask(not SettingManager.Instance:GetResult(SettingManager.Instance.THideEffect))

end

function SettingWindow:on_click_tAddFriend()
    --不接收好友请求 //--好友验证
    if self.tAddFriend.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TAddFriend,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TAddFriend,0)
        -- self.tAddFriend.isOn = true
        -- NoticeManager.Instance:FloatTipsByString("该功能暂未开放")
    end
    FriendManager.Instance.reject = SettingManager.Instance:GetResult(SettingManager.Instance.TAddFriend)
end

function SettingWindow:on_click_tHidePerson()
    --同屏
    if self.tHidePerson.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.THidePerson,1)
        --self.tHidePerson.isOn = false
        --NoticeManager.Instance:FloatTipsByString("该功能暂未开放")
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.THidePerson,0)
    end
    --true = 限制
    --false = 不限制
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson))

    EventMgr.Instance:Fire(event_name.setting_change, SettingManager.Instance.THidePerson, SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson))
end

function SettingWindow:on_click_tHidePersonRide()
    --隐藏他人坐骑
    if self.tHidePersonRide.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.THidePersonRide,0)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.THidePersonRide,1)
    end
    --true = 隐藏
    --false = 不隐藏
    SceneManager.Instance.sceneElementsModel:Show_OtherRole_Ride(SettingManager.Instance:GetResult(SettingManager.Instance.THidePersonRide))

    EventMgr.Instance:Fire(event_name.setting_change, SettingManager.Instance.THidePersonRide, SettingManager.Instance:GetResult(SettingManager.Instance.THidePersonRide))
end

function SettingWindow:on_click_tTeamVoice()
    --队伍语音
    if self.tTeamVoice.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TTeamVoice,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TTeamVoice,0)
    end
    ChatManager.Instance.autoPlayTeam = self.tTeamVoice.isOn
end

function SettingWindow:on_click_tGuildVoice()
    --公会语音
    if self.tGuildVoice.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TGuildVoice,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TGuildVoice,0)
    end
    ChatManager.Instance.autoPlayGuild = self.tGuildVoice.isOn
end

function SettingWindow:on_click_tWorldVoice()
    --世界语音
    if self.tWorldVoice.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TWorldVoice,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TWorldVoice,0)
    end
    ChatManager.Instance.autoPlayWorld = self.tWorldVoice.isOn
end

function SettingWindow:on_click_tTeamChannel()
    --队伍频道
    if self.tTeamChannel.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TTeamChannel,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TTeamChannel,0)
    end
end

function SettingWindow:on_click_tSceneChannel()
    --场景频道
    if self.tSceneChannel.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TSceneChannel,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TSceneChannel,0)
    end
end

function SettingWindow:on_click_tWorldChannel()
    --世界频道
    if self.tWorldChannel.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TWorldChannel,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TWorldChannel,0)
    end
end

function SettingWindow:on_click_tGuildChannel()
    --公会频道
    if self.tGuildChannel.isOn == true then
        SettingManager.Instance:SetResult(SettingManager.Instance.TGuildChannel,1)
    else
        SettingManager.Instance:SetResult(SettingManager.Instance.TGuildChannel,0)
    end
end

function SettingWindow:UpdateWindow(index)
    self.selectedTabIndex = index
    if self.selectedTabIndex == 1 then
        self:Reset()
        self.model:SetUpdateNoticeRedPoint(self.model.isNeedShowRedPointUpdateNotice)

        self.content.gameObject:SetActive(true)
        self:UpdateSystemSetting()
    elseif self.selectedTabIndex == 2 then
        self:Reset()
        self.model:SetUpdateNoticeRedPoint(self.model.isNeedShowRedPointUpdateNotice)
        --更新公告
        self.model:SetUpdateNoticeRedPoint(false)
        self.titleText.text = TI18N("更新公告")
        if self.updatenoticeWin == nil then
            self.updatenoticeWin = UpdateNoticePanel.New(self.model,self.Maincontent)
        end
        self.updatenoticeWin:Show()
    elseif self.selectedTabIndex == 3 then
        self.selectedTabIndex = 1
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.share_bind)
    elseif self.selectedTabIndex == 4 then
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.share_main)
        self:Reset()
        if self.shareMainPanel == nil then
            self.shareMainPanel = ShareMainPanel.New(self)
        end
        self.titleText.text = TI18N("邀请推广")
        self.shareMainPanel:Show()
    elseif self.selectedTabIndex == 5 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("是否要切换帐号"))
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function ()
            self:Hide()
            LuaTimer.Add(100, function() SdkManager.Instance:ChangeAccount() end)
        end
        NoticeManager.Instance:ConfirmTips(data)
    elseif self.selectedTabIndex == 6 then
        self:Reset()

        if self.bigbgPanel_fuli == nil then
            self.bigbgPanel_fuli = BigBgPanel.New(self.model,self.Maincontent,AssetConfig.GameBgTwo)
        end

        self.bigbgPanel_fuli:Show()
    elseif self.selectedTabIndex == 7 then
        self:Reset()

        if self.bigbgPanel_haoli == nil then
            self.bigbgPanel_haoli = BigBgPanel.New(self.model,self.Maincontent,AssetConfig.twoyearbigbg)
        end

        self.bigbgPanel_haoli:Show()
    end

    -- self.closeBtn.gameObject.transform:SetSiblingIndex(self.closeBtn.gameObject.transform.parent.childCount - 1);
end

function SettingWindow:SetUpdateNoticeRedPoint(bo)
    if self.tabGroup ~= nil then
        self.tabGroup:ShowRed(2,bo)
    end
end

function SettingWindow:Reset()
    self.content.gameObject:SetActive(false)
    if self.updatenoticeWin ~= nil then
        self.updatenoticeWin:Hiden()
    end
    if self.shareBindPanel ~= nil then
        self.shareBindPanel:Hiden()
    end
    if self.shareMainPanel ~= nil then
        self.shareMainPanel:Hiden()
    end

    if self.bigbgPanel_fuli ~= nil then
        self.bigbgPanel_fuli:Hiden()
    end

    if self.bigbgPanel_haoli ~= nil then
        self.bigbgPanel_haoli:Hiden()
    end
end

--系统设置
function SettingWindow:UpdateSystemSetting()
    -- body
    self.titleText.text = TI18N("系统设置")

    self.tMusic.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TMusic)
    self.tVolume.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TVolume)
    self.tLowerFrame.isOn = self.model.isLowerFrame
    self.tRefusingStrangers.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TRefusingStrangers)
    self.tHideEffect.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.THideEffect)
    self.tAddFriend.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TAddFriend)
    self.tHidePerson.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson)
    self.tHidePersonRide.isOn = not SettingManager.Instance:GetResult(SettingManager.Instance.THidePersonRide)
    self.tTeamVoice.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TTeamVoice)
    self.tGuildVoice.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TGuildVoice)
    self.tWorldVoice.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TWorldVoice)
    self.tTeamChannel.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TTeamChannel)
    self.tSceneChannel.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TSceneChannel)
    self.tWorldChannel.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TWorldChannel)
    self.tGuildChannel.isOn = SettingManager.Instance:GetResult(SettingManager.Instance.TGuildchannel)
    self.tPush.isOn = (FriendManager.Instance.offline_push == 1)

    self.sMusic.value = SettingManager.Instance:GetResult(SettingManager.Instance.SliderMusic,1)
    self.sVolume.value = SettingManager.Instance:GetResult(SettingManager.Instance.SliderVolume,1)
    self.sVoice.value = SettingManager.Instance:GetResult(SettingManager.Instance.SliderVoice,1)
end

function SettingWindow:OnClickClose()
    self.model:CloseMain()
end

-- 根据状态更新右侧标签
function SettingWindow:UpdateTab()
    self.setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 20, 1, 50, 999, 999, 999},
        levelLimit = {0, 0, 20, 0, 0, 0, 0},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }

    if ShareManager.Instance.shareData.apply_key == "" then
        self.setting.openLevel = {0, 20, 1, 50, 999, 999, 999}
        self.setting.levelLimit = {0, 0, 20, 0, 0, 0, 0}
    else
        self.setting.openLevel = {0, 20, 1, 50, 999, 999, 999}
        self.setting.levelLimit = {0, 0, 0, 0, 0, 0, 0}
    end

    if BaseUtils.IsVerify then
        self.setting.openLevel[3] = 999
        self.setting.openLevel[4] = 999
    end


    self:OpenHaoli()    --优先开豪礼
    self:OpenFuli()

    self.tabGroup:UpdateSetting(self.setting)
    self.tabGroup:Layout()
end

function SettingWindow:CheckRed()
    local bool = ShareManager.Instance.model.needRed
    self.tabGroup:ShowRed(3, bool)
    self.tabGroup:ShowRed(4, bool)
end

function SettingWindow:CheckPlatform()
    local platform = RoleManager.Instance.RoleData.platform

    -- 去掉乐视
    local show = (platform ~= "mix" or ctx.PlatformChanleId ~= 110)

    -- 乐视特殊处理
    if ctx.PlatformChanleId == 110 and BaseUtils.CSVersionToNum() >= 10608 then
        show = true
    end
    -- if platform == "ios" or platform == "beta" or platform == "local" or platform == "dev" or (platform == "mix" and ctx.PlatformChanleId == 15) then
    -- if platform == "local" or
    --     platform == "dev" or
    --     (platform == "ios" and (BaseUtils.GetLocation() == KvData.localtion_type.cn and BaseUtils.CSVersionToNum() > 20607)) or
    --     platform == "beta" or       -- 3k
    --     platform == "unite" or
    --     -- (platform == "mix" and ctx.PlatformChanleId == 15)  -- 联想
    --     platform == "mix"
    --     then
    --     show = true
    -- end
    if show then
        self.submitBtnRect.anchoredPosition = Vector2(-120, -173)
    else
        self.submitBtnRect.anchoredPosition = Vector2(0, -173)
    end
    self.linkBtn.gameObject:SetActive(show)
end

function SettingWindow:RefreshIndulge()
    local indulgeData = ((RoleManager.Instance.indulgeData or {})[RoleManager.Instance.RoleData.platform] or {})[ctx.PlatformChanleId] or {}
    -- local indulgeData = (RoleManager.Instance.indulgeData or {})[ctx.PlatformChanleId] or {}

    if indulgeData.is_show_phone == 1 then
        return true
    else
        return false
    end
end

function SettingWindow:OpenFuli()
    local num = 0
    for i1,v1 in ipairs(self.setting.openLevel) do
        if RoleManager.Instance.RoleData.lev >= v1 then
            if self.setting.levelLimit[i1] == 0 or (RoleManager.Instance.RoleData.lev <= self.setting.levelLimit[i1]  ) then
                num = num + 1
            end
        end
    end
    -- print("就进入了这里" .. num)
    if num <= 3 and self:RefreshIndulge() == true then
        self.setting.openLevel[6] = 0
    else
        self.setting.openLevel[6] = 999
    end

end


function SettingWindow:OpenHaoli()
    self.setting.openLevel[7] = 999

    -- BaseUtils.dump(self.setting.openLevel,"OpenLevel")
    -- BaseUtils.dump(self.setting.levelLimit,"LevelLimit")

    local num = 0
    for i,v in ipairs(self.setting.openLevel) do
        if RoleManager.Instance.RoleData.lev >= v then
            if self.setting.levelLimit[i] == 0 or (RoleManager.Instance.RoleData.lev <= self.setting.levelLimit[i]  ) then
                num = num + 1
            end
        end
    end

    -- print(num)
    if num > 3 then return end

    -- print(BaseUtils.BASE_TIME)
    if BaseUtils.BASE_TIME <= 1562299200 then --2019/07/05/12/00/00
        if ctx.PlatformChanleId == 33 or  ctx.PlatformChanleId == 0 or ctx.PlatformChanleId == 74 then
            self.setting.openLevel[7] = 0
        end
    end
end

function SettingWindow:OpenGMOnlineURL()
    local roleData = RoleManager.Instance.RoleData
    -- if Application.platform == RuntimePlatform.Android then
    if true then
        local isNew = false
        local tab = getmetatable(Utils)
	    for k,v in pairs(tab) do
	    	if tostring(k) == "OpenOnlineGmWindow" then
                isNew = true
	    	end
	    end
        if isNew then
            local from_id = ctx.PlatformChanleId
            local server_id = roleData.platform .. "_" .. roleData.zone_id
            local role_id = roleData.platform .. "_" .. roleData.id
            local role_name = roleData.name
            local server_name = self:GetServerName(roleData.zone_id, roleData.platform)
            local level = roleData.lev
            local url = string.format("http://apkcheck.shiyuegame.com/apkcheck_april/gm_online.php?platform=%s&from_id=%s&server_id=%s&role_id=%s&role_name=%s&server_name=%s&level=%s", roleData.platform, from_id, server_id, role_id, role_name, server_name, level)
            if BaseUtils.GetPlatform() == "ios" then
                url = string.format("http://ipacheck.shiyuegame.com/apkcheck_march/gm_online.php?platform=%s&from_id=%s&server_id=%s&role_id=%s&role_name=%s&server_name=%s&level=%s", SettingWindow:UrlEncode(roleData.platform), SettingWindow:UrlEncode(from_id), SettingWindow:UrlEncode(server_id), SettingWindow:UrlEncode(role_id), SettingWindow:UrlEncode(role_name), SettingWindow:UrlEncode(server_name), SettingWindow:UrlEncode(level))
            end
            local callback = function(text)
                local openUrl = "http://gmapi.3k.com/index.php?ct=api&ac=oauth&game_id=3&sign=" .. self:UrlEncode(text)
                SdkManager.Instance:OpenOnlineGmWindow(openUrl)
            end
            ctx:GetRemoteTxt(url, callback, 3)
        else
            Application.OpenURL(self.url)
        end
    else
        Application.OpenURL(self.url)
    end
end

function SettingWindow:UrlEncode(s)
     s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


function SettingWindow:GetServerName(zoneId, platform)
    local list = ServerConfig.servers
    for _, data in ipairs(list) do
        if data.zone_id == zoneId and data.platform == platform then
            return data.name
        end
    end
    return TI18N("未知服")
end
