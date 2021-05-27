CombineServerGiftPage = CombineServerGiftPage or BaseClass()


function CombineServerGiftPage:__init()
	
end	

function CombineServerGiftPage:__delete()
	if self.cell_gift_list ~= nil then
		for k,v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = {}
	end

	if self.gift_yb then
		self.gift_yb:DeleteMe()
		self.gift_yb = nil
	end

	if self.gift_combine_grid then
		self.gift_combine_grid:DeleteMe()
		self.gift_combine_grid = nil
	end
	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerGiftPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateCells()
	self:CreateItemCell()
	self:CreateNumBar()
	self.gift_type = 1
	self.select_index = 1

	self:InitEvent()
end	


--初始化事件
function CombineServerGiftPage:InitEvent()
	self.view.node_t_list.btn_buy_gift.node:addClickEventListener(BindTool.Bind1(self.OnClickBuyGiftHandler, self))
	--self.view.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind1(self.MoveLeft, self))
	--self.view.node_t_list.btn_rigtht.node:addClickEventListener(BindTool.Bind1(self.MoveRigtht, self))
	self.combineserver_gift_recharge_event = GlobalEventSystem:Bind(CombineServerActiviType.GIFT_CHANGE, BindTool.Bind(self.OnCombineServerGiftRechargeEvent, self))
end

--移除事件
function CombineServerGiftPage:RemoveEvent()
	if self.combineserver_gift_recharge_event then
		GlobalEventSystem:UnBind(self.combineserver_gift_recharge_event)
		self.combineserver_gift_recharge_event = nil
	end
end

function CombineServerGiftPage:MoveLeft()
	if self.select_index > 1 then
		self.select_index = self.select_index - 1
		self.gift_combine_grid:SetSelectItemToTop(self.select_index)
	end
end

function CombineServerGiftPage:MoveRigtht()
	if self.select_index < 7 then
		self.select_index = self.select_index + 1
		self.gift_combine_grid:SetSelectItemToTop(self.select_index)
	end
end

--更新视图界面
function CombineServerGiftPage:UpdateData(data)
	self:OnCombineServerGiftRechargeEvent()
end	

function CombineServerGiftPage:OnClickBuyGiftHandler()
	local type = self.gift_type	

	local is_can_get,index,info = CombineServerData.Instance:GetCanGiftDataByType(type)
	if is_can_get then
		CombineServerCtrl.Instance:ReqBuyGift(type,index)
	end	
end

function CombineServerGiftPage:CreateCells()
	self.cell_gift_list = {}
	for i = 1, 7 do
		local cell = BaseCell.New()
		local ph = self.view.ph_list["ph_gift_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.view.node_t_list.layout_gift_cells.node:addChild(cell:GetView(), 300)

		local cell_effect = AnimateSprite:create()
		cell_effect:setPosition(ph.x, ph.y)
		self.view.node_t_list.layout_gift_cells.node:addChild(cell_effect, 300)
		cell_effect:setVisible(false)
		cell.cell_effect = cell_effect

		table.insert(self.cell_gift_list, cell)
	end
end

function CombineServerGiftPage:CreateItemCell()
	local ph_grid = self.view.ph_list.ph_grid
	if self.gift_combine_grid == nil then
		local ph = self.view.ph_list.ph_grid
		local item_ui_cfg = self.view.ph_list.ph_gift_grid_cell
		self.gift_combine_grid = GridScroll.New()
		-- self.gift_combine_grid:SetIsUseStepCalc(false)
		local gap = (ph.w - item_ui_cfg.w * 3)	/ 2
		self.gift_combine_grid:Create(ph.x, ph.y, ph.w, ph.h, 2, item_ui_cfg.w + gap, CombinServerGiftRender, ScrollDir.Horizontal, false, item_ui_cfg)
		self.view.node_t_list.layout_combine_gift.node:addChild(self.gift_combine_grid:GetView(), 999)
		self.gift_combine_grid:SetSelectCallBack(BindTool.Bind(self.OnGiftGridSclectCallBack, self))
	end
end

function CombineServerGiftPage:CreateNumBar()
	local ph = self.view.ph_list.img_money
	self.gift_yb = NumberBar.New()
	self.gift_yb:SetRootPath(ResPath.GetCommon("num_100_"))
	self.gift_yb:SetPosition(ph.x, ph.y-8)
	self.gift_yb:SetSpace(0)
	self.view.node_t_list.layout_combine_gift.node:addChild(self.gift_yb:GetView(), 90)
	self.gift_yb:SetNumber(0)
	self.gift_yb:SetGravity(NumberBarGravity.Center)
end

function CombineServerGiftPage:OnGiftGridSclectCallBack(cell, index)
	if cell == nil or cell:GetData() == nil then return end
	local data = cell:GetData()
	self.select_index = cell:GetIndex()
	self.gift_type = data.gift_type
	local is_can_get,index,info = CombineServerData.Instance:GetCanGiftDataByType(data.gift_type)
	self.view.node_t_list.img_gift_bg.node:loadTexture(ResPath.GetBigPainting("gift_effect_" .. info.effec_id))
	self.view.node_t_list.img_gift_name.node:loadTexture(ResPath.GetOpenServerActivities("gift_txt_" .. info.name_id))

	local need_money = info.cost
	self.gift_yb:SetNumber(need_money)
	-- local total_cnt = OpenServiceAcitivityData.Instance:GetOneTypeGiftTotalCnt(data.gift_type)
	-- if total_cnt then
	-- 	local rest_buy_time = total_cnt - data.gift.idx + 1
	-- 	local content = string.format(Language.OpenServiceAcitivity.GiftRestBuy, rest_buy_time)
	-- 	RichTextUtil.ParseRichText(self.view.node_t_list.rich_openser_gift_rest_buy_cnt.node, content, 22, COLOR3B.GREEN)

	-- end
	self:FlushReward()
end


function CombineServerGiftPage:FlushReward()
	local is_can_get,index,info = CombineServerData.Instance:GetCanGiftDataByType(self.gift_type)
	local data = info and info.awards or {}
	for i,v in ipairs(data) do
		if self.cell_gift_list[i] then
			if v.level == 1 then
				local path, name = ResPath.GetEffectUiAnimPath(920)
				if path and name then
					self.cell_gift_list[i].cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
					self.cell_gift_list[i].cell_effect:setVisible(true)
				end
			else
				self.cell_gift_list[i].cell_effect:setVisible(false)
			end
			self.cell_gift_list[i]:SetData(v)
		end
	end
end

function CombineServerGiftPage:FlushData()
	if self.gift_combine_grid == nil then return end
	local data = CombineServerData.Instance:GetGiftData()
	self.gift_combine_grid:SetDataList(data)
	self.select_index = math.min(#data, self.select_index)
	if next(data) then
		self.gift_combine_grid:SelectItemByIndex(self.select_index)
	end
end

function CombineServerGiftPage:OnCombineServerGiftRechargeEvent()
	self:FlushData()
	self:FlushReward()
end

CombinServerGiftRender = CombinServerGiftRender or BaseClass(BaseRender)

function CombinServerGiftRender:__init()

end

function CombinServerGiftRender:__delete()
	
end

function CombinServerGiftRender:CreateChild()
	BaseRender.CreateChild(self)
end

function CombinServerGiftRender:OnFlush()
	if self.data == nil then return end
	local is_can_get, index, info = CombineServerData.Instance:GetCanGiftDataByType(self.data.gift_type)

	self.node_tree.gift_img.node:loadTexture(ResPath.GetBigPainting("gift_bg_" .. info.picture_id))
	self.node_tree.img_title.node:loadTexture(ResPath.GetOpenServerActivities("name_" .. info.name_id))
end

function CombinServerGiftRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetOpenServerActivities("bg_select_eff"), true)
	if nil == self.select_effect then
		ErrorLog("GiftRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 1)
end