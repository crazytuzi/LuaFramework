local CTravelItemView = class("CTravelItemView", CViewBase)

function CTravelItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelItemView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTravelItemView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_TravelHelpBtn = self:NewUI(4, CButton)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CBox)
	self.m_UseItemBox = self:NewUI(7, CBox)
	self.m_OperateBtn = self:NewUI(8, CButton)
	self.m_GetPathSpr = self:NewUI(9, CSprite)
	self:InitContent()
end

function CTravelItemView.InitContent(self)
	self.m_CurSelectBox = nil
	self.m_UseItemSid = nil
	self.m_ItemBox:SetActive(false)
	self.m_TravelHelpBtn:AddHelpTipClick("travel_item")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OperateBtn:AddUIEvent("click", callback(self, "OnOperateBtn"))
	self.m_GetPathSpr:AddUIEvent("click", callback(self, "OnGetPathSpr"))

	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))

	self:InitUseItemBox()

	self:RefreshItemGrid()
	self:RefreshUseItemBox()
	self:RefreshOperateBtn()
end

function CTravelItemView.OnTravelCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Travel.Event.MineItem then
		self.m_CurSelectBox = nil
		self:RefreshItemGrid()
		self:RefreshUseItemBox()
		self:RefreshOperateBtn()			
	end
end

function CTravelItemView.OnGetPathSpr(self, oLabel)
	--g_NotifyCtrl:FloatMsg("加成道具获取跳转")
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSOpenShop"]) then
		netstore.C2GSOpenShop(define.Store.Page.TravelShop)
		self:CloseView()
	end
end

function CTravelItemView.OnOperateBtn(self, oBtn)
	if self.m_UseItemSid then
		local args = 
			{
				msg = "卸下后，道具将会失效并消失，是否继续卸下？",
				okCallback = function ( )
						nettravel.C2GSCancelSpeedTravel()
					end,
				okStr = "确定",
				cancelStr = "取消",
			}
		g_WindowTipCtrl:SetWindowConfirm(args)
	elseif not self.m_UseItemSid and self.m_CurSelectBox then
		g_ItemCtrl:C2GSItemUse(self.m_CurSelectBox.m_ID, g_AttrCtrl.pid, 1)
	else
		g_NotifyCtrl:FloatMsg("请先选择加成道具")
	end
end

function CTravelItemView.RefreshItemGrid(self)
	local itemlist = g_ItemCtrl:GetTravelItems()
	self.m_GetPathSpr:SetActive(not itemlist or #itemlist==0)
	self.m_ItemGrid:Clear()
	for i,oItem in ipairs(itemlist) do
		local oItemBox = self.m_ItemBox:Clone()
		oItemBox.m_IconSprite = oItemBox:NewUI(1, CSprite)
		oItemBox.m_QulitySprite = oItemBox:NewUI(2, CSprite)
		oItemBox.m_EffectLabel = oItemBox:NewUI(3, CLabel)
		oItemBox.m_TimeLabel = oItemBox:NewUI(4, CLabel)
		oItemBox.m_NameLabel = oItemBox:NewUI(5, CLabel)
		oItemBox.m_SelectSprite = oItemBox:NewUI(6, CSprite)
		oItemBox.m_CountLabel = oItemBox:NewUI(7, CLabel)
		oItemBox.m_SelectSprite:SetActive(false)

		oItemBox.m_ID = oItem.m_ID
		oItemBox.m_Sid = oItem:GetValue("sid")
		oItemBox.m_Qulity = oItem:GetValue("quality")
		oItemBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		oItemBox.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
		oItemBox.m_NameLabel:SetText(oItem:GetValue("name"))
		oItemBox.m_EffectLabel:SetText(oItem:GetValue("description"))
		oItemBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(oItem:GetValue("add_time")))
		oItemBox.m_CountLabel:SetText(oItem:GetValue("amount"))
		oItemBox:AddUIEvent("click", callback(self, "OnItemBox"))
		oItemBox.m_IconSprite:AddUIEvent("click", callback(self, "OnClickIcon", oItemBox))
		oItemBox:SetActive(true)
		self.m_ItemGrid:AddChild(oItemBox)
	end
	self.m_ItemGrid:Reposition()
end

function CTravelItemView.OnItemBox(self, oItemBox)
	if self.m_CurSelectBox then
		self.m_CurSelectBox.m_SelectSprite:SetActive(false)
	end
	if not self.m_UseItemSid and self.m_CurSelectBox == oItemBox then
		self.m_CurSelectBox = nil
		self:ClearUseItemBox()
		self:RefreshOperateBtn()
		return
	end
	self.m_CurSelectBox = oItemBox
	self.m_CurSelectBox.m_SelectSprite:SetActive(true)

	self:SetUseItemBox()
	self:RefreshOperateBtn()
end

function CTravelItemView.OnClickIcon(self, oItemBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oItemBox.m_Sid, 
		{widget = oItemBox}, nil, {quality = oItemBox.m_Qulity})
	self:OnItemBox(oItemBox)
end

function CTravelItemView.SetUseItemBox(self)
	if self.m_UseItemSid then
		return
	end
	local sid = self.m_CurSelectBox and self.m_CurSelectBox.m_Sid
	if not sid then
		return
	end
	local oItem = CItem.NewBySid(sid)	
	self.m_UseItemBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
	self.m_UseItemBox.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
	self.m_UseItemBox.m_NameLabel:SetText(oItem:GetValue("name"))
	self.m_UseItemBox.m_EffectLabel:SetText(oItem:GetValue("description"))
	self.m_UseItemBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(oItem:GetValue("add_time")))
end

function CTravelItemView.InitUseItemBox(self)
	self.m_UseItemBox.m_IconSprite = self.m_UseItemBox:NewUI(1, CSprite)
	self.m_UseItemBox.m_QulitySprite = self.m_UseItemBox:NewUI(2, CSprite)
	self.m_UseItemBox.m_EffectLabel = self.m_UseItemBox:NewUI(3, CLabel)
	self.m_UseItemBox.m_TimeLabel = self.m_UseItemBox:NewUI(4, CLabel)
	self.m_UseItemBox.m_NameLabel = self.m_UseItemBox:NewUI(5, CLabel)
	self:ClearUseItemBox()
end

function CTravelItemView.ClearUseItemBox(self)
	self.m_UseItemSid = nil
	self.m_UseItemBox.m_EffectLabel:SetText("")
	self.m_UseItemBox.m_TimeLabel:SetText("")
	self.m_UseItemBox.m_NameLabel:SetText("")
	self.m_UseItemBox.m_IconSprite:SetSpriteName(nil)
	self.m_UseItemBox.m_QulitySprite:SetSpriteName(nil)
end

function CTravelItemView.RefreshUseItemBox(self)
	if self.m_UseItemBox.m_Timer then
		Utils.DelTimer(self.m_UseItemBox.m_Timer)
		self.m_UseItemBox.m_Timer = nil
	end
	local dData = g_TravelCtrl:GetMineItemInfo()
	if dData and dData.sid and dData.sid ~= 0 and dData.end_time and dData.server_time then
		self.m_UseItemSid = dData.sid
		local oItem = CItem.NewBySid(self.m_UseItemSid)	
		self.m_UseItemBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		self.m_UseItemBox.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
		self.m_UseItemBox.m_NameLabel:SetText(oItem:GetValue("name"))
		self.m_UseItemBox.m_EffectLabel:SetText(oItem:GetValue("description"))
		self.m_UseItemBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(oItem:GetValue("add_time")))
		local time = math.min(dData.end_time - g_TimeCtrl:GetTimeS(), oItem:GetValue("add_time"))
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 then
				self.m_UseItemBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
				time = time - 1
				return true
			end
		end
		self.m_UseItemBox.m_Timer = Utils.AddTimer(countdown, 1, 0)	
	else
		self:ClearUseItemBox()
	end
end

function CTravelItemView.RefreshOperateBtn(self)
	if self.m_UseItemSid then
		self.m_OperateBtn:SetGrey(false)
		self.m_OperateBtn:SetText("卸下")
	elseif self.m_CurSelectBox then
		self.m_OperateBtn:SetGrey(false)
		self.m_OperateBtn:SetText("使用")
	else
		self.m_OperateBtn:SetGrey(true)
		self.m_OperateBtn:SetText("使用")
	end
end

return CTravelItemView