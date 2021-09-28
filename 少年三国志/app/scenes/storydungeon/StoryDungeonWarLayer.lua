
require("app.cfg.story_dungeon_info")
require("app.cfg.story_barrier_info")
local StoryDungeonWarLayer = class("StoryDungeonWarLayer",UFCCSModelLayer)

function StoryDungeonWarLayer.create(...)
    return StoryDungeonWarLayer.new("ui_layout/storydungeon_StoryDungeonWarLayer.json",Colors.modelColor, ...)
end

function StoryDungeonWarLayer:ctor(json, color, ...)
    self.super.ctor(self, json, color, ...)
    self:registerKeypadEvent(true)
    self:adapterWithScreen()

end

function StoryDungeonWarLayer:_init()
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
    if _data then
        local barrier_info = story_barrier_info.get(_data.barrier1)
        if barrier_info then
            self:getLabelByName("Label_Desc"):setText(barrier_info.direction)
        end
    end
    
    self:registerBtnClickEvent("Button_Close",function()
        self:animationToClose()
    end)
    
    local imgBg = self:getImageViewByName("Image_MapBg")
    if imgBg then
        imgBg:loadTexture(G_Path.getStoryDungeonEventPic(_data.pic))
    end
    local titleLabel = self:getLabelByName("Label_GateName")
    titleLabel:setText(_data.name)
    titleLabel:createStroke(Colors.strokeBrown,1)
    
    local passBounsLabel = self:getLabelByName("Label_PassBouns")
    passBounsLabel:setText(G_lang:get("LANG_TOWER_JIANGLI"))
    --passBounsLabel:createStroke(Colors.strokeBrown,1)
    -- 史诗战役名称
    
    -- 初始化掉落物品
    local _dropInfo = drop_info.get(_data.box_drop_id)
    --local _dropGoods = require("app.data.DropGoods")
    for i=1,5 do
        local bg = self:getWidgetByName("ImageView_GoodBaseBg" .. tostring(i))
        local data = G_Goods.convert(_dropInfo["type_" .. tostring(i)],_dropInfo["value_" .. tostring(i)],_dropInfo["min_num_" .. tostring(i)],_dropInfo["max_num_" .. tostring(i)])
        if bg then
            if data then
                self:registerWidgetTouchEvent("ImageView_GoodBg" .. tostring(i),
                function(widget,_type)
                    if _type == TOUCH_EVENT_ENDED then
                        require("app.scenes.common.dropinfo.DropInfo").show(
                        _dropInfo["type_" .. i],_dropInfo["value_" .. i])
                    end
                end)
                
                bg:setVisible(true)
                local goodBg = self:getImageViewByName("ImageView_GoodBg" .. i)
                goodBg:loadTexture(G_Path.getEquipColorImage(data.quality,data.type))
                goodBg:setTag(i) 
                
                local numLabel = self:getLabelByName("Label_BounsNum" .. i)
                if data.size > 0 then
                    numLabel:setText("x" .. data.size)
                    numLabel:createStroke(Colors.strokeBrown,1)
                else
                    numLabel:setVisible(false)
                end

                
                local nameLabel = self:getLabelByName("Label_GoodName" .. i)
                nameLabel:setText(data.info.name)
                nameLabel:setColor(Colors.getColor(data.quality))
                nameLabel:createStroke(Colors.strokeBrown,1)
                
                local goodIco = self:getImageViewByName("ImageView_Goods" .. i)
                goodIco:loadTexture(data.icon)
                print(data.icon)
            else
                bg:setVisible(false)
            end
        end
    end
    
    -- 检查是否开启
    local _storydata = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydata then
        -- 一通关
        if _storydata.is_finished == true then
            self:getImageViewByName("Image_Pass"):setVisible(true)
            self:getButtonByName("Button_Battle"):setVisible(false)
        else
            G_Me.storyDungeonData:setCurrBarrierId(_data.barrier1)
            self:registerBtnClickEvent("Button_Battle",handler(self, self.onBattle))
        end
    else
        self:getButtonByName("Button_Battle"):setVisible(false)
        -- 没有开启
        local _info = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
        if _info then
            _info = story_dungeon_info.get(_info.open_req1)
            if _info then
                local notOpenLabel1 = self:getLabelByName("Label_NotOpen1")
                local notOpenLabel2 = self:getLabelByName("Label_NotOpen2")
                local notOpenLabel3 = self:getLabelByName("Label_NotOpen3")
                notOpenLabel1:setText(G_lang:get("LANG_DUNGEON_PASS"))
                notOpenLabel2:setText(_info.name)
                notOpenLabel3:setText(G_lang:get("LANG_DUNGEON_OPEN"))
                local size = notOpenLabel2:getSize()
                notOpenLabel1:setPositionX(notOpenLabel2:getPositionX() - size.width/2)
                notOpenLabel3:setPositionX(notOpenLabel2:getPositionX() + size.width/2)
                notOpenLabel1:setVisible(true)
                notOpenLabel2:setVisible(true)
                notOpenLabel3:setVisible(true)
                notOpenLabel1:createStroke(Colors.strokeBrown,2)
                notOpenLabel2:createStroke(Colors.strokeBrown,2)
                notOpenLabel3:createStroke(Colors.strokeBrown,2)
            end

        end

    end
    
end

function StoryDungeonWarLayer:onBattle(widget)
    local _storyDungeonConst = require("app.const.StoryDungeonConst")
    G_Me.storyDungeonData:setBranch(_storyDungeonConst.BRANCH.EPIC_WAR)
    local _barrierInfo = story_barrier_info.get(G_Me.storyDungeonData:getCurrBarrierId())
    local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_STORYDUGEON,
                                                   _barrierInfo.dungeon,
                                                   _storyDungeonConst,
                                                   _storyDungeonConst.TOUCHTYPE.TYPE_FIRSTENTER,
                                                   nil,
                                                   _barrierInfo.id)
    if isHave == true then
        self:_showStoryTalkLayer({storyId = _storyId,func = handler(self,self._sendExecuteBarrier)})
    else
        self:_sendExecuteBarrier()
        -- self:onCloseWindow()
    end
end

-- @desc显示剧情对话
-- @param storyid 剧情id
function StoryDungeonWarLayer:_showStoryTalkLayer(data)
    uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create(data))
end
-- @desc 发送执行关卡请求
function StoryDungeonWarLayer:_sendExecuteBarrier()
    G_HandlersManager.storyDungeonHandler:sendExecuteBarrier(
                                        G_Me.storyDungeonData:getCurrDungeonId(),
                                        G_Me.storyDungeonData:getCurrBarrierId(),
                                        1)
end

-- @desc 执行战斗
function StoryDungeonWarLayer:_recvExecuteBarrier(data)
    if data.ret == NetMsg_ERROR.RET_OK then 
        local temp = self
        G_Loading:showLoading(function ( ... )
            temp:onCloseWindow()
            temp.scene = require("app.scenes.storydungeon.StoryDungeonBattleScene").new({_data = data,isSkip = false})
            uf_sceneManager:pushScene(temp.scene)
        end, 
        function ( ... )
            temp.scene:play()
        end)

    end
end

function StoryDungeonWarLayer:onLayerEnter()
    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydata then
        if _storydata.is_entered == false then
            G_HandlersManager.storyDungeonHandler:sendSetStoryTag(G_Me.storyDungeonData:getCurrDungeonId())
        end
    end
    self:_init()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_EXECUTEBARRIER, self._recvExecuteBarrier, self)
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_110"), "smoving_bounce")
end

function StoryDungeonWarLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function StoryDungeonWarLayer:onCloseWindow()
    self:close() 
end

function StoryDungeonWarLayer:onBackKeyEvent( ... )
    self:close()
    return true
end

return StoryDungeonWarLayer