local CCreateRoleMagicCmd = class("CCreateRoleMagicCmd", CMagicCmd)

function CCreateRoleMagicCmd.ctor(self, funcname, starttime, args, magicunit)
	CMagicCmd.ctor(self, funcname, starttime, args, magicunit)
end

function CCreateRoleMagicCmd.GetCamera(self)
	return g_CameraCtrl:GetCreateRoleCamera()
end

function CCreateRoleMagicCmd.GetCalcPosObj(self, obj, oFaceObj)
	g_MagicCtrl.m_CalcPosObject:SetParent(obj.m_Transform, false)
	local pos = obj:GetPos() 
	g_MagicCtrl.m_CalcPosObject:SetPos(pos)
	if oFaceObj then
		local vFacePos = oFaceObj:GetPos()
		vFacePos.y = pos.y
		g_MagicCtrl.m_CalcPosObject:LookAt(vFacePos, obj:GetUp())
	end
	return g_MagicCtrl.m_CalcPosObject
end

function CCreateRoleMagicCmd.GetCommonPos(self, sType)
	local xz_pos = {x=0, z=0}
	if sType == "ally_team_center" then
		xz_pos = {x=3, z=22}
	elseif sType == "enemy_team_center" then
		xz_pos = {x=3, z=22}
	elseif sType == "center" then
		xz_pos = {x=3, z=22}
	end
	return Vector3.New(xz_pos.x, 0, xz_pos.z)
end


function CCreateRoleMagicCmd.GetLocalPosByType(self, sType, oAtk, oVic)
	local pos
	if sType == "atk" and oAtk then
		pos = oAtk:GetLocalPos()
	elseif sType == "vic" and oVic then
		pos = oVic:GetLocalPos()
	elseif sType == "atk_lineup" then
		pos = oAtk:GetOriginPos()
	elseif sType == "vic_lineup" then
		pos = oVic:GetOriginPos()
	elseif sType == "center" then
		pos = self:GetCommonPos("center")
	elseif sType == "cam" then
		local oCam = g_CameraCtrl:GetCreateRoleCamera()
		pos = oCam:GetPos()
	else
		pos = Vector3.zero
	end
	return pos
end

function CCreateRoleMagicCmd.CameraLock(self)
	local args = self.m_Args
	g_CreateRoleCtrl:SetLock(not args.player_swipe)
end

function CCreateRoleMagicCmd.GetShakeObj(self)
	return g_CreateRoleCtrl:GetRoot()
end

function CCreateRoleMagicCmd.CheckCondition(self, sCondition)
	if sCondition == "ally" then
		local oAtkObj = self.m_MagicUnit:GetAtkObj()
		return oAtkObj:IsAlly()
	elseif sCondition == "firstidx" then
		return self.m_MagicUnit.m_IsFirstIdx
	elseif sCondition == "endidx" then
		return self.m_MagicUnit.m_IsEndIdx
	elseif sCondition == "atkmale" then
		local oAtkObj = self.m_MagicUnit:GetAtkObj()
		local iShape = oAtkObj:GetShape()
		return table.index({110, 130, 150}, iShape)
	end
	return false
end


function CCreateRoleMagicCmd.HideUI(self)
	
end

return CCreateRoleMagicCmd