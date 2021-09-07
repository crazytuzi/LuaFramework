GroupInviteItem = GroupInviteItem or BaseClass()

function GroupInviteItem:__init(gameObject, parent, side)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent
    self.side = side
    self.transform = self.gameObject.transform

    self.headSlot = HeadSlot.New()
    self.transform:Find("Headbg"):GetComponent(Image).enabled = false
    self.HeadbgImg = self.transform:Find("Headbg"):GetComponent(Image)
    self.headSlot:SetRectParent(self.transform:Find("Headbg"))

    self.headObj = self.transform:Find("Head").gameObject
    self.Mix = self.transform:Find("Mix").gameObject
    self.headObj:SetActive(false)
    self.HeadImg = self.transform:Find("Head"):GetComponent(Image)
    self.Select = self.transform:Find("Select")
    self.LevText = self.transform:Find("LevText"):GetComponent(Text)
    self.ClassIcon = self.transform:Find("ClassIcon"):GetComponent(Image)
    self.name = self.transform:Find("name"):GetComponent(Text)
    self.friendMark = self.transform:Find("FriendMark").gameObject
    self.label = self.transform:Find("label")
    -- self.Text = self.transform:Find("label/Text"):GetComponent(Text)
    if self.side == 1 then
        self.Invited = self.transform:Find("Invited").gameObject
    end
    self.ArrowButton = self.transform:Find("Button"):GetComponent(Button)
    self.ArrowButton.onClick:AddListener(function()
        if self.parent.type == 2 and self.parent.friendMgr:IsFriend(self.data.id, self.data.platform, self.data.zone_id) then 
            NoticeManager.Instance:FloatTipsByString(TI18N("Ta是你的好友，不可直接拉黑{face_1,3}"))
            return
        end
        if self.side == 1 then
            self.parent:AddOne(self.data)
        else
            self.parent:ReduceOne(self.data)
        end
    end)
    self.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnBtnClick()
    end)
    -- self.transform:GetComponent(Button).onClick:RemoveAllListeners()
    -- self.transform:GetComponent(Button).onClick:AddListener(function() self:OnClickPlayer(item, data) end)
end

--设置


function GroupInviteItem:InitPanel(data)
    self:update_my_self(data)
end

--设置索引
function GroupInviteItem:set_my_index(_index)
    -- self.item_index = _index
end

--更新内容
function GroupInviteItem:update_my_self(data, _index)
    self.data = data
    local dat = {id = data.id, platform = data.platform, zone_id = data.zone_id,classes = data.classes, sex = data.sex}
    self.headSlot:SetAll(dat, {isSmall = true})

    self.LevText.text = tostring(data.lev)
    self.ClassIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
    self.name.text = data.name
    if self.side == 1 then
        self.Invited:SetActive(self.parent:IsSended(self.data))
        self.ArrowButton.gameObject:SetActive(not self.parent:IsSended(self.data))
    end
    if data.online ~= 0 then
        self.headSlot:SetGray(false)
        self.HeadImg:GetComponent(Image).color = Color(1,1,1)
        self.name.color = Color(12/255, 82/255, 176/255)
    else
        self.headSlot:SetGray(true)
        self.HeadImg:GetComponent(Image).color = Color(0.5, 0.5, 0.5)
        self.name.color = Color(0.5, 0.5, 0.5)
    end
    self.Mix:SetActive(not BaseUtils.IsTheSamePlatform(data.platform, data.zone_id))

    if self.parent.type == 2 then 
        self.friendMark:SetActive(self.parent.friendMgr:IsFriend(data.id, data.platform, data.zone_id))
    end
end

function GroupInviteItem:OnBtnClick()
    -- if self.data.time == -1 then
    --     self.parent:CreatGroup()
    --     return
    -- end
    -- if self.parent.selectObj ~= nil then
    --     self.parent.selectObj:SetActive(false)
    -- end
    -- self.parent.selectObj = self.Select
    -- self.parent.selectObj:SetActive(true)
end


function GroupInviteItem:Refresh(args)

end

function GroupInviteItem:__delete()
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    self.parent = nil
end