local CYJFbResultView = class("CYJFbResultView", CViewBase)

CYJFbResultView.CloseViewTime = 5

function CYJFbResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/YJFuben/YjFubenResultView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_IsAlwaysShow = true
end

function CYJFbResultView.OnCreateView(self)
	self.m_PlayerTexture = self:NewUI(1, CTexture)
	self.m_ResultGroup = self:NewUI(2, CBox)
	self.m_ExpGrid = self:NewUI(3, CGrid)
	self.m_ExpBox = self:NewUI(4, CBox)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CItemTipsBox)
	self.m_Container = self:NewUI(7, CBox)
	self.m_PassGroup = self:NewUI(8, CBox)
	
	self.m_Grid = self:NewUI(9, CGrid)
	self.m_CardBox = self:NewUI(10, CBox)
	self.m_ExitBtn = self:NewUI(11, CButton)
	self.m_ExitLabel = self:NewUI(12, CLabel)
	self.m_HeroSpr = self:NewUI(13, CSprite)
	self.m_ResultSprite = self:NewUI(14, CSprite)
	self.m_ItemBg = self:NewUI(15, CBox)
	self.m_CardGrid = self:NewUI(16, CGrid)
	self.m_MemCardObj = self:NewUI(17, CBox)
	self.m_HeroNameLabel = self:NewUI(18, CLabel)
	self.m_WarId = nil
	self.m_CloseViewTimer = nil
	self:InitContent()
end

function CYJFbResultView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ExpBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_CardBox:SetActive(false)
	self.m_MemCardObj:SetActive(false)
	self.m_ExitBtn:AddUIEvent("click", callback(self, "OnMyClose"))
	local oView = CWarResultView:GetView()
	if oView then
		oView:CloseView()
	end
	self.m_HeroSpr:SpriteAvatar(g_AttrCtrl.model_info.shape)
	self.m_HeroNameLabel:SetText(g_AttrCtrl.name)
end

function CYJFbResultView.SetActive(self, b)
	CViewBase.SetActive(self, b)
end

function CYJFbResultView.SetContent(self, num, iTime, dMemberList)
	self.m_PassGroup:SetActive(true)
	self.m_ResultGroup:SetActive(false)
	self:RefreshGrid(num)
	self:ShowEndTime(iTime)
	self:RefreshCard(dMemberList)
end

function CYJFbResultView.RefreshCard(self, dMemberList)
	self.m_InfoData = {}
	self.m_MemList = {}
	for _, info in ipairs(dMemberList) do
		self.m_InfoData[info.pid] = {info, {}}
		table.insert(self.m_MemList, info.pid)
	end
	self:UpdateCard2()
end

function CYJFbResultView.RefreshGrid(self, num)
	self.m_Grid:Clear()
	for i = 1, num do
		local box = self.m_CardBox:Clone()
		box.m_Spr = box:NewUI(1, CSprite)
		box.m_Label = box:NewUI(2, CLabel)
		box.m_ItemBox = box:NewUI(3, CItemTipsBox)
		box.m_ThreeSpr = box:NewUI(4, CSprite)
		box.m_ThreeSpr:SetActive(false)
		box.m_Label:SetText("点击抽取奖励")
		box.m_ItemBox:SetActive(false)
		box:SetActive(true)
		box.m_Spr:AddUIEvent("click", callback(self, "OnClickCard", i))
		self.m_Grid:AddChild(box)
	end
	self.m_Grid:Reposition()
end

function CYJFbResultView.RefreshResult(self, resultList)
	local amount = 0
	for _, dData in ipairs(resultList) do
		local box = self.m_Grid:GetChild(dData.idx)
		if box then
			if dData.gold and dData.gold > 0 then
				box.m_Label:SetText(string.format("#w2 %d", dData.gold))
				box.m_Spr:AddUIEvent("click", callback(self, "OnBuyCard", dData.idx, dData.gold))
				box.m_Spr:SetSpriteName("pic_yj_baoxiangguan")
				box.m_Spr:SetSize(184, 148)
				box.m_ThreeSpr:SetActive(false)
				box.m_Spr:SetColor(Utils.HexToColor("ACACACFF"))
				box.m_ItemBox:SetActive(false)
			else
				box.m_Label:SetText("")
				box.m_ItemBox:SetActive(true)
				box.m_ThreeSpr:SetActive(dData.mul == 3)
				box.m_Spr:SetSpriteName("pic_yj_baoxiangkai")
				box.m_Spr:SetSize(281, 204)
				box.m_Spr:SetColor(Utils.HexToColor("ffffffff"))
				amount = amount + 1
				local t = self:GetReward(dData)
				local config = {isLocal = true, uiType = 3}
				if t.key == "value" then
					box.m_ItemBox:SetItemData(t.itemid, t.value, nil, config)
				else
					box.m_ItemBox:SetItemData(t.itemid, t.amount, t.value, config)
				end
			end
		end
	end
	-- if amount > 3 then
	-- 	local function delay()
	-- 		if not Utils.IsNil(self) then
	-- 			self:OnClose()
	-- 		end
	-- 	end
	-- 	Utils.AddTimer(delay, 0, 2)
	-- end
end

function CYJFbResultView.GetReward(self, dData)
	local pat1 = "(%d+)%((%a+)=(%d+)%)"
	local pat2 = "(%d+)"
	local resultList = {}
	
	local amount = dData.amount
	local k1, k2, k3 = string.match(dData.sItem, pat1)
	if k1 then
		local t = {
			itemid = tonumber(k1),
			key = tostring(k2),
			value = tonumber(k3),
			amount = amount,
		}
		return t
	else
		local k1, k2 = string.match(dData.sItem, pat2)
		if k1 then
			local t = {
				itemid = tonumber(k1),
				amount = amount,
			}
			table.insert(resultList, t)
			return t
		end
	end
end

function CYJFbResultView.ShowEndTime(self, iTime)
	if self.m_EndTimer then
		Utils.DelTimer(self.m_EndTimer)
	end
	self.m_EndTime = iTime
	local function update()
		if Utils.IsNil(self) then
			return
		end

		local t = self.m_EndTime - g_TimeCtrl:GetTimeS()
		if t >= 0 then
			self.m_ExitLabel:SetText(string.format("%d秒后退出副本", t))
			return true
		else
			self.m_ExitLabel:SetText("0秒后退出副本")
			if t < -3 then 
				self:OnClose()
				return
			else
				return true
			end
		end
	end
	self.m_EndTimer = Utils.AddTimer(update, 0.1, 0)
end

function CYJFbResultView.UpdateMemInfo(self, info, cardInfo)
	self.m_InfoData = self.m_InfoData or {}
	self.m_MemList = self.m_MemList or {}
	if not table.index(self.m_MemList, info.pid) then
		table.insert(self.m_MemList, info.pid)
	end
	local cardList = {}
	for _, dData in ipairs(cardInfo) do
		cardList[dData.idx] = dData
	end
	self.m_InfoData[info.pid] = {info, cardList}
	self:UpdateCard2()
end

function CYJFbResultView.UpdateCard2(self)
	self.m_CardGrid:Clear()
	for _, pid in ipairs(self.m_MemList) do
		if pid ~= g_AttrCtrl.pid then
			local info, cardInfo = self.m_InfoData[pid][1], self.m_InfoData[pid][2]
			local box = self.m_MemCardObj:Clone()
			box:SetActive(true)
			box.m_Icon = box:NewUI(1, CSprite)
			box.m_Grid = box:NewUI(2, CGrid)
			box.m_ItemBox = box:NewUI(3, CItemTipsBox)
			box.m_EmptyBox = box:NewUI(4, CObject)
			box.m_NameLabel = box:NewUI(5, CLabel)
			
			box.m_Icon:SpriteAvatar(info.shape)
			box.m_NameLabel:SetText(info.name or "")
			box.m_ItemBox:SetActive(false)
			box.m_EmptyBox:SetActive(false)
			box.m_Grid:Clear()
			for i = 1, 4 do
				local dData = cardInfo[i]
				local itemBox = nil
				if dData and dData.gold and dData.gold == 0 then
					itemBox = box.m_ItemBox:Clone()
					itemBox.m_ThreeSpr = itemBox:NewUI(10, CSprite)
					itemBox.m_ThreeSpr:SetActive(dData.mul == 3)
					itemBox:SetActive(true)
					local t = self:GetReward(dData)
					local config = {isLocal = true, uiType = 0}
					if t.key == "value" then
						itemBox:SetItemData(t.itemid, t.value, nil, config)
					else
						itemBox:SetItemData(t.itemid, t.amount, t.value, config)
					end
					--itemBox.m_Effect:SetLocalPos(Vector3.New(50, -40, 0))
				else
					itemBox = box.m_EmptyBox:Clone()
					itemBox:SetActive(true)
				end
				box.m_Grid:AddChild(itemBox)
			end
			box.m_Grid:Reposition()
			self.m_CardGrid:AddChild(box)
		end
	end
	self.m_CardGrid:Reposition()
end

function CYJFbResultView.RefreshFinal(self, info, cardInfo)
	self.m_InfoData = self.m_InfoData or {}
	self.m_MemList = self.m_MemList or {}
	self.m_FinalList = self.m_FinalList or {}
	if not table.index(self.m_FinalList, info.pid) then
		table.insert(self.m_FinalList, info.pid)
	end
	local cardList = {}
	for _, dData in ipairs(cardInfo) do
		cardList[dData.idx] = dData
	end
	self.m_InfoData[info.pid] = {info, cardList}
	
	if #self.m_FinalList >= #self.m_MemList then
		if self.m_InfoData[g_AttrCtrl.pid] then
			self:RefreshResult(self.m_InfoData[g_AttrCtrl.pid][2])
		end
		self:UpdateCard2()
		local function delay()
			if not Utils.IsNil(self) then
				self:OnClose()
			end
		end
		Utils.AddTimer(delay, 0, 2)
	end
end

function CYJFbResultView.OnClickCard(self, idx)
	netminigame.C2GSMiniGameOp("drawcard" , {{key="idx", value=idx}, })
end

function CYJFbResultView.OnBuyCard(self, idx, igold)
	self:OnClickCard(idx)
end

function CYJFbResultView.OnMyClose(self)
	netminigame.C2GSMiniGameOp("drawcard" , {{key="endgame", value=1}})
end

return CYJFbResultView