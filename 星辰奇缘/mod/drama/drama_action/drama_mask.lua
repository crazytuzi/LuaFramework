-- ---------------------------
-- 剧情遮挡层
-- hosr
-- ---------------------------
DramaMask = DramaMask or BaseClass(BaseDramaPanel)

function DramaMask:__init(model)
    self.model = model
    self.path = "prefabs/ui/drama/dramamask.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.white = Color(0,0,0,0)
    self.black = Color(0,0,0,1)
    self.callback = nil
end

function DramaMask:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function DramaMask:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    UIUtils.AddUIChild(self.model.dramaCanvas, self.gameObject)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    self.gameObject:SetActive(false)

    self.transform = self.gameObject.transform
    self.panelBtn = self.gameObject:GetComponent(Button)
    self.panelImg = self.gameObject:GetComponent(Image)
    self.panelImg.color = Color(0,0,0,0)

    self.panelBtn.onClick:AddListener(function() self:ClickPanel() end)

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function DramaMask:OnInitCompleted()
    -- if LoginManager.Instance.first_enter then
        -- self:BlackPanel(true)
    -- end
end

function DramaMask:ClickPanel()
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaMask:SetClickCallback(func)
    self.callback = func
end

function DramaMask:BlackPanel(bool)
    if bool then
        self.panelImg.color = self.black
    else
        self.panelImg.color = self.white
    end
    self.gameObject:SetActive(true)
end

function DramaMask:BlackPanelVal(val)
    self.panelImg.color = Color(0,0,0,val)
end
