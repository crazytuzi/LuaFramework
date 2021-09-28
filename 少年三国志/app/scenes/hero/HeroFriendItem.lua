local HeroFriendItem = class ("HeroFriendItem", function (  )
	return CCSItemCellBase:create("ui_layout/knight_friendItem.json")
end)
local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function HeroFriendItem:ctor()
        
    self._addButton = self:getButtonByName("Button_add")
    self._mainPanel = self:getPanelByName("Panel_main")
    self._heroPanel = self:getPanelByName("Panel_hero")
    self._nameLabel = self:getLabelByName("Label_name")
    self._barLabel = self:getLabelByName("Label_bar")
    self._progress = self:getLoadingBarByName("ProgressBar_level")
    self._barLabel:createStroke(Colors.strokeBrown, 1)
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._bossEffect = nil

    self:registerBtnClickEvent("Button_add", function(widget)
                if not G_Me.formationData:isFirstTeamFull() then 
                    return G_MovingTip:showMovingTip(G_lang:get("LANG_FIRST_TEAM_NOT_FULL"))
                end
                local team1Knight, team1Count = G_Me.formationData:getFirstTeamKnightIds()
                local team2Knight, team2Count = G_Me.formationData:getSecondTeamKnightIds()
                if team1Count + team2Count >= G_Me.bagData.knightsData:getKnightCount() then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_NO_SELECT_KNIGHT"))
                else
                    local heroSelectLayer = require("app.scenes.hero.HeroSelectLayer")
                    heroSelectLayer.showHeroSelectLayer(uf_sceneManager:getCurScene(), self._index + 6, function ( knightId, effectWaitCallback )
                        self.__EFFECT_FINISH_CALLBACK__ = effectWaitCallback
                        if not G_Me.formationData:isKnightValidjForCurrentTeam(2, knightId, index) then
                           G_MovingTip:showMovingTip(G_lang:get("LANG_SAME_KNIGHT"))
                           return 
                        end

                        G_HandlersManager.cardHandler:changeTeamFormation(2, self._index, knightId)
                    end)
               end
    end)

end

function HeroFriendItem:updateView(index,targetType,targetLevel,func)
    self._index = index
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(2, index)
    if knightId > 0 then
        self._addButton:setVisible(false)
        self._mainPanel:setVisible(true)
        local baseInfo = knight_info.get(baseId)
        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
        self._nameLabel:setText(baseInfo.name)
        self._nameLabel:setColor(Colors.qualityColors[baseInfo.quality])

        self._heroPanel:removeAllChildrenWithCleanup(true)
        self._hero = KnightPic.createKnightButton(baseInfo.res_id,self._heroPanel,"knight_img",self,function ( )
            func()
            local KnightConst = require("app.const.KnightConst")
            uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( 
                KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, knightId ))
        end ,true,false)
        self._heroPanel:setScale(0.35)
        if not self._bossEffect then
            self._bossEffect = EffectSingleMoving.run(self._heroPanel, "smoving_idle", nil, {})
        end

        local curLevel = knightInfo.level
        self._progress:setPercent(math.min(curLevel*100/targetLevel,100))
        self._barLabel:setText(curLevel.."/"..targetLevel)
    else
        self._addButton:setVisible(true)
        self._mainPanel:setVisible(false)
    end
end

return HeroFriendItem

