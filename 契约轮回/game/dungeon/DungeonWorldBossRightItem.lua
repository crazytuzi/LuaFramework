DungeonWorldBossRightItem = DungeonWorldBossRightItem or class("DungeonWorldBossRightItem",BaseItem)
local DungeonWorldBossRightItem = DungeonWorldBossRightItem

function DungeonWorldBossRightItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeonWorldBossRightItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	DungeonWorldBossRightItem.super.Load(self)

	self.item_list = {}
	self.events = {}
end

function DungeonWorldBossRightItem:dctor()
	if self.item_list then
		destroyTab(self.item_list)
		self.item_list = nil
	end

	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end

	if self.schedule_id2 then
		GlobalSchedule:Stop(self.schedule_id2)
		self.schedule_id2 = nil
	end

	GlobalEvent:RemoveTabListener(self.events)
	self.events = nil
end

function DungeonWorldBossRightItem:LoadCallBack()
	self.nodes = {
		"parent/bg","parent/rank_btn", "parent/bg/closebtn","parent/bg/ScrollView/Viewport/Content",
		"parent/bg/ScrollView/Viewport/Content/DungeonWorldBossDamageItem",
		"parent/bg/myrank", "parent","parent/bg/tips",
	}
	self:GetChildren(self.nodes)

	self.DungeonWorldBossDamageItem_go = self.DungeonWorldBossDamageItem.gameObject
	SetVisible(self.DungeonWorldBossDamageItem_go, false)
	self.myrank = GetText(self.myrank)
	self:AddEvent()

	SetVisible(self.bg, true)
	SetVisible(self.rank_btn, false)
	self.myrank.text = "None"

	SetAlignType(self.transform, bit.bor(AlignType.Right, AlignType.Null))

	self.schedule_id2 = GlobalSchedule:Start(handler(self,self.CheckShowDamage), 0.5)
end

function DungeonWorldBossRightItem:AddEvent()

	local function call_back(target,x,y)
--[[		if not self:IsNearByBoss() then
			return Notify.ShowText("您现在没有在首领附近")
		end--]]

		SetVisible(self.bg, true)
		SetVisible(self.rank_btn, false)
		--[[self:RequestRank()
		if not self.schedule_id then
			self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestRank), 5)
		end--]]
	end
	AddButtonEvent(self.rank_btn.gameObject,call_back)

	local function call_back(target,x,y)
		SetVisible(self.bg, false)
		SetVisible(self.rank_btn, true)
	end
	AddButtonEvent(self.closebtn.gameObject,call_back)

	local function call_back(data)
		self:UpdateRanks(data)
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateBossDamageRank, call_back)

	local call_back = function()
        self:SetVisible(false)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.ShowTopRightIcon, call_back)

    local call_back1 = function()
        self:SetVisible(true)
    end

    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.HideTopRightIcon, call_back1)

    local function call_back()
    	self:destroy()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.GameReset, call_back)
end

function DungeonWorldBossRightItem:SetData(data)

end

function DungeonWorldBossRightItem:RequestRank()
	local flag, uid = self:IsNearByBoss()
	if flag then
		DungeonCtrl.GetInstance():RequestBossDamageRank(uid)
	end
end

function DungeonWorldBossRightItem:UpdateRanks(data)
	local ranks = data.ranks
	local my_rank = data.my_rank
	destroyTab(self.item_list)
	self.item_list = {}
	for i=1, #ranks do
		local item = DungeonWorldBossDamageItem(self.DungeonWorldBossDamageItem_go, self.Content)
		item:SetData(ranks[i])
		self.item_list[i] = item
	end
	SetVisible(self.tips, #ranks==0)
	if my_rank > 0 then
		self.myrank.text = string.format("%s(%s)", my_rank, GetShowNumber(data.my_damage))
	else
		self.myrank.text = string.format("Not yet (%s)", GetShowNumber(data.my_damage))
	end
end

function DungeonWorldBossRightItem:IsNearByBoss()
	local list = SceneManager.GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP) or {}
	for k, obj in pairs(list) do
		if obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
    		local bosscfg = Config.db_boss[obj.object_info.id]
    		if bosscfg and bosscfg.scene == 20000 then
    			return true, obj.object_id
    		end
    	end
	end
	return false
end

function DungeonWorldBossRightItem:CheckShowDamage()
	if not self:IsNearByBoss() then
		--SetVisible(self.bg, false)
		--SetVisible(self.rank_btn, true)
		if self.schedule_id then
			GlobalSchedule:Stop(self.schedule_id)
			self.schedule_id = nil
			destroyTab(self.item_list)
			self.item_list = {}
			SetVisible(self.tips, true)
			self.myrank.text = "None"
		end
	else
		if not self.schedule_id then
			self:RequestRank()
			self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestRank), 3)
		end
	end
end

