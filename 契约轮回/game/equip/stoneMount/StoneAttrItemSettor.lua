StoneAttrItemSettor = StoneAttrItemSettor or class("StoneAttrItemSettor",BaseItem)
local StoneAttrItemSettor = StoneAttrItemSettor

function StoneAttrItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "MountStoneAttrItem"
	self.layer = layer

	self.model = EquipMountStoneModel:GetInstance()
	self.need_load_end = false
	self.globalEvents = {}
	self.notOpenTxt = nil
	self.open_vip_panel = false

	StoneAttrItemSettor.super.Load(self)
end

function StoneAttrItemSettor:dctor()
	self.operationView = nil

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}

	if self.iconSettor ~= nil then
		self.iconSettor:destroy()
		self.iconSettor = nil
	end
	if self.ui_effect then
		self.ui_effect:destroy()
		self.ui_effect = nil 
	end
	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
	--self.model = nil
end

function StoneAttrItemSettor:LoadCallBack()
	self.nodes = {
		"add",
		"icon",
		"title",
		"value",
		"valueBG",
		"lock",
		"bg",
		"buttom_bg",
		"not_open_bg",
		"not_open_bg/contain/notOpen",
		"not_open_bg/contain/OpenImage",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.iconImg = self.icon:GetComponent('Image')
	self.titleTxt = self.title:GetComponent('Text')
	self.valueTxt = self.value:GetComponent('Text')
	self.selfRectTra = self.transform:GetComponent("RectTransform")
	self.notOpenTxt = self.notOpen:GetComponent('Text')
	--self.horlay = self.contain:GetComponent('HorizontalLayoutGroup')
	SetVisible(self.OpenImage.gameObject,false)
	--self.horlay.enabled = false

	if self.need_load_end then
		self:UpdateStoneAttr(self.equipitem, self.itemId,self.hole)
	elseif self.need_init_end then
		self:InitStoneAttr(self.equipitem, self.order,self.hole)
	end
end

function StoneAttrItemSettor:AddEvent()
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StoneChange, handler(self,self.DealStoneChange))

	local function call_back()
		self:ShowRedDot()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)

    local function call_back(target,x,y)
    	if self.open_vip_panel then
    		GlobalEvent:Brocast(VipEvent.OpenVipPanel)
    	end
    end
    AddClickEvent(self.lock.gameObject,call_back)
end

function StoneAttrItemSettor:AddOperateEvent()
	local function call_back()
		local stoneId = self.model:GetOnStoneIdBySlotHole(self.model.operateSlot,self.hole)
		local stones = self.model:SortOperationStones(stoneId, self.model.operateSlot,self.model.cur_state) or {}
		if self.itemId or table.isempty(stones) then
			self.model.operateHole = self.hole
			self.operationView = ClickStoneOperationView(self.transform,"UI")
			self.operationView:ShowView(self.itemId)
		else
			local stone = stones[1]
			EquipController.GetInstance():RequestMountStone(self.model.operateSlot, self.hole, stone.id)
		end
	end
	AddClickEvent(self.transform.gameObject,call_back)
end

function StoneAttrItemSettor:DealStoneChange(slot)
	if self.model.operateHole == self.hole then
		self.ui_effect = UIEffect(self.icon, 10115)
		SoundManager.GetInstance():PlayById(54)
		self:ShowRedDot()
	end
end

function StoneAttrItemSettor:InitStoneAttr(equipitem, order,hole)
	self.equipitem = equipitem
	if self.is_loaded then
		SetVisible(self.valueBG.gameObject,false)
		self.itemId = nil
		SetVisible(self.add.gameObject,true)

		if hole == 1 or 101 then
			SetVisible(self.buttom_bg.gameObject,true)
		else
			SetVisible(self.not_open_bg.gameObject,false)
			SetVisible(self.buttom_bg.gameObject,false)
		end

		self.order = order
		self.hole = hole
		SetVisible(self.icon.gameObject,false)
		self:SetValueTxt("")
		--self:SetItemPosition()
		local roleData = RoleInfoModel.Instance:GetMainRoleData()

		local cfg = Config.db_stones_hole[hole]
		if self.model.cur_state == self.model.states.spar then
			cfg = Config.db_spar_unlock[hole]
		end

		local cndtionTbl = String2Table(cfg.open_condition)
		for i, v in pairs(cndtionTbl) do
			local isLock = false
			if v[1] == "order" then
				if order < v[2] then
					isLock = true
					SetVisible(self.valueBG.gameObject,true)
					SetVisible(self.lock.gameObject,true)
					--SetVisible(self.icon.gameObject,false)
					SetVisible(self.add.gameObject,false)

					local info = string.format("<color=#ffffffff>T%s %s</color>",v[2], ConfigLanguage.Mix.Open)
					self:SetNotOpenInfo(info)
					--self:SetValueTxt({title = "",value = info})
				else
					isLock = false
					SetVisible(self.lock.gameObject,false)
					--SetVisible(self.icon.gameObject,true)
				end
				self.open_vip_panel = false
			elseif v[1] == "vip" then
				if RoleInfoModel.GetInstance():GetMainRoleVipLevel() < v[2] then
					isLock = true
					SetVisible(self.lock.gameObject,true)
					--SetVisible(self.icon.gameObject,false)
					SetVisible(self.add.gameObject,false)

					local info = string.format("vip%s%s",v[2],ConfigLanguage.Mix.Exclusive)
					self:SetNotOpenVip(v[2])
					self.open_vip_panel = true
					--self:SetValueTxt({title = "",value = info})
				else
					isLock = false
					SetVisible(self.add.gameObject,true)
					SetVisible(self.lock.gameObject,false)
					--SetVisible(self.icon.gameObject,true)
					self.open_vip_panel = false
				end
			end


			if not isLock and not self.isBindEvent then
				self:AddOperateEvent()

				SetVisible(self.not_open_bg.gameObject,false)
			else
				--if hole == 1 then
				--	SetVisible(self.not_open_bg.gameObject,true)
				--else
				--	SetVisible(self.not_open_bg.gameObject,false)
				--end
				RemoveClickEvent(self.transform.gameObject)
			end
		end
		self:ShowRedDot()
	else
		self.order = order
		self.hole = hole
		self.need_init_end = true
		self.need_load_end = false
	end
end

function StoneAttrItemSettor:UpdateStoneAttr(equipitem, itemId,hole)
	self.equipitem = equipitem
	if self.is_loaded then

		SetVisible(self.valueBG.gameObject,true)
		SetVisible(self.add.gameObject,false)
		if hole == 1 or 101 then
			SetVisible(self.buttom_bg.gameObject,true)
		else
			SetVisible(self.buttom_bg.gameObject,false)
		end


		SetVisible(self.icon.gameObject,true)


		self.itemId = itemId
		self.hole = hole

		SetVisible(self.not_open_bg.gameObject,false)
		SetVisible(self.add.gameObject,false)
		SetVisible(self.lock.gameObject,false)

		local itemCfg = Config.db_item[itemId]
		local abName = GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
		abName = "iconasset/" .. abName
		lua_resMgr:SetImageTexture(self,self.iconImg,abName,tostring(itemCfg.icon),true,nil,false)


		local info = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(itemCfg.color),
		itemCfg.name)
		--self:SetItemPosition()
		--local info = itemCfg.name
		self:SetValueTxt({title = info,value = self.model:GetStoneAttrInfo2(itemId,self.model.cur_state)})
		self:AddOperateEvent()
		self:ShowRedDot()
	else
		self.need_load_end = true
		self.need_init_end = false
		self.itemId = itemId
		self.hole = hole
	end

end

function StoneAttrItemSettor:SetItemPosition()

	local hole = self.hole
	if self.model.cur_state == self.model.states.spar then
		hole = hole - 100  --是晶石的话 减掉100得出真实列表位置
	end

	local angle = 90 - (hole - 1) * 60
	Chkprint("angle__________" , angle)
	local x = math.cos (math.rad((angle))) * 150
	local y = math.sin(math.rad(angle)) * 150
	self.selfRectTra.anchoredPosition = Vector2(x,y)
end

function StoneAttrItemSettor:SetNotOpenInfo(info)
	self.valueTxt.text = info
end

function StoneAttrItemSettor:SetNotOpenVip(vip)
	SetVisible(self.buttom_bg.gameObject,true)
	SetVisible(self.not_open_bg.gameObject,true)

	self.notOpenTxt.text = "V" .. vip

	GlobalSchedule:StartOnce(handler(self,self.SetVIPContain),0.06)
end

function StoneAttrItemSettor:SetVIPContain()
	SetVisible(self.OpenImage.gameObject,true)
end
function StoneAttrItemSettor:SetValueTxt(info)

	local hole = self.hole
	if self.model.cur_state == self.model.states.spar then
		hole = hole - 100  --是晶石的话 减掉100得出真实列表位置
	end

	if hole > 3  then
		SetLocalScale(self.valueBG.transform,-1,1,1)
		local valueBGRectTra = self.valueBG:GetComponent('RectTransform')
		valueBGRectTra.anchoredPosition = Vector2(-85.3,valueBGRectTra.anchoredPosition)

		local valueRectTra = self.value:GetComponent('RectTransform')
		self.valueTxt.alignment =  TextAnchor.MiddleRight
		valueRectTra.anchoredPosition = Vector2(-139,-27)--132.5

		local x,y,z = GetLocalPosition(self.title.transform)
		SetLocalPosition(self.title.transform, -100, y, z)
	end

	self.titleTxt.text = info.title
	self.valueTxt.text = info.value
end

function StoneAttrItemSettor:ShowRedDot()
	if not self.red_dot then
		self.red_dot = RedDot(self.bg)
		SetLocalPosition(self.red_dot.transform, 30, 30)
	end
	local show_reddot = self.model:GetNeedShowRedDotByHole(self.equipitem, self.hole,self.model.cur_state)
	SetVisible(self.red_dot, show_reddot)
end