-- @author 黄耀聪
-- @date 2016年9月18日
-- 自定义头像
---
PortraitWindow = PortraitWindow or BaseClass(BaseWindow)

--第二个参数为是否激活自定义头像框显示，默认为false
function PortraitWindow:__init(model)
    self.model = model
    self.name = "PortraitWindow"
    self.windowId = WindowConfig.WinID.portraitwindow
    -- self.cacheMode = CacheMode.Visible
    self.mgr = PortraitManager.Instance
    -- self.nowTabIndex = 1
    self.resList = {
        {file = AssetConfig.portrait_window, type = AssetType.Main},
        {file = AssetConfig.portrait_textures, type = AssetType.Dep},
        {file = AssetConfig.bigatlas_taskBg, type = AssetType.Main},
        {file = AssetConfig.playkillbgcycle, type = AssetType.Dep},
        {file = AssetConfig.head_custom_specail, type = AssetType.Main},
    }

    self.currentSelect = 0  -- 当前选择第几套头像
    self.currentClassSelect = {}    --当前每一类的选择序号
    self.typeFileList = {
        AssetConfig.head_custom_hair,
        AssetConfig.head_custom_face,
        AssetConfig.head_custom_bg,
        AssetConfig.head_custom_wear,
    }
    self.titleString = TI18N("头 像")

    self.headList = {}
    self.assetListener = function() self:OnAsset() end
    self.updateListener = function() self:Update() end

    self.classList =
    {
        [1] = {name = "头像",id = 1,icon_name = "Icon1", package = AssetConfig.portrait_textures},
        [2] = {name = "头像框",id = 2,icon_name = "Icon2", package = AssetConfig.portrait_textures},
        -- [3] = {name = "典藏室",id = 3,package = AssetConfig.fashionres, icon_name = "Icon2"}
    }
    self.extra = {inbag = false, nobutton = true}

    self.tabObjList = {}
    self.tabRedPoint = {}
    self.txtList = {}
    self.contentList = {}
    self.assesWayList = {}
    self.extra = {inbag = false, nobutton = true}

    self.currentTabIndex = 1
    self.lastPhotoFrame  = nil
    self.nowType = 1
    self.isMyOpen = false


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PortraitWindow:__delete()
    self.OnHideEvent:Fire()
    self.numToTab1 = nil
    if self.lineList ~= nil then
        for _,line in pairs(self.lineList) do
            for _,item in pairs(line.items) do
                item.specailIcon.sprite = nil
                item.image.sprite = nil
            end
        end
    end

    if self.assesLayout ~= nil then
        self.assesLayout:DeleteMe()
        self.assesLayout = nil
    end

    if  self.tabLayout ~= nil then
         self.tabLayout:DeleteMe()
         self.tabLayout = nil
    end



    if self.assesItemSlot ~= nil then
        self.assesItemSlot:DeleteMe()
        self.assesItemSlot = nil
    end

    if self.tabList ~= nil then
        for _,v in pairs(self.tabList) do
            if v ~= nil then
                v.iconImage.sprite = nil
            end
        end
    end
    if self.headList ~= nil then
        for _,v in pairs(self.headList) do
            if v ~= nil then
                v.headSlot:DeleteMe()
            end
        end
        self.headList = nil
    end
    if self.selectLayout ~= nil then
        self.selectLayout:DeleteMe()
        self.selectLayout = nil
    end
    if self.showLayout ~= nil then
        self.showLayout:DeleteMe()
        self.showLayout = nil
    end
    if self.classTabGroup ~= nil then
        self.classTabGroup:DeleteMe()
        self.classTabGroup = nil
    end
    if self.mainHeadSlot ~= nil then
        self.mainHeadSlot:DeleteMe()
        self.mainHeadSlot = nil
    end
    if self.buyButtonImage ~= nil then
        self.buyButtonImage.sprite = nil
        self.buyButtonImage = nil
    end
    self:AssetClearAll()
end

function PortraitWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.portrait_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.closeBtn = t:Find("Main/Close"):GetComponent(Button)
    self.titleText = t:Find("Main/Title/Text"):GetComponent(Text)
    self.selectTabContainer = t:Find("Main/Horizontal/Container")
    self.selectTabCloner = t:Find("Main/Horizontal/Cloner").gameObject

    self.classTabGroup = TabGroup.New(self.selectTabContainer, function(index) self:ChangeTab(index) end, {notAutoSelect = true, noCheckRepeat = false, perWidth = 111, perHeight = 45, isVertical = false, spacing = 0})
    self.selectContainer = t:Find("Main/SelectArea/Scroll/Container")
    self.selectPanel = t:Find("Main/SelectArea")
    self.lineCloner = t:Find("Main/SelectArea/Scroll/Line").gameObject
    self.lineClonerImg = t:Find("Main/SelectArea/Scroll/Line/Item1/Bg/Image"):GetComponent(Image)
    self.selectLayout = LuaBoxLayout.New(self.selectContainer, {axis = BoxLayoutAxis.Y, cspacing = 20, border = 0})
    self.showCloner = t:Find("Main/Head/Vertival/Cloner").gameObject

    self.setting = {
        bordertop = 18
        ,borderleft = 20
        ,column = 2
        ,cspacing = 35
        ,rspacing = 15
        ,cellSizeX = 70
        ,cellSizeY = 24
    }
    self.vertivalTr = t:Find("Main/Head/Vertival")
    self.myItemBg = t:Find("Main/Head/ItemBg"):GetComponent(Image)
    self.myItemBg.sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgcycle, "PlayKillBgCycle")
    self.showLayout = LuaGridLayout.New(t:Find("Main/Head/Vertival"),self.setting)
    local myHeadLayout = LuaBoxLayout.New(t:Find("Main/Head/MyHead/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 20})
    self.myHeadCloner = t:Find("Main/Head/MyHead/Cloner").gameObject
    self.ownText = t:Find("Main/Own/Text"):GetComponent(Text)
    self.ownPanel = t:Find("Main/Own")
    self.noticeBtn = t:Find("Main/Head/Time/Notice"):GetComponent(Button)
    self.timeText = t:Find("Main/Head/Time/Left"):GetComponent(Text)
    self.recoverBtn = t:Find("Main/Head/Recover"):GetComponent(Button)
    self.recoverText = t:Find("Main/Head/Recover/I18N_Text"):GetComponent(Text)
    self.randomBtn = t:Find("Main/Head/Random"):GetComponent(Button)
    self.buyButton = t:Find("Main/Buy"):GetComponent(Button)
    self.buyButtonImage = self.buyButton.gameObject:GetComponent(Image)
    self.buyButtonText = t:Find("Main/Buy/I18N_Text"):GetComponent(Text)
    self.priceText = t:Find("Main/Price/Text"):GetComponent(Text)
    self.pricePanel = t:Find("Main/Price")
    self.priceAssesWay = t:Find("Main/AssesWay")
    self.assesItem = t:Find("Main/AssesWay/ItemSlot")
    self.assesItemSlot = ItemSlot.New(self.assesItem.gameObject)
    self.assesNameText = t:Find("Main/AssesWay/ItemSlot/SecondName"):GetComponent(Text)
    self.headSlotNameText = t:Find("Main/NameText"):GetComponent(Text)
    self.headSlotNameText.text = "相框"

    self.assesContainer = t:Find("Main/AssesWay/Mask_con/Scroll_con/Container")
    self.assesTemplater = t:Find("Main/AssesWay/Mask_con/Scroll_con/Container/GetClone")
    self.assesTemplater.gameObject:SetActive(false)

    self.assesLayout = LuaBoxLayout.New(self.assesContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5})

    self.rebuyButton = t:Find("Main/ReBuy"):GetComponent(Button)

    self.tabListPanel = self.transform:Find("Main/TabListPanel")
    self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
    self.tabTemplate.transform.sizeDelta = Vector2(55,118)
    self.tabTemplate:SetActive(false)

    self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})

    for i=1,3 do
        local tab = {}
        tab.obj = GameObject.Instantiate(self.myHeadCloner)
        tab.transform = tab.obj.transform
        tab.select = tab.transform:Find("Select").gameObject
        tab.btn = tab.obj:GetComponent(Button)
        tab.headSlot = HeadSlot.New(nil)
        tab.headSlot:SetRectParent(tab.transform:Find("Slot"))
        tab.headAddImg = tab.transform:Find("Add"):GetComponent(Image)
        tab.transform.pivot = Vector2(0, 0.5)
        myHeadLayout:AddCell(tab.obj)
        self.headList[i] = tab
        tab.select:SetActive(false)
        tab.btn.onClick:RemoveAllListeners()
        tab.btn.onClick:AddListener(function() self:OnSelectHeadSlot(i) end)
    end
    -- for i,v in ipairs(self.headList) do
    --     v.transform.pivot = Vector2(0.5, 0.5)
    -- end
    myHeadLayout:DeleteMe()
    self.titleText.text = self.titleString

    self.mainHeadSlot = HeadSlot.New(nil,true)
    -- self.mainHeadSlot:HideSlotBg(true)
    self.mainHeadSlot:SetRectParent(t:Find("Main/Head/Bg"))
    t:Find("Main/Head/Bg"):GetComponent(Image).enabled = false

    local roleData = RoleManager.Instance.RoleData
    -- local dat = {id = roleData.id, platform = roleData.platform, zone_id = roleData.zone_id, sex = roleData.sex, classes = roleData.classes}
    -- self.mainHeadSlot:SetAll(dat, {isSmall = true})
    self.myHeadCloner:SetActive(false)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    self.buyButton.onClick:AddListener(function() self:OnBuy() end)
    self.recoverBtn.onClick:AddListener(function() self:OnRecover() end)

    self.randomBtn.onClick:AddListener(function() self:OnRandom(false) end)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    self.rebuyButton.onClick:AddListener(function() self:OnRebuy() end)

    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_taskBg))
    UIUtils.AddBigbg(t:Find("Main/BigBg"), obj)
    -- t:Find("Main/BigBg"):GetComponent(Image).enabled = false
    obj.transform.localScale = Vector3(0.5, 0.5, 1)
    obj.transform.anchoredPosition = Vector2(41.32, 0)
    self:ReloadTab()
end

function PortraitWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PortraitWindow:OnOpen()
    self.isMyOpen = false
    local model = self.model
    -- self.mgr:send17300()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
    self.mgr.updateEvent:AddListener(self.updateListener)
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)

    self:OnAsset()
    self:Update(true)
    self:InitTab()

    -- self:SwitchTabs(1)

    local list = model.head or {}
    local over_time_id = nil
    for k,v in pairs(list) do
        if v ~= nil then
            if BaseUtils.BASE_TIME > v.time_buy + v.day * 86400 then
                over_time_id = k
                break
            end
        end
    end
    if over_time_id == nil then
        for _,v in pairs(list) do
            if v ~= nil then
                if BaseUtils.BASE_TIME < v.time_buy + v.day * 86400 and BaseUtils.BASE_TIME > v.time_buy + (v.day - 5) * 86400 then
                    over_time_id = k
                    break
                end
            end
        end
    end

    if model.lastSelect ~= nil then
        self.currentSelect = model.lastSelect
        for i=1,4 do
            self.currentClassSelect[i] = model.lastTimeSelect[i]
        end
        self:SelectMyHeads(self.currentSelect, false)
    elseif over_time_id ~= nil then
        self:SelectMyHeads(over_time_id)
    elseif model.id_now ~= nil and model.id_now > 0 then
        self:SelectMyHeads(model.id_now)
    else
        self:SelectMyHeads(1)
        self:OnRandom(true)
    end
    model.lastSelect = self.currentSelect
    model.lastTimeSelect = model.lastTimeSelect or {}
    for i=1,4 do
        model.lastTimeSelect[i] = self.currentClassSelect[i]
    end
    if self.openArgs ~= nil then

        self:SwitchTabs(self.openArgs[1])
    else
        self:SwitchTabs(1)
    end
end

function PortraitWindow:OnHide()
    local model = self.model
    self:RemoveListeners()

    local c = 0
    for _,v in pairs(model.head) do
        if v ~= nil then
            c = c + 1
        end
    end

    if model.head[self.currentSelect] == nil or c == 0 then
        model.lastSelect = self.currentSelect
        model.lastTimeSelect = self.currentClassSelect
    else
        model.lastSelect = nil
        model.lastTimeSelect = nil
    end
end


function PortraitWindow:InitTab()
    for i,v in ipairs(self.classList) do
        if self.tabObjList[i] == nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            self.tabLayout:AddCell(obj)
        end
         self.tabObjList[i].gameObject:SetActive(true)
         self.tabObjList[i].name = tostring(i)
         local t = self.tabObjList[i].transform
         local content = v.name
         self.tabRedPoint[v.id] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         txt.text = content
         self.tabObjList[i]:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(v.id) end)

        if v.package ~= nil then
            if i == 2 then
                    t:Find("Text").anchoredPosition = Vector2(-3,-2)
                    t:Find("Icon").anchoredPosition = Vector2(-3.4,37)
            elseif i == 1 then
                t:Find("Text").anchoredPosition = Vector2(-3,9)
                t:Find("Icon").anchoredPosition = Vector2(-3.4,31)
            end
            local sprite = self.assetWrapper:GetSprite(v.package,v.icon_name)
            if sprite == nil then
                sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon_name))
            end
            t:Find("Icon"):GetComponent(Image).sprite  = sprite
            t:Find("Icon").gameObject:SetActive(true)

        else
            t:Find("Text").anchoredPosition = Vector2(-3.4,21)
            t:Find("Icon").gameObject:SetActive(false)
        end

         self.txtList[i] = txt
         self.contentList[i] = content
    end
end

function PortraitWindow:SwitchTabs(id)
    local index = tonumber(id)
    if self.currentTabIndex == index and self.isInit == true  then
        return
    end
    self.isInit = true
    self.txtList[self.currentTabIndex].text = string.format(ColorHelper.TabButton1NormalStr, self.contentList[self.currentTabIndex])
    self.txtList[index].text = string.format(ColorHelper.TabButton1SelectStr, self.contentList[index])
    self:EnableTab(self.currentTabIndex, false)
    self:EnableTab(index, true)
    self.currentTabIndex = index
    self:ChangeRightTab(index)
end

function PortraitWindow:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end

function PortraitWindow:ChangeRightTab(index)
        self.nowType = index
        if index == 1 then
            -- self.lastPhotoFrame = self.currentSelect[PortraitEumn.Type.photoFrame]
            self:ChangeTab(1)
            self.selectTabContainer.gameObject:SetActive(true)
            self.selectPanel.transform.anchoredPosition = Vector2(-19.5,-72.1)
            if self.model.head ~= nil and self.model.head[1] == nil then
                self:OnRandom(true)
            end
            self.vertivalTr.gameObject:SetActive(true)
            self.headSlotNameText.gameObject:SetActive(false)
            self:UpdateThreeHead()
            self.recoverText.text = "还原头像"
        elseif index == 2 then

            self.vertivalTr.gameObject:SetActive(false)
            self.headSlotNameText.gameObject:SetActive(true)
            -- self.currentClassSelect[PortraitEumn.Type.photoFrame] = self.lastPhotoFrame
            self:ChangeTab(5)
            if self.model.head[self.currentSelect] == nil then
                self:SelectMyHeads(1)
            end
            self.selectTabContainer.gameObject:SetActive(false)
            self.selectPanel.transform.anchoredPosition = Vector2(-19.5,-47)
             local headSlot = self.headList[self.currentSelect].headSlot
            local h = self.currentSelect
            headSlot.gameObject:SetActive(true)
            headSlot:HideSlotBg(true, 0.0625)
            headSlot:SetPortrait(self.currentClassSelect, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})
            self:UpdateHead()


        end

        self:OnUpdatePrice()
        self:SetBuy()
end



function PortraitWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
    self.mgr.updateEvent:RemoveListener(self.updateListener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function PortraitWindow:ReloadTab()
    self.tabList = self.tabList or {}
    self.showList = self.showList or {}

    self.showLayout:ReSet()
    for i,v in ipairs(self.model.portraitClassList) do
        if i == PortraitEumn.Type.photoFrame then
        else
            local tab = self.tabList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.selectTabCloner)
                tab.transform = tab.gameObject.transform
                tab.iconImage = tab.transform:Find("Image"):GetComponent(Image)
                tab.nameText = tab.transform:Find("Text"):GetComponent(Text)
                tab.red = tab.transform:Find("NotifyPoint").gameObject
                tab.ext = tab.transform:Find("Ext").gameObject
                tab.transform:SetParent(self.selectTabContainer)
                tab.transform.localScale = Vector3.one
            end
            tab.red:SetActive(false)
            tab.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.portrait_textures, v.icon)
            tab.nameText.text = v.name
            tab.ext:SetActive(v.type == 4)

            tab = self.showList[i]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.showCloner)
                tab.transform = tab.gameObject.transform
                -- tab.iconImage = tab.transform:Find("Image"):GetComponent(Image)
                tab.nameText = tab.transform:Find("Text"):GetComponent(Text)
                self.showList[i] = tab
            end
            -- tab.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.portrait_textures, v.icon)
            -- Log.Error(v.name)
            tab.nameText.text = v.name
            self.showLayout:UpdateCellIndex(tab.gameObject,i)
        end
    end
    self.classTabGroup:Init()
    self.classTabGroup:Layout()
    self.selectTabCloner:SetActive(false)
    self.showCloner:SetActive(false)
end

function PortraitWindow:ChangeTab(index)
    self.nowTabIndex = index
    local model = self.model
    local type = model.portraitClassList[index].type

    self:ReloadList(type,true)
end

function PortraitWindow:ReloadList(type,isUseOrder)
    self.isUseOrder = isUseOrder or false
    local scale = self.lineClonerImg.transform.rect.width / 180
    local model = self.model
    self.lineList = self.lineList or {}
    self.numToTab1 = {}

    local datalist = {}

    model.classList[type] = model.classList[type] or {}
    for _,v in pairs(model.classList[type]) do
        table.insert(datalist, v)
    end


      for k,v in pairs(datalist) do

        v.isFrame = 0
        v.isUse = 0
        v.isOderUse = 0
        if self.isOderUseIndex == nil and k == self.isOderUseIndex then
            v.isOderUse = 1
        end
        if self.model.frame_id_now == v.num then
            v.isUse = 1
            if self.isUseOrder == true then
                v.isOderUse = 1
                self.isOderUseIndex = k
            end
        end
        for i2,v2 in ipairs(self.model.headFrameList) do
            for i3,v3 in ipairs(v2.list) do
                if  v3.num == v.num then
                    v.isFrame = 1
                    break
                end
            end
        end
    end

    table.sort(datalist, function(a,b)
        if type == PortraitEumn.Type.photoFrame then
            if a.isOderUse ~= b.isOderUse then
                return a.isOderUse > b.isOderUse
            elseif a.isFrame ~= b.isFrame then
                return a.isFrame > b.isFrame
            else
                return a.position < b.position
            end
        else
            return a.num < b.num
        end

    end)
    local lineIndex = 0
    local tab = nil
    local tab1 = nil
    local sex = RoleManager.Instance.RoleData.sex
    local selectNum = self.currentClassSelect[type]
    self.selectLayout:ReSet()
    for i,v in ipairs(datalist) do
        lineIndex = math.ceil(i / 5)
        tab = self.lineList[lineIndex]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.lineCloner)
            tab.transform = tab.gameObject.transform
            tab.items = {}
            for j=1,5 do
                tab1 = {}
                tab1.transform = tab.transform:GetChild(j - 1)
                tab1.gameObject = tab1.transform.gameObject
                tab1.select = tab1.transform:Find("Bg/Select").gameObject
                tab1.image = tab1.transform:Find("Bg/Image"):GetComponent(Image)
                tab1.excessImageList = {}
                tab1.excessImageList[1] = tab1.transform:Find("Bg/Image/excess1"):GetComponent(Image)
                tab1.excessImageList[2] = tab1.transform:Find("Bg/Image/excess2"):GetComponent(Image)
                tab1.excessImageList[3] = tab1.transform:Find("Bg/Image/excess3"):GetComponent(Image)
                tab1.excessImageList[4] = tab1.transform:Find("Bg/Image/excess4"):GetComponent(Image)
                tab1.excessImageList[5] = tab1.transform:Find("Bg/Image/excess5"):GetComponent(Image)


                tab1.free = tab1.transform:Find("Bg/Free").gameObject
                tab1.mask = tab1.transform:Find("Bg/mask").gameObject
                tab1.use = tab1.transform:Find("Bg/Use").gameObject
                tab1.btn = tab1.transform:Find("Bg"):GetComponent(Button)
                tab1.specailIcon = tab1.transform:Find("SpecailIcon"):GetComponent(Image)
                tab1.nameText = tab1.transform:Find("Name/Text"):GetComponent(Text)
                tab.items[j] = tab1
            end
            self.lineList[lineIndex] = tab
        end
        tab1 = tab.items[(i - 1) % 5 + 1]
        tab1.gameObject:SetActive(true)

        tab1.image.transform.anchorMax = Vector2(0.5,0.5)
        tab1.image.transform.anchorMin = Vector2(0.5,0.5)
        tab1.image.transform.sizeDelta = Vector2(58,58)

        tab1.image.sprite = self.mgr:GetHeadcustomSprite(type, sex, v.res)
        if type == PortraitEumn.Type.Hair or type == PortraitEumn.Type.Wear then
            tab1.image:SetNativeSize()
            local t = 1
            if tab1.image.transform.sizeDelta.x > 58 and tab1.image.transform.sizeDelta.x >= tab1.image.transform.sizeDelta.y  then
                t = 58/tab1.image.transform.sizeDelta.x
            elseif tab1.image.transform.sizeDelta.y > 58 and tab1.image.transform.sizeDelta.x < tab1.image.transform.sizeDelta.y then
                t = 58/tab1.image.transform.sizeDelta.y
            end

            tab1.image.transform.sizeDelta = Vector2(tab1.image.transform.sizeDelta.x*t,tab1.image.transform.sizeDelta.y*t)
        end

        if type == PortraitEumn.Type.photoFrame then
            tab1.image.type = Image.Type.Sliced
            tab1.image.transform.sizeDelta = Vector2(tab1.image.transform.sizeDelta.x * 0.667*1.1,tab1.image.transform.sizeDelta.y * 0.667*1.1)
            if v.isUse == 1 then
                tab1.use.gameObject:SetActive(true)
                tab1.mask.gameObject:SetActive(false)
            elseif v.isUse == 0 and v.isFrame == 1 then
                tab1.use.gameObject:SetActive(false)
                tab1.mask.gameObject:SetActive(false)
            else
                tab1.use.gameObject:SetActive(false)
                tab1.mask.gameObject:SetActive(true)
            end
        else
            tab1.image.type = Image.Type.Simple
            tab1.use.gameObject:SetActive(false)
            tab1.mask.gameObject:SetActive(false)
        end

        local size = tab1.image.sprite.textureRect.size


        if type == PortraitEumn.Type.photoFrame and #v.excess > 0 then
            local myScale = 180/89

            for i2,v2 in ipairs(v.excess) do
                if DataHead.data_photoframe[string.format("%s_%s", tostring(type + 1), tostring(v2))] ~= nil then
                    local myData = DataHead.data_photoframe[string.format("%s_%s", tostring(type + 1), tostring(v2))]
                    if tab1.excessImageList[i2] ~= nil then
                        tab1.excessImageList[i2].gameObject:SetActive(true)
                        tab1.excessImageList[i2].sprite = PortraitManager.Instance:GetHeadcustomSprite(type, sex, myData.res)
                        tab1.excessImageList[i2]:SetNativeSize()

                        local size = tab1.excessImageList[i2].sprite.textureRect.size
                        tab1.excessImageList[i2].transform.sizeDelta = Vector2(size.x * scale * myScale, size.y * scale * myScale)
                        -- Vector2((myData.res_x- (80*0.223)*(80/180)) * scale* myScale, ((-myData.res_y+ (80*0.24)*(80/180)) * scale* myScale)
                        -- res_x = x*(120/87)*(180/58)*(89/180)+87*0.233 //  res_y = -(y*(180/58)*(89/180)*(120/79)-79*0.24)
                        tab1.excessImageList[i2].transform.anchoredPosition = Vector2((myData.res_x - (87*0.233))*(87/120) * scale* myScale, (-myData.res_y+(79*0.24))*(79/120) * scale* myScale)
                    else
                        error("头像配件GameObject为空")
                    end

                else
                    error("头像配件id索引的数据为空" .. tostring(type + 1) .. "_" .. tostring(v2))
                end
            end
        end

        if #tab1.excessImageList > #v.excess then
            for i=#v.excess + 1,#tab1.excessImageList do
                tab1.excessImageList[i].gameObject:SetActive(false)
            end
        end

        tab1.nameText.text = tostring(v.name)
        tab1.btn.onClick:RemoveAllListeners()
        tab1.free:SetActive(v.type == 4 and v.price == 0)
        tab1.specailIcon.gameObject:SetActive(false)
        if v.specail ~= 0 then
            tab1.specailIcon.gameObject:SetActive(true)
            tab1.specailIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.head_custom_specail, tostring(v.specail))
        end
        local num = v.num
        local select = tab1.select
        self.numToTab1[num] = tab1
        tab1.btn.onClick:AddListener(function() self:SelectClassItem(type, num, select) end)
        if selectNum == num then
            self.lastSelectObj = tab1.select
            tab1.select:SetActive(true)
        else
            tab1.select:SetActive(false)
        end
    end
    if lineIndex > 0 then
        for i=(#datalist - 1) % 5 + 2,5 do
            self.lineList[lineIndex].items[i].gameObject:SetActive(false)
        end
    end
    for i=1,lineIndex do
        self.selectLayout:AddCell(self.lineList[i].gameObject)
    end
    for i=lineIndex + 1,#self.lineList do
        self.lineList[i].gameObject:SetActive(false)
    end
    self.lineCloner:SetActive(false)
end

function PortraitWindow:OnAdd()
end

function PortraitWindow:OnAsset()
    self.ownText.text = tostring(RoleManager.Instance.RoleData.gold)
end

function PortraitWindow:OnNotice()
    if self.nowType == 1 then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {
            "1.需购买头像后方可使其成为自己头像",
            "2.最多可购买<color='#00ff00'>3套</color>头像，超过<color='#00ff00'>3套</color>时将<color='#00ff00'>替换</color>剩余时间最短的头像",
            "3.所有头像<color='#00ff00'>有效期</color>都一样，超过<color='#00ff00'>有效期</color>后头像将无法使用",
            }
        })
    elseif self.nowType == 2 then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {
            "1.使用<color='#ffff00'>指定道具</color>兑换头像框后即可使用其装饰<color='#ffff00'>头像</color>",
            "2.使用相同道具即可对<color='#ffff00'>头像框</color>进行续期",
            "3.每次兑换时间为<color='#00ff00'>30天</color>，超过期限后<color='#ffff00'>头像框</color>将无法使用",
            }
        })
    end
end

function PortraitWindow:Update(bool)
    self:UpdateHead(bool)
    self:OnTick()
    if self.nowTabIndex == 5 then
        self:ReloadList(self.model.portraitClassList[self.nowTabIndex].type)
    end
    self:SetBuy()
end

function PortraitWindow:UpdateHead(bool)

    local model = self.model
    model.head = model.head or {}

    if bool ~= true then

        self:UpdateThreeHead()
        if self.currentSelect > 0  then

            for i=1,4 do
                self.currentClassSelect[i] = nil
            end


                if model.head[self.currentSelect] ~= nil then
                    for _,v in ipairs(model.head[self.currentSelect].list) do
                        if self.nowType == 2 then
                            if v.type ~= PortraitEumn.Type.photoFrame then
                                self.currentClassSelect[v.type] = v.num
                            end
                        elseif self.nowType == 1 then
                            if v.type ~= PortraitEumn.Type.photoFrame then
                                    self.currentClassSelect[v.type] = v.num
                            end
                        end
                    end

                end

                if self.currentClassSelect[PortraitEumn.Type.photoFrame] == nil and self.nowType == 2 then
                    self:OnRandom(true,nil,5)
                end

                for i,v in ipairs(self.showList) do
                    if self.currentClassSelect[i] ~= nil then
                        if i == PortraitEumn.Type.photoFrame then
                            v.nameText.text = string.format("%s:<color='%s'>%s</color>",
                                tostring(model.portraitClassList[i].name),
                                "#205696",
                                -- ColorHelper.ButtonLabelColor["Blue"],
                                tostring(DataHead.data_res_config[i .. "_" .. self.currentClassSelect[i]].name)
                                )
                        end
                    else
                        if i == PortraitEumn.Type.photoFrame then
                            v.nameText.text = model.portraitClassList[i].name
                        end
                    end
                end
                self.mainHeadSlot:SetPortrait(self.currentClassSelect, {isSmall = false})

            end
        -- end
    end
end

function PortraitWindow:UpdateThreeHead()
    local model = self.model
    local info = model.head[self.currentSelect]
        local isHasHead = false
        for i,v in ipairs(self.headList) do


            if model.head[i] ~= nil then
                v.headSlot.gameObject:SetActive(true)
                local h = i
                local info1 = {}
                for _,v in pairs(model.head[i].list) do
                    info1[v.type] = v.num
                end
                v.headSlot:HideSlotBg(true, 0.0625)
                v.headSlot:SetPortrait(info1, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})
            else
                v.btn.onClick:RemoveAllListeners()
                if self.nowType == 1 then
                    v.headAddImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"BidAddImage")
                    v.btn.onClick:AddListener(function() self:OnSelectHeadSlot(i) end)
                elseif self.nowType == 2 then
                    v.headAddImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"Lock")
                    v.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("该位置还没有<color='#ffff00'>自定义头像</color>哟~快去挑选吧！{face_1,3}")) end)
                end
                -- local roleData = RoleManager.Instance.RoleData
                -- v.headSlot.baseImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, roleData.classes .. "_" .. roleData.sex)
            end
        end
end


function PortraitWindow:OnTick()
        local model = self.model
        local info = nil
        if self.nowType == 1 then
            info = model.head[self.currentSelect]
        elseif self.nowType == 2 then
            for k,v in pairs(model.headFrameList) do
                if v.id == self.currentClassSelect[self.nowTabIndex] then
                    info = v
                end
            end
        end


        if info ~= nil then
            if self.nowType == 2 then
                if DataHead.data_photoframe[5 .. "_" .. info.id].end_time == 0 then
                    self.timeText.text = "永久"
                    return
                end
            end
            if info.time_buy + info.day * 86400 >= BaseUtils.BASE_TIME then
                local d = nil
                local h = nil
                local m = nil
                local s = nil
                d,h,m,s = BaseUtils.time_gap_to_timer(info.time_buy + info.day * 86400 - BaseUtils.BASE_TIME)
                if d > 0 then
                    local n = h * 3600 + m * 60 + s
                    d = d + math.ceil(n / 86400)
                    if d > info.day then
                        d = info.day
                    end
                    self.timeText.text = string.format("%s天", tostring(d))
                else
                    self.timeText.text = string.format("%s:%s:%s", tostring(h), tostring(m), tostring(s))
                end
            else
                self.timeText.text = TI18N("已过期")
            end
        else
            self.timeText.text = "--/--"
        end


end

function PortraitWindow:OnBuy()
    local list = {}
    local info = {}
    local model = self.model
    for k,v in pairs(self.currentClassSelect) do
        if v ~= nil and v > 0 and k ~= PortraitEumn.Type.photoFrame then
            table.insert(list, {type = k, num = v})
        end
    end
    local lack = {}
    for i=1,3 do
        if self.currentClassSelect[i] == nil then
            table.insert(lack, i)
        end
    end


    local sum = 0
    for type,num in pairs(self.currentClassSelect) do
        if type ~= PortraitEumn.Type.photoFrame then
            sum = sum + DataHead.data_res_config[type.."_"..num].price
        end
    end

    if #lack == 0 then
        local confirmData = NoticeConfirmData.New()
        confirmData.content = string.format(TI18N("是否消耗<color='#00ff00'>%s</color>{assets_2, 90002}购买头像？"), tostring((model.gold or 0) + sum))
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureCallback = function() self.mgr:send17301(self.currentSelect, list) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        local s = ""
        for i,v in ipairs(lack) do
            if i ~= #lack then
                s = s .. self.model.portraitClassList[v].name .. " "
            else
                s = s .. self.model.portraitClassList[v].name
            end
        end
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请选择%s"), s))
    end

end

function PortraitWindow:SelectClassItem(type, num, select)
    local model = self.model
    if self.lastSelectObj ~= nil then
        self.lastSelectObj:SetActive(false)
        self.lastSelectObj = nil
    end

    if self.currentClassSelect[type] == num then
        if self.nowType == 1 then
            if num == model.lastTimeSelect[type] then
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("这已经是初始%s啦，不能取消哦"), model.portraitClassList[type].name))
            end
            self.currentClassSelect[type] = model.lastTimeSelect[type]
            if self.numToTab1[model.lastTimeSelect[type]] ~= nil then
                select = self.numToTab1[model.lastTimeSelect[type]].select
                self.lastSelectObj = select
                select:SetActive(true)
            end

        else
            select = self.numToTab1[num].select
            self.lastSelectObj = select
            select:SetActive(true)
        end
    else
        self.currentClassSelect[type] = num
        self.lastSelectObj = select
        select:SetActive(true)
    end
    self.mainHeadSlot:SetPortrait(self.currentClassSelect)

    local headSlot = self.headList[self.currentSelect].headSlot
    local h = self.currentSelect
    headSlot.gameObject:SetActive(true)
    headSlot:HideSlotBg(true, 0.0625)
    headSlot:SetPortrait(self.currentClassSelect, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})
    self:OnUpdatePrice()

    for i,v in ipairs(model.portraitClassList) do
        if self.currentClassSelect[i] ~= nil and self.currentClassSelect[i] ~= 0 then
            if i ~= PortraitEumn.Type.photoFrame then
                self.showList[i].nameText.text = string.format("%s:<color='%s'>%s</color>", tostring(v.name), "#205696", tostring(DataHead.data_res_config[i .. "_" .. self.currentClassSelect[i]].name))
            else
                self.headSlotNameText.text = string.format("%s:<color='%s'>%s</color>", tostring(v.name), "#205696", tostring(DataHead.data_photoframe[i .. "_" .. self.currentClassSelect[i]].name))
            end

        else
            if i ~= PortraitEumn.Type.photoFrame then
                self.showList[i].nameText.text = string.format("%s", tostring(v.name))
            else
                self.headSlotNameText.text = string.format("%s", tostring(v.name))
            end
        end
    end

    self:SetBuy()
    self:OnTick()
end

function PortraitWindow:SelectMyHeads(id, useServer)
    if useServer == nil then
        useServer = true
    end
    if self.headSelectObj ~= nil then
        self.headSelectObj:SetActive(false)
        self.headSelectObj = nil
    end

    local model = self.model
    self.currentSelect = id
    local info = {}
    model.head = model.head or {}
    if useServer then
        if model.head[id] ~= nil then
            for _,v in pairs(model.head[id].list) do
                info[v.type] = v.num
            end
            for k,v in pairs(info) do
                if self.nowType == 2 then
                    if k ~= PortraitEumn.Type.photoFrame then
                        self.currentClassSelect[k] = v
                    end
                elseif self.nowType == 1 then
                    if k ~= PortraitEumn.Type.photoFrame then
                        self.currentClassSelect[k] = v
                    end
                end
            end
            for k,v in pairs(self.currentClassSelect) do
                if self.nowType == 2 then
                    if k ~= PortraitEumn.Type.photoFrame then
                        self.currentClassSelect[k] = info[k]
                    end
                elseif self.nowType == 1 then
                    if k ~= PortraitEumn.Type.photoFrame then
                        self.currentClassSelect[k] = info[k]
                    end
                end
            end
        else
            for k,_ in pairs(self.currentClassSelect) do
                if self.nowType == 2 then
                    if k ~= PortraitEumn.Type.photoFrame then
                        self.currentClassSelect[k] = nil
                    end
                elseif self.nowType == 1 then
                    if k ~= PortraitEumn.Type.photoFrame then
                        self.currentClassSelect[k] = nil
                    end
                end
            end
        end
    end
    self.mainHeadSlot:SetPortrait(self.currentClassSelect)

    self:ReloadList(self.classTabGroup.currentIndex)

    self.headSelectObj = self.headList[id].select
    self.headSelectObj:SetActive(true)

    if self.nowType == 1 then
        if self.classTabGroup.currentIndex > 0 then
            if self.classTabGroup.currentIndex ~= PortraitEumn.Type.photoFrame then
                self.classTabGroup:ChangeTab(self.classTabGroup.currentIndex)
            else
                self.classTabGroup:ChangeTab(1)
            end
        else
            self.classTabGroup:ChangeTab(1)
        end
    elseif self.nowType == 2 then
        self.classTabGroup:ChangeTab(5)
    end

    for i,v in ipairs(self.headList) do
        if i ~= id then
            v.headSlot.gameObject:SetActive(model.head[i] ~= nil)
            if model.head[i] ~= nil then
                info = {}
                for _,v in pairs(model.head[i].list) do
                    info[v.type] = v.num
                end
                local h = i
                v.headSlot:HideSlotBg(true, 0.0625)
                v.headSlot:SetPortrait(info, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})
            end
        end
    end

    if not useServer then
        local h = self.currentSelect
        self.headList[self.currentSelect].headSlot.gameObject:SetActive(true)
        self.headList[self.currentSelect].headSlot:SetPortrait(self.currentClassSelect, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})
    else
        local h = self.currentSelect
        info = {}
        if model.head[self.currentSelect] ~= nil then
            for _,v in pairs(model.head[self.currentSelect].list) do
                info[v.type] = v.num
            end
            self.headList[self.currentSelect].headSlot.gameObject:SetActive(true)
            self.headList[self.currentSelect].headSlot:SetPortrait(info, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})
        end
    end

    if #self.currentClassSelect > 0 then
        for i,v in ipairs(self.model.portraitClassList) do
            if self.currentClassSelect[i] ~= nil then
                if i ~= PortraitEumn.Type.photoFrame then
                    self.showList[i].nameText.text = string.format("%s:<color='%s'>%s</color>", tostring(v.name),
                    "#205696",
                    tostring(DataHead.data_res_config[i .. "_" .. self.currentClassSelect[i]].name))
                else
                    self.headSlotNameText.text = string.format("%s:<color='%s'>%s</color>", tostring(v.name), "#205696", tostring(DataHead.data_photoframe[i .. "_" .. self.currentClassSelect[i]].name))
                end
            else
                if i ~= PortraitEumn.Type.photoFrame then
                    self.showList[i].nameText.text = string.format("%s", tostring(v.name))
                else
                    self.headSlotNameText.text = string.format("%s", tostring(v.name))
                end
            end
        end
    end
    self:OnTick()
    self:SetBuy()
end

function PortraitWindow:OnRecover()
    local model = self.model
    local id = self.currentSelect
    model.head = model.head or {}


    if model.head[id] ~= nil then
        self:SelectMyHeads(id)
        local info = {}
        for _,v in pairs(model.head[id].list) do
            info[v.type] = v.num
        end
        self.headList[id].headSlot:SetPortrait(info, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(id) end})
        self.mainHeadSlot:SetPortrait(info)
    else
        for i=1,4 do
            self.currentClassSelect[i] = model.lastTimeSelect[i]
        end
        self.headList[id].headSlot:SetPortrait(self.currentClassSelect, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(id) end})
        self.mainHeadSlot:SetPortrait(self.currentClassSelect)
    end
    self:SetBuy()
end

--isChange即使页签在第二层的时候,使用切换预设头像也会全部随机一遍
function PortraitWindow:OnRandom(noWear,isChange,RandomIndex)
    local myRandomIndex = RandomIndex or 0
    local model = self.model
    local myIsChange = isChange or false
    local info = {}
    if self.nowType == 1 or myIsChange == true then
            for type,v in pairs(model.classList) do
                if (type ~= PortraitEumn.Type.photoFrame and myRandomIndex == 0) or (myRandomIndex ~= 0 and myRandomIndex == type)then

                    local continue = false
                    if noWear == true and type == 4 then
                        continue = true
                    end

                    if continue ~= true then
                        local c = 0
                        for _,_ in pairs(v) do
                            c = c+1
                        end
                        local a = 0
                        if c > 0 then
                            local t = math.random(1, c)
                            for _,dat in pairs(v) do
                                a = a + 1
                                if a == t then
                                    info[type] = dat.num
                                    break
                                end
                            end
                        end
                    end
                else
                        info[type] = self.currentClassSelect[type]
                end
            end


    elseif self.nowType == 2 then
        for type,v in pairs(model.classList) do
            if type == PortraitEumn.Type.photoFrame then
                local continue = false

                if continue ~= true then
                    local c = 0
                    for _,_ in pairs(v) do
                        c = c+1
                    end
                    local a = 0
                    if c > 0 then
                        local t = math.random(1, c)
                        for _,dat in pairs(v) do
                            a = a + 1
                            if a == t then
                                info[type] = dat.num
                                break
                            end
                        end
                    end
                end
            end
        end

        for k,v in pairs(self.currentClassSelect) do
            if k ~= PortraitEumn.Type.photoFrame then
                info[k] = v
            end
        end
    end

    for type,num in pairs(info) do
        self.currentClassSelect[type] = num
    end

    for type,_ in pairs(self.currentClassSelect) do
        self.currentClassSelect[type] = info[type]
    end

    self:ReloadList(self.classTabGroup.currentIndex)

    if self.nowType == 1 then
        self.classTabGroup:ChangeTab(PortraitEumn.Type.Hair)
    elseif self.nowType == 2 then
        self.classTabGroup:ChangeTab(PortraitEumn.Type.photoFrame)
    end
    self.mainHeadSlot:SetPortrait(self.currentClassSelect)

    local headSlot = self.headList[self.currentSelect].headSlot
    headSlot.gameObject:SetActive(true)

    local h = self.currentSelect
    headSlot:HideSlotBg(true, 0.0625)
    headSlot:SetPortrait(self.currentClassSelect, {isSmall = true, clickCallback = function() self:OnSelectHeadSlot(h) end})

    self:OnUpdatePrice()
    for i,v in ipairs(self.model.portraitClassList) do
        if self.currentClassSelect[i] ~= nil then
            if i ~= PortraitEumn.Type.photoFrame then
                self.showList[i].nameText.text = string.format("%s:<color='%s'>%s</color>", tostring(v.name),
                "#205696",
            -- ColorHelper.ButtonLabelColor["Blue"],
                tostring(DataHead.data_res_config[i .. "_" .. self.currentClassSelect[i]].name))
            else
                self.headSlotNameText.text = string.format("%s:<color='%s'>%s</color>", tostring(v.name), "#205696", tostring(DataHead.data_photoframe[i .. "_" .. self.currentClassSelect[i]].name))
            end

        else
            if i ~= PortraitEumn.Type.photoFrame then
                self.showList[i].nameText.text = string.format("%s", tostring(v.name))
            else
                self.headSlotNameText.text = string.format("%s", tostring(v.name))
            end
        end
    end

    if noWear == true then
        model.lastSelect = self.currentSelect
        model.lastTimeSelect = model.lastTimeSelect or {}
        for i=1,4 do
            model.lastTimeSelect[i] = self.currentClassSelect[i]
        end
    end
    self:SetBuy()

    if self.isMyOpen == false then
        self.isMyOpen = true
    end
end

function PortraitWindow:OnUpdatePrice()

    if self.nowType == 1 then
        local model = self.model
        local sum = 0
        for type,num in pairs(self.currentClassSelect) do
            if type ~= PortraitEumn.Type.photoFrame then
                sum = sum + DataHead.data_res_config[type.."_"..num].price
            end
        end
        if sum > 0 then
            self.priceText.text = string.format("%s<color='#00ff00'>+%s</color>", tostring(model.gold or 0), tostring(sum))
        else
            self.priceText.text = tostring(model.gold or 0)
        end
        self.ownPanel.gameObject:SetActive(true)
        self.pricePanel.gameObject:SetActive(true)
        self.priceAssesWay.gameObject:SetActive(false)
    elseif self.nowType == 2 then
        if self.currentClassSelect[PortraitEumn.Type.photoFrame] ~= nil then
             local myNum = 0
                for type,num in pairs(self.currentClassSelect) do
                    if type == PortraitEumn.Type.photoFrame then
                        myNum = num
                    end
                end

                local str = StringHelper.Split(DataHead.data_photoframe[PortraitEumn.Type.photoFrame .. "_" .. myNum].accessway, "|")
                for i,v in ipairs(str) do
                    if self.assesWayList[i] == nil then
                        local go = GameObject.Instantiate(self.assesTemplater.gameObject)
                        self.assesWayList[i] = {}
                        self.assesWayList[i].gameObject = go.gameObject
                        self.assesWayList[i].text = go.transform:Find("Text"):GetComponent(Text)
                        self.assesLayout:AddCell(self.assesWayList[i].gameObject)
                    end

                    self.assesWayList[i].text.text = v
                end

                if #self.assesWayList > #str then
                    for i=#str + 1,#self.assesWayList do
                        self.assesWayList[i].gameObject:SetActive(false)
                    end
                end

                local cost = DataHead.data_photoframe[PortraitEumn.Type.photoFrame .. "_" .. myNum].cost[1]

                local itemData = ItemData.New()
                itemData:SetBase(DataItem.data_get[tonumber(cost[1])])

                self.assesItemSlot:SetAll(itemData)
                local hasNum = BackpackManager.Instance:GetItemCount(tonumber(cost[1]))
                self.assesItemSlot:SetNum(hasNum,tonumber(cost[2]))
                self.assesNameText.text = ColorHelper.color_item_name(DataItem.data_get[tonumber(cost[1])].quality, DataItem.data_get[tonumber(cost[1])].name)

                self.ownPanel.gameObject:SetActive(false)
                self.pricePanel.gameObject:SetActive(false)
                self.priceAssesWay.gameObject:SetActive(true)
        else
                self.ownPanel.gameObject:SetActive(false)
                self.pricePanel.gameObject:SetActive(false)
                self.priceAssesWay.gameObject:SetActive(false)
        end
    end
end

function PortraitWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function PortraitWindow:OnUse()
    self.mgr:send17302(self.currentSelect)
end

function PortraitWindow:SetBuy()
    local model = self.model
    self.buyButton.onClick:RemoveAllListeners()
    if self.nowType == 1 then
        self.isCancelWear = false
        if model.id_now ~= nil and model.id_now > 0 then
            if model.id_now == self.currentSelect then
                local is_same = true
                local info = model.head[model.id_now]
                local info1 = {}
                for i,v in ipairs(info.list) do
                    info1[v.type] = v.num
                end
                if self.currentClassSelect ~= nil then
                    info1[PortraitEumn.Type.photoFrame] =self.currentClassSelect[PortraitEumn.Type.photoFrame]
                end

                is_same = is_same and BaseUtils.sametab(info1, self.currentClassSelect)
                if is_same then
                    self:SetButton(false)
                    self.buyButtonText.text = TI18N("使用中")
                    self.buyButton.gameObject:SetActive(true)
                    self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    self.buyButtonText.color = ColorHelper.DefaultButton4
                    if (info.time_buy + info.day * 86400) - BaseUtils.BASE_TIME >= 86400 * 5 or BaseUtils.BASE_TIME > info.time_buy + info.day * 86400 then
                        self.rebuyButton.gameObject:SetActive(false)
                    else
                        self.rebuyButton.gameObject:SetActive(true)
                    end
                else
                    self:SetButton(true)
                    self.rebuyButton.gameObject:SetActive(false)
                    self.buyButtonText.text = TI18N("购买头像")
                    self.buyButton.gameObject:SetActive(true)
                    self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    self.buyButtonText.color = ColorHelper.DefaultButton3
                    self.buyButton.onClick:AddListener(function() self:OnBuy() end)
                end
            else
                local is_same = true
                local info = model.head[self.currentSelect]
                if info ~= nil then
                    local info1 = {}
                    for i,v in ipairs(info.list) do
                        info1[v.type] = v.num
                    end

                    if self.currentClassSelect[PortraitEumn.Type.photoFrame] ~= nil then
                        info1[PortraitEumn.Type.photoFrame] =self.currentClassSelect[PortraitEumn.Type.photoFrame]
                    else
                        info1[PortraitEumn.Type.photoFrame] = nil
                    end
                    is_same = is_same and BaseUtils.sametab(info1, self.currentClassSelect)
                    if info.time_buy + info.day * 86400 < BaseUtils.BASE_TIME then
                        is_same = false
                    end
                else
                    is_same = false
                end
                if is_same then
                    self:SetButton(false)
                    self.buyButtonText.text = TI18N("使 用")
                    self.buyButton.gameObject:SetActive(true)
                    self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                    self.buyButtonText.color = ColorHelper.DefaultButton1
                    self.buyButton.onClick:AddListener(function() self:OnUse() end)
                    if (info.time_buy + info.day * 86400) - BaseUtils.BASE_TIME >= 86400 * 5 or BaseUtils.BASE_TIME > info.time_buy + info.day * 86400 then
                        self.rebuyButton.gameObject:SetActive(false)
                    else
                        self.rebuyButton.gameObject:SetActive(true)
                    end
                else
                    self:SetButton(true)
                    self.rebuyButton.gameObject:SetActive(false)
                    self.buyButtonText.text = TI18N("购买头像")
                    self.buyButton.gameObject:SetActive(true)
                    self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    self.buyButtonText.color = ColorHelper.DefaultButton3
                    self.buyButton.onClick:AddListener(function() self:OnBuy() end)
                end
            end
        else
            local is_same = true
            if model.lastTimeSelect ~= nil then
                for i=1,4 do
                    is_same = is_same and (model.lastTimeSelect[i] == self.currentClassSelect[i])
                end
            end
            self:SetButton(not is_same)
            self.rebuyButton.gameObject:SetActive(false)
            self.buyButtonText.text = TI18N("购买头像")
            self.buyButton.gameObject:SetActive(true)
            self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.buyButton.onClick:AddListener(function() self:OnBuy() end)
        end
    elseif self.nowType == 2 then
        if self.currentClassSelect[PortraitEumn.Type.photoFrame] ~= nil then
            if self.currentClassSelect[self.nowTabIndex] == self.model.frame_id_now then
                self:SetButton(false)
                self.buyButtonText.text = TI18N("取消使用")
                self.buyButton.gameObject:SetActive(true)
                self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.buyButtonText.color = ColorHelper.DefaultButton3
                self.buyButton.onClick:AddListener(function() self:OnReBuyFrame() end)
                self.isCancelWear = true
            else
                self.isCancelWear = false
                local isHasFrame = false
                for i,v in ipairs(self.model.headFrameList) do
                    for i2,v2 in ipairs(v.list) do
                        if  v2.num == self.currentClassSelect[self.nowTabIndex] then
                            isHasFrame = true
                            break
                        end
                    end
                end

                if isHasFrame == true then
                    self:SetButton(false)
                    self.buyButtonText.text = TI18N("使 用")
                    self.buyButton.gameObject:SetActive(true)
                    self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                    self.buyButtonText.color = ColorHelper.DefaultButton1
                    self.buyButton.onClick:AddListener(function() self:OnUseFrame() end)
                elseif isHasFrame == false then
                    self:SetButton(true)
                    self.rebuyButton.gameObject:SetActive(false)
                    self.buyButtonText.text = TI18N("兑换")
                    self.buyButton.gameObject:SetActive(true)
                    self.buyButtonImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    self.buyButtonText.color = ColorHelper.DefaultButton3
                    self.buyButton.onClick:AddListener(function() self:OnBuyFrame() end)
                end
            end

            local cost = DataHead.data_photoframe[PortraitEumn.Type.photoFrame .. "_" .. self.currentClassSelect[self.nowTabIndex]].cost[1]

            local itemData = ItemData.New()
            itemData:SetBase(DataItem.data_get[tonumber(cost[1])])
            self.buyButton.gameObject:SetActive(true)
            self.assesItemSlot:SetAll(itemData)
            local hasNum = BackpackManager.Instance:GetItemCount(tonumber(cost[1]))
            self.assesItemSlot:SetNum(hasNum,tonumber(cost[2]))
        else
            self.buyButton.gameObject:SetActive(false)
        end
    end
end

function PortraitWindow:OnReBuyFrame()
    self.mgr:send17306(0)
end

function PortraitWindow:OnUseFrame()
    self.mgr:send17306(self.currentClassSelect[self.nowTabIndex])
end

function PortraitWindow:OnBuyFrame()
    self.mgr:send17305(self.currentClassSelect[self.nowTabIndex])
end


-- function PortraitWindow:OnSelectTab(index)
--     local model = self.model
--     if index == self.currentSelect then
--         return
--     end

--     local is_same = true    -- 是否与原来选中的套装一样
--     local info = model.head[self.currentSelect]
--     if model.id_now ~= nil and model.id_now > 0 and info ~= nil then
--         local info1 = {}
--         for i,v in ipairs(info.list) do
--             info1[v.type] = v.num
--         end
--         is_same = is_same and BaseUtils.sametab(info1, self.currentClassSelect)
--         if info.time_buy + info.day * 86400 > BaseUtils.BASE_TIME then  -- 没过期
--             is_same = is_same and true
--         else                                                    -- 过期
--             is_same = true
--         end
--     elseif #self.currentClassSelect > 0 then
--         if info ~= nil then
--             if info.time_buy + info.day * 86400 > BaseUtils.BASE_TIME then  -- 没过期
--                 is_same = is_same and true
--             else                                                    -- 过期
--                 is_same = true
--             end
--         else
--             is_same = false
--         end
--     end

--     if is_same then
--         self:OnRecover()
--     end
-- end

function PortraitWindow:OnSelectHeadSlot(index)
    local model = self.model
    if index == self.currentSelect then
        return
    end

    local is_same = true    -- 是否与原来选中的套装一样
    local info = model.head[self.currentSelect]
    if model.id_now ~= nil and model.id_now > 0 and info ~= nil then
        local info1 = {}
        for i,v in ipairs(info.list) do
            info1[v.type] = v.num
        end
        for k,v in pairs(info1) do
            if v ~= self.currentClassSelect[k] and k ~= PortraitEumn.Type.photoFrame then
                is_same = false
                break
            end
        end
        if info.time_buy + info.day * 86400 > BaseUtils.BASE_TIME then  -- 没过期
            is_same = is_same and true
        else                                                    -- 过期
            is_same = true
        end
    elseif #self.currentClassSelect > 0 then
        if info ~= nil then
            if info.time_buy + info.day * 86400 > BaseUtils.BASE_TIME then  -- 没过期
                is_same = is_same and true
            else                                                    -- 过期
                is_same = true
            end
        else
            is_same = false
        end
    end

    if is_same then
        self:SelectMyHeads(index)
        if model.head[self.currentSelect] == nil then
            self:OnRandom(true)
        end
    else
        if self.nowType == 1 then
            local confirmData = NoticeConfirmData.New()
            confirmData.content = TI18N("您挑选好的头像尚未购买哦，切换将使其被还原，是否确定？")
            confirmData.sureCallback = function()
                self:SelectMyHeads(index)
                if model.head[self.currentSelect] == nil then
                    self:OnRandom(true)
                end
            end
            confirmData.type = ConfirmData.Style.Normal
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            self:SelectMyHeads(index)
        end
    end
end

function PortraitWindow:SetButton(bool)
    if bool == true then
        self.recoverBtn.gameObject:SetActive(true)
        self.randomBtn.transform.anchoredPosition = Vector2(64, -180)
    else
        self.recoverBtn.gameObject:SetActive(false)
        self.randomBtn.transform.anchoredPosition = Vector2(0, -180)
    end
end

function PortraitWindow:OnRebuy()
    local model = self.model
    local sum = 0
    for type,num in pairs(self.currentClassSelect) do
        sum = sum + DataHead.data_res_config[type.."_"..num].price
    end
    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("续费此头像需要消耗<color='#00ff00'>%s</color>{assets_2, 90002}, 是否确定？"), tostring((model.gold or 0) + sum))
    confirmData.type = ConfirmData.Style.Normal
    confirmData.sureCallback = function() self.mgr:send17303(self.currentSelect) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

