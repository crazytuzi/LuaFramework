WarriorDungeonPanel = WarriorDungeonPanel or class("WarriorDungeonPanel", BaseItem);
local this = WarriorDungeonPanel


function WarriorDungeonPanel:ctor(parent_node, bossid)
	self.abName = "dungeon";
	self.image_ab = "dungeon_image";
	self.assetName = "WarriorDungeonPanel"
	self.layer = "UI"
	self.model = WarriorModel.GetInstance()
	self.events = {};
	self.gevents = {}
	self.schedules = {};
	self.isNeedUpdateInfo = true
	self.itemicon = {}
	self.rankItems = {}
	self.autoTime = 3
	WarriorDungeonPanel.super.Load(self)
end


function WarriorDungeonPanel:dctor()
	GlobalEvent:RemoveTabListener(self.gevents);
	self.model:RemoveTabListener(self.events);
	
	
	for k, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
	
	for k, v in pairs(self.rankItems) do
		v:destroy()
	end
	self.rankItems = {}
	if self.schedule then
		GlobalSchedule:Stop(self.schedule);
	end
	
	
	if self.meleeschedules then
		GlobalSchedule.StopFun(self.meleeschedules);
	end
	self.meleeschedules = nil;
	
	if self.autoRequestRank then
		GlobalSchedule.StopFun(self.autoRequestRank);
	end
	self.autoRequestRank = nil;
	MainModel:GetInstance():ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.warrior,false)
end

function WarriorDungeonPanel:LoadCallBack()
	self.nodes = {
		"endTime","endTime/endTitleTxt","con/contents_3","con/contents_2","con/contents_2/chakanjifen",
		"con/contents_3/close","con/contents_3/items/list_item_1", "con/contents_3/items/list_item_2", "con/contents_3/items/list_item_3", "con/contents_3/items/list_item_4", "con/contents_3/items/list_item_5",
		"con/contents_2/content_label_1","con/contents_2/content_label_3","con/contents_2/content_label_2","con/contents_2/content_label_4",
		"con/contents_2/value2","con/contents_2/value3","con/contents_2/ScrollView/Viewport/awardCon","WarriorDungeonRankItem",
		"con/contents_3/items","con/contents_3/mine/score","con/contents_3/mine/role_rank","con/contents_3/mine/role_name",
		"con/contents_2/wenhao1","con/contents_3/wenhao2","endTime/floorImg","con","con/contents_2/value5","con/contents_2/maxValue",
		"sjTitle",
	}
	self:GetChildren(self.nodes)
	self.endTitleTxt = GetText(self.endTitleTxt)
	self.content_label_1 = GetText(self.content_label_1)
	self.content_label_2 = GetText(self.content_label_2)
	self.content_label_3 = GetText(self.content_label_3)
	self.content_label_4 = GetText(self.content_label_4)
	self.value2 = GetText(self.value2)
	self.value3 = GetText(self.value3)
	self.value5 = GetText(self.value5)
	self.maxValue = GetText(self.maxValue)
	self.score = GetText(self.score)
	self.role_rank = GetText(self.role_rank)
	self.role_name = GetText(self.role_name)
	self.floorImg = GetImage(self.floorImg)
	SetLocalPosition(self.transform, 0, 0, 0);
	--SetVisible(self.sjTitle,false)

	SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Null))
	--SetAlignType(self.endTime.transform, bit.bor(AlignType.Left, AlignType.Right));
	self:InitUI();
	
	self:AddEvents();
	SetGameObjectActive(self.contents_3, false);
	WarriorController:GetInstance():RequesWarriorInfo()
	MainModel:GetInstance():ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.warrior,true)
end

function WarriorDungeonPanel:InitUI()
	
end

function WarriorDungeonPanel:AddEvents()

	local function call_back()
		ShowHelpTip(HelpConfig.Warrior.Help1,false,700)
	end
	AddButtonEvent(self.wenhao1.gameObject,call_back)

	local function call_back()
		ShowHelpTip(HelpConfig.Warrior.Help2,false,700)
	end
	AddButtonEvent(self.wenhao2.gameObject,call_back)
	
	local function call_back()
		SetGameObjectActive(self.contents_3.gameObject, false);
		--if self.autoRequestRank then
		--	GlobalSchedule.StopFun(self.autoRequestRank);
		--	self.autoRequestRank = nil;
		--end
	end
	AddClickEvent(self.close.gameObject,call_back)
	
	local function call_back() --排名
		SetGameObjectActive(self.contents_3.gameObject, not self.contents_3.gameObject.activeSelf);
		if self.contents_3.gameObject.activeSelf then
			self:HandleRequestRankInfo();
		--	if self.autoRequestRank then
		--		GlobalSchedule.StopFun(self.autoRequestRank);
		--		self.autoRequestRank = nil;
		--	end
		--	self.autoRequestRank = GlobalSchedule.StartFun(handler(self, self.HandleRequestRankInfo), 3, -1);
		--else
		--
		--	if self.autoRequestRank then
		--		GlobalSchedule.StopFun(self.autoRequestRank);
		--		self.autoRequestRank = nil;
		--	end
		end
	end
	AddClickEvent(self.chakanjifen.gameObject, call_back);
	
	
	
	local call_back = function()
		SetGameObjectActive(self.endTime.gameObject , false);
		self.hideByIcon = true;
	end
	
	self.gevents[#self.gevents + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);
	
	local call_back1 = function()
		SetGameObjectActive(self.endTime.gameObject , true);
		self.hideByIcon = nil;
	end
	
	self.gevents[#self.gevents + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);
	--self.gevents[#self.gevents + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
	self.events[#self.events + 1] = self.model:AddListener(WarriorEvent.RankInfo, handler(self, self.RankReturnList));
	
	self.events[#self.events + 1] = self.model:AddListener(WarriorEvent.WarriorInfo,handler(self,self.WarriorInfo))
	self.events[#self.events + 1] = self.model:AddListener(WarriorEvent.UpdateInfo,handler(self,self.UpdateInfo))
	self.events[#self.events + 1] = self.model:AddListener(WarriorEvent.EndInfo,handler(self,self.EndInfo))
	self.events[#self.events + 1] = self.model:AddListener(WarriorEvent.CreepInfo,handler(self,self.CreepInfo))
	--self:InitSjObject()
	--GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.gevents);
	--self:UpdateInfo()
	--if self.isNeedUpdateInfo  then
		
	--end
	self:HandleRequestRankInfo()
	if self.autoRequestRank then
		GlobalSchedule.StopFun(self.autoRequestRank);
		self.autoRequestRank = nil;
	end
	self.autoRequestRank = GlobalSchedule.StartFun(handler(self, self.HandleRequestRankInfo), 3, -1);

end

function WarriorDungeonPanel:HandleSceneChange()
	--self.sjschedule = GlobalSchedule.StartFunOnce(handler(self, self.InitSjObject), 1);
	self:InitSjObject()
end

function WarriorDungeonPanel:HandleNewCreate(monster)
	--if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
	--	logError(monster.object_id)
	--end
	--if monster.object_id == 30396001 then
	--	SetVisible(self.sjTitle,true)
	--end
end

function WarriorDungeonPanel:InitSjObject()
	local objects = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
	if objects then
		for k, monster in pairs(objects) do
			if monster.object_id == 30396001 then
				SetVisible(self.sjTitle,true)
			end
		end
	end

end


function WarriorDungeonPanel:CreepInfo(data)
	if self.model.creepState == 1 then
		SetGameObjectActive(self.sjTitle,true)
		if self.autoHide then
			GlobalSchedule.StopFun(self.autoHide);
			self.autoHide = nil;
		end
		self.autoHide = GlobalSchedule.StartFun(handler(self, self.HideTitle), 1, -1);
	end
end

function WarriorDungeonPanel:HideTitle()
	self.autoTime  = self.autoTime - 1
	if self.autoTime <= 0 then
		self.autoTime = 3
		GlobalSchedule.StopFun(self.autoHide);
		SetGameObjectActive(self.sjTitle,false)
	end
end



function WarriorDungeonPanel:UpdateFloorInfo()
	local floor = self.model.floor
	local score = self.model.score
	local kill = self.model.kill
	--logError(floor)
	--self:InitSjObject()
	local cfg = Config.db_warrior_floor[floor + 1]
	if not cfg then
		 cfg = Config.db_warrior_floor[floor]
	end
	local  curCfg = Config.db_warrior_floor[floor]
	local killTarget = curCfg.kill_target


	if killTarget == 0 then
		--self.value2.text = "击败敌人(安全复活会概率掉层)"
		self.content_label_1.text = "Top stage rules:"
	--19DB14
		local num = math.floor(cfg.prob/100)

		self.maxValue.text = string.format("Normal resurrection has <color=#19DB14>%s%s</color> chance to lower the stage",num,"%")
		SetVisible(self.maxValue,true)
		SetVisible(self.value2,false)
		SetVisible(self.content_label_2,false)
		self.content_label_4.text = string.format("Ranking Rewards:",ChineseNumber(floor))
		--self:CreepInfo()
		local rewardCfg = self.model:GetRewardCfg(1)
		local gain = rewardCfg.gain
		if SceneManager:GetInstance():IsCrossScene(SceneManager:GetInstance():GetSceneId()) then
			gain = rewardCfg.cross_gain
		end
		self:CreateIcon(gain)
	else
		self.value2.text = string.format("%s/%s",kill,killTarget)
		self.content_label_1.text = string.format("F%s Require:",ChineseNumber(floor))
		self.content_label_2.text = "Defeating score:"
		self.content_label_3.text = "Current points:"
		self.content_label_4.text = string.format("F%s Cleared Reward:",ChineseNumber(floor))
		SetVisible(self.value2,true)
		SetVisible(self.content_label_2,true)
		SetVisible(self.maxValue,false)

		local gain = cfg.gain
		--logError(SceneManager:GetInstance():IsCrossScene(SceneManager:GetInstance():GetSceneId()) )
		if SceneManager:GetInstance():IsCrossScene(SceneManager:GetInstance():GetSceneId()) then
			gain = cfg.cross_gain
		end
		self:CreateIcon(gain)
	end
	self.value3.text = score
	lua_resMgr:SetImageTexture(self, self.floorImg, "dungeon_image", "warrior_floor_"..floor, false, nil, false)

	
end

function WarriorDungeonPanel:CreateIcon(gain)
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
	local rewardTab = String2Table(gain)
	--local rewardTab = String2Table(self.data.reward)
	for i = 1, #rewardTab do
		--self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
		if self.itemicon[i] == nil then
			self.itemicon[i] = GoodsIconSettorTwo(self.awardCon)
		end
		local param = {}
		param["model"] = BagModel
		param["item_id"] = rewardTab[i][1]
		local num = rewardTab[i][2]
		local level = RoleInfoModel:GetInstance():GetMainRoleLevel();
		if Config.db_exp_acti_base[level] and rewardTab[i][1]== enum.ITEM.ITEM_PLAYER_EXP then
			 num = Config.db_exp_acti_base[level].worldlv_exp * rewardTab[i][2];
		end
		param["num"] = num
		--param["bind"] = rewardTab[i][3]
		param["can_click"] = true
		param["size"] = {x = 78,y = 78}
		self.itemicon[i]:SetIcon(param)
	end
end


function WarriorDungeonPanel:WarriorInfo(data)
	--dump(data)
	--logError("---1----")
	if not AutoFightManager:GetInstance():GetAutoFightState() then
		GlobalEvent:Brocast(FightEvent.AutoFight)
	end

	self.isNeedUpdateInfo = false
	self.end_time = data.end_time;
	self.meleeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
end


function WarriorDungeonPanel:UpdateInfo(data)
	--logError("更新信息")
	--self.model.floor = data.floor
	--self.model.score = data.score
	--self.model.kill = data.kill
	self:UpdateFloorInfo()
end

function WarriorDungeonPanel:EndInfo(data)
	--logError("结算")
end


function WarriorDungeonPanel:EndDungeon()
	local timeTab = nil;
	local timestr = "";
	local formatTime = "%02d";
	--整个副本的结束时间
	if self.end_time then
		if not self.startSchedule and not self.hideByIcon then
			SetGameObjectActive(self.endTime.gameObject, true);
		else
			SetGameObjectActive(self.endTime.gameObject, false);
		end
		
		timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
		if table.isempty(timeTab) then
			--logError("---222----")
			--Notify.ShowText("副本结束了,需要做清理了");
			GlobalSchedule.StopFun(self.meleeschedules);
		else
			timeTab.min = timeTab.min or 0;
			if timeTab.min then
				timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
			end
			if timeTab.sec then
				timestr = timestr .. string.format(formatTime, timeTab.sec);
			end
			self.endTitleTxt.text = timestr;--"副本倒计时: " ..
		end
	end
end

function WarriorDungeonPanel:HandleRequestRankInfo()
	--RankController:GetInstance():RequestRankListInfo(1013,1)
	WarriorController:GetInstance():RequesRankInfo(5)
end

function WarriorDungeonPanel:RankReturnList(data)
	self:UpdateRankItems(data.list)	
	self:SetMineInfo(data)
	dump(data)
end

function WarriorDungeonPanel:SetMineInfo(data)
	local mine = data.mine
	local rank = mine.rank
	self.rank = mine.rank
	local role = RoleInfoModel.GetInstance():GetMainRoleData()
	self.score.text = mine.sort
	self.role_name.text = role.name
	if rank == 0 then
		--self.score = GetText(self.score)
		--self.role_rank = GetText(self.role_rank)
		--self.role_name = GetText(self.role_name)
		self.value5.text = "Didn't make list"
		self.role_rank.text = #data.list.."+"
	else
		self.role_rank.text  = mine.rank
		self.value5.text = mine.rank
	end
end

function WarriorDungeonPanel:UpdateRankItems(tab)
	for i = 1, 5 do
		local item = self.rankItems[i]
		if not item then
			item = WarriorDungeonRankItem(self.WarriorDungeonRankItem.gameObject,self.items,"UI")
			self.rankItems[i] = item
			--item:SetData(tab[i],i)
			--else
			--item:SetData(tab[i],i)
		end
		item:SetData(tab[i],i)
	end
end