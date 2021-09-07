-- @author 黄耀聪
-- @date 2016年5月31日

WingSkillNoticePanel = WingSkillNoticePanel or BaseClass(BasePanel)

function WingSkillNoticePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "WingSkillNoticePanel"
    self.mgr = WingsManager.Instance

    self.resList = {
        {file = AssetConfig.skilltalentwindow, type = AssetType.Main},
    }

    self.activeSkillString = TI18N("激活技能")
    self.activeDescString = TI18N("恭喜您翅膀升到%s阶，获得翅膀技能")

    self.skillList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingSkillNoticePanel:__delete()
    self.OnHideEvent:Fire()
    for i, v in ipairs(self.skillList) do
        v.loader:DeleteMe()
        v = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WingSkillNoticePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skilltalentwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.titleText = t:Find("Main/Title/Text"):GetComponent(Text)
    self.descText = t:Find("Main/I18N_Text"):GetComponent(Text)
    self.CloseButton = t:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.soltPanel = t:FindChild("Main/Mask/SoltPanel").gameObject
    self.talentIcon = t:FindChild("Main/TalentIcon").gameObject

    self.titleText.text = self.activeSkillString
    self.descText.text = string.format(self.activeDescString, BaseUtils.NumToChn(self.mgr.grade))
end

function WingSkillNoticePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingSkillNoticePanel:OnOpen()
    self:RemoveListeners()
    self:UpdateList()
end

function WingSkillNoticePanel:OnHide()
    self:RemoveListeners()
end

function WingSkillNoticePanel:RemoveListeners()
end

function WingSkillNoticePanel:Close()
    self.mgr:CloseSkillNotice()
end

function WingSkillNoticePanel:UpdateList()
    local list = self.mgr.tips_args
    for k,v in pairs(list) do
        local icon = self.skillList[k]
        if icon == nil then
            local go = GameObject.Instantiate(self.talentIcon)
            local loader = SingleIconLoader.New(go.transform:FindChild("Image").gameObject)
            icon = { go = go, loader = loader}
            table.insert(self.skillList, icon)
            UIUtils.AddUIChild(self.soltPanel, icon.go)
        end
        self:SetItem(icon, v)
    end
end

function WingSkillNoticePanel:SetItem(item, data)
    local lev = data.lev
    local id = data.id
    local wingData = DataSkill.data_wing_skill[id.."_"..lev]
    -- item.transform:FindChild("Image"):GetComponent(Image).sprite
    --                     = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(wingData.icon))
    item.loader:SetSprite(SingleIconType.SkillIcon, tostring(wingData.icon))
    item.go.transform:FindChild("Text"):GetComponent(Text).text = wingData.name


    -- local talentTipsData = { id = id, lev = lev, name = talent["talent"..lev.."_name"], icon = talent["talent"..lev.."_icon"]
    --                             , desc = talent["talent"..lev.."_desc"], desc2 = talent["talent"..lev.."_desc2"], open = true }
    -- talentTipsData.sprite = item.transform:FindChild("Image"):GetComponent(Image).sprite
    local btn = item.go:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = item.go, type = Skilltype.wingskill, skillData = wingData}) end)
end



