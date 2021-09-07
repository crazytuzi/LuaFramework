GuildApplyMsgWindow  =  GuildApplyMsgWindow or BaseClass(BasePanel)

function GuildApplyMsgWindow:__init(model)
    self.name  =  "GuildApplyMsgWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_apply_msg_panel, type  =  AssetType.Main}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
    }

    self.is_open = false
    return self
end


function GuildApplyMsgWindow:__delete()
    self.is_open = false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end
    self:AssetClearAll()
end


function GuildApplyMsgWindow:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_apply_msg_panel))
    self.gameObject.name  =  "GuildApplyMsgWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseApplyMsgWindow() end)


    self.MainCon = self.transform:FindChild("MainCon")

    self.MainCon:FindChild("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseApplyMsgWindow() end)

    self.TopCon = self.MainCon:FindChild("TopCon")
    self.TopTxt = self.MainCon:Find("TopCon/Text"):GetComponent(Text)
    self.TopTxt.text = string.format(TI18N("正在申请加入<color='#ffff00'>%s</color>，向大家介绍一下自己吧！"), self.openArgs.Name)
    self.Btn1 = self.TopCon:FindChild("Btn1"):GetComponent(Button)
    self.Btn2 = self.TopCon:FindChild("Btn2"):GetComponent(Button)
    self.Btn3 = self.TopCon:FindChild("Btn3"):GetComponent(Button)

    self.Btn1Selected = self.TopCon:Find("Btn1/ImgSelected").gameObject
    self.Btn2Selected = self.TopCon:Find("Btn2/ImgSelected").gameObject
    self.Btn3Selected = self.TopCon:Find("Btn3/ImgSelected").gameObject
    self.InputField = self.TopCon:FindChild("InputField"):GetComponent(InputField)
    self.InputField.textComponent  =  self.InputField.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.InputField.placeholder  =  self.InputField.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)

    local str = PlayerPrefs.GetString("guildApplyMsg")
    if str ~= "" then
        self.InputField.text = str
    end
    self.BottomCon = self.MainCon:FindChild("BottomCon")
    self.BtnCancel = self.BottomCon:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnApply = self.BottomCon:FindChild("BtnApply"):GetComponent(Button)

    self.BtnCancel.onClick:AddListener(function()
        self.model:CloseApplyMsgWindow()
    end)

    self.BtnApply.onClick:AddListener(function()
        if self.model:check_has_join_guild() then
             NoticeManager.Instance:FloatTipsByString(TI18N("你当前已有公会"))
            return
        end
        local msg = self.InputField.text

        if msg == "" then
            local index = Random.Range(1,  2)
            if index == 1 then
                msg = TI18N("玩转星辰很轻松，带你躺赢带你飞")
            else
                msg = TI18N("调节气氛我在行，公会活跃少不了")
            end
        end
        PlayerPrefs.SetString("guildApplyMsg", msg)
        GuildManager.Instance:request11104(self.openArgs.GuildId,self.openArgs.PlatForm,self.openArgs.ZoneId, self.type, msg)
    end)

    self.InputField.onEndEdit:AddListener(function()
        local now = self.InputField.text
        if now ~= TI18N("玩转星辰很轻松，带你躺赢带你飞") or now ~= TI18N("调节气氛我在行，公会活跃少不了") or now ~= TI18N("撒娇卖萌古灵精，唱歌跳舞样样行") then
            self.type = 1
        end
    end)

    self.type = 2
    self.InputField.text = TI18N("玩转星辰很轻松，带你躺赢带你飞")
    self.Btn1Selected:SetActive(true)
    self.Btn2Selected:SetActive(false)
    self.Btn3Selected:SetActive(false)

    self.Btn1.onClick:AddListener(function()
        self.type = 2
        self.InputField.text = TI18N("玩转星辰很轻松，带你躺赢带你飞")
        self.Btn1Selected:SetActive(true)
        self.Btn2Selected:SetActive(false)
        self.Btn3Selected:SetActive(false)
    end)
    self.Btn2.onClick:AddListener(function()
        self.type = 3
        self.InputField.text = TI18N("调节气氛我在行，公会活跃少不了")
        self.Btn1Selected:SetActive(false)
        self.Btn2Selected:SetActive(true)
        self.Btn3Selected:SetActive(false)
    end)
    self.Btn3.onClick:AddListener(function()
        self.type = 4
        self.InputField.text = TI18N("撒娇卖萌古灵精，唱歌跳舞样样行")
        self.Btn1Selected:SetActive(false)
        self.Btn2Selected:SetActive(false)
        self.Btn3Selected:SetActive(true)
    end)
end