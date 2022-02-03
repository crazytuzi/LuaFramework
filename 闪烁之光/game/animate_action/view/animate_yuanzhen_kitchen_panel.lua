--*******************
--元宵厨房
--*******************
AnimateYuanzhenKitchenPanel = class("AnimateYuanzhenKitchenPanel", function()
    return ccui.Widget:create()
end)

local controller = AnimateActionController:getInstance()
local rewart_list = Config.HolidayMakeData.data_make_lev_list
function AnimateYuanzhenKitchenPanel:ctor(bid)
	self.net_load = false
	self.holiday_id = nil
	self.holiday_reward_bid = nil
	self:loadResources()
end
function AnimateYuanzhenKitchenPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("animateaction","animateaction_yaunzhen"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
		if self.loadResListCompleted then
			self:loadResListCompleted()
		end
	end)
end
function AnimateYuanzhenKitchenPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end
function AnimateYuanzhenKitchenPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("animateaction/animate_yuanzhen_kiechen_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.title_img = main_container:getChildByName("title_img")
 
    local res = PathTool.getTargetRes("bigbg/animateaction","txt_cn_animateaction_2",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.btn_collect = main_container:getChildByName("btn_collect")
    self.btn_collect:getChildByName("Text_5"):setString(TI18N("收集食材"))
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_5_0"):setString(TI18N("前往厨房"))
    self.btn_reward = main_container:getChildByName("btn_reward")
    
    self.time_text = main_container:getChildByName("time_text")
    self.time_text:setString("")
    self.kitchen_tesk_list = {}
    for i=1,4 do
    	self.kitchen_tesk_list[i] = main_container:getChildByName("task_text_"..i)
    end

    local title_text = createRichLabel(26, cc.c4b(0xff,0xec,0xc2,0xff), cc.p(0.5,0.5), cc.p(main_container:getContentSize().width/2-78,606), nil, nil, 500)
	main_container:addChild(title_text)
	local role_vo = RoleController:getInstance():getRoleVo()
	local str = string.format(TI18N("欢迎来到 <div fontcolor=#64e678 >%s</div> 的厨房"),role_vo.name)
	title_text:setString(str)
end

function AnimateYuanzhenKitchenPanel:register_event()
	if not self.festval_kitchen_event then
		self.festval_kitchen_event = GlobalEvent:getInstance():Bind(AnimateActionEvent.YuanZhenFestval_Kitchen,function(data)
			if not data or next(data) == nil then return end
			local str = string.format(TI18N("解锁菜单: %d"),data.show_list[2].num)
			self.kitchen_tesk_list[1]:setString(str)
			str = string.format(TI18N("制作元宵: %d"),data.show_list[1].num)
			self.kitchen_tesk_list[2]:setString(str)
			str = string.format(TI18N("击败怪物: %d"),data.show_list[3].num)
			self.kitchen_tesk_list[3]:setString(str)
			str = string.format(TI18N("第%d级"),data.lev)
			self.kitchen_tesk_list[4]:setString(str)

			str = string.format(TI18N("活动时间: %s- %s"),TimeTool.getMD2(data.start_time),TimeTool.getMD2(data.end_time))
			self.time_text:setString(str)

			self.make_lev = data.lev
			self.cur_exp = data.exp
			self.holiday_id = data.camp_id
			self.holiday_reward_bid = data.group_id
			self.net_load = true
		end)
	end

	if not self.kitchen_get_lev_event then
		self.kitchen_get_lev_event = GlobalEvent:getInstance():Bind(AnimateActionEvent.YuanZhenFestval_Kitchen_Lev,function(data)
			if self.holiday_id then
				local red_status = false
				for i,v in pairs(rewart_list[self.holiday_id]) do
					if controller:getModel():getKitchenLevData(v.lev) == false and v.lev <= self.make_lev then
						red_status = true
						break
					end
				end
				addRedPointToNodeByStatus(self.btn_reward, red_status)
			end
		end)
	end
    registerButtonEventListener(self.btn_collect, function()
    	if self.net_load == true then
	    	MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.YuanZhenFight)
	    else
	    	message(TI18N("网络加载中......"))
	    end
    end ,true, 1)
    registerButtonEventListener(self.btn_goto, function()
    	if self.net_load == true then
	    	controller:openAnimateYuanzhenGotoKitchenWindow(true,self.holiday_id,self.make_lev,self.holiday_reward_bid,self.cur_exp)
	    else
	    	message(TI18N("网络加载中......"))
	    end
    end ,true, 1)
    registerButtonEventListener(self.btn_reward, function()
    	if self.net_load == true then
	    	controller:openAnimateYuanzhenKitchenLevWindow(true,self.holiday_id)
	    else
	    	message(TI18N("网络加载中......"))
	    end
    end ,true, 1)
end

function AnimateYuanzhenKitchenPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
    	controller:sender24804()
    	controller:sender24805()
    end
end

function AnimateYuanzhenKitchenPanel:DeleteMe()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.festval_kitchen_event then
        GlobalEvent:getInstance():UnBind(self.festval_kitchen_event)
        self.festval_kitchen_event = nil
    end
    if self.kitchen_get_lev_event then
        GlobalEvent:getInstance():UnBind(self.kitchen_get_lev_event)
        self.kitchen_get_lev_event = nil
    end
end
