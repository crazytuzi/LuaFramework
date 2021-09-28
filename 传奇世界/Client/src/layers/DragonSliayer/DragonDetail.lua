local DragonDetail = class("DragonDetail", function() return cc.Layer:create() end);

function DragonDetail:ctor(params)
    if params == nil then
        cclog("\n[DragonDetail:ctor] param nil!");
        return;
    end

    self.m_baseNode = createSprite( self, "res/common/bg/bg18.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) );
    local bgSize = self.m_baseNode:getContentSize();
    
    local nameLal = createLabel(self.m_baseNode, params.q_name, cc.p(850/2, 529-25),cc.p(0.5, 0.5), 28, true, nil, nil, MColor.lable_yellow, 12580)

    local centerSpr = createScale9Frame(
        self.m_baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

    -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
    local richText = require("src/RichText").new( centerSpr , cc.p( 792/2, 455*5/6) , cc.size( 700 , 150 ) , cc.p( 0.5 , 0.5 ) , 40 , 20 , MColor.white, nil, nil, false);
    richText:setAutoWidth();
    richText:addText(params.q_txt_inf);
	richText:format();

    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    createLabel(centerSpr, game.getStrByKey("dragonClearanceRequire") .. ": ", cc.p(45, 250),cc.p(0, 0), 20, true, nil, nil, MColor.gold);
    createLabel(centerSpr, params.q_txt_win, cc.p(165, 250),cc.p(0, 0), 20, true, nil, nil, MColor.gold);
    local tmpRewardStr = "";
    if params.q_id == DragonData.m_dailyCarbon then
        if params.q_er_show_id then
            tmpRewardStr = game.getStrByKey("dragonDailyRewardTips") .. ": ";
        end
    else
        if params.q_fr_show_id then
            tmpRewardStr = game.getStrByKey("fb_firstPassAward") .. ": ";
        end
    end
    createLabel(centerSpr, tmpRewardStr, cc.p(45, 200),cc.p(0, 0), 20, true, nil, nil, MColor.gold);

    
    -- 奖励
    local awards = {}
    local DropOp = require("src/config/DropAwardOp")
    local tmpAwardId = 0;
    if params.q_id == DragonData.m_dailyCarbon then
        tmpAwardId = params.q_er_show_id;
    else
        tmpAwardId = params.q_fr_show_id;
    end
    local awardsConfig = DropOp:dropItem_ex(tmpAwardId);
    if awardsConfig and tablenums(awardsConfig) >0 then
        table.sort( awardsConfig , function(a, b)
            if a == nil or a.px == nil or b == nil or b.px == nil then
                return false;
            else
                return a.px > b.px;
            end
        end)
    end
    for i=1, #awardsConfig do
        awards[i] =  { 
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
        local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
        setNodeAttr( groupAwards , cc.p( 792/2, 100 ) , cc.p( 0.5 , 0 ) )
        centerSpr:addChild(groupAwards);
    end

    if params.q_id ~= DragonData.m_dailyCarbon and DragonData:IsClearnce(params.q_id) and params.q_fr_show_id then
        --function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
        createSprite(centerSpr, "res/component/flag/18.png", cc.p(70, 180), cc.p(0, 0));
    end

    local buttomSpr = createSprite(centerSpr, "res/layers/DragonSliayer/5.png", cc.p(5, 6), cc.p(0, 0));

    local EnterCarbon = function()
        local commConst = require("src/config/CommDef");
        
        userInfo.lastFb = params.q_ins_id or 0;
		setLocalRecordByKey(2,"subFbType",""..userInfo.lastFb)
		userInfo.lastFbType = commConst.CARBON_DRAGON_SLIAYER
		setLocalRecordByKey(2,"lastFbType","6")

        DragonData.DRAGON_SLIAYER_WINDOW = true;

        DragonData:SendEnterSingleInstance(params.q_id);
        
        addNetLoading(COPY_CS_ENTER_SINGLEINSTANCE, FRAME_SC_ENTITY_ENTER);
    end
    
	local challengeBtn = createMenuItem(buttomSpr, "res/component/button/2.png", cc.p(buttomSpr:getContentSize().width/2, 40), function()
        -- 是否有队伍
        if G_TEAM_INFO and G_TEAM_INFO.has_team == true then
            -- function MessageBoxYesNo(title,text,yesCallback,noCallback,yesText,noText)
            local yesCallbackFun = function()
                -- 先退出队伍
                g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_LEAVE_TEAM, "TeamLeaveTeamProtocol", {})
                EnterCarbon();
            end
            MessageBoxYesNo(nil, game.getStrByKey("dragonEnterConfirm"), yesCallbackFun, nil, game.getStrByKey("sure"),game.getStrByKey("cancel"));
        else
            EnterCarbon();
        end
	end)
	createLabel(challengeBtn, game.getStrByKey("fb_challege"), getCenterPos(challengeBtn), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow);

    -- 关闭按钮
    local closeBtn = createMenuItem( self.m_baseNode, "res/component/button/X.png", cc.p(bgSize.width-40, bgSize.height-28), function()
        DragonData:RegisterCallback("DragonDetail", nil);
        removeFromParent(self);
    end)

    ---------------------------------------------------------------------------------

    SwallowTouches(self);
    
    DragonData:RegisterCallback("DragonDetail", function(para)
        if para == 0 then
            DragonData:RegisterCallback("DragonDetail", nil);
            removeFromParent(self);
        end
    end);

    ---------------------------------------------------------------------------------

    self:registerScriptHandler(function(event)
		if event == "enter" then
		elseif event == "exit" then
		    DragonData:RegisterCallback("DragonDetail", nil);
		end
	end)

    ---------------------------------------------------------------------------------

    local commConst = require("src/config/CommDef");
    getRunScene():addChild(self, commConst.ZVALUE_UI);
end

return DragonDetail;