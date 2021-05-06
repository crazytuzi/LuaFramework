module(..., package.seeall)

--GS2C--

function GS2CreateCLink(pbdata)
	local idx = pbdata.idx
	local rand = pbdata.rand
	--todo
	g_LinkInfoCtrl:SetLinkIdx(rand, idx)
end

function GS2CLinkInfo(pbdata)
	local mask = pbdata.mask
	local idx = pbdata.idx --对应链接索引
	local name = pbdata.name
	local item = pbdata.item
	local partner = pbdata.partner
	local player = pbdata.player
	--todo
	local mask = tonumber("0x"..mask)
	if MathBit.andOp(MathBit.rShiftOp(mask, 4), 1) == 1 then
		g_LinkInfoCtrl:ShowPartnerLink(idx, partner)
	end
	if MathBit.andOp(MathBit.rShiftOp(mask, 3), 1) == 1 then
		g_LinkInfoCtrl:ShowItemLink(idx, item)
	end
	if MathBit.andOp(MathBit.rShiftOp(mask, 5), 1) == 1 then
		g_LinkInfoCtrl:ShowNameLink(idx, player)
	end
end

function GS2CSendCommonChat(pbdata)
	local chat_list = pbdata.chat_list
	--todo
	g_LinkInfoCtrl:UpdateNormalMsg(chat_list)
end


--C2GS--

function C2GSClickLink(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("link", "C2GSClickLink", t)
end

function C2GSLinkName(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("link", "C2GSLinkName", t)
end

function C2GSLinkItem(itemid, rand)
	local t = {
		itemid = itemid,
		rand = rand,
	}
	g_NetCtrl:Send("link", "C2GSLinkItem", t)
end

function C2GSLinkPartner(parid, rand)
	local t = {
		parid = parid,
		rand = rand,
	}
	g_NetCtrl:Send("link", "C2GSLinkPartner", t)
end

function C2GSLinkPlayer(rand)
	local t = {
		rand = rand,
	}
	g_NetCtrl:Send("link", "C2GSLinkPlayer", t)
end

function C2GSEditCommonChat(chat_list)
	local t = {
		chat_list = chat_list,
	}
	g_NetCtrl:Send("link", "C2GSEditCommonChat", t)
end

function C2GSGetCommonChat()
	local t = {
	}
	g_NetCtrl:Send("link", "C2GSGetCommonChat", t)
end

