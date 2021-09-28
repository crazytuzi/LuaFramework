--地面施法
SpGroundAttack =BaseClass(SpBase)
function SpGroundAttack:__init( player, skillVo )
	self._posEft = GameObject.New("SpGroundAttack_"..self._skillVo.un32SkillID)
	self._player = SceneController:GetInstance():GetScene():GetMainPlayer()
	self._targetPoint = self._player.transform.position
	self._scaleDistance = self._skillVo.fReleaseDist / 100

	self._scaleXy = nil
	self.autoDirection = Vector3.zero
	self.autoDistance = 0
end

function SpGroundAttack:__delete()
	self._targetPoint = nil
	self._player = nil
	if self._posEft then
		destroyImmediate(self._posEft)
		self._posEft = nil
	end
end

function SpGroundAttack:Init()
	 EffectMgr.LoadEffect("80004", function(eft) 
	 	if ToLuaIsNull(eft) then return end
	 	if ToLuaIsNull(self._posEft) or ToLuaIsNull(self.eftRoot) then destroyImmediate(eft) return end
	 	local tf = eft.transform
	 	local ptf = self._posEft.transform
	 	tf.localScale = Vector3.New(self._skillVo.previewValue[1]*0.01, 1, self._skillVo.previewValue[1]*0.01)
		tf:SetParent(ptf, false)
		ptf:SetParent(self.eftRoot.transform, false)
	 end)

	SpBase.Init(self)
end

function SpBase:Reset()
	self._scaleXy= nil
	self.autoDirection = Vector3.zero
	self.autoDistance = 0
end

function SpGroundAttack:Update()
	if not self._player or ToLuaIsNull(self._player.transform) then return end
	if self._posEft ~= nil then 
		if self._scaleXy then
			local angle = self.cam.transform.localRotation.eulerAngles.y
			local scaleXy = self._scaleXy * self._scaleDistance

			self._targetPoint.x = scaleXy.x
			self._targetPoint.y = 0
			self._targetPoint.z = scaleXy.y

			local newV = Quaternion.AngleAxis(angle, Vector3.up) * self._targetPoint
			self._targetPoint = self._player.transform.position + newV 

			self._posEft.transform.position = self._targetPoint
		else
			self._targetPoint = self._player.transform.position + self.autoDirection*self.autoDistance
			self._posEft.transform.position = self._targetPoint
		end
	end
	SpBase.Update(self)
end

function SpGroundAttack:GetTargetPoint()
	return self._targetPoint
end

function SpGroundAttack:SetControllPos(xy)
	self._scaleXy = xy
end

--设置绝对偏移
function SpGroundAttack:SetAutoSelect(direct, distance)
	 self.autoDirection = direct
	 self.autoDistance = distance
end
