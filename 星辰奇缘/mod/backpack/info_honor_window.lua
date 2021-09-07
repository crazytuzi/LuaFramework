-- @author 黄耀聪
-- @date 2016年9月27日

InfoHonorWindow = InfoHonorWindow or BaseClass(BaseWindow)
InfoHonorEumn = InfoHonorEumn or {}

InfoHonorEumn.Status = {
    ForWard = 1, -- 前缀称号页签
    Back = 2, -- 后缀称号页签
}

InfoHonorEumn.preStatus = {
    NotHas = 0,
    Has = 1,
    Use = 2,
    ExChange = 3,
}

function InfoHonorWindow:__init(model)
    self.model = model
    self.name = "InfoHonorWindow"
    self.windowId = WindowConfig.WinID.info_honor_window
    self.resList = {
        {file = AssetConfig.info_honor_window, type = AssetType.Main}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        ,{file = AssetConfig.res_honor, type = AssetType.Dep}
        ,{file = AssetConfig.fashionres,type = AssetType.Dep}
    }

    self.itemList = {}
    self.titleString = TI18N("称 号")
    self.honorListener = function() self:on_update_honors() end
    self.refreshCostNum = function() self:RefreshCostNum() end

    self.applyReward = function() self:RepplyGetReward() end


    self.tabObjList = {}
    self.tabRedPoint = {}
    self.txtList = {}
    self.contentList = {}
    self.currentTabIndex = 1
    self.isInit = false
    self.lastIndex = 0
    self.lastPreId = 0
    self.getText = {}
    self.exChangeNum = nil
    self.classList =
    {
        [1] = {name = "常规",id = 1},
        [2] = {name = "前缀",id = 2,package = AssetConfig.fashionres, icon_name = "Icon1"},
        [3] = {name = "典藏室",id = 3,package = AssetConfig.fashionres, icon_name = "Icon2"}
    }
    self.extra = {inbag = false, nobutton = true}


    self.tltleTab =
    {
        [1] = {name = "常规前缀"},
        [2] = {name = "荣誉前缀"},
        [3] = {name = "典藏前缀"}
    }

    self.preStatus = 0
    self.preObjList = {}
    self.titleObjList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnOpenEvent:AddListener(function() if self.previewComp ~= nil then self.previewComp:Show() end end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.OnHideEvent:AddListener(function() if self.previewComp ~= nil then self.previewComp:Hide() end end)
    self.selectPreIndex = 0
    self.canReward = false
end

function InfoHonorWindow:__delete()
    self.OnHideEvent:Fire()



    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end
    if self.imageLoader1 ~= nil then
        self.imageLoader1:DeleteMe()
        self.imageLoader1 =nil
    end

    if self.imageLoader2 ~= nil then
        self.imageLoader2:DeleteMe()
        self.imageLoader2 =nil
    end

    -- if self.imageLoader3 ~= nil then
    --     self.imageLoader3:DeleteMe()
    --     self.imageLoader3 =nil
    -- end

    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.possibleReward = nil
    end

    if self.getLayout ~= nil then
        self.getLayout:DeleteMe()
        self.getLayout = nil
    end

    -- if self.exchangeItemSlot ~= nil then
    --     self.exchangeItemSlot:DeleteMe()
    -- end

    -- if self.specilLoader ~= nil then
    --     self.specilLoader:DeleteMe()
    --     self.specilLoader = nil
    -- end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self.model.lastHonorId = nil
    self.model.lastHonorSelect = nil

    if self.leftBtnImage ~= nil then
        self.leftBtnImage.sprite = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function InfoHonorWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.info_honor_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.closeBtn = main:Find("Close"):GetComponent(Button)

    local left = main:Find("Left")
    self.previewContainer = left:Find("Preview")
    self.infoText = left:Find("Info/Text"):GetComponent(Text)
    self.timeText = left:Find("TimeText"):GetComponent(Text)
    self.info = left:Find("Info")
    self.info2 = left:Find("Info2")
    self.leftBtn = main:Find("Button"):GetComponent(Button)
    self.leftBtnImage = main:Find("Button"):GetComponent(Image)
    self.leftBtnText = main:Find("Button/Text"):GetComponent(Text)
    left:Find("RoleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    left:Find("RoleBg").gameObject:SetActive(true)
    self.honorText = left:Find("Honor"):GetComponent(Text)

    local right = main:Find("Right")
    self.mask_con = right:Find("Mask_con").gameObject
    self.cloner = right:Find("Mask_con/Scroll_con/Cloner").gameObject
    self.scroll = right:Find("Mask_con/Scroll_con"):GetComponent(ScrollRect)
    self.layout = LuaBoxLayout.New(right:Find("Mask_con/Scroll_con/Container"), {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})
    self.nothing = right:Find("UnOpen_con").gameObject

    self.preHonor_mask_container = right:Find("PreHonorMask/Mask_con/Scroll_con/Container")
    self.preHonor_mask_scroll = right:Find("PreHonorMask/Mask_con/Scroll_con")
    self.preHonor_mask_con = right:Find("PreHonorMask/Mask_con")
    self.preHonor_mask = right:Find("PreHonorMask")
    self.preHonorTemplate = right:Find("PreHonorMask/Mask_con/Scroll_con/Cloner")
    self.preHonorTemplate.sizeDelta = Vector2(105,45)
    self.preHonorTemplate.gameObject:SetActive(false)

    self.bottom1 = right:Find("Bottom1")
    self.bottom2 = right:Find("Bottom2")
    self.slider = right:Find("Bottom1/CountSlider"):GetComponent(Slider)
    self.rewardBtn = right:Find("Bottom1/Reward"):GetComponent(Button)
    self.rewardBtn.onClick:AddListener(function() self:ApplyReward() end)

    self.exchangeIcon1 = right:Find("Bottom2/Image1")
    self.exchangeIcon2 = right:Find("Bottom2/Image2")

    self.imageLoader1 = SingleIconLoader.New(self.exchangeIcon1.gameObject)
    self.imageLoader2 = SingleIconLoader.New(self.exchangeIcon2.gameObject)
    self.rewardImg = right:Find("Bottom1/Reward")
    self.hasRewardImg = right:Find("Bottom1/Reward/Image")
    self.hasRewardImg.gameObject:SetActive(false)

    self.imageLoader1:SetSprite(SingleIconType.Item, 22786)
    self.imageLoader2:SetSprite(SingleIconType.Item, 22786)



    -- self.imageLoader3:SetSprite(SingleIconType.Item, 22218)
    self.rewardImg = right:Find("Bottom1/Reward")

    self.acceptNumText = right:Find("Bottom2/TextBg1/Text"):GetComponent(Text)
    self.allNumText = right:Find("Bottom2/TextBg2/Text"):GetComponent(Text)
    -- self.preNumText = right:Find("PreHonorMask/Bottom/LeftText"):GetComponent(Text)
    -- self.allNumText =

    self.titleBg = right:Find("PreHonorMask/TitleBg")
    self.titleBg.gameObject:SetActive(false)


    self.exchangeItem = left:Find("Info2/ItemSlot")
    self.exchangeItem.gameObject:SetActive(false)
    -- self.exchangeItemSlot = ItemSlot.New(self.exchangeItem .gameObject)
    -- self.exchangeItemSlot.gameObject:SetActive(false)

    self.titleImg = left:Find("Info2/TitleImg")

    self.exchangeName =  left:Find("Info2/ItemSlot/SecondName"):GetComponent(Text)

    self.sliderText =right:Find("Bottom1/SliderText"):GetComponent(Text)



    self.setting = {
         column = 3
        ,borderleft = 10
        ,bordertop = 10
        ,cspacing = 5
        ,rspacing = 4
        ,cellSizeX = 105
        ,cellSizeY = 45
        ,special = true
    }

    self.pageLayout = LuaGridLayout.New(self.preHonor_mask_container,self.setting)

    for i=1,10 do
        local obj = GameObject.Instantiate(self.cloner)
        self.itemList[i] = BackPackHonorItem.New(obj, self, self.model)
        self.itemList[i].clickCallback = function(data) self:Update(data) end
        self.layout:AddCell(obj)
    end
    self.cloner:SetActive(false)
    self.setting_data = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.layout.panel  --item列表的父容器
       ,single_item_height = self.cloner.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = self.layout.panel.anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll.transform.sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.scroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.titleText.text = self.titleString
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.leftBtn.onClick:AddListener(function() self:OnClickUse() end)

    self.tabListPanel = self.transform:Find("Main/TabListPanel")
    self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
    self.tabTemplate.transform.sizeDelta = Vector2(55,118)
    self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    self.tabTemplate:SetActive(false)

    self.getLayout = LuaBoxLayout.New(left:Find("Info2/Mask_con/Scroll_con/Container").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    self.getTemplate = left:Find("Info2/Mask_con/Scroll_con/Container/GetClone")
    self.getTemplate.gameObject:SetActive(false)


end

function InfoHonorWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function InfoHonorWindow:OnOpen()
    self.isInit = false
    self.selectPreIndex = 0
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.honor_update, self.honorListener)
    EventMgr.Instance:AddListener(event_name.honor_update, self.refreshCostNum)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.refreshCostNum)
    HonorManager.Instance.onUpdateReward:AddListener(self.applyReward)
    self:RefreshCostNum()
    self.my_data = nil
    for i,v in ipairs(HonorManager.Instance.model.mine_honor_list) do
        if v.id == HonorManager.Instance.model.current_honor_id then
            self.my_data = v
        end
    end

    -- BaseUtils.dump(self.my_data, tostring(self.my_data))
    self:InitTab()
    self:ShowPreview()
    if self.isInit == false then
        if self.openArgs ~= nil then
            self:SwitchTabs(self.openArgs[1])
        else
            self:SwitchTabs(InfoHonorEumn.Status.ForWard)
        end
    end



    --  if self.my_data ~= nil then
    --     if self.honorText ~= nil then
    --         if HonorManager.Instance.model.current_pre_honor_id ~= 0 or HonorManager.Instance.model.current_pre_honor_id ~= nil then
    --             self.honorText.text = string.format("<color='#b031d5'>%s</color>",self.my_data.final_name)
    --         else
    --             self.honorText.text = string.format("<color='#b031d5'>%s·%s</color>",HonorManager.Instance.model.current_pre_honor_id,self.my_data.final_name)
    --         end
    --     end
    -- end
    -- self:InitHonor()
end

function InfoHonorWindow:InitTab()
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
            if i == 3 then
                    t:Find("Text").anchoredPosition = Vector2(-3.4,-1)
            else
                t:Find("Text").anchoredPosition = Vector2(-3.4,18)
            end
            local sprite = self.assetWrapper:GetSprite(v.package,v.icon_name)
            if sprite == nil then
                sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon_name))
            end
            t:Find("Icon"):GetComponent(Image).sprite  = sprite
            t:Find("Icon").gameObject:SetActive(true)
            t:Find("Icon").anchoredPosition = Vector2(-3.4,37)
        else
            t:Find("Text").anchoredPosition = Vector2(-3.4,21)
            t:Find("Icon").gameObject:SetActive(false)
        end

         self.txtList[i] = txt
         self.contentList[i] = content
    end
end

function InfoHonorWindow:OnHide()
    self:RemoveListeners()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
end

function InfoHonorWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.honor_update, self.honorListener)
     EventMgr.Instance:RemoveListener(event_name.honor_update, self.refreshCostNum)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.refreshCostNum)
    HonorManager.Instance.onUpdateReward:RemoveListener(self.applyReward)
end

function InfoHonorWindow:on_update_honors()
    if HonorManager.Instance.model.mine_honor_list == nil then
        -- HonorManager.Instance:request12700()
        self.nothing:SetActive(true)
        self.scroll.gameObject:SetActive(false)
        return
    end

    self.nothing:SetActive(false)
    self.scroll.gameObject:SetActive(true)
    self.current_honor_data_list = BaseUtils.copytab(HonorManager.Instance.model.mine_honor_list) or {}
    for k,v in pairs(DataHonor.data_get_honor_list) do
        if v.show_sort ~= 0 then
            if v.classes == 0 or v.classes == RoleManager.Instance.RoleData.classes then --无职业限制，或者职业相同
                if v.sex == 2 or v.sex == RoleManager.Instance.RoleData.sex then --无性别限制或者性别相同
                    if not HonorManager.Instance.model:check_has_honor(v.id) then
                        table.insert(self.current_honor_data_list, v)
                    end
                end
            end
        end
    end

    self.old_pre_data_id_list = BaseUtils.copytab(HonorManager.Instance.model.pre_honor_id_list) or {{pre_id = 1000}}
    self.old_pre_data_id_list = {{pre_id = 1000}}
    self.pre_data_id_list = {}
    for k,v in pairs(DataHonor.data_get_pre_honor_list) do
        while true do
            if self.currentTabIndex == 3 then
                if v.special ~= 2 then
                    break
                end
            end

            if not HonorManager.Instance.model:check_has_pre_honor(v.pre_id) then
                table.insert(self.pre_data_id_list, v)
                self.pre_data_id_list[#self.pre_data_id_list].status =InfoHonorEumn.preStatus.NotHas
            else
                table.insert(self.pre_data_id_list, v)
                if v.pre_id == HonorManager.Instance.model.current_pre_honor_id then
                    self.pre_data_id_list[#self.pre_data_id_list].status = InfoHonorEumn.preStatus.Use
                else
                    self.pre_data_id_list[#self.pre_data_id_list].status = InfoHonorEumn.preStatus.Has
                end
            end
            break
        end

    end

    table.sort(self.pre_data_id_list,function(a,b)
                   if a.special ~= b.special then
                        return a.special < b.special
                    else
                        if a.status ~= b.status then
                            return a.status > b.status
                        else
                            return a.pre_id < b.pre_id
                        end
                    end
                end)


    self.hasNum = 0
    local isRefresh = false
    local theLastIndex = 0
    local titleIndex = 0
    self.allNum = #DataHonor.data_get_pre_honor_list

    local cellIndex = 0
    local lastSpecial = -1
    for i,v in ipairs(self.pre_data_id_list) do

        if self.lastPreId ~= 0 and isRefresh == false then
           if  self.lastPreId == v.pre_id then
                theLastIndex  = i
                isRefresh = true
            end
        end


        if lastSpecial ~= v.special then
            titleIndex = titleIndex + 1

            if self.titleObjList[titleIndex] == nil then
                self.titleObjList[titleIndex] = {}
                self.titleObjList[titleIndex].gameObject = GameObject.Instantiate(self.titleBg.gameObject)
                self.titleObjList[titleIndex].text = self.titleObjList[titleIndex].gameObject.transform:Find("Title"):GetComponent(Text)

            end
            local myIndex = math.ceil(cellIndex/3)*3 + 1
            self.pageLayout:UpdateCellIndex(self.titleObjList[titleIndex].gameObject,myIndex)
            self.titleObjList[titleIndex].gameObject.transform.sizeDelta = Vector2(317,35)
            self.titleObjList[titleIndex].gameObject:SetActive(true)
            local myName = self.tltleTab[titleIndex].name

            if v.special == 2 then
                myName =  self.tltleTab[3].name
            end

            self.titleObjList[titleIndex].text.text = myName

            lastSpecial = v.special

            cellIndex = math.ceil(cellIndex/3)*3 + 4
        else
            cellIndex = cellIndex + 1
        end
        if  #self.titleObjList > titleIndex then
            for iy=titleIndex + 1,#self.titleObjList do
                self.titleObjList[iy].gameObject:SetActive(false)
            end
        end
        if self.preObjList[i] == nil then
            self.preObjList[i] = {}
            self.preObjList[i].gameObject = GameObject.Instantiate(self.preHonorTemplate.gameObject)
            self.preObjList[i].transform = self.preObjList[i].gameObject.transform
            self.preObjList[i].text = self.preObjList[i].transform:Find("Text"):GetComponent(Text)
            self.preObjList[i].use = self.preObjList[i].transform:Find("Use")
            self.preObjList[i].img = self.preObjList[i].transform:GetComponent(Image)
            self.preObjList[i].btn = self.preObjList[i].transform:GetComponent(Button)
            self.preObjList[i].btn.onClick:AddListener(function() self:ApplyPreObjBtn(i) end)
            self.preObjList[i].select = self.preObjList[i].transform:Find("Select")
            self.preObjList[i].select.gameObject:SetActive(false)
        end
        self.pageLayout:UpdateCellIndex(self.preObjList[i].gameObject,cellIndex)
        if i == self.selectPreIndex then
            self.preObjList[i].select.gameObject:SetActive(true)
        else
            self.preObjList[i].select.gameObject:SetActive(false)
        end
        self.preObjList[i].text.text = v.pre_name
        if v.status == InfoHonorEumn.preStatus.NotHas then
            self.preObjList[i].img.sprite = self.assetWrapper:GetSprite(AssetConfig.fashionres,"Square")
            self.preObjList[i].text.color = Color(121/255,137/255,157/255)
            self.preObjList[i].use.gameObject:SetActive(false)
            if self.currentTabIndex == 2 then
                self.preObjList[i].text.text = "???"
            end
        elseif v.status == InfoHonorEumn.preStatus.Has then
            self.preObjList[i].img.sprite = self.assetWrapper:GetSprite(AssetConfig.fashionres,"Square")
            self.preObjList[i].text.color = Color(39/255,99/255,176/255)
            self.hasNum = self.hasNum + 1
            self.preObjList[i].use.gameObject:SetActive(false)
        elseif v.status == InfoHonorEumn.preStatus.Use then
            self.preObjList[i].img.sprite = self.assetWrapper:GetSprite(AssetConfig.fashionres,"Square")
            self.hasNum = self.hasNum + 1
            self.preObjList[i].text.color = Color(39/255,99/255,176/255)
            self.preObjList[i].use.gameObject:SetActive(true)
        end

        if v.special >= 1 then
            self.preObjList[i].text.color = Color(196/255,26/255,232/255)
        end

         self.preObjList[i].gameObject:SetActive(true)
    end
    local minId = 0
    local minNum = 0
    for k,v in pairs(HonorManager.Instance.model.rewardList) do
        if v.reward_id > minId then
            minId = v.reward_id
        end
    end

    self.rewardId = 0
    for i,v in ipairs(DataHonor.data_reward_list) do
        if v.reward_id > minId then
            self.allNum = v.neen_num
            self.rewardId = v.reward_id
            break
        end

        if v.reward_id == minId then
            minNum = v.neen_num
        end
    end

    self.isRewardEnd = false
    if self.rewardId ==  0 then
        self.rewardId = minId
        self.isRewardEnd = true
        self.hasRewardImg.gameObject:SetActive(true)
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
    else
        if self.effTimerId == nil then
                 self.effTimerId = LuaTimer.Add(1000, 2500, function()
                       self.rewardImg.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                       Tween.Instance:Scale(self.rewardImg.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
                    end)
        end
        self.hasRewardImg.gameObject:SetActive(false)
    end

    self.slider.value = self.hasNum/self.allNum
    self.sliderText.text = string.format("%s/%s",self.hasNum,self.allNum)

    if self.hasNum >= self.allNum then
        self.canReward = true
        if self.firstEffect == nil then
            self.firstEffect = BibleRewardPanel.ShowEffect(20053,self.rewardImg.transform, Vector3(0.6, 0.6, 1),Vector3(-19, -14, -400))
        end
        self.firstEffect:SetActive(true)
    else
        if self.firstEffect ~= nil then
            self.firstEffect:SetActive(false)
        end
        self.canReward = false
    end






    self:RefreshCostNum()



    if #self.titleObjList > titleIndex then
        for i=titleIndex + 1,#self.titleObjList do
            self.titleObjList[i].gameObject:SetActive(false)
        end
    end



    if #self.preObjList > #self.pre_data_id_list then
        for i=#self.pre_data_id_list + 1,#self.preObjList do
            self.preObjList[i].gameObject:SetActive(false)
        end
    end


    if #self.tabObjList > #self.classList then
        for i=#self.classList + 1,#self.tabObjList do
            self.tabObjList[i].gameObject:SetActive(false)
        end
    end


    local show_sort = function(a, b)
        if a.show_sort == nil or b.show_sort == nil then return true end

        return a.id == HonorManager.Instance.model.current_honor_id
            or (a.has and not b.has)
            or (not a.has and not b.has and a.show_sort < b.show_sort)
    end
    table.sort(self.current_honor_data_list, show_sort )
    HonorManager.Instance.model.current_honor_data_list = self.current_honor_data_list

    self.setting_data.data_list = self.current_honor_data_list
    BaseUtils.refresh_circular_list(self.setting_data)

    if #self.current_honor_data_list > 0 then
        self.itemList[1].btn.onClick:Invoke()
    end


    if theLastIndex ~= 0 then
        self:ApplyPreObjBtn(theLastIndex ,true)
    end

end

function InfoHonorWindow:ApplyReward()
    if self.isRewardEnd == false then
        if self.canReward == true then
            HonorManager.Instance:request12710(self.rewardId)
        elseif self.canReward == false then



            local rewardList = {}
            for k,v in pairs(DataHonor.data_reward_list) do
                if self.rewardId == v.reward_id then
                    if RoleManager.Instance.RoleData.sex == v.sex or v.sex == 2 then
                        rewardList = BaseUtils.copytab(v.items)
                    end
                end
            end

            for k,v in pairs(rewardList) do
                v.item_id = v[1]
                v.num = v[3]
                v.effect = v[4]
            end
            if self.possibleReward == nil then
                self.possibleReward = SevenLoginTipsPanel.New(self)
            end
            self.possibleReward:Show({rewardList,3,{150,120,100,120},"达成收集进度奖励"})
        end
    elseif self.isRewardEnd == true then
        if self.effTimerId ~= nil then
            LuaTimer.Delete(self.effTimerId)
            self.effTimerId = nil
        end
        NoticeManager.Instance:FloatTipsByString("已领取完所有奖励")
    end
end

function InfoHonorWindow:RepplyGetReward()
     if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end

    local callBack = function(height) self:CallBack(self.possibleReward,height) end
    local timeCallBack = function() self:SecondCallBack(self.possibleReward) end
    local deleteCallBack = function() self:DeleteCallBack() end

        local rewardList = {}
        for k,v in pairs(DataHonor.data_reward_list) do
            if self.rewardId == v.reward_id then
                if RoleManager.Instance.RoleData.sex == v.sex or v.sex == 2 then
                    rewardList = BaseUtils.copytab(v.items)
                end
            end
        end

        for k,v in pairs(rewardList) do
            v.item_id = v[1]
            v.num = v[3]
            v.effect = v[4]
        end
    self.possibleReward:Show({rewardList,5,{[5] = false},"",{0,0,200/255},{0,1000,timeCallBack},callBack,deleteCallBack})
end
function InfoHonorWindow:ShowPreview()
    local callback = function(composite)
        self:SetRamImage(composite)
    end

    local setting = {
        name = "HonorPreviewRole"
        ,orthographicSize = 0.7
        ,width = 328
        ,height = 341
        ,offsetY = -0.23
    }

    self.current_looks = BaseUtils.copytab(SceneManager.Instance:MyData().looks)

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end

function InfoHonorWindow:ApplyPreObjBtn(index,isTure)
    self.isTure = isTure or false
    if self.lastIndex == index and self.isTure == false then
        return
    end

    if self.lastIndex ~= 0 then
        self.preObjList[self.lastIndex].select.gameObject:SetActive(false)
    end

    self.preObjList[index].select.gameObject:SetActive(true)
    self.lastIndex = index
    if self.pre_data_id_list[index].status == InfoHonorEumn.preStatus.NotHas then
        self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.leftBtnText.text = "未拥有"
        self.leftBtnText.color = ColorHelper.DefaultButton4
    elseif self.pre_data_id_list[index].status == InfoHonorEumn.preStatus.Has then
        self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.leftBtnText.text = "使用"
        self.leftBtnText.color = ColorHelper.DefaultButton2
    elseif self.pre_data_id_list[index].status == InfoHonorEumn.preStatus.Use then
        self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self.leftBtnText.text = "取消"
        self.leftBtnText.color = ColorHelper.DefaultButton1
    end

    self.selectPreStatus = self.pre_data_id_list[index].status

    self.exChange = false
    self.exChangeNum = 0
    if self.pre_data_id_list[index].isexchange == 1 then
        local myData = DataItem.data_get[self.pre_data_id_list[index].loss_items[1][1]]
        local itemData = ItemData.New()
        itemData:SetBase(myData)
        -- self.exchangeItemSlot:SetAll(itemData,self.extra)
        -- self.exchangeItemSlot.gameObject:SetActive(true)
        local num = BackpackManager.Instance:GetItemCount(self.pre_data_id_list[index].loss_items[1][1])

        -- self.exchangeItemSlot:SetNum(num,self.pre_data_id_list[index].loss_items[1][2])


        self.exChangeNum = num
        if self.currentTabIndex == 3 then
                self.exChange = true
                self.leftBtnText.text = "兑换"
                self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                self.leftBtnText.color = ColorHelper.DefaultButton3
        end

    else
        -- self.exchangeItemSlot.gameObject:SetActive(false)
    end

    local strList = {}
    if self.currentTabIndex == 2 then
       if self.pre_data_id_list[index].status == InfoHonorEumn.preStatus.Use or self.pre_data_id_list[index].status == InfoHonorEumn.preStatus.Has then
            local str = self.pre_data_id_list[index].desc
            table.insert(strList,str)
            self.titleImg.gameObject:SetActive(false)
        else
            strList = StringHelper.Split(self.pre_data_id_list[index].assetway, "|")
            self.titleImg.gameObject:SetActive(true)
        end
    elseif self.currentTabIndex == 3 then
        self.titleImg.gameObject:SetActive(true)
        table.insert(strList,"<color='#ffff00'>使用典藏卡可兑换典藏前缀</color>")
        table.insert(strList,"<color='#ffff00'>获得重复前缀可获得典藏卡</color>")
    end

    self.getLayout:ReSet()
    for i,v in ipairs(strList) do
        if self.getText[i] == nil then
            self.getText[i] = {}
            local go = GameObject.Instantiate(self.getTemplate.gameObject)
            self.getText[i].gameObject = go.gameObject
            self.getText[i].transform = go.gameObject.transform
            self.getText[i].text = self.getText[i].transform:Find("Text"):GetComponent(Text)

        end
        self.getText[i].text.text = v
        self.getText[i].gameObject:SetActive(true)
         self.getLayout:AddCell(self.getText[i].gameObject)

        if #strList < #self.getText then
            for i2=#strList + 1,#self.getText do
                self.getText[i2].gameObject:SetActive(false)
            end
        end

    end
    self.leftBtnImage.gameObject:SetActive(true)


    self.selectPreIndex = index


    self.lastPreId = self.pre_data_id_list[index].pre_id

    if DataHonor.data_get_pre_honor_list[self.lastPreId] ~= nil then
        if self.currentTabIndex ~= 1 then
            if DataHonor.data_get_honor_list[HonorManager.Instance.model.current_honor_id] == nil then
               self.honorText.text = string.format("<color='#b031d5'>%s·称号</color>", self.preObjList[index].text.text)
            else
                self.honorText.text = string.format("<color='#b031d5'>%s·%s</color>", self.preObjList[index].text.text,DataHonor.data_get_honor_list[HonorManager.Instance.model.current_honor_id].name)
            end
        elseif self.currentTabIndex == 1 then
            if DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id] ~= nil then
                 self.honorText.text = string.format("<color='#b031d5'>%s·%s</color>",DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id].pre_name,self.my_data.final_name)
            else
                self.honorText.text = string.format("<color='#b031d5'>%s</color>",self.my_data.final_name)
            end
        end
    end

    if self.currentTabIndex == 3 then
    else
    end
end

function InfoHonorWindow:SetRamImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end

function InfoHonorWindow:OnClickUse()
    if self.currentTabIndex == InfoHonorEumn.Status.ForWard then
        if self.my_data.has then
            if self.my_data.id == HonorManager.Instance.model.current_honor_id then
                HonorManager.Instance:request12702(self.my_data.id)
            else
                HonorManager.Instance:request12701(self.my_data.id)
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("该称号尚未激活"))
        end
    else
        if self.exChange == false then
            if self.selectPreStatus == InfoHonorEumn.preStatus.NotHas then
                NoticeManager.Instance:FloatTipsByString(TI18N("该前缀尚未激活"))
            elseif self.selectPreStatus == InfoHonorEumn.preStatus.Has then
                if HonorManager.Instance.model.current_honor_id == 0 or HonorManager.Instance.model.current_honor_id  == nil then
                    NoticeManager.Instance:FloatTipsByString("当前没有装备任何称号")
                    return
                end
                if DataHonor.data_get_honor_list[HonorManager.Instance.model.current_honor_id].is_can_pre == 0 then
                    NoticeManager.Instance:FloatTipsByString("当前称号无法添加前缀")
                    return
                end

                 HonorManager.Instance:request12708(self.pre_data_id_list[self.selectPreIndex].pre_id)
                 HonorManager.Instance.preStatusId = self.pre_data_id_list[self.selectPreIndex].pre_id
            elseif self.selectPreStatus == InfoHonorEumn.preStatus.Use then
                HonorManager.Instance:request12708(0)
            end

        elseif self.exChange == true then
            local num = BackpackManager.Instance:GetItemCount(self.pre_data_id_list[self.selectPreIndex].loss_items[1][1])
             if num >= self.pre_data_id_list[self.selectPreIndex].loss_items[1][2] then
                HonorManager.Instance:request12709(self.pre_data_id_list[self.selectPreIndex].pre_id)
            else
                NoticeManager.Instance:FloatTipsByString("典藏卡不足无法兑换")
            end

        end
    end
end

function InfoHonorWindow:InitHonor()
    if self.my_data ~= nil then
        if self.honorText ~= nil then

            if DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id] ~= nil then
                 self.honorText.text = string.format("<color='#b031d5'>%s·%s</color>",DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id].pre_name,self.my_data.final_name)
            else
                self.honorText.text = string.format("<color='#b031d5'>%s</color>",self.my_data.final_name)
            end
        end
        local str1 = string.format("%s%s", TI18N("达成条件："), self.my_data.cond_desc)
        local str = ""
        local isExt = false;
        for _, attr in pairs(self.my_data.attr_list)  do
             isExt = true
            if attr.name >= 51 and attr.name <= 62 then
                str = string.format("%s%s+%s%s", str, KvData.attr_name[attr.name], attr.val, "%").."，"
            else
                str = string.format("%s%s+%s", str, KvData.attr_name[attr.name], attr.val).."，"
            end
        end
        local len = string.len(str)
        local isInStr = false
        if isExt and len > 1 then
          str = string.sub(str, 1, len - 3)
          local fkstr = string.format("<color='#00ffff'>%s</color>",str);
            if self.my_data.collect_desc ~= nil and self.my_data.collect_desc ~= "" then
                str1 = string.format("%s\n%s%s", str1, TI18N("附加属性："), fkstr)
                isInStr = true
            end
        end
        if self.my_data.collect_desc ~= nil and self.my_data.collect_desc ~= "" then
            if isInStr == true then
                str1 = str1 .. "，" .. self.my_data.collect_desc
            else
                str1 = str1 .. "\n" .. "附加属性：" .. self.my_data.collect_desc
            end
        end
        self.infoText.text = str1

        if self.my_data.end_time == nil or self.my_data.end_time - BaseUtils.BASE_TIME < 0 then
            self.timeText.text = ""
        else
            self.timeText.text = string.format("剩余：%s", BaseUtils.formate_time_gap(self.my_data.end_time - BaseUtils.BASE_TIME, nil, 1, BaseUtils.time_formate.DAY))
        end

        if self.my_data.has ~= true then        -- 未拥有
            self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.leftBtnText.text = TI18N("未拥有")
        elseif self.my_data.id == HonorManager.Instance.model.current_honor_id then
            self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.leftBtnText.text = TI18N("取 消")
        else
            self.leftBtnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.leftBtnText.text = TI18N("使 用")
        end
    end
end

function InfoHonorWindow:Update(data)
    self.my_data = data
    self:InitHonor()
end


function InfoHonorWindow:SwitchTabs(id)
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
    self:ChangeTab(index)


end

function InfoHonorWindow:ChangeTab(index)
    self:on_update_honors()
    if index == 1 then
        self.mask_con.gameObject:SetActive(true)
        self.preHonor_mask.gameObject:SetActive(false)
        if DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id] ~= nil then
            self.honorText.text = string.format("<color='#b031d5'>%s·%s</color>",DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id].pre_name,self.my_data.final_name)
        else
            self.honorText.text = string.format("<color='#b031d5'>%s</color>",self.my_data.final_name)
        end
        self.leftBtnImage.gameObject:SetActive(true)
        self.info.gameObject:SetActive(true)
        self.info2.gameObject:SetActive(false)
       if  self.my_data ~= nil then
            self:Update(self.my_data)
        end
        self.leftBtnImage.transform.anchoredPosition = Vector2(-196,38)
        self.bottom1.gameObject:SetActive(false)
        self.bottom2.gameObject:SetActive(false)
    elseif index == 2 then
        -- if DataHonor.data_get_honor_list[HonorManager.Instance.model.current_honor_id] ~= nil then
        --     self.honorText.text = string.format("<color='#b031d5'>%s</color>",DataHonor.data_get_honor_list[HonorManager.Instance.model.current_honor_id].name)
        -- else
        --     self.honorText.text = ""
        -- end
        self.mask_con.gameObject:SetActive(false)
        self.preHonor_mask.gameObject:SetActive(true)
        self.preHonor_mask_con.sizeDelta = Vector2(350,364)
        self.preHonor_mask_scroll.sizeDelta = Vector2(350,364)
        self.leftBtnImage.gameObject:SetActive(false)
        self.leftBtnImage.transform.anchoredPosition = Vector2(-196,38)
        self.info.gameObject:SetActive(false)
        self.info2.gameObject:SetActive(true)
        self.bottom1.gameObject:SetActive(true)
        self.bottom2.gameObject:SetActive(false)
        self:ApplyPreObjBtn(1,true)



    elseif index == 3 then
        self.mask_con.gameObject:SetActive(false)
        self.preHonor_mask.gameObject:SetActive(true)
        self.leftBtnImage.gameObject:SetActive(false)
        self.info.gameObject:SetActive(false)
        self.info2.gameObject:SetActive(true)
        self.preHonor_mask_scroll.sizeDelta = Vector2(350,300)
        self.preHonor_mask_con.sizeDelta = Vector2(350,300)
        self.leftBtnImage.transform.anchoredPosition = Vector2(291,77)
        self.bottom1.gameObject:SetActive(false)
        self.bottom2.gameObject:SetActive(true)
        self:ApplyPreObjBtn(1,true)
        self:RefreshCostNum()
    end


end


function InfoHonorWindow:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end

function InfoHonorWindow:RefreshCostNum()


    if  self.currentTabIndex == 3 then

        -- print("使用的序号" .. self.selectPreIndex )
        if self.pre_data_id_list[self.selectPreIndex] ~= nil and self.pre_data_id_list[self.selectPreIndex].loss_items[1] ~= nil then
            local allNum = BackpackManager.Instance:GetItemCount(self.pre_data_id_list[self.selectPreIndex].loss_items[1][1])
            local acceptNum = self.pre_data_id_list[self.selectPreIndex].loss_items[1][2]
            if allNum >= acceptNum then
                self.allNumText.text = string.format("<color='#00ff00'>%s</color>",allNum)
            else
                self.allNumText.text = string.format("<color='#df3435'>%s</color>",allNum)
            end
            self.acceptNumText.text = string.format("<color='#ffffff'>%s</color>",acceptNum)
        end
    end
end

function InfoHonorWindow:CallBack(table,height)
    local gameObject = GameObject.Instantiate(table.componentContainer:Find("Button").gameObject)
    table:SetParent(table.objParent,gameObject)
    table.confirmBtn = gameObject.transform:GetComponent("Button")
    table.confirmBtn.onClick:AddListener(function() table:DeleteMe() end)
    table.confirmText = gameObject.transform:Find("Text"):GetComponent(Text)
    table.countTime = 10

    if self.getRewardEffect == nil then
        self.getRewardEffect = BibleRewardPanel.ShowEffect(20298,table.objParent.transform, Vector3(1, 1, 1), Vector3(0,(height / 2) - 20, -2))
    end
    self.getRewardEffect:SetActive(true)

    local rectTransform = gameObject.transform:GetComponent(RectTransform)
    rectTransform.anchoredPosition = Vector2(0,- table.containerHeight / 2 + 20)
end

function InfoHonorWindow:SecondCallBack(table)
    if table.countTime <= 0 then
       table:DeleteMe()
    else
       table.confirmText.text = "确定" .. string.format("(%ss)", tostring(table.countTime))
    end
end



function InfoHonorWindow:DeleteCallBack()
    if self.getRewardEffect ~= nil then
      self.getRewardEffect:DeleteMe()
      self.getRewardEffect = nil
    end

    -- if self.beatifulId == nil then
    --   self.beatifulId = LuaTimer.Add(0,3000, function()
    --             self:BeautifualEffect()
    --   end)
    -- end

     if self.iconEffect ~= nil then
      self.iconEffect:SetActive(true)
    end
end