local CTreasureDescView = class("CTreasureDescView", CViewBase)

CTreasureDescView.STATE = {
	NOT = 1,
	NEAR = 2,
	HERE = 3,
}

function CTreasureDescView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasureDescView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = nil
	self.m_BehindStrike = true
end

function CTreasureDescView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_PoinerSprite = self:NewUI(2, CSprite)
	self.m_TwinkleSprite = self:NewUI(3, CSprite)
	self.m_DistanceLabel = self:NewUI(4, CLabel)
	self.m_DescLabel = self:NewUI(5, CLabel)
	self.m_ProgressBar = self:NewUI(6, CSlider)
	self.m_ActionSrptie = self:NewUI(7, CSprite)
	self:InitContent()
end

function CTreasureDescView.InitContent(self)
	self.m_TweenAlpha = self.m_TwinkleSprite:GetComponent(classtype.TweenAlpha)
	self.m_TweenAlpha.enabled = false
	self.m_TwinkleSprite:SetActive(false)
	self.m_PoinerSprite:SetActive(false)
	self.m_DistanceLabel:SetText("")
	self.m_ProgressBar:SetValue(1)
	self.m_ActionSrptie:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ActionSrptie:AddUIEvent("click", callback(self, "OnAction"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamEvent"))
	g_DialogueCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDialogueEvent"))
end

function CTreasureDescView.OnTeamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.AddTeam then
		self:CloseView()
	end
end

function CTreasureDescView.OnDialogueEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dialogue.Event.HideAllViews then
		self:CloseView()
	end
end

function CTreasureDescView.RefreshDesc(self, itemid)
	self.m_ItemID = itemid
	local angle, distance, mapID, state
	local bAct = self.m_PoinerSprite:GetActive()
	local function update()
		if Utils.IsNil(self) then
			self.m_UpdateTimer = nil
			return
		end
		angle, distance, mapID, state = self:GetInstructions()
		if mapID and g_MapCtrl:GetMapID() ~= mapID then
			self:CloseView()
			return false
		end
		self.m_PoinerSprite:SetLocalRotation(Quaternion.Euler(0,0,angle))
		if not bAct then
			self.m_PoinerSprite:SetActive(true)
			bAct = true
		end
		self.m_DistanceLabel:SetText(string.format("%d 米", distance))
	 	
	 	if self.m_State == state and state ~= CTreasureDescView.STATE.HERE then
			return true 
		end
		self.m_State = state
		if state == CTreasureDescView.STATE.NOT then
			self.m_DescLabel:SetText(data.treasuredata.FARDESC)
			self.m_ActionSrptie:SetActive(false)
			self:Open(false, false)
		elseif state == CTreasureDescView.STATE.NEAR then
			self.m_DescLabel:SetText(data.treasuredata.NEARDESC)
			self.m_ActionSrptie:SetActive(false)
			self:Open(true, true)
		elseif state == CTreasureDescView.STATE.HERE then
			self.m_DescLabel:SetText(data.treasuredata.HEREDESC)
			self.m_ActionSrptie:SetActive(true)
			self:Open(true, false)
		end
		return true
	end
	self.m_UpdateTimer = Utils.AddTimer(update, 0.1, 0.1) 
end

--获取宝图路线指示
function CTreasureDescView.GetInstructions(self)
	local oHero = g_MapCtrl:GetHero()
	if not oHero then
		self:CloseView()
		return 0, 0, 0, 0
	end 
	local oHeroPos = oHero:GetPos()
	local itemInfo = g_ItemCtrl:GetItem(self.m_ItemID)
	local treasureinfo = itemInfo:GetValue("treasure_info")
	local mapID = treasureinfo.treasure_mapid
	local targetPos = Vector3.New(treasureinfo.treasure_posx, treasureinfo.treasure_posy, oHeroPos.z)
	local dir = targetPos - oHeroPos
	local angle = Vector3.Angle(oHero:GetUp(), dir)
	if dir.x >= 0 then
		angle = 0 - angle
	elseif dir.x < 0 then
		angle = angle
	end
	local distance = Vector3.Distance(oHeroPos, targetPos) * 3
	distance = math.floor(distance)
	local state
	if distance > 50 then
		state = CTreasureDescView.STATE.NOT
	elseif distance >= 5 and distance <=50 then
		state = CTreasureDescView.STATE.NEAR
	elseif distance < 5 then
		state = CTreasureDescView.STATE.HERE
	end
	return angle, distance, mapID, state
end

function CTreasureDescView.Open(self, bSprite, bTween)
	self.m_TwinkleSprite:SetActive(bSprite)
	self.m_TweenAlpha.enabled = bTween
	if not bTween then
		self.m_TwinkleSprite:SetColor(Color.New( 255/255, 255/255, 255/255, 255/255))
	end
end

function CTreasureDescView.OnAction(self, obj)
	local itemid = self.m_ItemID
	local targetId = g_AttrCtrl.pid
	g_ItemCtrl:C2GSItemUse(itemid, targetId, 1)
	self:CloseView()
end

return CTreasureDescView