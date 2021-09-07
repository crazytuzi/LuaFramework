-- @author xhs(中秋充值礼包)
-- @date 2017年9月20日
RechargePackageManager = RechargePackageManager or BaseClass(BaseManager)

function RechargePackageManager:__init()
    if RechargePackageManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    RechargePackageManager.Instance = self

    self.model = RechargePackageModel.New()

    self:InitHandler()
    self.datalist = {}
    self.onRecharge = {}
    self.onRecharge[1] = EventLib.New()
    self.onRecharge[2] = EventLib.New()
    self.onRecharge[3] = EventLib.New()
    self.onChangeDay = EventLib.New()
    self.onUpdateRed = EventLib.New()
    -- self.canRecharge = false
    --self.onUpdateRed:AddListener(function() self:CheckRedPoint() end)
end

function RechargePackageManager:RequestInitData()
    self:Send17889()
    self:Send17888(1)
    self:Send17888(2)
    self:Send17888(3)
    self.onUpdateRed:Fire()
end


function RechargePackageManager:InitHandler()
    self:AddNetHandler(17888, self.On17888)
    self:AddNetHandler(17889, self.On17889)
end

function RechargePackageManager:__delete()

end

function RechargePackageManager:Send17888(index)
    -- print("发送协议17888================================")
    Connection.Instance:send(17888, {days = index})
end

function RechargePackageManager:On17888(data)
    -- print("收到协议17888================================")
    -- BaseUtils.dump(data,"接收协议17888==========================")
    self.datalist[data.days] = data
    self.onRecharge[data.days]:Fire()
    self.onUpdateRed:Fire()
end


function RechargePackageManager:Send17889()
    -- print("发送协议17889================================")
    Connection.Instance:send(17889, {})
end

function RechargePackageManager:On17889(data)
    -- print("收到协议17889================================")
    self.curdays =  data.curdays
    self.onChangeDay:Fire(self.curdays)
    self.onUpdateRed:Fire()
end

function RechargePackageManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

-- function RechargePackageManager:CheckRedPoint()
--     for i=1,3 do
--         local data = self.datalist[i]
--         if data ~= nil then
--             if data.days > self.curdays then

--             elseif data.max_times - data.times > 0 then
--                 self.canRecharge = true
--                 return true
--             end
--         end
--     end
--     self.canRecharge = false
-- end





