-- --------------------------------------------------------------------
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄升星界面 点击 融合祭坛打开的界面  主要 4升5 5升6的
-- <br/> 2018年11月21日
--
-- --------------------------------------------------------------------
--HeroUpgradeStarFuseWindow = HeroUpgradeStarFuseWindow or BaseClass(BaseView)

HeroUpgradeStarFusePanel = class("HeroUpgradeStarFusePanel", function()
    return ccui.Widget:create()
end)

local controller = HeroController:getInstance()
local model = controller:getModel()
local table_sort = table.sort
local table_insert = table.insert
local string_format = string.format
local parnter_info = Config.PartnerData.data_partner_base

function HeroUpgradeStarFusePanel:ctor(hero_vo)
    self.hero_vo = hero_vo or nil
   -- 1 ~ 5星 星星列表
    self.star_list = {}
    -- 6 ~ 9星 星星列表
    self.star_list2 = {}
    -- 10星显示
    self.star10 = nil
    self.star_label = nil

    --融合数据
    self.dic_fuse_info = nil

    --中间四个item的数据
    self.hero_item_data_list = nil
    self.camp_y = {
        [HeroConst.CampType.eWater] = 766,
        [HeroConst.CampType.eFire] = 739,
        [HeroConst.CampType.eWind] = 540,
        [HeroConst.CampType.eLight] = 798,
        [HeroConst.CampType.eDark] = 497
    }
    
    --阵营红点列表
    self.camp_btn_redpoint_list = nil
    self:loadResources()


    
end
function HeroUpgradeStarFusePanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_reset_bg", true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3", false), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
        
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        self:configUI()
        self:register_event()
        self:openRootWnd()
    end)
end

function HeroUpgradeStarFusePanel:configUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_upgrade_star_fuse_window")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale( display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.hero_camp_bg = self.main_panel:getChildByName("hero_camp_bg")
        
    self.no_vedio_image = self.main_panel:getChildByName("no_vedio_image")
    self.no_vedio_label = self.main_panel:getChildByName("no_vedio_label")
    self.no_vedio_label:setString(TI18N("暂无此类型英雄"))
    --按钮
    self.explain_btn = self.main_panel:getChildByName("explain_btn")
    self.look_btn = self.main_panel:getChildByName("look_btn")
    -- self.close_btn = self.main_panel:getChildByName("close_btn")

    --英雄信息
    local lay_hero = self.main_panel:getChildByName("lay_hero")
    -- self.arrow_bg = self.power_click:getChildByName("arrow_bg")
    --星星
    self.star_node = lay_hero:getChildByName("star_node")
    --模型
    self.mode_node = lay_hero:getChildByName("mode_node")
    --阵营
    self.camp_icon = lay_hero:getChildByName("camp_icon")
    self.hero_name = lay_hero:getChildByName("name")

    local camp_node = self.main_panel:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_redpoint_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

    --中间部分
    self.synthesis_btn = self.main_panel:getChildByName("synthesis_btn")


    self.centre_hero_node = self.main_panel:getChildByName("centre_hero_node")
    --中间四个
    self.hero_item_list = {}
    self.hero_comp_name = {}
    for i=1,4 do
        self.hero_comp_name[i] = createRichLabel(22, cc.c4b(0xFF,0xED,0xD6,0xff), cc.p(0.5,0.5), cc.p(0,0), nil, nil, 150)
        self.centre_hero_node:addChild(self.hero_comp_name[i])
        self.hero_comp_name[i]:setString("")
        if i == 1 then
            self.hero_item_list[i] = HeroExhibitionItem.new(1, true)
            self.hero_item_list[i]:setPosition(0, 0)
            self.hero_comp_name[i]:setPosition(0,-78)
        else
            self.hero_item_list[i] = HeroExhibitionItem.new(0.8, true)
            self.hero_item_list[i]:setPosition(20 + (i-1) * 120, -16)
            self.hero_comp_name[i]:setPosition(20 + (i-1) * 120, -78)
        end
        self.hero_item_list[i]:addCallBack(function() self:_onClickHeroItem(i) end)
        self.centre_hero_node:addChild(self.hero_item_list[i])
    end
    
    --右上角部分
    local attr_node = self.main_panel:getChildByName("attr_node")
    self.level_label = attr_node:getChildByName("level_label")

    self.attr_icon_list = {}
    self.attr_icon_list[1] = attr_node:getChildByName("attr_icon1")
    self.attr_icon_list[2] = attr_node:getChildByName("attr_icon2")
    self.attr_icon_list[3] = attr_node:getChildByName("attr_icon3")
    self.attr_icon_list[4] = attr_node:getChildByName("attr_icon4")
    self.attr_label_list = {}
    self.attr_label_list[1] = attr_node:getChildByName("attr_label1")
    self.attr_label_list[2] = attr_node:getChildByName("attr_label2")
    self.attr_label_list[3] = attr_node:getChildByName("attr_label3")
    self.attr_label_list[4] = attr_node:getChildByName("attr_label4")


    --属性icon
    self.attr_list = {[1]="atk",[2]="hp",[3]="def",[4]="speed"}
    for i,attr_str in ipairs(self.attr_list) do
        if self.attr_icon_list[i] then
            local res_id = PathTool.getAttrIconByStr(attr_str)
            local res = PathTool.getResFrame("common",res_id)
            loadSpriteTexture(self.attr_icon_list[i], res, LOADTEXT_TYPE_PLIST)   
        end
    end

    self.lay_scrollview = self.main_panel:getChildByName("lay_scrollview")

    self:adaptationScreen()
end

function HeroUpgradeStarFusePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
end
--设置适配屏幕
function HeroUpgradeStarFusePanel:adaptationScreen()
    -- --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    -- local top_y = display.getTop(self.main_container)
    -- local bottom_y = display.getBottom(self.main_container)
    -- local left_x = display.getLeft(self.main_container)
    -- local right_x = display.getRight(self.main_container)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()

    -- -- local offy = top_y - top_height - 50 
    -- -- self.explain_btn:setAnchorPoint(cc.p(0.5,1))
    -- -- self.explain_btn:setPositionY(offy)

    -- local offx = right_x - 50 
    -- self.comment_btn:setPositionX(offx)
    -- self.lock_btn:setPositionX(offx)
    -- self.share_btn:setPositionX(offx)
end

function HeroUpgradeStarFusePanel:register_event()
    registerButtonEventListener(self.explain_btn, function(param,sender, event_type) 
        local config = Config.PartnerData.data_partner_const.game_rule2
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end ,true, 2, nil, 0.8)
    registerButtonEventListener(self.look_btn, function() self:_onClickBtnLook() end ,true, 2, nil, 0.8)

    registerButtonEventListener(self.synthesis_btn, function() self:_onClickBtnSynthesis() end ,true, 2)

     --阵营按钮
    for select_camp, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:_onClickBtnShowByIndex(select_camp) end ,true, 2)
    end

    --添加英雄选择返回事件
    if not self.star_select_event then
        self.star_select_event = GlobalEvent:getInstance():Bind(HeroEvent.Upgrade_Star_Select_Event, function() self:updateHeroItemInfo() end)
    -- --添加英雄升星成功返回
    -- self:addGlobalEvent(HeroEvent.Upgrade_Star_Success_Event, function() 
    --     if not self.fuse_data then return end
    --     self:updateHeadHeroInfo(self.fuse_data)
    -- end)
    end
    --新增英雄
    if not self.hero_data_add then
        self.hero_data_add = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Add, function()
        self:checkUpdateCurrentInfo(true)
        end)
    end

    --升星成功后 会更新主卡英雄信息    
    if not self.hero_data_update then
        self.hero_data_update = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Update, function()
        if not self.fuse_data then return end
        self.is_hero_data_update = true
        self:checkUpdateCurrentInfo()
        end)
    end
    --升星成功后 会删除英雄信息   
    if not self.del_hero_event then
        self.del_hero_event = GlobalEvent:getInstance():Bind(HeroEvent.Del_Hero_Event, function()
        if not self.fuse_data then return end
        self.is_del_hero_event = true
        self:checkUpdateCurrentInfo()
        end)
    end
end

--检测是否可以更新当前所有信息
--is_not_check 不用检测直接刷新
function HeroUpgradeStarFusePanel:checkUpdateCurrentInfo(is_not_check)
    if (self.is_hero_data_update and self.is_del_hero_event) or is_not_check then
        self:initCentreHeroItemDataByConfig(self.fuse_data.star_config)
        --更新阵营按钮上的红点
        self:updateCampRedpoint()
        self:updateHeroList(self.select_camp, true)
    end
end

--查看当前选中英雄
function HeroUpgradeStarFusePanel:_onClickBtnLook()
    if not self.show_hero_vo then return end
    controller:openHeroTipsPanel(true, self.show_hero_vo, {is_hide_equip = true})
end

--合成当前选中英雄
function HeroUpgradeStarFusePanel:_onClickBtnSynthesis()
    local partner_id = nil
    local hero_list = {}
    local random_list = {}
    local dic_item_expend = {}

    for i,item in ipairs(self.hero_item_data_list) do
        local count = 0
        for k,v in pairs(item.dic_select_list) do
            count = count + 1
        end
        if count < item.count then
            message(TI18N("所需材料不足"))
            return
        end
        if i == 1 then
            for k,v in pairs(item.dic_select_list) do
                partner_id = k
            end
        else
            for k,v in pairs(item.dic_select_list) do
                if v.is_hero_hun then --是否英魂 参考 HeroUpgradeStarSelectPanel:initHeroList(dic_other_selected) 里面的定义
                    if v.good_vo then
                        if dic_item_expend[v.good_vo.base_id] == nil then
                            dic_item_expend[v.good_vo.base_id] = 1
                        else
                            dic_item_expend[v.good_vo.base_id] = dic_item_expend[v.good_vo.base_id] + 1
                        end
                    end
                else
                    local data = {}
                     data.partner_id = k
                    if item.bid == 0 then
                        --随机卡
                        table_insert(random_list, data)
                    else
                        --指定卡
                        table_insert(hero_list, data)
                    end
                end
            end
        end
    end 
    self.is_hero_data_update = false
    self.is_del_hero_event = false

    local item_list = {}
    for item_id, num in pairs(dic_item_expend) do
        local data = {}
        data.item_id = item_id
        data.num = num
        table_insert(item_list, data)
    end
    controller:sender11005(partner_id, hero_list, random_list, item_list)
end


--显示根据类型 0表示全部
function HeroUpgradeStarFusePanel:_onClickBtnShowByIndex(select_camp)
    if self.img_select and self.camp_btn_list[select_camp] then
        local x, y = self.camp_btn_list[select_camp]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    self:updateHeroList(select_camp)
     --更新阵营按钮上的红点
    self:updateCampRedpoint()
end

--点击中间那个heroitem
function HeroUpgradeStarFusePanel:_onClickHeroItem(index)
    if not self.hero_item_data_list[index] then return end
    --标志点击了那个
    self.hero_item_data_list[index].is_select = true

    --被其他人选择的列表 [id] = hero_vo 模式
    local dic_other_selected = {}
    for i,item in ipairs(self.hero_item_data_list) do
        if i ~= index then
            for k,v in pairs(item.dic_select_list) do
                dic_other_selected[k] = v
            end
        end
    end

    local setting = {}
    setting.is_master = (index == 1)
    if self.hero_item_data_list[index].bid == 0 and self.hero_item_data_list[index].star == 5 and self.fuse_data then
        -- 表示随机卡
        setting.self_mark_bid = self.fuse_data.bid
    end
    controller:openHeroUpgradeStarSelectPanel(true, self.hero_item_data_list[index], dic_other_selected, HeroConst.SelectHeroType.eStarFuse, setting)
end

--更新选中英雄信息
function HeroUpgradeStarFusePanel:updateHeroItemInfo()
    self.dic_other_selected = {}
    for i,v in ipairs(self.hero_item_data_list) do
        if v.is_select then
            v.is_select = false
            local count = 0
            for k,v in pairs(v.dic_select_list) do
                count = count + 1
                self.dic_other_selected[k] = v
            end
            v.lev = string_format("%s/%s", count, v.count)
            if self.hero_item_list[i] then
                self.hero_item_list[i].num_label:setString(v.lev)
                if count > 0 then
                    self.hero_item_list[i]:setHeadUnEnabled(false)
                else
                    self.hero_item_list[i]:setHeadUnEnabled(true)
                end
            end       
        else
            for k,v in pairs(v.dic_select_list) do
                self.dic_other_selected[k] = v
            end
        end
    end
    --更新红点
    self:updateCentreHeroItemRedPoint()
end


--@hero_vo --需要显示的 hero_vo
--@hero_list
--@show_type 参考 HeroConst.MainInfoTab 定义
function HeroUpgradeStarFusePanel:openRootWnd()
    self:initHeroVoInfo()
    --默认打开
    self:_onClickBtnShowByIndex(0)
    if model.getIsFuseRedPoint and model:getIsFuseRedPoint() then
        controller:sender11055(0)
    end
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.guild, false)
end


function HeroUpgradeStarFusePanel:initHeroVoInfo()
    if self.dic_fuse_info then return end
    self.dic_fuse_info = model:getStarFuseList() or {}
end

--更新阵营的红点
function HeroUpgradeStarFusePanel:updateCampRedpoint()
    local select_camp  = self.select_camp  or 0
    for camp, btn in pairs(self.camp_btn_list) do
        if camp == select_camp then
            --当前选中阵营不显示
            addRedPointToNodeByStatus(btn, false)
        else
            local status = HeroCalculate.checkCampStarFuseRedpoint(self.dic_fuse_info[camp])
            addRedPointToNodeByStatus(btn, status)
        end
    end
end

-- function HeroUpgradeStarFusePanel:updateBackGround()
--     if self.fuse_data  then
--         local camp_type = self.fuse_data.camp_type or HeroConst.CampType.eWater
--         local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBgRes[camp_type], true)
--         self.record_bg_res = bg_res
--         self.item_load = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load) 
--     end
-- end

--更新上部分的英雄信息
--@fuse_data 融合数据 参考本类的: local fuse_data = {}
function HeroUpgradeStarFusePanel:updateHeadHeroInfo(fuse_data)
    if not fuse_data then return end
    self.fuse_data = fuse_data
    --背景
    local camp_type = fuse_data.camp_type or HeroConst.CampType.eWater
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBgRes[camp_type], true)
    if self.record_bg_res ~= bg_res then
        self.record_bg_res = bg_res
        self.item_load = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load) 
    end

    --背景门
    local camp_res = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBottomBgRes[camp_type], false)
    if self.record_camp_res ~= camp_res then
        self.record_camp_res = camp_res
        self.item_load_camp = loadSpriteTextureFromCDN(self.hero_camp_bg, camp_res, ResourcesType.single, self.item_load_camp) 
    end

    local camp_y = self.camp_y[camp_type] or 646
    self.hero_camp_bg:setPositionY(camp_y)

    --职业icon
    if self.record_camp_type == nil or self.record_camp_type ~= fuse_data.camp_type then
        self.record_camp_type = fuse_data.camp_type
        local res = PathTool.getHeroCampTypeIcon(fuse_data.camp_type)
        loadSpriteTexture(self.camp_icon, res, LOADTEXT_TYPE_PLIST)
    end

    if fuse_data.base_config then
        self.hero_name:setString(fuse_data.base_config.name)
    end

    --星星self.select_hero_vo.star
    self:createStar(fuse_data.star)
    self:updateSpine(fuse_data)

    --右上角属性
    local key = getNorKey(fuse_data.bid,fuse_data.star)
    self.show_hero_vo = model:getHeroPokedexByBid(key)
    if self.show_hero_vo then
        self.level_label:setString(string_format(TI18N("等级:%s"),self.show_hero_vo.lev))
        for i,attr_str in ipairs(self.attr_list) do
            if self.attr_label_list[i] then
                local value = self.show_hero_vo[attr_str] or 0
                self.attr_label_list[i]:setString(value)
            end
        end
    end

    --中间部分显示
    self:initCentreHeroItemDataByConfig(fuse_data.star_config)
end

function HeroUpgradeStarFusePanel:initCentreHeroItemDataByConfig(star_config)
    if not star_config then return end
    self.hero_item_data_list = {}
    --记录已选id [partner_id] = hero_vo
    self.dic_other_selected = {}
    local index = 1
    local expend = star_config.expend1[1]

    --结构参考 HeroModel:getHeroListByMatchInfo(dic_conditions, dic_random_conditions)的对应结构
    local conditions_list = {}
    if expend then
        --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
        self.hero_item_data_list[index] = self:getHeroData(expend[1], expend[2], expend[3]) 
        conditions_list[index] = {}
        conditions_list[index][expend[1]] = {}
        conditions_list[index][expend[1]][expend[2]] = expend[3]
    end
    index = index + 1
    for i,expend in ipairs(star_config.expend2) do
        --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
        self.hero_item_data_list[index] = self:getHeroData(expend[1], expend[2], expend[3])
        conditions_list[index] = {}
        conditions_list[index][expend[1]] = {}
        conditions_list[index][expend[1]][expend[2]] = expend[3]
        index = index + 1
    end
    if index <= 4 then
        --随机的 {1,4,2} : 1 表示阵营  4: 表示星级 2表示数量
        for i,expend in ipairs(star_config.expend3) do
            self.hero_item_data_list[index] = self:getHeroData(nil, expend[2], expend[3], expend[1])
            conditions_list[index] = {}
            conditions_list[index][expend[1]] = {}
            conditions_list[index][expend[1]][expend[2]] = expend[3]
            index = index + 1
            if index > 4 then
                break
            end
        end
    end

    for i,item in ipairs(self.hero_item_list) do
        --模拟的hero_vo数据
        local hero_vo = self.hero_item_data_list[i]
        if hero_vo then
            item:setVisible(true)
            local str = ""
            if hero_vo.bid == 0 then
                --随机卡的头像id
                local default_head_id = model:getRandomHeroHeadByQuality(hero_vo.star)
                item:setData(hero_vo)
                item:setDefaultHead(default_head_id)
                str = string_format(TI18N("<div outline=2,#000000 >%d星英雄</div>"),hero_vo.star)
            else
                str = string_format(TI18N("<div outline=2,#000000 >%s</div>"),parnter_info[hero_vo.bid].name)
                item:setData(hero_vo)
            end
            if self.hero_comp_name[i] then
                self.hero_comp_name[i]:setString(str)
            end
            item:setHeadUnEnabled(true)
        else
            item:setVisible(false)
        end
    end

    self:initHeroListByMatchInfo(conditions_list)
    self:updateCentreHeroItemRedPoint()
end

--初始化英雄列表匹配信息
function HeroUpgradeStarFusePanel:initHeroListByMatchInfo(conditions_list)
    local hero_list = model:getHeroList()

    self.conditions_hero_list = {}
    for k,hero in pairs(hero_list) do
        for i,conditions in ipairs(conditions_list) do
            if self.conditions_hero_list[i] == nil then
                self.conditions_hero_list[i] = {}
            end

            if self.hero_item_data_list[i].bid == 0 then
                --表示随机卡 0表示全部阵营
                if conditions[0] then
                    if conditions[0][hero.star] then
                        table_insert(self.conditions_hero_list[i], hero)
                    end
                else
                    if conditions[hero.camp_type] and conditions[hero.camp_type][hero.star] ~= nil then
                        table_insert(self.conditions_hero_list[i], hero)
                    end
                end
            else
                --指定卡
                if conditions[hero.bid] and conditions[hero.bid][hero.star] then
                    table_insert(self.conditions_hero_list[i], hero)
                end
            end
        end
    end

    --新加需求.自动填满指定定的位置的英雄
    -- if self.fuse_data.cur_redpoint and self.fuse_data.cur_redpoint == 1 then
        self.dic_other_selected = {}
        for i,v in ipairs(self.hero_item_data_list) do
            --策划要求指定才需要填充 
            if v.bid ~= 0 then
                if self.conditions_hero_list[i] and #self.conditions_hero_list[i] > 0 then
                    local sort_func
                    if i == 1 then
                        --第一个是主卡  
                        sort_func = SortTools.tableCommonSorter({{"lev", true}, {"id", true}})
                    else
                        sort_func = SortTools.tableCommonSorter({{"lev", false}, {"id", true}}) 
                    end
                    table_sort(self.conditions_hero_list[i], sort_func)

                    local count = 0
                    for _,hero_vo in ipairs(self.conditions_hero_list[i]) do
                        if self.dic_other_selected[hero_vo.id] == nil --[[and not hero_vo:checkHeroLockTips(true, nil, true)]] then
                            v.dic_select_list[hero_vo.id] = hero_vo
                            count = count + 1
                            if count >= v.count then
                                break
                            end
                        end
                    end
                    if count < v.count then
                        --说明不够..就不显示了
                        v.dic_select_list = {}
                    else
                        for k,v in pairs(v.dic_select_list) do
                            self.dic_other_selected[k] = v
                        end
                        v.lev = string_format("%s/%s", count, v.count)
                        if self.hero_item_list[i] then
                            self.hero_item_list[i].num_label:setString(v.lev)
                            if count > 0 then
                                self.hero_item_list[i]:setHeadUnEnabled(false)
                            else
                                self.hero_item_list[i]:setHeadUnEnabled(true)
                            end
                        end      
                    end
                end
            end
        end
    -- end

    --下面代码是加英雄魂的.
    local backpack_model = BackpackController:getInstance():getModel()
    if not backpack_model or not backpack_model.getHeroHunList then return end
    local list = backpack_model:getHeroHunList()
    for k, good_vo in pairs(list) do
        if good_vo.config then
            for i,conditions in ipairs(conditions_list) do
                if self.conditions_hero_list[i] == nil then
                    self.conditions_hero_list[i] = {}
                end
                if self.hero_item_data_list[i].bid == 0 then
                    --表示随机卡 0表示全部阵营
                    local camp_type = good_vo.config.camp_type
                    local star = good_vo.config.eqm_jie
                    if conditions[camp_type] and conditions[camp_type][star] ~= nil then
                        for j=1,good_vo.quantity do
                            local data = {}
                            data.id = -(j + camp_type * 10)
                            data.partner_id = data.id
                            data.good_vo = good_vo
                            table_insert(self.conditions_hero_list[i], data)
                        end
                    end
                end
            end
        end
    end
end
--计算中间item红点显示
function HeroUpgradeStarFusePanel:updateCentreHeroItemRedPoint()
    if not self.conditions_hero_list then return end
    if not self.dic_other_selected then return end
    --合成按钮的红点
    local is_btn_redpoint = true
    for i,item in ipairs(self.hero_item_list) do
        --模拟的hero_vo数据
        local hero_vo = self.hero_item_data_list[i]
        local conditions_list =  self.conditions_hero_list[i] or {}
        if hero_vo then
            local count = 0
            for k,v in pairs(hero_vo.dic_select_list) do
                count = count + 1
            end
            --已经填满了就不显示红点了
            if count < hero_vo.count then
                --随机卡的 --指定卡 逻辑一样的
                local num = hero_vo.count
                for i,each_hero in ipairs(conditions_list) do
                    --自已选的.和 别人没选的 都算数 
                    if hero_vo.dic_select_list[each_hero.partner_id] or self.dic_other_selected[each_hero.partner_id] == nil then 
                        num = num -1
                        if num == 0 then
                            break
                        end
                    end
                end
                --说明数量够 显示红点
                local status = (num <= 0) 
                item:showRedPoint(status, 8, 8)
                is_btn_redpoint = false
            else
                item:showRedPoint(false)
            end
        end
    end
    --中间合成按钮红点
    addRedPointToNodeByStatus(self.synthesis_btn, is_btn_redpoint, 6, 6)
end

--@ bid 英雄bid 特殊判断 如果 == nil 说明是随机卡
--@ star 星级
--@ count 数量
--@ camp_type 阵营  如果是随机卡.此一定需要有值
function HeroUpgradeStarFusePanel:getHeroData(bid, star, count, camp_type)
    --模拟 hero_vo 需要的数据
    local data = {}
    data.star = star or 0
    data.count = count or 0
    data.lev = string_format("%s/%s", 0, count)
    
    if bid == nil then
        data.bid = 0 --表示随机卡
        data.camp_type = camp_type
    else
        local base_config = Config.PartnerData.data_partner_base[bid]
        if base_config then
            data.bid = bid
            data.camp_type = base_config.camp_type
        else
            return nil
        end
    end
    --当前选中的英雄列表 [id] == hero_vo 模式
    data.dic_select_list = {}
    return data
end

--更新星星显示
function HeroUpgradeStarFusePanel:createStar(num)
    local num = num or 0
    local width = 29 + 3 
    self.star_setting = model:createStar(num, self.star_node, self.star_setting, width)
end

--更新模型,也是初始化模型
function HeroUpgradeStarFusePanel:updateSpine(fuse_data)
    if self.record_fuse_data ~= nil and self.record_fuse_data == fuse_data then
        return
    end
    self.record_fuse_data = fuse_data
    local fun = function()    
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.partner, fuse_data, nil,{scale = 1})
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(0,104))
            self.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            self.mode_node:addChild(self.spine)
            self.mode_node:setPositionY(66) 
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            self.spine:setScale(0.8)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        doStopAllActions(self.spine)
        self.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(self.spine)
                self.spine:removeFromParent()
                self.spine = nil
                fun()
        end)))
    else
        fun()
    end
end

function HeroUpgradeStarFusePanel:updateHeroList(select_camp, is_must_reset)
    local select_camp = select_camp or 0
    if not is_must_reset and select_camp == self.select_camp then 
        return
    end

    if self.scroll_view == nil then
        local scroll_view_size = cc.size(640,250)
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 4,
            space_y = 0,
            item_width = 128,
            item_height = 144,
            row = 0,
            col = 5,
            need_dynamic = true
        }
        local size = self.lay_scrollview:getContentSize()
        self.scroll_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    self.select_camp = select_camp
    local show_list = self.dic_fuse_info[self.select_camp]
    local sort_func = nil
    if MAKELIFEBETTER == true then
        sort_func = SortTools.tableLowerSorter({"aaaaa", "cur_redpoint","camp_type", "star", "bid"})
    else
        sort_func = SortTools.tableLowerSorter({"cur_redpoint","camp_type", "star", "bid"})
    end
    table.sort(show_list, sort_func)
    if #show_list == 0 then
        self.no_vedio_image:setVisible(true)
        self.no_vedio_label:setVisible(true)
        self.list_view:setData({})
        return
    else
        self.no_vedio_image:setVisible(false)
        self.no_vedio_label:setVisible(false)
    end
    if self.hero_vo then
        local bid = self.hero_vo.bid or 0
        local star = self.hero_vo.star or 0
        star = star + 1
        local select_index = 1
        for i,v in ipairs(show_list) do
            if bid == v.bid and star == v.star then
                select_index = i
            end
        end
        self.scroll_view:reloadData(select_index)    
        self.hero_vo = nil
    else
        self.scroll_view:reloadData()
         --默认选中第一个
        self:updateHeadHeroInfo(show_list[1])
    end

    
   
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroUpgradeStarFusePanel:createNewCell(width, height)
    local cell = HeroExhibitionItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroUpgradeStarFusePanel:numberOfCells()
    return #self.dic_fuse_info[self.select_camp]
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroUpgradeStarFusePanel:updateCellByIndex(cell, index)
    cell.index = index
    local fuse_data = self.dic_fuse_info[self.select_camp][index]
    if not fuse_data then return end
    cell:setData(fuse_data)
    local status = HeroCalculate.checkSingleStarFuseRedPoint(fuse_data)
    cell:showRedPoint(status)

    --此两个值是在上面红点计算后
    local need_count = fuse_data.need_count or 0
    local total_count = fuse_data.total_count  or 0
    local label = string_format("%s/%s", total_count, need_count)
    cell:showProgressbar(total_count * 100/ need_count, label)
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroUpgradeStarFusePanel:onCellTouched(cell)
    local index = cell.index
    local fuse_data = self.dic_fuse_info[self.select_camp][index]
    self:updateHeadHeroInfo(fuse_data)
end


--function HeroUpgradeStarFuseWindow:close_callback()
function HeroUpgradeStarFusePanel:DeleteMe()
    if self.spine then
        self.spine:DeleteMe()
        self.spine = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil

    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
             v:DeleteMe()
        end
        self.hero_item_list = nil
    end
    
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.resources_load then
        self.resources_load:DeleteMe()
    end
    self.resources_load = nil
    
    if self.item_load_camp then
        self.item_load_camp:DeleteMe()
    end
    self.item_load_camp = nil

    if self.hero_data_add then
        GlobalEvent:getInstance():UnBind(self.hero_data_add)
        self.hero_data_add = nil
    end

    if self.del_hero_event then
        GlobalEvent:getInstance():UnBind(self.del_hero_event)
        self.del_hero_event = nil
    end

    if self.star_select_event then
        GlobalEvent:getInstance():UnBind(self.star_select_event)
        self.star_select_event = nil
    end

    if self.hero_data_update then
        GlobalEvent:getInstance():UnBind(self.hero_data_update)
        self.hero_data_update = nil
    end

    if model.getIsFuseRedPoint and model:getIsFuseRedPoint() then
        controller:sender11055(0)
    end
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.guild, false)

end
