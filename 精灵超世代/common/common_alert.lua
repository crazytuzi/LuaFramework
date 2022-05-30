-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/7/15
-- Time: 11:16
-- 文件功能：用于提示的功能
CommonAlert = CommonAlert or BaseClass(BaseView)

CommonAlert.type =
{
    common  = 1,
    rich    = 2,
}
CommonAlert.WIDTH = 572
CommonAlert.HEIGHT = 350

CommonAlert.map_list =  {}

function CommonAlert:__init(type, title, is_auto_close, is_show_title, view_tag, win_type)
    self.type = type or CommonAlert.type.common
    self.offset_height = 95
    self.title = title
    self.timer = 0
    self.timer_for = true
    self.pk_status = FALSE
    self.auto_close = is_auto_close or TRUE
    self.is_show_title = is_show_title or TRUE
    self.view_tag = view_tag or ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "common/common_alert"
    self.win_type = win_type or WinType.Tips
end

function CommonAlert:initParam(confirm_label, confirm_callback, cancel_label, cancel_callback, close_callback)
   self.confirm_label = confirm_label or TI18N("确定")
   self.confirm_callback = confirm_callback
   self.cancel_label = cancel_label
   self.cancel_callback = cancel_callback
   self.external_close_callback = close_callback
end

function CommonAlert:open()
    BaseView.open(self)
    self:openCallBack()
end

function CommonAlert.closeAllWin()
    for i,v in ipairs(CommonAlert.map_list) do
        v:close()
    end
    CommonAlert.map_list = {}
end

function CommonAlert:close()
    for i,v in ipairs(CommonAlert.map_list) do
        if v == self then
            table.remove(CommonAlert.map_list, i)
        end
    end
    BaseView.close(self)
end

function CommonAlert:close_callback()
    if _is_game_restart then return end
    if self.timer_id then
        GlobalTimeTicket:getInstance():remove(self.timer_id)
    end
    if self.item_list and next(self.item_list) ~= nil then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = {}
    end
end

function CommonAlert:setTimerBtn(btn, btn_label, call_back)
    if btn_label == nil or btn_label == "" then return end
    if btn.label == nil then return end
    
    if self.timer_type == nil or self.timer_type == 0 then
        btn.label:setString(string.format("%s(%s)", btn_label, self.timer))
    else
        btn.label:setString(string.format("%s", TimeTool.GetTimeMS(self.timer)))
    end
    
    if self.timer > 0 then
        if self.pk_status == FALSE then
            setChildUnEnabled(true, btn)
            btn:setTouchEnabled(false)
            if btn.label then
                --btn.label:enableOutline(Config.ColorData.data_color4[84], 2)
            end
        end
    end

    self.timer_id = GlobalTimeTicket:getInstance():add(function()
        if tolua.isnull(self.alert_panel) then return end
        if self.timer > 1 then
            self.timer = self.timer - 1
            if self.timer_type == nil or self.timer_type == 0 then
                btn.label:setString(string.format("%s(%s)", btn_label, self.timer))
            else
                btn.label:setString(string.format("%s", TimeTool.GetTimeMS(self.timer)))
            end
        else
            setChildUnEnabled(false, btn)
            btn:setTouchEnabled(true)
            if btn.label then
                --btn.label:enableOutline(Config.ColorData.data_color4[264],2)
            end 
            btn.label:setString(string.format("%s", btn_label))
            if self.timer_auto_close == TRUE then
                if call_back ~= nil then
                    call_back()
                end
                self:close()
            end
        end
    end, 1, self.timer)
end

function CommonAlert:open_callback()
    self.background_panel = self.root_wnd:getChildByName("background_panel")
    self.background_panel:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)

    self.alert_panel = self.main_panel:getChildByName("main_container")
    self.alert_panel:setTouchEnabled(true)
    self.WIDTH = self.alert_panel:getContentSize().width
    
    self.title_contaier = self.main_panel:getChildByName("title_container")
    self.title_contaier:setVisible(TRUE == self.is_show_title)
    self.title_label = self.title_contaier:getChildByName("title_label")
    self.title_label:setString( self.title or TI18N("提示"))

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn.label = self.ok_btn:getChildByName("label")
    self.ok_btn.x = self.ok_btn:getPositionX()

    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn.label = self.cancel_btn:getChildByName("label")
    self.cancel_btn.x = self.cancel_btn:getPositionX()

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.close_btn:setVisible(self.external_close_callback ~= nil)
end

--打开调用
function CommonAlert:openCallBack()
    self.ok_btn.label:setString(self.confirm_label)
    --self.ok_btn.label:enableOutline(Config.ColorData.data_color4[264],2)
    if self.cancel_label then
        self.cancel_btn.label:setString(self.cancel_label)
        --self.cancel_btn.label:enableOutline(Config.ColorData.data_color4[263],2)
    end
    
    if self.timer and self.timer > 0 then
        if self.timer_for == true then
            self:setTimerBtn(self.ok_btn, self.confirm_label, self.confirm_callback)
        else
            self:setTimerBtn(self.cancel_btn, self.cancel_label, self.cancel_callback)
        end
    end

    self.line = self.main_panel:getChildByName("line")

    if self.cancel_label then
        self.cancel_btn:setVisible(true)
        self.cancel_btn:setTouchEnabled(true)
    else
        self.cancel_btn:setVisible(false)
        self.cancel_btn:setTouchEnabled(false)
    end
    if self.cancel_label then
        if self.is_lock == true then
            if self.cancel_btn then
                if self.cancel_btn then
                    self.cancel_btn.label:disableEffect(cc.LabelEffect.OUTLINE)
                    self.cancel_btn:setTouchEnabled(false)
                    setChildUnEnabled(true, self.cancel_btn)
                end
            end
        end
    end
    if self.cancel_label then
        self.ok_btn:setPositionX(self.ok_btn.x)
        self.cancel_btn:setPositionX(self.cancel_btn.x)
    else
        self.ok_btn:setPositionX(self.WIDTH * 0.5 + 16)
    end
end

--dis_y:是与中心的Y偏移量
function CommonAlert:setTextString(val, font_size, dis_y)
	dis_y = dis_y or 0
    if self.alert_txt then
       if self.alert_txt:getParent() then
           self.alert_txt:removeFromParent()
       end
       self.alert_txt = nil
    end
    font_size = font_size or 24
    if self.type == CommonAlert.type.common then
        self.alert_txt = self:recoutTextFieldSize(val, 560, font_size, 175)
    else
        self.alert_txt = self:recoutRichTextField(val, 560, font_size, 175)
        local function clickLinkCallBack( type, value )
            if type == "href" then
                if value == "privilege" then -- 前往特权商城
                    --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Privilege)
                    VipController:getInstance():openVipMainWindow(true, VIPTABCONST.PRIVILEGE)
                    if self.cancel_callback then
                        self:cancel_callback()
                    end
                    self.cancel_callback = nil
                    self:close()                    
                end
            end
        end
        self.alert_txt:addTouchLinkListener(clickLinkCallBack,{"href"})
    end
    self.alert_txt:setAnchorPoint(cc.p(0.5, 0.5))
    self.alert_panel:addChild(self.alert_txt)
    self.alert_txt:setPosition(cc.p(self.alert_panel:getContentSize().width/2, self.alert_panel:getContentSize().height/2 + dis_y))
end

--==============================--
--desc:设置二级扩展字符
--time:2018-06-05 01:59:58
--@val:
--@font_size:
--@dis_y:
--@aligment:文本对其情况
--@return 
--==============================--
function CommonAlert:setExtendTextString(val, font_size, dis_y, type, aligment, index) 
    local font_size = font_size or 22
    local dis_y = dis_y or 0
    local type = type  or CommonAlert.type.common
    local index = index or 1

    if self.extend_txt_list == nil then
        self.extend_txt_list = {}    
    end

    if self.extend_txt_list[index] then
        if self.extend_txt_list[index]:getParent() then
            self.extend_txt_list[index]:removeFromParent()
        end
        self.extend_txt_list[index] = nil
    end

    aligment = aligment or cc.TEXT_ALIGNMENT_LEFT 
    if type == CommonAlert.type.common then
        self.extend_txt_list[index] = self:recoutTextFieldSize(val, 560, font_size, 188, aligment)
    else
        self.extend_txt_list[index] = self:recoutRichTextField(val, 560, font_size, 188)
    end
    self.alert_panel:addChild(self.extend_txt_list[index]) 
    
    if aligment == cc.TEXT_ALIGNMENT_LEFT then
        self.extend_txt_list[index]:setAnchorPoint(cc.p(0, 0.5))
        self.extend_txt_list[index]:setPosition(cc.p(20, self.alert_panel:getContentSize().height / 2 + dis_y)) 
    elseif aligment == cc.TEXT_ALIGNMENT_CENTER then
        self.extend_txt_list[index]:setAnchorPoint(cc.p(0.5, 0.5))
        self.extend_txt_list[index]:setPosition(cc.p(self.alert_panel:getContentSize().width / 2, self.alert_panel:getContentSize().height / 2 + dis_y)) 
    end
end

-- 从新计算文本的大小
function CommonAlert:recoutTextFieldSize(str_label, width, font_size, color, aligment)
    color = color or 175
    aligment = aligment or cc.TEXT_ALIGNMENT_CENTER 
    local label = createWithSystemFont(str_label, DEFAULT_FONT, font_size)
    label:setTextColor(Config.ColorData.data_color4[color])
    label:setAlignment(aligment, cc.TEXT_ALIGNMENT_CENTER)
    label:setAnchorPoint(cc.p(0, 1))
    if width ~= nil then
        local label_width = label:getContentSize().width
        local label_height = label:getContentSize().height
        if label_width > width then
            local line_num = math.ceil(label_width/width)
            label:setContentSize(cc.size(width, label_height*line_num))
            label:setWidth(width)
        end
    end
    return label
end

--
function CommonAlert:recoutRichTextField(str_label,maxWidth,font_size, color)
    color = color or 175
    local Rich = require("common.richlabel.RichLabel")
    local richlabel = Rich.new {
        fontName = DEFAULT_FONT,
        fontSize = font_size,
        fontColor = Config.ColorData.data_color3[color],
        maxWidth = maxWidth or 350,
        lineSpace = 5,
        charSpace = 0,
    }
    richlabel:setString(str_label)
    richlabel:setPosition(cc.p(100,0))
    richlabel:setAnchorPoint(0, 1)
    return richlabel
end

function CommonAlert:register_event()
    self.ok_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.confirm_callback then
                if self.input_edit~=nil then
                    
                    self.confirm_callback(self.input_edit:getText())
                else
                    self:confirm_callback()
                end
            end
            if self.auto_close == TRUE then
                self.confirm_callback = nil
                self:close()
            end
        end
    end)

    if self.cancel_btn then
        self.cancel_btn:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.cancel_callback then
                    self:cancel_callback()
                end
                self.cancel_callback = nil
                self:close()
            end
        end)
    end

    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.external_close_callback ~= nil then
                self:external_close_callback()
            end
            self.external_close_callback= nil
            self:close()
        end
    end)
end

--[[
-- 提供公共的提示事件
--@param str 提示的文本内容
--@param confirm_label 确定框的文本，表示有确定框
--@param confirm_callback 确定的回调
--@param cancel_label 取消框的文本，表示有确定框
--@param cancel_callback 取消的回调
--@param type 普通文本和富文本类型
--@param close_callback 关闭的回调   可选参数  一般不设置 走取消流程 遇到关闭特殊处理的才加
--@param other_args 其他参数
-- ]]
function CommonAlert.show(str, confirm_label, confirm_callback, cancel_label, cancel_callback, type, close_callback, other_args, font_size,close)
    other_args = other_args or {}
    local view_tag = other_args.view_tag or ViewMgrTag.DIALOGUE_TAG
    local win_type = other_args.win_type or WinType.Tips
    local alert = CommonAlert.New(type, other_args.title, nil, nil, view_tag, win_type)
    alert.timer = other_args.timer
    alert.timer_auto_close = other_args.timer_auto_close or FALSE
    alert.pk_status = other_args.pk_status or FALSE
    alert.timer_for = (other_args.timer_for==nil) and true or other_args.timer_for   --默认是适用于确认回调的
    alert.is_lock = other_args.is_lock or false
    alert:initParam(confirm_label, confirm_callback, cancel_label, cancel_callback, close_callback)
    alert:open()
    if alert and alert.root_wnd and not tolua.isnull(alert.root_wnd) then
        alert:setCommonUIZOrder(alert.root_wnd)
    end
    if close == true then
        alert.close_btn:setVisible(true)
    end
    font_size = font_size or 24
    local off_y = other_args.off_y or 0
    alert:setTextString(str, font_size, off_y)
    alert.resetTitle = other_args.title
    if other_args.extend_str ~= nil and other_args.extend_str ~= "" then
        alert:setExtendTextString(other_args.extend_str, other_args.extend_size, other_args.extend_offy, other_args.extend_type, other_args.extend_aligment)
    elseif other_args.extend_list then
        --上面是单个二级扩展  这个是n个扩展 so extend_list是一个table
        --扩展的结构 和 单个二级的结构一致
        -- extend_str 表示内容
        --extend_size 内容大小
        --extend_offy 偏移量
        --extend_type 内容类型
        --extend_aligment 内容显示位置
        for i,v in ipairs(other_args.extend_list) do
            alert:setExtendTextString(v.extend_str, v.extend_size, v.extend_offy, v.extend_type, v.extend_aligment, i)
        end
    end

    -- 引导需要这个,所以暂时这样打开
    table.insert( CommonAlert.map_list, alert )
    return alert
end

--==============================--
--desc:带输入框的通用窗体
--time:2018-06-05 12:41:51
--@desc_str:扩展文字显示内容
--@placeholder_str:占位符
--@confirm_label:
--@confirm_callback:
--@cancel_label:
--@cancel_callback:
--@close:
--@close_callback:
--@font_size:
--@type:
--@is_auto_close:点击确认按钮之后，是否关闭窗体
--@size:
--@max_len:
--@other_args:扩展参数，包括了文本偏移值等
--@return 
--==============================--
function CommonAlert.showInputApply(desc_str, placeholder_str, confirm_label, confirm_callback, cancel_label, cancel_callback, close, close_callback, font_size, type, is_auto_close,size,max_len, other_args,bool)
    other_args = other_args or {}
    local alert = CommonAlert.New(type, title_str, is_auto_close)
    alert.timer = other_args.timer
    alert.timer_type = other_args.timer_type or 0
    alert.timer_auto_close = other_args.timer_auto_close or TRUE
    alert.timer_for = (other_args.timer_for==nil) and true or other_args.timer_for
    alert:initParam(confirm_label, confirm_callback, cancel_label, cancel_callback, close_callback)
    alert:open()

    local off_y = other_args.off_y 
    local off_x = other_args.off_x
    alert:createInputContainer(placeholder_str, size,max_len, other_args.desc, off_y, nil, off_x,bool)
    alert:setCommonUIZOrder(alert.root_wnd) 
    local font_size = font_size or 18

    -- 设置显示字内容  
    if desc_str ~= nil and desc_str ~= "" then
        alert:setTextString(desc_str, font_size, off_y)
    end

    -- 这里修正一下坐标位置吧
    if alert.input_edit ~= nil and alert.alert_txt~=nil then
        if off_y == nil then
            alert.alert_txt:setPositionY(alert.input_edit:getPositionY() - alert.input_edit:getContentSize().height/2 - 22)
        end
    end
    -- 引导需要这个,所以暂时这样打开
    table.insert( CommonAlert.map_list, alert )
    return alert
end

--单选框选中状态
function CommonAlert:isSelected()
    if self.check_box then
        return self.check_box:isSelected()
    end
end

--保存下时间的数据吧
CommonAlert.SaveLocalTime = {}
function CommonAlert:showCheckBox(tishi_id)
    local bg, btn = PathTool.getCheckBoxRes()
    self.check_box = RadioButton.new(self.alert_panel, bg, btn, _T("今日不再提示"), 0, RadioButtonDir.RIGHT, 20)

    self.check_box:setAnchorPoint(cc.p(0.5, 0))
    self.check_box:setTitleColor(Config.ColorData.data_color4[64])
    self.check_box:setPosition(cc.p(self.WIDTH/2-104, 12))
    self.check_box:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.check_box:setSelected(not self.check_box:isSelected())
            if self.check_box:isSelected() then
                CommonAlert.SaveLocalTime[tishi_id] = GameNet:getInstance():getTime()
            else
                CommonAlert.SaveLocalTime[tishi_id] = 0
            end
        end
    end)
end

function CommonAlert:ActionshowCheckBox(tishi_id)
    self.check_box = RadioButton.new(self.alert_panel, PathTool.getCommonRes("gouxuan1"),
    PathTool.getCommonRes("gouxuan"), _T("活动期间不再提示"), 0, RadioButtonDir.RIGHT, 20)
    self.check_box:setAnchorPoint(cc.p(0.5, 0))
    self.check_box:setTitleColor(Config.ColorData.data_color4[25])
    self.check_box:setPosition(cc.p(self.WIDTH/2, 12))
    self.check_box:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.check_box:setSelected(not self.check_box:isSelected())
            if self.check_box:isSelected() then
                CommonAlert.SaveLocalTime[tishi_id] = GameNet:getInstance():getTime()
            else
                CommonAlert.SaveLocalTime[tishi_id] = 0
            end
        end
    end)
end

--[[
    显示带物品的通用提示,暂时只支持一个物品的,多个物品视后续需求再添加
    @param:str 描述,可以不填
    @param:list 物品列表, 第一个参数是物品bid 第二个参数是物品数量
    @param:confirm_callback 确定按钮回调
    @param:confirm_label 确定按钮label
    @param:cancel_callback 取消按钮回调
    @param:cancel_label 确定按钮label
    @param:title_str title名字
    @param:type 文字显示的类型, 如果第一个参数str带多颜色,则需要需要填这个,否则默认是普通label
    @param:close_callback 关闭回调
    @param:view_tag 面板层级，引导问题用到
    @param:margin item之间的间距，默认为40
]]
function CommonAlert.showItemApply(str, list, confirm_callback, confirm_label, cancel_callback, cancel_label, title_str, font_size, type, close,close_callback,desc_label,item_info,view_tag,margin)
    type = type or CommonAlert.type.common
    local show_need = false
    item_info = item_info or {}
    if item_info.show_need then
        show_need = item_info.show_need
    end
    local win_type = item_info.win_type
    
    local alert = CommonAlert.New(type, title_str,nil,nil,view_tag, win_type)
    alert.timer = item_info.timer or 0
    alert:initParam(confirm_label, confirm_callback, cancel_label, cancel_callback, close_callback)
    alert:open()
    alert:showItemList(list,show_need,margin)
    alert:setCommonUIZOrder(alert.root_wnd) 
    font_size = font_size or 24
    desc_label = desc_label or ""
    if close == true then
        alert.close_btn:setVisible(true)
    end
    if desc_label ~= "" then
        local y = 190 
        if item_info ~= nil then
            y = item_info.y
        end
        local label = createLabel(24,86, nil,alert.alert_panel:getContentSize().width/2,y,desc_label, alert.alert_panel, nil, cc.p(0.5,1))
    end
    -- 设置显示字内容
    if str ~= nil and str ~= "" then
        local off_y = item_info.off_y or 78
        alert:setTextString(str, font_size, off_y)
    end
    return alert
end

function CommonAlert:showItemList(list,show_need,margin)
    if list == nil or next(list) == nil then return end
    self.item_list = {}
    self.item_name_list = {}
    local over_height = 60
    local item = nil
    local scale = 0.9
    local off = margin or 40
    local _x, _y = 0, 98
    local sum = #list
    local item_conf = nil
    local total_width = sum * BackPackItem.Width * scale + (sum - 1) * off
    local backpack_model = BackpackController:getInstance():getModel()
    local role_vo = RoleController:getInstance():getRoleVo()
    local assets_config = Config.ItemData.data_assets_id2label
    local panel_size = self.alert_panel:getContentSize()
    local max_width = math.max(total_width, panel_size.width)
    local start_x = 2
    if max_width <= panel_size.width then
        start_x = (panel_size.width - total_width) / 2 
    else
        max_width = max_width + start_x 
    end
    if self.item_scroll_view == nil then
        self.item_scroll_view = createScrollView(panel_size.width, panel_size.height+over_height, 0, panel_size.height, self.alert_panel, ccui.ScrollViewDir.horizontal) 
        self.item_scroll_view:setAnchorPoint(cc.p(0, 1))
        self.item_scroll_view:setInnerContainerSize(cc.size(max_width, panel_size.height+over_height))

        if sum > 4 then
            self.item_scroll_view:setTouchEnabled(true)
        else
            self.item_scroll_view:setTouchEnabled(false)
        end
    end

    for i, v in ipairs(list) do
        if v[1] and v[2] then
            local bid = v[1]
            local num = v[2]
            item_conf = Config.ItemData.data_get_data(bid)
            if item_conf then
                item = BackPackItem.new(false, true, false, scale, false, true)
                _x = start_x + (BackPackItem.Width * scale + off) * (i-1) + BackPackItem.Width*scale*0.5
                item:setBaseData(bid, num)
                item:setDefaultTip(true,true)
                if show_need == true then
                    _y = 60 + over_height
                    if assets_config[bid] == nil then -- 不是资产才需要显示需求数量
                        sum = backpack_model:getBackPackItemNumByBid(bid)
                        item:setNeedNum(num, sum)
                    end
                    item:setExtendDesc(true, item_conf.name, BackPackConst.quality_color_id[item_conf.quality]) 
                end
                item:setPosition(_x, _y)
                self.item_scroll_view:addChild(item)
                table.insert(self.item_list, item)
            end
        end
    end 
end

--计算判断是否属于今日之内的
function CommonAlert.countIsToday(tishi_id)
    local per_time = CommonAlert.SaveLocalTime[tishi_id]
    if per_time ~= nil then
        local cur_time = GameNet:getInstance():getTime()
        if (os.date("%x", per_time) == os.date("%x", cur_time)) then --时间没超过一天
            return true
        end
    end
    return false
end

function CommonAlert:createInputContainer(placeholder,size,max_len, desc, off_y, touch_enabled,off_x,bool)
    if self.input_edit == nil then
        if bool == true then
        self.input_edit = createEditBox(self.alert_panel, PathTool.getResFrame("common", "common_1021"), size or cc.size(300, 60), Config.ColorData.data_color3[81], 22, nil, 25, placeholder, nil, max_len, LOADTEXT_TYPE_PLIST)
        else
        self.input_edit = createEditBox(self.alert_panel, PathTool.getResFrame("common", "common_1021"), size or cc.size(300, 60), Config.ColorData.data_color3[81], 25, nil, 25, placeholder, nil, max_len, LOADTEXT_TYPE_PLIST)
        end
    end
    self.input_edit:setAnchorPoint(cc.p(0.5, 0.5))
    off_y = off_y or 0
    off_x = off_x or 0
    if desc ~= nil then
        self.input_edit:setText(desc)
    end
    self.input_edit:setPosition(self.alert_panel:getContentSize().width/2+off_x, 105+off_y)
end
