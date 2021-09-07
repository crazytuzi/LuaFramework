GuildApplyListItem = GuildApplyListItem or BaseClass()

function GuildApplyListItem:__init(gameObject, args)
    self.gameObject = gameObject
    self.data = nil
    self.args = args

    local itr = self.gameObject.transform

    self.transform = self.gameObject.transform
    self.ImgOne = self.gameObject:GetComponent(Image)
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtCareer = self.transform:FindChild("TxtCareer"):GetComponent(Text)
    self.ImgHeadCon = self.transform:FindChild("ImgHeadCon").gameObject
    self.ImgHead = self.ImgHeadCon.transform:FindChild("Img"):GetComponent(Image)
    self.BtnAgree = self.transform:FindChild("BtnAgree"):GetComponent(Button)
    self.BtnReject = self.transform:FindChild("BtnReject"):GetComponent(Button)
    self.TxtMsg = self.transform:FindChild("TxtMsg"):GetComponent(Text)

    self.BtnAgree.onClick:AddListener(function() self:item_btn_click(1) end)
    self.BtnReject.onClick:AddListener(function() self:item_btn_click(2) end)
end

function GuildApplyListItem:Release()
    self.ImgHead.sprite = nil
end

function GuildApplyListItem:Refresh(args)

end

function GuildApplyListItem:InitPanel(_data)
    self.data = _data.data

    if _data.item_index%2 == 0 then
        --偶数
        self.ImgOne.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgOne.color = ColorHelper.ListItem2
    end

    self.TxtName.text = string.format(ColorHelper.ListItemStr, TI18N(self.data.Name))
    self.TxtLev.text = string.format(ColorHelper.ListItemStr, tostring(self.data.Lev))
    self.TxtCareer.text = string.format(ColorHelper.ListItemStr, KvData.classes_name[self.data.Classes])
    self.ImgHead.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads ,string.format("%s_%s",tostring(self.data.Classes),tostring(self.data.Sex)))

    local msg = self.data.msg
    if msg == "" then
        if self.data.tag == 2 then
            msg = TI18N("玩转星辰很轻松，带你躺赢带你飞")
        elseif self.data.tag == 3 then
            msg = TI18N("调节气氛我在行，公会活跃少不了")
        elseif self.data.tag == 4 then
            msg = TI18N("撒娇卖萌古灵精，唱歌跳舞样样行")
        end
    end
    self.TxtMsg.text = string.format(TI18N("留言：%s"), msg)
    -- ad.tag = data.tag
    --     ad.msg = data.msg
end


function GuildApplyListItem:item_btn_click(index)
    if GuildManager.Instance.model:get_my_guild_post() < GuildManager.Instance.model.member_positions.elder then
        NoticeManager.Instance:FloatTipsByString(TI18N("权限不足无法操作"))
        return
    end
    if 1 == index then
        GuildManager.Instance:request11124(self.data.Rid,  self.data.PlatForm,  self.data.ZoneId,  1)
    elseif 2 == index then
        GuildManager.Instance:request11124(self.data.Rid,  self.data.PlatForm,  self.data.ZoneId,  0)
    end
end