GuildMemberItem = GuildMemberItem or BaseClass()

function GuildMemberItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform
    self.ImgOne = self.transform:FindChild("ImgOne"):GetComponent(Image)
    self.ImgHeadCon = self.transform:FindChild("ImgHead"):GetComponent(Image)
    self.ImgHead = self.ImgHeadCon.gameObject.transform:FindChild("Img"):GetComponent(Image)
    self.TxtDeleted = self.ImgHeadCon.gameObject.transform:FindChild("Text").gameObject
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtPos = self.transform:FindChild("TxtPos"):GetComponent(Text)
    self.TxtGx = self.transform:FindChild("TxtGx"):GetComponent(Text)
    self.TxtCup = self.transform:FindChild("TxtCup"):GetComponent(Text)
    self.ImgNeed = self.transform:FindChild("ImgNeed"):GetComponent(Image)
    self.ImgSelected = self.transform:FindChild("ImgSelected"):GetComponent(Image)
    self.ImgNeed.gameObject:SetActive(false)
    self.ImgSelected.gameObject:SetActive(false)
    self.TxtDeleted:SetActive(false)
    self.item_index = 1

    self.transform:GetComponent(Button).onClick:AddListener(function()
        if self.data.deleted == true then
            return
        end
        self:on_select_mem_item()
    end)

    self.update_info_func = function(_data)
        if _data.data.deleted == true then
            if self.data ~= nil and self.data.Rid == _data.data.Rid  and self.data.PlatForm == _data.data.PlatForm  and self.data.ZoneId == _data.data.ZoneId then
                self.data = _data.data
                --标记已开除
                self.ImgSelected.gameObject:SetActive(false)
                self.ImgHead.color = Color(1, 1, 1, 140/255)
                -- self.ImgOne.color = Color(96/255, 96/255, 96/255, 1)
                self.TxtName.text = string.format("<color='#6c86b4'>%s</color>", self.data.Name)
                self.TxtLev.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.Lev))
                self.TxtPos.text = string.format("<color='#6c86b4'>%s</color>", GuildManager.Instance.model.member_position_names[self.data.Post])
                self.TxtGx.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.active))--string.format("%s/%s", self.data.TotalGx, self.data.GongXian))
                self.TxtCup.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.ability))
            end
        elseif _data.data.updated == true then
            if self.data ~= nil and self.data.Rid == _data.data.Rid  and self.data.PlatForm == _data.data.PlatForm  and self.data.ZoneId == _data.data.ZoneId then
                self:update_my_self(_data.data, self.item_index)
            end
        end
    end
    EventMgr.Instance:AddListener(event_name.guild_member_update, self.update_info_func)
end

--设置
function GuildMemberItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function GuildMemberItem:Release()
    self.ImgHead.sprite = nil
    EventMgr.Instance:RemoveListener(event_name.guild_member_update, self.update_info_func)
end

function GuildMemberItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function GuildMemberItem:set_my_index(_index)
    self.item_index = _index
    if self.item_index%2 == 0 then
        --偶数
        self.ImgOne.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgOne.color = ColorHelper.ListItem2
    end
end

--更新内容
function GuildMemberItem:update_my_self(_data, _index)
    self.ImgSelected.gameObject:SetActive(false)
    self.data = _data
    self.TxtDeleted:SetActive(false)
    self.ImgHead.color = Color(1, 1, 1, 1)

    self:set_my_index(_index)

    if self.parent.selected_mem_data ~= nil then

        --判断下是否是选中列表中的数据
        if self.parent.selected_mem_data.Rid == self.data.Rid and self.parent.selected_mem_data.PlatForm == self.data.PlatForm and self.parent.selected_mem_data.ZoneId == self.data.ZoneId then
            self:on_select_mem_item(1)
        end
    else
        if self.item_index == 1 then
        --默认选中第一个
            self:on_select_mem_item(1)
        end
    end



    self.ImgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(self.data.Classes),tostring(self.data.Sex)))


    if self.data.Status == 1 then
        --在线啊
        -- self.TxtName.text = self.data.Name
        -- self.TxtLev.text = tostring(self.data.Lev)
        -- self.TxtPos.text = GuildManager.Instance.model.member_position_names[self.data.Post]
        -- self.TxtGx.text = string.format("%s/%s", self.data.TotalGx , self.data.GongXian)
        -- self.TxtCup.text = tostring(self.data.ability)
        self.TxtName.text = string.format(ColorHelper.ListItemStr, self.data.Name)
        self.TxtLev.text = string.format(ColorHelper.ListItemStr, tostring(self.data.Lev))
        self.TxtPos.text = string.format(ColorHelper.ListItemStr, GuildManager.Instance.model.member_position_names[self.data.Post])
        self.TxtGx.text = string.format(ColorHelper.ListItemStr, tostring(self.data.active))
        self.TxtCup.text = string.format(ColorHelper.ListItemStr, tostring(self.data.ability))
    else
        self.TxtName.text = string.format("<color='#6c86b4'>%s</color>", self.data.Name)
        self.TxtLev.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.Lev))
        self.TxtPos.text = string.format("<color='#6c86b4'>%s</color>", GuildManager.Instance.model.member_position_names[self.data.Post])
        self.TxtGx.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.active))
        self.TxtCup.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.ability))
    end
    if self.data.RedBagAmount > 0 or #self.data.requirement>0 then
        self.ImgNeed.gameObject:SetActive(true)
        if self.data.RedBagAmount > 0 then
            self.ImgNeed.gameObject.transform:Find("ImgNeed").gameObject:SetActive(true)
            self.ImgNeed.gameObject.transform:Find("Imgbox").gameObject:SetActive(false)
        elseif #self.data.requirement>0 then
            self.ImgNeed.gameObject.transform:Find("ImgNeed").gameObject:SetActive(false)
            self.ImgNeed.gameObject.transform:Find("Imgbox").gameObject:SetActive(true)
        end
        local btn = self.ImgNeed.gameObject.transform:GetComponent(Button) or self.ImgNeed.gameObject:AddComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() self:on_click_red_bag() end)
    else
        self.ImgNeed.gameObject:SetActive(false)
    end
end

function GuildMemberItem:Refresh(args)
    --更新信息，用于更新开除或者更新职位状态
    if args._type == 1 then
        self.ImgSelected.gameObject:SetActive(false)
    end
end

function GuildMemberItem:on_click_red_bag()
    if self.data.LeftRedBagValue > 0 then
        GuildManager.Instance:request11132(self.data.Rid, self.data.ZoneId, self.data.PlatForm)
    elseif self.data.LeftRedBagValue == 0 and self.data.RedBagAmount > 0 then
        GuildManager.Instance:request11132(self.data.Rid, self.data.ZoneId, self.data.PlatForm)
    elseif #self.data.requirement > 0 and self.data.requirement[1].requirement_type == 1 then
        local boxid = 0
        for k,v in pairs(self.data.requirement[1].requirement_digit) do
            if v.digit_key == 1 then
                boxid = v.digit_value
            end
        end
        if boxid ~= 0 then
            if self.data.Rid == RoleManager.Instance.RoleData.id and self.data.PlatForm == RoleManager.Instance.RoleData.platform and self.data.ZoneId == RoleManager.Instance.RoleData.zone_id then
                NoticeManager.Instance:FloatTipsByString(TI18N("您已发起公会求助"))
                return
            end
            local _data = {role_id = self.data.Rid, platform = self.data.PlatForm, zone_id = self.data.ZoneId, cell_id = boxid, name = self.data.Name}
            ShippingManager.Instance.guildhelp_info = _data
            ShippingManager.Instance:Req13710(1, self.data.Rid, self.data.PlatForm, self.data.ZoneId, boxid)
        end
    end
end


function GuildMemberItem:on_select_mem_item(_type)
    self.parent:on_click_mem_item(self.data, _type)
    self.ImgSelected.gameObject:SetActive(true)
end