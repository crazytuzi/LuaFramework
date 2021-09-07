Marry_RequestView = Marry_RequestView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_RequestView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_request_window
    self.name = "Marry_RequestView"
    self.resList = {
        {file = AssetConfig.marry_request_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }

    -----------------------------------------
    self.Button = nil

    self.PlayerItem = nil

    self.inviteCount = 0
    -----------------------------------------
end

function Marry_RequestView:__delete()
    self:ClearDepAsset()
end

function Marry_RequestView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_request_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/Mask")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("Main/Mask/SoltPanel"), setting)

    self.PlayerItem = self.transform:Find("Main/PlayerItem").gameObject

    self:Update()
end

function Marry_RequestView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_request_window)
end

function Marry_RequestView:Update()
    local roleData = RoleManager.Instance.RoleData
    local loverData = MarryManager.Instance.loverData


    self:UpdateFriend()
end

function Marry_RequestView:UpdateFriend()
-- BaseUtils.dump(MarryManager.Instance.model.requestData)
    self.list = {}
    for _, value in pairs(MarryManager.Instance.model.requestData) do
        self.list[BaseUtils.Key(value.id, value.platform, value.zone_id)] = value
    end

    local parent = self.transform:Find("Main/Mask/SoltPanel").gameObject
    for k,v in pairs(self.list) do
        local uid = k
        local item = parent.transform:Find(uid)
        if item == nil then
            item = GameObject.Instantiate(self.PlayerItem)
        else
            item.gameObject:SetActive(false)
        end
        item.gameObject.name = uid

        self:SetPlayerItem(item, v)
        self.Layout:AddCell(item.gameObject)
    end

    self.Layout:ReSize()
end


function Marry_RequestView:SetPlayerItem(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.classes, data.sex)
    -- if data.online == 1 then
    --     its:Find("Head"):GetComponent(Image).color = Color(1,1,1)
    --     its:Find("name"):GetComponent(Text).color = Color(1,1,1)
    -- else
    --     its:Find("Head"):GetComponent(Image).color = Color(0.5, 0.5, 0.5)
    --     its:Find("name"):GetComponent(Text).color = Color(0.5, 0.5, 0.5)
    -- end
    its:Find("LevText"):GetComponent(Text).text = tostring(data.lev)
    its:Find("ClassText"):GetComponent(Text).text = KvData.classes_name[data.classes]
    its:Find("name"):GetComponent(Text).text = data.name

    local okButton = its:Find("OkButton"):GetComponent(Button)
    okButton.onClick:AddListener(function() self:OkButtonClick(its, { rid = data.id, platform = data.platform, zone_id = data.zone_id}) end)

    local noButton = its:Find("NoButton"):GetComponent(Button)
    noButton.onClick:AddListener(function() self:NoButtonClick(its, { rid = data.id, platform = data.platform, zone_id = data.zone_id}) end)
end

function Marry_RequestView:GetClassIcon(classes)
    local sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(classes))
    return sprite
end

function Marry_RequestView:GetHead(classes, sex)
    local name = classes .. "_" .. sex
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    return sprite
end

function Marry_RequestView:OkButtonClick(its, data)
    its:Find("OkButton").gameObject:SetActive(false)
    its:Find("NoButton").gameObject:SetActive(false)
    its:Find("descText").gameObject:SetActive(true)
    its:Find("descText"):GetComponent(Text).text = TI18N("已同意")
    MarryManager.Instance:Send15005(1, {data})

    MarryManager.Instance.model.requestData[BaseUtils.Key(data.rid, data.platform, data.zone_id)] = nil
    EventMgr.Instance:Fire(event_name.marry_data_update)
end

function Marry_RequestView:NoButtonClick(its, data)
    its:Find("OkButton").gameObject:SetActive(false)
    its:Find("NoButton").gameObject:SetActive(false)
    its:Find("descText").gameObject:SetActive(true)
    its:Find("descText"):GetComponent(Text).text = TI18N("已拒绝")
    MarryManager.Instance:Send15005(2, {data})

    MarryManager.Instance.model.requestData[BaseUtils.Key(data.rid, data.platform, data.zone_id)] = nil
    EventMgr.Instance:Fire(event_name.marry_data_update)
end
