--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-21 10:58:07
-- @description    : 
		-- 先知殿预览
---------------------------------
SeerpalacePreviewWindow = SeerpalacePreviewWindow or BaseClass(BaseView)
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local controller = SeerpalaceController:getInstance()
local model = controller:getModel()
--[[
tag:默认为nil，是先知这个，1是主城召唤
]]
function SeerpalacePreviewWindow:__init(tag)
	self.win_type = WinType.Mini
	self.is_full_screen = true
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "seerpalace/seerpalace_preview_window"
	--[[self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("mall", "mall"), type = ResourcesType.plist },
    }--]]
    self.summon_tag = tag or nil
end

function SeerpalacePreviewWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
    self:playEnterAnimatianByObj(container , 2)

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("奖励预览"))

	self.list_panel = container:getChildByName("list_panel")
	self.scroll_view_size = self.list_panel:getContentSize()
	self.scroll_view = createScrollView(self.scroll_view_size.width, self.scroll_view_size.height, 0, 0, self.list_panel, ccui.ScrollViewDir.vertical)

end

function SeerpalacePreviewWindow:openRootWnd( index )
	if self.summon_tag == 1 then
		self:setSummonData(index)
	else
		self.group_id = SeerpalaceConst.Index_To_GroupId[index]
		if self.group_id then
			self:setData()
		end
	end
end

function SeerpalacePreviewWindow:setData(  )
	local award_config = Config.RecruitHighData.data_seerpalace_award[self.group_id]
	if award_config then
		local five_star_config = award_config[5]
		local four_star_config = award_config[4]

		local scale = 0.9
		local desc_height = 60  --概率描述的高度
		local row = 4 -- 5列宝可梦
		local start_x = 22
		local space_x = 35
		local space_y = 30
		local offset_y = 40 -- 两种星级之间的间隔
		local content_h = 0
		local label_width = 530
		for k,v in pairs(award_config) do
			if v.desc and v.desc ~= "" then
				content_h = content_h + desc_height
			end
			local item_num = #v.items -- 数量
			local item_col = math.ceil(item_num/row) -- 行数
			content_h = content_h + BackPackItem.Height*scale*item_col + (item_col-1)*space_y + offset_y
		end
		local max_height = math.max(content_h, self.scroll_view_size.height)
		self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view_size.width, max_height))

		-- 5星
		local desc_txt_1 = createLabel(22,Config.ColorData.data_new_color4[6],nil,start_x,max_height,five_star_config.desc,self.scroll_view,nil,cc.p(0, 1))
		local desc_txt_1_size = desc_txt_1:getContentSize()
		local rows = math.ceil(desc_txt_1_size.width / label_width)
		local desc_1_height = desc_txt_1_size.height * rows
		desc_txt_1:setDimensions(label_width, desc_1_height)
		for i,v in ipairs(five_star_config.items) do
			delayRun(self.list_panel, i/60, function ()
				local bid = v[1]
				local num = v[2]
				local summon_num = v[3] or 0
				local item_node = BackPackItem.new(false,true)
				item_node:setAnchorPoint(cc.p(0,1))
				item_node:setScale(0.9)
		        item_node:setBaseData(bid,num)
		        item_node:setSummonNumber(summon_num)
		        item_node:setDefaultTip()
		        local row_index = i%row
		        if row_index == 0 then
		        	row_index = row
		        end
		        local col_index = math.ceil(i/row)
		        local pos_x = start_x + (row_index-1)*(BackPackItem.Width*scale+space_x)
		        local pos_y = max_height - desc_1_height - (col_index-1)*(BackPackItem.Height*scale+space_y) - 1
		        item_node:setPosition(cc.p(pos_x, pos_y))
		        self.scroll_view:addChild(item_node)
			end)
		end

		-- 4星
		local start_y = max_height - desc_1_height - (math.ceil(#five_star_config.items/row))*(BackPackItem.Height*scale+space_y) + space_y - offset_y
		local desc_txt_2 = createLabel(22,Config.ColorData.data_new_color4[6],nil,start_x,start_y,four_star_config.desc,self.scroll_view,nil,cc.p(0, 1))
		local desc_txt_2_size = desc_txt_2:getContentSize()
		local rows = math.ceil(desc_txt_2_size.width / label_width)
		local desc_2_height = desc_txt_2_size.height * rows
		desc_txt_2:setDimensions(label_width, desc_2_height)
		for i,v in ipairs(four_star_config.items) do
			delayRun(self.list_panel, i/60, function (  )
				local bid = v[1]
				local num = v[2]
				local summon_num = v[3] or 0
				local item_node = BackPackItem.new(false,true)
				item_node:setAnchorPoint(cc.p(0,1))
				item_node:setScale(0.9)
		        item_node:setBaseData(bid,num)
		        item_node:setSummonNumber(summon_num)
		        item_node:setDefaultTip()
		        local row_index = i%row
		        if row_index == 0 then
		        	row_index = row
		        end
		        local col_index = math.ceil(i/row)
		        local pos_x = start_x + (row_index-1)*(BackPackItem.Width*scale+space_x)
		        local pos_y = start_y - desc_2_height - (col_index-1)*(BackPackItem.Height*scale+space_y) - 6
		        item_node:setPosition(cc.p(pos_x, pos_y))
		        self.scroll_view:addChild(item_node)
			end)
		end
	end
end

function SeerpalacePreviewWindow:setSummonData(index)
	local summon_data = Config.RecruitData.data_summon_data
	if summon_data and summon_data[SeerpalaceConst.Summon_Index[index]] then
		local tab = {}
		for i,v in pairs(summon_data[SeerpalaceConst.Summon_Index[index]]) do
			table_insert(tab,v)
		end
		table_sort(tab,function(a,b) return a.base_id < b.base_id end)
		
		local scale = 0.9
		local space_y = 40
		local content_h = space_y + (BackPackItem.Height*scale+30) * math.ceil(#tab/4)
		local max_height = math.max(content_h, self.scroll_view_size.height)
		self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view_size.width, max_height))
		for i,v in pairs(tab) do
			delayRun(self.list_panel, i/60, function()
				local item_node = BackPackItem.new(false,true)
				item_node:setAnchorPoint(cc.p(0,1))
				item_node:setScale(scale)
		        item_node:setBaseData(v.base_id)
		        item_node:showItemEffect(false)
		        item_node:setSummonNumber(string_format("%0.3f",v.summon_desc))
		        item_node:setDefaultTip()
		        local pos_x = 30 + (BackPackItem.Width*scale + 30) * ((i-1)%4)
		        local pos_y = max_height - ((BackPackItem.Height*scale + 30) * math.floor((i-1)/4))
		        item_node:setPosition(cc.p(pos_x, pos_y))
				self.scroll_view:addChild(item_node)
			end)
		end
	end
end
function SeerpalacePreviewWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
end

function SeerpalacePreviewWindow:_onClickBtnClose(  )
	controller:openSeerpalacePreviewWindow(false)
end

function SeerpalacePreviewWindow:close_callback(  )
	self.list_panel:stopAllActions()
	controller:openSeerpalacePreviewWindow(false)
end