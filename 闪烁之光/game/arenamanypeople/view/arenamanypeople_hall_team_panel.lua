-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队
-- <br/> 2020年3月23日
-- --------------------------------------------------------------------
ArenaManyPeopleHallTeamPanel = class("ArenaManyPeopleHallTeamPanel", function()
    return ccui.Widget:create()
end)

local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

local role_vo = RoleController:getInstance():getRoleVo()

function ArenaManyPeopleHallTeamPanel:ctor(parent)
    self.parent = parent

    self:config()
    self:layoutUI()
    self:registerEvents()
    
end

function ArenaManyPeopleHallTeamPanel:setVisibleStatus(bool)
    if not self.parent then return end
    self.visible_status = bool or false 
    self:setVisible(bool)
    
    if bool == true then
        self.dic_team_id = {}
        self.dic_apply_team_id = {}
        controller:sender29010()
        controller:sender29008()
    end
end

function ArenaManyPeopleHallTeamPanel:config()
    self.dic_team_id = {}

    self.dic_apply_team_id = {}

    self.default_msg = TI18N("请输入需要搜索的玩家名")

    --是否一定要刷新
    self.is_must_new = true
end

function ArenaManyPeopleHallTeamPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_hall_team_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")

    self.recommend_label = self.container:getChildByName("recommend_label")
    self.recommend_label:setString(TI18N("推荐玩家"))

    self.find_btn = self.container:getChildByName("find_btn")
    self.find_btn:getChildByName("label"):setString(TI18N("查 找"))
    self.require_btn = self.container:getChildByName("require_btn")
    self.require_btn:getChildByName("label"):setString(TI18N("查看好友"))
    
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
    self.edit_box:setPosition(cc.p(20,677))

end

--事件
function ArenaManyPeopleHallTeamPanel:registerEvents()
    registerButtonEventListener(self.find_btn, function() self:onFindBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.require_btn, function() self:onRequireBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.refresh_btn, function() self:onRefreshBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY,nil,nil, 1)



    if self.arenateam_hall_mian_event == nil then
        self.arenateam_hall_mian_event = GlobalEvent:getInstance():Bind(ArenaManyPeopleEvent.ARENAMANYPOEPLE_GET_RECOMMEND_INFO_EVENT,function (data)
            if not data then return end
            if self.is_refresh then
                self.is_must_new = true
                self.is_refresh = false
                self.dic_team_id = {}
            end
            self:setData(data)
        end)
    end

    --搜索返回
    if self.search_team_event == nil then
        self.search_team_event = GlobalEvent:getInstance():Bind(ArenaManyPeopleEvent.ARENAMANYPOEPLE_SEARCH_TEAM_EVENT,function (data)
            if not data then return end
            self:setSearchBack(data)
        end)
    end
   
    --申请单个
    if self.arenateam_apply_team_event == nil then
        self.arenateam_apply_team_event = GlobalEvent:getInstance():Bind(ArenaManyPeopleEvent.ARENAMANYPOEPLE_INVITATION_PLAYER_EVENT,function (data)
            if not data then return end
            if not self.dic_apply_team_id then return end
            local key = data.srv_id.."_"..data.rid
            self.dic_apply_team_id[key] = true
            self:updateShowlist(false)
        end)
    end

    --申请多个返回
    if self.arenateam_update_manber_event == nil then
        self.arenateam_update_manber_event = GlobalEvent:getInstance():Bind(ArenaManyPeopleEvent.ARENAMANYPOEPLE_UPDATE_MENBER_EVENT,function (data)
            if not data then return end
            if data.invite_list then
                self.dic_apply_team_id = {}
                for i,join_data in ipairs(data.invite_list) do
                    local key = join_data.sid.."_"..join_data.rid
                    self.dic_apply_team_id[key] = true
                end
            end
        end)
    end
    
end

--查找
function ArenaManyPeopleHallTeamPanel:onFindBtn()
    local name = self.edit_box:getText() or ""
    if name == "" then
        message(TI18N("请输入正确玩家名"))
        return 
    end
    
    controller:sender29001(name)
end

--查看好友
function ArenaManyPeopleHallTeamPanel:onRequireBtn()
    self.is_refresh = true
    controller:sender29009() 
end


--刷新
function ArenaManyPeopleHallTeamPanel:onRefreshBtn()
    self.is_refresh = true 
    controller:sender29008()
end

function ArenaManyPeopleHallTeamPanel:setData(scdata, is_new_data)
    if not role_vo then return end
    self.scdata = scdata

    local is_new_data = is_new_data or false
    for i,team_data in ipairs(scdata.team_members) do
        local key = team_data.sid.."_"..team_data.rid
        if self.dic_team_id[key] then
            for k,v in pairs(team_data) do
                self.dic_team_id[key][k] = v
            end
        else
            is_new_data = true
            self.dic_team_id[key] = team_data
        end
    end

    self:updateShowlist(is_new_data)
end


function ArenaManyPeopleHallTeamPanel:updateShowlist(is_new_data)
    self.show_list = {}
    for k,team_data in pairs(self.dic_team_id) do
        --已申请
        local key = team_data.sid.."_"..team_data.rid
        if self.dic_apply_team_id[key] then
            team_data.apply_order = 1
        else
            team_data.apply_order = 0
        end
        table_insert(self.show_list, team_data)
    end

    local sortfunc = SortTools.tableCommonSorter({{"apply_order", false}, {"power", true}, {"rid", false}})
    table_sort(self.show_list, sortfunc)
    is_new_data = is_new_data or self.is_must_new
    self:updateTeamlist(is_new_data)   
    self.is_must_new = false
end

function ArenaManyPeopleHallTeamPanel:setSearchBack(data)
    self.show_list = data.team_members
    table_sort(self.show_list, function(a, b) return a.power < b.power end)
    self.is_must_new = true
    self:updateTeamlist(true)  
end

--列表
function ArenaManyPeopleHallTeamPanel:updateTeamlist(is_new_data)
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

        self.scrollview_list:reloadData()
    else
        if is_new_data then
            self.scrollview_list:reloadData()    
        else --没有新数据就刷新当前item
            self.scrollview_list:resetCurrentItems()
        end
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("暂无玩家信息")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaManyPeopleHallTeamPanel:createNewCell(width, height)
    local cell = ArenaManyPeopleHallTeamItem.new(width, height, self)
    return cell
end

--获取数据数量
function ArenaManyPeopleHallTeamPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaManyPeopleHallTeamPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end


--移除
function ArenaManyPeopleHallTeamPanel:DeleteMe()
    if self.arenateam_hall_mian_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_hall_mian_event)
        self.arenateam_hall_mian_event = nil
    end
    
    if self.search_team_event then
        GlobalEvent:getInstance():UnBind(self.search_team_event)
        self.search_team_event = nil
    end


    if self.arenateam_apply_team_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_apply_team_event)
        self.arenateam_apply_team_event = nil
    end

    if self.arenateam_update_manber_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_update_manber_event)
        self.arenateam_update_manber_event = nil
    end
    
    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
        self.scrollview_list = nil
    end
end


-- 子项amp_hall_team_item
ArenaManyPeopleHallTeamItem = class("ArenaManyPeopleHallTeamItem", function()
    return ccui.Widget:create()
end)

function ArenaManyPeopleHallTeamItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenaManyPeopleHallTeamItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_hall_team_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.role_name = self.main_container:getChildByName("role_name")
    self.power = self.main_container:getChildByName("power")
    self.power_bg = self.main_container:getChildByName("Image_1")
    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setHeadLayerScale(0.9)
    self.head_icon:setPosition(170 , 67.5)
    self.main_container:addChild(self.head_icon)
    self.head_icon:addCallBack(function() self:onClickHead() end )

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("邀 请"))

    self.limit_level_title = self.main_container:getChildByName("limit_level_title")
    self.limit_level_title:setString(TI18N("排名"))


    self.limit_rank = self.main_container:getChildByName("limit_level")
    self.limit_rank:setString(TI18N("无"))
    self.limit_score = self.main_container:getChildByName("limit_power")
    self.limit_score:setString(TI18N("无"))
end

function ArenaManyPeopleHallTeamItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end, true, 2, nil, nil, 1)

end

function ArenaManyPeopleHallTeamItem:onClickHead()
    if not self.data then return end
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo and self.data.rid == roleVo.rid and self.data.sid == roleVo.srv_id then 
        message(TI18N("这是你自己~"))
        return
    end
    FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.sid, rid = self.data.rid})
end

--邀请
function ArenaManyPeopleHallTeamItem:onComfirmBtn()
    if not self.data then return end
    controller:sender29002(self.data.rid, self.data.sid)
end


function ArenaManyPeopleHallTeamItem:setData(data)
    if not data then return end
    self.data = data
    self.role_name:setString(data.name)
    self.power:setString(tostring(data.power))
    local width = self.power:getContentSize().width + 75
    local height = self.power_bg:getContentSize().height
    self.power_bg:setContentSize(cc.size(width,height))

    self.limit_score:setString(string_format(TI18N("积分：%s"), data.score))
    if data.rank > 0 then
        self.limit_rank:setString(tostring(data.rank)) 
    else
        self.limit_rank:setString(TI18N("未上榜")) 
    end
    

    if self.head_icon then
        self.head_icon:setHeadRes(self.data.face_id, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
        self.head_icon:setLev(self.data.lev)
        self.head_icon:addDesc(false)
        
        local avatar_bid = self.data.avatar_bid
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
    
    if data.apply_order == 1 then
        --已邀请
        setChildUnEnabled(true, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(false)
        self.comfirm_label:setString(TI18N("已邀请"))
        self.comfirm_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        self.comfirm_label:setString(TI18N("邀 请"))
        self.comfirm_label:enableOutline(Config.ColorData.data_color4[264], 2) --橙色
        setChildUnEnabled(false, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(true)
    end
end

function ArenaManyPeopleHallTeamItem:DeleteMe()
    if self.head_icon then
        self.head_icon:DeleteMe()
        self.head_icon = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

