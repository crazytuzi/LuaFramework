--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-06 15:56:29
-- @description    : 
		-- 跨服竞技场 排行榜
---------------------------------

local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()

CrossarenaRankWindow = CrossarenaRankWindow or BaseClass(BaseView)

function CrossarenaRankWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "ladder/ladder_rank_window"
	self.show_list = {}
end

function CrossarenaRankWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName('background')
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName('main_container')
    self:playEnterAnimatianByObj(self.main_panel, 1)
    self.close_btn = self.main_panel:getChildByName('close_btn')

    local title_con = self.main_panel:getChildByName("title_con")
    local title_label = title_con:getChildByName("title_label")
    title_label:setString(TI18N("排行榜"))

    self.no_log_image = self.main_panel:getChildByName("no_log_image")
    self.no_log_image:setVisible(false)

    self.rank_panel = self.main_panel:getChildByName('rank_panel')
    self.my_rank = self.main_panel:getChildByName('my_rank')
    local title = self.my_rank:getChildByName('title')
    title:setString(TI18N('我的排名'))
    self.no_rank_label = self.my_rank:getChildByName("no_rank_label")
    self.no_rank_label:setVisible(false)
    self.my_rank_id = self.my_rank:getChildByName("rank_id")
    self.my_name_label = self.my_rank:getChildByName("my_name_label")
    self.my_attk_label = self.my_rank:getChildByName("my_attk_label")
    self.my_guild_label = self.my_rank:getChildByName("my_guild_label")
    self.best_rank_label = self.my_rank:getChildByName("best_rank_label")
    self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setHeadLayerScale(0.8)
    self.my_head:setPosition(150, 66)
    self.my_rank:addChild(self.my_head)

    local bgSize = self.rank_panel:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-4)
    local setting = {
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 612,               -- 单元的尺寸width
        item_height = 112,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

	self.rank_scrollview = CommonScrollViewSingleLayout.new(self.rank_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

	self.rank_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
	self.rank_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
	self.rank_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
	

    self.rank_scrollview:setSwallowTouches(false)
end

function CrossarenaRankWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)

	self:addGlobalEvent(CrossarenaEvent.Update_Rank_Data_Event, function ( data )
		self:setData(data)
	end)
end

function CrossarenaRankWindow:_onClickBtnClose(  )
	_controller:openCrossarenaRankWindow(false)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function CrossarenaRankWindow:createNewCell()
    local cell = CrossarenaRankItem.new()
    return cell
end

--获取数据数量
function CrossarenaRankWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function CrossarenaRankWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end


function CrossarenaRankWindow:openRootWnd(  )
	_controller:sender25615()
end

function CrossarenaRankWindow:setData( data )
	if not data then return end

	local role_vo = RoleController:getInstance():getRoleVo()
	self.my_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
	self.my_head:setLev(role_vo.lev)
	self.my_name_label:setString(role_vo.name)
	self.my_attk_label:setString(changeBtValueForPower(role_vo.power))
	local my_score = _model:getMyCrossarenaScore()
	self.my_guild_label:setString(string.format(TI18N("积分:%d"), my_score)) -- 积分
	if not data.best_rank or data.best_rank == 0 then
		self.best_rank_label:setString(TI18N("历史最高：暂无"))
	else
		self.best_rank_label:setString(string.format(TI18N("历史最高：%d名"), data.best_rank))
	end

	if not data.rank or data.rank == 0 then
		self.no_rank_label:setVisible(true)
		self.my_rank_id:setVisible(false)
	else
		self.my_rank_id:setString(data.rank)
		self.no_rank_label:setVisible(false)
	end
	
	if not data.arena_cluster_role or next(data.arena_cluster_role) == nil then
		self.no_log_image:setVisible(true)
		self.show_list ={}
	else
		self.no_log_image:setVisible(false)
		self.show_list =data.arena_cluster_role
	end
	
	self.rank_scrollview:reloadData()
end

function CrossarenaRankWindow:close_callback(  )
	if self.rank_scrollview then
		self.rank_scrollview:DeleteMe()
		self.rank_scrollview = nil
	end
	if self.my_head then
		self.my_head:DeleteMe()
		self.my_head = nil
	end
    _controller:openCrossarenaRankWindow(false)
end

---------------------------@ 排行榜 子项
CrossarenaRankItem = class("CrossarenaRankItem", function()
    return ccui.Widget:create()
end)

function CrossarenaRankItem:ctor()
	self:configUI()
	self:register_event()
end

function CrossarenaRankItem:configUI(  )
	self.size = cc.size(612,112)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("crossarena/crossarena_rank_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("main_panel")
    self.container = container
    self.container:setSwallowTouches(false)

    self.rank_id = container:getChildByName("rank_id")
    self.rank_image = container:getChildByName("rank_image")
    self.rank_image:ignoreContentAdaptWithSize(true)
    self.guild_label = container:getChildByName("my_guild_label")
    self.attk_label = container:getChildByName("my_attk_label")
    self.name_label = container:getChildByName("my_name_label")
    self.score_label = container:getChildByName("my_score_label")
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.8)
    self.role_head:setPosition(140, 56)
    self.role_head:addCallBack(handler(self, self.openChatMessage))
    container:addChild(self.role_head)
end

function CrossarenaRankItem:register_event(  )
	
end

function CrossarenaRankItem:openChatMessage(  )
	local roleVo = RoleController:getInstance():getRoleVo()
	local rid = self.data.rid
	local srv_id  = self.data.srv_id
	if self.data.srv_id and self.data.srv_id == "robot" then 
		message(TI18N("神秘人太高冷，不给查看"))
		return
	end
	if rid and srv_id and roleVo.rid== rid and roleVo.srv_id == srv_id then 
		message(TI18N("你不认识你自己了么？"))
		return 
	end
	if self.data then 
		local vo = {rid = rid, srv_id = srv_id}
		ChatController:getInstance():openFriendInfo(vo,cc.p(0,0))
	end
end

function CrossarenaRankItem:setData( data )
	data = data or {}
	self.data = data

	if data.rank == 1 then
		self.rank_id:setVisible(false)
		self.rank_image:setVisible(true)
		self.rank_image:loadTexture(PathTool.getResFrame("common","common_3001"), LOADTEXT_TYPE_PLIST)
	elseif data.rank == 2 then
		self.rank_id:setVisible(false)
		self.rank_image:setVisible(true)
		self.rank_image:loadTexture(PathTool.getResFrame("common","common_3002"), LOADTEXT_TYPE_PLIST)
	elseif data.rank == 3 then
		self.rank_id:setVisible(false)
		self.rank_image:setVisible(true)
		self.rank_image:loadTexture(PathTool.getResFrame("common","common_3003"), LOADTEXT_TYPE_PLIST)
	else
		self.rank_id:setString(data.rank)
		self.rank_id:setVisible(true)
		self.rank_image:setVisible(false)
	end

	self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
	self.role_head:setLev(data.lev)

	self.name_label:setString(transformNameByServ(data.name, data.srv_id))
	self.attk_label:setString(changeBtValueForPower(data.power))
	local guild_name = ""
	if data.gname == nil or data.gname == "" then
		guild_name = TI18N("暂未加入公会")
	else
		guild_name = string.format(TI18N("公会:%s"), data.gname)
	end
	self.guild_label:setString(guild_name)
	self.score_label:setString(string.format(TI18N("积分:%d"), data.score or 0))
end

function CrossarenaRankItem:DeleteMe(  )
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end