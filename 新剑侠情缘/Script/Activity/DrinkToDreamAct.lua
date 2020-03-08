local tbAct = Activity.DrinkToDreamAct;

local tbActSetting = Activity:GetUiSetting("DrinkToDreamAct")
tbActSetting.nShowLevel = 20
tbActSetting.szTitle    = "大醉江湖梦一场"
tbActSetting.szUiName   = "Normal"
tbActSetting.szContent  = [[
[FFFE0D]大醉江湖梦一场活动开始了！[-]
[FFFE0D]活动时间：[-][c8ff00]%d年%d月%d日4点0分-%d年%d月%d日23点59分[-]
[FFFE0D]参与等级：[-]20级
    不知不觉，忘忧酒馆开业已近一年，承蒙诸位武林同仁光顾，酒馆生意还算红火，因此酒馆为武林中每位大侠准备了一坛酒，名为[ff8f06][url=openwnd:意平, ItemTips, "Item", nil, 10615][-]，大侠饮后可向他人说出平时不敢说或者不能说的话。
[FFFE0D]选择对象 撰写衷言[-]
    大侠可在使用[ff8f06][url=openwnd:意平, ItemTips, "Item", nil, 10615][-]后写下[FFFE0D]酒后衷言[-]，最多可选择三个好友寄出。每份衷言第一次提交[FFFE0D]免费[-]，后续修改每次需消耗[FFFE0D]200元宝[-]，且每日只允许修改[FFFE0D]2次[-]。
[FFFE0D]分享求赞 提升排名[-]
    大侠可以把自己的衷言分享到好友频道，亲密度超过[FFFE0D]15级[-]的好友点击衷言链接可以打开自己的衷言并可以点赞，系统会根据玩家获得的赞的总数进行排行。每个玩家每天可给别人点赞[FFFE0D]10次[-]，可给同一份衷言点赞[FFFE0D]1次[-]。
    给其他玩家点赞需消耗[aa62fc][url=openwnd:共鸣, ItemTips, "Item", nil, 10616][-]，打开[FFFE0D]每日活跃宝箱[-]后有概率获得[aa62fc][url=openwnd:共鸣, ItemTips, "Item", nil, 10616][-]。
    注：给写给自己的衷言点赞，写衷言的大侠会收到[FFFE0D]2个[-]赞哦！
[FFFE0D]召回好友 额外奖励[-]
    如果大侠写衷言的对象已经退隐江湖超过[FFFE0D]15天[-]了，且收到衷言后在活动期间上线，则双方都能收到[FFFE0D]5000贡献[-]和[aa62fc][url=openwnd:花草礼包, ItemTips, "Item", nil, 3698][-]！快去邀请隐士们重回江湖吧！
[FFFE0D]结算排行 发放奖励[-]
    [FFFE0D]2019年5月4日23:59:59[-]后将进入时长为[FFFE0D]3天[-]的展示期，展示期间将不能修改衷言以及点赞，展示期结束时会按照每个玩家的总获赞数进行排行，并发放奖励，奖励如下：
第1名---------------[e6d012][url=openwnd:六阶·诉衷情礼盒, ItemTips, "Item", nil, 10617][-]
第2至第3名----------[ff8f06][url=openwnd:五阶·诉衷情礼盒, ItemTips, "Item", nil, 10618][-]
第4至第5名----------[ff578c][url=openwnd:四阶·诉衷情礼盒, ItemTips, "Item", nil, 10619][-]
第6至第10名---------[aa62fc][url=openwnd:三阶·诉衷情礼盒, ItemTips, "Item", nil, 10620][-]
第11至第30名--------[11adf6][url=openwnd:二阶·诉衷情礼盒, ItemTips, "Item", nil, 10621][-]
第31至第100名-------[64db00][url=openwnd:一阶·诉衷情礼盒, ItemTips, "Item", nil, 10622][-]
]]
tbActSetting.FnCustomData = function (szKey, tbData)
    local tbTime1 = os.date("*t", tbData.nStartTime)
    local tbTime2 = os.date("*t", tbData.nEndTime)
    return {string.format(tbActSetting.szContent, tbTime1.year, tbTime1.month, tbTime1.day,tbTime2.year, tbTime2.month, tbTime2.day)}
end

-- 同步我的数据
function tbAct:OnSyncMyData(tbData)
	self.tbMyData       = tbData or {}
	self.tbPlayerSincereWords     = {}
	self.tbFriendSincereWordsList = {}
	self.nRequestTime   = 0
	self.nOperationEndTime = tbData.nOperationEndTime;
end

tbAct.tbPlayerQS = tbAct.tbPlayerQS or {}
tbAct.tbReadCd = tbAct.tbReadCd or {}

-- 提交衷言
function tbAct:OnCommitCallBack(nIdx, tbSincereWords)
	local tbData = self:GetPlayerData(me.dwID)
	local szMsg  = tbData.tbSincereWords[nIdx] and "修改成功" or "提交成功"
	tbData.tbSincereWords[nIdx] = tbSincereWords
	--TODO
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA)
	me.CenterMsg(szMsg)
end

-- 阅读衷言服务器回调
function tbAct:OnReadRsp(nPlayer, tbData, nIdx)
	if not tbData then
		me.CenterMsg("没找到该玩家的衷言")
		return
	end
	if not self.tbPlayerSincereWords[nPlayer] then
		self.tbPlayerSincereWords[nPlayer] = tbData
	else
		self.tbPlayerSincereWords[nPlayer].szName = tbData.szName
		self.tbPlayerSincereWords[nPlayer].tbSincereWords = self.tbPlayerSincereWords[nPlayer].tbSincereWords or {}
		for i = 1, self.SINCEREWORDS_COUNT do
			self.tbPlayerSincereWords[nPlayer].tbSincereWords[i] = tbData.tbSincereWords[i] or self.tbPlayerSincereWords[nPlayer].tbSincereWords[i]
		end
	end
	Ui:OpenWindow("DrinkToDream_SincereWordsEdit", nPlayer, nIdx)
end

-- 衷言列表回调
function tbAct:OnSyncSincereWordsList(tbSincereWordsList)
	self.tbFriendSincereWordsList = tbSincereWordsList or {}
	--TODO
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA, 1)
end

-- 
function tbAct:OpenSincereWords(nPlayer, nIdx)
	if nPlayer == me.dwID then
		Ui:OpenWindow("DrinkToDream_SincereWordsEdit", nPlayer, nIdx)
		return
	end

	local tbVersion = nil
	if self.tbPlayerSincereWords[nPlayer] then
		self.tbReadCd[nPlayer] = self.tbReadCd[nPlayer] or 0
		if GetTime() - self.tbReadCd[nPlayer] < 5 then
			Ui:OpenWindow("DrinkToDream_SincereWordsEdit", nPlayer, nIdx)
			return
		end
		self.tbReadCd[nPlayer] = GetTime()
		tbVersion  = {}
		local tbSincereWords = (self.tbPlayerSincereWords[nPlayer] or {}).tbSincereWords or {}
		for i = 1, self.SINCEREWORDS_COUNT do
			tbVersion[i] = tbSincereWords[i] and tbSincereWords[i].nVersion or nil
		end
	end
	RemoteServer.DrinkToDreamClientCall("Read", nPlayer, tbVersion, nIdx or 1)
end

function tbAct:GetPlayerData(nPlayer)
	if nPlayer == me.dwID then
		self.tbMyData = self.tbMyData or {}
		self.tbMyData.tbSincereWords = self.tbMyData.tbSincereWords or {}
		return self.tbMyData
	else
		return self.tbPlayerSincereWords[nPlayer]
	end
end

function tbAct:GetFriendSincereWordsList()
	self.tbFriendSincereWordsList = self.tbFriendSincereWordsList or {}
	local nCD = #self.tbFriendSincereWordsList < self.MAINUI_SINCEREWORDS_COUNT and 60*3 or 60*60*2
	if not self.nRequestTime or (GetTime() - self.nRequestTime) >= nCD then
		self.nRequestTime = GetTime()
		RemoteServer.DrinkToDreamClientCall("ReqSincereWordsList")
	end
	return self.tbFriendSincereWordsList
end

function tbAct:Commit(tbSincereWordsData, bConfirm)
	local tbData      = self:GetPlayerData(me.dwID)
	local bExist      = tbData.tbSincereWords[tbSincereWordsData.nIdx]
	local szCheckFunc = bExist and "CheckModify" or "CheckCommit"
	local szType      = bExist and "Modify" or "Commit"
	local bRet, szMsg = self[szCheckFunc](self, tbData, tbSincereWordsData, me.dwID, me.dwKinId)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	if not bConfirm then
		local szMsg = szType == "Commit" and
			string.format("每封衷言首次提交免费，后续修改提交需要消耗[FFFE0D]%d元宝[-]，确认提交吗？", self.MODITY_COST)
			or string.format("修改提交需要消耗[FFFE0D]%d元宝[-]，确认提交吗？关闭衷言界面可放弃修改", self.MODITY_COST)
		me.MsgBox(szMsg,
			{{"确认", Activity.DrinkToDreamAct.Commit, Activity.DrinkToDreamAct, tbSincereWordsData, true}, {"取消"}})
		return
	end
	if szType == "Modify" and me.GetMoney("Gold") < self.MODITY_COST then
		me.CenterMsg("元宝不足！请先去充值")
		Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
		return
	end
	RemoteServer.DrinkToDreamClientCall(szType, tbSincereWordsData)
end

function tbAct:Like(nPlayerId, nSincereWordsIdx)
	local tbData = self:GetPlayerData(me.dwID)
	local bRet, szMsg = self:CheckLike(tbData, me, nPlayerId, nSincereWordsIdx)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.DrinkToDreamClientCall("Like", nPlayerId, nSincereWordsIdx)
end

function tbAct:OnLikeCallBack(nBelonger, nIdx, nLikeCount)
	local tbData = self:GetPlayerData(me.dwID)
	tbData.nLikeCount = (tbData.nLikeCount or 0) + 1
	tbData.tbLikeList = tbData.tbLikeList or {}
	tbData.tbLikeList[nBelonger] = tbData.tbLikeList[nBelonger] or {nCount = 0, tbIdxCount = {}}
	tbData.tbLikeList[nBelonger].nCount = tbData.tbLikeList[nBelonger].nCount + 1
	tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] = (tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] or 0) + 1

	local tbBelong = self:GetPlayerData(nBelonger)
	if tbBelong and tbBelong.tbSincereWords and tbBelong.tbSincereWords[nIdx] then
		tbBelong.tbSincereWords[nIdx].nLikeCount = (tbBelong.tbSincereWords[nIdx].nLikeCount or 0) + nLikeCount
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA)
	me.CenterMsg("点赞成功")
end

function tbAct:OnBeLikeCallBack(nIdx, nLikeCount)
	if not self.tbMyData or not self.tbMyData.tbSincereWords or not self.tbMyData.tbSincereWords[nIdx] then
		return
	end
	self.tbMyData.tbSincereWords[nIdx].nLikeCount = nLikeCount
end

function tbAct:OnSyncSincereWordsList(tbSincereWordsList)
	self.tbFriendSincereWordsList = tbSincereWordsList or {}
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DRINKTODREAM_DATA, 1)
end