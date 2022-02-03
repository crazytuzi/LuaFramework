--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 限时招募
-- @DateTime:    2019-04-11 17:04:09
-- *******************************
RecruitHeroWindow = RecruitHeroWindow or BaseClass(BaseView)

local controller = RecruitHeroController:getInstance()
function RecruitHeroWindow:__init()
	self.is_full_screen = true
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "recruithero/recruit_hero_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg/action","action_bigbg_3"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("recruithero", "recruithero"), type = ResourcesType.plist},
	}
	self.player_item = {}
end

function RecruitHeroWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)

	local load_bg = self.main_container:getChildByName("load_bg")
	local res = PathTool.getPlistImgForDownLoad("bigbg/action", "action_bigbg_3")
    if not self.bg_load then
        self.bg_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(load_bg) then
                loadSpriteTexture(load_bg, res, LOADTEXT_TYPE)
            end
        end,self.bg_load)
    end

    -- 战斗预览按钮
    self.battle_preview_btn = self.main_container:getChildByName("battle_preview_btn")
    -- self.battle_preview_btn:setVisible(false)
    self.preview_btn_label = self.battle_preview_btn:getChildByName("preview_btn_label")
    self.preview_btn_label:setString(TI18N("战斗预览"))

	self.main_container:getChildByName("Text_1"):setString(TI18N("活动时间："))
	self.main_container:getChildByName("Text_3"):setString(TI18N("完成上方任务即可免费领取5星英雄斯芬克斯"))
	self.remain_time = self.main_container:getChildByName("remain_time")
	self.remain_time:setString("")

	self.all_get = self.main_container:getChildByName("all_get")
	self.all_get:setVisible(false)
	self.all_get:getChildByName("label"):setString(TI18N("领取"))
	self.all_goto = self.main_container:getChildByName("all_goto")
	self.all_goto:setVisible(false)
	self.all_goto:getChildByName("label"):setString(TI18N("未完成"))
	self.btn_paint = self.main_container:getChildByName("btn_paint")
	self.btn_paint:getChildByName("Text_2"):setString(TI18N("查看英雄"))

	self.finish_text = self.main_container:getChildByName("finish_text")
	self.finish_text:setString("")
	self:setPlayerItem()

	self.btn_close = self.main_container:getChildByName("btn_close")
end

function RecruitHeroWindow:setPlayerItem()
	local pos_x = 100
	local pos_y = 114
	local login_data = ActionController:getInstance():getModel():getSevenLoginData()
	local center_id = 26900
	if login_data.type == 1 then --新版
		local item_config = Config.LoginDaysNewData
		if item_config and item_config.data_day and item_config.data_day[2] then
			center_id = item_config.data_day[2].rewards[1][1]
		end
	end
	local bid = {29905,center_id,26903}
	for i=1,3 do
		local tab = {}
		local item = self.main_container:getChildByName("item_"..i)
		tab.btn_goto = item:getChildByName("btn_goto")
		tab.btn_goto:setVisible(false)
		tab.btn_goto:getChildByName("label"):setString(TI18N("前往完成"))
		tab.btn_get = item:getChildByName("btn_get")
		tab.btn_get:setVisible(false)
		tab.btn_get_label = tab.btn_get:getChildByName("label")
		tab.btn_get_label:setString(TI18N("前往领取"))
		tab.has = item:getChildByName("has")
		tab.has:setVisible(false)

		tab.title_label = item:getChildByName("title")
		
		self.player_item[i] = BackPackItem.new(false, true, false, 0.8, false)
	    self.player_item[i]:setPosition(pos_x, pos_y)
	    item:addChild(self.player_item[i])
	    self.player_item[i]:setBaseData(bid[i], 50)
	    self.player_item[i]:setDefaultTip()

		self.player_item[i] = tab
	end
end

function RecruitHeroWindow:openRootWnd()
	controller:sender25100()
	controller:getModel():setDayFirstLogin(false)
end
function RecruitHeroWindow:register_event()
	self:addGlobalEvent(RecruitHeroEvent.RecruitHeroBaseInfo, function(data)
		local ctr = ActionController:getInstance()
		local time = data.end_time - GameNet:getInstance():getTime()
		ctr:getModel():setCountDownTime(self.remain_time,time)
		self:showBtnStatus(data)
    end)
	registerButtonEventListener(self.btn_close, function()
        controller:openRecruitHeroWindow(false)
    end ,true, 2)
    registerButtonEventListener(self.battle_preview_btn, function()
        TimesummonController:getInstance():send23219(BattlePreviewParm.RecruitHero)
    end, true)
    registerButtonEventListener(self.background, function()
        controller:openRecruitHeroWindow(false)
    end ,false, 2)
    for i,v in pairs(self.player_item) do
    	registerButtonEventListener(v.btn_goto, function()
    		local status = controller:getModel():getRecruitEndTime()
    		if status then
		        self:jumpGotoTeskView(i)
		    else
		    	message(TI18N("活动已结束"))
		    end
	    end ,true, 1)
	    registerButtonEventListener(v.btn_get, function()
	        self:jumpGetTeskView(i)
	    end ,true, 1)
    end
    registerButtonEventListener(self.all_get, function()
        controller:sender25101(0)
    end ,true, 2)
    registerButtonEventListener(self.btn_paint, function()
        HeroController:getInstance():openHeroInfoWindowByBidStar(30508, 10)
    end ,true, 1)
end

--任务
function RecruitHeroWindow:showBtnStatus(data)
	if not data then return end
	local title = {TI18N("通关%d/%d关"),TI18N("次日登录"),TI18N("激活至尊月卡")}
	local tesk_dun = Config.WelfareData.data_welfare_const.dun_max_id
	local finish_num = 0
	local pos = {2,1,3}
	for i=1,3 do
		local base_data = controller:getModel():getRecruitBaseData(pos[i])
		if base_data then
			if i == 1 then
				self.player_item[i].title_label:setString(string.format(title[i],base_data.val,tesk_dun.val))
			else
				self.player_item[i].title_label:setString(title[i])
			end
			--特殊处理
			if i == 3 and base_data.status == 1 then
				self.player_item[i].btn_get_label:setString(TI18N("领取"))
			end
			self.player_item[i].btn_goto:setVisible(base_data.status == 0)
			self.player_item[i].btn_get:setVisible(base_data.status == 1)
			self.player_item[i].has:setVisible(base_data.status == 2)
			if base_data.status == 1 or base_data.status == 2 then
				finish_num = finish_num + 1
			end
		end
	end
	local str = string.format(TI18N("完成进度: %d/3"),finish_num)
	self.finish_text:setString(str)
	if data.state then
		self.all_goto:setVisible(data.state == 0)
		self.all_get:setVisible(data.state == 1 or data.state == 1)
	end
end
--前往的跳转
function RecruitHeroWindow:jumpGotoTeskView(num)
	if not num then return end
	if num == 1 then
		JumpController:getInstance():jumpViewByEvtData({5})
	elseif num == 2 then
		local login_data = ActionController:getInstance():getModel():getSevenLoginData()
		if login_data.type == 1 then --新版
			ActionController:getInstance():openEightLoginWin(true)
		else
			ActionController:getInstance():openSevenLoginWin(true)
		end
	elseif num == 3 then
		JumpController:getInstance():jumpViewByEvtData({44})
	end
end
--领取的跳转
function RecruitHeroWindow:jumpGetTeskView(num)
	if not num then return end
	if num == 1 then
		JumpController:getInstance():jumpViewByEvtData({46})
	elseif num == 2 then
		local login_data = ActionController:getInstance():getModel():getSevenLoginData()
		if login_data.type == 1 then --新版
			ActionController:getInstance():openEightLoginWin(true)
		else
			ActionController:getInstance():openSevenLoginWin(true)
		end
	elseif num == 3 then
		controller:sender25101(num)
	end
end
function RecruitHeroWindow:close_callback()
	if self.player_item and next(self.player_item or {}) ~= nil then
        for i, v in ipairs(self.player_item) do
            if v and v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    if self.bg_load then
        self.bg_load:DeleteMe()
    end
    self.bg_load = nil
    doStopAllActions(self.remain_time)
	controller:openRecruitHeroWindow(false)
end
