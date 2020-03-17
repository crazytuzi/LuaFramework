CurrentSceneScript = {}
CurrentSceneScript.Humans = {}
CurrentSceneScript.Scene = nil

-----------------------------------------------------------
CurrentSceneScript.MonPos = {
	{x=9, z=45}
}

-- 怪物波数
CurrentSceneScript.Waves = 0
-- 怪物总波数
CurrentSceneScript.total_waves = 0
-- 挑战每波怪数量
CurrentSceneScript.kill_monster = 0
-- 战场倒计时
CurrentSceneScript.TimerTid = 0
-- 当前挑战层数
CurrentSceneScript.Layer = 0
-- 总波数
CurrentSceneScript.total_waves = 0
-- 本波总怪物数
CurrentSceneScript.total_monster = 0
-- 本波怪ID
CurrentSceneScript.monster_id = 0
-- 本层挑战时间
CurrentSceneScript.time_limit = 0
-- 挑战状态 0:ready 1:fighting 2:over 进入over状态三种情况 1:玩家杀死所有怪胜利 2:时间到玩家失败 3:玩家退出
CurrentSceneScript.state = 0
CurrentSceneScript.fail_timer_tid = 0
CurrentSceneScript.box_timer_tid = 0
CurrentSceneScript.box_dir = 1.5 --宝箱朝向
-- 刷怪delay
CurrentSceneScript.delay_tid = 0
function CurrentSceneScript:Startup()
	self.SModScript = self.Scene:GetModScript()
	_RegSceneEventHandler(SceneEvents.HumanEnterWorld,"OnHumanEnter")
	_RegSceneEventHandler(SceneEvents.HumanLeaveWorld, "OnHumanLeave")
	_RegSceneEventHandler(SceneEvents.MonsterKilled,"OnMonsterKilled")
end

function CurrentSceneScript:Cleanup() 
    if self.fail_timer_tid > 0 then
		self.SModScript:CancelTimer(self.fail_timer_tid)
		self.fail_timer_tid = 0
	end
	if self.TimerTid > 0 then
		self.SModScript:CancelTimer(self.TimerTid)
		self.TimerTid = 0
	end

	if self.box_timer_tid > 0 then
		self.SModScript:CancelTimer(self.box_timer_tid)
		self.box_timer_tid = 0
	end
end

function CurrentSceneScript:OnHumanEnter(human)
	--human:GetModLingshouMudi():OnEnterResult()
	--print("------------OnHumanEnter-----------" .. self.state)
	if self.state ~= 0 then
		print("---state Error---" .. self.state)
	end
	-- 状态 ready->fighting
	self.state = 1
	self.Layer = human:GetModLingshouMD():GetLayer()
	self.time_limit = LingshoumudiConfig[tostring(self.Layer)]['time']
	self:StartWave()
	self.TimerTid = self.SModScript:CreateTimer(self.time_limit, "TimeEnd")
end

function CurrentSceneScript:OnHumanLeave(human)
	--print("------------OnHumanLeave-----------" .. self.state)
	if self.state ~= 2 then
	-- 玩家在战斗中离开,直接进入over 
		self:Over(1)
	end

	if self.fail_timer_tid ~= 0 then
		self.SModScript:CancelTimer(self.fail_timer_tid)
		self.fail_timer_tid = 0
	end

	if self.TimerTid ~= 0 then
		self.SModScript:CancelTimer(self.TimerTid)
		self.TimerTid = 0
	end

	if self.box_timer_tid ~= 0 then
		self.SModScript:CancelTimer(self.box_timer_tid)
		self.box_timer_tid = 0
	end

end

function CurrentSceneScript:TimeEnd()
	if self.state ~= 1 then
		print("TimeEnd state error" .. self.state)
	end
	self:Over(1)

	-- 挑战失败进入30s倒计时
	self.fail_timer_tid = self.SModScript:CreateTimer(30, "KickOff")
end

function CurrentSceneScript:KickOff( )
	-- 失败30s无动作T出去;
	if self.state ~= 3 then 
		return 
	end	
	--[[ 倒计时over了玩家自己退出请求,服务器先不T人了吧
	for k,v in pairs(self.Humans) do
		v:GetModLingshouMD():Quit()
	end
	--]]
end


function CurrentSceneScript:OnMonsterKilled()
	self.kill_monster = self.kill_monster + 1
	-- 通知客户端还有多少怪在场上
	for k,v in pairs(self.Humans) do
		v:GetModLingshouMD():SendWaveInfoToClient(self.monster_id, self.total_monster - self.kill_monster, self.Waves)
	end
	--	全杀光了开始下一波
	if self.kill_monster >= tonumber(self.total_monster) then
		if self.Waves < self.total_waves then
			self.delay_tid = self.SModScript:CreateTimer(2, "StartWave")
		else
			self:StartWave()
		end
	end
end


function CurrentSceneScript:StartWave()
	self.Waves = self.Waves + 1
	self.kill_monster = 0

	if self.Waves > self.total_waves and self.total_monster ~= 0 then
		self:Over(0)
	else
		-- 初始化本波信息
		self:InitWaveInfo()
		-- 通知客户端本波信息
		for k,v in pairs(self.Humans) do
			v:GetModLingshouMD():SendWaveInfoToClient(self.monster_id, self.total_monster, self.Waves)
		end
		-- 生成怪物
		self:CreateMonster()
	end
end

function CurrentSceneScript:Over(res)
	
	if self.state == 2 then
		-- 已结束了
		print("state Error" .. self.state)
		return
	end
	-- 所有怪定身且无敌
	self.Scene:RemoveAllMonster()
	-- 状态 fighting->over
	self.state = 2
	-- 停止计时
	if res == 0 then
		-- 胜利停止计时
		if self.TimerTid ~= 0 then
			self.SModScript:CancelTimer(self.TimerTid)
			self.TimerTid = 0
		end

		--倒计时生成宝箱
		self.box_timer_tid = self.SModScript:CreateTimer(3, "ChallengeBox")
	else
		if self.delay_tid ~= 0 then 
			self.SModScript:CancelTimer(self.delay_tid)
			self.delay_tid = 0
		end
	end

	for k,v in pairs(self.Humans) do
		v:GetModLingshouMD():ChallengeResult(self.Layer, res)
	end
end


function CurrentSceneScript:InitWaveInfo()
	--print("InitWaveInfo" .. self.Layer)
	--print(LingshoumudiConfig[tostring(self.Layer)])
	--if LingshoumudiConfig[tostring(self.Layer)] == nil then
	--	return
	--end
	local layer_info = split(LingshoumudiConfig[tostring(self.Layer)]['monster'], '#')
	local monster_info = split(tostring(layer_info[self.Waves]), ',')
	self.monster_id = monster_info[1];
	self.total_monster =  monster_info[2];
	self.total_waves = getTableLen(layer_info)
	--print("monster_id" .. self.monster_id .. " total_monster:" .. self.total_monster .. "total_waves:" .. self.total_waves)
end

function CurrentSceneScript:CreateMonster()
	print("CreateMonster" .. self.monster_id .. "monster_num" .. self.total_monster)
	self.Scene:GetModSpawn():SpawnBatch(tonumber(self.monster_id), tonumber(self.total_monster), 9, 45, 30)
end

function CurrentSceneScript:ChallengeBox()
	-- body
	local box_id = LingshoumudiConfig[tostring(self.Layer)]['box_id']
	local box_point = LingshoumudiConfig[tostring(self.Layer)]['box_point']
	if box_point[1] and box_point[2] then
		self.Scene:GetModSpawn():SpawnCollection(
				box_id, 
				box_point[1], 
				box_point[2],
				self.box_dir)
	end
end
