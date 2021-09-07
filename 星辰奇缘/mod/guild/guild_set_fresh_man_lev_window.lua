GuildSetFreshManLevWindow  =  GuildSetFreshManLevWindow or BaseClass(BasePanel)

function GuildSetFreshManLevWindow:__init(model)
    self.name  =  "GuildSetFreshManLevWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_set_fresh_man_lev_win, type  =  AssetType.Main}
    }


    return self
end


function GuildSetFreshManLevWindow:__delete()
    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildSetFreshManLevWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_set_fresh_man_lev_win))
    self.gameObject.name  =  "GuildSetFreshManLevWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseSetFreshManLevUI() end)

    self.MainCon = self.transform:FindChild("MainCon")

    local close_btn =  self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:CloseSetFreshManLevUI() end)

    self.TxtCreateCost = self.MainCon:FindChild("TxtCreateCost"):GetComponent(Text)

    self.TxtCreateCost.text = string.format("%s<color='#ffff00'>%s%s</color>", TI18N("当前公会新秀自动转为正式成员需要达到"), self.model.unfresh_man_lev, TI18N("级"))

    self.InputCon = self.MainCon.transform:FindChild("InputCon")
    self.NameInput = self.InputCon.transform:FindChild("NameInput"):GetComponent(InputField)
    self.NameInput.textComponent  =  self.NameInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.NameInput.placeholder  =  self.NameInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)

    self.BtnCancel = self.MainCon.transform:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.MainCon.transform:FindChild("BtnCreate"):GetComponent(Button)


    self.NameInput.text = tostring(self.model.unfresh_man_lev)

    self.BtnCancel.onClick:AddListener(function()
        self.model:CloseSetFreshManLevUI()
    end)
    self.BtnCreate.onClick:AddListener(function()
        local new_lev = tonumber(self.NameInput.text)
        if new_lev < 35 then
            NoticeManager.Instance:FloatTipsByString(TI18N("新秀转为正式成员最低不可小于35级"))
            return
        else
            --发送设置
            GuildManager.Instance:request11186(new_lev)
        end
    end)
end

function GuildSetFreshManLevWindow:update_info()
    self.TxtCreateCost.text = string.format("%s<color='#ffff00'>%s%s</color>", TI18N("当前公会新秀自动转为正式成员需要达到"), self.model.unfresh_man_lev, TI18N("级"))
end