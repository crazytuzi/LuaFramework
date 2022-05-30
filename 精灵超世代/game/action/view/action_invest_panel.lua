-- --------------------------------------------------------------------
-- 投资计划
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionInvestPanel = class("ActionInvestPanel", function()
    return ccui.Widget:create()
end)

function ActionInvestPanel:ctor(bid,type)
	self.holiday_bid = bid
	self.type = type
	self.ctrl = ActionController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.can_get = 0
	self.item_list = {}
	self:configUI()
	self:register_event()
end

function ActionInvestPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_invest_panel"))
	self.root_wnd:setPosition(-40,-120)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.bg = self.main_container:getChildByName("bg")
    local res = PathTool.getTargetRes("bigbg/action","txt_cn_action_invest_bg",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.bg) then
                self.bg:loadTexture(res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.btn = self.main_container:getChildByName("btn")
    self.btn:setTitleText(TI18N("￥88购买"))
	self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end

    self.login_label = self.main_container:getChildByName("login_label")

    self.return_label = createRichLabel(30, 1, cc.p(0,0.5), cc.p(535,self.btn:getPositionY()))
    self.return_label:setString(TI18N("<div fontcolor=#e0d5ab>已返：</div><div fontcolor=#35ff14>50%</div>"))
    self.main_container:addChild(self.return_label)
    self.return_label:setVisible(false)


    local scroll_view_size = cc.size(720,400)
    local setting = {
        item_class = ActionInvestItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = 720,               -- 单元的尺寸width
        item_height = 57,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        once_num = 1,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.main_container, cc.p(0, 180), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function ActionInvestPanel:register_event(  )
	if not self.update_action_even_event  then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
        	if data.bid == self.holiday_bid then
				if data.finish == 0 then
					ActionController:getInstance():setHolidayStatus(self.holiday_bid, false)
                end
        		self.data = data
        		self.day = data.finish
        		if data.finish == 0 then 
        			if data.aim_list and next(data.aim_list)~=nil then --未激活
        				self.btn:setTitleText(TI18N("￥88购买"))
	        			self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
        				self:createList(data.aim_list)
        				self.login_label:setString(TI18N("累计登录：")..data.finish..TI18N("天"))
        			else --领完
        				self.login_label:setString(TI18N("累计登录：7天"))
                        self.return_label:setString(string.format(TI18N("<div fontcolor=#e0d5ab>已返：</div><div fontcolor=#35ff14>%s</div>"),"800%"))
        				self.btn:setTitleText(TI18N("已领取"))
                        local path = PathTool.getResFrame("welfare","welfare_btn2")
                        self.btn:loadTextures(path,path,nil,LOADTEXT_TYPE_PLIST)
                        self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
	        			if self.item_list[7] then 
	        				self.item_list[7].gou:setVisible(true)
	        			end
        			end
        		else
        			self.return_label:setVisible(true)
        			if data.aim_list and next(data.aim_list)~=nil then 
        				
        				self:createList(data.aim_list)

        				local index = 0
        				local temp 
        				for k,v in pairs(data.aim_list) do
        					if v.status == 1 then 
        						temp = v.aim
        						break
        					elseif v.status == 2 then 
        						index = index+1
        					end
        				end
        				self.can_get = temp or index 

        				self.login_label:setString(TI18N("累计登录：")..data.finish..TI18N("天"))
        				local show_str = ""
        				if data.aim_list[index] then 
        					show_str = data.aim_list[index].aim_str
        				else
        					show_str = "0%"
        				end
        				self.return_label:setString(string.format(TI18N("<div fontcolor=#e0d5ab>已返：</div><div fontcolor=#35ff14>%s</div>"),show_str))

        				self.status = data.aim_list[self.can_get].status
        				if self.status == 0 then --未激活
        				elseif self.status == 1 then --激活可领
        					self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
        					self.btn:setTitleText(TI18N("可领取"))
                            local path = PathTool.getResFrame("welfare","welfare_btn")
                            self.btn:loadTextures(path,path,nil,LOADTEXT_TYPE_PLIST)
        				elseif self.status == 2 then --领了
        					if self.can_get+1 < 7 then 
        						self.btn:setTitleText(TI18N("明天可领"))
                                local path = PathTool.getResFrame("welfare","welfare_btn2")
                                self.btn:loadTextures(path,path,nil,LOADTEXT_TYPE_PLIST)
                                self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
        					else
        						self.btn:setTitleText(TI18N("已领取"))
                                local path = PathTool.getResFrame("welfare","welfare_btn2")
                                self.btn:loadTextures(path,path,nil,LOADTEXT_TYPE_PLIST)
                                self.btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
        					end
        				end

        			end
        		end
        		
        	end
        end)
    end

    self.btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data.finish == 0 then
				local data = Config.ChargeData.data_charge_data[100]
				sdkOnPay(data.val, nil, data.id, data.name) 
				return
			end
			if self.status then 
				if self.status == 1 then 
					self.ctrl:cs16604(self.holiday_bid,self.can_get)
				end
			end
		end
   	end)
end

function ActionInvestPanel:createList( list )
	self.item_scrollview:setData(list)
end

function ActionInvestPanel:setVisibleStatus(bool)
    WelfareController:getInstance():setWelfareStatus(ActionSpecialID.growfund, false)    
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
    	ActionController:getInstance():cs16603( self.holiday_bid)
    end
end

function ActionInvestPanel:DeleteMe()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil

	if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
end

-- --------------------------------------------------------------------
-- 投资计划子项
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionInvestItem = class("ActionInvestItem", function()
    return ccui.Widget:create()
end)

function ActionInvestItem:ctor()
	self.ctrl = ActionController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
	self:register_event()
end

function ActionInvestItem:configUI(  )
	self.root_wnd = ccui.Layout:create()
	self.root_wnd:setContentSize(cc.size(720,57))
	self.root_wnd:setAnchorPoint(0.5,0.5)
	self:addChild(self.root_wnd)

	local res = PathTool.getResFrame("welfare","welfare_title3")
	self.bg = createScale9Sprite(res, 0, 0, LOADTEXT_TYPE_PLIST, self.root_wnd)
	self.bg:setContentSize(self.root_wnd:getContentSize())
	self.bg:setAnchorPoint(0,0)

	self.gold = createRichLabel(30, 175, cc.p(0,0.5), cc.p(305,self.bg:getContentSize().height/2))
	self.bg:addChild(self.gold)

	self.coin = createRichLabel(30, 175, cc.p(0,0.5), cc.p(508,self.bg:getContentSize().height/2))
	self.bg:addChild(self.coin)

	self.gou = createImage(self.bg, PathTool.getResFrame("common","common_1043"), 25, self.bg:getContentSize().height/2, cc.p(0.5,0.5), true)
	self.gou:setVisible(false)

	self.title_bg = createImage(self.bg, PathTool.getResFrame("welfare","welfare_btn3"), 140, self.bg:getContentSize().height/2, cc.p(0.5,0.5), true)
	self.title_bg:setVisible(false)

	self.day = createRichLabel(30, 175, cc.p(0,0.5), cc.p(85,self.bg:getContentSize().height/2))
	self.bg:addChild(self.day)
end

function ActionInvestItem:setData( data )
	local color = 175
	local res = PathTool.getResFrame("welfare","welfare_title4")
	self.title_bg:setVisible(true)
	if data.aim % 2 == 0 then 
		res = PathTool.getResFrame("welfare","welfare_title3")
		self.title_bg:setVisible(false)
		color = 98
	end
	self.day:setString(string.format(TI18N("<div fontcolor=%s>登录%s天</div>"),tranformC3bTostr(color),data.aim))
	loadScale9SpriteTexture(self.bg, res, LOADTEXT_TYPE_PLIST)
	self.bg:setContentSize(self.root_wnd:getContentSize())

	self.gou:setVisible(data.status == 2)

	self.gold:setString(string.format(TI18N("<img src=%s scale=0.4 visible=true /><div fontcolor=#200b06>x%s</div>"),
										PathTool.getItemRes(Config.ItemData.data_get_data(data.item_list[1].bid).icon),data.item_list[1].num))

	if data.item_list[2] then
		self.coin:setString(string.format(TI18N("<img src=%s scale=0.4 visible=true /><div fontcolor=#200b06>x%s</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(data.item_list[2].bid).icon),data.item_list[2].num))
	end
end

function ActionInvestItem:register_event(  )

end

function ActionInvestItem:DeleteMe()
end
