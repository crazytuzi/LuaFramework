GuildChangeSignatrueWindow  =  GuildChangeSignatrueWindow or BaseClass(BaseWindow)

function GuildChangeSignatrueWindow:__init(model)
    self.name  =  "GuildChangeSignatrueWindow"
    self.model  =  model
    self.gameObject = nil

    self.resList  =  {
        {file  =  AssetConfig.guild_change_signature_win, type  =  AssetType.Main}
    }
    self.effect  =  nil
    self.fps  =  nil
    self.timerId  =  0

    return self
end


function GuildChangeSignatrueWindow:__delete()
    self.is_open  =  false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildChangeSignatrueWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_change_signature_win))
    self.gameObject.name  =  "GuildChangeSignatrueWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.is_open = true

    self.MainCon = self.gameObject.transform:FindChild("MainCon").gameObject

    local CloseBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseChangeSignatureUI()  end)


    self.GuildPurpose = self.MainCon.transform:FindChild("GuildPurpose").gameObject
    self.PurposeInput = self.GuildPurpose.transform:FindChild("PurposeInput"):GetComponent(InputField)
    self.PurposeInput.textComponent = self.PurposeInput.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.PurposeInput.placeholder = self.PurposeInput.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.PurposeInput.characterLimit = 5
    self.BtnCancel = self.MainCon.transform:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.MainCon.transform:FindChild("BtnCreate"):GetComponent(Button)
    self.TxtLeftNum = self.MainCon.transform:FindChild("TxtLeftNum"):GetComponent(Text)

    self.BtnCancel.onClick:AddListener(function() self:on_click_btn(1) end)
    self.BtnCreate.onClick:AddListener(function() self:on_click_btn(2) end)

    local gbData = self.model:get_guild_gb_data(self.model.my_guild_data.Lev)
    local max_time = gbData.signable
    local left_time = 0
    if self.model.change_signature_data.last_signed == 0 then
        left_time = max_time
    else

        -- local cur_time_stamp = math.floor(ctx.TimerManager:CreateCurTimeStamp())
        -- local last_time_stamp = self.model.change_signature_data.last_signed
        -- local div = cur_time_stamp - last_time_stamp

        -- if div >= 604800 then
        --     left_time = max_time
        -- else
        --     local cur_week = ctx.TimerManager:GetCurrentDayOfWeek(tostring(cur_time_stamp))
        --     local last_week = ctx.TimerManager:GetCurrentDayOfWeek(tostring(last_time_stamp))
        --     if cur_week >= last_week then
        --         left_time = max_time - self.model.change_signature_data.signed
        --     else
        --         left_time = max_time
        --     end
        -- end
    end

    -- self.TxtLeftNum.text = string.format("%s<color='#4CB749'>%s</color>%s",TI18N("本周还可设置"), left_time,  TI18N("次"))


    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
end


function GuildChangeSignatrueWindow:on_click_btn(index)
    if index == 2 then
        GuildManager.Instance:request11125(self.model.change_signature_data.Rid,self.model.change_signature_data.PlatForm,self.model.change_signature_data.ZoneId,self.PurposeInput.text)
    elseif index == 1 then
        self.model:CloseChangeSignatureUI()
    end
end