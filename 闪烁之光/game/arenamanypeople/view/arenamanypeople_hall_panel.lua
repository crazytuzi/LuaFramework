--------------------------------------------
-- @Author  : xhj
-- @Date    : 2020年3月23日
-- @description    : 
        -- 组队大厅
---------------------------------
ArenaManyPeopleHallPanel = ArenaManyPeopleHallPanel or BaseClass(BaseView)

local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()


function ArenaManyPeopleHallPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("arenateam_hall", "arenateam_hall"), type = ResourcesType.plist}
    }
    self.layout_name = "arenamanypeople/amp_hall_panel"

    self.view_list = {}
end

function ArenaManyPeopleHallPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    -- 通用进场动效
    ActionHelp.itemUpAction(self.main_container, 720, 0, 0.25)

    self.container = self.main_container:getChildByName("container")
    
    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("组队大厅"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.tab_container = self.main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("组 队"),
        [2] = TI18N("邀请信息"),
    }
    self.tab_item_type = {
        [1] = ArenaManyPeopleConst.TeamHallTabType.eTeam,
        [2] = ArenaManyPeopleConst.TeamHallTabType.eInvitation,
    }
    self.tab_list = {}
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = self.tab_item_type[i] or ArenaManyPeopleConst.TeamHallTabType.eTeam
            self.tab_list[i] = object
        end
    end
end

function ArenaManyPeopleHallPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    

    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

end

--关闭
function ArenaManyPeopleHallPanel:onClosedBtn()
    controller:openArenaManyPeopleHallPanel(false)
end

-- 切换标签页
function ArenaManyPeopleHallPanel:changeSelectedTab( index )
    if self.tab_object and self.tab_object.index == index then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object = nil
    end
    self.cur_tab_index = index
    self.tab_object = self.tab_list[index]

    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end
    if self.pre_panel then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        else
            self.pre_panel:setVisible(false)
        end
    end

    self.pre_panel = self:createSubPanel(self.cur_tab_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        else
            self.pre_panel:setVisible(true)
        end
    end

   
end

function ArenaManyPeopleHallPanel:createSubPanel(index)
    if not self.view_list then return end

    local panel = self.view_list[index]
    if panel == nil then
        if index == ArenaManyPeopleConst.TeamHallTabType.eTeam then --组队
            panel = ArenaManyPeopleHallTeamPanel.new(self) 
        elseif index == ArenaManyPeopleConst.TeamHallTabType.eInvitation then --收到邀请
            panel = ArenaManyPeopleHallInvitationPanel.new(self)
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

--setting.tab_type = ArenaManyPeopleConst.TeamHallTabType
function ArenaManyPeopleHallPanel:openRootWnd(setting)
    if not self.tab_item_type then return end
    local setting = setting or {}
    local index = setting.index or ArenaManyPeopleConst.TeamHallTabType.eTeam
    self:changeSelectedTab(index)
end


function ArenaManyPeopleHallPanel:close_callback()
    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil
    controller:openArenaManyPeopleHallPanel(false)
end