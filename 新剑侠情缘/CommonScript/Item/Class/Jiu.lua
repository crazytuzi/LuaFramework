
local tbJiuItem	= Item:GetClass("jiu");
-- local JIU_AVOID_TIME = 1.5 * 3600; -- 酒的有效期限

--普通酒
tbJiuItem.nTemplateId   = 1927;
tbJiuItem.nJiuSkillId 	= 2306;
-- tbJiuItem.nLastTime		= 180;							-- 各种酒使用后的持续时间
tbJiuItem.tbJiuName		= {XT("陈年女儿红")};				-- 每一种酒的Name
tbJiuItem.tbQuotiety	= {								-- 同时喝一种酒的数量对应的加经验的倍数(百分比)
	[0]	= 100,
	[1]	= 110,
	-- [2]	= 120,
	-- [3]	= 130,
	-- [4]	= 140,
	-- [5]	= 150,
	-- [6]	= 160,
};

-- function tbJiuItem:OnInit()
-- 	it.SetTimeOut(1, JIU_AVOID_TIME)
-- end


-- 右键点击时
function tbJiuItem:OnUse(it)
	local dwTemplateId = it.dwTemplateId
	local nType = KItem.GetItemExtParam(dwTemplateId, 1) 
	local nDuraTime = KItem.GetItemExtParam(dwTemplateId, 2)
	if not nType or not nDuraTime or  nDuraTime == 0 or nType == 0 then
		me.CenterMsg("酒道具参数错误")
		return 0 
	end
	if me.GetNpc().GetSkillState(self.nJiuSkillId)  then
		me.CenterMsg("少侠酒劲未过，还是稍后再喝吧")
		return 0
	end

--  技能Id, 等级, 状态类型(类型为0取的是表中时间,1取的是后面自定义时间), 时间, 死亡后是否消失, 覆盖原技能效果.
	me.AddSkillState(self.nJiuSkillId, nType, 1, nDuraTime * Env.GAME_FPS, 0, 1);
	me.CenterMsg("你喝了一瓶陈年女儿红")
	--if me.dwTeamID ~= 0 then
	--	ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, string.format("「%s」喝了一瓶%s", me.szName, it.szName), me.dwTeamID)
	--else
	--	me.Msg(string.format("你喝了一瓶%s", it.szName))
	--end

	return 1;
end

-- 功能:	计算同时喝一种酒的最大玩家的数量
-- 参数:	tbPlayer	队伍玩家的Id
function tbJiuItem:CalcQuotiety(tbPlayer)
	local tbDrinkedNum = {}
	for i, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			local tbState = pPlayer.GetNpc().GetSkillState(self.nJiuSkillId);
			if tbState then
				local nSkillLevel = tbState.nSkillLevel
				if (nSkillLevel > 0) then
					tbDrinkedNum[nSkillLevel] = tbDrinkedNum[nSkillLevel] or 0
					tbDrinkedNum[nSkillLevel] = tbDrinkedNum[nSkillLevel] + 1;
				end	
			end
		end
	end
	local nMaxTimes		= 0;
	local nCurDrinkId	= 0;
	for nType, v in pairs(tbDrinkedNum) do
		if (v > nMaxTimes) then
			nCurDrinkId = nType;
			nMaxTimes = v;
		end
	end

	if nMaxTimes > 4 then
		nMaxTimes = 4;
	end
	return nMaxTimes, (self.tbQuotiety[nCurDrinkId] - 100) * nMaxTimes + 100, self.tbJiuName[nCurDrinkId]
end
