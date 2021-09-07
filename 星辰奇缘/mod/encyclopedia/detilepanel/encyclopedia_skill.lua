-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaSkill = EncyclopediaSkill or BaseClass(BasePanel)


function EncyclopediaSkill:__init(parent)
    self.Mgr = EncyclopediaManager.Instance
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaSkill"
    self.resList = {
        {file = AssetConfig.classskill_pedia, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.currclass = 1
    self.iconLoaderList = {}
    self.giftIconLoader = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function EncyclopediaSkill:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.Layout1 ~= nil then
        self.Layout1:DeleteMe()
    end
    if self.Layout2 ~= nil then
        self.Layout2:DeleteMe()
    end
    for k,v in pairs(self.giftIconLoader) do
        v:DeleteMe()
    end
    self.giftIconLoader = {}
    for k,v in pairs(self.iconLoaderList) do
        v:DeleteMe()
    end
    self.iconLoaderList = {}

    self:AssetClearAll()
end

function EncyclopediaSkill:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.classskill_pedia))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.Desc = t:Find("Desc"):GetComponent(Text)
    local cfgdata = DataBrew.data_alldesc["rolekill"]
    if cfgdata ~= nil then
        self.Desc.text = cfgdata.desc1
    end
    self.ToggleList = t:Find("ToggleList")
    self.Background = t:Find("ToggleList/Background").gameObject
    self.Label = t:Find("ToggleList/Label"):GetComponent(Text)
    self.ToggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.Background.activeSelf
        self.Background:SetActive(open == false)
        self.ClassList:SetActive(open == false)
    end)

    self.ClassList = t:Find("ClassList").gameObject
    self.ClassListBtn = t:Find("ClassList/Button"):GetComponent(Button)
    self.ClassListBtn.onClick:AddListener(function()
        self.Background:SetActive(false)
        self.ClassList:SetActive(false)
    end)
    self.ClassListCon = t:Find("ClassList/Mask/Scroll")
    self.ClassListItem = t:Find("ClassList/Mask/Scroll"):GetChild(0).gameObject
    self.ClassListItem:SetActive(false)

    self.ItemListCon = t:Find("ItemList/Mask/Scroll")
    self.ItemListItem = t:Find("ItemList/Mask/Scroll"):GetChild(0).gameObject

    self.transform:Find("Right/I18NAttrsDescText_Front").anchoredPosition = Vector2(18, -177.5)
    self.transform:Find("Right/AttrsDescText").anchoredPosition = Vector2(136, -177.5)

    local setting1 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    local setting2 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = -4.8
        ,Top = 0
    }
    self.Layout1 = LuaBoxLayout.New(self.ClassListCon, setting1)
    self.Layout2 = LuaBoxLayout.New(self.ItemListCon, setting2)
    for i=1, #KvData.classes_name do
        local item = GameObject.Instantiate(self.ClassListItem)
        item.transform:Find("I18NText"):GetComponent(Text).text = KvData.classes_name[i]
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self.Label.text = KvData.classes_name[i]
            self.currclass = i
            self.Background:SetActive(false)
            self.ClassList:SetActive(false)
            self:RefreshItemList()
        end)
        self.Layout1:AddCell(item)
    end
    self.Label.text = KvData.classes_name[self.currclass]
    self:RefreshItemList()
end

function EncyclopediaSkill:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function EncyclopediaSkill:OnOpen()
    self:RemoveListeners()
end

function EncyclopediaSkill:OnHide()
    self:RemoveListeners()
end

function EncyclopediaSkill:RemoveListeners()
end

function EncyclopediaSkill:RefreshItemList()
    for k,v in pairs(self.iconLoaderList) do
        v:DeleteMe()
    end
    self.iconLoaderList = {}

    local oldList = {}
    for i=1, self.ItemListCon.childCount do
        self.ItemListCon:GetChild(i-1).gameObject:SetActive(false)
        table.insert(oldList, self.ItemListCon:GetChild(i-1))
    end

    local data = self.Mgr.RoleSkillData[self.currclass]
    BaseUtils.dump(self.Mgr.RoleSkillData, "总数据")
    self.Layout2:ReSet()
    for i,v in ipairs(data) do
        local Skillitem = nil
        if #oldList > 0 then
            Skillitem = oldList[#oldList]
            table.remove(oldList)
            -- Skillitem.transform:SetParent(self.ItemListCon)
        else
            Skillitem = GameObject.Instantiate(self.ItemListItem)
            -- Skillitem.transform:SetParent(self.ItemListCon)
        end
        self.Layout2:AddCell(Skillitem.gameObject)
        Skillitem.gameObject:SetActive(true)
        -- Skillitem.transform.localScale = Vector3.one
        local cfgdata = DataSkill.data_skill_role[BaseUtils.Key(v, 1)]
        -- BaseUtils.dump(cfgdata, "技能数据")
        -- local Img = Skillitem.transform:Find("SkillCon"):GetComponent(Image) or Skillitem.transform:Find("SkillCon").gameObject:AddComponent(Image)
        -- Img.sprite = self.assetWrapper:GetSprite(self.iconPath[self.currclass], tostring(cfgdata.icon))
        local iconLoader = SingleIconLoader.New(Skillitem.transform:Find("SkillCon").gameObject)
        iconLoader:SetSprite(SingleIconType.SkillIcon, cfgdata.icon)
        iconLoader:SetIconColor(Color.white)
        table.insert(self.iconLoaderList, iconLoader)

        Skillitem.transform:Find("SkillName"):GetComponent(Text).text = StringHelper.Split(cfgdata.name, "·")[1]
        Skillitem.transform:Find("SkillLev"):GetComponent(Text).text = cfgdata.about
        Skillitem.transform:Find("Select").gameObject:SetActive(false)
        Skillitem.transform:GetComponent(Button).onClick:RemoveAllListeners()
        Skillitem.transform:GetComponent(Button).onClick:AddListener(function()
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Skillitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)
            self:SetSkillData(cfgdata)
        end)
        if i == 1 then
            if self.selectgo ~= nil then
                self.selectgo:SetActive(false)
            end
            self.selectgo = Skillitem.transform:Find("Select").gameObject
            self.selectgo:SetActive(true)

            self:SetSkillData(cfgdata)
        end
    end
end

function EncyclopediaSkill:SetSkillData(data)
    local skilldata = data
    local transform = self.transform

    if nil == skilldata then return end
    local info_panel = transform:Find("Right").gameObject
    info_panel.transform:FindChild("NameText"):GetComponent(Text).text = StringHelper.Split(skilldata.name, "·")[1].."  LV."..skilldata.lev

    info_panel.transform:FindChild("DescText"):GetComponent(Text).text = skilldata.desc

    local attrstr = "";
    for attrindex = 1, #skilldata.attr do
        local attrdata = skilldata.attr[attrindex]
        if attrindex ~= 1 then attrstr = attrstr.."; " end
        attrstr = attrstr..attrdata.val..""..KvData.GetAttrName(attrdata.name)
    end

    info_panel.transform:FindChild("AttrsDescText"):GetComponent(Text).text = attrstr
    if attrstr == "" then
        info_panel.transform:FindChild("I18NAttrsDescText_Front").gameObject:SetActive(false)
    else
        info_panel.transform:FindChild("I18NAttrsDescText_Front").gameObject:SetActive(true)
    end

    info_panel.transform:FindChild("DescObject1/DescText"):GetComponent(Text).text = skilldata.locate
    info_panel.transform:FindChild("DescObject2/DescText"):GetComponent(Text).text = skilldata.dmg
    info_panel.transform:FindChild("DescObject3/DescText"):GetComponent(Text).text = skilldata.cooldown.. TI18N("回合")
    info_panel.transform:FindChild("DescObject4/DescText"):GetComponent(Text).text = skilldata.cost_mp.. TI18N("魔法")
    -- info_panel.transform:FindChild("UpgradeDescText"):GetComponent(Text).text = skilldata.lev_desc
    if data.id == 69511 or data.id == 69009 or data.id == 20009 then
        info_panel.transform:FindChild("DescObject1"):GetComponent(RectTransform).anchoredPosition = Vector2(-41, -65)
        info_panel.transform:FindChild("DescObject2"):GetComponent(RectTransform).anchoredPosition = Vector2(114, -65)
        info_panel.transform:FindChild("DescObject3"):GetComponent(RectTransform).anchoredPosition = Vector2(-41, -95)
        info_panel.transform:FindChild("DescObject4"):GetComponent(RectTransform).anchoredPosition = Vector2(114, -95)
    else
        info_panel.transform:FindChild("DescObject1"):GetComponent(RectTransform).anchoredPosition = Vector2(-41, -26)
        info_panel.transform:FindChild("DescObject2"):GetComponent(RectTransform).anchoredPosition = Vector2(114, -26)
        info_panel.transform:FindChild("DescObject3"):GetComponent(RectTransform).anchoredPosition = Vector2(-41, -56)
        info_panel.transform:FindChild("DescObject4"):GetComponent(RectTransform).anchoredPosition = Vector2(114, -56)
    end

    if skilldata.type == 0 then
        local talent = BaseUtils.copytab(DataSkillTalent.data_skill_talent[skilldata.id])
        local giftIcon
        if talent ~= nil then
            info_panel.transform:FindChild("GiftPanel").gameObject:SetActive(true)
            for i = 1, 3 do
                local open
                local lev = i
                giftIcon = info_panel.transform:FindChild("GiftPanel/GiftImage"..i).gameObject

                if (i ~= 3 and talent["talent"..i.."_lev"] <= skilldata.lev)
                    --[[or (i == 3 and SkillScriptManager.Instance.model.talent_3[skilldata.id])]] then
                    giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).color = Color.white
                    if i == 3 then
                        giftIcon.transform:FindChild("Text"):GetComponent(Text).text = TI18N("<color='#00ff00'>已激活</color>")

                        -- giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).sprite
                        --     = self.assetWrapper:GetSprite(self.iconPath[self.currclass], tostring(talent["talent"..i.."_icon"]))
                        if self.giftIconLoader[i] == nil then
                            self.giftIconLoader[i] = SingleIconLoader.New(giftIcon.transform:FindChild("GiftImage").gameObject)
                        end
                        self.giftIconLoader[i]:SetSprite(SingleIconType.SkillIcon, talent["talent"..i.."_icon"])
                    else
                        giftIcon.transform:FindChild("Text"):GetComponent(Text).text
                            = "<color='#ace92a'>Lv."..talent["talent"..i.."_lev"].."</color>"
                    end
                    open = true
                else
                    if i == 3 then
                        giftIcon.transform:FindChild("Text"):GetComponent(Text).text = TI18N("<color='#00ff00'>已激活</color>")

                        -- giftIcon.transform:FindChild("GiftImage"):GetComponent(Image).sprite
                        --     = self.assetWrapper:GetSprite(self.iconPath[self.currclass], tostring(talent["talent"..i.."_icon"]))
                        if self.giftIconLoader[i] == nil then
                            self.giftIconLoader[i] = SingleIconLoader.New(giftIcon.transform:FindChild("GiftImage").gameObject)
                        end
                        self.giftIconLoader[i]:SetSprite(SingleIconType.SkillIcon, talent["talent"..i.."_icon"])
                    else
                        giftIcon.transform:FindChild("Text"):GetComponent(Text).text
                            = "<color='#91b1b8'>Lv."..talent["talent"..i.."_lev"].."</color>"
                    end
                    open = false
                end

                local talentTipsData = { id = talent.id, lev = lev, name = talent["talent"..lev.."_name"], icon = talent["talent"..lev.."_icon"]
                                    , desc = talent["talent"..lev.."_desc"], desc2 = talent["talent"..lev.."_desc2"], open = open }
                local btn = giftIcon:GetComponent(Button)
                btn.onClick:RemoveAllListeners()
                btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = giftIcon, type = Skilltype.roletalent, skillData = talentTipsData}) end)
            end
        else
            info_panel.transform:FindChild("GiftPanel").gameObject:SetActive(false)
        end
    else
        info_panel.transform:FindChild("GiftPanel").gameObject:SetActive(false)
    end

end
