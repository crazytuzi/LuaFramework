---------------------------------------------------------------
--暗雷主界面


---------------------------------------------------------------

local CAnLeiMainView = class("CAnLeiMainView", CViewBase)


function CAnLeiMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/AnLei/AnLeiMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CAnLeiMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_MainDesLabel = self:NewUI(3, CLabel)
	self.m_OffLineTipsBtn = self:NewUI(4, CButton)
	self.m_GoBtn = self:NewUI(5, CButton)
	self.m_AnLeiPointLabel = self:NewUI(6, CLabel)
	self.m_RewardGrid = self:NewUI(7, CGrid)
	self.m_RewardBox = self:NewUI(8, CItemTipsBox)
	self.m_AddPointBtn = self:NewUI(9, CButton)
	self.m_TitleLabel = self:NewUI(10, CLabel)
	self.m_TipsLabel = self:NewUI(11, CLabel)
	self.m_GoBtn2 = self:NewUI(12, CButton)
	self.m_FindNpcBtn = self:NewUI(13, CButton)
	self.m_SubDeslaberl = self:NewUI(14, CLabel)
	self.m_MapId = nil
	self.m_CallBack = nil
	self:InitContent()
end

function CAnLeiMainView.InitContent(self)
	self.m_RewardBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_GoBtn:AddUIEvent("click", callback(self, "OnGo"))
	self.m_GoBtn2:AddUIEvent("click", callback(self, "OnGo"))
	self.m_FindNpcBtn:AddUIEvent("click", callback(self, "OnFindNpc"))
	self.m_AddPointBtn:AddUIEvent("click", callback(self, "OnAdd"))

	g_AnLeiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAnLeilEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))

	self.m_OffLineTipsBtn:AddHelpTipClick("anlei_offline_tips")
	self.m_GoBtn:SetActive(false)
	self.m_GoBtn2:SetActive(false)
	self.m_FindNpcBtn:SetActive(false)

	--隐藏奇袭按钮
	-- if g_AnLeiCtrl:IsHaveNpc() then
	-- 	self.m_GoBtn2:SetActive(true)
	-- 	self.m_FindNpcBtn:SetActive(true)
	-- else
		self.m_GoBtn:SetActive(true)
	--end

	self:RefreshText()
	self:RefreshReward()
end

function CAnLeiMainView.OnCtrlAnLeilEvent( self, oCtrl)
	-- if oCtrl.m_EventID == 1 then
	-- end
end

function CAnLeiMainView.SetContent(self, args)
	args = args	or {}
	self.m_MapId = args.mapId or 0
	self.m_CallBack = args.callBack 
	local str = ""
	local mapInfo = g_MapCtrl:GetMapInfo(self.m_MapId)
	local showIcons = g_AnLeiCtrl:GetMapShowIcon(self.m_MapId)
	if mapInfo and showIcons and next(showIcons) then
		str = mapInfo.scene_name .. "有概率遇到"
		for i, v in ipairs(showIcons) do
			local d = data.partnerdata.DATA[v]
			if d then
				if i == #showIcons then
					str = str..d.name.."。"
				else
					str = str..d.name.."、"
				end
			end
		end
	end
	self.m_SubDeslaberl:SetText(str)
end

function CAnLeiMainView.OnGo(self)
	if g_AnLeiCtrl:GoToPatrol(self.m_MapId) then
		if self.m_CallBack then
			self.m_CallBack()
		end
		self:CloseView()
	end
end

function CAnLeiMainView.OnFindNpc(self)
	if g_AnLeiCtrl:WalkToNpc() then
		if self.m_CallBack then
			self.m_CallBack()
		end		
		self:CloseView()
	end
end

function CAnLeiMainView.OnAdd(self)
	if g_AttrCtrl.trapmine_point >= CAnLeiCtrl.AnLeiPointMax then		
		g_NotifyCtrl:FloatMsg("当前探索点已满，请使用后继续购买。")
	else
		CAnLeiAddTipsView:ShowView()	
	end	
end

function CAnLeiMainView.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshText()
	end
end

function CAnLeiMainView.RefreshText(self)
	self.m_AnLeiPointLabel:SetText(string.format("%d/%d", g_AttrCtrl.trapmine_point, CAnLeiCtrl.AnLeiPointMax))
end

function CAnLeiMainView.RefreshReward(self)
	local d = g_AnLeiCtrl:GetConfig()
	self.m_RewardGrid:Clear()
	if d then
		local list = d.item_rewards_show
		for i = 1, #list do
			local sid = nil
			local parId	= nil
			local value = nil
			local str = list[i].sid 
			if string.find(str, "value") then
				sid, value = g_ItemCtrl:SplitSidAndValue(str)
			elseif string.find(str, "partner") then
				sid, parId = g_ItemCtrl:SplitSidAndValue(str)
			else
				sid = tonumber(str)
			end
			local oBox = self.m_RewardBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true, refreshSize = 80}
			oBox:SetItemData(sid, 1, parId, config)
			self.m_RewardGrid:AddChild(oBox)
		end
		self.m_TitleLabel:SetText(d.name)
		self.m_MainDesLabel:SetText(d.des)
		self.m_TipsLabel:SetText(d.tips)
	end
end

return CAnLeiMainView