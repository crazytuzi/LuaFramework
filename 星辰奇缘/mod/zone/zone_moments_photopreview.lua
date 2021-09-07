-- 动态大照片预览面板
-- @author hzf
-- @date 2016年7月29日,星期五

MomentsPhotoPreviewPanel = MomentsPhotoPreviewPanel or BaseClass(BasePanel)

function MomentsPhotoPreviewPanel:__init(model, parent)
    self.Mgr = ZoneManager.Instance
    self.model = model
    self.parent = parent
    self.name = "MomentsPhotoPreviewPanel"
    self.currindex = nil
    self.resList = {
        {file = AssetConfig.moment_photoprewview, type = AssetType.Main}
    }
    self.defaultsprite = nil
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.isshow = false
end

function MomentsPhotoPreviewPanel:__delete()
    if self.photoImgList ~= nil then
        for k,v in pairs(self.photoImgList) do
            v.sprite = nil
        end
    end
    self.photoImgList = nil
    self.isshow = false
    self.defaultsprite = nil
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MomentsPhotoPreviewPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_photoprewview))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.photoImgList = {}
    self.ToggleList = {}
    self.scrollCon = self.transform:Find("Bg/MaskScroll")
    self.Con = self.transform:Find("Bg/MaskScroll/Container")
    for i=1, 4 do
        self.photoImgList[i] = self.transform:Find(string.format("Bg/MaskScroll/Container/P%s", i)):GetComponent(Image)
        self.ToggleList[i] = self.transform:Find(string.format("Bg/ToggleGroup/Toggle%s", tostring(i))):GetComponent(Toggle)
        if i == 1 then
            self.defaultsprite = self.photoImgList[i].sprite
        end
    end
    if self.tabbedPanel == nil then
        self.tabbedPanel = TabbedPanel.New(self.scrollCon.gameObject, 4, 400)
    end
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self:OnDragEnd(currentPage, direction) end)
    self.transform:Find("Bg"):GetComponent(CustomDragButton).onClick:AddListener(function()
        self:Hiden()
    end)
    self.LBtn = self.transform:Find("Bg/LButton"):GetComponent(Button)
    self.LBtn.onClick:AddListener(function()
        self:NextPhoto(true)
    end)
    self.RBtn = self.transform:Find("Bg/RButton"):GetComponent(Button)
    self.RBtn.onClick:AddListener(function()
        self:NextPhoto(false)
    end)
    self.RepButton = self.transform:Find("Bg/RepButton"):GetComponent(Button)

    self.RepButton.onClick:AddListener(function()
        self:OnReport()
    end)
    self.isshow = true
end

function MomentsPhotoPreviewPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MomentsPhotoPreviewPanel:OnOpen()
    self.isshow = true
    self.data = self.openArgs.data
    self.openindex = self.openArgs.index
    self.RepButton.gameObject:SetActive(self.data.name ~= RoleManager.Instance.RoleData.name)
    self:Clear()
    self:SetPhoto()
end

function MomentsPhotoPreviewPanel:OnHide()
    self.data = nil
    self.isshow = false
end

function MomentsPhotoPreviewPanel:SetImg()
    -- body
end

function MomentsPhotoPreviewPanel:SetPhoto()
    local zonemodel = ZoneManager.Instance.model
    if self.data ~= nil then
        for i,v in ipairs(self.data.friend_moment_photo) do
            local photo_data = zonemodel:GetMomentPhoto(v.m_id, v.m_platform, v.m_zone_id, v.id)
            if photo_data ~= nil then
                self:Cb(self.photoImgList[v.id], photo_data)
            else
                local cb = function(photo_data)
                    self:Cb(nil, photo_data)
                end
                ZoneManager.Instance:RequirePhotoQueue(self.data.m_id, self.data.m_platform, self.data.m_zone_id, cb, 3, v.id)
            end
        end
    end
end

function MomentsPhotoPreviewPanel:Cb(Img, photo_data)
    if self.isshow == false then
        return
    end
    local zonemodel = ZoneManager.Instance.model
    if Img ~= nil then
        local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
        local result = tex2d:LoadImage(photo_data)
        if result then
            Img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
            if tex2d.width > tex2d.height then
                local scale = tex2d.height/tex2d.width
                childImg.transform.sizeDelta = Vector2(400, 400*scale)
            else
                local scale = tex2d.width/tex2d.height
                childImg.transform.sizeDelta = Vector2(400*scale, 400)
            end
            -- Img.gameObject:SetActive(self.currindex == v.id)
        end
        tex2d = nil
    else
        for i,v in ipairs(photo_data) do
            local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
            local result = tex2d:LoadImage(v.photo_bin)
            if result then
                local childImg = self.photoImgList[v.id]
                childImg.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                if tex2d.width > tex2d.height then
                    local scale = tex2d.height/tex2d.width
                    childImg.transform.sizeDelta = Vector2(400, 400*scale)
                else
                    local scale = tex2d.width/tex2d.height
                    childImg.transform.sizeDelta = Vector2(400*scale, 400)
                end
                childImg.transform.anchoredPosition = Vector2((v.id-1)*400+(400-childImg.transform.sizeDelta.x)/2, 0)
                -- childImg.gameObject:SetActive(self.currindex == v.id)
            end
            zonemodel:SaveMomentPhoto(v.photo_bin, self.data.m_id, self.data.m_platform, self.data.m_zone_id, v.id, v.uploaded)
            tex2d = nil
        end
    end
end

function MomentsPhotoPreviewPanel:Clear()
    for i=1, 4 do
        self.photoImgList[i].sprite = self.defaultsprite
    end
    local num = #self.data.friend_moment_photo
    self.currindex = 1
    if self.openindex ~= nil then
        self.currindex = self.openindex
    end
    self.tabbedPanel:SetPageCount(num)
    for i=1, 4 do
        self.ToggleList[i].gameObject:SetActive(i<= num)
        self.photoImgList[i].gameObject:SetActive(i<=num)
    end
    self.tabbedPanel:TurnPage(self.currindex)
    self.Con.sizeDelta = Vector2(400*num, 400)
    self.LBtn.gameObject:SetActive(self.currindex ~= 1)
    self.RBtn.gameObject:SetActive(num ~= self.currindex)
    self.ToggleList[self.currindex].isOn = true
end

function MomentsPhotoPreviewPanel:NextPhoto(left)
    if left then
        self.currindex = self.currindex -1
    else
        self.currindex = self.currindex +1
    end
    -- for i=1, 4 do
    --     self.photoImgList[i].gameObject:SetActive(i==self.currindex)
    -- end
    self.tabbedPanel:TurnPage(self.currindex)
    self.LBtn.gameObject:SetActive(self.currindex ~= 1)
    self.RBtn.gameObject:SetActive(self.currindex ~= #self.data.friend_moment_photo)
    self.ToggleList[self.currindex].isOn = true
end


function MomentsPhotoPreviewPanel:OnReport()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("是否<color='#ffff00'>举报</color>%s<color='#ffff00'>本图片</color>？"), self.data.name)
    data.sureLabel = TI18N("举报图片")
    data.cancelLabel = TI18N("取消")
    data.blueSure = true
    data.greenCancel = true
    data.sureCallback = function()ZoneManager.Instance:Require11869(self.data.m_id, self.data.m_platform, self.data.m_zone_id, 2, self.currindex) end
    NoticeManager.Instance:ConfirmTips(data)
end

function MomentsPhotoPreviewPanel:OnDragEnd(currentPage, direction)
    if self.data == nil then
        return
    end
    if direction == LuaDirection.Left then
        self.currindex = currentPage
    elseif direction == LuaDirection.Right then
        self.currindex = currentPage
    end
    self.LBtn.gameObject:SetActive(self.currindex ~= 1)
    self.RBtn.gameObject:SetActive(self.currindex ~= #self.data.friend_moment_photo)
    self.ToggleList[self.currindex].isOn = true
end