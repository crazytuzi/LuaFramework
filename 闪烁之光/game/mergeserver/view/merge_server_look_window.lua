--------------------------------------------
-- @Author  : lc
-- @Editor  : lc
-- @Date    : 2019-09-28 
-- @description    : 
		-- 合服问卷调查界面
---------------------------------
MergeserverLookWindow = MergeserverLookWindow or BaseClass(BaseView)

local controller = MergeserverController:getInstance()
local model = controller:getModel()
local string_format = string.format
local roleVo = RoleController:getInstance():getRoleVo()


function MergeserverLookWindow:__init()
	self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "mergeserverinfo/merge_server_look_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("mergeserver", "mergeserver"), type = ResourcesType.plist},		
	}
	local _const = Config.MergeVotingData.data_const
	self.rule = _const.merge_rule_text.desc  --超链接详情内容
	self.reward_label = _const.merge_welfare_text.desc  --第二弹奖励活动内容
	self.reward_data  = _const.merge_reward.val --奖励数据(图标item)
	self.merge_welfare_title = _const.merge_welfare_title.desc 
	self.merge_reward_title = _const.merge_reward_title.desc 
	self.merge_introductions_text = _const.merge_introductions_text.desc
	self.lev_limit = _const.level_limit.val
	self.openday_limit = _const.role_time_limit.val


	self.can_touch = true  --未选中状态

end

function MergeserverLookWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background") --遮罩
	if self.background then
		self.background:setScale(display.getMaxScale())
	end


	self.main_container = self.root_wnd:getChildByName("main_container")
	self:handleEffect(true) 
    self:playEnterAnimatianByObj(self.main_container , 1) 
	
	self.tips = self.main_container:getChildByName("tips") --规则

	
	self.reward_panel = self.main_container:getChildByName("reward_panel") --奖励背景
	
	self.bottom_panel_1 = self.main_container:getChildByName("bottom_panel_1") --投票
	self.check_panel = self.bottom_panel_1:getChildByName("check_panel") --复选框

	self.checkbox_agree = self.check_panel:getChildByName("checkbox_agree")
	self.txt_agree  = self.checkbox_agree:getChildByName("txt_agree")
	self.txt_agree:setString(TI18N("我支持尽快合服"))

	self.checkbox_disagree = self.check_panel:getChildByName("checkbox_disagree")
	self.txt_disagree  = self.checkbox_disagree:getChildByName("txt_disagree")
	self.txt_disagree:setString(TI18N("暂不支持这么快合服"))

	self.checkbox_agree:setSelected(true)  --默认同意
	self.checkbox_disagree:setSelected(false)


	self.btn_vote = self.bottom_panel_1:getChildByName("btn_vote") -- 投票按钮
	self.txt_vote = self.btn_vote:getChildByName("txt_vote")
	self.txt_vote:setString(TI18N("我要投票"))

	self.txt_already_vote = self.bottom_panel_1:getChildByName("txt_already_vote")
	self.txt_sur = self.bottom_panel_1:getChildByName("text_sur")
	self.txt_sur:setString(TI18N("本次投票仅有1次投票机会，距投票结束还有"))
	self.time_label = self.bottom_panel_1:getChildByName("time_label")
	self.time_label:setAnchorPoint(0,0.5)
	self.time_label:setString("00:00:00")
	self.time_label:setPositionX(495)
	self:setBtnVisible(true)--投票按钮
	

	self.bottom_panel_2 = self.main_container:getChildByName("bottom_panel_2") --投票结果
	self.bottom_panel_1:setVisible(false)
	self.bottom_panel_2:setVisible(false)
	self.Image_1 = self.bottom_panel_2:getChildByName("Image_1") 
	self.win_title_2 = self.Image_1:getChildByName("win_title_2")  --投票结果标题
	self.win_title_2:setString(TI18N("投票结果"))

	self.txt_agree_title = self.bottom_panel_2:getChildByName("txt_agree_title")
	self.txt_agree_title:setString(TI18N("支持合服    "))
	self.rate_agree = self.bottom_panel_2:getChildByName("rate_agree") --
	self.txt_agree_num = self.bottom_panel_2:getChildByName("txt_agree_num") 

	self.txt_disagree_title = self.bottom_panel_2:getChildByName("txt_disagree_title")
	self.txt_disagree_title:setString(TI18N("暂不支持合服"))
	self.rate_disagree = self.bottom_panel_2:getChildByName("rate_disagree") --
	self.txt_disagree_num = self.bottom_panel_2:getChildByName("txt_disagree_num")

	self.txt_result = self.bottom_panel_2:getChildByName("txt_result")
	self.txt_result:setString(TI18N("本次合服投票本服意愿度为"))
	self.rate = self.bottom_panel_2:getChildByName("rate")
	self.rate:setString("00%，")
	self.txt_result_0 = self.bottom_panel_2:getChildByName("txt_result_0") 
	self.txt_result_0:setString(TI18N("感谢您的参与"))



	self.my_vote = self.bottom_panel_2:getChildByName("my_vote") --
	self.my_vote:setString(TI18N("我的投选"))

	self.my_vote_agree_item = self.my_vote:getChildByName("my_vote_agree_item") --我的投票选项 默认同意
	self.my_rate_agree = self.my_vote_agree_item:getChildByName("my_rate_agree") --
	self.txt_agree_title_1 = self.my_vote_agree_item:getChildByName("txt_agree_title_1") --
	self.txt_agree_title_1:setString(TI18N("支持合服"))

	self.my_vote_disagree_item = self.my_vote:getChildByName("my_vote_disagree_item") --
	self.my_rate_disagree = self.my_vote_disagree_item:getChildByName("my_rate_disagree") --
	self.txt_disagree_title_1 = self.my_vote_disagree_item:getChildByName("txt_disagree_title_1") --
	self.txt_disagree_title_1:setString(TI18N("暂不支持合服"))
	self.my_vote_disagree_item:setVisible(false)

	self.miss_vote = self.bottom_panel_2:getChildByName("txt_didnt_vote") --
	self.miss_vote:setString(TI18N("您未参与本次投票"))
	self.miss_vote:setVisible(false)
	



	self.reward_bg_1 = self.main_container:getChildByName("reward_bg_1") --奖励 1 标题
	self.txt_reward_1 = self.reward_bg_1:getChildByName("txt_reward_1") 
	self.txt_reward_1:setString(self.merge_reward_title)


	self.reward_bg_2 = self.main_container:getChildByName("reward_bg_2") --奖励 2 标题
	self.txt_reward_2 = self.reward_bg_2:getChildByName("txt_reward_2")  
	self.txt_reward_2:setString(self.merge_welfare_title)

	
	self.win_title = self.main_container:getChildByName("win_title")  --标题
	self.win_title:setString(TI18N("合服意向调查"))

	self.close_btn = self.main_container:getChildByName("close_btn") --

	self.title_content_scroll = self.main_container:getChildByName("txt_title_content")   -- 介绍内容
	self.title_content_scroll_1 = self.main_container:getChildByName("txt_title_content_1")
	self.title_content_scroll_1:setVisible(false)
	--self.txt_title_content:setString(self.merge_introductions_text)
	-- 描述部分
   
    self.title_content_scroll:setScrollBarEnabled(false)
    --self.title_content_scroll:
    self.title_content_scroll_size = self.title_content_scroll:getContentSize()
    --createRichLabel(fontsize, textcolor, ap, pos, lineSpace, charSpace, max_width)
    self.desc_label = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(0, 90), 8, nil, 550) 
    self.desc_label:setString(self.merge_introductions_text)
    self.title_content_scroll:addChild(self.desc_label)
    self.title_content_scroll:setInnerContainerSize(cc.size(self.title_content_scroll_size.width, 90))

	self.reward_scroll = self.main_container:getChildByName("reward_scroll") -- 奖励scrollview
	--配置奖励icon
	local scroll_view_size = self.reward_scroll:getContentSize()
    local setting = {}
    setting.scale = 0.7
    setting.space_x = 15
    setting.is_center = false
    setting.max_count = 4
    local data_list = {}
    if self.reward_data then
        for k, v in pairs(self.reward_data) do
            table.insert(data_list, {v[1], v[2]})
        end
    end
    self.reward_scrollview = createScrollView(scroll_view_size.width, scroll_view_size.height, 0, 0, self.reward_scroll, ScrollViewDir.horizontal) 
    self.scroll_list = commonShowSingleRowItemList(self.reward_scrollview, self.scroll_list, data_list, setting)


    ----奖励第二弹内容配置
    self.reward_content_scroll_1 = self.main_container:getChildByName("reward_content_1") 
     self.reward_content_scroll_1:setVisible(false)
	self.reward_content_scroll = self.main_container:getChildByName("reward_content")
	self.reward_content_scroll:setScrollBarEnabled(false)
    self.scroll_size = self.reward_content_scroll:getContentSize()
	self.reward_content_scroll:setInnerContainerSize(cc.size(self.scroll_size.width, 170))
    self.reward_label_2 = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 1), cc.p(40, 170), 8, nil, 380) 
    self.reward_label_2:setString(self.reward_label)
    self.reward_content_scroll:addChild(self.reward_label_2)
	-- self.reward_content:setString(self.reward_label_2)
	-- local real_label = self.reward_content:getVirtualRenderer()
	 --   	if real_label then
	 --        real_label:setLineSpacing(10)  --设置行间距
	 --    end
end

function MergeserverLookWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function ()
		controller:openMergeWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function ()
		controller:openMergeWindow(false)
	end, false, 2)

	registerButtonEventListener(self.tips, function(param,sender, event_type)
		TipsManager:getInstance():showCommonTips(self.rule, sender:getTouchBeganPosition())
	end, true, 2)

	registerButtonEventListener(self.btn_vote, function ()
		self.can_touch = false
		if self.checkbox_agree:isSelected() == true  then --同意
			self.CheckboxStatus = 1
			self:setCheckboxGray(true)
		else 			--不同意
			self.CheckboxStatus = 0
			self:setCheckboxGray(false)
		end
		controller:sender10993(self.CheckboxStatus)  --发送 选项
		self:setBtnVisible(false)
	end, true, 2)

	self.checkbox_agree:addEventListener(function ( sender,event_type )  -- 投票状态与点击状态
			if event_type == ccui.CheckBoxEventType.selected then
	            playButtonSound2()
	            if self.checkbox_disagree:isSelected() == true then  --点击同意的时候 如果已经是 不同意的状态 重新勾选上
	            	self.checkbox_disagree:setSelected(false)
	            end
	            if self.can_touch == false then  --点击同意的时候 如果已经是 投完票的状态 重新勾选上
	            	self.checkbox_agree:setSelected(false)
	            	self.checkbox_disagree:setSelected(true)
	            end
	      	elseif event_type == ccui.CheckBoxEventType.unselected then 
	           playButtonSound2()
	           if self.can_touch == false then
	            	self.checkbox_agree:setSelected(true)
	            	self.checkbox_disagree:setSelected(false)
	            end
	       	end
        end)

	self.checkbox_disagree:addEventListener(function ( sender,event_type )
			if event_type == ccui.CheckBoxEventType.selected then
	            playButtonSound2()
	            if self.checkbox_agree:isSelected() == true then
	            	self.checkbox_agree:setSelected(false)	
	            end
	            if self.can_touch == false then
	            	self.checkbox_disagree:setSelected(false)
	            	self.checkbox_agree:setSelected(true)
	            end
	      	elseif event_type == ccui.CheckBoxEventType.unselected then 
	        	playButtonSound2()
	        	if self.can_touch == false then
	            	self.checkbox_disagree:setSelected(true)
	            	self.checkbox_agree:setSelected(false)
	            end
	        end
        end)

	self:addGlobalEvent(MergeserverEvent.Update_Main_Mergeserver_Event, function(data)
		if data and next(data) ~=nil then
			if data.status == 2 then  -- 公告期间
				controller:sender10992()
			end
			self:setData(data)
		end
	end)

	self:addGlobalEvent(MergeserverEvent.Update_Merge_MsgResult_Event, function(data)
		if data and next(data) ~=nil then
			self:setResultData(data)
		end
	end)
end


--显示已投票
function MergeserverLookWindow:setBtnVisible(bool)   --投票状态
	if bool == nil then return end
	self.btn_vote:setVisible(bool)
	self.txt_already_vote:setVisible(not bool)
end

--板娘
function MergeserverLookWindow:handleEffect(status)
    if status == false then
        if self.play_effect and self.play_effect_1 then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil

            self.play_effect_1:clearTracks()
            self.play_effect_1:removeFromParent()
            self.play_effect_1= nil
        end
    else
        if not tolua.isnull(self.main_container) and self.play_effect == nil and self.play_effect_1 == nil  then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(207), cc.p(-50,-70), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.play_effect_1 = createEffectSpine(PathTool.getEffectRes(206), cc.p(-50,-70), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.main_container:addChild(self.play_effect, -1)
            self.main_container:addChild(self.play_effect_1, 1)
        end
    end
end 


function MergeserverLookWindow:openRootWnd()
	controller:sender10991() -- 投票信息
	self:setCheckboxGray(model:getVotingStatus())--获取投票状态
	self.is_success = model:getVotingStatus() --投票是否成功
	if self.is_success == 1 then  --成功
		self:setBtnVisible(false) --投过票就把按钮隐藏了
	else 			
		self:setBtnVisible(true) --投过票就把按钮隐藏了
	end
	
end

--刷新公告结果
function MergeserverLookWindow:setResultData( data )
	self.result_data = data
	self.bottom_panel_2:setVisible(true)
	self.bottom_panel_1:setVisible(false)
	local rate_num = (data.agreepoints - data.disagreepoints)/ (data.agreepoints + data.disagreepoints)
	local num = rate_num * 1000 - math.floor(rate_num * 1000) + 0.5
	if num >= 1 then
		rate_num  = math.ceil(rate_num * 1000)/1000
	else
		rate_num = math.floor(rate_num * 1000)/1000
	end
	self.txt_agree_num:setString(string_format("%s%%", rate_num * 100))
	self.txt_disagree_num:setString(string_format("%s%%", (1-rate_num) * 100))
	self.rate_agree:setContentSize(cc.size(rate_num * 220,17))
	self.rate_disagree:setContentSize(cc.size((1 - rate_num) * 220,17))
	self.rate:setString(string_format("%s%%%s", rate_num * 100, "，"))
	if data.flag == 0 then 
		self.bottom_panel_1:setVisible(false)
		self.bottom_panel_2:setVisible(false)
	end
	if 	data.agreepoints == 0 and  data.disagreepoints == 0 then
		self.rate_agree:setVisible(false)
		self.rate_disagree:setVisible(false)
		self.rate:setString("0 %")
	end
	if (data.agreepoints - data.disagreepoints) < 0 then
		self.txt_agree_num:setString("0 %")
		self.txt_disagree_num:setString("100%")
		self.rate_agree:setContentSize(cc.size(0, 17))
		self.rate_disagree:setContentSize(cc.size(220, 17))
		self.rate:setString("0 %")
	end
	
end

--设置投票数据
function MergeserverLookWindow:setData( data )
	self.data = data
	if self.data.status == 1  then   --投票期间
		self.bottom_panel_1:setVisible(true)
		self.bottom_panel_2:setVisible(false)
		self.time_label:setAnchorPoint(0,0.5)
		self.time_label:setPositionX(450)
		commonCountDownTime(self.time_label,self.data.last_time) --设置倒计时
		if self.data.is_vote == 1 then  --已经投过票了
			self.can_touch = false
			local status = true
			if self.data.flag == 1 then
				status = true
			else
				status = false
			end
			self:setCheckboxGray(status)  --flag 1赞同 0 反对
			self:setBtnVisible(false) --投过票就把按钮隐藏了
		else
			self:setBtnVisible(true)
		end
	elseif  self.data.status == 2  then  --公告期间
		self.bottom_panel_1:setVisible(false)
		self.bottom_panel_2:setVisible(true)
		model:setMainuiAction(false)
		if self.data.is_vote == 1 then  --投过
			if self.data.flag == 1 then --赞同
				self.my_vote_agree_item:setVisible(true)
				self.my_vote_disagree_item:setVisible(false)
				self.miss_vote:setVisible(false)
			else--反对或者没投过
				self.my_vote_agree_item:setVisible(false)
				self.my_vote_disagree_item:setVisible(true)
				self.miss_vote:setVisible(false)
			end
		else --未投过   
			self.my_vote:setVisible(false)
			self.miss_vote:setVisible(true)
		end
	end
end


--投过票置灰
function MergeserverLookWindow:setCheckboxGray( bool )
	if bool == nil then return end
	self.checkbox_agree:setSelected(bool)
	self.checkbox_disagree:setSelected(not bool)
	self.checkbox_agree:setOpacity(178)
	self.checkbox_disagree:setOpacity(178)

end

function MergeserverLookWindow:close_callback(  )
	self:handleEffect(false)
	controller:openMergeWindow(false)
end