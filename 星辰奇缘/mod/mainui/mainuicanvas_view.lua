-- 主界面Canvas
MainUICanvasView = MainUICanvasView or BaseClass(BaseView)

function MainUICanvasView:__init()
    self.model = model
    self.winLinkType = WinLinkType.Single
	self.resList = {
        {file = AssetConfig.mainui_canvas, type = AssetType.Main}
    }

    self.name = "MainUICanvasView"

    self.gameObject = nil
    self.transform = nil

    self.fps = nil
    self.timerId = 0
    self.server = nil

    self:LoadAssetBundleBatch()

    self.openGmWin = function()
        GmManager.Instance:OpenGmWindow()
    end
    self.openConsole = function()
        -- ctx.GameConsole.panel:SetActive(not ctx.GameConsole.panel.activeSelf)
    end

    self.rect = nil
end

function MainUICanvasView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MainUICanvasView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mainui_canvas))
    self.gameObject.name = "MainUICanvasView"
    self.gameObject.transform:SetParent(ctx.CanvasContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1000)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one
    self.rect = rect

    self.transform = self.gameObject.transform

    MainUIManager.Instance:initRoleInfoView()
    MainUIManager.Instance:initPetInfoView()
    MainUIManager.Instance:initMapInfoView()
    MainUIManager.Instance:initExpInfoView()
    MainUIManager.Instance:initPlayerInfoView()
    MainUIManager.Instance:initNoticeView()
    MainUIManager.Instance:initSystemView()
    MainUIManager.Instance:initClicknpcView()
    MainUIManager.Instance:initBaseFunctionIconArea()

    self.fps = self.gameObject.transform:FindChild("FPS"):GetComponent(Text)
    self.fps.text = "fps:0"
    self.server = self.gameObject.transform:FindChild("FPS/Text"):GetComponent(Text)
    self.server.text = TI18N("本服")

    self.timeStamp = Time.realtimeSinceStartup
    self.frameStamp = Time.frameCount
    EventMgr.Instance:Fire(event_name.mainui_loaded)

    local isWhite = self:InWhiiteList()
    if IS_DEBUG then
        LuaTimer.Add(0, 200, function(id) self:ShowFPS(id) end)
        -- self.gameObject.transform:FindChild("FPS").gameObject:GetComponent(Button).onClick:AddListener(self.openGmWin)
        self.gameObject.transform:FindChild("FPS").gameObject:GetComponent(Button).enabled = false
        self.gameObject.transform:Find("FPS/GM"):GetComponent(Button).onClick:AddListener(self.openGmWin)
    elseif isWhite then
        LuaTimer.Add(0, 200, function(id) self:ShowFPS(id) end)
        self.gameObject.transform:Find("FPS/GM").gameObject:SetActive(false)
    else
        if ctx.CdnPath == "http://cdnres.xcqy.shiyuegame.com/xcqy" then
            LuaTimer.Add(0, 200, function(id) self:ShowFPS(id) end)
            self.gameObject.transform:Find("FPS/GM").gameObject:SetActive(false)
        else
            self.gameObject.transform:FindChild("FPS").gameObject:SetActive(false)
            self.gameObject.transform:Find("FPS/GM").gameObject:SetActive(false)
        end
    end
    self:ClearMainAsset()

    self:ShowServer()
end

function MainUICanvasView:ShowFPS(id)
    self.timerId = id
    local f = (Time.frameCount - self.frameStamp) / (Time.realtimeSinceStartup - self.timeStamp)
    self.fps.text = "FPS:"..math.floor(f)
    self.timeStamp = Time.realtimeSinceStartup
    self.frameStamp = Time.frameCount
end

function MainUICanvasView:OutFPS(bool)
    if bool then
        self.fps.gameObject.transform.localPosition = Vector3(60, 255, 0)
    else
        self.fps.gameObject.transform.localPosition = Vector3(-400, 255, 0)
    end
end

function MainUICanvasView:ShowServer()
    if self.server == nil then
        return
    end

    if RoleManager.Instance.RoleData.cross_type == 0 then
        self.server.text = TI18N("本服")
    else
        self.server.text = TI18N("跨服")
    end
end

function MainUICanvasView:InWhiiteList()
    local account = ""
    if RoleManager.Instance.RoleData ~= nil then
        account = RoleManager.Instance.RoleData.account
    end
    local platformId = tostring(ctx.PlatformChanleId)
    for _, data in ipairs(LoginConfig.WhiteList) do
        local waccount = data .. platformId
        if waccount == account then
            return true
        end
    end
    return false
end
