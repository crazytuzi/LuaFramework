--HeroStrengthChoose.lua

local HeroStrengthChoose = class ("HeroStrengthChoose", UFCCSModelLayer)

function HeroStrengthChoose:ctor( ... )
    self._func = nil
    self._totalExp = 0
    self._maxNeedExp = 0
    self._selectedHeros = {}

	self.super.ctor(self, ...)
end

function HeroStrengthChoose:onLayerLoad(  )
    
    self:registerBtnClickEvent("Button_return", function ( widget )
        self:close()
    end)

    self:registerBtnClickEvent("Button_ok", function ( widget )
        self:_onOkClicked()
    end)

    local label = self:getLabelByName("Label_exp")
    if label then
        label:enableStrokeEx(Colors.strokeBrown, 1)
    end
    label = self:getLabelByName("Label_selected")
    if label then
        label:enableStrokeEx(Colors.strokeBrown, 1)
    end
    self:enableLabelStroke("Label_need_exp", Colors.strokeBlack, 1)
    self:enableLabelStroke("Label_exp_value_total", Colors.strokeBlack, 1)
    self:showTextWithLabel("Label_exp_value_total", "0")

	self:adapterWithScreen()

	self:adapterWidgetHeight("Panel_list", "Panel_260", "Panel_bottom", -20, -10)
end

function HeroStrengthChoose:onLayerEnter( ... )
    --self:registerKeypadEvent(true, false)
    self:closeAtReturn(true)
end

function HeroStrengthChoose:onBackKeyEvent( ... )
    self:close()
    return true
end

function HeroStrengthChoose:initHeroList( knightList, selectedKnights, needExp, maxExp, func )
    self._maxNeedExp = maxExp or needExp

    local expLabel = self:getLabelByName("Label_need_exp")
    if expLabel then
        expLabel:setText(""..needExp)
    end

    table.foreach(selectedKnights, function ( i, v )
        if v > 0 then 
            self:_onChooseHero(v, true, G_Me.bagData.knightsData:getKnightAcquireExp(v), nil, true)
        end
        --self:_doAddKnight(v)
        --self:_updateSelectDesc(v, G_Me.bagData.knightsData:getKnightAcquireExp(v), true)
    end)
    self._func = func

    self._knightList = knightList
    
	local panel = self:getPanelByName("Panel_list")
	if panel == nil then
		return 
	end

	self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

    self._listview:setCreateCellHandler(function ( list, index)
        return require("app.scenes.herofoster.HeroStrengthChooseItem").new(list, index)
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
        cell:updateHeroItem( self._knightList[index + 1], self._selectedHeros )
    end)
    self._listview:setSelectCellHandler(function ( list, knightId, param, cell )
        local selected = cell:isSelectedStatus()
        return self:_onChooseHero(knightId, selected, param, cell)
        --local ret2 = self:_updateSelectDesc( knightId, param, selected, cell )

        --return (ret1 and ret2) and true or false
    end)
    self:registerListViewEvent("Panel_list", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
    end)

    --local count = G_Me.bagData.knightsData:getKnightCount() - 1
    self._listview:initChildWithDataLength(#self._knightList, 0.2)
end

function HeroStrengthChoose:_onChooseHero( knightId, isSelected, param, cell, isQuiet )

    isQuiet = isQuiet or false
    local length = #self._selectedHeros

    local nLimitLength = 5
    local szTips = G_lang:get("LANG_KNIGHT_STRENGTH_TIP_MAX_KNIGHT")
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.OPTIMIZE_LEVEL_UP) then
        nLimitLength = 10
        szTips = G_lang:get("LANG_KNIGHT_STRENGTH_TIP_MAX_KNIGHT2")
    end

    if length >= nLimitLength and isSelected then
        if not isQuiet then
            G_MovingTip:showMovingTip(szTips)
        end
        return false
    end


    param = param or 0
    local _doOk = function ( ... )
        if isSelected then
            self._totalExp = self._totalExp + param
        else
            self._totalExp = self._totalExp - param
        end
        local totalExp = self:getLabelByName("Label_exp_value_total")
        if totalExp then
            totalExp:setText(""..self._totalExp)
        end

        if isSelected then
            self:_doAddKnight(knightId)
        else
            self:_doRemoveKnight(knightId)
        end
    end

    if not isQuiet and isSelected and self._totalExp + param > self._maxNeedExp then
            MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_KNIGHT_STRENGTH_TIP_EXP_EXCEED"), false, 
                    function ( ... )
                        _doOk()

                        if cell then
                            cell:checkStrengthItem(true)
                        end
                    end)
        return false
    end

    _doOk()

    return true
end

function HeroStrengthChoose:_updateSelectDesc( knightId, param, selected, cell )
    param = param or 0
    local _doOk = function ( ... )
        if selected then
            self._totalExp = self._totalExp + param
        else
            self._totalExp = self._totalExp - param
        end
        local totalExp = self:getLabelByName("Label_exp_value_total")
        if totalExp then
            totalExp:setText(""..self._totalExp)
        end
    end

    if selected and self._totalExp + param > self._maxNeedExp then
        MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_KNIGHT_STRENGTH_TIP_RARELY_KNIGHT"), false, 
                    function ( ... )
                        _doOk()

                        cell:checkStrengthItem(true)
                        self:_doAddKnight(knightId)
                    end)
        return false
    end

    _doOk()

    return true
 end 

function HeroStrengthChoose:_doAddKnight( knightId )
    if type(knightId) ~= "number" then
        return 
    end

    for i, value in pairs(self._selectedHeros) do
       if value == knightId then
           return 
       end
    end

    table.insert(self._selectedHeros, #self._selectedHeros + 1, knightId)
end

function HeroStrengthChoose:_doRemoveKnight( knightId )
    for i, value in pairs(self._selectedHeros) do
        if value == knightId then
            table.remove(self._selectedHeros, i)
            return 
        end
    end
end

function HeroStrengthChoose:_onOkClicked( ... )
    local hasRarelyKnight = false
    for key, value in pairs(self._selectedHeros) do 
        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId( value )
        if knightInfo then
            local knightBaseInfo = knight_info.get(knightInfo["base_id"])
            if knightBaseInfo and knightBaseInfo.potential >= 18 then
               hasRarelyKnight = true
            end
        end
    end

    local doOk = function() 
        if self._func ~= nil then
            self._func(self._selectedHeros, self._totalExp)
        end

        self:close()
    end

    if hasRarelyKnight then
        MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_KNIGHT_STRENGTH_TIP_RARELY_KNIGHT"), false, 
                    function ( ... )
                        doOk()
                    end)
        return 
    end     

    doOk()
end

function HeroStrengthChoose.showHeroChooseLayer( parent, knightList, selectedKnights, needExp, maxExp, func )
    if parent == nil then
        return 
    end

    local heroChoose = require("app.scenes.herofoster.HeroStrengthChoose").new("ui_layout/HeroStrengthen_ChooseHero.json" )
    parent:addChild(heroChoose)
    heroChoose:initHeroList(knightList, selectedKnights, needExp, maxExp, func)

end

return HeroStrengthChoose

