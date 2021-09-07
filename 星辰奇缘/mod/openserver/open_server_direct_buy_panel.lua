-- @author hze
-- @date #19/05/11#
-- @开服养成直购活动

OpenServerDirectBuyPanel = OpenServerDirectBuyPanel or BaseClass(BasePanel)

function OpenServerDirectBuyPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.open_server_directbuypanel, type = AssetType.Main},
        {file = AssetConfig.open_server_directbuypanel_bg, type = AssetType.Main},
        {file = AssetConfig.open_server_directbuypanel_txt, type = AssetType.Main},
        {file = AssetConfig.open_server_textures2, type = AssetType.Dep},
    }
    self.model = model
    self.parent = parent
    self.mgr = OpenServerManager.Instance
    self.itemList = nil

    self.timeFormat = TI18N("<color='#2bf171'>%s月%s日-%s月%s日</color>每日上新")
    self.countFormat = TI18N("剩\n%s\n次")

    self.petImgList = {}
    self.itemList = {}

    self.rewardData = {}

    self.coldMark = true  --Tween冷却
    self.pageIndex = 1  --当前第几个
    self.showCount = 3  --当前界面显示数量
    
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.reloadListener = function(data) self:ReloadData(data) end
end

function OpenServerDirectBuyPanel:__delete()
    -- if self.itemList ~= nil then
    --     for i=1,#self.itemList do
    --         local item = self.itemList[i]
    --         item.slot:DeleteMe()
    --     end
    -- end

    self.OnHideEvent:Fire()
    
    if self.btnEffect then 
        self.btnEffect:DeleteMe()
    end

    if self.layout then 
        self.layout:DeleteMe()
    end

    if self.possibleReward then 
        self.possibleReward:DeleteMe()
    end

    if self.itemList then 
        for _, v in ipairs(self.itemList) do
            if v.itemSlot ~= nil then 
                for _, vv in ipairs(v.itemSlot) do
                    vv:DeleteMe()
                end
            end
        end
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function OpenServerDirectBuyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_directbuypanel))
    self.gameObject.name = "OpenServerDirectBuyPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    -- EventMgr.Instance:AddListener(event_name.update_cash_gift_info, self.OnUpdateInfo)
    local t = self.transform

    UIUtils.AddBigbg(t:Find("TopCon/ImgBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_directbuypanel_bg)))
    UIUtils.AddBigbg(t:Find("TopCon/TxtBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_directbuypanel_txt)))
    for i =1 ,3 do
        self.petImgList[i] = t:Find(string.format("TopCon/PetImage%s",i)):GetComponent(Image)
    end

    self.sliderTrans = t:Find("TopCon/Slider"):GetComponent(RectTransform)
    self.fillAreaTrans = self.sliderTrans:Find("Img"):GetComponent(RectTransform)
    self.sliderTxt = t:Find("TopCon/Slider/Txt"):GetComponent(Text)
    self.intimateTxtImg = t:Find("TopCon/IntimateTxtBg/IntimateTxtImg"):GetComponent(Image)

    self.chestBtn = t:Find("Chest"):GetComponent(Button)
    self.chestBtn.onClick:AddListener(function() self:ShowGift(self.gift_id)  end)
    self.rewardBtn = t:Find("RewardBtn"):GetComponent(Button)
    -- self.rewardBtn.onClick:AddListener(function() self.model:OpenRewardViewPanel(self.rewardData) end)   --每级宝箱一致，这个奖励预览屏蔽
    self.rewardBtn.onClick:AddListener(function() self:ShowGift(self.gift_id) end)

    self.itemContainer = t:Find("MaskScroll/Container")
    self.itemCloner = t:Find("MaskScroll/Container/Item").gameObject
    self.itemCloner:SetActive(false)

    self.timeTxt = t:Find("TimeTxt"):GetComponent(Text)

    self.prePageBtn = t:Find("PreBtn"):GetComponent(Button)
    self.nextPageBtn = t:Find("NextBtn"):GetComponent(Button)

    self.layout = LuaBoxLayout.New(self.itemContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    self.prePageBtn.onClick:AddListener(function() self:TurnPage(-1) end)
    self.nextPageBtn.onClick:AddListener(function() self:TurnPage(1) end)

    local tipsBtn = self.transform:Find("TopCon/TipsBtn"):GetComponent(Button)
    tipsBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = tipsBtn.gameObject, itemData = self.tipsData}) end)
end

function OpenServerDirectBuyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerDirectBuyPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.directBuyUpdateEvent:AddListener(self.reloadListener)

    local campData = DataCampaign.data_list[self.campId]
    local open_time = CampaignManager.Instance.open_srv_time
    local end_time = open_time + campData.cli_end_time[1][2] * 24 * 3600 + campData.cli_end_time[1][3]
    self.timeTxt.text = string.format( self.timeFormat, tonumber(os.date("%m", open_time)), tonumber(os.date("%d", open_time)), tonumber(os.date("%m", end_time)), tonumber(os.date("%d", end_time)))
    -- self.timeTxt.text = string.format(self.timeFormat, campData.cli_start_time[1][2], campData.cli_start_time[1][3], campData.cli_end_time[1][2], campData.cli_end_time[1][3])

    self.tipsData = {campData.cond_desc}  
    self.gift_id = tonumber(campData.conds or 22300)

    self.mgr:send20473()

    self:DealExtraEffect()
end

function OpenServerDirectBuyPanel:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then 
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    BaseUtils.ReleaseImage(self.intimateTxtImg)
    
    if self.timerId_effect ~= nil then 
        LuaTimer.Delete(self.timerId_effect)
        self.timerId_effect = nil
    end
end

function OpenServerDirectBuyPanel:RemoveListeners()
    self.mgr.directBuyUpdateEvent:RemoveListener(self.reloadListener)
end


--更新界面显示
function OpenServerDirectBuyPanel:ReloadData(data)
    BaseUtils.dump(data,"data111111111")

    self.now_bring_lev = data.now_bring_lev --当前等级
    

    self.rewardData = BaseUtils.copytab(data.bring_up_gift)
    -- self.gift_id = self.rewardData[1].gift_id
    self.gift_id = self.rewardData[data.now_bring_lev].gift_id

    self.intimateTxtImg.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures2, string.format( "IntimateTxtImg%s", data.now_bring_lev))
    self.intimateTxtImg:SetNativeSize()

    local callBack = function(val) 
        self.sliderTxt.text = string.format( "%s/%s", val, data.levup_point)
        self.fillAreaTrans.sizeDelta = Vector2((val / data.levup_point) * self.sliderTrans.sizeDelta.x, self.sliderTrans.sizeDelta.y - 3)
    
        for i,v in ipairs(self.petImgList) do
            if val >= data.bring_up_info[i].goal_point then 
                v.transform.gameObject:SetActive(true)
            else
                v.transform.gameObject:SetActive(false)
            end
        end
    end

    local val = self.model.now_bring_val or data.now_bring_val
    local total_val = self.model.levup_point or data.levup_point
    local lev_old = self.model.now_bring_lev or data.now_bring_lev
    local val_old = 0

    self.timerId = LuaTimer.Add(0, 5, function()
            if lev_old == data.now_bring_lev then 
                if val < data.now_bring_val then 
                    val = val + 1
                else
                    if self.timerId ~= nil then 
                        LuaTimer.Delete(self.timerId)
                        self.timerId = nil
                    end
                end
            else
                if val_old == total_val then 
                    if val < data.now_bring_val then 
                        val = val + 1
                    else
                        if self.timerId ~= nil then 
                            LuaTimer.Delete(self.timerId)
                            self.timerId = nil
                        end
                    end
                else
                    if val < total_val then
                        val = val + 1
                    else
                        val_old = total_val
                        val = 0
                    end
                end
            end
            callBack(val)
        end)
    
    self.model.now_bring_val =  data.now_bring_val
    self.model.levup_point =  data.levup_point
    self.model.now_bring_lev = data.now_bring_lev

    -- self.sliderTxt.text = string.format( "%s/%s", data.now_bring_val, data.levup_point)
    -- self.fillAreaTrans.sizeDelta = Vector2((data.now_bring_val / data.levup_point) * 300, 19)

    -- for i,v in ipairs(self.petImgList) do
    --     if data.now_bring_val >= data.bring_up_info[i].goal_point then 
    --         v.transform.gameObject:SetActive(true)
    --     else
    --         v.transform.gameObject:SetActive(false)
    --     end
    -- end

    self.itemCount = #data.camp_info
    self.layout:ReSet()
    for i, info in pairs(data.camp_info) do
        local tab = self.itemList[i]
        if not tab then  
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.itemCloner)
            tab.transform = tab.gameObject.transform
            tab.name = tostring(info.type)
    
            tab.nameTxt = tab.transform:Find("NameTxtBg/NameTxt"):GetComponent(Text)
            tab.descTxt = tab.transform:Find("DescTxt"):GetComponent(Text)
            tab.countTxtBg = tab.transform:Find("CountTxtBg")
            tab.countTxt = tab.countTxtBg:Find("CountTxt"):GetComponent(Text)
            tab.itemSlot = {}
            tab.itemData = {}
            tab.itemBg = {}
            tab.slotContainer = tab.transform:Find("SlotContainer")
            for j =1, 4 do
                local itemslot = tab.itemSlot[j]
                if itemslot == nil then 
                    itemslot = ItemSlot.New()
                    tab.itemData[j] = ItemData.New()
                    tab.itemBg[j] =  tab.slotContainer:Find(string.format("SlotCon%s",j))
                    UIUtils.AddUIChild(tab.itemBg[j].gameObject, itemslot.gameObject)
                    tab.itemSlot[j] = itemslot
                end
            end
            tab.btn = tab.transform:Find("Button"):GetComponent(Button)
            tab.btnImg = tab.btn.transform:GetComponent(Image)
            tab.btnTxt = tab.btn.transform:Find("Text"):GetComponent(Text)
        end

        local count = #info.reward
        for index = 1 , 4 do
            local slotItem = tab.itemSlot[index]
            if index <= count then
                local slotData = info.reward[index]
                tab.itemData[index]:SetBase(DataItem.data_get[slotData.item_base_id])
                slotItem:SetAll(tab.itemData[index], {inbag = false, nobutton = true})
                slotItem:SetNum(slotData.num)
                slotItem:ShowEffect(slotData.client_effect == 1,20223)
                slotItem.client_effect = slotData.client_effect == 1
            else
                slotItem.gameObject:SetActive(false)
            end
        end


        --简单布局
        local w = tab.slotContainer.sizeDelta.x * 0.5
        local h = tab.slotContainer.sizeDelta.y * 0.5
        if count == 4 then 
            tab.itemBg[1].anchoredPosition = Vector2(-w*0.5, h*0.5)
            tab.itemBg[2].anchoredPosition = Vector2(w*0.5, h*0.5)
            tab.itemBg[3].anchoredPosition = Vector2(-w*0.5, -h*0.5)
            tab.itemBg[4].anchoredPosition = Vector2(w*0.5, -h*0.5)
        elseif count == 3 then 
            tab.itemBg[1].anchoredPosition = Vector2(0, h*0.5)
            tab.itemBg[2].anchoredPosition = Vector2(-w*0.5, -h*0.5)
            tab.itemBg[3].anchoredPosition = Vector2(w*0.5, -h*0.5)
        elseif count == 2 then 
            tab.itemBg[1].anchoredPosition = Vector2(-w*0.5,0)
            tab.itemBg[2].anchoredPosition = Vector2(w*0.5,0)
        elseif count == 1 then 
            tab.itemBg[1].anchoredPosition = Vector2(0,0)
        end

        
        tab.nameTxt.text = info.title
        tab.descTxt.text = info.desc

        tab.countTxt.gameObject:SetActive(info.type ~= 0)
        tab.countTxt.text = string.format(self.countFormat, info.time)

        tab.btn.onClick:RemoveAllListeners()
        if info.type == 0 then 
            tab.countTxtBg.gameObject:SetActive(false)
            if data.active_val < info.need_val then 
                tab.btnTxt.text = TI18N("领取")
                tab.btnTxt.color = ColorHelper.DefaultButton2
                tab.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                if self.btnEffect ~= nil then
                    self.btnEffect:SetActive(false)
                end
            elseif info.time > 0 then 
                tab.btnTxt.text = TI18N("领取")
                tab.btnTxt.color = ColorHelper.DefaultButton3
                tab.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                if self.btnEffect == nil then
                    self.btnEffect = BaseUtils.ShowEffect(20053, tab.btnImg.transform, Vector3(1.9, 0.75, 1), Vector3(-60, -16, -1000))
                end
                self.btnEffect:SetActive(true)
            elseif info.time == 0 then 
                tab.btnTxt.text = TI18N("已领取")
                tab.btnTxt.color = ColorHelper.DefaultButton4
                tab.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                if self.btnEffect ~= nil then 
                    self.btnEffect:SetActive(false)
                end
            end
            tab.btn.onClick:AddListener(function() self.mgr:send20474() end)
        else 
            if info.time > 0 then 
                tab.btnTxt.text = string.format(TI18N("%s元购买"), BaseUtils.DiamondToRmb(info.need_val))
                tab.btnTxt.color = ColorHelper.DefaultButton3
                tab.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            elseif info.time == 0 then 
                tab.btnTxt.text = TI18N("售罄")
                tab.btnTxt.color = ColorHelper.DefaultButton4
                tab.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                tab.countTxtBg.gameObject:SetActive(false)
            end
            tab.btn.onClick:AddListener(function() 
                if SdkManager.Instance:RunSdk() then
                    SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(info.need_val), BaseUtils.DiamondToRmb(info.need_val), info.need_val / 10 * 10, "6")
                end 
            end)
        end
        self.layout:AddCell(tab.gameObject)
        self.itemList[i] = tab
    end


    --翻页按钮状态初始化
    if self.itemCount == self.showCount then 
        self.prePageBtn.gameObject:SetActive(false)
        self.nextPageBtn.gameObject:SetActive(false)
    else
        BaseUtils.SetGrey(self.prePageBtn.transform:GetComponent(Image), self.pageIndex == 1)
        BaseUtils.SetGrey(self.nextPageBtn.transform:GetComponent(Image), self.pageIndex + self.showCount - 1 == self.itemCount)
    end
end

--翻页逻辑
function OpenServerDirectBuyPanel:TurnPage(direction)
    local xContainerPos = self.itemContainer.anchoredPosition.x
    local xItemClonerSize = self.itemCloner.transform.sizeDelta.x

    if self.coldMark then
        self.coldMark = false
        if (self.pageIndex == 1 and direction == -1) or (self.pageIndex + self.showCount - 1 == self.itemCount and direction == 1) then 
            direction = 0
        else
            self.pageIndex = self.pageIndex + direction
        end
        local xVal = xContainerPos + (- direction * xItemClonerSize)
        if self.ltDescr ~= nil then
            Tween.Instance:Cancel(self.ltDescr)
            self.ltDescr = nil
        end
        self.ltDescr = Tween.Instance:MoveX(self.itemContainer, xVal, 0.5, function() 
                self.coldMark = true
                BaseUtils.SetGrey(self.prePageBtn.transform:GetComponent(Image), self.pageIndex == 1)
                BaseUtils.SetGrey(self.nextPageBtn.transform:GetComponent(Image), self.pageIndex + self.showCount - 1 == self.itemCount)

            end, 
            LeanTweenType.easeOutQuint).id
    end
end

--打开礼包
function OpenServerDirectBuyPanel:ShowGift(gift_id)
    -- print("打开礼包内容,gift_id:" .. gift_id)
    local gift_list = DataItemGift.data_show_gift_list[gift_id]
    
    local callBack = function(myself) myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x,myself.gameObject.transform.localPosition.y,200) end

    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self,callBack)
    end

    local str = TI18N("可随机获得以下道具之一")
    if self.now_bring_lev == 6 or self.now_bring_lev == 7 then
        str = TI18N("可获得稀有背饰及随机获得稀有道具中的一个")
    end
    self.possibleReward:Show({CampaignManager.ItemFilterForItemGift(gift_list),4,{140,140,120,120}, str})
end

--处理特效
function OpenServerDirectBuyPanel:DealExtraEffect()
    self.timerId_effect = LuaTimer.Add(0,200, function()
        if self.itemList == nil then 
            LuaTimer.Delete(self.timerId_effect)
        end

        for i, v in ipairs(self.itemList) do
            local show = (i >= self.pageIndex and i <= (self.pageIndex + self.showCount - 1)) 
            local itemSlot = v.itemSlot
            if itemSlot ~= nil then 
                for index = 1 , 4 do
                    itemSlot[index]:ShowEffect(show and itemSlot[index].client_effect, 20223)
                end
            end
        end
    end)
end




