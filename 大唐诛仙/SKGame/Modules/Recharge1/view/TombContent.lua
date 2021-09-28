TombContent = BaseClass(LuaUI)
function TombContent:__init(...)
	self.URL = "ui://g35bobp2e5r2g"
	self:__property(...)
	self:Config()
	self:InitEvent()
end
function TombContent:SetProperty(...)
	
end
function TombContent:Config()
	self.model = RechargeModel:GetInstance()
	self.cells = {}
end
function TombContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","TombContent");
	self.txtTombName = self.ui:GetChild("txtTombName")
	self.btnChakan = self.ui:GetChild("btnChakan")
	self.txtNumTab = {}
	for i = 1, 5 do
		self.txtNumTab[i] = self.ui:GetChild("txt_num" .. i)
	end
	self.comChangeBtn = self.ui:GetChild("n26")
end

function TombContent.Create(ui, ...)
	return TombContent.New(ui, "#", {...})
end

function TombContent:__delete()
	self:DestroyCells()
	self:RemoveEvent()
	self.model = nil
end

function TombContent:RefreshUI(idx)
	self:RefreshNums()
	self:RefreshCells(false, idx)
	self:RefreshBtn()
end

function TombContent:RefreshNums()
	local nums = self.model:GetTombNums()
	--local tombNum = self.model:GetTombLayer()
	--self.txtTombName.text = RechargeConst.TombName[tombNum]
	local costData = self.model:GetCostItem()
	local data = GetCfgData("item"):Get(tonumber(costData[1]))
	local tmp = StringFormat("{0}", data.name)
	--local newStr = StringFormat( [[当前探宝消耗：{0}个[color=#ff0000]{1}[/color] ]], costData[2], tmp)
	local newStr = StringFormat( [[当前探宝消耗：[color={0}]{1}[/color] ]], RechargeConst.TombCostColor[tonumber(costData[1])], tmp)
	self.txtTombName.text = newStr
	--setRichTextContent(self.txtTombName, newStr)

	for i = 1, #self.txtNumTab do
		self.txtNumTab[i].text = nums[i]
	end
end

function TombContent:RefreshBtn()
	local icon_cost = self.comChangeBtn:GetChild("icon_cost")
	local txt_cost_num = self.comChangeBtn:GetChild("txt_cost_num")
	local costNum = self.model:GetChangeCost()
	if costNum > 0 then
		icon_cost.url = RechargeConst.URL_TOMB_CHANGE_COST
		icon_cost.visible = true
		txt_cost_num.x = 169
		txt_cost_num.text = costNum
	else
		icon_cost.visible = false
		txt_cost_num.x = 120
		txt_cost_num.text = "(免费)"
	end
end

function TombContent:RefreshCells(isInit, idx)
	self:DestroyCells()
	self.cells = {}
	local startX = -23
	local startY = -10
	local curI = 1
	for i = 1, RechargeConst.kMaxCellNum do
		local cell = TombCell.New()
		local isNew = false
		if idx == i then
			isNew = true
		end
		cell:SetData(i, isInit, isNew)
		local j = math.ceil(i / 3)
		cell:SetXY(startX + 180 * curI, startY + 165 * j)
		self.cells[i] = cell
		self.ui:AddChild(cell.ui)
		if i % 3 == 0 then
			curI = 1
		else
			curI = curI + 1
		end
	end
end

function TombContent:DestroyCells()
	if not self.cells then return end
	for _, v in pairs(self.cells) do
		if v then
			v:RemoveFromParent()
			v:Destroy()
		end
	end
	self.cells = nil
end

function TombContent:InitEvent()
	self.comChangeBtn.onClick:Add( self.OnChangeClick, self )
	self.btnChakan.onClick:Add( self.OnChakanClick, self )
	local function OnGetData()
		self:RefreshUI()
	end
	self._hGetData = self.model:AddEventListener(RechargeConst.E_GetTombData, OnGetData)

	local function OnTombResult(idx)
		self:RefreshUI(idx)
	end
	self._hTombResult = self.model:AddEventListener(RechargeConst.E_TombResult, OnTombResult)

	local function OnChangeTomb()
		self:RefreshUI()
	end
	self._hChangeTomb = self.model:AddEventListener(RechargeConst.E_ChangeTomb, OnChangeTomb)
end

function TombContent:RemoveEvent()
	if self.model then
		self.model:RemoveEventListener(self._hGetData)
		self.model:RemoveEventListener(self._hTombResult)
		self.model:RemoveEventListener(self._hChangeTomb)
	end
end

function TombContent:OnChakanClick()
	RechargeController:GetInstance():OpenTombRewardShow()
end

function TombContent:OnChangeClick()
	RechargeController:GetInstance():OpenTombChangePop()
end