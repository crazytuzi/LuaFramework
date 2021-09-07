ExquisiteShelfItem = ExquisiteShelfItem or BaseClass()

function ExquisiteShelfItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    local t = self.transform

    self.bgContainer = t:Find("Bg")
    self.modelContainer = t:Find("Model")
    self.levText = t:Find("Lev"):GetComponent(Text)
    self.lockObj = t:Find("Lock").gameObject
    self.button = self.gameObject:GetComponent(Button)
    self.select = t:Find("Select")

    local go = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.exquisite_select))
    go.transform:SetParent(self.select:Find("Left"))
    go.transform.localScale = Vector3.one
    go.transform.anchorMax = Vector2(0, 1)
    go.transform.anchorMin = Vector2(0, 1)
    go.transform.pivot = Vector2(0, 1)
    go.transform.anchoredPosition = Vector2(-14.1,15.4)
    go = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.exquisite_select))
    go.transform:SetParent(self.select:Find("Right"))
    go.transform.localScale = Vector3(-1,1,1)
    go.transform.anchorMax = Vector2(1, 1)
    go.transform.anchorMin = Vector2(1, 1)
    go.transform.pivot = Vector2(0, 1)
    go.transform.anchoredPosition = Vector2(14.1,15.4)

    self.renderers = self.gameObject:GetComponentsInChildren(Image, true)
    self.button.onClick:AddListener(function() self:OnClick() end)
end

function ExquisiteShelfItem:__delete()
    self.assetWrapper = nil
    if self.nameImage ~= nil then
        BaseUtils.ReleaseImage(self.nameImage)
    end
    self.gameObject = nil
    self.model = nil
end

function ExquisiteShelfItem:SetData(data, index)
    self.data = data
    self.index = index
    self.levText.text = string.format("Lv.%s~%s", data.min_lev, data.max_lev)

    if RoleManager.Instance.RoleData.lev < data.min_lev then
        self.lockObj:SetActive(true)
        self:SetDark(false)
    elseif RoleManager.Instance.RoleData.lev <= data.max_lev then
        self.lockObj:SetActive(false)
        self:SetDark(false)
    else
        self.lockObj:SetActive(false)
        self:SetDark(true)
    end

    self:Select(false)
end

function ExquisiteShelfItem:SetDark(bool)
    if bool then
        for _,renderer in pairs(self.renderers) do
            renderer.color = Color(0.5, 0.5, 0.5)
            -- renderer.color = Color(0.299,0.587,0.184)
        end
    else
        for _,renderer in pairs(self.renderers) do
            renderer.color = Color(1, 1, 1)
        end
    end
end

function ExquisiteShelfItem:SetGray(bool)
    local GreyMat = nil
    if bool then
        GreyMat = PreloadManager.Instance:GetMainAsset("textures/materials/grey.unity3d")
        for _,renderer in pairs(self.renderers) do
            renderer.material = GreyMat
        end
    else
        for _,renderer in pairs(self.renderers) do
            renderer.material = nil
        end
    end
end

function ExquisiteShelfItem:OnClick()
    if self.clickCallback ~= nil and self.index ~= nil then
        self.clickCallback(self.index)
    end
end

function ExquisiteShelfItem:Select(bool)
    self.select.gameObject:SetActive(bool)
end
