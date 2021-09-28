require("app.cfg.dungeon_chapter_info")
require("app.cfg.dungeon_stage_info")
require("app.cfg.story_dungeon_info")

require("app.cfg.hard_dungeon_chapter_info")
require("app.cfg.hard_dungeon_stage_info")
local DungeonMainScene = class("DungeonMainScene", UFCCSBaseScene)
local FunctionLevelConst = require("app.const.FunctionLevelConst")
local soundConst = require("app.const.SoundConst")
local PlotlineDungeonType = require("app.const.PlotlineDungeonType")

function DungeonMainScene:ctor(josn, func, stageId, chapterId, pack, ...)
	self.super.ctor(self, ...)

    G_Me.userData:setPlotlineDungeonType(PlotlineDungeonType.EASY)

	GlobalFunc.savePack(self, pack)

	self._chapterList = { }

	-- 记录刚刚新开启的章节在cell中的位置
	self._indexOfCell = 0
	self.secretShine = nil
	self._chapterId = chapterId
	self._stageId = stageId

	self._newChpaterId = 0
	-- 当前最新的章节id
	self._currOpenChapterId = 0
	-- 检查是否跳到底部
	self._isMoveToBottom = false

	self.recordCellPos = { }

	-- 记录开启章节数目
	self.openChapterNum = 0
    -- 是否打完所有章节
    self.isPassChapter = false
    -- 精英副本红点，判断逻辑分布在几个地方
    self._showHardTips = false

	self._layer = CCSNormalLayer:create("ui_layout/dungeon_DungeonMainScene.json")
	self:addUILayerComponent("DungeonMainLayer", self._layer, true)

	

	self._layer:registerBtnClickEvent("Button_StoryDungeon", function()
		local _level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.STORY_DUNGEON)
		if G_Me.userData.level >= _level then
			uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonMainScene").new())
		else
			G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_STORYDUNGEON_TIPS", { level = _level }))
		end
	end )

	self._layer:registerBtnClickEvent("Button_NormalDungeon", function()
		local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.VIP_SCENE)
		if not unlockFlag then
			local _level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.VIP_SCENE)
			G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_VIP_TIPS", { level = _level }))
			return
		end
		uf_sceneManager:replaceScene(require("app.scenes.vip.VipMapScene").new())
	end )


	local nPlayerLevel = G_Me.userData.level
	if nPlayerLevel < 35 then
		self._layer:showWidgetByName("Panel_92", false)
	else
		self._layer:showWidgetByName("Panel_92", true)
		-- 精英模式
		self._layer:getButtonByName("Button_JinYin"):setVisible(false)
		self._layer:getButtonByName("Button_Dungeon"):setVisible(true)
		self._layer:getButtonByName("Button_Easy"):setScale(1)
		self._layer:getButtonByName("Button_Hard"):setScale(0.85)
		self._layer:getButtonByName("Button_Hard"):setOpacity(180)
		self._layer:getImageViewByName("Image_FlareEasy"):setVisible(true)
		self._layer:getImageViewByName("Image_FlareHard"):setVisible(false)

		self._layer:registerBtnClickEvent("Button_Easy", function()
			local unlockLevel = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.HARDDUNGEON)
			if G_Me.userData.level >= unlockLevel then
				G_Me.userData:setPlotlineDungeonType(PlotlineDungeonType.HARD)
				uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
				G_Me.hardDungeonData:recordHardDungeonEntered()
			else
				G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_HARDDUNGEON_TIPS", { level = unlockLevel }))
			end
		end)
		self._layer:registerBtnClickEvent("Button_Hard", function()
			local unlockLevel = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.HARDDUNGEON)
			if G_Me.userData.level >= unlockLevel then
				G_Me.userData:setPlotlineDungeonType(PlotlineDungeonType.HARD)
				uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
				G_Me.hardDungeonData:recordHardDungeonEntered()
			else
				G_MovingTip:showMovingTip(G_lang:get("LANG_PLAY_HARDDUNGEON_TIPS", { level = unlockLevel }))
			end
		end)
	end

	self:_init()

end

function DungeonMainScene:onSceneEnter(...)
	self._roleInfo = G_commonLayerModel:getDungeonRoleInfoLayer()
	self._speedBar = G_commonLayerModel:getSpeedbarLayer()
	self._speedBar:setSelectBtn("Button_Dungeon")
	self:addUILayerComponent("RoleInfoUI", self._roleInfo, true)
	self:addUILayerComponent("SpeedBar", self._speedBar, true)
	self:adapterLayerHeight(self._layer, nil, self._speedBar, -8, -56)
	GlobalFunc.flyIntoScreenLR( { self._roleInfo }, true, 0.4, 2, 100)
	
	self:_initChapterList()
	self:_showCellPos()
	self:_moveToBottom()

	self:_enterDungeonGate()
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
	if self._newChpaterId > 0 then
		G_SoundManager:preloadSceneSoundList( { soundConst.GameSound.KNIGHT_EAT_MATERIAL, soundConst.GameSound.KNIGHT_SHOW })
		self:playWinAnimation()
	end

	-- 显示名将副本提示
    local _level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.STORY_DUNGEON)
    if G_Me.userData.level >= _level then
	    self._layer:getImageViewByName("Image_Tips"):setVisible(G_Me.storyDungeonData:isHaveBouns() or G_Me.storyDungeonData:getExecutecount() > 0)
    else
        self._layer:getImageViewByName("Image_Tips"):setVisible(false)
    end

    -- 显示日常副本提示
    local _level2 = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.VIP_SCENE)
    if G_Me.userData.level >= _level2 then
	    self._layer:getImageViewByName("Image_Tips_2"):setVisible(G_Me.vipData:getLeftCount()>0)
    else
        self._layer:getImageViewByName("Image_Tips_2"):setVisible(false)
    end

    -- 精英暴动
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARD_DUNGEON_RIOT) then
        if G_Me.hardDungeonData:isNeedRequestRiotChapterList() then
            -- 精英暴动拉取数据
            G_HandlersManager.hardDungeonHandler:sendGetRiotChapterList()
        end
    end

    -- 检查普通副本有没有未领取的宝箱
    self:_easyDungeonHasUnclaimedBox()
    -- 检查精英副本有没有未领取的宝箱
    self:_hardDungeonHasUnclaimedBox()
    -- 检查精英副本有没有暴动事件
    self:_hasRiotEvent()
    -- 玩家是否达到50级，并且没有进入过精英副本
    self:_isEnteredHardDungeon()

    -- 若精英暴动有了新的可打的暴动章节
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_RIOT_UPDATE_MAIN_LAYER, self._onUpdateHardTipsWithRiot, self)
end

function DungeonMainScene:playWinAnimation()
	local cityPanel = nil
	if self._indexOfCell == 1 then
		-- 第一个区域,则上一个cell的最后显示胜利动画
		cityPanel = self.listview:getShowCellByIndex(1):getImageViewByName("ImageView_City" .. 4)
	elseif self._indexOfCell == 4 then
		cityPanel = self.listview:getShowCellByIndex(1):getImageViewByName("ImageView_City" .. 3)
	else
		cityPanel = self.listview:getShowCellByIndex(0):getImageViewByName("ImageView_City" .. self._indexOfCell - 1)
	end
	local EffectNode = require "app.common.effects.EffectNode"
	self.winEffectNode = EffectNode.new("effect_castle_win", function(event, frameIndex)
		if event == "finish" then
			self:playWayAnimation()
			self.winEffectNode:removeFromParentAndCleanup(true)
		end
	end )
	self.winEffectNode:play()
	cityPanel:addNode(self.winEffectNode, 10)
	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.Dungeon_Hall)
end

function DungeonMainScene:onSceneExit()
	G_SoundManager:unloadSceneSoundList( { soundConst.GameSound.KNIGHT_EAT_MATERIAL, soundConst.GameSound.KNIGHT_SHOW })
	if self._timer then
		G_GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
	self._indexOfCell = 0
	uf_eventManager:removeListenerWithTarget(self)

    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end



-- @desc 初始化章节列表
function DungeonMainScene:_initChapterList()
	for i = 1, dungeon_chapter_info.getLength() do
		local data = dungeon_chapter_info.indexOf(i)
		if G_Me.dungeonData:isOpenChpater(data.id) then
			table.insert(self._chapterList, 1, data.id)
			self.openChapterNum = self.openChapterNum + 1
			-- 设置最新的章节id
			if data.id > self._currOpenChapterId then
				self._currOpenChapterId = data.id
			end
		else
			table.insert(self._chapterList, 1, data.id)
			break
		end
	end

    self.isPassChapter = dungeon_chapter_info.getLength() -1 == self.openChapterNum
	-- 小于四个章节，需要将列表跳到底部
	if self.openChapterNum < 3 then
		self._isMoveToBottom = true
		self.listview:setScrollEnabled(false)
	end
end

-- 快速进入关卡
function DungeonMainScene:_enterDungeonGate()
	if self._chapterId ~= nil and self._chapterId > 0 then
		if type(self._chapterId) == "number" then
			if G_Me.dungeonData:isOpenChpater(self._chapterId) then
				G_Me.dungeonData:setCurrChapterId(self._chapterId)

				uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonGateScene").new(self._stageId, GlobalFunc.getPack(self)))
			else
				local data = dungeon_chapter_info.get(self._chapterId)
				if data then
					G_MovingTip:showMovingTip(G_lang:get("LANG_NOTOPENCHAPTER", { name = data.name }))
				else
					G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_CHAPTERERROR", { num = "Unknown" }))
				end
			end
		end
	end
end

-- @desc 点击章节
function DungeonMainScene:onClick(widget, _type)
	local _parent = widget:getParent()
	_parent = tolua.cast(_parent, "ImageView")
	local _city = _parent:getParent():getChildByName("ImageView_City" .. 5 - _parent:getTag())

	function showField(isShow)
		if G_Me.dungeonData:isOpenChpater(_city:getTag()) then
			G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
		--	_parent:getParent():getParent():setZOrder(1000)
			_parent:loadTexture(G_Path.getFieldIcon(_parent:getTag(), isShow))
		end
	end

	if _type == TOUCH_EVENT_BEGAN then
		showField(true)
	elseif _type == TOUCH_EVENT_CANCELED then
		showField(false)
	elseif _type == TOUCH_EVENT_ENDED then
		if G_Me.dungeonData:isOpenChpater(_city:getTag()) then
                --    _parent:getParent():setZOrder(1)
                    _parent:loadTexture(G_Path.getFieldIcon(_parent:getTag(), false))
                    G_Me.dungeonData:setCurrChapterId(_city:getTag())
                    uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonGateScene").new())

                    -- 记录当前点击cell位置
                    local pos = self.listview:getCellTopLeftOffset(self.recordCellPos[_city:getTag()].cellIndex)
                    G_Me.dungeonData:setCellPos(self.recordCellPos[_city:getTag()].cellIndex, pos)

		else
                    local data = dungeon_chapter_info.get(_city:getTag())
                    if data then
                        if data.map > 0 then
                                local _premiseData = dungeon_chapter_info.get(data.premise_id)
                                if _premiseData then
                                	G_MovingTip:showMovingTip(G_lang:get("LANG_PASSCONDITION", { name = _premiseData.name }))
                                end
                        else
                        -- 提示敬请期待
                             G_MovingTip:showMovingTip(data.name)
                        end
                    end
		end
	end

	-- widget:setTouchEnabled(false)
end

function DungeonMainScene:_init()
	local panel = self._layer:getWidgetByName("Panel_List")
	self._layer:adapterWidgetHeightWithOffset("Panel_List", 0, 0)
	panel = tolua.cast(panel, "Layout")
	self.listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	self.listview:setBouncedEnable(false)
	self.listview:setClippingEnabled(false)
	-- self.listview._list = dungeon_chapter_info.data
	self.listview:setCreateCellHandler( function(list, index)
		local cell = CCSItemCellBase:create("ui_layout/dungeon_DungeonItem.json")
		for i = 1, 4 do
			cell:registerWidgetTouchEvent("Panel_Click" .. i .. "_1", handler(self, self.onClick))
			cell:registerWidgetTouchEvent("Panel_Click" .. i .. "_2", handler(self, self.onClick))
			cell:registerWidgetTouchEvent("Panel_Click" .. i .. "_3", handler(self, self.onClick))
		end
		return cell
	end )

	self.listview:setUpdateCellHandler(handler(self, self._updateCell))

	-- 计算列表长度
	--    local lenth = self:_countListLenth()

	-- self.listview:initChildWithDataLength(2)   --

end

-- 计算滑动距离
function DungeonMainScene:countScrollSpace()
	local num = math.floor(#self._chapterList % 4)
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
	if - lenth > 1140 - CCDirector:sharedDirector():getWinSize().height and #self._chapterList <= 4 then
		lenth = 0
	end
	return lenth
end

-- 设置当前章节在屏幕的位置
function DungeonMainScene:_showCellPos()
	local cellIndex, cellPos = nil
	local lenth = self:_countListLenth()
	self.listview:reloadWithLength(lenth)
	local moveLenth = 0
	self.listview:reloadWithLength(lenth)
	if self._newChpaterId == 0 then
		cellIndex, cellPos = G_Me.dungeonData:getCellPos()
	else
		-- 开启新章节
		cellIndex = -1
	end

	local lenth = self:countScrollSpace()
	if cellIndex == -1 then
		moveLenth = - lenth
		G_Me.dungeonData:setCellPos(cellIndex, moveLenth)
	else
		moveLenth = cellPos
	end
	self.listview:setScrollSpace(lenth, 0)
	self.listview:scrollToTopLeftCellIndex(cellIndex, moveLenth, 0, function() end)
end


-- @desc 列表是否移动到底部
function DungeonMainScene:_moveToBottom()
	local lenth = self:_countListLenth()
	if self._isMoveToBottom == true then
		self.listview:scrollToBottomRightCellIndex(lenth - 1, 0, -1, function() end)
		-- 开启章节大于3个则可以移动地图
		-- self.listview:setScrollEnabled(self.openChapterNum > 3)
	end
end

-- @desc计算列表长度
-- @return lenth 列表长度
function DungeonMainScene:_countListLenth()
	local lenth = math.floor(#self._chapterList / 4)
	if #self._chapterList % 4 > 0 then
		lenth = lenth + 1
	end

	if lenth == 0 then lenth = 2 end
	return lenth
end

-- 设置城池连接线
function DungeonMainScene:_setCityRoad(cell, index, chapteId)
	local isShow = chapteId > 1 and G_Me.dungeonData:isOpenChpater(chapteId)

	-- 此章节为新开启章节
	if chapteId == self._newChpaterId then
		isShow = false
	end
	local i = 1
	while (cell:getImageViewByName("ImageView_Road" .. index .. "_" .. i)) do
		cell:getImageViewByName("ImageView_Road" .. index .. "_" .. i):setVisible(isShow)
		cell:getImageViewByName("ImageView_Road" .. index .. "_" .. i):setZOrder(-1)
		i = i + 1
	end
end

-- @desc 播放路线动画
function DungeonMainScene:playWayAnimation()
	local _index = 1
	self._timer = G_GlobalFunc.addTimer(0.2, function()
		-- 如果是第一则需要
		local lastCell = nil
		-- 当前开启的章节块 大于1
		if self.listview:getShowCellCount() > 1 and self._isMoveToBottom == false then
			lastCell = self.listview:getShowCellByIndex(1)
		end

		if self._indexOfCell == 1 and lastCell and lastCell:getImageViewByName("ImageView_LastRoad"):isVisible() == false then
			lastCell:getImageViewByName("ImageView_LastRoad"):setVisible(true)
		else
			-- 如果当前章节数大于4 则显示最顶上的路径，否则显示最底下的路径
                    local cell = self.listview:getShowCellByIndex((self._indexOfCell == 4 and 1) or 0)
                    if cell then
                            if cell:getImageViewByName("ImageView_Road" .. self._indexOfCell .. "_" .. _index) then
                                    cell:getImageViewByName("ImageView_Road" .. self._indexOfCell .. "_" .. _index):setVisible(true)
                                    _index = _index + 1
                            else
                                if self._timer then
                                    G_GlobalFunc.removeTimer(self._timer)
                                    self:_playEffect(cell)
                                end
                                self._timer = nil
                                self._newChpaterId = 0
					-- self._indexOfCell = 0
				end
			end
		end
	end
	)

end

--@desc 小刀动画
function DungeonMainScene:_addKnifeEffect(cell,_index,isShow)
    if self.isPassChapter == true then
        return
    end
    
    local field = cell:getImageViewByName("ImageView_City" .. _index)
    if field then
        local knifeNode = field:getNodeByTag(100)
        if knifeNode == nil and isShow == true then
            knifeNode = require("app.common.effects.EffectNode").new("effect_knife")
            field:addNode(knifeNode, 10,100)
            knifeNode:play()
            --local proImg = cell:getImageViewByName("ImageView_Po" .. _index)
            --if proImg then
            --    local pt = proImg:getPositionInCCPoint()
            --    if _index == 2 then
            --        pt.x = pt.x + 40
            --        pt.y = pt.y + 30
            --    else
            --        pt.x = pt.x - 150
            --    end
               
            --    knifeNode:setPosition(pt)
            --end
            knifeNode:setPosition(ccp(40,50))
        end
        if knifeNode then
            knifeNode:setVisible(isShow)
        end
    end

end

function DungeonMainScene:_addSceneEffect(_cell)
    local _effect = _cell:getNodeByTag(10)
    if _effect == nil and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        _effect = require("app.common.effects.EffectNode").new("effect_fubengditu")
        _cell:addNode(_effect, 10,10)
        _effect:play()
        _effect:setPosition(ccp(320,570))
    end
end

function DungeonMainScene:_playEffect(cell)
	local cityPanel = cell:getImageViewByName("ImageView_City" .. self._indexOfCell)
	local EffectNode = require "app.common.effects.EffectNode"
	self._starPanel = cell:getPanelByName("Panel_Star" .. self._indexOfCell)

	cell:getImageViewByName("ImageView_City" .. self._indexOfCell):setVisible(true)
	self:_showFire(cell)

	self.secretShine = require("app.common.effects.EffectNode").new("effect_particle_star")
	-- secretShine:setScale(0.5)
	cityPanel:addNode(self.secretShine, 10)
	self.secretShine:play()
	self.secretShine:setTag(self._indexOfCell)
	--    self.cityEffectNode:play()
	--    cityPanel:addNode(self.cityEffectNode,10)
	-- 播放亮起音效
	G_SoundManager:playSound(soundConst.GameSound.KNIGHT_EAT_MATERIAL)
end

-- 显示火焰
function DungeonMainScene:_showFire(cell)
	local data = dungeon_chapter_info.get(self._newChpaterId)
	-- self:_setCityStatus(data,self._indexOfCell,cell,true)
	self:_setStarTextContent(cell, data.id, data.star, self._indexOfCell, true)
	self._indexOfCell = 0
end

function DungeonMainScene:_updateCell(list, index, cell)
	if #self._chapterList == 0 then return end
	-- 设置起始索引
	local num = self.listview:getDataLength()
	local _startIndex = #self._chapterList -(num - index) * 4
	for i = 4, 1, -1 do
		local data = dungeon_chapter_info.get(self._chapterList[_startIndex + 1])
        if data then
            if data.map > 0 then
				-- 设置城池名字
                local _name = cell:getLabelBMFontByName("BitmapLabel_" .. i)
                if _name then
                    _name:setText(data.name)
                end

                -- 设置第X章的位置
                local tSize = _name:getSize()
                local posX = _name:getPositionX() - (tSize.width/2 * _name:getScale())
                local labelChapter = cell:getLabelBMFontByName("BitmapLabel_Chapter"..i)
                -- 章节数、名称下面加底
                local labelChapterBg = cell:getImageViewByName("Image_Label_Bg"..i)
                local nameChapterBg = cell:getImageViewByName("Image_Name_Bg"..i)
                
                -- UI编辑器有bug先这样修改
                labelChapter:setPositionY(_name:getPositionY() + 50)

                -- 章节名字下方的副本星数
                local panelStar = cell:getPanelByName("Panel_Star"..i)

                if labelChapterBg and nameChapterBg and labelChapter and panelStar then
                	labelChapterBg:setPositionX(posX)
                	labelChapterBg:setPositionY(labelChapter:getPositionY())
                	nameChapterBg:setPositionX(posX)
                	nameChapterBg:setPositionY(_name:getPositionY() - 10)

                	panelStar:setPositionX(posX + 15)
                	panelStar:setPositionY(_name:getPositionY() - 40)
                end

                if labelChapter then
                	labelChapter:setPositionX(posX)
                	labelChapter:setText(G_lang:get("LANG_DUNGEON_CHAPTER_INDEX", {num=data.id}))
                end
                
                -- 显示小刀动画
                self:_addKnifeEffect(cell,i,_startIndex == 1)
                
                local pos = list:getCellTopLeftOffset(index)
                self.recordCellPos[data.id] = { cellIndex = index, cellPos = pos }

                if i == 4 then
                    if G_Me.dungeonData:isOpenChpater(data.id + 1) and data.id + 1 ~= self._newChpaterId then
                        cell:getImageViewByName("ImageView_LastRoad"):setVisible(true)
                    else
                        cell:getImageViewByName("ImageView_LastRoad"):setVisible(false)
                    end
                end
                
                cell:getImageViewByName("ImageView_City" .. i):setVisible(G_Me.dungeonData:isOpenChpater(data.id))
                if data.id == self._currOpenChapterId + 1 then
                    cell:getImageViewByName("ImageView_City" .. i):setVisible(true)
                end

                --            --记录此点需要显示动画
                if data.id == G_Me.dungeonData:getOpenNewChapterId() then
                    self._indexOfCell = i
                    self._newChpaterId = G_Me.dungeonData:getOpenNewChapterId()
                    -- 清除开启新章节标记
                    G_Me.dungeonData:clearOpenNewChapterId()
                else
                    
                end

                -- 新开启闪关动画
                if self.secretShine then
                    local tag = self.secretShine:getTag()
                    local _cellIndex =(tag == 4 and 1 or 0)
                    self.secretShine:setVisible(_cellIndex == index)
                    self.secretShine:getParent():setVisible(true)
                end

                -- 显示路线
                self:_setCityRoad(cell, i, data.id)
                -- 设置城池图标
                local _isShowLight = G_Me.dungeonData:isOpenChpater(data.id) and data.id ~= self._newChpaterId
                self:_showChapterImg(cell, data.image, _isShowLight, i, data.id)

                -- 提示是否有奖励领取
                if G_Me.dungeonData:isOpenChpater(data.id) then
                    cell:getImageViewByName("Image_Tips" .. i):setVisible(self:hasUnclaimedBox(PlotlineDungeonType.EASY, data))
                else
                    cell:getImageViewByName("Image_Tips" .. i):setVisible(false)
                end

                -- 设置城池开启状态
                self:_setCityStatus(data, i, cell, G_Me.dungeonData:isOpenChpater(data.id) and data.id ~= self._newChpaterId)

                -- 不是新开启章节并且章节已经开启则显示星数
                self:_setStarTextContent(cell, data.id, data.star, i, G_Me.dungeonData:isOpenChpater(data.id) and data.id ~= self._newChpaterId)
             	-- 最后一章 敬请期待显示
            	cell:showWidgetByName("BitmapLabel_Wait" .. i, false)
            else
 				self:_setCityRoad(cell, i, data.id)
            	-- 最后一章 敬请期待显示
       			cell:showWidgetByName("BitmapLabel_Wait" .. i, true)
       			cell:getLabelBMFontByName("BitmapLabel_Wait" .. i):setText(data.name)
       			
            	cell:getImageViewByName("ImageView_City" .. i):setTag(data.id)
            	cell:getImageViewByName("ImageView_City" .. i):setVisible(false)

        	end
			-- 这个cell最后一个城池,检查下个城池是否开启
		else
			cell:getImageViewByName("ImageView_City" .. i):setVisible(false)
		end
			_startIndex = _startIndex + 1
	end
    self:_addSceneEffect(cell)
end

-- @desc 检测城池是否开启
-- @param statusLabel 城池开启状态文本
function DungeonMainScene:_setCityStatus(data, index, cell, isShow)

	cell:getImageViewByName("ImageView_Po" .. index):setVisible(false)

	-- 如果关卡开启

	if isShow then
		local _starNum = G_Me.dungeonData:getChapterStar(data.id)
		if _starNum == data.goldbox_star then
			cell:getImageViewByName("ImageView_Po" .. index):setVisible(true)
		end
	else
		cell:getImageViewByName("ImageView_Po" .. index):setVisible(false)
	end

	if data.story_id > 0 and data.id == self.openChapterNum and self.isPassChapter == false then
		cell:getPanelByName("Panel_WuJiangZhuan" .. index):setVisible(true)
		local _passLabel = cell:getLabelByName("Label_Pass" .. index)
		local _wuJiangLabel = cell:getLabelByName("Label_WuJiang" .. index)
		local _data = story_dungeon_info.get(data.story_id)
		if _passLabel then
			_passLabel:setText(G_lang:get("LANG_DUNGEON_PASSCHAPTER"))
			_passLabel:createStroke(Colors.strokeBrown, 1)
		end

		if _wuJiangLabel then
			_wuJiangLabel:setText(_data.name)
			_wuJiangLabel:setPositionX(_passLabel:getPositionX() + _passLabel:getSize().width)
			_wuJiangLabel:createStroke(Colors.strokeBrown, 1)
		end
	else
		cell:getPanelByName("Panel_WuJiangZhuan" .. index):setVisible(false)
	end

end

-- @desc 显示章节图片
-- @param _parent 章节背景框
-- @param imgId 图片资源id
-- @param isOpen章节是否开启 没有开启则显示灰度图
-- @param index 城池索引
-- @param id 副本索引id

function DungeonMainScene:_showChapterImg(cell, imgId, isOpen, index, id)
	local _cityImage = cell:getImageViewByName("ImageView_City" .. index)
	-- 创建地图
	_cityImage:loadTexture(G_Path.getCityIcon(imgId))
	_cityImage:setTag(id)
	-- _cityImage:showAsGray(not isOpen)
	_cityImage:setVisible(isOpen)
end

-- @desc 设置富文本内容
-- @param chpaterId 章节id
-- @param starNum 章节星数
function DungeonMainScene:_setStarTextContent(_cell, chapterId, starNum, index, isOpen)
	local _currStarNum = G_Me.dungeonData:getChapterStar(chapterId) or 0
	local _panel = _cell:getPanelByName("Panel_Star" .. index)
	if _panel then
		local labelStar = _cell:getLabelByName("Label_Star" .. index)
		labelStar:setText(_currStarNum .. "/" .. starNum)
		labelStar:createStroke(Colors.strokeBlack, 2)

		local imageStarBg = _cell:getImageViewByName("Image_Star_Bg" .. index)
		imageStarBg:setPositionX(labelStar:getPositionX())
		imageStarBg:setPositionY(labelStar:getPositionY())
		
		_panel:setVisible(true)
		_panel:setVisible(isOpen)
	end

end

-- @desc 查找章节是否有未领取宝箱
function DungeonMainScene:isHaveBoxBouns(data)
	local _isOpenCopperbox, _isOpenSilverbox, _isOpenGoldbox =
	G_Me.dungeonData:getBoxStuatus(data.id)
	local totalStar = G_Me.dungeonData:getChapterStar(data.id)

	-- 铜宝箱是否有奖励
	if _isOpenCopperbox == false then
		if totalStar >= data.copperbox_star then
			return true
		end
	end

	-- 银宝箱是否有奖励
	if _isOpenSilverbox == false then
		if totalStar >= data.silverbox_star then
			return true
		end
	end

	-- 金宝箱
	if _isOpenGoldbox == false then
		if totalStar >= data.goldbox_star then
			return true
		end
	end

	-- 关卡宝箱
	local list = G_Me.dungeonData:getCurrChapterStageList(data.id)
	for k, v in pairs(list) do
		if v.gateType == 2 then
			local _stageinfo = dungeon_stage_info.get(k)
			if _stageinfo then
                            local statge_data = G_Me.dungeonData:getStageData(data.id, _stageinfo.premise_id)
                            if statge_data._star and statge_data._star > 0 and not v._isFinished then
                                    return true
                            end
			end
		end
	end
	return false
end


-- 判断整个主线副本普通模式有没有未领取的宝箱
function DungeonMainScene:_easyDungeonHasUnclaimedBox( ... )
	local tChapterList = G_Me.dungeonData.chapter
	for key, val in pairs(tChapterList) do
		local nChapterId = key
		if G_Me.dungeonData:isOpenChpater(nChapterId) then
			local tChapterTmpl = dungeon_chapter_info.get(nChapterId)
			if self:hasUnclaimedBox(PlotlineDungeonType.EASY, tChapterTmpl) then
				self._layer:showWidgetByName("Image_EasyTips", true)
				return
			end
		end
	end
	self._layer:showWidgetByName("Image_EasyTips", false)
end

-- 判断整个主线副本精英模式有没有未领取的宝箱
function DungeonMainScene:_hardDungeonHasUnclaimedBox()
	local hasAward = false
	local tChapterList = G_Me.hardDungeonData.chapter
	for key, val in pairs(tChapterList) do
		local nChapterId = key
		if G_Me.hardDungeonData:isOpenChpater(nChapterId) then
			local tChapterTmpl = hard_dungeon_chapter_info.get(nChapterId)
			if self:hasUnclaimedBox(PlotlineDungeonType.HARD, tChapterTmpl) then
				hasAward = true
				break
			end
		end
	end

	self._showHardTips = self._showHardTips or hasAward
	self._layer:showWidgetByName("Image_HardTips", self._showHardTips)
end

function DungeonMainScene:hasUnclaimedBox(nDungeonType, data)
	local _isOpenCopperbox, _isOpenSilverbox, _isOpenGoldbox = false, false, false
	local totalStar = 0
	if nDungeonType == PlotlineDungeonType.EASY then
		totalStar = G_Me.dungeonData:getChapterStar(data.id)
		_isOpenCopperbox, _isOpenSilverbox, _isOpenGoldbox = G_Me.dungeonData:getBoxStuatus(data.id)

		local list = G_Me.dungeonData:getCurrChapterStageList(data.id)
		for k, v in pairs(list) do
			if v.gateType == 2 then
				local _stageinfo = dungeon_stage_info.get(k)
				if _stageinfo then
	                local statge_data = G_Me.dungeonData:getStageData(data.id, _stageinfo.premise_id)
	                if statge_data._star and statge_data._star > 0 and not v._isFinished then
	                        return true
	                end
				end
			end
		end
	else
		totalStar = G_Me.hardDungeonData:getChapterStar(data.id)
		_isOpenCopperbox, _isOpenSilverbox, _isOpenGoldbox = G_Me.hardDungeonData:getBoxStuatus(data.id)

		-- 关卡宝箱
		local list = G_Me.hardDungeonData:getCurrChapterStageList(data.id)
		for k, v in pairs(list) do
			if v.gateType == 2 then
				local _stageinfo = hard_dungeon_stage_info.get(k)
				if _stageinfo then
	                local statge_data = G_Me.hardDungeonData:getStageData(data.id, _stageinfo.premise_id)
	                if statge_data._star and statge_data._star > 0 and not v._isFinished then
	                    return true
	                end
				end
			end
		end
	end

	-- 铜宝箱是否有奖励
	if _isOpenCopperbox == false then
		if totalStar >= data.copperbox_star then
			return true
		end
	end

	-- 银宝箱是否有奖励
	if _isOpenSilverbox == false then
		if totalStar >= data.silverbox_star then
			return true
		end
	end

	-- 金宝箱
	if _isOpenGoldbox == false then
		if totalStar >= data.goldbox_star then
			return true
		end
	end

	return false
end

-- 有没有精英副本暴动
function DungeonMainScene:_hasRiotEvent()
	local unlockFlag = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.HARD_DUNGEON_RIOT)
    if unlockFlag then
    	-- 若有精英暴动，也要显示红点
		local hasRiot = G_Me.hardDungeonData:curTimeExistRiotsAlive()
		if hasRiot then
			self._showHardTips = self._showHardTips or hasRiot
			self._layer:showWidgetByName("Image_HardTips", self._showHardTips)
			return
		end
    end
end

-- 若精英暴动有的新的可打的章节
function DungeonMainScene:_onUpdateHardTipsWithRiot()
	__Log("-- _onUpdateHardTipsWithRiot")
	self._showHardTips = self._showHardTips or G_Me.hardDungeonData:curTimeExistRiotsAlive()
	self._layer:showWidgetByName("Image_HardTips", self._showHardTips)
end

-- 玩家是否达到50级，并且没有进入过精英副本
function DungeonMainScene:_isEnteredHardDungeon()
	self._showHardTips = self._showHardTips or not G_Me.hardDungeonData:isEnteredHardDungeon()
	self._layer:showWidgetByName("Image_HardTips", self._showHardTips)
end

return DungeonMainScene