WakanCostItem = BaseClass(LuaUI)

WakanCostItem.CurSelectItem = nil
function WakanCostItem:__init(...)
	self.URL = "ui://jh3vd6rkuchhc";
	self:__property(...)
	self:Config()
end

function WakanCostItem:SetProperty(...)
	
end

function WakanCostItem:Config()
	
end

function WakanCostItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wakan","WakanCostItem");

	self.quality = self.ui:GetChild("quality")
	self.select = self.ui:GetChild("select")
	self.icon = self.ui:GetChild("icon")
	self.count = self.ui:GetChild("count")
	self.jia = self.ui:GetChild("jia")
	self.role3D = self.ui:GetChild("role3D")
	self.moveRole3D = self.ui:GetChild("moveRole3D")

	self.preItemId = 0
	self.itemId = 0
	self.selected = false
	self.isInSelectPanel = false
	self.posTweener = nil

	self.eftId = "4105"
	self.moveEftId = "4102"
	self.moveStartPos = Vector2.New(44, 46)

	self.eftIds = {}

	self.isDestroy = false

	self:AddEvent()
	self:Reset()
end

function WakanCostItem.Create(ui, ...)
	return WakanCostItem.New(ui, "#", {...})
end

function WakanCostItem:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)

end

function WakanCostItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)

end

function WakanCostItem:UpdateSelectState()
	if self.jia then
		if self.selected then
			self.jia.visible = false
		else
			self.jia.visible = true
			self.count.text = ""
		end
	end
end

function WakanCostItem:SetViewInPanel(itemId, count)
	self.isInSelectPanel = true
	self.jia.visible = false
	self:SetItem(itemId)
	self:RemoveEvent()
	if count < 2 then
		self.count.text = ""
	else
		self.count.text = count
	end
end

function WakanCostItem:UpdateView()
	if self.isInSelectPanel then
		self.count.text = PkgModel:GetInstance():GetTotalByBid(self.itemId)
	else
		self.count.text = ""
	end
end

function WakanCostItem:AutoSet(itemId)
	self.selected = true

	self:SetItem(itemId)
	self:UpdateSelectState()
end

function WakanCostItem:SetItem(itemId)
	self.preItemId = self.itemId
	self.itemId = itemId
	local cfg = GoodsVo.GetItemCfg(itemId)
	if cfg then
		self.icon.url = StringFormat("Icon/Goods/{0}", cfg.icon)
		self.quality.url = StringFormat("Icon/Common/grid_cell_{0}", cfg.rare)
		self:UpdateView()
	else
		self.icon.url = ""
		self.quality.url = StringFormat("Icon/Common/grid_cell_1")
	end
end

function WakanCostItem:Reset(playEft, flyTargetPos, needReset)
	if playEft then
		if self.itemId ~= 0 then
			local eftId = EffectMgr.AddToUI(self.eftId, self.role3D, 0.3, pos, scale, eulerAngles, id, function(eft)
					if self.isDestroy then return end
					if needReset then
						self:ExcuteReset()
					end
					self:EftFly(flyTargetPos)
				end)
			self:AddEftId(eftId)
		end
	else
		self:ExcuteReset()
	end
end

function WakanCostItem:EftFly(flyTargetPos)
	self.moveRole3D.x = self.moveStartPos.x
	self.moveRole3D.y = self.moveStartPos.y
	self.moveRole3D.visible = true
	local targetPos = self.ui:GlobalToLocal(flyTargetPos)
	local eftId = EffectMgr.AddToUI(self.moveEftId, self.moveRole3D, nil, pos, scale, eulerAngles, id, function(eft)
			if self.isDestroy then return end
			if self.posTweener  then
				TweenUtils.Kill(self.posTweener, true)
				self.posTweener = nil
			end
			self.posTweener = TweenUtils.TweenVector2(self.moveStartPos, targetPos, 0.5, function(data)
				self.moveRole3D.x = data.x
				self.moveRole3D.y = data.y
			end)
			TweenUtils.SetEase(self.posTweener, 21)
			TweenUtils.OnComplete(self.posTweener, function ()
				if self.moveRole3D then
					self.moveRole3D.visible = false
				end 
			end, self.posTweener)
		end)
	self:AddEftId(eftId)
end

function WakanCostItem:AddEftId(eftId)
	table.insert(self.eftIds, eftId)
end

function WakanCostItem:ClearEft()
	for i = 1, #self.eftIds do
		EffectMgr.RealseEffect(self.eftIds[i])
	end
	self.eftIds = nil
end

function WakanCostItem:ExcuteReset()
	if self.isDestroy then return end
	self.itemId = 0
	self.selected = false
	self.isInSelectPanel = false

	self:UnSelect()
	self:SetItem(0)
	self:UpdateSelectState()

end

function WakanCostItem:OnClickHandler()
	if self.isInSelectPanel then return end
	if WakanCostItem.CurSelectItem then
		WakanCostItem.CurSelectItem:UnSelect()
	end
	self:Select()
	if WakanModel:GetInstance():HasCostItem() then
	 	WakanController:GetInstance().view:GetWakanPanel():ShowSelectPanel(self, function(data)
	 		self:SetItem(data)
			self:UpdateSelectState()
			if data ~= 0 then
				WakanController:GetInstance().view:GetWakanPanel():CheckExchange(self)
			else
				self:Reset()
			end
	 	end)
	else
		UIMgr.Win_Confirm("温馨提示", "注灵石不足，是否前往购买？", "确定", "取消", function()--确定
			MallController:GetInstance():OpenMallPanel(nil, 0, 2)				
		end,
		function()	--取消
		
		end)		
	end
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

function WakanCostItem:Select()
	self.selected = true
	if self.select then
		self.select.visible = true
	end
	WakanCostItem.CurSelectItem = self
end

function WakanCostItem:UnSelect()
	if self.select then
		self.select.visible = false
	end
end

function WakanCostItem:__delete()
	self.isDestroy = true
	self:RemoveEvent()
	if self.posTweener  then
		TweenUtils.Kill(self.posTweener, true)
		self.posTweener = nil
	end
	self.quality = nil
	self.select = nil
	self.white = nil
	self.yellow = nil
	self.blue = nil
	self.green = nil
	self.purple = nil
	self.select_2 = nil
	self.icon = nil
	self.count = nil

	self:ClearEft()
end