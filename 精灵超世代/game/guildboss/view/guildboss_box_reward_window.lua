-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会副本宝箱奖励面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossBoxRewardWindow = GuildBossBoxRewardWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()

function GuildBossBoxRewardWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Mini
	self.is_full_screen = false
	self.layout_name = "guildboss/guildboss_box_reward_window"

	self.is_wait_close = false -- 点击了宝箱开启，等到处理
	
	self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "guildboss/guildboss_1"), type = ResourcesType.single}, 
    }
end 

function GuildBossBoxRewardWindow:open_callback()
	local background = self.root_wnd:getChildByName("background")
	background:setScale(display.getMaxScale())
	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
	container:getChildByName("win_title"):setString(TI18N("击杀宝箱"))
	container:getChildByName("reward_notice"):setString(TI18N("宝箱随机开出以下奖励中的一种"))

	self.close_btn = container:getChildByName("close_btn")

	self.chapter_name = container:getChildByName("chapter_name")
	self.box_sum = container:getChildByName("box_sum")
	self.box_sum:setString(string.format(TI18N("拥有宝箱：%s"), 0))

	self.model = container:getChildByName("model")

	self.scroll_view = container:getChildByName("scroll_view")
	local size = self.scroll_view:getContentSize()
	local setting = {
		item_class = BackPackItem,
		start_x = -10,
		space_x = -16,
		start_y = -4,
		space_y = 0,
		item_width = 119,
		item_height = 119,
		row = 1,
		col = 1
	}
	self.item_scroll = CommonScrollViewLayout.new(self.scroll_view, nil, ScrollViewDir.horizontal, nil, size, setting) 

	self.box_tips = container:getChildByName("box_tips")
	self.box_tips:setString(TI18N("点击宝箱打开获得奖励"))

	self.no_box_tips = container:getChildByName("no_box_tips")
	self.no_box_tips:setString(TI18N("抱歉，当前无任何宝箱\n快去击杀BOSS，获得宝箱吧"))
end

function GuildBossBoxRewardWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openGuildBossBoxRewardWindow(false)
		end
	end) 

	if self.update_box_status_event == nil then
		self.update_box_status_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateBoxRewardsStatus, function(status)
			self:updateBoxStatus()
		end)
	end

	self.model:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if not self.is_wait_close and not tolua.isnull(self.box_effect) and self.show_fid then
				self.is_wait_close = true
				self.box_effect:setAnimation(0, PlayerAction.action_3, false)
			end
		end
	end) 

	if self.close_item_extend_window == nil then
		self.close_item_extend_window = GlobalEvent:getInstance():Bind(EventId.CAN_OPEN_LEVUPGRADE, function()
			if self.is_wait_close == true then
				self.is_wait_close = false
				self:changeBoxStatus(self.wait_change_sum)
				self.wait_change_sum = nil
			end
		end)
	end
end

function GuildBossBoxRewardWindow:openRootWnd()
	self:updateBoxStatus()
end

function GuildBossBoxRewardWindow:updateBoxStatus()
	local box_list = model:getBoxRewardList()
	local fid, sum = 0, 0
	for i,v in ipairs(box_list) do
		if v and v > 0 then
			if fid == 0 then
				fid = i
			end
			sum = sum + v		-- 计算总宝箱数量
		end
	end
	self.box_sum:setString(string.format(TI18N("拥有宝箱：%s"), sum)) 
	self.no_box_tips:setVisible(fid == 0)
	self.box_tips:setVisible(fid ~= 0)

	-- 如果有宝箱，或者没宝箱的时候,如果没有宝箱，就取当前的挑战章节做显示，否则取有宝箱的那个章节
	if fid == 0 then
		local base_info = model:getBaseInfo()
		if base_info ~= nil then
			fid = base_info.fid
		end
	end
	if fid == 0 then return end
	if fid ~= self.show_fid then
		self.show_fid = fid
		local config = Config.GuildDunData.data_chapter_reward[fid]
		if config then
			self.chapter_name:setString(config.chapter_name.." "..config.chapter_desc)
		end
		-- 宝箱奖励
		local box_config = Config.GuildDunData.data_chapter_box[fid]
		if box_config then
			local item_list = {}
			for i,v in ipairs(box_config.cli_award_list) do
				item_list[i] = {bid = v[1], quantity = v[2]}
			end
			self.item_scroll:setData(item_list,nil, nil, {scale=0.8})
		end
	end

	if not self.is_wait_close then
		self:changeBoxStatus(sum)
	else
		self.wait_change_sum = sum
	end
end

--==============================--
--desc:改变宝箱状态
--time:2018-06-15 02:43:24
--@return 
--==============================--
function GuildBossBoxRewardWindow:changeBoxStatus(sum)
	if sum == nil then return end
	if sum == 0 then
		self.model:setTouchEnabled(false)
		self:handleEffect(true, PlayerAction.action_1)
	else
		self.model:setTouchEnabled(true)
		self:handleEffect(true, PlayerAction.action_2)
	end
end

function GuildBossBoxRewardWindow:handleEffect(status, action)
	if status == false then
		if self.box_effect then
			self.box_effect:removeFromParent()
			self.box_effect = nil
		end
	else
		if self.box_effect == nil then
			self.box_effect = createEffectSpine(PathTool.getEffectRes(144), cc.p(120,40), cc.p(0, 0), true, action)
			self.model:addChild(self.box_effect, 1)
			-- 播放完特效之后，请求领取宝箱
			local function animationCompleteFunc(event)
				if event.animation == PlayerAction.action_3 then
					if self.show_fid then
						controller:requestGetChapterBox(self.show_fid)
					end
				end
			end
			self.box_effect:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE) 
		else
			self.box_effect:setAnimation(0, action, true) 
		end
	end
end 

function GuildBossBoxRewardWindow:close_callback()
	if self.close_item_extend_window then
		GlobalEvent:getInstance():UnBind(self.close_item_extend_window)
		self.close_item_extend_window = nil
	end
	self:handleEffect(false)
	if self.update_box_status_event then
		GlobalEvent:getInstance():UnBind(self.update_box_status_event)
		self.update_box_status_event = nil
	end
	if self.item_scroll then
		self.item_scroll:DeleteMe()
		self.item_scroll = nil
	end
    controller:openGuildBossBoxRewardWindow(false)
end