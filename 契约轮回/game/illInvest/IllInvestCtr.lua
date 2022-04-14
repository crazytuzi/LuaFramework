--- Created by Admin.
--- DateTime: 2019/12/4 11:39

require('game.illInvest.RequireIllInvest')

IllInvestCtr = IllInvestCtr or class("IllInvestCtr",BaseController)
local IllInvestCtr = IllInvestCtr

function IllInvestCtr:ctor()
    IllInvestCtr.Instance = self
    self.model = IllInvestModel.GetInstance()
    self.events = {}


    self:AddEvents()
    self:RegisterAllProtocal()
end

function IllInvestCtr:dctor()
    if self.crossday_delay_sche then
        GlobalSchedule:Stop(self.crossday_delay_sche)
        self.crossday_delay_sche = nil
    end

end

function IllInvestCtr:GetInstance()
    if not IllInvestCtr.Instance then
        IllInvestCtr.new()
    end
    return IllInvestCtr.Instance
end

function IllInvestCtr:RegisterAllProtocal(  )
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1145_actinvest_pb"
    self:RegisterProtocal(proto.ACTINVEST_INFO, self.HandleInvestInfo);
    self:RegisterProtocal(proto.ACTINVEST_BUY, self.HandleInvestBuyInfo);
    self:RegisterProtocal(proto.ACTINVEST_REWARD, self.HandleInvestRewardInfo);

end

function IllInvestCtr:AddEvents()
    local function callback(id)
        if self.model.is_Open then
            lua_panelMgr:GetPanelOrCreate(IllInvestPanel):Open(id)
        else
            Notify.ShowText("Event locked")
        end

    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(IllInvestEvent.OpenIllInvestPanel, callback)


    local function callback()  -- 隔天请求
        local function step()
            self:RequestInvestInfo()
            self.model.is_nextday = true
        end
        self.crossday_delay_sche = GlobalSchedule:StartOnce(step, 2.5)
    end

    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.CrossDay, callback)

end

-- overwrite
function IllInvestCtr:GameStart()
    local function step()
        self:RequestInvestInfo()
    end
    self.time_id = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)
end

--  活动是否开启
function IllInvestCtr:RequestInvestInfo()
    local pb = self:GetPbObject("m_actinvest_info_tos")
    self:WriteMsg(proto.ACTINVEST_INFO,pb)
end

function IllInvestCtr:HandleInvestInfo()
    local data = self:ReadMsg("m_actinvest_info_toc")
    if data and not table.isempty(data.acts) then
        self.model:SetInvestInfo(data)
        local is_open = self.model:IsOpen()
        if is_open then
            local tab = data.acts[1]
            local is_show = true
            local time = os.time()
            if time > tab.stime and time < tab.etime then
                is_show = false
            end
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"investment",true,nil, tab.etime, nil,false, is_show, true)
            if self.model.is_nextday then
                GlobalEvent:Brocast(IllInvestEvent.IllDayInvest)
                self.model.is_nextday = false
            end
        else
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"investment",false)
        end
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon,"investment",false)
    end

end


--  购买 投资
function IllInvestCtr:RequestBuyInvest(id)
    local pb = self:GetPbObject("m_actinvest_buy_tos")
    pb.act_id = id
    self:WriteMsg(proto.ACTINVEST_BUY,pb)
end
function IllInvestCtr:HandleInvestBuyInfo()
    local data = self:ReadMsg("m_actinvest_buy_toc")
    if data then
        Notify.ShowText("Purchased")
        self.model:SetOneInfo(data)
        GlobalEvent:Brocast(IllInvestEvent.IllInvestBuySuccess, data)
    end
end
-- 领取
function IllInvestCtr:RequestRewardInvest(id, day)
    local pb = self:GetPbObject("m_actinvest_reward_tos")
    pb.act_id = id
    pb.day = day
    self:WriteMsg(proto.ACTINVEST_REWARD,pb)
end

function IllInvestCtr:HandleInvestRewardInfo()
    local data = self:ReadMsg("m_actinvest_reward_toc")
    if data then
        self.model:SetOneInfo(data)
        GlobalEvent:Brocast(IllInvestEvent.IllInvestRewardSuccess, data)
    end
end


