-- ----------------------------------------------------------
-- UI - 断线重连
-- ----------------------------------------------------------
ReconnectView = ReconnectView or BaseClass(BasePanel)

function ReconnectView:__init(model)
    self.model = model
    self.name = "ReconnectView"
    self.resList = {
        {file = AssetConfig.reconnect, type = AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.font, type = AssetType.Dep}
    }

    self.name = "ReconnectView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------------------
    self.showType = 0
    self.timerId = 0
    self.loadingImage_trans = nil
    self.loading_callback = function(id) self:Update_LoadingImage(id) end
end

function ReconnectView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    LuaTimer.Delete(self.timerId)
end

function ReconnectView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.reconnect))
    self.gameObject.name = "ReconnectView"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    self.panel1 = self.transform:FindChild("Panel1").gameObject
    self.panel2 = self.transform:FindChild("Panel2").gameObject
    self.loadingImage_trans = self.transform:FindChild("Panel1/Loading")
    self.button = self.transform:FindChild("Panel2/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:Button_Click() end)

    self:ShowType()
end

function ReconnectView:ShowType(showType)
    if showType ~= nil then
        self.showType = showType
    end
    if self.gameObject ~= nil then
        if self.showType == 1 then
            self:Reconnect()
        elseif self.showType == 2 then
            self:RetrunToLogin()
        end
    end
end

function ReconnectView:Reconnect()
    self.panel1:SetActive(true)
    self.panel2:SetActive(false)
	LuaTimer.Delete(self.timerId)
	LuaTimer.Add(0, 100, self.loading_callback)
	-- Connection.Instance:reconnect()
end

function ReconnectView:Update_LoadingImage(id)
	self.timerId = id
	if BaseUtils.is_null(self.loadingImage_trans) then
        LuaTimer.Delete(self.timerId)
    else
	    self.loadingImage_trans:Rotate(Vector3(0, 0, -45))
	end
end

function ReconnectView:RetrunToLogin()
    self.panel1:SetActive(false)
    self.panel2:SetActive(true)
    LuaTimer.Delete(self.timerId)
end

function ReconnectView:Button_Click()
    Connection.Instance:CloseReconnectView()
    LoginManager.Instance:returnto_login()
end