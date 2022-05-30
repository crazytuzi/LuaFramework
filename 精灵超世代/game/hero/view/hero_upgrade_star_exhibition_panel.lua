-- --------------------------------------------------------------------
-- 突破升星成功
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      进阶成功
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
HeroUpgradeStarExhibitionPanel = HeroUpgradeStarExhibitionPanel or BaseClass(BaseView)

local table_insert = table.insert
local string_format = string.format

function HeroUpgradeStarExhibitionPanel:__init(ctrl, title)
    self.ctrl = ctrl
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_upgrade_star_exhibition_panel"
    self.view_tag = ViewMgrTag.MSG_TAG
    self.is_csb_action = true
    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("hero","hero"), type = ResourcesType.plist },
    }

    self.attr_list ={}
end

function HeroUpgradeStarExhibitionPanel:open_callback()
    local backpanel = self.root_wnd:getChildByName("backpanel")
    backpanel:setScale(display.getMaxScale())
    self.background = backpanel:getChildByName("background")

    self.main_container = self.root_wnd:getChildByName("main_container")
    local size = self.main_container:getContentSize()
    self.back_panel = self.main_container:getChildByName("back_panel")
    -- self.back_panel:setScale(display.getMaxScale())
    -- self.back_panel:setContentSize(cc.size(720, 550))

    local titlepanel = self.root_wnd:getChildByName("titlepanel")
    -- titlepanel:setPositionY(853)

    self.title_container = titlepanel:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    --属性
    local attr_panel = self.main_container:getChildByName("attr_panel")
    self.attr_labe_left_list = {}
    self.attr_labe_right_list = {}
    for i=1,5 do
        self.attr_labe_left_list[i] = attr_panel:getChildByName("attr_label_left"..i)
        self.attr_labe_right_list[i] = attr_panel:getChildByName("attr_label_right"..i)
    end

    local left_node = self.main_container:getChildByName("hero_node"):getChildByName("left_node")
    local right_node = self.main_container:getChildByName("hero_node"):getChildByName("right_node")

    self.left_item = HeroExhibitionItem.new(1, false)
    self.right_item = HeroExhibitionItem.new(1, false)

    self.left_item:setPosition(0,0)
    self.left_item:setAnchorPoint(cc.p(0.5, 0.5))
    self.right_item:setPosition(0,0)
    self.right_item:setAnchorPoint(cc.p(0.5, 0.5))

    left_node:addChild(self.left_item)
    right_node:addChild(self.right_item)

    self.skill_node = self.main_container:getChildByName("skill_node")
    self.arrow = self.skill_node:getChildByName("arrow_1086")

    self.main_container:getChildByName("common_90044"):getChildByName("attr_label"):setString(TI18N("属性提升"))
    self.main_container:getChildByName("common_90044_0"):getChildByName("skill_label"):setString(TI18N("技能提升"))
    self.exit_tips_label = self.main_container:getChildByName("exit_tips_label")
    self.exit_tips_label:setString(TI18N("点击任意处关闭"))
end

function HeroUpgradeStarExhibitionPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
end

--关闭
function HeroUpgradeStarExhibitionPanel:_onClickBtnClose()
    self.ctrl:openHeroUpgradeStarExhibitionPanel(false)
    -- ActionController:getInstance():checkOpenActionLimitGiftMainWindow()
    if self.new_data and self.new_data.star == 13 then
        --13星的因为有特效出现.所以不检查下一个显示  在天赋技能栏播放后才显示 准确点是在 skill_unlock_window关闭后
    else
        GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
    end
end

function HeroUpgradeStarExhibitionPanel:openRootWnd(old_data,new_data)
    if not old_data or not new_data then return end

    BattleResultMgr:getInstance():setWaitShowPanel(true)
    playOtherSound("c_get")
    self.old_data = old_data
    self.new_data = new_data
    
    self:handleEffect(true, open_type)

    self:updateHead()
    self:updateAttrList()
end

function HeroUpgradeStarExhibitionPanel:updateHead()
    self.left_item:setData(self.old_data)
    self.right_item:setData(self.new_data)
end
--更新属性
function HeroUpgradeStarExhibitionPanel:updateAttrList()

    local key = getNorKey(self.old_data.bid, self.old_data.star)
    local old_star_config = Config.PartnerData.data_partner_star(key)
    local new_key = getNorKey(self.new_data.bid, self.new_data.star)
    local new_star_config = Config.PartnerData.data_partner_star(new_key)

    if not old_star_config or not new_star_config then return end
    local show_list = {} 
    --战斗力
    table_insert(show_list, {left_value = self.old_data.power, right_value = self.new_data.power})

    --属性
    local attr_list = {"hp","atk","def","speed"}
    for i,attr_str in ipairs(attr_list) do
        local attr_name = Config.AttrData.data_key_to_name[attr_str]
        local old_value = self.old_data[attr_str] or 0
        local new_value = self.new_data[attr_str] or 0
        local str2 = string_format("%s: %s", attr_name, old_value)
        table_insert(show_list, {left_value = str2, right_value = new_value})
    end

    for i,v in ipairs(show_list) do
        self.attr_labe_left_list[i]:setString(v.left_value)
        self.attr_labe_right_list[i]:setString(v.right_value)
    end

    --技能
    local old_skill = nil
    local new_skill_list = {}
    --[序号] = 技能id
    local dic_old_skill = {}
    for i,v in ipairs(old_star_config.skills) do
        dic_old_skill[v[1]] = v[2]
    end 
    for i,v in ipairs(new_star_config.skills) do
        -- == 1 表示普通技能
        if v[1] ~= 1 then
            if dic_old_skill[v[1]] then
                if dic_old_skill[v[1]] ~= v[2] then
                    if old_skill == nil then
                        old_skill = dic_old_skill[v[1]]
                    end
                    table_insert(new_skill_list, v[2])
                end
            else --说明升星产生新技能了
                if old_skill == nil then
                    old_skill = dic_old_skill[v[1]]
                end
                table_insert(new_skill_list, v[2])

            end
        end
    end
    local skill_count = #new_skill_list
    local scale = 0.8
    if skill_count > 0 then
        if skill_count == 1 and old_skill ~= nil then
            self.left_skill_item = SkillItem.new(true, false, nil, scale, true)
            self.right_skill_item = SkillItem.new(true, false, nil, scale, true)
            self.left_skill_item:setPosition(cc.p( -140 ,0))
            self.right_skill_item:setPosition(cc.p( 140 ,0))
            self.left_skill_item:setData({skill_id = old_skill})
            self.right_skill_item:setData({skill_id = new_skill_list[1]})
            self.skill_node:addChild(self.left_skill_item)
            self.skill_node:addChild(self.right_skill_item)
        else
            self.arrow:setVisible(false)
            local skill_width = SkillItem.Width * scale + 10
            self.skill_list = {}
            local x = - skill_width * skill_count * 0.5 + skill_width * 0.5 
            for i,skill_id in ipairs(new_skill_list) do
                local skill_item = SkillItem.new(true, false, nil, scale, true)
                skill_item:setPosition(x + (i - 1) * skill_width , 0)
                skill_item:setData({skill_id = skill_id})
                self.skill_node:addChild(skill_item)
                table_insert(self.skill_list, skill_item)
            end
        end
    else
        self.arrow:setVisible(false)
        createLabel(24,Config.ColorData.data_new_color4[6],nil,0,0,TI18N("无技能提升"),self.skill_node,2, cc.p(0.5,0.5))
    end
end



function HeroUpgradeStarExhibitionPanel:handleEffect(status, open_type)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local action = PlayerAction.action_5
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect)
        end
    end
end 

function HeroUpgradeStarExhibitionPanel:close_callback()
    self:handleEffect(false)
    if self.left_item then
        self.left_item:DeleteMe()
        self.left_item = nil
    end 
    if self.right_item then
        self.right_item:DeleteMe()
        self.right_item = nil
    end 
    if self.left_skill_item then
        self.left_skill_item:DeleteMe()
        self.left_skill_item = nil
    end
    if self.right_skill_item then
        self.right_skill_item:DeleteMe()
        self.right_skill_item = nil
    end
    if self.skill_list then
        for i,v in ipairs(self.skill_list) do
            v:DeleteMe()
        end
        self.skill_list = nil
    end
    -- if self.new_data.star == 13 then
    if self.new_data.star > 0 then
        --目前专门处理显示13星开启天赋处理 
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Update_Star_Close_Event, self.new_data)
    end
    self.ctrl:openHeroUpgradeStarExhibitionPanel(false)
end

function HeroUpgradeStarExhibitionPanel:onExitAnim()
    GlobalEvent:getInstance():Fire(EventId.CAN_OPEN_LEVUPGRADE, true)
    GlobalEvent:getInstance():Fire(PokedexEvent.Call_End_Event)
end