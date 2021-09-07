-- ----------------------------------------------------------
-- UI - 宠物喂养窗口 资质面板
-- ----------------------------------------------------------
PetFeedView_Quality = PetFeedView_Quality or BaseClass(BasePanel)

function PetFeedView_Quality:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "PetFeedView_Quality"
    self.resList = {
        {file = AssetConfig.pet_feed_window_quality, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.petData = nil

    self.bar_list = {}
    self.select_image = nil
    self.item_slot = nil
    self.aptitude = 2
    self.headLoaderList = {}

    -- self.frozenButton = nil
    self.buttonscript = nil

    ------------------------------------------------
    self._update_pet = function() self:update_pet() end
    self._update_items = function() self:update_items() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetFeedView_Quality:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_feed_window_quality))
    self.gameObject.name = "PetFeedView_Quality"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    -- self.transform:SetAsFirstSibling()

    local transform = self.transform


    -- 按钮功能绑定
    -- local btn
    -- btn = transform:FindChild("Button"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:button_click() end)
    -- self.frozenButton = FrozenButton.New(btn.gameObject.transform)
    self.buttonscript = BuyButton.New(transform:FindChild("Button"), TI18N("喂养资质"), true)
    self.buttonscript.key = "PetFeed"
    self.buttonscript.protoId = 10510
    -- self.buttonscript:Set_btn_img("DefaultButton2")
    self.buttonscript:Show()

    self.money_text = transform:FindChild("Button/Num"):GetComponent(Text)

    transform:FindChild("PetHead/ClickArea").gameObject:GetComponent(Button).onClick:AddListener(
        function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, {function(data) self:selectPet(data) end}) end)

    transform:FindChild("PetHead/Button").gameObject:GetComponent(Button).onClick:AddListener(
        function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, {function(data) self:selectPet(data) end}) end)

    self.item_slot = ItemSlot.New()
    UIUtils.AddUIChild(transform:FindChild("ItemSolt").gameObject, self.item_slot.gameObject)

    for i = 1, 5 do
        local bar = transform:FindChild("WashPanel/WashItem"..i).gameObject
        table.insert(self.bar_list, bar)

        bar:GetComponent(Button).onClick:AddListener(function() self:bar_click(bar) end)
    end

    self.select_image = transform:FindChild("WashPanel/Select").gameObject

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function PetFeedView_Quality:__delete()
    self.OnHideEvent:Fire()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    if self.item_slot ~= nil then
        self.item_slot:DeleteMe()
        self.item_slot = nil
    end
    -- if self.frozenButton ~= nil then
    --     self.frozenButton:DeleteMe()
    -- end
    if self.buttonscript ~= nil then
        self.buttonscript:DeleteMe()
        self.buttonscript = nil
    end
end

function PetFeedView_Quality:OnShow()
    PetManager.Instance.OnUpdatePetList:Add(self._update_pet)
    PetManager.Instance.OnPetUpdate:Add(self._update_pet)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._update_items)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._update_items)

    self.petData = self.model.cur_petdata

    self:update()
end

function PetFeedView_Quality:OnHide()
    PetManager.Instance.OnUpdatePetList:Remove(self._update_pet)
    PetManager.Instance.OnPetUpdate:Remove(self._update_pet)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._update_items)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._update_items)
end

function PetFeedView_Quality:update()
    if self.petData == nil then return end
    self:update_pet()
    self:update_items()
end

function PetFeedView_Quality:update_pet()
    if self.petData == nil then return end
    self:update_base()
    self:update_quality()
end


function PetFeedView_Quality:update_base()
    local petData = self.petData
    local panel = self.transform:FindChild("PetHead").gameObject
    panel.transform:FindChild("NameText"):GetComponent(Text).text = self.model:get_petname(petData)--petData.name
    panel.transform:FindChild("LVText"):GetComponent(Text).text = string.format(TI18N("等级：%s"), petData.lev)

    local headId = tostring(petData.base.head_id)
    local loaderId = panel.transform:FindChild("Head_78/Head").gameObject:GetInstanceID()
    if self.headLoaderList[loaderId] == nil then
        self.headLoaderList[loaderId] = SingleIconLoader.New(panel.transform:FindChild("Head_78/Head").gameObject)
    end
    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
    -- panel.transform:FindChild("Head_78/Head"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        -- headitem.transform:FindChild("Head_78/Head"):GetComponent(Image):SetNativeSize()
    panel.transform:FindChild("Head_78/Head"):GetComponent(Image).rectTransform.sizeDelta = Vector2(64, 64)
end

function PetFeedView_Quality:update_quality()
    local petData = self.petData

    if (petData.phy_aptitude / petData.base.phy_aptitude) > 0.97 then
        self.bar_list[1].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.phy_aptitude, petData.max_phy_aptitude)
    else
        self.bar_list[1].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    end
    if (petData.pdef_aptitude / petData.base.pdef_aptitude) > 0.97 then
        self.bar_list[2].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.pdef_aptitude, petData.max_pdef_aptitude)
    else
        self.bar_list[2].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    end
    if (petData.hp_aptitude / petData.base.hp_aptitude) > 0.97 then
        self.bar_list[3].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.hp_aptitude, petData.max_hp_aptitude)
    else
        self.bar_list[3].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    end
    if (petData.magic_aptitude / petData.base.magic_aptitude) > 0.97 then
        self.bar_list[4].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.magic_aptitude, petData.max_magic_aptitude)
    else
        self.bar_list[4].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    end
    if (petData.aspd_aptitude / petData.base.aspd_aptitude) > 0.97 then
        self.bar_list[5].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("<color='#ffffff'>%s/%s</color>", petData.aspd_aptitude, petData.max_aspd_aptitude)
    else
        self.bar_list[5].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)
    end

    -- self.bar_list[1].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    -- self.bar_list[2].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    -- self.bar_list[3].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    -- self.bar_list[4].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    -- self.bar_list[5].transform:FindChild("ValueSlider/Text"):GetComponent(Text).text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)

    local slider1 = self.bar_list[1].transform:FindChild("ValueSlider/Slider"):GetComponent(Slider)
    BaseUtils.tweenDoSlider(slider1, slider1.value, (petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    local slider2 = self.bar_list[2].transform:FindChild("ValueSlider/Slider"):GetComponent(Slider)
    BaseUtils.tweenDoSlider(slider2, slider2.value, (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    local slider3 = self.bar_list[3].transform:FindChild("ValueSlider/Slider"):GetComponent(Slider)
    BaseUtils.tweenDoSlider(slider3, slider3.value, (petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    local slider4 = self.bar_list[4].transform:FindChild("ValueSlider/Slider"):GetComponent(Slider)
    BaseUtils.tweenDoSlider(slider4, slider4.value, (petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2, 0.3)
    local slider5 = self.bar_list[5].transform:FindChild("ValueSlider/Slider"):GetComponent(Slider)
    BaseUtils.tweenDoSlider(slider5, slider5.value, (petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2, 0.3)

    local basedata = petData.base
    local genreratio = 1
    if petData.genre == 1 then genreratio = 1.03 end

    --物攻
    local min_aptitude = basedata.phy_aptitude * 0.8
    local percent = (petData.phy_aptitude - min_aptitude) / (petData.max_phy_aptitude - min_aptitude)
    if percent < 0 then percent = 0 end
    if percent >= 1 then
        self.bar_list[1].transform:FindChild("I18N_Text"):GetComponent(Text).text = TI18N("已满")
    else
        local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
        local quality_add = (petData.max_phy_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
        local quality_add1 = math.floor(quality_add)
        if quality_add1 < 5 then quality_add1 = 5 end
        local quality_add2 = math.floor(quality_add * 1.6)
        if quality_add2 < 5 then quality_add2 = 5 end
        self.bar_list[1].transform:FindChild("I18N_Text"):GetComponent(Text).text = string.format(TI18N("增加%s-%s点"), quality_add1, quality_add2)
    end
    --物防
    local min_aptitude = basedata.pdef_aptitude * 0.8
    local percent = (petData.pdef_aptitude - min_aptitude) / (petData.max_pdef_aptitude - min_aptitude)
    if percent < 0 then percent = 0 end
    if percent >= 1 then
        self.bar_list[2].transform:FindChild("I18N_Text"):GetComponent(Text).text = TI18N("已满")
    else
        local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
        local quality_add = (petData.max_pdef_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
        local quality_add1 = math.floor(quality_add)
        if quality_add1 < 5 then quality_add1 = 5 end
        local quality_add2 = math.floor(quality_add * 1.6)
        if quality_add2 < 5 then quality_add2 = 5 end
        self.bar_list[2].transform:FindChild("I18N_Text"):GetComponent(Text).text = string.format(TI18N("增加%s-%s点"), quality_add1, quality_add2)
    end
    --生命
    local min_aptitude = basedata.hp_aptitude * 0.8
    local percent = (petData.hp_aptitude - min_aptitude) / (petData.max_hp_aptitude - min_aptitude)
    if percent < 0 then percent = 0 end
    if percent >= 1 then
        self.bar_list[3].transform:FindChild("I18N_Text"):GetComponent(Text).text = TI18N("已满")
    else
        local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
        local quality_add = (petData.max_hp_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
        local quality_add1 = math.floor(quality_add)
        if quality_add1 < 5 then quality_add1 = 5 end
        local quality_add2 = math.floor(quality_add * 1.6)
        if quality_add2 < 5 then quality_add2 = 5 end
        self.bar_list[3].transform:FindChild("I18N_Text"):GetComponent(Text).text = string.format(TI18N("增加%s-%s点"), quality_add1, quality_add2)
    end
    --法力
    local min_aptitude = basedata.magic_aptitude * 0.8
    local percent = (petData.magic_aptitude - min_aptitude) / (petData.max_magic_aptitude - min_aptitude)
    if percent < 0 then percent = 0 end
    if percent >= 1 then
        self.bar_list[4].transform:FindChild("I18N_Text"):GetComponent(Text).text = TI18N("已满")
    else
        local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
        local quality_add = (petData.max_magic_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
        local quality_add1 = math.floor(quality_add)
        if quality_add1 < 5 then quality_add1 = 5 end
        local quality_add2 = math.floor(quality_add * 1.6)
        if quality_add2 < 5 then quality_add2 = 5 end
        self.bar_list[4].transform:FindChild("I18N_Text"):GetComponent(Text).text = string.format(TI18N("增加%s-%s点"), quality_add1, quality_add2)
    end
    --速度
    local min_aptitude = basedata.aspd_aptitude * 0.8
    local percent = (petData.aspd_aptitude - min_aptitude) / (petData.max_aspd_aptitude - min_aptitude)
    if percent < 0 then percent = 0 end
    if percent >= 1 then
        self.bar_list[5].transform:FindChild("I18N_Text"):GetComponent(Text).text = TI18N("已满")
    else
        local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
        local quality_add = (petData.max_aspd_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
        local quality_add1 = math.floor(quality_add)
        if quality_add1 < 5 then quality_add1 = 5 end
        local quality_add2 = math.floor(quality_add * 1.6)
        if quality_add2 < 5 then quality_add2 = 5 end
        self.bar_list[5].transform:FindChild("I18N_Text"):GetComponent(Text).text = string.format(TI18N("增加%s-%s点"), quality_add1, quality_add2)
    end

    for i = 1, 5 do
        self.transform:FindChild(string.format("WashPanel/Recommend%s", i)).gameObject:SetActive(table.containValue(petData.base.recommend_aptitudes, i))
    end
end

function PetFeedView_Quality:update_items()
    local petData = self.petData
    local num = BackpackManager.Instance:GetItemCount(20007)
    local itemData = BackpackManager.Instance:GetItemBase(20007)
    itemData.quantity = num
    self.item_slot:SetAll(itemData)
    if num == 0 then
        self.item_slot:SetGrey(true)
    else
        self.item_slot:SetGrey(false)
    end

    self.buttonscript:Layout({[20007] = {need = 1}}, function() self:button_click() end, function(prices) self:price_back(prices) end, { antofreeze = false })
end

function PetFeedView_Quality:bar_click(gameObject)
    self.select_image.transform.localPosition = gameObject.transform.localPosition

    if gameObject == self.bar_list[1] then
        self.aptitude = 2
    elseif gameObject == self.bar_list[2] then
        self.aptitude = 3
    elseif gameObject == self.bar_list[3] then
        self.aptitude = 1
    elseif gameObject == self.bar_list[4] then
        self.aptitude = 4
    elseif gameObject == self.bar_list[5] then
        self.aptitude = 5
    end
end

function PetFeedView_Quality:price_back(prices)
    if prices[20007] == nil then
        self.buttonscript:Set_btn_txt(TI18N("喂养资质"))
        self.money_text.gameObject:SetActive(false)
    else
        self.buttonscript:Set_btn_txt("")
        -- if prices[20007].allprice > 0 then
        --     self.money_text.color = Color(1, 1, 0.6)
        -- else
        --     self.money_text.color = Color(1, 0, 0)
        -- end
        self.money_text.text = tonumber(math.abs(prices[20007].allprice))
        self.money_text.gameObject:SetActive(true)
        -- self.money_text.transform:SetAsLastSibling()
        self.money_text.gameObject.transform:SetParent(self.buttonscript.transform)
    end
end

function PetFeedView_Quality:button_click()
    -- if BackpackManager.Instance:GetItemCount(20007) > 0 then
        -- self.frozenButton:OnClick()
        PetManager.Instance:Send10510(self.petData.id, self.aptitude)
    -- else
    --     -- local info = {trans = nil, data = { base = mod_item.item_base_data(20007) }, is_equip = is_eq, num_need = 0, show_num = true, is_lock = false, show_name = "", is_new = false, is_select = false, inbag = false, show_tips = true, show_select = true, drop_only = false}
    --     -- mod_tips.item_tips(info)
    --     NoticeManager.Instance:FloatTipsByString("道具不足")
    -- end
end

function PetFeedView_Quality:selectPet(data)
    if data ~= nil then
        self.petData = data
        self.model.cur_petdata = data
        self:update()

        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("切换成功，当前选中宠物切换为<color=#00FF00>%s</color>"), tostring(data.name)))
    end
end