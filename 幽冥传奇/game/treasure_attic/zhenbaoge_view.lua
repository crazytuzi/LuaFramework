--ZhenBaoGeView = ZhenBaoGeView or BaseClass(BaseView)
local ZhenBaoGeView = BaseClass(SubView)
local RewardView = BaseClass()
RoleState ={
	Run  = 1,
	Stand  = 2,
}
function ZhenBaoGeView:__init()
	self.title_img_path = ResPath.GetWord("word_boss")
	self.texture_path_list = {
		 "res/xui/zhenbaoge.png",
	}
	self.config_tab = {
		{"zhenbaoge_ui_cfg", 1, {0}},
	}
	self.title_img_path = ResPath.GetWord("word_cardhandlebook")
end

function ZhenBaoGeView:ReleaseCallBack()
	if self.pata_view then
		self.pata_view:DeleteMe()
		self.pata_view = nil
	end

	if self.exchange_list then
		self.exchange_list:DeleteMe()
		self.exchange_list = nil
	end

	if self.pata_progerss then
		self.pata_progerss:DeleteMe()
		self.pata_progerss = nil
	end
	CountDown.Instance:RemoveCountDown(self.timer1)
end

function ZhenBaoGeView:LoadCallBack(index, loaded_times)
	self:CreatePataList()    	--创建爬塔的格子
	self:CreateExChangeList()   --兑换物品
	self:SetBtnDerect()			--上下按钮设置
	self:CreateRewardsView() 	--上方奖励领取按钮
	self:CreateLoadingBar()     --创建进度条
	self:CreateNumberBar()
	self:CreateTimer()
	self:UpdateInfo()

	local rest_time = TimeUtil.RestTimeToWeekDay(2) --星期一为第二天
	self.node_t_list.lbl_rest_times.node:setString(TimeUtil.FormatSecond2Str(rest_time))
    
	local step  = ZhenBaoGeData.Instance:GetZhenBaoGeData().cur_step
	if step > 0 then
		self.pata_view:SetArrowStep(step, false, ZhenBaoGeCtrl.Instance.ReqStepReward) 
	end

	self.cur_layer =self.pata_view:GetLayer(step)
	if self.cur_layer < 1 then
		self.cur_layer = 1
	end
	self.layer_number:SetNumber(self.cur_layer)

	XUI.AddClickEventListener(self.node_t_list.layout_btn.node, BindTool.Bind(self.ThrowDice, self,1),true)
	XUI.AddClickEventListener(self.node_t_list.layout_free.node, BindTool.Bind(self.ThrowDice, self,0),true)
	self.node_t_list.img_dice.node:setVisible(false)
	XUI.AddClickEventListener(self.node_t_list.img_hook_bg.node, BindTool.Bind(self.SkipAnimate, self),false)
	self.skip_animate =  false
	self.node_t_list.img_hook.node:setVisible(self.skip_animate)
	EventProxy.New(ZhenBaoGeData.Instance, self):AddEventListener(ZhenBaoGeData.SetDice, BindTool.Bind(self.SetDice, self))
	EventProxy.New(ZhenBaoGeData.Instance, self):AddEventListener(ZhenBaoGeData.InfoChange, BindTool.Bind(self.UpdateInfo, self))
	EventProxy.New(ZhenBaoGeData.Instance, self):AddEventListener(ZhenBaoGeData.LayerRewardChange, BindTool.Bind(self.UpateLayerReward, self))
	EventProxy.New(ZhenBaoGeData.Instance, self):AddEventListener(ZhenBaoGeData.ExchangeListUpdate, BindTool.Bind(self.UpdateProperty, self))
end

function ZhenBaoGeView:SetDice()
	local setdice = function ()
		self.node_t_list.img_dice.node:setVisible(true)
		local number = ZhenBaoGeData.Instance:GetZhenBaoGeData().dice_number or 1
		self.node_t_list.img_dice.node:loadTexture(ResPath.GetZhenBaoGe(number))

		local callback2 = cc.CallFunc:create(function ()
			self.node_t_list.img_dice.node:setVisible(false)
			self:RoleMove()
		end)
		local delay = cc.DelayTime:create(0.5)
		local action = cc.Sequence:create(delay,callback2)
		self.node_t_list.img_dice.node:runAction(action)
	end
	local x = self.node_t_list.layout_zhenbaoge.node:getContentSize().width/2-130
	local y = self.node_t_list.layout_zhenbaoge.node:getContentSize().height/2+130

	if self.skip_animate then
		setdice()
	else
		RenderUnit.PlayEffectOnce(399, self.node_t_list.layout_zhenbaoge.node, 100, x, y, false, setdice)
	end
end

function ZhenBaoGeView:SkipAnimate()
	self.skip_animate = not self.skip_animate
	self.node_t_list.img_hook.node:setVisible(self.skip_animate)
end

function ZhenBaoGeView:CreateTimer()
	self.rest_time = TimeUtil.RestTimeToWeekDay(2) --星期一为第二天
	if self.rest_time > 0 then 
		CountDown.Instance:RemoveCountDown(self.timer1)
		self.timer1 = CountDown.Instance:AddCountDown(self.rest_time, 1, BindTool.Bind(self.UpdateTimer,self))
	else
		self.node_t_list.lbl_rest_times.node:setVisible(false)
		self.node_t_list.lbl_text.node:setVisible(false)
	end
end

function ZhenBaoGeView:UpdateTimer()
	self.rest_time=self.rest_time-1
	if self.rest_time <= 0 then
		self.node_t_list.lbl_rest_times.node:setVisible(false)
		self.node_t_list.lbl_text.node:setVisible(false)
		self.rest_time=0
		CountDown.Instance:RemoveCountDown(self.timer1)
	else 
		self.node_t_list.lbl_rest_times.node:setVisible(true)
		self.node_t_list.lbl_text.node:setVisible(true)
	end
	self.node_t_list.lbl_rest_times.node:setString(TimeUtil.FormatSecond2Str(self.rest_time))
end


function ZhenBaoGeView:CreateNumberBar()
    self.layer_number = NumberBar.New()
    self.layer_number:Create(0,2, 80, 30, ResPath.GetCommon("num_151_"))
    self.layer_number:SetGravity(NumberBarGravity.Center)
    self.layer_number:SetNumber(1)
    self.node_t_list.img_floor.node:addChild(self.layer_number:GetView())
end

function ZhenBaoGeView:ThrowDice(tag)
	ZhenBaoGeCtrl.Instance.ReqThrowDice(tag)
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local info = ZhenBaoGeData.Instance:GetZhenBaoGeData()
	if tag == 1 then  --花费元宝
		if gold > 200  then
			self:SetThrowEnable(1,false)
			self:SetThrowEnable(2,false)
		end
	else
		self:SetThrowEnable(1,false)
		self:SetThrowEnable(2,false)
	end
end

function ZhenBaoGeView:SetThrowEnable(tag, enable)
	local color = enable and COLOR3B.YELLOW or COLOR3B.GRAY
	if tag == 1 then
		--免费次数
		self.node_t_list.layout_free.node:setEnabled(enable)
		self.node_t_list.lbl_free.node:setColor(color)
		self.node_t_list.img_free_btn.node:setGrey(not enable)
		self.node_t_list.img_remind.node:setVisible(enable)
	else
		--花费元宝
		self.node_t_list.layout_btn.node:setEnabled(enable)
		self.node_t_list.lbl_btn_text1.node:setColor(color)
		self.node_t_list.lbl_btn_text2.node:setColor(color)
		self.node_t_list.img_btn.node:setGrey(not enable)
		self.node_t_list.img_btn_bg.node:setGrey(not enable)
	end
end

function ZhenBaoGeView:RoleMove()
	local info = ZhenBaoGeData.Instance:GetZhenBaoGeData()
	self.pata_view:SetArrowStep(info.cur_step,true,ZhenBaoGeCtrl.Instance.ReqStepReward)
end

function ZhenBaoGeView:CreateLoadingBar()
	local x = self.node_t_list.layout_prog.node:getContentSize().width/2
	local y = self.node_t_list.layout_prog.node:getContentSize().height/2
	local width =self.ph_list.ph_prog.w
	local prog = XUI.CreateLoadingBar(x, y, ResPath.GetCommon("prog_104_progress"), XUI.IS_PLIST, nil, true, width, 23, cc.rect(20, 3, 5, 5))
	prog:setLocalZOrder(5)
	self.node_t_list.layout_prog.node:addChild(prog)
	self.pata_progerss = ProgressBar.New()
	self.pata_progerss:SetView(prog)
end

function ZhenBaoGeView:CreateRewardsView()
	self.reward_list = ZhenBaoGeData.Instance:GetLayerRewardList()
	self.icon_number = 0
	self.icon_list = {} 
	for k,v in pairs(self.reward_list) do
		self.icon_number = k
		self:CreateIcon(v)
	end
end

function ZhenBaoGeView:CreateIcon(data)
	local all_step = ZhenBaoGeData.Instance:GetZhenBaoGeData().setp_number
	if data.need_step > all_step then return end
	local sub_length =self.ph_list.ph_prog.w
	local ph_bar=self.ph_list.ph_bar
	--进度条间隔
	local img_bar = XUI.CreateImageView(data.need_step/all_step*sub_length+38,ph_bar.y, ResPath.GetCommon("prog_104_bar"), true)
	self.node_t_list.layout_prog.node:addChild(img_bar,100)

	local ph = self.ph_list.ph_icon
	local img_bg = XUI.CreateImageView(data.need_step/all_step*sub_length+48, ph.y, ResPath.GetMainui("icon_bg"), true)
	self.node_t_list.layout_zhenbaoge.node:addChild(img_bg,10)

	--宝箱图标
	--local item_cfg = ItemData.Instance:GetItemConfig(data.awards[1].item_id)
	--local str_path = ResPath.GetItem(item_cfg.icon)
	local str_path = ResPath.GetZhenBaoGe(string.format("box%d",self.icon_number))
	local img_icon = XUI.CreateImageView(img_bg:getContentSize().width/2,img_bg:getContentSize().height/2, str_path, true)
	img_icon:setName("img_icon")
	img_icon:setScale(0.9)
	img_bg:addChild(img_icon)

	--层数
	local layer_number = math.floor(( data.need_step - 1) / ZhenBaoGeData.Instance:GetZhenBaoGeData().layer_step) + 1
	local str_text = string.format(Language.ZhenBaoGe.Floor,layer_number)
	local text = XUI.CreateText(img_bg:getContentSize().width/2, 0, 100, 20, nil, str_text, nil, 16)
	text:setColor(COLOR3B.YELLOW)
	text:setName("text")
	img_bg:addChild(text)

	--红点
	local remind_img = XUI.CreateImageView(img_bg:getContentSize().width,img_bg:getContentSize().height, ResPath.GetMainui("remind_flag"), true)
	img_bg:addChild(remind_img, 999)
	remind_img:setName("remind_img")

 	self.icon_list[self.icon_number] = img_bg
	XUI.AddClickEventListener(img_bg, BindTool.Bind(self.ClickIcon,self,self.icon_number), false)
end

function ZhenBaoGeView:SetGray(tag,is_grey)
	local img_bg  = self.icon_list[tag]
	local img_icon = img_bg:getChildByName("img_icon")
	img_icon:setGrey(is_grey)
	local text =  img_bg:getChildByName("text")
	if is_grey then
		text:setColor(COLOR3B.GRAY)
	else
		text:setColor(COLOR3B.YELLOW)
	end
	img_bg.is_grey = is_grey
end

function ZhenBaoGeView:UpdateInfo()
	self:UpdateProperty()
	self:UpateLayerReward()
	local info = ZhenBaoGeData.Instance:GetZhenBaoGeData()
	self.node_t_list.lbl_free.node:setString(string.format(Language.ZhenBaoGe.FreeTimes,info.rest_time))
	if info.cur_step >= info.setp_number then
		self:SetThrowEnable(1,false)
		self:SetThrowEnable(2,false)
	else
		self:SetThrowEnable(2,true)
		if info.rest_time <= 0 then
			self:SetThrowEnable(1,false)
			self.node_t_list.img_remind.node:setVisible(false)
		else
			self:SetThrowEnable(1,true)
			self.node_t_list.img_remind.node:setVisible(true)
		end
	end
	local my_layer = self.pata_view:GetLayer(info.cur_step)
	self.node_t_list.lbl_my_floor.node:setString(string.format("%d", my_layer))
	self.cur_layer = my_layer
	if self.cur_layer < 1 then
		self.cur_layer = 1
	end
	self.layer_number:SetNumber(self.cur_layer)
end

function ZhenBaoGeView:UpdateProperty()
	--七彩石
	local str1 = string.format("%d",RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COLOR_STONE))
	self.node_t_list.lbl_color_stone.node:setString(str1)
	--龙魄
	str1 = string.format("%d",RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DRAGON_SPITIT))
	self.node_t_list.lbl_dargon_split.node:setString(str1)
	--进度条
	local data = ZhenBaoGeData.Instance:GetZhenBaoGeData()
	self.pata_progerss:SetPercent(data.cur_step/data.setp_number*100)
	self.exchange_list:SetDataList(ZhenBaoGeData.Instance:GetExchangeList())
end

function ZhenBaoGeView:UpateLayerReward()
	self.reward_list = ZhenBaoGeData.Instance:GetLayerRewardList()
	for k,v in pairs(self.reward_list) do
		if v.state == State.HasReceive then
			self:SetGray(k,true)
			self.icon_list[k]:getChildByName("remind_img"):setVisible(false)
		elseif v.state == State.CanReceive then
			self:SetGray(k,false)
			self.icon_list[k]:getChildByName("remind_img"):setVisible(true)
		elseif v.state == State.CanNotReceive then
			self:SetGray(k,false)
			self.icon_list[k]:getChildByName("remind_img"):setVisible(false)
		end
	end
end

function ZhenBaoGeView:ClickIcon(icon_number)
	if self.reward_list[icon_number].state  == State.CanReceive then
		ZhenBaoGeCtrl.Instance.ReqLayerReward(icon_number - 1)  --奖励下标从零开始
		local item_id  = self.reward_list[icon_number].awards[1].item_id  --获得奖励动画
		ZhenBaoGeCtrl.Instance:StartFlyItem(item_id)
	else
		TipCtrl.Instance:OpenItem(self.reward_list[icon_number].awards[1], EquipTip.FROM_NORMAL)
	end
 	
end

function  ZhenBaoGeView:SetBtnDerect()
	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind(self.OnClickUpBtn, self))
	XUI.AddClickEventListener(self.node_t_list.btn_down.node, BindTool.Bind(self.OnClickDownBtn, self))
	self.node_t_list.btn_down.node:setRotation(90)
	self.node_t_list.btn_up.node:setRotation(-90)
end

function ZhenBaoGeView:OnClickUpBtn()
	self.cur_layer = self.cur_layer + 1
	local max  = ZhenBaoGeData.Instance:GetZhenBaoGeData().layer_number
	if self.cur_layer > max then
		self.cur_layer = max
	end
	self.pata_view:JumpTolayer(self.cur_layer, 0.5)
	self.layer_number:SetNumber(self.cur_layer)
end

function ZhenBaoGeView:OnClickDownBtn()
	self.cur_layer = self.cur_layer - 1
	if self.cur_layer < 1 then
		self.cur_layer = 1
	end
	self.pata_view:JumpTolayer(self.cur_layer, 0.5)
	self.layer_number:SetNumber(self.cur_layer)
end

function ZhenBaoGeView:CreatePataList()
	local ph_window = self.ph_list.ph_window
	self.pata_view = RewardView.New(cc.p(ph_window.x, ph_window.y), cc.size(ph_window.w, ph_window.y))
	local award_data = ZhenBaoGeData.Instance:GetStepRewardList()
	self.pata_view:SetDataList(award_data)
	self.pata_view:AddTo(self.node_t_list.layout_zhenbaoge.node,12)

	local arrow_node = cc.Node:create()
	arrow_node:setAnchorPoint(0.5, 0.5)
	self.pata_view:SetArrowNode(arrow_node)
	--主体
	self.role_res_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_MODEL_ID)
	local anim_path, anim_name = "", ""
	anim_path, anim_name = ResPath.GetRoleAnimPath(self.role_res_id, "stand", 2)
	local anim_aprite = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	anim_aprite:setName("anim_aprite")
	arrow_node:addChild(anim_aprite,100)
end

function ZhenBaoGeView:CreateExChangeList()
	if self.exchange_list == nil then
		local ph = self.ph_list.ph_list
		self.exchange_list = ListView.New()
		self.exchange_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ExchangeRender, nil, nil, self.ph_list.ph_item)
		self.exchange_list:SetItemsInterval(4)
		self.exchange_list:SetMargin(2)
		self.exchange_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_zhenbaoge.node:addChild(self.exchange_list:GetView(),999)
		self.exchange_list:SetDataList(ZhenBaoGeData.Instance:GetExchangeList())
	end	
end

function ZhenBaoGeView:OpenCallBack()
	
end

function ZhenBaoGeView:CloseCallBack()
	
end

function ZhenBaoGeView:OnFlush()
	self:UpateLayerReward()
end

-----------------------------------------------------------------
-- ExchangeRender begin
-----------------------------------------------------------------


ExchangeRender = ExchangeRender or BaseClass(BaseRender)
function ExchangeRender:__init()
end

function ExchangeRender:__delete()
    self.item_cell:DeleteMe()
end

function ExchangeRender:CreateChild()
    BaseRender.CreateChild(self)
    XUI.AddClickEventListener(self.node_tree.btn_exchange.node, BindTool.Bind(self.OnClcikExchange, self))
    local ph = self.ph_list.ph_cell
   	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(ph.x, ph.y)
	self.item_cell:SetAnchorPoint(0.5, 0.5)
	self:GetView():addChild(self.item_cell:GetView(), 103)
end

function ExchangeRender:OnClcikExchange()
  BagCtrl.SendComposeItem(ITEM_SYNTHESIS_TYPES.COLOR_STONE, self.index, 0)
end

function ExchangeRender:OnFlush()
	if self.data~= nil then
		self.item_cell:SetData(self.data.awards[1])
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.awards[1].item_id)
		self.node_tree.lbl_name.node:setString(item_cfg.name)
		self.node_tree.lbl_value.node:setString(string.format("%d",self.data.consume[1].count))

		local item_id = ItemData.GetVirtualItemId(self.data.consume[1].type)
		local consume_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_id > 0 then
			self.node_tree.img_stone.node:loadTexture(ResPath.GetItem(consume_cfg.icon))
			self.node_tree.img_stone.node:setScale(0.5)
		end
		if self.data.can_exchange == 1 then
			self.node_tree.img_remind.node:setVisible(true)
		else
			self.node_tree.img_remind.node:setVisible(false)
		end
	end
end

-----------------------------------------------------------------
-- ExchangeRender end
-----------------------------------------------------------------

-----------------------------------------------------------------
-- RewardView begin
-----------------------------------------------------------------
local SCALE  = 0.7
RewardView.MOVE_ARROW_STATE = {
	MOVE_END = 0,
	MOVE_ARROW = 1,
	MOVE_LAYER = 2,
}
function RewardView:__init(pos, size)
	self.pos = pos
	self.size = size
	self.rewards = {}
	self.data_list = {}

	self.row_interval = 1
	self.col_interval = 0
	self.vertical_margin = 0
	self.horizontal_margin = 50
	self.item_w = 76*SCALE
	self.item_h = 77*SCALE

	self.reward_pos_t = {
		{1,	2, 3, 4, 5, 6, 7, 8},
		{0, 0, 0, 0, 0, 0, 0, 9},
		{0, 0, 0, 0, 0, 0, 0, 10},
		{18,17, 16, 15, 14, 13, 12, 11},
		{19, 0, 0, 0, 0, 0, 0, 0},
		{20, 0, 0, 0, 0, 0, 0, 0},
	}
	self.idx_row_col = {}
	for row, col_t in pairs(self.reward_pos_t) do
		for col, i in pairs(col_t) do
			if i > 0 then
				self.idx_row_col[i] = {row  = row, col = col}
			end
		end 
	end

	self.layer_row = #self.reward_pos_t
	self.layer_col = #self.reward_pos_t[1]
	self.layer_item_num = #self.idx_row_col
	self.one_layer_h = self.layer_row * self.item_h + self.vertical_margin + (self.layer_row - 0) * self.row_interval

	self.last_step = 0
	self.cur_step = 0
	self.step = 0
	self.move_arrow_state = 0
	self.move_end_callback = nil
	self.cur_layer = 1

	self.last_dir = -1

	self.view = XUI.CreateScrollView(self.pos.x, self.pos.y, self.size.width, self.one_layer_h, ScrollDir.Vertical)
	self.view:setTouchEnabled(false)
	self.create_rewards_task = nil
end

function RewardView:__delete()
	GlobalTimerQuest:CancelQuest(self.move_timer)
	self.move_timer = nil
	self.view = nil
	Runner.Instance:RemoveRunObj(self)
	self.create_rewards_task = nil
end

function RewardView:AddTo(parent, zorder)
	if nil ~= parent then
		parent:addChild(self.view, zorder or 0)
	end
end

function RewardView:ArrowCanMove()
	return self.move_arrow_state == RewardView.MOVE_ARROW_STATE.MOVE_END
end

function RewardView:SetArrowStep(step, is_move, move_end_callback)
	if self.step ~= step then
		self.last_step = self.step
		self.step = step
	else
		return false
	end

	self.move_end_callback = move_end_callback
	if is_move then
		if not self:ArrowCanMove() then
			return false
		end

		self.arrow_move_speed = 2
		self:ArrowMove()
	else
		self:ArrowMoveEnd()
	end

	return true
end

function RewardView:ArrowMove()


	local next_step = self.cur_step + 1
	if next_step > self.step then
		self:ArrowMoveEnd()
		return
	end

	local next_layer = self:GetLayer(next_step)
	if self.cur_layer ~= next_layer then
		self.move_arrow_state = RewardView.MOVE_ARROW_STATE.MOVE_LAYER
		local jump_time = 0.88
		self:JumpTolayer(self:GetLayer(next_step), jump_time)
		GlobalTimerQuest:CancelQuest(self.move_timer)
		self.move_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.move_timer = nil
			self:ArrowMove()
		end, jump_time)
		return
	end

	self.move_arrow_state = RewardView.MOVE_ARROW_STATE.MOVE_ARROW
	local callfunc = cc.CallFunc:create(function()
		self.cur_step = self.cur_step + 1
		self:ArrowMove()
	end)
	-- local act = cc.Sequence:create(cc.DelayTime:create(0.14), cc.Place:create(cc.p(self:GetPosByStep(next_step))), callfunc)
	--self.arrow_move_speed = (self.arrow_move_speed * 0.5) > 0.27 and self.arrow_move_speed * 0.5 or 0.27
	self:TurnDirection(RoleState.Run)
	self.arrow_move_speed = 1
	local act = cc.Sequence:create(cc.MoveTo:create(0.21 * self.arrow_move_speed, cc.p(self:GetPosByStep(next_step))), callfunc)
	self:GetArrow():stopAllActions()
	self:GetArrow():runAction(act)
end

function RewardView:TurnDirection(type)    --1 run 2 stand
	local my_stype = self.cur_step % 20
	if my_stype <= 7 and my_stype > 0 then
		self.cur_dir  =  2
	elseif my_stype <= 10 and my_stype >= 8 then
		self.cur_dir  =  0
	elseif my_stype >= 11 and my_stype <= 17 then
		self.cur_dir  =  6
	elseif my_stype >= 18 and my_stype <=20 then
		self.cur_dir  =  0
	else
		self.cur_dir  =  2
    end

   	
   	local res_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_MODEL_ID)
    if type == RoleState.Run then
    	if self.last_dir ~= self.cur_dir then
	    	local anim_aprite  = self:GetArrow():getChildByName("anim_aprite")
			local anim_path, anim_name = ResPath.GetRoleAnimPath(res_id,"run" , self.cur_dir)
			anim_aprite:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.05, false)
			self.last_dir = self.cur_dir
    	end
    else
    	local anim_aprite  = self:GetArrow():getChildByName("anim_aprite")
		local anim_path, anim_name = ResPath.GetRoleAnimPath(res_id,"stand" ,self.cur_dir)
		anim_aprite:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.last_dir = -1
    end
end

function RewardView:ArrowMoveEnd()
	GlobalTimerQuest:CancelQuest(self.move_timer)
	self.move_timer = nil

	self:GetArrow():stopAllActions()
	self:GetArrow():setPosition(self:GetPosByStep(self.step))
	self:JumpTolayer(self:GetLayer(self.step), 0)
	self.cur_step = self.step
	self:GetArrow():setVisible(self.cur_step > 0 and self.cur_step < #self.data_list)

	if self.move_end_callback then
		self.move_end_callback()
	end
	self.move_arrow_state = RewardView.MOVE_ARROW_STATE.MOVE_END
	self:TurnDirection(RoleState.Stand) 
end

function RewardView:GetArrow()
	return self.view:getChildByName("arrow")
end

function RewardView:SetArrowNode(node)
	if nil == self.view:getChildByName("arrow") then
		self.view:addChild(node, 200)
		node:setPosition(self.horizontal_margin-20,self.vertical_margin)
		node:setName("arrow")
	end
	--local str_path = ResPath.GetZhenBaoGe("btn_138")
	local str_path = ResPath.GetCommon("btn_138")
	local img_icon = XUI.CreateImageView(0, 0, str_path, true)
	img_icon:setScaleX(0.4)
	img_icon:setScaleY(0.95)
	img_icon:setAnchorPoint(0, 0)
	self.view:addChild(img_icon, 199)
end

function RewardView:GetPosByRowCol(row, col)
	return (col - 1) * (self.item_w + self.col_interval) + self.item_w * 0.5 + self.horizontal_margin,
		(row - 1) * (self.item_h + self.row_interval) + self.item_h * 0.5 + self.vertical_margin
end

function RewardView:GetLayer(idx)
	return math.floor((idx - 1) / self.layer_item_num) + 1
end

function RewardView:GetRowCol(idx)
	return self.idx_row_col[idx] or {row = 0, col = 0}
end

function RewardView:JumpTolayer(layer, time, attenuated)
	self.view:scrollToPositionY(- (layer - 1) * self.one_layer_h, time or 0.5, attenuated or false)
	self.cur_layer = layer
end

function RewardView:GetPosByStep(step)
	local layer_idx = self:GetLayer(step)
	local row_col_t = self:GetRowCol(step - (layer_idx - 1) * self.layer_item_num)
	local row = row_col_t.row + (layer_idx - 1) * self.layer_row
	local col = row_col_t.col
	return self:GetPosByRowCol(row, col)
end

function RewardView:Update()
	if nil ~= self.create_rewards_task then
	    local status = coroutine.resume(self.create_rewards_task, self)
	    if not status then
	    	self.create_rewards_task = nil
			Runner.Instance:RemoveRunObj(self)
	    end
	end
end

function RewardView:SetDataList(data_list)
	self.data_list = data_list or {}

	local max_row = math.floor(#self.data_list / self.layer_item_num) * self.layer_row
	self.view:setInnerContainerSize(cc.size(
		self.layer_col * self.item_w + (self.layer_col - 1) * self.col_interval + 2 * self.horizontal_margin,
		max_row * self.item_h + (max_row - 1) * self.row_interval + 2 * self.vertical_margin
	))

    self.create_rewards_task = coroutine.create(self.CreateRewards)
	Runner.Instance:AddRunObj(self)
end

function RewardView:CreateRewards(begin_step)
	--创建cell
	local function create_cell(idx)
		local item_data = self.data_list[idx]
		local cell = BaseCell.New()
		cell:SetIsUseStepCalc(true)
		cell:SetPosition(self:GetPosByStep(idx))
		cell:SetIndex(idx)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetData(item_data)
		cell:GetView():setPropagateTouchEvent(false)
		cell:GetView():setScale(SCALE)
		cell:SetRightBottomText(item_data.count,COLOR3B.RED,22, 1)
		self.view:addChild(cell:GetView(), 99)
		self.rewards[idx] = cell
	end

	--第一次创建cell
	self.rewards = {}
	local idx = 1
	local item_data = self.data_list[idx]
	local second_idx = 0
	while item_data do
		create_cell(idx)
		idx = idx + 1
		if (self.step - self.layer_item_num ) > idx then -- 已经走过的步数跳过创建(预留1层数量)
			idx = self.step - self.layer_item_num 
			second_idx = idx -1
		end
		item_data = self.data_list[idx]

		if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.012 then
	        coroutine.yield(idx)
		end
	end

	--将跳过的步数创建出来
	if second_idx > 0 then  
		local idx = second_idx
		local item_data = self.data_list[idx]
		while item_data do
			create_cell(idx)
			idx = idx - 1
			item_data = self.data_list[idx]
			second_idx = idx

			if XCommon:getHighPrecisionTime() - HIGH_TIME_NOW >= 0.012 then
		        coroutine.yield(idx)
			end
		end
	end
end
-----------------------------------------------------------------
-- RewardView end
-----------------------------------------------------------------
return ZhenBaoGeView