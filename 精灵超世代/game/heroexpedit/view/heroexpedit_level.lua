--**********************
--关卡守将信息
--**********************
HeroExpeditLevel = HeroExpeditLevel or BaseClass(BaseView)

local controller = HeroExpeditController:getInstance()
local sign_info = Config.ExpeditionData.data_sign_info
function HeroExpeditLevel:__init()
    self.is_full_screen = false
    self.layout_name = "heroexpedit/level_message"
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.reward_list = {}
end

function HeroExpeditLevel:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("main_container")

    self.text_level_msg = self.main_container:getChildByName("Image_6"):getChildByName("Text_7")
    self.text_level_msg:setString("")
	self.main_container:getChildByName("reward"):getChildByName("Text_17_0"):setString(TI18N("奖励"))
	self.reward_panel = self.main_container:getChildByName("reward"):getChildByName("reward_panel")
	self.main_container:getChildByName("enemy"):getChildByName("Text_17"):setString(TI18N("敌方阵容"))
	self.enemy_panel = self.main_container:getChildByName("enemy"):getChildByName("enemy_panel")
	self.btn_fight = self.main_container:getChildByName("btn_fight")
	self.btn_fight_label = self.btn_fight:getChildByName("Text_6")
    self.btn_fight_label:setString(TI18N("战斗"))

    self.btn_video = self.main_container:getChildByName("btn_video")

	self.text_name = self.main_container:getChildByName("text_name")
	self.text_fight_power = self.main_container:getChildByName("text_fight_power")
end

function HeroExpeditLevel:fightMessage(data)
    --获取当前关卡
    self.cur_grard_id = data.id

	self.text_level_msg:setString(TI18N("第")..sign_info[data.id].floor..TI18N("关"))

 	self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setAnchorPoint(cc.p(0.5, 0.5))
    self.my_head:setPosition(cc.p(166,541))
    self.main_container:addChild(self.my_head)
    self.my_head:setHeadRes(data.face)
    self.my_head:setLev(data.lev)

    self.text_name:setString(data.name)
    self.text_fight_power:setString(data.power)

    if data.status == 2 then
        setChildUnEnabled(true,self.btn_fight)
        self.btn_fight_label:setTextColor(cc.c4b(0xff,0xff,0xff0,0xff))
        self.btn_fight_label:disableEffect(cc.LabelEffect.OUTLINE)
        self.btn_fight:setTouchEnabled(false)
    end

    --关卡奖励
    if data.rewards then
        local num = tableLen(data.rewards)
        local pos = {}
        if num == 2 then
        	pos = {108,365}
        else
        	pos = {108,238,365}
        end
        for i=1, num do
        	if not self.reward_list[i] then
    	    	self.reward_list[i] = BackPackItem.new(nil,true,nil,0.9)
    		    self.reward_list[i]:setAnchorPoint(0,0.5)
    		    self.reward_panel:addChild(self.reward_list[i])
    		end
    		if self.reward_list[i] then
    		    self.reward_list[i]:setPosition(cc.p(pos[i], 55))
                if data.rewards[i].bid == 25 and data.is_holiday == 1 then
                    self.reward_list[i]:holidHeroExpeditTag(true, TI18N("限时提升"))
                else
                    self.reward_list[i]:holidHeroExpeditTag(false)
                end
    		    self.reward_list[i]:setDefaultTip()
    		    self.reward_list[i]:setBaseData(data.rewards[i].bid, data.rewards[i].num)
    		end
        end
    end

    local scroll_view_size = self.enemy_panel:getContentSize()
    local setting = {
        item_class = HeroExhibitionItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.enemy_list = CommonScrollViewLayout.new(self.enemy_panel, cc.p(-5, 10) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.enemy_list:setClickEnabled(false)

    for i,v in pairs(data.guards) do
        v.blood = v.hp_per
    end
    self.enemy_list:setData(data.guards,nil,nil,{scale = 0.8, can_click = false,from_type = HeroConst.ExhibitionItemType.eExpeditFight})
end

function HeroExpeditLevel:register_event()
	self:addGlobalEvent(HeroExpeditEvent.levelMessageEvent,function(data)
		if not data then return end
		self:fightMessage(data)
	end)

	registerButtonEventListener(self.btn_fight,function()
		HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Expedit_Fight)
		controller:openHeroExpeditLevelView(false)
	end, true, 1)

	registerButtonEventListener(self.background, function()
        controller:openHeroExpeditLevelView(false)
    end,false, 2)

    registerButtonEventListener(self.btn_video, function()
        if self.cur_grard_id then
            controller:openHeroexpeditVideoView(true,self.cur_grard_id)
            controller:openHeroExpeditLevelView(false)
        end
    end,true)
end

function HeroExpeditLevel:openRootWnd()
    controller:sender24409() --雇佣的宝可梦
end

function HeroExpeditLevel:close_callback()
	if self.reward_list and next(self.reward_list or {}) ~= nil then
        for i, v in ipairs(self.reward_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    if self.my_head then
        self.my_head:DeleteMe()
        self.my_head = nil
    end 
    if self.enemy_list then 
        self.enemy_list:DeleteMe()
        self.enemy_list = nil
    end

	controller:openHeroExpeditLevelView(false)
end