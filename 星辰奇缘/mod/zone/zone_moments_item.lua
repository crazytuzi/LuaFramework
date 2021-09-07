-- @author hzf
-- @date 2016年7月30日,星期六

ZoneMomentsitem = ZoneMomentsitem or BaseClass()

function ZoneMomentsitem:__init(Parent, gameObject, data, index)
    self.Parent = Parent
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.hasInit = false
    self.tex2dList = {}
    self.Index = index      --(1 朋友圈页面,2 活动页面 3 话题回顾页面)

    self.loadBigbg = false

    self.commentH = 0
    self.Head = self.transform:Find("Head/Image"):GetComponent(Image)
    self.HeadBtn = self.transform:Find("Head"):GetComponent(Button)

    self.HeadBtn.onClick:AddListener(function()
        if data.type ~= 3 then  --系统寄语
            ZoneManager.Instance:OpenOtherZone(self.data.role_id, self.data.platform, self.data.zone_id, {2})
        end
    end)
    self.Name = self.transform:Find("Name"):GetComponent(Text)
    self.NameButton = self.transform:Find("Name/Button"):GetComponent(Button)
    self.NameButton.onClick:AddListener(function()
        if data.type ~= 3 then          --"1:普通 2:寄语 3:系统寄语"
            self.data.rid = self.data.role_id
            TipsManager.Instance:ShowPlayer(self.data)
        end
    end)
    self.AnniImg = self.transform:Find("AnniTag")
    self.AnniImgBtn = self.AnniImg:GetComponent(Button)
    self.AnniImgBtn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString("被评论、点赞达到一定数量，可获得{face_1, 3}") end)
    self.AnniImg.gameObject:SetActive(false)
    self.TimeText = self.transform:Find("TimeTitle/Text"):GetComponent(Text)
    self.Msgbtn = self.transform:Find("Msg"):GetComponent(Button)
    self.Msg = self.transform:Find("Msg/Msg"):GetComponent(Text)
    self.Photo = self.transform:Find("Photo")

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
    self.sayButton = self.Timestamp:Find("sayButton"):GetComponent(Button)
    self.sayButton.onClick:AddListener(function() self.Parent:ShowOption(self.data, self.sayButton.transform.position) end)
    self.Msgbtn.onClick:AddListener(function() self.Parent:ShowOption(self.data, self.sayButton.transform.position) end)
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
        if self.Index == 1 then
            self.ShowAll = true
            self:update_my_self(self.data)
            self.Parent:ReLayout()
        else
            ZoneManager.Instance:OpenOtherZone(self.data.role_id, self.data.platform, self.data.zone_id, {2})
        end
    end)

    if self.Index == 3 then
        self.Timestamp.gameObject:SetActive(false)
        self.rewardBtn = self.transform:Find("Reward"):GetComponent(Button)
        self.reward = self.transform:Find("Reward"):GetComponent(Image)
        self.reward.gameObject:SetActive(false)
    end

end

function ZoneMomentsitem:__delete()
    for i,v in ipairs(self.tex2dList) do
        GameObject.Destroy(v)
    end
    self.tex2dList = nil
    if self.PhotoItem ~= nil then
        for k,v in pairs(self.PhotoItem) do
            v.sprite = nil
        end
    end
    self.PhotoItem = nil
    if self.MsgExt ~= nil then
        self.MsgExt:DeleteMe()
    end
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    -- if self.assetWrapper ~= nil then
    --     self.assetWrapper:DeleteMe()
    --     self.assetWrapper = nil
    -- end
    if self.assetWrapper2 ~= nil then
        self.assetWrapper2:DeleteMe()
        self.assetWrapper2 = nil
    end

end

function ZoneMomentsitem:update_my_self(data)
    if not self.hasInit or BaseUtils.isnull(self.Arrow) then return end
    self.selfHeight = 43
    self.data = data
    if data.type == 3 then  --系统寄语
        if not self.loadBigbg then
            local resources = {
                {file = AssetConfig.dailytopic, type = AssetType.Dep}
            }
            local fun = function()
                self.loadBigbg = true
                self:SetBigbgImage()
                self.Head.sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.friendtexture,"HelpGril2")
            end
            self.assetWrapper2 = AssetBatchWrapper.New()
            self.assetWrapper2:LoadAssetBundle(resources,fun)
        end
    else
        self.headSlot = HeadSlot.New(nil,true)
        self.headSlot:SetRectParent(self.Head.transform)

        self.Head.enabled = false
        self.headSlot:HideSlotBg(true, 0)
        self.headSlot:SetAll({id = data.role_id, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}, {isSmall = true, clickCallback = function() self:OnHeadClick() end})
    end
    self.Name.text = data.name
    self.TimeText.text = (os.date("%Y-%m-%d", data.ctime))
    if self.FirstInit then
        self.MsgExt:SetData(data.content)
    end
    self.Msgbtn.transform.sizeDelta = Vector2(407, self.MsgExt.selfHeight)
    self.selfHeight = self.selfHeight + self.MsgExt.selfHeight
    if data.type == 3 then
        self:SetBigbgImage()
        self.PhotoItem[1].transform.sizeDelta = Vector2(200,100)
        self.Photo.sizeDelta = Vector2(220, 120)
        self.Photo.gameObject:SetActive(true)
        self.PhotoItem[1].gameObject:SetActive(true)
        self.Photo.anchoredPosition = Vector2(84, -self.selfHeight)
        self.selfHeight = self.selfHeight + 120 + 5
        self.Photo:Find("1"):GetComponent(Button).onClick:RemoveAllListeners()
    else
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
    end

    if self.Index == 1 then
        self.Timestamp:GetComponent(Text).text = self:GetTimeGone(data.ctime)
        self.Timestamp.anchoredPosition = Vector2(84, -(self.selfHeight))
        self.selfHeight = self.selfHeight + 30
    elseif self.Index == 2 then

        self.Timestamp:GetComponent(Text).text = ""
        self.Timestamp.anchoredPosition = Vector2(84, -(self.selfHeight))
        self.selfHeight = self.selfHeight + 30
    elseif self.Index == 3 then
        self.selfHeight = self.selfHeight + 20
    end

    self:SetStatusCon()
    self.statusCon.anchoredPosition = Vector2(84, -(self.selfHeight))
    if self.Index == 1 then
         if RoleManager.Instance.RoleData.id == self.data.role_id and RoleManager.Instance.RoleData.platform == self.data.platform and RoleManager.Instance.RoleData.zone_id == self.data.zone_id then
             self.deleteButton.gameObject:SetActive(true)
         else
             self.deleteButton.gameObject:SetActive(false)
         end
    else
        self.deleteButton.gameObject:SetActive(false)
    end

    self.selfHeight = self.selfHeight + self.commentH
    self.transform.sizeDelta = Vector2(508, self.selfHeight)
    self.FirstInit = false
    local FriendWish = DataFriendWish.data_get_title_lev[ZoneManager.Instance.model.currCampId] or {}
    -- for i,v in pairs(DataFriendWish.data_get_title_lev) do
    --     if v.camp_id == ZoneManager.Instance.model.currCampId then
    --         table.insert(FriendWish,v)
    --     end
    -- end
    table.sort(FriendWish, function(a,b) return a.lev < b.lev end)
    --BaseUtils.dump(FriendWish,"FriendWish")

    if self.Index == 2 then   --寄语
        self.AnniImg.gameObject:SetActive(false)
        if #data.friend_comment >= FriendWish[4].coment and #data.likes >= FriendWish[4].praise then
            self.AnniImg:GetComponent(Image).sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"Honer2")
            self.AnniImg.gameObject:SetActive(true)
        elseif #data.friend_comment >= FriendWish[3].coment and #data.likes >= FriendWish[3].praise then
            self.AnniImg:GetComponent(Image).sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"Honer1")
            self.AnniImg.gameObject:SetActive(true)
        end
    elseif self.Index == 3 then   --话题
        --话题回顾时取model中记录的话题回顾活动id
        self.rewardBtn.onClick:RemoveAllListeners()
        self.AnniImg.gameObject:SetActive(false)
        self.reward.transform.anchoredPosition = Vector2(410,(90 - self.selfHeight)/2)
        if #data.friend_comment >= FriendWish[4].coment and #data.likes >= FriendWish[4].praise then
            self.reward.sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"TopicHotPrice")
            self.rewardBtn.onClick:AddListener(function() self:OnRewardClick(3) end)
            self.reward.gameObject:SetActive(true)

            self.AnniImg:GetComponent(Image).sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"Honer2")
            self.AnniImg.gameObject:SetActive(true)
        elseif #data.friend_comment >= FriendWish[3].coment and #data.likes >= FriendWish[3].praise then
            self.reward.sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"TopicRenqiPrice")
            self.rewardBtn.onClick:AddListener(function() self:OnRewardClick(2) end)
            self.reward.gameObject:SetActive(true)

            self.AnniImg:GetComponent(Image).sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"Honer1")
            self.AnniImg.gameObject:SetActive(true)
        elseif #data.friend_comment >= FriendWish[2].coment and #data.likes >= FriendWish[2].praise then
            self.reward.sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"TopicAddPrice")
            self.rewardBtn.onClick:AddListener(function() self:OnRewardClick(1) end)
            self.reward.gameObject:SetActive(true)
        else
            self.reward.gameObject:SetActive(false)
        end
        local luckydata = ZoneManager.Instance.luckyDogData
        local mes = data
        if luckydata ~= nil and next(luckydata) ~= nil then
            for i,v in pairs(luckydata) do
                if v.moment_id == mes.m_id and v.platform == mes.platform and v.zone_id == mes.zone_id then
                    self.reward.sprite = self.Parent.assetWrapper:GetSprite(AssetConfig.zone_textures,"TopicLuckyPrice")
                    self.rewardBtn.onClick:RemoveAllListeners()
                    self.rewardBtn.onClick:AddListener(function() self:OnRewardClick(4) end)
                    self.reward.gameObject:SetActive(true)
                    break
                end
            end
        end
    end
end

function ZoneMomentsitem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function ZoneMomentsitem:GetTimeGone(time)
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

function ZoneMomentsitem:SetStatusCon()
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
        local showStr = nil
        if self.Index == 1 then
            showStr = string.format("<color='#2e5cdf'>%s:</color>%s", v.name, v.msg)
        elseif self.Index == 2 then
            showStr = string.format("<color='#FFF89D'>%s:</color>%s", v.name, v.msg)
        else
            showStr = string.format("<color='#2e5cdf'>%s:</color>%s", v.name, v.msg)
        end
        --local showStr = string.format("<color='#2e5cdf'>%s:</color>%s", v.name, v.msg)
        self.commentList[v.id].Ext:SetData(showStr)
        self.commentList[v.id].item.sizeDelta = Vector2(406,self.commentList[v.id].Ext.selfHeight+12)
        self.commentList[v.id].item.anchoredPosition = Vector2(0, -CH)
        local btn = self.commentList[v.id].item:GetComponent(Button)
        if self.Index ~= 3 then
            btn.onClick:RemoveAllListeners()
            btn.onClick:AddListener(function()
                self.Parent:OnCommentsOpt({data = self.data, commentdata = v, type = 2, name = v.name})
            end)
        end

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

function ZoneMomentsitem:UpdateLike(data)
    self.data.likes = data
    self:update_my_self(self.data)
    self.Parent:ReLayout()
end

function ZoneMomentsitem:UpdateComments(data)
    self.data.friend_comment = data
    self:update_my_self(self.data)
    self.Parent:ReLayout()
end

function ZoneMomentsitem:OnDelete()
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

function ZoneMomentsitem:LoadThumb()
    local zonemodel = ZoneManager.Instance.model
    for i,v in ipairs(self.data.friend_moment_photo) do
        local photo = nil
        if v.auditing == 0 then
            self.PhotoItem[i].gameObject:SetActive(true)
            self.PhotoItem[i].color = Color.white
            self.PhotoTag[i]:SetActive(true)
            self.PhotoTagText[i].text = TI18N("审核中")
        elseif v.auditing == 1 then
            photo = zonemodel:GetThumb(self.data.m_id, self.data.m_platform, self.data.m_zone_id, v.id)
            self.PhotoItem[i].gameObject:SetActive(true)
            self.PhotoItem[i].color = Color.white
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
            self.PhotoTag[i]:SetActive(true)
            self.PhotoItem[i].color = Color(0.533, 0.533, 0.533, 1)
            self.PhotoTagText[i].text = TI18N("<color='#ff2929'>不通过</color>")
        end
    end
end

function ZoneMomentsitem:Cb(Img, photo_data)
    if self.PhotoItem == nil then
        return
    end
    local zonemodel = ZoneManager.Instance.model
    if Img ~= nil then
        local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
        local result = tex2d:LoadImage(photo_data)
        if result then
            if tex2d.width > tex2d.height then
                local scale = tex2d.height/tex2d.width
                Img.transform.sizeDelta = Vector2(50, 50*scale)
            else
                local scale = tex2d.width/tex2d.height
                Img.transform.sizeDelta = Vector2(50*scale, 50)
            end
            Img.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
            Img.gameObject:SetActive(true)
        end
        table.insert(self.tex2dList, tex2d)
    else
        for i,v in ipairs(photo_data) do
            local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
            local result = tex2d:LoadImage(v.thumb_bin)

            if result and self.PhotoItem ~= nil then
                local index = 1
                for ii,vv in ipairs(self.data.friend_moment_photo) do
                    if v.id == vv.id then
                        index = ii
                    end
                end
                local childImg = self.PhotoItem[index]
                if tex2d.width > tex2d.height then
                local scale = tex2d.height/tex2d.width
                    childImg.transform.sizeDelta = Vector2(50, 50*scale)
                else
                    local scale = tex2d.width/tex2d.height
                    childImg.transform.sizeDelta = Vector2(50*scale, 50)
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

function ZoneMomentsitem:OpenPhotoPreview(index)
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

function ZoneMomentsitem:OnHeadClick()
    if self.data ~= nil then
        ZoneManager.Instance:OpenOtherZone(self.data.role_id, self.data.platform, self.data.zone_id, {2})
    end
end

function ZoneMomentsitem:OnRewardClick(index)
    local rewardDesc = DataFriendWish.data_get_reward_desc
    NoticeManager.Instance:FloatTipsByString(rewardDesc[index].reward_desc)
end

function ZoneMomentsitem:SetBigbgImage()
    if self.PhotoItem[1] ~= nil then
        local pictureId = 1001
        local themeData = DataFriendWish.data_get_camp_theme
        for i,v in pairs(DataFriendWish.data_get_camp_theme) do
            if v.camp_id == ZoneManager.Instance.model.currCampId then
                pictureId = v.picture
                break
            end
        end
        self.PhotoItem[1].sprite = self.assetWrapper2:GetSprite(AssetConfig.dailytopic, tostring(pictureId))
    end
end