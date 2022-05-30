-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      共鸣水晶卸下放入的宝可梦
-- <br/> 2020年3月6日
-- --------------------------------------------------------------------
HeroResonatePutDownPanel = HeroResonatePutDownPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function HeroResonatePutDownPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "hero/hero_resonate_put_down_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }
    
end

function HeroResonatePutDownPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("卸下宝可梦"))

    self.left_item_node = self.main_container:getChildByName("left_item_node")
    self.right_item_node = self.main_container:getChildByName("right_item_node")
    self.right_lv = self.main_container:getChildByName("right_lv")
    self.right_lv:setString("")
    self.left_lv = self.main_container:getChildByName("left_lv")
    self.left_lv:setString("")
    self.left_hero_item = HeroExhibitionItem.new(1, false, 0, false) 
    self.left_item_node:addChild(self.left_hero_item)
    self.right_hero_item = HeroExhibitionItem.new(1, false, 0, false) 
    self.right_item_node:addChild(self.right_hero_item)

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))

    self.tips1 = self.main_container:getChildByName("tips1")
    self.tips1:setString(TI18N("还原至"))
    -- self.tips2 = self.main_container:getChildByName("tips2")
    -- self.tips2:setString(TI18N("离开共鸣水晶等级将被还原"))
    self.tips2 = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(338.00,209),nil,nil,1000)
    self.main_container:addChild(self.tips2)
    self.tips2:setString(TI18N("离开<div fontcolor=#ff0000>原力水晶</div>宝可梦等级将被还原"))
    self.tips3 = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(338.00,158),nil,nil,1000)
    self.main_container:addChild(self.tips3)
    local cell_cool_time = 86400
    local config = Config.ResonateData.data_const.cell_cool_time
    if config then
        cell_cool_time = config.val * 60
    end
    local str = TimeTool.GetTimeFormat(cell_cool_time)
    self.tips3:setString(string_format(TI18N("<div fontcolor=#249003>%s</div>后槽位可以重新添加宝可梦"), str))
    --底部线
    -- local line_img = createImage(self.main_container, nil, 0, 0, cc.p(0,0.5), false, 1)
    -- line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    -- line_img:setAnchorPoint(0.5,0)
    -- line_img:setScaleX(0.94)
    -- line_img:setPosition(cc.p(self.main_container:getContentSize().width/2, -50))

    -- local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_3")
    -- self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function HeroResonatePutDownPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)
end

--关闭
function HeroResonatePutDownPanel:onClickBtnClose()
    controller:openHeroResonatePutDownPanel(false)
end


-- 确定使用
function HeroResonatePutDownPanel:onClickBtnRight()
    if self.left_hero_vo and self.pos then
       controller:sender26427(self.left_hero_vo.partner_id, self.pos)
       self:onClickBtnClose()
    end
end
--setting
--setting.left_hero_vo 左边的宝可梦
--setting.pos 位置
function HeroResonatePutDownPanel:openRootWnd(setting)
    local setting = setting or {}
    self.left_hero_vo = setting.left_hero_vo 
    self.pos =  setting.pos 
    if not self.left_hero_vo then return end
    self.right_hevo_vo = deepCopy(self.left_hero_vo)
    local resonate_lev = self.left_hero_vo.resonate_lev or 1
    self.right_hevo_vo.resonate_lev = 0
    self.right_hevo_vo.lev = resonate_lev

    self.left_hero_item:setData(self.left_hero_vo)
    self.right_hero_item:setData(self.right_hevo_vo)
    self.left_lv:setString("Lv."..self.left_hero_vo.lev)
    self.right_lv:setString("Lv."..resonate_lev)
end


function HeroResonatePutDownPanel:close_callback()
    if self.line_load  then
        self.line_load:DeleteMe()
    end
    self.line_load = nil

    if self.left_hero_item then
        self.left_hero_item:DeleteMe()
        self.left_hero_item = nil
    end

    if self.right_hero_item then
        self.right_hero_item:DeleteMe()
        self.right_hero_item = nil
    end

    controller:openHeroResonatePutDownPanel(false)
end
