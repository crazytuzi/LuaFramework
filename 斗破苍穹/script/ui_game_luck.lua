UIGameLuck = {}
local ui_scrollView = nil
local ui_svItem = nil
local _data = nil
local function showAllLuck()
	local innerHieght, space = 0, 20
		
	local formationData = {}
    for key ,value in pairs( _data ) do
	    for key, obj in pairs(net.InstPlayerFormation) do
		    if obj.int["3"] == tonumber( value ) then
			    formationData[#formationData + 1] = obj
		    end
	    end
    end	
	
	for key, obj in pairs(formationData) do
		local svItem = ui_svItem:clone()
		ui_scrollView:addChild(svItem)
		innerHieght = innerHieght + svItem:getContentSize().height + space
			
		local ui_cardFrame = ccui.Helper:seekNodeByName(svItem, "image_frame_card")
		local ui_cardName = ccui.Helper:seekNodeByName(svItem, "text_name")
		local ui_cardIcon = ui_cardFrame:getChildByName("image_card")
		local ui_bench = ccui.Helper:seekNodeByName(svItem, "image_bench")
		local ui_lusckNames, ui_lucks = {}, {}
		for i = 1, 6 do
			ui_lusckNames[i] = ccui.Helper:seekNodeByName(svItem, "text_luck" .. i .. "_name")
			ui_lucks[i] = ccui.Helper:seekNodeByName(svItem, "text_luck" .. i)
			ui_lusckNames[i]:setString("")
			ui_lucks[i]:setString("")
		end
			
		local instFormationId = obj.int["1"] --阵型实例ID
		local instCardId = obj.int["3"] --卡牌实例ID
		local type = obj.int["4"] --阵型类型 1:主力,2:替补
		local dictCardId = obj.int["6"] --卡牌字典ID
		local instCardData = net.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
		local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
		local qualityId = instCardData.int["4"] --品阶ID
			
		ui_cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small))
		ui_cardName:setString(dictCardData.name)
		ui_cardIcon:loadTexture("image/" .. DictUI[tostring(dictCardData.smallUiId)].fileName)
		if type == 2 then
			ui_bench:loadTexture("ui/bz_zi02.png")
		else
			ui_bench:loadTexture("ui/bz_zi01.png")
		end
		local cardLucks = {}
		for k, objDcl in pairs(DictCardLuck) do
			if objDcl.cardId == dictCardId then
				cardLucks[#cardLucks + 1] = objDcl
			end
		end
		utils.quickSort(cardLucks, function(obj1, obj2) if obj1.id > obj2.id then return true end end)
		for key, dictLuck in pairs(cardLucks) do
			ui_lusckNames[key]:setString(dictLuck.name .. "：")
			ui_lucks[key]:setString(dictLuck.description)
			if utils.isCardLuck3v3(dictLuck, instFormationId , false , _data ) then
				ui_lusckNames[key]:setTextColor(cc.c4b(0, 68, 255, 255))
				ui_lucks[key]:setTextColor(cc.c4b(0, 68, 255, 255))
			else
				ui_lusckNames[key]:setTextColor(cc.c4b(51, 25, 4, 255))
				ui_lucks[key]:setTextColor(cc.c4b(51, 25, 4, 255))
			end
		end
	end
		
	innerHieght = innerHieght + space
	if innerHieght < ui_scrollView:getContentSize().height then
		innerHieght = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHieght))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(cc.p((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height - space))
		else
			childs[i]:setPosition(cc.p((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height - space))
		end
		prevChild = childs[i]
	end
	
end
function UIGameLuck.init()
    local btn_close = ccui.Helper:seekNodeByName( UIGameLuck.Widget , "btn_close" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )

    ui_scrollView = ccui.Helper:seekNodeByName( UIGameLuck.Widget , "view_luck_info" )
    ui_svItem = ui_scrollView:getChildByName("panel_all"):clone()
    ui_svItem:retain()
end
function UIGameLuck.setup()
    ui_scrollView:removeAllChildren()
    showAllLuck()
end
function UIGameLuck.free()
    _data = nil
end
function UIGameLuck.setData( data )
    _data = data
end