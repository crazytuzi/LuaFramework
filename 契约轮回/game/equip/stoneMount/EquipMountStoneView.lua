--
-- @Author: chk
-- @Date:   2018-09-25 19:36:44
--
EquipMountStoneView = EquipMountStoneView or class("EquipMountStoneView",BaseItem)
local EquipMountStoneView = EquipMountStoneView

function EquipMountStoneView:ctor(parent_node,layer,sub_id)
	self.abName = "equip"
	self.assetName = "EquipMountStoneView"
	self.layer = layer

	self.fstPosY = 115
	self.equipItem = nil
	self.globalEvents = {}
	self.itemSettors = {}
	self.stoneAttrSettors = {}
	self.strongItemSettor = {}
	self.stoneContains = {}
	self.model = EquipMountStoneModel:GetInstance()

	self.spar_item_settors = {}  --晶石装备UI项列表


	self.gem_red_dot = nil
	self.spar_red_dot = nil

	self.sub_id = sub_id

	EquipMountStoneView.super.Load(self)
end

function EquipMountStoneView:dctor()
	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}
	for i, v in pairs(self.strongItemSettor) do
		v:destroy()
	end
	self.strongItemSettor = {}

	for i, v in pairs(self.stoneAttrSettors) do
		v:destroy()
	end
	self.stoneAttrSettors = {}

	if self.iconSettor ~= nil then
		self.iconSettor:destroy()
	end
	self.iconSettor = nil
	self.stoneContains = nil
	self.equipItem = nil
	self.itemSettors = nil
	self.model.stoneUpViewContain = nil

	for i, v in pairs(self.spar_item_settors) do
		v:destroy()
	end
	self.spar_item_settors = {}

	if self.gem_red_dot then
		self.gem_red_dot:destroy()
		self.gem_red_dot = nil
	end

	if self.spar_red_dot then
		self.spar_red_dot:destroy()
		self.spar_red_dot = nil
	end

	self.model.last_select_gem_item = nil
	self.model.last_select_spar_item = nil
end

function EquipMountStoneView:LoadCallBack()
	self.nodes = {
		"leftInfo/itemScrollView",
		"leftInfo/itemScrollView/Viewport/itemContent",
		"rightInfo",
		"rightInfoEmpty",
		"rightInfo/icon",
		"rightInfo/attrContain",
		"rightInfo/upViewContain",

		"rightInfo/attrContain/attr_1",
		"rightInfo/attrContain/attr_2",
		"rightInfo/attrContain/attr_3",
		"rightInfo/attrContain/attr_4",
		"rightInfo/attrContain/attr_5",
		"rightInfo/attrContain/attr_6",

		"leftInfo/title/toggle_gem","leftInfo/title/toggle_spar",
		"leftInfo/title/toggle_gem/Label1","leftInfo/title/toggle_spar/Label2",
		"rightInfo/txt_tip",
		"leftInfo/sparScrollView","leftInfo/sparScrollView/Viewport/sparContent",

		"leftInfo/title/title_text","leftInfo/title/title_image",

	}

	self:GetChildren(self.nodes)
	self:GetTranComponent()
	self:InitUI()
	self:AddEvent()

	self.model.cur_state = self.model.states.gem
	self:LoadEquipStoneItem()

	self:ShowReddot()

	self:TryOpenSpar()	

	--晶石跳转处理
	local b = OpenTipModel.GetInstance():IsOpenSystem(120,6)
	if self.sub_id == 2 and b then
		self.toggle_spar.isOn = true
	end
end

--尝试开启晶石
function EquipMountStoneView:TryOpenSpar(  )

	local b = OpenTipModel.GetInstance():IsOpenSystem(120,6)

	if b then
		--开启晶石
		SetVisible(self.title_image,false)
		SetVisible(self.title_text,false)
		SetVisible(self.toggle_gem,true)
		SetVisible(self.toggle_spar,true)
	else
		--不开启晶石
		SetVisible(self.title_image,true)
		SetVisible(self.title_text,true)
		SetVisible(self.toggle_gem,false)
		SetVisible(self.toggle_spar,false)
	end
end

function EquipMountStoneView:AddEvent()
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.ShowStoneViewInfo,handler(self,self.DealShowStoneInfo))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail,handler(self,self.DealEquipUpdate))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.TakeOffStone,handler(self,self.DealTakeOffStone))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.MountStoneItemPos,handler(self,self.DealSetScrollPos))

	local function call_back( )
		self:ShowReddot()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)

	--宝石按钮
	local function call_back(target, value)
		if value then
			self:ChangeState(self.model.states.gem)
		end
	end
	AddValueChange(self.toggle_gem.gameObject, call_back)

	--晶石按钮
	local function call_back(target, value)
		if value then
			self:ChangeState(self.model.states.spar)
		end
	end
	AddValueChange(self.toggle_spar.gameObject, call_back)
end

function EquipMountStoneView:SetData(data)

end

function EquipMountStoneView:InitUI(  )
	self.toggle_gem = GetToggle(self.toggle_gem)
	self.toggle_spar = GetToggle(self.toggle_spar)
	self.txt_tip = GetText(self.txt_tip)
	self.Label1 = GetText(self.Label1)
	self.Label2 = GetText(self.Label2)

	self.sparContent = GetRectTransform(self.sparContent)
	
end

--选中最小的强化等级后，要自动设置位置
function EquipMountStoneView:DealSetScrollPos(itemSettor)
	local scrollRectTra = self.itemScrollView:GetComponent('RectTransform')
	local itemContentRectTra = self.itemContent:GetComponent('RectTransform')

	if self.model.cur_state == self.model.states.spar then
		scrollRectTra  = GetRectTransform(self.sparScrollView)
		itemContentRectTra = GetRectTransform(self.sparContent)
	end

	local itemRectTra = itemSettor.transform:GetComponent('RectTransform')
	local posY = GetLocalPositionY(itemSettor.transform)

	local itemH = math.abs(posY) + 100
	if itemH > scrollRectTra.sizeDelta.y then
		itemContentRectTra.anchoredPosition = Vector2(itemContentRectTra.anchoredPosition.x,itemH - scrollRectTra.sizeDelta.y)
	end

end

--处理卸下石头
function EquipMountStoneView:DealTakeOffStone(slot)
	local equipDetail = EquipModel.Instance.putOnedEquipDetailList[slot]
	local cfg = Config.db_equip[equipDetail.id]

	local stones = equipDetail.equip.stones

	self:UpdateStoneAttrInfo(cfg.order,stones,self.model.cur_state)

	GlobalEvent:Brocast(EquipEvent.CloseStoneOperateView)
end

--处理装备更新
function EquipMountStoneView:DealEquipUpdate(equipItem)
	self.equipItem = equipItem
	local cfg = Config.db_equip[equipItem.id]
	local stones = equipItem.equip.stones

	self:UpdateStoneAttrInfo(cfg.order,stones,self.model.cur_state)
end

--点击左侧装备列表装备的处理
function EquipMountStoneView:DealShowStoneInfo( equipItem )

	local stones = equipItem.equip.stones

--[[ 	if self.equipItem ~= nil and self.equipItem.uid ~= equipItem.uid then
		self.equipItem = equipItem
		local cfg = Config.db_equip[equipItem.id]
		self:UpdateStoneAttrInfo(cfg.order,stones,self.model.cur_state)
		self:UpdateIcon()
	elseif self.equipItem == nil then
		self.equipItem = equipItem
		local cfg = Config.db_equip[equipItem.id]
		self:UpdateStoneAttrInfo(cfg.order,stones,self.model.cur_state)
		self:UpdateIcon()
	end
 ]]
	self.equipItem = equipItem
	local cfg = Config.db_equip[equipItem.id]
	self:UpdateStoneAttrInfo(cfg.order,stones,self.model.cur_state)
	self:UpdateIcon()

end

function EquipMountStoneView:GetTranComponent(  )
	self.itemContentRectTra = self.itemContent:GetComponent('RectTransform')
	--self.model.stoneUpViewContain = self.upViewContain

	self.scrollRectTra = self.itemScrollView:GetComponent('RectTransform')
	self.itemContentRectTra = self.itemContent:GetComponent('RectTransform')

	self.stoneContains[1] = self.attr_1
	self.stoneContains[2] = self.attr_2
	self.stoneContains[3] = self.attr_3
	self.stoneContains[4] = self.attr_4
	self.stoneContains[5] = self.attr_5
	self.stoneContains[6] = self.attr_6
end

--设置scrollview 的 content 的 高度值
function EquipMountStoneView:SetScrollViwe()
	local count = table.nums(EquipModel.Instance:GetCanStrongEquips())
	local y =  100 * count
	self.itemContentRectTra.sizeDelta = Vector2(self.itemContentRectTra.sizeDelta.x,y)
	self.sparContent.sizeDelta = Vector2(self.sparContent.sizeDelta.x,y)
end

--加载左侧装备列表
function EquipMountStoneView:LoadEquipStoneItem(  )
	local putOnedEquips = EquipModel.Instance:GetCanMountStoneEquips()

	if table.nums(putOnedEquips) > 0 then
		SetVisible(self.rightInfoEmpty.gameObject,false)
		SetVisible(self.rightInfo.gameObject,true)

		local count = 0
		for i, v in pairs(putOnedEquips) do
			count  = count + 1
			self.strongItemSettor[#self.strongItemSettor+1] = EquipStoneItemSettor(self.itemContent,"UI")
			self.strongItemSettor[#self.strongItemSettor]:UpdateInfo(v,count,1)

			self.spar_item_settors[#self.spar_item_settors+1] = EquipStoneItemSettor(self.sparContent,"UI")
			self.spar_item_settors[#self.spar_item_settors]:UpdateInfo(v,count,2)
		end

		self:SetScrollViwe()
	else
		SetVisible(self.rightInfoEmpty.gameObject,true)
		SetVisible(self.rightInfo.gameObject,false)
	end
	
end

--刷新右侧装备icon信息
function EquipMountStoneView:UpdateIcon()
	if self.iconSettor == nil then
		self.iconSettor = GoodsIconSettorTwo(self.icon)
	end

	local param = {}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["p_item"] = self.equipItem
	param["item_id"] = self.equipItem.id
	param["size"] = {x = 104,y=104}
	param["can_click"] = true
	self.iconSettor:SetIcon(param)

	--self.iconSettor:UpdateIconClickNotOperate(self.equipItem,nil,{x = 104,y = 104})
end

--刷新右侧孔位信息
function EquipMountStoneView:UpdateStoneAttrInfo(order,stones,state)
	self.model:CheckStateParam(state)

	if table.isempty(self.stoneAttrSettors) then
		for i = 1, 6 do
			self.stoneAttrSettors[#self.stoneAttrSettors+1] = StoneAttrItemSettor(self.stoneContains[i],"UI")
		end
	end

	stones = self.model:GetStones(stones,state)

	if table.isempty(stones) then
		for i = 1, 6 do
			--没有已镶嵌石头 全部初始化

			local value = i
			if state == self.model.states.spar then
				--是晶石就加上100 算出真实孔位位置
				value = value + 100
			end
			
			self.stoneAttrSettors[i]:InitStoneAttr(self.equipItem, order,value)
		end
	else
		local notHole = {}
		table.insert(notHole,1)
		table.insert(notHole,2)
		table.insert(notHole,3)
		table.insert(notHole,4)
		table.insert(notHole,5)
		table.insert(notHole,6)

		for k, v in pairs(stones) do
			
			local value = k
			if state == self.model.states.spar then
				--是晶石就减掉100 算出真实列表位置
				value = value - 100
			end

			--有镶嵌石头的孔位 刷新信息
			self.stoneAttrSettors[value]:UpdateStoneAttr(self.equipItem, v,k)

			
			table.removebyvalue(notHole,value)
		end

		for k, v in pairs(notHole) do
			--未镶嵌石头的孔位 初始化
			
			local value = v
			if state == self.model.states.spar then
				--是晶石就加上100 算出真实孔位位置
				value = value + 100
			end

			self.stoneAttrSettors[v]:InitStoneAttr(self.equipItem, order,value)
		end
	end



end

--切换宝石/晶石
function EquipMountStoneView:ChangeState(state)
	self.model:CheckStateParam(state)
	self.model.cur_state = state

	if state == self.model.states.gem then
		--宝石
		SetColor(self.Label1, 122, 140, 185)
		SetColor(self.Label2, 255, 255, 255)
		self.txt_tip.text = "Tap socketed gems to replace, upgrade and remove"

		SetVisible(self.itemScrollView,true)
		SetVisible(self.sparScrollView,false)

		--调用选中来刷新右侧面板
		self.model.last_select_gem_item:SelectItem()
	else
		--晶石
		SetColor(self.Label2, 122, 140, 185)
		SetColor(self.Label1, 255, 255, 255)
		self.txt_tip.text = "Tap socketed crystal to replace, upgrade and remove"

		SetVisible(self.itemScrollView,false)
		SetVisible(self.sparScrollView,true)

		--第一次切换到晶石时默认选中第一个
		if self.model.last_select_spar_item == nil then
			self.spar_item_settors[1]:SelectItem()
		else
			--调用选中来刷新右侧面板
			self.model.last_select_spar_item:SelectItem()
		end

	end

	
end

--红点显示
function EquipMountStoneView:ShowReddot()
	if not self.gem_red_dot then
		self.gem_red_dot = RedDot(self.toggle_gem.transform)
		SetLocalPosition(self.gem_red_dot.transform, 55, 14)
	end

	if not self.spar_red_dot then
		self.spar_red_dot = RedDot(self.toggle_spar.transform)
		SetLocalPosition(self.spar_red_dot.transform, 55, 14)
	end

	local is_show_gem_red_dot = self.model:GetNeedShowRedDotByState(self.model.states.gem)
	local is_show_spar_red_dot = self.model:GetNeedShowRedDotByState(self.model.states.spar)

	SetVisible(self.gem_red_dot,is_show_gem_red_dot)
	SetVisible(self.spar_red_dot,is_show_spar_red_dot)
end


