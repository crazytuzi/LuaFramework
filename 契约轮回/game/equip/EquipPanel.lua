--
-- @Author: chk
-- @Date:   2018-08-30 19:06:17
--
EquipPanel = EquipPanel or class("EquipPanel",BasePanel)
local EquipPanel = EquipPanel

function EquipPanel:ctor()
	self.abName = "equip"
	self.assetName = "EquipPanel"
	self.layer = "UI"

	self.events = {}
	--self.click_bg_close = true
	--self.use_background = true
	self.change_scene_close = true

	self.putOnEquipView = nil
	self.outEquipView = nil
	self.model = EquipModel:GetInstance()
end

function EquipPanel:dctor()
	for i, v in pairs(self.events) do
		GlobalEvent:RemoveListener(v)
	end

	self.events = {}

	if self.putOnEquipView ~= nil then
		self.putOnEquipView:destroy()
	end	
	self.putOnEquipView = nil

	if self.outEquipView ~= nil then
		self.outEquipView:destroy()
	end	
	self.outEquipView = nil

	self.model:ClearData()

	if self.delete_scheld_id ~= nil then
		GlobalSchedule:Stop(self.delete_scheld_id)
	end
end

function EquipPanel:Open( )
	EquipPanel.super.Open(self)
end

function EquipPanel:LoadCallBack()
	self.nodes = {
		"mask",
		"comPanelContain",
		"normalPanelContain",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()

	local equipCfg = nil
	self.outEquipView = EquipDetailView(self.normalPanelContain)
	if self.model.outEquipItem ~= nil then
		equipCfg = Config.db_equip[self.model.outEquipItem.id]
		self.outEquipView:UpdateInfo(self.model.outEquipItem,true)
	elseif self.model.outEquipItemId ~= nil then
		equipCfg = Config.db_equip[self.model.outEquipItemId]
		self.outEquipView:UpdateInfoByEquipId(self.model.outEquipItemId,true)
	end


	self.putOnEquipView = EquipDetailView(self.comPanelContain)
	self.putOnEquipView:UpdateInfo(self.model.putOnedEquipDetailList[equipCfg.slot],true)
end

function EquipPanel:AddEvent()
	--self.events[#self.events+1] = GoodsEvent:AddListener(GoodsEvent.GoodsDetail,handler(self,self.DealGoodsDetailInfo))
	self.events[#self.events+1] = GlobalEvent:AddListener(EquipEvent.PutOnEquipSucess,handler(self,self.DealPutOnEquipSucess))
	self.events[#self.events+1] = GlobalEvent:AddListener(GoodsEvent.SellItems,handler(self,self.DealGoodsSell))
	self.events[#self.events+1] = GlobalEvent:AddListener(GoodsEvent.DelItems,handler(self,self.DealDelItems))
	self.events[#self.events+1] = GlobalEvent:AddListener(FactionEvent.DestroyEquipSucess,handler(self,self.DealDestroyEquip))
	self.events[#self.events+1] = GlobalEvent:AddListener(EquipEvent.BrocastSetViewPosition,handler(self,self.DealSetViewPosition))
	--self.update_sched_id = GlobalSchedule:Start(handler(self,self.Update),Time.deltaTime)

	local tcher = self.gameObject:AddComponent(typeof(Toucher))
	tcher:SetClickEvent(handler(self,self.OnTouchenBengin))
end

function EquipPanel:DealSetViewPosition(param)
	self.positionParam = param
end

function EquipPanel:DealDestroyEquip()
	self:Close()
end


function EquipPanel:DealDelItems()
	self:Close()
end

function EquipPanel:DealGoodsSell()
	self:Close()
end

function EquipPanel:DealPutOnEquipSucess()
	self:Close()
end

function EquipPanel:DealGoodsDetailInfo(itemInfo)
	local itemConfig = Config.db_item[itemInfo.id]
	if itemInfo.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
		self.putOnEquipView = EquipDetailView(self.normalPanelContain,"UI")
		self.putOnEquipView:UpdateInfo(itemInfo)
	end	
end

function EquipPanel:DeleteClickClose()
	if self.update_sched_id ~= nil then
		GlobalSchedule:Stop(self.update_sched_id)
		self.update_sched_id = nil
		self:Close()
	end
end

function EquipPanel:OnTouchenBengin(x,y)
	if self.positionParam ~= nil and not (x >= self.positionParam.bg_x and  x <= self.positionParam.xw and
			self.positionParam.yw <= y and self.positionParam.bg_y >= y) then
		self:Close()
	end
end

function EquipPanel:OpenCallBack()
	self:UpdateView()
end

function EquipPanel:Update()
	if Input.GetMouseButtonUp(0) then
		self.delete_scheld_id = GlobalSchedule:StartOnce(handler(self,self.DeleteClickClose),Time.deltaTime)
	elseif Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Ended then
		self.delete_scheld_id = GlobalSchedule:StartOnce(handler(self,self.DeleteClickClose),Time.deltaTime)
	end
end

function EquipPanel:UpdateView( )

end

function EquipPanel:CloseCallBack(  )

end
