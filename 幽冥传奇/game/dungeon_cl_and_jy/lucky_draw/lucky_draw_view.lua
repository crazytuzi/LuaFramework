--local LuckydrawView = BaseClass(SubView)
LuckydrawView = LuckydrawView or BaseClass(BaseView)
function LuckydrawView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetFubenCL("lucky_draw_txt")
    self.texture_path_list = {
		'res/xui/fuben_cl.png',
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0},},
		{"lucky_draw_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil , 999},
	}

	self.fuben_static_id = 1

	LuckydrawView.Instance = self
end
function LuckydrawView:__delete()
    
end
function LuckydrawView:ReleaseCallBack()
	DungeonData.Instance.check_box_status_list[self.fuben_static_id] = self.check_box.status
    if self.draw_item_list ~= nil then
		for _,v in ipairs(self.draw_item_list) do
			v:DeleteMe()
		end
	end

	if self.myself_record_list then
		self.myself_record_list:DeleteMe()
		self.myself_record_list = nil
	end

	self.draw_item_list = nil
	self.lucky_draw_list = nil
	self.selectIndex = nil
	self.check_box = nil
end
function LuckydrawView:LoadCallBack()
	--元宝数量 -- 测试
	-- self.num = 1234567
	--抽中奖品的物品id - 测试
	-- self.reward_index_id = 534

	-- --奖品列表
	-- self.lucky_draw_list = LuckyDrawAward.awards

	self.lucky_draw_list = {}

	--创建奖品格子
	self:CreateDrawItem()
	--奖品格子数量
	self.draw_item_data_length = 14
	--设置奖品格子数据	
	self:SetDrawItemData()
	--创建滚动布局
	self:CreateNumLayout()
	--创建公共信息栏
	self:CreateRecordList()
	-- 创建跳过动画选框
	self:CreateCheckBox()
	--设置抽奖次数
	self:SetCanDrawNum()

	self.node_t_list.btn_start_run.node:addClickEventListener(BindTool.Bind(self.OnClickStartRun,self))

	EventProxy.New(DungeonData.Instance, self):AddEventListener(DungeonData.LuckyInfoChange, BindTool.Bind(self.OnInfoChange, self))

	-- self.node_t_list.ph_cj_eff.node:setVisible(false)
	-- local pos_x, pos_y = self.node_t_list.ph_cj_eff.node:getPosition()
	-- RenderUnit.CreateEffect(1125, self.node_t_list.layout_layout.node, 10, nil, nil, pos_x-20, pos_y+10)

	self:Flush()
end

function LuckydrawView:ShowIndexCallBack()
	self:Flush()
end

function LuckydrawView:CloseCallBack()
	if self.flush_list_timer then
		GlobalTimerQuest:CancelQuest(self.flush_list_timer)
		self.flush_list_timer = nil
	end	
end

function LuckydrawView:OpenCallBack()
	self.selectIndex = 1
	DungeonCtrl.SendLuckTurnbleReq(1, self.fuben_static_id)
end

function LuckydrawView:CreateCheckBox()
	self.check_box = self.check_box or {}
	self.check_box.status = DungeonData.Instance.check_box_status_list[self.fuben_static_id]
	self.check_box.node = XUI.CreateImageView(20, 20, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box.node:setVisible(self.check_box.status)
	self.node_t_list.layout_skip_animation.node:addChild(self.check_box.node, 10)
	XUI.AddClickEventListener(self.node_t_list.layout_skip_animation.node, BindTool.Bind(self.OnClickSelectBoxHandler, self), true)
end

function LuckydrawView:OnClickSelectBoxHandler()
	if self.check_box == nil then return end
	self.check_box.status = not self.check_box.status
	self.check_box.node:setVisible(self.check_box.status)
end

function LuckydrawView:ShowStaticIdDraw(static_id)
	self.fuben_static_id = static_id
	self:Flush()
end

function LuckydrawView:OnFlush(param_t, index)
	-- self.reward_index_id = param_t.all.index == 0 and 0 or YuanBaoWheelCfg[self.fuben_static_id].award_1[param_t.all.index].id
	self.reward_index = param_t.all.index

	if nil == self.reward_index or self.reward_index == 0 then
		self.clip_layout.setGoldNum(DungeonData.Instance:GetLuckTurnbleGlodNum(self.fuben_static_id), true)
		
		--刷新奖励列表
		self:SetDrawItemData()
	end

	local jc_yb_num = YuanBaoWheelCfg[self.fuben_static_id].addYb
	self.node_t_list.lbl_txt_tip.node:setString(string.format(Language.LuckyDraw.CenterTip, jc_yb_num))

	--设置抽奖次数
	self:SetCanDrawNum(DungeonData.Instance:GetLuckTurnbleDrawNum(self.fuben_static_id))

	XUI.SetButtonEnabled(self.node_t_list.btn_start_run.node, DungeonData.Instance:GetLuckTurnbleDrawNum(self.fuben_static_id) > 0)
end

function LuckydrawView:OnInfoChange()
	if self.check_box.status then
		for k, v in pairs(self.draw_item_list) do
			v:SetSelect(false)
		end
		self:SetDrawItemData()
		self:FlushMyRecord()
	end
end

function LuckydrawView:OnClickStartRun()
	if not self.check_box.status then
		self:StartRunning()
	end
	
	--点击时刷新奖励列表
	self:SetDrawItemData()
	DungeonCtrl.SendLuckTurnbleDarwReq(self.fuben_static_id)
end

function LuckydrawView:SetCanDrawNum(num)
	local can_num = num or 0
	local text = string.format(Language.LuckyDraw.LuckyDrawNum[1], can_num)
	
	RichTextUtil.ParseRichText(self.node_t_list.rich_get_reward_num.node, text,17)
end

--设置奖品格子数据
function LuckydrawView:SetDrawItemData()
	local award_type = DungeonData.Instance:GetLuckTurnbleArwardCfgType(self.fuben_static_id)
	self.lucky_draw_list = YuanBaoWheelCfg[self.fuben_static_id].awardPool[award_type].award

    for i, v in pairs(self.lucky_draw_list) do
		self.draw_item_list[i]:SetRewardItem(self.lucky_draw_list[i])
	end
end

--奖品格子布局
function LuckydrawView:CreateDrawItem()
	self.draw_item_list = {}
	self.Ignor_item_list = {}
	for i = 1, 14 do
		if nil == self.draw_item_list[i] then
			local draw_item = LuckDrawRender.New()
			draw_item:SetUiConfig(self.ph_list["ph_reward_render"], true)
			if i < 6 then
				local x = 130 + (i - 2) * 108
				draw_item:GetView():setPosition(x, 410)
			elseif i < 9 then
				local y = 410 - (i - 5) * 103
				draw_item:GetView():setPosition(457, y)
			elseif i < 13 then
				local x = 130 - (i - 11) * 108
				draw_item:GetView():setPosition(x, 100)
			elseif i < 15 then
				local y = 410 + (i - 15) * 103
				draw_item:GetView():setPosition(22, y)
			end
			self.node_t_list.layout_layout.node:addChild(draw_item:GetView(), 99, 99)
			self.draw_item_list[i] = draw_item
			self.draw_item_list[i]:SetIgnoreDataToSelect(true)
			table.insert(self.Ignor_item_list,self.draw_item_list[i].item_cell)
		end
	end
end

--开始抽奖动画
function LuckydrawView:StartRunning()
	self.selectIndex = self.selectIndex or 1
	self.runTime = 0.05
	BagData.Instance:SetDaley(true)
	self.CountDownInstance = CountDown.Instance
	self.tiner1 = self.CountDownInstance:AddCountDown(1.5, self.runTime, BindTool.Bind(self.changeSelect, self))
	XUI.SetButtonEnabled(self.node_t_list.btn_start_run.node, false)
	-- GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
end

--改变选中的格子
function LuckydrawView:changeSelect()
	if nil == self.draw_item_list then return end
	if self.draw_item_list[self.selectIndex] then  
		self.draw_item_list[self.selectIndex]:SetSelect(false)
	end

	self.selectIndex = self.selectIndex <= self.draw_item_data_length and self.selectIndex or 1


	for k, v in pairs(self.draw_item_list) do
		v:SetSelect(k == self.selectIndex)
	end
	
	local time = self.CountDownInstance:GetRemainTime(self.tiner1)
	if self.runTime > 0.1 then
		local data = self.Ignor_item_list[self.selectIndex]:GetData()
		-- if self.reward_index_id == 0 or self.reward_index_id == data.item_id then 
		if self.reward_index == 0 or self.reward_index == self.selectIndex then 
			self.CountDownInstance:RemoveCountDown(self.tiner1)
			time = 1
			self.is_runing = false

			----转盘完成后调用
			BagData.Instance:SetDaley(false)
    		self:FlushMyRecord()
    		
    		GlobalTimerQuest:AddDelayTimer(function ()
    			self:SetDrawItemData()	
    		end, 1)

    		if self.flush_list_timer == nil then
    			self.flush_list_timer = GlobalTimerQuest:AddDelayTimer(function ()
    		    	-- XUI.SetButtonEnabled(self.node_t_list.btn_start_run.node, true)
				    XUI.SetButtonEnabled(self.node_t_list.btn_start_run.node, DungeonData.Instance:GetLuckTurnbleDrawNum(self.fuben_static_id) > 0)
    			end, 2)	
    		end

			--元宝数
		    self.clip_layout.setGoldNum(DungeonData.Instance:GetLuckTurnbleGlodNum(self.fuben_static_id), true)
		end
	end
	self.selectIndex = self.selectIndex + 1
	if time < 0.1 then
		self.runTime = self.runTime + 0.1
		self.CountDownInstance:RemoveCountDown(self.tiner1)
		self.tiner1 = self.CountDownInstance:AddCountDown(1.5, self.runTime, BindTool.Bind(self.changeSelect, self))
	end
	--XUI.SetButtonEnabled(self.node_t_list.btn_start_run.node, false)
end

--变动数字
local function creat_one_change_num(x)
	local node = XUI.CreateLayout(x, 110, 30, 150)
	local num = XUI.CreateImageView(0, 0, ResPath.GetCommon("num_133_0"))
	local temp_num = XUI.CreateImageView(0, -55, ResPath.GetCommon("num_133_1"))
	node:addChild(num)
	node:addChild(temp_num)

	node.now_num = 0

	--关闭动画定时器
	node.CloseNumTimer = function ()
		if node.timer_quest then
			GlobalTimerQuest:CancelQuest(node.timer_quest)
			node.timer_quest = nil
		end
	end

	--滚动改变数字
	local change_scorll_num = function (sign_num, is_jump)
		if node.now_num == sign_num then
			node.CloseNumTimer()
			return
		end

		local end_callback = cc.CallFunc:create(function()
			num:loadTexture(ResPath.GetCommon("num_133_" .. node.now_num))
			node:setPositionY(110)
		end)

		--刷新数字
		if is_jump then
			node.now_num = sign_num
			temp_num:loadTexture(ResPath.GetCommon("num_133_" .. sign_num))
		else
			node.now_num = (node.now_num + 1) % 10
			temp_num:loadTexture(ResPath.GetCommon("num_133_" .. node.now_num))
		end

		node:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(x, 110 + 55)), end_callback))
	end

	--闪动改变数字
	local change_flash_num = function (sign_num, is_jump)
		print("cd------------>you should write one function")  
	end

	--设置数字 param: 1目标数字 2是否跳过中间数字 3变化方式(1 滚动 2闪动)
	node.SetNum = function (sign_num, is_jump, change_type)
		node.CloseNumTimer()
		local change_num_fun = change_type == 1 and change_scorll_num or change_flash_num 
		if not is_jump then
			node.timer_quest = GlobalTimerQuest:AddRunQuest(function() change_num_fun(sign_num, is_jump) end, 0.3)
		else
			change_num_fun(sign_num, is_jump)
		end
	end

	return node
end

--整数中获取某一位数字
local function get_one_bit_num(num, unit)
	if unit == 1 then
		return num % 10
	end
	local last_residue_num = num % math.pow(10, unit - 1)
	local now_residue_num = num % math.pow(10, unit)
	return (now_residue_num - last_residue_num) / math.pow(10, unit - 1)
end

--创建滚动数字层
function LuckydrawView:CreateNumLayout()
	self.clip_layout = XUI.CreateLayout(288, 320, 290, 60)
	self.clip_layout:setClippingEnabled(true)

	local old_gold = 0

	--创建滚动数字
	local num_list = {}
	for i = 1, 7 do
		local num_obj = creat_one_change_num(30+ (7 - i) * 40)
		num_list[i] = num_obj
		self.clip_layout:addChild(num_obj)
	end

	--设置数字
	self.clip_layout.setGoldNum = function (gold_num, is_jump, change_type)
		if gold_num ~= old_gold then
			is_jump = is_jump or false
			change_type = change_type or 1
			for i = 1, 7 do
				local sign_num = get_one_bit_num(gold_num, i)
				num_list[i].SetNum(sign_num, is_jump, change_type)
			end
		end
		old_gold = gold_num
	end

	--关闭数字动画定时器
	self.clip_layout.CloseNumTimer = function ()
		for i = 1, 7 do
			num_list[i].CloseNumTimer()
		end
	end
	self.node_t_list.layout_layout.node:addChild(self.clip_layout, 300)
end

--创建公共信息栏
function LuckydrawView:CreateRecordList()
	local ph = self.ph_list.ph_record_list
	if self.myself_record_list == nil then
		self.myself_record_list = ListView.New()
		self.myself_record_list:Create(ph.x, ph.y-5, ph.w, ph.h, nil, LuckDrawRecordRender, nil, nil, self.ph_list.ph_message)
		self.myself_record_list:GetView():setAnchorPoint(0, 0)
		self.myself_record_list:SetItemsInterval(3)
		self.myself_record_list:SetJumpDirection(ListView.Bottom)
		self.node_t_list.layout_layout.node:addChild(self.myself_record_list:GetView(), 100)
	end
	self:FlushMyRecord()
end

--刷新公共信息数据
function LuckydrawView:FlushMyRecord()
	if nil == self.myself_record_list then return end
	self.myself_record_list:SetDataList(DungeonData.Instance:GetLuckTurnbleRecord(self.fuben_static_id))
end

LuckDrawRecordRender = LuckDrawRecordRender or BaseClass(BaseRender)
function LuckDrawRecordRender:__init()	
end

function LuckDrawRecordRender:__delete()	
end

function LuckDrawRecordRender:CreateChild()
	BaseRender.CreateChild(self)
	-- self.node_tree.rich_message.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function LuckDrawRecordRender:OnClickItemTipsHandler()
	TipsCtrl.Instance:OpenItem(self.data.item_data, EquipTip.FROM_NORMAL)
end

function LuckDrawRecordRender:OnFlush()
	if nil == self.data then return end

	-- local award_type = DungeonData.Instance:GetLuckTurnbleArwardCfgType(LuckydrawView.Instance.fuben_static_id)
	local cfg = YuanBaoWheelCfg[LuckydrawView.Instance.fuben_static_id].awardPool[tonumber(self.data.award_cfg_type)].award


	if nil == cfg or nil == cfg[tonumber(self.data.idx)] then return end
	local id = cfg[tonumber(self.data.idx)].id
	local count = cfg[tonumber(self.data.idx)].count
	local item = cfg[tonumber(self.data.idx)]

	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	local text = {}
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "007fff"
	end
	local item_name = ItemData.Instance:GetItemName(3477)
	if item.percent and item.percent > 0 then
		item_name = item.percent * 100 .. "%奖池"
	else
		item_name = item_cfg.name
	end

	local text = string.format( Language.LuckyDraw.message, self.rolename_color, self.data.name, item_name, count)
	RichTextUtil.ParseRichText(self.node_tree.rich_message.node, text, 20, nil,nil,nil,320,25)
end

function LuckDrawRecordRender:CreateSelectEffect()
end


----------------------------------------------------
-- LuckDrawRender
----------------------------------------------------
LuckDrawRender = LuckDrawRender or BaseClass(BaseRender)

function LuckDrawRender:__init()
	self.item_cell = nil
	self.item_list = {}
end

function LuckDrawRender:CreateChild()
	BaseRender.CreateChild(self)

	self.lbl_text_1 = self.node_tree.lbl_text_1.node

	local ph = self.ph_list.ph_cell
	local item_cell = BaseCell.New()
	item_cell:GetView():setAnchorPoint(0.5, 0.5)
	item_cell:GetView():setPosition(ph.x, ph.y)
	self.view:addChild(item_cell:GetView(), 10)
	self.item_cell = item_cell
	self.item_cell_index = nil
	
end

function LuckDrawRender:__delete()
	
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function LuckDrawRender:OnFlush()
end

function LuckDrawRender:SetRewardItem(item)
	if item then
		if item.type ~= tagAwardType.qatEquipment then
			item.id = ItemData.GetVirtualItemId(item.type)
		end
		local item_config = ItemData.Instance:GetItemConfig(item.id)

		self.item_cell:SetData({item_id = item.id, num = item.count, is_bind = item.bind})
		
		if item_config then
			self.node_tree.lbl_text_1.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
			if item.percent and item.percent > 0 then
				self.lbl_text_1:setString(item.percent * 100 .. "%奖池")
			else
				self.lbl_text_1:setString(item_config.name)
			end

			self.item_cell_index = index
		end
	else
		self.item_cell:SetData()
		self.lbl_text_1:setString("")
		self.item_cell_index = nil
	end
	
end

function LuckDrawRender:CreateSelectEffect()
	self.select_effect = XUI.CreateImageView(50, 63, ResPath.GetCommon("cell_select_bg"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 98)
end

--消息栏测试数据
MessageList = {
	{name = "str_t[1]", idx = "3", num = 3,},
	{name = "str_t[1]", idx = "3", num = 3,},
	{name = "str_t[1]", idx = "3", num =3,},
}