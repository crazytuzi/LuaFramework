local BossSceneRender = BaseClass(BaseRender)
function BossSceneRender:__init()
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.change_event = BossData.Instance:AddEventListener(BossData.UPDATE_BOSS_DATA, function ()
		self:Flush()
	end)
end

function BossSceneRender:__delete()
	if nil ~= self.boss_list then
		self.boss_list:DeleteMe()
		self.boss_list = nil
	end

	BossData.Instance:RemoveEventListener(self.change_event)
	self:RemoveAllEventlist()
end

function BossSceneRender:CreateChild()
	BaseRender.CreateChild(self)

	if self.boss_list == nil then
		local ph = self.ph_list.ph_boss_list
		self.boss_list = ListView.New()
		self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossSceneRender.BossListRender, nil, nil, self.ph_list.ph_boss_item)
		self.boss_list:SetItemsInterval(10)
		self.boss_list:SetJumpDirection(ListView.Top)
		self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
		self.view:addChild(self.boss_list:GetView(), 101)
	end
end

function BossSceneRender:SelectBossListCallback()
end

function BossSceneRender:OnFlush()

	self.node_tree.lbl_scene_name.node:setString(Scene.Instance:GetSceneName())
	self:GetBossListData()
end

function BossSceneRender:GetBossListData()
	local scene_id = Scene.Instance:GetSceneId()
	local boss_list = BossData.Instance:GetSceneBossListBySceneId(scene_id)
	local map_boss_list = MapData.GetMapBossList(scene_id)

	for key,value in pairs(map_boss_list) do
		local boss_id = value.BossId or 0
		local cur_boss_data = boss_list[boss_id] or {refresh_time = 0, now_time = 0, monster_lv = 0}
		value.refresh_time = cur_boss_data.refresh_time
		value.now_time = cur_boss_data.now_time
		value.booslv = cur_boss_data.monster_lv
		value.left_time = cur_boss_data.refresh_time - (Status.NowTime - cur_boss_data.now_time)

		value.state = value.left_time > 0 and 1 or 2
	end
	
	table.sort(map_boss_list,function (a,b)
		if a.state ~= b.state then
			return a.state > b.state
		elseif a.left_time ~= b.left_time then
			return a.left_time < b.left_time
		else
			return a.booslv < b.booslv
		end
	end)

	self.boss_list:SetDataList(map_boss_list)
end

BossSceneRender.BossListRender = BaseClass(BaseRender)
local BossListRender = BossSceneRender.BossListRender
function BossListRender:__init()
end

function BossListRender:__delete()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function BossListRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph_txt = self.ph_list.ph_boss_name
	self.boss_name = RichTextUtil.CreateLinkText("", 18, COLOR3B.ORANGE)
	self.boss_name:setPosition(0, ph_txt.y)
	self.view:addChild(self.boss_name, 100)
	self.boss_name:setAnchorPoint(0, 0.5)
	-- self.boss_name:setHorizontalAlignment(RichHAlignment.HA_LEFT)
	XUI.AddClickEventListener(self.boss_name, BindTool.Bind(self.OnOpenChess, self), true)
end

function BossListRender:OnFlush()
	if nil == self.data then return end

	self.boss_name:setString(self.data.name)

	local left_time = self.data.refresh_time - (Status.NowTime - self.data.now_time)
	
	self.boss_name:setColor(left_time <= 0 and COLOR3B.ORANGE or COLOR3B.G_W)
	self.node_tree.lbl_boss_open.node:setColor(left_time <= 0 and COLOR3B.GREEN or COLOR3B.RED)

	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			local left_time = self.data.refresh_time - (Status.NowTime - self.data.now_time)
			if left_time > 0 then
				self.node_tree.lbl_boss_open.node:setString(TimeUtil.FormatSecond(left_time, 3))
			else
				if self.timer then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
				self:Flush()
			end
		end
		callback()
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
	else
		self.node_tree.lbl_boss_open.node:setString("已刷新")
	end
end

function BossListRender:OnOpenChess()
	local monster_id = self.data.BossId or 0
	GuajiCache.monster_id = monster_id
	MoveCache.end_type = MoveEndType.FightByMonsterId
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), self.data.x, self.data.y, 1)
end

function BossListRender:CreateSelectEffect()

end


return BossSceneRender