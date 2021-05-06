local CPEFbView = class("CPEFbView", CViewBase)

local State = {
	Normal = 0,
	Roll = 1,
	RollEnd = 2,
	RollStop = 3,
	AutoFuben = 4,
}

function CPEFbView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/PartnerEquipFuben/ParnterEquipFbMainView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_HelpKey = "pefuben_info"
	self.m_SwitchSceneClose = true
end

function CPEFbView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_FilterBox = self:NewUI(2, CBox)
	self.m_StartBtn = self:NewUI(3, CButton)
	self.m_RollBox = self:NewUI(5, CBox)
	self.m_RollGold = self:NewUI(6, CLabel)
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_Grid = self:NewUI(8, CGrid)
	self.m_Itemobj = self:NewUI(9, CBox)
	self.m_EquipLockBox = self:NewUI(10, CBox)
	self.m_PartLockBox = self:NewUI(11, CBox)
	self.m_EnterBtn = self:NewUI(12, CButton)
	self.m_DropBtn = self:NewUI(13, CButton)
	self.m_DropGrid = self:NewUI(14, CGrid)
	self.m_DropSpr = self:NewUI(15, CSprite)
	self.m_CostLabel = self:NewUI(16, CLabel)
	self.m_SkillBox = self:NewUI(17, CBox)
	self.m_NameLabel = self:NewUI(18, CLabel)
	self.m_TipBtn = self:NewUI(19, CButton)
	self.m_AddFubenBtn = self:NewUI(20, CButton)
	self.m_MaskObj = self:NewUI(21, CWidget)
	self.m_FlashBtn = self:NewUI(22, CButton)
	self.m_SJBox = self:NewUI(23, CBox)
	self.m_TLBox = self:NewUI(24, CBox)
	self.m_AttrTypeLabel = self:NewUI(25, CLabel)
	self.m_AutoFightBtn = self:NewUI(26, CButton)
	self.m_AutoFightCostLabel = self:NewUI(27, CLabel)
	self.m_AutoFightFreeSpr = self:NewUI(28, CSprite)
	self.m_RestLabel = self:NewUI(29, CLabel)
	self.m_SDQLabel = self:NewUI(30, CLabel)
	self:InitContent()
end

function CPEFbView.DoCallback(self, funcname, ...)
	if self.m_State ~= State.Normal then
		return
	end
	self[funcname](self, ...)
end

function CPEFbView.InitContent(self)
	self:InitRollBox()
	self:InitLockBox()
	self:InitSkillBox()
	self:InitJumpFlash()
	self:InitAttr()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "DoCallback", "OnClose"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "DoCallback", "OnHelpTip"))
	self.m_StartBtn:AddUIEvent("click", callback(self, "DoCallback", "OnStart"))
	self.m_EnterBtn:AddUIEvent("click", callback(self, "DoCallback", "OnEnterFuben"))
	self.m_FilterBtn:AddUIEvent("click", callback(self, "DoCallback", "OnShowFilterView"))
	self.m_DropBtn:AddUIEvent("click", callback(self, "DoCallback", "OnShowDropView"))
	self.m_AddFubenBtn:AddUIEvent("click", callback(self, "DoCallback", "OnShowAddFuben"))
	self.m_AutoFightBtn:AddUIEvent("click", callback(self, "DoCallback", "TryFastClear"))
	self.m_Itemobj:SetActive(false)
	self.m_DropSpr:SetActive(false)
	self.m_SkillBox:SetActive(false)
	self.m_NameLabel:SetActive(false)
	self.m_MaskObj:SetActive(false)
	self.m_AttrTypeLabel:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_SkillBox, callback(self, "CloseTips"))
	g_ActivityCtrl:GetPEFbCtrl():AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFubenCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
	g_GuideCtrl:AddGuideUI("pefunben_start_btn", self.m_EnterBtn)
end

function CPEFbView.InitRollBox(self)
	local rollbox = self.m_RollBox
	self.m_PEBoxList = {}
	self.m_SelectPEList = {}
	for i = 1, 5 do
		local box = rollbox:NewUI(i, CBox)
		box.m_LockSpr = box:NewUI(1, CSprite)
		box.m_IconSpr = box:NewUI(2, CSprite)
		self.m_PEBoxList[i] = box
	end
	self.m_SelectPESpr= rollbox:NewUI(6, CSprite)
	self.m_PosSprList = {}
	self.m_PosSprList[1] = rollbox:NewUI(11, CSprite)
	self.m_PosLockSpr = rollbox:NewUI(12, CSprite)
	self.m_PosSprList[2] = rollbox:NewUI(13, CSprite)
	self.m_PosSprList[3] = rollbox:NewUI(14, CSprite)

end

function CPEFbView.InitLockBox(self)
	self.m_EquipLockBox.m_UnLockSpr = self.m_EquipLockBox:NewUI(1, CSprite)
	self.m_EquipLockBox.m_LockSpr = self.m_EquipLockBox:NewUI(2, CSprite)
	self.m_EquipLockBox.m_Label = self.m_EquipLockBox:NewUI(3, CLabel)
	self.m_EquipLockBox.m_Gold = self.m_EquipLockBox:NewUI(4, CLabel)

	self.m_PartLockBox.m_UnLockSpr = self.m_PartLockBox:NewUI(1, CSprite)
	self.m_PartLockBox.m_LockSpr = self.m_PartLockBox:NewUI(2, CSprite)
	self.m_PartLockBox.m_Label = self.m_PartLockBox:NewUI(3, CLabel)
	self.m_PartLockBox.m_Gold = self.m_PartLockBox:NewUI(4, CLabel)

	self.m_EquipLockBox:SetActive(false)
	self.m_PartLockBox:SetActive(false)
	self.m_EquipLockBox:AddUIEvent("click", callback(self, "DoCallback", "OnClickEquipLock"))
	self.m_PartLockBox:AddUIEvent("click", callback(self, "DoCallback", "OnClickPartLock"))
end

function CPEFbView.InitSkillBox(self)
	self.m_SkillDesc = self.m_SkillBox:NewUI(1, CLabel)
	self.m_SkillIcon = self.m_SkillBox:NewUI(2, CSprite)
	self.m_SKillName = self.m_SkillBox:NewUI(3, CLabel)
	self.m_SKillBG = self.m_SkillBox:NewUI(4, CSprite)

	self.m_FilterIcon = self.m_FilterBox:NewUI(1, CSprite)
	self.m_FilterName =self.m_FilterBox:NewUI(2, CLabel)
	self.m_FilterBtn = self.m_FilterBox:NewUI(3, CButton)
	self.m_FilterPosIcon = self.m_FilterBox:NewUI(4, CSprite)
end

function CPEFbView.InitAttr(self)
	self.m_SJLabel = self.m_SJBox:NewUI(1, CLabel)
	self.m_AddSJBtn = self.m_SJBox:NewUI(2, CButton)
	self.m_TLLabel = self.m_TLBox:NewUI(1, CLabel)
	self.m_AddTLBtn = self.m_TLBox:NewUI(2, CButton)
	self.m_AddTLBtn:AddUIEvent("click", callback(self, "OnAddEnergy"))
	self.m_AddSJBtn:AddUIEvent("click", callback(self, "OnAddGoldCoin"))
	self:UpdateAttr()
end

function CPEFbView.InitJumpFlash(self)
	local iJumpflash = IOTools.GetRoleData("pefb_jumpflash") or 0
	if iJumpflash == 1 then
		self.m_FlashBtn:SetSelected(true)
		self.m_IsJumpFlash = true
	else
		self.m_IsJumpFlash = false
		self.m_FlashBtn:SetSelected(false)
	end
	self.m_FlashBtn:AddUIEvent("click", callback(self, "OnChangeFlash"))
end

function CPEFbView.OnFubenCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PEFuben.Event.UpdateTurn then
		self.m_ResultData = oCtrl.m_EventData
		if self.m_IsJumpFlash then
			self:RefreshRoll()
			self.m_SelectEquip = self.m_ResultData.select_equip
			self.m_SelectPart = self.m_ResultData.select_part
			self.m_EnterFuben = self.m_ResultData.enter
			self:RefreshRoll()
			self:StopRoll()
		else
			self:StartRoll()
			self.m_SelectEquip = self.m_ResultData.select_equip
			self.m_SelectPart = self.m_ResultData.select_part
			self.m_EnterFuben = self.m_ResultData.enter
			Utils.AddTimer(function ()
				self:OnTurnResult()
				end, 0, 2)
		end
		
	elseif oCtrl.m_EventID == define.PEFuben.Event.UpdateLock then
		self.m_Lock = oCtrl.m_EventData["lock"]
		self:RefreshLock()
	end
end

function CPEFbView.OnAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.UpdateDay then
		self:UpdateDay()
	elseif oCtrl.m_EventID == define.Attr.Event.Change then
		self:UpdateAttr()
	end
end

function CPEFbView.RefreshAI(self)
	local t = {
		fb_id = 1,
		open_floor = 2,
		max_times = 5,
		use_times = 3,
		buy_times = 0,
		today_buy = 0,
		select_part = 3,
		select_equip = 3,
		lock = 0,
	}
	self:RefreshData(t)
	self.m_SelectEquip = 1
	self.m_SelectPart = 4
	self.m_EnterFuben = 1
	self:StartRoll()
	Utils.AddTimer(function ()
		self:OnTurnResult()
		end, 0, 5)

end

function CPEFbView.UpdateDay(self)
	g_ActivityCtrl:GetPEFbCtrl():ChooseFuben(0)
	CPEFbDropView:CloseView()
end

function CPEFbView.UpdateAttr(self)
	self.m_TLLabel:SetText(string.format("%d/%d", g_AttrCtrl.energy, g_AttrCtrl:GetMaxEnergy()))
	self.m_SJLabel:SetNumberString(g_AttrCtrl.goldcoin)
end

function CPEFbView.RefreshData(self, fdata)
	self.m_ID = fdata.fb_id
	self.m_OpenFloor = fdata.open_floor
	self.m_SelectPart = fdata.select_part
	CPEFbView.m_SelectPart = fdata.select_part
	self.m_SelectEquip = fdata.select_equip
	self.m_Lock = fdata.lock
	self.m_ResetCost = fdata.reset_cost
	self.m_Energy = fdata.energy
	self.m_FloorData = fdata.floors or {}
	self.m_Remain = fdata.remain or 0
	self.m_RestLabel:SetText("本日剩余次数："..tostring(self.m_Remain))
	local itemCount = g_ItemCtrl:GetTargetItemCountBySid(10030) or 0
	self.m_SDQLabel:SetText(tostring(itemCount))
	local fbdata = data.pefubendata.FUBEN[self.m_ID]
	self.m_MaxFloor = fbdata.floor_cnt
	self.m_EquipList = fbdata.equip

	if self.m_SelectPart > 0 then
		self.m_StartBtn:SetText("重新抽取")
		self.m_RollGold:SetActive(true)
		self.m_RollGold:SetText(tostring(self.m_ResetCost))
	else
		self.m_FilterBtn:SetActive(false)
		self.m_RollGold:SetActive(false)
		self.m_StartBtn:SetText("免费抽取")
	end
	self.m_CostLabel:SetText(tostring(self.m_Energy))
	self.m_AddFubenBtn:SetActive(false)
	self:RefreshDrop()
	self:RefreshGrid()
	self:RefreshRoll()
	self:RefreshLock()
	self:RefreshFilter()
	self:RefreshName()
	self.m_State = State.Normal
	CPEFbBuyView:CloseView()
end

function CPEFbView.RefreshGrid(self)
	self.m_Grid:Clear()
	for i = 1, self.m_MaxFloor do
		local itemobj = self:CreateItemobj()
		itemobj.m_Label:SetText(string.format("第%d层", i))
		itemobj:AddUIEvent("click", callback(self, "DoCallback", "OnClickFloor", i))
		local d = self.m_FloorData[i]
		for i = 1, 3 do
			if d and d.star >= i then
				itemobj.m_StarList[i]:SetSpriteName("pic_chapter_star_putong")
			else
				itemobj.m_StarList[i]:SetSpriteName("pic_chapter_star_kong")
			end
		end
		if i > self.m_OpenFloor+1 then
			itemobj.m_GreyObj:SetActive(true)
		end
		self.m_Grid:AddChild(itemobj)
	end
	
	local lastfloor = IOTools.GetRoleData("pefb_floor") or 1
	local idx = math.max(1, lastfloor)
	if idx + 5 > self.m_MaxFloor then
		idx = self.m_MaxFloor - 5
	end

	local child = self.m_Grid:GetChild(idx)
	local selectchild = self.m_Grid:GetChild(math.min(self.m_MaxFloor, lastfloor))
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
	selectchild:SetSelected(true)
	UITools.MoveToTarget(self.m_ScrollView, child)
	self.m_Floor = math.min(self.m_MaxFloor, lastfloor)
	self:OnClickFloor(self.m_Floor)
end

function CPEFbView.CreateItemobj(self)
	local itemobj = self.m_Itemobj:Clone()
	itemobj.m_Label = itemobj:NewUI(1, CLabel)
	itemobj.m_GreyObj = itemobj:NewUI(2, CSprite)
	itemobj.m_StarList = {}
	for i = 1, 3 do
		itemobj.m_StarList[i] = itemobj:NewUI(2+i, CSprite)
	end
	itemobj:SetGroup(self.m_Grid:GetInstanceID())
	itemobj:SetActive(true)
	itemobj.m_GreyObj:AddUIEvent("click", function ()
		if self.m_State ~= State.Normal then
			g_NotifyCtrl:FloatMsg("请先通关上层副本")
		end
	end)
	itemobj.m_GreyObj:SetActive(false)
	return itemobj
end

function CPEFbView.RefreshRoll(self)
	local idx = 1
	for i = 1, 5 do
		local equiptype = self.m_EquipList[i]
		local tdata = data.partnerequipdata.ParSoulType[equiptype]
		if tdata then
			self.m_PEBoxList[i]:AddUIEvent("click", callback(self, "DoCallback", "ShowTips", equiptype))
			self.m_PEBoxList[i].m_IconSpr:SpriteItemShape(tdata["icon"])
			self.m_PEBoxList[i].m_LockSpr:SetActive(false)
			self.m_PEBoxList[i].m_Type = equiptype
		end
		if equiptype == self.m_SelectEquip then
			idx = i
		end
	end
	

	if idx then
		self.m_SelectPESpr:SetLocalRotation(Quaternion.Euler(0, 0, (idx-1)*72 ))
		if self.m_Lock == 2 then
			self.m_PEBoxList[idx].m_LockSpr:SetActive(true)
		end
	end

	if self.m_SelectPart and self.m_SelectPart > 0 then
		self.m_PosSprList[1]:SetSpriteName("pic_peattr_"..tonumber(self.m_SelectPart))
		self.m_PosSprList[1].m_PosIdx = self.m_SelectPart
	else
		local x = 1
		self.m_PosSprList[1]:SetSpriteName("pic_peattr_"..tonumber(x))
		self.m_PosSprList[1].m_PosIdx = x
	end
	for i = 2, 3 do
		local x = self.m_PosSprList[i-1].m_PosIdx
		x = (x + 12 + Utils.RandomInt(1, 12)) % 13 + 1
		self.m_PosSprList[i]:SetSpriteName("pic_peattr_"..tonumber(x))
		self.m_PosSprList[i].m_PosIdx = x
	end
	
	self.m_PosSprList[1]:SetLocalPos(Vector3.New(0, 0, 0))
	self.m_PosSprList[2]:SetLocalPos(Vector3.New(0, -80, 0))
	self.m_PosSprList[3]:SetLocalPos(Vector3.New(0, -160, 0))
	self.m_PosLockSpr:SetActive(self.m_Lock == 1)
end

function CPEFbView.RefreshName(self)
	if self.m_SelectEquip > 0 then
		local tdata = data.partnerequipdata.ParSoulType[self.m_SelectEquip]
		local name = ""
		if tdata then
			name = tdata["name"]
		end
		local parttext = data.partnerequipdata.ParSoulAttr[self.m_SelectPart]["text"]
		self.m_NameLabel:SetActive(true)
		self.m_NameLabel:SetText(name.."·"..parttext)
		self.m_AttrTypeLabel:SetActive(true)
		self.m_AttrTypeLabel:SetText(parttext)
	else
		self.m_AttrTypeLabel:SetActive(false)
		self.m_NameLabel:SetActive(false)
	end
end

function CPEFbView.RefreshLock(self)
	if self.m_SelectPart > 0 then
		self.m_EquipLockBox:SetActive(false)
		self.m_PartLockBox:SetActive(false)
		
		self.m_EquipLockBox.m_UnLockSpr:SetActive(self.m_Lock ~= 2)
		self.m_PartLockBox.m_UnLockSpr:SetActive(self.m_Lock ~= 1)
		
		self.m_EquipLockBox.m_LockSpr:SetActive(self.m_Lock == 2)
		self.m_PartLockBox.m_LockSpr:SetActive(self.m_Lock == 1)
		
		self.m_PartLockBox.m_Label:SetText("锁定部位")
		self.m_PartLockBox.m_Gold:SetText("10")
		self.m_EquipLockBox.m_Label:SetText("锁定套装")
		self.m_EquipLockBox.m_Gold:SetText("10")
		
		self.m_PartLockBox.m_Gold:SetActive(true)
		self.m_EquipLockBox.m_Gold:SetActive(true)
		
		--self.m_EquipLockSpr:SetActive( self.m_Lock == 2)
		--self.m_PartLockSpr:SetActive( self.m_Lock == 1)
		if self.m_Lock == 1 then
			self.m_PartLockBox.m_Label:SetText("已锁定部位")
			self.m_PartLockBox.m_Gold:SetActive(false)

		
		elseif self.m_Lock == 2 then
			self.m_EquipLockBox.m_Label:SetText("已锁定套装")
			self.m_EquipLockBox.m_Gold:SetActive(false)
		end

		local idx = nil
		for i = 1, 5 do
			local equiptype = self.m_EquipList[i]
			if equiptype == self.m_SelectEquip then
				idx = i
			end
		end
		if idx then
			self.m_PEBoxList[idx].m_LockSpr:SetActive(self.m_Lock == 2)
		end
		self.m_PosLockSpr:SetActive(self.m_Lock == 1)

	else
		self.m_EquipLockBox:SetActive(false)
		self.m_PartLockBox:SetActive(false)
	end
end

function CPEFbView.RefreshDrop(self)
	self.m_DropBtn:SetEnabled(true)
	self.m_DropBtn:SetText("更换\n掉落组")
	self.m_DropGrid:Clear()
	for i = 1, 6 do
		local equiptype = self.m_EquipList[i]
		local tdata = data.partnerequipdata.ParSoulType[equiptype]
		if tdata then
			local spr = self.m_DropSpr:Clone()
			spr:SpriteItemShape(tdata["icon"])
			spr:SetActive(true)
			self.m_DropGrid:AddChild(spr)
		end
	end
end

function CPEFbView.RefreshFilter(self)
	if self.m_SelectEquip > 0 then
		local tdata = data.partnerequipdata.ParSoulType[self.m_SelectEquip]
		local name = ""
		if tdata then
			name = tdata["name"]
		end
		local parttext = string.number2text(self.m_SelectPart, true)
		
		self.m_FilterName:SetText(name.."·"..parttext)
		self.m_FilterIcon:SpriteItemShape(tdata["icon"])
		local name = string.format("pic_fuwen_daoju%d", self.m_SelectPart)
		self.m_FilterPosIcon:SetSpriteName(name)
	end
end


function CPEFbView.OnStart(self)
	if not g_ActivityCtrl:ActivityBlockContrl("pefuben") then
		return
	end
	if self:ShowDrawTip() then
		if self.m_SelectPart > 0 and g_WindowTipCtrl:IsShowTips("pefb_turn_tip") then
			local windowConfirmInfo = {
				msg				= string.format("是否消耗%d金币重新抽取", self.m_ResetCost),
				okCallback		= function ()
					g_ActivityCtrl:GetPEFbCtrl():StartTurn(self.m_ID)
				end,
				selectdata		={
					text = "今日内不再提示",
					CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "pefb_turn_tip")
				},
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			if g_AttrCtrl.energy < self.m_Energy then
				self.OnShowEnergyTip()
			else
				g_ActivityCtrl:GetPEFbCtrl():StartTurn(self.m_ID)
			end
		end
	end
end

function CPEFbView.OnShowEnergyTip(self)
	if g_WelfareCtrl:IsFreeEnergyRedDot() then
		local windowConfirmInfo = {
			msg = "有未领取的体力，是否前往领取？",
			title = "提示",
			okCallback = function () 
				g_WelfareCtrl:ForceSelect(define.Welfare.ID.FreeEnergy)
			end,
			cancelCallback = function ()
				g_NpcShopCtrl:ShowGold2EnergyView()
			end,
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_NpcShopCtrl:ShowGold2EnergyView()
	end
end

function CPEFbView.StartRoll(self)
	self.m_State = State.Roll
	self.m_EquipLockBox:SetActive(false)
	self.m_PartLockBox:SetActive(false)
	self.m_AttrTypeLabel:SetActive(false)
	self.m_MaskObj:SetActive(true)
	if self.m_RollTimer then
		Utils.DelTimer(self.m_RollTimer)
	end
	self.m_Speed = 1
	if not self.m_TypeIdx then
		self.m_TypeIdx = 1
	end
	self.m_PosIdx = nil
	self.m_DetalRotation = 0
	self.m_F = 5		--频率
	self.m_F2 = 3
	local idx = 1
	local idx = 1
	local function update()
		if Utils.IsNil(self) then
			return
		end
		idx = idx + 1
		local bStop = 0
		if idx % self.m_F2 == 0 then
			self:ScrollPos()
		end

		-- if idx%self.m_F == 0 then
		-- 	self:NextPos()
		-- end
		self:NextPos()
		if self:IsOverRoll() then
			self:StopRoll()
			return false
		end
		return true
	end
	self.m_RollTimer = Utils.AddTimer(update, 0.03, 0)
	self:CreateUpSpeedTimer()
end

function CPEFbView.CreateUpSpeedTimer(self)
	if self.m_SpeedTimer then
		Utils.DelTimer(self.m_SpeedTimer)
	end
	self.m_FList = {5, 4, 3, 2, 1}
	self.m_FList2 = {3, 2, 1, 1, 1}
	local idx = 1
	local function update()
		if Utils.IsNil(self) then
			return
		end
		self.m_F = self.m_FList[idx]
		self.m_F2 = self.m_FList2[idx]
		idx = idx + 1
		if idx > 5 then
			return false
		else
			return true
		end
	end
	self.m_SpeedTimer = Utils.AddTimer(update, 0.2, 0)
end

function CPEFbView.CreateDownSpeedTimer(self)
	if self.m_SpeedTimer then
		Utils.DelTimer(self.m_SpeedTimer)
	end
	self.m_FList = {1, 2, 3, 4, 5}
	self.m_FList2 = {1, 1, 2, 3, 3}
	local idx = 1
	local function update()
		if Utils.IsNil(self) then
			return
		end
		self.m_F = self.m_FList[idx]
		self.m_F2 = self.m_FList2[idx]
		idx = idx + 1
		if idx > 5 then
			return false
		else
			return true
		end
	end
	self.m_SpeedTimer = Utils.AddTimer(update, 0.2, 0)
end

function CPEFbView.NextPos(self)
	local isEnd = self.m_State == State.RollEnd and self.m_F == 5
	if isEnd and self.m_TypeIdx == self.m_LastTypeIdx and self.m_DetalRotation == 0 then
		
	elseif self.m_Lock == 2 then

	else
		local d = 24/self.m_F
		self.m_DetalRotation = self.m_DetalRotation + 24/self.m_F
		local delta = self.m_DetalRotation - 72
		if (delta > 0 and delta < d) or (delta < 0 and delta > -d) then
			self.m_DetalRotation = 72
		end
		if self.m_DetalRotation == 72 then
			self.m_TypeIdx = self.m_TypeIdx % 5 + 1
			self.m_DetalRotation = 0
		end
		self.m_SelectPESpr:SetLocalRotation(Quaternion.Euler(0, 0, (self.m_TypeIdx-1) * -72 - self.m_DetalRotation))
	end
end

function CPEFbView.ScrollPos(self, iPos)
	if self.m_Lock == 1 then
		return
	end
	local isEnd = self.m_State == State.RollEnd and self.m_F == 5
	if isEnd and self.m_PosIdx == self.m_LastPosIdx then
		return
	end
	for i = 1, 3 do
		local v = self.m_PosSprList[i]:GetLocalPos()
		v.y = v.y + 20
		if v.y > 80 then
			v.y = v.y - 240
			local j = (i + 1) % 3 + 1
			local idx = self.m_PosSprList[j].m_PosIdx
			if isEnd and idx ~= self.m_LastPosIdx then
				idx = self.m_LastPosIdx
			else
				idx = (idx + 12 + Utils.RandomInt(1, 12)) % 13 + 1
			end
			self.m_PosSprList[i]:SetSpriteName("pic_peattr_"..tonumber(idx))
			self.m_PosSprList[i].m_PosIdx = idx
		end
		if v.y == 0 and isEnd then
			self.m_PosIdx = self.m_PosSprList[i].m_PosIdx
		end
		self.m_PosSprList[i]:SetLocalPos(v)
	end
end

function CPEFbView.IsOverRoll(self)
	if self.m_State ~= State.RollEnd then
		return false
	end
	
	if self.m_F ~= 5 then
		return false
	end
	
	if self.m_Lock ~=1 and self.m_PosIdx ~= self.m_LastPosIdx then
		return false
	end

	if self.m_Lock ~= 2 and (self.m_TypeIdx ~= self.m_LastTypeIdx or self.m_DetalRotation ~= 0) then
		return false
	end

	return 1
end

function CPEFbView.EndRoll(self)
	self.m_State = 2
	self:CreateDownSpeedTimer()
	self.m_LastTypeIdx = 1
	for i = 1, 5 do
		if self.m_PEBoxList[i].m_Type == self.m_SelectEquip then
			if i == 1 then
				self.m_LastTypeIdx = 1
			else
				self.m_LastTypeIdx = 7-i
			end
			break
		end
	end
	self.m_LastPosIdx = self.m_SelectPart
end

function CPEFbView.StopRoll(self)
	self.m_State = State.Normal
	self.m_EquipLockBox:SetActive(true)
	self.m_PartLockBox:SetActive(true)
	self.m_MaskObj:SetActive(false)
	local x = 3
	local function update()
		if Utils.IsNil(self) then
			return
		end
		x = x - 1
		if x == 0 then
			self:OnAutoEnterFuben()
		end
		if x < 0 then
			return false
		else
			return true
		end
	end
	if self.m_EnterFuben == 1 then
		Utils.AddTimer(update, 1, 0)
		self.m_State = State.AutoFuben
		self:ShowResultTip(true)
	elseif self.m_EnterFuben == 2 then
		self:OnFastClear()
	end
	self:RefreshLock()
	self:RefreshName()
	self.m_EnterFuben = 0
	if self.m_SelectPart > 0 then
		self.m_StartBtn:SetText("重新抽取")
		self.m_RollGold:SetActive(true)
		self.m_RollGold:SetText(tostring(self.m_ResetCost))
	else
		self.m_StartBtn:SetText("免费抽取")
		self.m_RollGold:SetActive(false)
	end
end

function CPEFbView.OnTurnResult(self)
	if Utils.IsNil(self) then
		return
	else
		self:RefreshFilter()
		self:EndRoll()
	end
end

function CPEFbView.OnChangeFlash(self)
	if self.m_FlashBtn:GetSelected() then
		self.m_IsJumpFlash = true
		IOTools.SetRoleData("pefb_jumpflash", 1)
	else
		self.m_IsJumpFlash = false
		IOTools.SetRoleData("pefb_jumpflash", 0)
	end
end

function CPEFbView.OnClickFloor(self, iFloor)
	self.m_Floor = iFloor
	if g_WelfareCtrl:HasZhongShengKa() then
		self.m_AutoFightFreeSpr:SetActive(true)
		self.m_AutoFightCostLabel:SetActive(false)
	else
		self.m_AutoFightFreeSpr:SetActive(false)
		self.m_AutoFightCostLabel:SetActive(true)
		local sweepCount = 2
		if self.m_FloorData[self.m_Floor] then
			sweepCount = self.m_FloorData[self.m_Floor]["sweep_cost"]
		end
		self.m_AutoFightCostLabel:SetText(tostring(sweepCount))
	end
	local iStar = 0
	if self.m_FloorData[self.m_Floor] then
		iStar = self.m_FloorData[self.m_Floor]["star"]
	end
	if iStar < 3 then
		self.m_AutoFightBtn:SetSpriteName("btn_erji_anhua")
	else
		self.m_AutoFightBtn:SetSpriteName("btn_erji_anniu")
	end

	IOTools.SetRoleData("pefb_floor", iFloor)
end

function CPEFbView.OnClickPartLock(self)
	if self:ShowDrawTip() then
		if self.m_PartLockBox.m_LockSpr:GetActive() then
			self:UnLockPart()
		else
			self:LockPart()
		end
	end
end

function CPEFbView.OnClickEquipLock(self)
	if self:ShowDrawTip() then
		if self.m_EquipLockBox.m_LockSpr:GetActive() then
			self:UnLockEquip()
		else
			self:LockEquip()
		end
	end
end

function CPEFbView.UnLockPart(self)
	local tMsg = "确认解锁部位？"
	local windowConfirmInfo = {
		msg				= tMsg,
		okCallback		= function ()
			g_ActivityCtrl:GetPEFbCtrl():PELock(self.m_ID, 0)
		end,
		countdown = 15,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CPEFbView.LockPart(self)
	if g_WindowTipCtrl:IsShowTips("pefb_lock_tip") then
		local locktip = ""
		if self.m_Lock == 2 then
			locktip = "\n#R锁定部位时，套装将会自动解锁#n"
		end
		local parttext = string.number2text(self.m_SelectPart, true)
		local tMsg = string.format("确认消耗10水晶锁定部位？\n副本第一件必定掉落【%s号位】%s", parttext, locktip)
		local windowConfirmInfo = {
			msg				= tMsg,
			okCallback		= function ()
				g_ActivityCtrl:GetPEFbCtrl():PELock(self.m_ID, 1)
			end,
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "pefb_lock_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_ActivityCtrl:GetPEFbCtrl():PELock(self.m_ID, 1)
	end
end

function CPEFbView.UnLockEquip(self)
	local tMsg = "确认解锁套装？"
	local windowConfirmInfo = {
		msg				= tMsg,
		okCallback		= function ()
			g_ActivityCtrl:GetPEFbCtrl():PELock(self.m_ID, 0)
		end,
		countdown = 15,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CPEFbView.LockEquip(self)
	if g_WindowTipCtrl:IsShowTips("pefb_lock_tip") then
		local tdata = data.partnerequipdata.ParSoulType[self.m_SelectEquip]
		local name = ""
		if tdata then
			name = tdata["name"]
		end
		local locktip = ""
		if self.m_Lock == 1 then
			locktip = "\n#R锁定套装时，部位将会自动解锁#n"
		end

		local tMsg = string.format("确认消耗10水晶锁定套装？\n副本第一件必定掉落【%s】%s", name, locktip)
		local windowConfirmInfo = {
			msg				= tMsg,
			okCallback		= function ()
				g_ActivityCtrl:GetPEFbCtrl():PELock(self.m_ID, 2)
			end,
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "pefb_lock_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		g_ActivityCtrl:GetPEFbCtrl():PELock(self.m_ID, 2)
	end
end

function CPEFbView.OnEnterFuben(self)
	if not g_ActivityCtrl:ActivityBlockContrl("pefuben") then
		return
	end

	if self.m_SelectPart > 0 then
		if self:ShowDrawTip() then			
			g_ActivityCtrl:GetPEFbCtrl():EnterFuben(self.m_ID, self.m_Floor)
		end
	else		
		if g_AttrCtrl.energy < self.m_Energy then
			self.OnShowEnergyTip()
		else
			g_ActivityCtrl:GetPEFbCtrl():EnterFuben(self.m_ID, self.m_Floor)
		end
	end
end

function CPEFbView.OnAutoEnterFuben(self)
	self.m_State = State.Normal
	self.m_MaskObj:SetActive(false)
	self:OnEnterFuben()
	self:CloseView()
end

function CPEFbView.OnFastClear(self)
	if not g_ActivityCtrl:ActivityBlockContrl("pefuben") then
		return
	end
	if self.m_SelectPart > 0 then
		if self:ShowDrawTip() then			
			g_ActivityCtrl:GetPEFbCtrl():EnterFuben(self.m_ID, self.m_Floor, 1)
		end
	else		
		if g_AttrCtrl.energy < self.m_Energy then
			self.OnShowEnergyTip()
		else
			g_ActivityCtrl:GetPEFbCtrl():EnterFuben(self.m_ID, self.m_Floor, 1)
		end
	end
end

function CPEFbView.TryFastClear(self)
	local iStar = 0
	if self.m_FloorData[self.m_Floor] then
		iStar = self.m_FloorData[self.m_Floor]["star"]
	end
	if iStar < 3 then
		g_NotifyCtrl:FloatMsg("三星通关开启扫荡")
		return
	end
	if g_WelfareCtrl:HasZhongShengKa() then
		self:OnFastClear()
		return
	end
	local itemCount = g_ItemCtrl:GetTargetItemCountBySid(10030)
	local sweepCount = 0
	if self.m_FloorData[self.m_Floor] then
		sweepCount = self.m_FloorData[self.m_Floor]["sweep_cost"]
	end
	if itemCount < sweepCount then
		if g_WindowTipCtrl:IsShowTips("pefbfastclear") then
			local cost = data.itemdata.OTHER[10030].buy_price
			local windowConfirmInfo = {
				msg				= string.format("扫荡券不足，是否花费#w2%d补足\n终身卡可免费扫荡", (sweepCount - itemCount) * cost),
				okCallback 		= function()
					self:OnFastClear()
				end,
				okStr			= "确认",
				selectdata		= {
					text = "今日内不再提示",
					CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "pefbfastclear"),
				},
				thirdStr  		= "购买终身卡",
				thirdCallback  = function ()
					self:OnClose()
					g_WelfareCtrl:ForceSelect(define.Welfare.ID.Yk)
				end

			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			return
		else
			self:OnFastClear()
		end
	else
		self:OnFastClear()
	end
end

function CPEFbView.OnShowFilterView(self)
	if self:ShowDrawTip() then
		CPESelectView:ShowView(function (oView)
			oView:RefreshKey(self.m_SelectPart, self.m_SelectEquip)
		end)
	end
end

function CPEFbView.OnShowAddFuben(self)
end

function CPEFbView.OnShowDropView(self)
	nethuodong.C2GSOpenPEFuBenSchedule()
end


function CPEFbView.ShowTips(self, equip_type, oItem)
	local typedata = data.partnerequipdata.ParSoulType[equip_type]
	self.m_SkillBox:SetActive(true)
	self.m_SKillName:SetText(typedata["name"])
	self.m_SkillIcon:SpriteItemShape(typedata["icon"])
	local str = string.format("套装属性：%s", typedata["skill_desc"])
	self.m_SkillDesc:SetText(str)
	local lw, lh = self.m_SkillBox:GetSize()
	self.m_SKillBG:SetSize(220, 20+lh)
	UITools.NearTarget(oItem, self.m_SkillBox, enum.UIAnchor.Side.Top, Vector2.New(20, 0))
end

function CPEFbView.CloseTips(self)
	self.m_SkillBox:SetActive(false)
end

function CPEFbView.ShowDrawTip(self)
	if self.m_State == State.AutoFuben then
		g_NotifyCtrl:FloatMsg("正在进入副本")
		return false

	elseif self.m_State ~= State.Normal then
		g_NotifyCtrl:FloatMsg("正在抽取")
		return false
	end

	return true
end

function CPEFbView.ShowResultTip(self, isauto)
	g_NotifyCtrl:FloatMsg("3秒内进入副本")
end

-- function CPEFbView.SetTodayTip(self, key, bselect)
-- 	if bselect then
-- 		local dict = IOTools.GetRoleData("confirmtiptime") or {}
-- 		dict[key] = g_TimeCtrl:GetTimeS()
-- 		IOTools.SetRoleData("confirmtiptime", dict)
-- 	end
-- end

-- function CPEFbView.IsShowTips(self, key)
-- 	local dict = IOTools.GetRoleData("confirmtiptime") or {}
-- 	local sc = dict[key]
-- 	if sc and g_TimeCtrl:IsToday(tonumber(sc)) then
-- 		return false
-- 	else
-- 		return true
-- 	end
-- end

function CPEFbView.OnHelpTip(self)
	CHelpView:ShowView(function(oView)
		oView:ShowHelp(self.m_HelpKey)
	end)
end

function CPEFbView.OnAddEnergy(self)
	g_NpcShopCtrl:ShowGold2EnergyView()
end

function CPEFbView.OnAddGoldCoin(self)
	g_SdkCtrl:ShowPayView()
end

return CPEFbView
