-- --------------------------------------------------------------------
-- z装备新版tips
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EquipTips = EquipTips or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local role_vo = RoleController:getInstance():getRoleVo()
local math_floor = math.floor

function EquipTips:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/equip_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips    
    self.base_list = {}
    self.suit_item_list = {}
    self.random_item_list = {}
    -- self.enchant_list = {}
    -- self.gemstone_list = {}

    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.ohter_list = {}
    self.cloth_type = 1
    self.is_need = true

    --道具配置
    self.item_config = nil
    --套装配置
    self.suit_config = nil
end

function EquipTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        self.background:setSwallowTouches(false)
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")            -- 背景,需要动态设置尺寸
    self.container_init_size = self.container:getContentSize()

    -- 基础属性,名字,类型和评分等
    self.base_panel = self.container:getChildByName("base_panel")
    self.score_title = self.base_panel:getChildByName("score_title")
    self.score_title:setString(TI18N("评分："))
    self.equip_item =  BackPackItem.new(true,true,nil,1,false)
    self.equip_item:setPosition(cc.p(72,68))
    self.base_panel:addChild(self.equip_item)
    self.name = self.base_panel:getChildByName("name")
    self.equip_type = self.base_panel:getChildByName("equip_type")
    self.power_label = CommonNum.new(1, self.base_panel, 1, - 2, cc.p(0, 0))
    self.power_label:setPosition(cc.p(220, 32))
    self.power_label:setNum(0)
    self.power_label:setScale(0.8) 

    self.look_btn = self.base_panel:getChildByName("look_btn")
    self.look_btn:setVisible(false)

    self.suit_icon = self.base_panel:getChildByName("suit_icon")
    self.suit_name = self.base_panel:getChildByName("suit_name")
    -- 基础属性
    self.baseattr_panel = self.container:getChildByName("baseattr_panel")
    self.baseattr_panel:getChildByName("label"):setString(TI18N("基础属性"))

    --随机属性
    self.randomattr_panel = self.container:getChildByName("randomattr_panel")
    self.randomattr_panel_height = self.randomattr_panel:getContentSize().height
    self.randomattr_name  = self.randomattr_panel:getChildByName("label")
    self.pre_btn = self.randomattr_panel:getChildByName("pre_btn")
    self.pre_btn:getChildByName("label"):setString(TI18N("类型预览"))

    --套装属性
    self.suitattr_panel = self.container:getChildByName("suitattr_panel")
    self.suitattr_panel_height = self.suitattr_panel:getContentSize().height
    self.suitattr_name  = self.suitattr_panel:getChildByName("label")

    --技能
    self.skill_panel = self.container:getChildByName("skill_panel")
    self.skill_panel_height = self.skill_panel:getContentSize().height
    -- self.skill_text = createRichLabel(22, cc.c3b(255, 238, 221), cc.p(0, 1), cc.p(14, 190), 8, nil, 370)
    -- self.skill_panel:addChild(self.skill_text)

    -- 按钮部分
    self.tab_panel = self.container:getChildByName("tab_panel")
    self.tab_panel_height = self.tab_panel:getContentSize().height

    self.tab_btn_3 = self.tab_panel:getChildByName("tab_btn_3")
    self.tab_btn_3:setTitleText(TI18N("穿戴"))
    self.tab_btn_3:getTitleRenderer():enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    self.tab_btn_2 = self.tab_panel:getChildByName("tab_btn_2")
    self.tab_btn_2:setTitleText(TI18N("洗练"))
    self.tab_btn_2:getTitleRenderer():enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)
    self.tab_btn_2.need_str = ""
    self.tab_btn_1 = self.tab_panel:getChildByName("tab_btn_1")
    self.tab_btn_1:setTitleText(TI18N("卸下"))
    self.tab_btn_1.need_str = ""
    self.tab_btn_1:getTitleRenderer():enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)

    -- 描述部分
    self.desc_panel = self.container:getChildByName("desc_panel")
    self.scroll_view = self.desc_panel:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()
    self.desc_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(20, 64), 8, nil, 380)
    self.scroll_view:addChild(self.desc_label)

    self.close_btn = self.container:getChildByName("close_btn")
    -- self:checkIsShowBtn()
end

function EquipTips:register_event()
    --穿戴 和更换
    self.tab_btn_3:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onTabBtn3()
        end
    end)
    self.tab_btn_2:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onTabBtn2()
        end
    end)
    --卸下和出售
    self.tab_btn_1:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:onTabBtn1()
        end
    end)

    registerButtonEventListener(self.close_btn, function() self:onClickCloseBtn() end ,true, 1) 
    registerButtonEventListener(self.background, function() self:onClickCloseBtn() end ,false, 0) 

    registerButtonEventListener(self.pre_btn, function(param,sender, event_type) 
        if not self.data or not self.item_config then return end
        local config = Config.PartnerHolyEqmData.data_base_info(self.item_config.id)
        if config then
            TipsManager:getInstance():showCommonTips(config.tips_info, sender:getTouchBeganPosition())
        end
    end ,true, 2)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.PartnerHolyEqmData.data_const.game_rule_1
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end ,true, 2, nil, 0.8)
    --神装信息更新
    self:addGlobalEvent(HeroEvent.Holy_Equipment_Update_Event, function (hero_vo)
        if not hero_vo then return end
        if not self.data or not self.item_config then return end
        if hero_vo.partner_id and hero_vo.partner_id == self.partner_id then
            self:initData()
        end
    end)
end

function EquipTips:addDataBindEvent()
    --注册道具 goodsvo的变化事件..属性变化了才刷新
    if self.partner_id == nil or self.partner_id == 0 then
        if self.data and self.data.Bind and self.item_update_event == nil then
            self.item_update_event = self.data:Bind(GoodsVo.UPDATE_GOODS_ATTR, function(key, value) 
                if key == "holy_eqm_attr" then
                    self:initData()
                end
            end)
        end
    end
end

--关闭
function EquipTips:onClickCloseBtn()
    controller:openEquipTips(false)
end


function EquipTips:onTabBtn2()
    if not self.data then return end
    if not self.item_config then return end
    -- if self.is_need == false then 
    --     message(self.tab_btn_2.need_str)
    --     return
    -- end
    if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        --神装的是洗练
        HeroController:getInstance():openHolyequipmentRefreshAttPanel(true, self.data, self.partner_id)
    end
end

--卸下和出售
function EquipTips:onTabBtn1()
    if not self.data or not self.data.id or not self.item_config then return end
    if self.cloth_type ==  PartnerConst.EqmTips.backpack then  --1是出售
        
        if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            local color = BackPackConst.getWhiteQualityColorStr(self.item_config.quality)
            local str = string.format(TI18N("出售 <div fontcolor=%s>【%s】</div>可获得以下资源（已包含返还的60%%的洗练消耗），是否确定出售？"), color,self.item_config.name)
            controller:openHeroResetOfferPanel(true, {{item_id=self.data.id}}, false, function()
                    if HeroController:getInstance():getModel():checkHolyEquipmentPalnByItemID(self.data.id) then
                        local tips_str = TI18N("该神装已装配在方案中，继续出售将会清除其在方案中的配置，是否继续？")
                        CommonAlert.show(tips_str, TI18N("确定"), function()
                            controller:sender11089({{item_id=self.data.id}})
                        end, TI18N("取消"), nil, CommonAlert.type.common)
                    else
                        controller:sender11089({{item_id=self.data.id}})
                    end
            end, HeroConst.ResetType.eHolyEquipSell, str)    
        else
            BackpackController:getInstance():openItemSellPanel(true, self.data, BackPackConst.Bag_Code.EQUIPS)
        end
        controller:openEquipTips(false) 
    elseif self.cloth_type ==  PartnerConst.EqmTips.partner then --2是卸下
        --装备唯一id
        if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            if self.holy_data and self.holy_data.list then --神装方案卸下装备
                local partner_id = self.holy_data.partner_id or 0
                local list = {}
                --方案中已有的装备
                if self.holy_data.list and next(self.holy_data.list) ~= 0 then
                    for k,v in ipairs(self.holy_data.list) do
                        if v and v.item_id then
                            table.insert(list, {partner_id = v.partner_id, item_id = v.item_id})
                        end
                    end
                end
                --卸下的装备
                for i=#list,1,-1 do
                    if list[i] and list[i].item_id == self.data.id then
                        table.remove(list, i)
                    end
                end
                controller:sender25221(self.holy_data.id, partner_id, self.holy_data.name, list)
            else
                if HeroController:getInstance():getModel():isOpenHolyEquipMentByHerovo(self.partner) == false then
                    local str = TI18N("因版本调整，当前该宝可梦尚未达到开启神装所需星级条件，卸下后将无法立即穿戴，是否确认卸下？")
                    local function fun()
                        controller:sender11093(self.partner_id, self.data.id, 0)
                        controller:openEquipTips(false)
                    end
                    CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                    return
                end
                controller:sender11093(self.partner_id, self.data.id, 0)
            end
        else 
            controller:sender11011(self.partner_id, self.data.id)
        end

        controller:openEquipTips(false)
    end
end
--穿戴和更换
function EquipTips:onTabBtn3()
    if not self.data then return end
    if not self.item_config then return end
    local partner_id = self.partner_id or 0
    local item_id = self.data.id or 0
    local pos_id = self.item_config.type or 0
    if self.cloth_type ==  PartnerConst.EqmTips.backpack then  --1是穿戴
        if partner_id == 0  then 
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner,1)
        else
            controller:sender11010(partner_id,item_id)
        end
        
    elseif self.cloth_type ==  PartnerConst.EqmTips.partner then --2是更换
        if self.holy_data and self.holy_data.list then --神装方案更换装备
            controller:openHeroHolyEquipClothPanel(true, pos_id, 0, self.data, self.holy_data, HeroConst.EnterType.eHolyPlan,nil,self.holy_data.equip_list)
        else
            if BackPackConst.checkIsHolyEquipment(pos_id) then
                local is_open = HeroController:getInstance():getModel():isOpenHolyEquipMentByHerovo(self.partner)
                if not is_open then
                    message(TI18N("因版本调整，当前该宝可梦尚未达到穿戴或更换神装条件，请努力提升至9星~"))
                    return
                end
                controller:openHeroHolyEquipClothPanel(true, pos_id, self.partner_id, self.data,nil,nil,self.partner)
            else
                controller:openEquipPanel(true, pos_id, self.partner_id, self.data)
            end
        end
    end
    controller:openEquipTips(false)
end

--[[
    @desc: 打开时候附加的参数
    author:{author}
    time:2019-05-19 19:48:51
    --@object: {data=data, open_type=open_type, partner=partner, holy_data=holy_data}
    @return:
]]
function EquipTips:openRootWnd(object)
    self.data = object.data
    self.cloth_type = object.open_type or PartnerConst.EqmTips.normal
    self.partner = object.partner
    if self.partner then
        self.partner_id = self.partner.partner_id
    end
    self.holy_data = object.holy_data
    -- 因为传参不同,这边需要获取不同的配置数据
    local data = object.data
    local item_config = nil
    if type(data) == "number" then
        item_config = Config.ItemData.data_get_data(data)
    else
        if data.config then
            item_config = data.config
        else
            if data.bid then
                item_config = Config.ItemData.data_get_data(data.bid)
            elseif data.id then
                item_config = Config.ItemData.data_get_data(data.id)
            else
                item_config = data
            end
        end
    end
    self.item_config = item_config
    if self.item_config == nil then return end
    self:initData()
    self:addDataBindEvent()

    --限购INXS
    -- self:initLimitBuyInfo()
end

--限购信息
--data.limit_total_num = 限购最大数量
--data.limit_day  每日限购数量
--data.其他限购未加入
function EquipTips:initLimitBuyInfo()
    if not self.data then return end
    if self.data.limit_day then --每日限购
        local total_count = self.data.limit_total_num or 0
        local label = self:getLimitBuytLabel()
        if lable then
            lable:setString(string_format(TI18N("每日限购<div fontcolor=#249003>%s/%s</div>个"), self.data.limit_day, total_count))
        end
    end
end

function EquipTips:getLimitBuytLabel()
    if self.limit_buy_label == nil then
        self.limit_buy_label = createRichLabel(22, cc.c4b(0xff,0xee,0xdd,0xff), cc.p(0, 0.5), cc.p(0, 36) ,nil,nil,1000)
        self.main_container:addChild(self.limit_buy_label)
    end
    return self.limit_buy_label
end

function EquipTips:initData()
     --原本高度
    local target_height  = self.container_init_size.height
    --是否显示随机属性-------------开始 --神装才有
    local need_show_randomattr = false
    if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        need_show_randomattr = true
    end
    local randomattr_height = 0
    if need_show_randomattr then
        --随机属性（仅当为神装图鉴的时候会带参数）
        randomattr_height = self:setRandomAttrInfo(self.data.lustr_status)
        if randomattr_height > 0 then
            target_height = target_height + randomattr_height
        else
            randomattr_height = 0
            self.randomattr_panel:setVisible(false)
            need_show_randomattr = false
        end
    else
        self.randomattr_panel:setVisible(false)
    end
    --是否显示随机属性----------结束

    --是否显示套装属性-----------开始
    local need_show_suitattr = false
    local need_show_skill = nil
    local suitattr_height = 0

    --特殊判定外语版且神装类型的套装描述，需要修改尺寸，加高26
    local code = cc.Application:getInstance():getCurrentLanguageCode()
    if code ~= "zh" and self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then
        self.suitattr_name:setContentSize(cc.size(480, self.suitattr_name:getContentSize().height + 26))
        self.suitattr_panel_height = self.suitattr_panel:getContentSize().height + 26
    end

    if self.item_config.eqm_set ~= 0 then
        if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            self.suit_config = Config.PartnerHolyEqmData.data_suit_info[self.item_config.eqm_set]
        elseif self.item_config.sub_type == BackPackConst.item_tab_type.EQUIPS then--普通装备 
            self.suit_config = Config.PartnerEqmData.data_eqm_suit[self.item_config.eqm_set]
        end

        if self.suit_config then
            need_show_suitattr = true
            table_sort( self.suit_config, function(a, b) return a.num < b.num end)
        end
    end
    if need_show_suitattr then
        suitattr_height, need_show_skill = self:setSuitAttrInfo()
        if suitattr_height > 0 then
            target_height = target_height + suitattr_height
        else
            suitattr_height = 0
            self.suitattr_panel:setVisible(false)
            need_show_suitattr = false
        end
    else
        self.suitattr_panel:setVisible(false)
    end
    --是否显示套装属性-----------结束
    
    --是否显示技能 ------------ 开始 神装才有 必须在套装属性之后 因为判断在套装数据里面
    if self.item_config.sub_type ~= BackPackConst.item_tab_type.HOLYEQUIPMENT then 
        --不是神装没有技能显示
        need_show_skill = nil
    end
    if need_show_skill ~= nil then
        local config = Config.SkillData.data_get_skill(need_show_skill)
        if config then
            target_height = target_height + self.skill_panel_height
            if self.skill_item == nil then
                self.skill_item = self:createSkillItem(self.skill_panel)
            end
            self.skill_item.skill:showLockIcon(false)
            self.skill_item.skill:setData(config)
            -- self.skill_item.name:setString(config.name)
            self.skill_item.desc:setString(config.des)
        else
            need_show_skill = false
        end
    end

    --是否显示技能 ------------ 结束

    -- 是否显示按钮部分
    local need_show_btn = (self.cloth_type == PartnerConst.EqmTips.backpack or self.cloth_type == PartnerConst.EqmTips.partner)   
    if need_show_btn then
        self:updateBtnList()
    else
        target_height = target_height - self.tab_panel_height
        self.tab_panel:setVisible(false)
    end

    --公会宝库时间
    if self.data and self.data.is_market_place and next( self.data.end_time) ~= nil then
        self.market_time_label = createRichLabel(24, cc.c4b(0xff,0x9b,0x1e,0xff), cc.p(0, 1), cc.p(17, -10000), 8, nil, 1000) 
        self.container:addChild(self.market_time_label)
        local time = self.data.end_time[1].end_unixtime or 0
        local count = self.data.end_time[1].end_num or 1
        local str 
        local time = time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        if time <= 0 then
            str = string.format(TI18N("%s个物品已过期"), count)
        else
            str = string.format(TI18N("%s个物品于<div fontcolor=#249003>%s</div>后过期"), count, TimeTool.GetTimeFormatDayIIIIII(time))    
        end 
        self.market_time_label:setString(str)
        local size = self.market_time_label:getContentSize()
        target_height = target_height + size.height
    end

    if target_height ~= self.container_init_size.height then
        self.container:setContentSize(cc.size(self.container_init_size.width, target_height + 40))
        local y = target_height + 40 - 4
        self.base_panel:setPositionY(y) --基本信息
        self.close_btn:setPositionY(y - 11)
        y = y - self.base_panel:getContentSize().height 
        self.baseattr_panel:setPositionY(y) --基础属性
        y = y - self.baseattr_panel:getContentSize().height

        if need_show_randomattr then --随机属性
            self.randomattr_panel:setPositionY(y)
            y = y - randomattr_height
        end

        if need_show_suitattr then --套装属性
            self.suitattr_panel:setPositionY(y)
            y = y -  suitattr_height
        end

        if need_show_skill then --技能显示
            self.skill_panel:setPositionY(y)
            y = y - self.skill_panel_height --技能显示的高目前是写死的
        end

        self.desc_panel:setPositionY(y)
        if need_show_btn then
            y = y - self.desc_panel:getContentSize().height
            self.tab_panel:setPositionY(y)
        end
        --公会宝库时间 --因为与 need_show_btn是互斥的所以不做兼容处理了
        if self.data and self.data.is_market_place then
            y = y - self.desc_panel:getContentSize().height
            self.market_time_label:setPositionY(y)
        end
    end

    self:setBaseInfo()
    self:setBaseAttrInfo()
end

function EquipTips:updateBtnList()
    self.tab_btn_3:setVisible(true)
    self.tab_btn_2:setVisible(false)
    if self.cloth_type == PartnerConst.EqmTips.backpack then  --穿戴
        self.tab_btn_3:setTitleText(TI18N("穿戴"))
        self.tab_btn_1:setTitleText(TI18N("出售"))
    elseif self.cloth_type == PartnerConst.EqmTips.partner then  --卸下
        --判定红点
        --不是神装才判断红点
        if self.item_config and self.item_config.sub_type ~= BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            local is_redpoint = HeroCalculate.checkSingleHeroEachPosEquipRedPoint(self.item_config.type, self.data)
            addRedPointToNodeByStatus(self.tab_btn_3, is_redpoint, 5, 5)
        end

        self.tab_btn_3:setTitleText(TI18N("更换"))
        self.tab_btn_1:setTitleText(TI18N("卸下"))
    else
        self.tab_btn_3:setVisible(false)
        -- self.tab_btn_2:setVisible(false)
    end
    if self.item_config and self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        self.tab_btn_2:setVisible(true)
        self.look_btn:setVisible(true)
        if self.item_config.eqm_jie <= 0 then
            setChildUnEnabled(true, self.tab_btn_2)
            self.tab_btn_2:setTitleText(TI18N("无法洗练"))
            self.tab_btn_2:setTouchEnabled(false)
        end
    end

    -- 只要不是来自自己伙伴身上的
    if self.cloth_type ~= PartnerConst.EqmTips.partner then
        -- self.tab_btn_1:setVisible(false)
    end
    
end

--==============================--
--desc:设置基础属性
--time:2018-10-20 09:40:23
--@return 
--==============================--
function EquipTips:setBaseInfo()
    if self.data == nil or self.item_config == nil then return end
    local data = self.data

    self.equip_item:setBaseData(self.item_config.id)
    -- self.equip_item:setEquipJie(true)

    local name = self.item_config.name or ""
    local str = name
    local enchant = data.enchant or 0
    if enchant > 0 then 
        str = str .. "+" .. enchant
    end
    self.name:setString(str)

    local quality = 0
    if self.item_config.quality and self.item_config.quality >= 0 and self.item_config.quality <= 5 then
        quality = self.item_config.quality
    end
    --local background_res = PathTool.getResFrame("tips", "tips_"..quality)
    --if self.record_background_res == nil or self.record_background_res ~= background_res then
    --    self.record_background_res = background_res
    --    loadSpriteTexture(self.base_panel, background_res, LOADTEXT_TYPE_PLIST)
    --end
    local color = BackPackConst.getEquipTipsColor(quality)
    self.name:setTextColor(color) 
    
    if self.item_config.type_desc then
        self.equip_type:setString(TI18N("类型：").." "..self.item_config.type_desc)
    end

    if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        self.score_title:setVisible(true)
        self.power_label:setVisible(true)
        
        local sore = self:getHolyEquipScore() or 0
        local showPower = changeBtValueForPower(sore)
        self.power_label:setNum(showPower)
        --显示描述
        
        if self.chapter_label == nil then
            local config = Config.PartnerHolyEqmData.data_base_info(self.item_config.id)
            if config then
                self.chapter_label = createLabel(18, cc.c4b(0xd9,0x50,0x14,0xff), nil, 410, 66, config.unlock_desc, self.baseattr_panel, nil, cc.p(1,0.5))
            end
        end
        
        local id = math.floor(self.item_config.eqm_set/100)
        -- local config = Config.PartnerHolyEqmData.data_suit_res_prefix_fun(id)
        -- if config then
        --     local res = PathTool.getSuitRes(config.prefix)
        --     if self.record_suit_res == nil or self.record_suit_res ~= res then
        --         self.record_suit_res = res
        --         loadSpriteTexture(self.suit_icon, res, LOADTEXT_TYPE)
        --     end
        --     self.suit_name:setString(config.name)
        -- end
    else--if self.item_config.sub_type == BackPackConst.item_tab_type.EQUIPS then--普通装备 
        self.score_title:setVisible(true)
        self.power_label:setVisible(true)
        
        local score = data.score or 0
        if score <= 0 then 
            score = self:getBaseScore() or 0
        end
        local all_score = data.all_score or 0
        all_score = math.max(all_score,score)
        local showPower = changeBtValueForPower(all_score)
        self.power_label:setNum(showPower)
    end

    -- 描述
    self.desc_label:setString(self.item_config.desc)
    local label_siez = self.desc_label:getContentSize()
    local max_height = math.max(label_siez.height, self.scroll_size.height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
    self.desc_label:setPositionY(max_height-10)
end

--==============================--
--desc:设置基础属性
--time:2018-10-20 11:42:16
--@return 
--==============================--
function EquipTips:setBaseAttrInfo()
    if not self.item_config or not self.item_config.ext or not self.item_config.ext[1] then return end
    local base_attr = self.item_config.ext[1][2] or {}
    local index = 1 
    for i,v in ipairs(base_attr) do
        if index > 2 then return end        -- 超过2条属性不显示了,ui暂时不支持
        local attr_key = v[1]
        local attr_val = v[2]
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
            if not self.base_list[index] then 
                self.base_list[index] = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(4, 28), nil, nil, 380)
                self.baseattr_panel:addChild(self.base_list[index])
            end
            local label = self.base_list[index]
            local _x = 24 + (i-1) * 200
            label:setPositionX(_x)

            local icon = PathTool.getAttrIconByStr(attr_key)
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val*0.1).."%"
            else
                attr_val = changeBtValueForHeroAttr(attr_val, attr_key)
            end
            local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#137707> %s：</div><div fontcolor=#137707>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
            label:setString(attr_str)
            print("BaseAttrXXX"..index..":"..attr_str)
            index = index + 1
        end
    end
end

--图鉴的随机属性
function EquipTips:setLustrAtt()
    if self.item_config.eqm_jie then
        local const = Config.PartnerHolyEqmData.data_const
        if self.item_config.eqm_jie == 0 then
            local pos = {29,-9}
            for i=1,2 do
                local lustr_att = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(24,pos[i]),nil,nil,500)
                self.randomattr_panel:addChild(lustr_att)
                local str = ""
                if i == 1 then
                    str = const.text_show_1.desc
                else
                    str = const.text_show_2.desc
                end
                lustr_att:setString(str)
            end
            self.pre_btn:setVisible(false)
        elseif self.item_config.eqm_jie == 1 then
            local lustr_att = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(24,33),nil,nil,200)
            self.randomattr_panel:addChild(lustr_att)
            local attr_icon = PathTool.getAttrIconByStr("random")
            local msg = string.format(TI18N("<img src=%s visible=true scale=1 /> ？？？"),PathTool.getResFrame("common", attr_icon))
            lustr_att:setString(msg)

            local lustr_att2 = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(24,-9),nil,nil,500)
            self.randomattr_panel:addChild(lustr_att2)
            lustr_att2:setString(const.text_show_2.desc)
            self.pre_btn:setVisible(true)
        elseif self.item_config.eqm_jie == 2 then
            local pos = {29,-9}
            for i=1,2 do
                local lustr_att = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(24,pos[i]),nil,nil,200)
                self.randomattr_panel:addChild(lustr_att)
                local attr_icon = PathTool.getAttrIconByStr("random")
                local msg = string.format(TI18N("<img src=%s visible=true scale=1 /> ？？？"),PathTool.getResFrame("common", attr_icon))
                lustr_att:setString(msg)
            end
            self.pre_btn:setVisible(true)
        end
    end
end
--==============================--
--desc:设置随机属性
--@return 
--==============================--
function EquipTips:setRandomAttrInfo(lustr_status)
    if not self.data then return -1 end

    if lustr_status == true then
        self:setLustrAtt()        
    else
        local holy_eqm_attr = self.data.holy_eqm_attr or {}
        local dic_holy_eqm_attr = {}
        for i,v in ipairs(holy_eqm_attr) do
            dic_holy_eqm_attr[v.pos] = v
        end
        if next(dic_holy_eqm_attr) == nil then
            self.pre_btn:setVisible(false)
        else
            self.pre_btn:setVisible(true)
        end
        for i=1,2 do
            if self.random_item_list[i] == nil then
                self.random_item_list[i] = self:createattrItem(i, self.randomattr_panel)
            end

            if dic_holy_eqm_attr[i] then
                local attr_key = Config.AttrData.data_id_to_key[dic_holy_eqm_attr[i].attr_id]
                local attr_val = dic_holy_eqm_attr[i].attr_val or 0
                -- attr_val = attr_val/1000
                local attr_name = Config.AttrData.data_key_to_name[attr_key]
                local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                if is_per == true then
                    attr_val = (attr_val*0.1).."%"
                else
                    attr_val = changeBtValueForHeroAttr(attr_val, attr_key)
                end
                local icon = PathTool.getAttrIconByStr(attr_key)
                local attr_color = "c1b7ab"
                local val_color = "ffeedd"
                local ext_str = ""
                if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
                    --神装的颜色跟品质色走 val_color 后面处理
                    local attr_val11 = dic_holy_eqm_attr[i].attr_val or 0
                    val_color = model:getHolyEquipmentColorByItemIdAttrKey(self.item_config.id, attr_key, attr_val11, 1, 1)
                    local max_count = model:getHolyEquipmentMaxAttrByItemIdAttrKey(self.item_config.id, attr_key)
                    if attr_val11 >= max_count then
                        ext_str = "(max)"
                    end
                end
                local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#%s> %s：</div><div fontcolor=#%s>%s%s</div>", PathTool.getResFrame("common", icon), attr_color, attr_name, val_color, attr_val, ext_str)
                self.random_item_list[i].attr:setString(attr_str)
                -- local act_str = string_format("<div fontcolor=#%s>(%s%s)</div>", val_color,suit.count,TI18N("件激活"))
                -- self.random_item_list[i].act_info:setString(act_str)
            else
                local str
                if i == 1 then
                    str = Config.PartnerHolyEqmData.data_const.text_show_1.desc
                else
                    str = Config.PartnerHolyEqmData.data_const.text_show_2.desc
                end
                self.random_item_list[i].attr:setString(str)
            end
        end
    end

    return self.randomattr_panel_height + 40
end
--==============================--
--desc:装备套装属性 --by lwc
--time:2018-10-20 12:04:58
--@return 返回对比 csd中 suitattr_panel 额外的高度 如果 < 0 表示 没有套装信息(可能没有配置) 
--==============================--
function EquipTips:setSuitAttrInfo()
    if not self.suit_config then return -1 end
    if not self.item_config then return -1 end

    -- [4005] = {id=4005, name="冒险套装", add_attr1={{'atk',100}}, add_attr2={{'def',100}}, add_attr3={{'speed',10}}},
    --计算激活数量 (只有穿带才可能激活)
    local act_count, cur_suit_config  = self:getEquipActiveCount()

    --套装列表
    local suit_list = {}
    local max_config = self.suit_config[#self.suit_config]
    local max_count = max_config.num
    local name = nil
    
    for i,v in ipairs(self.suit_config) do
        if name == nil then
            name = v.name
        end

        if  (v.attr and next(v.attr) ~= nil) or (v.skill_id and next(v.skill_id) ~= nil) then
            local suit = {}
            suit.count = v.num
            if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
                local eqm_set = nil
                if cur_suit_config and cur_suit_config[i] then
                    suit.attr = cur_suit_config[i].skill_id[#cur_suit_config[i].skill_id]
                    eqm_set = cur_suit_config[i].id
                    if cur_suit_config[i].all_skill_desc then
                        suit.skill_desc = cur_suit_config[i].all_skill_desc[#v.all_skill_desc] --神装套装描述 
                    end
                else
                    suit.attr = v.skill_id[#v.skill_id]    
                    eqm_set = v.id
                    if v.all_skill_desc then
                        suit.skill_desc = v.all_skill_desc[#v.all_skill_desc] --神装套装描述 
                    end
                end
                local star = eqm_set%100
                suit.suit_name = string_format(TI18N("%s星套装"), star)

            elseif self.item_config.sub_type == BackPackConst.item_tab_type.EQUIPS then--普通装备 
                if cur_suit_config and cur_suit_config[v.num] then
                    for _,cur_suit in ipairs(cur_suit_config[v.num]) do
                        if cur_suit.num == v.num then
                            suit.attr = cur_suit.attr[#cur_suit.attr] 
                            suit.name =  cur_suit.abb_name
                            suit.is_suit =  true
                        end
                    end

                    if suit.attr == nil then
                        suit.attr = v.attr[#v.attr]
                        suit.name =  v.abb_name
                    end
                else
                    suit.attr = v.attr[#v.attr] 
                    suit.name =  v.abb_name               
                end
                -- suit.attr = v.attr[#v.attr]
            end
            
            table_insert(suit_list, suit)
        end
    end
    local count = #suit_list
    --神装名字特殊显示
    if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装 
        local eqm_key = math_floor(self.item_config.eqm_set/100)
        local res_config = Config.PartnerHolyEqmData.data_suit_res_prefix[eqm_key]
        name = res_config.name
        local tips = TI18N("高星神装能激活低星套装效果!")
        local str = string_format("%s(%s)", name, tips)
        self.suitattr_name:setString(str)
    else
        if count > 0 then
            --第一个名字不为空说明有套装激活
            if suit_list[1] and suit_list[1].is_suit then
                local tips = TI18N("套装效果(高星装备能激活低星装备套装效果)")
                self.suitattr_name:setString(tips)
                self.suitattr_name:setFontSize(20)
            else
                local str = string_format("%s (%s/%s)", name, act_count, max_count)
                self.suitattr_name:setString(str)
                -- local suit = suit_list[#suit_list]
                -- if suit and act_count >= suit.count then
                --     self.suitattr_name:setTextColor(cc.c4b(0x8b,0xff,0x8e,255))
                -- end
            end
        end
    end

    local show_skill_id = nil --是否有显示技能id
    for i,suit in ipairs(suit_list) do
        if self.suit_item_list[i] == nil then
            self.suit_item_list[i] = self:createattrItem(i, self.suitattr_panel, 26)
        end
        
        local type_str = type(suit.attr)
        local attr_color = "1db116"
        local val_color = "1db116"
        --是否激活
        if act_count >= suit.count then
            val_color = "0e7709"
            attr_color  = "0e7709"
        end 

        if type_str == "table" then
            --说明是属性
            local attr_key = suit.attr[1]
            local attr_val = suit.attr[2]
            local attr_name = Config.AttrData.data_key_to_name[attr_key]
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val*0.1).."%"
            end
            local icon = PathTool.getAttrIconByStr(attr_key)
            local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#%s> %s：</div><div fontcolor=#%s>%s</div>", PathTool.getResFrame("common", icon), attr_color, attr_name, val_color, attr_val)
            self.suit_item_list[i].attr:setString(attr_str)
        elseif type_str == "number" then
            local attr_name 
            if suit.skill_desc then
                attr_name = suit.skill_desc[2] or TI18N("描述信息无")
                if suit.skill_desc[1] and suit.skill_desc[1] == 2 then
                    show_skill_id = suit.attr
                end
            else
                attr_name = TI18N("描述信息无")
            end
            local icon = PathTool.getAttrIconByStr("skill")
            local attr_str = string_format("<img src='%s' scale=1 /><div fontcolor=#%s> %s</div>", PathTool.getResFrame("common", icon), attr_color, attr_name)
            self.suit_item_list[i].attr:setString(attr_str)    
        end
        if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装 
            local act_str = string_format("<div fontcolor=#%s>%s(%s)</div>", val_color, suit.suit_name, suit.count)
            self.suit_item_list[i].act_info:setString(act_str)
        else
            if suit.name then
                local act_str = string_format("<div fontcolor=#%s>(%s %s %s)</div>",val_color, suit.name, suit.count,TI18N("件激活"))
                self.suit_item_list[i].act_info:setString(act_str)
            else
                local act_str = string_format("<div fontcolor=#%s>(%s %s)</div>", val_color, suit.count, TI18N("件激活"))
                self.suit_item_list[i].act_info:setString(act_str)
            end
        end
    end

    return self.suitattr_panel_height + 40 *(count - 1), show_skill_id
end

--获取装备激活数量
function EquipTips:getEquipActiveCount()
    if not self.partner_id or self.partner_id == 0 then
        return 0
    end
    -- 套装数量
    local count = 0
    local equip_list = {}
    if self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        if self.partner.holy_eqm ~= nil then
            --说明是网络返回的
            for i,v in ipairs(self.partner.holy_eqm) do
                equip_list[v.type] = GoodsVo.New(v.base_id)
            end
        elseif self.partner.holy_eqm_list ~= nil then
            --说明是本地的 hero_vo
            for k,v in pairs(self.partner.holy_eqm_list) do
                equip_list[k] = v
            end
        end
        --组合神装的套装信息
        local suit_config = {} 
        local eqm_key = math_floor(self.item_config.eqm_set/100)
        local eqm_set_list = {}
        for k, goodvo in pairs(equip_list) do
            if goodvo.config then
                local eqm_key_1 = math_floor(goodvo.config.eqm_set/100)
                if eqm_key == eqm_key_1 then
                    table_insert(eqm_set_list, goodvo.config.eqm_set)
                    count = count + 1
                end
            end
        end
        table.sort( eqm_set_list, function(a,b) return a > b end)
        if count > 1 then
            local cur_eqm_set = nil
            local cur_config = nil
            for i,eqm_set in ipairs(eqm_set_list) do
                if cur_eqm_set == nil then
                    cur_eqm_set = eqm_set
                    cur_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
                    table_sort( cur_config, function(a, b) return a.num < b.num end)
                else
                    if cur_eqm_set ~= eqm_set then
                        cur_config = Config.PartnerHolyEqmData.data_suit_info[eqm_set]
                        table_sort( cur_config, function(a, b) return a.num < b.num end)    
                    end
                    for _,suit_info in ipairs(cur_config) do
                        if suit_info.num == i then
                            table_insert(suit_config, suit_info)
                            break
                        end
                    end
                end
            end
        end
        return count , suit_config

    elseif self.item_config.sub_type == BackPackConst.item_tab_type.EQUIPS then--普通装备 
        if self.partner.eqms ~= nil then
            --说明是网络返回的
            for i,v in ipairs(self.partner.eqms) do
                equip_list[v.type] = GoodsVo.New(v.base_id)
            end
        elseif self.partner.eqm_list ~= nil then
            --说明是本地的 hero_vo
            for k,v in pairs(self.partner.eqm_list) do
                equip_list[k] = v
            end
        end

        local suit_config = {}
        for k, goodvo in pairs(equip_list) do
            if goodvo.config then
                if goodvo.config.eqm_set > 0 then
                    count = count + 1
                    local set_config = Config.PartnerEqmData.data_eqm_suit[goodvo.config.eqm_set]
                    if set_config ~= nil then
                        table_insert(suit_config, set_config)
                    end
                end
                -- if self.item_config.eqm_set == goodvo.config.eqm_set then
                --     count = count + 1
                -- end
            end
        end
        table_sort( suit_config, function(a, b) 
                if a[1] and b[1] and a[1].id and b[1].id then
                    return a[1].id > b[1].id
                else
                    return false
                end
            end)
        return count, suit_config
    end
end

function EquipTips:createattrItem(index, parent, offset)
    if not parent then return end
    local object = {}
    object.node = ccui.Layout:create()
    object.node:setAnchorPoint(cc.p(0, 0.5))
    object.node:setContentSize(cc.size(360, 28))
    local code = cc.Application:getInstance():getCurrentLanguageCode()
    if code ~= "zh" and self.item_config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT and offset then
        object.node:setPosition(20, 26-offset-(index-1)*40)
    else
        object.node:setPosition(20, 26-(index-1)*40)
    end
    parent:addChild(object.node)
    object.attr = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(4, 14), nil, nil, 380)
    object.node:addChild(object.attr)
    object.act_info = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(1, 0.5), cc.p(460, 14), nil, nil, 380)
    object.node:addChild(object.act_info)
    return object
end

--==============================--
--desc:创建技能显示单例
--==============================--
function EquipTips:createSkillItem(parent)
    local item = {}
    local skill = SkillItem.new(true,true,true,0.8)
    parent:addChild(skill)
    skill:setPosition(70, 62)
    -- local name = createLabel(24,cc.c4b(0xfe,0xee,0xba,0xff),nil,140, 96,"",parent,1,cc.p(0,0))
    local desc = createRichLabel(18,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(138, 105),4,nil,260)
    -- local tips = createRichLabel(18,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,1),cc.p(25, 115),4,nil,260)
    -- tips:setString(TI18N("高级神装能兼容低级套装效果!"))
    parent:addChild(desc)
    -- parent:addChild(tips)
    item.skill = skill
    -- item.name = name
    item.desc = desc
    return item
end

--计算基础评分
function EquipTips:getBaseScore()
    if not self.item_config or not self.item_config.ext or not self.item_config.ext[1] then return 0 end
    local base_attr = self.item_config.ext[1][2] or {}
    local num = PartnerCalculate.calculatePower(base_attr)
    return num
end

--计算神装评分
function EquipTips:getHolyEquipScore()
    if not self.item_config or not self.item_config.ext or not self.item_config.ext[1] then return 0 end
    local num = 0
    local base_score = 0
    local holy_eqm_attr_sore = 0

    local base_config = Config.PartnerHolyEqmData.data_base_info(self.item_config.id)
    if base_config then
        num = base_config.score
    end

    if self.item_config and self.item_config.ext and self.item_config.ext[1] then
        local base_attr = self.item_config.ext[1][2] or {}
        base_score = HeroCalculate.holyEquipMentPower(base_attr)
    end

    if self.data and self.data.holy_eqm_attr then
        local holy_eqm_attr = {}
        local dic_holy_eqm_attr = {}
        for k,v in pairs(self.data.holy_eqm_attr) do
            dic_holy_eqm_attr[v.pos] = v
        end
        for i=1,2 do
            if dic_holy_eqm_attr[i] then
                local attr_key = Config.AttrData.data_id_to_key[dic_holy_eqm_attr[i].attr_id]
                table_insert(holy_eqm_attr,{attr_key,dic_holy_eqm_attr[i].attr_val})
            end
        end

        holy_eqm_attr_sore = HeroCalculate.holyEquipMentPower(holy_eqm_attr)
    end
       
    return num+ base_score+holy_eqm_attr_sore
end


function EquipTips:close_callback()
    if self.equip_item then 
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
    if self.power_label then 
        self.power_label:DeleteMe()
        self.power_label = nil
    end

    if self.item_update_event ~= nil then
        self.data:UnBind(self.item_update_event)
        self.item_update_event = nil
    end

    controller:openEquipTips(false)
end
