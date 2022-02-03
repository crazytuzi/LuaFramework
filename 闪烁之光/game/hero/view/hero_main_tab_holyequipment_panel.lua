-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竖版伙伴神装信息面板
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroMainTabHolyequipmentPanel = class("HeroMainTabHolyequipmentPanel", function()
    return ccui.Widget:create()
end)

local string_format = string.format
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()
local math_floor = math.floor


function HeroMainTabHolyequipmentPanel:ctor()  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroMainTabHolyequipmentPanel:config()
    --装备item 列表
    self.equip_item_list = {}

    self.equip_type_list = HeroConst.HolyequipmentPosList

    self.equip_icon_name_list = {
        [BackPackConst.item_type.GOD_EARRING] = "hero_info_25",  --耳环
        [BackPackConst.item_type.GOD_RING] = "hero_info_27",  --戒指
        [BackPackConst.item_type.GOD_NECKLACE] = "hero_info_26",  --项链
        [BackPackConst.item_type.GOD_BANGLE] = "hero_info_28",  --手镯
    }
    self.equip_name_suffix = {
        [BackPackConst.item_type.GOD_EARRING]  = 1,  --耳环
        [BackPackConst.item_type.GOD_NECKLACE] = 2,  --项链
        [BackPackConst.item_type.GOD_RING]     = 3,  --戒指
        [BackPackConst.item_type.GOD_BANGLE]   = 4,  --手镯   
    }


    --中间部分..显示
    self.border_item_load = {}
    self.suit_item_load = {}
    self.border_item_sprite = {} --边框图
    self.suit_item_sprite = {}   --套装图
    self.border_record_res = {}
    self.suit_record_res = {}

    --记录特效
    self.effect_item_list = {}
    self.record_effect_id = {}
end

function HeroMainTabHolyequipmentPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_main_tab_holyequipment_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.tab_panel = self.root_wnd:getChildByName("tab_panel")

    self.equip_node_list = {}
    for i=1,4 do
        local equip_type = self.equip_type_list[i] or i
        self.equip_node_list[i] = self.tab_panel:getChildByName("equip_node"..i)

        local item = BackPackItem.new(false,true,nil,0.9,false)
        -- 引导需要
        item:setName("guidehloye_equip_item_"..i)
        self.equip_node_list[i]:addChild(item,1)
        item:setPosition(cc.p(0,0))
        item:addCallBack(function() self:selectEquipByIndex(equip_type) end)
        local res= PathTool.getResFrame("hero",self.equip_icon_name_list[equip_type])
        local empty_icon = createImage(item:getRoot(), res,60,60, cc.p(0.5,0.5), true, 10, false)
        item.empty_icon = empty_icon
        self.equip_item_list[equip_type] = item

        self.border_item_sprite[i] = self.tab_panel:getChildByName("border_"..i)
        self.suit_item_sprite[i] = self.tab_panel:getChildByName("item_icon_"..i)
    end

    self.look_btn = self.tab_panel:getChildByName("look_btn")
    self.tips_lab = createRichLabel(22, cc.c4b(0x62,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(self.look_btn:getContentSize().width*0.5, self.look_btn:getContentSize().height*0.5),10,nil,100)
    self.look_btn:addChild(self.tips_lab)
    self.tips_lab:setString(TI18N("<div  href=detial>规则说明</div>"))
 

    self.holy_equip_bg = self.tab_panel:getChildByName("holy_equip_bg")
    if self.holy_equip_bg then
        local camp_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_holy_equip_bg", false)
        self.item_load = loadSpriteTextureFromCDN(self.holy_equip_bg, camp_res, ResourcesType.single, self.item_load) 
    end


    -- self.dungeon_label = createRichLabel(22,cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5),cc.p(70, 30))
    -- self.dungeon_label:setString(string_format("<div href=xxx>%s</div>", TI18N("祈祷获取")))
    -- self.tab_panel:addChild(self.dungeon_label)
    -- self.dungeon_label:addTouchLinkListener(function(type, value, sender, pos)
    --     -- message("等前往天界副本..等入口接口")
    --     HeavenController:getInstance():openHeavenDialWindow(true)
    --     --MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.HeavenWar)
    -- end, { "click", "href" })

    -- self.suit_label = createRichLabel(22,cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5),cc.p(184, 30))
    -- self.suit_label:setString(string_format("<div href=xxx>%s</div>", TI18N("神装图鉴")))
    -- self.tab_panel:addChild(self.suit_label)
    -- self.suit_label:addTouchLinkListener(function(type, value, sender, pos)
    --     HeroController:getInstance():openHeroClothesLustratWindow(true)
    -- end, { "click", "href" })

    -- self.suit_shop_label = createRichLabel(22,cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5),cc.p(300, 30))
    -- self.suit_shop_label:setString(string_format("<div href=xxx>%s</div>", TI18N("神装商店")))
    -- self.tab_panel:addChild(self.suit_shop_label)
    -- self.suit_shop_label:addTouchLinkListener(function(type, value, sender, pos)
    --     SuitShopController:getInstance():openSuitShopMainView(true)
    -- end, { "click", "href" })

    -- self.preview_label = createRichLabel(22,cc.c4b(0x64,0x32,0x23,0xff), cc.p(1,0.5),cc.p(660, 30))
    -- self.preview_label:setString(string_format("<div href=xxx>%s</div>", TI18N("加成总览")))
    -- self.tab_panel:addChild(self.preview_label)

    -- self.preview_label:addTouchLinkListener(function(type, value, sender, pos)
    --     if not self.hero_vo then return end
    --     local equip_list = model:getHeroHolyEquipList(self.hero_vo.partner_id)
    --     if next(equip_list) == nil then
    --         message(TI18N("暂无穿戴神装"))
    --         return 
    --     end
    --     local suit_data = self:getSuitData()
    --     controller:sender11086(self.hero_vo.partner_id, suit_data)
    -- end, { "click", "href" })

    self.tips = self.tab_panel:getChildByName("tips")
    self.tips:setString(TI18N(""))

    self.plan_btn = self.tab_panel:getChildByName("plan_btn")
    self.dungeon_btn = self.tab_panel:getChildByName("dungeon_btn")
    self.dungeon_btn:setName("guide_dungeon_btn")
    self.preview_btn = self.tab_panel:getChildByName("preview_btn")
    self.suit_btn = self.tab_panel:getChildByName("suit_btn")
    self.suit_shop_btn = self.tab_panel:getChildByName("suit_shop_btn")
    self.dungeon_btn_2 = self.tab_panel:getChildByName("dungeon_btn_2")
    -- self.plan_btn:getChildByName("label"):setString(TI18N("套装管理"))
end

--事件
function HeroMainTabHolyequipmentPanel:registerEvents()
    -- registerButtonEventListener(self.key_up_btn, function() self:onClickKeyUpBtn()  end ,true)
    -- registerButtonEventListener(self.discharge_btn, function() self:onClickDischargeBtn()  end ,true)
    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.PartnerHolyEqmData.data_const.game_rule_1
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end ,true, 1)

    registerButtonEventListener(self.plan_btn, function(param, sender, event_type) 
        if not self.hero_vo then return end
        local is_open = model:isOpenHolyEquipMentByHerovo(self.hero_vo)
        if not is_open then
            message(TI18N("因版本调整，当前该英雄尚未达到穿戴或更换神装条件，请努力提升至9星~"))
            return
        end
        controller:openHolyequipmentPlanPanel(true, self.hero_vo)
    end ,true, 1)
    registerButtonEventListener(self.dungeon_btn, function(param, sender, event_type) 

        HeavenController:getInstance():openHeavenMainWindow(true,nil,HeavenConst.Tab_Index.DialRecord)
        -- MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.heavenwar, HeavenConst.Tab_Index.DialRecord)
    end ,true, 1)
    registerButtonEventListener(self.preview_btn, function(param, sender, event_type) 
        if not self.hero_vo then return end
        local equip_list = model:getHeroHolyEquipList(self.hero_vo.partner_id)
        if next(equip_list) == nil then
            message(TI18N("暂无穿戴神装"))
            return 
        end
        local suit_data = self:getSuitData()
        controller:sender11086(self.hero_vo.partner_id, suit_data)
    end ,true, 1)
    registerButtonEventListener(self.suit_btn, function(param, sender, event_type) 
        HeroController:getInstance():openHeroClothesLustratWindow(true)
    end ,true, 1)
    registerButtonEventListener(self.suit_shop_btn, function(param, sender, event_type) 
        SuitShopController:getInstance():openSuitShopMainView(true)
    end ,true, 1)

    registerButtonEventListener(self.dungeon_btn_2, function(param, sender, event_type) 
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.heavenwar)
    end ,true, 1)
    

    if not self.hero_get_holy_equipment_event then
        self.hero_get_holy_equipment_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Get_Holy_Equipment_Event, function(list)
            if not list then return end
            if not self.hero_vo then return end
            for i,v in ipairs(list) do
                if v.partner_id == self.hero_vo.partner_id then
                    self:updateInfo(self.hero_vo)
                end
            end
        end)
    end

    if self.hero_holy_equipment_update_event == nil then
        self.hero_holy_equipment_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Holy_Equipment_Update_Event, function(hero_vo)
            if not hero_vo or not self.hero_vo then return end
            if hero_vo.partner_id == self.hero_vo.partner_id then
                self:updateInfo(self.hero_vo)
            end
        end)
    end
    -- if self.hero_data_update_event == nil then
    --     self.hero_data_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Update, function(hero_vo)
    --         if not hero_vo or not self.hero_vo then return end
    --         if hero_vo.partner_id == self.hero_vo.partner_id then
    --             self:updateArtifactInfo(self.hero_vo)
    --         end
    --     end)
    -- end

    -- --英雄信息更新
    -- if self.hero_equip_update_event == nil then
    --     self.hero_equip_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Equip_Update_Event, function()
    --         if not self.hero_vo then return end
    --         self:updateInfo(self.hero_vo)
    --         self:updateOneKeyBtnStatus()
    --     end)
    -- end
    -- --红点更新事件..英雄信息更新和 背包的信息更新 才能判断红点
    -- if self.hero_equip_redpoint_event == nil then
    --     self.hero_equip_redpoint_event = GlobalEvent:getInstance():Bind(HeroEvent.Equip_RedPoint_Event, function()
    --         if not self.hero_vo then return end
    --         self:updateRedPoint()
    --         self:updateOneKeyBtnStatus()
    --     end)
    -- end

end

--获取套装数据
function HeroMainTabHolyequipmentPanel:getSuitData()
    if not self.hero_vo then return end
    local equip_list = model:getHeroHolyEquipList(self.hero_vo.partner_id)
    local dic_suit_set = {}
    for k,euip_vo in pairs(equip_list) do
        if dic_suit_set[euip_vo.config.eqm_set] == nil then
            dic_suit_set[euip_vo.config.eqm_set] = 1
        else
            dic_suit_set[euip_vo.config.eqm_set] = dic_suit_set[euip_vo.config.eqm_set] + 1
        end
    end
    local suit_data_list = {}
    for eqm_set, count in pairs(dic_suit_set) do
        local suit_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
        if suit_config then
            for i,v in ipairs(suit_config) do
                if  (v.skill_id and next(v.skill_id) ~= nil) and count >= v.num then
                    --说明是激活的
                    local attr = v.skill_id[#v.skill_id]
                    if type(attr) == "number" then
                        --是技能才需要在那边显示
                        local data = {}
                        data.num = v.num
                        data.skill_id = 0
                        local skill_desc = v.all_skill_desc[#v.all_skill_desc] --神装套装描述 
                        data.skill_desc = skill_desc[2] or TI18N("描述信息无")
                        if skill_desc[1] and skill_desc[1] == 2 then
                            --说明是技能
                            data.skill_id = attr
                        end
                        table_insert(suit_data_list, data)
                    end
                end
            end
        end
    end

    return suit_data_list
end

--@ index 索引  如果是装备可以是装备类型 equip_type
function HeroMainTabHolyequipmentPanel:selectEquipByIndex(index)
    if not self.hero_vo then return end

    local equip_type = index
    local equip_list = model:getHeroHolyEquipList(self.hero_vo.partner_id)
    local equip_vo = equip_list[equip_type]
    if equip_vo ~= nil then
        controller:openEquipTips(true, equip_vo, PartnerConst.EqmTips.partner, self.hero_vo) 
    else
        local is_open = model:isOpenHolyEquipMentByHerovo(self.hero_vo)
        if not is_open then
            message(TI18N("因版本调整，当前该英雄尚未达到穿戴或更换神装条件，请努力提升至9星~"))
            return
        end
        controller:openHeroHolyEquipClothPanel(true,equip_type,self.hero_vo.partner_id,nil,nil,nil,self.hero_vo)
    end
end


function HeroMainTabHolyequipmentPanel:setData(hero_vo)
    if not hero_vo then return end
    self.hero_vo = hero_vo

    if self.hero_vo:ishaveHolyEquipmentData() then
        self:updateInfo(hero_vo)
    end
end

function HeroMainTabHolyequipmentPanel:updateRedPoint()
    local is_open = model:isOpenHolyEquipMentByHerovo(self.hero_vo)
    if not is_open then
        return
    end
    --装备红点
    local equip_list = model:getHeroHolyEquipList(self.hero_vo.partner_id)
    for i,equip_type in ipairs(self.equip_type_list) do
        local item = self.equip_item_list[equip_type]
        if item then
            if equip_list[equip_type] == nil then
                local is_redpoint = HeroCalculate.checkHolyEquipmentByEquipType(equip_type)
                item:showRedPoint(is_redpoint)
            else
                item:showRedPoint(false)
            end
        end
    end
end

function HeroMainTabHolyequipmentPanel:updateInfo(hero_vo)
    if not hero_vo then return end
    --装备信息
    local equip_list = model:getHeroHolyEquipList(hero_vo.partner_id)

    --计算套装数量
    local dic_suit_set = {}

    for k,equip_vo in pairs(equip_list) do
        local eqm_key = math_floor(equip_vo.config.eqm_set/100)
        if dic_suit_set[eqm_key] == nil then
            dic_suit_set[eqm_key] = 1
        else
            dic_suit_set[eqm_key] = dic_suit_set[eqm_key] + 1
        end
    end

    local base_config =  Config.PartnerHolyEqmData.data_base_info
    --是否已播放第一个特效
    self.first_effect_set = nil 
    for i,_type in ipairs(self.equip_type_list) do
        local equip_vo = equip_list[_type]
        local item = self.equip_item_list[_type]
        if equip_vo then
            item:setData(equip_vo)
            if item.empty_icon then 
                item.empty_icon:setVisible(false)
            end
            item.equip_vo = equip_vo
            local config = base_config(equip_vo.config.id)
            if config then
                item:setGoodsName(config.show_name, nil, 20, cc.c3b(0xff,0xf0,0xd9), cc.c3b(0x43,0x32,0x1d))
            end
            self:updateCenterUI(true, _type, equip_vo, dic_suit_set)
        else
            item:setData()
            if item.empty_icon then 
                item.empty_icon:setVisible(true)
            end
            item:setGoodsName("")
            item.equip_vo = nil
            self:updateCenterUI(false, _type)
        end
    end
    self:updateRedPoint()
end

--更新中间部分ui
--显示状态 status
--@_type 类型:
function HeroMainTabHolyequipmentPanel:updateCenterUI(status, _type, equip_vo, dic_suit_set)
    local pos = self.equip_name_suffix[_type]
    if status then
        if self.suit_item_sprite[pos] then
            if not equip_vo or not equip_vo.config then return end
            local id = math.floor(equip_vo.config.eqm_set/100)
            local config = Config.PartnerHolyEqmData.data_suit_res_prefix_fun(id)
            if not config then return end
            local res_name = string_format("%s_%s", config.prefix, pos)
            self.suit_item_sprite[pos]:setVisible(true)
            if self.suit_record_res[pos] == nil or self.suit_record_res[pos] ~= res_name then
                self.suit_record_res[pos] = res_name
                local res = PathTool.getPlistImgForDownLoad("hero/holy_eqm",res_name, false)
                self.suit_item_load[pos] = loadSpriteTextureFromCDN(self.suit_item_sprite[pos], res, ResourcesType.single, self.suit_item_load[pos])
            end
        end

        if self.border_item_sprite[pos] then
            if not equip_vo or not equip_vo.config then return end
            local res_name = string_format("border_%s_%s", equip_vo.config.eqm_star, pos)
            self.border_item_sprite[pos]:setVisible(true)
            if self.border_record_res[pos] == nil or self.border_record_res[pos] ~= res_name then
                self.border_record_res[pos] = res_name
                local res = PathTool.getPlistImgForDownLoad("hero/holy_eqm",res_name, false)
                self.border_item_load[pos] = loadSpriteTextureFromCDN(self.border_item_sprite[pos], res, ResourcesType.single, self.border_item_load[pos])
            end
        end
        if dic_suit_set then
            local eqm_key = math_floor(equip_vo.config.eqm_set/100)
            --特效的计算太麻烦了.我写死判断 套装数 : 4个   2个..如果以后多了再改
            if dic_suit_set[eqm_key] >= 4 then
                -- if _type == BackPackConst.item_type.GOD_EARRING then
                    self:showEffectByIndex(true, _type, 3)
                -- end
            elseif dic_suit_set[eqm_key] >= 2 then
                if self.first_effect_set ~= nil and self.first_effect_set ~= eqm_key then
                    self:showEffectByIndex(true, _type, 2)
                else
                    self.first_effect_set = eqm_key
                    self:showEffectByIndex(true, _type, 1)
                end
            else
                self:showEffectByIndex(false, _type)
            end
        end
    else
        if self.suit_item_sprite[pos] then
            self.suit_item_sprite[pos]:setVisible(false)
        end

        if self.border_item_sprite[pos] then
            self.border_item_sprite[pos]:setVisible(false)
        end

        self:showEffectByIndex(false, _type)
    end
end

function HeroMainTabHolyequipmentPanel:showEffectByIndex(status, _type, index)
    if status then
        if self.record_effect_id[_type] == nil or self.record_effect_id[_type] ~= index then 
            self.record_effect_id[_type] = index
            local effect_str = "E2442"..index
            self:showEffectByIndex(false, _type)
            -- self.effect_item_list[_type] = createEffectSpine(effect_str, cc.p(337, 206), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.effect_item_list[_type] = createEffectSpine(effect_str, cc.p(340, 196), cc.p(0.5, 0.5), true, PlayerAction.action)
            if _type == BackPackConst.item_type.GOD_NECKLACE then--项链
                self.effect_item_list[_type]:setScale(-0.9, 0.9)
            elseif _type == BackPackConst.item_type.GOD_RING then--戒指
                self.effect_item_list[_type]:setScale(0.9, -0.9)
            elseif _type == BackPackConst.item_type.GOD_BANGLE then--手镯
                self.effect_item_list[_type]:setScale(-0.9, -0.9)
            else
                self.effect_item_list[_type]:setScale(0.9, 0.9)
            end
            self.tab_panel:addChild(self.effect_item_list[_type], 10)
        end
    else
        if self.effect_item_list[_type] then
            self.effect_item_list[_type]:clearTracks()
            self.effect_item_list[_type]:removeFromParent()
            self.effect_item_list[_type] = nil
            self.record_effect_id[_type] = nil
        end
    end
end



function HeroMainTabHolyequipmentPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end


--移除
function HeroMainTabHolyequipmentPanel:DeleteMe()
    if self.hero_get_holy_equipment_event then
        GlobalEvent:getInstance():UnBind(self.hero_get_holy_equipment_event)
        self.hero_get_holy_equipment_event = nil
    end
    if self.hero_holy_equipment_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_holy_equipment_update_event)
        self.hero_holy_equipment_update_event = nil
    end


    if self.hero_data_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_data_update_event)
        self.hero_data_update_event = nil
    end
    if self.hero_equip_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_equip_update_event)
        self.hero_equip_update_event = nil
    end
    if self.hero_equip_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.hero_equip_redpoint_event)
        self.hero_equip_redpoint_event = nil
    end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    
    if self.suit_item_load then
        for k,v in pairs(self.suit_item_load) do
            v:DeleteMe()
        end
        self.suit_item_load = nil
    end
    if self.border_item_load then
        for k,v in pairs(self.border_item_load) do
            v:DeleteMe()
        end
        self.border_item_load = nil
    end

    for k,euip_type in ipairs(self.equip_type_list) do
        self:showEffectByIndex(false, euip_type)
    end

end
