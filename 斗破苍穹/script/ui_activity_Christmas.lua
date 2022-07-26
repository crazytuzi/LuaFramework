require"Lang"
UIActivityChristmas = {}
local _countF = nil
local _countS = nil
local _type = nil
local function getAnimation( uiAnimId , uiAnimName )
    local animPath = "ani/ui_anim/ui_anim" .. uiAnimId .. "/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    animation:getAnimation():play( "ui_anim" .. uiAnimId .. "_"..uiAnimName )
    return animation
end
---@flag : 0表示坐下,1表示右上
local function myPathFun(controlX, controlY, w, time, flag)
--	local time = 0.5
	if flag == 0 then
		local bezier1 = {
			cc.p(-controlX, 0),
			cc.p(-controlX, controlY),
			cc.p(0, controlY),
		}
		local bezierBy1 = cc.BezierBy:create(time, bezier1)
		local move1 = cc.MoveBy:create(time, cc.p(w, 0))
		local bezier2 = {
			cc.p(controlX, 0),
			cc.p(controlX, -controlY),
			cc.p(0, -controlY),
		}
		local bezierBy2 = cc.BezierBy:create(time, bezier2)
		local move2 = cc.MoveBy:create(time, cc.p(-w, 0))
		local path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
		if w == 0 then
			path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, bezierBy2))
		end
		return path
	elseif flag == 1 then
		local bezier1 = {
			cc.p(controlX, 0),
			cc.p(controlX, -controlY),
			cc.p(0, -controlY),
		}
		local bezierBy1 = cc.BezierBy:create(time, bezier1)
		local move1 = cc.MoveBy:create(time, cc.p(-w, 0))
		local bezier2 = {
			cc.p(-controlX, 0),
			cc.p(-controlX, controlY),
			cc.p(0, controlY),
		}
		local bezierBy2 = cc.BezierBy:create(time, bezier2)
		local move2 = cc.MoveBy:create(time, cc.p(w, 0))
		local path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, move1, bezierBy2, move2))
		if w == 0 then
			path = cc.RepeatForever:create(cc.Sequence:create(bezierBy1, bezierBy2))
		end
		return path
	end
end
local function addPillEffect(node , flag , offX )
    if node:getChildByName("effect1") then
        node:getChildByName("effect1"):removeFromParent()
    end
    if node:getChildByName("effect2") then
        node:getChildByName("effect2"):removeFromParent()
    end
    if flag then
	    for _i = 1, 2 do
		    local effect = cc.ParticleSystemQuad:create("particle/ui_anim8_effect.plist")
            effect:setName("effect".._i )
		    node:addChild(effect)
		    effect:setPositionType(cc.POSITION_TYPE_RELATIVE)
		    if _i == 1 then
            --    effect:setScale( 1.4 )
			    effect:setPosition(cc.p(node:getContentSize().width / 2 + offX , -20))
			    effect:runAction(myPathFun(node:getContentSize().height / 2 + 60 , node:getContentSize().height + 40 , 0, 0.5, 0))
		    else
            --    effect:setScale( 1.4 )
			    effect:setPosition(cc.p(node:getContentSize().width / 2 + offX , node:getContentSize().height + 20 ))
			    effect:runAction(myPathFun(node:getContentSize().height / 2 + 60 , node:getContentSize().height + 40, 0, 0.5, 1))
		    end
	    end
    end
end
function freshData()
    local text_hand = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "text_hand" )
    text_hand:setString(Lang.ui_activity_Christmas1.._countF..Lang.ui_activity_Christmas2)
    local panel_hand = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "panel_hand" )
    if _countF > 0 then
        addPillEffect(panel_hand, true , 0 )
      --  utils.addFrameParticle( panel_hand , true , 1.4 , false , -40 , 0 )
    else
        addPillEffect(panel_hand , false )
      --  utils.addFrameParticle( panel_hand , false )
    end

    local text_box = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "text_box" )   
    local panel_box = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "panel_box" )
    if _countS > 0 then
        text_box:setString(Lang.ui_activity_Christmas3)
        addPillEffect(panel_box, true , 20 )
      --  utils.addFrameParticle( panel_box , true , 1.4 )
    else
        text_box:setString(Lang.ui_activity_Christmas4)
        addPillEffect(panel_box , false , 20 )
      --  utils.addFrameParticle( panel_box , false )
    end
end
local function getEffect( goodS )
    local goods = utils.stringSplit( goodS , ";" )
    UIAwardGet.setOperateType(UIAwardGet.operateType.award, goods)
   	UIManager.pushScene("ui_award_get")
end
local function netCallBack( pack )
    _countF = pack.msgdata.int.first
    _countS = pack.msgdata.int.second
    cclog("_countF ".._countF .. "  ".._countS)
    freshData()
    if _type == 1 or _type == 2 then
        local goodStr = pack.msgdata.string["1"]
        getEffect( goodStr )
    end
end
--int.type = 圣诞活动类型 (0.进入活动界面  1.开启拼手气礼盒  2.开启圣诞礼盒)

local function netSendData()
    cclog("_type :".._type)
    UIManager.showLoading()
    local sendData = {
        header = StaticMsgRule.christmasDay ,
        msgdata = {
            int = {
                type = _type
            }
        }
    }
    netSendPackage(sendData , netCallBack)
end
local function openEffect()      
    netSendData()
end

local function getSnowP()
    local emitter = cc.ParticleSnow:createWithTotalParticles(100)
      --  emitter:setTag(weather)
        emitter:setPosition(display.width / 2, 0)
        emitter:setLife(6)
        emitter:setLifeVar(2)

      --  emitter:setRotatePerSecond( 360 )
      --  emitter:setRotatePerSecondVar( 10 )
        -- gravity
        emitter:setGravity(cc.p(0, -8))

        emitter:setStartSize(20)

        -- speed of particles
        emitter:setSpeed(130)
        emitter:setSpeedVar(30)

        local startColor = emitter:getStartColor()
        startColor.r = 0.9
        startColor.g = 0.9
        startColor.b = 0.9
        emitter:setStartColor(startColor)

        local startColorVar = emitter:getStartColorVar()
        startColorVar.b = 0.1
        emitter:setStartColorVar(startColorVar)

        emitter:setEmissionRate(emitter:getTotalParticles() / emitter:getLife())
        emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("image/snow.png"))
        return emitter
end

function UIActivityChristmas.init()
    local panel_hand = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "panel_hand" )
    local panel_box = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "panel_box" )
    local anim_hand = getAnimation( 62 , 1 )
    anim_hand:setPosition( cc.p( panel_hand:getContentSize().width / 2 , panel_hand:getContentSize().height / 2 ) )
    panel_hand:addChild( anim_hand )
    local anim_box = getAnimation( 62 , 2 )
    anim_box:setPosition( cc.p( panel_box:getContentSize().width / 2 , panel_box:getContentSize().height / 2 ) )
    panel_box:addChild( anim_box )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == panel_hand then
                --cclog("抓手气")
                _type = 1
               openEffect()
            elseif sender == panel_box then
                --cclog("宝箱")
                _type = 2
                openEffect()
            end
        end
    end
    panel_hand:setTouchEnabled( true )
    panel_hand:addTouchEventListener( onEvent )
    panel_box:setTouchEnabled( true )
    panel_box:addTouchEventListener( onEvent )

    local particle1 = getSnowP() --cc.ParticleSystemQuad:create("particle/snow/ui_anim_snow_1.plist" )
        --particle1:setPositionType(cc.POSITION_TYPE_RELATIVE)
   -- particle1:setScale( 1.2 )
    particle1:setPosition( cc.p( UIManager.screenSize.width / 2 , UIManager.screenSize.height - 120 ) )
    UIActivityChristmas.Widget:addChild(particle1 , 10 )

    local text_hand = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "text_hand" )
    text_hand:setPosition( cc.p( text_hand:getPositionX() , text_hand:getPositionY() - 45 ) )
    local text_box = ccui.Helper:seekNodeByName( UIActivityChristmas.Widget , "text_box" ) 
    text_box:setPosition( cc.p( text_box:getPositionX() , text_box:getPositionY() - 45 ) )

    --礼包按钮
--    local imageLibao = ccui.ImageView:create("ui/libao.png")
--    imageLibao:setPosition( cc.p( 476 , 310 ) )
--    UIActivityChristmas.Widget:addChild( imageLibao )
end
function UIActivityChristmas.setup()
    _type = 0
    netSendData()
 --   AudioEngine.playMusic("sound/christmas.mp3", true)
end
function UIActivityChristmas.free()
    _countF = nil
    _countS = nil
    _type = nil
  --  AudioEngine.playMusic("sound/bg_music.mp3", true)
end

function UIActivityChristmas.onActivity( params )

end

