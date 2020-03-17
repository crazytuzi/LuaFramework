--[[
帮派:数据模型
liyuan
2014年11月13日12:24:23
]]

_G.UnionModel = Module:new();

------------------------------------------------------------------------------
--									我的帮派信息 
------------------------------------------------------------------------------
UnionModel.subLeaderNum = 0
UnionModel.elderNum = 0
UnionModel.MyUnionInfo = {}

--帮派祈福
UnionModel.ispray1 = 0;
UnionModel.ispray2 = 0;
UnionModel.ispray3 = 0;
UnionModel.praylist = {};
UnionModel.applyNum = 0
UnionModel.memberSortFunc = nil
-- 我的帮派信息
function UnionModel:SetMyUnionInfo(msg)
	if msg.guildId then
		-- 已有帮派
		self.MyUnionInfo = UnionInfoVO:New(msg)
		Notifier:sendNotification(NotifyConsts.MyUnionInfoUpdate, {guildId=msg.guildId})
		self.applyNum = msg.applynum
		Notifier:sendNotification(NotifyConsts.ReplyGuildNumChanged)
	else
		-- 没有帮派
		Notifier:sendNotification(NotifyConsts.MyUnionInfoUpdate, {guildId=nil})
		self.applyNum = 0
		Notifier:sendNotification(NotifyConsts.ReplyGuildNumChanged)
	end
	self:UpdateToQuest();
end

-- 自己的忠诚度
function UnionModel:GetMyloyalty()
	if self.MyUnionInfo and self.MyUnionInfo.loyalty then 
		return self.MyUnionInfo.loyalty
	end
	
	return nil
end

function UnionModel:IsLeader()
	if self.MyUnionInfo and self.MyUnionInfo.pos == UnionConsts.DutyLeader then 
		return true
	end
	
	return false
end

--是否副帮主
function UnionModel:IsDutySubLeader()
	if self.MyUnionInfo and self.MyUnionInfo.pos == UnionConsts.DutySubLeader then 
		return true;
	end;
	return false;
end;

--更新自己的帮派信息
function UnionModel:UpdateMyGuildMemInfo(msg)
	self.MyUnionInfo.contribution = msg.contribution
	self.MyUnionInfo.totalContribution = msg.totalContribution
	self.MyUnionInfo.pos = msg.pos
	self.MyUnionInfo.loyalty = msg.loyalty
	
	Notifier:sendNotification(NotifyConsts.UpdateMyUnionMemInfo)
	Notifier:sendNotification(NotifyConsts.UpdateContribute)
end

-- 返回帮派等级
function UnionModel:GetMyUnionLevel()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		-- 有帮派
		return UnionModel.MyUnionInfo.level
	else
		-- 无帮派
		return 0
	end
end

-- 返回帮派资金
function UnionModel:GetMyUnionMoney()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		-- 有帮派
		return UnionModel.MyUnionInfo.captial
	else
		-- 无帮派
		return 0
	end
end;

-- 返回帮派id
function UnionModel:GetMyUnionId()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		-- 有帮派
		return UnionModel.MyUnionInfo.guildId
	else
		-- 无帮派
		return nil
	end
end

--返回帮派 name
function UnionModel:GetMyUnionName()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		-- 有帮派
		return UnionModel.MyUnionInfo.guildName
	else
		-- 无帮派
		return nil
	end
end;

function UnionModel:UpdateUnionNotice(guildNote)
	if not self.MyUnionInfo then return end
	
	UnionModel.MyUnionInfo.guildNotice = guildNote
	Notifier:sendNotification(NotifyConsts.EditNoticeUpdate, {guildNotice=guildNote})
end

-- 更新帮派信息
function UnionModel:UpdateGuildInfo(msg)
	if not self.MyUnionInfo or self.MyUnionInfo.guildId ~= msg.guildId then return end
	self.MyUnionInfo:UpdateUnionInfo(msg)
	-- FTrace(self.MyUnionInfo)
	Notifier:sendNotification(NotifyConsts.UpdateGuildInfo)
	if self.MyUnionInfo.alianceGuildId ~= "0_0" then
		Notifier:sendNotification(NotifyConsts.UpdateDiplomacyPlayer);
		---------------------------------------------------------在发请求同盟信息表
	end
end

-- 返回升级自身帮派技能
function UnionModel:SetLevelUpMyGuildSkill(msg)
	if self.MyUnionInfo.GuildSkillList then
		for i,guildSkill in pairs(self.MyUnionInfo.GuildSkillList) do
			if i == msg.groupId then
				local curSkillId = UnionUtils:GetSkillIdByGroup(msg.groupId)
				local skillCfg = t_guildskill[curSkillId]
				if skillCfg.nextlv then 
					guildSkill.skillId = skillCfg.nextlv
					break
				end
			end
		end
	end
	
	Notifier:sendNotification(NotifyConsts.UpdateLevelUpMyGuildSkill)
end

-- 返回开启某组帮派技能
function UnionModel:SetLvUpGuildSkill(msg) 
	if self.MyUnionInfo.GuildSkillList then
		for i,guildSkill in pairs(self.MyUnionInfo.GuildSkillList) do
			if i == msg.groupId then
				if guildSkill.skillId == 0 then
					guildSkill.skillId = msg.groupId*1000 + 1
				    guildSkill.openFlag = 1
				    break
                end
			end
		end
	end
	
	Notifier:sendNotification(NotifyConsts.OpenGuildSkill)
end

-- 捐献返回
function UnionModel:SetGuildContribute(msg)
	if self.MyUnionInfo.totalContribution then
		 local contributeAdd = msg.contribute - self.MyUnionInfo.contribution
		 if contributeAdd > 0 then self.MyUnionInfo.totalContribution = self.MyUnionInfo.totalContribution + contributeAdd end
	else
		self.MyUnionInfo.totalContribution = msg.contribute
	end
	self.MyUnionInfo.captial = msg.captial
	self.MyUnionInfo.contribution = msg.contribute
	if msg.GuildResList then
		self.MyUnionInfo.GuildResList = {}
		for k,guildRes in pairs(msg.GuildResList) do
			local resVO = {}
			resVO.itemId = guildRes.itemId
			resVO.count = guildRes.count
			table.push(self.MyUnionInfo.GuildResList, resVO)
		end
	end
	
	Notifier:sendNotification(NotifyConsts.UpdateContribute)
end

-- 帮派的资源数量
function UnionModel:GetResCountById(resId)
	for i, v in pairs(self.MyUnionInfo.GuildResList) do
		if v.itemId == resId then return v.count end
	end
end

--发送结盟成功
function UnionModel:OnAddDiplomacy(msg)
	for i , v in pairs(self.DipAppList) do
		if v.id == msg.guildId then 
			v = {};
		end
	end
end

--解散结盟成功
function UnionModel:OnRemoveDiplomacy(msg)
	self.MyUnionInfo.alianceGuildId = "0_0";
	self.dipPlayerList = {};
	Notifier:sendNotification(NotifyConsts.UpdateDiplomacy);
end

--返回自己回复的结盟结果
function UnionModel:OnGetDiplomacyHandler(msg)
	if msg.verify == 0 then
		
		--同意 但对方又已经有了同盟
		local cfg = msg.GuildAlianceApplyList ;
		if cfg.result == 1 then
		end
		return 
	end
end

--返回申请结盟的列表
UnionModel.DipAppList = {};
function UnionModel:OnGetAppDipList(list)
	for i , v in pairs(list) do
		self.DipAppList[v.id] = v;
	end
	Notifier:sendNotification(NotifyConsts.UpdateDiplomacyList,list);
end

--返回同盟信息表
UnionModel.dipPlayerList = {};
function UnionModel:OnGetDipPlayerList(msg)
	self.dipPlayerList = msg;
	Notifier:sendNotification(NotifyConsts.UpdateDiplomacyPlayerList,msg);
end

--清除申请列表
function UnionModel:OnClearAppList(msg)
	local cfg = msg;
	for i , v in pairs(self.DipAppList) do
		for j , k in pairs(cfg) do
			if v.id == k.guild then 
				self.DipAppList[i] = {};
				v = {};
			end
		end
	end
	Notifier:sendNotification(NotifyConsts.UpdateDiplomacyList,self.DipAppList);
end

--==↓↓------------------------------帮派加持----------------------------↓↓==--

--返回洗炼的属性
UnionModel.adoBapInfo = {};
function UnionModel:OnUpDateAidInfo(msg)
	for i , v in pairs(msg) do
		self.adoBapInfo[i] = v;
	end
	Notifier:sendNotification(NotifyConsts.UnionAidInfo,self.adoBapInfo);
end

--返回加持属性
UnionModel.aidInfo = {};
function UnionModel:OnModelBackAidInfo(msg)
	for i , v in pairs(msg) do
		self.aidInfo[i] = v;
	end
	Notifier:sendNotification(NotifyConsts.UnionAidInfoUpDate,self.aidInfo);
end

--返回加持升级的结果
function UnionModel:onBackAidUpLevelInfo(msg)
	if not msg.result then return end
	if msg.result == 0 then
		local cfg = t_guildwash[self.aidInfo.aidLevel + 1];
		if not cfg then return end
		self.aidInfo.aidLevel = cfg.lv;
		self.aidInfo.att = self.aidInfo.att + cfg.atkadd;
		self.aidInfo.def = self.aidInfo.def + cfg.defadd;
		self.aidInfo.maxhp = self.aidInfo.maxhp + cfg.hpadd;
		self.aidInfo.cri = self.aidInfo.cri + cfg.subdefadd;
		Notifier:sendNotification(NotifyConsts.UnionAidLevelUpDate,self.aidInfo);
	else
		print("升级失败");
	end
end

function UnionModel:GetAdditionLv()
	return self.aidInfo.aidLevel or 0
end

--==↑↑------------------------------帮派加持----------------------------↑↑==--
------------------------------------------------------------------------------
--									帮派列表
------------------------------------------------------------------------------
UnionModel.UnionsList = {}

function UnionModel:SetUnionList(msg)
	self.UnionsList = UnionUtils:GetUnionListDataGridData(msg.GuildList)
	
	if not self.UnionsList then return end
	Notifier:sendNotification(NotifyConsts.UnionListUpdate, {pages=msg.pages})
end

function UnionModel:SetUnionApplyResult(msg)
	if not msg.guildId then return end

	for i,v in pairs(self.UnionsList) do
		if msg.guildId == v.guildId then
			v.applyFlag = msg.applyFlag
			break
		end
	end
	
	--给对方帮派发包 现没有
	-- if self.UnionInfoVO.guildId == msg.guildId then
		-- if UnionUtils:GetUnionPermissionByDuty(self.UnionInfoVO.pos, UnionConsts.invitation_verify) == 1 then
			-- Notifier:sendNotification(NotifyConsts.UnionListUpdate, {guildList=self.UnionsList, pages=-1, guildId=msg.guildId, applyFlag=msg.applyFlag})
		-- end
	-- end
	-- name="bApply" comment="0-取消， 1-申请" />
	if msg.bApply == 1 then
		UIUnionCreateList:AddNotice(StrConfig['union50'])--已申请，等待对面帮派管理者确认
	else
		UIUnionCreateList:AddNotice(StrConfig['union47'])--已撤销申请
	end
	Notifier:sendNotification(NotifyConsts.UnionListUpdate, {pages=-1, guildId=msg.guildId, applyFlag=msg.applyFlag})
end

------------------------------------------------------------------------------
--									申请(审核)列表
------------------------------------------------------------------------------
UnionModel.UnionMemApplyList = {}

function UnionModel:SetUnionApplyList(msg)
	self.UnionMemApplyList = UnionUtils:GetGuildApplyListDataGridData(msg.GuildApplysList)
	
	if not self.UnionMemApplyList then return end
	Notifier:sendNotification(NotifyConsts.UpdateGuildApplyList,{NewPattern = true})  --新增body-->true
	-- print("------self.UnionMemApplyList",#self.UnionMemApplyList)
	self.applyNum = #(self.UnionMemApplyList)
end

--对UpdateGuildApplyList进行监听

function UnionModel:SetUnionVerifyResult(msg)
	if not msg.GuildApplyList then return end
	-- FTrace(self.UnionMemApplyList)
	local applyNum = 0
	if self.UnionMemApplyList then
		for resultI, resultV in pairs (msg.GuildApplyList) do   -- msg.GuildApplyList 自己帮派成员
			for i,v in pairs(self.UnionMemApplyList) do
				if v.id == resultV.memGid then   --成员id
					if resultV.result == 0 then
						v.applyFlag = msg.applyFlag
						if msg.verify == 0 then				--0 - 同意，1 - 拒绝
							v.applyFlag = 1 				--0未处理1已同意2已拒绝
							FloatManager:AddSysNotice(2005039);--您已同意对方的申请
						else
							v.applyFlag = 2
							FloatManager:AddSysNotice(2005040);--您已拒绝对方的申请
						end
					else
						v.applyFlag = -1
						FloatManager:AddCenter(StrConfig['union166']);--该信息已失效
					end
				end
				
				if v.applyFlag == 0 then
					applyNum = applyNum + 1
				end
			end
		end
		-- FTrace(self.UnionMemApplyList)
		Notifier:sendNotification(NotifyConsts.UpdateGuildApplyList,{NewPattern = false})   --新加body-->false
		-- if msg.verify == 0 then
		-- elseif msg.verify == 1 then
		-- end
	end
	self.applyNum = applyNum
	-- WriteLog(LogType.Normal,true,'-------------申请数量1:',self.applyNum)
	-- WriteLog(LogType.Normal,true,'-------------申请数量2:',#(self.UnionMemApplyList))
	Notifier:sendNotification(NotifyConsts.ReplyGuildNumChanged)
end

------------------------------------------------------------------------------
--									帮派成员列表
------------------------------------------------------------------------------
UnionModel.UnionMemberList = {}

function UnionModel:SetUnionMemberList(msg)
	self.UnionMemberList = UnionUtils:GetMemberListDataGridData(msg.GuildMemList, msg.timeNow)
	
	if not self.UnionMemberList then return end
	
	self:SortUnionMemberList()
	
	Notifier:sendNotification(NotifyConsts.UpdateGuildMemberList)
end

function UnionModel:SortUnionMemberList(sortFuncId)
	if not self.memberSortFunc then 
		self.memberSortFunc = UnionUtils.listMemSortFunc3
	end
	
	if sortFuncId then
		self.memberSortFunc = UnionUtils['listMemSortFunc'..sortFuncId]
	end
	
	table.sort(self.UnionMemberList,self.memberSortFunc);
	Notifier:sendNotification(NotifyConsts.UpdateGuildMemberList)
end

-- 帮主禅让
function UnionModel:SetChangeLeader(msg)
	if not msg.newId then return end
	UnionController:ReqMyGuildApplys()  --再次申请，申请者数量
	--WriteLog(LogType.Normal,true,'-------------帮主禅让:',self.applyNum)
	if self.UnionMemberList then
		for i,v in pairs(self.UnionMemberList) do
			if msg.newId == v.id then
				v.pos = UnionConsts.DutyLeader
			elseif msg.oldId == v.id then
				v.pos = msg.pos
			end
		end
		self:SortUnionMemberList()
		-- Notifier:sendNotification(NotifyConsts.UpdateGuildMemberList)
	end

	if msg.oldId == MainPlayerController:GetRoleID() then
		self.MyUnionInfo.pos = msg.pos
		Notifier:sendNotification(NotifyConsts.ChangeLeaderUpdate, {pos=msg.pos})
		FloatManager:AddSysNotice(2005035);--帮主转让成功
	end
	
	if msg.newId == MainPlayerController:GetRoleID() then
		self.MyUnionInfo.pos = UnionConsts.DutyLeader
		Notifier:sendNotification(NotifyConsts.ChangeLeaderUpdate, {pos=UnionConsts.DutyLeader})
	end
end


-- 改变职位
function UnionModel:SetChangeGuildPos(msg)
	if not msg.memGid then return end
	UnionModel.subLeaderNum = 0
	UnionModel.elderNum = 0
	
	if self.UnionMemberList then
		for i,v in pairs(self.UnionMemberList) do
			if msg.memGid == v.id then
				v.pos = msg.pos
			end
			
			if v.pos == UnionConsts.DutySubLeader then
				UnionModel.subLeaderNum = UnionModel.subLeaderNum + 1
			end
			if v.pos == UnionConsts.DutyElder then
				UnionModel.elderNum = UnionModel.elderNum + 1
			end
		end
		self:SortUnionMemberList()
		-- Notifier:sendNotification(NotifyConsts.UpdateGuildMemberList, {memList=self.UnionMemberList})
	end
	
	if msg.memGid == MainPlayerController:GetRoleID() then
		self.MyUnionInfo.pos = msg.pos
		Notifier:sendNotification(NotifyConsts.ChangeLeaderUpdate, {pos=msg.pos})
	else
		FloatManager:AddSysNotice(2005036);--任命成功
	end
end

-- 踢出帮派成员
function UnionModel:SetKickGuildMem(msg)
	if not msg.memGid then return end
	
	if self.UnionMemberList then
		for i,v in pairs(self.UnionMemberList) do
			if msg.memGid == v.id then
				table.remove(self.UnionMemberList,i);
				break
			end
		end
		self:SortUnionMemberList()
		-- Notifier:sendNotification(NotifyConsts.UpdateGuildMemberList)
	end
	
	if msg.memGid == MainPlayerController:GetRoleID() then
		self.MyUnionInfo.pos = msg.pos
		self.MyUnionInfo.guildId = nil
		Notifier:sendNotification(NotifyConsts.MyUnionInfoUpdate, {guildId=nil})
		self:UpdateToQuest()
	end
end



-- 退出帮派
function UnionModel:SetQuitGuild()
	self.MyUnionInfo.guildId = nil
	Notifier:sendNotification(NotifyConsts.MyUnionInfoUpdate, {guildId=nil})
	self:UpdateToQuest();
end

-- 解散帮派
function UnionModel:SetDismissGuild()
	self.MyUnionInfo.guildId = nil
	--clear帮派仓库数据
	self:ClearUnionWareInof();

	Notifier:sendNotification(NotifyConsts.MyUnionInfoUpdate, {guildId=nil})
	self:UpdateToQuest();

end

------------------------------------------------------------------------------
--									事件列表
------------------------------------------------------------------------------
UnionModel.UnionMemEventList = {}

function UnionModel:SetUnionMemEventList(msg)
	self.UnionMemEventList = UnionUtils:GetGuildEventListDataGridData(msg.GuildEventList)
	
	if not self.UnionMemEventList then return end
	Notifier:sendNotification(NotifyConsts.UpdateGuildEventList)
end




----------------------------------帮派仓库------------
UnionModel.UnionWareHoseInfomationlist = {};
UnionModel.WareHouseItemList = {};
UnionModel.WareHouseInfo = {};

-- initInfo 
function UnionModel:ClearUnionWareInof()
	UnionModel.UnionWareHoseInfomationlist = {};
	UnionModel.WareHouseItemList = {};
	UnionModel.WareHouseInfo = {};
end;

-- 设置最大限制
function UnionModel:SetUnionInfoDo(maxIn)
	local cfg = t_consts[87].val2
	self.WareHouseInfo.maxIn = cfg - maxIn
	Notifier:sendNotification(NotifyConsts.UpdateContribute)
end;
function UnionModel:GetUnionInfoDo()
	return self.WareHouseInfo
end;
-- 操作信息
function UnionModel:SetUnionInfomation(list,bo)
	if not bo then  
		self.UnionWareHoseInfomationlist = {};
	end;
	for i,info in ipairs(list) do
		local num = 1;
		if t_item[info.itemid] then 
			local cfg = t_item[info.itemid]
			num = info.cont / cfg.isEnterUnion 
			if info.opertype == 2 then 
				num = (info.cont / t_consts[54].val3) / cfg.isEnterUnion
			elseif info.opertype == 1 then 
				num = info.cont / cfg.isEnterUnion
			end;
		end;
		info.num = num;
		table.push(self.UnionWareHoseInfomationlist,info)
	end;
	local vo = self.UnionWareHoseInfomationlist;
	for i=1,#vo-1 do 
		for i=1,#vo-1 do 
			if vo[i].time < vo[i+1].time then  
				vo[i] ,vo[i+1] = vo[i+1],vo[i];
			end;
		end;
	end;
	-- 仓库操作信息
	Notifier:sendNotification(NotifyConsts.UnionWareHouseOperInfo)
end;
--get 操作信息 
function UnionModel:GetWareInfomation()
	return self.UnionWareHoseInfomationlist;
end;

--get itemlist
function UnionModel:GetItemList()
	return self.WareHouseItemList;
end;
function UnionModel:OnWareHouseItemList(list)
	self.WareHouseItemList = {};
	for i,info in ipairs(list) do 
		self.WareHouseItemList[info.uid] = info
	end;
	--trace(self.WareHouseItemList)
	--print("数组",self:GetListLenght(self.WareHouseItemList))
	Notifier:sendNotification(NotifyConsts.UnionWareHouseItemUpdate)
end;

function UnionModel:OnWareHouseAddItem(list)
	for i,info in ipairs(list) do 
		self.WareHouseItemList[info.uid] = info;
	end;
	--trace(self.WareHouseItemList)
	--print("添加以后的数组",self:GetListLenght(self.WareHouseItemList))
	Notifier:sendNotification(NotifyConsts.UnionWareHouseItemUpdate)
end;

function UnionModel:OnWareHouseRemoveItem(list)
	local remaList = {}
	for i,info in ipairs(list) do
		if self.WareHouseItemList[info.uid] then 
			self.WareHouseItemList[info.uid] = nil
		end;
	end;
	--trace(self.WareHouseItemList)
	--print("删除以后的数组",self:GetListLenght(self.WareHouseItemList))
	Notifier:sendNotification(NotifyConsts.UnionWareHouseItemUpdate)
end;

function UnionModel:GetEquipSuperNum(uid)
	for i,info in pairs(self.WareHouseItemList) do
		if info.uid == uid then 
			return info.superNum
		end;
	end
	return 0;
end;
function UnionModel:GetListLenght(list)
	local num = 0;
	for i,info in pairs(list) do 	
		num = num + 1;
	end;
	return num;
end;


------------------------------------------------------------------------------
--									帮派祈福信息
------------------------------------------------------------------------------
--设置是否普通祈福
function UnionModel:SetIsPray1(ispray)
	self.ispray1 = ispray;
	
	Notifier:sendNotification(NotifyConsts.UnionPrayRefresh)
end
--得到普通祈福
function UnionModel:GetIsPray1()
	return self.ispray1;
end
--设置是否高级祈福
function UnionModel:SetIsPray2(ispray)
	self.ispray2 = ispray;
	
	Notifier:sendNotification(NotifyConsts.UnionPrayRefresh)
end
--得到高级祈福
function UnionModel:GetIsPray2()
	return self.ispray2;
end
--设置是否至尊祈福
function UnionModel:SetIsPray3(ispray)
	self.ispray3 = ispray;
	
	Notifier:sendNotification(NotifyConsts.UnionPrayRefresh)
end
--得到至尊祈福
function UnionModel:GetIsPray3()
	return self.ispray3;
end
--设置祈福信息
function UnionModel:SetPrayList(list)
	self.praylist = list;
	
	Notifier:sendNotification(NotifyConsts.UnionPrayRefresh)
end
--得到祈福信息
function UnionModel:GetPrayList()
	return self.praylist;
end

--设置祈福后的活跃度和帮贡(帮派祈福后服务器并未通知客户端活跃度变化，客户端自己处理)
function UnionModel:UpdateMyGuildPrayInfo(huoyuedu)
	Notifier:sendNotification(NotifyConsts.UpdateContribute);
end

function UnionModel:UpdateToQuest()
	if not FuncManager:GetFuncIsOpen(FuncConsts.Guild) then return; end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_UnionJoin, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	local joined = UnionUtils:CheckMyUnion()
	if QuestModel:GetQuest(questId) then
		if joined then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if joined then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end