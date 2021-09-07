GuildMergeTipsWindow = GuildMergeTipsWindow or BaseClass(BasePanel)

function GuildMergeTipsWindow:__init(model)
    self.name = "GuildMergeTipsWindow"
    self.model = model

    self.windowId = WindowConfig.WinID.guild_merge_tips_win


    self.resList = {
        {file = AssetConfig.guild_merge_tips_win, type = AssetType.Main}
    }
    return self
end

function GuildMergeTipsWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function GuildMergeTipsWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_merge_tips_win))
    self.gameObject.name = "GuildMergeTipsWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main_con = self.transform:FindChild("MainCon").gameObject.transform

    local close_btn = self.main_con:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseGuildMergeTipsUI() end)


    self.ImgItemTop = self.main_con:FindChild("ImgItemTop")
    self.TxtDescVal = self.ImgItemTop:FindChild("TxtDescVal"):GetComponent(Text)
    self.ImgTanhao = self.ImgItemTop:FindChild("ImgTanhao"):GetComponent(Button)

    self.ImgItem = self.main_con:FindChild("ImgItem")
    self.TxtDesc = self.ImgItem:FindChild("TxtDesc"):GetComponent(Text)

    self.BtnCancel = self.main_con:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.main_con:FindChild("BtnCreate"):GetComponent(Button)

    self.img_blue = self.BtnCancel.image.sprite
    self.img_grey = self.BtnCreate.image.sprite

    self.BtnCreate.image.sprite = self.img_blue
    self.main_con:FindChild("BtnCreate"):FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3

    self.ImgTanhao.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1.公会成员每天完成<color='#2fc823'>公会任务</color>并且提交<color='#2fc823'>荣耀徽章</color>可增加公会健康度，公会等级越高，每天要求<color='#2fc823'>荣耀徽章</color>越高"))
        table.insert(tips, TI18N("2.公会健康度在<color='#ffa500'>兴旺昌盛</color>、<color='#ffa500'>生机盎然</color>、<color='#01c0ff'>中规中矩</color>、<color='#2fc823'>危在旦夕</color>可向其他公会发起合并申请"))
        table.insert(tips, TI18N("3.公会健康度在<color='#2fc823'>危在旦夕</color>、<color='#df3435'>独木难支</color>的公会将被系统降级，降为1级后会被系统自动合并至其他公会"))
        table.insert(tips, TI18N("4.排名前3的公会不可申请合入其他公会，同样也不能接受其他公会的合并申请"))
        TipsManager.Instance:ShowText({gameObject = self.ImgTanhao.gameObject, itemData = tips})
    end)
    self.BtnCancel.onClick:AddListener(function()
        -- if self.model.my_guild_data.Health > 80 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("我们公会兴旺昌盛，不需要申请合入至其他公会"))
        --     return
        -- end

        self.model.merge_type = 1 --申请合入
        self.model:InitGuildMergeUI()
    end)

    self.BtnCreate.onClick:AddListener(function()
        -- if self.model.my_guild_data.Health > 80 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("当前公会不能合并其他公会"))
        --     return
        -- end

        self.model.merge_type = 2 --请求列表进来
        self.model:InitGuildMergeUI()
    end)

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    GuildManager.Instance:request11106()
    GuildManager.Instance:request11100()
end

--更新公会健康度
function GuildMergeTipsWindow:update_guild_healthy()
    self.TxtDescVal.text = string.format("%s<color='#2fc823'>%s</color>", TI18N("当前健康度："), self.model:get_guild_healthy_name())
    self.TxtDesc.text = self.model:get_guild_healthy_desc()
    -- if self.model.my_guild_data.Health <= 80 then
    --     self.BtnCancel.image.sprite = self.img_blue
    -- else
    --     self.BtnCancel.image.sprite = self.img_grey
    -- end

    -- if self.model.my_guild_data.Health <= 80 then
    --     self.BtnCreate.image.sprite = self.img_blue
    -- else
    --     self.BtnCreate.image.sprite = self.img_grey
    -- end
end