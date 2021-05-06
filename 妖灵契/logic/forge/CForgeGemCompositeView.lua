---------------------------------------------------------------
--打造界面主界面


---------------------------------------------------------------

local CForgeGemCompositeView = class("CForgeGemCompositeView", CViewBase)

CForgeGemCompositeView.PosItem = {
	[0] = {itemId = 16021, buyId = 16021},
	[1] = {itemId = 16160, buyId = 18002},
	[2] = {itemId = 16161, buyId = 18102},
	[3] = {itemId = 16162, buyId = 18202},
	[4] = {itemId = 16163, buyId = 18302},
	[5] = {itemId = 16164, buyId = 18402},
	[6] = {itemId = 16165, buyId = 18502},
}
function CForgeGemCompositeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeGemCompositeView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_CompositeMode = nil
	self.m_IsAni = false
end

function CForgeGemCompositeView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_CompositeAllBtn = self:NewUI(3, CButton)
	self.m_CompositeOneBtn = self:NewUI(4, CButton)
	self.m_CompositeBoxList = {}
	for i = 1, 3 do
		local oBox = self:NewUI(4 + i, CBox)
		oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
		oBox.m_Label = oBox:NewUI(2, CLabel)
		oBox.m_AddBtn = oBox:NewUI(3, CButton)
		self.m_CompositeBoxList[i] = oBox
	end
	self.m_ShowGemBox = self:NewUI(8, CBox)
	self.m_ShowGemBox.m_ItemSpr = self.m_ShowGemBox:NewUI(1, CSprite)
	self.m_ShowGemBox.m_Label = self.m_ShowGemBox:NewUI(2, CLabel)
	self.m_ShowGemBox.m_ItemSpr:SetAlpha(0)
	
	self.m_BagGemCloneBox = self:NewUI(10, CBox)
	self.m_BagGemGrid = self:NewUI(11, CGrid)
	-- self.m_FindWayBox = self:NewUI(12, CBox)
	self.m_BagGemScollView = self:NewUI(13, CScrollView)
	self.m_CompositeAniBoxList = {}
	for i = 1, 3 do
		local oBox = self:NewUI(13 + i, CBox)
		oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
		oBox.m_Label = oBox:NewUI(2, CLabel)
		self.m_CompositeAniBoxList[i] = oBox
	end	

	self.m_GemType = 0
	self.m_BagGemList = {}
	self.m_BagGemBoxList = {}
	self.m_MoveAction = {}
	self.m_SelelctGemSidCount = 0
	self.m_SelelctGemSid = 0
	self.m_SelelctGemSidAni = 0
	self.m_LastClickIdx = 0

	self:InitContent()
end

function CForgeGemCompositeView.InitContent(self)
	self.m_BagGemCloneBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CloseView"))
	self.m_CompositeOneBtn:AddUIEvent("click", callback(self, "OnCompositeOne"))
	self.m_CompositeAllBtn:AddUIEvent("click", callback(self, "OnCompositeAll"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self:InitFindWayBox()
end

function CForgeGemCompositeView.InitPopupBox(self)
	self.m_GemString = 
	{
		[1] = {str = "全部宝石"},
		[2] = {str = "绯红宝石"},
		[3] = {str = "八云宝石"},
		[4] = {str = "双生宝石"},
		[5] = {str = "黄金宝石"},
		[6] = {str = "翠星宝石"},
		[7] = {str = "疾风宝石"},
	}
	self.m_GemTypePopupBox:ShowAniConfig()
	for i = 1, #self.m_GemString do
		self.m_GemTypePopupBox:AddSubMenu(string.format("%s", self.m_GemString[i].str), nil, nil, true)
	end
	self.m_GemTypePopupBox:SetPopupShowAni(true)
	self.m_GemTypePopupBox:SetCallback(callback(self, "OnSelectGemType"))
	self.m_GemTypePopupBox:AddMainBtnCallBack(callback(self, "ClickPopupBoxMain"))
end

function CForgeGemCompositeView.ClickPopupBoxMain(self)
	self:ShowSuccessAniEnd(false)
end

function CForgeGemCompositeView.OnSelectGemType(self, oBox)
	self:ShowSuccessAniEnd(false)
	local subMenu = oBox:GetSelectedSubMenu()
	local idx = self.m_GemTypePopupBox:GetSelectedIndex()
	oBox:SetMainMenu(subMenu.m_Label:GetText())
	self.m_GemType = idx - 1
	self.m_SelelctGemSid = 0
	self.m_LastClickIdx = 0
	self:RefreshBagGem(true)
	self:RefreshCompositeGem()
	self:SetContent(self.m_GemType)
end

function CForgeGemCompositeView.SetContent(self, iType, iLevel)
	self.m_GemType = iType
	if not self.m_GemTypePopupBox then
		self.m_GemTypePopupBox = self:NewUI(9, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, iType + 1, true)	
		self:InitPopupBox()
	end
	self:RefreshBagGem(true)
	if iLevel then
		if #self.m_BagGemList > 0 then
			local targetIdx = 0
			for i, v in ipairs(self.m_BagGemList) do
				if v:GetValue("level") == iLevel then
					targetIdx  = i
					break
				end
			end
			if targetIdx ~= 0 then
				self:ClickBagGemItem(targetIdx, self.m_BagGemList[targetIdx]:GetValue("sid"), nil)
			end
		end 
	else
		if #self.m_BagGemList > 0 then
			local targetIdx = 1
			for i, v in ipairs(self.m_BagGemList) do
				if v:GetValue("amount") >= 3 then
					targetIdx  = i
					break
				end
			end
			self:ClickBagGemItem(targetIdx, self.m_BagGemList[targetIdx]:GetValue("sid"), nil)
		end 
	end	

	local oView = CForgeMainView:GetView()
	if oView then
		oView:SetActive(false)
	end
end

function CForgeGemCompositeView.Destroy(self)
	self:StopMoveAction()
	local oView = CForgeMainView:GetView()
	if oView then
		oView:SetActive(true)
	end
	CViewBase.Destroy(self)
end

function CForgeGemCompositeView.RefreshBagGem(self, isReposition)
	self.m_BagGemList = g_ItemCtrl:GetGemListCompositeByType(self.m_GemType)
	local isSelect = false
	for i = 1, #self.m_BagGemList + 1 do
		local oBox = self.m_BagGemBoxList[i]
		if not oBox then
			oBox = self.m_BagGemCloneBox:Clone()
			oBox.m_ItemSpr = oBox:NewUI(1, CSprite)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			oBox.m_CountLabel = oBox:NewUI(3, CLabel)
			oBox.m_QualitySpr = oBox:NewUI(4, CSprite)
			oBox.m_DefaultAddBtn = oBox:NewUI(5, CButton)
			self.m_BagGemGrid:AddChild(oBox)
			self.m_BagGemBoxList[i] = oBox
		end
		oBox:SetActive(true)
		oBox.m_SelectSpr:SetActive(false)
		local oItem = self.m_BagGemList[i] 
		if oItem then
			oBox.m_ItemSpr:SetActive(true)
			oBox.m_CountLabel:SetActive(true)
			oBox.m_DefaultAddBtn:SetActive(false)
			oBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
			oBox.m_CountLabel:SetText(string.format("%d", oItem:GetValue("amount")))
			oBox.m_ItemSpr:AddUIEvent("click", callback(self, "ClickBagGemItem", i, oItem:GetValue("sid"), nil))
			oBox.m_ItemSpr:AddUIEvent("longpress", callback(self, "LongPressBagGemItem", oItem:GetValue("sid"), oBox))
			if self.m_SelelctGemSid == oItem:GetValue("sid") and not isSelect then
				oBox.m_SelectSpr:SetActive(true)
				isSelect = true
				self.m_LastClickIdx = i
			end
		else
			oBox.m_ItemSpr:SetActive(false)
			oBox.m_CountLabel:SetActive(false)
			oBox.m_DefaultAddBtn:SetActive(true)
			oBox.m_DefaultAddBtn:AddUIEvent("click", callback(self, "SetFindBoxActive", true))
		end
	end
	if #self.m_BagGemBoxList > #self.m_BagGemList + 1 then
		for i = #self.m_BagGemList + 2, #self.m_BagGemBoxList do
			local oBox = self.m_BagGemBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
	if isReposition then
		local cb = function ()
			self.m_BagGemScollView:ResetPosition()
		end
		Utils.AddTimer(cb, 0, 0)
	end
end

function CForgeGemCompositeView.RefreshCompositeGem(self)
	local oItem = nil
	if self.m_SelelctGemSid ~= 0 then
		oItem = CItem.NewBySid(self.m_SelelctGemSid)
	end	
	for i = 1, 3 do
		if self.m_SelelctGemSidCount >= i and oItem then
			self.m_CompositeBoxList[i].m_ItemSpr:SetActive(true)
			self.m_CompositeBoxList[i].m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
			self.m_CompositeBoxList[i].m_Label:SetText(oItem:GetValue("name"))
			self.m_CompositeBoxList[i].m_AddBtn:SetActive(false)
		else
			self.m_CompositeBoxList[i].m_ItemSpr:SetActive(false)
			self.m_CompositeBoxList[i].m_Label:SetText("添加宝石")
			self.m_CompositeBoxList[i].m_AddBtn:SetActive(true)
			self.m_CompositeBoxList[i].m_AddBtn:AddUIEvent("click", callback(self, "SetFindBoxActive", true))
		end
	end
end

function CForgeGemCompositeView.OnCompositeOne(self)
	if self.m_IsAni then
		return
	end
	self:ShowSuccessAniEnd(false)
	if self.m_SelelctGemSid ~= 0 then
		local oItem = CItem.NewBySid(self.m_SelelctGemSid)
		if oItem and oItem:GetValue("level") == 10 then
			g_NotifyCtrl:FloatMsg("宝石已达到最大等级")
			return
		end
	else
		g_NotifyCtrl:FloatMsg("请选择宝石")
	end
	if self.m_SelelctGemSidCount == 0 then
		g_NotifyCtrl:FloatMsg("请选择宝石")
	elseif self.m_SelelctGemSidCount < 3 then
		g_NotifyCtrl:FloatMsg("所需的宝石数量不足，无法合成")
	else
		self.m_CompositeMode = 1
		g_ItemCtrl:CtrlC2GSComposeGem(self.m_SelelctGemSid, 1)
	end
end

function CForgeGemCompositeView.OnCompositeAll(self)	
	if self.m_IsAni then
		return
	end
	self:ShowSuccessAniEnd(false)
	if self.m_SelelctGemSid ~= 0 then
		local oItem = CItem.NewBySid(self.m_SelelctGemSid)
		if oItem and oItem:GetValue("level") == 10 then
			g_NotifyCtrl:FloatMsg("宝石已达到最大等级")
			return
		end
	else
		g_NotifyCtrl:FloatMsg("请选择宝石")
	end
	if self.m_SelelctGemSidCount == 0 then
		g_NotifyCtrl:FloatMsg("请选择宝石")
	elseif self.m_SelelctGemSidCount < 3 then
		g_NotifyCtrl:FloatMsg("所需的宝石数量不足，无法合成")
	else
		self.m_CompositeMode = 0
		g_ItemCtrl:CtrlC2GSComposeGem(self.m_SelelctGemSid, 0)
	end
end

function CForgeGemCompositeView.ClickBagGemItem(self, idx, sid, bForce)
	self:ShowSuccessAniEnd(false)
	local oBox = self.m_BagGemBoxList[self.m_LastClickIdx]
	if oBox then
		oBox.m_SelectSpr:SetActive(false)
	end
	self.m_LastClickIdx = idx
	if self.m_SelelctGemSid ~= sid or bForce then
		self.m_SelelctGemSid = 0
		self.m_SelelctGemSidCount = 0
		for i = 1, #self.m_BagGemList do
			local oItem	 = self.m_BagGemList[i]
			if oItem and oItem:GetValue("sid") == sid then
				self.m_SelelctGemSidCount = oItem:GetValue("amount") 				
				self.m_SelelctGemSid = sid
				self.m_SelelctGemSidAni = sid
				oBox = self.m_BagGemBoxList[idx]
				if oBox then
					oBox.m_SelectSpr:SetActive(true)
				end				
			end
		end
		--如果合成刷新的时候，如果当前选中的宝石没有了，则重新刷新默认选中的宝石
		if bForce == true and #self.m_BagGemList > 0 and self.m_SelelctGemSid == 0 then
			local targetIdx = 1
			local oItem = self.m_BagGemList[1]
			for i, v in ipairs(self.m_BagGemList) do
				if v:GetValue("amount") >= 3 then
					targetIdx  = i
					oItem = v
					break
				end
			end
			if oItem then
				self.m_LastClickIdx = targetIdx
				sid = oItem:GetValue("sid")
				self.m_SelelctGemSidCount = oItem:GetValue("amount") 				
				self.m_SelelctGemSid = sid
				self.m_SelelctGemSidAni = sid
				local oBox = self.m_BagGemBoxList[targetIdx]
				if oBox then
					oBox.m_SelectSpr:SetActive(true)
				end		
			end
		end 

		self:RefreshCompositeGem()

	else
		oBox = self.m_BagGemBoxList[self.m_LastClickIdx]
		if oBox then
			oBox.m_SelectSpr:SetActive(true)
		end	
	end
end

function CForgeGemCompositeView.LongPressBagGemItem(self, sid, oBox, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end 
	self:ShowSuccessAniEnd(false)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid,
		{widget =  oBox, openView = self.m_ParentView})
end

function CForgeGemCompositeView.InitFindWayBox(self)
	-- local oBox = self.m_FindWayBox
	-- oBox.m_BackFindBtn = oBox:NewUI(1, CBox)
	-- oBox.m_FindGrid = oBox:NewUI(2, CGrid)
	-- oBox.m_FindCloneBox = oBox:NewUI(3, CBox)
	-- oBox.m_FindBgSpr = oBox:NewUI(4, CSprite)
	-- oBox.m_FindCloneBox:SetActive(false)
	-- local oItem = CItem.NewBySid(16021)
	-- if not oItem then
	-- 	return
	-- end
	-- local gainWay = oItem:GetValue("gain_way_id") or {}
	-- local idx = 0
	-- if gainWay and next(gainWay) then
	-- 	for i = 1, #gainWay do
	-- 		local d = data.itemdata.MODULE_SRC[gainWay[i]]
	-- 		if d then
	-- 			idx = idx + 1
	-- 			local tBox = oBox.m_FindCloneBox:Clone()
	-- 			tBox.m_NameLabel = tBox:NewUI(1, CLabel)
	-- 			tBox.m_NameLabel:SetText(d.name)
	-- 			tBox:SetActive(true)
	-- 			local function cb()										
	-- 				if not g_ActivityCtrl:ActivityBlockContrl("item_resource") and not g_ActivityCtrl:ActivityBlockContrl("partner_resource") then
	-- 			   		return
	-- 			   	end						
	-- 				if d.blockkey ~= "" then
	-- 					if not g_ActivityCtrl:ActivityBlockContrl(d.blockkey) then
	-- 				   		return
	-- 				   	end
	-- 				end
	-- 				if g_ItemCtrl:ItemFindWayToSwitch(d.id) == true then
	-- 					self:CloseView()
	-- 				end							
	-- 			end
	-- 			tBox:AddUIEvent("click", cb)
	-- 			oBox.m_FindGrid:AddChild(tBox)
	-- 		end						
	-- 	end
	-- 	oBox.m_FindGrid:Reposition()
	-- 	local w, h = oBox.m_FindGrid:GetCellSize()
	-- 	oBox.m_FindBgSpr:SetHeight(91 + idx * h)
	-- end
	-- oBox.m_BackFindBtn:AddUIEvent("click", callback(self, "SetFindBoxActive", false))
	-- oBox:SetActive(false)
end

function CForgeGemCompositeView.SetFindBoxActive(self, b)
	self:ShowSuccessAniEnd(false)
	if b then
		CItemTipsSimpleInfoView:ShowView(function (oView)
			oView:SetInitBox(CForgeGemCompositeView.PosItem[self.m_GemType].buyId, nil, {showQuickBuy = true})
			oView:ForceShowFindWayBox(true)
			local oData = DataTools.GetItemData(CForgeGemCompositeView.PosItem[self.m_GemType].itemId)
			oView.m_NameLabel:SetText(oData.name)
			oView.m_DesLabel:SetText(oData.introduction)
		end)
	else
		local oView = CItemTipsSimpleInfoView:GetView()
		if oView then
			oView:CloseView()
		end
	end
	-- self.m_FindWayBox:SetActive(b)
end

function CForgeGemCompositeView.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.ForgeGemComposite then	
		local sid = oCtrl.m_EventData.sid
		self:RefreshBagGem()
		self:RefreshCompositeGem()
		self:ShowCompositeAni(true, sid, oCtrl.m_EventData.amount)
	elseif oCtrl.m_EventID == define.Item.Event.RefreshBagItem 
		or oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshBagGem()
		self:ClickBagGemItem(self.m_LastClickIdx, self.m_SelelctGemSid, true)
	end
end

function CForgeGemCompositeView.ShowCompositeAni(self, b, sid, amount)
	self.m_IsAni = b
	self:StopMoveAction()
	self.m_MoveAction = {}
	if not b then
		for i, v in ipairs(self.m_CompositeAniBoxList) do
			v:SetActive(false)
			v.m_ItemSpr:SetActive(false)
		end
	else	
		local oItem = CItem.NewBySid(self.m_SelelctGemSidAni)
		for i, v in ipairs(self.m_CompositeAniBoxList) do
			v:SetActive(true)
			v.m_ItemSpr:SetActive(true)
			v.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
			local oBox = self.m_CompositeBoxList[i]
			local pos = oBox:GetLocalPos()
			v:SetLocalPos(pos)
			self.m_MoveAction[i] = CActionVector.New(v, 0.5, "SetLocalPos", Vector3.New(pos.x, pos.y, 0), Vector3.New(149, -91.5, 0))					
			if i == 1 then
				self.m_MoveAction[i]:SetEndCallback(callback(self, "ShowSuccessAniEnd", true, sid, amount))
			end
			g_ActionCtrl:AddAction(self.m_MoveAction[i])
		end
	end
end

function CForgeGemCompositeView.ShowSuccessAniEnd(self, b, sid, amount)
	if b then
		self.m_IsAni = false
		local oItem = CItem.NewBySid(sid)
		self.m_ShowGemBox.m_ItemSpr:SetAlpha(1)
		self.m_ShowGemBox.m_ItemSpr:SpriteItemShape(oItem:GetValue("icon"))
		for i, v in ipairs(self.m_CompositeAniBoxList) do
			v:SetActive(false)
			v.m_ItemSpr:SetActive(false)
		end		
	else
		self.m_ShowGemBox.m_ItemSpr:SetAlpha(0)
	end
end

function CForgeGemCompositeView.StopMoveAction(self)
	if next(self.m_MoveAction) then
		for i, v in ipairs(self.m_MoveAction) do
			if v then
				g_ActionCtrl:DelAction(v)
			end
		end
	end
end

return CForgeGemCompositeView