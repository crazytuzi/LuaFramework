local CLoginRewardView = class("CLoginRewardView", CViewBase)

function CLoginRewardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/LoginReward/LoginRewardView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_DepthType = "Dialog"
end

function CLoginRewardView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DuDuLuTexture = self:NewUI(2, CTexture)
	self.m_BlackTexture = self:NewUI(3, CTexture)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_DayGrid = self:NewUI(5, CGrid)
	self.m_Slider = self:NewUI(6, CSlider)
	self.m_AddBtn = self:NewUI(7, CButton)
	self.m_NextBtn = self:NewUI(8, CSprite)
	self.m_LastBtn = self:NewUI(9, CSprite)

	self.m_ConfirmPart = self:NewUI(10, CBox)
	self.m_DescSpr = self:NewUI(11, CSprite)
	self.m_DetailBtn = self:NewUI(12, CButton)
	self.m_DetailPart = self:NewUI(13, CBox)
	self.m_TweenLabel = self:NewUI(14, CLabel)
	self.m_Container = self:NewUI(15, CWidget)
	UITools.ResizeToRootSize(self.m_Container)
	
	self.m_StarIdx = 0
	self.m_CurIdx = 0
	self.m_AddBtnIdx = 0
	self:InitDayGrid()
	self:InitDetailPart()
	self:InitConfirmPart()
	self:InitContent()
end

function CLoginRewardView.InitDayGrid(self)
	self.m_BoxList = {}
	self.m_DayGrid:InitChild(function (obj,idx)
		local oBox = CBox.New(obj)
		oBox.m_Day = idx
		oBox.m_GotSprite = oBox:NewUI(1, CSprite)
		oBox.m_SelectSprite = oBox:NewUI(2, CLabel)
		oBox.m_Texture = oBox:NewUI(3, CTexture)
		table.insert(self.m_BoxList, oBox)
	end)
	local oBox2 = self.m_BoxList[3]
	oBox2.m_Sprite = oBox2:NewUI(4, CSprite)
	oBox2.m_Sprite:SetSpriteName(string.format("pic_wuqi_%d", g_AttrCtrl.school))
end

function CLoginRewardView.InitDetailPart(self)
	self.m_DetailPart.m_BGTexture = self.m_DetailPart:NewUI(1, CTexture)
	self.m_DetailPart.m_LeftActorTexture = self.m_DetailPart:NewUI(2, CActorTexture)
	self.m_DetailPart.m_RightActorTexture = self.m_DetailPart:NewUI(3, CActorTexture)
	
	self.m_DetailPart.m_SkillBox = self.m_DetailPart:NewUI(4, CBox)
	self.m_DetailPart.m_SkillBox.m_SkillGrid = self.m_DetailPart.m_SkillBox:NewUI(1, CGrid)
	self.m_DetailPart.m_SkillBox.m_SkillSpr = self.m_DetailPart.m_SkillBox:NewUI(2, CSprite)
	self.m_DetailPart.m_SkillBox.m_SkillScrollView = self.m_DetailPart.m_SkillBox:NewUI(3, CScrollView)
	self.m_DetailPart.m_SkillBox.m_SKillDescLabel = self.m_DetailPart.m_SkillBox:NewUI(4, CLabel)
	self.m_DetailPart.m_SkillBox.m_SkillNameLabel = self.m_DetailPart.m_SkillBox:NewUI(5, CLabel)
	self.m_DetailPart.m_SkillBox.m_SKillCostLabel = self.m_DetailPart.m_SkillBox:NewUI(6, CLabel)
	self.m_DetailPart.m_SkillBox.m_SKillDescSpr = self.m_DetailPart.m_SkillBox:NewUI(7, CSprite)
	self.m_DetailPart.m_SkillBox.m_TipsLabel = self.m_DetailPart.m_SkillBox:NewUI(8, CLabel)
	self.m_DetailPart.m_SkillBox.m_SkillSpr:SetActive(false)
	self.m_DetailPart.m_SkillBox:SetActive(true)
	self.m_DetailPart.m_SkillBox.m_SKillDescSpr:SetActive(false)

	self.m_DetailPart.m_BGTexture:AddUIEvent("click", callback(self, "ShowDetailPart", false))
	self.m_DetailPart.m_SkillBox.m_TipsLabel:AddUIEvent("click", callback(self, "ShowSkillDesc", true))
end

function CLoginRewardView.ShowSkillDesc(self, bShow)
	self.m_DetailPart.m_SkillBox.m_SKillDescSpr:SetActive(bShow)
	self.m_DetailPart.m_SkillBox.m_TipsLabel:SetActive(not bShow)
end

function CLoginRewardView.ShowDetailPart(self, bShow)
	if bShow then
		self.m_DetailPart:SetActive(bShow)
		self.m_ScrollView:SetActive(not bShow)
		if not self.m_DetailPart.m_Init then
			self.m_DetailPart.m_LeftActorTexture:ChangeShape(418)
			self.m_DetailPart.m_RightActorTexture:ChangeShape(702)
			self.m_DetailPart.m_Init = true
			local dPartner = data.partnerdata.DATA[418]
			self:UpdateSkill(dPartner)
		end
	else
		local bAct = self.m_DetailPart.m_SkillBox.m_SKillDescSpr:GetActive()
		if bAct then
			self:ShowSkillDesc(false)
		else
			self.m_DetailPart:SetActive(bShow)
			self.m_ScrollView:SetActive(not bShow)
		end
	end
end

function CLoginRewardView.UpdateSkill(self, dPartner)
	local oBox = self.m_DetailPart.m_SkillBox
	oBox.m_SkillGrid:Clear()
	local skilllist = dPartner.skill_list
	local list = table.copy(skilllist)
	table.sort(list, function (a, b) return a < b end)

	local d = data.skilldata.PARTNERSKILL
	for _, sk in ipairs(list) do
		local spr = oBox.m_SkillSpr:Clone()
		local dSk = d[sk]
		if dSk and dSk.icon then
			spr:SpriteSkill(dSk.icon)
		end
		spr:AddUIEvent("click", callback(self, "OnClickSkill"))
		spr.m_SkillID = dSk.id
		spr.m_Level = 1
		spr:SetGroup(oBox.m_SkillGrid:GetInstanceID())
		spr:SetActive(true)
		oBox.m_SkillGrid:AddChild(spr)
	end
	oBox.m_SkillGrid:Reposition()
	local defaultBox = oBox.m_SkillGrid:GetChild(1)
	if defaultBox then
		defaultBox:SetSelected(true)
		self:OnClickSkill(defaultBox)
	end
end

function CLoginRewardView.OnClickSkill(self, box)
	self:ShowSkillDesc(true)
	local oBox = self.m_DetailPart.m_SkillBox
	local iSkillID = box.m_SkillID
	local level = box.m_Level
	local d = data.skilldata.PARTNER
	local md = data.skilldata.PARTNERSKILL
	if d[iSkillID] then
		oBox.m_SkillNameLabel:SetText(string.format("技能%d", iSkillID))
		oBox.m_SKillCostLabel:SetActive(false)
		if md[iSkillID] then
			oBox.m_SkillNameLabel:SetText(string.format("%s", md[iSkillID]["name"]))
			oBox.m_SKillCostLabel:SetText(string.format("%d", md[iSkillID]["sp"]))
		else
			oBox.m_SKillCostLabel:SetText("0")
		end
		oBox.m_SKillCostLabel:SetActive(true)
		
		local strlist = {}
		if d[iSkillID][1] then
			local maindesc = d[iSkillID][1]["desc"]
			local otherdesc = md[iSkillID]["otherdesc"]
			table.insert(strlist, maindesc)
			table.insert(strlist, "")
			table.insert(strlist, otherdesc)
			table.insert(strlist, "")
		end
		
		if level == 0 then
			table.insert( strlist, "觉醒后解锁该技能")
		
		elseif #d[iSkillID] < 2 then
			table.insert( strlist, "技能无法升级")
		
		else
			for i, obj in ipairs(d[iSkillID]) do
				if i > 1 then
					if i <= level then
						table.insert( strlist, string.format("lv%d %s", i, d[iSkillID][i]["desc"]))
					else
						table.insert( strlist, string.format("lv%d %s", i, d[iSkillID][i]["desc"]))
					end
				end
			end
		end
		oBox.m_SKillDescLabel:SetText(table.concat(strlist, "\n"))
	end
	oBox.m_SkillScrollView:ResetPosition()
end

function CLoginRewardView.InitConfirmPart(self)
	self.m_ConfirmPart.m_BGTexture = self.m_ConfirmPart:NewUI(1, CTexture)
	self.m_ConfirmPart.m_CancelBtn = self.m_ConfirmPart:NewUI(2, CButton)
	self.m_ConfirmPart.m_OKBtn = self.m_ConfirmPart:NewUI(3, CButton)
	self.m_ConfirmPart.m_DescLabel = self.m_ConfirmPart:NewUI(4, CLabel)
	self.m_ConfirmPart.m_OKBtn:AddUIEvent("click", function () 
			nethuodong.C2GSAddFullBreedVal()
			self:ShowConfirmPart(false)
		end)
	self.m_ConfirmPart.m_CancelBtn:AddUIEvent("click", callback(self, "ShowConfirmPart", false))
	self.m_ConfirmPart.m_BGTexture:AddUIEvent("click", callback(self, "ShowConfirmPart", false))
end

function CLoginRewardView.ShowConfirmPart(self, bShow)
	if bShow then
		local info = g_LoginRewardCtrl:GetLoginRewardInfo()
		local value = info and info.breed_val or 0
		local cost = 1500 - value
		self.m_ConfirmPart.m_DescLabel:SetText(string.format("是否消耗#wa%d补足缺少的孵化值", cost))
	end
	self.m_ConfirmPart:SetActive(bShow)	
end

function CLoginRewardView.InitContent(self)
	UITools.ResizeToRootSize(self.m_BlackTexture)
	self.m_DetailPart:SetActive(false)
	self.m_ConfirmPart:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAddBtn"))
	--self.m_LastBtn:AddUIEvent("click", callback(self, "OnLastBtn"))
	--self.m_NextBtn:AddUIEvent("click", callback(self, "OnNextBtn"))
	self.m_DetailBtn:AddUIEvent("click", callback(self, "OnDetailBtn"))
	self.m_TweenLabel:AddUIEvent("click", callback(self, "OnDetailBtn"))
	self.m_ScrollView:AddMoveCheck("left", self.m_ScrollView, callback(self, "OnMoveEnd"))
	self.m_ScrollView:AddMoveCheck("right", self.m_ScrollView, callback(self, "OnMoveEnd"))
	g_LoginRewardCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlLoginRewardEvent"))
	self:Refresh()
	self:OnMoveEnd()
	self.m_CurIdx = self:GetStarIdx()
	self.m_CurIdx = math.min(9, self.m_CurIdx)
	local oBox = self.m_BoxList[self.m_CurIdx]
	if oBox then
		local function delay()
			if Utils.IsNil(self) or Utils.IsNil(oBox) then
				return
			end
			self.m_ScrollView:Move2Obj(oBox, true)
		end
		Utils.AddTimer(delay, 0.1, 0.1)
	end
end

function CLoginRewardView.OnMoveEnd(self, obj)
	local pos = self.m_ScrollView:GetLocalPos()
	self.m_LastBtn:SetActive(pos.x <= -190)
	self.m_NextBtn:SetActive(pos.x >= -1470)
end

function CLoginRewardView.OnAddBtn(self, obj)
	if self.m_AddBtnIdx == 0 then
		self:ShowConfirmPart(true)
	elseif self.m_AddBtnIdx == 1 then
		nethuodong.C2GSGetBreedValRwd()
	end
end

function CLoginRewardView.OnLastBtn(self, obj)
	local idx = self.m_CurIdx - 1
	idx = math.max(idx, 1)
	self.m_CurIdx = idx
	local oBox = self.m_BoxList[self.m_CurIdx]
	self.m_ScrollView:Move2Obj(oBox, true)
end

function CLoginRewardView.OnNextBtn(self, obj)
	local idx = self.m_CurIdx + 1
	idx = math.min(idx, 8)
	self.m_CurIdx = idx
	local oBox = self.m_BoxList[self.m_CurIdx]
	self.m_ScrollView:Move2Obj(oBox, true)
end

function CLoginRewardView.OnDetailBtn(self, obj)
	self:ShowDetailPart(true)
end

function CLoginRewardView.OnCtrlLoginRewardEvent(self, oCtrl)
	if oCtrl.m_EventID == define.LoginReward.Event.LoginReward then
		self:Refresh()
	end
end

function CLoginRewardView.Refresh(self)
	self.m_StarIdx = 0
	local info = g_LoginRewardCtrl:GetLoginRewardInfo()
	local get = info and info.breed_rwd == 1 
	local value = info and info.breed_val or 0
	local max = CLoginRewardCtrl.BREED_MAX
	local idx = 0
	if value == max then
		idx = 7
	else
		idx = math.max(math.floor(value / CLoginRewardCtrl.BREED_INTERVAL), 1)
		idx = math.min(idx, 6)
	end
	--self.m_DuDuLuTexture:LoadPath(string.format("Texture/LoginReward/pic_dudulu_%d.png", math.min(idx, 7)))
	local descspr = {
		[1] = "pic_fuhuazhong",
		[2] = "pic_fuhuawancheng",
	}

	self.m_Slider:SetValue(value/max)
	self.m_Slider:SetSliderText(string.format("%d/%d", value, max))
	if value >= max then
		self.m_DescSpr:SetSpriteName(descspr[2])
		if get then
			self.m_AddBtn:SetText("已领取")
			self.m_AddBtn:SetGrey(true)
			self.m_AddBtnIdx = 2
		else
			self.m_AddBtn:SetText("领取")
			self.m_AddBtnIdx = 1
		end
		self.m_AddBtn:SetActive(true)
	else
		self.m_AddBtn:SetActive(false)
		self.m_AddBtnIdx = 1
		self.m_DescSpr:SetSpriteName(descspr[1])
	end


	local dData = data.loginrewarddata.Reward
	for i,v in ipairs(dData) do
		local oBox = self.m_BoxList[i]
		if oBox then
			local sid = v.item.sid
			local bGet = MathBit.andOp(info.rewarded_day, 2 ^ (i-1)) == 0 --0是没有领取，1是已领取
			oBox.m_Get = bGet
			oBox.m_GotSprite:SetActive(not bGet)
			local bNotTime = i > info.login_day
			if bNotTime then
				oBox.m_SelectSprite:SetActive(false)
			elseif bGet then
				if i == info.login_day then
					oBox.m_Texture:AddEffect("Finger3")
				else
					oBox.m_Texture:DelEffect("Finger3")
					oBox.m_Texture:AddEffect("round")
				end
			end
			local bC2GS = bGet and not bNotTime
			if sid and string.find(sid, "house_partner") then
				local _, house_partner = g_ItemCtrl:SplitSidToHousePartner(sid)
				local house_partnerShape = data.housedata.HousePartner[house_partner].shape
				oBox.m_Texture:AddUIEvent("click", callback(self, "OnGetReward", i, house_partner, bC2GS, "house_partner"))
			elseif sid and string.find(sid, "partner") then
				local _, partner = g_ItemCtrl:SplitSidToPartner(sid)
				oBox.m_Texture:AddUIEvent("click", callback(self, "OnGetReward", i, partner, bC2GS, "partner"))
			else
				if string.find(sid, "value") then --虚拟道具金币水晶彩晶等。
					local value = g_ItemCtrl:SplitSidAndValue(sid)
					sid, value = g_ItemCtrl:SplitSidAndValue(sid)
				end
				local oItem = CItem.NewBySid(sid)
				oBox.m_Texture:AddUIEvent("click", callback(self, "OnGetReward", i, oItem, bC2GS, "item"))
			end
		end
	end
end

function CLoginRewardView.OnGetReward(self, day, oItem, bGet, sType, obj)
	if bGet then
		nethuodong.C2GSGetLoginReward(day)
	else
		if sType == "item" then
			g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItem:GetValue("sid"), 
				{widget = self, side = enum.UIAnchor.Side.Center,}, nil, {quality = oItem:GetValue("quality")})
		elseif sType == "partner" then
			g_WindowTipCtrl:SetWindowPartnerInfo(oItem, 
				{widget = self, side = enum.UIAnchor.Side.Center,})
		elseif sType == "house_partner" then
			g_WindowTipCtrl:SetWindowHousePartnerInfo(oItem, 
				{widget = self, side = enum.UIAnchor.Side.Center,})
		end
	end
end

function CLoginRewardView.GetStarIdx(self)
	self.m_StarIdx = 0
	for i,oBox in ipairs(self.m_BoxList) do
		if oBox.m_Get then
			self.m_StarIdx = i
			break
		end
	end
	self.m_StarIdx = math.max(self.m_StarIdx - 1, 0)
	return self.m_StarIdx
end

function CLoginRewardView.SetActive(self, bActive, noMotion)
	CViewBase.SetActive(self, bActive, noMotion)
	g_TaskCtrl.m_IsOpenLoginRewardView = false
end

return CLoginRewardView
