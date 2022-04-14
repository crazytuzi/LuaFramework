--
-- @Author: chk
-- @Date:   2019-01-03 22:31:47
--
FactionWareItemSettor = FactionWareItemSettor or class("FactionWareItemSettor",BaseBagIconSettor)
local FactionWareItemSettor = FactionWareItemSettor

function FactionWareItemSettor:ctor(_obj)
	self.transform = _obj.transform
	self.gameObject = self.transform.gameObject
	self.transform_find = self.transform.Find
	--self.MgrStatusSelect = false
	--self.model = FactionModel.GetInstance()
	--self.is_select = false
	--self.events = {}
	--self.globalEvents = {}
	self:InitUI()
end

function FactionWareItemSettor:dctor()
	--self:InitItem()
	
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
	self.events = {}
	
	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
end

function FactionWareItemSettor:InitUI()
	self.is_loaded = true
	self:LoadCallBack()
end

function FactionWareItemSettor:AddEvent()
	
	FactionWareItemSettor.super.AddEvent(self)
	AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
	
	--self.events[#self.events+1] = self.model:AddListener(FactionEvent.EquipDetailInfo,handler(self,self.DealEquipDetail))
	--self.events[#self.events+1] = self.model:AddListener(FactionEvent.QuitManagerWare,handler(self,self.DealQuitMangerWare))
	--self.events[#self.events+1] = self.model:AddListener(FactionEvent.LoadWareItem,handler(self,self.DealWareInfo))
	--self.events[#self.events+1] = self.model:AddListener(FactionEvent.AddWareItem,handler(self,self.AddItem))
	--self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(FactionEvent.DestroyEquipSucess,handler(self,self.DealDelItem))
end

--function FactionWareItemSettor:ClickItem(uid)
	----if FactionModel:GetInstance().isMgrStatus then
			----if self.uid == uid then
				----self.is_select = not self.is_select
				------self.MgrStatusSelect = not self.MgrStatusSelect
				----SetVisible(self.selectBg,self.is_select)
			----end
			----if self.selectItemCB ~= nil then
				----self.selectItemCB(self.uid,self.is_select)
			----end
		------end
		----return
	----end
	----self:SetSelected(self.uid==uid)
	----if self.uid ~= "0" and self.uid ~= nil then
	----	self.is_select = not self.is_select
	----	SetVisible(self.bg1,self.is_select)
	----	if self.selectItemCB ~= nil then
	----		self.selectItemCB(self.uid,self.is_select)
	----	end
	----end

--end



function FactionWareItemSettor:DealMultySelect(bagId)
	if self.bag == bagId and self.gameObject.activeInHierarchy then
		self.is_multy_selet = true
		--self.MgrStatusSelect = false
		self.is_select = false
		self:SetSelected(self.is_select)
	end
end

function FactionWareItemSettor:DealSingleSelect(bagId)
	if self.bag == bagId then
		self.is_multy_selet = false
		self.is_select = false
		--self.MgrStatusSelect = false
		self:SetSelected(self.is_select)
		self.selectItemCB(self.uid, self.is_select)
	end
end




function FactionWareItemSettor:DealDelItem(uid)
	if self.uid == uid then
		self:DelItem(self.bag,uid)
	end
end


function FactionWareItemSettor:DealWareInfo()
	local idx = self.__item_index + self.model.spanIdx
	self:LoadItem(idx)
end

--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function FactionWareItemSettor:DealGoodsDetailInfo(...)

	if not self.gameObject.activeInHierarchy then
		return
	end
	
	local param = { ... }
	local item = param[1]
	if item.uid ~= self.uid then
		return
	end
	
	local operate_param = {}
	if Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
		GoodsTipController.Instance:SetExchangeCB(operate_param,
			handler(self,self.RequestExchange),{item})

		--第1个参数 请求物品的返回的p_item 必传
		--第2个参数 对请求的物品的操作参数
		--第3个参数 身上穿的,装备的
		
		FactionWareItemSettor.super.DealGoodsDetailInfo(self,item,operate_param,param[3])
		
	end


end


--function FactionWareItemSettor:DealQuitMangerWare()
--	self.is_select = false
--	SetVisible(self.bg1,self.is_select)
--	if self.selectItemCB ~= nil then
--		self.selectItemCB(self.uid,self.is_select)
--	end
--end

function FactionWareItemSettor:LoadItemInfoByBgId(id)
	if self.__item_index ~= 1 then
		FactionWareItemSettor.super.LoadItemInfoByBgId(self,id)
	end
end

function FactionWareItemSettor:RequestExchange(call_back_param)
	FactionWareController.Instance:RequestExchEquip(call_back_param[1].uid)
end
