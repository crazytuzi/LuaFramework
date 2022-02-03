-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:战斗结算主界面]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
-- ActionyearmonsterResultPanel = class("ActionyearmonsterResultPanel", function()
--  return ccui.Layout:create()
-- end)

ActionyearmonsterResultPanel = ActionyearmonsterResultPanel or BaseClass(BaseView)


function ActionyearmonsterResultPanel:__init(fight_type)
    self.win_type = WinType.Tips
    self.layout_name = "battle/battle_result_view"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.effect_list = {}
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("actionyearmonster", "actionyearmonster_result"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("actionwhitedaymonster", "actionwhitedaymonster"), type = ResourcesType.plist },
    }

    self.fight_type = fight_type or BattleConst.Fight_Type.YearMonsterWar
    self.item_list = {}

end

function ActionyearmonsterResultPanel:openRootWnd(data)
    self:setData(data)
end

--初始化
function ActionyearmonsterResultPanel:open_callback()
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
    local offset_y = 80
    local Sprite_3 = self.source_container:getChildByName("Sprite_3")
    local Sprite_4 = self.source_container:getChildByName("Sprite_4")
    self.Sprite_2:setPositionY(self.Sprite_2:getPositionY() - offset_y)
    Sprite_3:setPositionY(Sprite_3:getPositionY() - offset_y)
    Sprite_4:setPositionY(Sprite_4:getPositionY() - offset_y)

    --年兽进度条
    self.actionyearmonster_hp_progress = createCSBNote(PathTool.getTargetCSB("actionyearmonster/actionyearmonster_hp_progress"))
    self.actionyearmonster_hp_progress:setPosition(0,315)
    self.source_container:addChild(self.actionyearmonster_hp_progress)
    progress_container = self.actionyearmonster_hp_progress:getChildByName("progress_container")
    self.progress_container = progress_container
    self.progress = progress_container:getChildByName("progress")
    self.progress:setZOrder(4)
    self.hp_count = progress_container:getChildByName("hp_count")
    self.hp_count:setZOrder(4)
    self.box_lev = progress_container:getChildByName("box_lev")
    self.box_lev:setZOrder(4)
    self.progress_box = progress_container:getChildByName("box")
    self.progress_box:setVisible(false)

    local box_bg = progress_container:getChildByName("box_bg")
    box_bg:setZOrder(3)
    local Image_1 = progress_container:getChildByName("Image_1")
    Image_1:setZOrder(3)
    local Image_2 = progress_container:getChildByName("Image_2")
    Image_2:setZOrder(3)

    self.head_panel = progress_container:getChildByName("head_panel")
    self.head_bg = self.head_panel:getChildByName("head_bg")
    self.head_bg_0 = self.head_panel:getChildByName("head_bg_0")

    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 820, "",self.root_wnd, nil, cc.p(0.5,0.5))

    self.time_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5,420 - offset_y), nil, nil, 1000)
    self.time_label:setString(TI18N("10秒后关闭"))
    self.root_wnd:addChild(self.time_label)

    self:createComfirmAndCancelBtn(offset_y)

    self.harm_btn = self.source_container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    local label  = createRichLabel(22,31, cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width/2,688), nil, nil, 1000)
    label:setString(TI18N("获得物品"))
    self.root_wnd:addChild(label)
    local result_line_bg = createSprite(PathTool.getResFrame("common", "common_1094"), self.root_wnd:getContentSize().width / 2 - 40, 688, self.root_wnd, cc.p(0, 0.5))
    result_line_bg:setScaleX(-1)
    local result_line_bg_2 = createSprite(PathTool.getResFrame("common", "common_1094"), self.root_wnd:getContentSize().width / 2 + 40,688, self.root_wnd, cc.p(0, 0.5))
    
    self.scroll_view = createScrollView(SCREEN_WIDTH,250,0,420,self.root_wnd,ccui.ScrollViewDir.vertical)
end

function ActionyearmonsterResultPanel:createComfirmBtn()
    if not self.root_wnd then return end
    self.comfirm_btn = createButton(self.root_wnd,TI18N("确 定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2, 455)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            BattleController:getInstance():openFinishView(false,self.fight_type)
        end
    end)
end
--创建确定和取消按钮
function ActionyearmonsterResultPanel:createComfirmAndCancelBtn(offset_y)
    if not self.root_wnd then return end
    self.comfirm_btn = createButton(self.root_wnd,TI18N("确 定"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.root_wnd:getContentSize().width / 2 - 170, 455 - offset_y)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            ActionyearmonsterController:getInstance():openActionyearmonsterResultPanel(false)
        end
    end)

    self.cancel_btn = createButton(self.root_wnd,TI18N("返回玩法"), 620, 580, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.root_wnd:getContentSize().width / 2 + 170, 455 - offset_y)
    self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            BattleResultReturnMgr:returnByFightType(self.fight_type) --先
            ActionyearmonsterController:getInstance():openActionyearmonsterResultPanel(false)
        end
    end)
end


function ActionyearmonsterResultPanel:register_event()
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function ActionyearmonsterResultPanel:_onClickHarmBtn(  )
    if self.data and next(self.data) ~= nil then
        BattleController:getInstance():openBattleHarmInfoView(true, self.data)
    end
end

--剧情：{章节id,难度，副本id}
function ActionyearmonsterResultPanel:setData(data, fight_type)
    if data then
        self.data = data or {}
        -- self.fight_type = fight_type
        self.reward_list = self.data.item_rewards or {{bid = 1, num = 1}}
        self:rewardViewUI()
        local model = ActionyearmonsterController:getInstance():getModel()
        if self.fight_type == BattleConst.Fight_Type.WhiteDayWar then
            model = ActionController:getInstance():getModel()
            local head_id = model:getWhiteDayHeadId()
            self:setMonsterHead(head_id)
        end
        local harm_count = self.data.all_dps
        local box_count, config, max_high = model:getHarmRewardInfo(harm_count, self.data.type)
        if box_count and box_count > 0 then
            if self.fight_type == BattleConst.Fight_Type.WhiteDayWar then
                if self.progress_light_img == nil then
                    self.progress_light_img = createImage(self.progress, PathTool.getResFrame("actionwhitedaymonster", "actionwhitedaymonster_2"), 0, self.progress:getContentSize().height / 2, cc.p(0.5,0.5), true, 1, true)
                end
                if harm_count > 0 then
                    self.progress_light_img:setVisible(true)
                    self.progress_light_img:setPositionX(self.progress:getContentSize().width * harm_count/config.max)
                else
                    self.progress_light_img:setVisible(false)
                end
                self.progress:setPercent(harm_count*100/config.max)
                self.hp_count:setString(string.format("%s/%s", harm_count, config.max))
            else
                self.progress:setPercent(harm_count*100/config.dps_high)
                self.hp_count:setString(string.format("%s/%s", harm_count, config.dps_high))
            end
            self.box_lev:setString(box_count)
        end
        self:showBoxEffect(true)
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

--boxeffect
function ActionyearmonsterResultPanel:showBoxEffect(bool, action)
    if bool == true then
        local action = PlayerAction.action 
        if self.play_effect1 == nil then
            self.play_effect1 = createEffectSpine("E27705", cc.p(420,21), cc.p(0.5, 0.5), true, action, function() end)
            self.progress_container:addChild(self.play_effect1, 1)
        end    
    else
        if self.play_effect1 then 
            self.play_effect1:setVisible(false)
            self.play_effect1:removeFromParent()
            self.play_effect1 = nil
        end
    end
end

function ActionyearmonsterResultPanel:setMonsterHead(head_id)
    local vSize = self.head_panel:getContentSize()
    self.mask_res = PathTool.getResFrame("common", "common_1032") 
    if self.mask_res ~= nil then
		self.mark_bg = createSprite(self.mask_res,vSize.width/2,vSize.height/2, self.head_panel, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)

		self.mask = createSprite(self.mask_res,vSize.width/2,vSize.height/2, nil, cc.p(0.5, 0.5))

		self.clipNode = cc.ClippingNode:create(self.mask)
		self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
		self.clipNode:setContentSize(vSize)
		self.clipNode:setCascadeOpacityEnabled(true)
		self.clipNode:setPosition(vSize.width/2,vSize.height/2)
		self.clipNode:setAlphaThreshold(0)
		self.head_panel:addChild(self.clipNode,2)

		self.icon = ccui.ImageView:create()
		self.icon:setCascadeOpacityEnabled(true)
		self.icon:setAnchorPoint(0.5,0.5)
		self.icon:setPosition(vSize.width/2,vSize.height/2+2)
		self.clipNode:addChild(self.icon,3)
	else
		self.icon = ccui.ImageView:create()
		self.icon:setCascadeOpacityEnabled(true)
		self.icon:setAnchorPoint(0.5,0.5)
		self.icon:setPosition(vSize.width/2,vSize.height/2+2)
		self.head_panel:addChild(self.icon)
    end
    self.clipNode:setScale(0.9)
    self.head_bg_0:setLocalZOrder(99)
    res = PathTool.getHeadIcon(head_id)
    self.icon:loadTexture(res, LOADTEXT_TYPE)
end

function ActionyearmonsterResultPanel:handleEffect(status)
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
function ActionyearmonsterResultPanel:rewardViewUI()
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
            item:setScale(1.2)
            item:setBaseData(v.bid,v.num)
            local item_config = Config.ItemData.data_get_data(v.bid)
            if item_config then
                item:setGoodsName(item_config.name,nil,nil,1)
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

function ActionyearmonsterResultPanel:ItemAciton()
    if self.item_list and next(self.item_list or {}) ~= nil then
        local show_num = 0
        for i,v in pairs(self.item_list) do
            if v then
                delayRun(self.root_wnd,0.1 * (i - 1),function()
                    v:setVisible(true)
                    v:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.95),cc.CallFunc:create(function ()
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

function ActionyearmonsterResultPanel:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        local str = new_time..TI18N("秒后关闭")
        if self.time_label and not tolua.isnull(self.time_label) then
            self.time_label:setString(str)
        end
        if new_time <= 0 then
            ActionyearmonsterController:getInstance():openActionyearmonsterResultPanel(false)
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "result_timer" .. self.fight_type)
end

--清理
function ActionyearmonsterResultPanel:close_callback()
    -- 移除可能存在的装备tips
    HeroController:getInstance():openEquipTips(false)
    TipsManager:getInstance():hideTips()
    BattleController:getInstance():openFinishView(false,self.fight_type) 
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW,self.fight_type)
    GlobalTimeTicket:getInstance():remove("result_timer" .. self.fight_type)

    ActionyearmonsterController:getInstance():openActionyearmonsterResultPanel(false)
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
