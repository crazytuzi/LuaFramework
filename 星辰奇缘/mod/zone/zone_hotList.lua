ZoneHotList = ZoneHotList or BaseClass()

function ZoneHotList:__init(panel, mainWin)
    self.Mgr = ZoneManager.Instance
    self.mainWin = mainWin
    self.gameObject = panel
    self.transform = self.gameObject.transform
    self.page = self.transform:Find("Mask/page")
    self.layoutCon = self.transform:Find("Mask/Container")
    self.toggle = self.transform:Find("Mask/Toggle")
    self.toggleCon = self.transform:Find("Mask/ToggleContainer")
    self.dataList = self.Mgr.hotzone_List
    self.pagenum = math.ceil(#self.dataList/8)
    self.spriteList = {}
    self.tex2dList = {}
    local setting = {
        axis = BoxLayoutAxis.X
        ,cspacing = 0
        -- ,scrollRect = self.transform:Find("Mask")
    }
    self.layout = LuaBoxLayout.New(self.layoutCon, setting)
    self.togglelayout = LuaBoxLayout.New(self.toggleCon, setting)
    for i=1,self.pagenum do
        local page = GameObject.Instantiate(self.page.gameObject)
        local toggle = GameObject.Instantiate(self.toggle.gameObject)
        page.gameObject.name = tostring(i)
        page.gameObject:SetActive(true)
        self.layout:AddCell(page)
        toggle.gameObject.name = tostring(i)
        toggle.gameObject:SetActive(true)
        self.togglelayout:AddCell(toggle)
    end
    self.tabpage = TabbedPanel.New(self.transform:Find("Mask").gameObject, self.pagenum, 730.4)
    self.tabpage.MoveEndEvent:AddListener(
        function(page)
            self:OnTabChange(page)
        end
    )
    self:OnTabChange(1)
end


function ZoneHotList:__delete()
    for i,v in ipairs(self.spriteList) do
        GameObject.Destroy(v)
    end
    self.spriteList = nil
    for i,v in ipairs(self.tex2dList) do
        GameObject.Destroy(v)
    end
    self.tex2dList = nil
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.togglelayout ~= nil then
        self.togglelayout:DeleteMe()
        self.togglelayout = nil
    end
    if self.tabpage ~= nil then
        self.tabpage:DeleteMe()
        self.tabpage = nil
    end
end

function ZoneHotList:Show()
    self.gameObject:SetActive(true)
end

function ZoneHotList:Hide()
    self.gameObject:SetActive(false)
end

function ZoneHotList:OnTabChange(index)
    self:InitPage(index)
    self:InitPage(index+1)
    for i=1,self.pagenum do
        self.toggleCon:Find(tostring(i)):GetComponent(Toggle).isOn = i==index
    end
end

function ZoneHotList:InitPage(index)
    local page = self.layoutCon:Find(tostring(index))
    if page == nil or page:Find("1").gameObject.activeSelf then
        return
    end
    local stari = (index-1)*8+1
    local endi = math.min((index-1)*8+8 , #self.dataList)
    for i=1,8 do
        local item = page:Find(tostring(i))
        if (index-1)*8+i <= endi then
            local data = self.dataList[(index-1)*8+i]
            self:SetItem(item, data)
            item.gameObject:SetActive(true)
        else
            item.gameObject:SetActive(false)
        end
    end
end

function ZoneHotList:SetItem(item, data)
    local headimg = item:Find("Head"):GetComponent(Image)
    headimg.sprite = self.mainWin:GetHead(data.classes, data.sex)
    item:Find("Head").gameObject:SetActive(true)
    item:Find("LikeText"):GetComponent(Text).text = tostring(data.liked)
    item:Find("nameText"):GetComponent(Text).text = data.name
    item:Find("GiftIcon").gameObject:SetActive(data.prize_num>0)
    item:GetComponent(Button).onClick:AddListener(function() self.Mgr:OpenOtherZone(data.id, data.platform, data.zone_id) end)
    if data.photo ~= 0 then
        local zoneManager = ZoneManager.Instance
        local photo = self.mainWin.model:LoadLocalPhoto(data.id, data.platform, data.zone_id, data.photo)
        if BaseUtils.is_null(photo) then
            zoneManager:RequirePhotoQueue(data.id, data.platform, data.zone_id, function(photo) if not BaseUtils.isnull(headimg) then self:toPhoto(photo, headimg, data.id, data.platform, data.zone_id, data.photo) end end)
        else
            if not BaseUtils.isnull(item) then
                self:toPhoto(photo, item:Find("Head"):GetComponent(Image), data.id, data.platform, data.zone_id, data.photo)
            end
        end
    end
end

function ZoneHotList:toPhoto(photo, img, id, platform, zone_id, photoid)
    if BaseUtils.isnull(img) or photo[1] == nil then
        return
    end
    self.mainWin.model:SaveLocalPhoto(photo[1].photo_bin, id, platform, zone_id, photoid, photo[1].id)
    -- local tex2d = Texture2D(8, 8)
    local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)

    local result = tex2d:LoadImage(photo[1].photo_bin)
    if result then
        img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
        -- img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0, 0))
        table.insert( self.spriteList, img.sprite )
    end
    table.insert(self.tex2dList, tex2d)
end