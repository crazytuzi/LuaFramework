SiegewarOpenBoxPanel = SiegewarOpenBoxPanel or class("SiegewarOpenBoxPanel",WindowPanel)
local SiegewarOpenBoxPanel = SiegewarOpenBoxPanel

function SiegewarOpenBoxPanel:ctor()
	self.abName = "siegewar"
	self.assetName = "SiegewarOpenBoxPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.model = SiegewarModel:GetInstance()
	self.items = {}
	self.events = {}
end

function SiegewarOpenBoxPanel:dctor()
end

function SiegewarOpenBoxPanel:Open(data)
	self.data = data
	SiegewarOpenBoxPanel.super.Open(self)
end

function SiegewarOpenBoxPanel:LoadCallBack()
	self.nodes = {
		"nametitle/name","opentitle/open","leftcounttitle/leftcount","leftcounttitle/addbtn",
		"ScrollView/Viewport/Content","openbtn","openbtn2","icon","icon/equip_num",
		"icon2","icon2/equip_num2",
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.open = GetText(self.open)
	self.leftcount = GetText(self.leftcount)
	self.icon = GetImage(self.icon)
	self.icon2 = GetImage(self.icon2)
	self.equip_num = GetText(self.equip_num)
	self.equip_num2 = GetText(self.equip_num2)
	self:AddEvent()
	self:SetPanelSize(700, 480)
	self:SetTileTextImage("siegewar_image", "siegewar_box_title")
end

function SiegewarOpenBoxPanel:AddEvent()

	local function call_back(data)
		self.data = data
		self:UpdateInfo(data, true)
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateBoxInfo, call_back)

	local function call_back()
		self.data.remain = self.data.remain - 1
		self:UpdateInfo(self.data)
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateBoxRewards, call_back)

	local function call_back(open_type)
		if open_type == 1 then
			self:OpenNormal()
		else
			self:OpenVip()
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.RequstOpenBox, call_back)

	local function call_back(target,x,y)
		self:OpenNormal()
	end
	AddButtonEvent(self.openbtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:OpenVip()
	end
	AddButtonEvent(self.openbtn2.gameObject,call_back)
end

function SiegewarOpenBoxPanel:OpenCallBack()
	self:UpdateView()
end

function SiegewarOpenBoxPanel:UpdateView()
	local boss_id = self.data.boss_id
	local key = string.format("%s@%s@%s", boss_id, 1, 1)
	local cfg = Config.db_siegewar_box_reward[key]
	if cfg then
		local box_reward_show = String2Table(cfg.box_reward_show)
		for i=1, #box_reward_show do
			local item_id = box_reward_show[i]
			local params = {}
			params["item_id"] = item_id
			params["bind"] = 2
			params["can_click"] = true
			params["size"] = {x=90, y=90}
			local item = self.items[i] or GoodsIconSettorTwo(self.Content)
			item:SetIcon(params)
			self.items[i] = item
		end
	end
	self:UpdateInfo(self.data, true)
end

function SiegewarOpenBoxPanel:UpdateInfo(data, update_icon)
	local boss_id = self.data.boss_id
	local cfg = Config.db_siegewar_boss[boss_id]
	if update_icon then
		self.name.text = table.concat(data.summoner, ",")
		local suids, suids2 = {}, {}
		for i=1, #data.suids do
			if not suids2[data.suids[i]] then
				suids[i] = string.format("S%s", data.suids[i])
				suids2[data.suids[i]] = true
			end
		end
		self.open.text = string.format("The player of %s’s server", table.concat(suids, ","))
	end
	if cfg then
		local box_time = cfg.box_time
		self.leftcount.text = string.format("%s/%s", data.remain, box_time)
		local open_count = box_time-data.remain+1
		open_count = (open_count >= box_time and box_time or open_count)
		local key1 = string.format("%s@%s@%s", boss_id, 1, open_count)
		local key2 = string.format("%s@%s@%s", boss_id, 2, open_count)
		self.open_count = open_count
		local rewardcfg1 = Config.db_siegewar_box_reward[key1]
		if rewardcfg1 then
			local cost = String2Table(rewardcfg1.cost)[1]
			local item_id = cost[1]
			local num = cost[2]
			self.cost_id1 = item_id
			self.need_num1 = num
			local itemcfg = Config.db_item[item_id]
			local had_num = BagModel.GetInstance():GetItemNumByItemID(item_id)
			self.equip_num.text = string.format("%s/%s", had_num, num)
			if update_icon then
				GoodIconUtil.GetInstance():CreateIcon(self, self.icon, itemcfg.icon, true)
			end
		end
		local rewardcfg2 = Config.db_siegewar_box_reward[key2]
		if rewardcfg2 then
			local cost = String2Table(rewardcfg2.cost)[1]
			local item_id = cost[1]
			local num = cost[2]
			self.cost_id2 = item_id
			self.need_num2 = num
			local itemcfg = Config.db_item[item_id]
			local had_num = BagModel.GetInstance():GetItemNumByItemID(item_id)
			self.equip_num2.text = string.format("%s/%s", had_num, num)
			if update_icon then
				GoodIconUtil.GetInstance():CreateIcon(self, self.icon2, itemcfg.icon, true)
			end
		end
	end
end


function SiegewarOpenBoxPanel:CloseCallBack(  )
	if self.items then
		destroyTab(self.items)
		self.items = nil
	end

	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
end

function SiegewarOpenBoxPanel:OpenNormal()
	local boss_id = self.data.boss_id
	local cfg = Config.db_siegewar_boss[boss_id]
	if not cfg then
		return Notify.ShowText("The boss data doesn't exist")
	end
	local max_open_count = cfg.box_time
	if self.open_count > max_open_count then
		return Notify.ShowText("Attempts used up")
	end
	local had_num = BagModel.GetInstance():GetItemNumByItemID(self.cost_id1)
	if had_num > self.need_num1 then
		SiegewarController.GetInstance():RequestBoxOpen(1, self.open_count, self.data.boss_id)
	else
		local lack_num = self.need_num1 - had_num
		local vouchercfg = Config.db_voucher[self.cost_id1]
		local need_gold = vouchercfg.price*lack_num
		local gold_type = Constant.GoldIDMap[vouchercfg.type]
		local gold_name = Constant.GoldName[gold_type]
		local function ok_func()
			local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, gold_type)
			if vo then
				SiegewarController.GetInstance():RequestBoxOpen(1, self.open_count, self.data.boss_id)
			end
		end
		local message = string.format("Insufficient item, spend %s %s to open the chest?", need_gold, gold_name)
		Dialog.ShowTwo("Tip",message,"Confirm",ok_func,nil,nil,nil,nil,"Don't notice me again today",nil,nil, self.__cname .. "1")
	end
end

function SiegewarOpenBoxPanel:OpenVip()
	local cfg = Config.db_siegewar_boss[self.data.boss_id]
	if not cfg then
		return Notify.ShowText("The boss data doesn't exist")
	end
	local max_open_count = cfg.box_time
	if self.open_count > max_open_count then
		return Notify.ShowText("Attempts used up")
	end
	local need_vip = String2Table(cfg.high_box_cond)[2]
	local viplv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
	if viplv < need_vip then
		local message = string.format("Insufficient VIP level, it’s available for VIP%s", need_vip)
		local function ok_func()
			GlobalEvent:Brocast(VipEvent.OpenVipPanel)
		end
		Dialog.ShowTwo("Tip",message,"Upgrade VIP",ok_func)
		return
	end

	local had_num = BagModel.GetInstance():GetItemNumByItemID(self.cost_id2)
	if had_num > self.need_num2 then
		SiegewarController.GetInstance():RequestBoxOpen(2, self.open_count, self.data.boss_id)
	else
		local lack_num = self.need_num2 - had_num
		local vouchercfg = Config.db_voucher[self.cost_id2]
		local need_gold = vouchercfg.price*lack_num
		local gold_type = Constant.GoldIDMap[vouchercfg.type]
		local gold_name = Constant.GoldName[gold_type]
		local function ok_func()
			local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, gold_type)
			if vo then
				SiegewarController.GetInstance():RequestBoxOpen(2, self.open_count, self.data.boss_id)
			end
		end
		local message = string.format("Insufficient item, spend %s %s to open the chest?", need_gold, gold_name)
		Dialog.ShowTwo("Tip",message,"Confirm",ok_func,nil,nil,nil,nil,"Don't notice me again today",nil,nil, self.__cname .. "2")
	end
end
