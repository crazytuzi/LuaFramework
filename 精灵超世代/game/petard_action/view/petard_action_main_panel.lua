--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-19 16:44:03
-- @description    : 
		-- 花火大会(活动)主界面
---------------------------------

local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

PetardActionMainPanel = class("PetardActionMainPanel", function()
    return ccui.Widget:create()
end)

function PetardActionMainPanel:ctor(bid)
    self.holiday_bid = bid or ActionRankCommonType.petard
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionpetard", "actionpetard"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_petard", true), type = ResourcesType.single},
	}

    self._init_flag = false
    self.lantern_list = {} -- 灯笼

	self.resources_load = ResourcesLoad.New(true)
	self.resources_load:addAllList(self.res_list, function()
		self:loadResListCompleted()
	end)
end

function PetardActionMainPanel:loadResListCompleted(  )
	self:configUI()
	self:registerEvent()
    _controller:sender27000() -- 请求基础数据
	self._init_flag = true
    self:updateItemNum()
end

function PetardActionMainPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("petard/petard_action_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    local image_bg = main_container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_petard", true), LOADTEXT_TYPE)

    self.item_object_list = {}
    for i=1,2 do
    	local item_num_bg = main_container:getChildByName("item_num_bg_" .. i)
    	if item_num_bg then
    		local object = {}
    		object.item_num_txt = item_num_bg:getChildByName("item_num_txt")
    		object.add_item_btn = item_num_bg:getChildByName("add_item_btn")
    		local item_icon = item_num_bg:getChildByName("item_icon")
    		local item_bid
    		if i == 1 and Config.HolidayPetardData.data_const["meteor_bid"] then
    			item_bid = Config.HolidayPetardData.data_const["meteor_bid"].val
    		elseif Config.HolidayPetardData.data_const["firework_bid"] then
    			item_bid = Config.HolidayPetardData.data_const["firework_bid"].val
    		end
    		local item_cfg = Config.ItemData.data_get_data(item_bid)
    		if item_cfg then
    			object.item_bid = item_bid
    			local item_res = PathTool.getItemRes(item_cfg.icon)
    			loadSpriteTexture(item_icon, item_res, LOADTEXT_TYPE)
    		end
    		_table_insert(self.item_object_list, object)
    	end
    end

    self.shop_btn = main_container:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("兑换商店"))
    self.put_btn = main_container:getChildByName("put_btn")
    self.put_btn:getChildByName("label"):setString(TI18N("燃放烟花"))
    self.btn_rule = main_container:getChildByName("btn_rule")

    self.time_txt = main_container:getChildByName("time_txt")
    self.petard_hot_txt = main_container:getChildByName("petard_hot_txt")
    self.progress = main_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)

    self.lantern_panel = main_container:getChildByName("lantern_panel")
    self.hot_val_image = main_container:getChildByName("hot_val_image")
    self.hot_val_txt = self.hot_val_image:getChildByName("label")

    main_container:getChildByName("action_tips"):setString(TI18N("秋日祭，放烟花，花火兑好礼"))
    main_container:getChildByName("item_num_title"):setString(TI18N("当前拥有:"))

    local time_cfg = Config.HolidayPetardData.data_const["holiday_time"]
    if time_cfg then
        self.time_txt:setString(TI18N("活动时间：") .. time_cfg.desc)
    end
end

function PetardActionMainPanel:registerEvent(  )
	for i,object in ipairs(self.item_object_list) do
		if object.add_item_btn then
			registerButtonEventListener(object.add_item_btn, function ()
				self:onClickAddItemBtn(i)
			end, true)
		end
	end

	registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true)

	registerButtonEventListener(self.put_btn, handler(self, self.onClickPutBtn), true)

	registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)

    -- 花火大会数据
    if not self.get_petard_data_event then
        self.get_petard_data_event = GlobalEvent:getInstance():Bind(PetardActionEvent.Get_Base_Info_Event, function ()
            self:setData()
        end)
    end

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateItemNum(data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateItemNum(data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:updateItemNum(data_list)
        end)
    end
end

function PetardActionMainPanel:onClickAddItemBtn( index )
    -- 跳转到 93031 活动界面
    local action_ctrl = ActionController:getInstance()
	local tab_vo = action_ctrl:getActionSubTabVo(ActionRankCommonType.exercise_1)
    if tab_vo and action_ctrl.action_operate and action_ctrl.action_operate.tab_list[tab_vo.bid] then
        action_ctrl.action_operate:handleSelectedTab(action_ctrl.action_operate.tab_list[tab_vo.bid])
    else
        message(TI18N("该活动已结束"))
    end
end

function PetardActionMainPanel:onClickShopBtn(  )
	MallController:getInstance():openMallActionWindow(true, self.holiday_bid)
end

function PetardActionMainPanel:onClickPutBtn(  )
	_controller:openSelectItemWindow(true)
end

function PetardActionMainPanel:onClickRuleBtn( param, sender, event_type )
	local rule_cfg = Config.HolidayPetardData.data_const["holiday_rule"]
    if rule_cfg then
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    end
end

function PetardActionMainPanel:setVisibleStatus( bool )
	bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
        _controller:sender27000() -- 请求基础数据
    end
end

function PetardActionMainPanel:setData( )
    local petard_data = _model:getPetardBaseInfo()

    if not petard_data or next(petard_data) == nil then return end
	
    -- 全服烟花热度
    local cur_hot_val = petard_data.score or 0
    local max_hot_val = _model:getMaxPetardHotVal()
    self.petard_hot_txt:setString(_string_format(TI18N("全服烟花热度：%d/%d"), cur_hot_val, max_hot_val))

    local function getLanternStateById( id )
        local state = PetardActionConst.Lantern_State.Lock
        for k,v in pairs(petard_data.score_award or {}) do
            if v.id == id then
                if v.status == 1 then -- 可领取
                    state = PetardActionConst.Lantern_State.CanGet
                elseif v.status == 2 then -- 已领取
                    state = PetardActionConst.Lantern_State.Got
                end
                break
            end
        end
        return state
    end

    -- 灯笼
    local start_x = 60
    local space_x = (720 - start_x*2)/(Config.HolidayPetardData.data_award_length - 1)
    local target_pos_x = start_x
    local target_val = 0
    local set_val_flag = false
    for i,cfg in ipairs(Config.HolidayPetardData.data_award) do
        local lantern_item = self.lantern_list[i]
        if not lantern_item then
            lantern_item = PetardLanternItem.new()
            self.lantern_panel:addChild(lantern_item)
            self.lantern_list[i] = lantern_item
        end
        local l_data = {}
        l_data.cfg = cfg
        l_data.state = getLanternStateById(cfg.id)
        lantern_item:setData(l_data)
        local pos_x = start_x + (i-1)*space_x
        lantern_item:setPosition(cc.p(pos_x, 174))

        if not set_val_flag then
            target_pos_x = pos_x
            target_val = cfg.count/1000*max_hot_val
            if l_data.state == PetardActionConst.Lantern_State.Lock then
                set_val_flag = true
            end
        end
    end
    -- 目标值
    self.hot_val_image:setPositionX(target_pos_x)
    self.hot_val_txt:setString(target_val)

    -- 计算进度
    if cur_hot_val >= max_hot_val then
        self.progress:setPercent(100)
    else
        local last_times = 0
        local progress_width = 720
        local first_off = 60 -- 0到第一个的距离
        local distance = 0
        for i,cfg in ipairs(Config.HolidayPetardData.data_award) do
            -- 计算进度
            local cur_target_val = cfg.count/1000*max_hot_val
            if i == 1 then
                if cur_hot_val <= cur_target_val then
                    distance = (cur_hot_val/cur_target_val)*first_off
                    break
                else
                    distance = first_off
                end
            else
                if cur_hot_val <= cur_target_val then
                    distance = distance + ((cur_hot_val-last_times)/(cur_target_val-last_times))*space_x
                    break
                else
                    distance = distance + space_x
                end
            end
            last_times = cur_target_val
        end
        self.progress:setPercent(distance/progress_width*100)
    end
end

function PetardActionMainPanel:updateItemNum( data_list )
    if data_list then
        for k,v in pairs(data_list) do
            for _,object in pairs(self.item_object_list) do
                if v.base_id and object.item_bid and v.base_id == object.item_bid and object.item_num_txt then
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(object.item_bid)
                    object.item_num_txt:setString(have_num)
                    break
                end
            end
        end
    else
        for k,object in pairs(self.item_object_list) do
            if object.item_bid and object.item_num_txt then
                local have_num = BackpackController:getInstance():getModel():getItemNumByBid(object.item_bid)
                object.item_num_txt:setString(have_num)
            end
        end
    end
end

function PetardActionMainPanel:DeleteMe(  )
    doStopAllActions(self.main_container)
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
    for k,item in pairs(self.lantern_list) do
        item:DeleteMe()
        item = nil
    end
    if self.get_petard_data_event then
        GlobalEvent:getInstance():UnBind(self.get_petard_data_event)
        self.get_petard_data_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
end

------------------------@ item
PetardLanternItem = class("PetardLanternItem", function()
    return ccui.Widget:create()
end)

function PetardLanternItem:ctor()
    self:configUI()
    self:register_event()
end

function PetardLanternItem:configUI(  )
    self.size = cc.size(105, 167)
    self:setTouchEnabled(false)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5, 1))

    local csbPath = PathTool.getTargetCSB("petard/petard_lantern_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    self.lantern_image = main_container:getChildByName("lantern_image")
    self.node_sp = main_container:getChildByName("node_sp")
    self.got_sp = main_container:getChildByName("got_sp")
end

function PetardLanternItem:register_event(  )
    registerButtonEventListener(self.main_container, handler(self, self.onClickItem), true)
end

function PetardLanternItem:onClickItem(  )
    if not self.data then return end

    if self.data.state == PetardActionConst.Lantern_State.CanGet then
        _controller:sender27007(self.data.cfg.id)
    else
        _controller:openPetardAwardWindow(true)
    end
end

function PetardLanternItem:setData( data )
    if not data then return end

    self.data = data

    self.main_container:setRotation(0)
    self.lantern_image:setOpacity(255)
    self.got_sp:setVisible(false)
    self:handleLanternEffect(self.data.state == PetardActionConst.Lantern_State.CanGet)
    self.lantern_image:setVisible(self.data.state ~= PetardActionConst.Lantern_State.CanGet)

    if self.data.state == PetardActionConst.Lantern_State.Lock then -- 未开启
        self.lantern_image:loadTexture(PathTool.getResFrame("actionpetard", "actionpetard_1001"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.node_sp, PathTool.getResFrame("actionpetard", "actionpetard_1003"), LOADTEXT_TYPE_PLIST)
    elseif self.data.state == PetardActionConst.Lantern_State.CanGet then -- 可领取
        --[[local sequence = cc.Sequence:create(cc.RotateBy:create(0.5, -10), cc.RotateBy:create(1, 20), cc.RotateBy:create(0.5, -10))
        self.main_container:runAction(cc.RepeatForever:create(sequence))--]]
    else -- 已领取
        self.lantern_image:loadTexture(PathTool.getResFrame("actionpetard", "actionpetard_1000"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.node_sp, PathTool.getResFrame("actionpetard", "actionpetard_1002"), LOADTEXT_TYPE_PLIST)
        self.lantern_image:setOpacity(153)
        self.got_sp:setVisible(true)
    end
end

function PetardLanternItem:handleLanternEffect( status )
    if status == false then
        if self.lantern_effect then
            self.lantern_effect:clearTracks()
            self.lantern_effect:removeFromParent()
            self.lantern_effect = nil
        end
    else
        if not tolua.isnull(self.main_container) and self.lantern_effect == nil then
            self.lantern_effect = createEffectSpine(Config.EffectData.data_effect_info[333], cc.p(self.size.width*0.5, self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.main_container:addChild(self.lantern_effect)
        end
    end
end

function PetardLanternItem:DeleteMe(  )
    self:handleLanternEffect(false)
    self:removeAllChildren()
    self:removeFromParent()
end