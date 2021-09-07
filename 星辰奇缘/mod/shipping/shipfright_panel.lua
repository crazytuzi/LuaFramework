ShipFrightPanel = ShipFrightPanel or BaseClass(BasePanel)


function ShipFrightPanel:__init()
    self.mgr = ShippingManager.Instance
    self.model = ShippingManager.Instance.model
    self.path = "prefabs/ui/shipping/shippingfrightpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
        ,{file = AssetConfig.shiptextures, type = AssetType.Dep}
    }
    self.name = "ShipFrightPanel"


end

function ShipFrightPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end
-- args {needid =1, rid = 1, platform = "dev", zone_id = zoenid, type = "求助类型"}
function ShipFrightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.Get = self.transform:Find("Main/Get"):GetComponent(Text)
    self.Curr = self.transform:Find("Main/Curr"):GetComponent(Text)
    self:Update(self.model.fright_data)
end

function ShipFrightPanel:Update(data)
    self.Get.text = string.format(TI18N("已夺回物资:<color='#ffff00'>%s</color>"), tostring(data.num))
    self.Curr.text = string.format(TI18N("当前第<color='#ffff00'>%s</color>波海盗"), tostring(data.wave))
end