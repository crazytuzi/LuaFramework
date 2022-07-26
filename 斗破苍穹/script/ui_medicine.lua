UIMedicine = {}

local PILL_POINTS = {
	_3 = {{x=311,y=493},{x=454,y=149},{x=163,y=149}},
	_4 = {{x=454,y=462},{x=454,y=149},{x=163,y=149},{x=163,y=462}},
	_5 = {{x=454,y=462},{x=454,y=149},{x=163,y=149},{x=163,y=462},{x=311,y=299}},
	_6 = {{x=311,y=493},{x=454,y=462},{x=454,y=149},{x=311,y=101},{x=163,y=149},{x=163,y=462}},
	_7 = {{x=311,y=493},{x=454,y=462},{x=454,y=149},{x=311,y=101},{x=163,y=149},{x=163,y=462},{x=311,y=299}},
	_8 = {{x=311,y=193},{x=454,y=462},{x=504,y=299},{x=454,y=149},{x=311,y=101},{x=163,y=149},{x=109,y=299},{x=163,y=462}},
	_9 = {{x=311,y=193},{x=454,y=462},{x=504,y=299},{x=454,y=149},{x=311,y=101},{x=163,y=149},{x=109,y=299},{x=163,y=462},{x=311,y=299}},
}

local ui_scrollView = nil
local ui_svItem = nil
local topLabelBtns = nil
local pageView = nil
local pageViewItem = nil
local pillInfoItem = nil

local _instConstellIds = nil --所有命宫实例ID
local _curCardLv = 0 --当前卡牌等级
local _curPageViewIndex = 0
local _curOpeningIndex = 1 --当前正在开启的命宫数组下标索引

local _effectAnims = nil

UIMedicine.isOpenNew = nil --是否开启新的命宫
local _openNew = nil

---@flag : 0表示坐下,1表示右上
local function myPathFun(controlX, controlY, w, time, flag)
--	local time = 0.5
	if flag == 0 then
		local bezier1 = {
			cc.p(-controlX, 0),
			cc.p(-controlX, controlY),
			cc.p(0, controlY),
		}
		local bezierBy1 = cc.BezierBy:create(time, bezier1)
		local move1 = cc.MoveBy:create(time, cc.p(w, 0))
		local bezier2 = {
			cc.p(controlX, 0),
			cc.p(controlX, -controlY),
			cc.p(0, -controlY),
		}
		local bezierBy2 = cc.BezierBy:create(time, bezier2)
		local move2 = cc.MoveBy:create(time, cc.p(-w, 0))
		local path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
		if w == 0 then
			path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, bezierBy2))
		end
		return path
	elseif flag == 1 then
		local bezier1 = {
			cc.p(controlX, 0),
			cc.p(controlX, -controlY),
			cc.p(0, -controlY),
		}
		local bezierBy1 = cc.BezierBy:create(time, bezier1)
		local move1 = cc.MoveBy:create(time, cc.p(-w, 0))
		local bezier2 = {
			cc.p(-controlX, 0),
			cc.p(-controlX, controlY),
			cc.p(0, controlY),
		}
		local bezierBy2 = cc.BezierBy:create(time, bezier2)
		local move2 = cc.MoveBy:create(time, cc.p(w, 0))
		local path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
		if w == 0 then
			path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, bezierBy2))
		end
		return path
	end
end

---@flag : 状态'炼' (默认是'服'的状态)
local function addStatusEffect(node, pos, _flag)
	if _effectAnims == nil then
		_effectAnims = {}
	end
	local effectAnim = ActionManager.getEffectAnimation(8)
	effectAnim:setPosition(pos.x + 2, pos.y)
	effectAnim:setScale(1.5)
	if _flag then
		effectAnim:getBone("Layer1"):addDisplay(ccs.Skin:create("image/ui_anim8_02.png"),0)
	end
	node:addChild(effectAnim)
	_effectAnims[#_effectAnims + 1] = effectAnim
end

local function cleanStatusEffect()
	if _effectAnims then
		for key, obj in pairs(_effectAnims) do
			obj:removeFromParent()
		end
	end
	_effectAnims = nil
end

local function addPillEffect(node)
	for _i = 1, 2 do
		local effect = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
		node:addChild(effect)
		effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
		if _i == 1 then
			effect:setPosition(cc.p(50, 0))
			effect:runAction(myPathFun(node:getContentSize().width - 40, node:getContentSize().height, 0, 0.5, 0))
		else
			effect:setPosition(cc.p(node:getContentSize().width - 50, node:getContentSize().height))
			effect:runAction(myPathFun(node:getContentSize().width - 40, node:getContentSize().height, 0, 0.5, 1))
		end
	end
end

local function setScrollViewFocus(isJumpTo)
	local childs = ui_scrollView:getChildren()
	for key, obj in pairs(childs) do
		local ui_focus = obj:getChildByName("image_wfg")
		if _curPageViewIndex + 1 == key then
			ui_focus:setVisible(true)

			local contaniner = ui_scrollView:getInnerContainer()
			local w = (contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
			local dt
			if w == 0 then
				dt = 0
			else
				dt = (obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
				if dt < 0 then
					dt = 0
				end
			end
			if isJumpTo then
				ui_scrollView:jumpToPercentHorizontal(dt * 100)
			else
				ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
			end

		else
			ui_focus:setVisible(false)
		end
	end
end

local function setPageViewItem(item, index, data)
	local instConstellId = data.int["1"] --命宫实例ID
	local dictConstellId = data.int["4"] --命宫字典ID
	local isUse = data.string["5"] --命宫丹药状态 0-未服用 1-服用（全为1表示该命宫点亮）
	local dictConstellData = DictConstell[tostring(dictConstellId)]
	local pills = dictConstellData.pills --丹药 丹药字典Id用分号隔开
	topLabelBtns[index]:setTitleText(dictConstellData.name)
	item:getChildByName("text_minggong"):setString(dictConstellData.name)
	local pillItem = item:getChildByName("image_medicine")
	
	if index < _curOpeningIndex then --开启
		topLabelBtns[index]:loadTextures("ui/mg_ld_di01.png", "ui/mg_ld_di01.png")
		topLabelBtns[index]:setTitleColor(cc.c3b(50, 50, 50))
		--[[
		local _offset = 393/2
		local _p = cc.p(120, item:getContentSize().height - 517)
		local _effect = {}
		for i = 1, 3 do
			_effect[i] = cc.ParticleSystemQuad:create("particle/ui_anim8_effect1.plist")
			_effect[i]:setPosition(cc.p(_p.x + _offset, _p.y))
			item:addChild(_effect[i])
		end
		for key, obj in pairs(_effect) do
			obj:setPositionType(cc.POSITION_TYPE_RELATIVE)
			obj:runAction(myPathFun(250, 393, 0, 1.5, 0))
		end
		--]]
	elseif index == _curOpeningIndex then --正在开启中。。。
		topLabelBtns[index]:loadTextures("ui/mg_ld_di02.png", "ui/mg_ld_di02.png")
		topLabelBtns[index]:setTitleColor(cc.c3b(0, 0, 0))
	else --未开启
		topLabelBtns[index]:loadTextures("ui/mg_ld_di03.png", "ui/mg_ld_di03.png")
		topLabelBtns[index]:setTitleColor(cc.c3b(50, 50, 50))
	end
	topLabelBtns[index]:setPressedActionEnabled(true)
	local function onLabelBtnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			pageView:scrollToPage(index - 1)
		end
	end
	topLabelBtns[index]:addTouchEventListener(onLabelBtnEvent)
	
	local _isUses = utils.stringSplit(isUse, ";")
	local dictPillIds = utils.stringSplit(pills, ";")
	local points = PILL_POINTS["_" .. #dictPillIds]
	for key, id in pairs(dictPillIds) do
		local _pillItem = nil
		if key == 1 then
			_pillItem = pillItem
		else
			_pillItem = pillInfoItem:clone()
			item:addChild(_pillItem)
		end
		_pillItem:setLocalZOrder(1)
		_pillItem:setPosition(cc.p(points[key].x, points[key].y))

		local _pillIcon = _pillItem:getChildByName("image_medicine") --丹药图标
		local _pillName = ccui.Helper:seekNodeByName(_pillItem, "text_medicine_name") --丹药名称
		local _pillState = ccui.Helper:seekNodeByName(_pillItem, "image_eat") --丹药状态图标（服 or 炼）
		_pillState:setVisible(false)
		
		local dictPillData = DictPill[tostring(id)]
		_pillName:setString(dictPillData.name)
		if index < _curOpeningIndex then --开启
			_pillIcon:loadTexture("image/" .. DictUI[tostring(dictPillData.smallUiId)].fileName)
			addPillEffect(_pillItem:getChildByName("image_frame"))
			local dictTableType = DictTableType[tostring(dictPillData.tableTypeId)]
			if dictTableType.id == StaticTableType.DictFightProp then
				local dictFightProp = DictFightProp[tostring(dictPillData.tableFieldId)]
				_pillName:setString(dictFightProp.name .. "+" .. dictPillData.value)
			end
		elseif index == _curOpeningIndex then --正在开启中。。。
			if tonumber(_isUses[key]) == 1 then
				_pillIcon:loadTexture("image/" .. DictUI[tostring(dictPillData.smallUiId)].fileName)
				addPillEffect(_pillItem:getChildByName("image_frame"))
				local dictTableType = DictTableType[tostring(dictPillData.tableTypeId)]
				if dictTableType.id == StaticTableType.DictFightProp then
					local dictFightProp = DictFightProp[tostring(dictPillData.tableFieldId)]
					_pillName:setString(dictFightProp.name .. "+" .. dictPillData.value)
				end
			else
--				if utils.getPillCount(dictPillData.id) >= 1 and _curCardLv >= dictPillData.cardlevel then
				if utils.getPillCount(dictPillData.id) >= 1 then
					_pillState:setVisible(true)
					_pillState:loadTexture("ui/mg_fu.png") --服
					addStatusEffect(item, points[key])
				else
					local dictPillRecipeData = DictPillRecipe[tostring(dictPillData.prescriptId)] --药方字典数据
					local pillRecipeCount = utils.getPillRecipeCount(dictPillRecipeData.id) --药方数量
					local thingOne = utils.stringSplit(dictPillRecipeData.thingOne, "_")
					local thingTwo = utils.stringSplit(dictPillRecipeData.thingTwo, "_")
					local thingThree = utils.stringSplit(dictPillRecipeData.thingThree, "_")
					if pillRecipeCount >= 1 and utils.getPillThingCount(thingOne[1]) >= tonumber(thingOne[2]) 
						and utils.getPillThingCount(thingTwo[1]) >= tonumber(thingTwo[2]) and utils.getPillThingCount(thingThree[1]) >= tonumber(thingThree[2]) then
						_pillState:setVisible(true)
						_pillState:loadTexture("ui/mg_lian.png") --炼
						addStatusEffect(item, points[key], true)
					end
				end
				_pillIcon:loadTexture("ui/frame_tianjia.png")
				local function pillItemEvent(sender, eventType)
					if eventType == ccui.TouchEventType.ended then
						UIMedicineAlchemy.setDictPillData(dictPillData)
						UIMedicineAlchemy.setPosition(key)
						UIMedicineAlchemy.setCurCardLv(_curCardLv)
						UIMedicineAlchemy.setInstConstellId(instConstellId)
						UIManager.pushScene("ui_medicine_alchemy")
					end
				end
				_pillItem:setTouchEnabled(true)
				_pillItem:addTouchEventListener(pillItemEvent)
			end
		else --未开启
			_pillIcon:loadTexture("ui/mg_suo.png")
			_pillName:getParent():setVisible(false)
		end
	end
end

function UIMedicine.init()
	local btn_close = ccui.Helper:seekNodeByName(UIMedicine.Widget, "btn_close")
	local btn_back = ccui.Helper:seekNodeByName(UIMedicine.Widget, "btn_back")
	btn_close:setPressedActionEnabled(true)
	btn_back:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close or sender == btn_back then
                if not UIMedicine.isOpenNew then
				    UIManager.popScene()
                end
			end
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_back:addTouchEventListener(btnTouchEvent)
	
	ui_scrollView = ccui.Helper:seekNodeByName(UIMedicine.Widget, "view_medicine")
	ui_svItem = ui_scrollView:getChildByName("btn_minggong"):clone()
	if ui_svItem:getReferenceCount() == 1 then
		ui_svItem:retain()
	end
	
	pageView = ccui.Helper:seekNodeByName(UIMedicine.Widget, "view_page")
	pageViewItem = pageView:getChildByName("panel_page"):clone()
	pillInfoItem = pageViewItem:getChildByName("image_medicine"):clone()
	if pageViewItem:getReferenceCount() == 1 then
		pageViewItem:retain()
	end
	if pillInfoItem:getReferenceCount() == 1 then
		pillInfoItem:retain()
	end
end

function UIMedicine.setup()
	cleanStatusEffect()
	
	ui_scrollView:removeAllChildren()
	pageView:removeAllPages()
	pageView:removeAllChildren()
	
	_curPageViewIndex = 0
	_curOpeningIndex = 1

	if _instConstellIds then
		local instConstellId_table = utils.stringSplit(_instConstellIds, ";")
		local _openKey = nil
		for key, id in pairs(instConstellId_table) do
			local instConstellData = net.InstPlayerConstell[tostring(id)] --命宫实例数据
			local isUse = instConstellData.string["5"] --命宫丹药状态 0-未服用 1-服用（全为1表示该命宫点亮）
			local _isUses = utils.stringSplit(isUse, ";")
			local _open = ""
			for i = 1, #_isUses do
				if i == #_isUses then
					_open = _open .. "1"
				else
					_open = _open .. "1;"
				end
			end
			if isUse == _open then --开启
				_openKey = key
			end
		end
        if not _openNew then
            if _openKey then
                _openNew = _openKey
            else
                _openNew = 0
            end
        end
		if _openKey then
            cclog("-----------------------> _openKey ".."   ".._openKey.."  ".._openNew )
            if  UIMedicine.isOpenNew and _openNew == _openKey - 1 and _openKey < #instConstellId_table then
                cclog("-----------------------> _openNew ")
                UIMedicine.Widget:runAction( cc.Sequence:create( cc.DelayTime:create(0.5) , cc.CallFunc:create(function()
            
			    utils.playArmature(47 , "ui_anim47" , UIManager.gameLayer , 0 , -45 , function ()
                    UIMedicine.isOpenNew = nil
                    _openNew = _openKey
                end)
            end)) ) 
            else
                UIMedicine.isOpenNew = nil
            end
			_curOpeningIndex = _openKey + 1        
            
        else
            if UIMedicine.isOpenNew then
                UIMedicine.isOpenNew = nil
            end
		end
		topLabelBtns = {}
		local innerWidth, space = 0, 0
		for key, id in pairs(instConstellId_table) do
			local instConstellData = net.InstPlayerConstell[tostring(id)] --命宫实例数据
			topLabelBtns[key] = ui_svItem:clone()
			ui_scrollView:addChild(topLabelBtns[key])
			innerWidth = innerWidth + topLabelBtns[key]:getContentSize().width + space
			local _pvItem = pageViewItem:clone()
			setPageViewItem(_pvItem, key, instConstellData)
			pageView:addPage(_pvItem)
			if key == 1 and UIGuidePeople.levelStep then 
				UIGuidePeople.isGuide(_pvItem:getChildByName("image_medicine"),UIMedicine)
			end
		end
		if innerWidth < ui_scrollView:getContentSize().width then
			innerWidth = ui_scrollView:getContentSize().width
		end
		ui_scrollView:setInnerContainerSize(cc.size(innerWidth, ui_scrollView:getContentSize().height))
--		local childs = ui_scrollView:getChildren()
		local prevChild = nil
		for i = 1, #topLabelBtns do
			if prevChild then
				topLabelBtns[i]:setPosition(cc.p(prevChild:getRightBoundary() + topLabelBtns[i]:getContentSize().width / 2 + space, ui_scrollView:getContentSize().height / 2))
			else
				topLabelBtns[i]:setPosition(cc.p(topLabelBtns[i]:getContentSize().width / 2 + space, ui_scrollView:getContentSize().height / 2))
			end
			prevChild = topLabelBtns[i]
		end
		local function pageViewEvent(sender, eventType)
			if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
				_curPageViewIndex = sender:getCurPageIndex()
				setScrollViewFocus()
			end
		end
		pageView:addEventListener(pageViewEvent)
		
		pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
			pageView:scrollToPage(_curOpeningIndex - 1)
			if _curOpeningIndex == 1 then
				setScrollViewFocus()
			end
		end)))
	end
end

function UIMedicine.setCurCardLv(cardLv)
	_curCardLv = cardLv
end

function UIMedicine.InstPlayerConstells(instConstellIds)
	_instConstellIds = instConstellIds
end

function UIMedicine.free()
	cleanStatusEffect()
	if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
		ui_svItem:release()
		ui_svItem = nil
	end
	ui_scrollView:removeAllChildren()
	if pageViewItem and pageViewItem:getReferenceCount() >= 1 then
		pageViewItem:release()
		pageViewItem = nil
	end
	if pillInfoItem and pillInfoItem:getReferenceCount() >= 1 then
		pillInfoItem:release()
		pillInfoItem = nil
	end
	pageView:removeAllPages()
	pageView:removeAllChildren()
    UIMedicine.isOpenNew = nil
    _openNew = nil
end