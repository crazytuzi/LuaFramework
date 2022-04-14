---
--- Created by  Administrator
--- DateTime: 2019/3/11 11:02
---
require("game.sevenDay.RequireSevenDay")
SevenDayController = SevenDayController or class("SevenDayController", BaseController)
local SevenDayController = SevenDayController

function SevenDayController:ctor()
    SevenDayController.Instance = self

    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
    self.model = SevenDayModel:GetInstance()
end



function SevenDayController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SevenDayController:GetInstance()
    if not SevenDayController.Instance then
        SevenDayController.new()
    end
    return SevenDayController.Instance
end

function SevenDayController:AddEvents()
    GlobalEvent:AddListener(SevenDayEvent.OpenSevenDayPanel, handler(self, self.HandleOpenSevenDayPanel))
    --
    --local function callback()
    --    self:CheckRedPoint()
    --end
    --GlobalEvent:AddListener(EventName.CrossDay, callback)

   --  GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))


    local function callBack(id)
        --OpenTipModel:GetInstance():IsOpenSystem()
        --logError(id)
        --print2(OpenTipModel:GetInstance():IsOpenSystem(570,1),"1111")
        if id == "810@1" then
            self:RequestLoginInfo()
        end
        --dump(OpenTipModel:GetInstance().syslist)
    end
    GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, callBack);
end


function SevenDayController:Test(keyCode)
    if keyCode == InputManager.KeyCode.C then
        self:HandleOpenSevenDayPanel()
    end
end

function SevenDayController:HandleOpenSevenDayPanel()
    lua_panelMgr:GetPanelOrCreate(SevenDayPanel):Open()
end



function SevenDayController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1701_yylogin_pb"
    self:RegisterProtocal(proto.YYLOGIN_INFO, self.HandleLoginInfo);
    self:RegisterProtocal(proto.YYLOGIN_REWARD, self.HandleReward);
end

-- overwrite
function SevenDayController:GameStart()
    local function step()
        self:RequestLoginInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.VLow)
end

--请求登录奖励信息
function SevenDayController:RequestLoginInfo()
    local pb = self:GetPbObject("m_yylogin_info_tos")
    self:WriteMsg(proto.YYLOGIN_INFO,pb)
end

function SevenDayController:HandleLoginInfo()
    local data = self:ReadMsg("m_yylogin_info_toc")
    self.model.dayNums = data.days -- 累计登录天数
    self.model.rewardDays = data.list --
    local lv = Config.db_sysopen["810@1"].level
    local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if role_data.level >= lv then
        if #self.model.rewardDays >= 14 then
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "sevenDay", false)
        else
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "sevenDay", true)
        end
    end

    self:CheckRedPoint()
    self.model:Brocast(SevenDayEvent.SevenDayInfo,data)

end

function SevenDayController:CheckRedPoint()
    local len = self.model.dayNums
    for i = 1, len do
        self.model.redPoints[i] = not self.model:IsGetReward(i)
    end

    local isRed = false
    for i = 1, #self.model.redPoints do
        if self.model.redPoints[i] == true then
            isRed = true
            break
        end
    end
    self.model:Brocast(SevenDayEvent.SevenDatRedInfo)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot,"sevenDay",isRed)
    if #self.model.rewardDays >= 14 then
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,27,false)
    else
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,27,isRed)
    end

    --if isRed == false then
        --if self.model.firstOpen then
            --GlobalEvent:Brocast(MainEvent.ChangeRedDot,"sevenDay",true)
        --end
    --end
end

--请求领奖
function SevenDayController:RequestReward(day)
    local pb = self:GetPbObject("m_yylogin_reward_tos")
    pb.day = tonumber(day)
    self:WriteMsg(proto.YYLOGIN_REWARD,pb)
end

function SevenDayController:HandleReward()
    Notify.ShowText("Claimed")
    local data = self:ReadMsg("m_yylogin_reward_toc")
    table.insert(self.model.rewardDays,data.day)
    self:CheckRedPoint()
    if #self.model.rewardDays >= 14 then
        local  bPanel = lua_panelMgr:GetPanel(SevenDayPanel)
        if bPanel then
            bPanel:Close()
        end
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "sevenDay", false)
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "sevenDay", true)
    end
    self.model:Brocast(SevenDayEvent.SevenDayReward,data)
end







