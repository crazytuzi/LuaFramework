-- @author pwj
-- @date 2018年2月26日,星期一

ArborDayShakeManager = ArborDayShakeManager or BaseClass(BaseManager)

function ArborDayShakeManager:__init()
    if ArborDayShakeManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    ArborDayShakeManager.Instance = self
    self.model = ArborDayShakeModel.New()
    self:InitHandler()

    self.onDrawReturn = EventLib.New()
    self.onMsgEvent = EventLib.New()
end

function ArborDayShakeManager:__delete()
end

function ArborDayShakeManager:RequestInitData()
    --登录请求数据
    self:send20440()
end

function ArborDayShakeManager:InitHandler()
    self:AddNetHandler(20434, self.on20434)
    self:AddNetHandler(20435, self.on20435)
    self:AddNetHandler(20440, self.on20440)
end

function ArborDayShakeManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

--抽奖第一阶段
function ArborDayShakeManager:send20434(data)
    --print("------------发送20434协议----------")
    Connection.Instance:send(20434, {num = data})
end

function ArborDayShakeManager:on20434(data)
    --print("------------收到20434协议----------")
    BaseUtils.dump(data,"20434_data")
    --NoticeManager.Instance:FloatTipsByString("")
    local inidata = data
    if data.flag == 1 then
        self.model.returnRewardlist = { }
        for i,v in ipairs (data.result) do
            table.insert(self.model.returnRewardlist, v)
        end
        --BaseUtils.dump(self.model.returnRewardlist,"self.model.returnRewardlist")
        self.onDrawReturn:Fire(self.model.returnRewardlist)
    elseif data.flag == 0 then
        --self.onDrawReturn:Fire({0})
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--抽奖第二阶段
function ArborDayShakeManager:send20435()
    Connection.Instance:send(20435, {})
end
function ArborDayShakeManager:on20435(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
function ArborDayShakeManager:send20440()
    --print("<color='#c32dfa>------------发送20440协议----------</color>")
    Connection.Instance:send(20440, {})
end

function ArborDayShakeManager:on20440(data)
    --print("------------收到20440协议----------")
    --BaseUtils.dump(data,"收到20440协议")
    local msg = data
    self.model:GenerateNormalHistory(msg)
end

