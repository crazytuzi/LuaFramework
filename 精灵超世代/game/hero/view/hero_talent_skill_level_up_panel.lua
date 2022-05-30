-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      天赋
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroTalentSkillLevelUpPanel = HeroTalentSkillLevelUpPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function HeroTalentSkillLevelUpPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_talent_skill_level_up_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

    --消耗数据列表
    self.item_list = {}
end

function HeroTalentSkillLevelUpPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("技能升级"))


    self.skill_up_panel = self.main_container:getChildByName("skill_up_panel")
    local show_item_node = self.skill_up_panel:getChildByName("show_item_node")
    self.skill_up_info = {}
    self.skill_up_info.skill_item =  SkillItem.new(true,true,true,nil,nil,false)
    self.skill_up_info.skill_item:setScale(0.9)
    show_item_node:addChild(self.skill_up_info.skill_item)
    self.skill_up_info.skill_name = self.skill_up_panel:getChildByName("skill_name")
    local dec_node = self.skill_up_panel:getChildByName("dec_node")
    self.skill_up_info.skill_desc = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(0,0),nil,nil,440)
    dec_node:addChild(self.skill_up_info.skill_desc)


    self.skill_down_panel = self.main_container:getChildByName("skill_down_panel")
    local show_item_node = self.skill_down_panel:getChildByName("show_item_node")
    self.skill_down_info = {}
    self.skill_down_info.skill_item =  SkillItem.new(true,true,true,nil,nil,false)
    self.skill_down_info.skill_item:setScale(0.9)
    show_item_node:addChild(self.skill_down_info.skill_item)
    self.skill_down_info.skill_name = self.skill_down_panel:getChildByName("skill_name")
    local dec_node = self.skill_down_panel:getChildByName("dec_node")
    self.skill_down_info.skill_desc = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(0,0),nil,nil,440)
    dec_node:addChild(self.skill_down_info.skill_desc)
    

    self.box_90025_2 = self.main_container:getChildByName("box_90025_2")
    self.page_name_1 = self.main_container:getChildByName("page_name_1")
    self.page_name_1:setString(TI18N("技能升级"))
    self.page_name_2 = self.main_container:getChildByName("page_name_2")
    self.page_name_2:setString(TI18N("升级消耗"))
    self.cost_node = self.main_container:getChildByName("cost_node")

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("遗忘技能"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("升 级"))

    self.arrow = self.main_container:getChildByName("Sprite_1")
    self.arrow:setPositionX(108)
    self.skill_max_label = self.main_container:getChildByName("skill_max_label")
    self.skill_max_label:setString("")
    -- self.close_btn = self.main_container:getChildByName("close_btn")
end

function HeroTalentSkillLevelUpPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    -- registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,false,2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 2)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 2)

    self:addGlobalEvent(HeroEvent.Hero_Level_Up_Talent_Event, function(data)
        if not data then return end
        if not self.hero_vo then return end
        if data.partner_id == self.hero_vo.partner_id then
            local skill_id = self.hero_vo.talent_skill_list[self.pos]
            self:initSkillInfo(skill_id)
        end
    end)
end

--关闭
function HeroTalentSkillLevelUpPanel:onClickBtnClose()
    controller:openHeroTalentSkillLevelUpPanel(false)
end

--遗忘
function HeroTalentSkillLevelUpPanel:onClickBtnLeft()
    if not self.skill_id then return end
    if not self.hero_vo then return end
    if not self.pos then return end
    local cost_config = Config.PartnerSkillData.data_partner_skill_back_fun(self.skill_id)
    if cost_config then
        if #cost_config.expend == 0 then
            controller:sender11098(self.hero_vo.partner_id, self.pos)
            self:onClickBtnClose()
            return
        end
        local str = TI18N("遗忘该技能需消耗 ")
        for i,v in ipairs(cost_config.expend) do
            local item_config = Config.ItemData.data_get_data(v[1])
            if item_config then
                if i ~= 1 then
                    str = str..", "
                end
                local str1 = string_format(TI18N("<img src=%s visible=true scale=0.32 /><div fontColor=#289b14 fontsize= 24>%s</div>"),PathTool.getItemRes(item_config.icon), v[2])
                str = str..str1
            end
        end
        if #cost_config.award1 > 0 then
            str = str..TI18N("\n(同时返还 ")
            for i,v in ipairs(cost_config.award1) do
                local item_config = Config.ItemData.data_get_data(v[1])
                if item_config then
                    if i ~= 1 then
                        str = str..", "
                    end
                    local str1 = string_format(TI18N("<img src=%s visible=true scale=0.32 /><div fontColor=#289b14 fontsize= 24>%s</div>"),PathTool.getItemRes(item_config.icon), v[2])
                    str = str..str1
                end
            end
            str = str..")"
        end

        local function fun()
            controller:sender11098(self.hero_vo.partner_id, self.pos)
            self:onClickBtnClose()
        end
        CommonAlert.show(str, TI18N('确认'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
    else
        controller:sender11098(self.hero_vo.partner_id, self.pos)
        self:onClickBtnClose()
    end
end
--升级
function HeroTalentSkillLevelUpPanel:onClickBtnRight()
    if not self.hero_vo then return end
    if not self.pos then return end
    controller:sender11097(self.hero_vo.partner_id, self.pos)
end

function HeroTalentSkillLevelUpPanel:openRootWnd(hero_vo, skill_id, pos)
    if not hero_vo then return end
    if not pos then return end
    if not skill_id then return end
    self.pos = pos
    self.hero_vo = hero_vo
    self:initSkillInfo(skill_id)
end

function HeroTalentSkillLevelUpPanel:initSkillInfo(skill_id)
    if not skill_id then return end
    local config = Config.PartnerSkillData.data_partner_skill_level_fun(skill_id)
    self.skill_id = skill_id
    if config then
        self:showSkillInfo(config.id, self.skill_up_info)
        self:showSkillInfo(config.next_id, self.skill_down_info)
        self:showCostInfo(config)
    else
        self:showSkillInfo(skill_id, self.skill_up_info)
        self.box_90025_2:setVisible(false)
        self.page_name_2:setVisible(false)
        self.arrow:setVisible(false)
        self.right_btn:setVisible(false)
        self.skill_max_label:setString(TI18N("该技能已满级"))
        self.skill_down_panel:setVisible(false)
        for i,item in ipairs(self.item_list) do
            item:setVisible(false) --相当于隐藏
        end
        
        --self.skill_bg = createSprite(nil,337,298,self.main_container,cc.p(0.5,0.5), LOADTEXT_TYPE)
        --self.skill_bg:setZOrder(1)
        --local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_talent_skill_max", false)
        --self.item_load = loadSpriteTextureFromCDN(self.skill_bg, bg_res, ResourcesType.single, self.item_load)
        self.skill_max_label:setZOrder(2)
        self.skill_max_label:setPositionY(307)
        self.left_btn:setZOrder(2)
        self.left_btn:setPosition(self.main_container:getContentSize().width * 0.5 , 61)
    end
end

function HeroTalentSkillLevelUpPanel:showSkillInfo(skill_id, skill_info)
    local config = Config.SkillData.data_get_skill(skill_id)
    if not config then return end
    if skill_info.skill_item then
        skill_info.skill_item:setData(config)
    end
    skill_info.skill_name:setString(config.name)
    skill_info.skill_desc:setString(config.des)
end

function HeroTalentSkillLevelUpPanel:showCostInfo(config)
    if not config then return end
    for i,item in ipairs(self.item_list) do
        item:setPositionX(10000) --相当于隐藏
    end

    local item_width = BackPackItem.Width + 160
    local start_x = - item_width * #config.expend/2 + 40
    for i,cost in ipairs(config.expend) do
        if self.item_list[i] == nil then
            self.item_list[i] = BackPackItem.new(true, true)
            self.item_list[i]:setAnchorPoint(0.5, 0.5)
            self.item_list[i]:setScale(0.7)

            self.cost_node:addChild(self.item_list[i])
        end
        local _x = start_x + (i - 1) * item_width
        self.item_list[i]:setPosition(_x, 0)
        local item_config = Config.ItemData.data_get_data(cost[1])
        if item_config then
            -- self.item_list[i]:setBaseData(cost[1], cost[2], true)
            self.item_list[i]:setData(item_config)
            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_config.id)
            self.item_list[i]:setNeedNum2(cost[2], have_num)
            self.item_list[i]:setDefaultTip(true, nil, nil , 1)
            -- local name = string_format("%sx%s", item_config.name, cost[2])
            self.item_list[i]:setGoodsName(item_config.name,cc.p(125,61),24,6,nil,nil,cc.p(0,0))
        end
    end
end

function HeroTalentSkillLevelUpPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    if self.skill_up_info and self.skill_up_info.skill_item then
        self.skill_up_info.skill_item:DeleteMe()
        self.skill_up_info = nil
    end
    if self.skill_down_info and self.skill_down_info.skill_item then
        self.skill_down_info.skill_item:DeleteMe()
        self.skill_down_info = nil
    end

    --if self.item_load then
    --    self.item_load:DeleteMe()
    --end
    --self.item_load = nil

    controller:openHeroTalentSkillLevelUpPanel(false)
end