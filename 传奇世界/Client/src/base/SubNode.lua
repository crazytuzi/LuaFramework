local SubNode = class("SubNode", function() return cc.Node:create() end )

function SubNode:ctor(params,pos)
	cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileEx("res/mainui/mainui@0.plist", false, false)
	createSprite(self, "res/common/scalable/main0.png", cc.p(0,0), cc.p(0.5,1.0))
	local spanx = 90
	local size = cc.size(30+#params*spanx,105)
	local bg = createScale9Sprite(self,"res/common/scalable/main1.png",cc.p(0,0),size,cc.p(0.5,0.0))
    bg:setTag(require("src/config/CommDef").TAG_SUB_NODE_BG)
	for k,v in ipairs(params)do
		local button = createTouchItem(bg,{"mainui/bottombtns/"..v.res..".png","mainui/bottombtns/"..v.res.."_sel.png"},cc.p(60+(k-1)*spanx,52),v.func)
		if v.res == "hy" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_FRIEND)
		elseif v.res == "hh" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_FACTION)
		elseif v.res == "dz" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_MAKE)
		elseif v.res =="bs" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_MASTER)
		elseif v.res == "qh" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_QIANGHUA)
		elseif v.res == "xl" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_XILIAN)
		elseif v.res == "zf" then
			G_TUTO_NODE:setTouchNode(button, TOUCH_SUB_ZHUFU)

		end
        if v.res == "mail" then
			G_MAINSCENE.__mailRed2 = createSprite( button, getSpriteFrame("mainui/flag/red.png") ,cc.p( button:getContentSize().width - 5 , button:getContentSize().height - 15 ) , cc.p( 0.5 , 0.5 ) )
			local isRed = false
			if G_MAIL_INFO and G_MAIL_INFO.emaliCount and G_MAIL_INFO.emaliCount> 0 then
				isRed = true
			end
			G_MAINSCENE.__mailRed2:setVisible( isRed )
        end
        if v.res == "rl" then
            button:setTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN)
        end
        if v.res == "dz" then
            button:setTag(require("src/config/CommDef").TAG_BUTTON_DAZAO)
        end
        if v.res == "hc" then
            button:setTag(require("src/config/CommDef").TAG_BUTTON_HECHENG)
        end
	end
	if pos then
		self:setPosition(pos)
	end
	local closeFunc = function()
		--self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.0), cc.RemoveSelf:create()))
		--removeFromParent(self)

        self:removeSelf()
	end
	registerOutsideCloseFunc(bg, closeFunc, true)

	self:setScale(0.0)
	self:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1))))
    local bag = MPackManager:getPack(MPackStruct.eBag)
	self:registerScriptHandler(function(event)
        function func_refreshRedDot_subNode()
            local forge = require("src/config/Forge")
            --打造button
            --遍历本种类的子item,如果有一个材料足够，那么本类就显示红点
            local bool_has_one_item_enough_daZao = false
			local player_money = MRoleStruct:getAttr(PLAYER_MONEY) or 0
			local player_vital = MRoleStruct:getAttr(PLAYER_VITAL) or 0

            for k, v in pairs(forge) do
                while true do
                    if v.q_sort ~= 1 then--打造
                        break
                    end
                    --查看所消耗的材料,命运打造的3职业消耗相同
                    local q_forgeCost = assert(loadstring("return " .. v.q_forgeCost))()
                    --如果材料足够就显示红点
                    local bool_enough = true
                    for item_id, item_count in pairs(q_forgeCost) do
                        if item_id == 777777 and item_count > player_vital then--声望
                            bool_enough = false
                            break
                        end
                        if item_id == 999998 and item_count > player_money then--金币
                            bool_enough = false
                            break
                        end
                        if item_id ~= 999998 and item_id ~= 777777 and item_count > MPackManager:getPack(MPackStruct.eBag):countByProtoId(item_id) then--道具:除了以上两种材料，其他都认为是道具，如果有不同的情况，程序崩溃，到时扩展程序
                            bool_enough = false
                            break
                        end
                    end
                    if bool_enough then
                        bool_has_one_item_enough_daZao = true
                    end
                    break
                end
                if bool_has_one_item_enough_daZao then
                    break
                end
            end
            if 
                G_MAINSCENE
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_DAZAO)
                and not G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_DAZAO):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
                and bool_has_one_item_enough_daZao then
                local node_daZao = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_DAZAO)
                local spr_redDot = createSprite(
                    node_daZao
                    , "res/component/flag/red.png"
                    , cc.p(node_daZao:getContentSize().width - 5, node_daZao:getContentSize().height - 15)
                )
                spr_redDot:setTag(require("src/config/CommDef").TAG_RED_DOT)
            elseif
                G_MAINSCENE
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_DAZAO)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_DAZAO):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
                then
                local node_daZao = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_DAZAO)
                node_daZao:removeChildByTag(require("src/config/CommDef").TAG_RED_DOT)
            end
            --合成button
            --遍历本种类的子item,如果有一个材料足够，那么本类就显示红点
            local bool_has_one_item_enough_heCheng = false
            for k, v in pairs(forge) do
                while true do
                    if v.q_sort ~= 2 then--合成
                        break
                    end
                    --查看所消耗的材料,命运打造的3职业消耗相同
                    local q_forgeCost = assert(loadstring("return " .. v.q_forgeCost))()
                    --如果材料足够就显示红点
                    local bool_enough = true
                    for item_id, item_count in pairs(q_forgeCost) do
                        if item_id == 777777 and item_count > MRoleStruct:getAttr(PLAYER_VITAL) then--声望
                            bool_enough = false
                            break
                        end
                        if item_id == 999998 and item_count > MRoleStruct:getAttr(PLAYER_MONEY) then--金币
                            bool_enough = false
                            break
                        end
                        if item_id ~= 999998 and item_id ~= 777777 and item_count > MPackManager:getPack(MPackStruct.eBag):countByProtoId(item_id) then--道具:除了以上两种材料，其他都认为是道具，如果有不同的情况，程序崩溃，到时扩展程序
                            bool_enough = false
                            break
                        end
                    end
                    if bool_enough then
                        bool_has_one_item_enough_heCheng = true
                    end
                    break
                end
                if bool_has_one_item_enough_heCheng then
                    break
                end
            end
            if G_MAINSCENE
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_HECHENG)
                and not G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_HECHENG):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
                and bool_has_one_item_enough_heCheng then
                local node_heCheng = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_HECHENG)
                local spr_redDot = createSprite(
                    node_heCheng
                    , "res/component/flag/red.png"
                    , cc.p(node_heCheng:getContentSize().width - 5, node_heCheng:getContentSize().height - 15)
                )
                spr_redDot:setTag(require("src/config/CommDef").TAG_RED_DOT)
            elseif
                G_MAINSCENE
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_HECHENG)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_HECHENG):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
                then
                local node_daZao = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_HECHENG)
                node_daZao:removeChildByTag(require("src/config/CommDef").TAG_RED_DOT)
            end
        end
        local func_changed_item = function(observable, event, pos, pos1, new_grid)
            if not (event == "-" or event == "+" or event == "=") then return end
            func_refreshRedDot_subNode()
        end
        local func_changed_gold = function(observable, attrId, objId, isMe, attrValue)
            if not isMe then return end
            if attrId ~= PLAYER_MONEY and attrId ~= PLAYER_VITAL then return end
            func_refreshRedDot_subNode()
        end
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_SUB)
            --熔炼button
            if
                G_RED_DOT_DATA.bool_shallShowSmelterRedDot
                and G_MAINSCENE
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP)
                and G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN)
                and not G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
            then
                local node_rongLian = G_MAINSCENE.base_node:getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BUTTON + require("src/config/CommDef").TAG_INDEX_SUB_NODE_EQUIP):getChildByTag(require("src/config/CommDef").TAG_SUB_NODE_BG):getChildByTag(require("src/config/CommDef").TAG_BUTTON_RONGLIAN)
                local spr_redDot = createSprite(
                    node_rongLian
                    , "res/component/flag/red.png"
                    , cc.p(node_rongLian:getContentSize().width - 5, node_rongLian:getContentSize().height - 15)
                )
                spr_redDot:setTag(require("src/config/CommDef").TAG_RED_DOT)
            end
            func_refreshRedDot_subNode()
            bag:register(func_changed_item)
            MRoleStruct:register(func_changed_gold)
		elseif event == "exit" then
			G_MAINSCENE.__mailRed2 = nil
            bag:unregister(func_changed_item)
            MRoleStruct:unregister(func_changed_gold)
		end
	end)
end

function SubNode:removeSelf()
    self:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.0), cc.RemoveSelf:create()))
end

return SubNode