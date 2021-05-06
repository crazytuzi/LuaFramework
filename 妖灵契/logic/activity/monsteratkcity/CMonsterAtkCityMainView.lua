local CMonsterAtkCityMainView = class("CMonsterAtkCityMainView", CViewBase)

function CMonsterAtkCityMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/MonsterAtkCity/MonsterAtkCityMainView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CMonsterAtkCityMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_HelpBtn = self:NewUI(3, CButton)
	self.m_CityPart = self:NewUI(4, CBox)
	self.m_HPSlider = self:NewUI(5, CSlider)
	self.m_NodePanel = self:NewUI(6, CObject)
	self.m_MonsterBox = self:NewUI(7, CBox)
	self.m_DefenseSliderBox = self:NewUI(8, CBox)
	self.m_DefenseLabel = self:NewUI(9, CLabel)
	self.m_WaveLabel = self:NewUI(10, CLabel)
	self.m_RewardsBox = self:NewUI(11, CBox)
	self.m_DetailPart = self:NewUI(12, CMonsterAtkCityDetailPart)
	self.m_RankPart = self:NewUI(13, CMonsterAtkCityRankPart)
	self.m_RankLabel = self:NewUI(14, CLabel)
	self.m_RewarPart = self:NewUI(15, CBox)
	self.m_CityBoxDic = {}
	self.m_MonsterBoxDic = {}
	self.m_DefenseBoxList = {}
	self.m_RewardsBoxList = {}
	self.m_MonsterDepth = 100
	self:InitContent()
end

function CMonsterAtkCityMainView.InitContent(self)
	--UITools.ResizeToRootSize(self.m_Container)
	self.m_MonsterBox:SetActive(false)
	self.m_DetailPart:SetActive(false)
	self.m_RankPart:SetActive(false)
	self.m_DetailPart:SetParentView(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_RankLabel:AddUIEvent("click", callback(self, "OnRank")) 
	g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvnet"))
	self:InitCityPart()
	self:InitMonster()
	self:InitDefenseBox()
	self:InitRewardsBox()
	self:InitRewarPart()
	self:RefreshDefense()
end

function CMonsterAtkCityMainView.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("monsteratkcity")
	end)
end

function CMonsterAtkCityMainView.OnRank(self, obj)
	self.m_RankPart:ShowPart(true)
end

function CMonsterAtkCityMainView.OnMonsterAtkCityEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.AddMonster then
		if oCtrl.m_EventData then
			self:AddMonsterBox(oCtrl.m_EventData)
		end
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.DelMonster then
		if oCtrl.m_EventData then
			self:DelMonsterBox(oCtrl.m_EventData)
		end
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.CityDefend then
		self:RefreshDefense()
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.RefreshWave then
		self:RefreshWave()
	end
end

function CMonsterAtkCityMainView.InitDefenseBox(self)
	local dData = data.msattackdata.DefenseRegion
	for i=1,4 do
		self.m_DefenseBoxList[i] = self.m_DefenseSliderBox:NewUI(i, CBox)
		self.m_DefenseBoxList[i].m_Slider = self.m_DefenseBoxList[i]:NewUI(1, CSlider)
		self.m_DefenseBoxList[i].m_Thumb = self.m_DefenseBoxList[i]:NewUI(2, CSprite)
		self.m_DefenseBoxList[i].m_Thumb:SetActive(false)
		self.m_DefenseBoxList[i].m_MaxValue = dData[i].max
		self.m_DefenseBoxList[i].m_MinValue = dData[i].min
		self.m_DefenseBoxList[i].m_Slider:SetValue(1)
		self.m_DefenseBoxList[i].m_Slider:SetSliderText("")
	end
end

function CMonsterAtkCityMainView.InitRewardsBox(self)
	local dData = data.msattackdata.DefenseReward
	for i=1,5 do
		self.m_RewardsBoxList[i] = self.m_RewardsBox:NewUI(i, CSprite)
		self.m_RewardsBoxList[i].m_MinValue = dData[i].value
		self.m_RewardsBoxList[i]:AddUIEvent("click", callback(self, "ShowRewarPart", true, dData[i]))
	end 
end

function CMonsterAtkCityMainView.InitRewarPart(self)
	self.m_RewarBG = self.m_RewarPart:NewUI(1, CTexture)
	self.m_RewarLabel = self.m_RewarPart:NewUI(2, CLabel)
	self.m_RewarGrid = self.m_RewarPart:NewUI(3, CGrid)
	self.m_ItemBox = self.m_RewarPart:NewUI(4, CItemRewardBox)
	self.m_RewarBG:AddUIEvent("click", callback(self, "ShowRewarPart", false))
	self.m_RewarPart:SetActive(false)
	self.m_ItemBox:SetActive(false)
end

function CMonsterAtkCityMainView.ShowRewarPart(self, bShow, dData)
	self.m_RewarPart:SetActive(bShow)
	if dData then
		local value = dData.value
		self.m_RewarLabel:SetText(string.format("城市防御值高于%s时可获得", value))
		local rewardlist = dData.rewardlist or {}
		self.m_RewarGrid:Clear()
		for i,v in ipairs(rewardlist) do
			local oBox = self.m_ItemBox:Clone()
			local config = {isLocal = true,}
			oBox:SetActive(true)
			oBox:SetItemBySid(v.sid, v.num, config)
			self.m_RewarGrid:AddChild(oBox)
		end
		self.m_RewarGrid:Reposition()
	end
end

function CMonsterAtkCityMainView.InitCityPart(self)
	self.m_Idx2CityID = {1003, 1004, 1006}
	for i=1,3 do
		local cityID = self.m_Idx2CityID[i]
		if cityID then
			local oBox = self.m_CityPart:NewUI(i, CBox)
			oBox.m_Idx = i
			oBox.m_CityID = cityID
			oBox.m_MapID = data.scenedata.DATA[cityID].map_id
			oBox.m_ResID = data.mapdata.DATA[oBox.m_MapID].resource_id
			oBox:AddUIEvent("click", callback(self, "OnCityBox"))
			self.m_CityBoxDic[cityID] = oBox
		end
	end
	self.m_DetailPart:ShowPart(false)
end

function CMonsterAtkCityMainView.OnCityBox(self, oBox)
	self.m_DetailPart:SetCityData(oBox)
	self.m_DetailPart:ShowPart(true)
end

function CMonsterAtkCityMainView.InitMonster(self)
	local monsterInfos = g_MonsterAtkCityCtrl:GetMonsterInfos()
	for k,monsterInfo in pairs(monsterInfos) do
		self:CreateMonsterBox(monsterInfo)
	end
end

function CMonsterAtkCityMainView.CreateMonsterBox(self, monsterInfo)
	local pathid = monsterInfo.path_id
	local dData = data.msattackdata.PathConfig[pathid]
	if not dData then
		printc("没有路径:",pathid)
		return
	end
	local worldmap_path = dData.worldmap_path
	local alive_time = dData.alive_time
	local worldmap_speed = dData.worldmap_speed
	local interval = g_TimeCtrl:GetTimeS() - monsterInfo.createtime
	if interval < alive_time then
		local startPos, starIdx = g_MonsterAtkCityCtrl:GetStartPos(worldmap_path, interval)
		if not startPos then
			return
		end
		local oMonsterBox = self.m_MonsterBox:Clone()
		oMonsterBox.m_IconSprite = oMonsterBox:NewUI(1, CSprite)
		oMonsterBox.m_BgSprite = oMonsterBox:NewUI(2, CSprite)
		if monsterInfo and monsterInfo.npctype == "middle" then
			oMonsterBox.m_BgSprite:SetSpriteName("pic_monster_bg_2")
		elseif monsterInfo and monsterInfo.npctype == "large" then
			oMonsterBox:SetLocalScale(Vector3.New(1.5, 1.5, 1.5))
			oMonsterBox.m_BgSprite:SetSpriteName("pic_monster_bg_3")
		else
			oMonsterBox.m_BgSprite:SetSpriteName("pic_monster_bg_1")
		end
		self.m_MonsterDepth = self.m_MonsterDepth + 1
		oMonsterBox.m_BgSprite:SetDepth(self.m_MonsterDepth)
		self.m_MonsterDepth = self.m_MonsterDepth + 1
		oMonsterBox.m_IconSprite:SetDepth(self.m_MonsterDepth)
		oMonsterBox.m_Npcid = monsterInfo.npcid
		oMonsterBox:SetParent(self.m_NodePanel.m_Transform)
		oMonsterBox:SetLocalPos(startPos)
		oMonsterBox.m_IconSprite:SpriteAvatar(monsterInfo.model_info.shape)
		oMonsterBox:SetActive(true)
		self.m_MonsterBoxDic[monsterInfo.npcid] = oMonsterBox
		self:CheckMoveMonsterBox(oMonsterBox, starIdx, worldmap_path)
	end
end

function CMonsterAtkCityMainView.CheckMoveMonsterBox(self, oMonsterBox, starIdx, worldmap_path)
	if Utils.IsNil(oMonsterBox) then
		return
	end
	starIdx = starIdx + 1
	if worldmap_path[starIdx] then
		self:MoveMonsterBox(oMonsterBox, starIdx, worldmap_path)
	else
		self:DelMonsterBox(oMonsterBox.m_Npcid)
	end
end 

function CMonsterAtkCityMainView.MoveMonsterBox(self, oMonsterBox, starIdx, worldmap_path)
	local targetPos = Vector3.New(worldmap_path[starIdx].x, worldmap_path[starIdx].y, 0)
	local interval = worldmap_path[starIdx].time - worldmap_path[starIdx-1].time
	local tween = DOTween.DOLocalMove(oMonsterBox.m_Transform, targetPos, interval)
	DOTween.OnComplete(tween, callback(self, "CheckMoveMonsterBox", oMonsterBox, starIdx, worldmap_path))
end

function CMonsterAtkCityMainView.AddMonsterBox(self, npcid)
	local monsterInfo = g_MonsterAtkCityCtrl:GetMonsterInfo(npcid)
	self:CreateMonsterBox(monsterInfo)
end

function CMonsterAtkCityMainView.DelMonsterBox(self, npcid)
	local oMonsterBox = self.m_MonsterBoxDic[npcid]
	if oMonsterBox then
		DOTween.DOKill(oMonsterBox.m_Transform, false)
		oMonsterBox:Destroy()
	end
	self.m_MonsterBoxDic[npcid] = nil
end

function CMonsterAtkCityMainView.RefreshDefense(self)
	local cur, max = g_MonsterAtkCityCtrl:GetDefendValue()
	self.m_DefenseLabel:SetText(string.format("%d/%d", cur, max))
	self.m_HPSlider:SetValue(cur/max)
	self.m_HPSlider:SetSliderText(string.format("%d/%d", cur, max))
	for i,v in ipairs(self.m_DefenseBoxList) do
		if cur > v.m_MaxValue then
			v.m_Thumb:SetActive(false)
			v.m_Slider:SetValue(1)
		elseif cur < v.m_MinValue then
			v.m_Thumb:SetActive(false)
			v.m_Slider:SetValue(0)
		elseif cur >= v.m_MinValue and cur < v.m_MaxValue then
			v.m_Thumb:SetActive(true)
			v.m_Slider:SetValue((cur - v.m_MinValue) / (v.m_MaxValue - v.m_MinValue))
		end
	end
	for i,v in ipairs(self.m_RewardsBoxList) do
		v:SetGrey(cur < v.m_MinValue)
	end

	self:RefreshWave()
end

function CMonsterAtkCityMainView.RefreshWave(self)
	local time = g_MonsterAtkCityCtrl:GetNextTime()
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	if time == 0 then
		self.m_WaveLabel:SetText("")
	else
		time = time - g_TimeCtrl:GetTimeS()
		local cur, max = g_MonsterAtkCityCtrl:GetWave()
		local txt = "怪物波数："..cur.."/"..max
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 and cur < max then
				self.m_WaveLabel:SetText(string.format(txt.."（下波时间:%s）", g_TimeCtrl:GetLeftTime(time, true)))
				time = time - 1
				return true
			else
				self.m_WaveLabel:SetText(txt)
			end
		end
		self.m_Timer = Utils.AddTimer(countdown, 1, 0)
	end
end

return CMonsterAtkCityMainView