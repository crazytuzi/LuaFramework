CampBoxRightItem = CampBoxRightItem or BaseClass()

function CampBoxRightItem:__init(gameObject,isHasDoubleClick)
    self.gameObject = gameObject

    -- local resources = {
    --  {file = AssetConfig.toyreward_textures, type = AssetType.Dep}
    -- }
    -- self.assetWrapper = AssetBatchWrapper.New()
    -- self.assetWrapper:LoadAssetBundle(resources)

    self.text = self.gameObject.transform:GetComponent("Text")
end

function CampBoxRightItem:__delete()
end

function CampBoxRightItem:SetData(str)
    local num = 0 or n
    self.text.text = str
    local atuoH = self.text.preferredHeight;
    self.gameObject.transform.sizeDelta = Vector2(240, atuoH)
end

