PayPanel = BaseClass(LuaUI)

function PayPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Pay","PayPanel")

	self.cell101 = self.ui:GetChild("cell101")
	self.cell102 = self.ui:GetChild("cell102")
	self.cell103 = self.ui:GetChild("cell103")
	self.cell104 = self.ui:GetChild("cell104")
	self.cell105 = self.ui:GetChild("cell105")
	self.cell106 = self.ui:GetChild("cell106")
	self.cell107 = self.ui:GetChild("cell107")

	self.model = PayModel:GetInstance()
	self.isInited = true

	self:SetXY(8,-10)

	self:Config()
	self:InitEvent()
end

function PayPanel:Config()
	self.payCellList = self.model.payCellList
	self.cellListVo = 
	{
		[self.payCellList[1]] = self.cell101,
		[self.payCellList[2]] = self.cell102,
		[self.payCellList[3]] = self.cell103,
		[self.payCellList[4]] = self.cell104,
		[self.payCellList[5]] = self.cell105,
		[self.payCellList[6]] = self.cell106,
		[self.payCellList[7]] = self.cell107,
	}
	self:InitData()
end

function PayPanel:InitEvent()
	-- 获取完已充值列表后刷新面板
	self.handler = GlobalDispatcher:AddEventListener(EventName.GetFirstPayList, function ()
		self:Update()
	end)
	GlobalDispatcher:DispatchEvent(EventName.PayPanelLayout, self.isInited)
end

-- 刷新面板
function PayPanel:Update()
	-- 获取已充值列表
	if #self.model.yichong > 0 then
		local cellList = {}
		SerialiseProtobufList( self.model.yichong, function ( id )
			if id and self.model:IsCellList( id ) then
				table.insert(cellList, id)
			end
		end)
		for __ ,v in ipairs(cellList) do
			local id = v
			local cell = self.cellListVo[id]
			cell:GetChild("shouchong").visible = false
			cell:GetChild("firstSong").visible = false
			self:ChangeNumFont( cell, id )
		end
	end
end

-- 初始数据                           
function PayPanel:InitData()
	for i,v in ipairs(self.payCellList) do
		local id = v
		local cell = self.cellListVo[id]
		-- 读表
		local price = self.model:GetPriceByPayItem(id, PayConst.GetType.Price)
		local gold = self.model:GetPriceByPayItem(id, PayConst.GetType.Gold)
		local premium = self.model:GetPriceByPayItem(id, PayConst.GetType.Premium)
		local cType = self.model:GetPriceByPayItem(id, PayConst.GetType.TypeValue)
		local lefttag = self.model:GetPriceByPayItem(id, PayConst.GetType.Lefttag)
		local righttag = self.model:GetPriceByPayItem(id, PayConst.GetType.Righttag)
		-- 初始化字体
		local getText = cell:GetChild("canGet"):GetChild("title")
		local tf = getText.textFormat
		tf.font = UIPackage.GetItemURL("Common" , "num_4")
		getText.textFormat = tf
		-- 元宝图标
		cell:GetChild("yuanbao").icon = "Icon/Pay/yb_" .. i
		-- 充值金额
		cell:GetChild("chongZhi").title = price
		-- 获得元宝
		cell:GetChild("canGet").title = gold + premium
		-- 首充赠送
		cell:GetChild("firstSong").title = premium
		-- 首充双倍图标
		if lefttag ~= 0 then
			cell:GetChild("shouchong").icon = "Icon/Pay/" .. lefttag
		else
			-- 没有首充双倍 隐藏首充赠送
			cell:GetChild("firstSong").visible = false
		end
		-- 横幅
		if righttag ~= 0 then
			cell:GetChild("hengfu").icon = "Icon/Pay/" .. righttag
		end
		-- 增加监听事件
		self:SetCellClick(cell, id)
	end
end

function PayPanel:SetCellClick( cell, id )
	cell.data = id
	cell.onClick:Add(function ( eve )
		if GameConst.isAppleIAP then
			PayCtrl:GetInstance():C_Pay(tonumber(eve.sender.data), 3)
		else
			self.model:OnCellClick( eve )
		end
	end)
end

-- 更改数字字体
function PayPanel:ChangeNumFont( cell, id )
	local getText = cell:GetChild("canGet"):GetChild("title")
	getText.autoSize = FairyGUI.AutoSizeType.Shrink
	getText.singleLine = true
	getText.align = FairyGUI.AlignType.Center
	getText.verticalAlign = FairyGUI.VertAlignType.Middle
	local tf = getText.textFormat
	tf.font = UIPackage.GetItemURL("Common" , "num_10")
	getText.textFormat = tf
	getText.text = self.model:GetPriceByPayItem(id, PayConst.GetType.Gold)
end

-- 月卡每天赠送元宝数
function PayPanel:GetMonthYB()
	return GetCfgData("constant"):Get(26).value
end

-- 读表
function PayPanel:GetCfgData( id )
	return GetCfgData("charge"):Get(tonumber(id))
end

-- 布局UI
function PayPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
	
end

-- Dispose use PayPanel obj:Destroy()
function PayPanel:__delete()
	self.model = nil
	self.isInited = false
	FirstRechargeModel:GetInstance():ClosePopPanel( true )
	GlobalDispatcher:RemoveEventListener(self.handler)
end