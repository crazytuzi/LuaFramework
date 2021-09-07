-- @author 黄耀聪
-- @date 2016年7月22日

AuctionManager = AuctionManager or BaseClass(BaseManager)

function AuctionManager:__init()
    if AuctionManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    AuctionManager.Instance = self
    self.model = AuctionModel.New()

    self.onUpdateItem = EventLib.New()
    self.onUpdateMyItem = EventLib.New()

    self:InitHandler()
end

function AuctionManager:__delete()
end

function AuctionManager:InitHandler()
    self:AddNetHandler(16700, self.on16700)
    self:AddNetHandler(16701, self.on16701)
    self:AddNetHandler(16702, self.on16702)
    self:AddNetHandler(16703, self.on16703)
    self:AddNetHandler(16704, self.on16704)
    self:AddNetHandler(16705, self.on16705)
    self:AddNetHandler(16706, self.on16706)
    self:AddNetHandler(16707, self.on16707)
end

function AuctionManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

-- 请求拍卖系统节目
function AuctionManager:send16700()
  -- print("发送16700")
    Connection.Instance:send(16700, {})
end

function AuctionManager:on16700(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收16700")
    end
    local model = self.model
    model.datalist = {}
    for _,dat in ipairs(data.auction_list) do
        model.datalist[dat.idx] = {}
        local tab = model.datalist[dat.idx]
        for k,v in pairs(dat) do
            tab[k] = v
        end
    end
    self.onUpdateItem:Fire()
end

-- 请求我的竞拍
function AuctionManager:send16701()
  -- print("发送16701")
    Connection.Instance:send(16701, {})
end

function AuctionManager:on16701(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收16701")
    end
    local model = self.model
    model.mylist = {}
    for _,dat in ipairs(data.list) do
        model.mylist[dat.idx] = {}
        local tab = model.mylist[dat.idx]
        for k,v in pairs(dat) do
            tab[k] = v
        end
    end
    self.onUpdateMyItem:Fire()
end

-- 关注
function AuctionManager:send16702(idx)
  -- print("发送16702")
    Connection.Instance:send(16702, {idx = idx})
end

function AuctionManager:on16702(data)
    local model = self.model

    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收16703")
    end

    model.datalist = model.datalist or {}
    model.datalist[data.idx] = model.datalist[data.idx] or {}
    for k,v in pairs(data) do
        model.datalist[data.idx][k] = v
    end
    self.onUpdateItem:Fire(data.idx)

    if data.focus == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("已关注"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("已取消关注"))
    end
end

-- 下注
function AuctionManager:send16703(idx, gold_add, gold)
  -- print("发送16703")
    Connection.Instance:send(16703, {idx = idx, gold_add = gold_add, gold = gold})
end

function AuctionManager:on16703(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收16703")
    end
    local model = self.model
    model.datalist[data.idx] = model.datalist[data.idx] or {}
    local tab = model.datalist[data.idx]
    for k,v in pairs(data) do
        tab[k] = v
    end
    self.onUpdateItem:Fire(data.idx)
end

-- 自动下注
function AuctionManager:send16704(idx, gold_add, gold, gold_max)
  -- print("发送16704")
    Connection.Instance:send(16704, {idx = idx, gold_add = gold_add, gold = gold, gold_max = gold_max})
end

function AuctionManager:on16704(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收16704")
    end
    local model = self.model
    model.datalist[data.idx] = model.datalist[data.idx] or {}
    local tab = model.datalist[data.idx]
    for k,v in pairs(data) do
        tab[k] = v
    end
    self.onUpdateItem:Fire(data.idx)
end

-- 离开页面
function AuctionManager:send16705()
  -- print("发送16705")
    Connection.Instance:send(16705, {})
end

function AuctionManager:on16705(data)
    BaseUtils.dump(data, "接收16705")
end

-- 请求活动时间
function AuctionManager:send16706()
  -- print("发送16706")
    Connection.Instance:send(16706, {})
end

function AuctionManager:on16706(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "<color=#FFFF00>接收16706</color>")
    end
    self.model.timeList = data.time_list
    table.sort(self.model.timeList, function(a,b) return a.start_time < b.start_time end)
end

function AuctionManager:InitData()
    -- self:send16706()
end

function AuctionManager:send16707()
  -- print("发送16707")
    Connection.Instance:send(16707, {})
end

function AuctionManager:on16707(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收16707")
    end
    local model = self.model
    model.datalist = model.datalist or {}
    for _,dat in ipairs(data.item_list) do
        model.datalist[dat.idx] = model.datalist[dat.idx] or {}
        local tab = model.datalist[dat.idx]
        for k,v in pairs(dat) do
            tab[k] = v
        end
        self.onUpdateItem:Fire(dat.idx)
    end
end
