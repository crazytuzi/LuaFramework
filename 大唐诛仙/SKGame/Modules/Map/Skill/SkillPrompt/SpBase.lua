--技能辅助特效基类(圆)
SpBase =BaseClass()
function SpBase:__init( player, skillVo )
	self.aimBlueType = "aim_blue_1"
	self.baseTye = "aim_blue_1"
	self.aimBlueTypeReplace = nil

	self.cam = Camera.main
	self._player = player
	self._skillVo = skillVo
	self._baseEffectId = nil
	self._effectList = {}
	self.isShowing = false

	self.eftRoot = GameObject.New("skillPreRoot"..self._skillVo.un32SkillID)
	self.eftRoot.transform:SetParent(self._player.transform, false)

	self.showBaseEft = true
end

function SpBase:__delete()
	self.aimBlueType = nil
	self.baseTye = nil
	self.aimBlueTypeReplace = nil

	self.cam = nil
	self._player = nil
	self._skillVo = nil
	self._baseEffectId = nil
	self._effectList = nil
	self.isShowing = nil
	
	if self.eftRoot then
		destroyImmediate(self.eftRoot)
	end
	self.eftRoot= nil
	self._effectList = nil
end

function SpBase:Init()
	if self.showBaseEft then
		local loadType = self.baseTye
		if self.aimBlueTypeReplace then loadType = self.aimBlueTypeReplace end
		EffectMgr.LoadEffect(loadType, function(eft)
				if ToLuaIsNull(eft) then return end
				if ToLuaIsNull(self.eftRoot) or ToLuaIsNull(self.eftRoot.transform) then
					destroyImmediate(eft)
					return
				end

			 	eft.name = "baseEft"
				local scale = self._skillVo.fReleaseDist *0.01
				scale = scale == 0 and 1 or scale
				local tf=eft.transform
			 	tf.localScale = Vector3.New(scale, 1, scale)
			 	tf:SetParent(self.eftRoot.transform, false)
		end)
	end

	self:Hide()
end

function SpBase:GetId()
	return self._skillVo.un32SkillID
end

function SpBase:GetDir()
	return nil
end

function SpBase:GetTargetPoint()
	return nil
end

function SpBase:Show()
	if not self.eftRoot then return end
	self.eftRoot:SetActive(true) 
	self.isShowing = true
end

function SpBase:Hide()
	if not self.eftRoot then return end
	self.eftRoot:SetActive(false) 
	self.isShowing = false
end

function SpBase:Reset()
end

function SpBase:Update()
	
end

function SpBase.GenerateSkillPromptBySkillVo(skillVo)
	local skillPrompt
	if skillVo ~= nil then
		local mainPlayer = SceneController:GetInstance():GetScene():GetMainPlayer()
		local previewType = skillVo.previewType
		if previewType == PreviewType.Nothing then 	--无

		elseif previewType == PreviewType.RangeSector360 then --圆
			skillPrompt = SpRangeSector360.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.RangeSector60 then --范围扇形60°
			skillPrompt = SpRangeSector60.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.RangeSector90 then --范围扇形90°
			skillPrompt = SpRangeSector90.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.RangeSector180 then --范围扇形180°
			skillPrompt = SpRangeSector180.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.GroundAttack then --地面施法
			skillPrompt = SpGroundAttack.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.ArrowSmall then --窄箭头
			skillPrompt = SpArrowSmall.New(mainPlayer, skillVo)
		
		elseif previewType == PreviewType.PointToRangeSector60 then --指向扇形aoe(60°)
			skillPrompt = SpPointToRangeSector60.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.PointToRangeSector90 then --指向扇形aoe(90°)
			skillPrompt = SpPointToRangeSector90.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.PointToRangeSector180 then --指向扇形aoe(180°)
			skillPrompt = SpPointToRangeSector180.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.PointToCenterSector90 then --指向扇形中心线单选(90°)
			skillPrompt = SpPointToCenterSector90.New(mainPlayer, skillVo)

		elseif previewType == PreviewType.ArrowBig then --宽箭头
			skillPrompt = SpArrowBig.New(mainPlayer, skillVo)
		end
	end
	return skillPrompt
end
