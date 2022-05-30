-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:战斗结算主界面]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
-- BattleResultView = class("BattleResultView", function()
-- 	return ccui.Layout:create()
-- end)

BattleResultView = BattleResultView or BaseClass(BaseView)


function BattleResultView:__init(result,fight_type)
	self.result = result
	self.x = 100
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.fight_type = fight_type
	self.is_running = true
	self.partner_list = {}
	self.item_list = {}
	-- self.cur_round = round
	-- self.total_round = total_round
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

function BattleResultView:openRootWnd(data,fight_type)
	self:setData(data, fight_type)
end

--初始化
function BattleResultView:open_callback()
	local res = ""
	playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 

	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.source_container = self.root_wnd:getChildByName("container")
	--self.source_container:setScale(display.getMaxScale())
	self.title_container = self.source_container:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height
	self:handleEffect(true)

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

	self.fight_text = createLabel(24, Config.ColorData.data_new_color4[6], nil, 360, 820, "",self.root_wnd, nil, cc.p(0.5,0.5))

	self.time_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5,420), nil, nil, 1000)
	self.time_label:setString(TI18N("10秒后关闭"))
	self.root_wnd:addChild(self.time_label)

	if self.fight_type == BattleConst.Fight_Type.DungeonStone then
		--宝石副本不用返回
		self:createComfirmBtn()
	else
		self:createComfirmAndCancelBtn()
	end


	self.harm_btn = self.source_container:getChildByName("harm_btn")
	self.harm_btn:setVisible(false)
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

	local label  = createRichLabel(22,175, cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width/2,775), nil, nil, 1000)
	label:setString(TI18N("获得物品"))
	self.root_wnd:addChild(label)
	--local result_line_bg = createSprite(PathTool.getResFrame("common", "common_1094"), self.root_wnd:getContentSize().width / 2 - 40, 790, self.root_wnd, cc.p(0, 1))
	--result_line_bg:setScaleX(-1)
	--local result_line_bg_2 = createSprite(PathTool.getResFrame("common", "common_1094"), self.root_wnd:getContentSize().width / 2 + 40,790, self.root_wnd, cc.p(0, 1))
	--
	self.scroll_view = createScrollView(SCREEN_WIDTH,210,0,518,self.root_wnd,ccui.ScrollViewDir.vertical)
end

function BattleResultView:createComfirmBtn()
	if not self.root_wnd then return end
	self.comfirm_btn = createButton(self.root_wnd,TI18N("确 定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
	self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2, 470)
	self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
	self.comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			BattleController:getInstance():openFinishView(false,self.fight_type)
		end
	end)
end
--创建确定和取消按钮
function BattleResultView:createComfirmAndCancelBtn()
	if not self.root_wnd then return end
	self.comfirm_btn = createButton(self.root_wnd,TI18N("确 定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
	self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 - 170, 470)
	self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
	self.comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			BattleController:getInstance():openFinishView(false,self.fight_type)
		end
	end)

	self.cancel_btn = createButton(self.root_wnd,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
	self.cancel_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 170, 470)
	self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
	self.cancel_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			BattleResultReturnMgr:returnByFightType(self.fight_type) --先
            BattleController:getInstance():openFinishView(false,self.fight_type) --后
		end
	end)
end


function BattleResultView:register_event()
	registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function BattleResultView:_onClickHarmBtn(  )
	if self.data and next(self.data) ~= nil then
		local setting = {}
        setting.fight_type = self.fight_type
		BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
	end
end

--剧情：{章节id,难度，副本id}
function BattleResultView:setData(data, fight_type)
	if data then
		self.data = data or {}
		self.fight_type = fight_type
		self.reward_list = self.data.item_rewards or {}
		self.result = self.data.result
		self.is_guide = self.data.is_guide
		self:rewardViewUI()
		if self.data and self.data.hurt_statistics then
			self.harm_btn:setVisible(true)
		else
			self.harm_btn:setVisible(false)
		end

		if self.fight_text then
			local name = Config.BattleBgData.data_fight_name[self.fight_type]
			if name then
	    		self.fight_text:setString(TI18N("当前战斗：")..name)
	    	end
		end
	end
end

function BattleResultView:handleEffect(status)
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

--奖励界面
function BattleResultView:rewardViewUI()
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
		if v.bid and v.num then
			local item = BackPackItem.new(true,true)
			item:setScale(1.3)
			item:setBaseData(v.bid,v.num)
			local item_config = Config.ItemData.data_get_data(v.bid)
			if item_config then
				--item:setGoodsName(item_config.name,nil,nil,175)
			end
			local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
			local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space)
			item:setPosition(cc.p(_x, _y + 20))
			item:setDefaultTip()
			self.scroll_view:addChild(item)
			self.item_list[i] = item
		end
	end
	self:ItemAciton()
end

function BattleResultView:ItemAciton()
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

function BattleResultView:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
		local str = string.format(TI18N("%s秒后关闭"), new_time)
		if self.time_label and not tolua.isnull(self.time_label) then
			self.time_label:setString(str)
		end
        if new_time <= 0 then
            BattleController:getInstance():openFinishView(false,self.fight_type)
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "result_timer" .. self.fight_type)
end

--清理
function BattleResultView:close_callback()
	-- 移除可能存在的装备tips
	HeroController:getInstance():openEquipTips(false)
    TipsManager:getInstance():hideTips()
	BattleController:getInstance():openFinishView(false,self.fight_type) 
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW,self.fight_type)
	GlobalTimeTicket:getInstance():remove("result_timer" .. self.fight_type)
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
	if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
	end
	
	if self.fight_type == BattleConst.Fight_Type.Darma then
		GlobalEvent:getInstance():Fire(BattleEvent.MOVE_DRAMA_EVENT, self.fight_type)
	end
	if BattleController:getInstance():getModel():getBattleScene() and BattleController:getInstance():getIsSameBattleType(self.fight_type) then
		BattleController:getInstance():getModel():result(self.data, self.is_leave_self)
	end
end
