--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-02-20 15:59:19
-- @description    : 
		-- 新手训练营选择界面
---------------------------------

local _controller = TrainingcampController:getInstance()
local _model = _controller:getModel()
local table_insert = table.insert
local _table_sort = table.sort

TrainingcampWindow = TrainingcampWindow or BaseClass(BaseView)

function TrainingcampWindow:__init()
	self.win_type = WinType.Full
	self.is_full_screen = false
	self.layout_name = "trainingcamp/trainingcamp_window"
	self.tab_list = {}
    self.cur_index = nil
    self.trainingCampList = {}
	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("trainingcamp","trainingcamp"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_95", true), type = ResourcesType.single },
	}

end

function TrainingcampWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_95",true), LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
	end

    local container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(container, 1)
    self.container = container
    self.titleImage = self.container:getChildByName("title_img")
    self.tips_button = self.container:getChildByName("tips_button")
    self.desc_bg = self.container:getChildByName("desc_bg")
    self.desc_lab = self.desc_bg:getChildByName("desc_lab")
    
	local tab_container = container:getChildByName("tab_container")
    local text_title = {TI18N("初阶训练"),TI18N("进阶训练")}
    for i=1, 2 do
        local tab_btn = tab_container:getChildByName(string.format("tab_btn_%s",i))
        tab_btn.label = tab_btn:getChildByName("title")
        tab_btn.label:setString(text_title[i])
        tab_btn.normal = tab_btn:getChildByName("normal")
        tab_btn.select = tab_btn:getChildByName("select")
        tab_btn.select:setVisible(false)
        tab_btn.label:setTextColor(Config.ColorData.data_new_color4[6])
        tab_btn.index = i
        self.tab_list[i] = tab_btn
    end
	
	local scroll_list = container:getChildByName("scroll_list")
	local scroll_view_size = scroll_list:getContentSize()
    local setting = {
        item_class = TrainingcampItem,      -- 单元类
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 15,                   -- y方向的间隔
        item_width = 650,               -- 单元的尺寸width
        item_height = 180,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(scroll_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    --self:createTitleEffect()
end

function TrainingcampWindow:register_event(  )
	for k, tab_btn in pairs(self.tab_list) do
        registerButtonEventListener(tab_btn, function()
			self:changeTabView(tab_btn.index)
        end ,false, 1)
    end


    registerButtonEventListener(self.tips_button, function(param,sender, event_type)
        if Config.TrainingCampData.data_const and Config.TrainingCampData.data_const.tips_rule then
            local config = Config.TrainingCampData.data_const.tips_rule 
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end,true, 1)
    
    -- 更新界面显示
    self:addGlobalEvent(TrainingcampEvent.Update_Trainingcamp_Data_Event, function (  )
        self:setData()
    end)
end

function TrainingcampWindow:createTitleEffect()
    if MAKELIFEBETTER == true then return end
    if self.title_effect then return end
	self.title_effect = createEffectSpine(PathTool.getEffectRes(646), cc.p(50, -10), cc.p(0.5, 0), true)
    self.titleImage:addChild(self.title_effect)
end 

function TrainingcampWindow:changeTabView(index)
    index = index or 1
    if self.cur_index == index then return end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
        self.cur_tab.normal:setVisible(true)
        self.cur_tab.select:setVisible(false)
    end

    self.cur_index = index
    self.cur_tab = self.tab_list[self.cur_index]

    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        self.cur_tab.normal:setVisible(false)
        self.cur_tab.select:setVisible(true)
    end
    self:setData()
end

function TrainingcampWindow:updateDesc()
    if not self.desc_lab then
        return
    end

    local data_camp_tips = Config.TrainingCampData.data_camp_tips[1]
    if data_camp_tips then
        self.desc_lab:setString(data_camp_tips.desc)
    end

    if self.time_ticket == nil then
        if Config.TrainingCampData.data_const and Config.TrainingCampData.data_const.camp_tips_cd then
            local config = Config.TrainingCampData.data_const.camp_tips_cd 
            self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
                
                local num = math.random(#Config.TrainingCampData.data_camp_tips) or 1
                local cof = Config.TrainingCampData.data_camp_tips[num]
                if cof then
                    self.desc_lab:setString(cof.desc)
                end
            end, config.val)
        end
    end
end 

function TrainingcampWindow:openRootWnd(index)
    if index == nil then
        index = 1
    end
    self:changeTabView(index)
    self:updateDesc()
end

function TrainingcampWindow:setData(  )
    if self.trainingCampList[self.cur_index] == nil then
        local tempArr = {}
        for i,v in ipairs(Config.TrainingCampData.data_info) do
            if v.type == self.cur_index then
                table_insert(tempArr, v)
            end
        end
        
        self.trainingCampList[self.cur_index] = tempArr
    end
    local list = self.trainingCampList[self.cur_index] or {}

    for i,v in ipairs(list) do
        local isFinish = _model:IsFinishById(v.id)
        if isFinish == true then
            v.sort = 1
        else
            v.sort = 0
        end
    end
    _table_sort(list,SortTools.tableLowerSorter({"sort","id"}))
    self.item_scrollview:setData(list)
end

function TrainingcampWindow:close_callback(  )
    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end

	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
    end
    
    if self.title_effect then
        self.title_effect:clearTracks()
        self.title_effect:removeFromParent()
        self.title_effect = nil
    end

	_controller:openTrainingcampWindow(false)
end

---------------------------------
--子项
---------------------------------
TrainingcampItem = class("TrainingcampItem", function()
    return ccui.Widget:create()
end)

function TrainingcampItem:ctor()
	self:configUI()
	self:register_event()
end

function TrainingcampItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("trainingcamp/trainingcamp_item"))
    self:setContentSize(cc.size(650, 180))
    self:addChild(self.root_wnd)
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
    self.desc_lab = self.main_container:getChildByName("desc_lab")
    self.title_lab = self.main_container:getChildByName("title_lab")
    self.go_btn = self.main_container:getChildByName("go_btn")
    self.go_btn:setTitleText(TI18N("进入训练"))
    self.go_btn.label = self.go_btn:getTitleRenderer()
    if self.go_btn.label ~= nil then
        --self.go_btn.label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
        self.go_btn.label:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)
    end
	self.status_img = self.main_container:getChildByName("status_img")
    self.status_img:setVisible(false)
    self.status_img:getChildByName("tips_1"):setString(TI18N("已完成"))
	
    self.award_list = self.main_container:getChildByName("award_list")
    local scroll_view_size = self.award_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
        scale = 0.7
    }
    self.award_scrollview = CommonScrollViewLayout.new(self.award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)

    self.tips_lab = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(1, 0.5), cc.p(615,40),nil,nil,400)
    self.main_container:addChild(self.tips_lab)
end

function TrainingcampItem:register_event()
	registerButtonEventListener(self.go_btn, function (  )
		if self.data then
            for i,v in ipairs(self.data.unlock) do
                if _model:IsFinishById(v) == false then --- 是否通关
                    local conf = Config.TrainingCampData.data_info[v]
                    if conf then
                        local str = string.format(TI18N("通关【%s】解锁"),conf.name)  
                        message(str)  
                    end
                    return
                end
            end
            _controller:openTrainingcampMainWindow(true,self.data)
        end
	end, true, 1)
end

function TrainingcampItem:setData(data)
	if not data then return end
	self.data = data
	self.title_lab:setString(data.name)
    self.desc_lab:setString(data.desc)

    --引导需要
    if data.id and self.go_btn then
        self.go_btn:setName("training_btn_" .. data.id)
    end

    local isFinish = _model:IsFinishById(data.id)
    self.status_img:setVisible(isFinish) -- 是否通关

	-- 奖励数据
	local item_list = {}
	for k,v in pairs(data.reward) do
        local vo = {}
        vo.id = v[1]
        vo.quantity = v[2]
        vo.dataId = data.id
        table_insert(item_list, vo)
    end
    self.award_scrollview:setData(item_list)
    self.award_scrollview:addEndCallBack(function (  )
        local list = self.award_scrollview:getItemList()
        for k,v in pairs(list) do
            local info = v:getData()
            if info then
                local isFinish = TrainingcampController:getInstance():getModel():IsFinishById(info.dataId) or false
                v:IsGetStatus(isFinish)
            end
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)

    local str = ""
    local is_red = true
    local is_open = true
    if isFinish == false then
        for i,v in ipairs(self.data.unlock) do
            if _model:IsFinishById(v) == false then --- 是否通关
                is_red = false
                is_open = false
                local conf = Config.TrainingCampData.data_info[v]
                if conf then
                    str = string.format(TI18N("通关<div fontcolor=#d63636>【%s】</div>解锁"),conf.name)
                end
                break
            end
        end
    else
        is_red = false
    end

    addRedPointToNodeByStatus(self.go_btn, is_red,5,5)   

    self.go_btn:setVisible(is_open)

    
    if data.type == 2 and is_open == false then
        str = TI18N("通关<div fontcolor=#d63636>【全部初阶关卡】</div>解锁")
    end
    
    self.tips_lab:setString(str)
end

function TrainingcampItem:DeleteMe()
    if self.award_scrollview then
		self.award_scrollview:DeleteMe()
		self.award_scrollview = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end
