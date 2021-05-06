local CEquipFubenMainView = class("CEquipFubenMainView", CViewBase)

function CEquipFubenMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/equipfuben/EquipFubenMainView.prefab", cb)
	self.m_ExtendClose = "Shelter"
	self.m_GroupName = "main"
	self.m_DepthType = "Menu"  --层次
	self.m_SeleltFbIdx = 1

end

function CEquipFubenMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_FubenGrid = self:NewUI(2, CGrid)
	self.m_TipsBtn = self:NewUI(3, CButton)
	self.m_Container = self:NewUI(4, CBox)
	self.m_TitleLabel = self:NewUI(5, CLabel)
	self.m_TimeLabel = self:NewUI(6, CLabel)
	self.m_EquipTipsLabel = self:NewUI(7, CLabel)
	self.m_CountLabel = self:NewUI(8, CLabel)
	self.m_AddCountButton = self:NewUI(9, CButton)
	self.m_EnterBtn = self:NewUI(10, CButton)
	self.m_InfoPart = self:NewUI(11, CChapterWealthInfoPart)
	self.m_ShowItemGrid = self:NewUI(12, CGrid)
	self.m_ShowItemCloneBox = self:NewUI(13, CItemTipsBox)
	self.m_LeftTimeLabel = self:NewUI(14, CLabel)
	self.m_IsOpenAni = true
	self:InitContent()
end

function CEquipFubenMainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ShowItemCloneBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddCountButton:AddUIEvent("click", callback(self, "OnAddFbCount"))
	self.m_EnterBtn:AddUIEvent("click", callback(self, "OnEnterFuben"))
	self.m_TipsBtn:AddHelpTipClick("equipfuben_main")

	g_GuideCtrl:AddGuideUI("equipfuben_main_enter_btn", self.m_EnterBtn)

	self.m_FubenGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox.m_MaskSprite = oBox:NewUI(1, CSprite)
		oBox.m_EnterBtn = oBox:NewUI(2, CButton)
		oBox.m_EquipSprite = oBox:NewUI(3, CButton)
		oBox.m_TimeTipsLabel = oBox:NewUI(4, CLabel)
		oBox.m_EquipTipsLabel = oBox:NewUI(5, CLabel)
		oBox.m_NameLabel = oBox:NewUI(6, CLabel)
		oBox.m_ProgressLabel = oBox:NewUI(7, CLabel)
		oBox.m_CountLabel = oBox:NewUI(8, CLabel)
		oBox.m_UnEnterBtn = oBox:NewUI(9, CButton)
		oBox.m_AddBtn = oBox:NewUI(10, CButton)
		oBox.m_TipsLabel = oBox:NewUI(11, CLabel)
		oBox.m_TipsSpr = oBox:NewUI(12, CSprite)
		oBox.m_Textrue = oBox:NewUI(13, CTexture)
		oBox.m_RedDotSpr = oBox:NewUI(14, CSprite)
		oBox:AddUIEvent("click", callback(self, "OnSelectedFb", index))
		oBox:SetGroup(self.m_FubenGrid:GetInstanceID())
		oBox:SetSelected(self.m_SeleltFbIdx == index)
		oBox.m_IgnoreCheckEffect = true
		return oBox
	end)
	local cb = function ()
		if Utils.IsNil(self) then
			return
		end
		self.m_IsOpenAni = false
	end
	Utils.AddTimer(cb, 0, 0.7)
	self:RefreshAll()
	self:ReOpenDetailView()
end

function CEquipFubenMainView.OnEnterFubenDetail(self, fubenId, leftTime)
	if leftTime and leftTime == 0 then
		g_NotifyCtrl:FloatMsg("本日次数已用完")
	else
		g_EquipFubenCtrl:CtrlC2GSOpenEquipFB(fubenId)
	end
end

function CEquipFubenMainView.RefreshList(self)
	local info = g_EquipFubenCtrl.m_FubenInfoList
	if info and next(info) then
		for i = 1, #info do
			local oBox = self.m_FubenGrid:GetChild(i)
			local d = info[i]					
			if oBox then
				if d then
					local baseInfo = data.equipfubendata.FUBEN[d.f_id]
					--local fubenDes = string.split(baseInfo.fuben_des, "|")
					-- oBox:SetActive(true)
					-- if fubenDes[1] then
					-- 	oBox.m_TimeTipsLabel:SetText(fubenDes[1])
					-- end
					-- if fubenDes[2] then
					-- 	oBox.m_EquipTipsLabel:SetText(fubenDes[2])
					-- end										
					-- oBox.m_NameLabel:SetText(baseInfo.type)
					if d.floor == 0 then
						oBox.m_ProgressLabel:SetText("未通关")
					else
						oBox.m_ProgressLabel:SetText(string.format("第%s层",g_EquipFubenCtrl:CountConvert(d.floor)))
					end	
					oBox.m_TipsLabel:SetText(baseInfo.main_des[1])
					oBox.m_RedDotSpr:SetActive(d.redpoint ~= 0)

					--oBox.m_CountLabel:SetText(string.format("[654a33]本日已进入[ea1e1e]%d/%d[654a33]次", d.max - d.left, d.max))
					-- oBox.m_EnterBtn:AddUIEvent("click", callback(self, "OnEnterFubenDetail", d.f_id, d.left))
					-- oBox.m_UnEnterBtn:AddUIEvent("click", callback(self, "OnEnterFubenDetail", d.f_id, d.left))
					-- oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnAddTime", d.f_id))

					-- if d.left == 0 then
					-- 	oBox.m_CountLabel:SetActive(false)
					-- 	oBox.m_MaskSprite:SetActive(true)
					-- 	oBox.m_EnterBtn:SetActive(false)
					-- 	oBox.m_UnEnterBtn:SetActive(true)
					-- else
					-- 	oBox.m_CountLabel:SetActive(true)
					-- 	oBox.m_MaskSprite:SetActive(false)
					-- 	oBox.m_EnterBtn:SetActive(true)
					-- 	oBox.m_UnEnterBtn:SetActive(false)
					-- end
					-- if g_EquipFubenCtrl:GetFubenCanBuyTime(d.f_id) > 0 then
					-- 	oBox.m_AddBtn:SetActive(true)
					-- else
					-- 	oBox.m_AddBtn:SetActive(false)
					-- end
				else
					oBox:SetActive(false)
				end
			end
		end	
	end
end

function CEquipFubenMainView.OnAddTime(self, fubenId)
	local time = g_EquipFubenCtrl:GetFubenCanBuyTime(fubenId)
	CEquipFubenAddTimeView:ShowView(function (oView)
		oView:SetData(fubenId, 1, 1, time)
	end)
end

function CEquipFubenMainView.OnAddFbCount(self)
	local info = g_EquipFubenCtrl.m_FubenInfoList
	local d = info[self.m_SeleltFbIdx]
	if d then
		local time = g_EquipFubenCtrl:GetFubenCanBuyTime(d.f_id)
		CEquipFubenAddTimeView:ShowView(function (oView)
			oView:SetData(d.f_id, 1, 1, time)
		end)			
	end
end

function CEquipFubenMainView.OnEnterFuben(self)
	local info = g_EquipFubenCtrl.m_FubenInfoList
	local d = info[self.m_SeleltFbIdx]
	if d then
		g_EquipFubenCtrl:CtrlC2GSOpenEquipFB(d.f_id)
	end
end

function CEquipFubenMainView.OnSelectedFb(self, idx, oBox)
	if self.m_SeleltFbIdx == idx then
		return
	end
	if oBox then
		oBox:SetSelected(true)
	end
	for i = 1, self.m_FubenGrid:GetCount() do		
		local oBox = self.m_FubenGrid:GetChild(i)
		if oBox and oBox.m_TipsSpr then
			if idx == i then
				oBox.m_TipsSpr:UITweenPlay()
			else
				oBox.m_TipsSpr:SetLocalScale(Vector3.New(0, 0, 1))
			end
		end
	end	
	self.m_SeleltFbIdx = idx
	self:RefreshBaseInfo()
end

function CEquipFubenMainView.RefreshBaseInfo(self)	
	self.m_LeftTimeLabel:SetText(string.format("本日剩余%d次", g_EquipFubenCtrl:GetFubenRemainTime()))

	local info = g_EquipFubenCtrl.m_FubenInfoList
	local d = info[self.m_SeleltFbIdx]
	if d then
		local baseInfo = data.equipfubendata.FUBEN[d.f_id]
		local fubenDes = string.split(baseInfo.fuben_des, "|")
		
		if fubenDes[1] then
			self.m_TimeLabel:SetText(fubenDes[1])
		end
		if fubenDes[2] then
			self.m_EquipTipsLabel:SetText(fubenDes[2])
		end										
		self.m_TitleLabel:SetText(baseInfo.type)
		self.m_CountLabel:SetText(string.format("%d", d.tili_cost))
		local showItemTable = baseInfo.showitem
		if showItemTable and next(showItemTable) then

			for i = 1, #showItemTable do
				local oBox = self.m_ShowItemGrid:GetChild(i)
				if not oBox then
					oBox = self.m_ShowItemCloneBox:Clone()
					self.m_ShowItemGrid:AddChild(oBox)
				end
				oBox:SetActive(true)
				local config = {isLocal = true,}
				oBox:SetItemData(showItemTable[i], 1, nil ,config)
			end
			if #showItemTable < self.m_ShowItemGrid:GetCount() then
				for i = #showItemTable + 1, self.m_ShowItemGrid:GetCount() do
					local oBox = self.m_ShowItemGrid:GetChild(i)
					if oBox then
						oBox:SetActive(false)
					end				
				end
			end
		end
	end
end

function CEquipFubenMainView.RefreshAll(self)
	self:RefreshList()
	self:RefreshBaseInfo()
end

function CEquipFubenMainView.ReOpenDetailView(self)
	if g_EquipFubenCtrl.m_ReOpenEquip == true then
		local path = string.format("equipfuben_cachefloor")
		local fbId = g_EquipFubenCtrl.m_ReOpenEquipFbId
		local tData = IOTools.GetRoleData(path)
		if not fbId and tData and type(tData) == "number" then
			fbId = tData
		end
		fbId = fbId or 1
		g_EquipFubenCtrl.m_ReOpenEquipFbId = nil
		self:OnSelectedFb(fbId)
		g_EquipFubenCtrl.m_ReOpenEquip = false
		g_EquipFubenCtrl:CtrlC2GSOpenEquipFB(fbId)
		local oBox = self.m_FubenGrid:GetChild(fbId)
		if oBox then
			oBox:SetSelected(true)
		end
	end	
end

return CEquipFubenMainView