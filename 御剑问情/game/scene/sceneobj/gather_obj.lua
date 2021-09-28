SPECIAL_GATHER_TYPE =
{
	JINGHUA = 1,				-- 精华采集
	GUILDBATTLE = 2,			-- 公会争霸采集物
	FUN_OPEN_MOUNT = 3, 		-- 功能开启副本-坐骑
	FUN_OPEN_WING = 4,			-- 功能开启副本-羽翼
	GUILD_BONFIRE = 5,			-- 仙盟篝火

	CROSS_FISHING = 6,			-- 钓鱼鱼篓
	KUAFU_MINING = 7, 			-- 跨服挖矿采集物
	BOSS_TOMBSTONE = 9, 		-- boss墓碑
}

GatherObj = GatherObj or BaseClass(SceneObj)

function GatherObj:__init(item_vo)
	self.obj_type = SceneObjType.GatherObj
	self.draw_obj:SetObjType(self.obj_type)
	self:SetObjId(item_vo.obj_id)
	self.rotation_y = 0
end

function GatherObj:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self:CancelHotDelayTime()

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
   	end
end

function GatherObj:InitInfo()
	SceneObj.InitInfo(self)

	local gather_config = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[self.vo.gather_id]
	if nil == gather_config then
		print_log("gather_config not find, gather_id:" .. self.vo.gather_id)
		return
	end
	self.vo.name = gather_config.show_name
	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		self.vo.name = string.format(Language.Guild.GuildGoddessName, self.vo.param2)
	elseif self.vo.special_gather_type == SPECIAL_GATHER_TYPE.CROSS_FISHING then
		self.vo.name = self.vo.param2 .. "·" .. self.vo.name
	end
	self.resid = gather_config.resid
	self.scale = gather_config.scale
	self.rotation_y = gather_config.rotation or 0
end

function GatherObj:InitShow()
	SceneObj.InitShow(self)
	if SpiritData.Instance:GetIsSpiritGather(self.vo.gather_id) then  -- 精灵采集物显示名称
		local name = self.vo.name or ""
		if SpiritData.Instance:GetSpiritType(self.vo.gather_id) == SPIRIT_QUALITY.PURPLE then
			name = "<color=#f12fea>".. self.vo.name .. "</color>"
		end
		self:GetFollowUi():SetName(name)
		self.rotation_y = DownAngleOfCamera
		self:GetFollowUi():SetSpecialImage(true, "uis/images_atlas", "arrow_gather")
	end

	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.JINGHUA
		and self.vo.gather_id == JingHuaHuSongData.Instance:GetGatherId(JingHuaHuSongData.JingHuaType.Big) then		--如果是天地精华采集物(大灵石)
		local name = string.format(Language.JingHuaHuSong.JingHuaName, self.vo.param)
		JingHuaHuSongData.Instance:SetJingHuaGatherAmount(self.vo.gather_id, self.vo.param)
		MainUIData.Instance:SendJingHuaHuSongNum(self.vo.param)
		MainUIView.Instance:JingHuaHuSongNum()
		if FuBenCtrl.Instance then
			FuBenCtrl.Instance:SetJingHuaHuSongNum()
		end

		-- self.vo.param > 0 代表灵石还有剩余，不需要显示下一批灵石的刷新时间
		if self.vo.param > 0 then
			if self.least_time_timer then
	    		CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    		self.least_time_timer = nil
	   		end

			self:GetFollowUi():SetName(name)
		else
			if self.least_time_timer then
	        CountDown.Instance:RemoveCountDown(self.least_time_timer)
	        self.least_time_timer = nil
	   		end

	   		local next_time = self.vo.param1 or 0
	   		local server_time = TimeCtrl.Instance:GetServerTime()
			local rest_time = math.floor(next_time - server_time)

			-- rest_time > 0 代表需要刷新下一批灵石时间
			if rest_time > 0 then
				self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function (elapse_time, total_time)
					local left_time = total_time - elapse_time

					-- 刷新下一批灵石的倒计时开头
					if left_time <= 0 then
						left_time = 0
						if self.least_time_timer then
	    					CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    					self.least_time_timer = nil
	   					end
	   					self:GetFollowUi():SetName(name)
	   				else
						local time = JingHuaHuSongData:GetNextTime(left_time)
						local now_time = string.format(Language.JingHuaHuSong.NextFlushTime, time)
		           		self:GetFollowUi():SetName(name .. now_time)
	           		end
	           		-- 刷新下一批灵石的倒计时结尾

	        	end)
			else
				self:GetFollowUi():SetName(name)
			end
		end

		self:GetFollowUi():SetTextScale(1.6, 1.6)
		self:GetFollowUi():SetTextPosY(50)
	end

	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.JINGHUA
		and self.vo.gather_id == JingHuaHuSongData.Instance:GetGatherId(JingHuaHuSongData.JingHuaType.Small) then		--如果是天地精华采集物(小灵石)
		self:GetFollowUi():SetName(Language.JingHuaHuSong.SmallJingHuaName)
		self:GetFollowUi():SetTextScale(1.4, 1.4)
	end

	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		local res_id = GuildBonfireData:GetBonfireOtherCfg().gather_res
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(res_id))
		local transform = self.draw_obj:GetRoot().transform
		transform.localScale = Vector3(1.5, 1.5, 1.5)
	else
		--self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(2001))
		-- self:ChangeModel(SceneObjPart.Main, "actors/gather/6001", "6001001")	--没有其他美术资源
		self:ChangeModel(SceneObjPart.Main, ResPath.GetGatherModel(self.resid))
		if self.scale then
			local transform = self.draw_obj:GetRoot().transform
			transform.localScale = Vector3(self.scale, self.scale, self.scale)
		end
	end

	--如果是跨服挖矿采集物，且属于双倍矿石
	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.KUAFU_MINING
		and KuaFuMiningData.Instance:IsMiningDoubleGather(self.vo.gather_id) then
		local gather_name = string.format(Language.KuaFuFMining.DoubleGather, self.vo.name)
		self:GetFollowUi():Show()
		self:ChangeShowName(gather_name, 1.2, 150)
	end

	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.BOSS_TOMBSTONE then
		self:UpdateTombstone()
	end

	if Scene.SCENE_OBJ_ID_T[self.vo.obj_id] == nil and Scene.Instance:GetSceneType() == SceneType.HunYanFb
		and self.vo.gather_id == 338 then --婚宴的绣球
		local transform = self.draw_obj:GetRoot().transform
		local pos = transform.localPosition
		transform:SetLocalPosition(pos.x, 10, pos.z)
		transform:DOLocalMoveY(0, 3)
	end

	if self.rotation_y ~= 0 then
		self.draw_obj:Rotate(0, self.rotation_y, 0)
	end

	if Scene.Instance:GetSceneType() == SceneType.HotSpring then
		if HotStringChatData.Instance:IsHotSpringDuck(self.vo.gather_id) then
			self.draw_obj:Rotate(0, math.random(0, 360), 0)
		end
	end
end

function GatherObj:UpdateTombstone()
	local name = self.vo.name or ""
		if self.least_time_timer then
	        CountDown.Instance:RemoveCountDown(self.least_time_timer)
	        self.least_time_timer = nil
	   	end

   		local next_time = self.vo.param1 or 0
   		local server_time = TimeCtrl.Instance:GetServerTime()
		local rest_time = math.floor(next_time - server_time)

		if rest_time > 0 then
			self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function (elapse_time, total_time)
				local left_time = total_time - elapse_time

				-- 刷新下一批灵石的倒计时开头
				if left_time <= 0 then
					left_time = 0
					if self.least_time_timer then
    					CountDown.Instance:RemoveCountDown(self.least_time_timer)
    					self.least_time_timer = nil
   					end
   					self:GetFollowUi():SetName(name)
   				else
					local time = ""
					if left_time > 3600 then
						time = TimeUtil.FormatSecond(left_time, 3)
					else
						time = TimeUtil.FormatSecond(left_time, 2)
					end
					if self.vo.param == 1 then
					 	time = string.format(Language.Boss.NextFlushTime2, self.vo.param3 or 0, time)
					 else
					 	time = string.format(Language.Boss.NextFlushTime1, self.vo.param3 or 0, time)
					 end
	           		self:GetFollowUi():SetName(name .. time)
           		end
        	end)
		else
			self:GetFollowUi():SetName(name)
		end
end

function GatherObj:OnEnterScene()
	SceneObj.OnEnterScene(self)
	if self.vo and self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		self:GetFollowUi():Show()
		self.follow_ui.root_obj.transform.localScale = Vector3(1.5, 1.5, 1.5)
	end
	self:PlayAction()
	self:HotSpirngPlayAction()

	if SpiritData.Instance:GetIsSpiritGather(self.vo.gather_id) then  -- 精灵采集物
		GlobalTimerQuest:AddDelayTimer(function()
			self:GetFollowUi().special_image_obj:GetComponent(typeof(UnityEngine.Animator)):SetBool("IsPlay", true)
		end, 0.7)
	end

	if self.draw_obj then
		self.draw_obj:SetWaterHeight(COMMON_CONSTS.WATER_HEIGHT)
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			local flag = scene_logic:IsCanCheckWaterArea() and true or false
			self.draw_obj:SetCheckWater(flag)
		end
	end
end

function GatherObj:GetGatherId()
	return self.vo.gather_id
end

function GatherObj:IsGather()
	return true
end

function GatherObj:CancelSelect()
	if SceneObj.select_obj and SpiritData.Instance:GetIsSpiritGather(SceneObj.select_obj:GetVo().gather_id) then
		return
	end

	if SceneObj.select_obj and SceneObj.select_obj == self then
		SceneObj.select_obj = nil
	end
	self.is_select = false
	if self:CanHideFollowUi() and nil ~= self.follow_ui and not self:IsRole() and not self:IsEvent() then
		self:GetFollowUi():Hide()
	end

	if not self:IsMainRole() and Scene.Instance:GetSceneType() == SceneType.HotSpring then
		--温泉场景双修
		GlobalEventSystem:Fire(ObjectEventType.CLICK_SHUANGXIU, self, self.vo, "cancel")
	end
end

function GatherObj:CanHideFollowUi()
	return not self.is_select and (self.vo and self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE)
end

function GatherObj:PlayAction()
	if nil == self.vo or self.vo.special_gather_type ~= SPECIAL_GATHER_TYPE.GUILD_BONFIRE and not SpiritData.Instance:GetIsSpiritGather(self.vo.gather_id) then
		return
	end
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			if SpiritData.Instance:GetIsSpiritGather(self.vo.gather_id) then
				part:SetTrigger(ANIMATOR_PARAM.REST)
			else
				part:SetTrigger("Action")
			end
			self.time_quest = GlobalTimerQuest:AddDelayTimer(function() self:PlayAction() end, 10)
		end
	end
end

function GatherObj:HotSpirngPlayAction()
	if nil == self.vo or not HotStringChatData.Instance:IsHotSpringDuck(self.vo.gather_id) then
		return
	end
	local draw_obj = self:GetDrawObj()
	if draw_obj then
		local part = draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("Action")
			self:CancelHotDelayTime()
			self.hot_spring_time_quest = GlobalTimerQuest:AddDelayTimer(function() self:HotSpirngPlayAction() end, math.random(8, 13))
		end
	end
end

function GatherObj:ChangeShowName(name, size, y)
	size = size or 1.6
	y = y or 50
	self:GetFollowUi():SetName(name)
	self:GetFollowUi():SetTextScale(size, size)
	self:GetFollowUi():SetTextPosY(y)
end

function GatherObj:CancelHotDelayTime()
	if self.hot_spring_time_quest then
		GlobalTimerQuest:CancelQuest(self.hot_spring_time_quest)
		self.hot_spring_time_quest = nil
	end
end

function GatherObj:UpdateGuildBonFire()
	if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
		if nil ~= self:GetDrawObj():_TryGetPartObj(SceneObjPart.Main) then
			local times = GuildBonfireData.Instance:GetGuildBonfireMucaiTimes(self.vo.obj_id)
			local huo_yan = self:GetDrawObj():GetAttachPoint(AttachPoint.BuffBottom)
			if huo_yan then
				local scale = 1 + times / 10
				huo_yan.transform.localScale = Vector3(scale, scale, scale)
			end
		end
	end
end

function GatherObj:OnModelLoaded(part, obj)
	SceneObj.OnModelLoaded(self, part, obj)
	if part == SceneObjPart.Main then
		if self.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
			self:UpdateGuildBonFire()
		end
	end
end