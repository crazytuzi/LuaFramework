require("app.cfg.story_field_info")
require("app.cfg.story_dungeon_info")
require("app.cfg.dungeon_stage_info")
require("app.cfg.dungeon_chapter_info")

local StoryDungeonMainScene = class("StoryDungeonMainScene",UFCCSBaseScene)

function StoryDungeonMainScene:ctor(josn,func,stageId, unUseParam, pack, ...)
    self.super.ctor(self,...)
    self._DungeonList = {}
    self._BattleList = {}
    self.recordCellPos = {}
    GlobalFunc.savePack(self, pack)
    self._layer = CCSNormalLayer:create("ui_layout/storydungeon_StoryDungeonMainScene.json")
    self:addUILayerComponent("StoryDungeonLayer",self._layer,true)
    --self._layer:adapterWithScreen()
    self._roleInfo = G_commonLayerModel:getDungeonRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self._stageId = stageId
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    self:adapterLayerHeight(self._layer,nil,self._speedBar,-8,-56)
        
    self._layer:registerBtnClickEvent("Button_WuJiang",handler(self,self._onWuJiang))
    self._layer:registerBtnClickEvent("Button_Campaign",handler(self,self._onCampaign))
    GlobalFunc.flyIntoScreenLR( { self._roleInfo }, true, 0.4, 2, 100)
    
    self._layer:registerBtnClickEvent("Button_Fragment",function()
         uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonSanGuoZhiFragmentScene").new())
    end
        )
        
    self._layer:registerBtnClickEvent("Button_Dungeon",function()
        uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
    end)
        
    self._layer:registerBtnClickEvent("Button_NormalDungeon",function()
        uf_sceneManager:replaceScene(require("app.scenes.vip.VipMapScene").new())
    end)
    
    self._layer:getLabelByName("Label_Times"):createStroke(Colors.strokeBrown, 1)
    self._layer:getLabelByName("Label_TimesValue"):createStroke(Colors.strokeBrown, 1)
    self._layer:getLabelByName("Label_Times"):setText(G_lang:get("LANG_STORYDUNGEON_CHALLENGETIMES"))
    self:_setExeCount()
    
    self:registerKeypadEvent(true)
      
    -- 检查主线副本是否有未领取的宝箱
    self._layer:showWidgetByName("Image_Tips_Dungeon", self:_checkPlotlineDungeonExistUnclaimedBox())
end


function StoryDungeonMainScene:onBackKeyEvent( ... )
    self:_onBack()
    return true
end



function StoryDungeonMainScene:onSceneUnload(...)

    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")

end

function StoryDungeonMainScene:_setExeCount()
      self._layer:getLabelByName("Label_TimesValue"):setText(G_Me.storyDungeonData:getExecutecount())
end

function StoryDungeonMainScene:onSceneEnter(...)
    if  G_Me.storyDungeonData:isNeedRequestNewData() then
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_DUNGEONLIST, self._setExeCount, self)
        G_HandlersManager.storyDungeonHandler:sendGetStoryList()
    end
    -- 更新数据，这里最好放到数据里做而不是在view里做
    self:_initList()
    self:initListView()
    self:_showCellPos()
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)

    -- 显示日常副本提示
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    local _level2 = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.VIP_SCENE)
    if G_Me.userData.level >= _level2 then
        self._layer:getImageViewByName("Image_Tips"):setVisible(G_Me.vipData:getLeftCount()>0)
    else
        self._layer:getImageViewByName("Image_Tips"):setVisible(false)
    end
end

function StoryDungeonMainScene:onSceneExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function StoryDungeonMainScene:initListView()
    if self.listview == nil then
        self.listview = CCSListViewEx:createWithPanel(self._layer:getPanelByName("Panel_DungeonList"), LISTVIEW_DIR_VERTICAL) 
        self.listview:setCreateCellHandler(function ( list, index) 
            local cell = CCSItemCellBase:create("ui_layout/storydungeon_StoryDungeonItem.json")
            for i = 1,4 do
                cell:registerWidgetTouchEvent("Panel_Click" .. i.. "_1",handler(self,self.onClick))
                cell:registerWidgetTouchEvent("Panel_Click" .. i.. "_2",handler(self,self.onClick))
                cell:registerWidgetTouchEvent("Panel_Click" .. i.. "_3",handler(self,self.onClick))
            end
    	    return cell
        end)
        self.listview:setBouncedEnable(false)
        self.listview:setClippingEnabled(false)
        local lenth = math.floor(#self._DungeonList/4)
        if #self._DungeonList%4 > 0 then
            lenth = lenth + 1
        end
        self.listview:setUpdateCellHandler(handler(self,self._updateCell))
        self.listview:initChildWithDataLength(lenth)
    else
        self.listview:refreshWithStart()
    end

end


function StoryDungeonMainScene:onClick(widget,_type)
    local _parent = widget:getParent()
    _parent = tolua.cast(_parent,"ImageView")
     local _head = _parent:getChildByName("ImageView_Head" .. 5-_parent:getTag())
    function showField(isShow)
        local data = G_Me.storyDungeonData:getStoryDungeon(_head:getTag())
        if data then
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        --    _parent:getParent():getParent():setZOrder(1000)
            _parent:loadTexture(G_Path.getFieldIcon(_parent:getTag(),isShow))
        end 
     end
    if _type == TOUCH_EVENT_BEGAN  then
        showField(true)
    elseif  _type == TOUCH_EVENT_CANCELED then
        showField(false)    
    elseif _type == TOUCH_EVENT_ENDED then
        local _data = G_Me.storyDungeonData:getStoryDungeon(_head:getTag())
        if _data then
                         -- 记录当前点击cell位置
            local pos = self.listview:getCellTopLeftOffset(self.recordCellPos[_head:getTag()].cellIndex)
             G_Me.storyDungeonData:setCellPos(self.recordCellPos[_head:getTag()].cellIndex,pos)
             
            G_Me.storyDungeonData:setCurrDungeonId(_head:getTag())
            uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonGateScene").new())
        else
            local child = _parent:getChildByName("Panel_WuJiangZhuan" .. 5-_parent:getTag())
            local passLabel = child:getChildByName("Label_Pass" .. 5-_parent:getTag())
            if passLabel  and _head:isVisible() == true then
                passLabel = tolua.cast(passLabel,"Label")
                G_MovingTip:showMovingTip(passLabel:getStringValue())
            end

            local labelCommingSoon = _parent:getChildByName("BitmapLabel_ComeBack" .. 5-_parent:getTag())
            if labelCommingSoon and labelCommingSoon:isVisible() then
                G_MovingTip:showMovingTip(G_lang:get("LANG_STORYDUNGEON_COMMING_SOON"))
            end
        end

    end
end

function StoryDungeonMainScene:_updateCell( list, index, cell)
    if #self._DungeonList == 0 then return end
    -- 设置起始索引
    local num = self.listview:getDataLength()
    local _startIndex = #self._DungeonList - (num-index)*4

    for i=4,1,-1 do
        local data = self._DungeonList[_startIndex+1]
        local knight_icon = cell:getImageViewByName("Image_Ico" .. i)
        local bg = cell:getImageViewByName("ImageView_Head" .. i)
        local knight_Panel = cell:getPanelByName("Panel_WuJiangZhuan" .. i)
        local battleBtn = cell:getButtonByName("Button_Battle" .. i)
        cell:registerBtnClickEvent("Button_Battle" .. i,handler(self,self._onClickBattle))
        if data then
            if data.pic > 0 then
                bg:setVisible(true)
                bg:showAsGray(data.Open == false)
                knight_icon:loadTexture(G_Path.getKnightIcon(data.pic))
                knight_icon:showAsGray(data.Open == false)
                bg:setTag(data.id)
                local headBg = cell:getImageViewByName("Image_HeadBg" .. i)
                headBg:showAsGray(data.Open == false)

                local nameBg = cell:getImageViewByName("Image_NameBg" .. i)
                nameBg:showAsGray(data.Open == false)

                local name = cell:getLabelByName("Label_Name" .. i)
                name:setText(data.name)
                name:setColor(data.Open == false and ccc3(204,204,204) or ccc3(254,246,216))
                --cell:getImageViewByName("ImageView_Field" .. i):showAsGray(data.Open == false)
                local pos = list:getCellTopLeftOffset(index)
                self.recordCellPos[data.id] = {cellIndex = index,cellPos = pos}
                -- 小旗子标志
                cell:getPanelByName("Panel_Flag" .. i):setVisible(data.Open and data.passStageNum < 4)
                -- 通关标志
                cell:getImageViewByName("ImageView_Po" .. i):setVisible(data.Open and data.passStageNum == 4)

                if data.Open == false then
                    local label_Pass = cell:getLabelByName("Label_Pass" .. i)
                    if data.desc then
                        label_Pass:setText(data.desc)
                        label_Pass:createStroke(Colors.strokeBrown,1)
                    end
                    knight_Panel:setVisible(true)
                else
                    knight_Panel:setVisible(false)
                    name:createStroke(Colors.strokeBrown,1)
                    -- 显示旗子数目
                    for j=1,4 do
                        cell:getImageViewByName("Image_Flag" .. i .. "_" .. j):showAsGray(j > data.passStageNum)
                    end
                end

                cell:getImageViewByName("Image_Tips" .. i):setVisible(data.haveBouns)
                -- 史诗战役
                local battleLabel = cell:getLabelByName("Label_BattleName" .. i)

                if self._BattleList[data.id] then
                    self:_addBattleEfeect(cell,battleBtn,battleLabel,self._BattleList[data.id],i)
                 else
                    battleBtn:setVisible(false)
                end
                battleLabel:setVisible(battleBtn:isVisible())

                cell:getLabelBMFontByName("BitmapLabel_ComeBack" .. i):setVisible(false)
            else
                cell:getLabelBMFontByName("BitmapLabel_ComeBack" .. i):setVisible(true)
                bg:setVisible(false)
                knight_Panel:setVisible(false)
                battleBtn:setVisible(false)
                cell:getImageViewByName("ImageView_Po" ..i):setVisible(false)
                bg:setTag(99999)
            end

        else
            --cell:getImageViewByName("ImageView_Field" .. i):showAsGray(true)
            bg:setVisible(false)
            knight_Panel:setVisible(false)
            battleBtn:setVisible(false)
            cell:getLabelBMFontByName("BitmapLabel_ComeBack" .. i):setVisible(false)
        end
        _startIndex = _startIndex + 1

    end
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        self:_addEffect(cell)
    end
end

function StoryDungeonMainScene:_addBattleEfeect(cell,battleBtn,battleLabel,data,_index)
        --史诗战役通关图标
    cell:getImageViewByName("Image_Pass" .._index):setVisible((data and data.isFinished== true) and true or false)

    battleBtn:setVisible(true)
    battleBtn:setTag(data.id)
    local sprite = battleBtn:getVirtualRenderer()
    sprite = tolua.cast(sprite, CCSPRITE)
    battleLabel:setText(data.name)
    battleLabel:createStroke(Colors.strokeBrown,1)
    if sprite then
        --没有开启,将史诗战役图标调暗
        sprite:setColor(data.Open and ccc3(255,255,255) or ccc3(128,128,128))
        -- 史诗战役开启状态
        if data.Open == true  and  data.isFinished == false then
            if sprite.secretShine == nil then
                sprite.secretShine = require("app.common.effects.EffectNode").new("effect_particle_star")
                -- secretShine:setScale(0.5)
                sprite:addChild(sprite.secretShine, 10)
                local size = sprite:getContentSize()
                sprite.secretShine:setPosition(ccp(size.width/2,size.height/2))
                sprite.secretShine:play()
            end
        else
            if sprite.secretShine then
                sprite.secretShine:removeFromParentAndCleanup(true)
                sprite.secretShine= nil
            end
        end
    end
end

function StoryDungeonMainScene:_addEffect(_cell)
    local _effect = _cell:getNodeByTag(10)
    if _effect == nil then
        _effect = require("app.common.effects.EffectNode").new("effect_fubengditu")
        _cell:addNode(_effect, 10,10)
        _effect:play()
        _effect:setPosition(ccp(320,570))
    end
end


function StoryDungeonMainScene:_onBack(widget)
     uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new())
end

-- 点击史诗战役
function StoryDungeonMainScene:_onClickBattle(widget)
    G_Me.storyDungeonData:setCurrDungeonId(widget:getTag())
    self:addChild(require("app.scenes.storydungeon.StoryDungeonWarLayer").create())
end

-- 设置当前章节在屏幕的位置
function StoryDungeonMainScene:_showCellPos()
    local cellIndex,cellPos = nil
    --local lenth = self:_countListLenth()
    --self.listview:reloadWithLength(lenth)
    local moveLenth = 0
    self.listview:refreshAllCell()
    cellIndex,cellPos = G_Me.storyDungeonData:getCellPos()
    
    local lenth = self:countScrollSpace()
    if cellIndex == -1  then
        moveLenth = -lenth
    else
        moveLenth = cellPos
    end
    self.listview:setScrollSpace(lenth, 0)
     if lenth == 0 and #self._DungeonList <= 2 then
          self.listview:scrollToBottomRightCellIndex(0,0,-1,function() end)
    else
           self.listview:scrollToTopLeftCellIndex(cellIndex,moveLenth,0,function() end)
     end
end

function StoryDungeonMainScene:countScrollSpace()
    local num = math.floor(#self._DungeonList%4)
    local lenth = 0
    if num == 0 then
        lenth = 0
    elseif num == 1 then
        lenth = -800
    elseif num == 2 then
        lenth = -470
    else
        lenth = -240
    end
    if -lenth >1140- CCDirector:sharedDirector():getWinSize().height  and #self._DungeonList <= 4 then
        lenth = 0
    end
    return lenth
end

function StoryDungeonMainScene:_initList()
    self._DungeonList = {}
    local lastDungeon = false
    for k=1,story_dungeon_info.getLength() do
        -- 这里不能直接使用元数据做赋值操作，否则可能会覆盖元数据
        local v = clone(story_dungeon_info.indexOf(k))
            local data = G_Me.storyDungeonData:getStoryDungeon(v.id)
            v.desc = ""
            v.haveBouns = false
            -- 武将传
            if v.type == 1 then
                -- 检查服务器是否有发数据过来，有发表示这一个关卡至少已经开启
                if data then
                    -- 是否开启
                    v.Open = true
                    -- 通关关卡数目
                    v.passStageNum = 0
                    -- 计算通过的关卡数目
                    -- barrier_id在表中的存储是按顺序从1开始顺序递增，所以第2关的关卡开始的barrier_id应该是5,6,7,8,以此类推
                    for i=1,4 do
                        if v["barrier" .. i] < data.barrier_id then
                            v.passStageNum = v.passStageNum +1
                        end
                    end
                    -- 已通关
                    if data.is_finished == true then
                        v.passStageNum = 4
                        -- 是否有奖励需要领取。has_award表示是否领过奖
                        v.haveBouns = not data.has_award
                    end
                    table.insert(self._DungeonList,1,v)
                else
                    -- 这里表示服务器数据后的下一个关卡
                    if lastDungeon == false then
                        -- 默认未开启
                        v.Open = false
                        v.passStageNum = 0
                        -- 开启条件需要根据open_req1这个前置条件到dungeon_stage_info里去找
                        local _info = dungeon_stage_info.get(v.open_req1)
                        -- 查看是否通过副本关卡
                        if _info then
                            local dungeon_data = G_Me.dungeonData:getStageData(_info.chapter_id,_info.id)
                            -- 如果找不到此副本或者副本未开启或者副本未通关，则提示通关xx章节后开启
                            if dungeon_data == nil or  not dungeon_data._isOpen or not dungeon_data._isFinished  then
                                local _chapterinfo = dungeon_chapter_info.get(_info.chapter_id)
                                v.desc = G_lang:get("LANG_STORYDUGEON_PASSSTAGE",{name=_chapterinfo.name})
                            -- 否则就是下一个未开启的关卡了
                            else
                                local story_info = story_dungeon_info.get(v.prepose_id)
                                if story_info then
                                    v.desc = G_lang:get("LANG_STORYDUGEON_PASSSTORYDUGEON",{name=story_info.name})
                                end
                            end
                        end
                        table.insert(self._DungeonList,1,v)

                        lastDungeon = true
                    end
                end
            -- 史诗战役
            else
                if data then
                    v.Open = true
                    v.isFinished = data.is_finished
                else
                    v.Open = false
                    v.isFinished = false
                end
                v.desc = ""
                -- 记录大事件所在的武将传位置
                self._BattleList[v.open_req1] = v
            end

    end
end

-- 检查主线副本是否有未领取的宝箱
function StoryDungeonMainScene:_checkPlotlineDungeonExistUnclaimedBox()
    return G_Me.dungeonData:hasUnclaimedBox()
end

return StoryDungeonMainScene

