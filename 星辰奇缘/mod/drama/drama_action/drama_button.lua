-- ---------------------------
-- 剧情遮挡层
-- hosr
-- ---------------------------
DramaButton = DramaButton or BaseClass(BaseDramaPanel)

function DramaButton:__init(model)
    self.model = model
    self.path = "prefabs/ui/drama/dramabutton.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.callback = nil
end

function DramaButton:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function DramaButton:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "DramaButton"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero

    self.transform = self.gameObject.transform
    self.jumpBtnObj = self.transform:Find("Button").gameObject
    self.jumpBtn = self.jumpBtnObj:GetComponent(Button)

    self.jumpBtnObj:SetActive(false)

    self.jumpBtn.onClick:AddListener(function() self:ClickJump() end)
end

function DramaButton:OnInitCompleted()
    self:ShowJump(self.openArgs)
end

function DramaButton:ClickJump()
    -- self.model.normalActionModel.plotModel:JumpPlot()
    self.model:JumpPlot()
end

function DramaButton:ShowJump(bool)
    if not BaseUtils.is_null(self.jumpBtnObj) then
        self.jumpBtnObj:SetActive(bool)
    end
end