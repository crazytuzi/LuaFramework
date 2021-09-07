-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaCPSkill = EncyclopediaCPSkill or BaseClass(BasePanel)


function EncyclopediaCPSkill:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaCPSkill"

    self.resList = {
        {file = AssetConfig.cpskill_pedia, type = AssetType.Main},
        -- {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }
    self.iconLoader = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaCPSkill:__delete()
    self.OnHideEvent:Fire()
    if self.info_panel_iconloader ~= nil then
        self.info_panel_iconloader:DeleteMe()
        self.info_panel_iconloader = nil
    end
    for i,v in ipairs(self.iconLoader) do
        v:DeleteMe()
        v = nil
    end
    self.iconLoader = {}
    if self.Layout2 ~= nil then
        self.Layout2:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function EncyclopediaCPSkill:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.cpskill_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.Desc = t:Find("Desc"):GetComponent(Text)
    local cfgdata = DataBrew.data_alldesc["cpskill"]
    if cfgdata ~= nil then
        self.Desc.text = cfgdata.desc1
    end
    self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.BaseItem = t:Find("ItemList/Mask/Scroll/Item").gameObject
    self.marryInfoPanel = t:Find("Right").gameObject
    self.info_panel_iconloader = SingleIconLoader.New(self.marryInfoPanel.transform:FindChild("Icon").gameObject)

    local setting2 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = -4.8
        ,Top = 0
    }

    self.Layout2 = LuaBoxLayout.New(self.ItemListCon, setting2)

    self:InitList()
end

function EncyclopediaCPSkill:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaCPSkill:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaCPSkill:OnHide()
    self:RemoveListeners()
end

function EncyclopediaCPSkill:RemoveListeners()
end

function EncyclopediaCPSkill:InitList()
    local data = self.Mgr.CPSkillData
    for i,v in ipairs(data) do
        local Skillitem = nil
        Skillitem = GameObject.Instantiate(self.BaseItem)
        self.Layout2:AddCell(Skillitem.gameObject)
        Skillitem.gameObject:SetActive(true)
        -- Skillitem.transform.localScale = Vector3.one
        -- local Img = Skillitem.transform:Find("SkillCon"):GetComponent(Image) or Skillitem.transform:Find("SkillCon").gameObject:AddComponent(Image)
        -- Img.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(v.icon))
        local iconLoader = SingleIconLoader.New(Skillitem.transform:Find("SkillCon").gameObject)
        iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(v.icon))
        table.insert(self.iconLoader, iconLoader)
        Skillitem.transform:Find("SkillName"):GetComponent(Text).text = v.name
        Skillitem.transform:Find("SkillLev"):GetComponent(Text).text = v.about
        Skillitem.transform:Find("Select").gameObject:SetActive(false)
        Skillitem.transform:GetComponent(Button).onClick:RemoveAllListeners()
        Skillitem.transform:GetComponent(Button).onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Skillitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetSkillData(v)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Skillitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetSkillData(v)
        end
    end
end

function EncyclopediaCPSkill:SetSkillData(skilldata)
    -- local skilldata = self.skilldata
    local transform = self.transform

    if nil == skilldata then return end

    local info_panel = self.marryInfoPanel
    -- info_panel.transform:FindChild("Icon"):GetComponent(Image).sprite
    --                 = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(skilldata.icon))
    self.info_panel_iconloader:SetSprite(SingleIconType.SkillIcon, tostring(skilldata.icon))
    info_panel.transform:FindChild("NameText"):GetComponent(Text).text = skilldata.name --.."  LV."..skilldata.lev

    info_panel.transform:FindChild("DescText"):GetComponent(Text).text = skilldata.desc

    info_panel.transform:FindChild("DescText1"):GetComponent(Text).text = skilldata.condition
    info_panel.transform:FindChild("DescText2"):GetComponent(Text).text = skilldata.desc2
    info_panel.transform:FindChild("DescText3"):GetComponent(Text).text = skilldata.location
    info_panel.transform:FindChild("DescText4"):GetComponent(Text).text = skilldata.cost_mp.. TI18N("魔法")
    info_panel.transform:FindChild("DescText5"):GetComponent(Text).text = skilldata.cooldown.. TI18N("回合")

    info_panel.transform:FindChild("Desc"):GetComponent(Text).text = skilldata.lev_desc

    -- if self.select_skilldata.lev == 0 then
    --     self.button.gameObject:SetActive(true)
    --     info_panel.transform:FindChild("ActiveText").gameObject:SetActive(false)
    -- else
    --     self.button.gameObject:SetActive(false)
    --     info_panel.transform:FindChild("ActiveText").gameObject:SetActive(true)
    -- end
end
