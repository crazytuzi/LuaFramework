Marry_TheinvitationView = Marry_TheinvitationView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_TheinvitationView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_theinvitation_window
    self.name = "Marry_TheinvitationView"
    self.resList = {
        {file = AssetConfig.marry_theinvitation_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.text = nil 
    self.itemSolt = nil 
    self.okButton = nil
    self.noButton = nil
    -----------------------------------------
end

function Marry_TheinvitationView:__delete()
    self:ClearDepAsset()
end

function Marry_TheinvitationView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_theinvitation_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    
end

function Marry_TheinvitationView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_theinvitation_window)
end

function Marry_TheinvitationView:Update()
	

end

function Marry_TheinvitationView:okButtonClick()
	self:Close()
end

function Marry_TheinvitationView:noButtonClick()
	self:Close()
end