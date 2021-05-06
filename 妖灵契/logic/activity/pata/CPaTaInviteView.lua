local CPaTaInviteView = class("CPaTaInviteView", CViewBase)

function CPaTaInviteView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PaTaInviteView.prefab", cb)
	self.m_ExtendClose = "Shelter"
end

function CPaTaInviteView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	-- self.m_PartnerGrid = self:NewUI(2, CGrid)
	-- self.m_PartnerBox = self:NewUI(3, CBox)
	-- self.m_PageGrid = self:NewUI(4, CGrid)
	-- self.m_PageBox = self:NewUI(5, CBox)
	self.m_ScrollPage = self:NewUI(6, CFactoryPartScroll)
	self.m_FriendScrollView = self:NewUI(7, CScrollView)
	self.m_FriendGrid = self:NewUI(8, CGrid)
	self.m_FriendBox = self:NewUI(9, CBox)
	self.m_RemainLabel = self:NewUI(10, CLabel)
	self:InitContent()

	self.m_InviteCount = 0
	self.m_SelectFrnPid = nil
	self.m_FrdList = {}
	self.m_PartnerList = {}
	self.m_PartnerBoxList = {}
end

function CPaTaInviteView.InitContent(self)
	self.m_FriendBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))

	self:InitScrollPage()
end

function CPaTaInviteView.SetContent(self, cnt, frdList)
	self.m_InviteCount = cnt or 0
	if self.m_InviteCount > CPataCtrl.InviteMaxCount then
		self.m_InviteCount = CPataCtrl.InviteMaxCount
	end
	self.m_FrdList = {}
	self.m_PartnerList = {}
	self.m_PartnerBoxList = {}
	self.m_SelectFrnPid = nil
	if next(frdList) ~= nil then
		for i = 1, #frdList do
			local ptCnt = frdList[i].ptncnt or 0 
			if ptCnt > 0 then
				table.insert(self.m_FrdList, frdList[i])
				if i == 1 then
					self.m_SelectFrnPid = frdList[i].pid
					g_PataCtrl:CtrlC2GSPataFrdInfo(self.m_SelectFrnPid)
				end
			end
		end
	end
	self:RefreshAll()
end

function CPaTaInviteView.RefreshAll(self)
	self.m_RemainLabel:SetText(string.format("%d/%d", self.m_InviteCount, CPataCtrl.InviteMaxCount))
	self:RefreshFrdList()
end

function CPaTaInviteView.RefreshFrdList(self)
	self.m_FriendGrid:Clear()
	if next(self.m_FrdList) ~= nil then
		for i = 1, #self.m_FrdList do
			local t = self.m_FrdList[i]
			local oBox = self.m_FriendBox:Clone()		
			oBox:SetActive(true)
			oBox.m_IconSprite = oBox:NewUI(1, CSprite)
			oBox.m_NameLabel = oBox:NewUI(2, CLabel)
			oBox.m_PowerLabel = oBox:NewUI(3, CLabel)
			oBox.m_LikeBtn = oBox:NewUI(4, CBox)		
			oBox.m_GradeLabel = oBox:NewUI(5, CLabel)	
			oBox.m_Pid = t.pid
			oBox:SetGroup(self.m_FriendGrid:GetInstanceID())
			oBox.m_IconSprite:SpriteAvatar(t.shape)
			oBox.m_NameLabel:SetText(t.name)
			oBox.m_PowerLabel:SetText(string.format("战力:%d", t.power))		
			oBox.m_GradeLabel:SetText(tostring(t.grade))	
			if self.m_SelectFrnPid == oBox.m_Pid then
				oBox:SetSelected(true)
			end
			oBox:AddUIEvent("click", callback(self, "OnSelectFrd", oBox.m_Pid))
			oBox.m_LikeBtn:AddUIEvent("click", callback(self, "OnLike", oBox.m_Pid))
			oBox.m_LikeBtn:SetGrey(t.upvote)
			self.m_FriendGrid:AddChild(oBox)
		end
	end
end

function CPaTaInviteView.RefreshPartnerList(self, target, partList)
	self.m_PartnerList = partList	
	self:ScrollPageSetData(partList)
end

function CPaTaInviteView.OnSelectFrd(self, pid)
	if pid ~= self.m_SelectFrnPid then
		self.m_SelectFrnPid = pid
		g_PataCtrl:CtrlC2GSPataFrdInfo(self.m_SelectFrnPid)
	end
end

function CPaTaInviteView.OnLike(self, pid, oBtn)
	if oBtn then
		oBtn:SetGrey(true)
	end
	netplayer.C2GSUpvotePlayer(pid)
end

function CPaTaInviteView.OnSelectPartner(self, parId)
	local name = ""
	for k, v in pairs(self.m_FrdList) do
		if v.pid == self.m_SelectFrnPid then
			name = v.name
			break
		end
	end
	local tMsg = string.format("确认邀请%s的伙伴助战么？", name)
	local windowConfirmInfo = {
		msg				= tMsg,
		okCallback		= function ()
			g_PataCtrl:CtrlC2GSPataInvite(self.m_SelectFrnPid, parId)
		end,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CPaTaInviteView.SetGridStar(self, grid, star)
	if star < 0 then
		star = 0 
	end
	if star > 5 then
		star = 5
	end
	if grid then
		local child = grid:GetChildList()
		for i = 1, #child do 			
			local oBox = child[i]
			if oBox then				
				if i <= star then
					oBox:SetActive(true)
				else
					oBox:SetActive(false)
				end
			end
		end
	end
end

function CPaTaInviteView.SetGridStar(self, grid, star)
	if star < 0 then
		star = 0 
	end
	if star > 5 then
		star = 5
	end
	if grid then
		local child = grid:GetChildList()
		for i = 1, #child do 			
			local oBox = child[i]
			if oBox then				
				if i <= star then
					oBox:SetActive(true)
				else
					oBox:SetActive(false)
				end
			end
		end
	end
end

function CPaTaInviteView.InitScrollPage(self)
	local oPart = self.m_ScrollPage
	self.m_ScrollPage:SetPartSize(3, 1)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			local t = self.m_PartnerList[dData.idx]
			oBox.m_ActorTexture = oBox:NewUI(1, CActorTexture)
			oBox.m_PowerLabel = oBox:NewUI(2, CLabel)
			oBox.m_GradeLabel = oBox:NewUI(3, CLabel)
			oBox.m_QualitySprite = oBox:NewUI(4, CSprite)
			oBox.m_StarGrid = oBox:NewUI(5, CGrid)
			oBox.m_QulityLabel = oBox:NewUI(6, CLabel)
			oBox.m_StarGrid:InitChild(function (obj, idx)
				local oSpr = CSprite.New(obj)
				oSpr:SetActive(false)
				return oSpr
			end)
	
			oBox.m_ActorTexture:ChangeShape(t.modeid)
			oBox.m_PowerLabel:SetText(string.format("%d", t.power))
			oBox.m_GradeLabel:SetText(string.format("等级:%d级", t.grade))
			local Rare = {
			[1] = "精英伙伴",
			[2] = "传说伙伴",			
			}
			oBox.m_QualitySprite:SetActive(false)
			--oBox.m_QualitySprite:SetSpriteName(string.format("text_dilao_%s", Rare[t.rare]))
			--oBox.m_QualitySprite:MakePixelPerfect()
			oBox.m_QulityLabel:SetText(Rare[t.rare])
			oBox:AddUIEvent("click", callback(self, "OnSelectPartner", t.parid))
			self:SetGridStar(oBox.m_StarGrid, t.star)
			oBox:SetActive(true)
			return oBox
		end
	end
	self.m_ScrollPage:SetFactoryFunc(factory)
end

function CPaTaInviteView.ScrollPageSetData(self, list)
	if not list or #list < 1 then
		self.m_ScrollPage:SetActive(false)
		return 
	end
	self.m_ScrollPage:SetActive(true)

	local function data()
		local t = {}
		for i= 1, #list do
			table.insert(t, {idx = i})
		end
		return t
	end
	self.m_ScrollPage:SetDataSource(data)
	self.m_ScrollPage:RefreshAll()
end

function CPaTaInviteView.OnCtrlMapEvent( self, oCtrl )
	if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		if g_TeamCtrl:IsInTeam() then
			self:CloseView()
		end
	end
end

return CPaTaInviteView