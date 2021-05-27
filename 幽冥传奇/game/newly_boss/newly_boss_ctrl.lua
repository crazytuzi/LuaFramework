require("scripts/game/newly_boss/newly_boss_data")
require("scripts/game/newly_boss/newly_boss_view")

NewlyBossCtrl = NewlyBossCtrl or BaseClass(BaseController)

function NewlyBossCtrl:__init()
	if NewlyBossCtrl.Instance then
		ErrorLog("[NewlyBossCtrl]:Attempt to create singleton twice!")
	end
	NewlyBossCtrl.Instance = self
	
	self.data = NewlyBossData.New()
	self.view = NewlyBossView.New(ViewDef.NewlyBossView)
	self:RegisterAllProtocols()

	self.is_auto = false

	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))

	self.map_labels = {}
	for i, v in ipairs(MapLabels or {}) do
		local scene_id = v.sceneId
		if scene_id then
			self.map_labels[scene_id] = v
		end
	end
end

function NewlyBossCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil
	
	NewlyBossCtrl.Instance = nil

	GlobalEventSystem:UnBind(self.scene_change)
	self.scene_change = nil

	if nil ~= self.eh_move_end then
		GlobalEventSystem:UnBind(self.eh_move_end)
		self.eh_move_end = nil
	end
end

function NewlyBossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTumoAddTime, "OnTumoAddTime")

	self:RegisterProtocol(SCReXueBossRanks, "OnReXueBossRanks")
	self:RegisterProtocol(SCReXueBossScore, "OnReXueBossScore")
	self:RegisterProtocol(SCReXueBossState, "OnReXueBossState")

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanOnChiyouShi)

end

function NewlyBossCtrl:RecvMainRoleInfo()

end

function NewlyBossCtrl.SendChiYouReq(fubenId)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPersonalBossSweep)
	protocol.fuben_id = fubenId
	protocol:EncodeAndSend()
end

function NewlyBossCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.CanOnChiyouShi then
		return self.data:RemindChiyouNum()
	end
end

function NewlyBossCtrl:OnTumoAddTime(protocol)
	self.data:SetTumoAddTime(protocol)
	CrossServerCtrl.Instance:OnCrossTumoAddTime(protocol)
end

-- 热血霸者排行
function NewlyBossCtrl:OnReXueBossRanks(protocol)
	self.data:SetReXueBossRankList(protocol.ranks)
end

-- 热血霸者积分
function NewlyBossCtrl:OnReXueBossScore(protocol)
	self.data:SetReXueBossInfo{rank = protocol.rank, score = protocol.score}
end

-- 热血霸者状态
function NewlyBossCtrl:OnReXueBossState(protocol)
   self.data:OnReXueBossStateChange(protocol.boss_state)
end

-- 获取是否寻路状态
function NewlyBossCtrl:GetChange(vis)
	self.is_auto = vis
end

function NewlyBossCtrl:GetMapLabels()
	return self.map_labels or {}
end

-- 野外boss场景变化寻路
function NewlyBossCtrl:SceneChange()
	if self.is_auto then
		local scene = Scene.Instance:GetSceneId()
		local is_gj = 0
		local map_labels = NewlyBossCtrl.Instance:GetMapLabels()
		if map_labels[scene] then
			if Scene.Instance:GetMinDisBoss() <= 0 then return end
			local boss, target_x, target_y = Scene.Instance:GetMinDisBoss()
			local target_obj = Scene.Instance:SelectMinDisMonster(boss, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
			if nil == target_obj then
				MoveCache.param1 = boss
				GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), target_x, target_y, 1)
				-- return
			end

			if self.eh_move_end then
				GlobalEventSystem:UnBind(self.eh_move_end)
				self.eh_move_end = nil
			end

			self.eh_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, function ()
				target_obj = Scene.Instance:SelectMinDisMonster(boss, COMMON_CONSTS.SELECT_OBJ_DISTANCE)
				if target_obj then
					GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, "select")
					if is_gj == 0 then
						GuajiCtrl.Instance:DoAttackTarget(target_obj)
						is_gj = 1
					end
				end

				if self.eh_move_end then
					GlobalEventSystem:UnBind(self.eh_move_end)
					self.eh_move_end = nil
				end
			end)
		end
		self.is_auto = false
	end
end