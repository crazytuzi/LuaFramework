-- 动态发送照片编辑面板
-- @author hzf
-- @date 2016年7月29日,星期五

MomentsPhotoEditPanel = MomentsPhotoEditPanel or BaseClass(BasePanel)

function MomentsPhotoEditPanel:__init(model, parent)
    self.Mgr = ZoneManager.Instance
    self.model = model
    self.parent = parent
    self.name = "MomentsPhotoEditPanel"
    self.tex2dList = {}
    self.photoList = {}
    self.thumbphotoList = {}
    self.origin = {}
    self.currindex = nil
    self.resList = {
        {file = AssetConfig.moment_photoedit_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MomentsPhotoEditPanel:__delete()
    if self.photoBtnList ~= nil then
        for k,v in pairs(self.photoBtnList) do
            v.Photo.sprite = nil
        end
    end
    for i,v in ipairs(self.tex2dList) do
        GameObject.Destroy(v)
    end
    self.tex2dList = nil
    self.photoList = {}
    self.thumbphotoList = {}
    self.photoBtnList = nil
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MomentsPhotoEditPanel:InitPanel()
    self:InitWebcam()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_photoedit_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.transform:Find("Bg"):GetComponent(Button).onClick:AddListener(function()
        self:Hiden()
    end)

    self.OKButton = self.transform:Find("Bg/OKButton"):GetComponent(Button)
    self.OKButton.onClick:AddListener(function()
        self:Hiden()
    end)
    self.CancelButton = self.transform:Find("Bg/CancelButton"):GetComponent(Button)
    self.CancelButton.onClick:AddListener(function()
        self.parent.photos = self.origin
        self:Hiden()
    end)

    self.photoBtnList = {}
    for i=1, 4 do
        self.photoBtnList[i] = {}
        self.photoBtnList[i].transform = self.transform:Find(string.format("Bg/PhotoCon/P%s", i))
        self.photoBtnList[i].NoImg = self.photoBtnList[i].transform:Find("NoImg").gameObject
        self.photoBtnList[i].Photo = self.photoBtnList[i].transform:Find("Photo"):GetComponent(Image)
        self.photoBtnList[i].btn = self.photoBtnList[i].transform:GetComponent(Button)
        self.photoBtnList[i].btn.onClick:AddListener(function()
            self:ShowTips(i)
        end)
    end
    self.Tips = self.transform:Find("Tips").gameObject
    self.Tips.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self.Tips:SetActive(false)
    end)
    self.transform:Find("Tips/TakePhotosButton"):GetComponent(Button).onClick:AddListener(function()
        self:TackPhoto()
    end)
    self.transform:Find("Tips/UpLoadButton"):GetComponent(Button).onClick:AddListener(function()
        self:OpenPhotoGallery()
    end)
    self.transform:Find("Tips/DelectButton"):GetComponent(Button).onClick:AddListener(function()
        self:DeletePhoto()
    end)
end

function MomentsPhotoEditPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MomentsPhotoEditPanel:OnOpen()
    self.origin = self.parent.photos
    for i,v in ipairs(self.parent.photos) do
        self:SetPhoto(i,v)
    end
end

function MomentsPhotoEditPanel:OnHide()
    self.parent:UpdatePhoto()
end

function MomentsPhotoEditPanel:InitWebcam()
    if ZoneManager.Instance.webcam == nil then
        ZoneManager.Instance:InitWebcam()
    end
end

function MomentsPhotoEditPanel:PhotoCallback(photoSavePath, photoSaveName)

    local photo = Utils.ReadBytesPath(photoSavePath..photoSaveName)
    Log.Debug(photo.Length)
    if photo.Length < 307200 then
        self.photoList[self.currindex] = photo
        self:SetPhoto(self.currindex, photo)
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = TI18N("上传失败，你上传的照片过大，请对图片进行处理或更换小于300KB的照片重新上传")
        data.sureLabel = TI18N("确认")
        NoticeManager.Instance:ConfirmTips(data)
    end
    self.parent.photos = {}
    for i=1, 4 do
        if self.photoList[i] ~= nil then
            table.insert( self.parent.photos, self.photoList[i] )
        end
    end
end

function MomentsPhotoEditPanel:TackPhoto()
    self.model.tempCallback = function(photoSavePath, photoSaveName)
        self:PhotoCallback(photoSavePath, photoSaveName)
    end
    if ZoneManager.Instance.roleinfo.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足40级，无法上传照片"))
    elseif ZoneManager.Instance.webcam ~= nil then
        LoginManager.Instance.webcam_sleep = true
        ZoneManager.Instance.webcam:TakePhoto()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("暂不支持该功能"))
    end
    self.Tips:SetActive(false)
end

function MomentsPhotoEditPanel:OpenPhotoGallery()
    self.model.tempCallback = function(photoSavePath, photoSaveName)
        self:PhotoCallback(photoSavePath, photoSaveName)
    end
    if ZoneManager.Instance.roleinfo.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足40级，无法上传照片"))
    elseif ZoneManager.Instance.webcam ~= nil then
        LoginManager.Instance.webcam_sleep = true
        ZoneManager.Instance.webcam:OpenPhotoGallery()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("暂不支持该功能"))
    end
    self.Tips:SetActive(false)
end

function MomentsPhotoEditPanel:DeletePhoto()
    self.thumbphotoList[self.currindex] = nil
    self.photoList[self.currindex] = nil
    local img = self.photoBtnList[self.currindex].Photo
    img.gameObject:SetActive(false)
    self.photoBtnList[self.currindex].NoImg:SetActive(true)
    self.Tips:SetActive(false)
end

function MomentsPhotoEditPanel:ShowTips(index)
    self.currindex = index
    self.Tips:SetActive(true)
end

function MomentsPhotoEditPanel:SetPhoto(index, photo_bin)
    local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
    table.insert(self.tex2dList, tex2d)
    local result = tex2d:LoadImage(photo_bin)
    local img = self.photoBtnList[index].Photo
    local scaletex = self:ScaleTextureBilinear(tex2d, 0.25)
    table.insert(self.tex2dList, scaletex)
    if result then
        img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
        -- img.sprite  = Sprite.Create(scaletex, Rect(0, 0, scaletex.width, scaletex.height), Vector2(0.5, 0.5), 1)
        img.gameObject:SetActive(true)
        self.photoBtnList[index].NoImg:SetActive(false)

    end
    local newbyte2 = scaletex:EncodeToJPG()
    self.thumbphotoList[index] = newbyte2
    self.parent.thumbphotos = {}
    for i=1, 4 do
        if self.thumbphotoList[i] ~= nil then
            table.insert( self.parent.thumbphotos, self.thumbphotoList[i] )
        end
    end


end

function MomentsPhotoEditPanel:Clear()
    if self.photoBtnList == nil or next(self.photoBtnList) == nil then
        return
    end
    self.photoList = {}
    self.thumbphotoList = {}
    for i=1, 4 do
        self.photoBtnList[i].NoImg:SetActive(true)
        self.photoBtnList[i].Photo.gameObject:SetActive(false)
    end
end

function MomentsPhotoEditPanel:ScaleTextureBilinear(originalTexture, scaleFactor)
    local newTexture = Texture2D(math.ceil (originalTexture.width * scaleFactor), math.ceil (originalTexture.height * scaleFactor), TextureFormat.RGB24, false)
    local scale = 1.0 / scaleFactor;
    local maxX = originalTexture.width - 1
    local maxY = originalTexture.height - 1
    for y = 0, newTexture.height-1 do
        for x = 0, newTexture.width-1 do
            -- Bilinear Interpolation
            local targetX = x * scale;
            local targetY = y * scale;
            local x1 = Mathf.Min(maxX, math.floor(targetX))
            local y1 = Mathf.Min(maxY, math.floor(targetY))
            local x2 = Mathf.Min(maxX, x1 + 1)
            local y2 = Mathf.Min(maxY, y1 + 1)

            local u = targetX - x1
            local v = targetY - y1
            local w1 = (1 - u) * (1 - v)
            local w2 = u * (1 - v)
            local w3 = (1 - u) * v
            local w4 = u * v
            local color1 = originalTexture:GetPixel(x1, y1)
            local color2 = originalTexture:GetPixel(x2, y1)
            local color3 = originalTexture:GetPixel(x1, y2)
            local color4 = originalTexture:GetPixel(x2,  y2)
            local color = Color(Mathf.Clamp01(color1.r * w1 + color2.r * w2 + color3.r * w3+ color4.r * w4),
                Mathf.Clamp01(color1.g * w1 + color2.g * w2 + color3.g * w3 + color4.g * w4),
                Mathf.Clamp01(color1.b * w1 + color2.b * w2 + color3.b * w3 + color4.b * w4),
                Mathf.Clamp01(color1.a * w1 + color2.a * w2 + color3.a * w3 + color4.a * w4)
                )
            newTexture:SetPixel(x, y, color)
        end
    end
    -- newTexture:Apply(false)
    return newTexture
end