FishingView = FishingView or BaseClass(BaseRender)

local WatchFishPosList = {
	[1] = {x = 397, y = -245},
	[2] = {x = 515, y = -194},
}

function FishingView:__init()
	self.enter_time = 0
	self.create_cd = 0.5
	self.is_play_reward_effect = false

	self.normal_fish_list = {}
	self.protect_fish_list = {}
	self.watch_fish_list = {}
	self.bullet_list = {}

	self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))

	--绑定组件
	self.pillar = self:FindObj("Pillar")
	self.fish_range_content = self:FindObj("FishRangeContent")
	self.click_range = self:FindObj("ClickRange")								-- 发射子弹点击区域
	self.bullet_start_pos = self:FindObj("BulletStartPos")						-- 子弹起始位置
	self.bullet_range = self:FindObj("BulletRange")								-- 界面范围

	--绑定变量
	self.title_des = self:FindVariable("TitleDes")								-- 鱼塘标题
	self.left_fish_times = self:FindVariable("LeftFishTimes")					-- 剩余养鱼次数
	self.is_self = self:FindVariable("IsSelf")									-- 是否自己的鱼塘
	self.can_harvest = self:FindVariable("CanHarvest")							-- 是否可收获
	self.bullet_num = self:FindVariable("BulletNum")							-- 子弹数量
	self.enter_des = self:FindVariable("EnterDes")
	self.is_show = self:FindVariable("is_show")

	self.paotai_animator = self.pillar.animator

	self.enter_animator = self.root_node:GetComponent(typeof(UnityEngine.Animator))

	self.bullet_delete_call_back = BindTool.Bind(self.BulletDeleteCallBack, self)
	self.touch_call_back = BindTool.Bind(self.TouchCallBack, self)

	self:ListenEvent("FireBullet", BindTool.Bind(self.FireBullet, self))
	self:ListenEvent("ClickFishRecord", BindTool.Bind(self.ClickFishRecord, self))
	self:ListenEvent("OpenFishPondList", BindTool.Bind(self.OpenFishPondList, self))
	self:ListenEvent("ClickAddBullet", BindTool.Bind(self.ClickAddBullet, self))
	self:ListenEvent("ClickFarmFish", BindTool.Bind(self.ClickFarmFish, self))
	self:ListenEvent("ClickAddFishTimes", BindTool.Bind(self.ClickAddFishTimes, self))
	self:ListenEvent("OpenTips", BindTool.Bind(self.OpenTips, self))
	self:ListenEvent("OnClickQuick",BindTool.Bind1(self.OnClickQuick, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	self.red_point_list = {
		[RemindName.Fishing_CanGet] = self:FindVariable("FarmFishRemind"),
		[RemindName.Fishing_BeSteal] = self:FindVariable("BeStealRemind"),
		[RemindName.Fishing_CanSteal] = self:FindVariable("GetFishRemind"),
	}

	for k in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function FishingView:__delete()
	self:ClearFish()
	self:ClearCountDown()
	self:RemoveDelayTime()

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function FishingView:ClearFish()
	for _, v in ipairs(self.normal_fish_list) do
		v:DeleteMe()
	end
	self.normal_fish_list = {}

	for _, v in ipairs(self.protect_fish_list) do
		v:DeleteMe()
	end
	self.protect_fish_list = {}

	for _, v in ipairs(self.watch_fish_list) do
		v:DeleteMe()
	end
	self.watch_fish_list = {}
end

function FishingView:InitView()
	self.is_self:SetValue(true)
	FishingData.Instance:SetNowFishPondUid(GameVoManager.Instance:GetMainRoleVo().role_id)
	FishingData.Instance:SetNowFishList(FishingData.Instance:GetMyFishList())
	self:StartCreateFish()
	self:FlushTitleDes()
	self:FlushInfo()
end

function FishingView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

--界面关闭时调用
function FishingView:CloseCallBack()
	for k, v in pairs(self.bullet_list) do
		v:DeleteMe()
	end
	self.bullet_list = {}
	self:ClearFish()
	self:ClearCountDown()
	self:RemoveDelayTime()
	if self.is_play_reward_effect then
		self:ShowRewardView()
	end
end

--刷新信息界面
function FishingView:FlushInfo()
	self:FlushBulletNum()
	self:FlushFarmFishTimes()

	local  level  = PlayerData.Instance:GetRoleVo().level
	local min_level = FishingData.Instance:GetSkipCfgByType(0).limit_level

	local farm_fish_times = FishingData.Instance:GetFarmFishTimes()
	local bullet_num = FishingData.Instance:GetLeftBulletNum()
	if level >= min_level and (farm_fish_times > 0 or bullet_num > 0) then
		self.is_show:SetValue(true)
	else
		self.is_show:SetValue(false)
	end
end

--刷新自己的鱼
function FishingView:FlushFish()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list then
		return
	end
	if #self.normal_fish_list <= 0 then
		--创建普通鱼
		local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_list.fish_quality)
		if nil == fish_info then
			return
		end
		for i = 1, fish_list.fish_num do
			local fish = Fish.New(fish_info, false)

			fish:SetParent(self.fish_range_content)
			table.insert(self.normal_fish_list, fish)
		end
	end

	if not self.is_play_reward_effect then
		self:CheckDeleteNormalFish()
	end
	FishingData.Instance:SetNowFishPondUid(GameVoManager.Instance:GetMainRoleVo().role_id)
	FishingData.Instance:SetNowFishList(FishingData.Instance:GetMyFishList())
	self:FlushTitleDes()
end

--删除自己的鱼
function FishingView:CheckDeleteNormalFish()
	local fish_list = FishingData.Instance:GetMyFishList()
	if nil == fish_list then
		return
	end
	local now_count = #self.normal_fish_list
	local diff_count = now_count - fish_list.fish_num
	if diff_count > 0 then
		--清除掉多余的鱼
		for i = now_count, fish_list.fish_num + 1, -1 do
			self.normal_fish_list[i]:DeleteMe()
			table.remove(self.normal_fish_list, i)
		end
	end
end

--刷新子弹数量
function FishingView:FlushBulletNum()
	local bullet_num = FishingData.Instance:GetLeftBulletNum()
	self.bullet_num:SetValue(bullet_num)
end

--刷新养鱼次数
function FishingView:FlushFarmFishTimes()
	local farm_fish_times = FishingData.Instance:GetFarmFishTimes()
	self.left_fish_times:SetValue(farm_fish_times)
end

--刷新鱼塘标题
function FishingView:FlushTitleDes()
	self:ClearCountDown()
	--获取当前鱼塘的归属者
	local uid = FishingData.Instance:GetNowFishPondUid()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local fish_list = FishingData.Instance:GetNowFishList()
	if nil == fish_list then
		return
	end
	if main_vo.role_id == uid then
		--是自己的鱼塘
		local normal_des = string.format(Language.Fishpond.FishPondTitleDes, main_vo.name)
		local fang_fish_time = fish_list.fang_fish_time
		if fang_fish_time <= 0 then
			--没有放鱼
			self.title_des:SetValue(normal_des)
			self.can_harvest:SetValue(false)
			return
		end
		local server_times = TimeCtrl.Instance:GetServerTime()
		local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_list.fish_quality)
		if nil == fish_info then
			self.title_des:SetValue(normal_des)
			return
		end
		local need_times = fish_info.need_time
		local left_time = need_times - (server_times - fang_fish_time)
		if left_time <= 0 then
			--可收获了
			self.title_des:SetValue(normal_des)
			self.can_harvest:SetValue(true)
		else
			local function time_func(elapse_time, total_time)
				if elapse_time >= total_time then
					self:ClearCountDown()
					--可收获了
					self.title_des:SetValue(normal_des)
					self.can_harvest:SetValue(true)
					return
				end
				local times = math.floor(total_time - elapse_time)
				local time_str = TimeUtil.FormatSecond(times)
				local des = string.format(Language.Fishpond.GetFishTimeDes, time_str)
				self.title_des:SetValue(des)
			end
			self.count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)
			local time_str = TimeUtil.FormatSecond(left_time)
			local des = string.format(Language.Fishpond.GetFishTimeDes, time_str)
			self.title_des:SetValue(des)
			self.can_harvest:SetValue(false)
		end
	else
		self.title_des:SetValue(string.format(Language.Fishpond.FishPondTitleDes, fish_list.owner_name))
	end
end

function FishingView:FishNumChange(is_succ)
	self:CheckDeleteFish(is_succ)
end

--重新刷新界面
function FishingView:RefreshView(is_enter_other)
	if is_enter_other then
		if self.is_play_reward_effect then
			self:RemoveDelayTime()
			self:ShowRewardView()
		end
		local fish_list = FishingData.Instance:GetNowFishList()
		if nil ~= fish_list then
			self.enter_des:SetValue(fish_list.owner_name)
			if self.enter_animator then
				self.enter_animator:SetTrigger("enter")
			end
		end
	end
	self.is_self:SetValue(false)
	self:StartCreateFish()
	self:FlushTitleDes()
end

function FishingView:ClearCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FishingView:StartCreateFish()
	if Status.NowTime - self.enter_time < self.create_cd then
		return
	end
	self.enter_time = Status.NowTime

	--先清除掉所有鱼
	self:ClearFish()
	FishingData.Instance:ClearWaitDeleteList()

	--加装饰鱼
	for i = 1, 2 do
		for j = 1, 2 do
			local data = {quality = i + 4}
			local fish = Fish.New(data, false)
			fish:SetParent(self.fish_range_content)
			table.insert(self.watch_fish_list, fish)
		end
	end

	for i = 1, 2 do
		local data = {quality = 7}
		local fish = Fish.New(data, false)
		fish:SetParent(self.fish_range_content)
		fish:SetPosition(WatchFishPosList[i])
		fish:SetDelfaultSpeed(0)
		table.insert(self.watch_fish_list, fish)
	end

	local fish_list = FishingData.Instance:GetNowFishList()
	if nil == fish_list then
		return
	end

	local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_list.fish_quality)
	if nil == fish_info then
		return
	end
	--加普通鱼
	for i = 1, fish_list.fish_num do
		local fish = Fish.New(fish_info, false)

		fish:SetParent(self.fish_range_content)
		table.insert(self.normal_fish_list, fish)
	end

	--加守卫鱼
	local protectfish_num = FishingData.Instance:GetProtectFishNum()
	for i = 1, protectfish_num do
		local fish = Fish.New(fish_info, true)

		fish:SetParent(self.fish_range_content)
		table.insert(self.protect_fish_list, fish)
	end
end

function FishingView:FireBullet()
	--判断该玩家是否可以继续捕获
	local fish_list = FishingData.Instance:GetNowFishList()
	if nil == fish_list then
		print_error("fish_list is nil!!!!!!!!!!!!!!!!")
		return
	end

	local rect = self.click_range.rect
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, UnityEngine.Input.mousePosition, self.uicamera, Vector2(0, 0))
	local abs_x = math.abs(local_pos_tbl.x)
	local abs_y = math.abs(local_pos_tbl.y)
	local angle = math.deg(math.atan2(abs_x, abs_y))
	if local_pos_tbl.x > 0 then
		angle = -angle
	end
	local rotation = Quaternion.Euler(0, 0, angle)
	self.pillar.rect.localRotation = rotation

	--是自己的鱼塘无法捕获
	if fish_list.owner_uid == GameVoManager.Instance:GetMainRoleVo().role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotGetSelfFish)
		return
	end

	local fish_quality = fish_list.fish_quality
	local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_quality)
	if nil == fish_info then
		print_error("fish_info is nil!!!!!!!!!!!!!!!!")
		return
	end
	if #self.normal_fish_list <= fish_info.steal_limit then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotEnoughFishDes)
		return
	end

	--判断是否有足够子弹
	-- local bullet_test_count = self.bullet_num:GetInteger()
	local bullet_num = FishingData.Instance:GetLeftBulletNum()
	if bullet_num <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotBulletNum)
		return
	end

	--播放炮台发射动画
	if self.paotai_animator then
		self.paotai_animator:SetTrigger("scale")
	end

	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.bullet_start_pos.rect.position)

	--转换屏幕坐标为本地坐标
	rect = self.bullet_range.rect
	local _, local_bullet_start_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	--开始发射子弹
	local bullet = Bullet.New()
	bullet:SetParent(self.bullet_range.transform)
	bullet:SetRange(self.bullet_range.rect.sizeDelta.x/2, self.bullet_range.rect.sizeDelta.y)
	bullet:SetStartPosTbl(local_bullet_start_pos_tbl)
	bullet:SetLocalRotation(rotation)
	bullet:SetDeleteCallBack(self.bullet_delete_call_back)
	bullet:SetTouchCallBack(self.touch_call_back)
	for _, v in ipairs(self.protect_fish_list) do
		local bind_func = BindTool.Bind(v.BulletPositionChange, v)
		bullet:AddPositionChangeListen(bind_func)
	end
	bullet:CreateBulletObj()
	self.bullet_list[bullet] = bullet
end

function FishingView:BulletDeleteCallBack(bullet)
	if self.bullet_list[bullet] then
		self.bullet_list[bullet]:DeleteMe()
		self.bullet_list[bullet] = nil
	end
end

function FishingView:TouchCallBack(bullet, obj)
	--判断是否打到了守卫鱼
	for _, v in ipairs(self.protect_fish_list) do
		if v:GetObj() == obj then
			--创建特效
			local position = bullet:GetPosition()
			EffectManager.Instance:PlayAtTransform("effects2/prefab/ui_x/ui_buyuzidan_sj_prefab", "UI_buyuzidan_sj", self.bullet_range.transform, 2, position)

			--删除子弹
			self.bullet_list[bullet]:DeleteMe()
			self.bullet_list[bullet] = nil

			--发送偷鱼的协议
			local uid = FishingData.Instance:GetNowFishPondUid()
			local now_fish_list = FishingData.Instance:GetNowFishList()
			if nil == now_fish_list then
				print_error("now_fish_list is nil!!!!!!!!!!!!!!!!")
				return
			end
			YuLeCtrl.Instance:SendFishPoolStealFish(uid, now_fish_list.is_fake_pool, now_fish_list.fish_quality, FISH_TYPE.PROTECT_FISH)

			SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.ProtectFishNotFarm)
			return
		end
	end

	for k, v in ipairs(self.normal_fish_list) do
		if v:GetObj() == obj then
			--鱼已经死亡
			if v:IsDead() then
				return
			end

			--创建特效
			local position = bullet:GetPosition()
			EffectManager.Instance:PlayAtTransform("effects2/prefab/ui_x/ui_buyuzidan_sj_prefab", "UI_buyuzidan_sj", self.bullet_range.transform, 2, position)

			--删除子弹
			self.bullet_list[bullet]:DeleteMe()
			self.bullet_list[bullet] = nil

			local wait_delete_list = FishingData.Instance:GetWaitDeleteList()
			if nil ~= wait_delete_list then
				for _, v2 in ipairs(wait_delete_list) do
					if v2 == v then
						--短时间内打中相同的鱼不处理
						return
					end
				end
			end

			--记录打中的鱼
			FishingData.Instance:AddWaitDeleteList(v)

			--发送偷鱼的协议
			local uid = FishingData.Instance:GetNowFishPondUid()
			local now_fish_list = FishingData.Instance:GetNowFishList()
			if nil == now_fish_list then
				print_error("now_fish_list is nil!!!!!!!!!!!!!!!!")
				return
			end
			YuLeCtrl.Instance:SendFishPoolStealFish(uid, now_fish_list.is_fake_pool, now_fish_list.fish_quality, FISH_TYPE.NORMAL_FISH)
			return
		end
	end
end

--判断是否删除鱼
function FishingView:CheckDeleteFish(is_succ)
	local wait_delete_list = FishingData.Instance:GetWaitDeleteList()
	if nil == wait_delete_list then
		return
	end
	local last_index = #wait_delete_list
	if last_index == 0 then
		return
	end

	local fish = wait_delete_list[last_index]
	if not fish:IsDead() then
		if is_succ then
			--开始播放被捕效果（包括释放）
			fish:PlayToBeTake()
			for k, v in ipairs(self.normal_fish_list) do
				if fish:GetObj() == v:GetObj() then
					table.remove(self.normal_fish_list, k)
					break
				end
			end
		else
			fish:SetDelfaultSpeed(2)
			fish:SetIsRun(true)
		end
	end

	wait_delete_list[last_index] = nil
end

--点击了养鱼记录
function FishingView:ClickFishRecord()
	YuLeCtrl.Instance:SendFishPoolQueryReq(FISH_POOL_QUERY_TYPE.FISH_POOL_QUERY_TYPE_STEAL_GENERAL_INFO)
	ViewManager.Instance:Open(ViewName.BeStealRecordView)
end

-- 打开鱼池列表
function FishingView:OpenFishPondList()
	ClickOnceRemindList[RemindName.Fishing_CanSteal] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.Fishing_CanSteal)
	YuLeCtrl.Instance:SendFishPoolQueryReq(FISH_POOL_QUERY_TYPE.FISH_POOL_QUERY_TYPE_WORLD_GENERAL_INFO)
end

--点击了增加子弹
function FishingView:ClickAddBullet()
	if not FishingData.Instance:CanBuyBulletTimes() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotTimesBuyBullet)
		return
	end

	local other_cfg = FishingData.Instance:GetOtherCfg()
	if nil == other_cfg then
		return
	end
	local bullet_buy_times = FishingData.Instance:GetTodayBulletBuyTimes()
	local gold = FishingData.Instance:GetGoldByBuyBulletTimes(bullet_buy_times + 1)
	local give_bullet_per_buy = other_cfg.give_bullet_per_buy				--一次购买子弹的数量
	local des = string.format(Language.Fishpond.BuyBulletNumDes, gold, give_bullet_per_buy)

	local function ok_callback()
		YuLeCtrl.Instance:SendFishPoolBuyBulletReq()
	end
	TipsCtrl.Instance:ShowCommonAutoView("bullt_num", des, ok_callback)
end

--点击了养鱼(返回)
function FishingView:ClickFarmFish()
	local uid = FishingData.Instance:GetNowFishPondUid()
	if uid == GameVoManager.Instance:GetMainRoleVo().role_id then
		local fish_list = FishingData.Instance:GetNowFishList()
		if nil == fish_list then
			return
		end
		local fang_fish_time = fish_list.fang_fish_time
		if fang_fish_time > 0 then
			local server_times = TimeCtrl.Instance:GetServerTime()
			local fish_info = FishingData.Instance:GetFishInfoByQuality(fish_list.fish_quality)
			if nil == fish_info then
				return
			end
			local need_times = fish_info.need_time
			local left_time = need_times - (server_times - fang_fish_time)
			if left_time <= 0 then
				--可收获
				self.is_play_reward_effect = true
				YuLeCtrl.Instance:SendFishPoolHarvest()
			else
				ViewManager.Instance:Open(ViewName.YangFishView)
			end
		else
			ViewManager.Instance:Open(ViewName.YangFishView)
		end
	else
		FishingData.Instance:SetNowFishPondUid(GameVoManager.Instance:GetMainRoleVo().role_id)
		FishingData.Instance:SetNowFishList(FishingData.Instance:GetMyFishList())
		self.is_self:SetValue(true)
		self:StartCreateFish()
		self:FlushTitleDes()
	end
end

function FishingView:OpenTips()
	TipsCtrl.Instance:ShowHelpTipView(193)
end

--点击了增加养鱼次数
function FishingView:ClickAddFishTimes()
	if not FishingData.Instance:CanBuyFarmFishTimes() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishpond.NotTimesBuyFarmFish)
		return
	end
	local today_buy_fang_fish_tims = FishingData.Instance:GetTodayFarmFishBuyTimes()
	local gold = FishingData.Instance:GetGoldByBuyFangFishTimes(today_buy_fang_fish_tims + 1)
	local des = string.format(Language.Fishpond.BuyFarmFishTimesDes, gold)

	local function ok_callback()
		YuLeCtrl.Instance:SendFishPoolQueryReq(FISH_POOL_QUERY_TYPE.FISH_POOL_BUY_FANG_FISH_TIMES)
	end
	TipsCtrl.Instance:ShowCommonAutoView("fish_count", des, ok_callback)
end

function FishingView:OnClickQuick()
	TipsCtrl.Instance:ShowQuickCompletionView("", false, nil, nil,nil,false,SKIP_TYPE.SKIP_TYPE_FISH,nil,nil)
end

-- 播放收获特效
function FishingView:PlayRewardEffect()
	self.is_play_reward_effect = true
	for k,v in pairs(self.normal_fish_list) do
		local position = v:GetPosition()
		EffectManager.Instance:PlayAtTransform("effects2/prefab/ui_x/ui_buyuzidan_sj_prefab", "UI_buyuzidan_sj", self.bullet_range.transform, 2, position)
		v:PlayToBeTake()
	end
	self.normal_fish_list = {}
	self:RemoveDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:ShowRewardView() end, 1)
end

function FishingView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function FishingView:ShowRewardView()
	self.is_play_reward_effect = false
	ViewManager.Instance:Open(ViewName.HarvestRecordView)
end