FairyUseItem = FairyUseItem or class("FairyUseItem",BaseItem)
local FairyUseItem = FairyUseItem

function FairyUseItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "FairyUseItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	FairyUseItem.super.Load(self)
	self.use_type = 1
	self.events = {}
end

function FairyUseItem:dctor()
	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil
	end
	self.pitembase = nil
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	GlobalEvent:RemoveTabListener(self.events)
	self.events = nil
	if self.uieffect then
		self.uieffect:destroy()
		self.uieffect = nil
	end
end

function FairyUseItem:LoadCallBack()
	self.nodes = {
		"buyBtn", "bg", "closeBtn", "icon", "Text", "buyBtn/buyLabel", "itemName"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.buyLabel = GetText(self.buyLabel)
	self.itemName = GetText(self.itemName)
	self.Text = GetText(self.Text)
	SetVisible(self.Text, true)
	self:UpdateView()
end

function FairyUseItem:AddEvent()
	local function call_back(target,x,y)
		if self.use_type == 1 then
			EquipController:GetInstance():RequestPutOnEquip(self.pitembase.uid)
		else
			lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(2, 2, self.data, true)
		end
		self:destroy()
	end
	AddButtonEvent(self.buyBtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:destroy()
	end
	AddButtonEvent(self.closeBtn.gameObject,call_back)
	self.schedule_id = GlobalSchedule:StartOnce(call_back, 15)

	local function call_back()
		self:destroy()
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)

	local function call_back()
		self:destroy()
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(EventName.GameReset, call_back)
end

--data:itemid
function FairyUseItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end 
end

function FairyUseItem:UpdateView()
	if self.data then
		local itemcfg = Config.db_item[self.data]
		local equiplist = BagController.GetInstance():GetEquipList(self.data)
		if itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
			local equiplist2 = BagController.GetInstance():GetEquipList(11020147)
			table.insertto(equiplist, equiplist2, 0)
		end
		local pitembase = self:GetAvalibleItem(equiplist)
		self.pitembase = pitembase
		if pitembase then
			self.use_type = 1
			self.buyLabel.text = "Equip"
		else
			self.use_type = 2
			self.buyLabel.text = "Buy"
		end
		local param = {}
		param["item_id"] = self.data
		param["can_click"] = true

		self.goodsitem = GoodsIconSettorTwo(self.icon)
		self.goodsitem:SetIcon(param)

		self.itemName.text = itemcfg.name
		if itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_FAIRY then
			self.Text.text = "EXP +50%"
		else
			self.Text.text = "Damage Reduction +25%"
		end

		local x = ScreenWidth - 400
		local y = -ScreenHeight + 353
		self.itemRectTra.anchoredPosition = Vector2(x,y)
		if not self.uieffect then
			self.uieffect = UIEffect(self.buyBtn, 10121)
		end
	end
end

function FairyUseItem:GetAvalibleItem(itemlist)
	for i=1, #itemlist do
		local pitembase = itemlist[i]
		if pitembase and not BagModel.GetInstance():IsExpire(pitembase.etime) then
			return pitembase
		end
	end
	return nil
end