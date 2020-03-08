
--接受请求是没有nLevel参数的，因为服务器上已经判断过了, 会做比较全的请求
function ChuangGong:AcceptGetChuangGong(dwSendId)
	local nCount = ChuangGong:GetDegree(me, "ChuangGong")
	if nCount <  1 then
		me.BuyTimes("ChuangGong", 1);
		return false
	end

	if not ChuangGong:IsWhiteMap(me.nMapTemplateId) then
		if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or me.nFightMode ~= 0 then
			return false, "您当前所在场景无法进行传功"
		end
	end

	if me.nFightMode ~= 0 then
		return false, "您当前处于战斗状态"
	end

	RemoteServer.RequestGetChuangGong(dwSendId)
	return true
end

function ChuangGong:AcceptSendChuangGong(dwGetId)
	local nCount = ChuangGong:GetDegree(me, "ChuangGongSend")
	if nCount < 1 then
		return false, "您的传功次数已经用完"
	end

	if not ChuangGong:IsWhiteMap(me.nMapTemplateId) then
		if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or me.nFightMode ~= 0 then
			return false, "您当前所在场景无法进行传功"
		end
	end

	if me.nFightMode ~= 0 then
		return false, "您当前处于战斗状态"
	end

	RemoteServer.RequestSendChuangGong(dwGetId)
	return true
end

--发起请求时是没做那么多的检查的
function ChuangGong:RequestGetChuangGong(dwSendId, nHisLevel)
	local bRet, szMsg = ChuangGong:CheckLevelLimi(nHisLevel,me.nLevel)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end	
	local nCount = ChuangGong:GetDegree(me, "ChuangGong")
	if nCount < 1 then
		local nNextVipLevel = DegreeCtrl:GetNextVipDegree("ChuangGong", me)
		if nNextVipLevel then
			local fnConfirmBuy = function ()
				Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
			end
			Ui:OpenWindow("MessageBox", string.format("接受传功次数耗尽，[FFFE0D] 【剑侠V%d】 [-]可增加每日接受传功次数，还有[FFFE0D] 超多福利[-]，是否前往？",  nNextVipLevel), 
				{ {fnConfirmBuy}, {}  }, {"前往", "取消"})

		else
			me.CenterMsg("今天次数已用完")
		end
		return
	end

	if not ChuangGong:IsWhiteMap(me.nMapTemplateId) then
		if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or me.nFightMode ~= 0 then
			me.CenterMsg("您当前所在场景无法进行传功")
			return
		end
	end
	

	RemoteServer.RequestGetChuangGong(dwSendId)
end

function ChuangGong:RequestSendChuangGong(dwGetId, nHisLevel)

	local bRet, szMsg = ChuangGong:CheckLevelLimi(me.nLevel, nHisLevel)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end	
	local nCount = ChuangGong:GetDegree(me, "ChuangGongSend")
	if nCount < 1 then
		me.CenterMsg("您的传功次数已经用完")
		return
	end

	if not ChuangGong:IsWhiteMap(me.nMapTemplateId) then
		if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" or me.nFightMode ~= 0 then
			me.CenterMsg("您当前所在场景无法进行传功")
			return
		end
	end

	RemoteServer.RequestSendChuangGong(dwGetId)
end

function ChuangGong:CheckMap()
	if ChuangGong:IsWhiteMap(me.nMapTemplateId) and Map:GetClassDesc(me.nMapTemplateId) ~= "fight" then
		return true
	end

	if Map:GetClassDesc(me.nMapTemplateId) == "fight" and me.nFightMode == 0 then
		return true
	end

	return false
end

function ChuangGong:GoSafe(fnRequest, szMsg)
	local fnGoSafe = function ()
		local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
		if nX and nY then
			AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, fnRequest)
		else
			me.CenterMsg("您当前所在场景无法进行传功")
		end
	end
	me.MsgBox(szMsg or self.szRequestGoSafeTip, {{"确定", fnGoSafe}, {"取消"}})
end

function ChuangGong:BeginChuangGong(dwGetId, dwSendId, nGetAdd, nSendAdd, nChuanGongMap,szSenderName, szType)
	self.tbWaitForOpenUIParam = nil;
	local bMeGet = not dwGetId;
	local dwHimId = dwGetId or dwSendId
	
	if  me.nMapTemplateId == nChuanGongMap then
		Ui:OpenWindow("ChuangGongPanel", nGetAdd, nSendAdd, bMeGet,dwHimId,szSenderName, false, szType);
		if House:IsInHouseMap() then
			UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SWITCH_PLACE);
		end
	else
		self.tbWaitForOpenUIParam = {nGetAdd, nSendAdd, bMeGet,dwHimId,szSenderName};
		UiNotify:RegistNotify(UiNotify.emNOTIFY_LOAD_RES_FINISH, self.OnMapLoaded, self)
	end
end

function ChuangGong:OnMapLoaded()
	if self.tbWaitForOpenUIParam then
		Ui:OpenWindow("ChuangGongPanel", unpack(self.tbWaitForOpenUIParam));
		self.tbWaitForOpenUIParam = nil;
	end

	if House:IsInHouseMap() then
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SWITCH_PLACE);
	end
	
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_LOAD_RES_FINISH, self)	
end

function ChuangGong:OnLogin(bIsReconnect)
	if bIsReconnect then
		Ui:CloseWindow("ChuangGongPanel");
	end
end

function ChuangGong:SendOne(nRemainTimes)
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE,nRemainTimes)
end

function ChuangGong:GetDegreeInfo()
	local szDegree = Calendar:GetDegree("ChuangGong")
	local szInfo = string.format("被传: %s", szDegree)

	local szSendTimes
	if me.nLevel >= self.nSendMinLevel then
		szDegree = Calendar:GetDegree("ChuangGongSend")
		szInfo = string.format("%s\n传功: %s", szInfo, szDegree)
	else
		szInfo = string.format("%s\n传功: %d级开放", szInfo, self.nSendMinLevel)
	end
	return szInfo
end

function ChuangGong:TryResetChuangGong()
	local nChuangGongTimes = ChuangGong:GetDegree(me, "ChuangGong")
	if nChuangGongTimes <= 0 and RegressionPrivilege:GetChuanGongTimes(me) > 0 then
		Timer:Register(1, function ()
			me.MsgBox(string.format("传功完成，是否重置被传次数"), 
	            {
	                {"重置", function () 
	                	RemoteServer.OnCallPregressionPrivilege("TryRestoreChuanGong")
	                 end},
	                {"取消"},
	            })
		 end);
	end
end
