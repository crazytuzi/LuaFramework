--
-- @Author: chk
-- @Date:   2018-10-06 18:55:31
--
ClickStoneOperationView = ClickStoneOperationView or class("ClickStoneOperationView",BaseItem)
local ClickStoneOperationView = ClickStoneOperationView

function ClickStoneOperationView:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "ClickStoneOperationView"
	self.layer = layer

	self.globalEvents = {}
	self.operationItemSettors = {}
	self.model = EquipMountStoneModel:GetInstance()
	ClickStoneOperationView.super.Load(self)
	self:SetOrderByParentAuto()
end

function ClickStoneOperationView:dctor()
	self.stoneId = nil
	for i, v in pairs(self.operationItemSettors) do
		v:destroy()
	end

	self.operationItemSettors = {}

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
end

function ClickStoneOperationView:LoadCallBack()
	self.nodes = {
		"bg",
		"tip",
		"mask",
		"takeOffBtn",
		"Scroll View/Viewport/Content",
		"title/txt_title",
	}
	self:GetChildren(self.nodes)
	self:GetTransformRect()
	self:AddEvent()
	self:SetViewPosition()

	if self.need_load_end then
		self:ShowView(self.stoneId)
	end

	self.txt_title = GetText(self.txt_title)
	self.txt_title.text = "Tap the gem for further operation"
	self.txt_tip = GetText(self.tip)
	self.txt_tip.text = "The gem has reached its max level"
	if self.model.cur_state == self.model.states.spar then
		self.txt_title.text = "Tap the crystal for further operation"
		self.txt_tip.text = "The crystal has reached its max level"
	end

end

function ClickStoneOperationView:AddEvent()
	local function call_back()
		EquipController.Instance:RequestTakeOffStone(self.model.operateSlot,self.model.operateHole)
	end

	AddClickEvent(self.takeOffBtn.gameObject,call_back)


	local function call_back()
		self:destroy()
	end

	AddClickEvent(self.mask.gameObject,call_back)

	local function call_back()
		for i, v in pairs(self.globalEvents) do
			GlobalEvent:RemoveListener(v)
		end
		self:destroy()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.CloseStoneOperateView,call_back)

	local function call_back()
		self:Close()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.CloseStoneOperationView,call_back)
	--self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail,handler(self,self.DealEquipUpdate))
	--self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.UpdateGoodsNum,handler(self,self.DealUpdateNum))
end

function ClickStoneOperationView:SetData(data)

end

function ClickStoneOperationView:DealUpdateNum(itemId)

end

function ClickStoneOperationView:DealEquipUpdate(equipItem)
	self.stoneId = self.model:GetOnStoneIdBySlotHole(self.model.operateSlot,self.model.operateHole)
	self:LoadItems()
end

function ClickStoneOperationView:GetTransformRect()
	self.bgRectTra = self.bg:GetComponent('RectTransform')
	self.viewRectTra = self.transform:GetComponent('RectTransform')
end

function ClickStoneOperationView:LoadItems()
	local stones = EquipMountStoneModel.GetInstance():SortOperationStones(self.stoneId, self.model.operateSlot,self.model.cur_state) or {}
	local isMaxLv = EquipMountStoneModel.GetInstance():JudgeIsMaxLv(self.stoneId,self.model.cur_state)  --宝石是否最大等级
	if table.isempty(stones) then --背包没有宝石
		for i, v in pairs(self.operationItemSettors) do
			v:destroy()
		end

		if isMaxLv then
			SetVisible(self.tip.gameObject,true)

			SetVisible(self.takeOffBtn.gameObject,false)
		else
			SetVisible(self.tip.gameObject,false)

			local stoneId = EquipMountStoneModel.GetInstance():GetStoneIdBySlot(self.model.operateSlot,self.model.cur_state)
			self.operationItemSettors[0] = StoneOperationItemSettor(self.Content,"UI")
			local stoneName = ""
			if self.model.operateSlot <= 1005 then
				stoneName = ConfigLanguage.Equip.AttackStone
				if self.model.cur_state == self.model.states.spar then
					stoneName = ConfigLanguage.Equip.AttackSpar
				end
			else
				stoneName = ConfigLanguage.Equip.DefStone
				if self.model.cur_state == self.model.states.spar then
					stoneName = ConfigLanguage.Equip.DefSpar
				end
			
			end
			local info = string.format(ConfigLanguage.Equip.JumpToMarketBuyStone,stoneName)
			self.operationItemSettors[0]:UpdateInfoJump(info,stoneId,nil,1)


			if self.stoneId ~= nil then --镶嵌的宝石
				SetVisible(self.takeOffBtn.gameObject,true)


				if self.operationItemSettors[self.stoneId] == nil then
					self.operationItemSettors[self.stoneId] = StoneOperationItemSettor(self.Content,"UI")
				end

				local num = BagModel.Instance:GetItemNumByItemID(self.stoneId)
				local itemCfg = Config.db_item[self.stoneId]
				local info = ""
				local upString = ConfigLanguage.Equip.UpStone
				if self.model.cur_state == self.model.states.spar then
					upString = ConfigLanguage.Equip.UpSpar
				end
				info = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),upString .. "\n")
				info = info .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Apricot),itemCfg.name)
				self.operationItemSettors[self.stoneId]:UpdateInfoUpLv(info,self.stoneId,num,2)
			else
				SetVisible(self.takeOffBtn.gameObject,false)
			end
		end


		return
	else
		SetVisible(self.takeOffBtn.gameObject,true)
		SetVisible(self.tip.gameObject,false)

		if self.stoneId ~= nil and not isMaxLv and
				not EquipMountStoneModel.GetInstance():HasContainStoneById(stones,self.stoneId) then
			local _stone = {id = self.stoneId}
			table.insert(stones,1,_stone)
		end

		if self.stoneId ~= nil then
			SetVisible(self.takeOffBtn.gameObject,true)
		else
			SetVisible(self.takeOffBtn.gameObject,false)
		end

		local index = 0
		for i, v in pairs(stones) do
			local upType = EquipMountStoneModel.GetInstance():GetUpLvType(v.id,self.model.cur_state)
			local isMount = EquipMountStoneModel.GetInstance():GetStoneIsMount(self.model.operateSlot,v.id,self.model.operateHole,self.model.cur_state)
			local num = BagModel.Instance:GetItemNumByItemID(v.id)
			local info = ""
			local cfg = Config.db_stone[v.id]
			if self.model.cur_state == self.model.states.spar then
				cfg = Config.db_spar[v.id]
			end
			local itemCfg = Config.db_item[v.id]
			--没有穿上
			if not isMount then --0表示宝石已是最高级了
				if self.operationItemSettors[v.id] == nil then
					self.operationItemSettors[v.id] = StoneOperationItemSettor(self.Content,"UI")
				end


				if self.stoneId ~= nil and v.id == self.stoneId and isMount then

					local upString = ConfigLanguage.Equip.UpStone
					if self.model.cur_state == self.model.states.spar then
						upString = ConfigLanguage.Equip.UpSpar
					end

					info = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),upString .. "\n")
					info = info .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Apricot),itemCfg.name)
					self.operationItemSettors[v.id]:UpdateInfoUpLv(info,v.id,num,index)
				else
					local replaceString = ConfigLanguage.Equip.ReplaceStone
					if self.model.cur_state == self.model.states.spar then
						replaceString = ConfigLanguage.Equip.ReplaceSpar
					end
					info = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),replaceString .. "\n")
					info = info .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Apricot),itemCfg.name)

					self.operationItemSettors[v.id]:UpdateInfoMount(info,v.id,num,index)
				end

				index = index + 1

				SetVisible(self.tip.gameObject,false)
			elseif isMount then -- 穿上了
				if upType == 0 then   --最高级，直接删除
					if self.operationItemSettors[v.id] ~= nil then
						self.operationItemSettors[v.id]:destroy()
						self.operationItemSettors[v.id] = nil
					end


					if table.isempty(self.operationItemSettors) then
						SetVisible(self.tip.gameObject,true)
					end
				else
					if self.operationItemSettors[v.id] == nil then
						self.operationItemSettors[v.id] = StoneOperationItemSettor(self.Content,"UI")
					end

					if v.id == self.stoneId then
						info = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),
								ConfigLanguage.Equip.UpStone .. "\n")
						info = info .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Apricot),itemCfg.name)
						self.operationItemSettors[v.id]:UpdateInfoUpLv(info,v.id,num,index)
					else
						info = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.GreenDeep),
								ConfigLanguage.Equip.ReplaceStone .. "\n")
						info = info .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Apricot),itemCfg.name)
						self.operationItemSettors[v.id]:UpdateInfoUpLv(info,v.id,num,index)
					end

					index = index + 1
				end
			end
		end
	end
end

function ClickStoneOperationView:SetViewPosition()
	local parentRectTra = self.parent_node:GetComponent('RectTransform')


	local pos = self.parent_node.position
	local x = ScreenWidth / 2 + pos.x * 100 + parentRectTra.sizeDelta.x / 2
	local y = pos.y * 100 - ScreenHeight / 2 - parentRectTra.sizeDelta.y / 2
	--local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)

	if not self.isCompare then
		self.transform:SetParent(EquipModel.Instance.UITransform)
	end


	local spanX = 0
	local spanY = 0
	--判断是否超出右边界
	local _x = ScreenWidth -(x + self.bgRectTra.sizeDelta.x)
	if  _x < 130 then
		spanX = ScreenWidth - (x + self.bgRectTra.sizeDelta.x + 130)
	end

	if ScreenHeight + y - self.bgRectTra.sizeDelta.y < 40 then
		spanY = ScreenHeight + y - self.bgRectTra.sizeDelta.y - 40
	end

	self.viewRectTra.anchoredPosition = Vector2(x + spanX,y - spanY)
end

function ClickStoneOperationView:ShowView(stoneId)
	self.stoneId = stoneId
	if self.is_loaded then
		self:LoadItems()
	else

		self.need_load_end = true
	end
end

