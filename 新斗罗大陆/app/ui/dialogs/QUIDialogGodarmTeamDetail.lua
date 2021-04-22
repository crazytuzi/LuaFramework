-- @Author: liaoxianbo
-- @Date:   2020-01-10 18:29:17
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-04-02 14:48:02
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmTeamDetail = class("QUIDialogGodarmTeamDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGodarmTeamDetail = import("..widgets.QUIWidgetGodarmTeamDetail")
local QUIWidgetGodarmSkillbox = import("..widgets.QUIWidgetGodarmSkillbox")
local QListView = import("...views.QListView")

function QUIDialogGodarmTeamDetail:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_TeamDetail.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGodarmTeamDetail.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._isMockBattle = options.isMockBattle or false

	self._ccbOwner.frame_tf_title:setString("神器上阵")
	self._godarmList = {}
    self._mainGodarmList = options.mainGodarmList
    self._godarmSkillBox = {}
    self:initSkillIcon()
    self:initSkillData()


end

function QUIDialogGodarmTeamDetail:viewDidAppear()
	QUIDialogGodarmTeamDetail.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogGodarmTeamDetail:viewWillDisappear()
  	QUIDialogGodarmTeamDetail.super.viewWillDisappear(self)

	self:removeBackEvent()
end
function QUIDialogGodarmTeamDetail:initSkillIcon( )
	self._godarmSkillBox = {}
	local maxnum = 4
	if self._isMockBattle then
		maxnum = 2
	end
	
	for i=1,maxnum do
		self._ccbOwner["node_skill"..i]:removeAllChildren()
		local item = QUIWidgetGodarmSkillbox.new({index=i})
		self._ccbOwner["node_skill"..i]:addChild(item)
		table.insert(self._godarmSkillBox,item)
	end

	for _,v in pairs(self._mainGodarmList) do
		if self._godarmSkillBox[v.pos] then
			self._godarmSkillBox[v.pos]:setSkillInfo(v)
		end
	end
end

function QUIDialogGodarmTeamDetail:initSkillData( )
	self._godarmList = {}


	if self._isMockBattle then
		for _,v in pairs(self._mainGodarmList) do
			local godarm = {}
			godarm.id = v.godarmId or v.id
			godarm.grade = v.grade
			godarm.level = v.level
			local godarmConfig = db:getCharacterByID(godarm.id)
        	godarm.aptitude = godarmConfig.aptitude
			table.insert( self._godarmList, godarm)
		end
		self:initListView()
		return
	end

	local haveGodarmList = clone(remote.godarm:getHaveGodarmList())

	for _,value in pairs(haveGodarmList) do
		value.pos = 5
	end

	for _,v in pairs(self._mainGodarmList) do
		if haveGodarmList[v.godarmId] then
			haveGodarmList[v.godarmId].pos = v.pos
		end
	end

	for _,v in pairs(haveGodarmList) do
		table.insert( self._godarmList, v )
	end

	table.sort( self._godarmList, function(a,b )
		if a.pos ~= b.pos then
			return a.pos < b.pos
		elseif a.aptitude ~= b.aptitude then
			return a.aptitude > b.aptitude
		elseif a.grade ~= b.grade then
			return a.grade > b.grade
		elseif a.level and b.level and a.level ~= b.level then
			return a.level > b.level
		end
	end )

	self:initListView()
end

function QUIDialogGodarmTeamDetail:initListView()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            -- ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._godarmList,
            spaceY = 6,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._contentListView:reload({totalNumber = #self._godarmList})
    end
end

function QUIDialogGodarmTeamDetail:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local masterConfig = self._godarmList[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetGodarmTeamDetail.new()
        isCacheNode = false
    end
    item:setSkillInfo( masterConfig, self ) 

    info.item = item
    info.size = item:getContentSize()
    return isCacheNode
end
function QUIDialogGodarmTeamDetail:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGodarmTeamDetail:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGodarmTeamDetail:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGodarmTeamDetail
