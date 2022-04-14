---
--- Created by  Administrator
--- DateTime: 2020/6/2 16:36
---
require("game.luckywheel.RequireLuckyWheel")
LuckyWheelController = LuckyWheelController or class("LuckyWheelController", BaseController)
local LuckyWheelController = LuckyWheelController

function LuckyWheelController:ctor()
    LuckyWheelController.Instance = self

    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
    self.model = LuckyWheelModel:GetInstance()
end

function LuckyWheelController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function LuckyWheelController:GetInstance()
    if not LuckyWheelController.Instance then
        LuckyWheelController.new()
    end
    return LuckyWheelController.Instance
end

function LuckyWheelController:AddEvents()

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(LuckyWheelPanel):Open()
    end
     GlobalEvent:AddListener(LuckyWheelEvent.OpenLuckWheelPanel,call_back)

    --GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))
end

function LuckyWheelController:Test(keyCode)
    if keyCode == InputManager.KeyCode.N then
        self:RequestLuckyWheelTurnInfo(5)
    elseif keyCode == InputManager.KeyCode.M then
        self:RequestLuckyWheelTurnInfo(6)
    elseif keyCode == InputManager.KeyCode.B then
        self:RequestLuckyWheelTurnInfo(1)
    end
end

function LuckyWheelController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1703_luckywheel_pb"
    self:RegisterProtocal(proto.LUCKYWHEEL_INFO, self.HandleLuckyWheelInfo);
    self:RegisterProtocal(proto.LUCKYWHEEL_TURN, self.HandleLuckyWheelTurnInfo);

end

-- overwrite
function LuckyWheelController:GameStart()

end

function LuckyWheelController:RequestLuckyWheelInfo()
    local pb = self:GetPbObject("m_luckywheel_info_tos")
    --local data = {}
    --data.act_id = 100100
    --data.round = 1
    --data.fetch = {[1] = 1,[2] = 2,[3] = 3}
    --self.model:DealInfo(data)
    --self.model:Brocast(LuckyWheelEvent.LuckyWheelInfo,data)
    self:WriteMsg(proto.LUCKYWHEEL_INFO,pb)
end


function LuckyWheelController:HandleLuckyWheelInfo()
    local data = self:ReadMsg("m_luckywheel_info_toc")
    self.model:DealInfo(data)
    self.model:Brocast(LuckyWheelEvent.LuckyWheelInfo,data)
end


function LuckyWheelController:RequestLuckyWheelTurnInfo(type)
    local pb = self:GetPbObject("m_luckywheel_turn_tos")
   -- logError("请求type",type)
    pb.type = type
    --local data = {}
    --data.type = 0
    --data.grid = grid
    --self.model:DealTurnInfo(data)
   -- self.model:Brocast(LuckyWheelEvent.LuckyWheelTurnInfo,data)
    self:WriteMsg(proto.LUCKYWHEEL_TURN,pb)
end



function LuckyWheelController:HandleLuckyWheelTurnInfo()
    local data = self:ReadMsg("m_luckywheel_turn_toc")
   -- logError(data.type,data.grid)
    self.model:DealTurnInfo(data)
   -- self.model:Brocast(LuckyWheelEvent.LuckyWheelTurnInfo,data)
end







