require "Core.Module.Common.Panel"
require "Core.Module.Compose.View.Item.ComposeTypeItem"

ComposePanel = Panel:New()

function ComposePanel:_Init()
  	self:_InitReference();
  	self:_InitListener();
end

function ComposePanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

    self._scrollView = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "trsList");
    self._typeTable = UIUtil.GetChildByName(self._trsContent, "UITable", "trsList/Table");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trsList/Table");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, ComposeTypeItem);

    self._infoPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "infoPanel");
	self._txtNoItem = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNoItem");
	self._txtNoItem.gameObject:SetActive(false);

	self._trsItem1 = UIUtil.GetChildByName(self._infoPanel, "Transform", "trsItem1");
	self._item1 = PropsItem:New();
	self._itemGo1 = UIUtil.GetUIGameObject(ResID.UI_PropsItem);
	UIUtil.AddChild(self._trsItem1, self._itemGo1.transform);
	self._item1:Init(self._itemGo1, nil);

	self._trsItem2 = UIUtil.GetChildByName(self._infoPanel, "Transform", "trsItem2");
	self._item2 = PropsItem:New();
	self._itemGo2 = UIUtil.GetUIGameObject(ResID.UI_PropsItem);
	UIUtil.AddChild(self._trsItem2, self._itemGo2.transform);
	self._item2:Init(self._itemGo2, nil);

	self._txtNeedNum = UIUtil.GetChildByName(self._infoPanel, "UILabel", "txtNeedNum");
	self._txtToNum = UIUtil.GetChildByName(self._infoPanel, "UILabel", "txtToNum");
	self._txtItemName1 = UIUtil.GetChildByName(self._infoPanel, "UILabel", "txtItemName1");
	self._txtItemName2 = UIUtil.GetChildByName(self._infoPanel, "UILabel", "txtItemName2");

	self._trsCtrl = UIUtil.GetChildByName(self._infoPanel, "Transform", "trsCtrl");
    self._txtNum = UIUtil.GetChildByName(self._trsCtrl, "UILabel", "txtNum");
    self._btnA1 = UIUtil.GetChildByName(self._trsCtrl, "UIButton", "btnA1");
    self._btnA2 = UIUtil.GetChildByName(self._trsCtrl, "UIButton", "btnA2");
    self._btnB1 = UIUtil.GetChildByName(self._trsCtrl, "UIButton", "btnB1");
    self._btnB2 = UIUtil.GetChildByName(self._trsCtrl, "UIButton", "btnB2");

    self._txtCost = UIUtil.GetChildByName(self._infoPanel, "UILabel", "txtCost");
    self._icoCost = UIUtil.GetChildByName(self._txtCost, "UISprite", "icoCost");

    self._btnCompose = UIUtil.GetChildByName(self._infoPanel, "UIButton", "btnCompose");
    self._btnAllCompose = UIUtil.GetChildByName(self._infoPanel, "UIButton", "btnAllCompose");
    
end

function ComposePanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
  	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	
  	self._onClickBtnComp = function(go) self:_OnClickBtnComp(self) end
	UIUtil.GetComponent(self._btnCompose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComp);
    self._onClickBtnAllComp = function(go) self:_OnClickBtnAllComp(self) end
	UIUtil.GetComponent(self._btnAllCompose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAllComp);

	self._onClickBtnA = function(go) self:_OnClickBtnMin(self) end
	UIUtil.GetComponent(self._btnA2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnA);
    self._onClickBtnB = function(go) self:_OnClickBtnReduce(self) end
	UIUtil.GetComponent(self._btnA1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnB);
    self._onClickBtnC = function(go) self:_OnClickBtnAdd(self) end
	UIUtil.GetComponent(self._btnB1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnC);
    self._onClickBtnD = function(go) self:_OnClickBtnMax(self) end
	UIUtil.GetComponent(self._btnB2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnD);

	self._onClickInput = function(go) self:_OnClickInput(self) end
    UIUtil.GetComponent(self._txtNum, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickInput);

	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, ComposePanel.OnBagChange, self);
	MessageManager.AddListener(ComposeNotes, ComposeNotes.ENV_COMPOSE_TYPE_CHG, ComposePanel.OnTypeChange, self);
	MessageManager.AddListener(ComposeNotes, ComposeNotes.ENV_COMPOSE_ITEM_CHG, ComposePanel.OnItemChange, self);
	

end

function ComposePanel:_Dispose()	
  	self:_DisposeListener();
  	self:_DisposeReference();
end

function ComposePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

	UIUtil.GetComponent(self._btnCompose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnComp = nil;
    UIUtil.GetComponent(self._btnAllCompose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAllComp = nil;
    UIUtil.GetComponent(self._btnA2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnA1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnB1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnB2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnA = nil;
    self._onClickBtnB = nil;
    self._onClickBtnC = nil;
    self._onClickBtnD = nil;

    UIUtil.GetComponent(self._txtNum, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickInput = nil;

    MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, ComposePanel.OnBagChange);
    MessageManager.RemoveListener(ComposeNotes, ComposeNotes.ENV_COMPOSE_TYPE_CHG, ComposePanel.OnTypeChange);
    MessageManager.RemoveListener(ComposeNotes, ComposeNotes.ENV_COMPOSE_ITEM_CHG, ComposePanel.OnItemChange);

end

function ComposePanel:_DisposeReference()
	self._phalanx:Dispose();
	self._item1:Dispose();
    self._item2:Dispose();

    if self._itemGo1 then
    	Resourcer.Recycle(self._itemGo1, true);
    end

    if self._itemGo2 then
    	Resourcer.Recycle(self._itemGo2, true);
    end
end

function ComposePanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ComposeNotes.CLOSE_COMPOSE_PANEL);
end

function ComposePanel:_OnClickBtnComp()
	if self.selectItem then
		local count = BackpackDataManager.GetProductTotalNumBySpid(self.needItemId);
		if count < self.compNeedNum then
			MsgUtils.ShowTips("compose/noEnough/-1");
			return;
		end

		local needMoney = self.compPrice * self.compNum;
		if MoneyDataManager.Get_money() >= needMoney then            
            ComposeProxy.ReqCompose(self.selectItem.target, self.compNum);
        else
            ProductGetProxy.TryShowGetUI(1, ComposeNotes.CLOSE_COMPOSE_PANEL);
            MsgUtils.ShowTips("common/lingshibuzu");
        end
		
	end
end

function ComposePanel:_OnClickBtnAllComp()
	if self.selectItem then
		local count = BackpackDataManager.GetProductTotalNumBySpid(self.needItemId);
		if count < self.compPerNum then
			MsgUtils.ShowTips("compose/noEnough/-1");
			return;
		end


		ComposeProxy.ReqCompose(self.selectItem.target, -1);
	end
end

function ComposePanel:Update(pId)
	local param = nil;
	if pId then
		param = ComposeManager.GetCfgByProductId(pId);
	end
    
    self:UpdateDisplay(param);
end

function ComposePanel:UpdateDisplay(param)
	self.showTypes = ComposeManager.GetTypes();

	local count = #self.showTypes;
    self._phalanx:Build(count, 1, self.showTypes);

	--有默认值时找到该显示的分类
	local defType = nil;
	local defItem = param;
	if defItem then
		local items = nil;
		local isEnd = false;
		for i,v in ipairs(self.showTypes) do
			items = ComposeManager.GetListByType(v);
			for idx,cfg in ipairs(items) do
				if cfg == defItem then
					defType = v
					isEnd = true;
					break;
				end
			end
			if isEnd then 
				break;
			end
		end
	end
	if defType == nil then
		defType = self.showTypes[1];
		defItem = ComposeManager.GetListByType(defType)[1];
	end

	self:SetDefault(defType, defItem);

	self:UpdateRedPoint();
	
	self._typeTable.repositionNow = true;
end

function ComposePanel:SetDefault(t, val)

	self.selectType = t;
	local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:SetExpand(item.data == t);
        item:SetItemSelect(val);
    end

    self:SetSelectItems(val);

end

function ComposePanel:SetSelectItems(data)
	if self.selectItem ~= data then
		self.selectItem = data;
	    self:UpdateDetail();
	end
end

function ComposePanel:UpdateDetail()
	if self.selectItem then
		self._infoPanel.gameObject:SetActive(true);
		self._txtNoItem.gameObject:SetActive(false);
		local cfg = self.selectItem;

		local demand = cfg.demand_item;
		demand = string.split(demand, "_");
		local dId = tonumber(demand[1]);
		local dNum = tonumber(demand[2]);
		local d1 = ProductInfo:New();
        d1:Init({spId = dId, am = 1});
        self._item1:UpdateItem(d1);

        local d2 = ProductInfo:New();
        d2:Init({spId = cfg.target, am = 1});
        self._item2:UpdateItem(d2);

        self._txtItemName1.text = LanguageMgr.GetColor(d1:GetQuality(), d1:GetName());
        self._txtItemName2.text = LanguageMgr.GetColor(d2:GetQuality(), d2:GetName());

        self.needItemId = dId;
        self.compPerNum = dNum;

        --设置货币与单价.
        local price = cfg.demand_cost;
        price = string.split(price, "_");
        local moneyId = tonumber(price[1]);
        local moneyCfg = ConfigManager.GetProductById(moneyId);
        ProductManager.SetIconSprite(self._icoCost, moneyCfg.icon_id);
        --self._icoCost:MakePixelPerfect();

        self.compPrice = tonumber(price[2]);
        self:SetNum(1);
	else
		self._infoPanel.gameObject:SetActive(false);
		self._txtNoItem.gameObject:SetActive(true);
	end
end

function ComposePanel:OnBagChange()
	self:UpdateDetail();
	self:UpdateRedPoint();
end

function ComposePanel:OnTypeChange(val)
	local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        if item.data ~= val then
        	item:SetExpand(false);
        end
    end
    self.selectType = val;
    self._scrollView:ResetPosition();
	self._typeTable.repositionNow = true;
end

function ComposePanel:OnItemChange(val)
	local items = self._phalanx:GetItems();
	for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:SetItemSelect(val);
    end
	self:SetSelectItems(val);
end

function ComposePanel:SetNum(val)
	if self.selectItem then
		self.compNum = val;
		local count = BackpackDataManager.GetProductTotalNumBySpid(self.needItemId);
		local needNum = val * self.compPerNum;
		self.compMaxNum = math.floor(count / self.compPerNum);
		self.compNeedNum = needNum;

		if (count >= needNum) then
		    self._txtNeedNum.text = LanguageMgr.GetColor(1, count .. "/" .. needNum);
		else
		    self._txtNeedNum.text =  LanguageMgr.GetColor(6, count .. "/" .. needNum);
		end

		self._txtNum.text = val;
		self._txtToNum.text = val;
		self._txtCost.text = val * self.compPrice;
	else
		self.compNum = 1;
		self.compMaxNum = 1;
		self._txtNum.text = "1";
		self._txtNeedNum.text = "";
		self._txtCost = "";
		self._txtToNum.text = "";
	end
end


function ComposePanel:_OnClickBtnMin() 
    self:SetNum(1);
end

function ComposePanel:_OnClickBtnReduce()
    local val = math.max(self.compNum - 1, 1);
    self:SetNum(val);
end 

function ComposePanel:_OnClickBtnAdd()
    if(self.compNum + 1 > self.compMaxNum) then
        return;
    end
    local val = math.max(self.compNum + 1);
    self:SetNum(val);
end

function ComposePanel:_OnClickBtnMax()
    self:SetNum(math.max(self.compMaxNum, 1));
end

function ComposePanel:_OnClickInput()
	local res = { };
    res.hd = ComposePanel.ConfirmInput;
    res.confirmHandler = ComposePanel.ConfirmInput;
    res.hd_target = self;
    res.x = 0;
    res.y = 130;
    ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function ComposePanel:ConfirmInput(val)
	val = tonumber(val);
	if val == 0 then
		val = 1;
	end
	self:SetNum(val);
end

function ComposePanel:UpdateRedPoint()
	local items = self._phalanx:GetItems();
	for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:UpdateRedPoint();
    end
end