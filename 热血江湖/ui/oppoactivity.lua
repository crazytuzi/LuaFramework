module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_oppoActivity = i3k_class("wnd_oppoActivity", ui.wnd_base)


local PRIVILEGE_STATE	 = 1		--特权
local WELFARE_STATE		 = 2		--福利

local DAY_ACTIVITY = 1				--天奖励
local WEEK_ACTIVITY = 2				--周奖励
local VIP_ACTIVITY = 3				-- vip奖励

local VIP_LVL_ACTIVITY = 4			-- VIP等级奖励

function wnd_oppoActivity:ctor()
	self.rightState = PRIVILEGE_STATE
end

function wnd_oppoActivity:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.privilege_btn:onClick(self, self.onRightClick, PRIVILEGE_STATE)
	widgets.welfare_btn:onClick(self, self.onRightClick, WELFARE_STATE)
	widgets.privilegeUI:show()
	widgets.welfareUI:hide()
	i3k_game_get_oppo_info()
	
end

function wnd_oppoActivity:refresh(state, info, rewardLog, curVipLevel)
	if state then
		self.rightState = state
	end
	self._vip_info = {
		info = info,
		rewardLog = rewardLog,
		curVipLevel = curVipLevel,
	}
	self:updateRightBtnState(info, rewardLog, curVipLevel)
	self:refreshRed()
end

function wnd_oppoActivity:updateRightBtnState(info, rewardLog, curVipLevel)
	local widgets = self._layout.vars
	if self.rightState == WELFARE_STATE then
		--福利按钮
		widgets.privilegeUI:hide()
		widgets.welfareUI:show()
		self:setWelfareView(info, rewardLog, curVipLevel)
		widgets.privilege_btn:stateToNormal()
		widgets.welfare_btn:stateToPressed()
	else
		widgets.welfareUI:hide()
		widgets.privilegeUI:show()
		self:setPrivilegeList(info, rewardLog, curVipLevel)
		self:setPrivilegeDesc(info, rewardLog, curVipLevel)
		widgets.privilege_btn:stateToPressed()
		widgets.welfare_btn:stateToNormal()
    end
end

--切换页签
function wnd_oppoActivity:onRightClick(sender, state)
	self.rightState = state 
	self:updateRightBtnState(self._vip_info.info, self._vip_info.rewardLog, self._vip_info.curVipLevel)
end


--设置特权
function wnd_oppoActivity:setPrivilegeList(info, rewardLog, curVipLevel, jump)
	local widgets = self._layout.vars
	widgets.privilegeScroll:removeAllChildren()
	--local info = g_i3k_game_context:getOppoActivitySyncInfo()
	for i, j in pairs(info.levelReward) do
		local node = require("ui/widgets/oppoflt2")()
		node.vars.desc:setText(i)
		self:setItems(j.gifts, node)
		if  curVipLevel < i then
			node.vars.rewardBtn:disable()	
		end
		if rewardLog and rewardLog.levelReward[i] then
			node.vars.reward:show()
			node.vars.rewardBtn:hide()
		end
		node.vars.rewardBtn:onClick(self, self.onReward, {level = i, state = VIP_LVL_ACTIVITY, items = j.gifts, index = i })
		widgets.privilegeScroll:addItem(node) 
	end
	if jump then
		widgets.privilegeScroll:jumpToChildWithIndex(jump)
	end
	
end

--设置特权描述
function wnd_oppoActivity:setPrivilegeDesc(info, rewardLog, curVipLevel)
	local widgets = self._layout.vars
	self.descList = widgets.descList
	widgets.descList:removeAllChildren()
	widgets.title:setText(info.title)
	local node = require("ui/widgets/oppoflt1")()
	node.vars.ruleDesc:setText(info.content)
	widgets.descList:addItem(node)
	g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
		local textUI = node.vars.ruleDesc
		local size = node.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		node.rootVar:changeSizeInScroll(ui.descList, width, height, true)
	end, 1)
end

--设置福利
function wnd_oppoActivity:setWelfareView(info, rewardLog, curVipLevel)
	local widgets = self._layout.vars
	local infCfg = { 
		[DAY_ACTIVITY]	= { items = info.dayReward,  lastTime = rewardLog.lastDayReward, desc = 5527, helpDesc = 5528,  },
		[WEEK_ACTIVITY]	= { items = info.weekReward, lastTime = rewardLog.lastWeekReward,  desc = 5529, helpDesc = 5530, },
		[VIP_ACTIVITY]	= { items = info.levelDayReward[curVipLevel > 0 and curVipLevel or 1].gifts, lastTime = rewardLog.lastLevelDayReward,  desc = 5531, helpDesc = 5532,},		
	}
	for i, j in pairs(infCfg) do
		widgets["welfareDesc"..i]:setText(i3k_get_string(j.desc))
		widgets["welfareHelp"..i]:setText(i3k_get_string(j.helpDesc))
		self:setWelfareItems(widgets["scroll"..i], j.items)
		local isReward = WEEK_ACTIVITY == i and g_i3k_get_week_count(g_i3k_get_day(i3k_game_get_time())) <= g_i3k_get_week_count(g_i3k_get_day(j.lastTime)) or g_i3k_get_day(i3k_game_get_time()) <= g_i3k_get_day(j.lastTime)
		if  isReward then	
			
			widgets["welfareBtnDesc"..i]:setText("已领取")
			widgets["welfareBtn"..i]:disable()
		end
		
		
		local gameCenter = g_i3k_game_context:GetIsOppoGameCenter()
		if i == DAY_ACTIVITY and not gameCenter then
			widgets["welfareBtn"..i]:disable()
		end
		if i == VIP_ACTIVITY and  curVipLevel <= 0 then
			widgets["welfareBtn"..i]:disable()
		end
		widgets["welfareBtn"..i]:onClick(self, self.onReward, {state = i, level = curVipLevel, items = j.items})
	end

	
end

--设置福利items
function wnd_oppoActivity:setWelfareItems(scroll, info)
	scroll:removeAllChildren()
	for k, v in ipairs(info) do
		local node = require("ui/widgets/oppoflt3")()	
		node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,g_i3k_game_context:IsFemaleRole()))
		node.vars.item_count:setText(v.count)
		node.vars.Btn:onClick(self,function(id) g_i3k_ui_mgr:ShowCommonItemInfo(v.id) end)
		node.vars.item_suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(v.id))
		scroll:addItem(node) 
		
	end
	
	
end

--设置items
function wnd_oppoActivity:setItems(info, node, isReward)
	for k = 1, 3 do
		local cfg = info[k]
		if node.vars["item_bg"..k] and cfg  then
			node.vars["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.id))
			node.vars["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.id,g_i3k_game_context:IsFemaleRole()))
			node.vars["item_count"..k]:setText("x"..cfg.count)
			node.vars["Btn"..k]:onClick(self,function(id) g_i3k_ui_mgr:ShowCommonItemInfo(cfg.id) end)
			node.vars["item_suo"..k]:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(cfg.id))
			if isReward and node.vars["alreadyGet"..k] then 
				node.vars["alreadyGet"..k]:show()
			end
		else
			node.vars["item_bg"..k]:hide()
		end
	end
end

--刷新红点
function wnd_oppoActivity:refreshRed()
	self._layout.vars.privilegeRed:setVisible(false)
	self._layout.vars.welfareRed:setVisible(false)
end

-----------Btn---------------------------

--领取特权
function wnd_oppoActivity:onReward(sender, info)
	local activityId = g_i3k_game_context:GetOppoActivityId()
	if info.state == DAY_ACTIVITY then
		i3k_sbean.oppo_vip_day_reward_take(activityId, info.items)
	elseif info.state == WEEK_ACTIVITY then	
		i3k_sbean.oppo_vip_week_reward_take(activityId, info.items)			
	elseif info.state == VIP_ACTIVITY then
		i3k_sbean.oppo_vip_level_day_reward_take(activityId, info.level, info.items)
	elseif info.state == VIP_LVL_ACTIVITY then	
		i3k_sbean.oppo_vip_level_reward_take(activityId, info.level, info.items,  info.index)
	end
end

function wnd_create(layout,...)
	local wnd = wnd_oppoActivity.new();
		wnd:create(layout,...)
	return wnd;
end
