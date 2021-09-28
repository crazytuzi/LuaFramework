local VSEntrance = class("VSEntrance", function() return cc.Node:create() end)

function VSEntrance:ctor(params)
    local Mbaseboard = require "src/functional/baseboard"
    local root = Mbaseboard.new(
    {
	    src = "res/common/bg/bg18.png",
	    close = {
		    src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		    offset = { x = -8, y = 4 },
            handler = function(nod)
                removeFromParent(self);
            end
	    },
	    title = {
		    src = game.getStrByKey("p3v3_entrance_title"),
		    size = 25,
		    color = MColor.lable_yellow,
		    offset = { y = -25 },
	    }
    })
    root:setPosition(g_scrCenter);
    self:addChild(root);

    local cnterBgSpr = createSprite( root , "res/layers/rewardTask/rewardTaskReleaseBg.png" , cc.p( root:getContentSize().width/2 , 15 ) , cc.p( 0.5 , 0 ) )
    local centerBgSize = cnterBgSpr:getContentSize();

    local popoutSpr = createSprite( cnterBgSpr, "res/common/shadow/desc_shadow.png", cc.p( centerBgSize.width/2 , 0 ), cc.p( 0.5 , 0 ) );

    --function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    --createLabel(cnterBgSpr, string.format(game.getStrByKey("p3v3_entrance_season_title"), valueDigitToChinese(params.season)), cc.p(centerBgSize.width/2, 395), cc.p(0.5, 0), 24, true, nil, nil, cc.c3b(247, 206, 150));
    createLabel(cnterBgSpr, string.format(game.getStrByKey("p3v3_entrance_season_title"), params.seasonName), cc.p(centerBgSize.width/2, 395), cc.p(0.5, 0), 24, true, nil, nil, cc.c3b(247, 206, 150));

    createLabel(cnterBgSpr, game.getStrByKey("activity_time"), cc.p(150, 360), cc.p(0, 0), 22, true, nil, nil, cc.c3b(247, 206, 150));

    createLabel(cnterBgSpr, formatDateStr(params.startDate) .. "--" .. formatDateStr(params.endDate), cc.p(260, 360), cc.p(0, 0), 22, nil, nil, nil, cc.c3b(189, 142, 107));

    createLabel(cnterBgSpr, game.getStrByKey("activity_rule"), cc.p(150, 320), cc.p(0, 0), 22, true, nil, nil, cc.c3b(247, 206, 150));

    local width , height  = 490 , 120
    local function createRichTextNode()
        local tempNode = cc.Node:create()

        -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
        local ruleTxt = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width-20 , 0 ) , cc.p( 0 , 0 ) , 22 , 20 , cc.c3b(189, 142, 107) )
	    ruleTxt:addText( require("src/config/PromptOp"):content(63) , cc.c3b(189, 142, 107) , false )
	    ruleTxt:format()

        tempNode:setContentSize( cc.size( width , math.abs( ruleTxt:getContentSize().height ) + 10  ) )
        setNodeAttr( ruleTxt , cc.p( 10 , 0 ) , cc.p( 0 , 0  ) )

        return tempNode;
    end
    
    local scrollView1 = cc.ScrollView:create()	  
    scrollView1:setViewSize(cc.size( width + 20  , height ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
    scrollView1:setPosition( cc.p( 250 , 225  ) )
    scrollView1:setScale(1.0)
    scrollView1:ignoreAnchorPointForPosition(true)
    local richNode = createRichTextNode()
    scrollView1:setContainer( richNode )
    scrollView1:updateInset()
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    scrollView1:setContentOffset(cc.p(scrollView1:getContentOffset().x, scrollView1:getViewSize().height - scrollView1:getContentSize().height))
    cnterBgSpr:addChild(scrollView1)

    local richText_roundLeft = require("src/RichText").new(cnterBgSpr, cc.p(150, 180), cc.size(580, 0), cc.p(0, 0), 22, 22, cc.c3b(247, 206, 150))
    richText_roundLeft:setAutoWidth()
    richText_roundLeft:addText(
        "^c(lable_yellow)" .. game.getStrByKey("p3v3_entrance_tip_label_part_0") .. "  ^"
        .. params.battleCount
        .. "  " .. game.getStrByKey("p3v3_entrance_tip_label_part_1")
    )
    richText_roundLeft:format()
    
    ------------------------------------------------- 奖励 -------------------------------------------------
    local awards = {}
    local DropOp = require("src/config/DropAwardOp")
    local dropId = 1640
    local awardsConfig = DropOp:dropItem_ex(params.reward)
    if awardsConfig and tablenums(awardsConfig) > 0 then
        table.sort(awardsConfig, function(a, b)
            if a == nil or a.px == nil or b == nil or b.px == nil then
                return false
            else
                return a.px > b.px
            end
        end)
    end
    for i=1, #awardsConfig do
        awards[i] = {
            id = awardsConfig[i]["q_item"] ,       -- 奖励ID
            num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
            streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
            quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
            upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
            time = awardsConfig[i]["q_time"] ,     -- 限时时间
            showBind = true,
            isBind = tonumber(awardsConfig[i]["bdlx"] or 0) == 1
        }
    end
    if table.size(awards) > 0 then
        local groupAwards = __createAwardGroup(awards, nil, 85, nil, false)
        setNodeAttr(groupAwards, cc.p(centerBgSize.width/2, 60), cc.p( 0.5 , 0 ) )
        cnterBgSpr:addChild(groupAwards)
    end
    --------------------------------------------------------------------------------------------------
    require("src/component/button/MenuButton").new(
    {
	    parent = cnterBgSpr,
	    pos = cc.p(400, 40),
        src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	    label = {
		    src = game.getStrByKey("p3v3_entrance_btn_label"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
		    if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
		    g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_GETINGAME, "FightTeam3v3GetInGameProtocol", {})
	    end,
    })

    __createHelp({
        parent = cnterBgSpr, 
		str = require("src/config/PromptOp"):content(63),
		pos = cc.p(550, 405)
    })
    --战斗录像开关
    local recordStr=createLabel(cnterBgSpr, game.getStrByKey("sky_arena_record"),cc.p(275, 40) , cc.p(1, 0.5), 22, true, 10)
    local function changeSelect( )
        local isAutoRecorder=getLocalRecordByKey(3,"isAutoRecorder3v3")
        setLocalRecordByKey(3,"isAutoRecorder3v3",not isAutoRecorder)
        self.gou:setVisible(not isAutoRecorder)
    end
    local checkBox=createTouchItem(cnterBgSpr,"res/component/checkbox/1.png",cc.p(164,40),changeSelect)
    self.gou=createSprite(cnterBgSpr,"res/component/checkbox/1-1.png",cc.p(164,40))
    local isAutoRecorder=getLocalRecordByKey(3,"isAutoRecorder3v3")
    self.gou:setVisible(isSupportReplay())
    if not isAutoRecorder then
        setLocalRecordByKey(3,"isAutoRecorder3v3",false)
        self.gou:setVisible(false)
    end
    checkBox:setVisible(isSupportReplay())
    recordStr:setVisible(isSupportReplay())

    SwallowTouches(self)
end

return VSEntrance
