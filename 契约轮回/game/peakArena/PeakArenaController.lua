---
--- Created by  Administrator
--- DateTime: 2019/7/31 16:18
---
PeakArenaController = PeakArenaController or class("PeakArenaController", BaseController)
local PeakArenaController = PeakArenaController
require('game.peakArena.RequirePeakArane')
function PeakArenaController:ctor()
    PeakArenaController.Instance = self
	
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function PeakArenaController:GetInstance()
    if not PeakArenaController.Instance then
        PeakArenaController.new()
    end
    return PeakArenaController.Instance
end



function PeakArenaController:GameStart()
	local function step()
		if OpenTipModel.GetInstance():IsOpenSystem(570,1) then
			self:Reques1v1Info()
		end

	end
	GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end




function PeakArenaController:AddEvents()
	

	local function callBack(id)
		--OpenTipModel:GetInstance():IsOpenSystem()
		--logError(id)
		--print2(OpenTipModel:GetInstance():IsOpenSystem(570,1),"1111")
		if id == "570@1" then
			self:Reques1v1Info()
		end
		--dump(OpenTipModel:GetInstance().syslist)
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, callBack);
	
	local function callBack()
		--logError(OpenTipModel:GetInstance():IsOpenSystem(570,1),"2222")
		if OpenTipModel:GetInstance():IsOpenSystem(570,1) then
			self:Reques1v1Info()
			--self.model.isReqRedPoint = true
		end
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.UpdateOpenFunction, callBack);

	
	self.events[#self.events + 1] = GlobalEvent:AddListener(PeakArenaEvent.OpenPeakArenaPanel, handler(self, self.OpenPeakArenaPanel));
	self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
	local function callBack(isShow,Id)
		if Id == 10125 or Id == 10126 then
			self:Reques1v1Info()
		end
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(ActivityEvent.ChangeActivity, callBack);
	local function callBack()
		if 	OpenTipModel.GetInstance():IsOpenSystem(570, 1) then
			self:Reques1v1Info()
		end
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.CrossDay, callBack);
end

function PeakArenaController:OpenPeakArenaPanel()
	lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 4);
end

function PeakArenaController:HandleSceneChange(sceneID)
	local config = Config.db_scene[sceneID]
	if not config then
		print2("不存在场景配置" .. tostring(sceneID));
		return
	end
	
	local curSceneId = SceneManager:GetInstance().last_scene_id
	local lastConfig = Config.db_scene[curSceneId]
	--if not lastConfig then
		--print2("不存在场景配置" .. tostring(curSceneId));
		--return
	--end
	if lastConfig then
		if lastConfig.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and lastConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_COMBAT1V1 then
			local  panel = lua_panelMgr:GetPanel(PeakArenaBattlePanel);
			if panel then
				panel:Close()
			end
			lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 4);
			self:ShowPanel(true)
		end
	end


	if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_COMBAT1V1 then
		--巅峰1v1
		lua_panelMgr:GetPanelOrCreate(PeakArenaBattlePanel):Open()
		self:ShowPanel(false)
		
		local  panel = lua_panelMgr:GetPanel(PeakArenaReadyPanel);
		if panel then
			panel:Close()
		end
		
	end
end

function PeakArenaController:ShowPanel(isShow)
	local  aPanel = lua_panelMgr:GetPanel(MainUIView)
	if aPanel then
		aPanel.main_top_left:SetVisible(isShow)
		aPanel.main_middle_left:SetVisible(isShow)
		aPanel.main_top_right:SetVisible(isShow)
	end
	--if aPanel then
		--aPanel:SetVisible(isShow)
	--end

	--local  bPanel = lua_panelMgr:GetPanel(MainMiddleLeft)
	--if bPanel then
		--bPanel:SetVisible(isShow)
	--end
	
	--local  cPanel = lua_panelMgr:GetPanel(MainTopRight)
	--if cPanel then
		--cPanel:SetVisible(isShow)
	--end
	
end

function PeakArenaController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
	self.pb_module_name = "pb_1605_combat1v1_pb"
	self:RegisterProtocal(proto.COMBAT1V1_INFO, self.Handle1v1Info);
	self:RegisterProtocal(proto.COMBAT1V1_MATCH_START, self.HandleMatchStart);
	self:RegisterProtocal(proto.COMBAT1V1_MATCH_CANCEL, self.HandleMatchCancel);
	self:RegisterProtocal(proto.COMBAT1V1_MATCH_SUCC, self.HandleMatchSucc);
	
	--self:RegisterProtocal(proto.COMBAT1V1_BATTLE, self.HandleBattleInfo);
	self:RegisterProtocal(proto.COMBAT1V1_BATTLE_RESULT, self.HandleResuleInfo);
	self:RegisterProtocal(proto.COMBAT1V1_BATTLE_START, self.HandleBattleStart);
	self:RegisterProtocal(proto.COMBAT1V1_JOIN_REWARD, self.HandleWinReward);
	self:RegisterProtocal(proto.COMBAT1V1_DAILY_REWARD, self.HandleDailyReward);
	self:RegisterProtocal(proto.COMBAT1V1_MERIT_REWARD, self.HandleMeritReward);
	self:RegisterProtocal(proto.COMBAT1V1_BUY_TIMES, self.HandleBuyTimes);
	self:RegisterProtocal(proto.COMBAT1V1_BATTLE_PREPARE, self.HandleBattlePrepare);
	
	
end


--面板信息
function PeakArenaController:Reques1v1Info()
	local pb = self:GetPbObject("m_combat1v1_info_tos");
	self:WriteMsg(proto.COMBAT1V1_INFO, pb);
end

function PeakArenaController:Handle1v1Info()
	local data = self:ReadMsg("m_combat1v1_info_toc");
	self.model.join_reward = data.join_reward
	self.model.merit_reward = data.merit_reward
	self.model.merit = data.merit
	self.model.score = data.score
	self.model.grade = data.grade
	self.model.daily_reward = data.daily_reward
	self.model.lastgrade = data.last_grade
	self.model.mode = data.mode
	self.model.remain_buy = data.remain_buy  --可购买次数
	--logError(data.remain_buy)
	self.model.remain_join = data.remain_join --可进入次数
	self.model.today_join = data.today_join --今日参与次数
	self:CheckRedPoint()
	self.model:Brocast(PeakArenaEvent.PeakArenaInfo,data)
end

function PeakArenaController:CheckRedPoint()
	local isRed = false
	if self.model.daily_reward == 1 then
		isRed = true
	end
	
	--local cfg = Config.db_combat1v1_merit_reward
	local cfg = self.model:GetMeritCfg()
	for i = 1, #cfg do
		if self.model:IsMeritReward(cfg[i].merit) == 0 then
			isRed = true
			break
		end
	end
	for k, v in pairs(self.model.join_reward) do
		if v == false then
			isRed = true
		end
	end
	
	if self.model.remain_join > 0 and (ActivityModel:GetInstance():GetActivity(10125) or ActivityModel:GetInstance():GetActivity(10126)) then
		isRed = true
	end
	
	self.model.isRedPoint = isRed
	GlobalEvent:Brocast(PeakArenaEvent.ShowRedPoint,isRed)
end

--匹配开始
function PeakArenaController:RequesMatchStart()
	local pb = self:GetPbObject("m_combat1v1_match_start_tos");
	
	self:WriteMsg(proto.COMBAT1V1_MATCH_START, pb);
end

function PeakArenaController:HandleMatchStart()
	local data = self:ReadMsg("m_combat1v1_match_start_toc");

	self.model:Brocast(PeakArenaEvent.MatchStart,data)
end

--取消匹配
function PeakArenaController:RequesMatchCancel()
	local pb = self:GetPbObject("m_combat1v1_match_cancel_tos");
	
	self:WriteMsg(proto.COMBAT1V1_MATCH_CANCEL, pb);
end

function PeakArenaController:HandleMatchCancel()
	local data = self:ReadMsg("m_combat1v1_match_cancel_toc");
	
	self.model:Brocast(PeakArenaEvent.MatchCancel,data)
end

--匹配成功
function PeakArenaController:HandleMatchSucc()
	local data = self:ReadMsg("m_combat1v1_match_succ_toc");
	
	self.model:Brocast(PeakArenaEvent.MatchSucc,data)
end



-- 加载完资源，进入副本后请求，前端此时处于等待对手阶段
function PeakArenaController:RequestBattlePrepare()
	local pb = self:GetPbObject("m_combat1v1_battle_prepare_tos");
	self:WriteMsg(proto.COMBAT1V1_BATTLE_PREPARE, pb);
end

function PeakArenaController:HandleBattlePrepare()
	local data = self:ReadMsg("m_combat1v1_battle_prepare_toc");
	--logError("12312313")
	self.model:Brocast(PeakArenaEvent.BattlePrepare,data)
end



-- 双方都进入后，推送倒计时，以及副本结束时间
function PeakArenaController:HandleBattleStart()
	local data = self:ReadMsg("m_combat1v1_battle_start_toc");
	
	self.model:Brocast(PeakArenaEvent.BattleStart,data)
end

--战斗结束
function PeakArenaController:HandleResuleInfo()
	local data = self:ReadMsg("m_combat1v1_battle_result_toc");
	self.model.score = data.score
	self.model.grade = data.grade
	lua_panelMgr:GetPanelOrCreate(PeakArenaEndPanel):Open(data)
	self.model:Brocast(PeakArenaEvent.ResuleInfo,data)
end


--领取场次奖励
function PeakArenaController:RequestWinReward(num)
	local pb = self:GetPbObject("m_combat1v1_join_reward_tos");
	pb.num = num
	self:WriteMsg(proto.COMBAT1V1_JOIN_REWARD, pb);
end


function PeakArenaController:HandleWinReward()
	local data = self:ReadMsg("m_combat1v1_join_reward_tos");
	self.model.join_reward[data.num] = true
	self:CheckRedPoint()
	self.model:Brocast(PeakArenaEvent.WinReward,data)
end

--领取每日奖励

function PeakArenaController:RequestDailyReward()
	local pb = self:GetPbObject("m_combat1v1_daily_reward_tos");
	self:WriteMsg(proto.COMBAT1V1_DAILY_REWARD, pb);
end

function PeakArenaController:HandleDailyReward()
	local data = self:ReadMsg("m_combat1v1_daily_reward_toc");
	self.model.daily_reward = 2
	self:CheckRedPoint()
	self.model:Brocast(PeakArenaEvent.DailyReward,data)
end


function PeakArenaController:RequestMeritReward(merit)
	local pb = self:GetPbObject("m_combat1v1_merit_reward_tos");
	pb.merit = merit
	self:WriteMsg(proto.COMBAT1V1_MERIT_REWARD, pb);
end


function PeakArenaController:HandleMeritReward()
	local data = self:ReadMsg("m_combat1v1_merit_reward_toc");
	table.insert(self.model.merit_reward,data.merit)
	self:CheckRedPoint()
	self.model:Brocast(PeakArenaEvent.MeritReward,data)
end


--够买次数
function PeakArenaController:RequestBuyTimes(num)
	local pb = self:GetPbObject("m_combat1v1_buy_times_tos");
	pb.num = num
	self:WriteMsg(proto.COMBAT1V1_BUY_TIMES, pb);
end

function PeakArenaController:HandleBuyTimes()
	local data = self:ReadMsg("m_combat1v1_buy_times_toc");
	--max_join
	--self.model.maxJoin = data.max_join
	self.model.remain_buy = data.remain_buy --可购买次数
	self.model.remain_join = data.remain_join 
	self:CheckRedPoint()
	self.model:Brocast(PeakArenaEvent.BuyTimes,data)
end