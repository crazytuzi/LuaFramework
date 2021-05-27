 TaskTiShuView = TaskTiShuView or BaseClass(BaseView)
function TaskTiShuView:__init( ... )
	--self:SetBgOpacity(200)
	self:SetModal(true)
	self.is_any_click_close = true	
	--self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER 
	self.texture_path_list[1] = 'res/xui/daily_tasks.png'
	-- self:SetModal(true)
	--self:SetIsAnyClickClose(true)
	self.config_tab = {
		-- {"common2_ui_cfg", 1, {0}},
		{"daily_tasks_ui_cfg", 1, {0}},
		{"daily_tasks_ui_cfg", 4, {0}},
		-- {"daily_tasks_ui_cfg", 2, {0}, false}, -- 默认隐藏 layout_receive_tasks
		-- {"daily_tasks_ui_cfg", 3, {0}, false}, -- 默认隐藏 layout_get_rewards
		-- {"common2_ui_cfg", 2, {0}},
	}
	self.data =  nil
	self.text_buy_time = nil
end

function TaskTiShuView:__delete( ... )
	-- body
end

function TaskTiShuView:ReleaseCallBack( ... )
	if self.num_change then
		GlobalEventSystem:UnBind(self.num_change)
		self.num_change = nil
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function TaskTiShuView:LoadCallBack( ... )
	XUI.AddClickEventListener(self.node_t_list.btn_enter.node, BindTool.Bind1(self.EnterFuben, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_get_reward1.node, BindTool.Bind1(self.GetReWardSingle, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_get_reward2.node, BindTool.Bind1(self.GetReWardouble, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_get_reward3.node, BindTool.Bind1(self.GetReWardFour, self), true)
	self.num_change = GlobalEventSystem:Bind(TIANSHUTASK_EVENT.NUM_CHANGE,BindTool.Bind1(self.ChangeNum, self))

	self:CreateCell()
	self:CreateBuyTime()
	RichTextUtil.ParseRichText(self.node_t_list["rich_task_goal"].node, Language.TiShuTask.task_desc)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
	EventProxy.New(TaskData.Instance, self):AddEventListener(TaskData.TIANSHU_NUM, BindTool.Bind(self.TianShuTimeFlush, self))

	self.node_t_list.img_name.node:loadTexture(ResPath.GetDailyTasks("text1"))
end

function TaskTiShuView:TianShuTimeFlush()
	self:Flush()
end

function TaskTiShuView:ChangeNum( ... )
	local remian_num = TaskData.Instance:GetRemianNum()
	self.node_t_list.lbl_task_num.node:setString(remian_num)
end


function TaskTiShuView:CreateCell( ... )
	self.cell_list = {}
	for i=1, 4 do
		local  ph = self.ph_list["ph_item_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x - 50, ph.y - 40)
		self.node_t_list.layout_tianshu_tasks.node:addChild(cell:GetView(), 99)
		self.cell_list[i] = cell
	end

	local data = TaskData.Instance:GetConfigDataItemData()
	for k, v in pairs(data) do
		if self.cell_list[k] then
			self.cell_list[k]:SetData({item_id = v.id, is_bind = v.bind or 0, num = v.count})
		end
	end
end

function TaskTiShuView:ItemDataListChangeCallback( ... )
	self:FlushConsumeShow()
end

function TaskTiShuView:OpenCallBack()
	-- override
end

function TaskTiShuView:ShowIndexCallBack(index)
	self:Flush(index)
end

-- 创建"购买次数"文本按钮
function TaskTiShuView:CreateBuyTime()
	local ph = self.ph_list["ph_buy_txt"]
	self.text_buy_time = RichTextUtil.CreateLinkText("购买次数", 19, COLOR3B.GREEN, nil, true)
	self.text_buy_time:setPosition(ph.x, ph.y)
	self.node_t_list["layout_tianshu_tasks"].node:addChild(self.text_buy_time, 20)
	XUI.AddClickEventListener(self.text_buy_time, BindTool.Bind(self.OnTextBuyTime, self), true)
end

function TaskTiShuView:OnTextBuyTime()
	self.but_time = self.but_time or Alert.New()
	self.but_time:SetLableString(string.format(Language.DailyTasks.BuyTimeTxt, TianShuRenWuConfig.buyTmsCost[1].count))
	self.but_time:SetOkFunc(function()
		TaskCtrl.Instance:SendOprateTianShuTask(3)
	end)
	self.but_time:SetShowCheckBox(false)
	self.but_time:Open()
end

function TaskTiShuView:OnFlush(param_t)
	self:ChangeNum()
	self:FlushConsumeShow()
end

function TaskTiShuView:CloseCallBack(...)
	
end

function TaskTiShuView:GetReWardSingle()

	TaskCtrl.Instance:SendOprateTianShuTask(1, 1)
end

function TaskTiShuView:GetReWardouble( ... )
	TaskCtrl.Instance:SendOprateTianShuTask(1, 2)
end

function TaskTiShuView:GetReWardFour( ... )
	TaskCtrl.Instance:SendOprateTianShuTask(1, 3)
end

function TaskTiShuView:EnterFuben( ... )
	TaskCtrl.Instance:SendOprateTianShuTask(2, 0)
	ViewManager.Instance:CloseViewByDef(ViewDef.TiShuTask)
end


function TaskTiShuView:FlushConsumeShow()
	for k, v in pairs(TianShuRenWuConfig.getAwardsType) do
		
		local consume = v.consume[1] 
		local consume_id = consume.id
		local consume_count = consume.count
		local item_cfg = ItemData.Instance:GetItemConfig(consume_id)
		local name = item_cfg.name
		local had_num = BagData.Instance:GetItemNumInBagById(consume_id,nil)
		local color = had_num >= consume_count and "00ff00" or "ff0000" 

		local text = string.format(Language.TiShuTask.desc, name, color, consume_count)
		if self.node_t_list["text_reward_consume"..k] then
			RichTextUtil.ParseRichText(self.node_t_list["text_reward_consume"..k].node, text)
			XUI.RichTextSetCenter(self.node_t_list["text_reward_consume"..k].node)
		end
	end

	local consume_id = TaskData.Instance:GetConsumeId()
	local item_cfg = ItemData.Instance:GetItemConfig(consume_id)
	local name = item_cfg.name
	local had_num = BagData.Instance:GetItemNumInBagById(consume_id,nil)
	local color = had_num >= 1 and "00ff00" or "ff0000" 
	local text =string.format("拥有%s:{wordcolor;%s;%d}", name, color, had_num)


	RichTextUtil.ParseRichText(self.node_t_list["text_had_item"].node, text)

	local _, buy_time = TaskData.Instance:GetHadCompeleteNum()
	self.text_buy_time:setEnabled(buy_time < TianShuRenWuConfig.maxBuyTimes)
	self.text_buy_time:setColor(buy_time < TianShuRenWuConfig.maxBuyTimes and COLOR3B.GREEN or COLOR3B.GRAY)
end