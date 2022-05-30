-- --------------------------------------------------------------------
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @description:
--      献祭《宝可梦和碎片》 融合 置换  回退(重生)
-- <br/>Create: 2018年11月9日
--
-- --------------------------------------------------------------------
HeroResetWindow = HeroResetWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local partner_config = Config.PartnerData.data_get_compound_info
local partner_const = Config.PartnerData.data_partner_const
local role_vo = RoleController:getInstance():getRoleVo()

function HeroResetWindow:__init(index)
    -- self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_index = index or HeroConst.SacrificeType.eHeroFuse
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "hero/hero_reset_window"
    self:loadResResources(self.res_index)

    --献祭界面选中的对象列表 [key] =  value 模式
    self.dic_select_partner_vo = {}
    self.select_count = 0

    --策划写死最多10个
    self.select_max_count = 15
    --当前碎片数量
    self.cur_chip_count = 0
    --策划要求 7星以上不能分解 (策划要求暂时取消)
    -- self.limit_star = 7
    self.view_list = {}
    --是否播放特效 待发送协议中
    self.is_play_efffect = false
    self.panel_list = {}
    self.setting = {y = -14}
end

function HeroResetWindow:loadResResources(index)
    local _index = index 
    if _index == HeroConst.SacrificeType.eHeroFuse then  --融合神殿资源
        self.res_list = {
            --{ path = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBgRes[HeroConst.CampType.eWater], true), type = ResourcesType.single },
            --{ path = PathTool.getPlistImgForDownLoad("bigbg/hero",HeroConst.CampBottomBgRes[HeroConst.CampType.eWater], false), type = ResourcesType.single },
            { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_upgrade_star_bg", true), type = ResourcesType.single },
            { path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
        } 
    elseif _index == HeroConst.SacrificeType.eHeroSacrifice then --宝可梦献祭资源
        self.res_list = {
            { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_reset_bg", true), type = ResourcesType.single },
            { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3", false), type = ResourcesType.single },
        } 
    elseif _index == HeroConst.SacrificeType.eHeroReplace then  --置换神殿资源
        self.res_list = {
            { path = PathTool.getPlistImgForDownLoad("bigbg/hero","txt_cn_hero_convert_bg", true), type = ResourcesType.single },
            --{ path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_hero_convert_stage",false), type = ResourcesType.single },
        }
    elseif _index == HeroConst.SacrificeType.eHeroDisband then                                                                  --宝可梦回退资源
        self.res_list = {
            --{ path = PathTool.getPlistImgForDownLoad("actionheroreset","actionheroreset"), type = ResourcesType.plist },
            { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_return_bg", true), type = ResourcesType.single }
        } 
    end
end


function HeroResetWindow:open_callback()
    self.main_panel = self.root_wnd:getChildByName("main_container")
    self.reset_container = self.main_panel:getChildByName("reset_container")
    self.reset_container:setZOrder(2)
    self.reset_container:setVisible(true)

    self.tab_list = {}
    self.tab_container = self.main_panel:getChildByName("tab_container")

    self.tab_container:setZOrder(3)
    for i=1,4 do--5 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.lable = tab_btn:getChildByName("title")
            object.tab_btn = tab_btn
            object.index = i
            object.is_hide = false
            self.tab_list[i] = object
        end
    end

    self:adaptationScreen()
    
end

function HeroResetWindow:updateTab(hero_vo)
    self.tab_type_list = {
        HeroConst.SacrificeType.eHeroFuse,
        HeroConst.SacrificeType.eHeroSacrifice
    }
    if not role_vo then return end
    if partner_const.hero_exchange_limit then
        if role_vo.lev >= partner_const.hero_exchange_limit.val then -- 是否开启置换神殿
            table.insert(self.tab_type_list,HeroConst.SacrificeType.eHeroReplace)
        end
    end
    if partner_const.hero_return_limit then
        if role_vo.lev >= partner_const.hero_return_limit.val then     -- 是否开启宝可梦回退
            table.insert(self.tab_type_list,HeroConst.SacrificeType.eHeroDisband) 
        end
    end
    --local len = #self.tab_type_list
    --if self.tab_list[len] then
    --    self.tab_list[len].select_bg:loadTexture(PathTool.getResFrame("common","common_2027"), LOADTEXT_TYPE_PLIST)
    --    self.tab_list[len].unselect_bg:loadTexture(PathTool.getResFrame("common","common_2026"), LOADTEXT_TYPE_PLIST)
    --    self.tab_list[len].select_bg:setScale9Enabled(true)
    --    self.tab_list[len].unselect_bg:setScale9Enabled(true)
    --    self.tab_list[len].select_bg:setCapInsets(cc.rect(25, 25, 1, 11))
    --    self.tab_list[len].unselect_bg:setCapInsets(cc.rect(25, 25, 1, 11))
    --end

    for k,btn in ipairs(self.tab_list) do
        if self.tab_type_list[k] then
            btn.is_hide = false
            btn.type  =  self.tab_type_list[k]
            btn.lable:setString(HeroConst.tabType[btn.type])
            if self.select_index and self.select_index == btn.type then
                self.cur_tab_index = k
            end
        else
            btn.is_hide = true
            if self.cur_tab_index and self.cur_tab_index == k then 
                self.cur_tab_index = 1
            end 
        end
        btn.tab_btn:setVisible(not btn.is_hide)
    end
    if self.cur_tab_index == nil then
        self.cur_tab_index = 1 
    end
    if self.tab_container then
        self.tab_container:setPositionX(360 + (4 - #self.tab_type_list) * 143/2)
    end

    self:changeSelectedTab(self.cur_tab_index, hero_vo)
end

--设置适配屏幕
function HeroResetWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_panel)
    local bottom_y = display.getBottom(self.main_panel)
    local left_x = display.getLeft(self.main_panel)
    local right_x = display.getRight(self.main_panel)

    local container_size = self.main_panel:getContentSize()
    local tab_y = self.tab_container:getPositionY()
    --self.tab_container:setPositionY(top_y - (container_size.height - tab_y))
end

function HeroResetWindow:register_event()
    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end
end

-- 切换标签页
function HeroResetWindow:changeSelectedTab( index ,hero_vo)
    if not self.tab_type_list then return end
	if self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.lable:setTextColor(cc.c3b(61,80,120))
        self.tab_object.lable:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
    end
    local _type = self.tab_type_list[index]
    if not _type then return end

    self.cur_tab_index = index
    self.select_index = _type
    self.tab_object = self.tab_list[self.cur_tab_index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.lable:setTextColor(cc.c3b(255,255,255))
        self.tab_object.lable:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end
    if self.select_panel then
		if self.select_panel.setVisibleStatus then
            self.select_panel:setVisibleStatus(false)
        end
	end
	self.select_panel = self:createPanel(self.select_index, hero_vo)
    if self.select_panel then
	   if self.select_panel.setVisibleStatus then
            self.select_panel:setVisibleStatus(true)
        end
    end
end

function HeroResetWindow:createPanel( index, hero_vo )
    local panel = self.view_list[index]
    if panel == nil then
        if index == HeroConst.SacrificeType.eHeroFuse then --融合神殿
            panel = HeroUpgradeStarFusePanel.new(hero_vo)
        elseif index == HeroConst.SacrificeType.eHeroReplace then --置换神殿
            panel = ActionHeroConvertPanel.new(self)
        elseif index == HeroConst.SacrificeType.eHeroSacrifice then   --宝可梦献祭
            panel = HeroSacrificePanel.new()
        elseif index == HeroConst.SacrificeType.eHeroDisband then -- 宝可梦回退    
            panel = HeroResetPanel.new()
        end
        panel:setPosition(cc.p(0,0))--cc.p(size.width * 0.5 , size.height * 0.5))
        self.reset_container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

function HeroResetWindow:openRootWnd(index,hero_vo)
    self.select_index =  index or HeroConst.SacrificeType.eHeroFuse
    self.is_send_proto = nil
    local hero_vo = hero_vo or nil
    self:updateTab(hero_vo)
    --self:changeSelectedTab(self.select_index,hero_vo)
end

function HeroResetWindow:close_callback()
    for k,v in pairs(self.view_list) do
		v:DeleteMe()
		v = nil
	end
    controller:openHeroResetWindow(false)
end