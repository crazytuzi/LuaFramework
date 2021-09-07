-- @author zyh(充值转盘)
-- @date 2017年9月8日
TurntabelRechargeManager = TurntabelRechargeManager or BaseClass(BaseManager)

function TurntabelRechargeManager:__init()
    if TurntabelRechargeManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    TurntabelRechargeManager.Instance = self

    self.model = TurntabelRechargeModel.New()

    self:InitHandler()
    self.onRefreshItem = EventLib.New()
    self.onGetBoxReward = EventLib.New()
    self.onStartRotation = EventLib.New()
    self.onShowRotation = EventLib.New()
    self.onUpdateRed = EventLib.New()

    self.totalItemList = nil
    self.rotationItemList = nil
    self.campId = 902
end

function TurntabelRechargeManager:RequestInitData()

    local baseTime = BaseUtils.BASE_TIME
    local timeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local beginTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    local distance = baseTime - beginTime
    local d = math.floor(distance/86400)

    if d >-1 and d <3 then
        TurntabelRechargeManager.Instance:Send17883(d + 1)
        self.chooseDay = d + 1
    end
    -- self:Send17883(d + 1)
end

function TurntabelRechargeManager:InitHandler()
    self:AddNetHandler(17883, self.On17883)
    self:AddNetHandler(17886, self.On17886)
    self:AddNetHandler(17884, self.On17884)
    self:AddNetHandler(17885, self.On17885)
end

function TurntabelRechargeManager:__delete()

end


function TurntabelRechargeManager:OpenWindow(args)
    self.model:OpenWindow(args)
end


function TurntabelRechargeManager:OpenWindow(args)
    self.model:OpenWindow(args)
end


function TurntabelRechargeManager:Send17883(index)
    -- print("发送协议17883================================" .. index)
    self:Send(17883,{days = index})
end

function TurntabelRechargeManager:On17883(data)
     -- BaseUtils.dump(data,"接收协议17883==========================")
    self.totalItemList = data
    self.regPoint = data.reg_point
    self.days = data.days
    self.rotationItemList = data.rd_reward
    self.boxRewardList = data.box_reward
    table.sort(self.rotationItemList,function(a,b)
       if a.index ~= b.index then
            return a.index < b.index
        else
            return false
        end
    end)
    table.sort(self.boxRewardList,function(a,b)
       if a.box_id ~= b.box_id then
            return a.box_id < b.box_id
        else
            return false
        end
    end)

    self.onRefreshItem:Fire()
    self.onUpdateRed:Fire()

end

function TurntabelRechargeManager:Send17884(d)
-- print("发送协议17884==================================")
    self:Send(17884, {days = d})
end


function TurntabelRechargeManager:On17884(data)
     -- BaseUtils.dump(data,"接收协议17884==========================")
    -- BaseUtils.dump(data, "On10430")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.onStartRotation:Fire(data.index)
    end
end
function TurntabelRechargeManager:Send17885(d)

    self:Send(17885, {days = d})
end


function TurntabelRechargeManager:On17885(data)
    -- BaseUtils.dump(data, "On10430")
         -- BaseUtils.dump(data,"接收协议17885==========================")

    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.onShowRotation:Fire(data.item_list)
    end
end
function TurntabelRechargeManager:Send17886(d,id)
    -- print("发送的天数" .. d)
    self:Send(17886, {days = d,box_id = id})
end


function TurntabelRechargeManager:On17886(data)
    -- BaseUtils.dump(data,"接收协议17886==========================")
    -- BaseUtils.dump(data, "On10430")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.onGetBoxReward:Fire(data.box_id)
    end
end

