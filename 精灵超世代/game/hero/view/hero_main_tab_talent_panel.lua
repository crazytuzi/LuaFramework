-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竖版伙伴天赋
-- <br/> 2019年2月19日
-- --------------------------------------------------------------------
HeroMainTabTalentPanel = class("HeroMainTabTalentPanel", function()
    return ccui.Widget:create()
end)

local string_format = string.format
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

function HeroMainTabTalentPanel:ctor(parent)  
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroMainTabTalentPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)

    --技能列表
    self.skill_item_list = {}
end

function HeroMainTabTalentPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_main_tab_talent_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.tab_panel = self.root_wnd:getChildByName("tab_panel")

    self.skill_look_btn = self.tab_panel:getChildByName("skill_look_btn")
    self.skill_look_btn:getChildByName("label"):setString(TI18N("技能预览"))
    self.shop_btn = self.tab_panel:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("技能商店"))

    self.look_btn = self.tab_panel:getChildByName("look_btn")

    local dic_config = Config.PartnerSkillData.data_partner_skill_pos or {}
    local config_list = {}
    
    for k,v in pairs(dic_config) do
        table_insert(config_list, v)
    end
    table.sort( config_list, function(a, b) return a.pos < b.pos end)
    self.config_list = config_list

    for i=1,3 do
        local v = config_list[i]
        local skill_panel = self.tab_panel:getChildByName("skill_panel"..i)
        local item = {}
        item.skill_panel = skill_panel
        item.icon = skill_panel:getChildByName("icon")
        item.lock_icon = skill_panel:getChildByName("lock_icon")
        item.skill_name_bg = skill_panel:getChildByName("skill_name_bg")
        item.skill_level_bg = skill_panel:getChildByName("skill_level_bg")
        item.redPoint = skill_panel:getChildByName("redPoint")
        item.redPoint:setVisible(false)
        item.skill_name = skill_panel:getChildByName("skill_name")
        item.skill_level = skill_panel:getChildByName("skill_level")
        registerButtonEventListener(skill_panel, function() self:onSkillClickByIndex(i, v) end ,false, 1)
        self.skill_item_list[i] = item
    end

    if self.skill_item_list[3] then
        self.skill_item_list[3].effect_node = self.skill_item_list[3].skill_panel:getChildByName("effect_node")
        self.skill_item_list[3].effect_node_2 = self.skill_item_list[3].skill_panel:getChildByName("effect_node_2")
        local bg_box = self.skill_item_list[3].skill_panel:getChildByName("bg_box")
        local skill_bg = self.skill_item_list[3].skill_panel:getChildByName("skill_bg")
        local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_talent_bg_1", false)
        self.box_item_load = loadSpriteTextureFromCDN(bg_box, bg_res, ResourcesType.single, self.box_item_load)
        local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_talent_bg", false)
        self.skill_bg_item_load = nil--loadSpriteTextureFromCDN(skill_bg, bg_res, ResourcesType.single, self.skill_bg_item_load)
    end
    --目前写死第二个
    -- if self.skill_item_list[2] then
    --     self.skill_item_list[2].skill_level_bg:setVisible(false)
    --     self.skill_item_list[2].skill_level:setVisible(false)
    --     self.skill_item_list[2].skill_name:setString(TI18N("11星开放"))
    -- end

    self.bg = self.tab_panel:getChildByName("bg")
    self.bg:setPositionY(224)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_bag_talent_bg", false)
    self.item_load = loadSpriteTextureFromCDN(self.bg, bg_res, ResourcesType.single, self.item_load)
end

--事件
function HeroMainTabTalentPanel:registerEvents()
    --详情
    registerButtonEventListener(self.skill_look_btn, function() self:onClickLookBtn()  end ,true, 2, nil)
    registerButtonEventListener(self.shop_btn, function() self:onClickShopBtn()  end ,true, 2, nil)
    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.PartnerSkillData.data_partner_skill_const.skill_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
        local config = Config.PartnerData.data_partner_const.game_rule1
    end ,true, 1)

    --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
                if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                    for i,item in pairs(temp_add) do
                        if Config.ItemData.data_skill_item_list[item.base_id] then
                            delayRun(self, 1, function() 
                                self:checkSkillLevelUpRedpoint()
                            end)
                            break
                        end
                        if item.base_id == model.talent_skill_cost_id then
                            delayRun(self, 1, function() 
                                self:checkSkillLevelUpRedpoint()
                            end)
                            break
                        end
                    end
                end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
                if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                    for i,item in pairs(temp_del) do
                        if Config.ItemData.data_skill_item_list[item.base_id] then
                            delayRun(self, 1, function() 
                                self:checkSkillLevelUpRedpoint()
                            end)
                            break
                        end
                        if item.base_id == model.talent_skill_cost_id then
                            delayRun(self, 1, function() 
                                self:checkSkillLevelUpRedpoint()
                            end)
                            break
                        end
                    end
                end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            -- if self.show_model_type == HeroConst.BagTab.eBagHero then 
                if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                    for i,item in pairs(temp_list) do
                        if Config.ItemData.data_skill_item_list[item.base_id] then
                            delayRun(self, 1, function() 
                                self:checkSkillLevelUpRedpoint()
                            end)
                            break
                        end
                        if item.base_id == model.talent_skill_cost_id then
                            delayRun(self, 1, function() 
                                self:checkSkillLevelUpRedpoint()
                            end)
                            break
                        end
                    end
                end
            -- end
        end)
    end

    -- if role_vo ~= nil then
    --     if self.role_lev_event == nil then
    --         self.role_lev_event =  role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
    --             if not self.hero_vo then return end
    --             local status = HeroCalculate.getHeroShowLevelStatus(self.hero_vo) 
    --             if status == 1 then
    --                 if key == "coin" then
    --                     -- delayRun(self, 1, function() 
    --                     --     self:checkSkillLevelUpRedpoint()
    --                     -- end)
    --                 end
    --             end
    --         end)
    --     end
    -- end


        -- 获取到天赋信息
    if not self.hero_get_talent_event then
        self.hero_get_talent_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Get_Talent_Event, function(list)
            if not list then return end
            if not self.hero_vo then return end
            for i,v in ipairs(list) do
                if v.partner_id == self.hero_vo.partner_id then
                    self:updteData()
                end
            end
        end)
    end
    -- 穿戴天赋技能返回
    if not self.hero_learn_talent_event then
        self.hero_learn_talent_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Learn_Talent_Event, function(data)
            if not data then return end
            if not self.hero_vo then return end
            if data.partner_id == self.hero_vo.partner_id then
                self:initSkillItemList()
                delayRun(self, 1, function() 
                    self:checkSkillLevelUpRedpoint()
                end)
            end
        end)
    end
    -- 升级天赋技能返回
    if not self.hero_level_up_talent_event then
        self.hero_level_up_talent_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Level_Up_Talent_Event, function(data)
            if not data then return end
            if not self.hero_vo then return end
            if data.partner_id == self.hero_vo.partner_id then
                message(TI18N("技能升级成功"))
                self:initSkillItemList()
                delayRun(self, 1, function() 
                    self:checkSkillLevelUpRedpoint()
                end)
            end
        end)
    end
    -- 升级天赋技能返回
    if not self.hero_forget_talent_event then
        self.hero_forget_talent_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Forget_Talent_Event, function(data)
            if not data then return end
            if not self.hero_vo then return end
            if data.partner_id == self.hero_vo.partner_id then
                self:initSkillItemList()
            end
        end)
    end

end


function HeroMainTabTalentPanel:onClickLookBtn()
    if not self.hero_vo then return end
    HeroController:getInstance():openArtifactSkillWindow(true, 2)
end

--打开商店
function HeroMainTabTalentPanel:onClickShopBtn()
    MallController:getInstance():openMallPanel(true, MallConst.MallType.SkillShop)
end

--点击技能
--@ config Config.PartnerSkillData.data_partner_skill_pos
function HeroMainTabTalentPanel:onSkillClickByIndex(index, config)
    if not self.hero_vo then return end

    if self.hero_vo:isResonateHero() then
        message(TI18N("赋能宝可梦不可更换天赋"))
        return
    end
    if self.hero_vo:ishaveTalentData() then
        local is_open, lock_str = model:checkOpenTanlentByconfig(config, self.hero_vo)
        if not is_open then
            message(lock_str)
            return
        end
        if self.hero_vo.talent_skill_list[config.pos] then
            controller:openHeroTalentSkillLevelUpPanel(true, self.hero_vo, self.hero_vo.talent_skill_list[config.pos], config.pos)
        else
            controller:openHeroTalentSkillLearnPanel(true, self.hero_vo, config.pos)
        end
    end
end

--@hero_vo 宝可梦数据
--@show_model_type 显示模式 1:宝可梦模式  2:图鉴模式 定义参考 HeroConst.BagTab.eBagHero
function HeroMainTabTalentPanel:setData(hero_vo, show_model_type)
    if not hero_vo then return end
    self.hero_vo = hero_vo
    if hero_vo.is_open_talent then
        --移除6星开启天赋
        hero_vo.is_open_talent = nil
        --移除那边的
        hero_vo:Fire(HeroVo.UPDATE_Partner_ATTR,hero_vo)
        --更新一下主角按钮的红点
        HeroCalculate.checkHeroRedPointByRedPointType(HeroConst.RedPointType.eRPTalent)
    end
    if self.parent and self.parent.is_hide_talent_Item then
        if self.skill_item_list and self.skill_item_list[3] and self.skill_item_list[3].skill_panel then
            self.skill_item_list[3].skill_panel:setVisible(false)
        end
    end
    if self.hero_vo:ishaveTalentData() then
        self:updteData()
    end

end

function HeroMainTabTalentPanel:updteData(  )
    if self.hero_vo.star > model.hero_info_upgrade_star_param4 then
        --13星开启第三个技能槽的特殊显示
        for i,v in ipairs(self.skill_item_list) do
            if i == 3 then
                if self.parent and self.parent.is_hide_talent_Item then
                    v.skill_panel:setVisible(false)
                else
                    v.skill_panel:setVisible(true)
                end
            else
                v.skill_panel:setPositionY(284)
            end
        end
        --特殊的显示 例如icon 变小时
        --self.bg:setPositionY(242)
    else
         for i,v in ipairs(self.skill_item_list) do
            if i == 3 then
                v.skill_panel:setVisible(false)
            else
                v.skill_panel:setPositionY(236)
            end
        end
        --self.bg:setPositionY(224)
    end
    self:initSkillItemList()
    self:checkSkillLevelUpRedpoint()
    self:checkOpenTanlentEffect()
end

--检查打开天赋特效
function HeroMainTabTalentPanel:checkOpenTanlentEffect()
    if self.parent and self.parent.is_hide_talent_Item and self.parent.is_show_open_talent_effect then
        if self.skill_item_list and self.skill_item_list[3] and self.skill_item_list[3].skill_panel then
            self.skill_item_list[3].skill_panel:setVisible(false)
        end
        self.parent.is_hide_talent_Item = false
        self:showOnpenThirteenEffect(true)
    end
end


function HeroMainTabTalentPanel:initSkillItemList()
    if not self.hero_vo.talent_skill_list then return end
    for i,v in ipairs(self.config_list) do
        if self.skill_item_list[i] then
            if i == 3 and self.hero_vo.star <= model.hero_info_upgrade_star_param4 then
                --上面处理了这里就可以不用处理了
                break
            end
            if self.hero_vo.talent_skill_list[v.pos] then
                local config = Config.SkillData.data_get_skill(self.hero_vo.talent_skill_list[v.pos])
                if config then
                    self.skill_item_list[i].icon:setVisible(true)
                    self.skill_item_list[i].skill_level_bg:setVisible(true)
                    self.skill_item_list[i].skill_level:setVisible(true)
                    self.skill_item_list[i].skill_name_bg:setVisible(true)
                    self.skill_item_list[i].skill_name:setVisible(true)
                    self.skill_item_list[i].lock_icon:setVisible(false)
                    local level = config.level
                    if config.client_lev and config.client_lev>0 then
                        level = config.client_lev
                    end
                    self.skill_item_list[i].skill_level:setString(level)
                    self.skill_item_list[i].skill_name:setString(config.name)
                    if self.skill_item_list[i].record_icon == nil or self.skill_item_list[i].record_icon ~= config.icon then
                        self.skill_item_list[i].record_icon = config.icon 
                        local skill_icon = PathTool.getSkillRes(config.icon, false)
                        loadSpriteTexture(self.skill_item_list[i].icon, skill_icon, LOADTEXT_TYPE)
                    end
                    if i == 3 then
                        self:showThirteenEffect1(true)

                        local partner_awakening_skill_config = Config.PartnerSkillData.data_partner_awakening_skill
                        if partner_awakening_skill_config and partner_awakening_skill_config[config.bid] then
                            self:showThirteenEffect2(true)
                        else
                            self:showThirteenEffect2(false)
                        end
                        
                    end
                end
            else
                self.skill_item_list[i].icon:setVisible(false)
                self.skill_item_list[i].lock_icon:setVisible(true)
                self.skill_item_list[i].skill_level_bg:setVisible(false)
                self.skill_item_list[i].skill_level:setVisible(false)
                
                
                self.skill_item_list[i].redPoint:setVisible(false)
                local is_open, lock_str = model:checkOpenTanlentByconfig(v, self.hero_vo)

                local res
                if is_open then
                    res = PathTool.getResFrame("common","common_90026")
                    self.skill_item_list[i].skill_name_bg:setVisible(false)
                    self.skill_item_list[i].skill_name:setVisible(false)
                else
                    res = PathTool.getResFrame("common","common_90009")
                    self.skill_item_list[i].skill_name_bg:setVisible(true)
                    self.skill_item_list[i].skill_name:setVisible(true)
                    self.skill_item_list[i].skill_name:setString(lock_str)
                end
                loadSpriteTexture(self.skill_item_list[i].lock_icon, res, LOADTEXT_TYPE_PLIST)
                if i == 3 then
                    self:showThirteenEffect1(false)
                    self:showThirteenEffect2(false)
                end
            end
        end
    end
end

--检查升级的红点 
function HeroMainTabTalentPanel:checkSkillLevelUpRedpoint()
    if not self.hero_vo.talent_skill_list then return end
    for i,v in ipairs(self.config_list) do
        if self.hero_vo.talent_skill_list[v.pos] then
            local is_redpoint = HeroCalculate.checkSingleTalentSkillLevel(self.hero_vo.talent_skill_list[v.pos])
            self.skill_item_list[i].redPoint:setVisible(is_redpoint)
        else
            self.skill_item_list[i].redPoint:setVisible(false)
        end
    end
end

--显示打开13星的效果
function HeroMainTabTalentPanel:showOnpenThirteenEffect(status)
    if status then
        --卡牌扫光
        if self.open_thirteen_effect == nil then
            --全屏抖动
            controller:runShakeScreemAction()
            self.open_thirteen_effect = createEffectSpine("E27805", cc.p(self.size.width/2,self.size.height/2), cc.p(0.5, 0.5), false, PlayerAction.action, function()
                if not tolua.isnull(self) then
                    self.open_thirteen_effect:setVisible(false)
                    controller:openSkillUnlockWindow(true, 0, {show_type = 2})
                end
            end)
            self.tab_panel:addChild(self.open_thirteen_effect, 1)

            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    if not tolua.isnull(self) then
                        if self.skill_item_list and self.skill_item_list[3] and self.skill_item_list[3].skill_panel then
                            self.skill_item_list[3].skill_panel:setVisible(true)
                        end
                    end
                end
            end
            self.open_thirteen_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)

        end 
    else
        if self.open_thirteen_effect then 
            self.open_thirteen_effect:setVisible(false)
            self.open_thirteen_effect:removeFromParent()
            self.open_thirteen_effect = nil
        end

    end
end
--显示13星通用特效
function HeroMainTabTalentPanel:showThirteenEffect1(status)
    if status then
        --技能花纹if  
        if self.thirteen_effect == nil and self.skill_item_list and self.skill_item_list[3] and self.skill_item_list[3].effect_node then
            self.thirteen_effect = createEffectSpine("E27803", cc.p(0,0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.skill_item_list[3].effect_node:addChild(self.thirteen_effect, 1)
        end 
    else
        if self.thirteen_effect then 
            self.thirteen_effect:setVisible(false)
            self.thirteen_effect:removeFromParent()
            self.thirteen_effect = nil
        end

    end
end

--显示13星通用特效
function HeroMainTabTalentPanel:showThirteenEffect2(status)
    if status then
        --扫光
        if self.thirteen_effect2 == nil and self.skill_item_list and self.skill_item_list[3] and self.skill_item_list[3].effect_node_2 then
            self.thirteen_effect2 = createEffectSpine("E27804", cc.p(-9,16), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.skill_item_list[3].effect_node_2:addChild(self.thirteen_effect2, 1)
        end   
    else
        if self.thirteen_effect2 then 
            self.thirteen_effect2:setVisible(false)
            self.thirteen_effect2:removeFromParent()
            self.thirteen_effect2 = nil
        end
    end
end

function HeroMainTabTalentPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end
--移除
function HeroMainTabTalentPanel:DeleteMe()
    self:showOnpenThirteenEffect(false)
    self:showThirteenEffect1(false)
    self:showThirteenEffect2(false)

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
    if self.hero_get_talent_event then
        GlobalEvent:getInstance():UnBind(self.hero_get_talent_event)
        self.hero_get_talent_event = nil
    end
    if self.hero_learn_talent_event then
        GlobalEvent:getInstance():UnBind(self.hero_learn_talent_event)
        self.hero_learn_talent_event = nil
    end
    if self.hero_level_up_talent_event then
        GlobalEvent:getInstance():UnBind(self.hero_level_up_talent_event)
        self.hero_level_up_talent_event = nil
    end
    if self.hero_forget_talent_event then
        GlobalEvent:getInstance():UnBind(self.hero_forget_talent_event)
        self.hero_forget_talent_event = nil
    end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.box_item_load then
        self.box_item_load:DeleteMe()
    end
    self.box_item_load = nil
    if self.skill_bg_item_load then
        self.skill_bg_item_load:DeleteMe()
    end
    self.skill_bg_item_load = nil

    if role_vo then
        if self.role_lev_event then
            role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end
end
