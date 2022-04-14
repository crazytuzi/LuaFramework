---
--- Created by  Administrator
--- DateTime: 2019/4/30 10:46
---
require('game.arena.RequireArena')
ArenaController = ArenaController or class("ArenaController", BaseController)
local ArenaController = ArenaController

function ArenaController:ctor()
	ArenaController.Instance = self
	
	self.events = {}
	self:AddEvents()
	self:RegisterAllProtocol()
	self.model = ArenaModel:GetInstance()
end

function ArenaController:dctor()
	GlobalEvent:RemoveTabListener(self.events)
end

function ArenaController:GetInstance()
	if not ArenaController.Instance then
		ArenaController.new()
	end
	return ArenaController.Instance
end

function ArenaController:AddEvents()
	
	self.events[#self.events + 1] = GlobalEvent:AddListener(PeakArenaEvent.ShowRedPoint, handler(self, self.PeakArenaRedPoint));
	self.events[#self.events + 1] = GlobalEvent:AddListener(CompeteEvent.CheckRedPoint, handler(self, self.CompeteRedPoint));
	self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));

	local function callBack(isShow,Id)
		if Id == 10231 then
			self:CheckRedPoint()
		end
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(ActivityEvent.ChangeActivity, callBack);


	--local function callBack(isFirst)
	--	logError(isFirst)
	--end
	--GlobalEvent:AddListener(EventName.FirstLanding, callBack);

	--self:PeakArenaRedPoint(PeakArenaModel:GetInstance():GetRedPoint())
end

function ArenaController:GameStart()
	local function step()
		--self:RequstArenaInfo() --竞技场信息
		--self:RequstTopInfo() --大神挑战信息
		--self:RequstTopRank() --大神奖励信息
		--self:RequstHighestRank()  --历史最高
		--self:RequstArenaRank() --排行奖励信息
		self:RequstRedPoineInfo()
	end
	GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Ordinary)
	
	
	-- GlobalSchedule.StartFunOnce(handler(self, self.CheckRedPoint), 3);
	--self:CheckRedPoint()
end



function ArenaController:HandleSceneChange(sceneID)
	local config = Config.db_scene[sceneID]
	if not config then
		print2("不存在场景配置" .. tostring(sceneID));
		return
	end
	
	if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ARENA then --进入JJC
		LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,false)
		local  aPanel = lua_panelMgr:GetPanel(AthleticsPanel)
		if aPanel then
			-- aPanel:Close()
			aPanel:SetVisible(false)
		end
		local  bPanel = lua_panelMgr:GetPanel(ArenaBigPanel)
		if bPanel then
			bPanel:SetVisible(false)
		end
		
		lua_panelMgr:GetPanelOrCreate(ArenaBattlePanel):Open()
	else
		if self.model.isOpenBattlePanle then
			local  panel = lua_panelMgr:GetPanel(ArenaBattlePanel);
			panel:Close()
			local  aPanel = lua_panelMgr:GetPanel(AthleticsPanel)
			if aPanel then
				-- aPanel:Close()
				aPanel:SetVisible(true)
				-- LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,false)
			end
			local  bPanel = lua_panelMgr:GetPanel(ArenaBigPanel)
			if bPanel then
				bPanel:SetVisible(true)
			end
			
			local ePanel = lua_panelMgr:GetPanel(ArenaEndPanel)
			if ePanel then
				ePanel:Close()
			end
			--   LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,true)
		end
	end
end


function ArenaController:RegisterAllProtocol()
	---[[protobuff的模块名字，用到pb一定要写]]
	self.pb_module_name = "pb_1132_arena_pb"
	self:RegisterProtocal(proto.ARENA_INFO, self.HandleArenaInfo);
	self:RegisterProtocal(proto.ARENA_REFRESH, self.HandleRefresh);
	self:RegisterProtocal(proto.ARENA_ADD_CHALLENGE, self.HandleAddChallenge);
	self:RegisterProtocal(proto.ARENA_START, self.HandleStart); --开始挑战
	self:RegisterProtocal(proto.ARENA_BATTLE, self.HandleBattleInfo)
	self:RegisterProtocal(proto.ARENA_END, self.HandleEnd)
	self:RegisterProtocal(proto.ARENA_TOP, self.HandleTopInfo)
	self:RegisterProtocal(proto.ARENA_STIMULATE, self.HandleStinulate)
	self:RegisterProtocal(proto.ARENA_HIGHEST_RANK, self.HandleHighestRank)
	self:RegisterProtocal(proto.ARENA_HIGHEST_RANK_FETCH, self.HandleHighestRankFetch)
	self:RegisterProtocal(proto.ARENA_RANK, self.HandleArenaRank)
	self:RegisterProtocal(proto.ARENA_RANK_FETCH, self.HandleArenaRankFetch)
	self:RegisterProtocal(proto.ARENA_TOP_RANK, self.HandleTopRank)
	self:RegisterProtocal(proto.ARENA_TOP_RANK_FETCH, self.HandleTopRankfetch)
	self:RegisterProtocal(proto.ARENA_NOTICE, self.HandleRedPoineInfo)
	
end


--请求竞技场数据
function ArenaController:RequstArenaInfo()
	local pb = self:GetPbObject("m_arena_info_tos");
	self:WriteMsg(proto.ARENA_INFO, pb);
end


function ArenaController:HandleArenaInfo()
	local data = self:ReadMsg("m_arena_info_toc");
	self.model.sti_times = data.sti_times
	self.model.curRank = data.rank
	
	--if data.challenge > 0 then
	--    self.model.isChallenge = true
	--else
	--    self.model.isChallenge = false
	--end
	self.model:Brocast(ArenaEvent.ArenaInfo,data)
end

--请求刷新
function ArenaController:RequstRefresh()
	local pb = self:GetPbObject("m_arena_refresh_tos");
	self:WriteMsg(proto.ARENA_REFRESH, pb);
end


function ArenaController:HandleRefresh()
	local data = self:ReadMsg("m_arena_refresh_toc");
	self.model:Brocast(ArenaEvent.ArenaRefresh,data)
end

--购买挑战次数
function ArenaController:RequstAddChallenge(num)
	local pb = self:GetPbObject("m_arena_add_challenge_tos");
	pb.num = num
	self:WriteMsg(proto.ARENA_ADD_CHALLENGE, pb);
	
end

function ArenaController:HandleAddChallenge()
	local data = self:ReadMsg("m_arena_add_challenge_toc");
	self.model:Brocast(ArenaEvent.ArenaAddChallenge,data)
	self:RequstRedPoineInfo()
end
--开始挑战
function ArenaController:RequstStart(rank,role_id,is_merge,istop,isSkip)
	local pb = self:GetPbObject("m_arena_start_tos");
	pb.rank = tonumber(rank)
	pb.role_id = role_id
	pb.is_merge = is_merge
	pb.is_top = istop
	pb.is_skip = isSkip
	self:WriteMsg(proto.ARENA_START, pb);
end

function ArenaController:HandleStart()
	local data = self:ReadMsg("m_arena_start_toc");
end

--战斗信息
function ArenaController:RequstBattleInfo()
	local pb = self:GetPbObject("m_arena_battle_tos");
	self:WriteMsg(proto.ARENA_BATTLE, pb);
end


function ArenaController:HandleBattleInfo()
	local data = self:ReadMsg("m_arena_battle_toc");
	self.model:Brocast(ArenaEvent.ArenaBattleInfo,data)
end

---挑战结束
function ArenaController:HandleEnd()
	local data = self:ReadMsg("m_arena_end_toc");
	self.model.curRank = data.new_rank
	self.model:StartResult(data)
	self:RequstRedPoineInfo()
	--self.model:Brocast(ArenaEvent.ArenaEnd,data)
end

--跳过战斗
function ArenaController:RequstSkip()
	local pb = self:GetPbObject("m_arena_skip_tos");
	self:WriteMsg(proto.ARENA_SKIP, pb);
end

--大神挑战信息
function ArenaController:RequstTopInfo()
	local pb = self:GetPbObject("m_arena_top_tos");
	self:WriteMsg(proto.ARENA_TOP, pb);
end

function ArenaController:HandleTopInfo()
	local data = self:ReadMsg("m_arena_top_toc");
	--if data.challenge > 0  then
	--    self.model.isTopChallenge = true
	--else
	--    self.model.isTopChallenge = false
	--end
	self.model:Brocast(ArenaEvent.ArenaTopInfo,data)
	
end

--战力激励
function ArenaController:RequstStinulate()
	local pb = self:GetPbObject("m_arena_stimulate_tos");
	self:WriteMsg(proto.ARENA_STIMULATE, pb);
end

function ArenaController:HandleStinulate()
	local data = self:ReadMsg("m_arena_stimulate_toc");
	self.model.sti_times = data.sti_times
	self.model:Brocast(ArenaEvent.ArenaStinulate,data)
end

--请求历史最高排行奖励
function ArenaController:RequstHighestRank()
	local pb = self:GetPbObject("m_arena_highest_rank_tos");
	self:WriteMsg(proto.ARENA_HIGHEST_RANK, pb);
end

function ArenaController:HandleHighestRank()
	local data = self:ReadMsg("m_arena_highest_rank_toc");
	self.model.highestRank = data.rank
	self.model.highestRankFetch = data.fetch
	--local cfg  = Config.db_arena_high_rank
	--self.model.isHightReward = false
	--for i, v in pairs(cfg) do
	--    if not self.model:isHighestById(v.id) then
	--        if self.model.highestRank <= self.data.max then
	--            self.model.isHightReward = true
	--        end
	--    end
	--end
	self.model:Brocast(ArenaEvent.ArenaHighestRank,data)
end

--请求领取历史最高奖励
function ArenaController:RequstHighestRankFetch(id)
	local pb = self:GetPbObject("m_arena_highest_rank_fetch_tos");
	pb.id = id
	self:WriteMsg(proto.ARENA_HIGHEST_RANK_FETCH, pb);
end

function ArenaController:HandleHighestRankFetch()
	local data = self:ReadMsg("m_arena_highest_rank_fetch_toc");
	table.insert(self.model.highestRankFetch,data.id)
	--  self.model.curRank
	self:RequstRedPoineInfo()
	self.model:Brocast(ArenaEvent.ArenaLqHighestRank,data)
end


--请求排名奖励信息
function ArenaController:RequstArenaRank()
	local pb = self:GetPbObject("m_arena_rank_tos");
	self:WriteMsg(proto.ARENA_RANK, pb);
end


function ArenaController:HandleArenaRank()
	local data = self:ReadMsg("m_arena_rank_toc");
	self.model.isRankReward = data.is_fetch
	self.model:Brocast(ArenaEvent.ArenaRankFetch)
end



--领取排行奖励
function ArenaController:RequstRankfetch()
	local pb = self:GetPbObject("m_arena_rank_fetch_tos");
	self:WriteMsg(proto.ARENA_RANK_FETCH, pb);
end

function ArenaController:HandleArenaRankFetch()
	local data = self:ReadMsg("m_arena_rank_toc");
	self.model.isRankReward = data.is_fetch
	self:RequstRedPoineInfo()
	self.model:Brocast(ArenaEvent.ArenaLqRankFetch)
end

--大神奖励信息
function ArenaController:RequstTopRank()
	local pb = self:GetPbObject("m_arena_top_rank_tos");
	self:WriteMsg(proto.ARENA_TOP_RANK, pb);
	
end

function ArenaController:HandleTopRank()
	local data = self:ReadMsg("m_arena_top_rank_toc");
	self:RequstRedPoineInfo()
	--self.model.isBigGodReward =  data.is_fetch
	self.model:Brocast(ArenaEvent.ArenaBigGodFetch)
end

--领取大神奖励
function ArenaController:RequstTopRankfetch()
	local pb = self:GetPbObject("m_arena_top_rank_fetch_tos");
	self:WriteMsg(proto.ARENA_TOP_RANK_FETCH, pb);
end


function ArenaController:HandleTopRankfetch()
	local data = self:ReadMsg("m_arena_top_rank_fetch_toc");
	self.model.isBigGodReward = data.is_fetch
	self:RequstRedPoineInfo()
	self.model:Brocast(ArenaEvent.ArenaLqBigGodFetch)
end

function ArenaController:RequstRedPoineInfo()
	local pb = self:GetPbObject("m_arena_notice_tos");
	--print2("请求红点信息")
	self:WriteMsg(proto.ARENA_NOTICE, pb);
end

function ArenaController:HandleRedPoineInfo()
	local data = self:ReadMsg("m_arena_notice_toc");
	self.model.isRankReward = data.rank --是否有每日奖励
	self.model.isHightReward = data.high_rank -- 突破奖励
	self.model.isChallenge = data.challenge -- 是否有挑战次数
	self.model.isBigGodReward = data.top_rank  --是可以领大神奖励
	self.model.isTopChallenge = data.top_challenge --是否有大神挑战次数
	self.model.curRank = data.cur_rank
	--self.model.dayFirst = Constant.IsFirstLanding
	--if Constant.IsFirstLanding then
	--	--
	--	--end
	if self.model.curRank <= 50 then
		if self.model.curRank == 0 then
			if Constant.IsFirstLanding and self.model.isFirstOpenBigPanel then
				self.model.bigRedPoint = true
			else
				self.model.bigRedPoint = false
			end
		else
			self.model.bigRedPoint = false
		end
	else
		if Constant.IsFirstLanding and self.model.isFirstOpenBigPanel  then
			self.model.bigRedPoint = true
		else
			self.model.bigRedPoint = false
		end
	end
	self:CheckRedPoint()
end

function ArenaController:CheckRedPoint()
	if self.model.isRankReward or self.model.isBigGodReward or  self.model.isHightReward
			or self.model.isChallenge or self.model.isTopChallenge or self.model.bigRedPoint then
		GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,39,true)
	else
		GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger,39,false)
	end


	if PeakArenaModel:GetInstance():GetRedPoint() or ActivityModel:GetInstance():GetActivity(10231)  or ActivityModel:GetInstance():GetActivity(10111)
	or CompeteModel:GetInstance():isRedPoint() then
		GlobalEvent:Brocast(MainEvent.ChangeRedDot,"athletics",true)
	else
		if self.model.isRankReward or self.model.isBigGodReward or  self.model.isHightReward
			or self.model.isChallenge or self.model.isTopChallenge or self.model.bigRedPoint then
			GlobalEvent:Brocast(MainEvent.ChangeRedDot,"athletics",true)
		else
			GlobalEvent:Brocast(MainEvent.ChangeRedDot,"athletics",false)
		end

	end
	GlobalEvent:Brocast(ArenaEvent.ArenaRedInfo)
end

function ArenaController:PeakArenaRedPoint(isRed)
	if isRed then
		GlobalEvent:Brocast(MainEvent.ChangeRedDot,"athletics",true)
	else
		self:CheckRedPoint()
	end
	GlobalEvent:Brocast(ArenaEvent.ArenaRedInfo)
end

function ArenaController:CompeteRedPoint(isRed)
	if isRed then
		GlobalEvent:Brocast(MainEvent.ChangeRedDot,"athletics",true)
	else
		self:CheckRedPoint()
	end
	GlobalEvent:Brocast(ArenaEvent.ArenaRedInfo)
end

















