-- --------------------------------------------------------------------
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @description:
--      荣耀神殿主面板
-- <br/>2018年10月26日
--
-- --------------------------------------------------------------------
PrimusMainWindow = PrimusMainWindow or BaseClass(BaseView)

local table_sort = table.sort
local string_format = string.format

function PrimusMainWindow:__init()
    self.ctrl = PrimusController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Full
    self.layout_name = "primus/primus_main_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("primus", "primus"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/primus", "primus_bigbg_1", false), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/primus", "primus_bigbg_2", false), type = ResourcesType.single}
    }
    --站台数据
    self.station_list = {}

    --tips描述
    self.tips_list = {}
    --是否已有称号
    self.is_have_title = false
end

function PrimusMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/primus", "primus_bigbg_1", false), LOADTEXT_TYPE)
    self.background:setScale( display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.main_panel:setLocalZOrder(2)
    self.explain_btn = self.main_panel:getChildByName("explain_btn")

    self.title_bg = self.main_panel:getChildByName("title_bg")
    self.title_bg:getChildByName("title_lab"):setString(TI18N("星河神殿"))
    self.exit_btn = self.title_bg:getChildByName("exit_btn")
    self.exit_btn:getChildByName("text"):setString(TI18N("退出"))
    self.tips_panel = self.main_panel:getChildByName("tips_panel")
    --设置适配
    self:adaptationScreen()

    for i=1,6 do
        local station_lay = self.main_panel:getChildByName("station_lay_"..i)
        local station_item = {}
        station_item.station_lay = station_lay
        station_item.title_img = station_lay:getChildByName("title_img")
        station_item.title_img_y = station_item.title_img:getPositionY()
        station_item.mode_node = station_lay:getChildByName("mode_node")
        station_item.name = station_lay:getChildByName("name")
        self.station_list[i] = station_item
    end

    for i=1,3 do
        self.tips_list[i] = self.tips_panel:getChildByName("tips_node_"..i)
    end
    self.tips_panel:getChildByName("title"):setString(TI18N("挑战条件:"))
    --说明
    self:initTipsInfo()
    self:addEffect()
end
--设置适配屏幕
function PrimusMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    -- local right_x = display.getRight(self.main_container)

    --主菜单 顶部的高度
    local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    --主菜单 底部的高度
    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()

    local offy = top_y - top_height - 10 
    self.title_bg:setAnchorPoint(cc.p(0.5,1))
    self.title_bg:setPosition(cc.p(360, offy))
    if top_y <= SCREEN_HEIGHT then 
        self.title_bg:setScale(display.getMaxScale())
    end

    self.explain_btn:setAnchorPoint(cc.p(0.5,1))
    self.explain_btn:setPositionY(offy)
    
    self.tips_panel:setPosition(cc.p(left_x + 2, bottom_y + bottom_height + 8)) --8 是偏移量
end

function PrimusMainWindow:register_event()
    registerButtonEventListener(self.exit_btn, handler(self, self._onClickBtnClose) ,false, 2)

    registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config = Config.PrimusData.data_const.game_rule
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,false, 1)
    
end
function PrimusMainWindow:_onClickBtnClose()
    self.ctrl:openPrimusMainWindow(false)
end

function PrimusMainWindow:_onClickByPosIndex(pos_index)
    if self.station_list and self.station_list[pos_index] and self.station_list[pos_index].sever_data then
        self.ctrl:openPrimusChallengePanel(true, self.station_list[pos_index].sever_data, self.is_have_title)
    end
end

function PrimusMainWindow:addEffect()
    self.size = self.main_container:getSize()
    --流星
    if self.scene_effect_1 == nil then
        self.scene_effect_1 = createEffectSpine(PathTool.getEffectRes(305), cc.p(self.size.width*0.5,self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.background:addChild(self.scene_effect_1, 1) 
    end

    --星星
    if self.scene_effect_2 == nil then
        self.scene_effect_2 = createEffectSpine(PathTool.getEffectRes(306), cc.p(self.size.width*0.5,self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.background:addChild(self.scene_effect_2, 1) 
    end
        
    --流水
    if self.scene_effect_3 == nil then
        self.scene_effect_3 = createEffectSpine(PathTool.getEffectRes(307), cc.p(self.size.width*0.5,self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
        self.main_container:addChild(self.scene_effect_3, 1)    
    end
end

function PrimusMainWindow:openRootWnd()
    self.ctrl:requestPrimusChallengeCount()
    self.ctrl:sender20701()
    self.model:setFirstLogin(false)
end

function PrimusMainWindow:setData(data)
    self.is_have_title = false
    table_sort(data.list, function(a, b) return a.pos < b.pos end)
    if not self.station_list then return end
    for i,v in ipairs(data.list) do
        if self.station_list[v.pos] then
            self.station_list[v.pos].sever_data = v
            self.station_list[v.pos].local_data = Config.PrimusData.data_upgrade[v.pos]

            self:updateStationInfoByPos(v.pos)
            --有数据才有监听
            registerButtonEventListener(self.station_list[i].station_lay, function() self:_onClickByPosIndex(v.pos) end ,false, 2)
        end
    end
end

function PrimusMainWindow:updateStationInfoByPos(pos_index)
    local station_item = self.station_list[pos_index]
    if not station_item then return end
    local sever_data = station_item.sever_data 
    if not sever_data then return end
    local is_self = false
    --称号
    if station_item.local_data then
        local honor_data = Config.HonorData.data_title[station_item.local_data.honor_id] 
        local offset_y = 0
        local look_config = Config.LooksData.data_data[sever_data.look_id]
        if look_config then
            offset_y = look_config.offset_y or 0
        end
        station_item.title_img:setPositionY(station_item.title_img_y + offset_y)
        if honor_data then
            local res = PathTool.getPlistImgForDownLoad("honor","txt_cn_honor_"..honor_data.res_id,false,false)
            station_item.item_load = loadSpriteTextureFromCDN(station_item.title_img, res, ResourcesType.single, station_item.item_load)
        end   
    end
    --名字
    if sever_data.name == nil or sever_data.name == "" then
        station_item.name:setString(TI18N("虚位以待"))
        station_item.name:setColor(cc.c3b(0xff,0xff,0xff))
        local look_id = self:getLookIdByData(station_item) or 340502
        --模型
        self:updateSpine(look_id, pos_index)
    else
        station_item.name:setString(sever_data.name)
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and sever_data.rid == roleVo.rid and sever_data.srv_id == roleVo.srv_id then 
            self.is_have_title = true
            is_self = true
            station_item.name:setColor(cc.c3b(0x14,0xff,0x32))
        else
            station_item.name:setColor(cc.c3b(0xff,0xe2,0x40))
        end

        --模型 
        self:updateSpine(sever_data.look_id, pos_index, is_self)
    end
end

function PrimusMainWindow:getLookIdByData( station_item)
    if not station_item then return end
    local sever_data = station_item.sever_data
    if station_item.unit_data_list == nil then
        station_item.unit_data_list = {} 
        local table_insert = table.insert
        for i,v in pairs(Config.PrimusData.data_unitdata) do
            if sever_data.pos == v.pos then
                table_insert(station_item.unit_data_list, v)
            end
        end
        table.sort( station_item.unit_data_list, function(a,b) return a.min < b.min end)
    end
    local num = sever_data.num
    local cur_data = nil
    local lenght = #station_item.unit_data_list
    for i,v in ipairs(station_item.unit_data_list) do
        if num >= v.min and num <= v.max then
            cur_data = v
            break
        end
        if i == lenght then
            cur_data = v
        end
    end
    if cur_data == nil then
        return
    end
    return cur_data.look_id
end

--更新模型,也是初始化模型
function PrimusMainWindow:updateSpine(look_id, pos_index, is_self)
    local station_item = self.station_list[pos_index]
    if not station_item then return end
    local fashion_id =  0
    local fun = function()
        if not station_item.spine then
            if not is_self and ( look_id == 500131 or look_id == 500132 ) then
                look_id = 500001   -- 130508 230508 330508
            end
            station_item.spine = BaseRole.new(BaseRole.type.role, look_id)
            station_item.spine:setAnimation(0,PlayerAction.show,true) 
            station_item.spine:setCascade(true)
            station_item.spine:setPosition(cc.p(0,45))
            station_item.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            station_item.spine:setScale(0.8)
            station_item.mode_node:addChild(station_item.spine) 
            station_item.spine:setCascade(true)
            station_item.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            station_item.spine:runAction(action)
        end
    end
    if station_item.spine then
        station_item.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        station_item.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(station_item.spine)
                station_item.spine:removeFromParent()
                station_item.spine = nil
                fun()
        end)))
    else
        fun()
    end
end

function PrimusMainWindow:initTipsInfo()
    if not self.tips_list then return end
    --默认写死 对应
    local id_list = {1,2,4}
    for i,id in ipairs(id_list) do
        local local_data = Config.PrimusData.data_upgrade[id]
        if self.tips_list[i] and local_data then 
            local str = string_format(TI18N("%s:竞技场排行<div fontcolor=#14ff32>前%s名</div>"), local_data.name, local_data.arena_rank)
            local label = createRichLabel(22, 1, cc.p(0,0), cc.p(0,0),nil,nil,500)
            label:setString(str)
            self.tips_list[i]:addChild(label)
        end
    end
end


function PrimusMainWindow:close_callback()
    for k,item in pairs(self.station_list) do
        if item.spine then
            item.spine:DeleteMe()
            item.spine = nil
        end
        if item.item_load then
            item.item_load:DeleteMe()
            item.item_load = nil
        end
    end
    self.station_item = nil

    self.ctrl:openPrimusMainWindow(false)
end
