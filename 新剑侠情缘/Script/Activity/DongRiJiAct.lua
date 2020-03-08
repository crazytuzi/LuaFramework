Activity.DongRiJiAct = Activity.DongRiJiAct or {}
local tbAct = Activity.DongRiJiAct;
--玩家登出时的数据清空。
function tbAct:OnLogout()
	self.tbPlayerData = nil; 
	self.tbSendGiftData = nil;
	self.tbReceGiftData = nil;
	self.tbReadySendData = nil;
	self.tbFriendsMsg = nil;
end

----------------------服务器回调函数--------------------

function tbAct:OnModifyWishesCallBack(nWishID , szMsg)
	Log("Success Modify Wishes" , nWishID);
	if self.tbPlayerData == nil then return end;
	self.tbPlayerData.nWishID = nWishID; 

	me.CenterMsg("成功许下了愿望");
	self:FlushMainPanel();
end

function tbAct:OnShowSendGiftRsp(tbListGiftMsg)
	Log("Success Get SendMsg");
	self.tbSendGiftData = tbListGiftMsg or self.tbSendGiftData;
	self:FlushMainPanel();
end

function tbAct:OnShowReceGiftRsp(tbListGiftMsg)
	Log("Success Get ReceMsg");
	self.tbReceGiftData = tbListGiftMsg or self.tbReceGiftData;
	self:FlushMainPanel();
end

function tbAct:OnGetMyMsgRsp(tbMyMsg)
	Log("Success Get MyMsg");
	self.tbPlayerData = tbMyMsg;
	self:FlushMainPanel();
end

function tbAct:OnGetFriendsMsgRsp(tbFriendsMsg , tbLossPlayer)
	self.tbFriendsMsg = {};
	for nId, nWishTag in pairs(tbFriendsMsg) do
		self.tbFriendsMsg[nId] = self.tbFriendsMsg[nId] or {};
		self.tbFriendsMsg[nId].nTag = nWishTag;
	end
	for nId,_ in pairs(tbLossPlayer) do
		self.tbFriendsMsg[nId] = self.tbFriendsMsg[nId] or {};
		self.tbFriendsMsg[nId].bIsLoss = true;
	end
	self:FlushMainPanel();
end

--领取礼物奖励
function tbAct:OnGetAwardRsp(nSendValue, nHasAward)
	me.CenterMsg("您成功的领取了奖励");
	self.tbPlayerData.nSendValue = nSendValue;
	self.tbPlayerData.nHasAward = nHasAward;
	self:FlushMainPanel();
end

--领取礼物。
function tbAct:OnReceiveGiftRsp(tbGiftMsg)
	me.CenterMsg("您成功的领取了奖励");
	if not tbGiftMsg or not tbGiftMsg.nGiftID then
	 	return; 
	end
	if self.tbPlayerData then
		self.tbPlayerData.tbIsForUse = self.tbPlayerData.tbIsForUse or {};
		self.tbPlayerData.tbIsForUse[tbGiftMsg.nGiftID] = false;
	end
	self:FlushMainPanel();
end

function tbAct:OnSuccessSendGift(tbGiftMsg , bSuccessHelp)
	if not tbGiftMsg or not tbGiftMsg.nGiftID then
	 	return; 
	end
	me.CenterMsg("大侠成功送出礼物")
	--更新送礼数据。
	if self.tbPlayerData then 
		self.tbPlayerData.tbSendGiftData = self.tbPlayerData.tbSendGiftData or {};
		table.insert(self.tbPlayerData.tbSendGiftData , tbGiftMsg.nGiftID);
		if bSuccessHelp then
			self.tbPlayerData.nSendValue = self.tbPlayerData.nSendValue or 0;
			self.tbPlayerData.nSendValue = self.tbPlayerData.nSendValue + 1;
			self:FlushMainPanel();
			Log("成功了满足了愿望")
		else
			Log("失败了，不能满足愿望");
		end
	end
	if self.tbSendGiftData then
		table.insert(self.tbSendGiftData,tbGiftMsg);
	end
end

--收到礼物
function tbAct:OnSuccessReceGiftRsp(tbGiftMsg )
	if not tbGiftMsg or not tbGiftMsg.nGiftID then
	 	return; 
	end
	Log("shou li");
	--更新收礼数据
	local tbData = self.tbPlayerData;
	if tbData then
		tbData.tbReceGiftData = tbData.tbReceGiftData or {};
		table.insert(tbData.tbReceGiftData, tbGiftMsg.nGiftID);
		tbData.tbIsForUse = tbData.tbIsForUse or {};
		tbData.tbIsForUse[tbGiftMsg.nGiftID] = true;
	end
	if self.tbReceGiftData then
		table.insert(self.tbReceGiftData,tbGiftMsg);
	end
end

--服务端调用,基础数据同步,收礼,修改愿望等。
function tbAct:FlushPlayerDataRsp(tbData)
	Log("Client Flush Data");
	self.tbPlayerData = tbData or self.tbPlayerData;
end

function tbAct:TryGetGiftMsg()
	local tbGiftMsg = {};
	local tbSendData = self.tbReadySendData or {};
	if not tbSendData.nSendPlayerID then return false, "请选择玩家" end;
	tbGiftMsg.nSendPlayerID = me.dwID;
	tbGiftMsg.nRecePlayerID = tbSendData.nSendPlayerID;

	if not tbSendData.nFDID then return false, "请选择礼物" end;
	tbGiftMsg.nFDID = tbSendData.nFDID;
	tbGiftMsg.nTag = tbSendData.nTag;
	tbGiftMsg.nJiYuType = self.tbKeyJiYu[tbSendData.szJiYu or ""] or 0;
	if tbGiftMsg.nJiYuType ~= 0 then
		tbGiftMsg.szJiYu = tbSendData.szJiYu;
	else
		tbGiftMsg.szJiYu = tbSendData.szJiYu;
	end
	if not tbGiftMsg.szJiYu and tbGiftMsg.nJiYuType ~= 0 then
	 	return false, "请填写寄语";
	 end;
	return true,tbGiftMsg;
end

----------------Ui获取数据的接口---------------

function tbAct:FlushMainPanel()
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_DRJ_FUDAI_ACT);
end

function tbAct:GetFriendWishMsg()
	return self.tbFriendsMsg or {};
end

function tbAct:GetFriendTag()
	if not self.tbReadySendData then return 1 end;
	local bRet = self.tbReadySendData.nTag or 1;
	return bRet;
end

function tbAct:GetFillBarMsg()
	if not self.tbPlayerData then return {0 , 0} end;
	local tbRet = {nSendValue = self.tbPlayerData.nSendValue, nHasAward = self.tbPlayerData.nHasAward}
	return tbRet or {0 , 0};
end

function tbAct:GetSendRecordMsg()
	local tbShowMsg = {};
	local bSure = true;
	for nIdx,tbGift in ipairs(self.tbSendGiftData or {}) do
		local bRet, tbResGift = self:UnZip(tbGift); --解压服务器的数据(好友信息仅存ID);
		if bRet then
			table.insert(tbShowMsg , tbResGift);
			self.tbSendGiftData[nIdx] = tbResGift;
		else 
			bSure = false 
		end
	end
	--数据不可靠，存在与好友解除关系。无法获得数据的情况。
	if not bSure then
		self.tbSendGiftData = nil;
		self:GetMySendMsg();
	end;
	return tbShowMsg;
end

function tbAct:GetRedaySendFriend()
	tbAct.tbReadySendData = tbAct.tbReadySendData or {};
	local szName = tbAct.tbReadySendData.szSendPlayerName;
	return szName;
end

function tbAct:GetReceRecordMsg()
	local tbShowMsg = {};
	local bSure = true;
	for nIdx,tbGift in ipairs(self.tbReceGiftData or {}) do
		local bRet, tbResGift = self:UnZip(tbGift, true); --解压服务器的数据(好友信息仅存ID);
		if bRet then
			if self.tbPlayerData and self.tbPlayerData.tbIsForUse then
				tbResGift.bHasUse = self.tbPlayerData.tbIsForUse[tbResGift.nGiftID or 1] or false;
			end

			table.insert(tbShowMsg , tbResGift);
			self.tbReceGiftData[nIdx] = tbResGift;
		else 
			bSure = false 
		end
	end
	--数据不可靠，存在与好友解除关系。无法获得数据的情况。
	if not bSure then
		self.tbSendGiftData = nil;
		self:GetMySendMsg();
	end;
	return tbShowMsg;
end

function tbAct:GetReadySendFDID()
	if not tbAct.tbReadySendData then return nil end;
	return tbAct.tbReadySendData.nFDID;
end

function tbAct:GetWishID(szMsg)
	if not self:CheckPlayerData() then return end;
	if szMsg == nil then
		return self.tbPlayerData.nWishID;
	else
		return self.tbKeyWishType[szMsg];
	end
end

function tbAct:SelectGift(nFDID)
	self.tbReadySendData = self.tbReadySendData or {};
	self.tbReadySendData.nFDID = nFDID;
	self:FlushMainPanel();
end

----------------调用服务器的接口---------------

--[赠送礼物] --已测试
function tbAct:SendGift(szJiYu)
	if not self:CheckCD(me,"SendGift" , 2) then
		me.CenterMsg("您操作太快了");
		return;
	end
	self.tbReadySendData = self.tbReadySendData or {};
	self.tbReadySendData.szJiYu = szJiYu;
	local bFlag, tbGiftMsg = self:TryGetGiftMsg();
	if not bFlag then
		me.CenterMsg(tbGiftMsg);
		return ;
	end
	local tbRet, szMsg = self:CheckGift(tbGiftMsg);
	if not tbRet then
		me.CenterMsg(szMsg);
		return ;
	end
	local fnSure = function()
		RemoteServer.DongRiJiClientCall("TrySendGift", tbGiftMsg);
		self.tbReadySendData = nil ;
		self:FlushMainPanel();
	end
	local tbRoleInfo = FriendShip:GetFriendDataInfo(tbGiftMsg.nRecePlayerID);
	local szName = tbRoleInfo.szName;
	local szGiftName = Item:GetItemTemplateShowInfo(tbGiftMsg.nFDID, me.nFaction, me.nSex);
	local szTag = self.tbTags[tbGiftMsg.nTag];
	local Msg = string.format("大侠，确定要将[FFFE0D]【%s】[-]赠予 您的[FFFE0D]【%s·%s】[-] 吗?",szGiftName,szTag ,szName);
	self.szTmpMsg = string.format("大侠，您成功的将[FFFE0D]【%s】[-]赠予 您的[FFFE0D]【%s·%s】[-]",szGiftName,szTag ,szName);
	Ui:OpenWindow("MessageBox",Msg,{{fnSure},{}},{"确定","取消"});
end
--[获取自身数据] --已测试
function tbAct:GetMyMsg()
	if self.tbPlayerData then
	 	return 
	end
	RemoteServer.DongRiJiClientCall("TryGetMyMsg");
end
--[获取自身送礼数据] --已测试
function tbAct:GetMySendMsg()
	if self.tbSendGiftData then return end;
	RemoteServer.DongRiJiClientCall("TryGetPlayerSendMsg");
end
--[获取自身收礼数据] --已测试
function tbAct:GetMyReceMsg()
	if self.tbReceGiftData then return end;
	RemoteServer.DongRiJiClientCall("TryGetPlayerReceMsg");
end
--[修改自身愿望] --已测试
function tbAct:ModifyWishes(nWishID)
	RemoteServer.DongRiJiClientCall("TryModifyWishes" , nWishID);
end

--[领取礼物] --已测试
function tbAct:ReceiveGift(nGiftID)
	if not self.tbPlayerData then
		self.GetMyMsg();
		return;
	end
	local tbTmp = self.tbPlayerData.tbIsForUse or {};
	if tbTmp[nGiftID] == true then
		RemoteServer.DongRiJiClientCall("TryTouchGift" , nGiftID);
	else
		me.CenterMsg("您已经领取过该礼物");
	end
end
--[获取好友愿望清单] --已测试
function tbAct:GetFriendsMsg()
	local bRet , szMsg = self:CheckCD(pPlayer, "GetFriendsMsg" , 3);
	if not bRet then
		return ;
	end
	RemoteServer.DongRiJiClientCall("TryGetFriendsMsg");
end
--[领取随机赠礼] --已测试
function tbAct:GetRandomGift()

	if not self.tbPlayerData then return end;
	local bCanGet = self:CanGetAward(self.tbPlayerData.nSendValue or 0, self.tbPlayerData.nHasAward or 0);
	if not bCanGet then
		me.CenterMsg("您还无法领取礼物");
		return ;
	end
	RemoteServer.DongRiJiClientCall("TryWishComeTrue");
end

function tbAct:CheckPlayerData()
	if not self.tbPlayerData then
		self.GetMyMsg();
		return false;
	end
	return true;
end

function tbAct:UnZip(tbGift , bIsNeedJiYu)
	if not tbGift then return false end;
	if bIsNeedJiYu then
		if tbGift.nJiYuType ~= 0 then
			tbGift.szJiYu = self.tbJiYuModel[tbGift.nJiYuType or 1];
		end
	end
	if type(tbGift.playerMsg) == "table" then
		return true , tbGift;
	elseif type(tbGift.playerMsg) == "number" then
		local tbPlayerMsg = {};
		local tbRoleStayInfo = FriendShip:GetFriendDataInfo(tbGift.playerMsg);
		if not tbRoleStayInfo then return false end;
		tbPlayerMsg.nSendPlayerID = tbRoleStayInfo.dwID;
		tbPlayerMsg.nHonorLevel = tbRoleStayInfo.nHonorLevel;
		tbPlayerMsg.szName = tbRoleStayInfo.szName;
		tbPlayerMsg.nFaction = tbRoleStayInfo.nFaction;
		tbPlayerMsg.nLevel = tbRoleStayInfo.nLevel;
		tbPlayerMsg.nPortrait = tbRoleStayInfo.nPortrait;
		tbGift.playerMsg = tbPlayerMsg;
		return true , tbGift;
	end
	return false
end
