-- @author hze
-- @date 2018/04/11
--宝物重塑

TalismanSynthesis = TalismanSynthesis or BaseClass(BasePanel)

function TalismanSynthesis:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "TalismanSynthesis"

    self.resList = {
        {file = AssetConfig.talisman_synthesis, type = AssetType.Main}
        ,{file = AssetConfig.talisman_synthesis_bg, type = AssetType.Dep}
        ,{file = AssetConfig.talisman_textures, type = AssetType.Dep}
        ,{file = AssetConfig.talisman_set, type = AssetType.Dep}
    }

    self.formula_id = nil
    self.complete = false
    -- self.lastIndexPos = nil

    self.talismanSelectedPanel = nil

    self.itemList = {}
    self.FormulaNeedId = {}
    self.FormulaNeedItem = {}


    self.formatColor =
    {
        [1] = "<color='#ffffff'>%s</color>",
        [2] = "<color='#eaafff'>%s</color>",
        [3] = "<color='#ffcd8d'>%s</color>",
        [4] = "<color='#ffb1b1'>%s</color>",
    }

    self.descTips =
    {
        TI18N("1、放入相应的材料即可获得重塑宝物"),
        TI18N("2、重塑配方随机生成，每<color='#ffff00'>周一5:00</color>刷新"),
        TI18N("3、每个配方只能<color='#ffff00'>重塑一次</color>，要把握机会哟")
    }


    self.need_gold_bind = 0

    self.reloadListener = function() self:Reload() end
    self.updateNeedIconListener = function(data) self:UpdateNeedIcon(data) end

    self.onClickCompose = function() self:ClickCompose() end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function TalismanSynthesis:__delete()
    self.OnHideEvent:Fire()

    if self.btnEffect ~= nil then
        self.btnEffect:DeleteMe()
        self.btnEffect = nil
    end

    BaseUtils.ReleaseImage(self.itemSlotImg)
    BaseUtils.ReleaseImage(self.itemSetImg)

    if self.itemList ~= nil then
        for _,v in ipairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = nil
    end

    if self.FormulaNeedItem ~= nil then
        for _,v in ipairs(self.FormulaNeedItem) do
            if v.iconLoader ~= nil then v.iconLoader:DeleteMe() end
            if v.setImage ~= nil then BaseUtils.ReleaseImage(v.setImage) end
            if v.iconBgImg ~= nil then BaseUtils.ReleaseImage(v.iconBgImg) end
            if v.icon ~= nil then BaseUtils.ReleaseImage(v.icon) end
            if v.topGradeImg ~= nil then BaseUtils.ReleaseImage(v.topGradeImg) end
        end
        self.FormulaNeedItem = nil
    end

    if self.buttonTxt ~= nil then
        self.buttonTxt:DeleteMe()
        self.buttonTxt = nil
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TalismanSynthesis:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_synthesis))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local left = self.transform:Find("Left")
    left.gameObject:SetActive(false)
    self.container = left:Find("Scroll/Container")
    self.cloner = left:Find("Scroll/Cloner").gameObject
    self.scroll = left:Find("Scroll"):GetComponent(ScrollRect)
    self.pageController = self.scroll.gameObject:AddComponent(PageTabbedController)

    self.setting_data = {
       item_list = self.itemList--·ÅÁË itemÀà¶ÔÏóµÄÁÐ±í
       ,data_list = {} --Êý¾ÝÁÐ±í
       ,item_con = self.container  --itemÁÐ±íµÄ¸¸ÈÝÆ÷
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --Ò»ÌõitemµÄ¸ß¶È
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --¸¸ÈÝÆ÷¸Ä±äÊ±ÉÏÒ»´ÎµÄy×ø±ê
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).rect.height --ÏÔÊ¾ÇøÓòµÄ¸ß¶È
       ,item_con_height = 0 --itemÁÐ±íµÄ¸¸ÈÝÆ÷¸ß¶È
       ,scroll_change_count = 0 --¸¸ÈÝÆ÷¹ö¶¯ÀÛ¼Æ¸Ä±äÖµ
       ,data_head_index = 0  --Êý¾ÝÍ·Ö¸Õë
       ,data_tail_index = 0 --Êý¾ÝÎ²Ö¸Õë
       ,item_head_index = 1 --itemÁÐ±íÍ·Ö¸Õë
       ,item_tail_index = 13 --itemÁÐ±íÎ²Ö¸Õë
    }

    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data)  self:UpdatePos() end)
    self.pageController.onUpEvent:AddListener(function() self:TweenTo() end)
    self.pageController.onEndDragEvent:AddListener(function() self:TweenTo() end)

    local layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    for i=1,10 do
       self.itemList[i] = TalismanSynthesisItem.New(self.model, GameObject.Instantiate(self.cloner), self)
       self.itemList[i].assetWrapper = self.assetWrapper
       layout:AddCell(self.itemList[i].gameObject)
       self.itemList[i].clickCallback = function(i) self:TweenTo(i -3) end
    end
    self.cloner:SetActive(false)
    layout:DeleteMe()

    self.right = self.transform:Find("Right")

    self.right:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_synthesis_bg, "talismansynthesisbg")
    self.composeBtn = self.right:Find("Button"):GetComponent(Button)
    self.composeBtn.transform.anchoredPosition = Vector2(-6,-196)
    self.composeBtn.onClick:AddListener(function()
        --[[达成重塑条件--]]
        self.complete = (#self.FormulaNeedId == 3)
        if  self.curUseTime ~= 0 then
            if self.complete then
                --发送19611
                local args = {formula_id = self.formula_id, stuff_list = self.FormulaNeedId}
                -- BaseUtils.dump(args)
                TalismanManager.Instance:send19611(args)
                if RoleManager.Instance.RoleData.gold_bind > self.need_gold_bind then
                    if self.btnEffect == nil then
                        self.btnEffect = BaseUtils.ShowEffect(20479, self.itemSlot, Vector3(1, 1, 1), Vector3(0, -0, -400))
                    end
                    self.btnEffect:SetActive(false)
                    self.btnEffect:SetActive(true)
                end
            else
                NoticeManager.Instance:FloatTipsByString("请放入所需的宝物材料{face_1,2}")
            end
        else
            NoticeManager.Instance:FloatTipsByString("已重塑本宝物，<color='#ffff00'>周一5:00</color>刷新哟{face_1,3}")
        end
     end)

    self.itemSlot = self.right:Find("ItemSlot")
    self.itemSlotImg = self.itemSlot:GetComponent(Image)
    self.itemSetImg = self.itemSlot:Find("Set"):GetComponent(Image)
    self.itemSetImg.transform.gameObject:SetActive(false)
    self.btnItemSlot = self.itemSlot:GetComponent(Button)

    for i = 1, 3 do
        local tab = self.FormulaNeedItem[i]
        if tab == nil then
            tab = {}
            tab.gameObject = self.right:Find(string.format("Container/Item%s",i)).gameObject
            tab.transform = tab.gameObject.transform
            tab.setImage = tab.transform:Find("Bg/Set"):GetComponent(Image)
            tab.add = tab.transform:Find("Bg/Add")
            tab.iconBgImg = tab.transform:Find("Bg"):GetComponent(Image)
            tab.icon = tab.transform:Find("Bg/Icon"):GetComponent(Image)
            tab.nameText = tab.transform:Find("Kind/Text"):GetComponent(Text)
            tab.kind = tab.transform:Find("Kind")
            tab.iconLoader = SingleIconLoader.New(tab.icon.gameObject)
            tab.btn = tab.transform:Find("Bg"):GetComponent(Button)
            tab.args = nil
            tab.btn.onClick:AddListener( function() self:OpenTalismanSelectWindow(tab.args) end)
            tab.topGradeImg = tab.transform:Find("Grade"):GetComponent(Image)
            tab.topNameTxt = tab.transform:Find("Grade/Text"):GetComponent(Text)
            self.FormulaNeedItem[i] = tab
        end
    end

    self.consumptionDes = self.right:Find("ConsumptionDes"):GetComponent(Text)
    self.consumptionDes.transform.gameObject:SetActive(false)
    self.buttonTxt = MsgItemExt.New(self.right:Find("Button/Text"):GetComponent(Text),128, 17, 27)


    ---------------------------------------------------------------
    --------------------添加tips按钮--------------------------------
    local gImg1 = GameObject()
    gImg1.name = "Tips"
    gImg1:AddComponent(RectTransform)
    gImg1.transform:SetParent(self.right:Find("Title"))
    gImg1.transform.localScale = Vector3.one
    gImg1.transform.anchoredPosition = Vector2(120, 0)
    gImg1:AddComponent(Image)
    gImg1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIconBg1")
    -- gImg1:GetComponent(Image):SetNativeSize()
    gImg1.transform.sizeDelta = Vector2(27,27)
    gImg1:AddComponent(Button)
    gImg1:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = gImg1.gameObject, itemData = self.descTips}) end)

    local gImg2 = GameObject()
    gImg2.name = "tanhao"
    gImg2:AddComponent(RectTransform)
    gImg2.transform:SetParent(gImg1.transform)
    gImg2.transform.localScale = Vector3.one
    gImg2.transform.anchoredPosition = Vector2(0, 0)
    gImg2:AddComponent(Image)
    gImg2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIcon3")
    gImg2.transform.sizeDelta = Vector2(12,22)
    -- gImg2:GetComponent(Image):SetNativeSize()

    -----------------------------------------------------------------------
end

function TalismanSynthesis:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TalismanSynthesis:OnOpen()
    self:RemoveListeners()
    TalismanManager.Instance.onUpdateFormulaEvent:AddListener(self.reloadListener)
    TalismanManager.Instance.onUpdateNeddItemEvent:AddListener(self.updateNeedIconListener)

    self.model.selectedData = {} -- 当前宝物可合成的已选中材料，每次打开重置
    -- self:Reload()
    self.model.initStatus = true
    -- 请求协议
    TalismanManager.Instance:send19610()

end

function TalismanSynthesis:OnHide()
    self:RemoveListeners()
    if self.btnEffect ~= nil then
        self.btnEffect:SetActive(false)
    end
end

function TalismanSynthesis:RemoveListeners()
    TalismanManager.Instance.onUpdateFormulaEvent:RemoveListener(self.reloadListener)
    TalismanManager.Instance.onUpdateNeddItemEvent:RemoveListener(self.updateNeedIconListener)
end

function TalismanSynthesis:Reload()
    self.transform:Find("Left").gameObject:SetActive(true)

    if self.model.initStatus then
        self:TweenTo(2)
        self:UpdatePos()
        self.model.initStatus = false
    end

    --作排序 （剩余次数/base_id大小排序）
    local sortfunc = function(a,b)
       local a_id = DataTalisman.data_formula_list[a.formula_id].complex_base_id
       local b_id = DataTalisman.data_formula_list[b.formula_id].complex_base_id

       if a.use_times ~= b.use_times then
            return a.use_times > b.use_times
       end

       return a_id > b_id
    end

    table.sort(self.model.formula_list,sortfunc)

    local datalist = {}
    -- 占位
    table.insert(datalist, {isEmpty = true})
    table.insert(datalist, {isEmpty = true})

    for i = 1,#self.model.formula_list do
        table.insert(datalist,{id = i,isEmpty = false,use_times = self.model.formula_list[i].use_times})
    end

    table.insert(datalist, {isEmpty = true})
    table.insert(datalist, {isEmpty = true})

    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)
end


function TalismanSynthesis:TweenTo(index)
    self.model.selectedData = {} -- 当前宝物可合成的已选中材料，每次tween重置
    if index == nil then
        index = math.ceil(math.floor(self.container.anchoredPosition.y * 2 / 84) / 2)
    end

    -- print(index)

    -- if self.lastIndexPos == index then return end
    -- self.lastIndexPos = index

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end

    --重置处理
    self:ResetNeedData()

    self.tweenId = Tween.Instance:ValueChange(self.container.anchoredPosition.y, 84 * index, 0.5,
        function()
            self.tweenId = nil
            self:SetInfo(index + 1)
        end,
        LeanTweenType.easeOutQuart,
        function(value)
            self.container.anchoredPosition = Vector2(0, value)
        end).id
end

function TalismanSynthesis:UpdatePos()
    local y = nil
    local xx = nil

    for i,v in ipairs(self.itemList) do
        y = v.transform.anchoredPosition.y + self.container.anchoredPosition.y

        xx = 1 - (((y + 168 + 10) * (y + 168 + 10)) / (210*210))
        if xx >= 0 then
            local x = math.sqrt(xx) * 145 - 145 -23
            v.item.anchoredPosition = Vector2(x, 0)
            local value = xx - 0.1


            if value < 0.85 then
                value = 0.85
            end

            value = 0.85 + 0.03

            if value > 1 then
                value = 1
            end

            v.item.localScale = Vector2(value, value ,0)
        end
    end
end


function TalismanSynthesis:SetInfo(correspondIndex)
    if correspondIndex == nil then return end
    -- print(string.format("当前选中所对应的表项:%s",correspondIndex))

    -- BaseUtils.dump(self.model.formula_list,"model里的配方表")
    -- print(correspondIndex)

    self.formula_id = self.model.formula_list[correspondIndex].formula_id

    ---
    --选中处理
    ---
    -- BaseUtils.dump(self.model.itemDic,"当前拥有的宝物列表")
    -- local basedata = {stuff1 = {{60301,1},{60100,1}}, stuff2 = {{60401,1}}, stuff3 = {{60309,1}}, cost = {90002,89989}}
    local basedata = DataTalisman.data_formula_list[self.formula_id]
    if basedata == nil then return end

    self.need_gold_bind =  basedata.cost[1][2]
    --当前剩余重塑次数
    self.curUseTime = self.model.formula_list[correspondIndex].use_times or 0

    --设置消耗
    if self.curUseTime == 0 then
        self.buttonTxt:SetData(string.format("<color='#e0e0e0'>  %s</color>", TI18N("下周刷新")))
        self.composeBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.composeBtn.transform.sizeDelta = Vector2(100,45)
    else
        self.buttonTxt:SetData(string.format("%d{assets_2,%d}%s",basedata.cost[1][2],basedata.cost[1][1],TI18N("重塑")))
        self.composeBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.composeBtn.transform.sizeDelta = Vector2(138,41.4)
    end



    if self.curUseTime == 0 then
        self.consumptionDes.gameObject:SetActive(true)
        self.consumptionDes.text = TI18N("<color='#FFFF00'>重塑次数用完 周一5:00刷新</color>")
    else
        self.consumptionDes.gameObject:SetActive(false)
        -- self.consumptionDes.text = string.format(TI18N("<color='#175AB3'>本周还可重塑%d次</color>"),self.curUseTime)
    end

    self.FormulaNeedItem[1].args = {basedata.stuff1,1}
    self.FormulaNeedItem[2].args = {basedata.stuff2,2}
    self.FormulaNeedItem[3].args = {basedata.stuff3,3}


    self.FormulaNeedItem[1].topNameTxt.text = string.format(self.formatColor[basedata.stuff_lev1],basedata.stuff_name1)
    self.FormulaNeedItem[2].topNameTxt.text = string.format(self.formatColor[basedata.stuff_lev2],basedata.stuff_name2)
    self.FormulaNeedItem[3].topNameTxt.text = string.format(self.formatColor[basedata.stuff_lev3],basedata.stuff_name3)

    self.FormulaNeedItem[1].topGradeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, string.format("rank%d",basedata.stuff_lev1))
    self.FormulaNeedItem[2].topGradeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, string.format("rank%d",basedata.stuff_lev2))
    self.FormulaNeedItem[3].topGradeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, string.format("rank%d",basedata.stuff_lev3))


    local cfgData = DataTalisman.data_get[basedata.complex_base_id]
    self.itemSlotImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures,"Level" .. cfgData.quality)
    local iconLoader = SingleIconLoader.New(self.itemSlot:Find("Icon").gameObject)
    iconLoader:SetSprite(SingleIconType.Item, cfgData.icon)
    iconLoader:DeleteMe()
    self.itemSetImg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
    self.itemSetImg.transform.gameObject:SetActive(true)
    self.btnItemSlot.onClick:RemoveAllListeners()
    self.btnItemSlot.onClick:AddListener(function()  TipsManager.Instance:ShowTalisman({itemData = cfgData , extra = {nobutton = true}})  end)
end


function TalismanSynthesis:UpdateNeedIcon(data)
    if data ~= nil then
        self.FormulaNeedId[data.index] = { id = data.id , index = data.index }

        -- table.insert(self.FormulaNeedId,{ id = data.id , index = data.index })

        local cfgData = DataTalisman.data_get[data.base_id]
        local tmpItem = self.FormulaNeedItem[data.index]
        tmpItem.add.gameObject:SetActive(false)
        tmpItem.setImage.gameObject:SetActive(true)

        tmpItem.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
        tmpItem.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
        tmpItem.iconLoader:SetSprite(SingleIconType.Item, cfgData.icon)

        tmpItem.nameText.text = ColorHelper.color_item_name(cfgData.quality, TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))
        tmpItem.kind.sizeDelta = Vector2(tmpItem.nameText.preferredWidth + 15,tmpItem.nameText.preferredHeight + 3)

    end
end

function TalismanSynthesis:ResetNeedData()
    if self.FormulaNeedItem == nil then return end
    for _,v in ipairs (self.FormulaNeedItem) do
            v.add.gameObject:SetActive(true)
            v.setImage.gameObject:SetActive(false)
            v.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures,"itbg")
            v.iconLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.talisman_textures,"Twills"))
            v.nameText.text = TI18N("未选择")
            v.kind.sizeDelta = Vector2(v.nameText.preferredWidth + 11,v.nameText.preferredHeight + 3)
    end

    self.FormulaNeedId = {}
end


function TalismanSynthesis:OpenTalismanSelectWindow(args)
    if self.talismanSelectedPanel == nil then
        self.talismanSelectedPanel = TalismanSelectWindow.New(self.model)
    end
    self.talismanSelectedPanel:Show(args)
end


TalismanSynthesisItem = TalismanSynthesisItem or BaseClass()

function TalismanSynthesisItem:__init(model,gameObject,parent)
    self.model = model
    self.gameObject = gameObject
    self.parent = parent

    self.transform = gameObject.transform
    self.item = self.transform:Find("Item")
    -- self.bg = self.item:Find("Bg"):GetComponent(Image)
    self.icon = self.item:Find("Icon"):GetComponent(Image)
    self.iconLoader = SingleIconLoader.New(self.icon.gameObject)
    self.iconBgImg = self.item:Find("IconBg"):GetComponent(Image)
    self.nameTxt =  self.item:Find("Name"):GetComponent(Text)
    self.lockImg = self.item:Find("Lock"):GetComponent(Image)

    self.item:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)

end

function TalismanSynthesisItem:__delete()

    BaseUtils.ReleaseImage(self.lockImg)
    BaseUtils.ReleaseImage(self.iconBgImg)
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
    end
end

function TalismanSynthesisItem:update_my_self(data ,index)
    self.data = data
    self.index = index

    self.item.gameObject:SetActive(not data.isEmpty)

    if not data.isEmpty then
        local base_id = DataTalisman.data_formula_list[self.model.formula_list[data.id].formula_id].complex_base_id

        local cfgData = DataTalisman.data_get[base_id]
        self.lockImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
        self.iconBgImg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfgData.quality)
        self.iconLoader:SetSprite(SingleIconType.Item, cfgData.icon)
        self.nameTxt.text = ColorHelper.color_item_name(cfgData.quality, TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))

        if data.use_times == 0 then
            self.lockImg.color = Color(138/255, 138/255, 138/255, 1)
            self.iconBgImg.color = Color(138/255, 138/255, 138/255, 1)
            self.icon.color = Color(138/255, 138/255, 138/255, 1)
        else
            self.lockImg.color = Color(1, 1, 1)
            self.iconBgImg.color = Color(1, 1, 1)
            self.icon.color = Color(1, 1, 1)
        end
    end
end

function TalismanSynthesisItem:OnClick()
    if self.clickCallback ~= nil and self.index ~= nil then
        self.clickCallback(self.index)
    end
end
