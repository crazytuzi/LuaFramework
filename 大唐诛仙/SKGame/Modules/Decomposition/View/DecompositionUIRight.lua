DecompositionUIRight = BaseClass(LuaUI)
function DecompositionUIRight:__init(...)
	self.URL = "ui://q13jjk9jxy1x4"
	self:__property(...)
	self:Config()
end

function DecompositionUIRight:SetProperty(type)
	self.type = type
end

function DecompositionUIRight:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function DecompositionUIRight:CleanSelectCellUIAndData()
	self:CleanItemUIList()
end

function DecompositionUIRight:HandleClose()
	--关闭的时候清除特效
	self:CleanAllEffect()
end

function DecompositionUIRight:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Decomposition","DecompositionUIRight")
	self.btnDecomposition = self.ui:GetChild("btnDecomposition")
	self.btnOneKeyDecomposition = self.ui:GetChild("btnOneKeyDecomposition")
	self.btnTips = self.ui:GetChild("btnTips")
	self.layer_items = self.ui:GetChild("layer_items")
	self.buttonTick0 = self.ui:GetChild("buttonTick0")
	self.buttonTick1 = self.ui:GetChild("buttonTick1")
	self.buttonTick2 = self.ui:GetChild("buttonTick2")
	self.labelDesc = self.ui:GetChild("labelDesc")
	self.effect_root1 = self.ui:GetChild("effect_root1")
	self.effect_root2 = self.ui:GetChild("effect_root2")
	self.effect_root3 = self.ui:GetChild("effect_root3")
	self.effect_root4 = self.ui:GetChild("effect_root4")
end

function DecompositionUIRight.Create(ui, ...)
	return DecompositionUIRight.New(ui, "#", {...})
end

function DecompositionUIRight:__delete()
	self:CleanAllEffect()
	self:CleanEvent()
	self:DestroyItemUIList()
	self:DestroyUIBtnTickList()
	if self.model then
		self.model = nil
	end
end

function DecompositionUIRight:InitUI()
	self.buttonTick0 = ButtonDecompositionTick.Create(self.buttonTick0)
	self.buttonTick1 = ButtonDecompositionTick.Create(self.buttonTick1)
	self.buttonTick2 = ButtonDecompositionTick.Create(self.buttonTick2)

	self.buttonTickList = {}
	self.buttonTickList[1] = self.buttonTick0
	self.buttonTickList[2] = self.buttonTick1
	self.buttonTickList[3] = self.buttonTick2

	self.effectRoot = {}
	self.effectRoot[1] = self.effect_root1
	self.effectRoot[2] = self.effect_root2
	self.effectRoot[3] = self.effect_root3
	self.effectRoot[4] = self.effect_root4

	self:InitItemsUI()
end

function DecompositionUIRight:InitData()
	if self.type == DecompositionConst.Decomposition then
		self.model = DecompositionModel:GetInstance()
	else
		self.model = RefinedModel:GetInstance()
		self.btnDecomposition.icon = "ui://q13jjk9j82xa16"
		self.labelDesc.text = self:SetDefaultTips()
		self.btnOneKeyDecomposition.title = "一键提炼"
	end
	
	self.buttonTickList = {}
	self.pkgCellList = {}
	self.itemsUIList = {}
	self.effectObjList = {}
	self.curTipsDataIndex = 0
end

function DecompositionUIRight:InitEvent()
	self.handler0 =  self.model:AddEventListener(DecompositionConst.SelectItem, function (pkgCellObj)
		self:SetItemsUI(pkgCellObj)
	end)

	self.handler1 = self.model:AddEventListener(DecompositionConst.UnselectItem, function (pkgCellObj)
		self:RemoveItemUI(pkgCellObj)
	end)

	self.handler2 = self.model:AddEventListener(DecompositionConst.Succ, function (bagId)
		self:HanleDecomposeSucc(bagId)
	end)
	-- self.handler3 = self.model:AddEventListener(DecompositionConst.AutoSucc, function (rareIdList)
	-- 	self:HandleAutoDecomposeSucc(rareIdList)
	-- end)
	ButtonToDelayClick(self.btnDecomposition , function() self:OnBtnDecompositionClick() end , 2)
	self.btnOneKeyDecomposition.onClick:Add(self.OneKeyDecomposition, self)
	self.btnTips.onClick:Add(self.OnBtnTipsClick ,self)

	for i = 1, #self.buttonTickList do
		if self.buttonTickList[i] ~= nil then
			self.buttonTickList[i].ui.onClick:Add(function()
				self:OnButtonTickClick(i)
			end)
		end
	end
end

function DecompositionUIRight:EnableBtnDecomposition()
	self.btnDecomposition.enabled = true
end

function DecompositionUIRight:CleanEvent()
	self.model:RemoveEventListener(self.handler0)
	self.model:RemoveEventListener(self.handler1)
	self.model:RemoveEventListener(self.handler2)
	self.model:RemoveEventListener(self.handler3)
end

function DecompositionUIRight:InitItemsUI()
	for i = 1, DecompositionConst.MaxSelectItemsCnt do
		local cell = PkgCell.New(self.layer_items, nil, function(cell) self:OnClickItem(cell) end)
		local w , h = cell:GetSize()
		cell:OpenTips(false, false)
		cell:SetupPressShowTips(true , 1)
		cell:SetXY(55 + (w + 20) * (i - 1), 28 )
		cell.gid = i
		table.insert(self.itemsUIList , cell)
	end
end

function DecompositionUIRight:SetItemsUI(pkgCellObj)
	local i = self:GetItemDataIndex()
	if (i ~= -1) and (not TableIsEmpty(pkgCellObj)) then
		local curItemData = pkgCellObj:GetData()
		local curItemUI = self:GetItemUIByIndex(i)
		if not TableIsEmpty(curItemUI) then
			if not TableIsEmpty(curItemData) then curItemUI:SetData(curItemData) end
		end
	end
end

function DecompositionUIRight:RemoveItemUI(pkgCellObj)
	if not TableIsEmpty(pkgCellObj) then
		local data = pkgCellObj:GetData()
		if not TableIsEmpty(data) then
			local item = self:GetItemUIById(data.id)
			if not TableIsEmpty(item) then
				self:DestroyItemUIByIndex(item.gid)
			end
		end
	end
end

function DecompositionUIRight:UpdateUI()
	for i = 1, DecompositionConst.MaxSelectItemsCnt do
		local curItem = self.itemsUIList[i]
		if not TableIsEmpty(curItem) then
			local cur = curItem:GetData()
			if not TableIsEmpty(cur) then
				local item = self.model:GetItemDataById( cur.id)
				if not TableIsEmpty(item) then
					if item.num == 0 then
						self:DestroyItemUIByIndex(i)
					else
						if item.num ~= cur.num then
							curItem:SetData(item)
						end
					end
				else
					self:DestroyItemUIByIndex(i)
				end
			end
		end
	end
end

function DecompositionUIRight:HanleDecomposeSucc(bagId)
	if bagId then
		for i = 1, DecompositionConst.MaxSelectItemsCnt do
			local curItem = self.itemsUIList[i]
			if not TableIsEmpty(curItem) then
				local cur = curItem:GetData()
				if not TableIsEmpty(cur) then
					if cur.id == toLong(bagId) then
						local p = curItem.ui.position
						self:LoadEffect("4520", i, Vector3.New(p.x+32, p.y-98, p.z))
						DelayCall(function() self:DestroyItemUIByIndex(i) end , 0.5)
						break
					end
				end
			end
		end
	end
end

function DecompositionUIRight:HandleAutoDecomposeSucc(rareIdList)
	if rareIdList then
		for rareIndex = 1, #rareIdList do
			for i = 1, DecompositionConst.MaxSelectItemsCnt do
				local curItem = self.itemsUIList[i]
				if not TableIsEmpty(curItem) then
					local curItemData = curItem:GetData()
					if not TableIsEmpty(curItemData) then
						if GoodsVo.GetRare(curItemData.goodsType , curItemData.bid) == rareIdList[rareIndex] then
							local p = curItem.ui.position
							self:LoadEffect("4520", i, Vector3.New(p.x+32, p.y-98, p.z))
							DelayCall(function() self:DestroyItemUIByIndex(i) end , 0.5)
						end
					end
				end
			end
		end
	end
end

--获取第一个空位
function DecompositionUIRight:GetItemDataIndex()
	for i = 1 , #self.itemsUIList do
		local curItemObj = self.itemsUIList[i]
		if not TableIsEmpty(curItemObj) then
			if curItemObj:GetData() == nil then
				return i
			end
		end
	end
	return -1
end

--判断第N个ItemUI
function DecompositionUIRight:GetItemUIByIndex(i)
	return self.itemsUIList[i] or {}
end

--通过id获取对应的ItemUI
function DecompositionUIRight:GetItemUIById(id)
	if id then
		for i =  1 , #self.itemsUIList do
			local curObj = self.itemsUIList[i]
			if not TableIsEmpty(curObj) then
				local curObjData = curObj:GetData()
				if not TableIsEmpty(curObjData) and curObjData.id == id then
					return self.itemsUIList[i]
				end
			end
		end
	end
	return {}
end

function DecompositionUIRight:OnClickItem(cell)
	if cell then
		self.model:DispatchEvent(DecompositionConst.CancelItem , cell)
		self:DestroyItemUIByIndex(cell.gid)
	end
end

function DecompositionUIRight:DestroyItemUIByIndex(i)
	if not TableIsEmpty(self.itemsUIList[i]) then
		self.itemsUIList[i]:SetData(nil)
	end
end

function DecompositionUIRight:CleanItemUIList()
	for i = 1, #self.itemsUIList do
		if not TableIsEmpty(self.itemsUIList[i]) then
			self.itemsUIList[i]:SetData(nil)
		end
	end
end

function DecompositionUIRight:DestroyItemUIList()
	for i = 1, #self.itemsUIList do
		if not TableIsEmpty(self.itemsUIList[i]) then
			self.itemsUIList[i]:Destroy()
			self.itemsUIList[i] = {}
		end
	end
end

function DecompositionUIRight:DestroyUIBtnTickList()
	for i = 1, #self.buttonTickList do
		if not TableIsEmpty(self.buttonTickList) then
			self.buttonTickList[i]:Destroy()
		end
	end
	self.buttonTickList = nil
end

function DecompositionUIRight:GetItemInstanceIdList()
	local list = {}
	for i = 1, #self.itemsUIList do
		if not TableIsEmpty(self.itemsUIList[i]) then
			local data = self.itemsUIList[i]:GetData()
			if data then
				table.insert(list, data.id or 0)
			end
		end
	end
	return list
end

--分解槽中有物品的品质大于3级，则点击后弹出
function DecompositionUIRight:IsNeedShowWinConfirm()
	for i = 1, #self.itemsUIList do
		if not TableIsEmpty(self.itemsUIList[i]) then
			local data = self.itemsUIList[i]:GetData()
			if not TableIsEmpty(data) then
				local rare =  GoodsVo.GetRare(data.goodsType, data.bid)
				if rare > 3 then
					return true
				end
			end
		end
	end
	return false
end

function DecompositionUIRight:OnBtnDecompositionClick()
	local function decompositionReq()
		local list = self:GetItemInstanceIdList()
		if not TableIsEmpty(list) then
			if self.type == DecompositionConst.Decomposition then
				DecompositionController:GetInstance():C_Decompose(list)
			else
				DecompositionController:GetInstance():C_Refine(list)
			end
		end
	end
	if self:IsNeedShowWinConfirm() == true then
		if self.type == DecompositionConst.Decomposition then
			UIMgr.Win_Confirm("提示" , "你要分解的物品稀有度较高，确定要分解吗？" , "确认" , "取消", decompositionReq)
		else
			UIMgr.Win_Confirm("提示" , "你要提炼的物品稀有度较高，确定要提炼吗？" , "确认" , "取消", decompositionReq)
		end
		
	else
		decompositionReq()
	end
end


function DecompositionUIRight:OnButtonTickClick(index)
	if index then
		if self.buttonTickList[index] then
			self.buttonTickList[index]:SetIconVisible()
		end
	end
end
local RareIndex = DecompositionConst.RareIndex
function DecompositionUIRight:GetDecompositionRareList()
	local rareIdList = {}
	for index = 1, #self.buttonTickList do
		if not TableIsEmpty(self.buttonTickList[index]) then
			local hasTick = self.buttonTickList[index]:GetTickState()
			if hasTick == true then
				local rare = RareIndex.None
				if index == RareIndex.White then
					rare = RareIndex.White
				elseif index == RareIndex.Green then
					rare = RareIndex.Green
				elseif index == RareIndex.Blue then
					rare = RareIndex.Blue
				end
				if rare ~= RareIndex.None then
					table.insert(rareIdList, rare)
				end
			end
		end
	end
	return rareIdList
end

function DecompositionUIRight:OneKeyDecomposition()
	local rareIdList = self:GetDecompositionRareList()
	if not TableIsEmpty(rareIdList) then
		if self.type == DecompositionConst.Decomposition then
			DecompositionController:GetInstance():C_AutoDecompose(rareIdList)
		else
			DecompositionController:GetInstance():C_AutoRefine(rareIdList)
		end
	end
end

function DecompositionUIRight:CleanAllEffect()
	for index = 1, #self.effectObjList do
		if self.effectObjList[index] ~= nil then
			destroyImmediate(self.effectObjList[index])
		end
	end
	self.effectObjList = {}
end

function DecompositionUIRight:LoadEffect(res , effectMountIndex, posVet3)
	local function callback(effect)
		if effect then
			if self.effectObjList[effectMountIndex] ~= nil then
				destroyImmediate(self.effectObjList[effectMountIndex])
				self.effectObjList[effectMountIndex] = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			local tf = effectObj.transform
			tf.localPosition = posVet3
			tf.localScale = Vector3.New(100, 100, 100)
	 		tf.localRotation = Quaternion.Euler(0, 0, 0)
			self.effectRoot[effectMountIndex]:SetNativeObject(GoWrapper.New(effectObj))
			self.effectObjList[effectMountIndex] = effectObj
		end
	end
	
	if res ~= nil and self.effectRoot[effectMountIndex] ~= nil then
		LoadEffect(res , callback)
	end
end

function DecompositionUIRight:OnBtnTipsClick()
	self.curTipsDataIndex = self.curTipsDataIndex + 1
	local content
	if self.type == DecompositionConst.Decomposition then
		content = DecompositionConst.TipsContent1
	else
		content = DecompositionConst.TipsContent2
	end
	local c = self.curTipsDataIndex % (#content)
	if c == 0 then
		self.labelDesc.text = content[#content]
	else
		self.labelDesc.text = content[c] or ""
	end
	
end

function DecompositionUIRight:SetDefaultTips()
	if self.type == DecompositionConst.Decomposition then
		self.labelDesc.text = "分解装备可得注灵石"
	else
		self.labelDesc.text = "提炼装备可得都护府神兽精华"
	end
end