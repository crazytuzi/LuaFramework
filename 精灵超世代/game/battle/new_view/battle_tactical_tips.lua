-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:阵法tips]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BattleTacticalSTips = BattleTacticalSTips or BaseClass()

local string_format = string.format

function BattleTacticalSTips:__init(delay, parent)
    if parent ~= nil then
        self.parent = parent
    end
    self.delay = delay or 3
    self.WIDTH = 475  --界面的宽度
    self.HEIGHT = 235
    self:createRootWnd()
end
function BattleTacticalSTips:createRootWnd()
    self:LoadLayoutFinish()
    self:registerCallBack()
end
function BattleTacticalSTips:LoadLayoutFinish()
    self.screen_bg = ccui.Layout:create()
    self.screen_bg:setAnchorPoint(cc.p(0.5, 0.5))
    self.screen_bg:setContentSize(cc.size(SCREEN_WIDTH, display.height))
    self.screen_bg:setTouchEnabled(true)
    self.screen_bg:setSwallowTouches(false)

    self.root_wnd = ccui.Widget:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(cc.p(0, 0))
    self.screen_bg:addChild(self.root_wnd)

    self.info_layer = ccui.Layout:create()
    self.info_layer:setCascadeOpacityEnabled(true)
    self.info_layer:setOpacity(0)
    self.screen_bg:addChild(self.info_layer)
    self.info_layer:runAction(cc.Spawn:create(cc.FadeIn:create(0.2)))

    local black = ccui.ImageView:create(PathTool.getResFrame("common", "common_30001"), LOADTEXT_TYPE_PLIST)
    black:setAnchorPoint(cc.p(0, 1))
    black:setScale9Enabled(true)
    black:setCapInsets(cc.rect(22, 22, 1, 1))
    self.info_layer.back = black
    self.info_layer:addChild(black)
end
--判断是否需要千分比显示
function BattleTacticalSTips:isShowPer(value)
    if value == "hit_rate" or value == "dodge_rate" or value == "crit_rate" or value == "crit_ratio" or value == "hit_magic" or value == "dodge_magic" or
    value == "dam" or value == "res" or value == "be_cure" or value == "cure" or value == "res_p" or value == "dam_s" or value == "res_s" or
    value == "dam_p" then
        return true
    end
    return false
end

function BattleTacticalSTips:isRestrainS(type_, type2)
    local restrain_s_data = Config.FormationData.data_form_data[type_].restrain_s
    for i = 1, #restrain_s_data do
        local vo = restrain_s_data[i]
        if vo == type2 then
            return true
        end
    end
    return false
end

function BattleTacticalSTips:setTacticalInfo(data_vo, form_info_2)
    local type2, lev = data_vo[1],data_vo[2]
    local content = createRichLabel(20, 10, cc.p(0, 1), nil, 0, 0, self.WIDTH - 20)
    local temp_str = ""
    local form_config = Config.FormationData.data_form_data
    local type_config = form_config[type2]
    if type_config == nil then return end

    -- 敌方阵法如果存在的话,判断克制关系
    if form_info_2 then
        local _type, _lev = form_info_2[1], form_info_2[2]
        if _type ~= type2 then -- 2者不一样才判断
            if self:isRestrainS(type2, _type) then -- 克制对方
                temp_str = string_format("<div fontcolor=#14ff32 fontsize = 24>%s</div>", TI18N("[克制敌方]"))
            elseif self:isRestrainS(_type, type2) then -- 被对方克制
                temp_str = string_format("<div fontcolor=#E23737 fontsize = 24>%s</div>", TI18N("[被克]"))
            end
        end
    end

    local str = string_format("<div fontcolor=#e260ff fontsize=24>%s  </div>%s\n", type_config.name, temp_str)
    content:setString(str)
    self.info_layer.back:addChild(content)

    local size2 = content:getSize()
    local height = 0
    local post_data_lenght = 0
    height = height + size2.height
    local pos_data = form_config[type2].pos
    local attr_data = Config.FormationData.data_form_attr[type2][lev]
    local str_list = {}
    local analyDesc = function(data, opp_pos, i)
        local str_2 = ""
        if not data[1] then
            return
        end
        for i = 1, #data do
            local vo = data[i]
            local name = Config.AttrData.data_key_to_name[vo[1]]
            if vo[2] ~= nil then
                local temp = vo[2]
                if vo[2] < 0 then
                    if PartnerCalculate.isShowPerByStr(tostring(vo[1])) == true then --千分比
                        temp = (vo[2] / 10)
                        temp = tostring(temp) .. "%"
                    end
                    str_2 = string.format("%s<div fontcolor=#ffffdc>%s</div><div fontcolor=#ff5050>%s</div>", str_2, name, temp)
                else
                    if PartnerCalculate.isShowPerByStr(tostring(vo[1])) == true then --千分比
                        temp = (vo[2] / 10)
                        temp = tostring(temp) .. "%"
                    end
                    str_2 = string.format("%s<div fontcolor=#ffffdc>%s</div>+%s", str_2, name, temp)
                end
            end
        end
        str_2 = string.format("<div fontcolor=#ffffdc>%s%s:  </div><div fontcolor=#14ff32>%s</div>",TI18N("位置"),opp_pos or 0,str_2)
        return str_2
    end
    local length = #pos_data or 5
    for i = 1, length do
        local pos = pos_data[i]
        local opp_pos = pos[2]
        local attr = attr_data["attr_" .. opp_pos]
        if not str_list[i] then
            local content_str = createRichLabel(20, 159, cc.p(0, 1), nil, 0, 0, self.WIDTH - 20)
            self.info_layer.back:addChild(content_str)
            str_list[i] = content_str
        end
        str_list[i]:setString(analyDesc(attr, opp_pos, i))
        local size_temp = str_list[i]:getSize()
        height = height + size_temp.height
    end
        
    height = (10) * length + height
    post_data_lenght = height

    --强克制
    local restrain_s_data = form_config[type2].restrain_s
    local content_s_str = createRichLabel(20, 159, cc.p(0, 1), nil, 8, 0, self.WIDTH - 20)
    local restrain_str = ""
    local form_const_config = Config.FormationData.data_form_cost.restrain_effect
    self.info_layer.back:addChild(content_s_str)
    for i = 1, #restrain_s_data do
        local vo = restrain_s_data[i]
        if vo then
            local tmp_config = form_config[vo]
            if tmp_config then
                if restrain_str ~= "" then
                    restrain_str = restrain_str..","
                end
                restrain_str = string_format("%s%s",restrain_str, tmp_config.name)
            end
        end
    end

    local restrain_w_data = form_config[type2].restrain_w
    local content_w_str = createRichLabel(20, 159, cc.p(0, 1), nil, 8, 0, self.WIDTH - 20)
    local restrain_w_str = ""
    self.info_layer.back:addChild(content_w_str)
    for i = 1, #restrain_w_data do
        local vo = restrain_w_data[i]
        if vo then
            local tmp_config = form_config[vo]
            if tmp_config then
                if restrain_w_str ~= "" then
                    restrain_w_str = restrain_w_str..","
                end
                restrain_w_str = string_format("%s%s",restrain_w_str, tmp_config.name)
            end
        end
    end
    -- 这里颜色转换一下,面板上绿色不适用tips上
    local message = string.gsub((form_const_config.desc or ""), "249003", "14ff32")
    content_s_str:setString(string_format(TI18N("克制:  <div fontcolor=#14ff32>%s</div>\n被克制:  <div fontcolor=#0xc81414>%s</div>\n%s"), restrain_str,restrain_w_str, message))
    local size_temp = content_s_str:getSize()

    height = height + size_temp.height
    -- --弱克制
    -- local restrain_w_data = form_config[type2].restrain_w
    -- local content_str = createRichLabel(20, 22, cc.p(0, 1), nil, 0, 0, self.WIDTH - 20)
    -- self.info_layer.back:addChild(content_str)
    -- local str_2 = ""
    -- for i = 1, #restrain_w_data do
    --     local vo = restrain_w_data[i + 1]
    --     if form_config[vo] then
    --         if str_2 ~= "" then
    --             str_2 = str_2 .. "、"
    --         end
    --         str_2 = str_2 .. form_config[vo].name
    --     end
    -- end
    -- content_str:setString(TI18N("弱克制：") .. str_2)
    -- local size_temp = content_str:getSize()
    -- height = height + size_temp.height
    -- content_str:setPosition(25, 100)
    -- local content_str_2 = createRichLabel(18, 6, cc.p(0, 1), nil, 0, 0, self.WIDTH - 50)
    -- content_str_2:setString(TI18N("强克制已方全体伤害+5%,免伤+5%,弱克制已方全体伤害+5%"))
    -- self.info_layer.back:addChild(content_str_2)
    local size_temp_2 = cc.size(0,0)--content_str_2:getSize()
    height = height + size_temp_2.height + 15 * 3 --+ 30
    self.info_layer.back:setContentSize(self.WIDTH, height)
    content:setPosition(25, self.info_layer.back:getContentSize().height - 17)
    local start_y = content:getPositionY() - content:getSize().height - 10
    for i = 1, length do
        local size_temp = str_list[i]:getSize()
        str_list[i]:setPosition(25, start_y - ((i - 1) * (10 + size_temp.height))) --self.info_layer.black_bg:getPositionY() -
    end
    content_s_str:setPosition(25, self.info_layer.back:getContentSize().height - post_data_lenght - 27)
    --content_str:setPosition(25, self.info_layer.back:getContentSize().height - post_data_lenght - content_s_str:getSize().height - 40)
    --content_str_2:setPosition(25, self.info_layer.back:getContentSize().height - post_data_lenght - content_str:getSize().height - 70)
    self:adjust()
end
function BattleTacticalSTips:adjust()
    if self.parent and not tolua.isnull(self.parent) then
        local world_pos = self.parent:convertToWorldSpace(cc.p(0, 0))
        local local_pos = self.info_layer:convertToNodeSpace(world_pos)
        local target_x = local_pos.x
        local target_y = local_pos.y
        local back_size = self.info_layer.back:getContentSize()
        if local_pos.x + back_size.width > SCREEN_WIDTH then
            target_x = SCREEN_WIDTH - back_size.width
        end
        if local_pos.y - back_size.height < 0 then
            target_y = back_size.height 
        end
        self.info_layer:setPosition(target_x,target_y)
    else
        self.info_layer:setPosition(0 + self.info_layer.back:getContentSize().width/2, display.height / 2)
    end
end

function BattleTacticalSTips:registerCallBack()
    self.screen_bg:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            TipsManager:getInstance():hideTips()
        end
    end)
end
function BattleTacticalSTips:setPosition(x, y)
    self.root_wnd:setAnchorPoint(cc.p(0, 1))
    self.root_wnd:setPosition(cc.p(x, y))
end
function BattleTacticalSTips:setPos(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end
function BattleTacticalSTips:getContentSize()
    return self.root_wnd:getContentSize()
end
function BattleTacticalSTips:getScreenBg()
    return self.screen_bg
end
function BattleTacticalSTips:open()
    local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
    parent:addChild(self.screen_bg)
    self.screen_bg:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    doStopAllActions(self.screen_bg)
    delayRun(self.screen_bg, 5000, function()
        TipsManager:getInstance():hideTips()
    end)
end
function BattleTacticalSTips:close()
    self.info_layer:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), cc.CallFunc:create(function()
        doStopAllActions(self.screen_bg)
        self.screen_bg:removeFromParent()
    end)))
end