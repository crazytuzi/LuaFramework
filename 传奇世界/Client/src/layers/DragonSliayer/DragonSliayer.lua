-- 屠龙传说
local DragonSliayer = class("DragonSliayer", function() return cc.Node:create() end);


function DragonSliayer:ctor()
    -- 初始化
    self:InitCfgByPage();
    self.m_path = "res/layers/DragonSliayer/";

    -- 控件初始化
    self.m_bg = nil;
    self.m_leftBtn = nil;
    self.m_rightBtn = nil;
    self.m_uiRichText = nil;
    -- 阶段展示
    self.m_dropNode = nil;

    self.m_pointLineTable = nil;
    self.m_btnTable = nil;

    ---------------------------------------------------------------------------------
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), g_scrSize.width, g_scrSize.height);
    self:addChild(layerColor);

    print("display.height=" .. display.height);

    -- ios 10 不支持超过2048宽度的图片，分成3张
    self.m_picNode = cc.Node:create();
    self:addChild(self.m_picNode);
    local scrollBgSpr1 = createSprite( self.m_picNode, self.m_path .. "scrollBg1.jpg" , cc.p(0, display.height/2), cc.p(0, 0.5))
    local scrollBgSpr2 = createSprite( self.m_picNode, self.m_path .. "scrollBg2.jpg" , cc.p(2048, display.height/2), cc.p(0, 0.5))
    local scrollBgSpr3 = createSprite( self.m_picNode, self.m_path .. "scrollBg3.jpg" , cc.p(2048*2, display.height/2), cc.p(0, 0.5))
    --self.m_picNode = createSprite( self , self.m_path .. "scrollBg.jpg" , cc.p(0, display.height/2), cc.p(0, 0.5))

    self.m_centerBg = cc.Node:create();
    self:addChild(self.m_centerBg);

    local upSpr = createSprite(self.m_centerBg, self.m_path .. "01.png", cc.p(display.width/2, display.height-82), cc.p(0.5, 0));
    local downSpr = createSprite(self.m_centerBg, self.m_path .. "02.png", cc.p(display.width/2, 0), cc.p(0.5, 0));

    ------------------------------------------------------------------------------------------------------------------------
    local closeFunc = function() 
        DragonData:RegisterCallback("DragonSliayer", nil);

		local cb = function() 
			TextureCache:removeUnusedTextures()
		end
		removeFromParent(self, cb);
	end

    local close_posx = 100;
	local close_item = createTouchItem(self, self.m_path.."2.png", cc.p(close_posx, display.height-52), closeFunc, nil)
	close_item:setLocalZOrder(500)

    SwallowTouches(self)

    self.m_leftBtn = createTouchItem(self, "res/group/arrows/17.png", cc.p(100, display.height/2), function()
            self.m_index = self.m_index-1;
            self:UpdateMainUI(false, false);
            self:ResetBtnStatus();
            self:ResetBgPos();
            self:RefreshDropShow();
        end);
    self.m_leftBtn:setFlippedX(true);
	self.m_leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(100-5, display.height/2)), cc.MoveTo:create(0.3, cc.p(100, display.height/2)))))

	self.m_rightBtn = createTouchItem(self, "res/group/arrows/17.png", cc.p(display.width-100, display.height/2), function()
            self.m_index = self.m_index+1;
            self:UpdateMainUI(false, true);
            self:ResetBtnStatus();
            self:ResetBgPos();
            self:RefreshDropShow();
        end)
	self.m_rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(display.width-100+5, display.height/2)), cc.MoveTo:create(0.3, cc.p(display.width-100, display.height/2)))))

    ---------------------------------------------------------------------------------
    self.m_todayChallengeBtn = createMenuItem(self.m_centerBg, "res/component/button/2.png", cc.p(950, 37), function()
        if DragonData.m_dailyCarbon > 0 then
            self:OpenDailyRandomCarbon();
        else
            -- 还未生成每日随机
            DragonData:SendRandomDailySingleInst();
        end
    end);
    self.m_todayChallengeLal = createLabel( self.m_todayChallengeBtn , game.getStrByKey("invade_day") .. game.getStrByKey("fb_challege") , getCenterPos( self.m_todayChallengeBtn ) , cc.p( 0.5 , 0.5 ) , 22 , true , nil , nil , MColor.lable_yellow);
    ---------------------------------------------------------------------------------
    
    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    self.m_dropShowLal = createLabel(self, game.getStrByKey("dragonShowTips"), cc.p(display.width/2, display.height - 105), cc.p(0.5, 0), 20, true, nil, nil, MColor.white);
    self.m_dropShowLal:enableOutline(cc.c4b(0,0,0,255),1);
    ---------------------------------------------------------------------------------

    local helpBtn = __createHelp{parent=self, str=require("src/config/PromptOp"):content(73), pos=cc.p(display.width-60, display.height-35), anch=cc.p(0, 0)};

    ------------------------------------------------------------------------------------------------------------------------

    -- 副本详细界面
    self.m_carbonNode = cc.Node:create();
    self.m_centerBg:addChild(self.m_carbonNode);


    

    ---------------------------------------------------------------------------------

    -- @param: 0-显示q_info 1-数据刷新
    DragonData:RegisterCallback("DragonSliayer", function(param)
        if param ~= nil then
            if param == 0 then
                self:UpdateMainUI(true);
                self:UpdateUiTips();
                self:SetTodayChallengeBtnShow();
            elseif param == 1 then
                self:OpenDailyRandomCarbon();
            end
        end
    end);

    ---------------------------------------------------------------------------------
    self:InitBgPos();

    self:UpdateMainUI(true);
    self:UpdateUiTips();
    self:SetTodayChallengeBtnShow();
    self:ResetBtnStatus();
    self:RefreshDropShow();

    ---------------------------------------------------------------------------------

    self:registerScriptHandler(function(event)
		if event == "enter" then
			-- 与服务器通信
            DragonData:SendSingleInstanceData();
		elseif event == "exit" then
		    DragonData:RegisterCallback("DragonSliayer", nil);
		end
	end)

    ---------------------------------------------------------------------------------

    local commConst = require("src/config/CommDef");
    getRunScene():addChild(self, commConst.ZVALUE_UI);
    
    ---------------------------------------------------------------------------------
end

function DragonSliayer:InitCfgByPage()
    -- 阶段展示掉落
    self.m_stateShowDrops = {10, 11, 12, 13, 14, 15, 16};

    self.m_dragonCfg = getConfigItemByKey("instanceInfolist");

    self.m_index = DragonData.m_curIdx;   -- 选中项
    -- 如果没有获取到网络数据，默认第一页
    if self.m_index == nil or self.m_index == 0 then
        self.m_index = 1;
    end

    --------------------------------------------------------------------------------
    -- 获取页显示信息
    if DragonData.m_pageCfg == nil then
        DragonData:InitPageInfo();
    end
    self.m_pageCfg = DragonData.m_pageCfg;

    self.m_maxSize = #(self.m_pageCfg);

    -- 读取点连线
    self.m_pointCfg = {};
    local tmpTable = require("src/config/instancePoint");
    for i=1, #tmpTable do
        local tmpLal = tmpTable[i].q_label;
        if self.m_pointCfg[tmpLal] == nil then
            self.m_pointCfg[tmpLal] = {};
        end

        table.insert(self.m_pointCfg[tmpLal], tmpTable[i]);
    end
    
end

function DragonSliayer:UpdateUiTips()
    if self.m_uiRichText then
        self.m_uiRichText:removeFromParent();
        self.m_uiRichText = nil;
    end
    
    --------------------------------------------------------------------------------------------------------------------------------------------------------------
    if DragonData:IsTodayChallengeOpen() then
        -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
        self.m_uiRichText = require("src/RichText").new( self.m_centerBg , cc.p(200, 30) , cc.size( 800 , 0 ) , cc.p( 0 , 0 ) , 26 , 20 , MColor.orange_shallow );
        self.m_uiRichText:addText(game.getStrByKey("dragonUITips2"));
        self.m_uiRichText:setAutoWidth();
	    self.m_uiRichText:format();
    else
        local function getCarbonStr(id)
            local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", id);
            if carbonCfg then
                return  carbonCfg.q_name;
            end

            return "";
        end

        --------------------------------------------------------------------------------------------------------------------------------------------------------------
        -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
        self.m_uiRichText = require("src/RichText").new( self.m_centerBg , cc.p( 100, 30 ) , cc.size( 800 , 0 ) , cc.p( 0 , 0 ) , 26 , 20 , MColor.orange_shallow );

        local uiTipsStr = game.getStrByKey("dragonUITips1");
        self.m_uiRichText:addText(uiTipsStr);

        --------------------------------------------------------------------------------------------------------------------------------------------------------------
        uiTipsStr = getCarbonStr(DragonData.BLEEDING_ORE_ONE);
        if DragonData:IsClearnce(DragonData.BLEEDING_ORE_ONE) then
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.green, false, true, true, function()
                self:JumpToOneCarbon(DragonData.BLEEDING_ORE_ONE);
            end, MColor.green);
        else
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.orange_shallow, false, true, true, function()
                self:JumpToOneCarbon(DragonData.BLEEDING_ORE_ONE);
            end, MColor.orange_shallow);
        end
        self.m_uiRichText:addText(game.getStrByKey("comma"));

        --------------------------------------------------------------------------------------------------------------------------------------------------------------
        uiTipsStr = getCarbonStr(DragonData.PREPARE_FOR_WAR_ONE);
        if DragonData:IsClearnce(DragonData.PREPARE_FOR_WAR_ONE) then
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.green, false, true, true, function()
                self:JumpToOneCarbon(DragonData.PREPARE_FOR_WAR_ONE);
            end, MColor.green);
        else
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.orange_shallow, false, true, true, function()
                self:JumpToOneCarbon(DragonData.PREPARE_FOR_WAR_ONE);
            end, MColor.orange_shallow);
        end
        self.m_uiRichText:addText(game.getStrByKey("comma"));
        
        --------------------------------------------------------------------------------------------------------------------------------------------------------------
        uiTipsStr = getCarbonStr(DragonData.GUARD_PRINCESS_ONE);
        if DragonData:IsClearnce(DragonData.GUARD_PRINCESS_ONE) then
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.green, false, true, true, function()
                self:JumpToOneCarbon(DragonData.GUARD_PRINCESS_ONE);
            end, MColor.green);
        else
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.orange_shallow, false, true, true, function()
                self:JumpToOneCarbon(DragonData.GUARD_PRINCESS_ONE);
            end, MColor.orange_shallow);
        end
        self.m_uiRichText:addText(game.getStrByKey("comma"));
        
        --------------------------------------------------------------------------------------------------------------------------------------------------------------
        uiTipsStr = getCarbonStr(DragonData.FERRY_SUPPLIES_ONE);
        if DragonData:IsClearnce(DragonData.FERRY_SUPPLIES_ONE) then
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.green, false, true, true, function()
                self:JumpToOneCarbon(DragonData.FERRY_SUPPLIES_ONE);
            end, MColor.green);
        else
            self.m_uiRichText:addTextItem(uiTipsStr, MColor.orange_shallow, false, true, true, function()
                self:JumpToOneCarbon(DragonData.FERRY_SUPPLIES_ONE);
            end, MColor.orange_shallow);
        end

        self.m_uiRichText:setAutoWidth();
	    self.m_uiRichText:format();
    end
    
end

function DragonSliayer:JumpToOneCarbon(carbonId)
    local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", carbonId);
    if carbonCfg then
        -- 获取页
        local tmpLabel = carbonCfg.q_label;
        if tmpLabel ~= nil then
            local pageStr = nil;
            if type(tmpLabel) == "string" then
                pageStr = stringsplit(tmpLabel, ",");
            else
                pageStr = {};
                pageStr[1] = tostring(tmpLabel);
            end
            
            local delayTime = 0.5;
            local targetPage = tonumber(pageStr[1]);
            if self.m_index ~= targetPage then
                -- 跳转到该页
                self.m_index = targetPage;
                self:UpdateMainUI(true);
                self:ResetBtnStatus();
                self:ResetBgPos();
                self:RefreshDropShow();
            else
                delayTime = 0;
            end

            -- 延时 0.3s 后突出显示该关卡
            self.m_carbonNode:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(
                function()
                    local menuItem = self.m_carbonNode:getChildByTag(carbonId);
                    if menuItem then
                        menuItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.5 ), cc.ScaleTo:create(0.1, 0.8 )));
                    end
                end
            )));
        end
    end
end

function DragonSliayer:InitBgPos()
    local picWidth = 2048 + 2048 + 398;
    local deltaWdith = (picWidth - g_scrSize.width)/(self.m_maxSize-1);
    local tmpX = (-1) * (self.m_index-1) * deltaWdith;

    self.m_picNode:setPosition(cc.p(tmpX, 0));
end

function DragonSliayer:ResetBgPos()
    local picWidth = 2048 + 2048 + 398;
    local deltaWdith = (picWidth - g_scrSize.width)/(self.m_maxSize-1);

    local endX = (-1) * (self.m_index-1) * deltaWdith;
    self.m_picNode:runAction(cc.MoveTo:create(0.3, cc.p(endX, 0)));
end

function DragonSliayer:FadeUILineAndBtn(straightway, dir)
    if straightway then
        self.m_btnTable = nil;
        self.m_pointLineTable = nil;
        self.m_carbonNode:removeAllChildren();
    else
        if self.m_pointLineTable then
            for i=1, #(self.m_pointLineTable) do
                local pointAddress = self.m_pointLineTable[i];
                if pointAddress and tolua.cast(pointAddress, "cc.Sprite") then
                    -- anchorpoint 0.5, 0.5
                    local tmpSize = pointAddress:getContentSize();
                    local tmpPosition = cc.p(pointAddress:getPositionX(), pointAddress:getPositionY());
                    -- dir: true - 右箭头, 往左消失, 坐标减小
                    local newPos = cc.p(0, 0);
                    if dir then
                        newPos = cc.p(0 - tmpSize.width/2, tmpPosition.y);
                    else
                        newPos = cc.p(display.width + tmpSize.width/2, tmpPosition.y);
                    end
                    
                    pointAddress:runAction(cc.Sequence:create(
                        cc.Spawn:create(
                            cc.MoveTo:create(0.3,newPos),
                            cc.FadeTo:create(0.1, 0)
                            ),
                        
                        cc.DelayTime:create(0.3),
                        cc.CallFunc:create(
                            function()
                                if pointAddress and tolua.cast(pointAddress, "cc.Sprite") then 
                                    pointAddress:removeFromParent();
                                end
                            end
                            )
                    ));
                end
            end

            self.m_pointLineTable = nil;
        end

        if self.m_btnTable then
            for i=1, #(self.m_btnTable) do
                local btnAddress = self.m_btnTable[i];
                if btnAddress and tolua.cast(btnAddress, "TouchSprite") then
                    local btnTag = btnAddress:getTag();

                    -- anchorpoint 0.5, 0.5
                    local tmpSize = btnAddress:getContentSize();
                    local tmpPosition = cc.p(btnAddress:getPositionX(), btnAddress:getPositionY());
                    -- dir: true - 左移, 往右消失, 坐标减小
                    local newPos = cc.p(0, 0);
                    if dir then
                        newPos = cc.p(0 - tmpSize.width/2, tmpPosition.y);
                    else
                        newPos = cc.p(display.width + tmpSize.width/2, tmpPosition.y);
                    end

                    if self:IsBossCarbon(btnTag, dir) then
                        -- BOSS 关卡需要移到所在的位置
                        newPos.x = self:ReCalculatePosX(btnTag, dir);
                        btnAddress:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.MoveTo:create(0.299,newPos)
                                ),

                            cc.DelayTime:create(0.299),
                            cc.CallFunc:create(
                                function()
                                    if btnAddress and tolua.cast(btnAddress, "TouchSprite") then 
                                        btnAddress:removeFromParent();
                                    end
                                end
                                )
                        ));
                    else
                        btnAddress:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.MoveTo:create(0.3,newPos),
                                cc.FadeTo:create(0.3, 0)
                                ),

                            cc.DelayTime:create(0.3),
                            cc.CallFunc:create(
                                function()
                                    if btnAddress and tolua.cast(btnAddress, "TouchSprite") then 
                                        btnAddress:removeFromParent();
                                    end
                                end
                                )
                        ));
                    end
                    
                end
            end

            self.m_btnTable = nil;
        end
    end
end

-- dir: true - 右箭头, 往左消失, 坐标减小
-- 页签其实已经移到下一页了
function DragonSliayer:IsBossCarbon(id, dir)
    if (id >= DragonData.DRAGON_SLIAYER_BEGIN and id <= DragonData.DRAGON_SLIAYER_END) then
        if dir then
            if (self.m_index-1) == (id - DragonData.DRAGON_SLIAYER_BEGIN + 1) then
                return true;
            end
        else
            if self.m_index == (id - DragonData.DRAGON_SLIAYER_BEGIN + 1) then
                return true;
            end
        end
    end

    return false;
end

-- 每一页 最多有两个连接关卡
function DragonSliayer:ReCalculatePosX(id, dir)
        if dir then
            local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", id);
            if carbonCfg then
                -- 获取页位置 [第二个的位置]
                local tmpLabelPos = carbonCfg.q_xy;
                if tmpLabelPos ~= nil then
                    local posStr = stringsplit(tmpLabelPos, ";");
                    if posStr and #posStr > 1 then
                        local tmpPosStr = posStr[2];
                        local commaPos = string.find(tmpPosStr, ",", 1, true);
                        local tmpX = string.sub(tmpPosStr, 1, commaPos - 1)
                        return tonumber(tmpX);
                    end
                end
            end
        else
            local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", id);
            if carbonCfg then
                -- 获取页位置 [第一个的位置]
                local tmpLabelPos = carbonCfg.q_xy;
                if tmpLabelPos ~= nil then
                    local posStr = stringsplit(tmpLabelPos, ";");
                    if posStr and #posStr > 0 then
                        local tmpPosStr = posStr[1];
                        local commaPos = string.find(tmpPosStr, ",", 1, true);
                        local tmpX = string.sub(tmpPosStr, 1, commaPos - 1)
                        return tonumber(tmpX);
                    end
                end
            end
        end

    return 0;
end

-- dir: true - 坐标减小; false - 坐标增大
function DragonSliayer:UpdateMainUI(straightway, dir)
    self:FadeUILineAndBtn(straightway, dir);

    -- 点连线，根据配置表
    local pointData = self.m_pointCfg[self.m_index];
    if pointData ~= nil then
        for i=1, #pointData do
            local tmpArrowPath = "";
            if DragonData:IsClearnce(pointData[i].q_right) and DragonSliayer:IsCarbonUnlock(pointData[i].q_left) then
                tmpArrowPath = "res/layers/DragonSliayer/14.png";
            else
                tmpArrowPath = "res/layers/DragonSliayer/13.png";
            end
            local onePoint = GetUIHelper():WrapImg(cc.Sprite:create(tmpArrowPath), cc.size(pointData[i].q_width, pointData[i].q_height));
            onePoint:setPosition(cc.p(pointData[i].q_x, pointData[i].q_y));
            onePoint:setRotation(pointData[i].q_rotate);
            if self.m_pointLineTable == nil then
                self.m_pointLineTable = {};
            end
            table.insert(self.m_pointLineTable, onePoint);
            onePoint:setOpacity(0);
            onePoint:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeTo:create(0.3, 255)));
            self.m_carbonNode:addChild(onePoint);
        end
    end

    -- 勾画关卡，根据配置表
    local pageData = self.m_pageCfg[self.m_index];
    if pageData ~= nil then
        for i=1, #(pageData) do
            local tmpNameColor = MColor.white;

            -- 已经解锁的关卡
            if self:IsCarbonUnlock(pageData[i].q_id) then
                
                -- 是否已经通关
                if DragonData:IsClearnce(pageData[i].q_id) then
                    -- 打完一次是否消失
                    if pageData[i].q_hide == 1 then
                        print("no need to show: " .. pageData[i].q_id);
                    else
                        tmpNameColor = cc.c3b(255, 241, 118);
                    
                        local menuItem = createTouchItem(self.m_carbonNode, self.m_path .. "10.png", cc.p(pageData[i].q_page_x, pageData[i].q_page_y), function()
                            self:EnterDetailScene(pageData[i]);
                        end);
                        if self.m_btnTable == nil then
                            self.m_btnTable = {};
                        end
                        table.insert(self.m_btnTable, menuItem);
                        menuItem:setCascadeOpacityEnabled(true);
                        menuItem:setTag(pageData[i].q_id);

                        -- 非翻页，或者翻页并且是boss移动关卡
                        menuItem:setOpacity(0);
                        if straightway or not self:IsBossCarbon(pageData[i].q_id, dir) then
                            menuItem:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeTo:create(0.2, 255)));
                        else
                            menuItem:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(
                                function()
                                    if menuItem and tolua.cast(menuItem, "TouchSprite") then 
                                        menuItem:setOpacity(255);
                                    end
                                end
                                )
                            ))
                        end
                        menuItem:setScale(0.8);
                        createLabel(menuItem, pageData[i].q_name, cc.p(menuItem:getContentSize().width/2, 30), cc.p(0.5, 0), 18, false, nil, nil, tmpNameColor);
                        createSprite(menuItem, self.m_path .. "11.png", getCenterPos(menuItem, nil, 20), cc.p(0.5, 0.5));
                        createSprite(menuItem, "res/component/flag/4.png", getCenterPos(menuItem), cc.p(0.5, 0.5));
                    end
                else
                    tmpNameColor = cc.c3b(188, 142, 108);

                    local tmpBtnPath = "";
                    if pageData[i].q_hide == 1 then
                        tmpBtnPath = self.m_path .. "12.png";
                    else
                        tmpBtnPath = self.m_path .. "10.png";
                    end

                    local menuItem = createTouchItem(self.m_carbonNode, tmpBtnPath, cc.p(pageData[i].q_page_x, pageData[i].q_page_y), function()
                        self:EnterDetailScene(pageData[i]);
                    end);
                    if self.m_btnTable == nil then
                        self.m_btnTable = {};
                    end
                    table.insert(self.m_btnTable, menuItem);
                    menuItem:setCascadeOpacityEnabled(true);
                    menuItem:setTag(pageData[i].q_id);

                    -- 非翻页，或者翻页并且是boss移动关卡
                    menuItem:setOpacity(0);
                    if straightway or not self:IsBossCarbon(pageData[i].q_id, dir) then
                        menuItem:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeTo:create(0.2, 255)));
                    else
                        menuItem:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(
                            function()
                                if menuItem and tolua.cast(menuItem, "TouchSprite") then 
                                    menuItem:setOpacity(255);
                                end
                            end
                            )
                        ))
                    end
                    menuItem:setScale(0.8);
                    createLabel(menuItem, pageData[i].q_name, cc.p(menuItem:getContentSize().width/2, 30), cc.p(0.5, 0), 18, false, nil, nil, tmpNameColor);
                end
            else
                -- 隐藏关卡 条件未满足 不显示
                if pageData[i].q_hide == 1 then
                    print("no need to show: " .. pageData[i].q_id);
                else
                    tmpNameColor = cc.c3b(162, 162, 162);
                    --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
                    -- function createTouchItem(parent, pszFileName, pos, callback,action,downFunc,noDefaultVoice)
                    local unlockMenuItem = createTouchItem(self.m_carbonNode, self.m_path .. "9.png", cc.p(pageData[i].q_page_x, pageData[i].q_page_y), function()
                        self:EnterDetailScene(pageData[i]);
                    end);
                    if self.m_btnTable == nil then
                        self.m_btnTable = {};
                    end
                    table.insert(self.m_btnTable, unlockMenuItem);
                    unlockMenuItem:setCascadeOpacityEnabled(true);
                    unlockMenuItem:setTag(pageData[i].q_id);

                    -- 非翻页，或者翻页并且是boss移动关卡
                    unlockMenuItem:setOpacity(0);
                    if straightway or not self:IsBossCarbon(pageData[i].q_id, dir) then
                        unlockMenuItem:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeTo:create(0.2, 255)));
                    else
                        unlockMenuItem:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(
                            function()
                                if unlockMenuItem and tolua.cast(unlockMenuItem, "TouchSprite") then 
                                    unlockMenuItem:setOpacity(255);
                                end
                            end
                            )
                        ))
                    end
                    unlockMenuItem:setScale(0.8);
                    --function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
                    createLabel(unlockMenuItem, pageData[i].q_name, cc.p(unlockMenuItem:getContentSize().width/2, 30), cc.p(0.5, 0), 18, false, nil, nil, tmpNameColor);
                end
            end
        end
    end
end

function DragonSliayer:RefreshDropShow()
    if self.m_dropNode then
        self.m_dropNode:removeFromParent();
        self.m_dropNode = nil;
    end

    -- 奖励
    local awards = {}
    local DropOp = require("src/config/DropAwardOp")
    local awardsConfig = DropOp:dropItem_ex(self.m_stateShowDrops[self.m_index]);
    if awardsConfig and tablenums(awardsConfig) >0 then
        table.sort( awardsConfig , function(a, b)
            if a == nil or a.px == nil or b == nil or b.px == nil then
                return false;
            else
                return a.px < b.px;
            end
        end)
    end
    for i=1, #awardsConfig do
        awards[i] =
        { 
            id = awardsConfig[i]["q_item"] ,       -- 奖励ID
            num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
            streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
            quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
            upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
            time = awardsConfig[i]["q_time"] ,     -- 限时时间
            showBind = true,
            isBind = tonumber(awardsConfig[i]["bdlx"] or 0) == 1,                          
        }
    end

    if tablenums( awards ) > 0 then
        --function __createAwardGroup( awards , isShowName , Interval , offX , isSwallow )
        self.m_dropNode =  __createAwardGroup( awards , nil , 85 , nil , false)
        setNodeAttr( self.m_dropNode, cc.p(display.width/2, display.height-105), cc.p(0.5, 0 ));
        self:addChild(self.m_dropNode);
    end
end

-- 挑战每日随机副本
function DragonSliayer:OpenDailyRandomCarbon()
    local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", DragonData.m_dailyCarbon);
    if carbonCfg then
        local dragonDetail = require("src/layers/DragonSliayer/DragonDetail");
        if dragonDetail ~= nil then
            dragonDetail.new(carbonCfg);
        end
    end
end

-- 控制今日挑战按钮显示
function DragonSliayer:SetTodayChallengeBtnShow()
    -- 是否解锁了今日挑战
    if DragonData:IsTodayChallengeOpen() then
        if DragonData.m_dailyPassed then
            self.m_todayChallengeBtn:setEnabled(false);
            self.m_todayChallengeLal:setString(game.getStrByKey("invade_day") .. game.getStrByKey("achievement_finish"));
        else
            self.m_todayChallengeBtn:setEnabled(true);
            self.m_todayChallengeLal:setString(game.getStrByKey("invade_day") .. game.getStrByKey("fb_challege"));
        end
    else
         self.m_todayChallengeLal:setString(game.getStrByKey("invade_day") .. game.getStrByKey("fb_challege"));
        self.m_todayChallengeBtn:setEnabled(false);
    end
end

--
function DragonSliayer:EnterDetailScene(pageData)
    if pageData ~= nil then
        if self:IsCarbonUnlock(pageData.q_id) then
            DragonData.m_curIdx = self.m_index;
            -- 已经通关完成
            if pageData.q_plot == nil or DragonData:IsClearnce(pageData.q_id) then
                local dragonDetail = require("src/layers/DragonSliayer/DragonDetail");
                if dragonDetail ~= nil then
                    dragonDetail.new(pageData);
                else
                    TIPS{str = game.getStrByKey("login_dataError"), type=1, flag=1};
                    error("[DragonSliayer:EnterDetailScene] dragonDetail is null!", 2);
                end
            else
                if G_MAINSCENE ~= nil then
                    G_MAINSCENE:EnterDragonStoryMode(pageData);
                else
                    TIPS{str = game.getStrByKey("login_dataError"), type=1, flag=1};
                    error("[DragonSliayer:EnterDetailScene] G_MAINSCENE is null!", 2);
                end
            end
        else
            -------------------------------------------------------------------------------------------
            if pageData.q_need then
                local conditions = nil
                if type(pageData.q_need) == "string" then
                    conditions = stringsplit(pageData.q_need, ",");
                    if conditions == nil then
                        TIPS{str = game.getStrByKey("login_dataError"), type=1, flag=1};
                        error("[DragonSliayer:EnterDetailScene] conditions is null!", 2);
                    end
                else
                    conditions = {};
                    conditions[1] = tostring(pageData.q_need);
                end

                local count = 0;
                for i=1, #conditions do
                    local tmpCarbonId = tonumber(conditions[i]);
                    if DragonData:IsClearnce(tmpCarbonId) then
                        count = count + 1;
                    end
                end

                if count < #(conditions) then
                    TIPS { str = getConfigItemByKeys("clientmsg",{"sth","mid"},{ 13000 , -70 }).msg };
                    return;
                end
            end

            -------------------------------------------------------------------------------------------
            if pageData.q_need2 then
                if not self:IsMainTaskReach(pageData.q_need2) then
                    local taskDb = getConfigItemByKey("TaskDB");
			        for i=1,#taskDb do
			            if taskDb[i].q_taskid == tonumber(pageData.q_need2) then
                            TIPS( {str = string.format(getConfigItemByKeys("clientmsg",{"sth","mid"},{ 13000 , -73 }).msg, taskDb[i].q_name)}  );
                            return;
			            end
			        end

                    TIPS{ str="dragonUnlockTips1" };
                    return;
                end
            end

            -------------------------------------------------------------------------------------------
            local lv = MRoleStruct:getAttr(ROLE_LEVEL);
            if lv == nil then
                lv = 0;
                TIPS{str = game.getStrByKey("login_dataError"), type=1, flag=1};
                error("[DragonSliayer:EnterDetailScene] cann't get level!", 2);
            end
            if lv < pageData.q_lv then
                TIPS( {str = string.format(getConfigItemByKeys("clientmsg",{"sth","mid"},{ 30000 , -3 }).msg, pageData.q_lv)}  );
                return;
            end

            
            -- 实际已经解锁了，可能数据更新了，重新刷新下页面
            self:UpdateMainUI(true);
            self:UpdateUiTips();
            self:SetTodayChallengeBtnShow();
            error("[DragonSliayer:EnterDetailScene] actually unlock!", 2);
        end
    else
        TIPS{str = game.getStrByKey("login_dataError"), type=1, flag=1};
        error("[DragonSliayer:EnterDetailScene] pageData is null!", 2);
    end
end

function DragonSliayer:ResetBtnStatus()
    if self.m_index <= 1 then
        self.m_leftBtn:setVisible(false);
        self.m_rightBtn:setVisible(true);
    elseif self.m_index >= self.m_maxSize then
        self.m_leftBtn:setVisible(true);
        self.m_rightBtn:setVisible(false);
    else
        self.m_leftBtn:setVisible(true);
        self.m_rightBtn:setVisible(true);
	end
end

function DragonSliayer:IsMainTaskReach(cfgId)
    local taskId = nil;
	if DATA_Mission and DATA_Mission.getLastTaskData() then
		taskId = DATA_Mission.getLastTaskData().q_taskid
		if DATA_Mission.getLastTaskData().isBan then
			taskId = taskId - 1
		end
    else
        error("[DragonSliayer:IsMainTaskReach] main task is null!", 2);
	end

    if taskId and taskId >= tonumber(cfgId) then
		return true;
	end

    return false;
end

function DragonSliayer:IsCarbonUnlock(id)
    local lv = MRoleStruct:getAttr(ROLE_LEVEL);
    if lv == nil then
        lv = 0;
        error("[DragonSliayer:IsCarbonUnlock] cann't get level!", 2);
    end

    local carbonCfg = getConfigItemByKey("instanceInfolist", "q_id", id);
    if carbonCfg then
        if lv >= carbonCfg.q_lv then
            if carbonCfg.q_need == nil then
                -- 主线任务解锁
                if carbonCfg.q_need2 then
                    return self:IsMainTaskReach(carbonCfg.q_need2)
                else
                    return true;
                end
            else
                local conditions = nil
                if type(carbonCfg.q_need) == "string" then
                    conditions = stringsplit(carbonCfg.q_need, ",");
                    if conditions == nil then return true end;
                else
                    conditions = {};
                    conditions[1] = tostring(carbonCfg.q_need);
                end

                local count = 0;
                for i=1, #conditions do
                    local tmpCarbonId = tonumber(conditions[i]);
                    if DragonData:IsClearnce(tmpCarbonId) then
                        count = count + 1;
                    end
                end

                if count >= #(conditions) then
                    -- 主线任务解锁
                    if carbonCfg.q_need2 then
                        return self:IsMainTaskReach(carbonCfg.q_need2)
                    else
                        return true
                    end
                end
            end
        end
    else
        error("[DragonSliayer:IsCarbonUnlock] carbonCfg is null! id = [" .. (id or 0) .. "]", 2);
    end

    return false;
end

return DragonSliayer;