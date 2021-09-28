SoulMgr = {}
local this = SoulMgr
function SoulMgr.Init()
	this.mainAnimator = nil -- 主角动作器
	this.tfMap = {} -- transform
	this.aniMap = {}
	this.luaObjMap = {}
	this.lockMap = {} -- key:animator
	-- this.keyMap = {}
	-- RenderMgr.Add(function () this.Update() end, "__SoulMgrRender")
end
-- 定时器上的控制检测
	-- function SoulMgr.Update()
	-- end
-- 主角动作器
	function MotionMgr.SetMainAnimator( mainAnimator )

		this.mainAnimator = mainAnimator
	end
-- key:场景对象中的guid或id或直接对象本身
	function SoulMgr.Add(key, gameObject, luaObject)
		if gameObject then
			this.tfMap[key] = gameObject.transform
			-- this.keyMap[gameObject] = key
			local animator = gameObject:GetComponent("Animator")  -- 动作控制器
			if animator then
				this.aniMap[key] = animator
				-- this.keyMap[animator] = key
			end
		end
		if luaObject then
			this.luaObjMap[key] = luaObject
			-- this.keyMap[luaObject] = key
		end
	end
-- 播放 v: key or animator
	-- 一直运行到最后不能重置动作
	function SoulMgr.Play(v, action)
		if action and this.aniMap[v] then
			if this.aniMap[v] then
				local animator = this.aniMap[v]
				if not this.IsNameAndLoop(animator, action) then
					animator:Play(action)
				end
			elseif type(v) == "userdata" then
				if not this.IsNameAndLoop(v, action) then
					v:Play(action)
				end
			end
		end
	end
	-- 一直运行到最后可中途重置动作
	function SoulMgr.DoPlay(v, action, normalizedTime)
		if action and this.aniMap[v] then
			if this.aniMap[v] then
				local animator = this.aniMap[v]
				if not this.IsNameAndLoop(animator, action) then
					animator:CrossFade(action, 0.08, 0, normalizedTime or 0)
				end
			elseif type(v) == "userdata" then
				if not this.IsNameAndLoop(v, action) then
					v:CrossFade(action, 0.08, 0, normalizedTime or 0)
				end
			end
		end
	end
	-- 一直运行到最后不能重置动作
	function SoulMgr.CrossPlay(v, action)
		if action then
			if this.aniMap[v] then
				local animator = this.aniMap[v]
				if not this.IsNameAndLoop(animator, action) then
					animator:CrossFade(action, 0.08)
				end
			elseif type(v) == "userdata" then
				if not this.IsNameAndLoop(v, action) then
					v:CrossFade(action, 0.08)
				end
			end
		end
	end
	--[[ 应该用不到
		function SoulMgr.PlayId(key, actId)
			local action = BehaviourMgr.GetActionName( actId )
			this.Play(key, action)
		end
		function SoulMgr.CrossPlayId(key, actId)
			local action = BehaviourMgr.GetActionName( actId )
			this.CrossPlay(key, action)
		end
		function SoulMgr.Play(key, action, normalizedTime)
			if action and this.aniMap[key] then
				local animator = this.aniMap[key]
				-- if normalizedTime then
				-- 	animator:Play(action, 0, normalizedTime)
				-- else
				-- 	animator:Play(action)
				-- end
			end
		end
		function SoulMgr.CrossPlay(key, action, normalizedTime)
			if action and this.aniMap[key] then
				local animator = this.aniMap[key]
				if normalizedTime then
					animator:CrossFade(action, 0.08, 0, normalizedTime)
				else
					animator:CrossFade(action, 0.08)
				end
			end
		end
	]]
-- 剪辑信息 v: key or animator
	function SoulMgr.GetCurStateInfo(v)
		if not v then return nil end
		local info = nil
		if this.aniMap[v] then
			info = this.aniMap[v]:GetCurrentAnimatorStateInfo(0)
		elseif type(v) == "userdata" then
			info = v:GetCurrentAnimatorStateInfo(0)
		end
		return info
	end
	function SoulMgr.IsName(v, act) -- act 动作名
		if not act then return false end
		local info = this.GetCurStateInfo(v)
		return act and info and info:IsName(act)
	end
	function SoulMgr.IsNameAndLoop(v, act) -- 判断与相同动作且循环
		if not act then return false end
		local info = this.GetCurStateInfo(v)
		return info and info.loop and info:IsName(act)
	end
	function SoulMgr.GetNormalTime(v)
		local info = this.GetCurStateInfo(v)
		return info and info.normalizedTime or 0
	end
	--[[ 应该用不到
		function SoulMgr.GetCurClipInfo(v)
			if not v then return end
			local info = nil
			if this.aniMap[v] then
				info = this.aniMap[v]:GetCurrentAnimatorClipInfo(0)[0]
			elseif type(v) == "userdata" then
				info = v:GetCurrentAnimatorClipInfo(0)[0]
			end
			return info
		end
		function SoulMgr.GetCurClipName(v)
			if not v then return end
			local clipInfo = this.GetCurClipInfo(v)
			return clipInfo and clipInfo.clip.name or ""
		end
	]]
-- 销毁
	function SoulMgr.Remove(key)
		-- RenderMgr.Realse("__SoulMgrRender")
		-- if this.tfMap[key] then
		-- 	this.keyMap[this.tfMap[key]] = nil
		-- end
		this.tfMap[key] = nil

		-- if this.aniMap[key] then
		-- 	this.keyMap[this.aniMap[key]] = nil
		-- end
		this.aniMap[key] = nil

		-- if this.luaObjMap[key] then
		-- 	this.keyMap[this.luaObjMap[key]] = nil
		-- end
		this.luaObjMap[key] = nil
	end