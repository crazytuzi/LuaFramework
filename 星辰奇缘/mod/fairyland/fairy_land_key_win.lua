FairyLandKeyWindow = FairyLandKeyWindow or BaseClass(BaseWindow)
-------------------------
--幻境宝箱
-------------------------
function FairyLandKeyWindow:__init(model)
    self.model = model
    self.name = "FairyLandKeyWindow"
    self.windowId = WindowConfig.WinID.fairy_land_key
    self.isHideMainUI = false
    self.resList = {
        {file = AssetConfig.fairy_landkey_tipswin, type = AssetType.Main}
    }

end

function FairyLandKeyWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FairyLandKeyWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fairy_landkey_tipswin))
    self.gameObject.name = "FairyLandKeyWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("MainCon").gameObject
end