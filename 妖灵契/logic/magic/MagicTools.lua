module(..., package.seeall)
function CalcRelativePos(oRelative, iAngle, iDis)
	if iDis == 0 then
		return Vector3.zero
	else
		local rad = math.rad(iAngle)
		local pos = Vector3.New(math.sin(rad)*iDis, 0, math.cos(rad)*iDis)
		return oRelative:TransformVector(pos) 
	end
end

function CalcDepth(pos, depth)
	local pos = Vector3.New(pos.x, pos.y+depth, pos.z)
	return pos
end

function GetParentByEnv(sEnv)
	local tranform
	if sEnv == "war" then
		local o = g_WarCtrl:GetRoot()
		if o then
			tranform = o.m_Transform
		end
	end
	return tranform
end

function GetDir(obj, type)
	if type == "local_up" then
		if obj.GetLocalUp then
			return obj:GetLocalUp()
		else
			return obj:GetUp()
		end
	elseif type == "local_right" then
		return obj:GetRight()
	elseif type == "local_forward" then
		if obj.GetLocalForward then
			return obj:GetLocalForward()
		else
			return obj:GetForward()
		end
	elseif type == "world_up" then
		return Vector3.up
	elseif type == "world_right" then
		return Vector3.right
	elseif type == "world_forward" then
		return Vector3.forward
	end
end

function GetExcutorDirPos(excutor, sType, vPos)
	local vDirPos
	local oRotateObj = excutor.m_RotateObj or excutor
	if sType == "forward" then
		vDirPos = vPos + oRotateObj:GetForward()
	elseif sType == "backward" then
		vDirPos = vPos + oRotateObj:GetForward() * -1
	elseif sType == "up" then
		vDirPos = vPos + oRotateObj:GetUp()
	elseif sType == "down" then
		vDirPos = vPos + oRotateObj:GetUp() * -1
	elseif sType == "right" then
		vDirPos = vPos + oRotateObj:GetRight()
	elseif sType == "left" then
		vDirPos = vPos + oRotateObj:GetRight() * -1
	end
	return vDirPos
end

function GetExcutorLocalAngle(excutor, sType)
	local oRotateObj = excutor.m_RotateObj or excutor
	local vAngle = oRotateObj:GetLocalEulerAngles()
	if sType == "forward" then
		--todo
	elseif sType == "backward" then
		vAngle.y = vAngle.y + 180
	elseif sType == "right" then
		vAngle.y = vAngle.y + 90
	elseif sType == "left" then
		vAngle.y = vAngle.y - 90
	else
		return
	end
	return vAngle
end

function MagicCmdCall(sRunEnv, sFuncName, ...)
	print("MagicCmdCall", sRunEnv, sFuncName, ...)
	local cls
	if sRunEnv == "war" then
		cls = CWarMagicCmd
	elseif sRunEnv == "createrole" then
		cls = CCreateRoleMagicCmd
	elseif sRunEnv == "dialogueani" then
		cls = CDialogueAniMagicCmd
	end
	return cls[sFuncName](cls, ...)
end

function ReverseCalcPos(sRunEnv, sBasePos, atkObj, vicObj, vEndPos, bFaceDir)
	local vPos = MagicCmdCall(sRunEnv, "GetLocalPosByType", sBasePos, atkObj, vicObj)
	bFaceDir = (bFaceDir == nil) and true or bFaceDir
	local oRelative = MagicCmdCall(sRunEnv, "GetRelativeObj", sBasePos, atkObj, vicObj, bFaceDir)
	local angle, dis, height = 0, 0, 0
	local vRelativePos = oRelative:GetPos()
	if vEndPos ~= vRelativePos then
		height = vEndPos.y - vRelativePos.y
		dis = math.sqrt((vEndPos.x-vRelativePos.x)^2+(vEndPos.z - vRelativePos.z)^2)
		angle = Vector3.Angle(oRelative:GetForward(), Vector3.Normalize(Vector3.New(vEndPos.x, vRelativePos.y, vEndPos.z)-vRelativePos))
		local vLocal = oRelative:InverseTransformPoint(vEndPos)
		if vLocal.x < 0 then 
			angle = 360 - angle
		end
	end
	if dis == 0 or angle == 360 then
		angle = 0
	end
	return math.roundext(angle, 2), math.roundext(dis, 2), math.roundext(height, 2)
end