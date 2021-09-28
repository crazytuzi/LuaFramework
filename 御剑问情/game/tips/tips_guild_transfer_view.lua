TipsGuildTransferView = TipsGuildTransferView or BaseClass(BaseView)

function TipsGuildTransferView:__init()
	self.ui_config = {"uis/views/guildview_prefab", "TipsTransferView"}
	self.view_layer = UiLayer.Pop
    self.play_audio = true
end

function TipsGuildTransferView:__delete()
end

-- 创建完调用
function TipsGuildTransferView:LoadCallBack()
    self.count = self:FindVariable("Count")
    self.name = self:FindVariable("Name")
    self.post = self:FindVariable("Post")

    for i = 1, 5 do
        self:ListenEvent("ClickTransfer" .. i,
            function() self:ClickTransfer(i) end)
    end
    self:ListenEvent("ClickOK",
        BindTool.Bind(self.ClickOK, self))
    self:ListenEvent("ClosenView",
        BindTool.Bind(self.ClosenView, self))
end

function TipsGuildTransferView:ReleaseCallBack()
    self.count = nil
    self.name = nil
    self.post = nil
end

function TipsGuildTransferView:OpenCallBack()
	self.select_post = 1
	self:OnClickChangePost()
end

function TipsGuildTransferView:ClickTransfer(index)
    if index == 1 then
        self.select_post = 3
        self.post:SetValue(Language.Guild.FuMengZhu)
    elseif index == 2 then
        self.select_post = 2
        self.post:SetValue(Language.Guild.ZhangLao)
    elseif index == 3 then
        self.select_post = 6
        self.post:SetValue(Language.Guild.HuFa)
    elseif index == 4 then
        self.select_post = 5
        self.post:SetValue(Language.Guild.JingYing)
    elseif index == 5 then
        self.select_post = 1
        self.post:SetValue(Language.Guild.PuTong)
    end
end

function TipsGuildTransferView:ClickOK()
    GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, self.uid, self.select_post)
    self:Close()
end

function TipsGuildTransferView:ClosenView()
	self:Close()
end

function TipsGuildTransferView:OnClickChangePost()
    local post = GuildData.Instance:GetGuildPost()
    if post == GuildDataConst.GUILD_POST.TUANGZHANG then
        self.count:SetValue(5)
    elseif post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
        self.count:SetValue(4)
    elseif post == GuildDataConst.GUILD_POST.ZHANG_LAO then
        self.count:SetValue(3)
    else
        self.count:SetValue(0)
    end
    self.name:SetValue(self.role_name)
    self.select_post = 1
    self.post:SetValue(Language.Guild.PuTong)
end

function TipsGuildTransferView:SetData(uid,role_name)
	self.uid = uid or 0
	self.role_name = role_name or ""
end