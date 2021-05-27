require("scripts/game/guaji/guaji_data")
require("scripts/game/guaji/guaji_function")
require("scripts/game/guaji/guaji_atk")
require("scripts/game/guaji/guaji_about_event")
require("scripts/game/guaji/guaji_behavior")

-- 挂机
GuajiCtrl = GuajiCtrl or BaseClass(BaseController)

function GuajiCtrl:__init()
	if GuajiCtrl.Instance ~= nil then
		ErrorLog("[GuajiCtrl] attempt to create singleton twice!")
		return
	end
	GuajiCtrl.Instance = self

	self.last_update_time = 0
	self.last_pick_time = 0
	self.on_arrive_func = BindTool.Bind(self.OnArrive, self)
	self.AtkInfo = {}
	
	self:RegisterAllEvents()
end

function GuajiCtrl:__delete()
	GuajiCtrl.Instance = nil

	Runner.Instance:RemoveRunObj(self)
	self.scene = nil

	GlobalTimerQuest:CancelQuest(self.delay_move_timer)
	self.delay_move_timer = nil

	GlobalTimerQuest:CancelQuest(self.delay_arrive_timer)
	self.delay_arrive_timer = nil
end

-- 每帧的更新
function GuajiCtrl:Update(now_time, elapse_time)
	-- 玩家操作时，判断是否做任务以及配置主线副本id有物品时
	if not MoveCache.is_opting_me then
		if GuideCtrl.Instance.is_auto_task and not Scene.Instance:GetIsTask() then
			local fallitem_obj = self.scene:SelectMinRemindFallItem()
			if nil ~= fallitem_obj then
				if Status.NowTime >= self.last_pick_time + Config.PICK_ITEM_CD then
					self:OnSelectObj(fallitem_obj, "auto_pickup")
				end
				return
			end
		end
	end

	-- if GuajiCache.guaji_type == GuajiType.Auto then
	-- 	-- 玩家正在挖掘
	-- 	if DiamondPetCtrl.Instance:IsExcavating() then
	-- 		return
	-- 	else
	-- 		local excavate_boss_list = DiamondPetCtrl.Instance:GetExcavateBossList()
	-- 		for obj_id, excavate_boss_view in pairs(excavate_boss_list) do
	-- 			if excavate_boss_view.parent then
	-- 					local obj = Scene.Instance:GetObjectByObjId(obj_id)
	-- 					MoveCache.end_type = MoveEndType.ExcavateBoss
	-- 					self:MoveToObj(obj, 0, 0)
	-- 					DiamondPetCtrl.Instance:SetObjId(obj_id)
	-- 				return
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- 自动捡物品
	if self:CanUpdatePickFallItem() then
		local fallitem_obj = self.scene:SelectMinRemindFallItem()
		if nil ~= fallitem_obj then
			if Status.NowTime >= self.last_pick_time + Config.PICK_ITEM_CD then
				self:OnSelectObj(fallitem_obj, "auto_pickup")
			end
			return
		end
	end

	self:UpdateProfAutoSkill()
	self:StrictCheckAtkOpt()
	self:UpdateAuto()
	self:UpdateHalfAuto()
end

-- 自动战斗逻辑
local Behavior = require("scripts/game/guaji/behavior_test")
function GuajiCtrl:UpdateAuto(ignore_check_move)
	local main_role = self.scene:GetMainRole()
	if self.AtkInfo.is_valid or (GuajiCache.guaji_type ~= GuajiType.Auto) or MoveCache.is_player_opting or nil == main_role or not main_role:IsAtkEnd() then
		return
	end

	if not ignore_check_move and (MoveCache.is_valid or main_role:IsMove()) then
		return
	end

	--未知暗殿 优先进入篝火 获取经验
	if Behavior.IsInWeiZhiAnDian() then
		if Behavior.IsHaveSoakPoint() then
			Behavior.SoakPoint()
			return
		end
	end

	--自动击杀怪物 
	--指定怪物id的战斗 如做任务-击杀xx数量怪物
	if Behavior.IsNeedAutoKillMonster() then
		local bool = Behavior.FindKillMonster(GuajiCache.monster_id)
		-- 找不到怪就不跳出
		if bool then
			return
		else
			GuajiCache.monster_id = 0
		end
	end

	--自动寻找攻击对象
	local target_obj = self.scene:GetObjectByObjId(GuajiCache.old_target_obj_id)
	if target_obj and self.scene:IsEnemy(target_obj) then
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "select")
	elseif GuajiCtrl.CanAutoBoss() and self.scene:GetMinDisBoss() > 0 then
		local boss, target_x, target_y = self.scene:GetMinDisBoss()
		target_obj = self.scene:SelectMinDisMonster(boss, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
		if nil == target_obj then
			MoveCache.param1 = boss
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(self.scene:GetSceneId(), target_x, target_y, 1)
			return
		end
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "select")
	else
		target_obj = self:SelectAtkTarget(false)
	end

	if nil ~= target_obj then
		self:DoAttackTarget(target_obj)
	else
		-- 找不到对象，疯狂乱跑
		if GuajiCache.guaji_type == GuajiType.Auto
			and GuajiCache.monster_id == 0
			--and Scene.Instance:GetFuBenId() ~= 0
			and main_role:IsStand() 
			and main_role:CanDoMove() then

			self:AutoMove()
		end
	end

	----动作
	--已定义

	----行为
	--自动攻击场景boss
	local function FindOneToAttackMinDisBoss()
		if self.scene:GetMinDisBoss() <= 0 then return end
		local boss, target_x, target_y = self.scene:GetMinDisBoss()
		local target_obj = self.scene:SelectMinDisMonster(boss, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
		if nil == target_obj then
			MoveCache.param1 = boss
			GuajiCtrl.Instance:MoveToPos(self.scene:GetSceneId(), target_x, target_y, 1)
			return
		end
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "select")

		self:DoAttackTarget(target_obj)
	end

	--和某一对象对话
	-- local function FindOneToTask()
	-- 	--与boss之家npc对话 并进入下一层
	-- 	local cfg = Scene.Instance:GetSceneServerConfig(scene_id)
	-- 	self:MoveToPos(self.scene:GetSceneId(), cfg.npc[1].posx, cfg.npc[1].posy, 1)
	-- 	local npc = self.scene:GetNpcByNpcId(86)
	-- 	if nil ~= npc then
	-- 		self:OnSelectObj(npc, "select")
	-- 		TaskCtrl.SendNpcTalkReq(npc:GetObjId(), "VipYuanBaoScene")
	-- 	end
	-- end


	--是否在boss之家1-4层
	local function IsInBossHomeSomeLayer()
		-- boss之家1-4层 场景id 56-59
		if Scene.Instance:GetSceneId() == 56 
			or Scene.Instance:GetSceneId() == 57 
			or Scene.Instance:GetSceneId() == 58 
			or Scene.Instance:GetSceneId() == 59
			then
			return true
		end 
	end

	----决策 不同地图的逻辑处理
	--boss之家1-4层 自动寻找boss
	--选中人物后优先攻击人物
	if IsInBossHomeSomeLayer() then
		if target_obj and target_obj.obj_type == SceneObjType.Role then return end
		FindOneToAttackMinDisBoss()
	end
end

function GuajiCtrl:UpdateHalfAuto()
	local main_role = self.scene:GetMainRole()
	if self.AtkInfo.is_valid or (GuajiCache.guaji_type ~= GuajiType.HalfAuto) or MoveCache.is_player_opting or nil == main_role or not main_role:IsAtkEnd() then
		return
	end

	if (MoveCache.is_valid or main_role:IsMove()) then
		return
	end

	local target_obj = GuajiCache.target_obj
	if nil == target_obj or not self.scene:CheckObjRefIsValid(GuajiCache.target_obj, GuajiCache.target_obj_id) or (not target_obj:IsRole() and not self.scene:IsEnemy(target_obj)) then
		self:SetGuajiType(GuajiType.None)
		return
	end

	self:DoAttackTarget(target_obj)
end

-- 挂机类型
function GuajiCtrl:SetGuajiType(guaji_type)
	if GuajiCache.guaji_type ~= guaji_type then
		GuajiCache.guaji_type = guaji_type

		-- if GuajiCache.guaji_type ~= GuajiType.Auto or GuajiCache.guaji_type ~= GuajiType.HalfAuto then
		if GuajiCache.guaji_type == GuajiType.None then
			GuajiCache.monster_id = 0
		end

		GlobalEventSystem:Fire(OtherEventType.GUAJI_TYPE_CHANGE, guaji_type)
	end
end

-- 清除所有操作信息
function GuajiCtrl:ClearAllOperate(reason)
	reason = reason or ClearGuajiCacheReason.None

	-- 跨场景移动信息不清除
	if reason == ClearGuajiCacheReason.SceneChange and MoveCache.cross_scene then
		MoveCache.cross_scene = false
		return
	end

	local clear_end_type = MoveCache.end_type
	MoveCache.is_valid = false
	MoveCache.cross_scene = false
	MoveCache.end_type = nil
	if self.AtkInfo.atk_source ~= ATK_SOURCE.PLAYER then
		self:ClearAtkOperate()
	end

	self:SetGuajiType(GuajiType.None)

	-- 被中断清除后的回调
	if MoveCache.be_clear_callback then
		MoveCache.be_clear_callback(reason, clear_end_type)
	end
end

function GuajiCtrl:CanUpdatePickFallItem()
	-- 玩家正操作移动
	if MoveCache.is_player_opting then
		return false
	end

	-- 正在去捡物品
	if MoveCache.is_valid and MoveCache.end_type == MoveEndType.PickItem and not self.scene:GetMainRole():IsAtkEnd() then
		return false
	end
	-- 挂机中
	if GuajiCache.guaji_type == GuajiType.Auto or GuajiCache.guaji_type == GuajiType.Monster then
		return self.scene:CanPickFallItem()
	end

	return false
end

function GuajiCtrl.CanAutoPick()
	return true
end

function GuajiCtrl.CanAutoBoss()
	return false
end
