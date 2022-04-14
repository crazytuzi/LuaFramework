--
-- @Author: LaoY
-- @Date:   2018-12-14 22:01:15
--
GiftSelectPanel = GiftSelectPanel or class("GiftSelectPanel",WindowPanel)
local GiftSelectPanel = GiftSelectPanel

function GiftSelectPanel:ctor()
	self.abName = "goods"
	self.assetName = "GiftSelectPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Gold,Constant.GoldType.Diamond,Constant.GoldType.Gemstone}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.has_num = 1
	self.model = GoodsModel:GetInstance()

	self.global_event_list = {}
end

function GiftSelectPanel:dctor()
	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	if self.item_list then
		for k,item in pairs(self.item_list) do
			item:destroy()
		end
		self.item_list = {}
	end
	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function GiftSelectPanel:Open(gift_id,uid,number)
	self.gift_id = gift_id
	self.uid = uid
	self.number = number
	GiftSelectPanel.super.Open(self)
end

function GiftSelectPanel:LoadCallBack()
	self.nodes = {
		"scroll/Viewport/Content","scroll","text_num","btn_sure","btn_minus","GiftSelectItem","btn_add","text_des","text_1","text_has_num","text_title",
		"scroll/Viewport"
	}
	self:GetChildren(self.nodes)
	
	self.scroll_component = self.scroll:GetComponent('ScrollRect')

	-- self:SetTileTextImage(self.abName .. "_image","img_title_gift_5",false)
	self:SetTitleVisible(false)

	self.GiftSelectItem_gameObject = self.GiftSelectItem.gameObject
	SetVisible(self.GiftSelectItem_gameObject,false)

	self.text_has_num_component = self.text_has_num:GetComponent('Text')
	self.text_num_component = self.text_num:GetComponent('Text')
	self.text_des_component = self.text_des:GetComponent('Text')
	self.text_title_component = self.text_title:GetComponent('Text')

	self.text_des_component.text = "Please select the reward you want"
	self:SetSelectNum(1)

	self.scroll_height = GetSizeDeltaY(self.scroll)

	self:AddEvent()
	self:SetMask()
end

function GiftSelectPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function GiftSelectPanel:AddEvent()
	local function call_back(target,x,y)
		local num = self.sel_num + 1
		if num > self.has_num then
			Notify.ShowText("Max value exceeded")
			return
		end
		self:SetSelectNum(num)
	end
	AddClickEvent(self.btn_add.gameObject,call_back)

	local function call_back(target,x,y)
		local num = self.sel_num - 1
		if num <= 0 then
			Notify.ShowText("Can't be less than 0")
			return
		end
		self:SetSelectNum(num)
	end
	AddClickEvent(self.btn_minus.gameObject,call_back)

	local function call_back(target,x,y)
		local item_id = self:GetSelectItemId()
		GoodsController:GetInstance():RequestUseGoods(self.uid,self.sel_num,{item_id})
	end
	AddClickEvent(self.btn_sure.gameObject,call_back)

	local function call_back(id)
		self:UpdateGoods()
		if self.has_num <= 0 then
			self:Close()
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

	local function call_back(item_id)
		if self.gift_id == item_id then
			self:Close()
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(GoodsEvent.UseGiftSuccess, call_back)
end

function GiftSelectPanel:SetSelectNum(num)
	num = num > self.has_num and self.has_num or num
	self.sel_num = num
	self.text_num_component.text = num
end

function GiftSelectPanel:GetSelectItemId()
	if not self.select_index then
		return nil
	end
	local item = self.item_list[self.select_index]
	return item:GetItemID()
end

function GiftSelectPanel:OpenCallBack()
	self:UpdateView()
	self:UpdateGoods()
end

function GiftSelectPanel:UpdateGoods()
	self.has_num = BagModel:GetInstance():GetItemNumByItemID(self.gift_id)
	self:SetSelectNum(self.num or 1)
	self.text_has_num_component.text = string.format("Packs you have：<color=#ce2323>%s</color>",self.has_num)
end

function GiftSelectPanel:UpdateView()
	local gift_config = Config.db_item_gift[self.gift_id]
	if not gift_config then
		return
	end
	self.text_title_component.text = gift_config.name
	
	local list = String2Table(gift_config.reward)
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	-- list[#list+1] = list[1]
	local len = #list
	local height = 80
	local line = 5
	local content_height = math.ceil(len/line) * height
	content_height = content_height < self.scroll_height and self.scroll_height or content_height
	SetSizeDeltaY(self.Content,content_height)

	if len <= 5 then
		SetLocalPositionY(self.scroll,-13)
		self.scroll_component.vertical = false
	else
		SetLocalPositionY(self.scroll,-20)
		self.scroll_component.vertical = true
	end

	self.item_list = self.item_list or {}
	local function call_back(index)
		if self.select_index == index then
			return
		end
		self.select_index = index
		for k,item in pairs(self.item_list) do
			item:SetSelectState(index == k)
		end
	end

	for i=1, len do
		local item = self.item_list[i]
		if not item then
			item = GiftSelectItem(self.GiftSelectItem_gameObject,self.Content)
			self.item_list[i] = item
			-- local x = (i-1)%line * height + height*0.5
			-- local y = -math.floor((i-1)/line) * height - height*0.5
			-- item:SetPosition(x, y)
			item:SetCallBack(call_back)
		else
			item:SetVisible(false)
		end
		item:SetData(i,list[i])
	end
	--call_back(1)

	for i=len+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end
end

function GiftSelectPanel:CloseCallBack(  )

end