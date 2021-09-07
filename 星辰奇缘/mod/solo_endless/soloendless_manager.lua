-- 单人无尽挑战 manager
-- hzf
-- 2016年12月09日10:42:25

SoloEndlessManager  = SoloEndlessManager or BaseClass(BaseManager)

function SoloEndlessManager:__init()
    if SoloEndlessManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    SoloEndlessManager.Instance = self
    self.model = SoloEndlessModel.New()
    self.StatusData = {}
    -- EventMgr.Instance:AddListener(event_name.role_event_change, function(event,oldEvent)
    --     self:CheckEvent(event,oldEvent)
    -- end)
    -- EventMgr.Instance:AddListener(event_name.end_fight, function()
    --     self.currWave = 1
    -- end)
end

function SoloEndlessManager:InitHandler()
    self:AddNetHandler(18100, self.On18100)
    self:AddNetHandler(18101, self.On18101)
    self:AddNetHandler(18102, self.On18102)
    self:AddNetHandler(18103, self.On18103)
    self:AddNetHandler(18104, self.On18104)
    self:AddNetHandler(18105, self.On18105)
    self:AddNetHandler(18106, self.On18106)
    self:AddNetHandler(18107, self.On18107)
    self:AddNetHandler(18108, self.On18108)
    self:AddNetHandler(18109, self.On18109)
    self:AddNetHandler(18110, self.On18110)
    self:AddNetHandler(18113, self.On18113)
    self:AddNetHandler(18114, self.On18114)
    self:AddNetHandler(18116, self.On18116)

end

function SoloEndlessManager:ReqOnConnect()
    self:Require18100()

end

function SoloEndlessManager:Require18100()
    Connection.Instance:send(18100,{})
end


function SoloEndlessManager:On18100(data)
    print("on18100")
    -- BaseUtils.dump(data)
    self.StatusData = data
    self.model:OpenMainWindow()
end


function SoloEndlessManager:Require18101()
    Connection.Instance:send(18101,{})
end

function SoloEndlessManager:On18101(data)
    print("on18101")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18102()
    Connection.Instance:send(18102,{})
end

function SoloEndlessManager:On18102(data)
    print("on18102")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18103(rid, platform, zone_id)
    Connection.Instance:send(18103,{rid = rid, platform = platform, zone_id = zone_id})
end

function SoloEndlessManager:On18103(data)
    print("on18103")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18104()
    Connection.Instance:send(18104,{})
end

function SoloEndlessManager:On18104(data)
    print("on18104")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18105(rid, platform, zone_id, type)
    Connection.Instance:send(18105,{rid = rid, platform = platform, zone_id = zone_id, type = type})
end

function SoloEndlessManager:On18105(data)
    print("on18105")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18106()
    Connection.Instance:send(18106,{})
end

function SoloEndlessManager:On18106(data)
    print("on18106收到求助详细信息")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18107()
    Connection.Instance:send(18107,{})
end

function SoloEndlessManager:On18107(data)
    print("on18107波数信息")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18108()
    Connection.Instance:send(18108,{})
end

function SoloEndlessManager:On18108(data)
    print("on18108")
    self.rankData = data
    self.model:OpenRankPanel()
end


function SoloEndlessManager:Require18109()
    Connection.Instance:send(18109,{})
end

function SoloEndlessManager:On18109(data)
    print("on18109")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18110()
    Connection.Instance:send(18110,{})
end

function SoloEndlessManager:On18110(data)
    print("on18110")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18113()
    Connection.Instance:send(18113,{})
end

function SoloEndlessManager:On18113(data)
    print("on18113")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18114()
    Connection.Instance:send(18114,{})
end

function SoloEndlessManager:On18114(data)
    print("on18114")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function SoloEndlessManager:Require18116()
    Connection.Instance:send(18116,{})
end

function SoloEndlessManager:On18116(data)
    print("on18116")
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

------------------------------------

function SoloEndlessManager:CheckOpen()
    self.model:OpenMainWindow()
end
