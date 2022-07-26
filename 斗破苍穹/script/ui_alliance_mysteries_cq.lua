require"Lang"
UIAllianceMysteriesCq = {}
local _chooseBox = nil --单选框列表
local _persionNum = nil -- 骰子个数
local _panel = nil 
local _selectedId = nil
function UIAllianceMysteriesCq.init()
    local btn_closed = ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "btn_closed" )
    local btn_sure = ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "btn_sure" )
    local panel1 = ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "panel_1" )
    local panel2 = ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "panel_2" )
    local checkBox1 = {}
    local checkBox2 = {}
    for i = 1 , 6 do
        checkBox1[ i ] = panel1:getChildByName( "checkbox_practice"..i )
    end
    for i = 1 , 11 do
        checkBox2[ i ] = panel2:getChildByName( "checkbox_practice"..i )
    end
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_closed then
                UIManager.popScene()
                UIAllianceMysteries.setChuQian()
            elseif sender == btn_sure then
                if _selectedId then
                    UIAllianceMysteries.setChuQian( _chooseBox[_selectedId] )
                    UIManager.popScene()
                   -- cclog( "_selectedId".._chooseBox[_selectedId] )
                else
                    UIManager.showToast( Lang.ui_alliance_mysteries_cq1 )
                end
            end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( onEvent )
    btn_sure:setPressedActionEnabled( true )
    btn_sure:addTouchEventListener( onEvent )

    local function onCheckBoxEvent( sender , eventType )
        if eventType == ccui.CheckBoxEventType.selected then
            local checkBox_ = nil
            if _persionNum == 1 then
                for key , value in pairs( checkBox1 ) do
                    if sender == value then
                        _selectedId = key
                    end
                end
                checkBox_ = checkBox1
            elseif _persionNum == 2 then
                for key , value in pairs( checkBox2 ) do
                    if sender == value then
                        _selectedId = key
                    end
                end
                checkBox_ = checkBox2
            end
            for key , value in pairs ( checkBox_ ) do
                if key ~= _selectedId then
                    value:setSelected( false )
                end
            end
        elseif eventType == ccui.CheckBoxEventType.unselected then
            _selectedId = nil
        end
    end
    for i = 1 , 6 do
        checkBox1[ i ]:addEventListener( onCheckBoxEvent )
    end
    for i = 1 , 11 do
        checkBox2[ i ]:addEventListener( onCheckBoxEvent )
    end
end
function UIAllianceMysteriesCq.setup()
    if _persionNum == 1 then
         _chooseBox = { 1 , 2 , 3 , 4 , 5 , 6
        }
        ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "panel_2" ):setVisible( false )
        _panel = ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "panel_1" )
    elseif _persionNum == 2 then
         _chooseBox = { 2 , 3 , 4 , 5 , 6 , 7 ,
                   8 , 9 , 10 , 11 , 12 
        }
        ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "panel_1" ):setVisible( false )
        _panel = ccui.Helper:seekNodeByName( UIAllianceMysteriesCq.Widget , "panel_2" )
    end
end
function UIAllianceMysteriesCq.free()
    _chooseBox = nil
    _persionNum = nil
    _selectedId = nil
end
function UIAllianceMysteriesCq.setData( data )
    _persionNum = data.num
end
