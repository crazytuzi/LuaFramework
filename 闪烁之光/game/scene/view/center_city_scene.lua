-- --------------------------------------------------------------------
-- 新的中心城
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

CenterCityScene = CenterCityScene or BaseClass()

local mainscene_ctrl = MainSceneController:getInstance()
local table_insert = table.insert
local table_remove = table.remove
-- local is_city_thumbnail = true --是否打开主城缩略图 --lwc

function CenterCityScene:__init(config)
    self.config                 = config
    self.size                   = cc.size(self.config.width, self.config.height)
    self.layer_num              = self.config.layer_sum
    self.speed_list             = {0.2, 0, -0.15, -0.25}
    self.step                   = 0
    self.add_build_interval     = 2
    self.rem_spine_interval     = 3600
    self.build_list             = {}    
    self.effect_list            = {}
    self.isStartUpdate          = false
    self.map_create_end         = false                 -- 主城地图创建完成
    self.map_cache              = {}                    -- 地图带创建的缓存数据
    self.layer_img_list         = {"1.png", "2.png", "3.png", "4.jpg"}

    self.cur_time_type          = 1
    self.target_time_type       = 1
    self.root_visible           = true

    self.map_resources_list     = {}          -- 地图资源

    self.is_save_logindata      = false

    self:createRootWnd()
    self:registerEvent()
    self:createScene()
end

--==============================--
--desc:设置时间类型
--time:2018-07-27 05:21:09
--@type:
--@return 
--==============================--
function CenterCityScene:setTimeType(type)
	local cur_type = 0
        

	if type == 6 then
		cur_type = 1
        -- RoleController:getInstance():getModel().city_music_name = "s_011"
    elseif type == 18 then
        -- RoleController:getInstance():getModel().city_music_name = "s_010"
		cur_type = 2
	end
	if self.target_time_type ~= cur_type then
		self.target_time_type = cur_type

        -- 这个时候就需要换资源了
        if self.root_visible == false and self.target_time_type ~= self.cur_time_type and self.map_create_end == true then
            self.cur_time_type = self.target_time_type
            self:changeMainSceneMap()
            self:changeSceneEffect()
            self:beforeUpdateBuild()
        end
	end
end

function CenterCityScene:setVisible(status)
    self.root_visible = status
    if self.root then
        self.root:setVisible(status)
    end
    -- 这个时候要判断一下当前的时间类型跟现在是否一致
    if status == false then
        if self.target_time_type ~= self.cur_time_type and self.map_create_end == true then
            self.cur_time_type = self.target_time_type -- 这个时候就需要替换掉资源了
            self:changeMainSceneMap()
            self:changeSceneEffect()
            self:beforeUpdateBuild()
        end
        self:showSceneEffectById(false)
    end
    if status == true then
        -- ios打开窗体上报
        if MAKELIFEBETTER == true and ios_log_report then
            ios_log_report("center_city_scene")
        end
    end
end

function CenterCityScene:playBackgroundMusic()
    local music_name = RoleController:getInstance():getModel().city_music_name or "s_002"
	AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, music_name, true)
end

--==============================--
--desc:初始定义相关层级,当前定义的地图层有7层
--time:2017-07-07 09:50:48
--@return 
--==============================--
function CenterCityScene:createRootWnd()
    self.root = ccui.Layout:create()
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.root:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self.root:setScale(display.getMaxScale())
    if is_city_thumbnail then
        self.root:setScale(0.3)
    end
    self.difference_width = ( SCREEN_WIDTH*display.getMaxScale() - (display.getRight(self.root, true) - display.getLeft(self.root, true)) ) * 0.5 / display.getMaxScale()

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setContentSize(self.size)
    self.root:addChild(self.root_wnd)

    -- 创建7个地图层,其中1是最靠前的层
    for i=1,self.layer_num do
        self["map_layer"..i] = ccui.Widget:create()
        self["map_layer"..i]:setAnchorPoint(cc.p(0, 0))
        self["map_layer"..i]:setContentSize(self.size)
	    self.root_wnd:addChild(self["map_layer"..i], self.layer_num + 1 - i)            -- 第0层放马赛克地图
        -- 同时定义每一层的相对移动速度
        self["map_layer"..i].speed = self.speed_list[i]
    end

    -- 创建特殊的背景
    if USESCENEMAKELIFEBETTER then
       self.verifyios_bg = createSprite(nil, self.size.width*0.5, self.size.height*0.5, self.root_wnd, cc.p(0.5,0.5), nil, -1) 
    end

    -- 创建主城特效层（花火大会活动的烟花特效）
    self.effect_layer = ccui.Layout:create()
    self.effect_layer:setContentSize(self.size)
    self.root_wnd:addChild(self.effect_layer, 99)

    -- 计算出地图的初始位置
    self.init_x = ( SCREEN_WIDTH - self.size.width ) * 0.5
    self.init_y = ( SCREEN_HEIGHT - self.size.height ) * 0.5

    --修改主城x位置 可以配置表 city_data表 --by lwc
    local offset = 0
    if Config.CityData.data_const then
        local config = Config.CityData.data_const.camera_default_x_pos
        if config then
            offset = config.val - self.init_x
        end
    end
    self:updateMainScene(self.init_x + offset, self.init_y)

    -- 提审服才需要处理的
    if NEEDCHANGEENTERSTATUS and MAKELIFEBETTER == true then
        self:setVisible(false)
    end

    ViewManager:getInstance():addToLayerByTag(self.root, ViewMgrTag.Scene_LAYER_TAG)
end

--==============================--
--desc:刷新地图位置
--time:2017-07-07 10:25:34
--@x:
--@y:
--@return 
--==============================--
function CenterCityScene:updateMainScene(x, y)
    y = y or self.init_y
    for i=1, self.layer_num do
        if self["map_layer"..i] then
            self["map_layer"..i]:setPosition((x-self.init_x) * self["map_layer"..i].speed, y-self.init_y)
        end
    end
    self.root_wnd:setPosition( x, y )
end

--==============================--
--desc:移动地图,先检测位置, 主需要移动X
--time:2017-07-07 10:30:54
--@x:
--@return 
--==============================--
function CenterCityScene:moveMainScene(x)
    x = self.root_wnd:getPositionX() + x
    local _x = self:scaleCheckPoint(x)
    self:updateMainScene(_x)
end

function CenterCityScene:scaleCheckPoint( _x )
    if _x > self.difference_width then
        _x = self.difference_width
    elseif _x < SCREEN_WIDTH - self.size.width - self.difference_width then
        _x = SCREEN_WIDTH - self.size.width - self.difference_width
    end
    return _x
end

--==============================--
--desc:进入中心城,在这里创建马赛克地图,和各层地图
--time:2017-07-07 09:53:23
--@return 
--==============================--
function CenterCityScene:createScene()
    self.map_create_end = false
    -- 先判断一些当前应该显示什么主城背景
    local hour = tonumber(os.date("%H"))
    if hour>= 6 and hour< 18 then
        self.cur_time_type = 1
        self.target_time_type = 1
        -- RoleController:getInstance():getModel().city_music_name = "s_011"
    else
        self.cur_time_type = 2
        self.target_time_type = 2
        -- RoleController:getInstance():getModel().city_music_name = "s_010"
    end
    -- 根据时间去区分
    self:changeSceneEffect()

    if USESCENEMAKELIFEBETTER  == true then
        self:renderMapPicByVerify(self.config.width, self.config.height)
    else
        self:renderMapPic()
        self:renderSmallPic()
    end

    local build_list = mainscene_ctrl:getBuildList()
    if build_list == nil or next(build_list) == nil then
        if self.wait_create_build_event == nil then
            self.wait_create_build_event = GlobalEvent:getInstance():Bind(SceneEvent.CreateBuildVoOver, function() 
                GlobalEvent:getInstance():UnBind(self.wait_create_build_event)
                self.wait_create_build_event = nil
                self:beforeCreateBuild()
            end)
        end
    else
        self:beforeCreateBuild()
    end
end

function CenterCityScene:beforeCreateBuild()
    self.scene_load = createResourcesLoad(PathTool.getPlistImgForDownLoad("centerscene", "centerscene"),ResourcesType.plist,function()
        local render_build_list = mainscene_ctrl:getBuildList() -- 获取场景建筑数据
        for i,v in pairs(render_build_list) do
            delayRun(self.root, 2/display.DEFAULT_FPS, function()
                self:createBuildItem(v)
            end)
        end
        self:setScheduleUpdate(true)
    end,self.scene_load)
end

function CenterCityScene:beforeUpdateBuild()
    self.scene_load = createResourcesLoad(PathTool.getPlistImgForDownLoad("centerscene", "centerscene"),ResourcesType.plist,function()
        if self.build_list then
            for i,v in pairs(self.build_list) do
                delayRun(self.root, 2/display.DEFAULT_FPS, function()
                    if v.updateBuildBg then
                        v:updateBuildBg()
                    end
                end)
            end
        end
    end,self.scene_load)
end

--==============================--
--desc:创建各个层图片
--time:2017-07-07 01:10:08
--@return 
--==============================--
function CenterCityScene:renderMapPic()
    local map_res = string.format("resource/centerscene/%s/%s", self.config.res_id, self.cur_time_type)
    local layer_data, res_path = nil
    local pos = cc.p(0, 0)
    local ap = cc.p(0, 0)
    for i, name in ipairs(self.layer_img_list) do
        res_path = string.format("%s/%s", map_res, name)
        if i == 1 then
            pos = cc.p(-80, 0)
        elseif i == 2 then
            pos = cc.p(0, 0)
        elseif i == 3 then
            pos = cc.p(59, 452)
        elseif i == 4 then
            ap = cc.p(0, 1)
            pos = cc.p(0, self.size.height)
        end
        table.insert(self.map_cache, {res = res_path, layer = i, pos = pos, ap = ap})
    end
end

--==============================--
--desc:创建马赛克地图
--time:2017-07-07 10:17:18
--@return 
--==============================--
function CenterCityScene:renderSmallPic()
	local res_jpg = string.format("resource/centerscene/preview/%s_%s.jpg", self.config.res_id, self.cur_time_type)
    -- self.smallPic = createSprite(res_jpg, 0, 10, self.root_wnd, cc.p(0,0), LOADTEXT_TYPE, -1)
    self.smallPic = createSprite(res_jpg, self.size.width * 0.5 - 3, self.size.height * 0.5 + 12 , self.root_wnd, cc.p(0.5,0.5), LOADTEXT_TYPE, -1)
    local size = self.smallPic:getContentSize()
    self.smallPic:setScale(self.size.width/size.width, self.size.height/size.height)
end

--==============================--
--desc:切换场景的时候,保存一下当前场景的位置,下一次进来的时候定位到这个位置
--time:2017-07-07 09:54:03
--@return 
--==============================--
function CenterCityScene:__delete()
    self:setScheduleUpdate(false)
    self:showSceneEffectById(false)
    for i=1, self.layer_num do
        doStopAllActions(self["map_layer"..i])
    end
    doStopAllActions(self.root_wnd)
    if self.scene_load then
        self.scene_load:DeleteMe()
        self.scene_load = nil
    end

    if self.wait_create_build_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.wait_create_build_event)
        self.wait_create_build_event = nil
    end
    for k,item in pairs(self.build_list) do
        if item.DeleteMe then
            item:DeleteMe()
        end
    end
    self.build_list = {}

    if not tolua.isnull(self.root) then
		self.root:removeAllChildren()
		self.root:removeFromParent()
	end
end

--==============================--
--desc:场景计时器
--time:2017-07-07 01:40:24
--@return 
--==============================--
function CenterCityScene:setScheduleUpdate(status)
    if status == true then
        if self.queue_timer == nil then
            self.queue_timer = GlobalTimeTicket:getInstance():add(function() 
                self:update()
            end, 1/display.DEFAULT_FPS)
        end
    else
        if self.queue_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.queue_timer)
            self.queue_timer = nil
        end
    end
end

--==============================--
--desc:每一帧循环的函数
--time:2017-07-07 01:44:16
--@dt:
--@return 
--==============================--
function CenterCityScene:update( dt )
	self.step = self.step + 1
    -- 异步创建地图
    if self.step % 3 == 0 then
        self:quequeAddMap()
    end
    -- 创建场景特效
    if self.step > 10 then
        self:quequeCreateEffect()
    end

    -- 定时移除,如果是战斗中,不处理,免得造成卡顿
    if self.step % self.rem_spine_interval == 0 then
        if BattleController:getInstance():isInFight() == false then
            display.removeUnusedTextures()
            -- collectgarbage("collect")
            self.step = 1
        end

        if self.is_save_logindata == false then
            self.is_save_logindata = true
            LoginController:getInstance():getModel():saveLoginDataToLocal()
        end
    end
end

--==============================--
--desc:创建指定单位
--time:2017-07-07 01:53:13
--@data:
--@return 
--==============================--
function CenterCityScene:createBuildItem(data)
    if is_city_thumbnail then return end
    if data == nil or data.config == nil then return end
    if self.build_list[data.config.bid] ~= nil then return end
    if MAKELIFEBETTER == true and data.is_verifyios == 0 then return end
    local build_item = BuildItem.New(data, data.config.type)
    build_item:setParentWnd(self["map_layer" .. data.config.layer])
    self.build_list[data.config.bid] = build_item
end

--==============================--
--desc:引导那边需要
--time:2018-06-27 03:09:03
--@id:
--@return 
--==============================--
function CenterCityScene:getBuildById(id)
    return self.build_list[id]
end

--==============================--
--desc:延迟异步加载并创建地图
--time:2017-07-07 03:49:13
--@return 
--==============================--
function CenterCityScene:quequeAddMap()
    if self.map_cache == nil or next(self.map_cache) == nil then 
        return 
    end
    if self.is_in_load == true then return end
    self.is_in_load = true

    local map_info = table.remove( self.map_cache, 1 )
    if map_info ~= nil then
        local format_type = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
        if map_info.layer == 2 or map_info.layer == 3 or EQUIPMENT_QUALITY == 3 then       --第二层或者是高内存手机直接用888
            format_type = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
        end
        cc.Director:getInstance():getTextureCache():addImageAsync(map_info.res, function()
            if self["map_layer"..map_info.layer] then
                local tmp_spr = createSprite(map_info.res, map_info.pos.x, map_info.pos.y, self["map_layer"..map_info.layer], map_info.ap, LOADTEXT_TYPE, -1)
                self.map_resources_list[map_info.layer] = tmp_spr
                if map_info.layer == 4 then
                    if self.cur_time_type == 1 then
                        tmp_spr:setScale(4)
                    else
                        tmp_spr:setScale(1)
                    end
                end
                self.is_in_load = false
                -- 判断是否创建完成了
                if self.map_cache == nil or next(self.map_cache) == nil then 
                    self:createMainMapOver()
                end
            end
        end, format_type)
    end
end

-- 加载完成之后马赛克地图就删掉吧
function CenterCityScene:createMainMapOver()
    if self.smallPic then
        self.smallPic:setVisible(false)
        self.smallPic:removeFromParent()
        self.smallPic = nil
    end
    self.map_create_end = true
end

--==============================--
--desc:改变地图
--time:2018-07-27 05:53:26
--@return 
--==============================--
function CenterCityScene:changeMainSceneMap()
    if USESCENEMAKELIFEBETTER == true then return end
    local map_res = string.format("resource/centerscene/%s/%s", self.config.res_id, self.cur_time_type) 
    for k,v in pairs(self.map_resources_list) do
        local map_sprite =  self.map_resources_list[k]
        if map_sprite then
            local res_path = string.format("%s/%s", map_res, self.layer_img_list[k]) 
            cc.Director:getInstance():getTextureCache():addImageAsync(res_path, function()
                loadSpriteTexture(map_sprite, res_path, LOADTEXT_TYPE)
                if k == 4 then
                    if self.cur_time_type == 1 then
                        map_sprite:setScale(4)
                    else
                        map_sprite:setScale(1)
                    end
                end
            end, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        end
    end
end

--==============================--
--desc:任务追踪那边,可能会触发点击,移动到指定的建筑,实际上就是如果该建筑不在主窗体内,则移动,否则不需要
--time:2017-06-12 09:25:58
--@build_item:
--@show_figer:这次移动是否需要显示手指
--@delay:移过去的事件
--return 
--==============================--
function CenterCityScene:movoToBuildPos(build_bid, show_figer, delay)
    local build_item = self.build_list[build_bid]
    if build_item == nil then return end
    local build_node = build_item:getNode()
    if tolua.isnull(build_node) then return end
    if self.is_moving_scene == true then return end
    self.is_moving_scene = true
    if show_figer == nil then show_figer = true end
    delay = delay or 1

    local world_pos = build_node:convertToWorldSpace(cc.p(0, 0))
    local size = build_item:getContentSize()

    local off_x = 0
    local space = 250   -- 预留多出100像素,避免被右边图标挡住
    if (world_pos.x < SCREEN_WIDTH - size.width - space) and (world_pos.x > size.width + space) then
        off_x = self.root_wnd:getPositionX()
    else
        off_x = SCREEN_WIDTH - world_pos.x - size.width - space + self.root_wnd:getPositionX()
    end
    
    -- 这个时候直接出提示手指
    if off_x == self.root_wnd:getPositionX() then 
        self.is_moving_scene = false
        self:showFingerTips(build_item, show_figer)
        return 
    end
    
    local target_x = self:scaleCheckPoint(off_x)
    if target_x == self.root_wnd:getPositionX() then 
        self.is_moving_scene = false
        self:showFingerTips(build_item, show_figer)
        return 
    end

    -- 修正之后的目标位置
    local root_move_to = cc.MoveTo:create(delay, cc.p(target_x, self.init_y))
    local call_fun = cc.CallFunc:create(function()
        self.is_moving_scene = false
        self:showFingerTips(build_item, show_figer)
    end)

    for i=1, self.layer_num do
        if self["map_layer"..i] then
                local move_to = cc.MoveTo:create(delay, cc.p((target_x-self.init_x)*self["map_layer"..i].speed, 0))
            self["map_layer"..i]:runAction(cc.EaseSineOut:create(move_to))
        end
    end
    local ease_out = cc.EaseSineOut:create(root_move_to)
    self.root_wnd:runAction(cc.Sequence:create(ease_out, call_fun))
end

--==============================--
--desc:在指定对象上面显示一个指示手指,存在3秒钟吧
--time:2017-06-12 12:55:27
--@obj:
--return 
--==============================--
function CenterCityScene:showFingerTips(obj, show_figer)
    if show_figer == false then return end
    if obj == nil then return end
    obj:showFingerTips()
end

--==============================--
--desc:提审服需要的东西
--time:2017-10-26 02:34:04
--@w:
--@h:
--@return 
--==============================--
function CenterCityScene:renderMapPicByVerify(w, h)
    if self.verifyios_bg then
        local map_res = string.format("resource/centerscene/%s.jpg", self.config.res_id)
        loadSpriteTexture(self.verifyios_bg, map_res, LOADTEXT_TYPE) 
    end
end

--==============================--
--desc:改变当前场景的一些特效
--time:2018-07-30 09:12:46
--@return 
--==============================--
function CenterCityScene:changeSceneEffect()
    if USESCENEMAKELIFEBETTER == true then return end      -- 提审包直接不创建场景特效
    self.effect_render_list = {}
    for k, effect_item in pairs(self.effect_list) do
        if effect_item.data and effect_item.data.dun_id and effect_item.data.dun_id ~= 0 then
            effect_item:DeleteMe()
            self.effect_list[k] = nil
        end
    end
    self:analysisEffect() 
end

--==============================--
--desc:解析特效数据
--time:2018-07-27 06:37:22
--@return 
--==============================--
function CenterCityScene:analysisEffect()
    self.effect_render_list = {}
    if self.config ~= nil and self.config.building_list ~= nil then
        for i, v in ipairs(self.config.building_list) do
            if v.dun_id == 0 or self.cur_time_type == v.dun_id then
                if v.type ~= BuildItemType.build then
                    if self.effect_list[v.bid] == nil then
                        table_insert(self.effect_render_list, v)
                    end
                end
            end
        end
    end
    -- 从前进层往后创建,越小id越往后
    if #self.effect_render_list then
        local sort_func = SortTools.tableLowerSorter({"layer", "bid"})
        table.sort(self.effect_render_list, sort_func) 
    end
end

--==============================--
--desc:创建特效
--time:2018-07-27 06:37:13
--@return 
--==============================--
function CenterCityScene:quequeCreateEffect()
    if USESCENEMAKELIFEBETTER == true then return end
    if is_city_thumbnail then return end
    if self.effect_render_list == nil or next(self.effect_render_list) == nil then return end
    if self.map_create_end == true then
        local effect_config = table_remove(self.effect_render_list, 1)
        if effect_config ~= nil then
            if self.effect_list[effect_config.bid] ~= nil then return end
            local js_path, atlas_path, png_path = PathTool.getSpineByName(effect_config.res) 
            local pf = getPixelFormat(effect_config.res)
            cc.Director:getInstance():getTextureCache():addImageAsync(png_path, function() 
                local build_item = BuildItem.New(effect_config, effect_config.type)
                build_item:setParentWnd(self["map_layer" .. effect_config.layer])
                self.effect_list[effect_config.bid] = build_item
            end, pf)
        end
    end
end

--==============================--
--desc:获取当前场景的时间类型
--time:2018-07-30 09:39:07
--@return 
--==============================--
function CenterCityScene:getCurTimeType()
    return self.cur_time_type
end

--==============================--
--desc:监听一些事件
--time:2017-07-07 09:51:41
--@return 
--==============================--
function CenterCityScene:registerEvent()
	local function onTouchBegin(touch, event)
		if GuideController:getInstance():isInGuide() == true then
			return false
		end
		
		-- 如果使用提审资源的话
		if USESCENEMAKELIFEBETTER == true then
			return false
		end
		
		-- 只在范围以内曹做移动
		if self.screenSize == nil then
			local pos = self.root:convertToWorldSpace(cc.p(0, 0))
			self.screenSize = cc.rect(pos.x, pos.y + 100, SCREEN_WIDTH, SCREEN_HEIGHT - 100)
		end
		local pos = cc.p(touch:getLocation().x, touch:getLocation().y)
		if not cc.rectContainsPoint(self.screenSize, pos) then
			return false
		end
		
		self.last_point = nil
		for i = 1, self.layer_num do
			doStopAllActions(self["map_layer" .. i])
		end
		self.is_moving_scene = false
		doStopAllActions(self.root_wnd)
		return true
	end
	
	local function onTouchMoved(touch, event)
		self.last_point = touch:getDelta()
		self:moveMainScene(self.last_point.x)
	end
	
	local function onTouchEnded(touch, event)
		if self.last_point == nil then return end
		local interval_x = self.last_point.x * 3
		
		local temp_x = self.root_wnd:getPositionX() + interval_x
		
		-- 修正之后的目标位置
		local target_x = self:scaleCheckPoint(temp_x)
		
		for i = 1, self.layer_num do
			if self["map_layer" .. i] then
				local move_to = cc.MoveTo:create(1, cc.p((target_x - self.init_x) * self["map_layer" .. i].speed, 0))
				self["map_layer" .. i]:runAction(cc.EaseBackOut:create(move_to))
			end
		end
		
		local root_move_to = cc.MoveTo:create(1, cc.p(target_x, self.init_y))
		local ease_out = cc.EaseBackOut:create(root_move_to)
		self.root_wnd:runAction(cc.Sequence:create(ease_out))
	end
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	self.root:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.root)
end 

-- 主城烟花特效
function CenterCityScene:showSceneEffectById( status, id, action, num )
    -- 标识是否为玩家自己燃放烟花（是的话要先播完特效再请求燃放烟花）
    if num then
        self.petard_self_num = num
    else
        self.petard_self_num = self.petard_self_num or 0
    end
    if self.is_show_effect then return end
    if status == true and id and Config.EffectData.data_effect_info[id] then
        self.is_show_effect = true
        playOtherSound("c_petard")
        
        if self.scene_effect and self.cur_effect_id and self.cur_effect_id ~= id then
            self.scene_effect:clearTracks()
            self.scene_effect:removeFromParent()
            self.scene_effect = nil
        end
        action = action or PlayerAction.action
        if not tolua.isnull(self.effect_layer) and self.scene_effect == nil then
            self.scene_effect = createEffectSpine(Config.EffectData.data_effect_info[id], cc.p(self.size.width*0.5, self.size.height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self.onPetardEffectEnd))
            self.effect_layer:addChild(self.scene_effect)
        elseif self.scene_effect then
            self.scene_effect:setToSetupPose()
            self.scene_effect:setAnimation(0, action, false)
        end
        self.cur_effect_id = id
    else
        self.is_show_effect = false
        if self.scene_effect then
            self.scene_effect:clearTracks()
            self.scene_effect:removeFromParent()
            self.scene_effect = nil
        end
    end
end

-- 烟花特效结束
function CenterCityScene:onPetardEffectEnd(  )
    local cd_time = 0
    local firework_cd_cfg = Config.HolidayPetardData.data_const["firework_cd"]
    if firework_cd_cfg then
        cd_time = firework_cd_cfg.val
    end
    -- 两个烟花之间的特效时间
    delayRun(self.effect_layer, cd_time, function (  )
        self.is_show_effect = false
    end)

    -- 自己燃放烟花时，等烟花特效结束后再发送请求
    local firework_bid_cfg = Config.HolidayPetardData.data_const["firework_bid"]
    if self.petard_self_num and self.petard_self_num > 0 and firework_bid_cfg then
        PetardActionController:getInstance():sender27001(firework_bid_cfg.val, self.petard_self_num)
        self.petard_self_num = 0
    end
end

-- 主城移到中间的位置
function CenterCityScene:moveToCenterPos(  )
    local pos_x = ( SCREEN_WIDTH - self.size.width ) * 0.5
    local pos_y = ( SCREEN_HEIGHT - self.size.height ) * 0.5
    self:updateMainScene(pos_x, pos_y)
end