--
-- @Author: chk
-- @Date:   2018-08-24 21:04:45
--
BaseBagPanel = BaseBagPanel or class("BaseBagPanel",BaseItem)
local BaseBagPanel = BaseBagPanel

function BaseBagPanel:ctor(parent_node,layer)

	self.bagId = nil
	self.arrangBagEnd = true                    --是否整理完背包
	self.model = BagModel:GetInstance()
	self.events = self.events or {}
	self.globalEvents = {}
	self.loadingItems = false
	self.equipDetailView = nil
	self.goodsDetailView = nil
	self.stoneDetailView = nil

	self.crntArrangeSec = 5
end

function BaseBagPanel:dctor()
	for k,v in pairs(self.events) do
		self.model:RemoveListener(v)
		self.events = {}
	end


	if self.scrollView ~= nil then
		self.scrollView:OnDestroy()
		self.scrollView = nil
	end

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}

	if self.equipDetailView ~= nil then
		self.equipDetailView:destroy()
		self.equipDetailView = nil
	end

	if self.goodsDetailView ~= nil then
		self.goodsDetailView:destroy()
		self.goodsDetailView = nil
	end

	if self.stoneDetailView  ~= nil then
		self.stoneDetailView:destroy()
		self.stoneDetailView = nil
	end 

	if self.arrange_span_sche_id ~= nil then
		GlobalSchedule:Stop(self.arrange_span_sche_id)
		self.arrange_span_sche_id = nil
	end

	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function BaseBagPanel:LoadCallBack()
	self.nodes = {
		"equipTipContainer",
		"goodsTipContainer",
		"ScrollView",
		"ScrollView/Viewport/Content",
		"btnContain",
		"btnContain/ArrangeBtn",
		"ScrollView/Viewport",
		-- "ArrangeBtn/ArrangeText",

	}
	
	self:GetChildren(self.nodes)
	self:AddEvent()
	self:SetMask()
end

function BaseBagPanel:AddEvent()
	self:ArrangeBagEvent(self.ArrangeBtn)
end

--整理背包事件
function BaseBagPanel:ArrangeBagEvent(arrangeBtn)
	AddClickEvent(arrangeBtn.gameObject,handler(self,self.ArrangeBagCB))
end

function BaseBagPanel:ArrangeBagCB()
	if self.arrangBagEnd then
		self:ArrangeBag()
	else
		Notify.ShowText(ConfigLanguage.Bag.ArrangingBag)
	end
end

function BaseBagPanel:ArrangeCutDown()

end

--整理背包(要重载)
function BaseBagPanel:ArrangeBag()
	if self.arrange_end_sche_id ~= nil then
		GlobalSchedule:Stop(self.arrange_end_sche_id)
		self.arrange_end_sche_id = nil
	end

	if self.arrange_span_sche_id ~= nil then
		GlobalSchedule:Stop(self.arrange_span_sche_id)
		self.arrange_span_sche_id = nil
	end

	self.arrangBagEnd = false

	local function call_back( ... )
		self.arrangBagEnd = true
	end
    self.crntArrangeSec = 5
	--self.arrange_end_sche_id = GlobalSchedule:Start(call_back,5,1)
	self.arrange_span_sche_id = GlobalSchedule:Start(handler(self,self.ArrangeCutDown),1,5)
	self:ArrangeCutDown()
end


function BaseBagPanel:CreateItems(cellCount)
	local param = {}
	local cellSize = {width = 80,height = 80}
	param["scrollViewTra"] = self.ScrollView
	param["cellParent"] = self.Content
	param["cellSize"] = cellSize
	param["cellClass"] = BagItemSettor
	param["begPos"] = Vector2(3,-5)
	param["spanX"] = 3
	param["spanY"] = 5
	param["createCellCB"] = handler(self,self.CreateCellCB)
	param["updateCellCB"] = handler(self,self.UpdateCellCB)
	param["cellCount"] = cellCount
	self.scrollView = ScrollViewUtil.CreateItems(param)
	local _, y = GetAnchoredPosition(self.Content.transform)
	if y >= 1 then
		SetAnchoredPosition(self.Content.transform, 0, 0)
	end
end


function BaseBagPanel:LoadItems(bagWareId)
	if self.loadingItems then
		return
	end


	self.loadingItems = true



	if self.scrollView ~= nil then
		self.scrollView:Update()
	end


	self.loadingItems = false
end

function BaseBagPanel:SetMask()
	self.StencilId = 12  -- 仓库跟 背包id 不同   scroll 会有穿透
   -- self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
