-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄立绘档案整合
-- <br/>Create: 2019年12月4日
--
-- --------------------------------------------------------------------
HeroDrawMainWindow = HeroDrawMainWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function HeroDrawMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "hero/hero_draw_main_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("herodraw", "herodraw"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg", true), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg_2", false), type = ResourcesType.single}
    }

    self.max_scale = 1.3
    --最小比例
    self.min_scale = 0.7

    local config = Config.PartnerData.data_partner_const.vertical_zoom
    if config then
        if config.val[1] then
            self.min_scale = config.val[1]
        end
        if config.val[2] then
            self.max_scale = config.val[2]
        end
    end
    --初始化比例
    self.slider_percent = 50
    --缩放大小 为 1 时 slider_percent 的比例值
    self.scale_percent = 50

    --必须缩放的协议
    self.must_scale = 1

    --点击个数
    self.touch_count = 0
    self.original_y = 0
    self.shard_preview_status = false

    self.view_list = {}

    --是否隐藏按钮
    self.is_hide = false
end

function HeroDrawMainWindow:open_callback()
    self.gl_view  = cc.Director:getInstance():getOpenGLView()

    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(self.mainContainer , 1)  
    self.mainContainer:setTouchEnabled(false)
    self.mainContainer_size = self.mainContainer:getContentSize()
    self.container = self.mainContainer:getChildByName("container")

    --centre_panel
    self.centre_panel = self.mainContainer:getChildByName("centre_panel")
    self.centre_panel:setTouchEnabled(false)

    self.hero_draw_icon = self.centre_panel:getChildByName("hero_draw_icon")
    self.hero_draw_icon_pos_x, self.hero_draw_icon_pos_y = self.hero_draw_icon:getPosition()
    self.hero_draw_icon_pos_x1, self.hero_draw_icon_pos_y1 = self.hero_draw_icon:getPosition()

    self.slider = self.centre_panel:getChildByName("slider")
    self.slider:setBarPercent(3, 97)
    self.slider:setScale9Enabled(true)
    --按钮
    self.delete_btn = self.centre_panel:getChildByName("delete_btn")
    self.add_btn = self.centre_panel:getChildByName("add_btn")

    --top_panel
    self.top_panel = self.mainContainer:getChildByName("top_panel")
    self.top_panel:setTouchEnabled(true)
    self.hero_name_bg = self.top_panel:getChildByName("hero_name_bg")
    self.hero_name = self.hero_name_bg:getChildByName("hero_name")
    self.title_name = self.hero_name_bg:getChildByName("title_name")

    self.hide_btn = self.top_panel:getChildByName("hide_btn")
    self.share_btn = self.top_panel:getChildByName("share_btn")

    self.bottom_panel = self.mainContainer:getChildByName("bottom_panel")
    self.bottom_panel:setTouchEnabled(true)
    self.close_btn = self.bottom_panel:getChildByName("close_btn")
    self.bottom_bg = self.bottom_panel:getChildByName("bottom_bg")
    loadSpriteTexture(self.bottom_bg, PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg_2", false), LOADTEXT_TYPE)

    local tab_btn_name = {
        [1] = TI18N("英雄形象"),
        [2] = TI18N("英雄档案")
    }

    self.tab_btn_list = {}
    for i=1,2 do
        local tab_btn = {}
        local item = self.bottom_panel:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        tab_btn.title:setTextColor(cc.c4b(0xa6, 0x85, 0x65, 0xff))

        tab_btn.title:setString(tab_btn_name[i])
        self.tab_btn_list[i] = tab_btn
    end

    self.shard_handle_panel = self.mainContainer:getChildByName("shard_handle_panel")
    self.confirm_btn = self.shard_handle_panel:getChildByName("confirm_btn")
    self.cancel_btn = self.shard_handle_panel:getChildByName("cancel_btn")
    self.erweima_container = self.shard_handle_panel:getChildByName("erweima_container")
    self.erweima_img = self.erweima_container:getChildByName("img")

    self.logo_container = self.shard_handle_panel:getChildByName("logo_container")
    self.logo_img = self.logo_container:getChildByName("logo_img")
    self.logo_img:setVisible(false)
    self.logo_container:getChildByName("label"):setString(TI18N("良心二次元放置策略卡牌"))

    self:adaptationScreen()
end
--设置适配屏幕
function HeroDrawMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.mainContainer)
    local bottom_y = display.getBottom(self.mainContainer)
    -- -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.mainContainer_size.height - tab_y))

    local y = self.bottom_panel:getPositionY()
    self.bottom_panel_y = bottom_y + y
    self.bottom_panel:setPositionY(self.bottom_panel_y)

        -- 分享预览
    self.cancel_btn:setPositionY(bottom_y + 40) 
    self.confirm_btn:setPositionY(bottom_y + 40)

    self.erweima_container:setPositionY(bottom_y + 125)

    self.logo_container:setPositionY(top_y) 
    
    self.erweima_init_y = bottom_y + 125 
    self.name_init_y = bottom_y + 150
end

function HeroDrawMainWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)

    registerButtonEventListener(self.delete_btn, function() self:onDeleteBtn() end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.add_btn, function() self:onAddBtn() end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.hide_btn, function() self:onHideBtn() end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.mainContainer, function() self:onHideBtn() end ,false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    for index, tab_btn in ipairs(self.tab_btn_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabIndex(tab_btn.index) end ,false, REGISTER_BUTTON_SOUND_BUTTON_TYPY) 
    end

    self.slider:addEventListener(function ( sender,event_type )
        if event_type == ccui.SliderEventType.percentChanged then
            self.slider_percent = self.slider:getPercent()
            self:setIconScale()
        end
    end)

    registerButtonEventListener(self.share_btn, function() 
        if FINAL_CHANNEL == "syios_smzhs" then
            message(TI18N("暂不支持"))
            return
        end
        self:enterShardStatus(true)
    end, true, 1)

    registerButtonEventListener(self.cancel_btn, function()
        self:enterShardStatus(false)
    end, true, 1)

    registerButtonEventListener(self.confirm_btn, function() 
        self:shardErweimaImg()
    end, true, 1)

    --多点触摸事件
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin),cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved),cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded),cc.Handler.EVENT_TOUCHES_ENDED)
    self.centre_panel:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.centre_panel)
end

function HeroDrawMainWindow:onClickBtnClose()
    controller:openHeroDrawMainWindow(false)
end


function HeroDrawMainWindow:enterShardStatus(status)
    -- self.shard_preview_status = status

    -- self.story_btn:setVisible(not status)
    self.top_panel:setVisible(not status)
    self.bottom_panel:setVisible(not status)
    self.container:setVisible(not status)
    self.shard_handle_panel:setVisible(status)
    if status == true then
        if IS_NEED_SHOW_LOGO == false then
            self.logo_img:setVisible(false)
        else
            local logo_path = PathTool.getLogoRes()
            loadSpriteTexture(self.logo_img, logo_path, LOADTEXT_TYPE)
            self.logo_img:setVisible(true)        
        end
        if IS_NEED_SHOW_ERWEIMA == false then
            self.erweima_container:setVisible(false)
        else
            self.erweima_container:setVisible(true)
            self:downErweimaImg()
        end
    end
end

--==============================--
--desc:下载二维码
--time:2019-01-26 11:15:40
--@return 
--==============================--
function HeroDrawMainWindow:downErweimaImg()
    local apk_data = RoleController:getInstance():getApkData()
    if apk_data then
        download_qrcode_png(apk_data.message.qrcode_url, function(code, filepath)
            if not tolua.isnull(self.erweima_img) then
                if code == 0 then
                    loadSpriteTexture(self.erweima_img, filepath, LOADTEXT_TYPE)
                    self.qrCodeImage = filepath         -- 标识下载成功
                end
                
                local size = self.erweima_img:getContentSize()
                local scale = 130 / size.width
                self.erweima_img:setScale(scale)
            end
        end)
    end 
end
--==============================--
--desc:执行分享操作
--time:2019-01-26 12:04:46
--@return 
--==============================--
function HeroDrawMainWindow:shardErweimaImg()
    if not IS_IOS_PLATFORM and callFunc("checkWrite") == "false" then return end
    self:changeShardStatus(false)
    local save_name = "sy_gameshard_image"
    if getRandomSaveName then
        save_name = getRandomSaveName()
    end

    local fileName = cc.FileUtils:getInstance():getWritablePath()..save_name..".png"
    delayOnce(function()
        cc.utils:captureScreen(function(succeed)
            if succeed then
                saveImageToPhoto(fileName)
                self:changeShardStatus(true)
            else
                message("保存失败")
            end
        end, fileName)
    end, 0.01)
end

function HeroDrawMainWindow:changeShardStatus(status)
    self.cancel_btn:setVisible(status)
    self.confirm_btn:setVisible(status)
    self.add_btn:setVisible(status)
    self.delete_btn:setVisible(status)
    self.slider:setVisible(status)
    if self.share_name == nil and self.hero_vo then
        self.share_name = createLabel(34, cc.c3b(0x52,0x37,0x17), nil, 24, 50, self.hero_vo.name, self.shard_handle_panel, 0, cc.p(0,0.5))
    end
    if self.share_name then
        self.share_name:setVisible(not status)
    end
    
    if status == false then
        local bottom_y = display.getBottom() 
        self.erweima_container:setPositionY(bottom_y + 20)
        -- self.name:setPositionY(bottom_y + 60) 
    else
        self.erweima_container:setPositionY(self.erweima_init_y)
        -- self.name:setPositionY(self.name_init_y) 
    end
end

--隐藏
function HeroDrawMainWindow:onHideBtn()
    --隐藏或者显示中
    if self.is_hiding then return end
    self.is_hide = not self.is_hide

    self.is_hiding = true

    local move_func = function(obj, x ,y)
        if not obj then return end
        local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(x, y))) 
        obj:runAction(moveto)
    end

    if self.is_hide then --变隐藏
        self.mainContainer:setTouchEnabled(true)
        local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(360, self.bottom_panel_y - 140))) 
        self.bottom_panel:runAction(cc.Sequence:create(moveto, cc.CallFunc:create(function()
           self.is_hiding = false
        end)))
        self.hide_btn:setTouchEnabled(false)
        self.share_btn:setTouchEnabled(false)
        self.slider:setTouchEnabled(false)
        self.delete_btn:setTouchEnabled(false)
        self.add_btn:setTouchEnabled(false)

        move_func(self.hero_name_bg, 360, 137)
        move_func(self.hide_btn, -40, -109)
        move_func(self.share_btn, -40, -34)
        
        move_func(self.slider, 748, 724)
        move_func(self.delete_btn, 748, 464)
        move_func(self.add_btn, 748, 985)
    else --显示
        local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(360, self.bottom_panel_y))) 
        self.bottom_panel:runAction(cc.Sequence:create(moveto, cc.CallFunc:create(function()
            self.is_hiding = false
            self.mainContainer:setTouchEnabled(false)
            self.hide_btn:setTouchEnabled(true)
            self.share_btn:setTouchEnabled(true)
            self.slider:setTouchEnabled(true)
            self.delete_btn:setTouchEnabled(true)
            self.add_btn:setTouchEnabled(true)
        end)))

        move_func(self.hero_name_bg, 360, 10)
        move_func(self.hide_btn, 50, -109)
        move_func(self.share_btn, 50, -34)

        move_func(self.slider, 683, 724)
        move_func(self.delete_btn, 683, 464)
        move_func(self.add_btn, 683, 985)
    end

    if self.view_list[1] then
         self.view_list[1]:hideAllBottom(self.is_hide)
    end  
end

--减
function HeroDrawMainWindow:onDeleteBtn()
    self.slider_percent = self.slider_percent - 1
    if self.slider_percent <= 0 then
        self.slider_percent = 0
    end
    self.slider:setPercent(self.slider_percent)
    self:setIconScale()
end
--加
function HeroDrawMainWindow:onAddBtn()
    self.slider_percent = self.slider_percent + 1
    if self.slider_percent >= 100 then
        self.slider_percent = 100
    end
    self.slider:setPercent(self.slider_percent)
    self:setIconScale()
end

function HeroDrawMainWindow:setIconScale()
    local cur_scale
    if self.slider_percent > self.scale_percent then
        local scale = self.max_scale - 1
        cur_scale = 1 + (self.slider_percent - self.scale_percent) * scale /50 
    elseif self.slider_percent < self.scale_percent then
        local scale = 1 - self.min_scale 
        cur_scale = self.min_scale + self.slider_percent * scale /50 
    else
        cur_scale = 1
    end
    self.cur_scale = cur_scale
    self.hero_draw_icon:setScale(cur_scale * self.must_scale)
end

function HeroDrawMainWindow:onTouchBegin( touch, event )
    -- 还处于回弹中的时候不给移动操作
    -- if self.is_in_scale == true then 
    --     return false
    -- end

    -- self.distance = 0
    -- self.last_point = nil
    -- self.in_touch_move = true
    -- self.in_acceleration = false
    -- self.map_blayer:stopAllActions()
    -- if self.map_mlayer then
    --     self.map_mlayer:stopAllActions()
    -- end
    -- self.root_wnd:stopAllActions()
    return true
end

function HeroDrawMainWindow:onTouchMoved( touch, event )
    local touch_point = #self.gl_view:getAllTouches()
    if touch_point == 1 then
        local touch_pos = touch[1]:getLocation()
        self:onMovePos(touch_pos)
        if self.touch_count < 1 then
            self.touch_count = 1
        end
    else
        if self.touch_count < 2 then
            self.touch_count = 2
        end
    end
end

function HeroDrawMainWindow:onTouchEnded( touch, event )
    local touch_point = #self.gl_view:getAllTouches()
    if touch_point ~= 0 then return end
    
    if self.touch_count == 1 then
        local touch_pos = touch[1]:getLocation()
        self:onEndPos(touch_pos)
    elseif self.touch_count == 2 then
        return
    end



    -- if touch_point ~= 0 then return end
    
    -- local mscale = 0
    -- if self.mscale > 2 then
    --     mscale = 2
    -- elseif self.mscale < self.default_scale then
    --     mscale = self.default_scale
    -- end

    -- if mscale == 0 then 
    --     if self.last_point == nil then return end
    --     local interval_x = self.last_point.x * 3
    --     local interval_y = self.last_point.y * 3
    --     self.last_point = nil

    --     local temp_x = self.root_wnd:getPositionX() + interval_x
    --     local temp_y = self.root_wnd:getPositionY() + interval_y

    --     -- 修正之后的目标位置
    --     local target_x, target_y = self:scaleCheckPoint( temp_x, temp_y )

    --     local move_to_1 = cc.MoveTo:create(1, cc.p((target_x-self.init_x)*self.b_run_times, (target_y-self.init_y)*self.b_run_times))
    --     self.map_blayer:runAction(cc.EaseSineOut:create(move_to_1))

    --     if self.map_mlayer then
    --         local move_to_2 = cc.MoveTo:create(1, cc.p((target_x-self.init_x)*self.m_run_times, (target_y-self.init_y)*self.m_run_times))
    --         self.map_mlayer:runAction(cc.EaseSineOut:create(move_to_2))
    --     end

    --     local move_to_3 = cc.MoveTo:create(1, cc.p(target_x, target_y))
    --     local call_fun = cc.CallFunc:create(function()
    --         self.in_touch_move = false
    --     end)
    --     local ease_out = cc.EaseSineOut:create(move_to_3)
    --     self.root_wnd:runAction(cc.Sequence:create(ease_out, call_fun))
    -- else
    --     self.is_in_scale = true

    --     local temp_x = (self.root_wnd:getPositionX() - self.base_x) * mscale / self.mscale + self.base_x
    --     local temp_y = (self.root_wnd:getPositionY() - self.base_y) * mscale / self.mscale + self.base_y

    --     local scale_to = cc.ScaleTo:create(0.3, mscale, mscale)
    --     local move_to = cc.MoveTo:create(0.3, cc.p(temp_x, temp_y))
    --     local call_fun = cc.CallFunc:create(function()
    --         self.mscale = mscale
    --         self.in_touch_move = false
    --         self.is_in_scale = false
            
    --         self.init_x = temp_x
    --         self.init_y = temp_y
    --     end)

    --     local seq = cc.Sequence:create( cc.Spawn:create(move_to, scale_to), call_fun )
    --     self.root_wnd:runAction(seq)

    --     -- local move_to_1 = cc.MoveTo:create(0.3, cc.p((temp_x-self.init_x)*self.b_run_times, (temp_y-self.init_y)*self.b_run_times))
    --     -- self.map_blayer:runAction(move_to_1)

    --     -- if self.map_mlayer then 
    --     --     local move_to_2 = cc.MoveTo:create(0.3, cc.p((temp_x-self.init_x)*self.m_run_times, (temp_y-self.init_y)*self.m_run_times))
    --     --     self.map_mlayer:runAction(move_to_2)
    --     -- end
    -- end
end


function HeroDrawMainWindow:onMovePos(touch_pos)
    if not touch_pos then return end
    if self.start_x and self.start_y then
        local target_pos = self.centre_panel:convertToNodeSpace(touch_pos)
        local x = target_pos.x - self.start_x
        local y = target_pos.y - self.start_y
        self.hero_cur_iocn_pos_x = self.hero_draw_icon_pos_x + x
        self.hero_cur_iocn_pos_y = self.hero_draw_icon_pos_y + y
        self.hero_draw_icon:setPosition(self.hero_cur_iocn_pos_x, self.hero_cur_iocn_pos_y)
    else
        local target_pos = self.centre_panel:convertToNodeSpace(touch_pos) 
        self.start_x = target_pos.x
        self.start_y = target_pos.y
    end
end


function HeroDrawMainWindow:onEndPos(touch_pos)
    if not touch_pos then return end
    if self.start_x == nil or  self.start_y == nil then return end
    local target_pos = self.centre_panel:convertToNodeSpace(touch_pos)
    local x = target_pos.x - self.start_x
    local y = target_pos.y - self.start_y
    self.hero_draw_icon_pos_x = self.hero_draw_icon_pos_x + x 
    self.hero_draw_icon_pos_y = self.hero_draw_icon_pos_y + y
    self.start_x = nil
    self.start_y = nil
end


-- @index  1 表示英雄  2 表示 档案
function HeroDrawMainWindow:changeTabIndex(index)
    if self.select_btn and self.select_btn.index == index then return end

    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:setTextColor(cc.c4b(0xa6, 0x85, 0x65, 0xff))
    end

    self.select_btn = self.tab_btn_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.title:setTextColor(cc.c4b(0xf8, 0xc4, 0x86, 0xff))
    end

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end
    self.pre_panel = self:createSubPanel(index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end

    if index == 1 then
        self.centre_panel:setVisible(true)
        self.top_panel:setVisible(true)
    else
        self.centre_panel:setVisible(false)
        self.top_panel:setVisible(false)
    end
end

function HeroDrawMainWindow:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index == 1 then
            panel = HeroDrawMainTabDraw.new(self) 
        elseif index == 2 then
            panel = HeroDrawMainTabFiles.new(self)
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function HeroDrawMainWindow:openRootWnd(setting)
    local setting = setting or {}
    local index = setting.index or 1
    self.hero_vo = setting.hero_vo
    if not self.hero_vo then return end

    self.hero_name:setString(self.hero_vo.name)
    
    self:changeTabIndex(index)
    
    self:initHeroDraw(self.hero_vo.use_skin)
end

function HeroDrawMainWindow:initHeroDraw( use_skin)
    if not self.hero_vo then return end
    -- share_type = share_type or HeroConst.ShareType.eHeroInfoShare
    local draw_res = nil
    local name = nil
    self.must_scale = 1

    if use_skin == nil or use_skin == 0 then   
        -- 原本皮肤 
        self.library_config = Config.PartnerData.data_partner_library(self.hero_vo.bid)
        if self.hero_vo.is_pokedex then
            local parther_config = Config.PartnerData.data_partner_base[self.hero_vo.bid]
            if parther_config then
                draw_res = parther_config.draw_res
            end
        else
            draw_res = self.hero_vo.draw_res
        end
        if self.library_config then
            name = self.library_config.title
            if self.library_config.scale ~= 0 then
                self.must_scale = self.library_config.scale/100
            end
            if not self.is_init_pos and self.library_config.draw_offset and next(self.library_config.draw_offset) ~= nil then
                local offset_x = self.library_config.draw_offset[1][1] or 0
                local offset_y = self.library_config.draw_offset[1][2] or 0
                self.hero_draw_icon_pos_x = self.hero_draw_icon_pos_x1 + offset_x
                self.hero_draw_icon_pos_y = self.hero_draw_icon_pos_y1 + offset_y
            end
        end
    else
        --换了皮肤
        local skin_config = Config.PartnerSkinData.data_skin_info[use_skin]
        if skin_config then
            draw_res = skin_config.draw_res
            name = skin_config.skin_name
            if skin_config.scale ~= 0 then
                self.must_scale = skin_config.scale/100
            end
            if not self.is_init_pos and skin_config.draw_offset and next(skin_config.draw_offset) ~= nil then
                local offset_x = skin_config.draw_offset[1][1] or 0
                local offset_y = skin_config.draw_offset[1][2] or 0
                self.hero_draw_icon_pos_x = self.hero_draw_icon_pos_x1 + offset_x
                self.hero_draw_icon_pos_y = self.hero_draw_icon_pos_y1 + offset_y
            end
        end
    end
    --标志是否初始化位置了
    self.is_init_pos = true
     
    local draw_res = draw_res or "jinglingwangzi"
    local bg_res = PathTool.getPlistImgForDownLoad("herodraw/herodrawres",draw_res, false)
    if self.hero_draw_icon then
        self.item_load = loadSpriteTextureFromCDN(self.hero_draw_icon, bg_res, ResourcesType.single, self.item_load) 
    end
    self.slider:setPercent(self.slider_percent)
    if self.cur_scale then
        self.hero_draw_icon:setScale(self.must_scale * self.cur_scale)
    else
        self.hero_draw_icon:setScale(self.must_scale)
    end

    if self.hero_cur_iocn_pos_x and self.hero_cur_iocn_pos_y then
        self.hero_draw_icon:setPosition(self.hero_cur_iocn_pos_x, self.hero_cur_iocn_pos_y)
    else
        self.hero_draw_icon:setPosition(self.hero_draw_icon_pos_x, self.hero_draw_icon_pos_y)
    end

    local name = name or ""
    self.title_name:setString(name)
end

function HeroDrawMainWindow:close_callback()
    -- if self.list_view then
    --     self.list_view:DeleteMe()
    --     self.list_view = nil
    -- end
    for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end
    self.view_list = nil

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    controller:openHeroDrawMainWindow(false)
end