-- @author 黄耀聪
-- @date 2016年7月6日
-- 攻略

StrategyManager = StrategyManager or BaseClass(BaseManager)

function StrategyManager:__init()
    if StrategyManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    StrategyManager.Instance = self

    self.onChangeTab = EventLib.New()
    self.onUpdateContent = EventLib.New()
    self.onUpdateList = EventLib.New()
    self.onUpdateMyList = EventLib.New()

    self.orderType = {
        Default = 1,    --默认顺序
        Time = 2,       -- 时间排序
        TimeUp = 3,       -- 时间倒序
        Comment = 4,    -- 评论数
        Cool = 5,       -- 点赞数
    }

    self.myType = {
        All = 0,
        Collect = 2,
    }

    self.serverNameTab = {}

    self.model = StrategyModel.New()
    self.orderCmp = function(a,b) return a.order < b.order end

    self.brew = false

    self:InitHandler()
end

function StrategyManager:__delete()
end

function StrategyManager:InitHandler()
    self:AddNetHandler(16600, self.on16600)
    self:AddNetHandler(16602, self.on16602)
    self:AddNetHandler(16603, self.on16603)
    self:AddNetHandler(16604, self.on16604)
    self:AddNetHandler(16605, self.on16605)
    self:AddNetHandler(16606, self.on16606)
    self:AddNetHandler(16607, self.on16607)
    self:AddNetHandler(16608, self.on16608)
end

function StrategyManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

-- 请求我的攻略
function StrategyManager:send16600(order, type, page, len)
  -- print("发送16600")
    Connection.Instance:send(16600, {order_type = order, type = type, page = page, len = len})
end

function StrategyManager:on16600(data)
    --BaseUtils.dump(data, "接收16600")
    local model = self.model
    model.myOrderList[data.order][data.type][data.page] = data
    self.onUpdateMyList:Fire(data.order, data.type, data.page)
end

-- 上传攻略
function StrategyManager:send16602(type, title, content, local_id)
  -- print("发送16602")
    Connection.Instance:send(16602, {type = type, title = title, content = content, local_id = local_id})
end

function StrategyManager:on16602(data)
    --BaseUtils.dump(data, "接收16602")
    if data.result == 1 then
        self.model.draftTab[data.local_id] = nil
        self:SaveDraft()
        self.model:ClearMyList()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 请求攻略列表
function StrategyManager:send16603(order, type, page, count)
    local dat = {order_type = order, type = type, page = page, count = count}
    --BaseUtils.dump(dat, "发送16603")
    Connection.Instance:send(16603, dat)
end

function StrategyManager:on16603(data)
    --BaseUtils.dump(data, "接收16603")
    local model = self.model
    model.orderList[data.order][data.type][data.page] = data

    self.onUpdateList:Fire(data.order, data.type, data.page)
end

-- 请求攻略内容
function StrategyManager:send16604(title_id, type)
  -- print("发送16604")
    local dat = {title_id = title_id, type = type}
    --BaseUtils.dump(dat, "16604")
    Connection.Instance:send(16604, dat)
end

function StrategyManager:on16604(data)
    -- BaseUtils.dump(data, "接收16604")
    local model = self.model
    model.strategyTab[data.type][data.id] = data
    self.onUpdateContent:Fire(data.id)
end

-- 收藏攻略
function StrategyManager:send16605(title_id)
  -- print("发送16605")
    Connection.Instance:send(16605, {title_id = title_id})
end

function StrategyManager:on16605(data)
    local model = self.model
    --BaseUtils.dump(data, "接收16605")
    model:ClearMyList()
    if model.strategyTab[1][data.title_id] ~= nil then
        model.strategyTab[1][data.title_id].like = data.result
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.onUpdateContent:Fire(data.title_id)
end

-- 请求题目
function StrategyManager:send16606(title_id)
  -- print("发送16606")
    Connection.Instance:send(16606, {title_id = title_id})
end

function StrategyManager:on16606(data)
    local model = self.model
    -- BaseUtils.dump(data, "接收16606")
    model.questionsTab[data.title_id] = data
    -- NoticeManager.Instance:FloatTipsByString(data.msg)

    if #data.answer == 0 then
        return
    end
    self.model:OpenQuestionPanel(data.title_id)
end

-- 请求奖励
function StrategyManager:send16607(title_id)
  -- print("发送16607")
    Connection.Instance:send(16607, {title_id = title_id})
end

function StrategyManager:on16607(data)
    local model = self.model
    --BaseUtils.dump(data, "接收16607")
    if data.result == 1 then
        if model.strategyTab[1][data.title_id] ~= nil then
            model.strategyTab[1][data.title_id].reward = 1
            self.onUpdateContent:Fire(data.title_id)
        end
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function StrategyManager:InitData()
    self:ReadDraft()
    self.serverNameTab = {}
    for k,v in pairs(ServerConfig.servers) do
        self.serverNameTab[BaseUtils.Key(v.zone_id, v.platform)] = v.name
    end
end

function StrategyManager:SaveDraft()
    self.model:SaveDraft()
end

function StrategyManager:ReadDraft()
    self.model:ReadDraft()
end

function StrategyManager:send16608(title_id, type, title, content, local_id)
  -- print("发送16608")
    Connection.Instance:send(16608, {title_id = title_id, title = title, type = type, content = content, local_id = local_id})
end

function StrategyManager:on16608(data)
    --BaseUtils.dump(data, "接收16608")
    if data.result == 1 then
        self.model.draftTab[data.local_id] = nil
        self:SaveDraft()
        self.model:ClearMyList()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



