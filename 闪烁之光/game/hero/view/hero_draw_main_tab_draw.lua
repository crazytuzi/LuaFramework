-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄形象
-- <br/> 2019年12月4日
-- --------------------------------------------------------------------
HeroDrawMainTabDraw = class("HeroDrawMainTabDraw", function()
    return ccui.Widget:create()
end)

local controller = HeroController:getInstance()
local string_format = string.format
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort

function HeroDrawMainTabDraw:ctor(parent) 
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroDrawMainTabDraw:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.can_click_btn = true
    self.is_show_attr = true
end

function HeroDrawMainTabDraw:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_draw_main_tab_draw")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    
    self.bottom_lay = self.main_container:getChildByName("bottom_lay")

    local bottom_y = display.getBottom(self.main_container)
    local y = self.bottom_lay:getPositionY()
    self.bottom_lay_y = bottom_y + y
    self.bottom_lay:setPositionY(self.bottom_lay_y)

    self.ext_panel = self.bottom_lay:getChildByName("ext_panel")
    --皮肤信息
    self.skin_panel = self.ext_panel:getChildByName("skin_panel")
    self.skin_panel:setVisible(true)
    self.skin_show_btn = self.skin_panel:getChildByName("show_btn")
    self.show_btn_icon = self.skin_show_btn:getChildByName("icon")
    self.model_bg = self.skin_panel:getChildByName("bg")
    self.model_node = self.skin_panel:getChildByName("model_node")
    self.comfirm_btn = self.skin_panel:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("应用"))



    local time_key = self.skin_panel:getChildByName("time_key")
    time_key:setString(TI18N("有效时间:"))
    self.attr_key = self.skin_panel:getChildByName("attr_key")
    self.attr_key:setString(TI18N("属性加成:"))

    --时间
    self.time_val = self.skin_panel:getChildByName("time_val")
    self.attr_item_list = {}


    self.vedio_panel = self.ext_panel:getChildByName("vedio_panel")
    self.vedio_show_btn = self.vedio_panel:getChildByName("show_btn")
    self.cv_name = self.vedio_panel:getChildByName("cv_name")
    self.cv_name:setString("")
    self.content_scrollview = self.vedio_panel:getChildByName("content_scrollview")
    self.content_scrollview_size = self.content_scrollview:getContentSize()

    --语音
    self.btn_panel = self.bottom_lay:getChildByName("btn_panel")
   
    self.skin_btn = self.btn_panel:getChildByName("skin_btn")
    self.vedio_btn = self.btn_panel:getChildByName("vedio_btn")
    self.skin_btn:getChildByName("label"):setString(TI18N("皮\n肤"))
    self.vedio_btn:getChildByName("label"):setString(TI18N("语\n音"))


    --收起
    self.back_btn = self.bottom_lay:getChildByName("back_btn")
    self.back_btn:getChildByName("label"):setString(TI18N("收起"))

    self.skin_shop_btn = self.bottom_lay:getChildByName("skin_shop_btn")
    self.skin_shop_btn:getChildByName("label"):setString(TI18N("时装商店"))
    self:checkSkinShopBtnStatus()
    self.lay_scrollview1 = self.bottom_lay:getChildByName("lay_scrollview1")
    self.lay_scrollview2 = self.bottom_lay:getChildByName("lay_scrollview2")

    --初始化位置
    self.bottom_lay:setPositionX(720)

    --图鉴特殊处理
    if  self.parent and self.parent.hero_vo and self.parent.hero_vo.is_pokedex then
        self.btn_bg = self.btn_panel:getChildByName("btn_bg")
        self.common_1016 = self.btn_panel:getChildByName("common_1016")
        self.btn_bg:setContentSize(cc.size(150,108))
        self.common_1016:setVisible(false)
        self.skin_btn:setVisible(false)
        self.skin_btn:setTouchEnabled(false)
    end
end

--事件
function HeroDrawMainTabDraw:registerEvents()
    --详情
    registerButtonEventListener(self.vedio_btn, function() self:onClickVedioBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.skin_btn, function() self:onClickSkinBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.skin_show_btn, function() self:onClickSkinShowBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.vedio_show_btn, function() self:onClickVedioShowBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.back_btn, function() self:onClickBackBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.skin_shop_btn, function() self:onClickSkinShopBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    if self.hero_skin_info_event == nil then
        self.hero_skin_info_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Skin_Info_Event, function(hero_vo)
            if not self.select_skin_index then return end
            if not self.skin_data_list then return end
            for i,v in ipairs(self.skin_data_list) do
                if model:isUnlockHeroSkin(v.skin_id) then
                    v.is_lock = false
                else
                    v.is_lock = true
                end
            end
            if self.use_skin_index ~= nil then
                if self.hero_vo then
                    self.hero_vo.use_skin = self.skin_data_list[self.use_skin_index].skin_id or 0
                end
                self.must_update = true
                self.select_skin_index = 2
                self:updateSkinList(self.use_skin_index)
                self.use_skin_index = nil
            else
                self:updateSkinList(self.select_skin_index)
            end
        end)
    end  

    if self.hero_skin_used_event == nil then
        self.hero_skin_used_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Skin_Used_Event, function(hero_vo)
            if not self.select_skin_index then return end
            if not self.skin_data_list then return end
            self:updateSkinList(self.select_skin_index)
        end)
    end

     if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
            if key == "lev" then 
                self:checkSkinShopBtnStatus()
            end
        end)
    end
end

--确定选择当前皮肤做作为显示皮肤
function HeroDrawMainTabDraw:onComfirmBtn()
    if not self.hero_vo then return end
    if not self.skin_data_list then return end
    if not self.parent then return end

    local skin_data = self.skin_data_list[self.select_skin_index]
    if skin_data and skin_data.is_skin_data then
        --换成其他皮肤
        if self.hero_vo.use_skin ~= skin_data.skin_id then
            controller:sender11019(self.hero_vo.partner_id, skin_data.skin_id)
        end
    else
        if self.hero_vo.use_skin ~= 0 then
            --换回原来皮肤
            controller:sender11019(self.hero_vo.partner_id, 0)
        end
    end
    -- self.parent:onClickBtnClose()
end

function HeroDrawMainTabDraw:checkSkinShopBtnStatus(  )
    if not self.role_vo then return end
    local limit_cfg = Config.ChargeMallData.data_const["skin_mall_lev"]
    if limit_cfg and limit_cfg.val > self.role_vo.lev then
        --需要置灰
        setChildUnEnabled(true, self.skin_shop_btn)
    else
        setChildUnEnabled(false, self.skin_shop_btn)
    end
end

function HeroDrawMainTabDraw:onClickSkinShopBtn()
    if not self.role_vo then return end
    local limit_cfg = Config.ChargeMallData.data_const["skin_mall_lev"]
    if limit_cfg and limit_cfg.val > self.role_vo.lev then
        message(limit_cfg.desc)
        return
    end

    MallController:getInstance():openSkinShopWindow(true)
end

--语音
function HeroDrawMainTabDraw:onClickVedioBtn()
    self.bottom_lay:setPositionX(720)
    local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(0, self.bottom_lay_y)))
    self.bottom_lay:runAction(moveto)

    self.skin_shop_btn:setVisible(false)
    self.skin_panel:setVisible(false)
    self.lay_scrollview1:setVisible(false)
    self.vedio_panel:setVisible(true)
    self.lay_scrollview2:setVisible(true)
    self:initVedioInfo()
end
--皮肤
function HeroDrawMainTabDraw:onClickSkinBtn()
    self.bottom_lay:setPositionX(720)
    local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(0, self.bottom_lay_y)))
    self.bottom_lay:runAction(moveto)

    self.skin_shop_btn:setVisible(true)
    self.skin_panel:setVisible(true)
    self.lay_scrollview1:setVisible(true)
    self.vedio_panel:setVisible(false)
    self.lay_scrollview2:setVisible(false)
    if self.is_show_attr then
        self:onClickSkinShowBtn()
    end 
    self:initSkinInfo()
end
--收起
function HeroDrawMainTabDraw:onClickBackBtn()
    self.bottom_lay:setPositionX(0)
    local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(720, self.bottom_lay_y))) 
    -- local fadeIn = cc.FadeIn:create(0.25)
    -- local spawn_action = cc.Spawn:create(moveto, fadeIn)
    self.bottom_lay:runAction(moveto)
end

function HeroDrawMainTabDraw:hideAllBottom(is_hide)
    if is_hide then
        self.skin_btn:setTouchEnabled(false)
        self.vedio_btn:setTouchEnabled(false)
        -- self.bottom_lay:setPositionX(720)
        local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(800, self.bottom_lay_y))) 
        self.bottom_lay:runAction(moveto)
    else
        self.bottom_lay:setPositionX(800)
        local moveto = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(720, self.bottom_lay_y))) 
        self.bottom_lay:runAction(cc.Sequence:create(moveto, cc.CallFunc:create(function()
            self.skin_btn:setTouchEnabled(true)
            self.vedio_btn:setTouchEnabled(true)
        end)))
    end
end

--播放语音
function HeroDrawMainTabDraw:onClickVedioShowBtn()
    -- body
    if self.select_vedio_data then
        HeroController:getInstance():onPlayHeroVoice(self.select_vedio_data.voice, self.select_vedio_data.voice_time, self.select_vedio_data.pefix)
    end
end

--显示显示
function HeroDrawMainTabDraw:onClickSkinShowBtn()
    if not self.hero_vo then return end

    if self.is_show_attr then
        self.is_show_attr = false
        self.model_bg:setVisible(false)
        self.model_node:setVisible(false)
        -- self:updateHeroInfo(1)
        if self.show_btn_icon then
            self.show_btn_icon:setScale(-1)
        end
    else
        self.is_show_attr = true
        self.model_bg:setVisible(true)
        self.model_node:setVisible(true)
        if self.show_btn_icon then
            self.show_btn_icon:setScale(1)
        end
    end
end

function HeroDrawMainTabDraw:initData()
    if not self.parent then return end
    if not self.parent.hero_vo then return end
    self.hero_vo = self.parent.hero_vo
end

--初始化语音
function HeroDrawMainTabDraw:initVedioInfo( )
    if not self.hero_vo then return end
    if self.init_vedio then return end
    self.init_vedio = true
    self.vedio_data_list = Config.PartnerVoiceData.data_skin_info[self.hero_vo.bid] or {}
    table_sort(self.vedio_data_list, function(a,b) return a.sort_index < b.sort_index end)
    self:updateVedioList()
end

function HeroDrawMainTabDraw:updateVedioList()
    if self.vedio_scroll_view == nil then
        local scroll_view_size = self.lay_scrollview2:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 5,
            start_y = 0,
            space_y = 0,
            item_width = 675,
            item_height = 60,
            row = 1,
            col = 1,
            need_dynamic = true
        }
        self.vedio_scroll_view = CommonScrollViewSingleLayout.new(self.lay_scrollview2, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0.5, 0.5)) 

        self.vedio_scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCellVedio), ScrollViewFuncType.CreateNewCell) --创建cell
        self.vedio_scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsVedio), ScrollViewFuncType.NumberOfCells) --获取数量
        self.vedio_scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexVedio), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.vedio_scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedVedio), ScrollViewFuncType.OnCellTouched) --更新cell
        -- local max_count = math.floor(scroll_view_size.height/list_setting.item_height)
        -- if #self.vedio_scroll_view <= max_count then
        --     self.vedio_scroll_view:setClickEnabled(false)
        -- end
    end
    if #self.vedio_data_list == 0 then
        commonShowEmptyIcon(self.lay_scrollview2, true, {text = TI18N("暂无语音数据")})
    else
        commonShowEmptyIcon(self.lay_scrollview2, false)
    end
    self.is_init_vedio = true
    self.vedio_scroll_view:reloadData(1)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroDrawMainTabDraw:createNewCellVedio(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5,0.5)
    cell:setTouchEnabled(false)
    cell:setPosition(width * 0.5 , height * 0.5)
    width = 650
    height = 53
    local size = cc.size(width, height)
    cell:setContentSize(size)

    cell.bg = createImage(cell, PathTool.getResFrame("herodraw", "hero_draw_22"), width * 0.5, height * 0.5, cc.p(0.5, 0.5), true, nil ,true)
    cell.bg:setContentSize(size)
    -- cell.bg:setScale(0.9)

    cell.name = createLabel(22, cc.c4b(0x64,0x32,0x23,0xff), nil, 40, height * 0.5, TI18N("名字"), cell, nil, cc.p(0, 0.5))

    cell.lay_btn = ccui.Layout:create()
    cell.lay_btn:setAnchorPoint(0.9,0.5)
    cell.lay_btn:setTouchEnabled(true)
    cell.lay_btn:setPosition(width * 0.9 , height * 0.5)
    cell.lay_btn:setContentSize(size)
    cell:addChild(cell.lay_btn)
    cell.use_img = createSprite(PathTool.getResFrame("herodraw", "hero_draw_19"), 590, height * 0.5,cell.lay_btn, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)

    registerButtonEventListener(cell.lay_btn, function() self:onCellTouchedVedio(cell)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    cell.DeleteMe = function()

    end

    return cell
end
--获取数据数量
function HeroDrawMainTabDraw:numberOfCellsVedio()
    if not self.vedio_data_list then return 0 end
    return #self.vedio_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroDrawMainTabDraw:updateCellByIndexVedio(cell, index)
    cell.index = index
    local vedio_data = self.vedio_data_list[index]
    if not vedio_data then return end

    cell.name:setString(vedio_data.name)
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroDrawMainTabDraw:onCellTouchedVedio(cell)
    if not cell.index then return end
    local index = cell.index
    local vedio_data = self.vedio_data_list[index]
    if not vedio_data then return end
    self.select_vedio_data = vedio_data
    if self.vedio_desc == nil then
        self.vedio_desc = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0, 1), cc.p(0,0), 12, nil, self.content_scrollview_size.width)
        self.content_scrollview:addChild(self.vedio_desc)
    end
    self.vedio_desc:setString(vedio_data.content)
    local size = self.vedio_desc:getContentSize()

    local scroll_heigt = math.max(self.content_scrollview_size.height, size.height) 
    self.content_scrollview:setInnerContainerSize(cc.size(self.content_scrollview_size.width, scroll_heigt))
    if size.height < self.content_scrollview_size.height then
        self.content_scrollview:setTouchEnabled(false)
        self.vedio_desc:setPositionY(scroll_heigt - (scroll_heigt - size.height)/2 )
    else
        self.vedio_desc:setPositionY(scroll_heigt)    
    end

    if self.select_vedio_data and not self.is_init_vedio then
        HeroController:getInstance():onPlayHeroVoice(self.select_vedio_data.voice, self.select_vedio_data.voice_time, self.select_vedio_data.pefix)
    end
    
    if vedio_data.cv_name and vedio_data.cv_name ~= "" then
        self.cv_name:setString(vedio_data.cv_name)
    else
        self.cv_name:setString("")
    end
    self.is_init_vedio = false
end

--初始化皮肤
function HeroDrawMainTabDraw:initSkinInfo()
    if not self.hero_vo then return end
    if self.init_skin then return end
    self.init_skin = true
    local bid_config = Config.PartnerSkinData.data_partner_bid_info[self.hero_vo.bid] or {}
    --皮肤数据
    self.skin_data_list = {}
    for skin_id,v in pairs(bid_config) do
        local data = {}
        data.is_skin_data = true -- 表示是皮肤数据
        
        if model:isUnlockHeroSkin(v.skin_id) then
            data.is_lock = false
        else
            data.is_lock = true
        end
        data.skin_id = skin_id
        data.config = Config.PartnerSkinData.data_skin_info[v.skin_id]
        table_insert(self.skin_data_list, data)
    end
    table_sort(self.skin_data_list, function(a, b) return a.skin_id <b.skin_id end)
    --第一个肯定是本体
    table_insert(self.skin_data_list, 1, self.hero_vo)
    local select_index = 1
    local use_skin = self.hero_vo.use_skin or 0
    if use_skin ~= 0 then
        for i,v in ipairs(self.skin_data_list) do
            if v.skin_id == use_skin then
                select_index = i
            end
        end
    end
    
    self:updateSkinList(select_index)
end

function HeroDrawMainTabDraw:updateSkinList(select_index)
    if self.skin_scroll_view == nil then
        local scroll_view_size = self.lay_scrollview1:getContentSize()
        local list_setting = {
            start_x = 10,
            space_x = 5,
            start_y = 0,
            space_y = 0,
            item_width = 186,
            item_height = 293,
            row = 1,
            col = 1,
            need_dynamic = true
        }
        self.skin_scroll_view = CommonScrollViewSingleLayout.new(self.lay_scrollview1, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.skin_scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.skin_scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.skin_scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.skin_scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
        local max_count = math.floor(scroll_view_size.width/list_setting.item_width)
        if #self.skin_data_list < max_count then
            self.skin_scroll_view:setClickEnabled(false)
        end
    end
    local select_index = select_index or 1
    self.skin_scroll_view:reloadData(select_index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroDrawMainTabDraw:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5,0.5)
    cell:setTouchEnabled(true)
    local size = cc.size(width, height)
    cell:setContentSize(size)

    cell.hero_icon = createSprite(nil, width * 0.5, height * 0.5,cell, cc.p(0.5, 0.5))
    cell.hero_icon:setScale(0.54)
    cell.bg = createImage(cell, PathTool.getResFrame("herodraw", "hero_draw_28"), width * 0.5, height * 0.5, cc.p(0.5, 0.5), true, nil ,true)
    cell.bg:setContentSize(size)
    -- cell.bg:setScale(0.9)

    cell.name = createLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.c4b(0,0,0,0), width * 0.5, 24, TI18N("名字"), cell, 2, cc.p(0.5, 0.5))

    cell.lock_label = createLabel(24, cc.c4b(0xff,0xff,0xff,0xff), cc.c4b(0x1b,0x4a,0x72,0xff), width * 0.5, height * 0.5, TI18N("未解锁"), cell, 2, cc.p(0.5, 0.5))
    cell.lock_label:setVisible(false)


    local res = PathTool.getResFrame("common", "common_90019")
    cell.select_bg = createImage(cell, res, width * 0.5, height * 0.5, cc.p(0.5,0.5), true,nil,true)
    cell.select_bg:setContentSize(size)

    cell.use_img = createSprite(PathTool.getResFrame("herodraw", "txt_cn_hero_draw_26"), 36, 274,cell, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    cell.use_img:setVisible(false)

    registerButtonEventListener(cell, function() self:onCellTouched(cell)  end ,false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    cell.DeleteMe = function()
        if cell.item_load then 
            cell.item_load:DeleteMe()
            cell.item_load = nil
        end
    end

    return cell
end
--获取数据数量
function HeroDrawMainTabDraw:numberOfCells()
    if not self.skin_data_list then return 0 end
    return #self.skin_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroDrawMainTabDraw:updateCellByIndex(cell, index)
    cell.index = index
    local skin_data = self.skin_data_list[index]
    if not skin_data then return end
    local config = skin_data
    --heroicon head_card_id is_skin_data
    local res_id 
    local name 
    if skin_data.is_skin_data then
        res_id = skin_data.config.head_card_id
        name = skin_data.config.skin_name
    else
        res_id = skin_data.bid
        name = skin_data.name
    end
    if cell.record_res_id == nil or cell.record_res_id ~= res_id then
        cell.record_res_id = res_id
        local res = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" ..res_id)
        cell.item_load = loadSpriteTextureFromCDN(cell.hero_icon, res, ResourcesType.single, cell.item_load, 60,function()
            if skin_data.is_skin_data and skin_data.is_lock then
                setChildUnEnabled(true, cell.hero_icon)
            end
        end)
    end

    --结束
    if skin_data.is_skin_data and skin_data.is_lock then
        cell.name:setVisible(false)
        cell.select_bg:setVisible(false)
        cell.use_img:setVisible(false)
        cell.lock_label:setVisible(true)


        setChildUnEnabled(true, cell.bg)
        setChildUnEnabled(true, cell.hero_icon)
    else
        cell.name:setVisible(true)
        cell.lock_label:setVisible(false)

        setChildUnEnabled(false, cell.bg)
        setChildUnEnabled(false, cell.hero_icon)
        if self.hero_vo.use_skin == 0 and index == 1 then
            cell.use_img:setVisible(true)    
        elseif self.parent.hero_vo.use_skin == skin_data.skin_id then
            cell.use_img:setVisible(true)
        else
            cell.use_img:setVisible(false)
        end

        cell.name:setString(name or "")
        if self.select_skin_index and self.select_skin_index == index then
            cell.select_bg:setVisible(true)
        else
            cell.select_bg:setVisible(false)
        end
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroDrawMainTabDraw:onCellTouched(cell)
    if not self.can_click_btn then return end
    if not cell.index then return end
    local index = cell.index
    local skin_data = self.skin_data_list[index]
    if not skin_data then return end

    if skin_data.is_skin_data then
        if skin_data.is_lock then
            self:setLockInfo(skin_data, index)
            return
        end
    end

    if self.select_cell ~= nil then
        self.select_cell.select_bg:setVisible(false)
    end

    self.select_cell = cell
    self.select_cell.select_bg:setVisible(true)

    self:updateSelectSkinInfo( index)
end

--更新选中的皮肤信息
function HeroDrawMainTabDraw:updateSelectSkinInfo(index)
    if not self.must_update and self.select_skin_index and self.select_skin_index == index then return end
    self.must_update = nil
    self.select_skin_index = index
    local skin_data = self.skin_data_list[self.select_skin_index]

    if skin_data.is_skin_data then
        --皮肤对象
        self.skin_config = skin_data.config
        self:updateAttrInfo()
    else
        --英雄对象
        self.skin_config = Config.PartnerData.data_partner_library(skin_data.bid)
        self:updateAttrInfo()
    end

    if self.parent then
        self.parent:initHeroDraw(self.skin_config.skin_id or 0)
    end
    self:updateHeroInfo(2)
end

function HeroDrawMainTabDraw:setLockInfo(skin_data, index)
    local dic_item_id = {}
    for i,id in ipairs(skin_data.config.item_id_list) do
        dic_item_id[id] = true
    end

    local have_item = nil
    local have_list = {}
    local list = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.BACKPACK) or {}
    for i,item in pairs(list) do
        if item.config and dic_item_id[item.config.id] then
            --背包上有道具
            local data = {}
            
            if item.config.client_effect[1] and item.config.client_effect[1][2] then
                data.time = item.config.client_effect[1][2]
            else
                data.time = 1
            end
            if data.time == 0 then
                --表示有永久的皮肤 
                have_item = item
                break
            end
            data.item_info = item
            table_insert(have_list, data)
        end
    end
    if have_item then
        --表示有永久的皮肤 
        self:useSkinItemByID(have_item, index)
        return
    end
    if #have_list > 0 then
        table.sort(have_list, function(a, b) return a.time > b.time end)
        self:useSkinItemByID(have_list[1].item_info, index)
    else
        --判断是否有活动id 有直接跳转
        if self:checkValidActionTime(skin_data.config) then
            self:gotoSkinAction(skin_data.config)
            return
        end

        --说明该皮肤不能同商城获取
        if skin_data.config.is_shop == 0 then
            message(TI18N("暂未获取此皮肤，请前往相关活动或玩法中获取！"))
        else
            self:gotoSkinAction(skin_data.config)
        end

    end
end

--使用皮肤道具
function HeroDrawMainTabDraw:useSkinItemByID(have_item, index)
    if have_item.config then
        local color = BackPackConst.getWhiteQualityColorStr(have_item.config.quality)
        local str = string_format(TI18N("已拥有解锁道具,是否消耗<div fontcolor=#%s>%s</div>解锁该皮肤？"), color, have_item.config.name)
        local callback = function()
            self.use_skin_index = index
            BackpackController:getInstance():sender10515(have_item.id, 1)
        end
        CommonAlert.show(str, TI18N("确定"), callback, TI18N("取消"),nil, CommonAlert.type.rich, nil, {title = TI18N("解锁皮肤")})
    end
end

function HeroDrawMainTabDraw:checkValidActionTime(config)
    if self.is_check_action_time ~= nil then
        return self.is_check_action_time
    end

    self.is_check_action_time = false
    if config and config.action_bid ~= 0 then
        local start_time = 0
        local end_time = 0
        if next(config.action_start_time) ~= nil and next(config.action_end_time) ~= nil then
            local year  = config.action_start_time[1] or 0
            local month = config.action_start_time[2] or 0
            local day   = config.action_start_time[3] or 0
            local hour  = config.action_start_time[4] or 0
            local min   = config.action_start_time[5] or 0
            local sec   = config.action_start_time[6] or 0
            start_time  =  os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}
            year  = config.action_end_time[1] or 0
            month = config.action_end_time[2] or 0
            day   = config.action_end_time[3] or 0
            hour  = config.action_end_time[4] or 0
            min   = config.action_end_time[5] or 0
            sec   = config.action_end_time[6] or 0
            end_time  =  os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}
        end

        if start_time ~= 0 and end_time ~= 0 then
            local cur_time = GameNet:getInstance():getTime()
            if cur_time >= start_time and cur_time <= end_time then
                self.is_check_action_time = true
            end
        else
            self.is_check_action_time = true
        end

        if self.is_check_action_time then
            --是否存在 活动
            self.is_check_action_time = ActionController:getInstance():CheckActionExistByActionBid(config.action_bid)
        end
    end
    return self.is_check_action_time
end

--跳转活动id
function HeroDrawMainTabDraw:gotoSkinAction(config)
    local callback = function()
        if not self.checkValidActionTime then return end
        --优先找皮肤活动
        if self:checkValidActionTime(config) then
            ActionController:getInstance():openActionMainPanel(true, nil, config.action_bid)
            return
        end

        --没有皮肤活动 找活动商城
        local shop_config = Config.ExchangeData.data_shop_list[MallConst.MallType.HeroSkin]
        if shop_config and shop_config.sort ~= 0 then
            MallController:getInstance():openMallPanel(true, MallConst.MallType.HeroSkin)
            return
        end

        --没有活动商城 提示:
        message(TI18N("暂无该皮肤获取途径"))
    end
    
    local str = TI18N("当前暂未拥有该皮肤,是否前往获取？")
    CommonAlert.show(str, TI18N("确定"), callback, TI18N("取消"),nil, nil, nil, {title = TI18N("解锁皮肤")}) 
end


--显示属性
function HeroDrawMainTabDraw:updateAttrInfo()
    if not self.skin_config then return end
    local end_time = model:getHeroSkinInfoBySkinID(self.skin_config.skin_id)
    if end_time then
        if end_time == 0 then
            self.time_val:setString(TI18N("永久"))
            doStopAllActions(self.time_val)
        else
            local time = end_time - GameNet:getInstance():getTime()
            if time <= 0 then 
                self.time_val:setString(TI18N("00:00:00"))    
            else
                commonCountDownTime(self.time_val, time)
            end
        end
    else
        self.time_val:setString(TI18N("永久"))
        doStopAllActions(self.time_val)
    end

    for i,v in ipairs(self.attr_item_list) do
        -- v.bg:setVisible(false)
        v.key_label:setVisible(false)
    end

    if not self.skin_config.skin_attr then
        self.attr_key:setString(TI18N("属性加成:  无"))
        return
    else
        self.attr_key:setString(TI18N("属性加成:"))
    end

    local y = 42
    local width_item = 130
    local offset_x = 0
    local size = cc.size(width_item, 35)

    for i,v in ipairs(self.attr_item_list) do
        -- v.bg:setVisible(false)
        v.key_label:setVisible(false)
    end

    for i,v in ipairs(self.skin_config.skin_attr) do
        local x = 130 + (i - 1) * (width_item + offset_x)
        if self.attr_item_list[i] == nil then
            self.attr_item_list[i] = self:createAttrItem(x, y, size)
        else
            -- self.attr_item_list[i].bg:setVisible(true)
            self.attr_item_list[i].key_label:setVisible(true)
        end

        local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
        -- local attr_str = string.format("<img src='%s' scale=1 /> %s + %s", res, attr_name, attr_val)
        local attr_str = string.format("%s + %s", attr_name, attr_val)
        self.attr_item_list[i].key_label:setString(attr_str)
    end
end

--创建属性item
function HeroDrawMainTabDraw:createAttrItem(x, y, size)
    local item = {}
    -- local size = cc.size(260, 35)
    -- local res = PathTool.getResFrame("hero","partner_skin_03")
    -- item.bg = createImage(self.skin_panel, res, x,y, cc.p(0, 0.5), true, 0, true)
    -- item.bg:setContentSize(size)
    -- item.bg:setOpacity(128)
    -- item.bg:setCapInsets(cc.rect(15, 15, 1, 1))
    item.key_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0, 0.5), cc.p(x  , y), nil, nil, 380)
    self.skin_panel:addChild(item.key_label, 2)
    return item
end

--更新英雄信息
--来源位置 1 表示 按show_btn 的   2 表示 按皮肤头像的
function HeroDrawMainTabDraw:updateHeroInfo(form_type)
    local skin_data = self.skin_data_list[self.select_skin_index]
    local hero_config
    local skin_id = 0
    if skin_data.is_skin_data then
        hero_config = Config.PartnerSkinData.data_hero_info(skin_data.skin_id)
        skin_id = skin_data.config.skin_id
    end
    self:updateSpine(self.hero_vo, skin_id, form_type)
end

--更新模型,也是初始化模型
--@is_refresh  是否需要检测
function HeroDrawMainTabDraw:updateSpine(hero_vo, skin_id, form_type)
    if self.record_skin_id and self.record_skin_id == skin_id then
        return
    end
    self.record_skin_id = skin_id

    local fun = function()    
        if not self.spine then 
            self.spine = BaseRole.new(BaseRole.type.partner, hero_vo, nil, {scale = 0.45, skin_id = skin_id})
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(0,104))
            self.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            -- self.spine:setScale(1)
            self.model_node:addChild(self.spine) 
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            self.spine:showShadowUI(true)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        self.can_click_btn = false
        self.spine:setCascade(true)
        if form_type == 2 then
            local action = cc.FadeOut:create(0.2)
            self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                    doStopAllActions(self.spine)
                    self.spine:removeFromParent()
                    self.spine = nil
                    self.can_click_btn = true
                    fun()
            end)))
        else
            -- form_type == 1 表示是show_btn的 不需要隐藏后再显示..而是直接删除显示
            doStopAllActions(self.spine)
            self.spine:removeFromParent()
            self.spine = nil
            self.can_click_btn = true
            fun()
        end
    else
        fun()
    end
end

function HeroDrawMainTabDraw:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        if not self.is_init then
            self.is_init = true
            self:initData()
        end
    end
end

--移除
function HeroDrawMainTabDraw:DeleteMe()

    doStopAllActions(self.bottom_lay)
    if self.skin_scroll_view then
        self.skin_scroll_view:DeleteMe()
        self.skin_scroll_view = nil
    end
    if self.vedio_scroll_view then
        self.vedio_scroll_view:DeleteMe()
        self.vedio_scroll_view = nil
    end


    if self.hero_skin_info_event then
        GlobalEvent:getInstance():UnBind(self.hero_skin_info_event)
        self.hero_skin_info_event = nil
    end
    if self.hero_skin_used_event then
        GlobalEvent:getInstance():UnBind(self.hero_skin_used_event)
        self.hero_skin_used_event = nil
    end

    if self.role_vo then
        if self.role_lev_event then
            self.role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end

end
