--[[
帮派:相关工具方法
liyuan
2014年11月13日12:24:23
]]

_G.UnionUtils = {}

-- 自己是否有帮派
-- @result 有true 无false
function UnionUtils:CheckMyUnion()
	if UnionModel.MyUnionInfo and UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
		-- 有帮派
		return true
	else
		-- 无帮派
		return false
	end
end

-- 帮派列表的UIdataSource
function UnionUtils:GetUnionListDataGridData(guildList)
	local dataGridList = self:GetListCopy(guildList)
	
	if dataGridList and #dataGridList > 0 then
		table.sort(dataGridList,function(A,B)
					if A.rank < B.rank then
						return true
					else
						return false
					end
				end)
		for i,v in pairs(dataGridList) do
			v.viewOnly = 0
		end
	end
	return dataGridList
end

-- 我的成员列表更新
function UnionUtils:GetMemberListDataGridData(memberList, timeNow)
	local dataGridList = self:GetListCopy(memberList)
	UnionModel.subLeaderNum = 0
	UnionModel.elderNum = 0
	for i,v in pairs(dataGridList) do
		if v.pos == UnionConsts.DutySubLeader then
			UnionModel.subLeaderNum = UnionModel.subLeaderNum + 1
		end
		if v.pos == UnionConsts.DutyElder then
			UnionModel.elderNum = UnionModel.elderNum + 1
		end
		if v.online == 1 then
			v.timeShow = string.format(StrConfig['union72'])--显示在线
		else
			v.timeShow = UnionUtils:GetLoginTime(timeNow - v.time)--最后登录显示
		end
	end
	
	return dataGridList
end

function UnionUtils:GetLoginTime(loginTime)
	local day,hour,min1,sec = CTimeFormat:sec2formatEx(toint(loginTime))-- 剩余时间
	-- FPrint(loginTime..':'..day..':'..hour..':'..min1..':'..sec )
	local resStr = ''
	if day >= 1 then
		resStr = string.format(StrConfig['union32'], day)
	elseif hour >= 1 then
		resStr = string.format(StrConfig['union33'], hour)
	elseif min1 >= 1 then
		resStr = string.format(StrConfig['union34'], min1)
	else
		resStr = string.format(StrConfig['union35'])
	end
	
	return resStr
end

-- 我的帮派事件列表更新
function UnionUtils:GetGuildEventListDataGridData(eventList)
	local dataGridList = self:GetListCopy(eventList)
	
	if dataGridList and #dataGridList > 0 then
		table.sort(dataGridList,function(A,B)
					if A.time > B.time then
						return true
					else
						return false
					end
				end)
		
		for i,v in pairs(dataGridList) do
			if v.param and v.param ~= '' then
				local list = split(v.param, ',')
				v.paramStr = UnionUtils:GetUnionEventStr(v.id, list)
			else
				v.paramStr = ''
			end
			v.timeStr = CTimeFormat:todate(toint(v.time))
		end	
	end
	
	return dataGridList
end

-- 我的帮派申请列表更新
function UnionUtils:GetGuildApplyListDataGridData(applyList)
	local dataGridList = self:GetListCopy(applyList)
	
	if dataGridList and #dataGridList > 0 then
		table.sort(dataGridList,function(A,B)
					if A.time < B.time then
						return true
					else
						return false
					end
				end)
				
		for i,v in pairs(dataGridList) do
			v.applyFlag = 0 --0未处理1已同意2已拒绝
			v.timeStr = CTimeFormat:todate(toint(v.time),'%04d-%02d-%02d')
		end	
	end
	
	return dataGridList
end

function UnionUtils:GetFormatDate(dataNum)
	if dataNum < 10 and dataNum > 0 then
		return '0'..dataNum
	end
	
	return dataNum
end

-- 复制一个列表
function UnionUtils:GetListCopy(list)
	local copyList = {}
	for index, itemVO in pairs(list) do
		local obj = {}
		for i,v in pairs(itemVO) do
			if type(v) ~= "table" then
				obj[i] = v
			end
		end
		table.push(copyList, obj)
	end
	
	return copyList
end

---------------------------------------------
--			菜单操作
---------------------------------------------
--根据职位获得操作菜单
function UnionUtils:GetOperList(targetRoleId, targetDuty)
	if targetRoleId == MainPlayerController:GetRoleID() then
		FPrint('不能操作自己')
		return nil
	end
	local constList = UnionUtils:GetDutyOperList(UnionModel.MyUnionInfo.pos)
	if not constList then return nil end
	local operList = {}
	for i=0,#constList do
		table.push(operList, constList[i])
	end
	
	-- FPrint(targetDuty)
	local cfg = t_guildtitle
	if UnionModel.MyUnionInfo.pos > targetDuty then
		-- 任命权限
		if UnionModel.subLeaderNum < t_guildtitle[UnionConsts.DutySubLeader].posnum then
			if targetDuty ~= UnionConsts.DutySubLeader then
				table.push(operList, UnionConsts.Oper_AppointSubLeader)
			end
		end
		
		if UnionModel.elderNum < t_guildtitle[UnionConsts.DutyElder].posnum then
			if targetDuty ~= UnionConsts.DutyElder then
				table.push(operList, UnionConsts.Oper_AppointElder)
			end
		end
		if targetDuty ~= UnionConsts.DutyElite then
			table.push(operList, UnionConsts.Oper_AppointElite)
		end
		if targetDuty ~= UnionConsts.DutyCommon then
			table.push(operList, UnionConsts.Oper_AppointCommon)
		end
		-- 踢出的操作
		table.push(operList, UnionConsts.Oper_KickOut)
	end
	
	local list = {}
	for i,k in pairs(operList) do
		local data = {}
		data.name = UnionUtils:GetOperName(k)
		data.oper = k
		table.push(list,data)
	end
	
	return list
end

--获取操作的名字
function UnionUtils:GetOperName(oper)
	return StrConfig['union'..oper]
end

--根据职位获取职位名字
function UnionUtils:GetOperDutyName(duty)
	if duty == UnionConsts.DutyLeader then
		return StrConfig['union19']
	elseif duty == UnionConsts.DutySubLeader then
		return StrConfig['union20']
	elseif duty == UnionConsts.DutyElder then
		return StrConfig['union21']
	elseif duty == UnionConsts.DutyElite then
		return StrConfig['union22']
	elseif duty == UnionConsts.DutyCommon then
		return StrConfig['union23']
	end
	
	return nil
end

--根据职位获取职位的可操作列表
function UnionUtils:GetDutyOperList(duty)
	if duty == UnionConsts.DutyLeader then
		return UnionConsts.LeaderOperList
	elseif duty == UnionConsts.DutySubLeader then
		return UnionConsts.SubLeaderOperList
	elseif duty == UnionConsts.DutyElder then
		return UnionConsts.ElderOperList
	elseif duty == UnionConsts.DutyElite then
		return UnionConsts.EliteOperList
	elseif duty == UnionConsts.DutyCommon then
		return UnionConsts.CommonOperList
	end
	
	return nil
end

--根据操作id获取操作的command
function UnionUtils:GetOperCommand(operId)
	if operId == UnionConsts.Oper_View then
		return 'UnionCommandView'								--查看资料
	elseif operId == UnionConsts.Oper_Talk then
		return 'UnionCommandTalk'								--私聊窗口
	elseif operId == UnionConsts.Oper_AddFriend then
		return 'UnionCommandAddFriend'							--添加好友
	elseif operId == UnionConsts.Oper_ChangeLeader then
		return 'UnionCommandChangeLeader'							--转让帮主
	elseif operId == UnionConsts.Oper_AppointSubLeader then
		return 'UnionCommandChangeDuty'							--任副帮主
	elseif operId == UnionConsts.Oper_AppointElder then
		return 'UnionCommandChangeDuty'							--任命长老
	elseif operId == UnionConsts.Oper_AppointElite then
		return 'UnionCommandChangeDuty'							--任命精英
	elseif operId == UnionConsts.Oper_AppointCommon then
		return 'UnionCommandChangeDuty'							--任命帮众
	elseif operId == UnionConsts.Oper_KickOut then
		return 'UnionCommandKickOut'							--踢出帮派
	end
	
	return nil
end

--转让职位操作的对应的职位
function UnionUtils:GetChangeOperDuty(operId)
	-- if operId == UnionConsts.Oper_ChangeLeader then
		-- return UnionConsts.DutyLeader						--转让帮主
	if operId == UnionConsts.Oper_AppointSubLeader then
		return UnionConsts.DutySubLeader					--任副帮主
	elseif operId == UnionConsts.Oper_AppointElder then
		return UnionConsts.DutyElder						--任命长老
	elseif operId == UnionConsts.Oper_AppointElite then
		return UnionConsts.DutyElite						--任命精英
	elseif operId == UnionConsts.Oper_AppointCommon then
		return UnionConsts.DutyCommon						--任命帮众
	end
	
	return nil
end

-- 取得帮派职位的权限(策划配表)
-- @duty  职位
-- @permissionStr  权限名字符表示(配表中的字段)
-- @result  1有权限0无
function UnionUtils:GetUnionPermissionByDuty(duty, permissionStr)
	if t_guildtitle[duty] and t_guildtitle[duty][permissionStr] then
		return t_guildtitle[duty][permissionStr]
	end
	
	return 0
end

---------------------------------------------
--			升级操作
---------------------------------------------
-- 由帮派等级获得帮派人数上限
function UnionUtils:GetUnionMemMaxNum(unionLevel)
	if t_guild[unionLevel] then
		return t_guild[unionLevel].memnum
	end
	
	return 0
end

-- 帮派升级活跃度条件是否达到
function UnionUtils:IsLevelUpLivenessReached()
	local needLiveness = UnionUtils:GetUnionLevelUpNeedLiveness(UnionModel.MyUnionInfo.level)
	if UnionModel.MyUnionInfo.liveness < needLiveness then
		return false
	end
	
	return true
end

-- 帮派升级条件是否达到
function UnionUtils:IsLevelUpReached()
	local needMoney = UnionUtils:GetUnionLevelUpNeedMoney(UnionModel.MyUnionInfo.level)
	if UnionModel.MyUnionInfo.captial < needMoney then
		return false
	end
	
	for i, guildRes in pairs(UnionModel.MyUnionInfo.GuildResList) do
		local needNum = UnionUtils:GetResLevelUpNeedNum(UnionModel.MyUnionInfo.level, guildRes.itemId)
		if guildRes.count < needNum then
			return false
		end
	end
	
	return true
end

-- 取得升级所需的道具数量
function UnionUtils:GetResLevelUpNeedNum(unionLevel, itemId)
	if not t_guild[unionLevel] then return -1 end

	local needRes = UnionUtils:Parse(t_guild[unionLevel].condition)
	-- FPrint(unionLevel..itemId)
	-- FTrace(needRes)
	for i,v in pairs(needRes) do
		if itemId == v.type then
			return toint(v.val)
		end
	end
	
	return -1
end

-- 由帮派等级获得帮派升级所需资金
function UnionUtils:GetUnionLevelUpNeedMoney(unionLevel)
	if t_guild[unionLevel] then
		return t_guild[unionLevel].capital
	end
	
	return 0
end

-- 由帮派等级获得帮派升级所需活跃度
function UnionUtils:GetUnionLevelUpNeedLiveness(unionLevel)
	if t_guild[unionLevel] then
		return t_guild[unionLevel].liveness
	end
	
	return 0
end

---------------------------------------------
--			技能操作
---------------------------------------------
-- 取得开启技能所需的道具数量
function UnionUtils:GetSkillOpenItemNum(skillGroupId, itemId)
	if not t_guildskillgroud[skillGroupId] then FPrint('没有找到技能组的配置文件'..skillGroupId) return -1 end

	local needRes = UnionUtils:Parse(t_guildskillgroud[skillGroupId].need_res)
	
	if not needRes then FPrint('没有找到技能组的道具条件'..skillGroupId) return -1 end
	
	for i,v in pairs(needRes) do
		if itemId == v.type then
			return toint(v.val)
		end
	end
	
	return -1
end

--取得开启技能所需的金币数量
function UnionUtils:GetSkillOpenMoneyNum(skillGroupId)
	if not t_guildskillgroud[skillGroupId] then FPrint('没有找到技能组的配置文件'..skillGroupId) return -1 end

	return t_guildskillgroud[skillGroupId].need_money
end

--取得开启技能所需的帮派等级
function UnionUtils:GetSkillOpenLevel(skillGroupId)
	if not t_guildskillgroud[skillGroupId] then FPrint('没有找到技能组的配置文件'..skillGroupId) return -1 end
	
	return t_guildskillgroud[skillGroupId].need_guildlv
end

-- 是否显示学习按钮
function UnionUtils:IsSkillNeedStudy(skillGroupId)
	local skillList = UnionModel.MyUnionInfo.GuildSkillList
	for i, unionSkill in pairs(skillList) do
		if i == skillGroupId then
			if unionSkill.openFlag == 1 then
				return false
			end 
		end
	end
	
	return true
end

-- 技能组的开启条件是否达成
function UnionUtils:IsSkillOpenReached(skillGroupId)
	return UnionUtils:IsSkillOpenItemGroupReached(skillGroupId) and UnionUtils:isSkillOpenMoneyReached(skillGroupId) and UnionUtils:isSkillOpenLevelReached(skillGroupId)
end

-- 技能组的全部道具开启条件是否达成
function UnionUtils:IsSkillOpenItemGroupReached(skillGroupId)
	local resList = UnionModel.MyUnionInfo.GuildResList
	for j, unionRes in pairs(resList) do
		if not UnionUtils:IsSkillOpenItemReached(skillGroupId, unionRes.itemId) then
			return false
		end
	end
	
	return true
end

-- 技能组的某个道具开启条件是否达成
function UnionUtils:IsSkillOpenItemReached(skillGroupId, itemId)
	local needNum = UnionUtils:GetSkillOpenItemNum(skillGroupId, itemId)
	local hasNum = BagModel:GetItemNumInBag(itemId)
	if hasNum < needNum then
		return false
	end
	
	return true
end

-- 技能组的金币条件是否达成
function UnionUtils:isSkillOpenMoneyReached(skillGroupId)
	local needMoney = UnionUtils:GetSkillOpenMoneyNum(skillGroupId)
	
	if not needMoney then FPrint('没有找到技能组的金币条件'..skillGroupId) return false end
	
	if UnionModel.MyUnionInfo.captial < needMoney then
		return false
	end
	
	return true
end

-- 技能组的等级开启条件是否达成
function UnionUtils:isSkillOpenLevelReached(skillGroupId)
	local needLevel = UnionUtils:GetSkillOpenLevel(skillGroupId)
	
	if not needLevel then FPrint('没有找到技能组的等级条件'..skillGroupId) return false end
	
	if UnionModel.MyUnionInfo.level < needLevel then
		return false
	end
	
	return true
end

-- 获取当前的技能是否开启
function UnionUtils:GetSkillIsOpenByGroup(skillGroupId)
	local skillList = UnionModel.MyUnionInfo.GuildSkillList
	for i, unionSkill in pairs(skillList) do
		if i == skillGroupId then
			if unionSkill.openFlag == 1 then
				return true
			end
		end
	end
	
	return false
end

-- 获取当前的技能
function UnionUtils:GetSkillIdByGroup(skillGroupId)
	local skillList = UnionModel.MyUnionInfo.GuildSkillList
	for i, unionSkill in pairs(skillList) do
		local skillVO = t_guildskillgroud[i]
		if i == skillGroupId then
			if UnionModel.MyUnionInfo.level >= skillVO.need_guildlv then
				unionSkill.openFlag = 1
			else
				unionSkill.openFlag = 0
			end
			return unionSkill.skillId
		end
	end
	
	return -1
end

function UnionUtils:GetAttrStr(attr)
	local list = AttrParseUtil:Parse(attr)
	local str = ''
	for i,vo in pairs(list) do
		str = str .. enAttrTypeName[vo.type]
		str = str .. '  +'
		str = str .. vo.val
		str = str .. '<br/>'
	end
	
	return str
end

--属性类型,属性值#属性类型,属性值
function UnionUtils:Parse(str)
	local list = {}
	local t = split(str,'#')
	for i=1,#t do
		local t1 = split(t[i],',')
		local vo = {}
		vo.type = toint(t1[1])
		vo.val = toint(t1[2])
		table.push(list,vo)
	end
	return list
end

function UnionUtils:GetUnionEventStr(eventId, paramList)
	local desc = ''
	if eventId == 1 then
		desc = string.format(StrConfig['union37'], paramList[1])
	elseif eventId == 2 then
		desc = string.format(StrConfig['union38'], paramList[1])
	elseif eventId == 3 then
		desc = string.format(StrConfig['union39'], paramList[1], UnionUtils:GetOperDutyName(toint(paramList[2])))
	elseif eventId == 4 then
		desc = string.format(StrConfig['union40'], paramList[1])
	elseif eventId == 5 then
		desc = string.format(StrConfig['union41'], paramList[1], paramList[2])
	elseif eventId == 6 then
		local itemname = ''
		local equipConfig = t_equip[toint(paramList[2])];
		if equipConfig then 
			itemname = equipConfig.name
		else
			local itemConfig = t_item[toint(paramList[2])];
			if itemname then itemname = itemConfig.name end
		end
		desc = string.format(StrConfig['union42'], paramList[1], paramList[3], itemname, paramList[4])
	end
	
	return desc
end

-- 帮派仓库 计算装备评分
function UnionUtils:GetCurEquipScore(info,bo) -- 是否取unionmodule数据  返回數值
	if not info then return end;
	if t_item[info.tid] then 
		if bo then 
			return t_item[info.tid].isEnterUnion
		end;
		return true,t_item[info.tid].isEnterUnion
	end;
	local equipcfg = t_equip[info.tid]
	local cfg = t_consts[53];
	-- local zhuijia = cfg.val1;
	-- local zhuoyue = cfg.val2;
	-- local stren = cfg.val3;
	local centerScore = cfg.fval;  -- 加入帮派仓库条件

	if bo then 
		local superNum = UnionModel:GetEquipSuperNum(info.uid)
		-- local cfgid = 200000 + (equipcfg.level * 10000) + (equipcfg.quality*1000) + (equipcfg.pos * 10) + superNum;
		local cfgid = info.tid;
		local cfgscore = t_guildblank[cfgid];
		if not cfgscore then 
			return 0
		end;
		return cfgscore.point;
	else
		local id = info:GetId();
		local superNum = 0;
		local superVO = EquipModel:GetSuperVO(id);
		if superVO then
			for i,vo in ipairs(superVO.superList) do
				if vo.id > 0 then
					superNum = superNum + 1;
				end
			end
		end
		-- local cfgid = 200000 + equipcfg.level * 10000 + equipcfg.quality*1000 + equipcfg.pos * 10 + superNum;
		local cfgid = info.tid
		local cfgscore = t_guildblank[cfgid];
		if not cfgscore then 
			return false,0;
		end;
		if cfgscore.point > centerScore then
			return true,cfgscore.point
		else
			return false,cfgscore.point;
		end;
	end;
end;

--根据祈福id得到帮派增加信息
function UnionUtils:GetAddPrayLiveness(id)
	local cfg = t_guildpray[id];
	if cfg then
		return cfg.huoyuedu;
	end
	
	return 0;
end

--------------------------------------------------------
--成员列表排列
--------------------------------------------------------
--成员列表排列规则：
--首先按职位顺序由帮主、副帮主、长老、精英、帮众自上而下排列
--在按在线或离线排列
--其次职位相同的按VIP等级高低自上而下排列
--VIP等级相同的按加入帮派时间的先后顺序自下而上排列
--加入帮派时间相同的按玩家姓名以a~z的顺序自上而下排列（特殊符号排在a前）

--名字
function UnionUtils.listMemSortFunc1(memA, memB)
	--名字
	return memA.name > memB.name
end

function UnionUtils.listMemSortFunc11(memA, memB)
	--名字
	return memA.name < memB.name
end

--等级
function UnionUtils.listMemSortFunc2(memA, memB)
	--等级
	return memA.level > memB.level
	
end

function UnionUtils.listMemSortFunc21(memA, memB)
	--等级
	return memA.level < memB.level
	
end

-- 职位 默认的
function UnionUtils.listMemSortFunc3(memA, memB)
	--职位	
	return memA.pos > memB.pos
	
end

-- 职位 默认的
function UnionUtils.listMemSortFunc31(memA, memB)
	--职位
	return memA.pos < memB.pos
end

-- 战斗力
function UnionUtils.listMemSortFunc4(memA, memB)
	return memA.lineid > memB.lineid
	
end

-- 战斗力
function UnionUtils.listMemSortFunc41(memA, memB)
	return memA.lineid < memB.lineid
	
end

--当前贡献
function UnionUtils.listMemSortFunc5(memA, memB)
	return memA.power > memB.power
	
end

function UnionUtils.listMemSortFunc51(memA, memB)
	return memA.power < memB.power
	
end

-- 累计贡献
function UnionUtils.listMemSortFunc6(memA, memB)
	return memA.allcontribute > memB.allcontribute
	
end

-- 累计贡献
function UnionUtils.listMemSortFunc61(memA, memB)
	return memA.allcontribute < memB.allcontribute
	
end

-- 最后登录
function UnionUtils.listMemSortFunc7(memA, memB)

	return memA.time > memB.time
	
end

-- 最后登录
function UnionUtils.listMemSortFunc71(memA, memB)

	return memA.time < memB.time
	
end

--adder:houxudong
--date:2016/7/31 20:28:00
--检测帮派是否可以升级,<通知帮主>
function UnionUtils:CheckCanUnionLvUp( )
	if not UnionUtils:CheckMyUnion() then
		return false
	end
	local canLvUp = false;
	if self:IsLevelUpReached() and self:IsLevelUpLivenessReached() and UnionModel:IsLeader() then
		canLvUp = true
	end
	return canLvUp
end

--检测是否有新的队员进入,<通知帮主和副帮主>
function UnionUtils:CheckJoinNewpattern( )
	local canShow = false;
	local applyNums = 0;
	local cfg = t_funcOpen[6]
	if not cfg then return false, 0 end
	local openLv = cfg.open_level
	if not openLv then return false, 0 end
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	if curRoleLvl >= openLv then
		if UnionModel.applyNum ~= 0 and UnionModel:IsLeader() or UnionModel.applyNum ~= 0 and UnionModel:IsDutySubLeader() then
			applyNums = UnionModel.applyNum
			canShow = true
		end
	end
	return canShow,applyNums
end
----------------------------检测帮派捐献----------------------
function UnionUtils:CheckContribution()
	if not UnionUtils:CheckMyUnion() then
		return 0,0,0
	end
	local qingtongNum = BagModel:GetItemNumInBag(UnionConsts.QingtongTokenId)
	local baiyinNum = BagModel:GetItemNumInBag(UnionConsts.BaiyingTokenId)
	local huangjinNum = BagModel:GetItemNumInBag(UnionConsts.HuangjinTokenId)
	return qingtongNum,baiyinNum,huangjinNum;
end
-----------------------------检测帮派加特（升级）-------------
function UnionUtils:CheckAidLevelUp()
	if not UnionUtils:CheckMyUnion() then
		return false
	end
	local aidLevel = UnionModel:GetAdditionLv();
	local cfg = {};
	local nextCfg = {};
	
	if aidLevel >0 and aidLevel <15  then
		cfg = t_guildwash[aidLevel];          --所处于第几阶段的表
		nextCfg = t_guildwash[aidLevel + 1];
	else
		return false;
	end
	local contribution = UnionModel.MyUnionInfo.contribution; --自己在帮派的贡献
	if UnionModel.MyUnionInfo.level >= nextCfg.guildlv and contribution >= cfg.lvconst then
		return true;
	else
		return false;
	end
end
-----------------------------检测帮派祈福-------------
function UnionUtils:CheckPray()
	if not UnionUtils:CheckMyUnion() then
		return false
	end
	local praycfg1 = t_guildpray[1];
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	if UnionModel:GetIsPray1() == 0 and playerinfo.eaBindGold + playerinfo.eaUnBindGold >= praycfg1.cost_count then
		return true;
	else
		return false;
	end
end
















