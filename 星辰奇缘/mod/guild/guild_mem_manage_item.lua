GuildMemManageItem = GuildMemManageItem or BaseClass()

function GuildMemManageItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil
    self.parent = parent

    self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform
    self.ImgOne = self.transform:FindChild("ImgOne"):GetComponent(Image)
    self.Toggle = self.transform:Find("Toggle")
    self.Checkmark  = self.Toggle:FindChild("Background"):FindChild("Checkmark").gameObject
    self.ImgHeadCon = self.transform:FindChild("ImgHead"):GetComponent(Image)
    self.ImgHead = self.ImgHeadCon.gameObject.transform:FindChild("Img"):GetComponent(Image)
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtPos = self.transform:FindChild("TxtPos"):GetComponent(Text)
    self.TxtGx = self.transform:FindChild("TxtGx"):GetComponent(Text)
    self.TxtCup = self.transform:FindChild("TxtCup"):GetComponent(Text)
    self.TxtLastLogin = self.transform:FindChild("TxtLastLogin"):GetComponent(Text)
    self.TxtTakePartTime = self.transform:FindChild("TxtTakePartTime"):GetComponent(Text)
    self.ImgSelected = self.transform:FindChild("ImgSelected"):GetComponent(Image)
    self.ImgSelected.gameObject:SetActive(false)
    self.item_index = 1

    self.Checkmark:SetActive(false)
    self.selected_state = false

    -- self.Toggle.onValueChanged:AddListener(function (status)
    --     if self.data.deleted == true then
    --         return
    --     end
    --     if self.data.Rid == RoleManager.Instance.RoleData.id and self.data.PlatForm == RoleManager.Instance.RoleData.platform and self.data.ZoneId == RoleManager.Instance.RoleData.zone_id then
    --         return
    --     end
    --     self.selected_state = status
    --     self.args.callback(self)
    -- end)


    self.Toggle:GetComponent(Button).onClick:AddListener(function()
        if self.data.deleted == true then
            return
        end
        self:on_select_mem_item()
    end)

    self.transform:GetComponent(Button).onClick:AddListener(function()
        if self.data.deleted == true then
            return
        end
        self:on_select_mem_item()
    end)

    self.update_info_func = function(_data)

        if _data.data.deleted == true then
            if self.data ~= nil and self.data.Rid == _data.data.Rid  and self.data.PlatForm == _data.data.PlatForm  and self.data.ZoneId == _data.data.ZoneId then
                self:on_select_mem_item(false)

                -- print("-------------------------------------进来标记开除")
                self.data = _data.data
                --标记已开除
                self.ImgSelected.gameObject:SetActive(false)
                self.ImgHead.color = Color(1, 1, 1, 140/255)
                self.ImgOne.color = Color(96/255, 96/255, 96/255, 1)
                self.TxtName.text = string.format("<color='#6c86b4'>%s</color>", self.data.Name)
                self.TxtLev.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.Lev))
                self.TxtPos.text = string.format("<color='#6c86b4'>%s</color>", GuildManager.Instance.model.member_position_names[self.data.Post])
                self.TxtGx.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.active)) --string.format("%s/%s", self.data.TotalGx, self.data.GongXian))
                self.TxtCup.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.ability))--tostring(self.data.cup))

                local time = os.date("*t", self.data.LastLogin)
                self.TxtLastLogin.text = string.format("<color='#6c86b4'>%s</color>", string.format("%s-%s", time.month, time.day))
                local t_time = os.date("*t", self.data.EnterTime)
                self.TxtTakePartTime.text = string.format("%s-%s", t_time.month, t_time.day)
                self:on_select_mem_item(false)
            end
        elseif _data.data.updated == true then
            if self.data ~= nil and self.data.Rid == _data.data.Rid  and self.data.PlatForm == _data.data.PlatForm  and self.data.ZoneId == _data.data.ZoneId then
                if self.data.deleted ~= true then
                    self:update_my_self(_data.data)
                end
            end
        end
    end
    EventMgr.Instance:AddListener(event_name.guild_member_update, self.update_info_func)
end

function GuildMemManageItem:Release()
    EventMgr.Instance:RemoveListener(event_name.guild_member_update, self.update_info_func)
end

function GuildMemManageItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function GuildMemManageItem:update_my_self(_data, item_index)
    self.ImgSelected.gameObject:SetActive(false)
    self.data = _data
    self.ImgHead.color = Color(1, 1, 1, 1)

    if item_index ~= nil then
        self:reset_selected()
        self.item_index = item_index

        if self.parent.selected_list[self.item_index] ~= nil then
            self:on_select_mem_item()
        else
            if self.item_index == 1 then
            --默认选中第一个
                if self.data.Rid ~= RoleManager.Instance.RoleData.id or self.data.PlatForm ~= RoleManager.Instance.RoleData.platform or self.data.ZoneId ~= RoleManager.Instance.RoleData.zone_id then
                    self:on_select_mem_item()
                end
            end
        end
    end

    if self.item_index%2 == 0 then
        --偶数
        self.ImgOne.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgOne.color = ColorHelper.ListItem2
    end

    self.ImgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(self.data.Classes),tostring(self.data.Sex)))


    if self.data.Status == 1 then
        --在线啊
        -- self.TxtName.text = self.data.Name
        -- self.TxtLev.text = tostring(self.data.Lev)
        -- self.TxtPos.text = GuildManager.Instance.model.member_position_names[self.data.Post]
        -- self.TxtGx.text = string.format("%s/%s", self.data.TotalGx , self.data.GongXian)
        -- self.TxtCup.text = tostring(self.data.cup)
        self.TxtName.text = string.format(ColorHelper.ListItemStr, self.data.Name)
        self.TxtLev.text = string.format(ColorHelper.ListItemStr, tostring(self.data.Lev))
        self.TxtPos.text = string.format(ColorHelper.ListItemStr, GuildManager.Instance.model.member_position_names[self.data.Post])
        self.TxtGx.text = string.format(ColorHelper.ListItemStr, tostring(self.data.active))
        self.TxtCup.text = string.format(ColorHelper.ListItemStr, tostring(self.data.ability))

        self.TxtLastLogin.text = string.format(ColorHelper.ListItemStr, TI18N("在线"))
    else
        self.TxtName.text = string.format("<color='#6c86b4'>%s</color>", self.data.Name)
        self.TxtLev.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.Lev))
        self.TxtPos.text = string.format("<color='#6c86b4'>%s</color>", GuildManager.Instance.model.member_position_names[self.data.Post])
        self.TxtGx.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.active))
        self.TxtCup.text = string.format("<color='#6c86b4'>%s</color>", tostring(self.data.ability))

        local time = os.date("*t", self.data.LastLogin)
        self.TxtLastLogin.text = string.format("<color='#6c86b4'>%s</color>", string.format("%s-%s", time.month, time.day))
    end

    local t_time = os.date("*t", self.data.EnterTime)
    self.TxtTakePartTime.text = string.format(ColorHelper.ListItemStr, string.format("%s-%s", t_time.month, t_time.day))
end

function GuildMemManageItem:Refresh(args)
    --更新信息，用于更新开除或者更新职位状态
    if args._type == 1 then
        self.ImgSelected.gameObject:SetActive(false)
    end
end

function GuildMemManageItem:on_click_red_bag()
    if self.data.RedBagAmount > 0 then
        -- mod_guild.open_red_bag_interface(self.data.Rid, self.data.ZoneId, self.data.PlatForm)
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


function GuildMemManageItem:on_select_mem_item(state)
    if self.data.Rid == RoleManager.Instance.RoleData.id and self.data.PlatForm == RoleManager.Instance.RoleData.platform and self.data.ZoneId == RoleManager.Instance.RoleData.zone_id then
        NoticeManager.Instance:FloatTipsByString(TI18N("不能选中自己哦"))
        return
    end

    if state == nil then
        state = not self.selected_state
        local last_state = self.selected_state
        self.Checkmark:SetActive(state)
        self.selected_state = state
        if last_state ~= state then
            self.parent:on_click_mem_item(self)
        end
    else
        self.Checkmark:SetActive(state)
        self.selected_state = state
    end
end

--重置选中状态
function GuildMemManageItem:reset_selected()
    self.Checkmark:SetActive(false)
    self.selected_state = false
end