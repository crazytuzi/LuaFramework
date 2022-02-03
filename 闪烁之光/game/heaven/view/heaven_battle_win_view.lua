--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-19 10:26:20
-- @description    : 
		-- 天界副本战斗胜利
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

HeavenBattleWinView = HeavenBattleWinView or BaseClass(BaseView)

function HeavenBattleWinView:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "heaven/heaven_battle_win_view"

    self.effect_cache_list = {}
    self.desc_txt_list = {}
    self.star_list = {}
    self.big_star_list = {}
end

function HeavenBattleWinView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("get_title"):setString(TI18N("获得物品"))

    self.success_bg = container:getChildByName("success_bg")
    self.Sprite_1 = self.success_bg:getChildByName("Sprite_1")
    if self.sprite_1_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end
    
    self.Sprite_2 = self.success_bg:getChildByName("Sprite_2")
    if self.sprite_2_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end
    

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:setVisible(false)
    self.harm_btn = container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))
    for i=1,3 do
    	local star = container:getChildByName("star_" .. i)
    	if star then
    		table.insert(self.star_list, star)
    	end
    	local desc_txt = container:getChildByName("desc_txt_" .. i)
    	if desc_txt then
    		table.insert(self.desc_txt_list, desc_txt)
    	end
        local big_star = self.root_wnd:getChildByName("big_star_" .. i)
        if big_star then
            table.insert(self.big_star_list, big_star)
        end
    end
    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 430, "",container, nil, cc.p(0.5,0.5))

    self.comfirm_btn = createButton(self.root_wnd,TI18N("确定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 - 170, 315)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:_onClickBtnClose()
        end
    end)

    self.cancel_btn = createButton(self.root_wnd,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 170, 315)
    self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            BattleResultReturnMgr:returnByFightType(BattleConst.Fight_Type.HeavenWar) --先
            self:_onClickBtnClose()    
        end
    end)

    self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    local list_view = container:getChildByName("list_view")
    local scroll_view_size = list_view:getContentSize()
    local setting = {
        item_class = HeavenBattleAwardItem,
        start_x = 94,
        space_x = 20,
        start_y = 0,
        space_y = 10,
        item_width = 120,
        item_height = 145,
        row = 4,
        col = 4,
        delay = 6,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(list_view, nil, nil, nil, scroll_view_size, setting)

    self.container = container
end

function HeavenBattleWinView:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.confirm_btn, handler(self, self._onClickBtnClose), true, 2)
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function HeavenBattleWinView:_onClickBtnClose(  )
	_controller:openHeavenBattleWinView(false)
end

function HeavenBattleWinView:_onClickHarmBtn(  )
    if self.data and self.data.all_hurt_statistics then
        table.sort( self.data.all_hurt_statistics, function(a, b) return a.type < b.type end)
        local role_vo = RoleController:getInstance():getRoleVo()
        local atk_name = role_vo.name
        local is_boss = _model:getCustomsIsBossType(self.data.id, self.data.order_id)
        for i,v in ipairs(self.data.all_hurt_statistics) do
            if is_boss then
                v.atk_name  = _string_format("%s(队伍%s)",atk_name, v.a_round)
                v.target_role_name  = _string_format("%s(队伍%s)",v.target_role_name, v.b_round)
            else
                v.atk_name  = atk_name
            end
        end
        BattleController:getInstance():openBattleHarmInfoView(true, self.data.all_hurt_statistics)
    end
end

function HeavenBattleWinView:handleEffect( status )
	if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(901), cc.p(self.title_width*0.5,self.title_height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end

function HeavenBattleWinView:openRootWnd( data )
	playOtherSound("c_arenasettlement", AudioManager.AUDIO_TYPE.COMMON)
    if data ~= nil then
        self.data = data
        self:setBaseInfo()
        self:setRewardsList()
        self:handleEffect(true)
        if data.all_hurt_statistics then
            self.harm_btn:setVisible(true)
        end

        if self.fight_text then
            local name = Config.BattleBgData.data_fight_name[BattleConst.Fight_Type.HeavenWar]
            if name then
                self.fight_text:setString(TI18N("当前战斗：")..name)
            end
        end
    end
end

function HeavenBattleWinView:setBaseInfo(  )
	if not self.data then return end

	local chapter_id = self.data.id -- 章节id
	local customs_id = self.data.order_id -- 关卡id
	local customs_data = Config.DungeonHeavenData.data_customs[chapter_id]
	if not customs_data then return end
	local c_data = customs_data[customs_id]
	if not c_data then return end

	for k,v in pairs(self.star_list) do
		v:setVisible(false)
	end
	for k,v in pairs(self.desc_txt_list) do
		v:setVisible(false)
	end
    local pass_star = 0
	for i,v in ipairs(c_data.cond_info) do
		local star_id = v[1]
		local con_id = v[2]
		local desc_txt = self.desc_txt_list[i]
		local con_data = Config.DungeonHeavenData.data_star_cond[con_id]
		if con_data and desc_txt then
			desc_txt:setVisible(true)
			desc_txt:setString(con_data.type)
		end
		local star = self.star_list[i]
		if star and self:checkStarIsShowById(star_id) then
			star:setVisible(true)
            pass_star = pass_star + 1
		end
	end

    for i,big_star in ipairs(self.big_star_list) do
        big_star:setVisible(i <= pass_star)
    end
end

function HeavenBattleWinView:checkStarIsShowById( id )
	local is_show = false
	if self.data and self.data.star_info then
		for k,v in pairs(self.data.star_info) do
			if v.id == id then
				is_show = (v.state == 1)
				break
			end
		end
	end
	return is_show
end

function HeavenBattleWinView:setRewardsList(  )
	if self.data == nil or self.data.award == nil or next(self.data.award) == nil then return end
    self.scroll_view:setData(self.data.award)
end

function HeavenBattleWinView:close_callback(  )
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
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
    _controller:openHeavenBattleWinView(false)
end

-------------------------------------@ item
HeavenBattleAwardItem = class("HeavenBattleAwardItem", function()
    return ccui.Layout:create()
end)

function HeavenBattleAwardItem:ctor()
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setContentSize(cc.size(120,145))
    self:setCascadeOpacityEnabled(true)

    self.item = BackPackItem.new(false, true, false, 1, false, true)
    self.item:setPosition(60,85)
    self:addChild(self.item)

    self.item_name_label = createLabel(24, cc.c4b(0xff,0xe8,0x87,0xff),nil, 60, 0, "", self, nil, cc.p(0.5, 0))

    self:registerEvent()
end

function HeavenBattleAwardItem:registerEvent()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self:setOpacity(0)
            self:setScale(2)
            local fadeIn = cc.FadeIn:create(0.1)
            local scaleTo = cc.ScaleTo:create(0.1, 1)
            self:runAction(cc.Spawn:create(fadeIn, scaleTo))
        elseif "exit" == event then

        end 
    end)
end

function HeavenBattleAwardItem:setData(data)
    if data then
        self.item:setBaseData(data.item_id, data.num)

        local item_config = Config.ItemData.data_get_data(data.item_id)
        if item_config then
            self.item_name_label:setString(item_config.name)
        end
    end
end

function HeavenBattleAwardItem:suspendAllActions()
end

function HeavenBattleAwardItem:DeleteMe()
    if self.item then
        self.item:DeleteMe()
    end
    self.item = nil
    self:removeAllChildren()
    self:removeFromParent()
end