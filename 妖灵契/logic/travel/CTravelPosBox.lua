--[[
	游历位置box
	用于：
		1.自己游历的四个位置
		2.自己游历的特殊位置
		3.好友游历的四个位置
		4.好友游历的特殊位置
]]
local CTravelPosBox = class("CTravelPosBox", CBox)

function CTravelPosBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ActorTexture = self:NewUI(2, CActorTexture)
	self.m_DuiHuaLabel = self:NewUI(3, CLabel)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_WidgetObj = self:NewUI(5, CWidget)
	self.m_ShadowSprite = self:NewUI(6, CSprite)
	self.m_CloseBtn = self:NewUI(7, CButton, false)
	self.m_LabelTips = self:NewUI(8, CLabel, false)
	self.m_DuiHuaLabel:SetActive(false)
	self.m_ShadowSprite:SetActive(false)
	self.m_NameLabel:SetText("")
	self.m_Depth = self.m_ActorTexture:GetDepth()
end

function CTravelPosBox.SetPathIdx(self, idx)
	self.m_PathIdx = idx
end

function CTravelPosBox.SetCanMove(self, isCanMove)
	self.m_IsCanMove = isCanMove
end

function CTravelPosBox.GetParid(self)
	return self.m_Parid
end

function CTravelPosBox.RefreshPosBox(self, parinfo)
	if parinfo and parinfo.parid and parinfo.parid > 0 then
		self.m_Parid = parinfo.parid
		self.m_NameLabel:SetText(parinfo.par_name)
		self.m_ShadowSprite:SetActive(true)
		self.m_ActorTexture:SetActive(true)
		self.m_ActorTexture:ChangeTravelShape(parinfo.par_model.shape, {},
			function () 
				local oDisplayTexture = self.m_ActorTexture:GetDisplayTexture()
				if oDisplayTexture then
					oDisplayTexture:SetColor(Color.white)
					local anim = "idleCity"
					local euler = Quaternion.Euler(0, 180, 0)
					self.m_ActorTexture:PlayAni(anim, true)
					self.m_ActorTexture:SetActorRotation(euler)
				end
				self:CheckMove()
			end)
	else
		self.m_Parid = nil
		self.m_NameLabel:SetText("")
		self.m_ShadowSprite:SetActive(false)
		self.m_ActorTexture:SetActive(false)
		self:CheckMove()
	end
end

function CTravelPosBox.AutoUpdateDepth(self, bAuto)
	if self.m_DepthTimer then
		Utils.DelTimer(self.m_DepthTimer)
		self.m_DepthTimer = nil 
	end
	if bAuto then
		local function auto()
			if Utils.IsNil(self) then
				return
			end
			local pos = self:GetLocalPos()
			self.m_ActorTexture:SetDepth(1000 + pos.y)
			return true
		end
		self.m_DepthTimer = Utils.AddTimer(auto, 0.1, 0.1)
	else
		self.m_ActorTexture:SetDepth(self.m_Depth)
	end
end

function CTravelPosBox.CheckMove(self)
	if self.m_CheckMoveTimer then
		Utils.DelTimer(self.m_CheckMoveTimer)
		self.m_CheckMoveTimer = nil
	end
	if not self.m_PathIdx or not self.m_IsCanMove then
		if self.m_Start then
			self:StopMove()
		end
		return
	end
	self.m_NameLabel:SetText("")
	local function delay()
		if self.m_Parid then
			self.m_Paths = data.traveldata.TRAVEL_PATH[self.m_PathIdx]
			self.m_Start = 1
			self.m_End = #self.m_Paths.path
			self:AutoUpdateDepth(true)
			self:StartMove()
		end
	end
	self.m_CheckMoveTimer = Utils.AddTimer(delay, 0.5, 0.5)
end

function CTravelPosBox.StartMove(self)
	if Utils.IsNil(self) then
		return
	end
	local ipath = self.m_Paths.path[self.m_Start]
	local config = data.traveldata.TRAVEL_PATH_CONFIG[ipath]
	local start_pos = Vector3.New(config.start_pos.x, config.start_pos.y, 0)
	local end_pos = Vector3.New(config.end_pos.x, config.end_pos.y, 0)
	self:SetLocalPos(start_pos)
	local tween = DOTween.DOLocalMove(self.m_Transform, end_pos, config.time)
	self.m_ActorTexture:SetRotateXYZ(config.rotate)
	self.m_ActorTexture:PlayAni("run", true)
	DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
	DOTween.OnComplete(tween, callback(self, "MoveComplete", config))
end

function CTravelPosBox.MoveComplete(self, config)
	local function keepmove()
		self.m_Start = self.m_Start + 1
		if self.m_Start > self.m_End then
			self.m_Start = 1
		end
		self:StartMove()
	end
	if self.m_MoveTimer then
		Utils.DelTimer(self.m_MoveTimer)
		self.m_MoveTimer = nil
	end
	self.m_ActorTexture:PlayAni(config.anim, config.loop)
	self.m_MoveTimer = Utils.AddTimer(keepmove, config.wait, config.wait)
end

function CTravelPosBox.StopMove(self)
	DOTween.DOKill(self.m_Transform, false)
	self:AutoUpdateDepth(false)
	if self.m_MoveTimer then
		Utils.DelTimer(self.m_MoveTimer)
		self.m_MoveTimer = nil
		self.m_Start = nil
	end
end

return CTravelPosBox