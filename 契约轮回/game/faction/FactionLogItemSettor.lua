--
-- @Author: chk
-- @Date:   2018-12-18 19:28:11
--


FactionLogItemSettor = FactionLogItemSettor or class("FactionLogItemSettor",Node)
local FactionLogItemSettor = FactionLogItemSettor

function FactionLogItemSettor:ctor(_obj, data, index)
	self.transform = _obj.transform
	self.gameObject = self.transform.gameObject;
	self.transform_find = self.transform.Find;
	self.data = data;
	self.index = index
	self.events = {}
	self.vipItemSettor = nil
	self.logName = {}
	self.model = FactionModel:GetInstance()

	self:InitUI()
end

function FactionLogItemSettor:dctor()
end

function FactionLogItemSettor:InitUI()
	self.is_loaded = true
	self.nodes = {
		"nameBG/name_text",
		"info_Text",
	}
	self:GetChildren(self.nodes)

	self.logName[enum.GUILD_LOG.GUILD_LOG_QUIT] = ConfigLanguage.Faction.QuitFaction2
	self.logName[enum.GUILD_LOG.GUILD_LOG_APPROVE] = ConfigLanguage.Faction.AppointmentCareer
	self.logName[enum.GUILD_LOG.GUILD_LOG_JOIN] = ConfigLanguage.Faction.EnterFaction
	self.logName[enum.GUILD_LOG.GUILD_LOG_UPGRADE] = ConfigLanguage.Faction.FactionUpLv

	self:AddEvent()
	self:UpdateItem()
end

function FactionLogItemSettor:AddEvent()

end

function FactionLogItemSettor:UpdateItem( ... )
	local timeStr = string.format("<color=#604c3d>%s</color>",self.model:GetWareLogTime(self.data.time))
	local name = string.format("<color=#295a84>%s</color>",self.data.role_name)
	local itemCfg = Config.db_item[self.data.item.id]
	self.name_text:GetComponent('Text').text = timeStr .. " " .. "<color=#295a84>" .. name .. "</color>"
	self.log_info = GetLinkText(self.info_Text)
	if self.data.type == 1 then
		self.log_info.text = string.format(ConfigLanguage.Faction.DonateGet,ColorUtil.GetColor(itemCfg.color),self.index,
				itemCfg.name,self.data.score)
	else
		self.log_info.text = string.format(ConfigLanguage.Faction.ExchangeEquip,ColorUtil.GetColor(itemCfg.color),self.index,
				itemCfg.name,self.data.score)
	end

	self.log_info:AddClickListener(handler(self,self.HandleClickLogItem))
end

function FactionLogItemSettor:HandleClickLogItem(str)
	local strs = string.split(str,"_")
	if strs and #strs > 1 then
		if strs[1] == "equip" then
			if self.equipDetailView ~= nil then
				self.equipDetailView:destroy()
			end

			local equipItem = self.model:GetLogItemByIndex(strs[2])
			if equipItem ~= nil then
					local itemCfg = Config.db_item[equipItem.item.id]
				if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
					--self.equipDetailView = EquipDetailView(self.transform)
					--self.equipDetailView:UpdateInfoNotOperate(equipItem.item)
				--	self.equipDetailView = GoodsTipView(self.transform)
					local param = {}
					param["item_id"] = equipItem.item.id
					param["p_item"] = equipItem.item
					param["model"] = self.model
					self.equipDetailView = EquipTipView(self.transform)
					self.equipDetailView:ShowTip(param)
				else
					--self.goodDetailView = GoodsDetailView(self.transform)
					--self.goodDetailView:UpdateInfo(equipItem.item)
					local param = {}
					param["item_id"] = equipItem.item.id
					param["p_item"] = equipItem.item
					param["model"] = self.model
					self.equipDetailView = GoodsTipView(self.transform)
					self.equipDetailView:ShowTip(param)
				end
			end
		end
	end
end