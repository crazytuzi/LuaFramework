local FactionMonkey = FactionBattle.FactionMonkey

FactionMonkey.tbMonkeyData = FactionMonkey.tbMonkeyData or {}

--[[
	数据缓存结构
	FactionMonkey.tbMonkeyData.nStartTime = 0
	FactionMonkey.tbMonkeyData.nChosedSession = 0
	FactionMonkey.tbMonkeyData.nMonkeySession = 0 		-- 目前举行过几次大师兄
	FactionMonkey.tbMonkeyData.tbMonkey = 
	{
		[1] = { 								-- 客户端按届数从小到达排序,因此和服务端的索引不同，投票时按玩家ID投
			nScore = 0,
			nScoreTime = 123456789,
			nSession = 0, 						-- 候选人是第几届新人王
			nPlayerId = 123456789,
			szName = "",
		},
	}

]]

-- 延迟请求数据时间
FactionMonkey.nRequestInterval = 30

function FactionMonkey:SynData()
	if me.nRequestTime and GetTime() < me.nRequestTime then
		return 
	end
	me.nRequestTime = GetTime() + FactionMonkey.nRequestInterval
	RemoteServer.SynFactionMonkeyData()
end

function FactionMonkey:OnSynData(tbMonkeyData)

	FactionMonkey.tbMonkeyData = tbMonkeyData
	if tbMonkeyData.tbMonkey and next(tbMonkeyData.tbMonkey) then
	 	FactionMonkey.tbMonkeyData.tbMonkey = self:SortMonkey(FactionMonkey.tbMonkeyData.tbMonkey)
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_MONKEY)
end

function FactionMonkey:IsMonkeyStarting()
	local nStartTime = FactionMonkey.tbMonkeyData.nStartTime or 0
	return nStartTime ~= 0 and GetTime() > nStartTime
end

function FactionMonkey:CheckVote()
	if not self:IsMonkeyStarting() then
		return false,"评选活动已经结束！"
	end
	return FactionBattle:CheckCommondVote(me)
end

function FactionMonkey:SynSwitch(nStartTime)
	FactionMonkey.tbMonkeyData.nStartTime = nStartTime
end

function FactionMonkey:SortMonkey(tbMonkey)
	local function SortBySession(a,b)
		return a.nSession < b.nSession
	end
	table.sort(tbMonkey,SortBySession)
	return tbMonkey
end

function FactionMonkey:ManageMonkey(tbMonkey)
	local tbResultMonkey = {}
	for nFaction=1,Faction.MAX_FACTION_COUNT do
		if tbMonkey[nFaction] then
			table.insert(tbResultMonkey,tbMonkey[nFaction])
		end
	end
	return tbResultMonkey
end