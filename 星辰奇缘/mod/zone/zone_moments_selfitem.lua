-- 朋友圈个人列表对象
-- @author hzf
-- @date 2016年7月30日,星期六

ZoneMomentsSelfitem = ZoneMomentsSelfitem or BaseClass()

function ZoneMomentsSelfitem:__init(Parent, gameObject, data)
    self.Parent = Parent
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.hasInit = false
    self.tex2dList = {}

    self.commentH = 0
    self.Head = self.transform:Find("Head/Image"):GetComponent(Image)
    self.Name = self.transform:Find("Name"):GetComponent(Text)
    self.TimeText = self.transform:Find("TimeTitle/Text"):GetComponent(Text)
    self.Msg = self.transform:Find("Msg"):GetComponent(Text)
    self.Photo = self.transform:Find("Photo")
    -- self.PhotoBtn = self.transform:Find("Photo/Button"):GetComponent(Button)
    -- self.PhotoBtn.onClick:AddListener(function()
    --     -- body
    -- end)
    self.PhotoItem = {}
    self.PhotoTag = {}
    self.PhotoTagText = {}
    for i=1, 4 do
        self.PhotoItem[i] = self.Photo:Find(tostring(i)):GetComponent(Image)
        self.Photo:Find(tostring(i)):GetComponent(Button).onClick:AddListener(function()
            self:OpenPhotoPreview(i)
        end)
        self.PhotoTag[i] = self.Photo:Find(tostring(i).."/Tag").gameObject
        self.PhotoTagText[i] = self.Photo:Find(tostring(i).."/Tag/Text"):GetComponent(Text)
    end
    self.Timestamp = self.transform:Find("Timestamp")
    self.deleteButton = self.Timestamp:Find("deleteButton"):GetComponent(Button)
    self.deleteButton.onClick:AddListener(function() self:OnDelete() end)
    self.deleteButton.gameObject:SetActive(true)
    self.Timestamp:Find("deleteButton/deleteButton").gameObject:SetActive(true)
    self.sayButton = self.Timestamp:Find("sayButton"):GetComponent(Button)
    self.Timestamp:Find("sayButton/sayButton").gameObject:SetActive(true)
    -- self.sayButton.gameObject:SetActive(true)
    self.sayButton.onClick:AddListener(function() self.Parent:ShowOption(self.data, self.sayButton.transform.position) end)
    self.statusCon = self.transform:Find("statusCon")
    self.Arrow = self.statusCon:Find("Arrow")
    self.Topdesc = self.statusCon:Find("Topdesc")
    self.TopdescTxt = self.statusCon:Find("Topdesc/Text"):GetComponent(Text)
    self.TopdescTxtRect = self.TopdescTxt.gameObject:GetComponent(RectTransform)
    self.Normaldesc = self.statusCon:Find("Normaldesc")
    self.More = self.statusCon:Find("More")

    self.MsgExt = MsgItemExt.New(self.Msg, 407, 17, 18.62)
    self.commentList = {}
    self.FirstInit = true
    self.selfHeight = 43
    self.hasInit = true
    self.ShowAll = false
    self.More:GetComponent(Button).onClick:AddListener(function()
        self.ShowAll = true
        self:update_my_self(self.data)
        self.Parent:ReLayout()
    end)
    self.Year = self.transform:Find("Year"):GetComponent(Text)
    self.Month = self.transform:Find("Month"):GetComponent(Text)
    self.headSlot = HeadSlot.New(nil)
    self.headSlot:SetRectParent(self.Head.transform)
end

function ZoneMomentsSelfitem:__delete()
    for i,v in ipairs(self.tex2dList) do
        GameObject.Destroy(v)
    end
    self.tex2dList = nil
    if self.PhotoItem ~= nil then
        for k,v in pairs(self.PhotoItem) do
            v.sprite = nil
        end
    end
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    self.PhotoItem = nil
    if self.MsgExt ~= nil then
        self.MsgExt:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function ZoneMomentsSelfitem:update_my_self(data)
    if not self.hasInit or BaseUtils.isnull(self.Arrow) then return end
    self.selfHeight = 43
    self.data = data
    self.Year.text = tonumber(os.date("%d", data.ctime))
    self.Month.text = string.format(TI18N("%s月"), tostring(BaseUtils.NumToChn(tonumber(os.date("%m", data.ctime))%100)))
    -- self.Head.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", data.classes, data.sex))
    self.Head.enabled = false
    self.headSlot:HideSlotBg(true, 0)
    self.headSlot:SetAll({id = data.role_id, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}, {isSmall = true})
    self.Name.text = data.name
    self.TimeText.text = (os.date("%Y-%m-%d", data.ctime))
    if self.FirstInit then
        self.MsgExt:SetData(data.content)
    end
    self.selfHeight = self.selfHeight + self.MsgExt.selfHeight
    if next(self.data.friend_moment_photo) ~= nil then
        self.Photo.anchoredPosition = Vector2(84, -self.selfHeight)
        self.Photo.sizeDelta = Vector2(10+60*#self.data.friend_moment_photo, 64)
        self.Photo.gameObject:SetActive(true)
        self.selfHeight = self.selfHeight + 64 + 5
        if self.FirstInit then
            self:LoadThumb()
        end
    else
        self.Photo.gameObject:SetActive(false)
    end
    self.Timestamp:GetComponent(Text).text = self:GetTimeGone(data.ctime)
    self.Timestamp.anchoredPosition = Vector2(84, -(self.selfHeight))
    self.selfHeight = self.selfHeight + 30
    self:SetStatusCon()
    self.statusCon.anchoredPosition = Vector2(84, -(self.selfHeight))
    if RoleManager.Instance.RoleData.id == self.data.role_id and RoleManager.Instance.RoleData.platform == self.data.platform and RoleManager.Instance.RoleData.zone_id == self.data.zone_id then
        self.deleteButton.gameObject:SetActive(true)
    else
        self.deleteButton.gameObject:SetActive(false)
    end
    self.selfHeight = self.selfHeight + self.commentH
    self.transform.sizeDelta = Vector2(508, self.selfHeight)
    self.FirstInit = false
end

function ZoneMomentsSelfitem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ZoneMomentsSelfitem:GetTimeGone(time)
    local timestr = BaseUtils.BASE_TIME - time
    if timestr > 3600*24 then
        timestr = string.format(TI18N("%s天前"), tostring(math.floor(timestr/(3600*24))))
    elseif timestr > 3600 then
        timestr = string.format(TI18N("%s小时前"), tostring(math.floor(timestr/(3600))))
    elseif math.ceil(timestr/(60)) > 0 then
        timestr = string.format(TI18N("%s分钟前"), tostring(math.ceil(timestr/(60))))
    else
        timestr = TI18N("刚刚")
    end
    return timestr
end

function ZoneMomentsSelfitem:SetStatusCon()
    if BaseUtils.isnull(self.Arrow) then
        return
    end
    local H = 0
    H = H + self.Arrow.sizeDelta.y
    local str = "　　"
    for i=1, 5 do
        local data = self.data.likes[i]
        if data ~= nil then
            if i == 1 then
                str = str..data.name
            else
                str = str.."、"..data.name
            end
        end
    end
    if #self.data.likes < 6 then
        str = string.format(TI18N("%s觉得很赞"), str)
    else
        str = string.format(TI18N("%s等%s人觉得很赞"), str, #self.data.likes)
    end
    self.TopdescTxt.text = str
    self.TopdescTxtRect.sizeDelta = Vector2(385 ,self.TopdescTxt.preferredHeight)
    self.Topdesc.sizeDelta = Vector2(406, self.TopdescTxt.preferredHeight+12)
    self.Topdesc.anchoredPosition = Vector2(0,-H)
    if #self.data.likes == 0 then
        self.Topdesc.gameObject:SetActive(false)
    else
        self.Topdesc.gameObject:SetActive(true)
        H = self.Topdesc.sizeDelta.y + H+2
    end
    if self.data.friend_comment == nil then
        self.data.friend_comment = {}
    end
    table.sort( self.data.friend_comment, function(a,b) return a.ctime < b.ctime end )
    local H3 = H
    local CH = H
    for i,v in ipairs(self.data.friend_comment) do
        if not(i <= 3 or self.ShowAll) then
            break
        end
        if self.commentList[v.id] == nil then
            local go = GameObject.Instantiate(self.Normaldesc.gameObject)
            go.transform:SetParent(self.statusCon)
            go.transform.localScale = Vector3.one
            local Ext = MsgItemExt.New(go.transform:Find("Text"):GetComponent(Text), 371.85, 17, 18.62)
            self.commentList[v.id] = {item = go.transform, Ext = Ext}
        end
        local showStr = string.format("<color='#2555d0'>%s:</color>%s", v.name, v.msg)
        self.commentList[v.id].Ext:SetData(showStr)
        self.commentList[v.id].item.sizeDelta = Vector2(406,self.commentList[v.id].Ext.selfHeight+12)
        self.commentList[v.id].item.anchoredPosition = Vector2(0, -CH)
        local btn = self.commentList[v.id].item:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            self.Parent:OnCommentsOpt({data = self.data, commentdata = v, type = 2, name = v.name})
        end)

        CH = CH + self.commentList[v.id].item.sizeDelta.y
        self.commentList[v.id].item.gameObject:SetActive(i<4 or self.ShowAll)
        if i == 3 then
            H3 = CH
        end
    end
    -- 清掉被删除的评论
    local deleList = {}
    for k, commentitem in pairs(self.commentList) do
        local has = false
        for i,v in ipairs(self.data.friend_comment) do
            if v.id == k then
                has = true
                break
            end
        end
        if not has and not BaseUtils.isnull(commentitem.item) then
            table.insert(deleList, k)
            GameObject.DestroyImmediate(commentitem.item.gameObject)
        end
    end
    for i,v in ipairs(deleList) do
        self.commentList[v] = nil
    end
    ----
    if self.ShowAll or #self.data.friend_comment <= 3 then
        H = CH
    else
        H = H3
    end
    if #self.data.friend_comment > 3 and self.ShowAll == false then
        self.More.gameObject:SetActive(true)
        self.More.anchoredPosition = Vector2(0, -H3)
        H = H + self.More.sizeDelta.y+2
    else
        self.More.gameObject:SetActive(false)
    end
    self.commentH = H
    if #self.data.likes == 0 and #self.data.friend_comment == 0 then
        self.statusCon.gameObject:SetActive(false)
    else
        self.commentH = H + 10
        self.statusCon.gameObject:SetActive(true)
    end
end

function ZoneMomentsSelfitem:UpdateLike(data)
    self.data.likes = data
    self:update_my_self(self.data)
    self.Parent:ReLayout()
end

function ZoneMomentsSelfitem:UpdateComments(data)
    self.data.friend_comment = data
    self:update_my_self(self.data)
    self.Parent:ReLayout()
end

function ZoneMomentsSelfitem:OnDelete()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("确定<color='#ffff00'>删除</color>本条状态？(删除后无法恢复)")
    data.sureLabel = TI18N("取消")
    data.cancelLabel = TI18N("确认删除")
    data.blueSure = true
    data.greenCancel = true
    data.cancelCallback = function() ZoneManager.Instance:Require11859(self.data.m_id, self.data.m_platform, self.data.m_zone_id) end
    NoticeManager.Instance:ConfirmTips(data)
end

function ZoneMomentsSelfitem:LoadThumb()
    local zonemodel = ZoneManager.Instance.model
    for i,v in ipairs(self.data.friend_moment_photo) do
        local photo = nil
        if v.auditing == 0 then    
            self.PhotoItem[i].gameObject:SetActive(true)
            self.PhotoItem[i].color = Color.white
            self.PhotoTag[i]:SetActive(true)
            self.PhotoTagText[i].text = TI18N("审核中")
        elseif v.auditing == 1 then
            self.PhotoItem[i].color = Color.white
            self.PhotoTag[i]:SetActive(false)
            photo = zonemodel:GetThumb(self.data.m_id, self.data.m_platform, self.data.m_zone_id, v.id)
            if photo ~= nil then
                self:Cb(self.PhotoItem[i], photo)
            else
                local cb = function(photo_data)
                    self:Cb(nil, photo_data)
                end
                ZoneManager.Instance:RequirePhotoQueue(self.data.m_id, self.data.m_platform, self.data.m_zone_id, cb, 2, v.id)
            end
        elseif v.auditing == 2 then
            self.PhotoItem[i].gameObject:SetActive(true)
            self.PhotoItem[i].color = Color(0.533, 0.533, 0.533, 1)
            self.PhotoTag[i]:SetActive(true)
            self.PhotoTagText[i].text = TI18N("<color='#ff2929'>不通过</color>")
        end
    end
end

function ZoneMomentsSelfitem:Cb(Img, photo_data)
    local zonemodel = ZoneManager.Instance.model
    if Img ~= nil then
        local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
        local result = tex2d:LoadImage(photo_data)
        if result then
            Img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
            Img.gameObject:SetActive(true)
        end
        table.insert(self.tex2dList, tex2d)
    else
        for i,v in ipairs(photo_data) do
            local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
            local result = tex2d:LoadImage(v.thumb_bin)
            if result and self.PhotoItem ~= nil then
                local childImg = self.PhotoItem[v.id]
                if BaseUtils.isnull(childImg) then
                    return
                end
                childImg.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                childImg.gameObject:SetActive(true)
            end
            if self.tex2dList ~= nil then
                table.insert(self.tex2dList, tex2d)
            else
                GameObject.Destroy(tex2d)
            end
            zonemodel:SaveThumb(v.thumb_bin, self.data.m_id, self.data.m_platform, self.data.m_zone_id, v.id, v.uploaded)
        end
    end
end

function ZoneMomentsSelfitem:OpenPhotoPreview(index)
    if self.data and self.data.friend_moment_photo[index] then
        local auditing = self.data.friend_moment_photo[index].auditing
        if auditing == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("图片审核中，请耐心等待{face_1,3}"))
        elseif auditing == 1 then
            self.Parent:OpenPhotoPreview({data = self.data, index = index})
        elseif auditing == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("审核失败，请上传符合规范的图片{face_1,7}"))
        end
    end
end
-- [DEBUG] 11865 = {
--     zone_id = 1,
--     friend_moment_photo = {
--     },
--     sex = 1,
--     role_id = 143,
--     classes = 3,
--     m_platform = "local",
--     m_zone_id = 1,
--     m_id = 3,
--     ctime = 1469861600,
--     content = "这是一条消息啊啊啊啊啊啊啊啊",
--     type = 0,
--     likes = {
--     },
--     name = "昼の乌斯",
--     platform = "local",
-- }
