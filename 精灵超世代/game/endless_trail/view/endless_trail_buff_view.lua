-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼Buff界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessTrailBuffView = EndlessTrailBuffView or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
function EndlessTrailBuffView:__init(...)
    self.is_full_screen = false
    self.layout_name = "endlesstrail/endlesstrail_buff_view"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.partner_list = {}
    self.res_list = {
    }

end

function EndlessTrailBuffView:open_callback(...)
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("增益选择"))
    self.desc_label = self.main_panel:getChildByName("desc_label")
    self.desc_label:setString(TI18N("必须选择一个Buff才能继续挑战"))

    self.buff_container = self.main_panel:getChildByName("buff_container")
    self.partner_container = self.main_panel:getChildByName("partner_container")
    self.form_icon = self.partner_container:getChildByName("form_icon")
    self.form_label = self.partner_container:getChildByName("form_label")
    self.desc_label_1 = self.partner_container:getChildByName("desc_label_1")
    --self.close_btn = self.main_panel:getChildByName("close_btn")
    self.cur_num = createRichLabel(20,175,cc.p(0.5,0.5),cc.p(545,750),nil,nil,500)
 
    self.main_container:addChild(self.cur_num)
    self.buff_scroll_size = self.buff_container:getContentSize()
    local setting = {
        item_class = EndlessTrailBuffItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 1,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = EndlessTrailBuffItem.Width,               -- 单元的尺寸width
        item_height = EndlessTrailBuffItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.buff_scrollview = CommonScrollViewLayout.new(self.buff_container, cc.p(2.5,0) , ScrollViewDir.vertical, ScrollViewStartPos.top,self.buff_scroll_size, setting)
end

function EndlessTrailBuffView:openRootWnd(data)
    if data then
        self.buff_data = data
        self.cur_num:setString(string.format(TI18N("即将挑战第<div fontcolor=#249003>%s</div>关"), data.round))
        local res = "res/resource/form/form_form_icon_"..data.formation_type..".png"
        self.form_icon:loadTexture(res)
        if Config.FormationData.data_form_data  then
            local name = Config.FormationData.data_form_data[data.formation_type].name
            self.form_label:setString(name.." Lv."..data.formation_lev)
        end
      
        self:updateBuffData(data)
        self:updatePartnerData(data)
    end
end

function EndlessTrailBuffView:getData(  )
    return self.buff_data
end

function EndlessTrailBuffView:register_event(...)
end
--[[
    @desc: 增益buff选择
    author:{author}
    time:2018-08-16 14:22:38
    --@args: 
    @return:
]]
function EndlessTrailBuffView:updateBuffData(data)
    if data then
        table.sort(data.list,function(a,b)
            return a.buff_id < b.buff_id
        end)
        self.buff_scrollview:setData(data.list)
    end
end

function EndlessTrailBuffView:updatePartnerData(data)
    if data then
        local pos_info = data.partner
        if pos_info then
            local temp = {}
            for k, v in pairs(pos_info) do
                v.rare_type = v.quality
                local vo = HeroVo.New()
                vo:updateHeroVo(v)
                table.insert(temp, vo)
            end

            for i, v in ipairs(temp) do
                delayRun(self.main_container, i*2 / display.DEFAULT_FPS, function (  )
                    if not self.partner_list[i] then
                        local item =  HeroExhibitionItem.new(0.8, true)
                        self.partner_list[i] = item
                        self.partner_container:addChild(item)
                    end
                    local temp_item = self.partner_list[i]
                    if temp_item then
                        temp_item:setExtendData({from_type=HeroConst.ExhibitionItemType.eEndLessHero})
                        temp_item:setData(v,true)
                        local width = HeroExhibitionItem.Width * 0.8 
                        temp_item:setPosition(width * 0.5 + 18 + (width + 25)* (i - 1), self.partner_container:getContentSize().height / 2 - 10)
                    end
                end)
            end
        end
    end
end

function EndlessTrailBuffView:close_callback(...)
    doStopAllActions(self.main_container)
    if self.partner_list then
        for k,v in pairs(self.partner_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
        self.partner_list = nil
    end
    if self.buff_scrollview then
        self.buff_scrollview:DeleteMe()
        self.buff_scrollview = nil
    end
    controller:openEndlessBuffView(false)
end


---buff列表单项
EndlessTrailBuffItem = class("EndlessTrailBuffItem",function()
    return ccui.Layout:create()
end)

EndlessTrailBuffItem.Height = 149
EndlessTrailBuffItem.Width = 608

function EndlessTrailBuffItem:ctor()
    self:setContentSize(EndlessTrailBuffItem.Width,EndlessTrailBuffItem.Height)
    self:setAnchorPoint(cc.p(0,1))
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_buff_item"))
    self:addChild(self.root_wnd)
    self.root = self.root_wnd:getChildByName("root")
    self.buff_icon = self.root:getChildByName("buff_icon")
    self.desc_label = createRichLabel(24, 175, cc.p(0, 0.5), cc.p(130, self.root:getContentSize().height / 2), nil, nil, 250)
    self.root:addChild(self.desc_label)

    self.select_btn = self.root:getChildByName("select_btn")
    self.select_label = self.select_btn:getChildByName("select_label")
    self.select_label:setString(TI18N("选择并挑战"))
    self:registerEvent()
end

function EndlessTrailBuffItem:registerEvent( ... )
    if self.select_btn then
        self.select_btn:addTouchEventListener(function(sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                if self.data then
                    controller:send23911(self.data.buff_id)
                end
            end
        end)
    end
end

function EndlessTrailBuffItem:setData(data)
    if data then
        self.data = data
        if Config.EndlessData.data_buff_data then
            if Config.EndlessData.data_buff_data[data.group_id] then
                if Config.EndlessData.data_buff_data[data.group_id][data.buff_id] then
                     local config = Config.EndlessData.data_buff_data[data.group_id][data.buff_id] 
                     if config then
                        self.desc_label:setString(config.desc)
                        if config.icon ~= "" then
                            loadSpriteTexture(self.buff_icon,PathTool.getBuffRes(config.icon),LOADTEXT_TYPE)
                        end
                     end
                end
            end
        end
       
    end 
end

function EndlessTrailBuffItem:getData(...)
    return self.data
end

function EndlessTrailBuffItem:DeleteMe( ... )
    self:removeAllChildren()
    self:removeFromParent()
end
