require("game/timeline/RequireTimeline");

--时间轴管理器
TimelineManager = TimelineManager or class("TimelineManager")

function TimelineManager:ctor(  )
	TimelineManager.Instance = self

	self.camera_trans = nil

	--是否进游戏后第一次进入场景
	self.is_first_enter_scene = true

	self:Reset()
	self:AddEvent()
end

function TimelineManager:dctor(  )
  
end

--清理数据
function TimelineManager:Reset()

	--logError("清理时间轴数据")

	--当前场景id
	self.cur_scene_id = nil

	--当前时间轴总时长
	self.all_time = nil

	--摄像机原始位置
	self.camera_original_pos = {}
	
	--摄像机原始大小
	self.camera_original_size = nil

	--等待执行的action
	self.wait_actions = {}

	--等待创建的怪物
	self.wait_create_monsters = {}

	--已创建的怪物
	self.created_monster = {}

	--已创建的特效
	self.created_effect = {}

	--已创建的MonsterText
	self.created_monster_text = {}

	--还在跑的定时器id列表
	self.schedule_ids = {}

	

	--场景摄像机
	if MapManager then
		self.camera_trans = self.camera_trans or MapManager.Instance.sceneCamera.transform
	end
	

	--各个层级
	self.scene_layer = self.scene_layer or GetImage(self:GetLayer(LayerManager.LayerNameList.Scene))
	self.bottom_layer = self.bottom_layer or self:GetLayer(LayerManager.LayerNameList.Bottom)
	self.ui_layer = self.ui_layer or self:GetLayer(LayerManager.LayerNameList.UI)
	self.top_layer = self.top_layer or self:GetLayer(LayerManager.LayerNameList.Top)
	--self.scene_other_obj = self.scene_other_obj or self:GetLayer(LayerManager.LayerNameList.SceneOtherObj)
	--self.scene_image = self.scene_image or self:GetLayer(LayerManager.LayerNameList.SceneImage)

	self.timeline_panel = nil
end

function TimelineManager:GetLayer(name)
	return LayerManager:GetInstance():GetLayerByName(name)
end

function TimelineManager:GetInstance()
	if not TimelineManager.Instance then
		TimelineManager()
	end
	return TimelineManager.Instance
end


function TimelineManager:AddEvent()
    GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

--处理场景切换事件
function TimelineManager:HandleSceneChange(scene_id)

	self:Reset()

	local cfg = TimelineConfig[scene_id]
	
	local need_skip = false
	if self.is_first_enter_scene == true then
		--重登进了有过场的副本 需要跳过动画
		need_skip = true
		self.is_first_enter_scene = false
	end

	if cfg then
		
		if need_skip == true then
			--直接跳过
			GlobalEvent:Brocast(EventName.EndHandleTimeline,scene_id)
			return
		end


		--存在该场景的时间轴配置 获取相关配置数据
		self.all_time = Time.time + cfg.AllTime

		--收集待创建怪物信息
		for k,v in pairs(cfg.Monster) do
			v.GlobalCreateTime = Time.time + v.CreateTime --刷新全局的创建时间
			table.insert( self.wait_create_monsters,v)
		end

		--收集待执行action信息
		for k,v in ipairs(cfg.Action) do
			v.GlobalStartTime = Time.time + v.StartTime  --刷新全局的开始时间
			if v.EndTime then
				v.Duration = v.Duration or v.EndTime - v.StartTime  --持续时间
			end
			table.insert(self.wait_actions,v)
		end

		--按开始时间或order排序
		local function sort_func(a,b)
			if a.StartTime ~= b.StartTime then
				return a.StartTime < b.StartTime
			end
			
			if a.Order ~= b.Order then
				return a.Order < b.Order
			end
		end

		table.sort(self.wait_create_monsters, sort_func)
		table.sort(self.wait_actions, sort_func)

		--开始时间轴
		self.cur_scene_id = scene_id
		self:StartHandleTimeline()
	
	else
		GlobalEvent:Brocast(EventName.EndHandleTimeline,scene_id)
	end
end

--开始时间轴
function TimelineManager:StartHandleTimeline( )
	--logError("时间轴开始")

	--特殊处理下GM界面
	local gmPanel =  LuaPanelManager:GetInstance():GetPanelByName("GMPanel")
	if gmPanel then
		gmPanel:Close()
	end
	
	--禁用地图点击 隐藏所有界面和other obj
	self:HandleLayer(false)

	--打开时间轴界面
	self.timeline_panel = LuaPanelManager:GetInstance():GetPanelOrCreate(TimelinePanel)
	self.timeline_panel:Open()
	local function call_back(  )
		self:EndHandleTimeline()
	end
	self.timeline_panel:SetCloseCallback(call_back)

	local schedule_id = GlobalSchedule:Start(handler(self, self.HandleTimelineConfig),0.1)
	self.timeline_panel:SetScheduleId(schedule_id)

	--等待0.1秒再派发开始时间轴事件 否则摄像机会无法及时瞬移到初始位置
	local function call_back(  )
		GlobalEvent:Brocast(EventName.StartHandleTimeline)
	end
	GlobalSchedule:StartOnce(call_back,0.1)


end

--结束时间轴
function TimelineManager:EndHandleTimeline( )
	--logError("时间轴结束")

	--启用地图点击 显示所有界面和other obj
	self:HandleLayer(true)

	--复位摄像机
	if self.camera_original_pos.x and self.camera_original_pos.y and self.camera_original_pos.z then
		SetGlobalPosition(self.camera_trans,self.camera_original_pos.x,self.camera_original_pos.y,self.camera_original_pos.z)
	end
	if self.camera_original_size then
		MapManager.Instance.sceneCamera.orthographicSize = self.camera_original_size
	end



	--停掉所有还在跑的定时器
	for k,v in pairs(self.schedule_ids) do
		--logError("停止还在跑的定时器"..v)
		GlobalSchedule:Stop(v)
	end

	--销毁已创建怪物
	for k,v in pairs(self.created_monster) do
		-- destroy(v)
		v:destroy()
	end
	self.created_monster = {}

	--销毁没来得及销毁的特效
	for k,v in pairs(self.created_effect) do
		EffectManager:GetInstance():RemoveSceneEffect(self,v)
		v:destroy()
	end

	--销毁没来得及销毁的MonsterText
	for k,v in pairs(self.created_monster_text) do
		v:destroy()
	end

	--停掉所有cc action
	cc.ActionManager:GetInstance():removeAllActions()

	GlobalEvent:Brocast(EventName.EndHandleTimeline,self.cur_scene_id)

	self:Reset()

	--过场动画播放完毕 请求开始副本
	DungeonCtrl:GetInstance():RequestDungeStart()
end

--处理各个层级
function TimelineManager:HandleLayer(visible)
	self.scene_layer.raycastTarget = visible
	SetVisible(self.bottom_layer,visible)
	SetVisible(self.ui_layer,visible)
	--SetVisible(self.top_layer,visible)
	--SetVisible(self.scene_other_obj,visible)
	--SetVisible(self.scene_image,visible)
end


--处理时间轴配置
function TimelineManager:HandleTimelineConfig()

	if Time.time >= self.all_time then
		--总时间已过，关闭时间轴界面，结束时间轴配置处理
		self.timeline_panel:FadeClosePanel()
		return
	end

	

	--使用循环处理多个创建时间点相同的Monster
	while true do
		--检查排在首位的待创建怪物信息（开始时间最近的那个）
		if self.wait_create_monsters[1] then
			local monster = self.wait_create_monsters[1]
			if Time.time >= monster.GlobalCreateTime then
				--移除要创建的首位monster
				table.remove(self.wait_create_monsters,1)

				--logError("开始处理创建怪物")
				self:HandleCreateMonster(monster)
			else
				--排首位的怪物还没到创建时间 打断循环
				break
			end

		else
			--没有要创建的怪物了 打断循环
			break

		end
	end



	--使用循环处理多个开始时间点相同的Action
	while true do

		--检查排在首位的action（开始时间最近的那个）
		if self.wait_actions[1] then

			local action = self.wait_actions[1]
			if Time.time >= action.GlobalStartTime then
				--移除要处理的首位action
				table.remove(self.wait_actions,1)
	
				if action.ActionType == TimelineActionType.Move then
	
					--处理移动action
					--logError("开始处理移动Action")
					self:HandleMoveAction(action)
	
				elseif action.ActionType == TimelineActionType.Shake then
	
					--处理震屏action
					--logError("开始处理震屏Action")
					self:HandleShakeAction(action)
			
				elseif action.ActionType == TimelineActionType.Anim then
	
					--处理动画action
					--logError("开始处理动画Action")
					self:HandleAnimAction(action)
	
				elseif action.ActionType == TimelineActionType.Effect then
					
					--处理特效action
					--logError("开始处理特效Action")
					self:HandleEffectAction(action)
	
				elseif action.ActionType == TimelineActionType.Scale then
					
					--处理缩放action
					--logError("开始处理缩放Action")
					self:HandleScaleAction(action)
	
				elseif action.ActionType == TimelineActionType.ShowMonsterName then
					
					--处理显示怪物名字action
					--logError("开始处理显示怪物名字Action")
					self:HandleShowMonsterNameAction(action)
				elseif action.ActionType == TimelineActionType.ShowMonsterTalk then
					
					--处理显示怪物对话action
					--logError("开始处理显示怪物对话Action")
					self:HandleShowMonsterTalkAction(action)
				else
					logError("Action的Type无效")
				end
			else
				--排首位的Action还没到时间 打断循环
				break
			end
			
		else
			--没有等待处理的Action了 打断循环
			break
		end
	end


end

--处理创建怪物
function TimelineManager:HandleCreateMonster(monster)
		--实例化要创建的怪物
		local cfg = Config.db_creep[monster.MonsterId]
		local ab_Name = "asset/"..cfg.figure..AssetsBundleExtName
		local asset_Name = cfg.figure..".prefab"

		local monsterModel = TimelineModel(ab_Name,asset_Name)
		self.created_monster[monster.InstanceId] = monsterModel

		local z = LayerManager:GetInstance():GetSceneObjectDepth(monster.PosY)
		monsterModel:SetGlobalPosition(monster.PosX,monster.PosY,z)
		monsterModel:SetRotate(monster.RotX,monster.RotY,monster.RotZ)
		monsterModel:SetLocalScale(cfg.scale,cfg.scale,cfg.scale)
		if monster.IsPrecreate then
			monsterModel:SetVisible(false)
		end

		-- local function call_back(objs)
		-- 	local go = newObject(objs[0])
		-- 	self.created_monster[monster.InstanceId] = go
		-- 	local trans = go.transform
		-- 	local z = LayerManager:GetInstance():GetSceneObjectDepth(monster.PosY)
		-- 	SetGlobalPosition(trans,monster.PosX,monster.PosY,z)
		-- 	SetRotation(trans,monster.RotX,monster.RotY,monster.RotZ)
		-- 	SetLocalScale(trans,cfg.scale,cfg.scale,cfg.scale)
		-- 	--预创建的 先隐藏
		-- 	if monster.IsPrecreate then
		-- 		SetVisible(trans,false)
		-- 	end
		-- end

		-- lua_resMgr:LoadPrefab(self,ab_Name,asset_Name,call_back,nil, Constant.LoadResLevel.High)
end

--处理移动action
function TimelineManager:HandleMoveAction(action)

	local target = nil
	if action.TargetType == TimelineTargetType.Camera then

		target = self.camera_trans

		--第一次移动摄像机 记录下初始位置 方便时间轴结束后复位
		if not self.camera_original_pos.x or not self.camera_original_pos.y or not self.camera_original_pos.z then
			self.camera_original_pos.x = self.camera_trans.position.x
			self.camera_original_pos.y = self.camera_trans.position.y
			self.camera_original_pos.z = self.camera_trans.position.z
		end

	elseif action.TargetType == TimelineTargetType.Monster then
	--TODO:

	elseif action.TargetType == TimelineTargetType.MainRole then
	--TODO:
	end

	local move_action = cc.MoveTo(action.Duration,action.MoveTargetPosX,action.MoveTargetPosY,target.position.z)
	cc.ActionManager:GetInstance():addAction(move_action, target)
end

--处理震屏Action
function TimelineManager:HandleShakeAction(action)

	local cur_time = action.Duration

	local total_time = action.Duration

	local schedule_shake_id = nil

	--先*100再取随机数，取到后/100，实现取浮点随机数效果
	local temp_x = action.ShakeX * 100
	local temp_y = action.ShakeY * 100
	local temp_z = action.ShakeZ * 100

	--原始位置
	local old_x = self.camera_trans.position.x
	local old_y = self.camera_trans.position.y
	local old_z = self.camera_trans.position.z

	local interval = action.ShakeInterval or Time.deltaTime
	local timer = 0

	local function call_back()
		if cur_time > 0 and total_time > 0 then
			local percent = cur_time / total_time
			cur_time = cur_time - Time.deltaTime

			timer = timer + Time.deltaTime
			if timer < interval then
				return
			end
			
			timer = 0

			--震动距离
			local x = Mathf.Random(-Mathf.Abs(temp_x) * percent,Mathf.Abs(temp_x) * percent)
			local y = Mathf.Random(-Mathf.Abs(temp_y) * percent,Mathf.Abs(temp_y) * percent)
			local z = Mathf.Random(-Mathf.Abs(temp_z) * percent,Mathf.Abs(temp_z) * percent)

			--最终位置=原始位置+震动距离
			 x = old_x + x / 100
			 y = old_y + y / 100
			 z = old_z + z / 100

			 SetLocalPosition(self.camera_trans,x,y,z)

			 
		else
			SetGlobalPosition(self.camera_trans,old_x,old_y,old_z)
			GlobalSchedule:Stop(schedule_shake_id)
			
			self.schedule_ids[schedule_shake_id] = nil	
		end
	end 

	schedule_shake_id = GlobalSchedule:Start(call_back,0)
	self.schedule_ids[schedule_shake_id] = schedule_shake_id
end

--处理动画Action
function TimelineManager:HandleAnimAction(action)
	local target = nil
	if action.TargetType == TimelineTargetType.Monster then
		--怪物
		target = self.created_monster[action.MonsterInstanceId]
		if not target or not target.is_loaded then
			logError(self.cur_scene_id .. "要处理的动画Action的MonsterInstanceId"..action.MonsterInstanceId.."无效")
			return
		end

	elseif action.TargetType == TimelineTargetType.MainRole then
		--TODO:
		return
	end

	target:SetVisible(true)
	local animator = target.animator
	animator:CrossFade(action.AnimName,0)

	local length = GetClipLength(animator,action.AnimName)

	local schedule_anim_id
	local function call_back()
		--切换回idle
		animator:CrossFade("idle",0)
		self.schedule_ids[schedule_anim_id] = nil
	end

	schedule_anim_id = GlobalSchedule:StartOnce(call_back,length)
	self.schedule_ids[schedule_anim_id] = schedule_anim_id
end

--处理特效Action
function TimelineManager:HandleEffectAction(action)

	local effect
	local config= {
		pos = {x = 0,y = 0}, scale = 1, speed = 1, is_loop = action.IsLoop,
	}

	if action.TargetType == TimelineTargetType.Camera then
		

		if UnityEngine.Screen.width / UnityEngine.Screen.height > 16/9 then
			config.scale = (UnityEngine.Screen.width / UnityEngine.Screen.height) / (16/9)
		end
	    local parent = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Scene)
	    effect = SceneTargetEffect(parent, action.EffectName, EffectManager.SceneEffectType.Target, self,LayerManager.BuiltinLayer.UI)
		effect:SetOrderIndex(action.EffectOrder)
		
	elseif action.TargetType == TimelineTargetType.Monster then
		
		local target = self.created_monster[action.MonsterInstanceId]
		if not target or not target.is_loaded then
			logError(self.cur_scene_id .. "要处理的特效Action的MonsterInstanceId"..action.MonsterInstanceId.."无效")
			return
		end
		target:SetVisible(true)

		local effect_node = target.transform:Find(action.EffectNodeName)
		if not effect_node then
			effect_node = GetComponentChildByName(target.transform,action.EffectNodeName)
		end

		if action.RotX and action.RotY and action.RotZ then
			config.rotation = {}
			config.rotation.x = action.RotX
			config.rotation.y = action.RotY
			config.rotation.z = action.RotZ
		end
		effect = SceneTargetEffect(effect_node,action.EffectName, EffectManager.SceneEffectType.Target, self)
		

	end

	effect:SetConfig(config)
	

	self.created_effect[action.EffectName] = effect
	local schedule_effect_id
	local function call_back()
		--销毁特效
		if self.created_effect[action.EffectName] then
			local effect  = self.created_effect[action.EffectName]
			EffectManager:GetInstance():RemoveSceneEffect(self,effect)
			effect:destroy()
			self.created_effect[action.EffectName] = nil
			--logError("销毁特效"..action.EffectName)
		end

		self.schedule_ids[schedule_effect_id] = nil
	end
	schedule_effect_id = GlobalSchedule:StartOnce(call_back,action.Duration)
	self.schedule_ids[schedule_effect_id] = schedule_effect_id
end

--处理缩放Action
function TimelineManager:HandleScaleAction(action)

	function call_back(new_num)
		MapManager.Instance.sceneCamera.orthographicSize = new_num
	end

	--第一次缩放相机 记录下size 方便结束后复位
	if not self.camera_original_size then
		self.camera_original_size = MapManager.Instance.sceneCamera.orthographicSize
	end

	local camera_original_size =  MapManager.Instance.sceneCamera.orthographicSize

	self:SmoothNumber(camera_original_size,action.ScaleTargetSize,action.Duration,call_back)
end

--处理显示怪物名字Action
function TimelineManager:HandleShowMonsterNameAction(action)
		self.timeline_panel:ShowMonsterName(action.MonsterId,action.ShowFadeTime,action.ShowTime,action.HideFadeTime)
end

--处理显示怪物对话Action
function TimelineManager:HandleShowMonsterTalkAction(action)
	local monster_text = MonsterText()
	self.created_monster_text[action.MonsterInstanceId] = monster_text
	monster_text:ShowName(false)
	monster_text:SetTalkContent(action.TalkText)
	monster_text:ShowTalk(true,action.Duration)

	local target = self.created_monster[action.MonsterInstanceId]
	if not target or not target.is_loaded then
		logError(self.cur_scene_id .. "要处理的显示怪物对话Action的MonsterInstanceId"..action.MonsterInstanceId.."无效")
		return
	end
	target = target.transform

	local world_pos = { x = target.position.x, y = target.position.y  }
	--local body_height = self:GetBodyHeight() + (self.body_pos.y <= 0 and 0 or self.body_pos.y + 30)
	
	local body_skin_renderer = target.gameObject:GetComponentInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
	local x, y, z = GetRenderBoundsSize(body_skin_renderer)
	local body_height = y/2
	monster_text:SetGlobalPosition(world_pos.x, world_pos.y + body_height, target.position.z * 1.1)

	if action.TalkPosY then
		SetLocalPositionY(monster_text.transform,action.TalkPosY)
	end
	

	local schedule_talk_id

	local function call_back(  )
		monster_text:destroy()
		self.created_monster_text[action.MonsterInstanceId] = nil
		self.schedule_ids[schedule_talk_id] = nil
	end
	schedule_talk_id = GlobalSchedule:StartOnce(call_back,action.Duration)
	self.schedule_ids[schedule_talk_id] = schedule_talk_id
end

--数字平滑过渡
function TimelineManager:SmoothNumber(original_num,target_num,duration,call_back)
	local schedule_id
	local timer = 0
	local function call_back2()
		if timer < duration then
			timer = timer + Time.deltaTime
			local new_num = Mathf.Lerp(original_num,target_num,timer / duration)
			call_back(new_num)
		else
			call_back(target_num)
			GlobalSchedule:Stop(schedule_id)
			self.schedule_ids[schedule_id] = nil
		end
	end
	schedule_id = GlobalSchedule:Start(call_back2,0)
	self.schedule_ids[schedule_id] = schedule_id
end


