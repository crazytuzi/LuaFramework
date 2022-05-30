-- --------------------------------------------------------------------
-- @description:
-- [文件功能:战斗结算MVP界面]
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleMvpView = BattleMvpView or BaseClass(BaseView)

function BattleMvpView:__init(data)
	self.win_type = WinType.Mini
	self.layout_name = "battle/battle_mvp_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false

	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battlemvp", "battlemvp"), type = ResourcesType.plist },
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}
    self.is_csb_action = true
	self.ani_isover = false
	self.item_list = {}
	self:setData(data)
end

function BattleMvpView:setData(data)
	data = data or {}
	self.data = data
	self.result = data.result
	self.reward_list = data.item_rewards or {}
	self.fight_type = data.combat_type or BattleConst.Fight_Type.Darma
	self.partner_bid = data.partner_bid or 0
    self.use_skin = data.use_skin or 0
	self.partner_hurt = data.partner_hurt or 0
	self.partner_total_hurt = data.partner_total_hurt or 0
	self.role_exp = data.exp or 0
	self.role_lv = data.lev or 1
	self.role_nowlv = data.new_lev or 1
	self.role_nowexp = data.new_exp or 0
end

--初始化
function BattleMvpView:open_callback()
	playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 

	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.main_container = self.root_wnd:getChildByName("container")
	self.main_container:setLocalZOrder(1)
	local containerPosY = self.main_container:getPositionY()
	local containerSize = self.main_container:getContentSize()
	self.containerSize = containerSize

	local role_vo = RoleController:getInstance():getRoleVo()

	-- 适配
	local top_off = display.getTop(self.root_wnd)
	self.offset_y = top_off-CC_DESIGN_RESOLUTION.height

	self.main_container:setPositionY(611+self.offset_y)
	self.main_container:setOpacity(0)
	self.main_container:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(0, 200)), cc.FadeIn:create(0.2)))

    self.pic_mvp = self.root_wnd:getChildByName("pic_mvp")
    self.pic_mvp:setLocalZOrder(1)
    self.pic_mvp:setPosition(cc.p(-300, 1155+self.offset_y))
    self.pic_mvp:runAction(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(300 + 34, 0)), cc.FadeIn:create(0.2)))

    self.pic_bg = self.root_wnd:getChildByName("pic_bg")
    self.pic_bg:setPosition(cc.p(-300, 1010+self.offset_y))
    self.pic_bg:runAction(cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(300, 0)), cc.FadeIn:create(0.3)))

    local main_bg = self.main_container:getChildByName("main_bg")
    --main_bg:setContentSize(cc.size(720, 525+self.offset_y))
	--
    self.auto_combat_num = self.main_container:getChildByName("auto_combat_num")
    self.auto_combat_num:setVisible(false)

    self.fight_text = createLabel(22,Config.ColorData.data_new_color4[11] , nil, 360, 570, "",self.main_container, nil, cc.p(0.5,0.5))

    local name = Config.BattleBgData.data_fight_name[self.fight_type]
    if name then
        self.fight_text:setString(TI18N("当前战斗：")..name)
    end
	local Sprite_2 = self.main_container:getChildByName("Sprite_2")
	loadSpriteTexture(Sprite_2, PathTool.getPlistImgForDownLoad("common/txt_common", "txt_common_6"), LOADTEXT_TYPE )

	self.time_label = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(containerSize.width/2,40-self.offset_y), nil, nil, 1000)
	self.time_label:setString(TI18N("10秒后关闭"))
	self.time_label:setVisible(false)
	self.main_container:addChild(self.time_label)

    self.comfirm_btn = createButton(self.main_container,TI18N("确定"), 620, 580, cc.size(168, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.main_container:getContentSize().width / 2 - 170, 90-self.offset_y)
	--self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
	self.comfirm_btn:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)

    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:onCloseBtn()
        end
	end)

	local back_limit_lv = Config.BattleBgData.data_back_limit[self.fight_type] or 0
	if back_limit_lv <= role_vo.lev then
		self.cancel_btn = createButton(self.main_container,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
		self.cancel_btn:setPosition(self.main_container:getContentSize().width / 2 + 170, 90-self.offset_y)
		--self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
		self.cancel_btn:enableShadow(Config.ColorData.data_new_color4[3],cc.size(0, -2),2)
		self.cancel_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				if self.ani_isover then
					BattleResultReturnMgr:returnByFightType(self.fight_type) --先
				end
				self:onCloseBtn()
			end
		end)
	else
		self.comfirm_btn:setPositionX(self.main_container:getContentSize().width / 2)
	end

	self.harm_btn = self.main_container:getChildByName("harm_btn")
	if self.data and next(self.data) ~= nil then
		self.harm_btn:setVisible(true)
	else
		self.harm_btn:setVisible(false)
	end
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))
	--
	--local label  = createRichLabel(22,31, cc.p(0.5, 0.5), cc.p(containerSize.width/2, 305), nil, nil, 1000)
	--label:setString(TI18N("获得物品"))
	--self.main_container:addChild(label)

	-- 进度条
	local percent = 0
	self.progressBg = self.main_container:getChildByName("sprite_3")
	self.proBgSize = self.progressBg:getContentSize()
	self.progress = self.main_container:getChildByName("LoadingBar")

	self.progress:setPercent(0)
    self.proTxt = createLabel(22,Config.ColorData.data_new_color4[12],nil,self.proBgSize.width/2,self.proBgSize.height/2 - 30,"",self.progressBg,nil, cc.p(0.5, 0.5))
    --self.proBar:setPosition(cc.p(self.proBgSize.width*percent/100+2, self.proBgSize.height/2))
    self.progressBg:setVisible(false)

    -- 延迟0.3秒显示进度条动画
    delayRun(self.root_wnd, 0.3, function ()
		self:showProgressEffect()
	end)

    -- 头像
    --local iconBg = self.main_container:getChildByName("sprite_2")
    --local iconBgSize = iconBg:getContentSize()
	local sprite_1 = self.main_container:getChildByName("sprite_1")
    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    self.head_icon:setPosition(208, 76)
    self.head_icon:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    --self.head_icon:setScale(0.8)
	sprite_1:addChild(self.head_icon)

    -- 等级
    local lvStr = string.format("Lv.%d", self.role_nowlv)
    self.roleLvTxt = createLabel(22,Config.ColorData.data_new_color4[10] ,nil,0,self.proBgSize.height+2,lvStr,self.progressBg,nil, cc.p(0, 0))

    -- 名称和立绘
    self.pic_bg:setLocalZOrder(1)
    local partner_config = Config.PartnerData.data_partner_base[self.partner_bid]
    local skin_config = Config.PartnerSkinData.data_skin_info[self.use_skin]

    if partner_config then
        local partnerName = partner_config.name
        local bustid
        if skin_config then
            bustid = skin_config.bustid
        else
            bustid = partner_config.bustid
        end
	    local picBgPosY = self.pic_bg:getPositionY()
	    self.roleNameTxt = createLabel(32,Config.ColorData.data_new_color4[1] ,nil,-300,picBgPosY+15,partnerName,self.root_wnd,nil, cc.p(0, 0))
	    self.roleNameTxt:setLocalZOrder(1)
	    self.roleNameTxt:enableOutline(Config.ColorData.data_new_color4[8] , 2)
	    self.roleNameTxt:runAction(cc.MoveTo:create(0.5, cc.p(30, picBgPosY+15)))
		self:ShowMvpRole(self.partner_bid)
	    --local bust_res = PathTool.getPartnerBustRes(bustid)
	    --if not self.bust_load then
	    --    self.bust_load = createResourcesLoad(bust_res, ResourcesType.single, function()
	    --        if not self.bustIcon then
	    --        	self.bustIcon = createImage(self.root_wnd, bust_res,  740, 860+self.offset_y, cc.p(0, 0), false, 0, false)
    	--			self.bustIcon:ignoreContentAdaptWithSize(true)
    	--			self.bustIcon:runAction(cc.MoveTo:create(0.2, cc.p(0, 860+self.offset_y)))
	    --        end
	    --	end,self.bust_load)
	    --end
    end

    -- 伤害输出
    local hurtTitle = createLabel(22,Config.ColorData.data_new_color4[15] ,nil,30, 38,TI18N("总伤害输出"),self.pic_bg,nil,cc.p(0, 0))
    local hurtPercent = string.format("%.2f", self.partner_hurt/self.partner_total_hurt*100) .. "%"
    local hurtStr = string.format("%d(%s)", changeBtValueForBattle(tonumber(self.partner_hurt)), hurtPercent)
    local hurtTxt = createLabel(22,Config.ColorData.data_new_color4[14],nil,30, 5,hurtStr,self.pic_bg,nil,cc.p(0, 0))

	local sprite_1 = self.main_container:getChildByName("sprite_1")
	local Image_1 = self.main_container:getChildByName("Image_1")

	--显示特效
	self:handleEffect(true)
	self.scroll_view = createScrollView(Image_1:getContentSize().width,Image_1:getContentSize().height -40,0,0,Image_1,ccui.ScrollViewDir.vertical)
	self.scroll_view:setLocalZOrder(2)
	self.scroll_view:setName("scroll_view")
	self:rewardViewUI()
end

function BattleMvpView:ShowMvpRole(role_id)
	self.spine = BaseRole.new(BaseRole.type.partner, role_id,nil, {scale=1 },true)
	self.spine:setAnimation(0,PlayerAction.show,true)
	self.spine:setPosition(cc.p(550,950))
	self.spine:setAnchorPoint(cc.p(0.5,0.5))
	self.spine:setScale(1)
	self.main_container:addChild(self.spine)

end

function BattleMvpView:showProgressEffect()
	local baseCurMaxExp = Config.RoleData.data_role_attr[self.role_lv].exp_max
	local basePercent = self.role_exp/baseCurMaxExp*100
	local maxPercent = self.role_nowexp/baseCurMaxExp*100
	if self.role_lv ~= self.role_nowlv then -- 有升级
		maxPercent = 100
	end
    if self.data.auto_num and self.data.auto_num > 0 then
        self.auto_combat_num:setVisible(true)
        self.auto_combat_num:setString(string.format(TI18N("已连续通过关卡数：%s"), self.data.auto_num))
    end

	self.progress:setPercent(basePercent)
	self.proTxt:setString(string.format("%d/%d", tonumber(self.role_exp), tonumber(baseCurMaxExp)))
    --self.proBar:setPosition(cc.p(self.proBgSize.width*basePercent/100+2, self.proBgSize.height/2))
    self.progressBg:setVisible(true)

    local call_back = function()
        basePercent = basePercent + 1
        if basePercent > maxPercent then
        	if self.role_lv == self.role_nowlv then
        		baseCurMaxExp = Config.RoleData.data_role_attr[self.role_nowlv].exp_max
        		basePercent = self.role_nowexp/baseCurMaxExp*100
        		self.progress:setPercent(basePercent)
    			--self.proBar:setPosition(cc.p(self.proBgSize.width*basePercent/100+2, self.proBgSize.height/2))
    			self.proTxt:setString(string.format("%d/%d", self.role_nowexp, tonumber(baseCurMaxExp)))
        		GlobalTimeTicket:getInstance():remove("mvp_progress_timer")
        	else
        		-- 播放升级特效
        		if self.progressEffect == nil then
			    	self.progressEffect = createEffectSpine(PathTool.getEffectRes(275), cc.p(self.proBgSize.width/2, self.proBgSize.height/2), cc.p(0.5, 0.5), false)
			    	self.progressBg:addChild(self.progressEffect)
			    else
			    	self.progressEffect:setAnimation(0, PlayerAction.action, false)
			    end
        		self.role_lv = self.role_lv + 1
        		basePercent = 0
        		maxPercent = 100
        		baseCurMaxExp = Config.RoleData.data_role_attr[self.role_lv].exp_max
        		if self.role_lv == self.role_nowlv then
        			maxPercent = self.role_nowexp/Config.RoleData.data_role_attr[self.role_nowlv].exp_max*100
        		end
        	end
        else
        	self.progress:setPercent(basePercent)
    		--self.proBar:setPosition(cc.p(self.proBgSize.width*basePercent/100+2, self.proBgSize.height/2))
    		self.proTxt:setString(string.format("%d/%d", math.ceil(baseCurMaxExp*basePercent/100), tonumber(baseCurMaxExp)))
        end
    end
    GlobalTimeTicket:getInstance():add(call_back, 0.01, 0, "mvp_progress_timer")
end

function BattleMvpView:onCloseBtn()
    if self.ani_isover then
        BattleController:getInstance():openFinishView(false,self.fight_type)
    end
end

function BattleMvpView:register_event()
	self.comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			self:onCloseBtn()
		end
	end)
	registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function BattleMvpView:_onClickHarmBtn(  )
	if self.data and next(self.data) ~= nil then
		BattleController:getInstance():openBattleHarmInfoView(true, self.data)
	end
end

function BattleMvpView:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
		if self.progressEffect then
			self.progressEffect:clearTracks()
			self.progressEffect:removeFromParent()
			self.progressEffect = nil
		end
	else
		if not tolua.isnull(self.main_container) and self.play_effect == nil then
			--self.play_effect = createEffectSpine(PathTool.getEffectRes(274), cc.p(self.containerSize.width * 0.5, 515), cc.p(0.5, 0.5), false, PlayerAction.action_1)
			--self.main_container:addChild(self.play_effect, 1)
		end
	end
end 

local item_scale = 0.7
--奖励界面
function BattleMvpView:rewardViewUI()
	if not self.reward_list then return end
	local sum = #self.reward_list
	local col =4
	-- 算出最多多少行
	self.row = math.ceil(sum / col)
	self.space = 10
	self.spaceX = 10
	local max_height = (self.space + BackPackItem.Height * item_scale) * self.row
	self.max_height = math.max(max_height, self.scroll_view:getContentSize().height)
	self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view:getContentSize().width, self.max_height))

	if sum >= col then
		sum = col
	end
	local total_width = sum * BackPackItem.Width*item_scale + (sum - 1) * self.spaceX
	self.start_x = (self.scroll_view:getContentSize().width - total_width) * 0.5

	-- 只有一行的话
	if self.row == 1 then
		self.start_y = self.max_height * 0.5
	else
		self.start_y = self.max_height - 20 - BackPackItem.Height * 0.5 * item_scale
	end

	self.action_effect = {}
    for i,v in ipairs(self.reward_list) do
    	if v.bid and v.num then
    		delayRun(self.root_wnd, i*0.1, function() 
	            local function one_fun()
	                if self.action_effect[i] then
	                    self.action_effect[i]:runAction(cc.RemoveSelf:create(true)) 
	                    self.action_effect[i] = nil
	                end
	            end
	            local _x = self.start_x + BackPackItem.Width * 0.5 * item_scale+ ((i - 1) % col) * (BackPackItem.Width * item_scale + self.spaceX)
	            local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height * item_scale + self.space)
	            
	            local effect_id = Config.EffectData.data_effect_info[156]
	            local action = PlayerAction.action_3
	            self.action_effect[i] = createEffectSpine(effect_id, cc.p(_x, _y), cc.p(0.5, 0.5), false, action, one_fun, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	            self.scroll_view:addChild(self.action_effect[i], 1)
	        
	            local function animationEventFunc(event)
	                if event.eventData.name == "appear" then
	                    local item = BackPackItem.new(true,true)
	                    item:setBaseData(v.bid,v.num)
						item:setScale(0.6)
	                    --local name = Config.ItemData.data_get_data(v.bid).name
						--item:setGoodsName(name,nil,20,cc.c3b(255,232,183))
	                    item:setPosition(cc.p(_x, _y + 20))
						item:setDefaultTip()
						self.scroll_view:addChild(item)
						self.item_list[i] = item
	                end
	            end
	            self.action_effect[i]:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
	        end)
    	end
    end

    delayRun(self.main_container, 0.5, function() 
        self:updateTimer()
    end)
end

function BattleMvpView:updateTimer()
	self.ani_isover = true
	self.time_label:setVisible(true)
	self.comfirm_btn:setVisible(true)
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        local str = string.format(TI18N("%s秒后关闭"), new_time)
		if self.time_label and not tolua.isnull(self.time_label) then
			self.time_label:setString(str)
		end
        if new_time <= 0 then
        	GlobalTimeTicket:getInstance():remove("mvp_close_timer")
            BattleController:getInstance():openFinishView(false,self.fight_type)
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "mvp_close_timer")
end

--清理
function BattleMvpView:close_callback()
	-- 移除可能存在的装备tips
	self.root_wnd:stopAllActions()

	if self.bust_load then
        self.bust_load:DeleteMe()
    end
    self.bust_load = nil
	
	GlobalTimeTicket:getInstance():remove("mvp_close_timer")
	GlobalTimeTicket:getInstance():remove("mvp_progress_timer")
	if self.item_list then
		for i,v in ipairs(self.item_list) do
			if v then
				v:DeleteMe()
			end
		end
	end
	self.item_list = {}
	self.item_list = nil
	self:handleEffect(false)

	HeroController:getInstance():openEquipTips(false)
    TipsManager:getInstance():hideTips()
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW,self.fight_type)

	if self.fight_type == BattleConst.Fight_Type.Darma then
		GlobalEvent:getInstance():Fire(BattleEvent.MOVE_DRAMA_EVENT, self.fight_type)
	end
	if BattleController:getInstance():getModel():getBattleScene() and BattleController:getInstance():getIsSameBattleType(self.fight_type) then
		BattleController:getInstance():getModel():result(self.data, self.is_leave_self)
	end
	BattleController:getInstance():openFinishView(false,self.fight_type) 
end
