local CMagicCmd = class("CMagicCmd")

function CMagicCmd.ctor(self, funcname, starttime, args, magicunit)
	self.m_FuncName = funcname
	self.m_StartTime = starttime
	self.m_Args = args
	self.m_MagicUnit = magicunit
	self.m_EffectObjs = {}
end

function CMagicCmd.Excute(self)
	local f = self[self.m_FuncName]
	if f then
		return f(self)
	end
end

function CMagicCmd.CalcPos(self, tPosInfo, atkObj, vicObj, bFaceDir)
	local vPos = self:GetLocalPosByType(tPosInfo.base_pos, atkObj, vicObj)
	bFaceDir = (bFaceDir == nil) and true or bFaceDir
	local oRelative = self:GetRelativeObj(tPosInfo.base_pos, atkObj, vicObj, bFaceDir)
	if oRelative then
		vPos = vPos + MagicTools.CalcRelativePos(oRelative, tPosInfo.relative_angle, tPosInfo.relative_dis)
	end
	vPos = MagicTools.CalcDepth(vPos, tPosInfo.depth)
	g_MagicCtrl:ResetCalcPosObject()
	return vPos
end

function CMagicCmd.GetRelativeObj(self, sType, oAtk, oVic, bFaceDir)
	if sType == "atk" then
		local oFaceObj =  bFaceDir and oVic.m_Actor or nil
		return self:GetCalcPosObj(oAtk.m_Actor, oFaceObj)
	elseif sType == "vic" then
		local oFaceObj =  bFaceDir and oAtk.m_Actor or nil
		return self:GetCalcPosObj(oVic.m_Actor, oFaceObj)
	elseif sType == "cam" then
		local oCam = g_CameraCtrl:GetWarCamera()
		return oCam
	elseif sType == "atk_team_center" or sType == "center"then
		local obj =self:GetCalcPosObj(g_WarCtrl:GetRoot())
		obj:SetLocalEulerAngles(oAtk:GetDefalutRotateAngle())
		return obj
	elseif sType == "vic_team_center" then
		local obj = self:GetCalcPosObj(g_WarCtrl:GetRoot())
		obj:SetLocalEulerAngles(oVic:GetDefalutRotateAngle())
		return obj
	else
		local oRoot = g_WarCtrl:GetRoot()
		return oRoot
	end
end

function CMagicCmd.GetCalcPosObj(self, obj, oFaceObj)
	g_MagicCtrl.m_CalcPosObject:SetParent(obj.m_Transform, false)
	local pos = obj:GetPos()
	pos.y = 0
	g_MagicCtrl.m_CalcPosObject:SetPos(pos)
	if oFaceObj then
		local vFacePos = oFaceObj:GetPos()
		vFacePos.y = pos.y
		g_MagicCtrl.m_CalcPosObject:LookAt(vFacePos, obj:GetUp())
	end
	return g_MagicCtrl.m_CalcPosObject
end

function CMagicCmd.GetLocalPosByType(self, sType, oAtk, oVic)
	return Vectr3.zero
end

function CMagicCmd.GetCommonPos(self, sType)
	return Vector3.zero
end

function CMagicCmd.GetExcutors(self, sType)
	local bAlly, bAtk, bVic, bAlive = true, true, true, nil
	if sType == "atkobj" then
		return {self.m_MagicUnit:GetAtkObj()}
	elseif sType == "vicobj" then
		return {self.m_MagicUnit:GetVicObjFirst()}
	elseif sType == "camobj" then
		return {self:GetCamera()}
	elseif sType == "vicobjs" then
		return self.m_MagicUnit:GetVicObjs()
	elseif sType == "allys" then

	elseif sType == "ally_na" then
		bAtk = false 
	elseif sType == "enemys" then
		bAlly = false
	elseif sType == "enemy_nv" then
		bAlly = false
		bVic = false
	elseif sType == "ally_alive" then
		bAlive = true
	else
		local lObjs = self.m_MagicUnit.m_ControlObjs[sType]
		return lObjs
	end
	return self.m_MagicUnit:GetTargets(bAlly, bAtk, bVic, bAlive)
end

function CMagicCmd.End(self)
	self.m_MagicUnit:End()
end

function CMagicCmd.ClearCmd(self)
	for i, oEff in ipairs(self.m_EffectObjs) do
		if not Utils.IsNil(oEff) then
			oEff:Destroy()
		end
	end
	self.m_EffectObjs = {}
end

function CMagicCmd.OnTimeUp(self, oEff)
	if not Utils.IsNil(oEff) then
		if not Utils.IsNil(self) then
			for i, v in ipairs(self.m_EffectObjs) do
				if v:GetInstanceID() == oEff:GetInstanceID() then
					table.remove(self.m_EffectObjs, i)
					break
				end
			end
		end
		oEff:Destroy()
	end
end

function CMagicCmd.IsCanRemove(self)
	for k, v in pairs(self.m_EffectObjs) do
		if Utils.IsExist(v) then
			return false
		else
			self.m_EffectObjs[k] = v
		end
	end
	return true
end

function CMagicCmd.ActorPlay(self, oActor, sState, iTime, iStartFrame, iEndFrame)
	if iTime then
		if iStartFrame then
			oActor:AdjustSpeedPlayInFrame(sState, iTime, iStartFrame, iEndFrame, function(o) o:SetSpeed(0) end)
		else
			oActor:AdjustSpeedPlay(sState, iTime)
		end
	else
		if iStartFrame then
			oActor:PlayInFrame(sState, iStartFrame, iEndFrame, function(o) o:SetSpeed(0) end)
		else
			oActor:Play(sState)
		end
	end
end

function CMagicCmd.AddEffect(self, oEff, iAliveTime)
	if iAliveTime then
		if iAliveTime > 20 then
			error(string.format("法术%d, 指令%d, 存在时间太长: %d", self.m_MagicUnit.m_MagicID, self.m_Idx, iAliveTime))
		elseif iAliveTime ~= -1 then
			Utils.AddScaledTimer(callback(self, "OnTimeUp", oEff), 0, iAliveTime)
			table.insert(self.m_EffectObjs, oEff)
		else
			print("不删除特效", oEff.m_Path)
			g_MagicCtrl:AddDontDestroyEffect(self.m_MagicUnit.m_RunEnv, oEff)
		end
	else
		error(string.format("法术%d, 指令%d, 没填存在时间", self.m_MagicUnit.m_MagicID, self.m_Idx))
	end
end

function CMagicCmd.CheckTime(self, iTime)
	if not iTime then
		printerror(string.format("法术%d, 指令%d, 没填时间", self.m_MagicUnit.m_MagicID, self.m_Idx))
		return 0
	end
	return iTime
end


function CMagicCmd.SetExcutorRotate(self, excutor, v)
	if excutor.m_RotateObj then
		excutor.m_RotateObj:SetLocalEulerAngles(Vector3.zero)
	end
	excutor:SetLocalEulerAngles(v)
end


--cmd func
function CMagicCmd.Name(self)
	local args = self.m_Args
	local excutor = self.m_MagicUnit:GetAtkObj()
	if not excutor then
		return
	end

	excutor:ShowWarSkillByClient(self.m_MagicUnit.m_MagicID, args.alive_time)
	
	--local id = self.m_MagicUnit.m_MagicID
	--local dMagic = DataTools.GetMagicData(id)
	--local oView = CWarFloatView:GetView()
	--if oView then
	--	oView:MagicName(dMagic.name, args.alive_time, excutor)
	--end
end

function CMagicCmd.PlayerBigMagic(self)
	local args = self.m_Args
	local excutor = self.m_MagicUnit:GetAtkObj()
	local actor = excutor:GetActor()
	CWarPlayerMagicView:ShowView(function (oView)
		oView:SetData(self.m_MagicUnit.m_MagicID, actor.m_Shape, args.alive_time)
	end)
end

function CMagicCmd.VicHitInfo(self)
	local args = self.m_Args
	self.m_MagicUnit:AddHitInfo(self.m_StartTime, args.hurt_delta, args.face_atk, args.play_anim, args.damage_follow, args.consider_hight)
end

function CMagicCmd.PlayAction(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	for i, excutor in ipairs(lExcutors) do
		if ModelTools.IsCommonState(args.action_name) then
			self:ActorPlay(excutor.m_Actor ,args.action_name, args.action_time, args.start_frame, args.end_frame)
		elseif excutor.m_Actor:PlayCombo(args.action_name) then
			excutor.m_Actor:SetComboHitEvent(callback(self.m_MagicUnit, "CombHit"))
		elseif args.bak_action_name then
			self:ActorPlay(excutor.m_Actor, args.bak_action_name)
		end
	end
end

function CMagicCmd.FaceTo(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	args.time = self:CheckTime(args.time)
	for i, excutor in ipairs(lExcutors) do
		local oRotateObj = excutor.m_RotateObj or excutor
		if args.face_to == "default" then
			excutor:SetLocalEulerAngles(Vector3.zero)
			if excutor.GetDefalutRotateAngle then
				DOTween.DOLocalRotate(oRotateObj.m_Transform, excutor:GetDefalutRotateAngle(), args.time)
			end
			return
		end
		local atkObj = self.m_MagicUnit:GetAtkObj()
		local vicObj = self.m_MagicUnit:GetVicObjFirst()
		if args.face_to == "fixed_pos" then
			local vEndPos = self:CalcPos(args.pos, atkObj, vicObj, false)
			g_MagicCtrl.m_CalcPosObject:SetParent(oRotateObj.m_Transform.parent, false)
			g_MagicCtrl.m_CalcPosObject:LookAt(vEndPos, oRotateObj:GetUp())
			DOTween.DOLocalRotate(oRotateObj.m_Transform, g_MagicCtrl.m_CalcPosObject:GetLocalEulerAngles(), args.time)
			g_MagicCtrl:ResetCalcPosObject()
		elseif args.face_to == "lerp_pos" then
			local beginV = oRotateObj:GetLocalEulerAngles()
			local endV = beginV + Vector3.New(-args.v_dis, args.h_dis, 0)
			if math.abs(args.v_dis) > 359 or math.abs(args.h_dis) > 359 then
				DOTween.DOLocalRotate(oRotateObj.m_Transform, endV, args.time, enum.DOTween.RotateMode.FastBeyond360)
			else
				DOTween.DOLocalRotate(oRotateObj.m_Transform, endV, args.time)
			end
		elseif args.face_to == "look_at" then
			local vEndPos = self:CalcPos(args.pos, atkObj, vicObj, false)
			local root = g_WarCtrl:GetRoot()
			local vUp = root.m_Transform.up
			local oAction = CLookAt.New(oRotateObj, args.time, vEndPos, vUp)
			g_ActionCtrl:AddAction(oAction)
		elseif args.face_to == "random" then
			local x = math.Random(args.x_min, args.x_max)
			local y = math.Random(args.y_min, args.y_max)
			local z = math.Random(args.z_min, args.z_max)
			if args.time > 0 then
				DOTween.DOLocalRotate(oRotateObj.m_Transform, Vector3.New(x, y, z), args.time)
			else
				excutor:SetLocalEulerAngles(Vector3.New(x, y, z))
			end
		elseif args.face_to == "prepare" then
			local sType = excutor.m_IsWarrior and "warrior" or "war"
			local dInfo = g_CameraCtrl:GetCameraInfo(sType, args.prepare_pos)
			if dInfo then
				DOTween.DOLocalRotate(excutor.m_Transform, dInfo.rotate, args.time)
			end
		end
	end
end

function CMagicCmd.MoveDir(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	for i, excutor in ipairs(lExcutors) do
		local vDir = MagicTools.GetDir(excutor, args.dir)
		local vBeginPos = excutor:GetPos()
		local vEndPos = vBeginPos + vDir*args.speed*args.move_time
		local tween = DOTween.DOLocalMove(excutor.m_Transform, vEndPos, args.move_time)
		DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
	end
end

function CMagicCmd.MoveCircle(self, atkObj, vicObj, excutor)
	local args = self.m_Args
	local iMax = args.lerp_cnt or 5
	local list = {}
	local dBeginArgs = args.begin_relative
	local dEndArgs = args.end_relative
	for i = 1, iMax do
		local iLerp = (i-1)/(iMax-1)
		local depth = Mathf.Lerp(dBeginArgs.depth, dEndArgs.depth, iLerp)
		local dis = Mathf.Lerp(dBeginArgs.relative_dis, dEndArgs.relative_dis, iLerp)
		local angle = Mathf.Lerp(dBeginArgs.relative_angle, dEndArgs.relative_angle, iLerp)
		local tInfo = {base_pos=dBeginArgs.base_pos, depth=depth,relative_angle=angle, relative_dis=dis}
		table.insert(list, self:CalcPos(tInfo, atkObj, vicObj, false))
	end
	DOTween.DOPath(excutor.m_Transform, list, args.move_time, 1, 0, 5, Color.green)
end

function CMagicCmd.MoveLine(self, atkObj, vicObj, excutor)
	local args = self.m_Args
	local bSetRotate = false
	local sType = excutor.m_IsWarrior and "warrior" or "war"
	local vBeginPos
	if args.begin_type == "current" then
		vBeginPos = excutor:GetLocalPos()
	elseif args.begin_type == "begin_prepare" then
		local dBeginInfo = g_CameraCtrl:GetCameraInfo(sType, args.begin_prepare)
		if not dBeginInfo then
			g_NotifyCtrl:FloatMsg(string.format("不存在预设点%s", args.begin_prepare))
			return
		end
		vBeginPos = dBeginInfo.pos
		bSetRotate = true
		self:SetExcutorRotate(excutor, dBeginInfo.rotate)
	elseif args.begin_type == "begin_relative" then
		vBeginPos = self:CalcPos(args.begin_relative, atkObj, vicObj, args.calc_face)
	end
	excutor:SetLocalPos(vBeginPos)
	if args.move_time == 0 then
		return
	end
	local vEndPos
	if args.end_type == "end_prepare" then
		local dEndInfo = g_CameraCtrl:GetCameraInfo(sType, self.m_Args.end_prepare)
		if dEndInfo then
			vEndPos = dEndInfo.pos
			if not bSetRotate then
				self:SetExcutorRotate(excutor, dEndInfo.rotate)
			end
		end
	elseif args.end_type == "end_relative" then
		vEndPos = self:CalcPos(args.end_relative, atkObj, vicObj, args.calc_face)
	end
	if vEndPos then
		if args.look_at_pos ~= false then
			if excutor.LookAtPos then
				excutor:LookAtPos(vEndPos)
			end
		end
		--EditorDebug.DrawLine(vBeginPos, vEndPos, "move")

		local tween = DOTween.DOLocalMove(excutor.m_Transform, vEndPos, args.move_time)
		local sEaseType = args.ease_type or "Linear"
		DOTween.SetEase(tween, enum.DOTween.Ease[sEaseType])
	end
end

function CMagicCmd.MoveJump(self, atkObj, vicObj, excutor)
	local args = self.m_Args
	local bSetRotate = false
	local sType = excutor.m_IsWarrior and "warrior" or "war"
	local vBeginPos
	if args.begin_type == "current" then
		vBeginPos = excutor:GetLocalPos()
	elseif args.begin_type == "begin_prepare" then
		local dBeginInfo = g_CameraCtrl:GetCameraInfo(sType, args.begin_prepare)
		if not dBeginInfo then
			g_NotifyCtrl:FloatMsg(string.format("不存在预设点%s", args.begin_prepare))
			return
		end
		vBeginPos = dBeginInfo.pos
		bSetRotate = true
		self:SetExcutorRotate(excutor, dBeginInfo.rotate)
	elseif args.begin_type == "begin_relative" then
		vBeginPos = self:CalcPos(args.begin_relative, atkObj, vicObj, args.calc_face)
	end
	excutor:SetLocalPos(vBeginPos)
	if args.move_time == 0 then
		return
	end
	local vEndPos
	if args.end_type == "end_prepare" then
		local dEndInfo = g_CameraCtrl:GetCameraInfo(sType, self.m_Args.end_prepare)
		if dEndInfo then
			vEndPos = dEndInfo.pos
			if not bSetRotate then
				self:SetExcutorRotate(excutor, dEndInfo.rotate)
			end
		end
	elseif args.end_type == "end_relative" then
		vEndPos = self:CalcPos(args.end_relative, atkObj, vicObj, args.calc_face)
	end
	if vEndPos then
		if args.look_at_pos ~= false and excutor.LookAtPos then
			excutor:LookAtPos(vEndPos)
		end
	end
	if excutor.SetRotateNode then
		local p = excutor.m_Transform.parent
		local oNode = CObject.New(UnityEngine.GameObject.New())
		excutor:SetRotateNode(oNode)
		vEndPos = oNode:InverseTransformPoint(vEndPos)
	end
	local iJump = args.min_jump_power
	if args.max_jump_power and args.max_jump_power > args.min_jump_power then
		iJump = math.Random(args.min_jump_power, args.max_jump_power)
	end
	local tween = DOTween.DOLocalJump(excutor.m_Transform, vEndPos, iJump, args.jump_num, args.move_time, false)
	local sEaseType = args.ease_type or "Linear"
	DOTween.SetEase(tween, enum.DOTween.Ease[sEaseType])
end

function CMagicCmd.Move(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	local atkObj = self.m_MagicUnit:GetAtkObj()
	local vicObj = self.m_MagicUnit:GetVicObjFirst()
	for i, excutor in ipairs(lExcutors) do
		if args.move_type == "circle" then
			self:MoveCircle(atkObj, vicObj, excutor)
		elseif args.move_type == "line" then
			self:MoveLine(atkObj, vicObj, excutor)
		elseif args.move_type == "jump" then
			self:MoveJump(atkObj, vicObj, excutor)
		end
	end
end

function CMagicCmd.StandEffect(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	local atkobj = self.m_MagicUnit:GetAtkObj()
	local vicObjs = self.m_MagicUnit:GetVicObjs()
	local list = {}
	for i, excutor in ipairs(lExcutors) do
		local oEff = CMagicEffect.New(args.effect.path, self.m_MagicUnit:GetLayer(args.effect.magic_layer), args.effect.is_cached)
		oEff:SetEnv(self.m_MagicUnit.m_RunEnv)
		local vPos = self:CalcPos(args.effect_pos, atkobj, vicObjs[i], false)
		oEff:SetLocalPos(vPos)
		if args.effect_dir_type then
			--LookAt有点误差
			local vAngle
			if oEff:GetParent() == excutor:GetParent() then
				vAngle = MagicTools.GetExcutorLocalAngle(excutor, args.effect_dir_type)
			end
			if vAngle then
				oEff:SetLocalEulerAngles(vAngle)
			else
				local vDirPos = MagicTools.GetExcutorDirPos(excutor, args.effect_dir_type, vPos)
				if not vDirPos and args.relative_dir then
					vDirPos = self:CalcPos(args.relative_dir, atkobj, vicObjs[i], false)
				end
				if vDirPos then
					oEff:LookAt(vDirPos, excutor.m_Transform.up)
				end
			end
		end
		--EditorDebug.DrawLine(vPos, vDirPos, "StandEffect???????")
		self:AddEffect(oEff, args.alive_time)
		table.insert(list, oEff)
	end
	return list
end

function CMagicCmd.ShootEffect(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	local atkobj = self.m_MagicUnit:GetAtkObj()
	local list = {}
	for i, excutor in ipairs(lExcutors) do
		local oEff = CMagicEffect.New(args.effect.path, self.m_MagicUnit:GetLayer(args.effect.magic_layer), args.effect.is_cached)
		oEff:SetEnv(self.m_MagicUnit.m_RunEnv)
		local beginPos = self:CalcPos(args.begin_pos, atkobj, excutor, true)
		oEff:SetLocalPos(beginPos)
		local endPos = self:CalcPos(args.end_pos, atkobj, excutor, true)
		oEff:LookAt(endPos, excutor.m_Transform.up)
		if args.move_time == 0 then
			oEff:SetLocalPos(endPos)
		else
			local tween = DOTween.DOLocalMove(oEff.m_Transform, endPos, args.move_time)
			local sEaseType = args.ease_type or "Linear"
			DOTween.SetEase(tween, enum.DOTween.Ease[sEaseType])
			if args.delay_time then
				DOTween.SetDelay(tween, args.delay_time)
			end
		end
		--EditorDebug.DrawLine(beginPos, endPos,"shoot")
		self:AddEffect(oEff, args.alive_time)
		table.insert(list, oEff)
	end
	return list
end

function CMagicCmd.BodyEffect(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end

	local function get()
		local oEff = CMagicEffect.New(args.effect.path, self.m_MagicUnit:GetLayer(args.effect.magic_layer), args.effect.is_cached)
		oEff:SetEnv(self.m_MagicUnit.m_RunEnv)
		if args.height then
			oEff:SetLocalPos(Vector3.New(0, args.height,0))
		end
		self:AddEffect(oEff, args.alive_time)
		return oEff
	end
	for i, excutor in ipairs(lExcutors) do
		if args.bind_type == "node" then
			if args.bind_idx and excutor.m_Actor  then
				excutor.m_Actor:BindObjByIdx(args.bind_idx, get)
			end
		elseif args.bind_type == "model" then
			if args.find_path and excutor.m_Actor then
				excutor.m_Actor:BindObjByFind(args.find_path, get)
			end
		else 
			local trans
			if args.bind_type == "pos" and args.body_pos and excutor.GetBindTrans then
				trans = excutor:GetBindTrans(args.body_pos)
			end
			if not trans then
				trans = excutor.m_RotateTrans or excutor.m_Transform
			end
			local o = get()
			o:SetParent(trans, false)
		end
	end
end

function CMagicCmd.ChainEffect(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	local atkobj = self.m_MagicUnit:GetAtkObj()
	for i, oEndObj in ipairs(lExcutors) do
		local vBeginPos = self:CalcPos(args.begin_pos, atkobj, oEndObj, true)
		local oEff = CMagicEffect.New(args.effect.path, self.m_MagicUnit:GetLayer(args.effect.magic_layer), args.effect.is_cached)
		oEff:SetEnv(self.m_MagicUnit.m_RunEnv)
		oEff:SetPos(vBeginPos)
		local vEndPos = self:CalcPos(args.end_pos, atkobj, oEndObj, true)
		local dis = Vector3.Distance(vBeginPos, vEndPos)
		oEff:LookAt(vEndPos, oEndObj.m_Transform.up)
		oEff:SetLocalScale(Vector3.New(1, 1, 0))
		if args.repeat_texture then
			oEff:SetTiling(dis, args.scale_time)
		end
		local tween = DOTween.DOScaleZ(oEff.m_Transform, dis, args.scale_time)
		local sEaseType = args.ease_type or "Linear"
		DOTween.SetEase(tween, enum.DOTween.Ease[sEaseType])
		self:AddEffect(oEff, args.alive_time)
	end
end

function CMagicCmd.AnimatorEffect(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	local atkobj = self.m_MagicUnit:GetAtkObj()
	local list = {}
	for i, excutor in ipairs(lExcutors) do
		local oEff = CAnimatorEffect.New(args.effect.path, self.m_MagicUnit:GetLayer(args.effect.magic_layer), args.effect.is_cached)
		oEff:AnimObj(excutor)
		self:AddEffect(oEff, args.alive_time)
		table.insert(list, oEff)
	end
	return list
end

function CMagicCmd.GetShakeObj(self)
	--override
end

function CMagicCmd.ShakeScreen(self)
	local shakeobj = self:GetShakeObj()
	if shakeobj then
		local args = self.m_Args
		local iRate = 0.1/args.shake_rate
		local oAction = CShakePosition.New(shakeobj, args.shake_time, args.shake_dis, iRate)
		g_ActionCtrl:AddAction(oAction)
	end
	-- local args = self.m_Args
	-- local shakeobj = g_WarCtrl:GetRoot()
	-- local pos = shakeobj:GetPos()
	-- local strength = args.shake_dis * 1.2
	-- local vibrato = args.shake_rate*2000
	-- local tweener = DOTween.DOShakePosition(shakeobj.m_Transform, args.shake_time, strength, vibrato, 90, false, false)
	-- DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
	-- DOTween.OnComplete(tweener, function()
	-- 		if Utils.IsExist(shakeobj) then
	-- 			shakeobj:SetPos(pos)
	-- 		end
	-- 	end)
end

function CMagicCmd.IsAtkObjAlly(self)
	local atkObj = self.m_MagicUnit:GetAtkObj()
	return atkObj:IsAlly()
end

function CMagicCmd.CameraTarget(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors or not next(lExcutors) then
		return
	end
	local excutor = lExcutors[1]
	local oCam = self:GetCamera()
	local atkObj = self.m_MagicUnit:GetAtkObj()
	local vicObj = self.m_MagicUnit:GetVicObjFirst()
	if args.move_type == "cam" then
		local vPos = self:CalcPos(args.camera_pos, atkObj, vicObj, false)
		oCam:LookAt(excutor.m_WaistTrans, excutor.m_WaistTrans.up)
		if args.move_time == 0 then
			oCam:SetLocalPos(vPos)
		else
			DOTween.DOLocalMove(oCam.m_Transform, vPos, args.move_time)
		end
	elseif args.move_type == "actor" then
		local vPos = self:CalcPos(args.actor_pos, atkObj, vicObj, false)
		excutor:SetPos(vPos)
		excutor.m_RotateTrans:LookAt(oCam.m_Transform, oCam:GetUp())
	end
end

function CMagicCmd.GroupCmd(self)
	local args = self.m_Args
	if args.group_type == "condition" then
		local groupname = nil
		if self:CheckCondition(args.condition_name) then
			groupname = args.true_group
		else
			groupname = args.false_group
		end
		if args.add_type == "insert" then
			self.m_MagicUnit:InsertGroupCmds(self.m_StartTime, {groupname})
		elseif args.add_type == "merge" then
			self.m_MagicUnit:MergeGroupCmds(groupname)
		end
	elseif args.group_type == "repeat" then
		local iCnt = string.eval(args.cnt, self.m_MagicUnit:GetEvalEnv())
		local lValList = args.group_names
		local iValCnt = #lValList
		local lGroupNames = {}
		for i=1, iCnt do
			local idx = 1
			if args.get_type == "random" then
				idx = Utils.RandomInt(1, iValCnt)
			else
				idx = i % iValCnt
				idx = (idx == 0) and iValCnt or idx
			end
			table.insert(lGroupNames, tostring(lValList[idx]))
		end
		self.m_MagicUnit:InsertGroupCmds(self.m_StartTime, lGroupNames)
	end
end


function CMagicCmd.CameraLock(self)
	--over ride
end

--指令组条件判断
function CMagicCmd.CheckCondition(self, sCondition)
	return false
end

function CMagicCmd.ActorColor(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	local c = args.color
	local color = Color.New(c.r/255, c.g/255, c.b/255, c.a/255)
	for i, excutor in ipairs(lExcutors) do
		-- excutor.m_ShadowObj:SetActive(false)
		if args.fade_time and args.fade_time > 0 then
			local action = CActionColor.New(excutor, args.fade_time, "SetMatColor", excutor:GetMatColor(), color)
			g_ActionCtrl:AddAction(action)
		else
			excutor:SetMatColor(color)
		end
		if args.alive_time then
			local function restore()
				if Utils.IsExist(excutor) then
					-- excutor.m_ShadowObj:SetActive(true)
					excutor:SetMatColor(Color.white)
				end
			end
			Utils.AddScaledTimer(restore, 0, args.alive_time)
		end
	end
end

function CMagicCmd.LockHide(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors then
		return
	end
	for i, excutor in ipairs(lExcutors) do
		excutor:LockHide()
	end
end

function CMagicCmd.HideUI(self)
	self:MoveHuds()
	UITools.HideUI()
	if self.m_Args.time and self.m_Args.time > 0 then
		Utils.AddScaledTimer(callback(self, "ShowUI"), 0, self.m_Args.time)
	end
	--else
	-- 	Utils.AddScaledTimer(callback(self, "ResetHuds"), 0, 1)
	--end
end

function CMagicCmd.ShowUI(self)
	UITools.ShowUI()
	return self:ResetHuds()
end

function CMagicCmd.MoveHuds(self)
	local oWarriorDamageHudRoot = g_HudCtrl:GetParentPanel("CWarriorDamageHud")
	local oWarriorMagicHudRoot = g_HudCtrl:GetParentPanel("CWarriorMagicHud")
	local p = UITools.GetUIRootObj(true)
	if p then
		oWarriorDamageHudRoot:SetParent(p.m_Transform, true)
		oWarriorMagicHudRoot:SetParent(p.m_Transform, true)
	end
end

function CMagicCmd.ResetHuds(self)
	local oWarriorDamageHudRoot = g_HudCtrl:GetParentPanel("CWarriorDamageHud")
	local oWarriorMagicHudRoot = g_HudCtrl:GetParentPanel("CWarriorMagicHud")
	local p = g_HudCtrl:GetHudRoot()
	if p then
		oWarriorDamageHudRoot:SetParent(p.m_Transform, true)
		oWarriorMagicHudRoot:SetParent(p.m_Transform, true)
	end
end

function CMagicCmd.LoadUI(self)
	local args = self.m_Args
	g_ResCtrl:LoadCloneAsync(args.path, function(oClone, path)
		local obj = CObject.New(oClone)
		local oRootObj = UITools.GetUIRootObj(true)
		obj:SetParent(oRootObj:GetTransform(), true)
		obj:SetLocalScale(oRootObj:GetLocalScale())
		obj:SetLocalPos(Vector3.zero)
		obj:InitUITwener(true)
		obj:UITweenPlay()
		Utils.AddScaledTimer(callback(g_ResCtrl, "PutCloneInCache", path, oClone), 0, args.time)
	end, true)
end

function CMagicCmd.GetCamera(self)
	
end

function CMagicCmd.CameraColor(self)
	local args = self.m_Args
	local obj =g_MapCtrl:GetCurMapObj()
	if obj then
		obj:SetActive(false)
	end
	local c = args.color
	local oCam = self:GetCamera()
	local color = Color.New(c.r/255, c.g/255, c.b/255, c.a/255)
	if args.fade_time and args.fade_time > 0 then
		local action = CActionColor.New(oCam, args.fade_time, "SetBackgroudColor", oCam:GetBackgroundColor(), color)
		g_ActionCtrl:AddAction(action)
	else
		oCam:SetBackgroudColor(color)
	end

	if args.restore_time then
		local function restore()
			local obj = g_MapCtrl:GetCurMapObj()
			if obj then
				obj:SetActive(true)
			end
			oCam:SetBackgroudColor(Color.black)
		end
		if args.restore_time > 0 then
			Utils.AddScaledTimer(restore, 0, args.restore_time)
		else
			restore()
		end
	end
end

function CMagicCmd.CameraFieldOfView(self)
	local args = self.m_Args
	local oCam = self:GetCamera()
	if args.fade_time and args.fade_time > 0 then
		local oAction = CActionFloat.New(oCam, args.fade_time, "SetFieldOfView", args.start_val, args.end_val)
		g_ActionCtrl:AddAction(oAction)
	else
		oCam:SetFieldOfView(args.end_val)
	end
end

function CMagicCmd.CameraPathPercent(self)
	g_CameraCtrl:SetAnimatorPercent(self.m_Args.path_percent)
end

function CMagicCmd.KillTargetTween(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors or not next(lExcutors) then
		return
	end
	for i, excutor in ipairs(lExcutors) do
		DOTween.DOKill(excutor.m_Transform, true)
		g_ActionCtrl:StopTarget(excutor)
	end
end

function CMagicCmd.ActorMaterial(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors or not next(lExcutors) then
		return
	end
	for i, excutor in ipairs(lExcutors) do
		if excutor.m_Actor then
			excutor.m_Actor:LoadMaterial(args.mat_path, {show_time=args.ease_show_time, hide_time=args.ease_hide_time, alive_time=args.alive_time})
		end
	end
end

function CMagicCmd.ControlObject(self)
	self.m_MagicUnit:ControlNextObject(self.m_Args.name)
end

function CMagicCmd.PlaySound(self)
	-- if Utils.IsEditor() then
	g_AudioCtrl:PlaySound(self.m_Args.sound_path, true, self.m_Args.sound_rate)
	-- end
end

function CMagicCmd.FloatHit(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors or not next(lExcutors) then
		return
	end
	CWarrior.up_speed = args.up_speed
	CWarrior.up_time =args.up_time
	CWarrior.hit_speed = args.hit_speed
	CWarrior.hit_time = args.hit_time
	CWarrior.down_time = args.down_time
	CWarrior.lie_time = args.lie_time
	for i, excutor in ipairs(lExcutors) do
		if excutor.FloatHit then
			excutor:FloatHit()
		end
	end
end

function CMagicCmd.WarResultAnim(self)
	local oCmd = self.m_MagicUnit.m_Data.refWarCmd
	-- oCmd.win = 1
	if oCmd then
		oCmd:WarResultAnim()
	end
end

function CMagicCmd.FloatTest(self)
	local args = self.m_Args
	CEditorMagicView.g_OriGetFile = true
	CWarCtrl.BoutStart = function(o, i) o.m_Bout = i end
	CWarrior.IsFloatAtkID = function () return true end
	CWarrior.up_speed = args.up_speed
	CWarrior.up_time =args.up_time
	CWarrior.hit_speed = args.hit_speed
	CWarrior.hit_time = args.hit_time
	CWarrior.down_time = args.down_time
	-- CWarrior.rise_time = args.rise_time
	warsimulate.FloatTest(args.sk1, args.sk2)
end

function CMagicCmd.SlowMotion(self)
	UnityEngine.Time:SetTimeScale(self.m_Args.scale*g_WarCtrl:GetAnimSpeed()*define.War.SpeedFactor)
	Utils.AddScaledTimer(function()
		g_WarCtrl:UpdateTimeScale()
		end,0, self.m_Args.time)
end

function CMagicCmd.Shadow(self)
	local args = self.m_Args
	local lExcutors = self:GetExcutors(args.excutor)
	if not lExcutors or not next(lExcutors) then
		return
	end
	for i, excutor in ipairs(lExcutors) do
		if excutor.m_Actor then
			if args.is_show then
				excutor.m_Actor:LoadMaterial("Material/shadow.mat")
			else
				excutor.m_Actor:DelMaterial("Material/shadow.mat")
			end
		end
		
	end
end

return CMagicCmd