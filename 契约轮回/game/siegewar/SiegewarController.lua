require('game.siegewar.RequireSiegewar')
SiegewarController = SiegewarController or class("SiegewarController",BaseController)
local SiegewarController = SiegewarController

function SiegewarController:ctor()
	SiegewarController.Instance = self
	self.model = SiegewarModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function SiegewarController:dctor()
end

function SiegewarController:GetInstance()
	if not SiegewarController.Instance then
		SiegewarController.new()
	end
	return SiegewarController.Instance
end

function SiegewarController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1609_siegewar_pb"
    self:RegisterProtocal(proto.SIEGEWAR_CITY, self.HandleCity)
    self:RegisterProtocal(proto.SIEGEWAR_BOSS, self.HandleBoss)
    self:RegisterProtocal(proto.SIEGEWAR_DAMAGE, self.HandleDamage)
    self:RegisterProtocal(proto.SIEGEWAR_MEDAL_FETCH, self.HandleMedal)
    self:RegisterProtocal(proto.SIEGEWAR_MEDAL_BUY, self.HandleBuyMedal)
    self:RegisterProtocal(proto.SIEGEWAR_BOSS_UPDATE, self.HandleBossUpdate)
    self:RegisterProtocal(proto.SIEGEWAR_BOXINFO, self.HanleBoxInfo)
    self:RegisterProtocal(proto.SIEGEWAR_BOXOPEN, self.HanleBoxOpen)
    self:RegisterProtocal(proto.SIEGEWAR_DROPPED, self.HandleDrop)
end

function SiegewarController:AddEvents()
	-- --请求基本信息
	local function call_back(id, sub_id, boss_id)
		if id == 1 and sub_id == 3 then
			local bosscfg = Config.db_siegewar_boss[boss_id]
			lua_panelMgr:GetPanelOrCreate(SiegewarBossPanel):Open(bosscfg.scene, boss_id)
		else
			lua_panelMgr:GetPanelOrCreate(SiegewarParentPanel):Open()
		end
	end
	GlobalEvent:AddListener(SiegewarEvent.OpenSiegewarPanel, call_back)


	local function call_back(uid)
		self:RequestBoxInfo(uid)
	end
	GlobalEvent:AddListener(SiegewarEvent.OpenBoxPanel, call_back)

	local function call_back(data)
		if not data.can_open then
			return Notify.ShowText("You don't have the access to open infinite chest.")
		end
		lua_panelMgr:GetPanelOrCreate(SiegewarOpenBoxPanel):Open(data)
	end
	self.model:AddListener(SiegewarEvent.UpdateBoxInfo, call_back)

	local function call_back(data, boss_id, count)
		local panel = lua_panelMgr:GetPanel(SiegewarRewardPanel)
		if not panel then
			lua_panelMgr:GetPanelOrCreate(SiegewarRewardPanel):Open(data, boss_id, count)
		end
	end
	self.model:AddListener(SiegewarEvent.UpdateBoxRewards, call_back)

	local function call_back()
		self:CheckRedDot()
	end
	self.model:AddListener(SiegewarEvent.UpdateCity, call_back)
	self.model:AddListener(SiegewarEvent.UpdateMedal, call_back)

	local role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	if role_data then
		local function call_back()
			self:CheckRedDot()
		end
		role_data:BindData("buffs", call_back)
	end
end

function SiegewarController:CheckRedDot()
	local flag = self.model:IsHaveRedDot()
	GlobalEvent:Brocast(MainEvent.ChangeRedDot, "siegewar", flag)
end

-- overwrite
function SiegewarController:GameStart()
	
end

----请求基本信息
function SiegewarController:RequestCity()
	local pb = self:GetPbObject("m_siegewar_city_tos")
	self:WriteMsg(proto.SIEGEWAR_CITY, pb)
end

----服务的返回信息
function SiegewarController:HandleCity()
	local data = self:ReadMsg("m_siegewar_city_toc")

	self.model:SetCities(data.cities)
	self.model:SetMedal(data.medal)
	self.model:SetFetch(data.fetch)
	self.model:SetRule(data.rule)
	self.model:UpdateCityIndex(data.link)
	self.model:Brocast(SiegewarEvent.UpdateCity)
end

function SiegewarController:RequestBoss(scene)
	local pb = self:GetPbObject("m_siegewar_boss_tos")
	pb.scene = scene
	self:WriteMsg(proto.SIEGEWAR_BOSS, pb)
end

function SiegewarController:HandleBoss()
	local data = self:ReadMsg("m_siegewar_boss_toc")

	self.model:SetBosses(data.scene, data.bosses)
	self.model:Brocast(SiegewarEvent.UpdateBossList, data)
end

function SiegewarController:RequestDamage(bossid)
	local pb = self:GetPbObject("m_siegewar_damage_tos")
	pb.boss = bossid
	self:WriteMsg(proto.SIEGEWAR_DAMAGE, pb)
end

function SiegewarController:HandleDamage()
	local data = self:ReadMsg("m_siegewar_damage_toc")

	GlobalEvent:Brocast(SiegewarEvent.UpdateBossDamageRank, data)
end

function SiegewarController:RequestMedal(id)
	local pb = self:GetPbObject("m_siegewar_medal_fetch_tos")
	pb.medal = id
	self:WriteMsg(proto.SIEGEWAR_MEDAL_FETCH, pb)
end

function SiegewarController:HandleMedal()
	local data = self:ReadMsg("m_siegewar_medal_fetch_toc")

	if not table.containValue(self.model.fetch, data.medal) then
		table.insert(self.model.fetch, data.medal)
	end
	self.model:Brocast(SiegewarEvent.UpdateMedal)
end

function SiegewarController:RequestBuyMedal()
	local pb = self:GetPbObject("m_siegewar_medal_buy_tos")
	self:WriteMsg(proto.SIEGEWAR_MEDAL_BUY, pb)
end

function SiegewarController:HandleBuyMedal()
	local data = self:ReadMsg("m_siegewar_medal_buy_toc")

	local _, max_medal = self.model:GetMedalRewards()
	self.model.medal = max_medal
	self.model:Brocast(SiegewarEvent.FullMedal)
end

function SiegewarController:HandleBossUpdate()
	local data = self:ReadMsg("m_siegewar_boss_update_toc")

	self.model:UpdateBoss(data)
	self.model:Brocast(SiegewarEvent.UpdateBoss, data)
end

function SiegewarController:RequestBoxInfo(uid)
	local pb = self:GetPbObject("m_siegewar_boxinfo_tos")
	pb.box_uid = uid
	self:WriteMsg(proto.SIEGEWAR_BOXINFO, pb)
end

function SiegewarController:HanleBoxInfo()
	local data = self:ReadMsg("m_siegewar_boxinfo_toc")

	self.model:Brocast(SiegewarEvent.UpdateBoxInfo, data)
end

function SiegewarController:RequestBoxOpen(type_id, count, boss_id)
	local pb = self:GetPbObject("m_siegewar_boxopen_tos")
	pb.type = type_id
	pb.boss = boss_id
	pb.times = count or 0
	self.model.open_boss_id = boss_id
	self.model.open_count = count or 0
	self:WriteMsg(proto.SIEGEWAR_BOXOPEN, pb)
end

function SiegewarController:HanleBoxOpen()
	local data = self:ReadMsg("m_siegewar_boxopen_toc")

	self.model:Brocast(SiegewarEvent.UpdateBoxRewards, data, self.model.open_boss_id, self.model.open_count)
end

function SiegewarController:RequestDrop()
	local pb = self:GetPbObject("m_siegewar_dropped_tos")
	self:WriteMsg(proto.SIEGEWAR_DROPPED, pb)
end

function SiegewarController:HandleDrop()
	local data = self:ReadMsg("m_siegewar_dropped_toc")

	self.model:Brocast(SiegewarEvent.UpdateRank, data.logs)
end
