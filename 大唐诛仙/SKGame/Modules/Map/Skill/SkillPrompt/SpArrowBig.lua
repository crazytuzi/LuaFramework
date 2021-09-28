--窄箭头
SpArrowBig =BaseClass(SpBase)
function SpArrowBig:__init( player, skillVo )
	self._angle = 0
	self._dir = 0

	self._dirEffect = GameObject.New("SpArrowBig_"..self._skillVo.un32SkillID)

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

function SpArrowBig:__delete()
	self._angle = 0
	self.effectAngle = nil
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

function SpArrowBig:Init()
	EffectMgr.LoadEffect("aim_blue_9", function(eft9)
			if ToLuaIsNull(eft9) then return end
			if ToLuaIsNull(self._dirEffect ) or ToLuaIsNull(self.eftRoot) then destroyImmediate(eft9) return end
			local eft = eft9.transform
			eft.localScale = Vector3.New(self._skillVo.previewValue[1] *0.01, 1, self._skillVo.previewValue[2] *0.01)
			local dft = self._dirEffect.transform
			eft:SetParent(dft, false)
			dft:SetParent(self.eftRoot.transform, false)
		end)
	SpBase.Init(self)
end

function SpArrowBig:Update()
	self:UpdateDir()
end

function SpArrowBig:UpdateDir()
	if self._dirEffect ~= nil then 
		self._dir = self._angle + self.cam.transform.localRotation.eulerAngles.y
		self._dirEffect.transform.rotation = Quaternion.Euler(0, self._dir, 0)
	end
end

function SpArrowBig:GetDir()
	return self._dir
end

function SpArrowBig:SetAngle(values)
	self._angle = values
end

