
-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会列表单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildRequestItem = class("GuildRequestItem", function()
	return ccui.Layout:create()
end)

local controller = GuildController:getInstance()
local  string_format = string.format
local  math_floor = math.floor

function GuildRequestItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guild/guild_list_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	local container = self.root_wnd:getChildByName("container")
	
	self.request_btn = container:getChildByName("request_btn")
	self.request_btn_label = self.request_btn:getChildByName("label")
	self.request_btn_label:setString(TI18N("申请加入"))
	self.leader_title = container:getChildByName("leader_title")
	self.leader_title:setString(TI18N("盟主"))

	self.condition_desc = container:getChildByName("condition_desc")
	self.limit_level = container:getChildByName("limit_level")
	self.limit_power = container:getChildByName("limit_power")
	self.guild_name = container:getChildByName("guild_name")
	self.guild_lev = container:getChildByName("guild_lev") 
	self.leader_value = container:getChildByName("leader_value")
	self.member_value = container:getChildByName("member_value")

	local member_title = container:getChildByName("member_title")
	member_title:setString(TI18N("人数："))
	
	self.btn_res_id = PathTool.getResFrame("common", "common_1018")

	self:registerEvent()
end

function GuildRequestItem:registerEvent()
	self.request_btn:addTouchEventListener(
	function(sender, event_type)
		customClickAction(sender, event_type,0.8)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data ~= nil then
				if self.data.is_apply == TRUE then -- 这个时候点击就是取消掉状态
					controller:requestJoinGuild(self.data.gid, self.data.gsrv_id, 2) 
				else
					controller:requestJoinGuild(self.data.gid, self.data.gsrv_id, 1) 
				end
			end
		end
	end
	)
end

function GuildRequestItem:setData(data)
	if self.data ~= nil then
		if self.update_self_event ~= nil then
			self.data:UnBind(self.update_self_event)
			self.update_self_event = nil
		end
	end
	if data ~= nil then
		self.data = data
		if self.update_self_event == nil then
			self.update_self_event = self.data:Bind(GuildEvent.UpdateGuildItemEvent, function(key, value) 
				if key == "is_apply" then			-- 只有申请状态变化时候才做更新
					self:setApplyStatus()
				end
			end)
		end
		self.guild_name:setString(data.name)
		self.guild_lev:setString(string.format(TI18N("(%s级)"), data.lev))
		self.leader_value:setString(string.format(TI18N("%s"), data.leader_name))
		

		self:setApplyStatus()
		self.member_value:setString(string.format("%s/%s", data.members_num, data.members_max))
		if data.members_num >= data.members_max then
			setChildUnEnabled(true, self.request_btn)
			self.condition_desc:setString("")
			-- self.request_btn:setPositionY(67)
			self.request_btn:setTouchEnabled(false)
			self.request_btn_label:setString(TI18N("满人"))
			self.request_btn_label:disableEffect()
			self.member_value:setTextColor(Config.ColorData.data_color4[183]) 
		else
			-- self.request_btn:setPositionY(81)
			-- setChildUnEnabled(false, self.request_btn)
			-- self.request_btn:setTouchEnabled(true)
			-- self.request_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
			self.member_value:setTextColor(cc.c4b(0x24,0x90,0x03,0xff)) -- 249003
		end
		self.guild_lev:setPositionX(self.guild_name:getPositionX() + self.guild_name:getContentSize().width + 5)
	end
end

function GuildRequestItem:setApplyStatus()
	if self.data == nil then return end
	local role_vo = RoleController:getInstance():getRoleVo() 
	if role_vo == nil then return end
	local data = self.data
	self.is_ok = true
	self:updateLimitInfo(data)
	if data.is_apply == TRUE then
		setChildUnEnabled(false, self.request_btn) 
    	--self.request_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
		self.request_btn_label:setString(TI18N("取消"))
		if self.btn_res_id ~= PathTool.getResFrame("common","common_1018") then
			self.btn_res_id = PathTool.getResFrame("common","common_1018")
			self.request_btn:loadTexture(self.btn_res_id, LOADTEXT_TYPE_PLIST) 
		end
		if data.apply_type == 2 then
			self.request_btn:setTouchEnabled(true)
			self.condition_desc:setTextColor(Config.ColorData.data_color4[183]) 
			self.condition_desc:setString(TI18N("公会不允许加入"))  --红字
		else
			if not self.is_ok then
				self.request_btn:setTouchEnabled(false) 
			else
				self.request_btn:setTouchEnabled(true) 
			end 
			self.condition_desc:setString("")
		end
	else
		if self.btn_res_id ~= PathTool.getResFrame("common", "common_1018") then
			self.btn_res_id = PathTool.getResFrame("common", "common_1018")
			self.request_btn:loadTexture(self.btn_res_id, LOADTEXT_TYPE_PLIST)
		end 
		if data.apply_type == 2 then	-- 不允许
			setChildUnEnabled(true, self.request_btn)
			self.request_btn_label:disableEffect()
			self.request_btn:setTouchEnabled(false) 
			self.request_btn_label:setString(TI18N("申请"))				-- 按钮灰掉
			self.condition_desc:setTextColor(Config.ColorData.data_color4[183]) 
			self.condition_desc:setString(TI18N("公会不允许加入"))			 -- 红字
		else
			if not self.is_ok then
				setChildUnEnabled(true, self.request_btn) 
				self.request_btn_label:disableEffect()
				self.request_btn:setTouchEnabled(false) 
				self.request_btn_label:setString(TI18N("申请"))			-- 按钮灰掉
			else
				setChildUnEnabled(false, self.request_btn) 
    			--self.request_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
				self.request_btn:setTouchEnabled(true) 
				self.request_btn_label:setString(TI18N("申请"))
			end
			self.condition_desc:setString("")
		end
	end 
end


--更新条件信息
function GuildRequestItem:updateLimitInfo( data )
	if not data then return end
	local role_vo = RoleController:getInstance():getRoleVo() 
	if not role_vo then return end
    if data.apply_lev <= 1 then
        self.limit_level:setVisible(false)
    else
        self.limit_level:setVisible(true)
        self.limit_level:setString(string_format(TI18N("等级: %s级"), data.apply_lev))
        if role_vo and role_vo.lev >= data.apply_lev then
            self.limit_level:setTextColor(cc.c3b(0x24,0x90,0x03))
        else
            self.limit_level:setTextColor(cc.c3b(0xd9,0x50,0x14))
            self.is_ok = false
        end
    end

    if data.apply_power == 0 then
        self.limit_power:setVisible(false)
    else
        self.limit_power:setVisible(true)
        local  power = MoneyTool.GetMoneyString(data.apply_power)
        self.limit_power:setString( string_format(TI18N("战力") .. ":%s",power))
        if role_vo and role_vo.power >= data.apply_power then
            self.limit_power:setTextColor(cc.c3b(0x24,0x90,0x03))
        else
            self.limit_power:setTextColor(cc.c3b(0xd9,0x50,0x14))
            self.is_ok = false
        end
    end        
end

function GuildRequestItem:suspendAllActions()
	if self.data ~= nil then
		if self.update_self_event ~= nil then
			self.data:UnBind(self.update_self_event)
			self.update_self_event = nil
		end
		self.data = nil
	end 
end

function GuildRequestItem:DeleteMe()
	if self.data ~= nil then
		if self.update_self_event ~= nil then
			self.data:UnBind(self.update_self_event)
			self.update_self_event = nil
		end
		self.data = nil
	end 
	self:removeAllChildren()
	self:removeFromParent()
end 