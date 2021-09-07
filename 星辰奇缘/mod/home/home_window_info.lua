-- ----------------------------------------------------------
-- UI - 家园建筑使用
-- ljh 160714
-- ----------------------------------------------------------
HomeWindow_Info = HomeWindow_Info or BaseClass(BasePanel)

function HomeWindow_Info:__init(parent)
    self.parent = parent
    self.model = parent.model
    self.name = "HomeWindow_Info"
    self.resList = {
        {file = AssetConfig.home_view_info, type = AssetType.Main}
        ,{file = AssetConfig.homeTexture, type = AssetType.Dep}
        ,{file = AssetConfig.homebigTexture, type = AssetType.Dep}
        -- ,{file = AssetConfig.base_textures, type = AssetType.Dep}
        ,{file = AssetConfig.skill_life_icon, type = AssetType.Dep}
        ,{file  = AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        ,{file  = AssetConfig.rolebgnew, type  =  AssetType.Dep}
        ,{file  = AssetConfig.info_textures, type  =  AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.childTab = {}
    self.headLoaderList = {}

    self.tabGroupObj = nil
    self.currentIndex = 1

    self.previewComposite = nil
    self.model_data = {}
    self.model_preview = nil

    self.init_bedroom = false
    self.init_petroom = false
    self.init_productionroom = false

    -- self.container = nil
    -- self.scrollrect = nil
    self.petItem_list = {}
    self.petData = nil -- 当前选中的宠物
    self.select_pet_item = nil

    self.init_productionroom = false
    self.productionroom_skillitem_list = {}

    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self._update_red = function() self:update_red() end

    self._updateBuildList = function()
        self:updateBuildList()
    end

    self._update_energy = function()
        self:update_energy()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HomeWindow_Info:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
end

function HomeWindow_Info:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.home_view_info))
    self.gameObject.name = "HomeWindow_Info"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform

    self.tabGroupObj = self.transform:FindChild("TabButtonGroup")

    local tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 0, 0, 0},
        perWidth = 185,
        perHeight = 60,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index)
        self:ChangeTab(index)
    end, tabGroupSetting)

    self.childTab = { }
    for i=1, 3 do
        table.insert(self.childTab, transform:FindChild("Panel"..i).gameObject)
    end
    self.childTab[4] = transform:FindChild("Panel1").gameObject
    self.panel2_desctext2 = MsgItemExt.New(self.transform:FindChild("Panel2/DescText2"):GetComponent(Text), 340, 18, 23)

    local setting = {
        name = "HomeWindowView"
        ,orthographicSize = 0.7
        ,width = 230
        ,height = 240
        ,offsetY = -0.4
    }

    self.previewComposite = PreviewComposite.New(nil, setting, {})
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.transform)
    self.rawImage.transform.localPosition = Vector3(0, -2000, 0)
    self.rawImage.transform.localScale = Vector3(1, 1, 1)

    self.okBtnQuickText = self.childTab[2].transform:FindChild("OkButton/HuoliTextI18N"):GetComponent(Text)
    self.okBtnQuickTxt = MsgItemExt.New(self.okBtnQuickText, 200, 22, 22)

    self.childTab[1]:SetActive(false)
    self.childTab[2]:SetActive(false)
    self.childTab[3]:SetActive(false)
    self.childTab[4]:SetActive(false)
    -- self.container = transform:FindChild("BuildListPanel/Content").gameObject
    -- self.itemobject = self.container.transform:FindChild("Item").gameObject

    -- -- 按钮功能绑定
    -- local btn
    -- btn = transform:FindChild("OkButton"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:okbuttonclick() end)

    -- btn = transform:FindChild("CancelButton"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:cancelbuttonclick() end)

    self.transform:Find("Panel1/BigBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homebigTexture, "1")
    self.transform:Find("Panel3/BigBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homebigTexture, "3")
    self.transform:Find("Panel2/bg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

    self.panel3_energy_slider = self.transform:Find("Panel3/Energy/Slider"):GetComponent(Slider)
    self.panel3_energy_slider_text = self.transform:Find("Panel3/Energy/Slider/Text"):GetComponent(Text)

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function HomeWindow_Info:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:SetActive(false)
        end
        self.currentIndex = tonumber(self.openArgs[2])
    end

    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(self.currentIndex)
    self.tabGroup.noCheckRepeat = false

    self:update_red()

    self:addevents()
    if self.previewComposite ~= nil then
        self.previewComposite:Show()
    end
end

function HomeWindow_Info:OnHide()
    self:removeevents()
    if self.previewComposite ~= nil then
        self.previewComposite:Hide()
    end

    if self.pet_timerId ~= nil then
       LuaTimer.Delete(self.pet_timerId)
       self.pet_timerId = nil
    end

    self.init_productionroom = false
end

function HomeWindow_Info:addevents()
    EventMgr.Instance:AddListener(event_name.home_build_update, self._update)
    EventMgr.Instance:AddListener(event_name.home_train_info_update, self._update)
    EventMgr.Instance:AddListener(event_name.home_use_info_update, self._update)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._update_energy)

    EventMgr.Instance:AddListener(event_name.home_use_info_update, self._update_red)
    EventMgr.Instance:AddListener(event_name.home_train_info_update, self._update_red)
    EventMgr.Instance:AddListener(event_name.active_point_update, self._update_red)
end

function HomeWindow_Info:removeevents()
    EventMgr.Instance:RemoveListener(event_name.home_build_update, self._update)
    EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self._update)
    EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self._update)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._update_energy)

    EventMgr.Instance:RemoveListener(event_name.home_use_info_update, self._update_red)
    EventMgr.Instance:RemoveListener(event_name.home_train_info_update, self._update_red)
    EventMgr.Instance:RemoveListener(event_name.active_point_update, self._update_red)
end

function HomeWindow_Info:ChangeTab(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:SetActive(false)
        end
        self.currentIndex = index
    end
    self.childTab[self.currentIndex]:SetActive(true)
    self:update()
end

function HomeWindow_Info:update()
    if self.currentIndex == 1 then
        self:update_bedroom()
    elseif self.currentIndex == 2 then
        self:update_petroom()
        self:update_petlist()
    elseif self.currentIndex == 3 then
        self:update_productionroom()
    elseif self.currentIndex == 4 then
        self:update_storeroom()
    end
end

function HomeWindow_Info:load_preview(model_preview, data)
    if not BaseUtils.sametab(data, self.model_data) then
        self.model_data = data

        self.model_preview = model_preview
        local model_data = BaseUtils.copytab(self.model_data)
        self.previewComposite:Reload(model_data, function(composite) self:preview_loaded(composite) end)
    else
        self.model_preview = model_preview
        local rawImage = self.previewComposite.rawImage
        rawImage.transform:SetParent(self.model_preview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        local animationData = DataAnimation.data_npc_data[self.model_data.animationId]
        if self.previewComposite.tpose ~= nil then
            self.previewComposite.tpose:GetComponent(Animator):Play(string.format("Move%s", animationData.move_id))
        end
    end
end

function HomeWindow_Info:preview_loaded(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.model_preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    if self.model_data.isRotate then
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    if self.model_data.isMove then
        local animationData = DataAnimation.data_npc_data[self.model_data.animationId]
        composite.tpose:GetComponent(Animator):Play(string.format("Move%s", animationData.move_id))
    end
end

---------------------------------- Mark 卧室
function HomeWindow_Info:update_bedroom()
    local transform = self.childTab[1].transform
    local build = self.model:getbuild(1)
    if build == nil then return end
    local builddata = self.model:getbuilddata(1, build.lev)
    if builddata == nil then return end

    transform:FindChild("NameText"):GetComponent(Text).text = builddata.name
    transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s<color='#00ff00'>%s%s</color>，%s", TI18N("今天还可以休息"), self.model:geteffecttypevalue(12) - self.model:getbuildeffecttypevalue(55), TI18N("次"), TI18N("休息可恢复<color='#00ff00'>一定活力</color>与<color='#00ff00'>饱食度</color>"))

    local showdescdata = builddata -- 要显示的说明数据
    self.childTab[2].transform:FindChild("OkButton/Text").gameObject:SetActive(true)
    self.childTab[2].transform:FindChild("OkButton/HuoliTextI18N").gameObject:SetActive(false)
    if build.lev == 0 then  -- 如果当前等级为0，则显示1级的数据
        showdescdata = self.model:getbuilddata(1, 1)
        self.childTab[2].transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("前往建造")
    else
        self.childTab[2].transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("休 息")
    end
    -- transform:FindChild("DescText1"):GetComponent(Text).text = string.format("1.占用空间<color='#ffff9a'>%s㎡</color>", showdescdata.use_space)
    -- transform:FindChild("DescText2"):GetComponent(Text).text = string.format("每天可以休息<color='#ffff9a'>%s</color>次，每次可获得<color='#ffff9a'>%s</color>点活力和<color='#ffff9a'>%s</color>点饱食度"
    --             , self.model:getbuilddataeffecttype(1, showdescdata.lev, 12)
    --             , self.model:getbuilddataeffecttype(1, showdescdata.lev, 7)
    --             , self.model:getbuilddataeffecttype(1, showdescdata.lev, 8))
    transform:FindChild("DescText2"):GetComponent(Text).text = ""

    local icon = transform:FindChild("Icon")
    BaseUtils.SetGrey(icon:GetComponent(Image), builddata.icon_grey == 1)
    local btn = icon:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = icon.gameObject, itemData = {builddata.icon_desc} }) end)

    btn = transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
            if build.lev > 0 then
                HomeManager.Instance:Send11215()
                AgendaManager.Instance:Require12004()
            else
                self:ask_build(TI18N("卧室"), 1)
            end
        end)
    -- local preview = transform:FindChild("Preview")
    -- local unit_data = DataUnit.data_unit[20075]
    -- local data = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1.5, isRotate = false}
    -- self:load_preview(preview, data)
end

---------------------------------- Mark 宠物
function HomeWindow_Info:update_petroom()
    local transform = self.childTab[2].transform
    local build = self.model:getbuild(2)
    if build == nil then return end
    local builddata = self.model:getbuilddata(2, build.lev)
    if builddata == nil then return end

    transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    transform:FindChild("NameText"):GetComponent(Text).text = builddata.name

    local showdescdata = builddata -- 要显示的说明数据
    self.childTab[2].transform:FindChild("OkButton/Text").gameObject:SetActive(true)
    self.childTab[2].transform:FindChild("OkButton/HuoliTextI18N").gameObject:SetActive(false)
    if build.lev == 0 then  -- 如果当前等级为0，则显示1级的数据
        showdescdata = self.model:getbuilddata(2, 1)
        self.childTab[2].transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("前往建造")
        -- transform:FindChild("DescText2"):GetComponent(Text).text = "当前未建造宠物室，赶紧点击<color='#00ff66'>升级</color>按钮建造吧{face_1,38}"
        self.panel2_desctext2:SetData(TI18N("当前未建造宠物室，赶紧点击<color='#00ff66'>升级</color>按钮建造吧{face_1,38}"))
    else
        if self.pet_timerId ~= nil then
            LuaTimer.Delete(self.pet_timerId)
            local transform = self.childTab[2].transform
            transform:FindChild("CoolTimeTxt").gameObject:SetActive(false)
        end

        self.childTab[2].transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("可 训 练")
        local costData1 = DataFamily.data_train_cost[1]
        local costData2 = DataFamily.data_train_cost[2]

        local left_num = self.model:getbuilddataeffecttype(2, showdescdata.lev, 11) - self.model:getbuildeffecttypevalue(53)
        local tempStr = string.format("%s<color='#248813'>%s</color>\n%s<color='#248813'>%s</color>\n%s", TI18N("当前活力： "), RoleManager.Instance.RoleData.energy, TI18N("今天剩余训练次数："), left_num, TI18N("次数用完后，消耗一定活力可继续训练"))
        self.panel2_desctext2:SetData(tempStr)
    end

    local icon = transform:FindChild("Icon")
    BaseUtils.SetGrey(icon:GetComponent(Image), builddata.icon_grey == 1)
    local btn = icon:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = icon.gameObject, itemData = {builddata.icon_desc} }) end)

    if not self.init_petroom then

    end
end

function HomeWindow_Info:update_petlist()
    -- print('---------------111111')
    local transform = self.childTab[2].transform
    local build = self.model:getbuild(2)
    if build == nil then return end
    local builddata = self.model:getbuilddata(2, build.lev)
    if builddata == nil then return end

    -- print('------------------22222')

    local length = self.model:getbuilddataeffecttype(2, build.lev, 6)
    if build.lev == 0 then  -- 如果当前等级为0，则打开1个宠物栏
        length = 1
    end
    local max_length = 3
    if #self.petItem_list == 0 then
        local content = transform:FindChild("PetListPanel/Content").gameObject
        local headobject = content.transform:FindChild("PetHead").gameObject
        headobject:SetActive(false)

        for i=1, max_length do
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(content.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local button = item:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:ClickPetHeadItem(item, i) end)
            self.petItem_list[i] = item
        end
    end

    local selectBtn = nil
    self.petData_list = self.model:getpettrainlist()
    for i=1, length do
        local headitem = self.petItem_list[i]
        if self.petData_list[i] ~= nil then
            local data = self.petData_list[i].petData
            headitem.name = tostring(self.petData_list[i].id)
            if data ~= nil then
                headitem.transform:FindChild("NameText"):GetComponent(Text).text = data.name
                headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("%s：%s", TI18N("等级"), data.lev)
                headitem.transform:FindChild("DescText"):GetComponent(Text).text = ""

                local headId = tostring(data.base.head_id)
                local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)

                local loaderId = headImage.gameObject:GetInstanceID()
                if self.headLoaderList[loaderId] == nil then
                    self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
                end
                self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)

                -- headImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
                headImage.rectTransform.sizeDelta = Vector2(54, 54)
                local headbg = PetManager.Instance.model:get_petheadbg(data)
                headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
                    = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

                if self.petdata ~= nil and self.petdata.id == data.id then selectBtn = headitem end
            end
        else
            local headitem = self.petItem_list[i]
            headitem.name = "add"

            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("点击添加")

            local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)

             local loaderId = headImage.gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
            end
            self.headLoaderList[loaderId]:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage"))
            headImage.rectTransform.sizeDelta = Vector2(32, 36)

            headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
                = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        end
        headitem.transform:FindChild("Select").gameObject:SetActive(false)
    end

    -- print('------------------333')

    if length < max_length then
        for i=length+1, max_length do
            local headitem = self.petItem_list[i]
            headitem.name = "lock"

            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("Using").gameObject:SetActive(false)
            headitem.transform:FindChild("Possess").gameObject:SetActive(false)
            if i == 2 then
                headitem.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("2级宠物室开启")
            else
                headitem.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("4级宠物室开启")
            end
            local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
            headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Lock")
            headImage.rectTransform.sizeDelta = Vector2(36, 40)
            headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
                 = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
            headitem.transform:FindChild("Select").gameObject:SetActive(false)
        end
    end

    local dataLen = 0
    for k, v in pairs(self.petData_list) do
        dataLen = dataLen + 1
    end
    if dataLen > 0 then
        local btn = transform:FindChild("OkButton"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        if self.select_pet_item ~= nil then
            self:ClickPetHeadItem(self.select_pet_item, 0)
        else
            self:ClickPetHeadItem(self.petItem_list[1], 1)
        end
    else
        transform:FindChild("PetInfoText"):GetComponent(Text).text = ""
        transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = ""
        transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = 0

        local preview = transform:FindChild("Preview")
        preview.gameObject:SetActive(false)
        transform:FindChild("PreviewText").gameObject:SetActive(true)
        transform:FindChild("TrainImage").gameObject:SetActive(false)

        local btn = transform:FindChild("OkButton"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
                if build.lev > 0 then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, {function(data) self:selectPet(data, 1) end})
                else
                    self:ask_build(TI18N("宠物室"), 2)
                end
            end)
    end
end

function HomeWindow_Info:ClickPetHeadItem(petHeadItem, index)
    local build = self.model:getbuild(2)
    if build == nil then return end

    if build.lev == 0 then
        self:ask_build(TI18N("宠物室"), 2)
        return
    end

    if petHeadItem.name == "lock" then
        if index == 2 then
            NoticeManager.Instance:FloatTipsByString(TI18N("该宠物栏将在2级宠物室开启"))
        elseif index == 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("该宠物栏将在4级宠物室开启"))
        end
    elseif petHeadItem.name == "add" then
        self.childTab[2].transform:FindChild("OkButton/Text").gameObject:SetActive(true)
        self.childTab[2].transform:FindChild("OkButton/HuoliTextI18N").gameObject:SetActive(false)
        --按钮居中显示
        self.childTab[2].transform:FindChild("CoolTimeTxt").gameObject:SetActive(false)
        self.childTab[2].transform:FindChild("OkButton").anchoredPosition = Vector3(187, -170, 0)
        if self.select_pet_item ~= nil then
            self.select_pet_item.transform:FindChild("Select").gameObject:SetActive(false)
        end
        self.select_pet_item = petHeadItem
        self.select_pet_item.transform:FindChild("Select").gameObject:SetActive(true)
        local transform = self.childTab[2].transform
        transform:FindChild("PetInfoText"):GetComponent(Text).text = ""
        transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = ""
        transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = 0
        local preview = transform:FindChild("Preview")
        preview.gameObject:SetActive(false)
        transform:FindChild("PreviewText").gameObject:SetActive(true)
        transform:FindChild("TrainImage").gameObject:SetActive(false)

        local openFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect,
                {
                    function(data, transform)
                        local build = self.model:getbuild(2)
                        if build == nil then return end
                        local builddata = self.model:getbuilddata(2, build.lev)
                        local exp_model = self.model:getbuilddataeffecttype(2, build.lev, 1)
                        local levupmode = DataLevup.data_levupmode[string.format("%s_%s", exp_model, data.lev)]
                        if levupmode ~= nil then
                            transform:FindChild("Main/DescText"):GetComponent(Text).text = string.format("%s<color='#248813'>%s</color>%s", TI18N("训练可获得"), levupmode.pet_exp, TI18N("经验"))
                        end
                    end
                    ,function(data) self:selectPet(data, index) end
                })
        end
        if index ~= 0 then
            openFunc()
        end
        local btn = transform:FindChild("OkButton"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
            openFunc()
        end)
    else
        if self.select_pet_item ~= nil then
            self.select_pet_item.transform:FindChild("Select").gameObject:SetActive(false)
        end
        self.select_pet_item = petHeadItem
        self.select_pet_item.transform:FindChild("Select").gameObject:SetActive(true)

        local data = self.petData_list[tonumber(petHeadItem.name)]
        self.petData = data.petData
        -- PetManager.Instance.model:getpet_byid(tonumber(petHeadItem.name))

        local transform = self.childTab[2].transform
        transform:FindChild("PetInfoText"):GetComponent(Text).text = string.format("%s Lv.%s", self.petData.name, self.petData.lev)
        transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = string.format("%s/%s", self.petData.exp, self.petData.max_exp)
        transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = self.petData.exp / self.petData.max_exp

        self.pet_end_time = data.end_time

        if self.pet_timerId ~= nil then
            LuaTimer.Delete(self.pet_timerId)
        end
        if self.pet_end_time > BaseUtils.BASE_TIME then
            transform:FindChild("OkButton").anchoredPosition = Vector3(187, -180, 0)
            local costData = DataFamily.data_train_cost[1]
            local btn = transform:FindChild("OkButton"):GetComponent(Button)
            self.childTab[2].transform:FindChild("OkButton/Text").gameObject:SetActive(false)
            self.childTab[2].transform:FindChild("OkButton/HuoliTextI18N").gameObject:SetActive(true)
            self.okBtnQuickTxt:SetData(string.format("%s(%s{assets_2,90006})", TI18N("加速"), costData.energy))

            btn.onClick:RemoveAllListeners()
            btn.onClick:AddListener(function()
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.sureLabel = TI18N("确定")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    HomeManager.Instance:Send11234(tonumber(self.select_pet_item.name))
                end
                data.content = string.format("  %s%s{assets_2,90006}%s", TI18N("是否消耗"), costData.energy, TI18N("直接完成训练？"))
                NoticeManager.Instance:ConfirmTips(data)
            end)
            transform:FindChild("CoolTimeTxt").gameObject:SetActive(true)
        else
            transform:FindChild("CoolTimeTxt").gameObject:SetActive(false)
            --按钮居中显示
            transform:FindChild("CoolTimeTxt").gameObject:SetActive(false)
            transform:FindChild("OkButton").anchoredPosition = Vector3(187, -170, 0)
        end

        self.pet_timerId = LuaTimer.Add(0, 1000, function() self:pet_time_update() end)

        local preview = transform:FindChild("Preview")
        local petModelData = PetManager.Instance.model:getPetModel(self.petData)
        local modelData = {type = PreViewType.Pet, skinId = petModelData.skin, modelId = petModelData.modelId, animationId = self.petData.base.animation_id, scale = self.petData.base.scale / 100, effects = petModelData.effects, isRotate = true, isMove = true}
        self:load_preview(preview, modelData)
        preview.gameObject:SetActive(true)
        transform:FindChild("PreviewText").gameObject:SetActive(false)
        transform:FindChild("TrainImage").gameObject:SetActive(true)
    end
end

function HomeWindow_Info:pet_time_update()
    if self.pet_end_time < BaseUtils.BASE_TIME then
        if self.pet_timerId ~= nil then
            LuaTimer.Delete(self.pet_timerId)
        end
        local transform = self.childTab[2].transform
        self.childTab[2].transform:FindChild("OkButton/Text").gameObject:SetActive(true)
        self.childTab[2].transform:FindChild("OkButton/HuoliTextI18N").gameObject:SetActive(false)
        self.childTab[2].transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("可 训 练")
        transform:FindChild("CoolTimeTxt").gameObject:SetActive(false)
        self.pet_end_time = 0
        self:update_petlist()
    else
        local timeStr = BaseUtils.formate_time_gap(self.pet_end_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.HOUR)
        local transform = self.childTab[2].transform
        transform:FindChild("CoolTimeTxt"):GetComponent(Text).text = timeStr
    end
end

function HomeWindow_Info:selectPet(data, index)
    if data ~= nil then
        if data.lev >= 40 then
            HomeManager.Instance:Send11214(data.id, index)
            AgendaManager.Instance:Require12004()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("该宠物太过弱小，还是等40级再来训练吧！"))
        end
    end
end

---------------------------------- Mark 生产室
function HomeWindow_Info:update_productionroom()
    local transform = self.childTab[3].transform
    local build = self.model:getbuild(3)
    if build == nil then return end
    local builddata = self.model:getbuilddata(3, build.lev)
    if builddata == nil then return end

    transform:FindChild("NameText"):GetComponent(Text).text = builddata.name
    transform:FindChild("DescText"):GetComponent(Text).text = TI18N("生产物品有一定几率获得<color='#00ff00'>双份奖励</color>")

    local showdescdata = builddata -- 要显示的说明数据
    if build.lev == 0 then showdescdata = self.model:getbuilddata(3, 1) end -- 如果当前等级为0，则显示1级的数据
    -- transform:FindChild("DescText1"):GetComponent(Text).text = string.format("1.占用空间<color='#ffff9a'>%s㎡</color>", showdescdata.use_space)
    -- transform:FindChild("DescText2"):GetComponent(Text).text = string.format("战斗中使用药品效果<color='#ffff9a'>+%s%%</color>，变身果持续时间<color='#ffff9a'>+%s分钟</color>"
    --             , self.model:getbuilddataeffecttype(3, showdescdata.lev, 5)
    --             , self.model:getbuilddataeffecttype(3, showdescdata.lev, 9))
    transform:FindChild("DescText2"):GetComponent(Text).text = TI18N("升至特定等级可提升战斗药效果，延长变身时长与PVP场次")



    local icon = transform:FindChild("Icon")
    BaseUtils.SetGrey(icon:GetComponent(Image), builddata.icon_grey == 1)
    local btn = icon:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = icon.gameObject, itemData = {builddata.icon_desc} }) end)

    if not self.init_productionroom then
        local transform = self.childTab[3].transform
        self.productionroom_skillitem_list[1] = transform:FindChild("Item1").gameObject
        self.productionroom_skillitem_list[2] = transform:FindChild("Item2").gameObject

        local btn = self.productionroom_skillitem_list[1].transform:FindChild("Button"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
                if build.lev > 0 then
                    SkillManager.Instance:Send10810(10000)
                else
                    self:ask_build(TI18N("生产室"), 3)
                end
            end)
        btn = self.productionroom_skillitem_list[2].transform:FindChild("Button"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function()
                if build.lev > 0 then
                    SkillManager.Instance:Send10810(10001)
                else
                    self:ask_build(TI18N("生产室"), 3)
                end
            end)

        self:update_productionroom_skill()
        self.init_productionroom = true
    end

    self:update_energy()
end

function HomeWindow_Info:update_productionroom_skill()
    local data_list = {
                 [1] = {skill_id = 10000, icon_id = 10000, name = TI18N("栽培果实"), button = TI18N("栽培"), cost = nil, type = 1}
                , [2] = {skill_id = 10001, icon_id = 10001, name = TI18N("魔药研制"), button = TI18N("研制"), cost = nil, type = 2}
            }
    local model = SkillManager.Instance.model

    local index = 0
    for i = 1, #data_list do
        local item = self.productionroom_skillitem_list[i]

        local data = data_list[i]
        if data ~= nil then
            local skill_lev = 10000
            for _, life_skill in ipairs(model.life_skills) do
                if life_skill.id == data.skill_id then
                    skill_lev = life_skill.lev
                    if life_skill.producing_cost ~= "" and #life_skill.producing_cost > 0 then
                        data.cost = life_skill.producing_cost[#life_skill.producing_cost][2]
                    end
                    if life_skill.product ~= "" and #life_skill.product > 0 then
                        data.key = life_skill.product[#life_skill.product].key
                    end
                end
            end

            local lev = 10000
            if data.type > 0 then
                for _, data_product_open in pairs(DataSkillLife.data_product_open) do
                    if data_product_open.type == data.type and lev > data_product_open.open_lev then
                        lev = data_product_open.open_lev
                    end
                end
            end

            if skill_lev >= lev then
                index = index + 1
                item:SetActive(true)
            else
                item:SetActive(false)
            end

            item.transform:FindChild("Image/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_icon, tostring(data.icon_id))
            local skill_name = string.format("%s Lv.%s", data.name, skill_lev)
            item.transform:FindChild("I18N_Name"):GetComponent(Text).text = skill_name
            item.transform:FindChild("I18N_Desc"):GetComponent(Text).text = string.format("%s：%s", TI18N("消耗活力"), data.cost or 0)
            item.transform:FindChild("Button/Text"):GetComponent(Text).text = data.button
        end
    end
end

---------------------------------- Mark 储存室
function HomeWindow_Info:update_storeroom()
    local build = self.model:getbuild(4)
    if build == nil then return end

    if build.lev == 0 then
        self:update_productionroom()
        self:ask_build(TI18N("储存室"), 4)
    else
        if self.childTab[self.currentIndex] ~= nil then
            self.childTab[self.currentIndex]:SetActive(false)
        end
        self.currentIndex = 1
        LuaTimer.Add(5, function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.store, {3}) end)
    end
end

---------------------------------- Mark
function HomeWindow_Info:update_energy()
    if DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev] == nil then return end

    local max_energy = DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy
    self.panel3_energy_slider_text.text = string.format("%s/%s", RoleManager.Instance.RoleData.energy, max_energy)
    self.panel3_energy_slider.value = RoleManager.Instance.RoleData.energy / max_energy
end


function HomeWindow_Info:ask_build(build_name, type)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format("%s<color='#ffff00'>%s</color>，%s？", TI18N("您还未建造"), build_name, TI18N("无法使用，是否前往建造"))
    data.sureLabel = TI18N("取消")
    data.cancelLabel = TI18N("前往")
    data.blueSure = true
    data.greenCancel = true
    data.sureCallback = function()
        if type == 4 then
            self.tabGroup.noCheckRepeat = true
            self.tabGroup:ChangeTab(1)
            self.tabGroup.noCheckRepeat = false
        end
    end
    data.cancelCallback = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {2,type})
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function HomeWindow_Info:update_red()
    -- 宠物室的空位
    local red = false

    local build = self.model:getbuild(2)
    if build == nil then return end
    local petItem_list = self.model:getpettrainlist()
    local length = self.model:getbuilddataeffecttype(2, build.lev, 6)
    if build.lev == 0 then  -- 如果当前等级为0，则打开1个宠物栏
        length = 1
    end
    for i=1, length do
        red = red or (petItem_list[i] == nil)
    end

    red = red and (AgendaManager.Instance:GetActivitypoint() >= 100)
    self.tabGroup:ShowRed(2, red)

    red = false

    -- 卧室的使用
    local all_times = self.model:geteffecttypevalue(12)
    local used_times = self.model:getbuildeffecttypevalue(55)
    red = red or (all_times - used_times > 0)

    self.tabGroup:ShowRed(1, red)
end
