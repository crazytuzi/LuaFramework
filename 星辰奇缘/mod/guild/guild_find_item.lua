GuildFindItem = GuildFindItem or BaseClass()

function GuildFindItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.data = nil
    self.parent = parent

    local itr = self.gameObject.transform
    self.bg =  itr:FindChild("bg"):GetComponent(Image)
    self.selBg= itr:FindChild("selBg"):GetComponent(Image)
    self.selBg.gameObject:SetActive(false)
    self.TxtName= itr:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev= itr:FindChild("TxtLev"):GetComponent(Text)
    self.TxtNum= itr:FindChild("TxtNum"):GetComponent(Text)
    self.TxtNumRect = itr:FindChild("TxtNum"):GetComponent(RectTransform)
    self.TxtLeader= itr:FindChild("TxtLeader"):GetComponent(Text)
    self.ImgToTem =  itr:FindChild("ImgTuTeng"):GetComponent(Image)

    self.TxtName.color = Color(232/255, 250/255, 255/255, 1)
    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.parent:on_select_update_right(self)  end)
end

function GuildFindItem:Release()
    self.ImgToTem.sprite = nil
end

function GuildFindItem:update_my_self(_data, _index)
    self:on_set_selected_state(false)
    if self.last_selected_item ~= nil then
        if self.last_selected_item.data ~= nil and self.last_selected_item.data.GuildId == _data.GuildId then
            self:on_set_selected_state(true)
        end
    end
    self.data = _data

    self.TxtName.text = string.format("<color='#205696'>%s</color>", self.data.Name)
    self.TxtLev.text = string.format(ColorHelper.ListItemStr, tostring(self.data.Lev))

    local fenzi = self.data.MemNum + self.data.FreshNum
    local fenmu = self.data.MaxMemNum + self.data.MaxFreshNum

    self.TxtNum.text = string.format(ColorHelper.ListItemStr, string.format("%s/%s", fenzi , fenmu))
    self.TxtNumRect.sizeDelta = Vector2(self.TxtNum.preferredWidth, 30)
    self.TxtLeader.text = string.format("<color>%s</color>", self.data.LeaderName)

    self.ImgToTem.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(self.data.ToTem))


    if _index%2 == 0 then
        --偶数
        self.bg.color = ColorHelper.ListItem1
    else
        --单数
        self.bg.color = ColorHelper.ListItem2
    end

    -- self:set_has_apply(self.data.hasApply)

    if _index == 1 then
        self.parent:on_select_update_right(self)
    end
end

function GuildFindItem:Refresh(args)
    self.data.hasApply = true
    self:set_has_apply(self.data.hasApply)
end

function GuildFindItem:on_set_selected_state(state)
    self.selBg.gameObject:SetActive(state)
end

function GuildFindItem:on_item_click_oper()
    self.data.hasApply = true
    self:set_has_apply(self.data.hasApply)
    GuildManager.Instance:request11104(self.data.GuildId,self.data.PlatForm,self.data.ZoneId)
end

function GuildFindItem:set_has_apply(state)
    if state then--已申请
    --     self.BtnOper.enabled = false
    --     self.BtnOper.image.color = Color.grey
    --     local btnTxt = self.BtnOper.transform:FindChild("Text"):GetComponent(Text)
    --     btnTxt.text = TI18N("已申请")
    -- else
    --     self.BtnOper.enabled = true
    --     self.BtnOper.image.color = Color.white
    --     local btnTxt = self.BtnOper.transform:FindChild("Text"):GetComponent(Text)
    --     btnTxt.text = TI18N("申请")
    end
end


