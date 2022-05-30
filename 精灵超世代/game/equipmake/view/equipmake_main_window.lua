-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      橙装制作和进阶面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EquipmakeMainWindow = EquipmakeMainWindow or BaseClass(BaseView)

local table_insert = table.insert
local table_remove = table.remove
local string_format = string.format
local controller = EquipmakeController:getInstance()
local backpack_model = BackpackController:getInstance():getModel()
local role_vo = RoleController:getInstance():getRoleVo()

function EquipmakeMainWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "equipmake/equipmake_main_window"
	self.cur_type = 0
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_8"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("hero","hero"), type = ResourcesType.plist}
	}

    self.equip_list = {}
    self.selected_index = 0

    self.fight_container_list = {}
    self.fight_container_pool = {}

    self.attr_container_list = {}
    self.attr_container_pool = {}

    self.arrow_container_list = {}
    self.arrow_container_pool = {}
end 

function EquipmakeMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale(self.root_wnd))

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)

    local main_panel = main_container:getChildByName("main_panel")
    main_panel:getChildByName("win_title"):setString(TI18N("橙装"))
    
    self.close_btn = main_panel:getChildByName("close_btn")

    self.arrow_img = main_panel:getChildByName("arrow_img")
    self.arrow_img:setVisible(false)
    self.center_x = self.arrow_img:getPositionX()
    self.center_y = self.arrow_img:getPositionY()

    self.preview_title = main_panel:getChildByName("preview_title")
    self.preview_title:setString(TI18N("合成预览"))

    self.equipmake_btn = main_panel:getChildByName("equipmake_btn")
    self.equipmake_btn_label = self.equipmake_btn:getChildByName("label")
    self.equipmake_btn_label:setString(TI18N("合成"))

    self.scrollview = main_panel:getChildByName("scrollview")
    self.scrollview_width = self.scrollview:getContentSize().width
    self.scrollview_height = self.scrollview:getContentSize().height

    self.notice_label = main_panel:getChildByName("notice_label")
    self.notice_label:setVisible(false)

    -- 跳转橙装碎片获取连接
    self.source_item = main_panel:getChildByName("source_item")

    self.source_link = createRichLabel(24, 178, cc.p(0, 0), cc.p(0, 0))
    self.source_item:addChild(self.source_link, -1)
    self.source_link:setString(TI18N("<div fontColor=#249003 href=xxx>获取橙装碎片</div>"))

    self.source_tips = self.source_item:getChildByName("tips")

    -- 消耗文本
    self.cost_label = createRichLabel(24, 175, cc.p(0.5, 0.5), cc.p(self.equipmake_btn:getPositionX(), 110), nil, nil, 600)
    main_panel:addChild(self.cost_label)

    self.main_panel = main_panel

    self:createEquipItem()
    self:createBaseEquipItem()
    self:createUpgradeEquipItem()
end

function EquipmakeMainWindow:register_event()
    self.source_item:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openEquipmakeSourcesWindow(true) 
        end
    end) 

    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openEquipmakeMainWindow(false)
        end
    end) 
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openEquipmakeMainWindow(false)
        end
    end)
    self.equipmake_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data == nil or self.selected_index == nil then return end
            if self.cur_show_type == 1 then --这个时候是合成,需要判断背包状况
                if backpack_model:checkEquipsIsFull() == true then
                    local str = TI18N("背包已满,无法合成新的橙装,是否前往熔炼?")
                    local function fun()
                        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.backpack, BackPackConst.item_tab_type.EQUIPS)
                    end
                    CommonAlert.show(str, TI18N("确认"), fun, TI18N("取消"), nil, CommonAlert.type.common, nil, nil, nil, true)
                else
                    controller:requestEquipmake(self.data.partner_id, self.selected_index)
                end
            else
                controller:requestEquipmake(self.data.partner_id, self.selected_index)
            end
        end
    end)

    if self.update_equip_make_event == nil then
        self.update_equip_make_event = GlobalEvent:getInstance():Bind(EquipmakeEvent.UpdateEquipmakeEvent, function(id, type)
            if self.data == nil or self.data.partner_id ~= id then return end
            self:changeCurUpgradeEquip(type) 

            -- 这里再做一波红点计算吧....
            self:checkCanUpgradeStatus()
        end)
    end

    if role_vo then
        if self.role_lev_event == nil then
            self.role_lev_event =  role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                if key == "boss_point" then
                    self:checkCanUpgradeStatus()
                    -- 这个时候强制选中一下自己.因为可能出问题
                    if self.selected_index then
                        self:setSelecteditem(self.selected_index, true)
                    end
                end
            end)
        end
    end

    if self.update_sell_orange_event == nil then
        self.update_sell_orange_event = GlobalEvent:getInstance():Bind(BackpackEvent.Sell_Goods_Success, function() 
            -- 橙装碎片分解来源红点
            self:checkSourceTipsStatus()
        end)
    end
end

--==============================--
--desc:更新当前合成或者进阶的装备
--time:2018-07-27 11:46:54
--@type:
--@return 
--==============================--
function EquipmakeMainWindow:changeCurUpgradeEquip(type)
    if type == nil then return end
    local object = self.equip_list[type]
    if object == nil or object.item == nil then return end
    local list = self.data.eqm_list
    local vo = list[type]
    if vo == nil then return end
    object.item:setData(vo)
    object.vo = vo
    if object.item.empty_icon then
        object.item.empty_icon:setVisible(false)
    end
    -- 如果当前在选中状态下,就强制选中一次
    if self.selected_index == type then
        self:setSelecteditem(self.selected_index, true)
    end
end

--==============================--
--desc:创建这个装备格子
--time:2018-07-26 02:32:35
--@return 
--==============================--
function EquipmakeMainWindow:createEquipItem()
    for i=1,4 do 
        local equip_type = i
        if not self.equip_list[equip_type] then        
            local item = BackPackItem.new(true,true,nil,0.9,false)
            self.main_panel:addChild(item,1)
            local offx = 120 + (i-1)%2*442
            local offy = 418 + math.floor(((i-1)/2)) * 232
            item:setPosition(cc.p(offx,offy))
            -- item:setDefaultTip(true)
            item:addCallBack(function()	
                self:setSelecteditem(i)
            end)
            local res = PathTool.getResFrame("hero","hero_equip_"..equip_type)
            local empty_icon = createImage(item:getRoot(), res,60,60, cc.p(0.5,0.5), true, 10, false)
            item.empty_icon = empty_icon
            local msg = Config.ItemData.data_item_type[i] or ""
            local pos_label = createLabel(24, 175, nil, offx, offy-BackPackItem.Height*0.5-10, msg, self.main_panel,nil, cc.p(0.5, 0.5))

            local object = {}
            object.item = item
            object.vo = nil
            self.equip_list[equip_type] = object 
        end	
    end
end

--==============================--
--desc:创建基础装备
--time:2018-07-26 03:04:45
--@return 
--==============================--
function EquipmakeMainWindow:createBaseEquipItem()
    self.base_x = 244
    self.base_y = 534
    self.base_equip = BackPackItem.new(true,true,nil,1,false)
    self.base_equip:setPosition(self.base_x, self.base_y)
    self.base_equip:setVisible(false)
    self.base_equip:setDefaultTip(true)

    self.base_equip_label = createLabel(24, 175, nil, BackPackItem.Width*0.5, -16, "", self.base_equip:getRoot(),nil, cc.p(0.5, 0.5))
    self.main_panel:addChild(self.base_equip, 2)
end

--==============================--
--desc:创建晋升装备
--time:2018-07-26 03:12:48
--@return 
--==============================--
function EquipmakeMainWindow:createUpgradeEquipItem()
    self.upgrade_equip = BackPackItem.new(true,true,nil,1,false)
    self.upgrade_equip:setPosition(440, 534)
    self.upgrade_equip:setVisible(false)
    self.upgrade_equip:setDefaultTip(true)

    self.upgrade_equip_label = createLabel(24, 175, nil, BackPackItem.Width*0.5, -16, "", self.upgrade_equip:getRoot(),nil, cc.p(0.5, 0.5))
    self.main_panel:addChild(self.upgrade_equip, 2)
end

--==============================--
--desc:移除当前显示的属性和战力相关
--time:2018-07-27 10:52:48
--@return 
--==============================--
function EquipmakeMainWindow:displayShowInfo()
    for i,object in ipairs(self.fight_container_list) do
        object.container:setVisible(false)
        table_insert(self.fight_container_pool, object)
    end 
    self.fight_container_list = {}

    for i, attr_label in ipairs(self.attr_container_list) do
        attr_label:setVisible(false)
        table_insert(self.attr_container_pool, attr_label)
    end
    self.attr_container_list = {}

    for i, arrow in ipairs(self.arrow_container_list) do
        arrow:setVisible(false)
        table_insert(self.arrow_container_pool, arrow)
    end
    self.arrow_container_list = {}

    self.notice_label:setVisible(false)
end

--==============================--
--desc:设置选中
--time:2018-07-26 04:28:52
--@index:
--@force: 是否强制选择,这里更新的时候就是戕害选择
--@return 
--==============================--
function EquipmakeMainWindow:setSelecteditem(index, force)
    if self.data == nil then return end
    if self.selected_index == index and not force then return end
    self.selected_index = index
    self:displayShowInfo()

    if self.selected_item then
        self.selected_item:setSelected(false)
        self.selected_item = nil 
    end
    local object = self.equip_list[index]
    if object then
        self.selected_item = object.item
        self.selected_item:setSelected(true)

        local data = object.vo 
        local show_type = 0        -- 进阶或者合成状态显示,避免跳变设置
        local btn_status_type = 0  -- 按钮状态显示,避免重复设置
        if data == nil then --合成
            show_type = 1
            btn_status_type = 1
        else -- 有装备的时候要判断当前装备是否有下一阶段
            if data.base_id then
                local config = Config.PartnerEqmData.data_eqm_compose_id[data.base_id]
                if config == nil or config.next_id == 0 then --达到上限了
                    show_type = 1
                    btn_status_type = 2
                else
                    show_type = 2
                    btn_status_type = 1
                end
            end
        end
        self:setEquipShowStatus(show_type)
        self:setBtnShowStatus(btn_status_type)
        if show_type == 2 then
            self:setUpgradeStatusInfo(data)
        else
            if data then
                self:setMaxStatusInfo(data) 
            else
                self:setComposeStatusInfo(index) 
            end
        end
    end 
end

--==============================--
--desc:设置中间装备显示状态
--time:2018-07-27 10:15:07
--@show_type:1:只显示当前装备 2:需要显示下一阶装备,标识是进阶
--@return 
--==============================--
function EquipmakeMainWindow:setEquipShowStatus(show_type) 
    if self.cur_show_type == show_type then return end
	self.cur_show_type = show_type
	if self.cur_show_type == 2 then
		self.base_equip:setVisible(true)
		self.upgrade_equip:setVisible(true)
		self.arrow_img:setVisible(true)
		self.base_equip:setPosition(self.base_x, self.base_y)
	else
		self.base_equip:setVisible(true)
		self.upgrade_equip:setVisible(false)
		self.arrow_img:setVisible(false)
		self.base_equip:setPosition(self.center_x, self.center_y)
	end
end

--==============================--
--desc:设置按钮点击状态
--time:2018-07-27 10:14:13
--@show_type:1:可以点击 2:达到上限不可点击
--@return 
--==============================--
function EquipmakeMainWindow:setBtnShowStatus(show_type)
    if self.btn_show_type == show_type then return end
    self.btn_show_type = show_type
    if show_type == 1 then
        self.equipmake_btn_label:enableOutline(Config.ColorData.data_color4[177])
        self.equipmake_btn:setTouchEnabled(true)
        setChildUnEnabled(false, self.equipmake_btn)
    else
        self.equipmake_btn_label:disableEffect()
        self.equipmake_btn:setTouchEnabled(false)
        setChildUnEnabled(true, self.equipmake_btn)
    end
end

--==============================--
--desc:设置最大合成状态
--time:2018-07-26 09:54:44
--@data:
--@return 
--==============================--
function EquipmakeMainWindow:setMaxStatusInfo(data)
    if data == nil or data.config == nil then return end
    self.base_equip:setData(data)
    local item_config = data.config
    self.base_equip_label:setString(item_config.name) 
    self.cost_label:setString(TI18N("当前以最高等级"))
    self.equipmake_btn_label:setString(TI18N("合成"))
    self.preview_title:setString(TI18N("合成预览")) 

    self:setOnlyOneStatusAttr(data.score, data:getEquipBaseAttr())
end

--==============================--
--desc:设置合成状态下的数据
--time:2018-07-26 08:51:06
--@index:这个虽然是下表但是也等同于装备类型
--@return 
--==============================--
function EquipmakeMainWindow:setComposeStatusInfo(index)
    if index == nil then return end
    if self.data == nil or tolua.isnull(self.root_wnd) then return end
    local lev = self.data.lev or 0
    local compose_config = nil

    -- 数据异常了
    if compose_config == nil then return end

    self:setCostInfo(compose_config.expend)
    self.equipmake_btn_label:setString(TI18N("合成"))
    self.preview_title:setString(TI18N("合成预览")) 

    local item_config = Config.ItemData.data_get_data(compose_config.id) 
    if item_config == nil then return end

    if self.base_vo == nil then
        self.base_vo = GoodsVo.New(item_config.id)
    end
    self.base_vo:setBaseId(item_config.id)
    self.base_equip:setData(self.base_vo)
    self.base_equip_label:setString(item_config.name)

    -- 如果当前位置是空的,就是只显示一个,如果当前位置有装备,则显示2个
    local base_vo = self.data.eqm_list[index]
    if base_vo == nil then
        self:setOnlyOneStatusAttr(self.base_vo:getEquipBaseScore(), self.base_vo:getEquipBaseAttr())
    else
        self:setUpgradeAttrInfo(base_vo, self.base_vo) 
    end
end

--==============================--
--desc:设置最大等级或者合成状态下的显示
--time:2018-07-27 11:21:45
--@return 
--==============================--
function EquipmakeMainWindow:setOnlyOneStatusAttr(score ,base_attr)
    local fight_object = self:createFightContainer()
    fight_object.container:setVisible(true)
    fight_object.container:setPosition(226, 104)
    fight_object.value:setNum(score) 

    local index = 1
    for i,v in ipairs(base_attr) do
        if v[1] and v[2] then
            local key = v[1]
            local value = v[2]
            local attr_name = Config.AttrData.data_key_to_name[key]
            if attr_name then
                local attr_label = self:createAttrContainer()
                local is_per_attr = PartnerCalculate.isShowPerByStr(key)
                if is_per_attr == true then
                    attr_label:setString(string_format("%s：+%s%s", attr_name, value*0.1, "%"))
                else
                    attr_label:setString(string_format("%s：+%s", attr_name, value))
                end
                local _x = 224
                local _y = 45 - (index - 1) * 39
                attr_label:setVisible(true)
                attr_label:setPosition(_x, _y)
                index = index + 1
            end
        end
    end
end

--==============================--
--desc:设置进阶状态下属性展示
--time:2018-07-27 11:25:39
--@cur_vo:
--@next_vo:
--@return 
--==============================--
function EquipmakeMainWindow:setUpgradeAttrInfo(cur_vo, next_vo)
    if cur_vo == nil or next_vo == nil then return end

    local cur_fight_object = self:createFightContainer()
    cur_fight_object.container:setVisible(true)
    cur_fight_object.container:setPosition(110, 104)
    cur_fight_object.value:setNum(cur_vo.score or 0) 

    local next_fight_object = self:createFightContainer()
    next_fight_object.container:setVisible(true)
    next_fight_object.container:setPosition(370, 104)
    next_fight_object.value:setNum(next_vo:getEquipBaseScore()) 

    local arrow = self:createArrowContainer()
    arrow:setVisible(true)
    arrow:setPosition(self.scrollview_width*0.5, 92)

    local index = 1
    local base_attr = cur_vo:getEquipBaseAttr()
    for i,v in ipairs(base_attr) do
        if v[1] and v[2] then
            local key = v[1]
            local value = v[2]
            local attr_name = Config.AttrData.data_key_to_name[key]
            if attr_name then
                local attr_label = self:createAttrContainer()
                local is_per_attr = PartnerCalculate.isShowPerByStr(key)
                if is_per_attr == true then
                    attr_label:setString(string_format("%s：+%s%s", attr_name, value*0.1, "%"))
                else
                    attr_label:setString(string_format("%s：+%s", attr_name, value))
                end
                local _x = 110
                local _y = 45 - (index - 1) * 39
                attr_label:setVisible(true)
                attr_label:setPosition(_x, _y)

                local arrow = self:createArrowContainer()
                arrow:setVisible(true)
                arrow:setPosition(self.scrollview_width*0.5, _y)

                index = index + 1
            end
        end
    end

    index = 1
    base_attr = next_vo:getEquipBaseAttr()
    for i,v in ipairs(base_attr) do
        if v[1] and v[2] then
            local key = v[1]
            local value = v[2]
            local attr_name = Config.AttrData.data_key_to_name[key]
            if attr_name then
                local attr_label = self:createAttrContainer()
                local is_per_attr = PartnerCalculate.isShowPerByStr(key)
                if is_per_attr == true then
                    attr_label:setString(string_format("%s：+%s%s", attr_name, value*0.1, "%"))
                else
                    attr_label:setString(string_format("%s：+%s", attr_name, value))
                end
                local _x = 370
                local _y = 45 - (index - 1) * 39
                attr_label:setVisible(true)
                attr_label:setPosition(_x, _y)
                index = index + 1
            end
        end
    end
end

--==============================--
--desc:设置进阶状态下的数据
--time:2018-07-26 08:51:53
--@data:
--@return 
--==============================--
function EquipmakeMainWindow:setUpgradeStatusInfo(data)
    if self.data == nil or tolua.isnull(self.root_wnd) then return end
    if data == nil or data.config == nil then return end
    self.base_equip:setData(data)
    local item_config = data.config
    self.base_equip_label:setString(item_config.name) 
    self.equipmake_btn_label:setString(TI18N("进阶"))
    self.preview_title:setString(TI18N("进阶预览")) 

    local base_config = Config.PartnerEqmData.data_eqm_compose_id[data.config.id]
    if base_config == nil or base_config.next_id == 0 or base_config.expend2 == nil then
        message(TI18N("橙装进阶数据异常"))
        return
    end
    local next_config = Config.PartnerEqmData.data_eqm_compose_id[base_config.next_id] 
    if next_config == nil or next_config.expend == nil then
        message(TI18N("橙装进阶下一级属性异常"))
        return
    end

    -- 创建下一阶装备
    if self.next_vo == nil then
        self.next_vo = GoodsVo.New(next_config.id)
    end
    local enchant_score = data.all_score-data.score -- 当前装备的精炼积分
    self.next_vo:setBaseId(next_config.id)
    self.next_vo:setEnchantInfo(data.enchant, data.attr)    -- 把当前属性设置到下一阶里面去
    self.next_vo:setEnchantScore(enchant_score)
    self.upgrade_equip:setData(self.next_vo)
    self.upgrade_equip_label:setString(self.next_vo.config.name)
    -- 设置进阶属性展示
    self:setUpgradeAttrInfo(data, self.next_vo)

    if self.next_vo.config and self.data.lev < self.next_vo.config.lev then
        self.notice_label:setVisible(true)
        self.notice_label:setString(string_format("宝可梦达%s可进阶", self.next_vo.config.lev))
    else
        self.notice_label:setVisible(false)
    end

    -- 计算消耗并设置
    -- local tmp_expend = {}
    -- for _,v in ipairs(next_config.expend) do
    --     if v[1] and v[2] then
    --         local id = v[1]
    --         local value = v[2]
    --         if tmp_expend[id] == nil then
    --             tmp_expend[id] = value
    --         end
    --         for n, m in ipairs(base_config.expend) do
    --             if m[1] and m[2] then
    --                 if id == m[1] then
    --                     tmp_expend[id] = tmp_expend[id] - m[2]
    --                 end
    --             end
    --         end
    --     end
    -- end
    -- local expend = {}
    -- for k,v in pairs(tmp_expend) do
    --     table_insert(expend, {k, v})
    -- end
    self:setCostInfo(base_config.expend2)
end

--==============================--
--desc:创建战力显示部分,这个是做到对象池去的
--time:2018-07-27 10:23:02
--@return 
--==============================--
function EquipmakeMainWindow:createFightContainer()
    local fight_object = nil
    if next(self.fight_container_pool) == nil then
        fight_object = {}
        fight_object.container = ccui.Layout:create()
        fight_object.container:setContentSize(cc.size(150, 30))
        fight_object.container:setAnchorPoint(cc.p(0, 0.5))
        fight_object.container:setPosition(0, 0)
        fight_object.container:setVisible(false)
        -- showLayoutRect(fight_object.container, 166)
        self.scrollview:addChild(fight_object.container)
        fight_object.label = createSprite(PathTool.getResFrame("hero", "txt_cn_hero_icon"),0,0, fight_object.container, cc.p(0, 0), LOADTEXT_TYPE_PLIST)
        fight_object.value = CommonNum.new(23, fight_object.container, 1, 0, cc.p(0, 0))
        fight_object.value:setScale(0.65)
        fight_object.value:setPosition(50, 14)
    else
        fight_object = table_remove(self.fight_container_pool, 1)
    end 
    table_insert(self.fight_container_list, fight_object)       -- 存到当前显示的table中去
    return fight_object
end

--==============================--
--desc:创建属性显示队列
--time:2018-07-27 10:43:29
--@return 
--==============================--
function EquipmakeMainWindow:createAttrContainer()
    local attr_label = nil
    if next(self.attr_container_pool) == nil then
        attr_label = createLabel(24, 175, nil, 0, 0, "", self.scrollview, nil, cc.p(0, 0))
    else
        attr_label = table_remove(self.attr_container_pool, 1)
    end
    table_insert(self.attr_container_list, attr_label)
    return attr_label 
end

--==============================--
--desc:创建建呕吐
--time:2018-07-27 10:57:51
--@return 
--==============================--
function EquipmakeMainWindow:createArrowContainer()
    local arrow = nil
    if next(self.arrow_container_pool) == nil then
        arrow = createSprite(PathTool.getResFrame("common","common_90017"), self.scrollview_width*0.5, 0, self.scrollview, cc.p(0, 0), LOADTEXT_PLIST)
    else
        arrow = table_remove(self.arrow_container_pool, 1)
    end
    table_insert(self.arrow_container_list, arrow)
    return arrow
end

--==============================--
--desc:设置消耗
--time:2018-07-26 09:57:23
--@expend:
--@return 
--==============================--
function EquipmakeMainWindow:setCostInfo(expend)
    expend = expend or {}
    -- 计算消耗
    local cost_desc = ""
    for i,v in ipairs(expend) do
        if v[1] and v[2] then
            local _config = Config.ItemData.data_get_data(v[1])
            if _config then
                local assets = Config.ItemData.data_assets_id2label[v[1]]
                local sum = 0
                if assets ~= nil then -- 资产
                    sum = role_vo[assets]
                else
                    sum = backpack_model:getBackPackItemNumByBid(v[1]) 
                end
                local color = 175
                if sum < v[2] then
                    color = 183
                end
                if cost_desc ~= "" then
                    cost_desc = cost_desc..","
                end
                cost_desc = string_format("%s<img src=%s visible=true scale=0.35 /><div fontColor=%s>%s</div>%s%s", cost_desc, PathTool.getItemRes(_config.icon), tranformC3bTostr(color), sum, "/", v[2])
            end
        end
    end
    self.cost_label:setString(string_format("%s：%s", TI18N("消耗"), cost_desc))
end

function EquipmakeMainWindow:openRootWnd(data)
    self.data = data
    if self.data ~= nil then
        self:updateEquipList()
        -- 默认选中武器
        self:setSelecteditem(1)

        -- 设置红点状态
        self:checkCanUpgradeStatus()

        -- 橙装分解来源红点
        self:checkSourceTipsStatus()
    end
end

--==============================--
--desc:设置装备的基础值
--time:2018-07-26 04:44:45
--@return 
--==============================--
function EquipmakeMainWindow:updateEquipList()
    if not self.equip_list then return end
    for i, object in pairs(self.equip_list) do
    	if object.item then
    		object.item:setData()
    		if object.item.empty_icon then
    			object.item.empty_icon:setVisible(true)
    		end
    	end
    	object.vo = nil
    end
    -- 获取装备列表
    local list = self.data.eqm_list 
    local object = nil
    for i, v in pairs(list) do
    	if v and v.type and v.config and v.config.quality and v.config.quality == BackPackConst.quality.orange then
            object = self.equip_list[v.type]
            if object and object.item then
                object.item:setData(v)
                if object.item.empty_icon then
                    object.item.empty_icon:setVisible(false)
                end
                object.vo = v
            end
    	end
    end
end 

--[[
    @desc: 计算红点状态
    author:{author}
    time:2018-08-13 15:16:44
    @return:
]]
function EquipmakeMainWindow:checkCanUpgradeStatus()
    if self.data == nil then return end
    local lev = self.data.lev
    local _config = Config.ItemData.data_assets_id2label
    local _eqm_config = Config.PartnerEqmData.data_eqm_compose_id
    for index, object in pairs(self.equip_list) do
        local vo = object.vo
        local max_config = nil
        if max_config == nil then
            if object.item then
                object.item:showNoticeTips(false)
            end
        else
            if vo == nil or vo.config == nil then --这个时候直接判断最大的资产够不够
                local can_make = true
                for i,v in ipairs(max_config.expend or {}) do
                    if not self:checkEnough(v[1], v[2]) then
                        can_make = false 
                        break
                    end
                end
                object.item:showNoticeTips(can_make, 1)
            else -- 这个时候找出他的下一级
                local base_config = _eqm_config[vo.config.id]
                if base_config then
                    if base_config.next_id == 0 then
                        object.item:showNoticeTips(false)
                    else
                        local next_config = _eqm_config[base_config.next_id]
                        if next_config.lev > lev then
                            object.item:showNoticeTips(false)
                        else
                            local can_make = true
                            for i,v in ipairs(base_config.expend2 or {}) do
                                if not self:checkEnough(v[1], v[2]) then
                                    can_make = false 
                                    break
                                end
                            end
                            object.item:showNoticeTips(can_make, 2)
                        end
                    end
                end
            end
        end
    end
end

--[[
    @desc: 判断资产或者物品是否足够
    author:{author}
    time:2018-08-13 15:33:09
    @return:
]]
function EquipmakeMainWindow:checkEnough(bid, need_num)
    if bid == nil or need_num == nil then return false end
    local _config = Config.ItemData.data_assets_id2label
    local _assets = _config[bid]
    local _sum = 0
    if _assets then
        _sum = role_vo[_assets]
    else
        _sum = backpack_model:getBackPackItemNumByBid(bid)
    end
    return _sum >= need_num
end

--[[
    @desc: 判断是否有橙装可分解
    author:{author}
    time:2018-08-13 16:00:22
    @return:
]]
function EquipmakeMainWindow:checkSourceTipsStatus()
    local equip_list = backpack_model:getBagGoldEquipList()
    if equip_list == nil or next(equip_list) == nil then
        self.source_tips:setVisible(false)
    else
        self.source_tips:setVisible(true)
    end
end

function EquipmakeMainWindow:close_callback()
    if self.base_equip then
        self.base_equip:DeleteMe()
    end
    self.base_equip = nil
    if self.upgrade_equip then
        self.upgrade_equip:DeleteMe()
    end
    self.upgrade_equip = nil

    if self.update_equip_make_event then
        GlobalEvent:getInstance():UnBind(self.update_equip_make_event)
        self.update_equip_make_event = nil
    end

    if self.update_sell_orange_event then
        GlobalEvent:getInstance():UnBind(self.update_sell_orange_event)
        self.update_sell_orange_event = nil
    end

    if role_vo then
        if self.role_lev_event then
            role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end

    for k,object in pairs(self.equip_list) do
        if object.item then
            object.item:DeleteMe()
        end
    end
    self.equip_list = nil

    for i,object in ipairs(self.fight_container_list) do
        if object.value then
            object.value:DeleteMe()
        end
    end
    self.fight_container_list = nil

    for i,object in ipairs(self.fight_container_pool) do
        if object.value then
            object.value:DeleteMe()
        end
    end
    self.fight_container_pool = nil

    controller:openEquipmakeMainWindow(false)
end