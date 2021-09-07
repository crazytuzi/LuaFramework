--  峡谷之巅便捷组队
-- @author hze
-- @time 2018.08.14
CanyonMakeTeamItem = CanyonMakeTeamItem or BaseClass()

function CanyonMakeTeamItem:__init(gameObject, parent)
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
    self.TxtCup = self.transform:FindChild("TxtCup")
    -- self.ImgNeed = self.transform:FindChild("ImgNeed"):GetComponent(Image)
    self.ImgSelected = self.transform:FindChild("ImgSelected"):GetComponent(Image)
    -- self.ImgNeed.gameObject:SetActive(false)
    self.ImgSelected.gameObject:SetActive(false)
    self.TxtDeleted:SetActive(false)
    self.BtnInvite = self.transform:Find("BtnInvite"):GetComponent(Button)
    self.BtnInvited = self.transform:Find("BtnInvited"):GetComponent(Button)
    self.BtnInvite.onClick:AddListener( function() self:onClick_InviteBtn()  end)
    self.BtnInvited.onClick:AddListener( function() NoticeManager.Instance:FloatTipsByString(TI18N("已经向对方发过邀请，请等待回复"))  end)
    self.BtnInvite_text = self.transform:Find("BtnInvite/Text"):GetComponent(Text)
    self.BtnInvited_text = self.transform:Find("BtnInvited/Text"):GetComponent(Text)

    self.item_index = 1

    self.selected_state = false

    self.transform:GetComponent(Button).onClick:AddListener(function()
        if self.data.deleted == true then
            return
        end
        self:on_select_mem_item()
    end)
end

function CanyonMakeTeamItem:onClick_InviteBtn()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        TeamManager.Instance:Send11704(self.data.roleid, self.data.platform, self.data.zoneid)
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        TeamManager.Instance:Send11702(self.data.roleid, self.data.platform, self.data.zoneid)
    end
    self.BtnInvite.gameObject:SetActive(false)
    self.BtnInvited.gameObject:SetActive(true)
    self.data.isOp = true
end

--设置
function CanyonMakeTeamItem:SetActive(boo)
    self.gameObject:SetActive(boo)
end

function CanyonMakeTeamItem:Release()
    self.ImgHead.sprite = nil
end

function CanyonMakeTeamItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function CanyonMakeTeamItem:set_my_index(_index)
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
function CanyonMakeTeamItem:update_my_self(_data, _index)
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



    self.ImgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(self.data.classes),tostring(self.data.sex)))

    self.TxtName.text = string.format(ColorHelper.ListItemStr, self.data.name)
    self.TxtLev.text = string.format(ColorHelper.ListItemStr, tostring(self.data.lev))

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        self.TxtPos.text = string.format(ColorHelper.ListItemStr, string.format("%s/5",self.data.team_num))
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        self.TxtPos.text = string.format(ColorHelper.ListItemStr, KvData.classes_name[self.data.classes])
    end
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        self.BtnInvite_text.text = TI18N("申请")
        self.BtnInvited_text.text = TI18N("已申请")
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        self.BtnInvite_text.text = TI18N("邀请")
        self.BtnInvited_text.text = TI18N("已邀请")
    end
    if self.data.isOp ~= nil and self.data.isOp == true then
        self.BtnInvite.gameObject:SetActive(false)
        self.BtnInvited.gameObject:SetActive(true)
    else
        self.BtnInvite.gameObject:SetActive(true)
        self.BtnInvited.gameObject:SetActive(false)
    end
end

function CanyonMakeTeamItem:on_select_mem_item(state)
    if state == nil then
        state = not self.selected_state
        local last_state = self.selected_state
        self.selected_state = state
        if last_state ~= state then
            self.parent:on_click_mem_item(self)
        end
    else
        self.selected_state = state
        self.parent:on_click_mem_item(self)
    end
end

--重置选中状态
function CanyonMakeTeamItem:reset_selected()
    self.selected_state = false
end