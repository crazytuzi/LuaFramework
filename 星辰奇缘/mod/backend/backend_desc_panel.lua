-- @author 黄耀聪
-- @date 2016年10月10日

BackendDescPanel = BackendDescPanel or BaseClass(BasePanel)

function BackendDescPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendDescPanel"
    self.mgr = BackendManager.Instance

    self.resList = {
        {file = AssetConfig.backend_desc_panel, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
        {file = AssetConfig.guidesprite, type = AssetType.Main},
        {file = AssetConfig.dailyicon, type = AssetType.Dep},
    }

    self.timeString = TI18N("活动剩余时间:<color='#00ff00'>%s</color>")
    self.timeString2 = TI18N("活动已结束")
    self.timeFormat1 = TI18N("%s日%s小时")
    self.timeFormat2 = TI18N("%s小时%s分")
    self.timeFormat3 = TI18N("%s分%s秒")
    self.timeFormat4 = TI18N("%s秒")

    self.bigbgToFile = {
        ["BackendWantedI18N"] = AssetConfig.bigatlas_backend_wanted_bg,
    }

    for _,v in pairs(self.bigbgToFile) do
        table.insert(self.resList, {file = v, type = AssetType.Main})
    end

    self.days = 0
    self.hours = 0
    self.minutes = 0
    self.seconds = 0

    self.tickListener = function() self:OnTime() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendDescPanel:__delete()
    self.OnHideEvent:Fire()
    if self.talkDescExt ~= nil then
        self.talkDescExt:DeleteMe()
        self.talkDescExt = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_desc_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    t.anchoredPosition = Vector2.zero
    self.transform = t

    self.bgContainer = t:Find("Title/Bg")
    self.talkDescText = t:Find("TalkBg/Desc"):GetComponent(Text)
    self.talkDescExt = MsgItemExt.New(self.talkDescText, 237, 18, 21)
    self.timeText = t:Find("TalkBg/Time/Text"):GetComponent(Text)
    self.btn = t:Find("Button"):GetComponent(Button)
    self.btnText = t:Find("Button/Text"):GetComponent(Text)
    self.targetImage = t:Find("TalkBg/Light/Image"):GetComponent(Image)

    t:Find("Girl"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")
end

function BackendDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendDescPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onTick:AddListener(self.tickListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    self:ReloadList()
    self:OnTime()
end

function BackendDescPanel:OnHide()
    self:RemoveListeners()
end

function BackendDescPanel:RemoveListeners()
    self.mgr.onTick:RemoveListener(self.tickListener)
end

function BackendDescPanel:ReloadList()
    local model = self.model
    local datalist = {}
    local menuData = self.menuData

    self.talkDescExt:SetData(self.menuData.rule_str)
    self.btnText.text = self.btnSplitList[1]

    local obj = nil
    if self.bigbgToFile[menuData.top_banner] ~= nil then
        obj = GameObject.Instantiate(self:GetPrefab(self.bigbgToFile[menuData.top_banner]))
    else
        obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_backend_wanted_bg))
    end
    UIUtils.AddBigbg(self.bgContainer, obj)
    obj.transform.anchorMax = Vector2(0.5, 1)
    obj.transform.anchorMin = Vector2(0.5, 1)
    obj.transform.pivot = Vector2(0.5, 1)
    obj.transform.anchoredPosition = Vector2(0, -5)

    local splitStringList = StringHelper.Split(menuData.tran_info, "|")
    self.btn.onClick:RemoveAllListeners()
    if splitStringList[1] == "1" then
        local tab = {}
        local windowId = tonumber(splitStringList[2])
        for i=3,#splitStringList do
            table.insert(tab, tonumber(splitStringList[i]))
        end
        self.btn.onClick:AddListener(function()
            WindowManager.Instance:OpenWindowById(windowId, tab)
        end)
    else
        self.btn.onClick:AddListener(function()
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.backend)
            QuestManager.Instance.model:FindNpc(splitStringList[2])
        end)
    end

    self.targetImage.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, menuData.title_ico)
end

function BackendDescPanel:OnTime()
    local model = self.model
    -- local end_time = self.menuData.end_time

    self.days, self.hours, self.minutes, self.seconds = BaseUtils.time_gap_to_timer(self.menuData.end_time - BaseUtils.BASE_TIME)
    if self.days > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat1, tostring(self.days), tostring(self.hours)))
    elseif self.hours > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat2, tostring(self.hours), tostring(self.minutes)))
    elseif self.hours > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat3, tostring(self.minutes), tostring(self.seconds)))
    elseif self.hours > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat4, tostring(self.seconds)))
    else
        self.timeText.text = self.timeString2
    end
end


