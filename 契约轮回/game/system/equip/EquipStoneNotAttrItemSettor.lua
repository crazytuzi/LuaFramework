--
-- @Author: chk
-- @Date:   2018-09-29 17:52:22
--
EquipStoneNotAttrItemSettor = EquipStoneNotAttrItemSettor or class("EquipStoneNotAttrItemSettor",BaseWidget)
local EquipStoneNotAttrItemSettor = EquipStoneNotAttrItemSettor

function EquipStoneNotAttrItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipStoneNoAttrItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	EquipStoneNotAttrItemSettor.super.Load(self)
end

function EquipStoneNotAttrItemSettor:dctor()
end

function EquipStoneNotAttrItemSettor:LoadCallBack()
	self.nodes = {
		"value",
		"notOpen"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	if self.need_load_end then
		self:UpdateInfo(self.order,self.hole)
	end
end

function EquipStoneNotAttrItemSettor:AddEvent()
end

function EquipStoneNotAttrItemSettor:SetData(data)

end

function EquipStoneNotAttrItemSettor:SetItemPosition(index)
	if self.is_loaded then
		local selfRectTra = self.transform:GetComponent('RectTransform')
		selfRectTra.anchoredPosition = Vector2(selfRectTra.anchoredPosition.x + 10,- (index - 1) * 25)
	else
		self.need_load_end = true
		self._index = index
	end

end

function EquipStoneNotAttrItemSettor:SetValueTxt(info)
	self.value:GetComponent('Text').text = info
end

function EquipStoneNotAttrItemSettor:UpdateInfo(order,hole)
	if self.is_loaded then
		local roleData = RoleInfoModel.Instance:GetMainRoleData()
		local cfg = Config.db_stones_hole[hole]
		if EquipMountStoneModel.GetInstance().cur_state == EquipMountStoneModel.GetInstance().states.spar then
		    hole = hole + 100
			cfg = Config.db_spar_unlock[hole]
		  
		end

		local cndtionTbl = String2Table(cfg.open_condition)
		for i, v in pairs(cndtionTbl) do
			local isLock = false
			if v[1] == "order" then
				if order < v[2] then
					local info = string.format("<color=#675344>%s</color>      <color=#675344>%s%s%s%s</color>",
							ConfigLanguage.Equip.NotMount,v[2],ConfigLanguage.Equip.Step,ConfigLanguage.Equip.Equip,
							ConfigLanguage.Mix.Open)
					self:SetValueTxt(info)
					SetVisible(self.notOpen.gameObject.gameObject,true)
				end
			elseif v[1] == "vip" then
				if roleData.viplv < v[2] then

					local info = string.format("<color=#675344>%s</color>   <color=#675344>vip%s%s</color>",
							ConfigLanguage.Equip.NotMount,v[2],ConfigLanguage.Mix.Exclusive)
					self:SetValueTxt(info)
					SetVisible(self.notOpen.gameObject.gameObject,true)
				end
			end

		end
	else
		self.need_load_end = true
		self.order = order
		self.hole = hole
	end

end


