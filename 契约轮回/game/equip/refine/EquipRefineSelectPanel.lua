EquipRefineSelectPanel = EquipRefineSelectPanel or class("EquipRefineSelectPanel",BasePanel)
local EquipRefineSelectPanel = EquipRefineSelectPanel

function EquipRefineSelectPanel:ctor()
	self.abName = "equip"
	self.assetName = "EquipRefineSelectPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.item_list = {}
	self.events = {}
	self.model = EquipRefineModel:GetInstance()
end

function EquipRefineSelectPanel:dctor()

end

function EquipRefineSelectPanel:Open( )
	EquipRefineSelectPanel.super.Open(self)
end

function EquipRefineSelectPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","takeoffbtn","ScrollView/Viewport/Content/EquipRefineSelectItem",
		"takeoffbtn/Text",
	}
	self:GetChildren(self.nodes)
	self.Text = GetText(self.Text)
	self.EquipRefineSelectItem_go = self.EquipRefineSelectItem.gameObject
	SetVisible(self.EquipRefineSelectItem_go, false)
	self.takeoffbtn_btn = GetButton(self.takeoffbtn)
	self:AddEvent()

	SetColor(self.background_img, 0, 0, 0, 0)
end

function EquipRefineSelectPanel:AddEvent()
	local function call_back(target,x,y)
		self.model.select_itemid = 0
		self.model:Brocast(EquipEvent.SelectRefineMateria, 0)
	end
	AddClickEvent(self.takeoffbtn.gameObject,call_back)

	local function call_back()
		self:Close()
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectRefineMateria, call_back)
end

function EquipRefineSelectPanel:OpenCallBack()
	self:UpdateView()
end

function EquipRefineSelectPanel:UpdateView( )
	local itemids = String2Table(Config.db_equip_refine_other[1].itemids)
	for i=1, #itemids do
		local item_id = itemids[i]
		local num = BagController:GetInstance():GetItemListNum(item_id)
		local item = EquipRefineSelectItem(self.EquipRefineSelectItem_go, self.Content)
		item:SetData(item_id, num)
		self.item_list[i] = item
	end
end

function EquipRefineSelectPanel:CloseCallBack(  )
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
		self.item_list[i] = nil
	end
	self.model:RemoveTabListener(self.events)
end