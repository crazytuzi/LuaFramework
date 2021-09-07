FashionLuckySelectionItem = FashionLuckySelectionItem or BaseClass()

--为其他人的评论或者自己的评论信息处理逻辑
function FashionLuckySelectionItem:__init(Parent,gameObject,asset,specialIds)
    self.Parent = Parent
    self.gameObject = gameObject

    self.assetWrapper = asset
    self.specialIds = specialIds
    self.init = false
    self.selfHeight = 0
    self.headSlot = nil
    self:InitPanel()
end

function FashionLuckySelectionItem:InitPanel()

    self.transform = self.gameObject.transform
    self.NameText = self.transform:Find("Name"):GetComponent(Text)
    self.MsgText = self.transform:Find("MsgBg/Msg"):GetComponent(Text)
    self.headBg = self.transform:Find("Headbg")

    -- self.leftButton = self.transform:Find("LeftButton"):GetComponent(Button)
    -- self.leftButton.onClick:AddListener(function() self:ApplyLeftButton() end)
    -- self.icon = self.transform:Find("Icon"):GetComponent(Image)

end

function FashionLuckySelectionItem:SetData(data)
    self.data = data
    local msg = BaseUtils.GetServerName(data.platform,data.zone_id)
    self.MsgText.text = msg
    self.NameText.text = self.data.name

    self.headData = {id = data.id,platform = data.platform,zone_id = data.zone_id,classes = data.classes,sex = data.sex},{isSmall = true}
    self:SetHeadImg()
    self:Layout()
end

function FashionLuckySelectionItem:__delete()


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

function FashionLuckySelectionItem:Layout()


    -- if self.selfHeight < 80 then
    --     self.selfHeight = 80
    -- end
    -- self.transform.sizeDelta = Vector2(316,self.selfHeight)
end

function FashionLuckySelectionItem:SetHeadImg()
    -- self.icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(self.data.classes))
    if self.headSlot == nil then
        self.headSlot = HeadSlot.New()
    end
    self.headSlot.gameObject:SetActive(true)
    self.headSlot:SetRectParent(self.headBg.transform)
    self.headSlot:SetAll(self.headData)
end

-- function FashionLuckySelectionItem:ApplyLeftButton()
--     if RoleManager.Instance.RoleData.lev >=30 then
--         if TeamManager.Instance:HasTeam() == false then
--             TeamManager.Instance:Send11701()
--         end
--         local sendData = string.format(TI18N("亲爱的{string_2,#b031d5,%s},我想和你共同激活同心锁哟~{magpiefestival_1,点击接受邀请,%s,%s,%s}"), self.data.name,RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
--         FriendManager.Instance:SendMsg(self.data.rid,self.data.platform,self.data.zone_id,sendData)
--         local data = {id = self.data.rid,platform = self.data.platform,zone_id = self.data.zone_id,classes = self.data.classes,lev = self.data.lev,sex = self.data.sex,name = self.data.name}
--         FriendManager.Instance:TalkToUnknowMan(data)
--     else
--         NoticeManager.Instance:FloatTipsByString("<color='#ffff00'>30级</color>以上才能参与，努力升级吧{face_1,3}")
--     end

-- end
