module(..., package.seeall)

--GS2C--

function GS2CTitleInfoList(pbdata)
	local infos = pbdata.infos
	--todo
	g_TitleCtrl:OnReceiveTitleList(infos)
end

function GS2CUpdateTitleInfo(pbdata)
	local info = pbdata.info
	--todo
	g_TitleCtrl:UpdateTitleInfo(info)
end

function GS2CAddTitleInfo(pbdata)
	local info = pbdata.info
	--todo
	g_TitleCtrl:AddTitleInfo(info)
end

function GS2CRemoveTitles(pbdata)
	local tidlist = pbdata.tidlist
	--todo
	g_TitleCtrl:RemoveTitles(tidlist)
end


--C2GS--

function C2GSUseTitle(tid, flag)
	local t = {
		tid = tid,
		flag = flag,
	}
	g_NetCtrl:Send("title", "C2GSUseTitle", t)
end

function C2GSTitleInfoList()
	local t = {
	}
	g_NetCtrl:Send("title", "C2GSTitleInfoList", t)
end

