
require("game/clash_territory/clash_territory_data")
require("game/clash_territory/clash_territory_view")
require("game/clash_territory/clash_territory_info_view")
require("game/clash_territory/clash_territory_shop_view")

ClashTerritoryCtrl = ClashTerritoryCtrl or BaseClass(BaseController)

function ClashTerritoryCtrl:__init()
	if ClashTerritoryCtrl.Instance ~= nil then
		print_error("[ClashTerritoryCtrl] attempt to create singleton twice!")
		return
	end
	ClashTerritoryCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = ClashTerritoryView.New(ViewName.ClashTerritory)
	self.info_view = ClashTerritoryInfoView.New(ViewName.ClashTerritoryInfo)
	self.shop_view = ClashTerritoryShopView.New(ViewName.ClashTerritoryShop)
	self.data = ClashTerritoryData.New()
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function ClashTerritoryCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	self.info_view:DeleteMe()
	self.info_view = nil

	self.shop_view:DeleteMe()
	self.shop_view = nil

	ClashTerritoryCtrl.Instance = nil
end

function ClashTerritoryCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTerritoryWarApperance, "OnTerritoryWarApperance")
	self:RegisterProtocol(SCTerritoryWarGlobeInfo, "OnTerritoryWarGlobeInfo")
	self:RegisterProtocol(SCTerritoryWarRoleInfo, "OnTerritoryWarRoleInfo")
	self:RegisterProtocol(SCTerritoryWarQualification, "OnTerritoryWarQualification")
end


function ClashTerritoryCtrl:MainuiOpenCreate()
	ClashTerritoryCtrl.SendTerritoryWarQualification()
end

--变身形象广播
function ClashTerritoryCtrl:OnTerritoryWarApperance(protocol)
	-- local role = Scene.Instance:GetObj(protocol.obj_id)
	-- if role then
	-- 	role:SetAttr("special_appearance", protocol.special_image)
	-- end
end

--全局信息（广播）
function ClashTerritoryCtrl:OnTerritoryWarGlobeInfo(protocol)
	self.data:SetGlobalInfo(protocol)
	if protocol.m_winner_side ~= -1 then
		local rewards = ClashTerritoryData.Instance:GetTerritoryRewawrdCfg() or {}
		local temp_list = {reward_list = {}}
		for i = 1, 3 do
			local item = rewards["item" .. i]
			if item and item.item_id > 0 then
				table.insert(temp_list.reward_list, item)
			end
		end
		TipsCtrl.Instance:OpenActivityRewardTip(temp_list)
		ClashTerritoryCtrl.SendTerritoryWarQualification()
	end
end

--个人信息
function ClashTerritoryCtrl:OnTerritoryWarRoleInfo(protocol)
	self.data:SetRoleInfo(protocol)
	local mian_role = Scene.Instance:GetMainRole()
	if mian_role then
		if protocol.special_image_id > 0 then
			Scene.Instance:GetMainRole():SetAttr("appearance_param", protocol.special_image_id)
			Scene.Instance:GetMainRole():SetAttr("special_appearance", SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR)
		else
			Scene.Instance:GetMainRole():SetAttr("appearance_param", 0)
			Scene.Instance:GetMainRole():SetAttr("special_appearance", 0)
		end
	end
end

--下发参战队伍信息
function ClashTerritoryCtrl:OnTerritoryWarQualification(protocol)
	self.data:SetQualification(protocol)
	-- self.view:Flush()
	GuildCtrl.Instance:FlushTerritort()
end

-- 复活商点购买
function ClashTerritoryCtrl:SendTerritoryWarReliveShopBuy(goods_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTerritoryWarReliveShopBuy)
	protocol.goods_id = goods_id
	protocol:EncodeAndSend()
end

-- 战斗商店购买
function ClashTerritoryCtrl:SendTerritoryWarReliveFightBuy(type, goods_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTerritoryWarReliveFightBuy)
	protocol.type = type
	protocol.goods_id = goods_id
	protocol:EncodeAndSend()
end

-- 请求参战队伍信息
function ClashTerritoryCtrl.SendTerritoryWarQualification()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTerritoryWarQualification)
	protocol:EncodeAndSend()
end

-- 请求埋地雷 (0 火 1 冰)
function ClashTerritoryCtrl.SendTerritorySetLandMine(landmine_type, x, y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTerritorySetLandMine)
	protocol.landmine_type = landmine_type
	protocol.pos_x = x
	protocol.pos_y = y
	protocol:EncodeAndSend()
end