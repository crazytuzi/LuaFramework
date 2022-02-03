-- --------------------------------------------------------------------
-- 远征扫荡结算
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

HeroexpeditResultWindow = HeroexpeditResultWindow or BaseClass(BaseView)

function HeroexpeditResultWindow:__init(data)
	self.data = data
	self.item_list = {}
	self.win_type = WinType.Tips
	self.layout_name = "battle/battle_result_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}
end

function HeroexpeditResultWindow:openRootWnd()
	self:setData()
end

--初始化
function HeroexpeditResultWindow:open_callback()
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

	self.clear_label = createLabel(24,Config.ColorData.data_color4[1],nil,364, 416,"",self.root_wnd)
	self.clear_label:setAnchorPoint(0.5,0.5)
	local comfirm_btn = createButton(self.root_wnd,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
	comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 5,470)
    comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
	comfirm_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            HeroExpeditController:getInstance():openHeroexpeditResultView(false)
		end
	end)

	self.harm_btn = self.source_container:getChildByName("harm_btn")
	self.harm_btn:setVisible(false)
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

	local result_get_bg = createSprite(PathTool.getResFrame("common", "common_90044"), 360,462, self.source_container, cc.p(0.5, 1))
	result_get_bg:setScaleX(5)

	local label  = createRichLabel(22,31, cc.p(0.5, 0.5), cc.p(360,382), nil, nil, 1000)
	label:setString(TI18N("获得物品"))
	self.source_container:addChild(label)
	local result_line_bg = createSprite(PathTool.getResFrame("common", "common_1094"), 320, 398, self.source_container, cc.p(0, 1))
	result_line_bg:setScaleX(-1)
	local result_line_bg_2 = createSprite(PathTool.getResFrame("common", "common_1094"), 400,398, self.source_container, cc.p(0, 1))

	self.scroll_view = createScrollView(SCREEN_WIDTH, 230, 0, 130, self.source_container, ccui.ScrollViewDir.vertical) 
end

function HeroexpeditResultWindow:register_event()
end

function HeroexpeditResultWindow:setData()
	if self.data then
		local str = string.format(TI18N("根据昨日通关关卡数，已自动扫荡%d关"),self.data.floor_id)
		self.clear_label:setString(str)
		self:rewardViewUI(self.data.rewards)
	end
end
--奖励界面
function HeroexpeditResultWindow:rewardViewUI(reward)
	if not reward then return end
	local sum = #reward
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
	for i, v in ipairs(reward) do
		local item = BackPackItem.new(true,true)
		item:setBaseData(v.bid,v.num)

		local name  = Config.ItemData.data_get_data(v.bid).name
		item:setGoodsName(name,nil,nil,1)
		local _x = self.start_x + BackPackItem.Width * 0.5 + ((i - 1) % col) * (BackPackItem.Width + self.space)
		local _y = self.start_y - math.floor((i - 1) / col) * (BackPackItem.Height + self.space)
		item:setPosition(cc.p(_x, _y))
		self.scroll_view:addChild(item)
		self.item_list[i] = item
	end
end
function HeroexpeditResultWindow:handleEffect(status)
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
--清理
function HeroexpeditResultWindow:close_callback()
	if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
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
		local data = {result = self.data ,combat_type = BattleConst.Fight_Type.ExpeditFight}
		BattleController:getInstance():getModel():result(data, self.is_leave_self)
	end
end
