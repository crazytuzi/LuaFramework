-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaWings = EncyclopediaWings or BaseClass(BasePanel)


function EncyclopediaWings:__init(parent)
    self.model = BackpackManager.Instance.mainModel.wingModel
    self.parent = parent
    self.name = "EncyclopediaWings"

    self.resList = {
        {file = AssetConfig.wings_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep},
    }
    self.lastSelectMain = 1
    self.lastSelectSub = 1
    self.subOpenList = {}
    self.iconloader = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaWings:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
    end
    self.iconloader = {}
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaWings:InitPanel()
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wings_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local main = t
    self.btnContainer = t:Find("Bar/Container")
    self.barRect = self.btnContainer:GetComponent(RectTransform)
    self.mainTemplate = self.btnContainer:Find("MainButton").gameObject
    self.mainHeight = 58
    self.subTemplate = self.btnContainer:Find("SubButton").gameObject
    self.subHeight = 40
    self.mainTemplate:SetActive(false)
    self.subTemplate:SetActive(false)
    self.mainList = {}
    self.subList = {}

    main:Find("Content/PreviewArea"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.preview = main:Find("Content/PreviewArea/ModelPreview").gameObject
    -- self.boxYLayout = LuaBoxLayout.New(self.btnContainer, {cspacing = 5, axis = BoxLayoutAxis.Y})
    for i=1,#WingsManager.Instance.wingsIdByGrade do
        local mainbtn = GameObject.Instantiate(self.mainTemplate):GetComponent(Button)
        self.mainList[i] = mainbtn
        mainbtn.gameObject.name = tostring(i)
        UIUtils.AddUIChild(self.btnContainer, mainbtn.gameObject)
        mainbtn.gameObject:SetActive(true)
        local t = mainbtn.gameObject.transform

        local id = t:Find("Icon").gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(t:Find("Icon").gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, DataItem.data_get[WingsManager.Instance:GetItemByGrade(i)].icon)
        t:Find("Text"):GetComponent(Text).text = string.format(TI18N("%s阶翅膀"), BaseUtils.NumToChn(i))
        mainbtn.onClick:AddListener(function()
            self:ClickMain(i)
            self:ReloadPanel(WingsManager.Instance.wingsIdByGrade[self.lastSelectMain][self.lastSelectSub])
        end)
        self.subOpenList[i] = false
        self.subList[i] = {}
        for j=1, #WingsManager.Instance.wingsIdByGrade[i] do
            local subbtn = GameObject.Instantiate(self.subTemplate):GetComponent(Button)
            subbtn.gameObject.name = tostring(i.."_"..j)
            UIUtils.AddUIChild(self.btnContainer, subbtn.gameObject)
            subbtn.gameObject:SetActive(false)
            subbtn.gameObject.transform:Find("Text"):GetComponent(Text).text = DataWing.data_base[WingsManager.Instance.wingsIdByGrade[i][j]].name
            self.subList[i][j] = subbtn
            subbtn.onClick:AddListener(function ()
                self:ClickSub(i, j)
                self:ReloadPanel(WingsManager.Instance.wingsIdByGrade[self.lastSelectMain][self.lastSelectSub])
            end)
        end
    end

    local content = main:Find("Content")
    self.nameText = content:Find("Name/Text"):GetComponent(Text)

    local infoArea = content:Find("InfoArea")
    local attrArea = infoArea:Find("AttrArea")
    local attrTemplate = attrArea:Find("Attr").gameObject
    attrTemplate:SetActive(false)
    self.attrList = {}
    self.attrIcon = {}
    self.attrName = {}
    self.attrValue = {}
    for i=1,4 do
        self.attrList[i] = GameObject.Instantiate(attrTemplate)
        self.attrList[i].name = tostring(i)
        local t = self.attrList[i].transform
        t:SetParent(attrArea)
        self.attrIcon[i] = t:Find("Icon"):GetComponent(Image)
        self.attrName[i] = t:Find("Desc"):GetComponent(Text)
        self.attrValue[i] = t:Find("Value"):GetComponent(Text)
        if i % 2 == 1 then
            t:Find("Bg").gameObject:SetActive(true)
        else
            t:Find("Bg").gameObject:SetActive(false)
        end
        t.localScale = Vector3.one
        self.attrList[i]:GetComponent(RectTransform).anchoredPosition = Vector2(0, -30 * (i - 1))
    end

    self:ClickMain(1)
    self:ReloadPanel(WingsManager.Instance.wingsIdByGrade[1][1])
end

function EncyclopediaWings:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaWings:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaWings:OnHide()
    self:RemoveListeners()
end

function EncyclopediaWings:RemoveListeners()
end


function EncyclopediaWings:EnableMain(main, bool)
    local t = self.mainList[main].gameObject.transform
    if bool == true then
        t:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
        t:Find("Arrow"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow3")
        t:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton9
    else
        t:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        t:Find("Arrow"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Arrow4")
        t:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton8
    end
end

function EncyclopediaWings:EnableSub(main, sub, bool)
    local t = self.subList[main][sub].gameObject.transform
    if bool == true then
        t:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
        t:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton11
    else
        t:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton10")
        t:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton10
    end
end

function EncyclopediaWings:ClickMain(main)
    if self.lastSelectMain ~= main then
        self:EnableMain(self.lastSelectMain, false)
        self:ShowSub(self.lastSelectMain, false)
        self.lastSelectSub = 1
        self.lastSelectMain = main
        self:ShowSub(self.lastSelectMain, true)
        self:EnableMain(main, true)
        self:EnableSub(self.lastSelectMain, self.lastSelectSub, true)
    else
        self:ShowSub(main, not self.subOpenList[main])
    end
end

function EncyclopediaWings:ClickSub(main, sub)
    if self.lastSelectMain ~= main then
        self:EnableSub(self.lastSelectMain, self.lastSelectSub, false)
        self:EnableMain(main, false)
        self:ShowSub(self.lastSelectMain, false)
        self.lastSelectMain = main
        self.lastSelectSub = sub
        self:ShowSub(self.lastSelectMain, true)
        self:EnableMain(main, true)
        self:EnableSub(self.lastSelectMain, self.lastSelectSub, true)
    elseif sub ~= self.lastSelectSub then
        self:EnableSub(self.lastSelectMain, self.lastSelectSub, false)
        self.lastSelectSub = sub
        self:EnableSub(self.lastSelectMain, self.lastSelectSub, true)
    end
end

function EncyclopediaWings:ShowSub(main, bool)
    self.subOpenList[main] = bool
    local model = self.model
    local h = (self.mainHeight + 4.1) * #model.wingsIdByGrade
    for k,v in pairs(self.subList[main]) do
        v.gameObject:SetActive(bool)
        if bool then
            h = h + self.subHeight + 4.1
        end
    end
    self.barRect.sizeDelta = Vector2(self.barRect.sizeDelta.x, h - 4.1)
    self:EnableSub(self.lastSelectMain, self.lastSelectSub, bool)
    if bool then
        self.mainList[main].transform:Find("Arrow").localScale = Vector3(-1, 1, 1)
    else
        self.mainList[main].transform:Find("Arrow").localScale = Vector3(1, 1, 1)
    end
end

function EncyclopediaWings:ReloadPanel(wing_id)
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "wing"
        ,orthographicSize = 0.45
        ,width = 341
        ,height = 250
        ,offsetY = -0.2
        , noDrag = true
    }
    local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = wing_id}}}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData, "ModelPreview")
    else
        self.previewComp:Reload(modelData, callback)
    end

    local roledata = RoleManager.Instance.RoleData
    local data = DataWing.data_base[wing_id]
    local attr = nil
    for i=0,10 do
        local tempAttr = DataWing.data_attribute[roledata.classes.."_"..data.grade.."_"..i]
        if tempAttr == nil then
            -- break
        else
            attr = tempAttr
        end
    end
    self.nameText.text = data.name

    for i=1,4 do
        local dat = attr.attr[i]
        if dat ~= nil then
            self.attrIcon[i].sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..dat.attr_name)
            self.attrName[i].text = KvData.attr_name[dat.attr_name]
            self.attrValue[i].text = tostring(dat.val)
            self.attrList[i]:SetActive(true)
        else
            self.attrList[i]:SetActive(false)
        end
    end
end


function EncyclopediaWings:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end
