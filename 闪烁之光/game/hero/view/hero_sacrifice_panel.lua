-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      献祭《英雄和碎片》 融合 置换  回退(重生)
-- <br/>Create: 2018年11月9日
--
-- --------------------------------------------------------------------
HeroSacrificePanel = class("HeroSacrificePanel", function()
    return ccui.Widget:create()
end)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local partner_config = Config.PartnerData.data_get_compound_info

function HeroSacrificePanel:ctor()
    --献祭界面选中的对象列表 [key] =  value 模式
    self.dic_select_partner_vo = {}
    self.select_count = 0

    --策划写死最多10个
    self.select_max_count = 15
    --当前碎片数量
    self.cur_chip_count = 0
    --策划要求 7星以上不能分解 (策划要求暂时取消)
    -- self.limit_star = 7

    --是否播放特效 待发送协议中
    self.is_play_efffect = false

    self.setting = {y = -14}
    self:loadResources()
end

function HeroSacrificePanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_reset_bg", true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3", false), type = ResourcesType.single },
        
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        self:configUI()
        self:register_event()
        self:createRootWnd()
    end)
end

function HeroSacrificePanel:configUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_sacrifice_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_reset_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self.reset_container = self.main_panel:getChildByName("reset_container")
    self.reset_container:setVisible(false)
    self.disband_container = self.main_panel:getChildByName("disband_container")
    -- self.main_panel = main_container:getChildByName("main_panel")
    -- self.main_panel:getChildByName("win_title"):setString(TI18N("英雄献祭"))

    self.spine_node = self.disband_container:getChildByName("spine_node")


    self.tip_btn = self.disband_container:getChildByName("tip_btn")
    self.partner_btn = self.disband_container:getChildByName("partner_btn")
    --查看选中返回资源
    self.look_btn = self.disband_container:getChildByName("look_btn")

    --快速放入
    self.putin_btn = self.disband_container:getChildByName("putin_btn")
    self.putin_btn_label = self.putin_btn:getChildByName("label")
    self.putin_btn_label:setString(TI18N("快速放入"))

    self.cancel_btn = self.disband_container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("取消放入"))
    self.cancel_btn:setVisible(false)

    

    -- self.putin_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[263], 2)
    --献祭
    self.disband_btn = self.disband_container:getChildByName("disband_btn")
    self.disband_btn_lable = self.disband_btn:getChildByName("label")
    self.disband_btn_lable:setString(TI18N("献 祭"))
    -- self.disband_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[264], 2)

    self.item_bg_1 = self.disband_container:getChildByName("item_bg_1")
    self.max_btn = self.item_bg_1:getChildByName("max_btn")
    self.max_btn_label = self.max_btn:getChildByName("label")
    self.max_btn_label:setString(TI18N("max")) --应该有语言变化

    self.add_btn = self.item_bg_1:getChildByName("add_btn")
    self.add_btn_label = self.add_btn:getChildByName("label")
    self.redu_btn = self.item_bg_1:getChildByName("redu_btn")
    self.redu_btn_label = self.redu_btn:getChildByName("label")
    self.resolve_count = self.item_bg_1:getChildByName("resolve_count")

    --放入英雄数量
    self.lab_put_count = self.disband_container:getChildByName("lab_put_count")
    --拥有英雄数量
    self.lab_have_count = self.disband_container:getChildByName("lab_have_count")

    self.text_bg = self.disband_container:getChildByName("text_bg")

    local camp_node = self.disband_container:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

  

    --特效
    self.reset_effect = createEffectSpine("E24121", cc.p(385, 601), cc.p(0.5, 0.5), true, PlayerAction.action_1, 
        function()
            --特效完成一次调用函数
            self:effectCompleteOnce()
        end)
    self.spine_node:addChild(self.reset_effect, 1) 

    --添加可编辑的输入文本
    local res = PathTool.getResFrame("common","common_99998")
    local edit_content = createEditBox(self.item_bg_1, res,cc.size(90,50), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content = edit_content
    edit_content:setAnchorPoint(cc.p(0.5,0.5))
    edit_content:setPlaceholderFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setPosition(cc.p(114, 27))

    local begin_change_label = false
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if begin_change_label then  
                begin_change_label = false
                self.resolve_count:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" then
                    local num = tonumber(str)
                    if num ~= nil and num > 0 then
                        self:showEditNum(num)
                    else
                        self:showEditNum(0)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:showEditNum(0)
                end 

            end
        elseif strEventName == "began" then
            if not begin_change_label then
                self.resolve_count:setVisible(false)
                begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function HeroSacrificePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == false then
        self.is_send_proto = nil
        self:onClickBtnShowByIndex(0, true)
        doStopAllActions(self.disband_container)
    end
end



function HeroSacrificePanel:register_event()
    registerButtonEventListener(self.tip_btn, function(param,sender, event_type) 
        local config = Config.PartnerData.data_partner_const.game_rule1
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end ,true, 1)
    registerButtonEventListener(self.partner_btn, function() MallController:getInstance():openMallPanel(true,MallConst.MallType.Recovery) end ,true, 2)


    registerButtonEventListener(self.look_btn,  handler(self, self._onClickBtnLook) ,true, 1)
    registerButtonEventListener(self.putin_btn, handler(self, self._onClickBtnPutIn) ,true, 1)
    registerButtonEventListener(self.cancel_btn, handler(self, self._onClickBtnCancel) ,true, 1)
    registerButtonEventListener(self.disband_btn, handler(self, self._onClickBtnDisband) ,true, 1)

    registerButtonEventListener(self.max_btn, handler(self, self.onClickBtnMax) ,true, 1)
    registerButtonEventListener(self.add_btn, handler(self, self.onClickBtnAdd) ,true, 1)
    registerButtonEventListener(self.redu_btn, handler(self, self.onClickBtnRedu) ,true, 1)

      --阵营按钮
    for select_camp, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:onClickBtnShowByIndex(select_camp) end ,true, 2)
    end

    if not self.del_hero_event  then
        self.del_hero_event = GlobalEvent:getInstance():Bind(HeroEvent.Del_Hero_Event, function()
        self.dic_select_partner_vo = {}
        self:setLookBtnEffect()
        self.select_count = 0
        self:updateHeroList(self.select_camp, true)
        self.is_send_proto = false
        self.lab_put_count:setString(string_format(TI18N("已放入英雄:%s/%s"),self.select_count, self.select_max_count))
        end)
    end

        -- 增加物品的更新,这里需要判断增加的物品是不是当前标签页类型的,否则不刷新了
    if not self.add_good_event  then
        self.add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, add_list)
        if bag_code ~= BackPackConst.Bag_Code.BACKPACK then
            return 
        end
        local need_update = false
        for k, item in pairs(add_list) do
            if item.config and item.config.sub_type == BackPackConst.item_tab_type.HERO then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:onClickBtnShowByIndex(self.select_camp, true)
            self.is_send_proto = false
        end
        end)
    end

    -- 删除一个物品更新,也需要判断当前标签页类型
    if not self.delete_good_event  then
        self.delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
        if bag_code ~= BackPackConst.Bag_Code.BACKPACK then
            return 
        end
        if del_list == nil or next(del_list) == nil then return end
        local need_update = false
        for k, item in pairs(del_list) do
            if item.config and item.config.sub_type == BackPackConst.item_tab_type.HERO then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:onClickBtnShowByIndex(self.select_camp, true)
            self.is_send_proto = false
        end
        end)
    end

    if not self.modify_good_event  then
        self.modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,change_list)
        if bag_code ~= BackPackConst.Bag_Code.BACKPACK then
            return 
        end
        if change_list == nil or next(change_list) == nil then return end
        local need_update = false
        for k, item in pairs(change_list) do
            if item.config and item.config.sub_type == BackPackConst.item_tab_type.HERO then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:onClickBtnShowByIndex(self.select_camp, true)
            self.is_send_proto = false
        end
        end)
    end

end


--最大
function HeroSacrificePanel:onClickBtnMax()
    if not self.select_chip_data then return end
    self.cur_chip_count = self.select_chip_data.quantity
    self:updateLabelNum(self.cur_chip_count)
end
--加
function HeroSacrificePanel:onClickBtnAdd()
    if not self.select_chip_data then return end
    self.cur_chip_count = self.cur_chip_count + 1
    if self.cur_chip_count > self.select_chip_data.quantity then
        self.cur_chip_count = self.select_chip_data.quantity
    end
    self:updateLabelNum(self.cur_chip_count)
end
--减
function HeroSacrificePanel:onClickBtnRedu()
    if not self.select_chip_data then return end
    self.cur_chip_count = self.cur_chip_count - 1
    if self.cur_chip_count < 0 then
        self.cur_chip_count = 0
    end
    self:updateLabelNum(self.cur_chip_count)
end

function HeroSacrificePanel:updateLabelNum(count)
    if not self.select_chip_data then 
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(true)  
        self:setTouchEnable_Max(true) 
        self.resolve_count:setString(0)
        self.edit_content:setVisible(false)
        return 
    end
    self:setTouchEnable_Max(false)
    self.edit_content:setVisible(true)
    if count == 0 then
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(false)
    elseif count == self.select_chip_data.quantity then
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(true)
    else
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(false)
    end
    self.resolve_count:setString(count)
end

function HeroSacrificePanel:showEditNum(count)
    if not self.select_chip_data then return end
    self.cur_chip_count = count
    if self.cur_chip_count > self.select_chip_data.quantity then
        self.cur_chip_count = self.select_chip_data.quantity
    elseif self.cur_chip_count < 0 then
        self.cur_chip_count = 0
    end
    self:updateLabelNum(self.cur_chip_count)
end


function HeroSacrificePanel:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.add_btn)
    self.add_btn:setTouchEnabled(not bool)
    if bool then
        self.add_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        self.add_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
end
function HeroSacrificePanel:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.redu_btn)
    self.redu_btn:setTouchEnabled(not bool)
    if bool then
        self.redu_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        self.redu_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
end

function HeroSacrificePanel:setTouchEnable_Max(bool)
    setChildUnEnabled(bool,self.max_btn)
    self.max_btn:setTouchEnabled(not bool)
    if bool then
        self.max_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        self.max_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
end

--查看返回资源信息
function HeroSacrificePanel:_onClickBtnLook()
    if not self.dic_select_partner_vo then return {} end
    local hero_list = {}
    for k,v in pairs(self.dic_select_partner_vo) do
        table_insert(hero_list, {partner_id = v.partner_id})
    end
    if #hero_list > 0 then
        controller:openHeroResetReturnPanel(true, hero_list)
    else
        message(TI18N("没有选中英雄"))
    end
end
--取消放入
function HeroSacrificePanel:_onClickBtnCancel()
    local count = 0
    for k,v in pairs(self.dic_select_partner_vo) do
        v.is_ui_select = false
        count = count + 1
    end
    if count == 0 then
        message(TI18N("没有选中英雄"))
        return 
    end
    self.dic_select_partner_vo = {}
    self.select_count = 0
    self.is_show_cancel_label = false
    --以下下是放入英雄的
    if not self.list_view  then return end
    self:setLookBtnEffect()
    self.list_view:resetCurrentItems()
    self.lab_put_count:setString(string_format(TI18N("已放入英雄:%s/%s"),self.select_count, self.select_max_count))
end
--快速放入
function HeroSacrificePanel:_onClickBtnPutIn()
    if not self.show_list then return end
    if self.select_count >= self.select_max_count then
        message(string_format(TI18N("每次最多可献祭%s个英雄"), self.select_max_count))
        return
    end 
    local can_count = self:checkAutoPutCount()
    if can_count == 0 then
        message(TI18N("快速放入只能放入1~3星英雄"))
        return
    end

    local count = self.select_max_count - self.select_count
    for i,hero_vo in ipairs(self.show_list) do
        --快速放入只能放入 1 -3星的
        if hero_vo.star <= 3 and hero_vo.is_in_form <= 0 then
            if not hero_vo.is_ui_select then
                if hero_vo:checkHeroLockTips(true, nil, true) then
                    hero_vo.is_ui_select = false
                else
                    hero_vo.is_ui_select = true
                    self.dic_select_partner_vo[hero_vo.partner_id] = hero_vo
                    self.select_count = self.select_count + 1
                    count = count - 1
                    if count <= 0 then
                        break
                    end
                end
                
            end
        end
    end
    if self.select_count <= 0 then
        message("暂时没有可放入的英雄")
        return
    end
    --以下下是放入英雄的
    if not self.list_view  then return end
    self:setLookBtnEffect()
    self.list_view:resetCurrentItems()
    self.lab_put_count:setString(string_format(TI18N("已放入英雄:%s/%s"),self.select_count, self.select_max_count))
end

--检查还可以快速放入的个数
function HeroSacrificePanel:checkAutoPutCount( )
    local count = 0
    for i,hero_vo in ipairs(self.show_list) do
        --快速放入只能放入 1 -3星的
        if hero_vo and hero_vo.star <= 3 and hero_vo.is_in_form <= 0 then
            if not hero_vo.is_ui_select then
                count = count + 1
            end
        end
    end
    return count
end

--献祭
function HeroSacrificePanel:_onClickBtnDisband()
    if self.is_send_proto then return end
    self:disbandHero()
end


--献祭英雄
function HeroSacrificePanel:disbandHero()
    local hero_list = {}
    local is_show_tip = false
    for k,v in pairs(self.dic_select_partner_vo) do
        table_insert(hero_list, {partner_id = v.partner_id})
        if not is_show_tip then
            --策划要求 星级 > 5以上.需要提示
            if v.star >= 5 then
                is_show_tip = true
            end 
        end
    end
    if #hero_list > 0 then
        self.record_hero_list = hero_list
        controller:openHeroResetOfferPanel(true, hero_list, is_show_tip, function()
                if self.reset_effect then
                    self.is_play_efffect = true 
                    self.reset_effect:setAnimation(0, PlayerAction.action_2, false)
                    self:playEffect(true)
                end
                self.is_send_proto = true
                delayRun(self.disband_container, 1.2, function()
                    self:senderOffer()
                end)
        end, HeroConst.ResetType.eHeroReset)
    else
        message(TI18N("没有放入英雄"))
    end
end

function HeroSacrificePanel:senderOffer()
    if not self.record_hero_list then return end
    controller:sender11076(self.record_hero_list)
    self.record_hero_list = nil
end

--特效完成一次
function HeroSacrificePanel:effectCompleteOnce()
    if self.is_play_efffect then
        self.is_play_efffect = false
        self.reset_effect:setAnimation(0, PlayerAction.action_1, true)
    end
end

--显示根据类型 0表示全部
function HeroSacrificePanel:onClickBtnShowByIndex(select_camp, reset)
    if self.img_select and self.camp_btn_list[select_camp] then
        local x, y = self.camp_btn_list[select_camp]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    --把已选中的去掉
    self.dic_select_partner_vo = {}
    self.select_count = 0
    self:updateHeroList(select_camp, reset)
    --if self.select_index == HeroConst.SacrificeType.eHeroSacrifice then
    self.lab_put_count:setString(string_format(TI18N("已放入英雄:%s/%s"),self.select_count, self.select_max_count))
    self.cancel_btn:setVisible(false)

end

-- 切换标签页
function HeroSacrificePanel:changeSelectedTab()
    --elseif index == HeroConst.SacrificeType.eHeroSacrifice then   --英雄献祭
        self.reset_container:setVisible(false)
        self.disband_container:setVisible(true)
        --英雄献祭
        self.item_bg_1:setVisible(false)
        self.text_bg:setVisible(true)
        self.putin_btn:setVisible(true)
        self.cancel_btn:setVisible(false)
        self.lab_put_count:setVisible(true)
        self.look_btn:setVisible(true)
        self.disband_btn_lable:setString(TI18N("献 祭"))
        self:onClickBtnShowByIndex(0, true)
end

function HeroSacrificePanel:createRootWnd()
    
    self.is_send_proto = nil
    self:changeSelectedTab()
end

--获取英雄信息列表
function HeroSacrificePanel:getHeroListByCamp(select_camp)
    local hero_list = model:getHeroList()
    local show_list = {}
    local lock_list = {}

    for k, hero_vo in pairs(hero_list) do
        if not hero_vo:isResonateHero() and (select_camp == 0 or (select_camp == hero_vo.camp_type)) then
            -- 锁定 , 上阵, 7星以上都不能被分解
            if hero_vo:isLock() or (hero_vo.isInForm and hero_vo:isInForm()) then --or hero_vo.star >= self.limit_star then
                table_insert(lock_list, hero_vo)
            else
                table_insert(show_list, hero_vo)
            end
            hero_vo.is_ui_select = nil
        end
    end 
    local sort_func = SortTools.tableLowerSorter({"star", "lev", "camp_type", "bid", "sort_order"})
    table_sort(lock_list, sort_func) 
    table_sort(show_list, sort_func) 
    for i,hero_vo in ipairs(lock_list) do
        table_insert(show_list, hero_vo)
    end
    return show_list
end

--获取碎片信息


--创建英雄列表 
-- @select_camp 选中阵营
function HeroSacrificePanel:updateHeroList(select_camp, reset)
    local select_camp = select_camp or 0
    if not reset and select_camp == self.select_camp then 
        return
    end

    if not self.list_view then
        local scroll_view_size = cc.size(640,330)
        self.hero_setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 128,               -- 单元的尺寸width
            item_height = 122,              -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }

        local img_box_0 = self.disband_container:getChildByName("img_box_0")
        local x, y = img_box_0:getPosition()
        self.list_view = CommonScrollViewSingleLayout.new(self.disband_container, cc.p(x, y) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, self.hero_setting, cc.p(0.5,0.5))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.select_camp = select_camp
    --if self.select_index == HeroConst.SacrificeType.eHeroSacrifice then
        --英雄献祭
        
    self.show_list = self:getHeroListByCamp(select_camp)
    self.lab_have_count:setString(string_format(TI18N("可献祭英雄:%s"), #self.show_list))
    self.list_view:reloadData(nil, {item_height = 122})
    
    
    local count = #self.show_list

    
    if count == 0 then
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)
    end 
end
--显示空白
function HeroSacrificePanel:showEmptyIcon(bool)
    if not self.empty_con and bool == false then
        return
    end
    
    if not self.empty_con then
        local img_box_0 = self.disband_container:getChildByName("img_box_0")
        local x, y = img_box_0:getPosition()

        local size = cc.size(200, 200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5, 0.5))
        self.empty_con:setPosition(x, y)

        self.disband_container:addChild(self.empty_con, 10)
        local res = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3')
        local bg = createImage(self.empty_con, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), false)
        
        local login_data = LoginController:getInstance():getModel():getLoginData()
        self.empty_label = createLabel(26, Config.ColorData.data_color4[175], nil, size.width / 2, -10, '', self.empty_con, 0, cc.p(0.5, 0)) 
    end

    self.empty_label:setString(TI18N("暂无该类型英雄"))
    self.empty_con:setVisible(bool)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroSacrificePanel:createNewCell(width, height)
    local height = 122 --高度写死
    local cell = ccui.Widget:create()
    local hero_item = HeroExhibitionItem.new(0.9, true)
    hero_item:setPosition(width * 0.5 , height * 0.5)
    cell:addChild(hero_item)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell.hero_item = hero_item

    cell.hero_item:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroSacrificePanel:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroSacrificePanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    if hero_vo then
        cell.hero_item:setData(hero_vo)
        --设置选中状态 
        -- if self.select_index == HeroConst.SacrificeType.eHeroSacrifice then
        cell.hero_item:setSelected(hero_vo.is_ui_select == true)
        --英雄献祭
        if (hero_vo.isLock and hero_vo:isLock()) or (hero_vo.isInForm and hero_vo:isInForm()) then --or hero_vo.star >= self.limit_star then
            cell.hero_item:showLockIcon(true)
        else
            cell.hero_item:showLockIcon(false)
        end
        cell.hero_item:setPositionY(self.hero_setting.item_height * 0.5)
        cell.hero_item:showProgressbarStatus(false)
        cell.hero_item:showChipIcon(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroSacrificePanel:onCellTouched(cell)
    if self.is_send_proto then return end
    local index = cell.index
    local hero_vo = self.show_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    end
end


--@hero_vo 
function HeroSacrificePanel:selectHero(item, hero_vo)
    if not hero_vo  then return end
    if not item then return end
    if hero_vo:checkHeroLockTips(true) then
        return 
    end
    if self.dic_select_partner_vo[hero_vo.partner_id] == nil then
        if self.select_count >= self.select_max_count then
            message(string_format(TI18N("每次最多可献祭%s个英雄"), self.select_max_count))
            return
        end
        hero_vo.is_ui_select = true
        self.dic_select_partner_vo[hero_vo.partner_id] = hero_vo
        self.select_count = self.select_count + 1  
    else
        hero_vo.is_ui_select = false
        self.dic_select_partner_vo[hero_vo.partner_id] = nil
        self.select_count = self.select_count - 1  
    end
    item.hero_item:setSelected(hero_vo.is_ui_select)
    self.lab_put_count:setString(string_format(TI18N("已放入英雄:%s/%s"),self.select_count, self.select_max_count))

    self:setLookBtnEffect()
end


function HeroSacrificePanel:setLookBtnEffect()
    if next(self.dic_select_partner_vo) ~= nil then
        if not self.is_show_effect then
            self.is_show_effect = true
            doStopAllActions(self.look_btn)
            self.look_btn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.8, 1.1), cc.ScaleTo:create(0.8, 1))))
        end
        self.cancel_btn:setVisible(true)
    else
        self.is_show_effect = false
        doStopAllActions(self.look_btn)
        self.look_btn:runAction(cc.ScaleTo:create(0.5, 1))
        self.cancel_btn:setVisible(false)
    end
end

--播放火花的效果
function HeroSacrificePanel:playEffect(status)
    if status == false then
        if self.play_effect2 then
            self.play_effect2:clearTracks()
            self.play_effect2:removeFromParent()
            self.play_effect2 = nil
        end
    else
        
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_xianji")
        if self.play_effect2 == nil then
            self.play_effect2 = createEffectSpine("E24122", cc.p(380, 601), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.spine_node:addChild(self.play_effect2, 1)
        else
            self.play_effect2:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function HeroSacrificePanel:DeleteMe()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.reset_effect then
        self.reset_effect:clearTracks()
        self.reset_effect:removeFromParent()
        self.reset_effect = nil
    end

    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.modify_good_event then
        GlobalEvent:getInstance():UnBind(self.modify_good_event)
        self.modify_good_event = nil
    end
    if self.add_good_event then
        GlobalEvent:getInstance():UnBind(self.add_good_event)
        self.add_good_event = nil
    end
    if self.del_hero_event then
        GlobalEvent:getInstance():UnBind(self.del_hero_event)
        self.del_hero_event = nil
    end
    if self.delete_good_event then
        GlobalEvent:getInstance():UnBind(self.delete_good_event)
        self.delete_good_event = nil
    end
    --清空选中状态
    local hero_list = model:getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.is_ui_select = nil
    end
    self:playEffect(false)
    doStopAllActions(self.look_btn)
    doStopAllActions(self.disband_container)

    controller:openHeroResetWindow(false)
end