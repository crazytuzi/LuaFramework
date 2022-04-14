---
--- Created by  Administrator
--- DateTime: 2020/4/13 16:46
---
require("game.richman.RequireRichMan")
RichManController = RichManController or class("RichManController", BaseController)
local RichManController = RichManController

function RichManController:ctor()
    RichManController.Instance = self
    self.model = RichManModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()

end

function RichManController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function RichManController:GetInstance()
    if not RichManController.Instance then
        RichManController.new()
    end
    return RichManController.Instance
end

function RichManController:AddEvents()

    local function call_back()
        if not OperateModel:GetInstance():IsActOpenByTime(self.model.actId) then
            Notify.ShowText("Event is over")
            return
        end
        lua_panelMgr:GetPanelOrCreate(RichManPanel):Open()
    end
    GlobalEvent:AddListener(RichManEvent.OpenRichManPanel,call_back)

    GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.ActiveInfo))
    GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.ReturnReward))
    
    local function call_back(id)
       -- if id == self.model.actId then
            self:RequestRichManInfo()
     --   end
    end
    GlobalEvent:AddListener(OperateEvent.ACT_START,call_back)


    local function call_back()
         self.model:CheckRedPoint()
    end

    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    local function call_back()
        self:RequestRichManInfo()
        OperateController:GetInstance():Request1700006(self.model.actId)
       -- logError("跨天请求大富豪")
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)

end

function RichManController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1702_richman_pb"
    self:RegisterProtocal(proto.RICHMAN_INFO, self.HandleRichManInfo)
    self:RegisterProtocal(proto.RICHMAN_DICE, self.HandleRichManDiceInfo)
    self:RegisterProtocal(proto.RICHMAN_FETCH, self.HandleRichManFitchInfo)
    self:RegisterProtocal(proto.RICHMAN_REFRECH, self.HandleRichManRefrechInfo)
    self:RegisterProtocal(proto.RICHMAN_MEND, self.HandleRichManMendInfo)
end

-- overwrite
function RichManController:GameStart()
    local function step()
        --local info = OperateModel:GetInstance():GetActInfo(self.model.actId)


       -- if info then
            self:RequestRichManInfo()
      --  end

    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)
end

function RichManController:RequestRichManInfo()
    local pb = self:GetPbObject("m_richman_info_tos")

    self:WriteMsg(proto.RICHMAN_INFO,pb)
end

function RichManController:HandleRichManInfo()
    local data = self:ReadMsg("m_richman_info_toc")
    self.model.actId = data.act_id
    --logError(self.model.actId,"大富豪")
    self.model.curRound = data.curr_round
    self.model.curGrid = data.curr_grid
    self.model.luckyRound = data.lucky_round
    self.model.diceGain = data.dice_gain
    self.model.roundFetch = data.round_fetch
    self.model.diceMend = data.dice_mend
    self.model:SetDiceGineNums()
    self.model:SetAfterDayDiceGineNums()
    ----if data.had_lucky  then
    ----    self.model.hasLuck = 1
    ----end
   -- logError(Table2String(data))
    self.model:CheckRedPoint()
    self.model:Brocast(RichManEvent.RichManInfo,data)
end

function RichManController:RequestRichManDiceInfo(type,point)
    local pb = self:GetPbObject("m_richman_dice_tos")
    pb.type = type
    if point then
        pb.point = point
    end
    self:WriteMsg(proto.RICHMAN_DICE,pb)
end

function RichManController:HandleRichManDiceInfo()
    local data = self:ReadMsg("m_richman_dice_toc")
  --  logError(Table2String(data))
    if data.type == 3 then
        self.model:Brocast(RichManEvent.RichManReadyDiceInfo,data)
        return
    end

    self.model.curGrid = self.model.curGrid + data.point
    if data.result == 5 then
        local round = self.model.curRound
        local  grid = self.model.curGrid
        local key = self.model.actId.."@"..round.."@"..grid
        local cfg = Config.db_yunying_richman[key]
        self.model.curGrid = self.model.curGrid - tonumber(cfg.reward)
        if cfg.type == 4 then
            self.model:Brocast(RichManEvent.RichManReadyDiceLuckInfo,data)
        end
    elseif data.result == 4  then
        self.model:Brocast(RichManEvent.RichManReadyDiceLuckInfo,data)
    end
    --if data.result == 4 then
    --    self:RequestRichManInfo()
    --end
    --logError(self.model.curGrid)
    if self.model.curGrid >= 36 then
        self.model.curGrid = 1
        self.model.curRound =  self.model.curRound + 1
    end
    self.model:CheckRedPoint()
    self.model:Brocast(RichManEvent.RichManDiceInfo,data)
end


function RichManController:RequestRichManFitchInfo(round)
    local pb = self:GetPbObject("m_richman_fetch_tos")
    pb.round = round
    self:WriteMsg(proto.RICHMAN_FETCH,pb)
end


function RichManController:HandleRichManFitchInfo()
    local data = self:ReadMsg("m_richman_fetch_toc")
    table.insert(self.model.roundFetch,data.round)
    self.model:CheckRedPoint()
    self.model:Brocast(RichManEvent.RichManFetchInfo,data)
end


function RichManController:HandleRichManRefrechInfo()
    local data = self:ReadMsg("m_richman_refrech_toc")
   -- logError("--refrech--")
    self:RequestRichManInfo()
    --self.model:Brocast(RichManEvent.RichManRefrechInfo)
end

function RichManController:RequestRichManMendInfo()
    local pb = self:GetPbObject("m_richman_mend_tos")
    self:WriteMsg(proto.RICHMAN_MEND,pb)
end


function RichManController:HandleRichManMendInfo()
    local data = self:ReadMsg("m_richman_mend_toc")
    --for i, v in pairs(self.model.diceGain) do
    --    self.model.diceGain[i] = self.model:GetTouZiNum(i)
    --end
    self.model.diceMend = self.model.diceMend + 1
    self.model.diceGineNums =  self.model.diceGineNums + 1
    self.model.afterDiceGineNums = self.model.afterDiceGineNums + 1
    logError("--补签")
    self.model:CheckRedPoint()
    self.model:Brocast(RichManEvent.RichManMendInfo,data)
end

function RichManController:ActiveInfo(info)
    self.model:CheckRedPoint()
end

function RichManController:ReturnReward()
    self.model:CheckRedPoint()
end






