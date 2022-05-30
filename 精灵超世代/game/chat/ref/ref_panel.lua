--伙伴状态设置界面
--author:cloud
--date:2017.4.25

RefPanel = RefPanel or BaseClass(BaseView)
function RefPanel:__init(  )
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
	self.layout_name = "mainui/ref_panel"

    self.is_change_lock = false
    self.is_change_main = false
    self.tab_btn_list = {}
    self.tab_panel_list = {}
end

function RefPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setSwallowTouches(false)

    local main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = main_panel:getChildByName("container")

    for i=1,3 do
        local tab_btn = main_panel:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.tab_btn = tab_btn 
            object.normal = tab_btn:getChildByName("normal")
            object.select = tab_btn:getChildByName("select")
            --object.normal_icon = tab_btn:getChildByName("normal_icon")
            --object.select_icon = tab_btn:getChildByName("select_icon")
            object.label  = tab_btn:getChildByName("label") 
            object.index = i
            if i == 1 then
                object.label:setString(TI18N("表情"))
            elseif i == 2 then
                object.label:setString(TI18N("道具"))
            else
                object.label:setString(TI18N("装备"))
            end
            self.tab_btn_list[i] = object
        end
    end
    self.main_panel = main_panel
    self.main_panel:setPositionY(display.getBottom()+168)
end

function RefPanel:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
           RefController:getInstance():closeView()
        end
    end)

    
    for i, object in ipairs(self.tab_btn_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playButtonSound2()
                    self:changeTabView(i)
                end
            end)
        end
    end
end

function RefPanel:openRootWnd(setting, channel)
    self:changeTabView(1)
    -- self.main_panel:setPositionY(display.getBottom()+168+offset_y)
    local setting = setting or {}
    local world_pos = setting.world_pos or cc.p(0, 0)
    local offset_y =  setting.offset_y or 0
    local node_pos = self.root_wnd:convertToNodeSpace(world_pos)
    self.main_panel:setPositionY(node_pos.y + offset_y)

    -- 同省频道只显示表情分页
    if channel and channel == ChatConst.Channel.Province then
        for k,object in pairs(self.tab_btn_list) do
            if k ~= 1 and object.tab_btn then
                object.tab_btn:setVisible(false)
            end
        end
    end
end

function RefPanel:changeTabView(index)
    if self.select_object and self.select_object.index == index then return end
    if self.select_object then
        --self.select_object.normal:setVisible(true)
        self.select_object.select:setVisible(false)
        --self.select_object.normal_icon:setVisible(true)
        --self.select_object.select_icon:setVisible(false)
        
    end
    if self.select_panel then
        self.select_panel:setVisible(false)
    end
    self.select_object = self.tab_btn_list[index]
    if self.select_object then
        --self.select_object.normal:setVisible(false)
        self.select_object.select:setVisible(true)
        --self.select_object.normal_icon:setVisible(false)
        --self.select_object.select_icon:setVisible(true)
    end
    self.select_panel = self:createPanel(index)
    if self.select_panel then
        self.select_panel:setVisible(true)
    end
end

function RefPanel:createPanel(index)
    if self.tab_panel_list[index] then
        return self.tab_panel_list[index]
    end
    local panel = nil
    if index == 1 then
        panel = RefFacesUI.New(self.container)
    elseif index == 2 then
        panel = RefItemUI.New(self.container)
    else
        panel = RefEquipUI.New(self.container)
    end
    if panel then
        self.tab_panel_list[index] = panel
    end
    return panel
end

-- 移除数据
function RefPanel:close_callback()
    for i,v in ipairs(self.tab_panel_list) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.tab_panel_list = nil

    RefController:getInstance():closeView() 
end
