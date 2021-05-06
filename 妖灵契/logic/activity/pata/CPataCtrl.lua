local CPataCtrl = class("CPataCtrl", CCtrlBase)

CPataCtrl.InviteMaxCount = 3
CPataCtrl.MaxLevel = 100

define.PaTa = {
	Option = 
	{
		EnterView = 1,
		Reset = 2,
		WipeOut = 3,
		GetWipeOutReward = 6,		
	},
	Event = 
	{
		WipeOutBegin = 1,
		WipeOutEnd = 2,		
		Reset = 3,
		WarResult = 4,
		FirstReWard = 5,
		UpdataWarFloor = 6,
	},
}

function CPataCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_CurLevel = 1						--当前层数
	self.m_MaxLevel = 1						--历史最高层
	self.m_InviteCount = 0					--邀请次数
	self.m_WipeOutBeginTime = nil			--开始扫荡时间戳
	self.m_WipeOutEndTime = nil				--结束扫荡时间戳
	self.m_WipeOutInfo = nil				--扫荡信息
	self.m_WipeOutRewardList = nil			--扫荡奖励			
	self.m_CanWipeOutEndLevel = nil			--可扫荡到的层数
	self.m_ResetCount = 0					--重置次数	
	self.m_WarResult = nil
	self.m_WarFloor = 1						--战斗的层数
	self.m_IsClickOpen = false
	self.m_FirstRewardList = {}
end

--打开爬塔主画面
function CPataCtrl.PaTaEnterView(self)
	local b = false
	if data.globalcontroldata.GLOBAL_CONTROL.pata.is_open == "n" then
		g_NotifyCtrl:FloatMsg("该功能正在维护，已临时关闭，请您留意官网相关信息。")

	elseif g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.pata.open_grade then
		g_NotifyCtrl:FloatMsg("未达到开放等级。")		

	-- elseif g_TeamCtrl:IsJoinTeam() then
	-- 	g_NotifyCtrl:FloatMsg("组队中无法挑战地牢。")

	elseif g_ActivityCtrl:IsDailyCultivating() then
		g_NotifyCtrl:FloatMsg("每日修行中无法挑战地牢。")

	else
		b = true
		nethuodong.C2GSPataOption(define.PaTa.Option.EnterView)
	end
	return b
end

--重置爬塔进度
function CPataCtrl.PaTaReset(self)
	nethuodong.C2GSPataOption(define.PaTa.Option.Reset)
end

--打开扫荡界面
function CPataCtrl.PaTaEnterWipeOutView(self)
	nethuodong.C2GSPataOption(define.PaTa.Option.WipeOut)
end

--领取首通奖励
function CPataCtrl.PaTaGetFristReward(self, level)
	nethuodong.C2GSPataTgReward(level)
end

--领取扫荡奖励
function CPataCtrl.PaTaGetWipeOutReward(self)
	nethuodong.C2GSPataOption(define.PaTa.Option.GetWipeOutReward)
end

--请求爬塔邀请助战
function CPataCtrl.PaTaReadyFight(self)
	nethuodong.C2GSPataEnterWar(self.m_CurLevel, 0)
end

--爬塔普通扫荡
function CPataCtrl.PaTaWipeOut(self)
	nethuodong.C2GSPataEnterWar(self.m_CurLevel, 1)
end

--爬塔立即扫荡
function CPataCtrl.PaTaFastWipeOut(self)
	nethuodong.C2GSPataEnterWar(self.m_CurLevel, 2)
end

--进入战斗
function CPataCtrl.CtrlC2GSPataInvite(self, friendId, partId)
	friendId = friendId or 0
	partId = partId or 0
	nethuodong.C2GSPataInvite(friendId, partId)
end

--请求玩家的伙伴信息
function CPataCtrl.CtrlC2GSPataFrdInfo(self, target)
	target = target or 0
	nethuodong.C2GSPataFrdInfo(target)
end

--伙伴信息返回
function CPataCtrl.CtrlGS2CPataFrdPtnInfo(self, target, partList)
	target = target or 0
	partList = partList or {}
	if partList and next(partList) then
		partList = self:PataPartnerSort(partList)
		local oView = CPaTaInviteView:GetView()
		if oView then
			oView:RefreshPartnerList(target, partList)
		end
	end
end

function CPataCtrl.PataPartnerSort(self, partList)
	if not partList and next(partList) == nil then
		return partList
	end

	--比较函数
	local function sortByType(arg)
		local func = nil 
		func = function( a, b) 
			local len = #arg
			local t = {}
			for i = 1, len do
				local  condition = {}
				condition.a = a[arg[i].sortType]		

				condition.b = b[arg[i].sortType]
				table.insert(t, condition)
			end

			if t[1].a == t[1].b and len > 1 then
				if t[2].a == t[2].b and len > 2 then
					if t[3].a == t[3].b and len > 3 then
						if t[4].a == t[4].b and len > 4 then
							if t[5].a == t[5].b and len > 5 then
								if arg[6].isGreate	== false then
									return t[6].a < t[6].b
								else
									return t[6].a > t[6].b
								end
							else
								if arg[5].isGreate == false then
									return t[5].a < t[5].b
								else
									return t[5].a > t[5].b
								end
							end					
						else
							if arg[4].isGreate == false then						
								return t[4].a < t[4].b
							else
								return t[4].a > t[4].b
							end	
						end			
					else
						if arg[3].isGreate == false then
							return t[3].a < t[3].b
						else
							return t[3].a > t[3].b	
						end						
					end
				else
					if arg[2].isGreate == false then
						return t[2].a < t[2].b
					else
						return t[2].a > t[2].b 
					end					
				end
			else
				if arg[1].isGreate == false then
					return t[1].a < t[1].b
				else
					return t[1].a > t[1].b
				end				
			end
		end
		return func
	end

	--排序池，每种排序基本规则 isGreate = false 升序   isGreate == true 表示降序
	local tSortPool = 
		{
			power = {sortType = "power", isGreate = true},
			rare = {sortType = "rare", isGreate = true},
			grade = {sortType = "grade", isGreate = true},
			star = {sortType = "star", isGreate = true},
			parid = {sortType = "parid", isGreate = false},
		}

	table.sort(partList, sortByType({
	[1] = tSortPool.power,
	[2] = tSortPool.rare,
	[3] = tSortPool.grade,
	[4] = tSortPool.star,
	[5] = tSortPool.parid,
	}))

	return partList
end

--打开爬塔主界面返回
function CPataCtrl.CtrlGS2CPataUIInfo(self, curlv, maxLv, info, restCnt, tglist)
	self.m_CurLevel = curlv
	self.m_MaxLevel = maxLv
	self.m_ResetCount = restCnt
	self.m_FirstRewardList = tglist or {}

	local oView = CPaTaView:GetView()
	g_ViewCtrl:DontDestroyOnCloseAll("CPaTaView", true)
	if oView then
		oView:SetLevel(curlv, maxLv, info)	
	else
		CPaTaView:ShowView( function (oView)
			oView:SetLevel(curlv, maxLv, info)			
		end)
	end
end

--打开邀请助战返回
function CPataCtrl.CtrlGS2CPataInviteInfo(self, cnt, list)
	self.m_InviteCount = cnt or 0
	local frdList = table.copy(list)
	if self.m_InviteCount > 0 and next(frdList) ~= nil then
		local partnerCount = 0
		for i = 1, #frdList do
			local cnt = frdList[i].ptncnt or 0
			partnerCount = partnerCount + cnt
			frdList[i].upvote = frdList[i].upvote or false
		end
		if partnerCount > 0 then
			if #frdList > 1 then
				table.sort(frdList, function (a, b)
					return a.power > b.power
				end)
			end
			CPaTaInviteView:ShowView(function (oView)
				oView:SetContent(self.m_InviteCount, frdList)
			end)
		else
			g_NotifyCtrl:FloatMsg("你的好友还没有伙伴！")
		end
	elseif next(frdList) == nil then
		g_NotifyCtrl:FloatMsg("你尚未添加好友,无法邀请！")
	elseif self.m_InviteCount == 0 then
		g_NotifyCtrl:FloatMsg("今日好友邀请次数已用完！")
	else

	end
end

--爬塔战斗返回
function CPataCtrl.CtrlGS2CPataWarUI(self, iWin, itemList, curLv, inviteCnt) 
	self.m_CurLevel = curLv
	if curLv > self.m_MaxLevel then
		self.m_MaxLevel = curLv
	end
	self.m_InviteCount = inviteCnt or 0

	self.m_WarResult = { win = iWin, itemList = itemList, curLv = curLv, inviteCnt = inviteCnt }
	self:OnEvent(define.PaTa.Event.WarResult, self.m_WarResult)
end

--扫荡信息返回
function CPataCtrl.CtrlGS2CSweepInfo(self, begintime, info)
	self.m_WipeOutBeginTime = begintime
	self.m_WipeOutInfo = info
	local data = {begintime = self.m_WipeOutBeginTime, info = self.m_WipeOutInfo}
	self:OnEvent(define.PaTa.Event.WipeOutBegin, data)
end

--是否在扫荡中
function CPataCtrl.IsWipeOuting(self )
	return self.m_WipeOutBeginTime ~= nil
end

--获取扫荡预览时间
function CPataCtrl.GetPreviewWipeOutEndTimeString(self )
	local str = ""
	local targetLevel = self:GetWipdOutEndlevel()
	if targetLevel > self.m_CurLevel then
		local time = (targetLevel - self.m_CurLevel) * 15
		local h = math.floor(time / 3600)
		local min = math.floor(time % 3600 / 60)
		local sec = time % 60
		str = (h ~= 0 ) and str..tostring(h).."时" or str
		str = (min ~= 0 ) and str..tostring(min).."分" or str
		str = str..tostring(sec).."秒"		
	end
	return str
end

--获取结束扫荡时间
function CPataCtrl.GetWipeOutEndTime(self )
	local time = 0
	if self.m_WipeOutEndTime ~= nil then
		time = self.m_WipeOutEndTime
	elseif self:IsWipeOuting() then

		local totalTime = 0
		for i = 1, #self.m_WipeOutInfo do		
			totalTime = totalTime + self.m_WipeOutInfo[i].costtime			
		end
		time = self.m_WipeOutBeginTime + totalTime
		
		--时间矫正
		local timeNow = g_TimeCtrl:GetTimeS()
		if time > timeNow + totalTime then
			self.m_WipeOutEndTime = timeNow + totalTime
		else
			self.m_WipeOutEndTime = time	
		end		
	end
	return time
end

--获取扫荡剩余时间
function CPataCtrl.GetWipeOutRemainTime(self)
	local time = 0
	if self:IsWipeOuting() then
		local now = g_TimeCtrl:GetTimeS()
		local tTime = self:GetWipeOutEndTime()
		if now < tTime then
			time = tTime - now
		end
		local totalTime = 0
		for i = 1, #self.m_WipeOutInfo do		
			totalTime = totalTime + self.m_WipeOutInfo[i].costtime			
		end
		if time > totalTime then
			time = totalTime
		end 		
	end
	return time
end

--获取扫荡剩余时间字符串
function CPataCtrl.GetWipeOutRemainTimeString(self)
	local str = ""
	local time = self:GetWipeOutRemainTime()
	if time >= 0 then
		local h = math.floor(time / 3600)
		local min = math.floor(time % 3600 / 60)
		local sec = time % 60
		str = (h ~= 0 ) and str..tostring(h).."时" or str
		str = (min ~= 0 ) and str..tostring(min).."分" or str
		str = str..tostring(sec).."秒"
	end
	return str
end

--扫荡的到的层数
function CPataCtrl.GetWipdOutEndlevel(self )
	local lv = 1
	if not self.m_CanWipeOutEndLevel and self.m_WipeOutInfo then
		lv = self.m_WipeOutInfo[#self.m_WipeOutInfo].lv
	else
		lv = self.m_CanWipeOutEndLevel
	end
	return lv
end

--获取当前扫荡的层数和此层已经扫荡的时间
function CPataCtrl.GetCurWipeOutLevelAndTime(self)
	local level = self.m_CurLevel
	local doingTime = 0
	if self:IsWipeOuting() then
		local time = g_TimeCtrl:GetTimeS() - self.m_WipeOutBeginTime
		if time < 0 then
			time = 0
		end
		for i = 1, #self.m_WipeOutInfo do
			local d = self.m_WipeOutInfo[i]
			if d then
				if time - d.costtime > 0 then
					level = d.lv
					time = time - d.costtime 
				else
					doingTime = time
					level = d.lv - 1
					break
				end
			end			
		end
	end
	return level, doingTime
end

--获取预览的奖励列表(扫荡前预览)
function CPataCtrl.GetProviewRewardList(self)	
	local curLevel = self.m_CurLevel
	if self:IsWipeOuting() then
		if self.m_WipeOutInfo and next(self.m_WipeOutInfo) then
			curLevel = self.m_WipeOutInfo[1].lv - 1
		end
	end
	local targetlevel = self:GetWipdOutEndlevel()
	local reward = {}
	local d = data.tollgatedata.PATA

	local function checkExit(tb, sid)
		local vTable = nil
		if tb and next(tb) then
			for i = 1, #tb do
				if tb[i].sid == sid then
					vTable = tb[i]
					break
				end
			end
		end
		return vTable
	end	

	for i = curLevel, (targetlevel - 1) do
		local tRward = d[i].ui_rewardtbl
		if tRward and next(tRward) then
			for i = 1, #tRward do	
				local sid = tRward[i].rewardid				
				if sid and string.find(sid, "value") then
					local k, v = g_ItemCtrl:SplitSidAndValue(sid)
					--相同奖励叠加
					local t = checkExit(reward, k)
					if t then
						t.count = t.count + v
					else
						t = {sid = k, count = v}
						table.insert(reward, t)	
					end		

				else			
					--相同奖励叠加		
					local t = checkExit(reward, tonumber(sid))
					if t then
						t.count = t.count + 1
					else
						t = {sid = sid, count = 1}
						table.insert(reward, t)	
					end	
				end				
			end
		end
	end

	return reward
end

--获取指定层的通关奖励
function CPataCtrl.GetPassRewardListByLevel(self, level)	
	local reward = {}	
	if level >= 1 and level <= CPataCtrl.MaxLevel then
		local function checkExit(tb, sid)
			local vTable = nil
			if tb and next(tb) then
				for i = 1, #tb do
					if tb[i].sid == sid then
						vTable = tb[i]
						break
					end
				end
			end
			return vTable
		end	
		local d = data.tollgatedata.PATA
		if d then
			local tRward = d[level].ui_rewardtbl
			if tRward and next(tRward) then 
				for i = 1, #tRward do	
					local sid = tRward[i].rewardid				
					if sid and string.find(sid, "value") then
						local k, v = g_ItemCtrl:SplitSidAndValue(sid)
						--相同奖励叠加
						local t = checkExit(reward, k)
						if t then
							t.count = t.count + v
						else
							t = {sid = k, count = v}
							table.insert(reward, t)	
						end		

					else			
						--相同奖励叠加		
						local t = checkExit(reward, tonumber(sid))
						if t then
							t.count = t.count + 1
						else
							t = {sid = sid, count = 1}
							table.insert(reward, t)	
						end	
					end				
				end
			end
		end
	end
	return reward
end

--获取指定层的首通奖励
function CPataCtrl.GetFirstRewardListByLevel(self, level)
	local reward = {}	
	if level >= 1 and level <= CPataCtrl.MaxLevel then
		local id = level + 2000
		local d = data.rewarddata.PATA[id]
		if d then
			local tRward = d.first_reward -- 首通奖励
			local function checkExit(tb, sid)
				local vTable = nil
				if tb and next(tb) then
					for i = 1, #tb do
						if tb[i].sid == sid then
							vTable = tb[i]
							break
						end
					end
				end
				return vTable
			end

			if tRward and next(tRward) then --大奖励池
				for i = 1, #tRward do								
					local sid = tRward[i].sid
					if string.find(sid, "value") then
						local k, v = g_ItemCtrl:SplitSidAndValue(sid)
						--相同奖励叠加
						local t = checkExit(reward, k)
						if t then
							t.count = t.count + v
						else
							t = {sid = k, count = v}
							table.insert(reward, t)	
						end		
					else			
						--相同奖励叠加		
						local t = checkExit(reward, sid)
						if t then
							t.count = t.count + tRward[i].amount
						else
							t = {sid = sid, count = tRward[i].amount}
							table.insert(reward, t)	
						end	

					end				
				end
			end
		
		end
	end
	return reward
end

--扫荡奖励返回
function CPataCtrl.CtrlGS2CPataRwItemUI(self, curLv, itemList)
	self.m_WipeOutBeginTime = nil
	self.m_WipeOutEndTime = nil
	self.m_WipeOutInfo = nil
	self.m_CurLevel = curLv
	self.m_WipeOutRewardList = itemList
	self:OnEvent(define.PaTa.Event.WipeOutEnd)
end

--首通奖励预览返回
function CPataCtrl.CtrlGS2CPataFirstRwLv(self, level)
	CPaTaWipeView:ShowView(function(oView)
		oView:ShowFirstReward(level)
	end)
end

--打开扫界面返回
function CPataCtrl.CtrlGS2CSweepLevel(self, endLevel)
	self.m_CanWipeOutEndLevel = endLevel
	CPaTaWipeView:ShowView(function(oView)
		oView:ShowWipeOut()
	end)
end

--扫荡奖励界面确认领取
function CPataCtrl.CtrlWipeOutRewardConfirm(self)
	self.m_WipeOutRewardList = nil 
end

function CPataCtrl.GetFloorMonsterId(self, floor)
	local id = nil
	local pataData = data.tollgatedata.PATA[floor]
	if pataData then
		local monsterId = pataData.monster[1].monsterid
		if monsterId then
			local monster = data.monsterdata.PATA[monsterId]
			if monster then
				id = monster.model_id	
			end
		end
	end
	return id
end

function CPataCtrl.SetPataWarFloor(self, floor)
	self.m_WarFloor = floor
	self:OnEvent(define.PaTa.Event.UpdataWarFloor)
end

function CPataCtrl.GetWarFloor(self)
	return self.m_WarFloor
end

function CPataCtrl.SwitchEnv(self, bWar)
	if bWar then
		if g_WarCtrl:GetWarType() == define.War.Type.Pata then
			local oView = CPataWarView:GetView()
			if oView then
				oView:SetFloor(self.m_WarFloor)
			else
				CPataWarView:ShowView(function(oView)
					oView:SetFloor(self.m_WarFloor)
				end)
			end
		end
	end
end

function CPataCtrl.ShowWarResult(self, oCmd)
	if oCmd.win then
		if CPaTaWinView:GetView() == nil then
			CPaTaWinView:ShowView(function (oView)
				oView:SetDefaultShow()
			end)
		end
	else
		if CPaTaFailView:GetView() == nil then
			CPaTaFailView:ShowView(function (oView)
				oView:SetDefaultShow()
			end)
		end
	end
end


-- 返回1 是可领取， 返回2 是已领取 返回3 是没有
function CPataCtrl.IsHaveFirstReward(self, level)
	self.m_FirstRewardList = self.m_FirstRewardList or {}
	local status = 3
	if self.m_MaxLevel > level and not table.index(self.m_FirstRewardList, level) then
		status = 1
	elseif table.index(self.m_FirstRewardList, level) then
		status = 2 
	end
	return status
end

function CPataCtrl.CtrlGS2CTgRewardResult(self, level)
	self.m_FirstRewardList = self.m_FirstRewardList or {}
	table.insert(self.m_FirstRewardList, level)
	self:OnEvent(define.PaTa.Event.FirstReWard)
end


function CPataCtrl.IsPataRedDot(self)
	return false	
end

return CPataCtrl
