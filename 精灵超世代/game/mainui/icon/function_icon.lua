-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      游戏图标对象
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
FunctionIcon = class("FunctionIcon", function() 
	return ccui.Widget:create()
end)

local game_net = GameNet:getInstance()
local string_format = string.format

--@ data 对象结构是 FunctionIconVo
function FunctionIcon:ctor(data)
	self.time_ticket_desc = ""
	self.data = data
	if self.data.config.type == FunctionIconVo.type.right_top_1 or
	   self.data.config.type == FunctionIconVo.type.right_top_2 or 
	   self.data.config.type == FunctionIconVo.type.left_top then
		self.scb_path = PathTool.getTargetCSB("mainui/function_icon_left")
	elseif self.data.config.type == FunctionIconVo.type.right_bottom_1 or self.data.config.type == FunctionIconVo.type.right_bottom_2 then
		self.scb_path = PathTool.getTargetCSB("mainui/function_icon_right")
	end
	self.root_wnd = createCSBNote(self.scb_path)
	self:setCascadeOpacityEnabled(true)
	self:addChild(self.root_wnd)

	self.size = self.root_wnd:getContentSize()
	self.width = self.size.width
	self.height = self.size.height
	self:setContentSize(self.size)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(true)
	self:setName(data.config.name)

	self.container = self.root_wnd:getChildByName("main_container")
	self.button = self.container:getChildByName("button")
	self.tishi = self.container:getChildByName("tips")

	if self.data.config.type == FunctionIconVo.type.right_bottom_1 or self.data.config.type == FunctionIconVo.type.right_bottom_2 then
		self.num = self.container:getChildByName("num")
		self.num:setVisible(false)
		if self.data.config.id == MainuiConst.icon.mail or self.data.config.id == MainuiConst.icon.friend then
			loadSpriteTexture(self.tishi, PathTool.getResFrame("mainui", "mainui_1034"), LOADTEXT_TYPE_PLIST)
			self.tishi:setPosition(56,59)
		end
	else
		self.name = self.container:getChildByName("name")
		self:setIconName()
	end

	self:registerEvent()
	self:updateInfo()

	-- 7天登录特殊处理 
	if self.data and self.data.config then
		if self.data.config.id == MainuiConst.icon.seven_login or self.data.config.id == MainuiConst.icon.eight_logins then
			self:updateSevenLoginInfo()
		elseif self.data.config.id == MainuiConst.icon.icon_charge1 or self.data.config.id == MainuiConst.icon.icon_charge2 then
			self:updateFirstChargeInfo()
		elseif self.data.config.id == MainuiConst.icon.year_monster then--年兽活动开启时登录请求主城红包入口
			ActionyearmonsterController:getInstance():sender28223()
			ActionyearmonsterController:getInstance():sender28224()
			ActionyearmonsterController:getInstance():sender28200()
		elseif self.data.config.id == MainuiConst.icon.arena_many_people then--多人竞技场请求基础协议
			ArenaManyPeopleController:getInstance():sender29000()
			ArenaManyPeopleController:getInstance():sender29003()
			ArenaManyPeopleController:getInstance():sender29028()
			
		end
	end
end

--==============================--
--desc:更新自身,现在只处理显示tips与否
--time:2017-07-29 03:33:10
--@return 
--==============================--
function FunctionIcon:updateInfo()
	self:updateTishiState()
	self:updateIconRes()
	self:setIconName()

	-- 首充的特殊处理
	if self.data and self.data.config then
		if self.data.config.id == MainuiConst.icon.icon_charge1 or self.data.config.id == MainuiConst.icon.icon_charge2 then
			self:updateFirstChargeInfo()
		end
	end
	--推送礼包的处理
	if self.data and self.data.config then
		if self.data.config.id == MainuiConst.icon.personal_gift then
			FestivalActionController:getInstance():sender26301()
		end
	end
end

function FunctionIcon:updateIconRes()
	if self.data ~= nil and self.data.config ~= nil then
		if self.data.config.res_type == 1 then
			local res_id = self.data.real_res_id
			if res_id == "" then
				res_id = self.data.res_id
			end
			local target_res = PathTool.getFunctionRes(res_id)
			if target_res ~= self.res_id then
				self.res_id = target_res
				loadSpriteTexture(self.button, self.res_id, LOADTEXT_TYPE)
			end
		else
			if self.data.config.id == MainuiConst.icon.first_charge then
				local target_res = PathTool.getFunctionRes(self.data.res_id)
				if target_res ~= self.res_id then
					self.res_id = target_res
					loadSpriteTexture(self.button, self.res_id, LOADTEXT_TYPE)
				end
				self.button:setVisible(false)

				if self.icon_first_effect == nil then
	                self.icon_first_effect = createEffectSpine(self.data.config.icon_effect, nil, nil, true, nil, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	                self.icon_first_effect:setAnchorPoint(cc.p(0.5, 0.5))
	                self.icon_first_effect:setVisible(false)
	                self.icon_first_effect:setPosition(self.button:getContentSize().width*0.5,self.button:getContentSize().height*0.5+15)
	                self.container:addChild(self.icon_first_effect, -1)
				end

				local get_status = false
				for i=1,6 do
					local get_data = ActionController:getInstance():getModel():getFirstBtnStatus(i)
					if get_data then
						if get_data == 1 then
							get_status = true
							break
						end
					end
				end
				self.tishi:setVisible(get_status)

				local role_vo = RoleController:getInstance():getRoleVo()
				local num_vip_exp = role_vo.vip_exp / 10
				if num_vip_exp >= 100 then
					if get_status == true then
						if self.icon_first_effect then
							self.icon_first_effect:setVisible(true)
						end
						self.button:setVisible(false)
					else
						if self.icon_first_effect then
							self.icon_first_effect:setVisible(false)
						end
						self.button:setVisible(true)
					end
				else
					if self.icon_first_effect then
						self.icon_first_effect:setVisible(true)
					end
				end
			elseif self.data.config.id == MainuiConst.icon.personal_gift then
				if self.icon_gift_effect == nil then
	                self.icon_gift_effect = createEffectSpine(self.data.config.icon_effect, nil, nil, true, nil, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	                self.icon_gift_effect:setAnchorPoint(cc.p(0.5, 0.5))
	                self.icon_gift_effect:setVisible(true)
	                self.icon_gift_effect:setPosition(self.button:getContentSize().width*0.5,-10)
	                self.button:addChild(self.icon_gift_effect, 1)
				end
			else
				if self.icon_effect == nil then
	                self.icon_effect = createEffectSpine(self.data.config.icon_effect, nil, nil, true, nil, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	                self.icon_effect:setAnchorPoint(cc.p(0.5, 0.5))
	                self.icon_effect:setVisible(true)
	                self.icon_effect:setPosition(self.button:getContentSize().width*0.5,self.button:getContentSize().height*0.5)
	                self.button:addChild(self.icon_effect, 1)
				end
			end
		end
	end
end

--- 开始准备倒计时
function FunctionIcon:updateTime()
	if self.data == nil or self.data.config == nil then return end
	if self.data.end_time > 0 then
		self:setLessTime()
	else
		self:removeTimeLabel()
	end
end

--设置倒计时
function FunctionIcon:setLessTime()
	local time = self.data.end_time - game_net:getTime()
	if time <= 0 then
		self:removeTimeLabel()
	else
		if self.time_label == nil then
			self.time_label = createLabel(17, 54, nil, self.container:getContentSize().width / 2, -8, '', self.container, 2, cc.p(0.5, 0.5))
			self.time_label:enableOutline(Config.ColorData.data_color4[2], 1)
		end
		local time_desc = ""
		if self.data.config.id == MainuiConst.icon.champion then
			if self.data.status == 1 then
				time_desc = string_format(TI18N("%s后开启"),TimeTool.GetTimeForFunction(time))
			elseif self.data.status == 2 then
				time_desc = string_format(TI18N("进行中:%s"),TimeTool.GetTimeForFunction(time))
			end
		elseif self.data.config.id == MainuiConst.icon.godbattle then
            if self.data.status == 1 then
                time_desc = string_format(TI18N("报名中:%s"),TimeTool.GetTimeForFunction(time))
			elseif self.data.status == 2 then
                time_desc = string_format(TI18N("进行中:%s"),TimeTool.GetTimeForFunction(time))
            end
		elseif self.data.config.id == MainuiConst.icon.guildwar then
			if self.data.status == 1 then
				time_desc = string_format(TI18N("%s后开启"),TimeTool.GetTimeForFunction(time))
            elseif self.data.status == 2 then
				time_desc = string_format(TI18N("%s后结束"),TimeTool.GetTimeForFunction(time))
            end
		else
			time_desc = TimeTool.GetTimeForFunction(time)
		end
		self:setBaseTimeInfo(time_desc)
	end
end

--- 设置通用类的倒计时显示
function FunctionIcon:setBaseTimeInfo(time_desc)
	if self.time_ticket_desc ~= time_desc then
		self.time_ticket_desc = time_desc
		self.time_label:setString(time_desc)
	end
end

function FunctionIcon:removeTimeLabel()
    if self.time_label and not tolua.isnull(self.time_label) then
        self.time_label:removeFromParent()
        self.time_label = nil
    end
end

function FunctionIcon:updateTishiState()
	if tolua.isnull( self.tishi) or self.data == nil then return end
	local status = self.data:getTipsStatus()
	self.tishi:setVisible(status)
	if self.data.config.id == MainuiConst.icon.friend or self.data.config.id == MainuiConst.icon.mail then
		local num = self.data:getTipsNum()
		if num > 0 and self.num ~= nil then
			self.num:setString(num)
			self.num:setVisible(true)
		else
			self.num:setVisible(false)
		end
	end
end

function FunctionIcon:getData()
	return self.data
end

function FunctionIcon:getIconRedStatus(  )
	if self.data then
		return self.data:getTipsStatus()
	else
		return false
	end
end

function FunctionIcon:registerEvent()
	self:addTouchEventListener(function(sender, event_type)
		if not self.is_show_unfold_ani and self.data ~= nil and self.data.config ~= nil then
			customClickAction(sender, event_type)
	    	if event_type == ccui.TouchEventType.ended then
				playButtonSound()
				MainuiController:getInstance():iconClickHandle(self.data.config.id, sender, self.data.action_id)		
	    	end
		end
	end)

	if self.data ~= nil then
		if self.update_by_self_event == nil then
			self.update_by_self_event = self.data:Bind(FunctionIconVo.UPDATE_SELF_EVENT, function(key)
				if key == nil then 
					self:updateInfo()
				else
					if key == "res_id" then
						self:updateIconRes()
					elseif key == "tips_status" then
						self:updateTishiState()
						--mainui 两侧图标如果是收起状态，则需要更新显示红点
						MainuiController:getInstance():updateIconRedStatus()
 					end
				end
			end)
		end

		if self.data.id == MainuiConst.icon.seven_login or self.data.id == MainuiConst.icon.eight_login then
			if self.seven_login_status_event == nil then
				self.seven_login_status_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVEN_LOGIN_STATUS, function() 
					self:updateSevenLoginInfo()
				end)
			end
		end
	end
	self:registerScriptHandler(function(event)
		if "exit" == event then	
			if self.data then
				if self.update_by_self_event ~= nil then
					self.data:UnBind(self.update_by_self_event)
					self.update_by_self_event = nil
				end
				self.data = nil
			end
		end 
	end)
end

function FunctionIcon:setIconName()
	if tolua.isnull(self.name) or self.data == nil or self.data.config == nil then return end

	if self.data.real_name and self.data.real_name ~= "" and self.data.real_name ~= "null" then
		self.name:setString(self.data.real_name)
	else
		self.name:setString(self.data.config.icon_name)
	end
end

--==============================--
--desc:针对七天登录的
--time:2018-09-12 07:38:29
--@return 
--==============================--
function FunctionIcon:updateSevenLoginInfo()
	local login_data = ActionController:getInstance():getModel():getMaxSevenDay() 
	if login_data == nil or login_data.day == nil then return end
	local login_type = ActionController:getInstance():getModel():getSevenDayType()
	local day_config = nil
	
	if login_type == 1 then --新版
		day_config = Config.LoginDaysNewData.data_day[login_data.day]
	else
		day_config = Config.LoginDaysData.data_day[login_data.day]
	end
	if day_config then
		local str = ""
		if login_data.status == 3 then
			str = day_config.next_desc
		else
			str = day_config.day_desc
		end
		
		if self.extend_label == nil then
			self.extend_label = createLabel(20, 1, 163, self.container:getContentSize().width / 2, -12, '', self.container, 2, cc.p(0.5, 0.5)) 
		end
		self.extend_label:setString(str)
	end
end

function FunctionIcon:updateFirstChargeInfo()
	if self.data == nil then return end
	local status = self.data.status
	if self.extend_label == nil then
		self.extend_label = createLabel(20, 1, 163, self.container:getContentSize().width / 2, -12, '', self.container, 2, cc.p(0.5, 0.5)) 
	end
	if status == 0 then
		self.extend_label:setString(TI18N("明日可领"))
	elseif status == 1 then
		self.extend_label:setString(TI18N("可领取"))
	end
end

function FunctionIcon:setIsShowUnfoldAni( status )
	self.is_show_unfold_ani = status
end

function FunctionIcon:DeleteMe()
	self.root_wnd:stopAllActions()
	if self.data ~= nil then
		if self.update_by_self_event ~= nil then
			self.data:UnBind(self.update_by_self_event)
			self.update_by_self_event = nil
		end
		self.data = nil
	end
	if self.seven_login_status_event then
		GlobalEvent:getInstance():UnBind(self.seven_login_status_event)
		self.seven_login_status_event = nil
	end

	self:removeAllChildren()
	self:removeFromParent()
end
