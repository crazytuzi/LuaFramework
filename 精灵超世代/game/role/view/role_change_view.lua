-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      角色信息面板改名改性别面板
-- <br/>Create: 2017-09-21
-- --------------------------------------------------------------------
RoleChangeView = RoleChangeView or BaseClass(BaseView)

function RoleChangeView:__init(ctrl)
	self.ctrl = ctrl
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "roleinfo/role_change_view"
    self.role_vo = self.ctrl:getRoleVo()
    self.sex_select = self.role_vo.sex
    self.btn_list = {}
end

function RoleChangeView:open(index)
    BaseView.open(self)
end

function RoleChangeView:open_callback()
	self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2)

    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

	self.close_btn = self.main_panel:getChildByName("close_btn")
    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn.label = self.ok_btn:getTitleRenderer()
    if self.ok_btn.label ~= nil then
        self.ok_btn.label:setString(TI18N("确定"))
        self.ok_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn.label = self.cancel_btn:getTitleRenderer()
    if self.cancel_btn.label ~= nil then
        self.cancel_btn.label:setString(TI18N("取消"))
        self.cancel_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    

    self.title_container = self.main_panel:getChildByName("title_container")
    local title_label = self.title_container:getChildByName("title_label")
    title_label:setString(TI18N("更改信息"))

	self.main_container = self.main_panel:getChildByName("main_container")
    local free_tips = self.main_container:getChildByName("free_tips")
    free_tips:setString(TI18N("本次免费"))
    local name = self.main_container:getChildByName("name")
    name:setString(TI18N("名字："))

    self.sex_container = self.main_container:getChildByName("sex_container")
    local sex_name = self.sex_container:getChildByName("sex_name")
    sex_name:setString(TI18N("性别："))
    local sex_tips = self.sex_container:getChildByName("sex_tips")
    sex_tips:setString(TI18N("性别选择后不能变更哦~"))
    self.boy_btn = self.sex_container:getChildByName("boy_btn")
    self.boy_btn:setSelected(false)
    self.girl_btn = self.sex_container:getChildByName("girl_btn")
    self.girl_btn:setSelected(false)
    -- self.btn_1 = self.sex_container:getChildByName("btn_1")
    -- self.btn_1_select = self.btn_1:getChildByName("select")
    -- self.btn_1_select:setVisible(self.sex_select==1)
    -- self.btn_0 = self.sex_container:getChildByName("btn_0")
    -- self.btn_0_select = self.btn_0:getChildByName("select")
    -- self.btn_0_select:setVisible(self.sex_select==0)
    -- if self.sex_select == 1 then
    --     setChildUnEnabled(false,self.btn_1)
    --     setChildUnEnabled(true,self.btn_0) 
    -- elseif self.sex_select == 0 then
    --     setChildUnEnabled(true,self.btn_1)
    --     setChildUnEnabled(false,self.btn_0) 
    -- end

    -- self.tips = createRichLabel(24,Config.ColorData.data_color3[64],cc.p(0.5,0.5),cc.p(self.main_container:getContentSize().width/2,22)) --self.main_container:getChildByName("tips")
    -- self.main_container:addChild(self.tips)
    -- local msg = self.ctrl:getString("rename_desc")
    -- print("=================cur_sex",self.role_vo.sex)
    -- if self.role_vo.sex == 2  and self.role_vo.is_first_rename == TRUE then
    --     msg = self.ctrl:getString("free_rename_desc")
    -- end
    -- self.tips:setString(msg)

    local str = ""
    if self.role_vo.is_first_rename == TRUE then
        str = TI18N("请输入名字(限制6字)")
    else
        str = self.role_vo.name
    end
	self:createInputContainer(str)


	self:register_event()
end

function RoleChangeView:createInputContainer(placeholder,max_len, desc, off_y, touch_enabled)
    if self.input_edit == nil then
        self.input_edit = createEditBox(self.main_container, PathTool.getResFrame("common", "common_1021"), cc.size(250, 50), Config.ColorData.data_color3[151], 24, Config.ColorData.data_color3[151], 24, placeholder, nil, max_len, LOADTEXT_TYPE_PLIST)
    end
    self.input_edit:setAnchorPoint(cc.p(0.5, 0.5))
    off_y = off_y or 0
    if desc ~= nil then
        self.input_edit:setText(desc)
    end
    self.input_edit:setPosition(297,125)
end

function RoleChangeView:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openRoleChangeNameView(false)
        end
    end)

    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:openRoleChangeNameView(false)
        end
    end)
    if self.background then
        self.background:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    self.ctrl:openRoleChangeNameView(false)
                end
            end
        )
    end

    self.ok_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.sex_select ~= 2 and self.input_edit:getText()~="" then
                local text = string.gsub(self.input_edit:getText(), "\n", "")
                self.ctrl:changeRoleName(text,self.sex_select)
            elseif self.input_edit:getText()=="" then
                message(TI18N("请输入姓名~"))
            elseif self.sex_select == 2 then
                message(TI18N("请选择性别~"))
            end
        end
    end)

    self.boy_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            if self.girl_btn:getSelectedState() then
                self.girl_btn:setSelected(false)
            end
            self.sex_select = 1
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            
        end
    end)

    self.girl_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            if self.boy_btn:getSelectedState() then
                self.boy_btn:setSelected(false)
            end
            self.sex_select = 0
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            
        end
    end)

    -- self.btn_1:addTouchEventListener(function(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         self.sex_select = 1
    --         if self.btn_0_select:isVisible() then
    --             self.btn_0_select:setVisible(false)
    --         end
    --         self.btn_1_select:setVisible(true)
    --         setChildUnEnabled(false,self.btn_1)
    --         setChildUnEnabled(true,self.btn_0)
    --     end
    -- end)

    -- self.btn_0:addTouchEventListener(function(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         self.sex_select = 0
    --         if self.btn_1_select:isVisible() then
    --             self.btn_1_select:setVisible(false)
    --         end
    --         self.btn_0_select:setVisible(true)
    --         setChildUnEnabled(false,self.btn_0)
    --         setChildUnEnabled(true,self.btn_1)
    --     end
    -- end)

    -- if self.role_vo ~= nil then
    --     if self.role_update_event == nil then
    --         self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
    --             print("=======key====value",key,value)
    --             if key == "sex"  then
    --                 local msg = self.ctrl:getString("rename_desc")
    --                 if self.role_vo.sex == 2  and self.role_vo.is_first_rename == TRUE then
    --                     msg = self.ctrl:getString("free_rename_desc")
    --                 end
    --                 --self.tips:setString(msg)
    --             end
    --         end)
    --     end
    -- end

end

function RoleChangeView:close_callback()
    -- if self.role_vo ~= nil then
    --     if self.role_update_event ~= nil then
    --         self.role_vo:UnBind(self.role_update_event)
    --         self.role_update_event = nil
    --     end
    --     self.role_vo = nil
    -- end

	self.ctrl:openRoleChangeNameView(false)
end