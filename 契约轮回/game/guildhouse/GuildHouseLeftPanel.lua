GuildHouseLeftPanel = GuildHouseLeftPanel or class("GuildHouseLeftPanel",BaseItem)
local GuildHouseLeftPanel = GuildHouseLeftPanel
local ostime = os.time

function GuildHouseLeftPanel:ctor(parent_node,layer)
	self.abName = "guild_house"
	self.assetName = "GuildHouseLeftPanel"
	self.layer = layer

	self.model = GuildHouseModel:GetInstance()
	GuildHouseLeftPanel.super.Load(self)

	self.cards_list = {}
	self.global_events = {}
	self.events = {}
	self.schedule = nil
	self.countdownitem_isfinish = false
end

function GuildHouseLeftPanel:dctor()
	for i=1, #self.cards_list do 
		self.cards_list[i]:destroy()
	end
	for i=1, #self.global_events do
		GlobalEvent:RemoveListener(self.global_events[i])
	end
	for i=1, #self.events do
		self.model:RemoveListener(self.events[i])
	end
	if self.countdownitem then
		self.countdownitem:StopSchedule()
		self.countdownitem = nil
	end
	if self.schedule then
		GlobalSchedule:Stop(self.schedule)
		self.schedul = nil
	end
	if self.question_reddot then
		self.question_reddot:destroy()
		self.question_reddot = nil
	end
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
	if self.reddot1 then
		self.reddot1:destroy()
		self.reddot1 = nil
	end
	if self.reddot2 then
		self.reddot2:destroy()
		self.reddot2 = nil
	end
	if self.reddot3 then
		self.reddot3:destroy()
		self.reddot3 = nil
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function GuildHouseLeftPanel:LoadCallBack()
	self.nodes = {
		"bg2/cardbtn","cards","cards/bg3/card1","cards/bg3/card2","cards/bg3/card3",
		"bg2/infobtn","cards/usebtn1","cards/bg3/card1/num1","cards/bg3/card2/num2",
		"cards/bg3/card3/num3","cards/usebtn2","cards/usebtn3","center","center/pr/countdown",
		"cards/closebtn","center/pr/title","bg2/exp","bg/questionbtn","bg/boss","bg/boss/boss_order",
		"center/bg3", "center/bg3/boss_score", "center/bg3/left_time","center/bg",
		"bg/nostart/time_title/time_pre","bg/nostart/bg2/time_title/time_pre2","bg2",
		"bg/nostart","bg/nostart/bg2/headbg/ordertxt",
	}
	self:GetChildren(self.nodes)
	self.num1 = GetText(self.num1)
	self.num2 = GetText(self.num2)
	self.num3 = GetText(self.num3)
	self.title = GetText(self.title)
	self.boss_order = GetText(self.boss_order)
	self.exp = GetText(self.exp)
	self.boss_score = GetImage(self.boss_score)
	self.left_time = GetText(self.left_time)
	self.time_pre = GetText(self.time_pre)
	self.time_pre2 = GetText(self.time_pre2)
	self.ordertxt = GetText(self.ordertxt)
	self:AddEvent()
	SetVisible(self.cards, false)
	SetVisible(self.center, false)
	self.schedule = GlobalSchedule:Start(handler(self,self.CountDown), 1)

	RoleInfoController:GetInstance():RequestWorldLevel()
	GuildHouseController:GetInstance():RequestBossTime()
end

function GuildHouseLeftPanel:AddEvent()
	local function call_back(target,x,y)
		SetVisible(self.cards, true)
		self:ShowCards()
	end
	AddClickEvent(self.cardbtn.gameObject,call_back)

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.GuildHouse.tips, true)
		--[[local data = {}
		data.rank = 1
		data.score = 100
		data.rewards = {[50000]=10}
		self.model:Brocast(GuildHouseEvent.QuestionResult, data)--]]
	end
	AddClickEvent(self.infobtn.gameObject,call_back)

	local function call_back(target,x,y)
		if not self.model:CanCallBoss() then
			Notify.ShowText("Boss summoning is not started yet")
			return
		end
		if BagModel:GetInstance():GetItemNumByItemID(self.model.card_id1) < 0 then
			Notify.ShowText("Not enough summoning cards")
			return
		end
		GuildHouseController:GetInstance():RequestCallBoss(self.model.card_id1)
	end
	AddClickEvent(self.usebtn1.gameObject,call_back)

	local function call_back(target,x,y)
		if not self.model:CanCallBoss() then
			Notify.ShowText("Boss summoning is not started yet")
			return
		end
		if BagModel:GetInstance():GetItemNumByItemID(self.model.card_id2) < 0 then
			Notify.ShowText("Not enough summoning cards")
			return
		end
		GuildHouseController:GetInstance():RequestCallBoss(self.model.card_id2)
	end
	AddClickEvent(self.usebtn2.gameObject,call_back)

	local function call_back(target,x,y)
		if not self.model:CanCallBoss() then
			Notify.ShowText("Boss summoning is not started yet")
			return
		end
		if BagModel:GetInstance():GetItemNumByItemID(self.model.card_id3) < 0 then
			Notify.ShowText("Not enough summoning cards")
			return
		end
		GuildHouseController:GetInstance():RequestCallBoss(self.model.card_id3)
	end
	AddClickEvent(self.usebtn3.gameObject,call_back)

	local function call_back(target,x,y)
		SetVisible(self.cards, false)
	end
	AddClickEvent(self.closebtn.gameObject,call_back)

	local function call_back(target,x,y)
		--lua_panelMgr:GetPanelOrCreate(GuildQuestionPanel):Open()
		self.model.is_opened_panel = nil
		GuildHouseController:GetInstance():RequestQuestion()
	end
	AddClickEvent(self.questionbtn.gameObject,call_back)

	local function call_back()
		self:ShowCards()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

	local function call_back(worldlv)
		local order_str = self.model:GetBossOrder(worldlv) .. "Stage"
		self.boss_order.text = order_str
		self.ordertxt.text = order_str
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(RoleInfoEvent.QUERY_WORLD_LEVEL, call_back)

	local function call_back(exp)
		self.exp.text = "+" .. string.gsub(GetShowNumber(exp), "%.", "dot")
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.UpdateExpEvent, call_back)

	local function call_back(start_time)
		self:BossCountdown(start_time)
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.BossStart, call_back)

	local function call_back()
		if self.schedule_id then
			GlobalSchedule:Stop(self.schedule_id)
			self.schedule_id = nil
			SetVisible(self.bg3, false)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(GuildHouseEvent.BossFinish, call_back)
end

function GuildHouseLeftPanel:SetData(data)

end

function GuildHouseLeftPanel:BossCountdown(start_time)
	if self.schedule_id then
		return
	end
	if start_time > 0 then
		self.score, self.end_time = self.model:GetBossScore(start_time)
		if self.score then
			SetVisible(self.bg3, true)
			lua_resMgr:SetImageTexture(self,self.boss_score, 'guild_house_image', self.score, true)
			local function call_back()
				local interval = self.end_time - (os.time()-start_time)
				if interval >= 0 then
					self.left_time.text = interval
				else
					self.score, self.end_time = self.model:GetBossScore(start_time)
					if self.score then
						lua_resMgr:SetImageTexture(self,self.boss_score, 'guild_house_image', self.score, true)
					else
						GlobalSchedule:Stop(self.schedule_id)
						self.schedule_id = nil
						SetVisible(self.bg3, false)
					end
				end
			end
			self.schedule_id = GlobalSchedule:Start(call_back, 0.33)
		else
			if self.schedule_id then
				GlobalSchedule:Stop(self.schedule_id)
				self.schedule_id = nil
			end
			SetVisible(self.bg3, false)
		end
	end
end

function GuildHouseLeftPanel:UpdateView()
	local activity = ActivityModel:GetInstance():GetActivity(self.model.activity_id)
	if activity then
		SetVisible(self.nostart, false)
		SetVisible(self.bg2 , true)
		if self.model:IsInQuestion() then
			SetVisible(self.boss, false)
			SetVisible(self.questionbtn, true)
			if not self.question_reddot then
				self.question_reddot = RedDot(self.questionbtn.transform)
				SetLocalPosition(self.question_reddot.transform, 14, 18)
				SetVisible(self.question_reddot, true)
			end
		else
			SetVisible(self.boss, true)
			SetVisible(self.questionbtn, false)
			if self.question_reddot then
				self.question_reddot:destroy()
				self.question_reddot = nil
			end
		end
		self:UpdateRedDot()
	else
		SetVisible(self.nostart, true)
		SetVisible(self.boss, false)
		SetVisible(self.questionbtn, false)
		SetVisible(self.bg2 , false)
		SetVisible(self.center, false)
		local activitycfg = Config.db_activity[self.model.activity_id]
		local timetab = String2Table(activitycfg.time)
		local hour = timetab[1][1]
		local min = timetab[1][2]
		local hour2 = timetab[2][1]
		local min2 = timetab[2][2]
		self.time_pre.text = string.format("%s:%s-%s:%s", hour, min, hour, min+10)
		self.time_pre2.text = string.format("%s:%s-%s:%s", hour, min+10, hour2, min2)
	end
end

function GuildHouseLeftPanel:UpdateRedDot()
	if not self.model:CanCallBoss() then
		return
	end
	local num1 = BagModel:GetInstance():GetItemNumByItemID(self.model.card_id1)
	local num2 = BagModel:GetInstance():GetItemNumByItemID(self.model.card_id2)
	local num3 = BagModel:GetInstance():GetItemNumByItemID(self.model.card_id3)
	if num1>0 or num2>0 or num3>0 then
		if not self.reddot then
			self.reddot = RedDot(self.cardbtn.transform)
			SetLocalPosition(self.reddot.transform, 31, 12)
			SetVisible(self.reddot, true)
		end
	else
		if self.reddot then
			self.reddot:destroy()
			self.reddot = nil
		end
	end
	if num1>0 then
		if not self.reddot1 then
			self.reddot1 = RedDot(self.usebtn1.transform)
			SetLocalPosition(self.reddot1.transform, 31, 10)
			SetVisible(self.reddot1, true)
		end
	else
		if self.reddot1 then
			self.reddot1:destroy()
			self.reddot1 = nil
		end
	end
	if num2>0 then
		if not self.reddot2 then
			self.reddot2 = RedDot(self.usebtn2.transform)
			SetLocalPosition(self.reddot2.transform, 31, 10)
			SetVisible(self.reddot2, true)
		end
	else
		if self.reddot2 then
			self.reddot2:destroy()
			self.reddot2 = nil
		end
	end
	if num3>0 then
		if not self.reddot3 then
			self.reddot3 = RedDot(self.usebtn3.transform)
			SetLocalPosition(self.reddot3.transform, 31, 10)
			SetVisible(self.reddot3, true)
		end
	else
		if self.reddot3 then
			self.reddot3:destroy()
			self.reddot3 = nil
		end
	end
end

function GuildHouseLeftPanel:ShowCards()
	local param = {
		item_id = self.model.card_id1,
		num = BagModel:GetInstance():GetItemNumByItemID(self.model.card_id1),
		can_click = true
	}
	local item = self.cards_list[1] or GoodsIconSettorTwo(self.card1)
	item:SetIcon(param)
	self.num1.text = param.num
	self.cards_list[1] = item
	local param2 = {
		item_id = self.model.card_id2,
		num = BagModel:GetInstance():GetItemNumByItemID(self.model.card_id2),
		can_click = true
	}
	local item2 = self.cards_list[2] or GoodsIconSettorTwo(self.card2)
	item2:SetIcon(param2)
	self.num2.text = param2.num
	self.cards_list[2] = item2
	local param3 = {
		item_id = self.model.card_id3,
		num = BagModel:GetInstance():GetItemNumByItemID(self.model.card_id3),
		can_click = true
	}
	local item3 = self.cards_list[3] or GoodsIconSettorTwo(self.card3)
	item3:SetIcon(param3)
	self.num3.text = param3.num
	self.cards_list[3] = item3
	self:UpdateRedDot()
end

--倒计时
function GuildHouseLeftPanel:CountDown()
	local activity = ActivityModel:GetInstance():GetActivity(self.model.activity_id)
	local now = os.time()
	if activity then
		local question_start_time = activity.stime+60
		local question_end_time = activity.stime+555
		local callboss_start_time = activity.stime+600
		if now < question_start_time then
			self.title.text = "Guild quiz is going to start"
			SetVisible(self.center, true)
			self:NewCountDown()
			if not self.countdownitem_isstart then
				self.countdownitem_isstart = true
				self.countdownitem:StartSechudle(question_start_time, handler(self,self.Finish))
			end
		end

		self:QuestionEndSchedule(activity)
		self:CallBossPreSchedule(activity)
		self:ActivityEndSchedule(activity)
	else
		self.countdownitem_isstart = false
		SetVisible(self.center, false)
	end
	self:UpdateView()
end

function GuildHouseLeftPanel:NewCountDown()
	if not self.countdownitem then
		local param = {
		    isShowMin = true,
			duration = 0.033,
			split = "：",
		}
		self.countdownitem = CountDownText(self.countdown, param)
	else
		self.countdownitem:ActiveText()
	end
end

--答题结束倒计时
function GuildHouseLeftPanel:QuestionEndSchedule(activity)
	local now = ostime()
	if now >= activity.stime + 60 and now < activity.stime+560 then
		self.title.text = "Guild quiz countdown"
		SetVisible(self.center, true)
		self:NewCountDown()
		if not self.countdownitem_isstart then
			self.countdownitem_isstart = true 
			self.countdownitem:StartSechudle(activity.stime+560, handler(self,self.Finish))
		end
	end
end

function GuildHouseLeftPanel:CallBossPreSchedule( activity )
	local now = ostime()
	if now >= activity.stime + 560 and now < activity.stime + 600 then
		self.title.text = "Boss summoning is going to start"
		SetVisible(self.center, true)
		self:NewCountDown()
		if not self.countdownitem_isstart then
			self.countdownitem_isstart = true
			self.countdownitem:StartSechudle(activity.stime+600, handler(self,self.Finish))
		end
	end
end

function GuildHouseLeftPanel:ActivityEndSchedule( activity )
	local now = ostime()
	if now >= activity.stime+600 and now < activity.etime then
		self.title.text = "Guild boss countdown"
		SetVisible(self.center, true)
		self:NewCountDown()
		if not self.countdownitem_isstart then
			self.countdownitem_isstart = true 
			self.countdownitem:StartSechudle(activity.etime, handler(self,self.Finish))
		end
	end
end

function GuildHouseLeftPanel:Finish()
	self.countdownitem_isstart = false
	if self.model:CanCallBoss() then
		self:UpdateRedDot()
	end
end


