FriendPushWindow = FriendPushWindow or BaseClass(BaseWindow)

function FriendPushWindow:__init(model)
    self.model = model
    self.name = "FriendPushWindow"
    self.currpage = nil
    self.friendMgr = self.model.friendMgr
    self.resList = {
        {file = AssetConfig.friendpush_window, type = AssetType.Main}
        -- ,{file = AssetConfig.infoicon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.chat_window_res, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
    }

end

function FriendPushWindow:__delete()
    self:ClearDepAsset()
end

function FriendPushWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.friendpush_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.inputfield = self.transform:Find("Main/InputCon/InputField"):GetComponent(InputField)
    local ipf = self.inputfield
    local textcom = self.inputfield.transform:Find("Text"):GetComponent(Text)
    local placeholder = self.inputfield.transform:Find("Placeholder"):GetComponent(Text)
    ipf.textComponent = textcom
    ipf.placeholder = placeholder

    self.Con1 = self.transform:Find("Main/ItemPanel/Con1")
    self.Con2 = self.transform:Find("Main/ItemPanel/Con2")
    self:SetInput()
    self.friendMgr:Require11810()
end

function FriendPushWindow:Close()
    self.model:ClosePushWindow()
end

function FriendPushWindow:ShowPlayer()
    for i,v in ipairs(self.friendMgr.pushList) do
        local item
        if i < 4 then
            item = self.Con1:Find(string.format("FriendItem%s", tostring(i)))
            self:SetPlayer(item, v)
        else
            item = self.Con2:Find(string.format("FriendItem%s", tostring(i-3)))
            self:SetPlayer(item, v)
        end
    end
end

function FriendPushWindow:SetPlayer(item, data)
    local csname = string.format("%s_%s", tostring(data.classes), tostring(data.sex))
    item:Find("name"):GetComponent(Text).text = data.name
    item:Find("head"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, csname)
    item:Find("level"):GetComponent(Text).text = data.lev
    item:Find("ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  data.classes)
    item:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowPlayer(data) end)
    item.gameObject:SetActive(true)
end

function FriendPushWindow:SetInput()
    local callback = function()
        if self.inputfield.text ~= "" then
            self.friendMgr:Require11808(self.inputfield.text)
        else

        end
    end
    self.transform:Find("Main/btnFind"):GetComponent(Button).onClick:AddListener(callback)
end