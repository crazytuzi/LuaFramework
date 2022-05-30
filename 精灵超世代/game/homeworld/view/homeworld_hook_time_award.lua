--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-06 17:57:46
-- @description    : 
		-- 家园累计在线时长
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

HomeworldHookTimeAward = HomeworldHookTimeAward or BaseClass()

function HomeworldHookTimeAward:__init( parent )
	self.parent = parent

	self:createRoorWnd()
    self:registerEvent()

    self:setData()
end

function HomeworldHookTimeAward:createRoorWnd(  )
	local csbPath = PathTool.getTargetCSB("homeworld/homeworld_hook_time")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setPosition(cc.p(170, 1150))
    self.parent:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.progress_bg = self.container:getChildByName("progress_bg")
    self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setPercent(0)
    self.progress_value = self.progress_bg:getChildByName("progress_value")
    self.progress_value:setString(0)

    self.pos_bird = self.container:getChildByName("pos_bird")

    self.btn_get_res = self.container:getChildByName("btn_get_res")
    self.btn_get_res:ignoreContentAdaptWithSize(true)
    self.btn_get_res:loadTexture(PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_4"), LOADTEXT_TYPE)

    self:showBirdEffect(true)

    local hook_red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Hook)
    self:setRedStatus(hook_red_status)
end

function HomeworldHookTimeAward:registerEvent(  )
	registerButtonEventListener(self.btn_get_res, function (  )
		_controller:sender26016()
		self:showBirdEffect(true, PlayerAction.interaction)
	end, true)

	registerButtonEventListener(self.container, function (  )
		_controller:sender26016()
		self:showBirdEffect(true, PlayerAction.interaction)
	end, false)
end

function HomeworldHookTimeAward:setData(  )
	local hook_time = _model:getHomeAccHookTime()
	local hook_time_hour = math.floor(hook_time/3600)

	local max_val_cfg = Config.HomeData.data_const["homecoin_hoarding_limit"]
	if not max_val_cfg then return end
	local percent = hook_time_hour/max_val_cfg.val*100

	self.progress_value:setString(_string_format(TI18N("已累计%d时"), hook_time_hour))
	self.progress:setPercent(percent)

	self.btn_get_res:stopAllActions()
	if hook_time > 0 then
		self.btn_get_res:setPosition(cc.p(-22, 165))
		local act_1 = cc.MoveTo:create(1, cc.p(-22, 170))
		local act_2 = cc.MoveTo:create(1, cc.p(-22, 160))
		self.btn_get_res:runAction(cc.RepeatForever:create(cc.Sequence:create(act_1, act_2)))
		self.btn_get_res:setVisible(true)
	else
		self.btn_get_res:setVisible(false)
	end
end

function HomeworldHookTimeAward:setVisible( status )
	if self.root_wnd then
		self.root_wnd:setVisible(status)
	end
end

function HomeworldHookTimeAward:setRedStatus( status )
	--addRedPointToNodeByStatus( self.btn_get_res, status, -7, nil, nil, 2 )
end

-- 显示管家鸟特效
function HomeworldHookTimeAward:showBirdEffect( status, action )
	if status == true then
		action = action or PlayerAction.idle
		local is_loop = true
		if action == PlayerAction.interaction then
			is_loop = false
		end
		if not tolua.isnull(self.pos_bird) and self.bird_effect == nil then
            self.bird_effect = createEffectSpine("H66001", cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.idle, handler(self, self._onActionEndCallback))
            self.pos_bird:addChild(self.bird_effect)
        elseif self.bird_effect then
        	self.bird_effect:setToSetupPose()
			self.bird_effect:setAnimation(0, action, is_loop)
        end
        self.cur_action = action
	else
		if self.bird_effect then
            self.bird_effect:clearTracks()
            self.bird_effect:removeFromParent()
            self.bird_effect = nil
        end
	end
end

function HomeworldHookTimeAward:_onActionEndCallback(  )
	if self.cur_action == PlayerAction.interaction then
		self:showBirdEffect(true, PlayerAction.idle)
	end
end

function HomeworldHookTimeAward:__delete(  )
	self:showBirdEffect(false)
	self:removeAllChildren()
	self:removeFromParent()
end