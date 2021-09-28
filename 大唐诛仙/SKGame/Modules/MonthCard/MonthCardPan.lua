-- 福利界面月卡panel
MonthCardPan = BaseClass(LuaUI)
function MonthCardPan:__init( ... )
	self.URL = "ui://7gr86wlkiqif6"
	self:__property(...)

	self:Config()
	self:InitEvent()
	self:RefreshUI()
end

function MonthCardPan:InitEvent()
	self.btn_buy.onClick:Add(self.OnBuyClick, self)

	local function OnInfoChange()
		self:RefreshUI()
	end
	self._hInfoChange = self.model:AddEventListener(MonthCardConst.E_CARDINFO_CHANGE, OnInfoChange)
end

function MonthCardPan:OnBuyClick()
	if self.state == MonthCardConst.STATE.NOT_ACTIVE then
		MallController:GetInstance():OpenMallPanel(0, 2)
	elseif self.state == MonthCardConst.STATE.CAN_GET then
		MonthCardController:GetInstance():C_GetMonthCardAward()
	end
end

-- Set self property
function MonthCardPan:SetProperty( ... )
end

-- start
function MonthCardPan:Config()
	self.model = MonthCardModel:GetInstance()
end

-- wrap UI to lua
function MonthCardPan:RegistUI( ui )
	resMgr:AddUIAB("MonthCard")
	self.ui = ui or self.ui or UIPackage.CreateObject("MonthCard","MonthCardPan")

	self.btn_buy = self.ui:GetChild("btn")
	self.txt_days = self.ui:GetChild("n6")
	self.img_icon = self.ui:GetChild("n7")
end

-- Combining existing UI generates a class
function MonthCardPan.Create( ui, ...)
	return MonthCardPan.New(ui, "#", {...})
end

function MonthCardPan:__delete()
	self:RemoveEvents()
end

function MonthCardPan:RemoveEvents()
	self.btn_buy.onClick:Remove(self.OnBuyClick, self)
	if self.model then
		self.model:RemoveEventListener(self._hInfoChange)
	end
end

function MonthCardPan:RefreshUI()
	self.state = self.model:GetState()
	self:RefreshBtn()
	self:RefreshTxt()
end

function MonthCardPan:RefreshBtn()
	if self.state == MonthCardConst.STATE.NOT_ACTIVE then
		self.btn_buy.grayed = false
		self.btn_buy.touchable = true
		self.img_icon.icon = MonthCardConst.URL_GOUMAI
		self.txt_days.visible = false
	elseif self.state == MonthCardConst.STATE.CAN_GET then
		self.btn_buy.grayed = false
		self.btn_buy.touchable = true
		self.img_icon.icon = MonthCardConst.URL_LINGQU
		self.txt_days.visible = true
	else
		self.btn_buy.grayed = true
		self.btn_buy.touchable = false
		self.img_icon.icon = MonthCardConst.URL_YILINGQU
		self.txt_days.visible = true
	end
end

function MonthCardPan:RefreshTxt()
	local days = self.model:GetLeftDays()
	local str = string.format(MonthCardConst.TXT_LEFT_DAYS, days)
	self.txt_days.text = str
end