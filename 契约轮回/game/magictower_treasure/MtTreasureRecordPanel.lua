--
-- @Author: LaoY
-- @Date:   2018-12-21 14:55:40
--

MtTreasureRecordPanel = MtTreasureRecordPanel or class("MtTreasureRecordPanel",BasePanel)

function MtTreasureRecordPanel:ctor()
	self.abName = "magictower_treasure"
	self.assetName = "MtTreasureRecordPanel"
	self.layer = "UI"

	self.use_background = true
	self.click_bg_close = true
	self.change_scene_close = true

	self.item_list = {}
	self.model_event_list = {}
	self.model = MagictowerTreasureModel:GetInstance()
	MagictowerTreasureController:GetInstance():RequestLog()
end

function MtTreasureRecordPanel:dctor()
	if self.model_event_list then
		self.model:RemoveTabListener(self.model_event_list)
		self.model_event_list = {}
	end

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function MtTreasureRecordPanel:Open( )
	MtTreasureRecordPanel.super.Open(self)
end

function MtTreasureRecordPanel:LoadCallBack()
	self.nodes = {
		"MtTreasureRecordItem","scroll/Viewport/Content","scroll"
	}
	self:GetChildren(self.nodes)
	self.MtTreasureRecordItem_gameobject = self.MtTreasureRecordItem.gameObject
	SetVisible(self.MtTreasureRecordItem,false)
	self.scroll_height = GetSizeDeltaY(self.scroll)

	SetAlignType(self.transform,bit.bor(AlignType.Left, AlignType.Null))
	
	self:AddEvent()
end

function MtTreasureRecordPanel:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.ACC_LOG, call_back)

end

function MtTreasureRecordPanel:OpenCallBack()
	self:UpdateView()
end

function MtTreasureRecordPanel:UpdateView( )
	local list = self.model.logs or {}
	local len = #list
	local height = 0
	for i=1, len do
		local item = self.item_list[i]
		if not item then
			item = MtTreasureRecordItem(self.MtTreasureRecordItem_gameobject,self.Content)
			self.item_list[i] = item
		else
			item:SetVisible(true)
		end
		item:SetData(i,list[i])
		height = height + item:GetHeight()
	end
	height = height < self.scroll_height and self.scroll_height or height
	SetSizeDeltaY(self.Content,height)
	
	for i=len+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end
end

function MtTreasureRecordPanel:CloseCallBack(  )

end