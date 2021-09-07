-- ----------------------------------------------------------
-- Manager - 未命名宝藏 -- 又名鸿福宝箱 （天地秘藏  远古宝库    星河宝箱    神迹宝库    天运宝箱    混沌秘宝    福运宝箱）
-- ljh 20161216
-- ----------------------------------------------------------
NotNamedTreasureManager = NotNamedTreasureManager or BaseClass(BaseManager)

function NotNamedTreasureManager:__init()
    if NotNamedTreasureManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	NotNamedTreasureManager.Instance = self

    self.model = NotNamedTreasureModel.New()

    self:InitHandler()

    self.OnUpdateList = EventLib.New()
end

function NotNamedTreasureManager:RequestInitData()
	self.model:InitData()

    self:Send18200()
end

function NotNamedTreasureManager:__delete()
    self.OnUpdateList:DeleteMe()
    self.OnUpdateList = nil
end

function NotNamedTreasureManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(18200, self.On18200)
    self:AddNetHandler(18201, self.On18201)
    self:AddNetHandler(18202, self.On18202)
    self:AddNetHandler(18203, self.On18203)
end

function NotNamedTreasureManager:Send18200()
    Connection.Instance:send(18200, { })
end

function NotNamedTreasureManager:On18200(data)
    self.model.gold_times = data.gold_times
    self.model.silver_times = data.silver_times
    self.OnUpdateList:Fire()
end

function NotNamedTreasureManager:Send18201(uint_id)
    Connection.Instance:send(18201, { uint_id = uint_id })
end

function NotNamedTreasureManager:On18201(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.OnUpdateList:Fire(data.item_type_id)
    end
end

function NotNamedTreasureManager:Send18202()
    Connection.Instance:send(18202, { })
end

function NotNamedTreasureManager:On18202(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NotNamedTreasureManager:Send18203(key_base_id)
    Connection.Instance:send(18203, { key_base_id = key_base_id })
end

function NotNamedTreasureManager:On18203(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        LuaTimer.Add(500, function() self.model:FindElement() end)
    end
end
