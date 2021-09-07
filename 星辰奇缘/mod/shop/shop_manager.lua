ShopManager = ShopManager or BaseClass(BaseManager)

function ShopManager:__init()
    if ShopManager.Instance then
        Log.Error("")
        return
    end
    ShopManager.Instance = self
    self:initHandle()
    self.model = ShopModel.New()

    self.redPoint = {{}, {}, {}}
    self.specialRed = {{}, {}, {}}
    self.redPoint[1][2] = true
    self.itemPriceTab = {}

    self.TTimeLimit = "TimeLimit"
    self.openThreeCharge = false  --开启三倍返利活动，默认关闭

    self.assetIdToKey = {}
    for k,v in pairs(KvData.assets) do
        self.assetIdToKey[v] = k
    end

    self.checkRedListener = function() self:CheckForMainUIRedPoint() end
    self.checkCharactor = function() self:OnCheckCharactor() end

    self.onUpdateRedPoint = EventLib.New()
    self.onUpdateCurrency = EventLib.New()
    self.onUpdateBuyPanel = EventLib.New()
    self.onUpdateUnfreeze = EventLib.New()
    self.onUpdateRecharge = EventLib.New()
    self.onUpdateRT = EventLib.New()
    self.onUpdateRebateReward = EventLib.New()

    self.onUpdateProgress = EventLib.New()

    self.onUpdateRedPoint:AddListener(self.checkRedListener)
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function()
        self:RequestData()
        -- EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.checkCharactor)
        -- EventMgr.Instance:AddListener(event_name.role_asset_change, self.checkCharactor)
        self.onUpdateRedPoint:Fire()
    end)
    EventMgr.Instance:AddListener(event_name.privilege_lev_change, function()
        -- local num = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialGift)
        -- print(num)
        -- if num > 0 then
            self:send11301(1)
        -- end
    end)

    self.dataList = {}
    --self:InitData()
end

-- 传入打开的子标签页的序号
function ShopManager:OpenWindow(args)
    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true and args ~= nil and #args > 0 and args[1] == 3 then
        NoticeManager.Instance:FloatTipsByString(TI18N("充值暂未开放"))
        return
    end
    local model = self.model
    model.currentMain = nil
    model.currentSub = nil

    local redPoint = ShopManager.Instance.redPoint
    if args == nil or #args == 0 then   -- 不带参数
        -- 判断红点
        for i=1,3 do
            for j=1,3 do
                if redPoint[i][j] == true then
                    model.currentMain = i
                    model.currentSub = j
                    model:OpenWindow()  -- 转跳红点页签
                    return
                end
            end
        end

        model.currentMain = 1
        model.currentSub = 1
        model:OpenWindow()  -- 转跳红点页签
    else
        local lev = RoleManager.Instance.RoleData.lev
        model.currentMain = args[1]
        model.currentSub = args[2]
        model.autoSelect = args[3]
        -- local c = 0
        -- for i,v in ipairs(model.dataTypeList[args[1]].subList) do
        --     if v.lev == nil or lev >= v.lev then
        --         c = c + 1
        --         if i == args[2] then
        --             model.currentSub = c
        --             break
        --         end
        --     end
        -- end

        local tab = model.dataTypeList[args[1]].subList[args[2]]
        if tab == nil or (tab.lev ~= nil and lev < tab.lev) then
            model.currentSub = 1
        end

        if model.currentMain < 3 then
            if model.currentSub == nil then
                model.currentSub = 1
            end

            -- local minLev = 120
            -- for k,v in pairs(DataShop.data_goods) do
            --     if v.tab == model.currentMain and v.tab2 == model.currentSub and v.lev <= lev and v.lev < minLev then
            --         minLev = v.lev
            --     end
            -- end

            -- if lev < 40 then
            --     model.currentMain = 1
            --     model.currentSub = 1
            -- end
        end

        model:OpenWindow()
    end
end

function ShopManager:initHandle()
    self:AddNetHandler(11300, self.on11300)
    self:AddNetHandler(11301, self.on11301)
    self:AddNetHandler(11302, self.on11302)
    self:AddNetHandler(11303, self.on11303)

    self:AddNetHandler(13900, self.on13900)
    self:AddNetHandler(13901, self.on13901)
    self:AddNetHandler(13902, self.on13902)
    self:AddNetHandler(13903, self.on13903)

    self:AddNetHandler(11400, self.on11400)
    self:AddNetHandler(10607, self.on10607)

    self:AddNetHandler(14019, self.on14019)
    self:AddNetHandler(9937, self.on9937)
    self:AddNetHandler(9953, self.on9953)
    self:AddNetHandler(9956, self.on9956)
    self:AddNetHandler(9957, self.on9957)

end

function ShopManager:on11300(data)
    local model = self.model
    if data.reload == 1 then
        if data.tab == 1 then
            model.datalist[1][1] = nil
            model.datalist[1][2] = nil
            model.datalist[1][3] = nil
            model.datalist[1][4] = nil
        elseif data.tab == 2 then
            model.datalist[2][1] = nil
            model.datalist[2][2] = nil
            model.datalist[2][3] = nil
            model.datalist[2][4] = nil
        end
        self:send11301(data.tab)
        self:send13900()
    end
end

function ShopManager:send11301(tab)
  -- print("发送11301")
    Connection.Instance:send(11301, {["tab"] = tab})
end

function ShopManager:on11301(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        -- BaseUtils.dump(data,"商店协议回调11301=====================================================================")
    end
    local model = self.model
    local ceil = math.ceil

    if data.tab == 1 then
        model.datalist[1][1] = {}
        model.datalist[1][2] = {}
        model.datalist[1][4] = {}
        model.datalist[1][5] = {}
        model.datalist[1][18] = {}
        for k,v in pairs(data.itemlist) do
            v.tab = 1
            table.insert(model.datalist[1][v.tab2], v)
            self.itemPriceTab[v.id] = v
        end
        for k,v in pairs(model.datalist[1]) do
            if v ~= nil then
                model.pageNum[1][k] = ceil((#v) / 8)  -- 计算各页签的页数
            end
        end

        for _,list in pairs(model.datalist[1]) do
            if list ~= nil then
                table.sort(list, function(a, b)
                        if a.sort == nil or b.sort == nil then
                            return a.id < b.id
                        else
                            return a.sort < b.sort
                        end
                    end)
            end
        end
        -- 时装新品展示45级弹窗
        if RoleManager.Instance.RoleData.lev >= 45 then
            BibleManager.Instance:AutoPopWin(21)
        end

        -- table.sort(dataList,function(a,b)
        --    if a.id ~= b.id then
        --         return a.id < b.id
        --     else
        --         return false
        --     end
        -- end)

    elseif data.tab == 2 then
        -- model.datalist[2][1] = {}
        -- model.datalist[2][2] = {}
        -- model.datalist[2][3] = {}
        -- model.datalist[2][4] = {}
        -- model.datalist[2][5] = {}
        -- model.datalist[2][6] = {}
        -- model.datalist[2][7] = {}
        -- model.datalist[2][8] = {}
        -- model.datalist[2][9] = {}
        -- model.datalist[2][10] = {}
        -- model.datalist[2][11] = {}
        -- model.datalist[2][12] = {}
        -- model.datalist[2][13] = {}
        -- model.datalist[2][14] = {}
        -- model.datalist[2][15] = {}
        -- model.datalist[2][16] = {}
        -- model.datalist[2][17] = {}
        -- model.datalist[2][19] = {}
        -- model.datalist[2][20] = {}
        -- model.datalist[2][21] = {}
        -- model.datalist[2][22] = {}
        -- model.datalist[2][23] = {}
        -- model.datalist[2][24] = {}
        -- model.datalist[2][25] = {}
        -- model.datalist[2][26] = {}
        -- model.datalist[2][27] = {}
        -- model.datalist[2][999] = {}
        -- model.datalist[2][231] = {}
        --

        model.datalist[2] = {}

        for k,v in pairs(data.itemlist) do
            v.tab = 2
            if model.datalist[2][v.tab2] == nil then
                model.datalist[2][v.tab2] = {}
            end
            table.insert(model.datalist[2][v.tab2], v)
            self.itemPriceTab[v.id] = v
        end
        for k,v in pairs(model.datalist[2]) do
            if v ~= nil then
                model.pageNum[2][k] = ceil((#v) / 8)  -- 计算各页签的页数
            end
        end

        for _,list in pairs(model.datalist[2]) do
            if list ~= nil then
                table.sort(list, function(a, b)
                        if a.sort == nil or b.sort == nil then
                            return a.id < b.id
                        else
                            return a.sort < b.sort
                        end
                    end)
            end
        end
    end

    self.onUpdateBuyPanel:Fire()

    self:send11302()
end

function ShopManager:send11302()
    -- print("发送11302")
    Connection.Instance:send(11302, {})
end

function ShopManager:on11302(data)
    -- print("接收11302")

    local model = self.model
    local roleData = RoleManager.Instance.RoleData
    model.hasBuyList = {}

    for k,v in pairs(data.buy_info) do
        if v.num ~= nil then
            model.hasBuyList[v.id] = v.num
        end
    end

    local lastTime = PlayerPrefs.GetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, self.TTimeLimit, 1, 2))
    local thisDay = math.ceil((BaseUtils.BASE_TIME + 1) / 86400) - 4

    if lastTime == nil then
        self.redPoint[1][2] = true
    else
        local lastDay = math.ceil((lastTime + 1) / 86400) - 4
        local thisMonday = math.floor(thisDay / 7) * 7 + 1

        if lastDay < thisMonday and thisMonday <= thisDay then
            self.redPoint[1][2] = true
        else
            self.redPoint[1][2] = false
        end
    end

    -- self.redPoint[1][2] = self.redPoint[1][2] and true

    -- self:OnCheckCharactor()
    self.onUpdateBuyPanel:Fire()
    self.onUpdateRedPoint:Fire()

    -- if model.shopWin ~= nil then
    --     -- model.shopWin:ReloadBuyPanel()
    --     for i=1,model.shopWin.pageTotalNum do
    --         if model.shopWin.hasInitPage[i] == true then
    --             model.shopWin:InitDataPanel(model.currentMain, model.currentSub, i)
    --         end
    --     end
    --     model.shopWin:UpdateSelection(model.selectedInfo)
    --     if model.selectItem ~= nil then
    --         model.selectItem.transform:Find("Select").gameObject:SetActive(true)
    --     end

    --     model.shopWin:CheckRedPoint()
    -- end
end

function ShopManager:send11303(id, num)
    -- print("发送11303 " .. tostring(id) .. " " .. tostring(num))
    Connection.Instance:send(11303,{["id"] = id, ["num"] = num})
end

function ShopManager:on11303(data)
    local model = self.model
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        -- 提示购买成功
        -- print("购买成功")
        self.model:CloseQuickBuyPanel()
    else
        -- 提示购买失败
            -- NoticeManager.Instance:FloatTipsByString(data.msg)
            --      local dataN = NoticeConfirmData.New()
            -- dataN.type = ConfirmData.Style.Sure
            -- dataN.content = TI18N("当天充值<color='#ffff00'>任意金额</color>可<color='#ffff00'>额外</color>获得一次奖励")
            -- dataN.sureLabel = TI18N("立即充值")
            -- -- data.cancelLabel = self.buyBtnString
            -- dataN.sureCallback = function()
            -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
           -- end
           --  dataN.showClose = 1
           --  dataN.blueSure = false
           --  dataN.greenCancel = true
           --  dataN.cancelCallback = sure
           --  NoticeManager.Instance:ConfirmTips(dataN)
        -- print("购买失败，"..data.msg)
    end
    if model.selectObj ~= nil and not BaseUtils.isnull(model.selectObj) then
        model.selectObj:SetActive(true)
    end

    self.onUpdateUnfreeze:Fire()

    EventMgr.Instance:Fire(event_name.shop_buy_result, data.result)
end

-- 请求神秘商店数据
function ShopManager:send13900()
  -- print("发送13900")
    Connection.Instance:send(13900, {})
end

-- 获取神秘商店数据
function ShopManager:on13900(data)
    -- if Application.platform == RuntimePlatform.WindowsEditor then
    --     BaseUtils.dump(data, "接收13900")
    -- end

    local model = self.model
    model.last_view = data.last_view
    model.next_time = data.next_time

    model.datalist[1][3] = {}
    local datalist = model.datalist[1][3]
    self.mysteryRefreshTime = data.next_time
    for i=1,#data.items do
        datalist[i] = {}
        datalist[i].tab = 1
        datalist[i].tab2 = 3
        datalist[i].id = data.items[i].idx
        datalist[i].base_id = data.items[i].id
        datalist[i].num = data.items[i].num
        datalist[i].price = data.items[i].val
        datalist[i].label = 0
        datalist[i].flag = data.items[i].flag
        datalist[i].asset_type = data.items[i].type
        datalist[i].limit_role = 1
    end

    model.pageNum[1][3] = math.ceil((#model.datalist[1][3]) / 8)

    if model.last_view == model.next_time then
        self.redPoint[1][3] = false
    elseif RoleManager.Instance.RoleData.lev >= 40 then
        self.redPoint[1][3] = true
    end

    model.mysteryRefresh = data.refresh
    model.mysteryRefreshed = data.refreshed

    self.onUpdateBuyPanel:Fire()
    self.onUpdateRedPoint:Fire()

    -- BaseUtils.dump(datalist, "<color=#FF0000>shopdata[1][3]</color>")

    -- if model.shopWin ~= nil then
    --     model.shopWin:ReloadBuyPanel()
    -- end
end

function ShopManager:send13901(idx)
    -- print("发送13901 "..idx)
    Connection.Instance:send(13901, {idx = idx})
end

function ShopManager:on13901(data)
    -- print("接收13901 "..data.result)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if self.model.shopWin ~= nil then
        if self.model.shopWin.frozen ~= nil then
            self.model.shopWin.frozen:Release()
        end
    end

    self.onUpdateUnfreeze:Fire()
end

function ShopManager:send13902()
    -- print("发送13902")
    Connection.Instance:send(13902, {})
end

function ShopManager:on13902(data)
    -- print("接收13902 "..data.last_view)
end

function ShopManager:on11400(data)
end

function ShopManager:on10607(data)

end

function ShopManager:RequestData()
    local model = self.model
    model.mysteryRefresh = 0
    model.mysteryRefreshed = 0

    model.datalist[1][1] = {}
    model.datalist[1][2] = {}
    model.datalist[1][4] = {}
    model.datalist[2] = {}

    self:send11301(1)
    self:send11301(2)
    if RoleManager.Instance.RoleData.lev >= self.model.dataTypeList[1].subList[3].lev then
        self:send13900()
    end
    self:send14019()
    self:send9937()

    if BaseUtils.IsNewIosVest() then -- 新马甲包计费点从协议获取
        self:send9957(BaseUtils.GetGameName())        
    end
end

function ShopManager:CheckForMainUIRedPoint()
    local red = false
    for k,v in pairs(self.redPoint) do
        for k1, v1 in pairs(v) do
            red = red or v1
        end
    end
    -- BaseUtils.dump(red, "<color=#FF0000>----------------------------------</color>")
    local lev = RoleManager.Instance.RoleData.lev
    if lev >= 20 and MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(6, red)
    end
end

function ShopManager:OnCheckCharactor()
    local roleData = RoleManager.Instance.RoleData
    if self.character == nil or self.character ~= roleData.character then
        self.character = roleData.character
        if self.character ~= nil and self.character >= 1000 then
            self.redPoint[2][2] = true
            self.specialRed[2][2] = true
        else
            self.redPoint[2][2] = false
        end
        self.onUpdateRedPoint:Fire()
        return
    end
end

function ShopManager:send14019()
    Connection.Instance:send(14019, {})
end

function ShopManager:on14019(data)
    local model = self.model
    -- BaseUtils.dump(data, "接收14019")
    if data.open_time ~= nil then
        model.rechargeLog = {open_time = data.open_time}
    end
    if data.charged ~= nil and #data.charged > 0 then
        for k,v in pairs(data.charged) do
            model.rechargeLog[v.gold] = v.time
        end
    end

    CampaignManager.Instance:Send14000()
    self.onUpdateRecharge:Fire()
end

function ShopManager:OpenRechargeExplain(args)
    self.model:OpenRechargeExplain(args)
end

function ShopManager:send13903()
    -- print("发送13903")
    Connection.Instance:send(13903, {})
end

function ShopManager:on13903(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        -- BaseUtils.dump(data, "接收13903")
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.onUpdateUnfreeze:Fire()
end

function ShopManager:send9937()
    Connection.Instance:send(9937, {})
end

function ShopManager:on9937(data)
    local model = self.model
    model.rechargeLogRed = {}
    for i,v in ipairs(data.golds) do
        model.rechargeLogRed[v.gold] = true
    end
    self.onUpdateRecharge:Fire()
    self.onUpdateRebateReward:Fire()
end

function ShopManager:send9953()
    Connection.Instance:send(9953, {})
end

function ShopManager:on9953(data)
    local model = self.model
    model.productId_IOS = data.label
end


function ShopManager:send9956()
    Connection.Instance:send(9956, {})
    print("send9956")
end

function ShopManager:on9956(data)
    if data ~= nil then 
        self.openThreeCharge = (data.flag == 1) 
        self.onUpdateProgress:Fire(data) 
    end
end

function ShopManager:send9957(game_name)
    Connection.Instance:send(9957, { game_name = game_name })
end

function ShopManager:on9957(data)
    if IS_DEBUG then
        BaseUtils.dump(data, "on9957")
    end
    if data.recharge_list ~= nil then
        -- self.model.iosVestRechargeData = data.recharge_list
        self.model.iosVestRechargeData = {}
        for i, v in ipairs(data.recharge_list) do
            self.model.iosVestRechargeData[v.tag] = v
        end
    end
end

function ShopManager:InitData()
    -- self.dataList = {}
    -- for k,v in pairs(DataCampaign.data_list) do
    --     if v.name == "元旦狂欢" then
    --         self.dataList[v.group_index] = v
    --     end
    -- end

    -- table.sort(self.dataList,function(a,b)
    --     if a.group_index ~= b.group_index then
    --         return a.group_index < b.group_index
    --     else
    --         return false
    --     end
    -- end)
end

function ShopManager:GetDataList(cond_type)
    self.dataList = {}
    --凡是开出的cond_Type = 24 的秋日活动都会加入该列表
    local RebateRewardData = CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.RebateReward)

    --容错，加入其它条目类型
    if cond_type ~= nil then
        RebateRewardData = CampaignManager.Instance.model:GetIdsByType(cond_type)
    end

    if next(RebateRewardData) ~= nil then
        for k,v in pairs(RebateRewardData) do
            local RightData = DataCampaign.data_list[v]
            if RightData ~= nil then
                self.dataList[RightData.group_index] = RightData
            end
        end

        table.sort(self.dataList,function(a,b)
            if a.group_index ~= b.group_index then
                return a.group_index < b.group_index
            else
                return false
            end
        end)
    end

    return self.dataList
end

function ShopManager:RequestInitData()
    -- if Application.platform == RuntimePlatform.IPhonePlayer then
        self:send9953()
    -- end
end

function ShopManager:ReplaceProductId(productId)
    if Application.platform == RuntimePlatform.IPhonePlayer then
        if self.model.productId_IOS == nil then
            return productId
        else
            local iosList = DataRecharge.data_ios
            if BaseUtils.IsNewIosVest() then -- 新马甲包计费点从协议获取
                iosList = self.model.iosVestRechargeData 
            end

            local rechargeData = iosList[productId]
            local rechargeData2 = iosList[self.model.productId_IOS]
            if rechargeData ~= nil and rechargeData2 ~= nil and rechargeData.game_name == rechargeData2.game_name and rechargeData.rmb == rechargeData2.rmb then
                return self.model.productId_IOS
            else
                return productId
            end
        end
    else
        return productId
    end
end
