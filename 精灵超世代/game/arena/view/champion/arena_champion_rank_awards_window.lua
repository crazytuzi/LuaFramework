-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛排名奖励的面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionRankAwardsWindow = ArenaChampionRankAwardsWindow or BaseClass(BaseView)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel()

function ArenaChampionRankAwardsWindow:__init(view_type)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "arena/arena_champion_rank_awards_window"
	self.res_list = {
	-- {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
	}

	self.view_type = view_type or ArenaConst.champion_type.normal
	self.award_list = {}
end 

function ArenaChampionRankAwardsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    local main_panel = main_container:getChildByName("main_panel")
    if self.view_type == ArenaConst.champion_type.normal then
    	main_panel:getChildByName("win_title"):setString(TI18N("冠军赛奖励"))
    else
    	main_panel:getChildByName("win_title"):setString(TI18N("周冠军赛奖励"))
    end
    main_panel:getChildByName("notice_label"):setString(TI18N("比赛结束后奖品将发送到邮箱")) 

    self.close_btn = main_panel:getChildByName("close_btn")
    self.list_view = main_panel:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        start_x = 5,
        space_x = 0,
        start_y = 0,
        space_y = 5,
        item_width = 604,
        item_height = 114,
        row = 0,
        col = 1,
        need_dynamic = true
    }

	self.scroll_view = CommonScrollViewSingleLayout.new(self.list_view, nil, nil, nil, size, setting, cc.p(0, 0))

	self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
	self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
	self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell


	local title_container = main_panel:getChildByName("title_container")
	title_container:getChildByName("award_title"):setString(TI18N("奖励"))
	title_container:getChildByName("rank_title"):setString(TI18N("排名"))
end

function ArenaChampionRankAwardsWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaChampionRankAwardsWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaChampionRankAwardsWindow(false)
		end
	end)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaChampionRankAwardsWindow:createNewCell()
    local cell = ArenaChampionRankAwardsItem.new()
	if cell.setExtendData then
		cell:setExtendData(self.view_type)
	end
    return cell
end

--获取数据数量
function ArenaChampionRankAwardsWindow:numberOfCells()
    if not self.award_list then return 0 end
    return #self.award_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaChampionRankAwardsWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.award_list[index]
    if not data then return end
    cell:setData(data)
end

function ArenaChampionRankAwardsWindow:openRootWnd()
    -- 临时测试,直接用循环赛排名奖励
    local tmp_list = {}
    if self.view_type == ArenaConst.champion_type.normal then
    	tmp_list = deepCopy(Config.ArenaChampionData.data_awards)
    else
    	tmp_list = deepCopy(Config.ArenaClusterChampionData.data_awards)
    end
    for i,v in ipairs(tmp_list) do
        v.index = i
	end
	self.award_list = tmp_list
    self.scroll_view:reloadData()
end

function ArenaChampionRankAwardsWindow:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    controller:openArenaChampionRankAwardsWindow(false)
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛排行奖励单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionRankAwardsItem = class("ArenaChampionRankAwardsItem", function()
	return ccui.Layout:create()
end)

function ArenaChampionRankAwardsItem:ctor()
	self.item_list = {}
	
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_loop_activity_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	self.rank_img = self.root_wnd:getChildByName("rank_img")
	self.rank_label = self.root_wnd:getChildByName("rank_label")
	self.item_container = self.root_wnd:getChildByName("item_container")
	
	self.total_width = self.item_container:getContentSize().width
	
	self:registerEvent()
end

function ArenaChampionRankAwardsItem:registerEvent()
end

function ArenaChampionRankAwardsItem:setExtendData( view_type )
	self.view_type = view_type or ArenaConst.champion_type.normal
end

function ArenaChampionRankAwardsItem:setData(data)
	if data ~= nil then
		if data.index ~= nil then
			if data.index <= 3 then
				self.rank_label:setVisible(false)
				if data.rank == 0 then
					self.rank_img:setVisible(false)
				else
					-- local res_id = PathTool.getResFrame("common", string.format("common_300%s", data.index))
					local res_id = PathTool.getResFrame("common", RankConstant.RankIconRes[data.index])
					if self.rank_res_id ~= res_id then
						self.rank_res_id = res_id
						loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
					end
					self.rank_img:setVisible(true)
				end
			else
				self.rank_img:setVisible(false)
				self.rank_label:setVisible(true)
				if data.min == data.max then
					self.rank_label:setString(data.min)
				else
					self.rank_label:setString(string.format("%s~%s", data.min, data.max))
				end
			end
		end
		-- 先隐藏掉一些吧
        for k, item in pairs(self.item_list) do
            item:setVisible(false)
        end

		local item_config = nil
		local index = 1
		local item = nil
		local scale = 0.8
		local off = 10
		local _x, _y = 0, 55
		local items = data.items
		if self.view_type == ArenaConst.champion_type.cross then
			items = data.awards or data.items or {}
		end
		local sum = #items
		for i = sum, 1, - 1 do
            local v = items[i]
            item_config = Config.ItemData.data_get_data(v[1])
            if item_config then
                if self.item_list[index] == nil then
                    item = BackPackItem.new(false, true, false, scale, false, true) 
                    _x = self.total_width - ( (index-1)*(BackPackItem.Width*scale+off) + BackPackItem.Width*0.5*scale )
                    item:setPosition(_x, _y)
                    self.item_container:addChild(item)
                    self.item_list[index] = item
                else
                end
                item = self.item_list[index]
                item:setVisible(true)
                item:setBaseData(v[1],v[2])
                index = index + 1
            end
		end
	end
end

function ArenaChampionRankAwardsItem:DeleteMe()
	for i, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
	self:removeAllChildren()
	self:removeFromParent()
end 