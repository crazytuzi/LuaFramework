module(..., package.seeall)

--GS2C--

function GS2CGameCardStart(pbdata)
	local num = pbdata.num --卡牌数量
	local endtime = pbdata.endtime --剩余时间
	local memlist = pbdata.memlist --成员信息列表
	--todo
	CYJFbResultView:ShowView(function(oView)
		oView:SetContent(num, endtime, memlist)
	end)
end

function GS2COpenCardInfo(pbdata)
	local cardlist = pbdata.cardlist
	--todo
	local oView = CYJFbResultView:GetView()
	if oView then
		oView:RefreshResult(cardlist)
	end
end

function GS2CMemCardInfo(pbdata)
	local info = pbdata.info
	local cardlist = pbdata.cardlist
	--todo
	local oView = CYJFbResultView:GetView()
	if oView then
		oView:UpdateMemInfo(info, cardlist)
	end
end

function GS2CFinalMemCardInfo(pbdata)
	local info = pbdata.info
	local cardlist = pbdata.cardlist
	--todo
	local oView = CYJFbResultView:GetView()
	if oView then
		oView:RefreshFinal(info, cardlist)
	end
end


--C2GS--

function C2GSMiniGameOp(name, cmds)
	local t = {
		name = name,
		cmds = cmds,
	}
	g_NetCtrl:Send("minigame", "C2GSMiniGameOp", t)
end

function C2GSGameCardEnd(name)
	local t = {
		name = name,
	}
	g_NetCtrl:Send("minigame", "C2GSGameCardEnd", t)
end

