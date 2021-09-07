CampaignAutumnHelpItem = CampaignAutumnHelpItem or BaseClass()

function CampaignAutumnHelpItem:__init(Parent,gameObject,asset)
    self.Parent = Parent
    self.gameObject = gameObject

    self.assetWrapper = asset
    self.init = false
    self.selfHeight = 0
    self.headSlot = nil
    self:InitPanel()
end

function CampaignAutumnHelpItem:InitPanel()
    self.transform = self.gameObject.transform
    self.Msg = self.transform:Find("Msg"):GetComponent(Text)
    self.MsgExt = MsgItemExt.New(self.Msg,338,20,22)
end

function CampaignAutumnHelpItem:SetData(data)
     local myHour = ""
    local mymini = ""
    self.data = data
    local hour = tonumber(os.date("%H",self.data.time))
    -- print(hour .. "sdjfklsdjfkljsdklf")
    if hour  < 10 then
        myHour = "0" .. hour
    else
        myHour = hour
    end


    local mini = tonumber(os.date("%M",self.data.time))
    if mini < 10 then
        mymini = "0" .. mini
    else
        mymini = mini
    end
    math.randomseed(data.tar_role_id)
    local rand = math.random(1,7)
    local sendMsg = "%s:%s " .. CampaignAutumnManager.Instance.model.replyFriendList[rand]
    self.data.msg = string.format(sendMsg,myHour,mymini,self.data.name,self.data.cut_price)
    self.MsgExt:SetData(self.data.msg,true)

-- self.headData = {id = data.tar_roleid,platform = data.platform,zone_id = data.zone_id,classes = data.classes,sex = data.sex},{isSmall = true}    self:SetHeadImg()
    self:Layout()
end

function CampaignAutumnHelpItem:__delete()
    if self.MsgExt ~= nil then
        self.MsgExt:DeleteMe()
        self.MsgExt = nil
    end

    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.Parent ~= nil then
        self.Parent = nil
    end
end

function CampaignAutumnHelpItem:Layout()
    -- self.selfHeight = 50 + self.MsgExt.selfHeight


    -- if self.selfHeight < 80 then
    --     self.selfHeight = 80
    -- end
    -- self.transform.sizeDelta = Vector2(705,self.selfHeight)
    -- self.MsgExt.contentRect.anchoredPosition = Vector2(92,-46)
end

-- function CampaignAutumnHelpItem:SetHeadImg()
--     -- self.icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(self.data.classes))
--     if self.headSlot == nil then
--         self.headSlot = HeadSlot.New()
--     end
--     self.headSlot.gameObject:SetActive(true)
--     self.headSlot:SetRectParent(self.headBg.transform)
--     self.headSlot:SetAll(self.headData)
-- end

