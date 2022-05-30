-- --------------------------------------------------------------------
-- 新手练武场的结算界面
-- 
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-4-10
-- --------------------------------------------------------------------

PractiseTowerResultWindow = PractiseTowerResultWindow or BaseClass(BaseView)


function PractiseTowerResultWindow:__init(result, fight_type)
	self.result = result
	self.x = 100
	
	self.fight_type = fight_type
	
	self.item_list = {}
	self.dungeon_data = data
	
	self.win_type = WinType.Tips
	self.layout_name = "battle/battle_result_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}
	
end

function PractiseTowerResultWindow:openRootWnd(data,fight_type,battle_extend_data)
	self:setData(data, fight_type, battle_extend_data)
end

--初始化
function PractiseTowerResultWindow:open_callback()
	local res = ""
	if self.result == 0 then
		playOtherSound("b_lose", AudioManager.AUDIO_TYPE.BATTLE) 
	else
		playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 
	end
	

	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.source_container = self.root_wnd:getChildByName("container")
	self.Sprite_1 = self.source_container:getChildByName("Sprite_1")
	if self.sprite_1_load == nil and self.result == 1 then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end
    
    self.Sprite_2 = self.source_container:getChildByName("Sprite_2")
    if self.sprite_2_load == nil and self.result == 1 then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end
	self.title_container = self.source_container:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height
	self:handleEffect(true)

	self.time_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5,420), nil, nil, 1000)
	self.time_label:setString(TI18N("10秒后关闭"))
	self.time_label:setVisible(false)
	self.root_wnd:addChild(self.time_label)

	self.harm_btn = self.source_container:getChildByName("harm_btn")
	self.harm_btn:setVisible(false)
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

	self.fight_text = createLabel(24, Config.ColorData.data_new_color4[6], nil, 360, 455, "",self.source_container, nil, cc.p(0.5,0.5))

	self.tips_lab = createLabel(24, Config.ColorData.data_new_color4[6], nil, 360, 250, "",self.source_container, nil, cc.p(0.5,0.5))
	if self.result == 1 then
		self.tips_lab:setVisible(false)
	else
		self.tips_lab:setVisible(true)
	end
	
	self.tips_lab:setString(TI18N("            选择重新挑战后将再次挑战本次Boss关卡\n\n（不会额外消耗挑战次数，但本次挑战结果将失效）"))
	local result_get_bg = createSprite(PathTool.getResFrame("common", "common_90044"), 360,415, self.source_container, cc.p(0.5, 0.5))
	result_get_bg:setScaleX(5)
	self.pass_time = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(360, 415), nil, nil, 1000)
	self.pass_time:setString(TI18N("本次造成伤害：0"))
	self.source_container:addChild(self.pass_time) 


	local label  = createRichLabel(22,Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(360,368), nil, nil, 1000)
	
	self.source_container:addChild(label)
	--local result_line_bg = createSprite(PathTool.getResFrame("common", "common_1094"), 320, 368, self.source_container, cc.p(0, 0.5))
	--result_line_bg:setScaleX(-1)
	--local result_line_bg_2 = createSprite(PathTool.getResFrame("common", "common_1094"), 400,368, self.source_container, cc.p(0, 0.5))

	self.scroll_view = createScrollView(SCREEN_WIDTH, 230, 0, 130, self.source_container, ccui.ScrollViewDir.vertical) 

	self.comfirm_btn = createButton(self.root_wnd,TI18N("确定"), 620, 580, cc.size(168, 66), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_new_color4[1])
	self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 - 170, 470)
	self.comfirm_btn:enableShadow(Config.ColorData.data_new_color4[3], cc.size(0,-2),2)
	self.comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			PractisetowerController:getInstance():openResultWindow(false)
		end
	end)

	self.cancel_btn = createButton(self.root_wnd,TI18N("重新挑战"), 620, 580, cc.size(168, 66), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_new_color4[1])
	self.cancel_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 170, 470)
	self.cancel_btn:enableShadow(Config.ColorData.data_new_color4[2], cc.size(0,-2),2)
	self.cancel_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			local power = nil
			local award_cfg = Config.HolidayPractiseTowerData.data_tower[self.data.number]
			if award_cfg then
				power = award_cfg.power
			end
			PractisetowerController:getInstance():getModel():setResetFightId({id = self.data.number,power = power})
			PractisetowerController:getInstance():sender29103()	
		end
	end)
	if self.result == 0 then
		label:setString(TI18N("战斗提示"))
	else
		label:setString(TI18N("获得物品"))
	end
	self.fight_num = createLabel(24, Config.ColorData.data_new_color4[6], nil, self.root_wnd:getContentSize().width / 2 + 170, 425, "",self.root_wnd, nil, cc.p(0.5,0.5))
end

function PractiseTowerResultWindow:register_event()
	registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function PractiseTowerResultWindow:_onClickHarmBtn(  )
	if self.data and next(self.data) ~= nil then
		local setting = {}
        setting.fight_type = self.fight_type
		BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
	end
end

--剧情：{章节id,难度，副本id}
function PractiseTowerResultWindow:setData(data, fight_type, dungeon_data)
	if data then
		self.data = data or {}
		self.dungeon_data = dungeon_data
        self.fight_type = fight_type
        local pass_time = data.all_dps or 0

	
		self.reward_list = self.data.reward
		self.result = self.data.flag
		self.is_guide = self.data.is_guide
		
		self.pass_time:setString(string.format( TI18N("本次造成伤害：%s"),pass_time))
		self.harm_btn:setVisible(true)
        
		self:rewardViewUI()
		if self.fight_text then
			local name = Config.BattleBgData.data_fight_name[self.fight_type]
			if name then
	    		self.fight_text:setString(TI18N("当前战斗：")..name)
	    	end
		end
		
		self.cancel_btn:setVisible(true)
		self.fight_num:setVisible(true)
		self.comfirm_btn:setPositionX(self.root_wnd:getContentSize().width / 2 - 170)
		if self.result == 1 then
			self.cancel_btn:setVisible(false)
			self.fight_num:setVisible(false)
			self.comfirm_btn:setPositionX(self.root_wnd:getContentSize().width/2)
		end
		
		self.fight_num:setString(string.format(TI18N("剩余：%d次"),data.last_anew_times ))
	end
end

function PractiseTowerResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			if self.result == 1 then
				self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[103], cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
			else
				self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[104], cc.p(self.title_width * 0.5, self.title_height * 0.5 + 32), cc.p(0.5, 0.5), false, PlayerAction.action)
			end
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end


--奖励界面
function PractiseTowerResultWindow:rewardViewUI()
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
		self.start_y = self.max_height * 0.5
	else
		self.start_y = self.max_height - self.space - BackPackItem.Height * 0.5
	end
	for i, v in ipairs(self.reward_list) do
		local item = BackPackItem.new(true,true)
		item:setScale(1.3)
		item:setBaseData(v.base_id,v.num)
		
		local name  = Config.ItemData.data_get_data(v.base_id).name
		item:setGoodsName(name,nil,nil,1)
		local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
		local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space)
		item:setPosition(cc.p(_x, _y))
		self.scroll_view:addChild(item)
		self.item_list[i] = item
	end
	self:ItemAciton()
end

function PractiseTowerResultWindow:ItemAciton()
	if self.item_list and next(self.item_list or {}) ~= nil then
		local show_num = 0
		for i,v in pairs(self.item_list) do
			if v then
				delayRun(self.root_wnd,0.1 * (i - 1),function()
					v:setVisible(true)
					v:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function ()
							show_num = show_num + 1 
							if show_num >= tableLen(self.item_list) then
								if self.result == 1 then
									self:updateTimer()
								end
							end
					end)))
				end)
			end
		end
	else
		if self.result == 1 then
			self:updateTimer()
		end
	end
end

function PractiseTowerResultWindow:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
		local str = string.format(TI18N("%s秒后关闭"), new_time)
		if self.time_label and not tolua.isnull(self.time_label) then
			self.time_label:setVisible(true)
			self.time_label:setString(str)
		end
        if new_time <= 0 then
            PractisetowerController:getInstance():openResultWindow(false)
            GlobalTimeTicket:getInstance():remove("close_result_reward")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "close_result_reward")
end

--清理
function PractiseTowerResultWindow:close_callback()

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
		local data = {result = self.result ,combat_type = BattleConst.Fight_Type.PractiseTower}
		BattleController:getInstance():getModel():result(data)
	end

	GlobalTimeTicket:getInstance():remove("close_result_reward")
	PractisetowerController:getInstance():openResultWindow(false)
end
