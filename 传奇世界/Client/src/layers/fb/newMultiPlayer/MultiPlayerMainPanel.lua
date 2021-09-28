 --Author:		bishaoqing
--DateTime:		2016-05-31 15:55:41
--Region:		多人守卫主界面
local MultiPlayerMainPanel = class("MultiPlayerMainPanel", require("src/layers/base/BasePanel"))
local MultiDB = require("src/config/MultiCopy")
local DropOp = require("src/config/DropAwardOp")
local Arg = require("src/layers/fb/newMultiPlayer/MultiPlayerCfg")
-- local MultiPlayerMem = require("src/layers/fb/newMultiPlayer/MultiPlayerMem")
local teamTargetCfg = require("src/layers/teamup/teamTargetCfg")
MultiPlayerMainPanel.bOpened = false
function MultiPlayerMainPanel.IsOpened( ... )
	-- body
	return MultiPlayerMainPanel.bOpened == true
end


function MultiPlayerMainPanel:ctor( ... )
	-- body
	MultiPlayerMainPanel.super.ctor(self, ...)
	self.m_nCurSelectId = 0
	MultiPlayerMainPanel.bOpened = true
	-- GetMultiPlayerCtr():getTeamDataFromServer(self.m_nCurSelectId)
end

-- function MultiPlayerMainPanel:InitUI( ... )
-- 	-- body
-- 	MultiPlayerMainPanel.super.InitUI(self)

-- 	local stWinSize = cc.Director:getInstance():getWinSize()
	
-- 	-- self.m_imgBg = createSprite(self.m_uiRoot, "res/common/2.png", cc.p(stWinSize.width/2, stWinSize.height/2), cc.p(0.5, 0.5))
-- 	self.m_imgBg, self.m_btnClose = createBgSprite(self.m_uiRoot, "多人守卫", nil, nil, handler(self, self.OnClose))
-- 	registerOutsideCloseFunc( self.m_imgBg , function() self:OnClose() end,true)
	
-- 	local stBgSize = self.m_imgBg:getContentSize()

-- 	--local sprBlackBg = createScale9Sprite(self.m_imgBg, "res/common/bg/bg-6.png", cc.p(480, 320 - 30))

--     self.m_leftSpr = createScale9Frame(
--         self.m_imgBg,
--         "res/common/scalable/panel_outer_base_1.png",
--         "res/common/scalable/panel_outer_frame_scale9_1.png",
--         cc.p( 26 + 15, 18 + 22 ),
--         cc.size(514, 500),
--         5
--     )

--     self.m_rightSpr = createScale9Frame(
--         self.m_imgBg,
--         "res/common/scalable/panel_outer_base_1.png",
--         "res/common/scalable/panel_outer_frame_scale9_1.png",
--         cc.p( 550 + 15, 18 + 22 ),
--         cc.size(360, 500),
--         5
--     )

-- 	self.m_sclContent = GetWidgetFactory():CreateScrollView(cc.size(500, 487), true)
--     self.m_imgBg:addChild(self.m_sclContent)
--     self.m_sclContent:setAnchorPoint(cc.p(0.5, 1))
-- 	self.m_sclContent:setPosition(cc.p(300, 534))
    
-- 	-- self.m_btnClose = createMenuItem( self.m_imgBg , "res/component/button/X.png" , cc.p(stBgSize.width/2 + display.width/2 - 36, 574) , handler(self, self.OnClose) )

-- 	-- local tfTitle = createLabel(self.m_imgBg, "多人守卫", cc.p(568, 594), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
-- 	-- tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

-- 	self.m_btnChallenge = createMenuItem( self.m_imgBg , "res/component/button/1.png" , cc.p(650, 78) , handler(self, self.onChallenge) )
-- 	local stBtnSize = self.m_btnChallenge:getContentSize()
-- 	local tfTitle = createLabel(self.m_btnChallenge, "个人挑战", cc.p(stBtnSize.width/2, stBtnSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
-- 	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

-- 	self.m_btnTeamChallenge = createMenuItem( self.m_imgBg , "res/component/button/1.png" , cc.p(840, 78) , handler(self, self.onTeamChallenge) )
-- 	local stBtnSize = self.m_btnTeamChallenge:getContentSize()
-- 	local tfTitle = createLabel(self.m_btnTeamChallenge, "组队挑战", cc.p(stBtnSize.width/2, stBtnSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
-- 	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

--     -------------------------------------------------------------------
-- 	--local tfRule = self:createRule()
-- 	--self.m_imgBg:addChild(tfRule)
--     -- 选择读取 ActivityNormalDB.lua
--     self:createRule();

-- 	createSprite(self.m_imgBg, "res/fb/multiple/11.png", cc.p(748, 238))
-- 	local tfTitle = createLabel(self.m_imgBg, "每日通关奖励", cc.p(747, 238), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
-- 	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)


-- end

function MultiPlayerMainPanel:InitUI( ... )
	-- body
	MultiPlayerMainPanel.super.InitUI(self)

	local stWinSize = cc.Director:getInstance():getWinSize()
	
	--对话框
	self.m_imgBg, self.m_btnClose = createBgSprite(self.m_uiRoot, "多人守卫", nil, nil, handler(self, self.OnClose))
	registerOutsideCloseFunc( self.m_imgBg , function() self:OnClose() end,true)
	
	--底色背景
	local stBgSize = self.m_imgBg:getContentSize()
	local stSize = cc.size(895, 497)
	local uiBlack = GetUIHelper():WrapImg(cc.Sprite:create("res/common/scalable/panel_outer_base.png"), stSize)
    uiBlack:setAnchorPoint(cc.p(0.5, 0.5))
    uiBlack:setPosition(cc.p(480, 287))
    uiBlack:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    self.m_imgBg:addChild(uiBlack)

	local uiBlack_bg = createScale9Frame(
        self.m_imgBg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(480, 287),
        stSize,
        5,
        cc.p(0.5, 0.5)
    )
 
	--滚动条
	local uiScrollBg = createSprite(self.m_imgBg, "res/fb/multiple/bg.jpg", cc.p(stBgSize.width/2, stBgSize.height/2 + 30))
	local stScrollSize = uiScrollBg:getContentSize()
	
	self.m_sclContent = GetWidgetFactory():CreateScrollView(stScrollSize, true)
    uiScrollBg:addChild(self.m_sclContent)
    self.m_sclContent:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_sclContent:setPosition(cc.p(stScrollSize.width/2, stScrollSize.height/2))

	createSprite(self.m_imgBg, "res/fb/multiple/shadow.png", cc.p(stBgSize.width/2, stBgSize.height/2 + 30))
	local uiShadow = createSprite(self.m_imgBg, "res/fb/multiple/shadow.png", cc.p(stBgSize.width/2, stBgSize.height/2 + 30))
	uiShadow:setOpacity(255 * 0.5)
	--奖励
	local tfTitle = createLabel(self.m_imgBg, "奖励: 已通关的副本可反复参与挑战，但无额外奖励。", cc.p(70, 150), cc.p(0, 0.5), GetUiCfg().stFontSize.TooMuchWordsSize)
	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	--开始挑战
	self.m_btnChallenge = createMenuItem( self.m_imgBg , "res/component/button/2.png" , cc.p(810, 80) , handler(self, self.onTeamChallenge) )
	createLabel(self.m_btnChallenge, "开始挑战", getCenterPos(self.m_btnChallenge), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize, nil, nil, nil, GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	
	--寻找队伍
	self.m_btnSingleChallenge = createMenuItem( self.m_imgBg , "res/component/button/2.png" , cc.p(650, 80) , handler(self, self.onFindTeam) )
	createLabel(self.m_btnSingleChallenge, "寻找队伍", getCenterPos(self.m_btnSingleChallenge), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize, nil, nil, nil, GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	createLabel(self.m_imgBg, "组队挑战可提高副本通关成功率。", cc.p(590, 150), cc.p(0, 0.5), GetUiCfg().stFontSize.TooMuchWordsSize, nil, nil, nil, MColor.lable_black)

	local n_prompt = __createHelp(
	{
		parent = self.m_imgBg,
		str = self:getRuleStr(),
		pos = cc.p(900, 510),
	})
end

function MultiPlayerMainPanel:onTeamChallenge( ... )
    -- pre deal with level.
    local tmpMultiCarbonId = GetMultiPlayerCtr():getCopyId();
    local fbData = getConfigItemByKey("MultiCopy", "CopyofID", tmpMultiCarbonId);
    if fbData then
        local lv = MRoleStruct:getAttr(ROLE_LEVEL);
        if lv then
            if lv < tonumber(fbData.accesslevel) then
                local msgItem = getConfigItemByKeys("clientmsg",{"sth","mid"},{30000,-3});
                if msgItem then
                    TIPS{ type = msgItem.tswz , str = string.format( msgItem.msg , tonumber(fbData.accesslevel) ) , flag = msgItem.flag }
                    return;
                end
            end
        end
    end

	-- body
	if not G_TEAM_INFO.has_team then
		-- TIPS({str = "你当前没有队伍，无法发起组队挑战!", type = 1})
		MessageBoxYesNoEx(nil, "勇士：你确定要一个人开始挑战吗，组队挑战可大大提高副本通关成功率哦。", handler(GetMultiPlayerCtr(), GetMultiPlayerCtr().enterGameFromServer), handler(self, self.onFindTeam), "立即开始", "寻找队伍", true)
	else
		if GetTeamCtr():isCaptain() then
			self:showEffect()

		end
		GetMultiPlayerCtr():checkTeamChallengeFromServer()
	end
end

function MultiPlayerMainPanel:showEffect( ... )
	-- body
	self:stopEffect()
	-- self.m_uiMessage, uiOkButton, uiCancelButton = MessageBoxYesNoEx(nil, "正在等待成员确认", nil, nil, nil, nil, false)
	-- uiOkButton:setVisible(false)
	-- uiCancelButton:setVisible(false)
	if not self.m_uiWaitEffect then
		-- self.m_uiWaitEffect = Effects:create(false)
		self.m_uiWaitEffect = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
		GetUIHelper():AddTouchEventListener(true, self.m_uiWaitEffect)
		local oEffect = Effects:create(false)
		oEffect:setScale(1)
	   	oEffect:playActionData("guardwait", 14, 1,-1,0)
	   	oEffect:setName("oEffect")

	   	self.m_uiWaitEffect:addChild(oEffect)
	   	oEffect:setPosition(getCenterPos(self.m_uiWaitEffect))
	   	self.m_uiRoot:addChild(self.m_uiWaitEffect, 2)
   	end
   self.m_uiWaitEffect:setVisible(true)
end

function MultiPlayerMainPanel:stopEffect( ... )
	-- body
	-- if IsNodeValid(self.m_uiMessage) then
	-- 	if self.m_uiMessage.funcNo then
	-- 		self.m_uiMessage.funcNo()
	-- 	else
	-- 		self.m_uiMessage:removeFromParent()
	-- 	end
	-- end
	-- self.m_uiMessage = nil
	if self.m_uiWaitEffect then
		self.m_uiWaitEffect:setVisible(false)
	end
end

-- function MultiPlayerMainPanel:onTeamChallengeRet( proto )
-- 	-- body
-- 	if not proto then
-- 		return
-- 	end

-- 	local nResult = proto.result
-- 	if not nResult or nResult ~= 0 then
-- 		local errorMemberInfo = proto.errorMemberInfo
-- 		local errorNum = proto.errorNum
-- 		if #errorMemberInfo >= 1 then
-- 			local sStr = "队伍成员："
-- 			for i,stInfo in ipairs(errorMemberInfo) do
-- 				local oMem = MultiPlayerMem.new()
-- 				oMem:reset(stInfo)
-- 				local sName = oMem:getMemberName()
-- 				if i ~= 1 then
-- 					sStr = sStr.."、"..sName
-- 				else
-- 					sStr = sStr .. sName
-- 				end
-- 			end
-- 			sStr = sStr..' 不满足当前副本开启条件，无法发起组队挑战！'
-- 			TIPS({str = sStr, type = 1})
-- 		end
-- 		return
-- 	end

-- 	self.m_vMem = proto.memberIds
-- 	--如果成功那就创建队伍并且邀请人员
-- 	GetMultiPlayerCtr():createTeamFromServer(self.m_nCurSelectId)
-- end

function MultiPlayerMainPanel:AddEvent( ... )
	-- body
	MultiPlayerMainPanel.super.AddEvent(self)
	Event.Add(EventName.UpdateMultiPanel, self, self.RefreshUI)
	-- Event.Add(EventName.OperateRet, self, self.onOperateRet)
	-- Event.Add(EventName.TeamChallengeRet, self, self.onTeamChallengeRet)
	Event.Add(EventName.AllReady, self, self.stopEffect)
	Event.Add(EventName.MultiError, self, self.stopEffect)
end

function MultiPlayerMainPanel:RemoveEvent( ... )
	-- body
	MultiPlayerMainPanel.super.RemoveEvent(self)
	Event.Remove(EventName.UpdateMultiPanel, self)
	-- Event.Remove(EventName.OperateRet, self)
	-- Event.Remove(EventName.TeamChallengeRet, self)
	Event.Remove(EventName.MultiError, self)
	Event.Remove(EventName.AllReady, self)
end

-- function MultiPlayerMainPanel:onOperateRet( nId, bResult )
-- 	-- body
-- 	if not bResult then
-- 		return
-- 	end
-- 	if nId == Arg.COPY_MULTI_OPERATOR_ENTERCOPY then
-- 		self:OnClose()
-- 	elseif nId == Arg.COPY_MULTI_OPERATOR_CREATETEAM then--创建队伍
-- 		local oPanel = GetMultiPlayerCtr():openMultiMyTeamPanel()
-- 		oPanel:setInitInviteMem(self.m_vMem)
-- 		self.m_vMem = nil
-- 	end
-- end

function MultiPlayerMainPanel:RefreshUI( ... )
	-- body
	-- --如果自己有队伍就打开队伍界面
	-- GetMultiPlayerCtr():openTeamPanelByMyPosition()
	--------------------------------------------------
	self:Reset()
	local nPadding = 10

	for _,v in ipairs(MultiDB) do
		--多人守卫副本和单人体验副本陪在一张表里，用这个字段区分
		if not v.solo or v.solo == 0 then
			local uiCate, nId = self:CreateCate(v)
			if uiCate then
				self.m_sclContent:addChild(uiCate)
				self.m_stCates[nId] = uiCate
			end

			
		end
	end
	--设置滑动控件的高度和子控件的位置
	GetUIHelper():FixScrollView(self.m_sclContent, nPadding, true, 35)

	local bFind = false
	local nCurLv = GetMultiPlayerCtr():getCurLv()

	if self.m_nCurSelectId and nCurLv >= self.m_nCurSelectId then
		for k,v in pairs(self.m_stCates) do
			if k == self.m_nCurSelectId then
				bFind = true
				break
			end
		end
	end

	if not bFind then
		
		for k,v in pairs(self.m_stCates) do
			if nCurLv >= k then
				self:setCurSelectId(k)
				break
			end
		end
	else
		self:setCurSelectId(self.m_nCurSelectId)
	end
end

--创建scrollview里面重复的部件
function MultiPlayerMainPanel:CreateCate( stMultiDB )
	-- body
	
	
	local nCurLv = GetMultiPlayerCtr():getCurLv()
	local nId = stMultiDB.CopyofID
	local bPassed = nCurLv > nId
	local bCanSelect = nCurLv >= nId
	print("bPassed", nCurLv, nId, bPassed, bCanSelect)

	local sSpritePath, strEffectName, strStopSprite
	local stEffectPos
	if nId == 1 then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/guard1@0.plist")
		sSpritePath = "res/fb/multiple/normal.png"
		strEffectName = "guard1"
		stEffectPos = cc.p(137,165)
		strStopSprite = "guard1/00000.png"
	elseif nId == 2 then
		cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/guard2@0.plist")
		sSpritePath = "res/fb/multiple/difficult.png"
		strEffectName = "guard2"
		stEffectPos = cc.p(137,165)
		strStopSprite = "guard2/00000.png"
	else--[[if nId == 3 then]]
		cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/guard3@0.plist")
		sSpritePath = "res/fb/multiple/hard.png"
		strEffectName = "guard3"
		stEffectPos = cc.p(135,190)
		strStopSprite = "guard3/00000.png"
	end
	local m_plCate = cc.Sprite:create(sSpritePath)

	local uiIcon = createSprite(m_plCate, sSpritePath, cc.p(0, 0), cc.p(0, 0))
	uiIcon:setName("uiIcon")
	local strCopyName = stMultiDB.Copyname
    if GetMultiPlayerCtr():isTodayPassed(nId) then
    	strCopyName = strCopyName.."（今日已通关）"
    end
	-- local nReward = stMultiDB.reward
	local uiLockInfo = createSprite(m_plCate, "res/common/bg/propNamebg.png", cc.p(27, 35), cc.p(0, 0))

	local uiTfBgUnselect = createScale9Sprite(m_plCate, "res/common/scalable/14_0.png", cc.p(12, 0),cc.size(243, 41),cc.p(0, 0))
	uiTfBgUnselect:setName("uiTfBgUnselect")
	createLabel(uiTfBgUnselect, strCopyName, getCenterPos(uiTfBgUnselect), cc.p(0.5, 0.5), GetUiCfg().stFontSize.NormalSize, nil, nil, nil, cc.c3b(127, 119, 108))

	local uiTfBgSelect = createScale9Sprite(m_plCate, "res/common/scalable/14_1.png", cc.p(12, 0),cc.size(243, 41),cc.p(0, 0))
	uiTfBgSelect:setName("uiTfBgSelect")
    createScale9Sprite(uiTfBgSelect, "res/common/scalable/14_2.png", getCenterPos(uiTfBgSelect),cc.size(220, 30),cc.p(0.5, 0.5))
    
    

    createLabel(uiTfBgSelect, strCopyName, getCenterPos(uiTfBgSelect), cc.p(0.5, 0.5), GetUiCfg().stFontSize.NormalSize, nil, nil, nil, cc.c3b(253, 238, 215))

	createSprite(m_plCate, "res/common/scalable/14_3.png", cc.p(29, 28), cc.p(0, 0))

	local strLockInfo = "未开启"
	local stColor = GetUiCfg().FontColor.TipAndWarningColor
	if bCanSelect then
		strLockInfo = "已开启"
		stColor = GetUiCfg().FontColor.GreenColor
	end
	createLabel(uiLockInfo, strLockInfo, getCenterPos(uiLockInfo), cc.p(0.5, 0.5), GetUiCfg().stFontSize.NormalSize, nil, nil, nil, stColor)
	-- local tfTitle = createLabel(m_plCate, stMultiDB.Copyname, cc.p(89, 459), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	-- tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	-- local stDropDetail = DropOp:getDropNum(nReward,777777)
	-- if stDropDetail then
	-- 	local tfTitle = createLabel(m_plCate, "声望+"..stDropDetail.q_count, cc.p(79, 433), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	-- 	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	-- end
	-- local uiSelect = cc.Sprite:create("res/fb/multiple/select.png")
	-- m_plCate:addChild(uiSelect)
	-- uiSelect:setName("uiSelect")
	-- uiSelect:setPosition(cc.p(79, 243))

	-- local uiPassed = cc.Sprite:create("res/fb/multiple/passed.png")
	-- m_plCate:addChild(uiPassed)
	-- uiPassed:setName("uiPassed")
	-- uiPassed:setPosition(cc.p(79, 243))
	-- if bPassed then
	-- 	uiPassed:setVisible(true)
	-- else
	-- 	uiPassed:setVisible(false)
	-- end
	local function setCurSelectId()
		self:setCurSelectId(nId)
	end

	local function tipLock( ... )
		-- body
		local strTip = "需要通关普通难度才可开启此关卡！"
		if nId == 3 then
			strTip = "需要通关困难难度才可开启此关卡！"
		end
		setCurSelectId()
		TIPS({str = strTip, type = 1})
		
	end

	if bCanSelect then
		--如果解锁了，那点击就是选中
		GetUIHelper():AddTouchEventListener(false, m_plCate, nil, setCurSelectId)
	else
		--如果没解锁，点击就是提示
		GetUIHelper():AddTouchEventListener(false, m_plCate, nil, tipLock)
	end

	local uiEffectNode = cc.Node:create()
	uiEffectNode:setPosition(stEffectPos)
	m_plCate:addChild(uiEffectNode)
	local oEffect = Effects:create(false)
	oEffect:setScale(1)
	uiEffectNode:addChild(oEffect)
   	oEffect:playActionData2(strEffectName, 200,-1,0)
   	uiEffectNode:setName("oEffect")
   	uiEffectNode:setVisible(false)
   	local uiStopSprite = cc.Sprite:createWithSpriteFrameName(strStopSprite)
   	uiStopSprite:setName("uiStopSprite")
   	uiStopSprite:setVisible(false)
   	m_plCate:addChild(uiStopSprite)
   	uiStopSprite:setPosition(stEffectPos)
   	uiStopSprite:setColor(cc.c3b(200, 200, 200))
	return m_plCate, nId
end

--创建每日奖励节点
function MultiPlayerMainPanel:createDayReward( reward )
	-- body
	print("reward", reward)
	if not reward then
		return
	end
	local awards = {}
    
    local awardsConfig = DropOp:dropItem_ex(tonumber(reward));
    for i=1, #awardsConfig do
        awards[i] =  { 
              id = awardsConfig[i]["q_item"] ,       -- 奖励ID
              num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
              streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
              quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
              upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
              time = awardsConfig[i]["q_time"] ,     -- 限时时间
              showBind = true,
              isBind = tonumber(awardsConfig[i]["bdlx"]) == 1,     -- 绑定(1绑定0不绑定)
            }
    end

    local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
    -- setNodeAttr( groupAwards , cc.p( 815/2, 20 ) , cc.p( 0.5 , 0 ) )
    return groupAwards
end

--[[
function MultiPlayerMainPanel:createRule(  )
	-- body
    -- 规则介绍
    local ruleStr = require("src/config/PromptOp"):content(57);
    local ruleLal = require("src/RichText").new( nil , cc.p( 570 , 450 ) , cc.size( 350 , 0 ) , cc.p( 0 , 0.5 ) , 22 , 20 , MColor.white )
	ruleLal:addText( ruleStr , MColor.white , false )
	ruleLal:format()
	return ruleLal
end
]]

function MultiPlayerMainPanel:getRuleStr( ... )
	-- body
	-- local cfgData = getConfigItemByKey("Prompt", "q_MarkID", 57);
	-- local strTime = cfgData and cfgData.q_rule or ""
	-- return strTime
	local data = require("src/config/PromptOp")
	local str = data:content(57)
	return str
end

function MultiPlayerMainPanel:createRule(  )
    local bg = self.m_rightSpr
    local tempWidth = 10
    local topHeight, offSetY = 470, 30;

    local cfgData = getConfigItemByKey("ActivityNormalDB", "q_id", 8);
    
    local str = game.getStrByKey("bodyguard_lv") .. "："
    createLabel(bg, str, cc.p(tempWidth, topHeight), cc.p(0, 0.5), 20, true)
    local needLev = cfgData and cfgData.q_lv or 34
    createLabel(bg, "" .. needLev, cc.p(tempWidth + 100, topHeight), cc.p(0, 0.5), 20):setColor(MColor.orange)

    topHeight = topHeight - offSetY
    local str = game.getStrByKey("empire_rule_1_title_1") .. "："
    createLabel(bg, str, cc.p(tempWidth, topHeight), cc.p(0, 0.5), 20, true)
    local strTime = DATA_Battle:formatTime( cfgData.q_time )
    createLabel(bg, strTime[1] , cc.p(tempWidth + 100, topHeight), cc.p(0, 0.5), 20):setColor(MColor.orange)

    topHeight = topHeight - offSetY
    local str = game.getStrByKey("empire_rule_3_title_1") .. "："
    createLabel(bg, str, cc.p(tempWidth, topHeight), cc.p(0, 0.5), 20, true)

    topHeight = topHeight - offSetY/2
    local strTime = cfgData and cfgData.q_rule or ""
    createLabel(bg, strTime, cc.p(tempWidth, topHeight), cc.p(0, 1), 20, false, nil, nil, MColor.orange, 1, 350)
end

function MultiPlayerMainPanel:onFindTeam( ... )
	-- body
	if G_TEAM_INFO.has_team then
		TIPS({str = "已经有队伍了!", type = 1})
		return
	end
	-- GetMultiPlayerCtr():openMultiPlayerAllTeamPanel(self.m_nCurSelectId)

	local nTarget = 1
	if self.m_nCurSelectId == 1 then
		nTarget = teamTargetCfg.team_defense
	elseif self.m_nCurSelectId == 2 then
		nTarget = teamTargetCfg.team_defense1
	else
		nTarget = teamTargetCfg.team_defense2
	end
	GetTeamCtr():openFindTeam(nTarget)
end

function MultiPlayerMainPanel:setCurSelectId( nId )
	-- body
	print("setCurSelectId", nId)
	self.m_nCurSelectId = nId
	-- for k,v in pairs(self.m_stCates) do
	-- 	v:getChildByName("uiSelect"):setVisible(false)
	-- end
	if not nId then
		return
	end

	local nCurLv = GetMultiPlayerCtr():getCurLv()
	print("nCurLv < nId", nCurLv < nId)
	-- if nCurLv < nId then
	-- 	return
	-- end
	local bCanSelect = nCurLv >= nId
	if bCanSelect then
		self.m_btnChallenge:setEnabled(true)
		self.m_btnSingleChallenge:setEnabled(true)
	else
		self.m_btnChallenge:setEnabled(false)
		self.m_btnSingleChallenge:setEnabled(false)
	end
	-- local uiCate = self.m_stCates[nId]
	-- if uiCate then
	-- 	uiCate:getChildByName("uiSelect"):setVisible(true)
	-- end

	-- for k,v in pairs(self.m_stRewards) do
	-- 	v:setVisible(false)
	-- end
	-- local uiReward = self.m_stRewards[nId]
	-- if uiReward then
	-- 	uiReward:setVisible(true)
	-- end
	if self.m_uiReward then
		self.m_uiReward:removeFromParent()
	end
	local db = DB.get("MultiCopy", "CopyofID", nId)
	if db then
		self.m_uiReward = self:createDayReward(db.tggd)
		if self.m_uiReward then
			self.m_imgBg:addChild(self.m_uiReward)
			self.m_uiReward:setPosition(cc.p(60,25))
		end
	end
	for k,v in pairs(self.m_stCates) do
		if k == nId then
			v:getChildByName("uiTfBgSelect"):setVisible(true)
			v:getChildByName("uiTfBgUnselect"):setVisible(false)
			v:getChildByName("uiIcon"):setRenderMode(3)
			v:getChildByName("uiIcon"):setOpacity(255 * 0.7)
			v:getChildByName("oEffect"):setVisible(true)
			v:getChildByName("uiStopSprite"):setVisible(false)
		else
			v:getChildByName("uiTfBgSelect"):setVisible(false)
			v:getChildByName("uiTfBgUnselect"):setVisible(true)
			v:getChildByName("uiIcon"):setRenderMode(0)
			v:getChildByName("uiIcon"):setOpacity(255)
			v:getChildByName("oEffect"):setVisible(false)
			v:getChildByName("uiStopSprite"):setVisible(true)
		end
	end


	GetMultiPlayerCtr():setCopyId(self.m_nCurSelectId)
end

function MultiPlayerMainPanel:Reset( ... )
	-- body
	self.m_sclContent:getContainer():removeAllChildren()
	-- self.m_nCurSelectId = 0
	if not self.m_stCates then
		self.m_stCates = {}
	else
		for k,v in pairs(self.m_stCates) do
			self.m_stCates[k] = nil
		end
	end

	-- if not self.m_stRewards then
	-- 	self.m_stRewards = {}
	-- else
	-- 	for k,v in pairs(self.m_stRewards) do
	-- 		if IsNodeValid(v) then
	-- 			v:removeFromParent()
	-- 		end
	-- 		self.m_stRewards[k] = nil
	-- 	end
	-- end
end

function MultiPlayerMainPanel:Dispose( ... )
	-- body
	MultiPlayerMainPanel.super.Dispose(self,...)
	MultiPlayerMainPanel.bOpened = false
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

return MultiPlayerMainPanel