local tbUi = Ui:CreateClass("ChuangGongPanel");
tbUi.tbBaseTime = 
{
	["TeacherStudent"] = ChuangGong.TIMES,
	["SelfChuangGong"] = ChuangGong.nSelfTimes,
	["QingMingAct"] = Activity.QingMingAct.nWorshipTimes,
	["PeachBringUp"] = House.tbPeach.FAIRYLAND_BRINGUP_TIME;
}

tbUi.tbTitleDes = 
{
	["SelfChuangGong"] = "修炼中...",
	["QingMingAct"] = "祭拜中...",
	["ActivityFuben"] = "打坐中...",
	["PeachBringUp"] = "护持中...";
}

--直接查看到别的玩家数据的用ViewRole:OpenWindow 打开
function tbUi:OnOpenEnd(nGetAdd, nSendAdd, bMeGet,dwHimId,szSenderName, bNotChuanGong, szType)	
	self.bMeGet = bMeGet
	self.dwHimId = dwHimId
	self.szSenderName = szSenderName
	self.bIsChuanGong = not bNotChuanGong
	self.szType = szType or "Default"
	self.pPanel:ProgressBar_SetValue("ProgBar", 0)
	self.pPanel:Label_SetText("lbProgBar",  "0%")
	self.pPanel:SetActive("Label", self.bIsChuanGong)
	self.pPanel:Label_SetText("Label",self.tbTitleDes[self.szType] or "传功中...")

	if szType == "PeachBringUp" then
		self.nProgress = 0;
		self.nMaxTime = tbUi.tbBaseTime[szType];
		Timer:Register(Env.GAME_FPS, self.UpdateProgress, self);
	end
end

function tbUi:UpdateProgress()
	self.nProgress = self.nProgress + 1;
	local nBar = self.nProgress / self.nMaxTime;

	self.pPanel:ProgressBar_SetValue("ProgBar", nBar);
	self.pPanel:Label_SetText("lbProgBar",  string.format("%d%%", nBar * 100));
	return nBar < 1;
end

function tbUi:OnChuangGongEnd()
	if self.bMeGet then
		me.CenterMsg("传功完成，你获得了大量的经验", true)
		if self.szType=="TeacherStudent" then
			-- do nothing
		else
			if not FriendShip:IsFriend(me.dwID, self.dwHimId) then
			   me.MsgBox(string.format("传功完成，是否申请添加 [FFFE0D]%s[-] 为好友？",self.szSenderName or "对方"), 
	            {
	                {"申请", function () 
	                	RemoteServer.RequestAddFriend(self.dwHimId)		-- 被请求者请求加好友
	                	ChuangGong:TryResetChuangGong()
	                 end},
	                {"取消", function ()
	                	ChuangGong:TryResetChuangGong()
	                end},
	            })
			else
				ChuangGong:TryResetChuangGong()
			end
			local nCount = ChuangGong:GetDegree(me, "ChuangGong")
			if nCount <= 0 then
				me.SendBlackBoardMsg("你感到丹田充盈，今日无法再接受传功了",true)
			end
		end
	else
		if self.szType=="TeacherStudent" then
			me.CenterMsg("传功完成，你获得了大量的经验", true)
		elseif self.szType=="SelfChuangGong" then
			me.SendBlackBoardMsg("打坐修炼完毕，你获得了大量经验",true)
			local nAccept = ChuangGong:GetDegree(me, "ChuangGong")
			if nAccept > 0 then
				me.MsgBox(string.format("当前还剩[FFFE0D]%d次[-]被传功次数，是否要继续打坐修炼？",nAccept), 
	            {
	                {"继续修炼", function () 
	                	RemoteServer.TrySelfChuanGong()		-- 被请求者请求加好友
	                end},
	                {"暂不修炼"},
	            })
			else
				me.SendBlackBoardMsg("你感到丹田充盈，今日无法再打坐修炼或接受传功了",true)
			end
		elseif self.szType == "QingMingAct" then
			me.CenterMsg("祭拜完成，你获得了大量的经验", true)
		elseif self.szType == "ActivityFuben" then
			me.CenterMsg("打坐完成，你获得了大量的经验", true)
		elseif self.szType == "PeachBringUp" then
			me.CenterMsg("二位大侠护持完毕，桃花树又长大了呢！", true);
		else
			me.CenterMsg( string.format("传功完成，你获得了%d贡献和大量经验", ChuangGong.nSendAddContrib), true)
			local nSend = ChuangGong:GetDegree(me, "ChuangGongSend")
			if nSend > 0 then
				if not ChuangGong.tbWithoutCDVip[me.GetVipLevel()] then
					me.SendBlackBoardMsg("你感到气血沸腾，需30分钟后才可再次传功",true)
				end
			else
				me.SendBlackBoardMsg("你感到丹田虚浮，今日已无法再给其他侠士传功了",true)
			end
		end
	end
end

function tbUi:UpdateGetExp(nRemainTimes)
	nRemainTimes = nRemainTimes or 0
	local nBaseTimes = self.tbBaseTime[self.szType] or ChuangGong.TIMES
	local nVal = self.bIsChuanGong and (1 - nRemainTimes / nBaseTimes) or nRemainTimes
	self.pPanel:ProgressBar_SetValue("ProgBar", nVal)
	self.pPanel:Label_SetText("lbProgBar", math.floor(100 * nVal) .. "%")
	if (self.bIsChuanGong and nRemainTimes <= 0) or (not self.bIsChuanGong and nRemainTimes >= 1) then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function tbUi:OnClose()
	if self.bIsChuanGong then
		self:OnChuangGongEnd();
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE, self.UpdateGetExp, self},
	}
	return tbRegEvent
end