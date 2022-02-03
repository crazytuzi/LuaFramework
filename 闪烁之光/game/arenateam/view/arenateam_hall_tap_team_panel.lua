-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队
-- <br/> 2019年10月11日
-- --------------------------------------------------------------------
ArenateamHallTapTeamPanel = class("ArenateamHallTapTeamPanel", function()
    return ccui.Widget:create()
end)

local controller = ArenateamController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_floor = math.floor

local role_vo = RoleController:getInstance():getRoleVo()

function ArenateamHallTapTeamPanel:ctor(parent)
    self.parent = parent

    self:config()
    self:layoutUI()
    self:registerEvents()
    
end

function ArenateamHallTapTeamPanel:setVisibleStatus(bool)
    if not self.parent then return end
    self.visible_status = bool or false 
    self:setVisible(bool)
    
    -- self:setData()
    if bool == true then
        self.dic_team_id = {}
        controller:sender27200()
    end
end

function ArenateamHallTapTeamPanel:config()

    --根据self.dic_team_id[srv_id.."_"..tid] = data
    self.dic_team_id = {}

    --已申请的id信息 self.dic_apply_team_id[srv_id.."_"..tid] = true
    self.dic_apply_team_id = {}

    self.default_msg = TI18N("请输入需要搜索的队伍名字")

    --是否一定要刷新
    self.is_must_new = true
end

function ArenateamHallTapTeamPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_hall_tap_team_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")

    --  -- 标题
    -- local res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_honor_wall_bg", false)
    -- if self.record_title_img_res == nil or self.record_title_img_res ~= res then
    --     self.record_title_img_res = res
    --     self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load_title_img_res) 
    -- end 

    self.recommend_label = self.container:getChildByName("recommend_label")
    self.recommend_label:setString(TI18N("推荐队伍"))


    --分享按钮
    self.find_btn = self.container:getChildByName("find_btn")
    self.find_btn:getChildByName("label"):setString(TI18N("查 找"))
    self.require_btn = self.container:getChildByName("require_btn")
    self.require_btn:getChildByName("label"):setString(TI18N("一键申请"))
    self.create_btn = self.container:getChildByName("create_btn")
    self.create_btn:getChildByName("label"):setString(TI18N("创建队伍"))
    self.refresh_btn = self.container:getChildByName("refresh_btn")
    self.refresh_btn:getChildByName("label"):setString(TI18N("刷 新"))

    --列表
    self.lay_srollview = self.container:getChildByName("lay_srollview")

    local size = cc.size(448,52)
    local res = PathTool.getResFrame("common", "common_1021")
    self.edit_box =  createEditBox(self.container, res,size, nil, 24, Config.ColorData.data_color3[151], 20, self.default_msg, nil, nil, LOADTEXT_TYPE_PLIST, nil, nil--[[, cc.KEYBOARD_RETURNTYPE_SEND]])
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
end

--事件
function ArenateamHallTapTeamPanel:registerEvents()
    registerButtonEventListener(self.find_btn, function() self:onFindBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.require_btn, function() self:onRequireBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.create_btn, function() self:onCreateBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.refresh_btn, function() self:onRefreshBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY,nil,nil, 1)



    if self.arenateam_hall_mian_event == nil then
        self.arenateam_hall_mian_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_HALL_MAIN_EVENT,function (data)
            if not data then return end
            if self.is_refresh then
                message(TI18N("刷新成功"))
                self.is_must_new = true
                self.is_refresh = false
                self.dic_team_id = {}
            end
            self:setData(data)
        end)
    end

    --搜索返回
    if self.arenateam_search_team_event == nil then
        self.arenateam_search_team_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_SEARCH_TEAM_EVENT,function (data)
            if not data then return end
            self:setSearchBack(data)
        end)
    end
    --一键申请
    if self.arenateam_key_apply_team_event == nil then
        self.arenateam_key_apply_team_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_KEY_APPLY_TEAM_EVENT,function (data)
            if not data then return end
            self:keyApplyTeam(data)
        end)
    end
    --申请单个
    if self.arenateam_apply_team_event == nil then
        self.arenateam_apply_team_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_APPLY_TEAM_EVENT,function (data)
            if not data then return end
            if not self.dic_apply_team_id then return end
            local key = data.srv_id.."_"..data.tid
            self.dic_apply_team_id[key] = true
            self:updateShowlist(false)
        end)
    end

    -- if self.update_honor_wall_event == nil then
    --     self.update_honor_wall_event = GlobalEvent:getInstance():Bind(RoleEvent.ROLE_UPDATE_HONOR_WALL_EVENT,function (data)
    --         if not data then return end
    --         if self.dic_use_honor_icon_list then
    --             if data.id == 0 then
    --                 self.dic_use_honor_icon_list[data.pos] = nil
    --             else
    --                 self.dic_use_honor_icon_list[data.pos] = {pos = data.pos, id = data.id}
    --             end
    --         end
            
    --     end)
    -- end
end

--查找
function ArenateamHallTapTeamPanel:onFindBtn()
    local name = self.edit_box:getText() or ""
    if name == "" then
        message(TI18N("请输入正确的队伍名字"))
        return 
    end
    controller:sender27210(name)
end

--一键申请
function ArenateamHallTapTeamPanel:onRequireBtn()
    if not self.show_list then return end
    local is_have_team = model:isHaveTeam()
    if is_have_team then
        message(TI18N("已有队伍,不能申请"))
        return
    end

    if #self.show_list == 0 then
        message(TI18N("当前无可申请的队伍"))
        return
    end

    local do_join_list = {}
    for i,v in ipairs(self.show_list) do
        if v.apply_order == 0 then
            local data = {}
            data.tid = v.tid
            data.order = i
            data.srv_id = v.srv_id
            table_insert(do_join_list, data)
        end
    end
    controller:sender27216(do_join_list) 
end

--创建队伍
function ArenateamHallTapTeamPanel:onCreateBtn()
    controller:openArenateamCreateTeamPanel(true)
end

--刷新
function ArenateamHallTapTeamPanel:onRefreshBtn()
    self.is_refresh = true 
    controller:sender27200()
end

function ArenateamHallTapTeamPanel:setData(scdata, is_new_data)
    if not role_vo then return end
    self.scdata = scdata

    local is_new_data = is_new_data or false
    for i,team_data in ipairs(scdata.team_list) do
        local key = team_data.srv_id.."_"..team_data.tid
        if self.dic_team_id[key] then
            for k,v in pairs(team_data) do
                self.dic_team_id[key][k] = v
            end
        else
            is_new_data = true
            self.dic_team_id[key] = team_data
        end
    end

    if scdata.do_join_list then
        self.dic_apply_team_id = {}
        for i,join_data in ipairs(scdata.do_join_list) do
            local key = join_data.srv_id.."_"..join_data.tid
            self.dic_apply_team_id[key] = true
        end
    end

    self:updateShowlist(is_new_data)
end

function ArenateamHallTapTeamPanel:keyApplyTeam( data )
    if not self.scdata then return end
    if not self.dic_apply_team_id then return end

    for i,join_data in ipairs(data.do_join_list) do
        local key = join_data.srv_id.."_"..join_data.tid
        self.dic_apply_team_id[key] = true
    end
    self:updateShowlist(false)
end

function ArenateamHallTapTeamPanel:updateShowlist(is_new_data)
    self.show_list = {}
    local math_abs = math.abs
    for k,team_data in pairs(self.dic_team_id) do
        local count = #team_data.team_members
        if count > 0 then
            --战力
            local power =  team_data.team_power/count
            team_data.temp_power = math_abs(power - role_vo.power)

            team_data.must_count = 0
            --满足等级
            if role_vo.lev >= team_data.team_limit_lev then
                team_data.must_count = team_data.must_count + 1
            end
            --满足战力
            if role_vo.power >= team_data.team_limit_power then
               team_data.must_count = team_data.must_count + 1 
            end

            --已申请
            local key = team_data.srv_id.."_"..team_data.tid
            if self.dic_apply_team_id[key] then
                team_data.apply_order = 1
            else
                team_data.apply_order = 0
            end

            if count >= 3 then
                team_data.max_count = 3 
            else
                team_data.max_count = 0
            end


            table_insert(self.show_list, team_data)
        end
    end

    local sortfunc = SortTools.tableCommonSorter({{"max_count", false}, {"apply_order", false},  {"must_count", true},  {"temp_power", false}, {"tid", false}})
    table_sort(self.show_list, sortfunc)
    is_new_data = is_new_data or self.is_must_new
    self:updateTeamlist(is_new_data)   
    self.is_must_new = false
end

function ArenateamHallTapTeamPanel:setSearchBack(data)
    self.show_list = data.team_list
    table_sort(self.show_list, function(a, b) return a.tid < b.tid end)
    self.is_must_new = true
    self:updateTeamlist(true)  
end

--列表
function ArenateamHallTapTeamPanel:updateTeamlist(is_new_data)
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 606,                -- 单元的尺寸width
            item_height = 153,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

        self.scrollview_list:reloadData()
    else
        if is_new_data then
            self.scrollview_list:reloadData()    
        else --没有新数据就刷新当前item
            self.scrollview_list:resetCurrentItems()
        end
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("暂无队伍信息")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamHallTapTeamPanel:createNewCell(width, height)
    local cell = ArenateamHallTapTeamItem.new(width, height, self)
    return cell
end

--获取数据数量
function ArenateamHallTapTeamPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamHallTapTeamPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end

--点击cell .需要在 createNewCell 设置点击事件
function ArenateamHallTapTeamPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
end

--移除
function ArenateamHallTapTeamPanel:DeleteMe()
    if self.arenateam_hall_mian_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_hall_mian_event)
        self.arenateam_hall_mian_event = nil
    end
    
    if self.arenateam_search_team_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_search_team_event)
        self.arenateam_search_team_event = nil
    end

    if self.arenateam_key_apply_team_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_key_apply_team_event)
        self.arenateam_key_apply_team_event = nil
    end

    if self.arenateam_apply_team_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_apply_team_event)
        self.arenateam_apply_team_event = nil
    end
    

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
        self.scrollview_list = nil
    end
end


-- 子项arenateam_hall_tap_team_item
ArenateamHallTapTeamItem = class("ArenateamHallTapTeamItem", function()
    return ccui.Widget:create()
end)

function ArenateamHallTapTeamItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenateamHallTapTeamItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_hall_tap_team_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.team_name = self.main_container:getChildByName("team_name")
    self.power = self.main_container:getChildByName("power")

    self.head_list = {}
    local x = 58
    for i=1,3 do
        self.head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.head_list[i]:setHeadLayerScale(0.8)
        self.head_list[i]:setPosition(x + 95 * (i - 1) , 58)
        self.head_list[i]:setLev(99)
        self.main_container:addChild(self.head_list[i])
    end
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("申 请"))

    self.apply_tips = self.main_container:getChildByName("apply_tips")
    self.apply_tips:setString(TI18N("已申请"))
    self.apply_tips:setVisible(false)

    self.limit_level = self.main_container:getChildByName("limit_level")
    self.limit_level:setString(TI18N("等级: 无"))
    self.limit_power = self.main_container:getChildByName("limit_power")
    self.limit_power:setString(TI18N("战力: 无"))
end

function ArenateamHallTapTeamItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end, true, 2, nil, nil, 1)

    for i,head in ipairs(self.head_list) do
        head:addCallBack(function() self:onClickHead(i) end )
    end
end

function ArenateamHallTapTeamItem:onClickHead(i)
    local team_members = self.data.team_members or {}
    local data = team_members[i]
    if not data then return end
    if self.head_list and self.head_list[i] then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and data.rid == roleVo.rid and data.sid == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end

--申请
function ArenateamHallTapTeamItem:onComfirmBtn()
    if not self.data then return end

    local is_have_team = model:isHaveTeam()
    if is_have_team then
        message(TI18N("已有队伍,不能申请"))
        return
    end

    if self.data.apply_order == 1 then
        message(TI18N("已申请该队伍"))
        return
    end

    if not self.is_ok then
        message(TI18N("申请条件不满足"))
        return
    end
    
    controller:sender27202(self.data.tid, self.data.srv_id)
end


function ArenateamHallTapTeamItem:setData(data)
    if not data then return end
    self.data = data
    self.team_name:setString(data.team_name)
    self.power:setString(data.team_power)

    local team_members = data.team_members or {}
    for i,member_data in ipairs(team_members) do
        member_data.is_leader = 0
        for i,v in ipairs(member_data.ext) do
            if v.extra_key == 1 then --是否队长
                if v.extra_val == 1 then
                    member_data.is_leader = 1 
                else
                    member_data.is_leader = - member_data.pos   
                end
            end
        end
    end
    table_sort(team_members, function(a, b) return a.is_leader > b.is_leader end)


    for i,head in ipairs(self.head_list) do
        local member_data = team_members[i]
        if member_data then
            head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
            head:setLev(member_data.lev)
            head:addDesc(false)
            if member_data.is_leader == 1 then
                head:showLeader(true)  
            else
                head:showLeader(false)
            end
            local avatar_bid = member_data.avatar_bid
            if head.record_res_bid == nil or head.record_res_bid ~= avatar_bid then
                head.record_res_bid = avatar_bid
                local vo = Config.AvatarData.data_avatar[avatar_bid]
                --背景框
                if vo then
                    local res_id = vo.res_id or 1
                    local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                    head:showBg(res, nil, false, vo.offy)
                else
                    local bgRes = PathTool.getResFrame("common","common_1031")
                    head:showBg(bgRes, nil, true)
                end
            end
        else
            --没有数据..还原
            head:clearHead()
            head:closeLev()
            head:addDesc(true, TI18N("待加入"))
            head:showLeader(false)
            local bgRes = PathTool.getResFrame("common","common_1031")
            head:showBg(bgRes, nil, true)
        end
    end

    --是否条件满足
    self.is_ok = true
    if #team_members < 3 then
        --不满人
        if data.team_limit_lev == 0 then
            self.limit_level:setVisible(false)
        else
            self.limit_level:setVisible(true)
            self.limit_level:setString(string_format(TI18N("等级: %s级"), data.team_limit_lev))
            if role_vo and role_vo.lev >= data.team_limit_lev then
                self.limit_level:setTextColor(cc.c3b(0x24,0x90,0x03))
            else
                self.limit_level:setTextColor(cc.c3b(0xd9,0x50,0x14))
                self.is_ok = false
            end
        end

        if data.team_limit_power == 0 then
            self.limit_power:setVisible(false)
        else
            self.limit_power:setVisible(true)
            local power = math_floor(data.team_limit_power/10000)
            self.limit_power:setString(string_format(TI18N("战力: %s万"), power))
            if role_vo and role_vo.power >= data.team_limit_power then
                self.limit_power:setTextColor(cc.c3b(0x24,0x90,0x03))
            else
                self.limit_power:setTextColor(cc.c3b(0xd9,0x50,0x14))
                self.is_ok = false
            end
        end        
    else
        self.limit_level:setVisible(false)
        self.limit_power:setVisible(false)
    end

    --是否已有队伍 如有队伍.就不处理显示已申请了
    local is_have_team = model:isHaveTeam()
    if is_have_team then
        self.comfirm_btn:setVisible(false)
    else 
        self.comfirm_btn:setVisible(true)
        if data.max_count == 3 then
            setChildUnEnabled(true, self.comfirm_btn)
            self.comfirm_btn:setTouchEnabled(false)
            self.comfirm_label:setString(TI18N("已满人"))
            self.comfirm_label:disableEffect(cc.LabelEffect.OUTLINE)
        elseif data.apply_order == 1 then
            --已申请
            setChildUnEnabled(true, self.comfirm_btn)
            self.comfirm_btn:setTouchEnabled(false)
            self.comfirm_label:setString(TI18N("已申请"))
            self.comfirm_label:disableEffect(cc.LabelEffect.OUTLINE)
        else
            self.comfirm_label:setString(TI18N("申 请"))
            self.comfirm_label:enableOutline(Config.ColorData.data_color4[263], 2) --绿色
            if self.is_ok then --是否能申请
                setChildUnEnabled(false, self.comfirm_btn)
                self.comfirm_btn:setTouchEnabled(true)
            else
                setChildUnEnabled(true, self.comfirm_btn)
                self.comfirm_btn:setTouchEnabled(false)
            end
        end
    end
end

function ArenateamHallTapTeamItem:DeleteMe()
    if self.head_list then
        for i,item in ipairs(self.head_list) do
            item:DeleteMe()
        end
        self.head_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end

