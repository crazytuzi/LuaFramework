---------------------------------------------------------------
--明雷Tips画面

---------------------------------------------------------------

local CMingLeiReadyFightView = class("CMingLeiReadyFightView", CViewBase)

function CMingLeiReadyFightView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/MingLei/MingLeiReadyFightView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CMingLeiReadyFightView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_FightBtn = self:NewUI(2, CButton)
	self.m_TeamBtn = self:NewUI(3, CButton)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_RewardGrid = self:NewUI(6, CGrid)
	self.m_RewardBox = self:NewUI(7, CBox)
	self.m_LevelLabel = self:NewUI(8, CLabel)
	self.m_LevelGrid = self:NewUI(9, CGrid)
	self.m_LevelBox = self:NewUI(10, CBox)
	self.m_ShapBox = self:NewUI(11, CBox)
	self.m_CloseBtn = self:NewUI(12, CButton)

	self.m_RewardBoxList = {}

	self.m_NpcId = 0
	self.m_Shape = 315
	self.m_Level = 1
	self.m_Data = nil
	self.m_DoneTime = 0
	self.m_ToTalTime = 10
	self.m_LevelPool = 
	{
		[1] = {level = 1, text = "普通"},
		[2] = {level = 2, text = "困难"},
		[3] = {level = 3, text = "地狱"},
	}	

	self:InitContent()
end

function CMingLeiReadyFightView.InitContent(self)
	self.m_RewardBox:SetActive(false)
	self.m_LevelBox:SetActive(false)
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnFight"))
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnTeam"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAdd"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnCloseBtn"))
	self.m_LevelLabel:SetText(string.format("%s奖励：", self.m_LevelPool[1].text))
	self:InitLevelGrid()
end

function CMingLeiReadyFightView.OnFight(self)
	nethuodong.C2GSDoMingleiCmd(self.m_NpcId, "MLF", {type = self.m_Level})
end

function CMingLeiReadyFightView.OnTeam(self)
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.minglei.open_grade then
		g_NotifyCtrl:FloatMsg(string.format("您目前等级未到达%d级，无法进行便捷组队。", data.globalcontroldata.GLOBAL_CONTROL.minglei.open_grade))
		return
	end
	local target = 1101
	local d = data.autoteamdata.DATA
	for i, v in pairs(d) do
		if v.parentId == target and v.quick_build_id == self.m_Shape then
			target = v.id
			break
		end
	end
	g_TeamCtrl:QuickBuildTeamByTarget(target)
	self:CloseView()
end

function CMingLeiReadyFightView.OnAdd(self)
	nethuodong.C2GSDoMingleiCmd(self.m_NpcId, "BUY")
end

function CMingLeiReadyFightView.SetContent(self, config)
	config = config or {}
	local totaltime = config.totaltime
	local buytime = config.buytime
	local donetime = config.donetime
	local leftbuytime = config.leftbuytime
	local npctype = config.npctype
	local npcid = config.npcid
	self.m_NpcId = npcid
	self.m_DoneTime = donetime
	self.m_ToTalTime = totaltime
	self.m_Data = data.mingleidata.NPC[npctype]
	if not self.m_Data then
		return
	end
	self.m_Shape = self.m_Data.modelId
	self:OnClickToggle(1)
	self:RefreshShap()
	self:RefreshRewardGird()
	self.m_TimeLabel:SetText(string.format("[674c36]进行次数:[318f89]%d/%d", self.m_DoneTime, self.m_ToTalTime))
end

function CMingLeiReadyFightView.RefreshRewardGird(self)
	local t = data.mingleidata.CONFIG_UI_REWARD
	local d
	if not t then
		return
	end
	for k, v in pairs(t) do
		if v.shape == self.m_Shape and v.level == self.m_Level then
			d = v.reward_list
			break
		end
	end
	if not d or d == "" then
		return
	end
	local list = string.split(d, "|")
	for i= 1, #list do
		local info = string.split(list[i], "-")
		local sid = tonumber(info[1])
		local des = tostring(info[2])		
		local oBox = self.m_RewardBoxList[i]
		if not oBox then
			oBox = self.m_RewardBox:Clone()
			oBox.m_MainBox = oBox:NewUI(1, CItemRewardBox)
			oBox.m_Label = oBox:NewUI(2, CLabel)
			self.m_RewardGrid:AddChild(oBox)
			table.insert(self.m_RewardBoxList, oBox)
		end
		oBox:SetActive(true)
		local config = {side = enum.UIAnchor.Side.Top}
		oBox.m_MainBox:SetItemBySid(sid, 1, config)		
		oBox.m_Label:SetText(string.format("%s", des))
	end

	if #list < #self.m_RewardBoxList then
		for i = #list + 1, #self.m_RewardBoxList do
			local oBox = self.m_RewardBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
end

function CMingLeiReadyFightView.RefreshShap(self)
	local oBox = self.m_ShapBox			
	oBox.m_NameLabel = oBox:NewUI(1, CLabel)
	oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
	oBox.m_QualityBgSpr = oBox:NewUI(3, CSprite)
	oBox.m_ShapeSpr = oBox:NewUI(4, CSprite)
	local d = data.partnerdata.DATA[self.m_Shape]
	if not d then
		return
	end
	oBox.m_ShapeSpr:SpriteAvatarBig(d.icon)
	oBox.m_QualityBgSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(d.rare))
	oBox.m_QualitySpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(d.rare))
	oBox.m_QualitySpr:SetActive(false)
	oBox.m_NameLabel:SetText(self.m_Data.name)
end

function CMingLeiReadyFightView.InitLevelGrid(self)

	for i = 1, #self.m_LevelPool do
		local oBox = self.m_LevelBox:Clone()
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_ToggleBtn = oBox:NewUI(2, CButton)
		oBox.m_Label:SetText(self.m_LevelPool[i].text)
		oBox:SetActive(true)		
		oBox.m_ToggleBtn:AddUIEvent("click", callback(self, "OnClickToggle", i))
		oBox.m_ToggleBtn:SetGroup(self.m_LevelGrid:GetInstanceID())
		oBox.m_ToggleBtn:SetSelected(i == 1)
		self.m_LevelGrid:AddChild(oBox)
	end
end

function CMingLeiReadyFightView.OnClickToggle(self, level)
	if self.m_Level == level then
		return
	end
	self.m_Level = level 
	self:RefreshRewardGird()
	self.m_LevelLabel:SetText(string.format("%s奖励：", self.m_LevelPool[level].text))
end

function CMingLeiReadyFightView.RefreshTime(self, totaltime, buytime, donetime, leftbuytime)
	self.m_ToTalTime = totaltime
	self.m_DoneTime = donetime
	self.m_TimeLabel:SetText(string.format("[674c36]进行次数:[318f89]%d/%d", self.m_DoneTime, self.m_ToTalTime))
end

function CMingLeiReadyFightView.OnCloseBtn(self )
	self:CloseView()
end

return CMingLeiReadyFightView