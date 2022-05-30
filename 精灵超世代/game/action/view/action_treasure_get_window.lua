--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-31 02:40:55
-- @description    : 
		-- 探宝获得物品
---------------------------------
ActionTreasureGetWindow = ActionTreasureGetWindow or BaseClass(BaseView)
local treasure_const = Config.DialData.data_const
local controller = ActionController:getInstance()
function ActionTreasureGetWindow:__init(data,index,count_type,func)
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.is_full_screen = false
    self.layout_name = "augury/augury_get_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("augury","augury"), type = ResourcesType.plist },
    }
    self.effect_cache_list = {}
    self.index = index or 1 -- 抽奖次数
    self.touchTreasure_type = count_type or 2 -- 抽奖类型(3为转盘活动)
    self.func = func
    self.data = data or {}
    self.cache_list = {}

    self.can_click = false
end

function ActionTreasureGetWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setBackGroundColorOpacity(180)
        self.background:setScale(display.getMaxScale())
    end
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.size = self.main_panel:getContentSize()
    self.title_model = self.root_wnd:getChildByName("titlepanel")

    self.bg_top = self.main_panel:getChildByName("bg_top")
    if self.bg_top_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.bg_top_load = loadImageTextureFromCDN(self.bg_top, res, ResourcesType.single, self.bg_top_load)
    end

    self.bg_bottom = self.main_panel:getChildByName("bg_bottom")
    if self.bg_bottom_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.bg_bottom_load = loadImageTextureFromCDN(self.bg_bottom, res, ResourcesType.single, self.bg_bottom_load)
    end

    self.close_sp = self.main_panel:getChildByName("close_sp")
    
    if self.touchTreasure_type == 1 or self.touchTreasure_type == 2 then
        self.btn_left = createImage(self.main_panel, PathTool.getResFrame("common", "common_1017"), 182, -51, cc.p(0.5,0.5), true, 0, true)
        self.btn_left:setContentSize(cc.size(168,66))
        -- local text_left = createLabel(24,Config.ColorData.data_color4[1], Config.ColorData.data_color4[277],64,32,TI18N("确定"),self.btn_left,2, cc.p(0.5,0.5))
        local btn_left_size = self.btn_left:getContentSize()
        self.text_left = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_left_size.width/2, btn_left_size.height/2))
        self.text_left:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>确定</div>"), Config.ColorData.data_new_color_str[3]))
        self.btn_left:addChild(self.text_left)
        self.btn_left:setTouchEnabled(true)
        registerButtonEventListener(self.btn_left, function()
            controller:openTreasureGetItemWindow(false)
        end ,true, 2)

        local str = string.format(TI18N("再来%d次"),treasure_const.treasure_num.val[self.index][self.touchTreasure_type])
        self.btn_right = createImage(self.main_panel, PathTool.getResFrame("common", "common_1017"), 559, -51, cc.p(0.5,0.5), true, 0, true)
        -- local text_right = createLabel(24,Config.ColorData.data_color4[1],Config.ColorData.data_color4[277],64,32,"",self.btn_right,2, cc.p(0.5,0.5))
        local btn_right_size = self.btn_right:getContentSize()
        self.text_right = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_right_size.width/2, btn_right_size.height/2))
        self.text_right:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>%s</div>"), Config.ColorData.data_new_color_str[3], str))
        self.btn_right:addChild(self.text_right)
        self.btn_right:setContentSize(cc.size(168,66))
        -- text_right:setString(str)
        self.btn_right:setTouchEnabled(true)
        registerButtonEventListener(self.btn_right, function()
            if self.touchTreasure_type == 1 or self.touchTreasure_type == 2 then
                controller:send16643(self.index, self.touchTreasure_type)
            elseif self.touchTreasure_type == 3 then
                DialActionController:getInstance():sender16671(self.index, 1)
            end
            controller:openTreasureGetItemWindow(false)
        end ,true, 2)
        self.close_sp:setVisible(false)
    elseif self.touchTreasure_type == 3 then
        self.close_sp:setVisible(true)
    elseif self.touchTreasure_type == 4 then
        self.btn_left = createImage(self.main_panel, PathTool.getResFrame("common", "common_1017"), 360, -51, cc.p(0.5,0.5), true, 0, true)
        self.btn_left:setContentSize(cc.size(168,66))
        -- local text_left = createLabel(24,Config.ColorData.data_color4[1], Config.ColorData.data_color4[264],64,32,TI18N("确定"),self.btn_left,2, cc.p(0.5,0.5))
        local btn_left_size = self.btn_left:getContentSize()
        self.text_left = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_left_size.width/2, btn_left_size.height/2))
        self.text_left:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>确定</div>"), Config.ColorData.data_new_color_str[3]))
        self.btn_left:addChild(self.text_left)
        self.btn_left:setTouchEnabled(true)
        registerButtonEventListener(self.btn_left, function()
            controller:openTreasureGetItemWindow(false)
            if self.func then
                self.func()
            end
        end ,true, 2)
    end

    self.title_container = self.title_model:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    self:handleEffect(true)
    self:updatData()
end

function ActionTreasureGetWindow:register_event()
    if self.touchTreasure_type == 3 then
        registerButtonEventListener(self.background, function (  )
            controller:openTreasureGetItemWindow(false)
        end, false, 2)
    end
end

function ActionTreasureGetWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[103], cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.title_container:addChild(self.play_effect, 1)
        end
	end
end 

function ActionTreasureGetWindow:updatData()
    if not self.data or next(self.data) == nil then return end
    local award = self.data

    local num = 0
    local list = {}
    self.space = 20
    self.ref_height = 119
    self.ref_width = 119
    for i,v in pairs(award) do
        num = num +1
        list[num] = {bid=v.bid,quantity = v.num}
    end
    self.row = math.ceil(num/5)

    if not self.scroll_view then
        local scroll_view_size = cc.size(720,440)
        self.scroll_view =  createScrollView(scroll_view_size.width,scroll_view_size.height,self.size.width/2, 15,self.main_panel,ccui.ScrollViewDir.vertical)
        self.scroll_view:setAnchorPoint(cc.p(0.5,0))
    end
    
    self.scroll_height =self.scroll_view:getContentSize().height
    self.scroll_width = self.scroll_view:getContentSize().width
    local max_height = self.space + (self.space + self.ref_height+45) * self.row
    self.max_height = math.max(max_height, self.scroll_height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width, self.max_height))

    local sum = num
    if sum >= 5 then
        sum = 5
    end
    local total_width = sum * self.ref_width + (sum - 1)*self.space
    local start_x = (self.scroll_width - total_width) * 0.5

    self.action_effect = {}
    for i,v in ipairs(list) do
        delayRun(self.main_panel, i*10/display.DEFAULT_FPS, function() 
            local function one_fun()
                if self.action_effect[i] then
                    self.action_effect[i]:runAction(cc.RemoveSelf:create(true)) 
                    self.action_effect[i] = nil
                end
            end
            local _x = start_x + self.ref_width * 0.5 + ((i - 1) % 5) * (self.ref_width + self.space)
            local _y = self.max_height - math.floor((i - 1) / 5) * (self.ref_height + self.space+45)-self.ref_height/2-40
            if self.row <= 1 then
            	_y = _y - 100
            end
            
            local effect_id = Config.EffectData.data_effect_info[156]
            local action = PlayerAction.action_3
            self.action_effect[i] = createEffectSpine(effect_id, cc.p(_x, _y), cc.p(0.5, 0.5), false, action, one_fun, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            self.scroll_view:addChild(self.action_effect[i], 1)
        
            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    local item = BackPackItem.new(false,true)
                    item:setData(v)
                    item:setDefaultTip()
                   
                    local item_config = Config.ItemData.data_get_data(v.bid)
                    if item_config.quality >=3 then
                        local action = PlayerAction.action_2
                        if item_config.quality >=4 then 
                            action = PlayerAction.action_1
                        end
                        item:showItemEffect(true,156,action,true)
                    end
                    if item_config then
                        --local color = BackPackConst.quality_color[item_config.quality]
                        --item:setGoodsName(item_config.name,nil,22,color)
                    end
                    local _x = start_x + self.ref_width * 0.5 + ((i - 1) % 5) * (self.ref_width + self.space)
                    local _y = self.max_height - math.floor((i - 1) / 5) * (self.ref_height + self.space+45)-self.ref_height/2-40
                    if self.row <= 1 then
		            	_y = _y - 100
		            end

                    item:setPosition(cc.p(_x, _y))
                    self.scroll_view:addChild(item)
                    table.insert(self.cache_list, item)

                    local cur_row = math.ceil(i/5)
                    if cur_row > 2 then
                    	local percent = cur_row/self.row*100
                    	self.scroll_view:scrollToPercentVertical(percent, 0.5, true)
                    end
                end
            end
            self.action_effect[i]:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)       
        end)
    end
end
function ActionTreasureGetWindow:openRootWnd(type)
    playOtherSound("c_get") 
    self.can_click = false
    delayRun(self.background, 2, function() 
        self.can_click = true
    end)
end

function ActionTreasureGetWindow:close_callback()
    controller:openTreasureGetItemWindow(false)

    if self.bg_top_load then
        self.bg_top_load:DeleteMe()
        self.bg_top_load = nil
    end

    if self.bg_bottom_load then
        self.bg_bottom_load:DeleteMe()
        self.bg_bottom_load = nil
    end
    
    self:handleEffect(false)
    for i,v in pairs(self.cache_list) do
        if v and v["DeleteMe"] then 
            v:DeleteMe()
        end
    end
    self.cache_list = nil
end