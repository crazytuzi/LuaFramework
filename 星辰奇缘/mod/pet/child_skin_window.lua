-- @author hze
-- @date #18/03/15#
-- 子女皮肤
ChildSkinWindow = ChildSkinWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ChildSkinWindow:__init(model)
    self.model = model
    self.name = "ChildSkinWindow"
    self.windowId = WindowConfig.WinID.ChildSkinWindow
    -- self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible
    --
    self.resList = {
        {file = AssetConfig.childskinwindow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.playkillbgcycle, type = AssetType.Dep}
        ,{file = AssetConfig.childhead, type = AssetType.Dep}
        ,{file = AssetConfig.childrentextures, type = AssetType.Dep}

        , {file = AssetConfig.petskinwindow_bg , type = AssetType.Dep}
        , {file = AssetConfig.petskinwindow_bg1, type = AssetType.Dep}
        , {file = AssetConfig.petskinwindow_bg2, type = AssetType.Dep}


    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.headlist = {}
    self.headLoaderList = {}
    self.petnum_max = 0

    self.attrItemList = {}


    self.attrTextList = {}
    self.onButtonType = 1        --按钮Type

    self.selectSkinIndex = 1         --当前索引

    self.actionIndexPlayAction = 1
    self.timeIdPlayAction = nil

    self.skinIndexList = {}     --皮肤序号列表
    self.SkinBtnList = {}       --皮肤按钮列表
    self.itemLossList = {}      --消耗道具列表

    self.flag = 1

    self.coldStatus = false

    --按钮对应皮肤序号初始值
    self.btn_index = { 3, 1, 2, 3, 1 }

    ------------------------------------------------
    self._OnUpdate = function()
        self:OnUpdate()
    end

    self._ReloadCurrSkinData = function()
        self:UpdateHeadBar()
    end

    self._OnPricesBack = function(prices)
        self:OnPricesBack(prices)
    end

    self.reloadIconDatalistener = function()
        self:ReloadIconData()
    end

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.headList = {}
end

function ChildSkinWindow:__delete()
    self:OnHide()
    if self.timer1 ~= nil then
        LuaTimer.Delete(self.timer1)
        self.timer1 = nil
    end

    if self.timeIdPlayAction ~= nil then
        LuaTimer.Delete(self.timeIdPlayAction)
        self.timeIdPlayAction = nil
    end

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end

    if self.itemLossList ~= nil then
        for k,v in ipairs(self.itemLossList) do
            v:DeleteMe()
            v = nil
        end
        self.itemLossList = nil
    end

    if self.itemLayout ~= nil then
        self.itemLayout:DeleteMe()
        self.itemLayout = nil
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end

    if self.buyButton ~= nil then
        self.buyButton:DeleteMe()
        self.buyButton = nil
    end

    if self.timeId_PlayIdleAction ~= nil then
        LuaTimer.Delete(self.timeId_PlayIdleAction)
        self.timeId_PlayIdleAction = nil
    end

    BaseUtils.ReleaseImage(self.mainTransform:Find("Info/Image"):GetComponent(Image))
    BaseUtils.ReleaseImage(self.info:Find("ModelBg/Image"):GetComponent(Image))
    BaseUtils.ReleaseImage(self.info:Find("ModelBg"):GetComponent(Image))



    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ChildSkinWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childskinwindow))
    self.gameObject.name = "ChildSkinWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:Find("Info/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petskinwindow_bg, "ChildSkinBg")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    --右边四个tab键
    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0, 0, 68},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting, { notAutoSelect = true })

    --里面两个tab键
    self.tabGroupObj2 = self.mainTransform:FindChild("Info/TabButtonGroup").gameObject
    self.tabGroup2 = TabGroup.New(self.tabGroupObj2, function(index) self:ChangeTab2(index) end, { notAutoSelect = true })

    --天赋键
    self.telnetButton = self.mainTransform:FindChild("Info/TelnetButton"):GetComponent(Button)
    self.telnetButton.onClick:AddListener(function()
        if self.lock then
            local info = {child = PetManager.Instance.model.currChild}
            self.model.mySubIndex = 1
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_change_telnet, info)
            return
        else
            self:ChangeTab2(3)
        end
    end)
    self.telnetButton.gameObject:SetActive(true)
    self.telnetButtonRedPoint = self.telnetButton.transform:FindChild("RedPoint").gameObject

    --附灵键
    self.spiritButton = self.mainTransform:FindChild("Info/SpiritButton"):GetComponent(Button)
    self.spiritButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.childSpirtWindow) end)
    --皮肤键
    self.skinButton = self.mainTransform:FindChild("Info/SkinButton"):GetComponent(Button)
    self.skinButton.transform:FindChild("Select").gameObject:SetActive(true)
    self.skinButton.transform:FindChild("Normal").gameObject:SetActive(false)

    ----------------------------------------------------------------------------
    --左边滚动Bar
    self.container = self.mainTransform:Find("HeadChildBar/mask/HeadContainer").gameObject
    self.childHeabarBaseItem = self.container.transform:Find("PetHead").gameObject
    self.childHeabarBaseItem.gameObject:SetActive(false)
    for i = 1, 6 do
        local index = i
        local item = PetChildHeadItem.New(GameObject.Instantiate(self.childHeabarBaseItem),self, index)
        item:ShowAdd()
        table.insert(self.headList, item)
    end

    -----------------------------------------------------------------------------
     --info面板
    self.info = self.mainTransform:FindChild("Info")

    self.info:Find("ModelBg/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petskinwindow_bg1, "ChildSkinBg1")
    self.info:Find("ModelBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.petskinwindow_bg2, "ChildSkinBg2")

    --消耗物品
    self.itemContainer = self.info:FindChild("ItemContainer")

    --皮肤标题、名字
    self.titleText = self.info:FindChild("ModelBg/Title/NameText"):GetComponent(Text)
    self.titleImage = self.info:FindChild("ModelBg/Title/Image").gameObject

    --皮肤属性
    self.skinAttrObject = self.info:FindChild("SkinAttr").gameObject
    self.skinAttrRectTransform = self.skinAttrObject:GetComponent(RectTransform)
    for i = 1, 5 do
        table.insert(self.attrTextList, self.skinAttrObject.transform:FindChild("AttrText" .. i):GetComponent(Text))
    end

    --选中、使用效果
    self.skinTick = self.info:FindChild("SkinTick")
    self.select = self.info:FindChild("Select")

    --对白
    self.dialogueTxt = self.info:FindChild("StoryButton/Text"):GetComponent(Text)
    self.dialogueTxt.alignment = 0
    self.dialogueTxt.transform.anchoredPosition = Vector2(21,-33)
    self.dialogueTxt.transform.pivot = Vector2(0,1)
    self.contentTxt = MsgItemExt.New(self.dialogueTxt, 100, 16, 20)
    self.dialogueTxt.transform.parent.gameObject:SetActive(false)

    --剩余时间
    self.timeTxt = self.info:FindChild("TimeArea/TimeTxt"):GetComponent(Text)
    self.timeTxt.transform.sizeDelta = Vector2 (145,28)
    self.timeTxt.transform.anchoredPosition = Vector2(63,0)

    --子女皮肤模型
    local setting = {
        name = "ChildSkinView",
        orthographicSize = 0.8,
        width = 341,
        height = 341,
        offsetY = - 0.4
    }
    self.previewComposite = PreviewComposite.New(nil, setting, { })
    self.previewComposite:BuildCamera(true)
    self.rawImage = self.previewComposite.rawImage
    self.rawImage.transform:SetParent(self.transform)
    self.rawImage.gameObject:SetActive(false)
    self.modelPreview = self.info:FindChild("ModelBg/Preview")
    self.modelPreview.transform.anchoredPosition = Vector2(0,3)


    self.skinBtnContainer = self.info:Find("Scroll/SkinBtnContainer")
    --皮肤按钮

    for i = 1, 5 do
        if self.SkinBtnList[i] == nil then
            local tab = {}
            tab.obj = self.info:FindChild(string.format("Scroll/SkinBtnContainer/Item%s",i))
            tab.item = tab.obj:Find("SkinButton")
            tab.item:GetComponent(Button).onClick:RemoveAllListeners()
            tab.item:GetComponent(Button).onClick:AddListener( function() self:OnSkinButtonClick(i) end)
            tab.notactive = tab.item:Find("NotActive"):GetComponent(Image)
            tab.used = tab.item:Find("Used").gameObject
            tab.selected = tab.item:Find("Selected").gameObject
            tab.goldexclusive = tab.item:Find("Special"):GetComponent(Image)
            tab.icon = tab.item:Find("Icon"):GetComponent(Image)

            self.SkinBtnList[i] = tab
        end
    end

    local btn = self.info:FindChild("ModelBg/Preview").gameObject:AddComponent(Button)
    btn.onClick:AddListener( function() if self.previewComposite ~= nil and self.previewComposite.tpose ~= nil then self:PlayAction() end end)

    --激活按钮
    self.buyButton = BuyButton.New(self.info:FindChild("OkButton"), TI18N("激 活"), false)
    self.buyButton.key = "ChildSkinActivate"
    self.buyButton:Show()

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function ChildSkinWindow:__DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:OnClickClose()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end


function ChildSkinWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
end

function ChildSkinWindow:OnShow()
    self:Init()
    PetManager.Instance.OnUpdatePetList:Add(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Add(self._OnUpdate)
    ChildrenManager.Instance.OnChildDataUpdate:AddListener(self._ReloadCurrSkinData)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.reloadIconDatalistener)

    ChildrenManager.Instance:Require18600()
    self.currIndex = 0
    self.tabGroup:ChangeTab(4)
end

function ChildSkinWindow:OnHide()
    PetManager.Instance.OnUpdatePetList:Remove(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Remove(self._OnUpdate)
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self._ReloadCurrSkinData)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.reloadIconDatalistener)
end

function ChildSkinWindow:Update()
    self:UpdateHeadBar()
end

function ChildSkinWindow:OnUpdate()
    self:Update()
end

function ChildSkinWindow:UpdateHeadBar()
    local childlist = ChildrenManager.Instance.childData
    local list = {}

    for k,v in pairs(childlist) do
        if v.stage == 3 then
            table.insert(list,v)
        end
    end

    table.sort(list, function(a,b)
            if a.stage == b.stage then
                return a.child_id < b.child_id
            else
                return a.stage > b.stage
            end
        end)

    if #list > 0 then
        for i,item in ipairs(self.headList) do
            local dat = list[i]
            if dat ~= nil then
                dat.attach_pet_ids = {}
                for i = 1, #PetManager.Instance.model.petlist do
                    local data = PetManager.Instance.model.petlist[i]
                    if data.spirit_child_flag == 1 then
                        if data.child_id == dat.child_id and data.platform == dat.platform and data.zone_id == dat.zone_id then
                            table.insert(dat.attach_pet_ids,data.id)
                        end
                    end
                end
                item:SetData(dat)
                if #dat.attach_pet_ids > 0 then
                    item.transform:FindChild("AttachHeadIcon").gameObject:SetActive(true)
                    local attach_pet_id = dat.attach_pet_ids[1]
                    local attach_pet_data = self.model:getpet_byid(attach_pet_id)
                    local headId = tostring(attach_pet_data.base.head_id)
                    local loaderId = item.gameObject:GetInstanceID()
                    if self.headLoaderList[loaderId] == nil then
                        self.headLoaderList[loaderId] = SingleIconLoader.New(item.transform:FindChild("AttachHeadIcon/Image").gameObject)
                    end
                    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
                else
                    item.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)
                end
            else
                item:ShowAdd()
            end
        end
    else
    end
    self.currIndex = PetManager.Instance.model.currIndex or 0
    if #list > 0 then
        if self.currIndex == 0 then
            self.currIndex = 1
        end
        self.headList[self.currIndex]:ClickSelf()
    end
end

function ChildSkinWindow:UpdateTabGroup()
    self.lock = false
    table.sort(self.child.talent_skills, function(a,b) return a.grade < b.grade end)
    if self.child ~= nil and #self.child.talent_skills == 0 then
        self.lock = true
    elseif self.child ~= nil and #self.child.talent_skills >= 1 and self.child.talent_skills[1].id == 0 then
        self.lock = true
    end

    if self.lock then
        self.model.mySubIndex = 1
        self.tabGroup2.cannotSelect = {false, false, true}
    else
        self.tabGroup2.cannotSelect = {false, false, false}
    end


    if DataChild.data_child_condition[1].need_lev > RoleManager.Instance.RoleData.lev then
        self.spiritButton.gameObject:SetActive(false)
    else
        self.spiritButton.gameObject:SetActive(true)
    end
end


function ChildSkinWindow:ChangeTab(index)
    if index ~= 4 then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {index})
    end
end

function ChildSkinWindow:ChangeTab2(index)
    WindowManager.Instance:CloseWindow(self)
    -- print("发送消息=================================================" .. index)
    self.model.childVewIndex = index
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4, index})
end



function ChildSkinWindow:onOkButtonClick()
    local data_child_skin = DataChild.data_child_skin[self.selectSkinIndex]
    if data_child_skin == nil then return end
    data_child_skin.cost = data_child_skin.cost or {}

    if self.onButtonType == 2 then
        ChildrenManager.Instance:Send18643(self.model.currChild.child_id, self.model.currChild.platform, self.model.currChild.zone_id,data_child_skin.skin_id)
    elseif self.onButtonType == 3 or self.onButtonType == 1 then
        local temp = 0
        for k,v in pairs(data_child_skin.cost) do
            local backpack_num = BackpackManager.Instance:GetItemCount(v[1])
            if v[2] <= backpack_num then
                temp = temp + 1
            end
        end

        if temp == #data_child_skin.cost then
            if self.onButtonType == 1 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("%s已经激活，是否消耗{assets_2,%d}%s延长30天"),data_child_skin.skin_name,data_child_skin.cost[1][1],DataItem.getData[data_child_skin.cost[1][1]].name)
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    ChildrenManager.Instance:Send18642(self.model.currChild.child_id, self.model.currChild.platform, self.model.currChild.zone_id,data_child_skin.skin_id)
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                ChildrenManager.Instance:Send18642(self.model.currChild.child_id, self.model.currChild.platform, self.model.currChild.zone_id,data_child_skin.skin_id)
            end
        else
                local itemData = ItemData.New()
                local basedata = DataItem.data_get[data_child_skin.cost[1][1]]
                itemData:SetBase(basedata)
                TipsManager.Instance:ShowItem({gameObject = nil, itemData = itemData, extra = { inbag = false, nobutton = false }})
                -- NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
        end
    end
end


function ChildSkinWindow:Init()
    self.coldStatus = false
    -- BaseUtils.dump(PetManager.Instance.model.currChild,"当前孩子数据")
    self:UpdatePos()
end


function ChildSkinWindow:OnSkinButtonClick(index,is_init)

    if index == 3 and not is_init then return end

    if self.coldStatus then return end
    self.coldStatus = true

     --当前孩子的皮肤序号列表
    self.skinIndexList = {}
    for key, value in pairs(DataChild.data_child_skin) do
        if self.model.currChild.sex == value.sex then
            table.insert(self.skinIndexList,value.skin_id)
        end
    end

    table.sort(self.skinIndexList,function(a,b) return a < b end)
    -- BaseUtils.dump(self.skinIndexList,"【皮肤序号")

    -- if index == 3 then return end
    --设置按钮和皮肤的对应关系
    local temp = self.btn_index[index] or 2
    for i = 3, 1, -1 do
        self.btn_index[i] = temp
        temp = (temp - 1) % 3
        if temp == 0 then temp = 3 end
    end

    temp = self.btn_index[3]
    for i = 3, 5 do
        self.btn_index[i] = temp
        temp = temp % 3 + 1
    end

    -- BaseUtils.dump(self.btn_index,"按钮和皮肤对应关系表")
    self.selectSkinIndex = self.skinIndexList[self.btn_index[3]]   --当前选中的永远都是3

    self.SkinBtnList[index].selected:SetActive(true)
    self.SkinBtnList[3].selected:SetActive(false)
    -- print(self.selectSkinIndex)
    self:TweenTo(index,is_init)

end

function ChildSkinWindow:UpdateBase()

    --当前选中的皮肤数据
    local data_child_skin  = DataChild.data_child_skin[self.selectSkinIndex]

    if data_child_skin == nil then Debug.Log(string.format("子女皮肤表序号%s项为空",self.selectSkinIndex)) return end

    -- 对白



    --资质效果
    local attrList = { }
    if data_child_skin.phy_aptitude ~= 0 and data_child_skin.pdef_aptitude ~= 0 and data_child_skin.hp_aptitude ~= 0 and data_child_skin.magic_aptitude ~= 0 and data_child_skin.aspd_aptitude ~= 0 then
        table.insert(attrList, string.format(TI18N("全部资质<color='#00ff00'>+%s</color>"), data_child_skin.phy_aptitude))
    else
        if data_child_skin.phy_aptitude ~= 0 then
            table.insert(attrList, string.format(TI18N("物攻资质<color='#00ff00'>+%s</color>"), data_child_skin.phy_aptitude))
        end
        if data_child_skin.pdef_aptitude ~= 0 then
            table.insert(attrList, string.format(TI18N("物防资质<color='#00ff00'>+%s</color>"), data_child_skin.pdef_aptitude))
        end
        if data_child_skin.hp_aptitude ~= 0 then
            table.insert(attrList, string.format(TI18N("生命资质<color='#00ff00'>+%s</color>"), data_child_skin.hp_aptitude))
        end
        if data_child_skin.magic_aptitude ~= 0 then
            table.insert(attrList, string.format(TI18N("法力资质<color='#00ff00'>+%s</color>"), data_child_skin.magic_aptitude))
        end
        if data_child_skin.aspd_aptitude ~= 0 then
            table.insert(attrList, string.format(TI18N("速度资质<color='#00ff00'>+%s</color>"), data_child_skin.aspd_aptitude))
        end
    end
    if data_child_skin.growth ~= 0 then
        table.insert(attrList, string.format(TI18N("成长<color='#00ff00'>+%s</color>"), string.format("%.2f", data_child_skin.growth / 500)))
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


    --皮肤名字和标题
    if data_child_skin.skin_name ~= nil then
        self.titleText.text = string.format("<color='#fafa00'>%s</color>", data_child_skin.skin_name)
    end

    --模型
    self:UpdateModel()


    -- 图标设置
    for i,v in ipairs(self.SkinBtnList) do
        v.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures,tostring(DataChild.data_child_skin[self.skinIndexList[self.btn_index[i]]].skin_icon))
        v.notactive.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures,tostring(DataChild.data_child_skin[self.skinIndexList[self.btn_index[i]]].skin_icon))
        v.goldexclusive.transform.gameObject:SetActive(DataChild.data_child_skin[self.skinIndexList[self.btn_index[i]]].goldexclusive == 1)
    end
    ----------------------协议改变-----------------------------------------------------
    self:ReloadIconData()
end

function ChildSkinWindow:UpdateModel()
    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local currChild = self.model.currChild
    local childData = DataChild.data_child[currChild.base_id]

    local skinId = 0
    local modelId = 0
    local animationId = 0
    local effects = {}

    if childData ~= nil then
        -- self.previewName.text = self.child.name
        if currChild.grade == 0 then
            skinId = childData.skin_id_0
            modelId = childData.model_id
        elseif currChild.grade == 1 then
            skinId = childData.skin_id_1
            modelId = childData.model_id1
        elseif currChild.grade == 2 then
            skinId = childData.skin_id_2
            modelId = childData.model_id2
        elseif currChild.grade == 3 then
            skinId = childData.skin_id_3
            modelId = childData.model_id3
        end
        animationId = childData.animation_id
        effects = childData.effects_0
    end

    local data_child_skin = DataChild.data_child_skin[self.selectSkinIndex]

    if data_child_skin ~= nil then
        skinId = data_child_skin.texture
        modelId = data_child_skin.model_id
        animationId = data_child_skin.animation_id
    end

    local data = {type = PreViewType.Pet, skinId = skinId, modelId = modelId, animationId = animationId, effects = effects, scale = 1.7}

    self.previewComposite:Reload(data, callback)
    self.modelData = data
end


function ChildSkinWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.modelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.Euler(0,336,0)
    -- composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.LeftForward, 0))
    --Quaternion.identity

    if self.timeId_PlayIdleAction ~= nil then LuaTimer.Delete(self.timeId_PlayIdleAction) end
    self.timeId_PlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayIdleAction() end)
end

function ChildSkinWindow:ChangeDialog()
    local data_child_skin = DataChild.data_child_skin[self.selectSkinIndex]
    if data_child_skin ~= nil and data_child_skin.dialogue1 ~= nil and data_child_skin.dialogue2 ~= nil then
    self.flag = self.flag % 2 + 1
    if self.flag == 1 then
        self.contentTxt:SetData(data_child_skin.dialogue1)
    else
        self.contentTxt:SetData(data_child_skin.dialogue2)
    end
    self.dialogueTxt.transform.parent.gameObject:SetActive(false)
    end
    if self.dialogueTxt.transform ~= nil then
        self.dialogueTxt.transform.parent.gameObject:SetActive(true)
    end
    if self.timer1 ~= nil then LuaTimer.Delete(self.timer1) end
    self.timer1 = LuaTimer.Add(2000,function() self.dialogueTxt.transform.parent.gameObject:SetActive(false) end )
end

function ChildSkinWindow:PlayIdleAction()
    if self.timeIdPlayAction == nil and self.previewComposite ~= nil and self.previewComposite.tpose ~= nil then
        self.previewComposite:PlayMotion(FighterAction.Idle)
    end
end

function ChildSkinWindow:PlayAction()
    self:ChangeDialog()
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


function ChildSkinWindow:TweenTo(index,is_init)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end

    local tweenTime = 0.5
    if is_init then tweenTime = 0 end

    self.tweenId = Tween.Instance:ValueChange(self.skinBtnContainer.anchoredPosition.y, 90*(index - 3), tweenTime,
        function()
            self.tweenId = nil
            self.SkinBtnList[index].selected:SetActive(false)
            self.SkinBtnList[3].selected:SetActive(true)
            self.skinBtnContainer.anchoredPosition = Vector2(0,0)
            self:UpdatePos()
            self:UpdateBase()
            self.coldStatus = false
        end
        , LeanTweenType.easeOutQuart,
        function(value)
            self.skinBtnContainer.anchoredPosition = Vector2(0, value)
            self:UpdatePos()
        end).id
end

function ChildSkinWindow:UpdatePos()
    local y = nil
    local xx = nil
    for i,v in ipairs(self.SkinBtnList) do
        y = v.obj.anchoredPosition.y  + self.skinBtnContainer.anchoredPosition.y

        xx = 1 - ((y)*(y) / (180*180))
        if xx >= 0 then
            local x = math.sqrt(xx) * 180 - 90 - 70
            v.item.anchoredPosition = Vector2(x, 0)
            local value = (1 - (y) * (y)/(180*180))

            if value < 0.9 then
                value = 0.9
            end
            v.item.localScale = Vector2(value + 0.1,value + 0.1,0)
        end
    end

end

--重新加载按钮图标
function ChildSkinWindow:ReloadIconData()
    --当前孩子的皮肤数据
    -- local child_skin_info = self.model.currChild.child_skin or {}
    -- BaseUtils.dump(child_skin_info,"当前孩子的皮肤数据")
    local skin_active = false
    local skin_used = false
    local duration_time = 0

    --当前选中的皮肤数据
    local data_child_skin  = DataChild.data_child_skin[self.selectSkinIndex] or {}

    local child_skin_info = self:ExpireCheck()
    -- BaseUtils.dump(child_skin_info,"当前孩子的皮肤数据")

    for k,v in ipairs(child_skin_info) do
        if data_child_skin.skin_id == v.skin_id then
            skin_active = true
            skin_used = (v.skin_active_flag == 2)
            duration_time = v.expire_time
        end
    end

    for k,v in ipairs(self.SkinBtnList) do
        local temp = false
        local tempused = false
        for i,value in ipairs(child_skin_info) do
            if value.skin_id == self.skinIndexList[self.btn_index[k]] then
                if value.skin_active_flag == 2 then
                    tempused = true
                end
                temp = true
                break
            end
        end
        --判断是否激活，正在使用
        self.SkinBtnList[k].notactive.gameObject:SetActive(not temp)
        if temp then
            self.SkinBtnList[k].goldexclusive.color = Color(1, 1, 1, 1)
        else
            self.SkinBtnList[k].goldexclusive.color = Color(174/255, 174/255, 174/255, 1)
        end
        self.SkinBtnList[k].used:SetActive(tempused)
    end



    --剩余时间
    if duration_time == 0 then duration_time = os.time() end
    if duration_time > os.time() then
        local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(duration_time - os.time())
        -- print(string.format("%s,%s,%s,%s",my_date, my_hour, my_minute, my_second))
        local timestr = ""
        self.timeTxt.transform.gameObject:SetActive(true)
        if my_date > 0 then
            timestr = string.format(TI18N("%s天"), my_date)
            self.timeTxt.text = string.format(TI18N("剩余时间：%s"),timestr)
        elseif my_hour > 0 then
            timestr = string.format(TI18N("%s时"), my_hour)
            self.timeTxt.text = string.format(TI18N("剩余时间：%s"),timestr)
        elseif my_minute > 0 or my_second > 0 then
            self.timeTxt.text = TI18N("剩余时间:不足1小时")
        else
            self.timeTxt.transform.gameObject:SetActive(false)
        end
    else
        self.timeTxt.transform.gameObject:SetActive(false)

    end

    --下方item变化  (策划gank不要了)
    local need_list = {}
    local item_index = 1
    data_child_skin.cost = data_child_skin.cost or {}

    for i,v in ipairs (data_child_skin.cost) do
        if self.itemLossList[i] == nil then
            local obj = ItemSlot.New()
            obj.transform:SetParent(self.itemContainer:Find(string.format("ItemSlot%s",i)))
            obj.transform.localScale = Vector3(1, 1, 1)
            obj.transform.localPosition = Vector3(0, 0, 0)
            self.itemLossList[i] = obj
        end
        local itemData = ItemData.New()
        itemData:SetBase(BackpackManager.Instance:GetItemBase(v[1]))
        itemData.need = v[2]
        itemData.quantity = BackpackManager.Instance:GetItemCount(v[1])
        self.itemLossList[i]:SetAll(itemData)
        self.itemLossList[i].gameObject:SetActive(true)
        need_list = { [v[1]] = { need = v[2] } }
        item_index = i + 1
    end

    for i = item_index, #(self.itemLossList) do
        self.itemLossList[i].gameObject:SetActive(false)
    end


    --按钮文本
    if not skin_active then
        self.buyButton:Set_btn_txt(TI18N("激  活"))
        self.onButtonType = 3
        self.buyButton.protoId = 18643
        self.buyButton:Layout( {}, function() self:onOkButtonClick() end, self._OnPricesBack, { antofreeze = false })
    elseif skin_used then
        self.buyButton:Set_btn_txt(TI18N("续  费"))
        self.onButtonType = 1
        self.buyButton.protoId = 18642
        self.buyButton:Layout( {}, function() self:onOkButtonClick() end, self._OnPricesBack, { antofreeze = false })
    else
        self.buyButton:Set_btn_txt(TI18N("使  用"))
        self.onButtonType = 2
        self.buyButton:Layout( {}, function() self:onOkButtonClick() end, self._OnPricesBack, { antofreeze = false })
    end

    self.model.lastSkinIndex = self.btn_index[3]
end

function ChildSkinWindow:ResetSkinBtn()
    --重置所有按钮的状态
    for i,v in ipairs(self.SkinBtnList) do
        v.notactive.gameObject:SetActive(false)
        v.used:SetActive(false)
    end
end

function ChildSkinWindow:OnPricesBack(prices)
    -- BaseUtils.dump(prices, "prices")
end

function ChildSkinWindow:OpenGetChildWindow()
    local args = { }
    local data_child_skin = DataChild.data_child_skin[self.selectSkinIndex]
    if data_child_skin ~= nil then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)

        args.petId = self.model.currChild.base_id
        args.grade = self.model.currChild.grade
        args.genre = self.model.currChild.genre
        args.use_skin = data_child_skin.skin_id
        args.platform = self.model.currChild.platform
        args.zone_id = self.model.currChild.zone_id
        args.child_id = self.model.currChild.child_id

        self.model:OpenGetChildWindow(args)
    end
end

function ChildSkinWindow:ExpireCheck()
    local child_skin_info = self.model.currChild.child_skin or {}
    for i = #child_skin_info,1,-1 do
        if child_skin_info[i].expire_time < os.time() then
            table.remove(child_skin_info,i)
        end
    end
    return child_skin_info
end


function ChildSkinWindow:SelectOne(item)
            -- 正常跳转
    PetManager.Instance.model.currChild = item.data
    PetManager.Instance.model.currIndex = item.index
    if self.currItem ~= nil then
        self.currItem:Select(false)
    end
    self.currItem = item
    self.currIndex = self.currItem.index
    self.currItem:Select(true)

    self:ResetSkinBtn()
    local lastBtnindex = 3
    for i = 2,4 do
        if self.btn_index[i] == self.model.lastSkinIndex then
            lastBtnindex = i
            break
        end
    end
    -- print(lastBtnindex)
    self:OnSkinButtonClick(lastBtnindex,true)
end
