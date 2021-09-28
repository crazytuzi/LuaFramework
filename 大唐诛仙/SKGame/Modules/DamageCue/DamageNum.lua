DamageNum =BaseClass(LuaUI)
function DamageNum:__init( parent )
	self.isSleep = false
	self.worldScale = 1.2
	if not resMgr:AddUIAB("DamageCue") then return end
	local damageItem = UIPackage.CreateObject("DamageCue","DamageNum")
	damageItem.visible = false
	parent:AddChild(damageItem)
	self._go = damageItem.displayObject.gameObject
	local tf = self._go.transform
	-- self.transform=tf
	self.damageItem = damageItem
	tf.localPosition = Vector3.one*-1000
	tf.localScale = Vector3.one
	self.title = damageItem:GetChildAt(0) 
	self.type_ = 0   --1:表示其他形式，2表示是加血，加血时候血条不放大

	self._target = nil
	self._source = nil
	self.hetghtOffSet = 1.5
	self.xOffset = 120

	self.cam = Camera.main
end

function DamageNum:SetTargetSoure(tartget, source)
	self._target = tartget
	self._source = source 
end

--显示伤害
function DamageNum:ShowDamage(damage, fType)
	self:WakeUp()
	local tf = self.title.textFormat
	tf.font = self:GetFontUrl(fType)
	self.title.textFormat = tf
	self.title.alpha = 1
	self.title.text = damage
end

local word1 = UIPackage.GetItemURL("Common", "num_MonsterDamageFont")
local word2 = UIPackage.GetItemURL("Common", "num_PlayerDamageFont")
local word3 = UIPackage.GetItemURL("Common", "num_AddHpFont")
local word4 = UIPackage.GetItemURL("Common", "num_CritFont")
local word5 = UIPackage.GetItemURL("Common", "num_FightOtherFont")

--获取font
function DamageNum:GetFontUrl(fType)
	local fonts
	if fType == FontType.MonsterDamageFont then
		fonts = word1
		self.type_ = 1
	elseif fType == FontType.PlayerDamageFont then
		fonts = word2
		self.type_ = 1
	elseif fType == FontType.AddHpFont then
		fonts = word3
		self.type_ = 2
	elseif fType == FontType.CritFont then
		fonts = word4
	elseif fType == FontType.FightOtherFont then
		fonts = word5
		self.type_ = 1
	end
	return fonts
end
--开启缓动
function DamageNum:StartEffect()
	if self._source == nil or self._target == nil or ToLuaIsNull(self.cam) or ToLuaIsNull(self._source.transform) or ToLuaIsNull(self._target.transform) then
		return
	end
	local srcTf = self._source.transform
	local tarTf = self._target.transform
	self.step = 0
	self.isStar = true
	self.step1Time = 0.1
	self.step2Time = 0.2
	self.step3delay = 0.0
	self.step3Time = 0
	self.initviewp = self.cam:WorldToViewportPoint(srcTf.position + srcTf.up*self.hetghtOffSet)
	self.initViewportPoint = self.cam:WorldToViewportPoint(tarTf.position + tarTf.up*self.hetghtOffSet)
	RenderMgr.Realse(self.render)
	self.render = RenderMgr.Add(function() self:Update() end)
end
--缓动效果，用Tween比较吃性能，
function DamageNum:Update()	
	if not self.isStar then return end
		local viewportPoint = self.initViewportPoint
		local offsetDirect = ( self.initviewp.x - viewportPoint.x)
		self.damageItem.visible = true
		self.damageItem:SetXY(layerMgr.WIDTH*viewportPoint.x + offsetDirect*self.xOffset, layerMgr.HEIGHT - layerMgr.HEIGHT*viewportPoint.y)
	if ToLuaIsNull(self._go) or ToLuaIsNull(self._go.transform) then
		self:Over()
		return
	end
	local goTf = self._go.transform
	local pos = goTf.localPosition
	local dt = Time.deltaTime
	--出来时候停止0.1秒。再执行
	if self.step == 0 then 
		local scale = 1.2
		if self.type_ == 2 then
			scale = 1.2
		else
			scale = 2.5
		end
		self.step1scale = Vector3(self.worldScale * scale, self.worldScale * scale, 1)
		self.step1pos = pos
		self.step2scale = Vector3(self.worldScale, self.worldScale, self.worldScale)
		self.step = 1
		return
	elseif self.step == 1 then
		if self.step1Time >= 0 then
			goTf.localScale = Vector3.Lerp(goTf.localScale, self.step1scale, 0.2)
			pos = Vector3.Lerp(pos, self.step1pos, 0.3)
			self.step1pos = Vector3(pos.x - 0, pos.y + 20, pos.z)		
			self.step1Time = self.step1Time - dt
			if self.step1Time <= 0 then
				self.step = self.step + 1
			end
			goTf.localPosition = pos
		end
	elseif self.step == 2 then
		if self.step2Time >= 0 then
			goTf.localScale = Vector3.Lerp(goTf.localScale, self.step2scale*0.8, 0.2)
			self.step2Time = self.step2Time - dt
			if self.step2Time <= 0 then
				self.step = self.step + 1
			end
		end
	elseif self.step == 3 then
		if self.step3Time >= 0 then
			self.step3delay = self.step3delay - dt
			if self.step3delay <= 0 then
				self.step3pos = Vector3(pos.x, pos.y + 100, pos.z + 0.2)
				self.step3Time = 0.6
				self.step = self.step + 1
			end
		end
	elseif self.step == 4 then
		if self.step3Time >= 0 then
			goTf.localPosition = Vector3.Lerp(pos, self.step3pos, 0.1)
			self.step3Time = self.step3Time - dt
			if self.step3Time >= 0.1 then
				--self.title.alpha = math.max(self.title.alpha - dt * 0.001, 0)
			else
				self.title.alpha = math.max(self.title.alpha - dt * 8, 0) 
			end
			if self.step3Time <= 0 then
				self:Over()
			end
		end
	end
end
--结束入队
function DamageNum:Over()
	RenderMgr.Realse(self.render)
	self:Sleep()
	table.insert(DamageCueUiEdition:GetInstance().itemPools, self)
end
--唤醒
function DamageNum:WakeUp()
	if self.isSleep then
		self.isSleep = false
		self.cam = Camera.main
		-- self._go:SetActive(true)
		GlobalDispatcher:RemoveEventListener(self.handler)
		self.handler = GlobalDispatcher:AddEventListener(EventName.UNLOAD_SCENE,function ()
			self:Over()
		end)
	end
end
--休眠
function DamageNum:Sleep()
	if not self.isSleep then
		self.cam = nil
		self.isSleep = true
		self.damageItem.position = Vector3.one*-1000
		-- self._go:SetActive(false)
		-- self.transform.localPosition = Vector3.one*-1000
		GlobalDispatcher:RemoveEventListener(self.handler)
		self.isStar = false
	end
end

function DamageNum:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler)
	RenderMgr.Realse(self.render)
	self._go = nil
	self._source = nil
	self.title = nil
	self._target = nil
	self._source = nil
	self.initviewp = nil
	self.initViewportPoint = nil
	self.cam=nil
end