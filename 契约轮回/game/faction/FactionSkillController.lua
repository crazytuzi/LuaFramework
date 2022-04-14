--
-- @Author: chk
-- @Date:   2018-12-05 10:40:57
--
require('game.faction.RequireFaction')
FactionSkillController = FactionSkillController or class("FactionSkillController",BaseController)
local FactionSkillController = FactionSkillController

function FactionSkillController:ctor()
	FactionSkillController.Instance = self
	self.model = FactionModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function FactionSkillController:dctor()
end


function FactionSkillController:GetInstance()
	if not FactionSkillController.Instance then
		FactionSkillController.new()
	end
	return FactionSkillController.Instance
end

function FactionSkillController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1402_guild_skill_pb"
	self:RegisterProtocal(proto.GUILD_SKILL_SKILLS,self.ResponeFactionSkills)
    self:RegisterProtocal(proto.GUILD_SKILL_UPGRADE,self.ResponeLearnSkill)
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function FactionSkillController:AddEvents()
	-- --请求基本信息
	-- local function ON_REQ_BASE_INFO()
		-- self:RequestLoginVerify()
	-- end
	-- self.model:AddListener(FactionModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)
end

-- overwrite
function FactionSkillController:GameStart()
end


function FactionSkillController:RequestFactionSkills()
	local pb = self:GetPbObject("m_guild_skill_skills_tos")
	self:WriteMsg(proto.GUILD_SKILL_SKILLS,pb)
end

function FactionSkillController:ResponeFactionSkills()
	local data = self:ReadMsg("m_guild_skill_skills_toc")
	self.model.skillLst = data.skills
	for i, v in pairs(self.model.skillLst) do
		self.model:Brocast(FactionEvent.SkillInfo,i)
	end
	FactionController:GetInstance():UpdateRedPoint()
end

function FactionSkillController:RequestLearnSkill(id)
    local pb = self:GetPbObject("m_guild_skill_upgrade_tos")
    pb.id = id
    self:WriteMsg(proto.GUILD_SKILL_UPGRADE,pb)
end

function FactionSkillController:ResponeLearnSkill()
    local data = self:ReadMsg("m_guild_skill_upgrade_toc")
    self.model.skillLst[data.id] = data.level
    self.model:Brocast(FactionEvent.SkillUpLv,data)
	FactionController:GetInstance():UpdateRedPoint()
end



