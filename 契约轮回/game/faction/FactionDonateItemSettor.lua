--
-- @Author: chk
-- @Date:   2019-01-04 21:44:12
--
FactionDonateItemSettor = FactionDonateItemSettor or class("FactionDonateItemSettor",BaseBagIconSettor)
local FactionDonateItemSettor = FactionDonateItemSettor

function FactionDonateItemSettor:ctor(parent_node, layer)
	self.abName = "system"
	self.assetName = "BagItem"
	self.layer = layer


	FactionDonateItemSettor.super.Load(self)
end

function FactionDonateItemSettor:AddEvent()
	FactionDonateItemSettor.super.AddEvent(self)
	AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end


--处理装备(物品)详细信息
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function FactionDonateItemSettor:DealGoodsDetailInfo(...)
	if not self.gameObject.activeInHierarchy then
		return
	end

	local param = { ... }
	local item = param[1]

	if item.uid ~= self.uid then
		return
	end

	local operate_param = {}
	if Config.db_item[item.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
		GoodsTipController.Instance:SetDonateCB(operate_param,
				handler(self,self.DonateEquip),{item})

		--第1个参数 请求物品的返回的p_item 必传
		--第2个参数 对请求的物品的操作参数
		--第3个参数 身上穿的,装备的

		FactionWareItemSettor.super.DealGoodsDetailInfo(self,item,operate_param)

	end
end

function FactionDonateItemSettor:DonateEquip(itemData)
	--logError(#FactionModel:GetInstance().wareItems)
	--local len = table.nums(FactionModel:GetInstance().wareItems)

	local id = itemData[1].id
	local itemCfg = Config.db_equip[id]
	if itemCfg then
		local order = itemCfg.order
		local star = itemCfg.star
		if order >= 6 and star >= 2 then
			local itemcfg = Config.db_item[id]
			local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(itemcfg.color), itemcfg.name)
			local function ok_func()
				local len = FactionModel:GetInstance():GetWareItemsLen()
				if len >= 200 then
					Notify.ShowText("Insufficient room in the warehouse")
					return
				end
				FactionWareController.Instance:RequestDonateEquip(itemData[1].uid)
			end
			Dialog.ShowTwo("Tip",str.."Rare equipment can be used for combination\nDonate?","Confirm",ok_func,nil,nil,nil,nil,"Don't notice anymore until next time I log in", false, nil, self.__cname)
		else
			local len = FactionModel:GetInstance():GetWareItemsLen()
			if len >= 200 then
				Notify.ShowText("Insufficient room in the warehouse")
				return
			end
			FactionWareController.Instance:RequestDonateEquip(itemData[1].uid)
		end
	end

end

