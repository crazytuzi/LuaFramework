-- 活动通用匹配功能
--hzf

MatchManager = MatchManager or BaseClass(BaseManager)

function MatchManager:__init()
    if MatchManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    MatchManager.Instance = self
    self.model = SnowBallModel.New(self)
    self.status = 0
    self.currid = 0
    self.matchResult = nil
    self.timesData = {}
    self:InitHandler()
    self.IconDic = {}
    self.statusList = {}
end

function MatchManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function MatchManager:InitHandler()
    self:AddNetHandler(18300, self.On18300)
    self:AddNetHandler(18301, self.On18301)
    self:AddNetHandler(18302, self.On18302)
    self:AddNetHandler(18303, self.On18303)
    self:AddNetHandler(18304, self.On18304)
    self:AddNetHandler(18305, self.On18305)
    self:AddNetHandler(18306, self.On18306)
    self:AddNetHandler(18307, self.On18307)
end

function MatchManager:ReqOnReConnect()
    self.IconDic = {}

    self:Require18300()
    self:Require18306(1000)
end

--当前匹配状态
function MatchManager:Require18300()
    Connection.Instance:send(18300,{})
end

function MatchManager:On18300(data)
    BaseUtils.dump(data, "18300")
    self.status = data.status
    self.currid = data.id
    EventMgr.Instance:Fire(event_name.match_status_change)
end

-- 进入某个大厅
function MatchManager:Require18301(id)
    Connection.Instance:send(18301,{id = id})
end

function MatchManager:On18301(data)
    BaseUtils.dump(data, "18301")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出匹配大厅
function MatchManager:Require18302()
    Connection.Instance:send(18302,{})
end

function MatchManager:On18302(data)
    BaseUtils.dump(data, "18302")
    self.currid = 0
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 进行匹配
-- 请求进行匹配
function MatchManager:Require18303()
    Connection.Instance:send(18303,{})
end

function MatchManager:On18303(data)
    BaseUtils.dump(data, "18303")
    -- if data.result == 1 then
    --     self.status = MatchStatus.Matching
    -- end
    -- EventMgr.Instance:Fire(event_name.match_status_change)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 取消匹配
function MatchManager:Require18304()
    Connection.Instance:send(18304,{})
end

function MatchManager:On18304(data)
    -- BaseUtils.dump(data, "18304")
    -- if data.result == 1 then
    --     self.status = MatchStatus.Normal
    -- end
    -- EventMgr.Instance:Fire(event_name.match_status_change)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 匹配出结果
function MatchManager:Require18305()
    Connection.Instance:send(18305,{})
end

function MatchManager:On18305(data)
    BaseUtils.dump(data, "18305")
    self.matchResult = data
    NoticeManager.Instance:FloatTipsByString(data.msg)
    EventMgr.Instance:Fire(event_name.match_has_result)
    NoticeManager.Instance:FloatTipsByString(TI18N("匹配成功，请准备作战！"))
end


-- 退出匹配大厅
function MatchManager:Require18306(id)
    Connection.Instance:send(18306,{id = id})
end

function MatchManager:On18306(data)
    -- BaseUtils.dump(data, "18306")
    self.statusList[data.id] = data.status
    if RoleManager.Instance.RoleData.lev < 30 then
        return
    end

    StarParkManager.Instance.agendaTab[2101] = nil
    if data.id == 1000 then
        local cfg_data = DataSystem.data_daily_icon[121]
        if data.status == 1 then
            StarParkManager.Instance.agendaTab[2101] = {}
            StarParkManager.Instance.agendaTab[2101].text = TI18N("准备中")
            StarParkManager.Instance.agendaTab[2101].time = data.timeout + Time.time
            StarParkManager.Instance.agendaTab[2101].timeoutCallBack = function() self:Require18306(data.id) end
        elseif data.status == 2 then
            StarParkManager.Instance.agendaTab[2101] = {}
            StarParkManager.Instance.agendaTab[2101].time = data.timeout + Time.time
            StarParkManager.Instance.agendaTab[2101].timeoutCallBack = function()
                if self.IconDic[data.id] ~= nil then
                    MainUIManager.Instance:DelAtiveIcon(cfg_data.id)
                    self.IconDic[data.id] = nil
                end
                self:Require18306(data.id)
            end

            if RoleManager.Instance.RoleData.lev >= 30 then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("<color='#ffff00'>雪球大战</color>活动正在进行中，是否前往参加？")
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.cancelSecond = 180
                data.sureCallback = function()
                    self:Require18301(1000)
                end
                NoticeManager.Instance:ActiveConfirmTips(data)
            end
        end
    end

    StarParkManager.Instance:ShowIcon()
end

-- 某个大厅剩余次数
function MatchManager:Require18307(id)
    Connection.Instance:send(18307,{id = id})
end

function MatchManager:On18307(data)
    self.timesData[data.id] = data.count
    EventMgr.Instance:Fire(event_name.match_times_change)

    -- if data.id == 1000 then
    --     if MatchManager.Instance.timesData[1000] == 5 then
                -- if self.IconDic[1000] ~= nil then
                --     MainUIManager.Instance:DelAtiveIcon(121)
                --     self.IconDic[1000] = nil
                -- end
    --     end
    -- end
end