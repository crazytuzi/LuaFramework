--作者:hzf
--01/04/2017 15:47:30
--功能:子女获取第3步窗口

ChildrenAfterBirthPanel = ChildrenAfterBirthPanel or BaseClass(BasePanel)
function ChildrenAfterBirthPanel:__init(parent)
    self.parent = parent
    self.Mgr = ChildrenManager.Instance
    self.resList = {
        {file = AssetConfig.childrenafterbirthpanel, type = AssetType.Main},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
    }
    --self.OnOpenEvent:Add(function() self:OnOpen() end)
    --self.OnHideEvent:Add(function() self:OnHide() end)
    self.hasInit = false
end

function ChildrenAfterBirthPanel:__delete()
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

function ChildrenAfterBirthPanel:OnHide()

end

function ChildrenAfterBirthPanel:OnOpen()

end

function ChildrenAfterBirthPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrenafterbirthpanel))
    self.gameObject.name = "ChildrenAfterBirthPanel"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    self.transform = self.gameObject.transform
    self.bg = self.transform:Find("bg")
    self.transform:Find("preview"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = self.transform:Find("preview")
    self.Text1 = self.transform:Find("Desbg/Text1"):GetComponent(Text)
    self.Text1.text = string.format(TI18N("1.幼年期的子女勤学好动，作为父母需要<color='#00ff00'>用心培养</color>喔\n2.幼年期的培养效果，将决定以后的<color='#00ff00'>资质属性</color>\n3.德、智、体、敏、力，累计100次学习后将进入成长期"))
    self.Text2 = self.transform:Find("Desbg/Text2"):GetComponent(Text)
    self.Text2.text = string.format(TI18N("1.成长期的子女已经能够<color='#00ff00'>参与战斗</color>咯，咱家宝贝棒棒的\n2.每位家长最多同时携带2名子女，战斗中可召唤登场\n3.当前子女达到成长期后，才能孕育下一个子女哦"))
    self.Title1Text = self.transform:Find("Title1/Text"):GetComponent(Text)
    self.Title2Text = self.transform:Find("Title2/Text"):GetComponent(Text)
    self.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_study_win)
    end)
    -- self.Attention = self.transform:Find("Attention")
    self.AttentionText = self.transform:Find("Attention/Text"):GetComponent(Text)
    local hasNumber = math.max(0,self.Mgr.max_childNum-#self.Mgr.childData)
    self.AttentionText.text = string.format("当前已孕育%s名子女，还可以孕育%s名<color='#00ff00'>（上限:单身3名,结缘4名）</color>", tostring(#self.Mgr.childData), tostring(hasNumber))
    -- self.LButton = self.transform:Find("LButton"):GetComponent(Button)
    -- self.RButton = self.transform:Find("RButton"):GetComponent(Button)
    -- self.current = self.transform:Find("current")
    -- self.currentsex = self.transform:Find("current/sex")
    -- self.currentclass = self.transform:Find("current/class")
    -- self.currentname = self.transform:Find("current/name")se
    self:LoadPreview()
end

function ChildrenAfterBirthPanel:LoadPreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "ChildrenAfterBirthPanel"
        ,orthographicSize = 0.3
        ,width = 280
        ,height = 300
        ,offsetY = -0.26
    }
    local chidldata = ChildrenManager.Instance:GetChildhood()
    BaseUtils.dump(chidldata, "孩子的数据快快快快快快快")

    local baby = DataUnit.data_unit[71159]
    if chidldata.sex == 0 then
        baby = DataUnit.data_unit[71160]
    end
    local modelData = {type = PreViewType.Pet, skinId = baby.skin, modelId = baby.res, animationId = baby.animation_id, scale = baby.scale/100, effects = {}}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function ChildrenAfterBirthPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 74, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    -- self.preview:SetActive(true)
    -- local childbase = self.ChildrenData[self.currindex]
    -- self.currentsex.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, self.sexicon[childbase.sex])
    -- self.currentclass.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, self.classType[self.parentClassTo_classType[childbase.classes]])
    -- self.currentname.text = childbase.name
    -- self.currentGo:SetActive(true)
end
