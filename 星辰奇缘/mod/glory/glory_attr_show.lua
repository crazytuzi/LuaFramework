-- @author 黄耀聪
-- @date 2017年6月22日, 星期四

GloryAttrShow = GloryAttrShow or BaseClass(BasePanel)

function GloryAttrShow:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GloryAttrShow"

    self.resList = {
        {file = AssetConfig.glory_attr, type = AssetType.Main},
        {file = AssetConfig.glory_textures, type = AssetType.Dep},
    }

    self.attrList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GloryAttrShow:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GloryAttrShow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_attr))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local main = t:Find("Main")

    local attr = main:Find("Attr")
    for i=1,6 do
        local tab = {}
        tab.transform = attr:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.text = tab.gameObject:GetComponent(Text)
        self.attrList[tonumber(tab.gameObject.name)] = tab
    end

    local title = main:Find("Title")
    self.titleImage = title:Find("Image"):GetComponent(Image)
    self.titleText = title:Find("Text"):GetComponent(Text)
    self.pointsText = title:Find("Points/Text"):GetComponent(Text)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
end

function GloryAttrShow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryAttrShow:OnOpen()
    self:RemoveListeners()

    self:Reload()
end

function GloryAttrShow:OnHide()
    self:RemoveListeners()
end

function GloryAttrShow:RemoveListeners()
end

function GloryAttrShow:Reload()
    for id,v in pairs(DataSkillPrac.data_skill) do
        self.attrList[id].text.text = string.format("[%s]", v.name)
    end

    local lev = self.model.currentData.max_id or 1
    for _,v in pairs((DataGlory.data_level[lev] or {}).skill_prac or {}) do
        self.attrList[v[1]].text.text = string.format("<color=#23F0F7>[%s]+%s</color>", DataSkillPrac.data_skill[v[1]].name, v[2])
    end

    self.titleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.glory_textures, string.format("Glory_%s", DataGlory.data_title[self.model.currentData.new_title_id].title_icon))
    self.titleText.text = DataGlory.data_title[self.model.currentData.new_title_id].title_name
    self.pointsText.text = string.format(TI18N("已获得属性点:%s"), (DataGlory.data_level[self.model.currentData.max_id] or {}).all_point or 0)
end


