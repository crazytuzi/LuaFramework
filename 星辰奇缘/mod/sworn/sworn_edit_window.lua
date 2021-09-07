-- @author 黄耀聪
-- @date 2016年11月5日

SwornEditWindow = SwornEditWindow or BaseClass(BaseWindow)

function SwornEditWindow:__init(model)
    self.model = model
    self.name = "SwornEditWindow"
    self.windowId = WindowConfig.WinID.sworn_modify_window

    self.resList = {
        {file = AssetConfig.sworn_modify_window, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
    }

    self.price = {"coin", 100000}
    self.updateListener = function() self:Reload(self.type) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornEditWindow:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornEditWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_modify_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    self.titleText = main:Find("Title/Text"):GetComponent(Text)

    self.customInputField = main:Find("Up/Custom"):GetComponent(InputField)
    self.swornInputField = main:Find("Up/Sworn"):GetComponent(InputField)
    self.singleInputField = main:Find("Up/Single"):GetComponent(InputField)
    self.customBtn = main:Find("Up/CustomBtn"):GetComponent(Button)
    self.swornBtn = main:Find("Up/SwornBtn"):GetComponent(Button)
    self.customText = main:Find("Up/CustomBtn/Text"):GetComponent(Text)
    self.swornText = main:Find("Up/SwornBtn/Text"):GetComponent(Text)
    self.numText = main:Find("Up/Text"):GetComponent(Text)
    self.numText1 = main:Find("Up/Text1"):GetComponent(Text)
    self.dotObj = main:Find("Up/Dot_I18N").gameObject

    self.ownImage = main:Find("Down/Own/Image"):GetComponent(Image)
    self.priceImage = main:Find("Down/Price/Image"):GetComponent(Image)
    self.ownText = main:Find("Down/Own/Text"):GetComponent(Text)
    self.priceText = main:Find("Down/Price/Text"):GetComponent(Text)

    self.cancelBtn = main:Find("Down/Cancel"):GetComponent(Button)
    self.modifyBtn = main:Find("Down/Modify"):GetComponent(Button)

    self.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[KvData.assets[self.price[1]]])

    self.cancelBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function SwornEditWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornEditWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateListener)

    self.type = self.openArgs[1]
    self:Reload(self.type)
end

function SwornEditWindow:OnHide()
    self:RemoveListeners()
end

function SwornEditWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateListener)
end

function SwornEditWindow:Reload(type)
    local model = self.model
    self.ownText.text = RoleManager.Instance.RoleData[self.price[1]]
    self.modifyBtn.onClick:RemoveAllListeners()
    self.titleText.text = TI18N("修改称号")
    if type == 1 then           -- 修改结拜称号
        self.ownText.text = RoleManager.Instance.RoleData.gold
        self.ownImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[KvData.assets["gold"]])
        self.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[KvData.assets["gold"]])
        self.singleInputField.gameObject:SetActive(true)
        self.swornInputField.gameObject:SetActive(true)
        self.numText.gameObject:SetActive(true)
        self.numText1.gameObject:SetActive(false)
        self.numText.text = model.numList[#model.swornData.members]
        self.customInputField.gameObject:SetActive(false)
        self.customBtn.gameObject:SetActive(false)
        self.swornBtn.gameObject:SetActive(false)
        self.customText.text = model.swornData.members[model.myPos].name_defined
        self.modifyBtn.onClick:AddListener(function() self:OnEditSworn() end)
        self.dotObj:SetActive(false)

        local tab = StringHelper.ConvertStringTable(model.swornData.name)
        self.singleInputField.text = tab[#tab]
        local tab1 = {}
        for i=1,#tab - 2 do
            table.insert(tab1, tab[i])
        end
        self.swornInputField.text = tostring(table.concat(tab1))

        local times = model.swornData.times
        if times > 4 then times = 4 end
        self.priceText.text = DataSworn.data_rename_loss[times + 1].prefix
    elseif type == 2 then       -- 修改自己称号
        self.ownText.text = RoleManager.Instance.RoleData.coin
        self.ownImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[KvData.assets["coin"]])
        self.priceImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[KvData.assets["coin"]])
        self.singleInputField.gameObject:SetActive(false)
        self.swornInputField.gameObject:SetActive(false)
        self.numText.gameObject:SetActive(false)
        self.numText1.gameObject:SetActive(true)
        self.numText1.text = model.rankList[model.myPos]
        self.customInputField.gameObject:SetActive(true)
        self.customBtn.gameObject:SetActive(false)
        self.swornBtn.gameObject:SetActive(true)
        self.swornText.text = model.swornData.name
        self.modifyBtn.onClick:AddListener(function() self:OnEditCustom() end)
        self.dotObj.transform.anchoredPosition = Vector2(24, -4)
        self.dotObj:SetActive(true)

        self.customInputField.text = model.swornData.members[model.myPos].name_defined

        local times = model.swornData.members[model.myPos].times
        if times > 4 then times = 4 end
        self.priceText.text = DataSworn.data_rename_loss[times + 1].personal
    end
end

function SwornEditWindow:OnEditCustom()
    if self.customInputField.text ~= "" then
        -- local confirmData = NoticeConfirmData.New()
        -- confirmData.content = string.format(TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2, %s}修改自定义称号？"), tostring(self.price[2]), tostring(KvData.assets[self.price[1]]))
        -- confirmData.sureCallback = function() SwornManager.Instance:send17707(self.customInputField.text) end
        -- NoticeManager.Instance:ConfirmTips(confirmData)
        SwornManager.Instance:send17707(self.customInputField.text)
        WindowManager.Instance:CloseWindow(self)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入自定义称号"))
    end
end

function SwornEditWindow:OnEditSworn()
    if self.swornInputField.text ~= "" and self.singleInputField.text ~= "" then
        -- local confirmData = NoticeConfirmData.New()
        -- confirmData.content = string.format(TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2, %s}修改前缀称号？（需投票）"), tostring(self.price[2]), tostring(KvData.assets[self.price[1]]))
        -- confirmData.sureCallback = function() SwornManager.Instance:send17705(self.swornInputField.text, self.singleInputField.text) end
        -- NoticeManager.Instance:ConfirmTips(confirmData)
        SwornManager.Instance:send17705(self.swornInputField.text, self.singleInputField.text)
        WindowManager.Instance:CloseWindow(self)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入前缀称号"))
    end
end

