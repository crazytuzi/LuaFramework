--**************
--元宵活动抽奖
--**************
AnimateActionFestvalWindow = AnimateActionFestvalWindow or BaseClass(BaseView)

local controller = AnimateActionController:getInstance()
local action_controller = ActionController:getInstance()
local lottery_rand_list = Config.HolidayLantermFestivalData.data_rand_list
local constant = Config.HolidayLantermFestivalData.data_constant
local consume_list = Config.HolidayLantermFestivalData.data_consume_list
local data_consume = Config.HolidayLantermFestivalData.data_consume_num
function AnimateActionFestvalWindow:__init(index,is_open)
	self.index = index or 1
	self.is_open = is_open or 0
	self.role_festval = RoleController:getInstance():getRoleVo()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big
    self.item_list = {}
    self.layout_name = "animateaction/animate_festval_lottery_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("animateaction","animateaction_yaunzhen"), type = ResourcesType.plist }
    }
end

function AnimateActionFestvalWindow:open_callback()
	local light_name = {TI18N("纳福灯"),TI18N("祈愿灯"),TI18N("丰登灯"),TI18N("小花灯")}
	self.background = self.root_wnd:getChildByName("backgroud")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    local title_name = main_container:getChildByName("title_name")
    local name = light_name[self.index] or ""
    title_name:setString(name)

    self.btn_add = main_container:getChildByName("btn_add")
    self.light_festval_num = main_container:getChildByName("light_num")
    local count = self.role_festval:getActionAssetsNumByBid(constant.awards_expend_items.val)
    self.light_festval_num:setString(count)

    self.btn_lighting = main_container:getChildByName("btn_lighting")
    self.lighting_spr = main_container:getChildByName("Sprite_3")
	self.lighting_bg = main_container:getChildByName("Panel_1")

	self.not_open_text = createRichLabel(26, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(main_container:getContentSize().width/2,56), nil, nil, 500)
	main_container:addChild(self.not_open_text)
	
    self.consume_text = createRichLabel(26, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(self.btn_lighting:getContentSize().width/2,self.btn_lighting:getContentSize().height/2), nil, nil, 150)
	self.btn_lighting:addChild(self.consume_text)
	
    self.good_cons = main_container:getChildByName("good_cons")
    self.good_cons:setScrollBarEnabled(false)
    self.main_container = main_container
    self.btn_close = main_container:getChildByName("btn_close")
end

function AnimateActionFestvalWindow:setNotOpenConsume(visible)
	self.btn_lighting:setVisible(visible)
	self.lighting_spr:setVisible(visible)
	self.lighting_bg:setVisible(visible)
	self.light_festval_num:setVisible(visible)
	self.btn_add:setVisible(visible)
end
--小花灯消耗
function AnimateActionFestvalWindow:setLightComsumeTotle(data)
	if not data or next(data) == nil then return end
	table.sort(data.rand_list, function(a,b) 
		if a.rand_id and b.rand_id then
			return a.rand_id < b.rand_id 
		end
	end)

	local item_config = Config.ItemData.data_get_data(constant.awards_expend_items.val)
	local res = PathTool.getItemRes(item_config.icon)
	--小花灯消耗
	if self.index == 4 then
		local str = string.format(TI18N("<img src='%s' scale=0.45 /> <div outline=2,#2b610d>%d  点灯</div>"),res,constant.awards_4_expend.val[2] or 0)
		self.consume_text:setString(str)
	else

		local count = data.count or 0
		count = count + 1
		local totle = #consume_list[self.index] or 1
		if count >= totle then
			count = totle
		end
		local str = string.format(TI18N("<img src='%s' scale=0.45 /> <div outline=2,#2b610d>%d  点灯</div>"),res,consume_list[self.index][count].expend or 0)
		self.consume_text:setString(str)
	end

	local status = false
	if data and data.rand_list then
		for i,v in pairs(data.rand_list) do
			if v.status == 0 then
				status = true
				break
			end
		end
	end
	if self.is_open == 1 then
		if status == false then
			self:setNotOpenConsume(false)
			if not self.light_finish then
				self.light_finish = createSprite(PathTool.getResFrame("animateaction_yaunzhen","txt_cn_animateaction_yaunzhen"),self.main_container:getContentSize().width/2, 61, self.main_container, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST)
			end
			if self.light_finish then
				self.light_finish:setVisible(true)
			end
			self.not_open_text:setVisible(false)
		end
	else
		self:setNotOpenConsume(false)
		local item_config = Config.ItemData.data_get_data(constant.awards_expend_items.val)
    	local res = PathTool.getItemRes(item_config.icon)
		local str = string.format(TI18N("累计消耗<img src='%s' scale=0.45 />%d个开启</div>"),res,data_consume[self.index].need_num or 0)
		self.not_open_text:setString(str)
		self.not_open_text:setVisible(true)
		if self.light_finish then
			self.light_finish:setVisible(false)
		end
	end
	
	local list_num = #data.rand_list or 1
    self.good_cons:setInnerContainerSize(cc.size(511,119*(math.floor(list_num/4)) + 30))
    local pos_y = self.good_cons:getInnerContainerSize().height - 60
    for i=1, list_num do
    	delayRun(self.good_cons, i*2/60, function()
	        if not self.item_list[i] then
	            self.item_list[i] = BackPackItem.new(true,true,nil)
	            self.item_list[i]:setAnchorPoint(0, 0.5)
	            self.good_cons:addChild(self.item_list[i])
	        end
	        if self.item_list[i] then
	            local tvl = (i-1)%4
	            local width = BackPackItem.Width * tvl
	            local height = BackPackItem.Height * math.floor((i-1)/4) + (18*math.floor((i-1)/4))
	            self.item_list[i]:setPosition(cc.p(width+tvl*26,pos_y - height))
	            self.item_list[i]:setDefaultTip()
	            local item_id = lottery_rand_list[self.index][data.rand_list[i].rand_id].item_id
	            local item_num = lottery_rand_list[self.index][data.rand_list[i].rand_id].item_num
	            local effect = lottery_rand_list[self.index][data.rand_list[i].rand_id].effect
	            if item_id and item_num then
		            self.item_list[i]:setBaseData(item_id,item_num)
		        end
	            if effect == 1 then
	            	self.item_list[i]:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
	            else
	            	self.item_list[i]:showItemEffect(false)
	            end
	            if data.rand_list[i] and data.rand_list[i].status == 0 then
	            	setChildUnEnabled(false,self.item_list[i])
	            else
	            	setChildUnEnabled(true,self.item_list[i])
	            end
	        end
	    end)
    end
end

function AnimateActionFestvalWindow:openRootWnd()
	controller:sender24802(self.index)
end

function AnimateActionFestvalWindow:register_event()
	if not self.role_lottery_event and self.role_festval then
        self.role_lottery_event = self.role_festval:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and id == constant.awards_expend_items.val and self.role_festval then 
                local count = self.role_festval:getActionAssetsNumByBid(constant.awards_expend_items.val) or 0
                if tolua.isnull(self.light_festval_num) == false then
	                self.light_festval_num:setString(count)
	            end
            end
        end)
    end

	self:addGlobalEvent(AnimateActionEvent.YuanZhenFestval_Lottery, function(data)
		if not data or next(data) == nil then return end
		self:setLightComsumeTotle(data)
	end)

    registerButtonEventListener(self.btn_close, function()
    	controller:sender24801()
        controller:openAnimateFestvalWindow(false)
    end ,true, 2)
    registerButtonEventListener(self.btn_lighting, function()
        controller:sender24803(self.index)
    end ,true, 1)
    registerButtonEventListener(self.btn_add, function()
        --跳转到元宵大冒险的
        controller:openAnimateFestvalWindow(false)
    	local id = ActionRankCommonType.yuanzhen_adventure
        local tab_vo = action_controller:getActionSubTabVo(id)
        if tab_vo then
            if action_controller.action_operate and action_controller.action_operate.tab_list[id] then
                action_controller.action_operate:handleSelectedTab(action_controller.action_operate.tab_list[id])
            end
        end
    end ,true, 1)
end

function AnimateActionFestvalWindow:close_callback()
	doStopAllActions(self.good_cons)
	if self.item_list then
	    for k, item in pairs(self.item_list) do
	        item:DeleteMe()
	    end
	    self.item_list = nil
	end
    if self.role_lottery_event then
        self.role_festval:UnBind(self.role_lottery_event)
        self.role_lottery_event = nil
    end
	controller:openAnimateFestvalWindow(false)
end