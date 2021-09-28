CompositionUIRight = BaseClass(LuaUI)
function CompositionUIRight:__init(...)
	self.URL = "ui://qr7fvjxixy1x5";
	self:__property(...)
	self:Config()
end

function CompositionUIRight:SetProperty(...)
	
end

function CompositionUIRight:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function CompositionUIRight:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Composition","CompositionUIRight")
	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.bg2 = self.ui:GetChild("bg2")
	self.groupBG = self.ui:GetChild("groupBG")
	self.effect_root = self.ui:GetChild("effect_root")
	self.layer_items = self.ui:GetChild("layer_items")
	self.btnComposition = self.ui:GetChild("btnComposition")
	self.loader_consume_icon = self.ui:GetChild("loader_consume_icon")
	self.label_consume_cnt = self.ui:GetChild("label_consume_cnt")
end

function CompositionUIRight.Create(ui, ...)
	return CompositionUIRight.New(ui, "#", {...})
end

function CompositionUIRight:__delete()
	self:DestroyPkgCellList()
	self:CleanEvent()

	if self.effectObj then
		self.effectObj = nil
	end

	if self.model then
		self.model = nil
	end

	RenderMgr.Realse(self.longPressKey)
end

function CompositionUIRight:DestroyPkgCellList()
	for index = 1 , #self.pkgCellList do
		self.pkgCellList[index]:Destroy()
		self.pkgCellList[index] = nil
	end
	self.pkgCellList = {}
end

function CompositionUIRight:InitUI()
	local function OnClickPkgCell(cellObj)
		self:OnClickPkgCell(cellObj)
	end
	for index = 1 , CompositionConst.MaxRightItemsCnt do
		local curItemObj = PkgCell.New(self.layer_items, nil, OnClickPkgCell)
		curItemObj:OpenTips(false, false)
		curItemObj:SetupPressShowTips(true , 1)
		table.insert(self.pkgCellList, curItemObj)
	end
	if #self.pkgCellList >= 3 then
		self.pkgCellList[1]:SetXY( 204 , 153)
		self.pkgCellList[2]:SetXY( 66 , 252)
		self.pkgCellList[3]:SetXY( 361 , 252)

		self.pkgCellList[1]:SetSize(110 , 110)
		self.pkgCellList[2]:SetSize( 91 , 91)
		self.pkgCellList[3]:SetSize( 91, 91)

		self.pkgCellList[1]:SetNumFontSize(20)
		self.pkgCellList[2]:SetNumFontSize(20)
		self.pkgCellList[3]:SetNumFontSize(20)
	end
	self:InitGoldConsumeUI()
end

function CompositionUIRight:InitData()
	self.model = CompositionModel:GetInstance()
	self.pkgCellList = {}
	self.curPkgCellData = {}
	self.effectObj = nil
	self.longPressKey = "CompositionUIRight.OnBtnComposeClick"
end

function CompositionUIRight:InitEvent()
	local function OnItemSelect(pkgCellData)
		self:OnCompositionItemSelect(pkgCellData)
	end
	self.handler0 = self.model:AddEventListener(CompositionConst.SelectItem , OnItemSelect)

	-- self.btnComposition.onClick:Add(function()
	-- end)
	--改成长按
	local function OnBtnComposeClick()
		if not TableIsEmpty(self.curPkgCellData) then
			CompositionController:GetInstance():CompositionReq(self.curPkgCellData.bid)
			if TaskModel:GetInstance():GetAutoExecTaskId() ~= 0 then
				GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
			end
		end
	end
	longPress(self.btnComposition , OnBtnComposeClick , 0.5 , self.longPressKey)
	--++
	self.btnComposition.onTouchBegin:Add(function ()
		OnBtnComposeClick()
	end)
	--++
	local function HandleUpdateItems()
		self:UpdateUI()
	end
	self.handler1 =  self.model:AddEventListener(CompositionConst.UpdateItems, HandleUpdateItems)
	local function HandleComposeSucc()
		self:LoadEffect("4511", 10)
		DelayCall(function() self:LoadEffect("4512", 1) end, 0.5)
	end
	self.handler2 = self.model:AddEventListener(CompositionConst.ComposeSucc , HandleComposeSucc)
end

function CompositionUIRight:CleanEvent()
	self.model:RemoveEventListener(self.handler0)
	self.model:RemoveEventListener(self.handler1)
	self.model:RemoveEventListener(self.handler2)
end

function CompositionUIRight:OnCompositionItemSelect( pkgCellData )
	if not TableIsEmpty(pkgCellData) then
		self:SetCurPkgCellData(pkgCellData)
		self:SetUI()
	end
end

function CompositionUIRight:SetCurPkgCellData(data)
	if not TableIsEmpty(data) then
		self.curPkgCellData = data
	end
end

function CompositionUIRight:SetUI()
	if not TableIsEmpty(self.curPkgCellData) then
		local itemDataType = self.model:GetItemsTypeById(self.curPkgCellData.bid)
		if itemDataType ~= -1 then
			local cnt = PkgModel:GetInstance():GetTotalByBid(self.curPkgCellData.bid)
			--不绑定
			local isBinding = 0 
			self.pkgCellList[1]:SetDataByCfg(itemDataType , self.curPkgCellData.bid , cnt , isBinding)
		end

		local composeCfg = self.model:GetCfgData(self.curPkgCellData.bid)
		if not TableIsEmpty(composeCfg) then
			local curCnt = 0
			for index = 1, #composeCfg.composeStr do
				local curConsume = composeCfg.composeStr[index]
				if curConsume[1] ~= GoodsVo.GoodType.gold then
					curCnt = curCnt + 1
					if  0 < curCnt and curCnt < 3 then
						self.pkgCellList[curCnt + 1]:Clear()
						self.pkgCellList[curCnt + 1]:SetLock(false)
						local isBinding = 0 --不绑定
						self.pkgCellList[curCnt + 1]:SetDataByCfg( curConsume[1] , curConsume[2] , curConsume[3] , isBinding)
					end
				else
					self:SetGoldConsumeUI(curConsume)
				end
			end

			if curCnt < 2 then
				--加锁第三个
				--self.pkgCellList[3]
				if not TableIsEmpty(self.pkgCellList[3]) then
					self.pkgCellList[3]:Clear()
					self.pkgCellList[3]:AddLock()
					self.pkgCellList[3]:SetLock(true)
				end
			end

			self:SetCntUI()
		end
		self:SetCompositionBtnUI()
	end
end

function CompositionUIRight:SetCntUI()
	for index = 1 , #self.pkgCellList do
		local curPkgCell = self.pkgCellList[index]
		if not TableIsEmpty(curPkgCell) then
			local goodsVoObj = curPkgCell:GetData()
			if not TableIsEmpty(goodsVoObj) then
				local hasCnt = PkgModel:GetInstance():GetTotalByBid(goodsVoObj.bid)
				
				local needCnt = self:GetNeedCntByBid(goodsVoObj.bid , goodsVoObj.goodsType )

				local colorStr = GoodsVo.RareColor[1] --白色
				if needCnt > hasCnt then
					colorStr = GoodsVo.errorcolor --红色
				end

				if index ~= 1 then
					curPkgCell.title.text = StringFormat("[color={0}]{1}/{2}[/color]" , colorStr , hasCnt , needCnt)
				else
					curPkgCell.title.text = StringFormat("[color={0}]{1}[/color]" , GoodsVo.RareColor[1] , hasCnt)
				end

			end
		end
	end
end

function CompositionUIRight:GetNeedCntByBid(bid, goodsType)
	local rtnCnt = 0
	if bid and goodsType then
		if not TableIsEmpty(self.curPkgCellData) then
			
			local composeCfg = self.model:GetCfgData(self.curPkgCellData.bid)
			if not TableIsEmpty(composeCfg) then
				
				for index = 1, #composeCfg.composeStr do
					local curConsume = composeCfg.composeStr[index]
					
					local cfg = GoodsVo.GetCfg(goodsType, bid)
					local goodsVoType = cfg.goodsType or -1
					if goodsVoType == goodsType and curConsume[2] == bid then
						
						rtnCnt = curConsume[3]
						break
					end
				end
			end
		end
	end
	return rtnCnt
end

function CompositionUIRight:OnClickPkgCell(cellObj)

end

function CompositionUIRight:SetGoldConsumeUI(cfg)
	if not TableIsEmpty(cfg) then
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		local strRGB = ""
		if mainPlayer and mainPlayer.gold then
			if mainPlayer.gold < cfg[3] then
				strRGB = "#C60202"
			else
				strRGB = "#FFFFFF"
			end
		end
		local strCnt = StringFormat("[color={0}]{1}[/color]" , strRGB , cfg[3] or 0)
		
		self.loader_consume_icon.url = StringFormat("Icon/Goods/gold")
		self.label_consume_cnt.text = strCnt
	end
end

function CompositionUIRight:InitGoldConsumeUI()
	self.loader_consume_icon.url = StringFormat("Icon/Goods/gold")
	self.label_consume_cnt.text = 0
end

function CompositionUIRight:OnBtnCompose()
	if not TableIsEmpty(self.curPkgCellData) then
		CompositionController:GetInstance():CompositionReq(self.curPkgCellData.bid)
	end
end

function CompositionUIRight:UpdateUI()
	self:SetUI()
end

function CompositionUIRight:CleanEffect()
	if self.effectObj then
		EffectMgr.RealseEffect(self.effectObj)
	end
end

function CompositionUIRight:LoadEffect(res, scaleNum)
	if not res then return end
	self.effectObj = EffectMgr.AddToUI(res, self.effect_root, 1, nil , nil , nil , nil ,function ( effect )
		local tf = effect.transform
		tf.localPosition = Vector3.New(260, -202, 0)
		tf.localScale = Vector3.New(100, 100, 100)
		tf.localRotation = Quaternion.Euler(0, 0, 0)
	end)
end


function CompositionUIRight:SetCompositionBtnUI()
	if not TableIsEmpty(self.curPkgCellData) then
		local isEnoughRes = self.model:IsEnoughToComposition(self.curPkgCellData.bid)
		if not isEnoughRes then
			self.btnComposition.title = "资源不足"
			self.btnComposition.enabled = false
		else
			self.btnComposition.title = "合成"
			self.btnComposition.enabled = true
		end
	else
		self.btnComposition.title = "合成"
			self.btnComposition.enabled = true
	end
end