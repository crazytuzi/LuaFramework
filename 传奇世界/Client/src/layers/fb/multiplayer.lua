-- -- 多人守卫副本
-- local multiplayer = class("multiplayer", function() return cc.Layer:create() end)
-- -- 子节点 创建队伍
-- local createTeamLayer = class("createTeamLayer", require("src/TabViewLayer"))
-- -- 队伍列表或者自己队伍列表
-- local teamDetail = class("teamDetail",require("src/TabViewLayer"))

-- local commConst = require("src/config/CommDef");

-- MultiData.m_currTeamId = 0

-- function multiplayer:ctor()
--     -- 初始化
--     self.m_subNode = nil;
--     self.m_selfMemNode = nil;
--     self.m_leftBtn = nil;
--     self.m_rightBtn = nil;
--     self.m_picSpr = nil;
--     self.m_insideSpr = nil;
--     self.m_recomandSpr = nil;
--     self.m_inNamesLal = nil;
--     self.m_firstAward = nil;
--     self.m_remomandLal = nil;

--     self.m_currSelFbId = 0;
--     self.m_index = 1;
    
--     self.m_fbData = require("src/config/MultiCopy");
--     self.m_inNums = table.size(self.m_fbData);

--     local msgids = {CHAT_SC_CALL_RET, COPY_SC_GETALLTEAMDATA}
--     require("src/MsgHandler").new(self, msgids)

--     --------------------------------------------------------------------------------------------
--     -- 重新设置数据
--     local fbId = MultiData.m_fbId
--     if fbId > 0 then
-- 	    for i,v in ipairs(self.m_fbData) do
-- 		    if self.m_fbData[i].CopyofID == fbId then
-- 			    self.m_index = i
--                 break;
-- 		    end
-- 	    end
--     else
--         -- 选中默认级别
--         self.m_index = MultiData.m_curLvl;
--     end
--     --------------------------------------------------------------------------------------------

-- 	local bg = createBgSprite(self, game.getStrByKey("fb_multiple"))
-- 	local centerSpr = createSprite(bg, "res/common/bg/bg-6.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2 - 30))
--     self.m_picSpr = createSprite(centerSpr, "res/fb/multiple/1.png", cc.p(17, 17), cc.p(0, 0));
--     self.m_insideSpr = createSprite(self.m_picSpr, "res/fb/multiple/3.png", cc.p(40, 99), cc.p(0, 0));
--     -- 添加滑动响应
--     local listenner = cc.EventListenerTouchOneByOne:create()
-- 	    listenner:setSwallowTouches(true)
-- 	    listenner:registerScriptHandler(function(touch, event)
--                 if self.m_picSpr and touch and event then
-- 				    local pt = self.m_picSpr:convertTouchToNodeSpace(touch)
-- 				    if cc.rectContainsPoint(self.m_insideSpr:getBoundingBox(),pt) then
-- 					    return true;
-- 				    end	  
--                 end  	
-- 				return false;
-- 			end,cc.Handler.EVENT_TOUCH_BEGAN)
-- 	    listenner:registerScriptHandler(function(touch, event)
--                 if self.m_picSpr and touch and event then
-- 				    local pt = self.m_picSpr:convertTouchToNodeSpace(touch)
-- 				    if cc.rectContainsPoint(self.m_insideSpr:getBoundingBox(),pt) then
--                         local start = touch:getStartLocation();
-- 	    		        local dest = touch:getLocation();
--                         local span = cc.p(dest.x - start.x, dest.y - start.y);
--                         if ( math.abs(span.x) > 50 and math.abs(span.y) < 80 ) then
--                             if span.x < 0 then  -- 往左
--                                 if self.m_index > 1 then
--                                     self.m_index = self.m_index - 1;
--                                     self:SetEveryInstance();
--                                 end
--                             else
--                                 if self.m_index < self.m_inNums then
--                                     if self.m_index < MultiData.m_curLvl then
--                                         self.m_index = self.m_index + 1;
--                                         self:SetEveryInstance();
--                                     else
--                                         TIPS{ type = 1, str = game.getStrByKey("multiRemind") };
--                                     end
--                                 end
--                             end
--                         end
-- 				    end
--                     return true;
--                 end

--                 return false;
-- 			end,cc.Handler.EVENT_TOUCH_ENDED)
-- 	    local eventDispatcher = self.m_insideSpr:getEventDispatcher()
-- 	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.m_insideSpr)

--     local littleSpr = createSprite(self.m_picSpr, "res/fb/multiple/2.png", cc.p(129, 470), cc.p(0, 0)); 
    
--     --function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
--     createLabel(self.m_picSpr, game.getStrByKey("fb_multiple"), cc.p(129+270, 475), nil, 20, true, nil, nil, MColor.white)
--     self.m_inNamesLal = createLabel(self.m_picSpr, "", cc.p(129+360, 475), nil, 20, true, nil, nil, MColor.gold)

--     self.m_levelRangeLal = createLabel(self.m_picSpr, "", cc.p(896/2, 450), cc.p(0.5, 0.5), 18, true, nil, nil)

--     -- 推荐战力
--     self.m_recomandSpr = createSprite(self.m_insideSpr, "res/fb/defense/flag-red.png", cc.p(71, 174), cc.p(0, 0)); 

--     createLabel(self.m_recomandSpr, game.getStrByKey("suggest_battleforce"), cc.p(136/2, 65), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)
--     self.m_remomandLal = createLabel(self.m_recomandSpr, "", cc.p(136/2, 35), cc.p(0.5, 0), 20, true, nil, nil, MColor.gold);

--     -- 规则介绍
--     local ruleStr = require("src/config/PromptOp"):content(57);
--     local ruleLal = require("src/RichText").new( self.m_insideSpr , cc.p( 220 , 220 ) , cc.size( 550 , 0 ) , cc.p( 0 , 0.5 ) , 22 , 20 , MColor.white )
-- 	ruleLal:addText( ruleStr , MColor.white , false )
-- 	ruleLal:format()

--     -- 每日首通奖励
--     createLabel(self.m_insideSpr, game.getStrByKey("multiDailyReward") ..game.getStrByKey("fb_prize"), cc.p(815/2, 136), cc.p(0.5, 0), 20, true, nil, nil, MColor.gold)

--     self.m_firstAward = cc.Node:create();
--     self.m_insideSpr:addChild(self.m_firstAward);

--     createLabel(self.m_insideSpr, game.getStrByKey("fb_teamTips"), cc.p(815/2, 2), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)
    
--     self.m_leftBtn = createTouchItem(self.m_picSpr, "res/group/arrows/17.png", cc.p(60, 250), function()
--             if self.m_index > 1 then
--                 self.m_index = self.m_index - 1;
--                 self:SetEveryInstance();
--             end
--         end);
--     self.m_leftBtn:setFlippedX(true);
-- 	self.m_leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(60-5, 250)), cc.MoveTo:create(0.3, cc.p(60, 250)))))
--     self.m_leftBtn:setVisible(false);

-- 	self.m_rightBtn = createTouchItem(self.m_picSpr, "res/group/arrows/17.png", cc.p(896-60, 250), function()
--             if self.m_index < self.m_inNums then
--                 if self.m_index < MultiData.m_curLvl then
--                     self.m_index = self.m_index + 1;
--                     self:SetEveryInstance();
--                 else
--                     TIPS{ type = 1, str = game.getStrByKey("multiRemind") };
--                 end
--             end
--         end)
-- 	self.m_rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(896-60+5, 250)), cc.MoveTo:create(0.3, cc.p(896-60, 250)))))
--     self.m_rightBtn:setVisible(false);

--     self:SetEveryInstance();
    
--     -- 下面的功能按钮
-- 	local createTeamBtn  = createMenuItem(self.m_picSpr, "res/component/button/50.png", cc.p(896/2 - 100, 40), function()
--         if self.m_selfMemNode ~= nil then
--             removeFromParent(self.m_selfMemNode)
--             self.m_selfMemNode = nil;
--         end

--         MultiData.m_currTeamId = 0
-- 		local nod = createTeamLayer.new(self.m_index, self)
-- 	    if nod then
-- 		    getRunScene():addChild(nod, 200)
--             self.m_selfMemNode = nod;
-- 	    end
-- 	end)
-- 	createLabel(createTeamBtn, game.getStrByKey("create_team"), getCenterPos(createTeamBtn), nil, 22, true, nil, nil, MColor.lable_yellow)

--     -- 加入队伍按钮
-- 	local joinTeamBtn = createMenuItem(self.m_picSpr, "res/component/button/50.png", cc.p(896/2 + 90, 40), function()
--         if self.m_subNode then
--             if not self.m_subNode.m_isList then
--                 removeFromParent(self.m_subNode)
--                 self.m_subNode = nil;   
--             end
-- 	    end

--         if self.m_subNode == nil then
--             local nod = teamDetail.new(self.m_index, self, true)
-- 	        if nod then
-- 		        getRunScene():addChild(nod, 200)
--                 self.m_subNode = nod;
--             end
-- 	    end

--         if self.m_subNode ~=nil then
-- 			self.m_subNode:UpdateData();
-- 		end
-- 	end)
-- 	createLabel(joinTeamBtn, game.getStrByKey("fb_joinIn") .. game.getStrByKey("fb_team"), getCenterPos(joinTeamBtn), nil, 22, true, nil, nil, MColor.lable_yellow)

--     self:registerScriptHandler(function(event)
-- 		if event == "enter" then
--             if g_msgHandlerInst ~= nil then
--                 -- 这个协议会返回自身队伍和队伍列表
--                 local proto = {};
--                 proto.copyId = self.m_currSelFbId;
--                 g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETTEAMDATA, "CopyGetTeamDataProtocol", proto);
--             end
-- 		elseif event == "exit" then
-- 			MultiData:RegisterCallback("multiplayer", nil);
-- 		end
-- 	end)

--     -- @param: 0-打开子节点
--     MultiData:RegisterCallback("multiplayer", function(para)
--         if para == nil then
--             return;
--         end

--         if para == 0 then
--             if self.m_subNode == nil then
--                 if self.m_selfMemNode == nil then
--                     self:WakeUpSubNode();
--                 end
--             end
--         elseif para == 1 then
--             -- 重新设置数据
--             self.m_index = MultiData.m_curLvl;
--             self:SetEveryInstance();
--             --------------------------------------------------------------------------------------------
--         end
--     end)
-- end

-- function multiplayer:WakeUpSubNode()
-- 	local fbId = MultiData.m_fbId
-- 	local curFbIndex = 1
-- 	for i,v in ipairs(self.m_fbData) do
-- 		if self.m_fbData[i].CopyofID == fbId then
-- 			curFbIndex = i
--             break;
-- 		end
-- 	end
-- 	self:openFbPop(curFbIndex)
-- end

-- -- 自己加入别人的队伍
-- function multiplayer:openFbPop(index)
-- 	if self.m_subNode then
-- 		if self.m_subNode.m_currSelIdx == index then
-- 			self.m_subNode:UpdateData();
-- 			return
-- 		else
-- 			removeFromParent(self.m_subNode)
--             self.m_subNode = nil;
-- 		end
-- 	end
--     local nod = teamDetail.new(index, self, false)
-- 	if nod then
-- 		getRunScene():addChild(nod, 200)
--         nod:UpdateData();
--         self.m_subNode = nod;
-- 	end
-- end

-- function multiplayer:SetEveryInstance()
--     if self.m_index <= 1 then
--         self.m_leftBtn:setVisible(false);
--     else
--         self.m_leftBtn:setVisible(true);
--     end

--     if self.m_index >= self.m_inNums then
--         self.m_rightBtn:setVisible(false);
--     else
--         self.m_rightBtn:setVisible(true);
--     end
    
-- 	local cellData = self.m_fbData[self.m_index]
-- 	if cellData then
-- 		self.m_inNamesLal:setString(cellData.Copyname);

--         if self.m_index == 1 then
--             local levelStr = "(Lv." .. tostring(cellData.accesslevel) .. ")";

--             local levelColor = MColor.green;
-- 		    if MRoleStruct:getAttr( ROLE_LEVEL ) < cellData.accesslevel then
--                 levelColor = MColor.red;
-- 		    end

--             self.m_levelRangeLal:setString(levelStr);
--             self.m_levelRangeLal:setColor(levelColor);
--         else
--             self.m_levelRangeLal:setString("");
--         end

--         self.m_remomandLal:setString(tostring(cellData.q_tjzl));

--         self.m_currSelFbId = tonumber(cellData.CopyofID)
--         -- 每日首通奖励
-- 	    self:addDayFirstPrize(cellData)
-- 	end
-- end

-- function multiplayer:addDayFirstPrize(fbData)
-- 	if self.m_firstAward then
-- 		self.m_firstAward:removeAllChildren();
-- 	end

-- 	if fbData then        
--         local awards = {}
--         local DropOp = require("src/config/DropAwardOp")
--         local awardsConfig = DropOp:dropItem_ex(tonumber(fbData.reward));
--         for i=1, #awardsConfig do
--             awards[i] =  { 
--                               id = awardsConfig[i]["q_item"] ,       -- 奖励ID
--                               num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
--                               streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
--                               quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
--                               upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
--                               time = awardsConfig[i]["q_time"] ,     -- 限时时间
--                               showBind = true,
--                               isBind = tonumber(awardsConfig[i]["bdlx"]) == 1,     -- 绑定(1绑定0不绑定)
--                             }
--         end

--         if tablenums( awards ) > 0 then
--             --function __createAwardGroup( awards , isShowName , Interval , offX , isSwallow )
--             local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
--             setNodeAttr( groupAwards , cc.p( 815/2, 20 ) , cc.p( 0.5 , 0 ) )
--             self.m_firstAward:addChild(groupAwards);
--         end
-- 	end
-- end

-- function multiplayer:networkHander(luabuffer,msgid)
--     local switch = {
--         [CHAT_SC_CALL_RET] = function()
-- 			--喊话返回
--             local proto = g_msgHandlerInst:convertBufferToTable("CallMsgRetProtocol", luabuffer)
-- 			local ret = proto.callMsgRet;
-- 			if ret then
-- 				TIPS({ str =  game.getStrByKey("team_hanren2") })
-- 			end
-- 		end,
--         -- 队伍列表信息更新
--         [COPY_SC_GETALLTEAMDATA] = function()
        	
--             local proto = g_msgHandlerInst:convertBufferToTable("CopyGetAllTeamDataProtocol", luabuffer)

--         	MultiData.m_listFbId = proto.copyId;
--         	MultiData.m_teamNum = proto.teamNum;
        	
--             local info = proto.info;

--         	MultiData.m_teamInfo = {}
--         	for i=1, MultiData.m_teamNum do
--                 MultiData.m_teamInfo[i] = {info[i].teamId, info[i].leaderName, info[i].needBattle, info[i].memberCnt};
--         	end
        	
--             MultiData:ExecuteCallback("teamDetail", 1);
--        	end
-- 		}

--     if switch[msgid] then 
--         switch[msgid]()
--     end
-- end

-- ---------------------------------------------------------------------------------

-- function createTeamLayer:ctor(indx, node)
--     -- 初始化
--     self.m_fbData = require("src/config/MultiCopy");
--     if self.m_fbData ~= nil and self.m_fbData[indx] ~= nil then
--         self.m_singleFbData = self.m_fbData[indx];
--         self.m_currSelFbId = self.m_singleFbData.CopyofID;
--     else
--         return;
--     end
--     self.m_autoOpen = true;
--     self.m_battleRequire = 0;
--     self.m_teamMemNum = 0;
--     self.m_teamMemInfo = nil;
--     self.m_currSelIdx = indx;
    
--     self.m_mainNode = node;
--     self.m_memListLal = nil;
--     self.m_outoOpenSpr = nil;

--     self.m_baseNode = createSprite( self, "res/common/bg/bg44.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) );

--     local nameLal = createLabel(self.m_baseNode, game.getStrByKey("create_team"), cc.p(850/2, 529-25),cc.p(0.5, 0.5), 28, true, nil, nil, MColor.lable_yellow, 12580)

--     -- 左边部分
--     local leftSpr = createSprite(self.m_baseNode, "res/fb/multiple/4.png", cc.p(25, 25), cc.p(0, 0));

--     createSprite(leftSpr, "res/fb/multiple/7.png", cc.p(11, 408), cc.p(0, 0));
--     createLabel(leftSpr, game.getStrByKey("multiSetting"), cc.p(200, 415), nil, 20, true, nil, nil, cc.c3b(247, 206, 150))

--     local changeSelect = function()
-- 		local isVisible = self.m_outoOpenSpr:isVisible() 
--     	self.m_outoOpenSpr:setVisible(not isVisible)
--     	self.m_autoOpen = not self.m_autoOpen;

--         self:AutoOpenInstance();
-- 	end
-- 	createTouchItem(leftSpr,"res/component/checkbox/1.png",cc.p(55, 354),changeSelect)
-- 	self.m_outoOpenSpr = createSprite(leftSpr,"res/component/checkbox/1-1.png",cc.p(55, 353))
-- 	createLabel(leftSpr, game.getStrByKey("fb_desc6"), cc.p(80, 343), cc.p(0, 0), 20, 1.0, 1, nil, cc.c3b(189, 142, 107))
-- 	self.m_outoOpenSpr:setVisible(self.m_autoOpen);

--     createSprite(leftSpr, "res/fb/multiple/8.png", cc.p(392/2, 300), cc.p(0.5, 0));

--     createLabel(leftSpr, game.getStrByKey("fb_desc7"), cc.p(392/2, 265), cc.p(0.5, 0), 20, true, nil, nil, cc.c3b(247, 206, 160))

--     ----------------------------------------------------------------
--     local MRoleStruct = require("src/layers/role/RoleStruct")
-- 	local combat = MRoleStruct:getAttr(PLAYER_BATTLE)
-- 	local startZl = 3.0
-- 	local endZl = ( GetPreciseDecimal(combat / 1000, 1) > 0)and GetPreciseDecimal(combat / 1000, 1) or 1.0
	
-- 	if endZl < startZl then
-- 		endZl = startZl
-- 	end

--     local tmpConfig = { sp = startZl, ep = endZl, cur = endZl }

--     -- 滑动部分
--     local selector = Mnode.createSelector(
--     {
-- 	    config = tmpConfig,
-- 	    onValueChanged = function(selector, value)
--             print("\n" .. value);
-- 	    end,
--         unit = 0.1,
--     })

--     selector:setScale(0.85)
--     selector:setPosition(cc.p(188, 181));
--     local inputEdit = selector:GetInputEditbox();
--     if inputEdit ~= nil then
--         inputEdit:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL);
--     end
--     leftSpr:addChild(selector);

--     -- 选择范围
--     createLabel(leftSpr, game.getStrByKey("input")..game.getStrByKey("range").."：" .. string.format("%0.1f", tmpConfig.sp) .. "-" .. string.format("%0.1f", tmpConfig.ep), cc.p(392/2, 90), cc.p(0.5, 0), 20, true, nil, nil, cc.c3b(247, 206, 160))

--     createSprite(leftSpr, "res/fb/multiple/8.png", cc.p(392/2, 60), cc.p(0.5, 0));

--     ----------------------------------------------------------------
--     local MMenuButton = require("src/component/button/MenuButton")
--     -- 确定按钮
--     local ConfirmBtn = MMenuButton.new(
--     {
-- 	    src = {"res/component/button/49.png", "res/component/button/49_sel.png"},
-- 	    label = {
-- 		    src = game.getStrByKey("sure"),
-- 		    size = 22,
-- 		    color = MColor.lable_yellow,
-- 	    },
-- 	    cb = function()
--                 if MultiData.m_currTeamId == nil or MultiData.m_currTeamId == 0 then
--                     self.m_battleRequire = selector:value()
--                     local proto = {};
--                     proto.copyId = self.m_currSelFbId;
--                     proto.needBattle = self.m_battleRequire * 1000;
-- 		            g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_CREATECOPYTEAM, "CopyCreateTeamProtocol", proto);
--                 end
--             end,
--     })

--     Mnode.addChild(
--     {
-- 	    parent = leftSpr,
-- 	    child = ConfirmBtn,
-- 	    pos = cc.p(200, 28),
--     })
--     ----------------------------------------------------------------

--     -- 右边部分
--     local rightSpr = createSprite(self.m_baseNode, "res/fb/multiple/5.png", cc.p(425, 95), cc.p(0, 0));

--     createSprite(rightSpr, "res/fb/multiple/11.png", cc.p(11, 338), cc.p(0, 0));
--     createLabel(rightSpr, game.getStrByKey("multiMemList"), cc.p(170, 345), nil, 20, true, nil, nil, cc.c3b(247, 206, 150))
--     self.m_memListLal = createLabel(rightSpr, "0/4", cc.p(235, 345), nil, 20, true, nil, nil, MColor.white)

--     -- function TabViewLayer:createTableView(parent,size,pos,t_type,sliderFile)
--     self:createTableView(rightSpr,cc.size(358, 310),cc.p(7, 15),true)

--     -- 离开按钮
--     local leaveBtn  = createMenuItem(self.m_baseNode, "res/component/button/50.png", cc.p(515, 50), function()
--         if self.m_teamMemInfo ~= nil then
--             g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_LEAVECOPYTEAM, "CopyLeaveTeamProtocol", {});
--         end

--         if self.m_mainNode ~= nil then
--             self.m_mainNode.m_selfMemNode = nil;
--         end

--         MultiData.m_currTeamId = 0;

-- 	    removeFromParent(self);
-- 	end)
-- 	createLabel(leaveBtn, game.getStrByKey("fb_leave"), getCenterPos(leaveBtn), nil, 22, true, nil, nil, MColor.lable_yellow)

--     -- 开启副本
--     local startBtn  = createMenuItem(self.m_baseNode, "res/component/button/50.png", cc.p(700, 50), function()
-- 	    userInfo.lastFb = self.m_currSelFbId
-- 		setLocalRecordByKey(2, "subFbType", "" .. userInfo.lastFb)
-- 		userInfo.lastFbType = commConst.CARBON_MULTI_GUARD
-- 		setLocalRecordByKey(2,"lastFbType","5");

--         local proto = {};
--         proto.copyId = userInfo.lastFb;
-- 		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol", proto);
-- 	end)
-- 	createLabel(startBtn, game.getStrByKey("fb_startFb"), getCenterPos(startBtn), nil, 22, true, nil, nil, MColor.lable_yellow)
    
--     ----------------------------------------------------------------
--     SwallowTouches(self);

--     self:registerScriptHandler(function(event)
-- 		if event == "enter" then
--             if g_msgHandlerInst ~= nil then
--                 local proto = {};
--                 proto.copyId = self.m_currSelFbId;
--                 g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETTEAMDATA, "CopyGetTeamDataProtocol", proto);
--             end
-- 		elseif event == "exit" then
--             MultiData:RegisterCallback("createTeamLayer", nil);

--             if g_msgHandlerInst ~= nil then
--                 local proto = {};
--                 proto.flag = 0;
--                 g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_OPENMULTIWIN, "CopyOpenMultiWinProtocol", proto)
--             end
-- 		end
-- 	end)

--     -- @param: 0-打开子节点
--     MultiData:RegisterCallback("createTeamLayer", function(para)
--         if para == nil then
--             return;
--         end

--         if para == 0 then
--             self:UpdateSelfTeam();
--         end
--     end)
-- end

-- function createTeamLayer:cellSizeForTable(table,idx) 
--     return 75,358
-- end

-- function createTeamLayer:numberOfCellsInTableView(table)
-- 	return 4;
-- end

-- function createTeamLayer:tableCellTouched(table,cell)
-- end

-- -- 更新自身队伍信息
-- function createTeamLayer:UpdateSelfTeam()
-- 	self.m_battleRequire = MultiData.m_battleRequire*10
-- 	self.m_teamMemNum = MultiData.m_teamMemNum
-- 	self.m_teamMemInfo = MultiData.m_teamMemInfo

--     self.m_memListLal:setString(tostring(self.m_teamMemNum) .. "/4");
    
-- 	self:getTableView():reloadData();

--     self:AutoOpenInstance();
-- end

-- function createTeamLayer:AutoOpenInstance()
--     if self.m_autoOpen and MultiData.m_teamMemNum >= 4 and MultiData.m_teamMemInfo ~= nil and #(MultiData.m_teamMemInfo) >= 4 then
--         -- 自动开启，是否4个成员全部准备
--         local readyNum = 0;
--         for i = 1, #(MultiData.m_teamMemInfo) do
--             if MultiData.m_teamMemInfo[i] ~= nil and MultiData.m_teamMemInfo[i][4] then
--                 readyNum = readyNum + 1;
--             end
--         end

--         if readyNum >= 4 then
--             userInfo.lastFb = self.m_currSelFbId
-- 		    setLocalRecordByKey(2, "subFbType", "" .. userInfo.lastFb)
-- 		    userInfo.lastFbType = commConst.CARBON_MULTI_GUARD
-- 		    setLocalRecordByKey(2,"lastFbType","5")

--             local proto = {};
--             proto.copyId = userInfo.lastFb;
-- 		    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol", proto)
--         end
--     end
-- end

-- function createTeamLayer:tableCellAtIndex(table, idx)
--     local cell = table:dequeueCell();

--     if not cell then
--         cell = cc.TableViewCell:new();
--     else
--         cell:removeAllChildren();
--     end
        
--     local bg = createSprite(cell,"res/fb/multiple/12.png",cc.p(0,3),cc.p(0.0,0.0))
    
--     if self.m_teamMemInfo ~= nil and self.m_teamMemInfo[idx+1] ~= nil then
--         local currMemInfo = self.m_teamMemInfo[idx+1]
--         if currMemInfo[4] then
-- 			createLabel(bg, game.getStrByKey("already") .. game.getStrByKey("fb_getReady"), cc.p(30, 35), nil, 18, true, nil, nil, MColor.green)
--         else
--             createLabel(bg, game.getStrByKey("multiReading"), cc.p(30, 35), nil, 18, true, nil, nil, MColor.red)
-- 		end
            
--         -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
--         local nameStr = currMemInfo[2];
--         -- 队长
--         if idx == 0 then
-- 			nameStr = nameStr .. "(" .. game.getStrByKey("multiLeader") .. ")"
-- 		end
--         createLabel(bg, nameStr, cc.p(78, 40), cc.p(0, 0), 18, true, nil, nil, cc.c3b(255, 241, 121))

-- 		createLabel(bg, game.getStrByKey("combat_power") ..":", cc.p(78, 10), cc.p(0, 0), 18, true, nil, nil, cc.c3b(247, 206, 150))
--         createLabel(bg, tostring(currMemInfo[3]), cc.p(160, 10), cc.p(0, 0),18, true, nil, nil, MColor.white)

-- 		-- 操作按钮
--         local str = game.getStrByKey("look_up")
-- 		local funcBtn = createMenuItem(bg, "res/component/button/48.png", cc.p(305, 34), function()
--                 if str==game.getStrByKey("look_up") then
-- 			        LookupInfo(currMemInfo[2])
--                 elseif str==game.getStrByKey("fb_leave") then
-- 			        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_LEAVECOPYTEAM, "CopyLeaveTeamProtocol", {})
-- 			    elseif str==game.getStrByKey("fb_kickOut") then
--                     local proto = {};
--                     proto.targetId = currMemInfo[1];
-- 			        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_REMOVECOPYMEM, "CopyRemoveTeamMemberProtocol", proto)
-- 			    elseif str==game.getStrByKey("fb_hanren") then
--                     -- 部分信息可能会无法获取，校验下
--                     local tmpLine = MRoleStruct:getAttr(PLAYER_LINE);
--                     if MultiData ~= nil and MultiData.m_currTeamId ~= nil and MultiData.m_currTeamId ~= 0 and G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil and G_MAINSCENE.map_layer.mapID ~= nil and tmpLine ~= nil then
--                         local text = game.getStrByKey("multi_auto_invite")
-- 				        local fbName = self.m_singleFbData.Copyname
-- 				        text = string.format(text, fbName, tostring(self.m_teamMemNum), tostring(self.m_battleRequire*1000))

--                         local proto = {}
--                         proto.channel = commConst.Channel_ID_Area
--                         proto.message = text
--                         proto.area = 1
--                         proto.callType = 1
--                         proto.paramNum = 3
--                         proto.callParams = {
--                             tostring(MultiData.m_currTeamId),
--                             tostring(G_MAINSCENE.map_layer.mapID),
--                             tostring(tmpLine)
--                         }
                        
--                         g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", proto);
--                     end
-- 			    end
-- 		    end)

-- 		if G_ROLE_MAIN ~= nil and G_ROLE_MAIN:getTheName() == currMemInfo[2] then	
-- 			if G_ROLE_MAIN:getTheName() == self.m_teamMemInfo[1][2] then
-- 			    str = game.getStrByKey("fb_hanren")
-- 			else    -- 加入队伍呼出来
-- 			    str = game.getStrByKey("fb_leave")
-- 			end
-- 		else
-- 			if G_ROLE_MAIN ~= nil and G_ROLE_MAIN:getTheName() == self.m_teamMemInfo[1][2] then
-- 			    str = game.getStrByKey("fb_kickOut")
-- 			end
-- 		end
-- 		createLabel(funcBtn, str, getCenterPos(funcBtn), nil, 21, true)
--     end
    
--     return cell
-- end

-- ---------------------------------------------------------------------------------

-- function teamDetail:ctor(index, node, isList)
--     -- 是列表 还是成员
--     self.m_isList = isList;
--     self.m_currSelIdx = index;

--     self.m_fbData = require("src/config/MultiCopy");
--     if self.m_fbData ~= nil and self.m_fbData[index] ~= nil then
--         self.m_singleFbData = self.m_fbData[index];
--         self.m_currSelFbId = self.m_singleFbData.CopyofID;
--     else
--         return;
--     end

-- 	self.m_node = node;
--     self.m_nameLal = nil;
--     self.m_operateLal = nil;

--     self.m_baseNode = createSprite( self, "res/common/bg/bg27.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) );
--     local bgSize = self.m_baseNode:getContentSize();
    
--     local nameStr = "";
--     local operateStr = "";
--     if self.m_isList then
--         nameStr = game.getStrByKey("fb_teamList");
--         operateStr = game.getStrByKey("fb_quickJoin");
--     else
--         nameStr = game.getStrByKey("multiMemList");
--         operateStr = game.getStrByKey("fb_getReady");
--     end
--     self.m_nameLal = createLabel(self.m_baseNode, nameStr, cc.p(bgSize.width/2, bgSize.height-41),cc.p(0.5, 0), 28, true, nil, nil, MColor.lable_yellow)
    
--     local rightSpr = createSprite(self.m_baseNode, "res/fb/multiple/5.png", cc.p(402/2, 98), cc.p(0.5, 0));

--     self:createTableView(rightSpr, cc.size(358, 350),cc.p(8,10),true)

--     -- 功能按钮
--     local operateBtn  = createMenuItem(self.m_baseNode, "res/component/button/50.png", cc.p(201, 50), function()
--             local curStr = self.m_operateLal:getString();
--             if curStr == game.getStrByKey("fb_quickJoin") then
--                 local proto = {};
--                 proto.copyId = self.m_currSelFbId;
-- 			    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_AUTOJOIN, "CopyAutoJoinTeamProtocol", proto);

--                 if self.m_node ~= nil then
--                     self.m_node.m_subNode = nil;
--                 end
--                 removeFromParent(self);
-- 		    elseif curStr == game.getStrByKey("fb_getReady") then
--                 -- 需要保存副本数据
--                 local commConst = require("src/config/CommDef");

-- 			    userInfo.lastFb = self.m_currSelIdx
-- 			    setLocalRecordByKey(2,"subFbType",""..userInfo.lastFb)
-- 			    userInfo.lastFbType = commConst.CARBON_MULTI_GUARD
-- 			    setLocalRecordByKey(2,"lastFbType","5")

--                 local proto = {};
--                 proto.ready = true;
-- 			    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_READY, "CopyTeamReadyProtocol", proto);
-- 		    elseif curStr == game.getStrByKey("fb_cancelReady") then
--                 local proto = {};
--                 proto.ready = false;
-- 			    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_READY, "CopyTeamReadyProtocol", proto);
--             elseif curStr == game.getStrByKey("fb_startFb") then
--                 userInfo.lastFb = self.m_singleFbData.CopyofID;
-- 		        setLocalRecordByKey(2, "subFbType", "" .. userInfo.lastFb)
-- 		        userInfo.lastFbType = commConst.CARBON_MULTI_GUARD
-- 		        setLocalRecordByKey(2,"lastFbType","5")

--                 local proto = {};
--                 proto.copyId = userInfo.lastFb;
-- 		        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol", proto);
-- 		    end
-- 	    end)
-- 	self.m_operateLal = createLabel(operateBtn, operateStr, getCenterPos(operateBtn), nil, 22, true, nil, nil, MColor.lable_yellow)
    
--     -- 关闭按钮
--     local closeBtn = createMenuItem( self.m_baseNode, "res/component/button/X.png", cc.p(bgSize.width-38, bgSize.height-26), function(isClickBtn)
--         if not self.m_isList then
--             g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_LEAVECOPYTEAM, "CopyLeaveTeamProtocol", {});
            
--             MultiData:ClearSelfTeamInfo();
--             MultiData:ShowLeaveTeamTips();
--         end

--         if self.m_node ~= nil then
--             self.m_node.m_subNode = nil;
--         end
--         -- 退出队伍，清空
--         MultiData.m_currTeamId = 0;

--         removeFromParent(self);
--     end)

--     SwallowTouches(self);

--     self:registerScriptHandler(function(event)
-- 		if event == "enter" then
--             if g_msgHandlerInst ~= nil then
--                 local proto = {};
--                 proto.copyId = self.m_currSelFbId;
--                 g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETTEAMDATA, "CopyGetTeamDataProtocol", proto);
--             end
-- 		elseif event == "exit" then
--             MultiData:RegisterCallback("teamDetail", nil);

--             if g_msgHandlerInst ~= nil then
--                 local proto = {};
--                 proto.flag = 0;
--                 g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_OPENMULTIWIN, "CopyOpenMultiWinProtocol", proto)
--             end
-- 		end
-- 	end)

--     -- @param: 0-打开子节点
--     MultiData:RegisterCallback("teamDetail", function(para)
--         if para == nil then
--             return;
--         end

--         -- 自身队伍更新
--         if para == 0 then
--             self:UpdateData();
--         elseif para == 1 then
--             self:UpdateData();
--         end
--     end)
-- end

-- function teamDetail:cellSizeForTable(table,idx) 
--     return 75,358
-- end

-- function teamDetail:numberOfCellsInTableView(table)
--     if self.m_isList then
--         if MultiData.m_teamInfo ~= nil then
--             return #(MultiData.m_teamInfo);
--         else
-- 	        return 0;
--         end 
--     else
--         return 4;
--     end
-- end

-- function teamDetail:tableCellTouched(table,cell)
-- end

-- function teamDetail:UpdateData()
--     if not self.m_isList then
--         -- 是否准备
--         if MultiData.m_teamMemInfo ~= nil and #(MultiData.m_teamMemInfo) > 0 then
--             local isReady = false
-- 		    if MultiData.m_teamMemInfo[1][1] == userInfo.currRoleId then
--                 self.m_operateLal:setString(game.getStrByKey("fb_startFb"))
--             else
-- 			    for i=1, #(MultiData.m_teamMemInfo) do
-- 				    if MultiData.m_teamMemInfo[i][1] == userInfo.currRoleId then
-- 					    isReady = MultiData.m_teamMemInfo[i][4]
-- 					    break
-- 				    end
-- 			    end
-- 			    if isReady then
-- 				    self.m_operateLal:setString(game.getStrByKey("fb_cancelReady"))
-- 			    else
-- 				    self.m_operateLal:setString(game.getStrByKey("fb_getReady"))
-- 			    end
-- 		    end
--         else    -- 可能被其他人踢掉了
--             if self.m_node ~= nil then
--                 self.m_node.m_subNode = nil;
--             end
--             removeFromParent(self);
--             return;
--         end

--         -- 标题更新
--         local nameStr = game.getStrByKey("multiMemList") .. tostring(MultiData.m_teamMemNum) .. "/4";
--         self.m_nameLal:setString(nameStr);
--     end

-- 	self:getTableView():reloadData()
-- end

-- function teamDetail:tableCellAtIndex(table, idx)
-- 	local cell = table:dequeueCell();

--     if not cell then
--         cell = cc.TableViewCell:new();
--     else
--         cell:removeAllChildren();
--     end

--     local bg = createSprite(cell,"res/fb/multiple/12.png",cc.p(0,3),cc.p(0.0,0.0))
    
--     -- 自己队伍
--     if not self.m_isList then
--         if MultiData.m_teamMemInfo ~= nil then
--     	    local currMemInfo = MultiData.m_teamMemInfo[idx+1]
--     	    if currMemInfo then
--                 if currMemInfo[4] then
-- 			        createLabel(bg, game.getStrByKey("already") .. game.getStrByKey("fb_getReady"), cc.p(30, 35), nil, 18, true, nil, nil, MColor.green)
--                 else
--                     createLabel(bg, game.getStrByKey("multiReading"), cc.p(30, 35), nil, 18, true, nil, nil, MColor.red)
-- 		        end

--                 local nameStr = currMemInfo[2];
--                 -- 队长
--                 if idx == 0 then
-- 			        nameStr = nameStr .. "(" .. game.getStrByKey("multiLeader") .. ")"
-- 		        end
--                 createLabel(bg, nameStr, cc.p(78, 40), cc.p(0, 0), 18, true, nil, nil, cc.c3b(255, 241, 121))

--                 createLabel(bg, game.getStrByKey("combat_power") ..":", cc.p(78, 10), cc.p(0, 0), 18, true, nil, nil, cc.c3b(247, 206, 150))
--                 createLabel(bg, tostring(currMemInfo[3]), cc.p(160, 10), cc.p(0, 0),18, true, nil, nil, MColor.white)

--                 -- 操作按钮
-- 			    local str = game.getStrByKey("look_up")
-- 			    local funcBtn = createMenuItem(bg, "res/component/button/48.png", cc.p(305, 34), function()
--                         if str==game.getStrByKey("look_up") then
-- 			    	        LookupInfo(currMemInfo[2])
-- 			            elseif str==game.getStrByKey("fb_kickOut") then
--                             local proto = {};
--                             proto.targetId = currMemInfo[1];
-- 			    	        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_REMOVECOPYMEM, "CopyRemoveTeamMemberProtocol", proto)
-- 			            elseif str==game.getStrByKey("fb_leave") then
-- 			    	        g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_LEAVECOPYTEAM, "CopyLeaveTeamProtocol", {});
--                             MultiData:ClearSelfTeamInfo();
--                             MultiData:ShowLeaveTeamTips();

--                             if self.m_parent ~= nil then
--                                 self.m_parent.m_subNode = nil;
--                             end
--                             removeFromParent(self);
-- 			            elseif str==game.getStrByKey("fb_hanren") and G_FBMULTIPLE_DATA.currTeamId ~= 0 then
-- 			    	        if MultiData.m_currTeamId ~= 0 and G_MAINSCENE ~= nil and G_MAINSCENE.map_layer ~= nil then
--                                 local text = game.getStrByKey("multi_auto_invite")
-- 				                local fbName = self.m_singleFbData.Copyname
-- 				                text = string.format(text, fbName, tostring(MultiData.m_teamMemNum), tostring(MultiData.m_battleRequire*10000))

--                                 local proto = {}
--                                 proto.channel = commConst.Channel_ID_Area
--                                 proto.message = text
--                                 proto.area = 1
--                                 proto.callType = 1
--                                 proto.paramNum = 3
--                                 proto.callParams = {
--                                     tostring(MultiData.m_currTeamId),
--                                     tostring(G_MAINSCENE.map_layer.mapID),
--                                     tostring(MRoleStruct:getAttr(PLAYER_LINE))
--                                 }
                        
--                                 g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", proto)
--                             end
-- 			            end
--                     end)
			
-- 			    if G_ROLE_MAIN ~= nil and G_ROLE_MAIN:getTheName() == currMemInfo[2] then	
-- 			        if G_ROLE_MAIN:getTheName() == MultiData.m_teamMemInfo[1][2] then
-- 			    	    str = game.getStrByKey("fb_hanren")
-- 			        else
-- 			    	    str = game.getStrByKey("fb_leave")
-- 			        end
-- 			    else
-- 			        if G_ROLE_MAIN ~= nil and G_ROLE_MAIN:getTheName() == MultiData.m_teamMemInfo[1][2] then
-- 			    	    str = game.getStrByKey("fb_kickOut")
-- 			        end
-- 			    end
-- 			    createLabel(funcBtn, str, getCenterPos(funcBtn), nil, 21, true)
--     	    end
--         end
--     else
--         if MultiData.m_teamInfo ~= nil then
--     	    local currTeamInfo = MultiData.m_teamInfo[idx+1]
--     	    if currTeamInfo then
--                 local memNumLab = createLabel(bg, tostring(currTeamInfo[4]) .. "/4", cc.p(30, 35), nil, 18, true, nil, nil, MColor.white);

--                 createLabel(bg, currTeamInfo[2], cc.p(78, 40), cc.p(0, 0), 18, true, nil, nil, cc.c3b(255, 241, 121))
                
--                 createLabel(bg, game.getStrByKey("fb_requireBattle"), cc.p(78, 10), cc.p(0, 0), 18, true, nil, nil, cc.c3b(247, 206, 150))
--                 createLabel(bg, tostring(currTeamInfo[3]), cc.p(160, 10), cc.p(0, 0),18, true, nil, nil, MColor.white)

--                 local MRoleStruct = require("src/layers/role/RoleStruct")
-- 			    local combat = MRoleStruct:getAttr(PLAYER_BATTLE)

--     		    local funcBtn = createMenuItem(bg, "res/component/button/48.png", cc.p(305, 34), function()
--                         local proto = {};
--                         proto.teamId = currTeamInfo[1];
--                         g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_JOINCOPYTEAM, "CopyJoinTeamProtocol", proto);
--                         if self.m_node ~= nil then
--                             self.m_node.m_subNode = nil;
--                         end
--                         removeFromParent(self);
--                     end)
-- 			    local joinLab = createLabel(funcBtn, game.getStrByKey("fb_joinIn"), getCenterPos(funcBtn), nil,21,true)
-- 			    joinLab:setColor(MColor.lable_yellow)
-- 			    if combat < currTeamInfo[3] then
--     			    joinLab:setColor(MColor.red)
--     		    end
--     		    if memNumLab ~= nil and currTeamInfo[4] >= 4 then
--     			    memNumLab:setColor(MColor.red);
--     		    end
--     	    end
--         end
--     end
    
--     return cell
-- end

-- ---------------------------------------------------------------------------------

-- return multiplayer;