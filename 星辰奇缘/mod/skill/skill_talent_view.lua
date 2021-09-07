SkillTalentView = SkillTalentView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function SkillTalentView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.skilltalentwindow
    self.name = "SkillTalentView"
    self.resList = {
        {file = AssetConfig.skilltalentwindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.skillList = {}
    self.skillLoaderList = {}
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillTalentView:__delete()
    self:OnHide()
    for i, v in ipairs(self.skillLoaderList) do
        v:DeleteMe()
        v = nil
    end
    self.skillLoaderList = {}
    self:ClearDepAsset()
end

function SkillTalentView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skilltalentwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.soltPanel = self.transform:FindChild("Main/Mask/SoltPanel").gameObject
    self.talentIcon = self.transform:FindChild("Main/TalentIcon").gameObject

    self:OnShow()
end

function SkillTalentView:Close()
    self.model.newTalent = {}

    self.model:CloseSkillTalentWindow()
end

function SkillTalentView:OnShow()
    self:UpdateList()
end

function SkillTalentView:OnHide()
end

function SkillTalentView:UpdateList()
    local list = self.model.newTalent
    for k,v in pairs(list) do
        local icon = self.skillList[k]
        local iconLoader = self.skillLoaderList[k]
        if icon == nil then
            icon = GameObject.Instantiate(self.talentIcon)
            UIUtils.AddUIChild(self.soltPanel, icon)
            table.insert(self.skillList, icon)
            iconLoader = SingleIconLoader.New(icon.transform:FindChild("Image").gameObject) 
            table.insert(self.skillLoaderList, iconLoader)
        end
        self:SetItem(icon, v.data, v.lev, iconLoader)
    end
end

function SkillTalentView:SetItem(item, talent, lev, iconLoader)
    if lev == 3 then
        -- item.transform:FindChild("Image"):GetComponent(Image).sprite
        --                 = self.assetWrapper:GetSprite(BaseUtils.SkillIconPath(), tostring(talent["talent"..lev.."_icon"]))
        iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(talent["talent"..lev.."_icon"]))
    else
        -- item.transform:FindChild("Image"):GetComponent(Image).sprite
        --                 = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, tostring(talent["talent"..lev.."_icon"]))
        iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(talent["talent"..lev.."_icon"]))
    end

    item.transform:FindChild("Text"):GetComponent(Text).text = talent["talent"..lev.."_name"]

    local talentTipsData = { id = talent.id, lev = lev, name = talent["talent"..lev.."_name"], icon = talent["talent"..lev.."_icon"]
                                , desc = talent["talent"..lev.."_desc"], desc2 = talent["talent"..lev.."_desc2"], open = true }
    talentTipsData.sprite = item.transform:FindChild("Image"):GetComponent(Image).sprite
    local btn = item:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = item, type = Skilltype.roletalent, skillData = talentTipsData}) end)
end