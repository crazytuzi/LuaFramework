--------------------------------------------------------
-- 日常活动-行会boss  配置 
--------------------------------------------------------

BossTipsView = BossTipsView or BaseClass(BaseView)

function BossTipsView:__init()
	self.texture_path_list = {
		"res/xui/boss.png",
	}
	self.config_tab = {
		{"boss_ui_cfg", 10, {0}},
	}
end

function BossTipsView:__delete()
end

--释放回调
function BossTipsView:ReleaseCallBack()

end

--加载回调
function BossTipsView:LoadCallBack(index, loaded_times)
	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.CENTER_TOP)
	local w, h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

----------更换父节点----------
	local node = self.real_root_node
	node:retain()
	node:removeFromParent()
	node:setParent(nil)
	right_top:TextLayout():addChild(node)
	node:release()
	node:setEnabled(true)
-------------end--------------

	-- local size = self.node_t_list["layout_boss_list"].node:getContentSize()
	-- local x, y
	-- x = w / 2 - size.width / 2 + 295
	-- y = h - 105
	self.root_node:setPosition(0, 220)
	self.root_node:setAnchorPoint(0, 0)

	-- EventProxy.New(ActivityData.Instance, self):AddEventListener(ActivityData.RANKING_DATA_CHANGE, BindTool.Bind(self.OnRankingDataChange, self))
	EventProxy.New(BossData.Instance, self):AddEventListener(BossData.UPDATE_BOSS_DATA, BindTool.Bind(self.FlushView, self))

	local ph = self.ph_list.ph_boss_list
	self.boss_list = ListView.New()
	self.boss_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BossTipsView.BossListRender, nil, nil, self.ph_list.ph_boss_item)
	self.boss_list:SetItemsInterval(15)
	self.boss_list:SetJumpDirection(ListView.Top)
	self.boss_list:SetSelectCallBack(BindTool.Bind(self.SelectBossListCallback, self))
	self.node_t_list.layout_boss_list.node:addChild(self.boss_list:GetView(), 101)
	self:AddObj("boss_list")
end

function BossTipsView:SelectBossListCallback()
end

function BossTipsView:OpenCallBack()
end

function BossTipsView:CloseCallBack(is_all)
	
end

--显示指数回调
function BossTipsView:ShowIndexCallBack(index)
	self:FlushView()
end

----------视图函数----------
function BossTipsView:FlushView()
	self.node_t_list.lbl_scene_name.node:setString(Scene.Instance:GetSceneName())
	self:GetBossListData()
end

function BossTipsView:GetBossListData()
	local scene_id = Scene.Instance:GetSceneId()
	local now_time = Status.NowTime
	local boss_list = BossData.Instance:GetSceneBossListBySceneId(scene_id)
	local map_boss_list = MapData.GetMapBossList(scene_id)

	
	for k,v in pairs(boss_list) do
		for key,value in pairs(map_boss_list) do
			if v.refresh_time > 0 then
				v.refresh_time = v.refresh_time - (now_time - v.now_time)
				v.refresh_time = v.refresh_time > 0 and v.refresh_time or 0
				v.now_time = now_time
			end
			if value.BossId == v.boss_id then
				value.refresh_time = v.refresh_time
				value.booslv = v.monster_lv
				value.state = v.refresh_time > 0 and 1 or 2
				break
			end
		end
	end
	
	table.sort(map_boss_list,function (a,b)
		
		if a.state ~= b.state then
			return a.state > b.state
		else
			return a.booslv < b.booslv
		end
	end)

	self.boss_list:SetDataList(map_boss_list)
end

BossTipsView.BossListRender = BaseClass(BaseRender)
local BossListRender = BossTipsView.BossListRender
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
	self.boss_name = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN)
	self.boss_name:setPosition(0, ph_txt.y)
	self.view:addChild(self.boss_name, 100)
	self.boss_name:setAnchorPoint(0, 0.5)
	-- self.boss_name:setHorizontalAlignment(RichHAlignment.HA_LEFT)
	XUI.AddClickEventListener(self.boss_name, BindTool.Bind(self.OnOpenChess, self), true)
end

function BossListRender:OnFlush()
	if nil == self.data then return end

	self.boss_name:setString(self.data.name)
	-- self.node_tree.lbl_boss_open.node:setString(self.data.refresh_time > 0 and "未刷新" or "已刷新")
	self.boss_name:setColor(self.data.refresh_time <= 0 and COLOR3B.GREEN or COLOR3B.G_W)
	self.node_tree.lbl_boss_open.node:setColor(self.data.refresh_time <= 0 and COLOR3B.GREEN or COLOR3B.RED)

	local left_time = self.data.refresh_time - Status.NowTime
	if left_time > 0 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end

		local callback = function()
			
			local left_time = self.data.refresh_time - Status.NowTime
			if left_time > 0 then
				self.node_tree.lbl_boss_open.node:setString(TimeUtil.FormatSecond(left_time, 3))
			else
				if self.timer then
					GlobalTimerQuest:CancelQuest(self.timer)
					self.timer = nil
				end
			end
		end
		callback()
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
	else
		self.node_tree.lbl_boss_open.node:setString("已刷新")
	end
end

function BossListRender:OnOpenChess()
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), self.data.x, self.data.y, 1)
end

function BossListRender:CreateSelectEffect()

end
--------------------
