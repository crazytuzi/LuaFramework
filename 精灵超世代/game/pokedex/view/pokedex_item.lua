-- --------------------------------------------------------------------
-- 图鉴子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PokedexItem = class("PokedexItem", function()
    return ccui.Widget:create()
end)

local controller = PokedexController:getInstance()
local model = PokedexController:getInstance():getModel()

function PokedexItem:ctor(can_bind_event)
    if can_bind_event == nil then           -- 有一些地方创建这个不需要绑定数据事件的
        self.can_bind_event = true
    else
        self.can_bind_event = can_bind_event
    end
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function PokedexItem:config()
    self.ctrl = PartnerController:getInstance()
    self.size = cc.size(194,300)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)
    self.is_show_point = false
    self:retain()
    self.is_can_call = false
    self.is_have = false
    self.star_list = {}
end
function PokedexItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("pokedex/pokedex_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.label_panel = self.main_panel:getChildByName("label_panel")
    
    --原画
    self.head_bg = self.main_panel:getChildByName("res_icon")
    self.head_bg:setCascadeOpacityEnabled(true)
    self.rare_type = self.main_panel:getChildByName("rare_type")
   

    self.hero_type = self.main_panel:getChildByName("hero_type")

    self.hero_name = self.label_panel:getChildByName("name")
    --等级
    self.hero_lev = self.label_panel:getChildByName("need_lev")

    self.add_btn = self.main_panel:getChildByName("add_btn")
    self.chips_bg = self.main_panel:getChildByName("chips")

    self.dsiband_summon_btn = self.main_panel:getChildByName("dsiband_summon_btn")

    -- self.black_bg = self.main_panel:getChildByName("black_bg")
    --星级
    self.star_con = ccui.Widget:create()
    self.main_panel:addChild(self.star_con)

    self:createProgressBar()
end

function PokedexItem:setData(data)
    if not data then return end
    self.data = data
    local res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" .. data.bid)
    self.item_load = createResourcesLoad(res_id, ResourcesType.single, function()
        if not tolua.isnull(self.head_bg) then
            loadSpriteTexture(self.head_bg, res_id, LOADTEXT_TYPE)
            self.head_bg:setScale(0.55)
            self.head_bg:setCascadeOpacityEnabled(true)
            self:showHaveIcon()
            if self.load_fun then 
                self:load_fun()
            end
        end
    end, self.item_load)

    self:createStar(data.show_star)

    local name = data.name or ""

    self.hero_name:setString(name)

    local limit_lev = data.limit_lev or 1

    self.hero_lev:setString(limit_lev)

    local hero_type = data.type or 0
    local res = PathTool.getResFrame("common","common_900"..(45+hero_type))
    self.hero_type:loadTexture(res,LOADTEXT_TYPE_PLIST)

    local rare_type = data.rare_type or 3
    local res = PathTool.getResFrame("common","common_9003"..(4-rare_type))
    self.rare_type:loadTexture(res,LOADTEXT_TYPE_PLIST)

    self.progress:setVisible(not self.is_have)
    self.add_btn:setVisible(not self.is_have)
    self.progress_bg:setVisible(not self.is_have)
    self.chips_bg:setVisible(not self.is_have)

    -- 没有拥有才需要显示是否神格召唤
    local is_deshand = model:isDisbandPartner(data.bid)
    if self.is_have == false and is_deshand == true then -- 非拥有的,切是分解过的
        self.dsiband_summon_btn:setVisible(true)
    else
        self.dsiband_summon_btn:setVisible(false)
    end
end

function PokedexItem:createProgressBar( )
    local size =self.main_panel:getContentSize()
    local bg, progress = createLoadingBar(PathTool.getResFrame("common", "common_90005"), PathTool.getResFrame("common", "common_90006"), 
        cc.size(104, 24), self.main_panel, cc.p(0.5, 1), 93, -10, true)
    
    self.progress = progress
    self.progress_bg = bg
    self.progress_label = createLabel(18,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],bg:getContentSize().width/2,bg:getContentSize().height/2+2,"",bg,2, cc.p(0.5,0.5))
end

function PokedexItem:showHaveIcon()
    local is_have = self.is_have or false
    setChildUnEnabled(not is_have,self.head_bg)
    local str = ""
    self:showCallIcon(false)
    if is_have == false then 
        --检查下是否可以召唤
        local chips_id = self.data.chips_id or 0
        local count  = BackpackController:getInstance():getModel():getBackPackItemNumByBid(chips_id) or 0
        local chips_num = self.data.chips_num or 0
        if count >= chips_num then 
            self:showCallIcon(true)
        end
        self.progress:setVisible(true)
        self.progress:setPercent((count/chips_num)*100)
        self.progress_label:setString(count.."/"..chips_num)
    else
        self.progress:setVisible(false)
    end
end

function PokedexItem:changeHaveStatus(bool)
    self.is_have = bool or false
end

function PokedexItem:showCallIcon(bool)
    if not self.call_icon and bool == false then return end
    if not self.call_icon then 
        self.select_bg = ccui.Layout:create()
        self.select_bg:setContentSize(cc.size(180,47))
        self.select_bg:setAnchorPoint(cc.p(0.5,0))
        self.select_bg:setPosition(cc.p(self.size.width/2,140))
        self.main_panel:addChild(self.select_bg)
        showLayoutRect(self.select_bg,160)

        local res = PathTool.getResFrame("pokedex","txt_cn_pokedex_2")
        self.call_icon = createImage(self.main_panel,res,self.size.width/2,145,cc.p(0.5,0),true,0,false)
    end

    self.call_icon:setVisible(bool)
    self.select_bg:setVisible(bool)
    self.is_can_call = bool
    self.call_icon:stopAllActions()
    self.call_icon:setOpacity(255)
    if bool == true then
        breatheShineAction(self.call_icon,1.5,1.5) 
    end
end

function PokedexItem:createStar(num)
    num = num or 0
    local size = cc.size(14*num,15)
    self.star_con:setContentSize(size)
    self.star_con:setPosition(cc.p(self.size.width/2,60))

    for i=1,num do 
        if not self.star_list[i] then 
            local res = PathTool.getResFrame("common","common_90013")
            local star = createImage(self.star_con,res,0,size.height/2,cc.p(0,0.5),true,0,false)
            star:setScale(1.1)
            self.star_list[i] = star
        end
        self.star_list[i]:setVisible(true)
        self.star_list[i]:setPosition(cc.p((i-1)*19-3,size.height/2))
    end
end
--事件
function PokedexItem:registerEvents()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click =
                    math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                    math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                if self.is_can_call == true then 
                    --请求合成跳转召唤
                    return 
                end
                if self.call_fun then
                    self:call_fun(self.data)
                end
            end
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        end
    end)

    self.add_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.data then return end
            local chips_id =self.data.chips_id or 0
            local config = Config.ItemData.data_get_data(chips_id)
            BackpackController:getInstance():openTipsSource( true,config )
        end
    end)

    self.dsiband_summon_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.data then return end
        end
    end)
end

function PokedexItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function PokedexItem:addCallBack(call_fun)
    self.call_fun =call_fun
end

function PokedexItem:addLoadCallBack(load_fun)
    self.load_fun = load_fun
end
function PokedexItem:getIsCall()
    return self.is_can_call or false
end
function PokedexItem:setSelectStatus(bool)
    self.select_bg:setVisible(bool)
end

function PokedexItem:setVisibleStatus(bool)
    self:setVisible(bool)
end

function PokedexItem:suspendAllActions()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
end

function PokedexItem:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    self:removeFromParent()
end



