-- --------------------------------------------------------------------
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄图书馆详细信息界面
-- <br/> 2019年1月11日
--
-- --------------------------------------------------------------------
HeroLibraryInfoWindow = HeroLibraryInfoWindow or BaseClass(BaseView)


local controller = HeroController:getInstance()
local table_sort = table.sort
local string_format = string.format
local table_insert = table.insert

function HeroLibraryInfoWindow:__init()
    self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "hero/hero_library_info_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("herolibrary", "herolibrary"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg", true), type = ResourcesType.single}
    }

    --当前选择
    self.select_index = 0

    --最大索引
    self.max_index = 2

    --技能item
    self.skill_item_list = {}

    --奇遇冒险id
    self.encounter_id = 0
end

function HeroLibraryInfoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
     self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero","hero_draw_bg",true), LOADTEXT_TYPE)
    self.background:setScale( display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)  


    self.close_btn = self.main_container:getChildByName("close_btn")

    --名字背景
    self.hero_name_bg = self.main_container:getChildByName("hero_name_bg")
    --英雄立绘
    self.hero_draw_icon = self.main_container:getChildByName("hero_draw_icon")
    --英雄名字
    self.hero_name =  self.hero_name_bg:getChildByName("hero_name")
    self.title_name =  self.hero_name_bg:getChildByName("title_name")
    self.title_bg = self.hero_name_bg:getChildByName("title_bg")

    self.box_6 = self.main_container:getChildByName("box_6")

    -- 详细属性
    self.attr_btn =  self.box_6:getChildByName("attr_btn")
    self.attr_btn:getChildByName("label"):setString(TI18N("详细属性"))
    --查看传记
    self.story_btn =  self.box_6:getChildByName("story_btn")
    self.story_btn:getChildByName("label"):setString(TI18N("查看传记"))

    --分享英雄
    self.share_btn =  self.box_6:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("分享英雄"))
    
    --奇遇图鉴
    self.encounter_btn =  self.box_6:getChildByName("encounter_btn")
    self.encounter_btn:getChildByName("label"):setString(TI18N("物语图鉴"))
    self.encounter_btn:setVisible(false)

    --技能面板
--     self.skill_panel =  self.box_6:getChildByName("skill_panel")

    -- self.attr_name = self.skill_panel:getChildByName("attr_name")
    -- self.type_name = self.skill_panel:getChildByName("type_name")

    -- self.skill_container = self.skill_panel:getChildByName("skill_container")
    -- self.skill_container:setScrollBarEnabled(false)
    -- self.skill_container:setTouchEnabled(false)
    -- self.skill_container_size = self.skill_container:getContentSize()

    --播放声音面板
    -- self.voice_panel =  self.box_6:getChildByName("voice_panel")
    -- self.voice_node = self.voice_panel:getChildByName("voice_node")
    -- self.voice_btn = self.voice_panel:getChildByName("voice_btn")
    -- self.voice_btn:getChildByName("label"):setString(TI18N("播放语音"))
    -- --左右按钮
    -- self.left_btn = self.box_6:getChildByName("left_btn")
    -- self.right_btn = self.box_6:getChildByName("right_btn")


    self:adaptationScreen()

    -- --画页签点
    -- self.point_list = {}
    -- local size = self.box_6:getContentSize()
    -- local pos_x = size.width * 0.5
    -- local pos_y = 35
    -- local point_width = 30 --点的宽度(包括间隔的)
    -- local start_x = pos_x - point_width * self.max_index /2
    -- for i=1, self.max_index do
    --     local res = PathTool.getResFrame("herolibrary","hero_library_13")
    --     createSprite(res, start_x + point_width * 0.5 + ( i - 1) * point_width, pos_y, self.box_6, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    --     local res = PathTool.getResFrame("herolibrary","hero_library_12")
    --     self.point_list[i] = createSprite(res, start_x + point_width * 0.5 + ( i - 1) * point_width, pos_y, self.box_6, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    -- end

end
--设置适配屏幕
function HeroLibraryInfoWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    -- local left_x = display.getLeft(self.main_container)
    -- local right_x = display.getRight(self.main_container)

    local main_container_size = self.main_container:getContentSize()

    --下
    local _, box_6_y = self.box_6:getPosition()
    local content_bottom = box_6_y + bottom_y
    --上
    local _, hero_name_bg_y = self.hero_name_bg:getPosition()
    local content_top =  top_y - (main_container_size.height - hero_name_bg_y)

     self.hero_name_bg:setPositionY(content_top)
     self.box_6:setPositionY(content_bottom)

     self.close_btn:setPositionY(content_top)
    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

function HeroLibraryInfoWindow:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openHeroLibraryInfoWindow(false) end, true, 2)
    
    registerButtonEventListener(self.attr_btn, function() self:onClickAttrBtn() end ,true, 2)
    registerButtonEventListener(self.story_btn, function() self:onClickStoryBtn() end ,true, 2)
    registerButtonEventListener(self.share_btn, function() self:onClickShareBtn() end ,true, 2)
    -- registerButtonEventListener(self.encounter_btn, function() self:onClickEncounterBtn() end ,true, 2)
    -- registerButtonEventListener(self.voice_btn, function() self:onClickVoiceBtn() end ,true, 2)
        
    -- registerButtonEventListener(self.left_btn, handler(self, self.onClickLeftBtn) ,true, 2)
    -- registerButtonEventListener(self.right_btn, handler(self, self.onClickRightBtn) ,true, 2)

    -- 冒险奇遇入口
    -- if self.update_show_encounter_event == nil then
    --     self.update_show_encounter_event = GlobalEvent:getInstance():Bind(EncounterEvent.CHECK_SHOW_LIBRARY_ENCOUNTER, function(list)
    --         if list and list[1] then
    --             self.encounter_id = list[1].id or 0
    --         end
            
    --          if self.encounter_id>0 then
    --             if self.encounter_btn then
    --                 self.encounter_btn:setVisible(true)
    --             end
    --         end
    --     end)
    -- end
end

--详细属性
function HeroLibraryInfoWindow:onClickAttrBtn()
    if not self.partner_config  then return end
    local pokedex_config = Config.PartnerData.data_partner_pokedex[self.partner_config.bid]
    if pokedex_config and pokedex_config[1] then
        local star = pokedex_config[1].star or 1
        controller:openHeroInfoWindowByBidStar(self.partner_config.bid, star)
    end
end
--查看传记
function HeroLibraryInfoWindow:onClickStoryBtn()
    if not self.partner_config or not self.library_config then return end
    if self.library_config.story == nil or self.library_config.story == "" then
        message(TI18N("该英雄暂无传记"))
        return 
    end
    local name = string_format("%s %s",self.library_config.title, self.partner_config.name)
    local content = self.library_config.story
    controller:openHeroLibraryStoryPanel(true, name, content)
end
--分享英雄
function HeroLibraryInfoWindow:onClickShareBtn()
    if not self.partner_config or not self.library_config then return end
    local draw_res = self.partner_config.draw_res
    local name = self.partner_config.name
    if draw_res and draw_res ~= "" then
        controller:openHeroLookDrawWindow(true, draw_res, name, self.partner_config, HeroConst.ShareType.eLibraryInfoShare)
    end
end

--冒险奇遇
-- function HeroLibraryInfoWindow:onClickEncounterBtn()
--     if self.encounter_id >0 then
--         EncounterController:getInstance():openEncounterWindow(true,self.encounter_id)    
--     end
    
-- end

--播放语音
function HeroLibraryInfoWindow:onClickVoiceBtn()
    if not self.partner_config  then return end

    if self.partner_config.voice and self.partner_config.voice ~= "" then
        local voice = self.partner_config.voice 
        local time = self.partner_config.voice_time
        controller:onPlayHeroVoice(voice, time)
    end
end

--左边
function HeroLibraryInfoWindow:onClickLeftBtn()
    self.select_index = self.select_index - 1
    if self.select_index <= 1 then
        self.select_index = 1
    end
    self:setBtnVisable(self.select_index)
    self:showPanelByIndex(self.select_index)
end
--右边
function HeroLibraryInfoWindow:onClickRightBtn()
    self.select_index = self.select_index + 1
    if self.select_index >= self.max_index then
        self.select_index = self.max_index 
    end
    self:setBtnVisable(self.select_index)
    self:showPanelByIndex(self.select_index)
end

function HeroLibraryInfoWindow:setBtnVisable(index)
    if index <= 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(true)
    elseif index >= self.max_index then
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(false)
    else
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(true)
    end
end

-- @bid 伙伴id
function HeroLibraryInfoWindow:openRootWnd(bid, library_config)
    local partner_config = Config.PartnerData.data_partner_base[bid]
    local library_config = Config.PartnerData.data_partner_library(bid)
    if not partner_config or not library_config then return end

    self.partner_config = partner_config
    self.library_config = library_config
    self:updateHeroInfo()
    -- self:setBtnVisable(1)
    -- self:showPanelByIndex(1)

    local size = cc.size(720, 220)
    self.page_view = CustomPageView.new(size, true, true)--, 10, 20,total_page
    self.page_view:setPosition(-10 , 14)
    self.box_6:addChild(self.page_view)
    self.page_view.per_page = 1
    
    local function createPage(data_list, page, layout)
        if page == 1 then
            self:createSkillPanel(layout)
        elseif page == 2 then
            self:createVoicePanel(layout)
        end
    end

    self.page_view:addCreatePageCallBack(createPage)
    local data = {{1},{2}}
    self.page_view:setViewData(data)
    self.page_view:adjustLightPos(10,20,10)
    --请求是否可显示冒险奇遇
    -- EncounterController:getInstance():send27102(bid)
end

--更新英雄信息
function HeroLibraryInfoWindow:updateHeroInfo()
    if not self.partner_config or not self.library_config then return end

    local draw_res_id = self.partner_config.draw_res
    local bg_res = PathTool.getPlistImgForDownLoad("herodraw/herodrawres",draw_res_id, false)
    if self.hero_draw_icon then
        self.item_load = loadSpriteTextureFromCDN(self.hero_draw_icon, bg_res, ResourcesType.single, self.item_load) 
    end
    if self.library_config.scale == 0 then
        self.hero_draw_icon:setScale(1)
    else
        self.hero_draw_icon:setScale(self.library_config.scale/100)
    end
    if self.library_config.draw_offset and next(self.library_config.draw_offset) ~= nil then
        local x, y = self.hero_draw_icon:getPosition()
        local offset_x = self.library_config.draw_offset[1][1] or 0
        local offset_y = self.library_config.draw_offset[1][2] or 0
        self.hero_draw_icon:setPosition(x + offset_x,  y + offset_y) 
    end

    self.hero_name:setString(self.partner_config.name)
    if self.library_config.title and self.library_config.title ~= "" then
        self.title_name:setString(self.library_config.title)
    else
        self.title_bg:setVisible(false)
    end    
end

--创建page
function HeroLibraryInfoWindow:createSkillPanel(layout)
    if not self.partner_config or not self.library_config then return end
    local attr_name_str = string_format("%s：%s%s",TI18N("属性"), tostring(HeroConst.CampAttrName[self.partner_config.camp_type]), tostring(HeroConst.CareerName[self.partner_config.type]))
    createLabel(26, cc.c4b(0x64,0x32,0x23,0xff), nil, 79, 176, attr_name_str, layout)

    local type_name_str = string_format("%s：%s",TI18N("定位"), self.partner_config.hero_pos)
    createLabel(26, cc.c4b(0x64,0x32,0x23,0xff), nil, 442, 176, type_name_str, layout)


    self.skill_container_size = cc.size(580, 130)
    self.skill_container = createScrollView(self.skill_container_size.width, self.skill_container_size.height, 70, 35, layout, ccui.ScrollViewDir.vertical) 
    self.skill_container:setSwallowTouches(false)
    self:initSkill()
end


--创建page
function HeroLibraryInfoWindow:createVoicePanel(layout)
    if not self.partner_config or not self.library_config then return end

    local val = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(70,160), 12, nil, 580)
    layout:addChild(val)
    val:setString(self.library_config.voice_str)
   
    if self.partner_config.voice and self.partner_config.voice ~= "" then
        local btn_layout = ccui.Layout:create()
        btn_layout:setContentSize(cc.size(176,42))
        btn_layout:setAnchorPoint(cc.p(0, 0.5))
        btn_layout:setPosition(497, 35)
        btn_layout:setTouchEnabled(true)
        layout:addChild(btn_layout)
        registerButtonEventListener(btn_layout, function() self:onClickVoiceBtn() end ,true, 2)

        local res = PathTool.getResFrame("herolibrary","hero_library_19")
        createSprite(res, 23, 21, btn_layout, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        
        local res = PathTool.getResFrame("herolibrary","hero_library_20")
        createSprite(res, 82, 9, btn_layout, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        
        createLabel(22, cc.c4b(0xf5,0xf3,0xe9,0xff), cc.c4b(0x46,0x29,0x0a,0xff), 82, 23, TI18N("播放语音"), btn_layout, 2, cc.p(0.5,0.5))
    end
end


function HeroLibraryInfoWindow:showPanelByIndex(index)
    self.select_index = index
    for i=1,self.max_index do
        if index == i then
            self.point_list[i]:setVisible(true)
        else
            self.point_list[i]:setVisible(false)
        end
    end

    if index == 1 then
        self:showSkillPanel(true)
        self:showVoicePanel(false)
    elseif index == 2 then
        self:showSkillPanel(false)
        self:showVoicePanel(true)
    end
end


function HeroLibraryInfoWindow:showSkillPanel(status)
    if status then
        self.skill_panel:setVisible(true)
        if not self.partner_config or not self.library_config then return end
        if self.is_init_skill == nil then
            self.is_init_skill = true
            -- self.attr_name:setString()
            local attr_name_str = string_format("%s：%s%s",TI18N("属性"), tostring(HeroConst.CampAttrName[self.partner_config.camp_type]), tostring(HeroConst.CareerName[self.partner_config.type]))
            self.attr_name:setString(attr_name_str)
            
            local type_name_str = string_format("%s：%s",TI18N("定位"), self.partner_config.hero_pos)
            self.type_name:setString(type_name_str)

            self:initSkill()

        end
    else
        self.skill_panel:setVisible(false)
    end
end

function HeroLibraryInfoWindow:showVoicePanel(status)
    if status then
        self.voice_panel:setVisible(true)
        if not self.partner_config or not self.library_config then return end
        if self.is_init_voice == nil then
            self.is_init_voice = true
            local val = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(0,0), 12, nil, 580)
            self.voice_node:addChild(val)
            val:setString("    "..self.library_config.voice_str)

            if self.partner_config.voice == nil or self.partner_config.voice == "" then
                self.voice_btn:setVisible(false)
            end
        end
    else
        self.voice_panel:setVisible(false)
    end
end

function HeroLibraryInfoWindow:initSkill()
    if not self.partner_config.bid then return end
    local bid = self.partner_config.bid
    local star = Config.PartnerData.data_partner_max_star[bid] or self.partner_config.init_star
    local key = getNorKey(bid, star)
    local star_config = Config.PartnerData.data_partner_star(key)
    if star_config == nil then return end

    local skill_list = {}
    for i,v in ipairs(star_config.skills) do
        -- 不是普通攻击 1表示普通攻击
        if v[1] ~= 1 then
            table_insert(skill_list, v)
        end
    end
    --技能item的宽度
    local skill_width = 108
    local item_width = skill_width + 28
    local total_width = item_width * #skill_list
    local max_width = math.max(self.skill_container_size.width, total_width)
    self.skill_container:setInnerContainerSize(cc.size(max_width, self.skill_container_size.height))

    for i,v in ipairs(self.skill_item_list) do
        v:setVisible(false)
    end
    
    local x = 0
    if total_width > self.skill_container_size.width then
        --技能的总宽度大于 显示的宽度 就从左往右显示
        x = 0
    else
        --否则从中从中间显示
        x = (self.skill_container_size.width - total_width) * 0.5
    end

    for i,skill in ipairs(skill_list) do
        local config = Config.SkillData.data_get_skill(skill[2])
        if config then
            if self.skill_item_list[i] == nil then
                self.skill_item_list[i] = {}
                self.skill_item_list[i] = SkillItem.new(true,true,true,1, true)
                self.skill_item_list[i]:setSwallowTouches(false)
                self.skill_container:addChild(self.skill_item_list[i])
            end
            self.skill_item_list[i]:setData(config)
            -- self.skill_item_list[i]:showUnEnabled(is_lock)
            self.skill_item_list[i]:setVisible(true)
            self.skill_item_list[i]:setPosition( x + item_width * (i - 1) + item_width * 0.5, skill_width/2 + 6)
        else 
            print(string_format("技能表id: %s 没发现", tostring(skill.skill_bid)))
        end
    end
end



function HeroLibraryInfoWindow:close_callback()
    -- EncounterController:getInstance():getModel().finishArr = {}

    if self.hero_music ~= nil then
        AudioManager:getInstance():removeEffectByData(self.hero_music)
    end

    -- if self.update_show_encounter_event then
    --     GlobalEvent:getInstance():UnBind(self.update_show_encounter_event)
    --     self.update_show_encounter_event = nil
    -- end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    self.encounter_id = 0

    controller:openHeroLibraryInfoWindow(false)
end
