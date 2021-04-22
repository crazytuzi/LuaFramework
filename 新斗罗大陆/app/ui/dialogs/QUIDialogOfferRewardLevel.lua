

local QUIDialog = import(".QUIDialog")
local QUIDialogOfferRewardLevel = class("QUIDialogOfferRewardLevel", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogOfferRewardLevel:ctor(options)
	local ccbFile = "ccb/Dialog_OfferReward_Level.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogOfferRewardLevel.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)

	
    self._ccbOwner.frame_tf_title:setVisible(false)
    self._totalBarWidth = self._ccbOwner.node_bar:getContentSize().width * self._ccbOwner.node_bar:getScaleX()
    self._totalBarPosX = self._ccbOwner.node_bar:getPositionX()
	self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.node_bar)
end

function QUIDialogOfferRewardLevel:viewDidAppear()
	QUIDialogOfferRewardLevel.super.viewDidAppear(self)
	self:setInfo()
end

function QUIDialogOfferRewardLevel:viewWillDisappear()
	QUIDialogOfferRewardLevel.super.viewWillDisappear(self)
end

function QUIDialogOfferRewardLevel:setInfo()
    self._ccbOwner.tf_title:setString("悬赏等级")
    local my_info = remote.offerreward:getMyInfo()

    local cur_level = my_info.level or 1
    local offerLevel = remote.offerreward:getOfferRewardLevelById(cur_level)
    local progressInfo = my_info.progressInfo  or {}
    if offerLevel == nil then
    	return 
    end

    local aptitude_table = string.split(offerLevel.aptitude, ";")
	self:addSabc(self._ccbOwner.node_level_cur ,aptitude_table )
	self._ccbOwner.tf_title_cur:setString(cur_level.."级悬赏")

	if  offerLevel.level_up then

	    local level_up_table = string.split(offerLevel.level_up, "^")
	    local cur_num = 0
	    for k,v in pairs(progressInfo) do
	    	if tonumber(v.quality) == tonumber(level_up_table[1])  then 
	    		cur_num = v.num
	    		break
	    	end
	    end
	    local max_num = level_up_table[2]

	    self._ccbOwner.tf_task_need:setString("悬赏"..max_num.."个")

	    self._ccbOwner.tf_process:setString(cur_num.."/"..max_num)
		local stencil = self._percentBarClippingNode:getStencil()
		local posX = -self._totalBarWidth + cur_num / max_num * self._totalBarWidth
		stencil:setPositionX(posX)

	  	local sabcInfo = db:getSABCByAptitude(tonumber(level_up_table[1]) + 1)
		q.setAptitudeShow(self._ccbOwner,sabcInfo.lower)

		self._ccbOwner.node_max:setVisible(false)
	else
		self._ccbOwner.node_next:setVisible(false)
		self._ccbOwner.node_task:setVisible(false)
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.node_cur:setPositionX(180)
	end


    local next_level = cur_level + 1
    local offerLevel_next = remote.offerreward:getOfferRewardLevelById(next_level)
    if offerLevel_next == nil then
    	return 
    end
    self._ccbOwner.tf_title_next:setString(next_level.."级悬赏")
    local aptitude_next_table = string.split(offerLevel_next.aptitude, ";")
	self:addSabc(self._ccbOwner.node_level_next ,aptitude_next_table )
end


function QUIDialogOfferRewardLevel:addSabc(node , aptitude_table)

	local scale_ = 0.35
	local offside_width = 70
	local offside_height = 30

	if #aptitude_table ==1 then
		local nodeOwner = {}
		local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
	    node:addChild(pingzhiNode)
	    pingzhiNode:setScale(scale_)
  		local sabcInfo = db:getSABCByAptitude(tonumber(aptitude_table[1]) + 1)
	    q.setAptitudeShow(nodeOwner,sabcInfo.lower )
	elseif #aptitude_table ==2 then
		for i,v in ipairs(aptitude_table) do
			local nodeOwner = {}
			local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
		    node:addChild(pingzhiNode)
		    pingzhiNode:setScale(scale_)
		    pingzhiNode:setPositionX((i - 1.5) * offside_width)
			local sabcInfo = db:getSABCByAptitude(tonumber(aptitude_table[i]) + 1)
	    	q.setAptitudeShow(nodeOwner,sabcInfo.lower )
		end
	elseif #aptitude_table ==3 then
		for i,v in ipairs(aptitude_table) do
			local nodeOwner = {}
			local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
			pingzhiNode:setScale(scale_)
		    node:addChild(pingzhiNode)
		    if i == 3 then
		    	pingzhiNode:setPositionY(-offside_height)
			else
		    	pingzhiNode:setPositionX((i - 1.5) * offside_width)
		    	pingzhiNode:setPositionY(offside_height)
		    end
			local sabcInfo = db:getSABCByAptitude(tonumber(aptitude_table[i]) + 1)
	    	q.setAptitudeShow(nodeOwner,sabcInfo.lower )
		end
	elseif #aptitude_table ==4 then
		for i,v in ipairs(aptitude_table) do
			local nodeOwner = {}
			local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
		    node:addChild(pingzhiNode)
		    pingzhiNode:setScale(scale_)
		    if i >= 3 then
		    	pingzhiNode:setPositionX((i - 3.5) * offside_width)
		    	pingzhiNode:setPositionY(-offside_height)
			else
		    	pingzhiNode:setPositionX((i - 1.5) * offside_width)
		    	pingzhiNode:setPositionY(offside_height)
		    end
			local sabcInfo = db:getSABCByAptitude(tonumber(aptitude_table[i]) + 1)
	    	q.setAptitudeShow(nodeOwner,sabcInfo.lower)
		end
	end

end

-- function QUIDialogOfferRewardLevel:_backClickHandler()
-- 	app.sound:playSound("common_cancel")
-- 	self:playEffectOut()
-- end

function QUIDialogOfferRewardLevel:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end


return QUIDialogOfferRewardLevel