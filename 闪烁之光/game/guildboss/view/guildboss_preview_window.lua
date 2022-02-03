-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会副本boss的预览窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
--GuildBossPreviewWindow = GuildBossPreviewWindow or BaseClass(BaseView)
GuildBossPreviewWindow = class("GuildBossPreviewWindow", function()
	return ccui.Layout:create()
end)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format

function GuildBossPreviewWindow:ctor()
	self.monster_list = {}				-- 存储怪物相关显示数据的
	self.is_first_enter = true
	-- self._getIndex = 1
	self:open_callback()
end 

function GuildBossPreviewWindow:open_callback()
	self.main_view = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_preview_window"))
	self:addChild(self.main_view) 



	self:register_event()

end

function GuildBossPreviewWindow:register_event()

end

function GuildBossPreviewWindow:updateScrollViewList()
    if self.scroll_view == nil then
        self.scroll_container = self.main_view:getChildByName("scroll_container")
        self.scroll_size = self.scroll_container:getContentSize()
        local list_setting = {
            -- item_class = GuildBossPreviewItem,
            start_x = 7,
            space_x = 2,
            start_y = 4,
            space_y = 0,
            item_width = 100,
            item_height = 90,
            row = 1,
            col = 0,
            delay = 5
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, self.scroll_size, list_setting, cc.p(0, 0)) 

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    self.cell_data_list, select_index = self:getCellData()
    self.scroll_view:reloadData(select_index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GuildBossPreviewWindow:createNewCell(width, height)
    local cell = GuildBossPreviewItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function GuildBossPreviewWindow:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function GuildBossPreviewWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data, index)
    if self.cur_index == index then
        cell:setSelect(true)
    else
        cell:setSelect(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function GuildBossPreviewWindow:onCellTouched(cell)
    local index = cell.index
    local data = self.cell_data_list[index]
    if data then
        if data.status == 2 or data.status == 3 then
            message(TI18N("通关上一章开启"))
        else
            local config = Config.GuildDunData.data_guildboss_list[data.show_id]
            if config then
                local boss_id = config.boss_id
                self:clickOpen(cell,index,true)
                local protocal = {boss_id = boss_id, start_num = 1, end_num = 100}
                GuildbossController:getInstance():requestGuildDunRank(GuildBossConst.rank.role, protocal)
            end
        end
    end
end

function GuildBossPreviewWindow:getCellData()
	local base_info = model:getBaseInfo()
    local item_list = {}
    local select_index = nil
	if base_info and next(base_info or {}) ~= nil then
		local is_first_lock = false
        local max_id = Config.GuildDunData.data_chapter_reward[#Config.GuildDunData.data_chapter_reward].id
		for i,v in ipairs(Config.GuildDunData.data_chapter_reward) do
			local object = {}
			object.desc = string_format("%s", v.chapter_name)
			object.show_id = v.show_id
			if base_info.fid and base_info.fid == v.id then	-- 进行中
                select_index = i
				object.status = 0
                if base_info.max_id == v.id and max_id == v.id then --最后一关了
                    if base_info.info and next(base_info.info) ~= nil then
                        if base_info.info[1].hp and base_info.info[1].hp == 0 then
                            object.status = 1
                        end
                    end
                end
			elseif base_info.fid > v.id then -- 已通关
				object.status = 1
			else
				if is_first_lock == false then	-- 第一个未通关的，做文本显示
					object.status = 3
					is_first_lock = true
				else
					object.status = 2 
				end
			end
			item_list[i] = object
		end
	end
    return item_list, select_index
end

function GuildBossPreviewWindow:clickOpen(cell, k, is_change)
	if (self.cur_index and self.cur_index == k) and is_change == true then
		return 
	end
	if self.cur_select ~= nil and (self.cur_index and self.cur_index ~= k) then
        self.cur_select:setSelect(false)
    end
	self.cur_select = cell
	
	self.cur_index = k
	self.cur_select:setSelect(true)
	
    if not self.is_first_enter then
        local data = self.cell_data_list[self.cur_index]
		GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateChangeStatus,data)		
	end
	self.is_first_enter = false
end



function GuildBossPreviewWindow:DeleteMe()
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end 
	--controller:openGuildBossPreviewWindow(false) 
end


function GuildBossPreviewWindow:getCurSelect()
	if self.cur_select then
		return self.cur_select 
	end
end

-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      boss总览的单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossPreviewItem = class("GuildBossPreviewItem", function()
	return ccui.Layout:create()
end)
function GuildBossPreviewItem:ctor()
	self.boss_id = 0

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_preview_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self:setTouchEnabled(true)
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

	self.center_x = self.size.width * 0.5
	self.boss_icon = PlayerHead.new(PlayerHead.type.circle)
	self.boss_icon:setAnchorPoint(0.5, 0.5)
	self.boss_icon:setScale(0.8)
	self.boss_icon:setPosition(self.center_x,self.size.height/2)
	self.root_wnd:addChild(self.boss_icon,-1)

	self.model = self.root_wnd:getChildByName("model")
	self.pass_icon = self.root_wnd:getChildByName("pass_icon")
	self.chapter_value = self.root_wnd:getChildByName("chapter_value")
	self.status_value = self.root_wnd:getChildByName("status_value")
    self.status_value:setVisible(false)
	self.lock_icon = self.root_wnd:getChildByName("lock_icon")
    self.lock_icon:setScale(0.8)
	self:registerEvent()
end

function GuildBossPreviewItem:setData(data, index)
	if data ~= nil then
		self.data = data
		self.chapter_value:setString(data.desc)
		self:updateMonsterInfo(data.show_id, data.status) 

		self.pass_icon:setVisible(false)
		local temp_index = math.min(index - 1,tableLen(Config.GuildDunData.data_chapter_reward))
		if data.status == 0 then	
            self.lock_icon:setVisible(false)
            -- self.status_value:setVisible(false)                  -- 进行中
   --          self.status_value:enableOutline(Config.ColorData.data_color4[178],1) 
            -- self.status_value:setString(TI18N("进行中"))
        elseif data.status == 1 then                    -- 已打通
            self.pass_icon:setVisible(true)
            self.lock_icon:setVisible(false)
            -- self.status_value:setVisible(false)
        elseif data.status == 2 then                    -- 未开通，只需要显示锁状态，不需要文字提示
            self.lock_icon:setVisible(true)
   --          self.status_value:enableOutline(Config.ColorData.data_color4[183],2) 
            -- self.status_value:setVisible(true)
            -- self.status_value:setString(TI18N('通关')..Config.GuildDunData.data_chapter_reward[temp_index].chapter_name)
        else
            self.lock_icon:setVisible(true)
   --          self.status_value:enableOutline(Config.ColorData.data_color4[183],2) 
			-- self.status_value:setVisible(true)											-- 未开启，需要显示文字提示的状态
			-- self.status_value:setString(TI18N('通关')..Config.GuildDunData.data_chapter_reward[temp_index].chapter_name)
		end
	end
end

function GuildBossPreviewItem:updateMonsterInfo(boss_id, status)
	local config = Config.GuildDunData.data_guildboss_list[boss_id]
	self.data.config = config 
	if config == nil then return end
	--if self.boss_id ~= boss_id then
		self.boss_id = boss_id
		self.boss_icon:setHeadRes(config.head_icon)
		setChildUnEnabled(false, self.boss_icon)
		if status == 2 or status == 3 then		-- 这个时候表示锁住的
			setChildUnEnabled(true,self.boss_icon)
		end
	--end 
end

function GuildBossPreviewItem:addCallBack(value)
    self.callback = value
end

function GuildBossPreviewItem:registerEvent()
    self:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self.touch_end = sender:getTouchEndPosition()
                local is_click = true
                if self.touch_began ~= nil then
                    is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
                end
                if is_click == true then
                    playButtonSound2()
                    if self.callback then
                        self:callback()
                    end
                end
            elseif event_type == ccui.TouchEventType.moved then
            elseif event_type == ccui.TouchEventType.began then
                self.touch_began = sender:getTouchBeganPosition()
            elseif event_type == ccui.TouchEventType.canceled then
            end
        end
    )
end

function GuildBossPreviewItem:getData()
    return self.data
end

function GuildBossPreviewItem:setSelect(status)
	if status and  not self.select_img then
		self.select_img = createSprite(PathTool.getResFrame("guildboss","guildboss_1018"),50,45,self.root_wnd,cc.p(0.5,0.5))
		self.root_wnd:setLocalZOrder(-1)
	end

	if self.select_img then
        if status then
            breatheShineAction(self.select_img)
        else
            doStopAllActions(self.select_img)
        end
		self.select_img:setVisible(status)
	end
end
function GuildBossPreviewItem:getIsShow()
    return self.is_show
end

function GuildBossPreviewItem:getItemPosition()
    if self then
        return cc.p(self:getPosition())
    end
end


function GuildBossPreviewItem:DeleteMe()
	if self.spine then
		self.spine:DeleteMe()
		self.spine = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end
