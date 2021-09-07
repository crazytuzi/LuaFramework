GuildChangeNamePanel  =  GuildChangeNamePanel or BaseClass(BasePanel)

function GuildChangeNamePanel:__init(model)
    self.name  =  "GuildChangeNamePanel"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_change_name_win, type  =  AssetType.Main}
    }

    return self
end


function GuildChangeNamePanel:__delete()

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildChangeNamePanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_change_name_win))
    self.gameObject.name  =  "GuildChangeNamePanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseChangeNameUI() end)

    self.MainCon = self.transform:FindChild("MainCon")

    local CloseBtn =  self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseChangeNameUI()   end)

    self.GuildPurpose = self.MainCon:FindChild("GuildPurpose")
    self.purpose_input = self.GuildPurpose:FindChild("PurposeInput"):GetComponent(InputField)
    self.purpose_input.textComponent  =  self.purpose_input.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.purpose_input.placeholder  =  self.purpose_input.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.purpose_input.characterLimit  =  5


    self.TxtCurrentName = self.MainCon:FindChild("TxtCurrentName"):GetComponent(Text)
    self.BtnChange = self.MainCon:FindChild("BtnChange"):GetComponent(Button)
    self.TxtLost = self.MainCon:FindChild("TxtLost"):GetComponent(Text)
    self.TxtHas = self.MainCon:FindChild("TxtHas"):GetComponent(Text)


    self.TxtCurrentName.text = string.format("%s%s", TI18N("公会现用名："), self.model.my_guild_data.Name)


    local cost = 1680

    self.BtnChange.onClick:AddListener(function()
        if self.purpose_input.text == "" then
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入公会名称"))
            return
        end
        if self.purpose_input.text == TI18N("请输入公会名称") then
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入有效公会名称"))
            return
        end

        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
             GuildManager.Instance:request11187(self.purpose_input.text)
        end
        confirmData.content = string.format("%s<color='#2fc823'>%s</color>{assets_2,90002}%s<color='#2fc823'>%s</color>%s", TI18N("你将花费"), cost, TI18N("把公会改名为"), self.purpose_input.text,TI18N("是否确定？"))
        NoticeManager.Instance:ConfirmTips(confirmData)


    end)


    local color = "#df3435"
    if RoleManager.Instance.RoleData.gold >= cost then
        color = "#2fc823"
    end
    self.TxtHas.text = tostring(RoleManager.Instance.RoleData.gold)
    self.TxtLost.text = string.format("<color='%s'>%s</color>", color,cost)
end