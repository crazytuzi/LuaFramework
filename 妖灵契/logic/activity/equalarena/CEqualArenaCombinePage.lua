local CEqualArenaCombinePage = class("CEqualArenaCombinePage", CPageBase)

function CEqualArenaCombinePage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CEqualArenaCombinePage.OnInitPage(self)
	self.m_CountDownSlot = self:NewUI(1, CBox)
	self.m_CountDownPrefab = self:NewUI(2, CCountDownBox)
	self.m_SubmitBtn = self:NewUI(3, CButton)
	self.m_DownNameLabel = self:NewUI(4, CLabel)
	self.m_DownReadMask = self:NewUI(5, CLabel)
	self.m_DownGrid = self:NewUI(6, CGrid)
	self.m_UpNameLabel = self:NewUI(7, CLabel)
	self.m_UpReadMask = self:NewUI(8, CLabel)
	self.m_UpGrid = self:NewUI(9, CGrid)
	self.m_UpEquipGrid = self:NewUI(10, CGrid)
	self.m_UpPlayerSprite = self:NewUI(11, CSprite)
	self.m_DownPlayerSprite = self:NewUI(12, CSprite)
	self.m_DownEquipGrid = self:NewUI(13, CGrid)
	self:InitContent()
end

function CEqualArenaCombinePage.InitContent(self)
	self.m_CountDownBox = self.m_CountDownPrefab:Clone()
	self.m_CountDownBox:SetParent(self.m_CountDownSlot.m_Transform)
	self.m_Submited = false
	self.m_DownReadMask:SetText("准备中...")
	self.m_UpReadMask:SetText("准备中...")
	self.m_DownGrid:InitChild(function (obj, idx)
		local oPartnerBox = CBox.New(obj)
		-- oPartnerBox.m_Index = idx
		oPartnerBox.m_Equip = nil
		oPartnerBox.m_Shape = nil
		oPartnerBox.m_Texture = oPartnerBox:NewUI(1, CTexture)
		oPartnerBox.m_NameLabel = oPartnerBox:NewUI(2, CLabel)
		oPartnerBox.m_Bg = oPartnerBox:NewUI(3, CSprite)
		oPartnerBox.m_Sprite = oPartnerBox:NewUI(4, CSprite)
		oPartnerBox.m_StatusLabel = oPartnerBox:NewUI(5, CLabel)
		oPartnerBox.m_DescLabel = oPartnerBox:NewUI(6, CLabel)
		oPartnerBox:AddUIEvent("click", callback(self, "OnClickSelect", oPartnerBox))
		
		return oPartnerBox
	end)

	self.m_DownEquipGrid:InitChild(callback(self, "InitEquipBox"))

	self.m_UpGrid:InitChild(function (obj, idx)
		local oPartnerBox = CBox.New(obj)
		oPartnerBox.m_Texture = oPartnerBox:NewUI(1, CTexture)
		oPartnerBox.m_NameLabel = oPartnerBox:NewUI(2, CLabel)
		return oPartnerBox
	end)
	self.m_UpEquipGrid:InitChild(callback(self, "InitEquipBox"))

	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEqualEvent"))
	self:SetData()
end

function CEqualArenaCombinePage.InitEquipBox(self, obj, idx)
	local oEquipBox = CSprite.New(obj)

	function oEquipBox.ShowHint(self)
		local oView = CNotifyView:GetView()
		if oView and oEquipBox.m_EquipData then
			oView:ShowHint(oEquipBox.m_EquipData.skill_desc, oEquipBox, enum.UIAnchor.Side.Bottom)
		end
	end
	oEquipBox:AddUIEvent("click", callback(oEquipBox, "ShowHint"))

	function oEquipBox.SetData(self, oData)
		local equipData = data.partnerequipdata.ParSoulType[oData]
		if equipData then
			oEquipBox:SpriteItemShape(equipData.icon)
			oEquipBox.m_EquipData = equipData
		else
			oEquipBox.m_EquipData = nil
			oEquipBox:SetSpriteName("")
		end
	end
	return oEquipBox
end

function CEqualArenaCombinePage.ShowHint(self, oEquipBox)
	
end

function CEqualArenaCombinePage.OnEqualEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EqualArena.Event.OnCombineDone then
		if oCtrl.m_EventData == g_AttrCtrl.pid then
			self.m_DownReadMask:SetText("准备完成")
			self.m_SubmitBtn:SetText("已准备")
		else
			self.m_UpReadMask:SetText("准备完成")
		end
	elseif oCtrl.m_EventID == define.EqualArena.Event.OnCombineSubmit then
		self.m_Submiting = false
	end
end

-- function CEqualArenaCombinePage.SetCountDownText(self, value)
-- 	self.m_CountDownLabel:SetText(tostring(value))
-- end

function CEqualArenaCombinePage.BeginCountDown(self, countDown)
	self.m_CountDownBox:BeginCountDown(countDown)
	-- self.m_CountDownLabel:SetTimeUPCallBack(callback(self, "OnTimeUP"))
	-- self.m_CountDownLabel:BeginCountDown(countDown)
end

function CEqualArenaCombinePage.OnTimeUP(self)
	-- self.m_CountDownLabel:SetText("0")
end

function CEqualArenaCombinePage.ExchangePartner(self, oPartnerBox, oTargetPartnerBox)
	local equipTemp = oPartnerBox.m_Equip
	oPartnerBox.m_Equip = oTargetPartnerBox.m_Equip
	oTargetPartnerBox.m_Equip = equipTemp
	self:CheckColor(oPartnerBox)
	self:CheckColor(oTargetPartnerBox)
	local tempPos = oPartnerBox:GetLocalPos()
	local targetPos = oTargetPartnerBox:GetLocalPos()
	local tempScale = Vector3.one
	local targetScale = Vector3.one
	if not oPartnerBox.m_Equip then
		targetScale = Vector3.New(0.75, 0.75, 0.75)
	end
	if not oTargetPartnerBox.m_Equip then
		tempScale = Vector3.New(0.75, 0.75, 0.75)
	end
	local iDistance = tempPos.x - targetPos.x
	local tween = DOTween.DOScale(oPartnerBox.m_Transform, Vector3.New(0.01, 0.01, 0.01), 0.05)
	local tween1 = DOTween.DOScale(oTargetPartnerBox.m_Transform, Vector3.New(0.01, 0.01, 0.01), 0.05)
	DOTween.OnComplete(tween1, function()
		oPartnerBox:SetLocalPos(targetPos)
		oTargetPartnerBox:SetLocalPos(tempPos)
		DOTween.DOScale(oPartnerBox.m_Transform, targetScale, 0.15)
		DOTween.DOScale(oTargetPartnerBox.m_Transform, tempScale, 0.15)
	end)
	self:SubmitChange(2)
end

function CEqualArenaCombinePage.CheckColor(self, oPartnerBox)
	if oPartnerBox.m_Equip then
		local oEquipBox = self.m_DownEquipGrid:GetChild(oPartnerBox.m_Equip)
		
		oPartnerBox.m_Texture:SetColor(Color.white)
		oPartnerBox.m_Bg:SetColor(Color.white)
		-- oPartnerBox.m_Bg:SetLocalPos(Vector3.New(-5, 30, 0))
		-- oPartnerBox.m_StatusLabel:SetText("")
		oPartnerBox.m_StatusLabel:SetActive(false)
		
		oPartnerBox.m_DescLabel:SetText(oEquipBox.m_EquipData.simple_desc)
		oPartnerBox.m_Sprite:SetColor(Color.white)
		-- oPartnerBox.m_NameLabel:SetColor(Color.white)
	else
		local oColor = Color.New(0.7,0.7,0.7,1)
		-- oPartnerBox.m_StatusLabel:SetText("【备选】")
		oPartnerBox.m_StatusLabel:SetActive(true)
		oPartnerBox.m_DescLabel:SetText("")
		oPartnerBox.m_Texture:SetColor(oColor)
		oPartnerBox.m_Bg:SetColor(oColor)
		oPartnerBox.m_Sprite:SetColor(oColor)
		-- oPartnerBox.m_NameLabel:SetColor(oColor)
		oPartnerBox.m_Bg:SetLocalPos(Vector3.zero)
	end
end

function CEqualArenaCombinePage.SetData(self)
	self.m_Submiting = false
	self:BeginCountDown(g_EqualArenaCtrl:GetRestCombineTime())
	local oPartnerBox = nil
	for _,playerInfo in pairs(g_EqualArenaCtrl.m_CombineInfo) do
		if playerInfo.info.pid == g_AttrCtrl.pid then
			self.m_DownNameLabel:SetText(playerInfo.info.name)
			--玩家形象
			self.m_OwnPlayerInfo = playerInfo
			self.m_DownPlayerSprite:SpriteAvatar(playerInfo.info.shape)

			local dPartnerToFuwen = {}
			if playerInfo.select and #playerInfo.select > 3 then
				for i,v in ipairs(playerInfo.select) do
					dPartnerToFuwen[v.partner] = playerInfo.select_fuwen[v.fuwen]
				end
			else
				for i,equip in ipairs(playerInfo.select_fuwen) do
					dPartnerToFuwen[i] = equip
				end
			end
			local equipPos = 2
			local nonePos = 1
			for i,partnerInfo in ipairs(playerInfo.select_partner) do
				if dPartnerToFuwen[i] then
					oPartnerBox = self.m_DownGrid:GetChild(equipPos)
					oPartnerBox.m_Index = i
					oPartnerBox.m_Equip = i
					local oEquipBox = self.m_DownEquipGrid:GetChild(equipPos - 1)
					oEquipBox:SetData(dPartnerToFuwen[i])
					equipPos = equipPos + 1
				else
					oPartnerBox = self.m_DownGrid:GetChild(nonePos)
					oPartnerBox.m_Index = i
					nonePos = nonePos + 5
				end
				oPartnerBox.m_Shape = partnerInfo.model_info.shape
				oPartnerBox.m_Texture:LoadCardPhoto(partnerInfo.model_info.shape)
				oPartnerBox.m_NameLabel:SetText(partnerInfo.name)
				self:CheckColor(oPartnerBox)
			end
		else
			self.m_UpNameLabel:SetText(playerInfo.info.name)
			--玩家形象
			self.m_UpPlayerSprite:SpriteAvatar(playerInfo.info.shape)

			--伙伴形象
			for i,partnerInfo in ipairs(playerInfo.select_partner) do
				oPartnerBox = self.m_UpGrid:GetChild(i)
				oPartnerBox.m_Shape = partnerInfo.model_info.shape
				oPartnerBox.m_Texture:LoadCardPhoto(partnerInfo.model_info.shape)
				oPartnerBox.m_NameLabel:SetText(partnerInfo.name)
			end
			for i,equip in ipairs(playerInfo.select_fuwen) do
				local oEquipBox = self.m_UpEquipGrid:GetChild(i)
				oEquipBox:SetData(equip)
			end
		end
	end
end

function CEqualArenaCombinePage.OnClickSelect(self, oPartnerBox)
	if self.m_Submiting then
		-- g_NotifyCtrl:FloatMsg("操作过快")
		return
	elseif self.m_Submited then
		return
	end
	if self.m_CurrentSelect == nil then
		self.m_CurrentSelect = oPartnerBox
		if oPartnerBox.m_Equip then
			DOTween.DOScale(oPartnerBox.m_Transform, Vector3.New(0.9, 0.9, 0.9), 0.1)
		else
			DOTween.DOScale(oPartnerBox.m_Transform, Vector3.New(0.65, 0.65, 0.65), 0.1)
		end
		--选中第一个
	else
		--选中第二个
		self:ExchangePartner(oPartnerBox, self.m_CurrentSelect)
		self.m_CurrentSelect = nil
	end
end

function CEqualArenaCombinePage.OnSubmit(self)
	if self.m_CurrentSelect then
		if self.m_CurrentSelect.m_Equip then
			DOTween.DOScale(self.m_CurrentSelect.m_Transform, Vector3.one, 0.1)
		else
			DOTween.DOScale(self.m_CurrentSelect.m_Transform, Vector3.New(0.75, 0.75, 0.75), 0.1)
		end
		self.m_CurrentSelect = nil
	end
	if self.m_Submited then
		return
	end
	self.m_Submited = true
	self:SubmitChange(1)
end

function CEqualArenaCombinePage.SubmitChange(self, handleType)
	self.m_Submiting = true
	local partnerList = {}
	local equipList = {}
	for i = 1, self.m_DownGrid:GetCount() do
		local oPartnerBox = self.m_DownGrid:GetChild(i)
		if oPartnerBox.m_Equip then
			table.insert(partnerList, oPartnerBox.m_Index)
			table.insert(equipList, oPartnerBox.m_Equip)
		else
			-- oPartnerBox.m_ExchangeBtn:SetActive(false)
		end
	end

	netarena.C2GSConfigEqualArena(partnerList, equipList, handleType)
end


return CEqualArenaCombinePage