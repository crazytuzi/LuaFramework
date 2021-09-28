-- FileName: MyReportTableView.lua 
-- Author: Zhang Zihang
-- Date: 2014/8/4
-- Purpose: 我的战报tableView的创建

module("MyReportTableView", package.seeall)

require "script/ui/lordWar/LordWarData"
require "script/utils/BaseUI"
require "script/model/user/UserModel"

local _touchPriority = nil
local _recordInfo = {}

--[[
	@des 	:创建tableView
	@param 	:处理后的我的战报的信息
	@return :创建好的tableView
--]]
function createTableView(p_myRecordInfo)
	require "script/ui/lordWar/myReport/MyReportNode"
	_touchPriority = MyReportNode.getTouchPriority()

	_recordInfo = p_myRecordInfo
	print("战绩信息")
	print_t(_recordInfo)

	local cellNum = table.count(p_myRecordInfo)

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(565,100)
		elseif fn == "cellAtIndex" then
			a2 = createInnerCell(p_myRecordInfo[cellNum - a1],cellNum - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = cellNum
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, CCSizeMake(565,515))
end

--[[
	@des 	:创建tableView的cell
	@param 	:$ p_cellInfo 每个cell的信息
	@param 	:$ p_index table下标索引
	@return :创建好的cell
--]]
function createInnerCell(p_cellInfo,p_index)
	local tCell = CCTableViewCell:create()

	--创一个node，方便在上面添加图片啥的
	--因为在cell上添加锚点只能设置为ccp(0,0)，会很蛋疼的 - - ！
	local cellNode = CCNode:create()
	cellNode:setContentSize(CCSizeMake(565,100))
	cellNode:setAnchorPoint(ccp(0,0))
	cellNode:setPosition(ccp(0,0))
	tCell:addChild(cellNode)

	--底层分割线
	local cutLineSprite = CCScale9Sprite:create("images/common/line02.png")
	cutLineSprite:setContentSize(CCSizeMake(550,5))
	cutLineSprite:setAnchorPoint(ccp(0.5,0))
	cutLineSprite:setPosition(ccp(cellNode:getContentSize().width/2,0))
	cellNode:addChild(cutLineSprite)

	--按钮层
	local cellMenu = CCMenu:create()
	cellMenu:setPosition(ccp(0,0))
	cellMenu:setAnchorPoint(ccp(0,0))
	cellMenu:setTouchPriority(_touchPriority - 2)
	cellNode:addChild(cellMenu)

	--查看战报按钮
	local checkReportMenuItem = CCMenuItemImage:create("images/battle/battlefield_report/look_n.png", "images/battle/battlefield_report/look_h.png")
	checkReportMenuItem:setAnchorPoint(ccp(1,0.5))
	checkReportMenuItem:setPosition(ccp(cellNode:getContentSize().width -10,cellNode:getContentSize().height/2))
	checkReportMenuItem:registerScriptTapHandler(checkReportCallBack)
	cellMenu:addChild(checkReportMenuItem,1,p_index)

	local outOrInLabel
	local tableName = {
							[1] = GetLocalizeStringBy("zzh_1100"),
							[2] = GetLocalizeStringBy("zzh_1101"),
					  }

	--服内
	if p_cellInfo.type == 1 or p_cellInfo.type == 2 then
		if p_cellInfo.type == 1 then
			outOrInLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1092") .. GetLocalizeStringBy("zzh_1096"),g_sFontPangWa,21)
		else
			outOrInLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1092") .. tableName[tonumber(p_cellInfo.teamType)],g_sFontPangWa,21)
		end
	--跨服
	else
		if p_cellInfo.type == 3 then
			outOrInLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1093") .. GetLocalizeStringBy("zzh_1096"),g_sFontPangWa,21)
		else
			outOrInLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1093") .. tableName[tonumber(p_cellInfo.teamType)],g_sFontPangWa,21)
		end
	end



	outOrInLabel:setColor(ccc3(0xff,0xf6,0x00))
	outOrInLabel:setAnchorPoint(ccp(0.5,1))
	outOrInLabel:setPosition(ccp(80,80))
	cellNode:addChild(outOrInLabel)

	local roundNumLable = CCLabelTTF:create("",g_sFontPangWa,25)
	roundNumLable:setColor(ccc3(0xff,0xff,0xff))
	--淘汰赛
	if p_cellInfo.type == 2 or p_cellInfo.type == 4 then
		local championSprite 
		if (p_cellInfo.round == LordWarData.kCross2To1) or (p_cellInfo.round == LordWarData.kInner2To1) then
			championSprite = CCSprite:create("images/lord_war/battlereport/champion_final.png")
		elseif (p_cellInfo.round == LordWarData.kCross4To2) or (p_cellInfo.round == LordWarData.kInner4To2) then
			championSprite = CCSprite:create("images/lord_war/battlereport/semi_final.png")
		else
			championSprite = CCSprite:create("images/lord_war/battlereport/playoff_final.png")
			if (p_cellInfo.round == LordWarData.kInner8To4) or (p_cellInfo.round == LordWarData.kCross8To4) then
				roundNumLable:setString("1/4")
			elseif (p_cellInfo.round == LordWarData.kInner16To8) or (p_cellInfo.round == LordWarData.kCross16To8) then
				roundNumLable:setString("1/8")
			else
				roundNumLable:setString("1/16")
			end
		end
		local connectNode = BaseUI.createHorizontalNode({roundNumLable,championSprite})
		connectNode:setAnchorPoint(ccp(0.5,0))
		connectNode:setPosition(ccp(80,10))
		cellNode:addChild(connectNode)
	--海选
	else
		roundNumLable:setString(GetLocalizeStringBy("key_2886") .. p_cellInfo.round .. GetLocalizeStringBy("zzh_1094"))
		roundNumLable:setAnchorPoint(ccp(0.5,0))
		roundNumLable:setPosition(ccp(80,10))
		cellNode:addChild(roundNumLable)
	end

	--对手名字
	local oppentName = CCLabelTTF:create(p_cellInfo.vsMan,g_sFontName,21)
	oppentName:setColor(ccc3(0x00,0xe4,0xff))
	oppentName:setAnchorPoint(ccp(0.5,1))
	oppentName:setPosition(ccp(250,80))
	cellNode:addChild(oppentName)

	--对手所在服务器
	local oppoentServer = CCLabelTTF:create("(" .. p_cellInfo.vsServer .. ")",g_sFontName,18)
	oppoentServer:setColor(ccc3(0xff,0xff,0xff))
	oppoentServer:setAnchorPoint(ccp(0.5,0))
	oppoentServer:setPosition(ccp(250,15))
	cellNode:addChild(oppoentServer)

	--比分
	local scoreLabel = CCLabelTTF:create(p_cellInfo.ownGet .. ":" .. p_cellInfo.heGet,g_sFontName,21)
	scoreLabel:setColor(ccc3(0x00,0xff,0x18))
	scoreLabel:setAnchorPoint(ccp(0.5,0.5))
	scoreLabel:setPosition(ccp(380,50))
	cellNode:addChild(scoreLabel)

	local resultSprite
	--自己赢了
	--在淘汰赛阶段且一方已到3
	if (p_cellInfo.type == 2 or p_cellInfo.type == 4) and (p_cellInfo.ownGet == 3 or p_cellInfo.heGet == 3) then
		--输赢
		if p_cellInfo.ownGet < p_cellInfo.heGet then
			resultSprite = CCSprite:create("images/battle/battlefield_report/fu.png")
		else
			resultSprite = CCSprite:create("images/battle/battlefield_report/sheng.png")
		end
		resultSprite:setAnchorPoint(ccp(0.5,0.5))
		resultSprite:setPosition(ccp(465,50))
		cellNode:addChild(resultSprite)
	end

	if (p_cellInfo.type == 1 or p_cellInfo.type == 3) then
		--输赢
		if p_cellInfo.ownGet < p_cellInfo.heGet then
			resultSprite = CCSprite:create("images/battle/battlefield_report/fu.png")
		else
			resultSprite = CCSprite:create("images/battle/battlefield_report/sheng.png")
		end
		resultSprite:setAnchorPoint(ccp(0.5,0.5))
		resultSprite:setPosition(ccp(465,50))
		cellNode:addChild(resultSprite)
	end

	return tCell
end

--[[
	@des 	:查看战报回调
	@param 	:tag值
	@return :
--]]
function checkReportCallBack(tag)
	--[[
    local netCallBack = function(ret)
		require "script/ui/lordWar/warReport/WarReportLayer"
		WarReportLayer.showLayer(ret)
	end
    --]]
	local curInfo = _recordInfo[tag]

	if (curInfo.type == 2) or (curInfo.type == 4) then
		-- local userUid = UserModel.getUserUid()
		-- local userServerId = LordWarData.getMyServerId()
		-- print("插卡结果",userUid)
		-- print("查看结果2",userServerId)
		-- print("得到的值")
		-- print_t(curInfo)
		-- require "script/ui/lordWar/LordWarService"
		-- LordWarService.getPromotionBtl(curInfo.round,curInfo.teamType,userServerId,userUid,curInfo.heServerId,curInfo.heUid,netCallBack)
		local isInner
		if curInfo.type == 2 then
			isInner = true
		else
			isInner = false
		end
		require "script/ui/lordWar/MyInfoLayer"
		MyInfoLayer.closeButtonCallback()
		require "script/ui/lordWar/warReport/WarReportLayer"
		WarReportLayer.showLayer(curInfo.allTable, _touchPriority - 500,888,isInner,curInfo.atkTable,curInfo.defTable,curInfo.atkWinNum,curInfo.defWinNum)
	else
		require "script/ui/lordWar/MyInfoLayer"
		MyInfoLayer.closeButtonCallback()
		require "script/battle/BattleUtil"
		BattleUtil.playerBattleReportById(curInfo.bid)
	end
end