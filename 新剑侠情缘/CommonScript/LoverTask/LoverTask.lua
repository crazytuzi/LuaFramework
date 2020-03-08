LoverTask.SAVE_GROUP = 176
LoverTask.nFinishCountIdx = 1 					-- 完成次数
LoverTask.nTaskTypeIdx = 2 						-- 任务类型
LoverTask.nTaskStateIdx = 3 					-- 任务状态
LoverTask.nTaskStepIdx = 4 						-- 任务进度
LoverTask.nTaskTeammateIdx = 5 					-- 一起进行任务的队友id
LoverTask.nUpdateTimeIdx = 6 					-- 次数更新时间

LoverTask.TASK_TYPE_IDIOMS = 1 					-- 有缘一线牵
LoverTask.TASK_TYPE_DEFEND = 2 					-- 缘定长相守
LoverTask.TASK_TYPE_DREAM = 3 					-- 梦境


LoverTask.TASK_STATE_ACCEPT = 1 				-- 任务状态-接取
LoverTask.TASK_STATE_CANCEL = 2 				-- 任务状态-取消
LoverTask.TASK_STATE_CAN_FINISH = 3 			-- 任务状态-可完成

LoverTask.MAX_FINISH_COUNT = 2 					-- 每周最多可完成次数

LoverTask.PROCESS_SHOW_TASK_PANEL = 1 			-- 展示交任务界面
LoverTask.PROCESS_FINISH_TASK = 2 				-- 接任务

LoverTask.nTaskIdiomsFubenMapTId = 8013
LoverTask.nTaskDefendFubenMapTId = 8014
LoverTask.nTaskDreamFubenMapTId = 8015

LoverTask.nLoveTaskFakeId = -1
-- 时间轴概率
LoverTask.tbTimeFrameRate = LoverTask.tbTimeFrameRate or {}

LoverTask.nMinJoinLevel = 35 				-- 参与最小等级
LoverTask.nMaxJoinLevel = 79 				-- 参与最大等级
LoverTask.nAddImitity = 200 					-- 组队完成任务增加的亲密度
LoverTask.nAddTitleId = 6808
LoverTask.nTitleTime = 7 * 24 * 60 * 60 		-- 称号有效期
LoverTask.szTitleFrame = "OpenLevel59" 			-- 该时间轴开放之后就不给称号
LoverTask.tbSetting = 
{
	[LoverTask.TASK_TYPE_IDIOMS] = 
	{
		szFubenClass = "IdiomsFubenBaseTask";
		nFubenMapTemplateId = LoverTask.nTaskIdiomsFubenMapTId;
		nDelayKickOut = 120;
		JOIN_MEMBER_COUNT = 2;
		NameCol = 10;
		NameRow = 10;
		tbNpcNameSet = {} ;						-- 决定每条龙有几个tbTaskIdiomsFuben.tbNpcPos = {};
		tbNpcPos = {};
		tbNpcIdSet = {2051} ;					-- 所有的npcid
		REVIVE_TIME = 3;
		tbReward = {}; 							-- 副本奖励，配置表（任务完成发）
		tbFinishAward = 
		{
			["OpenLevel39"] = {
				tbTaskAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}; 		-- 任务完成奖励
			};
			["OpenLevel59"] = {
				tbTaskAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}; 		-- 任务完成奖励
				tbExtAward = { {{"item", 9509, 1}}}; 				-- 从里面随机一份
			};			
		};
		nWinCount = 10; 							-- 接上几句成语任务才完成
		nPreFinishDialogId = 91002; 			-- 完成任务之前的对话
		tbStep = 
		{
			{
				szDes = "[缘]默契试炼", 
				szFinishDes = "[缘]默契试炼", 
				szType = "Dialog", 
				tbParam = {91000}, 
				tbTaskInfo = {
					-- szTitle 任务标题 szDetail 任务目标 szDesc任务描述 tbAward 任务展示奖励
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]默契试炼[-]", szDetail = "和[FFFE0D]燕若雪[-]对话", szDesc = "燕若雪想帮助你们培养一下默契度，相传有个地方为九州文脉之源，进入修炼可极大的增强彼此的默契。", tbShowAward = {}};
				};
			};
			{
				szDes = "[缘]忘雪之地", 
				szFinishDes = "[缘]忘雪之地", 
				szType = "Dialog", 
				tbParam = {91001}, 
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]忘雪之地[-]", szDetail = "向[FFFE0D]燕若雪[-]了解忘雪谷", szDesc = "原来这个文脉之源在天山腹地，名唤忘雪谷，里面灵物皆以成语命名，燕若雪要求你们按怪物的名字接龙，依次击杀，达到10积分则完成此次默契试炼", tbShowAward = {}};
				};
			};
			{
				szDes = "[缘]前往忘雪谷", 
				szFinishDes = "【已完成】[缘]忘雪试炼[-]", 
				szType = "Fuben", 
				tbParam = {LoverTask.nTaskIdiomsFubenMapTId}, 
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]忘雪试炼[-]", szDetail = "跟[FFFE0D]燕若雪[-]进入副本", szDesc = "准备好了，就找燕若雪，她会带你们前往忘雪谷", tbShowAward = {}};
					[LoverTask.TASK_STATE_CAN_FINISH] = {szTitle = "[11adf6][缘]忘雪试炼[-]", szDetail = "找[FFFE0D]燕若雪[-]领取奖励", szDesc = "两位轻松通过试炼，默契满分，若雪特赠一些好玩的物件，助天下有情人终成眷属！", tbShowAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}};
				};
			};
		};
	};
	[LoverTask.TASK_TYPE_DEFEND] = {
		szFubenClass = "DefendFubenBaseTask";
		nFubenMapTemplateId = LoverTask.nTaskDefendFubenMapTId;
		nPreFinishDialogId = 91005; 													-- 完成任务之前的对话
		KICK_TIME = 5;
		REVIVE_TIME = 5;
		nMingXiaHitMsgInteval = 10;
		tbFinishAward = 
		{
			["OpenLevel39"] = {
				tbTaskAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}; 		-- 任务完成奖励
			};
			["OpenLevel59"] = {
				tbTaskAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}; 		-- 任务完成奖励
				tbExtAward = { {{"item", 9509, 1}}}; 				-- 从里面随机一份
			};		
		};
		tbReward = { 																	-- 副本奖励（任务完成发）
			[0] = {{"Item", 4523, 1}},
			[1] = {{"Item", 4524, 1}}, 		
			[2] = {{"Item", 4525, 1}},
			[3] = {{"Item", 4526, 1}},
			[4] = {{"Item", 4527, 1}},
			[5] = {{"Item", 4528, 1}}, 		
			[6] = {{"Item", 4529, 1}, {"AddTimeTitle", 5033, 10*24*60*60}},
		};
		nWinCount = 4; 							-- 守几波任务才完成
		tbSeriesSetting = {
			["Dialog"] = {
				[1] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement1", Index = "Series_Jin1",  Text = "天王"},
				[2] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement2", Index = "Series_Mu1",   Text = "逍遥"},
				[3] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement3", Index = "Series_Shui1", Text = "峨嵋"},
				[4] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement4", Index = "Series_Huo1",  Text = "桃花"},
				[5] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement5", Index = "Series_Tu1",   Text = "武当"},
			},
			["Monster"] = {
				[1] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement1", Index = "Series_Jin2",  Text = "金"},
				[2] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement2", Index = "Series_Mu2",   Text = "木"},
				[3] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement3", Index = "Series_Shui2", Text = "水"},
				[4] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement4", Index = "Series_Huo2",  Text = "火"},
				[5] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement5", Index = "Series_Tu2",   Text = "土"},
			}, 
			
		};
		tbStep = 
		{
			{
				szDes = "[缘]生死相守", 
				szFinishDes = "[缘]生死相守", 
				szType = "Dialog", 
				tbParam = {91003}, 
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]生死相守[-]", szDetail = "和[FFFE0D]燕若雪[-]对话", szDesc = "燕若雪得知张如梦和恋人南宫彩虹有难，希望你们协助解围。", tbShowAward = {}};
				};
			};
			{
				szDes = "[缘]塞外大漠", 
				szFinishDes = "[缘]塞外大漠", 
				szType = "Dialog", 
				tbParam = {91004}, 
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]塞外大漠[-]", szDetail = "听[FFFE0D]燕若雪[-]讲解战术", szDesc = "燕若雪大致讲解了一下解围策略，你们需要成功守住4次进攻，剩下的交给燕若雪处理", tbShowAward = {}};
				};
			};
			{
				szDes = "[缘]前往塞外", 
				szFinishDes = "【已完成】[缘]塞外解围[-]", 
				szType = "Fuben", 
				tbParam = {LoverTask.nTaskDefendFubenMapTId};
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]塞外解围[-]", szDetail = "跟随[FFFE0D]燕若雪[-]前往塞外", szDesc = "准备好了，就找燕若雪，她会带你们前往忘雪谷", tbShowAward = {}};
					[LoverTask.TASK_STATE_CAN_FINISH] = {szTitle = "[11adf6][缘]塞外解围[-]",  szDetail = "找[FFFE0D]燕若雪[-]领取奖励", szDesc = "两位少侠以身犯险，燕若雪对汝2人甚是佩服，看你们郎才女貌，很是般配，特赠你们一些情缘物件。",tbShowAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}};
				};
			};
		};
	};
	[LoverTask.TASK_TYPE_DREAM] = 
	{
		szFubenClass = "DreamFubenBaseTask";
		nPreFinishDialogId = 91008; 	
		nFubenMapTemplateId = LoverTask.nTaskDreamFubenMapTId;
		KICK_TIME = 120;
		REVIVE_TIME = 5;
		tbFinishAward = 
		{
			["OpenLevel39"] = {
				tbTaskAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}; 		-- 任务完成奖励
			};
			["OpenLevel59"] = {
				tbTaskAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}; 		-- 任务完成奖励
				tbExtAward = { {{"item", 9509, 1}}}; 				-- 从里面随机一份
			};			
		};
		tbStep = 
		{
			{
				szDes = "[缘]心结成梦", 
				szFinishDes = "[缘]心结成梦", 
				szType = "Dialog", 
				tbParam = {91006}, 
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]心结成梦[-]", szDetail = "和[FFFE0D]燕若雪[-]对话", szDesc = "燕若雪精神恍惚，似有心事，去问问情况。", tbShowAward = {}};
				};
			};
			{
				szDes = "[缘]若雪梦境", 
				szFinishDes = "[缘]若雪梦境", 
				szType = "Dialog", 
				tbParam = {91007}, 
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]若雪梦境[-]", szDetail = "了解[FFFE0D]若雪[-]梦境", szDesc = "燕若雪大致说了一下梦境的注意事项，二位需要学会牵手动作，才能通过梦境", tbShowAward = {}};
				};
			};
			{
				szDes = "[缘]前往梦境", 
				szFinishDes = "【已完成】[缘]若雪梦境[-]", 
				szType = "Fuben", 
				tbParam = {LoverTask.nTaskDreamFubenMapTId};
				tbTaskInfo = {
					[LoverTask.TASK_STATE_ACCEPT] = {szTitle = "[11adf6][缘]前往梦境[-]", szDetail = "进入[FFFE0D]燕若雪[-]梦境", szDesc = "准备好了，就找燕若雪，她会带你们进入梦境", tbShowAward = {}};
					[LoverTask.TASK_STATE_CAN_FINISH] = {szTitle = "[11adf6][缘]梦境归来[-]",  szDetail = "找[FFFE0D]燕若雪[-]领取奖励", szDesc = "两位少侠帮助燕若雪解开心结，燕若雪决定说明真相，直面命运，为了感谢二位，特赠情缘物件。",tbShowAward = {{"item", 1234, 20},{"item", 1235, 20},{"item", 1969, 5,0,true},{"BasicExp", 90}}};
				};
			};
		};
    };
}
LoverTask.nRecommondLoverCount = 3 						-- 推荐人数
local tbTaskIdiomsFuben = LoverTask.tbSetting[LoverTask.TASK_TYPE_IDIOMS]
local tbTaskDefendFuben = LoverTask.tbSetting[LoverTask.TASK_TYPE_DEFEND]

function LoverTask:LoadSetting()
	if MODULE_GAMESERVER then
		local szTabPath,szParamType,tbParams
		if not next(tbTaskIdiomsFuben.tbNpcNameSet) then
			szTabPath = "Setting/LoverTask/IdiomsTask/npc_name.tab";
			szParamType = "";
			tbParams = {};
			for i = 1, tbTaskIdiomsFuben.NameCol do
				szParamType = szParamType .. "s";
				table.insert(tbParams, "name" .. i);
			end
			tbTaskIdiomsFuben.tbNpcNameSet = LoadTabFile(szTabPath, szParamType, nil, tbParams);
			assert(#tbTaskIdiomsFuben.tbNpcNameSet == tbTaskIdiomsFuben.NameCol,string.format("[tbTaskIdiomsFuben] LoadSetting no match NameCol %d/%d",#tbTaskIdiomsFuben.tbNpcNameSet,tbTaskIdiomsFuben.NameCol))
			local nRow = 0
			for _,v in ipairs(tbTaskIdiomsFuben.tbNpcNameSet) do
				assert(Lib:CountTB(v) == tbTaskIdiomsFuben.NameCol,"[tbTaskIdiomsFuben] LoadSetting valid NameCol")
				nRow = nRow + 1
			end
			assert(nRow == tbTaskIdiomsFuben.NameRow,"[tbTaskIdiomsFuben] LoadSetting valid NameRow")
		end
		if not next(tbTaskIdiomsFuben.tbNpcPos) then
			szTabPath = "Setting/LoverTask/IdiomsTask/npc_pos.tab";
			szParamType = "dd";
			tbParams = {"PosX", "PosY"};
			local tbFile = LoadTabFile(szTabPath, szParamType, nil, tbParams);
			for _, tbInfo in ipairs(tbFile) do
				table.insert(tbTaskIdiomsFuben.tbNpcPos, {nPosX = tbInfo.PosX, nPosY = tbInfo.PosY});
			end
		end
		if not next(tbTaskIdiomsFuben.tbReward) then
			szTabPath = "Setting/LoverTask/IdiomsTask/Award.tab";
			szParamType = "ds"
			tbParams = {"nRank","szAward"}
			local tbFile = LoadTabFile(szTabPath, szParamType, nil, tbParams);
			for _, tbInfo in ipairs(tbFile) do
				local tbRow = {}
				tbRow[1] = tbInfo.nRank
				tbRow[2] = Lib:GetAwardFromString(tbInfo.szAward)
				table.insert(tbTaskIdiomsFuben.tbReward,tbRow)
			end
		end
	end

end
LoverTask:LoadSetting()

function LoverTask:OnServerStart()
	if version_tx or version_hk or version_xm then
		self.tbTimeFrameRate =  					-- 时间轴概率
			{
				["OpenLevel39"] = {
					tbRate = {
						[LoverTask.TASK_TYPE_IDIOMS] = 1000;
						[LoverTask.TASK_TYPE_DEFEND] = 1000;
						[LoverTask.TASK_TYPE_DREAM] = 1000;
					};
				};
			}
	else
		self.tbTimeFrameRate =  					-- 时间轴概率
			{
				["OpenLevel39"] = {
					tbRate = {
						[LoverTask.TASK_TYPE_IDIOMS] = 0;
						[LoverTask.TASK_TYPE_DEFEND] = 1000;
						[LoverTask.TASK_TYPE_DREAM] = 1000;
					};
				};
			}
	end
	assert(next(self.tbTimeFrameRate), "[Error] LoverTask Wrong Rate...")
	for _, v in pairs(self.tbTimeFrameRate) do
		local nTotalRate = 0
		for _, nRate in pairs(v.tbRate) do
			nTotalRate = nTotalRate + nRate
		end
		v.nTotalRate = nTotalRate
	end
end

function LoverTask:GetTaskIdiomsFubenReward(nRank)
	local tbAllReward = {}

	for _,tbInfo in ipairs(tbTaskIdiomsFuben.tbReward) do
		tbAllReward = Lib:CopyTB(tbInfo[2])
		if nRank <= tbInfo[1] then
			break
		end
	end

	return self:FormaReward(tbAllReward)
end

function LoverTask:FormaReward(tbAllReward)
	tbAllReward = Lib:CopyTB(tbAllReward) or {}

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end

function LoverTask:GetTaskDefendFubenReward(nRound)
	return tbTaskDefendFuben.tbReward[nRound] and  self:FormaReward(tbTaskDefendFuben.tbReward[nRound]) 
end

function LoverTask:GetSeriesSetting(szKey, nSeries)
	local tbSetting = tbTaskDefendFuben.tbSeriesSetting[szKey] and tbTaskDefendFuben.tbSeriesSetting[szKey][nSeries]
	return tbSetting and Lib:CopyTB(tbSetting)
end

function LoverTask:GetActiveTaskType(pPlayer)
	local nTaskType = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskTypeIdx);
	local nTaskState = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
	if nTaskType > 0 and (nTaskState == LoverTask.TASK_STATE_ACCEPT or nTaskState == LoverTask.TASK_STATE_CAN_FINISH) then
		return nTaskType
	end
end

function LoverTask:GetCancelTaskType(pPlayer)
	local nTaskType = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskTypeIdx);
	local nTaskState = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
	if nTaskType > 0 and nTaskState == LoverTask.TASK_STATE_CANCEL then
		return nTaskType
	end 
end

function LoverTask:CheckTeammate(pPlayer, szTipTitle)
	local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID)
	if not tbTeam then
		return false, string.format("需要男女2人组队，才可%s！", szTipTitle or "领取任务")
	end
	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember ~= 2 then
        return false, string.format("需要男女2人组队，才可%s！", szTipTitle or "领取任务")
    end
    local nMemberId = tbMember[1] == pPlayer.dwID and tbMember[2] or tbMember[1]
    local pMember = KPlayer.GetPlayerObjById(nMemberId)
    if not pMember then
        return false, "没找到队友"
    end
     local nMapId1 = pPlayer.GetWorldPos()
    local nMapId2 = pMember.GetWorldPos()
    if nMapId1 ~= nMapId2 or pPlayer.GetNpc().GetDistance(pMember.GetNpc().nId) > Npc.DIALOG_DISTANCE * 3 then
        return false, "队友不在附近！"
    end
    return true, "", pMember, tbTeam
end

function LoverTask:CheckLevel(pPlayer)
	if pPlayer.nLevel < LoverTask.nMinJoinLevel or pPlayer.nLevel > LoverTask.nMaxJoinLevel then
		return false
	end
	return true
end

function LoverTask:CheckAcceptTask(pPlayer)
	local bRet, szMsg, pMember, tbTeam = self:CheckTeammate(pPlayer)
	if not bRet then
		return false, szMsg
	end
    if tbTeam:GetCaptainId() ~= pPlayer.dwID then
        return false, "你不是队长无权操作！"
    end
    if pPlayer.nSex == pMember.nSex then
        return false, "需要男女2人组队，才可领取任务！"
    end
    local nLoverId = Wedding:GetLover(pPlayer.dwID)
    if nLoverId and nLoverId ~= pMember.dwID then
    	return false, "只能和结婚对象一起完成任务"
    end
    local nEngaged = Wedding:GetEngaged(pPlayer.dwID)
    if nEngaged and nEngaged ~= pMember.dwID then
    	return false, "只能和订婚对象一起完成任务"
    end

    local nMemberLoverId = Wedding:GetLover(pMember.dwID)
    if nMemberLoverId and nMemberLoverId ~= pPlayer.dwID then
    	return false, string.format("%s已经结了婚，只能和结婚对象一起完成任务", pMember.szName)
    end
    local nMemberEngaged = Wedding:GetEngaged(pMember.dwID)
    if nMemberEngaged and nMemberEngaged ~= pPlayer.dwID then
    	return false, string.format("%s已经订了婚，只能和订婚对象一起完成任务", pMember.szName)
    end
    if not LoverTask:CheckLevel(pPlayer) then
    	return false, string.format("%s不在参与等级范围", pPlayer.szName)
    end
     if not LoverTask:CheckLevel(pMember) then
    	return false, string.format("%s不在参与等级范围", pMember.szName)
    end
    return true, "", pMember
end

function LoverTask:CheckDoTask(pPlayer)
	local bRet, szMsg, pMember, tbTeam = self:CheckTeammate(pPlayer, "进行任务")
	if not bRet then
		return false, szMsg
	end
	if tbTeam:GetCaptainId() ~= pPlayer.dwID then
        return false, "你不是队长无权操作！"
    end
    local nTeammateId = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskTeammateIdx)
    local nMemberTeammateId = pMember.GetUserValue(self.SAVE_GROUP, self.nTaskTeammateIdx)
    if nTeammateId ~= pMember.dwID or pPlayer.dwID ~= nMemberTeammateId then
    	return false, "需要和接任务时的队友一起进行"
    end
    local nTaskType = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskTypeIdx);
    local nMemberTaskType = pMember.GetUserValue(self.SAVE_GROUP, self.nTaskTypeIdx);
    
    if nTaskType == 0 or not nMemberTaskType == 0 then
    	return false, "当前无可进行任务"
    end
    if nTaskType ~= nMemberTaskType then
    	return false, "任务不一致"
    end
    local nTaskStep = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStepIdx);
    local nMemberTaskStep = pMember.GetUserValue(self.SAVE_GROUP, self.nTaskStepIdx);
    if nTaskStep == 0 or nTaskStep ~= nMemberTaskStep then
    	return false, "任务进度不一致"
    end
    local nTaskState = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
    local nMemberTaskState = pMember.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
    if nTaskState == 0 then 
    	return false, string.format("「%s」无任务状态", pPlayer.szName)
    end
    if nMemberTaskState == 0 then 
    	return false, string.format("「%s」无任务状态", pMember.szName)
    end
    if nTaskState == LoverTask.TASK_STATE_CANCEL then
    	return false, string.format("「%s」已经放弃了任务", pPlayer.szName)
    end
    if nMemberTaskState == LoverTask.TASK_STATE_CANCEL then
    	return false, string.format("「%s」已经放弃了任务", pMember.szName)
    end
    if nTaskState ~= nMemberTaskState then
    	return false, "任务状态不一致"
    end
    return true, "", pMember, nTaskState
end

-- 返回任务步骤描述
function LoverTask:GetTaskStepDes(pPlayer)
	local nTaskType = self:GetActiveTaskType(pPlayer)
	if not nTaskType then
		return
	end
	local nTaskState = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
	local nTaskStep = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStepIdx);
	local tbStep = LoverTask:GetTaskStep(pPlayer) or {}
	local tbStepInfo = tbStep[nTaskStep] or {}
	local szDes = tbStepInfo.szDes
	if nTaskState == self.TASK_STATE_CAN_FINISH and tbStepInfo.szFinishDes then
		szDes = tbStepInfo.szFinishDes
	end
	return szDes or ""
end

function LoverTask:GetTaskPreFinishDialog(nTaskType)
	local tbTaskSetting = self.tbSetting[nTaskType]
	return tbTaskSetting and tbTaskSetting.nPreFinishDialogId
end

function LoverTask:GetTaskStep(pPlayer)
	local nTaskType = self:GetActiveTaskType(pPlayer)
	if not nTaskType then
		return
	end
	return self.tbSetting[nTaskType] and self.tbSetting[nTaskType].tbStep
end

function LoverTask:GetTaskAward(pPlayer)
	local nTaskType = self:GetActiveTaskType(pPlayer)
	if not nTaskType then
		return
	end
	local tbInfo = self.tbSetting[nTaskType] or {}
	local szMaxTimeFrame = Lib:GetMaxTimeFrame(tbInfo.tbFinishAward)
	local tbAward = tbInfo.tbFinishAward[szMaxTimeFrame]
	return tbAward.tbTaskAward, tbAward.tbExtAward
end

function LoverTask:GetTaskInfo(pPlayer)
	local tbStep = LoverTask:GetTaskStep(pPlayer)
	if not tbStep then
		return
	end
	local nTaskStep = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStepIdx);
	local tbTaskInfo = tbStep[nTaskStep] and tbStep[nTaskStep].tbTaskInfo
	local nTaskState = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
	return tbTaskInfo and tbTaskInfo[nTaskState]
end

function LoverTask:GetLoverTask(pPlayer)
	local tbTask = LoverTask:GetTaskInfo(pPlayer)
	if not tbTask then
		return
	end
	return {LoverTask.nLoveTaskFakeId, tbTask.szTitle, tbTask.szDetail, tbTask.szDesc, tbTask.tbShowAward}
end

function LoverTask:IsLoverTask(nTaskId)
	return nTaskId == LoverTask.nLoveTaskFakeId
end

function LoverTask:CheckGiveUpTask(pPlayer)
	local nTaskType = self:GetActiveTaskType(pPlayer)
	if not nTaskType then
		return false, "没有任务可放弃"
	end
	local nTaskState = pPlayer.GetUserValue(self.SAVE_GROUP, self.nTaskStateIdx);
	if nTaskState == self.TASK_STATE_CAN_FINISH then
		return false, "不能放弃已完成的任务"
	end
	return true
end

function LoverTask:IsDreamTaskMap(pPlayer)
	if pPlayer.nMapTemplateId == self.nTaskDreamFubenMapTId then
		return true
	end
end