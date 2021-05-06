module(..., package.seeall)

--GS2C--

function GS2CLoginSummon(pbdata)
	local summondata = pbdata.summondata
	local extsize = pbdata.extsize --拓展格子数量
	local fightid = pbdata.fightid --参战宠物id
	--todo
	g_SummonCtrl:SetInitPropertyInfo(summondata,fightid)
end

function GS2CAddSummon(pbdata)
	local summondata = pbdata.summondata
	--todo
	g_SummonCtrl:AddSummon(summondata)	
end

function GS2CDelSummon(pbdata)
	local id = pbdata.id
	local newid = pbdata.newid --洗宠时这个发新宠id，正常删除为0
	--todo
	g_SummonCtrl:GS2CDelSummon(id,newid)
end

function GS2CSummonPropChange(pbdata)
	local id = pbdata.id
	local summondata = pbdata.summondata
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(summondata,"summon")
	g_SummonCtrl:UpdateMaskInfo(dDecode,id)
end

function GS2CSummonSetFight(pbdata)
	local id = pbdata.id --参战id，无参战发0
	--todo
	g_SummonCtrl:SetFightid(id)
	g_WarCtrl:FightSummonChange()
end

function GS2CSummonAutoAssignScheme(pbdata)
	local id = pbdata.id
	local switch = pbdata.switch --1.开，0.关
	local scheme = pbdata.scheme --自动加点方案
	--todo
end

function GS2CWashSummonUI(pbdata)
	--todo
end

function GS2CSummonCombineResult(pbdata)
	local id1 = pbdata.id1
	local id2 = pbdata.id2
	local resultid = pbdata.resultid
	--todo
	g_SummonCtrl:ReceiveCombineSummon(id1,id2,resultid)
end

function GS2CSummonFollow(pbdata)
	local id = pbdata.id --跟随宠物的id，没有跟随发0
	--todo
	g_SummonCtrl:ReceiveFollowId(id)
end

function GS2CSummonTrainInfo(pbdata)
	local id = pbdata.id --宠物id
	local useapt = pbdata.useapt --使用宠物资质丹次数
	local usegrow = pbdata.usegrow --使用宠物成长丹次数
	local freepoint = pbdata.freepoint --是否免费重置过属性，1.已重置，0.没
	--todo
end


--C2GS--

function C2GSWashSummon(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSWashSummon", t)
end

function C2GSStickSkill(summid, itemid)
	local t = {
		summid = summid,
		itemid = itemid,
	}
	g_NetCtrl:Send("summon", "C2GSStickSkill", t)
end

function C2GSSummonSkillLevelUp(summid, skid)
	local t = {
		summid = summid,
		skid = skid,
	}
	g_NetCtrl:Send("summon", "C2GSSummonSkillLevelUp", t)
end

function C2GSSummonChangeName(summid, name)
	local t = {
		summid = summid,
		name = name,
	}
	g_NetCtrl:Send("summon", "C2GSSummonChangeName", t)
end

function C2GSSummonSetFight(summid, fight)
	local t = {
		summid = summid,
		fight = fight,
	}
	g_NetCtrl:Send("summon", "C2GSSummonSetFight", t)
end

function C2GSReleaseSummon(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSReleaseSummon", t)
end

function C2GSSummonAssignPoint(summid, scheme)
	local t = {
		summid = summid,
		scheme = scheme,
	}
	g_NetCtrl:Send("summon", "C2GSSummonAssignPoint", t)
end

function C2GSSummonAutoAssignScheme(summid, scheme)
	local t = {
		summid = summid,
		scheme = scheme,
	}
	g_NetCtrl:Send("summon", "C2GSSummonAutoAssignScheme", t)
end

function C2GSSummonOpenAutoAssign(summid, flag)
	local t = {
		summid = summid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonOpenAutoAssign", t)
end

function C2GSSummonRequestAuto(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSSummonRequestAuto", t)
end

function C2GSBuySummon(typeid)
	local t = {
		typeid = typeid,
	}
	g_NetCtrl:Send("summon", "C2GSBuySummon", t)
end

function C2GSCombineSummon(summid1, summid2)
	local t = {
		summid1 = summid1,
		summid2 = summid2,
	}
	g_NetCtrl:Send("summon", "C2GSCombineSummon", t)
end

function C2GSSummonFollow(summid, flag)
	local t = {
		summid = summid,
		flag = flag,
	}
	g_NetCtrl:Send("summon", "C2GSSummonFollow", t)
end

function C2GSUseSummonExpBook(summid, cnt)
	local t = {
		summid = summid,
		cnt = cnt,
	}
	g_NetCtrl:Send("summon", "C2GSUseSummonExpBook", t)
end

function C2GSUseAptitudePellet(summid, aptitude)
	local t = {
		summid = summid,
		aptitude = aptitude,
	}
	g_NetCtrl:Send("summon", "C2GSUseAptitudePellet", t)
end

function C2GSUseGrowPellet(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSUseGrowPellet", t)
end

function C2GSUsePointPellet(summid, attr)
	local t = {
		summid = summid,
		attr = attr,
	}
	g_NetCtrl:Send("summon", "C2GSUsePointPellet", t)
end

function C2GSReqSummonTrainInfo(summid)
	local t = {
		summid = summid,
	}
	g_NetCtrl:Send("summon", "C2GSReqSummonTrainInfo", t)
end

