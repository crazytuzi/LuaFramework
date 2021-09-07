-- ---------------------------
-- 一闷夺宝
-- hosr
-- ---------------------------
LotteryManager = LotteryManager or BaseClass(BaseManager)

function LotteryManager:__init()
    if LotteryManager.Instance then
        return
    end
    LotteryManager.Instance = self

    self.model = LotteryModel.New()

    self:InitHandler()

    -- 上次更新时间戳
    self.lastTimeTab = {
        [LotteryEumn.Type.Diamond] = 0
    }

    -- 根据类型存放的列表数据
    self.typeTab = {
        [LotteryEumn.Type.Diamond] = {},
        [LotteryEumn.Type.Gold] = {},
        [LotteryEumn.Type.Silver] = {},
    }

    -- 根据期号存储
    self.idxTab = {}
    -- 历史记录
    self.historyTab = {}
    -- 已揭晓列表
    self.overTab = {}
    -- 我参与的次数
    self.myTimeTab = {}
    -- 记录选项卡里面的历史记录
    self.recordHistoryTab = {}
    -- 关注物品的id列表
    self.focusList = {}
    -- 累计参与人次
    self.totalJoinMemNum = 0
    -- 开始结束时间
    self.startTime = 0
    self.endTime = 0
    -- 开启时间段
    self.timeList = nil
end

function LotteryManager:InitHandler()
    self:AddNetHandler(16900, self.On16900)
    self:AddNetHandler(16901, self.On16901)
    self:AddNetHandler(16902, self.On16902)
    self:AddNetHandler(16903, self.On16903)
    self:AddNetHandler(16904, self.On16904)
    self:AddNetHandler(16906, self.On16906)
    self:AddNetHandler(16907, self.On16907)
    self:AddNetHandler(16908, self.On16908)
end

function LotteryManager:RequestInitData()
    -- self.idxTab = {}
    -- self.historyTab = {}
    -- self.recordHistoryTab = {}
    -- self.overTab = {}
    -- self.myTimeTab = {}
    -- self.startTime = 0
    -- self.endTime = 0
    if self.activeIconData ~= nil then
        MainUIManager.Instance:DelAtiveIcon(308)
        self.activeIconData = nil
    end
    self:Send16904()
end

-- 界面请求对应数据
function LotteryManager:RefreshData(index)
    if index == 1 then
        if BaseUtils.BASE_TIME - self.lastTimeTab[LotteryEumn.Type.Diamond] > 10 then
            self:Send16900(0, self.lastTimeTab[LotteryEumn.Type.Diamond])
        end
    end
end

function LotteryManager:GetListData(index, filterType)
    if filterType == 0 then
        return self.typeTab[LotteryEumn.Type.Diamond]
    else
        local list = self.typeTab[LotteryEumn.Type.Diamond]
        local resultList = {}
        for i = 1, #list do
            local data = list[i]
            if data.sort == filterType then
                table.insert(resultList, data)
            end
        end
        return resultList
    end
end

-- 获取自己参与
function LotteryManager:GetMyJoin()
    local list = {}
    -- -- print("==============================")
    for k,item in pairs(self.idxTab) do
        if item.times_my > 0 and item.state <= LotteryEumn.State.Opening then
            for k, v in pairs(self.typeTab[LotteryEumn.Type.Diamond]) do
                if v.idx == item.idx then
                    table.insert(list, item)
                    break
                end
            end
        end
    end
    return list
end

-- 或区域自己已揭晓
function  LotteryManager:GetMyGet()
    return self.overTab
end

-- 揭晓请求数据
function LotteryManager:RequestNew(time)
    self:Send16900(0, time)
    self:Send16901()
end

-- 请求住界面列表数据
function LotteryManager:Send16900(type, time)
    -- print('---------------------------发送16900')
    self:Send(16900, {type = type, time = time})
end

-- 请求已揭晓页面
function LotteryManager:Send16901(_page_now)
    -- -- print("----------------请求16901")
    if _page_now == nil then
        self:Send(16901, {page_now = 1})
    else
        self:Send(16901, {page_now = _page_now})
    end
end

--请求购买
function LotteryManager:Send16902(idx, item_idx, count, all)
    -- print('---------------------发送16902')
    if all == nil then
        self:Send(16902, {idx = idx, item_idx = item_idx, count = count, all = 0})
    else
        self:Send(16902, {idx = idx, item_idx = item_idx, count = count, all = all})
    end
end

-- 查看详情
function LotteryManager:Send16903(idx)
-- print('---------------------发送16903')
    self:Send(16903, {idx = idx})
end

-- 请求活动时间
function LotteryManager:Send16904()
-- print('---------------------发送16904')
    self:Send(16904, {})
end

-- 分页请求我的号码
function LotteryManager:Send16906(_idx, _page_now)
    -- -- print("--------------------发送16906")
    self:Send(16906, {idx = _idx, page_now = _page_now})
end

-- 新物品上架or更新
function LotteryManager:Send16907(_page_now)
    self:Send(16907, {page_now = _page_now})
end

-- 关注物品
function LotteryManager:Send16908(idx)
    self:Send(16908, {idx = idx})
end

--请求界面
function LotteryManager:On16900(dat)
    -- print('-------------------------收到16900')
    -- BaseUtils.dump(dat)
    if dat.times_all > 0 then
        self.totalJoinMemNum = dat.times_all
    end
    local lastTime = self.lastTimeTab[dat.type]
    self.timeList = dat.time_list
    if dat.time > lastTime then
        if #dat.focus_list ~= 0 then
            self.focusList = {}
            for i=1, #dat.focus_list do
                self.focusList[dat.focus_list[i].focus_id] = dat.focus_list[i]
            end
        end

        local myTimeTab = {}
        for i,v in ipairs(dat.my_list) do
            myTimeTab[v.idx] = v.times_my
        end

        self.lastTimeTab[dat.type] = dat.time
        self.typeTab[dat.type] = {}
        for i,v in ipairs(dat.lottery) do
            local itemData = LotteryItemData.New()
            itemData:SetData(v)

            if myTimeTab[v.idx] ~= nil then
                itemData.times_my = myTimeTab[v.idx]
            end

            if self.focusList[v.item_idx] ~= nil then
                itemData.focus = 1
            end

            table.insert(self.typeTab[dat.type], itemData)
            self.idxTab[itemData.idx] = itemData
        end

        if self.historyTab == nil then
            self.historyTab = {}
        end
        for i,v in ipairs(dat.history_list) do
            local hisData = LotteryHistoryData.New()
            hisData:SetData(v)

            if myTimeTab[v.idx] ~= nil then
                hisData.times_my = myTimeTab[v.idx]
            end

            if self.focusList[v.item_idx] ~= nil then
                hisData.focus = 1
            end

            local hasIn = false
            for k, v in pairs(self.historyTab) do
                if v.idx == hisData.idx then
                    hasIn = true
                    break
                end
            end
            if hasIn == false then
                table.insert(self.historyTab, hisData)
            end
        end

        EventMgr.Instance:Fire(event_name.lottery_main_update)
    end
end

--分页请求已揭晓页面
function LotteryManager:On16901(dat)
    -- -- print("----------------收到16901")
    -- BaseUtils.dump(dat)
    local myTimeTab = {}
    for i,v in ipairs(dat.my_list) do
        myTimeTab[v.idx] = v.times_my
    end

    self.overTab = {}
    for i,v in ipairs(dat.lottery) do
        local data = LotteryItemData.New()
        data:SetData(v)
        if myTimeTab[v.idx] ~= nil then
            data.times_my = myTimeTab[v.idx]
        end
        table.insert(self.overTab, data)
    end
    table.sort(self.overTab, function(a,b) return tonumber(a.idx) > tonumber(b.idx) end)
    EventMgr.Instance:Fire(event_name.lottery_over_update)
end

--购买返回
function LotteryManager:On16902(dat)
    -- print('---------------------收到16902')
    -- BaseUtils.dump(dat)
    if dat.msg == 0 then
        local item = self.idxTab[dat.idx]
        if item ~= nil then
            item:SetData(dat)
        end
        EventMgr.Instance:Fire(event_name.lottery_main_update)
    else
        --不足次数
        local leftCount = dat.times_sum - dat.times_now
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self:Send16902(dat.idx, dat.item_idx, leftCount, 1)
        end
        data.content = string.format("%s<color='#ffff00'>%s</color>%s", TI18N("是否"), TI18N("包下剩余"), TI18N("所需人次"))

        NoticeManager.Instance:ConfirmTips(data)
    end
end

--查看详情返回
function LotteryManager:On16903(dat)
    -- -- print("---------------------收到16903")
    -- BaseUtils.dump(dat, "169033333333333333333333333")
    self.model:OpenDetail(dat)
end

--请求时间
function LotteryManager:On16904(dat)
    -- -- print("-----------------收到16904")
    -- BaseUtils.dump(dat)

    self.startTime = dat.time_start
    self.endTime = dat.time_end
    if dat.state == 0 then
        if self.activeIconData ~= nil then
            MainUIManager.Instance:DelAtiveIcon3(308)
            self.activeIconData = nil
        end
        -- self.model:CloseMain()
        self.model:CloseJoinPanel()
    else
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[308]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        -- self.activeIconData.timestamp = (dat.time_end - BaseUtils.BASE_TIME) + Time.time
        self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.lottery_main) end
        MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)

        -- 获取初始数据
        self:Send16900(0, 0)
        if #self.overTab == 0 then
            self:Send16901()
        end
    end
end


function LotteryManager:On16906(dat)
    -- -- print("-----------------------收到16906")
    EventMgr.Instance:Fire(event_name.lottery_my_num_update, dat)
end

function LotteryManager:On16907(dat)
    -- -- print("-----------------------收到16907")
    -- BaseUtils.dump(dat)
    self.recordHistoryTab = {}
    for i,v in ipairs(dat.lottery) do
        local data = LotteryItemData.New()
        data:SetData(v)
        table.insert(self.recordHistoryTab, data)
    end
    table.sort(self.recordHistoryTab, function(a,b) return tonumber(a.idx) > tonumber(b.idx) end)
    EventMgr.Instance:Fire(event_name.lottery_over_update)
end

--关注物品
function LotteryManager:On16908(dat)
    -- -- print("----------------收到16908")
    -- BaseUtils.dump(dat)
    if dat.flag == 1 then
        self.focusList[dat.item_idx] = dat.item_idx
    else
        self.focusList[dat.item_idx] = nil
    end
    EventMgr.Instance:Fire(event_name.lottery_focus_update, dat.idx)

    NoticeManager.Instance:FloatTipsByString(TI18N(dat.msg))
end
