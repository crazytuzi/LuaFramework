require("game/fishing/fishing_data")
require("game/fishing/fishing_view")
require("game/fishing/fish_bait_view")
require("game/fishing/fish_succ_view")

FishingCtrl = FishingCtrl or BaseClass(BaseController)

function FishingCtrl:__init()
	if FishingCtrl.Instance ~= nil then
		print_error("[FishingCtrl]error:create a singleton twice")
	end
	FishingCtrl.Instance = self

	self.data = FishingData.New()
	self.view = FishingView.New(ViewName.FishingView)							-- 钓鱼面板

	self:RegisterAllProtocols()
end

function FishingCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	FishingCtrl.Instance = nil
end

function FishingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFishingUserInfo, "OnFishingUserInfo")
	self:RegisterProtocol(SCFishingCheckEventResult, "OnFishingCheckEventResult")
	self:RegisterProtocol(SCFishingGearUseResult, "OnFishingGearUseResult")
	self:RegisterProtocol(SCFishingEventBigFish, "OnFishingEventBigFish")
	self:RegisterProtocol(SCFishingTeamMemberInfo, "OnFishingTeamMemberInfo")
	self:RegisterProtocol(SCFishingFishInfo, "OnFishingFishInfo")
	self:RegisterProtocol(SCFishingRandUserInfo, "OnFishingRandUserInfo")
	self:RegisterProtocol(SCFishingScoreInfo, "OnFishingScoreInfo")

	self:RegisterProtocol(SCFishingStealResult, "OnFishingStealResult")
	self:RegisterProtocol(SCFishingGetFishBrocast, "OnFishingGetFishBrocast")
	self:RegisterProtocol(SCCrossFishingScoreRankList, "OnCrossFishingScoreRankList")
	self:RegisterProtocol(SCFishingScoreStageInfo, "OnFishingScoreStageInfo")
	self:RegisterProtocol(SCFishingStatusNotify, "OnFishingStatusNotify")
	self:RegisterProtocol(SCFishingStealInfo, "OnFishingStealInfo")
	self:RegisterProtocol(SCFishingConfirmResult, "OnFishingConfirmResult")

	self:RegisterProtocol(CSFishingOperaReq)

end

function FishingCtrl:OnFishingStealInfo(protocol)
	local fish_cfg = FishingData.Instance:GetFishingFishCfgByType(protocol.fish_type)
	if fish_cfg then
		local str = string.format(Language.Fishing.LabelFishingBeSteal, protocol.cur_score_stage, fish_cfg.name)
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end

function FishingCtrl:OnFishingUserInfo(protocol)
	local info = self.data:GetFishingUserInfo()																	--鱼变换时刷新鱼篓
	if info.fish_num_list then
		for k, v in pairs(protocol.fish_num_list) do
			if v ~= info.fish_num_list[k] or (info.news_list and #info.news_list >= 1 ) then
				self:Flush("flush_creel_view")
			end
		end
	end

	self.data:SetFishingUserInfo(protocol)
	if self.view:IsOpen() then
		self.view:GetMagicCount()
	end
	self:Flush()

	-- if protocol.fishing_status == FISHING_STATUS.FISHING_STATUS_CAST then
	-- 	self:Flush("flush_fishing")
	-- end
	if protocol.fishing_status == FISHING_STATUS.FISHING_STATUS_HOOKED then
		self:Flush("flush_rod_time")
	end

	self:Flush("flush_fishing_area")

end

function FishingCtrl:OnFishingCheckEventResult(protocol)
	self.data:SetFishingCheckEventResult(protocol)
	self:Flush("flush_fish_succ")

end

function FishingCtrl:OnFishingGearUseResult(protocol)
	self.data:SetFishingGearUseResult(protocol)
	self:Flush("flush_use_gear")
end

function FishingCtrl:OnFishingEventBigFish(protocol)
	self.data:SetFishingEventBigFish(protocol)
	
end

function FishingCtrl:OnFishingTeamMemberInfo(protocol)
	self.data:SetFishingTeamMemberInfo(protocol)
	
end

function FishingCtrl:OnFishingFishInfo(protocol)
	self.data:SetFishingFishInfo(protocol)
	
end

function FishingCtrl:OnFishingRandUserInfo(protocol)
	self.data:SetFishingRandUserInfo(protocol)
	
end

function FishingCtrl:OnFishingScoreInfo(protocol)
	-- body
end

function FishingCtrl:OnFishingStealResult(protocol)
	self.data:SetFishingStealResult(protocol)
	if protocol.is_succ == 1 then
		self:Flush("flush_fish_steal")
	end
end

function FishingCtrl:OnFishingGetFishBrocast(protocol)
	self.data:SetFishingGetFishBrocast(protocol)
end

function FishingCtrl:OnCrossFishingScoreRankList(protocol)
	self.data:SetCrossFishingScoreRankList(protocol)
	self.view:Flush("flush_table_view")
end

function FishingCtrl:OnFishingScoreStageInfo(protocol)
	self.data:SetFishingScoreStageInfo(protocol)

	self:Flush("flush_table_view")
end

function FishingCtrl:OnFishingStatusNotify(protocol)

-- 钓鱼的状态
-- FISHING_STATUS = {
-- 	FISHING_STATUS_IDLE = 0,							-- 未钓鱼，即不在钓鱼界面
-- 	FISHING_STATUS_WAITING = 1,							-- 在钓鱼界面等待抛竿
-- 	FISHING_STATUS_CAST = 2,							-- 已经抛竿，等待触发事件
-- 	FISHING_STATUS_HOOKED = 3,							-- 已经触发事件，等待拉杆
-- 	FISHING_STATUS_PULLED = 4,							-- 已经拉杆，等待玩家做选择
-- }
	


	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		local main_part = obj.draw_obj:GetPart(SceneObjPart.Main)	
		local role_id = obj:GetVo().role_id	

		if self.view.fishing_effect_list[role_id] ~= nil then						--特效删除
				self.view:RemoveFishingEffect(role_id)
		end

		if obj:IsFishing() then
			if protocol.status == FISHING_STATUS.FISHING_STATUS_HOOKED then
				main_part:SetInteger("status", ActionStatus.ShangGou)					--上钩
			end
			if protocol.status == FISHING_STATUS.FISHING_STATUS_CAST then
				main_part:SetInteger("status", ActionStatus.ShuaiGan)					--甩杆
				if obj:IsMainRole() then
					self:Flush("flush_fishing_lagan_btn")
				end
				local goal = self.data:GetFishingGoal(role_id)							--特效点
				if goal then	
					if not self.game_root then
						self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
					end
					if self.view.fishing_effect_list then
						self.view.fishing_effect_list[role_id] = AsyncLoader.New(self.game_root.transform)					
						local call_back = function(effect_obj)
							if effect_obj then
								local root = obj:GetRoot()
								if root and not IsNil(root.gameObject) then
									effect_obj.transform.localPosition = goal
								end
							end
						end
						self.view.fishing_effect_list[role_id]:Load("effects2/prefab/misc/diaoyu_prefab", "diaoyu", call_back)
					end
				end
			end

			if protocol.status == FISHING_STATUS.FISHING_STATUS_PULLED  then			--收杆
				main_part:SetInteger("status", ActionStatus.ShouGan)			
			end

			if protocol.status == FISHING_STATUS.FISHING_STATUS_IDLE then

				main_part:SetInteger("status", ActionStatus.Idle)						--等待	
				table.remove(self.data.fishing_goal, role_id)
			end

			if protocol.status == FISHING_STATUS.FISHING_STATUS_WAITING then
				main_part:SetInteger("status", ActionStatus.Idle)						--等待
				if obj:IsMainRole() then
					self:Flush("flush_fishing_paogan_btn")
				end	

				local real_x, real_y = obj:GetRealPos()								--人物世界坐标
				local real_vec = u3d.vec2(real_x, real_y)							--世界坐标转化成表
				local target_x, target_y = 0, 0
				local is_water_way = false												
				local length = 5													--半径长度
				local flag = math.random(2)											--取随机方向遍历角度(1为右边，-1为左边)
				if flag == 2 then
					flag = -1
				end
				local pos = obj:GetRoot().transform.position
				local dir = obj:GetRoot().transform.forward					
				local dirvec = u3d.vec2(dir.x, dir.z)								--方向坐标转化成表
				local vec = u3d.v2Add(real_vec, u3d.v2Mul(dirvec, length))			--获得目标位置
				for i = 1, 12 do
					-- target_x, target_y = AStarFindWay:GetLineEndXY( x, y, vec.x, vec.y, GridCellType.Fishing)
					target_x, target_y = GameMapHelper.WorldToLogic(vec.x, vec.y)	--世界坐标转化成逻辑坐标（传参是逻辑坐标）
					is_water_way = AStarFindWay:IsWaterWay(target_x, target_y)			--求目标是否为水区域（参数为逻辑坐标）
					if is_water_way then
						local goal = u3d.vec3(vec.x, pos.y + 0.1, vec.y)
						self.data:SetFishingGoal(role_id, goal)
						break
					end
					dirvec = u3d.v2Rotate(dirvec, 30, flag)							--往flag方向转30度角
					vec = u3d.v2Add(real_vec, u3d.v2Mul(dirvec, length))
				end

				if is_water_way then
					obj:SetDirectionByXY(target_x, target_y)
				end
			end
		end
		
		if obj:IsMainRole() then
			-- 自动钓鱼状态的时候
			local fishing_status = FishingData.Instance:GetAutoFishing()
			if fishing_status == 1 then 
				local fish_bait_cfg = FishingData.Instance:GetFishingFishBaitCfgByType(0)
				local fish_bait = FishingData.Instance:GetBaitFishing(0)
				if fish_bait <= 0 then																							--没有鱼饵时结束
					FishingData.Instance:SetAutoFishing(0)
					FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
				elseif protocol.status == FISHING_STATUS.FISHING_STATUS_WAITING then
					-- 使用0普通鱼饵
					FishingCtrl.Instance:SendFishing(0)
				end
			end
		end
	end
end

function FishingCtrl:OnFishingConfirmResult(protocol)
	self.data:SetFishingConfirmResult(protocol)
	self:Flush("flush_fish_result")
end

function FishingCtrl:SendFishingOperaReq(opera_type, param1, param2, param3)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSFishingOperaReq)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param2 or 0
	protocol_send:EncodeAndSend()
end



 -- -- 钓鱼类型
 -- 2333: FISHING_OPERA_REQ_TYPE = {
 -- 2334: 	FISHING_OPERA_REQ_TYPE_START_FISHING = 0,			-- 开始钓鱼（进入钓鱼界面）
 -- 2335: 	FISHING_OPERA_REQ_TYPE_CASTING_RODS = 1,			-- 抛竿 param1是鱼饵类型
 -- 2336: 	FISHING_OPERA_REQ_TYPE_PULL_RODS = 2,				-- 收竿
 -- 2337: 	FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT = 3,			-- 确认本次钓鱼事件
 -- 2338: 	FISHING_OPERA_REQ_TYPE_USE_GEAR = 4,				-- 使用法宝 param是法宝类型
 -- 2339: 	FISHING_OPERA_REQ_TYPE_BIG_FISH_HELP = 5,			-- 帮忙拉大鱼
 -- 2340: 	FISHING_OPERA_REQ_TYPE_STOP_FISHING = 6,			-- 停止钓鱼（离开钓鱼界面）
 -- 2341: 	FISHING_OPERA_REQ_TYPE_AUTO_FISHING = 7,			-- 自动钓鱼 param1:0取消状态1设置状态，param2状态类型
 -- 2342: 	FISHING_OPERA_REQ_TYPE_RAND_USER = 8,				-- 随机角色请求
 -- 2343: 	FISHING_OPERA_REQ_TYPE_BUY_STEAL_COUNT = 9,			-- 购买偷鱼次数
 -- 2344: 	FISHING_OPERA_REQ_TYPE_RANK_INFO = 10,				-- 请求钓鱼排行榜信息
 -- 2345: 	FISHING_OPERA_REQ_TYPE_STEAL_FISH = 11,				-- 偷鱼请求 param1 是被偷玩家rold_id
 -- 2346: 	FISHING_OPERA_REQ_TYPE_EXCHANGE = 12,				-- 兑换请求 param1：兑换组合下标
 -- 2347: 	FISHING_OPERA_REQ_TYPE_BUY_BAIT = 13,				-- 购买鱼饵 param1: 购买鱼饵类型 param2为购买数量
 -- 2348  }
 -- 2349  

-- 钓鱼抛竿 param1是鱼饵类型
function FishingCtrl:SendFishing(param1)
	self:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_CASTING_RODS, param1)
end

-- 钓鱼兑换
function FishingCtrl:SendFishingExchange(param1)
	self:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_EXCHANGE, param1)
end

-- 购买鱼饵 param1: 购买鱼饵类型 param2为购买数量
function FishingCtrl:SendBuyFishBait(param1, param2)
	self:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_BUY_BAIT, param1, param2)
end

-- 自动钓鱼 param1:0取消状态1设置状态，param2状态类型
function FishingCtrl:SendAutoFishing(param1, param2)
	self:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_AUTO_FISHING, param1, param2)
end

-- 使用法宝 param是法宝类型
function FishingCtrl:SendUseGear(param1)
	self:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_USE_GEAR, param1)
end

-- 刷新View方法
function FishingCtrl:Flush(key, value_t)
	if self.view then
		self.view:Flush(key, value_t)
	end
end

function FishingCtrl:OnOpenCreelHandler()
	if self.view then
		self.view:OnOpenCreelHandler()
	end
end
