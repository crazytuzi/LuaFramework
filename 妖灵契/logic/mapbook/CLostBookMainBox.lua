local CLostBookMainBox = class("CLostBookMainBox", CBox)

function CLostBookMainBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_ConditionGrid = self:NewUI(2, CGrid)
	self.m_ConditionLabel = self:NewUI(3, CLabel)
	self.m_LockSpr = self:NewUI(4, CSprite)
	self.m_GreySpr = self:NewUI(5, CSprite)
	self.m_RepairBtn = self:NewUI(6, CButton)
	self.m_RedSpr = self:NewUI(7, CSprite)
	self.m_Slider = self:NewUI(8, CSlider)
	self.m_ProgressLabel = self:NewUI(9, CLabel)
	self.m_CardTexture = self:NewUI(10, CTexture)
	self.m_PressTipObj = self:NewUI(11, CWidget)
	self.m_EffectTexture = self:NewUI(12, CTexture)
	self:InitContent()
end

function CLostBookMainBox.InitContent(self)
	self.m_ConditionLabel:SetActive(false)
	self.m_CardTexture:SetActive(false)
	self.m_PressTipObj:AddUIEvent("longpress", function (a, bPress) if bPress then g_NotifyCtrl:FloatMsg("佚书修补进度") end end)
	self.m_RepairBtn:AddUIEvent("click", callback(self, "OnClickRepair"))
	self.m_RepairEffect = CEffect.New("Effect/UI/ui_eff_1165/Prefabs/ui_eff_1165.prefab", self:GetLayer(), false)
	self.m_RepairEffect:SetParent(self.m_RepairBtn.m_Transform)

	self.m_CardTexture:LoadCardPhoto(301)
end

function CLostBookMainBox.RefreshData(self, oData)
	self.m_PreData = self.m_Data or {}
	self.m_Data = oData
	self.m_ID = oData.id
	self:RefreshName()
	self:RefreshCondition()
	self:RefreshIcon()
	self:RefreshShow()
	self:RefreshRepair()
	self:RefreshProgress()
	self:RefreshRedSpr()
	self.m_IsUpdate = false
end


function CLostBookMainBox.UpdateData(self, oData)
	self.m_IsUpdate = true
	self:RefreshData(oData)
end

function CLostBookMainBox.RefreshName(self)
	local oData = self.m_Data
	self.m_NameLabel:SetText(oData.name)
	local idx = 1
	local function update()
		self.m_NameLabel:SetActive(true)
		self.m_NameLabel:SetAlpha(idx/10)
		if idx >= 10 then
			self.m_NameLabel:SetAlpha(1)
			return
		end
		idx = idx + 1
		return true
	end

	if self.m_PreData.entry_name ~= 0 then
		self.m_NameLabel:SetActive(oData.entry_name == 1)
	else
		if oData.entry_name == 1 then
			Utils.AddTimer(update, 0.1, 0)
		else
			self.m_NameLabel:SetActive(false)
		end
	end

end

function CLostBookMainBox.RefreshCondition(self)
	local oData = self.m_Data
	self.m_ConditionGrid:Clear()
	local conditiondata = data.mapbookdata.CONDITION
	local amount = 1
	for i, iCondition in ipairs(oData.condition_list) do
		if conditiondata[iCondition] then
			local itype = conditiondata[iCondition]["sub_type"]
			if (itype == 3 and not table.index(oData.condition, iCondition)) or itype == 1 then
			
			else
				local labelList = {}
				if table.index(oData.condition, iCondition) then
					labelList = self:CreateLabel(conditiondata[iCondition]["desc"], true)
				else
					labelList = self:CreateLabel(conditiondata[iCondition]["desc"])
				end
				for _, label in ipairs(labelList) do
					label:SetName(tostring(10-amount))
					self.m_ConditionGrid:AddChild(label)
					amount = amount + 1
				end
				
			end
		end
	end
	self.m_ConditionGrid:Reposition()
end

function CLostBookMainBox.CreateLabel(self, text, isgreen)
	self.m_CharLen = 10
	local label = self.m_ConditionLabel
	local resultList = {}
	local iLen = utf8.len(text)
	local iMax = math.ceil(iLen/self.m_CharLen)
	for i= 1, iMax do
		local iStart = math.max(1, (i - 1) * self.m_CharLen + 1)
		local sSub = utf8.sub(text, iStart, iStart + self.m_CharLen)
		local oLabel = label:Clone()
		if isgreen then
			oLabel:SetColor(Utils.HexToColor("00ff00ff"))
		end
		oLabel:SetActive(true)
		oLabel:SetText(sSub)
		table.insert(resultList, oLabel)
	end
	return resultList

end

function CLostBookMainBox.RefreshIcon(self)
	local oData = self.m_Data
	local edata = data.partnerequipdata.EQUIPTYPE[oData.target_id]
	self.m_CardTexture:SetActive(false)
	if edata then
		local sPath = string.format("Texture/PartnerEquip/bg_fw_"..edata.icon..".png")
		self.m_CardTexture:LoadPath(sPath , function() self.m_CardTexture:SetActive(true) end)

		self.m_EffectTexture:LoadPath(sPath)
	end
end

function CLostBookMainBox.RefreshShow(self)
	if self.m_Data.unlock == 0 then
		self.m_GreySpr:SetActive(true)
		self.m_Slider:SetActive(false)
		self.m_CardTexture:SetActive(false)
		self.m_PressTipObj:SetActive(false)
	else
		self.m_Slider:SetActive(true)
		self.m_CardTexture:SetActive(true)
		self.m_PressTipObj:SetActive(true)
		if self.m_PreData.unlock == 0 then
			self:DoShowEffect()
		else
			self.m_GreySpr:SetActive(false)
		end
		--self:DoShowEffect()
	end
end

function CLostBookMainBox.DoShowEffect(self)
	self.m_ShowEffect1 = CEffect.New("Effect/UI/ui_eff_1163/Prefabs/ui_eff_1163.prefab", self:GetLayer(), false)
	self.m_ShowEffect1:SetLocalPos(Vector3.New(0, -36, 0))
	self.m_ShowEffect1:SetParent(self.m_CardTexture.m_Transform)
	local t = 0
	Utils.AddTimer(function (dt)
		t = t + dt
		if Utils.IsNil(self) then
			return
		end
		if t >= 0.6 then
			self.m_GreySpr:SetActive(false)
		end
		if t >= 3 and self.m_ShowEffect1 then
			self.m_ShowEffect1:Destroy()
			self.m_ShowEffect1 = nil
			return
		end
		return true
	end, 0.1, 0)
end

function CLostBookMainBox.RefreshRepair(self)
	if self.m_Data.unlock == 1 then
		if self.m_Data.repair == 0 or self.m_Data.entry_name == 0 then
			self.m_RepairBtn:SetActive(true)
		else
			self.m_RepairBtn:SetActive(false)
		end
		if self.m_Data.repair == 1 then
			if self.m_PreData.repair == 0 then
				self:DoRepairEffect()
			end
			self.m_CardTexture:SetColor(Utils.HexToColor("ffffffff"))
		else
			self.m_CardTexture:SetColor(Utils.HexToColor("090707ff"))
		end
	else
		self.m_RepairBtn:SetActive(false)
	end
end

function CLostBookMainBox.DoRepairEffect(self)
	self.m_ShowEffect2 = CEffect.New("Effect/UI/ui_eff_1166/Prefabs/ui_eff_1166.prefab", self:GetLayer(), false)
	self.m_ShowEffect2:SetParent(self.m_CardTexture.m_Transform)
	self.m_EffectTexture:SetActive(true)
	
	Utils.AddTimer(function (dt)
		if Utils.IsNil(self) then
			return
		end
		if self.m_ShowEffect2 then
			self.m_ShowEffect2:Destroy()
			self.m_ShowEffect2 = nil
			return
		end
		return true
	end, 0, 3)
end

function CLostBookMainBox.RefreshProgress(self)
	local iPoint, iTotal = self:GetProgress(self.m_Data)
	self.m_Slider:SetValue(iPoint / iTotal)
	self.m_ProgressLabel:SetText(string.format("修复：%d/%d", iPoint, iTotal))
end

function CLostBookMainBox.GetProgress(cls, oData)
	local iPoint = 0
	local iTotal = 0
	iTotal = iTotal + oData.name_point
	if oData.entry_name == 1 then
		iPoint = iPoint + oData.name_point
	end
	
	iTotal = iTotal + oData.repair_point
	if oData.repair == 1 then
		iPoint = iPoint + oData.repair_point
	end

	iTotal = iTotal + oData.unlock_point
	if #oData.condition == #oData.condition_list and oData.unlock == 1 then
		iPoint = iPoint + oData.unlock_point
	end

	--前面3个条件达成，完整佚书
	if iPoint == iTotal then
		iPoint = iPoint + oData.book_point
	end
	iTotal = iTotal + oData.book_point

	iTotal = oData.chapter_point * (#oData.chapter_list) + iTotal
	for _, oChapter in ipairs(oData.chapter) do
		if oChapter.unlock == 1 then
			iPoint = oData.chapter_point + iPoint
		end
	end
	return iPoint, iTotal
end

function CLostBookMainBox.OnClickRepair(self)
	if self.m_Data.repair == 0 and self.m_Data.entry_name == 0 then
		self:RepairAll()
	
	elseif self.m_Data.repair == 0 then
		self:RepairBook()

	elseif self.m_Data.entry_name == 0 then
		self:RepairName()
	end

end

function CLostBookMainBox.RepairAll(self)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(11822)
	local windowConfirmInfo = {
		msg = "您可以消耗1个时光钥匙对该佚书进行绘像修复或者名字录入。",
		okStr = "修复绘象",
		title = "佚书修补",
		cancelStr = "录入名字",
		closeCallback = function() end,
		noCancelCbTouchOut = true,
		cancelCallback = function()
			nethandbook.C2GSEnterName(self.m_Data.id)
		end,
		okCallback = function()
			nethandbook.C2GSRepairDraw(self.m_Data.id)
		end
	}
	CMapBookConfirmView:ShowView(function(oView)
		oView:InitArg(windowConfirmInfo)
	end)
end

function CLostBookMainBox.RepairBook(self)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(11822)
	local windowConfirmInfo = {
		msg = "您可以消耗1个时光钥匙对该佚书进行绘像修复。",
		okStr = "修复绘象",
		title = "佚书修补",
		cancelStr = "取消",
		cancelCallback = function() end,
		okCallback = function()
			nethandbook.C2GSRepairDraw(self.m_Data.id)
		end
	}
	CMapBookConfirmView:ShowView(function(oView)
		oView:InitArg(windowConfirmInfo)
	end)
end

function CLostBookMainBox.RepairName(self)
	local amount = g_ItemCtrl:GetBagItemAmountBySid(11822)
	local windowConfirmInfo = {
		msg = "您可以消耗1个时光钥匙对该佚书进行名字录入。",
		okStr = "名字录入",
		title = "佚书修补",
		cancelStr = "取消",
		cancelCallback = function() end,
		okCallback = function()
			nethandbook.C2GSEnterName(self.m_Data.id)
		end
	}
	CMapBookConfirmView:ShowView(function(oView)
		oView:InitArg(windowConfirmInfo)
	end)
end

function CLostBookMainBox.RefreshRedSpr(self)
	local bNewChapter = false

	for _, oChapter in ipairs(self.m_Data.chapter) do
		local cdata = data.mapbookdata.CHAPTER[oChapter.id]
		-- if oChapter.unlock == 1 and #cdata.condition == #oChapter.condition and oChapter.read == 0 then
		-- 	bNewChapter = true
		-- 	break
		-- end
		if oChapter.unlock == 0 and #cdata.condition == #oChapter.condition then
			bNewChapter = true
			break
		end
	end

	if self.m_Data.unlock == 0 then
		if #self.m_Data.condition_list == #self.m_Data.condition then
			self.m_RedSpr:SetActive(true)
		else
			self.m_RedSpr:SetActive(false)
		end
	else
		if not bNewChapter then
			self.m_RedSpr:SetActive(self.m_Data.red_point > 1)
		else
			self.m_RedSpr:SetActive(bNewChapter)
		end
	end
end

return CLostBookMainBox