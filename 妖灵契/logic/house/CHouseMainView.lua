local CHouseMainView = class("CHouseMainView", CViewBase)

function CHouseMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/HouseMainView.prefab", cb)

	self.m_GroupName = "House"
end

function CHouseMainView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	self.m_QuitBtn = self:NewUI(2, CButton)
	self.m_UpgradeBtn = self:NewUI(3, CButton)--装修
	self.m_AdornBtn = self:NewUI(4, CButton)--收藏
	self.m_CamPosBtn = self:NewUI(5, CButton)
	self.m_BackBtn = self:NewUI(6, CButton)
	self.m_PlayerInfoBox = self:NewUI(7, CBox)
	self.m_FriendPart = self:NewUI(8, CHouseFriendPart)
	-- self.m_WarmLabel = self:NewUI(9, CLabel)
	self.m_AdornBox = self:NewUI(10, CHouseAdornBox)
	self.m_FriendBtn = self:NewUI(11, CButton)
	self.m_PhotoBtn = self:NewUI(12, CButton)
	self.m_HideBtn = self:NewUI(13, CButton)
	self.m_RightGroup = self:NewUI(14, CBox)
	self.m_TrainStart = self:NewUI(15, CBox)
	self.m_TrainEnd = self:NewUI(16, CBox)
	self.m_HeadBtn = self:NewUI(17, CButton)
	self.m_HeadPart = self:NewUI(18, CBox)
	-- self.m_RightBottom = self:NewUI(19, CBox)
	self.m_GuideBtn = self:NewUI(20, CButton)
	-- self.m_LTTable = self:NewUI(21, CTable)
	self.m_BuffPart = self:NewUI(22, CBox)
	self.m_ShareTexture = self:NewUI(23, CTexture)
	self.m_NameLabel = self:NewUI(24, CLabel)
	self.m_ServerNameLabel = self:NewUI(25, CLabel)
	self.m_MainView = self:NewUI(26, CBox)
	self.m_SharePart = self:NewUI(27, CBox)
	self:InitContent()
end

function CHouseMainView.InitContent(self)
	self:RecordInfo()
	self.m_SharePart:SetActive(false)
	self.m_NameLabel:SetText(g_AttrCtrl.name)
	self.m_ServerNameLabel:SetText(g_ServerCtrl:GetCurServerName())
	g_GuideCtrl:AddGuideUI("house_main_door_btn", self.m_GuideBtn)
	self.m_FriendBtn:SetActive(g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.friend.open_grade)
	self:InitHeadPart()
	self:InitBuffPart()
	self.m_TrainStart:SetActive(false)
	self.m_TrainEnd:SetActive(false)
	self.m_FriendPart:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_FriendPart, function(obj)
		self.m_FriendPart:SetActive(false)
		if not g_HouseCtrl:IsInFriendHouse() then
			self.m_PlayerInfoBox:SetActive(false)
			self.m_HeadPart:SetActive(true)
			-- self:DelayCall(0, "RefreshTable")
		end
		-- self.m_FriendBtn:SetActive(true)
	end)
	self:InitPlayerBox()
	UITools.ResizeToRootSize(self.m_Contanier, 4, 4)
	-- self.m_BackBtn:SetActive(false)
	self.m_AdornBox:SetActive(false)
	self.m_GuideBtn:SetActive(false)

	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	self.m_CamPosBtn:AddUIEvent("click", callback(self, "OnCamPos"))
	
	self.m_AdornBtn:AddUIEvent("click", callback(self, "OnAdorn"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	g_PlayerBuffCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBuffEvent"))
	self.m_PhotoBtn:AddUIEvent("click", callback(self, "OnPhoto"))
	self.m_FriendBtn:AddUIEvent("click", callback(self, "OnFriend"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnClickHide"))
	self.m_HeadBtn:AddUIEvent("click", callback(self, "OnClickHead"))
	self.m_GuideBtn:AddUIEvent("click", callback(self, "OnClickGuideDoor"))
	--tzq屏蔽未完成功能
	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnUpgrade"))
	--lq屏蔽按钮
	local bShow = g_ShareCtrl:IsShowShare()
	self.m_PhotoBtn:SetActive(bShow)
	self.m_UpgradeBtn:SetActive(bShow)
	self.m_AdornBtn:SetActive(bShow)
	-- self:RefreshWarm()
	self:Refresh()
end

function CHouseMainView.RecordInfo(self)
	self.m_ExpDic = {}
	for i,v in ipairs(data.housedata.PartnerPanel) do
		local partnerInfo = g_HouseCtrl:GetPartnerInfo(v.partner_id)
		if partnerInfo then
			self.m_ExpDic[v.partner_id] = {love_level = partnerInfo.love_level, love_ship = partnerInfo.love_ship}
		else
			self.m_ExpDic[v.partner_id] = {love_level = 0, love_ship = 0}
		end
	end
	-- printc("RecordInfo")
	-- table.print(self.m_ExpDic, "self.m_ExpDic")
end

-- function CHouseMainView.RefreshTable(self)
-- 	self.m_LTTable:Reposition()
-- end

function CHouseMainView.InitHeadPart(self)
	local oHeadPart = self.m_HeadPart
	oHeadPart.m_HeadGrid = oHeadPart:NewUI(1, CGrid)
	oHeadPart.m_HeadBox = oHeadPart:NewUI(2, CBox)
	oHeadPart.m_ExpLabel = oHeadPart:NewUI(3, CLabel)
	-- g_UITouchCtrl:TouchOutDetect(oHeadPart, function(obj)
	-- 	oHeadPart:SetActive(false)
	-- end)
	oHeadPart:SetActive(false)
	oHeadPart.m_HeadBox:SetActive(false)
	local sortList = {}
	for i,v in ipairs(data.housedata.PartnerPanel) do
		if g_HouseCtrl:GetPartnerInfo(v.partner_id) then
			table.insert(sortList, v)
		end
	end
	for i,v in ipairs(data.housedata.PartnerPanel) do
		if not g_HouseCtrl:GetPartnerInfo(v.partner_id) then
			table.insert(sortList, v)
		end
	end
	self.m_HeadDic = {}
	for i,v in ipairs(sortList) do
		local oHeadBox = self:CreateHeadBox()
		self.m_HeadDic[v.partner_id] = oHeadBox
		oHeadBox:SetData(v)
	end
end

function CHouseMainView.InitBuffPart(self)
	local oBuffPart = self.m_BuffPart
	oBuffPart.m_BuffSprite = oBuffPart:NewUI(1, CSprite)
	oBuffPart.m_ProcessSprite = oBuffPart:NewUI(2, CSprite)
	oBuffPart.m_LvLabel = oBuffPart:NewUI(3, CLabel)
	oBuffPart.m_ProcessLabel = oBuffPart:NewUI(4, CLabel)
	oBuffPart.m_BuffSprite:AddUIEvent("click", callback(self, "ShowBuffView"))
	function oBuffPart.Refresh(self)
		local oInfo = g_PlayerBuffCtrl:GetHouseBuff()
		local oData = data.housedata.LoveBuff[oInfo.stage]
		local oDataNext = data.housedata.LoveBuff[oInfo.stage + 1] or oData
		oBuffPart.m_BuffSprite:SetGrey(oInfo.stage <= 0)
		oBuffPart.m_BuffSprite:SpriteHouseBuff(oData.icon)
		-- oBuffPart.m_ProcessSprite:SetSpriteName("")
		oBuffPart.m_LvLabel:SetText(oInfo.stage)
		oBuffPart.m_ProcessLabel:SetText(string.format("%s/%s", g_HouseCtrl:GetTotalLoveLv(), oDataNext.total_level))
		oBuffPart.m_ProcessSprite:SetFillAmount(g_HouseCtrl:GetTotalLoveLv() / oDataNext.total_level)
		-- oBuffPart:SetActive(not g_HouseCtrl:IsInFriendHouse())
	end

	g_GuideCtrl:AddGuideUI("house_main_buff_btn", oBuffPart.m_BuffSprite)
end

function CHouseMainView.ShowBuffView(self)
	g_GuideCtrl:TargetGuideStepContinu("HouseTwoView", 1)
	CHouseBuffView:ShowView()
end

function CHouseMainView.CreateHeadBox(self)
	local oHeadBox = self.m_HeadPart.m_HeadBox:Clone()
	oHeadBox.m_Sprite = oHeadBox:NewUI(2, CSprite)
	oHeadBox.m_LockSprite = oHeadBox:NewUI(3, CSprite)


	oHeadBox:AddUIEvent("click", callback(self, "OnClickHeadBox", oHeadBox))
	oHeadBox:SetActive(true)
	self.m_HeadPart.m_HeadGrid:AddChild(oHeadBox)

	function oHeadBox.SetData(self, oData)
		oHeadBox.m_Data = oData
		
		-- oHeadBox.m_Label:SetText(oData.desc)
		if oData.partner_id then
			local partnerData = g_HouseCtrl:GetPartnerInfo(oData.partner_id)
			-- printc("SetData: " .. oData.icon)
			if partnerData then
				oHeadBox.m_HasPartner = true
				-- oHeadBox:SetGrey(false)
				-- oHeadBox.m_Sprite:SetGrey(false)
				oHeadBox.m_Sprite:SpriteHouseSmallAvatar(oData.icon)
				oHeadBox.m_LockSprite:SetActive(false)
			else
				oHeadBox.m_HasPartner = false
				oHeadBox.m_LockSprite:SetActive(true)
				oHeadBox.m_Sprite:SpriteHouseSmallAvatar(100000 + oData.icon)
				-- oHeadBox:SetGrey(true)
				-- oHeadBox.m_Sprite:SetGrey(true)
			end
		end
	end

	return oHeadBox
end

function CHouseMainView.OnClickGuideDoor(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	nethouse.C2GSOpenWorkDesk(g_HouseCtrl.m_OwnerPid)
	self.m_GuideBtn:SetActive(false)
end

function CHouseMainView.OnClickHeadBox(self, oHeadBox)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	if oHeadBox.m_HasPartner then
		if g_HouseCtrl:IsHouseOnly() then
			CHouseExchangeTestView:ShowView(function (oView)
				oView:SetPartnerInfo(oHeadBox.m_Data.partner_id)
			end)
		else
			CHouseExchangeView:ShowView(function (oView)
				oView:SetPartnerInfo(oHeadBox.m_Data.partner_id)
			end)
		end
	else
		g_NotifyCtrl:FloatMsg(oHeadBox.m_Data.tips)
	end
end

function CHouseMainView.InitPlayerBox(self)
	local oPlayerInfoBox = self.m_PlayerInfoBox
	oPlayerInfoBox.m_AvatarSprite = oPlayerInfoBox:NewUI(1, CSprite)
	oPlayerInfoBox.m_NameLabel = oPlayerInfoBox:NewUI(2, CLabel)
	oPlayerInfoBox.m_TeaArtLvLabel = oPlayerInfoBox:NewUI(3, CLabel)
	oPlayerInfoBox.m_FriendshipLabel = oPlayerInfoBox:NewUI(4, CLabel)
	function oPlayerInfoBox.Refresh(self)
		if g_HouseCtrl:IsInFriendHouse() then
			local friendData = g_FriendCtrl:GetFriend(g_HouseCtrl.m_OwnerPid)
			if friendData then
				oPlayerInfoBox.m_AvatarSprite:SpriteAvatar(friendData.shape)
				oPlayerInfoBox.m_NameLabel:SetText(friendData.name)
				oPlayerInfoBox.m_FriendshipLabel:SetText("好友度:" .. (friendData.friend_degree or "0"))
				oPlayerInfoBox.m_FriendshipLabel:SetActive(true)
				oPlayerInfoBox.m_TeaArtLvLabel:SetActive(false)
			else
				printc("<color=#ff0000>不存在好友id:</color>" .. g_HouseCtrl.m_OwnerPid)
			end
		else
			oPlayerInfoBox.m_AvatarSprite:SpriteAvatar(g_AttrCtrl.model_info.shape)
			oPlayerInfoBox.m_NameLabel:SetText(g_AttrCtrl.name)
			oPlayerInfoBox.m_TeaArtLvLabel:SetText("厨艺等级:" .. g_HouseCtrl:GetTalentLevel())
			oPlayerInfoBox.m_FriendshipLabel:SetActive(false)
			oPlayerInfoBox.m_TeaArtLvLabel:SetActive(true)
			-- oPlayerInfoBox:SetActive(false)
		end
	end
end

function CHouseMainView.OnHideView(self)
	self.m_TrainStart:SetActive(false)
	self.m_TrainEnd:SetActive(false)
end

function CHouseMainView.Refresh(self)
	self.m_PlayerInfoBox:Refresh()
	self.m_BuffPart:Refresh()
	if g_HouseCtrl:IsInFriendHouse() then
		self.m_RightGroup:SetActive(false)
		self.m_HideBtn:SetActive(false)
		self.m_HeadPart:SetActive(false)
		-- self.m_RightBottom:SetActive(false)
		-- self.m_BackBtn:SetActive(true)
	else
		-- self.m_RightBottom:SetActive(true)
		self.m_RightGroup:SetActive(true)
		self.m_HideBtn:SetActive(true)
		self.m_HeadPart:SetActive(true)
	end
	-- self:DelayCall(0, "RefreshTable")
end

function CHouseMainView.OnClickHide(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	local bShow = self.m_RightGroup:GetActive()
	self.m_RightGroup:SetActive(not bShow)
	-- self.m_RightBottom:SetActive(not bShow)
	self.m_HideBtn:SetSpriteName(bShow and "btn_zhaidi_shousuoanniu1" or "pic_zhaidi_shousuoanniu2")
end

function CHouseMainView.OnPhoto(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	-- g_NotifyCtrl:FloatMsg("该功能暂未开启")
	if not self.m_ShareTexture.m_Init then
		local tex = Utils.CreateQRCodeTex(define.Url.OffcialWeb, self.m_ShareTexture.m_UIWidget.width)
		self.m_ShareTexture:SetMainTexture(tex)
		self.m_ShareTexture.m_Init = true
	end
	self.m_SharePart:SetActive(true)
	self.m_MainView:SetActive(false)
	Utils.AddTimer(callback(self, "PrintSceen"), 0, 0)
end

function CHouseMainView.PrintSceen(self)
	local rt = UnityEngine.RenderTexture.New(1334, 750, 16)
	local oCam2 = g_CameraCtrl:GetHouseCamera()
	local oCam = g_CameraCtrl:GetUICamera()
	g_NotifyCtrl:HideView(true)
	oCam2:SetTargetTexture(rt)
	oCam2:Render()
	oCam:SetTargetTexture(rt)
	oCam:Render()
	oCam:SetTargetTexture(nil)
	oCam2:SetTargetTexture(nil)
	local texture2D = UITools.GetRTPixels(rt)
	local filename = os.date("%Y%m%d%H%M%S", g_TimeCtrl:GetTimeS())
	local path = IOTools.GetRoleFilePath(string.format("/Screen/%s.jpg", filename))
	IOTools.SaveByteFile(path, texture2D:EncodeToJPG())
	local sTip = string.format("#妖灵契#我家的小姐姐，世界第一棒~%s】", define.Url.OffcialWeb)
	g_ShareCtrl:ShareImage(path, sTip, function () 
		if not g_AttrCtrl:IsHasGameShare() then
			netplayer.C2GSGameShare("house_share")
		end
	end)
	self:EndShare()
end

function CHouseMainView.EndShare(self)
	self.m_MainView:SetActive(true)
	g_NotifyCtrl:HideView(false)
	self.m_SharePart:SetActive(false)
end

function CHouseMainView.OnFriend(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	nethouse.C2GSFriendHouseProfile()
end

function CHouseMainView.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.FriendRefresh
		or oCtrl.m_EventID == define.House.Event.OnRecieveHouseCoin then
		self.m_FriendPart:SetData()
		self.m_PlayerInfoBox:SetActive(true)
		self.m_HeadPart:SetActive(false)
		-- self.m_BackBtn:SetActive(true)
		-- self.m_FriendBtn:SetActive(false)
	elseif oCtrl.m_EventID == define.House.Event.SetHouseInfo then
		self:Refresh()
		self.m_PlayerInfoBox:SetActive(g_HouseCtrl:IsInFriendHouse())
		self.m_HeadPart:SetActive(not self.m_PlayerInfoBox:GetActive())
		self.m_FriendPart:SetActive(false)
		-- self.m_FriendBtn:SetActive(true)
	elseif oCtrl.m_EventID == define.House.Event.TalentRefresh then
		self.m_PlayerInfoBox:Refresh()
	elseif oCtrl.m_EventID == define.House.Event.PartnerRefresh then
		local partnerInfo = g_HouseCtrl:GetPartnerInfos()
		for k,v in pairs(partnerInfo) do
			local iExp = 0
			for i = self.m_ExpDic[v.type].love_level, v.love_level - 1 do
				iExp = iExp + g_HouseCtrl:GetMaxLove(i)
			end
			iExp = iExp + v.love_ship - self.m_ExpDic[v.type].love_ship
			if iExp > 0 then
				local expAni = self.m_HeadPart.m_ExpLabel:Clone()
				expAni:SetText(iExp)
				expAni:SetActive(true)
				expAni:SetParent(self.m_HeadDic[v.type].m_Transform)
				expAni:DelayCall(2, "Destroy")
			end
		end
		self.m_BuffPart:Refresh()
		self:RecordInfo()
	elseif oCtrl.m_EventID == define.House.Event.UpdateFriendWorkDesk then
		if self.m_HeadPart:GetActive() then
			nethouse.C2GSFriendHouseProfile()
		end
	end
	-- self.m_LTTable:Reposition()
	-- if oCtrl.m_EventID == define.House.Event.WarmRefresh then
		-- self:RefreshWarm()
	-- end
end

function CHouseMainView.PlayTrainStart(self)
	self.m_TrainStart:SetActive(false)
	self.m_TrainStart:SetActive(true)
end

function CHouseMainView.PlayTrainEnd(self)
	self.m_TrainEnd:SetActive(false)
	self.m_TrainEnd:SetActive(true)
end

-- function CHouseMainView.RefreshWarm(self)
-- 	local sText = string.format("温馨度:%d/%d", g_HouseCtrl.m_CurWarm, g_HouseCtrl.m_MaxWarm)
-- 	self.m_WarmLabel:SetText(sText)
-- end

function CHouseMainView.OnQuit(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	g_HouseCtrl:LeaveHouse()
end

function CHouseMainView.OnAdorn(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	g_NotifyCtrl:FloatMsg("该功能暂未开启")
	-- local oHouse = g_HouseCtrl:GetCurHouse()
	-- oHouse:SetHouseMode(define.House.Mode.Adorn)
	-- self.m_BackBtn:SetActive(true)
end

function CHouseMainView.OnUpgrade(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	g_NotifyCtrl:FloatMsg("该功能暂未开启")
	-- local oHouse = g_HouseCtrl:GetCurHouse()
	-- oHouse:SetHouseMode(define.House.Mode.Upgrade)
	-- self.m_BackBtn:SetActive(true)
end

function CHouseMainView.OnClickHead(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	self.m_HeadPart:SetActive(true)
end

function CHouseMainView.OnCamPos(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	g_HouseCtrl:NextCameraPos()
end

function CHouseMainView.OnBack(self)
	if not g_HouseCtrl:CanTouch() then
		return
	end
	if self.m_FriendPart:GetActive() then
		self.m_PlayerInfoBox:SetActive(g_HouseCtrl:IsInFriendHouse())
		self.m_FriendPart:SetActive(false)
		-- self:DelayCall(0, "RefreshTable")
		-- self.m_FriendBtn:SetActive(true)
		-- self.m_BackBtn:SetActive(g_HouseCtrl:IsInFriendHouse())
	elseif self.m_AdornBox:GetActive() then
		self:SetAdornBox(nil)
		local oHouse = g_HouseCtrl:GetCurHouse()
		oHouse:SetHouseMode(define.House.Mode.Normal)
		-- self.m_BackBtn:SetActive(false)
	elseif g_HouseCtrl:IsInFriendHouse() then
		nethouse.C2GSEnterHouse(g_AttrCtrl.pid)
		-- self.m_BackBtn:SetActive(false)
	else
		g_HouseCtrl:LeaveHouse()
	end
end

function CHouseMainView.SetAdornBox(self, oFurniture, oNearWidget)
	if oFurniture and self.m_AdornBox:GetActive() then
		return
	end
	if oFurniture then
		g_HouseCtrl:LookFurniture(oFurniture)
		g_HouseTouchCtrl:LockTouch(true)
		self.m_AdornBox:SetActive(true)
		self.m_AdornBox:SetAdornList(oFurniture:GetAdornList())
		Utils.AddTimer(function()
			UITools.NearTarget(oNearWidget, self.m_AdornBox, enum.UIAnchor.Side.Right) 
			end, 0, 0.01)
	else
		g_HouseCtrl:LookFurniture(nil)
		self.m_AdornBox:SetAdornList({})
		self.m_AdornBox:SetActive(false)
		g_HouseTouchCtrl:LockTouch(false)
	end
end

function CHouseMainView.OnBuffEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PlayerBuff.Event.OnRefreshBuff then
		self.m_BuffPart:Refresh()
		-- self:DelayCall(0, "RefreshTable")
	end
end

function CHouseMainView.Destroy(self)
	g_GuideCtrl:FinishAllHouseGuide()
	CViewBase.Destroy(self)
end

return CHouseMainView