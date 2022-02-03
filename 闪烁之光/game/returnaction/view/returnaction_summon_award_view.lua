--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-12-4 15:48:16
-- @description    : 
		-- 回归召唤奖励预览界面
---------------------------------

local _controller = ReturnActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

ReturnActionSummonAwardView = ReturnActionSummonAwardView or BaseClass(BaseView)

function ReturnActionSummonAwardView:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "returnaction/returnaction_summon_award"

	self.res_list = {
	}

	self.pro_config = {}
	self.num_config = {}
end

function ReturnActionSummonAwardView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
    self:playEnterAnimatianByObj(container , 2)

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("奖励详情"))

	self.time_label = container:getChildByName("time_label")

	self.close_btn = container:getChildByName("close_btn")

	local list_panel = container:getChildByName("list_panel")
	self.scroll_size = list_panel:getContentSize()
	self.desc_scrollview = createScrollView(self.scroll_size.width, self.scroll_size.height, 0, 0, list_panel)
end

function ReturnActionSummonAwardView:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openReturnActionSummonAwardView(false)
	end, false, 2)
end

function ReturnActionSummonAwardView:openRootWnd( period, data, text_elite )
	self.text_elite = text_elite or nil
	self.period = period
	self.data = data
	self:setData()
end

function ReturnActionSummonAwardView:setData(  )
	if not self.period then return end

	local container_height = 0

	local pro_config = _model:getActionSummonItemList()

	local up_con_height = 0
	if pro_config then
		-- 道具剩余数量
		if not self.title_bg_1 then
			self.title_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90090"), 0, 0, cc.p(0, 1), true, nil, true)
			self.title_bg_1:setCapInsets(cc.rect(2, 10, 2, 2))
			self.title_bg_1:setContentSize(cc.size(205, 36))
			local tempLab = TI18N("道具剩余数量")	
			local title_txt_1 = createLabel(24, 274, nil, 10, 18, tempLab, self.title_bg_1, nil, cc.p(0, 0.5))
		end

		if not self.info_bg_1 then
			self.info_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90024"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
			self.info_bg_1:setContentSize(cc.size(614, 260))
		end

		if not self.info_title_bg_1 then
			self.info_title_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90025"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
			self.info_title_bg_1:setContentSize(cc.size(610, 44))

			self.line_1 = createImage(self.info_title_bg_1, PathTool.getResFrame("common", "common_1069"), 305, 22, cc.p(0.5, 0.5), true, nil, true)
			self.line_1:setContentSize(cc.size(2, 40))

			local tempLab = TI18N("道具剩余数量")	
			local info_title_txt_1 = createLabel(24, 116, nil, 152, 22, TI18N("道具"), self.info_title_bg_1, nil, cc.p(0.5, 0.5))
			local info_title_txt_2 = createLabel(24, 116, nil, 457, 22, TI18N("剩余数量"), self.info_title_bg_1, nil, cc.p(0.5, 0.5))
		end

		
		local scroll_view_size = cc.size(584,200)
		if self.num_scrollview == nil then
			local setting = {
				start_x = 0,                     -- 第一个单元的X起点
				space_x = 0,                     -- x方向的间隔
				start_y = 0,                     -- 第一个单元的Y起点
				space_y = 5,                     -- y方向的间隔
				item_width = 584,                -- 单元的尺寸width
				item_height = 30,               -- 单元的尺寸height
				row = 1,                         -- 行数，作用于水平滚动类型
				col = 1,                         -- 列数，作用于垂直滚动类型
				once_num = 1,                    -- 每次创建的数量
			}
			
			self.num_scrollview = CommonScrollViewSingleLayout.new(self.desc_scrollview, cc.p(0,990) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 1))

			self.num_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell2), ScrollViewFuncType.CreateNewCell) --创建cell
			self.num_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells2), ScrollViewFuncType.NumberOfCells) --获取数量
			self.num_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex2), ScrollViewFuncType.UpdateCellByIndex) --更新cell
		end
		local num_config_list = {}
		for k,v in pairs(pro_config) do
			if v.cfg and v.cfg.show == 0 then
				_table_insert(num_config_list,v)
			end 
		end
		self.num_config = num_config_list
		self.num_scrollview:reloadData()

		up_con_height = 54 + scroll_view_size.height + 60

		container_height = up_con_height
	end

	-- 描述内容
	local desc_height = 0
	if self.data then
		local summon_cfg = Config.HolidayReturnNewData.data_constant.tips_1
		if summon_cfg then
			if not self.title_bg_2 then
				self.title_bg_2 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90090"), 0, 0, cc.p(0, 1), true, nil, true)
				self.title_bg_2:setCapInsets(cc.rect(2, 10, 2, 2))
				self.title_bg_2:setContentSize(cc.size(205, 36))
				
				local title_txt_2 = createLabel(24, 274, nil, 10, 18, TI18N("内容详情"), self.title_bg_2, nil, cc.p(0, 0.5))
			end
			if not self.award_desc then
				self.award_desc = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 1), cc.p(self.scroll_size.width*0.5, 430), 10, nil, 580)
				self.desc_scrollview:addChild(self.award_desc)
			end
			self.award_desc:setString(summon_cfg.desc or "")
			local desc_size = self.award_desc:getContentSize()

			desc_height = desc_size.height + 54 + 10
			container_height = container_height + desc_height
		end
	end

	-- 概率展示
	if pro_config then
		if not self.title_bg_3 then
			self.title_bg_3 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90090"), 0, 0, cc.p(0, 1), true, nil, true)
			self.title_bg_3:setCapInsets(cc.rect(2, 10, 2, 2))
			self.title_bg_3:setContentSize(cc.size(205, 36))
			local title_txt_3 = createLabel(24, 274, nil, 10, 18, TI18N("概率公示"), self.title_bg_3, nil, cc.p(0, 0.5))
		end
		

		if not self.info_bg_2 then
			self.info_bg_2 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90024"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
			self.info_bg_2:setContentSize(cc.size(614, 260))
		end

		if not self.info_title_bg_2 then
			self.info_title_bg_2 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90025"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
			self.info_title_bg_2:setContentSize(cc.size(610, 44))
			self.line_2 = createImage(self.info_title_bg_2, PathTool.getResFrame("common", "common_1069"), 305, 22, cc.p(0.5, 0.5), true, nil, true)
			self.line_2:setContentSize(cc.size(2, 40))

			local tempLab = TI18N("道具剩余数量")	
			local info_title_txt_3 = createLabel(24, 116, nil, 152, 22, TI18N("道具"), self.info_title_bg_2, nil, cc.p(0.5, 0.5))
			local info_title_txt_4 = createLabel(24, 116, nil, 457, 22, TI18N("概率"), self.info_title_bg_2, nil, cc.p(0.5, 0.5))
		end

		
		local scroll_view_size = cc.size(584,200)
		if self.pro_scrollview == nil then
			
			local setting = {
				start_x = 0,                     -- 第一个单元的X起点
				space_x = 0,                     -- x方向的间隔
				start_y = 0,                     -- 第一个单元的Y起点
				space_y = 5,                     -- y方向的间隔
				item_width = 584,                -- 单元的尺寸width
				item_height = 30,               -- 单元的尺寸height
				row = 1,                         -- 行数，作用于水平滚动类型
				col = 1,                         -- 列数，作用于垂直滚动类型
				once_num = 1,                    -- 每次创建的数量
			}
			
			self.pro_scrollview = CommonScrollViewSingleLayout.new(self.desc_scrollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 1))

			self.pro_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
			self.pro_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
			self.pro_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
		end
		
		container_height = container_height + scroll_view_size.height + 54

		self.pro_config = pro_config
		self.pro_scrollview:reloadData()
	
	end

	
		
	local max_height = math.max(self.scroll_size.height, container_height)
	max_height = max_height +  100

	self.desc_scrollview:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
	if self.title_bg_1 then
		self.title_bg_1:setPositionY(max_height)
	end

	if self.info_title_bg_1 then
		self.info_title_bg_1:setPositionY(max_height - 42)
	end

	if self.info_bg_1 then
		self.info_bg_1:setPositionY(max_height - 40)
	end
	
	
	if self.num_scrollview then
		self.num_scrollview:setPositionY(max_height-90)
	end
	if self.title_bg_2 then
		self.title_bg_2:setPositionY(max_height - up_con_height)
	end
	if self.award_desc then
		self.award_desc:setPositionY(max_height - up_con_height - 54)
	end
	if self.title_bg_3 then
		self.title_bg_3:setPositionY(max_height - up_con_height - desc_height)
	end

	if self.info_title_bg_2 then
		self.info_title_bg_2:setPositionY(max_height - up_con_height - desc_height-42)
	end

	if self.info_bg_2 then
		self.info_bg_2:setPositionY(max_height - up_con_height - desc_height-40)
	end
	if self.pro_scrollview then
		self.pro_scrollview:setPositionY(max_height - up_con_height - desc_height-90)
	end
	
	
	
	-- 活动时间
	if self.data then
		local start_time = TimeTool.getYMD(self.data.starttime)
		local end_time = TimeTool.getYMD(self.data.endtime)
		self.time_label:setString(string.format(TI18N("概率有效期：%s~%s"), start_time, end_time))
	end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ReturnActionSummonAwardView:createNewCell2()
	local cell = ReturnActionSummonAwardItem.new()
	return cell
 end
 --获取数据数量
 function ReturnActionSummonAwardView:numberOfCells2()
	 if not self.num_config then return 0 end
	 return #self.num_config
 end
 --更新cell(拖动的时候.刷新数据时候会执行次方法)
 --cell :createNewCell的返回的对象
 --index :数据的索引
 function ReturnActionSummonAwardView:updateCellByIndex2(cell, index)
	 cell.index = index
	 local cell_data = self.num_config[index]
	 if not cell_data then return end
	 local time_desc = cell:setData(cell_data,1)
 end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ReturnActionSummonAwardView:createNewCell()
	local cell = ReturnActionSummonAwardItem.new()
	return cell
 end
 --获取数据数量
 function ReturnActionSummonAwardView:numberOfCells()
	 if not self.pro_config then return 0 end
	 return #self.pro_config
 end
 --更新cell(拖动的时候.刷新数据时候会执行次方法)
 --cell :createNewCell的返回的对象
 --index :数据的索引
 function ReturnActionSummonAwardView:updateCellByIndex(cell, index)
	 cell.index = index
	 local cell_data = self.pro_config[index]
	 if not cell_data then return end
	 local time_desc = cell:setData(cell_data,2)
 end

function ReturnActionSummonAwardView:close_callback(  )
	doStopAllActions(self.desc_scrollview)
	if self.pro_scrollview then
        self.pro_scrollview:DeleteMe()
    end
	self.pro_scrollview = nil

	if self.num_scrollview then
        self.num_scrollview:DeleteMe()
    end
	self.num_scrollview = nil
	
	_controller:openReturnActionSummonAwardView(false)
end

-------------------@ item 
ReturnActionSummonAwardItem = class("ReturnActionSummonAwardItem", function()
    return ccui.Widget:create()
end)

function ReturnActionSummonAwardItem:ctor()
    self:configUI()
    self:register_event()
end

function ReturnActionSummonAwardItem:configUI(  )
	self.size = cc.size(584, 30)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0, 1))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.name_text = createLabel(24, 274, nil, 169, self.size.height/2, "", self.root_wnd, nil, cc.p(0.5, 0.5))--名字
    self.num_text = createLabel(24, 274, nil, 473, self.size.height/2, "", self.root_wnd, nil, cc.p(0.5, 0.5))--概率
end

function ReturnActionSummonAwardItem:register_event(  )
	
end

function ReturnActionSummonAwardItem:setData( data ,type)
	if not data then return end

	self.name_text:setTextColor(Config.ColorData.data_color4[274])
	self.num_text:setTextColor(Config.ColorData.data_color4[274])
	local item_config = Config.ItemData.data_get_data(data.itemId)
	if item_config then
		self.name_text:setString(string.format( "%s*%d",item_config.name,data.itemNum ) )
		if type == 1 then
			self.name_text:setTextColor(BackPackConst.getWhiteQualityColorC4B(item_config.quality))	
		end
	end
	
	if type == 1 then --1:道具剩余类型  2：道具详细类型
		local count,sum = _model:getActionSummonItemNumById(data.itemId)
		self.num_text:setString(string.format( "%d/%d",sum-count,sum ))--数量	
	else
		self.num_text:setString(data.show_pro .. "%")--概率	
	end
	
end

function ReturnActionSummonAwardItem:DeleteMe(  )
	self:removeAllChildren()
    self:removeFromParent()
end