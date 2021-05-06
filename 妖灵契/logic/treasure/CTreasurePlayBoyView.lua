local CTreasurePlayBoyView = class("CTreasurePlayBoyView", CViewBase)

CTreasurePlayBoyView.HASCHANGE = 1
CTreasurePlayBoyView.NOTCHANGE = 0

function CTreasurePlayBoyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Treasure/TreasurePlayBoyView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter" --Shelter
	self.m_Interval = tonumber(data.globaldata.GLOBAL.playboy_boxspeed.value)
	self.m_AnimTime = tonumber(data.globaldata.GLOBAL.playboy_animtime.value)
	self.m_ResultInfo = {} --动画结束后的信息
	self.m_BoxPosList = {}
	self.m_BoxWroldPosList = {}
	self.m_BoxAnim = false --是否装箱动画
	self.m_IsFree = true
end

function CTreasurePlayBoyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TimeLabel = self:NewUI(2, CLabel)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_SpineTexture = self:NewUI(4, CSpineTexture)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CItemTipsBox)
	self.m_StartBtn = self:NewUI(7, CButton)
	self.m_CostLabel = self:NewUI(8, CLabel)
	self.m_FreeLabel = self:NewUI(9, CLabel)
	self.m_Container = self:NewUI(10, CWidget)
	self.m_ItemBGSprite = self:NewUI(11, CSprite)
	self.m_DeskGrid = self:NewUI(12, CGrid)
	self:InitContent()
end

function CTreasurePlayBoyView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ItemBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_StartBtn:AddUIEvent("click", callback(self, "OnStart"))
	self.m_SpineTexture:ShapeCommon(404, function ()
  		self.m_SpineTexture:SetAnimation(0, "idle", true)
 	end)
end

function CTreasurePlayBoyView.SetActive(self, bAct)
	CViewBase.SetActive(self, bAct)
	if bAct then
		self:CheckItemRewardListView()
	end
end

function CTreasurePlayBoyView.CheckItemRewardListView(self)
	local oView = CItemRewardListView:GetView()
	if oView then
		g_ViewCtrl:TopView(oView)
	end
end

function CTreasurePlayBoyView.OnClose(self, oBtn)
	if self.m_IsFree then
		local windowConfirmInfo = {
			msg = "你存在一次免费的抽取机会，是否退出界面",
			title = "提示",
			okCallback = function () self:CloseView() end,	
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:CloseView()
	end
end

function CTreasurePlayBoyView.InitBoxPosList(self)
	self.m_BoxPosList = {}
	self.m_BoxWroldPosList = {}
	for i,oBox in ipairs(self.m_ItemGrid:GetChildList()) do
		table.insert(self.m_BoxPosList, oBox:GetLocalPos())
		table.insert(self.m_BoxWroldPosList, oBox:GetPos())
	end
end

function CTreasurePlayBoyView.InitTime(self, createtime)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	createtime = tonumber(createtime) + 600
	self.m_LeftTime = createtime - g_TimeCtrl:GetTimeS()
	local function updatetime()
		if Utils.IsNil(self) then
			return
		end
		self.m_LeftTime = self.m_LeftTime - 1
		if self.m_LeftTime < 0 then
			local str = self:GetLeftTime(0)
			self.m_TimeLabel:SetText(str)
			self:CloseView()
		else
			local str = self:GetLeftTime(self.m_LeftTime)
			self.m_TimeLabel:SetText(str)
			return true
		end
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(updatetime, 1, 0)
end

function CTreasurePlayBoyView.GetLeftTime(self, iSec)
	local s = g_TimeCtrl:GetLeftTime(iSec)
	return s
end

function CTreasurePlayBoyView.InitInfo(self, createtime, rewardinfo, haschangepos, dialog, cost, sessionidx)
	self:InitHasChangePos(haschangepos) --要初始化现在是乱了还是没乱，1乱0否
	self:InitTime(createtime)
	self:InitRewardInfo(rewardinfo)
	self:InitDialog(dialog)
	self:InitCost(cost)
	self:InitSessionidx(sessionidx)
end

function CTreasurePlayBoyView.InitRewardInfo(self, rewardinfo)
	rewardinfo = rewardinfo or {}
	local haschangepos = self.m_HasChangePos
	if not haschangepos or haschangepos == CTreasurePlayBoyView.NOTCHANGE then
		--第一次进来
		self:InitShowInfo(rewardinfo)
		self:InitBoxPosList()
		self:ItemOnTheDesk()
	elseif haschangepos == CTreasurePlayBoyView.HASCHANGE then
		self.m_ItemBGSprite:SetActive(true)
		self.m_SpineTexture:SetActive(false)
		self.m_ResultInfo = rewardinfo
		local oBoxList = self.m_ItemGrid:GetChildList()
		if #oBoxList > 0 then --已经初始化道具就刷新(在第一次进来打开界面后)
			self:RefreshInfo(rewardinfo)
		else
			--没初始化道具就初始
			self:InitShowInfo(rewardinfo)
			self:RefreshInfo(rewardinfo)
		end
	end
end

function CTreasurePlayBoyView.ItemOnTheDesk(self)
	--移位
	self.m_ItemBGSprite:SetActive(false)
	for i,oBox in ipairs(self.m_ItemGrid:GetChildList()) do
		self.m_DeskGrid:AddChild(oBox)
	end
	self.m_DeskGrid:Reposition()
end

function CTreasurePlayBoyView.InitShowInfo(self, rewardinfo)
	local rewardList = g_TreasureCtrl:GetPlayBoyRewardList()
	self.m_ItemGrid:Clear()
	for i,v in ipairs(rewardinfo) do
		local idx = rewardinfo[i].idx
		local type = rewardinfo[i].type
		local data = rewardList[idx]
		if data then
			local oBox = self.m_ItemBox:Clone()
			oBox:SetActive(true)
			oBox.m_MaskSprite = oBox:NewUI(5, CSprite)
			oBox.m_MaskSprite:SetActive(false)
			local sid = data.sid
			local num = 0
			if sid and string.find(sid, "value") then
				local k, v = g_ItemCtrl:SplitSidAndValue(sid)
				sid = tonumber(k)
				num = tonumber(v)
			else
				num = data.amount
			end
			oBox.m_ID = v.id
			oBox.m_Idx = v.idx
			oBox.m_Type = v.type
			oBox:SetItemData(sid, num, nil, {isLocal = true})
			oBox.m_Key = i
			self.m_ItemGrid:AddChild(oBox)
		end
	end
	self.m_ItemGrid:Reposition()
end

function CTreasurePlayBoyView.RefreshInfo(self, rewardinfo)
	for i,oBox in ipairs(self.m_ItemGrid:GetChildList()) do
		for i,result in ipairs(rewardinfo) do
			if result.id == oBox.m_ID and result.idx == oBox.m_Idx and result.type == oBox.m_Type then
				local bGet = result.has_get and result.has_get == 1
				local bMaskAct = oBox.m_MaskSprite:GetActive()
				oBox.m_MaskSprite:SetActive(not bGet)
				if not self.m_BoxAnim then
					oBox.m_IconSprite:SetActive(bGet)
					if bGet and bMaskAct then
						self:CreateEffect(oBox)
					end
				end
				oBox.m_MaskSprite:AddUIEvent("click", callback(self, "OnItemBox", oBox.m_Key))
			end
		end			
	end
end

function CTreasurePlayBoyView.OnItemBox(self, key, oBox)
	if not self.m_BoxAnim and key then
		if self.m_Cost and self.m_Cost.value > g_AttrCtrl.goldcoin then
			g_NotifyCtrl:FloatMsg("您的水晶不足")
			g_SdkCtrl:ShowPayView()
		else
			netother.C2GSCallback(self.m_Sessionidx, key)
		end
	end
end

function CTreasurePlayBoyView.CreateEffect(self, oBox)
	local ref = weakref(oBox.m_IconSprite)
	local function onpkeffload(oClone, errcode)
		local oAttach = getrefobj(ref)
		if oClone and oAttach then
			local oEff = CObject.New(oClone)
			oEff:SetParent(oBox.m_IconSprite.m_Transform)
			local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
			mPanel.uiEffectDrawCallCount = 1
			local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
			oEff.m_RenderQComponent = mRenderQ
			mRenderQ.needClip = true
			mRenderQ.attachGameObject = oAttach.m_GameObject
			local function autodestroy()
				oEff:Destroy()
			end
			Utils.AddTimer(autodestroy, 1, 1)
		end
	end
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_treasure/Prefabs/treasure_smoke.prefab", onpkeffload)
end

function CTreasurePlayBoyView.InitHasChangePos(self, haschangepos)
	self.m_HasChangePos = haschangepos
end

function CTreasurePlayBoyView.InitDialog(self, dialog)
	self.m_DescLabel:SetText(dialog)
end

function CTreasurePlayBoyView.InitCost(self, cost)
	--cost.type 消耗类型暂时只有水晶
	self.m_Cost = cost
	if self.m_HasChangePos == CTreasurePlayBoyView.NOTCHANGE then
		self.m_StartBtn:SetActive(true)
		self.m_CostLabel:SetActive(false)
		self.m_FreeLabel:SetActive(false)
		self.m_IsFree = true
	elseif self.m_HasChangePos == CTreasurePlayBoyView.HASCHANGE then
		self.m_StartBtn:SetActive(false)
		local txt = ""
		if cost and cost.value > 0 then
			txt = string.format("%d", cost.value)
			self.m_CostLabel:SetText(txt)
			self.m_FreeLabel:SetActive(false)
			self.m_CostLabel:SetActive(true)
			self.m_IsFree = false
		elseif cost and cost.type ==1 then
			self.m_IsFree = false
			self.m_FreeLabel:SetActive(false)
			self.m_CostLabel:SetActive(false)
		else
			self.m_IsFree = true
			self.m_FreeLabel:SetActive(true)
			self.m_CostLabel:SetActive(false)
		end
		
	end
	
	if self.m_IsFree then
		self.m_ExtendClose = "Shelter"
	else
	 	self.m_ExtendClose = "Black"
	end
end

function CTreasurePlayBoyView.InitSessionidx(self, sessionidx)
	self.m_Sessionidx = sessionidx
end

function CTreasurePlayBoyView.OnStart(self)
	if self.m_HasChangePos == CTreasurePlayBoyView.NOTCHANGE then
		--self:BoxAnim()
		self:FlyDeskAnim()
	end
end

function CTreasurePlayBoyView.ReallyStart(self)
	self:BoxAnim()
	netother.C2GSCallback(self.m_Sessionidx, 1)
end

--物品飞桌
function CTreasurePlayBoyView.FlyDeskAnim(self)
	if self.m_FlyTimer then
		return
	end
	self.m_ItemBGSprite:SetActive(true)
	self.m_SpineTexture:SetActive(false)
	local idx = 1
	local speed = tonumber(data.globaldata.GLOBAL.playboy_flydeskspeed.value)
	local interval = tonumber(data.globaldata.GLOBAL.playboy_flydeskinterval.value)
	local function fly()
		local oDeskBox = self.m_DeskGrid:GetChild(idx)
		if oDeskBox then
			--oBox:SetParent(self.m_ItemGrid.m_Transform)
			DOTween.DOMove(oDeskBox.m_Transform, self.m_BoxWroldPosList[idx], speed)
			idx = idx + 1
			return true
		else
			--归位
			for i,oBox in ipairs(self.m_DeskGrid:GetChildList()) do
				self.m_ItemGrid:AddChild(oBox)
			end
			self.m_ItemGrid:Reposition()
			self:ReallyStart()
		end
		return false
	end
	self.m_FlyTimer = Utils.AddTimer(fly, interval, 0)
end

--物品装箱。
function CTreasurePlayBoyView.BoxAnim(self)
	self.m_BoxAnim = true
	local count = self.m_ItemGrid:GetCount()
	local from, to
	for i, oBox in ipairs(self.m_ItemGrid:GetChildList()) do
		to = oBox.m_MaskSprite:GetLocalPos()
		from = Vector3.New(to.x - 100, to.y, to.z)
		oBox.m_MaskSprite:SetLocalPos(from)
		if i == count then
			DOTween.OnComplete(DOTween.DOLocalMove(oBox.m_MaskSprite.m_Transform, to, 2), function ()
				oBox.m_IconSprite:SetActive(false)
				self:Anim()
			end)
		else
			DOTween.OnComplete(DOTween.DOLocalMove(oBox.m_MaskSprite.m_Transform, to, 2), function ()
				oBox.m_IconSprite:SetActive(false)
			end)
		end
	end
end

--宝箱打乱
function CTreasurePlayBoyView.Anim(self)
	if self.m_AnimTimer then
		Utils.DelTimer(self.m_AnimTimer)
		self.m_AnimTimer = nil
	end
	local interval = self.m_Interval
	local endtime = g_TimeCtrl:GetTimeS() + self.m_AnimTime
	local len = self.m_ItemGrid:GetCount()
	local i1, i2, o1, o2
	local temps = {}
	local function test()
		if Utils.IsNil(self) then
			self.m_AnimTimer = nil
			return
		end
		if g_TimeCtrl:GetTimeS() >= endtime then
			self:ResultPos(interval) -- 最后位置要以服务器发的为准
			return
		end
		for i=1,len do
			table.insert(temps, i)
		end
		while #temps > 0 do
			i1 = Utils.RandomInt(1, #temps)
			o1 = self.m_ItemGrid:GetChild(temps[i1])
			table.remove(temps, i1)

			i2 = Utils.RandomInt(1, #temps)
			o2 = self.m_ItemGrid:GetChild(temps[i2])
			table.remove(temps, i2)

			DOTween.DOLocalMove(o1.m_Transform, o2:GetLocalPos(), interval)
			DOTween.DOLocalMove(o2.m_Transform, o1:GetLocalPos(), interval)
		end
		return true
	end
	self.m_AnimTimer = Utils.AddTimer(test, interval+0.1, 0.1+0.1)
end

function CTreasurePlayBoyView.ResultPos(self, interval)
	local oBoxList = self.m_ItemGrid:GetChildList()
	local resultInfo = self.m_ResultInfo
	local sortList = {}
	for i1, result in ipairs(resultInfo) do
		for i2, oBox in ipairs(oBoxList) do
			if result.id == oBox.m_ID and result.idx == oBox.m_Idx and result.type == oBox.m_Type then
				oBox.m_Key = i1
				oBox.m_MaskSprite:AddUIEvent("click", callback(self, "OnItemBox", oBox.m_Key))
				table.insert(sortList, oBox)
			end
		end
	end
	for i,oBox in ipairs(sortList) do
		DOTween.DOLocalMove(oBox.m_Transform, self.m_BoxPosList[i], interval)
	end
	self.m_BoxAnim = false
end

return CTreasurePlayBoyView