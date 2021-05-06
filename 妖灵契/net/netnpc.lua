module(..., package.seeall)

--GS2C--

function GS2CNpcSay(pbdata)
	local sessionidx = pbdata.sessionidx
	local npcid = pbdata.npcid
	local shape = pbdata.shape
	local name = pbdata.name
	local text = pbdata.text
	local fight = pbdata.fight --是否可挑战
	--todo
	printc(" fight ", pbdata.fight)
	g_DialogueCtrl:GS2CNpcSay(pbdata)
end

function GS2CNpcFightInfoList(pbdata)
	local info_list = pbdata.info_list
	--todo
	g_MapBookCtrl:UpdateNpcInfo(info_list)
end


--C2GS--

function C2GSClickNpc(npcid)
	local t = {
		npcid = npcid,
	}
	g_NetCtrl:Send("npc", "C2GSClickNpc", t)
end

function C2GSNpcRespond(npcid, answer)
	local t = {
		npcid = npcid,
		answer = answer,
	}
	g_NetCtrl:Send("npc", "C2GSNpcRespond", t)
end

function C2GSClickConvoyNpc(npcid)
	local t = {
		npcid = npcid,
	}
	g_NetCtrl:Send("npc", "C2GSClickConvoyNpc", t)
end

