FashionSuitTab = FashionSuitTab or BaseClass(BasePanel)

function FashionSuitTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.fashion_suit_tab, type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.has_init = false

    self.item_list = nil
    self.current_data_list = nil
    self.cur_tab_go = nil

    self.last_selected_item = nil

    self.head_color_list = nil
    self.cloth_color_list = nil
    self.head_color_index = 1
    self.cloth_color_index = 1
    self.tab_index = 1

    self.on_save_fashion = function()
        self:on_click_put_on_btn()
    end

    self.on_bottom_prices_back = function(prices)
        self:OnPriceBack(prices)
    end

    self.on_item_update = function()
        if self.last_selected_item  ~= nil then
            self:UpdateClothCost(self.last_selected_item.data.active)
        end
    end

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_item_update)
    return self
end

function FashionSuitTab:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end
    if self.BtnSave_btn ~= nil then
        self.BtnSave_btn:DeleteMe()
        self.BtnSave_btn = nil
    end

    self.head_color_list = nil
    self.cloth_color_list = nil
    self.head_color_index = 1
    self.cloth_color_index = 1

    self.cur_tab_go = nil
    self.gameObject = nil
    self.has_init = false
    if self.item_list ~= nil then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end

    if self.ClothCostSlot ~= nil then
        self.ClothCostSlot:DeleteMe()
        self.ClothCostSlot = nil
    end

    if self.slot_go_list ~= nil then
        for i,v in ipairs(self.slot_go_list) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slot_go_list = nil
    end

    self.last_selected_item = nil
    self.current_data_list = nil

    self:AssetClearAll()
end

function FashionSuitTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_suit_tab))
    self.gameObject.name = "FashionSuitTab"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.ConRight)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, 0, 0)


    ----选项卡按钮
    self.ColorTabBtn = self.transform:FindChild("ConTop"):FindChild("BtnColor"):GetComponent(Button)
    self.ClothTabBtn = self.transform:FindChild("ConTop"):FindChild("BtnCloth"):GetComponent(Button)
    self.tab_text_color1 = self.ClothTabBtn.transform:FindChild("Text"):GetComponent(Text).color
    self.tab_text_color2 = self.ColorTabBtn.transform:FindChild("Text"):GetComponent(Text).color
    self.ColorTabBtn.onClick:AddListener( function() self:on_click_tab(self.ColorTabBtn.gameObject) end)
    self.ClothTabBtn.onClick:AddListener( function() self:on_click_tab(self.ClothTabBtn.gameObject) end)
    self.cur_tab_go = self.ClothTabBtn.gameObject

    --套装底部
    self.ConClothBottom = self.transform:Find("ClothTab/ConClothBottom")
    self.BttomTxtLock = self.ConClothBottom:FindChild("TxtLock"):GetComponent(Text)
    self.BttomTxtLock.text = TI18N("请选择要穿戴的套装")
    self.ClothSaveBtn = self.ConClothBottom:Find("BtnPutOn"):GetComponent(Button)
    self.ClothSaveBtnTxt = self.ConClothBottom:Find("BtnPutOn/Text"):GetComponent(Text)
    self.ClothCostCon = self.ConClothBottom:Find("TxtCon")
    self.ClothCostTxt = self.ConClothBottom:Find("TxtCon/Slot1/TxtName"):GetComponent(Text)
    self.ClothCostGetBtn = self.ConClothBottom:Find("TxtCon/BtnGet"):GetComponent(Button)
    self.ClothCostGetBtnTxt = self.ConClothBottom:Find("TxtCon/BtnGet/Text"):GetComponent(Text)
    self.ClothCostSlotCon = self.ConClothBottom:Find("TxtCon/Slot1/SlotCon")
    self.ClothCostSlot = self:CreateSlot(self.ClothCostSlotCon)
    self.ClothCostGetBtn.gameObject:SetActive(true)
    self.ClothCostCon.gameObject:SetActive(false)

    self.BtnUpEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.BtnUpEffect.transform:SetParent(self.ClothCostGetBtn.transform)
    self.BtnUpEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.BtnUpEffect.transform, "UI")
    self.BtnUpEffect.transform.localScale = Vector3(1.5, 0.8, 1)
    self.BtnUpEffect.transform.localPosition = Vector3(-47.4, -19, -400)
    self.BtnUpEffect.gameObject:SetActive(false)

    --染色底部保存购买按钮
    self.ConBottom = self.transform:Find("ColorTab/ConBottom")
    self.BtnSave = self.ConBottom:FindChild("BtnPutOn").gameObject
    self.ImgTanHao = self.ConBottom:FindChild("ImgTanHao"):GetComponent(Button)
    self.BtnSave_btn= BuyButton.New(self.BtnSave, TI18N("保 存"))
    self.BtnSave_btn.key = "FashionSave"
    self.BtnSave_btn.protoId = 13201
    self.BtnSave_btn:Show()

    self.BtnSave:SetActive(false)

    ----套装选项卡
    self.ClothTab = self.transform:FindChild("ClothTab")
    self.MaskLayer = self.ClothTab:FindChild("MaskLayer")
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer")
    self.LayoutLayer = self.ScrollLayer.transform:FindChild("LayoutLayer")
    self.LayoutLayer_rect = self.LayoutLayer:GetComponent(RectTransform)
    self.origin_item = self.LayoutLayer:FindChild("Item").gameObject
    self.origin_item:SetActive(false)


    -----染色选项卡
    self.ColorTab = self.transform:FindChild("ColorTab")
    self.HeadColorCon = self.ColorTab:FindChild("HeadColorCon")
    self.Head_MidCon = self.HeadColorCon:FindChild("MidCon")
    self.Head_LeftBtn = self.Head_MidCon:FindChild("LeftBtn"):GetComponent(Button)
    self.Head_RightBtn = self.Head_MidCon:FindChild("RightBtn"):GetComponent(Button)
    self.Head_ImgTxtBg = self.Head_MidCon:FindChild("ImgTxtBg")
    self.Head_TxtSlolution = self.Head_ImgTxtBg:FindChild("TxtSlolution"):GetComponent(Text)
    self.TxtHeadHasGet = self.HeadColorCon:FindChild("TxtHeadHasGet"):GetComponent(Text)

    self.ClothColorCon = self.ColorTab:FindChild("ClothColorCon")
    self.Cloth_MidCon = self.ClothColorCon:FindChild("MidCon")
    self.Cloth_LeftBtn = self.Cloth_MidCon:FindChild("LeftBtn"):GetComponent(Button)
    self.Cloth_RightBtn = self.Cloth_MidCon:FindChild("RightBtn"):GetComponent(Button)
    self.Cloth_ImgTxtBg = self.Cloth_MidCon:FindChild("ImgTxtBg")
    self.Cloth_TxtSlolution = self.Cloth_ImgTxtBg:FindChild("TxtSlolution"):GetComponent(Text)
    self.TxtClothHasGet = self.ClothColorCon:FindChild("TxtClothHasGet"):GetComponent(Text)

    self.ColorCostCon = self.ColorTab:FindChild("TxtCon")
    self.slot_go_list = {}
    self.Slot_list = {}
    self.Slot_Con_list = {}
    self.TxtValue_list = {}
    self.Textmz_list = {}
    self.imgAssetIcon_list = {}
    self.ImgTxtBg_list = {}

    for i=1,3 do
        self.Slot_list[i] = self.ColorCostCon.transform:FindChild(string.format("Slot%s", i)).gameObject
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

    self.TxtHeadHasGet.text = ""
    self.TxtClothHasGet.text = ""

    self.ImgTanHao.onClick:AddListener( function()
        local tips = {}
        table.insert(tips, TI18N("1.套装与染色可以搭配使用，套装仅通过<color='#ffff00'>特殊途径</color>获得"))
        table.insert(tips, TI18N("2.染色方案购买过之后可重复使用，切换至<color='#ffff00'>已拥有</color>的染色方案只需消耗少量<color='#ffff00'>换装费用（月光绒*5）</color>"))
        table.insert(tips, TI18N("3.切换至<color='#ffff00'>已激活套装</color>或<color='#ffff00'>原始染色</color>时，没有消耗"))
        TipsManager.Instance:ShowText({gameObject = self.ImgTanHao.gameObject, itemData = tips})
    end)

    self.Head_LeftBtn.onClick:AddListener(function()
        self:on_click_head_left_btn()
    end)
    self.Head_RightBtn.onClick:AddListener(function()
        self:on_click_head_right_btn()
    end)
    self.Cloth_LeftBtn.onClick:AddListener(function()
        self:on_click_body_left_btn()
    end)
    self.Cloth_RightBtn.onClick:AddListener(function()
        self:on_click_body_right_btn()
    end)
    self.ClothSaveBtn.onClick:AddListener(function()
        self:on_click_put_on_btn()
    end)
    self.ClothCostGetBtn.onClick:AddListener(function()
        --检查下该商品，商城是否有卖，有则弹出购买界面
        if self.tab_index == 1 then
            local cost_dic = self.parent.model:count_fashion_loss(self.last_selected_item.data)
            local baseId = 0
            local needNum = 0
            for k, need in pairs(cost_dic) do
                if need ~= 0 then
                    baseId = k
                    needNum = need
                end
            end

            if baseId ~= 0 then
                local hasNum = BackpackManager.Instance:GetItemCount(baseId)
                if hasNum >= needNum then
                    --使用
                    local temp = BackpackManager.Instance:GetItemByBaseid(baseId)[1]
                    BackpackManager.Instance:Use(temp.id, 1, baseId)
                else
                    local base_data = DataItem.data_get[baseId]
                    local dropstr = ""
                    for i, data in ipairs(base_data.tips_type) do
                        if data.tips == 2 then
                            dropstr = data.val
                            break
                        end
                    end
                    local canBuy = false
                    for code,argstr,label,desc,icon in string.gmatch(dropstr, "{(%d-);(.-);(.-);(.-);(%d-)}") do
                        local args = StringHelper.Split(argstr, "|")
                        local tempCode = code
                        if #args == 0 then
                            table.insert(args,tonumber(argstr))
                        end
                        if tonumber(tempCode) == TipsEumn.DropCode.OpenWindow then
                            if #args == 3 then
                                if  tonumber(args[1]) == WindowConfig.WinID.shop and tonumber(args[2]) == 1 and tonumber(args[3]) == 4 then
                                    canBuy = true
                                    break
                                end
                            end
                        end
                    end

                    if baseId == 29664 or baseId == 29665 then -- 特殊时装处理
                        local info = {itemData = base_data, gameObject = self.ClothCostGetBtn.gameObject}
                        TipsManager.Instance:ShowItem(info)
                    elseif canBuy then
                        --可以买,直接打开便捷购买
                        ShopManager.Instance.model:OpenQuickBuyPanel(baseId)
                    else
                        local info = {itemData = base_data, gameObject = self.ClothCostGetBtn.gameObject}
                        TipsManager.Instance:ShowItem(info)
                    end
                end
            end
        end
    end)

    self.has_init = true

    FashionManager.Instance:request13200()
end

-------------------更新套装底部消耗
function FashionSuitTab:UpdateClothCost(active)
    self.BttomTxtLock.text = ""--TI18N("该套装尚未激活，无法穿戴")
    if active == 1 then
        --已经激活
        self.ClothCostCon.gameObject:SetActive(false)
        self.ClothSaveBtn.gameObject:SetActive(true)
    else
        local cost_dic = self.parent.model:count_fashion_loss(self.last_selected_item.data)
        -- self:update_cost_slot(cost_dic)
        local baseId = 0
        local needNum = 0
        for k, need in pairs(cost_dic) do
            if need ~= 0 then
                baseId = k
                needNum = need
            end
        end
        if baseId ~= 0 then
            self.ClothCostCon.gameObject:SetActive(true)
            self.ClothSaveBtn.gameObject:SetActive(false)
            local hasNum = BackpackManager.Instance:GetItemCount(baseId)
            local baseData = DataItem.data_get[baseId]
            self.ClothCostTxt.text = baseData.name
            self:SetSlotData(self.ClothCostSlot, baseData)
            self.ClothCostSlot:SetNum(hasNum, needNum)
            if hasNum >= needNum then
                self.ClothCostGetBtnTxt.text =  TI18N("使 用")
                self.BtnUpEffect.gameObject:SetActive(true)
            else
                self.ClothCostGetBtnTxt.text =  TI18N("获 取")
                self.BtnUpEffect.gameObject:SetActive(false)
            end
        end
    end
end

-------------------更新染色底部消耗
function FashionSuitTab:UpdateColorCost()
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

    local cost_dic = {}
    local head_cost_dic = nil
    local cloth_cost_dic = nil
    if self.current_head_color_data.id == 0 then
        head_cost_dic = {}
    elseif self.current_head_color_data.active == 0 then
        --未激活
        head_cost_dic = self.parent.model:count_fashion_loss(self.current_head_color_data)
    else
        --已激活
        if self.current_head_color_data.suit_type then
            head_cost_dic = {}
        else
            head_cost_dic = self.parent.model:count_color_change_loss(self.current_head_color_data)
        end
    end

    if self.current_cloth_color_data.id == 0 then
        cloth_cost_dic = {}
    elseif self.current_cloth_color_data.active == 0 then
        --未激活
        cloth_cost_dic = self.parent.model:count_fashion_loss(self.current_cloth_color_data)
    else
        --已激活
        if self.current_cloth_color_data.suit_type then
            cloth_cost_dic = {}
        else
            cloth_cost_dic = self.parent.model:count_color_change_loss(self.current_cloth_color_data)
        end
    end
    cost_dic = self.parent.model:merge_cost_dic(head_cost_dic, cloth_cost_dic)
    self:update_cost_slot(cost_dic)
end

--根据消耗列表显示底部消耗内容
function FashionSuitTab:update_cost_slot(cost_dic)
    if self.parent.model:count_dic_len(cost_dic) <= 0 then
        self.ColorCostCon.gameObject:SetActive(false)
    else
        for i = 1, #self.Slot_list do
            self.Slot_list[i]:SetActive(false)
        end
        self.ColorCostCon.gameObject:SetActive(true)
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
end

--请求底部个数价格回调
function FashionSuitTab:OnPriceBack(prices)
    for i=1,#self.slot_go_list do
        if self.slot_go_list[i] ~= nil then
            if self.slot_go_list[i].itemData ~= nil then
                local data = prices[self.slot_go_list[i].itemData.base_id]
                if data ~= nil then
                    self:OnPriceBackHelp(data, self.Textmz_list[i], self.imgAssetIcon_list[i])
                end
            end
        end
    end
end

function FashionSuitTab:OnPriceBackHelp(data, bottom_left_TxtVal, bottom_left_icon , _num)
    local allprice = data.allprice
    local price_str = ""
    if allprice >= 0 then
        price_str = string.format("<color='%s'>%s</color>", "#00ff00", allprice)
    else
        price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], -allprice)
    end
    bottom_left_TxtVal.text = price_str
    bottom_left_icon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[data.assets])
    bottom_left_icon.gameObject:SetActive(true)
end

-------------------------------------------监听逻辑
-------点击选项卡监听
function FashionSuitTab:on_click_tab(tab_go)
    if self.cur_tab_go == tab_go then
        --当前已经是这个了
        return
    end
    if self.parent.model.dyeing_fashion_list == nil then
        --协议还没回来
        return
    end
    self.cur_tab_go = tab_go
    if tab_go == self.ColorTabBtn.gameObject then
        self.BttomTxtLock.text = ""
        self.BtnSave:SetActive(true)

        self.tab_index = 2
        --切到染色
        self:switch_tab(self.ColorTab, self.ColorTabBtn)
        self:update_color_tab()
        self.ConClothBottom.gameObject:SetActive(false)
        self.ConBottom.gameObject:SetActive(true)
    elseif tab_go == self.ClothTabBtn.gameObject then
        print("----------------------1")
        self.ClothSaveBtn.gameObject:SetActive(false)
        self.BttomTxtLock.text = TI18N("请选择要穿戴的套装")
        self.ClothCostCon.gameObject:SetActive(false)
        self.BtnSave:SetActive(false)
        self.tab_index = 1
        --切到套装
        self:switch_tab(self.ClothTab, self.ClothTabBtn)
        self:update_cloth_tab()
        self.ConClothBottom.gameObject:SetActive(true)
        self.ConBottom.gameObject:SetActive(false)
    end
end

------点击头部染色左按钮
function FashionSuitTab:on_click_head_left_btn()
    self.head_color_index = self.head_color_index - 1
    if self.head_color_index <= 0 then
        self.head_color_index = #self.head_color_list
    end
    if self.head_color_list[self.head_color_index].base_id ~= nil then
        self.Head_TxtSlolution.text = self.head_color_list[self.head_color_index].name
    else
        self.Head_TxtSlolution.text = string.format(TI18N("<color='#82b5c8'>染色：</color>%s"), self.head_color_list[self.head_color_index].name)
    end

    self.TxtHeadHasGet.text = ""
    if self.head_color_list[self.head_color_index].active == 1 then
        self.TxtHeadHasGet.text = TI18N("已拥有")
    end

    --更新模型
    self:update_color_model()
end

------点击头部染色右按钮
function FashionSuitTab:on_click_head_right_btn()
    self.head_color_index = self.head_color_index + 1
    if self.head_color_index > #self.head_color_list then
        self.head_color_index = 1
    end
    if self.head_color_list[self.head_color_index].base_id ~= nil then
        self.Head_TxtSlolution.text = self.head_color_list[self.head_color_index].name
    else
        self.Head_TxtSlolution.text = string.format(TI18N("<color='#82b5c8'>染色：</color>%s"), self.head_color_list[self.head_color_index].name)
    end

    self.TxtHeadHasGet.text = ""
    if self.head_color_list[self.head_color_index].active == 1 then
        self.TxtHeadHasGet.text = TI18N("已拥有")
    end

    --更新模型
    self:update_color_model()
end

------点击身体染色左按钮
function FashionSuitTab:on_click_body_left_btn()
    self.cloth_color_index = self.cloth_color_index - 1
    if self.cloth_color_index <= 0 then
        self.cloth_color_index = #self.cloth_color_list
    end
    if self.cloth_color_list[self.cloth_color_index].base_id ~= nil then
        self.Cloth_TxtSlolution.text = self.cloth_color_list[self.cloth_color_index].name
    else
        self.Cloth_TxtSlolution.text = string.format(TI18N("<color='#82b5c8'>染色：</color>%s"), self.cloth_color_list[self.cloth_color_index].name)
    end


    self.TxtClothHasGet.text = ""
    if self.cloth_color_list[self.cloth_color_index].active == 1 then
        self.TxtClothHasGet.text = TI18N("已拥有")
    end


    --更新模型
    self:update_color_model()
end

------点击身体染色右按钮
function FashionSuitTab:on_click_body_right_btn()
    self.cloth_color_index = self.cloth_color_index + 1
    if self.cloth_color_index > #self.cloth_color_list then
        self.cloth_color_index = 1
    end

    if self.cloth_color_list[self.cloth_color_index].base_id ~= nil then
        self.Cloth_TxtSlolution.text = self.cloth_color_list[self.cloth_color_index].name
    else
        self.Cloth_TxtSlolution.text = string.format(TI18N("<color='#82b5c8'>染色：</color>%s"), self.cloth_color_list[self.cloth_color_index].name)
    end


    self.TxtClothHasGet.text = ""
    if self.cloth_color_list[self.cloth_color_index].active == 1 then
        self.TxtClothHasGet.text = TI18N("已拥有")
    end

    --更行模型
    self:update_color_model()
end


--------切换左边选项卡逻辑
function FashionSuitTab:switch_tab(selectTab, selectBtn)
    if self.has_init == false then
        return
    end
    self.transform:FindChild("ConTop"):FindChild("BtnCloth"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
    self.transform:FindChild("ConTop"):FindChild("BtnColor"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
    self.ColorTabBtn.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color2
    self.ClothTabBtn.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color2
    selectBtn.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
    selectBtn.transform:FindChild("Text"):GetComponent(Text).color = self.tab_text_color1

    self.ClothTab.gameObject:SetActive(false)
    self.ColorTab.gameObject:SetActive(false)
    selectTab.gameObject:SetActive(true)
end

----------------------------------------------重置状态
function FashionSuitTab:reset_item_list()
     -----------------------对item列表进行还原
    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local it = self.item_list[i]
            -- if it.data.is_wear == 1 then
            --     it:set_select(true)
            -- else
                it:set_select(false)
            -- end
        end
    end

    if self.tab_index == 1 then
        self.last_selected_item = nil
        self.ClothSaveBtn.gameObject:SetActive(false)
        self.BttomTxtLock.text = TI18N("请选择要穿戴的套装")
        self.ClothCostCon.gameObject:SetActive(false)
        self.BtnSave:SetActive(false)
    elseif self.tab_index == 2 then
         --将当前所穿或者缩染，排到第一项
        self:update_color_tab()
    end
end

----------------------------------------------更新逻辑
--更新左边模型，切换染色方案时使用
function FashionSuitTab:update_color_model()
    self.current_head_color_data = self.head_color_list[self.head_color_index]
    self.current_cloth_color_data = self.cloth_color_list[self.cloth_color_index]

    --在这里组装贴图数据
    local data_list = {}
    if self.current_head_color_data.suit_type == false then
        --这个是染色方案
        if self.current_head_color_data.id ~= 0 or self.last_selected_item ~= nil then
            --不是基础
            local temp = self.parent.model:get_default_fashion(SceneConstData.looktype_hair)
            temp.texture_id = self.current_head_color_data.skin_id
            table.insert(data_list, temp)
        elseif self.current_head_color_data.id == 0 and self.last_selected_item == nil then
            local temp = self.parent.model:get_default_fashion(SceneConstData.looktype_hair)
            temp.texture_id = 0
            table.insert(data_list, temp)
        end
    else
        --不是染色方案，是套装
        local temp = self.current_head_color_data
        table.insert(data_list, temp)
    end

    if self.current_cloth_color_data.suit_type == false then
        --这个是染色方案
        if self.current_cloth_color_data.id ~= 0 or self.last_selected_item ~= nil then
            --不是基础
            local temp = self.parent.model:get_default_fashion(SceneConstData.looktype_dress)
            temp.texture_id = self.current_cloth_color_data.skin_id
            table.insert(data_list, temp)
        elseif self.current_cloth_color_data.id == 0 or self.last_selected_item == nil then
            local temp = self.parent.model:get_default_fashion(SceneConstData.looktype_dress)
            temp.texture_id = 0
            table.insert(data_list, temp)
        end
    else
        --不是染色方案，是套装
        local temp = self.current_cloth_color_data
        table.insert(data_list, temp)
    end

    self.parent:update_batch_model(data_list)
    self:UpdateColorCost()
end

--更新染色逻辑，切换到染色tab时调用
function FashionSuitTab:update_color_tab()
    --更新染色面板的显示内容
    self.head_color_list = {}
    self.cloth_color_list = {}

    --获取配置染色数据
    local head_color_cfg_list = self.parent.model:get_color_prog_list_by_type(SceneConstData.looktype_hair)
    local cloth_color_cfg_list = self.parent.model:get_color_prog_list_by_type(SceneConstData.looktype_dress)

    --根据协议染色数据组装
    local head_color_socket_list = self.parent.model.dyeing_fashion_list[SceneConstData.looktype_hair]
    local cloth_color_socket_list = self.parent.model.dyeing_fashion_list[SceneConstData.looktype_dress]

    --组装头部染色列表
    for k, v in pairs(head_color_cfg_list) do
        if head_color_socket_list[v.id] ~= nil then
            v.active = 1
            v.is_use = head_color_socket_list[v.id].is_use
        else
            if v.id == 0 then
                v.active = 1
            else
                v.active = 0
            end
            v.is_use = 0
        end
        v.suit_type = false --标注这个是染色data
        table.insert(self.head_color_list, v)
    end

    --组装身体染色列表
    for k, v in pairs(cloth_color_cfg_list) do
        if cloth_color_socket_list[v.id] ~= nil then
            v.active = 1
            v.is_use = cloth_color_socket_list[v.id].is_use
        else
            if v.id == 0 then
                v.active = 1
            else
                v.active = 0
            end
            v.is_use = 0
        end
        v.suit_type = false --标注这个是染色data
        table.insert(self.cloth_color_list, v)
    end

    --把激活的套装的头和身分别insert到对应的染色表里面
    local head_cfg_list = self.parent.model:get_suit_fashion_list_by_type(SceneConstData.looktype_hair)
    local cloth_cfg_list = self.parent.model:get_suit_fashion_list_by_type(SceneConstData.looktype_dress)

    for i=1,#head_cfg_list do
        local h_cfg_dat = head_cfg_list[i]
        h_cfg_dat.suit_type = true --标注这个是套装data
        table.insert(self.head_color_list, h_cfg_dat)
    end

    for i=1,#cloth_cfg_list do
        local c_cfg_dat = cloth_cfg_list[i]
        c_cfg_dat.suit_type = true --标注这个是套装data
        table.insert(self.cloth_color_list, c_cfg_dat)
    end

    self.head_color_index = 1
    self.cloth_color_index = 1

    --将当前所穿或者缩染，排到第一项
    for i=1,#self.head_color_list do
        local temp = self.head_color_list[i]
        if temp.suit_type == false then
            local temp_socket = self.parent.model.dyeing_fashion_list[temp.type][temp.id]
            if temp_socket ~= nil and temp_socket.is_use == 1 then
                self.head_color_index = i
                break
            end
        else
            if temp.is_wear == 1 then
                self.head_color_index = i
                break
            end
        end
    end

    for i=1,#self.cloth_color_list do
        local temp = self.cloth_color_list[i]
        if temp.suit_type == false then
            local temp_socket = self.parent.model.dyeing_fashion_list[temp.type][temp.id]
            if temp_socket ~= nil and temp_socket.is_use == 1 then
                self.cloth_color_index = i
                break
            end
        else
            if temp.is_wear == 1 then
                self.cloth_color_index = i
                break
            end
        end
    end


    --初始化显示名字
    if self.head_color_list[self.head_color_index].base_id ~= nil then
        self.Head_TxtSlolution.text = self.head_color_list[self.head_color_index].name
    else
        self.Head_TxtSlolution.text = string.format(TI18N("<color='#82b5c8'>染色：</color>%s"), self.head_color_list[self.head_color_index].name)
    end


    if self.cloth_color_list[self.cloth_color_index].base_id ~= nil then
        self.Cloth_TxtSlolution.text = self.cloth_color_list[self.cloth_color_index].name
    else
        self.Cloth_TxtSlolution.text = string.format(TI18N("<color='#82b5c8'>染色：</color>%s"), self.cloth_color_list[self.cloth_color_index].name)
    end

    self.current_head_color_data = self.head_color_list[self.head_color_index]
    self.current_cloth_color_data = self.cloth_color_list[self.cloth_color_index]


    self.TxtClothHasGet.text = ""
    self.TxtHeadHasGet.text = ""
    if self.current_cloth_color_data.active == 1 then
        self.TxtClothHasGet.text = TI18N("已拥有")
    end
    if self.current_head_color_data.active == 1 then
        self.TxtHeadHasGet.text = TI18N("已拥有")
    end

    self:update_color_model()

end

--更新套装逻辑，切换到套装tab时调用
function FashionSuitTab:update_cloth_tab()


    -- if self.last_selected_item ~= nil then
    --     --设置成上次选中的那一条
    --      ------------------------这里后面要改掉，一条item拆分成一个头和一个衣服，然后再丢给 self.parent:update_batch_model(data_list)
    --     self:update_left(self.last_selected_item, true)
    -- else
    --     --上次没有选中任何一条则刷新下列表
    --     if self.current_data_list ~= nil then
    --         self:update_item_list(self.current_data_list)
    --     end
    --     self.parent:update_model()
    -- end
    self:update_item_list(self.parent.model:get_suit_data_list())
end


--更新右边数据列表
function FashionSuitTab:update_item_list(data_list)
    self.current_data_list = {}
    for k, v in pairs(data_list) do
        table.insert(self.current_data_list, v)
    end



    -- local priority_sort = function(a, b)
    --     return a.sort_id > b.sort_id --根据index从小到大排序
    -- end
    -- table.sort(self.current_data_list, priority_sort)

    local active_sort = function(a, b)
    if a.active ~= b.active then
        return a.active > b.active
    else
        return a.sort_id > b.sort_id --根据index从小到大排序
    end
        -- return a.active > b.active --根据index从小到大排序
    end
    table.sort(self.current_data_list, active_sort)

    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local it = self.item_list[i]
            if it.gameObject ~= nil then
                it.gameObject:SetActive(false)
                it:set_select(false)
            end
        end
    else
        self.item_list = {}
    end

    --根据数据量设置LayoutLayer 的高度
    local lineNum = math.floor(#self.current_data_list/3)
    local nextNum = #self.current_data_list%3
    lineNum = nextNum > 0 and (lineNum+1) or lineNum
    local newHeight = lineNum*100
    self.LayoutLayer_rect.sizeDelta = Vector2(self.LayoutLayer_rect.rect.width, newHeight)

    local has_wear_one = false

    for i=1,#self.current_data_list do
        local v = self.current_data_list[i]
        local item = self.item_list[i]
        if item == nil then
            item = FashionSuitItem.New(self, self.origin_item, i)
        else
            item:set_select(false)
            item.gameObject:SetActive(true)
        end
        if v.is_wear == 1 then
            has_wear_one = true
        end
        item:set_item_data(v)
        table.insert(self.item_list, item)
    end

    if self.last_selected_item ~=nil and self.last_selected_item.data ~= nil then
        self.last_selected_item:on_select_item()
        self.last_selected_item:set_select(true)
        has_wear_one = true
    else
        for i=1,#self.item_list do
            local item = self.item_list[i]
            if item.data.is_wear == 1 then
                item:on_select_item()
                item:set_select(true)
                has_wear_one = true
                break
            end
        end
    end

    if has_wear_one == false then
        self.parent:update_model()
    end
end

--选中某个时装
function FashionSuitTab:update_left(item, _force)
    --_force 不为nil，则是要求不考虑这个item是否选中
    if item.selected == true and _force == nil then
        --脱掉
        item:set_select(false)
        local temp = self.parent.model:get_default_fashion(item.data.type)
        self.last_selected_item = nil
        self.parent:update_model(temp)
        self.ClothSaveBtn.gameObject:SetActive(false)
        self.BttomTxtLock.text = TI18N("请选择要穿戴的套装")
        self.ClothCostCon.gameObject:SetActive(false)
        self.BtnSave:SetActive(false)
        -- self.parent:update_add_prop_str("")
    else
        if self.last_selected_item ~= nil then
            self.last_selected_item:set_select(false)
        end

        item:set_select(true)

        if self.tab_index == 1 then
            self:UpdateClothCost(item.data.active)
        else
            if item.data.active == 1 then
                self.BtnSave:SetActive(true)
            else
                self.BtnSave:SetActive(false)
            end
        end

        local head_data = DataFashion.data_base[item.data.include[1].fashion_id]
        local cloth_data = DataFashion.data_base[item.data.include[2].fashion_id]
        local data_list = {}
        table.insert(data_list, head_data)
        table.insert(data_list, cloth_data)
        self.parent:update_batch_model(data_list)
        -- self.parent:update_add_prop_str(self.last_selected_item.data.addpoint_str)
    end
end


---------------------------------------监听器逻辑

--穿戴按钮点击监听
function FashionSuitTab:on_click_put_on_btn()
    print("on_click_put_on_btn")
    if self.parent.model.current_head_data == nil and self.parent.model.current_cloth_data == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前形象没有任何变化"))
        self.BtnSave_btn:ReleaseFrozon()
        return
    end
    if self.tab_index == 1 then
        --套装的逻辑
        if self.last_selected_item ~= nil then
            --是有选择套装要穿戴
            if self.last_selected_item.data.is_wear == 1 then
                NoticeManager.Instance:FloatTipsByString(TI18N("该套装已经穿戴"))
                self.BtnSave_btn:ReleaseFrozon()
                return
            end

            if self.last_selected_item.data.active == 0 then
                -- print(1)
                --未激活
                if #self.last_selected_item.data.loss ~= 0 then
                    for j=1,#self.last_selected_item.data.loss do
                        local loss_data = self.last_selected_item.data.loss[j]
                        local has = BackpackManager.Instance:GetItemCount(loss_data.val[1][1])
                        local need = loss_data.val[1][2]
                        if has < need then
                            -- print(2)
                            NoticeManager.Instance:FloatTipsByString(TI18N("缺少可兑换的道具"))
                            self.BtnSave_btn:ReleaseFrozon()
                            return
                        end
                    end
                end
            end
        end
        local head_id = self.parent.model.current_head_data.base_id
        if self.parent.model.current_head_data.is_origin == 1 then
            head_id = 0
        end
        local cloth_id = self.parent.model.current_cloth_data.base_id
        if self.parent.model.current_cloth_data.is_origin == 1 then
            cloth_id = 0
        end
        FashionManager.Instance:request13201(0, head_id, 0, cloth_id)
    else
        --染色的逻辑
        local head_id = 0
        if self.parent.model.current_head_data ~=nil and self.parent.model.current_head_data.is_origin == 0 then
            --不是基础
            head_id = self.parent.model.current_head_data.base_id
        end
        local cloth_id = 0
        if self.parent.model.current_cloth_data ~= nil and self.parent.model.current_cloth_data.is_origin == 0 then
            cloth_id = self.parent.model.current_cloth_data.base_id
        end
        local head_color_id = 0
        local cloth_color_id = 0
        if self.current_cloth_color_data.suit_type == false then
            cloth_color_id = self.current_cloth_color_data.id
        end
        if self.current_head_color_data.suit_type == false then
            head_color_id = self.current_head_color_data.id
        end

        FashionManager.Instance:request13201(head_color_id, head_id, cloth_color_id, cloth_id)
    end
end


--更新穿戴按钮的样式
function FashionSuitTab:update_put_on_btn()
    if self.parent.model.current_head_data == nil and self.parent.model.current_cloth_data == nil then
        self.BtnSave_btn:Set_btn_txt(TI18N("保 存"))
        self.BtnSave_btn:Layout({}, self.on_save_fashion, self.on_bottom_prices_back)
    else
        if self.last_selected_item == nil and self.tab_index == 1 then
            self.BtnSave_btn:Set_btn_txt(TI18N("保 存"))
            self.BtnSave_btn:Layout({}, self.on_save_fashion, self.on_bottom_prices_back)
            return
        end

        local buy_list = {}

        local btn_str = TI18N("保 存")

        local cost_dic = {}
        if self.tab_index == 1 then
            --套装
            if self.last_selected_item.data.active ~= 1 then
                cost_dic = self.parent.model:count_fashion_loss(self.last_selected_item.data)
            end
        else
            --染色
            local head_cost_dic = nil
            local cloth_cost_dic = nil
            if self.current_head_color_data.id == 0 then
                --基础
                head_cost_dic = {}
            elseif self.current_head_color_data.active == 0 then
                --未激活
                head_cost_dic = self.parent.model:count_fashion_loss(self.current_head_color_data)
            else
                --已激活
                if self.current_head_color_data.suit_type then
                    head_cost_dic = {}
                else
                    head_cost_dic = self.parent.model:count_color_change_loss(self.current_head_color_data)
                end
            end

            if self.current_cloth_color_data.id == 0 then
                cloth_cost_dic = {}
            elseif self.current_cloth_color_data.active == 0 then
                --未激活
                cloth_cost_dic = self.parent.model:count_fashion_loss(self.current_cloth_color_data)
            else
                --已激活
                if self.current_cloth_color_data.suit_type then
                    cloth_cost_dic = {}
                else
                    cloth_cost_dic = self.parent.model:count_color_change_loss(self.current_cloth_color_data)
                end
            end

            cost_dic = self.parent.model:merge_cost_dic(head_cost_dic, cloth_cost_dic)
        end



        for k, _need in pairs(cost_dic) do
            if _need ~= 0 then
                local has = BackpackManager.Instance:GetItemCount(k)
                if _need > 0 and _need > has then
                    btn_str = TI18N("购 买")
                    buy_list[k] = {need = _need}
                end
            end
        end

        if self.current_cloth_color_data ~= nil and self.current_head_color_data ~= nil then
            if self.current_cloth_color_data.active == 1 and self.current_head_color_data.active == 1 then
                btn_str = TI18N("保 存")
            end
        end

        if self.tab_index == 1 then
            buy_list = {}
        end

        if self.tab_index == 1 then
            --套装
            self.ClothSaveBtnTxt.text = btn_str
        else
            --染色
            self.BtnSave_btn:Layout(buy_list, self.on_save_fashion, self.on_bottom_prices_back)
            self.BtnSave_btn:Set_btn_txt(btn_str)
        end

    end
end

--slot逻辑
--创建slot
function FashionSuitTab:CreateSlot(slot_con)
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
function FashionSuitTab:SetSlotData(slot, data)
    if data == nil then
        slot:SetAll(nil, nil)
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    slot:SetAll(cell, nil)
end