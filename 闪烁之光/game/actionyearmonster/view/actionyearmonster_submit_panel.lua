-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: lwc(必填, 创建模块的人员)
-- @editor: lwc(必填, 后续维护以及修改的人员)
-- @description:
--      提交祭品
-- <br/>2020年1月7日
ActionyearmonsterSubmitPanel = ActionyearmonsterSubmitPanel or BaseClass(BaseView)

local controller = ActionyearmonsterController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local _table_remove = table.remove

function ActionyearmonsterSubmitPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionyearmonster", "actionyearmonster_ch"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/actionyearmonster","actionyearmonster_submit_bg"), type = ResourcesType.single }
    }
    self.layout_name = "actionyearmonster/actionyearmonster_submit_panel"

    self.role_vo = RoleController:getInstance():getRoleVo()
    --贡品id
    self.holiday_nian_tribute_id = 80351
    local config  = Config.HolidayNianData.data_const.holiday_nian_tribute_id
    if config then
        self.holiday_nian_tribute_id = config.val
    end
    self.vertical_array = Array.New()
    self.have_count = 0
end

function ActionyearmonsterSubmitPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.panel_bg = self.main_panel:getChildByName("panel_bg")
    local path = PathTool.getPlistImgForDownLoad("bigbg/actionyearmonster","actionyearmonster_submit_bg")
    loadSpriteTexture(self.panel_bg, path, LOADTEXT_TYPE)

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("凶狠的年兽"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.rule_btn = self.main_panel:getChildByName("rule_btn")
    self.item_btn = self.main_panel:getChildByName("item_btn")
    self.item_icon = self.item_btn:getChildByName("img")
    self.item_icon:setScale(0.9)
    self.item_count = self.item_btn:getChildByName("count")

    self.item_config = Config.ItemData.data_get_data(self.holiday_nian_tribute_id)
    if self.item_config then
        loadSpriteTexture(self.item_icon, PathTool.getItemRes(self.item_config.icon), LOADTEXT_TYPE)
    end

    self.challenge_btn = self.main_container:getChildByName("challenge_btn")
    self.challenge_btn:getChildByName("label"):setString(TI18N("提交贡品"))

    local progress_container = self.main_container:getChildByName("progress_container")
    self.progress_container = progress_container
    self.progress = progress_container:getChildByName("progress")
    self.hp_value = progress_container:getChildByName("hp_value")
    -- self.progress:setScale9Enabled(true)
    local progress_container_size = progress_container:getContentSize()


    local box_reward_list = Config.HolidayNianData.data_redbag_progress
    if box_reward_list and next(box_reward_list) ~= nil then
        self.box_list = {}
        table_sort( box_reward_list, function(a, b) return a < b end )
        local max_num = box_reward_list[#box_reward_list]
        self.max_num = max_num
        local len = progress_container_size.width/ max_num
        for i,num in ipairs(box_reward_list) do
            if i >= #box_reward_list then break end
            local box_item = {}
            local x = len * num - 5
            -- local res_id = PathTool.getEffectRes(config.effect_id or 110)
            -- local box = createEffectSpine(res_id, cc.p( x, 8), cc.p(0.5, 0.5), true, PlayerAction.action_1)
            -- progress_container:addChild(box)
            -- box_item.box = box
            box_item.sprite = createSprite(PathTool.getResFrame("actionyearmonster_ch","actionyearmonster_ch_13"), x, 23, progress_container, cc.p(0.5,0.5))
            box_item.lable = createLabel(22, cc.c4b(0xff,0xea,0xab,0xff), cc.c4b(0x9f,0x30,0x1b,0xff), x, -10, num, progress_container, 2, cc.p(0.5,0.5))
            box_item.per = num * 100/max_num
            box_item.is_show_redbag = false

            -- box_item.btn = createButton(progress_container,"", x, progress_container_size.height * 0.5, cc.size(52, 70), PathTool.getResFrame("common", "common_99998"))
            -- box_item.btn:addTouchEventListener(function(sender, event_type)
            --     if event_type == ccui.TouchEventType.ended then
            --         self:onClickBoxBtn(config, sender:getTouchBeganPosition())
            --     end
            -- end)
            -- box_item.config = config
            -- local pos = progress_container:convertToWorldSpace(cc.p(x,progress_container_size.height * 0.5))
            -- local newpos = self.root_wnd:convertToNodeSpace(pos)
            -- box_item.pos = newpos
            self.box_list[i] = box_item
            -- self.box_list[config.num] = box_item
        end
    end


    self.tips = self.main_container:getChildByName("tips")
    self.tips:setString(TI18N("全服收集提交贡品, 召唤限时年兽和红包雨"))
end

function ActionyearmonsterSubmitPanel:register_event(  )
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    -- registerButtonEventListener(self.item_btn, handler(self, self.onClickItemBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.rule_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.challenge_btn, handler(self, self.onClickChallengeBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    --提交祭品成功
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Submit_item_Event, function(data)
        self:showEffect(true, "eating")
    end)
    --28200信息
    self:addGlobalEvent(ActionyearmonsterEvent.YEAR_MONSTER_BASE_INFO, function(data)
        self:updateShowMoveVertical(data)
        self.base_data = data
       
        self:updateProgress()
        self:updateItemCount()
    end)


    if self.role_assets_event == nil then
        if self.role_vo then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS,function(key ,value) 
                if key == self.holiday_nian_tribute_id then
                    self:updateItemCount()
                end
            end)
        end
    end
end

-- 关闭
function ActionyearmonsterSubmitPanel:onClickCloseBtn(  )
    controller:openActionyearmonsterSubmitPanel(false)
end


-- 道具
function ActionyearmonsterSubmitPanel:onClickItemBtn(  )
    
end

-- 提交祭品
function ActionyearmonsterSubmitPanel:onClickChallengeBtn(  )
    if not self.base_data then return end
    if not self.role_vo then return end
    --可提交的数量
    local count = self.base_data.max_val - self.base_data.val

    if count == 0 then
        message(TI18N("年兽已召唤, 请在年兽沉睡后再试"))
        return
    end

    --拥有的数量
    local have_count = self.role_vo:getActionAssetsNumByBid(self.holiday_nian_tribute_id)
    if have_count > count then
        have_count = count
    end
    if have_count == 0 then
        if self.item_config then
            message(self.item_config.name..TI18N("数量不足!"))
        else
            message(TI18N("贡品数量不足!"))
        end
        return
    end
    self.have_count = have_count
    controller:sender28211(have_count)
end

function ActionyearmonsterSubmitPanel:updateItemCount()
    if self.role_vo then
        local count = self.role_vo:getActionAssetsNumByBid(self.holiday_nian_tribute_id)
        self.item_count:setString("x"..count)

        if self.base_data and self.base_data.val < self.base_data.max_val and count > 0  then
            addRedPointToNodeByStatus(self.challenge_btn, true, 0, 5)
        else
            addRedPointToNodeByStatus(self.challenge_btn, false, 0, 5)
        end
    else
        self.item_count:setString("x0")
    end
end

function ActionyearmonsterSubmitPanel:openRootWnd(setting)
    local setting = setting or {}
    self.base_data = setting.base_data 
    if not self.base_data then return end

    self:updateProgress()
    self:updateItemCount()

    if self.base_data.val >= self.base_data.max_val then
        self:showEffect(true, PlayerAction.stand)
        self.tips:setString(TI18N("限时年兽已苏醒，前往挑战获取丰厚奖励！"))
    else
        self:showEffect(true)
        self.tips:setString(TI18N("全服收集提交贡品, 召唤限时年兽和红包雨"))
    end
end

-- 打开规则说明
function ActionyearmonsterSubmitPanel:onClickRuleBtn( param, sender, event_type )
    local rule_cfg = Config.HolidayNianData.data_const["holiday_nian_tribute_desc"]
    if rule_cfg then
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    end
end

function ActionyearmonsterSubmitPanel:updateProgress()
    if not self.base_data then return end
    local per =  self.base_data.val * 100/self.base_data.max_val
    self.progress:setPercent(per)
    self.hp_value:setString(string_format("%s/%s", self.base_data.val, self.base_data.max_val))

    if self.is_init_per == nil then
        self.is_init_per = true
        for i,v in ipairs(self.box_list) do
            local num = math.floor(self.base_data.max_val * v.per/100)
            v.lable:setString(num)    
            if per > v.per then
                v.is_show_redbag = true
            else
                v.lable:disableEffect(cc.LabelEffect.OUTLINE)
                setChildUnEnabled(true, v.lable)    
                setChildUnEnabled(true, v.sprite)    
            end
        end    
    else
        for i,v in ipairs(self.box_list) do
            if per > v.per and not v.is_show_redbag  then
                -- self:showRedBagEffect()
                v.is_show_redbag = true
                v.lable:disableEffect(cc.LabelEffect.OUTLINE)
                v.lable:enableOutline(cc.c4b(0x64,0x32,0x23,0xff), 2)
                setChildUnEnabled(false, v.lable)    
                setChildUnEnabled(false, v.sprite)
            end
        end    
    end

end

--年兽spine
function ActionyearmonsterSubmitPanel:showEffect(bool, action)
    if bool == true then
        local action = action or "sleeping"
        if self.play_effect == nil then
            self.play_effect = createEffectSpine("E28002", cc.p(347,467), cc.p(0.5, 0.5), true, action, function()
                self:endEffect()
            end)
            self.main_container:addChild(self.play_effect, 1)
        else
            
            if action == "eating" then
                self.is_show_eat = true
                self.play_effect:setAnimation(0, action, false)
            else
                self.play_effect:setAnimation(0, action, true)
            end
            
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

--结束一次特效
function ActionyearmonsterSubmitPanel:endEffect()
    if self.is_show_eat then
        self.is_show_eat = false
        self:showEffect(true)
    end
end


function ActionyearmonsterSubmitPanel:updateShowMoveVertical(data)
    if self.base_data then
        local itemName = ""
        if self.item_config then
            itemName = self.item_config.name
        end
        local addNum = data.val-self.base_data.val
        local tempArr = {string_format(TI18N("消耗<div fontcolor=#ff91f6 fontsize=22 >%s</div>×%d"), itemName,self.have_count),
        string_format(TI18N("进度值<div fontcolor=#84e766 fontsize=22 >+%s</div>"),addNum)}

        for k,v in pairs(tempArr) do
            self:showMoveVertical(v)
        end
        self:crateLabelEffect(addNum)
    end
end

function ActionyearmonsterSubmitPanel:crateLabelEffect(num)
    if self.label_list == nil then
        self.label_list = {}
    end
    local label = nil
    if #self.label_list > 0 then
        label = _table_remove(self.label_list)
        label:setVisible(true)
        label:setString("+"..num)
    else
        label = createLabel(50, cc.c4b(0xff,0xcf,0x3c,0xff),cc.c4b(0xb0,0x35,0x0a,0xff),0, 0,"+"..num ,self.progress_container,2, cc.p(0.5,0.5), "fonts/title.ttf")
    end
    if label then
        label:setPosition(210, 20)    
        label:setOpacity(0)
        local action1 = cc.FadeIn:create(0.2)
        local delay = cc.DelayTime:create(0.5)
        local action2 = cc.FadeOut:create(0.5)
        local sequence = cc.Sequence:create(action1,delay,action2, cc.CallFunc:create(function()
            label:setVisible(false)
            table_insert(self.label_list, label)
        end))

        local moveto = cc.EaseSineOut:create(cc.MoveTo:create(0.8, cc.p(210, 53)))
        local spawn = cc.Spawn:create(moveto,sequence)

        label:runAction(spawn)
    end
end

--==============================--
--desc:竖直向上渐变小时的，最多同时显示3个
--==============================--
function ActionyearmonsterSubmitPanel:showMoveVertical(msg)
	local parent_wnd = self.main_container
	if string.len(msg) == 0 then return end
	
	--容器
	local container = ccui.Widget:create()
	container:setCascadeOpacityEnabled(true)
	container:setAnchorPoint(cc.p(0.5, 0))
	parent_wnd:addChild(container, 10)
	
	--背景
	local image = createScale9Sprite(PathTool.getResFrame("actionyearmonster_ch", "actionyearmonster_ch_19"))
	image:setScale9Enabled(true)
	image:setContentSize(cc.size(258, 44))
	container.image = image
	container:addChild(image)
	
	--文本
	local temp_msg = string_format("<div fontcolor=#ffd473 fontsize=22 >%s</div>", msg)
	local label = self:createhorizontalLabel(temp_msg, Config.ColorData.data_color3[1], 258, 22)
	label:setAnchorPoint(0.5, 0.5)
	container:addChild(label)
	
	local label_size = label:getSize()
	local max_width = 258
	local max_height = math.max(label_size.height + 20, image:getContentSize().height)
	local size = cc.size(max_width, max_height)
	container:setContentSize(size)
	image:setPosition(cc.p(size.width / 2, size.height / 2))
	label:setPosition(cc.p(size.width / 2, size.height / 2))
	
	--剔除当前的数据和ui
	local function deleteMessage()
		local temp_data = self.vertical_array:PopFront()
		local item = temp_data["item"]
		doRemoveFromParent(item)
	end
	local delay = 2 --self.delay
	self.vertical_array:PushBack({msg = msg, delay_time = delay, item = container})
	self:sortPosition()
	delayRun(container.image, delay, function()
		deleteMessage()
	end)
end

--创建水平方向移动的文本
function ActionyearmonsterSubmitPanel:createhorizontalLabel(msg, color, max_width, fontsize)
	local fontcolor = color or Config.ColorData.data_color3[2]
	local label = createRichLabel(fontsize, fontcolor, cc.p(0, 1), cc.p(0, 0), 0, 0, max_width)
	label:setString(msg)
	return label
end

-- 排列位置
function ActionyearmonsterSubmitPanel:sortPosition()
	local offset = 0 --偏移
	local max_height = 0 --最大的高度
	local size = self.vertical_array:GetSize()
	if size > 0 then
		local _y = self.main_container:getContentSize().height/10*7         -- 往上提一点
		local _x = SCREEN_WIDTH / 2
		local last_height = self.vertical_array:Get(size - 1).item:getContentSize().height
		local last_y
		for i = self.vertical_array:GetSize(), 1, - 1 do
			local data = self.vertical_array:Get(i - 1)
			local item = data.item
			if tolua.isnull(item) then return end
            doStopAllActions(item)
			if size == i then
				item:setPosition(cc.p(_x, _y))
				last_y = _y + item:getContentSize().height +i*3
			else
				item:setPosition(cc.p(_x, last_y))
				last_y = last_y + item:getContentSize().height +i*3
			end
			item.action = item:runAction(cc.MoveBy:create(0.5, cc.p(0, last_height)))
		end
	end
end

function ActionyearmonsterSubmitPanel:close_callback(  )
    self:showEffect(false)

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    -- if self.item_load then
    --     self.item_load:DeleteMe()
    -- end
    -- self.item_load = nil

    -- if self.item_load_icon then
    --     self.item_load_icon:DeleteMe()
    -- end
    -- self.item_load_icon = nil

    -- if self.item_load_bg then
    --     self.item_load_bg:DeleteMe()
    -- end
    -- self.item_load_bg = nil

    -- if self.item_list then
    --     for i,v in pairs(self.item_list) do
    --         v:DeleteMe()
    --     end
    --     self.item_list = nil
    -- end

    controller:openActionyearmonsterSubmitPanel(false)
end
