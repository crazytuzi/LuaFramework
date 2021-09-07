-- ----------------------------------------------------------
-- UI - 宠物皮肤窗口
-- ----------------------------------------------------------
PetSkinWindow = PetSkinWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetSkinWindow:__init(model)
    self.model = model
    self.name = "PetSkinWindow"
    self.windowId = WindowConfig.WinID.pet_skin_window
    self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        { file = AssetConfig.pet_skin_window, type = AssetType.Main }
        ,{ file = AssetConfig.pet_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.rolebgnew, type = AssetType.Dep }
        ,{ file = AssetConfig.wingsbookbg, type = AssetType.Dep }
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.headLoaderList = {}
    self.headlist = { }
    self.petnum_max = 0

    self.attrTextList = { }
    self.onButtonType = 1
    self.skinIndex = 1
    -- 是否显示幻化界面
    self.isShowTrans = false

    self.actionIndexPlayAction = 1
    self.timeIdPlayAction = nil
    ------------------------------------------------
    self._OnUpdate = function()
        self:OnUpdate()
    end

    self._UpdateItem = function()
        self:UpdateItem()
    end

    self._onOkButtonClick = function()
        self:onOkButtonClick()
    end

    self._OnPricesBack = function(prices)
        self:OnPricesBack(prices)
    end
    ------------------------------------------------
    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

end

function PetSkinWindow:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.SkillSlot ~= nil then
        self.SkillSlot:DeleteMe()
        self.SkillSlot = nil
    end
    if self.timerTrans ~= nil then
        LuaTimer.Delete(self.timerTrans)
        self.timerTrans = nil;
    end
    self:OnHide()

    if self.timeIdPlayAction ~= nil then
        LuaTimer.Delete(self.timeIdPlayAction)
        self.timeIdPlayAction = nil
    end

    if self.timeIdPlayActionTrans ~= nil then
        LuaTimer.Delete(self.timeIdPlayActionTrans)
        self.timeIdPlayActionTrans = nil
    end

    if self.timeId_PlayIdleAction_Trans ~= nil then
        LuaTimer.Delete(self.timeId_PlayIdleAction_Trans)
        self.timeId_PlayIdleAction_Trans = nil
    end
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.previewCompositeTrans ~= nil then
        self.previewCompositeTrans:DeleteMe()
        self.previewCompositeTrans = nil
    end

    if self.buyButton ~= nil then
        self.buyButton:DeleteMe()
        self.buyButton = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetSkinWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_skin_window))
    self.gameObject.name = "PetSkinWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener( function() self:OnClickClose() end)

    self.transform:FindChild("Panel").gameObject:AddComponent(Button).onClick:AddListener( function() self:OnClickClose() end)

    self.mainTransform:Find("Info/ModelBg/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.mainTransform:Find("Info/ModelBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.mainTransform:Find("TransCon/ModelBg/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.mainTransform:Find("TransCon/ModelBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")


    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = { 0, 0, 0, 68 },
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting, { notAutoSelect = true })

    self.tabGroupObj2 = self.mainTransform:FindChild("TopTabButtonGroup").gameObject
    self.tabGroup2 = TabGroup.New(self.tabGroupObj2, function(index) self:ChangeTab2(index) end, { notAutoSelect = true, perWidth = 90, perHeight = 35})

    self.spirtButton = self.mainTransform:FindChild("TopTabButtonGroup/SpiritButton"):GetComponent(Button)

    self.headBar = self.mainTransform:FindChild("HeadBar")
    self.headBarRectTransform = self.headBar.transform:FindChild("HeadBar"):GetComponent(RectTransform)
    self.headBarContainer = self.headBar.transform:FindChild("HeadBar/mask/HeadContainer").gameObject
    self.headBarObject = self.headBarContainer.transform:FindChild("PetHead").gameObject

    self.toggle = self.mainTransform:FindChild("HeadBar/Toggle"):GetComponent(Toggle)
    self.toggle.onValueChanged:AddListener( function(on) self:OnToggleChange(on) end)

    self.headBarTabGroupObj = self.mainTransform:FindChild("HeadBar/TabButtonGroup").gameObject
    self.headBarTabGroup = TabGroup.New(self.headBarTabGroupObj, function(index) self:HeadBarChangeTab(index) end, { notAutoSelect = true })

    self.info = self.mainTransform:FindChild("Info")
    self.TransCon = self.mainTransform:Find("TransCon");
    self.TransCon.gameObject:SetActive(self.isShowTrans);
    self.info.gameObject:SetActive(not self.isShowTrans);

    self.noItemSlotObject = self.info:FindChild("NoItemSlot").gameObject
    self.itemSlotObject = self.info:FindChild("ItemSlot").gameObject
    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.itemSlotObject.transform:FindChild("Slot").gameObject, self.itemSlot.gameObject)

    self.itemName = self.itemSlotObject.transform:FindChild("ItemName"):GetComponent(Text)
    self.itemNumText = self.itemSlotObject.transform:FindChild("ItemNumText"):GetComponent(Text)
    self.itemNumText.gameObject:SetActive(false)
    self.quickBuyImage = self.itemSlotObject.transform:FindChild("ImgIcon").gameObject
    self.quickBuyText = self.itemSlotObject.transform:FindChild("TxtVal"):GetComponent(Text)

    self.titleText = self.info:FindChild("Title/NameText"):GetComponent(Text)
    self.titleImage = self.info:FindChild("Title/Image").gameObject

    self.TransCon:FindChild("Title/NameText"):GetComponent(Text).text = TI18N("宠物幻化");

    self.skinAttrObject = self.info:FindChild("SkinAttr").gameObject
    self.skinAttrRectTransform = self.skinAttrObject:GetComponent(RectTransform)
    for i = 1, 5 do
        table.insert(self.attrTextList, self.skinAttrObject.transform:FindChild("AttrText" .. i):GetComponent(Text))
    end

    self.skinTick = self.info:FindChild("SkinTick")
    self.select = self.info:FindChild("Select")

    self.tipsObject = self.info:FindChild("Tips").gameObject
    self.info:FindChild("Tips/Text"):GetComponent(Text).text = TI18N("暂无可更换皮肤，尽请期待")
    self.lineObject = self.info:FindChild("Line").gameObject

    local setting = {
        name = "PetView"
        ,
        orthographicSize = 0.8
        ,
        width = 400
        ,
        height = 400
        ,
        offsetY = - 0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, { })
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.transform)
    self.rawImage.gameObject:SetActive(false)
    self.modelPreview = self.info:FindChild("Preview")

    self.okButtonText = self.info:FindChild("OkButton/Text"):GetComponent(Text)

    self.BtnTrans = self.info:FindChild("BtnTrans"):GetComponent(Button)
    self.BtnSkin = self.TransCon:FindChild("BtnSkin"):GetComponent(Button)
    self.BtnTrans.onClick:AddListener(
    function()
        if RoleManager.Instance.RoleData.lev < 60 then
            NoticeManager.Instance:FloatTipsByString(TI18N("人物等级达60级开启功能"))
            return
        end
        self:UpdateCon();
    end );
    self.BtnSkin.onClick:AddListener(
    function()
        self:UpdateCon();
    end );


    self.modelPreviewTrans = self.TransCon:FindChild("Preview")
    self.previewCompositeTrans = PreviewComposite.New(nil, setting, { })
    self.previewCompositeTrans:BuildCamera(true)
    self.rawImageTrans = self.previewCompositeTrans.rawImage
    self.rawImageTrans.transform:SetParent(self.transform)
    self.rawImageTrans.gameObject:SetActive(false)


    self.TxtName = self.TransCon:Find("Title/NameText"):GetComponent(Text)
    self.SkillCon = self.TransCon:Find("DescPanel/SkillCon");
    self.TxtDesc = self.TransCon:Find("DescPanel/TxtDesc"):GetComponent(Text);
    self.BtnAdd = self.TransCon:Find("DescPanel/TxtDesc/BtnAdd"):GetComponent(Button);
    self.BtnAdd.onClick:AddListener( function()
        local petData = self.model.cur_petdata
        if petData ~= nil and DataPet.data_pet_trans_black[petData.base_id] == nil then
            self.model:OpenTransGemView()
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("参战等级＜%s不可幻化"), self.model.transLev))
        end
    end );

    self.TxtAttr = self.TransCon:Find("TxtAttr"):GetComponent(Text);
    self.TxtDescTitle = self.TransCon:Find("DescPanel/TxtTitle"):GetComponent(Text);

    self.SkillSlotCon = self.TransCon:Find("DescPanel/SkillCon/SlotCon");
    self.TxtSkillName = self.TransCon:Find("DescPanel/SkillCon/TxtSkillName"):GetComponent(Text);
    self.TxtSkillName.gameObject:SetActive(false)

    self.TxtSkillDesc = self.TransCon:Find("DescPanel/SkillCon/TxtSkillDesc"):GetComponent(Text);
    self.BtnDel = self.TransCon:Find("DescPanel/SkillCon/BtnDel"):GetComponent(Button);
    self.BtnDel.onClick:AddListener(
    function()
        self:OnTransDele()
    end )

    self.notShowTransToggle = self.TransCon:FindChild("NotShowTransToggle"):GetComponent(Toggle)
    self.notShowTransToggle.onValueChanged:AddListener(function(on) self:OnNotShowTransToggleChange(on) end)

    --------------------------------
    local btn = self.info:FindChild("StoryButton"):GetComponent(Button)
    btn.onClick:AddListener( function() self:onStoryButtonClick() end)
    self.storyButton = btn

    btn = self.info:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener( function() self:onOkButtonClick() end)
    self.okButton = btn

    btn = self.info:FindChild("CancelButtom"):GetComponent(Button)
    btn.onClick:AddListener( function() self:onCancelButtonClick() end)
    self.cancelButton = btn

    btn = self.info:FindChild("SkinButton1"):GetComponent(Button)
    btn.onClick:AddListener( function() self:OnSkinButtonClick(1) end)
    self.skinButton1 = btn

    btn = self.info:FindChild("SkinButton2"):GetComponent(Button)
    btn.onClick:AddListener( function() self:OnSkinButtonClick(2) end)
    self.skinButton2 = btn

    btn = self.info:FindChild("SkinButton3"):GetComponent(Button)
    btn.onClick:AddListener( function() self:OnSkinButtonClick(3) end)
    self.skinButton3 = btn

    btn = self.info:FindChild("Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener( function() self:PlayAction() end)

    btn = self.TransCon:FindChild("Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener( function() self:PlayTransAction() end)

    btn = self.info:FindChild("TipsButton"):GetComponent(Button)
    btn.onClick:AddListener( function()
        TipsManager.Instance:ShowText( {
            gameObject = self.info:FindChild("TipsButton").gameObject
            ,
            itemData = { TI18N("更换皮肤条件"), TI18N("1.携带<color='#00ff00'>等级≥65级</color>的<color='#ffff00'>变异</color>宠"), TI18N("2.宠物需要进阶到<color='#ffff00'>最高阶</color>"), TI18N("3.神兽、珍兽需要<color='#ffff00'>进阶2次</color>") }
        } )
    end )

    self.skinButton1RedPoint = self.skinButton1.transform:Find("RedPoint").gameObject
    self.skinButton2RedPoint = self.skinButton2.transform:Find("RedPoint").gameObject
    self.skinButton3RedPoint = self.skinButton3.transform:Find("RedPoint").gameObject
    self.skinButton1RedPoint:SetActive(false)

    self.buyButton = BuyButton.New(self.okButton.transform, TI18N("激 活"), false)
    self.buyButton.key = "PetSkinActivate"
    self.buyButton.protoId = 10557
    self.buyButton:Show()

    self.TxtDesc.text = string.format(TI18N("1、<color='#02FD05'>参战等级≥65级</color>的宠物可使用宠物幻化\n2、幻化的宠物将变身为新的外形，并附加<color='#ffff00'>额外属性</color>与<color='#ffff00'>额外技能</color>\n3、幻化可随时卸下与替换"));

    ----------------------------
    for k, v in pairs(DataPet.data_add_pet_nums) do
        if v.pet_nums > self.petnum_max then
            self.petnum_max = v.pet_nums
        end
    end
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetSkinWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
    -- self.model:ClosePetSkinWindow()
end

function PetSkinWindow:OnShow()
    local data = self.openArgs
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._UpdateItem)
    PetManager.Instance.OnUpdatePetList:Add(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Add(self._OnUpdate)

    if RoleManager.Instance.RoleData.lev >= 75 then
        self.toggle.isOn = self.model.headbarToggleOn
        self.headBarTabGroup:ChangeTab(self.model.headbarTabIndex)

        self.headBarTabGroupObj:SetActive(true)
        self.headBarRectTransform.sizeDelta = Vector2(246, 415)
    else
        self.model.headbarTabIndex = 1
        self.headBarTabGroupObj:SetActive(false)
        self.headBarRectTransform.sizeDelta = Vector2(246, 450)
    end
    self.BtnSkin.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= 60)
    self.BtnTrans.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= 60)
    self:Update()
    if RoleManager.Instance.RoleData.lev >= 60 then
        if data ~= nil and data[1] == "2" then
            self.isShowTrans = true
        else
            self.isShowTrans = false
        end
        self:UpdateCon();
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("60级开放宠物幻化功能"))
    end
end

function PetSkinWindow:OnHide()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateItem)
    PetManager.Instance.OnUpdatePetList:Remove(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Remove(self._OnUpdate)
    self.model:CloseTransGemView()
end

function PetSkinWindow:Update()
    self.selectIndex = 1
    for key, value in pairs(DataPet.data_pet_skin) do
        if self.model.cur_petdata.base.id == value.id and self.model.cur_petdata.use_skin == value.skin_id then
            self.selectIndex = value.skin_lev + 1
        end
    end

    if self.model.headbarTabIndex == 1 and RoleManager.Instance.RoleData.lev >= 75 then
        self:UpdateSpirtButtonEffect()
    end

    self.model:CheckTabOpen(self.tabGroup2)
    self.tabGroup2:Layout()
    self.tabGroup2:Select(4)

    self:UpdateHeadBar()
end

function PetSkinWindow:OnUpdate()
    self:Update()
end

function PetSkinWindow:UpdateHeadBar()
    -- local petlist = {}
    -- for i=1, #self.model.petlist do
    -- 	local petData = self.model.petlist[i]
    -- 	if self.model:GetCanChangeSkin(petData) then
    -- 		table.insert(petlist, petData)
    -- 	end
    -- end
    local petlist = self.model.petlist
    local headnum = self.model.pet_nums
    local headlist = self.headlist
    local headobject = self.headBarObject
    local container = self.headBarContainer
    local data

    -- if not self.toggle.isOn then
    if self.model.headbarTabIndex == 1 then
        petlist = self.model:GetMasterPetList()
    else
        petlist = self.model:GetAttachPetList()

        if #petlist == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有附灵宠物"))
            self.headBarTabGroup:ChangeTab(1)
            return
        end
    end

    if #self.model:GetAttachPetList() > 0 then
        self.headBarTabGroupObj:SetActive(true)
        self.headBarRectTransform.sizeDelta = Vector2(246, 415)
    else
        self.headBarTabGroupObj:SetActive(false)
        self.headBarRectTransform.sizeDelta = Vector2(246, 450)
    end

    local selectBtn = nil
    for i = 1, #petlist do
        data = petlist[i]
        local headitem = headlist[i]

        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[i] = item
            headitem = item
        end

        headitem.name = tostring(data.id)

        headitem.transform:FindChild("NameText"):GetComponent(Text).text = data.name
        headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format(TI18N("等级：%s"), data.lev)
        headitem.transform:FindChild("Using").gameObject:SetActive(data.status == 1)
        headitem.transform:FindChild("Attach").gameObject:SetActive(data.master_pet_id ~= 0)
        -- headitem.transform:FindChild("Possess").gameObject:SetActive(data.possess_pos > 0)
        local headId = tostring(data.base.head_id)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)

        local loaderId = headImage.gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
        -- headImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        -- headImage:SetNativeSize()
        headImage.rectTransform.sizeDelta = Vector2(54, 54)
        -- headImage.gameObject:SetActive(true)

        local headbg = self.model:get_petheadbg(data)
        headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
        = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener( function() self:onHeadItemClick(headitem) end)

        if self.model:GetCanChangeSkin(data) and self.model:EnoughItemToChangeSkin(data) then
            headitem.transform:FindChild("RedPointImage").gameObject:SetActive(true)
        else
            headitem.transform:FindChild("RedPointImage").gameObject:SetActive(false)
        end

        if #data.attach_pet_ids > 0 then
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(true)
            local attach_pet_id = data.attach_pet_ids[1]
            local attach_pet_data = self.model:getpet_byid(attach_pet_id)
            local headId = tostring(attach_pet_data.base.head_id)

             local loaderId = headitem.transform:FindChild("AttachHeadIcon/Image").gameObject:GetInstanceID()
            --
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(headitem.transform:FindChild("AttachHeadIcon/Image").gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)

            -- headitem.transform:FindChild("AttachHeadIcon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        else
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)
        end

        headitem:SetActive(true)

        if self.model.cur_petdata ~= nil and self.model.cur_petdata.id == data.id then selectBtn = headitem end
    end

    if not self.toggle.isOn then
        for i = #petlist + 1, self.model.pet_nums do
            local headitem = headlist[i]
            if headitem == nil then
                local item = GameObject.Instantiate(headobject)
                item:SetActive(true)
                item.transform:SetParent(container.transform)
                item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                headlist[i] = item
                headitem = item
            end

            headitem.name = "lock"

            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("Using").gameObject:SetActive(false)
            headitem.transform:FindChild("Attach").gameObject:SetActive(false)
            headitem.transform:FindChild("Possess").gameObject:SetActive(false)

            local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
            headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
            -- headImage:SetNativeSize()
            headImage.rectTransform.sizeDelta = Vector2(32, 36)
            -- headImage.gameObject:SetActive(true)

            headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
            = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")

            local button = headitem:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener( function() self:onHeadAddClick(headitem) end)

            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)

            if self.model.headbarTabIndex == 1 then
                headitem:SetActive(true)
            else
                headitem:SetActive(false)
            end
        end
    end

    if self.petnum_max > self.model.pet_nums then
        local headitem = headlist[self.model.pet_nums + 1]
        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[self.model.pet_nums + 1] = item
            headitem = item
        end
        headitem.name = "lock"

        headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
        headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
        headitem.transform:FindChild("Using").gameObject:SetActive(false)
        headitem.transform:FindChild("Attach").gameObject:SetActive(false)
        headitem.transform:FindChild("Possess").gameObject:SetActive(false)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
        headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Lock")
        -- headImage:SetNativeSize()
        headImage.rectTransform.sizeDelta = Vector2(36, 40)
        -- headImage.gameObject:SetActive(true)

        headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
        = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener( function() self:onHeadLockClick(headitem) end)

        headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)

        if self.model.headbarTabIndex == 1 then
            headitem:SetActive(true)
        else
            headitem:SetActive(false)
        end
    end

    if #petlist > 0 then
        if selectBtn == nil then
            self:onHeadItemClick(headlist[1])
        else
            self:onHeadItemClick(selectBtn)
        end
    end
end

function PetSkinWindow:UpdateBase()
    self.skinIndex = 1
    for key, value in pairs(DataPet.data_pet_skin) do
        if self.model.cur_petdata.base.id == value.id and self.model.cur_petdata.use_skin == value.skin_id then
            self.skinIndex = value.skin_lev + 1
        end
    end

    if self.skinIndex == 1 then
        local postition = self.skinButton1.transform.localPosition
        self.skinTick.transform.localPosition = Vector3(postition.x + 4, postition.y + 10, postition.z)
    elseif self.skinIndex == 2 then
        local postition = self.skinButton2.transform.localPosition
        self.skinTick.transform.localPosition = Vector3(postition.x + 3, postition.y + 10, postition.z)
    elseif self.skinIndex == 3 then
        local postition = self.skinButton3.transform.localPosition
        self.skinTick.transform.localPosition = Vector3(postition.x + 1, postition.y + 10, postition.z)
    end

    if self.selectIndex == 0 then
        self.selectIndex = self.skinIndex
    end
    if self.selectIndex == 1 then
        local postition = self.skinButton1.transform.localPosition
        self.select.transform.localPosition = Vector3(postition.x + 1, postition.y + 10, postition.z)
    elseif self.selectIndex == 2 then
        local postition = self.skinButton2.transform.localPosition
        self.select.transform.localPosition = Vector3(postition.x, postition.y + 10, postition.z)
    elseif self.selectIndex == 3 then
        local postition = self.skinButton3.transform.localPosition
        self.select.transform.localPosition = Vector3(postition.x, postition.y + 10, postition.z)
    end

    local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
    if data_pet_skin ~= nil and #data_pet_skin.story > 0 then
        self.storyButton.gameObject:SetActive(true)
    else
        self.storyButton.gameObject:SetActive(false)
    end

    if data_pet_skin ~= nil then
        local attrList = { }
        if data_pet_skin.phy_aptitude ~= 0 and data_pet_skin.pdef_aptitude ~= 0 and data_pet_skin.hp_aptitude ~= 0 and data_pet_skin.magic_aptitude ~= 0 and data_pet_skin.aspd_aptitude ~= 0 then
            table.insert(attrList, string.format(TI18N("全部资质<color='#00ff00'>+%s</color>"), data_pet_skin.phy_aptitude))
        else
            if data_pet_skin.phy_aptitude ~= 0 then
                table.insert(attrList, string.format(TI18N("物攻资质<color='#00ff00'>+%s</color>"), data_pet_skin.phy_aptitude))
            end
            if data_pet_skin.pdef_aptitude ~= 0 then
                table.insert(attrList, string.format(TI18N("物防资质<color='#00ff00'>+%s</color>"), data_pet_skin.pdef_aptitude))
            end
            if data_pet_skin.hp_aptitude ~= 0 then
                table.insert(attrList, string.format(TI18N("生命资质<color='#00ff00'>+%s</color>"), data_pet_skin.hp_aptitude))
            end
            if data_pet_skin.magic_aptitude ~= 0 then
                table.insert(attrList, string.format(TI18N("法力资质<color='#00ff00'>+%s</color>"), data_pet_skin.magic_aptitude))
            end
            if data_pet_skin.aspd_aptitude ~= 0 then
                table.insert(attrList, string.format(TI18N("速度资质<color='#00ff00'>+%s</color>"), data_pet_skin.aspd_aptitude))
            end
        end
        if data_pet_skin.growth ~= 0 then
            table.insert(attrList, string.format(TI18N("成长<color='#00ff00'>+%s</color>"), string.format("%.2f", data_pet_skin.growth / 500)))
        end
        if #attrList > 0 then
            self.skinAttrObject:SetActive(true)
            self.skinAttrRectTransform.sizeDelta = Vector2(130, 38 + #attrList * 25)
            for i = 1, #self.attrTextList do
                self.attrTextList[i].text = attrList[i]
            end
        else
            self.skinAttrObject:SetActive(false)
        end
    else
        self.skinAttrObject:SetActive(false)
    end

    if data_pet_skin ~= nil then
        if data_pet_skin.skin_name_res == 0 then
            self.titleText.text = string.format("<color='#fafa00'>%s</color>", data_pet_skin.skin_name)
            self.titleImage:SetActive(false)
        else
            self.titleText.text = ""
            self.titleImage:SetActive(true)
            self.titleImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("I18N_Genre%s", data_pet_skin.skin_name_res))
            self.titleImage:GetComponent(Image):SetNativeSize()
        end
    else
        -- self.titleText.text = string.format(TI18N("原装%s"), self.model.cur_petdata.base.name)
        self.titleText.text = self.model.cur_petdata.base.name
        self.titleImage:SetActive(false)
    end

    local hasSkinData = false
    -- for key, value in pairs(DataPet.data_pet_skin) do
    --     if self.model.cur_petdata.base.id == value.id then
    --         hasSkinData = true
    --     end
    -- end
    if DataPet.data_pet_skin[string.format("%s_1", self.model.cur_petdata.base.id)] ~= nil then
        hasSkinData = true
    end

    -- if self.model:GetCanChangeSkin(self.model.cur_petdata) then
    if hasSkinData then
        self.skinTick.gameObject:SetActive(true)
        self.select.gameObject:SetActive(true)
        self.skinButton1.gameObject:SetActive(true)
        self.skinButton2.gameObject:SetActive(true)
        self.skinButton3.gameObject:SetActive(true)
        self.okButton.gameObject:SetActive(true)
        self.cancelButton.gameObject:SetActive(true)
        self.tipsObject:SetActive(false)
        self.lineObject:SetActive(true)


        if self.selectIndex > 1 then
            -- local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex)]
            -- for i=1, #self.model.cur_petdata.has_skin do
            --     if self.model.cur_petdata.has_skin[i].skin_id == data_pet_skin.skin_id then
            --         enough = false
            --     end
            -- end

            if self.model:CheckSkinActive(self.selectIndex - 1, self.model.cur_petdata) then
                self.itemSlotObject:SetActive(false)
                self.noItemSlotObject:SetActive(true)
            else
                self.itemSlotObject:SetActive(true)
                self.noItemSlotObject:SetActive(false)
            end
        else
            self.itemSlotObject:SetActive(false)
            self.noItemSlotObject:SetActive(false)
        end

        if self.model:GetCanChangeSkin(self.model.cur_petdata) then
            local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, 1)]
            local enough = true
            for i = 1, #data_pet_skin.cost do
                if BackpackManager.Instance:GetItemCount(data_pet_skin.cost[i][1]) < data_pet_skin.cost[i][2] then
                    enough = false
                end
            end
            if enough then
                for i = 1, #self.model.cur_petdata.has_skin do
                    if self.model.cur_petdata.has_skin[i].skin_id == data_pet_skin.skin_id then
                        -- 如果已经激活了，就当作材料不足吧
                        enough = false
                    end
                end
            end
            self.skinButton2RedPoint:SetActive(enough)

            data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, 2)]
            enough = true
            for i = 1, #data_pet_skin.cost do
                if BackpackManager.Instance:GetItemCount(data_pet_skin.cost[i][1]) < data_pet_skin.cost[i][2] then
                    enough = false
                end
            end
            if enough then
                for i = 1, #self.model.cur_petdata.has_skin do
                    if self.model.cur_petdata.has_skin[i].skin_id == data_pet_skin.skin_id then
                        -- 如果已经激活了，就当作材料不足吧
                        enough = false
                    end
                end
            end
            self.skinButton3RedPoint:SetActive(enough)
        end
    else
        self.skinTick.gameObject:SetActive(false)
        self.select.gameObject:SetActive(false)
        self.skinButton1.gameObject:SetActive(false)
        self.skinButton2.gameObject:SetActive(false)
        self.skinButton3.gameObject:SetActive(false)
        self.okButton.gameObject:SetActive(false)
        self.cancelButton.gameObject:SetActive(false)
        self.tipsObject:SetActive(true)
        self.lineObject:SetActive(false)

        self.itemSlotObject:SetActive(false)
        self.noItemSlotObject:SetActive(false)
    end

    if self.skinIndex == self.selectIndex then
        self.okButtonText.text = TI18N("使用中")
        self.buyButton:Set_btn_txt(TI18N("使用中"))
        self.buyButton:SetActive(false)
        self.okButtonText.color = ColorHelper.DefaultButton2
        self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.onButtonType = 1
    elseif self.selectIndex == 1 or self.model:CheckSkinActive(self.selectIndex - 1, self.model.cur_petdata) then
        self.okButtonText.text = TI18N("使  用")
        self.buyButton:Set_btn_txt(TI18N("使  用"))
        self.buyButton:SetActive(false)
        self.okButtonText.color = ColorHelper.DefaultButton3
        self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.onButtonType = 2
    else
        self.okButtonText.text = TI18N("激  活")
        self.buyButton:Set_btn_txt(TI18N("激  活"))
        self.buyButton:SetActive(true)
        self.okButtonText.color = ColorHelper.DefaultButton3
        self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.onButtonType = 3
    end
end

function PetSkinWindow:UpdateModel()
    local petData = self.model.cur_petdata
    local petModelData = self.model:getPetModel(petData, true)
    local data = { type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects }
    local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
    if data_pet_skin ~= nil then
        data.modelId = data_pet_skin.model_id
        data.skinId = data_pet_skin.skin_id
        data.effects = data_pet_skin.effects
    end
    self.previewComposite:Reload(data, function(composite) self:PreviewLoaded(composite) end)
    self.modelData = data
end

function PetSkinWindow:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
end

function PetSkinWindow:UpdateItem()
    if self.onButtonType == 3 then
        local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
        if data_pet_skin ~= nil then
            local cost = data_pet_skin.cost[1]
            local base_data = BackpackManager.Instance:GetItemBase(cost[1])
            local cost_num = cost[2]
            local backpack_num = BackpackManager.Instance:GetItemCount(cost[1])
            local itemData = ItemData.New()
            itemData:SetBase(base_data)
            itemData.need = cost_num
            itemData.quantity = backpack_num
            self.itemSlot:SetAll(itemData)
            self.itemName.text = itemData.name
            -- local color = "#00ff00"
            -- if cost_num > backpack_num then
            -- 	color = "#ff0000"
            -- end
            -- self.itemNumText.text = string.format("<color='%s'>%s</color>/%s", color, backpack_num, cost_num)

            -- if data_pet_skin.skin_lev == 2 and data_pet_skin.quick_buy_gold ~= 0 and PrivilegeManager.Instance.charge >= data_pet_skin.quick_buy_gold then
            --     self.buyButton:Layout({[cost[1]] = {need = cost_num}}, self._onOkButtonClick, nil, { antofreeze = false})
            --     self.buyButton:SetActive(true)
            -- else
            --     self.buyButton:SetActive(false)
            -- end
            self.quickBuyImage:SetActive(false)
            self.quickBuyText.gameObject:SetActive(false)
            if data_pet_skin.can_quick_buy == 1 then
                self.buyButton:Layout( { [cost[1]] = { need = cost_num } }, self._onOkButtonClick, self._OnPricesBack, { antofreeze = false })
                self.buyButton:SetActive(true)
            else
                self.buyButton:SetActive(false)
            end
        end
    end
end

function PetSkinWindow:onHeadItemClick(item)
    self.model.cur_petdata = self.model:getpet_byid(tonumber(item.name))
    if self.model.cur_petdata.genre ==6 then
        --print("点击了小浣熊")
        NoticeManager.Instance:FloatTipsByString("精灵蛋没有皮肤界面")
    else
        self.selectIndex = 0
        self:UpdateBase()
        self:UpdateModel()
        self:UpdateItem()
        self:UpdateTrans()

        local head
        for i = 1, #self.headlist do
            head = self.headlist[i]
            head.transform:FindChild("Select").gameObject:SetActive(false)
        end
        item.transform:FindChild("Select").gameObject:SetActive(true)

        if self.model.headbarTabIndex == 1 and RoleManager.Instance.RoleData.lev >= 75 then
            self:UpdateSpirtButtonEffect()
        end
    end
end

function PetSkinWindow:onHeadAddClick()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你是否要前往宠物图鉴查看可携带宠物？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() self.model:OpenPetWindow( { 3 }) end
    NoticeManager.Instance:ConfirmTips(data)
end

function PetSkinWindow:onHeadLockClick(item)
    local itembase = BackpackManager.Instance:GetItemBase(DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_id)

    local str = string.format(TI18N("是否消耗%s%s开启宠物栏？")
    , DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_val
    , ColorHelper.color_item_name(itembase.quality, itembase.name))

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() PetManager.Instance:Send10523() end
    NoticeManager.Instance:ConfirmTips(data)
end

function PetSkinWindow:OnSkinButtonClick(index)
    self.selectIndex = index

    self:UpdateBase()
    self:UpdateModel()
    self:UpdateItem()
    self:UpdateTrans()
end

function PetSkinWindow:onStoryButtonClick()
    local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
    if data_pet_skin ~= nil then
        local storyTips = { }
        for i = 1, #data_pet_skin.story do
            table.insert(storyTips, data_pet_skin.story[i].line)
        end
        TipsManager.Instance:ShowText( { gameObject = self.storyButton.gameObject, itemData = storyTips })
    end
end

function PetSkinWindow:onOkButtonClick()
    if self.onButtonType == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("该皮肤已经在使用中"))
    elseif self.onButtonType == 2 then
        local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
        if data_pet_skin == nil then
            PetManager.Instance:Send10558(self.model.cur_petdata.id, 0)
        else
            PetManager.Instance:Send10558(self.model.cur_petdata.id, data_pet_skin.skin_id)
        end
    elseif self.onButtonType == 3 then
        local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
        if data_pet_skin == nil then
            PetManager.Instance:Send10558(self.model.cur_petdata.id, 0)
        else
            local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
            if data_pet_skin ~= nil then
                local cost = data_pet_skin.cost[1]
                local cost_num = cost[2]
                local backpack_num = BackpackManager.Instance:GetItemCount(cost[1])
                if cost_num <= backpack_num then
                    PetManager.Instance:Send10557(self.model.cur_petdata.id, data_pet_skin.skin_id)
                elseif data_pet_skin.can_quick_buy == 1 then
                    -- if data_pet_skin.quick_buy_gold ~= 0 then
                    --     if PrivilegeManager.Instance.charge >= data_pet_skin.quick_buy_gold then
                    --         local confirmData = NoticeConfirmData.New()
                    --         confirmData.type = ConfirmData.Style.Normal
                    --         confirmData.content = string.format(TI18N("确定要消耗{assets_1, 90002, %s}激活<color='#ffff00'>%s</color>吗？"), self.buyButton.money, data_pet_skin.skin_name)
                    --         confirmData.sureLabel = TI18N("确定")
                    --         confirmData.cancelLabel = TI18N("取消")
                    --         confirmData.sureCallback = function()
                    --                 -- self.BtnWashBuyBtn:Freeze()
                    --                 PetManager.Instance:Send10557(self.model.cur_petdata.id, data_pet_skin.skin_id)
                    --             end
                    --         NoticeManager.Instance:ConfirmTips(confirmData)
                    --     else
                    --         NoticeManager.Instance:FloatTipsByString(string.format(TI18N("道具不足，可在通过<color='#00ff00'>王者积分兑换</color>获得（累计充值<color='#00ff00'>%s钻</color>后可开启便捷激活）"), data_pet_skin.quick_buy_gold))
                    --     end
                    -- else
                    --     NoticeManager.Instance:FloatTipsByString(TI18N("道具不足，无法激活"))
                    -- end

                    if data_pet_skin.quick_buy_gold ~= 0 then
                        if PrivilegeManager.Instance.charge <= data_pet_skin.quick_buy_gold then
                            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("道具不足，可在通过<color='#00ff00'>王者积分兑换</color>获得（累计充值<color='#00ff00'>%s钻</color>后可开启便捷激活）"), data_pet_skin.quick_buy_gold))
                            return
                        end
                    end

                    if data_pet_skin.quick_buy_tips == 1 then
                        local confirmData = NoticeConfirmData.New()
                        confirmData.type = ConfirmData.Style.Normal
                        confirmData.content = string.format(TI18N("确定要消耗{assets_1, 90002, %s}激活<color='#ffff00'>%s</color>吗？"), self.buyButton.money, data_pet_skin.skin_name)
                        confirmData.sureLabel = TI18N("确定")
                        confirmData.cancelLabel = TI18N("取消")
                        confirmData.sureCallback = function()
                            -- self.BtnWashBuyBtn:Freeze()
                            PetManager.Instance:Send10557(self.model.cur_petdata.id, data_pet_skin.skin_id)
                        end
                        NoticeManager.Instance:ConfirmTips(confirmData)
                    else
                        PetManager.Instance:Send10557(self.model.cur_petdata.id, data_pet_skin.skin_id)
                    end
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("道具不足，无法激活"))
                end
            end
        end
    end
end

function PetSkinWindow:onCancelButtonClick()
    self:OnSkinButtonClick(self.skinIndex)
end

function PetSkinWindow:PlayAction()
    if self.timeIdPlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil and self.modelData ~= nil then
        local animationData = DataAnimation.data_npc_data[self.modelData.animationId]
        local actionList = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
        self.actionIndexPlayAction = self.actionIndexPlayAction + math.random(1, 2)
        if self.actionIndexPlayAction > #actionList then self.actionIndexPlayAction = self.actionIndexPlayAction - #actionList end
        local actionName = actionList[self.actionIndexPlayAction]
        self.previewComposite:PlayAnimation(actionName)

        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", actionName, self.modelData.modelId)]
        if motion_event ~= nil then
            if actionName == "1000" then
                self.timeIdPlayAction = LuaTimer.Add(motion_event.total, function()
                    self.timeIdPlayAction = nil
                    if not BaseUtils.isnull(self.previewComposite.tpose) then
                        self.previewComposite:PlayMotion(FighterAction.Stand)
                    end
                end )
            elseif actionName == "2000" then
                self.timeIdPlayAction = LuaTimer.Add(motion_event.total, function()
                    self.timeIdPlayAction = nil
                    if not BaseUtils.isnull(self.previewComposite.tpose) then
                        self.previewComposite:PlayMotion(FighterAction.Stand)
                    end
                end )
            else
                self.timeIdPlayAction = LuaTimer.Add(motion_event.total, function() self.timeIdPlayAction = nil end)
            end
        end
    end
end

function PetSkinWindow:PlayTransAction()
    if self.timeIdPlayActionTrans == nil and self.previewCompositeTrans ~= nil and self.previewCompositeTrans.tpose ~= nil and self.modelDataTrans ~= nil then
        local animationData = DataAnimation.data_npc_data[self.modelDataTrans.animationId]
        local actionList = { "1000", "2000", string.format("Idle%s", animationData.idle_id) }
        self.actionIndexPlayAction = self.actionIndexPlayAction + math.random(1, 2)
        if self.actionIndexPlayAction > #actionList then self.actionIndexPlayAction = self.actionIndexPlayAction - #actionList end
        local actionName = actionList[self.actionIndexPlayAction]
        self.previewCompositeTrans:PlayAnimation(actionName)

        local motion_event = DataMotionEvent.data_motion_event[string.format("%s_%s", actionName, self.modelData.modelId)]
        if motion_event ~= nil then
            if actionName == "1000" then
                self.timeIdPlayActionTrans = LuaTimer.Add(motion_event.total, function()
                    self.timeIdPlayActionTrans = nil
                    if not BaseUtils.isnull(self.previewCompositeTrans.tpose) then
                        self.previewCompositeTrans:PlayMotion(FighterAction.Stand)
                    end
                end )
            elseif actionName == "2000" then
                self.timeIdPlayActionTrans = LuaTimer.Add(motion_event.total, function()
                    self.timeIdPlayActionTrans = nil
                    if not BaseUtils.isnull(self.previewCompositeTrans.tpose) then
                        self.previewCompositeTrans:PlayMotion(FighterAction.Stand)
                    end
                end )
            else
                self.timeIdPlayActionTrans = LuaTimer.Add(motion_event.total, function() self.timeIdPlayActionTrans = nil end)
            end
        end
    end
end



function PetSkinWindow:PlayIdleAction()
    if self.timeIdPlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil then
        self.previewComposite:PlayMotion(FighterAction.Idle)
    end
end

function PetSkinWindow:TransPlayIdleAction()
    if self.timeIdPlayActionTrans == nil and self.previewCompositeTrans ~= nil and self.previewCompositeTrans.tpose ~= nil then
        self.previewCompositeTrans:PlayMotion(FighterAction.Idle)
    end
end

function PetSkinWindow:ChangeTab(index)
    if index ~= 1 then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, { index })
    end
end

function PetSkinWindow:ChangeTab2(index)
    if index == 4 then return end   --不允许点自己
    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, { 1, index })
end

function PetSkinWindow:OpenGetPetWindow()
    local args = { }
    local petData = self.model.cur_petdata
    local petModelData = self.model:getPetModel(petData, true)
    local data = { type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects }
    local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
    if data_pet_skin ~= nil then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)

        args.petId = self.model.cur_petdata.base.id
        args.grade = self.model.cur_petdata.grade
        args.genre = self.model.cur_petdata.genre
        args.use_skin = data_pet_skin.skin_id
        self.model:OpenGetPetWindow(args)
    end
end

function PetSkinWindow:OnToggleChange(on)
    self.model.headbarToggleOn = on
    self:UpdateHeadBar()
end

function PetSkinWindow:HeadBarChangeTab(index)
    self.model.headbarTabIndex = index
    self:UpdateHeadBar()
end

function PetSkinWindow:UpdateSpirtButtonEffect()
    local data = self.model.cur_petdata
    if data ~= nil then
        if #data.attach_pet_ids == 0 then
            -- if self.spirtButtonEffect == nil then
            --     local fun = function(effectView)
            --         local effectObject = effectView.gameObject

            --         effectObject.transform:SetParent(self.spirtButton.transform)
            --         effectObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
            --         effectObject.transform.localPosition = Vector3(63, 15, -400)
            --         effectObject.transform.localRotation = Quaternion.identity

            --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --     end
            --     self.spirtButtonEffect = BaseEffectView.New({effectId = 20122, time = nil, callback = fun})
            -- else
            --     self.spirtButtonEffect:SetActive(true)
            -- end
            self.spirtButton.transform:Find("Arrow").gameObject:SetActive(true)
        elseif self.spirtButtonEffect ~= nil then
            -- self.spirtButtonEffect:SetActive(false)
        else
            self.spirtButton.transform:Find("Arrow").gameObject:SetActive(false)
        end
    elseif self.spirtButtonEffect ~= nil then
        -- self.spirtButtonEffect:SetActive(false)
        self.spirtButton.transform:Find("Arrow").gameObject:SetActive(false)
    end
end

function PetSkinWindow:OnPricesBack(prices)
    BaseUtils.dump(prices, "prices")

    local data = nil
    for key, value in pairs(prices) do
        data = value
    end
    if data == nil then
        return
    end

    local allprice = data.allprice
    local price_str = ""
    if allprice >= 0 then
        price_str = string.format("<color='%s'>%s</color>", "#ffffff", allprice)
    else
        price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], - allprice)
    end
    self.quickBuyText.text = price_str
    self.quickBuyImage:GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[data.assets])

    self.quickBuyImage:SetActive(true)
    self.quickBuyText.gameObject:SetActive(true)
end

function PetSkinWindow:UpdateCon()
    self.info.gameObject:SetActive(not self.isShowTrans);
    self.TransCon.gameObject:SetActive(self.isShowTrans);
    self:UpdateTrans()
    self.isShowTrans = not self.isShowTrans;
end

function PetSkinWindow:UpdateTrans()
    self.itemID = nil;
    local isOpen = false;
    local petData = self.model.cur_petdata
    if petData ~= nil then
        local transList = petData.unreal;
        if transList ~= nil and #transList > 0 and  DataPet.data_pet_trans_black[petData.base_id] == nil  then
            isOpen = true
        end
        if isOpen then
            local taransData = transList[1];
            self.itemID = taransData.item_id
            self.endTime = taransData.timeout
            local transTmp = DataPet.data_pet_trans[self.itemID];
            if self.timerTrans ~= nil then
                LuaTimer.Delete(self.timerTrans)
            end
            if self.endTime > BaseUtils.BASE_TIME then
                self.timerTrans = LuaTimer.Add(0, 1000,
                function()
                    self:ShowTransAttr()
                end )
            end
            self.TxtDescTitle.text = TI18N("幻化技能");
            if self.SkillSlot == nil then
                self.SkillSlot = SkillSlot.New()
                UIUtils.AddUIChild(self.SkillSlotCon, self.SkillSlot.gameObject)
            end
            local skillData = DataSkill.data_petSkill[string.format("%s_1", transTmp.skills[1][1])];
            local extra = { }
            extra.petId = petData.child_id
            self.SkillSlot.gameObject.name = skillData.id
            self.SkillSlot:SetAll(Skilltype.petskill, skillData, extra)
            self.TxtSkillDesc.text = string.format(TI18N("%s: \n%s"), skillData.name, skillData.desc)
        else
            self.TxtDescTitle.text = TI18N("幻化介绍");
        end
        self.TxtAttr.gameObject:SetActive(isOpen)
        self.TxtDesc.gameObject:SetActive(not isOpen)
        self.SkillCon.gameObject:SetActive(isOpen)
        self.notShowTransToggle.isOn = (petData.unreal_looks_flag == 1)
    end
    self:UpdateTransModel();
end

function PetSkinWindow:OnTransDele()
    if self.itemID ~= nil then
        PetManager.Instance:Send10565(self.model.cur_petdata.id, self.itemID)
    end
end


function PetSkinWindow:UpdateTransModel()
    local petData = self.model.cur_petdata
    local petModelData = self.model:getPetModel(petData, true)

    local data = { type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = petData.base.animation_id, scale = petData.base.scale / 100, effects = petModelData.effects }
    local tmp = DataPet.data_pet_trans[self.itemID];

    if tmp ~= nil and petData.unreal_looks_flag == 0 then
        local transFTmp = DataTransform.data_transform[tmp.skin_id];
        if transFTmp ~= nil then
            data.modelId = transFTmp.res
            data.skinId = transFTmp.skin
            data.animationId = transFTmp.animation_id
            data.effects = transFTmp.effects
            data.scale = transFTmp.scale / 100
        end
    end
    self.modelDataTrans = data
    self.previewCompositeTrans:Reload(data, function(composite) self:PreviewLoadedTrans(composite) end)
end

function PetSkinWindow:PreviewLoadedTrans(composite)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreviewTrans)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))

    if self.timeId_PlayIdleAction_Trans ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction_Trans) end
    self.timeId_PlayIdleAction_Trans = LuaTimer.Add(0, 15000, function() self:TransPlayIdleAction() end)
end

function PetSkinWindow:ShowTransAttr()
    local transTmp = DataPet.data_pet_trans[self.itemID];
    if transTmp ~= nil then
        local attr = transTmp.attr
        local attrText = ""
        if attr ~= nil and #attr > 0 then
            for i, v in ipairs(attr) do
                if v.attr_name ~= nil and v.val ~= nil then
                    attrText = string.format("%s %s", attrText, KvData.GetAttrString(v.attr_name, v.val))
                end
            end
        end
        local offTime = self.endTime - BaseUtils.BASE_TIME;
        if offTime > 0 then
            local dayStr, hourStr, minStr, secStr = BaseUtils.time_gap_to_timer(self.endTime - BaseUtils.BASE_TIME);
            local timeStr = ""
            if dayStr > 0 then
                timeStr = string.format("<color='#00ffff'>%s%s%s%s%s%s</color>", dayStr, TI18N("天"), hourStr, TI18N("小时"), minStr, TI18N("分钟"))
            else
                timeStr = string.format("<color='#00ffff'>%s%s%s%s%s%s</color>", hourStr, TI18N("小时"), minStr, TI18N("分钟"), secStr, TI18N("秒"))
            end
            attrText = attrText .. string.format(TI18N("\n剩余时间：\n%s"), timeStr);
            self.TxtAttr.text = attrText;
        else
            self:UpdateTrans();
        end
    end
end

function PetSkinWindow:OnNotShowTransToggleChange(on)
    local petData = self.model.cur_petdata
    if petData ~= nil then
        if on and petData.unreal_looks_flag == 0 then
            -- NoticeManager.Instance:FloatTipsByString(dat.msg)
            PetManager.Instance:Send10574(petData.id, 1)
        elseif not on and petData.unreal_looks_flag == 1 then
            -- NoticeManager.Instance:FloatTipsByString(dat.msg)
            PetManager.Instance:Send10574(petData.id, 0)
        end
    end
end
