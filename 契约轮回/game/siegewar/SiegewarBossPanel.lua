SiegewarBossPanel = SiegewarBossPanel or class("SiegewarBossPanel",WindowPanel)
local SiegewarBossPanel = SiegewarBossPanel

function SiegewarBossPanel:ctor()
	self.abName = "siegewar"
	self.assetName = "SiegewarBossPanel"
	self.layer = "UI"

	self.panel_type = 2								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.is_hide_other_panel = true
	self.events = {}
	self.global_events = {}
	self.boss_list = {}
	self.reward_list = {}
	self.point_list = {}
	self.model = SiegewarModel:GetInstance()
end

function SiegewarBossPanel:dctor()
end

function SiegewarBossPanel:Open(scene, boss_id)
	self.data = scene
	self.default_bossid = boss_id
	SiegewarBossPanel.super.Open(self)
end

function SiegewarBossPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","ScrollView/Viewport/Content/SiegewarBossItem",
		"ScrollView/Viewport/DropContent","ScrollView/Viewport/OccupyContent",
		"rewardtitle2/medal","rewardtitle3/tired","enterbtn","rightbg/occupyserver",
		"rightbg/ScrollView/Viewport/PointContent","rightbg/tip3",
		"rightbg/ScrollView/Viewport/PointContent/SiegewarPointItem",
		"bg","occtext",
	}
	self:GetChildren(self.nodes)
	self.SiegewarBossItem_go = self.SiegewarBossItem.gameObject
	SetVisible(self.SiegewarBossItem_go, false)
	self.SiegewarPointItem_go = self.SiegewarPointItem.gameObject
	SetVisible(self.SiegewarPointItem_go, false)
	self.medal = GetText(self.medal)
	self.tired = GetText(self.tired)
	self.tip3 = GetText(self.tip3)
	self.occupyserver = GetText(self.occupyserver)
	self.bg = GetImage(self.bg)
	self.occtext = GetText(self.occtext)
	self:AddEvent()
	self:SetTileTextImage("siegewar_image", "siegewartitle_img")
	local res = "siegewar__big_bg"
	lua_resMgr:SetImageTexture(self,self.bg, "iconasset/icon_big_bg_" .. res, res, false)
	local score = String2Table(Config.db_game["siegewar_win_score"].val)[1]
	self.occtext.text = string.format("The first one earned %s points will capture the city", score)
end

function SiegewarBossPanel:AddEvent()
	local function call_back(data)
		self.scene_info = data
		self:UpdateInfo()
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateBossList, call_back)

	local function call_back(bossid)
		local order = self.model:GetBossOrder()
		local key = string.format("%s@%s", bossid, order)
		local bosscfg = Config.db_siegewar_belong_reward[key]
		local drops = String2Table(bosscfg.drop_reward_show)
		local joins = String2Table(bosscfg.seize_reward_show)
		destroyTab(self.reward_list)
		self.reward_list = {}
		for i=1, #drops do
			local param = {}
			param["can_click"] = true
			param["item_id"] = drops[i]
			param["bind"] = 2
			local item = GoodsIconSettorTwo(self.DropContent)
			item:SetIcon(param)
			self.reward_list[#self.reward_list+1] = item
		end
		for i=1, #joins do
			local param = {}
			param["can_click"] = true
			param["item_id"] = joins[i]
			param["bind"] = 2
			local item = GoodsIconSettorTwo(self.OccupyContent)
			item:SetIcon(param)
			self.reward_list[#self.reward_list+1] = item
		end
		local bosscfg2 = Config.db_siegewar_boss[bossid]
		self.tip3.text = string.format("Defeat the boss so you can get <color=#03f2ec>%s</color> points", bosscfg2.score)
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.ClickBoss, call_back)

	local function call_back(sceneid)
		local scenecfg = Config.db_scene[sceneid]
		if scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR then
			self:Close()
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EventName.EndHandleTimeline, call_back)

	local function call_back(target,x,y)
		local city = self.model.cities[self.data]
		if city.level == 2 then
			local index = self.model:GetCityIndex(2, self.data)
			if not self.model:IsCanAttackMCity(index) then
				return Notify.ShowText("You can only attack cities on the same server and middle cities nearby")
			end
		elseif city.level == 3 then
			if not self.model:IsCanAttackBCity() then
				local scenecfg = Config.db_scene[self.data]
				return Notify.ShowText(string.format("Before attacking %s, you need to capture the cities of the previous level", scenecfg.name))
			end
		end
		local scene_id = SceneManager:GetInstance():GetSceneId()
		if scene_id == self.data then
			local bosscfg = Config.db_siegewar_boss[self.model.select_boss]
			if bosscfg then
				local coord = String2Table(bosscfg.coord)
				OperationManager:GetInstance():TryMoveToPosition(nil, nil, { x = coord[1], y = coord[2] })
			end
		else
			SceneControler.GetInstance():RequestSceneChange(self.data, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 11121)
		end
	end
	AddButtonEvent(self.enterbtn.gameObject,call_back)
end

function SiegewarBossPanel:OpenCallBack()
	self:UpdateView()
end

function SiegewarBossPanel:UpdateView( )

end

function SiegewarBossPanel:CloseCallBack(  )
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end
	if self.boss_list then
		destroyTab(self.boss_list)
		self.boss_list = nil
	end
	if self.reward_list then
		destroyTab(self.reward_list)
		self.reward_list = nil
	end
	if self.point_list then
		destroyTab(self.point_list)
		self.point_list = nil
	end
end
function SiegewarBossPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
end

function SiegewarBossPanel:UpdateView()
	if self.data then
		SiegewarController.GetInstance():RequestBoss(self.data)
		self.medal.text = self.model.medal
		self.tired.text = string.format("%s/%s", self.model:GetTired())
	end
end

function SiegewarBossPanel:UpdateInfo()
	local bosses = self.scene_info.bosses
	local bosslist = {}
	for i=1, #bosses do
		local bosscfg = Config.db_siegewar_boss[bosses[i].id]
		local boss = {}
		boss.id = bosses[i].id
		boss.born = bosses[i].born
		boss.order = bosscfg.order
		bosslist[#bosslist+1] = boss
	end

	local function sort_fun(a, b)
		return a.order < b.order
	end
	table.sort(bosslist, sort_fun)
	destroyTab(self.boss_list)
	self.boss_list = {}
	for i=1, #bosslist do
		local item = SiegewarBossItem(self.SiegewarBossItem_go, self.Content)
		item:SetData(bosslist[i])
		self.boss_list[i] = item
	end
	if self.default_bossid then
		self.model:Brocast(SiegewarEvent.ClickBoss, self.default_bossid)
	else
		self.model:Brocast(SiegewarEvent.ClickBoss, bosslist[1].id)
	end
	if self.model.rule == 0 then
		if self.scene_info.name ~= "" then
			self.occupyserver.text = string.format("%S occupied", self.scene_info.name)
		else
			self.occupyserver.text = "None"
		end
	else
		if self.scene_info.suid > 0 then
			local city = self.model.cities[self.data]
			if city.temp and city.level == 2 then
				self.occupyserver.text = string.format("Occupied by S%s (temporary)", RoleInfoModel:GetInstance():GetServerName(self.scene_info.suid))
			else
				self.occupyserver.text = string.format("Occupied by S%s", RoleInfoModel:GetInstance():GetServerName(self.scene_info.suid))
			end
		else
			self.occupyserver.text = "None"
		end
	end
	destroyTab(self.point_list)
	self.point_list = {}
	for i=1, #self.scene_info.score do
		local item = SiegewarPointItem(self.SiegewarPointItem_go, self.PointContent)
		item:SetData(self.scene_info.score[i])
		self.point_list[#self.point_list+1] = item
	end
end