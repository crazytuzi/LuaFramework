-- -----------------------------------
-- 返回主UI
-- hosr
-- -----------------------------------
MainuiBackView = MainuiBackView or BaseClass(BasePanel)

function MainuiBackView:__init()
    self.path = "prefabs/ui/mainui/backmainui.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }

    self.click = function() self:OnClick() end

    -- 窗口隐藏事件
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    -- 窗口打开事件
    self.OnOpenEvent:AddListener(function() self:OnShow() end)

    self.isOpen = true
end

function MainuiBackView:__delete()
    if not BaseUtils.is_null(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.isOpen = true
end

function MainuiBackView:InitPanel()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
    self.gameObject.name = "MainuiBackView"
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject , self.gameObject)

    self.transform = self.gameObject.transform
    self.transform:Find("Button"):GetComponent(Button).onClick:AddListener(self.click)

    self.transform:Find("Panel").gameObject:SetActive(false)

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if self.isOpen then
        self.gameObject:SetActive(true)
    end
end

function MainuiBackView:OnClick()
    GestureManager.Instance:SoBusy()
end

function MainuiBackView:OnShow()
    self.isOpen = false
end

function MainuiBackView:OnHide()
    self.isOpen = true
end