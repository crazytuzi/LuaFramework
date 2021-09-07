Marry_DivorceView = Marry_DivorceView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_DivorceView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_divorce_window
    self.name = "Marry_DivorceView"
    self.resList = {
        {file = AssetConfig.marry_divorce_window, type = AssetType.Main}
    }

    -----------------------------------------
    self.type = 2

    -----------------------------------------
end

function Marry_DivorceView:__delete()
    self:ClearDepAsset()
end

function Marry_DivorceView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_divorce_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.buttonText1 = self.transform:FindChild("Main/Button1/Text"):GetComponent(Text)
    self.buttonText2 = self.transform:FindChild("Main/Button2/Text"):GetComponent(Text)
    self.buttonText3 = self.transform:FindChild("Main/Button3/Text"):GetComponent(Text)

    self.text1 = self.transform:FindChild("Main/Text1"):GetComponent(Text)
    self.text2 = self.transform:FindChild("Main/Text2"):GetComponent(Text)
    self.text3 = self.transform:FindChild("Main/Text3"):GetComponent(Text)

    self.transform:FindChild("Main/Button1"):GetComponent(Button).onClick:AddListener(function() self:Button1_Click() end)
    self.transform:FindChild("Main/Button2"):GetComponent(Button).onClick:AddListener(function() self:Button2_Click() end)
    self.transform:FindChild("Main/Button3"):GetComponent(Button).onClick:AddListener(function() self:Button3_Click() end)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.type = self.openArgs[1]
        self:Update()
    end
end

function Marry_DivorceView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_divorce_window)
end

function Marry_DivorceView:Update()
	if self.type == 1 then
		self.buttonText1.text = TI18N("取消婚约 50万银币")
        self.text1.text = TI18N("未婚伴侣解除当前订婚状态")

        self.transform:FindChild("Main/Button2").gameObject:SetActive(false)
        self.transform:FindChild("Main/Button3").gameObject:SetActive(false)

        self.text2.gameObject:SetActive(false)
        self.text3.gameObject:SetActive(false)
	end
end

function Marry_DivorceView:Button1_Click()
    if self.type == 1 then
        MarryManager:Send15020(3)
    else
    	MarryManager:Send15020(1)
    end
	self:Close()
end

function Marry_DivorceView:Button2_Click()
	MarryManager:Send15020(2)
	self:Close()
end

function Marry_DivorceView:Button3_Click()
	MarryManager:Send15020(3)
	self:Close()
end