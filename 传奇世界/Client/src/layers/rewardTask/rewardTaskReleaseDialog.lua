local MColor = require "src/config/FontColor"
return { new = function(params)
    local Mbaseboard = require "src/functional/baseboard"
    local root = Mbaseboard.new(
    {
	    src = "res/common/bg/bg18.png",
	    close = {
		    src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		    offset = { x = -8, y = 4 },
	    },
	    title = {
		    src = game.getStrByKey("taskPublish") .. game.getStrByKey("task_tf"),
		    size = 25,
		    color = MColor.lable_yellow,
		    offset = { y = -25 },
	    }
    })
    local distance_between_type = 259
    local spr_bg = cc.Sprite:create("res/layers/rewardTask/rewardTaskReleaseBg.png")
    spr_bg:setAnchorPoint(cc.p(0, 0))
    spr_bg:setPosition(cc.p(17 + 16, 16))
    root:addChild(spr_bg)
     G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_REWARDTASK_CLOSE)
    local commConst = require("src/config/CommDef");
    local pack = MPackManager:getPack(MPackStruct.eBag);

    local padding_left, padding_top = 6, 8
    --[[
    卷轴等级	经验	声望	消耗
    至尊	2000000	15000	至尊悬赏卷轴
    高级	310000	3200	高级悬赏卷轴
	低级	124000	1280	1万金币
    ]]
    --至尊
    local spr_bg_zhi_zun = cc.Sprite:create("res/layers/rewardTask/extremeBg.png")
    spr_bg_zhi_zun:setAnchorPoint(cc.p(0, 1))
    spr_bg_zhi_zun:setPosition(cc.p(spr_bg:getPositionX() - padding_left + 13, spr_bg:getPositionY() + padding_top + 447))
    root:addChild(spr_bg_zhi_zun)
    createLabel(root, game.getStrByKey("taskExtremeBounty"), cc.p(spr_bg:getPositionX() + 90, spr_bg:getPositionY() + 392) , cc.p(0, 0) , 22 , true , nil , nil , MColor.yellow)
    --createLabel(root, game.getStrByKey("acquire") .. 200 .. game.getStrByKey("ten_thousand") .. game.getStrByKey("exp"), cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2, spr_bg:getPositionY() + 268) , cc.p(.5, 0) , 18, true , nil , nil , cc.c3b(247, 206, 150))--根据策划要求写死为固定值
    local icon = iconCell({parent = root, isTip = true, num = {value = 2000000}, iconID = 444444})--点击icon弹出了第3级tip
    icon:setScale(71.0 / 82)
    icon:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 - 40, spr_bg:getPositionY() + 268 + 60))
    local icon1 = iconCell({parent = root, isTip = true, num = {value = 15000}, iconID = 777777})--点击icon弹出了第3级tip
    icon1:setScale(71.0 / 82)
    icon1:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + 40, spr_bg:getPositionY() + 268 + 60))
    
    --createLabel(root, game.getStrByKey("consume") .. ":" .. game.getStrByKey("rewardTaskMaterialZhiZun"), cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2, spr_bg:getPositionY() + 206) , cc.p(.5, 0) , 20, true , nil , nil , cc.c3b(247, 206, 150))
    local publishBtn = createMenuItem(root, "res/component/button/2.png", cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2, spr_bg:getPositionY() + 136) , function()
        --在真正发送发布悬赏任务之前，需要首先发送这条消息(请求服务器返回角色已经发布的悬赏任务)给服务器，触发服务器对角色任务缓存的刷新，用于判断过期时间，若服务器缓存中不含有角色任务数据，服务器将不会执行发布任务流程
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(5)
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(0, 3)
    end)
    createLabel(publishBtn, game.getStrByKey("taskPublish") .. game.getStrByKey("task_tf"), getCenterPos(publishBtn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147))

    --高级
    local spr_bg_gao_ji = cc.Sprite:create("res/layers/rewardTask/seniorBg.png")
    spr_bg_gao_ji:setAnchorPoint(cc.p(0, 1))
    spr_bg_gao_ji:setPosition(cc.p(spr_bg:getPositionX() - padding_left + 13 + distance_between_type, spr_bg:getPositionY() + padding_top + 447))
    root:addChild(spr_bg_gao_ji)
    createLabel(root, game.getStrByKey("taskSeniorBounty"), cc.p(spr_bg:getPositionX() + 90 + distance_between_type, spr_bg:getPositionY() + 392) , cc.p(0, 0) , 22 , true , nil , nil , MColor.yellow)
    --createLabel(root, game.getStrByKey("acquire") .. 31 .. game.getStrByKey("ten_thousand") .. game.getStrByKey("exp"), cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type, spr_bg:getPositionY() + 268) , cc.p(.5, 0) , 18, true , nil , nil , cc.c3b(247, 206, 150))
    local icon = iconCell({parent = root, isTip = true, num = {value = 310000}, iconID = 444444})
    icon:setScale(71.0 / 82)
    icon:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 - 40 + distance_between_type, spr_bg:getPositionY() + 268 + 60))
    local icon2 = iconCell({parent = root, isTip = true, num = {value = 3200}, iconID = 777777})--点击icon弹出了第3级tip
    icon2:setScale(71.0 / 82)
    icon2:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + 40 + distance_between_type, spr_bg:getPositionY() + 268 + 60))
    
    --createLabel(root, game.getStrByKey("consume") .. ":" .. game.getStrByKey("rewardTaskMaterialGaoJi"), cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type, spr_bg:getPositionY() + 206) , cc.p(.5, 0) , 20, true , nil , nil , cc.c3b(247, 206, 150))
    local publishBtn = createMenuItem(root, "res/component/button/2.png", cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type, spr_bg:getPositionY() + 136) , function()
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(5)
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(0, 2)
    end)
    createLabel(publishBtn, game.getStrByKey("taskPublish") .. game.getStrByKey("task_tf"), getCenterPos(publishBtn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147))
    G_TUTO_NODE:setTouchNode(publishBtn,TOUCH_REWARDTASK_RECEIVE)
    --普通
    local spr_bg_pu_tong = cc.Sprite:create("res/layers/rewardTask/juniorBg.png")
    spr_bg_pu_tong:setAnchorPoint(cc.p(0, 1))
    spr_bg_pu_tong:setPosition(cc.p(spr_bg:getPositionX() - padding_left + 13 + distance_between_type * 2, spr_bg:getPositionY() + padding_top + 447))
    root:addChild(spr_bg_pu_tong)
    createLabel(root, game.getStrByKey("taskJuinorBounty"), cc.p(spr_bg:getPositionX() + 90 + distance_between_type * 2, spr_bg:getPositionY() + 392) , cc.p(0, 0) , 22 , true , nil , nil , MColor.yellow)
    --createLabel(root, game.getStrByKey("acquire") .. 12.4 .. game.getStrByKey("ten_thousand") .. game.getStrByKey("exp"), cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type * 2, spr_bg:getPositionY() + 268) , cc.p(.5, 0) , 18, true , nil , nil , cc.c3b(247, 206, 150))
    local icon = iconCell({parent = root, isTip = true, num = {value = 124000}, iconID = 444444})
    icon:setScale(71.0 / 82)
    icon:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 - 40 + distance_between_type * 2, spr_bg:getPositionY() + 268 + 60))
    local icon3 = iconCell({parent = root, isTip = true, num = {value = 1280}, iconID = 777777})--点击icon弹出了第3级tip
    icon3:setScale(71.0 / 82)
    icon3:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + 40 + distance_between_type * 2, spr_bg:getPositionY() + 268 + 60))

    createLabel(root, game.getStrByKey("consume") .. ":" .. 1 .. game.getStrByKey("ten_thousand") .. game.getStrByKey("gold_coin"), cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type * 2, spr_bg:getPositionY() + 206) , cc.p(.5, 0) , 20, true , nil , nil , cc.c3b(247, 206, 150))
    local publishBtn = createMenuItem(root, "res/component/button/2.png", cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type * 2, spr_bg:getPositionY() + 136) , function()
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(5)
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(0, 1)
    end)
    createLabel(publishBtn, game.getStrByKey("taskPublish") .. game.getStrByKey("task_tf"), getCenterPos(publishBtn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147))

    local BagItemChanged = function(observable, event, pos, pos1, new_grid)
		if event == "-" or event == "+" or event == "=" then
			root:removeChildByTag(399);
            -- 获取至尊悬赏卷轴数量
            local extremeNum = pack:countByProtoId(commConst.ITEM_ID_EXTREME_BOUNTY_SCROLL);
            local extremeStr = game.getStrByKey("rewardTaskMaterialZhiZun") .. "(^c(" .. ( extremeNum > 0 and "green)" or "red)" ) ..  extremeNum .. "^" .. "/1)"
            --function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
            local extremeRichText = require("src/RichText").new( root , cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2, spr_bg:getPositionY() + 214) , cc.size( 200 , 22 ) , cc.p(.5, 0) , 22 , 20 , MColor.white, 399 )
            extremeRichText:setAutoWidth()
            extremeRichText:addText( extremeStr , MColor.lable_yellow , false )
            extremeRichText:format()

            root:removeChildByTag(299);
			-- 获取高级悬赏卷轴数量
            local seniorNum = pack:countByProtoId(commConst.ITEM_ID_SENIOR_BOUNTY_SCROLL);
            local seniorStr = game.getStrByKey("rewardTaskMaterialGaoJi") .. "(^c(" .. ( seniorNum > 0 and "green)" or "red)" ) ..  seniorNum .. "^" .. "/1)"
            --function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
            local extremeRichText = require("src/RichText").new( root , cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2 + distance_between_type, spr_bg:getPositionY() + 206) , cc.size( 200 , 22 ) , cc.p(.5, 0) , 22 , 20 , MColor.white, 299 )
            extremeRichText:setAutoWidth()
            extremeRichText:addText( seniorStr , MColor.lable_yellow , false )
            extremeRichText:format()
		end
	end

    root:registerScriptHandler(function(event)
		if event == "enter" then
            BagItemChanged(nil, "=");
			pack:register(BagItemChanged)
		elseif event == "exit" then
			pack:unregister(BagItemChanged)
		end
	end)
    
    local tag_extremeRichTextTag = 50003;
    local tag_richText = 50002
    function root:RefreshData()
        root:removeChildByTag(tag_richText)
        local richText = require("src/RichText").new(root, cc.p(spr_bg:getPositionX() - padding_left + 790 / 2 - 345 / 2, 27 ) , cc.size( 500 , 0 ) , cc.p( 0 , 0) , 22 , 22 , MColor.white)
        richText:setTag(tag_richText)
        richText:setAutoWidth()
        local rewardTasks = DATA_Mission:GetRewardTaskData()
        local publishNum = rewardTasks and rewardTasks.publishLeftNum or 0
        local rightStr1 = "^c(lable_yellow)" .. game.getStrByKey("taskJuinorBounty") .. game.getStrByKey("taskAnd") .. game.getStrByKey("taskSeniorBounty") .. game.getStrByKey("taskStillCan") .. game.getStrByKey("taskPublish") .. "^" .. publishNum .. "^c(lable_yellow)" .. game.getStrByKey("baby_material_number") .. "^"
        richText:addText(rightStr1)
	    richText:format()

        root:removeChildByTag(tag_extremeRichTextTag);
        -- 获取至尊悬赏剩余次数
        local extremeLeftNum = rewardTasks and rewardTasks.publishExtremeLeftNum or 0;
        local extremeLeftStr = game.getStrByKey("taskExtremeBounty") .. game.getStrByKey("times_left") .. "^c(white)" ..  extremeLeftNum .. "^";
        --function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
        local extremeLeftRichText = require("src/RichText").new( root , cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2, spr_bg:getPositionY() + 180) , cc.size( 200 , 22 ) , cc.p(.5, 0) , 22 , 20 , MColor.white )
        extremeLeftRichText:setAutoWidth()
        extremeLeftRichText:setTag(tag_extremeRichTextTag)
        extremeLeftRichText:addText( extremeLeftStr , MColor.lable_yellow , false )
        extremeLeftRichText:format()

        local extremeLeftRichTextSize = extremeLeftRichText:getContentSize();
        extremeLeftRichText:setPosition(cc.p(spr_bg_zhi_zun:getPositionX() + spr_bg_zhi_zun:getContentSize().width / 2, spr_bg:getPositionY() + 200 - extremeLeftRichTextSize.height));
    end
    --请求一次服务器数据用来触发刷新RefreshData
    require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(5)
    return root
end}