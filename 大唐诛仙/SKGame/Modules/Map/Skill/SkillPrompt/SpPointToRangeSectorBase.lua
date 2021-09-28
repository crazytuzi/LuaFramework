--指向扇形180°
SpPointToRangeSectorBase =BaseClass(SpBase)

function SpPointToRangeSectorBase:__init( player, skillVo)
	self._angle = 0
	self._dir = 0
	self._dirEffect = GameObject.New("SpPointToRangeSectorBase_"..self._skillVo.un32SkillID)
	self._pointToEftId = nil
	self._isDirShow = false
end

function SpPointToRangeSectorBase:__delete()
	if self._dirEffect then
		destroyImmediate(self._dirEffect)
		self._dirEffect = nil
	end
	self._pointToEftId = nil
end

function SpPointToRangeSectorBase:Init()
	EffectMgr.LoadEffect(self.aimBlueType, function(eft)
		if ToLuaIsNull(self._dirEffect) or ToLuaIsNull(self.eftRoot) then destroyImmediate(eft) return end
		local scale = self._skillVo.fReleaseDist *0.01
		scale = scale == 0 and 1 or scale
		local tf = eft.transform
		local dtf = self._dirEffect.transform
	 	tf.localScale = Vector3.New(scale, 0, scale)
	 	tf:SetParent(dtf, false)
	 	self:UpdateDir() --生成特效马上更新一次转向
	 	dtf:SetParent(self.eftRoot.transform, false)
	end)

  	SpBase.Init(self)
end

function SpPointToRangeSectorBase:Show()
	SpBase.Show(self)
end

function SpPointToRangeSectorBase:Update()
	self:UpdateDir()
	SpBase.Update(self)
end

function SpPointToRangeSectorBase:UpdateDir()
	if self._dirEffect and self.cam then 
		self._dir = self._angle + self.cam.transform.localRotation.eulerAngles.y
		self._dirEffect.transform.rotation = Quaternion.Euler(0, self._dir, 0)
	end
end

function SpPointToRangeSectorBase:GetDir()
	return self._dir
end

function SpPointToRangeSectorBase:SetAngle(values)
	self._angle = values
end