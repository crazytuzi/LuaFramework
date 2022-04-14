OpenBagInputPanel = OpenBagInputPanel or class("OpenBagInputPanel",WindowPanel)
local OpenBagInputPanel = OpenBagInputPanel

function OpenBagInputPanel:ctor()
	self.abName = "bag"
	self.assetName = "OpenBagInputPanel"
	self.layer = "UI"
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.openCellCount = 1
	self.needTbl = nil
	self.needEnough = true
	self.model = BagModel:GetInstance()
end

function OpenBagInputPanel:dctor()
end

function OpenBagInputPanel:Open(bagWare, openCellCount)
	self.bagWare = bagWare or self.model.bagId
	self.openCellCount = openCellCount or 1
	OpenBagInputPanel.super.Open(self)
end

function OpenBagInputPanel:LoadCallBack()
	self.nodes = {
		"Infos",
		"OpenBtn",
		"Infos/AddCellInfo/InputField",
		"NotEnoughTip",
		"Infos/needGoods/needCount",
		"Infos/needGoods/goodsContain",
		"group/Toggle",
		"group/Toggle2",
	}
	self:GetChildren(self.nodes)
	self.NotEnoughTipTxt = self.NotEnoughTip:GetComponent('Text')
	self.CountInputIpt = self.InputField:GetComponent('InputField')
	self.needCountTxt = self.needCount:GetComponent('Text')
	self.Toggle = GetToggle(self.Toggle)
	self.Toggle2 = GetToggle(self.Toggle2)

	--self:SetPanelSize(501, 328)
	self:SetTileTextImage("bag_image", "bag_extend_f")
	self:AddEvent()
end

function OpenBagInputPanel:AddEvent()
	local function call_back()
		if self.needEnough then
			self:RequestOpenCell()
		else
			local itemCfg = Config.db_item[self.needTbl[1]]
			local voucherCfg = Config.db_voucher[self.needTbl[1]]
			local tipInfo = string.format(ConfigLanguage.Bag.OpenCellNotEnoughGoods2,itemCfg.name,self.spanCount * voucherCfg.price)
			Dialog.ShowTwo(ConfigLanguage.Mix.Tips,tipInfo,ConfigLanguage.Mix.Confirm,handler(self,self.RequestOpenCell))
		end
	end
	AddClickEvent(self.OpenBtn.gameObject,call_back)

	local function call_back(countIpt)
		self.openCellCount = tonumber(countIpt)
		self:ShowCostInfo()
	end
	self.CountInputIpt.onValueChanged:AddListener(call_back)

	local function call_back(value)
		if value then
			self.bagWare = self.model.wareHouseId
			self:UpdateInfo()
		end
	end
	AddValueChange(self.Toggle.gameObject, call_back)

	local function call_back(value)
		if value then
			self.bagWare = self.model.bagId
			self:UpdateInfo()
		end
	end
	AddValueChange(self.Toggle2.gameObject, call_back)
end

function OpenBagInputPanel:RequestOpenCell()
	BagController.GetInstance():RequestOpenCell(self.bagWare,self.openCellCount)
	self:Close()
end

function OpenBagInputPanel:OpenCallBack()
	self:UpdateView()
end

function OpenBagInputPanel:UpdateView( )
	if self.bagWare == self.model.bagId then
		self.Toggle2.isOn = true
	else
		self.Toggle.isOn = true
	end
	self:UpdateInfo()
end

function OpenBagInputPanel:UpdateInfo()
	self.CountInputIpt.text = tostring(self.openCellCount)
	self:ShowCostInfo()
end

function OpenBagInputPanel:ShowCostInfo()
	local bagCfg = Config.db_bag[self.bagWare]
	self.needTbl = String2Table(bagCfg.cost)
	if self.needIcon then
		self.needIcon:destroy()
		self.needIcon = nil
	end
	self.needIcon = GoodsIconSettorTwo(self.goodsContain)
	local hasCount = self.model:GetItemNumByItemID(self.needTbl[1])
	local needCount = self.needTbl[2] * self.openCellCount

	self.needCountTxt.text = ""
	local countInfo = nil
	if hasCount >= needCount then
		self.needEnough = true
		countInfo = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),hasCount) ..
				"/" .. needCount
		self.NotEnoughTipTxt.text = ""

		local param = {}
		param["model"] = self.model
		param["num"] = countInfo
		param["item_id"] = self.needTbl[1]
		self.needIcon:SetIcon(param)
		--self.needIcon:UpdateIconByItemIdClick(self.needTbl[1],countInfo)

	else
		self.spanCount = needCount - hasCount
		local itemCfg = Config.db_item[self.needTbl[1]]
		self.needEnough = false
		countInfo = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Red) ,hasCount) ..
				"/" .. needCount

		self.NotEnoughTipTxt.text = string.format(ConfigLanguage.Bag.OpenCellNotEnoughGoods,itemCfg.name)

		local param = {}
		param["model"] = self.model
		param["num"] = countInfo
		param["item_id"] = self.needTbl[1]
		self.needIcon:SetIcon(param)
	end
end

function OpenBagInputPanel:CloseCallBack(  )
	if self.needIcon ~= nil then
		self.needIcon:destroy()
	end
end
