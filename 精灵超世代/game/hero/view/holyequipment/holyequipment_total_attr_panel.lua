-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      神装总预览
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
HolyequipmentTotalAttrPanel = HolyequipmentTotalAttrPanel or BaseClass(BaseView)
local controller = HeroController:getInstance()

function HolyequipmentTotalAttrPanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/holyequipment_total_attr_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    -- self.key_list1 = {[1]="atk",[2]="hp",[3]="def",[4]="speed"}
    -- self.key_list2 = {[1]="crit_rate",[2]="crit_ratio",[3]="hit_magic",[4]="dodge_magic"}
    -- self.key_list3 = {[1]="tenacity",[2]="hit_rate",[3]="res",[4]="dodge_rate"}
    -- self.key_list4 = {[1]="cure",[2]="be_cure",[3]="dam",[4]="dam"}
end

function HolyequipmentTotalAttrPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        -- self.background:setSwallowTouches(false)
    end
    self.container = self.root_wnd:getChildByName("main_panel")

    self:playEnterAnimatianByObj(self.main_panel , 2) 
    
    self.container_size = self.container:getContentSize()
    self.panel_bg = self.container:getChildByName("panel_bg") 
    self.panel_bg_size = self.panel_bg:getContentSize()

    self.base_fight = self.container:getChildByName("base_fight")
    self.container:getChildByName("base_attr"):setString(TI18N("饰品总加成"))

    self.attr_panel = self.container:getChildByName("attr_panel")
    self.attr_panel:getChildByName("key_name"):setString(TI18N("属性加成:"))
    self.spe_panel = self.container:getChildByName("spe_panel")
    self.spe_panel:getChildByName("key_name"):setString(TI18N("特殊效果"))


    self.skill_panel = self.spe_panel:getChildByName("skill_panel")
end

function HolyequipmentTotalAttrPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)

     --宝可梦详细信息
    self:addGlobalEvent(HeroEvent.Hero_Vo_Detailed_info, function(hero_vo)
        if hero_vo and hero_vo.partner_id == self.hero_vo.partner_id then
            self:setData(hero_vo)
        end
    end)
    
end

--关闭
function HolyequipmentTotalAttrPanel:onClickCloseBtn()
    controller:openHolyequipmentTotalAttrPanel(false)
end

--suit_data 套装属性数据 数据参考 HeroMainTabHolyequipmentPanel:getSuitData()
function HolyequipmentTotalAttrPanel:openRootWnd(hero_vo, suit_data)
    if not hero_vo then return end
    self.suit_data = suit_data
    self.hero_vo = hero_vo
    self:setData(hero_vo)
end

function HolyequipmentTotalAttrPanel:setData(hero_vo)
    --显示顺序
    local key_list = {
        [1] = "atk",            --攻击
        [2] = "hp",             --血
        [3] = "def",            --防御
        [4] = "speed",          --速度
        [5] = "crit_rate",      --暴击率
        [6] = "crit_ratio",     --暴伤害
        [7] = "hit_magic",      --控制
        [8] = "dodge_magic",    --抗控
        [9] = "tenacity",       --抗暴
        [10] = "hit_rate",      --命中
        [11] = "res",           --免伤
        [12] = "dodge_rate",    --闪避
        [13] = "cure",          --治疗
        [14] = "be_cure",       --被治疗
        [15] = "dam",           --伤害加成
        [16] = "dam_p",           --物伤
        [17] = "dam_s",           --法伤
        [18] = "res_p",           --物免
        [19] = "res_s",           --法免
    }

    local power = hero_vo.power or 0
    power = changeBtValueForPower(power)
    self.base_fight:setString(string.format(TI18N("总战力:%s"), power))

    local item_height = 40
    local size  = self.attr_panel:getContentSize()
    local x1 = size.width * 0.25
    local x2 = size.width * 0.75
    local index = 1
    local content_height = self.container_size.height - self.attr_panel:getPositionY()

    for i,key in ipairs(key_list) do
        if hero_vo[key] and hero_vo[key] > 0 then
            local row = math.floor((index-1)/2)
            local col = (index - 1) % 2
            local _x = 0
            local _y = -(item_height * 0.5 + row * item_height)
            if col == 0 then
                _x = x1
            else
                _x = x2
            end
            self:createAttrItem(_x, _y, key, hero_vo[key])
            index = index + 1
        end
    end
    --和上面最后一次抵消的
    index = index - 1 
    local row = math.floor((index-1)/2) + 1
    local height = row * item_height
    content_height = content_height + size.height + height

    if self.suit_data and next(self.suit_data) ~= nil then
        table.sort( self.suit_data, function(a, b) return a.num < b.num end)
        local skill_index = 1
        local is_had_skill = false
        local y = 0
        local x = self.container_size.width * 0.5
        for i,suit in ipairs(self.suit_data) do
            if suit.skill_id == 0 then
                self:createSkillItem(x , y - item_height * 0.5, suit.skill_desc)
                y = y - item_height
                skill_index = skill_index + 1
            else
                self.skill_panel:setPositionY(y)
                y = y - self.skill_panel:getContentSize().height
                --有技能id说明是最后那个
                self:updateSkillID(suit.skill_id, suit.skill_desc)
                is_had_skill = true
            end
        end
        self.skill_panel:setVisible(is_had_skill)
        self.spe_panel:setPositionY(self.container_size.height - content_height)
        local spe_height = size.height - y + 10
        content_height = content_height + spe_height
    else
        self.spe_panel:setVisible(false)
        content_height = content_height + 10
    end
    self.panel_bg:setContentSize(cc.size(self.panel_bg_size.width, content_height))
    local y1 = (self.container_size.height - content_height) * 0.5
    local y = self.container:getPositionY()
    self.container:setPositionY(y - y1)
end

function HolyequipmentTotalAttrPanel:createAttrItem(x, y, attr_key, attr_val)
    local item = {}
    local size = cc.size(260, 36)
    local res = PathTool.getResFrame("common","common_1145")
    item.bg = createImage(self.attr_panel, res, x,y, cc.p(0.5, 0.5), true, 0, true)
    item.bg:setContentSize(size)
    item.bg:setOpacity(128)
    item.bg:setCapInsets(cc.rect(50, 0, 1, 36))

    item.key_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(x - size.width * 0.5 + 10  , y), nil, nil, 380)
    self.attr_panel:addChild(item.key_label, 2)
    local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(attr_key, attr_val)
    local attr_str = string.format("<img src='%s' scale=1 /><div fontcolor=#3d5078> %s：</div>", res, attr_name)
    item.key_label:setString(attr_str)

    item.val_label = createLabel(22, Config.ColorData.data_new_color4[6],nil, x + size.width * 0.5 - 10, y, attr_val,self.attr_panel,nil, cc.p(1,0.5))
    item.val_label:setZOrder(2)
end

function HolyequipmentTotalAttrPanel:createSkillItem(x, y, skill_desc)
     local item = {}
    local size = cc.size(530, 35)
    local res = PathTool.getResFrame("common","common_90058")
    item.bg = createImage(self.spe_panel, res, x,y, cc.p(0.5, 0.5), true, 0, true)
    item.bg:setOpacity(128)
    item.bg:setContentSize(size)
    item.bg:setCapInsets(cc.rect(15, 15, 1, 1))

    item.skill_label = createLabel(22, cc.c4b(0xe0,0xbf,0x98,0xff),nil, x - size.width * 0.5 + 10, y, skill_desc,self.spe_panel,nil, cc.p(0,0.5))
    item.skill_label:setZOrder(2)
end

function HolyequipmentTotalAttrPanel:updateSkillID(skill_id, skill_desc)
    -- self.skill_panel
    local name = self.skill_panel:getChildByName("skill_dec1")
    name:setString(skill_desc)


    local config = Config.SkillData.data_get_skill(skill_id)
    if config then
        if self.skill_item == nil then
            self.skill_item = SkillItem.new(true,true,true,0.8)
            self.skill_item:showLockIcon(false)
            self.skill_item:setPosition(16, 6)
            local node = self.skill_panel:getChildByName("skill_node")
            node:addChild(self.skill_item)
        end
        self.skill_item:setData(config)

        if self.skill_desc == nil then
            self.skill_desc = createRichLabel(20,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(144, 110),4,nil,370)
            self.skill_panel:addChild(self.skill_desc)    
        end
        self.skill_desc:setString(config.des)
    end
end

function HolyequipmentTotalAttrPanel:close_callback()
    controller:openHolyequipmentTotalAttrPanel(false)
end