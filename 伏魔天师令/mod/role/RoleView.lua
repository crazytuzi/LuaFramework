local RoleView = classGc(view,function(self,_pageno,_otheruid)
    self.m_openPageNo=_pageno
    self.m_otheruid=_otheruid or 0
    self.m_isShowOrther=_otheruid~=nil
	self.m_winSize=cc.Director:getInstance():getWinSize()

	print("角色界面参数===>>>>>",_pageno,_otheruid)
end)

local TAGBTN_ROLE   = 1
local TAGBTN_EQUIP  = 2
local TAGBTN_SKILL  = 3
local TAGBTN_GILDED = 4
local TAGBTN_TITLE  = 5

local SYSID_ARRAY=
{
	[TAGBTN_ROLE]=_G.Const.CONST_FUNC_OPEN_ROLE_ATTRIBUTE,
	[TAGBTN_EQUIP]=_G.Const.CONST_FUNC_OPEN_SMITHY_STRENGTHEN,
	[TAGBTN_SKILL]=_G.Const.CONST_FUNC_OPEN_ROLE_SKILL,
	[TAGBTN_GILDED]=_G.Const.CONST_FUNC_OPEN_ROLE_GOLD,
	[TAGBTN_TITLE]=_G.Const.CONST_FUNC_OPEN_ROLE_TITLE,
}

function RoleView.create( self )
	self.m_RoleView  = require("mod.general.TabUpView")()
	self.m_rootLayer = self.m_RoleView:create("角 色")

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self:__initView()
	self:delayShow()

	return tempScene
end

function RoleView.__initView( self )
	print("dasdasdasd-->>",self.m_openPageNo)
	local function closeFun()
		self:closeWindow()
	end

	local function tabBtnCallBack(tag)
		print("RoleView._initView tabBtnCallBack>>>>> tag="..tag)
		local sysId=SYSID_ARRAY[tag]
		if _G.GOpenProxy:showSysNoOpenTips(sysId) then return false end
		
		if tag==3 or tag==5 then
			self.neikuangSpr:setVisible(false)
		else
			self.neikuangSpr:setVisible(true)
		end

		self:selectContainerByTag(tag)
		return true
	end
	self.m_RoleView:addCloseFun(closeFun)
	self.m_RoleView:addTabFun(tabBtnCallBack)

	if not self.m_isShowOrther then
		self.m_RoleView:addTabButton("属  性",TAGBTN_ROLE)
		self.m_RoleView:addTabButton("技  能",TAGBTN_SKILL)
		self.m_RoleView:addTabButton("元  魄",TAGBTN_EQUIP)
		self.m_RoleView:addTabButton("称  号",TAGBTN_TITLE)
		self.m_RoleView:addTabButton("经  脉",TAGBTN_GILDED)

		local signArray=_G.GOpenProxy:getSysSignArray()
		if signArray[_G.Const.CONST_FUNC_OPEN_SMITHY_STRENGTHEN] then
			self.m_RoleView:addSignSprite(TAGBTN_EQUIP,_G.Const.CONST_FUNC_OPEN_SMITHY_STRENGTHEN)
		end
		if signArray[_G.Const.CONST_FUNC_OPEN_ROLE_GOLD] then
			self.m_RoleView:addSignSprite(TAGBTN_GILDED,_G.Const.CONST_FUNC_OPEN_ROLE_GOLD)
		end
		if signArray[_G.Const.CONST_FUNC_OPEN_ROLE_SKILL] then
			self.m_RoleView:addSignSprite(TAGBTN_SKILL,_G.Const.CONST_FUNC_OPEN_ROLE_SKILL)
		end
		if signArray[_G.Const.CONST_FUNC_OPEN_ROLE_TITLE] then
			self.m_RoleView:addSignSprite(TAGBTN_TITLE,_G.Const.CONST_FUNC_OPEN_ROLE_TITLE)
		end

		local msg=REQ_TITLE_REQUEST()
		_G.Network:send(msg)

		local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_ROLE)
		if rewardIconCount>0 then
			self.m_RoleView:setTagIconNum(TAGBTN_TITLE,rewardIconCount)
		end

		local guideId=_G.GGuideManager:getCurGuideId()
		local function showGuide(_tab)
			local tabBtn=self.m_RoleView:getTabBtnByTag(_tab)	
			local closeBtn=self.m_RoleView:getCloseBtn()
			_G.GGuideManager:initGuideView(self.m_rootLayer)
			_G.GGuideManager:registGuideData(1,tabBtn)
			local number=_tab==TAGBTN_EQUIP and 4 or 3 
			_G.GGuideManager:registGuideData(number,closeBtn)
			_G.GGuideManager:runNextStep()
			self.m_guideTab=_tab

			local command=CGuideNoticHide()
      		controller:sendCommand(command)
		end

		if guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL1
			or guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL2
			or guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL3
			or guideId==_G.Const.CONST_NEW_GUIDE_SYS_SKILL4 then
			showGuide(TAGBTN_SKILL)
		elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP then
			showGuide(TAGBTN_EQUIP)
		elseif guideId==_G.Const.CONST_NEW_GUIDE_SYS_GOLD
			or guideId==_G.Const.CONST_NEW_GUIDE_SYS_GOLD2 then
			showGuide(TAGBTN_GILDED)
		end
	else
		local isRoleShow,isGildShow,isEquipShow=true,true,true
		if self.m_openPageNo==TAGBTN_GILDED then
			isGildShow=nil
		elseif self.m_openPageNo==TAGBTN_EQUIP then
			isEquipShow=nil
		else
			isRoleShow=nil
			self.m_openPageNo=TAGBTN_ROLE
		end
		self.m_RoleView:addTabButton("属性",TAGBTN_ROLE,isRoleShow)
		self.m_RoleView:addTabButton("元魄",TAGBTN_EQUIP,isEquipShow)
		self.m_RoleView:addTabButton("技能",TAGBTN_SKILL,true)
		self.m_RoleView:addTabButton("经脉",TAGBTN_GILDED,isGildShow)
		self.m_RoleView:addTabButton("称号",TAGBTN_TITLE,true)
	end
	
	self.m_mainContainer = cc.Node:create()
	self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	self.m_rootLayer:addChild(self.m_mainContainer)

	self.neikuangSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	self.neikuangSpr:setContentSize(cc.size(828,476))
	self.neikuangSpr:setPosition(2,-55)
	self.m_mainContainer:addChild(self.neikuangSpr)

	--五个容器五个页面
	self.m_tagcontainer = {}
  	self.m_tagPanel     = {}
  	self.m_tagPanelClass= {}   

	for i=1,5 do
		self.m_tagcontainer[i] = cc.Node:create()
    	self.m_mainContainer   : addChild(self.m_tagcontainer[i])
	end
end

function RoleView.chuangIconNum(self,_sysId,_number)
  if _G.Const.CONST_FUNC_OPEN_ROLE==_sysId then
    self.m_RoleView:setTagIconNum(TAGBTN_TITLE,_number)
  end
end

function RoleView.delayShow(self)
	self.m_mediator=require("mod.role.RoleViewMediator")(self)

	self.m_equipView=require("mod.role.EquipLayer")(self.m_otheruid,self.m_isShowOrther)
	self.m_equipLayer=self.m_equipView:create()
	self.m_mainContainer:addChild(self.m_equipLayer)
	self.m_mediator:setEquipView(self.m_equipView)

	self:__initParams()
end

function RoleView.__initParams( self )
	print("__initParams",self.m_openPageNo)
    if self.m_openPageNo~=nil then
        self:setCurTabId(self.m_openPageNo)
    else
        self:setCurTabId(TAGBTN_ROLE) 
    end

	self.m_RoleView:selectTagByTag(self:getCurTabId())
	self:selectContainerByTag(self:getCurTabId())
end

function RoleView.getGuideView(self)
	return self.m_guideView
end

function RoleView.selectContainerByTag(self,_tag)
	print("selectContainerByTag",_tag)
	for i=1,5 do
		if i == _tag then
			self.m_tagcontainer[i] : setVisible(true)
		else
			self.m_tagcontainer[i] : setVisible(false)
		end
	end
	if _tag==TAGBTN_ROLE then
		self.m_equipLayer:setVisible(true)
	elseif _tag==TAGBTN_EQUIP then
		self.m_equipLayer:setVisible(false)
	else
		self.m_equipLayer:setVisible(false)
	end
	local skillLayer = self.m_tagPanelClass[TAGBTN_SKILL]
	if skillLayer ~= nil then
		if _tag~=TAGBTN_SKILL then
			skillLayer.m_canDrag = nil
		else
			skillLayer.m_canDrag = true
		end
	end
	
	if not self.m_isShowOrther then
		local isAddAttrFly=true
		local isRemoveAttrFly=true
		if (self.m_curTabId==TAGBTN_ROLE or self.m_curTabId==TAGBTN_EQUIP)
			and (_tag==TAGBTN_ROLE or _tag==TAGBTN_EQUIP)
			and self.m_attrFlyNode~=nil then
			isRemoveAttrFly=false
			isAddAttrFly=false
		end
		if isRemoveAttrFly and self.m_attrFlyNode~=nil then
			self.m_attrFlyNode:removeFromParent(true)
			self.m_attrFlyNode=nil
		end
		if isAddAttrFly then
			if _tag==TAGBTN_ROLE or _tag==TAGBTN_EQUIP then
				self.m_attrFlyNode=_G.Util:getLogsView():createAttrLogsNode()
				self.m_attrFlyNode:setPosition(-200,-30)
				self.m_mainContainer:addChild(self.m_attrFlyNode,20)
			elseif _tag==TAGBTN_GILDED then
				self.m_attrFlyNode=_G.Util:getLogsView():createAttrLogsNode()
				self.m_attrFlyNode:setPosition(-190,-50)
				self.m_mainContainer:addChild(self.m_attrFlyNode,20)
			end
		end
	end

	self:setCurTabId(_tag)
	--创建面板内容
	self:initTagPanel(_tag)

	local secondSize=self.m_RoleView:getSecondSize()
	if _tag==TAGBTN_SKILL then
		self.m_RoleView:setSecondSize(cc.size(secondSize.width,secondSize.height-10))
	else
		self.m_RoleView:setSecondSize(secondSize)
	end

	if self.m_guideTab~=nil then
		if _tag==self.m_guideTab then
			_G.GGuideManager:showGuideByStep(2)
		else
			_G.GGuideManager:hideGuideByStep(2)
		end
	end
end

function RoleView.initTagPanel(self,_tag)
	if self.m_tagPanel[_tag] == nil then
		--在这里创建自己面板的的东西
		local view=nil
		if _tag == TAGBTN_ROLE then
			print("创建角色面板")
			local curUid=self.m_equipView:getCurRoleUid()
			view = require "mod.role.RoleLayer"(curUid,self.m_isShowOrther)
			self.m_mediator:setInfoView(view)
		elseif _tag == TAGBTN_EQUIP then
			print("创建元魂面板")
			local curUid=self.m_equipView:getCurRoleUid()
			view = require "mod.role.EquipStrengthLayer"(curUid)
		elseif _tag == TAGBTN_TITLE then
			view = require("mod.role.TitleLayer")(self.m_titleMsg)
		elseif _tag == TAGBTN_SKILL then
			print("创建技能面板")
			view = require "mod.role.SkillLayer"(self)
		elseif _tag == TAGBTN_GILDED then
			print("创建经脉面板")
			view = require "mod.role.GoldView"(self.m_otheruid)
		end
		if view == nil then return end
		self.m_tagPanelClass[_tag] = view
    	self.m_tagPanel[_tag]      = view:__create()

    	self.m_tagcontainer[_tag]:addChild(self.m_tagPanel[_tag])
	end
end

function RoleView.closeWindow( self )
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil
	--注销各个子页面得mediator
	self:allunregister()

	cc.Director:getInstance():popScene() 
	self:destroy()

	if self.m_guideTab then
		local command=CGuideNoticShow()
      	controller:sendCommand(command)
	end
end

function RoleView.allunregister( self )
	for _tag=1,5 do
		if self.m_tagPanelClass[_tag]~=nil then
			self.m_tagPanelClass[_tag]:unregister()
		end
	end
end

function RoleView.setCurTabId( self,_id )
    self.m_curTabId=_id
end
function RoleView.getCurTabId( self )
    return self.m_curTabId
end

function RoleView.setTitleMsg(self,_titleMsg)
	if self.m_isShowOrther then return end

	self.m_titleMsg=self.m_titleMsg or {}
	for k,v in pairs(_titleMsg.data) do
		self.m_titleMsg[k]=v
		--[[
		print("tid:",v.tid)
		print("state:",v.state)
		print("type:",v.type)
		print("new:",v.new)
		]]--
	end
	self.m_titleMsg["tid"] = _titleMsg.tid
	if self.m_tagPanelClass[TAGBTN_TITLE]~=nil then
		self.m_tagPanelClass[TAGBTN_TITLE]:updateTitleMsgArray(_titleMsg.date)
	end
	self:__updateTitleHightSpr()
end

function RoleView.__updateTitleHightSpr(self)
	local isCanActivate=false
	for k,v in pairs(self.m_titleMsg) do
		if type(v)==table and v.state==_G.Const.CONST_TITLE_STATA_0 then
			isCanActivate=true
			break
		end
	end
	if isCanActivate then
		if self.m_titleHightSpr==nil then
			local tempBtn=self.m_RoleView:getTabBtnByTag(TAGBTN_TITLE)
			local btnSize=tempBtn:getContentSize()
			local tempSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips1.png")
			tempSpr:setPosition(btnSize.width-25,btnSize.height*0.5)
			tempSpr:setScale(0.5)
			tempBtn:addChild(tempSpr,10)
			self.m_titleHightSpr=tempSpr
		end
	elseif self.m_titleHightSpr~=nil then
		self.m_titleHightSpr:removeFromParent(true)
		self.m_titleHightSpr=nil
	end
end

function RoleView.updateTitle( self )
	if self.m_tagPanelClass[TAGBTN_TITLE]~=nil then
		self.m_tagPanelClass[TAGBTN_TITLE]:updateTitle()
	end
end

function RoleView.updateFlag( self )
	if self.m_tagPanelClass[TAGBTN_TITLE]~=nil then
		self.m_tagPanelClass[TAGBTN_TITLE]:updateFlag()
	end
end

function RoleView.playerpower( self )
	-- print("playerpowerplayerpowerplayerpowerplayerpower====>>>")
	self.m_equipView:playerpower()
end

return RoleView