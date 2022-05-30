-- --------------------------------------------------------------------
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      星阶提升成功
-- <br/> 2020年4月17日
-- --------------------------------------------------------------------
HeroUpgradeStarorderExhibition = HeroUpgradeStarorderExhibition or BaseClass(BaseView)

local table_insert = table.insert
local string_format = string.format

function HeroUpgradeStarorderExhibition:__init(ctrl, title)
    self.ctrl = ctrl
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_exhibition_window"
    self.view_tag = ViewMgrTag.MSG_TAG
    self.is_csb_action = true
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("hero","hero"), type = ResourcesType.plist },
    }
    self.attr_list ={}
end

function HeroUpgradeStarorderExhibition:open_callback()
    local backpanel = self.root_wnd:getChildByName("backpanel")
    backpanel:setScale(display.getMaxScale())
    self.background = backpanel:getChildByName("background")

    self.main_container = self.root_wnd:getChildByName("main_container")
    local size = self.main_container:getContentSize()
    self.back_panel = self.main_container:getChildByName("back_panel")
    -- self.back_panel:setScale(display.getMaxScale())
    self.back_panel:setContentSize(cc.size(720, 400))
    self.Image_1 = self.back_panel:getChildByName("Image_1")
    self.Image_2 = self.back_panel:getChildByName("Image_2")
    self.Image_1:setPositionY(400)
    self.Image_1:setContentSize(cc.size(736, 200))
    self.Image_2:setContentSize(cc.size(736, 200))

    local titlepanel = self.root_wnd:getChildByName("titlepanel")
    titlepanel:setPositionY(853)

    self.title_container = titlepanel:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    
    self.left_item = HeroExhibitionItem.new(1, false)
    self.left_item:setPosition(cc.p(size.width/2,400))
    self.main_container:addChild(self.left_item)
    self.advanced_node = ccui.Layout:create()
    self.advanced_node:setPosition(cc.p(size.width/2, 322))
    self.main_container:addChild(self.advanced_node)

    local label = createLabel(24,Config.ColorData.data_color4[1],nil,size.width/2,-90,"",self.main_container,2, cc.p(0.5,0))
    label:setString(TI18N("点击任意处关闭"))
end

function HeroUpgradeStarorderExhibition:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
end

--关闭
function HeroUpgradeStarorderExhibition:_onClickBtnClose()
    self.ctrl:openBreakExhibitionWindow(false, self.unlock_skill_id)
end

function HeroUpgradeStarorderExhibition:openRootWnd(old_data,new_data)
    if not old_data or not new_data then return end

    playOtherSound("c_get")
    self.old_data = old_data
    self.new_data = new_data
    
    self:handleEffect(true, open_type)

    self:updateHead()
    self:updateAttrList()
end

function HeroUpgradeStarorderExhibition:updateHead()
    self.left_item:setData(self.new_data)

    local max_count = self.ctrl:getModel():getHeroMaxBreakCountByInitStar(self.new_data.init_star)
    local star_width = 27 + 8
    local break_count = self.new_data.break_lev
    local x = - star_width * max_count * 0.5 + star_width * 0.5
    for i=1,max_count do
        if i <= break_count then
            local res = PathTool.getResFrame("hero","hero_info_1")
            local star = createSprite(res, x + (i-1)*star_width, 0, self.advanced_node, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 1)
        else
            local res = PathTool.getResFrame("hero","hero_info_2")
            local star = createSprite(res, x + (i-1)*star_width, 0, self.advanced_node, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 0)
        end
    end

end
--更新属性
function HeroUpgradeStarorderExhibition:updateAttrList()
    local old_break_lev = self.old_data.break_lev or 0
    local new_break_lev = self.new_data.break_lev or 0

    local key = getNorKey(self.old_data.type, self.old_data.break_id, old_break_lev)
    local old_break_config = Config.PartnerData.data_partner_brach[key]
    local new_key = getNorKey(self.new_data.type, self.new_data.break_id, new_break_lev)
    local new_break_config = Config.PartnerData.data_partner_brach[new_key]

    if not old_break_config or not new_break_config then return end

    --查找是否有解锁新技能
    if new_break_config.skill_num > old_break_config.skill_num then
        --说明有解锁技能
        local key = getNorKey(self.old_data.bid, self.old_data.star)
        local star_config = Config.PartnerData.data_partner_star(key)
        if star_config then
            local skill_id = nil --200101
            for i,info in ipairs(star_config.skills) do
                if info[1] ==  new_break_config.skill_num then
                    skill_id = info[2]
                    break
                end
            end
            if skill_id ~= nil then
                self.unlock_skill_id = skill_id
            end
        end
    end

    local show_list = {} 
    --战斗力
    local res = PathTool.getResFrame("common","common_90001")
    local str = string_format(" <img src='%s' />  %s", res, changeBtValueForPower(self.old_data.power))
    table_insert(show_list, {left_value = str, right_value = changeBtValueForPower(self.new_data.power)})
    --等级上限
    local str1 = string_format("%s: %s", TI18N("等级上限"), old_break_config.lev_max)
    table_insert(show_list, {left_value = str1 , right_value = new_break_config.lev_max})

    --属性
    for i,v in ipairs(new_break_config.all_attr) do
        local attr_str = v[1]
        if attr_str == "hp_max" then 
            attr_str = "hp"
        end
        local attr_name = Config.AttrData.data_key_to_name[attr_str]
        local str2 = string_format("%s: %s", attr_name, changeBtValueForHeroAttr(self.old_data[attr_str], attr_str))
        table_insert(show_list, {left_value = str2, right_value = changeBtValueForHeroAttr(self.new_data[attr_str], attr_str)})
    end

    for i,v in ipairs(show_list) do
        if not self.attr_list[i] then 
            self.attr_list[i] = {}

            local res = PathTool.getResFrame("common","common_90044")
            local bg = createImage(self.main_container, res,20,230-(i-1)*50, cc.p(0,0), true, 0, true)
            bg:setContentSize(cc.size(675,43))
            if i ~=1 then
                bg:setOpacity(160)
            end
            local now_label =createRichLabel(22, cc.c4b(0xff,0xee,0xac,0xff), cc.p(0,0), cc.p(130,290-i*50), 0, 0, 400)
            self.main_container:addChild(now_label) 
            local next_label = createRichLabel(22, cc.c4b(0x35,0xff,0x14,0xff), cc.p(0,0), cc.p(430,290-i*50), 0, 0, 400)
            self.main_container:addChild(next_label) 
            local res = PathTool.getResFrame("common","common_90017")
            local arrow =  createImage(self.main_container, res,330,240-(i-1)*50, cc.p(0,0), true, 0, false)
            self.attr_list[i].now_label = now_label
            self.attr_list[i].next_label = next_label
            self.attr_list[i].arrow = arrow
        end

        self.attr_list[i].now_label:setString(v.left_value )
        self.attr_list[i].next_label:setString(v.right_value )
    end
end



function HeroUpgradeStarorderExhibition:handleEffect(status, open_type)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local action = PlayerAction.action_5
        if open_type and open_type == 2 then 
            action = PlayerAction.action_6
        end
        action = PlayerAction.action_6
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect)
        end
    end
end 

function HeroUpgradeStarorderExhibition:close_callback()
    self:handleEffect(false)
    if self.left_item then
        self.left_item:DeleteMe()
        self.left_item = nil
    end
    self.ctrl:openBreakExhibitionWindow(false)
end

function HeroUpgradeStarorderExhibition:onExitAnim()
    GlobalEvent:getInstance():Fire(EventId.CAN_OPEN_LEVUPGRADE, true)
    GlobalEvent:getInstance():Fire(PokedexEvent.Call_End_Event)
end