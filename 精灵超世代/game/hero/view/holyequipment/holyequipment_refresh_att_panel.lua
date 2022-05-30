-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--       神装洗练界面
-- <br/>2019年4月10日
-- --------------------------------------------------------------------
HolyequipmentRefreshAttPanel = HolyequipmentRefreshAttPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert

function HolyequipmentRefreshAttPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "hero/holyequipment_refresh_att_panel"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("artifact", "artifact"), type = ResourcesType.plist},
    }


    self.is_can_save =false
    self.need_list = {}
    self.base_list_left = {}
    self.base_list_right = {}
    self.skill_list_left = {}
    self.skill_list_right = {}
end

function HolyequipmentRefreshAttPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1) 

    main_container:getChildByName("win_title"):setString(TI18N("神装洗练"))

    local container = main_container:getChildByName("container")
    self.container = container
    local cost_title = container:getChildByName("cost_title")
    cost_title:setString(TI18N("消耗"))
    local base_title_1 = container:getChildByName("base_title_1")
    base_title_1:setString(TI18N("基础属性"))
    local up_title = container:getChildByName("up_title")
    up_title:setString(TI18N("随机属性[洗练前]"))
    local down_title = container:getChildByName("down_title")
    down_title:setString(TI18N("随机属性[洗练后]"))

    --item名字
    self.name_txt = container:getChildByName("name_txt")    --洗练后评分
    self.score_lab = container:getChildByName("score_lab")
    self.score_lab:setString("")
    self.checkbox_list = {}
    self.is_checkbox_select = {}
    self.checkbox_list[1] = self.container:getChildByName("checkbox1")
    self.checkbox_list[2] = self.container:getChildByName("checkbox2")
    self.checkbox_list[1]:setSelected(false)
    self.checkbox_list[2]:setSelected(false)
    self.checkbox_list[1]:getChildByName("name"):setString(TI18N("锁定属性"))
    self.checkbox_list[2]:getChildByName("name"):setString(TI18N("锁定属性"))

    -- self.left_bg = container:getChildByName("Image_7")
    -- self.right_bg = container:getChildByName("Image_9")
    --消耗
    local cost_icon_1 = container:getChildByName("cost_icon_1")
    cost_icon_1:setScale(0.8)
    local cost_icon_2 = container:getChildByName("cost_icon_2")
    cost_icon_2:setScale(0.8)
    self.cost_icon = {cost_icon_1, cost_icon_2}
    local cost_txt_1 = container:getChildByName("cost_txt_1")
    local cost_txt_2 = container:getChildByName("cost_txt_2")
    cost_txt_1:setString("")
    cost_txt_2:setString("")
    self.cost_txt = {cost_txt_1, cost_txt_2}

    self.explain_btn = main_container:getChildByName("explain_btn")
    self.close_btn = main_container:getChildByName("close_btn")
    self.save_btn = main_container:getChildByName("save_btn")
    self.save_btn:getChildByName("label"):setString(TI18N("保存"))
    self.reset_btn = main_container:getChildByName("reset_btn")
    self.reset_btn:getChildByName("label"):setString(TI18N("洗练"))
    self.cancel_btn = main_container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("洗练"))

    --道具
    self.pos_item = container:getChildByName("pos_item")
    self.item_node = BackPackItem.new(false, false, false)
    self.item_node:setPositionY(15)
    self.pos_item:addChild(self.item_node)

    self.tips_label = container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("(已洗练至最大的属性不会下降,但在不锁定下会改变类型)"))

    self.checkbox_tips = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(1, 0.5), cc.p(638, 551), nil, nil, 380)
    container:addChild(self.checkbox_tips)
    --基础属性值
    self.base_att_label = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(300, 625), nil, nil, 380)
    container:addChild(self.base_att_label)
    --洗练前属性
    self.random_att_up_list = {}
    for i=1,2 do
        local x = 44
        local y = 500 - (i - 1) * 48
        self.random_att_up_list[i] = self:createAttInfo(x, y, container)
    end
    
    -- 洗练后属性
    self.random_att_down_list = {}
    for i=1,2 do
        local x = 44
        local y = 300 - (i - 1) * 48
        self.random_att_down_list[i] = self:createAttInfo(x, y, container)
    end

    self.reset_count_tips = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(20, 25), nil, nil, 630)
    self.main_container:addChild(self.reset_count_tips)
end

--创建属性信息
function HolyequipmentRefreshAttPanel:createAttInfo(x, y, container)
    local item_info =  {}
    item_info.att_label = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(x, y), nil, nil, 720)
    item_info.value_lable = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(x + 300, y), nil, nil, 380)
    container:addChild(item_info.att_label)
    container:addChild(item_info.value_lable)
    -- item_info.value_lable:setString("(max)")

    local res = PathTool.getResFrame("common","common_90005")
    local res1 = PathTool.getResFrame("common","common_90006")
    local size = cc.size(160, 18)
    local bg,comp_bar = createLoadingBar(res, res1, size, container, cc.p(0.5,0.5), x + 310, y, true, true)
    item_info.comp_bar = comp_bar
    item_info.comp_bar_bg = bg

    local text_color = cc.c3b(255,255,255)
    local line_color = cc.c3b(0,0,0)
    item_info.comp_bar_label = createLabel(18, text_color, line_color, size.width/2, size.height/2, "", comp_bar, 2, cc.p(0.5, 0.5))
    item_info.comp_bar_label:setString("100%")
    item_info.comp_bar_bg:setVisible(false)
    return item_info
end

function HolyequipmentRefreshAttPanel:register_event(  )
    registerButtonEventListener(self.background, function () self:onClickCloseBtn() end, false, 2)
    registerButtonEventListener(self.close_btn, function () self:onClickCloseBtn() end, true, 2)
    -- 洗练
    registerButtonEventListener(self.reset_btn, function () self:onClickResetBtn() end, true, 1)
    registerButtonEventListener(self.cancel_btn, function () self:onClickResetBtn() end, true, 1)
    -- 保存
    registerButtonEventListener(self.save_btn, function () self:onClickSaveBtn() end, true, 1)

    for i,box in ipairs(self.checkbox_list) do
        box:addEventListener(function ( sender,event_type )
            playButtonSound2()
            self:onCheckboxSelect(i)
        end)
    end

    registerButtonEventListener(self.explain_btn, function ( param, sender )
        local config = Config.PartnerHolyEqmData.data_const.game_rule_2
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end)

    --神装信息更新
    self:addGlobalEvent(HeroEvent.Holy_Equipment_Update_Event, function (hero_vo)
        if not hero_vo then return end
        if not self.data or not self.item_config then return end
        if hero_vo.partner_id and hero_vo.partner_id == self.partner_id then
            self:initData()
        end
    end)

    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        if self.partner_id then
            for i,v in ipairs(list) do
                if self.partner_id == v.partner_id then
                    self:onClickCloseBtn()
                end
            end
        end
    end)
end

function HolyequipmentRefreshAttPanel:addDataBindEvent()
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

function HolyequipmentRefreshAttPanel:onClickCloseBtn()
    controller:openHolyequipmentRefreshAttPanel(false)
end

--洗练
function HolyequipmentRefreshAttPanel:onClickResetBtn()
    if not self.data or not self.item_config then return end
    if not self.is_checkbox_select then return end

    local pos_list = {}
    for i,v in pairs(self.is_checkbox_select) do
        if v == true then
            table_insert(pos_list, {pos = i})
        end
    end
    controller:sender11094(self.partner_id, self.data.id, pos_list)
end

--保存洗练
function HolyequipmentRefreshAttPanel:onClickSaveBtn()
    if not self.data or not self.item_config then return end
    controller:sender11090(self.partner_id, self.data.id, 1)
end

function HolyequipmentRefreshAttPanel:onCheckboxSelect(i)
    if not self.checkbox_list[i] then return end
    if not self.checkbox_tips then return end
    self.is_checkbox_select[i] = self.checkbox_list[i]:isSelected()

    local cost_count = 0
    for k,is_select in pairs(self.is_checkbox_select) do
        if is_select then
            cost_count = cost_count + 1
        end
    end
    if cost_count > 0 then
        local cost_value = nil
        local config = Config.PartnerHolyEqmData.data_const.lock_pay_diamon
        if config then
            for i,v in ipairs(config.val) do
                if cost_count == v[1] then
                    cost_value = v[2]
                    break
                end
            end
            if cost_value == nil and next(config.val) ~= nil then
                cost_value = config.val[#config.val][2]
            end
        end
        if cost_value ~= nil then
            local tips_str = TI18N("锁定共花费")
            local res = PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold)
            local str = string_format("%s <img src='%s' scale=0.25 />: %s", tips_str, res, cost_value)
            self.checkbox_tips:setString(str)
        else
            self.checkbox_tips:setString("")    
        end
    else
        self.checkbox_tips:setString("")
    end
end

--@ data 结构: goodsvo  
function HolyequipmentRefreshAttPanel:openRootWnd( data, partner_id )
    if not data then return end
    self.data = data
    self.item_config = self.data.config
    if self.item_config == nil then return end

    self.partner_id = partner_id or 0
    self:initData()
    self:addDataBindEvent()
end

function HolyequipmentRefreshAttPanel:initData()
    if not self.data or not self.item_config then return end

    self.item_node:setData(self.data)
    self.name_txt:setString(self.item_config.name)

    self.is_can_save = false
    local dic_holy_eqm_attr = {}
    for i,v in ipairs(self.data.holy_eqm_attr) do
        dic_holy_eqm_attr[v.pos] = v
        --后端协议  如果 101 表示 1 位置上面有洗练属性没有保存
        if v.pos >= 100 then
            self.is_can_save = true
        end
    end

    self:setBaseAttrInfo()
    self:setRandomAttrInfo(dic_holy_eqm_attr)
    self:updateBtnShow()
    self:updateCostInfo()

    --洗练属性
    local count = 0
    for k,v in pairs(self.data.extra) do
        if v.extra_k == 10 then
            count = v.extra_v
        end
    end

    self.reset_count_tips:setString(string_format(TI18N("该装备已洗练%s次"), count))
end

--获取属性对应信息 
--return 属性icon路径, 属性名字, 属性值
function HolyequipmentRefreshAttPanel:getAttrInfo(attr_id, attr_val)
    if not attr_id or not attr_val then return end
    local attr_key = Config.AttrData.data_id_to_key[attr_id]
    local attr_name = Config.AttrData.data_key_to_name[attr_key]
    if attr_name then
        local icon = PathTool.getAttrIconByStr(attr_key)
        local is_per = PartnerCalculate.isShowPerByStr(attr_key)
        if is_per == true then
            attr_val = (attr_val/10).."%"
        end
        local res = PathTool.getResFrame("common", icon)
        
        return res, attr_name, attr_val
    end
end

-- 基础属性
function HolyequipmentRefreshAttPanel:setBaseAttrInfo(  )
    if not self.data or not self.data.main_attr then return end
    local main_attr = self.data.main_attr[1] or {}
    local res, attr_name, attr_val = self:getAttrInfo(main_attr.attr_id, main_attr.attr_val)
    if res then
        local tips = TI18N("不变")
        local attr_str = string_format("<img src='%s' scale=1 /> %s：%s (%s)", res, attr_name, attr_val, tips)
        self.base_att_label:setString(attr_str)
    end
end

--计算神装评分
function HolyequipmentRefreshAttPanel:getHolyEquipScore()
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

function HolyequipmentRefreshAttPanel:setRandomAttrInfo(dic_holy_eqm_attr)
    local old_holy_eqm_attr = {}--旧的随机属性
    local new_holy_eqm_attr = {}--新的随机属性
    -- body
    for i=1,2 do
        --上方属性
        local random_eqm_attr = dic_holy_eqm_attr[i] or {}
        local res, attr_name, attr_val = self:getAttrInfo(random_eqm_attr.attr_id, random_eqm_attr.attr_val)
        if res then
            local attr_str = string_format("<img src='%s' scale=1 /> %s：", res, attr_name)
            self.random_att_up_list[i].att_label:setString(attr_str)

            
            local attr_key = Config.AttrData.data_id_to_key[random_eqm_attr.attr_id]
            local quality = model:getHolyEquipmentQualityByItemIdAttrKey(self.item_config.id, attr_key, random_eqm_attr.attr_val)
            local res = PathTool.getBarQualityBg(quality)

            table_insert(old_holy_eqm_attr,{attr_key,random_eqm_attr.attr_val})

            if self.random_att_up_list[i].record_res == nil or self.random_att_up_list[i].record_res ~= res then
                self.random_att_up_list[i].record_res = res
                self.random_att_up_list[i].comp_bar:loadTexture(res,LOADTEXT_TYPE_PLIST)
            end

            local max_count = model:getHolyEquipmentMaxAttrByItemIdAttrKey(self.item_config.id, attr_key)
            local per = random_eqm_attr.attr_val * 100/max_count

            if random_eqm_attr.attr_val >= max_count then
                local color = BackPackConst.getWhiteQualityColorStr(quality)
                local attr_value = string_format("<div fontcolor=%s>(max)</div>", color)
                self.random_att_up_list[i].value_lable:setString(attr_value)
            else
                self.random_att_up_list[i].value_lable:setString("")
            end

            
            self.random_att_up_list[i].comp_bar_bg:setVisible(true)
            self.random_att_up_list[i].comp_bar:setPercent(per)
            self.random_att_up_list[i].comp_bar_label:setString(attr_val)
        else
            self.random_att_up_list[i].comp_bar_bg:setVisible(false)
            self.random_att_up_list[i].att_label:setString("    ----                              --                                           ---- ")
        end

        -- 下方属性
        if random_eqm_attr ~= nil and next(random_eqm_attr) ~= nil then
            if self.is_can_save then  --表示有未保存的
                local random_down_eqm_attr = dic_holy_eqm_attr[i + 100] or {}
                local res, attr_name, attr_val = self:getAttrInfo(random_down_eqm_attr.attr_id, random_down_eqm_attr.attr_val)
                if res then
                    local attr_str = string_format("<img src='%s' scale=1 /> %s：", res, attr_name)
                    self.random_att_down_list[i].att_label:setString(attr_str)

                    local attr_key = Config.AttrData.data_id_to_key[random_down_eqm_attr.attr_id]
                    local quality = model:getHolyEquipmentQualityByItemIdAttrKey(self.item_config.id, attr_key, random_down_eqm_attr.attr_val)
                    local res = PathTool.getBarQualityBg(quality)
                    if self.random_att_down_list[i].record_res == nil or self.random_att_down_list[i].record_res ~= res then
                        self.random_att_down_list[i].record_res = res
                        self.random_att_down_list[i].comp_bar:loadTexture(res,LOADTEXT_TYPE_PLIST)
                    end

                    table_insert(new_holy_eqm_attr,{attr_key,random_down_eqm_attr.attr_val})

                    local max_count = model:getHolyEquipmentMaxAttrByItemIdAttrKey(self.item_config.id, attr_key)
                    local per = random_down_eqm_attr.attr_val * 100/max_count

                    if random_down_eqm_attr.attr_val >= max_count then
                        local color = BackPackConst.getWhiteQualityColorStr(quality)
                        local attr_value = string_format("<div fontcolor=%s>(max)</div>", color)
                        self.random_att_down_list[i].value_lable:setString(attr_value)
                    else
                        self.random_att_down_list[i].value_lable:setString("")
                    end

                    self.random_att_down_list[i].comp_bar_bg:setVisible(true)
                    self.random_att_down_list[i].comp_bar:setPercent(per)
                    self.random_att_down_list[i].comp_bar_label:setString(attr_val)
                end
            else
                local res = PathTool.getAttrIconByStr("random")
                local attr_name = TI18N("随机属性")
                local attr_str = string_format("<img src='%s' scale=1 /> %s：", res, attr_name)
                self.random_att_down_list[i].att_label:setString(attr_str)
                self.random_att_down_list[i].value_lable:setString("? ? ?")
                self.random_att_down_list[i].comp_bar_bg:setVisible(false)
            end
        else
            self.random_att_down_list[i].comp_bar_bg:setVisible(false)
            self.checkbox_list[i]:setVisible(false)
            self.random_att_down_list[i].att_label:setString("    ----                              --")
        end
    end

    if new_holy_eqm_attr and #new_holy_eqm_attr>0 then
        local old_score = HeroCalculate.holyEquipMentPower(old_holy_eqm_attr) or 0
        local new_score = HeroCalculate.holyEquipMentPower(new_holy_eqm_attr) or 0
        local num = 0
        local base_score = 0

        local base_config = Config.PartnerHolyEqmData.data_base_info(self.item_config.id)
        if base_config then
            num = base_config.score
        end
    
        if self.item_config and self.item_config.ext and self.item_config.ext[1] then 
            local base_attr = self.item_config.ext[1][2] or {}
            base_score = HeroCalculate.holyEquipMentPower(base_attr)
        end

        local sum_score = new_score+num+base_score
        local add_score = sum_score-(old_score+num+base_score)
        if add_score > 0 then
            add_score = "+"..add_score
        else
            add_score = ""..add_score
        end
        self.score_lab:setString(string_format(TI18N("评分：%d(%s)"),sum_score,add_score))
    else
        self.score_lab:setString(TI18N("评分：? ? ?"))
    end
end


function HolyequipmentRefreshAttPanel:updateBtnShow(  )
    self.reset_btn:setVisible(not self.is_can_save)
    self.save_btn:setVisible(self.is_can_save)
    self.cancel_btn:setVisible(self.is_can_save)
end

function HolyequipmentRefreshAttPanel:updateCostInfo(  )
    if not self.data or not self.item_config then return end
    local config = Config.PartnerHolyEqmData.data_base_info(self.item_config.id)
    if config and config.reset_price and next(config.reset_price) ~= nil then
        for i=1,2 do
            local cost_data = config.reset_price[i]
            local cost_icon = self.cost_icon[i]
            local cost_txt = self.cost_txt[i]
            if cost_data then
                local bid = cost_data[1]
                local num = cost_data[2]
                local item_config = Config.ItemData.data_get_data(bid)
                if item_config then
                    cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                    cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                    if have_num >= num then
                        cost_txt:setTextColor(cc.c3b(255, 255, 255))
                    else
                        cost_txt:setTextColor(cc.c3b(253, 71, 71))
                    end
                end
            else
                cost_txt:setString("")
            end
        end
    end
end

function HolyequipmentRefreshAttPanel:close_callback(  )
    if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end

    if self.item_update_event ~= nil then
        self.data:UnBind(self.item_update_event)
        self.item_update_event = nil
    end

    controller:openHolyequipmentRefreshAttPanel(false)
end
