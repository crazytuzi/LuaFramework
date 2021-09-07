ZoneHeadPanel = ZoneHeadPanel or BaseClass()

function ZoneHeadPanel:__init(transform, parent)
    self.parent = parent
    self.transform = transform
    self.Mgr = ZoneManager.Instance
    self.model = ZoneManager.Instance.model
    self.tex2dList = {}

    self.Tips = self.transform:Find("Tips")
    self.PhotoCon = self.transform:Find("PhotoCon")
    self.titleText = self.transform:Find("Title/Text"):GetComponent(Text)
    self.P = {}
    self.P[1] = self.PhotoCon:Find("P1")
    self.P[2] = self.PhotoCon:Find("P2")
    self.P[3] = self.PhotoCon:Find("P3")
    self.tipsclose = self.PhotoCon:Find("tipsclose"):GetComponent(Button)
    self.tipsclose.onClick:AddListener(function()
        self.Tips.gameObject:SetActive(false)
        self.tipsclose.gameObject:SetActive(false)
    end)
    self.clickid = 0
end

function ZoneHeadPanel:OnInitCompleted()
    local lastindex = 0
    for i=1,3 do
        local pData = nil
        for k,v in pairs(self.parent.photoList) do
            if v.id == i then
                pData = v
            end
        end
        local img = self.P[i]:Find("Photo"):GetComponent(Image)
        local NoImg = self.P[i]:Find("NoImg")
        if pData ~= nil then
            if self.Mgr.openself then
                local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
                table.insert(self.tex2dList, tex2d)
                local result = tex2d:LoadImage(pData.photo_bin)
                self.P[i]:Find("NoImg").gameObject:SetActive(false)
                if result then
                    img.sprite = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                    img.gameObject:SetActive(true)
                    self.P[i].gameObject:SetActive(true)
                end
                if pData.default == 1 then
                    self.P[i]:Find("Label").gameObject:SetActive(true)
                    self.P[i]:Find("Label/Text"):GetComponent(Text).text = TI18N("当前")
                elseif pData.auditing == 0 then
                    self.P[i]:Find("Label").gameObject:SetActive(true)
                    self.P[i]:Find("Label/Text"):GetComponent(Text).text = TI18N("审核")
                else
                    self.P[i]:Find("Label").gameObject:SetActive(false)
                end
                -- self.Mgr:RequirePhotoQueue(self.Mgr.roleinfo.id, self.Mgr.roleinfo.platform, self.Mgr.roleinfo.zone_id, function(pData) self.parent:toPhoto(pData, img) end)
                lastindex = i
            elseif pData.auditing == 1 then
                local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
                table.insert(self.tex2dList, tex2d)
                local result = tex2d:LoadImage(pData.photo_bin)
                self.P[i]:Find("NoImg").gameObject:SetActive(false)
                if result then
                    img.sprite = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                    img.gameObject:SetActive(true)
                    self.P[i].gameObject:SetActive(true)
                end
                if pData.default == 1 then
                    self.P[i]:Find("Label").gameObject:SetActive(true)
                    self.P[i]:Find("Label/Text"):GetComponent(Text).text = TI18N("当前")
                elseif pData.auditing == 0 then
                    self.P[i]:Find("Label").gameObject:SetActive(true)
                    self.P[i]:Find("Label/Text"):GetComponent(Text).text = TI18N("审核")
                else
                    self.P[i]:Find("Label").gameObject:SetActive(false)
                end
                -- self.Mgr:RequirePhotoQueue(self.Mgr.targetInfo.id, self.Mgr.targetInfo.platform, self.Mgr.targetInfo.zone_id, function(pData) self.parent:toPhoto(pData, img) end)
            end
        else
            img.gameObject:SetActive(false)
            NoImg.gameObject:SetActive(true)
            self.P[i]:Find("Label").gameObject:SetActive(false)
            if self.Mgr.openself then
                lastindex = i
            else
                self.P[i].gameObject:SetActive(false)
            end
        end
        if not self.Mgr.openself then
            self.titleText.text = string.format(TI18N("%s的照片"), self.parent.myzoneData.name)
        end

    end
    if lastindex < 3 then
        local maxL = (170+26)
        local imgList = {}
        for i=1,3 do
            if self.P[i]:Find("Photo").gameObject.activeSelf then
                table.insert( imgList, self.P[i] )
            end
        end
        for i,v in ipairs(imgList) do
            if #imgList == 2 then
                v.anchoredPosition = Vector2((i-1.5)*(26+170), -12.5)
            elseif #imgList == 1 then
                v.anchoredPosition = Vector2(0, -12.5)
            end
        end
    elseif self.Mgr.openself then
        for i=1,3 do
            self.P[i]:GetComponent(Button).onClick:AddListener(function() self:OnClickPhoto(i) end)
        end
    end
end

function ZoneHeadPanel:__delete()
    for i,v in ipairs(self.tex2dList) do
        GameObject.Destroy(v)
    end
    self.tex2dList = nil
end

function ZoneHeadPanel:OnClickPhoto(index)
    local pData = nil
        for k,v in pairs(self.parent.photoList) do
            if v.id == index then
                pData = v
            end
        end
    if pData == nil or pData.auditing ~= 1 or pData.default == 1 then
        self.Tips:Find("SetButton").gameObject:SetActive(false)
        self.Tips.sizeDelta = Vector2(181, 3*55+23.2)
    else
        self.Tips:Find("SetButton").gameObject:SetActive(true)
        self.Tips.sizeDelta = Vector2(181, 4*55+23.2)

    end
    self.Tips.anchoredPosition = Vector2(self.P[index].anchoredPosition.x, 0)
    self.Tips.gameObject:SetActive(true)
    self.tipsclose.gameObject:SetActive(true)
    self.clickid = index
end

function ZoneHeadPanel:Open()
    if not self.Mgr.openself and next(self.parent.photoList) == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("该玩家未设置自定义头像"))
        self:Close()
        return
    end
    self:OnInitCompleted()
end

function ZoneHeadPanel:Close()
    self.transform.gameObject:SetActive(false)
    self.Tips.gameObject:SetActive(false)
    self.tipsclose.gameObject:SetActive(false)
end