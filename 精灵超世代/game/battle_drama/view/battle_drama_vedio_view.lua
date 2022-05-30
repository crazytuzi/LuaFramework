--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-17 19:28:32
-- @description    : 
		-- 通关录像
---------------------------------
BattlDramaPassVedioView = BattlDramaPassVedioView or BaseClass(BaseView)

local controller = BattleDramaController:getInstance() 
local model = BattleDramaController:getInstance():getModel()
local Pass_Type = {
	Fastest = 1,  -- 最快通关
	Lowest = 2,	  -- 最低战力通关
	Lately = 3,	  -- 最近通关
}

function BattlDramaPassVedioView:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "battledrama/battle_drama_vedio_view"
    self.res_list = {
        --{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
    }
end

function BattlDramaPassVedioView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

    local title_label = container:getChildByName("title_label")
    title_label:setString(TI18N("通关录像"))
    
    self.close_btn = container:getChildByName("close_btn")

    local item_list = container:getChildByName("item_container")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = DramaPassVedioItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 600,               -- 单元的尺寸width
        item_height = 136,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,-2) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview:setBounceEnabled(false)
end

function BattlDramaPassVedioView:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), nil, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), nil, 2)

	self:addGlobalEvent(Battle_dramaEvent.UpdatePassVedioDataEvent, function ( data )
		self:setData(data)
	end)
end

function BattlDramaPassVedioView:_onClickCloseBtn(  )
	controller:openDramaPassVedioView(false)
end

function BattlDramaPassVedioView:setData( data )
	if not data then return end

	local function getVedioDataByType( pType )
		for _,v in pairs(data) do
			if v.type == pType then
				return v
			end
		end
	end

	local vedio_data = {}
	for i=1,3 do
		local temp_data = getVedioDataByType(i)
		if not temp_data then
			temp_data = {}
			temp_data.type = i
		end
		table.insert(vedio_data, temp_data)
	end
	self.item_scrollview:setData(vedio_data)
end

function BattlDramaPassVedioView:openRootWnd(  )
	local drama_data = model:getDramaData()
    if drama_data then
    	local cur_dun_id = drama_data.dun_id
    	controller:send13015(cur_dun_id)
    end
end

function BattlDramaPassVedioView:close_callback(  )
	controller:openDramaPassVedioView(false)
end


----------------------------@ item
DramaPassVedioItem = class("DramaPassVedioItem", function()
    return ccui.Widget:create()
end)

function DramaPassVedioItem:ctor()
	self:configUI()
	self:register_event()
end

function DramaPassVedioItem:configUI(  )
	self.size = cc.size(600, 136)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("battledrama/battle_drama_vedio_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.type_label = self.root_wnd:getChildByName("type_label")
    self.empty_label = self.root_wnd:getChildByName("empty_label")
    self.empty_label:setString(TI18N("虚位以待"))
    self.container = self.root_wnd:getChildByName("container")


    self.name_label = self.container:getChildByName("name_label")
    self.desc_label = self.container:getChildByName("desc_label")
    self.check_btn = self.container:getChildByName("check_btn")
    self.check_btn:setTitleText(TI18N("查看"))
end

function DramaPassVedioItem:register_event(  )
	registerButtonEventListener(self.check_btn, handler(self, self._onClickCheckBtn))
end

function DramaPassVedioItem:_onClickCheckBtn(  )
	if self.data and self.data.repaly_id and self.data.sid then
		BattleController:getInstance():csRecordBattle(self.data.repaly_id, self.data.sid)
	end
end

function DramaPassVedioItem:setData( data )
	self.data = data or {}
	if not self.data.type then return end

	if self.data.type == 1 then
		self.type_label:setString(TI18N("最快"))
	elseif self.data.type == 2 then
		self.type_label:setString(TI18N("最低"))
	elseif self.data.type == 3 then
		self.type_label:setString(TI18N("最近"))
	end

	if self.data.rid == nil then
		self.empty_label:setVisible(true)
		self.container:setVisible(false)
	else
		self.empty_label:setVisible(false)
		self.container:setVisible(true)

		self.name_label:setString(self.data.name)

		if not self.player_head then
			self.player_head = PlayerHead.new(PlayerHead.type.circle)
		    self.player_head:setHeadRes(self.data.face_id, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
		    self.player_head:setPosition(80, self.size.height/2)
		    self.container:addChild(self.player_head)
		    --[[self.player_head:addCallBack(function (  )
            	if self.data.rid and self.data.sid then
            		local friend_data = {}
            		friend_data.srv_id = self.data.sid
            		friend_data.rid = self.data.rid
            		FriendController:getInstance():openFriendCheckPanel(true, friend_data)
            	end
	        end,true)--]]
		end

		if self.data.type == 1 then
			self.desc_label:setString(string.format(TI18N("通关时间:%s"), TimeTool.GetTimeFormat(self.data.time)))
		elseif self.data.type == 2 then
			self.desc_label:setString(string.format(TI18N("最低战力:%d"), self.data.power))
		elseif self.data.type == 3 then
			self.desc_label:setString(string.format(TI18N("通关时间:%s"), TimeTool.GetTimeFormat(self.data.time)))
		end
	end
end

function DramaPassVedioItem:DeleteMe(  )
	if self.player_head then
		self.player_head:DeleteMe()
		self.player_head = nil
	end
end