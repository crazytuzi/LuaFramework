NewMarrySkillWindow = NewMarrySkillWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function NewMarrySkillWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.newmarryskillwindow
    self.name = "NewMarrySkillWindow"
    self.resList = {
        {file = AssetConfig.newmarryskillwindow, type = AssetType.Main}
    }

    -----------------------------------------
    self.skillList = {}
    self.skillIconLoaderList = {}
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end


function NewMarrySkillWindow:__delete()
    self:OnHide()
    for k, v in pairs(self.skillIconLoaderList) do
        v:DeleteMe()
        v = nil 
    end
    self.skillIconLoaderList = {}
    self:ClearDepAsset()
end

function NewMarrySkillWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newmarryskillwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.soltPanel = self.transform:FindChild("Main/Mask/SoltPanel").gameObject
    self.skillIcon = self.transform:FindChild("Main/SkillIcon").gameObject

    self:OnShow()
end

function NewMarrySkillWindow:Close()
    self.model.newTalent = {}

    self.model:CloseNewMarrySkillWindow()
end

function NewMarrySkillWindow:OnShow()
    self:UpdateList()
end

function NewMarrySkillWindow:OnHide()
end

function NewMarrySkillWindow:UpdateList()
    -- BaseUtils.dump(self.openArgs)
    local id = nil
    local lev = nil
    if self.openArgs ~= nil and #self.openArgs > 0 then
        id = self.openArgs[1]
        lev = self.openArgs[2]
    end

    local list = { self.model:getmarryskilldata(id, lev) }
    for k,v in pairs(list) do
        local icon = self.skillList[k]
        local loader = self.skillIconLoaderList[k]
        if icon == nil then
            icon = GameObject.Instantiate(self.skillIcon)
            UIUtils.AddUIChild(self.soltPanel, icon)
            table.insert(self.skillList, icon)

            loader = SingleIconLoader.New(icon.transform:FindChild("Image").gameObject)
            table.insert(self.skillIconLoaderList, loader)
        end
        self:SetItem(icon, v, loader)
    end

    self.transform:FindChild("Main/Text"):GetComponent(Text).text = string.format(TI18N("恭喜你们激活<color='#ffff00'>%s</color>，可在<color='#ffff00'>技能-伴侣</color>标签查看"), self.model:getmarryskilldata(id, lev).name)
end

function NewMarrySkillWindow:SetItem(item, data, loader)
    -- item.transform:FindChild("Image"):GetComponent(Image).sprite
    --                     = self.assetWrapper:GetSprite(AssetConfig.skillIcon_roleother, data.icon)
    loader:SetSprite(SingleIconType.SkillIcon, data.icon)

    item.transform:FindChild("Text"):GetComponent(Text).text = data.name

    local skillTipsData = data
    local btn = item:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = item, type = Skilltype.marryskill, skillData = skillTipsData}) end)
end