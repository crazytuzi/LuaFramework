FestivalManager = FestivalManager or BaseClass(BaseManager)

function FestivalManager:__init()
    if FestivalManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    FestivalManager.Instance = self
    self.model = FestivalModel.New()

    self:InitHandler()
end

function FestivalManager:__delete()
end

function FestivalManager:InitHandler()
    self:AddNetHandler(10228, self.on10228)
end

function FestivalManager:ReqOnConnect()
    self.isFestivalGot = false
    self.isTodayFestival = false
    self:send10228()
end

function FestivalManager:send10228()
    Connection.Instance:send(10228, {})
end

function FestivalManager:on10228(data)
    self.isFestivalGot = (data.result == 0)
    BibleManager.Instance.redPointDic[1][11] = (self.isFestivalGot ~= true)
    self.model:CheckFestival()
    ImproveManager.Instance:OnStatusChange(true)
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

