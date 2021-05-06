local CWarMagicCmd = class("CWarMagicCmd", CMagicCmd)

function CWarMagicCmd.ctor(self, funcname, starttime, args, magicunit)
	CMagicCmd.ctor(self, funcname, starttime, args, magicunit)
end

function CWarMagicCmd.GetCamera(self)
	return g_CameraCtrl:GetWarCamera()
end

function CWarMagicCmd.GetLocalPosByType(self, sType, oAtk, oVic)
	local vAllyTeamPos = self:GetCommonPos("ally_team_center")
	local vEnemyTeamPos = self:GetCommonPos("enemy_team_center")
	local pos
	if sType == "atk" and oAtk then
		pos = oAtk:GetLocalPos()
		pos.y = 0
	elseif sType == "vic" and oVic then
		pos = oVic:GetLocalPos()
		pos.y = 0
	elseif sType == "atk_lineup" then
		pos = oAtk:GetOriginPos()
	elseif sType == "vic_lineup" then
		pos = oVic:GetOriginPos()
	elseif sType == "atk_team_center" then
		pos = oAtk:IsAlly() and vAllyTeamPos or vEnemyTeamPos
	elseif sType == "vic_team_center" then
		pos = oVic:IsAlly() and vAllyTeamPos or vEnemyTeamPos
	elseif sType == "center" then
		pos = self:GetCommonPos("center")
	elseif sType == "cam" then
		local oCam = g_CameraCtrl:GetWarCamera()
		pos = oCam:GetPos()
	else
		pos = Vector3.zero
	end
	return pos
end

function CWarMagicCmd.CameraLock(self)
	local args = self.m_Args
	g_WarTouchCtrl:SetLock(not args.player_swipe)
end

function CWarMagicCmd.GetCommonPos(self, sType)
	local xz_pos = {x=0, z=0}
	if sType == "ally_team_center" then
		xz_pos = {x=1.91, z=-1.91}
	elseif sType == "enemy_team_center" then
		xz_pos = {x=-1.77, z=1.77}
	elseif sType == "center" then
		xz_pos = {x=0, z=0}
	end
	return Vector3.New(xz_pos.x, 0, xz_pos.z)
end

function CWarMagicCmd.GetShakeObj(self)
	return g_WarCtrl:GetRoot()
end

function CWarMagicCmd.CheckCondition(self, sCondition)
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
		return table.index({110, 130, 150}, iShape) ~= nil
	end
	return false
end

return CWarMagicCmd