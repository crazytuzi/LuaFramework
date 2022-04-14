---
--- Created by  Administrator
--- DateTime: 2019/8/1 20:45
---
PeakArenaBattlePanel = PeakArenaBattlePanel or class("PeakArenaBattlePanel", BasePanel)
local this = PeakArenaBattlePanel

function PeakArenaBattlePanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena"
	self.assetName = "PeakArenaBattlePanel"
	
	self.model = PeakArenaModel:GetInstance()
	self.events = {};
	self.gevents = {}
	self.schedules = {};
	self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()

	self.is_hide_model_effect = false
end

function PeakArenaBattlePanel:dctor()
	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.gevents)
	self.model.isOpenBattlePanel = false
	
	for i = 1, #self.schedules, 1 do
		GlobalSchedule:Stop(self.schedules[i]);
	end
	self.schedules = {};
	
	
	if self.role_update_list and self.role_data then
		for k, event_id in pairs(self.role_update_list) do
			self.role_data:RemoveListener(event_id)
		end
		self.role_update_list = nil
	end
	
	
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
	
	if self.role_icon2 then
		self.role_icon2:destroy()
		self.role_icon2 = nil
	end
end

function PeakArenaBattlePanel:Open()
	self.model.isOpenBattlePanel = true
	WindowPanel.Open(self);
end

function PeakArenaBattlePanel:LoadCallBack()
	self.nodes = {
		"myObj/myzhanl/myPower","myObj/myHp","endTime","enemyObj/enemyHp",
		"startTime/time","enemyObj/ezhanl/enemyPower","enemyObj/elevelBg/enemyLevel",
		"myObj/mlevelBg/myLevel","readyImg","startTime","endTime/endText",
		"myObj/myHead","enemyObj/eHead","myObj","myObj/mlevelBg","myObj/myzhanl",
		"enemyObj/ezhanl","enemyObj","enemyObj/elevelBg","myObj/myName","enemyObj/eName",
	}
	self:GetChildren(self.nodes)
	self.myPower = GetText(self.myPower)
	self.myHp = GetImage(self.myHp)
	self.enemyHp = GetImage(self.enemyHp)
	self.time = GetText(self.time)
	self.enemyPower = GetText(self.enemyPower)
	self.enemyLevel = GetText(self.enemyLevel)
	self.myLevel = GetText(self.myLevel)
	self.endText = GetText(self.endText)
	self.endTime.gameObject:SetActive(false);
	self.myName = GetText(self.myName)
	self.eName = GetText(self.eName)
	self.mlevelBg = GetImage(self.mlevelBg)
	self.elevelBg = GetImage(self.elevelBg)
	self:InitUI()
	self:AddEvent()
	self:InitScene()
	PeakArenaController:GetInstance():RequestBattlePrepare()
end

function PeakArenaBattlePanel:InitUI()
	self:SetMyInfo()
end

function PeakArenaBattlePanel:InitScene()
	local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT);
	if createdMonTab then
		for k, monster in pairs(createdMonTab) do
			self:HandleNewCreate(monster);
		end
	end
	
	if table.isempty(createdMonTab) then
		local createdMonTab2 = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE);
		if createdMonTab2 then
			for k, monster in pairs(createdMonTab2) do
				self:HandleNewCreate(monster);
			end
		end
		
	end
	
end

function PeakArenaBattlePanel:AddEvent()
	self.schedules[2] = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
	
	
	
	local function call_back()
		self:UpdateMainHp()
	end
	
	self.role_update_list = {}
	self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hp", call_back)
	local function call_back()
		self:UpdateMainHp()
	end
	self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hpmax", call_back)
	
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.BattleStart,handler(self,self.BattleStart))
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.BattlePrepare,handler(self,self.BattlePrepare))
	
	
	
	
	GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.gevents);
end





function PeakArenaBattlePanel:SetMyInfo()
	--self.myLevel.text = self.role_data.level
	self:SetLevel(self.role_data.level,self.mlevelBg,self.myLevel)
	self.myPower.text = self.role_data.power
	self.myName.text = self.role_data.name
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
	local param = {}
	local function uploading_cb()
		--  logError("回调")
	end
	--param["is_squared"] = true
	--param["is_hide_frame"] = true
	param["size"] = 90
	param["uploading_cb"] = uploading_cb
	param["role_data"] = self.role_data
	self.role_icon1 = RoleIcon(self.myHead)
	self.role_icon1:SetData(param)
	
	
end

function PeakArenaBattlePanel:SetEnemyInfo(role)
	self.enemyPower.text = role.power
	--self.enemyLevel.text = role.level
	self:SetLevel(role.level,self.elevelBg,self.enemyLevel)
	self.eName.text = role.name
	if self.role_icon2 then
		self.role_icon2:destroy()
		self.role_icon2 = nil
	end
	local param = {}
	local function uploading_cb()
		--  logError("回调")
	end
	--param["is_squared"] = true
	--param["is_hide_frame"] = true
	param["size"] = 90
	param["uploading_cb"] = uploading_cb
	param["role_data"] = role
	self.role_icon2 = RoleIcon(self.eHead)
	self.role_icon2:SetData(param)
end





function PeakArenaBattlePanel:HandleNewCreate(monster)
	if not monster.object_info or monster.object_info.uid == self.role_data.uid then
		return 
	end
	if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT or monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
		local call_back1 = function(hp)
			local value = hp / monster.object_info.hpmax
			if self.enemyHp then
				self.enemyHp.fillAmount = value
			end
			if monster and monster.object_info and monster.object_info.hp <= 0 then
				--call_back();
				monster.object_info:RemoveListener(self.update_blood);
			end
		end
		if not self.update_blood  then
			self.update_blood = monster.object_info:BindData("hp", call_back1);
		end

		if self.pos == 1 then
			monster:SetRotateY(255)
		else
			monster:SetRotateY(90)
		end
		self:SetEnemyInfo(monster.object_info)
	end
end

function PeakArenaBattlePanel:UpdateMainHp()
	if not self.role_data or not self.role_data.attr or not self.role_data.hp or not self.role_data.hpmax or not self.is_loaded then
		return
	end
	local value = self.role_data.hp / self.role_data.hpmax
	self.myHp.fillAmount = value
end


function PeakArenaBattlePanel:BattlePrepare(data)
	--logError("111111111111")
	--dump(data)
	self.pos = data.pos
	if self.pos == 1 then --自己的位置在左
		
	else --自己的位置在右
		SetLocalScale(self.myHead.transform,-1,1,1)
		SetLocalScale(self.myObj.transform,-1,1,1)
		SetLocalPositionX(self.myObj.transform,45)
		SetLocalScale(self.mlevelBg.transform,-1,1,1)
		SetLocalScale(self.myzhanl.transform,-1,1,1)
		SetLocalScale(self.myName.transform,-1,1,1)
		SetLocalPositionX(self.myzhanl.transform,-92)

		
		SetLocalScale(self.eHead.transform,-1,1,1)
		SetLocalScale(self.enemyObj.transform,-1,1,1)
		SetLocalPositionX(self.enemyObj.transform,-578)
		SetLocalScale(self.elevelBg.transform,-1,1,1)
		SetLocalScale(self.ezhanl.transform,-1,1,1)
		SetLocalScale(self.eName.transform,-1,1,1)
		SetLocalPositionX(self.ezhanl.transform,-360)
		
		
	end
	SetVisible(self.myObj,true)
	SetVisible(self.enemyObj,true)
end




function PeakArenaBattlePanel:BattleStart(data)
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role then
		if self.pos == 1 then
			main_role:SetRotateY(90)
		else
			--main_role:
			main_role:SetRotateY(225)
		end

	end
	self.prep_time = data.ptime
	self.end_time = data.etime
	if self.prep_time and not self.start_dungeon_time then
		self.start_dungeon_time = self.prep_time
		if self.schedules[1] then
			GlobalSchedule.StopFun(self.schedules[1])
		end
		self.endDungeonStartCountDownFun = function()
			if self.schedules[1] then
				GlobalSchedule.StopFun(self.schedules[1])
			end
			self.schedules[1] = nil
			SetGameObjectActive(self.endTime.gameObject, true)
		end
		self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 0.2, -1);
	end
	
	
end

function PeakArenaBattlePanel:StartDungeon()
	local timeTab = nil;
	local timestr = "";
	local formatTime = "%d";--"%02d";
	if self.start_dungeon_time then
		timeTab = TimeManager:GetLastTimeData(os.time(), self.start_dungeon_time);
		if table.isempty(timeTab) then
			GlobalSchedule.StopFun(self.schedules[1]);
			if self.startTime and self.startTime.gameObject then
				SetGameObjectActive(self.startTime.gameObject, false);
				SetGameObjectActive(self.readyImg.gameObject,false)
			end

			if self.endDungeonStartCountDownFun then
				self.endDungeonStartCountDownFun();
			end
			self.schedules[1] = nil;
			
			--防止自动战斗不打
			TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
			--停止自动寻路
			OperationManager:GetInstance():StopAStarMove();
			if not AutoFightManager:GetInstance():GetAutoFightState() then
				GlobalEvent:Brocast(FightEvent.AutoFight)
			end
		else
			if timeTab.sec then
				timestr = timestr .. string.format(formatTime, timeTab.sec);
			end
			self.time.text = timestr;
		end
	end
	
end
--结束倒计时
function PeakArenaBattlePanel:EndDungeon()
	--if self.end_time and self.start_dungeon_time <= 0 then
	--    self.endTime.gameObject:SetActive(true);
	--end
	local timeTab = nil;
	local timestr = "";
	local formatTime = "%02d";
	--整个副本的结束时间
	if self.end_time then
		--SetGameObjectActive(self.endTime.gameObject, true);
		timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
		if table.isempty(timeTab) then
			--Notify.ShowText("副本结束了,需要做清理了");
			
			GlobalSchedule.StopFun(self.schedules[1]);
		else
			if timeTab.min then
				timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
			end
			if timeTab.sec then
				timestr = timestr .. string.format(formatTime, timeTab.sec);
			end
			self.endText.text = timestr;
		end
	end
end

function PeakArenaBattlePanel:SetLevel(lv,lv_frame_img,nameText)
	local result = lv
	local img_idx = 1
	local critical = String2Table(Config.db_game.level_max.val)[1]
	if lv > critical then
		result = lv - critical
		img_idx = 2
	end
	lua_resMgr:SetImageTexture(self, lv_frame_img, "main_image", "img_main_role_lv_bg_" .. img_idx, false, nil, false)
	nameText.text = result
end

