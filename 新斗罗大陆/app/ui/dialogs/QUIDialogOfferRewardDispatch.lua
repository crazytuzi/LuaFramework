

local QUIDialog = import(".QUIDialog")
local QUIDialogOfferRewardDispatch = class("QUIDialogOfferRewardDispatch", QUIDialog)
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetHeroSmallFrame = import("..widgets.QUIWidgetHeroSmallFrame")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QListView = import("...views.QListView")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QColorLabel = import("...utils.QColorLabel")

QUIDialogOfferRewardDispatch.TYPE_ALL = 1
QUIDialogOfferRewardDispatch.TYPE_TANK = 2
QUIDialogOfferRewardDispatch.TYPE_HEALTH = 3
QUIDialogOfferRewardDispatch.TYPE_PHYSICS = 4
QUIDialogOfferRewardDispatch.TYPE_MAGIC = 5


QUIDialogOfferRewardDispatch.TYPE_CHECK_STAR = 1
QUIDialogOfferRewardDispatch.TYPE_CHECK_APTITUDE = 2

local PerSatisfyValue = 100000



function QUIDialogOfferRewardDispatch:ctor(options)
	local ccbFile = "ccb/Dialog_OfferReward_Dispatch.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerType1", callback = handler(self, self._onTriggerType1)},
		{ccbCallbackName = "onTriggerType2", callback = handler(self, self._onTriggerType2)},
		{ccbCallbackName = "onTriggerType3", callback = handler(self, self._onTriggerType3)},
		{ccbCallbackName = "onTriggerType4", callback = handler(self, self._onTriggerType4)},
		{ccbCallbackName = "onTriggerType5", callback = handler(self, self._onTriggerType5)},
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
		{ccbCallbackName = "onTriggerClick3", callback = handler(self, self._onTriggerClick3)},
		{ccbCallbackName = "onTriggerClick4", callback = handler(self, self._onTriggerClick4)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerOneKey", callback = handler(self, self._onTriggerOneKey)},
	}
	QUIDialogOfferRewardDispatch.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.frame_tf_title:setVisible(false)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_one_key)
    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type1)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type2)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type3)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type4)
    -- q.setButtonEnableShadow(self._ccbOwner.btn_type5)


    self._dispatchHeros ={}
    self._selectTab = QUIDialogOfferRewardDispatch.TYPE_ALL
    self._taskId = options.taskId
    self._dispatchId = options.dispatchId
    self._countStar =0
    self._countAptitude =0
    self._curforce = 0

	self._targetForce =  0
	self._starCondi = 0
	self._starCount = 0
	self._aptitudeCondi = 0
	self._aptitudeCount = 0


    self._dispatchHeros = {}
end

function QUIDialogOfferRewardDispatch:viewDidAppear()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
	QUIDialogOfferRewardDispatch.super.viewDidAppear(self)
	self:_handleData()
	self:_initInfo()
	self:setInfo()
	self:initListView()
	self._lastItemNum = #self._items
end

function QUIDialogOfferRewardDispatch:viewWillDisappear()
	QUIDialogOfferRewardDispatch.super.viewWillDisappear(self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSmallFrame.EVENT_HERO_FRAMES_CLICK, self._onIconClick, self)
end

function QUIDialogOfferRewardDispatch:viewAnimationInHandler()
	--代码
	self:initListView()
end

function QUIDialogOfferRewardDispatch:_handleData()
	self._allItems = remote.offerreward:getDispatchHeroInfos() 
	self._offerReward = remote.offerreward:getOfferRewardTaskById(self._taskId)
	self._totalNumber = self._offerReward.hero_number

	self._func_type = QUIDialogOfferRewardDispatch.TYPE_ALL
	self._talent_type = HERO_TALENT.HEALTH
	if self._offerReward.func == "health" then
		self._func_type = QUIDialogOfferRewardDispatch.TYPE_HEALTH
		self._talent_type = HERO_TALENT.HEALTH
	elseif self._offerReward.func == "t" then
		self._func_type = QUIDialogOfferRewardDispatch.TYPE_TANK
		self._talent_type = HERO_TALENT.TANK
	elseif self._offerReward.func == "dps_p" then
		self._func_type = QUIDialogOfferRewardDispatch.TYPE_PHYSICS
		self._talent_type = HERO_TALENT.DPS_PHYSISC
	elseif self._offerReward.func == "dps_m" then
		self._func_type = QUIDialogOfferRewardDispatch.TYPE_MAGIC
		self._talent_type = HERO_TALENT.DPS_MAGIC
	end

	self._targetForce = self._offerReward.require or 0
	self._starCondi = 0
	self._starCount = 0
	self._aptitudeCondi = 0
	self._aptitudeCount = 0


	if self._offerReward.star then
		local checkStarTable = string.split(self._offerReward.star, "^")
		if checkStarTable[1] or checkStarTable[2] then
			self._starCondi = tonumber(checkStarTable[1])
			self._starCount = tonumber(checkStarTable[2])
		end
	end

	if self._offerReward.quality then
		local checkAptitudeTable = string.split(self._offerReward.quality, "^")
		if checkAptitudeTable[1] or checkAptitudeTable[2] then
			self._aptitudeCondi = tonumber(checkAptitudeTable[1])
			self._aptitudeCount = tonumber(checkAptitudeTable[2])
		end
	end


end

function QUIDialogOfferRewardDispatch:selectTabs()
	for i=1,5 do
		self._ccbOwner["btn_type"..i]:setEnabled(i ~= self._selectTab)
		self._ccbOwner["btn_type"..i]:setHighlighted(i == self._selectTab)
	end
	self:_showArray()
end

function QUIDialogOfferRewardDispatch:_initInfo()
	self:setForceColor(self._offerReward.require or 0 , self._ccbOwner.tf_need_force)

	self._ccbOwner.tf_need_force:setPositionX(self._ccbOwner.tf_desc_force_fst:getPositionX() + self._ccbOwner.tf_desc_force_fst:getContentSize().width + 2)
	self._ccbOwner.node_cur_force:setPositionX(self._ccbOwner.tf_need_force:getPositionX() + self._ccbOwner.tf_need_force:getContentSize().width + 2)

   	local colorInfo = FONTCOLOR_TO_OUTLINECOLOR[self._offerReward.aptitude + 1]
	if colorInfo then
		self._ccbOwner.tf_name:setColor(colorInfo.fontColor)
		self._ccbOwner.tf_name:setOutlineColor(colorInfo.outlineColor)
		self._ccbOwner.tf_name:enableOutline()
	end
	local sabcInfo = db:getSABCByAptitude(tonumber(self._offerReward.aptitude + 1))

 	q.setAptitudeShow(self._ccbOwner,sabcInfo.lower )


   	self._ccbOwner.node_talent:setVisible(true)
    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.node_talent:addChild(self._professionalIcon)
    end
    self._professionalIcon:setType(self._talent_type,false,1)

	self._ccbOwner.tf_name:setString(self._offerReward.name)
	--居中
	self._ccbOwner.node_father:setPositionX((4 - self._totalNumber) * 75)


	if self._starCondi > 0 and self._starCount > 0 then
		self._ccbOwner.tf_need_star:setString(self._starCount.."名"..self._starCondi.."星")
	end

	if self._aptitudeCondi > 0 and self._aptitudeCount > 0 then
		local sabcInfo = db:getSABCByQuality(self._aptitudeCondi)
		self._ccbOwner.tf_need_aptitude:setString(self._aptitudeCount.."名"..sabcInfo.qc.."级")
	end
end


function QUIDialogOfferRewardDispatch:setInfo()

	self:updateHero()
	self:selectTabs()
end


function QUIDialogOfferRewardDispatch:setForceColor(force , node_tf_force)
	force = tonumber(force)
	local colorInfo =remote.herosUtil:calculateForceColorAndOutline(force)
	
	if colorInfo then
		node_tf_force:setColor(colorInfo.fontColor)
		node_tf_force:setOutlineColor(colorInfo.outlineColor)
		node_tf_force:enableOutline()
	end
	local num,unit = q.convertLargerNumber(force)
	node_tf_force:setString(num..(unit or ""))
	-- node_tf_force:setString(force)
end

function QUIDialogOfferRewardDispatch:updateHero()
    self._curforce = 0


	local neddCheckAptitude = self:needCheckByType(QUIDialogOfferRewardDispatch.TYPE_CHECK_APTITUDE)
	local neddCheckStar = self:needCheckByType(QUIDialogOfferRewardDispatch.TYPE_CHECK_STAR)
    self._countStar =0
    self._countAptitude =0



	for i=1,4 do
		self._ccbOwner["node_hero_"..i]:removeAllChildren()
		if i > self._totalNumber then
			break
		end

		local info = self._dispatchHeros[i]
		local heroHead = QUIWidgetHeroHead.new()
		if info and info.heroInfo then
			heroHead:setHeroInfo(info.heroInfo)
        	heroHead:showSabc()
        	self._curforce = self._curforce + info.heroInfo.force

			local actorId = info.heroInfo.actorId
			if neddCheckAptitude then
				local characher = db:getCharacterByID(actorId)
				if characher and tonumber(characher.aptitude) >= tonumber(self._aptitudeCondi) then
					self._countAptitude = self._countAptitude + 1
				end
			end
			if neddCheckStar then
				local star = self._dispatchHeros[i].heroInfo.grade or 0
				star = star + 1
				if tonumber(star) >= tonumber(self._starCondi) then
					self._countStar = self._countStar + 1
				end
			end
		else
			heroHead:setHeroByFile(1,  QResPath("mockbattle_card_icon_bg")[1], 1)
			if i ~= 1 then
				heroHead:setProfessionByType(self._talent_type)
			end

		end
		heroHead:setScale(0.8)
		self._ccbOwner["node_hero_"..i]:addChild(heroHead)
	end

	self:_refreshConditionColorText(self._ccbOwner.node_cur_force ,self._curforce , self._offerReward.require or 0 )
	local width = 0
	local offSide = 0
	self._ccbOwner.node_need_star:setPositionX(-230)
	if neddCheckAptitude then
		width = self._ccbOwner.tf_desc_aptitude_fst:getContentSize().width + offSide + width
		self._ccbOwner.tf_need_aptitude:setPositionX(self._ccbOwner.tf_desc_aptitude_fst:getPositionX() + width)
		width = self._ccbOwner.tf_need_aptitude:getContentSize().width + offSide + width
		self._ccbOwner.tf_desc_aptitude_sec:setPositionX(self._ccbOwner.tf_desc_aptitude_fst:getPositionX() + width)
		width = self._ccbOwner.tf_desc_aptitude_sec:getContentSize().width + offSide + width
		self._ccbOwner.node_cur_aptitude:setPositionX(self._ccbOwner.tf_desc_aptitude_fst:getPositionX() + width)
		local colorTextWidth = self:_refreshConditionColorText(self._ccbOwner.node_cur_aptitude ,self._countAptitude , self._aptitudeCount)
		width = colorTextWidth + offSide + width
		self._ccbOwner.node_need_star:setPositionX(50)
	end

	width = 0
	if neddCheckStar then
		
		width = self._ccbOwner.tf_desc_star_fst:getContentSize().width + offSide + width
		self._ccbOwner.tf_need_star:setPositionX(self._ccbOwner.tf_desc_star_fst:getPositionX() + width)
		width = self._ccbOwner.tf_need_star:getContentSize().width + offSide + width
		self._ccbOwner.tf_desc_star_sec:setPositionX(self._ccbOwner.tf_desc_star_fst:getPositionX() + width)
		width = self._ccbOwner.tf_desc_star_sec:getContentSize().width + offSide + width
		self._ccbOwner.node_cur_star:setPositionX(self._ccbOwner.tf_desc_star_fst:getPositionX() + width)
		self:_refreshConditionColorText(self._ccbOwner.node_cur_star ,self._countStar , self._starCount)
	end
	self._ccbOwner.node_need_aptitude:setVisible(neddCheckAptitude)
	self._ccbOwner.node_need_star:setVisible(neddCheckStar)
end



function QUIDialogOfferRewardDispatch:_refreshConditionColorText( _node , _curValue , _conditionValue )
	local width = 0
	_conditionValue = _conditionValue or 0
	_node:removeAllChildren()
	local desc  = "##e(".."##x".._curValue.."##e/".._conditionValue..")"
	if _curValue >= _conditionValue then
		 desc  = "##e(".."##g".._curValue.."##e/".._conditionValue..")"
	end

	local text = QColorLabel:create(desc, 500, nil, nil, 20, GAME_COLOR_LIGHT.stress)
	text:setAnchorPoint(ccp(0, 0.5))
	_node:addChild(text)
	width = text:getContentSize().width

	return width
end


function QUIDialogOfferRewardDispatch:initListView( ... )
	-- body
	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_content:getContentSize())
		self._listViewLayout:resetTouchRect()
	end

	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._items[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
					item = QUIWidgetHeroSmallFrame.new()
	            	isCacheNode = false
	            end
	            item:setDispatchHeroInfo(itemData,self:checkHeroIsInArray(itemData))
	            item:setFramePos(index)
	            item:initGLLayer()
	            item:setScale(0.8)
	            info.item = item
	            info.size = cc.size(120,160)
                list:registerBtnHandler(index,"btn_team", "_onTriggerHeroOverview")
	            return isCacheNode
	        end,
	        isVertical = false,
	        curOriginOffset = 10,
	        -- curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	contentOffsetY = 0,
	        totalNumber = #self._items,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		if self._lastItemNum == #self._items then
			self._listViewLayout:refreshData() 
		else
			self._listViewLayout:reload({totalNumber = #self._items}) 
			self._lastItemNum = #self._items
		end
	end
end

function QUIDialogOfferRewardDispatch:_showArray()
	self._items = {}
	if self._selectTab == QUIDialogOfferRewardDispatch.TYPE_ALL then
		self._items = self._allItems
	else
		for i,v in ipairs(self._allItems or {}) do
			if v.func == self._selectTab  then
				table.insert(self._items , v )
			end
		end
	end
	self:initListView()

end

function QUIDialogOfferRewardDispatch:_onIconClick(event)
	-- event.actorId
	print(" event.actorId "..event.pos)
	local info = self._items[event.pos]

	if info.isUsed then
		app.tip:floatTip("该魂师已派遣至别的悬赏任务，无法继续派遣")

		return
	end

	if self:checkArrayPutDownHero(info) then
		return
	end
	if self:checkArrayPutUpHero(info) then
		return
	end
end


function QUIDialogOfferRewardDispatch:checkArrayPutUpHero(info)
	local sortTable ={}
	if self._totalNumber > 1 then
		if self._func_type ~= info.func then
			for i=1,self._totalNumber do
				table.insert(sortTable,i)
			end
		else
			for i=1,self._totalNumber - 1 do
				table.insert(sortTable,i + 1)
			end
			table.insert(sortTable,1)
		end
	else
		table.insert(sortTable,1)
	end
	for i,v in ipairs(sortTable) do
		if self._dispatchHeros[v] == nil  then
			if self._func_type ~= info.func and v ~= 1 then
				app.tip:floatTip("无法派遣，魂师相应类型不匹配")
				return false
			end

			self._dispatchHeros[v] = {}
			self._dispatchHeros[v].heroInfo = info.heroInfo
			self._dispatchHeros[v].userId = info.userId
			self:setInfo()
			if v == 1 and self._totalNumber > 1 then
				self:switchByTalentType()
			end
			return true
		end
	end
	app.tip:floatTip("派遣人数已满，无法派遣更多的魂师")
	return false
end

function QUIDialogOfferRewardDispatch:checkArrayPutDownHero(info)

	for i=1,self._totalNumber do
		if self._dispatchHeros[i] ~= nil 
			and info.heroInfo.actorId == self._dispatchHeros[i].heroInfo.actorId 
			and info.userId == self._dispatchHeros[i].userId then
			self:arrayPutDownHero(i)
			return true
		end
	end
	return false
end

function QUIDialogOfferRewardDispatch:checkHeroIsInArray(info)

	for i=1,self._totalNumber do
		if self._dispatchHeros[i] ~= nil 
			and info.heroInfo.actorId == self._dispatchHeros[i].heroInfo.actorId 
			and info.userId == self._dispatchHeros[i].userId then
			return true
		end
	end
	return false
end


function QUIDialogOfferRewardDispatch:switchByTalentType()

	local num = 0
	for i=1,self._totalNumber do
		if self._dispatchHeros[i] ~= nil and self._dispatchHeros[i].userId and self._dispatchHeros[i].heroInfo  then
			num = num + 1
		end
	end
	if self._totalNumber <= num then
		return
	end

	if self._func_type ~= self._selectTab then
    	app.sound:playSound("common_switch")
    	self._selectTab = self._func_type
		self:selectTabs()
	end
end


function QUIDialogOfferRewardDispatch:arrayPutDownHero(idx)
	if self._dispatchHeros[idx] == nil then return end
	-- table.remove(self._dispatchHeros,idx)
	self._dispatchHeros[idx]  = nil

	self:setInfo()
end


function QUIDialogOfferRewardDispatch:handleOneKeyData( )
	-- body
	local handleTable = {}
	local totleTable = {}
	for i,v in ipairs(self._allItems or {}) do
		if not v.isUsed  then -- 排除已派遣的
			local info = {}
			info.idx = i
			info.force = v.heroInfo.force
			info.gradeWeight = 1
			info.aptitudeWeight = 1
			info.gradeCheck = 1
			info.aptitudeCheck = 1
			info.forceWeight =  0
			info.funcCount = v.func == self._func_type and 1 or 0

			if self:needCheckByType(QUIDialogOfferRewardDispatch.TYPE_CHECK_STAR) then
				local star = v.heroInfo.grade or 0
				star = star + 1
				info.gradeWeight = self._starCondi / star
				info.gradeCheck = star >= self._starCondi and 1 or 0
			end
			if self:needCheckByType(QUIDialogOfferRewardDispatch.TYPE_CHECK_APTITUDE) then
				info.aptitudeCheck = 0
				local characher = db:getCharacterByID(v.heroInfo.actorId)
				if characher then
					local aptitude = characher.aptitude or 1
					info.aptitudeWeight =  self._aptitudeCondi / aptitude
					info.aptitudeCheck = aptitude >= self._aptitudeCondi and 1 or 0
				end
			end
			table.insert(totleTable , info )
		end
	end

	table.sort(totleTable, function (x, y)
		return x.force > y.force
		end)
	--设置战斗力权重
	for i,info in ipairs(totleTable) do
		info.forceWeight =  i / #totleTable
	end

	self:foo(1 , totleTable , {} , 0)


end

function QUIDialogOfferRewardDispatch:foo(counter,totleTable,handleTable , oldWeight)

	if counter > #totleTable then
		-- QPrintTable(handleTable)
		-- print(oldWeight)
		if tonumber(oldWeight) < PerSatisfyValue * 4  then
			app.tip:floatTip("没有符合要求的派遣魂师")
			return
		end

		local idx = 2
		-- QPrintTable(handleTable)
		for i,info in ipairs(handleTable) do
			local itemInfo = self._allItems[info.idx]
			local index_ = 1
			if info.funcCount == 1 then
				index_ = idx
				if index_ > self._totalNumber then
					index_ = 1 -- 若大于最大上限说明本次最优解都是限定魂师 第一个位置也是
				end
				idx = idx + 1
			end	
			self._dispatchHeros[index_] = {}
			self._dispatchHeros[index_].heroInfo = itemInfo.heroInfo
			self._dispatchHeros[index_].userId = itemInfo.userId
		end

		self:setInfo()
		return
	end

	local compareWeight = oldWeight
	local compareIdx = 0
	local curData = totleTable[counter]
	if #handleTable < self._totalNumber then
		table.insert(handleTable , curData )
	else
		for i=1,self._totalNumber do
			local curWeight = self:getWeightByData(handleTable,i,curData)
			if curWeight >= compareWeight then
				compareIdx = i
				compareWeight = curWeight
			end
		end
		handleTable[compareIdx] = curData
	end
	-- QPrintTable(handleTable)
	self:foo(counter + 1 , totleTable , handleTable, compareWeight)
end


function QUIDialogOfferRewardDispatch:getWeightByData(handleTable , idx ,curData)
	local weight = 0 
	local countStar = 0 
	local countAptitude = 0 
	local curforce = 0 
	local countFunc = 0 

	for i=1,self._totalNumber do
		local info = handleTable[i]
		if i == idx then
			info = curData
		end
		weight = weight + info.gradeWeight + info.aptitudeWeight + info.forceWeight
		countStar = countStar + info.gradeCheck
		countAptitude = countAptitude + info.aptitudeCheck
		curforce = curforce + info.force
		countFunc = countFunc + info.funcCount
	end
	if countStar >= self._starCount then
		weight = weight + PerSatisfyValue
	end
	if countAptitude >= self._aptitudeCount then
		weight = weight + PerSatisfyValue
	end
	if countFunc >= self._totalNumber - 1 then
		weight = weight + PerSatisfyValue
	else
		local func_weight = PerSatisfyValue * countFunc / (self._totalNumber - 1)
		func_weight = func_weight / (self._totalNumber - 1 )
		weight = weight + func_weight

	end
	if curforce >= self._targetForce then
		weight = weight + PerSatisfyValue
	end

	return weight
end

function QUIDialogOfferRewardDispatch:_onTriggerType1(event)
	if self._selectTab == QUIDialogOfferRewardDispatch.TYPE_ALL then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogOfferRewardDispatch.TYPE_ALL

	self:selectTabs()
end

function QUIDialogOfferRewardDispatch:_onTriggerType2(event)
	if self._selectTab == QUIDialogOfferRewardDispatch.TYPE_TANK then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogOfferRewardDispatch.TYPE_TANK
	self:selectTabs()
end

function QUIDialogOfferRewardDispatch:_onTriggerType3(event)
	if self._selectTab == QUIDialogOfferRewardDispatch.TYPE_HEALTH then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogOfferRewardDispatch.TYPE_HEALTH
	self:selectTabs()
end

function QUIDialogOfferRewardDispatch:_onTriggerType4(event)
	if self._selectTab == QUIDialogOfferRewardDispatch.TYPE_PHYSICS then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogOfferRewardDispatch.TYPE_PHYSICS
	self:selectTabs()
end

function QUIDialogOfferRewardDispatch:_onTriggerType5(event)
	if self._selectTab == QUIDialogOfferRewardDispatch.TYPE_MAGIC then return end
    app.sound:playSound("common_switch")
	self._selectTab = QUIDialogOfferRewardDispatch.TYPE_MAGIC
	self:selectTabs()
end


function QUIDialogOfferRewardDispatch:_onTriggerClick1( )
	self:arrayPutDownHero(1)
end

function QUIDialogOfferRewardDispatch:_onTriggerClick2( )
	if self._totalNumber < 2 then
		return
	end
	self:arrayPutDownHero(2)

end

function QUIDialogOfferRewardDispatch:_onTriggerClick3( )
	if self._totalNumber < 3 then
		return
	end
	self:arrayPutDownHero(3)
end

function QUIDialogOfferRewardDispatch:_onTriggerClick4( )
	if self._totalNumber < 4 then
		return
	end	
	self:arrayPutDownHero(4)
end

function QUIDialogOfferRewardDispatch:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogOfferRewardDispatch:_onTriggerOK()
    app.sound:playSound("common_small")

	local heroInfos = {}
	local curforce = 0
	local neddCheckAptitude = false
	local neddCheckStar = false
	local checkStarTable = {}
	local checkAptitudeTable = {}
	local countStar = 0
	local countAptitude = 0

	if self._offerReward.star then
		neddCheckStar = true
		checkStarTable = string.split(self._offerReward.star, "^")
	end

	if self._offerReward.quality then
		neddCheckAptitude = true
		checkAptitudeTable = string.split(self._offerReward.quality, "^")
	end

	-- QPrintTable(self._dispatchHeros)
	for i=1,self._totalNumber do
		if self._dispatchHeros[i] ~= nil and self._dispatchHeros[i].userId and self._dispatchHeros[i].heroInfo  then

			local userId = self._dispatchHeros[i].userId
			local actorId = self._dispatchHeros[i].heroInfo.actorId
			table.insert(heroInfos ,{userId = userId , actorId = actorId} )
		end
	end

	if q.isEmpty(heroInfos) then
		app.tip:floatTip("请添加需要派遣的魂师")
		return
	end

	if self:needCheckByType(QUIDialogOfferRewardDispatch.TYPE_CHECK_APTITUDE) and self._countAptitude < self._aptitudeCount then
		app.tip:floatTip("派遣的魂师品质没有达到要求")
		return
	end

	if self:needCheckByType(QUIDialogOfferRewardDispatch.TYPE_CHECK_STAR) and self._countStar < self._starCount then
		app.tip:floatTip("派遣的魂师星级没有达到要求")
		return
	end

	if self._offerReward.require > self._curforce then
		app.tip:floatTip("派遣的魂师战斗力不足")
		return
	end

	if #heroInfos < self._totalNumber then
		app.tip:floatTip("上阵魂师不足，无法派遣")
		return
	end
	-- QPrintTable(heroInfos)

	local  success = function ( ... )
		-- body
		app.tip:floatTip("任务派遣成功")
		self:_onTriggerClose()
	end

	remote.offerreward:offerRewardDispatchHeroRequest(heroInfos , self._dispatchId , success , handler(self, self._onTriggerClose) )
end

function QUIDialogOfferRewardDispatch:_onTriggerOneKey()
    app.sound:playSound("common_small")
	self:handleOneKeyData( )
end

function QUIDialogOfferRewardDispatch:needCheckByType(checkType)

	if QUIDialogOfferRewardDispatch.TYPE_CHECK_STAR == checkType then
		return self._starCondi > 0 and self._starCount > 0
	elseif QUIDialogOfferRewardDispatch.TYPE_CHECK_APTITUDE == checkType then
		return self._aptitudeCondi > 0 and self._aptitudeCount > 0
	end
	return false
end


return QUIDialogOfferRewardDispatch