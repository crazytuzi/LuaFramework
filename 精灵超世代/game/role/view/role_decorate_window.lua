-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      角色更换装饰面板
-- <br/>Create: 2018-05-15
-- --------------------------------------------------------------------
RoleDecorateWindow = RoleDecorateWindow or BaseClass(BaseView)

function RoleDecorateWindow:__init(ctrl)
	self.ctrl = ctrl
	self.role_vo = self.ctrl:getRoleVo()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Mini              	
    self.layout_name = "roleinfo/role_decorate_window"  
   	
    self.cur_index = nil
    self.cur_tab = nil
    self.pre_panel = nil
    self.view_list = {}
    self.tab_btn_list = {}

    self.res_list = {
        --{ path = PathTool.getPlistImgForDownLoad("face","face"), type = ResourcesType.plist },
    }
end

function RoleDecorateWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)
    self.title_container = self.main_container:getChildByName("title_container")
    self.title_label = self.title_container:getChildByName("title_label")
    self.title_label:setString(TI18N("更换装饰"))
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.scrollCon = self.main_container:getChildByName("scrollCon")

    self.tab_container = self.main_container:getChildByName("tab_container")
    self:creataBtnList()
end

function RoleDecorateWindow:creataBtnList(  )
	self.tab_list = {
        {label=TI18N("头像"), index=1, status=true},
        {label=TI18N("头像框"), index=2, status=true},
        {label=TI18N("冒险形象"), index=3, status=true},
        {label=TI18N("称号"), index=4, status=true},
        {label=TI18N("空间背景"), index=5, status=true},
    }
    local count = #self.tab_list
	for i = 1, count do
		tab = self.tab_container:getChildByName("tab_btn_" .. i)
		if tab ~= nil then
			tab_btn = tab
			tab_btn:setName("tab_btn_" .. i)
			if tab_btn ~= nil then
				info = self.tab_list[i]                --有序table,直接取下标去创建
				if info ~= nil then
					tab_btn.notice = info.notice or ""
					tab_btn.label =  tab_btn:getChildByName("title")--tab_btn:getTitleRenderer()
					tab_btn.label:setString(info.label)
					tab_btn.index = info.index
					--tab_btn.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
					tab_btn:setTouchEnabled(info.status)
                    tab_btn:setBright(false)
					-- 添加注册监听事件
					tab_btn:addTouchEventListener(function(sender, event_type)
						if event_type == ccui.TouchEventType.ended then
							self:changeTabView(sender.index)
						end
					end)
						self.tab_btn_list[info.index] = tab_btn
				else
					tab_btn:setVisible(false)
				end
			end
		end
	end

end
--@ setting 配置文件
--目前配置变量  
--3 形象设置:   setting.id = 对应道具id 
--5 设置背景:   setting.id = 对应道具id 
function RoleDecorateWindow:openRootWnd( index, setting)
	local index = index or 1
    self:changeTabView(index, setting)
end

function RoleDecorateWindow:changeTabView( index, setting)
	if self.cur_index == index then return end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
        self.cur_tab:setBright(false)
    end

    self.cur_index = index
    self.cur_tab = self.tab_btn_list[self.cur_index]

    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.label:enableShadow(cc.c4b(135, 66, 1, 255), cc.size(0, -2),2)
        self.cur_tab:setBright(true)
    end

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end

    self.pre_panel = self:createSubPanel(self.cur_tab.index, setting)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end
end

function RoleDecorateWindow:createSubPanel(index, setting)
    local panel = self.view_list[index]
    if panel == nil then
    	if index ==1 then --头像
            panel = RoleHeadPanel.new()
        elseif index == 2 then --头像框
            panel = RoleFacePanel.new(setting)
        elseif index == 3 then 
            panel = RoleDecorateTabBodyPanel.new(setting)--形象
        elseif index == 4 then
        	panel = RoleTitlePanel.new()--称号     
        elseif index == 5 then
            panel = RoleBackgroundPanel.new(setting)--空间背景
        end
        local size = self.scrollCon:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 ,size.height * 0.5))
        self.scrollCon:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end


function RoleDecorateWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			self.ctrl:openRoleDecorateView(false)
		end
	end)
     if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self.ctrl:openRoleDecorateView(false)
            end
        end)
    end
end

function RoleDecorateWindow:close_callback()
	for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end
	self.ctrl:openRoleDecorateView(false)
end

