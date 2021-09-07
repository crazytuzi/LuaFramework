ForceImprovePanel = ForceImprovePanel or BaseClass(BasePanel)

function ForceImprovePanel:__init(parent)
    self.parent = parent
    self.mgr = ForceImproveManager.Instance
    self.model = self.mgr.model

    self.depPath = "textures/ui/forceimprove.unity3d"

    self.resList = {
        {file = AssetConfig.force_improve_panel, type = AssetType.Main}
        , {file = self.depPath, type = AssetType.Dep}
        ,{file = AssetConfig.half_length, type = AssetType.Dep}
        ,{file = AssetConfig.guidetaskicon, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.detailList = {}
    self.classSliderList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:ReloadClass() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ForceImprovePanel:__delete()
    self.OnHideEvent:Fire()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.halfImage ~= nil and  self.halfImage.sprite ~= nil then
        self.halfImage.sprite = nil
    end
    if self.badgeIcon ~= nil then
        if self.badgeIcon:GetComponent(Image) ~= nil and self.badgeIcon:GetComponent(Image).sprite ~= nil then
            self.badgeIcon:GetComponent(Image).sprite = nil
        end
    end

    if self.classSliderList ~= nil then
        for k,v in pairs(self.classSliderList) do
            if v.icon ~= nil and v.icon.sprite ~= nil then
                v.icon.sprite = nil
            end
        end
    end

    if self.detailList ~= nil then
        for k,v in pairs(self.detailList) do
            if v.icon ~= nil and v.icon.sprite ~= nil then
                v.icon.sprite = nil
            end
        end
    end

    if self.detailLayout ~= nil then
        self.detailLayout:DeleteMe()
        self.detailLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ForceImprovePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.force_improve_panel))
    self.gameObject.name = "ForceImprovePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localPosition = Vector3(0, 0, 0)
    self.transform.localScale = Vector3(1, 1, 1)

    local t = self.transform
    self.halfImage = t:Find("RoleInfo/Half"):GetComponent(Image)
    self.scoreText = t:Find("RoleInfo/ScoreValue"):GetComponent(Text)
    self.badgeIcon = t:Find("RoleInfo/BadgeIcon")
    self.badgeText = t:Find("RoleInfo/BadgeText"):GetComponent(Text)
    self.slider = t:Find("RoleInfo/Slider"):GetComponent(Slider)
    self.okButton = t:Find("RoleInfo/OkButton"):GetComponent(Button)
    self.sliderText = t:Find("RoleInfo/Slider/ProgressTxt"):GetComponent(Text)
    self.classScroll = t:Find("ScorePanel/ClassLayer/ScrollLayer"):GetComponent(ScrollRect)
    self.classContaner = t:Find("ScorePanel/ClassLayer/ScrollLayer/Container")
    self.classCloner = self.classContaner.parent:Find("Cloner").gameObject
    self.detailContainer = t:Find("DetailPanel/ScrollLayer/Container")
    self.detailCloner = self.detailContainer.parent:Find("Cloner").gameObject
    self.nothingObj = t:Find("DetailPanel/ScrollLayer/Nothing").gameObject

    self.okButton.gameObject:SetActive(false)
    self.classCloner:SetActive(false)
    self.detailCloner:SetActive(false)
    self.nothingObj:SetActive(true)
    self.detailCloner.transform:Find("IconBg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")

    local openLevel = {}
    for i,v in ipairs(self.model.classList) do
        local minLev = 99999
        for j,vv in ipairs(v.subList) do
            if vv.lev < minLev then
                minLev = vv.lev
            end
        end
        table.insert(openLevel,minLev)
    end
    BaseUtils.dump(openLevel,"openLevel")
    for i,v in ipairs(self.model.classList) do
        if self.classSliderList[i] == nil then
            self.classSliderList[i] = {}
            local obj = GameObject.Instantiate(self.classCloner)
            obj:SetActive(true)
            obj.name = tostring(i)
            local t = obj.transform
            t:SetParent(self.classContaner)
            t.localScale = Vector3.one
            self.classSliderList[i].slider = t:Find("Slider"):GetComponent(Slider)
            self.classSliderList[i].sliderText = t:Find("Slider/ProgressTxt"):GetComponent(Text)
            self.classSliderList[i].text = t:Find("Text"):GetComponent(Text)
            self.classSliderList[i].icon = t:Find("Icon"):GetComponent(Image)
            self.classSliderList[i].tag = t:Find("Tag").gameObject
        end
    end

    self.tabGroup = TabGroup.New(self.classContaner, function(i) self:ChangeTab(i) end, {isVertical = true, notAutoSelect = true, perWidth = 350, perHeight = 70, spacing = 5,openLevel = openLevel})
    self.detailLayout = LuaBoxLayout.New(self.detailContainer, {axis = BoxLayoutAxis.Y, cspacing = 10, border = 10})
end

function ForceImprovePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ForceImprovePanel:OnOpen()
    ForceImproveManager.Instance:send10018()

    self:UpdateRoleInfo()

    self.nothingObj:SetActive(self.lastIndex == nil)
    self:ReloadClass()

    self:RemoveListeners()
    self.mgr.onUpdateForce:AddListener(self.updateListener)

    self.parent.transform:FindChild("Main/Title/Text"):GetComponent(Text).text = TI18N("战力提升")
end

function ForceImprovePanel:OnHide()
    self:RemoveListeners()
end

function ForceImprovePanel:RemoveListeners()
    self.mgr.onUpdateForce:RemoveListener(self.updateListener)
end

function ForceImprovePanel:UpdateRoleInfo()
    local roleData = RoleManager.Instance.RoleData
    self.halfImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..roleData.classes..roleData.sex)
    self.halfImage.gameObject:SetActive(true)
    self.scoreText.text = tostring(roleData.fc)

    local data_reward = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel, roleData.classes)]
    if data_reward == nil then
        self.badgeIcon.gameObject:SetActive(false)
        self.badgeText.text = ""
    else
        self.badgeIcon.gameObject:SetActive(true)
        self.badgeIcon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(self.depPath, data_reward.icon)
        self.badgeText.text = data_reward.score_name
    end

    local next_data_reward = DataFcUpdate.data_reward[string.format("%s_%s", self.model.fcLevel+1, roleData.classes)]
    if next_data_reward == nil then
        self.slider.value = 1
        self.sliderText.text = string.format("%s/--", roleData.fc)
    else
        self.slider.value = roleData.fc/next_data_reward.score
        self.sliderText.text = string.format("%s/%s", roleData.fc, next_data_reward.score)
    end
end

function ForceImprovePanel:ReloadClass()
    for i,_ in ipairs(self.tabGroup.buttonTab) do
        self:SetClassItem(i)
    end

    self.tabGroup:Layout()

    if self.lastIndex ~= nil then
        self:ReloadDetails(self.lastIndex)
    end
end

function ForceImprovePanel:SetClassItem(index)
    local model = self.model
    local tab = self.classSliderList[index]
    local data = model.classList[index]
    tab.text.text = data.name

    local serverTop = "--"
    if data.serverTop ~= nil and data.serverTop > 0 then
        serverTop = tostring(data.serverTop)
        tab.slider.value = data.myScore / data.serverTop
    else
        tab.slider.value = 1
    end
    tab.sliderText.text = tostring(data.myScore).."/"..serverTop
    tab.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, data.icon)

    if RoleManager.Instance.RoleData.lev >= 30 then
        if data.myScore < data.serverTop * 0.5 then
            tab.tag:SetActive(true)
        else
            tab.tag:SetActive(false)
        end
    end
end

function ForceImprovePanel:ChangeTab(index)
    self.nothingObj:SetActive(false)
    self.lastIndex = index
    self:ReloadDetails(index)
end

function ForceImprovePanel:ReloadDetails(index)
    local model = self.model
    local datas = model:SortDetailData(model.classList[index].subList)
    local cntTemp = 0
    local lev = RoleManager.Instance.RoleData.lev
    if RoleManager.Instance.RoleData.lev_break_times > 0 then
        lev = lev + 6
    end
    for i,v in ipairs(datas) do
        if v.lev <= lev then
            cntTemp = cntTemp + 1
            if self.detailList[cntTemp] == nil then
                self.detailList[cntTemp] = {}
                local obj = GameObject.Instantiate(self.detailCloner)
                local t = obj.transform
                obj.name = tostring(cntTemp)
                self.detailLayout:AddCell(obj)
                self.detailList[cntTemp].obj = obj
                self.detailList[cntTemp].name = t:Find("Name"):GetComponent(Text)
                self.detailList[cntTemp].icon = t:Find("Icon"):GetComponent(Image)
                self.detailList[cntTemp].btn = t.gameObject:GetComponent(Button)
                self.detailList[cntTemp].goBtn = self.detailList[cntTemp].icon:GetComponent(Button)
                self.detailList[cntTemp].desc = t:Find("Desc"):GetComponent(Text)
                self.detailList[cntTemp].nowScore = t:Find("NowScore"):GetComponent(Text)
                self.detailList[cntTemp].recommendScore = t:Find("RecommendScore"):GetComponent(Text)
                self.detailList[cntTemp].tag = t:Find("Tag").gameObject
            end
            self:SetDetailItem(index, v,cntTemp)
        end
    end

    for i=cntTemp + 1, #self.detailList do
        self.detailList[i].obj:SetActive(false)
    end

    self.detailLayout.panelRect:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical, (80 + 10) * cntTemp + 10)
end

function ForceImprovePanel:SetDetailItem(index, data,itemIndex)
    local model = self.model
    local tab = self.detailList[itemIndex]

    local recommendData = model:GetMyRecommendData(data.id)
    if recommendData == nil then
        return
    end
    local myScore = self.model.subTypeList[data.id].myScore
    local serverTop = self.model.subTypeList[data.id].serverTop

    local recommendType = 1
    local recommendText = ""
    local showBestScore = false
    if myScore >= recommendData.val then
        showBestScore = true
        recommendType = 1
        recommendText = TI18N("<color='#2f34ff'>不分伯仲</color>")
    elseif myScore >= recommendData.val * 0.95 then
        recommendType = 1
        recommendText = TI18N("<color='#2f34ff'>不分伯仲</color>")
    elseif myScore > recommendData.val * 0.7 then
        recommendType = 1
        recommendText = TI18N("<color='#249015'>推荐提升</color>")
    else
        recommendType = 2
        recommendText = TI18N("<color='#ff0000'>强烈推荐</color>")
    end

    if showBestScore then
        if myScore >= serverTop then
            recommendType = 1
            recommendText = TI18N("<color='#2f34ff'>不分伯仲</color>")
        elseif myScore >= serverTop * 0.95 then
            recommendType = 1
            recommendText = TI18N("<color='#2f34ff'>不分伯仲</color>")
        elseif myScore > serverTop * 0.7 then
            recommendType = 1
            recommendText = TI18N("<color='#249015'>推荐提升</color>")
        else
            recommendType = 2
            recommendText = TI18N("<color='#ff0000'>强烈推荐</color>")
        end
    end

    tab.obj:SetActive(true)
    tab.name.text = data.name
    -- tab.desc.text = data.desc
    tab.desc.text = string.format(TI18N("评价：%s"), recommendText)
    tab.nowScore.text = string.format(TI18N("当前评分：%s"), myScore)
    if showBestScore then
        tab.recommendScore.text = string.format(TI18N("本服最高：%s"), serverTop)
    else
        tab.recommendScore.text = string.format(TI18N("推荐评分：%s"), recommendData.val)
    end

    tab.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(data.icon))

    if recommendType > 1 then
        tab.tag:SetActive(true)
    else
        tab.tag:SetActive(false)
    end

    tab.btn.onClick:RemoveAllListeners()
    tab.btn.onClick:AddListener(function() self:JumpTo(data.link) end)
end

function ForceImprovePanel:JumpTo(link)
    local openArgs = {}
    local args = StringHelper.Split(link, ",")
    local winId = tonumber(args[1])
    if winId == 0 then return end

    for i=2,#args do
        table.insert(openArgs, tonumber(args[i]))
    end
    WindowManager.Instance:OpenWindowById(winId, openArgs)
end

