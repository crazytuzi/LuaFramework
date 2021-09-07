-- ----------------------------------------------------------
-- UI - 坐骑窗口 信息面板
-- @ljh 2016.5.24
-- ----------------------------------------------------------
RideView_Transformation = RideView_Transformation or BaseClass(BasePanel)

function RideView_Transformation:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "RideView_Transformation"
    self.resList = {
        {file = AssetConfig.ridewindow_book, type = AssetType.Main}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.dailyicon, type = AssetType.Dep}
        , {file = AssetConfig.base_textures, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
        , {file = AssetConfig.ridebg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false
    self.transfigurationButtonStatus = false
    self.transfigurationStatusIndex = 1

    ------------------------------------------------
    self.headBar = nil
    self.modelPanel = nil
    self.attrPanel = nil
    self.infoPanel = nil

    self.container = nil
    self.headobject = nil
    self.scrollrect = nil

    self.headlist = {}

    self.ridedata = nil

    self.transformationListType = 1
    self.ride_transformation_list = {}
    self.list_name = {TI18N("逐风坐骑"), TI18N("疾风坐骑"), TI18N("旋风坐骑")}

    self.showType = 1

    self.color_name = { TI18N("可爱蓝"), TI18N("爱心粉"), TI18N("儒雅紫"), TI18N("坏笑橙"), TI18N("欢乐白") }
    self.effect_name = { TI18N("可爱蓝"), TI18N("爱心粉"), TI18N("儒雅紫"), TI18N("坏笑橙"), TI18N("欢乐白") }

    self.colorIndex = 1
    self.effectIndex = 1
    ------------------------------------------------
    self._update = function() self:update() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideView_Transformation:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow_book))
    self.gameObject.name = "RideView_Transformation"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.headBar = self.transform:FindChild("HeadBar").gameObject
    self.modelPanel = self.transform:FindChild("ModelPanel").gameObject
    self.attrPanel = self.transform:FindChild("AttrPanel").gameObject
    self.infoPanel = self.transform:FindChild("InfoPanel").gameObject
    self.dyeSelectPanel = self.transform:FindChild("DyeSelectPanel").gameObject
    self.dyeInfoPanel = self.transform:FindChild("DyeInfoPanel").gameObject
    self.dyeNoActiveInfoPanel = self.transform:FindChild("DyeNoActiveInfoPanel").gameObject
    self.dyeNoActiveInfoText = self.transform:FindChild("DyeNoActiveInfoPanel/Text"):GetComponent(Text)
    self.dyeNoActiveInfoText.text = "激活后可染色"

    self.desc = self.transform:Find("Desc").gameObject
    self.desc:SetActive(false)

    self.modelPanel.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
    self.modelPanel.transform:Find("Bg").gameObject:SetActive(true)

    self.mulityplayertext = self.modelPanel.transform:Find("MulityPlayerText")

    self.container = self.headBar.transform:FindChild("HeadBar/mask/HeadContainer").gameObject
    self.headobject = self.container.transform:FindChild("Head").gameObject
    self.headobject.transform:FindChild("RedPointImage").localPosition = Vector3(34, 28, 0)
    self.headobject:SetActive(false)
    
    -- TODO 图集资源有问题的应急措施，下版本去掉 20181001
    local headSelect = self.container.transform:FindChild("Head/Select"):GetComponent(Image)
    if headSelect.sprite == nil then
        headSelect.sprite = self.assetWrapper:GetSprite(AssetConfig.ride_texture,"ItemSelectedBg")
    end
    if headSelect.sprite == nil then
        headSelect.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"Select1")
    end

    self.scrollrect = self.headBar.transform:FindChild("HeadBar/mask"):GetComponent(ScrollRect)



    -- -- 按钮功能绑定
    local btn
    btn = self.headBar.transform:FindChild("SwitchButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:openList() end)

    btn = self.headBar.transform:FindChild("SwitchButton/List/Close"):GetComponent(Button)
    btn.onClick:AddListener(function() self:closeList() end)

    for i = 1, 3 do
        btn = self.headBar.transform:FindChild("SwitchButton/List/Button"..i):GetComponent(Button)
        btn.onClick:AddListener(function() self:selectTransformationList(i) end)

        btn.transform:FindChild("I18NText"):GetComponent(Text).text = self.list_name[i]
    end

    btn = self.modelPanel.transform:FindChild("Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:ModelClick() end)

    btn = self.infoPanel.transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:okButtonClick() end)

    btn = self.dyeInfoPanel.transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnDyeColor() end)

    btn = self.dyeInfoPanel.transform:FindChild("CancelButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:ResetDyeColor() end)
    self.dyeResetButton = btn
    self.dyeResetButton.gameObject:SetActive(false)

    btn = self.dyeSelectPanel.transform:FindChild("ColorCon/MidCon/LeftBtn"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnSelectColor(true, true) end)

    btn = self.dyeSelectPanel.transform:FindChild("ColorCon/MidCon/RightBtn"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnSelectColor(true, false) end)

    btn = self.dyeSelectPanel.transform:FindChild("EffectCon/MidCon/LeftBtn"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnSelectColor(false, true) end)

    btn = self.dyeSelectPanel.transform:FindChild("EffectCon/MidCon/RightBtn"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnSelectColor(false, false) end)


    self.transfigurationButton = self.transform:FindChild("TransfigurationButton"):GetComponent(Button)
    self.transfigurationButton.onClick:AddListener(function() self:OnTransfigurationButtonClick() end)
    self.transfigurationButton.gameObject:SetActive(false)

    self.transfigurationImage = self.transform:FindChild("TransfigurationButton"):GetComponent(Image)

    btn = self.transform:FindChild("SwitchButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnSwitchButtonClick() end)
    self.switchButton = btn

    self.itemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.infoPanel.transform:FindChild("PiecePanel/ItemSolt").gameObject, self.itemSolt.gameObject)

    self.dyeItemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.dyeInfoPanel.transform:FindChild("PiecePanel/ItemSolt").gameObject, self.dyeItemSolt.gameObject)

    self.headBar.transform:FindChild("SwitchButton/TypeText"):GetComponent(Text).text = self.list_name[self.transformationListType]

    self.timeItem = self.transform:FindChild("TimeItem").gameObject
    self.timeText = self.transform:FindChild("TimeItem/TimeText"):GetComponent(Text)

    self.dyeSelectPanel.transform:FindChild("EffectCon").gameObject:SetActive(false)

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function RideView_Transformation:__delete()
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end
    if self.dyeItemSolt ~= nil then
        self.dyeItemSolt:DeleteMe()
        self.dyeItemSolt = nil
    end
    self:OnHide()
    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end
    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RideView_Transformation:OnInitCompleted()

end

function RideView_Transformation:OnShow()
    --BaseUtils.dump(self.openArgs,"传入的参数")
    self.myIsOpen = false
    RideManager.Instance.OnUpdateRide:Remove(self._update)
    RideManager.Instance.OnUpdateOneRide:Remove(self._update)
	RideManager.Instance.OnUpdateRide:Add(self._update)
    RideManager.Instance.OnUpdateOneRide:Add(self._update)

    if self.firstEffect ~= nil then
        self.firstEffect:SetActive(false)
    end
    local openDyeWindow = false
    if self.openArgs ~= nil and #self.openArgs > 1 then
        -- self.showType = self.openArgs[2]
        -- if self.showType == 2 then
        --     openDyeWindow = true
        -- end
        if self.openArgs[2] ~= nil and self.openArgs[2] == 2 then
            openDyeWindow = true
        end
    end

    if self.openArgs ~= nil then
        if self.openArgs.transfigurationOpenStatus ~= nil then
            self.transfigurationOpenStatus = self.openArgs.transfigurationOpenStatus
        end
    end


    self:update()

    if self.parent.openArgs ~= nil and #self.parent.openArgs > 2 then
        for i=1,#self.headlist do
            if self.headlist[i].name == tostring(self.parent.openArgs[2]) or self.headlist[i].name == tostring(self.parent.openArgs[3])then
                self:onheaditemclick(self.headlist[i])
                break
            end
        end
    end


    if openDyeWindow then
        if self.ridedata.active and DataMount.data_ride_dye[self.ridedata.id] ~= nil then
            self.model:OpenRideDyeWindow({ self.ridedata.id, self.ridedata.active })
        end
    end
end

function RideView_Transformation:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.effectTimerId ~= nil then
        LuaTimer.Delete(self.effectTimerId)
        self.effectTimerId = nil
    end

    RideManager.Instance.OnUpdateRide:Remove(self._update)
    RideManager.Instance.OnUpdateOneRide:Remove(self._update)
end

function RideView_Transformation:update()
    if self.model.cur_ridedata == nil then return end

    self:SetColorAndEffectIndex()
    self:update_headBar()

    if DataMount.data_ride_dye[self.ridedata.id] == nil then
        self.showType = 1
        self.switchButton.gameObject:SetActive(false)
    else
        self.switchButton.gameObject:SetActive(true)
    end


    self:Update_Transfiguration()



    self:update_modelPanel()
    self.dyeNoActiveInfoText.text = "激活后可染色"
    if self.showType == 1 then
        self.attrPanel:SetActive(true)
        self.infoPanel:SetActive(true)
        self.dyeSelectPanel:SetActive(false)
        self.dyeInfoPanel:SetActive(false)
        self.dyeNoActiveInfoPanel:SetActive(false)

        self:update_attrPanel()
        self:update_infoPanel()
    elseif self.showType == 4 then
        self.attrPanel:SetActive(true)
        self.infoPanel:SetActive(true)
        self.dyeSelectPanel:SetActive(false)
        self.dyeInfoPanel:SetActive(false)
        self.dyeNoActiveInfoPanel:SetActive(false)

        self:update_attrPanel()
        self:Update_TransfigurationInfoPanel()
    else
        self.attrPanel:SetActive(false)
        self.infoPanel:SetActive(false)
        self.dyeSelectPanel:SetActive(true)
        if self.ridedata.active then
            self.dyeInfoPanel:SetActive(true)
            self.dyeNoActiveInfoPanel:SetActive(false)
        else
            self.dyeInfoPanel:SetActive(false)
            self.dyeNoActiveInfoPanel:SetActive(true)
        end

        self:update_dyeSelectPanel()
        self:update_dyeInfoPanel()
    end
end

function RideView_Transformation:update_headBar()
    -- self.ride_transformation_list = self.model:get_ride_transformation_list(self.transformationListType) 说现在不分阶数了
    self.ride_transformation_list = self.model:get_ride_transformation_list(0) -- 参数0代表获取所有阶数

    local ridelist = {}
    for k,v in ipairs(self.ride_transformation_list) do
        if DataMount.data_ride_transformation[v.id] ~= nil then
            if RoleManager.Instance.RoleData.lev >= DataMount.data_ride_transformation[v.id].opentab  then
                table.insert(ridelist,v)
            end
        else
             table.insert(ridelist,v)
        end
    end

    local headlist = self.headlist
    local headobject = self.headobject
    local container = self.container
    local data

    local selectBtn = nil
    --BaseUtils.dump(ridelist,"ridelist")
    --将列表后面的id们提前
    local HasNum = 0
    local forwardList = {}
    for i = 1, #ridelist do
        if ridelist[i].active then
            HasNum = HasNum + 1
        end
        -- if (ridelist[i].id == 2051 or ridelist[i].id == 2057 or ridelist[i].id == 2063 or ridelist[i].id == 2069 or ridelist[i].id == 2070 or ridelist[i].id == 2076) and ridelist[i].active == nil then
        if (ridelist[i].id == 2051 or self.model:CheckIsMultiplayerRide(ridelist[i].id)) and ridelist[i].active == nil then
            table.insert(forwardList,i)
        end
    end
    if next(forwardList) ~= nil then
        for i,v in ipairs(forwardList) do
            local element = table.remove(ridelist,v)
            table.insert(ridelist, HasNum + 1, element)
        end
        forwardList = {}
    end

    for i = 1, #ridelist do
        if not ridelist[i].active then
            local cost = ridelist[i].synthetise_cost[1]
            if cost ~= nil then
                local num = BackpackManager.Instance:GetItemCount(cost[1])
                if num >= cost[2] then
                    table.insert(forwardList,i)
                end
            end

        end
    end
    if next(forwardList) ~= nil then
        for i,v in ipairs(forwardList) do
            local element = table.remove(ridelist,v)
            table.insert(ridelist, 1, element)
        end
        forwardList = {}
    end


    for i = 1, #ridelist do

        data = ridelist[i]
        local headitem = headlist[i]

        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[i] = item
            headitem = item
        end

        headitem:SetActive(true)
        headitem.name = tostring(data.id)

        -- self:updateNameColor(data, headitem)

        local headId = tostring(data.base.head_id)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
        headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.headride, headId)
        -- headImage:SetNativeSize()
        -- headImage.rectTransform.sizeDelta = Vector2(54, 54)
        -- headImage.gameObject:SetActive(true)

        -- local headbg = self.model:get_rideheadbg(data)
        -- headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
        --     = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

        if data.active then
            headImage.color = Color.white
        else
            headImage.color = Color.grey
        end

        if self.model.cur_ridedata.transformation_id == data.id
            or (self.model.cur_ridedata.transformation_id == 0 and self.model.cur_ridedata.mount_base_id == data.id) then
            headitem.transform:FindChild("Using").gameObject:SetActive(true)
        else
            headitem.transform:FindChild("Using").gameObject:SetActive(false)
        end

        if DataMount.data_ride_data[data.id] ~= nil and DataMount.data_ride_data[data.id].multiplayer == 1 then 
            headitem.transform:FindChild("MulityPlayer").gameObject:SetActive(true)
        else
            headitem.transform:FindChild("MulityPlayer").gameObject:SetActive(false)
        end

        if not data.active then
            local cost = data.synthetise_cost[1]
            if cost == nil then
                headitem.transform:FindChild("RedPointImage").gameObject:SetActive(false)
            else
                local num = BackpackManager.Instance:GetItemCount(cost[1])
                if num >= cost[2] then
                    headitem.transform:FindChild("RedPointImage").gameObject:SetActive(true)
                else
                    headitem.transform:FindChild("RedPointImage").gameObject:SetActive(false)
                end
            end
        else
            headitem.transform:FindChild("RedPointImage").gameObject:SetActive(false)
        end

        -- if data.index == 1 then
        --    headitem.transform:FindChild("Mark").gameObject:SetActive(false)
        -- else
        --     headitem.transform:FindChild("Mark").gameObject:SetActive(true)
        -- end

        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:onheaditemclick(headitem) end)

        if self.ridedata ~= nil and self.ridedata.id == data.id then selectBtn = headitem end
    end

    for i = #ridelist+1, #headlist do
        headlist[i]:SetActive(false)
    end
    if #ridelist > 0 then
        if selectBtn == nil then
            self:onheaditemclick(headlist[1])
        else
            self:onheaditemclick(selectBtn)
        end
    end
end

function RideView_Transformation:update_modelPanel()
    if self.ridedata == nil then return end

    local transform = self.modelPanel.transform
    local preview = transform:FindChild("Preview")
    local rideData = self.ridedata

    
    if self.showType == 1 then
        local base_id = self.model:GetTransformationDye(rideData.base.base_id)
        local _scale = DataMount.data_ride_data[base_id].scale / 100 * 1.6
        local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
        table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val =  base_id})
        self.parent:load_preview(preview, data)
    elseif self.showType == 4 then
        if self.transfigurationButtonStatus == false then
            local base_id = self.model:GetTransformationDye(rideData.base.base_id)
            local _scale = DataMount.data_ride_data[base_id].scale / 100 * 1.6
            local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
            table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = base_id })
            self.parent:load_preview(preview, data)
        elseif self.transfigurationButtonStatus == true then
            local _scale = DataMount.data_ride_data[rideData.base.base_id].scale / 100 * 1.6
            local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
            table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val =  DataMount.data_ride_transf_data[rideData.base.base_id].evolution_id})
            self.parent:load_preview(preview, data)
        end
    else
        local data_ride_dye_preview = DataMount.data_ride_dye_preview[string.format("%s_%s_%s", self.ridedata.id, self.colorIndex, self.effectIndex)]
        -- print(string.format("%s_%s_%s", self.ridedata.id, self.colorIndex, self.effectIndex))
        local data_ride_data = DataMount.data_ride_data[data_ride_dye_preview.dye_id]
        local _scale = data_ride_data.scale / 100 * 1.6
        -- local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 1, effects = { { effect_id = data_ride_data.s_effect_id } } }
        local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {} }
        table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = data_ride_dye_preview.dye_id })
        self.parent:load_preview(preview, data)
    end

    transform:FindChild("Title/Text"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", rideData.color, rideData.base.name)
    if rideData.index == 1 then
       transform:FindChild("Mark").gameObject:SetActive(false)
    else
        transform:FindChild("Mark").gameObject:SetActive(true)
    end
end


function RideView_Transformation:Update_Transfiguration()


    -- print(debug.traceback())
    -- print(tostring(self.myIsOpen) .. "6666666666666666666666")
    if DataMount.data_ride_transf_data[self.ridedata.id] ~= nil then
        self.showType = 4
        local myTransfigurationData = RideManager.Instance.model:GetTransfigurationData(self.ridedata.id)
        if self.myIsOpen == false then
            if self.transfigurationOpenStatus == nil then
                if myTransfigurationData == nil then
                    self.transfigurationButtonStatus = false
                elseif myTransfigurationData ~= nil then
                    if myTransfigurationData.evolution_id == DataMount.data_ride_transf_data[self.ridedata.id].base_id then
                        self.transfigurationButtonStatus = false
                    elseif myTransfigurationData.evolution_id == DataMount.data_ride_transf_data[self.ridedata.id].evolution_id then
                        self.transfigurationButtonStatus = true
                    end
                end

            elseif self.transfigurationOpenStatus ~= nil then
                self.transfigurationButtonStatus = self.transfigurationOpenStatus
                NoticeManager.Instance:FloatTipsByString("暂未激活<color='#ffff00'>进化形态</color>，激活后可<color='#ffff00'>幻化</color>")
            end
             self.myIsOpen =true
        end

        self.transfigurationButton.gameObject:SetActive(true)
    else
        self.showType = 1
        self.transfigurationButton.gameObject:SetActive(false)
    end


    if self.transfigurationButtonStatus == false then
        self.transfigurationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ride_texture,"RunI18N")
    elseif self.transfigurationButtonStatus == true then
        self.transfigurationImage.sprite = self.assetWrapper:GetSprite(AssetConfig.ride_texture,"StandI18N")
    end
end

function RideView_Transformation:update_attrPanel()
    if self.ridedata == nil then return end

    local gameObject = self.attrPanel

    local attr_list = self.ridedata.collect_attr
    for i=1, #attr_list do
        local item = gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject
        item.gameObject:SetActive(true)

        item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].attr_name))
        item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].val1)
        item.transform:FindChild("Icon"):GetComponent(Image).sprite
            = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].attr_name])))
    end

    if #attr_list < 5 then
        for i=#attr_list+1, 5 do
            gameObject.transform:FindChild(string.format("AttrObject%s", i)).gameObject:SetActive(false)
        end
    end

    if #attr_list == 0 then
        self.desc:SetActive(true)
    else
        self.desc:SetActive(false)
    end

    gameObject.transform:FindChild("SpeedText"):GetComponent(Text).text = string.format(TI18N("移动速度：%s"), self.ridedata.base.speed_attr[1].val1)
end

function RideView_Transformation:Update_TransfigurationInfoPanel()
    if self.transfigurationButtonStatus == false then
        self:update_infoPanel()
        self.dyeNoActiveInfoPanel:SetActive(false)
        self.infoPanel.transform:FindChild("OkButton").gameObject:SetActive(true)
    elseif self.transfigurationButtonStatus == true then
        if self.ridedata.active then
            local myTransfigurationData = DataMount.data_ride_transf_data[self.ridedata.id]
            self:Update_TransfigurationNextInfoPanel(myTransfigurationData)
            self.dyeNoActiveInfoPanel:SetActive(false)
        else
            self.infoPanel.transform:FindChild("AccessText").gameObject:SetActive(false)
            self.infoPanel.transform:FindChild("PiecePanel").gameObject:SetActive(false)
            self.infoPanel.transform:FindChild("OkButton").gameObject:SetActive(false)
            self.dyeNoActiveInfoPanel:SetActive(true)
            self.dyeNoActiveInfoText.text = DataMount.data_ride_transf_data[self.ridedata.id].ridedesc
        end
    end
end

function RideView_Transformation:Update_TransfigurationNextInfoPanel(myTransfigurationData)
    if myTransfigurationData == nil then return end
    local isactive = false

    local myData = self.model:GetTransfigurationData(myTransfigurationData.base_id)
    if myData ~= nil then
        isactive = true
    end

    if isactive then
        self.infoPanel.transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("幻化")
        self.infoPanel.transform:FindChild("AccessText").gameObject:SetActive(true)
        self.infoPanel.transform:FindChild("PiecePanel").gameObject:SetActive(false)
        self.infoPanel.transform:FindChild("AccessText"):GetComponent(Text).text = DataMount.data_ride_transf_data[self.ridedata.id].access
    else
            self.infoPanel.transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("激活")
            self.infoPanel.transform:FindChild("AccessText").gameObject:SetActive(true)
            self.infoPanel.transform:FindChild("PiecePanel").gameObject:SetActive(true)

            self.infoPanel.transform:FindChild("AccessText"):GetComponent(Text).text = myTransfigurationData.access
            local cost = myTransfigurationData.evolution_cost[1]
            local itembase = BackpackManager.Instance:GetItemBase(cost[1])
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            self.itemSolt:SetAll(itemData)

            local num = BackpackManager.Instance:GetItemCount(cost[1])

            self.itemSolt:SetNum(num, cost[2])
            self.infoPanel.transform:FindChild("PiecePanel/ItemNameText"):GetComponent(Text).text = itemData.name

    end
end

function RideView_Transformation:update_infoPanel()
    if self.ridedata == nil then return end

    if self.ridedata.active then
        self.infoPanel.transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("幻化")
        self.infoPanel.transform:FindChild("AccessText").gameObject:SetActive(true)
        self.infoPanel.transform:FindChild("PiecePanel").gameObject:SetActive(false)
        self.infoPanel.transform:FindChild("AccessText"):GetComponent(Text).text = self.ridedata.access
    else
        if #self.ridedata.synthetise_cost == 0 then
            self.infoPanel.transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("激活")
            self.infoPanel.transform:FindChild("AccessText").gameObject:SetActive(true)
            self.infoPanel.transform:FindChild("PiecePanel").gameObject:SetActive(false)

            self.infoPanel.transform:FindChild("AccessText"):GetComponent(Text).text = self.ridedata.access
        else
            self.infoPanel.transform:FindChild("OkButton/Text"):GetComponent(Text).text = TI18N("激活")
            self.infoPanel.transform:FindChild("AccessText").gameObject:SetActive(true)
            self.infoPanel.transform:FindChild("PiecePanel").gameObject:SetActive(true)

            self.infoPanel.transform:FindChild("AccessText"):GetComponent(Text).text = self.ridedata.access
            local cost = self.ridedata.synthetise_cost[1]
            local itembase = BackpackManager.Instance:GetItemBase(cost[1])
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            self.itemSolt:SetAll(itemData)

            local num = BackpackManager.Instance:GetItemCount(cost[1])
            local almighty_num = 0
            for index, itemBaseId in ipairs(self.ridedata.replace_item) do
                almighty_num = almighty_num + BackpackManager.Instance:GetItemCount(itemBaseId)
            end
            self.itemSolt:SetNum(num + almighty_num, cost[2])
            -- local almighty_num = BackpackManager.Instance:GetItemCount(23660)
            -- if self.ridedata.index == 2 then
            --     almighty_num = BackpackManager.Instance:GetItemCount(23669)
            -- end
            -- if self.ridedata.id == 2018 then
            --     self.itemSolt:SetNum(num, cost[2])
            -- else
            --     self.itemSolt:SetNum(num + almighty_num, cost[2])
            -- end

            self.infoPanel.transform:FindChild("PiecePanel/ItemNameText"):GetComponent(Text).text = itemData.name
            -- if num < cost[2] then
            --     self.infoPanel.transform:FindChild("PiecePanel/ItemNumText"):GetComponent(Text).text = string.format("<color='ff0000'>%s</color><color='ffff00'>/%s</color>", num, cost[2])
            -- else
            --     self.infoPanel.transform:FindChild("PiecePanel/ItemNumText"):GetComponent(Text).text = string.format("<color='00ff00'>%s</color><color='ffff00'>/%s</color>", num, cost[2])
            -- end
        end
    end
end

function RideView_Transformation:update_dyeSelectPanel()
    local data_ride_dye = DataMount.data_ride_dye[self.ridedata.id]
    if data_ride_dye ~= nil then
        if data_ride_dye.color_name[self.colorIndex] ~= nil then
            self.dyeSelectPanel.transform:Find("ColorCon/MidCon/ImgTxtBg/TxtSlolution"):GetComponent(Text).text = data_ride_dye.color_name[self.colorIndex].name
        end
        if data_ride_dye.effect_name[self.effectIndex] ~= nil then
            self.dyeSelectPanel.transform:Find("EffectCon/MidCon/ImgTxtBg/TxtSlolution"):GetComponent(Text).text = data_ride_dye.effect_name[self.effectIndex].name
        end
    end
end

function RideView_Transformation:update_dyeInfoPanel()
    if self.ridedata == nil then
        return
    end

    local cost = DataMount.data_ride_dye[self.ridedata.id].dye_cost[1]
    local itembase = BackpackManager.Instance:GetItemBase(cost[1])
    local itemData = ItemData.New()
    itemData:SetBase(itembase)
    self.dyeItemSolt:SetAll(itemData)

    local num = BackpackManager.Instance:GetItemCount(cost[1])
    local color = "#00ff00"
    if num < cost[2] then
        color = "#ff0000"
    end
    self.dyeInfoPanel.transform:FindChild("PiecePanel/ItemNameText"):GetComponent(Text).text = itemData.name
    self.dyeInfoPanel.transform:FindChild("PiecePanel/ItemNumText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>/%s", color, num, cost[2])
end

function RideView_Transformation:ModelClick()

end

function RideView_Transformation:openList()
    self.headBar.transform:FindChild("SwitchButton/List").gameObject:SetActive(true)
end

function RideView_Transformation:closeList()
    self.headBar.transform:FindChild("SwitchButton/List").gameObject:SetActive(false)
end

function RideView_Transformation:selectTransformationList(type)
    self.transformationListType = type
    self:closeList()

    self.headBar.transform:FindChild("SwitchButton/TypeText"):GetComponent(Text).text = self.list_name[self.transformationListType]

    self.ridedata = nil
    self:update_headBar()
end

function RideView_Transformation:onheaditemclick(item)
    local id = tonumber(item.name)
    self.mulityplayertext.gameObject:SetActive(DataMount.data_ride_data[id].multiplayer == 1)
    for i,value in ipairs(self.ride_transformation_list) do
        if id == value.id then
            self.ridedata = value
            break
        end
    end
    self:SetColorAndEffectIndex()

    if DataMount.data_ride_dye[self.ridedata.id] == nil then
        self.showType = 1
        self.switchButton.gameObject:SetActive(false)
    else
        self.switchButton.gameObject:SetActive(true)
    end
    self:Update_Transfiguration()
    self:update_modelPanel()
    self.dyeNoActiveInfoText.text = "激活后可染色"
    if self.showType == 1 then
        self.attrPanel:SetActive(true)
        self.infoPanel:SetActive(true)
        self.dyeSelectPanel:SetActive(false)
        self.dyeInfoPanel:SetActive(false)
        self.dyeNoActiveInfoPanel:SetActive(false)

        self:update_attrPanel()
        self:update_infoPanel()
     elseif self.showType == 4 then
        self.attrPanel:SetActive(true)
        self.infoPanel:SetActive(true)
        self.dyeSelectPanel:SetActive(false)
        self.dyeInfoPanel:SetActive(false)
        self.dyeNoActiveInfoPanel:SetActive(false)

        self:update_attrPanel()
        self:Update_TransfigurationInfoPanel()
    else
        self.attrPanel:SetActive(false)
        self.infoPanel:SetActive(false)
        self.dyeSelectPanel:SetActive(true)
        if self.ridedata.active then
            self.dyeInfoPanel:SetActive(true)
            self.dyeNoActiveInfoPanel:SetActive(false)
        else
            self.dyeInfoPanel:SetActive(false)
            self.dyeNoActiveInfoPanel:SetActive(true)
        end

        self:update_dyeSelectPanel()
        self:update_dyeInfoPanel()
    end

    local head
    for i = 1, #self.headlist do
        head = self.headlist[i]
        head.transform:FindChild("Select").gameObject:SetActive(false)

        local ridedata = nil
        for i,value in ipairs(self.ride_transformation_list) do
            if tonumber(head.name) == value.id then
                ridedata = value
                break
            end
        end
        -- self:updateNameColor(ridedata, head)
    end
    item.transform:FindChild("Select").gameObject:SetActive(true)
    -- self:updateNameColor(self.ridedata, item, true)

    if self.ridedata.expire_time ~= 0 then
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end

        local time = self.ridedata.expire_time - BaseUtils.BASE_TIME
        if time > 0 then
            self.timerId = LuaTimer.Add(0, 1000, function() self:OnTimer() end)
        else
            self.timeText.text = TI18N("已过期")
        end
        self.timeItem:SetActive(true)
    else
        self.timeItem:SetActive(false)
    end
end

-- function RideView_Transformation:updateNameColor(data, headitem, isselect)
--     if isselect then
--         headitem.transform:FindChild("NameText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", data.color, data.base.name)

--         local lvText = TI18N("未获得")
--         if data.expire_time ~= 0 then
--             if data.expire_time - BaseUtils.BASE_TIME > 0 then
--                 lvText = string.format("<color='%s'>%s</color>", "#be5713", TI18N("限时幻化"))
--             else
--                 lvText = string.format("<color='%s'>%s</color>", ColorHelper.color[5], TI18N("已过期"))
--             end
--         elseif data.active then
--             lvText = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("可幻化"))
--         end
--         headitem.transform:FindChild("LVText"):GetComponent(Text).text = lvText
--     else
--         headitem.transform:FindChild("NameText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", data.color, data.base.name)

--         local lvText = TI18N("未获得")
--         if data.expire_time ~= 0 then
--             if data.expire_time - BaseUtils.BASE_TIME > 0 then
--                 lvText = string.format("<color='%s'>%s</color>", "#be5713", TI18N("限时幻化"))
--             else
--                 lvText = string.format("<color='%s'>%s</color>", ColorHelper.color[5], TI18N("已过期"))
--             end
--         elseif data.active then
--             lvText = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("可幻化"))
--         end
--         headitem.transform:FindChild("LVText"):GetComponent(Text).text = lvText
--     end
-- end

function RideView_Transformation:okButtonClick()
    if self.model.cur_ridedata == nil or self.ridedata == nil then
        return
    end

    if SceneManager.Instance.sceneElementsModel.self_data ~= nil then 
        local self_data = SceneManager.Instance.sceneElementsModel.self_data
        if self_data.isDriver == 1 or (self_data.passengers ~= nil and next(self_data.passengers) ~= nil) then    --司机不允许幻化坐骑
            NoticeManager.Instance:FloatTipsByString(TI18N("共乘状态下无法幻化，请取消共乘后再试"))
            return
        end
    end

    if  self.showType == 4  then
            if self.transfigurationButtonStatus == true then

                if self.model.cur_ridedata.transformation_id == DataMount.data_ride_transf_data[self.ridedata.id].evolution_id or (self.model.cur_ridedata.transformation_id == 0 and self.model.cur_ridedata.mount_base_id == self.ridedata.id) and transfigurationData.evolution_id == DataMount.data_ride_transf_data[self.ridedata.id].evolution_id then
                    NoticeManager.Instance:FloatTipsByString(TI18N("你已经幻化成该坐骑啦{face_1, 22}"))
                else
                    local transfigurationData = RideManager.Instance.model:GetTransfigurationData(self.ridedata.id)
                    if transfigurationData == nil then
                        local cost = DataMount.data_ride_transf_data[self.ridedata.id].evolution_cost[1]
                        local num = BackpackManager.Instance:GetItemCount(cost[1])
                        if num < cost[2] then
                            if num  < cost[2] then
                                NoticeManager.Instance:FloatTipsByString("您没有足够的合成道具，攒够了再来吧")
                            end
                        else
                            RideManager.Instance:Send17029(DataMount.data_ride_transf_data[self.ridedata.id].base_id)
                        end
                    elseif transfigurationData ~= nil then
                        if transfigurationData.evolution_id ~= DataMount.data_ride_transf_data[self.ridedata.id].evolution_id then
                            RideManager.Instance:Send17030(self.ridedata.id,self.model.cur_ridedata.index,self.ridedata.id)
                        else
                            RideManager.Instance:Send17015(self.model.cur_ridedata.index, self.ridedata.id)
                            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = DataMount.data_ride_transf_data[self.ridedata.id].evolution_id, callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })

                        end
                    end
                end
            elseif self.transfigurationButtonStatus == false then
                if self.model.cur_ridedata.transformation_id == self.ridedata.id or (self.model.cur_ridedata.transformation_id == 0 and self.model.cur_ridedata.mount_base_id == self.ridedata.id) then
                    NoticeManager.Instance:FloatTipsByString(TI18N("你已经幻化成该坐骑啦{face_1, 22}"))
                    -- RideManager.Instance:Send17015(self.model.cur_ridedata.index, 0)
                else
                    if self.ridedata.active then
                        local transfigurationData = RideManager.Instance.model:GetTransfigurationData(self.ridedata.id)
                        if transfigurationData ~= nil then
                                if transfigurationData.evolution_id ~= DataMount.data_ride_transf_data[self.ridedata.id].base_id then
                                    RideManager.Instance:Send17030(self.ridedata.id,self.model.cur_ridedata.index,self.ridedata.id)
                                else
                                    RideManager.Instance:Send17015(self.model.cur_ridedata.index, self.ridedata.id)
                                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = self.model:GetTransformationDye(self.ridedata.id), callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
                                end
                        else
                            RideManager.Instance:Send17015(self.model.cur_ridedata.index, self.ridedata.id)
                            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = self.model:GetTransformationDye(self.ridedata.id), callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
                        end

                    else
                        local cost = self.ridedata.synthetise_cost[1]
                        local num = BackpackManager.Instance:GetItemCount(cost[1])
                        if num < cost[2] then
                            NoticeManager.Instance:FloatTipsByString("您没有足够的合成道具，攒够了再来吧")
                        else
                            RideManager.Instance:Send17019(self.ridedata.id)
                        end
                    end
                end
            end
    else
        if self.model.cur_ridedata.transformation_id == self.ridedata.id or (self.model.cur_ridedata.transformation_id == 0 and self.model.cur_ridedata.mount_base_id == self.ridedata.id) then
            NoticeManager.Instance:FloatTipsByString(TI18N("你已经幻化成该坐骑啦{face_1, 22}"))
        elseif self.model.cur_ridedata.mount_base_id == self.ridedata.id then
            RideManager.Instance:Send17015(self.model.cur_ridedata.index, 0)
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = self.model:GetTransformationDye(self.ridedata.id), callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
        else
            if self.ridedata.active then
                if self.ridedata.expire_time ~= 0 and self.ridedata.expire_time - BaseUtils.BASE_TIME <= 0 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("该坐骑幻化时间已过期，无法进行幻化"))
                else
                    RideManager.Instance:Send17015(self.model.cur_ridedata.index, self.ridedata.id)
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = self.model:GetTransformationDye(self.ridedata.id), callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ridewindow) end })
                end
            else
                if #self.ridedata.synthetise_cost == 0 then
                    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideequip, { 1, 0 })
                    local nameText = ''
                    local id = self.ridedata.pre_condition_ride[1]
                    if id ~= nil then
                        nameText = DataMount.data_ride_data[id].name
                    end
                    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("为<color='#00ff00'>%s</color>佩戴<color='#ffff00'>坐骑铠甲</color>可激活"), nameText))
                else
                    local cost = self.ridedata.synthetise_cost[1]
                    local num = BackpackManager.Instance:GetItemCount(cost[1])
                    if num < cost[2] then
                        local almighty_num = 0
                        local almighty_data = {}
                        for index, itemBaseId in ipairs(self.ridedata.replace_item) do
                            if num + almighty_num < cost[2] then
                                local tempNum = BackpackManager.Instance:GetItemCount(itemBaseId)
                                local tempNum2 = cost[2] - num - almighty_num
                                if tempNum2 > tempNum then
                                    tempNum2 = tempNum
                                end
                                table.insert(almighty_data, { num = tempNum2, name = BackpackManager.Instance:GetItemBase(itemBaseId).name})
                                almighty_num = almighty_num + tempNum
                            end
                        end
                        -- local almighty_num = BackpackManager.Instance:GetItemCount(23660)
                        -- local itemName = TI18N("万能坐骑元神")
                        -- if self.ridedata.index == 2 then
                        --     almighty_num = BackpackManager.Instance:GetItemCount(23669)
                        --     itemName = TI18N("<color='#ffff00'>稀有万能坐骑元神</color>")
                        -- end

                        -- local hasNum = 0
                        -- if self.ridedata.id == 2018 then
                        --     hasNum = num
                        -- else
                        --     hasNum = num + almighty_num
                        -- end

                        -- if hasNum < cost[2] then
                        if num + almighty_num < cost[2] then
                            NoticeManager.Instance:FloatTipsByString("您没有足够的合成道具，攒够了再来吧")
                        else
                            local data = NoticeConfirmData.New()
                            data.type = ConfirmData.Style.Normal
                            local confirmString = ""
                            for index, almightyData in ipairs(almighty_data) do
                                if index == 1 then
                                    confirmString = string.format(TI18N("%s个%s"), almightyData.num, almightyData.name)
                                else
                                    confirmString = string.format(TI18N("%s、%s个%s"), confirmString, almightyData.num, almightyData.name)
                                end
                            end
                            data.content = string.format(TI18N("碎片不足，是否使用<color='#00ff00'>%s</color>激活幻化？"), confirmString)
                            -- data.content = string.format(TI18N("碎片不足，是否使用<color='#00ff00'>%s个</color>%s激活幻化？"), itemName, cost[2] - num)
                            data.sureLabel = TI18N("确定")
                            data.cancelLabel = TI18N("取消")
                            data.sureCallback = function() RideManager.Instance:Send17019(self.ridedata.id) end
                            NoticeManager.Instance:ConfirmTips(data)
                        end
                    else
                        RideManager.Instance:Send17019(self.ridedata.id)
                    end
                end
            end
        end
    end
end

function RideView_Transformation:OnTimer()
    local time = self.ridedata.expire_time - BaseUtils.BASE_TIME
    if time <= 0 then
        self.timeText.text = TI18N("<color='#ffff00'>已过期</color>")
        self:update()
    else
        local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(time)
        if my_date ~= 0 then
            self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余时间：%s天</color>"), my_date)
        elseif my_hour ~= 0 then
            self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余时间：%s小时</color>"), my_hour)
        elseif my_minute ~= 0 then
            self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余时间：%s分钟</color>"), my_minute)
        elseif my_second ~= 0 then
            self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余时间：%s秒</color>"), my_second)
        end
    end
end


function RideView_Transformation:OnTransfigurationButtonClick()
    if self.transfigurationButtonStatus == true then
        self.transfigurationButtonStatus = false
    elseif self.transfigurationButtonStatus == false then
        self.transfigurationButtonStatus = true
    end
    local transform = self.modelPanel.transform
    local preview = transform:FindChild("Preview")

    if self.firstEffect == nil then
        self.firstEffect = BibleRewardPanel.ShowEffect(20436, preview.gameObject.transform, Vector3.one, Vector3(0,-50, -400))
    end
     self.firstEffect:SetActive(false)
    self.firstEffect:SetActive(true)

    self.effectTimerId = LuaTimer.Add(1000, function() self:TimerDelay() end)

end

function RideView_Transformation:TimerDelay()
    local transfigurationData = RideManager.Instance.model:GetTransfigurationData(self.ridedata.id)
    if transfigurationData ~= nil then
        RideManager.Instance:Send17030(self.ridedata.id)
    end
    self:Update_Transfiguration()
    self:update_modelPanel()
    self:Update_TransfigurationInfoPanel()
end

function RideView_Transformation:OnSwitchButtonClick()
    -- if self.showType == 1 then
    --     self.showType = 2
    -- else
    --     self.showType = 1
    -- end

    -- if self.showType == 1 then
    --     self.attrPanel:SetActive(true)
    --     self.infoPanel:SetActive(true)
    --     self.dyeSelectPanel:SetActive(false)
    --     self.dyeInfoPanel:SetActive(false)
    --     self.dyeNoActiveInfoPanel:SetActive(false)

    --     self:update_attrPanel()
    --     self:update_infoPanel()
    --     self:update_modelPanel()
    -- else
    --     self.attrPanel:SetActive(false)
    --     self.infoPanel:SetActive(false)
    --     self.dyeSelectPanel:SetActive(true)
    --     if self.ridedata.active then
    --         self.dyeInfoPanel:SetActive(true)
    --         self.dyeNoActiveInfoPanel:SetActive(false)
    --     else
    --         self.dyeInfoPanel:SetActive(false)
    --         self.dyeNoActiveInfoPanel:SetActive(true)
    --     end

    --     self.desc:SetActive(false)

    --     self:update_dyeSelectPanel()
    --     self:update_dyeInfoPanel()
    --     self:update_modelPanel()
    -- end

    self.model:OpenRideDyeWindow({ self.ridedata.id, self.ridedata.active })
end

function RideView_Transformation:OnSelectColor(isColor, isLeft)
    local data_ride_dye = DataMount.data_ride_dye[self.ridedata.id]
    if data_ride_dye == nil then
        return
    end

    local color_length = #data_ride_dye.color_name
    local effect_length = #data_ride_dye.effect_name

    if isColor then
        if isLeft then
            self.colorIndex = self.colorIndex - 1
        else
            self.colorIndex = self.colorIndex + 1
        end
    else
        if isLeft then
            self.effectIndex = self.effectIndex - 1
        else
            self.effectIndex = self.effectIndex + 1
        end
    end

    if color_length ~= 0 then
        if self.colorIndex <= 0 then
            self.colorIndex = self.colorIndex + color_length
        end
        if self.colorIndex > color_length then
            self.colorIndex = self.colorIndex % color_length
        end
    end
    if effect_length ~= 0 then
        if self.effectIndex <= 0 then
            self.effectIndex = self.effectIndex + effect_length
        end
        if self.effectIndex > effect_length then
            self.effectIndex = self.effectIndex % effect_length
        end
    end

    self:update_dyeSelectPanel()

    self:update_modelPanel()
end

function RideView_Transformation:OnDyeColor()
    if self.ridedata.active then
        self.model:OpenRideDyeWindow({ self.ridedata.id, self.ridedata.active })
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("获得该幻化才可进行染色哟{face_1, 22}"))
    end
end

function RideView_Transformation:ResetDyeColor()

end

function RideView_Transformation:SetColorAndEffectIndex()
    if self.ridedata ~= nil then
        local dye_id = self.model:GetTransformationDye(self.ridedata.id)
        for key, value in pairs(DataMount.data_ride_dye_preview) do
            if dye_id == value.dye_id then
                self.colorIndex = value.color_id
                self.effectIndex = value.effect_id
            end
        end
    end
end
