local LegionTechCell = require("app.scenes.legion.LegionTechCell")
local LegionTechLayer = class("LegionTechLayer", UFCCSNormalLayer)
require("app.cfg.corps_technology_info")

function LegionTechLayer.create(...)
    return LegionTechLayer.new("ui_layout/legion_TechLayer.json", ...)
end

function LegionTechLayer:ctor(...)
	self.super.ctor(self, ...)
	self._hasInited = false
	self._inited = {}
	self._views = {}
	self._showCell = nil
	self._checkName = {"CheckBox_learn","CheckBox_tech"}
	self._maxCount = corps_technology_info.indexOf(corps_technology_info.getLength()).id
	self._showList = {}
	self._lastCorpAttr = 0
	self._lastCorpExp = 0
	self._numAttrChanger = nil
	self._numExpChanger = nil
	self:updateShowList(1)
	self:updateShowList(2)
	self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)

	self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_exp"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_attr"):createStroke(Colors.strokeBrown, 1)
	self._namelabel = self:getLabelByName("Label_nameValue")
	self._explabel = self:getLabelByName("Label_expValue")
	self._attrlabel = self:getLabelByName("Label_attrValue")
	self._namelabel:createStroke(Colors.strokeBrown, 1)
	self._explabel:createStroke(Colors.strokeBrown, 1)
	self._attrlabel:createStroke(Colors.strokeBrown, 1)

	self:getCheckBoxByName("CheckBox_tech"):setVisible(G_Me.legionData:getCorpDetail().position > 0)

	self:registerBtnClickEvent("Button_back", function(widget) 
	    self:onBackKeyEvent()
	    end)
	self:registerBtnClickEvent("Button_help", function(widget) 
		self:onHelp()
	    end)
end

function LegionTechLayer:onHelp( )
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_LEGION_TECH_HELPTITLE"), content=G_lang:get("LANG_LEGION_TECH_HELPVALUE")},})

end

function LegionTechLayer:goCheck(_type,id )
	if not _type and not id then
		self._showCell = nil
		self:_onRefresh()
		return
	end
	_type = _type or 1
	id = id or 1
	local name = self._checkName[_type]
	self._tabs:checked(name)
	local targetList = self._showList[_type]
	local start = 0
	for k , v in pairs(targetList) do 
		if v == id then
			start = k
		end
	end
	start = start - 1
	self._showCell = {type=_type,id=id}
	self._views[name]:reloadWithLength(self._maxCount,start)
	self._views[name]:scrollToShowCell(start,0)
end

function LegionTechLayer:onBackKeyEvent( ... )
	if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end

    	return true
end

function LegionTechLayer:onLayerEnter()
	self:registerKeypadEvent(true)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DEVELOP_CORP_TECH, self._onResult2, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_LEARN_CORP_TECH, self._onResult1, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_TECH_BROADCAST, self._onRefresh, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_TECH_INFO, self._onRefresh, self)

	G_HandlersManager.legionHandler:sendGetCorpTechInfo()
end

function LegionTechLayer:adapterLayer()

	self:adapterWidgetHeight("Panel_list1", "Panel_Top", "", 90, 0)
	self:adapterWidgetHeight("Panel_list2", "Panel_Top", "", 90, 0)

	if not self._hasInited then
		self._hasInited = true
		self:_createTab("Panel_list1", self._checkName[1],"Label_learn")
		self:_createTab("Panel_list2", self._checkName[2],"Label_tech")
	end
	self._tabs:checked(self._checkName[1])
	self:updateInfo()
end

--创建tab
function LegionTechLayer:_createTab(panelName, btnName,labelName)
    self._views[btnName] = CCSListViewEx:createWithPanel(self:getPanelByName(panelName), LISTVIEW_DIR_VERTICAL)
    self._tabs:add(btnName, self:getPanelByName(panelName),labelName)
    self:_initTabHandler(btnName)
end


--初始化tab的listview
function LegionTechLayer:_initTabHandler(btnName)
    local listView = self._views[btnName] 
    listView:setCreateCellHandler(function ( list, index)
        return LegionTechCell.new(list, index)
    end)
    local _type = btnName == "CheckBox_learn" and 1 or 2
    listView:setUpdateCellHandler(function ( list, index, cell)
        if  index < self._maxCount then
           cell:updateData(list,(self._showList[_type])[index+1],btnName,self._showCell,function ( _type,id )
           		self:goCheck(_type,id)
           end) 
        end
    end)
    listView:setSpaceBorder(0,40)
    listView:initChildWithDataLength( 0)

end

--选中了某个tab
function LegionTechLayer:onCheckCallback(btnName)
    if not self._inited[btnName] then
        self._views[btnName]:initChildWithDataLength(self._maxCount,0.2)
    end
    self._inited[btnName] = 1
    self._checked = btnName

    -- self:updateShowList(1)
    -- self:updateShowList(2)
end

function LegionTechLayer:_onResult1(data)
	if data.ret == 1 then
		local info = corps_technology_info.get(data.tech_id,data.tech_level)
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_NAME_LEVEL_UP1",{name=info.name,level=data.tech_level}))
		self:_onRefresh()
	end
end

function LegionTechLayer:_onResult2(data)
	if data.ret == 1 then
		local info = corps_technology_info.get(data.tech_id,data.tech_level)
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_NAME_LEVEL_UP2",{name=info.name,level=data.tech_level}))
		self:_onRefresh()
	end
end

function LegionTechLayer:_onRefresh()
	if self._views[self._checkName[1]] then
	    self._views[self._checkName[1]]:refreshAllCell()
	end
	if self._views[self._checkName[2]] then
	    self._views[self._checkName[2]]:refreshAllCell()
	end
	self:updateInfo()
end

function LegionTechLayer:updateInfo()
    self._namelabel:setText(G_lang:get("LANG_LEGION_TECH_LEGIONNAME",{name=G_Me.legionData:getCorpDetail().name,level=G_Me.legionData:getCorpDetail().level}))
    -- self._explabel:setText(G_Me.legionData:getCorpDetail().exp)
    -- self._attrlabel:setText(G_Me.userData.corp_point)
    self:updateAttrLabel()
    self:updateExpLabel()
end

function LegionTechLayer:updateShowList(_type)
	local list = {}
	for i = 1 , self._maxCount do 
		table.insert(list,#list+1,i)
	end
	table.sort(list,function ( a,b )
		local statea = G_Me.legionData:getTechState(a,_type)
		local stateb = G_Me.legionData:getTechState(b,_type)
		if statea ~= stateb then
			return statea > stateb
		end
		return a < b
	end)
	self._showList[_type] = list
end


function LegionTechLayer:updateAttrLabel()
	local num = G_Me.userData.corp_point
	if self._lastCorpAttr > 0 and num ~= self._lastCorpAttr then
	    --增加一个变化动画
	    if self._numAttrChanger then
	        self._numAttrChanger:stop()
	        self._numAttrChanger = nil 
	    end
	    local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
	    self._numAttrChanger = NumberScaleChanger.new( self._attrlabel,  self._lastCorpAttr, num ,
	        function(value) 
	            self._attrlabel:setText(value)
	        end
	    )
	else
	    self._attrlabel:setText(num)
	end
	self._lastCorpAttr = num
end

function LegionTechLayer:updateExpLabel()
	local num = G_Me.legionData:getCorpDetail().exp
	if self._lastCorpExp > 0 and num ~= self._lastCorpExp then
	    --增加一个变化动画
	    if self._numExpChanger then
	        self._numExpChanger:stop()
	        self._numExpChanger = nil 
	    end
	    local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
	    self._numExpChanger = NumberScaleChanger.new( self._explabel,  self._lastCorpExp, num ,
	        function(value) 
	            self._explabel:setText(value)
	        end
	    )
	else
	    self._explabel:setText(num)
	end
	self._lastCorpExp = num
end

function LegionTechLayer:onLayerExit( )
    if self._numAttrChanger then
        self._numAttrChanger:stop()
        self._numAttrChanger = nil 
    end
    if self._numExpChanger then
        self._numExpChanger:stop()
        self._numExpChanger = nil 
    end
end

return LegionTechLayer