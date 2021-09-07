ApprenticeSignUpWindow  =  ApprenticeSignUpWindow or BaseClass(BaseWindow)

function ApprenticeSignUpWindow:__init(model)
    self.name  =  "ApprenticeSignUpWindow"
    self.model  =  model

    self.windowId = WindowConfig.WinID.apprenticesignupwindow

    self.resList  =  {
        {file  =  AssetConfig.apprenticesignupwindow, type  =  AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.font, type = AssetType.Dep}
    }
    
    self.max_word = 20

    return self
end


function ApprenticeSignUpWindow:__delete()
    self.is_open  =  false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function ApprenticeSignUpWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.apprenticesignupwindow))
    self.gameObject.name  =  "ApprenticeSignUpWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.main_con = self.gameObject.transform:FindChild("MainCon").gameObject
    
    self.guild_purpose = self.main_con.transform:FindChild("GuildPurpose").gameObject
    self.purpose_input = self.guild_purpose.transform:FindChild("InputCon"):FindChild("PurposeInput"):GetComponent(InputField)
    self.purpose_input.textComponent  =  self.purpose_input.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.purpose_input.placeholder  =  self.purpose_input.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    -- self.name_input.characterLimit  =  5
    self.purpose_input.characterLimit  =  20

    self.purpose_input.onValueChange:AddListener(function(str)
        local word_list = StringHelper.ConvertStringTable(str)
        local word_num = #word_list
        local left_num = self.max_word - word_num - 1
        if str ~= "" and #word_list == 0 then
            left_num = self.max_word - 1
        elseif str == "" then
            left_num = self.max_word
        end
        left_num = left_num < 0 and 0 or left_num
        if left_num == 0 then
            self.text.text = string.format("%s<color='%s'>%s</color>%s", TI18N("当前还可输入："), ColorHelper.colorObject[4], left_num, TI18N("字"))
        else
            self.text.text = string.format("%s<color='%s'>%s</color>%s", TI18N("当前还可输入："), ColorHelper.colorObject[4], left_num, TI18N("字"))
        end
    end)

    self.text = self.main_con.transform:FindChild("Text"):GetComponent(Text)
    self.okButton = self.main_con.transform:FindChild("OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnOkButtonClick() end)

    self.is_open  =  true

    self.purpose_input.text = TI18N("徒弟弟快到碗里来~")

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end

function ApprenticeSignUpWindow:OnOkButtonClick(btn)
    local purp = self.purpose_input.text
    if purp == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先填写"))
        return
    end
    TeacherManager.Instance:send15814(purp)
    WindowManager.Instance:CloseWindow(self)
end