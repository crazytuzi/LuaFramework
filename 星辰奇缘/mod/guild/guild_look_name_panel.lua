GuildLookNamePanel  =  GuildLookNamePanel or BaseClass(BasePanel)

function GuildLookNamePanel:__init(model)
    self.name  =  "GuildLookNamePanel"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_look_name_win, type  =  AssetType.Main}
    }

    return self
end


function GuildLookNamePanel:__delete()

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildLookNamePanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_look_name_win))
    self.gameObject.name  =  "GuildLookNamePanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseChangeNameLookUI() end)

    self.MainCon = self.transform:FindChild("MainCon")

    local CloseBtn =  self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseChangeNameLookUI()   end)

    self.TxtLeader = self.MainCon:FindChild("TxtLeader"):GetComponent(Text)
    self.TxtGuild = self.MainCon:FindChild("TxtGuild"):GetComponent(Text)
    self.BtnChange = self.MainCon:FindChild("BtnChange"):GetComponent(Button)


    self.TxtLeader.text = string.format("%s", self.model.my_guild_data.LeaderName)
    if self.model.my_guild_data.Name_used ~= nil and self.model.my_guild_data.Name_used ~= "" then
        self.TxtGuild.text = string.format("%s", self.model.my_guild_data.Name_used)
    else
        self.TxtGuild.text = string.format("%s", TI18N("无"))
    end

    self.BtnChange.onClick:AddListener(function()
        if GuildManager.Instance.model:get_my_guild_post() < GuildManager.Instance.model.member_positions.leader then
            NoticeManager.Instance:FloatTipsByString(TI18N("会长才能够更改公会名称"))
            return
        end
        self.model:CloseChangeNameLookUI()
        self.model:InitChangeNameUI()
    end)
end
