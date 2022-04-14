-- @Author: lwj
-- @Date:   2019-04-17 15:30:56
-- @Last Modified time: 2019-11-14 17:13:18

require "game.firstPay.RequireFirstPay"
FirstPayController = FirstPayController or class("FirstPayController", BaseController)
local FirstPayController = FirstPayController

function FirstPayController:ctor()
    FirstPayController.Instance = self
    self.model = FirstPayModel:GetInstance()
    self.pop_lv = 17
    self.is_show_guide = false
    self.role_update_list = {}
    self.is_binded = false

    --0.1元首充绑定玩家等级刷新的事件id
    self.firstpaydime_lv_update_event_id = nil

    --0.1元首充界面弹窗等级
    self.firstpaydime_panel_pop_lv = Config.db_sysopen["841@1"].level

    self:AddEvents()
    self:RegisterAllProtocal()
end

function FirstPayController:dctor()
    self:RemoveLvBind()
    GlobalSchedule:Stop(self.sche_1)

    GlobalEvent:RemoveListener(self.firstpaydime_lv_update_event_id)
    self.firstpaydime_lv_update_event_id = nil
end

function FirstPayController:GetInstance()
    if not FirstPayController.Instance then
        FirstPayController.new()
    end
    return FirstPayController.Instance
end

function FirstPayController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1130_firstpay_pb"
    self:RegisterProtocal(proto.FIRSTPAY_INFO, self.HandleFirstPayInfo)
    self:RegisterProtocal(proto.FIRSTPAY_REWARD, self.HandleGetReward)
end

function FirstPayController:AddEvents()
    local function callback(param)
        self:RequestInfo()
        lua_panelMgr:GetPanelOrCreate(FirstPayPanel):Open(param)
    end
    GlobalEvent:AddListener(FirstPayEvent.OpenFirstPayPanel, callback)

    self.model:AddListener(FirstPayEvent.GetFirstPayReward, handler(self, self.RequestGetReward))

    -- 打开0.1元首充界面
    local function callback(param)
        local panel = lua_panelMgr:GetPanelOrCreate(FirstPayDimePanel)
        panel:Open()
        panel:SetData()
    end
    GlobalEvent:AddListener(FirstPayEvent.OpenFirstPayDimePanel, callback)

    --已充值列表返回
    local function callback( ) 
        local list = VipModel.GetInstance().have_pay_list
        self:HandleFirstPayDimeInfo(list)
    end
    VipModel.GetInstance():AddListener(VipEvent.HandlePaidList,callback)

    -- 打开首充提示界面
    local function callback(time)
        local panel = lua_panelMgr:GetPanelOrCreate(FirstPayTipPanel)
        panel:Open()
        local data = {}
        data.time = time  --剩余时间
        panel:SetData(data)
    end
    GlobalEvent:AddListener(FirstPayEvent.OpenFirstPayTipPanel, callback)
end

-- overwrite
function FirstPayController:GameStart()
    local function step()
        self:RequestInfo()
    end
    self.sche_1 = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)

     --是否首次显示过0.1元首充图标的红点
     self.is_first_show_firstpaydime_reddot = false
     
     
     local function callback(  )
         self:BindFirstPayDimeLvUpEvent()
     end
     GlobalSchedule:StartOnce(callback, Constant.GameStartReqLevel.Low)
end

function FirstPayController:CheckIsBindPopWin()
    local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    --未首充，等级不足，未绑定事件
    if my_lv < self.pop_lv and (not self.is_binded) and (not self.model:IsFirstPay()) then
        self:BindLvUpPopWin()
    else
        self:RemoveLvBind()
    end
end

function FirstPayController:BindLvUpPopWin()
    self.role_update_list = self.role_update_list or {}
    local function call_back()
        local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        if my_lv >= self.pop_lv then
            --弹出首充指引
            self.is_show_guide = true
            self:RequestInfo()
            self:RemoveLvBind()
        end
    end
    self.role_update_list[#self.role_update_list + 1] = GlobalEvent:AddListener(EventName.ChangeLevel, call_back)
end

function FirstPayController:RemoveLvBind()
    if not table.isempty(self.role_update_list) then
        for k, event_id in pairs(self.role_update_list) do
            GlobalEvent:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
end

function FirstPayController:RequestInfo()
    self:WriteMsg(proto.FIRSTPAY_INFO)
end

function FirstPayController:HandleFirstPayInfo()
    local data = self:ReadMsg("m_firstpay_info_toc")
    --dump(data, "<color=#6ce19b>HandleFirstPayInfo0   HandleFirstPayInfo0  HandleFirstPayInfo0  HandleFirstPayInfo0</color>")
    self.model:SetInfo(data)
    self:CheckIsShowIcon()
    if self.is_show_guide then
        lua_panelMgr:GetPanelOrCreate(FirstPayGuidPanel):Open()
        self.is_show_guide = false
    end
    if self.model:IsFirstPay() then
        --已首充
        self.model:CheckRD()
    else
        if self.model.is_show_rd_once then
            self.model.is_show_rd_once = false
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "firstPay", true)
        end
    end
    self:CheckIsBindPopWin()
end

function FirstPayController:CheckIsShowIcon()
    local is_show = self.model:IsCanShowIcon()
    if is_show then
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "firstPay", true)
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "firstPay", false)
    end
end

function FirstPayController:RequestGetReward()
    local pb = self:GetPbObject("m_firstpay_reward_tos")
    pb.day = self.model.cur_show_day
    self:WriteMsg(proto.FIRSTPAY_REWARD, pb)

end

function FirstPayController:HandleGetReward()
    self.model:AddRewarded()
    self.model:Brocast(FirstPayEvent.FetchSuccess)
    if self.model.cur_show_day == 3 then
        self.model.show_icon_this_time = true
    end
    Notify.ShowText("Claimed")
end

--绑定0.1元首充相关的等级提升事件
function FirstPayController:BindFirstPayDimeLvUpEvent(  )

     --尝试先移除掉旧的升级监听
     if self.firstpaydime_lv_update_event_id then

        GlobalEvent:RemoveListener(self.firstpaydime_lv_update_event_id)
        self.firstpaydime_lv_update_event_id = nil
    end

    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local role_create_time = RoleInfoModel.GetInstance():GetRoleValue("ctime")  --角色创建时间
    local cur_time = TimeManager.GetInstance():GetServerTime()  --当前时间
    local end_time = role_create_time + TimeManager.DaySec  --结束时间

    --尝试监听等级提升
    if lv < self.firstpaydime_panel_pop_lv  and cur_time < end_time then
        --等级不足10级  且时间没到 就绑定等级提升事件
        
        local function callback(  )
           
            local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
         
            if cur_lv >= self.firstpaydime_panel_pop_lv then

                --显示图标
                -- local role_create_time = RoleInfoModel.GetInstance():GetRoleValue("ctime")  --角色创建时间
                -- local end_time = role_create_time + TimeManager.DaySec  --结束时间
                -- GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "firstPayDime", true,nil,nil,end_time)
                self.is_first_show_firstpaydime_reddot = true

                --等级足够 进行弹窗
                local panel = lua_panelMgr:GetPanelOrCreate(FirstPayDimePanel)
                panel:Open()
                panel:SetData()

               

                GlobalEvent:RemoveListener(self.firstpaydime_lv_update_event_id)
                self.firstpaydime_lv_update_event_id = nil
            end
        end
        self.firstpaydime_lv_update_event_id = GlobalEvent:AddListener(EventName.ChangeLevel, callback)
    end

   
end

--处理已充值列表返回信息
function FirstPayController:HandleFirstPayDimeInfo(paid_list)

    local goods_id = 15
    local is_pay = false  --是否已充值过0.1元
    for k,v in ipairs(paid_list) do
        if v == goods_id then
            is_pay = true
        end
    end
     
    local role_create_time = RoleInfoModel.GetInstance():GetRoleValue("ctime")  --角色创建时间
    local cur_time = TimeManager.GetInstance():GetServerTime()  --当前时间
    local end_time = role_create_time + TimeManager.DaySec  --结束时间
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
  
    --等级达到 未购买 时间未到
    --就显示icon
    local is_show_icon = lv >= self.firstpaydime_panel_pop_lv and not is_pay and cur_time < end_time
    GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "firstPayDime", is_show_icon,nil,nil,end_time)


    --红点显示 只在没显示过红点，且显示了图标的情况下 显示一次
    if not self.is_first_show_firstpaydime_reddot and is_show_icon then
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "firstPayDime", true)
        self.is_first_show_firstpaydime_reddot = true
    end




end