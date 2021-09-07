-- 清明植树面板
BuyBuyPanel = BuyBuyPanel or BaseClass(BasePanel)

function BuyBuyPanel:__init(parentGo)
    self.parentGo = parentGo
    self.name = "BuyBuyPanel"

    self.resList = {
        {file = AssetConfig.buybuy_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }

end

function BuyBuyPanel:OnInitCompleted()

end

function BuyBuyPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function BuyBuyPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.buybuy_panel))
    UIUtils.AddUIChild(self.parentGo, self.gameObject)
    self.gameObject.name = "BuyBuyPanel"
    self.transform = self.gameObject.transform

end