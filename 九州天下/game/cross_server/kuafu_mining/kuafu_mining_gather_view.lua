KuaFuMiningGatherView = KuaFuMiningGatherView or BaseClass(BaseRender)

function KuaFuMiningGatherView:__init()
	self.gather = self:FindObj("MiningGatherBar")
	self.gather_bar = self.gather:GetComponent(typeof(UnityEngine.UI.Slider))
	self.gather_fil = self:FindObj("MiningGatherFil")
	self.mining_sun = self:FindObj("MiningSun")

	self.end_time = self:FindVariable("end_time")
	self.is_click = self:FindVariable("is_click")
	self.original = self.gather_fil.rect.anchoredPosition3D
	self.is_click:SetValue(false)
	self:ListenEvent("OnClickStop", BindTool.Bind(self.OnClickStop, self))
	-- self:ListenEvent("AutoMining", BindTool.Bind(self.OnClickAuto, self))
	-- self:ListenEvent("CancelAutoMining", BindTool.Bind(self.OnClickCancelAuto, self))
	self:ListenEvent("StoplMining", BindTool.Bind(self.StopMining, self))
	
	self.cur_angle = 999
end

function KuaFuMiningGatherView:__delete()
	if self.mining_delay then
		GlobalTimerQuest:CancelQuest(self.mining_delay)
		self.mining_delay = nil
	end
end

function KuaFuMiningGatherView:SendCSCross(req_type, param1)
	KuaFuMiningCtrl.Instance:SendCSCrossMiningOperaReq(req_type, param1)
end

function KuaFuMiningGatherView:Result(angle, is_auto)
	if not angle or angle == 999 then return end
	if is_auto and not KuaFuMiningData.Instance:GetMiningIsAuto() then
		self:SendCSCross(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_STOP_GATHER)
	end

	local cur_result = CROSS_MINING_AREA_TYPE.CROSS_MINING_AREA_TYPE_BLACK
	if KuaFuMiningData.Instance:GetMiningIsAuto() then
		angle = GameMath.Rand(-20, 200)
	end	

	if angle >= 75 and angle <= 105 then
		cur_result = CROSS_MINING_AREA_TYPE.CROSS_MINING_AREA_TYPE_RED

	elseif angle >= 30 and angle <= 150 then
		cur_result = CROSS_MINING_AREA_TYPE.CROSS_MINING_AREA_TYPE_YELLOW
	end
	
	self:SendCSCross(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_MINING, cur_result)
end

function KuaFuMiningGatherView:StopMining()
	KuaFuMiningCtrl.Instance:SetGatherVisable(false)
	self:RemoveCountDown()

	if KuaFuMiningData.Instance:GetMiningIsAuto() or KuaFuMiningCtrl.Instance:GetGuideState() then
		if self.mining_delay == nil then
			self.mining_delay = GlobalTimerQuest:AddDelayTimer(function ()
				self:AutoMining()
				GlobalTimerQuest:CancelQuest(self.mining_delay)
				self.mining_delay = nil
			end, 0.5)
		end
	end
end

function KuaFuMiningGatherView:OnClickStop()
	self:RemoveCountDown()
	self:Result(self.cur_angle, false)
	if KuaFuMiningData.Instance:GetMiningIsAuto() then
		self:SendCSCross(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_CANCEL_AUTO_MINING)
	end
end

function KuaFuMiningGatherView:OnClickAuto()
	self:SendCSCross(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_AUTO_MINING)
end

function KuaFuMiningGatherView:OnClickCancelAuto()
	self:SendCSCross(MINING_REQ_TYPE.CROSS_MINING_REQ_TYPE_CANCEL_AUTO_MINING)
	Scene.Instance:GetMainRole():StopMove()
end

function KuaFuMiningGatherView:AutoMining()
	local new_pos_list = {}
	local other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
	local pos_list  = KuaFuMiningData.Instance:GetMiningGatherPosInfo()
	if pos_list == nil or next(pos_list) == nil then 
		SysMsgCtrl.Instance:ErrorRemind(Language.KuaFuFMining.MineWaitRefresh)
		return 
	end
	local new_pos_list = CrossCrystalData.Instance:GetMinDistancePosList(pos_list)

	MoveCache.param1 = other_cfg.gather_id
	if KuaFuMiningData.Instance:GetMiningIsAuto() or KuaFuMiningCtrl.Instance:GetGuideState() then
		MoveCache.end_type = MoveEndType.GatherById
	end

	GuajiCtrl.Instance:MoveToPos(other_cfg.scene_id, new_pos_list[1].x, new_pos_list[1].y, 4, 2)
end

function KuaFuMiningGatherView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			self:AutoMining()
		elseif k == "click" and self.is_click then
			local value = KuaFuMiningData.Instance:GetMiningIsAuto()
			self.is_click:SetValue(value)
			KuaFuMiningCtrl.Instance:SetShowText(value)
		end
	end
end

function KuaFuMiningGatherView:Start()
	local x = 0
	local y = 0
	local r = 0  		--半径  
	local w = 0.5 		--角度  
	local speed = 0.08
	local first = true
	local reverse = true
	self.gather_bar.value = 0
	self.gather_fil.rect.anchoredPosition3D = self.original

	r = Vector3.Distance(self.gather_fil.rect.anchoredPosition3D, self.mining_sun.rect.anchoredPosition3D)
	
	function diff_time_func(elapse_time, total_time)

		if reverse then
			w = w + speed + UnityEngine.Time.deltaTime
		else
			w = w + speed - UnityEngine.Time.deltaTime
		end

		if first then
			w = 3.5
			first = false
		end

		x = Mathf.Cos(w) * r
		y = Mathf.Sin(w) * r

		local rotation = self:GetAngle(0, 0, x, y)
		local end_times = 5 - elapse_time
		self.cur_angle = rotation
		self.end_time:SetValue(end_times + 1)
		self.gather_bar.value = end_times ~= 0 and  end_times / total_time or 0

		self.gather_fil.transform.localRotation = Quaternion.Euler(0, 0, rotation - 90)
		self.gather_fil.rect.anchoredPosition3D = Vector3(x, y, self.gather_fil.rect.anchoredPosition3D.z)

		if x < 0 and rotation < 0 then --x < 0的时候角度转成正的来计算
			rotation = 360 + rotation
		end 
		
		if (rotation >= 200 and y <= 0) or (rotation <= -20 and y <= 0 and not reverse) then
			speed = -speed
			w = w
			reverse = not reverse
		elseif rotation >= 0 then
			w = w
		elseif rotation >= 180 then
			w = -w
		end

		if elapse_time >= total_time then
			self:Result(rotation, true)
			self:RemoveCountDown()
		end
	end
	
	local total = 5
	self:RemoveCountDown()

	self.count_down = CountDown.Instance:AddCountDown(
		total, 0.04, diff_time_func)
end

function KuaFuMiningGatherView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

--两点的夹角
function KuaFuMiningGatherView:GetAngle(px1, py1, px2, py2) 
	local p = {}
	p.x = px2 - px1
	p.y = py2 - py1
			 
	local r = math.atan2(p.y, p.x) * 180 / math.pi  

	return r
end