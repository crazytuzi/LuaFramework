-- ----------------------------------------------------------
-- UI - 创建家园窗口
-- ljh 20160712
-- ----------------------------------------------------------
CreateHomeView = CreateHomeView or BaseClass(BaseWindow)

function CreateHomeView:__init(model)
    self.model = model
    self.name = "CreateHomeView"
    self.windowId = WindowConfig.WinID.CreateHomeView

    self.resList = {
        {file = AssetConfig.createhomewindow, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
        , {file  =  AssetConfig.totembg, type  =  AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------

    ------------------------------------------------

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function CreateHomeView:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CreateHomeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.createhomewindow))
    self.gameObject.name = "CreateHomeView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:Find("ToTemBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)



    self.mainTransform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickOkButton() end)
    ----------------------------

    self:OnShow()
end

function CreateHomeView:OnClickClose()
    self:OnHide()
    WindowManager.Instance:CloseWindow(self)
end

function CreateHomeView:OnShow()
    self:update()
end

function CreateHomeView:OnHide()

end

function CreateHomeView:update()
    local own = RoleManager.Instance.RoleData.coin
    self.mainTransform:FindChild("CostItem/NumText"):GetComponent(Text).text = tostring(own)
	local cost = DataFamily.data_create_cost[1].cost
    local costNumText = self.mainTransform:FindChild("CostItem2/NumText"):GetComponent(Text)
    costNumText.text = cost[1][2]
    if own < cost[1][2] then
        costNumText.color = Color(1,1,1)
    end
end

function CreateHomeView:OnClickOkButton()
	HomeManager.Instance:Send11201()
    self:OnClickClose()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gethome)
end