-- ------------------------------
-- 诸神之战
-- hosr
-- ------------------------------
GodsWarManager = GodsWarManager or BaseClass(BaseManager)

function GodsWarManager:__init()
	if GodsWarManager.Instance then
		return
	end
	GodsWarManager.Instance = self

	self.model = GodsWarModel.New()

	self:InitHandler()

	-- 赛季状态
	self.status = 0
	-- 赛季
	self.season = 0

	-- 我的战队信息
	self.myData = nil

	-- 报名人数限制
	self.singupCountLimit = 5
	-- 查询邀请数据
	self.applyData = nil
	-- 队长id
	self.captinId = nil
	self.captin = nil

	self.replyYes = function() self:Send17903(1) end
	self.replyNo = function() self:Send17903(0) end

	self.requestRed = false
	self.signupRed = false

	-- 分组信息
	self.matchTab = {} --  小组赛
	self.elimintionTab = {} -- 淘汰赛

	self.settlementData = {} --冠军信息

    --历史8强信息
   self.hisElimintionTab = {}

	-- 我的对手
	self.myFighter = nil
	-- 双方准备数据
	self.readyData = nil
	self.readyDataOther = nil

	-- 比赛状态
	self.flag = 0
	-- 比赛倒计时
	self.left_time = 0
	-- 统计数据
	self.summaryData = nil

	-- 当前轮比赛结果,不靠谱数据，临时用
	self.myCurrentResult = nil

	-- 缓存投票情况
	self.mySelectData = {}
	-- 投票数
	self.voteCountDic = {}
	-- 投票结果
	self.voteDic = {}
	-- 是否投过票
	self.voted = false

	-- 录像平台区号
	self.videoPlatform = 0
	self.videoZondId = 0

    self.isHitstory = false
    self.selectSeason = 1

    --不在下拉列表显示的届数
    self.unShowList = {1,2}

	self.lvupListener = function()
		self:OnLevUpCheck()
	end

	self.OnUpdateTime = EventLib.New()
	self.godwarTimeData = nil
	self.godTimeNumber = 0

	self.godsWarJiFenAllData = {}
	self.godsWarJiFenData = {}
	self.OnUpdateGodsWarData = EventLib.New()
	self.OnUpdateGodsWarOtherData = EventLib.New()
	self.OnUpdateGodsWarRankData = EventLib.New()
end

function GodsWarManager:__delete()
end

function GodsWarManager:InitHandler()
    self:AddNetHandler(17900, self.On17900)
    self:AddNetHandler(17901, self.On17901)
    self:AddNetHandler(17902, self.On17902)
    self:AddNetHandler(17903, self.On17903)
    self:AddNetHandler(17904, self.On17904)
    self:AddNetHandler(17905, self.On17905)
    self:AddNetHandler(17906, self.On17906)
    self:AddNetHandler(17907, self.On17907)
    self:AddNetHandler(17908, self.On17908)
    self:AddNetHandler(17909, self.On17909)
    self:AddNetHandler(17910, self.On17910)
    self:AddNetHandler(17911, self.On17911)
    self:AddNetHandler(17912, self.On17912)
    self:AddNetHandler(17913, self.On17913)
    self:AddNetHandler(17914, self.On17914)
    self:AddNetHandler(17915, self.On17915)
    self:AddNetHandler(17916, self.On17916)
    self:AddNetHandler(17917, self.On17917)
    self:AddNetHandler(17918, self.On17918)
    self:AddNetHandler(17919, self.On17919)
    self:AddNetHandler(17920, self.On17920)
    self:AddNetHandler(17921, self.On17921)
    self:AddNetHandler(17922, self.On17922)
    self:AddNetHandler(17923, self.On17923)
    self:AddNetHandler(17924, self.On17924)
    self:AddNetHandler(17925, self.On17925)
    self:AddNetHandler(17926, self.On17926)
    self:AddNetHandler(17927, self.On17927)
    self:AddNetHandler(17928, self.On17928)
    self:AddNetHandler(17929, self.On17929)
    self:AddNetHandler(17930, self.On17930)
    self:AddNetHandler(17931, self.On17931)
    self:AddNetHandler(17932, self.On17932)
    self:AddNetHandler(17933, self.On17933)
    self:AddNetHandler(17934, self.On17934)
    self:AddNetHandler(17935, self.On17935)
    self:AddNetHandler(17936, self.On17936)
    self:AddNetHandler(17937, self.On17937)
    self:AddNetHandler(17959, self.On17959)
    self:AddNetHandler(17962, self.On17962)
    self:AddNetHandler(17963, self.On17963)
	self:AddNetHandler(17964, self.On17964)
	self:AddNetHandler(17966, self.On17966)
	self:AddNetHandler(17967, self.On17967)
end

function GodsWarManager:RequestInitData()
	self.myCurrentResult = nil
	self.myData = nil
	self.myFighter = nil
	self.readyData = nil
	self.readyDataOther = nil
	self.applyData = nil
	self.matchTab = {}
	self.requestRed = false
	self.signupRed = false
	self.status = 0
	self.season = 0
	self.left_time = 0
	self.flag = 0
	self.mySelectData = {}
	self.model:Clear()

	self:Send17900()
	self:Send17915()
	self:Send17934()
	self:Send17936()
	self:Send17966()


	self.model:RoleEventChange()
    EventMgr.Instance:AddListener(event_name.role_level_change, self.lvupListener)
end

function GodsWarManager:Test()
	self.model:Test()
end

function GodsWarManager:GetLeftTime()
	local val = 0
	if self.flag == 2 then
		if self.status >= GodsWarEumn.Step.Elimination32Idel then
			val = 3600 - (BaseUtils.BASE_TIME - self.left_time)
		else
			val = 1200 - (BaseUtils.BASE_TIME - self.left_time)
		end
	else
		val = 600 - (BaseUtils.BASE_TIME - self.left_time)
	end
	return math.max(0, val)
end

function GodsWarManager:SetIcon(isviewer, noticetosign)
    MainUIManager.Instance:DelAtiveIcon(119)

    if self.status == GodsWarEumn.Step.Prepare or self.status == GodsWarEumn.Step.Sign then
	    self.activeIconData = AtiveIconData.New()
	    local iconData = DataSystem.data_daily_icon[119]
	    self.activeIconData.id = iconData.id
	    self.activeIconData.iconPath = iconData.res_name
	    self.activeIconData.sort = iconData.sort
	    self.activeIconData.lev = iconData.lev
	    -- if isviewer then
	    -- 	self.activeIconData.clickCallBack = function()
	    -- 		LuaTimer.Add(200, function() self:IconNotice() end)
	    -- 	end
	    -- else
	    	-- self.activeIconData.clickCallBack = function() self:Send17919() end
	    -- end
	    if noticetosign or (self.myData ~= nil and self.myData.tid == 0) then
			self.activeIconData.text = TI18N("<color='#ffff00'>可报名</color>")
	    	self.activeIconData.clickCallBack = function() self.model:OpenMain({2,3}) end
		-- elseif self.flag == 1 then
		-- 	self.activeIconData.text = TI18N("<color='#ffff00'>准备中</color>")
		-- 	self.activeIconData.clickCallBack = function() self.model:OpenMain({2}) end
		else
			-- self.activeIconData.timestamp = self:GetLeftTime()
			self.activeIconData.text = TI18N("<color='#ffff00'>报名成功</color>")
			self.activeIconData.clickCallBack = function() self.model:OpenMain({1,2}) end
			-- 	print(debug.traceback())
		end
	    MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
	else
		if self.status == GodsWarEumn.Step.ChallengeIdel or self.status == GodsWarEumn.Step.Challenge then
			return
		end
		local nextStatusTime = self:GetNextStatusTime()
		-- Log.Error("========================================================")
		-- Log.Error(tostring(nextStatusTime))
		if nextStatusTime ~= nil then
			if self.myData ~= nil then
				self.activeIconData = AtiveIconData.New()
			    local iconData = DataSystem.data_daily_icon[119]
			    self.activeIconData.id = iconData.id
			    self.activeIconData.iconPath = iconData.res_name
			    self.activeIconData.sort = iconData.sort
			    self.activeIconData.lev = iconData.lev
			    if nextStatusTime == 0 then
			    	--比赛阶段（可以进场景）
			    	if self.status >= GodsWarEumn.Step.Elimination32Idel then
				    	local name = GodsWarEumn.StepName[self.status]
				    	self.activeIconData.text = string.format(TI18N("<color='#ffff00'>%s</color>"), name)
				    else
				    	self.activeIconData.text = TI18N("<color='#ffff00'>小组赛</color>")
				    end
				    self.activeIconData.clickCallBack = function() self:Send17919() end
			    else
					self.activeIconData.timestamp = (nextStatusTime - BaseUtils.BASE_TIME) + Time.time

					if self.myData ~= nil and self.myData.tid == 0 then
						self.activeIconData.clickCallBack = function() self:VoteOrOpenWindow() end
					else
						self.activeIconData.clickCallBack = function() self.model:OpenMain({1,2}) end
					end
				end
				MainUIManager.Instance:AddAtiveIcon(self.activeIconData)
			end
		end
	end
end

function GodsWarManager:GetNextStatusTime()
	if self.status == GodsWarEumn.Step.Publicity
		or (self.status >= GodsWarEumn.Step.Audition1Idel and self.status <= GodsWarEumn.Step.FinalIdel and self.status % 2 == 0) then
		local data_time = nil
		table.sort(self.godwarTimeData, function(a,b) return a.state_code < b.state_code end)
		for _,value in ipairs(self.godwarTimeData) do
			if value.state_code > self.status and not GodsWarEumn.ExceptStep(value.state_code) then
				data_time = value
				-- BaseUtils.dump(data_time,"下一阶段距离时间")
				break
			end
		end
		-- for key, value in pairs(DataGodsDuel.data_time) do
		-- 	if value.type == self.status + 1 then
		-- 		data_time = value
		-- 	end
		-- end

		if data_time == nil then
			return
		end

		local y = tonumber(os.date("%Y", data_time.start_time))
        local m = tonumber(os.date("%m", data_time.start_time))
        local d = tonumber(os.date("%d", data_time.start_time))
        local h = tonumber(os.date("%H",data_time.start_time))
        local mini = tonumber(os.date("%M",data_time.start_time))
        local s = tonumber(os.date("%S",data_time.start_time))

		local timeTab = {year=y, month=m, day=d, hour=h,min=mini,sec=s,isdst=false}
		local nextTimestamp = os.time(timeTab)

		if nextTimestamp - BaseUtils.BASE_TIME < 172800 then
			return nextTimestamp
		end
	elseif self.status >= GodsWarEumn.Step.Audition1 and self.status <= GodsWarEumn.Step.Final and self.status % 2 == 1 then
		return 0
	end
end

function GodsWarManager:VoteOrOpenWindow()
	if GodsWarManager.Instance.status <= GodsWarEumn.Step.Elimination16 then
		self.model:OpenMain({1})
	else
		local num = BackpackManager.Instance:GetItemCount(21719)
		if num > 0  then
			-- self.model:OpenVote()
			self.model:OpenMain({3})
		else
			self.model:OpenMain({1,2})
		end
	end
end

function GodsWarManager:IconNotice(type, str)
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.showClose = 1
    confirmData.sureLabel = TI18N("前往观战")
    confirmData.cancelLabel = TI18N("查看录像")
    if str == nil then
	    if type == 1 then
	    	confirmData.content = TI18N("您已经完成了本轮比赛")
	    else
	    	confirmData.content = TI18N("很遗憾，您没有参赛资格哦{face_1,15}")
	    end
	else
		confirmData.content = str
    end
	confirmData.cancelCallback = function()
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)})
	end
    confirmData.sureCallback = function()
    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 2, group = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)})
	end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function GodsWarManager:SignUp()
	if self.myData == nil or self.myData.tid == 0 then
		-- 您当前还没有任何战队哦，只有加入战队后方能报名
	    local confirmData = NoticeConfirmData.New()
	    confirmData.type = ConfirmData.Style.Normal
	    confirmData.sureLabel = TI18N("建立战队")
	    confirmData.cancelLabel = TI18N("战队列表")
	    confirmData.sureCallback = function()
	    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {2})
	    	self.model:OpenCreate()
	    end
	    confirmData.cancelCallback = function()
	    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {2})
	    end
	    confirmData.content = TI18N("您需要加入拥有<color='#ffff00'>五人或以上</color>成员的战队方可报名参赛哦")
	    NoticeManager.Instance:ConfirmTips(confirmData)
	else
		if self:IsSelfCaptin() then
			if GodsWarManager.Instance.myData.qualification >= GodsWarEumn.Quality.Sign then
				NoticeManager.Instance:FloatTipsByString(TI18N("你已报名"))
			else
				if self:MemberCount() >= self.singupCountLimit then
					self:Send17916()
				else
				    local confirmData = NoticeConfirmData.New()
				    confirmData.type = ConfirmData.Style.Normal
				    confirmData.sureLabel = TI18N("确定")
				    confirmData.cancelLabel = TI18N("邀请成员")
				    confirmData.content = TI18N("您的战队需要拥有<color='#ffff00'>至少五名</color>成员方可报名参赛哦")
				    confirmData.cancelCallback = function()
				    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {2})
				    	self.model:OpenApply()
				    end
				    NoticeManager.Instance:ConfirmTips(confirmData)
				end
			end
		else
			NoticeManager.Instance:FloatTipsByString(TI18N("只有<color='#ffff00'>战队队长</color>才能报名参赛"))
		end
	end
end

-- 成员人数
function GodsWarManager:MemberCount()
	if self.myData == nil then
		return 0
	else
		return #self.myData.members
	end
end

-- 自己是不是队长
function GodsWarManager:IsSelfCaptin()
	return (BaseUtils.get_self_id() == self.captinId)
end

-- 检查红点
function GodsWarManager:CheckRed()
	if self.myData == nil then
		self.requestRed = false
		self.signupRed = false
		return
	end

	if #self.myData.applys > 0 then
		self.requestRed = true
	else
		self.requestRed = false
	end

	if self.status == GodsWarEumn.Step.Sign
		and #self.myData.members >= 5
		and self.myData.qualification < GodsWarEumn.Quality.Sign
		then
		self.signupRed = true
	else
		self.signupRed = false
	end
end

function GodsWarManager:AgendaRed()
	return (self.requestRed or self.signupRed)
end

-- 进入战队是检查
function GodsWarManager:CheckIn(player, callback)
	-- local group = GodsWarEumn.Group(self.myData.lev, self.myData.break_times)
	local group = self.myData.lev
	local newGroup = GodsWarEumn.Group(player.lev, player.break_times)
	if newGroup > group then
		local levstr = player.lev
		if player.break_times == 1 then
			levstr = string.format(TI18N("突破%s"), player.lev)
		end
		local str = string.format(TI18N("<color='#ffff00'>%s</color>等级达到<color='#00ff00'>%s</color>级，加入战队后将使您的战队等级分组从<color='#ffff00'>%s</color>提升至<color='#ffff00'>%s</color>"), player.name, levstr, GodsWarEumn.GroupName(group), GodsWarEumn.GroupName(newGroup))
	    local confirmData = NoticeConfirmData.New()
	    confirmData.type = ConfirmData.Style.Normal
	    confirmData.sureLabel = TI18N("确定")
	    confirmData.cancelLabel = TI18N("取消")
	    confirmData.sureCallback = callback
	    confirmData.content = str
	    NoticeManager.Instance:ConfirmTips(confirmData)
	else
		if callback ~= nil then
			callback()
		end
	end
end

-- 在准备区队伍变更
function GodsWarManager:TeamChange(code, callback)
	if self.flag == 1 then
	    local data = NoticeConfirmData.New()
	    data.type = ConfirmData.Style.Normal
	    if code == 11706 then
	    	data.cancelLabel = TI18N("依然暂离")
	    	data.content = TI18N("当前已处于诸神之战准备状态，暂离将退出准备状态，是否<color='#ffff00'>暂离</color>")
	    elseif code == 11708 then
	    	data.cancelLabel = TI18N("依然离队")
	    	data.content = TI18N("当前已处于诸神之战准备状态，离队将退出准备状态，是否<color='#ffff00'>离队</color>")
	    elseif code == 11710 then
	    	data.cancelLabel = TI18N("依然踢除")
	    	data.content = TI18N("当前已处于诸神之战准备状态，踢除队员将退出准备状态，是否<color='#ffff00'>踢除</color>")
	    else
	    	data.cancelLabel = TI18N("依然暂离")
	    	data.content = TI18N("当前已处于诸神之战准备状态，暂离/离队将退出准备状态，是否<color='#ffff00'>暂离/离队</color>")
	    end
	    data.sureLabel = TI18N("取消")
	    data.cancelCallback = callback
	    NoticeManager.Instance:ConfirmTips(data)
	else
		callback()
	end
end

function GodsWarManager:ReadyCheck()
	if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() then
		NoticeManager.Instance:FloatTipsByString(TI18N("该操作只能由队长进行哦"))
		return
	end

	if self.readyData ~= nil and self.readyData.status == 1 then
		self:Send17927()
	else
		if TeamManager.Instance:HasLeave() then
			NoticeManager.Instance:FloatTipsByString(TI18N("队伍中有人暂离，不能准备哦"))
		elseif TeamManager.Instance:HasOffline() then
			NoticeManager.Instance:FloatTipsByString(TI18N("队伍中有人离线，不能准备哦"))
		else
			local count = TeamManager.Instance:MemberCount()
			if count < 4 then
				NoticeManager.Instance:FloatTipsByString(TI18N("参战人数要求<color='#ffff00'>4</color>人以上"))
			elseif count >= 4 and count < 5 then
			    local data = NoticeConfirmData.New()
			    data.type = ConfirmData.Style.Normal
			    data.content = TI18N("当前队伍人数不足<color='#ffff00'>5</color>人，是否确定准备就绪？")
			    data.sureLabel = TI18N("确定")
			    data.cancelLabel = TI18N("取消")
			    data.sureCallback = function() self:Send17921() end
			    NoticeManager.Instance:ConfirmTips(data)
			else
				self:Send17921()
			end
		end
	end
end

-- ----------------------------------
-- 协议处理
-- ----------------------------------

-- 初始化获取战队数据
function GodsWarManager:Send17900()
	self:Send(17900, {})
end

function GodsWarManager:On17900(dat)
	--BaseUtils.dump(dat, "17900000000000000000")
	for i,v in ipairs(dat.members) do
		if v.position == GodsWarEumn.Position.Captin then
			self.captin = v
			self.captinId = string.format("%s_%s_%s", dat.platform, dat.zone_id, dat.tid)
		end
	end

	-- if self:IsSelfCaptin() and self.myData ~= nil and self.myData.tid == 0 and dat.tid ~= 0 then
	local isCreate = false
	if self.myData ~= nil and self.myData.tid == 0 and dat.tid ~= 0 then
		isCreate = true
	end

	self.myData = dat
	self:CheckRed()

	EventMgr.Instance:Fire(event_name.godswar_team_update)

	if isCreate then
		-- MainUIManager.Instance:DelAtiveIcon(119)  -- 创建完成去掉主ui图标
		self:SetIcon()
		WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_main, {2, 1})
		self.model:PlayCreateEffect()
	end
end

-- 创建战队
function GodsWarManager:Send17901(name)
	self:Send(17901, {name = name})
end

function GodsWarManager:On17901(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
	if dat.err_code == 1 then
		self.model:CreateCoolDown()
	end
end

-- 推送战队创建请求
function GodsWarManager:Send17902()
	self:Send(17902, {})
end

function GodsWarManager:On17902(dat)
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.sureLabel = TI18N("加入")
    confirmData.cancelLabel = TI18N("婉拒")
    confirmData.cancelSecond = 30
    if dat.type == 1 then
	    confirmData.sureCallback = function() self:Send17903(1) end
	    confirmData.cancelCallback = function() self:Send17903(0) end
	    confirmData.content = string.format(TI18N("<color='#23f0f7'>%s</color>将创建诸神之战战队<color='#ffff00'>%s</color>，并邀请您加入"), dat.leader_name, dat.name)
    elseif dat.type == 2 then
	    confirmData.sureCallback = function() self:Send17911(1) end
	    confirmData.cancelCallback = function() self:Send17911(0) end
	    confirmData.content = string.format(TI18N("<color='#23f0f7'>%s</color>邀请你加入诸神之战战队<color='#ffff00'>%s</color>，是否同意"), dat.leader_name, dat.name)
    end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 回复创建战队
function GodsWarManager:Send17903(flag)
	self:Send(17903, {flag = flag})
end

function GodsWarManager:On17903(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 解散(退出)战队
function GodsWarManager:Send17904()
	self:Send(17904, {})
end

function GodsWarManager:On17904(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 邀请队伍成员加入战队
function GodsWarManager:Send17905(id, platform, zone_id)
	self:Send(17905, {id = id, platform = platform, zone_id = zone_id})
end

function GodsWarManager:On17905(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 查看战队列表
function GodsWarManager:Send17906()
	self:Send(17906, {})
end

function GodsWarManager:On17906(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
	EventMgr.Instance:Fire(event_name.godswar_list_update, dat.team_list)
end

-- 申请加入战队
function GodsWarManager:Send17907(tid, platform, zone_id)
	self:Send(17907, {tid = tid, platform = platform, zone_id = zone_id})
end

function GodsWarManager:On17907(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 批准加入战队
function GodsWarManager:Send17908(rid, platform, zone_id, flag)
	self:Send(17908, {rid = rid, platform = platform, zone_id = zone_id, flag = flag})
end

function GodsWarManager:On17908(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 踢出战队成员
function GodsWarManager:Send17909(rid, platform, zone_id)
	self:Send(17909, {rid = rid, platform = platform, zone_id = zone_id})
end

function GodsWarManager:On17909(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 查询可邀请列表
function GodsWarManager:Send17910(type)
	self:Send(17910, {type = type})
end

function GodsWarManager:On17910(dat)
	self.applyData = dat
	EventMgr.Instance:Fire(event_name.godswar_apply_update)
end

-- 回复战队邀请
function GodsWarManager:Send17911(type)
	self:Send(17911, {type = type})
end

function GodsWarManager:On17911(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 战队改名
function GodsWarManager:Send17912(name)
	self:Send(17912, {name = name})
end

function GodsWarManager:On17912(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 修改战队公告
function GodsWarManager:Send17913(declaration)
	self:Send(17913, {declaration = declaration})
end

function GodsWarManager:On17913(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 替补更换
function GodsWarManager:Send17914(fid1, platform1, zone_id1, fid2, platform2, zone_id2)
	self:Send(17914, {fid1 = fid1, platform1 = platform1, zone_id1 = zone_id1, fid2 = fid2, platform2 = platform2, zone_id2 = zone_id2})
end

function GodsWarManager:On17914(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 获取赛季状态
function GodsWarManager:Send17915()
	self:Send(17915, {})
end

function GodsWarManager:On17915(dat)
	-- print("收到17915")
	-- print("诸神之战当前阶段————" .. dat.state)
	if self.status ~= dat.state then
		-- 状态切换的时候，清空分组信息重新请求
		self.matchTab = {}
		self.elimintionTab = {}
	end

	if self.status ~= dat.state and dat.state == 0 then

	end

	self.status = dat.state
	self.season = dat.season_id
	self:Send17933(true)


	if self.status == 24 or self.status == 26  or self.status == 28 or self.status == 30 then
		local num = BackpackManager.Instance:GetItemCount(21719)
		if num > 0  then

                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = TI18N("诸神之战赛事可投票，是否前往？")
                data.sureLabel = TI18N("确认")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function ()
                	self.model:OpenVote()
                end
                NoticeManager.Instance:ConfirmTips(data)

		end
	end

end

-- 战队报名
function GodsWarManager:Send17916()
	self:Send(17916, {})
end

function GodsWarManager:On17916(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 查询小组赛分组队伍信息
function GodsWarManager:Send17917(zone_id, index)
	self:Send(17917, {zone_id = zone_id, index = index})
end

function GodsWarManager:On17917(dat)
	local zone_id = dat.zone_id
	local index = dat.index
	if self.matchTab[zone_id] == nil then
		self.matchTab[zone_id] = {}
	end
	self.matchTab[zone_id][index] = dat.team_list

	EventMgr.Instance:Fire(event_name.godswar_match_update)
end

-- 根据分组和页码获取对应数据
function GodsWarManager:GetMatchData(zone_id, index)
	if self.matchTab[zone_id] == nil then
		self:Send17917(zone_id, index)
		return nil
	else
		if self.matchTab[zone_id][index] == nil then
			self:Send17917(zone_id, index)
			return nil
		else
			return self.matchTab[zone_id][index]
		end
	end
end

-- 获取淘汰赛分组列表
function GodsWarManager:GetElimintionData(zone)
	if self.elimintionTab[zone] == nil then
		self:Send17925(zone)
		return {}
	else
		local team_list = self.elimintionTab[zone]
		local list = team_list

		if self.status >= GodsWarEumn.Step.Elimination4Idel or self.status == GodsWarEumn.Step.None then
			list = {}
			for i,indexList in ipairs(GodsWarEumn.PositionIndex) do
				for j,index in ipairs(indexList) do
					local d = team_list[index]
					if d ~= nil and d.qualification >= GodsWarEumn.Quality.Q8 then
						table.insert(list, d)
					end
				end
			end
		end
		return list
	end
end

--get 根据届数和分组获取诸神之战历史8强信息，不包含当前届
function GodsWarManager:GetHisElimintionData(selSeason,zone)
    local key = BaseUtils.Key(selSeason,zone)
	if self.hisElimintionTab[key] == nil then
		self:Send17932(selSeason,zone)
		return {}
	else
		local team_list = self.hisElimintionTab[key]
		local list = {}
		for i,indexList in ipairs(GodsWarEumn.PositionIndex) do
			for j,index in ipairs(indexList) do
				local d = team_list[index]
				if d ~= nil and d.qualification >= GodsWarEumn.Quality.Q8 then
					table.insert(list, d)
				end
			end
		end
		return list
	end
end



-- 获取我的对战信息
function GodsWarManager:Send17918()
	self:Send(17918, {})
end

function GodsWarManager:On17918(dat)
	-- BaseUtils.dump(dat, "888888888888888888888888888888")
	self.myCurrentResult = nil
	self.myFighter = dat
	EventMgr.Instance:Fire(event_name.godswar_fighter_update)
end

-- 诸神比赛入场
function GodsWarManager:Send17919()
	-- print("Send17919")
	self:Send(17919, {})
end

function GodsWarManager:On17919(dat)
	BaseUtils.dump(dat, "On17919")
	if dat.err_code == 0 then
		if dat.msg == TI18N("您已经完成了本轮对战") or dat.msg == TI18N("您的战队已经完成了本轮对战") then
			self.model:OpenMain({1,2})
		elseif dat.msg == TI18N("您还没有战队呢，等待下一赛季的到来吧") or dat.msg == TI18N("您的战队今日没赛事，请查看战队比赛状态")  or dat.msg == TI18N("现在不是入场时间，请等待比赛开始吧") then
				self.model:OpenMain({3})
		elseif self.status >= GodsWarEumn.Step.Elimination32Idel then
				self:IconNotice(1, dat.msg)
		end
	end
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 诸神离场
function GodsWarManager:Send17920()
	self:Send(17920, {})
end

function GodsWarManager:On17920(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 准备就绪
function GodsWarManager:Send17921()
	self:Send(17921, {})
end

function GodsWarManager:On17921(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 战队准备状态信息
function GodsWarManager:Send17922()
	self:Send(17922, {})
end

function GodsWarManager:On17922(dat)
	-- BaseUtils.dump(dat, "22222222222222222222222222222")

	local lastStatus1 = 0
	local lastStatus2 = 0
	if self.readyData ~= nil then
		lastStatus1 = self.readyData.status
	end

	if self.readyDataOther ~= nil then
		lastStatus2 = self.readyDataOther.status
	end

	self.readyData = {}
	self.readyDataOther = {}
	if dat.tid_1 == self.myData.tid then
		self.readyData.tid = dat.tid_1
		self.readyData.platform = dat.platform_1
		self.readyData.zone_id = dat.id_1
		self.readyData.team_name = dat.team_name_1
		self.readyData.status = dat.status_1

		self.readyDataOther.tid = dat.tid_2
		self.readyDataOther.platform = dat.platform_2
		self.readyDataOther.zone_id = dat.id_2
		self.readyDataOther.team_name = dat.team_name_2
		self.readyDataOther.status = dat.status_2
	else
		self.readyDataOther.tid = dat.tid_1
		self.readyDataOther.platform = dat.platform_1
		self.readyDataOther.zone_id = dat.id_1
		self.readyDataOther.team_name = dat.team_name_1
		self.readyDataOther.status = dat.status_1

		self.readyData.tid = dat.tid_2
		self.readyData.platform = dat.platform_2
		self.readyData.zone_id = dat.id_2
		self.readyData.team_name = dat.team_name_2
		self.readyData.status = dat.status_2
	end
	EventMgr.Instance:Fire(event_name.godswar_ready_update)

	local newStatus1 = self.readyData.status
	local newStatus2 = self.readyDataOther.status

	local showNotice = false
	local str = ""
	if (lastStatus1 == 0 and newStatus1 == 1 and lastStatus2 == 0 and newStatus2 == 0) then
		showNotice = true
		str = string.format(TI18N("%s<color='#31f2f9'>(%s)</color>已经准备就绪"), self.readyData.team_name, BaseUtils.GetServerNameMerge(self.readyData.platform, self.readyData.zone_id))
	elseif (lastStatus1 == 0 and newStatus1 == 0 and lastStatus2 == 0 and newStatus2 == 1) then
		showNotice = true
		str = string.format(TI18N("%s<color='#31f2f9'>(%s)</color>已经准备就绪"), self.readyDataOther.team_name, BaseUtils.GetServerNameMerge(self.readyDataOther.platform, self.readyDataOther.zone_id))
	end

	if showNotice then
	    local data = NoticeConfirmData.New()
	    data.type = ConfirmData.Style.Sure
	    data.content = str
	    data.sureLabel = TI18N("确定")
	    data.sureSecond = 8
	    NoticeManager.Instance:ConfirmTips(data)
	end
end

-- 活动状态信息
function GodsWarManager:Send17923()
	self:Send(17923, {})
end

function GodsWarManager:On17923(dat)
	BaseUtils.dump(dat, "333333333333333333333333333")
	self.left_time = dat.left_time
	self.flag = dat.flag
	self.status = dat.state
	if GodsWarEumn.IsFighting() then
		-- 开打后清空一下分组列表，重新请求
		self.matchTab = {}
	end

	local notice = false
	local viewer = false
	if (self.status == GodsWarEumn.Step.Audition1 or self.status == GodsWarEumn.Step.Audition2 or self.status == GodsWarEumn.Step.Audition3 or self.status == GodsWarEumn.Step.Audition4 or self.status == GodsWarEumn.Step.Audition5 or self.status == GodsWarEumn.Step.Audition6 or self.status == GodsWarEumn.Step.Audition7)
		and self.myData ~= nil and self.myData.qualification >= GodsWarEumn.Quality.Sign then
		-- and self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.Q256 then
		notice = true
	elseif self.status == GodsWarEumn.Step.Elimination32 then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.Q64 then
		else
			viewer = true
		end
	elseif self.status == GodsWarEumn.Step.Elimination16 then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.Q32 then
		else
			viewer = true
		end
	elseif self.status == GodsWarEumn.Step.Elimination8 then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.Q16 then
		else
			viewer = true
		end
	elseif self.status == GodsWarEumn.Step.Elimination4 then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.Q8 then
		else
			viewer = true
		end
	elseif self.status == GodsWarEumn.Step.Semifinal then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.Q4 then
		else
			viewer = true
		end
	elseif self.status == GodsWarEumn.Step.Thirdfinal then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.ThirdPlace then
		else
			viewer = true
		end
	elseif self.status == GodsWarEumn.Step.Final then
		notice = true
		if self.myData ~= nil and self.myData.qualification == GodsWarEumn.Quality.ChampionPlace then
		else
			viewer = true
		end
	end

	if notice and RoleManager.Instance.RoleData.lev >= 70 then
		self:SetIcon(viewer)
		if self.flag ~= 0 and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GodsWar then
		    local data = NoticeConfirmData.New()
		    data.type = ConfirmData.Style.Normal
		    data.sureLabel = TI18N("确定")
		    data.cancelLabel = TI18N("取消")
		    data.cancelSecond = 180
			if viewer then
				data.content = TI18N("<color='#ffff00'>诸神之战</color>即将开始，是否前往观战？")
				data.sureCallback = function()
					WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 2, group = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)})
				end
			else
				data.content = TI18N("<color='#ffff00'>诸神之战</color>即将开始，是否进场准备？")
				data.sureCallback = function() self:Send17919() end
			end
		    NoticeManager.Instance:ActiveConfirmTips(data)
		    self.matchTab = {}
		    self.elimintionTab = {}
		end
	else
		-- 报名阶段活动图标额外判断显示
		local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
		if self.status == GodsWarEumn.Step.Sign and self.myData ~= nil and self.myData.tid == 0 and RoleManager.Instance.RoleData.lev >= 80 and currentHour > 5 and currentHour <= 16 then
			self:SetIcon(true, true)
		else
			-- MainUIManager.Instance:DelAtiveIcon(119)
			-- self:SetIcon()
		end
	end

	EventMgr.Instance:Fire(event_name.godswar_time_update)
end

-- 通知战斗开始
function GodsWarManager:Send17924()
	self:Send(17924, {})
end

function GodsWarManager:On17924(dat)
	self.model:OpenFightShow(dat.team_list)
end

-- 查询64强对战分组
function GodsWarManager:Send17925(zone)
	self:Send(17925, {zone_id = zone})
end

function GodsWarManager:On17925(dat)
	-- BaseUtils.dump(dat, "252525252525252525252525")
	local list = {}
	for i,v in ipairs(dat.team_list) do
		list[v.team_group_64] = v
	end

	self.elimintionTab[dat.zone_id] = list
	EventMgr.Instance:Fire(event_name.godswar_match_update)
end

-- 战斗结果
function GodsWarManager:Send17926()
	self:Send(17926, {})
end

function GodsWarManager:On17926(dat)
	self.summaryData = dat
	local result = dat.result
	self.model:OpenFightResult({result = result})
	GodsWarManager.Instance.myCurrentResult = result
	EventMgr.Instance:Fire(event_name.godswar_fightresult_update, result)
end

function GodsWarManager:Send17927()
	self:Send(17927, {})
end

function GodsWarManager:On17927(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 获取对战的录像列表
function GodsWarManager:Send17928(season_id, group_id, watch_type)
	self:Send(17928, {season_id = season_id, group_id = group_id, watch_type = watch_type})
end

function GodsWarManager:On17928(dat)
	--BaseUtils.dump(dat, "88888888888888888888888888888888")
	self.videoPlatform = dat.platform
	self.videoZondId = dat.zone_id
	EventMgr.Instance:Fire(event_name.godswar_video_update, dat.gods_duel_match_profile)
end

--观战or查看录像
function GodsWarManager:Send17929(id)
	CombatManager.Instance.currRecData = {type = 13, rec_id = id, platform = "", zone_id = 0}
	self:Send(17929, {id = id})
end

function GodsWarManager:On17929(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

--获取投票情况
function GodsWarManager:Send17930()
	self:Send(17930, {})
end

function GodsWarManager:On17930(dat)
	-- BaseUtils.dump(dat, "0000000000000000000000")
	self.voteDic = {}
	self.voted = false
	local maxRound = 0
	for i,v in ipairs(dat.gods_duel_vote_choice) do
		if self.voteDic[v.match_round] == nil then
			self.voteDic[v.match_round] = {}
		end
		local key = string.format("%s_%s_%s", v.tid, v.platform, v.zone_id)
		self.voteDic[v.match_round][key] = v
		maxRound = math.max(maxRound, v.match_round)
	end

	for i = maxRound - 1, 0, -1 do
		self.voteDic[i] = nil
	end

	if self.status <= GodsWarEumn.Step.Elimination4 then
		if maxRound >= 4 then
			self.voted = true
		end
	elseif self.status <= GodsWarEumn.Step.Semifinal then
		if maxRound >= 5 then
			self.voted = true
		end
	elseif self.status <= GodsWarEumn.Step.Thirdfinal then
		if maxRound >= 6 then
			self.voted = true
		end
	elseif self.status <= GodsWarEumn.Step.Final then
		if maxRound >= 7 then
			self.voted = true
		end
	end

	self.voteCountDic = {}
	for i,v in ipairs(dat.gods_duel_poll) do
		local key = string.format("%s_%s_%s", v.tid, v.platform, v.zone_id)
		self.voteCountDic[key] = v.voted_cnt
	end

	EventMgr.Instance:Fire(event_name.godswar_vote_update, dat)
end

-- 诸神之战进行投票
-- list= {tid, platform, zone_id}
function GodsWarManager:Send17931(match_zone, list)
	local data = {match_zone = match_zone, id = list}
	-- BaseUtils.dump(data, "111111111111111111111111")
	self:Send(17931, data)
end

function GodsWarManager:On17931(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
	if dat.flag == 1 then
		self.voted = true
		EventMgr.Instance:Fire(event_name.godswar_vote_success)
	end
end


function GodsWarManager:OnLevUpCheck()
	if self.status == GodsWarEumn.Step.Sign then
		local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
		local currentMinute = tonumber(os.date("%M", BaseUtils.BASE_TIME))
		if self.myData ~= nil and self.myData.tid == 0 and RoleManager.Instance.RoleData.lev >= 80 and currentHour > 5 and currentHour <= 16 then
			self:SetIcon(true, true)
		else
			-- MainUIManager.Instance:DelAtiveIcon(119)
			-- self:SetIcon()
		end
	end
end

function GodsWarManager:Send17932(season,zone)
	print("Send17932")
	print(season)
	print(zone)
	local data = {season_id = season, zone_id = zone}
	self:Send(17932, data)
end

function GodsWarManager:On17932(dat)
	BaseUtils.dump(dat, "On17932")
    local list = {}
	for i,v in ipairs(dat.team_list) do
		list[v.team_group_64] = v
	end
    local key = BaseUtils.Key(dat.season_id,dat.zone_id)
	self.hisElimintionTab[key] = list
	EventMgr.Instance:Fire(event_name.godswar_history_update)
end

function GodsWarManager:Send17933(isTrue)
	self.isSetTime = isTrue or false
	self:Send(17933,{season_id = 0})
end

function GodsWarManager:On17933(dat)
	self.godwarTimeData = dat.season_time
	table.sort(self.godwarTimeData,function(a,b)
               if a.state_code ~= b.state_code then
                    return a.state_code < b.state_code
                else
                    return false
                end
            end)
	--BaseUtils.dump(self.godwarTimeData,"self.godwarTimeData")
	self.godTimeNumber = dat.season_id
	self.OnUpdateTime:Fire()

	if self.isSetTime == true then
		if self.status == GodsWarEumn.Step.Audition1
			or self.status == GodsWarEumn.Step.Audition2
			or self.status == GodsWarEumn.Step.Audition3
			or self.status == GodsWarEumn.Step.Audition4
			or self.status == GodsWarEumn.Step.Audition5
			or self.status == GodsWarEumn.Step.Audition6
			or self.status == GodsWarEumn.Step.Audition7
			or self.status == GodsWarEumn.Step.Elimination32
			or self.status == GodsWarEumn.Step.Elimination16
			or self.status == GodsWarEumn.Step.Elimination8
			or self.status == GodsWarEumn.Step.Elimination4
			or self.status == GodsWarEumn.Step.Semifinal
			or self.status == GodsWarEumn.Step.Thirdfinal
			or self.status == GodsWarEumn.Step.Final
			then
			self:Send17918()
			self:Send17923()
			self:SetIcon()
		else
			local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
			if self.status == GodsWarEumn.Step.Sign then
				if self.myData ~= nil and self.myData.tid == 0 and RoleManager.Instance.RoleData.lev >= 80 and currentHour > 5 and currentHour <= 16 then
					self:SetIcon(true, true)
				else
					self:SetIcon()
				end
			elseif self.status == GodsWarEumn.Step.FinalOff then
				MainUIManager.Instance:DelAtiveIcon(119)
			else
				-- print("诸神之战当前阶段"..self.status)
				-- MainUIManager.Instance:DelAtiveIcon(119)
				self:SetIcon()
			end
		end
	end
end

function GodsWarManager:Send17934()
    -- print("发送协议17934===================================================================================================================================")

	self:Send(17934,{})
end

function GodsWarManager:On17934(data)
	    -- BaseUtils.dump(data,"接收协议17934=====================================================================================================================")

	self.godsWarJiFenAllData = data
end

function GodsWarManager:Send17935(data)
    -- print("发送协议17935===================================================================================================================================")
	self:Send(17935,data)
end

function GodsWarManager:On17935(data)
	-- BaseUtils.dump(data,"接收协议17936=====================================================================================================================")

	self.godsWarJiFenOtherData = data
	self.OnUpdateGodsWarOtherData:Fire()
end

function GodsWarManager:Send17936(isGetOther,myRid,myPlatform,myZone_id)
    -- print("发送协议17935===================================================================================================================================")
    self.otherData = {rid = myRid,platform = myPlatform,zone_id = myZone_id}
    self.isGetOthenr = false or isGetOther
	self:Send(17936,{})
end

function GodsWarManager:On17936(data)
	-- BaseUtils.dump(data,"接收协议17936=====================================================================================================================")

	self.godsWarJiFenData = data
	self.OnUpdateGodsWarData:Fire()
	if self.isGetOthenr == true then
		self.isGetOthenr = false
		self:Send17935(self.otherData)
	end

end


function GodsWarManager:Send17937(myType,myGroup,isChange)
	self.myType = myType,myGroup
	self.myGroup = myGroup
	self.isChange = isChange or false
    -- print("发送协议17937===================================================================================================================================")
	self:Send(17937,{type = myType,group = myGroup})
end

function GodsWarManager:On17937(data)
	-- BaseUtils.dump(data,"接收协议17937=====================================================================================================================")

	if data.type == self.myType and data.group == self.myGroup then
		self.OnUpdateGodsWarRankData:Fire(data.rank,self.isChange)
	end

end

--观战or查看诸神挑战录像
function GodsWarManager:Send17959(id)
	CombatManager.Instance.currRecData = {type = 13, rec_id = id, platform = "", zone_id = 0}
	self:Send(17959, {id = id})
end

function GodsWarManager:On17959(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function GodsWarManager:On17962(dat)
	BaseUtils.dump(dat, "On17962")
	if dat.status ==1 then
		local qdata = {
			title = TI18N("诸神竞猜")
			, answerTitle = TI18N("请选择")
			, question = string.format(TI18N("<color='#00ff00'>%s队伍</color>正在向诸神发起挑战，你认为他们能成功完成挑战吗？"), dat.team_name)
			, callBack = function(index)
				self:Send17963(index - 1)
			end
			, answer = { TI18N("能"), TI18N("不能"), TI18N("不知道")}
		}

		CombatManager.Instance.WatchLogmodel:OpenQuestionPanel(qdata)
	end
end

function GodsWarManager:Send17963(choice)
	self:Send(17963, {choice = choice})
end

function GodsWarManager:On17963(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function GodsWarManager:On17964(dat)
	BaseUtils.dump(dat, "On17964")
	CombatManager.Instance.voteData = dat
	CombatManager.Instance.voteData.totla_num = dat.support_num + dat.unsupport_num + dat.unknow_num
	EventMgr.Instance:Fire(event_name.combat_watch_vote)
end

function GodsWarManager:Send17966()
	  print("发送17966")
	  self:Send(17966, {})
end

function GodsWarManager:On17966(dat)
	  --BaseUtils.dump(dat,"on17966")
		self.model.countDownTime = dat.start_time
		local intervalTime = dat.start_time - BaseUtils.BASE_TIME
		--print(intervalTime.."intervalTime")
		if CombatManager.Instance.isFighting == true and (CombatManager.Instance.combatType == 110 or CombatManager.Instance.combatType == 111) and CombatManager.Instance.isWatching == false and CombatManager.Instance.isWatchRecorder == false and intervalTime > 0 and intervalTime <= 15 * 60 then
			  LuaTimer.Add(2000,function() self.model:OpenTopPanel() end)
		end
end

function GodsWarManager:On17967(dat)
	-- BaseUtils.dump(dat,"on17967")
	self.settlementData = {}
	for _, v in ipairs(dat.champion_teams) do
		self.settlementData[v.match_group] = v
	end
	self.model:OpenSettlement()
	EventMgr.Instance:Fire(event_name.godswar_match_update)
end
