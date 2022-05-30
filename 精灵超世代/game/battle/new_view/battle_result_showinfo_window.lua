-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      通用的战斗伤害,加血和承受数据展示界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

BattleResultShowInfoWindow = BattleResultShowInfoWindow or BaseClass(BaseView)

local controller = BattleController:getInstance()
local table_insert = table.insert 
local role_vo = RoleController:getInstance():getRoleVo()
local unit_func = Config.UnitData.data_unit
local partner_base = Config.PartnerData.data_partner_base

function BattleResultShowInfoWindow:__init(view_type)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.win_type = WinType.Big
	self.layout_name = "battle/battle_result_showinfo"
	self.total_data = {}
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
	}

	self.view_type = view_type or ArenaConst.champion_type.normal
end 

function BattleResultShowInfoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
    local main_panel = main_container:getChildByName("main_panel")
	main_panel:getChildByName("win_title"):setString(TI18N("数据统计"))
	for i=1,3 do
		local desc = main_panel:getChildByName("desc_"..i)
		if desc then
			if i == 1 then
				desc:setString(TI18N("伤害"))
			elseif i == 2 then
				desc:setString(TI18N("承受伤害"))
			else
				desc:setString(TI18N("治疗"))
			end
		end
	end

	self.tab_list = {}
	for i=1,3 do
		local tab = main_container:getChildByName("tab_btn_"..i)
		if tab then
			local unselect_bg = tab:getChildByName("unselect_bg")
			local select_bg = tab:getChildByName("select_bg")
			local title = tab:getChildByName("title")
			unselect_bg:setVisible(true)
			select_bg:setVisible(false)
			self.tab_list[i] = {tab=tab, unselect=unselect_bg, select=select_bg, title=title}
			if i == 1 then
				title:setString(TI18N("队伍一"))
			elseif i == 2 then
				title:setString(TI18N("队伍二"))
			elseif i == 3 then
				title:setString(TI18N("队伍三"))
			end
		end
	end

	self.item = main_panel:getChildByName("item")
	self.item:setVisible(false)

	self.close_btn = main_panel:getChildByName("close_btn")

	self.top_list_view = main_panel:getChildByName("top_list_view")
	self.bottom_list_view = main_panel:getChildByName("bottom_list_view")

	self.top_name = main_panel:getChildByName("top_name")
	self.bottom_name = main_panel:getChildByName("bottom_name")

	self.success_img = main_panel:getChildByName("success_img")
	self.fail_img = main_panel:getChildByName("fail_img")
	self.top_y = 753
	self.bottom_y = 418

	self.report_btn = main_panel:getChildByName("report_btn")
	self.share_btn = main_panel:getChildByName("share_btn")
	self.share_panel = main_container:getChildByName("share_panel")
	self.share_panel:setVisible(false)
    self.share_panel:setSwallowTouches(false)
    self.share_bg = self.share_panel:getChildByName("share_bg")
    self.btn_guild = self.share_bg:getChildByName("btn_guild")
    self.btn_world = self.share_bg:getChildByName("btn_world")
    self.btn_cross = self.share_bg:getChildByName("btn_cross")
    self.btn_guild:getChildByName("label"):setString(TI18N("分享到公会频道"))
    self.btn_world:getChildByName("label"):setString(TI18N("分享到世界频道"))
    self.btn_cross:getChildByName("label"):setString(TI18N("分享到跨服频道"))

	-- 有需要
	self.baseZOrder = main_panel:getLocalZOrder()
end

function BattleResultShowInfoWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			self:onCloseBtn()
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			self:onCloseBtn()
		end
	end)
	self.report_btn:addTouchEventListener(function(sender, event_type)
		--customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound()
			self:onClickReportBtn()
		end
	end)
	self.share_btn:addTouchEventListener(function(sender, event_type)
		--customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound()
			self.share_panel:setVisible(true)
		end
	end)

	-- 分享到公会
    registerButtonEventListener(self.btn_guild, function (  )
        if RoleController:getInstance():getRoleVo():isHasGuild() == false then
            message(TI18N("您暂未加入公会"))
            return
		end
		self:onClickShareBtnByType(ChatConst.Channel.Gang)
    end, false, 1)
    -- 分享到世界
	registerButtonEventListener(self.btn_world, function (  )
		self:onClickShareBtnByType(ChatConst.Channel.World)
    end, false, 1)
    -- 分享到跨服
    registerButtonEventListener(self.btn_cross, function (  )
        local cross_config = Config.MiscData.data_const["cross_level"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo.lev < cross_config.val then
            message(string.format(TI18N("%d级开启跨服频道"), cross_config.val))
            return
		end
		self:onClickShareBtnByType(ChatConst.Channel.Cross)
    end, false, 1)
	-- 点击关闭分享界面
    self.share_panel:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            self.share_panel:setVisible(false)
        end
    end)

	for i,v in ipairs(self.tab_list) do
		local tab_object = self.tab_list[i]
		tab_object.tab:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playTabButtonSound()
				self:changeTabIndex(i)
			end
		end)
	end
end

function BattleResultShowInfoWindow:onCloseBtn()
	if self.fight_type == BattleConst.Fight_Type.PlanesWar then
		local guild_controller = GuildbossController:getInstance()
		if guild_controller and guild_controller.hideGuildbossResultWindow then
			guild_controller:hideGuildbossResultWindow(true)	
		end
	end
	controller:openBattleResultShowInfoWindow(false)
end

-- 点击回放战斗
function BattleResultShowInfoWindow:onClickReportBtn( )
	local role_vo = RoleController:getInstance():getRoleVo()
	if self.replay_id and role_vo then
		-- 先关闭战斗结算界面
		if self.fight_type == BattleConst.Fight_Type.Arena then
			ArenaController:getInstance():openLoopResultWindow(false)
		elseif self.fight_type == BattleConst.Fight_Type.LadderWar then
			LadderController:getInstance():openLadderBattleResultWindow(false)
		elseif self.fight_type == BattleConst.Fight_Type.EliteMatchWar or self.fight_type == BattleConst.Fight_Type.EliteKingMatchWar then
			ElitematchController:getInstance():openElitematchFightResultPanel(false)
		elseif self.fight_type == BattleConst.Fight_Type.StarTower then
			StartowerController:getInstance():openResultWindow(false)
		elseif self.fight_type == BattleConst.Fight_Type.PlanesWar then
			local guild_controller = GuildbossController:getInstance()
			if guild_controller and guild_controller.hideGuildbossResultWindow then
				guild_controller:hideGuildbossResultWindow(false)	
			end
		end
		if self.success == 1 then
			BattleController:getInstance():openFinishView(false,self.fight_type)
		else
			BattleController:getInstance():openFailFinishView(false,self.fight_type)
		end
		
		BattleController:getInstance():csRecordBattle(self.replay_id, role_vo.srv_id)
	end
end

-- 点击分享录像
function BattleResultShowInfoWindow:onClickShareBtnByType( cross_type )
	if self.replay_id and self.fight_type then
		local share_type = BattleConst.getShareTypeByBattleType( self.fight_type )
		BattleController:getInstance():on20034(self.replay_id, cross_type, self.target_name or "", share_type)
		self.share_panel:setVisible(false)
	end
end

--[[
    @desc: 切换多队伍标签页的
    author:{author}
    time:2020-02-10 11:21:43
    --@index: 
    @return:
]]
function BattleResultShowInfoWindow:changeTabIndex(index)
	if self.select_index == index then return end
	self.select_index = index

	if self.select_tab then
		self.select_tab.tab:setLocalZOrder(self.baseZOrder - 99)
		self.select_tab.select:setVisible(false)
		self.select_tab.unselect:setVisible(true)
	end
	self.select_tab = self.tab_list[index]
	self.select_tab.tab:setLocalZOrder(self.baseZOrder + 99)
	self.select_tab.select:setVisible(true)
	self.select_tab.unselect:setVisible(false)

	local data =  self.total_data[index]
	if data then
		self:setData(data)
	end
end
--setting 
--setting.fight_type 战斗类型 默认nil 
function BattleResultShowInfoWindow:openRootWnd(data, setting)
	if data == nil then return end
	local setting = setting or {}
	self.fight_type = setting.fight_type or data.combat_type
	if data.hurt_statistics == nil and next(data) ~= nil then   -- 多队伍
		self.total_data = data
		local sum = math.min(#data, 3)
		for i=1,sum do
			local tab_object = self.tab_list[i]
			tab_object.tab:setVisible(true)
		end
		self:changeTabIndex(1)
	else
		self:setData(data)
	end
	-- 暂时以下战斗显示分享与回放按钮
	if self.fight_type and self.fight_type == BattleConst.Fight_Type.Arena 
		or self.fight_type == BattleConst.Fight_Type.PK
		or self.fight_type == BattleConst.Fight_Type.GuildWar
		or self.fight_type == BattleConst.Fight_Type.LadderWar
		or self.fight_type == BattleConst.Fight_Type.EliteMatchWar
		or self.fight_type == BattleConst.Fight_Type.EliteKingMatchWar 
		or self.fight_type == BattleConst.Fight_Type.StarTower 
		or self.fight_type == BattleConst.Fight_Type.AreanManyPeople --多人竞技场
		or self.fight_type == BattleConst.Fight_Type.PlanesWar then --位面
		self.report_btn:setVisible(true)
		self.share_btn:setVisible(true)
	end
end

function BattleResultShowInfoWindow:setData(data)
	self.top_plist = {}
	self.bot_plist = {}
	self.success = data.result or 0    -- 胜利或者失败
	self.atk_name = data.atk_name or role_vo.name or "" -- 进攻名字
	self.target_name = data.target_role_name or data.def_name or "" -- 对方名字
	self.replay_id = data.replay_id or data.vedio_id -- 录像id
	
	for k,v in pairs(data.hurt_statistics or {}) do
		if v.type == 1 or v.type == 0 then  -- == 0的时候是手按太快,还没出招就gm结束了
			self.top_plist = v.partner_hurts
		elseif v.type == 2 then
			self.bot_plist = v.partner_hurts
		end
	end
	self:setBaseInfo()

	local bast_hurt = 0		-- 最高输出
	local bast_behurt = 0	-- 最高承伤
	local bast_cure = 0		-- 最高治疗
	for i,v in ipairs(self.top_plist) do
		v.dps = v.dps or 0
		v.be_hurt = v.be_hurt or 0
		v.cure = v.cure or 0
		if bast_hurt < v.dps then
			bast_hurt = v.dps
		end
		if bast_behurt < v.be_hurt then
			bast_behurt = v.be_hurt
		end
		if bast_cure < v.cure then
			bast_cure = v.cure
		end
	end
	for i,v in ipairs(self.bot_plist) do
		v.dps = v.dps or 0
		v.be_hurt = v.be_hurt or 0
		v.cure = v.cure or 0
		if bast_hurt < v.dps then
			bast_hurt = v.dps
		end
		if bast_behurt < v.be_hurt then
			bast_behurt = v.be_hurt
		end
		if bast_cure < v.cure then
			bast_cure = v.cure
		end
	end
	self:setTopInfo(bast_hurt, bast_behurt, bast_cure)
	self:setBottomInfo(bast_hurt, bast_behurt, bast_cure)
end

function BattleResultShowInfoWindow:setBaseInfo()
	self.success_img:setVisible(self.success ~= 0)
	self.fail_img:setVisible(self.success ~= 0)
	if self.success == 1 then
		self.success_img:setPositionY(self.top_y)
		self.fail_img:setPositionY(self.bottom_y)
	elseif self.success == 2 then
		self.success_img:setPositionY(self.bottom_y)
		self.fail_img:setPositionY(self.top_y)
	end
	self.top_name:setString(self.atk_name)
	self.bottom_name:setString(self.target_name)
end

function BattleResultShowInfoWindow:setTopInfo(bast_hurt, bast_behurt, bast_cure)
	local mvp_bid = 0
	local tmp_hurt = 0
	for i,v in ipairs(self.top_plist) do
		if tmp_hurt < v.dps then
			tmp_hurt = v.dps
			mvp_bid = v.bid
		end
	end
	if self.top_scroll_view == nil then
		local size = self.top_list_view:getContentSize()
		local setting = {
			item_class = BattleResultReportItem,
			start_x = 0,
			space_x = 0,
			start_y = 30,
			space_y = 0,
			item_width = 122,
			item_height = 278,
			row = 1,
			col = 1,
		}
		self.top_scroll_view = CommonScrollViewLayout.new(self.top_list_view, nil, ScrollViewDir.horizontal, ScrollViewStartPos.bottom, size, setting)
	end
	self.top_scroll_view:setVisible(true)
	self.top_scroll_view:setData(self.top_plist, nil, nil, {total_hurt = bast_hurt, total_behurt = bast_behurt, total_cure = bast_cure, _mvp_bid = mvp_bid, node = self.item, fight_type = self.fight_type, is_top_team = true}) 
end

function BattleResultShowInfoWindow:setBottomInfo(bast_hurt, bast_behurt, bast_cure)
	local mvp_bid = 0
	local tmp_hurt = 0
	for i,v in ipairs(self.bot_plist) do
		if tmp_hurt < v.dps then
			tmp_hurt = v.dps
			mvp_bid = v.bid
		end
	end
	if self.bottom_scroll_view == nil then
		local size = self.bottom_list_view:getContentSize()
		local setting = {
			item_class = BattleResultReportItem,
			start_x = 0,
			space_x = 0,
			start_y = 30,
			space_y = 0,
			item_width = 122,
			item_height = 278,
			row = 1,
			col = 1,
		}
		self.bottom_scroll_view = CommonScrollViewLayout.new(self.bottom_list_view, nil, ScrollViewDir.horizontal, ScrollViewStartPos.bottom, size, setting)
	end
	self.bottom_scroll_view:setVisible(true)
	self.bottom_scroll_view:setData(self.bot_plist, nil, nil, {total_hurt = bast_hurt, total_behurt = bast_behurt, total_cure = bast_cure, _mvp_bid = mvp_bid, node = self.item, fight_type = self.fight_type}) 
end

function BattleResultShowInfoWindow:close_callback()
	if self.top_scroll_view then
		self.top_scroll_view:DeleteMe()
	end
	self.top_scroll_view = nil
	if self.bottom_scroll_view then
		self.bottom_scroll_view:DeleteMe()
	end
	self.bottom_scroll_view = nil
    controller:openBattleResultShowInfoWindow(false)
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛当前排行榜的分列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BattleResultReportItem = class("BattleResultReportItem", function()
	return ccui.Layout:create()
end)

function BattleResultReportItem:ctor()
	self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function BattleResultReportItem:setExtendData(data)
	self.total_hurt = data.total_hurt
	self.total_behurt = data.total_behurt
	self.total_cure = data.total_cure
	self.mvp_bid = data._mvp_bid
	self.fight_type = data.fight_type
	self.is_top_team = data.is_top_team -- 是否是 top_scroll_view 的队伍 

	local node = data.node	
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

		for i=1,3 do
			self["progress_"..i] = self.root_wnd:getChildByName("progress_"..i)	-- 进度条
			--if self["progress_"..i] then
			--	self["progress_"..i]:setScale9Enabled(true)
			--end
			self["desc_"..i] = self.root_wnd:getChildByName("desc_"..i)			-- 描述
		end

		self.mvp = self.root_wnd:getChildByName("mvp")

		self.partner_item = HeroExhibitionItem.new(0.8, true) 
		self.partner_item:addCallBack(handler(self, self._onClickHeroCallBack))
		self.partner_item:setPosition(61, 178)
		self.root_wnd:addChild(self.partner_item)
	end
end

function BattleResultReportItem:_onClickHeroCallBack(  )
	if self.data and self.data.rid and self.data.rid ~= 0 and self.data.srvid and self.data.srvid ~= "" and self.data.id and self.data.id ~= 0 then
		local role_vo = RoleController:getInstance():getRoleVo()
		if role_vo.rid == self.data.rid and role_vo.srv_id == self.data.srvid then
			local hero_vo = HeroController:getInstance():getModel():getHeroById(self.data.id)
			if hero_vo then
				HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
			else
				message(TI18N("伙伴不存在"))
			end
		else
			LookController:getInstance():sender11061(self.data.rid, self.data.srvid, self.data.id)
		end
	else
		message(TI18N("该宝可梦来自异域，无法查看"))
	end
end

function BattleResultReportItem:setData(data)
	if data and data.bid then
		self.data = data
		if self.mvp_bid and self.mvp_bid == data.bid then
			self.mvp:setVisible(true)
		else
			self.mvp:setVisible(false)
		end

		if data.star == 0 or data.star == nil then
			local unit_config = unit_func(data.bid)
			if unit_config then
				data.bid = tonumber(unit_config.head_icon)
				data.master_head_id = data.bid
				if unit_config.star and unit_config.star > 0 then
					data.star = unit_config.star
				else
					local base_config = partner_base[data.bid]
					if base_config then
						data.star = base_config.init_star
					end
				end
			end
		end
		self.partner_item:setData(data, true)
		if self.fight_type == BattleConst.Fight_Type.PlanesWar then
			--位面需要显示租借宝可梦
			--后端说 位面的租借宝可梦是 判断 srvid == ""
			if self.is_top_team then
				if self.data.srvid == "" then
					self.partner_item:showHelpImg(true)
				else
					self.partner_item:showHelpImg(false)
				end
			end

		end
		-- showHelpImg
		self.desc_1:setString(changeBtValueForBattle(data.dps))
		self.desc_2:setString(changeBtValueForBattle(data.be_hurt))
        self.desc_3:setString(changeBtValueForBattle(data.cure))
		if self.total_hurt == 0 then
			self.progress_1:setPercent(0)
		else
			self.progress_1:setPercent(100*data.dps/self.total_hurt) 
		end
		if self.total_behurt == 0 then
			self.progress_2:setPercent(0)
		else
			self.progress_2:setPercent(100*data.be_hurt/self.total_behurt) 
		end
		if self.total_cure == 0 then
			self.progress_3:setPercent(0)
		else
			self.progress_3:setPercent(100*data.cure/self.total_cure) 
		end
	end
end

function BattleResultReportItem:DeleteMe()
	if self.partner_item then
		self.partner_item:DeleteMe()
		self.partner_item = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end 