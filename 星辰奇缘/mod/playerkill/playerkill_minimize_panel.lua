-- ------------------------
-- 英雄擂台最小化
-- ------------------------

PlayerkillMinimizePanel = PlayerkillMinimizePanel or BaseClass(BasePanel)

function PlayerkillMinimizePanel:__init(model)
    self.model = model
    self.name = "PlayerkillMinimizePanel"
    self.resList = {
        {file = AssetConfig.playkillminimize, type = AssetType.Main}
        , {file = AssetConfig.dailyicon, type = AssetType.Dep}
	}
end

function PlayerkillMinimizePanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.icon = nil
    self:AssetClearAll()
	PlayerkillManager.Instance.OnMatchSuccess:Remove(self.matchSuccessListener)
end

function PlayerkillMinimizePanel:Close()
    MainUIManager.Instance:ShowMainUICanvas(false)
    self.model:MaximizeMainWindow()
	self.model:CloseMinimizePanel()
end

function PlayerkillMinimizePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playkillminimize))
	self.gameObject.name = self.name
	self.transform = self.gameObject.transform

    self.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform, false)
    self.transform.localPosition = Vector3(0, 0, 0)
    self.transform.localScale = Vector3(1, 1, 1)

	self.icon = self.transform:Find("Waiting/Icon"):GetComponent(Image)
	self.desc = self.transform:Find("Waiting/TextBg/Text"):GetComponent(Text)
	self.desc.text = TI18N("等待中")

    self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, "1029")

	self.maximizationButton = self.transform:Find("Waiting"):GetComponent(Button)
	self.maximizationButton.onClick:AddListener(function() self:Close() end)

	self.matchSuccessListener = function() self:MatchSuccess() end

	self:AddListener()
end

function PlayerkillMinimizePanel:AddListener()
	PlayerkillManager.Instance.OnMatchSuccess:Add(self.matchSuccessListener)
end

function PlayerkillMinimizePanel:MatchSuccess()
	self:Close()
end
