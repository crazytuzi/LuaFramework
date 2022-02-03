-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      点击通用回调界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
CommonOptionsList = class("CommonOptionsList", function() 
	return ccui.Widget:create()
end)

CommonOptionsList.TypeName = {
	[1]	= {name = TI18N("查看信息"), func = "check_role"},      			-- 查看信息
	[2]	= {name = TI18N("召唤队友"), func = "summon_member"}, 				-- 召唤队员
	[3]	= {name = TI18N("请离队友"), func = "expel_member"}, 				-- 开除队员
	[4]	= {name = TI18N("升为队长"), func = "promote_leader"},				-- 提升队长
	[5]	= {name = TI18N("顶替队长"), func = "replace_leader"},				-- 顶替队长
	[6]	= {name = TI18N("暂离队伍"), func = "afk_team"}, 					-- 暂离
	[7]	= {name = TI18N("回到队伍"), func = "return_team"}, 				-- 归队
	[8]	= {name = TI18N("解散队伍"), func = "dissolve_team"}, 				-- 解散队伍
	[9]	= {name = TI18N("退出队伍"), func = "exit_team"},					-- 退出队伍
	[10]= {name = TI18N("督促准备"), func = "order_member"}, 				-- 督促准备

	[12]= {name = TI18N("任命盟主"), func = "set_leader"}, 					-- 任命盟主
	[13]= {name = TI18N("任命副盟主"), func = "set_assistant"}, 			-- 任命副盟主
	[14]= {name = TI18N("设置成员"), func = "set_member"}, 					-- 设为成员
	[15]= {name = TI18N("加为好友"), func = "add_friend"}, 					-- 加为好友
	[16]= {name = TI18N("踢出联盟"), func = "kick_guild"}, 					-- 踢出联盟
	[17]= {name = TI18N("弹劾盟主"), func = "impeach_leader"}, 				-- 弹劾盟主
	[18]= {name = TI18N("发起私聊"), func = "talk_with"}, 					-- 发起私聊
	[19]= {name = TI18N("退出联盟"), func = "exit_guild"}, 					-- 退出联盟
}

function CommonOptionsList:ctor(parent, anchorpoint, pos)
	self:initConfig()

	self:setContentSize(cc.size(self.width, 50))
	if parent ~= nil then
		parent:addChild(self)
	end
	anchorpoint = anchorpoint or cc.p(0.5,0.5)
	self:setAnchorPoint(anchorpoint)
	if pos ~= nil then
		self:setPosition(pos)
	end

	self:registerEvent()
end

function CommonOptionsList:initConfig()
	self.width = 186
	self.btn_width = 161
	self.btn_height = 59
end

function CommonOptionsList:registerEvent()
end

function CommonOptionsList:setDataList(data, target)
	if data == nil or target == nil or next(data) == nil then
		return
	end
	local sum = #data
	self.height = sum * self.btn_height + 18
	self:setContentSize(cc.size(self.width, self.height))

	if self.container == nil then
		self.container = createImage(self, PathTool.getResFrame("common", "common_90005"), 0, 0, cc.p(0, 0), true)
	end
	self.container:setScale9Enabled(true)
	self.container:setContentSize(cc.size(self.width, self.height))

	for k,v in pairs(self.container:getChildren()) do
		if v.DeleteMe then
			v:DeleteMe()
			v = nil
		end
	end

	-- 点击按钮关闭自身
	local function setVisibleStatus()
		if self ~= nil then
			self:setVisible(false)
		end
	end

	-- 开始创建
	local btn_info_data = nil
	local btn_index = 1
	for i,v in ipairs(data) do
		btn_info_data = CommonOptionsList.TypeName[v]
		if btn_info_data ~= nil then
			local btn = CommonOptionsListBtn.new(self.container, btn_info_data.func, btn_info_data.name, target, self.btn_width, self.btn_height, setVisibleStatus)
			btn:setPosition(cc.p(self.width/2, self.height-10-btn:getSize().height/2-(btn_index-1)*self.btn_height))
			btn_index = btn_index + 1
		end
	end
end

function CommonOptionsList:DeleteMe()
	for k,v in pairs(self.container:getChildren()) do
		if v.DeleteMe then
			v:DeleteMe()
			v = nil
		end
	end
	self:removeAllChildren()
	self:removeFromParent()
end


CommonOptionsListBtn = class("CommonOptionsListBtn", function() 
	return ccui.Widget:create()
end)

function CommonOptionsListBtn:ctor(parent, func_name, label_str, target, width, height, call_back)
	self.func_name = func_name
	self.target = target
	self.call_back = call_back
	self.size = cc.size(width,height)
	self:setContentSize(self.size)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(true)
	self:setCascadeOpacityEnabled(true)

	if not tolua.isnull(parent) then
		parent:addChild(self)
	end
	self.button = createButton(self, label_str, width*0.5, height*0.5, self.size, PathTool.getResFrame("common", "common_1027"), 25, Config.ColorData.data_color4[1])

	self:registerEvent()
end

function CommonOptionsListBtn:registerEvent()
	self.button:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended  then
			self[self.func_name](self)
			if self.call_back ~= nil then
				self:call_back()
			end
      	end
	end)
end

function CommonOptionsListBtn:getSize()
	return self.size
end

function CommonOptionsListBtn:summon_all_member()
	TeamController:getInstance():getModel():summonMember()	
end

-- 查看角色
function CommonOptionsListBtn:check_role()
end

-- 召唤队友
function CommonOptionsListBtn:summon_member()
	if self.target ~= nil then
		TeamController:getInstance():send_13214(self.target.rid, self.target.srv_id)	
	end
end

-- 开除队员
function CommonOptionsListBtn:expel_member()
	if self.target ~= nil then
		TeamController:getInstance():send_13211(self.target.rid, self.target.srv_id)	
	end
end

-- 提升队长
function CommonOptionsListBtn:promote_leader()
	if self.target ~= nil then
		TeamController:getInstance():send_13209(self.target.rid, self.target.srv_id)	
	end
end

-- 顶替队长
function CommonOptionsListBtn:replace_leader()
	TeamController:getInstance():send_13256()	
end

-- 暂离
function CommonOptionsListBtn:afk_team()
	TeamController:getInstance():send_13213()
end

-- 归队
function CommonOptionsListBtn:return_team()
	TeamController:getInstance():send_13217()
end

-- 解散队伍
function CommonOptionsListBtn:dissolve_team()
	TeamController:getInstance():send_13226()	
end

-- 退出队伍
function CommonOptionsListBtn:exit_team()
	TeamController:getInstance():send_13210()
end

--督促准备
function CommonOptionsListBtn:order_member()
	TeamController:getInstance():send_13294(self.target.srv_id,self.target.rid)
end

function CommonOptionsListBtn:set_leader()
	if self.target ~= nil then
		local config = Config.GuildData.data_position[1]
		if config == nil then return end
		local str = string.format( TI18N("确定任免 %s 为 %s 吗?现在反悔还来得及!"),  self.target.name, config.name)
		CommonAlert.show( str, TI18N("确定"), function()
			GuildController:getInstance():changeMemberPosition(self.target.rid, self.target.srv_id, 1)
    	end, TI18N("取消"))
	end
end
function CommonOptionsListBtn:set_assistant()
	if self.target ~= nil then
		local config = Config.GuildData.data_position[2]
		if config == nil then return end
		local str = string.format( TI18N("确定任免 %s 为 %s 吗?"),  self.target.name, config.name)
		CommonAlert.show( str, TI18N("确定"), function()
			GuildController:getInstance():changeMemberPosition(self.target.rid, self.target.srv_id, 2)
    	end, TI18N("取消"))
	end
end
function CommonOptionsListBtn:set_member()
	if self.target ~= nil then
		local config = Config.GuildData.data_position[3]
		if config == nil then return end
		local str = string.format( TI18N("确定将 %s 降职为 %s 吗?"),  self.target.name, config.name)
		CommonAlert.show( str, TI18N("确定"), function()
			GuildController:getInstance():changeMemberPosition(self.target.rid, self.target.srv_id, 3)
    	end, TI18N("取消"))
	end
end
function CommonOptionsListBtn:add_friend()
	if self.target ~= nil then
		 GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_ADD, self.target.srv_id, self.target.rid)
	end
end
function CommonOptionsListBtn:kick_guild()
	if self.target ~= nil then
		local str = string.format( TI18N("确定将 %s 踢出联盟吗? 真是狠心的盟主啊!"),  self.target.name)
		CommonAlert.show( str, TI18N("确定"), function()
			GuildController:getInstance():requestKickOutMember(self.target.rid, self.target.srv_id)
    	end, TI18N("取消"))
	end
end
function CommonOptionsListBtn:impeach_leader()
	-- 没有了弹劾盟主
end
function CommonOptionsListBtn:talk_with()
	if self.target ~= nil then
		local is_same = RoleController:getInstance():isTheSameSvr(self.target.srv_id)
    	local is_cross = not is_same
    	local freind_type = FriendConst.FriendGroupType.friend
        if is_cross == true then
            freind_type = FriendConst.FriendGroupType.cross_friend
        end
 		ContactController:getInstance():openContactPanel(ContactConst.ContactTypeConst.friend,{rid = self.target.rid,srv_id = self.target.srv_id},freind_type)
	end
end
function CommonOptionsListBtn:exit_guild()
	if self.target ~= nil then
		local str = string.format( TI18N("确定要退出联盟吗?给你机会考虑清楚"),  self.target.name)
		CommonAlert.show( str, TI18N("确定"), function()
			GuildController:getInstance():requestExitGuild()
    	end, TI18N("取消"))
	end
end

function CommonOptionsListBtn:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end