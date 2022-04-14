-- @Author: chk
-- @Date:   2018-09-18 16:17:26
--

EquipStoneItemSettor = EquipStoneItemSettor or class("EquipStoneItemSettor",BaseItem)
local EquipStoneItemSettor = EquipStoneItemSettor

function EquipStoneItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipStoneItem"
	self.layer = layer

	self.model = EquipMountStoneModel:GetInstance()
	self.need_load_end = false
	self.iconCls = nil
	self.globalEvents = {}
	self.stoneIcons = {}
	self.stoneIconBGs = {}
	self.stoneIconsShowBG = {}
	self.__index = 0

	self.state = nil --标记是宝石那栏的还是晶石那栏的

	self.need_select = false

	EquipStoneItemSettor.super.Load(self)
end

function EquipStoneItemSettor:dctor()
	self.model.last_select_item = nil
	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}

	if self.iconCls ~= nil then
		self.iconCls:destroy()
		self.iconCls = nil
	end
	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
	self.stoneIconsShowBG = nil
	self.stoneIcons = nil
	self.stoneIconBGs = nil
end

function EquipStoneItemSettor:LoadCallBack()
	self.nodes = {
		"select",
		"icon",
		"name",
		"stoneContain",
		"name_type",
		"stoneContain/stone_1_bg",
		"stoneContain/stone_1_bg/stone_1",
		"stoneContain/stone_1_bg/stone_1_s",
		"stoneContain/stone_2_bg",
		"stoneContain/stone_2_bg/stone_2",
		"stoneContain/stone_2_bg/stone_2_s",
		"stoneContain/stone_3_bg",
		"stoneContain/stone_3_bg/stone_3",
		"stoneContain/stone_3_bg/stone_3_s",
		"stoneContain/stone_4_bg",
		"stoneContain/stone_4_bg/stone_4",
		"stoneContain/stone_4_bg/stone_4_s",
		"stoneContain/stone_5_bg",
		"stoneContain/stone_5_bg/stone_5",
		"stoneContain/stone_5_bg/stone_5_s",
		"stoneContain/stone_6_bg",
		"stoneContain/stone_6_bg/stone_6",
		"stoneContain/stone_6_bg/stone_6_s",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self:GetTraComponent()
	self.name_type = GetText(self.name_type)
	if self.need_load_end then
		self:UpdateInfo(self.equipItem,self.__index,self.state)
	end
	if self.need_select then
		self:SelectItem()
	end
end

function EquipStoneItemSettor:AddEvent()
	AddClickEvent(self.gameObject,handler(self,self.SelectItem))

	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail,handler(self,self.DealEquipUpdate))

	local function call_back( )
		self:ShowRedDot()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)
    --self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StoneChange, call_back)
end

function EquipStoneItemSettor:DealEquipUpdate(equipItem)
	if equipItem.uid == self.equipItem.uid then
		self.equipItem = equipItem
		self:UpdateStone(equipItem.equip.stones)
	end

end

function EquipStoneItemSettor:GetTraComponent()
	self.stoneIcons[1] = self.stone_1:GetComponent('Image')
	self.stoneIcons[2] = self.stone_2:GetComponent('Image')
	self.stoneIcons[3] = self.stone_3:GetComponent('Image')
	self.stoneIcons[4] = self.stone_4:GetComponent('Image')
	self.stoneIcons[5] = self.stone_5:GetComponent('Image')
	self.stoneIcons[6] = self.stone_6:GetComponent('Image')

	self.stoneIconBGs[1] = self.stone_1_bg
	self.stoneIconBGs[2] = self.stone_2_bg
	self.stoneIconBGs[3] = self.stone_3_bg
	self.stoneIconBGs[4] = self.stone_4_bg
	self.stoneIconBGs[5] = self.stone_5_bg
	self.stoneIconBGs[6] = self.stone_6_bg

	self.stoneIconsShowBG[1] = self.stone_1_s
	self.stoneIconsShowBG[2] = self.stone_2_s
	self.stoneIconsShowBG[3] = self.stone_3_s
	self.stoneIconsShowBG[4] = self.stone_4_s
	self.stoneIconsShowBG[5] = self.stone_5_s
	self.stoneIconsShowBG[6] = self.stone_6_s

	self.nameTxt= self.name:GetComponent('Text')
end

function EquipStoneItemSettor:SetData(data)

end

function EquipStoneItemSettor:SelectItem()

	if not self.is_loaded then
		self.need_select = true
		return
	end
	self.need_select = false
	local last_select_item = self.model.last_select_gem_item
	if self.state == self.model.states.spar then
		last_select_item = self.model.last_select_spar_item
	end

	if last_select_item ~= nil then
		last_select_item:ShowSelectBG(false)
	end

	self:ShowSelectBG(true)

	if self.state == self.model.states.gem then
		self.model.last_select_gem_item = self
	else
		self.model.last_select_spar_item = self
	end

	local equipConfig = Config.db_equip[self.equipItem.id]
	if EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot] ~= nil then
		self.model.operateItemId = equipConfig.id
		self.model.operateSlot = equipConfig.slot

		GlobalEvent:Brocast(EquipEvent.ShowStoneViewInfo,EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot])
	-- else
	-- 	GoodsController.Instance:RequestItemInfo(1,equipConfig.slot)
	end

end

function EquipStoneItemSettor:ShowSelectBG(show)
	SetVisible(self.select.gameObject,show)
end

--设置UI项在scorll view的content下的位置
function EquipStoneItemSettor:SetItemPosition()
	local y = (self.__index - 1) * 96
	SetLocalPosition(self.transform,0,-y,0)
end

function EquipStoneItemSettor:UpdateStone( stones )
	local notStoneSlot = {}
	table.insert(notStoneSlot,1)
	table.insert(notStoneSlot,2)
	table.insert(notStoneSlot,3)
	table.insert(notStoneSlot,4)
	table.insert(notStoneSlot,5)
	table.insert(notStoneSlot,6)

	local openCount = self.model:GetOpenHoleCount(self.equipItem.id,self.state)
	for i = 1, openCount do
		SetVisible(self.stoneIconsShowBG[i].gameObject,false)
		SetVisible(self.stoneIcons[i].gameObject,false)
	end
	if openCount < 6 then
		for i = openCount + 1,6 do
			SetVisible(self.stoneIconBGs[i].gameObject,false)
			--SetVisible(self.stoneIcons[i].gameObject,false)
		end
	end

	local index = 1
	for i, v in pairs(stones) do
		--table.removebyvalue(notStoneSlot,i)


		if (self.state == self.model.states.spar and i >= 101) or (self.state == self.model.states.gem and i <= 6) then
			SetVisible(self.stoneIconsShowBG[index].gameObject,true)
			SetVisible(self.stoneIcons[index].gameObject,true)
			local itemCfg = Config.db_item[v]
			local abName = GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
			abName = "iconasset/" .. abName
			lua_resMgr:SetImageTexture(self,self.stoneIcons[index],abName,tostring(itemCfg.icon),true,nil,false)
	
			index = index + 1
		end


	
	end



	self:ShowRedDot()
	--for i, v in pairs(notStoneSlot) do
	--	SetVisible(self.stoneIconsShowBG[v].gameObject,false)
	--	SetVisible(self.stoneIcons[v].gameObject,false)
	--end
end

function EquipStoneItemSettor:UpdateInfo(equip,index,state)

	self.model:CheckStateParam(state)

	self.__index = index
	self.equipItem = equip
	self.state = state

	if self.is_loaded then

		local equipConfig = Config.db_equip[equip.id]
		local itemCfg = Config.db_item[equip.id]
		self.nameTxt.text = string.format("<color=#%s>%s</color>",
				ColorUtil.GetColor(itemCfg.color), equipConfig.name)
		self.name_type.text = enumName.ITEM_STYPE[equipConfig.slot]
		if self.iconCls == nil then
			self.iconCls = GoodsIconSettorTwo(self.icon)
		end

		local param = {}
		param["not_need_compare"] = true
		param["model"] = self.model
		param["p_item"] = equip
		param["item_id"] = equip.id
		param["size"] = {x = 76,y=76}
		--param["can_click"] = true
		self.iconCls:SetIcon(param)

		--self.iconCls:UpdateIconByItemId(equip.id)
		
		self.need_load_end = false

		--刷新镶嵌的石头信息
		self:UpdateStone(equip.equip.stones)

		self:SetItemPosition()
		if self.model.select_equip ~= nil and self.model.select_equip.id == self.equipItem.id then

			self:SelectItem()

			GlobalEvent:Brocast(EquipEvent.MountStoneItemPos,self.transform)
		else
			local equip = EquipModel.Instance:GetFstMountEquip()
			--第一次打开 默认选宝石那一栏的装备
			if equip ~= nil and equip.id == self.equipItem.id and state == 1 then
				self:SelectItem()
				GlobalEvent:Brocast(EquipEvent.MountStoneItemPos,self.transform)
			end

		end
		self:ShowRedDot( )
	else
		self.need_load_end = true
	end
end

--显示红点
function EquipStoneItemSettor:ShowRedDot( )
	if not self.red_dot then
		self.red_dot = RedDot(self.transform)
		SetLocalPosition(self.red_dot.transform, 275, -19)
	end
	local show_red = self.model:GetNeedShowRedDotByEquip(self.equipItem,self.state)
	SetVisible(self.red_dot, show_red)
end