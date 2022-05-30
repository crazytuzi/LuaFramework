-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      巅峰冠军赛竞猜界面
-- <br/>2019年11月19日
--
-- --------------------------------------------------------------------
ArenapeakchampionGuessCountPanel = ArenapeakchampionGuessCountPanel or BaseClass(BaseView)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local string_format = string.format

function ArenapeakchampionGuessCountPanel:__init(view_type)
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.win_type = WinType.Mini
    self.is_full_screen = false
    self.layout_name = "arenapeakchampion/arenapeakchampion_guess_count_panel"

    self.res_list = {
    -- {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
    }

    -- self.view_type = view_type or ArenaConst.champion_type.normal
    self.cur_set_value = 0
    self.guess_coin = 10
    self.can_bet = 300
    self.guess_max = 300 --猜测上限

    self.guess_coin_item_id = 33
end 

function ArenapeakchampionGuessCountPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("竞猜"))
    container:getChildByName("set_title"):setVisible(false)
    container:getChildByName("Image_1"):setVisible(false)
    container:getChildByName("Image_4"):setVisible(false)
    container:getChildByName("can_get_title"):setString(TI18N("猜中可能赢得："))

    local item_config = Config.ItemData.data_get_data(self.guess_coin_item_id)
    if item_config then
        local sprite_1 = container:getChildByName("Sprite_1")
        sprite_1:setVisible(false)
        local sprite_2 = container:getChildByName("Sprite_2")
        -- loadSpriteTexture(sprite_1, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
        loadSpriteTexture(sprite_2, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    end
    


    self.close_btn = container:getChildByName("close_btn")
    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("返回"))

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))

    self.slider = container:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(9, 91)

    self.set_right = container:getChildByName("set_right")
    self.set_left = container:getChildByName("set_left")
    self.set_max = container:getChildByName("set_max")
    self.set_value = container:getChildByName("set_value")
    self.guess_max_title = container:getChildByName("guess_max_title")

    self.slider:setVisible(false)
    self.set_right:setVisible(false)
    self.set_left:setVisible(false)
    self.set_max:setVisible(false)
    self.set_value:setVisible(false)
    self.guess_max_title:setVisible(false)

    self.get_value = container:getChildByName("get_value")
    self.get_value:setString("0")
    self.guess_count = container:getChildByName("guess_count")
    self.guess_count:setString("")

    self.guess_title = createRichLabel(26, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(312,306),nil,nil,1000)
    container:addChild(self.guess_title)
    self.tips = createRichLabel(26, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(312,260),nil,nil,1000)
    container:addChild(self.tips)
    self.tips:setString(TI18N("(支持后竞猜选择将不可更改)"))

    -- self.edit_content = createEditBox(container, PathTool.getResFrame("common","common_99998"),cc.size(130,41), Config.ColorData.data_color4[175], 26, Config.ColorData.data_color4[175], 26, "", nil, nil, LOADTEXT_TYPE_PLIST)
    -- self.edit_content:setAnchorPoint(cc.p(0.5,0.5))
    -- self.edit_content:setPosition(cc.p(242, 259))

    -- local begin_change_label = false
    -- local function editBoxTextEventHandle(strEventName,pSender)
    --     if strEventName == "return" or strEventName == "ended" then
    --         if begin_change_label then  
    --             begin_change_label = false
    --             self.set_value:setVisible(true)
    --             local str = pSender:getText()
    --             pSender:setText("")  
    --             if str ~= "" and str ~= self.input_text then
    --                 local num = tonumber(str)
    --                 if num ~= nil and num >= 0 then
    --                     self:showEditNum(num)
    --                 else
    --                     self:showEditNum(self.cur_set_value)
    --                     message(TI18N("请输入数字"))
    --                 end
    --             else
    --                 self:showEditNum(self.cur_set_value)
    --             end 

    --         end
    --     elseif strEventName == "began" then
    --         if not begin_change_label then
    --             self.set_value:setVisible(false)
    --             begin_change_label = true
    --         end
    --     elseif strEventName == "changed" then

    --     end
    -- end
    -- self.edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function ArenapeakchampionGuessCountPanel:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)

    --确定
    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.cur_set_value <= 0 then
                message(TI18N("代币不足"))
                return
            end
            if self.data then
                controller:sender27704(self.bet_type, self.cur_set_value)
            end
        end
    end)

    -- self.set_left:addTouchEventListener(function(sender, event_type) --减少
    --     customClickAction(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         if self.data then
    --             local target_value = self.cur_set_value - self.guess_coin
    --             if target_value < 0 then
    --                 target_value = 0
    --             end
    --             self:setGuessValue(target_value)
    --             self:setSliderPercent()
    --         end
    --     end
    -- end)
    -- self.set_right:addTouchEventListener(function(sender, event_type) --增加
    --     customClickAction(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         if self.data then
    --             local target_value = self.cur_set_value + self.guess_coin
    --             if target_value > self.can_bet then
    --                 target_value = self.can_bet
    --             end
    --             self:setGuessValue(target_value)
    --             self:setSliderPercent()
    --         end
    --     end
    -- end)
    -- self.set_max:addTouchEventListener(function(sender, event_type) --最大
    --     customClickAction(sender, event_type)
    --     if event_type == ccui.TouchEventType.ended then
    --         playButtonSound2()
    --         if self.data then
    --             self:setGuessValue(self.can_bet)
    --             self:setSliderPercent()
    --         end
    --     end
    -- end)
    -- if self.slider ~= nil then
    --     self.slider:addEventListener(function ( sender,event_type )
    --         if event_type == ccui.SliderEventType.percentChanged then
    --             self:setCurGuessValueByPercent()
    --         end
    --     end)
    -- end
end

function ArenapeakchampionGuessCountPanel:onClickCloseBtn()
    controller:openArenapeakchampionGuessCountPanel(false)
end

-- 根据滑块的百分比设置竞猜值
function ArenapeakchampionGuessCountPanel:setCurGuessValueByPercent(  )
    if not self.slider then return end
    local percent = self.slider:getPercent()
    local cur_val = math.floor(self.can_bet*percent/100)
    self:setGuessValue(cur_val)
end

-- 根据数值设置滑块位置
function ArenapeakchampionGuessCountPanel:setSliderPercent(  )
    if self.cur_set_value then
        local percent = (self.cur_set_value/self.can_bet)*100
        self.slider:setPercent(percent)
    end
end

-- 键盘输入数字
function ArenapeakchampionGuessCountPanel:showEditNum( num )
    if num < 0 then
        num = 0
    elseif num > self.can_bet then
        num = self.can_bet
    end
    self:setGuessValue(num)
    self:setSliderPercent()
end

function ArenapeakchampionGuessCountPanel:setGuessValue(target_value)
    if self.data == nil then return end
    self.cur_set_value = target_value
    self.set_value:setString(target_value)
    local get_value = math.floor( self.cur_set_value * self.guess_times )
    self.get_value:setString(get_value)
    self.guess_count:setString(target_value)

    self.guess_max_title:setVisible(self.cur_set_value >= self.guess_max)
end

function ArenapeakchampionGuessCountPanel:openRootWnd(setting)
    local setting = setting or {}
    self.bet_type = setting.bet_type or 1 --押注类型  

    local name = setting.name or ""
    local data = model:getMyGuessData()
    if not data then return end
    -- -- 单次押注上限
    -- local max_config = Config.ArenaPeakChampionData.data_const.guess_limit
    -- if max_config then
    --     self.guess_max = max_config.val
    -- end

    -- -- 每次押注增量
    -- local guess_config = Config.ArenaPeakChampionData.data_const.guess_coin
    -- if guess_config then
    --     self.guess_coin = guess_config.val
    -- end

    if data then
        local bet_ratio = setting.ratio or 2000
        self.guess_times = bet_ratio * 0.001
        self.data = data
        self.can_bet = data.can_bet     -- 可押注的数量,如果拥有的大于单次可押注的那么当前最大押注就是单次上限
        self.cur_set_value = data.can_bet    
        
        local item_config = Config.ItemData.data_get_data(self.guess_coin_item_id)
        if item_config then
            local iconsrc = PathTool.getItemRes(item_config.icon)
            local str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> <div fontcolor=#249003>%s</div> 支持玩家 <div fontcolor=#249003>%s</div>?"), iconsrc, self.cur_set_value, name)
            self.guess_title:setString(str)
        end
        local get_value = math.floor( self.cur_set_value * self.guess_times )
        self.get_value:setString(get_value)
    end
end

function ArenapeakchampionGuessCountPanel:close_callback()
    controller:openArenapeakchampionGuessCountPanel(false) 
end