-- @author hze
-- @date #19/02/25#
-- @开服新累充活动

OpenServerAccumulativeRechargePanel = OpenServerAccumulativeRechargePanel or BaseClass(BasePanel)

function OpenServerAccumulativeRechargePanel:__init(model, parent)
    self.parent = parent
    self.name = "OpenServerAccumulativeRechargePanel"

    self.mgr = OpenServerManager.Instance
    self.model = model

    self.resList = {
        {file = AssetConfig.open_server_accumulativerecharge, type = AssetType.Main},
        {file = AssetConfig.open_server_accumulativerecharge_bigbg, type = AssetType.Main},
        {file = AssetConfig.open_server_accumulativerecharge_bg, type = AssetType.Main},
        {file = AssetConfig.open_server_accumulativerecharge_txt, type = AssetType.Main},
        {file = AssetConfig.open_server_textures, type = AssetType.Dep},
        {file = AssetConfig.open_server_textures2, type = AssetType.Dep},
        {file = AssetConfig.accumulative_big_icon_textures, type = AssetType.Dep}
    }

    self.setting = {
        notAutoSelect = true,
        noCheckRepeat = false,
        perWidth = 101,
        perHeight = 131,
        isVertical = false,
        spacing = 0
    }

    self.timeFormat = TI18N("%s月%s日-%s月%s日")
    self.dateString = TI18N("第%s天")

    self.isMoving = false

    self.itemList = {}
    self.rewardItemList = {}
    -- self.effectList = {}

    self.showCount = 5
    self.btn_index = {}

    self.initflag = true
    self.coldStatus = false


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    
    self.reloadListener = function(data) self:ReloadData(data) end
end

function OpenServerAccumulativeRechargePanel:__delete()
    self.OnHideEvent:Fire()

    -- BaseUtils.ReleaseImage(self.iconImage)
    if self.iconloader then
        self.iconloader:DeleteMe()
    end

    if self.m_layout ~= nil then 
        self.m_layout:DeleteMe()
    end

    if self.rewardItemList ~= nil then
        for _,v in pairs(self.rewardItemList) do
            if v.effect ~= nil then 
                v.slot:DeleteMe()
            end
            if v.effect ~= nil then 
                v.effect:DeleteMe()
            end
        end
    end

    if self.btnEffect ~= nil then
        self.btnEffect:DeleteMe()
    end

    self:AssetClearAll()
end

function OpenServerAccumulativeRechargePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_accumulativerecharge))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.transform

    UIUtils.AddBigbg(self.transform:Find("Bigbg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_accumulativerecharge_bigbg)))
    UIUtils.AddBigbg(self.transform:Find("Top/TitleBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_accumulativerecharge_bg)))
    UIUtils.AddBigbg(self.transform:Find("Top/TxtBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_accumulativerecharge_txt)))

    self.timeTxt = self.transform:Find("Top/TimeText"):GetComponent(Text)
    self.iconImage = t:Find("ImageIcon"):GetComponent(Image)
    self.iconloader = SingleIconLoader.New(self.iconImage.gameObject)

    self.m_scrollRect = t:Find("MScrollRect"):GetComponent(ScrollRect)
    self.m_scrollRect.onValueChanged:AddListener(function()
        BaseUtils.DealExtraEffect(self.m_scrollRect, self.rewardItemList, {axis = BoxLayoutAxis.X, delta1 = 5})
    end)
    self.m_itemContainer = self.m_scrollRect.transform:Find("Container")

    self.m_layout = LuaBoxLayout.New(self.m_itemContainer, {axis = BoxLayoutAxis.X, cspacing = 5, border = 5})


    self.r_scrollRect = t:Find("RScrollRect"):GetComponent(ScrollRect)
    self.r_scrollRect.onValueChanged:AddListener(function()

    end)
    self.r_itemContainer = self.r_scrollRect.transform:Find("Container")

    self.btn = t:Find("RechargeBtn"):GetComponent(Button)
    self.btnImg = self.btn:GetComponent(Image)

    self.betweenTxt = t:Find("BetweenTxt"):GetComponent(Text)

    for index = 1 , 2 * self.showCount - 1 do
        local item = self.itemList[index] or {}
        if self.itemList[index] == nil then 
            item.gameObject = self.r_itemContainer:Find("ItemCloner"..index).gameObject
            item.transform = item.gameObject.transform
            item.rectTrans = item.transform:Find("Item")
            item.txt = item.rectTrans:Find("Txt"):GetComponent(Text)
            item.imgRect = item.rectTrans:Find("Image")
            item.select = item.rectTrans:Find("Select").gameObject
            item.btn = item.rectTrans:GetComponent(Button)
            item.red = item.rectTrans:Find("Red").gameObject
            self.itemList[index] = item
        end
        item.btn.onClick:RemoveAllListeners()
        item.btn.onClick:AddListener(function() self:OnRItemClick(index) end)
    end
end

function OpenServerAccumulativeRechargePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerAccumulativeRechargePanel:OnOpen()
    self:RemoveListeners()
    self.mgr.accumulativeRechargeUpdateEvent:AddListener(self.reloadListener)

    local campData = DataCampaign.data_list[self.campId]

    local open_time = CampaignManager.Instance.open_srv_time
    local end_time = open_time + campData.cli_end_time[1][2] * 24 * 3600 + campData.cli_end_time[1][3]
    self.timeTxt.text = string.format( self.timeFormat, tonumber(os.date("%m", open_time)), tonumber(os.date("%d", open_time)), tonumber(os.date("%m", end_time)), tonumber(os.date("%d", end_time)))

    --初始化
    self.initflag = true
    self.coldStatus = false

    self:UpdatePos()

    self:JumpImage()

    self.mgr:send20477()
end

function OpenServerAccumulativeRechargePanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then 
        LuaTimer.Delete(self.timerId)
    end 

    if self.tweenId ~= nil then 
        Tween.Instance:Cancel(self.tweenId)
    end

    if self.tweenId2 ~= nil then 
        Tween.Instance:Cancel(self.tweenId2)
    end
end

function OpenServerAccumulativeRechargePanel:RemoveListeners()
    self.mgr.accumulativeRechargeUpdateEvent:RemoveListener(self.reloadListener)
end


function OpenServerAccumulativeRechargePanel:ReloadData(data)  
    -- BaseUtils.dump(data,"20477data")
    self.data = data.reward_info
    table.sort(self.data, function(a, b) return a.charge < b.charge end)
    
    self.recharged_val =  data.recharged_val
    self.current_id = data.v_id
    if data.v_id == 0 then
        self.current_id = 1
    end
    self.max_len = #self.data

    -- if self.btn_index[self.showCount] == nil then self:SetBtnIndex(self.showCount) end

    -- BaseUtils.dump(self.btn_index,"按钮对应关系表")

    self:OnRItemClick(self.showCount, true)   

    -- for index , id in ipairs(self.btn_index) do
    --     if id == self.current_id then 
    --         self:OnRItemClick(index)
    --         break
    --     end
    -- end
    self.initflag = false
end

function OpenServerAccumulativeRechargePanel:OnRItemClick(index, protoFlag)
    if not protoFlag and index == self.showCount and not self.initflag then return end

    if self.coldStatus then return end
    self.coldStatus = true
    
    --设置对应关系
    self:SetBtnIndex(index)

    -- BaseUtils.dump(self.btn_index,"按钮对应关系表")

    self.selectId = self.btn_index[self.showCount]  --选中的id

    self:TweenTo(index)
end

--设置对应关系
function OpenServerAccumulativeRechargePanel:SetBtnIndex(index)
    -- print(self.current_id)
    local temp = self.btn_index[index] or self.current_id
    for i = self.showCount, 1, -1 do
        self.btn_index[i] = temp
        temp = (temp - 1 - 1) % self.max_len + 1
    end

    temp = self.btn_index[self.showCount]
    for i = self.showCount, 2 * self.showCount - 1 do
        self.btn_index[i] = temp
        temp = temp % self.max_len + 1
    end
end

function OpenServerAccumulativeRechargePanel:TweenTo(index)
    local id = index
    --tween动画
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end

    local tweenTime = 0.5
    if self.initflag then tweenTime = 0 end

    self.tweenId = Tween.Instance:ValueChange(self.r_itemContainer.anchoredPosition.y, 62 * (index - self.showCount), tweenTime,
        function()
            self.tweenId = nil
            --选中效果
            self.itemList[index].select:SetActive(false)
            self.itemList[self.showCount].select:SetActive(true)
            
            self.r_itemContainer.anchoredPosition = Vector2(0,0)    --设为初始值
            self:UpdatePos()    --更新位置信息
            self:UpdateItemData()   --更新item项信息
            self.coldStatus = false
        end
        , LeanTweenType.easeOutQuart,
        function(value)
            self.r_itemContainer.anchoredPosition = Vector2(0, value)
            self:UpdatePos()
        end).id
end

function OpenServerAccumulativeRechargePanel:UpdatePos()
    local y = nil
    local xx = nil
    local yy = nil
    local vy = nil
    for i,v in ipairs(self.itemList) do
        yy = yy or ((v.transform.sizeDelta.y) * (self.showCount - 1) * (v.transform.sizeDelta.y) * (self.showCount - 1))
        vy = vy or v.rectTrans.anchoredPosition.y
        y = v.transform.anchoredPosition.y  + self.r_itemContainer.anchoredPosition.y
        xx = 1 - ((y)*(y) / yy)
        if xx >= 0 then
            local vx = math.sqrt(xx) * 184 - 65          --根据实际需要设置（一般情况下 184 -65 等于 中心item轴点离scrollRect的水平距离）
            v.rectTrans.anchoredPosition = Vector2(vx, vy)
            local value = xx
            if value < 0.9 then
                value = 0.9
            end
            v.transform.localScale = Vector2(value,value)
        end
    end
end

function OpenServerAccumulativeRechargePanel:UpdateItemData()
    for index, item in ipairs(self.itemList) do
        local txtString = TI18N("已领取")
        local dat = self.data[self.btn_index[index]]

        if dat.flag == 0 or dat.flag == 2 then 
            txtString = string.format(TI18N("累充<color='#FFFF40'>%s</color>"), dat.charge)
        end

        item.red:SetActive(dat.flag == 2)

        item.txt.text = txtString

        local width = item.txt.preferredWidth - 40
        if width < 0  then width = 0 end
        item.imgRect.anchoredPosition = Vector2(width, 0)
    end

    self:ReloadReward() --加载奖励相关信息
end

function OpenServerAccumulativeRechargePanel:ReloadReward()
    local data = self.data[self.selectId]
    local items = data.items
    
    
    local shownum = 0
    self.m_layout:ReSet()
    for i, v in ipairs(items) do
        local item = self.rewardItemList[i]
        if item == nil then
            item = {}
            item.slot = ItemSlot.New()
            item.data = ItemData.New()
        end
        item.data:SetBase(BackpackManager:GetItemBase(v.item_base_id))
        item.slot:SetAll(item.data, {inbag = false, nobutton = true, noselect = true})
        item.slot:SetNum(v.num)
        item.slot.transform.sizeDelta = Vector2(60, 60)
        item.slot:ShowEffect(v.client_effect == 1,20223)
        item.gameObject = item.slot.gameObject
        item.effect = item.slot.effect
        self.m_layout:AddCell(item.slot.gameObject)
        self.rewardItemList[i] = item
        shownum = i

        if i == 1 then 
            local icon = v.item_base_id
            if v.item_base_id == 29262 then
                icon = 29263
            end
            if v.item_base_id == 29263 then
                icon = 29262
            end
            self.iconloader:SetSprite(SingleIconType.Other, icon)
            self.iconImage.gameObject:SetActive(true)
        end
    end
    for j = shownum + 1,#self.rewardItemList do
        self.rewardItemList[j].slot.gameObject:SetActive(false)
    end
    self.m_itemContainer.sizeDelta = Vector2(#items * 65 + 5, 60)

    -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.accumulative_big_icon_textures, "382")

                                                                
    self.btn.onClick:RemoveAllListeners()
    if data.flag == 0 then 
        self.btnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "RechargeBtn")
        self.btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)
        if self.btnEffect ~= nil then
            self.btnEffect:SetActive(false)
        end
    elseif data.flag == 1 then
        self.btnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "UnReceiveBtn")
        self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("奖励已领取")) end)
        if self.btnEffect ~= nil then
            self.btnEffect:SetActive(false)
        end
    elseif data.flag == 2 then 
        self.btnImg.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_textures, "ReceiveBtn")
        self.btn.onClick:AddListener(function() 
            self.mgr:send20478(data.id) 
        end)
        if self.btnEffect == nil then
            self.btnEffect = BaseUtils.ShowEffect(20053, self.btnImg.transform, Vector3(1.9, 0.75, 1), Vector3(-60, -16, -1000))
        end
        self.btnEffect:SetActive(true)
    end

    local min_charged = self.recharged_val   --下一阶段最小充值额度
    for _, v in ipairs(self.data) do
        if min_charged < v.charge then 
            min_charged = v.charge
            break
        end
    end

    --当前阶段鹰充值额度
    local between_num = data.charge - self.recharged_val
    self.betweenTxt.text = (between_num < 0) and 0 or between_num
    local w = self.betweenTxt.preferredWidth
    self.betweenTxt.transform.sizeDelta = Vector2(w + 12, 31)
end




function OpenServerAccumulativeRechargePanel:OnNotice()
    if self.campBaseData ~= nil then
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campBaseData.cond_desc}})
    end
end


function OpenServerAccumulativeRechargePanel:JumpImage()
    local iconImgRect = self.iconImage.transform:GetComponent(RectTransform)
    local origin_x = iconImgRect.anchoredPosition.x
    local origin_y = iconImgRect.anchoredPosition.y + 5
    local value = 0

    local callback = function()  
        if self.tweenId2 ~= nil then 
            Tween.Instance:Cancel(self.tweenId2)
            self.tweenId2 = nil
        end
        self.tweenId2 = Tween.Instance:ValueChange(0, 360, 2
            ,function() self.tweenId2 = nil end
            ,LeanTweenType.linear
            ,function(value) iconImgRect.anchoredPosition = Vector2(origin_x, origin_y + math.sin((value/180) * math.pi) * 10) end
        ).id
    end
    self.timerId = LuaTimer.Add(0,2000,callback)
end
