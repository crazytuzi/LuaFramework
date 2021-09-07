GuildPositionWindow  =  GuildPositionWindow or BaseClass(BasePanel)

function GuildPositionWindow:__init(model)
    self.name  =  "GuildPositionWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_position_win, type  =  AssetType.Main}
    }
    self.effect  =  nil
    self.fps  =  nil
    self.timerId  =  0

    return self
end


function GuildPositionWindow:__delete()
    self.is_open  =  false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildPositionWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_position_win))
    self.gameObject.name  =  "GuildPositionWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon= self.gameObject.transform:FindChild("MainCon").gameObject
    local close_btn =  self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    close_btn.onClick:AddListener(function() self.model:ClosePositionUI() end)

    self.is_open = true

    self.TxtCreateCost= self.MainCon.transform:FindChild("TxtCreateCost"):GetComponent(Text)
    self.toggleGroup= self.MainCon.transform:FindChild("ToggleGroup").gameObject
    self.Toggle0 = self.toggleGroup.transform:FindChild("Toggle0"):GetComponent(Toggle)
    self.Toggle1 = self.toggleGroup.transform:FindChild("Toggle1"):GetComponent(Toggle)
    self.Toggle2 = self.toggleGroup.transform:FindChild("Toggle2"):GetComponent(Toggle)
    self.Toggle3 = self.toggleGroup.transform:FindChild("Toggle3"):GetComponent(Toggle)
    self.Toggle4 = self.toggleGroup.transform:FindChild("Toggle4"):GetComponent(Toggle)
    self.Toggle5 = self.toggleGroup.transform:FindChild("Toggle5"):GetComponent(Toggle)
    self.Toggle6 = self.toggleGroup.transform:FindChild("Toggle6"):GetComponent(Toggle)
    self.toTxt0 = self.Toggle0.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt1 = self.Toggle1.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt2 = self.Toggle2.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt3 = self.Toggle3.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt4 = self.Toggle4.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt5 = self.Toggle5.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt6 = self.Toggle6.transform:FindChild("Text"):GetComponent(Text)

    self.BtnCancel= self.MainCon.transform:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate= self.MainCon.transform:FindChild("BtnCreate"):GetComponent(Button)

    self.BtnCancel.onClick:AddListener(function() self:on_click_btn(1) end)
    self.BtnCreate.onClick:AddListener(function() self:on_click_btn(2) end)

    self:update_view()
end

function GuildPositionWindow:update_view()
    self.toTxt1.text = string.format("%s <color='#ffffff'>(%s/2)</color>",TI18N("副会长"), self.model:get_post_num(self.model.member_positions.vice_leader))
    self.toTxt2.text= string.format("%s <color='#ffffff'>(%s/4)</color>",TI18N("长老"), self.model:get_post_num(self.model.member_positions.elder))
    self.toTxt3.text= string.format("%s <color='#ffffff'>(%s/6)</color>",TI18N("兵长"), self.model:get_post_num(self.model.member_positions.sergeant))
    self.toTxt4.text= string.format("%s <color='#ffffff'>(%s/12)</color>",TI18N("精英"), self.model:get_post_num(self.model.member_positions.elite))
    self.toTxt6.text= string.format("%s <color='#ffffff'>(%s/6)</color>",TI18N("宝贝"), self.model:get_post_num(self.model.member_positions.baby))
    self.myData = self.model.select_mem_oper_data
    self.TxtCreateCost.text = string.format(TI18N("你需要把<color='#248813'>[%s]</color>任命以下哪个职位？"),self.myData.guildMemData.Name)
end


function GuildPositionWindow:on_click_btn(index)
    if 2 == index then
        local pos = -1
        if self.Toggle0.isOn then
            pos = self.model.member_positions.stduy
        elseif self.Toggle1.isOn then
            pos = self.model.member_positions.vice_leader
        elseif self.Toggle2.isOn then
            pos = self.model.member_positions.elder
        elseif self.Toggle3.isOn then
            pos = self.model.member_positions.sergeant
        elseif self.Toggle4.isOn then
            pos = self.model.member_positions.elite
        elseif self.Toggle5.isOn then
            pos = self.model.member_positions.mem
        elseif self.Toggle6.isOn then
            pos = self.model.member_positions.baby
        end
        if pos == -1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要设置的职位"))
            return
        end
        GuildManager.Instance:request11108(self.myData.guildMemData.Rid,self.myData.guildMemData.PlatForm,self.myData.guildMemData.ZoneId, pos)
    elseif 1 == index then
        self.model:ClosePositionUI()
    end
end
