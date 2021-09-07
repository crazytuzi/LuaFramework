ClassesChallengeModel = ClassesChallengeModel or BaseClass(BaseModel)

function ClassesChallengeModel:__init()
    self.window = nil

    self.status = 0
    self.timestamp = 0
    self.id = 0
    self.round = 0
    self.time_span = 0
    self.done_list = {}
    self.rewarded = {}

    self.star = 0
	self.time_span = 0
	self.rank = 0
	self.gains = {}

	self.rank_list = {}

    self.quest_track = false
    self.questteam_loaded = false

    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, function() self.questteam_loaded = true self:UpdataQuest() end)
end

function ClassesChallengeModel:__delete()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function ClassesChallengeModel:InitMainUI()
    if self.window == nil then
        self.window = ClassesChallengeMyScoreWindow.New(self)
    end
    self.window:Open()
end

function ClassesChallengeModel:CloseMainUI()
    if self.window ~= nil then
        WindowManager.Instance:CloseWindow(self.window)
    end
end

function ClassesChallengeModel:On14800(data)
    self.status = data.status
    self.timestamp = data.timeout + Time.time

    local cfg_data = DataSystem.data_daily_icon[105]
    if self.status == 1 then
		local iconData = AtiveIconData.New()
		iconData.id = cfg_data.id
		iconData.iconPath = cfg_data.res_name
		iconData.text = TI18N("报名中")
		iconData.clickCallBack = function()
			self:ClassesCheckIn()
		end
		iconData.sort = cfg_data.sort
		iconData.lev = cfg_data.lev
		MainUIManager.Instance:AddAtiveIcon(iconData)
	elseif self.status == 2 then
		local iconData = AtiveIconData.New()
		iconData.id = cfg_data.id
		iconData.iconPath = cfg_data.res_name
		iconData.clickCallBack = function()
			self:ClassesCheckIn()
		end
		iconData.sort = cfg_data.sort
		iconData.lev = cfg_data.lev
		iconData.timestamp = self.timestamp
		iconData.timeoutCallBack = timeout_callback
		iconData.timeoutCallBack = function()
			MainUIManager.Instance:DelAtiveIcon(105)
		end
		MainUIManager.Instance:AddAtiveIcon(iconData)
        if RoleManager.Instance.RoleData.lev >= cfg_data.lev then
    		local data = NoticeConfirmData.New()
    		data.type = ConfirmData.Style.Normal
    		data.content = TI18N("<color='#ffff00'>职业挑战</color>活动正在进行中，是否前往参加？")
    		data.sureLabel = TI18N("确认")
    		data.cancelLabel = TI18N("取消")
    		data.cancelSecond = 30
    		data.sureCallback = function() self:Go() end

            if RoleManager.Instance.RoleData.cross_type == 1 then
                -- 如果处在中央服，先回到本服在参加活动
                RoleManager.Instance.jump_over_call = function() self:Go() end
                data.sureCallback = SceneManager.Instance.quitCenter
                data.content = TI18N("<color='#ffff00'>职业挑战</color>活动正在进行中，是否<color='#ffff00'>返回原服</color>参加？")
            end

    		NoticeManager.Instance:ActiveConfirmTips(data)
        end
    else
    	MainUIManager.Instance:DelAtiveIcon(105)
    end

	AgendaManager.Instance:SetCurrLimitID(2005, data.status == 1 or data.status == 2)
    -- BaseUtils.dump(data, "On14800")
end

function ClassesChallengeModel:On14802(data)
    self.id = data.id
    self.round = data.round
    self.time_span = data.time_span
    self.done_list = data.done_list
    self.rewarded = data.rewarded

    self:UpdataQuest()
end

function ClassesChallengeModel:On14804(data)
	self.star = data.star
 	self.time_span = data.time_span
 	-- self.rank = data.rank
	self.gains = data.gains
-- BaseUtils.dump(self.gains, "On14804")
    self:ShowReward()
end

function ClassesChallengeModel:On14805(data)
	self.rank_list = data.rank
	self.time_span = data.my_time_span
	self.rank = data.my_rank
-- BaseUtils.dump(self.rank_list, "On14805")
	if #self.rank_list > 0 then
		self:ShowRank()
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("排名正在统计中，请稍后再查看"))
		-- ClassesChallengeManager.Instance:Send14804()
	end
end

function ClassesChallengeModel:CreatQuest()
    if self.quest_track then
        return
    end
    self.quest_track = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
    BaseUtils.dump(self.quest_track, "<color=#00FF00>=================1</color>")
    self.quest_track.callback = function ()
            self:Go()
        end

    self:UpdataQuest()
end

function ClassesChallengeModel:DeleteQuest()
    if self.quest_track then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.quest_track.customId)
        self.quest_track = nil
    end
end

function ClassesChallengeModel:UpdataQuest()
    if not self.questteam_loaded then return end
    if self.id ~= 0 then
        if self.quest_track then
        	local index = #self.done_list
            local data = DataClassesChallenge.data_data[self.id]
            local unit_data = DataUnit.data_unit[data.unit_id]
            if data == nil then
                self:DeleteQuest()
            else
				self.quest_track.title = string.format(TI18N("<color='#61e261'>[活动]职业挑战<color='#ff0000'>(%s/10)</color></color>"), index)
				self.quest_track.Desc = string.format(TI18N("击败 <color='#00ff00'>%s</color>"), unit_data.name)
				self.quest_track.fight = true
                self.quest_track.type = CustomTraceEunm.Type.Activity

                MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.quest_track)
				self:Go()
            end
        else
            self:CreatQuest()
        end
    else
        self:DeleteQuest()
    end
end

function ClassesChallengeModel:Clear()
    self.id = 0
    self.quest_track = nil
end

function ClassesChallengeModel:Go()
	if self.status == 0 then
		local data = DataClassesChallenge.data_data[99]
		SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
		local uniqueid = BaseUtils.get_unique_npcid(data.unit_id, 9)
		local npcData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(uniqueid)
		if npcData == nil then
			SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, data.location[1][2], data.location[1][3], true)
		else
			SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, nil, nil, true)
		end
	else
		if self.id == 0 then
			local data = DataClassesChallenge.data_data[99]
			SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
			local uniqueid = BaseUtils.get_unique_npcid(data.unit_id, 9)
			local npcData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(uniqueid)
			if npcData == nil then
				SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, data.location[1][2], data.location[1][3], true)
			else
				SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, nil, nil, true)
			end
		else
			local data = DataClassesChallenge.data_data[self.id]
			SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
			local uniqueid = BaseUtils.get_unique_npcid(data.unit_id, 9)
			local npcData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneNpc(uniqueid)
			if npcData == nil then
				SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, data.location[1][2], data.location[1][3], true)
			else
				SceneManager.Instance.sceneElementsModel:Self_AutoPath(data.location[1][1], uniqueid, nil, nil, true)
			end
		end
	end
end

function ClassesChallengeModel:ShowReward()
	local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(self.time_span)
	my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
	my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
	local time_str = string.format("<color='#8DE92A'>%s%s%s%s</color>", my_minute, TI18N("分"), my_second, TI18N("秒"))
	if my_hour ~= nil and my_hour > 0 then
		-- my_hour = my_hour >= 10 and tostring(my_hour) or string.format("0%s", my_hour)
		time_str = string.format("<color='#8DE92A'>%s%s%s%s%s%s</color>", my_hourm, TI18N("小时"), my_minute, TI18N("分"), my_second, TI18N("秒"))
	end
	FinishCountManager.Instance.model.reward_win_data = {
	                    titleTop = TI18N("职业挑战")
	                    -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
	                    , val1 = string.format(TI18N("难度星数：<color='#8DE92A'>%s★</color>  用时：%s"), self.star, time_str)
	                    , val2 = TI18N("挑战成功")
	                    , title = TI18N("职业挑战奖励")
	                    , confirm_str = TI18N("查看排名")
	                    , share_str = TI18N("回到主城")
	                    , reward_list = self.gains
	                    , confirm_callback = function() ClassesChallengeManager.Instance:Send14805() end
	                    , share_callback = function()
	                    		if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
	                    			NoticeManager.Instance:FloatTipsByString(TI18N("只有队长才能回城"))
	                    		else
		                    		SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath_AndTopEffect()
		                    		SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
		                    	end
	                    	end
	                }
	FinishCountManager.Instance.model:InitRewardWin_Common()
end

function ClassesChallengeModel:ShowRank()
	self:InitMainUI()
end

function ClassesChallengeModel:ClassesCheckIn()
    if RoleManager.Instance.RoleData.cross_type == 1 then
        -- 如果处在中央服，先回到本服在参加活动
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureSecond = -1
        confirmData.cancelSecond = 180
        confirmData.sureLabel = TI18N("确认")
        confirmData.cancelLabel = TI18N("取消")
        RoleManager.Instance.jump_over_call = function() self:Go() end
        confirmData.sureCallback = SceneManager.Instance.quitCenter
        confirmData.content = TI18N("<color='#ffff00'>职业挑战</color>活动已开启，是否<color='#ffff00'>返回原服</color>参加？")
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        self:Go()
    end
end

function ClassesChallengeModel:OpenChiefChallengeWindow(args)
    if self.chiefchallengewindow == nil then
        self.chiefchallengewindow = ChiefChallengeWindow.New(self)
    end
    self.chiefchallengewindow:Open(args)
end


