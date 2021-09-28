WakanPanel = BaseClass(LuaUI)

function WakanPanel:__init(...)
	self:RegistUI()
	self:Config()
end

function WakanPanel:__delete()
	self.descTipsUI = nil

	self.hasDestroy = true
	if self.selectPanel then
		self.selectPanel:Destroy()
	end
	self.selectPanel = nil
	self:DestroyCreate()
	self:RemoveEvent()
end

function WakanPanel:Config()
	
end

function WakanPanel:RegistUI()
	self.ui = UIPackage.CreateObject("Wakan","WakanPanel");

	self.n61 = self.ui:GetChild("n61")
	self.n58 = self.ui:GetChild("n58")
	self.n59 = self.ui:GetChild("n59")
	self.n63 = self.ui:GetChild("n63")
	self.VerLine = self.ui:GetChild("VerLine")
	self.wakanBtn = self.ui:GetChild("wakanBtn")
	self.propItem1 = self.ui:GetChild("propItem1")
	self.propItem3 = self.ui:GetChild("propItem3")
	self.propItem2 = self.ui:GetChild("propItem2")
	self.infoMore = self.ui:GetChild("infoMore")
	self.partName = self.ui:GetChild("partName")
	self.progessTxt = self.ui:GetChild("progessTxt")
	self.info = self.ui:GetChild("info")
	self.progess = self.ui:GetChild("progess")
	self.infoLable = self.ui:GetChild("infoLable")
	self.costLable = self.ui:GetChild("costLable")
	self.cost = self.ui:GetChild("cost")
	self.radio = self.ui:GetChild("radio")
	self.selectInfo = self.ui:GetChild("selectInfo")
	self.costIcon = self.ui:GetChild("costIcon")
	self.awakeBtn = self.ui:GetChild("awakeBtn")
	self.n73 = self.ui:GetChild("n73")
	self.n67 = self.ui:GetChild("n67")
	self.proListBg = self.ui:GetChild("proListBg")
	self.curLevelName = self.ui:GetChild("curLevelName")
	self.n80 = self.ui:GetChild("n80")
	self.proListBg_2 = self.ui:GetChild("proListBg")
	self.nextLevelName = self.ui:GetChild("nextLevelName")
	self.items = self.ui:GetChild("items")
	self.curB1 = self.ui:GetChild("curB1")
	self.curB2 = self.ui:GetChild("curB2")
	self.nextB1 = self.ui:GetChild("nextB1")
	self.nextB2 = self.ui:GetChild("nextB2")
	self.selectPanel = self.ui:GetChild("selectPanel")
	self.successEft = self.ui:GetChild("successEft")
	self.bgImg = self.ui:GetChild("bgImg")
	self.tipsBtn = self.ui:GetChild("tipsBtn")
	self.progessPre = self.ui:GetChild("progessPre") 
	self.yimanMark = self.ui:GetChild("yimanMark") 

	self.yimanMark.visible = false
	self.progessPre.value = 0

	self.creatLists = {}
	self.isDataSync = false

	self.longTouchFrame = "WakanPanel_LongTouchFrame"
	self.longTouchLeastTime = 0.6 --最小长按时间
	self.isLongTouchChecking = false
	self.touchDownTime = 0

	self.lastQuickWakanTime = 0
	self.maxQuickInternal = 1
	self.minQuickInternal = 0.02
	self.curQuickInternal = 1

	self.failEftId = "4103"
	self.successEftId = "4104"

	self.curProgess = 0
	self.curMaxProgess = 0

	self.costItemIds = WakanConst.WakanCostItemIds
	self.costIcon.url = GoodsVo.GetIconUrl(GoodsVo.GoodType.gold)

	self:ToCreate()
	self:AddEvent()

	local career = SceneModel:GetInstance():GetMainPlayer().career
	if career == 1 then
		self.bgImg.url = "Icon/zhuling/jianying_zhanshi"
	elseif career == 2 then
		self.bgImg.url = "Icon/zhuling/jianying_fashi"
	elseif career == 3 then
		self.bgImg.url = "Icon/zhuling/jianying_anwu"
	end

	self.initOK = true
	self.hasDestroy = false
	self.showingTarget = nil

	self.descTipsUI = nil
end

function WakanPanel:ToCreate()
	self.items = WakanSelectItems.Create(self.items)
	self:AddToCreateList(self.items)

	self.propItem1 = WakanCostItem.Create(self.propItem1)
	self:AddToCreateList(self.propItem1)
	self.propItem2 = WakanCostItem.Create(self.propItem2)
	self:AddToCreateList(self.propItem2)
	self.propItem3 = WakanCostItem.Create(self.propItem3)
	self:AddToCreateList(self.propItem3)

	self.curB1 = WakanProperty.Create(self.curB1)
	self:AddToCreateList(self.curB1)
	self.curB2 = WakanProperty.Create(self.curB2)
	self:AddToCreateList(self.curB2)
	self.nextB1 = WakanProperty.Create(self.nextB1)
	self:AddToCreateList(self.nextB1)
	self.nextB2 = WakanProperty.Create(self.nextB2)
	self:AddToCreateList(self.nextB2)

	self.radio = CustomRadio.Create(self.radio)
	self.radio:SetCallBack(function() self:AutoFillCost() end, function() end)
	self:AddToCreateList(self.radio)

	self.selectPanel = WakanCostItemSelectPanel.Create(self.selectPanel)
	self:HideSelectPanel()
	self:AddToCreateList(self.selectPanel)
end

function WakanPanel:AddToCreateList(gui)
	table.insert(self.creatLists, gui)
end

function WakanPanel:DestroyCreate()
	destroyUIList(self.creatLists)
	self.creatLists = nil
end

function WakanPanel:AddEvent()
	self.tipsBtn.onClick:Add(function()
		if self.descTipsUI == nil then
			self.descTipsUI =  DescPanel.New()
		end
		self.descTipsUI:SetContent(2)
		UIMgr.ShowPopup(self.descTipsUI, false, 0, 0, function()
			if self.descTipsUI then
				UIMgr.HidePopup(self.descTipsUI.ui)
				self.descTipsUI = nil
			end
		end)
	end, self)

	self.wakanBtn.onClick:Add(self.WakanBtnClickHandler, self)
	self.awakeBtn.onClick:Add(self.AwakeBtnClickHandler, self)

	self.handler1 = WakanModel:GetInstance():AddEventListener(WakanConst.SelectWakanItem, function ( data ) self:ChangeViewHandler(data) end)
	self.handler2 = WakanModel:GetInstance():AddEventListener(WakanConst.WakanDataUpdate, function ( data ) self:RefreshPanel(data) end)
	self.handler4 = WakanModel:GetInstance():AddEventListener(WakanConst.WakanDataSync, function ( data ) self:DefaultSet(data) end)

	self.handler5 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function () self:BagUpdate() end)
end

function WakanPanel:RemoveEvent()
	self.wakanBtn.onClick:Remove(self.WakanBtnClickHandler, self)
	self.awakeBtn.onClick:Remove(self.AwakeBtnClickHandler, self)

	self.wakanBtn.onTouchBegin:Remove(self.OnWakanBtnDown, self)
	self.wakanBtn.onTouchEnd:Remove(self.OnWakanBtnUp, self)

	WakanModel:GetInstance():RemoveEventListener(self.handler1)
	WakanModel:GetInstance():RemoveEventListener(self.handler2)
	WakanModel:GetInstance():RemoveEventListener(self.handler4)

	GlobalDispatcher:RemoveEventListener(self.handler5)

	RenderMgr.Remove(self.longTouchFrame)
end

function WakanPanel:PlayerFailEft()
	EffectMgr.AddToUI(self.failEftId, self.successEft, 0.9)
end

function WakanPanel:PlayerSuccessEft()
	EffectMgr.AddToUI(self.successEftId, self.successEft, 0.9)
end

function WakanPanel:BagUpdate()
	if self.radio:IsSelect() then
		self:AutoFillCost()
	end
end

function WakanPanel:ResetPage()
	self:ResetCost()
end

function WakanPanel:ResetCost(playEft, isCrit, needReset)
	self.yimanMark.visible = false
	self.progessPre.value = 0
	self.info.text = "0.0%"

	self:HideSelectPanel()

	local flyTargetPos = self.ui:LocalToGlobal(Vector2.New(self.progess.x + self.progess.width*0.5, self.progess.y))
	self.propItem1:Reset(playEft, flyTargetPos, true)
	self.propItem2:Reset(playEft, flyTargetPos, true)
	self.propItem3:Reset(playEft, flyTargetPos, true)
	if playEft then
		DelayCall(function() 
			if isCrit then
				self:PlayerSuccessEft()
			else
				self:PlayerFailEft()
			end
		end, 0.6)

		DelayCall(function() 
			if self.hasDestroy then return end
			if self.radio:IsSelect() then
				self:AutoFillCost()
			end
		end, 0.7)
	else
		self.radio:Reset()
	end
end

function WakanPanel:AutoFillCost()
	local checkIds = WakanConst.WakanCostItemIds
	local showIds = {}
	for i = 1, #checkIds do
		if PkgModel:GetInstance():GetTotalByBid(checkIds[i]) > 0 then
			local vo = {}
			vo.id = checkIds[i]
			table.insert(showIds, vo)
		end
	end
	SortTableByKey(showIds, "id", true)

	self.propItem1:Reset()
	self.propItem2:Reset()
	self.propItem3:Reset()

	local curFillIndex = 1
	for i = 1, #showIds do
		local typeCount = PkgModel:GetInstance():GetTotalByBid(showIds[i].id)
		if curFillIndex > 3 then
			break
		end
		for j = 1, typeCount do
			if curFillIndex <= 3 then 
				self["propItem"..curFillIndex]:AutoSet(showIds[i].id)
				curFillIndex = curFillIndex + 1
			end
			if curFillIndex > 3 then
				break
			end
		end
	end

	DelayCall(function()  
		self:UpdateCrit()
	end, 0.3)
	self:HideSelectPanel()
end

function WakanPanel:CheckExchange(checkSource)
	for i = 1, 3 do
		if self["propItem"..i] ~= checkSource and PkgModel:GetInstance():GetTotalByBid(checkSource.itemId) == 1 and 
			checkSource.itemId == self["propItem"..i].itemId then
			self["propItem"..i]:AutoSet(checkSource.preItemId)
		end
	end
end

function WakanPanel:ShowSelectPanel(target, callBack)
	if self.showingTarget and self.showingTarget == target then
		self:HideSelectPanel()
	else
		self.showingTarget = target
		self.selectPanel:SetXY(target.ui.x - (self.selectPanel.ui.width - target.ui.width)*0.5, target.ui.y - self.selectPanel.ui.height)
		self.selectPanel:ShowSelect(function(data) 
			self.showingTarget = nil
			callBack(data)
			self:UpdateCrit()
		end, self["propItem1"], self["propItem2"], self["propItem3"])
	end
end

function WakanPanel:HideSelectPanel()
	self.showingTarget = nil
	self.selectPanel:SetVisible(false)
end

function WakanPanel:UpdateCrit()
	local add = 0
	for i = 1, 3 do
		if self["propItem"..i].itemId ~= 0 then
			local cfg = GetCfgData( "item" ):Get(self["propItem"..i].itemId)
			if cfg then
				add = add + cfg.effectValue
			end
		end
	end
	self.info.text = WakanModel:GetInstance():GetWakanCrit(add, self.curProgess, self.curMaxProgess).."%"
	self.progessPre.value = ((add + self.curProgess)/self.curMaxProgess)*100
	if self.hasDestroy then return end
	if add + self.curProgess >= self.curMaxProgess then
		self.yimanMark.visible = true
	else
		self.yimanMark.visible = false
	end
end

function WakanPanel:AwakeBtnClickHandler()
	local awakePanel = AwakePanel.New()
	UIMgr.ShowCenterPopup(awakePanel)
end

function WakanPanel:WakanBtnClickHandler()
	local msg = {}
	msg.posId = self.curPart
	msg.itemIds = {}
	for i = 1, 3 do
		if self["propItem"..i].itemId ~= 0 then
			table.insert(msg.itemIds, self["propItem"..i].itemId)
		end
	end
	if #msg.itemIds < 1 then
		Message:GetInstance():TipsMsg("请放入灵石")
		return
	end
	WakanModel:GetInstance():DispatchEvent(WakanConst.ReqTakeWakan, msg)
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

--按下
function WakanPanel:OnWakanBtnDown(context)	
	self.isLongTouchChecking = true
	self.touchDownTime = Time.time
	RenderMgr.Add(function() self:LongTouchFrame() end, self.longTouchFrame)
end

--弹起
function WakanPanel:OnWakanBtnUp(context)	
	self.isLongTouchChecking = false
	self.isLongTouch = false
	RenderMgr.Remove(self.longTouchFrame)
end

function WakanPanel:LongTouchFrame()
	--长按检测
	if self.isLongTouchChecking and Time.time - self.touchDownTime > self.longTouchLeastTime then 
		self.isLongTouch = true
		self.isLongTouchChecking = false
		self.curQuickInternal = self.maxQuickInternal
		self.lastQuickWakanTime = Time.time
	end
	if self.isLongTouch then
		if Time.time - self.lastQuickWakanTime > self.curQuickInternal then
			self:WakanBtnClickHandler()
			self.lastQuickWakanTime = Time.time
		end
		
		if self.curQuickInternal > self.minQuickInternal then
			self.curQuickInternal = self.curQuickInternal - Time.deltaTime
		end
		if self.curQuickInternal < self.minQuickInternal then
			self.curQuickInternal = self.minQuickInternal
		end
	end
end

function WakanPanel:ReqUpdate()
	if not self.isDataSync then
		WakanModel:GetInstance():DispatchEvent(WakanConst.ReqWakanList)
	else
		self:DefaultSet()
	end
end

function WakanPanel:DefaultSet()
	self.isDataSync = true --第一次刷新为服务器数据同步
	self.items:InitItems()
	self:ResetPage()
end

--注灵更新
function WakanPanel:RefreshPanel(data)
	local level = WakanModel:GetInstance():GetPartWakanInfo(self.curPart)[2]
	self.level = level
	self:UpdateView(data)
end

--列表选择更新
function WakanPanel:ChangeViewHandler(data)
	self.curPart = data.part
	self.level = data.level

	self:UpdateView()
end

function WakanPanel:UpdateView(data)
	local playEft = nil
	local isCrit = nil
	if data then
		playEft = data[1]
		isCrit = data[2]
	end
	self:ResetCost(playEft, isCrit, not self.radio:IsSelect())
	if not self.initOK then return end
	local part = self.curPart
	local level = self.level
	local nextLevel = self.level + 1
	local preData = WakanModel:GetInstance():GetWakanDataByLevel(level - 1)
	local curData = WakanModel:GetInstance():GetWakanDataByLevel(level)
	local nextLevelData = WakanModel:GetInstance():GetWakanDataByLevel(nextLevel)
	local isMaxLevel = nextLevelData == nil and true or false
	local partName = WakanModel:GetInstance():GetPartName(part)

	self.partName.text = WakanConst.WakanTypeName[part]

	self.curB1:SetVisible(false)
	self.curB2:SetVisible(false)
	self.nextB1:SetVisible(false)
	self.nextB2:SetVisible(false)
	
	if isMaxLevel then
		self.progess.value = 100
		self.progess.max = 100
		if curData then
			self.progessTxt.text = curData.needMana.."/"..curData.needMana
			self.curProgess = curData.needMana
			self.curMaxProgess = curData.needMana
			self.curLevelName.text = curData.des
			--self.curLevelName.text = curData.des
		end

		local curAttrInfo = WakanModel:GetInstance():GetAttrsAddByLevel_Part(level, part)
		if curAttrInfo then
			for i = 1, #curAttrInfo do
				if i == 1 then
					self["curB"..i].line.visible = false
				end

				self["curB"..i]:SetVisible(true)
				self["curB"..i].value1.text = curAttrInfo[i][1]
				self["curB"..i].value3.text = "+"..curAttrInfo[i][2]

				self["nextB"..i]:SetVisible(true)
				self["nextB"..i].value1.text = curAttrInfo[i][1]
				self["nextB"..i].value3.text = "+0"
			end
		end

		self.nextLevelName.text = "----"

		self.cost.text = "----"

	else
		local levelProgess = WakanModel:GetInstance():GetWakanValueByPart(part)
		local levelProgessMax = nextLevelData.needMana

		self.progessTxt.text = levelProgess.."/"..levelProgessMax
		self.progess.value = (levelProgess/levelProgessMax)*100

		self.curProgess = levelProgess
		self.curMaxProgess = levelProgessMax
		if curData then
			self.curLevelName.text = curData.des
		end
		
		local curAttrInfo = WakanModel:GetInstance():GetAttrsAddByLevel_Part(level, part)
		if curAttrInfo then
			for i = 1, #curAttrInfo do
				if i == 1 then
					self["curB"..i].line.visible = false
				end

				self["curB"..i]:SetVisible(true)
				self["curB"..i].value1.text = curAttrInfo[i][1]
				self["curB"..i].value3.text = "+"..curAttrInfo[i][2]
			end
		end

		self.nextLevelName.text = nextLevelData.des
		local nextAttrInfo = WakanModel:GetInstance():GetAttrsAddByLevel_Part(nextLevel, part)
		if nextAttrInfo then
			for i = 1, #nextAttrInfo do
				if i == 1 then
					self["nextB"..i].line.visible = false
				end
				
				self["nextB"..i]:SetVisible(true)
				self["nextB"..i].value1.text = nextAttrInfo[i][1]
				self["nextB"..i].value3.text = "+"..nextAttrInfo[i][2]
			end
		end

		self.cost.text = nextLevelData.expGold
	end

	self:RefreshBtn()
end

function WakanPanel:RefreshBtn()
	local model = WakanModel:GetInstance()
	local bEnough, needLev, isMax = model:IsRoleLevelEnough(self.level or 1)
	if isMax then
		self.wakanBtn.grayed = true
		self.wakanBtn.touchable = false
		self.wakanBtn.text = "已满级"
	else
		if bEnough then
			self.wakanBtn.grayed = false
			self.wakanBtn.touchable = true
			self.wakanBtn.text = "注灵"
		else
			self.wakanBtn.grayed = true
			self.wakanBtn.touchable = false
			self.wakanBtn.text = StringFormat("{0}级可注灵", needLev)
		end
	end
end