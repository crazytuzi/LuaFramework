FriendItem = FriendItem or BaseClass()

function FriendItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

    self.headSlot = HeadSlot.New()
    self.transform:Find("Headbg"):GetComponent(Image).enabled = false
    self.headSlot:SetRectParent(self.transform:Find("Headbg"))

    self.headObj = self.transform:Find("Head").gameObject

    self.mobile = self.transform:Find("name/Mobile").gameObject
    self.mobile:GetComponent(Button).onClick:AddListener(function() self:ClickMobile() end)
end

--设置


function FriendItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function FriendItem:set_my_index(_index)
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
function FriendItem:update_my_self(_data, _index)
    if _data.ishelp ~= nil then
        local nameText = self.transform:Find("name")
        local sigText = self.transform:Find("SigText")
        nameText:GetComponent(Text).text = TI18N("星辰小助手")
        sigText:GetComponent(Text).text = TI18N("有不懂的可以点我哦")
        nameText:GetComponent(Text).color = ColorHelper.Default

        nameText.localPosition = Vector2(81,-21)

        local buttonImg = self.transform:Find("Button/Image")
        buttonImg.localPosition = Vector2.zero
        buttonImg:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures,"InfoIcon3")
        local headImg = self.transform:Find("Headbg/HeadSlot/Custom/Base")
        headImg.gameObject:SetActive(true)
        headImg.localScale = Vector2(1.17,1.17)
        headImg:GetComponent(Image).color = Color(1,1,1)
        headImg:GetComponent(Image).sprite =self.parent.assetWrapper:GetSprite(AssetConfig.friendtexture,"HelpGril1")

        self.transform:Find("Select").gameObject:SetActive(false)

        self.transform:Find("ClassIcon").gameObject:SetActive(false)
        self.transform:Find("label").gameObject:SetActive(false)
        self.transform:Find("levbg").gameObject:SetActive(false)
        self.transform:Find("LevText").gameObject:SetActive(false)
        self.transform:Find("name/Mobile").gameObject:SetActive(false)
        self.transform:Find("Headbg/HeadSlot/Custom/Container").gameObject:SetActive(false)
        self.transform:Find("Headbg/HeadSlot/Select").gameObject:SetActive(false)
        self.transform:Find("Mix").gameObject:SetActive(false)
        self.transform:Find("Red").gameObject:SetActive(false)
        self.transform:Find("label").gameObject:SetActive(false)


        nameText:GetComponent(RectTransform).sizeDelta = Vector2(nameText:GetComponent(Text).preferredWidth + 10, 30)

        self.transform:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
        self.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function() self.OpenHelp() end)
        self.transform:GetComponent(Button).onClick:RemoveAllListeners()
        self.transform:GetComponent(Button).onClick:AddListener(function() self.OpenHelp() end)
        self.headObj:SetActive(false)

    else
        local dat = {id = _data.id, platform = _data.platform, zone_id = _data.zone_id,classes = _data.classes, sex = _data.sex}
        self.transform:Find("ClassIcon").gameObject:SetActive(true)
        self.transform:Find("label").gameObject:SetActive(true)
        self.transform:Find("levbg").gameObject:SetActive(true)
        self.transform:Find("LevText").gameObject:SetActive(true)
        local buttonImg = self.transform:Find("Button/Image")

        buttonImg:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures,"InfoIcon2")
        local nameText = self.transform:Find("name")
        nameText.localPosition = Vector2(111,-21)

        self.headSlot:SetAll(dat, {isSmall = true})
        self.parent:SetPlayerItem(self.gameObject, _data)
        self.headSlot:SetGray(_data.online ~= 1)
        self.headObj:SetActive(false)
    end
end

function FriendItem:Refresh(args)

end

function FriendItem:__delete()
    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    self.parent = nil
end

function FriendItem:ClickMobile()
    TipsManager.Instance:ShowText({gameObject = self.mobile, itemData = {TI18N("该玩家已开启离线消息提醒")}})
end

function FriendItem:OpenHelp()
    FriendManager.Instance.help = true
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window)
end