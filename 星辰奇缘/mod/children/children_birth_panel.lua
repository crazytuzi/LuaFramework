--作者:hzf
--01/05/2017 11:22:19
--功能:子女系统

ChildrenBirthPanel = ChildrenBirthPanel or BaseClass(BasePanel)
function ChildrenBirthPanel:__init(parent)
	self.parent = parent
    self.btnEffect = "prefabs/effect/20053.unity3d"
	self.resList = {
        {file = AssetConfig.childrenbirthpanel, type = AssetType.Main},
		{file = self.btnEffect, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        {file = AssetConfig.dailyicon, type = AssetType.Dep},
		{file = AssetConfig.childrentextures, type = AssetType.Dep},
	}
    self.Way = {
        [1] = {name = TI18N("天地灵蕴"), isquick = true, file = AssetConfig.childrentextures, icon = "iconeat", callback = function() WindowManager.Instance:OpenWindowById(17805, {5}) end},
        [2] = {name = TI18N("孕育任务"), isquick = false, file = AssetConfig.childrentextures, icon = "iconquest", callback = function() self:DoQuest() end},
        [3] = {name = TI18N("悬赏任务"), isquick = false, file = AssetConfig.dailyicon, icon = "1013", callback = function() AgendaManager.Instance:OpenWindow() end},
        [4] = {name = TI18N("上古妖魔"), isquick = false, file = AssetConfig.dailyicon, icon = "1014", callback = function() AgendaManager.Instance:OpenWindow() end},
        [5] = {name = TI18N("野怪战斗"), isquick = false, file = AssetConfig.dailyicon, icon = "1005", callback = function() AgendaManager.Instance:OpenWindow() end}
    }
    self.max_maturity = 1000
    self.ontimeschange = function()
        self:UpdateTimes()
    end
    self.chidDataUpdate = function()
        self:UpdateValue()
    end
    self.eggDataUpdate = function()
        self:UpdateEggData()
    end
    ChildrenManager.Instance:Require18626()
	self.hasInit = false
    self.TypeList = {
        [1] = 10002,
        [2] = 10001,
        [3] = 10000,
        [4] = 13,
        [5] = 3,
    }
end

function ChildrenBirthPanel:__delete()
    QuestManager.Instance.childPregnancyUpdate:RemoveListener(self.ontimeschange)
    ChildrenManager.Instance.OnChildDataUpdate:RemoveListener(self.chidDataUpdate)
    ChildrenManager.Instance.OnChildEggUpdate:RemoveListener(self.eggDataUpdate)
	if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenBirthPanel:OnHide()

end

function ChildrenBirthPanel:OnOpen()

end

function ChildrenBirthPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrenbirthpanel))
	self.gameObject.name = "ChildrenBirthPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
	self.preview = self.transform:Find("preview")
	self.transform:Find("preview"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
	self.DoButton = self.transform:Find("Button"):GetComponent(Button)
    self.DoButton.onClick:AddListener(function()
        self:GetBaby()
    end)
    self.DoButton.gameObject:SetActive(true)
    self.ButtonText = self.transform:Find("Button/Text"):GetComponent(Text)
	self.AttentionText = self.transform:Find("Attention/Text"):GetComponent(Text)

    self.btnEffectgo = GameObject.Instantiate(self:GetPrefab(self.btnEffect))
    self.btnEffectgo.transform:SetParent(self.DoButton.transform)
    self.btnEffectgo.transform.localScale = Vector3(1.66, 0.56, 1)
    self.btnEffectgo.transform.localPosition = Vector3(-53, -11, -1000)
    Utils.ChangeLayersRecursively(self.btnEffectgo.transform, "UI")
    self.btnEffectgo:SetActive(false)

	self.Slider = self.transform:Find("Slider"):GetComponent(Slider)
	-- self.NameText = self.transform:Find("Slider/NameText"):GetComponent(Text)
	self.RateText = self.transform:Find("RateText"):GetComponent(Text)
	self.DescText = self.transform:Find("DescText"):GetComponent(Text)
	-- self.TItle = self.transform:Find("TItle")
	self.TitleText = self.transform:Find("TItle/TitleText"):GetComponent(Text)
	self.MaskScroll = self.transform:Find("MaskScroll")
	self.List = self.transform:Find("MaskScroll/List")
	self.Layout = LuaBoxLayout.New(self.List, {axis = BoxLayoutAxis.X, cspacing = 10, scrollRect = self.MaskScroll})
	self.BaseItem = self.transform:Find("MaskScroll/List/Button")

    self.transform:Find("Attention/Text"):GetComponent(Text).text = string.format("当前已孕育%s名子女，还可以孕育%s名<color='#00ff00'>（上限%s名）</color>", tostring(#ChildrenManager.Instance.childData), tostring(ChildrenManager.Instance.max_childNum-#ChildrenManager.Instance.childData), tostring(ChildrenManager.Instance.max_childNum))

    self.TipsPanel = self.transform:Find("TipsPanel")
    self.TipsPanel:GetComponent(Button).onClick:AddListener(function()
        self.TipsPanel.gameObject:SetActive(false)
    end)
    self.transform:Find("TipsButton"):GetComponent(Button).onClick:AddListener(function()
        self.TipsPanel.gameObject:SetActive(true)
    end)

    self.I18NText = self.transform:Find("TipsPanel/Main/I18NText"):GetComponent(Text)
    self.I18NText.text = TI18N("每天完成以下内容，将有几率可以获得<color='#ffff00'>孕育值</color>，每天可获得：")
    self.I18NText1 = self.transform:Find("TipsPanel/Main/I18NText1"):GetComponent(Text)
    self.NumText1 = self.transform:Find("TipsPanel/Main/NumText1"):GetComponent(Text)
    self.I18NText2 = self.transform:Find("TipsPanel/Main/I18NText2"):GetComponent(Text)
    self.NumText2 = self.transform:Find("TipsPanel/Main/NumText2"):GetComponent(Text)

	self:InitFuncList()
	self:LoadPreview()
    self:UpdateValue()
    self:UpdateTimes()
    self:UpdateEggData()
    ChildrenManager.Instance.OnChildDataUpdate:AddListener(self.chidDataUpdate)
    QuestManager.Instance.childPregnancyUpdate:AddListener(self.ontimeschange)
    ChildrenManager.Instance.OnChildEggUpdate:AddListener(self.eggDataUpdate)
end

function ChildrenBirthPanel:InitFuncList()

	for i,v in ipairs(self.Way) do
		local item = GameObject.Instantiate(self.BaseItem.gameObject)
		item.transform:Find("Text"):GetComponent(Text).text = v.name
		self.Layout:AddCell(item)
        item.transform:Find("iconbg/icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(v.file, v.icon)
        item.transform:Find("label").gameObject:SetActive(v.isquick)
        item.transform:GetComponent(Button).onClick:AddListener(function()
            v.callback()
        end)
	end
end

function ChildrenBirthPanel:LoadPreview()
	local callback = function(composite)
        local effects = {{effect_id = 301710}}
        if MarryManager.Instance.loverData ~= nil and RoleManager.Instance.RoleData.sex == 1 then
            effects = {{effect_id = 301700}}
        elseif MarryManager.Instance.loverData ~= nil and RoleManager.Instance.RoleData.sex == 0 then
            effects = {{effect_id = 301700}}
        end
        local callback = function(effect)
            effect.transform.localPosition = Vector3(0, 0, 0)
            Utils.ChangeLayersRecursively(effect.transform, "ModelPreview")
        end
        TposeEffectLoader.New(composite.tpose, composite.tpose, effects, callback)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "ChildrenBirthPanel"
        ,orthographicSize = 0.55
        ,width = 280
        ,height = 300
        ,offsetY = -0.4
    }
    local llooks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
    local chidldata = ChildrenManager.Instance:GetChildFetus()
    BaseUtils.dump(chidldata, "孩子数据")
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks, effects = {{effect_id = 301710}}}
    if #chidldata.parents == 1 then
        modelData.classes = chidldata.parents[1].classes
        modelData.sex = chidldata.parents[1].sex
        modelData.looks = chidldata.parents[1].looks
    else
        for k,v in pairs(chidldata.parents) do
            if v.sex == 0 then
                modelData.classes = v.classes
                modelData.sex = v.sex
                modelData.looks = v.looks
            end
        end
    end
    BaseUtils.dump(modelData, "数据")
    -- if MarryManager.Instance.loverData ~= nil and RoleManager.Instance.RoleData.sex == 1 then
    --     modelData = {type = PreViewType.Role, classes = MarryManager.Instance.loverData.classes, sex = MarryManager.Instance.loverData.sex, looks = {}, effects = {{effect_id = 301720}}}
    --     -- modelData.looks =
    -- elseif MarryManager.Instance.loverData ~= nil and RoleManager.Instance.RoleData.sex == 0 then
    --     modelData.effects = {{effect_id = 30172}}
    -- end
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function ChildrenBirthPanel:SetRawImage(composite)
	local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 53, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    -- self.preview:SetActive(true)
end

function ChildrenBirthPanel:UpdateTimes()
    local chidldata = ChildrenManager.Instance:GetChildFetus()
    if chidldata ~= nil then
        self.Slider.value = chidldata.maturity / self.max_maturity
        self.RateText.text = string.format("%s/%s", tostring(chidldata.maturity), tostring(self.max_maturity))
        -- self.DoButton.gameObject:SetActive(chidldata.maturity == self.max_maturity)
    end
    if QuestManager.Instance.childPregnancyData.round == 0 and chidldata.maturity ~= self.max_maturity then
        local day = os.date("%d", QuestManager.Instance.childPregnancyData.last_accepted)
        local currday = os.date("%d", BaseUtils.BASE_TIME)
        if day == currday then
            self.btnEffectgo:SetActive(false)
        else
            self.btnEffectgo:SetActive(true)
        end
        self.DoButton.onClick:RemoveAllListeners()
        self.DoButton.onClick:AddListener(function()
            self:DoQuest()
        end)
        self.ButtonText.text = TI18N("孕育任务")
    elseif chidldata.maturity == self.max_maturity then
        self.DoButton.onClick:RemoveAllListeners()
        self.DoButton.onClick:AddListener(function()
            self:GetBaby()
        end)
        self.ButtonText.text = TI18N("孩子诞生")
        self.btnEffectgo:SetActive(true)
    else
        self.btnEffectgo:SetActive(false)
        self.DoButton.onClick:RemoveAllListeners()
        self.DoButton.onClick:AddListener(function()
            self:DoQuest()
        end)
        self.ButtonText.text = TI18N("孕育任务")
    end
end

function ChildrenBirthPanel:UpdateValue()
    local chidldata = ChildrenManager.Instance:GetChildFetus()
    if chidldata ~= nil then
        self.Slider.value = chidldata.maturity / self.max_maturity
        self.RateText.text = string.format("%s/%s", tostring(chidldata.maturity), tostring(self.max_maturity))
        -- self.DoButton.gameObject:SetActive(chidldata.maturity == self.max_maturity)
    end
end

function ChildrenBirthPanel:GetBaby()
    ChildrenManager.Instance:Require18609()
end

function ChildrenBirthPanel:UpdateEggData()
    if ChildrenManager.Instance.eggData ~= nil then
        local str1 = ""
        local val1 = ""
        local str2 = ""
        local val2 = ""
        local proto = ChildrenManager.Instance.eggData.extra

        for i,v in ipairs(self.TypeList) do
            print(DataChild.data_egg_val[v].desc)
            if i%2 == 1 then
                local currval = 0
                for _, data in pairs(proto) do
                    if data.type == v then
                        currval = data.value
                    end
                end
                if i > 1 then
                    str1 = str1.."\n"..DataChild.data_egg_val[v].desc
                    val1 = val1.."\n"..string.format("%s/%s", tostring(currval*DataChild.data_egg_val[v].val), tostring(DataChild.data_egg_val[v].val*DataChild.data_egg_val[v].active_times))
                else
                    str1 = DataChild.data_egg_val[v].desc
                    val1 = string.format("%s/%s", tostring(currval*DataChild.data_egg_val[v].val), tostring(DataChild.data_egg_val[v].val*DataChild.data_egg_val[v].active_times))
                end
            else
                local currval = 0
                for _, data in pairs(proto) do
                    if data.type == v then
                        currval = data.value
                    end
                end
                if i > 2 then
                    str2 = str2.."\n"..DataChild.data_egg_val[v].desc
                    val2 = val2.."\n"..string.format("%s/%s", tostring(currval*DataChild.data_egg_val[v].val), tostring(DataChild.data_egg_val[v].val*DataChild.data_egg_val[v].active_times))
                else
                    str2 = DataChild.data_egg_val[v].desc
                    val2 = string.format("%s/%s", tostring(currval*DataChild.data_egg_val[v].val), tostring(DataChild.data_egg_val[v].val*DataChild.data_egg_val[v].active_times))
                end
            end
        end
        self.I18NText1.text = str1
        self.NumText1.text = string.format("<color='#00ff00'>%s</color>", val1)
        self.I18NText2.text = str2
        self.NumText2.text = string.format("<color='#00ff00'>%s</color>", val2)
    end
end

function ChildrenBirthPanel:DoQuest()
    ChildrenManager.Instance.model:CloseGetWindow()
    local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.childbreed)
    if questData ~= nil then
        QuestManager.Instance:DoQuest(questData)
    else
        QuestManager.Instance:Send10211(QuestEumn.TaskType.childbreed)
    end
end