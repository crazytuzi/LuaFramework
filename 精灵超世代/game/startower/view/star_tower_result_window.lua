-- --------------------------------------------------------------------
-- 星命塔的胜利战斗结算
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

StarTowerResultWindow = StarTowerResultWindow or BaseClass(BaseView)


function StarTowerResultWindow:__init(result, fight_type)
	self.result = result
	self.x = 100
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.fight_type = fight_type
	self.is_running = true
	self.partner_list = {}
	self.item_list = {}
	self.dungeon_data = data
	self.cur_round = round
	self.total_round = total_round
	self.is_stop = false
	self.is_open_box = false
	self.win_type = WinType.Tips
	self.layout_name = "battle/battle_result_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.effect_list = {}
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}
	self.star = 0
end

function StarTowerResultWindow:openRootWnd(data,fight_type,battle_extend_data)
	self:setData(data, fight_type, battle_extend_data)
end

--初始化
function StarTowerResultWindow:open_callback()
	local res = ""
	playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 

	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.source_container = self.root_wnd:getChildByName("container")
	self.Sprite_1 = self.source_container:getChildByName("Sprite_1")
	if self.sprite_1_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end
    
    self.Sprite_2 = self.source_container:getChildByName("Sprite_2")
    if self.sprite_2_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end
	self.title_container = self.source_container:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height
	self:handleEffect(true)

	self.time_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5,420), nil, nil, 1000)
	self.time_label:setString(TI18N("10秒后关闭"))
	self.root_wnd:addChild(self.time_label)

	self.harm_btn = self.source_container:getChildByName("harm_btn")
	self.harm_btn:setVisible(false)
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

	self.fight_text = createLabel(24, Config.ColorData.data_new_color4[6], nil, 360, 455, "",self.source_container, nil, cc.p(0.5,0.5))

	local result_get_bg = createSprite(PathTool.getResFrame("common", "common_2050"), 360,415, self.source_container, cc.p(0.5, 0.5))
	result_get_bg:setScaleX(5)
	result_get_bg:setScaleY(3)
	self.pass_time = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(360, 415), nil, nil, 1000)
	self.pass_time:setString(TI18N("通关时间：00:00:00"))
	self.source_container:addChild(self.pass_time) 

	self.gain_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(360, 100), nil, nil, 1000)
	self.source_container :addChild(self.gain_label)

	local label  = createRichLabel(22,Config.ColorData.data_new_color4[16], cc.p(0.5, 0.5), cc.p(360,368), nil, nil, 1000)
	label:setString(TI18N("获得物品"))
	self.source_container:addChild(label)
	-- local result_line_bg = createSprite(PathTool.getResFrame("common", "common_1094"), 320, 368, self.source_container, cc.p(0, 0.5))
	-- result_line_bg:setScaleX(-1)
	-- local result_line_bg_2 = createSprite(PathTool.getResFrame("common", "common_1094"), 400,368, self.source_container, cc.p(0, 0.5))

	self.scroll_view = createScrollView(SCREEN_WIDTH, 230, 0, 130, self.source_container, ccui.ScrollViewDir.vertical) 

	self.comfirm_btn = createButton(self.root_wnd,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
	self.comfirm_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,%s>确定</div>"), Config.ColorData.data_new_color_str[3]))
	self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 - 170, 470)
	-- self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
	self.comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			StartowerController:getInstance():openResultWindow(false)
		end
	end)

	self.cancel_btn = createButton(self.root_wnd,TI18N("挑战下一层"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
	self.cancel_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,%s>挑战下一层</div>"), Config.ColorData.data_new_color_str[2]))
	self.cancel_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 170, 470)
	-- self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
	self.cancel_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            --BattleResultReturnMgr:returnByFightType(self.fight_type) --先
            if not self.data then return end
            local tower = self.data.tower or 0
            StartowerController:getInstance():openResultWindow(false)   -- 胜利之后可以直接进入下一层继续挑战
            if self.isCanNext  then
	            StartowerController:getInstance():sender11322(tower + 1)
	            if self.data.count > 0 and  tower < Config.StarTowerData.data_tower_base_length then
	            	message(TI18N("已进入下一层战斗"))   
	            end
	        else
	        	BattleResultReturnMgr:returnByFightType(self.fight_type) --先
	        end
		end
	end)
end

function StarTowerResultWindow:register_event()
	registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function StarTowerResultWindow:_onClickHarmBtn(  )
	if self.data and next(self.data) ~= nil then
		local setting = {}
        setting.fight_type = self.fight_type
		BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
	end
end

--剧情：{章节id,难度，副本id}
function StarTowerResultWindow:setData(data, fight_type, dungeon_data)
	if data then
		self.data = data or {}
		self.dungeon_data = dungeon_data
        self.fight_type = fight_type
        local pass_time = data.timer or 0
		local item_list ={}
		local asset_list = {}
		local first_award = self.data.first_award or {}

		

		for i, v in ipairs(first_award) do
			v.is_first = true
			table.insert(item_list,v)
		end
		for i, v in ipairs(self.data.award) do
			v.is_first = false
			table.insert(item_list,v)
		end
		local str = ""
		if asset_list and next(asset_list or {}) ~= nil then
			for i, v in pairs(asset_list) do
				if Config.ItemData.data_get_data(v.item_id) then
					local icon = Config.ItemData.data_get_data(v.item_id).icon
					local str_ = string.format("<div><img src='%s' scale=0.4 /></div><div fontcolor=#ffffff fontsize=24>+%s            </div>", PathTool.getItemRes(icon), v.num)
					str = str .. str_
				end
			end
		end
		if self.gain_label and not tolua.isnull(self.gain_label) then
			self.gain_label:setString(str)
		end
		self.reward_list = item_list
		self.result = self.data.result
		self.is_guide = self.data.is_guide
		
		if data.is_skip and data.is_skip == 1 then
			self.pass_time:setString(TI18N("冒险者的实力过于强大~敌人落荒而逃~"))
			self.harm_btn:setVisible(false)
		else
			self.pass_time:setString(string.format( TI18N("通关时间：%s"),TimeTool.GetTimeFormat(pass_time)))
			self.harm_btn:setVisible(true)
		end
        
		--self.source_container:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,150),cc.CallFunc:create(function ()
			self:rewardViewUI()
		--end)))
		if self.fight_text then
			local name = Config.BattleBgData.data_fight_name[self.fight_type]
			if name then
	    		self.fight_text:setString(TI18N("当前战斗：")..name)
	    	end
		end
		
		-- local back_limit_lv = Config.BattleBgData.data_back_limit[self.fight_type] or 0
		-- if self.role_vo.lev >= back_limit_lv then
			self.cancel_btn:setVisible(true)
			self.comfirm_btn:setPositionX(self.root_wnd:getContentSize().width / 2 - 170)
			if self.data.tower then
				self.isCanNext = false
				local config  = Config.StarTowerData.data_tower_const.quick_challenge 
				if config then 
					if self.data.tower < config.val - 1 then
						self.isCanNext = false
						--self.cancel_btn:setBtnLabel(TI18N("返回玩法"))
						self.cancel_btn:setVisible(false)
						self.comfirm_btn:setPositionX(self.root_wnd:getContentSize().width/2)
					else
						self.isCanNext = true
						self.cancel_btn:setRichText(string.format(TI18N("<div fontColor=#ffffff fontsize=22 shadow=0,-2,2,%s>挑战下一层</div>"), Config.ColorData.data_new_color_str[2]))
						-- self.cancel_btn:setBtnLabel(TI18N("挑战下一层"))
					end
				end
			end
		-- else
		-- 	self.cancel_btn:setVisible(false)
		-- 	self.comfirm_btn:setPositionX(self.root_wnd:getContentSize().width/2)
		-- end	
	end
end

function StarTowerResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[103], cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end


--奖励界面
function StarTowerResultWindow:rewardViewUI()
	local sum = #self.reward_list
	local col =4
	-- 算出最多多少行
	self.row = math.ceil(sum / col)
	self.space = 30
	local max_height = self.space + (self.space + BackPackItem.Height) * self.row
	self.max_height = math.max(max_height, self.scroll_view:getContentSize().height)
	self.scroll_view:setInnerContainerSize(cc.size(self.scroll_view:getContentSize().width, self.max_height))

	if sum >= col then
		sum = col
	end
	local total_width = sum * BackPackItem.Width + (sum - 1) * self.space
	self.start_x = (self.scroll_view:getContentSize().width - total_width) * 0.5

	-- 只有一行的话
	if self.row == 1 then
		self.start_y = self.max_height * 0.5 + 30
	else
		self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5 + 30
	end
	for i, v in ipairs(self.reward_list) do
		local item = BackPackItem.new(true,true)
		item:setScale(1.3)
		item:setBaseData(v.item_id,v.num)
		if v.is_first  and v.is_first ==true then 
			item:showBiaoQian(true,TI18N("首通"))
		end
		local name  = Config.ItemData.data_get_data(v.item_id).name
		-- item:setGoodsName(name,nil,nil,175)
		local item_size = item:getContentSize()
		item:setGoodsName(name,cc.p(item_size.width/2,0),nil,nil,nil,nil,cc.p(0.5,1),cc.size(item_size.width+20, 78))
		local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
		local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space)
		item:setPosition(cc.p(_x, _y))
		self.scroll_view:addChild(item)
		self.item_list[i] = item
	end
	self:ItemAciton()
end

function StarTowerResultWindow:ItemAciton()
	if self.item_list and next(self.item_list or {}) ~= nil then
		local show_num = 0
		for i,v in pairs(self.item_list) do
			if v then
				delayRun(self.root_wnd,0.1 * (i - 1),function()
					v:setVisible(true)
					v:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function ()
							show_num = show_num + 1 
							if show_num >= tableLen(self.item_list) then
								self:updateTimer()
							end
					end)))
				end)
			end
		end
	else
		self:updateTimer()
	end
end

function StarTowerResultWindow:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
		local str = string.format(TI18N("%s秒后关闭"), new_time)
		if self.time_label and not tolua.isnull(self.time_label) then
			self.time_label:setString(str)
		end
        if new_time <= 0 then
            StartowerController:getInstance():openResultWindow(false)
            GlobalTimeTicket:getInstance():remove("close_result_reward")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "close_result_reward")
end

--清理
function StarTowerResultWindow:close_callback()
	if self.partner_list then
		for i,v in ipairs(self.partner_list) do
			if v then
				v:DeleteMe()
			end
		end
	end
	self.partner_list = {}
	self.partner_list = nil
	self:handleEffect(false)

	if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
	end
	if not MainuiController:getInstance():checkIsInDramaUIFight() then
		AudioManager:getInstance():playLastMusic()
	end
	if BattleController:getInstance():getModel():getBattleScene() then
		local data = {result = self.result ,combat_type = BattleConst.Fight_Type.StarTower}
		BattleController:getInstance():getModel():result(data)
	end

	GlobalTimeTicket:getInstance():remove("close_result_reward")
	StartowerController:getInstance():openResultWindow(false)
end
