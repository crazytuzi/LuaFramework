--
-- @Author: chk
-- @Date:   2019-01-01 14:14:45
--
FactionExchangePanel = FactionExchangePanel or class("FactionExchangePanel",BasePanel)
local FactionExchangePanel = FactionExchangePanel

function FactionExchangePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionExchangePanel"
	self.layer = "UI"

	 self.use_background = true
	-- self.change_scene_close = true

	self.iconSettor = nil
	self.canExchangeNum = 0
	self.exchangeNum = 1
	self.maxNum = 0
	self.item_id = 0
	self.events = {}
	self.model = FactionModel:GetInstance()
end

function FactionExchangePanel:dctor()
	if self.keyboardView ~= nil then
		self.keyboardView:Close()
	end

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	if self.iconSettor then
		self.iconSettor:destroy()
	end
	self.iconSettor = nil

end

function FactionExchangePanel:Open( itemId)
	self.item_id = itemId
	FactionExchangePanel.super.Open(self)
end

function FactionExchangePanel:LoadCallBack()
	self.nodes = {
		"icon",
		"nameTxt",
		"cost/cost_value",
		"exchange/minusBtn",
		"exchange/plusBtn",
		"exchange/keyBtn",
		"exchange/countBG/count",
		"integral/integral",
		"keyboardCon",
		"comformBtn",
		"CloseBtn",
	}
	self:GetChildren(self.nodes)
	self.countTxt = self.count:GetComponent('Text')
	self.excBuyCfg = self.model:GetExcBuyCfg(self.item_id)
	self:AddEvent()

	local param = {}
	param["model"] = self.model
	param["item_id"] = self.item_id
	self.iconSettor = GoodsIconSettorTwo(self.icon)
	self.iconSettor:SetIcon(param)
	local itemCfg = Config.db_item[self.item_id]
	GetText(self.nameTxt).text = string.format("<color=#%s>%s</color>",
			ColorUtil.GetColor(itemCfg.color), itemCfg.name)

	GetText(self.cost_value).text = self.excBuyCfg.score
end

function FactionExchangePanel:AddEvent()
	local function call_back()
		self:Close()
	end
	AddClickEvent(self.CloseBtn.gameObject,call_back)
	local function call_back(target,x,y)
		FactionWareController.GetInstance():RequestExchBuy(self.item_id,self.exchangeNum)
	end
	AddClickEvent(self.comformBtn.gameObject,call_back)


	local function call_back(target,x,y)
		if self.exchangeNum > 1 then
			self.exchangeNum = self.exchangeNum - 1
			self.countTxt.text = self.exchangeNum .. ""
		end
	end
	AddClickEvent(self.minusBtn.gameObject,call_back)


	local function call_back(target,x,y)
		if self.exchangeNum < self.canExchangeNum then
			self.exchangeNum = self.exchangeNum + 1
			self.countTxt.text = self.exchangeNum .. ""
		end
	end
	AddClickEvent(self.plusBtn.gameObject,call_back)


	local function call_back(target,x,y)
		--if self.keyboardView == nil then
			self.keyboardView = lua_panelMgr:GetPanelOrCreate(NumKeyPad,self.countTxt,nil,
					handler(self,self.SetNum),handler(self,self.SetNum),handler(self,self.SetNum),-104,-43)
			self.keyboardView:Open()
		--else
		--	SetVisible(self.keyboardView.transform.gameObject,not self.keyboardView.gameObject.activeSelf)
		--end
	end
	AddClickEvent(self.keyBtn.gameObject,call_back)

	self.events[#self.events+1] = self.model:AddListener(FactionEvent.ExchangeSucess,handler(self,self.DealExchangeSucess))
end

function FactionExchangePanel:OpenCallBack()
	self:UpdateView()
end

function FactionExchangePanel:DealExchangeSucess()
	self:UpdateView()
end

function FactionExchangePanel:UpdateView( )
	GetText(self.integral).text = tostring(self.model.wareInfo.score)


	self.canExchangeNum = math.floor(self.model.wareInfo.score / self.excBuyCfg.score)
end

function FactionExchangePanel:CloseCallBack(  )

end

function FactionExchangePanel:SetNum()
	if self.countTxt.text == "" then
		self.countTxt.text = "1"
		self.exchangeNum = 1
	else
		self.exchangeNum = tonumber(self.countTxt.text)
		if self.exchangeNum > self.canExchangeNum then
			self.exchangeNum = self.canExchangeNum
		end

		self.countTxt.text = self.exchangeNum .. ""
	end
end