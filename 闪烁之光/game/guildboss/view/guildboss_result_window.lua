-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会副本挑战结算面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildbossResultWindow = GuildbossResultWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format

function GuildbossResultWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.is_full_screen = false
    self.effect_cache_list = {}
	self.layout_name = "guildboss/guildboss_result_window"
	self.is_csb_action = true
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist}
	}
	self.fight_type = BattleConst.Fight_Type.GuildDun
end

function GuildbossResultWindow:open_callback()
	playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 
	
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	local container = self.root_wnd:getChildByName("container")
	self.container = container

	self.title_container = self.root_wnd:getChildByName("title_container") 
	self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 400, "", container, nil, cc.p(0.5,0.5))
    
    -- self.comfirm_btn = createButton(container,TI18N("确 定"), 620, 500, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    -- self.comfirm_btn:setPosition(container:getContentSize().width / 2 - 170, 76)
    -- self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    -- self.comfirm_btn:addTouchEventListener(function(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         self:onCloseBtn()
    --     end
    -- end)

    -- self.cancel_btn = createButton(container,TI18N("返 回"), 620, 500, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    -- self.cancel_btn:setPosition(container:getContentSize().width / 2 + 170, 76)
    -- self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    -- self.cancel_btn:addTouchEventListener(function(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         BattleResultReturnMgr:returnByFightType(self.fight_type) --先
    --         self:onCloseBtn()
    --     end
    -- end)

	self.dps_list_btn = container:getChildByName("dps_list_btn")		-- 查看伤害排名的
	self.harm_btn = container:getChildByName("harm_btn")
	self.harm_btn:setVisible(false)
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))
	self.best_title_sp = container:getChildByName("Sprite_7")
	self.best_title_sp:setAnchorPoint(cc.p(0.5, 0.5))

	self.partner_item = HeroExhibitionItem.new(1, false)
	self.partner_item:setPosition(165, 223)
	container:addChild(self.partner_item)
	self.dps_value = container:getChildByName("dps_value")
	self.container = container
end

function GuildbossResultWindow:onCloseBtn()
	controller:openGuildbossResultWindow(false)
	if self.fight_type == BattleConst.Fight_Type.SandybeachBossFight then
		GlobalEvent:getInstance():Fire(ActionEvent.Aandybeach_Boss_Fight_Result_Close)
	end
end

function GuildbossResultWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			self:onCloseBtn()
		end
	end) 
	self.dps_list_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:openGuildbossResultDpsRankWindow(true, self.data)
		end
	end) 
	registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function GuildbossResultWindow:_onClickHarmBtn(  )
	if self.data and next(self.data) ~= nil then
		BattleController:getInstance():openBattleHarmInfoView(true, self.data, {fight_type = self.fight_type})
	end
end

function GuildbossResultWindow:openRootWnd(data, fight_type)
	self.fight_type = fight_type or BattleConst.Fight_Type.GuildDun
    self:handleEffect(true)
	if data ~= nil then
		self.data = data
		self.dps_value:setString(string.format(TI18N("总伤害：%s"), data.all_dps))
		local hero_vo
		if data.best_partner ~= 0 then
			hero_vo = HeroController:getInstance():getModel():getHeroById(data.best_partner)
		end
		if hero_vo then
			self.partner_item:setData(hero_vo)
		end
		if self.fight_type == BattleConst.Fight_Type.GuildDun or self.fight_type == BattleConst.Fight_Type.MonopolyBoss then --公会副本的、奇境boss
			self:createRewardsList(data.award_list)
		elseif self.fight_type == BattleConst.Fight_Type.SandybeachBossFight then --沙滩保卫战
			self:createSandybeachBossFighRewardsList(data)
		elseif self.fight_type == BattleConst.Fight_Type.PlanesWar then --位面
			self.partner_item:setVisible(false)
			self.dps_list_btn:setVisible(false)
			self.best_title_sp:setVisible(false)
			self:createPlanesAwardList(data.award_list)
		end
		self.harm_btn:setVisible(true)

		if self.fight_text then
			local name = Config.BattleBgData.data_fight_name[self.fight_type]
			if name then
	    		self.fight_text:setString(TI18N("当前战斗：")..name)
	    	end
		end
	end
end

--==============================--
--desc:创建奖励
--time:2018-06-14 10:22:01
--@award_list:
--@return 
--==============================--
function GuildbossResultWindow:createRewardsList(award_list)
	if award_list == nil then return end
	local rich_label = nil
	local _y = 0
	local item_config = nil
	local index = 1
	local item_name = ""
	for i, v in ipairs(award_list) do
		item_config = Config.ItemData.data_get_data(v.bid)
		if item_config then
			_y = 251 - (index - 1) * 50
			rich_label = createRichLabel(24, 190, cc.p(0, 0.5), cc.p(266, _y), nil, nil, 500)
			self.container:addChild(rich_label)
			if item_config.id == Config.ItemData.data_assets_label2id.guild then
				item_name = TI18N("贡献")
			else
				item_name = item_config.name
			end
			rich_label:setString(string.format("%s%s：<img src=%s visible=true scale=0.4 /> +%s", TI18N("获得"), item_name, PathTool.getItemRes(item_config.icon), v.num))
			index = index + 1
		end
	end 
end
--==============================--
--desc:创建奖励
--time:2018-06-14 10:22:01
--@award_list:
--@return 
--==============================--
function GuildbossResultWindow:createSandybeachBossFighRewardsList(data)
	local award_list = {
		[1] = {name = TI18N("伤害积分:"), score = data.dps_score},
		[2] = {name = TI18N("战胜积分:"), score = data.kill_score},
	}
	for i, v in ipairs(award_list) do
		local item_config
		if self.fight_type == BattleConst.Fight_Type.SandybeachBossFight then
			item_config = Config.ItemData.data_get_data(80228)
		else
			item_config = Config.ItemData.data_get_data(1)
		end
		if item_config then
			local _y = 266 - (i - 1) * 50
			local rich_label = createRichLabel(24, 190, cc.p(0, 0.5), cc.p(266, _y), nil, nil, 500)
			self.container:addChild(rich_label)
			rich_label:setString(string.format("%s <img src=%s visible=true scale=0.4 /> +%s", v.name, PathTool.getItemRes(item_config.icon), v.score))
		end
	end 
end

-- 创建位面的奖励(物品icon形式)
function GuildbossResultWindow:createPlanesAwardList( award_list )
	if not award_list or next(award_list) == nil then return end

	if not self.award_scroll_view then
		self.award_scroll_view = createScrollView(SCREEN_WIDTH,210,0,64,self.container,ccui.ScrollViewDir.vertical)
	end

	local sum = #award_list
	local col =4
	-- 算出最多多少行
	local row = math.ceil(sum / col)
	local space = 30
	local max_height = space + (space + BackPackItem.Height) * row
	max_height = math.max(max_height, self.award_scroll_view:getContentSize().height)
	self.award_scroll_view:setInnerContainerSize(cc.size(self.award_scroll_view:getContentSize().width, max_height))

	if sum >= col then
		sum = col
	end
	local total_width = sum * BackPackItem.Width + (sum - 1) * space
	local start_x = (self.award_scroll_view:getContentSize().width - total_width) * 0.5

	-- 只有一行的话
	local start_y = 0
	if row == 1 then
		start_y = max_height * 0.5
	else
		start_y = max_height - space - BackPackItem.Height * 0.5
	end
	self.item_list = self.item_list or {}
	for i, v in ipairs(award_list) do
		if v.bid and v.num then
			local item = BackPackItem.new(true,true)
			item:setBaseData(v.bid,v.num)
			local item_config = Config.ItemData.data_get_data(v.bid)
			if item_config then
				item:setGoodsName(item_config.name,nil,nil,1)
			end
			if v.bid == 25 and PlanesafkController:getInstance():getModel():isHolidayOpen() then
				item:holidHeroExpeditTag(true, TI18N("限时提升"))
			end
			local _x = start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + space)
			local _y = start_y - math.floor((i - 1) / col) * (BackPackItem.Height + space)
			item:setPosition(cc.p(_x, _y + 20))
			item:setDefaultTip()
			self.award_scroll_view:addChild(item)
			self.item_list[i] = item
		end
	end
end

function GuildbossResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function GuildbossResultWindow:close_callback()
    self.container:stopAllActions()
	if self.partner_item then
		self.partner_item:DeleteMe()
		self.partner_item = nil
	end
	self:handleEffect(false)
	if self.item_list then
		for i,v in ipairs(self.item_list) do
			if v then
				v:DeleteMe()
			end
		end
	end
	-- 位面结算后可能要主动触发格子事件
	if self.fight_type == BattleConst.Fight_Type.PlanesWar and self.data then
		PlanesafkController:getInstance():initiativeTriggerEvtByIndex(self.data.line, self.data.index)
	end
	controller:openGuildbossResultWindow(false)
end 