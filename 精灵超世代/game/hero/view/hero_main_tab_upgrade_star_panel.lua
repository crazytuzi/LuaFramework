 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竖版伙伴升星信息面板
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroMainTabUpgradeStarPanel = class("HeroMainTabUpgradeStarPanel", function()
    return ccui.Widget:create()
end)

local color_data = {
    [1] = cc.c4b(0x64,0x32,0x23,0xff), --觉醒消耗进阶石
}

local string_format = string.format
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local role_vo = RoleController:getInstance():getRoleVo()

function HeroMainTabUpgradeStarPanel:ctor(parent)  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroMainTabUpgradeStarPanel:config()

    --材料列表
    self.hero_item_list = {}
    self.cost_item_list = {} -- 升星额外消耗的材料
end

function HeroMainTabUpgradeStarPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_main_tab_upgrade_star_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.tab_panel = self.root_wnd:getChildByName("tab_panel")

    --星星node
    self.left_star_node = self.tab_panel:getChildByName("left_star_node")
    self.right_star_node = self.tab_panel:getChildByName("right_star_node")

    self.star_arrow = self.tab_panel:getChildByName("star_arrow")
    self.common_9005 = self.tab_panel:getChildByName("common_9005")
    --技能item node
    self.left_skill_node = self.tab_panel:getChildByName("left_skill_item_node")
    self.right_skill_node = self.tab_panel:getChildByName("right_skill_item_node")

    --材料 node
    self.item_node = self.tab_panel:getChildByName("item_node")

    --箭头
    self.arrow_2019 = self.tab_panel:getChildByName("arrow_2019")

    self.attr_list = {}
    for i=1,3 do
        local param = self.tab_panel:getChildByName("param"..i)
        local attr = {}
        attr.param =  param
        attr.key = param:getChildByName("key")
        attr.left = param:getChildByName("left")
        attr.arrow_icon = param:getChildByName("arrow_icon")
        attr.right = param:getChildByName("right")
        self.attr_list[i] = attr
    end

    self.up_btn = self.tab_panel:getChildByName("up_btn")

    local size = self.up_btn:getContentSize()
    --self.up_btn_label = createRichLabel(26,1, cc.p(0.5,0.5),cc.p(size.width * 0.5 , size.height * 0.5))
    --self.up_btn:addChild(self.up_btn_label)
    self.up_btn_label = self.up_btn:getChildByName("up_btn_label")

    local x, y = self.up_btn:getPosition()
    self.fuse_btn_label = createRichLabel(18,cc.c3b(36, 144, 3), cc.p(0.5,0.5),cc.p(x, y + 60))
    self.fuse_btn_label:setString(string_format("<div href=xxx>%s</div>", TI18N("前往宝可梦神殿")))
    self.tab_panel:addChild(self.fuse_btn_label)

    self.fuse_btn_label:addTouchLinkListener(function(type, value, sender, pos)
        if self.hero_vo then
            HeroController:getInstance():openHeroResetWindow(true, HeroConst.SacrificeType.eHeroFuse, self.hero_vo)

        end
    end, { "click", "href" })

    self.label_tip = self.tab_panel:getChildByName("label_tip")
    self.label_tip:setString(TI18N("(100%返还材料宝可梦升级、进阶消耗的金币、经验和进阶石)"))
end

--事件
function HeroMainTabUpgradeStarPanel:registerEvents()
    registerButtonEventListener(self.up_btn, function() self:_sendUpgradeStar()  end ,true, 2)

    --宝可梦信息更新
    if self.hero_data_update_event == nil then
        self.hero_data_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Update, function(hero_vo)
            if not hero_vo or not self.hero_vo then return end
            if self.hero_vo.partner_id == hero_vo.partner_id then
                self.is_hero_data_update = true
                self:checkUpdateCurrentInfo()
            end
        end)
    end

    --删除宝可梦
    if self.hero_data_delete_event == nil then
        self.hero_data_delete_event = GlobalEvent:getInstance():Bind(HeroEvent.Del_Hero_Event, function()
            if not self.hero_vo then return end
            self.is_del_hero_event = true
            self:checkUpdateCurrentInfo()
        end)
    end

    --新增宝可梦
    if self.hero_data_add_event == nil then
        self.hero_data_add_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Add, function()
            if not self.hero_vo then return end
            self:checkUpdateCurrentInfo(true)
        end)
    end


    --添加宝可梦选择返回事件
    if self.upgrade_star_select_event == nil then
        self.upgrade_star_select_event = GlobalEvent:getInstance():Bind(HeroEvent.Upgrade_Star_Select_Event, function()
            self:updateHeroItemInfo()
        end)
    end

        --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if not self.hero_vo then return end
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                self:checkUpdateCurrentInfo(true)
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if not self.hero_vo then return end
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                self:checkUpdateCurrentInfo(true)
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if not self.hero_vo then return end
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                self:checkUpdateCurrentInfo(true)
            end
        end)
    end
end

function HeroMainTabUpgradeStarPanel:checkUpdateCurrentInfo(is_not_check)
    if (self.is_hero_data_update and self.is_del_hero_event) or is_not_check then
        self:updateInfo(self.hero_vo)
    end
end

--发升星协议
function HeroMainTabUpgradeStarPanel:_sendUpgradeStar()
    if self.is_max_star then
        -- message(TI18N("该宝可梦已满星"))
        return 
    end
    if self.hero_item_data_list and next(self.hero_item_data_list) ~= nil then
        local partner_id = self.hero_vo.partner_id
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
        model:setUpgradeStarUpdateRecord(false)
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
end

--更新选中宝可梦信息
function HeroMainTabUpgradeStarPanel:updateHeroItemInfo()
    if not self.hero_item_data_list then return end
    self.dic_other_selected = {}
    --过滤自己
    if self.hero_vo then
        self.dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
    end
    for i,v in ipairs(self.hero_item_data_list) do
        if v.is_select then
            v.is_select = false
            local count = 0
            for k,vo in pairs(v.dic_select_list) do
                count = count + 1
                self.dic_other_selected[k] = vo
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
            for k,vo in pairs(v.dic_select_list) do
                self.dic_other_selected[k] = vo
            end
        end
    end
    self:updateCentreHeroItemRedPoint()
end


function HeroMainTabUpgradeStarPanel:setData(hero_vo)
    if not hero_vo then return end
    self.hero_vo = hero_vo
    self:updateInfo(hero_vo)
end

function HeroMainTabUpgradeStarPanel:updateInfo(hero_vo)
    if not hero_vo then return end
    --星星 HeroModel:createStar(num, star_con, star_setting, star_width)
    local star = hero_vo.star or 1
    self.left_star_setting = model:createStar(star, self.left_star_node, self.left_star_setting)
    self.right_star_setting = model:createStar(star + 1, self.right_star_node, self.right_star_setting)

    local key = getNorKey(hero_vo.bid, star)
    local star_config = Config.PartnerData.data_partner_star(key)
    local next_key = getNorKey(hero_vo.bid, star + 1)
    local next_star_config = Config.PartnerData.data_partner_star(next_key)


    if next_star_config == nil then
        --说明满星了
        self.star_arrow:setVisible(false)
        self.right_star_node:setVisible(false)
        if self.left_skill_item then
            self.left_skill_item:setVisible(false)
        end
        if self.right_skill_item then
            self.right_skill_item:setVisible(false)
        end
        --满级技能
        local skill_id = self:getFirstSkillID(star_config, next_star_config)
        if skill_id then
            if self.max_skill_item == nil then    
                local size = self.arrow_2019:getContentSize()
                self.max_skill_item = self:createSkillItem(self.arrow_2019, cc.p(size.width * 0.5, size.height * 0.5), skill_id)
            end
            self.arrow_2019:setVisible(true)
            self.max_skill_item:setVisible(true)
            self.max_skill_item:setData({skill_id = skill_id})
        else
            self.arrow_2019:setVisible(false)
        end

        --隐藏材料显示
        self.item_node:setVisible(false)
    else
        --6星以上逻辑
        if star >= model.hero_info_upgrade_star_param and star < model.hero_info_upgrade_star_param3 then
            self.right_star_node:setVisible(true)
            self.star_arrow:setVisible(true)

            if self.max_skill_item then
                self.max_skill_item:setVisible(false)
            end
            --左右技能
            local skill_id1, skill_id2 = self:getFirstSkillID(star_config, next_star_config)
            if skill_id1 and skill_id2 then
                if self.left_skill_item == nil then
                    self.left_skill_item = self:createSkillItem(self.left_skill_node, cc.p(0,0))    
                end
                if self.right_skill_item == nil then
                    self.right_skill_item = self:createSkillItem(self.right_skill_node, cc.p(0,0)) 
                end
                self.left_skill_item:setVisible(true)
                self.left_skill_item:setData({skill_id = skill_id1})
                self.right_skill_item:setVisible(true)
                self.right_skill_item:setData({skill_id = skill_id2})
                self.arrow_2019:setVisible(true)
            else
                self.arrow_2019:setVisible(false)
                if self.left_skill_item then
                    self.left_skill_item:setVisible(false)
                end
                if self.right_skill_item then
                    self.right_skill_item:setVisible(false)
                end
            end
        else
            --4 5星的逻辑
            self.arrow_2019:setVisible(false)
            if self.left_skill_item then
                self.left_skill_item:setVisible(false)
            end
            if self.right_skill_item then
                self.right_skill_item:setVisible(false)
            end
        end


        --升星材料
        self.item_node:setVisible(true)
        self:updateItemDataByConfig(next_star_config)
    end

    --更新属性
    self:updateAttrUI(star_config, next_star_config)
    
    if hero_vo:isResonateHero() then
        self.up_btn:setVisible(false)
        --self.common_9005:setVisible(false)
        if self.consume_label then
            self.consume_label:setVisible(false)
        end
        self.fuse_btn_label:setVisible(false)
    else
        self.up_btn:setVisible(true)
            --按钮显示
        if next_star_config == nil then
            self.is_max_star = true
            self.up_btn_label:setString(TI18N("已满级"))
            --self.up_btn_label:setString(string.format(TI18N("<div outline=2,#294a15>%s</div>"),TI18N("已满级")))
        else
            self.is_max_star = false
            if star >= model.hero_info_upgrade_star_param then
                --6星以上逻辑
                if next(next_star_config.other_expend) ~= nil then
                    local need_num = 0
                    -- 取出所需进阶石的数量
                    for k,v in pairs(next_star_config.other_expend) do
                        if v[1] == model.upgrade_star_cost_id then
                            need_num = v[2]
                            break
                        end
                    end
                    if need_num > 0 then
                        local item_data = Config.ItemData.data_get_data(model.upgrade_star_cost_id)
                        local count = BackpackController:getInstance():getModel():getItemNumByBid(item_data.id)
                       
                        --local str = string.format(TI18N("<img src=%s scale=0.45 visible=true /><div outline=2,#294a15>%s%s</div>"),PathTool.getItemRes(item_data.icon), need_num,TI18N("升星"))
                        --self.up_btn_label:setString(str)
                        self.up_btn_label:setString(TI18N("升星"))
                        if not self.consume_label then
                            self.consume_label = createRichLabel(20,Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), nil,nil,nil,1000)
                            self.tab_panel:addChild(self.consume_label)
                        end
                        if self.consume_label then
                            self.consume_label:setVisible(true)
                            local x, y = self.up_btn:getPosition()
                            self.consume_label:setPosition(x, y + 60)
                            local str = string.format(TI18N("<img src=%s scale=0.25 visible=true /> %s/%s"),PathTool.getItemRes(item_data.icon),MoneyTool.GetMoneyString(count), need_num)
                            self.consume_label:setString(str)
                        end
                    else
                        --self.up_btn_label:setString(string.format(TI18N("<div outline=2,#294a15>%s</div>"),TI18N("升星")))
                        self.up_btn_label:setString(TI18N("升星"))
                    end
                else
                    --self.up_btn_label:setString(string.format(TI18N("<div outline=2,#294a15>%s</div>"),TI18N("升星")))
                    self.up_btn_label:setString(TI18N("升星"))
                end

                --self.common_9005:setVisible(true)
                self.fuse_btn_label:setVisible(false)
            else
                if self.consume_label then
                    self.consume_label:setVisible(false)
                end
                --self.common_9005:setVisible(false)
                -- 4 5星的逻辑
                --self.up_btn_label:setString(string.format(TI18N("<div outline=2,#294a15>%s</div>"),TI18N("升星")))
                self.up_btn_label:setString(TI18N("升星"))
                self.fuse_btn_label:setVisible(true)
            end

        end
        -- 
        --按钮的红点
        local is_redpoint = HeroCalculate.checkSingleHeroUpgradeStarRedPoint(hero_vo)
        addRedPointToNodeByStatus(self.up_btn, is_redpoint, 5, 5)
    end
    
end

--策划说默认拿第一个不同的..
--获取第一个不同的技能 返回左右两个 .满星返回一个
function HeroMainTabUpgradeStarPanel:getFirstSkillID(star_config, next_star_config)
    if next_star_config == nil then
        if star_config then
            for i,v in ipairs(star_config.skills) do
                if v[1] ~= 1 then
                    return v[2]
                end
            end
        end
        return nil
    end
    if star_config and next_star_config then
        local left_skill_id
        --[序号] = 技能id
        local dic_left_skill = {}
        for i,v in ipairs(star_config.skills) do
            dic_left_skill[v[1]] = v[2]
        end 
        for i,v in ipairs(next_star_config.skills) do
            if v[1] ~= 1 then
                if dic_left_skill[v[1]] and dic_left_skill[v[1]] ~= v[2] then
                    return dic_left_skill[v[1]] , v[2]
                end
            end
        end
    end
    return nil
end
--创建技能item
function HeroMainTabUpgradeStarPanel:createSkillItem(parent, position, skill_id)
    local skill_item = SkillItem.new(true, true, true, 0.8, true)
    skill_item:setPosition(position)
    -- skill_item:setData({skill_id = skill_id})
    parent:addChild(skill_item)
    return skill_item
end

--更新升星物品材料
function HeroMainTabUpgradeStarPanel:updateItemDataByConfig(star_config)
    if not star_config then return end
    self.hero_item_data_list = {}
    --红点条件list
    local conditions_list = {}
    --记录已选id [partner_id] = hero_vo
    self.dic_other_selected = {}
    --过滤自己
    if self.hero_vo then
        self.dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
    end
    -- local expend = star_config.expend1[1]
    -- if expend then --主卡
    --     --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
    --     self.hero_item_data_list[index] = self:getHeroData(expend[1], expend[2], expend[3]) 
    -- end

    --指定的 {10402,4,1} : 10402: 表示bid, 4: 表示星级 1:表示数量
    local index = 1
    for i,expend in ipairs(star_config.expend2) do
        self.hero_item_data_list[index] = self:getHeroData(expend[1], expend[2], expend[3])
        conditions_list[index] = {}
        conditions_list[index][expend[1]] = {}
        conditions_list[index][expend[1]][expend[2]] = expend[3]
        index = index + 1
    end
    --随机的 {1,4,2} : 1 表示阵营  4: 表示星级 2表示数量
    for i,expend in ipairs(star_config.expend3) do
        self.hero_item_data_list[index] = self:getHeroData(nil, expend[2], expend[3], expend[1])
        conditions_list[index] = {}
        conditions_list[index][expend[1]] = {}
        conditions_list[index][expend[1]][expend[2]] = expend[3]
        index = index + 1
    end

    for i,item in ipairs(self.hero_item_list) do
        item:setVisible(false)
    end

    for i,hero_vo in ipairs(self.hero_item_data_list) do
        if self.hero_item_list[i] == nil then
            self.hero_item_list[i] = HeroExhibitionItem.new(0.8, true)
            self.hero_item_list[i]:setPosition( (i-1) * (HeroExhibitionItem.Width * 0.8 + 10) , 0)
            self.hero_item_list[i]:addCallBack(function() self:_onClickItemData(i) end)
            self.item_node:addChild(self.hero_item_list[i])
        end
        self.hero_item_list[i]:setVisible(true)
        if hero_vo.bid == 0 then
            --随机卡的头像id
            local default_head_id = model:getRandomHeroHeadByQuality(hero_vo.star)
            self.hero_item_list[i]:setData(hero_vo)
            self.hero_item_list[i]:setDefaultHead(default_head_id)
            self.hero_item_list[i]:setHeroName(true, string_format(TI18N("%s星宝可梦"), hero_vo.star))
        else
            self.hero_item_list[i]:setData(hero_vo)
            self.hero_item_list[i]:setHeroName(true, hero_vo.name)
        end
        
        self.hero_item_list[i]:setHeadUnEnabled(true)
    end

    -- 额外材料
    for k,item in pairs(self.cost_item_list) do
        item:setVisible(false)
    end

    local start_index = #self.hero_item_data_list
    if star_config.other_expend then
        for i,v in ipairs(star_config.other_expend) do
            local bid = v[1]
            local need_num = v[2]
            if bid ~= model.upgrade_star_cost_id then
                local item = self.cost_item_list[i]
                if not item then
                    item = BackPackItem.new(false, true, false, 0.8)
                    self.item_node:addChild(item)
                    self.cost_item_list[i] = item
                end
                item:setPosition( (start_index+i-1) * (BackPackItem.Width * 0.8 + 10) , 0)
                local have_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(bid)
                item:setBaseData(bid)
                item:setNeedNum(need_num, have_num, 1, true, 2)
                if need_num > have_num then
                    item:setDefaultTip(true, true)
                else
                    item:setDefaultTip()
                end
                item:setVisible(true)
            end
        end
    end

    self:initHeroListByMatchInfo(conditions_list)
    self:updateCentreHeroItemRedPoint()
end


--初始化宝可梦列表匹配信息
function HeroMainTabUpgradeStarPanel:initHeroListByMatchInfo(conditions_list)
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
                if conditions[hero.bid] and conditions[hero.bid][hero.star] then   -- 指定卡要剔除自己
                    if self.hero_vo and self.hero_vo.partner_id ~= hero.partner_id then
                        table_insert(self.conditions_hero_list[i], hero)
                    end
                end
            end
        end
    end
    
    --新加需求.自动填满指定定的位置的宝可梦
    -- if self.hero_vo and self.hero_vo.red_point[HeroConst.RedPointType.eRPStar] then
        self.dic_other_selected = {}
        if self.hero_vo then
            self.dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
        end
        for i,v in ipairs(self.hero_item_data_list) do
            --策划要求指定才需要填充 
            if v.bid ~= 0 then
                if self.conditions_hero_list[i] and #self.conditions_hero_list[i] > 0 then
                    local sort_func = SortTools.tableCommonSorter({{"lev", false}, {"id", true}}) 
                    table_sort(self.conditions_hero_list[i], sort_func)
                    local count = 0
                    for _,hero_vo in ipairs(self.conditions_hero_list[i]) do
                        if self.dic_other_selected[hero_vo.id] == nil and not hero_vo:checkHeroLockTips(true, nil, true) then
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


    local list = BackpackController:getInstance():getModel():getHeroHunList()
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
function HeroMainTabUpgradeStarPanel:updateCentreHeroItemRedPoint()
    if not self.conditions_hero_list then return end
    if not self.dic_other_selected then return end
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
                    if hero_vo.dic_select_list[each_hero.id] or self.dic_other_selected[each_hero.id] == nil then 
                        num = num -1
                        if num == 0 then
                            break
                        end
                    end
                end
                --说明数量够 显示红点
                local status = (num <= 0) 
                item:showRedPoint(status, 8, 8)

            else
                item:showRedPoint(false)
            end
        end
    end
end

--点击材料数据
function HeroMainTabUpgradeStarPanel:_onClickItemData(index)
    if not self.hero_item_data_list[index] then return end
    if not self.hero_vo then return end
    --标志点击了那个
    self.hero_item_data_list[index].is_select = true
    --被其他人选择的列表 [id] = hero_vo 模式
    local dic_other_selected = {}
    --把自己也过滤
    dic_other_selected[self.hero_vo.partner_id] = self.hero_vo
    for i,item in ipairs(self.hero_item_data_list) do
        if i ~= index then
            for k,v in pairs(item.dic_select_list) do
                dic_other_selected[k] = v
            end
        end
    end

    local setting = {}
    if self.hero_item_data_list[index].bid == 0 and self.hero_item_data_list[index].star == 5 then
        -- 表示随机卡
        setting.self_mark_bid = self.hero_vo.bid
    end

    controller:openHeroUpgradeStarSelectPanel(true, self.hero_item_data_list[index], dic_other_selected, HeroConst.SelectHeroType.eUpgradeStar, setting)
end

--更新属性ui
function HeroMainTabUpgradeStarPanel:updateAttrUI(star_config, next_star_config)
    if next_star_config == nil then
        for i,attr in ipairs(self.attr_list) do
            attr.param:setVisible(false)
        end
    else
        --根据csd那边算出来的
        local y = 290
        local h = 96
        local star = self.hero_vo.star or 0
        local show_count = #next_star_config.attr_show
        if show_count <= 0 then 
            --条件不满足
            for i,attr in ipairs(self.attr_list) do
                attr.param:setVisible(false)
            end 
            return 
        elseif show_count > 3 then --容错的
            show_count = 3
        end
        local param_height = h/show_count
        for i,attr in ipairs(self.attr_list) do
            local data_list =  next_star_config.attr_show[i]
            if data_list then
                local p_y = y - ((i-1) * param_height + param_height * 0.5)
                if star >= model.hero_info_upgrade_star_param and star < model.hero_info_upgrade_star_param2 then
                    --6星以上逻辑  485 -->根据csd那边算出来的
                    attr.param:setPosition(485, p_y)    
                else
                    -- 4 5, 11星的逻辑  12星的逻辑
                    attr.param:setPosition(self.size.width * 0.5, p_y)    
                end
                attr.param:setVisible(true)
                if data_list[2] == nil then
                    attr.arrow_icon:setVisible(false)
                    attr.left:setVisible(false)
                    attr.right:setVisible(false)
                else
                    attr.arrow_icon:setVisible(true)
                    attr.left:setVisible(true)
                    attr.right:setVisible(true)
                    attr.left:setString(data_list[2])
                    attr.right:setString(data_list[3])
                end
                attr.key:setString(data_list[1])
                
            else
                attr.param:setVisible(false)
            end
        end
    end
end

--@ bid 宝可梦bid 特殊判断 如果 == nil 说明是随机卡
--@ star 星级
--@ count 数量
--@ camp_type 阵营  如果是随机卡.此一定需要有值
function HeroMainTabUpgradeStarPanel:getHeroData(bid, star, count, camp_type)
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
            data.name = base_config.name
        else
            return nil
        end
    end
    --当前选中的宝可梦列表 [id] == hero_vo 模式
    data.dic_select_list = {}
    return data
end

function HeroMainTabUpgradeStarPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function HeroMainTabUpgradeStarPanel:DeleteMe()
    if self.left_skill_item then
        self.left_skill_item:DeleteMe()
        self.left_skill_item = nil
    end
    if self.right_skill_item then
        self.right_skill_item:DeleteMe()
        self.right_skill_item = nil
    end
    if self.max_skill_item then
        self.max_skill_item:DeleteMe()
        self.max_skill_item = nil
    end
    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
             v:DeleteMe()
        end
        self.hero_item_list = nil
    end
    if self.cost_item_list then
        for i,v in ipairs(self.cost_item_list) do
            v:DeleteMe()
        end
        self.cost_item_list = nil
    end

    if self.upgrade_star_select_event then
        GlobalEvent:getInstance():UnBind(self.upgrade_star_select_event)
        self.upgrade_star_select_event = nil
    end

    if self.hero_data_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_data_update_event)
        self.hero_data_update_event = nil
    end

    if self.hero_data_delete_event then
        GlobalEvent:getInstance():UnBind(self.hero_data_delete_event)
        self.hero_data_delete_event = nil
    end
    if self.hero_data_add_event then
        GlobalEvent:getInstance():UnBind(self.hero_data_add_event)
        self.hero_data_add_event = nil
    end

    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end
end
