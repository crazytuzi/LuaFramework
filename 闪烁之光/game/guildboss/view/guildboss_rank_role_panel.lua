-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--     排行榜的个人排行榜标签面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossRankRolePanel = class("GuildBossRankRolePanel", function()
	return ccui.Layout:create()
end)

local model = GuildbossController:getInstance():getModel()
local controller = GuildbossController:getInstance()
local string_format = string.format 

function GuildBossRankRolePanel:ctor(data)
	self.data = data
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_rank_role_panel"))
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	self.container = self.root_wnd:getChildByName("container")
	
	self.my_rank = self.root_wnd:getChildByName("my_rank")              -- 我的公会排行
	self.my_dps = self.root_wnd:getChildByName("my_dps")                -- 我的公会今日总伤害
	
    self.top_container = self.root_wnd:getChildByName("top_container")
    self.notice = self.top_container:getChildByName("notice")
    self.notice:setString(TI18N("虚位以待！"))

    self.info_container = self.top_container:getChildByName("info_container")
    self.role_name = self.info_container:getChildByName("role_name")
    self.check_btn = self.info_container:getChildByName("check_btn")
	self.check_btn:getChildByName("label"):setString(TI18N("查看详情"))
	self.reward_btn = self.root_wnd:getChildByName("reward_btn")
	self.reward_btn:getChildByName("label"):setString(TI18N("奖励一览"))

    self.fight_label = CommonNum.new(20, self.info_container, 99999, - 2, cc.p(0, 0.5))
	self.fight_label:setPosition(176, 48)
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
	self.role_head:setPosition(84, 65)
    self.role_head:setLev(99)
    self.info_container:addChild(self.role_head)

	self.empty_tips = self.root_wnd:getChildByName("empty_tips")
	self.empty_tips:getChildByName("desc"):setString(TI18N("暂无任何排名")) 
	
	self:registerEvent()
end

function GuildBossRankRolePanel:registerEvent()
	self.check_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playTabButtonSound()
            if self.no_1_rid and self.no_1_srv_id then
                FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.no_1_srv_id, rid = self.no_1_rid})
            end
		end
	end)
	self.reward_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playTabButtonSound()
			controller:oepnGuildRewardShowView(true)
		end
	end)
	if self.update_rank_event == nil then
		self.update_rank_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateGuildDunRank, function(data, index)
			if index == GuildBossConst.rank.guild then
				self:updateRankData(data)
			end
		end)
	end 
end

function GuildBossRankRolePanel:addToParent(status)
	self:setVisible(status)
	
	if self.scroll_view == nil then
		if self.data then
			GuildbossController:getInstance():requestGuildDunRank(GuildBossConst.rank.guild)
			-- local protocal = {boss_id = self.data.boss_id, start_num = 1, end_num = 100}
			-- GuildbossController:getInstance():requestGuildDunRank(GuildBossConst.rank.role,protocal) 
		end
	end
end

function GuildBossRankRolePanel:updateRankData(data)
    if data == nil or data.rank_guild == nil or next(data.rank_guild) == nil then
        self.empty_tips:setVisible(true)
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
        self.notice:setVisible(true)
        self.info_container:setVisible(false)
    else
        self.empty_tips:setVisible(false)
		if self.scroll_view == nil then
			local size = cc.size(self.container:getContentSize().width, 450)
			local setting = {
				item_class = GuildBossRankRoleItem,
				start_x = 4,
				space_x = 4,
				start_y = -5,
				space_y = 0,
				item_width = 600,
				item_height = 123,
				row = 0,
				col = 1
			}
			self.scroll_view = CommonScrollViewLayout.new(self.container, nil, nil, nil, size, setting) 
		end
        -- 更新排行榜数据
        self.scroll_view:setData(data.rank_guild)

        self.notice:setVisible(false)
        self.info_container:setVisible(true)		
		-- 设置排名第一的显示
		self.role_name:setString(data.r_name)
		self.fight_label:setNum(data.power)
		self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
		self.role_head:setLev(data.lev)

        -- 储存排名第一的信息，用于点击头像处理
        self.no_1_rid = data.r_rid
        self.no_1_srv_id = data.r_srvid 

		-- 自己
        if data.my_rank == 0 then
            self.my_rank:setString(TI18N("我的公会排名：未上榜"))
        else
            self.my_rank:setString(string_format(TI18N("我的公会排名：%s"), data.my_rank))
		end
		self.my_dps:setString(string_format(TI18N('本周结算奖励:')))
		-- if self.my_rank_reward == nil then
		-- 	self.my_rank_reward = createRichLabel(20, 181, cc.p(0, 1), cc.p(180, 55), 10,nil, 250)
		-- 	self.root_wnd:addChild(self.my_rank_reward)
		-- end
		if Config.GuildDunData.data_chapter_reward and Config.GuildDunData.data_chapter_reward[data.my_max_id] then
			local rewards_list = Config.GuildDunData.data_chapter_reward[data.my_max_id].award_list--model:getRankAward(data.my_rank)
			local pos = {{x =180,y=55},{x=320,y=55},{x=180,y=15},{x = 320,y=15}}
			if rewards_list and next(rewards_list or {}) ~= nil then
				local desc = ''
				for i, v in ipairs(rewards_list) do
					local item_config = Config.ItemData.data_get_data(v[1])
					if item_config ~= nil then
						local label = createRichLabel(20, 181, cc.p(0, 1), cc.p(pos[i].x,pos[i].y), 10, nil, 250)
						self.root_wnd:addChild(label)
						local str = string_format("<img src=%s visible=true scale=0.3 /> %s", PathTool.getItemRes(item_config.icon), v[2])
						label:setString(str)
						-- if desc ~= '' then
						-- 	desc = desc .. '      '
						-- end
						--desc = desc .. string_format('<img src=%s visible=true scale=0.3 /> %s', PathTool.getItemRes(item_config.icon), v[2])
					end
				end
				--self.my_rank_reward:setString(string_format(TI18N('%s'), desc))
			else
				-- if self.my_rank_reward then
				-- 	self.my_rank_reward:setString(TI18N("暂无奖励"))
				-- end
			end
		end

        --self.my_dps:setString(string_format(TI18N("今日伤害：%s"), data.mydps))
    end
end 

function GuildBossRankRolePanel:DeleteMe()
    if self.update_rank_event then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end
	if self.fight_label then
		self.fight_label:DeleteMe()
		self.fight_label = nil
	end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      排行榜公会单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossRankRoleItem = class("GuildBossRankRoleItem", function()
	return ccui.Layout:create()
end)

function GuildBossRankRoleItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_rank_role_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)

	self.rank_img = self.root_wnd:getChildByName("rank_img") -- common_3001 -3003
    self.rank_value = self.root_wnd:getChildByName("rank_value")
   	--self.day_dps = self.root_wnd:getChildByName("day_dps")
    self.guild_name = self.root_wnd:getChildByName("guild_name")
    self.role_name = self.root_wnd:getChildByName("role_name")
end

function GuildBossRankRoleItem:setData(data)
	if data then
		if data.rank <= 3 then
            self.rank_value:setVisible(false) 
            self.rank_img:setVisible(true) 
            local res_id = PathTool.getResFrame("common", "common_300"..data.rank)
            if self.res_id ~= res_id then
                self.res_id = res_id
                loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST) 
            end
        else
            self.rank_img:setVisible(false) 
            self.rank_value:setVisible(true)
            self.rank_value:setString(data.rank)
        end

        self.role_name:setString(data.name)
        self.guild_name:setString(string_format(TI18N("会长：%s"), data.r_name))
		--self.day_dps:setString(string_format(TI18N("今日总伤害：%s"), data.all_dps))
		--self.day_dps:setString("本周结算奖励:")
		local rewards_list = Config.GuildDunData.data_chapter_reward[data.max_id].award_list --model:getRankAward(data.rank)
		if rewards_list and next(rewards_list) then
			-- if self.rank_reward == nil then
			-- 	self.rank_reward = createRichLabel(20, 181, cc.p(0, 0.5), cc.p(365, self.size.height/2), 20, nil, 250) 
			-- 	self.root_wnd:addChild(self.rank_reward)
			-- end
			local desc = ""
			local count = 0
			local pos = {{x = 375, y = 100}, {x = 490, y = 100}, {x = 375, y = 60}, {x = 490, y = 60}}

			for i,v in ipairs(rewards_list) do
				local item_config = Config.ItemData.data_get_data(v[1])
				if item_config ~= nil then
					-- if desc ~= "" then
					-- 	desc = desc.."   "
					-- end
					-- desc = desc..string_format("<img src=%s visible=true scale=0.3 />%s", PathTool.getItemRes(item_config.icon), v[2]) 
					local label = createRichLabel(20, 181, cc.p(0, 1), cc.p(pos[i].x, pos[i].y), 10, nil, 250)
					self.root_wnd:addChild(label)
					local str = string_format("<img src=%s visible=true scale=0.3 /> %s", PathTool.getItemRes(item_config.icon), v[2])
					label:setString(str)

				end
			end
			--self.rank_reward:setString(string_format(TI18N("%s"), desc))
		else
			--if self.rank_reward then
				--self.rank_reward:setVisible(false)
			--end
		end
	end
end

function GuildBossRankRoleItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 