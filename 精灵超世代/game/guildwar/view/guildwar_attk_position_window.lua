--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-16 10:37:47
-- @description    : 
		-- 联盟战 挑战据点
---------------------------------
GuildwarAttkPositionWindow = GuildwarAttkPositionWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarAttkPositionWindow:__init(  )
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big 
	self.is_full_screen = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
	}
	self.layout_name = "guildwar/guildwar_attk_position_window"

	self.item_list = {}
end

function GuildwarAttkPositionWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(container, 1)

    local top_panel = container:getChildByName("top_panel")
    local pos_panel = container:getChildByName("pos_panel")
    local buff_panel = container:getChildByName("buff_panel")
    buff_panel:setVisible(false)
    self.pos_panel = pos_panel
    self.buff_panel = buff_panel

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("挑战信息"))
    local title_label = container:getChildByName("title_label")
    title_label:setString(TI18N("胜利获得"))
	
    -- local award_label = pos_panel:getChildByName("award_label")
	local award_label = createRichLabel(18,Config.ColorData.data_new_color4[11],
	cc.p(0.5,0.5),cc.p(360,400),nil,nil,430)
	pos_panel:addChild(award_label)
    award_label:setString(TI18N("难度越高奖励越丰厚，最多可获得上述奖励！"))

    self.defend_label = top_panel:getChildByName("defend_label")
    local label_pos_x, label_pos_y = self.defend_label:getPosition()
    self.check_def_label = createRichLabel(18, 181, cc.p(0, 0.5), cc.p(label_pos_x+5, label_pos_y))
    self.check_def_label:setString(string.format(TI18N("<div fontColor=#249003 href=xxx>查看详情</div>")))
    self.check_def_label:addTouchLinkListener(function(type, value, sender, pos)
    	if self.data and self.data.pos then
    		local enemyBaseInfo = model:getEnemyGuildWarBaseInfo()
    		controller:openDefendLookWindow(true, enemyBaseInfo.g_id, enemyBaseInfo.g_sid, self.data.pos) -- 打开据点防守记录
    	end
    end, { "click", "href" })
    top_panel:addChild(self.check_def_label)

    local temp_index = {
    	[1] = 3,
    	[2] = 2,
    	[3] = 1
	}
    self.star_list = {}
    for i=1,3 do
    	local star = top_panel:getChildByName(string.format("star_%d", i))
    	if star then
    		star:setVisible(false)
    		local index = temp_index[i]
    		self.star_list[index] = star
    	end
    end

    self.close_btn = container:getChildByName("close_btn")
    self.easy_btn = pos_panel:getChildByName("easy_btn")
    local easy_btn_label = self.easy_btn:getChildByName("label")
    easy_btn_label:setString(TI18N("挑战"))
    self.com_btn = pos_panel:getChildByName("com_btn")
    local com_btn_label = self.com_btn:getChildByName("label")
    com_btn_label:setString(TI18N("挑战"))
    self.diff_btn = pos_panel:getChildByName("diff_btn")
    local diff_btn_label = self.diff_btn:getChildByName("label")
    diff_btn_label:setString(TI18N("挑战"))

    -- self.tips_label = container:getChildByName("tips_label")
	self.tips_label = createRichLabel(18,Config.ColorData.data_color3[175],
	cc.p(0,0.5),cc.p(60,30),nil,nil,350)
	container:addChild(self.tips_label)
	self.tips_label:setString(TI18N("难度越高，敌方属性加成越高"))
	self.award_bg = container:getChildByName("image_2")

    self.count_label = container:getChildByName("count_label")
    self.easy_label = pos_panel:getChildByName("easy_label")
    self.easy_coe_label = pos_panel:getChildByName("easy_coe_label")
    self.com_label = pos_panel:getChildByName("com_label")
    self.com_coe_label = pos_panel:getChildByName("com_coe_label")
    self.diff_label = pos_panel:getChildByName("diff_label")
    self.diff_coe_label = pos_panel:getChildByName("diff_coe_label")
    self.good_con = container:getChildByName("good_con")

    self.image_easy = pos_panel:getChildByName("image_easy")
    self.image_com = pos_panel:getChildByName("image_com")
    self.image_dif = pos_panel:getChildByName("image_dif")

    local buff_count_title = buff_panel:getChildByName("buff_count_title")
    buff_count_title:setString(TI18N("据点挑战次数:"))
    local count_title = container:getChildByName("count_title")
    count_title:setString(TI18N("挑战次数:"))

    self.challenge_btn = buff_panel:getChildByName("challenge_btn")
    self.challenge_btn_label = self.challenge_btn:getChildByName("label")
    self.challenge_btn_label:setString(TI18N("挑战"))

    self.buff_count_label = buff_panel:getChildByName("buff_count_label")
    self.lv_label = buff_panel:getChildByName("lv_label")
    self.progress_bg = buff_panel:getChildByName("progress_bg")
    local progress_size = self.progress_bg:getContentSize()
    self.progress = ccui.LoadingBar:create()
    self.progress:setCascadeOpacityEnabled(true)
    self.progress:setScale9Enabled(true)
    self.progress:setAnchorPoint(cc.p(0, 0.5))
    self.progress:setContentSize(progress_size)
    self.progress:loadTexture(PathTool.getResFrame("common", "common_30006"), LOADTEXT_TYPE_PLIST)
    self.progress:setPosition(cc.p(0, progress_size.height/2))
    self.progress:setPercent(0)
    self.progress_bg:addChild(self.progress)

    self.attr_panel = {}
    for i=1,6 do
    	local attr_panel = buff_panel:getChildByName(string.format("attr_panel_%d", i))
    	if attr_panel then
    		attr_panel.attr_label = attr_panel:getChildByName("attr_label")
    		attr_panel.attr_value_1 = attr_panel:getChildByName("attr_value_1")
    		attr_panel.attr_value_2 = attr_panel:getChildByName("attr_value_2")
    		attr_panel.attr_image = attr_panel:getChildByName("image")
    		self.attr_panel[i] = attr_panel
    	end
    end

    local good_con_size = self.good_con:getContentSize()
    self.good_con_size = good_con_size
    self.item_scroll_view = createScrollView(good_con_size.width, good_con_size.height, 0, good_con_size.height/2, self.good_con, ccui.ScrollViewDir.horizontal) 
    self.item_scroll_view:setAnchorPoint(cc.p(0, 0.5))
    self.item_scroll_view:setInnerContainerSize(cc.size(good_con_size.width, good_con_size.height))
end

function GuildwarAttkPositionWindow:setData( data )
	self.data = data

	self.pos_panel:setVisible(data.hp > 0)
	self.buff_panel:setVisible(data.hp <= 0)
	local power = data.power or 0
	if data.hp > 0 then
		if data.hp == 1 then
		setChildUnEnabled(true, self.com_btn)
		setChildUnEnabled(true, self.diff_btn)
		setChildUnEnabled(true, self.image_com)
		setChildUnEnabled(true, self.image_dif)
		elseif data.hp == 2 then
			setChildUnEnabled(true, self.diff_btn)
			setChildUnEnabled(true, self.image_dif)
		end

		-- 难度系数显示
		local easy_cfg = Config.GuildWarData.data_const["easy_difficulty"]
		self.easy_coe_label:setString(easy_cfg.val/10 .. "%" .. TI18N("难度"))
		local normal_cfg = Config.GuildWarData.data_const["normal_difficulty"]
		self.com_coe_label:setString(normal_cfg.val/10 .. "%" .. TI18N("难度"))
		local hard_cfg = Config.GuildWarData.data_const["hard_difficulty"]
		self.diff_coe_label:setString(hard_cfg.val/10 .. "%" .. TI18N("难度"))

		local pos_data = Config.GuildWarData.data_position[data.pos]
		if pos_data then
			local easy_value = pos_data.warscore[1][2] or 0
			self.easy_label:setString(string.format(TI18N("+%d战绩"), math.ceil(easy_value)))
			local com_value = pos_data.warscore[2][2] or 0
			self.com_label:setString(string.format(TI18N("+%d战绩"), math.ceil(com_value)))
			local diff_value = pos_data.warscore[3][2] or 0
			self.diff_label:setString(string.format(TI18N("+%d战绩"), math.ceil(diff_value)))
		end

		self.award_bg:setContentSize(cc.size(560, 190))
		self.tips_label:setString(TI18N("难度越高，敌方属性加成越高"))
	else
		self.award_bg:setContentSize(cc.size(560, 160))
		self.tips_label:setString(TI18N("挑战成功可增强公会增益"))

		local myGuildBaseData = model:getMyGuildWarBaseInfo()
		local buff_lev = myGuildBaseData.buff_lev or 0
	    local max_level = Config.GuildWarData.data_buff_length
		self.progress:setPercent(buff_lev/max_level*100)
		self.lv_label:setString(string.format("%d/%d", buff_lev, max_level))

		local cur_buff_info = Config.GuildWarData.data_buff[buff_lev] or {}
		local next_buff_info = Config.GuildWarData.data_buff[buff_lev+1] or {}
		cur_buff_info.attr = cur_buff_info.attr or {}
		next_buff_info.attr = next_buff_info.attr or {}
		for i=1,6 do
	    	local attr_panel = self.attr_panel[i]
	    	if not cur_buff_info.attr[i] and not next_buff_info.attr[i] then
	    		attr_panel:setVisible(false)
	    	else
	    		attr_panel:setVisible(true)
	    		local attr_info = cur_buff_info.attr[i] or next_buff_info.attr[i]
	    		local attr_name = Config.AttrData.data_key_to_name[attr_info[1]]
	    		local cur_value = 0
	    		if cur_buff_info.attr[i] then
	    			cur_value = cur_buff_info.attr[i][2]
	    		end
	    		local next_value
	    		if next_buff_info.attr[i] then
	    			next_value = next_buff_info.attr[i][2]
	    		end
	    		attr_panel.attr_label:setString(attr_name)
	    		local is_per = PartnerCalculate.isShowPerByStr(attr_info[1])-- 是否为千分比
	    		if is_per then 
	    			cur_value = cur_value/10 .. "%"
	    		end
	    		attr_panel.attr_value_1:setString(cur_value)
	    		if next_value then
	    			if is_per then 
						next_value = next_value/10 .. "%"
					end
	    			attr_panel.attr_value_2:setString(next_value)
	    			attr_panel.attr_value_2:setVisible(true)
	    			attr_panel.attr_image:setVisible(true)
	    		else
	    			attr_panel.attr_value_2:setVisible(false)
	    			attr_panel.attr_image:setVisible(false)
	    		end
	    	end
	    end

	    local max_count_1 = 0
	    local count_config = Config.GuildWarData.data_const.ruins_challange_limit
	    if count_config then
	    	max_count_1 = count_config.val
	    end
	    local cur_count_1 = data.relic_def_count or 0
	    local left_count_1 = max_count_1-cur_count_1
	    if left_count_1 < 0 then
	    	left_count_1 = 0
	    end
	    if left_count_1 > 0 then
	    	self.buff_count_label:setTextColor(Config.ColorData.data_color4[178])
	    else
	    	self.buff_count_label:setTextColor(Config.ColorData.data_color4[183])
	    end
	    self.buff_count_label:setString(string.format("%d/%d", left_count_1, max_count_1))

	    if cur_count_1 >= max_count_1 then
	    	setChildUnEnabled(true, self.challenge_btn)
	    	self.challenge_btn:setTouchEnabled(false)
	    	self.challenge_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
	    end
	end

	-- 星数
	for i=1,3 do
		local star = self.star_list[i]
		if star and i > data.hp then
			star:setVisible(true)
		else
			star:setVisible(false)
		end
	end

	self.defend_label:setString(string.format(TI18N("已成功防御%d次"), data.def_count or 0))

	local award_data = Config.GuildWarData.data_const.win_strongholds_reward_hard
	if award_data and award_data.val then
		local item_num = #award_data.val
		local space_x = 30
		local scale = 0.8
		local start_x = (self.good_con_size.width-item_num*BackPackItem.Width*scale-(item_num-1)*space_x)/2
		if start_x < 0 then
			start_x = 0
		end
		for k,award in pairs(award_data.val) do
			if type(award) == "table" then
				local bid = award[1]
	            local num = award[2]
	            local item_conf = Config.ItemData.data_get_data(bid)
	            if item_conf then
	            	local item = self.item_list[k]
	            	if not item then
	            		item = BackPackItem.new(false, true, false, 1, false, true)
	            		item:setDefaultTip(true,true)
	                	item:setScale(scale)
	                	self.item_scroll_view:addChild(item)
	                	self.item_list[k] = item
	            	end
	                local _x = start_x + (BackPackItem.Width*scale + space_x) * (k-1) + BackPackItem.Width*scale*0.5
	                local _y = self.good_con_size.height/2
	                item:setBaseData(bid, num)	                
	                item:setPosition(_x, _y)
	            end
			end
		end
	end

	local challenge_count = model:getGuildWarChallengeCount()
	local max_count = Config.GuildWarData.data_const.challange_time_limit.val
	local left_count = max_count-challenge_count
	if left_count < 0 then
		left_count = 0
	end
	if left_count > 0 then
    	self.count_label:setTextColor(Config.ColorData.data_color4[178])
    else
    	self.count_label:setTextColor(Config.ColorData.data_color4[183])
    end
	self.count_label:setString(string.format("%d/%d", left_count, max_count))

	-- 敌方阵容
	if not self.enemy_battle_array_panel then
		self.enemy_battle_array_panel = GuildwarBattleArrayPanel.new()
		local container_size = self.container:getContentSize()
		self.container:addChild(self.enemy_battle_array_panel)
		self.enemy_battle_array_panel:setPosition(cc.p(42, 645))
	end
	local battle_array_data = {}
	local partner_list = {}
	for k,v in pairs(data.defense) do
		table.insert(partner_list, v)
	end
	battle_array_data.partner_list = partner_list
	battle_array_data.rid = data.rid
	battle_array_data.srv_id = data.srv_id
	battle_array_data.power = power
	battle_array_data.formation_type = data.formation_type
	battle_array_data.formation_lev = data.formation_lev
	self.enemy_battle_array_panel:setData(battle_array_data)
end

function GuildwarAttkPositionWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openAttkPositionWindow(false)
		end
	end)
	
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openAttkPositionWindow(false)
		end
	end)

	self.easy_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.pos then
				-- 判断一下实时血量
				--[[if model:getEnemyPositionHpByPos(self.data.pos) <= 0 then
					controller:requestGuildWarFighting(self.data.pos, 0, 1)
				else
					controller:requestGuildWarFighting(self.data.pos, 1, 0)
				end--]]
				controller:requestGuildWarFighting(self.data.pos, 1, 0)
			end
		end
	end)

	self.com_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.pos then
				-- 判断一下实时血量
				--[[if model:getEnemyPositionHpByPos(self.data.pos) <= 0 then
					controller:requestGuildWarFighting(self.data.pos, 0, 1)
				else
					controller:requestGuildWarFighting(self.data.pos, 2, 0)
				end--]]
				controller:requestGuildWarFighting(self.data.pos, 2, 0)
			end
		end
	end) 
	
	self.diff_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.data.pos then
				-- 判断一下实时血量
				--[[if model:getEnemyPositionHpByPos(self.data.pos) <= 0 then
					controller:requestGuildWarFighting(self.data.pos, 0, 1)
				else
					controller:requestGuildWarFighting(self.data.pos, 3, 0)
				end--]]
				controller:requestGuildWarFighting(self.data.pos, 3, 0)
			end
		end
	end)
	-- 挑战废墟
	self.challenge_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			-- 判断是否还有存活的据点
			if model:checkEnemyIsHaveLivePosition() then
				local function fun()
					controller:requestGuildWarFighting(self.data.pos, 0, 1)
				end
				local str = string.format(TI18N("挑战废墟获得的战绩将大大减少，推荐优先挑战其他未沦陷的据点，请问是否继续挑战废墟？"))
				CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.common)
			else
				controller:requestGuildWarFighting(self.data.pos, 0, 1)
			end
		end
	end) 
end

function GuildwarAttkPositionWindow:openRootWnd( pos )
	controller:requestEnemyPositionData(pos)
end

function GuildwarAttkPositionWindow:close_callback(  )
	if self.enemy_battle_array_panel then
		self.enemy_battle_array_panel:DeleteMe()
		self.enemy_battle_array_panel = nil
	end
	for k,item in pairs(self.item_list) do
		item:DeleteMe()
		item = nil
	end
	controller:openAttkPositionWindow(false)
end