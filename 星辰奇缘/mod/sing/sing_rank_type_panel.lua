SingRankTypePanel  =  SingRankTypePanel or BaseClass(BasePanel)

function SingRankTypePanel:__init(parent)
    self.parent = parent

    self.name  =  "SingRankTypePanel"
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.singranktypepanel, type  =  AssetType.Main}
        , {file  =  AssetConfig.sing_res, type  =  AssetType.Dep}
    }

    ------------------------------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SingRankTypePanel:OnHide()
end

function SingRankTypePanel:OnShow()
    self:Update()
end

function SingRankTypePanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end


function SingRankTypePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.singranktypepanel))
    self.gameObject.name = "SingRankTypePanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.closeButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeButton.onClick:AddListener(function() self:OnClose() end)

    self.transform:Find("Main/RankType1"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton1() end)
    self.transform:Find("Main/RankType2"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton2() end)

    self:Update()
end

function SingRankTypePanel:OnClose()
    -- WindowManager.Instance:CloseWindow(self)
    SingManager.Instance.model:CloseSingRankTypePanel()
end

function SingRankTypePanel:Update()

end

function SingRankTypePanel:OnClickButton1()
    if self.openArgs ~= nil and self.openArgs.list1 ~= nil then
        SingManager.Instance.model:OpenMultiItem(self.parent, {list = self.openArgs.list1})
        self:OnClose()
    end
end

function SingRankTypePanel:OnClickButton2()
    if self.openArgs ~= nil and self.openArgs.list2 ~= nil then
        SingManager.Instance.model:OpenMultiItem(self.parent, {list = self.openArgs.list2})
        self:OnClose()
    end
end