TimeBossLeftPanel = TimeBossLeftPanel or class("TimeBossLeftPanel",BaseItem)
local TimeBossLeftPanel = TimeBossLeftPanel

function TimeBossLeftPanel:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "TimeBossLeftPanel"
	self.layer = layer

	self.events = {}
	self.global_events = {}
	self.rank_items = {}
	self.sprite_list = {}
	self.model = TimeBossModel:GetInstance()
	TimeBossLeftPanel.super.Load(self)
end

function TimeBossLeftPanel:dctor()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	if self.rank_items then
		destroyTab(self.rank_items)
		self.rank_items = nil
	end
	if self.countdown_item then
		self.countdown_item:destroy()
		self.countdown_item = nil
	end
	if self.sprite_list then
		for i=1, #self.sprite_list do
	    	self.sprite_list[i] = nil
	    end
	    self.sprite_list = nil
	end
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.action then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.saizi)
        self.action = nil
    end
    if self.global_events then
    	GlobalEvent:RemoveTabListener(self.global_events)
    	self.global_events = nil
    end
end

function TimeBossLeftPanel:LoadCallBack()
	self.nodes = {
		"left/leftbg/ScrollView/Viewport/Content","left/leftbg/ScrollView/Viewport/Content/TimeBossRankItem",
		"left/leftbg/myranktitle/myrank","left/highpointbg","left/highpointbg/btnclose",
		"left/highpointbg/highpoint","left/highpointbg/saizibg","left/highpointbg/saizibg/saizi",
		"left/highpointbg/saizibg/saizinum","left/highpointbg/name","left/highpointbg/saizibg/countdown",
	}
	self:GetChildren(self.nodes)
	self.TimeBossRankItem_go = self.TimeBossRankItem.gameObject
	SetVisible(self.TimeBossRankItem_go, false)
	self.myrank = GetText(self.myrank)
	self.highpoint = GetText(self.highpoint)
	self.saizinum = GetText(self.saizinum)
	self.name = GetText(self.name)
	self.saizi = GetImage(self.saizi)
	self:AddEvent()

	SetVisible(self.highpointbg, false)
	if self.model.dice_etime > os.time() then
		self:UpdateDice(self.model.dice_etime)
	end
	self:LoadSprite()
	self:RequestRank()
	if not self.schedule_id then
		self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestRank), 5)
	end
	AutoFightManager:GetInstance():StartAutoFight()
end

function TimeBossLeftPanel:AddEvent()
	local function call_back(target,x,y)
		SetVisible(self.highpointbg, false)
	end
	AddClickEvent(self.btnclose.gameObject,call_back)

	local function call_back(target,x,y)
		local now_time = os.time()
		if self.model.dice_etime > now_time then
			if self.model.dice_etime - now_time >= 2 then
				self:PlaySeziAnimate(6)
			else
				TimeBossController.GetInstance():RequestDicing()
			end
		end
	end
	AddClickEvent(self.saizibg.gameObject,call_back)

	local function call_back(data)
		self:UpdateRanking(data)
	end
	self.events[#self.events+1] = self.model:AddListener(TimeBossEvent.UpdateRanking, call_back)

	local function call_back(etime)
		self:UpdateDice(etime)
	end
	self.events[#self.events+1] = self.model:AddListener(TimeBossEvent.DiceNotice, call_back)

	local function call_back(data)
		if data.score > 0 then
			SetVisible(self.saizi, false)
			SetVisible(self.saizinum, true)
			self.saizinum.text = data.score
		end
		if data.highest > 0 then
			self.highpoint.text = string.format("%s pts", data.highest)
			self.name.text = data.owner
		end
	end
	self.events[#self.events+1] = self.model:AddListener(TimeBossEvent.DiceResult, call_back)

	local function call_back()
		self:destroy()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function TimeBossLeftPanel:SetData(data)

end

function TimeBossLeftPanel:RequestRank()
	TimeBossController.GetInstance():RequestRanking()
end

function TimeBossLeftPanel:UpdateRanking(data)
	local rank = data.ranking or {}
	local my_rank = data.my_rank
	local my_dmg = data.my_dmg
	local function sort_rank(a, b)
		return a.rank < b.rank
	end
	table.sort(rank, sort_rank)
	for i=1, #rank do
		local item = self.rank_items[i] or TimeBossRankItem(self.TimeBossRankItem_go, self.Content)
		item:SetData(rank[i])
		item:SetVisible(true)
		self.rank_items[i] = item
	end

	if #self.rank_items > #rank then
		for i=#rank+1, #self.rank_items do
			if self.rank_items[i] then
				self.rank_items[i]:SetVisible(false)
			end
		end
	end
	if my_rank > 0 then
		self.myrank.text = my_rank
	else
		if my_dmg/100 < 10 then
			self.myrank.text = string.format("N/A (%0.2f)", my_dmg/100) .. "%"
		else
			self.myrank.text = string.format("N/A (%0.1f)", my_dmg/100) .. "%"
		end
	end
end

function TimeBossLeftPanel:UpdateDice(etime)
	SetVisible(self.highpointbg, true)
	SetVisible(self.saizi, true)
	SetVisible(self.saizinum, false)
	self.highpoint.text = self.model.highest or ""
	self.name.text = self.model.owner or ""
	if not self.countdown_item then
		local param = {
			isShowMin = false,
			formatTime = "%d",
		}
		self.countdown_item = CountDownText(self.countdown, param)
		local function end_func()
			SetVisible(self.highpointbg, false)
			self.countdown_item:destroy()
			self.countdown_item = nil
			self.model.highest = ""
			self.model.owner = ""
		end
		self.countdown_item:StartSechudle(etime, end_func)
	end
end

function TimeBossLeftPanel:LoadSprite()
	local arr_spirite = {"saizi_1_2","saizi_2_2","saizi_3_2","saizi_4_2",
		"saizi_5_2","saizi_6_2","saizi_7_2","saizi_8_2","saizi_9_2",
	"saizi_1","saizi_2","saizi_3","saizi_4","saizi_5","saizi_6"}
	
	for i=1, #arr_spirite do
		local function call_back(objs)
	        self.sprite_list[i] = objs[0]
	    end
        lua_resMgr:LoadSprite(self, 'saizi_image', arr_spirite[i], call_back)
    end
end

function TimeBossLeftPanel:PlaySeziAnimate(num)
    time = 2
    local last_sprite_index = num+9
    local delayperunit = 0.1
    local loop_count = 9
    local function start_action()
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.saizi)
            self.action = nil
        end
        local action = cc.Animate(self.sprite_list, time, self.saizi, last_sprite_index, delayperunit, loop_count)
        cc.ActionManager:GetInstance():addAction(action, self.saizi)
        self.action = action
    end

    start_action()
    local function call_back()
    	TimeBossController.GetInstance():RequestDicing()
    end
    GlobalSchedule:StartOnce(call_back, 1)
end
