-- 战斗录像
-- @author huangzefeng
-- @date 20160517
CombatLogViewPanel = CombatLogViewPanel or BaseClass(BasePanel)

function CombatLogViewPanel:__init(model)
    self.model = model
    self.Mgr = CombatManager.Instance
    self.name = "CombatLogViewPanel"

    self.resList = {
        {file = AssetConfig.combatlog_viewpanel, type = AssetType.Main}
        ,{file  =  AssetConfig.heads, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.combatlog_res, type  =  AssetType.Dep}
    }
    self.updatekeep = function()
        self:UpdateKeepbtn()
    end
    self.updateLike = function()
        self:UpdateLikebtn()
    end
end

function CombatLogViewPanel:__delete()
    self.Mgr.OnKeepLogChange:Remove(self.updatekeep)
    self.Mgr.OnLikeChange:Remove(self.updateLike)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function CombatLogViewPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatlog_viewpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "CombatLogViewPanel"
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseViewPanel() end)

    self.sendData = string.format("{rec_1, %s, %s, %s, %s, %s, %s}", self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id, self.openArgs.atk_name, self.openArgs.dfd_name)
    local data = self.openArgs
    self.MainCon = self.transform:Find("Main")
    self.Content = self.transform:Find("Main/Content")
    self.transform:Find("Main/Content/Text"):GetComponent(Text).text = Combat_Type[data.combat_type]
    self.transform:Find("Main/Content/name1"):GetComponent(Text).text = data.atk_name
    self.transform:Find("Main/Content/name2"):GetComponent(Text).text = data.dfd_name
    self.transform:Find("Main/Content/ImgVs/Round"):GetComponent(Text).text = string.format(TI18N("<color='#00ff00'>%s</color>回合"), data.round)
    self.transform:Find("Main/Content/like"):GetComponent(Text).text = ""--string.format(TI18N("<color='#00ff00'>%s</color>人喜欢"), data.liked)
    self.transform:Find("Main/Content/like").gameObject:SetActive(data.liked > 0)

    self.L = self.Content:Find("L")
    self.R = self.Content:Find("R")
    self.L.gameObject:SetActive(true)
    self.R.gameObject:SetActive(true)

    self.L:GetComponent(RectTransform).anchoredPosition = Vector2(-130, -131)
    self.R:GetComponent(RectTransform).anchoredPosition = Vector2(130, -131)
    self.Content:GetComponent(RectTransform).anchoredPosition = Vector2(0, -14)
    self.transform:Find("Panel2"):GetComponent(Button).onClick:AddListener(function()
        self:HideShare()
    end)
    self.ShareCon = self.transform:Find("Share")
    self.likeTxt = self.transform:Find("Main/ShareButton/ImgLine/LikeCon/Text"):GetComponent(Text)  --已喜欢：<color='#c7f9ff'>5</color>
    self.shareTxt = self.transform:Find("Main/ShareButton/ImgLine/ShareCon/Text"):GetComponent(Text)  --已喜欢：<color='#c7f9ff'>5</color>
    self.playTxt = self.transform:Find("Main/ShareButton/ImgLine/PlayCon/Text"):GetComponent(Text)  --已喜欢：<color='#c7f9ff'>5</color>


    self.likeTxt.transform:GetComponent(RectTransform).sizeDelta = Vector2(113.2, 30)
    self.shareTxt.transform:GetComponent(RectTransform).sizeDelta = Vector2(113.2, 30)
    self.playTxt.transform:GetComponent(RectTransform).sizeDelta = Vector2(113.2, 30)
    self.likeTxt.transform:GetComponent(RectTransform).anchoredPosition = Vector2(26, 0)
    self.shareTxt.transform:GetComponent(RectTransform).anchoredPosition = Vector2(26, 0)
    self.playTxt.transform:GetComponent(RectTransform).anchoredPosition = Vector2(26, 0)

    self.likeTxt.text = string.format(TI18N("已喜欢：<color='#c7f9ff'>%s</color>"), self.openArgs.liked)
    self.shareTxt.text = string.format(TI18N("已分享：<color='#c7f9ff'>%s</color>"), self.openArgs.shared)
    self.playTxt.text = string.format(TI18N("已播放：<color='#c7f9ff'>%s</color>"), self.openArgs.replayed)
    -- if self.openArgs.shared == 0 then
        self.transform:Find("Main/ShareButton/I18NText"):GetComponent(Text).text = string.format(TI18N("分享"))
    -- else
    --     self.transform:Find("Main/ShareButton/I18NText"):GetComponent(Text).text = string.format(TI18N("分享%s"), self.openArgs.shared)
    -- end
    -- if self.openArgs.replayed == 0 then
        self.transform:Find("Main/LookButton/I18NText"):GetComponent(Text).text = string.format(TI18N("回放"))
    -- else
    --     self.transform:Find("Main/LookButton/I18NText"):GetComponent(Text).text = string.format(TI18N("回放%s"), self.openArgs.replayed)
    -- end
    if self.openArgs.likable == 1 then
        -- if self.openArgs.liked == 0 then
            self.transform:Find("Main/likeButton/I18NText"):GetComponent(Text).text = string.format(TI18N("喜欢"))
        -- else
        --     self.transform:Find("Main/likeButton/I18NText"):GetComponent(Text).text = string.format(TI18N("喜欢%s"), self.openArgs.liked)
        -- end
    else
        -- if self.openArgs.liked == 0 then
            self.transform:Find("Main/likeButton/I18NText"):GetComponent(Text).text = string.format(TI18N("  已喜欢"))
        -- else
        --     self.transform:Find("Main/likeButton/I18NText"):GetComponent(Text).text = string.format(TI18N("  已喜欢%s"), self.openArgs.liked)
        -- end
    end

    self.transform:Find("Main/LookButton"):GetComponent(TransitionButton).enabled = false
    self.transform:Find("Main/KeepButton"):GetComponent(TransitionButton).enabled = false
    self.transform:Find("Main/likeButton"):GetComponent(TransitionButton).enabled = false
    self.transform:Find("Main/ShareButton"):GetComponent(TransitionButton).enabled = false

    self.transform:Find("Main/LookButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnLook()
    end)
    self.transform:Find("Main/KeepButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnKeep()
    end)
    self.transform:Find("Main/likeButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnLike()
    end)
    self.transform:Find("Main/ShareButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnShare()
    end)
    self.transform:Find("Share/WorldButton"):GetComponent(Button).onClick:AddListener(function()
        self:SendToWorld()
    end)
    self.transform:Find("Share/GuildButton"):GetComponent(Button).onClick:AddListener(function()
        self:SendToGuild()
    end)
    self.transform:Find("Share/FriendButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnFriend()
    end)

    self:InitFighter()
    self:UpdateKeepbtn()
    self.Mgr.OnKeepLogChange:AddListener(self.updatekeep)
    self.Mgr.OnLikeChange:AddListener(self.updateLike)
end

function CombatLogViewPanel:SendToWorld()
    if ChatManager.Instance.worldCd == 0 then
        CombatManager.Instance:Send10756(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
        NoticeManager.Instance:FloatTipsByString(TI18N("成功发送至聊天频道"))
        self.model:CloseViewPanel()
    end
    ChatManager.Instance:SendMsg(MsgEumn.ChatChannel.World, self.sendData)
end
function CombatLogViewPanel:SendToGuild()
  ChatManager.Instance:SendMsg(MsgEumn.ChatChannel.Guild, self.sendData)
    if GuildManager.Instance.model:check_has_join_guild() then
        CombatManager.Instance:Send10756(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
        NoticeManager.Instance:FloatTipsByString(TI18N("成功发送至聊天频道"))
        self.model:CloseViewPanel()
    end
end
 
function CombatLogViewPanel:SendToFriends(list)
    if next(list) == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择一个好友"))
        return
    end
    for _,v in pairs(list) do
        if v.isGroup then
            ChatManager.Instance:Send10424(MsgEumn.ChatChannel.Group,v.id, v.platform,v.zone_id, self.sendData)
        else
            FriendManager.Instance:SendMsg(v.id, v.platform, v.zone_id, self.sendData)
        end
         CombatManager.Instance:Send10756(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
    end
     NoticeManager.Instance:FloatTipsByString(TI18N("分享录像成功"))
     self:HideShare()
end


function CombatLogViewPanel:OnLike()
    if self.openArgs.likable == 1 then
        CombatManager.Instance:Send10752(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
    end
end
function CombatLogViewPanel:OnLook()
    CombatManager.Instance:Send10744(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
    self.model:CloseViewPanel()
end
function CombatLogViewPanel:OnKeep()
    if self.model:IsKeep(self.openArgs.rec_id) then
        --取消收藏
        CombatManager.Instance:Send10751(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
    else
        --收藏
        CombatManager.Instance:Send10750(self.openArgs.type, self.openArgs.rec_id, self.openArgs.platform, self.openArgs.zone_id)
    end
end

function CombatLogViewPanel:OnShare()
    self.transform:Find("Panel2").gameObject:SetActive(true)
    self.ShareCon.gameObject:SetActive(true)
end

function CombatLogViewPanel:OnFriend()
     if self.friendPanel == nil then
        local setting = {
            ismulti = true,
            callback = function(list) self:SendToFriends(list) end,
            list_type = 1,
            containGroup = true,
            groupDesc = TI18N("分享至群组"),
            btnname = TI18N("分 享")
        }
        self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
    end
    self.friendPanel:Show()
end

function CombatLogViewPanel:HideShare()
    self.transform:Find("Panel2").gameObject:SetActive(false)
    self.ShareCon.gameObject:SetActive(false)
end

function CombatLogViewPanel:UpdateKeepbtn()
    local btn = self.transform:Find("Main/KeepButton"):GetComponent(Button)
    local btnImg = self.transform:Find("Main/KeepButton"):GetComponent(Image)
    local Text = self.transform:Find("Main/KeepButton/I18NText"):GetComponent(Text)
    btn.onClick:RemoveAllListeners()
    if self.model:IsKeep(self.openArgs.rec_id) then
        -- btnImg.enabled = false
        Text.text = TI18N("   取消收藏")
        btn.onClick:AddListener(function()
            self:OnKeep()
        end)
    else
        -- btnImg.enabled = true
        Text.text = TI18N("收藏")
        btn.onClick:AddListener(function()
            self:OnKeep()
        end)
    end
end

function CombatLogViewPanel:UpdateLikebtn()
    self.likeTxt.text = string.format(TI18N("已喜欢：<color='#c7f9ff'>%s</color>"), self.openArgs.liked+1)
    -- self.transform:Find("Main/likeButton/I18NText"):GetComponent(Text).text = string.format(TI18N("  已喜欢%s"), self.openArgs.liked+1)
    self.transform:Find("Main/likeButton/I18NText"):GetComponent(Text).text = TI18N("  已喜欢")
    self.transform:Find("Main/Content/like"):GetComponent(Text).text = ""--string.format(TI18N("<color='#00ff00'>%s</color>人喜欢"), self.openArgs.liked+1)
    self.openArgs.likable = 0
end



function CombatLogViewPanel:ReSize(big, horizon)
    -- if big then
        self.MainCon.sizeDelta = Vector2(520, 394)
        self.Content.sizeDelta = Vector2(465.8, 230)
    -- else
    --     if horizon then
    --         self.MainCon.sizeDelta = Vector2(470, 312)
    --         self.Content.sizeDelta = Vector2(360, 154)
    --     else
    --         self.MainCon.sizeDelta = Vector2(520, 370)
    --         self.Content.sizeDelta = Vector2(465.8, 154)
    --     end
    -- end
end

function CombatLogViewPanel:InitFighter()
    local atklist = {}
    local dfdlist = {}
    for i,v in ipairs(self.openArgs.fighters) do
        if v.group == 0 then
            table.insert(atklist, v)
        else
            table.insert(dfdlist, v)
        end
    end

    self.transform:Find("Main/Content/name1").gameObject:SetActive(false)
    self.transform:Find("Main/Content/name2").gameObject:SetActive(false)

    if #dfdlist == 0 then
        if #atklist > 1 then
            if #atklist <= 3 then
                self:ReSize(true)
            else
                self:ReSize(true)
            end
            local K = 1
            for i,v in ipairs(atklist) do
                local itemindex = 3+math.floor(i/2)*K
                K = K*-1
                local Item = self.L:Find(tostring(i))
                Item:Find("ClassIcon"):GetComponent(RectTransform).anchoredPosition = Vector2(-94, 0)
                if v.lev >= 100 then
                    Item:GetComponent(Text).text = string.format("Lv.%s          %s", v.lev,v.name)
                else
                    Item:GetComponent(Text).text = string.format("Lv.%s            %s", v.lev,v.name)
                end
                Item:Find("ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(v.classes))
                Item.gameObject:SetActive(true)
            end
            self.transform:Find("Main/Content/name2").gameObject:SetActive(true)
        else
            self:ReSize(false, true)
            self.transform:Find("Main/Content/name1").gameObject:SetActive(true)
            self.transform:Find("Main/Content/name2").gameObject:SetActive(true)

            local tempData = atklist[1]
            if tempData ~= nil then
                self.transform:Find("Main/Content/name1"):GetComponent(Text).text = string.format("Lv.%s          %s", tempData.lev,tempData.name)
                self.transform:Find("Main/Content/name1/ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(tempData.classes))
            end

        end
    elseif #dfdlist ~= 0 then
        self:ReSize(#dfdlist > 1)
        local K = 1
        for i,v in ipairs(dfdlist) do
            local itemindex = 3+math.floor(i/2)*K
            K = K*-1
            local Item = self.L:Find(tostring(i))
            Item:Find("ClassIcon"):GetComponent(RectTransform).anchoredPosition = Vector2(-94, 0)
            if v.lev >= 100 then
                Item:GetComponent(Text).text = string.format("Lv.%s          %s", v.lev,v.name)
            else
                Item:GetComponent(Text).text = string.format("Lv.%s            %s", v.lev,v.name)
            end
            Item:Find("ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(v.classes))
            Item.gameObject:SetActive(true)
        end
        K = 1
        for i,v in ipairs(atklist) do
            local itemindex = 3+math.floor(i/2)*K
            K = K*-1
            local Item = self.R:Find(tostring(i))
            Item:Find("ClassIcon"):GetComponent(RectTransform).anchoredPosition = Vector2(-94, 0)
            if v.lev >= 100 then
                Item:GetComponent(Text).text = string.format("Lv.%s          %s", v.lev,v.name)
            else
                Item:GetComponent(Text).text = string.format("Lv.%s            %s", v.lev,v.name)
            end
            Item:Find("ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(v.classes))
            Item.gameObject:SetActive(true)
        end
    end
end
