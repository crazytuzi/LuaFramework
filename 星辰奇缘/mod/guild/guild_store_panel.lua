-- @author 黄耀聪
-- @date 2017年3月6日

GuildStorePanel = GuildStorePanel or BaseClass(BasePanel)

function GuildStorePanel:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.name = "GuildStorePanel"

    self.updateListener = function() self:update_view() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self:InitPanel()
end

function GuildStorePanel:__delete()
    for i,v in ipairs(self.itemList) do
        if v ~= nil then
            v:Release()
            v:DeleteMe()
        end
    end
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GuildStorePanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.LeftCon=t:FindChild("LeftCon").gameObject
    -- self.LeftCon:SetActive(false)

    self.scroll_con = self.LeftCon.transform:FindChild("MaskLayer"):FindChild("ScrollLayer").gameObject
    self.scroll_rect = self.scroll_con.transform:GetComponent(ScrollRect)
    self.layoutLayer = self.scroll_con.transform:FindChild("LayoutLayer")
    self.originItem = self.layoutLayer:FindChild("Item").gameObject
    self.originItem:SetActive(false)
    self.TxtStoreLev=self.LeftCon.transform:FindChild("BottomCon"):FindChild("TxtStoreLev"):GetComponent(Text)
    self.TxtFleshTime=self.LeftCon.transform:FindChild("BottomCon"):FindChild("TxtFleshTime"):GetComponent(Text)
    self.ImgTanHao = self.LeftCon.transform:FindChild("BottomCon"):FindChild("ImgTanHao"):GetComponent(Button)
    self.RIghtCon=t:FindChild("RIghtCon").gameObject
    -- self.RIghtCon:SetActive(false)
    self.TxtTitle=self.RIghtCon.transform:FindChild("TopCon"):FindChild("ImgTitle"):FindChild("TxtTitle"):GetComponent(Text)
    self.TxtDesc_go=self.RIghtCon.transform:FindChild("TopCon"):FindChild("ScrollRect/TxtDesc"):GetComponent(Text)
    self.TxtDesc = MsgItemExt.New(self.TxtDesc_go, 248, 18, 23)
    self.BtnMinus=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon0"):FindChild("BtnMinus"):GetComponent(Button)
    -- self.TxtNum=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon0"):FindChild("TxtNum"):GetComponent(Text)

    self.TxtNum = self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon0"):FindChild("TxtNum"):GetComponent(InputField)
    self.TxtNum.textComponent  =  self.TxtNum.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.TxtNum.placeholder  =  self.TxtNum.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)
    self.TxtNum.onEndEdit:AddListener(function (val)
        local temp = tonumber(val)
        if temp == nil then
            return
        end
        local leftNum = 0
        if self.selected_data.type ~= 1 then
            --非共享
            if self.selected_data.Limit ~= 0 then --有限购
                leftNum = self.selected_data.Limit - self.selected_data.RoleNum
            else --无限购
                leftNum = self.selected_data.RoleNum
            end

            if leftNum < 1 then
                leftNum = 1
            end
            if temp>leftNum then
                temp = leftNum
            end
        else
            if temp > self.selected_data.Num then
                temp = self.selected_data.Num
            end
        end
        if temp <= 0 then
            temp = 1
        end

        self.TxtNum.text = tostring(temp)
    end)

    self.BtnPlus=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon0"):FindChild("BtnPlus"):GetComponent(Button)
    self.TxtValue1=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon1"):FindChild("TxtValue"):GetComponent(Text)
    self.ImgIcon1=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon1"):FindChild("ImgIcon"):GetComponent(Image)
    self.TxtValue2=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon2"):FindChild("TxtValue"):GetComponent(Text)
    self.ImgIcon2=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("ItemCon2"):FindChild("ImgIcon"):GetComponent(Image)
    self.BtnExchange=self.RIghtCon.transform:FindChild("BottomCon"):FindChild("BtnExchange"):GetComponent(Button)
    self.Toggle1 = self.RIghtCon.transform:FindChild("BottomCon"):FindChild("Toggle1"):GetComponent(Toggle)

    self.Toggle1.onValueChanged:RemoveAllListeners()
    self.Toggle1.isOn = self.model.guild_store_is_warm_tips

    self.Toggle1.onValueChanged:AddListener(function(status)
        self.model.guild_store_is_warm_tips = status
    end)

    self.restoreFrozen_exchange = FrozenButton.New(self.BtnExchange)

    self.ImgTanHao.onClick:AddListener(function() self:on_click_tanhao_tips() end)
    self.BtnMinus.onClick:AddListener(function() self:on_click_btn(1) end)
    self.BtnPlus.onClick:AddListener(function() self:on_click_btn(2) end)
    self.BtnExchange.onClick:AddListener(function() self:on_click_btn(3) end)
    self.TxtNum.text="0"


    GuildManager.Instance:request11118()
    GuildManager.Instance:request11120()
    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()


    self.model.guild_store_has_refresh = false
end

function GuildStorePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildStorePanel:OnOpen()
    self:RemoveListeners()
    self.model.onUpdateStore:AddListener(self.updateListener)

    self:update_view()
end

function GuildStorePanel:OnHide()
    self:RemoveListeners()

    self:stop_timer()
end

function GuildStorePanel:RemoveListeners()
    self.model.onUpdateStore:RemoveListener(self.updateListener)
end



------------------------------面板更新逻辑
function GuildStorePanel:update_view()

    if self.itemList==nil then
        self.itemList = {}
    else
        for i=1,#self.itemList do
            local item = self.itemList[i]
            item.gameObject:SetActive(false) --把全部隐藏起来
        end
    end

    local datalist = nil
    if self.model.store_list ~=nil then
        datalist = self.model.store_list
    else
        datalist = {}
    end

    for i=1,#datalist do
        local data = datalist[i]
        local gsItem = self.itemList[i]
        if gsItem == nil then
            gsItem = GuildStoreItem.New(self, self.originItem, data, i)
            table.insert(self.itemList, gsItem)
        else
            gsItem:reset_data(data, i)
            gsItem.gameObject:SetActive(true) --把全部隐藏起来
        end
    end

    self.TxtStoreLev.text = string.format(self.model.guild_lang.GUILD_STORE_CUR_LEV,self.model.my_guild_data.store_lev)
    self.LeftCon:SetActive(true)

    if self.model.store_flesh_time == 0 then
        self:stop_timer()
    else
        self:start_timer()
    end

    -- self.layoutLayer

    local newH = 95*math.ceil(#datalist/2)
    local rect = self.layoutLayer:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(444, newH)
end


--选中左边一条条目时，更新右边的内容
function GuildStorePanel:update_right_inner(data, itemData)
    -- if self.selected_data==data then
    --     return
    -- end

    self.selected_data = data
    self.TxtTitle.text = ColorHelper.color_item_name(itemData.quality,itemData.name)
    -- self.TxtDesc.text = itemData.desc
    --self.TxtDesc:SetData(QuestEumn.FilterContent(itemData.desc))
    self.TxtNum.text = "1"
    local ddesc = BaseUtils.ReplacePattern(itemData)
    self.TxtDesc:SetData(QuestEumn.FilterContent(ddesc))
    local l = data.prices
    self.ImgIcon1.sprite= PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures , string.format("Assets%s",l[1].name))
    self.ImgIcon1.gameObject:SetActive(true)

    local myNum = 0

    if l[1].name >= 90000 then--资产
        if l[1].name == 90000 then
            myNum = RoleManager.Instance.RoleData.coin
        elseif l[1].name == 90002 then
            myNum = RoleManager.Instance.RoleData.gold
        elseif l[1].name == 90003 then
            myNum = RoleManager.Instance.RoleData.gold_bind
        elseif l[1].name == 90011 then
            myNum = RoleManager.Instance.RoleData.guild
        end
    else --道具
        myNum= ackpackManager.Instance:GetItemCount(l[1].name)
    end
    self.TxtValue2.text = tostring(myNum)

    if myNum < l[1].val then
        local temp = string.format("<color='#ff0000'>%d</color>",tostring(l[1].val))
        self.TxtValue1.text= tostring(temp)
    else
        local temp = string.format("<color='#4dd52b'>%d</color>",tostring(l[1].val))
        self.TxtValue1.text= tostring(temp)
    end


    self.ImgIcon2.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures , string.format("Assets%s",l[1].name))
    self.ImgIcon2.gameObject:SetActive(true)
    self.RIghtCon:SetActive(true)
end

--外部更新面板右边数据
function GuildStorePanel:update_right()
    -- print("-------------------------------更新")
    if self.selected_data == nil then
        return
    end

    local l = self.selected_data.prices

    local myNum = 0
    if l[1].name >= 90000 then--资产
        if l[1].name == 90000 then
            myNum = RoleManager.Instance.RoleData.coin
        elseif l[1].name == 90002 then
            myNum = RoleManager.Instance.RoleData.gold
        elseif l[1].name == 90003 then
            myNum = RoleManager.Instance.RoleData.gold_bind
        elseif l[1].name == 90011 then
            myNum = RoleManager.Instance.RoleData.guild
        end
    else --道具
        myNum= mod_item.item_count(l[1].name)
    end
    self.TxtValue2.text = myNum
end

---------------------各种点击事件监听
function GuildStorePanel:on_click_btn(index)
    if index== 1 then
        local temp =  tonumber(self.TxtNum.text)
        temp = temp - 1
        if temp<1 then
            temp = 1
        end
        self.TxtNum.text = tostring(temp)
    elseif index== 2 then
        local temp= tonumber(self.TxtNum.text)
        temp = temp + 1
        local leftNum = 0

        if self.selected_data.type ~= 1 then
            --非共享
            if self.selected_data.Limit ~= 0 then --有限购
                leftNum = self.selected_data.Limit - self.selected_data.RoleNum
            else --无限购
                leftNum = self.selected_data.RoleNum
            end

            if leftNum < 1 then
                leftNum = 1
            end
            if temp>leftNum then
                temp = leftNum
            end
        else
            if temp > self.selected_data.Num then
                temp = self.selected_data.Num
            end
        end
        if temp <= 0 then
            temp = 1
        end

        self.TxtNum.text = tostring(temp)
    elseif index== 3 then
        if self.selected_data==nil then
            NoticeManager.Instance:FloatTipsByString(self.model.guild_lang.GUILD_STORE_EXCHANGE_UNSELECT_NOTICE)
            return
        end
        local num= tonumber(self.TxtNum.text)
        if self.selected_data.type == 3 then
            NoticeManager.Instance:FloatTipsByString(TI18N("下一级可兑换"))
        elseif self.selected_data.type == 2 then
            GuildManager.Instance:request11162(self.selected_data.Id,num)
        else
            GuildManager.Instance:request11119(self.selected_data.Id,num)
        end
    end
end


function GuildStorePanel:on_click_tanhao_tips(g)
    local tips = {}

    local current_time = self.model.store_flesh_time + BaseUtils.BASE_TIME
    local hour = os.date("%H", current_time)
    local mi = os.date("%M", current_time)
    table.insert(tips, string.format("%s%s:%s%s", TI18N("1.商店每天"), hour, mi, TI18N("刷新稀有物品")))
    table.insert(tips, TI18N("2.消耗贡献与金币可兑换"))
    TipsManager.Instance:ShowText({gameObject = self.ImgTanHao.gameObject, itemData = tips})
end


-----------------------------------拖动逻辑
function GuildStorePanel:drag_begin(data)
    self.scroll_rect:OnInitializePotentialDrag(data)
    self.scroll_rect:OnBeginDrag(data)
end

function GuildStorePanel:draging(data)
    self.scroll_rect:OnDrag(data)
end


function GuildStorePanel:drag_end(data)
    self.scroll_rect:OnEndDrag(data)
end



----------------计时器逻辑
--计时关掉界面
function GuildStorePanel:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function GuildStorePanel:stop_timer()
    if self.timer_id ~= nil then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = nil
    end
end

function GuildStorePanel:timer_tick()
    self.model.store_flesh_time = self.model.store_flesh_time - 1
    if self.model.store_flesh_time == 0 then
        self:stop_timer()
    else
        local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.model.store_flesh_time)
        my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
        my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
        my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
        self.TxtFleshTime.text = string.format("<color='#8DE92A'>%s:%s:%s</color>", my_hour, my_minute, my_second)
    end
end

