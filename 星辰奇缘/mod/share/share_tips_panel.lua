-- ----------------------------------
-- 分享输入小界面
-- hosr
-- ----------------------------------
ShareTipsPanel = ShareTipsPanel or BaseClass(BasePanel)

function ShareTipsPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.sharebindtipspanel, type = AssetType.Main},
		{file = AssetConfig.shareres, type = AssetType.Dep},
		{file = AssetConfig.guidegirl2, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ShareTipsPanel:__delete()
end

function ShareTipsPanel:OnShow()
end

function ShareTipsPanel:OnHide()
end

function ShareTipsPanel:Close()
	self.model:CloseTipsPanel()
end

function ShareTipsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sharebindtipspanel))
    self.gameObject.name = "ShareBindPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidegirl2, "GuideGirl2")

    self.title = self.transform:Find("Main/Title"):GetComponent(Text)
    self.input = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.sure = self.transform:Find("Main/Sure"):GetComponent(Button)
    self.cancel = self.transform:Find("Main/Cancel"):GetComponent(Button)

    self.sure.onClick:AddListener(function() self:ClickSure() end)
    self.cancel.onClick:AddListener(function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
end

function ShareTipsPanel:ClickSure()
	if self.input.text == "" then
		return
	end
	local key = self.input.text
	ShareManager.Instance:Send17500(key)
	self:Close()
end