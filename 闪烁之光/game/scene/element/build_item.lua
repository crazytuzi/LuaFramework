-- --------------------------------------------------------------------
-- 中心城建筑单位
-- 数据可能是建筑单位,也可能是特效,主要是根据配置的type区分
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里用到的配置数据有 Config.CityData.data_base 建筑的基础数据, 建筑的升级数据,每一级的相信配置数据 Config.CityData.data_button 具体按钮配置数据
-- 		锁定的特效使用的是 E60374 解锁的特效是 E60374
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BuildItem = BuildItem or BaseClass()

local mainscene_ctrl = MainSceneController:getInstance()

function BuildItem:__init(data, type)
	self.data = data
	self.can_click = false
	self.is_build = (type == BuildItemType.build)
	self.build_type = type
	self:createRootwnd()
end

function BuildItem:getData()
	return self.data
end

function BuildItem:createRootwnd()
	self.size = cc.size(83, 80)
	self.node = ccui.Widget:create()
	self.node:setAnchorPoint(0.5, 0)
	self.node:setContentSize(self.size)

	if self.is_build == true then
		self:createBuild()
	else
		if self.build_type == BuildItemType.effect then
			self:createEffect()
		elseif self.build_type == BuildItemType.npc then
			self:createNpc()
		end
	end
end

--==============================--
--desc:该建筑是可点击的建筑
--time:2017-07-18 09:58:43
--@return 
--==============================--
function BuildItem:createBuild()
	-- local cur_time_type = MainSceneController:getInstance():getMainScene():getCurTimeType()
	local temp_res = PathTool.getResFrame("centerscene", "scene_icon_bg_1")
	-- if cur_time_type == 1 then --白天
	-- 	temp_res = PathTool.getResFrame("centerscene", "scene_icon_bg_1")
	-- end
	
	self.item_icon_bg = createImage(self.node, temp_res,
		self.size.width * 0.5,
		self.size.height * 0.5,
		cc.p(0.5, 0.5),
		true
	)

	local scale_x = 1
	if self.data.config.bid == CenterSceneBuild.crossshow or self.data.config.bid == CenterSceneBuild.luckytreasure or self.data.config.bid == CenterSceneBuild.startower
	or self.data.config.bid == CenterSceneBuild.adventure or self.data.config.bid == CenterSceneBuild.seerpalace or self.data.config.bid == CenterSceneBuild.resonate then
		scale_x = -1
	end
	self.item_icon_bg:setScaleX(scale_x)

	self.item_icon = createImage(self.node, PathTool.getResFrame("centerscene", string.format("txt_cn_scene_%s", self.data.config.res)),
	self.size.width * 0.5,
	self.size.height * 0.5+5,
		cc.p(0.5, 0.5),
		true
	)

	-- 引导需要的,根据这个获取建筑点击对象
	self.node:setName("guidesign_build_"..self.data.config.bid)

	-- 看看需要不需要添加红点
	self:fightStatus()
	self:setLockStatus()
	self:setRedPoint()
	self:setGuideEffect()
	self:registEvent()
end

function BuildItem:createEffect()
	self.body = 
		createEffectSpine(
		self.data.res,
		cc.p(self.size.width * 0.5, self.size.height * 0.5),
		cc.p(0.5, 0.5),
		true,
		PlayerAction.action,
		nil,
		cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
	)
	self.node:addChild(self.body)
end

function BuildItem:createNpc()
	self.body = 
		createEffectSpine(
		self.data.res,
		cc.p(self.size.width * 0.5, self.size.height * 0.5),
		cc.p(0.5, 0.5),
		true,
		PlayerAction.action_1,
		nil,
		cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
	)
	self.node:addChild(self.body)

	self.is_idle_ing = false
	local function animationCompleteFunc(event) 
		if event.animation == PlayerAction.action_2 then
			self.body:setAnimation(0, PlayerAction.action_1, true)
			self.is_idle_ing = false
		end
	end
	self.body:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE) 
	self:registNpcEvent()
end

function BuildItem:clickNpcHandler()
	if self.is_idle_ing == true then return end
	playOtherSound(self.data.name,AudioManager.AUDIO_TYPE.COMMON)
	self.is_idle_ing = true
	self.body:setAnimation(0, PlayerAction.action_2, false)
end

--更新主城泡泡背景
function BuildItem:updateBuildBg()
	if self.item_icon_bg then
		-- local cur_time_type = MainSceneController:getInstance():getMainScene():getCurTimeType()
		local temp_res = PathTool.getResFrame("centerscene", "scene_icon_bg_1")
		-- if cur_time_type == 1 then --白天
		-- 	temp_res = PathTool.getResFrame("centerscene", "scene_icon_bg_1")
		-- end
		self.item_icon_bg:loadTexture(temp_res, LOADTEXT_TYPE_PLIST)
	end
end


--==============================--
--desc:点击npc的时候要切换动作
--time:2018-07-27 07:11:43
--@return 
--==============================--
function BuildItem:registNpcEvent()
	self.node:setTouchEnabled(true)
	self.node:setSwallowTouches(false)
	self.node:addTouchEventListener(function(sender, event_type)
		-- customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then	
            self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click = math.abs( self.touch_end.x - self.touch_began.x ) <= 20 and math.abs( self.touch_end.y - self.touch_began.y ) <= 20
			end
			if is_click == true then
				self:clickNpcHandler()				
			end
		elseif event_type == ccui.TouchEventType.began then			
            self.touch_began = sender:getTouchBeganPosition()
		end
	end)
end

function BuildItem:registEvent()
	self.node:setTouchEnabled(false)
	self.node:setSwallowTouches(false)
	self.node:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then	
            self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click = math.abs( self.touch_end.x - self.touch_began.x ) <= 20 and math.abs( self.touch_end.y - self.touch_began.y ) <= 20
			end
			self:removeFinger()
			if is_click == true then
				if sender.guide_call_back ~= nil then
					sender.guide_call_back(sender)
				end
				self:clickHandler()				
			end
		elseif event_type == ccui.TouchEventType.began then			
            self.touch_began = sender:getTouchBeganPosition()
		end
	end)

	if self.data ~= nil then
		if self.update_self_event == nil then
			self.update_self_event = self.data:Bind(BuildVo.Update_self_event, function(key)
				if key == "lock_status" then
					self:setLockStatus()
				elseif key == "tips_status" then
					self:setRedPoint()
				elseif key == "fight_status" then
					self:fightStatus()
				elseif key == "group_id" then
					self:setGuideEffect()
				end
			end)
		end
	end
	delayRun(self.node, 1.2, function() self.node:setTouchEnabled(true) end)
end

--==============================--
--desc:建筑的点击函数
--time:2017-07-18 09:53:07
--@return 
--==============================--
function BuildItem:clickHandler()
	if self.data ~= nil then
		if self.data.is_lock == true then			-- 未开放
			if self.data.desc then
				message(self.data.desc)
			else
				message(TI18N("建筑开启数据异常"))
			end
		else
			playButtonSound()
			if self.data.group_id ~= 0 then
				mainscene_ctrl:send10956(self.data.group_id)
				
				self.data:setSpecialGroupId(0)
			end
			mainscene_ctrl:openBuild(self.data.config.bid)
		end
	end
end

function BuildItem:getRoot()
	return self.node
end

function BuildItem:getNode()
	return self.node
end

function BuildItem:getPosition()
	return self.node:getPosition()
end

--==============================--
--desc:获取建筑的尺寸,
--time:2017-06-12 10:55:28
--return 
--==============================--
function BuildItem:getContentSize()
	return self.node:getContentSize()
end

function BuildItem:getSize()
	return self.node:getContentSize()
end

function BuildItem:getAnchorPoint()
	return self.node:getAnchorPoint()
end


function BuildItem:setParentWnd(parent)
	if tolua.isnull(parent) then return end
	self.parent_wnd = parent
	if self.data ~= nil then
		if self.is_build then
			self.node:setPosition(self.data.config.x, self.data.config.y)
			self.parent_wnd:addChild(self.node, 10)
		else
			self.node:setPosition(self.data.x, self.data.y)
			self.parent_wnd:addChild(self.node, 1)
		end
	end
end

function BuildItem:getParent()
	return self.parent_wnd
end

function BuildItem:__delete()
	if self.data ~= nil then
		if self.update_self_event ~= nil then
			self.data:UnBind(self.update_self_event)
			self.update_self_event = nil
		end
		self.data = nil
	end
	if self.body then
		self.body:setVisible(false)
		self.body:clearTracks()
		self.body:runAction(cc.RemoveSelf:create(true))
	end
	if self.node:getParent() then
		self.node:removeAllChildren()
		self.node:removeFromParent()
	end
end

--==============================--
--desc:手指提示
--time:2017-06-12 01:01:10
--return 
--==============================--
function BuildItem:showFingerTips()
	if self.finger_effect == nil then
        self.finger_effect = createEffectSpine("E51050", cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.action)
        self.finger_effect:setPosition(self.size.width*0.5, self.size.height*0.5)
        self.node:addChild(self.finger_effect)

		local delay_time = cc.DelayTime:create(3)
		local call_fun = cc.CallFunc:create(function()
			self:removeFinger()
		end)
		self.finger_effect:runAction(cc.Sequence:create(delay_time, call_fun))
	end
end

function BuildItem:removeFinger()
    if self.finger_effect ~= nil then                		
		self.finger_effect:clearTracks()
		self.finger_effect:runAction(cc.RemoveSelf:create(true))
		self.finger_effect = nil
	end
end

--==============================--
--desc:建筑显示红点
--time:2017-08-14 12:45:41
--@return 
--==============================--
function BuildItem:setRedPoint()
	if self.data == nil then return end
	-- 如果还没有解锁的时候,那么就不要显示红点
	local status = self.data:getTipsStatus()
	if self.data.is_lock == true then return end
	if self.red_status ~= nil and self.red_status == status then return end
	self.red_status = status
	if status == false then
		if self.tips_icon ~= nil then
			self.tips_icon:setVisible(false)
		end
	else
		if self.tips_icon == nil then
			self.tips_icon = createSprite(PathTool.getResFrame("centerscene", "scene_0"), 70, 66, self.item_icon, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		end
		self.tips_icon:setVisible(true)
	end
end

function BuildItem:setGuideEffect()
	if self.data == nil then return end
	local group_id = self.data.group_id
	if self.item_group_id ~= nil and self.item_group_id == group_id then return end

	if group_id == 0 then
		if self.guide_effect then
			self.guide_effect:removeFromParent()
			self.guide_effect = nil
		end
	else
		if self.guide_effect == nil then
			self.guide_effect = createEffectSpine(PathTool.getEffectRes(240), cc.p(41,45), cc.p(0.5,0.5), true, PlayerAction.action)
			self.item_icon:addChild(self.guide_effect, 10)
		end
	end
end

--- 当前战斗状态
function BuildItem:fightStatus()
	if self.data == nil then return end
	local status = self.data:getFightStatus()
	if self.fight_status ~= nil and self.fight_status == status then return end
	if status == false then
		if self.fight_effect then
			self.fight_effect:setVisible(false)
		end
	else
		if self.fight_effect == nil then
			self.fight_effect = createEffectSpine( PathTool.getEffectRes(186), cc.p(41,100), cc.p(0,0), true, PlayerAction.action)
			self.fight_effect:setScale(1.5)
			self.item_icon:addChild(self.fight_effect, 10)
		end
		self.fight_effect:setVisible(true)
	end
end

--==============================--
--desc:设置解锁状态
--time:2017-08-14 12:47:24
--@return 
--==============================--
function BuildItem:setLockStatus()
	if self.build_lock_status == self.data.is_lock then return end
	self.build_lock_status = self.data.is_lock

	if self.build_lock_status then
		if self.data.config.bid == CenterSceneBuild.crossshow then
			--策划要求 跨服时空锁住情况是不显示
			self.node:setVisible(false)
		else
			setChildUnEnabled(true, self.node)
		end
		-- if self.lock_icon == nil then
		-- 	self.lock_icon = createRichLabel(20,1,cc.p(0.5,0.5),cc.p(47,68),nil,nil)
		-- 	local str = string.format("<div fontcolor=#ffffff, outline=2,#D95014>%s</div>",self.data.desc)
		-- 	self.lock_icon:setString(str)
		-- 	self.item_icon:addChild(self.lock_icon)
		-- end
	else
		if self.data.config.bid == CenterSceneBuild.crossshow then
			self.node:setVisible(true)
		else
			setChildUnEnabled(false, self.node)
		end
		-- if self.lock_icon then
		-- 	self.lock_icon:removeFromParent()
		-- 	self.lock_icon = nil
		-- end
		-- 解锁的时候做一次红点设置
		self:setRedPoint()
	end
end