--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-20 20:53:38
-- @description    : 
		-- 先知殿召唤
---------------------------------
local controller = SeerpalaceController:getInstance()
local model = controller:getModel()

SeerpalaceSummonPanel = class("SeerpalaceSummonPanel", function()
    return ccui.Widget:create()
end)

function SeerpalaceSummonPanel:ctor(  )
	self.summon_list = {}
    self.summon_pos = {}
    self.is_playing = false -- 是否正在播放召唤特效

	self:configUI()
	self:register_event()
end

function SeerpalaceSummonPanel:addToParent( status )
	status = status or false
    self:setVisible(status)
end

function SeerpalaceSummonPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("seerpalace/seerpalace_summon_panel"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    -- 预加载音效
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_xianzhizhaohuan')

    local main_container = self.root_wnd:getChildByName("main_container")

    self.pos_npc = main_container:getChildByName("pos_npc")
    self.pos_ball = main_container:getChildByName("pos_ball")
    
    self.btn_summon = main_container:getChildByName("btn_summon")
    local btn_size = self.btn_summon:getContentSize()
    self.btn_summon_label = createRichLabel(30, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.btn_summon:addChild(self.btn_summon_label)
    
    -- NPC
    self:handleNPCEffect(true)
    -- 水晶球（常驻）
    self:handleBallEffect(true)

    for i=1,4 do
        local pos_node = main_container:getChildByName("pos_node_" .. i)
        if pos_node then
            delayRun(pos_node, i*3/60, function ( )
                local summon_icon = self.summon_list[i]
                if not summon_icon then
                    summon_icon = SeerpalaceSummonItem.new(handler(self, self._onClickSummonCard))
                    pos_node:addChild(summon_icon)
                    self.summon_list[i] = summon_icon
                end
                summon_icon:setIndex(i)
            end)
            self.summon_pos[i] = pos_node
        end
    end

    self:updateSummonBtnLabel()
end

-- 点击了卡牌
function SeerpalaceSummonPanel:_onClickSummonCard( card )
    if self.is_playing then return end -- 播放召唤特效中不让切换选择卡牌
    if self.select_card then
        self.select_card:setSelectStatus(false)
    end
    if card then
        self.select_card = card
        self.select_card:setSelectStatus(true)
    end
    self:updateSummonBtnLabel()
end

-- NPC特效
function SeerpalaceSummonPanel:handleNPCEffect( status )
    if status == false then
        if self.npc_effect then
            self.npc_effect:clearTracks()
            self.npc_effect:removeFromParent()
            self.npc_effect = nil
        end
    else
        if not tolua.isnull(self.pos_npc) and self.npc_effect == nil then
            self.npc_effect = createEffectSpine(Config.EffectData.data_effect_info[630], cc.p(0, -105), cc.p(0.5, 0.5), true, PlayerAction.action_1, handler(self, self._onNPCAniCallBack))
            self.npc_ani_status = 1 -- 标识当前npc的动作类型
            self.pos_npc:addChild(self.npc_effect)
        end
    end
end

-- 水晶球特效
function SeerpalaceSummonPanel:handleBallEffect( status )
    if status == false then
        if self.ball_effect then
            self.ball_effect:clearTracks()
            self.ball_effect:removeFromParent()
            self.ball_effect = nil
        end
    else
        if not tolua.isnull(self.pos_ball) and self.ball_effect == nil then
            self.ball_effect = createEffectSpine(Config.EffectData.data_effect_info[631], cc.p(4, 1), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.pos_ball:addChild(self.ball_effect)
        end
    end
end

-- 水晶球召唤特效
function SeerpalaceSummonPanel:handleSummonEffect( status )
    if status == false then
        if self.summon_effect then
            self.summon_effect:clearTracks()
            self.summon_effect:removeFromParent()
            self.summon_effect = nil
        end
    else
        if not tolua.isnull(self.pos_ball) and self.summon_effect == nil then
            self.summon_effect = createEffectSpine(Config.EffectData.data_effect_info[632], cc.p(4, 1), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self._onSummonAniCallBack))
            self.pos_ball:addChild(self.summon_effect)
        elseif self.summon_effect then
            self.summon_effect:setToSetupPose()
            self.summon_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

-- 水晶球召唤特效完毕再请求召唤协议
function SeerpalaceSummonPanel:_onSummonAniCallBack(  )
    local group_id = self.select_card:getSummonGroupId()
    controller:requestSeerpalaceSummon(group_id)
    self.is_playing = false
end

-- npc的召唤特效播放完再请求召唤协议
function SeerpalaceSummonPanel:_onNPCAniCallBack(  )
    if self.npc_effect and self.npc_ani_status == 2 then
        self.npc_effect:setAnimation(0, PlayerAction.action_1, true)
        self.npc_ani_status = 1
    end
end

function SeerpalaceSummonPanel:register_event(  )
    registerButtonEventListener(self.btn_summon, handler(self, self._onClickSummonBtn), true)
end

-- 点击召唤
function SeerpalaceSummonPanel:_onClickSummonBtn(  )
    if self.is_playing then return end
    if self.select_card then
        local summon_cost = self.select_card:getSummonCostItem()
        if summon_cost then
            local bid = summon_cost[1]
            local num = summon_cost[2]

            local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
            -- 背包物品足够则先播放召唤特效再请求召唤协议，不足则直接请求协议（弹出物品来源和提示）
            if have_num >= num and self.npc_effect then
                self.npc_ani_status = 2
                self.is_playing = true
                self.npc_effect:setAnimation(0, PlayerAction.action_2, false)
                self:handleSummonEffect(true)
                playOtherSound("c_xianzhizhaohuan")
            else
                local group_id = self.select_card:getSummonGroupId()
                controller:requestSeerpalaceSummon(group_id)
            end
        end
    else
        message("请先选择一种卡牌")
    end
end

-- 刷新召唤按钮文字显示
function SeerpalaceSummonPanel:updateSummonBtnLabel(  )
    if self.select_card then
        local summon_cost = self.select_card:getSummonCostItem()
        if summon_cost then
            local bid = summon_cost[1]
            local num = summon_cost[2]

            local item_config = Config.ItemData.data_get_data(bid)
            if item_config then
                self.btn_summon_label:setString(string.format(TI18N("<img src='%s' scale=0.3 /><div outline=2,#4a2606>%d 召唤</div>"), PathTool.getItemRes(item_config.icon), num))
            end
        end
    else
        self.btn_summon_label:setString(TI18N("<div outline=2,#4a2606>召唤</div>"))
    end
end

function SeerpalaceSummonPanel:DeleteMe(  )
    self:handleNPCEffect(false)
    self:handleBallEffect(false)
    self:handleSummonEffect(false)
    for _,summon_item in pairs(self.summon_list) do
        summon_item:DeleteMe()
        summon_item = nil
    end
end

---------------------------@ item
SeerpalaceSummonItem = class("SeerpalaceSummonItem", function()
    return ccui.Widget:create()
end)

function SeerpalaceSummonItem:ctor(callback)
    self._clickCallBack = callback

    self._is_select = false -- 是否选中了
    self:configUI()
    self:register_event()
end

function SeerpalaceSummonItem:configUI(  )
    self.size = cc.size(180, 196)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("seerpalace/seerpalace_summon_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.effect_node = container:getChildByName("effect_node")
    self.summon_layer = container:getChildByName("summon_layer")
    self.check_layer = container:getChildByName("check_layer")
end

function SeerpalaceSummonItem:setIndex( index )
    self.index = index

    local group_id = SeerpalaceConst.Index_To_GroupId[index]
    local config = Config.RecruitHighData.data_seerpalace_data[group_id]
    if config and config.item_once then
        self.summon_cost = config.item_once[1] -- 召唤所需道具id和数量
        self.group_id = group_id

        local effect_id = SeerpalaceConst.Book_EffectId[group_id]
        local effect_pos = SeerpalaceConst.Effect_Pos[group_id]
        if effect_id and effect_pos and effect_id ~= 0 then
            self:handleCardEffect(true, effect_id, effect_pos)
        end
    end

    -- 引导需要
    self.summon_layer:setName("guide_card_" .. index)
end

-- 获取召唤所需道具id和数量
function SeerpalaceSummonItem:getSummonCostItem(  )
    return self.summon_cost
end

-- 获取先知殿配置的组id
function SeerpalaceSummonItem:getSummonGroupId(  )
    return self.group_id
end

-- 卡牌特效
function SeerpalaceSummonItem:handleCardEffect( status, effect_id, effect_pos )
    if status == false then
        if self.card_effect then
            self.card_effect:clearTracks()
            self.card_effect:removeFromParent()
            self.card_effect = nil
        end
    else
        if not tolua.isnull(self.effect_node) and self.card_effect == nil then
            self.card_effect = createEffectSpine(Config.EffectData.data_effect_info[effect_id], effect_pos, cc.p(0.5, 0.5), true, PlayerAction.action_1)
            self.effect_node:addChild(self.card_effect)
        end
    end
end

function SeerpalaceSummonItem:register_event(  )
    registerButtonEventListener(self.check_layer, handler(self, self._onClickCheckLayer))
    registerButtonEventListener(self.summon_layer, handler(self, self._onClickSummonLayer))
end

-- 点击查看
function SeerpalaceSummonItem:_onClickCheckLayer(  )
    if self.index then
        controller:openSeerpalacePreviewWindow(true, self.index)
    end
end

-- 点击选中
function SeerpalaceSummonItem:_onClickSummonLayer(  )
    if self._is_select == false then
        if self._clickCallBack then
            self:_clickCallBack(self)
        end
    end
end

function SeerpalaceSummonItem:setSelectStatus( status )
    if status == true then
        self.summon_layer:setPositionY(30)
        self.check_layer:setPositionY(30)
        self.card_effect:setAnimation(0, PlayerAction.action_2, true)
        self.card_effect:setToSetupPose()
    else
        self.summon_layer:setPositionY(0)
        self.check_layer:setPositionY(0)
        self.card_effect:setAnimation(0, PlayerAction.action_1, true)
        self.card_effect:setToSetupPose()
    end
    self._is_select = status
end

function SeerpalaceSummonItem:DeleteMe(  )
    self:handleCardEffect(false)
    self.container:stopAllActions()
    self:removeAllChildren()
    self:removeFromParent()
end