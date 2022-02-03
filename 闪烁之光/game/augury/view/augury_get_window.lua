-- --------------------------------------------------------------------
-- 占卜获得界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
AuguryGetWindow = AuguryGetWindow or BaseClass(BaseView)

function AuguryGetWindow:__init(data)
    self.ctrl = AuguryController:getInstance()
    self.is_full_screen = false
    self.layout_name = "augury/augury_get_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("augury","augury"), type = ResourcesType.plist },
    }
    self.effect_cache_list = {}
    self.win_type = WinType.Big 
    self.data = data
    self.cache_list = {}

    self.can_click = false
end

function AuguryGetWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.size = self.main_panel:getContentSize()
    self.title_model = self.root_wnd:getChildByName("titlepanel")

    self.title_container = self.title_model:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    self:handleEffect(true)
    self:updatData()
end

function AuguryGetWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.can_click == false then return end
            playCloseSound()
            self.ctrl:openGetWidnow(false)
        end
    end)
end

function AuguryGetWindow:handleEffect(status)
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

function AuguryGetWindow:updatData()
    if not self.data then return end
    local award = self.data.award or {}

    local num = 0
    local list = {}
    self.space = 20
    self.ref_height = 119
    self.ref_width = 119
    for i,v in pairs(award) do
        num = num +1
        list[num] = {bid=v.item_id,quantity = v.num}
    end
    self.row = math.ceil(num/5)
    self.is_one = false
    if not self.scroll_view then
        local scroll_view_size = cc.size(720,440)
        if num <=3 then 
            self.is_one = true
            scroll_view_size = cc.size(720,400)
        end
        self.scroll_view =  createScrollView(scroll_view_size.width,scroll_view_size.height,self.size.width/2, 15,self.main_panel,ccui.ScrollViewDir.vertical)
        self.scroll_view:setAnchorPoint(cc.p(0.5,0))
    end
    
    self.scroll_height =self.scroll_view:getContentSize().height
    self.scroll_width = self.scroll_view:getContentSize().width
    local max_height = self.space + (self.space + self.ref_height+45) * self.row
    self.max_height = math.max(max_height, self.scroll_height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width, self.max_height))
    self.action_effect = {}
    for i,v in ipairs(list) do
        delayRun(self.main_panel, i*10/display.DEFAULT_FPS, function() 
            local function one_fun()
                if self.action_effect[i] then
                    self.action_effect[i]:runAction(cc.RemoveSelf:create(true)) 
                    self.action_effect[i] = nil
                end
            end
            local _x = 12 + self.ref_width * 0.5 + ((i - 1) % 5) * (self.ref_width + self.space)
            local _y = self.max_height - math.floor((i - 1) / 5) * (self.ref_height + self.space+45)-self.ref_height/2-40

            if self.is_one == true then 
                _x = self.scroll_width/2
                _y = _y -100
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
                        local color = BackPackConst.quality_color[item_config.quality]
                        item:setGoodsName(item_config.name,nil,22,color)
                    end
                    local _x = 15 + self.ref_width * 0.5 + ((i - 1) % 5) * (self.ref_width + self.space)
                    local _y = self.max_height - math.floor((i - 1) / 5) * (self.ref_height + self.space+45)-self.ref_height/2-40
                    if self.is_one == true then 
                        _x = self.scroll_width/2
                        _y = _y -100
                    end
                    item:setPosition(cc.p(_x, _y))
                    self.scroll_view:addChild(item)
                    table.insert(self.cache_list, item)
                    
                end
            end
            self.action_effect[i]:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)

           
        end)
    end
end
function AuguryGetWindow:openRootWnd(type)
    -- self.background:setTouchEnabled(false)
    self.can_click = false
    delayRun(self.background, 2, function() 
        self.can_click = true
        -- self.background:setTouchEnabled(true)
    end)
end

function AuguryGetWindow:setPanelData()
end

function AuguryGetWindow:close_callback()
    self.ctrl:openGetWidnow(false)

    self:handleEffect(false)
    for i,v in pairs(self.cache_list) do
        if v and v["DeleteMe"] then 
            v:DeleteMe()
        end
    end
    self.cache_list = nil
end
