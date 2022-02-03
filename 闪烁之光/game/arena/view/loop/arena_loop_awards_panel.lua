-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛的赛季排名奖励面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopAwardsPanel = class("ArenaLoopAwardsPanel", function()
    return ccui.Layout:create()
end)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel() 
local game_net = GameNet:getInstance()
local string_format = string.format 

function ArenaLoopAwardsPanel:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_loop_awards_panel"))

    self.item_list = {}
    self.temp_list = {}
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    local rank_title = container:getChildByName("rank_title")
    rank_title:setString(TI18N("排名"))
    local award_title = container:getChildByName("award_title")
    award_title:setString(TI18N("奖励"))

    local my_container = self.root_wnd:getChildByName("my_container")
    my_container:getChildByName("desc"):setString(TI18N("保持排名可获得奖励:"))
    my_container:getChildByName("role_name"):setString(TI18N("我的排名:"))
    self.role_rank = my_container:getChildByName("role_rank")
    self.item_container = my_container:getChildByName("item_container")
    self.total_width = self.item_container:getContentSize().width 

    local scroll_container = container:getChildByName("scroll_container")
    local size = scroll_container:getContentSize()
    local setting = {
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 4,
        item_width = 614,
        item_height = 124,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewSingleLayout.new(scroll_container, nil, nil, nil, size, setting, cc.p(0, 0))

    self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self.desc = self.root_wnd:getChildByName("desc")

    self:registerEvent()
end

function ArenaLoopAwardsPanel:registerEvent()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaLoopAwardsPanel:createNewCell()
    local cell = ArenaLoopAwardsItem.new()
    return cell
end

--获取数据数量
function ArenaLoopAwardsPanel:numberOfCells()
    if not self.temp_list then return 0 end
    return #self.temp_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaLoopAwardsPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.temp_list[index]
    if not data then return end
    cell:setData(data)
end

function ArenaLoopAwardsPanel:setNodeVisible(status)
	self:setVisible(status)
    self:handleEvent(status)
end 

function ArenaLoopAwardsPanel:addToParent()
    local tmp_list = deepCopy(Config.ArenaData.data_awards)
    for i,v in ipairs(tmp_list) do
        v.index = i
    end
    self.temp_list =tmp_list
    self.scroll_view:reloadData()
end

function ArenaLoopAwardsPanel:updatePanelInfo(is_event)
    local my_data = model:getMyLoopData()
    if my_data == nil then return end
    if my_data.rank == 0 then
        self.role_rank:setString(TI18N("暂未上榜"))
    else
        self.role_rank:setString(my_data.rank)
        local config = nil
        for i, v in ipairs(Config.ArenaData.data_awards) do
            if v.min <= my_data.rank and v.max >= my_data.rank then
                config = v
                break
            end
        end
        if config then
            self:updateMyRewardsItems(config.items)
        end
    end
end

function ArenaLoopAwardsPanel:handleEvent(status)
	if status == true then
		if self.time_ticket == nil then
			self.time_ticket = GlobalTimeTicket:getInstance():add(function()
				self:countDownTimeTicket()
			end, 1)
		end
		self:countDownTimeTicket()
	else
		if self.time_ticket ~= nil then
			GlobalTimeTicket:getInstance():remove(self.time_ticket)
			self.time_ticket = nil
		end
	end
end 

function ArenaLoopAwardsPanel:countDownTimeTicket()
	local data = model:getMyLoopData()
	if data == nil then
		self:handleEvent(false)
		return
	end
	local less_time = data.end_time - game_net:getTime()
	if less_time >= 0 then
		self.desc:setString(string_format(TI18N("赛季剩余时间:%s"), TimeTool.GetTimeFormat(less_time)))
	end 
end

function ArenaLoopAwardsPanel:updateMyRewardsItems(list)
    for k, item in pairs(self.item_list) do
        item:setVisible(false)
    end
    if list == nil or next(list) == nil then return end

    local item_config = nil
    local index = 1
    local item = nil
    local scale = 0.8
    local off = 10
    local _x, _y = 0, 55
    local sum = #list
    for i = sum, 1, - 1 do
        local v = list[i]
        item_config = Config.ItemData.data_get_data(v[1])
        if item_config then
            if self.item_list[index] == nil then
                item = BackPackItem.new(false, true, false, scale, false, true)
                _x = self.total_width -((index - 1) *(BackPackItem.Width * scale + off) + BackPackItem.Width * 0.5 * scale)
                item:setPosition(_x, _y)
                self.item_container:addChild(item)
                self.item_list[index] = item
            end
            item = self.item_list[index]
            item:setBaseData(v[1], v[2])
            item:setVisible(true)
            index = index + 1
        end
    end
end

function ArenaLoopAwardsPanel:DeleteMe()
    self:handleEvent(false)
	for i, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      赛季奖励面板的单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopAwardsItem = class("ArenaLoopAwardsItem",function()
    return ccui.Layout:create()
end)

function ArenaLoopAwardsItem:ctor()
    self.item_list = {}

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arean_loop_awards_item"))
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

function ArenaLoopAwardsItem:registerEvent()
end

function ArenaLoopAwardsItem:setData(data)
    if data ~= nil then
        if data.index ~= nil then
            if data.index <= 3 then
                self.rank_label:setVisible(false)
                if data.rank == 0 then
                    self.rank_img:setVisible(false)
                else
                    local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.index))
                    if self.rank_res_id ~= res_id then
                        self.rank_res_id = res_id
                        loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                    end
                    self.rank_img:setVisible(true)
                end
            else
                self.rank_img:setVisible(false)
                self.rank_label:setVisible(true)
                self.rank_label:setString(string.format("%s~%s", data.min, data.max))
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
        local sum = #data.items
        for i=sum,1,-1 do
            local v = data.items[i]
            item_config = Config.ItemData.data_get_data(v[1])
            if item_config then
                if self.item_list[index] == nil then
                    item = BackPackItem.new(false, true, false, scale, false, true) 
                    _x = self.total_width - ( (index-1)*(BackPackItem.Width*scale+off) + BackPackItem.Width*0.5*scale )
                    item:setPosition(_x, _y)
                    self.item_container:addChild(item)
                    self.item_list[index] = item
                end
                item = self.item_list[index]
                item:setBaseData(v[1],v[2])
                item:setVisible(true)
                index = index + 1
            end
        end
    end
end

function ArenaLoopAwardsItem:DeleteMe()
    for i,v in ipairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self:removeAllChildren()
    self:removeFromParent()
end
