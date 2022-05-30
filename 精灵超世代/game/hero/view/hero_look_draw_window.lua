-- --------------------------------------------------------------------
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @description:
--      宝可梦查看立绘界面(废弃 日期 2019年12月6日)
-- <br/> 2018年11月15日
--
-- --------------------------------------------------------------------
HeroLookDrawWindow = HeroLookDrawWindow or BaseClass(BaseView)

local string_format = string.format

function HeroLookDrawWindow:__init()
    self.ctrl = HeroController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "hero/hero_look_draw_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("herodraw", "herodraw"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg", true), type = ResourcesType.single}
    }
    --最大比例

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
end

function HeroLookDrawWindow:open_callback()
    self.gl_view  = cc.Director:getInstance():getOpenGLView()

    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero","hero_draw_bg",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)  
    self.main_container:setTouchEnabled(false)
    self.hero_draw_icon = self.main_container:getChildByName("hero_draw_icon")
    self.hero_draw_icon_pos_x, self.hero_draw_icon_pos_y = self.hero_draw_icon:getPosition()

    self.slider = self.main_container:getChildByName("slider")
    self.slider:setBarPercent(3, 97)
    self.slider:setScale9Enabled(true)
    --名字
    self.name = self.main_container:getChildByName("name")
    --按钮
    self.delete_btn = self.main_container:getChildByName("delete_btn")
    self.add_btn = self.main_container:getChildByName("add_btn")
    self.close_btn = self.main_container:getChildByName("close_btn")

    self.bottom_lay = self.main_container:getChildByName("bottom_lay")
    self.top_lay = self.main_container:getChildByName("top_lay")

    self.story_btn = self.main_container:getChildByName("story_btn")
    self.shard_preview_btn = self.main_container:getChildByName("shard_preview_btn")

    self.shard_handle_panel = self.main_container:getChildByName("shard_handle_panel")
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
function HeroLookDrawWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    -- --主菜单 顶部的高度
    local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()

    local btn_y = bottom_y + 98
    self.slider:setPositionY(btn_y)
    self.delete_btn:setPositionY(btn_y)
    self.add_btn:setPositionY(btn_y)
    self.name:setPositionY(bottom_y + 150)

    -- 分享预览
    self.shard_preview_btn:setPositionY(bottom_y + 40)
    self.cancel_btn:setPositionY(bottom_y + 40) 
    self.confirm_btn:setPositionY(bottom_y + 40)
    self.story_btn:setPositionY(bottom_y + 40)

    self.erweima_container:setPositionY(bottom_y + 125)

    self.logo_container:setPositionY(top_y) 
    
    local closed_y = top_y - 80
    self.close_btn:setPositionY(closed_y)

    self.bottom_lay:setPositionY(bottom_y)
    self.bottom_lay:setContentSize(cc.size(SCREEN_WIDTH, bottom_height))
    self.top_lay:setPositionY(top_y)
    self.top_lay:setContentSize(cc.size(SCREEN_WIDTH, top_height))

    self.erweima_init_y = bottom_y + 125 
    self.name_init_y = bottom_y + 150
    self.handle_init_y = btn_y 
    
end

function HeroLookDrawWindow:register_event()
    registerButtonEventListener(self.close_btn, function() self.ctrl:openHeroLookDrawWindow(false) end, true, 2)

    registerButtonEventListener(self.delete_btn, function() self:onDeleteBtn() end ,true, 2)
    registerButtonEventListener(self.add_btn, function() self:onAddBtn() end ,true, 2)

    registerButtonEventListener(self.story_btn, function() self:onClickStoryBtn() end ,true, 1)
    registerButtonEventListener(self.shard_preview_btn, function() 
        if FINAL_CHANNEL == "syios_smzhs" then
            message(TI18N("暂不支持"))
            return
        end
        self:enterShardStatus(true)
    end, true, 1)

    registerButtonEventListener(self.cancel_btn, function()
        if self.share_type == HeroConst.ShareType.eHeroInfoShare then --默认宝可梦信息分享返回
            self:enterShardStatus(false)
        elseif self.share_type == HeroConst.ShareType.eLibraryInfoShare then --图书馆宝可梦分享返回
            self.ctrl:openHeroLookDrawWindow(false)
        end
    end, true, 1)

    registerButtonEventListener(self.confirm_btn, function() 
        self:shardErweimaImg()
    end, true, 1)

    self.slider:addEventListener(function ( sender,event_type )
        if event_type == ccui.SliderEventType.percentChanged then
            self.slider_percent = self.slider:getPercent()
            self:setIconScale()
        end
    end)

    --多点触摸事件
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(handler(self, self.onTouchBegin),cc.Handler.EVENT_TOUCHES_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved),cc.Handler.EVENT_TOUCHES_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded),cc.Handler.EVENT_TOUCHES_ENDED)
    self.main_container:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.main_container)
end

--==============================--
--desc:切换分享状态
--time:2019-01-26 11:08:16
--@status:
--@return 
--==============================--
function HeroLookDrawWindow:enterShardStatus(status)
    self.shard_preview_status = status

    self.story_btn:setVisible(not status)
    self.close_btn:setVisible(not status)
    self.shard_preview_btn:setVisible(not status)
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
function HeroLookDrawWindow:downErweimaImg()
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
function HeroLookDrawWindow:shardErweimaImg()
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

function HeroLookDrawWindow:changeShardStatus(status)
    self.cancel_btn:setVisible(status)
    self.confirm_btn:setVisible(status)
    self.add_btn:setVisible(status)
    self.delete_btn:setVisible(status)
    self.slider:setVisible(status)
    if status == false then
        local bottom_y = display.getBottom() 
        self.erweima_container:setPositionY(bottom_y + 20)
        self.name:setPositionY(bottom_y + 60) 
    else
        self.erweima_container:setPositionY(self.erweima_init_y)
        self.name:setPositionY(self.name_init_y) 
    end
end

--
function HeroLookDrawWindow:onTouchBegin( touch, event )
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

function HeroLookDrawWindow:onTouchMoved( touch, event )
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

function HeroLookDrawWindow:onTouchEnded( touch, event )
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


function HeroLookDrawWindow:onMovePos(touch_pos)
    if not touch_pos then return end
    if self.start_x and self.start_y then
        local target_pos = self.main_container:convertToNodeSpace(touch_pos)
        local x = target_pos.x - self.start_x
        local y = target_pos.y - self.start_y
        self.hero_draw_icon:setPosition(self.hero_draw_icon_pos_x + x, self.hero_draw_icon_pos_y + y)
    else
        local target_pos = self.main_container:convertToNodeSpace(touch_pos) 
        self.start_x = target_pos.x
        self.start_y = target_pos.y
    end
end


function HeroLookDrawWindow:onEndPos(touch_pos)
    if not touch_pos then return end
    if self.start_x == nil or  self.start_y == nil then return end
    local target_pos = self.main_container:convertToNodeSpace(touch_pos)
    local x = target_pos.x - self.start_x
    local y = target_pos.y - self.start_y
    self.hero_draw_icon_pos_x = self.hero_draw_icon_pos_x + x 
    self.hero_draw_icon_pos_y = self.hero_draw_icon_pos_y + y
    self.start_x = nil
    self.start_y = nil
end

--减
function HeroLookDrawWindow:onDeleteBtn()
    self.slider_percent = self.slider_percent - 1
    if self.slider_percent <= 0 then
        self.slider_percent = 0
    end
    self.slider:setPercent(self.slider_percent)
    self:setIconScale()
end
--加
function HeroLookDrawWindow:onAddBtn()
    self.slider_percent = self.slider_percent + 1
    if self.slider_percent >= 100 then
        self.slider_percent = 100
    end
    self.slider:setPercent(self.slider_percent)
    self:setIconScale()
end

--查看宝可梦传记
function HeroLookDrawWindow:onClickStoryBtn()
    if not self.partner_config or not self.library_config then return end
    if self.library_config.story == nil or self.library_config.story == "" then
        message(TI18N("该宝可梦暂无传记"))
        return 
    end
    local name = string_format("%s %s",self.library_config.title, self.partner_config.name)
    local content = self.library_config.story
    self.ctrl:openHeroLibraryStoryPanel(true, name, content)
end

function HeroLookDrawWindow:setIconScale()
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
    self.hero_draw_icon:setScale(cur_scale * self.must_scale)
end

--@draw_res_id 对应立绘的id
--@name 立绘对应的宝可梦名字
function HeroLookDrawWindow:openRootWnd(draw_res_id, name, hero_vo, share_type)
    if not hero_vo then return end
    self.hero_vo = hero_vo
    share_type = share_type or HeroConst.ShareType.eHeroInfoShare
    local bid = hero_vo.bid
    local partner_config = Config.PartnerData.data_partner_base[bid]
    local library_config = Config.PartnerData.data_partner_library(bid)
    --传记需要
    self.partner_config = partner_config
    self.library_config = library_config

    self.must_scale = 1
    if self.hero_vo.use_skin == nil or self.hero_vo.use_skin == 0 then   
        -- 原本皮肤 
        if library_config then
            if library_config.scale ~= 0 then
                self.must_scale = library_config.scale/100
            end
            if library_config.draw_offset and next(library_config.draw_offset) ~= nil then
                local offset_x = library_config.draw_offset[1][1] or 0
                local offset_y = library_config.draw_offset[1][2] or 0
                self.hero_draw_icon_pos_x = self.hero_draw_icon_pos_x + offset_x
                self.hero_draw_icon_pos_y = self.hero_draw_icon_pos_y + offset_y
            end
        end
    else
        --换了皮肤
        local skin_config = Config.PartnerSkinData.data_skin_info[self.hero_vo.use_skin]
        if skin_config then
            if skin_config.scale ~= 0 then
                self.must_scale = skin_config.scale/100
            end
            if skin_config.draw_offset and next(skin_config.draw_offset) ~= nil then
                local offset_x = skin_config.draw_offset[1][1] or 0
                local offset_y = skin_config.draw_offset[1][2] or 0
                self.hero_draw_icon_pos_x = self.hero_draw_icon_pos_x + offset_x
                self.hero_draw_icon_pos_y = self.hero_draw_icon_pos_y + offset_y
            end
        end
    end

    local draw_res_id = draw_res_id or "jinglingwangzi"
    local bg_res = PathTool.getPlistImgForDownLoad("herodraw/herodrawres",draw_res_id, false)
    if self.hero_draw_icon then
        self.item_load = loadSpriteTextureFromCDN(self.hero_draw_icon, bg_res, ResourcesType.single, self.item_load) 
    end
    self.slider:setPercent(self.slider_percent)
    self.hero_draw_icon:setScale(self.must_scale)
    self.hero_draw_icon:setPosition(self.hero_draw_icon_pos_x, self.hero_draw_icon_pos_y)

    local name = name or ""
    self.name:setString(name)
    --绘图分享来源类型
    if share_type == HeroConst.ShareType.eHeroInfoShare then
        self:enterShardStatus(false)
    elseif share_type == HeroConst.ShareType.eLibraryInfoShare then
        self:enterShardStatus(true)
    end
    self.share_type = share_type
end



function HeroLookDrawWindow:close_callback()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    self.ctrl:openHeroLookDrawWindow(false)
end
