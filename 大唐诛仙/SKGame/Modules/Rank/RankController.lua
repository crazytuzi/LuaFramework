RegistModules("Rank/RankConst")
RegistModules("Rank/RankModel")
RegistModules("Rank/RankView")

RegistModules("Rank/Vo/BattleRankVo")
RegistModules("Rank/Vo/EquipRankVo")
RegistModules("Rank/Vo/GoldRankVo")

RegistModules("Rank/View/RankItem")
RegistModules("Rank/View/RankHead")
RegistModules("Rank/View/RankContent")
RegistModules("Rank/View/RankPanel")
RegistModules("Rank/View/RankSelectPanel")

RankController =BaseClass(LuaController)

function RankController:GetInstance()
	if RankController.inst == nil then
		RankController.inst = RankController.New()
	end
	return RankController.inst
end

function RankController:__init()
	self.model = RankModel:GetInstance()
	self.view = nil

	self:InitEvent()
	self:RegistProto()

	self.getRankDataSuccess = false
end

function RankController:InitEvent()
	
end

-- 协议注册
function RankController:RegistProto()
	self:RegistProtocal("S_BattleValueRank") --战力榜
	self:RegistProtocal("S_EquipRank") --神兵榜
	self:RegistProtocal("S_GoldRank") --财富榜
end

function RankController:S_BattleValueRank(buff)
	local msg = self:ParseMsg(rank_pb.S_BattleValueRank(), buff)
	self.model:ParseBattleRankData(msg)
end

function RankController:S_EquipRank(buff)
	local msg = self:ParseMsg(rank_pb.S_EquipRank(), buff)
	self.model:ParseEquipRankData(msg)
end

function RankController:S_GoldRank(buff)
	local msg = self:ParseMsg(rank_pb.S_GoldRank(), buff)
	self.model:ParseGoldRankData(msg)
end

-- 请求获取排行榜数据
--@param bigType 1：战力榜 2：神兵榜  3：财富榜
--@param smallType 1：综合 2：龙卫 3：冰璃 4：暗巫
--@param start
--@param num
function RankController:ReqGetRankList(bigType, smallType, start, num)
	local msg = rank_pb.C_GetRankList()
	msg.type = bigType
	msg.career = smallType
	msg.start = start
	msg.offset = num
	self:SendMsg("C_GetRankList", msg)
end

function RankController:OpenRankPanel()
	if not self.view then
		self.view = RankView.New()
	end
	RenderMgr.Add(function () self:OpenRankPanelInFrame() end, "RankController:OpenRankPanelInFrame")
	self.getRankDataSuccess = true
end

function RankController:OpenRankPanelInFrame()
	if self.view and self.getRankDataSuccess then 
		 RenderMgr.Remove("RankController:OpenRankPanelInFrame")
		self.view:OpenRankPanel()
	end
end

function RankController:Close()
	if self.view then 
		self.view:Close()
	end
end

function RankController:__delete()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	RankController.inst = nil
end