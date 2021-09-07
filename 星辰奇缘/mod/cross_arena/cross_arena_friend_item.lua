CrossArenaWindowFriendItem = CrossArenaWindowFriendItem or BaseClass()

function CrossArenaWindowFriendItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.parent = parent
    self.transform = self.gameObject.transform
    -- self.ImgBg = self.transform:GetComponent(Image)

    self.head = self.transform:Find("Head")
    self.nameText = self.transform:Find("NameText"):GetComponent(Text)
    self.levelText = self.transform:Find("Level/Text"):GetComponent(Text)
    self.mixImage = self.transform:Find("MixImage").gameObject

    self.headSlot = HeadSlot.New()
    self.headSlot:SetRectParent(self.head.transform)

    self.transform:GetComponent(Button).onClick:AddListener(function()
        if self.parent.currIndex == 1 then
            self.okButton.gameObject:SetActive(true)
        else
            FriendManager.Instance:TalkToUnknowMan(self.data)
        end
    end)

    self.okButton = self.transform:Find("OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function()
            local btns = {}
            table.insert(btns, {label = TI18N("邀请组队"), callback = function() CrossArenaManager.Instance.model:InvitationAndCreateRoom(self.data, 1) end})
            table.insert(btns, {label = TI18N("邀请决战"), callback = function() CrossArenaManager.Instance.model:InvitationAndCreateRoom(self.data, 2) end})
            TipsManager.Instance:ShowButton({gameObject = self.okButton.gameObject, data = btns})
        end)
    self.deleteButton = self.transform:Find("DeleteButton"):GetComponent(Button)
    self.deleteButton.onClick:AddListener(function()
            -- CrossArenaManager.Instance:Send20716(self.data.id, self.data.platform, self.data.zone_id)
        end)

    self.okButton.gameObject:SetActive(false)
    self.deleteButton.gameObject:SetActive(false)

    self.item_index = 1
end

function CrossArenaWindowFriendItem:Release()
end

--设置索引
function CrossArenaWindowFriendItem:SetMyIndex(index)
    self.item_index = index
    -- if self.item_index%2 == 0 then  --偶数
    --     self.ImgBg.color = Color(155/255, 199/255, 239/255, 1)
    -- else --单数
    --     self.ImgBg.color = Color(129/255, 179/255, 233/255, 1)
    -- end
end

--更新内容
function CrossArenaWindowFriendItem:update_my_self(data, index)
    self.data = data
    self:SetMyIndex(index)

    -- local headData = { id = data.id, platform = data.platform, zone_id = data.zone_id, classes = data.classes, sex = data.sex}
    self.headSlot:SetAll(data, {isSmall = true})
    self.headSlot:SetGray(data.online == nil or data.online == 0)

    self.nameText.text = data.name
    self.levelText.text = tostring(data.lev)

    self.mixImage:SetActive(not BaseUtils.IsTheSamePlatform(data.platform, data.zone_id))

    self.okButton.gameObject:SetActive(false)
    self.deleteButton.gameObject:SetActive(false)
end