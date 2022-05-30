-- --------------------------------------------------------------------
-- @author: htp(必填, 创建模块的人员)
-- @description:
--      联盟战主界面
-- --------------------------------------------------------------------
GuildwarMainWindow = GuildwarMainWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarMainWindow:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full
	self.layout_name = "guildwar/guildwar_main_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/guildwar","guildwar_1"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg/guildwar","guildwar_2"), type = ResourcesType.single },
	}

	self.cur_position_type = GuildwarConst.positions.others -- 当前阵地类型
    self.position_vo_data = {} -- 据点数据
    self.position_stack = {}   -- 创建的据点
    self.position_pool = {}    -- 缓存池中的据点
    self.position_pos = {}     -- 正在显示中的据点
    self.map_bgs = {}          -- 地图资源
    self.top3_item_list = {}
end 

function GuildwarMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.map_layer = self.main_container:getChildByName("map_layer")

    self.show_panel = self.main_container:getChildByName("show_panel")
    self.state_panel = self.main_container:getChildByName("state_panel")
    self.top_panel = self.main_container:getChildByName("top_panel")

    self.myguild_container = self.show_panel:getChildByName("myguild_container")
    self.enemyguild_container = self.show_panel:getChildByName("enemyguild_container")

    self.rank_container = self.show_panel:getChildByName("rank_container")
    self.title_container = self.show_panel:getChildByName("title_container")
    self.buff_container = self.show_panel:getChildByName("buff_container")

    --local title_label = self.top_panel:getChildByName("title_label")
    --title_label:setString(TI18N("公会战"))

    self.battle_list_btn = self.show_panel:getChildByName("battle_list_btn")
    self.battle_list_btn_label = self.battle_list_btn:getChildByName("label")
    self.battle_list_btn_label:setString(TI18N("对阵列表"))

    self.attk_check_btn = self.show_panel:getChildByName("attk_check_btn")
    self.attk_check_btn_label = self.attk_check_btn:getChildByName("label")
    self.attk_check_btn_label:setString(TI18N("进攻一览"))

    self.ally_atk_btn = self.show_panel:getChildByName("ally_atk_btn")
    self.ally_atk_btn_label = self.ally_atk_btn:getChildByName("label")
    self.ally_atk_btn_label:setString(TI18N("进攻日志"))

    self.look_award_btn = self.show_panel:getChildByName("look_award_btn")
    self.look_award_btn_label = self.look_award_btn:getChildByName("label")
    self.look_award_btn_label:setString(TI18N("玩法奖励"))

    local tips_label_1 = self.buff_container:getChildByName("tips_label_1")
    tips_label_1:setString(TI18N("挑战据点废墟可激活或提升全公会增益"))
    
    self.change_scene_btn = self.show_panel:getChildByName("change_scene_btn")
    self.change_scene_btn_label = self.change_scene_btn:getChildByName("label")
    self.change_scene_btn_label:setString(TI18N("敌方阵地"))

    self.award_box_btn = self.show_panel:getChildByName("award_box_btn")
    self.award_box_btn:getChildByName("label"):setString(TI18N("战果宝箱"))

    self.clash_list_btn = self.state_panel:getChildByName("clash_list_btn")
    self.clash_list_btn:setTitleText(TI18N("对阵列表"))
    self.clash_list_btn_label = self.clash_list_btn:getTitleRenderer()
    if self.clash_list_btn_label ~= nil then
        self.clash_list_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
    end

    self.look_box_btn = self.state_panel:getChildByName("look_box_btn")
    self.look_box_btn:getChildByName("label"):setString(TI18N("战果宝箱"))

    local rank_desc_label = self.rank_container:getChildByName("rank_desc_label")
    rank_desc_label:setString(TI18N("战绩排行榜"))

    self.rank_btn = self.rank_container:getChildByName("rank_btn")
    self.close_btn = self.top_panel:getChildByName("close_btn")
    self.explain_btn = self.top_panel:getChildByName("explain_btn")

    self.time_label = self.title_container:getChildByName("time_label")
    self.challenge_label = self.title_container:getChildByName("challenge_label")
    self.state_tips_label = self.state_panel:getChildByName("state_tips_label")
    self.buff_lv_label = self.buff_container:getChildByName("buff_lv_label")
    self.buff_icon = self.buff_container:getChildByName("buff_icon")

    self.my_guild_name_label = self.myguild_container:getChildByName("guild_name_label_1")
    self.my_guild_star_label = self.myguild_container:getChildByName("star_label_1")
    self.my_guild_win = self.myguild_container:getChildByName("image_win_1")
    self.my_guild_dogfall = self.myguild_container:getChildByName("image_dogfall_1")
    self.enemy_guild_name_label = self.enemyguild_container:getChildByName("guild_name_label_2")
    self.enemy_guild_star_label = self.enemyguild_container:getChildByName("star_label_2")
    self.enemy_guild_win = self.enemyguild_container:getChildByName("image_win_2")
    self.enemy_guild_dogfall = self.enemyguild_container:getChildByName("image_dogfall_2")

    -- 适配
    self:adjustPanlePosition()

    self.map_size = cc.size(720,1280*6)
    self.map_layer:setContentSize(self.map_size)
    self.map_layer:setPosition(cc.p(self.map_layer_posX, (self.free_size.height - self.map_size.height + self.map_layer_posY)))
    self:addMapImage()
end

function GuildwarMainWindow:adjustPanlePosition(  )
    local top_height = display.getTop()
    local top_view_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    local free_size_height = MainuiController:getInstance():getMainUi():getFreeSize()
    self.free_size = cc.size(SCREEN_WIDTH, free_size_height)
    self.main_container_size = self.main_container:getContentSize()

    local off_bottom = math.abs(display.getBottom(self.main_container))
    local off_left = display.getLeft(self.main_container)
    local off_right = display.getRight(self.main_container)-self.main_container_size.width
    local old_pos_x, old_pos_y = self.map_layer:getPosition()

    self.map_scalex = display.getScale()
    self.map_layer_posX = old_pos_x+off_left
    self.map_layer_posY = old_pos_y-off_bottom
    self.map_layer:setPosition(cc.p(self.map_layer_posX, self.map_layer_posY))
    self.map_layer:setScaleX(self.map_scalex)

    local top_panel_posY = display.getTop(self.main_container)-top_view_height-30
    local offset_y = top_panel_posY - self.top_panel:getPositionY() -- y轴偏移
    self.top_panel:setPositionY(top_panel_posY)
    self.title_container:setPositionY(self.title_container:getPositionY()+offset_y)
    self.state_panel:setContentSize(cc.size(self.free_size.width, display.height))
    -- self.state_panel:setPosition(cc.p(self.main_container_size.width/2, display.height*0.5))
    self.state_tips_label:setPosition(cc.p(self.free_size.width/2, display.height/2+20))
    self.clash_list_btn:setPosition(cc.p(self.free_size.width/2, display.height/2-80))
    self.look_box_btn:setPositionY(top_panel_posY-117)

    self.myguild_container:setPosition(cc.p(self.myguild_container:getPositionX()+off_left,self.myguild_container:getPositionY()+offset_y))
    self.enemyguild_container:setPosition(cc.p(self.enemyguild_container:getPositionX()+off_right,self.enemyguild_container:getPositionY()+offset_y))
    self.rank_container:setPosition(cc.p(self.rank_container:getPositionX()+off_left,self.rank_container:getPositionY()+offset_y))
    self.buff_container:setPosition(cc.p(self.buff_container:getPositionX()+off_left,self.buff_container:getPositionY()-off_bottom))
    self.ally_atk_btn:setPosition(cc.p(self.ally_atk_btn:getPositionX()+off_left,self.ally_atk_btn:getPositionY()+offset_y))
    self.look_award_btn:setPosition(cc.p(self.look_award_btn:getPositionX()+off_left,self.look_award_btn:getPositionY()+offset_y))
    self.award_box_btn:setPosition(cc.p(self.award_box_btn:getPositionX()+off_left,self.award_box_btn:getPositionY()+offset_y))
    self.change_scene_btn:setPosition(cc.p(self.change_scene_btn:getPositionX()+off_right,self.change_scene_btn:getPositionY()-off_bottom))
    self.battle_list_btn:setPosition(cc.p(self.battle_list_btn:getPositionX()+off_right,self.battle_list_btn:getPositionY()+offset_y))
    self.attk_check_btn:setPosition(cc.p(self.attk_check_btn:getPositionX()+off_right,self.attk_check_btn:getPositionY()+offset_y))
end

function GuildwarMainWindow:openRootWnd(  )
	local flag = model:getGuildWarEnemyFlag()
    local status = model:getGuildWarStatus()

    self:refreshGuildWarStatus()
    self:updateMainRedStatus()

	-- 打开界面时判断，如果有匹配到对手且状态为开战中或结算，但无缓存数据，则请求数据
	if flag == TRUE and status > GuildwarConst.status.showing and not model:checkIsHaveEnemyCacheData() then
		controller:requestGuildWarData()
    else
        self:refreshGuildWarPosition()
        self:refreshStarAndBuffInfo()
        self:refreshTopThreeRank()
        self:refreshChallengeCount()
	end
end

-- 状态刷新
function GuildwarMainWindow:refreshGuildWarStatus(  )
	local status = model:getGuildWarStatus()
	local isShowTips = false
	local tips_str = ""
    self.clash_list_btn:setVisible(false)
    local flag = model:getGuildWarEnemyFlag()
    ----------------------->>",status)
	if status == GuildwarConst.status.close then
		isShowTips = true
		tips_str = TI18N("公会战暂未开始，请在每周一、周三、周五12:00-20:00准时参加哦！（ﾟ∀ﾟ）つ")
        -- 所有据点都放入缓存池中
        for i=#self.position_stack, 1, -1 do
            local item = table.remove(self.position_stack, i)
            local pos = item:getPositionPos()
            item:setVisible(false)
            item:suspendAllActions()
            table.insert(self.position_pool, item)
            self.position_pos[pos] = nil
        end
	elseif status == GuildwarConst.status.matching then
		isShowTips = true
		tips_str = TI18N("正在匹配，请耐心等待")
	elseif status == GuildwarConst.status.showing then
		if flag == TRUE then 
			tips_str = TI18N("公会战暂未开始，请在每周一、周三、周五12:00-20:00准时参加哦！（ﾟ∀ﾟ）つ")
		else -- 未匹配到对手
			tips_str = TI18N("很遗憾，您的公会在此次公会战中匹配轮空或活跃人数未达标，请期待下次！(つд∩)")
		end
        self.clash_list_btn:setVisible(true)
        isShowTips = true
	elseif status == GuildwarConst.status.processing then
        if flag == TRUE then
            isShowTips = false
        else -- 未匹配到对手
            tips_str = TI18N("很遗憾，您的公会在此次公会战中匹配轮空或活跃人数未达标，请期待下次！(つд∩)")
            isShowTips = true
            self.clash_list_btn:setVisible(true)
        end
	elseif status == GuildwarConst.status.settlement then
		if flag == TRUE then
            isShowTips = false
        else -- 未匹配到对手
            tips_str = TI18N("很遗憾，您的公会在此次公会战中匹配轮空或活跃人数未达标，请期待下次！(つд∩)")
            isShowTips = true
            self.clash_list_btn:setVisible(true)
        end
	end

	self.guildwar_status = status

	if isShowTips then
		self.state_tips_label:setString(tips_str)
	end

	self.show_panel:setVisible(not isShowTips)
	self.state_panel:setVisible(isShowTips)
	self:refreshSurplusTime()
    self:refreshChallengeCount()
end

-- 加载阵地地图资源(只创建3张，动态调整位置重复使用)
function GuildwarMainWindow:addMapImage(  )
    for i=1,3 do
        local pos_y = (6-i)*1280
        local map_bg = createSprite(PathTool.getPlistImgForDownLoad("bigbg/guildwar", "guildwar_1"),0,pos_y,self.map_layer,cc.p(0, 0), LOADTEXT_TYPE)
        map_bg:setScaleX(self.map_scalex)
        table.insert(self.map_bgs, map_bg)
    end
    self:dynamicAddMapImage()
end

function GuildwarMainWindow:getTopOrBottomMapBgPosY( flag )
    local value
    for k,mapbg in pairs(self.map_bgs) do
        local pos_y = mapbg:getPositionY()
        value = value or pos_y
        if flag == 1 and pos_y > value then
            value = pos_y
        elseif flag == 2 and pos_y < value then
            value = pos_y
        end
    end
    return value
end

-- 动态调整地图位置
function GuildwarMainWindow:dynamicAddMapImage(  )
    local map_pos_y = self.map_layer:getPositionY()
    map_pos_y = math.abs(map_pos_y)
    local offset_y = 200
    for k,mapbg in pairs(self.map_bgs) do
        local bg_pos_y = mapbg:getPositionY()
        if (bg_pos_y+offset_y) < (map_pos_y-1280) then
            mapbg:setPositionY(self:getTopOrBottomMapBgPosY(1)+1280)
        elseif (bg_pos_y-offset_y)>(map_pos_y+1280) then
            mapbg:setPositionY(self:getTopOrBottomMapBgPosY(2)-1280)
        end
    end
end

function GuildwarMainWindow:moveMapLayer( x, y )
	x = self.map_layer:getPositionX() + x
    y = self.map_layer:getPositionY() + y
    local return_pos = self:checkMapLayerPoint(x,y)
    if self.bottom_position_pos_y and return_pos.y <= -(self.bottom_position_pos_y-300) then
        self.map_layer:setPosition(return_pos.x,return_pos.y)
        return true
    else
        return false
    end
end

function GuildwarMainWindow:checkMapLayerPoint( _x, _y )
	local return_pos = cc.p(_x,_y)
    if return_pos.x > self.map_layer_posX then
        return_pos.x = self.map_layer_posX
    elseif return_pos.x < (self.free_size.width-self.map_size.width + self.map_layer_posX) then
        return_pos.x = (self.free_size.width-self.map_size.width + self.map_layer_posX)
    end
    if return_pos.y < (self.free_size.height - self.map_size.height + self.map_layer_posY)  then
        return_pos.y = (self.free_size.height - self.map_size.height + self.map_layer_posY)
    elseif return_pos.y >= self.map_layer_posY  then 
        return_pos.y = self.map_layer_posY
    end
    return return_pos
end

-- 剩余时间显示
function GuildwarMainWindow:refreshSurplusTime(  )
	self.surplusTime = model:getGuildWarSurplusTime()
    if self.surplusTime < 0 then
        self.surplusTime = 0
    end
	self.time_label:setString(TimeTool.GetTimeFormatDayIIIIIIII(self.surplusTime))
	self:openGuildWarSurplusTimer(true)
end

-- 活动剩余时间倒计时
function GuildwarMainWindow:openGuildWarSurplusTimer( status )
	if status == true then
		if self.guildwar_timer == nil then
            self.guildwar_timer = GlobalTimeTicket:getInstance():add(function()
                self.surplusTime = self.surplusTime - 1
                if self.surplusTime >= 0 then
                	self.time_label:setString(TimeTool.GetTimeFormatDayIIIIIIII(self.surplusTime))
                else
                	self.surplusTime = 0
                	GlobalTimeTicket:getInstance():remove(self.guildwar_timer)
            		self.guildwar_timer = nil
                end
            end, 1)
        end
	else
		if self.guildwar_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.guildwar_timer)
            self.guildwar_timer = nil
        end
	end
end

-- 剩余次数刷新
function GuildwarMainWindow:refreshChallengeCount(  )
    if self.guildwar_status == GuildwarConst.status.settlement then
        self.challenge_label:setString(TI18N("后关闭"))
    else
        local count = model:getGuildWarChallengeCount()
        local max_count = Config.GuildWarData.data_const.challange_time_limit.val
        self.challenge_label:setString(string.format(TI18N("挑战次数:%d/%d"), (max_count-count), max_count))
    end
end

-- 刷新双方星数、结果和buff信息
function GuildwarMainWindow:refreshStarAndBuffInfo(  )
	local myGuildData = model:getMyGuildWarBaseInfo()
	self.my_guild_name_label:setString(myGuildData.gname or "")
	self.my_guild_star_label:setString(myGuildData.hp or 0)

    local buff_lev = myGuildData.buff_lev or 0
    local max_level = Config.GuildWarData.data_buff_length
    self.buff_lv_label:setString(string.format(TI18N("%d/%d级"), buff_lev, max_level))

	local enemyGuildData = model:getEnemyGuildWarBaseInfo()
	self.enemy_guild_name_label:setString(enemyGuildData.gname or "")
	self.enemy_guild_star_label:setString(enemyGuildData.hp or 0)

	local result = model:getGuildWarResult()
	self.my_guild_win:setVisible(result == GuildwarConst.result.win)
	self.my_guild_dogfall:setVisible(result == GuildwarConst.result.dogfall)
	self.enemy_guild_win:setVisible(result == GuildwarConst.result.lose)
	self.enemy_guild_dogfall:setVisible(result == GuildwarConst.result.dogfall)
end

-- 刷新前三排名数据
function GuildwarMainWindow:refreshTopThreeRank(  )
    local rank_list = model:getGuildWarTopThreeRank()
    if rank_list == nil or next(rank_list) == nil then return end
    for i, v in ipairs(rank_list) do
        if not self.top3_item_list[v.rank] then
            local item = self:createSingleRankItem(v.rank)
            self.rank_container:addChild(item)
            self.top3_item_list[v.rank] = item
        end
        local item = self.top3_item_list[v.rank]
        if item then
            item:setPosition(-10,150 - (v.rank-1) * item:getContentSize().height)
            item.label:setString(v.name)
        end
    end
end

function GuildwarMainWindow:createSingleRankItem(i)
    local container = ccui.Layout:create()
    container:setAnchorPoint(cc.p(0,1))
    container:setContentSize(cc.size(180,40))
    local sp = createSprite(PathTool.getResFrame("common","common_300"..i),30,40/2,container)
    sp:setScale(0.4)
    container.sp = sp
    local label = createLabel(12,1,nil,60,18,"",container)
    label:setAnchorPoint(cc.p(0,0.5))
    label:setTextColor(cc.c4b(0x89,0xed,0xff,0xff))

    container.label = label
    return container
end

-- 据点
function GuildwarMainWindow:refreshGuildWarPosition(  )
    self.position_vo_data = {}
    -- 开战或结算时才显示据点
    if self.guildwar_status == GuildwarConst.status.processing or self.guildwar_status == GuildwarConst.status.settlement then
        if self.cur_position_type == GuildwarConst.positions.myself then
            self.position_vo_data = model:getMyGuildWarPositionList()
        elseif self.cur_position_type == GuildwarConst.positions.others then
            self.position_vo_data = model:getEnemyGuildWarPositionList()
        end
    end

    self.bottom_position_pos_y = 0
    for k,position_vo in pairs(self.position_vo_data) do
        local pos_data = Config.GuildWarData.data_position[position_vo.pos]
        if self.bottom_position_pos_y == 0 or pos_data.pos_y < self.bottom_position_pos_y then
            self.bottom_position_pos_y = pos_data.pos_y
        end
    end

    self:dynamicShowGuildWarPosition()
end
-- 动态加载据点显示
function GuildwarMainWindow:dynamicShowGuildWarPosition(  )
    self:checkPositionMoveToPool()

    for k,position_vo in pairs(self.position_vo_data) do
        local pos_data = Config.GuildWarData.data_position[position_vo.pos]
        if pos_data and not self.position_pos[position_vo.pos] and self:checkPositionIsInDisplayRect(pos_data.pos_x, pos_data.pos_y) then
            local position_item = table.remove(self.position_pool, 1)
            if position_item == nil then
                position_item = GuildwarPositionItem.new()
                self.map_layer:addChild(position_item, 10)
            end
            position_item:setVisible(true)
            position_item:setData(position_vo, self.cur_position_type)
            position_item:setPosition(cc.p(pos_data.pos_x, pos_data.pos_y))
            table.insert(self.position_stack, position_item)
            self.position_pos[position_vo.pos] = true
        end
    end
end

-- 检测已创建的据点是否需要放入缓存池
function GuildwarMainWindow:checkPositionMoveToPool(  )
    for i=#self.position_stack, 1, -1 do
        local item = self.position_stack[i]
        local pos_x, pos_y = item:getPosition()
        if not self:checkPositionIsInDisplayRect(pos_x, pos_y) then
            local pos = item:getPositionPos()
            item:setVisible(false)
            item:suspendAllActions()
            table.insert(self.position_pool, item)
            table.remove(self.position_stack, i)
            self.position_pos[pos] = nil
        end
    end
end
-- 根据据点位置计算是否在显示区域之内
function GuildwarMainWindow:checkPositionIsInDisplayRect( pos_x, pos_y )
    local isIn = true
    local item_width = GuildwarPositionItem.Width
    local item_height = GuildwarPositionItem.Height
    local map_pos_x, map_pos_y = self.map_layer:getPosition()
    map_pos_x = math.abs(map_pos_x)
    map_pos_y = math.abs(map_pos_y)
    if (pos_x+item_width/2)<map_pos_x or (pos_x-item_width/2)>(map_pos_x+self.free_size.width) or (pos_y+item_height)<map_pos_y or pos_y>(map_pos_y+display.height) then
        isIn = false
    end
    return isIn
end

-- 切换阵地
function GuildwarMainWindow:changeGuildwarPositionType(  )
    self.map_layer:setPosition(cc.p(self.map_layer_posX, (self.free_size.height - self.map_size.height + self.map_layer_posY)))
    for i=1,3 do
        local pos_y = (6-i)*1280
        local map_bg = self.map_bgs[i]
        if map_bg then
            map_bg:setPosition(cc.p(0, pos_y))
        end
    end
    -- 所有据点都放入缓存池中
    for i=#self.position_stack, 1, -1 do
        local item = table.remove(self.position_stack, i)
        local pos = item:getPositionPos()
        item:setVisible(false)
        item:suspendAllActions()
        table.insert(self.position_pool, item)
        self.position_pos[pos] = nil
    end

    if self.cur_position_type == GuildwarConst.positions.myself then
        self.cur_position_type = GuildwarConst.positions.others
        self:refreshGuildWarPosition()
        self.change_scene_btn_label:setString(TI18N("敌方阵地"))
    else
        self.cur_position_type = GuildwarConst.positions.myself
        self.change_scene_btn_label:setString(TI18N("我方阵地"))
        local myPostionData = model:getMyGuildWarPositionList()
        if next(myPostionData) == nil then -- 本地没有我方据点数据，则请求
            controller:requestMyGuildPositionData()
        else
            self:refreshGuildWarPosition()
        end
    end
end

function GuildwarMainWindow:register_event( )
	-- 联盟战状态变化
	if self.guildwar_status_event == nil then
		self.guildwar_status_event = GlobalEvent:getInstance():Bind(GuildwarEvent.UpdateGuildWarStatusEvent, function(status, flag) 
			-- 状态从开战前到开战后，这时请求数据
			if self.guildwar_status <= 3 and status > 3 and flag == TRUE then
				controller:requestGuildWarData()
			end
            if status <= 3 then -- 状态变更为开战前的界面时，关闭只有开战时才能打开的界面
                controller:openAttkLookWindow(false)
                controller:openAttkPositionWindow(false)
                controller:openGuildWarAwardWindow(false)
                controller:openBattleLogWindow(false)
                controller:openDefendLookWindow(false)
                controller:openGuildWarRankView(false)
            end
			self:refreshGuildWarStatus()
		end)
	end
	-- 详细数据
	if self.guildwar_enemy_init_event == nil then
		self.guildwar_enemy_init_event = GlobalEvent:getInstance():Bind(GuildwarEvent.GuildWarEnemyPositionDataInitEvent, function( ) 
			self:refreshChallengeCount()
			self:refreshStarAndBuffInfo()
            self:refreshTopThreeRank()
			self:refreshGuildWarPosition()
		end)
	end
	-- 挑战次数更新
	if self.guildwar_count_event == nil then
		self.guildwar_count_event = GlobalEvent:getInstance():Bind(GuildwarEvent.UpdateGuildwarChallengeCountEvent, function( ) 
			self:refreshChallengeCount()
		end)
	end
    -- 基础数据更新
    if self.guildwar_baseinfo_event == nil then
        self.guildwar_baseinfo_event = GlobalEvent:getInstance():Bind(GuildwarEvent.UpdateGuildWarBaseInfoEvent, function ( )
            self:refreshTopThreeRank()
            self:refreshStarAndBuffInfo()
        end)
    end
    -- 收到我方据点数据
    if self.guildwar_myposition_event == nil then
        self.guildwar_myposition_event = GlobalEvent:getInstance():Bind(GuildwarEvent.GetGuildWarMyPositionDataEvent, function (  )
            self:refreshGuildWarPosition()
        end)
    end
    -- 红点更新
    if self.update_red_status_event == nil then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(GuildwarEvent.UpdateGuildWarRedStatusEvent, function(redtype, status)
            self:updateMainRedStatus(redtype, status)
        end)
    end

	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openMainWindow(false)
		end
	end) 

	self.explain_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            MainuiController:getInstance():openCommonExplainView(true, Config.GuildWarData.data_explain)
		end
	end)

	local function onTouchBegin(touch, event)
        self.last_point = nil
        self.is_move_map_layer = true
        return true
    end

    local function onTouchMoved(touch, event)
        self.last_point = touch:getDelta()
        if self:moveMapLayer(self.last_point.x,self.last_point.y) then
            self:dynamicShowGuildWarPosition()
            self:dynamicAddMapImage()
        end
    end

	local function onTouchEnded(touch, event)
        self.is_move_map_layer = false
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.map_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.map_layer)

    -- 进攻一览
    self.attk_check_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openAttkLookWindow(true)
        end
    end)
    -- 对阵列表
    self.battle_list_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openBattleListWindow(true)
        end
    end)
    --对阵列表（匹配成功展示界面）
    self.clash_list_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openBattleListWindow(true)
            model:updateGuildWarRedStatus(GuildConst.red_index.guildwar_match, false)
        end
    end)
    -- 进攻日志
    self.ally_atk_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openBattleLogWindow(true)
            model:updateGuildWarRedStatus(GuildConst.red_index.guildwar_log, false)
        end
    end)
    -- 战绩奖励
    self.look_award_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openGuildWarAwardWindow(true)
        end
    end)
    -- 详细排名
    self.rank_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openGuildWarRankView(true)
        end
    end)
    -- 切换阵地
    self.change_scene_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:changeGuildwarPositionType()
        end;
    end)
    -- 宝箱按钮
    registerButtonEventListener(self.award_box_btn, function (  )
        controller:openAwardBoxWindow(true)
    end, true)
    -- 宝箱按钮
    registerButtonEventListener(self.look_box_btn, function (  )
        controller:openAwardBoxWindow(true)
    end, true)
end

function GuildwarMainWindow:updateMainRedStatus( redtype, status )
    if redtype == GuildConst.red_index.guildwar_match then
        addRedPointToNodeByStatus(self.clash_list_btn, status, -5, -5)
    elseif redtype == GuildConst.red_index.guildwar_log then
        addRedPointToNodeByStatus(self.ally_atk_btn, status, -5, -5)
    elseif redtype == GuildConst.red_index.guildwar_box then
        addRedPointToNodeByStatus(self.award_box_btn, status, -5, -5)
        addRedPointToNodeByStatus(self.look_box_btn, status, -5, -5)
    else
        local match_btn_status = model:checkRedIsShowByRedType(GuildConst.red_index.guildwar_match)
        addRedPointToNodeByStatus(self.clash_list_btn, match_btn_status, -5, -5)

        local atk_btn_status = model:checkRedIsShowByRedType(GuildConst.red_index.guildwar_log)
        addRedPointToNodeByStatus(self.ally_atk_btn, atk_btn_status, -5, -5)

        local box_btn_status = model:checkRedIsShowByRedType(GuildConst.red_index.guildwar_box)
        addRedPointToNodeByStatus(self.award_box_btn, box_btn_status, -5, -5)
        addRedPointToNodeByStatus(self.look_box_btn, box_btn_status, -5, -5)
    end
end

function GuildwarMainWindow:close_callback()
    self:openGuildWarSurplusTimer(false)

    for k,item in pairs(self.position_stack) do
        item:DeleteMe()
    end

    for k,item in pairs(self.position_pool) do
        item:DeleteMe()
    end

    if self.guildwar_status_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.guildwar_status_event)
		self.guildwar_status_event = nil
	end

	if self.guildwar_enemy_init_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.guildwar_enemy_init_event)
		self.guildwar_enemy_init_event = nil
	end

    if self.guildwar_baseinfo_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.guildwar_baseinfo_event)
        self.guildwar_baseinfo_event = nil
    end

    if self.guildwar_myposition_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.guildwar_myposition_event)
        self.guildwar_myposition_event = nil
    end

    if self.update_red_status_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end

	if self.guildwar_count_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.guildwar_count_event)
		self.guildwar_count_event = nil
	end

    controller:openMainWindow(false)
end