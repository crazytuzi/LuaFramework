-- region *.lua
-- Date jia 2017-4-25
-- endregion 套娃 manager
DollsRandomManager = DollsRandomManager or BaseClass(BaseManager)
function DollsRandomManager:__init()
    if DollsRandomManager.Instance ~= nil then
        Log.Error("不能重复实例化")
        return
    end
    DollsRandomManager.Instance = self
    self.model = DollsRandomModel.New()
    self.DollsList = { }
    self.isRefresh = true
    -- 打开的套娃是否有精灵套娃
    self.isAdvDolls = false
    self.CurLuckey = 0
    self.MaxLuckey = 100
    self.FreeTimes = 0
    self.isOpening = false

    self.onRewardlistUpdate = EventLib.New()
    self:InitHandler()
end

function DollsRandomManager:__delete(args)
    DollsRandomManager.Instance = nil
    if self.model ~= nil then
        self.model:DeleteMe()
    end
    self.model = nil
    self:RemoveNetHandler(17838, self.tmp17838)
    self:RemoveNetHandler(17839, self.tmp17839)
    self:RemoveNetHandler(17840, self.tmp17840)
end

function DollsRandomManager:InitHandler()
    self.tmp17838 = self:AddNetHandler(17838, self.On17838)
    self.tmp17839 = self:AddNetHandler(17839, self.On17839)
    self.tmp17840 = self:AddNetHandler(17840, self.On17840)

    self:AddNetHandler(20459, self.on20459)


end

function DollsRandomManager:OpenWindow(args)
    self.model:OpenWindow(args)
end
-- 请求套娃信息
function DollsRandomManager:RequestDollsData()
    local data = { }
    Connection.Instance:send(17838,data)
end

function DollsRandomManager:On17838(data)
    self.CurLuckey = data.lucky
    self.FreeTimes = data.free_times
    self.DollsList = { }
    if next(data.dolls) ~= nil then
        for _, doll in ipairs(data.dolls) do
            self.DollsList[doll.pos] = doll
        end
    end
    EventMgr.Instance:Fire(event_name.dolls_data_update)
end

-- 开启套娃
function DollsRandomManager:OpenDolls(type, pos)
    if self.isOpening then
        return
    end
    self.isAdvDolls = false
    local data = { type = type, pos = pos }
    if pos > 0 then
        self.isAdvDolls = self.DollsList[pos].type == 2
    else
        for _, dolls in pairs(self.DollsList) do
            if dolls.open == 0 and dolls.type == 2 then
                self.isAdvDolls = true
                break
            end
        end
    end
    self:Send(17839, data)
end

function DollsRandomManager:On17839(data)
    EventMgr.Instance:Fire(event_name.dolls_open_back, data)
end

-- 刷新套娃
function DollsRandomManager:RefreshDolls()
    self.isRefresh = true
    local data = { }
    self:Send(17840, data)
end

function DollsRandomManager:On17840(data)
    if data.err_code == 1 then
        EventMgr.Instance:Fire(dolls_open_back, data)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function DollsRandomManager:send20459()
    print("<color='#ff0000'>send20459</color>")
    Connection.Instance:send(20459, {})
end

function DollsRandomManager:on20459(data)
    BaseUtils.dump(data, "<color='#ff0000'>on20459</color>")
    self.model.AllTimes = data.now_times
    self.model.rewardsList = data.add_list
    self.model.lastRewardList = data.last_reward
    self.model:ResetRewardList()
    self.onRewardlistUpdate:Fire()
end