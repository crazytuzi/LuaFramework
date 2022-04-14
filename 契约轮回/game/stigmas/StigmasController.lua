---
--- Created by  Administrator
--- DateTime: 2019/9/24 11:05
---
StigmasController = StigmasController or class("StigmasController", BaseController)
local StigmasController = StigmasController
require('game.stigmas.RequireStigmas')
function StigmasController:ctor()
    StigmasController.Instance = self
    self.model = StigmasModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function StigmasController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function StigmasController:GetInstance()
    if not StigmasController.Instance then
        StigmasController.new()
    end
    return StigmasController.Instance
end

function StigmasController:AddEvents()
    local function callBack(id)
        --OpenTipModel:GetInstance():IsOpenSystem()
        --  logError(id)
        --print2(OpenTipModel:GetInstance():IsOpenSystem(570,1),"1111")
        if id == "150@12" then
            self:RequstDungeSoulPanel()
        end
        --dump(OpenTipModel:GetInstance().syslist)
    end
    GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, callBack);

end

function StigmasController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1203_dunge_pb"
    self:RegisterProtocal(proto.DUNGE_SOUL_PANEL, self.HandleDungeSoulPanel);
    self:RegisterProtocal(proto.DUNGE_SOUL_SELECT, self.HandleDungeSoulSelect);
    self:RegisterProtocal(proto.DUNGE_SOUL_START, self.HandleDungeSoulStart);
    self:RegisterProtocal(proto.DUNGE_SOUL_SUMMON, self.HandleDungeSoulSummon);


end

-- overwrite
function StigmasController:GameStart()
    local function step()
        if OpenTipModel.GetInstance():IsOpenSystem(150, 12) then
            self:RequstDungeSoulPanel()
        end
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end



function StigmasController:RequstDungeSoulPanel()
    local pb = self:GetPbObject("m_dunge_soul_panel_tos")

    self:WriteMsg(proto.DUNGE_SOUL_PANEL,pb)
end


function StigmasController:HandleDungeSoulPanel()
    local data = self:ReadMsg("m_dunge_soul_panel_toc")
    self.model.slots = data.slots
    self.model.options = data.options
    self.model.dungenStype = data.stype
    self.model.dungenId = data.id
    self.model.dungenInfo = data.info
    self.model:SetTimes(self.model.dungenInfo["rest_times"])
    self.model:Brocast(StigmasEvent.DungeSoulPanel,data)
end


function StigmasController:RequstDungeSoulSelect(slot,morph_id)
    local pb = self:GetPbObject("m_dunge_soul_select_tos")
    pb.slot = slot
    pb.morph_id = morph_id
    self:WriteMsg(proto.DUNGE_SOUL_SELECT,pb)
end


function StigmasController:HandleDungeSoulSelect()
    local data = self:ReadMsg("m_dunge_soul_select_toc")
    self.model.slots = data.slots
    self.model:Brocast(StigmasEvent.DungeSoulSelect,data)
end

function StigmasController:RequstDungeSoulStart()
    local pb = self:GetPbObject("m_dunge_soul_start_tos")

    self:WriteMsg(proto.DUNGE_SOUL_START,pb)
end


function StigmasController:HandleDungeSoulStart()
    local data = self:ReadMsg("m_dunge_soul_start_toc")
    GlobalEvent:Brocast(StigmasEvent.DungeSoulStart,data)
end

function StigmasController:RequstDungeSoulSummon(auto_summon)
    local pb = self:GetPbObject("m_dunge_soul_summon_tos")
    pb.auto_summon = auto_summon
    self:WriteMsg(proto.DUNGE_SOUL_SUMMON,pb)
end


function StigmasController:HandleDungeSoulSummon()
    local data = self:ReadMsg("m_dunge_soul_summon_toc")
    GlobalEvent:Brocast(StigmasEvent.DungeSoulSummon,data)
end










