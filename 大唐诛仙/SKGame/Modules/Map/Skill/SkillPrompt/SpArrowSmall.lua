--窄箭头
SpArrowSmall =BaseClass(SpBase)
function SpArrowSmall:__init( player, skillVo )
	self._angle = 0
	self._dir = 0

	self._dirEffect = GameObject.New("SpArrowSmall_"..self._skillVo.un32SkillID)

	self._railEff = nil
	self.railEffId = nil
	
	self._isDirShow = false
	self.scale = self._skillVo.fReleaseDist *0.01
	self.isShowScale = false
	self.ballisticEftId = nil

	if self.scale > 6 then
		self.showBaseEft = false
	end
end

function SpArrowSmall:__delete()
	self._isDirShow = false
	self.isShowScale = false
	self._railEff = nil
	if self._dirEffect then
		destroyImmediate(self._dirEffect)
		self._dirEffect = nil
	end

  	if self.railEffId then
		EffectMgr.RealseEffect(self.railEffId)
		self.railEffId = nil
	end

  	if self.ballisticEftId then
		EffectMgr.RealseEffect(self.ballisticEftId)
		self.ballisticEftId = nil
	end
end

function SpArrowSmall:Init()
	 EffectMgr.LoadEffect("aim_blue_8", function(eft8)
	 	if ToLuaIsNull(eft8) then return end
	 	if ToLuaIsNull(self._dirEffect ) or ToLuaIsNull(self.eftRoot) then destroyImmediate(eft8) return end
	 	local etf = eft8.transform
	 	local dtf = self._dirEffect.transform

	 	etf.localScale = Vector3.New(1, 1, self.scale - 0.9)
	 	etf:SetParent(dtf, false)

 	 	EffectMgr.LoadEffect("aim_blue_7", function(eft7)
 	 		if ToLuaIsNull(eft7) then return end
 	 		if ToLuaIsNull(self._dirEffect ) or ToLuaIsNull(self.eftRoot ) then destroyImmediate(eft7) return end
 	 		local pos = Vector3.New(0,0,1) * self.scale - Vector3.New(0,0,1)
 			etf= eft7.transform
 	 		etf:SetParent(dtf, false)
 	 		etf.localPosition = pos

 	 		dtf:SetParent(self.eftRoot.transform, false)
 	 	end)
	end)
	SpBase.Init(self)
end

function SpArrowSmall:Update()
	self:UpdateDir()
end

function SpArrowSmall:UpdateDir()
	if self._dirEffect ~= nil then 
		self._dir = self._angle + self.cam.transform.localRotation.eulerAngles.y
		self._dirEffect.transform.rotation = Quaternion.Euler(0, self._dir, 0)
	end
end

function SpArrowSmall:GetDir()
	return self._dir
end

function SpArrowSmall:SetAngle(values)
	self._angle = values
end

