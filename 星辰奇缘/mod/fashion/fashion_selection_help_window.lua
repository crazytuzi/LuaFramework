FashionSelectionHelpWindow  =  FashionSelectionHelpWindow or BaseClass(BaseWindow)

function FashionSelectionHelpWindow:__init(model)
    self.name  =  "FashionSelectionHelpWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.fashion_help_window
    -- 缓存
    self.resList  =  {
        {file = AssetConfig.fashion_help_window, type = AssetType.Main}
        ,{file = AssetConfig.fashion_selection_show_big1, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_show_big2, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_help_big1, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_help_big2, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_help_big3, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_help_big4, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_selection_texture, type = AssetType.Dep}
    }
    self.roleListener = function() self:ReSetButton() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FashionSelectionHelpWindow:OnHide()
    self:RemoveAllListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function FashionSelectionHelpWindow:__delete()
    self:RemoveAllListeners()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end


function FashionSelectionHelpWindow:AddAllListeners()
    FashionSelectionManager.Instance.onUpdateRoleHelpData:AddListener(self.roleListener)
end

function FashionSelectionHelpWindow:RemoveAllListeners()
    FashionSelectionManager.Instance.onUpdateRoleHelpData:RemoveListener(self.roleListener)
end

function FashionSelectionHelpWindow:ReSetButton()
    if FashionSelectionManager.Instance.haseSurport == 2 then
        self.selectionHelpBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.selectionHelpBtnText.color = ColorHelper.DefaultButton4
        self.selectionHelpBtnText.text = "感谢支持"
    else
        self.selectionHelpBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.selectionHelpBtnText.color = ColorHelper.DefaultButton3
        self.selectionHelpBtnText.text = "帮Ta投票"
    end
    self.selectionHelpBtn.gameObject:SetActive(true)
end
function FashionSelectionHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_help_window))
    self.gameObject.name = "FashionHelpnWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

     self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
     self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

     self.previewParent = self.transform:Find("MainCon/FashionItem/FashionPreview")

     self.transform:Find("MainCon/FashionItem"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big1, "FashionSelectionTop")
     self.transform:Find("MainCon/FashionItem/BottomBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big2, "FashionSelectionBottom")
     self.transform:Find("MainCon/FashionItem").gameObject:SetActive(true)
     self.transform:Find("MainCon/FashionItem/TitleBg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"TitleBg2")

     self.transform:Find("MainCon/ZhuangShiBg/Bg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_help_big1, "FashionLookBg1")
 self.transform:Find("MainCon/ZhuangShiBg/Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_help_big2, "FashionLookBg2")
     self.transform:Find("MainCon/ZhuangShiBg/Bg3"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_help_big3, "FashionLookBg3")
     self.transform:Find("MainCon/ZhuangShiBg").gameObject:SetActive(true)

     self.transform:Find("MainCon/CircleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_help_big4, "FashionLookBg4")
     self.transform:Find("MainCon/CircleBg").gameObject:SetActive(true)

     self.fashionTitle = self.transform:Find("MainCon/FashionItem/TitleBg/Text"):GetComponent(Text)
     self.selectionHelpBtn = self.transform:Find("MainCon/FashionItem/SelectionBtn"):GetComponent(Button)
     self.selectionHelpBtnText = self.transform:Find("MainCon/FashionItem/SelectionBtn/Text"):GetComponent(Text)
     self.selectionHelpBtn.onClick:AddListener(function() self:ApplyHelp() end)
     self.selectionHelpBtn.gameObject:SetActive(false)
    self:OnShow()
end

function FashionSelectionHelpWindow:OnShow()
    self:RemoveAllListeners()
    self:AddAllListeners()
    if self.previewComp ~= nil then
        self.previewComp:Show()
    end



    if self.openArgs ~= nil then
        local sendData = {group_id = self.openArgs[1],f_id = self.openArgs[6],f_platform = self.openArgs[7],f_zone_id = self.openArgs[8]}
                        FashionSelectionManager.Instance:send20415(sendData)
        self:RefreshPreviewComp()
    end

end

function FashionSelectionHelpWindow:RefreshPreviewComp()
    if tonumber(self.openArgs[3]) == tonumber(RoleManager.Instance.RoleData.sex) then
        self.myFashionData = self.model.fashionList[self.openArgs[1]]
    else
        self.myFashionData = self.model.otherFashionList[self.openArgs[1]]
    end

    self.fashionTitle.text = DataFashion.data_suit[self.myFashionData.set_id].name

    local data_list = {}
    for k,v in pairs(self.myFashionData.fashion) do
        local myData = DataFashion.data_base[v.value]
        table.insert(data_list, myData)
    end


    self.kvLooks = {}

    for k,v in pairs(data_list) do
        self.kvLooks[v.type] = {looks_str = "", looks_val = v.model_id, looks_mode = v.texture_id, looks_type = v.type}
    end
    if self.openArgs[4] ~= nil and self.openArgs[5] ~= nil then
        self.kvLooks[SceneConstData.looktype_weapon] = {looks_str = "", looks_val = self.openArgs[5], looks_mode = self.openArgs[4], looks_type = SceneConstData.looktype_weapon}
    end

     local modelData = {type = PreViewType.Role, classes = tonumber(self.openArgs[2]), sex = self.openArgs[3], looks = self.kvLooks}
    if self.previewComp == nil then
            local setting = {
                name = "previewComp"
                ,layer = "UI"
                ,parent = self.previewParent.transform
                ,localRot = Vector3(0, 0, 0)
                ,localPos = Vector3(0, -102, -150)
                ,localScale = Vector3(280,280,280)
                ,usemask = false
                ,sortingOrder = 21
            }
            self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
    else
            self.previewComp:Reload(modelData, callback)
    end

end


function FashionSelectionHelpWindow:ApplyHelp()
    if self.openArgs ~= nil then
        self.lastSelectFirendData = {id = self.openArgs[6],platform = self.openArgs[7],zone_id = self.openArgs[8],name =self.openArgs[9],sex = self.openArgs[3],lev = self.openArgs[10],classes = self.openArgs[2]}
        FashionSelectionManager.Instance.lastSelectFirendData = self.lastSelectFirendData
        local sendData = {group_id = self.openArgs[1],f_id = self.openArgs[6],f_platform = self.openArgs[7],f_zone_id = self.openArgs[8],invite_code = 1}
        FashionSelectionManager.Instance:send20413(sendData)
    end
end
