--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年10月9日
-- @description    : 
        -- 组队大厅
---------------------------------
ArenateamHallPanel = ArenateamHallPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function ArenateamHallPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenateam_hall", "arenateam_hall"), type = ResourcesType.plist}
    }
    self.layout_name = "arenateam/arenateam_hall_panel"

    self.view_list = {}
end

function ArenateamHallPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("组队大厅"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.tab_container = self.main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("组 队"),
        [2] = TI18N("收到邀请"),
        [3] = TI18N("我的队伍"),
    }
    self.tab_item_type = {
        [1] = ArenateamConst.TeamHallTabType.eTeam,
        [2] = ArenateamConst.TeamHallTabType.eInvitation,
        [3] = ArenateamConst.TeamHallTabType.eMyTeam,
    }
    self.tab_list = {}
    for i=1,3 do
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
            object.index = self.tab_item_type[i] or ArenateamConst.TeamHallTabType.eTeam
            self.tab_list[i] = object
        end
    end
end

function ArenateamHallPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)


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

    -- 组队竞技场申请列表的
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_ALL_RED_POINT_EVENT, function (  )
        self:updateRedPoint()
    end)
    
    -- 组队竞技场申请列表的
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_APPLY_RED_POINT_EVENT, function (  )
        self:updateRedPoint()
    end)

    -- 组队竞技场邀请列表的
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_INVITATION_RED_POINT_EVENT, function (  )
        if self.cur_tab_index and self.cur_tab_index == ArenateamConst.TeamHallTabType.eInvitation then
            --就在本界面..红点不用 .协议刷新本界面信息
            model.is_invitation_red = false
            controller:sender27206()
        else
            self:updateRedPoint()
        end
    end)
end

--关闭
function ArenateamHallPanel:onClosedBtn()
    controller:openArenateamHallPanel(false)
end

-- 切换标签页
function ArenateamHallPanel:changeSelectedTab( index )
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

    if self.cur_tab_index == ArenateamConst.TeamHallTabType.eInvitation then
        --消除红点
        model:setIsInvitationRedpoint(false)
    end
end

function ArenateamHallPanel:createSubPanel(index)
    if not self.view_list then return end

    local panel = self.view_list[index]
    if panel == nil then
        if index == ArenateamConst.TeamHallTabType.eTeam then --组队
            panel = ArenateamHallTapTeamPanel.new(self) 
        elseif index == ArenateamConst.TeamHallTabType.eInvitation then --收到邀请
            panel = ArenateamHallTapInvitationPanel.new(self)
        elseif index == ArenateamConst.TeamHallTabType.eMyTeam then --我的队伍
            panel = ArenateamHallTapMyTeamPanel.new(self)
        end
        local size = self.main_container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.main_container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

--setting.tab_type = ArenateamConst.TeamHallTabType
function ArenateamHallPanel:openRootWnd(setting)
    if not self.tab_item_type then return end
    local setting = setting or {}
    local index = setting.index or ArenateamConst.TeamHallTabType.eTeam
    self:updateRedPoint()
    self:changeSelectedTab(index)
end

function ArenateamHallPanel:updateRedPoint()
    if not self.tab_list then return end
    if self.tab_list[2] and self.tab_list[2].tab_btn then
        local tab_btn = self.tab_list[2].tab_btn
        if model.is_invitation_red then
            addRedPointToNodeByStatus(tab_btn, true, 5, 5)
        else
            addRedPointToNodeByStatus(tab_btn, false, 5, 5)
        end
    end

    if self.tab_list[3] and self.tab_list[3].tab_btn then
        local tab_btn = self.tab_list[3].tab_btn
        if model.is_apply_red then
            addRedPointToNodeByStatus(tab_btn, true, 5, 5)
        else
            addRedPointToNodeByStatus(tab_btn, false, 5, 5)
        end
    end
end

function ArenateamHallPanel:close_callback()
    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil
    controller:openArenateamHallPanel(false)
end