local CEqualArenaSelectPage = class("CEqualArenaSelectPage", CPageBase)

function CEqualArenaSelectPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CEqualArenaSelectPage.OnInitPage(self)
	self.m_TipsLabel = self:NewUI(1, CLabel)
	self.m_PartnerGrid = self:NewUI(2, CGrid)
	self.m_PartnerEquipGrid = self:NewUI(3, CGrid)
	self.m_CountDownSlot = self:NewUI(4, CBox)
	self.m_SubmitBtn = self:NewUI(5, CButton)
	self.m_LeftBox = self:NewUI(6, CBox)
	self.m_RightBox = self:NewUI(7, CBox)
	self.m_CountDownPrefab = self:NewUI(8, CCountDownBox)
	self:InitContent()
end

function CEqualArenaSelectPage.InitContent(self)
	self.m_PartnerBoxToNet = {1,2,9,3,4,5,6,7,8}
	self.m_NetToPartnerBox = {1,2,4,5,6,7,8,9,3}

	self.m_EquipBoxToNet = {1,2,3,4,5,9,6,7,8}
	self.m_NetToEquipBox = {1,2,3,4,5,7,8,9,6}
	self:InitGrid()
	self.m_CountDownBox = self.m_CountDownPrefab:Clone()
	self.m_CountDownBox:SetParent(self.m_CountDownSlot.m_Transform)
	self:CreateInfoBox(self.m_LeftBox)
	self:CreateInfoBox(self.m_RightBox)
	self.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit"))
	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEqualEvent"))
	self:SetData()
end

function CEqualArenaSelectPage.InitGrid(self)
	self.m_PartnerGrid:InitChild(function (obj, idx)
		local oPartnerBox = CBox.New(obj)
		oPartnerBox.m_Index = idx
		oPartnerBox.m_Status = define.EqualArena.MarkType.None
		oPartnerBox.m_BgSprite = oPartnerBox:NewUI(1, CButton)
		oPartnerBox.m_PartnerSprite = oPartnerBox:NewUI(2, CSprite)
		oPartnerBox.m_AwakeSprite = oPartnerBox:NewUI(3, CSprite)
		oPartnerBox.m_SelectSprite = oPartnerBox:NewUI(4, CSprite)
		oPartnerBox.m_SelectSprite:SetActive(false)
		-- oPartnerBox.m_SelectSprite:SetSpriteName("")
		oPartnerBox.m_BgSprite:AddUIEvent("click", callback(self, "SelectPartner", oPartnerBox))
		return oPartnerBox
	end)

	self.m_PartnerEquipGrid:InitChild(function (obj, idx)
		local oPartnerEquipBox = CBox.New(obj)
		oPartnerEquipBox.m_Index = idx
		oPartnerEquipBox.m_Status = define.EqualArena.MarkType.None
		oPartnerEquipBox.m_Sprite = oPartnerEquipBox:NewUI(1, CButton)
		oPartnerEquipBox.m_SelectSprite = oPartnerEquipBox:NewUI(2, CSprite)
		
		oPartnerEquipBox.m_SelectSprite:SetSpriteName("")
		oPartnerEquipBox.m_Sprite:AddUIEvent("click", callback(self, "SelectPartnerEquip", oPartnerEquipBox))
		return oPartnerEquipBox
	end)
	self.m_RandomParnerBox = self.m_PartnerGrid:GetChild(3)
	self.m_RandomParnerBox.m_AwakeSprite:SetActive(false)
	-- self.m_RandomParnerBox.m_PartnerSprite:SpriteItemShape(0)

	self.m_RandomEquipBox = self.m_PartnerEquipGrid:GetChild(6)
	-- self.m_RandomEquipBox.m_Sprite:SpriteItemShape(0)
end

function CEqualArenaSelectPage.SetData(self)
	if self.m_FirstSetData == nil then
		for k,v in pairs(g_EqualArenaCtrl.m_PlayerInfos) do
			if v.info.pid == g_AttrCtrl.pid then
				self.m_LeftBox:ChangeTexture(v.info.shape)
			else
				self.m_RightBox:ChangeTexture(v.info.shape)
			end
		end
		--设置初始符文列表
		for i,v in ipairs(g_EqualArenaCtrl.m_PartnerEquipList) do
			local oPartnerEquipBox = self.m_PartnerEquipGrid:GetChild(self:GetNetToEquipBoxIndex(i))
			local oData = data.partnerequipdata.ParSoulType[v]
			if oData then
				oPartnerEquipBox.m_Data = oData
				oPartnerEquipBox.m_Sprite:SpriteItemShape(oData.icon)
			else
				printc(string.format("<color=#ff0000>ID:%s 符文套装不存在</color>", v))
			end
		end
		--设置初始伙伴列表
		for i,v in ipairs(g_EqualArenaCtrl.m_PartnerList) do
			local oPartnerBox = self.m_PartnerGrid:GetChild(self:GetNetToPartnerBoxIndex(i))
			oPartnerBox.m_PartnerSprite:SpriteAvatar(v.model_info.shape)
			oPartnerBox.m_AwakeSprite:SetActive(v.awake == 1)
		end
		self.m_FirstSetData = true
	else
		--清空已选状态
		for i=1,self.m_PartnerGrid:GetCount() do
			local oPartnerBox = self.m_PartnerGrid:GetChild(i)
			-- oPartnerBox.m_SelectSprite:SetSpriteName("")
			oPartnerBox.m_SelectSprite:SetActive(false)
		end
		for i=1,self.m_PartnerEquipGrid:GetCount() do
			local oPartnerEquipBox = self.m_PartnerEquipGrid:GetChild(i)
			oPartnerEquipBox.m_SelectSprite:SetSpriteName("")
		end
	end
	--初始伙伴、人物、名字
	for k,v in pairs(g_EqualArenaCtrl.m_PlayerInfos) do
		if v.info.pid == g_AttrCtrl.pid then
			self.m_LeftBox:SetData(v)
		else
			self.m_RightBox:SetData(v)
		end
	end

	local curOperaterInfo = g_EqualArenaCtrl.m_PlayerInfos[g_EqualArenaCtrl.m_CurrentOperater]
	if g_EqualArenaCtrl.m_CurrentOperater == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("轮到您了")
		-- self.m_SubmitBtn:SetText("确定选择")
	else
		-- self.m_SubmitBtn:SetText("请等候")
	end
	self.m_TipsLabel:SetText(string.format("[FFEDA3]请[00cc00][%s][-]选择%s名伙伴和%s套御灵", curOperaterInfo.info.name, g_EqualArenaCtrl.m_CurrentNeedPartner, g_EqualArenaCtrl.m_CurrentNeedEquip))
	self:BeginCountDown(g_EqualArenaCtrl:GetRestSelectTime())
end

function CEqualArenaSelectPage.GetNetToPartnerBoxIndex(self, baseIndex)
	return self.m_NetToPartnerBox[baseIndex]
end

function CEqualArenaSelectPage.GetPartnerBoxToNetIndex(self, baseIndex)
	return self.m_PartnerBoxToNet[baseIndex]
end

function CEqualArenaSelectPage.GetNetToEquipBoxIndex(self, baseIndex)
	return self.m_NetToEquipBox[baseIndex]
end

function CEqualArenaSelectPage.GetEquipBoxToNetIndex(self, baseIndex)
	return self.m_EquipBoxToNet[baseIndex]
end

function CEqualArenaSelectPage.CreateInfoBox(self, oBox)
	oBox.m_Texture = oBox:NewUI(1, CTexture)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_PartnerGrid = oBox:NewUI(3, CGrid)
	oBox.m_PartnerEquipGrid = oBox:NewUI(4, CGrid)
	oBox.m_PlayerSprite = oBox:NewUI(5, CSprite)

	oBox.m_EquipBoxArr = {}
	oBox.m_ParentView = self

	oBox.m_PartnerGrid:InitChild(function (obj, idx)
		local oPartnerBox = CBox.New(obj)
		oPartnerBox.m_Index = idx
		oPartnerBox.m_BgSprite = oPartnerBox:NewUI(1, CSprite)
		oPartnerBox.m_PartnerSprite = oPartnerBox:NewUI(2, CSprite)
		oPartnerBox.m_AwakeSprite = oPartnerBox:NewUI(3, CSprite)
		oPartnerBox.m_UnShowSprite = oPartnerBox:NewUI(4, CSprite)
		return oPartnerBox
	end)
	oBox.m_PartnerEquipGrid:InitChild(function (obj, idx)
		local oPartnerEquipBox = CBox.New(obj)
		oBox.m_EquipBoxArr[idx] = oPartnerEquipBox
		oPartnerEquipBox.m_Sprite = oPartnerEquipBox:NewUI(1, CSprite)
		oPartnerEquipBox.m_Index = idx
		oPartnerEquipBox.m_Sprite:SetSpriteName("")
		-- oPartnerEquipBox.m_Sprite:SetActive(false)
		return oPartnerEquipBox
	end)

	function oBox.SetName(self, sName)
		oBox.m_NameLabel:SetText(sName)
	end

	function oBox.ChangeTexture(self, iShape)
		oBox.m_Texture:LoadDialogPhoto(iShape, function ()
			oBox.m_Texture:MakePixelPerfect()
		end)
	end

	function oBox.ChangePartner(self, idx, iShape, bAwake, iRare)
		local oPartnerBox = oBox.m_PartnerGrid:GetChild(idx)
		if iShape then
			oPartnerBox.m_PartnerSprite:SetActive(true)
			oPartnerBox.m_PartnerSprite:SpriteAvatar(iShape)
			oPartnerBox.m_AwakeSprite:SetActive(bAwake)
			oPartnerBox.m_UnShowSprite:SetActive(false)
			oPartnerBox.m_BgSprite:SetActive(true)
			if iRare then
				oPartnerBox.m_BgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(iRare))
			end
		else
			oPartnerBox.m_BgSprite:SetActive(false)
			oPartnerBox.m_PartnerSprite:SetActive(false)
			oPartnerBox.m_AwakeSprite:SetActive(false)
			oPartnerBox.m_UnShowSprite:SetActive(true)
		end
	end

	function oBox.ChangePartnerEquip(self, idx, sid)
		local oPartnerEquipBox = oBox.m_EquipBoxArr[idx]
		if not oPartnerEquipBox then
			-- printc("idx: " .. idx)
			return
		end
		if sid and data.partnerequipdata.ParSoulType[sid] then
			-- oPartnerEquipBox.m_Sprite:SetActive(true)
			oPartnerEquipBox.m_Sprite:SpriteItemShape(data.partnerequipdata.ParSoulType[sid].icon)
		else
			oPartnerEquipBox.m_Sprite:SetSpriteName("")
			-- oPartnerEquipBox.m_Sprite:SetActive(false)
		end
	end

	function oBox.SetData(self, oPlayerInfo)
		oBox.m_Info = oPlayerInfo
		oBox:SetName(oPlayerInfo.info.name)
		
		for i = 1, oBox.m_PartnerGrid:GetCount() do
			oBox:ChangePartner(i)
		end
		--前三个头像
		oBox.m_PlayerSprite:SpriteAvatar(oPlayerInfo.info.shape)
		for i, parShape in ipairs(oPlayerInfo.par_list) do
			oBox:ChangePartner(i, parShape, oPlayerInfo.awake_list[i] == define.EqualArena.Awake.Yes)
		end
		--正在选择的部分
		if oPlayerInfo.select_par and #oPlayerInfo.select_par > 0 then
			--设置伙伴选中状态
			for _,parid in ipairs(oPlayerInfo.select_par) do
				self.m_ParentView:SetPartnerSelectMark(parid, oPlayerInfo.info.pid, define.EqualArena.MarkType.Selecting)
			end
		end
		if oPlayerInfo.select_item and #oPlayerInfo.select_item > 0 then
			--设置符文选中状态
			for _,equipid in ipairs(oPlayerInfo.select_par) do
				self.m_ParentView:SetPartnerEquipSelectMark(equipid, oPlayerInfo.info.pid, define.EqualArena.MarkType.Selecting)
			end
		end
		--已选部分
		for i,v in ipairs(oPlayerInfo.selected_partner) do
			self.m_ParentView:SetPartnerSelectMark(v, oPlayerInfo.info.pid, define.EqualArena.MarkType.Selected)
			local partner = g_EqualArenaCtrl.m_PartnerList[v]
			oBox:ChangePartner(i + 2, partner.model_info.shape)
		end
		for i,v in ipairs(oPlayerInfo.selected_fuwen) do
			self.m_ParentView:SetPartnerEquipSelectMark(v, oPlayerInfo.info.pid, define.EqualArena.MarkType.Selected)
			local equip = g_EqualArenaCtrl.m_PartnerEquipList[v]
			oBox:ChangePartnerEquip(i, equip)
		end
	end
end

function CEqualArenaSelectPage.SetPartnerSelectMark(self, index, pid, status)
	local idx = self:GetNetToPartnerBoxIndex(index)
	local oPartnerBox = self.m_PartnerGrid:GetChild(idx)
	oPartnerBox.m_Status = status
	local oBox = nil
	if pid == g_AttrCtrl.pid then
		oBox = self.m_LeftBox
	else
		oBox = self.m_RightBox
	end

	if status == define.EqualArena.MarkType.None then
		oPartnerBox.m_BgSprite:SetGrey(false)
		oPartnerBox.m_PartnerSprite:SetGrey(false)
		oPartnerBox.m_AwakeSprite:SetGrey(false)
		oPartnerBox.m_SelectSprite:SetActive(false)
		-- oPartnerBox.m_SelectSprite:SetSpriteName("")
	elseif status == define.EqualArena.MarkType.Selecting then
		oPartnerBox.m_SelectSprite:SetActive(true)
		-- oPartnerBox.m_SelectSprite:SetSpriteName("bg_fuwenxuanzhongkuang")
		if g_EqualArenaCtrl.m_PartnerList[index] then
			oBox:ChangeTexture(g_EqualArenaCtrl.m_PartnerList[index].model_info.shape)
		else
			--tzq 随机动画
		end
	elseif status == define.EqualArena.MarkType.Selected then
		oPartnerBox.m_BgSprite:SetGrey(true)
		oPartnerBox.m_PartnerSprite:SetGrey(true)
		oPartnerBox.m_AwakeSprite:SetGrey(true)
		oPartnerBox.m_SelectSprite:SetActive(false)
		-- if pid == g_AttrCtrl.pid then
		-- 	oPartnerBox.m_SelectSprite:SetSpriteName("bg_fuwenyijingbeixuanzhong")
		-- else
		-- 	oPartnerBox.m_SelectSprite:SetSpriteName("bg_fuwenyijingbeixuanzhong")
		-- end
	end
end

function CEqualArenaSelectPage.SetPartnerEquipSelectMark(self, index, pid, status)
	local idx = self:GetNetToEquipBoxIndex(index)
	local oPartnerEquipBox = self.m_PartnerEquipGrid:GetChild(idx)
	oPartnerEquipBox.m_Status = status
	if status == define.EqualArena.MarkType.None then
		oPartnerEquipBox.m_SelectSprite:SetSpriteName("")
	elseif status == define.EqualArena.MarkType.Selecting then
		oPartnerEquipBox.m_SelectSprite:SetSpriteName("bg_fuwenxuanzhongkuang")
	elseif status == define.EqualArena.MarkType.Selected then
		if pid == g_AttrCtrl.pid then
			oPartnerEquipBox.m_SelectSprite:SetSpriteName("bg_fuwenyijingbeixuanzhong")
		else
			oPartnerEquipBox.m_SelectSprite:SetSpriteName("bg_fuwenyijingbeixuanzhong")
		end
	end
end

function CEqualArenaSelectPage.SelectPartner(self, oPartnerBox)
	-- printc("SelectPartner: " .. oPartnerBox.m_Index)
	local idx = self:GetPartnerBoxToNetIndex(oPartnerBox.m_Index)
	g_EqualArenaCtrl:SetSelecting(idx, define.EqualArena.SelectingType.Partner)
end

function CEqualArenaSelectPage.SelectPartnerEquip(self, oPartnerEquipBox)
	-- printc("SelectPartnerEquip: " .. oPartnerEquipBox.m_Index)
	local oView = CNotifyView:GetView()
	if oView and oPartnerEquipBox.m_Data then
		oView:ShowHint(oPartnerEquipBox.m_Data.simple_desc, oPartnerEquipBox, enum.UIAnchor.Side.Top)
	end
	local idx = self:GetEquipBoxToNetIndex(oPartnerEquipBox.m_Index)
	g_EqualArenaCtrl:SetSelecting(idx, define.EqualArena.SelectingType.Equip)
end

function CEqualArenaSelectPage.OnEqualEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EqualArena.Event.OnSelectSection then
		self:SetData()
		self:OnTimeUP()
	elseif oCtrl.m_EventID == define.EqualArena.Event.OnSetSelecting then
		-- printc("OnSetSelecting")
		local oData = oCtrl.m_EventData
		-- table.print(oData, "OnSetSelecting oData------------->")
		if oData.selectType == define.EqualArena.SelectingType.Partner then
			self:SetPartnerSelectMark(oData.idx, oData.pid, oData.handleType)
			local oBox = nil
			local pid = oData.pid
			if pid == g_AttrCtrl.pid then
				oBox = self.m_LeftBox
			else
				oBox = self.m_RightBox
			end
			local startIndex = #oBox.m_Info.selected_partner + 2
			for i = 1, g_EqualArenaCtrl.m_CurrentNeedPartner do
				if g_EqualArenaCtrl.m_SelectingPartnerRecord[pid][i] then
					local partner = g_EqualArenaCtrl.m_PartnerList[g_EqualArenaCtrl.m_SelectingPartnerRecord[pid][i]]
					if partner then
						oBox:ChangePartner(startIndex + i, partner.model_info.shape, true)
					else
						oBox:ChangePartner(startIndex + i, nil)
					end
				else
					oBox:ChangePartner(startIndex + i, nil)
				end
			end
		elseif oData.selectType == define.EqualArena.SelectingType.Equip then
			self:SetPartnerEquipSelectMark(oData.idx, oData.pid, oData.handleType)
			local oBox = nil
			local pid = oData.pid
			if pid == g_AttrCtrl.pid then
				oBox = self.m_LeftBox
			else
				oBox = self.m_RightBox
			end
			local startIndex = #oBox.m_Info.selected_fuwen
			for i = 1, g_EqualArenaCtrl.m_CurrentNeedEquip do
				if g_EqualArenaCtrl.m_SelectingEquipRecord[pid][i] then
					local equip = g_EqualArenaCtrl.m_PartnerEquipList[g_EqualArenaCtrl.m_SelectingEquipRecord[pid][i]]
					if equip then
						oBox:ChangePartnerEquip(startIndex + i, equip)
					else
						oBox:ChangePartnerEquip(startIndex + i, nil)
					end
				else
					oBox:ChangePartnerEquip(startIndex + i, nil)
				end
			end
		end
	end
end

function CEqualArenaSelectPage.BeginCountDown(self, countDown)
	-- self.m_CountDownBox:SetTimeUPCallBack(callback(self, "OnTimeUP"))
	self.m_CountDownBox:BeginCountDown(countDown)
end

function CEqualArenaSelectPage.OnTimeUP(self)
	local oView = CItemTipsConfirmWindowView:GetView()
	if oView then
		oView:OnClose()
	end
end

function CEqualArenaSelectPage.OnSubmit(self)
	g_EqualArenaCtrl:SubmitSelecting()
end

return CEqualArenaSelectPage