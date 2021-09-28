--[[参数： res "effect/resId.unity3d" 仅处理这里的特效 releaseTime 释放删除特效时间 0:无限, n:时间 autoDestroy 粒子特效是否在美术那边自己处理会释放, true false
	注意:	1.所有外部删除操作必需由以下方法统一执行否则会有内存溢出： Destroy(effect), DestroyById(id), RealseEffect(id)
			2.执行 EffectMgr.Reset()方法后 延迟0.5秒等缓存清理完再重新加特效，否执也没什么事,特效加载不成功
]]
EffectMgr = {}
local this = EffectMgr
this.autoId = -999999999
this.autoDestroyTime = 5
this.isPreLoadingEffect = false -- 正在预加载
function EffectMgr.Init()
	this._isClearing = false
	this.map = {}
	this.followMap = {}
	this.nearPosMap = {}
	this.autoDestroyMap = {}
	this.creatingMap = {} -- 正在创建的特效,用于纠正删除销毁

	this.destroyCallbackMap = {}

	RenderMgr.Add(function () this.Update() end, "__EffectRender")
end

-- 将一个特效资源添加到空间位置
function EffectMgr.AddToPos(res, pos, releaseTime, delay, autoDestroy, id, callback, scale, destroyCallback, param2)
	id = this._CreatingEffectId(id)
	local exec = function ()
		this.LoadEffect(res, function (effect)
			if not ToLuaIsNull(effect) then
				if not this._isClearing then
					this._Cache(id, effect)
					if pos then effect.transform.localPosition = pos end -- 位置设置
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
					releaseTime = releaseTime or 0
					if releaseTime > 0 then  -- 设置释放时间
						this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
					end
					if destroyCallback then
						this.destroyCallbackMap[id] = {destroyCallback, param2}
					end
					if callback then callback(id) end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
--[[特效绑定到gameObject中 (骨骼：先用 Util.GetBone(name, parent) 找到骨骼点再绑定）
	或 另外对已经有的特效直接使用 BindToBone(res, targetRoot, boneName, releaseTime, delay, autoDestroy, id, callback, pos, scale)
	]]
function EffectMgr.BindTo(res, gameObject, releaseTime, delay, autoDestroy, id, callback, pos, scale, destroyCallback, param2)
	id = this._CreatingEffectId(id)
	if ToLuaIsNull(gameObject) or not res then logWarn("创建失败，特效绑定的对象不存在!"..(res or "nil")) return id end
	local exec = function  ()
		this.LoadEffect(res, function (effect)
			local hasError = false
			local result = pcall(function()
				if ToLuaIsNull(gameObject) then
					destroyImmediate(effect)
					this.creatingMap[id] = nil
					logWarn("创建失败，找不到特效绑定的对象!")
					hasError = true
					return
				end
			end)
			if hasError then return end
			if not result then
				destroyImmediate(effect)
				this.creatingMap[id] = nil
				return
			end
			if effect then
				if not this._isClearing then
					this._Cache(id, effect)
					local root = gameObject.transform
					local eTf = effect.transform
					this.SetParent( effect, root )
					if pos ~= nil then eTf.localPosition = pos end
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					eTf.rotation = root.rotation
					if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
					releaseTime = releaseTime or 0
					if releaseTime > 0 then  -- 设置释放时间
						this.autoDestroyMap[id] = releaseTime
					end
					if destroyCallback then
						this.destroyCallbackMap[id] = {destroyCallback, param2}
					end
					if callback then callback(id) end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
--特殊绑定
--@param effectName 特效名
--@param target 目标对象
--@param liftTime 生命周期
--@param loadCallBack 加载回调
--@return 绑定特效id, 是否绑定成功
function EffectMgr.SpecialBindToBone(effectName, target, liftTime, loadCallBack)
	local eftIds = {}
	local autoDestroy = liftTime == nil or liftTime == 0
	if ToLuaIsNull(target.transform) then return eftIds end
	local eftInfo = StringSplit(effectName, "_")
	local eftName = effectName
	local handlerType = eftInfo[2]
	if handlerType == nil then
		return eftIds
	end
	local tar = target.transform.gameObject
	if string.lower(handlerType) == "b" then --绑到指定骨骼
		local boneName = ""
		local len = #eftInfo
		for i=3, len do
			local s = string.lower(eftInfo[i])
			if s ~= "finger0nub" then
				if s ~= "weapon01" and s ~= "weapon02" then
					s = string.upper(string.sub(s, 1, 1)) ..string.sub(s, 2)
				end
			else
				s = "Finger0Nub"
			end
			boneName = boneName..s..(i ~= len and " " or "")
		end
		
		local eftId = this.BindToBone(eftName, tar, boneName, liftTime, nil, autoDestroy, nil, function(eid)
			if loadCallBack then 
				loadCallBack(eid)
				loadCallBack = nil
			end
   		end)
   		table.insert(eftIds, eftId)

	elseif string.lower(handlerType) == "2h" then --绑双手
		local eftId = this.BindToBone(eftName, tar, BoneHandEffect.LeftHand, liftTime, nil, autoDestroy, nil, function(eid)
			if loadCallBack then 
				loadCallBack(eid)
				loadCallBack = nil
			end
   		end)
   		table.insert(eftIds, eftId)
   		local eftId = this.BindToBone(eftName, tar, BoneHandEffect.RightHand, liftTime, nil, autoDestroy, nil, function(eid)
			if loadCallBack then 
				loadCallBack(eid)
				loadCallBack = nil
			end
   		end)
   		table.insert(eftIds, eftId)
	elseif string.lower(handlerType) == "2w" then --绑双武器
		
	end
	return eftIds
end
-- 目标骨骼的父级节点绑定特效 targetRoot:GameObject Util.BindBone(effect, boneName, targetRoot, pos)
function EffectMgr.BindToBone(res, targetRoot, boneName, releaseTime, delay, autoDestroy, id, callback, pos, scale, destroyCallback, param2)
	id = this._CreatingEffectId(id)
	if not boneName or ToLuaIsNull(targetRoot) then logWarn("创建失败，特效绑定的骨骼不存在!"..boneName) return id end
	local exec = function  ()
		this.LoadEffect(res, function (effect)
			if ToLuaIsNull(targetRoot) then
				destroyImmediate(effect)
				this.creatingMap[id] = nil
				return
			end
			local gameObject = Util.GetBone(boneName, targetRoot)
			if ToLuaIsNull(gameObject) then
				destroyImmediate(effect)
				this.creatingMap[id] = nil
				logWarn("创建失败，找不到特效绑定的骨骼!"..boneName)
				return
			end
			if not ToLuaIsNull(effect) then
				if not this._isClearing then
					this._Cache(id, effect)
					local root = gameObject.transform
					local etf = effect.transform
					this.SetParent( effect, root )
					if pos ~= nil then etf.localPosition = pos end
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					etf.rotation = root.rotation
					if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
					releaseTime = releaseTime or 0
					if releaseTime > 0 then  -- 设置释放时间
						this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
					end
					if destroyCallback then
						this.destroyCallbackMap[id] = {destroyCallback, param2}
					end
					if callback then callback(id) end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
				-- if callback then callback(id) end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
-- 移动特效位置 target目标位置或与start有distance远后停止移动, catchCallback 碰到时回调 param 回调参数 catchDestroy 到达目标时立即销毁 stayTime 逗留时间
-- target:可以是V3位置或目标transform对象
function EffectMgr.MoveTo(res, start, target, speed, releaseTime, delay, distance, catchCallback, param, catchDestroy, autoDestroy, id, callback, scale, destroyCallback, param2, stayTime)
	speed = speed or 0
	id = this._CreatingEffectId(id)
	if speed == 0 or ToLuaIsNull(target) then logWarn("[move]创建失败，特效speed=0或目标位置不存在!") return id end
	if distance == 0 then distance = nil end
	local exec = function  ()
		this.LoadEffect(res, function (effect)
			if not ToLuaIsNull(effect) then
				if not this._isClearing then
					this._Cache(id, effect)
					effect.transform.position = start
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					stayTime = stayTime or 0
					local doEffect = function ()
						if this.map[id] then
							this.nearPosMap[id] = {target, speed, distance, start, catchCallback, param, catchDestroy}
							if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
							releaseTime = releaseTime or 0
							if releaseTime > 0 then  -- 设置释放时间
								this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
							end
							if destroyCallback then
								this.destroyCallbackMap[id] = {destroyCallback, param2}
							end
							if callback then callback(id) end
						end
					end
					if stayTime == 0 then
						doEffect()
					else
						DelayCall(doEffect, stayTime)
					end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
-- 弹跳（N次）|抛出（1次）target为位置 或 目标 transform， jumpNum弹跳次数，maxH 相对起点高度飞到的最高值
function EffectMgr.ThrowTo(res, start, target, speed, releaseTime, delay, catchCallback, param, catchDestroy, autoDestroy, id, callback, scale, destroyCallback, param2, jumpNum, maxH, stayTime)
	speed = speed or 0
	id = this._CreatingEffectId(id)
	if speed == 0 or ToLuaIsNull(target) then logWarn("[throw]创建失败，特效speed=0或目标位置不存在!") return id end
	if type(target) ~= "table" then target = target.position end
	local dist = Vector3.Distance(start, target)
	if dist < 2 or math.abs(start.y-target.y) > 1 then -- 小于2米用直线
		this.MoveTo(res, start, target, speed, releaseTime, delay, nil, catchCallback, param, catchDestroy, autoDestroy, id, callback, scale, destroyCallback, param2, stayTime)
		return id
	end
	local exec = function  ()
		this.LoadEffect(res, function (effect)
			if not ToLuaIsNull(effect) then
				if not this._isClearing then
					this._Cache(id, effect)
					local etf = effect.transform
					etf.position = start
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					stayTime = stayTime or 0

					local doEffect = function ()
						if this.map[id] then
							if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
							releaseTime = releaseTime or 0
							if releaseTime > 0 then  -- 设置释放时间
								this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
							end
							if destroyCallback then
								this.destroyCallbackMap[id] = {destroyCallback, param2}
							end
							if callback then callback(id) end
							maxH = maxH or 2
							local hl = 2*dist*0.2 -- + math.abs(start.y-target.y)
							local mt = 0.5 + hl/speed -- 运行时间
							local tweener = TweenUtils.DoJump(etf, target+Vector3.New(0,maxH,0), mt, jumpNum or 1, 1)
							TweenUtils.OnTweenCompleted(tweener, function ()
								if this.map[id] then
									if catchCallback then -- 回调到达目标位置
										catchCallback(param, id)
										catchCallback, param = nil, nil
									end
									if catchDestroy then -- 到达目标时立即销毁
										this.DestroyById(id)
									end
								end
							end)
						end
					end
					if stayTime == 0 then
						doEffect()
					else
						DelayCall(doEffect, stayTime)
					end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
-- 特效跟随场景对象 (如护盾圈，龙卷风在身上，有自身旋转)
function EffectMgr.FollowTo(res, gameObject, releaseTime, delay, autoDestroy, id, callback, scale, destroyCallback, param2)
	id = this._CreatingEffectId(id)
	if ToLuaIsNull(gameObject) then logWarn("创建失败，特效跟随的对象不存在!") return id end
	local exec = function  ()
		this.LoadEffect(res, function (effect)
			if ToLuaIsNull(gameObject) then
				destroyImmediate(effect)
				this.creatingMap[id] = nil
				logWarn("创建失败，找不到特效跟随的对象!"..id)
				return
			end
			if not ToLuaIsNull(effect) then
				if not this._isClearing or not this._isFollowClearing then
					local follow = gameObject.transform
					this._Cache(id, effect)
					local parent = follow.parent
					if not ToLuaIsNull(parent) then
						this.SetParent( effect, parent )
					end
					this.followMap[id] = follow -- 跟随的 transform 对象
					local etf = effect.transform
					etf.localPosition = follow.localPosition
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					etf.rotation = follow.rotation
					if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
					releaseTime = releaseTime or 0
					if releaseTime > 0 then  -- 设置释放时间
						this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
					end
					if destroyCallback then
						this.destroyCallbackMap[id] = {destroyCallback, param2}
					end
					if callback then callback(id) end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
-- 由先前的创建特效接口产生的特效，再将创建指定特效id设置要跟随相应的gameObject
function EffectMgr.SetFollow( id, gameObject, releaseTime, delay, autoDestroy, scale, destroyCallback, param2)
	if not this.map[id] then return end
	if ToLuaIsNull(gameObject) then logWarn("创建失败，[设置]特效跟随的对象不存在!") return end
	local exec = function  ()
		if ToLuaIsNull(gameObject) then
			logWarn("创建失败，找不到[设置]特效跟随的对象!")
			return
		end
		local effect = this.map[id]
		if not ToLuaIsNull(effect) then
			this._Cache(id, effect, true)
			local follow = gameObject.transform
			local parent = follow.parent
			if not ToLuaIsNull(parent) then
				this.SetParent( effect, parent )
			end
			this.followMap[id] = follow -- 跟随的 transform 对象
			local etf = effect.transform
			etf.localPosition = follow.localPosition
			if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
			etf.rotation = follow.rotation
			if autoDestroy then this.autoDestroyMap[id] = this.autoDestroyTime end -- 自动销毁时间
			releaseTime = releaseTime or 0
			if releaseTime > 0 then  -- 设置释放时间
				this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
			end
			if destroyCallback then
				this.destroyCallbackMap[id] = {destroyCallback, param2}
			end
		end
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
end
--[[以start为中心radius半径随机产生num个特效后集中或直接射出的特效
	moveType 0移动(distance) 1抛射(jumpNum, maxH)
	rType :0.圆内的点【暂不支持】 1.球面的点 2.球内的点 randomDelayCreate(毫秒)随机时间内产生，填nil或0或delay不空表示不随机
	]]
function EffectMgr.Scatter(res, moveType, randomDelayCreate, rType, num, radius, start, target, speed, releaseTime, delay, distance, catchCallback, param, catchDestroy, autoDestroy, callback, scale, destroyCallback, param2, distance, jumpNum, maxH, stayTime)
	randomDelayCreate = randomDelayCreate or 0
	rType = rType or 1
	local result = GetRandomPoint(rType, num or 1, radius, start)
	for i=1,#result do
		if randomDelayCreate ~= 0 and delay ~= nil then
			delay = math.random(randomDelayCreate)*0.001
		end
		start = result[i]
		if moveType == 0 then
			this.MoveTo(res, start, target, speed, releaseTime, delay, distance, catchCallback, param, catchDestroy, autoDestroy, nil, callback, scale, destroyCallback, param2, stayTime)
		else
			this.ThrowTo(res, start, target, speed, releaseTime, delay, catchCallback, param, catchDestroy, autoDestroy, nil, callback, scale, destroyCallback, param2, jumpNum, maxH, stayTime)
		end
	end
end
-- 添加特效到FUI(GGraph图形对象作容器)中
function EffectMgr.AddToUI(res, ui, releaseTime, pos, scale, eulerAngles, id, callback, delay)
	id = this._CreatingEffectId(id)
	if not ui then logWarn("创建失败，特效绑定的ui不存在!") return id end
	local exec = function  ()
		this.LoadEffect(res, function (effect)
			if not ui then
				this.creatingMap[id] = nil
				logWarn("创建失败，找不到特效绑定的ui!")
				return
			end
			if not ToLuaIsNull(effect) then
				if not this._isClearing then
					this._Cache(id, effect, true)
					if scale ~= nil then Util.ScaleParticleSystem(effect.gameObject, scale) end
					local etf = effect.transform
					if pos then etf.localPosition = pos end
					if eulerAngles then etf.localEulerAngles = eulerAngles end
					ui:SetNativeObject(GoWrapper.New(effect))
					if callback then callback(effect) end
					releaseTime = releaseTime or 0
					if releaseTime > 0 then  -- 设置释放时间
						this.autoDestroyMap[id] = releaseTime -- math.min(releaseTime, this.autoDestroyTime)
					end
				elseif this.creatingMap[id]	then								-- 正在执行清理中
					destroyImmediate(effect)
				end
			end
			this.creatingMap[id] = nil
		end)
	end
	delay = delay or 0
	if delay == 0 then
		exec()
	else
		DelayCall(exec, delay)
	end
	return id
end
-- 对特效绑定音效 soundRes 只处理Audio路径内的音频文件
function EffectMgr.PlaySound(soundId)
	if not soundId then return end
	soundMgr:PlayEffect(tostring(soundId))
end

function EffectMgr.PlayBGSound(soundId)
	if not soundId then return end 
	soundMgr:PlayBackSound(tostring(soundId))
end

-- 销毁指定特效以一定时间 useDestroyCallback是否启用销毁回调
function EffectMgr.Destroy(effect)
	for id,v in pairs(this.map) do
		if v == effect then
			this.DestroyById(id) -- 找到处理
			effect = nil
			break
		end
	end
	destroyImmediate(effect)
end
-- 销毁指定特效以一定时间
function EffectMgr.DestroyById(id)
	this.RealseEffect(id)
	if this.destroyCallbackMap[id] then
		this.destroyCallbackMap[id][1](this.destroyCallbackMap[id][2])
	end
	this.destroyCallbackMap[id] = nil
end
-- 直接释放操作，不执行销毁回调
function EffectMgr.RealseEffect(id)
	local effect = this.map[id]
	if not effect then return end
	this.map[id] = nil
	this.autoDestroyMap[id] = nil
	this.nearPosMap[id] = nil
	this.followMap[id] = nil
	return destroyImmediate(effect)
end
-- 获取特效
function EffectMgr.GetEffectById(id)

	return this.map[id]
end

-- 加载指定 res 特效
function EffectMgr.LoadEffect(res, finishCallback)
	LoadEffect(res, function ( o )
		local e = GameObject.Instantiate(o)
		e.name = res
		finishCallback(e)
	end)
end
function EffectMgr.Update()
	for id,v in pairs(this.autoDestroyMap) do
		if v > 0 then
			this.autoDestroyMap[id] = v - Time.deltaTime
		else
			this.DestroyById(id)
		end
	end
	for id, v in pairs(this.nearPosMap) do -- v:{target, speed, distance, start, catchCallback, param, catchDestroy}
		if this.map[id] then
			local effect = this.map[id]
			local eft = effect.transform
			local curPos = eft.localPosition
			local step = v[2] * Time.deltaTime
			local isPassDistance = v[3] and Vector3.Distance(curPos, v[4]) > v[3] -- 是否超过距离
			
			if not isPassDistance then
				local targetPos = nil
				if type(v[1]) == "table" then
					targetPos = v[1]
				else -- transform
					targetPos = v[1].position
				end
				if Vector3.Distance(curPos, targetPos) > step then
					eft.localPosition = Vector3.MoveTowards(curPos, targetPos, step)
					curPos = eft.localPosition
				else -- 到达目标位置
					if v[5] then -- 回调到达目标位置
						v[5](v[6], id)
						v[5], v[6] = nil, nil
					end
					if v[7] then -- 到达目标时立即销毁
						this.DestroyById(id)
					end
				end
			else 
				if not this.autoDestroyMap[id] then -- 超过 如果没有设置 自动或释放时间则 立即消失
					this.DestroyById(id)
				end
			end
		else
			this.nearPosMap[id] = nil
		end
	end
	for id, v in pairs(this.followMap) do
		if this.map[id] then
			if not pcall(function () this.map[id].transform.localPosition = v.localPosition end) then
				this.map[id] = nil
				logWarn("特效go已经销毁--->"..tostring(id))
			end
		else
			this.RealseEffect(id)
		end
	end
end
-- 缩放粒子
function EffectMgr.Scale( effect, scale )
	if not ToLuaIsNull(effect) and not ToLuaIsNull(effect.gameObject) then
		Util.ScaleParticleSystem(effect.gameObject, scale)
	end
end

-- 三轴缩放粒子
function EffectMgr.SetV3Scale( effectId, scaleV3 )
	local eft = EffectMgr.GetEffectById(effectId)
	if eft then
		eft.transform.localScale = scaleV3
	end
end
-- root 作为父级的transform, bool是否归为引用原局部坐标为当前坐标
function EffectMgr.SetParent( effect, root, bool )
	if not ToLuaIsNull(effect) and root then
		effect.transform:SetParent(root, bool==true)
	end
end
-- 全清除所有特效并重置
function EffectMgr.Reset()
	this._Clear()
	DelayCall(function () this.Init() end, 0.3)
end
-- 清除所有特效
function EffectMgr:_Clear()
	RenderMgr.Remove("__EffectRender")
	this._isClearing = true
	for id,v in pairs(this.map) do
		this.RealseEffect(id)
	end
	this.map = {}
	this.autoDestroyMap = {}
	this.followMap = {}
	this.nearPosMap = {}
end
function EffectMgr:ClearFollowMap()
	for id,v in pairs(this.followMap) do
		this.RealseEffect(id)
	end
	this._isFollowClearing = true
	this.followMap = {}
	DelayCall(function () this._isFollowClearing = false end, 0.3)
end
function EffectMgr._AutoId()
	this.autoId = this.autoId + 1
	return this.autoId
end
function EffectMgr._CreatingEffectId( id )

	return id or this._AutoId()
end
function EffectMgr._Cache(id, effect, keepExisting)
	if this.map[id] then -- print("已经存在相应id特效了->直接可以用这id取得", id)
		if not keepExisting then
			destroyImmediate(this.map[id])
		end
	end
	this.map[id] = effect
end

--------------------------技能----------------------------------------
	--创建技能特效
	--@param effectName 特效名
	--@param target 战斗对象
	--@param liftTime 生命周期
	--@param targetPos 目标点
	--@param scale 缩放
	--@param loadCallBack 加载回调
	function EffectMgr.CreateSkillEffect(effectName, target, liftTime, targetPos, scale, loadCallBack)
		local eftIds = {}
		local autoDestroy = liftTime == nil or liftTime == 0
		if targetPos and scale then --加载到目标点且缩放
			local eftId = EffectMgr.AddToPos(effectName, targetPos, liftTime, nil, autoDestroy, nil, function(eid)
				local effect = EffectMgr.GetEffectById(eid)
				effect.transform.localScale = scale
				if loadCallBack then 
					loadCallBack(eid)
					loadCallBack = nil
				end
			end)
			table.insert(eftIds, eftId)
		elseif targetPos and not scale then --加载到目标点且不缩放
			local eftId = EffectMgr.AddToPos(effectName, targetPos, liftTime, nil, autoDestroy, nil, function(eid)
				local effect = EffectMgr.GetEffectById(eid)
				if loadCallBack then 
					loadCallBack(eid)
					loadCallBack = nil
				end
			end)
			table.insert(eftIds, eftId)
		elseif not targetPos and scale then --加载到目标自身且缩放
			local tf = target.transform
			if ToLuaIsNull(tf) then return eftIds end
			local eftId = EffectMgr.BindTo(effectName, tf.gameObject, liftTime, nil, autoDestroy, nil, function(eid)
				local effect = EffectMgr.GetEffectById(eid)
				effect.transform.localScale = scale and scale or Vector3.New(1, 1, 1)
				if loadCallBack then 
					loadCallBack(eid)
					loadCallBack = nil
				end
			end)
			table.insert(eftIds, eftId)
		else
			local tf = target.transform
			if ToLuaIsNull(tf) then return eftIds end
			local go = tf.gameObject
			eftIds = EffectMgr.SpecialBindToBone(effectName, go, liftTime, loadCallBack)
			if #eftIds < 1 then
		   		local eftId = EffectMgr.BindTo(effectName, go, liftTime, nil, autoDestroy, nil, function(eid)
					if loadCallBack then 
						loadCallBack(eid)
						loadCallBack = nil
					end
		   		end)
		   		table.insert(eftIds, eftId)
			end
		end
		return eftIds
	end

	--创建Buff特效
	--@param effectName 特效名
	--@param target 战斗对象
	--@param liftTime 生命周期
	--@param scale 缩放
	--@param loadCallBack 加载回调
	function EffectMgr.CreateBuffEffect(effectName, target, liftTime, scale, loadCallBack)
		local tar = target.transform.gameObject
		local eftIds = EffectMgr.SpecialBindToBone(effectName, tar, liftTime, loadCallBack)
		if #eftIds < 1 then
			local eftId = EffectMgr.FollowTo(effectName, tar, liftTime, nil, autoDestroy, nil, function(eid)
				if loadCallBack then 
					loadCallBack(eid)
					loadCallBack = nil
				end
			end, scale)
	   		table.insert(eftIds, eftId)
		end
		return eftIds
	end
--

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 场景对象的效果处理 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

--以一定方向距离移动
--param cur 起始位置, direction 缓动方向, dist 缓动距离, time 缓动时间, updateCall 更新回调, finishCallback 结束回调, tweenerType 缓动效果类型 (1:匀速)
function EffectMgr.MoveByDirection(cur, direction, dist, time, updateCall, finishCallback, tweenerType)
	local dist = dist or 0
	local time = time or 0
	local targetPos = cur + direction*dist
	local gx, gy = MapUtil.LocalToGrid(cur)
	if Astar.isBlock(gx, gy) then 
		if finishCallback then
			finishCallback()
			finishCallback = nil
		end
		return
	end

	local moveDis = 0
	local movetarget = nil
	while(moveDis <= dist)
	do
		moveDis = moveDis+0.1
		movetarget = cur + direction*moveDis
		local gx, gy = MapUtil.LocalToGrid(movetarget)
		if Astar.isBlock(gx, gy) then
			if finishCallback then
				finishCallback()
				finishCallback = nil
			end
			break
		end
	end
	targetPos = cur + direction*moveDis
	local doTime = time*(moveDis/dist)
	local tweener = TweenUtils.TweenVector3(cur, targetPos, doTime, updateCall)
	TweenUtils.SetEase(tweener, tweenerType or 1)
	if finishCallback then
		TweenUtils.OnComplete(tweener, finishCallback, tweener)
	end
	return tweener, doTime
end
-- 对场景对象进行动效缩放
function EffectMgr.ScaleObj( obj, scaleV, time)
	TweenUtils.TweenFloat(1, scaleV, time or 0, function ( data )
		if not obj or ToLuaIsNull(obj.transform) then return end
		obj.transform.localScale = Vector3.one * data
	end)
end
-- 受击变色 (闪动变色)
function EffectMgr.HitColor( obj, color, times)
	if not obj then return end
	obj:SetBodyColor(color or Color.New(2,2,2), times )
end
-- 变色(长久) color=nil 重置恢复
function EffectMgr.ChangeColor(obj, color)
	if not obj then return end
	obj:ChangeColor(color)
end

-- 对一个场景对象加载残影效果 bool开启关闭 interval产生影子间隔时间 lifeCycle影子生存时间
function EffectMgr.SetCanying( gameObject, bool, interval, lifeCycle)
	if ToLuaIsNull(gameObject) then return end
	local canying = gameObject:GetComponent("CanYing")
	if not canying then
		canying = gameObject:AddComponent(typeof(CanYing))
	end
	if interval then
		canying.interval = interval or 0.3
	end
	if lifeCycle then
		canying.lifeCycle = lifeCycle or 0.3
	end
	canying.enabled = bool
end
