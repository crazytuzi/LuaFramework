------------------------------------------------------------
--飞行粒子特效
------------------------------------------------------------
FlyEffectView = FlyEffectView or BaseClass(BaseView)

local interval = 0.05					-- 生成特效间隔
local EffectCount = 8					-- 特效个数
local Section = 20						-- 区间大小

function FlyEffectView:__init()
	self.ui_config = {"uis/views/tips/flyeffectview_prefab", "FlyEffectView"}
	self.view_layer = UiLayer.Pop

	self.effect_obj_list = {}

	self.tween_list = {}

	self.start_position = Vector3(0, 0, 0)
	self.end_position = Vector3(0, 0, 0)
	self.ease = DG.Tweening.Ease.Linear				--默认匀速运动
	self.duration = 1								--运行时间

	self.need_repeat = false						--重复回调
	self.effect_count = 0

	self.end_count = 0
end

function FlyEffectView:ReleaseCallBack()
	self.start_obj = nil
	self.end_obj = nil
	self.my_uicamera = nil
	self.my_rect = nil

	self.effect_count = 0

	if self.add_time_quest then
		GlobalTimerQuest:CancelQuest(self.add_time_quest)
		self.add_time_quest = nil
	end

	if self.fly_time_quest then
		GlobalTimerQuest:CancelQuest(self.fly_time_quest)
		self.fly_time_quest = nil
	end

	for _, v in ipairs(self.effect_obj_list) do
		GameObjectPool.Instance:Free(v)
	end
	self.effect_obj_list = {}

	for _, v in ipairs(self.tween_list) do
		v:Kill()
	end
	self.tween_list = {}

	if not self.need_repeat and self.complete_callback then
		self.complete_callback()
		self.complete_callback = nil
	end

	self.ease = nil
end

function FlyEffectView:SetAsset(bundle, asset)
	self.bundle = bundle
	self.asset = asset
end

function FlyEffectView:SetStartObj(obj)
	self.start_obj = obj
end

function FlyEffectView:SetEndObj(obj)
	self.end_obj = obj
end

function FlyEffectView:SetEffectCount(effect_count)
	self.effect_count = effect_count
end

function FlyEffectView:SetStartPosition()
	if nil == self.start_obj or IsNil(self.start_obj.gameObject) then
		return
	end
	local obj_rect = self.start_obj:GetComponent(typeof(UnityEngine.RectTransform))
	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.my_uicamera, obj_rect.position)

	--转换屏幕坐标为本地坐标
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.my_rect, screen_pos_tbl, self.my_uicamera, Vector2(0, 0))

	self.start_position = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
end

function FlyEffectView:SetEndPosition()
	if nil == self.end_obj or IsNil(self.end_obj.gameObject) then
		return
	end
	local obj_rect = self.end_obj:GetComponent(typeof(UnityEngine.RectTransform))
	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.my_uicamera, obj_rect.position)

	--转换屏幕坐标为本地坐标
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.my_rect, screen_pos_tbl, self.my_uicamera, Vector2(0, 0))

	self.end_position = Vector3(local_pos_tbl.x, local_pos_tbl.y, 0)
end

--设置速率曲线
function FlyEffectView:SetEase(ease)
	self.ease = ease
end

--花费时间
function FlyEffectView:SetDuration(duration)
	self.duration = duration
end

function FlyEffectView:SetCompleteCallBack(callback)
	self.complete_callback = callback
end

function FlyEffectView:SetNeedRepeat(need_repeat)
	self.need_repeat = need_repeat
end

function FlyEffectView:OnMoveEnd()
	self.end_count = self.end_count + 1
	if self.effect_obj_list[self.end_count] then
		GameObjectPool.Instance:Free(self.effect_obj_list[self.end_count])
		self.effect_obj_list[self.end_count] = nil
	end
	if self.need_repeat and self.complete_callback then
		self.complete_callback()
	end
	if self.end_count >= self.effect_count then
		self.end_count = 0
		self:Close()
	end
end

function FlyEffectView:StartDoTween()
	local fly_count = 0
	if self.fly_time_quest then
		GlobalTimerQuest:CancelQuest(self.fly_time_quest)
		self.fly_time_quest = nil
	end
	self.fly_time_quest = GlobalTimerQuest:AddRunQuest(function()
		if fly_count >= self.effect_count then
			GlobalTimerQuest:CancelQuest(self.fly_time_quest)
			self.fly_time_quest = nil
			return
		end
		fly_count = fly_count + 1

		local obj = self.effect_obj_list[fly_count]
		if obj then
			local tween = obj.transform:DOLocalMove(self.end_position, self.duration)
			tween:SetEase(self.ease)
			tween:OnComplete(BindTool.Bind(self.OnMoveEnd, self))
			table.insert(self.tween_list, tween)
		end
	end, interval)
end

function FlyEffectView:CreatEffect()
	local count = 0
	local random_min_x = self.start_position.x - Section
	local random_max_x = self.start_position.x + Section

	local random_min_y= self.start_position.y - Section
	local random_max_y = self.start_position.y + Section

	if self.add_time_quest then
		GlobalTimerQuest:CancelQuest(self.add_time_quest)
		self.add_time_quest = nil
	end

	self.add_time_quest = GlobalTimerQuest:AddRunQuest(function()
		if count >= self.effect_count then
			GlobalTimerQuest:CancelQuest(self.add_time_quest)
			self.add_time_quest = nil
			return
		end
		count = count + 1
		GameObjectPool.Instance:SpawnAsset(self.bundle, self.asset, function(obj)
			if nil == self.root_node or nil == obj then
				if not self.need_repeat and self.complete_callback then
					self.complete_callback()
					self.complete_callback = nil
				end
				return
			end
			obj.transform:SetParent(self.root_node.transform, false)

			local x = math.random(random_min_x, random_max_x)
			local y = math.random(random_min_y, random_max_y)
			obj.transform.localPosition = Vector3(x, y, 0)
			table.insert(self.effect_obj_list, obj)
			if #self.effect_obj_list >= self.effect_count then
				self:StartDoTween()
			end
		end)
	end, interval)
end

function FlyEffectView:OpenCallBack()
	self.end_count = 0

	self.my_uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	self.my_rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))

	self:SetStartPosition()
	self:SetEndPosition()
	self.effect_count = self.effect_count or EffectCount
	self:CreatEffect()
end

function FlyEffectView:CloseCallBack()
	self.start_obj = nil
	self.end_obj = nil
	self.my_uicamera = nil
	self.my_rect = nil
	self.effect_count = 0

	if self.add_time_quest then
		GlobalTimerQuest:CancelQuest(self.add_time_quest)
		self.add_time_quest = nil
	end

	if self.fly_time_quest then
		GlobalTimerQuest:CancelQuest(self.fly_time_quest)
		self.fly_time_quest = nil
	end

	for _, v in ipairs(self.effect_obj_list) do
		GameObjectPool.Instance:Free(v)
	end
	self.effect_obj_list = {}

	for _, v in ipairs(self.tween_list) do
		v:Pause()
	end
	self.tween_list = {}

	if not self.need_repeat and self.complete_callback then
		self.complete_callback()
		self.complete_callback = nil
	end
end