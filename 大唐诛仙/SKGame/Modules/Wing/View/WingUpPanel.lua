WingUpPanel = BaseClass(CommonBackGround)

function WingUpPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Wing","WingUpPanel");

	self.huaBg = self.ui:GetChild("huaBg")
	self.role3D = self.ui:GetChild("role3D")
	self.touch = self.ui:GetChild("touch")
	self.name = self.ui:GetChild("name")
	self.power = self.ui:GetChild("power")
	self.progess = self.ui:GetChild("progess")
	self.levelInfo = self.ui:GetChild("levelInfo")
	self.progessLabel = self.ui:GetChild("progessLabel")
	self.fds221 = self.ui:GetChild("fds221")
	self.vxcw23 = self.ui:GetChild("vxcw23")
	self.dsa2112 = self.ui:GetChild("dsa2112")
	self.listBg = self.ui:GetChild("listBg")
	self.list = self.ui:GetChild("list")
	self.be32 = self.ui:GetChild("be32")
	self.fsq = self.ui:GetChild("fsq")
	self.listBg_2 = self.ui:GetChild("listBg")
	self.cost1 = self.ui:GetChild("cost1")
	self.cost2 = self.ui:GetChild("cost2")
	self.cost3 = self.ui:GetChild("cost3")
	self.cost4 = self.ui:GetChild("cost4")   --===============
	self.textYuling = self.ui:GetChild("textYuling")
	self.upBtn = self.ui:GetChild("upBtn")
	self.returnBtn = self.ui:GetChild("returnBtn")
	self.chooseBtn = self.ui:GetChild("chooseBtn")
	self.successEft = self.ui:GetChild("successEft")

	self.starts = Starts.New()
	self.starts:SetXY(self.levelInfo.x + 110, self.levelInfo.y - 5)
	self.ui:AddChild(self.starts.ui)

	self.progess = CustomProgess.Create(self.progess)

	self.cost1 = WingCostPropItem.Create(self.cost1)
	self.cost1:SetData(WingModel.CostProps[1])
	self.cost2 = WingCostPropItem.Create(self.cost2)
	self.cost2:SetData(WingModel.CostProps[2])
	self.cost3 = WingCostPropItem.Create(self.cost3)
	self.cost3:SetData(WingModel.CostProps[3])
	self.cost4 = WingCostPropItem.Create(self.cost4)
	self.cost4:SetData(WingModel.CostProps[4])

	self.ui.x = 130
	self.ui.y = 120

	self.data = nil
	self.touchId = -1
	self.lasttouchX = 0

	self.curSelectCost = -1

	self.isYLBtn = false
	self.chooseBtn:GetChild("chooseIcon").visible = false
	--self:SetYLData()

	self.isShowing = false
	self.isMax = false
	self.showLost = false

	self.curGrade = nil
	self.isDestroy = false
	self.isUpGrade = false
	self.isPlayingUpEft = false
	self.upEft = "4614"

	self.flyStarIndex = nil
	self.flyDuration = nil
	self.progessReduceSection = nil
	self.flyTargetPos = nil
	self.playProgessCur = nil
	self.playProgessMax = nil

	self:Config()
	self:AddEvent()

	self.cost1:Select()
end

--配置
function WingUpPanel:Config()
	self.id = "WingUpPanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="yy00", res1="yy01", id="0", red=true},
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("羽  翼")
		end
		self:SetTabarTips(id, false)
	end
end

function WingUpPanel:SetYLData()
	local totalWingValue = WingModel:GetInstance().totalWingValue
	self.textYuling.text = StringFormat("(当前拥有羽灵：{0})", totalWingValue)
	if totalWingValue <= 0 then
		self.upBtn.grayed = true
		self.upBtn.touchable = false
	else
		self.upBtn.grayed = false
		self.upBtn.touchable = true
	end
	local data = WingModel:GetInstance():GetWingDynamicData(self.data.wingId)
	if data.star <= 0 and data.wingValue <= 0 then
		self.returnBtn.enabled = false
	else
		self.returnBtn.enabled = true
	end
end

function WingUpPanel:AddEvent()
	self.touch.onTouchBegin:Add(WingUpPanel.RotationwingModel,self) --旋转模型

	longPress(self.upBtn, function ()
		self:OnUpBtnClickHandler()
	end, 1, "WingUpPanel.pressRender", 0.2)

	self.upBtn.onTouchBegin:Add(function ()
		self:OnUpBtnClickHandler()
	end)
	self.chooseBtn.onClick:Add(function()
		self:OnClickChooseBtn()
	end)
	self.returnBtn.onClick:Add(function()
		local str = StringFormat("只能返还消耗的80%羽灵，确定返还？\n\n[color=#ff2c2c](请注意：返还羽灵后星级将降为0)[/color]")
		UIMgr.Win_Confirm("温馨提示", str, "确认", "取消", function()
			WingController:GetInstance():C_UnEvolve(self.data.wingId)
		end)
	end)
	self.selectCostHandler = WingModel:GetInstance():AddEventListener(WingConst.SelectWingCostItem, function (data) self:OnSelectCostHandler(data) end)
	self.updateHandler = WingModel:GetInstance():AddEventListener(WingConst.DataUpdateOk, function () self:Update(true) end)
	self.closeCallback = function ()
		if self.wingModel then
			destroyImmediate(self.wingModel) 
		end
		
		if not NPCDialogController:GetInstance():NPCDialogPanelIsAlive() then
			PlayerInfoController:GetInstance():Open(2)   --关闭羽化界面 打开羽翼界面
		end
	end
end

function WingUpPanel:RemoveEvent()
	self.touch.onTouchBegin:Clear() --旋转模型
	self.upBtn.onClick:Clear()
	self.upBtn.onTouchBegin:Clear()
	self.upBtn.onTouchEnd:Clear()

	WingModel:GetInstance():RemoveEventListener(self.selectCostHandler)
	WingModel:GetInstance():RemoveEventListener(self.updateHandler)
	Stage.inst.onTouchMove:Remove(self.ontouchMove, self)
	Stage.inst.onTouchEnd:Remove(self.ontouchEnd,self)
end

function WingUpPanel:OnUpBtnClickHandler()
	if self.isDestroy then return end
	local typ = WingModel:GetInstance().type
	if typ == 1 then
		if WingModel:GetInstance().totalWingValue > 0 then
			WingController:GetInstance():C_Evolve(typ, self.data.wingId, 0)
		else
			Message:GetInstance():TipsMsg("羽灵值不足")
		end
	else
		if WingModel:GetInstance():HasCostItem() then
			if WingModel:GetInstance():HasNumCost(self.curSelectCost) > 0 then
				if WingModel:GetInstance().isUp == 1 then
					WingController:GetInstance():C_Evolve(typ, self.data.wingId, self.curSelectCost)
					WingModel:GetInstance().isUp = 0
				end
			else
				Message:GetInstance():TipsMsg("物品数量不足")
			end
		else
			local marketId = 0
			local cfg = GetCfgData("market")
			for k , v in pairs(cfg) do
				if type(v) ~= 'function' and v and v.itemId == self.curSelectCost and v.pageId == 2 then
					marketId = v.marketId
					break
				end
			end
			MallController:GetInstance():QuickBuy(marketId)
		--[[if not self.showLost then
			self.showLost = true
			UIMgr.Win_Confirm("温馨提示", "羽化材料不足，是否前往购买？", "确定", "取消", function()--确定
				MallController:GetInstance():OpenMallPanel(nil, 0, 2)				
			end,
			function()	--取消
				self.showLost = false
			end)
		end]]--
		end
	end
end

function WingUpPanel:OnClickChooseBtn()
	self.isYLBtn = not self.isYLBtn
	local totalWingValue = WingModel:GetInstance().totalWingValue
	self.chooseBtn:GetChild("chooseIcon").visible = self.isYLBtn
	if self.isYLBtn then	
		WingModel:GetInstance().type = 1
		self.cost1:SetGrayed(true)
		self.cost2:SetGrayed(true)
		self.cost3:SetGrayed(true)
		self.cost4:SetGrayed(true)
	else
		WingModel:GetInstance().type = 2
		self.cost1:SetGrayed(false)
		self.cost2:SetGrayed(false)
		self.cost3:SetGrayed(false)
		self.cost4:SetGrayed(false)
	end
end

function WingUpPanel:OnSelectCostHandler(data)
	self.curSelectCost = data
end

--创建角色3d模型
function WingUpPanel:CreateWingModel()
	self.role3D.visible = true
	local callback = function ( prefab )
		if prefab == nil then return end
		self.wingModel = GameObject.Instantiate(prefab)
		local cfg = GetCfgData("wing"):Get(self.data.wingId).offset
		self.wingModel.transform.localPosition = Vector3.New(cfg[1], cfg[2], 1000)
		self.wingModel.transform.localScale = Vector3.New(400, 400, 400)
		self.wingModel.transform.localEulerAngles = Vector3.New(0, 90, 0)
		self.role3D:SetNativeObject(GoWrapper.New(self.wingModel)) -- ui 3d对象加入
	end
	LoadWing(self.data.dressStyle, callback)
end

function WingUpPanel:Show(data)
	self.data = data 
	self.isShowing = true
	self:CreateWingModel()
	self:Update(false)
end

function WingUpPanel:Close()
	self.isShowing = false

	CommonBackGround.Close(self)
end

function WingUpPanel:PlayUpGradeEft()
	self.isPlayingUpEft = true
	local startProgess = self.playProgessCur
	local targetProgess = self.playProgessCur - self.progessReduceSection
	self.progessTweener = TweenUtils.TweenFloat(startProgess, targetProgess, self.flyDuration, function(data)
		if self.progess then
			self.playProgessCur = data
			self.progess:SetProgess(self.playProgessCur, self.playProgessMax)
			self.progessLabel.text = math.ceil(self.playProgessCur).."/"..math.ceil(self.playProgessMax)
		end
	end)

	self.starts:SetFly(self.flyStarIndex, self.flyTargetPos, self.flyDuration, function() 
		--	if not self.starts then return end
		self.starts:SetStarState(self.flyStarIndex, false)
		self.flyStarIndex = self.flyStarIndex - 1
		if self.flyStarIndex > 0 then
			self:PlayUpGradeEft()
		else
			if self.upEft and self.successEft then
				EffectMgr.AddToUI(self.upEft, self.successEft)
				self.isPlayingUpEft = false
				self.flyStarIndex = nil
				self.flyDuration = nil
				self.progessReduceSection = nil
				self.flyTargetPos = nil
				self.playProgessCur = nil
				self.playProgessMax = nil
				self:Update(false)
			end
		end
	end)
end

function WingUpPanel:Update(isEventUpdate)
	if not self.isShowing or self.isPlayingUpEft then return end
	if self.data == nil then  return end
	
	self.dynamicData = WingModel:GetInstance():GetWingDynamicData(self.data.wingId) 
	self:SetYLData()

	self.name.text = self.data.name
	local starUpCfg = nil
	local starLastCfg = nil --+++++++
	if self.dynamicData then
		local start = self.dynamicData.star
		local integer, decimals = math.modf(start / 5)
		local startLevel = start % 5

		self.isUpGrade = false
		if isEventUpdate and self.curGrade and integer > self.curGrade and self.data.upStarStr[start + 1] then
			self.isUpGrade = true
			RenderMgr.Realse("WingUpPanel.pressRender")
		end

		if self.isUpGrade then --升阶
			self.starts:SetLevel(5)
			for i = 1, 5 do
				self.starts:SetStarState(i, true, true)
			end

			starUpUpCfg = self.data.upStarStr[start+1]
			starUpCfg = self.data.upStarStr[start]
			starLastCfg = self.data.upStarStr[start-1]
			if starUpCfg then
				self.isMax = false
				self.progess:SetProgess(starUpCfg[2]-starLastCfg[2], starUpCfg[2]-starLastCfg[2])
				self.progessLabel.text = (starUpCfg[2]-starLastCfg[2]).."/"..(starUpCfg[2]-starLastCfg[2])
			else
				self.isMax = true
				self.starts:SetLevel(5)
				self.progess:SetProgess(1, 1)
				self.progessLabel.text = "已达到最大值"
			end
			self.upBtn.grayed = true
			self.upBtn.touchable = false

			self.flyStarIndex = 5
			self.flyDuration = 0.6
			self.progessReduceSection = tonumber(starUpCfg[2]-starLastCfg[2]) / 5
			self.flyTargetPos = self.ui:LocalToGlobal(Vector2.New(self.role3D.x + 180, self.role3D.y + 210))
			self.playProgessCur = starUpUpCfg[2]-starUpCfg[2]
			self.playProgessMax = starUpUpCfg[2]-starUpCfg[2]

			MainUIController:GetInstance():LockInTime(self.flyDuration*5)
			self:PlayUpGradeEft()
		else
			self.starts:SetLevel(startLevel)
			self.curGrade = integer

			starUpCfg = self.data.upStarStr[start + 2]
			starLastCfg = self.data.upStarStr[start+1]
			if starUpCfg then
				self.isMax = false
				self.upBtn.grayed = false
				self.upBtn.touchable = true
				self.progess:SetProgess(self.dynamicData.wingValue, starUpCfg[2] -starLastCfg[2])
				self.progessLabel.text = self.dynamicData.wingValue.."/"..(starUpCfg[2]-starLastCfg[2])
				self.levelInfo.text = StringFormat("{0}阶", integer)
			else
				self.isMax = true
				self.upBtn.grayed = true
				self.upBtn.touchable = false
				self.starts:SetLevel(5)
				self.progess:SetProgess(1, 1)
				self.progessLabel.text = "已达到最大值"
				self.levelInfo.text = StringFormat("{0}阶", integer - 1)
			end
		end
	else
		self.starts:SetLevel(0)
		self.levelInfo.text = StringFormat("{0}阶", 0)
		self.progessLabel.text = "0/0"
	end
	local curAddPercent = 0
	self.list:RemoveChildrenToPool()
	for i = 1, #self.data.baseProperty do
		local prop = self.list:AddItemFromPool()
		local pName = prop:GetChild("value1")
		local pValue = prop:GetChild("value2")
		local upValue = prop:GetChild("value3")
		local line = prop:GetChild("line")
		if i == 1 then
			line.visible = false
		else
			line.visible = true
		end

		local curCfg = self.data.upStarStr[self.dynamicData.star+1]
		if curCfg then
			curAddPercent = curCfg[3] / 10000
		else
			curAddPercent = 0
		end

		local nextCfg = self.data.upStarStr[self.dynamicData.star + 2]
		local nextAddPercent = 0
		if nextCfg then
			nextAddPercent = nextCfg[3] / 10000
		else
			nextAddPercent = curAddPercent
		end

		pName.text = RoleVo.GetPropDefine(self.data.baseProperty[i][1]).name
		pValue.text =  math.ceil(tonumber(self.data.baseProperty[i][2]) * (1 + curAddPercent))
		upValue.text = math.ceil(math.ceil(tonumber(self.data.baseProperty[i][2]) * (1 + nextAddPercent)) - math.ceil(tonumber(self.data.baseProperty[i][2]) * (1 + curAddPercent)))
	end
	local baseProperty = {}
	for i=1, #self.data.baseProperty do
		table.insert(baseProperty, { self.data.baseProperty[i][1], tonumber(self.data.baseProperty[i][2]) * (1 + curAddPercent)})
	end
	self.power.text = "i"..CalculateScore(baseProperty)
end

--旋转角色模型
function WingUpPanel:RotationwingModel( context )
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.ontouchMove, self )
		Stage.inst.onTouchEnd:Add( self.ontouchEnd, self )
	end
end

--touchmove
function WingUpPanel:ontouchMove(context)
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		if self.lasttouchX ~= 0 then
			local rotY = self.wingModel.transform.localEulerAngles.y - (evt.x - self.lasttouchX)
			self.wingModel.transform.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lasttouchX = evt.x
end

--touchend
function WingUpPanel:ontouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lasttouchX = 0
		Stage.inst.onTouchMove:Remove(self.ontouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.ontouchEnd,self)
	end
end

function WingUpPanel:OnHideHandler()
	self.role3D.visible = false
end

function WingUpPanel:Layout()
end

function WingUpPanel:__delete()
	if self.wingModel then
		destroyImmediate(self.wingModel) 
	end
	self.isDestroy = true
	self:RemoveEvent()
	WingModel:GetInstance().type = 2
	if self.progess then
		self.progess:Destroy()
		self.progess = nil
	end
	if self.cost1 then
		self.cost1:Destroy()
		self.cost1 = nil
	end
	if self.cost2 then
		self.cost2:Destroy()
		self.cost2 = nil
	end
	if self.cost3 then
		self.cost3:Destroy()
		self.cost3 = nil
	end
	if self.cost4 then
		self.cost4:Destroy()
		self.cost4 = nil
	end
	WingCostPropItem.CurSelectItem = nil

	if self.starts then
		self.starts:Destroy()
		self.starts = nil
	end
	self.data = nil
end