ApprenticeshipWindow = ApprenticeshipWindow or BaseClass(BaseWindow)

function ApprenticeshipWindow:__init(model)
    self.model = model
    self.mgr = TeacherManager.Instance

    self.windowId = WindowConfig.WinID.apprenticeship
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.teacher_show_window, type = AssetType.Main}
        ,{file = AssetConfig.half_length, type = AssetType.Dep}
        ,{file = AssetConfig.teacher_textures, type = AssetType.Dep}
    }

    self.tabName = {
        {name = TI18N("日常"), icon = "TabIcon01"},
        {name = TI18N("目标"), icon = "TabIcon02"},
        {name = TI18N("关系"), icon = "TabIcon03"}
    }

    self.titleName = {
        TI18N("日常功课"),
        TI18N("徒弟目标"),
        TI18N("关系"),
    }
    self.tabObjList = {}
    self.subPanel = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.onUpdateListener = function() self:OnPersonal() end
    self.checkRedListener = function() self:CheckRed() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.imgLoader = nil
end

function ApprenticeshipWindow:__delete()
    self.OnHideEvent:Fire()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.subPanel ~= nil then
        for k,v in pairs(self.subPanel) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.subPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ApprenticeshipWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teacher_show_window))
    self.gameObject.name = "ApprenticeshipWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform

    local main = t:Find("Main")
    self.nameText = main:Find("InfoArea/Bg/Name"):GetComponent(Text)
    self.levText = main:Find("InfoArea/Bg/Lev"):GetComponent(Text)
    self.forceText = main:Find("InfoArea/Bg/Force"):GetComponent(Text)
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.formImage = main:Find("InfoArea/Form"):GetComponent(Image)
    self.panelContainer = main:Find("PanelContainer")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.chatBtn = main:Find("InfoArea/Bg/Chat"):GetComponent(Button)
    -- self.forceDescText = main:Find("InfoArea/Bg/I18N"):GetComponent(Text)
    self.forceImage = main:Find("InfoArea/Bg/Image"):GetComponent(Image)

    self.tabCloner = main:Find("Button").gameObject
    self.tabContainer = main:Find("TabButtonGroup")

    self.closeBtn.onClick:AddListener(function() self.model:CloseDailyWindow() end)

    local obj = nil
    for i,v in ipairs(self.tabName) do
        if v ~= nil then
            if self.tabObjList[i] == nil then
                obj = GameObject.Instantiate(self.tabCloner)
                obj.name = tostring(i)
                self.tabObjList[i] = obj
                obj:SetActive(true)
                t = obj.transform
                t:Find("Normal/Text"):GetComponent(Text).text = v.name
                t:Find("Select/Text"):GetComponent(Text).text = v.name
                t:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.teacher_textures, v.icon)
                t:SetParent(self.tabContainer)
                t.localScale = Vector3.one
                -- t.localPosition = Vector3(0, (1 - i) * 106, 0)
            end
        end
    end

    local setting = {
        perWidth = 46
        , perHeight = 110
        , isVertical = true
        , notAutoSelect = true
        , noCheckRepeat = true
        , spacing = 0
    }
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, setting)

    self.tabCloner:SetActive(false)
end

function ApprenticeshipWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ApprenticeshipWindow:OnOpen()
    local args = self.openArgs
    if args == nil then
        args = {}
    end

    local index = 1
    if args[2] ~= nil then
        index = args[2]
    end
    if args[1] ~= nil then
        self.model.stuData = args[1]
    end
    self:OnPersonal()

    self:RemoveListeners()
    self.mgr.onUpdateInfo:AddListener(self.onUpdateListener)
    self.mgr.onUpdateDailyRed:AddListener(self.checkRedListener)

    index = self:CheckForShow(index)
    self.tabGroup:Layout()
    self.tabGroup:ChangeTab(index)

    self.mgr:send15806(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)
end

function ApprenticeshipWindow:OnHide()
    self:RemoveListeners()
end

function ApprenticeshipWindow:RemoveListeners()
    self.mgr.onUpdateInfo:RemoveListener(self.onUpdateListener)
    self.mgr.onUpdateDailyRed:RemoveListener(self.checkRedListener)
end

function ApprenticeshipWindow:ChangeTab(index)
    local panel = nil
    if self.lastIndex ~= nil then
        panel = self.subPanel[self.lastIndex]
    end
    if panel ~= nil then
        panel:Hiden()
    end

    panel = self.subPanel[index]
    if panel == nil then
        if index == 1 then
            panel = ApprenticeshipDailyPanel.New(self.model, self.panelContainer)
        elseif index == 2 then
            panel = ApprenticeshipGrowPanel.New(self.model, self.panelContainer)
        elseif index == 3 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window)
            return
        end
        self.subPanel[index] = panel
    end
    self.titleText.text = self.titleName[index]
    self.lastIndex = index
    self.mgr.onUpdateInfo:Fire()
    panel:Show(self.openArgs)
end

function ApprenticeshipWindow:OnPersonal()
    local model = self.model
    local roleData = RoleManager.Instance.RoleData
    local data = nil
    if self.lastIndex == 1 then
        data = model.dailyData[BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)]
    else
        data = model.targetData[BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)]
    end

    if data == nil then
        data = self.model.stuData
    end

    if data.name == nil then data.name = "" end

    self.nameText.text = data.name.."     "
    self.chatBtn.onClick:RemoveAllListeners()

    if data.lev == nil then return end

    self.levText.text = ""
    self.nameText.text = string.format(TI18N("%s  <color=#C7F9FF>%s级</color>"), data.name, tostring(data.lev))
    self.formImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..data.classes..data.sex)
    self.formImage.gameObject:SetActive(true)
    self.chatBtn.onClick:RemoveAllListeners()
    self.chatBtn.onClick:AddListener(function ()
        local pdata = {
            id = data.rid,
            platform = data.platform,
            zone_id = data.zone_id,
            sex = data.sex,
            classes = data.classes,
            lev = data.lev,
            name = data.name,
        }
        FriendManager.Instance:TalkToUnknowMan(pdata)
    end)

    local msg = nil
    if BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id) == BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) then     -- 查看自己的目标
        msg = TI18N("<color='%s'>综合战力:</color>")
        self.forceImage.sprite = self.assetWrapper:GetSprite(AssetConfig.teacher_textures, "Sword")
    else
        msg = TI18N("<color='%s'>贡献师道值:</color>")

        if self.imgLoader == nil then
            self.imgLoader = SingleIconLoader.New(self.forceImage.gameObject)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, 90019)

        for _,v in pairs(self.model.teacherStudentList.list) do
            if BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) == BaseUtils.Key(v.rid, v.platform, v.zone_id) then
                self.forceText.text = string.format(TI18N("%s<color=#FFFF9A>%s</color>"), string.format(msg, ColorHelper.color[2]), tostring(v.teacher_score))
                break
            end
        end
    end

    self.forceText.text = string.format(TI18N("%s<color=#FFFF9A>%s</color>"), string.format(msg, ColorHelper.color[2]), data.fc)
end

function ApprenticeshipWindow:CheckForShow(index)
    -- BaseUtils.dump(self.model.stuData, "self.model.stuData")
    local roleData = RoleManager.Instance.RoleData
    if BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id) == BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) then     -- 查看自己的目标
        if self.model.myTeacherInfo.status == 2 then -- 出师了
            self.tabGroup.openLevel = {0, 0, 0}
            return 1
        elseif self.model.myTeacherInfo.status == 3 then
            self.tabGroup.openLevel = {255, 0, 255}
            return 2
        else
            self.tabGroup.openLevel = {0, 0, 0}
        end
    else
        if self.model.stuData.status == 1 then
            self.tabGroup.openLevel = {0, 0, 255}
        else
            self.tabGroup.openLevel = {255, 0, 255}
            return 2
        end
    end
    return index
end

function ApprenticeshipWindow:CheckRed()
    if self.tabGroup ~= nil then
        local tab = self.mgr.dailyRedPointDic[BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)]
        if tab == nil then tab = {} end
        for k,v in pairs(self.tabGroup.buttonTab) do
            if k == 3 then
                local state = SwornManager.Instance:CheckRedPointState()
                v["red"]:SetActive(state)
            else
                v["red"]:SetActive((tab[k] == true))
            end
        end
    end
end
