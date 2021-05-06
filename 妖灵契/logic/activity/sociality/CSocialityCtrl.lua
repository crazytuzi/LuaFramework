local CSocialityCtrl = class("CSocialityCtrl", CCtrlBase)

function CSocialityCtrl.ctor(self)
	CCtrlBase.ctor(self)
end

function CSocialityCtrl.Play(self, oInfo, oPlayer)
	if (not oPlayer) then
		return
	end
	local oTarget = g_MapCtrl:GetPlayer(oInfo.target)
	oPlayer:ResetSociaty()
	if oInfo.start_time == nil or oInfo.start_time == 0 then
		return
	end

	local oData = data.socialitydata.DATA[oInfo.display_id] or {}
	local dClipInfo = oPlayer.m_Actor:GetAnimClipInfo(oData.action)
	local passTime = g_TimeCtrl:GetTimeS() - oInfo.start_time
	if passTime < 0 then
		passTime = 0
	end
	local bLoop = oData.loop ~= 0
	if not bLoop and passTime > dClipInfo.length then
		return
	end
	local startNormalized = (passTime % dClipInfo.length) / dClipInfo.length

	if oData.action and oPlayer then
		Utils.AddTimer(function ()
			if not Utils.IsNil(oPlayer) and not Utils.IsNil(oPlayer.m_Actor) then
				if not CDialogueMainView:GetView() then
					oPlayer.m_Actor:SetLocalRotation(Quaternion.Euler(0, oData.rotate_y, 0))
				end			
			end
		end, 0, 0)
		if oData.double ~= 0 and oTarget then
			local oTarget1 = oPlayer
			local oTarget2 = oTarget
			if oInfo.is_invite ~= 1 then
				oTarget1 = oTarget
				oTarget2 = oPlayer
			end
			Utils.AddTimer(function ()
				if not Utils.IsNil(oTarget1) and not Utils.IsNil(oTarget2) and not Utils.IsNil(oTarget1.m_Actor) then
					oTarget2.m_Actor:SetLocalRotation(Quaternion.Euler(0, oData.rotate_y, 0))
					oTarget1:PlaySociaty(oData.action, startNormalized, oTarget2.m_Pid)
					oTarget2:PlaySociaty(oData.target_action, startNormalized, oTarget1.m_Pid)
				end
			end, 0, 0)
		else
			oPlayer:PlaySociaty(oData.action, startNormalized)
		end
	end
end

function CSocialityCtrl.GetPlayerList(self)
	local playerList = g_MapCtrl:GetInSceenPlayer()

	for k,v in pairs(playerList) do
		g_FriendCtrl:IsMyFriend(v.m_Pid)
	end
end

return CSocialityCtrl