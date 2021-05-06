local CTreasureNormalView = class("CTreasureNormalView", CViewBase)

CTreasureNormalView.Poiner = {
		Ready = 1, 		--指针准备
		Rotate = 2,		--指针旋转
		SubSpeed = 3,	--指针减速
		Stop 	= 4,	--指针停止
}
CTreasureNormalView.Angles = {
		[1] = 360,
		[2] = 315,
		[3] = 270,
		[4] = 225,
		[5] = 180,
		[6] = 135,
		[7] = 90,
		[8] = 45,
}

function CTreasureNormalView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasureNormalView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Shelter"
	self.m_GroupName = "main"

	self.m_Poiner = CTreasureNormalView.Poiner.Ready
	self.m_Result = nil
	self.m_Type = nil --1是常规，2是npc
	self.m_Full = nil --true是保底，flase是常规

	g_NetCtrl:SetCacheProto("treasure", true)
	g_NetCtrl:ClearCacheProto("treasure", true)	
end

function CTreasureNormalView.OnCreateView(self)
	self.m_ZiSeTexture = self:NewUI(1, CTexture)
	self.m_JinSeTexture = self:NewUI(2, CTexture)
	self.m_ZiSeBtn = self:NewUI(3, CButton)
	self.m_JinSeBtn = self:NewUI(4, CButton) 
	self.m_PoinerSprite = self:NewUI(5, CSprite)
	self.m_GrooveGrid = self:NewUI(6, CGrid)
	self.m_RewardTable = self:NewUI(7, CTable)
	self.m_DescLabel = self:NewUI(8, CLabel)
	self.m_StarEffNode = self:NewUI(9, CWidget)
	self.m_LightEffNode = self:NewUI(10, CWidget)
	self.m_BaoEffNode = self:NewUI(11, CWidget)
	self.m_RewardPanel = self:NewUI(12, CPanel)
	self:InitContent()
end

function CTreasureNormalView.InitContent(self)
	self.m_StarEffNode:SetActive(false)
	self.m_LightEffNode:SetActive(false)
	self.m_BaoEffNode:SetActive(false)

	self:InitEffect("Effect/UI/ui_eff_1155/Prefabs/ui_ctg_1155_xingxing.prefab", self.m_StarEffNode)
	self:InitEffect("Effect/UI/ui_eff_1155/Prefabs/ui_ctg_1155_guang.prefab", self.m_LightEffNode)
	self:InitEffect("Effect/UI/ui_eff_1155/Prefabs/ui_eff_1155_bao.prefab", self.m_BaoEffNode)

	self.m_ZiSeBtn:AddUIEvent("click", callback(self, "OnOperateBtn"))
	self.m_JinSeBtn:AddUIEvent("click", callback(self, "OnOperateBtn"))

	self.m_GrooveGrid:InitChild(function (obj, idx)
			local oBox = CBox.New(obj)
			oBox.m_SelectSprite = oBox:NewUI(1, CSprite)
			oBox.m_SelectSprite:SetActive(false)
			return oBox
		end)

	self.m_RewardTable:InitChild(function (obj, idx)
			local oBox = CItemTipsBox.New(obj)
			return oBox
		end)
end

function CTreasureNormalView.InitEffect(self, sPath, oNode, oAttach)
	local ref = weakref(self)
	local function onpkeffload(oClone, errcode)
		local oAttach = getrefobj(ref)
		if oClone then
			local oEff = CObject.New(oClone)
			oEff:SetParent(oNode.m_Transform)
			local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
			mPanel.uiEffectDrawCallCount = 1
			local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
			oEff.m_RenderQComponent = mRenderQ
			mRenderQ.needClip = true
			if oAttach then
				mRenderQ.attachGameObject = oAttach.m_GameObject
			end
		end
	end
	g_ResCtrl:LoadCloneAsync(sPath, onpkeffload)
end

function CTreasureNormalView.InitRewardTable(self, rewardinfo)
	local rewardList = g_TreasureCtrl:GetProviewRewardList()
	for i, oBox in ipairs(self.m_RewardTable:GetChildList()) do
		local idx = rewardinfo[i].idx
		local type = rewardinfo[i].type
		oBox.m_Idx = idx
		oBox.m_Type = type
		if type == 2 then
			--oBox.m_IconSprite:SpriteAvatar(data.treasuredata.EVENTTIPS[idx].spirte)
			local sprite = ""
			if oBox.m_Idx == 1 then
				sprite = "pic_tanwan"
			elseif oBox.m_Idx == 2 then
				sprite = "pic_caiquan"
			end
			oBox.m_IconSprite:SetSpriteName(sprite)
			oBox.m_CountLabel:SetActive(false)
			local dData = data.treasuredata.EVENTTIPS[idx]
			local tExtend = {
				atlas = "Treasure",
				spritename = sprite,
				name = dData.name,
				desc = dData.desc,
			}
			oBox:AddUIEvent("click", callback(self, "ShowEventTips", 1, tExtend))
		else
			local data = rewardList[idx]
			if data then
				oBox:SetItemData(data.sid, data.num, nil, {isLocal = true})
				oBox.m_QualitySprite:SetActive(false)
				oBox.m_IconSprite:SetSize(82, 82)
				local oItem = CItem.NewBySid(data.sid)
				--重新注册响应
				local tExtend = {
					itemshape = oItem:GetValue("icon"),
					name = data.name,
					desc = data.desc,
				}
				oBox:AddUIEvent("click", callback(self, "ShowEventTips", 0, tExtend))
			end
		end
	end
end

function CTreasureNormalView.ShowEventTips(self, iType, tExtend, obj)
	if self.m_LightEffNode:GetActive() then
		return
	end
	if iType == 0 then
		g_WindowTipCtrl:SetPreviewItemWindow(tExtend,
			{widget = obj, side = enum.UIAnchor.Side.Center ,offset = Vector2.New( -10, 0)})
	elseif iType == 1 then
		g_WindowTipCtrl:SetPreviewItemWindow(tExtend,
			{widget = obj, side = enum.UIAnchor.Side.Center ,offset = Vector2.New( -10, 0)})
	end
end

function CTreasureNormalView.SetSessionidx(self, sessionidx)
	self.m_Sessionidx = sessionidx
end

function CTreasureNormalView.GetSessionidx(self)
	return self.m_Sessionidx
end

function CTreasureNormalView.SetGroove(self, value)
	value = value % 5
	self.m_Full = value == 0 
	if self.m_Full then
		value = 5
	end
	self.m_JinSeTexture:SetActive(self.m_Full)
	self.m_ZiSeTexture:SetActive(not self.m_Full)
	for i=1,value do
		local oBox = self.m_GrooveGrid:GetChild(i)
		oBox.m_SelectSprite:SetActive(true)
		if i == value then
			self.m_BaoEffNode:SetParent(oBox.m_Transform)
			self.m_BaoEffNode:SetLocalPos(Vector3.zero)
			self.m_BaoEffNode:SetActive(true)
		end
	end
	self:RefreshDesc()
end

function CTreasureNormalView.RefreshDesc(self)
	local sDesc = ""
	if self.m_Poiner == CTreasureNormalView.Poiner.Ready then
		if self.m_Full then
			sDesc = table.randomvalue(data.treasuredata.BAODI)
		else
			sDesc = table.randomvalue(data.treasuredata.CHANGGUI)
		end
	elseif self.m_Poiner == CTreasureNormalView.Poiner.Rotate then
		sDesc = table.randomvalue(data.treasuredata.MID)
	elseif self.m_Poiner == CTreasureNormalView.Poiner.Stop then
		sDesc = table.randomvalue(data.treasuredata.STOP)
	end
	self.m_DescLabel:SetText(sDesc)
end

function CTreasureNormalView.SetTreasureResult(self, idx, iType)
	self.m_Result = idx
	self.m_Type = iType--1是常规，2是npc
	self.m_ZiSeBtn:SetEnabled(false)
	self.m_JinSeBtn:SetEnabled(false)
	self.m_ZiSeBtn:SetGrey(true)
	self.m_JinSeBtn:SetGrey(true)
	self.m_Poiner = CTreasureNormalView.Poiner.SubSpeed
end

function CTreasureNormalView.GetTreasureResult(self)
	return self.m_Result, self.m_Type
end

function CTreasureNormalView.OnOperateBtn(self, oBtn)
	local iReady = CTreasureNormalView.Poiner.Ready
	local iRotate = CTreasureNormalView.Poiner.Rotate
	local iPoiner = self.m_Poiner
	self.m_StarEffNode:SetActive(true)
	if iPoiner == iReady then
		self.m_Poiner = iRotate
		self.m_ZiSeBtn:SetText("停止")
		self.m_JinSeBtn:SetText("停止")
		self:PoinerRotate()
		self:WaitAction()
		self:RefreshDesc()
	elseif iPoiner == iRotate then
		self:PoinerSubSpeed()
	end
end

function CTreasureNormalView.PoinerSubSpeed(self)
	local sessionidx = self:GetSessionidx()
	netother.C2GSCallback(sessionidx, 1)
end

function CTreasureNormalView.WaitAction(self)
	--最长10秒后执行self:PoinerSubSpeed()
	Utils.AddTimer(callback(self,"PoinerSubSpeed"), 5, 5)
end

function CTreasureNormalView.PoinerRotate(self)
	if self.m_PoinerTimer then
		Utils.DelTimer(self.m_PoinerTimer)
		self.m_PoinerTimer = nil
	end
	local angle = 0
	local interval = 20
	local count = 0
	local bStop = false
	local function rotate()
		if Utils.IsNil(self) then
			self.m_PoinerTimer = nil
			return
		end
		self.m_PoinerSprite:SetLocalRotation(Quaternion.Euler(0,0,angle))
		angle = angle - interval
		if angle < 0 then
			angle = 360 + angle --转换成 [0,360]
		end
		if self.m_Poiner == CTreasureNormalView.Poiner.SubSpeed then
			interval = math.max(10, interval - 0.1)
			count = count + 1
			if count % 60 == 0 then
				bStop = true
			end
			if bStop then
				local result, oBox = self:GetRewardItem()
				angle = math.floor(angle)
				if oBox and result and angle + 3 >= result and angle - 3 <= result then
					self.m_PoinerSprite:SetLocalRotation(Quaternion.Euler(0,0,result))
					self.m_Poiner = CTreasureNormalView.Poiner.Stop
					self:RefreshDesc()
					self:AddPlayBoy()
					self:AddHorseRace()
					self:DelayClose()
					self.m_RewardPanel:SetSortOrder(2)
					self.m_StarEffNode:SetActive(false)
					self.m_LightEffNode:SetParent(oBox.m_Transform)
					self.m_LightEffNode:SetLocalPos(Vector3.zero)
					self.m_LightEffNode:SetActive(true)
					return false
				end
			end
		end
		return true
	end
	self.m_PoinerTimer = Utils.AddTimer(rotate, 0, 0)
end

function CTreasureNormalView.DelayClose(self)
	CItemTipsMainView:CloseView()
	local function delay()
		if self.m_Type == 1 then
			self:OpenTreasureRewardView()
			local itemlist = g_ItemCtrl:GetItemIDListBySid(10024)
			local itemid = itemlist[1]
			if itemid then
				local oItem = g_ItemCtrl:GetItem(itemid)
				table.insert(g_ItemCtrl.m_QuickUseIdCache, itemid)
				g_ItemCtrl:LocalShowQuickUse()
				--CItemQuickUseView:ShowView(function(oView)
				--	oView:SetItem(oItem)
				--end)
			end
		elseif self.m_Type == 2 then
			self:ClickNpc()
		end
		self:OnClose()
	end
	Utils.AddTimer(delay, 2, 2)
end

function CTreasureNormalView.CloseView(self)
	g_NetCtrl:SetCacheProto("treasure", false)
	g_NetCtrl:ClearCacheProto("treasure", true)	
	CViewBase.CloseView(self)
end

function CTreasureNormalView.GetRewardItem(self)
	local angleIdx, oItem = 1
	local resultIdx, iType = self:GetTreasureResult()
	for i,oBox in ipairs(self.m_RewardTable:GetChildList()) do
		if oBox.m_Idx == resultIdx and oBox.m_Type == iType then
			angleIdx = i
			oItem = oBox
			break
		end
	end
	local angle = CTreasureNormalView.Angles[angleIdx]
	return angle, oItem
end

function CTreasureNormalView.SetPlayBoy(self, npcinfo)
	self.m_PlayBoy = npcinfo
end

function CTreasureNormalView.AddPlayBoy(self)
	if self.m_PlayBoy  then
		g_MapCtrl:AddDynamicNpc(self.m_PlayBoy)
	end
end

function CTreasureNormalView.ClickNpc(self)
	if self.m_PlayBoy and self.m_PlayBoy.npcid then
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClickNpc"]) then
			netnpc.C2GSClickNpc(self.m_PlayBoy.npcid)
		end
	end
end

function CTreasureNormalView.SetTreasureReward(self, func)
	self.m_CBFun = func
end

function CTreasureNormalView.OpenTreasureRewardView(self)
	if self.m_CBFun then
		self.m_CBFun()
	end
end

function CTreasureNormalView.SetHorseRace(self, horse_race)
	self.m_HorseRace = horse_race
end

function CTreasureNormalView.AddHorseRace(self)
	nethuodong.C2GSFinishGetReward("treasure")
	if self.m_HorseRace then
		g_ChatCtrl:AddMsg(self.m_HorseRace)
	end
end

return CTreasureNormalView