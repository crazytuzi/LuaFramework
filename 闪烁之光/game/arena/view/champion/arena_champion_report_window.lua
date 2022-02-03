-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛战报界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

ArenaChampionReportWindow = ArenaChampionReportWindow or BaseClass(BaseView)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel()
local table_insert = table.insert 

function ArenaChampionReportWindow:__init(view_type)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Big
	self.layout_name = "arena/arena_champion_report_window"
	self.res_list = {
	}

	self.view_type = view_type or ArenaConst.champion_type.normal
end 

function ArenaChampionReportWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
    local main_panel = main_container:getChildByName("main_panel")
	main_panel:getChildByName("win_title"):setString(TI18N("数据统计"))
	for i=1,3 do
		local desc = main_panel:getChildByName("desc_"..i)
		if desc then
			if i == 1 then
				desc:setString(TI18N("伤害"))
			elseif i == 2 then
				desc:setString(TI18N("承受伤害"))
			else
				desc:setString(TI18N("治疗"))
			end
		end
	end

	self.item = main_panel:getChildByName("item")
	self.item:setVisible(false)

	self.close_btn = main_panel:getChildByName("close_btn")

	self.top_list_view = main_panel:getChildByName("top_list_view")
	self.bottom_list_view = main_panel:getChildByName("bottom_list_view")
	self.check_btn = main_panel:getChildByName("check_btn")

	self.top_name = main_panel:getChildByName("top_name")
	self.bottom_name = main_panel:getChildByName("bottom_name")

	self.success_img = main_panel:getChildByName("success_img")
	self.top_y = 702
	self.bottom_y = 360
end

function ArenaChampionReportWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaChampionReportWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaChampionReportWindow(false)
		end
	end)
	self.check_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.replay_id ~= 0 then
				if self.view_type == ArenaConst.champion_type.cross then
					local base_info = CrosschampionController:getInstance():getModel():getBaseInfo()
					if base_info then
						BattleController:getInstance():csRecordBattle(self.data.replay_id, base_info.srv_id) 
					else
						BattleController:getInstance():csRecordBattle(self.data.replay_id) 
					end
				else
					BattleController:getInstance():csRecordBattle(self.data.replay_id) 
				end
			end
		end
	end)
end

function ArenaChampionReportWindow:openRootWnd(data)
	if data == nil then return end
	self.data = data
	self:setBaseInfo()
	self:setTopInfo()
	self:setBottomInfo()
end

function ArenaChampionReportWindow:setBaseInfo()
	self.success_img:setVisible(self.data.ret ~= 0)
	if self.data.ret == 1 then
		self.success_img:setPositionY(self.top_y)
	elseif self.data.ret == 2 then
		self.success_img:setPositionY(self.bottom_y)
	end
	self.top_name:setString(self.data.a_name or "")
	self.bottom_name:setString(self.data.b_name or "")
end

function ArenaChampionReportWindow:setTopInfo()
	local total_hurt = 0		-- 总伤害
	local total_behurt = 0		-- 总被伤害
	local total_curt = 0		-- 总治疗
	for i,v in ipairs(self.data.a_plist) do
		total_hurt = total_hurt + v.hurt
		total_behurt = total_behurt + v.behurt
		total_curt = total_curt + v.curt
	end

	if self.top_scroll_view == nil then
		local size = self.top_list_view:getContentSize()
		local setting = {
			item_class = ArenaChampionReportItem,
			start_x = 0,
			space_x = 0,
			start_y = 0,
			space_y = 0,
			item_width = 122,
			item_height = 278,
			row = 1,
			col = 1,
		}
		self.top_scroll_view = CommonScrollViewLayout.new(self.top_list_view, nil, ScrollViewDir.horizontal, nil, size, setting)
	end
	self.top_scroll_view:setVisible(true)
	self.top_scroll_view:setData(self.data.a_plist, nil, nil, {total_hurt = total_hurt, total_behurt = total_behurt, total_curt = total_curt, node = self.item}) 
end

function ArenaChampionReportWindow:setBottomInfo()
	local total_hurt = 0		-- 总伤害
	local total_behurt = 0		-- 总被伤害
	local total_curt = 0		-- 总治疗
	for i,v in ipairs(self.data.b_plist) do
		total_hurt = total_hurt + v.hurt
		total_behurt = total_behurt + v.behurt
		total_curt = total_curt + v.curt
	end
	if self.bottom_scroll_view == nil then
		local size = self.bottom_list_view:getContentSize()
		local setting = {
			item_class = ArenaChampionReportItem,
			start_x = 0,
			space_x = 0,
			start_y = 0,
			space_y = 0,
			item_width = 122,
			item_height = 278,
			row = 1,
			col = 1,
		}
		self.bottom_scroll_view = CommonScrollViewLayout.new(self.bottom_list_view, nil, ScrollViewDir.horizontal, nil, size, setting)
	end
	self.bottom_scroll_view:setVisible(true)
	self.bottom_scroll_view:setData(self.data.b_plist, nil, nil, {total_hurt = total_hurt, total_behurt = total_behurt, total_curt = total_curt, node = self.item}) 
end

function ArenaChampionReportWindow:close_callback()
	if self.top_scroll_view then
		self.top_scroll_view:DeleteMe()
	end
	self.top_scroll_view = nil
	if self.bottom_scroll_view then
		self.bottom_scroll_view:DeleteMe()
	end
	self.bottom_scroll_view = nil
    controller:openArenaChampionReportWindow(false)
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛当前排行榜的分列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionReportItem = class("ArenaChampionReportItem", function()
	return ccui.Layout:create()
end)

function ArenaChampionReportItem:ctor()
	self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function ArenaChampionReportItem:setExtendData(data)
	self.total_hurt = data.total_hurt
	self.total_behurt = data.total_behurt
	self.total_curt = data.total_curt

	local node = data.node	
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

		for i=1,3 do
			self["progress_"..i] = self.root_wnd:getChildByName("progress_"..i)	-- 进度条
			if self["progress_"..i] then
				self["progress_"..i]:setScale9Enabled(true) 
			end
			self["desc_"..i] = self.root_wnd:getChildByName("desc_"..i)			-- 描述
		end

		self.partner_item = HeroExhibitionItem.new(0.8, false) 
		self.partner_item:setPosition(61, 198)
		self.root_wnd:addChild(self.partner_item)
	end
end


function ArenaChampionReportItem:setData(data)
	if data then
		self.partner_item:setData(data, true)
		-- local config = Config.PartnerData.data_partner_base[data.bid]
		-- if config then
		-- 	self.partner_item:showCareerType(config.type)
		-- end
		self.desc_1:setString(data.hurt)
		self.desc_2:setString(data.behurt)
		self.desc_3:setString(data.curt)
		if self.total_hurt == 0 then
			self.progress_1:setPercent(0)
		else
			self.progress_1:setPercent(100*data.hurt/self.total_hurt) 
		end
		if self.total_behurt == 0 then
			self.progress_2:setPercent(0)
		else
			self.progress_2:setPercent(100*data.behurt/self.total_behurt) 
		end
		if self.total_curt == 0 then
			self.progress_3:setPercent(0)
		else
			self.progress_3:setPercent(100*data.curt/self.total_curt) 
		end
	end
end

function ArenaChampionReportItem:DeleteMe()
	if self.partner_item then
		self.partner_item:DeleteMe()
		self.partner_item = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end 