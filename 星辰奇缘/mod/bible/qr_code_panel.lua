-- @author 黄耀聪
-- @date 2016年6月17日

QRCodePanel = QRCodePanel or BaseClass(BasePanel)

function QRCodePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "QRCodePanel"

    self.resList = {
        {file = AssetConfig.qr_code_panel, type = AssetType.Main}
        , {file = AssetConfig.qrcodebigbg, type = AssetType.Main}
        , {file = AssetConfig.qrcodetxt, type = AssetType.Main}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.imageName = nil
    self.imageCode = nil

end

function QRCodePanel:__delete()  --
    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

end

function QRCodePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.qr_code_panel))
    self.gameObject.name = "QRCodePanel"
    self.transform = self.gameObject.transform
    local t = self.transform:Find("MainPanel")
    UIUtils.AddUIChild(self.parent, self.gameObject)
    UIUtils.AddBigbg(self.transform:Find("Bigbg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.qrcodebigbg)))
    UIUtils.AddBigbg(t:Find("TitleTxt"), GameObject.Instantiate(self:GetPrefab(AssetConfig.qrcodetxt)))


    self.Desc2Content = t:Find("UrlContent/Con/Desc2Content"):GetComponent(Text)   --二维码链接
    self.CodeImage = t:Find("CodeImage"):GetComponent(Image)  --二维码图片
    self.CodeImage.gameObject:SetActive(false)

    self.panel = t:Find("Panel")
    self.panel:GetComponent(Button).onClick:AddListener(function()  self:ChangeScaleQRCodeImg(false)  end)
    self.CodeImage.transform:GetComponent(Button).onClick:AddListener(function() self:ChangeScaleQRCodeImg(true) end)

    self.SaveButton = t:Find("SaveButton"):GetComponent(Button)
    self.SaveButton.onClick:AddListener(function()
        --保存到相册
            local path = ctx.ResourcesPath .. "/../" .. self.imageName .. ".jpg"
            if Application.platform == RuntimePlatform.IPhonePlayer then
                path = ctx.ResourcesPath .. "/../" .. self.imageName .. ".jpg"
            elseif Application.platform == RuntimePlatform.Android then
                path = ctx.ResourcesPath .. "/../../../../../DCIM/" .. "Camera" .. "/" .. self.imageName .. ".jpg"
            end
            local bytes = self.imageCode:EncodeToJPG()
            Utils.WriteBytesPath(bytes, path)
            if Application.platform == RuntimePlatform.IPhonePlayer then
                -- -- if SdkManager.IsHasMethod("SdkCallFunc") then
                -- --     local result = SdkManager.Instance:SdkCallFunc("saveImageToPhotosAlbum",path)
                -- --     if result == "true" then
                -- --         NoticeManager.Instance:FloatTipsByString(TI18N("图片已保存"))
                -- --     else
                -- --         NoticeManager.Instance:FloatTipsByString(TI18N("请下载更高版本的app"))
                -- --     end
                -- -- else
                --     NoticeManager.Instance:FloatTipsByString(TI18N("请下载更高版本的app"))
                -- -- end

                local result = SdkManager.Instance:SdkCallFunc("saveImageToPhotosAlbum",path)
                if result == "true" then
                    NoticeManager.Instance:FloatTipsByString(TI18N("图片已保存"))
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("请下载更高版本的app"))
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("图片已保存"))
            end
     end)
    self.CopyButton = t:Find("CopyButton"):GetComponent(Button)
    self.CopyButton.onClick:AddListener(function()
        --复制链接
        if Application.platform == RuntimePlatform.IPhonePlayer then
            -- SdkManager.Instance:CopyContent(self.Desc2Content.text)
            Utils.CopyTextToClipboard(self.Desc2Content.text)
            NoticeManager.Instance:FloatTipsByString(TI18N("链接已复制到粘贴板"))
        elseif Application.platform == RuntimePlatform.Android then
            -- SdkManager.Instance:CopyContent(self.Desc2Content.text)
            Utils.CopyTextToClipboard(self.Desc2Content.text)
            NoticeManager.Instance:FloatTipsByString(TI18N("链接已复制到粘贴板"))
        end
    end)

    --ios渠道上新包前
    if --[[ctx.PlatformChanleId == 74 or--]] Application.platform == RuntimePlatform.IPhonePlayer then
        self.SaveButton.gameObject:SetActive(false)
        t:Find("UrlContent").anchoredPosition = Vector2(0,19)
        self.CopyButton.transform.anchoredPosition = Vector2(185,-162)
        t:Find("Desc").anchoredPosition = Vector2(0,-100)
    end


    local data = self.model.qrCodeData
    -- BaseUtils.dump(data)
    -- local data = {message = {l = "http://192.168.1.228/aaa.jpg", url = "www.123.com"}}
    local isContinue
    if data ~= nil then
        local listTmp = StringHelper.Split(data.message.qrcode_url, "/")
        self.imageName = string.sub(listTmp[#listTmp],1,-5)
        self.Desc2Content.text = data.message.url
        -- t:Find("UrlContent/Con"):GetComponent(RectTransform).sizeDelta = Vector2(self.Desc2Content.preferredWidth,30)

        local co = coroutine.create(function()
            local w = WWW(data.message.qrcode_url)

            isContinue = true
            while not w.isDone do
                coroutine.yield()
            end
            isContinue = false

            -- print(w.error)
            if w.error then
                -- failcb(w.error)
                self.Desc2Content.text = "data   exception"
            else
                if self.CodeImage ~= nil then
                    local sprite = Sprite.Create(w.texture, Rect(0, 0, w.texture.width, w.texture.height), Vector2(0.5, 0.5), 1)
                    self.imageCode = w.texture
                    self.CodeImage.sprite = sprite
                    self.CodeImage.gameObject:SetActive(true)
                end
            end

            w:Dispose()
        end)

        coroutine.resume(co)

        local moduleFixedUpdate = {}

        self.timerId = LuaTimer.Add(0, 200,
        function()
            if isContinue then
                coroutine.resume(co)
            else
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
            end
        end)

        -- ctx:GetRemoteData(data.message.qrcode_url, function(www)
        --     if www ~= nil then
        --         -- print(www .. "----------GetRemoteData===")
        --         local texture = www.texture
        --         local sprites = Sprite.Create(texture, Rect(0, 0, texture.width, texture.height), Vector2(0.5, 0.5))
        --         self.CodeImage.sprite = sprites
        --         www:Dispose()
        --         self.CodeImage.gameObject:SetActive(true)
        --     else
        --         print("www is nil ----------GetRemoteData===")
        --     end
        -- end, 1, "error_")
    else
        self.Desc2Content.text = "data exception"
    end
end

function QRCodePanel:OnInitCompleted()  --资源加载完毕
    self.OnOpenEvent:Fire()  --回调
end

function QRCodePanel:OnOpen()  --打开的时候
    -- self:RemoveListeners()  --删除事件
    -- EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListener)  --增加事件

    -- self:InitUI()  --初始化UI界面
end

function QRCodePanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function QRCodePanel:RemoveListeners()
    -- EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListener)
end




function QRCodePanel:ChangeScaleQRCodeImg(on_off)
    self.panel.gameObject:SetActive(on_off)
    if on_off then
        self.CodeImage.transform.anchoredPosition = Vector2(-95,20)
        self.CodeImage.transform.sizeDelta = Vector2(320,320)
    else
        self.CodeImage.transform.anchoredPosition = Vector2(0,20)
        self.CodeImage.transform.sizeDelta = Vector2(126,126)
    end
end


function QRCodePanel:IsMixPlatformChanle()

end
