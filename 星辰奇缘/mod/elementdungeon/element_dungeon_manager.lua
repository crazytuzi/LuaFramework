-- ----------------------------------------------------------
-- Manager - 元素副本
-- ljh 20161215
-- ----------------------------------------------------------
ElementDungeonManager = ElementDungeonManager or BaseClass(BaseManager)

function ElementDungeonManager:__init()
    if ElementDungeonManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	ElementDungeonManager.Instance = self

    self.model = ElementDungeonModel.New()

    self:InitHandler()

    self.OnUpdateList = EventLib.New()
end

function ElementDungeonManager:RequestInitData()
	self.model:InitData()

    self:Send10500()
end

function ElementDungeonManager:__delete()
    self.OnUpdateList:DeleteMe()
    self.OnUpdateList = nil
end

function ElementDungeonManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    -- self:AddNetHandler(10500, self.On10500)
end

function ElementDungeonManager:Send10500()
    Connection.Instance:send(10500, { })
end

function ElementDungeonManager:On10500(data)
    -- BaseUtils.dump(data,"ElementDungeonManager:On10500(data) === ")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10500(data)
end
