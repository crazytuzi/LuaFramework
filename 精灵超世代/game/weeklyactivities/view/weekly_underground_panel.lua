
-- --------------------------------------------------------------------
WeeklyUndergroundPanel = class("WeeklyUndergroundPanel", function()
	return ccui.Widget:create()
end)

local controll = WeeklyActivitiesController:getInstance()
local model    = WeeklyActivitiesController:getModel()
local card_data = Config.ChargeData.data_constant
local mainui_ctrl = MainuiController:getInstance()
local string_format = string.format
local pf_ctrl = PlanesafkController:getInstance()


function WeeklyUndergroundPanel:ctor()
	self.current_day = 0
	self.isPlay = false
	self.playNum = 1
	self.item_id = 17447
	self.progressValue = 0
	--self.progreass_max_conut = 9
	self.cur_progress_const = 0
	self.img_index = 1
	self.item_const = 0
	self.tier_num = 0
	self.isFree = false

	self:loadResources()
	controll:send_29210()
end

function WeeklyUndergroundPanel:loadResources()
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

function WeeklyUndergroundPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end

function WeeklyUndergroundPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/hippocrene_underground_panel"))
	self:addChild(self.root_wnd)
	self:setAnchorPoint(0, 0)
	
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.animtionNode   = self.main_container:getChildByName("animtionNode")

	self.undergroundBg = self.main_container:getChildByName("bg")
	local res_id = PathTool.getPlistImgForDownLoad("bigbg/welfare", "underground_bg" .. self.img_index)
	loadSpriteTexture(self.undergroundBg,res_id,LOADTEXT_TYPE)
	self.title_2 = self.main_container:getChildByName("title_2")
	local res_id = PathTool.getTargetRes("weeklyactivity/weeklyunderground", "title")
	loadSpriteTexture(self.title_2,res_id,LOADTEXT_TYPE)

	self.btn_cultivate1 = self.main_container:getChildByName("btn_cultivate1")
	self.btn_cultivate10 = self.main_container:getChildByName("btn_cultivate10")
	self.btn_free_to_explore = self.main_container:getChildByName("btn_free_to_explore")

	self.btn_reward = self.main_container:getChildByName("btn_reward")
	self.btn_rank = self.main_container:getChildByName("btn_rank")
	self.time_text   = self.main_container:getChildByName("time_text")
	self.loading_bar = self.main_container:getChildByName("LoadingBar_1")
	self.loading_bar:setPercent(0)
	self.number_const = {}
	self.all_const_num = self.main_container:getChildByName("all_const_num")
	self.btn_rule = self.main_container:getChildByName("btn_rule")

	local buy_panel = self.main_container:getChildByName("buy_panel")

	self.add_btn = buy_panel:getChildByName("add_btn")
	self.item_conut = self.main_container:getChildByName("buy_panel"):getChildByName("label")
	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
    self.item_conut:setString(tostring(count))
    self.item_const_num = count

	for i=1,8 do
		local node_number = self.main_container:getChildByName("node_number")
		self.number_const[i] = node_number:getChildByName("count"..i)
		self.number_const[i]:setString(tostring(i).. TI18N("层"))
	end

    self.btn_cultivate1:getChildByName("Text_4"):setString(TI18N("探索1次"))
    self.btn_cultivate10:getChildByName("Text_4"):setString(TI18N("探索10次"))
    self.btn_free_to_explore:getChildByName("Text_4"):setString(TI18N("免费探索"))
    self:setBtnIsShow(false)

	self:showRoleInfo( )
	self:setLessTime(model:getWeeklyActivityData())
	--controll:updateTipsStatus()
end

function WeeklyUndergroundPanel:setBtnIsShow(is_show)
	self.btn_cultivate1:setVisible(is_show)
	self.btn_cultivate10:setVisible(is_show)
	self.btn_free_to_explore:setVisible(not is_show)
end

function WeeklyUndergroundPanel:setBgImg()
	self.img_index = self.img_index + 1
	if self.img_index > 3 then
		self.img_index = 1
	end
	local res_id = PathTool.getPlistImgForDownLoad("bigbg/welfare", "underground_bg" .. self.img_index)
	loadSpriteTexture(self.undergroundBg,res_id,LOADTEXT_TYPE)
end

function WeeklyUndergroundPanel:showRoleInfo( )

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
    self.map_role:setScale(1.5)
    -- self.map_role:setTimeScale(1.6)
    self.animtionNode:addChild(self.map_role)
    self.map_role:setPosition(0, -100)
end

function WeeklyUndergroundPanel:setCursTratumNum( num )
	self.cur_progress_const = num
	self.progressValue = (self.cur_progress_const  % 9)/9 * 100
	self.all_const_num:setString(tostring(self.cur_progress_const) ..TI18N("层"))
	self.loading_bar:setPercent(self.progressValue)
	local curNum =  self.cur_progress_const  % 9 
	local curNumberMin = self.cur_progress_const - curNum + 1
	local curNumberMax = self.cur_progress_const - curNum + 8
	self:setNodeNum(curNumberMin ,curNumberMax)
end

function WeeklyUndergroundPanel:setNodeNum(index,max_const)
	local number_index = 0
	for i= index , max_const do
		number_index = number_index + 1
		self.number_const[number_index]:setString(tostring(i)..TI18N("层"))
	end
end

function WeeklyUndergroundPanel:setLessTime(data)
	local time = (data.end_time or 0) -GameNet:getInstance():getTime()
	--print("----------服务器时间------------>>",os.date("%Y-%m-%d %H:%M %S", GameNet:getInstance():getTime()))
	--print("----------结束时间-------------->>",os.date("%Y-%m-%d %H:%M %S", data.end_time))
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

function WeeklyUndergroundPanel:playExcessiveAnim( )
	--self.Mask:setPosition(-800, -40)
	self.map_role:stopAllActions()
	self.map_role:setPosition(0, self.map_role:getPositionY())
	self.map_role:setAnimation(0, PlayerAction.stand, true)
	--self.Mask:runAction(cc.MoveTo:create(2, cc.p(-20, -40)))
	--self.Mask:runAction(cc.MoveTo:create(1, cc.p(800, -40)))
	self.map_role:runAction(cc.Sequence:create(
			cc.CallFunc:create(function()
				self.map_role:setAnimation(0, PlayerAction.run, true)
			end),
			cc.MoveTo:create(1.5, cc.p(400, self.map_role:getPositionY())),
			cc.CallFunc:create(function()
				self:setBgImg()
				self.map_role:setPosition(-400, self.map_role:getPositionY())
			end ),
			cc.MoveTo:create(1.5, cc.p(0, self.map_role:getPositionY())),
			cc.CallFunc:create(function()
				self.map_role:setAnimation(0, PlayerAction.stand, true)
			end )
	))
	--self.excessive = createEffectSpine("E23012",cc.p(0,0),cc.p(0.5, 0.5),false,"action1",handler(self , self.excessiveAnimationComplete))
	--self.animtionNode:addChild(self.excessive)
end

function WeeklyUndergroundPanel:excessiveAnimationComplete()
	self:setBgImg()
end

function WeeklyUndergroundPanel:playWetOutAnimation(num)
	--if self.isPlay == true then  return  end
	--self.isPlay = true
	--print("=-=-0--->",self.item_conut_num)
	if self.item_const_num == 0 and self.tier_num > 0 then 
		local config = Config.ItemData.data_get_data(self.item_id)
		BackpackController:getInstance():openTipsSource(true, config)
		return
	end
	local id = BackpackController:getInstance():getModel():getBackPackItemIDByBid(self.item_id)
	controll:send_29211(id,num)
	--if not self.wetOut  then
	--	self.wetOut = createEffectSpine("dc_death",cc.p(0,0),cc.p(0.5, 0.5),false,"action",handler(self , self.wetOutAnimationComplete))
	--	self.animtionNode:addChild(self.wetOut)
	--else
	--	self.wetOut:setAnimation(0, "action", false)
	--end
end

function WeeklyUndergroundPanel:wetOutAnimationComplete()
	self.isPlay = false
end


function WeeklyUndergroundPanel:register_event()
	self.init_underground_data = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.INIT_UNDERGROUND_DATA, function(data)
		self:setCursTratumNum( data.tier_num )
		self:setBtnIsShow(data.tier_num > 0)
		self.tier_num = data.tier_num
	end)

	self.explore_data = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.EXPLORE_DATA, function(data)
		--dump(data, "探索返回-------------->")
		self:setCursTratumNum( data.tier_num )
		self:playExcessiveAnim( )
		self:setBtnIsShow(data.tier_num > 0)
		self.tier_num = data.tier_num
		--local count = BackpackController:getInstance():getModel():getItemNumByBid(self.draw_consume[1])
        --self.icon_num:setString(count or 0)
	end)
	--
	registerButtonEventListener(self.btn_free_to_explore, function()
		self:playWetOutAnimation(1)
    end,true, 1)

	registerButtonEventListener(self.btn_cultivate1, function()
		self:playWetOutAnimation(1)
    end,true, 1)

    registerButtonEventListener(self.btn_cultivate10, function()
		self:playWetOutAnimation(110)
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

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        	local des = controll:getActiviceDes()
	        TipsManager:getInstance():showCommonTips(des, sender:getTouchBeganPosition(),nil,nil,500)
    end ,false)

    if self.add_goods_event == nil then
   		self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
      		local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
      		self.item_conut:setString(tostring(count))
      		self.item_const_num  = count
			--mainui_ctrl:getInstance():setFunctionTipsStatus(MainuiConst.icon.WeekAction, count > 0)
    	end)
    end
    
    if  self.del_goods_event == nil then
    	self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
        	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
        	self.item_conut:setString(tostring(count))
        	self.item_const_num = count
    	end)
    end
    

    if self.modify_goods_event == nil then 
    	self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
    	    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    	    self.item_conut:setString(tostring(count))
    	    self.item_const_num = count
    	end)
    end
end

function WeeklyUndergroundPanel:updateProgressValue(  )
	--self.progressValue = self.progressValue + 11
	--self.cur_progress_const = self.cur_progress_const + 1
	--self.loading_bar:setPercent(self.progressValue)
	--self.all_const_num:setString(tostring(self.cur_progress_const) ..TI18N("层"))
	--if self.progressValue > 100 then
	--	self.progressValue  = 0
	--	self.loading_bar:setPercent(self.progressValue)
	--	--print("self.cur_progress_const-----><", self.cur_progress_const)
	--	self:setNodeNum(self.cur_progress_const + 1,self.cur_progress_const + 8)
	--end
end

function WeeklyUndergroundPanel:setVisibleStatus(bool)
	--bool = bool or false
	--self:setVisible(bool)
end

function WeeklyUndergroundPanel:DeleteMe()
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

	if self.init_underground_data ~= nil then
		GlobalEvent:getInstance():UnBind(self.init_underground_data)
		self.init_underground_data = nil
	end

	if self.explore_data ~= nil then
		GlobalEvent:getInstance():UnBind(self.explore_data)
		self.explore_data = nil
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
end 