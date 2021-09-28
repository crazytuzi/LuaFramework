local shaWarNode = class( "shaWarNode", function() return  cc.Layer:create() end)

function shaWarNode:ctor(bgSize)
	self.data = {}
	local msgids = {SHAWAR_SC_PICKREWARD_RET,SHAWAR_SC_GETSHAINFO_RET,FACTION_SC_GETSTATUERANK_RET}
	require("src/MsgHandler").new(self,msgids)
	self.WarData = require("src/config/ShaWarDB")

	g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_GETSHAINFO, "GetShaInfoProtocol", {})
	addNetLoading(SHAWAR_CS_GETSHAINFO, SHAWAR_SC_GETSHAINFO_RET)

	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETSTATUERANK, "FactionGetStatueRank", {})

    local bg = cc.Node:create()
    bg:setPosition(cc.p(0, 0))
    self:addChild(bg)
	self.bg = bg
	
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(176 - 88, 640 - 115),
        cc.size(790, 454),
        5,
        cc.p(0.0, 1)
     )
	createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(185 - 88, 640 - 424),cc.size(331, 300),cc.p(0, 0))
	createScale9Sprite(bg,"res/common/scalable/panel_inside_scale9.png",cc.p(524 - 88, 640 - 424),cc.size(433, 300),cc.p(0, 0))
	
	createSprite(bg, "res/empire/shaWar/shaBg.jpg", cc.p(185 - 88 + 1, 640 - 424 + 2), cc.p(0, 0))

	--报名时间
	local lab = createLabel(self.bg, game.getStrByKey("shaWar_ContriTime1") .. ":", cc.p(100, 250 + 30), cc.p(0, 1), 22, true) 
	self.contriTimeTitleLab = lab

	lab = createLabel(self.bg, "dada", cc.p(105 + self.contriTimeTitleLab:getContentSize().width, 250 + 30), cc.p(0, 1), 22) 
	lab:setColor(MColor.white)
	self.contriTimerLab = lab

	self:addBtn()

	--城主  城主奖励
	local lab = createLabel(self.bg, game.getStrByKey("worShip_Title3") .. ":", cc.p(100, 205), cc.p(0, 1), 22, true)
	lab = createLabel(self.bg, game.getStrByKey("biqi_str9"), cc.p(205, 205), cc.p(0, 1), 22)
	lab:setColor(MColor.yellow)
	self.kingNameLab = lab

	local lab = createLabel(self.bg, game.getStrByKey("shaWar_Award_Lead") .. ":", cc.p(100, 205 - 35), cc.p(0, 1), 22, true)
	local award = self.WarData[1].winReward
	local tab = unserialize(award)
	local awardID = tab[#tab]
	awardID = tab[1]
	local DropOp = require("src/config/DropAwardOp")
	local gdItem = DropOp:getItemBySexAndSchool(tonumber(awardID))

	local j = 1 
	local propOP = require("src/config/propOp")

	local tableNum = tablenums(gdItem)
	for m,n in pairs(gdItem) do
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
		{
			protoId = tonumber(n.q_item),
			--num = tonumber(n.q_count),
			swallow = true,
			cb = "tips",
			showBind = true,
			isBind = tonumber(n.bdlx or 0) == 1,
		})
		icon:setTag(9)
		bg:addChild(icon)
		icon:setPosition(cc.p(248 + ( j -1) * 90, 126))
		icon:setScale(0.98)
		j = j + 1
	end	
end

function shaWarNode:addBtn()
	local findNpc = function()
		local npcCfg = getConfigItemByKey("NPC", "q_id"  )[10392]
		local WorkCallBack = function()
			require("src/layers/mission/MissionNetMsg"):sendClickNPC(10392)
		end
		__removeAllLayers()

     	local tempData = { targetType = 4 , mapID = npcCfg.q_map ,  x = npcCfg.q_x , y = npcCfg.q_y , callFun = WorkCallBack  }
        __TASK:findPath( tempData )
	end	

	local goto = function()
		local MRoleStruct = require("src/layers/role/RoleStruct")
        local mapInfo = getConfigItemByKey("MapInfo", "q_id", 4100)
        if mapInfo and mapInfo.q_map_min_level and mapInfo.q_map_min_level > MRoleStruct:getAttr(ROLE_LEVEL) then
            local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
            local msgStr = string.format( msg_item.msg , tostring( mapInfo.q_map_min_level ) )
            TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr })
            return
        end         

		if self.data.isOpen then
			g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_GOTOSHA, "GotoShaProtocol", {})
		end
	end
	local getAward = function()		
		self:showAward()
	end
	
	local getShaWarLog = function()
		package.loaded["src/layers/shaWar/shaWarLogLayer"] = nil
		local subNode = require("src/layers/shaWar/shaWarLogLayer").new()
		self.bg:addChild(subNode, 10)
		subNode:setPosition(cc.p(480, 320))
	end

	local contributionTips = function()
		--package.loaded["src/layers/shaWar/ShaWarContributionLayer"] = nil
		local MyfacID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
		if MyfacID == 0 then
			TIPS({str = "加入行会后才能帮助行会申请攻打沙城" , type = 1})
			return
		end
		local subNode = require("src/layers/shaWar/ShaWarContributionLayer").new()	
		self.bg:addChild(subNode, 10)
		subNode:setPosition(cc.p(480, 320))		
	end

	self.BtnContribution = createMenuItem(self.bg, "res/component/button/49.png", cc.p(653, 255), contributionTips)
	createLabel(self.BtnContribution, game.getStrByKey("shaWar_Btn1"), getCenterPos(self.BtnContribution), nil, 22, true):setColor(MColor.lable_yellow)	
	
	self.btnGetAward = createMenuItem(self.bg, "res/component/button/50.png", cc.p( 545 + 20, 126), getAward)
	createLabel(self.btnGetAward, game.getStrByKey("shaWar_Btn2"), getCenterPos(self.btnGetAward), nil, 22, true):setColor(MColor.lable_yellow)
	
	self.getShaWarLogBtn = createMenuItem(self.bg, "res/component/button/50.png", cc.p( 545 + 20, 126), getShaWarLog)
	createLabel(self.getShaWarLogBtn, game.getStrByKey("shaWar_Btn3"), getCenterPos(self.getShaWarLogBtn), nil, 22, true):setColor(MColor.lable_yellow)

	self.btnGoto = createMenuItem(self.bg, "res/component/button/50.png", cc.p( 750, 126), goto)
	createLabel(self.btnGoto, game.getStrByKey("shaWar_Btn4"), getCenterPos(self.btnGoto), nil, 22, true):setColor(MColor.lable_yellow)
	self.btnGoto:setEnabled(false)

	local function ruleBtnFunc()
		self:showRule()
	end
	local ruleBtn = createMenuItem(self.bg, "res/component/button/small_help2.png", cc.p(117, 418 + 76), ruleBtnFunc)
	DATA_Battle:setRedData("SCZB", false)
end

function shaWarNode:showConRank(rankInfo)
	if self.bg:getChildByTag(250) then
		self.bg:removeChildByTag(250)
	end

	local subNode = require("src/layers/shaWar/ShaWarContributionRank").new(rankInfo)
	if subNode then
		self.bg:addChild(subNode,3, 250)
		subNode:setPosition(cc.p(524 - 88, 640 - 424 + 75))
	end
end

function shaWarNode:showAward()
	local award = self.WarData[1].dailyReward
	local tab = unserialize(award)
	local awardID = tab[#tab]
	if G_ROLE_MAIN:getTheName() == self.data.facData.kingName then
		awardID = tab[1]
	elseif G_ROLE_MAIN:getTheName() == self.data.facData.assleaderName then
		awardID = tab[2] or tab[#tab]
	end

	local bg = createSprite(self.bg, "res/common/5.png", cc.p(480, 320), nil,100)
	local bgSize = bg:getContentSize()
	createLabel(bg, game.getStrByKey("shaWar_Btn2"), getCenterPos(bg, 0 , 120), nil, 20, true)

	local DropOp = require("src/config/DropAwardOp")
	local gdItem = DropOp:dropItem(tonumber(awardID))

	local tableNum = tablenums(gdItem)
	tableNum = tableNum > 4 and 4 or tableNum
	local j = 1
	for m,n in pairs(gdItem) do
		if j > 4 then break end
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
		{
			protoId = tonumber(n.q_item),
			num = tonumber(n.q_count),
			swallow = true,
			cb = "tips",
			showBind = true,
			isBind = tonumber(n.bdlx or 0) == 1,
		})
		icon:setTag(9)
		bg:addChild(icon)
		icon:setPosition(cc.p(bgSize.width/2 - (tableNum/2 - j + 1) * 85, 180))
		icon:setAnchorPoint(0, 0.5)
		j = j + 1
	end
	createLabel(bg, game.getStrByKey("shaWar_canAwardCondition"), cc.p( bgSize.width/2, 110), nil, 20, true):setColor(MColor.lable_black)
	local getAward = function()
		g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_PICKREWARD, "ShaPickRewardProtocol", {})
	end	
	local awardBtn = createMenuItem(bg, "res/component/button/50.png", cc.p( bgSize.width/2, 45), getAward)
	createLabel(awardBtn, game.getStrByKey("shaWar_oneKeyAward"), getCenterPos(awardBtn), nil, 22):setColor(MColor.lable_yellow)
	self.btnGetOnDayAward = awardBtn
	
	awardBtn:setEnabled(self.data.isOccupy and self.data.facData.AwardEnable)
	local closeFunc = function()
		self.awardLayer = nil	
		self.btnGetOnDayAward = nil
		removeFromParent(bg)
	end
	self.awardLayer = bg
	registerOutsideCloseFunc( bg , closeFunc ,true)
end

function shaWarNode:showRule()
    local ruleBg = createSprite(self.bg,"res/common/helpBg.png",cc.p(480, 320), nil,100)
    local root_size = ruleBg:getContentSize()
    createSprite(ruleBg, "res/common/helpBg_title.png", cc.p(261, 290))
    createLabel(ruleBg, "信息", cc.p(261, 290), nil, 20):setColor(MColor.brown)

    registerOutsideCloseFunc(ruleBg, function() removeFromParent(ruleBg) end, true)

    local Node = cc.Node:create()
	local function createRichTextContent(parent, content, pos, size, anchor, lineHeight, fontSize, fontColor)
		local richText = require("src/RichText").new(parent, pos, size, anchor, lineHeight, fontSize, fontColor)
	    richText:addText(content)
	    richText:format()
	    return richText
	end

	local height = 0
	local offSetX = 40
	local data = require("src/config/PromptOp")
	local strCfg = {62, 49, 50, 51, 52, 53}
	local num = 6
	
	for i=1, num do
		local lab = createRichTextContent(Node, data:content(strCfg[num-i+1]), cc.p(offSetX, height), cc.size(root_size.width - 80, 30), cc.p(0, 0), 25, 20, MColor.brown_gray)
		height = height + lab:getContentSize().height
		lab = createLabel(Node, game.getStrByKey("empire_rule_"..(num-i+1) .. "_title_3") .. ":", cc.p(offSetX, height + 5 ), cc.p(0, 0), 22, true)
		lab:setColor(MColor.brown_gray)
		height = height + lab:getContentSize().height + 22
	end

	height = height - 10
	Node:setAnchorPoint(0,0)
	Node:setContentSize(cc.size(root_size.width, height))

    local scrollView1 = cc.ScrollView:create()
    scrollView1:setViewSize(cc.size( root_size.width - 20, root_size.height - 60 ) )
    scrollView1:setPosition( cc.p( 0 , 15 ) ) --250 , 65
    scrollView1:ignoreAnchorPointForPosition(true)

    scrollView1:setContainer(Node)
    scrollView1:updateInset()

    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    ruleBg:addChild(scrollView1)

    scrollView1:setContentOffset( cc.p(0, - Node:getContentSize().height + root_size.height - 50))		
end

function shaWarNode:updateInfo()
	if self.data.isOccupy then
		if self.kingNameLab and self.data.facData.facName ~= "" and self.data.facData.kingName ~= "" then
			local strName = self.data.facData.kingName 
			strName = strName .. "(" .. self.data.facData.facName .. ")"
			self.kingNameLab:setString(strName)
		end
	end

	if not self.data.isOpen and self.data.NextTime > 0 then
		local str = os.date("%Y-%m-%d  24:00:00", self.data.curTime + (self.data.NextTime - 1)* 24*3600 )
		self.contriTimeTitleLab:setString(game.getStrByKey("shaWar_ContriTime1") .. ":")
		self.contriTimerLab:setString(str)
	else
		self.contriTimeTitleLab:setString(game.getStrByKey("shaWar_ContriTime2"))
		self.contriTimerLab:setString("")
		self.contriTimeTitleLab:setPositionX(97 + 165)
		self.contriTimeTitleLab:setAnchorPoint(cc.p(0.5, 1))
	end

	local time = self.WarData[1]["openTime"]
	local tempTime = "19:00-20:00"
	-- if time then
	-- 	local strTime = StrSplit(time, ",")
	-- 	if strTime[5] then
	-- 		tempTime = strTime[5]
	-- 	end
	-- end	

	local str = ""
	if self.data.isOpen then
		str = string.format(game.getStrByKey("shaWar_begainTime2"), tempTime)
	else	
		local strDay = os.date("%Y-%m-%d ", self.data.curTime + self.data.NextTime * 24 * 3600)
		str = string.format(game.getStrByKey("shaWar_begainTime1"), strDay .. tempTime)
	end

	local richText = require("src/RichText").new(self.bg, cc.p(653 + 13, 205 - 8), cc.size(433, 22), cc.p(0.5,1), 22, 22, MColor.lable_yellow)
	richText:setAutoWidth()
	richText:addText(str)
	richText:format()
end
function shaWarNode:updateBtnStatus()
	local defId = G_SHAWAR_DATA.startInfo.DefenseID
	local MyfacID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
	if MyfacID == defId and defId ~= 0 then
		self.btnGetAward:setVisible(true)
		self.getShaWarLogBtn:setVisible(false)
	else
		self.btnGetAward:setVisible(false)
		self.getShaWarLogBtn:setVisible(true)		
	end

	self.btnGoto:setEnabled(self.data.isOpen)
end

function shaWarNode:networkHander(buff,msgid)
	local switch = {
	[SHAWAR_SC_GETSHAINFO_RET] = function( )
		self.data.facData = {}
		local retTab = g_msgHandlerInst:convertBufferToTable("GetShaInfoRetProtocol", buff)

		self.data.isOpen = retTab.isOpen	
		if not self.data.isOpen then
			self.data.NextTime = retTab.remainDayNum --下一次活动开始剩余天数
		end
		self.data.curTime = retTab.curTiem
		self.data.isOccupy = retTab.beOccupy
		if self.data.isOccupy then
			self.data.facData.facName = retTab.facName
			self.data.facData.sex = retTab.leaderSex
			self.data.facData.school = retTab.Leadersch
			self.data.facData.kingName = retTab.leadername
			self.data.facData.weaponId = retTab.weapon
			self.data.facData.clothes  = retTab.upperbody
			self.data.facData.wing   = retTab.wingID
			self.data.facData.assleaderName = retTab.assleaderName
			self.data.facData.AwardEnable  = retTab.canReward
		end
		dump(self.data, "self.data")
		self:updateInfo()
		self:updateBtnStatus()
	end,
	[SHAWAR_SC_PICKREWARD_RET] = function( )
		TIPS({str = "领取成功！", type = 1 })
		self.data.facData.AwardEnable = false
		if self.btnGetOnDayAward then
			performWithDelay(self, function() self.btnGetOnDayAward:setEnabled(false) end ,0.25 )
		end
	end,
	[FACTION_SC_GETSTATUERANK_RET] = function()
		local rankInfo = {}
		local retTab = g_msgHandlerInst:convertBufferToTable("FactionGetStatueRankRet", buff)
		local facID1 = retTab.shaFacId
		if facID1 > 1 then
			local facName,kingName = retTab.shaFacName, retTab.shaFacLeaderName
			if facName ~= "" and kingName ~= "" then
				local index = #rankInfo + 1
				--rankInfo[index] = {"沙城帮会" , facName, kingName, "", 0, 4}
			end
		end
		facID1 = retTab.zhongzhouFacId
		if facID1 > 1 then
			local facName,kingName = retTab.zhongFacName, retTab.zhongFacLeaderName
			if facName ~= "" and kingName ~= "" then
				local index = #rankInfo + 1
				--rankInfo[index] = {"中州帮会" , facName, kingName, "", 0, 5}
			end
		end

		local tempData = retTab.rdData
		local num = tempData and tablenums(tempData) or 0
		for i=1,num do
			local tempRec = tempData[i]
			local facId,facName,facLeadName,num = tempRec.facID,tempRec.facName,tempRec.facLeaderName,tempRec.statueNum
			local index = #rankInfo + 1
			rankInfo[index] = { "" .. i, facName, facLeadName, "" .. num , facId}
		end
		dump(rankInfo, "rankInfo")
		
		self:showConRank(rankInfo)
        
	end,
	}

	if switch[msgid] then
		switch[msgid]()
	end
end

return shaWarNode