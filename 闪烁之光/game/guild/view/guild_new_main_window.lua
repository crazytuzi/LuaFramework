--**********************
--公会新主界面（公会酒馆）
--xhj
--**********************
GuildNewMainWindow = GuildNewMainWindow or BaseClass(BaseView)
local rank_limit_lev = 30

local controller = GuildController:getInstance()
local model = GuildController:getInstance():getModel()
local map_center = 360  --地图移动的中心点
local string_format = string.format
local table_insert = table.insert

local gb_model = GuildbossController:getInstance():getModel()
local skill_model = GuildskillController:getInstance():getModel()
local redbag_model = RedbagController:getInstance():getModel()
local gw_model = GuildwarController:getInstance():getModel()
function GuildNewMainWindow:__init()
    self.is_full_screen = true
    self.layout_name = "guild/guild_new_main_window"
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guild", "guild"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/guild","guild_bg_1",true), type = ResourcesType.single },
	}
	self.icon_list = {} --图标
	self.effect_list = {} --特效
	self.npc_list = {} --特效
	self.is_shrink = true --信息面板是否显示
	self.is_in_shrink = false --信息面板收缩状态
	self.touch_pos = {
		[109] = {745,170}--猫点击位置
	}
    self.role_vo = RoleController:getInstance():getRoleVo()
end

function GuildNewMainWindow:open_callback()
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.guild_bg = self.root_wnd:getChildByName("bg")
	self.top_bg = self.root_wnd:getChildByName("top_bg")
	self.bottom_bg = self.root_wnd:getChildByName("bottom_bg")
	
	self.map_layer = self.main_container:getChildByName("map_layer")
	self.guild_panel = self.main_container:getChildByName("guild_panel")
	self.mask_panel = self.guild_panel:getChildByName("mask_panel")
	self.info_panel = self.mask_panel:getChildByName("info_panel")
	self.info_panel:setVisible(false)
	self.sign_btn = self.info_panel:getChildByName("sign_btn")							-- 公会宣言的设置按钮
	self.guild_sign_value = self.info_panel:getChildByName("guild_sign_value")			-- 公会宣言内容
	self.guild_sign_value:setTextAreaSize(cc.size(250, 130))

	self.change_name_btn = self.guild_panel:getChildByName("change_name_btn")				-- 公会改名
	self.rank_btn = self.info_panel:getChildByName("rank_btn")							-- 公会排名
	self.rank_btn:getChildByName("label"):setString(TI18N("公会排名"))

	self.info_panel:getChildByName("guild_leader_title"):setString(TI18N("会长："))
	
	self.arrow_img = self.guild_panel:getChildByName("arrow_img")
	self.guild_name_value = self.guild_panel:getChildByName("guild_name_value")
	self.guild_leader_value = self.info_panel:getChildByName("guild_leader_value")
	self.guild_lev_value = self.info_panel:getChildByName("guild_lev_value")
	
	self.check_member_btn = self.info_panel:getChildByName("check_member_btn")					-- 查看成员
	self.check_member_btn.tips = self.check_member_btn:getChildByName("tips") 			-- 查看成员红点
	self.check_member_btn:getChildByName("label"):setString(TI18N("公会管理"))

	self.notice_btn = self.info_panel:getChildByName("notice_btn")						-- 公会日志按钮
	self.notice_btn.tips = self.notice_btn:getChildByName("tips") 						-- 公告红点
	self.notice_btn:getChildByName("label"):setString(TI18N("公会日志"))

	self.progress = self.info_panel:getChildByName("progress")
    self.progress:setScale9Enabled(true)
	self.progress_num = self.info_panel:getChildByName("progress_num")
	self:adaptationScreen()
end

--设置适配屏幕
function GuildNewMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)

	self.top_bg:setPositionY(top_y)
	self.bottom_bg:setPositionY(bottom_y)
    
end

function GuildNewMainWindow:register_event()
    registerButtonEventListener(self.sign_btn, function()
		controller:openGuildChangeSignWindow(true)
	end,true, 1)

	registerButtonEventListener(self.change_name_btn, function()
		controller:openGuildChangeNameWindow(true)
	end,true, 1)
	
	registerButtonEventListener(self.rank_btn, function()
		RankController:getInstance():openRankView(true, RankConstant.RankType.union)
	end,true, 1)

	registerButtonEventListener(self.check_member_btn, function()
		controller:openGuildMemberWindow(true)
	end,true, 1)

	registerButtonEventListener(self.notice_btn, function()
		controller:openGuildNoticeWindow(true)
	end,true, 1)

	registerButtonEventListener(self.guild_panel, function()
		self:shrinkInfoContainer()
	end,false, 1)
	
	
    if self.role_vo ~= nil then
		if self.role_assets_event == nil then
			self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
				if key == "position" then
					self:updateJurisdiction()
				end
			end)
		end
	end

	if self.update_red_status_event == nil then
		self.update_red_status_event = GlobalEvent:getInstance():Bind(GuildEvent.UpdateGuildRedStatus, function(type, status)
			self:updateSomeRedStatus(type, status)
		end)
	end
end

function GuildNewMainWindow:registerEvent()
	local function onTouchBegin(touch, event)
        self.touch_point = nil
        doStopAllActions(self.guild_bg)
        return true
    end
    local function onTouchMoved(touch, event)
        self.touch_point = touch:getDelta()
		local pos_x = self:setBorder(self.touch_point.x)
        self.guild_bg:setPositionX(pos_x)
    end
	local function onTouchEnded(touch, event)
		if self.touch_point then
        	local pos_x = self.touch_point.x + 15
        	if self.touch_point.x < 0 then
        		pos_x = self.touch_point.x - 15
        	end
			local x = self:setBorder(pos_x)
        	self.guild_bg:stopAllActions()
			local root_move_to = cc.MoveTo:create(1, cc.p(x, 640))
			local call_fun = cc.CallFunc:create(function()
			end)
			local ease_out = cc.EaseSineOut:create(root_move_to)
			self.guild_bg:runAction(cc.Sequence:create(ease_out, call_fun))
        end
	end
	
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	self.map_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.map_layer)
	
end

--置灰操作
function GuildNewMainWindow:setGray( bool )
    if self.rank_btn:isVisible() == true then
        setChildUnEnabled(bool, self.rank_btn)
        -- self.rank_btn:setTouchEnabled(not bool)
        if bool == true then
            self.rank_btn:getChildByName("label"):disableEffect(cc.LabelEffect.OUTLINE)
        else
            self.rank_btn:getChildByName("label"):enableOutline(cc.c4b(0x50,0x2E,0x1B,0xff), 1)
        end
    end
end

function GuildNewMainWindow:setBorder(x)
	local pos_x = self.guild_bg:getPositionX() + x
    if pos_x >= self.move_pos then
    	pos_x = self.move_pos
    end
    if pos_x <= map_center - (self.move_pos-map_center) then
    	pos_x = map_center - (self.move_pos-map_center)
    end
	return pos_x
end

--==============================--
--desc:收缩公会信息面板
--@return 
--==============================--
function GuildNewMainWindow:shrinkInfoContainer()
	if not self.info_panel then
		return
	end
    if self.is_in_shrink == true then return end
    self.is_in_shrink = true

    self.is_shrink = not self.is_shrink

    self.info_panel:setVisible(true)

    local len = 587.5
    local move_by_1 = nil
    local fade_1 = nil
	local scaleY = 1
    if self.is_shrink == true then
        move_by_1 = cc.MoveTo:create(0.6, cc.p(0, len))
		fade_1 = cc.FadeOut:create(0.6)
    else
        move_by_1 = cc.MoveTo:create(0.6, cc.p(0, 100))
		fade_1 = cc.FadeIn:create(0.1)
		scaleY = -1
	end
	self.arrow_img:setScaleY(scaleY)

    local call_fun_1 = cc.CallFunc:create(function()
        self.is_in_shrink = false
        if self.is_shrink == true then
            self.info_panel:setVisible(false)
        end
	end)
	local ease_out = cc.EaseBackOut:create(move_by_1)

    self.info_panel:runAction(cc.Sequence:create(cc.Spawn:create(ease_out, fade_1), call_fun_1)) 
end

--创建层次场景
function GuildNewMainWindow:createLayer()
	-- 创建7个地图层,其中1是最靠前的层
    for i=1,2 do
        self["map_layer"..i] = ccui.Layout:create()
        self["map_layer"..i]:setAnchorPoint(cc.p(0, 0))
		self["map_layer"..i]:setContentSize(self.guild_bg:getContentSize())
		if self.guild_bg and self["map_layer"..i] then
			self.guild_bg:addChild(self["map_layer"..i]) 	
		end
	end
end

function GuildNewMainWindow:openRootWnd()
	self:setGray(not RankController:getInstance():checkRankIsShow())
	self.guild_bg:ignoreContentAdaptWithSize(true)
	self.guild_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/guild","guild_bg_1",true), LOADTEXT_TYPE)
	self.move_pos = self.guild_bg:getContentSize().width*display.getMaxScale() * 0.5
	self.guild_bg:setScale(display.getMaxScale())
	self.move_pos = self.move_pos or 540

	
	self:createLayer()
	self:registerEvent()
	self:createIcon()
	self:createEffect()
	self:createNpc()

	if self.my_guild_info == nil then
		self.my_guild_info = model:getMyGuildInfo()
		if self.my_guild_info ~= nil then
			if self.update_my_guild_info_event == nil then
				self.update_my_guild_info_event = self.my_guild_info:Bind(GuildEvent.UpdateMyInfoEvent, function(key, value)
					if key == "sign" then
						self:updateGuildSignInfo()
					elseif key == "members_num" then
						
					elseif key == "lev" or key == "exp" then
						self:updateGuildBaseInfo()
					elseif key == "name" then
						self:updateGuildNameInfo()
					elseif key == "leader_name" then
						self:updateGuildLeaderInfo()
					end
				end)
			end
		end

		-- 监听开服天数变化
		if self.update_open_srv_day_event == nil then
	        self.update_open_srv_day_event = GlobalEvent:getInstance():Bind(RoleEvent.OPEN_SRV_DAY, function() 
	            self:checkGuildWarStatus()
	        end)
	    end

		self:updateGuildNameInfo()
		self:updateGuildSignInfo()
		self:updateGuildBaseInfo()
		self:updateGuildLeaderInfo()
		self:updateSomeRedStatus()
	end

	self:updateJurisdiction()
	local status = SysEnv:getInstance():getBool(SysEnv.keys.guild_first_open, true)
	if status == true then
		self:shrinkInfoContainer()
		SysEnv:getInstance():set(SysEnv.keys.guild_first_open, false)
	end
	
	

	--测试音效 --"lwc"
	-- AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_007", true) --
end

--创建图标按钮
function GuildNewMainWindow:createIcon()
	local tempArr = {}
	for i,v in ipairs(Config.GuildData.data_guild_scene_icon) do
		if v.res_type == 1 then --icon类型
			table_insert(tempArr, v)
		end
	end
	
	for i,v in ipairs(tempArr) do
		if self.map_layer2 then
			if self.icon_list[v.type] == nil then
				self.icon_list[v.type] = ccui.Layout:create()
				self.icon_list[v.type]:setContentSize(cc.size(83,80))
				self.icon_list[v.type]:setTouchEnabled(true)
				self.icon_list[v.type]:setAnchorPoint(0.5,0.5)
				
				self.icon_list[v.type]:setPosition(v.pos[1][1],v.pos[1][2])
				if self.icon_list[v.type] then
					self.map_layer2:addChild(self.icon_list[v.type])	
				end
				
				createImage(self.icon_list[v.type], PathTool.getResFrame("guild", string.format("guild_icon_%s", v.icon)),83/2,80/2,cc.p(0.5, 0.5),
				true
				)
				local bg = createImage(self.icon_list[v.type], PathTool.getResFrame("guild", "guild_1028"),83/2,23,cc.p(0.5, 0.5),true,nil,true)
				bg:setContentSize(cc.size(74,22))

				createLabel(18, cc.c4b(0xff,0xf8,0xca,0xff), cc.c4b(0x32,0x1c,0x0e,0xff), 83/2, 23, v.name, self.icon_list[v.type], 1, cc.p(0.5, 0.5))

				if v.type == GuildConst.icon_type.guild_icon_type_6 then --公会战
					self.icon_list[v.type].is_unlock = false
				elseif v.type == GuildConst.icon_type.guild_icon_type_4 then --公会副本
					self.icon_list[v.type].is_unlock = false
				end
				registerButtonEventListener(self.icon_list[v.type], function(data)
					self:onCheckIcon(data)		    		
				end,true,1,v)
			end
		end
	end
end


--创建特效
function GuildNewMainWindow:createEffect()
	local tempArr = {}
	for i,v in pairs(Config.GuildData.data_guild_scene_icon) do
		if v.res_type == 2 then --2特效类型
			table_insert(tempArr, v)
		end
	end
	
	for i,v in ipairs(tempArr) do
		if self.map_layer1 then
			if self.effect_list[i] == nil then
				delayRun(self.root_wnd, i*2 / display.DEFAULT_FPS,function ()
					if self.effect_list[i] == nil then
						self.effect_list[i] = createEffectSpine(v.icon,cc.p(v.pos[1][1],v.pos[1][2]),cc.p(0.5, 0.5),true,PlayerAction.action_1,nil,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
						if self.effect_list[i] and self.map_layer1 and not tolua.isnull(self.map_layer1) then
							self.map_layer1:addChild(self.effect_list[i])	
							if self.touch_pos and self.touch_pos[v.type] then
								local node = ccui.Layout:create()
								node:setContentSize(cc.size(83, 83))
								node:setPosition(self.touch_pos[v.type][1],self.touch_pos[v.type][2])
								node:setTouchEnabled(true)
								self.map_layer1:addChild(node)

								self.effect_list[i].is_idle_ing = false
								local function animationCompleteFunc(event) 
									if event.animation == PlayerAction.action_2 then
										if self.effect_list[i] and not tolua.isnull(self.effect_list[i]) then
											self.effect_list[i]:setAnimation(0, PlayerAction.action_1, true)
											self.effect_list[i].is_idle_ing = false
										end
									end
								end
								self.effect_list[i]:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE) 
								
								node:addTouchEventListener(function(sender, event_type)
									if self.effect_list[i] == nil or tolua.isnull(self.effect_list[i]) or self.effect_list[i].is_idle_ing == true then return end
									self.effect_list[i].is_idle_ing = true
									self.effect_list[i]:setAnimation(0, PlayerAction.action_2, false)
								end)
							end
						end
					end
				end)
			end
		end
	end
end

--创建NPC
function GuildNewMainWindow:createNpc()
	local tempArr = {}
	for i,v in pairs(Config.GuildData.data_guild_scene_icon) do
		if v.res_type == 3 then -- 3npc类型
			table_insert(tempArr, v)
		end
	end
	
	for i,v in ipairs(tempArr) do
		if self.map_layer1 then
			if self.npc_list[i] == nil then
				delayRun(self.map_layer1, i*2 / display.DEFAULT_FPS,function ()
					if self.npc_list[i] == nil then
						self.npc_list[i] = createEffectSpine(v.icon,cc.p(v.pos[1][1],v.pos[1][2]),cc.p(0.5, 0.5),true,PlayerAction.action,nil,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)	
						if self.npc_list[i] and self.map_layer1 and not tolua.isnull(self.map_layer1) then
							self.map_layer1:addChild(self.npc_list[i])	
						end
					end
                end)
			end
		end
	end
end



--==============================--
--desc:一些权限控制
--time:2018-06-05 04:41:34
--@return 
--==============================--
function GuildNewMainWindow:updateJurisdiction()
	if self.role_vo == nil then return end
	if self.role_vo.position == GuildConst.post_type.member then
		self.sign_btn:setVisible(false)
		self.change_name_btn:setVisible(false) 
	else
		self.sign_btn:setVisible(true)
		self.change_name_btn:setVisible(true)
	end
end

--==============================--
--desc:更新宣言
--time:2018-05-31 08:33:30
--@return 
--==============================--
function GuildNewMainWindow:updateGuildSignInfo()
	if self.my_guild_info == nil then return end
	self.guild_sign_value:setString(self.my_guild_info.sign)
end

--==============================--
--desc:更新基础信息，等级，经验，成员数量，都是和等级相关的，所以在这里统一处理
--time:2018-05-31 08:33:42
--@return 
--==============================--
function GuildNewMainWindow:updateGuildBaseInfo()
	if self.my_guild_info == nil then return end 
	self.guild_lev_value:setString(string_format(TI18N("Lv.%s"), self.my_guild_info.lev))
	local config = Config.GuildData.data_guild_lev[self.my_guild_info.lev]
	if config ~= nil then
		if config.exp == 0 then
			self.progress_num:setString(TI18N("已满级"))
			self.progress:setPercent(100)
		else
			self.progress_num:setString(string_format("%s/%s", self.my_guild_info.exp, config.exp))
			self.progress:setPercent(math.floor(self.my_guild_info.exp/config.exp*100))
		end
	end

	-- 一些按钮权限开启的东西,只有未解锁才做判断
	self:checkGuildDunLockStatus()
	self:checkGuildWarStatus()
end

--==============================--
--desc:更新公会名称
--time:2018-06-09 02:29:24
--@return 
--==============================--
function GuildNewMainWindow:updateGuildNameInfo()
	if self.my_guild_info == nil then return end 
	self.guild_name_value:setString(self.my_guild_info.name) 
end

--==============================--
--desc:监测公会副本开启状态
--time:2018-06-09 12:01:09
--@return 
--==============================--
function GuildNewMainWindow:checkGuildDunLockStatus()
	local is_unlock = false
	if self.icon_list[GuildConst.icon_type.guild_icon_type_4].is_unlock == false then
		local config = Config.GuildDunData.data_const.guild_lev
		if config then
			is_unlock =(self.my_guild_info and self.my_guild_info.lev >= config.val)
			self.icon_list[GuildConst.icon_type.guild_icon_type_4].is_unlock = is_unlock			-- 等级解锁
			
			-- self.icon_list[GuildConst.icon_type.guild_icon_type_4]:setTouchEnabled(is_unlock)
			if is_unlock == false then
				setChildUnEnabled(true, self.icon_list[GuildConst.icon_type.guild_icon_type_4])
			else
				setChildUnEnabled(false, self.icon_list[GuildConst.icon_type.guild_icon_type_4])
			end
		end
	end 
end

-- 公会战开启状态
function GuildNewMainWindow:checkGuildWarStatus(  )
	local is_unlock = false

	if self.icon_list[GuildConst.icon_type.guild_icon_type_6].is_unlock == false then
		local config_lv = Config.GuildWarData.data_const.limit_lev -- 公会等级显示
		local config_day = Config.GuildWarData.data_const.limit_open_time -- 开服天数限制
		if config_lv and config_day then
			is_unlock =(self.my_guild_info and self.my_guild_info.lev >= config_lv.val)
			local tips_str = ""
			if is_unlock == true then
				local open_srv_day = RoleController:getInstance():getModel():getOpenSrvDay()
				is_unlock = (open_srv_day > config_day.val)
				tips_str = config_day.desc
			else
				tips_str = config_lv.desc
			end
			--[[if true then -- 暂时屏蔽
				is_unlock = false
				tips_str = TI18N("敬请期待!")
			end--]]

			self.icon_list[GuildConst.icon_type.guild_icon_type_6].is_unlock = is_unlock			-- 等级解锁
			
			-- self.icon_list[GuildConst.icon_type.guild_icon_type_6]:setTouchEnabled(is_unlock)
			if is_unlock == false then
				setChildUnEnabled(true, self.icon_list[GuildConst.icon_type.guild_icon_type_6])
			else
				setChildUnEnabled(false, self.icon_list[GuildConst.icon_type.guild_icon_type_6])
			end
		end
	end
end

--==============================--
--desc:更新公会帮主
--time:2018-05-31 08:34:05
--@return 
--==============================--
function GuildNewMainWindow:updateGuildLeaderInfo()
	if self.my_guild_info == nil then return end 
	self.guild_leader_value:setString(self.my_guild_info.leader_name) 
end


function GuildNewMainWindow:onCheckIcon(data )
	if not data then
		return
	end
	if data.type == GuildConst.icon_type.guild_icon_type_1 then --秘境
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildSecretArea)
	elseif data.type == GuildConst.icon_type.guild_icon_type_2 then --技能
		GuildskillController:getInstance():openGuildSkillMainWindow(true)
	elseif data.type == GuildConst.icon_type.guild_icon_type_3 then --宝库
		GuildmarketplaceController:getInstance():openGuildmarketplaceMainWindow(true)
	elseif data.type == GuildConst.icon_type.guild_icon_type_4 then --副本
		if self.icon_list[GuildConst.icon_type.guild_icon_type_4].is_unlock == false then
			local config = Config.GuildDunData.data_const.guild_lev
			if config then
				message(config.desc)
				return
			end
		end 

		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)
	elseif data.type == GuildConst.icon_type.guild_icon_type_5 then --商店
		MallController:getInstance():openMallPanel(true, MallConst.MallType.UnionShop)
	elseif data.type == GuildConst.icon_type.guild_icon_type_6 then --公会站
		if self.icon_list[GuildConst.icon_type.guild_icon_type_6].is_unlock == false then
			local config_lv = Config.GuildWarData.data_const.limit_lev -- 公会等级显示
			local config_day = Config.GuildWarData.data_const.limit_open_time -- 开服天数限制
			if config_lv and config_day then
				local is_unlock =(self.my_guild_info and self.my_guild_info.lev >= config_lv.val)
				local tips_str = ""
				if is_unlock == true then
					tips_str = config_day.desc
				else
					tips_str = config_lv.desc
				end
				message(tips_str)
				return
			end
		end

		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildWar)
		-- 清除掉联盟战开启的红点
		gw_model:updateGuildWarRedStatus(GuildConst.red_index.guildwar_start, false)
	elseif data.type == GuildConst.icon_type.guild_icon_type_7 then --活跃
		if self.role_vo ~= nil then
			local lev = Config.GuildQuestData.data_guild_action_data.open_glev.val
			if self.role_vo.guild_lev >= lev then
				controller:openGuildActionGoalWindow(true)
			else
				local str = string_format(TI18N("公会达到%d级后开启"),lev)
				message(str)
			end
		end
	elseif data.type == GuildConst.icon_type.guild_icon_type_8 then --捐献
		controller:openGuildDonateWindow(true)
	elseif data.type == GuildConst.icon_type.guild_icon_type_9 then --红包
		RedbagController:getInstance():openMainView(true)
	end
end


--==============================--
--desc:更新红点状态,如果type未指定，则全部更新
--time:2018-06-07 10:29:53
--@type:
--@return 
--==============================--
function GuildNewMainWindow:updateSomeRedStatus(type, status)
	local red_status = false
	if type == GuildConst.red_index.notice then
		self.notice_btn.tips:setVisible(status)
	elseif type == GuildConst.red_index.apply then
		self.check_member_btn.tips:setVisible(status)
	elseif type == GuildConst.red_index.boss_times then
		red_status = gb_model:checkGuildDunRedStatus()
		if self.icon_list[GuildConst.icon_type.guild_icon_type_4] then
			addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_4], red_status)
		end
	elseif type == GuildConst.red_index.donate or type == GuildConst.red_index.donate_activity then
		red_status = model:getDonateRedStatus() 
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_8], red_status)
	elseif type == GuildConst.red_index.skill_2 or type == GuildConst.red_index.skill_3 or 
		type == GuildConst.red_index.skill_4 or type == GuildConst.red_index.skill_5 or 
		type == GuildConst.red_index.pvp_skill_2 or type == GuildConst.red_index.pvp_skill_3 or 
		type == GuildConst.red_index.pvp_skill_4 or type == GuildConst.red_index.pvp_skill_5 or
		type == GuildConst.red_index.all_skill then
		red_status = RoleController:getInstance():getModel():getRedPointStatus(RoleConst.red_point.red_point_2)
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_2], red_status)
	elseif type == GuildConst.red_index.red_bag then 
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_9], status)
	elseif type == GuildConst.red_index.guild_secret_area then --公会秘境 --by lwc
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_1], status)
	elseif type == GuildConst.red_index.goal_action then
		if self.icon_list[GuildConst.icon_type.guild_icon_type_7] then
			addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_7], status)
		end
	elseif type == GuildConst.red_index.guildwar_start or type == GuildConst.red_index.guildwar_match or type == GuildConst.red_index.guildwar_count then
		red_status = gw_model:checkGuildGuildWarRedStatus()
		if self.icon_list[GuildConst.icon_type.guild_icon_type_6].is_unlock == false then
			red_status = false
		end
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_6], red_status)
	else
		red_status = model:getRedStatus(GuildConst.red_index.apply)
		self.check_member_btn.tips:setVisible(red_status)

		red_status = model:getDonateRedStatus()
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_8], red_status)

		red_status = gb_model:checkGuildDunRedStatus()
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_4], red_status)

		red_status = gw_model:checkGuildGuildWarRedStatus()
		if self.icon_list[GuildConst.icon_type.guild_icon_type_6].is_unlock == false then
			red_status = false
		end
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_6], red_status)

		red_status = RoleController:getInstance():getModel():getRedPointStatus(RoleConst.red_point.red_point_2)
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_2], red_status)

		red_status = redbag_model:getAllRedBagStatus()
		addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_9], red_status)

		--活跃红点
		red_status = model:getGoalRedStatus()
		if self.icon_list[GuildConst.icon_type.guild_icon_type_7] then 
			addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_7], red_status)
		end
		
		--秘境红点
		local sa_model = GuildsecretareaController:getInstance():getModel()
		local red_status = sa_model:checkRedPoint()
		if self.icon_list[GuildConst.icon_type.guild_icon_type_1] then
			addRedPointToNodeByStatus(self.icon_list[GuildConst.icon_type.guild_icon_type_1], red_status)
		end
	end
end

function GuildNewMainWindow:close_callback()
	doStopAllActions(self.guild_bg) 
	doStopAllActions(self.map_layer1)
	doStopAllActions(self.info_panel) 
	doStopAllActions(self.root_wnd)

	for i,v in pairs(self.effect_list) do
		if v then
			v:clearTracks()
			v:removeFromParent()
			v = nil
		end
	end
	self.effect_list = {}

	for i,v in pairs(self.npc_list) do
		if v then
			v:clearTracks()
			v:removeFromParent()
			v = nil
		end
	end
	self.npc_list = {}

	
	if self.my_guild_info ~= nil then
		if self.update_my_guild_info_event ~= nil then
			self.my_guild_info:UnBind(self.update_my_guild_info_event)
			self.update_my_guild_info_event = nil
		end
		self.my_guild_info = nil
	end
	if self.update_open_srv_day_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_open_srv_day_event)
		self.update_open_srv_day_event = nil
	end
	if self.role_vo ~= nil then
		if self.role_assets_event ~= nil then
			self.role_vo:UnBind(self.role_assets_event)
			self.role_assets_event = nil
		end
		self.role_vo = nil
	end
	if self.update_red_status_event then
		GlobalEvent:getInstance():UnBind(self.update_red_status_event)
		self.update_red_status_event = nil
	end
	controller:openGuildMainWindow(false)
end