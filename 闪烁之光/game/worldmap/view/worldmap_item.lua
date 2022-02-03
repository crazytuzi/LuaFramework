-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      世界地图的单个剧情副本
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
WorldMapItem =
    class(
    "WorldMapItem",
    function()
        return ccui.Layout:create()
    end
)

-- 119 特效 1、选中未通过 2、选中通过 3、未选中通过 4、未选中未通过

local controller = BattleDramaController:getInstance()
local model = BattleDramaController:getInstance():getModel()

function WorldMapItem:ctor(config,open_data)
    self.config = config
    self.size = cc.size(50, 50)
    self.scale = 4
    self.open_data = open_data
    self:createRootWnd()
end

function WorldMapItem:createRootWnd()
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self.effect = createEffectSpine(PathTool.getEffectRes(119), cc.p(self.size.width*0.5, self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action_4)
    self:addChild(self.effect)

    local res = PathTool.getResFrame("worldmap", "worldmap_1008")
    self.progress_bg = createSprite(res, self.size.width * 0.5,80, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    self.progress_label = createLabel(18, 1, nil, 42, 13, "", self.progress_bg, nil, cc.p(0.5, 0.5))
    local res = PathTool.getResFrame("worldmap", "worldmap_1006")
    local name_bg = createSprite(res, self.size.width * 0.5, -20, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    self.name_label = createLabel(18, 175, nil, self.size.width * 0.5-2, -15, self.config.name, self, nil, cc.p(0.5, 0.5))
    self:registerEvent()
    self:fillData()
end

function WorldMapItem:registerEvent()
    self:setTouchEnabled(true)
    self:addTouchEventListener(function(sender, event_type)
        customClickAction(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.call_back then
                self.call_back()
            end
            
            playButtonSound2()
            -- local max_chapter_id = model:getCurMaxChapterId(self.drama_data.mode)
            -- -- local open_num = math.min(chapter_pass_sum + 1, tableLen(self.config))
            -- if max_chapter_id ~= 1 then
            --     max_chapter_id = max_chapter_id + 1
            -- end
            local max_sum_chapter = model:getOpenSumChapter(self.drama_data.mode)
            if self.drama_data then
                if self.config.bid <=  (max_sum_chapter)  and self.config.bid ~= self.drama_data.chapter_id then
                    -- local chapter_list = model:getChapterListByID(self.drama_data.mode, self.config.bid)
                    -- local max_dun_id = model:getHasPassChapterMaxDunId(self.drama_data.mode, self.config.bid)
                    -- if chapter_list and max_dun_id ~= 0 then --直接切换
                    --     local cur_drama_data = model:getDramaData()
                    --     cur_drama_data.mode = self.drama_data.mode
                    --     cur_drama_data.chapter_id = self.config.bid
                    --     cur_drama_data.dun_id = max_dun_id
                    --     BattleDramaController:getInstance():getModel():setDramaData(cur_drama_data)
                    -- else
                    --     BattleDramaController:getInstance():send13002()
                    -- end
                    -- WorldmapController:getInstance():openWorldMapMainWindow(false)
                    WorldmapController:getInstance():openWorldMapTipsWindow(true,self.config.bid,WorldmapEvent.open_type.open_type_2)
                else
                    if self.config.bid == self.drama_data.chapter_id then
                        -- if self.open_data then
                        --     WorldmapController:getInstance():openWorldMapMainWindow(false)
                        -- else
                        --     message(TI18N("已在当前章节"))
                        -- end
                        WorldmapController:getInstance():openWorldMapTipsWindow(true,self.config.bid,WorldmapEvent.open_type.open_type_1)
                    else
                        -- message(TI18N("前面章节暂没通关"))
                        WorldmapController:getInstance():openWorldMapTipsWindow(true,self.config.bid,WorldmapEvent.open_type.open_type_3)
                    end
                end
            end
           
        end
    end)
    -- if not self.update_effect_event then
    --     self.update_effect_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Drama_Unlock_View,function (data)
    --         if self.config and self.config.bid == data.bid then
    --             WorldmapController:getInstance():openWorldMapMainWindow(false)
    --             --self:showAfterEffect()
    --         end
    --     end)
    -- end

    if not self.update_effect_event then
        self.update_effect_event = GlobalEvent:getInstance():Bind(WorldmapEvent.World_Map_Unlock_item,function ()
            local data = model:getDramaData()
            if self.config and data and self.config.bid == data.chapter_id and self.effect then
                local nil_func = function()
                end
                self.effect:registerSpineEventHandler(nil_func, sp.EventType.ANIMATION_COMPLETE)
                self.effect:setAnimation(0, PlayerAction.action_1, true)
            end
        end)
    end
end


function WorldMapItem:showAfterEffect()
    if self.after_effect then
        self.after_effect:runAction(cc.RemoveSelf:create(true))
        self.after_effect = nil
    end
    if not self.after_effect then
        local parent_wnd = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
        local world_pos = self:convertToWorldSpace(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))

        self.after_effect = createEffectSpine(PathTool.getEffectRes(146), cc.p(SCREEN_WIDTH / 2,SCREEN_HEIGHT / 2), cc.p(0.5, 0.5), false, PlayerAction.action)
        parent_wnd:addChild(self.after_effect)

        self.after_effect:runAction(cc.Sequence:create(cc.MoveTo:create(0.5,cc.p(world_pos.x,world_pos.y))))
        local function animationCompleteFunc()
            if self.after_effect then
                self.after_effect:runAction(cc.RemoveSelf:create(true))
                self.after_effect = nil
            end
            self:showFingerEffect()
        end
        self.after_effect:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
    end
end


function WorldMapItem:showFingerEffect()
    if self.finger_effect then
        self.finger_effect:runAction(cc.RemoveSelf:create(true))
        self.finger_effect = nil
    end
    if not self.finger_effect then
        self.finger_effect = createEffectSpine(PathTool.getEffectRes(240), cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2), cc.p(0.5, 0.5), false, PlayerAction.action)
        self:addChild(self.finger_effect)

        local function animationCompleteFunc()
            BattleController:getInstance():setUnlockChapterStatus(false)
            WorldmapController:getInstance():addLockContainer(false)
            self.effect:setAnimation(0, PlayerAction.action_1, true)
        end
        self.finger_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        self.finger_effect:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
    end
end

function WorldMapItem:addToParent(parent,call_back)
    if not tolua.isnull(parent) and self.config then
        parent:addChild(self)
        if call_back then
            self.call_back  = call_back
        end
        self:setPosition(self.config.x, self.config.y)
    end
end

function WorldMapItem:openEffect()
    if not tolua.isnull(self.effect) then
        self.effect:setAnimation(0, PlayerAction.action_6, false)
        local function animationCompleteFunc()
            -- BattleDramaController:getInstance():openBattleDramaUnlockChapterView(true, self.config)
            WorldmapController:getInstance():openWorldMapTipsWindow(true,self.config.bid,WorldmapEvent.open_type.open_type_1)
            BattleController:getInstance():setUnlockChapterStatus(false)
            WorldmapController:getInstance():addLockContainer(false)
        end
        self.effect:registerSpineEventHandler(animationCompleteFunc, sp.EventType.ANIMATION_COMPLETE)
    end
end

--==============================--
--desc:填充数据
--time:2018-06-06 01:59:45
--@return 
--==============================--
function WorldMapItem:fillData()
    self.drama_data = model:getDramaData()
    if self.config ~= nil and self.drama_data ~= nil then

        self.progress_bg:setVisible(self.config.bid <= self.drama_data.chapter_id) 
        self.progress_label:setString(string.format("%s/%s", model:getHasCurChapterPassListNum(BattleDramaConst.Normal, self.config.bid), model:getChapterLength(BattleDramaConst.Normal, self.config.bid)))
        local max_sum_chapter = model:getOpenSumChapter(self.drama_data.mode)
        if self.config.bid == self.drama_data.chapter_id then--当前选中的
            if self.open_data then
                self:openEffect()
            else
                --self.progress_label:setString(string.format("%s/%s", model:getHasCurChapterPassListNum(BattleDramaConst.Normal,self.config.bid), model:getChapterLength(BattleDramaConst.Normal, self.config.bid)))
                self.effect:setAnimation(0, PlayerAction.action_1, true)
            end
        elseif self.config.bid < max_sum_chapter then
            self.effect:setAnimation(0, PlayerAction.action_3, true)
        elseif self.config.bid > max_sum_chapter then
            self.effect:setAnimation(0, PlayerAction.action_5, true) 
        end
    end
end

function WorldMapItem:clearEffect()
    if self.finger_effect then
        self.finger_effect:runAction(cc.RemoveSelf:create(true))
        self.finger_effect = nil
    end
    if self.after_effect then
        self.after_effect:runAction(cc.RemoveSelf:create(true))
        self.after_effect = nil
    end
    if self.open_effect then
        self.open_effect:runAction(cc.RemoveSelf:create(true))
        self.open_effect = nil
    end
end

function WorldMapItem:DeleteMe()
    if self.update_effect_event then
        GlobalEvent:getInstance():UnBind(self.update_effect_event)
        self.update_effect_event = nil
    end
    self:clearEffect()
end
