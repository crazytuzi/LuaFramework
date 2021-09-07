GuildChangePurposeWindow  =  GuildChangePurposeWindow or BaseClass(BaseWindow)

function GuildChangePurposeWindow:__init(model)
    self.name  =  "GuildChangePurposeWindow"
    self.model  =  model
    self.gameObject = nil

    self.resList  =  {
        {file  =  AssetConfig.guild_change_purpose_win, type  =  AssetType.Main}
    }
    self.effect  =  nil
    self.fps  =  nil
    self.timerId  =  0
    self.max_word_num = 50
    return self
end


function GuildChangePurposeWindow:__delete()
    self.is_open  =  false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildChangePurposeWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_change_purpose_win))
    self.gameObject.name  =  "GuildChangePurposeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.is_open = true

    self.MainCon = self.gameObject.transform:FindChild("MainCon")

    self.title_txt = self.MainCon:FindChild("TitleCon"):FindChild("TxtTitle"):GetComponent(Text)

    local CloseBtn =  self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:ClosePurposeUI()   end)

    self.GuildPurpose= self.MainCon:FindChild("GuildPurpose").gameObject
    self.PurposeInput=self.GuildPurpose.transform:FindChild("PurposeInput"):GetComponent(InputField)
    self.PurposeInput.textComponent = self.PurposeInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.PurposeInput.placeholder = self.PurposeInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.PurposeInput.characterLimit = self.max_word_num

    self.PurposeInput.onValueChange:AddListener(function(str)
        local word_list = StringHelper.ConvertStringTable(str)
        local word_num = #word_list
        local left_num = self.max_word_num - word_num
        if str ~= "" and #word_list == 0 then
            left_num = self.max_word_num - 1
        elseif str == "" then
            left_num = self.max_word_num
        end
        left_num = left_num < 0 and 0 or left_num

        if left_num == 0 then
            self.TxtNum.text = string.format(TI18N("当前还可输入：<color='%s'>%s</color>字"), ColorHelper.color[6], left_num)
        else
            self.TxtNum.text = string.format(TI18N("当前还可输入：<color='%s'>%s</color>字"), ColorHelper.color[5], left_num)
        end
    end)

    self.TxtNum = self.MainCon:FindChild("TxtNum"):GetComponent(Text)
    self.BtnCreate= self.MainCon:FindChild("BtnCreate"):GetComponent(Button)

    self.BtnCreate.onClick:AddListener(function() self:on_click_btn(2) end)


    if self.model.board_announcement_type == 1 then
        self.PurposeInput.text = self.model.my_guild_data.Board
        self.title_txt.text = TI18N("公会宗旨")
        local num = StringHelper.ConvertStringTable(self.model.my_guild_data.Board)
        local left_num = self.max_word_num - #num
        self.TxtNum.text = string.format(TI18N("当前还可输入：<color='#ffff00'>%s</color>字"), left_num)
    else
        self.PurposeInput.text = self.model.my_guild_data.Announcement
        self.title_txt.text = TI18N("公会公告")
        local num = StringHelper.ConvertStringTable(self.model.my_guild_data.Announcement)
        local left_num = self.max_word_num - #num
        self.TxtNum.text = string.format(TI18N("当前还可输入：<color='#ffff00'>%s</color>字"), left_num)
    end

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end


function GuildChangePurposeWindow:on_click_btn(index)
    if index == 2 then
        GuildManager.Instance:request11114(self.PurposeInput.text, self.model.board_announcement_type)
    elseif index == 1 then
        self.model:ClosePurposeUI()
    end
end
