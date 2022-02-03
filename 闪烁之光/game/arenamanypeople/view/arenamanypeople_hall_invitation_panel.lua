-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队要求
-- <br/> 2020年3月23日
-- --------------------------------------------------------------------
ArenaManyPeopleHallInvitationPanel = class("ArenaManyPeopleHallInvitationPanel", function()
    return ccui.Widget:create()
end)

local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()

local table_sort = table.sort
local string_format = string.format

function ArenaManyPeopleHallInvitationPanel:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ArenaManyPeopleHallInvitationPanel:setVisibleStatus(bool)
    if not self.parent then return end
    self.visible_status = bool or false 
    self:setVisible(bool)

    if bool then
        controller:sender29003()
    end
end

function ArenaManyPeopleHallInvitationPanel:config()

end

function ArenaManyPeopleHallInvitationPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_hall_invitation_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")

    self.key_btn = self.container:getChildByName("key_btn")
    self.key_btn:getChildByName("label"):setString(TI18N("全部拒绝"))

    --列表
    self.lay_srollview = self.container:getChildByName("lay_srollview")
end

--事件
function ArenaManyPeopleHallInvitationPanel:registerEvents()
    registerButtonEventListener(self.key_btn, function() self:onKeyBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil, nil, 1)


    if self.arenateam_invitation_list_event == nil then
        self.arenateam_invitation_list_event = GlobalEvent:getInstance():Bind(ArenaManyPeopleEvent.ARENAMANYPOEPLE_INVITATION_LIST_EVENT,function (data)
            if not data then return end
            self.is_init = true
            self:setData(data)
        end)
    end
    if self.arenateam_key_clear_event == nil then
        self.arenateam_key_clear_event = GlobalEvent:getInstance():Bind(ArenaManyPeopleEvent.ARENAMANYPOEPLE_KEY_CLEAR_EVENT,function (data)
            self.show_list = {}
            self:updateTeamlist()
        end)
    end
end

--一键清除
function ArenaManyPeopleHallInvitationPanel:onKeyBtn()
    controller:sender29005()
end


function ArenaManyPeopleHallInvitationPanel:setData(scdata)
    if not scdata then return end
    self.scdata = scdata
    self.show_list = scdata.team_members
    table_sort(self.show_list, function(a, b) return a.power > b.power end)
    self:updateTeamlist()   
end

--列表
function ArenaManyPeopleHallInvitationPanel:updateTeamlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 5,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 135,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    self.scrollview_list:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("暂无邀请信息")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaManyPeopleHallInvitationPanel:createNewCell(width, height)
    local cell = ArenaManyPeopleHallInvitationItem.new(width, height)
    return cell
end

--获取数据数量
function ArenaManyPeopleHallInvitationPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaManyPeopleHallInvitationPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end


--移除
function ArenaManyPeopleHallInvitationPanel:DeleteMe()
    if self.arenateam_invitation_list_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_invitation_list_event)
        self.arenateam_invitation_list_event = nil
    end
    if self.arenateam_key_clear_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_key_clear_event)
        self.arenateam_key_clear_event = nil
    end

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
        self.scrollview_list = nil
    end
end


-- 子项amp_hall_invitation_item
ArenaManyPeopleHallInvitationItem = class("ArenaManyPeopleHallInvitationItem", function()
    return ccui.Widget:create()
end)

function ArenaManyPeopleHallInvitationItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ArenaManyPeopleHallInvitationItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_hall_invitation_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.team_name = self.main_container:getChildByName("team_name")
    self.power = self.main_container:getChildByName("power")

    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setHeadLayerScale(0.9)
    self.head_icon:setPosition(153 , 67.5)
    self.main_container:addChild(self.head_icon)
    self.head_icon:addCallBack(function() self:onClickHead() end )
    self.power_bg = self.main_container:getChildByName("Image_1")
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("同 意"))
    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("拒 绝"))

    self.limit_level_title = self.main_container:getChildByName("limit_level_title")
    self.limit_level_title:setString(TI18N("排名"))

    self.limit_rank = self.main_container:getChildByName("limit_level")
    self.limit_rank:setString(TI18N("无"))
    self.limit_score = self.main_container:getChildByName("limit_power")
    self.limit_score:setString(TI18N("无"))
end

function ArenaManyPeopleHallInvitationItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onArgeeBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.cancel_btn, function() self:onCancelBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    
end

function ArenaManyPeopleHallInvitationItem:onClickHead()
    if not self.data then return end
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo and self.data.rid == roleVo.rid and self.data.sid == roleVo.srv_id then 
        message(TI18N("这是你自己~"))
        return
    end
    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.sid, rid = self.data.rid})
end
--确定
function ArenaManyPeopleHallInvitationItem:onArgeeBtn()
    if not self.data then return end
    controller:sender29004(self.data.rid, self.data.sid, 1)
end

--取消
function ArenaManyPeopleHallInvitationItem:onCancelBtn()
    if not self.data then return end
    controller:sender29004(self.data.rid, self.data.sid, 0)
end


function ArenaManyPeopleHallInvitationItem:setData(data)
    if not data then return end
    self.data = data
    self.team_name:setString(self.data.name)
    self.power:setString(tostring(self.data.power))
    local width = self.power:getContentSize().width + 55
    local height = self.power_bg:getContentSize().height
    self.power_bg:setContentSize(cc.size(width,height))
    
    if data.rank > 0 then
        self.limit_rank:setString(tostring(self.data.rank)) 
    else
        self.limit_rank:setString(TI18N("未上榜")) 
    end

    self.limit_score:setString(string_format(TI18N("积分：%d"),self.data.score))


    if self.head_icon then
        self.head_icon:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.head_icon:setLev(data.lev)
        self.head_icon:addDesc(false)

        local avatar_bid = data.avatar_bid
        if self.head_icon.record_res_bid == nil or self.head_icon.record_res_bid ~= avatar_bid then
            self.head_icon.record_res_bid = avatar_bid
            local vo = Config.AvatarData.data_avatar[avatar_bid]
            --背景框
            if vo then
                local res_id = vo.res_id or 1
                local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                self.head_icon:showBg(res, nil, false, vo.offy)
            else
                local bgRes = PathTool.getResFrame("common","common_1031")
                self.head_icon:showBg(bgRes, nil, true)
            end
        end
    end
end

function ArenaManyPeopleHallInvitationItem:DeleteMe()
    if self.head_icon then
        self.head_icon:DeleteMe()
        self.head_icon = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

