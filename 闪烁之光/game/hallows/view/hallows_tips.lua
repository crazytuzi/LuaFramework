-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣器装备的tips
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsTips = HallowsTips or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local model = controller:getModel()
local string_format = string.format

function HallowsTips:__init()
    self.is_full_screen = false
    self.layout_name = "hallows/hallows_tips"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("tips", "tips"), type = ResourcesType.plist}, 
    }
    self.win_type = WinType.Tips    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.base_list = {}
end 

function HallowsTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.lab_name = self.main_panel:getChildByName("lab_name")

    self.node_dec = self.main_panel:getChildByName("node_dec")
    self.lab_dec = createRichLabel(22, cc.c3b(0xe0,0xbf,0x98), cc.p(0,1), cc.p(0,0), 5, 0, 366)
    self.node_dec:addChild(self.lab_dec)

    self.node_item = self.main_panel:getChildByName("node_item")

    self.lab_base = self.main_panel:getChildByName("lab_base")
    self.lab_base:setString(TI18N("基础属性(升级属性强化效果)"))
    self.lab_special = self.main_panel:getChildByName("lab_special")
    self.lab_special:setString(TI18N("特殊属性(升级技能强化效果)"))
    self.lab_refine = self.main_panel:getChildByName("lab_refine")
    self.lab_refine:setString(TI18N("精炼效果(升级神器精炼效果)"))

    --基本属性
    self.attr_info_list = {}
    for i=1,2 do
        local item = {}
        item.attr_label = self.main_panel:getChildByName("attr_label"..i)
        item.attr_icon = self.main_panel:getChildByName("attr_icon"..i)
        self.attr_info_list[i] = item
    end

    -- 特殊属性
    self.special_info_list = {}
    for i=1,3 do
       local item = {}
        item.apecial_left_label = self.main_panel:getChildByName("apecial_left_label"..i)
        item.apecial_right_label = self.main_panel:getChildByName("apecial_right_label"..i)
        self.special_info_list[i] = item 
    end
    
    -- 精炼等级
    self.refine_left_label = self.main_panel:getChildByName("refine_left_label1")
    self.refine_right_label = self.main_panel:getChildByName("refine_right_label1")
end

function HallowsTips:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openHallowsTips(false)
        end
    end)
end

function HallowsTips:openRootWnd(hallows_data)
    if not hallows_data then return end
    local hallows_vo
    if type(hallows_data) == "number" then
        hallows_vo = model:getHallowsById(hallows_data)
    elseif type(hallows_data) == "table" then
        hallows_vo = hallows_data
    end
    if not hallows_vo then return end

    local hallows_id = hallows_vo.id
    local skill_lev = 1
    local is_lock = false
    if hallows_vo then
        skill_lev = hallows_vo.skill_lev
    else
        is_lock = true
    end
    self.config = Config.HallowsData.data_base[hallows_id]
    if not self.config  then return end
   
    --名字
    local str = ""
    if HallowsController:getInstance():getModel():getHallowsRefineIsOpen() then
        str = string_format(TI18N("%s(+%s)【精炼+%d级】"), self.config.name, hallows_vo.step, hallows_vo.refine_lev)
    else
        str = string_format(TI18N("%s(+%s)"), self.config.name, hallows_vo.step)
    end
    self.lab_name:setString(str)

    -- 技能伤害和精炼伤害
    local skill_atk_val, refine_atk_val = hallows_vo:getHallowsSkillAndRefineAtkVal()
    local item_config = Config.ItemData.data_get_data(self.config.item_id)
    if item_config then
        if not self.hallows_item then
            self.hallows_item = BackPackItem.new(false, false)
            self.node_item:addChild(self.hallows_item)
        end
        if hallows_vo.look_id ~= 0 then
            local magic_cfg = Config.HallowsData.data_magic[hallows_vo.look_id]
            if magic_cfg then
                self.hallows_item:setBaseData(magic_cfg.item_id)
                self.hallows_item:setMagicIcon(true)
            else
                self.hallows_item:setBaseData(self.config.item_id)
                self.hallows_item:setMagicIcon(false)
            end
        else
            self.hallows_item:setBaseData(self.config.item_id)
            self.hallows_item:setMagicIcon(false)
        end

        if is_lock then
            local res = PathTool.getResFrame("common","common_90009")
            local lock_icon =createImage(self.node_item, res, x ,y , cc.p(0.5,0.5),true,0,false)
            lock_icon:setScale(0.8)
            setChildUnEnabled(true, self.hallows_item)
        end
    end

    local skill_key = getNorKey(hallows_id, skill_lev)
    local skill_up_config = Config.HallowsData.data_skill_up(skill_key)
    if skill_up_config then
        local skill_config = Config.SkillData.data_get_skill(skill_up_config.skill_bid)
        if skill_config then
            --技能描述
            local total_atk_val = skill_atk_val + refine_atk_val
            self.lab_dec:setString(string_format(skill_config.des, total_atk_val, refine_atk_val))
        end
    end

    --属性
    local attr_data = hallows_vo.add_attr
    for i,item in ipairs(self.attr_info_list) do
        local attr = attr_data[i]
        if attr then
            local attr_id = attr.attr_id
            local attr_val = attr.attr_val
            local attr_str = Config.AttrData.data_id_to_key[attr_id]
            local res_id = PathTool.getAttrIconByStr(attr_str)
            local res = PathTool.getResFrame("common",res_id)
            loadSpriteTexture(item.attr_icon, res, LOADTEXT_TYPE_PLIST)

            local attr_name = Config.AttrData.data_key_to_name[attr_str]
            local name = string_format("%s%s+%s",TI18N("全队"), attr_name, attr_val)
            item.attr_label:setString(name)   
        else
            item.attr_label:setVisible(false)
            item.attr_icon:setVisible(false)
        end
    end
    --特殊属性
    local attr_config = Config.HallowsData.data_skill_attr[hallows_id]
    if attr_config then
        for i,item in ipairs(self.special_info_list) do
            if attr_config[i] then

                item.apecial_left_label:setString(attr_config[i].desc)
                local str = string_format(TI18N("技能等级%s级"), attr_config[i].lev_limit)
                item.apecial_right_label:setString(str)
                if is_lock or skill_lev < attr_config[i].lev_limit then
                    item.apecial_left_label:setColor(cc.c3b(0x8b,0x7b,0x69))
                    item.apecial_right_label:setColor(cc.c3b(0x8b,0x7b,0x69))
                end
            else
                item.apecial_left_label:setVisible(false)
                item.apecial_right_label:setVisible(false)
            end
        end
    end
    -- 精炼等级
    self.refine_left_label:setString(string_format(TI18N("神器技能真实伤害+%d"), refine_atk_val))
    self.refine_right_label:setString(string_format(TI18N("精炼等级%d级"), hallows_vo.refine_lev))
end




function HallowsTips:close_callback()
    if self.hallows_item then
        self.hallows_item:DeleteMe()
        self.hallows_item = nil
    end
    controller:openHallowsTips(false)
end