ChildrenGiveUpItem = ChildrenGiveUpItem or BaseClass()

function ChildrenGiveUpItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform
    self.Button = self.transform:GetComponent(Button)

    self.Select = self.transform:Find("Select").gameObject
    self.NameText = self.transform:Find("NameText"):GetComponent(Text)
    self.LVText = self.transform:Find("LVText"):GetComponent(Text)
    self.Head_78 = self.transform:Find("Head_78")
    self.HeadBg = self.transform:Find("Head_78/HeadBg")
    self.Head = self.transform:Find("Head_78/Head"):GetComponent(Image)
    self.ClassesIcon = self.transform:Find("ClassesIcon"):GetComponent(Image)
    self.Classes = self.transform:Find("Classes"):GetComponent(Text)
end

--设置


function ChildrenGiveUpItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function ChildrenGiveUpItem:set_my_index(_index)
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
function ChildrenGiveUpItem:update_my_self(_data, _index)
    local dat = {id = _data.id, platform = _data.platform, zone_id = _data.zone_id,classes = _data.classes, sex = _data.sex}
    local baseData = DataChild.data_child[_data.base_id]
    if self.parent.currData == nil or self.parent.currData.child_id ~= _data.child_id then
        self.Select:SetActive(false)
    else
        self.Select:SetActive(true)
    end
    self.LVText.text = _data.lev
    if baseData == nil then
        if _data.sex == 1 then
            self.NameText.text = TI18N("胎儿 （孕育期）")
        else
            self.NameText.text = TI18N("胎儿 （孕育期）")
        end
        self.Head.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.childhead, tostring(_data.sex))
        self.ClassesIcon.gameObject:SetActive(false)
        self.Classes.gameObject:SetActive(false)
        if _data.stage == ChildrenEumn.Stage.Fetus then
            self.LVText.text = string.format(TI18N("进度：%s/1000"), _data.maturity)
        else
            self.LVText.text = string.format(TI18N("进度：%s/100"), _data.maturity)
        end
    else
        self.ClassesIcon.gameObject:SetActive(true)
        self.Classes.gameObject:SetActive(true)
        self.NameText.text = _data.name
        self.Head.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.childhead, tostring(baseData.head_id))
        self.ClassesIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(_data.classes))
        self.Classes.text = KvData.classes_name[_data.classes]
        self.LVText.text = string.format(TI18N("等级：%s"), _data.lev)
    end
    self.Button.onClick:RemoveAllListeners()
    self.Button.onClick:AddListener(function()
        self.parent:OnClickItem(self, _data)
    end)
end

function ChildrenGiveUpItem:Refresh(args)

end

function ChildrenGiveUpItem:__delete()
    self.Head.sprite = nil
    self.ClassesIcon.sprite = nil
end

