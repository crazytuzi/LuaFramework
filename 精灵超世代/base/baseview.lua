-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      所有窗体的基类，必须要继承与他
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BaseView = BaseView or BaseClass(CommonUI)

WinType = {
	Tips = 1,
	Mini = 2,
	Big = 3,
	Full = 4,
}

--一级面板下面的按钮颜色与描边
CommonButton_Color = {
	[1] = cc.c4b(0xff,0xff,0xff,0xff), --默认
	[2] = cc.c4b(0xff,0xed,0xd6,0xff), --点击
    [3] = cc.c4b(0x2a,0x16,0x0e,0xff), --默认
    [4] = cc.c4b(0x2a,0x16,0x0e,0xff), --点击
}

--保存不是tips的其他 win
BaseView.winMap = {}
--保存tips的map --by lwc
BaseView.winTipsMap = {}

local ANIMATION_UI_START		= "ui_start"	                -- ui文件进场动作
local ANIMATION_UI_END			= "ui_end"		                -- ui退场动作
local UI_START_FRAME			= "start_frame"	                -- 进场后的帧事件
local UI_END_FRAME				= "end_frame"			        -- 退场结束帧事件

function BaseView:__init()
	self.view_tag				= ViewMgrTag.WIN_TAG        	-- 父级层次
	self.layout_name			= nil                       	-- csb文件路径,如果有值,则表示是csb文件,不用判断createWnd
	self.is_full_screen			= true                      	-- 是全屏界面
	self.is_use_csb				= true							-- 是否是使用csb创建窗体
	self.anim_vo_list			= {}					    	-- 保存csb文件上的动画
	self.is_exist_ui_end		= false			            	-- 是否存在退场动作，
	self.load_callback			= nil                       	-- 显示完成之后
	self.root_wnd				= nil                       	-- 根节点
	self.parent_wnd				= nil                       	-- 界面存放的父节点
	self.is_csb_action          = nil                           -- 是否使用csb那边的动画

	self.is_before_battle 		= false							-- 是否是在战斗之前就打开的，因为可能在战斗中会打开其他窗体这个时候的处理

	self.background_path		= nil							-- 背景资源路径

	self.show_close_btn			= true 							-- 是否显示关闭按钮
	
	--状态
	self.is_load_finish			= false
	self.is_loading				= false
	self.is_opening				= false
	self.is_visible				= false
	
	self.title_str				= ""                        	-- 标题
	
	self.tab_info_list			= {}                        	-- 如果这个有列表,则表示这个面板是标签页{label="aaaa", index=1, status=true} 
	self.tab_max				= 4                         	-- 当前面板

	--回调
	self.open_callback			= nil
	self.close_callback			= nil
	self.action_callback		= nil
	self.win_type				= WinType.Full              	-- 其他窗口打开模式为3
	
	-- 新增资源管理F
	self.res_list				= {}                        	-- 该窗体关联的资源，{{path="", type=ResourcesType}, ...} 结构
	self.is_start_to_load		= false
	self.open_params			= nil

	self.base_view_event_list 	= {}							-- 统一事件列表,方便移除

	-- 是否显示mainui顶部功能图标
	self.is_show_func_icon = 0
end

--==============================--
--desc:打开窗体的唯一入口，这里负责资源加载引用，
--time:2018-04-20 11:09:12
--@args:
--@return 
--==============================--
function BaseView:open(...)
	if not tolua.isnull(self.root_wnd) then
		self:setCommonUIZOrder(self.root_wnd)
		if self:getVisible() == false then
			self:setVisible(true)
			-- self:needHideMainScene()
		end
	else
		if self.is_start_to_load == false then
			self.is_start_to_load = true
			self.open_params = {...}

			if self.layout_name == nil and self.is_use_csb == true then
				if self.is_full_screen == true then 
					if  self.background_path == nil then
						self.background_path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_2", true)
					end
					table.insert(self.res_list, {path = self.background_path, type = ResourcesType.single})
				end		
			end

			if next(self.res_list) == nil then
				self:loadResListCompleted()
			else
				if self.resources_load == nil then
					self.resources_load = ResourcesLoad.New(true) 
				end
				
				self.resources_load:addAllList(self.res_list, function()
					self:loadResListCompleted()
				end)
			end
		end
	end
end

--==============================--
--desc:加载资源完成
--time:2018-04-20 10:33:13
--@return 
--==============================--
function BaseView:loadResListCompleted()
	-- 构建窗体
	self:constructBaseView()
	
	--进场动效
	self:playEnterAnimatian()

	-- 缓存窗体数据
	self:openCacheView()

	-- ios打开窗体上报
	if MAKELIFEBETTER == true and ios_log_report then
		ios_log_report(self.layout_name)
	end
end

--==============================--
--desc:资源全部加载完成之后，这边开始构建窗体
--time:2018-04-20 11:09:39
--@return 
--==============================--
function BaseView:constructBaseView()
	self.is_opening = true
	self.is_visible = true
	if self:__getRootWnd() then	--這裡不為空，說明已經加載過面板了
		if self.open_callback then
			self:open_callback()
		end
		if not self:__getRootWnd():getParent() then
			self:attachParent()
		end
		self:setRootWndVisible(true)
		self:setCommonUIZOrder(self.root_wnd)
	else
		self:openOnlyReal()
	end
end

function BaseView:openOnlyReal()
	if self.is_loading then return end
	self.is_loading = true
	self:loadFiles()
end

function BaseView:loadFiles()
	if self.layout_name then
		self:initLayoutFile(self.layout_name)
	else
		if self["createRootWnd"] then
			self:createRootWnd()
		else
			if self.tab_info_list and next(self.tab_info_list) ~= nil then		-- 做了调整，如果是带标签页的必然是全屏的
				self:initLayoutFile("common/common_window_tab", true)
			elseif self.tab_info_list2 and next(self.tab_info_list2) ~= nil then		-- 做了调整，如果是带标签页的必然是全屏的
				self:initLayoutFile("common/common_window_tab2", true)
			else
				if self.is_full_screen == true then
					self:initLayoutFile("common/common_window", true)
				else
					self:initLayoutFile("common/common_window_2", true)
				end
			end
		end
	end
	if not self:__getRootWnd() then return end
	--进场，离场注册
	self:registerNodeScriptHandler()

	--加入父节点
	self:attachParent()
	
	self:__getRootWnd():setVisible(self.is_visible)
	self:__getRootWnd():setAnchorPoint(cc.p(0.5, 0.5))
	self:__getRootWnd():setPosition(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
	self.is_load_finish = true
	--有的话可以设置，置顶
	self:setCommonUIZOrder(self.root_wnd)
	
	--加载的回调，如果是选择，不可见的关闭，那么只会调用一次
	if self.load_callback then
		self:load_callback()
	end
	
	--这个回调基本每次调用open都会调用
	if self.is_opening then
		if self.open_callback then
			safeCallFunc(function() self:open_callback() end)
		end
		-- 设置中文文本内容
		setTextContentList(self.root_wnd, self.text_name_list)
		-- 是否有注册监听事件
		if self.register_event then
			self:register_event()
		end
		-- 如果有打开事件，那么就打开处理
		if self.openRootWnd then
			if self.open_params ~= nil and next(self.open_params) ~= nil then
				self:openRootWnd(unpack(self.open_params))
			else
				self:openRootWnd()
			end
			--专门为在初始化后.插更的方法 .目的减少初始化层面修改 导致插更的体积大小 --by lwc
			if self.insertFunc then
				self:insertFunc()
			end
			self.is_start_to_load = false
		end
	end
	self.is_loading = false
end

--==============================--
--desc:关闭面板
--time:2017-08-15 12:11:35
--@source:是自身关闭还是外界关闭
--@return 
--==============================--
function BaseView:close(source)
	if self.is_closeing then return end
	self.is_closeing = true
	if source ~= nil and type(source) == "boolean" then
		self.close_by_other = source
	end
	
	-- 移除当前的窗体,并且缓存窗体校验
	self:closeCacheView()
	if self.is_exist_ui_end then
		self:playExitAnimation()
	else
		self:closeInternal()
	end
end

function BaseView:closeInternal()
	if self.root_wnd and(not tolua.isnull(self.root_wnd)) then
		self.root_wnd:stopAllActions()
		self:setRootWndVisible(false)
	end
	self:__close()
	GlobalEvent:getInstance():Fire(EventId.CLOSE_BASE_VIEW, self)
end

function BaseView:__close()
	if self.is_opening and self.close_callback then
		self:close_callback()
	end
	
	--根据模式来选择关闭的调用
	self:closeDestroy()
	
	self.is_opening = false
	self.is_closeing = false
end

function BaseView:openCacheView()
	if self.win_type ~= WinType.Tips then
		if #BaseView.winMap >= 12 then
			local topWin = table.remove(BaseView.winMap, 1)
			if topWin ~= nil then
				topWin:close()
				if topWin.next_win ~= nil then
					topWin.next_win.top_win = nil
				end
			end
		end
		table.insert(BaseView.winMap, self)
		if #BaseView.winMap > 1 then
			local lastWin = BaseView.winMap[#BaseView.winMap - 1]
			if lastWin ~= nil then
				if lastWin.win_type == WinType.Mini and self.win_type ~= WinType.Mini then
					lastWin = table.remove(BaseView.winMap, #BaseView.winMap - 1)
					if lastWin ~= nil then
						if lastWin.top_win then
							lastWin.top_win.next_win = self
						end
						if lastWin.close then
							lastWin:close()
						end
					end
				end
			end
			
			if #BaseView.winMap > 0 then
				local lastWin = BaseView.winMap[#BaseView.winMap - 1]
				-- 如果面板原本就是隐藏的,就不需要做链接了,这种情况只有战斗中才会出现了
				if lastWin and not tolua.isnull(lastWin.root_wnd) and lastWin.win_type ~= WinType.Tips and lastWin:getVisible() == true then
					self.top_win = lastWin
					self.top_win.next_win = self
					if self.win_type ~= WinType.Mini and self.win_type >= lastWin.win_type then
						self.top_win:setVisible(false)
					end
				end
			end
		end
		self:needHideMainScene()
	else
		table.insert(BaseView.winTipsMap, self)
	end
end

function BaseView:needHideMainScene()
	if self.win_type == WinType.Full then
		delayOnce(function()
			if self.is_visible == true then
				if BattleController:getInstance():isInFight() == true then
					BattleController:getInstance():handleBattleSceneStatus(false)
				end
				MainSceneController:getInstance():handleSceneStatus(false)
				if self.is_show_func_icon == 1 then
					self:setVisible(true)
				end
			end
		end, 1 / display.DEFAULT_FPS)
	end
end

function BaseView:closeCacheView()
	if self.win_type ~= WinType.Tips then
		for i, v in ipairs(BaseView.winMap) do
			if v == self then
				table.remove(BaseView.winMap, i)
				if self.top_win and not tolua.isnull(self.top_win.root_wnd) then
					if self.next_win ~= nil and self.next_win.win_type == WinType.Full then
                    else
						if not self.close_by_other then
							if not self.top_win.is_before_battle then -- 战队战斗之前进入的窗体做处理
								self.top_win:setVisible(true)
							else
								self.top_win.enter_battle_status = true
							end
						end
						self.top_win.next_win = nil
					end
				end
				if self.next_win and self.top_win then
					self.top_win.next_win = self.next_win
					self.next_win.top_win = self.top_win
				end
				break		
			end
		end
		if #BaseView.winMap == 0 or (not self:isFullWinExist()) then
			if not BattleController:getInstance():isInFight() and not MainuiController:getInstance():checkIsInDramaUIFight() then
				MainSceneController:getInstance():handleSceneStatus(true)
			elseif BattleController:getInstance():isInFight() then
				BattleController:getInstance():handleBattleSceneStatus(true)
			end
		end
	else
		for i, v in ipairs(BaseView.winTipsMap) do
			if v == self then
				table.remove(BaseView.winTipsMap, i)
				break
			end
		end
	end
end

function BaseView:isFullWinExist()
	for _, win in ipairs(BaseView.winMap) do
		if win.win_type == WinType.Full and win.is_before_battle == false then
			return true
		end
	end
	return false
end

function BaseView:isBigWinExist()
    for _, win in ipairs(BaseView.winMap) do
        if win.win_type == WinType.Big then
            return true
        end
    end
    return false
end

function BaseView:closeDestroy()
	self:release()
end

function BaseView:__delete()
	self:release()
end

--need to be override
--用来调用删除面板内的内容，但是没法释放纹理内存
function BaseView:deleteMe()
end

--need to be override
--释放纹理内存
function BaseView:releaseMem()
end

--统一这个地方来设置，方面修改
function BaseView:setRootWndVisible(bool)
	self:setVisible(bool)
end

--事件注册，当根节点离开父节点的时候触发，保障根节点不会变成“野指针”
function BaseView:registerNodeScriptHandler()
	local function onNodeEvent(event)
		if "enter" == event then  --进场
			if self["onEnter"] then
				self:onEnter()
			end
		elseif "exit" == event then --离场
			if self["onExit"] then
				self:onExit()
			end
		end
	end
	self:__getRootWnd():registerScriptHandler(onNodeEvent)
end

--节点销毁
function BaseView:release()
	self:deleteMe()
	self.is_visible = false
	self.is_load_finish = false
	self.is_loading = false
		
	if self.root_wnd and(not tolua.isnull(self.root_wnd)) then
		self.root_wnd:stopAllActions()
		self.root_wnd:removeAllChildren()
		self.root_wnd:removeFromParent()
	end
	
	for _, vo in pairs(self.anim_vo_list) do
		local rootWnd = vo[1]
		local uiAction = vo[2]
		if rootWnd then 
			rootWnd:release() 
		end
		if uiAction then
			uiAction:clearFrameEventCallFunc()
			uiAction:release()
		end
	end
	self.anim_vo_list = {}
	
	-- 移除该面板相关的资源计数，等到自动删除
	if self.resources_load ~= nil then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end

	-- 移除掉统一箭筒的事件
	self:removeGlobalEvent()
	
	self:releaseMem()
	self.root_wnd = nil
end

--设置父节点
function BaseView:__setParent(parent)
	self.parent_wnd = parent
end

--获取父节点
function BaseView:__getRootParent()
	if not self.parent_wnd then
		self.parent_wnd = ViewManager:getInstance():getLayerByTag(self.view_tag)
	end
	return self.parent_wnd
end

-- 获取根窗口
function BaseView:__getRootWnd()
	return self.root_wnd
end

function BaseView:isOpen()
	if not self:isLayout() then
		return false
	end
	return self.is_visible
end

-- 是否被加载了
function BaseView:isLayout()
	return self.is_load_finish
end

function BaseView:setVisible(bool)
	self.is_visible = bool
	if self.root_wnd == nil or tolua.isnull(self.root_wnd) then return end
	self.root_wnd:setVisible(bool)
end

function BaseView:getVisible()
	return self.is_visible
end

function BaseView:openAction(action_ui)
	if action_ui then
		if self.action_callback then self.action_callback() end
	end
end

function BaseView:addChild(diplayerObj)
	self.root_wnd:addChild(diplayerObj)
end

function BaseView:removeChild(diplayerObj)
	self.root_wnd:removeChild(diplayerObj)
end

function BaseView:removeAllChildren()
	self.root_wnd:removeAllChildren()
end

function BaseView:setPosition(pos)
	self.root_wnd:setPosition(pos)
end

function BaseView:getPosition()
	self.root_wnd:getPosition()
end

--[[
    @desc: 根据csb构建窗体
    author:{author}
    time:2018-05-03 10:06:42
    --@csbPath:csb路径
	--@use_default: 是否是通用的资源
    return
]]
function BaseView:initLayoutFile(csbPath, use_default)
	self:preLoadLayoutFile()
	self:loadLayoutFile(csbPath, use_default)
	self:loadComplete()
	
	if self.BIND_TOUCH_EVENTS then
		self:createResoueceBinding(self.BIND_TOUCH_EVENTS)
	end
end

--绑定ui事件
function BaseView:createResoueceBinding(bindEvents)
	assert(self.root_wnd, "root_wnd should not be null")
	
	for _, v in pairs(bindEvents) do
		local node = self:getChildByName(v.widget)
		if node then
			for _, event in pairs(v.events) do
				if event.event == "click" then
					self:onClicked(node, handler(self, self[event.hander]))
				end
			end
		end
	end
end

function BaseView:onClicked(node, endCallback, beganCallback, cancelCallback)
	node:addTouchEventListener(function(sender, state)
		local event = {}
		event.target = sender
		
		if state == ccui.TouchEventType.began then
			event.name = "began"
			node:setScale(1.1)
			if beganCallback then beganCallback(event) end
		elseif state == ccui.TouchEventType.moved then
			event.name = "moved"
		elseif state == ccui.TouchEventType.ended then
			self:playButtonSound2()
			event.name = "ended"
			node:setScale(1)
			endCallback(event)
		else
			event.name = "cancelled"
			node:setScale(1)
			if cancelCallback then cancelCallback(event) end
		end
	end)
end

--递归获取子节点
function BaseView:getChildByName(sWidgetPath)
	local tTidgetTrees = Split(sWidgetPath, "/")
	local node = self.root_wnd
	if nil == self.layout_name and self.container then
		node = self.container:getChildByName("container")
	end
	for _, v in ipairs(tTidgetTrees) do
		if not node then
			print("node: " .. nodepath)
		end
		node = node:getChildByName(v)
	end	
	
	return node
end

function BaseView:attachParent()
	self:__getRootParent():addChild(self:__getRootWnd())
end

function BaseView:preLoadLayoutFile()
end

function BaseView:loadLayoutFile(csbPath, use_default)
	csbPath = PathTool.getTargetCSB(csbPath)
	self.root_wnd = cc.CSLoader:createNode(csbPath)
	self.root_wnd:retain()
	-- 这里是使用默认的base_view csb
	if use_default == true then
		self:getObjFromCSB()
	end

	if self.is_csb_action then
		local ui_action = cc.CSLoader:createTimeline(csbPath)
		ui_action:retain()
		self.is_exist_ui_end = ui_action:IsAnimationInfoExists(ANIMATION_UI_END)
		table.insert(self.anim_vo_list, {self.root_wnd, ui_action})

		local function onFrameEvent(frame)
			if nil == frame then return end
			local str = frame:getEvent()
			if str == UI_START_FRAME then
				self:onEnterAnim()
			elseif str == UI_END_FRAME then
				self:onExitAnim()
				self:setVisible(false)
				delayOnce(function()
					self:closeInternal()
				end, 1 / display.DEFAULT_FPS)
			end
		end
		ui_action:setFrameEventCallFunc(onFrameEvent)
		if not tolua.isnull(self.root_wnd) then
			self.root_wnd:runAction(ui_action)
		end
	end
end
--@ 通用入场动作  
--@ action_type 动作类型 默认 1 表示 左进   2 表示缩小放大
function BaseView:playEnterAnimatianByObj(obj, action_type)
	if not tolua.isnull(obj) then
		if action_type == 2 then
 			ActionHelp.itemScaleAction(obj)
		else
			ActionHelp.itemUpAction(obj)
		end
	end
end

--==============================--
--desc:使用默认的csb创建窗体的时候
--time:2017-07-05 12:30:21
--@return 
--==============================--
function BaseView:getObjFromCSB()
	if self.root_wnd == nil then return end
	self.background = self.root_wnd:getChildByName("background")
	-- self.background:ignoreContentAdaptWithSize(true)
	self.background:setScale(display.getMaxScale(self.root_wnd))

	-- 背景一定要是image，不是之前的黑幕了
	if self.background_path ~= nil then
		self.background:loadTexture(self.background_path, LOADTEXT_TYPE)
	else
		if self.is_full_screen == true then
			self.background:setVisible(false)
		end
	end
	
	local image_panel = self.root_wnd:getChildByName("image_panel")
	if image_panel ~= nil then
		image_panel:setPositionY(display.getBottom(self.root_wnd))
	end
	self.main_container = self.root_wnd:getChildByName("main_container")
	if image_panel ~= nil then
		self.main_container:setPositionY(image_panel:getPositionY() + 85)
	end
	-- 通用进场动效
	ActionHelp.itemUpAction(self.main_container, 400, 0, 0.2)
	
	self.main_panel = self.main_container:getChildByName("main_panel")

	-- 这个节点就是各个面板自己需要显示的内容的父节点了
	self.container = self.main_panel:getChildByName("container")
	
	if self.is_full_screen == false then        -- 全屏的不需要做背景点击关闭
		if self.background then
			self.background:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					playCloseSound()
					self:close()
				end
			end)
		end
	end
	local title_label = self.main_panel:getChildByName("win_title")
	title_label:setString(self.title_str)
	self.title_label = title_label
	
	self.close_btn = self.main_panel:getChildByName("close_btn")
	if self.close_btn == nil then
		self.close_btn = self.root_wnd:getChildByName("close_btn")
	end
	if self.close_btn then
		self.close_btn:setVisible(self.show_close_btn)
		if self.close_btn then
			self.close_btn:addTouchEventListener(function(sender, event_type)
				customClickAction(sender,event_type)
				if event_type == ccui.TouchEventType.ended then
					playCloseSound()
					if self.beforeClose then
						self:beforeClose()
					end
					self:close()
				end
			end)
		end
	end
    self:createTabList2()

	-- 这里就是标签页面板了,因为面板问题,这类的面板最多现在只放5个标签页,规则现在只判断这么多
	if self.tab_info_list and next(self.tab_info_list) ~= nil then
		local tab_panel =self.main_panel:getChildByName("tab_container")
		if self.tab_btn_list == nil then
			self.tab_btn_list = {}
		end
		local tab, tab_btn, tab_tips, info
		for i = 1, self.tab_max do
			tab = tab_panel:getChildByName("tab_btn_" .. i)
			if tab ~= nil then
				tab_btn = tab
				tab_btn:setName("tab_btn_" .. i)
				tab_tips = tab:getChildByName("tab_tips")
				tab_red_num = tab:getChildByName("red_num")  --要显示出红点跟次数
				select_bg = tab:getChildByName("select_bg")
				unselect_bg = tab:getChildByName("unselect_bg")
				if tab_btn ~= nil then
					tab_btn.tips = tab_tips
					tab_btn.red_num = tab_red_num
					tab_btn.select_bg = select_bg
					tab_btn.unselect_bg = unselect_bg
					info = self.tab_info_list[i]                --有序table,直接取下标去创建
					if info ~= nil then
						tab_btn.notice = info.notice or ""
						tab_btn.label = tab:getChildByName("title")
						tab_btn.label:setString(info.label)
						tab_btn.index = info.index
						tab_btn.label:setTextColor(Config.ColorData.data_new_color4[6])
						tab_btn.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, 0),0)
						tab_btn.label:setFontSize(24)

						local txt_width = tab_btn.label:getContentSize().width + 16
						local img_width = tab_btn.select_bg:getContentSize().width
						local scale = 1
						if txt_width > img_width then
							scale = img_width / txt_width
						end
						tab_btn.label:setScale(scale)

						--tab_btn.label:enableOutline(CommonButton_Color[3],2)
						tab_btn.select_bg:setVisible(false)
						tab_btn.tips:setVisible(false)
						tab_btn.red_num:setVisible(false)
						-- tab_btn:setTouchEnabled(info.status)
						tab_btn.can_touch = info.status
						-- 如果不可点击,就灰掉吧
						if info.status == false then
							setChildUnEnabled(true, tab_btn, Config.ColorData.data_new_color4[18])
						end
						-- 添加注册监听事件
						tab_btn:addTouchEventListener(function(sender, event_type)
							if event_type == ccui.TouchEventType.ended then
								playTabButtonSound()
								if sender.can_touch == false then
									message(sender.notice)
								else
									self:setSelecteTab(sender.index)
								end
							end
						end)
						self.tab_btn_list[info.index] = tab_btn
					else
						tab_btn:setVisible(false)
					end
				end
			end
		end
	end
end

function BaseView:createTabList2()
    if self.tab_info_list2 == nil then return end
    if self.tab_btn_list == nil then
        self.tab_btn_list = {}
    end 
    local tab_panel =self.main_panel:getChildByName("tab_container")
    local tab1 = tab_panel:getChildByName("tab_btn_1")
    self.tab_btn_list[1] = tab1
    local btn_width = tab1:getContentSize().width
    local max_width = btn_width
    local len = #self.tab_info_list2
    local tab, info
    local x,y = tab1:getPosition()
    local space = 5
    for i = 1, len do
        info = self.tab_info_list2[i]
        tab = self.tab_btn_list[i]
        if tab == nil then
            tab = tab1:clone()
            tab_panel:addChild(tab)
            tab:setPosition(x, y)
            max_width = max_width + btn_width + space
            self.tab_btn_list[i] = tab
        end
        tab.tips = tab:getChildByName("tab_tips")
        tab.red_num = tab:getChildByName("red_num")  --要显示出红点跟次数
        tab.select_bg = tab:getChildByName("select_bg")
        tab.unselect_bg = tab:getChildByName("unselect_bg")
        tab.notice = info.notice or ""
        tab.label = tab:getChildByName("title")
        tab.label:setString(info.label)
        tab.index = info.index
        tab.status = info.status
        tab_btn.label:setTextColor(Config.ColorData.data_new_color4[6])
		--tab_btn.label:enableOutline(CommonButton_Color[3],2)
        tab.select_bg:setVisible(false)
        tab.tips:setVisible(false)
        tab.red_num:setVisible(false)
        tab:setTouchEnabled(info.status)
        -- 如果不可点击,就灰掉吧
        if info.status == false then
            setChildUnEnabled(true, tab, Config.ColorData.data_new_color4[18])
            tab:setTouchEnabled(true)
        end
        -- 添加注册监听事件
        tab:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                if sender.status == false then
                    message(sender.notice)
                else
                    self:setSelecteTab(sender.index)
                end
            end
        end)
        x = x + btn_width + space
    end
    max_width = math.max(max_width, tab_panel:getContentSize().width)
	tab_panel:setScrollBarEnabled(false)
    tab_panel:setSwallowTouches(false)
    tab_panel:setInnerContainerSize(cc.size(max_width, tab_panel:getContentSize().height))
end

--==============================--
--desc:设置标签页上面的红点
--time:2017-08-01 02:10:31
--@status:
--@index:
--@return 
--==============================--
function BaseView:setTabTips(status, index)
	if not tolua.isnull(self.root_wnd) and self.tab_btn_list then
		local tab_btn = self.tab_btn_list[index]
		if tab_btn and tab_btn.tips then
			tab_btn.tips:setVisible(status)
		end
	end
end

--==============================--
--desc:设置标签页上的红点，要显示出数字出来
--time:2018-05-07 05:47:47
--@status:
--@index:
--@return 
--==============================--
function BaseView:setTabTipsII(num, index)
	local status = true 
	if num <=0 then 
		status = false
	end
	local tab_btn = self.tab_btn_list[index]
	if tab_btn and tab_btn.tips then
		tab_btn.tips:setVisible(status)
		tab_btn.red_num:setVisible(status)
	end
	if num >=0 then 
		tab_btn.red_num:setString(num)
	end
end

--换标签的时候改变标题名字
function BaseView:changeTitleName(name)
	if self.title_label and name ~= nil then
		self.title_label:setString(name)
	end
end

function BaseView:setTabBtnTouchStatus(status, index)
	local tab_btn = self.tab_btn_list[index]
	if tab_btn then
		setChildUnEnabled(not status, tab_btn, Config.ColorData.data_new_color4[18])
		tab_btn.can_touch = status
	end
end

--==============================--
--desc:切换标签页做的一些事情
--time:2017-07-05 01:47:38
--@index:
--@is_init:
--@return 
--==============================--
function BaseView:setSelecteTab(index, is_init)	
	if self.cur_selected and self.cur_selected.index == index then return end	
	if self.cur_selected ~= nil then
		if self.cur_selected.label then
			self.cur_selected.label:setTextColor(Config.ColorData.data_new_color4[6])
			self.cur_selected.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, 0),0)
			--self.cur_selected.label:setFontSize(20)

			--self.cur_selected.label:enableOutline(CommonButton_Color[3],2)
		end
		self.cur_selected.select_bg:setVisible(false)
	end
	
	self.cur_selected = self.tab_btn_list[index]
	if self.cur_selected ~= nil then
		if self.cur_selected.label then
			self.cur_selected.label:setTextColor(Config.ColorData.data_new_color4[1])
			self.cur_selected.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
			--self.cur_selected.label:setFontSize(22)
			--self.cur_selected.label:enableOutline(CommonButton_Color[4],2)
		end
		self.cur_selected.select_bg:setVisible(true)
	end
	if self.selectedTabCallBack and self.cur_selected ~= nil then
		self:selectedTabCallBack(self.cur_selected.index)
	end
end

function BaseView:loadComplete()
end

function BaseView:playEnterAnimatian()
	if self.is_csb_action then
		for _, vo in pairs(self.anim_vo_list) do
			local rootWnd = vo[1]
			local uiAction = vo[2]
			if rootWnd and uiAction then
				if uiAction:IsAnimationInfoExists(ANIMATION_UI_START) then
					uiAction:play(ANIMATION_UI_START, false)
				end
			end
		end
	end
end

--播放退场动作
function BaseView:playExitAnimation()
	if self.is_csb_action then
		for _, vo in pairs(self.anim_vo_list) do
			local rootWnd = vo[1]
			local uiAction = vo[2]
			if rootWnd and uiAction then
				if uiAction:IsAnimationInfoExists(ANIMATION_UI_END) then
					uiAction:play(ANIMATION_UI_END, false)
				end
			end
		end
	end
end

--进场动画播完，可重写
function BaseView:onEnterAnim()
end

--退场动画播完，可重写
function BaseView:onExitAnim()
end

--[[
    @desc: 通用声音配置
    author:{author}
    time:2018-05-03 10:18:03
    return
]]
function BaseView:playButtonSound()
	if AudioManager then
		AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_002")
	end
end

--==============================--
--desc:剧情或者引导需要判断当前是否有窗体打开或者是否有全屏窗体打开
--time:2017-07-26 11:03:22
--@return 
--==============================--
function BaseView.checkWinExist()
	for _, win in ipairs(BaseView.winMap) do
		if win.win_type == WinType.Full then
			return true
		end
	end
	return false
end

--==============================--
--desc:外部关闭所有的窗体
--time:2017-09-20 02:18:52
--@return 
--==============================--
function BaseView.closeAllView()
	local win_list = {}
	if BaseView.winMap ~= nil and next(BaseView.winMap) ~= nil then
		for i, v in ipairs(BaseView.winMap) do
			table.insert(win_list, v)
		end
	end
	
	if win_list ~= nil and next(win_list) ~= nil then
		for i, v in ipairs(win_list) do
			if v.close then
				v:close(true)
			end
		end
	end
	BaseView.winMap = {}
end
--desc:外部关闭所有tips的窗口
function BaseView.closeAllTipsview()
	local win_list = {}
	if BaseView.winTipsMap ~= nil and next(BaseView.winTipsMap) ~= nil then
		for i, v in ipairs(BaseView.winTipsMap) do
			table.insert(win_list, v)
		end
	end
	
	if win_list ~= nil and next(win_list) ~= nil then
		for i, v in ipairs(win_list) do
			if v.close then
				v:close(true)
			end
		end
	end
	BaseView.winTipsMap = {}
end
--打印 当前窗口信息..--by lwc
function BaseView.printWinLog()
	print("当前窗口数量: "..#BaseView.winMap)
	for i,v in ipairs(BaseView.winMap) do
		if v.layout_name then
			print(string.format("第%s个窗口名字: %s", i, v.layout_name))
		end
		if v.check_class_name then
			print(string.format("第%s个窗口名字: %s", i, v.check_class_name))
		end
	end

	print("当前tips窗口数量: "..#BaseView.winTipsMap)
	for i,v in ipairs(BaseView.winTipsMap) do
		if v.layout_name then
			print(string.format("第%s个tips窗口名字: %s", i, v.layout_name))
		end
	end
end

--关闭所有的view 和 tips的窗口
function BaseView.closeViewAndTips()
	BaseView.closeAllView()
	BaseView.closeAllTipsview()
end

--==============================--
--desc:关闭一些会挡住引导或者剧情的面板
--time:2017-09-29 07:16:54
--@return 
--==============================--
function BaseView.closeSomeWin()
	CommonAlert.closeAllWin()
	TipsManager:getInstance():hideTips()
	TipsManager:getInstance():showBackPackCompTips(false) 
	ChatController:getInstance():closeChatUseAction()
	ArenaController:getInstance():openArenaChampionTop3Window()
	BattleController:getInstance():closeBattleResultWindow()
	HeroController:getInstance():openEquipTips(false)
	BattleDramaController:getInstance():openDramHookRewardView(false)
	LevupgradeController:getInstance():openMainWindow(false) 
    ActionController:getInstance():openFirstChargeView(false) 
    ActionController:getInstance():openActionMainPanel(false) 
    VipController:getInstance():openVipMainWindow(false) 
	WelfareController:getInstance():openMainWindow(false) 
	HallowsController:getInstance():openHallowsTips(false)
	FriendController:getInstance():openFriendFindWindow(false)
	FriendController:getInstance():openFriendWindow(false)
	OnlineGiftController:getInstance():openOnlineGiftView(false)
	FriendController:getInstance():openFriendCheckPanel(false)
	Endless_trailController:getInstance():openEndlessBuffView(false, nil, true)
	PartnersummonController:getInstance():openSummonGainWindow(false)
	PartnersummonController:getInstance():openSummonGainShowWindow(false)
	-- ActionController:getInstance():openActionLimitGiftMainWindow(false) --如果触发剧情了 需要关闭礼包的 暂时忽略 --by lwc
end 

--==============================--
--desc:basevie统一注册事件,这里需要注意自己Fire的时候,参数如果是多个,那么非最后一个的都需要默认值,要不然unpack会跟自己想要的对不上.
--time:2018-10-26 10:55:32
--@event_type:
--@callback:
--@return 
--==============================--
function BaseView:addGlobalEvent(event_type, callback)
	if self.base_view_event_list == nil then
		--在上面有定义的情况下..有人点出(此文本行数 + 4)行的地方: self.base_view_event_list 这个是一个nil对象 
		--应该是先执行 removeGlobalEvent 情况下.才执行此方法..是移除的了..这里无视此方法的处理
		return
	end
	if self.base_view_event_list[event_type] == nil then
		self.base_view_event_list[event_type] = GlobalEvent:getInstance():Bind(event_type, function(...) 
			if callback and (not tolua.isnull(self.root_wnd)) then
    			local params = {...}
				callback(unpack(params))
			end
		end)
	end
end

function BaseView:removeGlobalEvent()
	if self.base_view_event_list then
		for k,v in pairs(self.base_view_event_list) do
			GlobalEvent:getInstance():UnBind(self.base_view_event_list[k])
			self.base_view_event_list[k] = nil
		end
	end
	self.base_view_event_list = nil
end