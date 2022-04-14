--
-- @Author: LaoY
-- @Date:   2018-09-26 10:34:35
-- 技能界面以及战斗中技能相关 放在战斗模块一起

SkillController = SkillController or class("SkillController", BaseController)
local SkillController = SkillController

function SkillController:ctor()
    SkillController.Instance = self
    self.model = SkillModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function SkillController:dctor()
end

function SkillController:GetInstance()
    if not SkillController.Instance then
        SkillController.new()
    end
    return SkillController.Instance
end

function SkillController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1105_skill_pb"
    -- self:RegisterProtocal(proto.SKILL_LIST, self.HandleSkillList)
end

function SkillController:AddEvents()
    -- --请求基本信息
    local function ON_REQ_SKILL_LIST()
        self:RequestSkillList()
    end
    self.model:AddListener(SkillEvent.REQ_SKILL_LIST, ON_REQ_SKILL_LIST)
end

-- overwrite
function SkillController:GameStart()
    local function step()
        self.model:Brocast(SkillEvent.REQ_SKILL_LIST)
    end
    -- GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Super)
end

----请求基本信息
function SkillController:RequestSkillList()
    -- local pb = self:GetPbObject("m_skill_list_tos")
    self:WriteMsg(proto.SKILL_LIST)
end

----服务的返回信息
function SkillController:HandleSkillList()
    local data = self:ReadMsg("m_skill_list_toc")
    -- print('--LaoY SkillController.lua,line 57--')
    -- dump(data,"data")
    self.model:SetSkillList(data.skills)
    self.model:Brocast(SkillEvent.ACC_SKILL_LIST)
end