-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      七天排行面板
-- Create: 2018-06-28
-- --------------------------------------------------------------------
ActionSevenRankWindow = ActionSevenRankWindow or BaseClass(BaseView)

local string_format = string.format
local controller = ActionController:getInstance()
local model = ActionController:getInstance():getModel()
local string_find = string.find

function ActionSevenRankWindow:__init()
    self.win_type = WinType.Full  
    self.layout_name = "action/action_seven_rank_window"    
    self.res_list = {
    	{ path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg"), type = ResourcesType.single },
    	{ path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist }, 
    	{ path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
	}

    self.tab_list = {}
    self.cur_select = nil
    self.cur_index = nil
    self.rank_list = {}

	-- 前3名的展示数据
	self.top_3_list = {}
end

function ActionSevenRankWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
    	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg"), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.tab_container = self.main_container:getChildByName("tab_container")
    
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.container = self.main_panel:getChildByName("container")
    self.close_btn = self.main_panel:getChildByName("close_btn")

	-- 前3名的如节点
	self.top_3_view = self.container:getChildByName("top_3_view")
	self.top_3_y = self.top_3_view:getPositionY()
	for i=1,3 do
		local no_con = self.top_3_view:getChildByName(string_format("no%s_con", i))
		if no_con then
			local name = no_con:getChildByName("name")
			local srcoll_con = no_con:getChildByName("srcoll_con")

			local honor = nil
			local crown = nil
			if i == 1 then
				honor = createImage(no_con, nil, no_con:getContentSize().width/2+40, 130, cc.p(0.5,0.5), false, 1, false)
				honor:setScale(0.9)
				honor:setTouchEnabled(true)

				crown = no_con:getChildByName("crown")
				crown:setLocalZOrder(20)
				crown:setVisible(false)
			end

   			local scroll_view_size = srcoll_con:getContentSize()
			local setting = {
				item_class = BackPackItem,
				start_x = 10,
				space_x = 6,
				start_y = 4,
				space_y = 0,
				item_width = BackPackItem.Width*0.7,
				item_height = BackPackItem.Height*0.7,
				row = 1,
				col = 1,
				scale = 0.7,
			}
			local goods_scrollview = CommonScrollViewLayout.new(srcoll_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)

			local head = PlayerHead.new(PlayerHead.type.circle)
			head:setAnchorPoint(0.5,0.5)
			head:setScale(0.8)
			if i == 1 then
				head:setPosition(595,85)
			else
				head:setPosition(595,74)
			end
			no_con:addChild(head)

			local object = {}
			object.name = name
			object.honor = honor
			object.crown = crown
			object.item_scroll = goods_scrollview
			object.head = head
			object.data = {}
			object.head:setVisible(false)
			object.name:setVisible(false)
			self.top_3_list[i] = object
		end
	end

    self.desc_con = self.container:getChildByName("desc_con")
    self.goto_btn = self.desc_con:getChildByName("goto_btn")
    self.goto_btn:setTitleText(TI18N("前往"))
	self.goto_btn.label = self.goto_btn:getTitleRenderer()
    if self.goto_btn.label ~= nil then
        self.goto_btn.label:enableOutline(Config.ColorData.data_color4[177], 2)
    end
    self.uplev_btn = self.desc_con:getChildByName("uplev_btn")
    self.rank_name = self.desc_con:getChildByName("rank_name")
    self.desc = createRichLabel(22, 1, cc.p(0,1), cc.p(15,120), 0, 0, 440)
    self.desc_con:addChild(self.desc)

	self.tips_button = self.desc_con:getChildByName("tips_button")

    --标签栏
    local rank_title = self.container:getChildByName("rank_title")
    rank_title:setString(TI18N("排名"))
    local reward_title = self.container:getChildByName("reward_title")
    reward_title:setString(TI18N("奖励"))
    local name_title = self.container:getChildByName("name_title")
    name_title:setString(TI18N("玩家姓名"))

    local my_rank_title = self.desc_con:getChildByName("my_rank_title")
    my_rank_title:setString(TI18N("我的排名："))
    self.my_rank = self.desc_con:getChildByName("my_rank")
    self.rank_time_title = self.desc_con:getChildByName("rank_time_title")
    self.rank_time_title:setString(TI18N("结算时间："))
    self.rank_time_title:setVisible(false)
    self.rank_time = self.desc_con:getChildByName("rank_time")

    self.detail_btn = self.container:getChildByName("detail_btn")
    self.detail_btn:setTitleText(TI18N("详细排行"))
	self.detail_btn.label = self.detail_btn:getTitleRenderer()
    if self.detail_btn.label ~= nil then
        self.detail_btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end

    self.scroll_con = self.container:getChildByName("scroll_con")
    local scroll_view_size = self.scroll_con:getContentSize()
    local setting = {
        item_class = ActionSevenRankItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 2,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = ActionSevenRankItem.Width,               -- 单元的尺寸width
        item_height = ActionSevenRankItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.scroll_con, cc.p(0, scroll_view_size.height) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 1))
    self.tab_scroll = createScrollView(self.tab_container:getContentSize().width,self.tab_container:getContentSize().height,0,0,self.tab_container,ccui.ScrollViewDir.horizontal)
end

function ActionSevenRankWindow:openRootWnd( index )
	controller:sender22700(0)
	self.index = index or 1 
end

function ActionSevenRankWindow:createTabBtn( list  )
	self.tab_scroll:setInnerContainerSize(cc.size((ActionSevenRankTab.Width+10)*12,self.tab_scroll:getContentSize().height))
	local show_list = {}
	local temp = controller:getModel():getCrossServerRankListData(0)
	for k,v in pairs(temp) do
		v[1].status = 1 --0进行中1未开启2结束
		for a,j in pairs(list) do
			if j.id == v[1].id then 
				v[1].end_time = j.end_time
				local less = j.end_time-GameNet:getInstance():getTime()
				if less>0 then 
					v[1].status = 0
				elseif less <= 0 then 
					v[1].status = 2
				end
			end
		end
		table.insert(show_list,v[1])
	end

	table.sort(show_list,SortTools.tableLowerSorter({"status","id"}))

	self.index = show_list[1].id
	local status = show_list[1].status
	for i,v in pairs(show_list) do
		if self.tab_list[v.id] == nil then 
			local item = ActionSevenRankTab.new()
			item:setPosition(10+(ActionSevenRankTab.Width+10)*(i-1),2)
			self.tab_scroll:addChild(item)
			self.tab_list[v.id] = item 
			self.tab_list[v.id]:addCallBack(function ( cell )
				local index = cell:getIndex()
				self:selectByTab(index,cell.status)
			end)
		end
		if self.index ~= v.id then
			local status = self:checkHaveFinishTask(v.id)
			self.tab_list[v.id]:setRedPointStatus(status)
		end
		self.tab_list[v.id]:setData(v)
		self.tab_list[v.id]:setIsTouch(v.status~=1)
		
	end
	self:selectByTab(self.index,status)
end

function ActionSevenRankWindow:selectByTab( index,status)
	if self.cur_index == index then return end
	self.cur_index = index
	if self.cur_select ~= nil then
		self.cur_select:setSelect(false)
	end
	self.cur_select = self.tab_list[index] 
	self.cur_select:setSelect(true)
	self.desc:setString(Config.DaysRankData.data_rank_list[index][1].tips_rule)
	self.rank_name:setString(Config.DaysRankData.data_rank_list[index][1].name)
	self.tips_button:setPositionX(self.rank_name:getPositionX()+self.rank_name:getContentSize().width + 30)

	self:setLessTime(0)
	if status == 1 then --未开启的
		self.rank_time:setString(TI18N('暂未开启'))
	end

	self.my_rank:setString(TI18N(""))

	-- 设置前3名的基础显示
	self:setTop3BaseInfo()

	-- 设置每日任务以及4名之后的显示
	self:fileSevenRankInfo()

	-- 切换标签页的时候就要请求一下22701
	controller:sender22701(self.cur_index)

end

function ActionSevenRankWindow:fileSevenRankInfo()
	if self.cur_index == nil then return end

	-- 这里显示从第4名开始,,,,可能需要前面插入每日任务
	local show_list = {}

	local is_show_redpoint = false
	local quest_list = deepCopy(Config.DaysRankData.data_rank_quest[self.cur_index])
	if quest_list then
		for i,v in ipairs(quest_list) do
			local quest_vo = model:getSevenQuestByID(v.id)
			if quest_vo and quest_vo.finish ~= TaskConst.task_status.completed then
				v.is_quest = true
				table.insert(show_list,v)
				if quest_vo.finish == TaskConst.task_status.finish then
					is_show_redpoint = true
				end
			end
		end
	end

	--因为提交任务..会刷新fileSevenRankInfo --在这里处理红点 
	if self.tab_list[self.cur_index] then
		self.tab_list[self.cur_index]:setRedPointStatus(is_show_redpoint)
	end

	local temp = deepCopy(Config.DaysRankData.data_rank_data[self.cur_index])
	for a,j in pairs(temp) do
		if j.high > 3 then 
			j.is_quest = false
			table.insert(show_list,j)
		end
	end

	self.item_scrollview:setData(show_list)
end

--检查是否有完成的任务 self.cur_index == index
function ActionSevenRankWindow:checkHaveFinishTask(index)
	local quest_list = Config.DaysRankData.data_rank_quest[index]
	if quest_list then
		for i,v in ipairs(quest_list) do
			local quest_vo = model:getSevenQuestByID(v.id)
			if quest_vo and quest_vo.finish == TaskConst.task_status.finish then
				return true
			end
		end
	end
	return false
end

function ActionSevenRankWindow:register_event(  )
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				controller:openSevenRankWin(false)
			end
		end)
	end

	self.uplev_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
			--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
		end
	end)

	self.detail_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.rank_list[self.cur_index] and next(self.rank_list[self.cur_index])~=nil then 
				RankController:getInstance():openRankView(true,Config.DaysRankData.data_rank_list[self.cur_index][1].jump)
			else
				message(TI18N("该排行榜暂无数据"))
			end
		end
	end)

	if self.tips_button then
		self.tips_button:addTouchEventListener(function ( sender,event_type )
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if Config.DaysRankData.data_rank_list[self.cur_index] then
					local str =Config.DaysRankData.data_rank_list[self.cur_index][1].tips_str
					TipsManager:getInstance():showCommonTips(str, sender:getTouchBeganPosition())
				end
			end
		end)
	end

	self.goto_btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			local config = Config.DaysRankData.data_rank_list[self.cur_index]
			if config and config[1] then
				BackpackController:getInstance():gotoItemSources(config[1].evt_type, config[1].extend)
			end
		end
	end)

	-- 设置点击
	for k,object in pairs(self.top_3_list) do
		if object.honor then
			object.honor:addTouchEventListener(function ( sender,event_type )
				if event_type == ccui.TouchEventType.ended then
					playButtonSound2()
					if self.cur_index then 
						local face_id = Config.DaysRankData.data_rank_data_const["rank_title"..self.cur_index].val
						local config = Config.HonorData.data_title[face_id]
						TipsManager:getInstance():showFaceTips( 3,config,cc.p(465,788) )
					end
				end
			end)
		end

		if object.head then
			object.head:addCallBack(function (  )
				if object.data then 
					FriendController:getInstance():openFriendCheckPanel(true, object.data)
				end
			end)
		end
	end

	--获取七天排行列表
	if not self.update_tab then 
		self.update_tab = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVEN_RANK_LIST,function ( data )
			self:createTabBtn(data.rank_list)
			-- dump(data)
		end)
	end
	--获取单个排行榜信息
	if not self.update_single_rank then 
		self.update_single_rank = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVEN_RANK_DATA,function ( data )
			self.rank_list[self.cur_index] = data.rank_list
			if data.rank~=0 then 
				self.my_rank:setString(data.rank)
			else
				self.my_rank:setString(TI18N("未上榜"))
			end		
			local time = TimeTool.GetTimeFormat(data.end_time - GameNet:getInstance():getTime())
			self.rank_time:setString(string.format(TI18N("%s"),time))
			self:setLessTime(data.end_time-GameNet:getInstance():getTime())
			self:updateTop3Info(data.rank_list)
		end)
	end

	if not self.update_quest_event then
		self.update_quest_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVENT_QUEST, function() 
			self:fileSevenRankInfo()
		end)
	end
end

--- 设置前3名的状态
function ActionSevenRankWindow:updateTop3Info( rank_list )
	if rank_list == nil then return end

	for i, object in ipairs(self.top_3_list) do
		local data = rank_list[i]  --根据排行榜取
		object.data = data
		if data then --有排名数据
			object.name:setString(data.name)
			if i == 1 then
				object.name:setPositionY(35)
			else
				object.name:setPositionY(25)
			end
			object.head:setVisible(true)
			object.head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
			if object.crown then
				object.crown:setVisible(true)
			end
		else
			object.head:setVisible(false)
			if object.crown then
				object.crown:setVisible(false)
			end
			object.name:setString(TI18N("虚位以待"))
			object.name:setPositionY(75)
		end
	end
end

--- 设置排行榜前3的基础奖励数据
function ActionSevenRankWindow:setTop3BaseInfo(  )
	for i,object in ipairs(self.top_3_list) do
		if object.head then
			object.head:setVisible(false)
		end
		if object.crown then
			object.crown:setVisible(false)
		end
		if object.honor then
			object.honor:setVisible(false)
		end
		if object.name then
			object.name:setVisible(true)
			object.name:setString(TI18N("虚位以待"))
			object.name:setPositionY(75)
		end
	end

	-- 取出第一名的称号
	local face_id = Config.DaysRankData.data_rank_data_const["rank_title"..self.cur_index].val
	local config = Config.HonorData.data_title[face_id]
	local res = PathTool.getTargetRes("honor","txt_cn_honor_"..config.res_id,false,false)
	if self.res_id ~= res then
		self.res_id = res
		self.item_load = createResourcesLoad(res, ResourcesType.single, function()
			local object = self.top_3_list[1] -- 取出第一个
			if not tolua.isnull(object.honor) then
				object.honor:loadTexture(res,LOADTEXT_TYPE)
				object.honor:setVisible(true)
			end
		end,self.item_load)
	end

	for i, object in ipairs(self.top_3_list) do
		local config = Config.DaysRankData.data_rank_data[self.cur_index]
		if config then
			local list = config[i]
			local temp = {}
			local effect_list = {}
			if list then
				if  list.effect_list then
					for i, v in ipairs(list.effect_list) do
						if not effect_list[v] then
							effect_list[v] = {effect_id = v}
						end
					end
				end
				for k,v in pairs(list.rewards) do
					local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
					vo.show_effect = effect_list[v[1]]
					vo.quantity = v[2]
					table.insert(temp,vo)	
				end

				if object.item_scroll then
					object.item_scroll:setData(temp)
					object.item_scroll:addEndCallBack(function (  )
						local list = object.item_scroll:getItemList()
						for k,v in pairs(list) do
							v:showItemEffect(false)
							v:setDefaultTip()
							if v.data.show_effect then
								if v.data.quality >= 4 then
									v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
								else
									v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
								end
							else
								v:showItemEffect(false)
							end
						end
					end)
				end
			end
		end
	end
end

--设置倒计时
function ActionSevenRankWindow:setLessTime( less_time )
    if tolua.isnull(self.rank_time) then return end
    self.rank_time:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.rank_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.rank_time:stopAllActions()
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ActionSevenRankWindow:setTimeFormatString(time)
    if time > 0 then
        self.rank_time:setString(string.format(TI18N("%s"),TimeTool.GetTimeFormat(time)))
        self.rank_time_title:setVisible(true)
    else
        self.rank_time:setString("")
        self.rank_time_title:setVisible(false)
    end
end

function ActionSevenRankWindow:close_callback()
	if self.update_tab ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_tab)
        self.update_tab = nil
    end

    if self.update_single_rank ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_single_rank)
        self.update_single_rank = nil
    end

	if self.update_quest_event then
		GlobalEvent:getInstance():UnBind(self.update_quest_event)
		self.update_quest_event = nil
	end

	for k,object in pairs(self.top_3_list) do
		if object.head then
			object.head:DeleteMe()
		end
		if object.item_scroll then
			object.item_scroll:DeleteMe()
		end
	end
	self.top_3_list = nil

	if self.tab_list ~= nil then 
		for k,v in pairs(self.tab_list) do
			if v and v["DeleteMe"] then 
				v:DeleteMe()
			end
		end
	end

	if self.goods_scrollview then
        self.goods_scrollview:DeleteMe()
        self.goods_scrollview = nil
    end

	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

	controller:openSevenRankWin(false)
end


-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      七天排行面板标签子项
-- Create: 2018-06-28
-- --------------------------------------------------------------------
ActionSevenRankTab = class("ActionSevenRankTab", function()
    return ccui.Widget:create()
end)

ActionSevenRankTab.Width = 123
ActionSevenRankTab.Height = 130

function ActionSevenRankTab:ctor()
	self:configUI()
	self:register_event()
end

function ActionSevenRankTab:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_seven_rank_tab"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(ActionSevenRankTab.Width,ActionSevenRankTab.Height))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setTouchEnabled(true)
    self.main_container:setSwallowTouches(false)

    self.icon = self.main_container:getChildByName("icon")
    self.name = self.main_container:getChildByName("name")
    self.stage = self.main_container:getChildByName("stage")
    self.status_bg = self.main_container:getChildByName("status_bg")

    self.arrow = self.root_wnd:getChildByName("arrow")
    self.arrow:setVisible(false)

    self.day = self.main_container:getChildByName("day")
end

function ActionSevenRankTab:register_event(  )
	self.main_container:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
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
	end)
end

function ActionSevenRankTab:setData(data)
	self.index = data.id
	local num = data.id
	if num >= 15 then
		num = num - 7
	end
	self.day:setString(TI18N("第")..num..TI18N("天"))
	self.name:setString(data.name)
	self.status  = data.status
	local res = PathTool.getResFrame("welfare","txt_cn_welfare_title_bg2")
	if data.status == 1 then --未开启
		res = PathTool.getResFrame('welfare', 'txt_cn_welfare_title_bg3')
	elseif data.status == 0 then --进行中
		res = PathTool.getResFrame('welfare', 'txt_cn_welfare_title_bg2')

	elseif data.status == 2 then --结束
		res = PathTool.getResFrame("welfare","txt_cn_welfare_title_bg8")
	end
	self.status_bg:loadTexture(res, LOADTEXT_TYPE_PLIST)

	local res = PathTool.getTargetRes("welfare/action_icon","welfare_icon_"..(data.ico or 1),false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.icon) then
                loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
end

function ActionSevenRankTab:setSelect( status )
	if status then 
        loadSpriteTexture(self.stage, PathTool.getResFrame("welfaretab","welfaretab_1"), LOADTEXT_TYPE_PLIST)
        self.stage:setPositionY(73)
        self.main_container:setPositionY(14.5)
    else
        loadSpriteTexture(self.stage, PathTool.getResFrame("welfaretab","welfaretab_2"), LOADTEXT_TYPE_PLIST)
        self.stage:setPositionY(40)
        self.main_container:setPositionY(-3)
    end
    self.arrow:setVisible(status)
end

function ActionSevenRankTab:getIndex(  )
	return self.index
end

function ActionSevenRankTab:setIsTouch( status )
	self.is_touch = status
end

function ActionSevenRankTab:setRedPointStatus(status)
	addRedPointToNodeByStatus(self, status)
end

function ActionSevenRankTab:addCallBack( value )
	self.callback =  value
end

function ActionSevenRankTab:DeleteMe()
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
	
	self:removeAllChildren()
	self:removeFromParent()
end




-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      七天排行面板子项
-- Create: 2018-06-28
-- --------------------------------------------------------------------
ActionSevenRankItem = class("ActionSevenRankItem", function()
    return ccui.Widget:create()
end)

ActionSevenRankItem.Width = 686
ActionSevenRankItem.Height = 124

function ActionSevenRankItem:ctor()
	self:configUI()
	self:register_event()
end

function ActionSevenRankItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_seven_rank_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(ActionSevenRankItem.Width,ActionSevenRankItem.Height))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setTouchEnabled(true)
    self.main_container:setSwallowTouches(false)

    self.bg = self.main_container:getChildByName("bg")

    self.rank_num = self.main_container:getChildByName("rank_num")
    self.rank_icon = self.main_container:getChildByName("rank_icon")

	self.quest_icon = self.main_container:getChildByName("quest_icon")
	self.desc_value = self.main_container:getChildByName("desc_value")
	self.get_btn = self.main_container:getChildByName("get_btn")
	self.get_btn_label = self.get_btn:getChildByName("label")
	self.get_btn_label:setString(TI18N("领取"))
	
    self.srcoll_con = self.main_container:getChildByName("srcoll_con")
    local scroll_view_size = self.srcoll_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 6,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        scale = 0.7,
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.srcoll_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ActionSevenRankItem:register_event(  )
	self:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click =
					math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
					math.abs(self.touch_end.y - self.touch_began.y) <= 20
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
	end)
	self.get_btn:addTouchEventListener(function(sender, event_type) 
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.data then
				controller:requestSubmitTask(self.data.id)
			end
		end
	end)
end

function ActionSevenRankItem:setData(data)
	if data then
		self.data = data
		if not data.is_quest then
			self.rank_num:setString(TI18N("第")..data.low.."~"..data.high..TI18N("名"))
			self.rank_num:setPositionY(62)
			self.desc_value:setVisible(false)
			self.get_btn:setVisible(false)
			self.quest_icon:setVisible(false)
		else
			self.rank_num:setString(data.desc)
			self.rank_num:setPositionY(82)
			self.desc_value:setVisible(true)
			self.get_btn:setVisible(true)
			self.quest_icon:setVisible(true)

			local quest_vo = model:getSevenQuestByID(data.id)
			if quest_vo then
				if quest_vo.finish == TaskConst.task_status.un_finish then -- 未达成
					setChildUnEnabled(true, self.get_btn) 
					self.get_btn_label:disableEffect()
					self.get_btn:setTouchEnabled(false) 
					self.get_btn_label:setString(TI18N("未达成"))
				elseif quest_vo.finish == TaskConst.task_status.finish then
					setChildUnEnabled(false, self.get_btn) 
					self.get_btn_label:enableOutline(Config.ColorData.data_color4[177]) 
					self.get_btn:setTouchEnabled(true) 
					self.get_btn_label:setString(TI18N("领取"))
				end
				local progress = quest_vo.progress
				if progress then
					local progress_value = progress[1]
					if progress_value then
						self.desc_value:setString(string_format(data.target_desc, progress_value.value))
					end
				end
			end
		end

		local effect_list = {}
		if data.effect_list then
			for i, v in ipairs(data.effect_list) do
				if not effect_list[v] then
					effect_list[v] = {effect_id = v}
				end
			end
		end
		local list = {}
		for k,v in pairs(data.rewards) do
			local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
			vo.show_effect = effect_list[v[1]]
			vo.quantity = v[2]
			table.insert(list,vo)
		end

		self.item_scrollview:setData(list)
		self.item_scrollview:addEndCallBack(function (  )
			local list = self.item_scrollview:getItemList()
			for k,v in pairs(list) do
				v:setDefaultTip()
				v:showItemEffect(false)
				if v.data and v.data.show_effect then
					if v.data.quality >= 4 then
						v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
					else
						v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
					end
				else
					v:showItemEffect(false)
				end
			end
		end)
	end
end

function ActionSevenRankItem:suspendAllActions()
end

function ActionSevenRankItem:DeleteMe()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end