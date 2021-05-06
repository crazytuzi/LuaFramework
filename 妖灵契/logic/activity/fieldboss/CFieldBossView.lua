local CFieldBossView = class("CFieldBossView", CViewBase)

function CFieldBossView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/fieldboss/FieldBossView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	self.m_OpenEffect = "Scale"
	self.m_SwitchSceneClose = true
end

function CFieldBossView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BorderTexture = self:NewUI(2, CTexture)
	self.m_MainTexture = self:NewUI(3, CTexture)
	self.m_FightBtn = self:NewUI(4, CButton)
	
	self.m_ItemGrid = self:NewUI(6, CGrid)
	self.m_ItemBox = self:NewUI(7, CItemTipsBox)
	self.m_Slider = self:NewUI(8, CSlider)
	self.m_TimeLabel = self:NewUI(9, CLabel)
	self.m_TipBtn = self:NewUI(10, CButton)
	self.m_HpLabel = self:NewUI(11, CLabel)
	self.m_BoxList = {}
	for i = 1, 3 do
		local box = self:NewUI(10+i, CBox)
		box.m_ShowSpr = box:NewUI(1, CSprite)
		self.m_BoxList[i] = box
		box:SetGroup(self.m_BoxList[1]:GetInstanceID())
	end
	
	self.m_MapTexture = self:NewUI(14, CTexture)
	self.m_NextTexture = self:NewUI(15, CTexture)
	self.m_HpLabel = self:NewUI(16, CLabel)
	self:InitContent()
end

function CFieldBossView.InitContent(self)
	self.m_ItemBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnFightBoss"))
	self.m_TipBtn:AddHelpTipClick("field_boss")
	for i, box in ipairs(self.m_BoxList) do
		box:AddUIEvent("click", callback(self, "OnClickBossBox", i))
	end
end

function CFieldBossView.UpdateBoss(self, bossList)
	for _, oBoss in ipairs(bossList) do
		local bossid = oBoss.id
		local status = oBoss.status
		if status == 2 then
			self.m_BoxList[bossid].m_ShowSpr:SetActive(true)
		else
			self.m_BoxList[bossid].m_ShowSpr:SetActive(false)
		end
	end
	self:OnClickBossBox(1)
	self.m_BoxList[1]:SetSelected(true)
end

function CFieldBossView.UpdateBossDetail(self, bossData)
	self.m_BossID = bossData.bossid
	printc("UpdateBossDetail,",bossData.status, bossData.left_time)
	if bossData.status == 2 then
		self.m_Slider:SetActive(true)
		local pecent = bossData.hpinfo.hp/bossData.hpinfo.maxhp
		self.m_Slider:SetValue(pecent)
		if pecent < 0.3 then
			self.m_HpLabel:SetText(string.format("%d/%d#R(%.2f%%)", bossData.hpinfo.hp, bossData.hpinfo.maxhp, pecent*100))
		else
			self.m_HpLabel:SetText(string.format("%d/%d(%.2f%%)", bossData.hpinfo.hp, bossData.hpinfo.maxhp, pecent*100))
		end
		self.m_FightBtn:SetActive(true)
		self:UpdateLeftTime()
		self:UpdateMapLabel(bossData.bossid)
	else
		self.m_Slider:SetActive(false)
		self.m_FightBtn:SetActive(false)
		self:UpdateLeftTime(bossData.left_time)
		self:UpdateMapLabel()
	end
	self.m_MainTexture:LoadPath(string.format("Texture/FieldBoss/bg_ywboss_%d.png", self.m_BossID), function()
		self.m_MainTexture:SetActive(true)
	end)
	self.m_BorderTexture:LoadPath(string.format("Texture/FieldBoss/bg_duibaikuang_%d.png", self.m_BossID), function()
		self.m_BorderTexture:SetActive(true)
	end)
	self:UpdateBossReward(self.m_BossID)
end

function CFieldBossView.UpdateBossReward(self, bossid)
	local bd, nd = g_FieldBossCtrl:GetBossData(bossid)
	local rewardstr = bd["rewarditem"]
	local rewardList = string.split(rewardstr, "|")
	self.m_ItemGrid:Clear()
	for _, sItem in ipairs(rewardList) do
		local box = self.m_ItemBox:Clone()
		box:SetActive(true)
		box:SetItemData(tonumber(sItem), 1, nil, {isLocal=true})
		self.m_ItemGrid:AddChild(box)
	end
	self.m_ItemGrid:Reposition()
end

function CFieldBossView.UpdateMapLabel(self, bossid)
	if bossid then
		self.m_MapTexture:LoadPath(string.format("Texture/FieldBoss/bg_ywmap_%d.png", bossid), function()
			self.m_MapTexture:SetActive(true)
		end)
	else
		self.m_MapTexture:SetActive(false)
	end
end

function CFieldBossView.UpdateLeftTime(self, iTime)
	if iTime then
		local colorlist = {
			{"8B410BFF", "FFEEB5FF"},
			{"514260FF", "E1D8FFFF"},
			{"6C2F25FF", "F9E2C2FF"},
		}
		iTime = math.max(0, iTime)
		local timeStr = g_TimeCtrl:GetLeftTime(iTime)
		local color = colorlist[self.m_BossID] or colorlist[1]
		self.m_TimeLabel:SetColor(Utils.HexToColor(color[1]))
		self.m_TimeLabel:SetEffectColor(Utils.HexToColor(color[2]))
		self.m_TimeLabel:SetActive(true)
		self.m_TimeLabel:SetText(timeStr)
		self.m_NextTexture:LoadPath(string.format("Texture/FieldBoss/text_xiansheng_%d.png", self.m_BossID), function()
			self.m_NextTexture:SetActive(true)
		end)
	else
		self.m_NextTexture:SetActive(false)
		self.m_TimeLabel:SetActive(false)
	end
end

function CFieldBossView.UpdateItems(self)
	self.m_ItemGrid:Clear()

end

function CFieldBossView.OnClickBossBox(self, bossid)
	nethuodong.C2GSFieldBossInfo(bossid)
end

function CFieldBossView.OnFightBoss(self)
	if not self.m_BossID then
		return
	end
	local bd, _ = g_FieldBossCtrl:GetBossData(self.m_BossID)
	local nd = data.fieldbossdata.NPC[bd.gate_model]
	local pos = {
		x = nd.x,
		y = nd.y,
		z = nd.z,
	}
	local mapId = nd.sceneId
	local function autowalk()
		if g_MapCtrl:GetMapID() ~= mapId or g_MapCtrl.m_MapLoding or math.floor(mapId/100) ~= g_MapCtrl.m_ResID then
			return true
		else
			g_MapTouchCtrl:WalkToPos(pos, nd.id, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function ()
				local npcid = g_MapCtrl:GetNpcIdByNpcType(nd.id)
				local oNpc = g_MapCtrl:GetNpc(npcid)
				if oNpc and oNpc.Trigger then
					oNpc:Trigger()
				end
			end)
		end
	end
	
	local curMapID = g_MapCtrl:GetMapID()
	if g_MapCtrl:GetMapID() ~= mapId then
		local oHero = g_MapCtrl:GetHero()
		netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapId)
		if self.m_AutoWalkTimer then
			Utils.DelTimer(self.m_AutoWalkTimer)
		end
		self.m_AutoWalkTimer = Utils.AddTimer(autowalk, 0, 0)
	else
		autowalk()
	end
	
	
end

return CFieldBossView
