-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛竞猜界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionGuessWindow = ArenaChampionGuessWindow or BaseClass(BaseView)

function ArenaChampionGuessWindow:__init(view_type)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
	self.win_type = WinType.Mini
	self.is_full_screen = false
    self.layout_name = "arena/arena_champion_guess_window"
    self.cur_set_value = 0
    self.guess_coin = 10
    self.can_bet = 300
    self.guess_max = 300
	self.res_list = {
	-- {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
	}

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
    else
        self.ctrl = CrosschampionController:getInstance()
    end
end 


function ArenaChampionGuessWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("竞猜"))
    container:getChildByName("set_title"):setString(TI18N("竞猜数量"))
    container:getChildByName("can_guess_title"):setString(TI18N("可竞猜"))
    container:getChildByName("can_get_title"):setString(TI18N("可获得"))
    container:getChildByName("guess_title"):setString(TI18N("投入竞猜币数量"))

    if self.view_type == ArenaConst.champion_type.cross and Config.ItemData.data_get_data(33) then
        local sprite_1 = container:getChildByName("Sprite_1")
        local sprite_2 = container:getChildByName("Sprite_2")
        loadSpriteTexture(sprite_1, PathTool.getItemRes(Config.ItemData.data_get_data(33).icon), LOADTEXT_TYPE)
        loadSpriteTexture(sprite_2, PathTool.getItemRes(Config.ItemData.data_get_data(33).icon), LOADTEXT_TYPE)
    end

    self.close_btn = container:getChildByName("close_btn")
    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("返回"))

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))

    self.slider = container:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(10, 89)

    self.set_right = container:getChildByName("set_right")
    self.set_left = container:getChildByName("set_left")
    self.set_max = container:getChildByName("set_max")
    self.set_value = container:getChildByName("set_value")

    self.guess_max_title = container:getChildByName("guess_max_title")

    self.guess_value = container:getChildByName("guess_value")
    self.get_value = container:getChildByName("get_value")
    self.guess_role = container:getChildByName("guess_role")

    self.edit_content = createEditBox(container, PathTool.getResFrame("common","common_99998"),cc.size(130,41), Config.ColorData.data_color4[175], 26, Config.ColorData.data_color4[175], 26, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content:setAnchorPoint(cc.p(0.5,0.5))
    self.edit_content:setPosition(cc.p(270, 242))

    local begin_change_label = false
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if begin_change_label then  
                begin_change_label = false
                self.set_value:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" and str ~= self.input_text then
                    local num = tonumber(str)
                    if num ~= nil and num >= 0 then
                        self:showEditNum(num)
                    else
                        self:showEditNum(self.cur_set_value)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:showEditNum(self.cur_set_value)
                end 

            end
        elseif strEventName == "began" then
            if not begin_change_label then
                self.set_value:setVisible(false)
                begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    self.edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function ArenaChampionGuessWindow:register_event()
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            ArenaController:getInstance():openArenaChampionGuessWindow(false) 
        end
    end)
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.data then
                if self.view_type == ArenaConst.champion_type.normal then
                    self.ctrl:requestBetTheMatch(self.data.bet_type, self.cur_set_value)
                else
                    self.ctrl:sender26204(self.data.bet_type, self.cur_set_value)
                end
            end
        end
    end)
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            ArenaController:getInstance():openArenaChampionGuessWindow(false) 
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            ArenaController:getInstance():openArenaChampionGuessWindow(false) 
        end
    end)
    self.set_left:addTouchEventListener(function(sender, event_type) --减少
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                local target_value = self.cur_set_value - self.guess_coin
                if target_value < 0 then
                    target_value = 0
                end
                self:setGuessValue(target_value)
                self:setSliderPercent()
            end
        end
    end)
    self.set_right:addTouchEventListener(function(sender, event_type) --增加
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                local target_value = self.cur_set_value + self.guess_coin
                if target_value > self.can_bet then
                    target_value = self.can_bet
                end
                self:setGuessValue(target_value)
                self:setSliderPercent()
            end
        end
    end)
    self.set_max:addTouchEventListener(function(sender, event_type) --最大
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                self:setGuessValue(self.can_bet)
                self:setSliderPercent()
            end
        end
    end)
    if self.slider ~= nil then
        self.slider:addEventListener(function ( sender,event_type )
            if event_type == ccui.SliderEventType.percentChanged then
                self:setCurGuessValueByPercent()
            end
        end)
    end
end

-- 根据滑块的百分比设置竞猜值
function ArenaChampionGuessWindow:setCurGuessValueByPercent(  )
    if not self.slider then return end
    local percent = self.slider:getPercent()
    local cur_val = math.floor(self.can_bet*percent/100)
    self:setGuessValue(cur_val)
end

-- 根据数值设置滑块位置
function ArenaChampionGuessWindow:setSliderPercent(  )
    if self.cur_set_value then
        local percent = (self.cur_set_value/self.can_bet)*100
        self.slider:setPercent(percent)
    end
end

-- 键盘输入数字
function ArenaChampionGuessWindow:showEditNum( num )
    if num < 0 then
        num = 0
    elseif num > self.can_bet then
        num = self.can_bet
    end
    self:setGuessValue(num)
    self:setSliderPercent()
end

function ArenaChampionGuessWindow:setGuessValue(target_value)
    if self.data == nil then return end
    self.cur_set_value = target_value
    self.set_value:setString(target_value)
    local get_value = math.floor( self.cur_set_value * self.guess_times )
    self.get_value:setString(get_value)

    self.guess_max_title:setVisible(self.cur_set_value >= self.guess_max)
end

function ArenaChampionGuessWindow:openRootWnd(data)

    -- 单次押注上限
    if self.view_type == ArenaConst.champion_type.normal then
        local max_config = Config.ArenaChampionData.data_const.guess_limit
        if max_config then
            self.guess_max = max_config.val
        end

        -- 每次押注增量
        local guess_config = Config.ArenaChampionData.data_const.guess_coin
        if guess_config then
            self.guess_coin = guess_config.val
        end
    else
        local max_config = Config.ArenaClusterChampionData.data_const.guess_limit
        if max_config then
            self.guess_max = max_config.val
        end

        -- 每次押注增量
        local guess_config = Config.ArenaClusterChampionData.data_const.guess_coin
        if guess_config then
            self.guess_coin = guess_config.val
        end
    end

    if data then
        local bet_ratio = data.bet_ratio or 2000
        self.guess_times = bet_ratio * 0.001
        self.data = data
        self.guess_value:setString(data.can_bet)
        self.guess_role:setString(data.name)

        self.can_bet = data.can_bet     -- 可押注的数量,如果拥有的大于单次可押注的那么当前最大押注就是单次上限
        if self.guess_max <= data.can_bet then
            self.can_bet = self.guess_max
        end

        if self.can_bet < self.guess_coin then
            self.cur_set_value = 0
            self.set_value:setString(0)
            self.set_left:setTouchEnabled(false)
            self.set_right:setTouchEnabled(false)
            self.set_max:setTouchEnabled(false)
        else
            self:setGuessValue(self.guess_coin)
        end
        self:setSliderPercent()
    end
end

function ArenaChampionGuessWindow:close_callback()
    ArenaController:getInstance():openArenaChampionGuessWindow(false) 
end