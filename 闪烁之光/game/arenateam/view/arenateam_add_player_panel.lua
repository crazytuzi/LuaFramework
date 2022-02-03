--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年10月12日
-- @description    : 
        -- 添加队员
---------------------------------
ArenateamAddPlayerPanel = ArenateamAddPlayerPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function ArenateamAddPlayerPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenateam_hall", "arenateam_hall"), type = ResourcesType.plist}
    }
    self.layout_name = "arenateam/arenateam_add_player_panel"

    self.view_list = {}

    --是否显示推荐列表 false表示显示玩家搜索列表
    self.is_show_recommend = true

    --标识玩家已邀请
    self.dic_invitation_player = {}
end

function ArenateamAddPlayerPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("添加玩家"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.tab_container = self.main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("申请列表"),
        [2] = TI18N("邀请玩家")
    }

    self.tab_item_type = {
        [1] = ArenateamConst.AddPlayerTabType.eApplyList,
        [2] = ArenateamConst.AddPlayerTabType.eInvitation
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
            object.index = self.tab_item_type[i] or ArenateamConst.AddPlayerTabType.eApplyList
            self.tab_list[i] = object
        end
    end
    local apply_panel = self.main_container:getChildByName("apply_panel")
    local invitation_panel = self.main_container:getChildByName("invitation_panel")
    apply_panel:setVisible(false)
    invitation_panel:setVisible(false)
    self.view_list = {}
    self.view_list[ArenateamConst.AddPlayerTabType.eApplyList] = apply_panel
    self.view_list[ArenateamConst.AddPlayerTabType.eInvitation] = invitation_panel


    self.apply_lay_srollview = apply_panel:getChildByName("lay_srollview")

    self.default_msg = TI18N("请输入玩家名字")
    local size = cc.size(448,52)
    local res = PathTool.getResFrame("common", "common_1021")
    self.edit_box =  createEditBox(invitation_panel, res,size, nil, 24, Config.ColorData.data_color3[151], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
    self.edit_box:setAnchorPoint(cc.p(0,0))
    self.edit_box:setPlaceholderFontColor(Config.ColorData.data_color4[151])
    self.edit_box:setFontColor(Config.ColorData.data_color4[66])
    self.edit_box:setPosition(cc.p(20,820))
    -- self.edit_box:setMaxLength(14)
    -- local function editBoxTextEventHandle(strEventName,pSender)
    --     if strEventName == "return" then
    --         local str = pSender:getText()
    --         if GmCmd and GmCmd.show_from_chat and GmCmd:show_from_chat(str) then return end
    --     end
    -- end
    -- if not tolua.isnull(self.edit_box) then
    --     self.edit_box:registerScriptEditBoxHandler(editBoxTextEventHandle)
    -- end

    self.find_btn = invitation_panel:getChildByName("find_btn")
    self.find_btn:getChildByName("label"):setString(TI18N("查 找"))
    self.refresh_btn = invitation_panel:getChildByName("refresh_btn")
    self.refresh_btn:getChildByName("label"):setString(TI18N("刷 新"))

    self.invitation_lay_srollview = invitation_panel:getChildByName("lay_srollview")
end

function ArenateamAddPlayerPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)

    registerButtonEventListener(self.find_btn, function() self:onFindBtn()  end ,true, 1)
    registerButtonEventListener(self.refresh_btn, function() self:onRefreshBtn()  end ,true, 1, nil, nil, 1.5)


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

    --获取申请列表
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_APPLY_LIST_EVENT, function(data)
        if not data then return end
        self.apply_show_list = data.arena_team_member
        if self.cur_tab_index == ArenateamConst.AddPlayerTabType.eApplyList then
            self:initApply()
        end
    end)

    --获取推荐玩家
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_GET_RECOMMEND_INFO_EVENT, function(data)
        if not data then return end
        self.dic_invitation_player = {}
        self.invitation_recommend_list = data.arena_team_member
        self.is_show_recommend = true
        -- if self.cur_tab_index == ArenateamConst.AddPlayerTabType.eInvitation then
            self:initInvitation()
        -- end
    end)

    --搜索玩家
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_SEARCH_PLAYER_EVENT, function(data)
        if not data then return end
        self.dic_invitation_player = {}
        self.invitation_search_list = data.arena_team_member
        self.is_show_recommend = false
        -- if self.cur_tab_index == ArenateamConst.AddPlayerTabType.eInvitation then
            self:initInvitation()
        -- end
    end)
    
    --邀请某个玩家返回
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_INVITATION_PLAYER_EVENT, function(data)
        if not data then return end
        local key = data.rid.."_"..data.srv_id
        self.dic_invitation_player[key] = true
        if self.invitation_scrollview_list then
            self.invitation_scrollview_list:resetCurrentItems()
        end
    end)


    --玩家申请列表操作返回
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_ANSWER_APPLY_EVENT, function(data)
        if not data then return end
        if not self.apply_show_list then return end

        for i,v in ipairs(self.apply_show_list) do
            if v.rid == data.rid and v.sid == data.srv_id then
                table.remove(self.apply_show_list, i)
                break
            end
        end
        if #self.apply_show_list == 0 then
            model:setIsApplayRedpoint(false)
            self:updateRedPoint(false)
        end
        self:updateApplyList()
    end)

      -- 组队竞技场红点变化事件
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_APPLY_RED_POINT_EVENT, function (  )
        if self.cur_tab_index and self.cur_tab_index == ArenateamConst.AddPlayerTabType.eApplyList then
        else
            --没有标一下红点
            self:updateRedPoint(true)
        end
        controller:sender27203()
    end)
end

function ArenateamAddPlayerPanel:updateRedPoint(status)
    if not self.tab_list then return end
    if self.tab_list[1] and self.tab_list[1].tab_btn then
        local tab_btn = self.tab_list[1].tab_btn
        addRedPointToNodeByStatus(tab_btn, status, 5, 5) 
    end
end

--关闭
function ArenateamAddPlayerPanel:onClosedBtn()
    controller:openArenateamAddPlayerPanel(false)
end

--查找
function ArenateamAddPlayerPanel:onFindBtn()
    local name = self.edit_box:getText() or ""
    if name == "" then
        message(TI18N("玩家名字不能为空"))
        return
    end
    controller:sender27229(name)
end

--刷新
function ArenateamAddPlayerPanel:onRefreshBtn()
    controller:sender27228()
end

-- 切换标签页
function ArenateamAddPlayerPanel:changeSelectedTab( index )
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
        self.pre_panel:setVisible(false)
    end

    self.pre_panel = self.view_list[index]
    if self.pre_panel ~= nil then
        self.pre_panel:setVisible(true)
    end
    if index == ArenateamConst.AddPlayerTabType.eApplyList then
        self:initApply()
        -- self:updateRedPoint(false)
        -- model:setIsApplayRedpoint(false)
    elseif index == ArenateamConst.AddPlayerTabType.eInvitation then
        self:initInvitation()
    end
end

--setting.tab_type = ArenateamConst.AddPlayerTabType
function ArenateamAddPlayerPanel:openRootWnd(setting)
    if not self.tab_item_type then return end
    local setting = setting or {}
    local index = setting.index or ArenateamConst.AddPlayerTabType.eApplyList
    --是否队长
    self.is_team_leader = setting.is_team_leader or false
    self:changeSelectedTab(index)
    controller:sender27203()
    controller:sender27228()
end

function ArenateamAddPlayerPanel:initApply()
    --没有数据返不处理
    if not self.apply_show_list then return end

    -- local sort_func = SortTools.tableUpperSorter({"score", "win_acc"})
    table_sort(self.apply_show_list, function(a, b) return a.power > b.power end)
    self:updateApplyList()
end
--列表
function ArenateamAddPlayerPanel:updateApplyList()
    if not self.apply_show_list then return end
    if self.apply_scrollview_list == nil then
        local scrollview_size = self.apply_lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 210,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.apply_scrollview_list = CommonScrollViewSingleLayout.new(self.apply_lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.apply_scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.apply_scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.apply_scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    self.apply_scrollview_list:reloadData()
    if #self.apply_show_list == 0 then
        commonShowEmptyIcon(self.apply_lay_srollview, {text = TI18N("暂无队伍信息")})
    else
        commonShowEmptyIcon(self.apply_lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamAddPlayerPanel:createNewCell(width, height)
    local cell = ArenateamAddPlayerItem.new(width, height, self, ArenateamConst.AddPlayerTabType.eApplyList)
    return cell
end

--获取数据数量
function ArenateamAddPlayerPanel:numberOfCells()
    if not self.apply_show_list then return 0 end
    return #self.apply_show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamAddPlayerPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.apply_show_list[index]
    if not data then return end
    cell:setData(data)
end



function ArenateamAddPlayerPanel:initInvitation()
    --已经初始化 不做处理了
    if self.is_show_recommend then
        self.invitation_show_list = self.invitation_recommend_list
    else
        self.invitation_show_list = self.invitation_search_list
    end
    if not self.invitation_show_list then return end
    table_sort(self.invitation_show_list, function(a, b) return a.power > b.power end)
    self:updateInvitationList()
end

--列表
function ArenateamAddPlayerPanel:updateInvitationList()
    if not self.invitation_show_list then return end
    if self.invitation_scrollview_list == nil then
        local scrollview_size = self.invitation_lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 210,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.invitation_scrollview_list = CommonScrollViewSingleLayout.new(self.invitation_lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.invitation_scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCellInvitation), ScrollViewFuncType.CreateNewCell) --创建cell
        self.invitation_scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCellsInvitation), ScrollViewFuncType.NumberOfCells) --获取数量
        self.invitation_scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndexInvitation), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    self.invitation_scrollview_list:reloadData()

    if #self.invitation_show_list == 0 then
        commonShowEmptyIcon(self.invitation_lay_srollview, {text = TI18N("暂无队伍信息")})
    else
        commonShowEmptyIcon(self.invitation_lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamAddPlayerPanel:createNewCellInvitation(width, height)
    local cell = ArenateamAddPlayerItem.new(width, height, self, ArenateamConst.AddPlayerTabType.eInvitation)
    return cell
end

--获取数据数量
function ArenateamAddPlayerPanel:numberOfCellsInvitation()
    if not self.invitation_show_list then return 0 end
    return #self.invitation_show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamAddPlayerPanel:updateCellByIndexInvitation(cell, index)
    cell.index = index
    local data = self.invitation_show_list[index]
    if not data then return end
    cell:setData(data)

    local key = data.rid.."_"..data.sid
    local is_invitation = self.dic_invitation_player[key] or false
    cell:setInvitationLabel(is_invitation)
end

function ArenateamAddPlayerPanel:close_callback()

    if self.apply_scrollview_list then
        self.apply_scrollview_list:DeleteMe()
        self.apply_scrollview_list = nil
    end
    if self.invitation_scrollview_list then
        self.invitation_scrollview_list:DeleteMe()
        self.invitation_scrollview_list = nil
    end

    controller:openArenateamAddPlayerPanel(false)
end



-- 子项arenateam_hall_tap_self.main_container
ArenateamAddPlayerItem = class("ArenateamAddPlayerItem", function()
    return ccui.Widget:create()
end)

function ArenateamAddPlayerItem:ctor(width, height, parent, show_type)
    self.show_type = show_type or ArenateamConst.AddPlayerTabType.eApplyList
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenateamAddPlayerItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_add_player_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    local size = self.main_container:getContentSize()
    self.player_name = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(132,177),nil,nil,800)
    self.main_container:addChild(self.player_name)
    self.power =  self.main_container:getChildByName("power")
    --头像
    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setHeadLayerScale(0.8)
    self.head:setPosition(56 , 160)
    self.head:setLev(99)
    self.main_container:addChild(self.head)

    --英雄
    self.hero_item_list = {}
    local item_width = HeroExhibitionItem.Width * 0.8 + 10
    local x = size.width * 0.5 -item_width * 5 * 0.5 + item_width * 0.5
    local y = 58
    for j=1,5 do
        self.hero_item_list[j] = HeroExhibitionItem.new(0.8, true)
        self.hero_item_list[j]:setSwallowTouches(false)
        self.hero_item_list[j]:setPosition(x + (j - 1) * item_width, y)
        self.hero_item_list[j]:addCallBack(function() self:onClickHeroItemByIndex(j) end)
        -- self.hero_item_list[i]:setBgOpacity(128)
        self.main_container:addChild(self.hero_item_list[j])
    end

    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("拒 绝"))
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("同 意"))
    self.invitation_btn = self.main_container:getChildByName("invitation_btn")
    self.invitation_btn_label = self.invitation_btn:getChildByName("label")
    self.invitation_btn_label:setString(TI18N("邀 请"))

    if self.show_type == ArenateamConst.AddPlayerTabType.eApplyList then
        self.cancel_btn:setVisible(true)
        self.comfirm_btn:setVisible(true)
        self.invitation_btn:setVisible(false)
    elseif self.show_type == ArenateamConst.AddPlayerTabType.eInvitation then
        self.cancel_btn:setVisible(false)
        self.comfirm_btn:setVisible(false)
        self.invitation_btn:setVisible(true)
    end
end

function ArenateamAddPlayerItem:register_event( )
    registerButtonEventListener(self.cancel_btn, function() self:onCancelBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil,nil,1)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil,nil,1)
    registerButtonEventListener(self.invitation_btn, function() self:onInvitationBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil,nil,1)
end

--英雄
function ArenateamAddPlayerItem:onClickHeroItemByIndex(i)
    
end

--拒绝
function ArenateamAddPlayerItem:onCancelBtn()
    if not self.parent then return end
    if self.parent.is_team_leader then
        controller:sender27204(self.data.rid, self.data.sid, 0)
    else
        message(TI18N("只有队长可进行该操作"))
    end
end

--同意
function ArenateamAddPlayerItem:onComfirmBtn()
    if not self.parent then return end
    if self.parent.is_team_leader then
        controller:sender27204(self.data.rid, self.data.sid, 1)
    else
        message(TI18N("只有队长可进行该操作"))
    end
end

--邀请
function ArenateamAddPlayerItem:onInvitationBtn()
    if not self.parent then return end
    if not self.data then return end
    if self.parent.is_team_leader then
        controller:sender27205(self.data.rid, self.data.sid)
    else
        message(TI18N("只有队长可进行该操作"))
    end
end


function ArenateamAddPlayerItem:setData(data)
    if not data then return end
    self.data = data
    self.player_name:setString(self.data.name)
    self.power:setString(self.data.power)
    --头像

    self.head:setHeadRes(self.data.face_id, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
    self.head:setLev(self.data.lev)
    local avatar_bid = self.data.avatar_bid
    if self.record_res_bid == nil or self.record_res_bid ~= avatar_bid then
        self.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.head:showBg(res, nil, false, vo.offy)
        end
    end

    --英雄
    table_sort(self.data.team_partner, function(a, b) return a.pos < b.pos end)
    for i,hero_item in ipairs(self.hero_item_list) do
        local hero_vo = self.data.team_partner[i]
        if hero_vo then
            hero_vo.use_skin = hero_vo.skin_id
            hero_item:setData(hero_vo)    
        else
            hero_item:setData(nil)
        end
        
    end
end

function ArenateamAddPlayerItem:setInvitationLabel(is_invitation)
    if is_invitation then
        self.invitation_btn_label:setString(TI18N("已邀请"))
        setChildUnEnabled(true, self.invitation_btn)
        self.invitation_btn:setTouchEnabled(false)
    else
        self.invitation_btn_label:setString(TI18N("邀 请"))
        setChildUnEnabled(false, self.invitation_btn)
        self.invitation_btn:setTouchEnabled(true)
    end
    
end

function ArenateamAddPlayerItem:DeleteMe()
    if self.head_list then
        for i,item in ipairs(self.head_list) do
            item:DeleteMe()
        end
        self.head_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end
