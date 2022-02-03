-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄属性tips
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
HeroTipsAttrPanel = HeroTipsAttrPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()

function HeroTipsAttrPanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/hero_tips_attr_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.key_list1 = {[1]="atk",[2]="hp",[3]="def",[4]="speed"}
    self.key_list2 = {[1]="crit_rate",[2]="crit_ratio",[3]="hit_magic",[4]="dodge_magic"}
    self.key_list3 = {[1]="tenacity",[2]="hit_rate",[3]="res",[4]="dodge_rate"}
    self.key_list4 = {
        [1]="cure",
        [2]="be_cure",
        [3]="dam",
        -- [4]="dam",
        [4] = "dam_p",           --物伤
        [5] = "dam_s",           --法伤
        [6] = "res_p",           --物免
        [7] = "res_s",           --法免
    }
end

function HeroTipsAttrPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        -- self.background:setSwallowTouches(false)
    end
    self.container = self.root_wnd:getChildByName("main_panel")
    self.panel_bg = self.container:getChildByName("panel_bg") 
    self.panel_bg_size = self.panel_bg:getContentSize()
    local bottom_panel = self.container:getChildByName("bottom_panel")
    self.bottom_panel = bottom_panel
    self.bottom_panel_y = bottom_panel:getPositionY()

    self.container:getChildByName("base_attr"):setString(TI18N("基本属性"))
    self.container:getChildByName("special_attr"):setString(TI18N("特殊属性"))
    --属性信息
    self.attr_panel_list = {}
    self.attr_list = {}
    for k=1,3 do
        local attr_panel = self.container:getChildByName("attr_panel_"..k)
        self.attr_panel_list[k] = attr_panel
        self.attr_list[k] = {}
        local key_attr_name = "key_list"..k
        for i=1,4 do
            local item = {}
            item.icon = attr_panel:getChildByName("attr_icon"..i)
            item.key = attr_panel:getChildByName("attr_key"..i)
            item.value = attr_panel:getChildByName("attr_label"..i)
            item.attr_key = self[key_attr_name][i]
            self.attr_list[k][i] = item
        end
    end
    --这个可以做无限长
    local attr_panel = self.container:getChildByName("attr_panel_4")
    self.attr_panel_list[4] = attr_panel
    self.attr_list[4] = {}
    for i,v in ipairs(self.key_list4) do
        local item = {}
        item.icon = attr_panel:getChildByName("attr_icon"..i)
        item.key = attr_panel:getChildByName("attr_key"..i)
        item.value = attr_panel:getChildByName("attr_label"..i)
        item.attr_key = self.key_list4[i]
        self.attr_list[4][i] = item
    end

    --下面两个
    -- 公会等级

    self.guild_level_key = bottom_panel:getChildByName("attr_key1")
    self.guild_pvp_level_key = bottom_panel:getChildByName("attr_key2")
    self.halidom_level_key = bottom_panel:getChildByName("attr_key3")
    self.resonate_level_key = bottom_panel:getChildByName("attr_key4")

    self.guild_level_value = bottom_panel:getChildByName("attr_label1")
    self.guild_pvp_level_value = bottom_panel:getChildByName("attr_label2")
    self.halidom_level_value = bottom_panel:getChildByName("attr_label3")
    self.resonate_level_value = bottom_panel:getChildByName("attr_label4")

    self.title_name = bottom_panel:getChildByName("title_name")
    self.title_name:setString(TI18N("加成项"))
    self.goto_btn_1 = bottom_panel:getChildByName("goto_btn_1")
    self.goto_btn_2 = bottom_panel:getChildByName("goto_btn_2")
    self.goto_btn_3 = bottom_panel:getChildByName("goto_btn_3")
    self.goto_btn_4 = bottom_panel:getChildByName("goto_btn_4")

    self.bottom_btn = bottom_panel:getChildByName("bottom_btn")
    self.is_hide = false
end

function HeroTipsAttrPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)

    registerButtonEventListener(self.goto_btn_1, handler(self, self.onClickGotoBtn1) ,true, 2)
    registerButtonEventListener(self.goto_btn_2, handler(self, self.onClickGotoBtn1) ,true, 2)
    registerButtonEventListener(self.goto_btn_3, handler(self, self.onClickGotoBtn3) ,true, 2)
    registerButtonEventListener(self.goto_btn_4, handler(self, self.onClickGotoBtn4) ,true, 2)
    registerButtonEventListener(self.bottom_btn, handler(self, self.onClickBottomBtn) ,true, 2)


     --英雄详细信息
    self:addGlobalEvent(HeroEvent.Hero_Vo_Detailed_info, function(hero_vo)
        if hero_vo and hero_vo.partner_id == self.hero_vo.partner_id then
            self:setData(hero_vo)
        end
    end)
    
end

--关闭
function HeroTipsAttrPanel:onClickCloseBtn()
    controller:openHeroTipsAttrPanel(false)
end

--跳转公会技能
function HeroTipsAttrPanel:onClickGotoBtn1()
    if RoleController:getInstance():getRoleVo():isHasGuild() == false then
        message(TI18N("您暂未加入公会"))
        return
    end
    self:onClickCloseBtn()
    BaseView.closeAllView()
    ChatController:getInstance():closeChatUseAction()
    JumpController:getInstance():jumpViewByEvtData({32})
    -- BackpackController:getInstance():gotoItemSources("evt_league_skill", {})
end

--跳转圣物
function HeroTipsAttrPanel:onClickGotoBtn3()
    if not HalidomController:getInstance():getModel():checkHalidomIsOpen() then
        return
    end
    self:onClickCloseBtn()
    BaseView.closeAllView()
    ChatController:getInstance():closeChatUseAction()
    HeroController:getInstance():openHeroBagWindow(true, HeroConst.BagTab.eHalidom)
end
--共鸣跳转
function HeroTipsAttrPanel:onClickGotoBtn4()
    if not controller:getModel():checkResonateIsOpen() then
        return
    end
    self:onClickCloseBtn()
    BaseView.closeAllView()
    ChatController:getInstance():closeChatUseAction()
    controller:openHeroResonateWindow(true)
end

--隐藏
function HeroTipsAttrPanel:onClickBottomBtn()
    if self.is_hide then
        self.is_hide = false
        self.bottom_btn:setRotation(-90)
        --显示
        self.panel_bg:setContentSize(self.panel_bg_size)
        self.bottom_panel:setPositionY(self.bottom_panel_y)
        self.attr_panel_list[3]:setVisible(true)
        self.attr_panel_list[4]:setVisible(true)
    else
        self.is_hide = true
        self.bottom_btn:setRotation(90)
        --隐藏
        self.panel_bg:setContentSize(cc.size(self.panel_bg_size.width, self.panel_bg_size.height - 242))
        self.bottom_panel:setPositionY(self.bottom_panel_y + 242)
        self.attr_panel_list[3]:setVisible(false)
        self.attr_panel_list[4]:setVisible(false)
    end
    
end

function HeroTipsAttrPanel:openRootWnd(hero_vo, is_my)
    if not hero_vo then return end
    self.is_my = is_my
    self.hero_vo = hero_vo

    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo and self.hero_vo.rid and self.hero_vo.srv_id and 
        role_vo.rid == self.hero_vo.rid and role_vo.srv_id == self.hero_vo.srv_id then
        self.is_my = true
    end

    if self.is_my then
        if hero_vo.is_pokedex then
            --是否图鉴
            self:setData(hero_vo)
            self.goto_btn_1:setVisible(false)
            self.goto_btn_2:setVisible(false)
        elseif hero_vo.is_had_detailed then
            --是否已经有数据
            self:setData(hero_vo)
        else
            controller:sender11063(hero_vo.partner_id)
        end
    else
        self:setData(hero_vo)
    end
    
end

function HeroTipsAttrPanel:setData(hero_vo)
    for k,list in ipairs(self.attr_list) do
        for i,attr in ipairs(list) do
            local attr_str = attr.attr_key
            local res_id = PathTool.getAttrIconByStr(attr_str)
            local res = PathTool.getResFrame("common",res_id)
            loadSpriteTexture(attr.icon, res, LOADTEXT_TYPE_PLIST)

            local attr_name = Config.AttrData.data_key_to_name[attr_str]
            attr.key:setString(attr_name)

            local value = hero_vo[attr_str] or 0
            local is_per = PartnerCalculate.isShowPerByStr(attr_str)-- 是否为千分比
            if is_per then
                value = (value/10).."%"
            end
            attr.value:setString(value)
        end
    end
    self:setBottomInfo()
end

function HeroTipsAttrPanel:setBottomInfo()
    local string_format = string.format
    local _type = HeroConst.CareerType.eMagician
    local camp_type = HeroConst.CampType.eWater
    local config = Config.PartnerData.data_partner_base[self.hero_vo.bid]
    if config then
        _type = config.type
        camp_type = config.camp_type
    end

    local guild_level = 0 --公会等级
    local guild_pvp_skill_level = 0 --公会pvp技能等级
    local guild_pvp_attr_level = 0 --公会pvp属性等级
    local halidom_level = 0 --圣物等级
    local halidom_break = 0 --圣物阶级
    local resonate_stone_level = 0 --共鸣石碑等级
    if self.hero_vo.ext_data then
        for i,v in ipairs(self.hero_vo.ext_data) do
            if v.id == 1 then --公会等级
                guild_level = v.val or 0
            elseif v.id == 2 then
                halidom_break = v.val or 0
            elseif v.id == 3 then
                halidom_level = v.val or 0
            elseif v.id == 4 then
                resonate_stone_level = v.val or 0
            elseif v.id == 5 then
                guild_pvp_attr_level = v.val or 0
            elseif v.id == 6 then
                guild_pvp_skill_level = v.val or 0
            end
        end
    end
    if self.is_my and not self.hero_vo.is_pokedex then
        --是自己的.公会等级可能会改变
        local model = GuildskillController:getInstance():getModel()
        local level = model:getCareerSkillLevel(_type)
        local attr_lev, skill_lev = model:getCareerPvpSkillLevel(_type)
        if level ~= -1 then 
            --如果有公会技能等级信息..拿本地的
            guild_level = level
        end
        if attr_lev ~= -1 then
            guild_pvp_skill_level = skill_lev or 0
            guild_pvp_attr_level = attr_lev or 0
        end

        local halidom_vo = HalidomController:getInstance():getModel():getHalidomDataByCampType(camp_type)
        if halidom_vo then
            halidom_level = halidom_vo.lev or 0
            halidom_break = halidom_vo.step or 0
        end
        local model = controller:getModel()
        if model then
            resonate_stone_level  = model.resonate_stone_level or 0    
        end
    end

    self.guild_level_key:setString(string_format("%s-%s",TI18N("公会技能等级"), HeroConst.CareerName[_type]))
    self.guild_pvp_level_key:setString(string_format("%s-%s",TI18N("公会PVP等级"), HeroConst.CareerName[_type]))
    self.halidom_level_key:setString(string_format(TI18N("%s之圣物等级"), HeroConst.CampName[camp_type]))
    self.resonate_level_key:setString(TI18N("水晶增幅阶段"))
    self.guild_level_value:setString(string_format("lv.%s", guild_level))
    self.guild_pvp_level_value:setString(string_format("lv.%s(技能lv.%s)", guild_pvp_attr_level, guild_pvp_skill_level))
    if halidom_break == 0 and halidom_level == 0 then
        self.halidom_level_value:setString(TI18N("未解锁"))
    else
        self.halidom_level_value:setString(string_format("lv.%s(%s%s)", halidom_level, halidom_break, TI18N("阶")))
    end

    if resonate_stone_level == 0 then
        self.resonate_level_value:setString(TI18N("未解锁"))
    else
        self.resonate_level_value:setString(string_format("lv.%s", resonate_stone_level))
    end
end

function HeroTipsAttrPanel:close_callback()
    controller:openHeroTipsAttrPanel(false)
end