PayCheckPanel = BaseClass(LuaUI)
function PayCheckPanel:__init( id )
	self.ui = UIPackage.CreateObject("Pay", "PayCheckPanel");
	self.payListCtrl = self.ui:GetController("payListCtrl")
	self.title = self.ui:GetChild("title")
	self.btnClose = self.ui:GetChild("btnClose")
	self.payNum = self.ui:GetChild("payNum")
	self.getNum = self.ui:GetChild("getNum")
	self.list1 = self.ui:GetChild("list1")
	self.list2 = self.ui:GetChild("list2")
	self.btnPay = self.ui:GetChild("btnPay")

	self.id = id -- 充值货品id
	self.payType = 1 -- 支付类型
	self.price = 0 -- 充值金额
	self.gold = 0 -- 获得元宝

	self:InitEvent()
	self:AddEvent()
end

function PayCheckPanel:InitEvent()
	self.payCtrl = PayCtrl:GetInstance()
	self.model = PayModel:GetInstance()
	self.payNum.title = "充值金额："
	self.getNum.title = "充值元宝："
	self.list1:GetChild("listIcon").icon = "Icon/Pay/type1"
	self.list2:GetChild("listIcon").icon = "Icon/Pay/type2"
	self.list1.title = "支付宝"
	self.list2.title = "微信支付"
end

function PayCheckPanel:AddEvent()
	-- 监听事件
	self.btnClose.onClick:Add(self.OnBtnCloseClick, self)
	self.btnPay.onClick:Add(self.OnBtnPayClick, self)

	-- 选择不同支付方式
	self.payListCtrl.onChanged:Add(function ()
		self.payType = self.payListCtrl.selectedIndex + 1
	end)
end

function PayCheckPanel:SetPayPanel()
	-- 显示数值
	self.payNum:GetChild("num").text = StringFormat("{0}元", self:GetCfgData(self.id).price)
	if self:GetCfgData(self.id).gold and self:GetCfgData(self.id).gold ~= 0 then
		self.getNum:GetChild("num").text = StringFormat("{0}元宝", self:GetCfgData(self.id).gold)
	else
		self.getNum:GetChild("num").visible = false
		self.getNum.visible = false
	end
end

-- 读表
function PayCheckPanel:GetCfgData( id )
	return GetCfgData("charge"):Get(tonumber(id))
end

-- 点击支付
function PayCheckPanel:OnBtnPayClick()
	self.payCtrl:C_Pay(tonumber(self.id), self.payType)
	self:Destroy()
end

-- 点击关闭
function PayCheckPanel:OnBtnCloseClick()
	UIMgr.HidePopup()
end

-- Dispose use PayCheckPanel obj:Destroy()
function PayCheckPanel:__delete()
	self.payType = 0
	self.payCtrl = nil
	self.model = nil
	GlobalDispatcher:DispatchEvent(EventName.PLAYER_MODEL)
end