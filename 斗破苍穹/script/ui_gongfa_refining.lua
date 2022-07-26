require"Lang"
UIGongfaRefining = { }
local _instMagicId = nil
local _cardImagePath = nil
local _cardIconPoint = nil
local needThing = nil
local _data1 = nil
local _data2 = nil
local function effectRe()
    local effects = {}
    local childs = UIManager.uiLayer:getChildren()
	local function effectCallback()
		local animation = ActionManager.getUIAnimation(2, function(armature) 
			UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), 
						cc.CallFunc:create(function() armature:removeFromParent() 
                        for key, obj in pairs(childs) do
			                obj:setEnabled(true)
		                end
                        UIGongfaRefining.setup()
                        UIManager.flushWidget( UIGongfaInfo )
                        UIManager.flushWidget( UIBagGongFa )
                        UIManager.flushWidget( UILineup )
                        end)))
		end)
        local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "anim_event" then
				animation:getAnimation():setSpeedScale(1.2)
			elseif evt == "anim_event1" then
				animation:getAnimation():setSpeedScale(1)
			end
		end
        animation:getAnimation():setFrameEventCallFunc(onFrameEvent)
		if _cardImagePath then
			animation:getBone("renwu"):addDisplay(ccs.Skin:create(_cardImagePath), 0)
			animation:getBone("renwu2"):addDisplay(ccs.Skin:create(_cardImagePath), 0)
		end
        
		animation:setPosition( cc.p( _cardIconPoint.x + 150 , _cardIconPoint.y - 170 ))
		UIGongfaRefining.Widget:addChild(animation, 1000)
		for key, obj in pairs(effects) do
			obj:removeFromParent()
		end
	end
--    for key, obj in pairs(childs) do
--		obj:setEnabled(false)
--    end
    local image_equipment = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_equipment" )
    local image_di_cost = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_di_cost" )
    local _posOffX = _cardIconPoint.x - image_equipment:getPositionX() + image_di_cost:getPositionX() - image_di_cost:getContentSize().width / 2
    local _posOffY = _cardIconPoint.y - image_equipment:getPositionY() + image_di_cost:getPositionY() - image_di_cost:getContentSize().height / 2
    for i = 1, #needThing do
		local btnImg = ccui.Helper:seekNodeByName(UIGongfaRefining.Widget, "image_frame_good" .. i)		
		effects[#effects + 1] = cc.ParticleSystemQuad:create("particle/ui_anim2_effect.plist")
		effects[i]:setPosition(cc.p( _posOffX + btnImg:getPositionX(), _posOffY + btnImg:getPositionY()))
		UIGongfaRefining.Widget:addChild(effects[i], 1000)
		if i == #needThing then
			effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _cardIconPoint), cc.CallFunc:create(effectCallback)))
		else
			effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _cardIconPoint)))
		end
	end
end
local function netCallBack( pack )
    UIManager.showToast(Lang.ui_gongfa_refining1)
    effectRe()   
end
local function netSendData()
    UIManager.showLoading()
    local sendData = {
        header = StaticMsgRule.magicAdvance ,
        msgdata = {
            int = {
                instPlayerMagicId = _instMagicId
            }
        }
    }
    netSendPackage( sendData , netCallBack )
end
function UIGongfaRefining.init()
    local btn_close = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "btn_close" )
    local btn_refining = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "btn_refining" )
    local image_frame_good1 = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_frame_good1" )
    local image_frame_good2 = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_frame_good2" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_refining then
               -- cclog("精炼")
                netSendData()
            elseif sender == image_frame_good1 then
                utils.storyDropOutDialog( _data1 , 7 )
            elseif sender == image_frame_good2 then
                utils.storyDropOutDialog( _data2 , 7 )
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_refining:setPressedActionEnabled( true )
    btn_refining:addTouchEventListener( onEvent )

    image_frame_good1:setTouchEnabled( true )
    image_frame_good1:addTouchEventListener( onEvent )
    image_frame_good2:setTouchEnabled( true )
    image_frame_good2:addTouchEventListener( onEvent )
end

function UIGongfaRefining.setup()
    if _instMagicId then
        local instMagicData = net.InstPlayerMagic[tostring(_instMagicId)]
        local dictMagicId = instMagicData.int["3"]
        local magicType = instMagicData.int["4"]
        local magicQualityId = instMagicData.int["5"]
        local magicLevleId = instMagicData.int["6"]

        local dictMagicData = DictMagic[tostring(dictMagicId)]
        local magicLv = DictMagicLevel[tostring(magicLevleId)].level

        local magicRefiningLevel = 0
        local magicAdvanceId = instMagicData.int["10"]
        if magicAdvanceId and magicAdvanceId > 0 then
            magicRefiningLevel = DictMagicrefining[tostring(magicAdvanceId)].starLevel
        end
        
        local image_equipment = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_equipment" )
        _cardImagePath = "image/" .. DictUI[tostring(dictMagicData.bigUiId)].fileName
        image_equipment:loadTexture("image/" .. DictUI[tostring(dictMagicData.bigUiId)].fileName)
        local image_di_name = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_di_name" )
        image_di_name:getChildByName("text_name"):setString(dictMagicData.name)

        local image_basemap = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_basemap" )
        local image_di_l = image_basemap:getChildByName( "image_di_l" )
        local image_di_r = image_di_l:getChildByName( "image_di_r" )
        _cardIconPoint = cc.p( image_basemap:getPositionX() - image_basemap:getContentSize().width / 2 + 
                               image_di_l:getPositionX() - image_di_l:getContentSize().width / 2 + 
                               image_di_r:getPositionX() - image_di_r:getContentSize().width / 2 +
                               image_equipment:getPositionX()  , 
                               image_basemap:getPositionY() - image_basemap:getContentSize().height / 2 + 
                               image_di_l:getPositionY() - image_di_l:getContentSize().height / 2 + 
                               image_di_r:getPositionY() - image_di_r:getContentSize().height / 2 +
                               image_equipment:getPositionY() 
                             )

        local magic_refining = {}
        for key  ,value in pairs( DictMagicrefining ) do
             if dictMagicId == value.MagicId then
                 magic_refining[value.starLevel] = value.id
             end
        end
        local image_di_add = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_di_add" )
        for i = 1 , 5 do
            local text_star = image_di_add:getChildByName("text_star"..i)
            local text_add = image_di_add:getChildByName("text_add"..i)
            local text_lv = image_di_add:getChildByName("text_lv"..i)
            if magic_refining[ i ] then
                local _data = DictMagicrefining[ tostring( magic_refining[i] ) ]
                text_add:setString(DictFightProp[tostring(_data.fightPropId)].name .. " +" .. _data.value)
                text_lv:setString(Lang.ui_gongfa_refining2.._data.maxStrengthen..Lang.ui_gongfa_refining3)
            else
                text_star:setVisible( fasle )
                text_add:setVisible( false )
                text_lv:setVisible( false )
            end
            local textColor = cc.c3b( 0 , 246 , 255 )
            if i <= magicRefiningLevel then
                textColor = cc.c3b( 0 , 246 , 255 )
            else
                textColor = cc.c3b( 191 , 191 , 191 )
            end
            text_star:setTextColor( textColor )
            text_add:setTextColor( textColor )
            text_lv:setTextColor( textColor )
        end

        for i = 1 , 5 do
            local image_star = image_di_name:getChildByName("image_star"..i)
            if i <= #magic_refining then
                if i <= magicRefiningLevel then
                    image_star:loadTexture("ui/star01.png")
                else
                    image_star:loadTexture("ui/star02.png")
                end
            else
                image_star:setVisible( false )
            end
        end
        
        needThing = nil
        if magicRefiningLevel >= #magic_refining then
        else
            needThing = utils.stringSplit( DictMagicrefining[tostring( magic_refining[magicRefiningLevel + 1] )].contions , ";" )
        end
        
        for i = 1 , 2 do
            local image_frame_good = ccui.Helper:seekNodeByName( UIGongfaRefining.Widget , "image_frame_good"..i )
            if needThing and needThing[ i ] then        
                image_frame_good:setVisible( true )
                local data = utils.getItemProp( needThing[i] )  
                if i == 1 then
                    _data1 = { smallUiId = DictMagic[tostring(data.tableFieldId)].smallUiId , name = data.name , outBarrier = "" }
                elseif i == 2 then
                    _data2 = { smallUiId = DictMagic[tostring(data.tableFieldId)].smallUiId , name = data.name , outBarrier = "" }
                end 
                local num = 0 
                if net.InstPlayerMagic then
                    for key, obj in pairs(net.InstPlayerMagic) do
                      --  cclog("aaa :"..obj.int["1"] .. "  ".._instMagicId.."  "..data.tableFieldId.."  "..obj.int["3"].."  "..obj.int["8"])
                        if ( obj.int["1"] == _instMagicId ) then
                        elseif obj.int["8"] == 0 and obj.int["3"] == data.tableFieldId then 
                       --     cclog("aaa111 :"..obj.int["1"] .. "  ".._instMagicId)
                            num = num + 1
                        end
                    end
                end
                image_frame_good:loadTexture( data.frameIcon )
                if i == 1 then
                    image_frame_good:getChildByName("image_stone"):loadTexture( data.smallIcon )
                elseif i == 2 then
                    image_frame_good:getChildByName("image_good"):loadTexture( data.smallIcon )
                end
                image_frame_good:getChildByName("text_name"):setString( data.name )
                image_frame_good:getChildByName("text_numbr"):setString( num .. "/" .. data.count )
            else
                image_frame_good:setVisible( false )
            end
        end
    end
end

function UIGongfaRefining.free()
    _instMagicId = nil
    _data1 = nil
    _data2 = nil
    _cardImagePath = nil
    _cardIconPoint = nil
    needThing = nil
end

function UIGongfaRefining.setInstMagicId(instMagicId)
   -- cclog("instMagicId : "..instMagicId)
    _instMagicId = instMagicId
end
