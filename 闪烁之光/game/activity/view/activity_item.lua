--[[
活动 Item 项
--]]
ActivityItem = class("ActivityItem", function()
	return ccui.Widget:create()
end)

function ActivityItem:ctor()
	self.is_double = false
	self.list_item = {}
	self:createRootWnd()
	self:registerEvent()
end

function ActivityItem:createRootWnd()
	self.count = nil

	self.rootWnd = createCSBNote(PathTool.getTargetCSB("activity/activity_item"))
	self:setAnchorPoint(cc.p(0, 1))
	self:addChild(self.rootWnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(605,165))

	self.mainContainer = self.rootWnd:getChildByName("main_container")

	self.itemMask = self.mainContainer:getChildByName("itemMask")
	self.textLimit = self.itemMask:getChildByName("textLimit")
	self.textLimit:setString(TI18N("敬请期待"))
	self.itemMask:setLocalZOrder(11)

	self.btnRule = self.mainContainer:getChildByName("btnRule")
	self.btnRule:setTouchEnabled(false)

	self.textTimeStart = self.mainContainer:getChildByName("textTimeStart")
	self.textTimeStart:setString("")
	self.textTimeStart:setVisible(false)
	self.itemBG = self.mainContainer:getChildByName("itemBG")
	self.redPoint = self.mainContainer:getChildByName("redPoint")
	self.redPoint:setVisible(false)
end
function ActivityItem:setData(data)
	self.activityData = data
	self:changeItemData(data)

	-- 引导使用,不要删
	if data and data.id then
		self:setName("guide_activity_item_"..data.id)
	end
end
function ActivityItem:getData()
	return self.activityData
end
function ActivityItem:addCallBack( value )
	self.callback =  value
end
function ActivityItem:registerEvent()
	if self.btnRule then
		self.btnRule:addTouchEventListener(function(sender, event_type) 
			if event_type == ccui.TouchEventType.ended then
				if self.activityData.id == ActivityConst.limit_index.escort then
					MainuiController:getInstance():openCommonExplainView(true, Config.EscortData.data_explain)
				elseif self.activityData.id == ActivityConst.limit_index.union then
					MainuiController:getInstance():openCommonExplainView(true, Config.GuildDunData.data_explain)
				elseif self.activityData.id == ActivityConst.limit_index.fightFirst then

				elseif self.activityData.id == ActivityConst.limit_index.allGod then
					MainuiController:getInstance():openCommonExplainView(true, Config.ZsWarData.data_explain)
				elseif self.activityData.id == ActivityConst.limit_index.guildwar then
					MainuiController:getInstance():openCommonExplainView(true, Config.GuildWarData.data_explain)
				elseif self.activityData.id == ActivityConst.limit_index.champion then
					MainuiController:getInstance():openCommonExplainView(true, Config.ArenaChampionData.data_explain)
				elseif self.activityData.id == ActivityConst.limit_index.ladder then
					MainuiController:getInstance():openCommonExplainView(true, Config.SkyLadderData.data_explain)
				end
			end
		end)
	end

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
end

function ActivityItem:updateRedStatus()
	if self.activityData then
		local red_status = false
		if self.activityData.id == ActivityConst.limit_index.union  then
			if GuildbossController:getInstance():getModel():getChangeCount() == true and 
				ActivityController:getInstance():getBossActivityDoubleTime() == true and
				ActivityController:getInstance():getFirstComeGuild() == true then
				red_status = true
			end
		elseif self.activityData.id == ActivityConst.limit_index.guildwar then
			red_status = GuildwarController:getInstance():getModel():checkGuildGuildWarRedStatus()
		elseif self.activityData.id == ActivityConst.limit_index.ladder then
			red_status = LadderController:getInstance():getModel():checkLadderRedStatus()
		end

		self.redPoint:setVisible(red_status)
	end
end

function ActivityItem:changeItemData(data)
	if data.val[1] then
	    for i,v in pairs(data.val[1]) do
	    	if not self.list_item[i] then
		    	local item = BackPackItem.new(nil,true,nil,0.5)
		    	if self.mainContainer then
				    self.mainContainer:addChild(item,1)
				end
			    self.list_item[i] = item
			end
			if self.list_item[i] then
			    self.list_item[i]:setPosition(cc.p(40*i + (24*i-1), 67))
			    self.list_item[i]:setBaseData(v)
				self.list_item[i]:setDoubleIcon(self.is_double)
				self.list_item[i]:setDefaultTip()
			end
	    end
	end


	self:limitItemData(data)
	
	if data.desc then
		if self.textTimeStart then
	    	self.textTimeStart:setString(data.desc)
	    	self.textTimeStart:setVisible(true)
	    end
    end
end

--限时活动子项
function ActivityItem:limitItemData(data)
	local role_vo = RoleController:getInstance():getRoleVo()
	local res = PathTool.getTargetRes("activity/activity_big", "txt_cn_activity_item_"..data.id, false, false)
	loadSpriteTexture(self.itemBG,res,LOADTEXT_TYPE)
	
	if data.is_open == 1 then
		local _bool = MainuiController:getInstance():checkIsOpenByActivate(data.activate)
		if _bool == true then
			self:setTouchEnabled(true)
			self:handleEffect(true)
			self.itemMask:setVisible(false)
			if self.btnRule then self.btnRule:setTouchEnabled(true) end

			if data.id == ActivityConst.limit_index.union then
				if role_vo.gname == "" then
					self.textLimit:setString(TI18N("当前未加入公会"))
					self:handleEffect(false)
					self.itemMask:setVisible(true)
					self.itemMask:setTouchEnabled(true)
				end
			end
		else
			self:handleEffect(false)
			if self.btnRule then self.btnRule:setTouchEnabled(false) end
			self.textLimit:setString(data.lock_desc)
		end
	else
		if data.id == ActivityConst.limit_index.union then
			if role_vo.gname ~= "" then
				self.textLimit:setString(TI18N("公会副本玩法暂未开启"))
			end
		end
	end
end

function ActivityItem:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if not tolua.isnull(self.mainContainer) and self.play_effect == nil then
        	self.play_effect = createEffectSpine(PathTool.getEffectRes(505), cc.p(self.itemBG:getContentSize().width-106, 28), cc.p(1, 0), true, PlayerAction.action)
            self.mainContainer:addChild(self.play_effect, 1)
        end
	end
end

function ActivityItem:DeleteMe()
	if self.list_item and next(self.list_item) ~= nil then
		for i,v in ipairs(self.list_item) do
			if v.DeleteMe then
		        v:DeleteMe()
		    end
	    end
	end
    self.list_item = {}

	self:handleEffect(false)
	self:removeAllChildren()
	self:removeFromParent()
	self.count = nil
end

