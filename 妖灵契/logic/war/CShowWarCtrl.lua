local CShowWarCtrl = class("CShowWarCtrl")
--纯客户端的战斗演示
function CShowWarCtrl.ctor(self)
	self.m_WarID = nil
	self.m_EndCb = nil
	self.m_MagicList = {}
end

function CShowWarCtrl.IsShowWar(self)
	return self.m_WarID ~= nil
end

function CShowWarCtrl.IsCanOperate(self)
	if self:IsShowWar() then
		return false
	else
		return true
	end
	
end

function CShowWarCtrl.LoadShowWar(self, sType, cb)
	local dData = data.showwardata[sType]
	if not dData then
		printerror("没有战斗导表数据", sType)
		return
	end
	self.m_EndCb = cb
	self.m_WarID = Utils.GetUniqueID()
	netwar.GS2CShowWar({war_id=self.m_WarID, war_type=dData.war_type})
	netwar.GS2CEnterWar()
	for i, dData in ipairs(dData.warrior_list) do 
		self:AddWarrior(dData)
	end
	self:BoutEnd({[1]=0})
	self:BoutStart({[1]=1})
	for i, dData in ipairs(dData.cmd_list) do
		self:AddCmd(dData)
	end
	self:End({})
end

function CShowWarCtrl.GetTestValue(self, k, v)
	if v == "$player" then
		if k == "name" then
			return g_AttrCtrl.name
		elseif k == "shape" then
			return 130
		elseif k == "weapon" then
			return 2000
		end
	elseif v == "$skill_1" then
		v = 3201
	elseif v == "$skill_2" then
		v = 3202
	elseif v == "$skill_3" then
		v = 3203
	elseif v == "$skill_4" then
		v = 3205
	end
	return v
end

function CShowWarCtrl.GetValue(self, k, v)
	if g_AttrCtrl.pid == 0 then
		return self:GetTestValue(k, v)
	end
	if v == "$player" then
		if k == "name" then
			return g_AttrCtrl.name
		elseif k == "shape" then
			return g_AttrCtrl.model_info.shape
		elseif k == "weapon" then
			return g_AttrCtrl.model_info.weapon
		end
	elseif v == "$skill_1" then
		v = self.m_MagicList[1]
	elseif v == "$skill_2" then
		v = self.m_MagicList[2]
	elseif v == "$skill_3" then
		v = self.m_MagicList[3]
	elseif v == "$skill_4" then
		v = self.m_MagicList[4]
	end
	return v
end

function CShowWarCtrl.AddWarrior(self, dData)
	local t = { 
		war_id = self.m_WarID,
		camp_id = dData.camp, 
	}
	if dData.partner == 1 then
		t.type = define.Warrior.Type.Partner 
		t.partnerwarrior={
				pflist = {}, 
				wid = dData.wid, 
				parid = ((dData.wid==1) and g_AttrCtrl.pid or -1), 
				pos = dData.pos, 
				status= {
						auto_skill=nil, 
						name = self:GetValue("name", dData.name), 
						status=1,
						mp=1, 
						max_mp=1,
						hp=1, 
						max_hp=1, 
						model_info={shape=self:GetValue("shape", dData.shape), weapon= self:GetValue("weapon", dData.weapon)}},
					}
	else
		t.type = define.Warrior.Type.Player
		t.warrior={
				pflist = {}, 
				wid = dData.wid, 
				pid = ((dData.wid==1) and g_AttrCtrl.pid or -1), 
				pos = dData.pos, 
				status={
						auto_skill=nil, 
						name = self:GetValue("name", dData.name), 
						status=1,
						mp=1, 
						max_mp=1,
						hp=1, 
						max_hp=1, 
						model_info={shape=self:GetValue("shape", dData.shape), weapon= self:GetValue("weapon", dData.weapon)}},
					}
	end
	if dData.wid == 1 then
		self.m_MagicList = {}
		if g_AttrCtrl.pid > 0 then
			local list = g_SkillCtrl:GetSchoolSkillListData(g_AttrCtrl.school, g_AttrCtrl.school_branch)
			for i, dSkill in ipairs(list) do
				if dSkill.type == 1 or dSkill.type == 3 then
					table.insert(self.m_MagicList, dSkill.skill_id)
				end
			end
		end
	end
	netwar.GS2CWarAddWarrior(t)
end

function CShowWarCtrl.AddCmd(self, dData)
	local f = self[dData.cmd_name]
	if f then
		f(self, dData.arg_list)
	else
		printerror("CShowWarCtrl.AddCmd"..dData.cmd_name)
	end
end

function CShowWarCtrl.GetList(self, s, f)
	local t = string.split(s, "-")
	for i, v in ipairs(t) do
		t[i] = f(v)
	end
	return t
end

--Cmd Start
function CShowWarCtrl.BoutStart(self, lArgs)
	local t = {
		war_id = self.m_WarID, 
		bout_id = tonumber(lArgs[1]),
		left_time = 30,
	}
	netwar.GS2CWarBoutStart(t)
end

function CShowWarCtrl.BoutEnd(self, lArgs)
	local t = {
		war_id = self.m_WarID, 
		bout_id = tonumber(lArgs[1]),
	}
	netwar.GS2CWarBoutEnd(t)
end

function CShowWarCtrl.Skill(self, lArgs)
	local t = {
		war_id = self.m_WarID, 
		action_wlist = {tonumber(lArgs[1])}, 
		select_wlist = self:GetList(lArgs[2], tonumber), 
		skill_id = self:GetValue("skill", lArgs[3]),
		magic_id = tonumber(lArgs[4]),
	}
	netwar.GS2CWarSkill(t)
end

function CShowWarCtrl.WarriorStatus(self, lArgs)
	local t = {
		war_id = self.m_WarID, 
		wid = tonumber(lArgs[1]), 
		status =
		{
			status = tonumber(lArgs[2]),
		}
	}
	netwar.GS2CWarWarriorStatus(t)
end

function CShowWarCtrl.Damage(self, lArgs)
	local t = {
		war_id = self.m_WarID, 
		wid = tonumber(lArgs[1]), 
		type = 1, 
		iscrit = tonumber(lArgs[2]),
		damage = tonumber(lArgs[3]),
	}
	netwar.GS2CWarDamage(t)
end

function CShowWarCtrl.Wait(self, lArgs)
	local oCmd = CWarCmd.New(function()
			local oWarrior = g_WarCtrl:GetWarrior(1)
			if oWarrior then
				oWarrior:WaitTime(tonumber(lArgs[1]))
				g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
			end
		end)
	g_WarCtrl:InsertCmd(oCmd)
end

function CShowWarCtrl.Chat(self, lArgs)
	local oCmd = CWarCmd.New(function()
			local oWarrior = g_WarCtrl:GetWarrior(tonumber(lArgs[1]))
			if oWarrior then
				local oMsg = CChatMsg.New(0, {text = tostring(lArgs[2])})
				oWarrior:ChatMsg(oMsg)
			end
		end)
	g_WarCtrl:InsertCmd(oCmd)
end

function CShowWarCtrl.GoBack(self, lArgs)
	local t = {
		war_id = self.m_WarID, 
		action_wid = tonumber(lArgs[1])
	}
	netwar.GS2CWarGoback(t)
end

function CShowWarCtrl.End(self, lArgs)
	local oCmd = CWarCmd.New(function() 
			if self.m_EndCb then
				self.m_EndCb(self)
				self.m_EndCb = nil
			else
				self:StopShowWar()
			end
		end)
	g_WarCtrl:InsertCmd(oCmd)
end

function CShowWarCtrl.StopShowWar(self)
	self.m_WarID = nil
	self.m_MagicList = {}
	g_WarCtrl:End()
	netplayer.C2GSLeaveWatchWar()
end

--Cmd End

return CShowWarCtrl