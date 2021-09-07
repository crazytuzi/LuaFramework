GuildPrayConfirmWindow  =  GuildPrayConfirmWindow or BaseClass(BasePanel)

function GuildPrayConfirmWindow:__init(model)
    self.name  =  "GuildPrayConfirmWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_pray_confirm_panel, type  =  AssetType.Main}
    }

    self.is_open  =  false
    return self
end


function GuildPrayConfirmWindow:__delete()
    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildPrayConfirmWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_pray_confirm_panel))
    self.gameObject.name  =  "GuildPrayConfirmWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:ClosePrayConfirmWindow() end)
    self.MainCon = self.transform:FindChild("MainCon")
    local CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseButton.onClick:AddListener(function() self.model:ClosePrayConfirmWindow() end)
    self.BtnCancel = self.MainCon:FindChild("BtnCancel"):GetComponent(Button)
    self.BtnCreate = self.MainCon:FindChild("BtnCreate"):GetComponent(Button)

    self.ItemList = {}
    for i = 1, 7 do
        local item = self.MainCon:FindChild(tostring(i))
        item.gameObject:SetActive(false)
        table.insert(self.ItemList, item)
    end

    self.BtnCancel.onClick:AddListener(function()
        self.model:ClosePrayConfirmWindow()
    end)
    self.BtnCreate.onClick:AddListener(function()
        local tempLev = 0 --当前
        if self.data ~= nil then
            for i = 1, #self.data.element_info do
                local temp = self.data.element_info[i]
                tempLev = tempLev + temp.lev
            end
        end
        local myLev = 0
        for i = 1, #self.model.my_guild_data.element_info do
            myLev = myLev + self.model.my_guild_data.element_info[i].lev
        end
        if myLev >= tempLev then
            --本公会最高
            NoticeManager.Instance:FloatTipsByString(TI18N("本公会祭坛等级已是本服最高，无需极限祈福{face_1,3}"))
        else
            self.model:OnSwitchPrayToggle()
        end
        self.model:ClosePrayConfirmWindow()
    end)
    GuildManager.Instance:request11194()
end

--更新面板
function GuildPrayConfirmWindow:UpdateInfo(data)
    self.data = data
    local index = 1
    for i = 1, #data.element_info do
        local temp = data.element_info[i]
        local cfgData = nil
        for k, v in pairs(DataGuild.data_guild_element) do
            if v.element_type == temp.build_type then
                cfgData = v
                break
            end
        end
        if cfgData ~= nil then
            local item = self.ItemList[index]
            item.gameObject:SetActive(true)
            self:SetItemData(item, temp, cfgData)
            index = index + 1
        end
    end
end

--设置item数据
function GuildPrayConfirmWindow:SetItemData(item, data, cfgData)
    item:FindChild("Text"):GetComponent(Text).text = cfgData.element_name
    item:FindChild("TxtLev"):GetComponent(Text).text = tostring(data.lev)
end