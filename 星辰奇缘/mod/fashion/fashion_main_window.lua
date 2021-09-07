FashionMainWindow  =  FashionMainWindow or BaseClass(BaseWindow)

function FashionMainWindow:__init(model)
    self.name  =  "FashionMainWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.fashion_window
    -- 缓存
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.resList  =  {
        {file = AssetConfig.fashion_window, type = AssetType.Main}
        ,{file = AssetConfig.FashionBg, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_big_icon, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_big_icon2, type = AssetType.Dep}
        ,{file = AssetConfig.fashionres, type = AssetType.Dep}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.effectbg, type = AssetType.Dep}
    }
    self.timer_id = 0
    self.timer_belt_id = 0
    self.suit_tab = nil
    self.weapon_tab = nil
    self.belt_tab = nil
    self.cur_belt_data = nil

    self.is_open = false
    self.is_open_prop = false

    self.item_id_1 = 20045
    self.item_id_2 = 20046


    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.is_open = false
    self.item_list = nil

    self.prop_txt_list = nil
    self.head_item = nil
    self.waist_item = nil
    self.cloth_item = nil
    self.ring_item = nil
    self.weapon_item = nil

    self.head_slot = nil
    self.waist_slot = nil
    self.cloth_slot = nil
    self.ring_slot = nil
    self.head_dress_slot = nil
    self.weapon_slot = nil

    self.slot_go1 = nil
    self.slot_go2 = nil
    self.current_index = 0

    self.model.current_head_data = nil
    self.model.current_cloth_data = nil
    self.model.current_waist_data = nil
    self.model.current_ring_data = nil
    self.model.current_head_dress_data = nil
    self.model.current_weapon_data = nil

    self.on_looks_update = function(looks)
        self:on_update_role_looks(looks)
    end

    self.on_item_update = function()
        self:on_item_change()
    end

    self.attrImgList = {}
    self.attrTxtList = {}
    self.attrObjList = {}

    self.fashionTips = nil
    self.imgLoader = nil

    return self
end

function FashionMainWindow:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:HideCameraOnly()
    end
end

function FashionMainWindow:OnShow()
    self.model:InitWeaponFashion()

    if self.previewComp ~= nil then
        self.previewComp:Show()
    end
    self:ShowAllAttr()
    self:UpdateBottomFaceScroe()
    if self.current_index == nil or self.current_index == 0 then
        self.tabGroup:ChangeTab(1)
    else
        self.tabGroup:ChangeTab(self.current_index)
    end
end

function FashionMainWindow:__delete()
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.fashionTips ~= nil then
        self.fashionTips:DeleteMe()
        self.fashionTips = nil
    end

    for i,v in ipairs(self.attrImgList) do
        v.sprite = nil
    end
    self.attrImgList = nil

    if self.slot_go_list ~= nil then
        for k, v in pairs(self.slot_go_list) do
            v:DeleteMe()
        end
    end

    if self.head_slot ~= nil then
        self.head_slot:DeleteMe()
    end
    if self.cloth_slot ~= nil then
        self.cloth_slot:DeleteMe()
    end
    if self.waist_slot ~= nil then
        self.waist_slot:DeleteMe()
    end
    if self.ring_slot ~= nil then
        self.ring_slot:DeleteMe()
    end
    if self.head_dress_slot ~= nil then
        self.head_dress_slot:DeleteMe()
    end

    if self.head_item ~= nil then
        if self.head_item.slot ~= nil then
            self.head_item.slot:DeleteMe()
            self.head_item.slot = nil
        end
    end

    if self.waist_item ~= nil then
        if self.waist_item.slot ~= nil then
            self.waist_item.slot:DeleteMe()
            self.waist_item.slot = nil
        end
    end

    if self.cloth_item ~= nil then
        if self.cloth_item.slot ~= nil then
            self.cloth_item.slot:DeleteMe()
            self.cloth_item.slot = nil
        end
    end

    if self.ring_item ~= nil then
        if self.ring_item.slot ~= nil then
            self.ring_item.slot:DeleteMe()
            self.ring_item.slot = nil
        end
    end

    if self.dress_head_item ~= nil then
        if self.dress_head_item.slot ~= nil then
            self.dress_head_item.slot:DeleteMe()
            self.dress_head_item.slot = nil
        end
    end

    if self.weapon_item ~= nil then
        if self.weapon_item.slot ~= nil then
            self.weapon_item.slot:DeleteMe()
            self.weapon_item.slot = nil
        end
    end

    self.ImgSec.sprite = nil
    if self.imgAssetIcon_list ~= nil then
        for i=1,#self.imgAssetIcon_list do
            self.imgAssetIcon_list[i].sprite = nil
        end
    end

    self:stop_timer()
    self:stop_belt_timer()
    self.is_open = false

    if self.suit_tab ~= nil then
        self.suit_tab:DeleteMe()
    end
    if self.weapon_tab ~= nil then
        self.weapon_tab:DeleteMe()
    end
    if self.belt_tab ~= nil then
        self.belt_tab:DeleteMe()
    end

    self.suit_tab = nil
    self.weapon_tab = nil
    self.belt_tab = nil

    self.cur_belt_data = nil

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    self.item_list = nil

    self.prop_txt_list = nil
    self.head_item = nil
    self.waist_item = nil
    self.cloth_item = nil
    self.ring_item = nil
    self.dress_head_item = nil
    self.weapon_item = nil

    self.head_slot = nil
    self.waist_slot = nil
    self.head_dress_slot = nil
    self.cloth_slot = nil
    self.ring_slot = nil
    self.weapon_slot = nil

    self.slot_go1 = nil
    self.slot_go2 = nil
    self.current_index = 0

    self.model.current_head_data = nil
    self.model.current_cloth_data = nil
    self.model.current_waist_data = nil
    self.model.current_ring_data = nil
    self.model.current_head_dress_data = nil
    self.model.current_weapon_data = nil


    EventMgr.Instance:RemoveListener(event_name.role_looks_change, self.on_looks_update)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)


    self.is_open  =  false
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function FashionMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "FashionMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.is_open = true

    -------------------------------------面板基础逻辑
    self.MainCon = self.transform:FindChild("MainCon")
    self.HeadCon = self.MainCon:FindChild("HeadCon")
    self.CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseBtn.onClick:AddListener(function () self.model:CloseFashionUI()  end)

    local tabGroup = self.MainCon:FindChild("TabButtonGroup")
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        -- cannotSelect = {false, false, false, true},
    }
    self.tabGroup = TabGroup.New(tabGroup.gameObject, function(index) self:tabChange(index) end, setting)

    -- self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    -- self.tab_btn1.onClick:AddListener(function() self:tabChange(1) end)
    -- self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    -- self.tab_btn2.onClick:AddListener(function() self:tabChange(2) end)
    -- self.tab_btn3 = tabGroup.transform:GetChild(2):GetComponent(Button)
    -- self.tab_btn3.onClick:AddListener(function() self:tabChange(3) end)

    if self.imgLoader == nil then
           local go =  self.tabGroup.buttonTab[4].transform:Find("ImgIcon").gameObject
           self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item,24022)

    -- 属性显示
    self.attrContainer = self.MainCon:Find("AttrContainer").gameObject
    for i = 1, 3 do
        local item = self.MainCon:Find("AttrContainer/Text" .. i)
        table.insert(self.attrImgList, item:Find("Icon"):GetComponent(Image))
        table.insert(self.attrTxtList, item:GetComponent(Text))
        table.insert(self.attrObjList, item.gameObject)
    end
    self.attrContainer:SetActive(false)

    --------------------------------------面板右边逻辑
    self.ConRight = self.HeadCon:FindChild("ConRight")
    self.suit_tab = FashionSuitTab.New(self)
    self.suit_tab:Show()
    self.weapon_tab = FashionWeapontTab.New(self)
    self.belt_tab = FashionBeltTab.New(self)

    ---------------------------------------面板左边逻辑
    self.ConLeft = self.HeadCon:FindChild("ConLeft")
    self.ImgTxtAddProp = self.ConLeft:FindChild("ImgTxtAddProp")
    self.ImgTxtAddProp.gameObject:SetActive(false)
    self.TxtAddProp = self.ImgTxtAddProp:FindChild("TxtAddProp"):GetComponent(Text)

    self.ImgSec = self.ConLeft:FindChild("ImgSec"):GetComponent(Image)

    self.ConLeft:FindChild("ImgSec"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.FashionBg, "FashionBg")
    self.ImgSec.gameObject:SetActive(true)
    self.BtnBack = self.ConLeft:FindChild("BtnBack"):GetComponent(Button)
    self.BtnShop = self.ConLeft:FindChild("BtnShop"):GetComponent(Button)
    self.BtnProp = self.ConLeft:FindChild("BtnProp"):GetComponent(Button)
    self.ClockCon = self.ConLeft:Find("BottomCon/ClockCon").gameObject
    self.ClockCon_ImgBg = self.ClockCon.transform:FindChild("ImgBg")
    self.ClockCon_TxtCloth = self.ClockCon_ImgBg:FindChild("TxtCloth"):GetComponent(Text)

     self.ClockCon_TxtCloth.text = ""

    self.PropCon = self.ConLeft:FindChild("PropCon").gameObject
    self.PropConPanel = self.PropCon.transform:FindChild("Panel"):GetComponent(Button)
    self.prop_txt_list = {}
    for i=1,4 do
        local txt = self.PropCon.transform:FindChild(string.format("TxtProp%s", i)):GetComponent(Text)
        table.insert(self.prop_txt_list, txt)
    end
    self.PropCon:SetActive(self.is_open_prop)

    --左侧顶部颜值描述
    self.LeftTopCon = self.ConLeft:FindChild("LeftTopCon")
    self.LeftTopConTitle = self.LeftTopCon:Find("ImgTitle/TxtTitle"):GetComponent(Text)
    self.LeftTopConTxtDesc = self.LeftTopCon:Find("TxtDesc"):GetComponent(Text)
    self.LeftTopConTxtFaceScore = self.LeftTopCon:Find("TxtFaceScore"):GetComponent(Text)

    self.Preview = self.ConLeft:FindChild("Preview").gameObject
    self.ConLeft:Find("ItemFashionCon").gameObject:SetActive(true)
    self.ConLeft:Find("ItemFashionCon"):GetComponent(RectTransform).anchoredPosition = Vector2(-180, -24)
    self.ItemFashion1 = self.ConLeft:Find("ItemFashionCon/ItemFashion1").gameObject
    self.ItemFashion2 = self.ConLeft:Find("ItemFashionCon/ItemFashion2").gameObject
    self.ItemFashion3 = self.ConLeft:Find("ItemFashionCon/ItemFashion3").gameObject
    self.ItemFashion4 = self.ConLeft:Find("ItemFashionCon/ItemFashion4").gameObject
    self.ItemFashion5 = self.ConLeft:Find("ItemFashionCon/ItemFashion5").gameObject

    self.ImgIconItemFashion1 = self.ItemFashion1.transform:FindChild("ImgIcon").gameObject
    self.ImgIconItemFashion2 = self.ItemFashion2.transform:FindChild("ImgIcon").gameObject
    self.ImgIconItemFashion3 = self.ItemFashion3.transform:FindChild("ImgIcon").gameObject
    self.ImgIconItemFashion4 = self.ItemFashion4.transform:FindChild("ImgIcon").gameObject
    self.ImgIconItemFashion5 = self.ItemFashion5.transform:FindChild("ImgIcon").gameObject

    self.txtFashion1 = self.ItemFashion1.transform:FindChild("Text").gameObject
    self.txtFashion2 = self.ItemFashion2.transform:FindChild("Text").gameObject
    self.txtFashion3 = self.ItemFashion3.transform:FindChild("Text").gameObject
    self.txtFashion4 = self.ItemFashion4.transform:FindChild("Text").gameObject
    self.txtFashion5 = self.ItemFashion5.transform:FindChild("Text").gameObject

    self.ImgBackPack = self.ConLeft:FindChild("ImgBackPack"):GetComponent(Button)
    self.ImgBadge = self.ConLeft:Find("ImgBadge").gameObject
    self.ImgBadge:SetActive(false)
    self.TxtHas = self.ConLeft:Find("BottomCon/TxtHas"):GetComponent(Text)
    self.LeftBottomSlotCon = self.ConLeft:Find("BottomCon/TxtCon").gameObject
    self.LeftBottomSlotCon:SetActive(false)
    self.TxtHas.text = ""
    self.TxtHas.gameObject:SetActive(false)

    --底部颜值进度条
    self.BottomFaceScoreCon = self.ConLeft:Find("BottomFaceScoreCon")
    self.FaceLevTxt = self.ConLeft:Find("BottomFaceScoreCon/ImgFaceScoreLev/TxtLev"):GetComponent(Text)
    self.FaceNameLevTxt = self.ConLeft:Find("BottomFaceScoreCon/TxtLev"):GetComponent(Text)
    self.ImgProgBarRect = self.ConLeft:Find("BottomFaceScoreCon/ImgProg/ImgProgBar"):GetComponent(RectTransform)
    self.TxtProgBar = self.ConLeft:Find("BottomFaceScoreCon/ImgProg/TxtProgBar"):GetComponent(Text)
    self.BtnFaceLevUp = self.ConLeft:Find("BottomFaceScoreCon/BtnFaceLevUp"):GetComponent(Button)
    self.BtnFaceLevUpRedPoint = self.ConLeft:Find("BottomFaceScoreCon/BtnFaceLevUp/RedPoint").gameObject

    self.DescCon = self.ConLeft:Find("DescCon").gameObject
    self.DescConText = self.ConLeft:Find("DescCon/DescText"):GetComponent(Text)

    self.LimitDescText = self.ConLeft:Find("LimitDescText"):GetComponent(Text)
    self.LimitProg = self.ConLeft:Find("LimitProg").gameObject
    self.LimitProgBarRect = self.ConLeft:Find("LimitProg/ImgProgBar"):GetComponent(RectTransform)
    self.LimitProgBar = self.ConLeft:Find("LimitProg/TxtProgBar"):GetComponent(Text)

    self.slot_go_list = {}
    self.Slot_list = {}
    self.Slot_Con_list = {}
    self.TxtValue_list = {}
    self.Textmz_list = {}
    self.imgAssetIcon_list = {}
    self.ImgTxtBg_list = {}

    for i=1,3 do
        self.Slot_list[i] = self.LeftBottomSlotCon.transform:FindChild(string.format("Slot%s", i)).gameObject
        self.Slot_Con_list[i] = self.Slot_list[i].transform:FindChild("SlotCon").gameObject
        self.TxtValue_list[i] = self.Slot_list[i].transform:FindChild("TxtValue1"):GetComponent(Text)
        self.Textmz_list[i] = self.Slot_list[i].transform:FindChild("Textmz"):GetComponent(Text)
        self.imgAssetIcon_list[i] = self.Slot_list[i].transform:FindChild("ImgIcon"):GetComponent(Image)
        self.ImgTxtBg_list[i] = self.Slot_list[i].transform:FindChild("ImgTxtBg")
        self.imgAssetIcon_list[i].gameObject:SetActive(false)
        self.TxtValue_list[i].text = ""
        self.ImgTxtBg_list[i]:GetComponent(CanvasGroup).blocksRaycasts = false
        self.TxtValue_list[i].transform:GetComponent(CanvasGroup).blocksRaycasts = false
    end

    self.fashionTips = FashionTips.New(self.transform:Find("FashionTips"), self)

    ----------------------------注册监听器
    self.BtnProp.onClick:AddListener(function()
        self.is_open_prop = not self.is_open_prop
        self.PropCon:SetActive(self.is_open_prop)
    end)

    self.PropConPanel.onClick:AddListener(function()
        self.is_open_prop = not self.is_open_prop
        self.PropCon:SetActive(self.is_open_prop)
    end)
    self.BtnBack.onClick:AddListener(function() self:on_click_back_btn()  end)
    self.BtnShop.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1,4})
    end)
    self.ImgBackPack.onClick:AddListener(function() self:on_click_backpack_btn() end)
    self.BtnFaceLevUp.onClick:AddListener(function()
        self.model:OpenFashionFaceUI()
    end)
    EventMgr.Instance:AddListener(event_name.role_looks_change, self.on_looks_update)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)

    -- self:ShowAllAttr()
    -- self:UpdateBottomFaceScroe()
    self:OnShow()
end


function FashionMainWindow:switch_tab_btn(btn)
    -- self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    -- self.tab_btn3.transform:FindChild("Select").gameObject:SetActive(false)
    -- self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    -- self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    -- self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    -- self.tab_btn3.transform:FindChild("Normal").gameObject:SetActive(true)
    -- btn.transform:FindChild("Select").gameObject:SetActive(true)
    -- btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

--事件监听
--切换选项卡
function FashionMainWindow:tabChange(index)
    -- if index == self.current_index then
    --     return
    -- end

    self.ItemFashion1:SetActive(false)
    self.ItemFashion2:SetActive(false)
    self.ItemFashion3:SetActive(false)
    self.ItemFashion4:SetActive(false)

    local data_list = nil
    if index == 1 then
        --套装页签
        self.current_index = index
        self:switch_suit_tab()
        self.DescCon:SetActive(false)
        self.ImgBadge:SetActive(false)
    elseif index == 2 then
        self.current_index = index
        -- data_list = self.model:get_fashion_data_list(SceneConstData.looktype_dress)
        -- self:switch_tab_btn(self.tab_btn2.transform)
                --饰品页签
        self.ItemFashion1:SetActive(false)
        self.ItemFashion2:SetActive(false)
        self.ItemFashion3:SetActive(false)
        self.ItemFashion4:SetActive(false)
        self.ItemFashion5:SetActive(true)

        self:on_click_back_btn()
        self.suit_tab:Hiden()
        self.belt_tab:Hiden()

        data_list = self.model:get_weapon_data_list()
        self.weapon_tab:update_item_list(data_list)
        -- self:switch_tab_btn(self.tab_btn3.transform)
        self.weapon_tab:Show()

        self.ImgBadge:SetActive(false)
    elseif index == 3 then
        self.current_index = index
        --饰品页签
        self.ItemFashion1:SetActive(false)
        self.ItemFashion2:SetActive(false)
        self.ItemFashion3:SetActive(true)
        self.ItemFashion4:SetActive(true)
        self.ItemFashion5:SetActive(false)

        self:on_click_back_btn()
        self.suit_tab:Hiden()
        self.weapon_tab:Hiden()

        data_list = self.model:get_belt_data_list()
        self.belt_tab:update_item_list(data_list)
        -- self:switch_tab_btn(self.tab_btn3.transform)
        self.belt_tab:Show()
        self.DescCon:SetActive(false)
        self.ImgBadge:SetActive(false)
    elseif index == 4 then
        -- data_list = self.model:get_fashion_data_list(SceneConstData.lookstype_ring)
        -- self:switch_tab_btn(self.tab_btn4.transform)
        -- 打开兑换界面 hosr 20170320
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_exchange)
    end
end

--切换到套装页签
function FashionMainWindow:switch_suit_tab()
    self.ItemFashion1:SetActive(true)
    self.ItemFashion2:SetActive(true)
    self.ItemFashion3:SetActive(false)
    self.ItemFashion4:SetActive(false)
    self.ItemFashion5:SetActive(false)

    self:on_click_back_btn()
    self.belt_tab:Hiden()
    self.weapon_tab:Hiden()

    local data_list = self.model:get_suit_data_list()

    if self.suit_tab.has_init then
        self.suit_tab:update_item_list(data_list)
        self.suit_tab:Show()
    end
    -- self:switch_tab_btn(self.tab_btn1.transform)
end


--更新模型
function FashionMainWindow:on_update_role_looks(looks)
    --监听到场景模型变化
    -- print("监听到场景模型变化,更新时装模型")
    self:update_model()
    self:ShowAllAttr()
end

--协议更新
function FashionMainWindow:update_socket()
    if self.current_index == 1 or self.current_index == 0 then
        if self.suit_tab.tab_index == 1 then
            -- self:tabChange(1)
            self:switch_suit_tab()
        else
            self.suit_tab:update_color_tab()
        end
        self.suit_tab:update_put_on_btn()
    elseif self.current_index == 2 then
        self.weapon_tab:update_item_list(self.model:get_weapon_data_list())
    elseif self.current_index == 3 then
        self.belt_tab:update_item_list(self.model:get_belt_data_list())
    end
    self:ShowAllAttr()
    self:UpdateBottomFaceScroe()
end

--更新逻辑
--当前穿戴的 头部，腰饰，衣服，婚戒
function FashionMainWindow:update_current_fashion_item()
    if self.head_item == nil then
        self.head_item = self:create_slot_item(self.head_slot, self.ImgIconItemFashion1, self.ItemFashion1, self.txtFashion1)
    end
    if self.cloth_item == nil then
        self.cloth_item = self:create_slot_item(self.cloth_slot, self.ImgIconItemFashion2, self.ItemFashion2, self.txtFashion2)
    end
    if  self.waist_item == nil then
        self.waist_item = self:create_slot_item(self.waist_slot, self.ImgIconItemFashion3, self.ItemFashion3, self.txtFashion3)
    end
    if self.ring_item == nil then
        self.ring_item = self:create_slot_item(self.ring_slot, nil, self.ItemFashion4, nil)
    end
    if  self.dress_head_item == nil then--头饰
        self.dress_head_item = self:create_slot_item(self.head_dress_slot, self.ImgIconItemFashion4, self.ItemFashion4, self.txtFashion4)
    end
    if  self.weapon_item == nil then--武器
        self.weapon_item = self:create_slot_item(self.weapon_slot, self.ImgIconItemFashion5, self.ItemFashion5, self.txtFashion5)
        self.weapon_item.slot:SetNotips(true)
        self.weapon_item.slot.button.onClick:AddListener(function() TipsManager.Instance:ShowItem(self.weapon_item.slot) end)
    end

    --将所有data弄成当前玩家的穿戴data
    local head_data =  self.model:get_current_fashion_data(SceneConstData.looktype_hair)
    local cloth_data = self.model:get_current_fashion_data(SceneConstData.looktype_dress)
    local waist_data = self.model:get_current_fashion_data(SceneConstData.lookstype_belt)
    local ring_data = self.model:get_current_fashion_data(SceneConstData.lookstype_ring)
    local head_dress_data = self.model:get_current_fashion_data(SceneConstData.lookstype_headsurbase)
    local weapon_data = self.model:get_current_fashion_data(SceneConstData.looktype_weapon)

    head_data = self.model.current_head_data ~= nil and self.model.current_head_data or head_data
    cloth_data = self.model.current_cloth_data ~= nil and self.model.current_cloth_data or cloth_data
    waist_data = self.model.current_waist_data ~= nil and self.model.current_waist_data or waist_data
    ring_data = self.model.current_ring_data ~= nil and self.model.current_ring_data or ring_data
    head_dress_data = self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data or head_dress_data
    weapon_data = self.model.current_weapon_data ~= nil and self.model.current_weapon_data or weapon_data

    if head_data ~= nil then
        local temp = DataFashion.data_base[head_data.base_id]
        if temp.is_role == 1 then
             head_data = nil
        end
    end
    if cloth_data ~= nil then
        local temp = DataFashion.data_base[cloth_data.base_id]
        if temp.is_role == 1 then
             cloth_data = nil
        end
    end
    if waist_data ~= nil then
        local temp = DataFashion.data_base[waist_data.base_id]
        if temp.is_role == 1 then
             waist_data = nil
        end
    end

    if ring_data ~= nil then
        local temp = DataFashion.data_base[ring_data.base_id]
        if temp.is_role == 1 then
             ring_data = nil
        end
    end
    if head_dress_data ~= nil then
        local temp = DataFashion.data_base[head_dress_data.base_id]
        if temp.is_role == 1 then
             head_dress_data = nil
        end
    end
    if weapon_data ~= nil then
        local temp = DataFashion.data_base[weapon_data.base_id]
        if temp.is_role == 1 then
             weapon_data = nil
        end
    end

    if self.model.current_head_data == nil then
        self.model.current_head_data = self.model:get_cfg_data(head_data)
    end
    if self.model.current_cloth_data == nil then
        self.model.current_cloth_data = self.model:get_cfg_data(cloth_data)
    end
    if self.model.current_waist_data == nil then
        self.model.current_waist_data = self.model:get_cfg_data(waist_data)
    end
    if self.model.current_ring_data == nil then
        self.model.current_ring_data = self.model:get_cfg_data(ring_data)
    end
    if self.model.current_head_dress_data == nil then
        self.model.current_head_dress_data = self.model:get_cfg_data(head_dress_data)
    end
    if self.model.current_weapon_data == nil then
        self.model.current_weapon_data = self.model:get_cfg_data(weapon_data)
    end

    self:update_slot_item(self.head_item, head_data)
    self:update_slot_item(self.cloth_item, cloth_data)
    self:update_slot_item(self.waist_item, waist_data)
    self:update_slot_item(self.ring_item, ring_data)
    self:update_slot_item(self.dress_head_item, head_dress_data)
    self:update_slot_item(self.weapon_item, weapon_data)
end

function FashionMainWindow:update_slot_item(item, data)
    if data ~= nil then
        self:SetSlotData(item.slot, DataItem.data_get[data.base_id])
        item.slot.transform:SetAsLastSibling()
    else
        if item.imgIcon ~= nil then
            item.imgIcon.transform:SetAsLastSibling()
        end
        if item.txt ~= nil then
            item.txt.transform:SetAsLastSibling()
        end
        self:SetSlotData(item.slot, nil)
    end
end

--还原按钮点击监听
function FashionMainWindow:on_click_back_btn()
    if self.model.current_head_data == nil and self.model.current_cloth_data == nil and self.model.current_waist_data == nil and self.model.current_ring_data == nil and self.model.current_head_dress_data == nil and self.model.current_weapon_data == nil then
        return
    end

    self.belt_tab:reset_belt_selected_items()
    self.weapon_tab:reset_weapon_selected_items()
    self.suit_tab:reset_item_list()


    --将模型设置当前人物模型
    self:update_model()
end

--道具更新
function FashionMainWindow:on_item_change()
    self:update_materia_data()
    self.suit_tab:update_put_on_btn()
end

--回到背包按钮点击监听
function FashionMainWindow:on_click_backpack_btn()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack)
end


--请求穿戴协议返回，面板更新接口
function FashionMainWindow:socket_back_put_on()
    --更新模型
    self:update_model()
    self:ShowAllAttr()
    --更新数据列表里面那个被穿戴的data的item
    -- self:tabChange(self.current_index)
    self.tabGroup:ChangeTab(self.current_index)
end

--请求卸下协议返回，面板更新接口
function FashionMainWindow:socket_back_unload()
    --更新模型
    self.model.current_head_data = nil
    self.model.current_cloth_data = nil
    self.model.current_waist_data = nil
    self.model.current_ring_data = nil
    self.model.current_head_dress_data = nil
    self.model.current_weapon_data = nil
    --更新数据列表里面那个被卸下的data的item
    -- self:tabChange(self.current_index)
    self.tabGroup:ChangeTab(self.current_index)
end

function FashionMainWindow:create_slot_item(slot, imgIcon, parent, txt)
    if slot == nil then --如果是空的则创建
        slot = self:CreateSlot(parent)
        if imgIcon ~= nil then
            imgIcon.transform:SetAsLastSibling()
        end
        if txt ~= nil then
            txt.transform:SetAsLastSibling()
        end
        self:SetSlotData(slot, nil)
        local item = {}
        item.slot = slot
        item.slot_parent = parent
        item.imgIcon = imgIcon
        item.txt = txt
        return item
    end
end

--创建slot
function FashionMainWindow:CreateSlot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function FashionMainWindow:SetSlotData(slot, data)
    if data == nil then
        slot:SetAll(nil, nil)
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end


--移除unitdata里面某个类型时装id
function FashionMainWindow:remove_unitDataFashion(_type, unitData)
    local index = 0
        for i=1, #unitData.looks do
            local look = unitData.looks[i]
            if look.looks_type == _type then
                index = i
            end
        end
        if index ~= 0 then
            table.remove(unitData.looks, index)
        end
end

--检查下当前是否选中单件时装，返回单件时装的时间
function FashionMainWindow:check_single_time()
    if self.model.current_head_data ~= nil and self.model.current_head_data.expire_time ~= nil and self.model.current_head_data.expire_time > 0 then
        return self.model.current_head_data.expire_time
    elseif self.model.current_cloth_data ~= nil and self.model.current_cloth_data.expire_time ~=nil and self.model.current_cloth_data.expire_time > 0 then
        return self.model.current_cloth_data.expire_time
    elseif self.model.current_waist_data ~= nil and self.model.current_waist_data.expire_time ~= nil and self.model.current_waist_data.expire_time > 0 then
        return self.model.current_waist_data.expire_time
    elseif self.model.current_ring_data ~= nil and self.model.current_ring_data.expire_time ~=nil and self.model.current_ring_data.expire_time > 0 then
        return self.model.current_ring_data.expire_time
    elseif self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data.expire_time ~= nil and self.model.current_head_dress_data.expire_time > 0 then
        return self.model.current_head_dress_data.expire_time
    elseif self.model.current_weapon_data ~= nil and self.model.current_weapon_data.expire_time ~= nil and self.model.current_weapon_data.expire_time > 0 then
        return self.model.current_weapon_data.expire_time
    end
    return 0
end

--更新当前显示的时装属性辅助函数
function FashionMainWindow:update_cur_prop_help(index, data)
    local txt = nil
    local temp_index = index
    if data ~= nil and #data.attrs > 0 then
        local temp_color = ColorHelper.color[1]
        local suffix_str = TI18N("(已激活)")
        if data.active == 0 then
            temp_color = ColorHelper.color[6]
            suffix_str = TI18N("(未激活)")
        end
        for i=1,#data.attrs do
            txt = self.prop_txt_list[index]
            index = index + 1
            local atr = data.attrs[i]
            txt.text = string.format("<color='%s'>%s+%s%s</color>", temp_color, KvData.attr_name[atr.effect_type], atr.val, suffix_str)
        end
    end
    return temp_index
end

--更新当前显示的时装属性
function FashionMainWindow:update_cur_prop()
    for i=1,#self.prop_txt_list do
        self.prop_txt_list[i].text = ""
    end
    local index = 1
    -- index = self:update_cur_prop_help(index, self.model.current_head_data)
    -- index = self:update_cur_prop_help(index, self.model.current_cloth_data)
    -- index = self:update_cur_prop_help(index, self.model.current_waist_data)
    -- index = self:update_cur_prop_help(index, self.model.current_ring_data)
    -- index = self:update_cur_prop_help(index, self.model.current_head_dress_data)
end

--更新底部材料数据
function FashionMainWindow:update_materia_data()
    --还原显示内容
    self.LeftBottomSlotCon:SetActive(false)
    self.ClockCon:SetActive(false)
    self:stop_timer()
    self:stop_belt_timer()
    self.TxtHas.text = ""
    for i=1,#self.Textmz_list do
        self.Textmz_list[i].text = ""
    end
    for i=1,#self.imgAssetIcon_list do
        self.imgAssetIcon_list[i].gameObject:SetActive(false)
    end
    for i=1,#self.Slot_list do
        self.Slot_list[i]:SetActive(false)
    end
    for i=1,#self.TxtValue_list do
        self.TxtValue_list[i].text = "0"
    end

    if self.current_index == 1 or self.current_index == 0 then
        --套装
        if self.suit_tab ~= nil and self.suit_tab.tab_index == 1 then
            -- if self.suit_tab.last_selected_item ~= nil then
            --     --选中套装
            --     if self.suit_tab.last_selected_item.data.active == 1 then87
            --         --时装已激活
            --         self:start_timer()
            --     else

            --         local cost_dic = self.model:count_fashion_loss(self.suit_tab.last_selected_item.data)
            --         self:update_cost_slot(cost_dic)
            --         --更新保存快捷购买按钮
            --     end
            -- else
            --     --没选中
            -- end
            if self.suit_tab.last_selected_item ~= nil then
                self:UpdateLeftTopFaceScore(1, self.suit_tab.last_selected_item.data.addpoint_str)
            else
                self:UpdateLeftTopFaceScore(1)
            end
        elseif self.suit_tab.tab_index == 2 then
            --选中染色页签
            -- local cost_dic = {}
            -- --染色
            -- local head_cost_dic = nil
            -- local cloth_cost_dic = nil

            -- if self.suit_tab.current_head_color_data.id == 0 then
            --     head_cost_dic = {}
            -- elseif self.suit_tab.current_head_color_data.active == 0 then
            --     --未激活
            --     head_cost_dic = self.model:count_fashion_loss(self.suit_tab.current_head_color_data)
            -- else
            --     --已激活
            --     if self.suit_tab.current_head_color_data.suit_type then
            --         head_cost_dic = {}
            --     else
            --         head_cost_dic = self.model:count_color_change_loss(self.suit_tab.current_head_color_data)
            --     end
            -- end

            -- if self.suit_tab.current_cloth_color_data.id == 0 then
            --     cloth_cost_dic = {}
            -- elseif self.suit_tab.current_cloth_color_data.active == 0 then
            --     --未激活
            --     cloth_cost_dic = self.model:count_fashion_loss(self.suit_tab.current_cloth_color_data)
            -- else
            --     --已激活
            --     if self.suit_tab.current_cloth_color_data.suit_type then
            --         cloth_cost_dic = {}
            --     else
            --         cloth_cost_dic = self.model:count_color_change_loss(self.suit_tab.current_cloth_color_data)
            --     end
            -- end

            -- cost_dic = self.model:merge_cost_dic(head_cost_dic, cloth_cost_dic)
            -- self:update_cost_slot(cost_dic)
            self:UpdateLeftTopFaceScore(2)
        end
    elseif self.current_index == 3 then
        --饰品的
        -- if self.model:check_is_belt_data(self.model.current_waist_data) == false and self.model:check_is_belt_data(self.model.current_head_dress_data) == false then
        --     --都是基础的或者是空的，不处理
        -- else
        --     if self.model:check_is_belt_data(self.model.current_waist_data) and self.model:check_is_base_data(self.model.current_head_dress_data) and self.model.current_waist_data.active == 1 then
        --         --腰饰不是nil且不是基础，头饰是nil获者是基础
        --         self:start_belt_timer(self.model.current_waist_data)
        --     elseif self.model:check_is_belt_data(self.model.current_head_dress_data) and self.model:check_is_base_data(self.model.current_waist_data) and self.model.current_head_dress_data.active == 1 then
        --         --头饰不是nil且不是基础，腰饰是nil获者是基础
        --         self:start_belt_timer(self.model.current_head_dress_data)
        --     else
        --         if self.model.current_waist_data ~= nil and self.model.current_waist_data.active == 1 and self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data.active == 1 then
        --             --两个都是激活的
        --             if self.model.current_head_dress_data.expire_time < self.model.current_waist_data.expire_time then
        --                 self:start_belt_timer(self.model.current_head_dress_data)
        --             else
        --                 self:start_belt_timer(self.model.current_waist_data)
        --             end
        --         else
        --             --在饰品页签
        --             local waist_dic = {}
        --             local head_dress_dic = {}
        --             local cost_dic = {}
        --             if self.model:check_is_belt_data(self.model.current_waist_data) and self.model.current_waist_data.active == 0 then
        --                 waist_dic = self.model:count_fashion_loss(self.model.current_waist_data)
        --             end
        --             if self.model:check_is_belt_data(self.model.current_head_dress_data) and self.model.current_head_dress_data.active == 0 then
        --                 head_dress_dic = self.model:count_fashion_loss(self.model.current_head_dress_data)
        --             end
        --             cost_dic = self.model:merge_cost_dic(waist_dic, head_dress_dic)
        --             self:update_cost_slot(cost_dic)
        --         end
        --     end
        -- end
    end
end

--根据选中的时装数据显示颜值
function  FashionMainWindow:UpdateLeftTopFaceScore(type, propStr, data)
    if type == 1 then
        if self.suit_tab.last_selected_item == nil then
            return
        end
        local cfgData = DataFashion.data_base[self.suit_tab.last_selected_item.data.id]
        local str = ""
        if propStr == nil then
            str = string.format(TI18N("颜值<color='#C7F9FF'>+%s</color>"), DataFashion.data_cloth_face[self.suit_tab.last_selected_item.data.id].collect_val)
        else
            str = string.format(TI18N("颜值<color='#C7F9FF'>+%s</color>\n%s"), DataFashion.data_cloth_face[self.suit_tab.last_selected_item.data.id].collect_val, propStr)
        end
        self.LeftTopConTitle.text = cfgData.name
        if cfgData.desc == "" then
            self.LeftTopConTxtDesc.text = str
        else
            self.LeftTopConTxtDesc.text = string.format(TI18N("%s\n%s"), cfgData.desc, str)
            -- self.LeftTopConTxtFaceScore.text = str
        end
        self.LeftTopCon.gameObject:SetActive(true)
        self.DescCon:SetActive(false)
        self.LimitDescText.gameObject:SetActive(false)
        self.LimitProg:SetActive(false)

        if self.suit_tab.last_selected_item.data ~= nil and self.suit_tab.last_selected_item.data.special_mark == 100 then
            self.ImgBadge:SetActive(true)
        else
            self.ImgBadge:SetActive(false)
        end
    elseif type == 2 then
        local name = ""
        local val = 0
        if self.suit_tab.current_head_color_data.id ~= 0 then
            local headColorData = DataFashion.data_color_face[self.suit_tab.current_head_color_data.id]
            if headColorData ~= nil then
                val = headColorData.collect_val + val
                local temp = nil
                for k, v in pairs(DataFashion.data_color_prog) do
                    if v.id == self.suit_tab.current_head_color_data.id then
                        temp = v
                        break
                    end
                end
                if temp ~= nil then
                    name = temp.name
                end
            end
        end
        if self.suit_tab.current_cloth_color_data.id ~= 0 then
            local clothColorData = DataFashion.data_color_face[self.suit_tab.current_cloth_color_data.id]
            if clothColorData ~= nil  then
                val = clothColorData.collect_val + val
                local temp = nil
                for k, v in pairs(DataFashion.data_color_prog) do
                    if v.id == self.suit_tab.current_head_color_data.id then
                        temp = v
                        break
                    end
                end
                if temp ~= nil then
                    if name == "" then
                        name = temp.name
                    else
                        name = string.format("%s、%s", name, temp.name)
                    end
                end
            end
        end
        if name ~= "" then
            self.LeftTopConTitle.text = name
            self.LeftTopConTxtDesc.text = string.format(TI18N("颜值<color='#C7F9FF'>+%s</color>"), val)
            self.LeftTopCon.gameObject:SetActive(true)
        else
            self.LeftTopCon.gameObject:SetActive(false)
        end
        self.DescCon:SetActive(false)
        self.LimitDescText.gameObject:SetActive(false)
        self.LimitProg:SetActive(false)

        self.ImgBadge:SetActive(false)
    elseif type == 3 then -- 饰品
        local temp = nil
        if data == nil then
            self.LeftTopCon.gameObject:SetActive(false)
        else
            local val = 0
            local name = data.name
            if DataFashion.data_cloth_face[data.base_id] ~= nil  then
                val = val + DataFashion.data_cloth_face[data.base_id].collect_val
            end
            self.LeftTopConTitle.text = name
            self.LeftTopConTxtDesc.text = string.format(TI18N("颜值<color='#C7F9FF'>+%s</color>"), val)
            self.LeftTopCon.gameObject:SetActive(true)
        end
        self.DescCon:SetActive(false)

        if data ~= nil and data.limit_desc ~= "" and (data.expire_time > 0 or data.active == 0) then
            self.LimitDescText.gameObject:SetActive(true)
            self.LimitDescText.text = data.limit_desc
            self.LimitProg:SetActive(true)
        else
            self.LimitDescText.gameObject:SetActive(false)
            self.LimitProg:SetActive(false)
        end

        if data ~= nil and data.special_mark == 100 then
            self.ImgBadge:SetActive(true)
        else
            self.ImgBadge:SetActive(false)
        end
    elseif type == 4 then -- 武器
        local temp = nil
        if data == nil then
            self.LeftTopCon.gameObject:SetActive(false)
            self.DescCon:SetActive(false)
            self.LimitDescText.gameObject:SetActive(false)
            self.LimitProg:SetActive(false)
        else
            local val = 0
            local name = data.name
            local faceString = ""
            if DataFashion.data_cloth_face[data.base_id] ~= nil  then
                if DataFashion.data_cloth_face[data.base_id].collect_val ~= 0 then
                    faceString = string.format(TI18N("颜值<color='#C7F9FF'>+%s</color>"), DataFashion.data_cloth_face[data.base_id].collect_val)
                end
            end

            local attrString = ""
            for index, value in ipairs(data.attrs) do
                if index == 1 then
                    attrString = string.format("%s <color='#ffffff'>+%s</color>", KvData.attr_name_show[value.effect_type], value.val)
                else
                    attrString = string.format("%s\n%s <color='#ffffff'>+%s</color>", attrString, KvData.attr_name_show[value.effect_type], value.val)
                end
            end
            self.LeftTopConTitle.text = name

            local descString = ""
            local cfgData = DataFashion.data_base[self.weapon_tab.last_selected_item.data.base_id]
            if cfgData.desc ~= "" then
                descString = string.format(TI18N("%s%s\n"), descString, cfgData.desc)
            end
            if attrString ~= "" then
                descString = string.format(TI18N("%s%s\n"), descString, attrString)
            end
            if faceString ~= "" then
                descString = string.format(TI18N("%s%s\n"), descString, faceString)
            end
            self.LeftTopConTxtDesc.text = descString
            self.LeftTopCon.gameObject:SetActive(true)

            if data.special_mark == 3 then
                self.DescCon:SetActive(true)
                local descString = TI18N("当前首席：\n")
                local roleData = RoleManager.Instance.RoleData
                local mark = true
                for index, value in ipairs(self.model.classesChiefList) do
                    if value.classes == roleData.classes then
                        descString = string.format("%s\n    <color='#23f0f7'>%s</color>", descString, value.name)
                        mark = false
                    end
                end
                if mark then
                    descString = TI18N("当前还没有首席\n快去争夺吧")
                end

                -- local descString2 = TI18N("昔日首席：")
                -- mark = true
                -- for index, value in ipairs(self.model.classesChiefList1) do
                --     if value.classes == roleData.classes then
                --         descString2 = string.format("%s\n    <color='#23f0f7'>%s</color>", descString2, value.name)
                --         mark = false
                --     end
                -- end
                -- for index, value in ipairs(self.model.classesChiefList2) do
                --     if value.classes == roleData.classes then
                --         descString2 = string.format("%s\n    <color='#23f0f7'>%s</color>", descString2, value.name)
                --         mark = false
                --     end
                -- end
                -- if mark then
                --     descString2 = TI18N("暂无昔日首席")
                -- end
                -- self.DescConText.text = string.format("%s\n\n%s", descString, descString2)

                if mark then
                    self.DescConText.text = descString
                    self.DescCon:SetActive(true)
                    self.DescCon:GetComponent(RectTransform).sizeDelta = Vector2(140, 62)
                else
                    self.DescCon:SetActive(false)
                end
            elseif data.special_mark == 4 then
                if #self.model.arenaKingList > 0 then
                    local descString = TI18N("当天竞技王者：")
                    local mark = true
                    for index, value in ipairs(self.model.arenaKingList) do
                        descString = string.format("%s\n    <color='#23f0f7'>%s</color>", descString, value.name)
                        mark = false
                    end
                    if mark then
                        descString = TI18N("竞技场正在激烈战斗中\n快快参与吧！")
                    end
                    self.DescConText.text = descString
                    self.DescCon:SetActive(true)
                    self.DescCon:GetComponent(RectTransform).sizeDelta = Vector2(140, 148.2)
                else
                    self.DescCon:SetActive(false)
                end
            else
                self.DescCon:SetActive(false)
            end

            if data ~= nil and data.limit_desc ~= "" and (data.expire_time > 0 or data.active == 0) then
                self.LimitDescText.gameObject:SetActive(true)
                self.LimitDescText.text = data.limit_desc
                -------ymiakill
                local limit_time = data.expire_time - BaseUtils.BASE_TIME
                local limit_date = math.modf(limit_time / 86400)
                self.LimitProg:SetActive(limit_date > 0)
                --print(limit_date)
                local percent = limit_date / 365
                self.LimitProgBarRect.sizeDelta = Vector2(161*percent, 18)
                self.LimitProgBar.text = string.format(TI18N("%s/365天"), limit_date)
            else
                self.LimitDescText.gameObject:SetActive(false)
                self.LimitProg:SetActive(false)
            end
        end

        self.ImgBadge:SetActive(false)
    end
end

--更新底部颜值
function FashionMainWindow:UpdateBottomFaceScroe()
    local cfgData = DataFashion.data_face[string.format("%s_%s", self.model.collect_lev+1, RoleManager.Instance.RoleData.classes)]
    self.FaceLevTxt.text = tostring(self.model.collect_lev)

    if self.model.collect_lev == 0 then
        self.FaceNameLevTxt.text = string.format("%s Lv. %s", TI18N("平平无奇"), self.model.collect_lev)
    else
        local tempCfgData = DataFashion.data_face[string.format("%s_%s", self.model.collect_lev, RoleManager.Instance.RoleData.classes)]
        self.FaceNameLevTxt.text = string.format("%s Lv. %s", tempCfgData.name, self.model.collect_lev)
    end
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    local percent = self.model.collect_val/cfgData.loss_collect
    if percent >= 1 then
        percent = 1
        self.effTimerId = LuaTimer.Add(1000, 3000, function()
            self.BtnFaceLevUp.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.BtnFaceLevUp.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end

    self.ImgProgBarRect.sizeDelta = Vector2(173*percent, 17)
    self.TxtProgBar.text = string.format(TI18N("总颜值：%s/%s"), self.model.collect_val, cfgData.loss_collect)

    self.BtnFaceLevUpRedPoint:SetActive(percent == 1)
end

--根据消耗列表显示底部消耗内容
function FashionMainWindow:update_cost_slot(cost_dic)
    if self.model:count_dic_len(cost_dic) > 0 then
        --显示激活需要的道具
        self.LeftBottomSlotCon:SetActive(true)
    else
        return
    end
    self.LeftBottomSlotCon:SetActive(true)
    local index = 1
    for k, need in pairs(cost_dic) do
        if need ~= 0 then
            self.Slot_list[index]:SetActive(true)
            if self.slot_go_list[index] == nil then
                self.slot_go_list[index] = self:CreateSlot(self.Slot_Con_list[index])
            end

            local base_data = DataItem.data_get[k]
            self:SetSlotData(self.slot_go_list[index], base_data)

            local has = BackpackManager.Instance:GetItemCount(k)
            if need <= has then
                self.TxtValue_list[index].text = string.format("<color='#8DE92A'>%s</color>/%s", has, need)
            else
                self.TxtValue_list[index].text = string.format("<color='#EE3900'>%s</color>/%s", has, need)
            end
            index = index + 1
        end
    end
end

--请求底部个数价格回调
function FashionMainWindow:on_price_back(prices)
    for i=1,#self.slot_go_list do
        if self.slot_go_list[i] ~= nil then
            if self.slot_go_list[i].itemData ~= nil then
                local data = prices[self.slot_go_list[i].itemData.base_id]
                if data ~= nil then
                    self:on_price_back_help(data, self.Textmz_list[i], self.imgAssetIcon_list[i])
                end
            end
        end
    end
end

function FashionMainWindow:on_price_back_help(data, bottom_left_TxtVal, bottom_left_icon , _num)
    local allprice = data.allprice
    if allprice >= 0 then
        price_str = string.format("<color='%s'>%s</color>", "#00ff00", allprice)
    else
        price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], -allprice)
    end
    bottom_left_TxtVal.text = price_str
    bottom_left_icon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[data.assets])
    bottom_left_icon.gameObject:SetActive(true)
end

--找到当前数据里面任意一个有消耗道具id的
function FashionMainWindow:find_current_cost_base_id()
    if self.model.current_head_data ~= nil and self.model.current_head_data.is_wear ~= 1 and self.model.current_head_data.loss[1] ~= nil then
        if self.model.current_head_data.loss[1].val[1][2] ~= 0 then
            return self.model.current_head_data.loss[1].val[1][1]
        elseif self.model.current_head_data.loss[2].val[1][2] ~= 0 then
            return self.model.current_head_data.loss[2].val[1][1]
        end
    end

    if self.model.current_cloth_data ~= nil and self.model.current_cloth_data.is_wear ~= 1 and self.model.current_cloth_data.loss[1] ~= nil  then
        if self.model.current_cloth_data.loss[1].val[1][2] ~= 0 then
            return self.model.current_cloth_data.loss[1].val[1][1]
        elseif self.model.current_cloth_data.loss[2].val[1][2] ~= 0 then
            return self.model.current_cloth_data.loss[2].val[1][1]
        end
    end

    if self.model.current_waist_data ~= nil and self.model.current_waist_data.is_wear ~= 1 and self.model.current_waist_data.loss[1] ~= nil   then
        if self.model.current_waist_data.loss[1].val[1][2] ~= 0 then
            return self.model.current_waist_data.loss[1].val[1][1]
        elseif self.model.current_waist_data.loss[2].val[1][2] ~= 0 then
            return self.model.current_waist_data.loss[2].val[1][1]
        end
    end

    if self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data.is_wear ~= 1 and self.model.current_head_dress_data.loss[1] ~= nil   then
        if self.model.current_head_dress_data.loss[1].val[1][2] ~= 0 then
            return self.model.current_head_dress_data.loss[1].val[1][1]
        elseif self.model.current_head_dress_data.loss[2].val[1][2] ~= 0 then
            return self.model.current_head_dress_data.loss[2].val[1][1]
        end
    end

    if self.model.current_weapon_data ~= nil and self.model.current_weapon_data.is_wear ~= 1 and self.model.current_weapon_data.loss[1] ~= nil   then
        if self.model.current_weapon_data.loss[1].val[1][2] ~= 0 then
            return self.model.current_weapon_data.loss[1].val[1][1]
        elseif self.model.current_weapon_data.loss[2].val[1][2] ~= 0 then
            return self.model.current_weapon_data.loss[2].val[1][1]
        end
    end
end

-------------------------------------模型逻辑
--模型逻辑
--更新模型
function FashionMainWindow:update_model(data, _type)
    if data == nil then
        --如果传入的data是nil，则将模型还原到真实人物模型状态，即卸下所有试穿
        self.model.current_head_data =  nil--将所有data弄成当前玩家的穿戴data
        self.model.current_cloth_data = nil
        self.model.current_waist_data = nil
        self.model.current_ring_data = nil
        self.model.current_head_dress_data = nil
        self.model.current_weapon_data = nil
    end

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)

    if self.model.current_head_data ~=  nil then
        self:remove_unitDataFashion(self.model.current_head_data.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model.current_head_data.texture_id, looks_type=SceneConstData.looktype_hair, looks_val= self.model.current_head_data.base_id})
    end
    if self.model.current_cloth_data ~= nil then
        self:remove_unitDataFashion(self.model.current_cloth_data.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model.current_cloth_data.texture_id, looks_type=SceneConstData.looktype_dress, looks_val= self.model.current_cloth_data.base_id})
    end
    if self.model.current_waist_data ~= nil and self.model.current_waist_data.is_role ~= 1 then
        self:remove_unitDataFashion(self.model.current_waist_data.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model.current_waist_data.texture_id, looks_type=SceneConstData.lookstype_belt, looks_val= self.model.current_waist_data.base_id})
    end
    if self.model.current_ring_data ~= nil then
        self:remove_unitDataFashion(data.type, unitData)
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model.current_ring_data.texture_id, looks_type=SceneConstData.lookstype_ring, looks_val= self.model.current_ring_data.base_id})
    end
    if self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data.is_role ~= 1 then
        self:remove_unitDataFashion(data.type, unitData)
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model.current_head_dress_data.texture_id, looks_type=SceneConstData.lookstype_headsurbase, looks_val= self.model.current_head_dress_data.base_id})
    end
    if self.model.current_weapon_data ~= nil and self.model.current_weapon_data.is_role ~= 1 then
        self:remove_unitDataFashion(data.type, unitData)
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model.current_weapon_data.texture_id, looks_type=SceneConstData.lookstype_headsurbase, looks_val= self.model.current_weapon_data.base_id})
    end

    if data ~= nil then
        -- 如果传入的data不为nil，则模型还在试穿状态
        if self.current_index == 1 then --头部
            self.model.current_head_data = data
            self:remove_unitDataFashion(data.type, unitData) --脱下当前同类型的
            table.insert(unitData.looks, {looks_str = "", looks_mode =  data.texture_id, looks_type=SceneConstData.looktype_hair, looks_val= data.base_id})
        elseif self.current_index == 2 then --衣服
            -- self.model.current_cloth_data = data
            -- self:remove_unitDataFashion(data.type, unitData) --脱下当前同类型的
            -- table.insert(unitData.looks, {looks_str = "", looks_mode =  data.texture_id, looks_type=SceneConstData.looktype_dress, looks_val= data.base_id})
            self.model.current_weapon_data = data
            self:remove_unitDataFashion(data.type, unitData) --脱下当前同类型的
            table.insert(unitData.looks, {looks_str = "", looks_mode =  0, looks_type=SceneConstData.looktype_weapon, looks_val= data.model_id})
        elseif self.current_index == 3 then --腰饰
            self:remove_unitDataFashion(data.type, unitData) --脱下当前同类型的
            if data.base_id ~= 0 then
                if data.type == SceneConstData.lookstype_belt then
                    self.model.current_waist_data = data
                    table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_waist_data.effect_id, looks_type=SceneConstData.lookstype_belt, looks_val= data.base_id})
                elseif data.type == SceneConstData.lookstype_headsurbase then
                    self.model.current_head_dress_data = data
                    table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_head_dress_data.effect_id, looks_type=SceneConstData.lookstype_headsurbase, looks_val= data.base_id})
                end
            end
        elseif self.current_index == 4 then --戒指
            self.model.current_ring_data = data
        end
    else
        self.ImgBadge:SetActive(false)
    end

    self:update_model_view(unitData.looks)
    self:update_current_fashion_item()

    if self.current_index == 1 then
        self.suit_tab:update_put_on_btn()
    elseif self.current_index == 2 then
        self.weapon_tab:update_put_on_btn()
    elseif self.current_index == 3 then
        self.belt_tab:update_put_on_btn()
    end
    self:update_materia_data()
    self:update_cur_prop()
end

-- --更新顶部加点描述
-- function FashionMainWindow:update_add_prop_str(str)
--     if str == "" then
--         self.ImgTxtAddProp.gameObject:SetActive(false)
--     else
--         self.ImgTxtAddProp.gameObject:SetActive(true)
--     end
--     self.TxtAddProp.text = str
-- end


--传入时装data列表进行批量更新
function FashionMainWindow:update_batch_model(data_list)

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)

    if self.model.current_head_data ~=  nil then
        self:remove_unitDataFashion(self.model.current_head_data.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_head_data.texture_id, looks_type=SceneConstData.looktype_hair, looks_val= self.model.current_head_data.base_id})
    end
    if self.model.current_cloth_data ~= nil then
        self:remove_unitDataFashion(self.model.current_cloth_data.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_cloth_data.texture_id, looks_type=SceneConstData.looktype_dress, looks_val= self.model.current_cloth_data.base_id})
    end
    if self.model.current_waist_data ~= nil and self.model.current_waist_data.is_role ~= 1 then
        self:remove_unitDataFashion(self.model.current_waist_data.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_waist_data.effect_id, looks_type=SceneConstData.lookstype_belt, looks_val= self.model.current_waist_data.base_id})
    end
    if self.model.current_ring_data ~= nil then
        self:remove_unitDataFashion(self.model.current_ring_data.type, unitData)
        table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_ring_data.effect_id, looks_type=SceneConstData.lookstype_ring, looks_val= self.model.current_ring_data.base_id})
    end
    if self.model.current_head_dress_data ~= nil and self.model.current_head_dress_data.is_role ~= 1 then
        self:remove_unitDataFashion(self.model.current_head_dress_data.type, unitData)
        table.insert(unitData.looks, {looks_str = "", looks_mode = self.model.current_head_dress_data.effect_id, looks_type=SceneConstData.lookstype_headsurbase, looks_val= self.model.current_head_dress_data.base_id})
    end
    if self.model.current_weapon_data ~= nil and self.model.current_weapon_data.is_role ~= 1 then
        self:remove_unitDataFashion(self.model.current_weapon_data.type, unitData)
        table.insert(unitData.looks, {looks_str = "", looks_mode = self.model:GetWeaponLookModel(self.model.current_weapon_data.model_id), looks_type=SceneConstData.looktype_weapon, looks_val= self.model.current_weapon_data.model_id})
    end

    for i=1,#data_list do
        local data = data_list[i]
        if data ~= nil then
            -- 如果传入的data不为nil，则模型还在试穿状态
            self:remove_unitDataFashion(data.type, unitData) --脱下当前同类型的
            local _looks_mode = 0
            if data.type == SceneConstData.looktype_hair then
                self.model.current_head_data = data
                _looks_mode = data.texture_id
                table.insert(unitData.looks, {looks_str = "", looks_mode = _looks_mode, looks_type=data.type, looks_val= data.base_id})
            elseif data.type == SceneConstData.looktype_dress then
                self.model.current_cloth_data = data
                _looks_mode = data.texture_id
                table.insert(unitData.looks, {looks_str = "", looks_mode = _looks_mode, looks_type=data.type, looks_val= data.base_id})
            elseif data.type == SceneConstData.lookstype_belt then
                self.model.current_waist_data = data
                _looks_mode = data.effect_id
                if data.is_role ~= 1 then
                    table.insert(unitData.looks, {looks_str = "", looks_mode = _looks_mode, looks_type=data.type, looks_val= data.base_id})
                end
            elseif data.type == SceneConstData.lookstype_ring then
                self.model.current_ring_data = data
                table.insert(unitData.looks, {looks_str = "", looks_mode = _looks_mode, looks_type=data.type, looks_val= data.base_id})
            elseif data.type == SceneConstData.lookstype_headsurbase then
                self.model.current_head_dress_data = data
                _looks_mode = data.effect_id
                if data.is_role ~= 1 then
                    table.insert(unitData.looks, {looks_str = "", looks_mode = _looks_mode, looks_type=data.type, looks_val= data.base_id})
                end
            elseif data.type == SceneConstData.looktype_weapon then
                self.model.current_weapon_data = data
                _looks_mode = self.model:GetWeaponLookModel(data.model_id)
                if data.is_role ~= 1 then
                    table.insert(unitData.looks, {looks_str = "", looks_mode = _looks_mode, looks_type=data.type, looks_val= data.model_id})
                end
            end
        end
    end

    self:update_model_view(unitData.looks)
    self:update_current_fashion_item()

    if self.current_index == 1 or self.current_index == 0 then
        self.suit_tab:update_put_on_btn()
    elseif self.current_index == 2 then
        self.weapon_tab:update_put_on_btn()
    elseif self.current_index == 3 then
        self.belt_tab:update_put_on_btn()
    end
    self:update_materia_data()
    self:update_cur_prop()
end

--更新模型
function FashionMainWindow:update_model_view(_looks)
    -- BaseUtils.dump(_looks)

    --判断下当前模型是不是跟要更新的模型是一样的， 是的话则不更新
    if self.last_looks ~= nil then
        --检查下是不是没变化
        if self.model:check_loos_is_same(self.last_looks, _looks) then
            return
        end
    end
    self.last_looks = _looks
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "FashionMainWindowRole"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end


function FashionMainWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)

    local has_belt = false
    --检查下有没有腰饰
    for i=1,#self.last_looks do
        if self.last_looks[i].looks_type == SceneConstData.lookstype_belt then
            has_belt = true
            break
        end
    end

    if has_belt and self.model.has_onclick_belt_item then
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.Backward, 0))
    end
    self.model.has_onclick_belt_item = false

    if self.current_index == 2 then
        composite:PlayMotion(FighterAction.BattleStand)
    else
        composite:PlayMotion(FighterAction.Stand)
    end

    self.Preview:SetActive(true)
end


-------------------套装计时器逻辑
--开始战斗倒计时
function FashionMainWindow:start_timer()
    self:stop_timer()
    self.ClockCon.gameObject:SetActive(true)
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function FashionMainWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
    self.ClockCon:SetActive(false)
end

function FashionMainWindow:timer_tick()
    local left_time = self.suit_tab.last_selected_item.data.expire_time - BaseUtils.BASE_TIME
    if left_time > 0 then
        self.ClockCon_TxtCloth.text = self.model:convert_left_time_str(left_time)
    else
        self:stop_timer()
    end
end


-------------------饰品计时器逻辑
--开始战斗倒计时
function FashionMainWindow:start_belt_timer(_data)
    self.cur_belt_data = _data
    self.ClockCon.gameObject:SetActive(true)
    if _data.active == 1 then
        --已激活
        if _data.expire_time == 0 then
            self.ClockCon_TxtCloth.text = TI18N("剩余时间：永久")
            return
        end
    end
    self:stop_belt_timer()
    self.ClockCon.gameObject:SetActive(true)
    self.timer_belt_id = LuaTimer.Add(0, 1000, function() self:timer_belt_tick() end)
end

function FashionMainWindow:stop_belt_timer()
    if self.timer_belt_id ~= 0 then
        LuaTimer.Delete(self.timer_belt_id)
        self.timer_belt_id = 0
    end
    self.ClockCon:SetActive(false)
end

function FashionMainWindow:timer_belt_tick()
    local left_time = self.cur_belt_data.expire_time - BaseUtils.BASE_TIME
    if left_time > 0 then
        self.ClockCon_TxtCloth.text = self.model:convert_left_time_str(left_time)
    else
        self:stop_belt_timer()
    end
end

-- 显示当前时装的总属性
function FashionMainWindow:ShowAllAttr()
    -- 不显示属性了
    if true then
        self.attrContainer:SetActive(false)
        return
    end

    local data_list = {}
    if FashionManager.Instance.model.current_fashion_list ~= nil then
        local list = FashionManager.Instance.model:get_suit_data_list()
        for i,v in pairs(list) do
            if v.active == 1 then
                table.insert(data_list, v)
            end
        end
    end

    if FashionManager.Instance.model.current_fashion_list ~= nil then
        local list = FashionManager.Instance.model:get_belt_data_list()
        for i,v in pairs(list) do
            if v.active == 1 then
                table.insert(data_list, v)
            end
        end
    end

    if FashionManager.Instance.model.current_fashion_list ~= nil then
        local list = FashionManager.Instance.model:get_weapon_data_list()
        for i,v in pairs(list) do
            if v.active == 1 then
                table.insert(data_list, v)
            end
        end
    end

    local vals = {}
    for i,data in ipairs(data_list) do
        if data.attrs ~= nil then
            for i,v in ipairs(data.attrs) do
                if vals[v.effect_type] == nil then
                    vals[v.effect_type] = {effect_type = v.effect_type, val = 0}
                end
                vals[v.effect_type].val = vals[v.effect_type].val + v.val
            end
        end
    end

    local valsList = {}
    for k,v in pairs(vals) do
        table.insert(valsList, v)
    end

    -- 如果要显示属性出来，这里要小心，预设里面只有三个位置，而属性列表可能超过三个
    if #valsList > 0 then
        table.sort(valsList, function(a,b) return a.effect_type < b.effect_type end)

        for i,v in ipairs(self.attrObjList) do
            v:SetActive(false)
        end

        for i,v in ipairs(valsList) do
            self.attrImgList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon" .. v.effect_type)
            self.attrTxtList[i].text = string.format("%s:<color='#00ff00'>%s</color>", KvData.attr_name[v.effect_type], v.val)
            self.attrObjList[i]:SetActive(true)
        end
        -- self.attrContainer:SetActive(true)
        self.attrContainer:SetActive(false)
    else
        self.attrContainer:SetActive(false)
    end
end

function FashionMainWindow:ShowTips(data)
    self.fashionTips:Show(data)
end
