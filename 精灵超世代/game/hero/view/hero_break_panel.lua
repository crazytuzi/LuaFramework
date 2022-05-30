-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      宝可梦进阶弹窗
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroBreakPanel = HeroBreakPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local string_format = string.format
function HeroBreakPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_break_panel"

    self.empty_res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
    self.res_list = {
        { path = self.empty_res, type = ResourcesType.single }
    }
end

function HeroBreakPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)  
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("进阶"))

    --消耗
    self.item_cost_panel1 = self.main_container:getChildByName("item_cost_panel1")
    self.item_cost_panel2 = self.main_container:getChildByName("item_cost_panel2")
    self.item_icon1 = self.item_cost_panel1:getChildByName("item_icon")
    self.item_cost1 = self.item_cost_panel1:getChildByName("label")
    self.item_icon2 = self.item_cost_panel2:getChildByName("item_icon")
    self.item_cost2 = self.item_cost_panel2:getChildByName("label")

    --属性
    local attr_panel = self.main_container:getChildByName("attr_panel")
    self.attr_icon_list = {}
    self.attr_label_key_list = {}
    self.attr_labe_left_list = {}
    self.attr_labe_right_list = {}
    for i=1,5 do
        self.attr_icon_list[i] = attr_panel:getChildByName("attr_icon"..i)
        self.attr_label_key_list[i] = attr_panel:getChildByName("attr_label_key"..i)
        self.attr_labe_left_list[i] = attr_panel:getChildByName("attr_label_left"..i)
        self.attr_labe_right_list[i] = attr_panel:getChildByName("attr_label_right"..i)
    end
    self.attr_label_key_list[1]:setString(TI18N("等级上限:"))

    --技能
    self.skill_panel = self.main_container:getChildByName("skill_panel")
    self.skill_title = self.skill_panel:getChildByName("label_title")
    
    self.skill_name = self.skill_panel:getChildByName("label_name")
    self.skill_level = self.skill_panel:getChildByName("label_level")

    self.break_btn = self.main_container:getChildByName("break_btn")
    self.break_btn:getChildByName("label"):setString(TI18N("进阶"))
end

function HeroBreakPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.break_btn, handler(self, self._onClickBtnBreak) ,true, 2)
    --添加宝可梦升星成功返回
    self:addGlobalEvent(HeroEvent.Next_Break_Info_Event, function(next_data) 
        if not next_data then return end
        if not self.hero_vo then return end
        self:setData(self.hero_vo,next_data)
    end)
end

--关闭
function HeroBreakPanel:_onClickBtnClose()
    controller:openHeroBreakPanel(false)
end

--进阶
function HeroBreakPanel:_onClickBtnBreak()
    if not self.hero_vo then return end
    controller:sender11004(self.hero_vo.id)
end

function HeroBreakPanel:openRootWnd(hero_vo)
    if not hero_vo then return end
    self.hero_vo = hero_vo
    controller:sender11016(hero_vo.partner_id)
end

function HeroBreakPanel:setData(hero_vo, next_data)
    --属性
    local key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev)
    local break_config = Config.PartnerData.data_partner_brach[key]
    local next_key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev + 1)
    local next_break_config = Config.PartnerData.data_partner_brach[next_key]
    --没有配置信息
    if break_config == nil or next_break_config == nil then return end

    for i=1, 5 do
        if i == 1 then --默认1是等级上限的
            self.attr_labe_left_list[i]:setString(break_config.lev_max)
            self.attr_labe_right_list[i]:setString(next_break_config.lev_max)
        else
            local attr = next_break_config.all_attr[i-1]
            if attr then
                -- icon
                local attr_str = attr[1]
                local res_id = PathTool.getAttrIconByStr(attr_str)
                local res = PathTool.getResFrame("common",res_id)
                loadSpriteTexture(self.attr_icon_list[i], res, LOADTEXT_TYPE_PLIST)
                --名字
                local attr_name = Config.AttrData.data_key_to_name[attr_str]
                self.attr_label_key_list[i]:setString(attr_name..":")
                --左右属性

                if attr_str == "hp_max" then 
                    attr_str = "hp"
                end
                local left_attr = hero_vo[attr_str]
                local right_attr = next_data[attr_str] or 0
                self.attr_labe_left_list[i]:setString(changeBtValueForHeroAttr(left_attr, attr_str))
                self.attr_labe_right_list[i]:setString(changeBtValueForHeroAttr(right_attr, attr_str))
            end
        end
    end
    --技能
    if next_break_config.skill_num > break_config.skill_num then
        --说明有解锁技能
        local key = getNorKey(hero_vo.bid, hero_vo.star)
        local star_config = Config.PartnerData.data_partner_star(key)
        if star_config then
            local skill_id = nil --200101
            for i,info in ipairs(star_config.skills) do
                if info[1] ==  next_break_config.skill_num then
                    skill_id = info[2]
                    break
                end
            end
            if skill_id ~= nil then
                self.skill_title:setString(TI18N("解锁技能"))
                self.skill_item = SkillItem.new(true,true,nil,0.8, false)
                local size = self.skill_panel:getContentSize()
                self.skill_item:setPosition(cc.p(80, size.height/2))
                self.skill_panel:addChild(self.skill_item)
                local config = Config.SkillData.data_get_skill(skill_id)
                if config then
                    self.skill_item:setData(config)
                    self.skill_item:addCallBack(function()
                        TipsManager:getInstance():showSkillTips(config)
                    end)
                    self.skill_name:setString(TI18N("技能名称: ")..config.name)
                    self.skill_name:setPosition(155, 30)
                    self.skill_level:setString(TI18N("技能等级: ")..config.level)
                end
            else--配置表没有填对应序号 技能 容错
                self:ShowNoneSkillInfo()    
            end
        else --配置表没有 容错未什么都没有
            self:ShowNoneSkillInfo()
        end
    else
        --什么都没
        self:ShowNoneSkillInfo()
    end

    --消耗
    if #break_config.expend == 0 then
        self.item_cost_panel1:setVisible(false)
        self.item_cost_panel2:setVisible(false)
    else
        for i=1,2 do
            local cost = break_config.expend[i]
            if cost then
                local config = Config.ItemData.data_get_data(cost[1])
                local item_icon = self["item_icon"..i]
                if config and item_icon then
                    local head_icon = PathTool.getItemRes(config.icon, false)
                    loadSpriteTexture(item_icon, head_icon, LOADTEXT_TYPE) 
                    item_icon:setScale(0.4)       
                end
                local count = BackpackController:getInstance():getModel():getItemNumByBid(cost[1])
                local str = string_format("%s/%s", MoneyTool.GetMoneyString(count,false), MoneyTool.GetMoneyString(cost[2],false))
                self["item_cost"..i]:setString(str)
                if count < cost[2] then
                    self["item_cost"..i]:setColor(cc.c3b(0xff,0x59,0x43))
                end
            else
                self["self.item_cost_panel"..i]:setVisible(false)
            end
        end
    end
end

--无技能显示信息
function HeroBreakPanel:ShowNoneSkillInfo( ... )
    self.skill_title:setVisible(false)
    self.skill_name:setString(TI18N("无技能展示"))
    self.skill_name:setPosition(115, 10)
    self.skill_level:setVisible(false)
    local size = self.skill_panel:getContentSize()
    local bg = createImage(self.skill_panel, self.empty_res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
    bg:setScale(0.6)
end

function HeroBreakPanel:close_callback()
    if self.skill_item then 
        self.skill_item:DeleteMe()
        self.skill_item = nil
    end
    controller:openHeroBreakPanel(false)
end