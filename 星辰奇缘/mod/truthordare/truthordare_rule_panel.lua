-- ----------------------------------------------------------
-- UI - 真心话大冒险
-- ----------------------------------------------------------
TruthordareRulePanel = TruthordareRulePanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TruthordareRulePanel:__init(model)
    self.model = model
    self.name = "TruthordareRulePanel"

    self.resList = {
        {file = AssetConfig.truthordarerulepanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    self.currentIndex = 0
    self.itemList = {}

	------------------------------------------------
	self.tabGroup = nil
	self.tabGroupObj = nil

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function TruthordareRulePanel:__delete()
    self:OnHide()

    self:AssetClearAll()
end

function TruthordareRulePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordarerulepanel))
    self.gameObject.name = "TruthordareRulePanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup")    --侧边栏


    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function TruthordareRulePanel:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TruthordareRulePanel:OnShow()
end

function TruthordareRulePanel:OnHide()
    
end