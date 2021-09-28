-- VSEntry

local VSEntry = class("VSEntry", require "app.scenes.battle.entry.TweenEntry")

function VSEntry.create(...)
    return VSEntry.new("battle/tween/tween_pvp.json", ...)
end

function VSEntry:ctor(vsJson, vsInfo, battleField)

    VSEntry.super.ctor(self, vsJson, vsInfo, nil, battleField)
    
    battleField:addToSuperSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(ccp(display.cx, display.cy)))
    
end

function VSEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local vsInfo = self._data
    
    local displayNode = node
    
    if not displayNode then
        -- 先手
        if string.match(tweenNode, "xianshou") then
            
            local suffix = tonumber(string.sub(tweenNode, string.len(tweenNode), string.len(tweenNode)))
            displayNode = display.newSprite(G_Path.getBattleTxtImage('pvp_xianshou.png'))
            if suffix >= 1 and suffix <= 3 then
                displayNode:setVisible(vsInfo.first == 1)
            else
                displayNode:setVisible(vsInfo.first == 2)
            end

        -- vs
        elseif string.match(tweenNode, "vs") then
            displayNode = display.newSprite(G_Path.getBattleTxtImage('pvp_vs.png'))
            
        -- 这里根据后缀a或b结尾，a是我方，b是敌方
        -- 头像
        elseif string.match(tweenNode, "touxiang") then
            
            local suffix = string.sub(tweenNode, string.len(tweenNode), string.len(tweenNode))
            displayNode = display.newSprite("#putong_bg.png")
            -- 这里要更换时装头像
            local knightId = suffix == "a" and vsInfo.myself.id or vsInfo.enemy.id
            local myselfDressId = suffix == "a" and vsInfo.myself.dress_id or vsInfo.enemy.dress_id
            local clid = suffix == "a" and vsInfo.myself.clid or vsInfo.enemy.clid
            local cltm = suffix == "a" and vsInfo.myself.cltm or vsInfo.enemy.cltm
            local clop = suffix == "a" and vsInfo.myself.clop or vsInfo.enemy.clop
            local head = display.newSprite(G_Path.getKnightIcon(
                ((myselfDressId and myselfDressId ~= 0) or (clid and clid ~= 0)) 
                and G_Me.dressData:getDressedResidWithClidAndCltm(knightId, myselfDressId ,clid ,cltm,clop) 
                or knight_info.get(knightId).res_id))
            displayNode:addChild(head)
            head:setPositionXY(displayNode:getContentSize().width/2, displayNode:getContentSize().height/2)
        -- 战力
        elseif string.match(tweenNode, "zhanli") then
            
            local suffix = string.sub(tweenNode, string.len(tweenNode), string.len(tweenNode))
            local label = Label:create()
            label:setFontName(G_Path.getBattleLabelFont())
            label:setFontSize(vsInfo.first == 1 and 34 or 30)
            label:setColor(Colors.darkColors.TITLE_01)
            label:createStroke(Colors.strokeBlack, 1)
            label:setText(G_lang:get("LANG_BATTLE_VS_POWER_DESC", {power=suffix == "a" and vsInfo.myself.power or vsInfo.enemy.power}))
            label:setAnchorPoint(ccp(suffix == "a" and 1 or 0, 0.5))
            displayNode = label
        -- 背景底图
        elseif string.match(tweenNode, "heidi") then
            
            local suffix = string.sub(tweenNode, string.len(tweenNode), string.len(tweenNode))
            displayNode = display.newSprite(G_Path.getBattleImage(suffix == "a" and 'pvp_ziji_di.png' or 'pvp_difang_di.png'))
            
        elseif string.match(tweenNode, "name") then
            
            local suffix = string.sub(tweenNode, string.len(tweenNode), string.len(tweenNode))
            local label = Label:create()
            label:setFontName(G_Path.getBattleLabelFont())
            label:setFontSize(30)
            local quality = knight_info.get(suffix == "a" and vsInfo.myself.id or vsInfo.enemy.id).quality
            label:setColor(Colors.qualityColors[quality])
            label:createStroke(Colors.strokeBlack, 1)
            label:setText(suffix == "a" and vsInfo.myself.name or vsInfo.enemy.name)
            label:setAnchorPoint(ccp(suffix == "a" and 1 or 0, 0.5))
            displayNode = label
            
        elseif tweenNode == "zhezhao" then           
            displayNode = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width, display.height)
            displayNode:ignoreAnchorPointForPosition(false)
            displayNode:setAnchorPoint(ccp(0.5, 0.5))
        end
        
        assert(displayNode, "Unknown displayNode with key: "..tweenNode)

        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end
    
    return displayNode

end

return VSEntry






