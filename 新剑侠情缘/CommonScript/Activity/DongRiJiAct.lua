 if not MODULE_GAMESERVER then
    Activity.DongRiJiAct = Activity.DongRiJiAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("DongRiJiAct") or Activity.DongRiJiAct
--DRJ:冬日祭
--FD:福袋
--------------------------策划填写--------------------------------
tbAct.FD_JIYU_MAX_LEN = 15 		--福袋寄语的上限字数。
tbAct.MODIFY_COST = 200			--每次修改愿望花费的钱数。
tbAct.ASK_FRIEND_CD = 15;		--玩家请求好友列表愿望数据的CD时间。（秒）
tbAct.DEFAULT_CD = 1;			--默认CD时间。(秒)
tbAct.tbWishType = {"点击选择","贡献","元气","真气","和氏璧","门客","水晶矿石","魂石","黄金图谱","本命武器"};
tbAct.NONE_WISH = 1;			--无，玩家初始愿望，在TYPE中的ID;
tbAct.BTNSHARE_OPEN = false		--分享按钮是否开启。
tbAct.TIMES_AWARD = 5			--满足5次心愿之后发奖励。
tbAct.LOSS_PLAYER_DAY = 15*24*60*60--15天。
tbAct.tbTags = {"久爱伴侣","授业之恩","手足之谊"};
tbAct.tbKeyWishType = {};
tbAct.nRequireLv = 20			--玩家参与等级
for idx, sz in ipairs(tbAct.tbWishType) do
	tbAct.tbKeyWishType[sz] = idx;
end

tbAct.tbKeyTags = {};
for idx, sz in ipairs(tbAct.tbTags) do
	tbAct.tbKeyTags[sz] = idx;
end

tbAct.tbJiYuModel = 
{
	"攀折赠君还有意，翠眉轻嫩怕春风",
	"美人赠我锦绣段，何以报之青玉案",
	"赠君珍物情几许，却怕斜阳深院里",
	"何以折相赠，白花青桂枝",
	"因君怀胆气，赠尔定交情",
	"江南无所有，聊赠一枝春",
	"持为美人赠，勖此故交心",
	"两情顾盼合，珠碧赠于斯",
	"投我以木瓜，报之以琼琚"
}
tbAct.tbKeyJiYu = {};
for idx, sz in ipairs(tbAct.tbJiYuModel) do
	tbAct.tbKeyJiYu[sz] = idx;
end

tbAct.szMailContent = "新春福袋活动开始了！大侠快收下这个福袋，跟自己的好友互赠礼物吧！"
tbAct.nActEnterItem = 10224;	--初始参加活动道具 ID;

--{赠送福袋ID, 收到福袋的ID, 赠送上限, 收到上限 ,福袋的价值量 ,达到收到上限时获得转赠道具}

tbAct.tbFuDaiSetting = 
{
	[10201] = {10210, 3, 10, 1 , 10225, 199 , "贡献"		,10225},
	[10202] = {10211, 3, 10, 1 , 10226, 199 , "元气"		,10226},
	[10203] = {10212, 3, 10, 1 , 10227, 199 , "真气"		,10227},
	[10204] = {10213, 2, 5 , 5 , 10228, 999 , "和氏璧"	,10228},
	[10205] = {10214, 2, 5 , 5 , 10229, 999 , "门客"		,10229},
	[10206] = {10215, 2, 5 , 5 , 10230, 999 , "水晶矿石"	,10230},
	[10207] = {10216, 1, 3 , 10, 10231, 2999 ,"魂石"		,10231},
	[10208] = {10217, 1, 3 , 10, 10232, 2999 ,"黄金图谱"	,10232},
	[10209] = {10218, 1, 3 , 10, 10233, 2999 ,"本命武器"	,10233},

	[10225] = {10210, 3, 10, 0 , 10225, 20 , "转赠礼物", 10201},
	[10226] = {10211, 3, 10, 0 , 10226, 20 , "转赠礼物", 10202},
	[10227] = {10212, 3, 10, 0 , 10227, 20 , "转赠礼物", 10203},
	[10228] = {10213, 2, 5 , 0 , 10228, 20 , "转赠礼物", 10204},
	[10229] = {10214, 2, 5 , 0 , 10229, 20 , "转赠礼物", 10205},
	[10230] = {10215, 2, 5 , 0 , 10230, 20 , "转赠礼物", 10206},
	[10231] = {10216, 1, 3 , 0 , 10231, 20 , "转赠礼物", 10207},
	[10232] = {10217, 1, 3 , 0 , 10232, 20 , "转赠礼物", 10208},
	[10233] = {10218, 1, 3 , 0 , 10233, 20 , "转赠礼物", 10209}
}


--回归奖励
tbAct.tbBackProfessionAward   = {{"Contrib", 5000}, {"item", 3698, 1}}
tbAct.tbBackBeProfessionAward = {{"Contrib", 5000}, {"item", 3698, 1}}
tbAct.nBackAwardLimit = 10 	--回归奖励上限。

--%s 为玩家名
tbAct.szZhaoHui_Mail_Msg = "大侠前日赠礼的好友「%s」在您的感召之下真的重出江湖了，果然是念念不忘，必有回响，为贺大侠二人重聚之喜，我谨代表武林盟略备薄礼，庆祝大侠回来与大家团聚！";
tbAct.szZhaoHuiLimit_Mail_Msg = "大侠前日赠礼的好友「%s」在您的感召之下真的重出江湖了，果然是念念不忘，必有回响，大侠二人能够重聚，真是可喜可贺！";

tbAct.szBeiZhaoHui_Mail_Msg = "恭喜大侠重回江湖！在大侠退隐江湖的这段日子里，您的好友「%s」一直对您念念不忘，时时盼望大侠能够回来一起行走江湖，大侠今日果然受到感召，重回武林，为贺大侠二人重聚之喜，我谨代表武林盟送上薄礼一份，还请大侠笑纳。";
tbAct.szBeiZhaoHuiLimit_Mail_Msg = "恭喜大侠重回江湖！在大侠退隐江湖的这段日子里，您的好友「%s」一直对您念念不忘，时时盼望大侠能够回来一起行走江湖，大侠今日果然受到感召，重回武林，真是可喜可贺！";
tbAct.szMailTitle = "新春福袋";
tbAct.szMailFrom = "独孤剑";

--满足5个愿望发放的奖励
tbAct.tbSendWishesAward = {"Contrib", 10000}

--排行榜奖励
tbAct.szRankMsg = "大侠在新春福袋活动中最终排行第%d名，这是大侠的奖励，请注意查收！";
--排行榜奖励分为3等--依次此类推;
-- tbAct.szRankAward = {{"item", 10220, 1},{"item", 10221, 1}}
-- tbAct.tbRandAwardBlock = {{1,1},{2,10}};

tbAct.tbRankAward             = {
									{1, 	{{"item", 10298, 1}}},
									{10, 	{{"item", 10299, 1}}},
								}

tbAct.szLimitWithGift = "大侠已经给该好友送过太多这个了！";
tbAct.szNotice = "「%s」通过新春福袋向「%s」送出了一份【%s】，并附寄语【%s】，两人真是亲密无间，羡煞旁人！";
tbAct.szNotice2 = "「%s」通过新春福袋向「%s」送出了一份【%s】，两人真是情深义重！";
-- 玩家收到礼物时发一份邮件
-- 邮件内容：寄语，我在福袋里送给您一份礼物，快点击<这里>去看看吧！
-- 邮件标题：新春福袋
-- 邮件来源：玩家名

--[[ 玩家身上的数据
	tbData = {nSendValue = 0 , nHasAward = 0 , nWishID = 0, tbListSendGift = {} , tbListReceGift = {}}
]]

--[[ 福袋 礼物的 数据 ，存储分表。
{
	tbGift = {nGiftID = 1, nFDID = 1, nTag = 1, nSendPlayerID = 1, nRecePlayerID = 1, nJiYuType = 0, szJiYu = "123456789012" , bIsLossPaleyer = false}
}
]]

--获取礼物的世界公告
function tbAct:GetNotice(tbGiftMsg)
	if not tbGiftMsg or not tbGiftMsg.nFDID then return nil end;
	local nFDID = tbGiftMsg.nFDID;
	if not MODULE_GAMESERVER then return nil end;
	if self.tbFuDaiSetting[nFDID][4] < 6 then return nil end;

	local tbRoleStayInfo1 = KPlayer.GetRoleStayInfo(tbGiftMsg.nSendPlayerID);
	local tbRoleStayInfo2 = KPlayer.GetRoleStayInfo(tbGiftMsg.nRecePlayerID);
	if not tbRoleStayInfo1 or not tbRoleStayInfo2 then return nil end ;
	local szSendName = tbRoleStayInfo1.szName;
	local szReceName = tbRoleStayInfo2.szName;
	local szGiftName = Item:GetItemTemplateShowInfo(tbGiftMsg.nFDID);
	if self.tbFuDaiSetting[nFDID][4] == 5 then
		return string.format(tbAct.szNotice2 , tbRoleStayInfo1.szName, tbRoleStayInfo2.szName , szGiftName );
	else
		return string.format(tbAct.szNotice, tbRoleStayInfo1.szName ,tbRoleStayInfo2.szName , szGiftName , tbGiftMsg.szJiYu);
	end
end


-- 检查是否是配置表里的福袋。
function tbAct:IsFuDai(nFDID)
	return self.tbFuDaiSetting[nFDID] ~= nil;
end

-- 检查是否能领取奖励
function tbAct:CanGetAward(nSendValue , nHasAward)
	if not MODULE_GAMESERVER and tbAct.tbPlayerData then
		nSendValue = tbAct.tbPlayerData.nSendValue or 0;
		nHasAward = tbAct.tbPlayerData.nHasAward or 0;
	end
	Log("nSendValue",nSendValue , nHasAward);
	if not nSendValue or not nHasAward then 
		return false, "数据异常，请重试" 
	end; 
	
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	local bRet = nSendValue >= (nHasAward + 1) * tbAct.TIMES_AWARD;
	if not bRet then
		return false,"您已经领取过该奖励";
	end
	return true;
end

function tbAct:GetGiftValue(nFDID)
	if self:IsFuDai(nFDID) then 
		return self.tbFuDaiSetting[nFDID][4];
	else
		return 0;
	end
end

-- 判断玩家是否为流失玩家
function tbAct:IsLossPaleyer(nPlayerID)
	if MODULE_GAMESERVER then 
		local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nPlayerID);
		local bRet = tbRoleStayInfo.nLastOnlineTime + tbAct.LOSS_PLAYER_DAY < GetTime(); 
		return bRet;
	end
end

--检查操作CD ，默认为3秒;
function tbAct:CheckCD(pPlayer, szKey, nTimes)
	local tbData = {};
	nTimes = nTimes or self.DEFAULT_CD;
	if MODULE_GAMESERVER then
		Log(self.nOperationEndTime);
		Log(GetTime());
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
		tbData = self:GetPlayerData(pPlayer.dwID);
	else
		tbData = self.tbClientData or {};
	end
	tbData.tbAskCD = tbData.tbAskCD or {}; 
	local nLastTime = tbData.tbAskCD[szKey];
	local nLocalTime = GetTime();
	if nLastTime ~= nil then
		local nPassTime = nLocalTime - nLastTime;
		if nPassTime < nTimes then 
			return false , "您的操作太快了" 
		end;
	end
	tbData.tbAskCD[szKey] = nLocalTime;
	if MODULE_GAMESERVER then
		self:SaveDataToPlayer(pPlayer, tbData);
	else
		self.tbClientData = tbData;
	end
	return true;
end


function tbAct:CheckGift(tbGiftMsg)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	if type(tbGiftMsg) ~= "table" then
		return false, "数据异常，请重试"
	end
	if tbGiftMsg.nSendPlayerID == tbGiftMsg.nRecePlayerID then 
		return false, "赠送玩家与被赠送玩家不能为同一人";
	end

	if not self:IsFuDai(tbGiftMsg.nFDID) then
		return false , "请选择礼物";
	end

	if type(tbGiftMsg.nJiYuType) ~= "number" 
		or tbGiftMsg.nJiYuType < 0 or tbGiftMsg.nJiYuType > #(self.tbJiYuModel) then
		return false, "寄语类型错误，请重试"
	end
	Log("Check 标签",tbGiftMsg.nTag);
	if type(tbGiftMsg.nTag) ~= "number"
		or tbGiftMsg.nTag < 0 or tbGiftMsg.nTag > #(self.tbTags) then 
		return false,"标签错误，请重试"
	end

	if tbGiftMsg.nJiYuType == 0 then
		if Lib:IsEmptyStr(tbGiftMsg.szJiYu) then
			return false, "尚未编辑寄语";
		end
		if ReplaceLimitWords(tbGiftMsg.szJiYu) then
			return false, "寄语内容含有敏感字符"
		end
		local nContentLen = Lib:Utf8Len(tbGiftMsg.szJiYu);
		if nContentLen > self.FD_JIYU_MAX_LEN then
			return false, "寄语内容最多为"..tbAct.FD_JIYU_MAX_LEN.."个字";
		end
	end
	return true;
end

function tbAct:CheckWishes(nWishID)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	if type(nWishID) ~= "number" then 
		return false, "数据异常，请重试"
	end
	if nWishID <= 0 or nWishID > #(self.tbWishType) then 
		return false, "数据异常，请重试"
	end
	return true;
end



