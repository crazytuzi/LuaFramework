GuildHealthyWindow = GuildHealthyWindow or BaseClass(BaseWindow)

function GuildHealthyWindow:__init(model)
    self.name = "GuildHealthyWindow"
    self.model = model

    self.windowId = WindowConfig.WinID.guild_healthy_win


    self.resList = {
        {file = AssetConfig.guild_healthy_win, type = AssetType.Main}
    }
    return self
end

function GuildHealthyWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function GuildHealthyWindow:InitPanel()
    if self.gameObject ~= nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_healthy_win))
    self.gameObject.name = "GuildHealthyWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.main_con = self.transform:FindChild("MainCon").gameObject.transform

    local close_btn = self.main_con:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseGuildHealthyUI() end)

    self.TxtHealthyNum = self.main_con:FindChild("TxtHealthyNum"):GetComponent(Text)
    self.ImgTanhao = self.main_con:FindChild("ImgTanhao"):GetComponent(Button)

    self.BtnCancel = self.main_con:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.main_con:FindChild("BtnCreate"):GetComponent(Button)

    self.img_blue = self.BtnCancel.image.sprite
    self.img_grey = self.BtnCreate.image.sprite

    self.ImgTanhao.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, TI18N("1.公会健康度≤50，可发起合并或申请合入公会（由会长操作）"))
        table.insert(tips, TI18N("2.公会健康度＜20，将被其他公会直接合并"))
        table.insert(tips, TI18N("3.公会成员每天上缴荣耀勋章数量过低会降低公会健康度"))
        TipsManager.Instance:ShowText({gameObject = self.ImgTanhao.gameObject, itemData = tips})
    end)
    self.BtnCancel.onClick:AddListener(function()
        if self.model.my_guild_data.Health > 50 then
            NoticeManager.Instance:FloatTipsByString(TI18N("我们公会目前还是很强大的，不需要合并"))
            return
        end
        self.model.merge_type = 1 --申请合入
        self.model:InitGuildMergeUI()
    end)

    self.BtnCreate.onClick:AddListener(function()
        if self.model.my_guild_data.Health > 50 then
            NoticeManager.Instance:FloatTipsByString(TI18N("我们公会目前还是很强大的，不需要合并"))
            return
        end
        self.model.merge_type = 2 --请求列表进来
        self.model:InitGuildMergeUI()
    end)

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    GuildManager.Instance:request11106()
    GuildManager.Instance:request11100()

    -- self:update_guild_healthy()
end

--更新公会健康度
function GuildHealthyWindow:update_guild_healthy()
    self.TxtHealthyNum.text = string.format("%s<color='#2fc823'>%s</color>", TI18N("当前公会健康度："), self.model.my_guild_data.Health)
    if self.model.my_guild_data.Health > 50 then
        self.BtnCancel.image.sprite = self.img_grey
        self.BtnCreate.image.sprite = self.img_grey
    else
        self.BtnCancel.image.sprite = self.img_blue
        self.BtnCreate.image.sprite = self.img_blue
    end
end