--
-- @Author: LaoY
-- @Date:   2018-12-14 19:57:05
--
GiftMulPanel = GiftMulPanel or class("GiftMulPanel",WindowPanel)
local GiftMulPanel = GiftMulPanel

function GiftMulPanel:ctor()
	self.abName = "goods"
	self.assetName = "GiftMulPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Gold,Constant.GoldType.Diamond,Constant.GoldType.Gemstone}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.model = GoodsModel:GetInstance()

	self.global_event_list = {}
end

function GiftMulPanel:dctor()

	if self.item_list then
		for k,item in pairs(self.item_list) do
			item:destroy()
		end
		self.item_list = {}
	end

	

	if self.global_event_list then
		self.model:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end
end

function GiftMulPanel:Open(gift_id,uid,number)
	self.gift_id = gift_id
	self.uid = uid
	self.number = number
	GiftMulPanel.super.Open(self)
end

function GiftMulPanel:LoadCallBack()
	self.nodes = {
		"scroll","text_des","scroll/Viewport/Content","GiftMulItem","text_title"
	}
	self:GetChildren(self.nodes)
	--self:SetTileTextImage(self.abName .. "_image","img_title_gift_4",false)

	self.GiftMulItem_gameObject = self.GiftMulItem.gameObject
	SetVisible(self.GiftMulItem,false)

	self.text_des_component = self.text_des:GetComponent('Text')
	self.text_title_component = self.text_title:GetComponent('Text')

	self:SetTitleVisible(false)
	
	self:AddEvent()
end

function GiftMulPanel:AddEvent()
	local function call_back(item_id)
		if self.gift_id == item_id then
			self:Close()
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(GoodsEvent.UseGiftSuccess, call_back)
end

function GiftMulPanel:OpenCallBack()
	self:UpdateView()
end

function GiftMulPanel:UpdateView( )
	local gift_config = Config.db_item_gift[self.gift_id]
	if not gift_config then
		return
	end
	self.text_title_component.text = gift_config.name

	self.item_list = self.item_list or {}
	local list = String2Table(gift_config.mul)
	local len = #list
	local str = string.format("You can select one from the %s packs!",len)
	self.text_des_component.text = str
	for i=1, len do
		local item = self.item_list[i]
		if not item then
			item = GiftMulItem(self.GiftMulItem_gameObject,self.Content)
			self.item_list[i] = item
		end
		item:SetData(i,list[i],self.uid,self.number)
	end
	
	for i=len+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(true)
	end
end

function GiftMulPanel:CloseCallBack(  )

end