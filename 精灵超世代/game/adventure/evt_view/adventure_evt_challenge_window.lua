-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      挑战护卫界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureEvtChallengeWindow = AdventureEvtChallengeWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local table_insert = table.insert
local game_net = GameNet:getInstance()

function AdventureEvtChallengeWindow:__init(data)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.layout_name = "adventure/adventure_evt_challenge_window"
	self.res_list = {
	}
    self.hero_list = {}

    -- 当前信息.其实需要获取单位id
    self.data = data

    self.is_skip_fight = false --跳过战斗
end

function AdventureEvtChallengeWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("挑战守卫"))
    container:getChildByName("change_title"):setString(TI18N("从列表选择宝可梦"))
    container:getChildByName("self_title"):setString(TI18N("我方"))
    container:getChildByName("other_title"):setString(TI18N("守卫"))

    self.challenge_btn = container:getChildByName("challenge_btn")
    self.challenge_btn:getChildByName("label"):setString(TI18N("进入战斗"))

    self.cur_hero_item = HeroExhibitionItem.new(1, true, 0, false) 
    self.cur_hero_item:setPosition(200, 520)
    self.cur_hero_item:showProgressbar(100)
    container:addChild(self.cur_hero_item)

    self.target_hero_item = HeroExhibitionItem.new(1, true, 0, false) 
    self.target_hero_item:setPosition(522, 520)
    self.target_hero_item:showProgressbar(100)
    container:addChild(self.target_hero_item)

    self.other_name = container:getChildByName("other_name")        -- 守卫名字

    self.power_click = container:getChildByName("power_click")
    self.fight_label = CommonNum.new(20, self.power_click, 99999, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(165, 37)
    self.container = container

    self.checkbox_skip = container:getChildByName("checkbox_skip")
    local skip_name = self.checkbox_skip:getChildByName("name")
    skip_name:setString(TI18N("跳过并连续战斗"))
    skip_name:setFontSize(22)
    self.checkbox_skip:setVisible(false)
    self.checkbox_skip:setPosition(280,400)

    self.checkbox_series = container:getChildByName("checkbox_series")
    self.checkbox_series:getChildByName("name"):setString(TI18N("连续挑战"))
    self.checkbox_series:setVisible(false)
end

function AdventureEvtChallengeWindow:register_event()
    registerButtonEventListener(self.background, function() 
        controller:openEvtViewByType(false) 
    end, false, 2) 

    registerButtonEventListener(self.challenge_btn, function() 
        if self.data then
            local ext_list = {}
            --type: 2 跳过战斗 3 连续
            if self.is_skip_fight then
                local tab = {}
                for i=2,3 do
                    table.insert(ext_list,{type = i, val = 1})
                end
            end
            model:setAdventureFightReturnTag(false)
            controller:send20620(self.data.id, AdventureEvenHandleType.handle,ext_list)
        end
    end, true, 1) 
    --跳过战斗
    registerButtonEventListener(self.checkbox_skip, function()
        local skip_select = self.checkbox_skip:isSelected()
        self.is_skip_fight = skip_select
    end, true, 1)

    self:addGlobalEvent(AdventureEvent.UpdateMonsterHP, function(data)
        if self.target_hero_item then
            data = data or 0
            self.target_hero_item:showProgressbar(data)
        end
    end)
end

function AdventureEvtChallengeWindow:openRootWnd(data)
    if self.data then
        controller:send20620(self.data.id, AdventureEvenHandleType.requst, {})
        -- 设置头像
        if self.target_hero_item and self.data and self.data.config then
            self.target_hero_item:setUnitData(self.data.config.unit_id)

            local config = Config.UnitData.data_unit(self.data.config.unit_id)
            if config  then
                self.other_name:setString(config.name)
            end
        end
    end
    self:createHeroList()
     

    self.base_data = model:getAdventureBaseData()

    if self.base_data then
        local config = Config.AdventureData.data_floor_reward[self.base_data.id]
        if config and config.auto_combat == 1 then
            --可以跳过战斗
            self.checkbox_skip:setVisible(true)
            local is_skip = SysEnv:getInstance():getBool(SysEnv.keys.adventure_skip_fight, false)
            self.is_skip_fight = is_skip
            self.checkbox_skip:setSelected(self.is_skip_fight)
        end
    end
end

--==============================--
--desc:创建自己的伙伴列表
--time:2019-01-22 10:39:19
--@return 
--==============================--
function AdventureEvtChallengeWindow:createHeroList()
    local hero_list = model:getFormList()
    local partner_id = model:getSelectPartnerID() 
    for i,v in ipairs(hero_list) do
        local function clickback(cell, data)
            self:selectHeroItem(cell, data)
        end
        if self.hero_list[i] == nil then
            self.hero_list[i] = HeroExhibitionItem.new(0.9, true, 0, false) 
            self.hero_list[i]:setPosition(120 + (i-1)* 120, 306)
            self.hero_list[i]:addCallBack(clickback)
            self.container:addChild(self.hero_list[i])
        end
        local hero_item = self.hero_list[i]
        self:updateHeroInfo(hero_item, v)

        -- 默认选中一个
        if partner_id ~= 0 then
            if v.partner_id == partner_id then
                self:selectHeroItem(hero_item, v)
            end
        end
    end
end

--==============================--
--desc:设置当前选中的
--time:2019-01-24 07:20:59
--@cell:
--@data:
--@return 
--==============================--
function AdventureEvtChallengeWindow:selectHeroItem(cell, data)
    if data.now_hp == 0 then
        message(TI18N("死亡宝可梦无法选择"))
        return
    end
	if self.select_cell == cell then return end
	if self.select_cell then
		self.select_cell:setSelected(false)
		self.select_cell = nil
	end
	self.select_cell = cell
	self.select_cell:setSelected(true)
    self.fight_label:setNum(changeBtValueForPower(data.power))
	-- 请求储存
	controller:requestSelectPartner(data.partner_id)

    self.cur_hero_item:setData(data)
    -- 设置血量
    local hp_per = data.now_hp / data.hp
    self.cur_hero_item:showProgressbar(hp_per * 100)
end 

--==============================--
--desc:外部设置额外信息
--time:2019-01-24 06:04:06
--@item:
--@data:
--@return 
--==============================--
function AdventureEvtChallengeWindow:updateHeroInfo(item, data)
	if item == nil then return end
	item:setData(data)
	local hp_per = data.now_hp / data.hp
	item:showProgressbar(hp_per * 100)
	if hp_per == 0 then
		item:showStrTips(true, TI18N("已阵亡"))
	else
		item:showStrTips(false)
	end
end

function AdventureEvtChallengeWindow:close_callback()
    SysEnv:getInstance():set(SysEnv.keys.adventure_skip_fight, self.is_skip_fight, true)
    if self.cur_hero_item then
        self.cur_hero_item:DeleteMe()
    end
    self.cur_hero_item = nil
    if self.target_hero_item then
        self.target_hero_item:DeleteMe()
    end
    self.target_hero_item = nil

    if self.fight_label then
        self.fight_label:DeleteMe()
    end
    self.fight_label = nil

    for i,v in ipairs(self.hero_list) do
        v:DeleteMe()
    end
    self.item_list = nil

	controller:openEvtViewByType(false)
end
