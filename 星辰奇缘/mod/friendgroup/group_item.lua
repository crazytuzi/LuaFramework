GroupItem = GroupItem or BaseClass()

function GroupItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

    self.headSlot = HeadSlot.New()
    self.transform:Find("Headbg"):GetComponent(Image).enabled = false
    self.HeadbgImg = self.transform:Find("Headbg"):GetComponent(Image)
    self.headSlot:SetRectParent(self.transform:Find("Headbg"))

    self.headObj = self.transform:Find("Head").gameObject
    self.HeadImg = self.transform:Find("Head"):GetComponent(Image)
    self.Select = self.transform:Find("Select").gameObject
    self.name = self.transform:Find("name"):GetComponent(Text)
    self.SigText = self.transform:Find("SigText"):GetComponent(Text)
    self.ArrowButton = self.transform:Find("Button"):GetComponent(Button)
    self.ArrowButton.onClick:AddListener(function()
        self:OpenInfoPanel()
    end)
    self.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnBtnClick()
    end)
    self.Red = self.transform:Find("Red").gameObject
    self.RedText = self.transform:Find("Red/Text"):GetComponent(Text)
    self.Add = self.transform:Find("Add").gameObject
    self.MidText = self.transform:Find("MidText"):GetComponent(Text)
end

--设置


function GroupItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GroupItem:set_my_index(_index)
    -- self.item_index = _index
    -- if self.item_index%2 == 0 then
    --     --偶数
    --     self.ImgOne.color = ColorHelper.ListItem1
    -- else
    --     --单数
    --     self.ImgOne.color = ColorHelper.ListItem2
    -- end
end

--更新内容
function GroupItem:update_my_self(_data, _index)
    self.data = _data
    local dat = {id = _data.role_rid, platform = _data.role_platform, zone_id = _data.role_zone_id,classes = _data.owner_classes, sex = _data.owner_sex}
    if _data.time == -1 then
        self.headSlot:Default()
        self.headSlot:HideSlotBg(true)
        self.headSlot:SetActive(false)
        self.MidText.text = TI18N("创建自定义群组")
        self.HeadbgImg.enabled = true
        self.Red:SetActive(false)
        self.Select:SetActive(false)
    elseif _data.time ~= math.huge then
        self.headSlot:HideSlotBg(false)
        self.headSlot:SetActive(true)
        self.headSlot:SetAll(dat, {isSmall = true})
        self.HeadbgImg.enabled = false
        self.Red:SetActive(false)
        local bol, num = FriendGroupManager.Instance:IsHasNewMsg(self.data.group_rid, self.data.group_platform, self.data.group_zone_id)
        self.Red:SetActive(bol)
        self.RedText.text = tostring(num)
    else
        self.headSlot:HideSlotBg(true)
        self.headSlot:SetActive(false)
        self.MidText.text = TI18N("群组邀请")
        self.HeadImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Addfriendicon")
        self.HeadImg:SetNativeSize()
        self.HeadbgImg.enabled = true
        self.Red:SetActive(FriendGroupManager.Instance:GetInviteNum() > 0)
        self.RedText.text = tostring(FriendGroupManager.Instance:GetInviteNum())
        self.Select:SetActive(false)
    end
    self.headObj:SetActive(_data.time == math.huge)
    self.MidText.gameObject:SetActive(_data.time == -1 or _data.time == math.huge)
    self.Add:SetActive(_data.time == -1)
    self.name.gameObject:SetActive(_data.time ~= -1 and _data.time ~= math.huge)
    self.SigText.gameObject:SetActive(_data.time ~= -1 and _data.time ~= math.huge)
    self.ArrowButton.gameObject:SetActive(_data.time ~= -1 and _data.time ~= math.huge)
    -- self.headSlot:SetGray(_data.online ~= 1)
    -- self.parent:SetPlayerItem(self.gameObject, _data)
    if self.parent.Mainwin.groupchatPanel.currChatTarget ~= nil and self.parent.Mainwin.groupchatPanel.currChatTarget == BaseUtils.Key(self.data.group_rid, self.data.group_platform, self.data.group_zone_id) then
        if self.parent.selectObj ~= nil then
            self.parent.selectObj:SetActive(false)
        end
        self.parent.selectObj = self.Select
        self.parent.selectObj:SetActive(true)
    end

    if _data.time ~= math.huge and _data.time ~= -1 then
        local str = self:GetOnlineStr()
        self.name.text = _data.group_name..str
        self.SigText.text = _data.group_content
    end
end

function GroupItem:OnBtnClick()
    if self.data.time == -1 then
        local cfg = DataFriendGroup.data_get[FriendGroupManager.Instance.data19001.create+1]
        if cfg ~= nil then
            if RoleManager.Instance.RoleData.lev < cfg.lev then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前等级小于<color='#00ff00'>%s级</color>，无法创建群组"), cfg.lev))
                return
            end
        else
            cfg = DataFriendGroup.data_get[1]
            if RoleManager.Instance.RoleData.lev < cfg.lev then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前等级小于<color='#00ff00'>%s级</color>，无法创建群组"), cfg.lev))
                return
            end
        end
        --考虑到卡等级情况，现在需要移除“世界等级-10时不能建群“的规则，即纯读表
        -- if RoleManager.Instance.RoleData.lev < RoleManager.Instance.world_lev - 10 then
        --     NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前等级小于<color='#00ff00'>%s级</color>，无法创建群组"), tostring(RoleManager.Instance.world_lev - 10)))
        --     return
        -- end
        local freenum, nextdata = FriendGroupManager.Instance:CheckCreate()
        if freenum == 0 then
            if nextdata ~= nil then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("当前等级可创建群组数量已达上限，%s级可开启更多群组"), nextdata.lev))
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("当前可创建群组数量已达上限"))
            end
        else
            self.parent:CreatGroup()
        end
        return
    elseif self.data.time == math.huge then
        self.parent.Mainwin:ShowGroupRequest()
        return
    end
    self.parent.Mainwin:SwitchRightGroup(6)
    self.parent.Mainwin.groupchatPanel:SetTarget(self.data)
    if self.parent.selectObj ~= nil then
        self.parent.selectObj:SetActive(false)
    end
    self.parent.selectObj = self.Select
    self.parent.selectObj:SetActive(true)
    self.Red:SetActive(false)
    FriendManager.Instance.model:CheckRedPoint()
end

function GroupItem:OpenInfoPanel()
    FriendGroupManager.Instance.model:OpenInfoPanel({self.data.group_rid, self.data.group_platform, self.data.group_zone_id})
end

function GroupItem:Refresh(args)

end

function GroupItem:__delete()
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    self.parent = nil
end

function GroupItem:GetOnlineStr()
    local gdata = FriendGroupManager.Instance:GetGroupData(self.data.group_rid, self.data.group_platform, self.data.group_zone_id)
    if gdata == nil then
        return ""
    end
    local onlinenum = 0
    for i,v in ipairs(gdata.members) do
        if v.online == 1 then
            onlinenum = onlinenum + 1
        end
    end
    return string.format("(%s/%s)", onlinenum, #gdata.members)
end
