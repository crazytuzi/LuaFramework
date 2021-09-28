
local BaseChooseLayer = class ("BaseChooseLayer", UFCCSModelLayer)


function BaseChooseLayer.create()
    local layer = BaseChooseLayer.new("ui_layout/common_BaseChooseLayer.json")
    return layer
end

function BaseChooseLayer:ctor( ... )
    self._func = nil
    self._totalExp = 0
    self._selectedItems= {}

    self.super.ctor(self, ...)
end

function BaseChooseLayer:onLayerEnter( )
    self:closeAtReturn(true)
end

function BaseChooseLayer:onBackKeyEvent( ... )
    self:close()
    return true
end

function BaseChooseLayer:onLayerLoad(  )
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
    self:enableLabelStroke("Label_exp_value", Colors.strokeBlack, 1)
    self:enableLabelStroke("Label_exp_value_total", Colors.strokeBlack, 1)
    self:showTextWithLabel("Label_exp_value_total", "0")

    self:adapterWithScreen()

    self:adapterWidgetHeight("Panel_list", "Panel_top", "Panel_bottom", 0, 0)
end

function BaseChooseLayer:getNeedExp( curItem )
    return 0
end

function BaseChooseLayer:getSupplyExp( item )
    return 0
end

function BaseChooseLayer:initItemList( itemList, selectedItems, needExp, func )
    local expLabel = self:getLabelByName("Label_need_exp")
    if expLabel then
        expLabel:setText(""..needExp)
    end

    for i,v in pairs(selectedItems) do
        self:_doAddItem(v)
        self:_updateSelectDesc(v, self:getSupplyExp(v), true)
    end

    self._func = func

    self._itemList = itemList

    -- for k,v in pairs(selectedItems) do 
    --     self._selectedItems[k] = v
    -- end
    
    local panel = self:getPanelByName("Panel_list")
    if panel == nil then
	return 
    end

    self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

    self._listview:setCreateCellHandler(function ( list, index)
            local cell = self:getItem(list, index)
            cell:setSelectCallback(function ( item, exp, cell )
                    local selected = cell:isSelectedStatus()
                    local ret = self:_onChooseItem(item, selected, exp, cell)
                    if ret then
                        self:_updateSelectDesc( item, exp, selected )
                    end

                    return ret
                end
            )
            return cell

    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
        cell:updateItem( self._itemList[index + 1], self._selectedItems )
    end)

    self._listview:initChildWithDataLength(#self._itemList,0.2)
end

function BaseChooseLayer:getItem( item , index)
    return require("app.scenes.common.BaseChooseItem").new(list, index)
end


-- 判断能否选中
function BaseChooseLayer:_onChooseItem( item, isSelected, param, cell )

    if not self:checkChooseItem(item, isSelected) then
        return false
    end

    if isSelected then 
       self:_doAddItem(item)
    else
       self:_doRemoveItem(item)
    end

    return true
end

function BaseChooseLayer:checkChooseItem( item , isSelected)
    -- local length = #self._selectedItems
    -- if length >= 5 and isSelected then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_TOO_MUCH"))
    --     return false
    -- end

    -- if self._totalExp > self._equipment:getStrengthLeftExp() and isSelected then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_ENOUGH_EXP_TIPS"))
    --     return false
    -- end

    -- if self._item:getStrengthMoney(self._totalExp + treasure:getSupplyExp()) > G_Me.userData.money and isSelected then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_MONEY_NOTENOUGH_TIPS"))
    --     return false
    -- end
    -- return true
end


function BaseChooseLayer:_updateSelectDesc( item, param, selected )
    param = param or 0
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

function BaseChooseLayer:_doAddItem( item )

    for i, value in pairs(self._selectedItems) do
       if value.id == item.id then
           return 
       end
    end
    table.insert(self._selectedItems, #self._selectedItems + 1, item)
end

function BaseChooseLayer:_doRemoveItem( item )
    for i, value in pairs(self._selectedItems) do
        if value.id == item.id then
            table.remove(self._selectedItems, i)
            return 
        end
    end
end

function BaseChooseLayer:_onOkClicked( ... )

    local doOk = function() 
        if self._func ~= nil then
            self._func(self._selectedItems, self._totalExp)
        end

        self:close()
    end

    if self:checkItem(self._selectedItems) then
        MessageBoxEx.showYesNoMessage(nil, 
                    self:getHighTxt(), false, 
                    function ( ... )
                        doOk()
                    end)
        return 
    end     

    doOk()
end

function BaseChooseLayer:getHighTxt( )
    return G_lang:get("LANG_QIANGHUA_HAS_HIGH_LEVEL_CAILIAO")
end

function BaseChooseLayer:checkItem(items )
    -- local hasRarelyItem = false
    -- for key, value in pairs(self._selectedItems) do 
    --         local treasureBaseInfo = value:getInfo()
    --         if treasureBaseInfo and treasureBaseInfo.quality >= 4 and treasureBaseInfo.type ~= 3 then
    --            hasRarelyTreasure = true
    --         end
    -- end
    -- return hasRarelyItem
    return false
end

return BaseChooseLayer

