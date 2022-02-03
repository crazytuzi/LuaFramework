--*********
--元宵厨房的收集
--*********
AnimateYuanzhenCollectWindow = AnimateYuanzhenCollectWindow or BaseClass(BaseView)

local controller = AnimateActionController:getInstance()
local collect_list = Config.HolidayMakeData.data_collect_list
local master_list = Config.HolidayMakeData.data_master_diff_list
function AnimateYuanzhenCollectWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "animateaction/animate_yuanzhen_collect_window"
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_26"), type = ResourcesType.single},
	}
end

function AnimateYuanzhenCollectWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    main_container:getChildByName("Text_2"):setString(TI18N("收集食材"))
    main_container:getChildByName("text"):setString(TI18N("推荐战力: "))
    main_container:getChildByName("text_0"):setString(TI18N("今日可挑战次数: "))

    self.master_trait_text = main_container:getChildByName("master_trait_text")
    self.recommend_power = main_container:getChildByName("recommend_power")
    self.btn_add = main_container:getChildByName("btn_add")
    self.btn_challenge = main_container:getChildByName("btn_challenge")
    self.btn_challenge:getChildByName("Text_6"):setString(TI18N("挑战"))
    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80                     -- 缩放
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.titile_image = main_container:getChildByName("titile_image")
    local res = PathTool.getTargetRes("bigbg","bigbg_26",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.titile_image) then
                loadSpriteTexture(self.titile_image, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
    self.challge_num = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5), cc.p(288,346), nil, nil, 100)
	main_container:addChild(self.challge_num)

	self.main_container = main_container
    self.btn_close = main_container:getChildByName("btn_close")
 end

function AnimateYuanzhenCollectWindow:openRootWnd()
	local holiday_id = controller:getModel():getHolidayID()
	self.master_trait_text:setString(collect_list[holiday_id].desc)
	local role_vo = RoleController:getInstance():getRoleVo()
	local count = 1
	for i,v in pairs(master_list[holiday_id]) do
		if role_vo.max_power >= v.min and role_vo.max_power <= v.max then
			count = v.id
			break
		end
	end
	self.recommend_power:setString(master_list[holiday_id][count].recommend)
	self.main_container:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
            if self and self.updateModel then
                self:updateModel(master_list[holiday_id][count].unit_id)
            end
    end)))

	local str = string.format(TI18N("<div fontcolor=#157e22 >%d</div> 次"),controller:getModel():getRemainChallageNum())
	self.challge_num:setString(str)
	
	if self.item_scrollview then
		local list = {}
	    for k, v in pairs(collect_list[holiday_id].award) do
	        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
	        if vo then
	            vo.quantity = v[2]
	            table.insert(list, vo)
	        end
	    end
		self.item_scrollview:setData(list)
		self.item_scrollview:addEndCallBack(function()
	        local list = self.item_scrollview:getItemList()
	        for k,v in pairs(list) do
	            v:setDefaultTip()
	        end
	    end)
	end
end
function AnimateYuanzhenCollectWindow:updateModel(unit_id)
	if not unit_id then return end
    if not self.partner_model then 
        self.partner_model = BaseRole.new(BaseRole.type.unit, unit_id)
        self.partner_model:setAnimation(0,PlayerAction.show,true) 
        self.main_container:addChild(self.partner_model)
        self.partner_model:setPosition(cc.p(355,670))
    end
end
function AnimateYuanzhenCollectWindow:register_event()
	self:addGlobalEvent(AnimateActionEvent.YuanZhenFestval_Buy_Challage, function(data)
		if not data or next(data) == nil then return end
		local str = string.format(TI18N("<div fontcolor=#157e22 >%d</div> 次"),data.combat_num)
		if self.challge_num then
			self.challge_num:setString(str)
		end
	end)
	self:addGlobalEvent(AnimateActionEvent.YuanZhenFestval_Kitchen, function(data)
		if not data or next(data) == nil then return end
		local str = string.format(TI18N("<div fontcolor=#157e22 >%d</div> 次"),data.combat_num)
		if self.challge_num then
			self.challge_num:setString(str)
		end
	end)

	registerButtonEventListener(self.btn_close, function()
    	controller:openAnimateYuanzhenCollectWindow(false)
    end ,true, 1)
    registerButtonEventListener(self.btn_add, function()
    	local holiday_id = controller:getModel():getHolidayID()
    	local function fun() 
            controller:sender24809()
        end
    	local item_config = Config.ItemData.data_get_data(collect_list[holiday_id].buy_loss[1][1])
        if item_config then 
            local res = PathTool.getItemRes(item_config.icon)
            local str = string.format(TI18N("是否花费 <img src='%s' scale=0.4 />%s购买挑战次数"),res,collect_list[holiday_id].buy_loss[1][2])
            CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
        end
    end ,true, 1)
    registerButtonEventListener(self.btn_challenge, function()
    	controller:sender24808()
    end ,true, 1)
end
function AnimateYuanzhenCollectWindow:close_callback()
	if self.partner_model then 
        self.partner_model:runAction(cc.Sequence:create( cc.CallFunc:create(function()
		    doStopAllActions(self.partner_model)
            self.partner_model:removeFromParent()
            self.partner_model = nil
    	end)))
    end
	doStopAllActions(self.main_container)
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openAnimateYuanzhenCollectWindow(false)
end