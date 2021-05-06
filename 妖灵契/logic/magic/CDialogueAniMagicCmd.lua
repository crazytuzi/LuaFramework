local CDialogueAniMagicCmd = class("CDialogueAniMagicCmd", CMagicCmd)

function CDialogueAniMagicCmd.ctor(self, funcname, starttime, args, magicunit)
	CMagicCmd.ctor(self, funcname, starttime, args, magicunit)
end

function CDialogueAniMagicCmd.GetCamera(self)
	return g_CameraCtrl:GetMainCamera()
end

function CDialogueAniMagicCmd.GetLocalPosByType(self, sType, oAtk, oVic)
	local vAllyTeamPos = self:GetCommonPos("ally_team_center")
	local vEnemyTeamPos = self:GetCommonPos("enemy_team_center")
	local pos
	--printy(" >>>>>>>>>>>>>>>>>>  pos ", sType)

	if sType == "atk" and oAtk then
		pos = oAtk:GetLocalPos()
	--	pos.y = 0
	elseif sType == "vic" and oVic then
		pos = oVic:GetLocalPos()
	--	pos.y = 0
	elseif sType == "atk_lineup" then
		--pos = oAtk:GetOriginPos()
		pos = oVic:GetLocalPos()

	elseif sType == "vic_lineup" then
		--pos = oVic:GetOriginPos()
		pos = oVic:GetLocalPos()
	elseif sType == "atk_team_center" then
		--pos = oAtk:IsAlly() and vAllyTeamPos or vEnemyTeamPos
		pos = oVic:GetLocalPos()
	elseif sType == "vic_team_center" then
		pos = oVic:GetLocalPos()
		--pos = oVic:IsAlly() and vAllyTeamPos or vEnemyTeamPos
	elseif sType == "center" then
		--pos = self:GetCommonPos("center")
		pos = oVic:GetLocalPos()
		--pos = oVic:GetLocalPos()
	elseif sType == "cam" then
		local oCam = g_CameraCtrl:GetMainCamera()
		pos = oCam:GetPos()
	else
		pos = Vector3.zero
	end

	return pos
end

function CMagicCmd.CDialogueAniMagicCmd(self)

end

return CDialogueAniMagicCmd