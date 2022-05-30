
-- --------------------------------------------------------------------
WeeklyStoneChamberPanel = class("WeeklyStoneChamberPanel", function()
	return ccui.Widget:create()
end)

local controll = WeeklyActivitiesController:getInstance()
local model    = WeeklyActivitiesController:getModel()
local card_data = Config.ChargeData.data_constant
local mainui_ctrl = MainuiController:getInstance()
local string_format = string.format
local pf_ctrl = PlanesafkController:getInstance()

function WeeklyStoneChamberPanel:ctor()
	self.current_day = 0
	self.isPlay = false
	self.scheduleNum = 0
	self.item_id = 17451

	self.cur_grid = 0
	self.box_num = 0
	self.cur_box_num = 0

	self.cur_direction = 0
	self.role_jump_direction = 0
	self.is_lock = false
	self.is_send = true
	self.item_num = 0
	self:loadResources()
	controll:send_29207()
end

function WeeklyStoneChamberPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","txt_cn_hippocreneBg"), type = ResourcesType.single },
    	} 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
        	self:loadResListCompleted()
        end
    end)
end

function WeeklyStoneChamberPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end

function WeeklyStoneChamberPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/stone_chamber_panel"))
	self:addChild(self.root_wnd)
	self:setAnchorPoint(0, 0)
	
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.animtionNode   = self.main_container:getChildByName("animtionNode")
--
	local bg = self.main_container:getChildByName("bg")
	local res_id = PathTool.getPlistImgForDownLoad("bigbg/welfare", "stone_chamberBg")
	loadSpriteTexture(bg,res_id,LOADTEXT_TYPE)
	self.btn_cultivate1 = self.main_container:getChildByName("btn_cultivate1")
	self.btn_cultivate10 = self.main_container:getChildByName("btn_cultivate10")
	self.btn_reward = self.main_container:getChildByName("btn_reward")
	self.btn_rank = self.main_container:getChildByName("btn_rank")
	local buy_panel = self.main_container:getChildByName("buy_panel")
	self.add_btn = buy_panel:getChildByName("add_btn")
	self.btn_rule = self.main_container:getChildByName("btn_rule")
	self.btn_check_frame = self.main_container:getChildByName("btn_check_frame")
	self.gou_img = self.btn_check_frame:getChildByName("Image_6")
	self.move_panel = self.main_container:getChildByName("move_panel")
	
	local schedule_panel = self.main_container:getChildByName("schedule_panel")
	self.schedule_num = schedule_panel:getChildByName("label")

	local treasure_box_panel = self.main_container:getChildByName("treasure_box_panel")
	self.treasure_box_num =  treasure_box_panel:getChildByName("label")
	self.time_text   = self.main_container:getChildByName("time_text")

	self.time_text   = self.main_container:getChildByName("time_text")
	self.time_text_0   = self.main_container:getChildByName("time_text_0")
	self.schedule_num_0 = schedule_panel:getChildByName("label_0")
	self.time_text_0:setString(TI18N("剩余时间："))
	self.schedule_num_0:setString(TI18N("我的进度"))
	
	self.item_conut = buy_panel:getChildByName("label")
	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
    self.item_conut:setString(tostring(count))
    self.item_num = count

    self.grid_str = self.main_container:getChildByName("Text_1")
    self.grid_str:setVisible(false)

    self.explode_node = self.main_container:getChildByName("explode_node")

	self.move_item_tabs = {}

	for i=1,2 do
		local item = self.move_panel:getChildByName("move_item_page"..i)
		if i == 2 then 
			self.cur_step_on_item = item:getChildByName("move_item1") --默认踩中第一格子
		end
		for i=1,3 do
			local moveItem = item:getChildByName("move_item"..i)
			self:setMoveItem(moveItem,i)
		end
		table.insert(self.move_item_tabs, item)
	end
	self:showRoleInfo( )
	self:setLessTime(model:getWeeklyActivityData())
	self:explodeEfft( )
	--controll:updateTipsStatus()
end

function WeeklyStoneChamberPanel:setBoxAndGridNum(box_num,grid_num)
	self.cur_grid = grid_num
	self.box_num = box_num
	--print("---------当前格子数--222----->>",self.cur_grid)
	local grid_num = string_format(TI18N("距离本路面任务还差%s格"),grid_num)
	--self.grid_str:setString(grid_num)
	self.schedule_num:setString("x"..self.cur_grid)
	self.treasure_box_num:setString("x"..box_num)
end

function WeeklyStoneChamberPanel:setMoveTierNum( tier )
	self.cur_grid = tier
	--print("---------当前格子数------->>",self.cur_grid)
	local x,y = self.animtionNode:getPosition()
	if self.cur_grid > 0 then 
		local cur_grid = self.cur_grid % 3
		self.animtionNode:setPosition(x,y + 200)
		if cur_grid > 0 then  
			self.animtionNode:setPosition(x-150,y + 200)
		end
		local movePosY = 0
		if cur_grid == 0 then 
		    movePosY = -400
		elseif cur_grid == 2  then 
			movePosY = -200
		end
		for i=1,2 do
			local x,y = self.move_item_tabs[i]:getPosition()
			self.move_item_tabs[i]:setPosition(x,y + movePosY)
		end
	end
	self:actionStopEvent()
end

function WeeklyStoneChamberPanel:starExplodeEfft(is_boo)
	local x,y = self.animtionNode:getPosition()
	self.explode_node:setVisible(true) --is_boo == 0 and
	if  is_boo == 0 and ( x == 205 or x == 505 )  then 
		self.efftEx:setAnimation(0, "action", false)
		self.explode_node:setPosition(x,y)
		return
	elseif self.cur_box_num == self.box_num and ( x == 205 or x == 505 ) then
		self.efftEx:setAnimation(0, "action", false)
		self.explode_node:setPosition(x,y)
		return
	end
	self.cur_box_num = self.box_num
end

function WeeklyStoneChamberPanel:explodeEfft( )
	self.explode_node:setVisible(false)
	self.explode_node = self.main_container:getChildByName("explode_node")
	self.efftEx = createEffectSpine("E23001",cc.p(0,0),cc.p(0.5, 0.5),false,"action",handler(self,self.explodeStopEvent))
	self.explode_node:addChild(self.efftEx,0)
end

function WeeklyStoneChamberPanel:explodeStopEvent( )
	self.explode_node:setVisible(false)
end

function WeeklyStoneChamberPanel:setMoveItem( node_panel, index )
	if index == 1 then 
		local efft = createEffectSpine("clone_battle",cc.p(0,0),cc.p(0.5, 0.5),true,"action")
		efft:setName("efft_anim")
		local x,y = node_panel:getChildByName("qanim"):getPosition()
		efft:setScale(0.5)
		efft:setPosition(x,y+30)
		node_panel:addChild(efft,0)
	else
		local efft1 = createEffectSpine("buzhuo",cc.p(0,0),cc.p(0.5, 0.5),true,"jinglinqiu_effect_loop")
		efft1:setName("efft_anim1")
		efft1:setScale(0.5)
		local x,y = node_panel:getChildByName("q1_4"):getPosition()
		efft1:setPosition(x,y+60)
		node_panel:addChild(efft1,1)

		local efft2 = createEffectSpine("buzhuo",cc.p(0,0),cc.p(0.5, 0.5),true,"jinglinqiu_effect_loop")
		efft2:setName("efft_anim2")
		efft2:setScale(0.5)
		local x,y = node_panel:getChildByName("q2_5"):getPosition()
		efft2:setPosition(x,y+60)
		node_panel:addChild(efft2,2)
	end
	if self.cur_step_on_item then 
		self.cur_step_on_item:getChildByName("efft_anim"):setVisible(false)--第一格不显示
	end
end

function WeeklyStoneChamberPanel:starMoveAction()
	for i=1,2 do
		local x,y =  self.move_item_tabs[i]:getPosition()
		local pos = cc.p(x,y - 200)
		local act_move1 = cc.MoveTo:create(0.11,cc.p(pos.x,pos.y))
		if y == 0 or y < 0  then 
    		self.move_item_tabs[i]:runAction(
    			cc.Sequence:create(act_move1, cc.CallFunc:create(handler(self,self.actionStopEvent))))
    	else
    		self.move_item_tabs[i]:runAction(act_move1)
    	end
	end
end


function  WeeklyStoneChamberPanel:getCurStepOnItem( )
	for i=1,2 do
		local x,y =  self.move_item_tabs[i]:getPosition()
		if y == 0  then 
			
			if self.cur_grid > 0 then
				self.cur_step_on_item = self.move_item_tabs[i]:getChildByName("move_item2")
				self:setEfftAnimIsShow(self.move_item_tabs[i]:getChildByName("move_item1"),false )
			else
				self.cur_step_on_item = self.move_item_tabs[i]:getChildByName("move_item1")
			end
		elseif y == -200 then
			self.cur_step_on_item = self.move_item_tabs[i]:getChildByName("move_item3")
			self:setEfftAnimIsShow(self.move_item_tabs[i]:getChildByName("move_item2"),false )
		elseif y == -400 then
			local index = 1
			if i == 1 then 
				index = 2
			end
			self.cur_step_on_item = self.move_item_tabs[index]:getChildByName("move_item1")
			self:setEfftAnimIsShow(self.move_item_tabs[i]:getChildByName("move_item3"),false )
		elseif y == -600 then
			local index = 1
			if i == 1 then 
				index = 2
			end
			self.cur_step_on_item = self.move_item_tabs[index]:getChildByName("move_item2")
			self:setEfftAnimIsShow(self.move_item_tabs[index]:getChildByName("move_item1"),false )
			self.move_item_tabs[i]:setPosition(x,600)
			for j=1,3 do
				local item = self.move_item_tabs[i]:getChildByName("move_item"..j)
				item:setVisible(true)
				if j == 1 then 
					item:getChildByName("efft_anim"):setVisible(true)
				else
					item:getChildByName("efft_anim1"):setVisible(true)
					item:getChildByName("efft_anim2"):setVisible(true)
				end
			end
		end
	end
end

function WeeklyStoneChamberPanel:setEfftAnimIsShow( node ,is_show )
	if node then 
		local x,y = self.animtionNode:getPosition()
		if node:getChildByName("efft_anim") then 
			node:getChildByName("efft_anim"):setVisible(is_show)
		else
			node:getChildByName("efft_anim1"):setVisible(is_show)
			node:getChildByName("efft_anim2"):setVisible(is_show)
		end
	end
end

function WeeklyStoneChamberPanel:actionStopEvent()
	self:getCurStepOnItem( )
	self:setEfftAnimIsShow( self.cur_step_on_item ,false )
	self.is_lock = false
	self.is_send = true
end
function WeeklyStoneChamberPanel:startJumpItemStatus( direction )
	local item = self.move_item_tabs[2]:getChildByName("move_item2")
	item:getChildByName("efft_anim"..direction):setVisible(false)
	self.is_lock = false
end

function WeeklyStoneChamberPanel:showRoleInfo( )
    local look_id = pf_ctrl:getModel():getPlanesRoleLookId()
    local role_vo = RoleController:getInstance():getRoleVo()
    look_id = 1
    if role_vo.sex == 1 then
    	look_id = 2
    end
    local figure_cfg = Config.HomeData.data_figure[look_id]
    local effect_id = "H60001"
    if figure_cfg then
        effect_id = figure_cfg.look_id
    end
    self.map_role = createEffectSpine( effect_id, cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.stand )
    self.map_role:setScale(1)
    self.animtionNode:addChild(self.map_role)
    self.map_role:setPosition(0, 0)
end

function WeeklyStoneChamberPanel:startJumpEvent( direction )
	if self.is_lock  == true then return end
	self.is_lock  = true
	self.cur_direction = direction
	self.cur_grid = self.cur_grid + 1
	local x,y = self.animtionNode:getPosition()
	--print("self.cur_grid % 3 ~= 0 ---->",self.cur_grid)
	if direction == 1 then 
		if self.cur_grid % 3 ~= 0 then
			if self.cur_grid == 1 then
				self:setRoleJumpDirection( 7 )
				self:startJumpItemStatus( direction )
				self.is_lock = false
				self.is_send = true
				return
			end
			self:starMoveAction()
			if x == 355  then
				self:setRoleJumpDirection( 3 )
				return
			elseif x == 205  then 
				self:setRoleJumpDirection( 0 ) --不变
				return
			elseif x == 505 then 
				self:setRoleJumpDirection( 1 )
				return
			end
		end
		self:starMoveAction()
		if self.cur_grid % 3 == 0 and x == 205 then 
			self:setRoleJumpDirection( 5 )
			return
		elseif self.cur_grid % 3 == 0 and x == 505 then 
			self:setRoleJumpDirection( 6 )
			return
		end
	elseif direction == 2 then 
		if self.cur_grid % 3 ~= 0 then
			if self.cur_grid == 1 then
				self:setRoleJumpDirection( 8 )
				self:startJumpItemStatus( direction )
				self.is_lock = false
				self.is_send = true
				return
			end
			self:starMoveAction()
			if x == 355  then
				self:setRoleJumpDirection( 4 )
				return
			elseif x == 205 then 
				--self.cur_step_on_item:getChildByName("efft_anim")
				self:setRoleJumpDirection( 2 ) 
				return
			elseif x == 505 then 
				self:setRoleJumpDirection( 0 )
				return
			end
		end
		self:starMoveAction()
		if self.cur_grid % 3 == 0 and x == 205 then 
			self:setRoleJumpDirection( 5 )
			return
		elseif self.cur_grid % 3 == 0 and x == 505 then 
			self:setRoleJumpDirection( 6 )
			return
		end
	end
	--local x,y = self.animtionNode:getPosition()
end

function WeeklyStoneChamberPanel:setRoleJumpDirection( jump_direction )
	if jump_direction == 1 then   --右边跳左边
		self:roleJumpEvent( -300,0)
	elseif jump_direction == 2 then--左边跳右边
		self:roleJumpEvent( 300,0)
	elseif jump_direction == 3 then--中间跳左边 
		self:roleJumpEvent( -150,0)
	elseif jump_direction == 4 then--中间跳右边 
		self:roleJumpEvent( 150,0)
	elseif jump_direction == 5 then--左边跳中间 
		self:roleJumpEvent( 150,0)
	elseif jump_direction == 6 then--右边跳中间 
		self:roleJumpEvent( -150,0)
	elseif jump_direction == 7 then--起步的时候开始跳(中间跳上去左边)
		self:roleJumpEvent( -150,200)
	elseif jump_direction == 8 then--起步的时候开始跳(中间跳上去右边)
		self:roleJumpEvent( 150,200)
	else
		--self:starExplodeEfft(self.box_num)
		self:roleJumpEvent( 0,0)
	end
	self.role_jump_direction = jump_direction
end

function WeeklyStoneChamberPanel:roleJumpEvent( x_pos,y_pos)
	local x,y =  self.animtionNode:getPosition()
	local act_move1 = cc.MoveTo:create(0.1,cc.p(x+x_pos,y+y_pos))
	self.animtionNode:runAction(cc.Sequence:create(act_move1, cc.CallFunc:create(handler(self,self.setRoleMove))))
	--self.animtionNode:runAction(act_move1)
end

function WeeklyStoneChamberPanel:setRoleMove(  )
	self:starExplodeEfft(self.box_num)
end

function WeeklyStoneChamberPanel:setLessTime(data)
	local time = (data.end_time or 0 ) - GameNet:getInstance():getTime()
	if time < 0 then return end
	self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))
	
    if self.time_ticket == nil then
		local _callback = function() 
			local time = data.end_time-GameNet:getInstance():getTime()
			if  time >= 0 then
				self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))
			else
				if self.time_ticket then
        			GlobalTimeTicket:getInstance():remove(self.time_ticket)
        			self.time_ticket = nil
    			end
			end
		end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback)
    end
end

function WeeklyStoneChamberPanel:register_event()
	self.int_stone_chamber = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.INIT_STONE_CHAMBER, function(data)
		if data then
			--dump(data, "---------------初始化数据")
			if self.cur_grid == 0 then 
				self:setMoveTierNum(data.cur_grid)
			end
			self:setBoxAndGridNum(data.box_num , data.cur_grid)
			--if data.cur_grid > 0 then 
			--	--self:starExplodeEfft(data.box_num)
			--end
			
		end
	end)

	self.around_jump = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.AROUND_JUMP, function(data)
		if data then
			--dump(data,"------------左右跳返回数据---------------->>")
			--self:setBoxAndGridNum(data.box_num,data.cur_grid)
			--self:setMoveTierNum( data.cur_grid )
			--self:setLessTime(data)
		end
	end)

	self.lottery_result = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.LOTTERY_RESULTS, function(data)
		if data then
			--dump(data,"------------lottery_results---------------->>")
			--self:setBoxAndGridNum(data.box_num,data.cur_grid)
			--self:setMoveTierNum( data.cur_grid )
			--self:setLessTime(data)
		end
	end)
	--WeeklyActivitiesEvent.INIT_STONE_CHAMBER
	registerButtonEventListener(self.btn_cultivate1, function()
		
		if self.item_num > 0 and self.is_send == true then 
			self.is_send = false
			self:startJumpEvent( 1 )
			controll:send_29208()
			
		end
		if self.item_num <= 0 then 
			local config = Config.ItemData.data_get_data(self.item_id)
			BackpackController:getInstance():openTipsSource(true, config)
		end
    end,true, 1)

    registerButtonEventListener(self.btn_cultivate10, function()
    	if self.item_num > 0  and self.is_send == true then 
    		self.is_send = false
			self:startJumpEvent( 2 )
			controll:send_29208()
			
		end
		if self.item_num <= 0 then 
			local config = Config.ItemData.data_get_data(self.item_id)
			BackpackController:getInstance():openTipsSource(true, config)
		end
    end,true, 1)

    registerButtonEventListener(self.btn_reward, function()
		controll:openRankWindow( true ,2)
    end,true, 1)

    registerButtonEventListener(self.btn_rank, function()
		controll:openRankWindow( true ,1)
    end,true, 1)

    registerButtonEventListener(self.add_btn, function()
    	local config = Config.ItemData.data_get_data(self.item_id)
		BackpackController:getInstance():openTipsSource(true, config)
    end,true, 1)

    registerButtonEventListener(self.btn_check_frame, function()
    	local visible = self.gou_img:isVisible() 
    	self.gou_img:setVisible( not visible)


    end,true, 1)


    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
		local des = controll:getActiviceDes()
	    TipsManager:getInstance():showCommonTips(des, sender:getTouchBeganPosition(),nil,nil,500)
    end ,false)

    if self.add_goods_event == nil then
   		self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
      		local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
      		self.item_conut:setString(tostring(count))
			self.item_num = count
    	end)
    end
    
    if  self.del_goods_event == nil then
    	self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
        	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
        	self.item_conut:setString(tostring(count))
        	self.item_num = count
        	--print(self.item_num,"-----------------------------------1")
    	end)
    end
    

    if self.modify_goods_event == nil then 
    	self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
    	    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    	    self.item_conut:setString(tostring(count))
    	    self.item_num = count
    	    --print(self.item_num,"-----------------------------------2")
    	end)
    end
end

function WeeklyStoneChamberPanel:setVisibleStatus(bool)
	--bool = bool or false
	--self:setVisible(bool)
end

function WeeklyStoneChamberPanel:DeleteMe()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end

    if self.title_load then 
        self.title_load:DeleteMe()
        self.title_load = nil
    end

    if self.animtionNode then 
        self.animtionNode:removeSelf()
        self.animtionNode = nil
    end

	if self.update_week_data ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_week_data)
		self.update_week_data = nil
	end
	if self.update_cultivace ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_cultivace)
		self.update_cultivace = nil
	end
	if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end

    if self.add_goods_event then 
    	GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end

    if self.del_goods_event then 
    	GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end
    if self.modify_goods_event then 
    	GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.around_jump then 
    	GlobalEvent:getInstance():UnBind(self.around_jump)
        self.around_jump = nil
    end
    if self.lottery_result then 
    	GlobalEvent:getInstance():UnBind(self.lottery_result)
        self.lottery_result = nil
    end
    if self.int_stone_chamber then 
    	GlobalEvent:getInstance():UnBind(self.int_stone_chamber)
        self.int_stone_chamber = nil
    end
end 