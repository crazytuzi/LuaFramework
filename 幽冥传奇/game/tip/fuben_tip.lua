FubenTip = FubenTip or BaseClass(XuiBaseView)

FubenTip.TYPE = {
	MUTIL_FUBEN = 2,
}

function FubenTip:__init()
	self.texture_path_list = {
		"res/xui/fuben.png"
	}

	self.config_tab = {
		{"itemtip_ui_cfg", 13, {0}}
	}
end

function FubenTip:ReleaseCallBack()
	CountDown.Instance:RemoveCountDown(self.cd_key)
	if self.top_tip_view then 
		self.top_tip_view:DeleteMe()
		self.top_tip_view = nil
	end

	if self.cell_list then 
		for i,v in ipairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end

	if self.result_event then
		GlobalEventSystem:UnBind(self.result_event)
		self.result_event = nil
	end
	
	if self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	
end

function FubenTip:LoadCallBack(index, loaded_times)
	self.root_node:setTouchEnabled(false)
	self:CreateMutilView()
	self:CreateTimerLabel()
	-- self:FlushBossNum(0)
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneChange, self))
	self.result_event = GlobalEventSystem:Bind(OtherEventType.FIRST_FLOOR_RESULT, BindTool.Bind(self.OnFirstFloorResult, self))
	self.count_event = GlobalEventSystem:Bind(OtherEventType.FIRST_FLOOR_KILL_COUNT, BindTool.Bind(self.OnFirstFloorKillCount, self))
end

function FubenTip:CreateTimerLabel()
	self.timer_label = XUI.CreateText(410, 538, 100, 40, nil, "(00:00:00)", nil, 20, COLOR3B.GREEN)
	self.node_t_list.layout_jy_fuben_lingqu.node:addChild(self.timer_label)
end

--经验副本
function FubenTip:CreateMutilView()
	self.top_tip_view = MutilFubenRender.New()
	self.top_tip_view:SetUiConfig(self.ph_list.ph_top_tip_item, true)
	self.top_tip_view:SetAnchorPoint(0.5, 0.5)
	self.top_tip_view:SetPosition(280, 585)
	self.top_tip_view:SetScale(0.8)
	self.node_t_list.layout_jy_fuben_lingqu.node:addChild(self.top_tip_view:GetView())
end

function FubenTip:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:Flush()
end

function FubenTip:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FubenTip:OnFlush()
	if self.awards then
		local length = #self.awards > 5 and 5 or #self.awards
		self.cell_list = {}
		local size = self.top_tip_view:GetView():getContentSize()
		local mid = (length + 1) / 2
		for i = 1, length do
			local id = self.awards[i].id
			if self.awards[i].type > 0 then
				id = ItemData.GetVirtualItemId(self.awards[i].type)
			end
			local item_data = {item_id = id, num = self.awards[i].count, is_bind = self.awards[i].bind}
			if self.cell_list[i] then
				self.cell_list[i]:SetData(item_data)
			else
				local d_x = (mid - i) * size.width / (length + 1) * 0.6
				local cell = BaseCell.New()
				cell:SetData(item_data)
				self.node_t_list.layout_jy_fuben_lingqu.node:addChild(cell:GetView())
				self.cell_list[i] = cell
				cell:GetView():setPosition(270 + d_x, 560)
				cell.right_bottom_text:setFontSize(25)
				cell:SetScale(0.6)
			end
		end
	end
	self:FlushBossNum(0)
end

function FubenTip:OnSceneChange(scene_id, scene_type, fuben_id)
	if not FubenMutilLayer[scene_id] then 
		self:Close()
	else
		self.awards = FubenMutilData.GetFubenShowAwards(FubenMutilType.Team, FubenMutilLayer[scene_id])
		self.bossNum = FubenMutilData.GetNeedKilledNum(FubenMutilType.Team, FubenMutilLayer[scene_id])
		self.time = FubenMutilData.GetTurnsRefreshTimes(FubenMutilType.Team, FubenMutilLayer[scene_id])
		self:FlushTimee(time)

		self:Flush()
	end
end

function FubenTip:OnFirstFloorResult(result)
	if result == 0 and self.time then
		self:FlushTimee(self.time)
	end
end

function FubenTip:OnFirstFloorKillCount(count)
	self:FlushBossNum(count)
end

function FubenTip:SetData(awards, bossNum, type, time)
	self.awards = awards
	self.bossNum = bossNum
	self.tip_type = type
	self.time = time
	self:FlushTimee(time)

	if self:IsOpen() then
		self:Flush()
	end
end

function FubenTip:FlushTimee(time)
	if time and time > 0 then 
		function cd_callback(elapse_time, total_time)
			if elapse_time >= total_time then
				CountDown.Instance:RemoveCountDown(self.cd_key)
			else
				local c = TimeUtil.FormatSecond(math.ceil(total_time - elapse_time))
				if nil == self.timer_label then 
					self:CreateTimerLabel()
				end
				self.timer_label:setString("(" .. c .. ")")
			end
		end
		self.cd_key = CountDown.Instance:AddCountDown(time, 1, cd_callback)
	end
end

function FubenTip:FlushBossNum(num)
	local data = {}
	data.monsterMaxCount = self.bossNum
	data.monster = num
	data.type = FubenTip.TYPE.MUTIL_FUBEN
	if self.top_tip_view then
		self.top_tip_view:SetData(data)
	end
end




MutilFubenRender = MutilFubenRender or BaseClass(BaseRender)
function MutilFubenRender:__init()
	
end

function MutilFubenRender:__delete()
end

function MutilFubenRender:CreateChild()
	BaseRender.CreateChild(self)
end

function MutilFubenRender:OnFlush()
	if nil == self.data then return end
	--怪物数量刷新  
	local str = "{wordcolor;1eff00;%s}{wordcolor;FFCC00;/%s}"
	local content = string.format(str, self.data.monster, self.data.monsterMaxCount)
	RichTextUtil.ParseRichText(self.node_tree.rich_kill_num.node, content, 24)
	self.node_tree.img_title.node:loadTexture(ResPath.GetFuben("scene_tip_title_"..self.data.type))
end
