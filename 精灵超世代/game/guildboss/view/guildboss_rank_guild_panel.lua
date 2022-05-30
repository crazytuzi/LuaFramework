-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      排行榜公会标签面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildBossRankGuildPanel = class("GuildBossRankGuildPanel", function()
	return ccui.Layout:create()
end)

function GuildBossRankGuildPanel:ctor() 
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_rank_guild_panel"))
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd) 

    self.container = self.root_wnd:getChildByName("container")
    self.title_1 = self.container:getChildByName("title_1")
    self.title_1:setString(TI18N("排名"))

    self.title_2 = self.container:getChildByName("title_2")
    self.title_2:setString(TI18N("公会名字"))

    self.title_3 = self.container:getChildByName("title_3")
    self.title_3:setString(TI18N("本周通关"))

    self.title_4 = self.container:getChildByName("title_4")
    self.title_4:setString(TI18N("今日总伤害"))

    self.my_guild_rank = self.root_wnd:getChildByName("my_guild_rank")              -- 我的公会排行
    self.my_guild_chapter = self.root_wnd:getChildByName("my_guild_chapter")        -- 我的公会章节
    self.my_guild_chapter_1 = self.root_wnd:getChildByName("my_guild_chapter_1")    --我的公会章节数
    self.my_guild_dps = self.root_wnd:getChildByName("my_guild_dps")                -- 我的公会今日总伤害
    self.my_guild_dps_1 = self.root_wnd:getChildByName("my_guild_dps_1")            --我的公会章节数


    self.top_container = self.root_wnd:getChildByName("top_container")
    self.notice = self.top_container:getChildByName("notice")
    self.notice:setString(TI18N("虚位以待！"))

    self.info_container = self.top_container:getChildByName("info_container")
    self.role_name = self.info_container:getChildByName("role_name")
    self.check_btn = self.info_container:getChildByName("check_btn")
    self.check_btn:getChildByName("label"):setString(TI18N("查看详情"))
    self.fight_label = CommonNum.new(20, self.info_container, 99999, - 2, cc.p(0, 0.5))
	self.fight_label:setPosition(176, 48)
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
	self.role_head:setPosition(84, 65)
    self.info_container:addChild(self.role_head)

    self.empty_tips = self.root_wnd:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无任何排名"))

    self:registerEvent()
end

function GuildBossRankGuildPanel:registerEvent()
    self.check_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playTabButtonSound()
            if self.no_1_rid and self.no_1_srv_id then
                FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.no_1_srv_id, rid = self.no_1_rid})
            end
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

function GuildBossRankGuildPanel:addToParent(status)
    self:setVisible(status)
    if self.scroll_view == nil then
        GuildbossController:getInstance():requestGuildDunRank(GuildBossConst.rank.guild)
    end
end

function GuildBossRankGuildPanel:updateRankData(data)
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
            local size = cc.size(self.container:getContentSize().width,450)
            local setting = {
                item_class = GuildBossRankGuildItem,
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

        -- 自己公会的排名
        if data.my_rank == 0 then
            self.my_guild_rank:setString(TI18N("我的公会排名：未上榜"))
        else
            self.my_guild_rank:setString(string.format(TI18N("我的公会排名：%s"), data.my_rank))
        end
        self.my_guild_chapter:setString(TI18N("本周已通关："))
        self.my_guild_chapter_1:setString(data.my_max_id)
        self.my_guild_dps:setString(TI18N("今日总伤害："))
        self.my_guild_dps_1:setString(data.my_dps)
    end
end

function GuildBossRankGuildPanel:DeleteMe()
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
GuildBossRankGuildItem = class("GuildBossRankGuildItem", function()
	return ccui.Layout:create()
end)

function GuildBossRankGuildItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_rank_guild_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
    self.rank_img = self.root_wnd:getChildByName("rank_img") -- common_3001 -3003
    self.guild_name = self.root_wnd:getChildByName("guild_name")
    self.guild_leader = self.root_wnd:getChildByName("guild_leader")
    self.chapter_value = self.root_wnd:getChildByName("chapter_value")
    self.day_dps = self.root_wnd:getChildByName("day_dps")
    self.rank_value = self.root_wnd:getChildByName("rank_value")
end

function GuildBossRankGuildItem:setData(data)
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

        self.guild_name:setString(data.name)
        self.guild_leader:setString(string.format(TI18N("会长：%s"), data.r_name))
        self.chapter_value:setString(string.format(TI18N("第%s章"),StringUtil.numToChinese(data.max_id)))
        self.day_dps:setString(string.format(TI18N("%s"), data.day_dps))
    end
end

function GuildBossRankGuildItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 