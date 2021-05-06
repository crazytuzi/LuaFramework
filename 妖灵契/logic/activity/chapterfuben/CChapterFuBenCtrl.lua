local CChapterFuBenCtrl = class("CChapterFuBenCtrl", CCtrlBase)

function CChapterFuBenCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CChapterFuBenCtrl.ResetCtrl(self)
	self.m_TotalStarInfos = {}  --1普通，2困难 每章节星数/奖励信息
	self.m_ExtraRewardInfos = {}
	self.m_FinalChapter = {}    --目前通关最远的关卡 1普通，2困难
	self.m_AllChapterLevelInfos = {}
	self.m_EnergyBuytime = 0
	self.m_ResultInfo = {exp_list={}, item_list={}, condition={}}
	self.m_WarAfterReshow = nil
end

--~g_ChapterFuBenCtrl:Debug()
function CChapterFuBenCtrl.Debug(self)
	table.print(g_ChapterFuBenCtrl.m_TotalStarInfos, "--m_TotalStarInfos")
	table.print(g_ChapterFuBenCtrl.m_ExtraRewardInfos, "--m_ExtraRewardInfos")
	table.print(g_ChapterFuBenCtrl.m_FinalChapter, "--m_FinalChapter")
	table.print(g_ChapterFuBenCtrl.m_AllChapterLevelInfos, "--m_AllChapterLevelInfos")
end

function CChapterFuBenCtrl.OnReceiveLoginChapterInfo(self, totalstar_info, extrareward_info, finalchapter, energy_buytime)
	--printc("---------登陆收到剧情副本信息-----------------")
	for k,v in pairs(totalstar_info) do
		local type
		if v.type and v.type > 0 then
			type = v.type
		else
			type = 1
		end
		if not self.m_TotalStarInfos[type] then
			self.m_TotalStarInfos[type] = {}
		end
		self.m_TotalStarInfos[type][v.chapter] = v
	end

	--self.m_TotalStarInfos = table.list2dict(totalstar_info, "chapter")
	
	for i,v in ipairs(extrareward_info) do
		if not self.m_ExtraRewardInfos[v.type] then
			self.m_ExtraRewardInfos[v.type] = {}
		end
		if not self.m_ExtraRewardInfos[v.type][v.chapter] then
			self.m_ExtraRewardInfos[v.type][v.chapter] = {}
		end
		self.m_ExtraRewardInfos[v.type][v.chapter][v.level] = v
	end

	for k,v in pairs(finalchapter) do
		local type
		if v.type and v.type > 0 then
			type = v.type
		else
			type = 1
		end
		self.m_FinalChapter[type] = v
	end
	
	self.m_EnergyBuytime = energy_buytime
	self:OnEvent(define.ChapterFuBen.Event.OnLogin)
	g_GuideCtrl:ReCheckChapterFubenGuide(true)
end

function CChapterFuBenCtrl.OnReceiveChapterOpen(self, type, chapter, level)
	--只是说明开启这个章节关切
	if not self.m_FinalChapter[type] then
		self.m_FinalChapter[type] = {}
	end
	self.m_FinalChapter[type] = {
		open = 1,
		pass = 0,
		star = 0,
		chapter = chapter,
		level = level,
		fight_time = 0,
		type = type,
	}
	if type == define.ChapterFuBen.Type.Difficult then
		IOTools.SetClientData("chapter_difficult_new", true)
	end
	self:OnEvent(define.ChapterFuBen.Event.OnChapterOpen)
end

function CChapterFuBenCtrl.OnReceiveUpdateChapterTotalStar(self, info)
	if not self.m_TotalStarInfos[info.type] then
		self.m_TotalStarInfos[info.type] = {}
	end
	self.m_TotalStarInfos[info.type][info.chapter] = info
	self:OnEvent(define.ChapterFuBen.Event.OnUpdateChapterTotalStar)
end

function CChapterFuBenCtrl.OnReceiveUpdateChapterExtraReward(self, info)
	if not self.m_ExtraRewardInfos[info.type] then
		self.m_ExtraRewardInfos[info.type] = {}
	end
	if not self.m_ExtraRewardInfos[info.type][info.chapter] then
		self.m_ExtraRewardInfos[info.type][info.chapter] = {}
	end
	self.m_ExtraRewardInfos[info.type][info.chapter][info.level] = info
	
	self:OnEvent(define.ChapterFuBen.Event.OnUpdateChapterExtraReward, info)
end

function CChapterFuBenCtrl.OnReceiveChapterInfo(self, info)
	for k,v in pairs(info) do
		if not self.m_AllChapterLevelInfos[v.type] then
			self.m_AllChapterLevelInfos[v.type] = {}
		end
		if not self.m_AllChapterLevelInfos[v.type][v.chapter] then
			self.m_AllChapterLevelInfos[v.type][v.chapter] = {}
		end
		self.m_AllChapterLevelInfos[v.type][v.chapter][v.level] = v
	end
	self:OnEvent(define.ChapterFuBen.Event.OnChapterInfo)
end

function CChapterFuBenCtrl.OnReceiveUpdateChapter(self, info)
	if not self.m_AllChapterLevelInfos[info.type] then
		self.m_AllChapterLevelInfos[info.type] = {}
	end
	if not self.m_AllChapterLevelInfos[info.type][info.chapter] then
		self.m_AllChapterLevelInfos[info.type][info.chapter] = {}
	end
	self.m_AllChapterLevelInfos[info.type][info.chapter][info.level] = table.copy(info)
	self:OnEvent(define.ChapterFuBen.Event.OnUpdateUpdateChapter, info)
	g_GuideCtrl:ReCheckChapterFubenGuide()
	g_TaskCtrl:RefreshUI()
end

function CChapterFuBenCtrl.OnReceiveUpdateEnergyBuytime(self, info)
	local energy_buytime = info.energy_buytime or self.m_EnergyBuytime or 0
	self.m_EnergyBuytime = energy_buytime
end

function CChapterFuBenCtrl.OnReceiveSweepChapterReward(self, reward, chapter, level, type)
	local dData = {
		chapter = chapter,
		level = level,
		reward = reward,
		type = type,
	}
	self:OnEvent(define.ChapterFuBen.Event.OnSweepChapterReward, dData)
end

function CChapterFuBenCtrl.IsOpenChapterFuBen(self)
	return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.chapterfuben.open_grade
		and data.globalcontroldata.GLOBAL_CONTROL.chapterfuben.is_open == "y" 
		and main.g_AppType  ~= "shenhe"
		and self:GetCurMaxChapter(define.ChapterFuBen.Type.Simple) > 0
end

function CChapterFuBenCtrl.IsOpenChapterDifficult(self)
	return self:IsOpenChapterFuBen() and self:GetCurMaxChapter(define.ChapterFuBen.Type.Difficult) > 0
end

function CChapterFuBenCtrl.GetCurMaxChapter(self, type)
	local type = type or define.ChapterFuBen.Type.Simple
	local chapter = self.m_FinalChapter[type] and self.m_FinalChapter[type].chapter
	chapter = chapter or 1
	local maxopenchapter = self:GetMaxOpenChapter(type)
	chapter = math.min(chapter, maxopenchapter)
	return chapter
end

function CChapterFuBenCtrl.GetMaxOpenChapter(self, type)
	local dDatalen = #DataTools.GetChapterInfo(type)
	local globalmax = 1
	if type == define.ChapterFuBen.Type.Simple then
		globalmax = tonumber(data.globaldata.GLOBAL.max_simple_chapter.value) 
	elseif type == define.ChapterFuBen.Type.Difficult then
		globalmax = tonumber(data.globaldata.GLOBAL.max_difficult_chapter.value) 
	end
	return math.min(globalmax, dDatalen)
end

function CChapterFuBenCtrl.GetFinalChapterLevel(self, type)
	type = type or 1
	local chapter, level = 1, 1
	if self.m_FinalChapter[type] then
		chapter = self.m_FinalChapter[type].chapter
		level = self.m_FinalChapter[type].level
	end
	return chapter, level
end

function CChapterFuBenCtrl.GetChapterTotalStar(self, type, chapterid)
	local dChapterStar = self.m_TotalStarInfos[type]
	if dChapterStar then
		dChapterStar = dChapterStar[chapterid]
	end
	if not dChapterStar then
		dChapterStar = {
			chapter = chapterid,
			star = 0,
			reward_status = 0,
			type = type,
		}
	end
	return dChapterStar
end

function CChapterFuBenCtrl.GetChapterLevelInfos(self, type, chapterid)
	return self.m_AllChapterLevelInfos[type] and self.m_AllChapterLevelInfos[type][chapterid]
end

function CChapterFuBenCtrl.GetChapterLevelInfo(self, type, chapterid, level)
	return self.m_AllChapterLevelInfos[type] and self.m_AllChapterLevelInfos[type][chapterid]
		and self.m_AllChapterLevelInfos[type][chapterid][level]
end

function CChapterFuBenCtrl.GetChapterExtraReward(self, type, chapterid, level)
	--reward_status已领取是1，可领取是0,没通关是不会有这个关卡的这个信息的
	return self.m_ExtraRewardInfos[type]
		and self.m_ExtraRewardInfos[type][chapterid]
		and self.m_ExtraRewardInfos[type][chapterid][level]
		or {chapter = chapterid, level=level, reward_status=nil}
end

function CChapterFuBenCtrl.OnReceiveChapterFbWinUI(self, war_id, win, player_exp, partner_exp, firstpass_reward, stable_reward, random_reward, star, condition, coin)
	local function getitem(v)
		local d = {
			id = v.id,
			sid = v.sid,
			amount = v.amount,
			virtual = v.virtual,
		}
		return d
	end
	local item_list = {}
	if coin > 0 then
		local d = {
			sid = 1002,
			amount = coin,
			virtual = 1002,
		}
		table.insert(item_list, d)
	end
	for i,v in ipairs(firstpass_reward) do
		table.insert(item_list, getitem(v))
	end
	for i,v in ipairs(stable_reward) do
		table.insert(item_list, getitem(v))
	end
	for i,v in ipairs(random_reward) do
		table.insert(item_list, getitem(v))
	end
	local dInfo = WarTools.GetResultInfo(player_exp, partner_exp, item_list)
	self.m_ResultInfo.exp_list = dInfo.exp_list
	self.m_ResultInfo.item_list = dInfo.item_list
	self.m_ResultInfo.condition = condition
	local oView = CChapterFuBenResultView:GetView()
	if oView then
		oView:RefreshResultInfo(self.m_ResultInfo.exp_list, self.m_ResultInfo.item_list, self.m_ResultInfo.condition)
		oView:SetDelayCloseView()
	end
end

function CChapterFuBenCtrl.ShowWarResult(self, oCmd)
	if oCmd.win then
		CChapterFuBenResultView:ShowView(function (oView)
			oView:RefreshResultInfo(self.m_ResultInfo.exp_list, self.m_ResultInfo.item_list, self.m_ResultInfo.condition)
			oView:SetDelayCloseView()
		end)
	else
		CWarResultView:ShowView(function (oView)
    		oView:SetWarID(oCmd.war_id)
    		oView:SetWin(false)
    		oView:SetDelayCloseView()
		end)
	end
end

function CChapterFuBenCtrl.GetEnergyBuytime(self)
	return self.m_EnergyBuytime
end

function CChapterFuBenCtrl.CheckChapterLevelPass(self, type, chapterid, level)
	local bPass = false
	local chapterlevel = self:GetChapterLevelInfo(type, chapterid, level)
	if chapterlevel then
		bPass = chapterlevel.pass == 1
	else
		local final = self.m_FinalChapter[type]
		if final and final.chapter and final.level then
			if chapterid < final.chapter then
				bPass = true
			elseif chapterid == final.chapter then
				if level < final.level then
					bPass = true
				elseif level == final.level then
					bPass = final.pass == 1 and final.open == 1
				end
			end
		end
	end
	return bPass
end

function CChapterFuBenCtrl.CheckChapterLevelOpen(self, type, chapterid, level)
	local bOpen = false
	local chapterlevel = self:GetChapterLevelInfo(type, chapterid, level)
	if chapterlevel then
		bOpen = true
	else
		local final = self.m_FinalChapter[type]
		if final and final.chapter and final.level then
			if chapterid < final.chapter then
				bOpen = true
			elseif chapterid == final.chapter  then
				if level < final.level then
					bOpen = true
				elseif level == final.level then
					bOpen = final.open == 1
				end
			end
		end
	end
	local dConfig = DataTools.GetChapterConfig(type, chapterid, level)
	for i,v in ipairs(dConfig.open_condition) do
		if string.find(v, "等级=") then
			for out in string.gmatch(v, "(%w+)") do
				local grade = tonumber(out)
				bOpen = bOpen and g_AttrCtrl.grade >= grade
				break
			end
		end
	end
	return bOpen
end

--返回true是已领取
--~printc(g_ChapterFuBenCtrl:CheckChapterRewardStatus(2,2,1))
function CChapterFuBenCtrl.CheckChapterRewardStatus(self, type, chapterid, rewardidx)
	local dChapterStar = self:GetChapterTotalStar(type, chapterid)
	return dChapterStar and dChapterStar.reward_status and MathBit.andOp(dChapterStar.reward_status, 2 ^ (rewardidx -1)) ~= 0
end

--返回true是可领取
--~printc(g_ChapterFuBenCtrl:CheckChapterRewardStatusCanGet(2,2,1))
function CChapterFuBenCtrl.CheckChapterRewardStatusCanGet(self, type, chapterid, rewardidx)
	local bGet = self:CheckChapterRewardStatus(type, chapterid, rewardidx)
	local dStarReward = DataTools.GetChapterStarReward(type, chapterid, rewardidx)
	local dChapterStar = self:GetChapterTotalStar(type, chapterid)
	local bCanGet = not bGet and dChapterStar.star >= dStarReward.star
	return bCanGet
end

--~g_ChapterFuBenCtrl:ForceChapterLevel(define.ChapterFuBen.Type.Simple, 1, 1, true)
function CChapterFuBenCtrl.ForceChapterLevel(self, type, chapterid, level, bGuide)
	local maxChapter = self:GetCurMaxChapter(type)
	if maxChapter == 0 then
		if not self:CheckLevelCondition(type, 1, 1) then
			return
		end
	end
	if chapterid > maxChapter then
		chapterid = maxChapter
		level = nil
	end
	CChapterFuBenMainView:ShowView(function (oView)
		oView:ForceChapterInfo(type, chapterid)
		if level then
			if bGuide then
				oView:SetGuideLevel(level)
			else
				oView.m_ChapterBox:SetForceLevel(level)
			end
		end
	end)
end

function CChapterFuBenCtrl.IsInChapterFuBen(self)
	return CChapterFuBenMainView:GetView()
end

function CChapterFuBenCtrl.HasRedDot(self)
	return self:HasRedDotSimple() or self:HasRedDotDifficult()
end

function CChapterFuBenCtrl.HasRedDotSimple(self)
	local v = self.m_TotalStarInfos[define.ChapterFuBen.Type.Simple]
	if v then
		for _,d in pairs(v) do
			local type
			if d.type and d.type > 0 then
				type = d.type
			else
				type = 1
			end
			if self:HasRedDotByChapter(type, d.chapter) then
				return true
			end
		end			
	end
end

function CChapterFuBenCtrl.HasRedDotDifficult(self)
	local v = self.m_TotalStarInfos[define.ChapterFuBen.Type.Difficult]
	if v then
		for _,d in pairs(v) do
			local type
			if d.type and d.type > 0 then
				type = d.type
			else
				type = 1
			end
			if self:HasRedDotByChapter(type, d.chapter) then
				return true
			end
		end			
	end
end

function CChapterFuBenCtrl.HasRedDotByChapter(self, type, chapter)
	--table.print(self.m_TotalStarInfos)
	--章节星星奖励
	local dStarReward = DataTools.GetChapterStarReward(type)
	local rewardlist = dStarReward[chapter]
	if rewardlist then
		for i,v in ipairs(rewardlist) do
			if self:CheckChapterRewardStatusCanGet(type, chapter, i) then
				return true
			end
		end
	end
	--关卡奖励
	local infos = self.m_ExtraRewardInfos[type]
	if infos then
		for _,d in pairs(infos) do
			for _,v in pairs(d) do
				if v.chapter == chapter then
					local dExtraReward = self:GetChapterExtraReward(type, chapter, v.level)
					local dInfo = self:GetChapterLevelInfo(type, chapter, v.level)
					if dExtraReward.reward_status == 0 and dInfo and dInfo.star == 3 then
						return true
					end
				end
			end
		end
	end
end

function CChapterFuBenCtrl.GetTaskPassDes(self, type, chapter, level)
	local str = ""
	local dData = DataTools.GetChapterConfig(type, chapter, level)
	if dData and dData.taskPassDes then
		str = dData.taskPassDes
	end
	return str
end

function CChapterFuBenCtrl.CheckLevelCondition(self, type, chapter, level)
	local dConfig = DataTools.GetChapterConfig(type, chapter, level)
	local tips
	if type == define.ChapterFuBen.Type.Simple then
		for i,v in ipairs(dConfig.open_condition) do
			if string.find(v, "完成剧情任务=") then
				for out in string.gmatch(v, "(%w+)") do
					local tsakid = tonumber(out)
					local iStory = g_TaskCtrl:GetLastStoryTaskId()
					if iStory > 0 and tsakid > iStory then
						tips = string.format("完成剧情任务 %s", g_TaskCtrl:GetValueByTaskIdAndKey(tsakid, "name"))
					end
				end
			elseif string.find(v, "通关=") then
				local sArr = string.split(v, "=")
				sArr = string.split(sArr[2], "-")
				local d = self:GetChapterLevelInfo(type, tonumber(sArr[1]), tonumber(sArr[2]))
				if not (d and d.pass == 1) then
					if tips then
						tips = string.format("%s, ", tips)
					else
						tips = ""
					end
					tips = string.format("通关战役%s-%s%s", sArr[1], sArr[2], tips)
				end
			elseif string.find(v, "等级=") then
				for out in string.gmatch(v, "(%w+)") do
					local grade = tonumber(out)
					if g_AttrCtrl.grade < grade then
						if tips then
							tips = string.format("%s, ", tips)
						else
							tips = ""
						end
						tips = string.format("%s达到等级%d开启", tips, grade)
					end
				end
			end
		end
	elseif type == define.ChapterFuBen.Type.Difficult then
		for i,v in ipairs(dConfig.open_condition) do
			if string.find(v, "通关困难关卡=") then
				local sArr = string.split(v, "=")
				sArr = string.split(sArr[2], "-")
				local d = self:GetChapterLevelInfo(type, tonumber(sArr[1]), tonumber(sArr[2]))
				if not (d and d.pass == 1) then
					tips = string.format("通关困难战役%s-%s", sArr[1], sArr[2])
				end		
			elseif string.find(v, "等级=") then
				for out in string.gmatch(v, "(%w+)") do
					local grade = tonumber(out)
					if g_AttrCtrl.grade < grade then
						if tips then
							tips = string.format("%s, ", tips)
						else
							tips = ""
						end
						tips = string.format("%s达到等级%d开启", tips, grade)
					end
				end
			elseif string.find(v, "通关=") then
				local sArr = string.split(v, "=")
				sArr = string.split(sArr[2], "-")
				local d = self:GetChapterLevelInfo(type, tonumber(sArr[1]), tonumber(sArr[2]))
				if not (d and d.pass == 1) then
					if tips then
						tips = string.format("%s, ", tips)
					else
						tips = ""
					end
					tips = string.format("%s通关战役%s-%s", tips, sArr[1], sArr[2])
				end
			end
		end
	end
	if tips then
		g_NotifyCtrl:FloatMsg(tips)
		return false
	end
	return true
end

return CChapterFuBenCtrl