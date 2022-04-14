-- @Author: lwj
-- @Date:   2019-04-17 15:30:56
-- @Last Modified time: 2019-11-14 17:13:18

require "game.secPay.RequireSecPay"
SecPayController = SecPayController or class("SecPayController", BaseController)
local SecPayController = SecPayController

function SecPayController:ctor()
    SecPayController.Instance = self
    self.model = SecPayModel:GetInstance()

    self:AddEvents()
    self:RegisterAllProtocal()
end

function SecPayController:dctor()
    if self.cross_day_event_id then
        GlobalEvent:RemoveListener(self.cross_day_event_id)
        self.cross_day_event_id = nil
    end
    GlobalSchedule:Stop(self.sche_1)
end

function SecPayController:GetInstance()
    if not SecPayController.Instance then
        SecPayController.new()
    end
    return SecPayController.Instance
end

function SecPayController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1143_actpay_pb"
    self:RegisterProtocal(proto.ACTPAY_INFO, self.HandleActInfoList)
    self:RegisterProtocal(proto.ACTPAY_REWARD, self.HandleGetReward)
end

function SecPayController:AddEvents()
    local function callback(param)
        self:RequestInfo()
        --local id = OperateModel.GetInstance():GetActIdByType(730)
        --if id == 0 then
        --    return
        --end
        local running_id = self.model:GetAnyRunningActId()
        if not running_id then
            return
        end
        local opdays = LoginModel.GetInstance():GetOpenTime()
        local cf = Config.db_actpay[running_id]
        if not cf then
            logError("SecPayModel: actpay配置没有该running_id: ", running_id)
            return false
        end
        local need_day = cf.opdays
        if opdays < need_day then
            return
        end
        lua_panelMgr:GetPanelOrCreate(SecPayPanel):Open(param)
    end
    GlobalEvent:AddListener(SecPayEvent.OpenFirstPayPanel, callback)

    self.model:AddListener(SecPayEvent.GetFirstPayReward, handler(self, self.RequestGetReward))

    self.cross_day_event_id = GlobalEvent:AddListener(EventName.CrossDayAfter, handler(self, self.RequestInfo))
end

-- overwrite
function SecPayController:GameStart()
    local function step()
        self:RequestInfo()
    end
    self.sche_1 = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end

function SecPayController:RequestInfo()
    self:WriteMsg(proto.ACTPAY_INFO)
end

function SecPayController:HandleActInfoList()
    local data = self:ReadMsg("m_actpay_info_toc")
    --dump(data, "<color=#6ce19b>HandleActInfoList   HandleActInfoList  HandleActInfoList  HandleActInfoList</color>")
    self.model:SetInfo(data.acts)
    self:CheckIsShowIcon(self.model.sec_week_recha_id, "secPay")
    self:RechargeOperate()
end

--一系列活动，取得数据之后的操作
function SecPayController:RechargeOperate()
    --第二周累充
    if self.model:IsFirstPay(self.model.sec_week_recha_id) then
        --已首充
        self.model:CheckRD(self.model.sec_week_recha_id, "secPay", 64)
    else
        if self:CheckLastOneDayTime(self.model.sec_week_recha_id) then
            self.model.show_icon_this_time_list[self.model.sec_week_recha_id] = true
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "secPay", true)
        end
    end
end

function SecPayController:CheckLastOneDayTime(id)
    local str = self.model.cache_act_name[id] .. "check_red_dot_stamp"
    local stamp = CacheManager.GetInstance():GetInt(str)
    if stamp == nil then
        --没有登录时间
        return true
    else
        local param = TimeManager.GetInstance():GetDifDay(stamp, os.time())
        if param >= 1 then
            --显示一天一次红点
            return true
        else
            return false
        end
    end
end

function SecPayController:CheckIsShowIcon(id, key)
    local is_show = self.model:IsCanShowIcon(id)
    if is_show then
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, key, true)
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, key, false)
    end
end

function SecPayController:RequestGetReward(id, day)
    local pb = self:GetPbObject("m_actpay_reward_tos")
    pb.day = day or self.model.cur_show_day
    pb.act_id = id
    self:WriteMsg(proto.ACTPAY_REWARD, pb)
end

function SecPayController:HandleGetReward()
    self.model:AddRewarded()
    self.model:Brocast(SecPayEvent.FetchSuccess)
    if self.model.cur_show_day == 3 then
        self.model.show_icon_this_time = true
    end
    self:CheckIsShowIcon(self.model.sec_week_recha_id, "secPay")
    self:RechargeOperate()
    Notify.ShowText("Claimed")
end
