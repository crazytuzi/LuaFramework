
-- @author zyh
BigBgPanel = BigBgPanel or BaseClass(BasePanel)

function BigBgPanel:__init(model,parent,bg)
    self.model = model
    self.parent = parent
    self.name = "BigBgPanel"
    self.bg = bg

    self.resList = {
        {file = AssetConfig.GameBgPanel, type = AssetType.Main},
        {file = self.bg,type = AssetType.Main}
    }

    -- self.OnOpenEvent:AddListener(function()
    --     self:UpdatePanel()
    -- end)
end

function BigBgPanel:OnInitCompleted()
end

function BigBgPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function BigBgPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.GameBgPanel))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.bigBg = self.transform:Find("Bg")
    self.bigObj = GameObject.Instantiate(self:GetPrefab(self.bg))
    UIUtils.AddBigbg(self.bigBg,self.bigObj)

    if self.bg == AssetConfig.GameBgTwo then
        self.bigBg.anchoredPosition = Vector2(0,-7.4)
        self.bigBg.localScale = Vector3(1,0.96,1)
    elseif self.bg == AssetConfig.twoyearbigbg then
        self.bigBg.anchoredPosition = Vector2(5,-28)
    end



end



