local CTravelOtherBox = class("CTravelOtherBox", CBox)

function CTravelOtherBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_BGSprite = self:NewUI(2, CSprite)
	self.m_ItemBox = self:NewUI(3, CBox)
	self.m_InviteBox = self:NewUI(4, CBox)
	self.m_PartnerBox = self:NewUI(5, CBox)
	self.m_GameBox = self:NewUI(6, CBox)
	self.m_ExchangeBox = self:NewUI(7, CBox)

	self.m_Type = nil --自己游历/好友游历
	--分开标记
	self.m_ItemFlag = 0 --0隐藏，1显示
	self.m_InviteFlag = 0 --0隐藏，1显示
	self.m_PartnerFlag = 0 --0隐藏，1显示
	self.m_GameFlag = 0 --0隐藏，1显示
	self.m_ExchangeFlag = 0 --0隐藏，1显示
	self:InitContent()
end

function CTravelOtherBox.InitContent(self)
	self:InitItemBox()
	self:InitInviteBox()
	self:InitPartnerBox()
	self:InitGameBox()
	self:InitExchangeBox()
end

function CTravelOtherBox.Refresh(self, iType)
	self.m_Type = iType
	if self.m_Type == define.Travel.Type.Mine then
		self:RefreshItemMine()
		self:RefreshInviteMine()
		self:RefreshPartnerMine()
		self:RefreshGameMine()
		self:RefreshExchangeMine()
	elseif self.m_Type == define.Travel.Type.Friend then
		self:RefreshItemFriend()
		self:RefreshInviteFriend()
		self:RefreshPartnerFriend()
		self:RefreshGameFriend()
		self:RefreshExchangeFriend()
	end
	self.m_Grid:Reposition()
	self:RefreshBGSize()
end

function CTravelOtherBox.RefreshBGSize(self)
	local sumflage = self.m_ItemFlag + self.m_InviteFlag + self.m_PartnerFlag + self.m_GameFlag + self.m_ExchangeFlag
	self.m_BGSprite:SetActive(sumflage > 0)
	local w,h = 122,122*sumflage
	self.m_BGSprite:SetSize(w, h)
	--printc(self.m_ItemFlag , self.m_InviteFlag , self.m_PartnerFlag , self.m_GameFlag , self.m_ExchangeFlag)
end

--region 游历道具
function CTravelOtherBox.InitItemBox(self)
	local oBox = self.m_ItemBox
	oBox.m_IconSprite = oBox:NewUI(1, CSprite)
	oBox.m_QulitySprite = oBox:NewUI(2, CSprite)
	oBox.m_EffectLabel = oBox:NewUI(3, CLabel)
	oBox.m_TimeLabel = oBox:NewUI(4, CLabel)
	oBox.m_AddSprite = oBox:NewUI(5, CSprite)
	oBox:AddUIEvent("click", callback(self, "OnItemBox"))
end

function CTravelOtherBox.OnItemBox(self, oBox)
	if self.m_Type == define.Travel.Type.Mine then
		CTravelItemView:ShowView()
		if next(g_ItemCtrl:GetTravelItems()) and not IOTools.GetRoleData("travel_item_first") then
			IOTools.SetRoleData("travel_item_first", true)
			self.m_ItemBox.m_AddSprite:DelEffect("circle")
		end
	elseif self.m_Type == define.Travel.Type.Friend then
		g_NotifyCtrl:FloatMsg("无法对好友游历添加道具")
	end
end

function CTravelOtherBox.RefreshItemMine(self)
	self.m_ItemFlag = 1
	local oBox = self.m_ItemBox
	oBox:SetActive(true)
	if oBox.m_Timer then
		Utils.DelTimer(oBox.m_Timer)
		oBox.m_Timer = nil
	end
	local dData = g_TravelCtrl:GetMineItemInfo()
	if dData and dData.sid and dData.sid ~= 0 and dData.end_time and dData.server_time then
		local sid = dData.sid
		local oItem = CItem.NewBySid(sid)
		oBox.m_IconSprite:SetActive(true)
		oBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
		oBox.m_EffectLabel:SetText(oItem:GetValue("description"))
		oBox.m_AddSprite:SetActive(false)
		oBox.m_AddSprite:DelEffect("circle")
		local time = math.min(dData.end_time - g_TimeCtrl:GetTimeS(), oItem:GetValue("add_time"))
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 then
				oBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
				time = time - 1
				return true
			end
		end
		oBox.m_Timer = Utils.AddTimer(countdown, 1, 0)		
	else
		oBox.m_EffectLabel:SetText("")
		oBox.m_TimeLabel:SetText("")
		oBox.m_IconSprite:SetActive(false)
		oBox.m_IconSprite:SetSpriteName(nil)
		oBox.m_QulitySprite:SetSpriteName(nil)
		oBox.m_AddSprite:SetActive(self.m_Type == define.Travel.Type.Mine)
		if self.m_Type == define.Travel.Type.Mine and next(g_ItemCtrl:GetTravelItems()) and not IOTools.GetRoleData("travel_item_first") then
			oBox.m_AddSprite:AddEffect("circle")
		end
	end
end

function CTravelOtherBox.RefreshItemFriend(self)
	local oBox = self.m_ItemBox
	local dData = g_TravelCtrl:GetFrdTravelItem()
	if dData and dData.sid and dData.sid ~= 0 and dData.end_time then
		self.m_ItemFlag = 1
		self.m_ItemBox:SetActive(true)
		local sid = dData.sid
		local oItem = CItem.NewBySid(sid)	
		oBox.m_IconSprite:SetActive(true)
		oBox.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
		oBox.m_EffectLabel:SetText(oItem:GetValue("description"))
		oBox.m_AddSprite:SetActive(false)
		if oBox.m_Timer then
			Utils.DelTimer(oBox.m_Timer)
			oBox.m_Timer = nil
		end
		local time = dData.end_time - g_TimeCtrl:GetTimeS()
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 then
				oBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
				time = time - 1
				return true
			end
		end
		oBox.m_Timer = Utils.AddTimer(countdown, 1, 0)
	else
		self.m_ItemFlag = 0
		self.m_ItemBox:SetActive(false)
		if oBox.m_Timer then
			Utils.DelTimer(oBox.m_Timer)
			oBox.m_Timer = nil
		end
		oBox.m_EffectLabel:SetText("")
		oBox.m_TimeLabel:SetText("")
		oBox.m_IconSprite:SetActive(false)
		oBox.m_IconSprite:SetSpriteName(nil)
		oBox.m_QulitySprite:SetSpriteName(nil)
		oBox.m_AddSprite:SetActive(self.m_Type == define.Travel.Type.Mine)
	end
end

--endregion 游历道具

--region 游历邀请
function CTravelOtherBox.InitInviteBox(self)
	local oBox = self.m_InviteBox
	oBox.m_InviteBtn = oBox:NewUI(1, CButton)
	oBox.m_InviteLabel = oBox:NewUI(2, CLabel)
	oBox.m_InviteTweenScale = oBox.m_InviteBtn:GetComponent(classtype.TweenScale)
	oBox.m_InviteTweenScale.enabled = false
	oBox.m_InviteBtn:AddUIEvent("click", callback(self, "OnInviteBtn"))

	--请求好友邀请数据为了刷新界面的按钮
	nettravel.C2GSQueryTravelInvite()
end

function CTravelOtherBox.OnInviteBtn(self, oBtn)
	local oBox = self.m_InviteBox
	CTravelFriendInviteView:ShowView()
	IOTools.SetClientData("travelmineinvite", false)
	oBox.m_InviteLabel:SetActive(false)
end

function CTravelOtherBox.RefreshInviteMine(self)
	local oBox = self.m_InviteBox
	local bHas = g_TravelCtrl:HasMainInvite()
	local bNew = bHas and IOTools.GetClientData("travelmineinvite") == true
	local bAct = bHas or bNew
	oBox:SetActive(bAct)
	oBox.m_InviteBtn:SetActive(bAct)
	oBox.m_InviteTweenScale.enabled = false --bAct
	oBox.m_InviteLabel:SetActive(bNew)
	if bAct then
		self.m_InviteFlag = 1
	else
		self.m_InviteFlag = 0
	end
end

function CTravelOtherBox.RefreshInviteFriend(self)
	self.m_InviteFlag = 0
	self.m_InviteBox:SetActive(false)
end
--endregion 游历邀请

--region 游历寄存好友伙伴
function CTravelOtherBox.InitPartnerBox(self)
	local oBox = self.m_PartnerBox
	oBox:SetActive(false)
	oBox.m_BoderSpr = oBox:NewUI(1, CSprite)
	oBox.m_Icon = oBox:NewUI(2, CSprite)
	oBox.m_StarGrid = oBox:NewUI(3, CGrid)
	oBox.m_StarSpr = oBox:NewUI(4, CSprite)
	oBox.m_AwakeSpr = oBox:NewUI(5, CSprite)
	oBox.m_GradeLabel = oBox:NewUI(6, CLabel)
	oBox.m_TimeLabel = oBox:NewUI(7, CLabel)
	oBox.m_GetLabel = oBox:NewUI(8, CLabel)
	oBox.m_StarSpr:SetActive(false)
	oBox.m_StarGrid:Clear()
	for i = 1, 5 do
		local oSpr = oBox.m_StarSpr:Clone()
		oSpr:SetActive(true)
		oSpr:SetDepth(9+i)
		oBox.m_StarGrid:AddChild(oSpr)
	end
	oBox.m_StarGrid:Reposition()
	oBox:AddUIEvent("click", callback(self, "OnPartner"))

	oBox.m_Status = nil
	oBox.m_FrdPid = nil
end

function CTravelOtherBox.OnPartner(self, oBox)
	if oBox.m_Status == 1 then
		nettravel.C2GSAcceptFrdTravelRwd()
	elseif oBox.m_FrdPid then
		local title = "游历队伍"
		local frdobj = g_FriendCtrl:GetFriend(oBox.m_FrdPid)
		local msg = "是否查看【"..frdobj.name.."】的游历队伍"
		CTravelPartnerConfirmView:ShowView(function (oView)
			oView:RefreshView(oBox.m_Parid, 
				title, 
				msg, 
				function () 
					nettravel.C2GSGetFrdTravelInfo(oBox.m_FrdPid) 
				end)
		end)
	end
end

function CTravelOtherBox.RefreshPartnerMine(self)
	self.m_PartnerFlag = 0
	local oBox = self.m_PartnerBox
	local dData = g_TravelCtrl:GetMine2FrdParInfo()
	if not dData or not dData.parinfo then
		oBox:SetActive(false)
		return
	end
	local parinfo = dData.parinfo
	local oPartner = g_PartnerCtrl:GetPartner(parinfo.parid)
	if not oPartner then
		oBox:SetActive(false)
		return
	end
	self.m_PartnerFlag = 1
	--显示伙伴的时候不显示邀请信息
	self.m_InviteFlag = 0
	self.m_InviteBox:SetActive(false)
	IOTools.SetClientData("travelmineinvite", false)

	oBox:SetActive(true)
	oBox.m_Parid = parinfo.parid
	local icon = oPartner:GetIcon()
	oBox.m_Icon:SpriteAvatar(icon)
	local star = oPartner:GetValue("star")
	for i, oSpr in ipairs(oBox.m_StarGrid:GetChildList()) do
		if star >= i then
			oSpr:SetSpriteName("pic_chouka_dianliang")
		else
			oSpr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
	local rare = oPartner:GetValue("rare")
	local sSprite = oBox.m_BoderSpr:GetSpriteName()
	if string.startswith(sSprite, "bg_haoyoukuang_") then
		local filename = define.Partner.CardColor[rare] or "hui"
		oBox.m_BoderSpr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
	elseif string.startswith(sSprite, "bg_huobankuang_") then
		oBox.m_BoderSpr:SetSpriteName(string.format("bg_huobankuang_da%d", rare))
	end
	local awake = oPartner:GetValue("awake")
	oBox.m_AwakeSpr:SetActive(awake == 1)
	local grade = oPartner:GetValue("grade")
	oBox.m_GradeLabel:SetText(string.format("%d", grade))
	local time = dData.end_time - g_TimeCtrl:GetTimeS()
	local function countdown()
		if Utils.IsNil(oBox) then
			return 
		end
		if time >= 0 then
			oBox.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
			time = time - 1
			return true
		end
	end
	if oBox.m_Timer then
		Utils.DelTimer(oBox.m_Timer)
		oBox.m_Timer = nil
	end
	oBox.m_Timer = Utils.AddTimer(countdown, 1, 0)
	local bGet = dData.recieve_status == 1
	oBox.m_GetLabel:SetActive(bGet)
	oBox.m_TimeLabel:SetActive(not bGet)
	oBox.m_FrdPid = dData.frd_pid
	oBox.m_Status = dData.recieve_status
end

function CTravelOtherBox.RefreshPartnerFriend(self)
	self.m_PartnerFlag = 0
	self.m_PartnerBox:SetActive(false)
end
--endregion 游历寄存好友伙伴

--region 游历商人
function CTravelOtherBox.InitGameBox(self)
	local oBox = self.m_GameBox
	oBox.m_TimeLabel = oBox:NewUI(1, CLabel)
	oBox.m_BGSprite = oBox:NewUI(2, CSprite)
	oBox.m_TimeLabel:SetActive(false)
	oBox:AddUIEvent("click", callback(self, "OnGame"))
end

function CTravelOtherBox.OnGame(self, oBox)
	CTravelGameView:ShowView()
end

function CTravelOtherBox.RefreshGameMine(self)
	local bAct = g_TravelCtrl:GetTravelGameInfo()
	self.m_GameBox:SetActive(bAct)
	if bAct then
		self.m_GameFlag = 1
		self.m_GameBox.m_BGSprite:DelEffect("bordermove")
		self.m_GameBox.m_BGSprite:AddEffect("bordermove", Vector4.New(-34, 34, -34, 34))
	else
		self.m_GameFlag = 0
		g_TravelCtrl:SetTravelGameRedDot(false)
	end
end

function CTravelOtherBox.RefreshGameFriend(self)
	self.m_GameFlag = 0
	self.m_GameBox:SetActive(false)
end
--endregion 游历商人

--region 积分兑换
function CTravelOtherBox.InitExchangeBox(self)
	local oBox = self.m_ExchangeBox
	oBox.m_ExchangeBtn = oBox:NewUI(1, CButton)
	oBox.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnExchange"))
end

function CTravelOtherBox.OnExchange(self, oBtn)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSOpenShop"]) then
		netstore.C2GSOpenShop(define.Store.Page.TravelShop)
	end
end

function CTravelOtherBox.RefreshExchangeMine(self)
	self.m_ExchangeFlag = 1
	self.m_ExchangeBox:SetActive(true)
end

function CTravelOtherBox.RefreshExchangeFriend(self)
	self.m_ExchangeFlag = 0
	self.m_ExchangeBox:SetActive(false)
end
--endregion 积分兑换

return CTravelOtherBox