local CFieldBossCtrl = class("CFieldBossCtrl", CCtrlBase)

define.FieldBoss = {
	Event = {
		RefreshHP = 1,
		UpdataUIData = 2,
		EndFieldBoss = 3,
		UpadteBossList = 4,
	}
}

function CFieldBossCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CFieldBossCtrl.ResetCtrl(self)
	self.m_UIData = nil
	self.m_BossList = {}
	self.m_ID = nil
	self.m_ResultData = {}
end

function CFieldBossCtrl.IsOpen(self)
	return self.m_UIData
end

function CFieldBossCtrl.LeaveFieldBoss(self)
	self.m_UIData = nil
	self.m_ID = nil
	self.m_ResultData = {}
	self:OnEvent(define.FieldBoss.Event.EndFieldBoss)
end

function CFieldBossCtrl.RefreshData(self, oData)
	self.m_UIData = {}
	self.m_UIData["orgamount"] = 0
	for _, orginfo in ipairs(oData.org_info) do
		if orginfo.org_id == g_AttrCtrl.org_id then
			self.m_UIData["orgamount"] = orginfo.amount
			break
		end
	end
	self.m_ID = oData.bossid
	self.m_UIData["playercnt"] = oData.playercnt
	self.m_UIData["bossname"] = oData.bossname
	self.m_UIData["reward_endtime"] = oData.reward_endtime
	self.m_UIData["reward_amount"] = oData.reward_amount
	
	self:OnEvent(define.FieldBoss.Event.UpdataUIData)
end

function CFieldBossCtrl.GetUIData(self)
	return self.m_UIData
end

function CFieldBossCtrl.AddBoss(self, bossList)
	for _, bossid in ipairs(bossList) do
		if not table.index(self.m_BossList, bossid) then
			table.insert(self.m_BossList, bossid)
		end
	end
	self:OnEvent(define.FieldBoss.Event.UpadteBossList, self.m_BossList)
end

function CFieldBossCtrl.DelBoss(self, bossid)
	local index = table.index(self.m_BossList, bossid)
	if index then
		table.remove(self.m_BossList, index)
	end
	self:OnEvent(define.FieldBoss.Event.UpadteBossList, self.m_BossList)
end

function CFieldBossCtrl.GetBossList(self)
	return self.m_BossList
end

function CFieldBossCtrl.RefreshBossHP(self, hp, hpmax)
	self.m_Hp = hp
	self.m_MaxHp = hpmax
	self:OnEvent(define.FieldBoss.Event.RefreshHP, nil)
end

function CFieldBossCtrl.GetBossHP(self)
	return self.m_Hp, self.m_MaxHp
end

function CFieldBossCtrl.SetHidePlayer(self, bHide)
	self.m_IsHidePlayer = bHide
	if bHide then
		g_MapCtrl:HideFightPlayer()
	else
		g_MapCtrl:ShowFightPlayer()
	end
end

function CFieldBossCtrl.IsHidePlayer(self)
	if self.m_UIData and self.m_IsHidePlayer then
		return true
	else
		return false
	end
end

function CFieldBossCtrl.GetBossID(self)
	return self.m_ID
end

function CFieldBossCtrl.GetBossData(self, id)
	local bd = data.fieldbossdata.BossConfig[id]
	local nd = nil
	if bd then
		nd = data.fieldbossdata.NPC[bd.boss_model]
	end
	return bd, nd
end

function CFieldBossCtrl.HidePlayer(self, oPlayer)
	if not self.m_IsOpen then
		return
	end

	if not self.m_IsHidePlayer then
		return
	end

	if oPlayer.m_IsFight then
		oPlayer:HidePlayer()
	end
end

function CFieldBossCtrl.SetWarResult(self, pdata)
	self.m_ResultData = {
		damage = pdata.damage,
		max_hp = pdata.max_hp,
		killer = pdata.killer,
	}
	local str = "\n\n"
	if pdata.killer == g_AttrCtrl.pid then
		str = str .. "[dc4236]最后一击\n#n"
	end
	str = str .. string.format("个人伤害：[f2b51c]%d\n#n", pdata.damage)
	if pdata.teamdamage and pdata.teamdamage > 0 and g_TeamCtrl:IsJoinTeam() then
		str = str .. string.format("队伍伤害：[f2b51c]%d\n#n", pdata.teamdamage) 
	end
	g_WarCtrl:SetResultValue("failtips", string.getstringdark(str))
	g_WarCtrl:SetResultValue("reward_times", pdata.reward_times)
	if pdata.coin_reward > 0 then
		g_WarCtrl:SetResultValue("item_list", {{amount = pdata.coin_reward, sid=1002, virtual=1002}})
	else
		g_WarCtrl:SetResultValue("item_list", {})
	end
	local oView = CFieldWarResultView:GetView()
	if oView then
		oView:ReloadWinFailTip()
	end
end

function CFieldBossCtrl.ShowWarResult(self, oCmd)
	local win = oCmd.win
	if oCmd.win_side == 0 then
		win = nil
	end
	CFieldWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(win)
		oView:SetDelayCloseView()
		if not win then
			Utils.AddTimer(function()
				if oView and not Utils.IsNil(oView) then
					oView:RefreshWinFailTip(win)
				end
			end, 0, 1)
		end
	end)
end
return CFieldBossCtrl