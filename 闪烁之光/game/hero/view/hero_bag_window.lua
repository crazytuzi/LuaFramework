-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄(伙伴)背包 策划 陈星宇
-- <br/>Create: 2018年11月14日
--
-- --------------------------------------------------------------------
HeroBagWindow = HeroBagWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function HeroBagWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "hero/hero_bag_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("herobag","herobag"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_bag_bg", true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_bag_bg_1", false), type = ResourcesType.single },
    }

    --背包列表 结构
    --图鉴列表
    self.hero_bag_list = {}
    --拥有英雄列表
    self.dic_pokedex_info = {}
    --阵营
    self.select_camp = 0

    --是否要重置 切换页签用
    self.is_must_reset = true

    --按钮位置列表
    self.btn_pos_list = {}
end

function HeroBagWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_bag_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1)  

    self.container = self.mainContainer:getChildByName("container")
    self.box_1 = self.mainContainer:getChildByName("box_1")
    self.box_1:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_bag_bg_1", false), LOADTEXT_TYPE)

    self.no_vedio_image = self.container:getChildByName("no_vedio_image")
    self.no_vedio_label = self.container:getChildByName("no_vedio_label")
    self.no_vedio_image:setVisible(false)
    self.no_vedio_label:setVisible(false)
    self.no_vedio_label:setString(TI18N("一个英雄都没有哦，快去召唤吧"))
    self.lay_scrollview = self.container:getChildByName("lay_scrollview")
    self.con_panel = self.container:getChildByName("con_panel")
    self.img_line = self.container:getChildByName("img_line")

    local camp_node = self.container:getChildByName("camp_node")
    self.camp_node = camp_node
    self.camp_btn_list = {}
    self.camp_redpoint_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[1] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[2] = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[3] = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[4] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[5] = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

    self.camp_btn_size = self.camp_btn_list[1]:getContentSize()


    local tab_container = self.container:getChildByName("tab_container")
    local tab_btn_name = {
        [1] = TI18N("英雄"),
        [2] = TI18N("图鉴"),
        [3] = TI18N("精灵"),
        [4] = TI18N("圣物"),
    }
    local tab_btn_type = {
        [1] = HeroConst.BagTab.eBagHero,     --英雄
        [2] = HeroConst.BagTab.eBagPokedex,  --图书馆
        [3] = HeroConst.BagTab.eElfin,       --精灵
        [4] = HeroConst.BagTab.eHalidom,     --圣物
    }
    self.tab_btn_list = {}
    for i=1,4 do
        local tab_btn = {}
        local item = tab_container:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = tab_btn_type[i]
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        tab_btn.title:setString(tab_btn_name[i])
        tab_btn.title:setTextColor(cc.c4b(0xdd,0xa8,0x80,0xff))
        tab_btn.title:enableOutline(cc.c4b(0x28,0x1b,0x13,0xff), 2)

        tab_btn.title:setFontSize(24)
        
        tab_btn.red_point = item:getChildByName("red_point")
        tab_btn.red_point:setVisible(false)
        self.tab_btn_list[tab_btn.index] = tab_btn
    end

    self.embattle_btn = self.container:getChildByName("embattle_btn")

    self.item_buy_panel = self.container:getChildByName("item_buy_panel")
    --英雄数量
    self.hero_label = self.item_buy_panel:getChildByName("label")
    self.add_btn = self.item_buy_panel:getChildByName("add_btn")

    self.library_btn = self.container:getChildByName("library_btn")
    local library_btn_label = self.library_btn:getChildByName("label")
    if library_btn_label then
        library_btn_label:setString(TI18N("图书馆"))
    end
    self:updateTabBtnStatus()
end

function HeroBagWindow:register_event()
    registerButtonEventListener(self.embattle_btn, handler(self, self._onClickBtnEmbattle) ,true, 2)
    --tab_container
    for index, tab_btn in ipairs(self.tab_btn_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabIndex(tab_btn.index) end ,false, 2) 
    end

    --阵营按钮
    for index, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:_onClickBtnShowByIndex(index) end ,true, 2)
    end

    registerButtonEventListener(self.add_btn, handler(self, self.onClickAddBtn) ,true, 2)

    registerButtonEventListener(self.library_btn, handler(self, self.onClickLibraryBtn) ,true, 2)


    self:addGlobalEvent(HeroEvent.All_Hero_Detail_Info_Event, function(hero_vo)
        --检测一下红点
        --装备信息回来了..检查多一次吧
        HeroCalculate.checkAllHeroRedPoint()
    end)

    --更新英雄上限事件
    self:addGlobalEvent(HeroEvent.Buy_Hero_Max_Count_Event, function() self:updateHeroMaxInfo() end)
    
    --剧情布阵改变了
    self:addGlobalEvent(HeroEvent.Form_Drama_Event, function()
        self:updateEmbattleBtnRedPoint()
    end)    
    --新增英雄
    self:addGlobalEvent(HeroEvent.Hero_Data_Add, function()
        self.hero_bag_list = model:getAllHeroArray()
        self.is_must_reset = true
        self:updateHeroList(self.select_camp)
        self.is_must_reset = false
        self:updateEmbattleBtnRedPoint()
        self:updateHeroMaxInfo()
    end)

    --删除英雄
    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function()
        self.hero_bag_list = model:getAllHeroArray()
        self.is_must_reset = true
        self:updateHeroList(self.select_camp)
        self.is_must_reset = false
        self:updateHeroMaxInfo()
    end)

    --英雄红点更新
    self:addGlobalEvent(HeroEvent.All_Hero_RedPoint_Event, function(status_data)
        self:updateHeroBagRedpoint(status_data)
        --需要刷新一下全部英雄

    end)

    --所有英雄基本信息事件
    self:addGlobalEvent(HeroEvent.All_Hero_Base_Info_Event, function(status_data)
        self.hero_bag_list = model:getAllHeroArray()
        self.is_must_reset = true
        self:updateHeroList(self.select_camp)
        self.is_must_reset = false
        self:updateEmbattleBtnRedPoint()
        self:updateHeroMaxInfo()
    end)

    -- 圣物红点
    self:addGlobalEvent(HalidomEvent.Update_Halidom_Red_Event, function(status_data)
        self:updateHeroBagHalidomRedStatus( true )
    end)

    -- 精灵红点
    self:addGlobalEvent(ElfinEvent.Update_Elfin_Red_Event, function(status_data)
        self:updateHeroBagElfinRedStatus( )
    end)

    --道具增加
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
        if not self.list_view then return end
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            for i,item in pairs(temp_add) do
                if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                    self.list_view:resetCurrentItems()
                end
            end
        end
    end)
    --物品道具删除 判断红点
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_add)
        if not self.list_view then return end
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            for i,item in pairs(temp_add) do
                if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                    self.list_view:resetCurrentItems()
                end
            end
        end
    end)
    --物品道具删除 判断红点
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_add)
        if not self.list_view then return end
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            for i,item in pairs(temp_add) do
                if item.base_id == model.upgrade_star_cost_id or item.base_id == model.upgrade_star_cost_id_2 then
                    self.list_view:resetCurrentItems()
                end
            end
        end
    end)

    --引导前给需要特殊处理界面抛事件
    self:addGlobalEvent(GuideEvent.Update_Guide_Open_Event, function()
        if self.select_btn and self.select_btn.index == HeroConst.BagTab.eBagHero and self.select_camp == 0 and self.list_view then
            self.list_view:resetCurrentItems()
        end
    end)

    -- 角色等级变化
    if not self.role_assets_event then
        if self.role_vo == nil then
            self.role_vo = RoleController:getInstance():getRoleVo()
        end
        if self.role_vo then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" then
                    self:updateTabBtnStatus()
                    self:setLibraryBtnStatus()
                end
            end)
        end
    end
end
function HeroBagWindow:setLibraryBtnStatus(lev)
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local level_cfg = Config.PartnerData.data_partner_const.library_level
    if level_cfg then
        if level_cfg.val > role_vo.lev then
            setChildUnEnabled(true, self.library_btn)
        else
            setChildUnEnabled(false, self.library_btn)    
        end
    else
        setChildUnEnabled(false, self.library_btn)
    end
end

function HeroBagWindow:_onClickBtnClose()
    controller:openHeroBagWindow(false)
end

-- 打开布阵界面
function HeroBagWindow:_onClickBtnEmbattle()
    -- message("此不通,可在推图挑战BOSS进行布阵")
    controller:openFormMainWindow(true)
end
--显示根据类型 0表示全部
function HeroBagWindow:_onClickBtnShowByIndex(index)
    if self.img_select and self.camp_btn_list[index] then
        local x, y = self.camp_btn_list[index]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    if self.select_btn then
        if self.select_btn.index == HeroConst.BagTab.eBagHero or self.select_btn.index == HeroConst.BagTab.eBagPokedex then
            self:updateHeroList(index)
        elseif self.select_btn.index == HeroConst.BagTab.eHalidom then
            if self.halidom_panel then
                self.halidom_panel:choseHalidomByCamp(index)
            end
        end
    end
end

--加英雄数量
function HeroBagWindow:onClickAddBtn()
    local buy_num = model:getHeroBuyNum()
    local config = Config.PartnerData.data_partner_buy[buy_num + 1]
    if config then 
        local item_id = config.expend[1][1] or 3
        local count = config.expend[1][2] or 100
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format(TI18N("是否花费<img src='%s' scale=0.3 />%s扩充%s个英雄位置数量上限？"), iconsrc, count, config.add_num)
        local call_back = function()
            controller:sender11009()
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    else
        message(TI18N("购买次数已达上限"))
    end
end

function HeroBagWindow:onClickLibraryBtn()
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local level_cfg = Config.PartnerData.data_partner_const.library_level
    if level_cfg and level_cfg.val > role_vo.lev then
        message(level_cfg.desc)
        return
    end
    HeroController:getInstance():openHeroLibraryMainWindow(true)
end

-- 刷新tab按钮锁定状态
function HeroBagWindow:updateTabBtnStatus(  )
        if not self.tab_btn_list then return end
    for index, tab_btn in ipairs(self.tab_btn_list) do
        local is_open = true
        if tab_btn.index == HeroConst.BagTab.eHalidom then
            is_open = HalidomController:getInstance():getModel():checkHalidomIsOpen(true)
        elseif tab_btn.index == HeroConst.BagTab.eElfin then
            is_open = ElfinController:getInstance():getModel():checkElfinIsOpen(true)
        end
        if tab_btn.btn then
            setChildUnEnabled( not is_open, tab_btn.btn)
        end
    end
end

-- @index  1 表示英雄  2 表示 图鉴  3表示圣物
function HeroBagWindow:changeTabIndex(index)
    if self.select_btn and self.select_btn.index == index then return end

    if index == HeroConst.BagTab.eHalidom then -- 圣物需要判断是否开启
        if not HalidomController:getInstance():getModel():checkHalidomIsOpen() then
            return
        end
    elseif index == HeroConst.BagTab.eElfin then
        if not ElfinController:getInstance():getModel():checkElfinIsOpen() then
            return
        end
    end

    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:setTextColor(cc.c4b(0xdd,0xa8,0x80,0xff))
        self.select_btn.title:enableOutline(cc.c4b(0x28,0x1b,0x13,0xff), 2)

        self.select_btn.title:setFontSize(24)
    end

    self.select_btn = self.tab_btn_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)

        self.select_btn.title:setTextColor(cc.c4b(0x6c,0x40,0x2c,0xff))
        self.select_btn.title:disableEffect(cc.LabelEffect.OUTLINE)
        self.select_btn.title:setFontSize(28)
    end
    if self.library_btn then
        self.library_btn:setVisible(false)
    end

    if index == HeroConst.BagTab.eBagHero then --英雄页签
        self.lay_scrollview:setVisible(true)
        self.con_panel:setVisible(false)
        self:setCampBtnPos(1)
        self.select_camp = 0
        self.item_buy_panel:setVisible(true)
        self:updateHeroMaxInfo()
        self.library_btn:setVisible(true)
    elseif index == HeroConst.BagTab.eBagPokedex then --图鉴页签
        self.lay_scrollview:setVisible(true)
        self.con_panel:setVisible(false)
        self:setCampBtnPos(2)
        self.select_camp = 1 
        self.item_buy_panel:setVisible(false)
        
    elseif index == HeroConst.BagTab.eHalidom then --圣物
        if not self.halidom_panel then
            self.halidom_panel = HalidomMainPanel.new(handler(self, self._onChangeSelectCamp))
            self.con_panel:addChild(self.halidom_panel)
        end
        if self.elfin_panel then
            self.elfin_panel:setVisible(false)
        end
        self.halidom_panel:setVisible(true)
        self.lay_scrollview:setVisible(false)
        self.con_panel:setVisible(true)
        self:setCampBtnPos(2)
        self.select_camp = 1 
        self.item_buy_panel:setVisible(false)

        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)

    elseif index == HeroConst.BagTab.eElfin then --精灵
        if not self.elfin_panel then
            self.elfin_panel = ElfinMainPanel.new(self.sub_type)
            self.con_panel:addChild(self.elfin_panel)
        end
        if self.halidom_panel then
            self.halidom_panel:setVisible(false)
        end
        self.elfin_panel:setVisible(true)
        self.lay_scrollview:setVisible(false)
        self.con_panel:setVisible(true)
        self.item_buy_panel:setVisible(false)

        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    end

    self.img_line:setVisible(index ~= HeroConst.BagTab.eElfin)
    self.camp_node:setVisible(index ~= HeroConst.BagTab.eElfin)

    self:updateHeroBagHalidomRedStatus()
    self:updateHeroBagElfinRedStatus()
    self.is_must_reset = true
    self:_onClickBtnShowByIndex(self.select_camp)
    self.is_must_reset = false
end

function HeroBagWindow:_onChangeSelectCamp( index )
    if self.img_select and self.camp_btn_list[index] then
        local x, y = self.camp_btn_list[index]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
end

--更新tab红点
function HeroBagWindow:updateHeroBagRedpoint(status_data)
    if self.redpoint_status == nil then
        self.redpoint_status = {}
    end
    for i,data in ipairs(status_data) do
        self.redpoint_status[data.bid] = data.status
    end
    local is_redpoint = false
    for k, status in pairs(self.redpoint_status) do
        if status == true then
            is_redpoint = true 
            break
        end
    end
    --目前只有英雄红点
    local btn = self.tab_btn_list[HeroConst.BagTab.eBagHero]
    if btn then
        btn.red_point:setVisible(is_redpoint)
    end

    if self.select_btn and self.select_btn.index == HeroConst.BagTab.eBagHero  then
        --刷新一下当前红点
        if self.list_view then
            self.list_view:resetCurrentItems()
        end
    end
end

-- 更新圣物的红点(包括tab和阵营)
function HeroBagWindow:updateHeroBagHalidomRedStatus( force )
    local halidom_model = HalidomController:getInstance():getModel()
    local red_status = halidom_model:getHalidomRedStatus()
    -- tab红点
    local btn = self.tab_btn_list[HeroConst.BagTab.eHalidom]
    if btn then
        btn.red_point:setVisible(red_status)
    end
    -- 阵营红点 
    if self.select_btn and self.select_btn.index == HeroConst.BagTab.eHalidom then
        if force or not self.halidom_camp_red or next(self.halidom_camp_red) == nil then
            self.halidom_camp_red = {}
            for k,hData in pairs(Config.HalidomData.data_base) do
                local camp_btn = self.camp_btn_list[hData.camp]
                if camp_btn then
                    local camp_red_status = false
                    if halidom_model:checkHalidomIsUnlock(hData.id) then
                        local halidom_vo = halidom_model:getHalidomDataById(hData.id)
                        if halidom_vo and next(halidom_vo) ~= nil then
                            if halidom_vo:getRedStatusByType(HalidomConst.Red_Type.Lvup) or halidom_vo:getRedStatusByType(HalidomConst.Red_Type.Step) then
                                camp_red_status = true
                            end
                        end
                    elseif halidom_model:checkHalidomIsCanUnlock(hData.id) then
                        camp_red_status  = true
                    end
                    self.halidom_camp_red[hData.camp] = camp_red_status
                    self:setRedPointcamp(hData.camp, camp_red_status)
                end
            end
        else
            if self.halidom_camp_red then
                for k,camp_btn in pairs(self.camp_btn_list) do
                    if k ~= 0 then
                        local camp_red_status = self.halidom_camp_red[k]
                        self:setRedPointcamp(k, camp_red_status)
                    end
                    
                end
            end
        end
    else
        for k,camp_btn in pairs(self.camp_btn_list) do
            if k ~= 0 then
                self:setRedPointcamp(k, false)
            end
        end
    end
end

-- 精灵tab按钮红点
function HeroBagWindow:updateHeroBagElfinRedStatus(  )
    local elfin_model = ElfinController:getInstance():getModel()
    local red_status = elfin_model:getElfinRedStatus()
    local btn = self.tab_btn_list[HeroConst.BagTab.eElfin]
    if btn then
        btn.red_point:setVisible(red_status)
    end
end

function HeroBagWindow:setRedPointcamp(camp, is_visible)
    if is_visible then
        if self.camp_redpoint_list[camp] == nil then
            local camp_btn = self.camp_btn_list[camp]
            local x, y = camp_btn:getPosition()
            red_res = PathTool.getResFrame("mainui","mainui_1009")
            self.camp_redpoint_list[camp] = createSprite(red_res,0,0,self.camp_node,cc.p(1,1),LOADTEXT_TYPE_PLIST)
            self.camp_redpoint_list[camp]:setPosition(x + self.camp_btn_size.width*0.5, y+self.camp_btn_size.height*0.5)
        end
        self.camp_redpoint_list[camp]:setVisible(is_visible)
    else
        if self.camp_redpoint_list[camp] then
            self.camp_redpoint_list[camp]:setVisible(false)
        end
    end
end

--更新出征按钮红点
function HeroBagWindow:updateEmbattleBtnRedPoint()
    if not model then return end
    local is_redpoint = false
    --目前只开了一队的数量..第二对不知道什么时候开. 如果开了第二对..那么这里的逻辑需要加上开启第二队伍的逻辑
    local open_team_count = 1
    local hallow_list = HallowsController:getInstance():getModel():getHallowsList() or {}
    local horo_list = model:getAllHeroArray()
    local dic_hallows = {} --标志神器被使用
    local dic_pos_list = model:getMyPosList() --如果以后多队伍的情况下会有超过5个
    local dic_hero_bid = {}
    for k,v in pairs(dic_pos_list) do
        if v.id then
            local hero_vo = model:getHeroById(v.id)
            if hero_vo and hero_vo.bid then
                dic_hero_bid[hero_vo.bid] = true
            end
        end
    end

    for i=1,open_team_count do
        local hollows_id = model.use_hallows_id or 0 --目前神器只有一个列表..等开了多队伍后要改成数组

        if hollows_id == 0 then --没穿戴神器  
            -- 判断有没有可用的神器
            for i,v in ipairs(hallow_list) do
                if v.id and dic_hallows[v.id] == nil then
                    is_redpoint = true
                    break
                end
            end
        else
            if hollows_id then
                dic_hallows[hollows_id] = true
            end
        end
        --判断有没有空位置 并且不能同名
        local list = model:getMyPosList(i)
        local count = #list
        if count < 5 then
            for j=1,horo_list:GetSize() do
                local hero_vo = horo_list:Get(j-1)
                if hero_vo and hero_vo.bid and dic_hero_bid[hero_vo.bid] == nil then
                    is_redpoint = true
                    break    
                end
            end
        end
    end

    addRedPointToNodeByStatus(self.embattle_btn, is_redpoint, 5, 0, nil ,2)
end

function HeroBagWindow:openRootWnd(index, sub_type)
    local index = index or HeroConst.BagTab.eBagHero
    self.sub_type = sub_type
    if index == HeroConst.BagTab.eHalidom then -- 圣物需要判断是否已经开启，没开启则默认选中英雄分页
        local open_cfg = Config.HalidomData.data_const["halidom_open_lev"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if not open_cfg or not role_vo or open_cfg.val > role_vo.lev then
            index = HeroConst.BagTab.eBagHero
        end
    elseif index == HeroConst.BagTab.eElfin then
        if not ElfinController:getInstance():getModel():checkElfinIsOpen(true) then
            index = HeroConst.BagTab.eBagHero
        end
    end
    --已拥有信息信息
    self.dic_had_hero_info = HeroController:getInstance():getModel():getHadHeroInfo()
    self:initHeroBagList()
    self:changeTabIndex(index)

    --检测一下红点
    HeroCalculate.checkAllHeroRedPoint()
    --布阵按钮的红点
    self:updateEmbattleBtnRedPoint()
    self:setLibraryBtnStatus()
end

--初始化背包伙伴列表 
function HeroBagWindow:initHeroBagList()
    --英雄列表
    self.hero_bag_list = model:getAllHeroArray()
    --图书馆列表
    self.dic_pokedex_info = model:getHeroPokedexList()
end

function HeroBagWindow:updateHeroMaxInfo()
    if self.hero_label then
        local max, count = model:getHeroMaxCount()
        self.hero_label:setString(string_format("%s/%s", count, max))
    end
end

--设置种族按钮位置 根据按钮数量来设定位置
--@ btn_Type 按钮类型 1 有全部按钮类型  2 无全部按钮类型
function HeroBagWindow:setCampBtnPos(btn_Type)
    if self.btn_pos_list[btn_Type] == nil then
        self.btn_pos_list[btn_Type] = {}

        local offset = 20
        local width = 58 -- 按钮大小
        local count = 5
        if btn_Type == 1  then
            count = 6
        end
        
        local x = - (width * count + offset *(count -1)) * 0.5 + width * 0.5
        for i=1,count do
            self.btn_pos_list[btn_Type][i] = x + (i-1) * (width + offset)
        end
    end
    if btn_Type == 1  then
        self.camp_btn_list[0]:setVisible(true)
        for i=0, 5 do
            local x = self.btn_pos_list[btn_Type][i+1] or 0
            self.camp_btn_list[i]:setPositionX(x)
        end
    else
        self.camp_btn_list[0]:setVisible(false)
        for i=1, 5 do
            local x = self.btn_pos_list[btn_Type][i] or 0
            self.camp_btn_list[i]:setPositionX(x)
        end
    end
end


--创建英雄列表 
-- @select_camp 选中阵营
function HeroBagWindow:updateHeroList(select_camp)
    local select_camp = select_camp or 1
    if not self.is_must_reset and select_camp == self.select_camp then 
        return
    end
    if not self.list_view then
        local scroll_view_size = cc.size(600,680)
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 150,               -- 单元的尺寸width
            item_height = 136,              -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        local size = self.lay_scrollview:getContentSize()
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    self.select_camp = select_camp
    local size = 0
    if self.select_btn and self.select_btn.index == HeroConst.BagTab.eBagPokedex then
        --图书馆
        local list = self.dic_pokedex_info[self.select_camp] or {}
        size = #list
        if size > 0 then
            self.show_list =list
        else
            self.show_list = {}
        end 
    else
        --英雄列表 (默认)
        local hero_array = self.hero_bag_list or Array.New()
        local form_list = {}
        local list = {}
        for j=1,hero_array:GetSize() do
            local hero_vo = hero_array:Get(j-1)
            if select_camp == 0 or (select_camp == hero_vo.camp_type) then
                if hero_vo.isFormDrama and hero_vo:isFormDrama() then
                    table_insert(form_list, hero_vo)
                else
                    table_insert(list, hero_vo)
                end
                -- vo:PushBack(hero_vo)
            end
        end
        size = #list + #form_list
        if size > 0 then
            -- vo:UpperSortByParams("star", "power", "lev", "sort_order")
            -- local sort_func1 = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"lev", true}, {"sort_order", true}})
            local sort_func = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"lev", true}, {"sort_order", true}})
            table_sort(form_list, sort_func)
            table_sort(list, sort_func)
            local count = #form_list
            for i=count, 1, -1 do
                table_insert(list, 1, form_list[i])
            end
            self.show_list = list
        else
            self.show_list = {}
        end
    end
    self.list_view:reloadData()

    if size == 0 then
        self.no_vedio_image:setVisible(true)
        self.no_vedio_label:setVisible(true)
        return
    else
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    end
end

function HeroBagWindow:selectHero(item, hero_vo)
    if not hero_vo  then return end
    if not item then return end
    local show_model_type = HeroConst.BagTab.eBagHero
    if self.select_btn then
        show_model_type = self.select_btn.index or HeroConst.BagTab.eBagHero
    end 
    --打开英雄信息ui
    HeroController:getInstance():openHeroMainInfoWindow(true, hero_vo, self.show_list, {show_model_type = show_model_type})
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroBagWindow:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroBagWindow:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroBagWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    if hero_vo then
        if self.select_btn then
            if self.select_btn.index == HeroConst.BagTab.eBagPokedex then
                --图书馆
                local dic_had_hero_info = HeroController:getInstance():getModel():getHadHeroInfo()
                local is_have
                if self.dic_had_hero_info[hero_vo.bid] and self.dic_had_hero_info[hero_vo.bid] >= hero_vo.star then
                    is_have = false
                else
                    is_have = true
                end

                cell:setHeadUnEnabled(is_have)
                if cell.partner_type then
                    setChildUnEnabled(is_have, cell.partner_type)
                end
                cell:showRedPoint(false)
                cell:showFightImg(false)
                cell.from_type = HeroConst.ExhibitionItemType.eBagPokedex
            elseif self.select_btn.index == HeroConst.BagTab.eBagHero then
                --英雄页签
                cell:setHeadUnEnabled(false)
                if cell.partner_type then
                    setChildUnEnabled(false, cell.partner_type)
                end
                if HeroCalculate.isCheckHeroRedPointByHeroVo(hero_vo) then
                    local is_redpoint = HeroCalculate.checkSingleHeroRedPoint(hero_vo)
                    cell:showRedPoint(is_redpoint, 10, 5)
                else
                    cell:showRedPoint(false)
                end
                cell.from_type = HeroConst.ExhibitionItemType.eHeroBag

                if hero_vo:isFormDrama() then
                    cell:showFightImg(true)
                else
                    cell:showFightImg(false)
                end
            end
        end
        cell:setData(hero_vo)
    end

end

--点击cell .需要在 createNewCell 设置点击事件
function HeroBagWindow:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.show_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    end
end


function HeroBagWindow:close_callback()
    if self.list_view then
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.halidom_panel then
        self.halidom_panel:DeleteMe()
        self.halidom_panel = nil
    end
    if self.elfin_panel then
        self.elfin_panel:DeleteMe()
        self.elfin_panel = nil
    end
    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
    controller:openHeroBagWindow(false)
end