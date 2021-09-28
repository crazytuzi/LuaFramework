ClanModel = BaseClass(LuaModel)
function ClanModel:__init()
	self.openType = ClanConst.paneType.cj
	self.clanId = 0
	self.job = -1
	self.contribution = 0
	self.justJoinClan = false --标识是否刚刚加入
	self.justExitClan = false --标识是否刚刚退出
	self.members = {}
	self.warList = {}
	self.donateList = {}

	self.learnList = {}
	self.devList = {}
	self.mapSkills =nil -- [type]={[level]=cfg,...} 配置 guildskill
	self.typeSkillList = {}

	self.cityWar=nil
	self.unionInfo=nil
	self.tax = nil
	
	self.warHoster = -1 -- 城占帮id

	self.clanInfo = ClanInfoVo.New()
end

function ClanModel:SetBaseInfo(msg, job, contribution)
	self.clanInfo:Update(msg)
	self.justJoinClan = self.clanId == 0 and self.clanInfo.guildId ~= 0
	self.justExitClan = self.clanId ~= 0 and self.clanInfo.guildId == 0
	self.clanId = self.clanInfo.guildId
	self.job = job
	self.contribution = contribution 
	-- print("职位："..ClanConst.clanJob[job+1])
	self:Fire(ClanConst.clanInfoUpdated)
end
function ClanModel:ClearInfo() -- 退出或被踢出调用
	self.clanInfo:Clear()
	self.justJoinClan = self.clanId == 0 and self.clanInfo.guildId ~= 0
	self.justExitClan = self.clanId ~= 0 and self.clanInfo.guildId == 0
	self.clanId = self.clanInfo.guildId
	self.contribution = 0
	self.job = 0
	-- print("职位："..ClanConst.clanJob[job+1])
	self:Fire(ClanConst.clanInfoUpdated)
end
-- 成员列表
function ClanModel:UpdateMembers(members, onlineNum)
	self.members = members
	self.onlineNum = onlineNum
	self:Fire(ClanConst.membersChanged)
end
-- 可申请列表
function ClanModel:UpdateGuildItems( items )
	self:Fire(ClanConst.sqGuildItems, items)
end
-- 可接受列表
function ClanModel:UpdateApplyList( items )
	self:Fire(ClanConst.applyList, items)
end
--
function ClanModel:UpdateDonate(list)
	self.donateList = list
end
--
function ClanModel:UpdateWarList(list)
	self.warList = list
end
--
function ClanModel:DevSkill( list )
	self.devList = list
end
function ClanModel:LearnSkill( list )
	self.learnList = list
end
function ClanModel:ConfigSkill()
	if self.mapSkills then return end
	local cfg = GetCfgData("guildskill")
	local get_key = "Get"
	local list = {}
	for k,v in pairs(cfg) do
		if k~=get_key then
			table.insert(list, v)
		end
	end
	SortTableBy2Key(list, "type", "level", true, true )
	local map = {}
	for i,v in ipairs(list) do
		if not map[v.type] then
			map[v.type] = {}
			table.insert(self.typeSkillList, v.type)
		end
		table.insert(map[v.type], v)
	end
	self.mapSkills = map
end

function ClanModel:SetCityWar(msg)
	self.cityWar = msg
end
function ClanModel:SetUnionInfo( msg )
	self.unionInfo = msg
end
function ClanModel:SetTax( msg )
	self.tax = msg
end
function ClanModel:SetBuyList( list )
	self.buyList = list
end

function ClanModel:GetInstance()
	if ClanModel.inst == nil then
		ClanModel.inst = ClanModel.New()
	end
	return ClanModel.inst
end
function ClanModel:__delete()
	self.clanInfo:Clear()
	self.clanInfo=nil
	self.contribution = 0
	ClanModel.inst = nil
end