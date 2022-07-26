require"Lang"
UIAllianceActivity = {}

local ACTIVITYS = {
--    { name = "ui_alliance_aaa", openLevel = 0 }
    { name = "ui_alliance_mysteries" , openLevel = 0 },
    { name = "ui_alliance_escort" , openLevel = 0 },
    { name = "ui_alliance_run" , openLevel = 0 },
    { name = "ui_alliance_njsf", openLevel = DictSysConfig[tostring(StaticSysConfig.NaJie_OpenLevel)].value }
}

local userData = nil
local ui_scrollView = nil
local ui_svItem = nil

local function cleanScrollView()
    if ui_svItem and ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    local SCROLLVIEW_ITEM_SPACE = 10
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
        scrollViewItem:loadTexture( "image/"..obj.name..".png" )
        if tonumber( obj.openLevel ) == -1 then
            utils.GrayWidget( scrollViewItem , true )
        else
            utils.GrayWidget( scrollViewItem , false )
        end
		_initItemFunc(scrollViewItem, obj)
		ui_scrollView:addChild(scrollViewItem)
		_innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

function UIAllianceActivity.init()
    local image_basemap = UIAllianceActivity.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    btn_back:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_activity")
    ui_svItem = ui_scrollView:getChildByName("image_activity"):clone()
end

function UIAllianceActivity.setup()
    layoutScrollView(ACTIVITYS, function(_item, _data)
        _item:setTouchEnabled(true)
        _item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if tonumber( _data.openLevel ) == -1 then
                    UIManager.showToast( Lang.ui_alliance_activity1 )
                elseif userData.allianceLevel >= _data.openLevel then
                    if _data.name == "ui_alliance_mysteries" then
                        UIAllianceMysteries.setData( { allianceLevel = userData.allianceLevel } )
                    elseif _data.name == "ui_alliance_run" then
                        UIAllianceRun.setData( { allianceLevel = userData.allianceLevel } )
                    end
                    local class = require(_data.name)
                    if type(class) == "table" and class.show then
                        class.show(userData)
                    else
                        if _data.name == "ui_alliance_run" then
                            netSendPackage( { header = StaticMsgRule.sendTurtleOpen , msgdata = {} } , function ( pack )
                                local openState = pack.msgdata.int.isOpen
                                if openState == 0 then
                                    UIManager.showToast( Lang.ui_alliance_activity2 )
                                else
                                    UIManager.showWidget(_data.name)
                                end
                            end )                           
                        else
                            UIManager.showWidget(_data.name)
                        end
                    end
                else
                    UIManager.showToast(string.format(Lang.ui_alliance_activity3, _data.openLevel))
                end
            end
        end)
    end)
end

function UIAllianceActivity.show(_tableParams)
    userData = _tableParams
    UIManager.showWidget("ui_alliance_activity")
end

function UIAllianceActivity.free()
    cleanScrollView()
end
