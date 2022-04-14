--
-- @Author: chk
-- @Date:   2019-01-16 17:50:15
--

EquipTipCareerInfoSettor = EquipTipCareerInfoSettor or class("EquipTipCareerInfoSettor",BaseWidget)
local EquipTipCareerInfoSettor = EquipTipCareerInfoSettor

function EquipTipCareerInfoSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipTipCareerInfo"
	self.layer = layer


	EquipTipCareerInfoSettor.super.Load(self)
end

function EquipTipCareerInfoSettor:dctor()
end

function EquipTipCareerInfoSettor:LoadCallBack()
	self.nodes = {
		"careerCon",
		"careerCon/pos",
		"careerCon/condition",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function EquipTipCareerInfoSettor:AddEvent()
end

function EquipTipCareerInfoSettor:SetData(data)

end

function EquipTipCareerInfoSettor:SetCareer(equipCfg)
	local careerInfo = ""
	local careerCfg = {}
	local itemCfg = Config.db_item[equipCfg.id]

	if equipCfg.career == "0" then
		table.insert(careerCfg, 1)
		table.insert(careerCfg, 2)
	else
		careerCfg = String2Table(equipCfg.career)
	end
	for k, v in pairs(careerCfg) do
		local wakeCfg = EquipModel.Instance:GetEquipWakeCfg(v, equipCfg.wake)
		if wakeCfg ~= nil then
			if EquipModel.Instance:GetMapCrntCareer(v, equipCfg.id) then
				careerInfo = careerInfo .. "A"..equipCfg.wake .. "·" .. wakeCfg.name .. "\n"
			else
				careerInfo = careerInfo .. string.format("<color=#%s>%s</color>", EquipModel.Instance.notMapCarrerColor,
						"A"..equipCfg.wake .. "·" .. wakeCfg.name .. "\n")
			end
		end
	end

	local key = enum.ITEM_TYPE.ITEM_TYPE_EQUIP .. "@" .. equipCfg.slot
	if Config.db_item_type[key] ~= nil then
		local stype = Config.db_item_type[key].stype
		self.pos:GetComponent('Text').text = enumName.ITEM_STYPE[stype]
	end

	self.condition:GetComponent('Text').text = careerInfo
	--self.level:GetComponent('Text').text = itemCfg.level .. ConfigLanguage.Mix.Level
	if table.nums(careerCfg) == 1 then
		self.careerConRectTra = self.careerCon:GetComponent('RectTransform')
		SetAnchoredPosition(self.careerCon, self.careerConRectTra.anchoredPosition.x, -7.3)
	end
end
