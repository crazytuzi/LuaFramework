CoinBar = class("CoinBar")

function CoinBar:New(transform)
	self = {};
	setmetatable(self, {__index = CoinBar});
	self:Init(transform)
	return self;
end

function CoinBar:Init(transform)
	local txts = UIUtil.GetComponentsInChildren(transform, "UILabel")
	self._txtLingshi = UIUtil.GetChildInComponents(txts, "txtLingshi")
	self._txtXianyu = UIUtil.GetChildInComponents(txts, "txtXianyu")
	self._txtBangdingxianyu = UIUtil.GetChildInComponents(txts, "txtBangdingxianyu")
	
	self.btn_add1 = UIUtil.GetChildByName(transform, "UIButton", "btn_add1");
	self.btn_add2 = UIUtil.GetChildByName(transform, "UIButton", "btn_add2");
	self.btn_add3 = UIUtil.GetChildByName(transform, "UIButton", "btn_add3");
	
	if(self.btn_add1) then
		self._onClickBtn_add1 = function(go) self:_OnClickBtn_add1(self) end
		UIUtil.GetComponent(self.btn_add1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_add1);
	end
	
	if(self.btn_add2) then
		self._onClickBtn_add2 = function(go) self:_OnClickBtn_add2(self) end
		UIUtil.GetComponent(self.btn_add2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_add2);
	end
	
	if(self.btn_add3) then
		self._onClickBtn_add3 = function(go) self:_OnClickBtn_add3(self) end
		UIUtil.GetComponent(self.btn_add3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_add3);
	end
	
	
	
	self:MoneyChange()
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, CoinBar.MoneyChange, self);
end

function CoinBar:SetUILabel(txtLingshi, txtXianyu, txtBangdingxianyu)
	self._txtLingshi = txtLingshi
	self._txtXianyu = txtXianyu
	self._txtBangdingxianyu = txtBangdingxianyu
	self:MoneyChange()
end

function CoinBar:Dispose()
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, CoinBar.MoneyChange,self)
	
	if(self.btn_add1) then
		UIUtil.GetComponent(self.btn_add1, "LuaUIEventListener"):RemoveDelegate("OnClick");
		self._onClickBtn_add1 = nil;
	end
	
	if(self.btn_add2) then
		UIUtil.GetComponent(self.btn_add2, "LuaUIEventListener"):RemoveDelegate("OnClick");
		self._onClickBtn_add2 = nil;
	end
	
	if(self.btn_add3) then
		UIUtil.GetComponent(self.btn_add3, "LuaUIEventListener"):RemoveDelegate("OnClick");
		self._onClickBtn_add3 = nil;
	end
	
	
	self._txtLingshi = nil
	self._txtXianyu = nil
	self._txtBangdingxianyu = nil
end

function CoinBar:SetGetFunc(fuc1,fuc2,fuc3, clickFuc1, clickFuc2, clickFuc3)
    self.fuc1 = fuc1
    self.fuc2 = fuc2
    self.fuc3 = fuc3
    self.clickFuc1 = clickFuc1
    self.clickFuc2 = clickFuc2
    self.clickFuc3 = clickFuc3
    self:MoneyChange()
end

function CoinBar:MoneyChange()
	if(self._txtLingshi) then
		self._txtLingshi.text = tostring(self.fuc1 and self.fuc1() or MoneyDataManager.Get_money())
	end
	
	if(self._txtBangdingxianyu) then
		self._txtBangdingxianyu.text = tostring(self.fuc2 and self.fuc2() or MoneyDataManager.Get_bgold())
	end
	
	if(self._txtXianyu) then
		self._txtXianyu.text = tostring(self.fuc3 and self.fuc3() or MoneyDataManager.Get_gold())
	end
end

-- ��ʯ
function CoinBar:_OnClickBtn_add1() 
    if self.clickFuc1 then self.clickFuc1() return end
	ModuleManager.SendNotification(MallNotes.SHOW_MONEY_GET_PANEL)
end

-- ����
function CoinBar:_OnClickBtn_add2()
    if self.clickFuc2 then self.clickFuc2() return end
	--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 3})
    ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
end

-- ����
function CoinBar:_OnClickBtn_add3()
    if self.clickFuc3 then self.clickFuc3() return end
	ModuleManager.SendNotification(MallNotes.SHOW_BGOLD_GET_PANEL)
end