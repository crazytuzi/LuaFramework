
local NormalButton = {}

NormalButton.TYPE_NORMAL = 1
NormalButton.TYPE_BUBBLE = 2
NormalButton.TYPE_DARKER = 3
local btnContentsize = nil
-- create normal button
function NormalButton.new(params)
    local listener = params.listener
    local button -- pre-reference
    print(params.btnType)
    params.btnType = params.btnType or NormalButton.TYPE_NORMAL
    params.listener = function(tag)
        -- game.GameAudio:playSound(GAME_SFX.tapButton)
        if params.prepare then
            params.prepare()
        end

        button:setEnabled(false)
        local function normal1(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            local scaleX = button:getScaleX() * (size.width + offset) / size.width
            local scaleY = button:getScaleY() * (size.height + offset) / size.height
            -- button:runAction(transition.sequence({                
            --     CCScaleTo:create(time,scaleX,scaleY),
            --     -- CCScaleTo:create(time,scaleX*1.1,scaleY*1.1),
            --     -- CCScaleTo:create(time,scaleX,scaleY),
            --     CCCallFunc:create(onComplete)
            --     }))
            transition.scaleTo(button, {
                scaleX     = scaleX,
                scaleY     = scaleY,
                time       = time,
                onComplete = onComplete,
            })
            if(offset < 0) then
                button:setOpacity(150)
            else
                button:setOpacity(255)
            end
            
        end

        local function normal2(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            -- transition.fadeIn(button, {time = time})
            -- transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
            
        end
        local function zoom1(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            local scaleX = button:getScaleX() * (size.width + offset) / size.width
            local scaleY = button:getScaleY() * (size.height - offset) / size.height

            transition.moveTo(button, {y = y - offset, time = time})
            transition.scaleTo(button, {
                scaleX     = scaleX,
                scaleY     = scaleY,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function zoom2(offset, time, onComplete)
            local x, y = button:getPosition()
            local size = button:getContentSize()

            transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function dark1( offset, time, onComplete )
            local x, y = button:getPosition()
            local size = button:getContentSize()

            button:setOpacity(100)
            -- transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 0.9,
                scaleY     = 0.9,
                time       = time,
                onComplete = onComplete,
            })
        end 
        local function dark2( offset, time, onComplete )
            local x, y = button:getPosition()
            local size = button:getContentSize()

            button:setOpacity(255)
            -- transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 1.1,
                scaleY     = 1.1,
                time       = time,
                onComplete = onComplete,
            })
        end 
        local function dark3( offset, time, onComplete )
            local x, y = button:getPosition()
            local size = button:getContentSize()

            button:setOpacity(255)
            -- transition.moveTo(button, {y = y + offset, time = time / 2})
            transition.scaleTo(button, {
                scaleX     = 1.0,
                scaleY     = 1.0,
                time       = time,
                onComplete = onComplete,
            })
        end 

        -- =================================================

        -- if not tolua.isnull(button:getParent() ) then
        --     print(button:getParent())
        --     button:getParent():setEnabled(false)
        -- end

        if(params.btnType == NormalButton.TYPE_NORMAL)  and button.actioning == false then
            button.actioning = true
            normal1(-30, 0.11, function()
                   normal1(30, 0.08, function()
                        normal1(15, 0.05, function()
                            normal2(30, 0.08, function()
                                button:getParent():setEnabled(true)
                                listener(tag)
                                button.actioning = false
                                button:setEnabled(true)
                            end)
                        end)

                   end)
            end)
        elseif(params.btnType == NormalButton.TYPE_BUBBLE)   and button.actioning == false then
            button.actioning = true
            zoom1(40, 0.08, function()
                zoom2(40, 0.09, function()
                    zoom1(20, 0.10, function()
                        zoom2(20, 0.11, function()
                            button:getParent():setEnabled(true)
                            listener(tag)
                            button.actioning = false
                            button:setEnabled(true)
                        end)
                    end)
                end)
            end)
        elseif(params.btnType == NormalButton.TYPE_DARKER)   and button.actioning == false then
            button.actioning = true
            dark2(40,0.08, function ( ... )
                dark1(40,0.1,function()
                    dark3(40,0.08,function ( ... )
                        -- button:getParent():setEnabled(true)
                        listener(tag)
                        button.actioning = false
                        button:setEnabled(true)
                    end)
                end)
            end)
        end
        
    end -- listener = function(tag)

    button = ui.newImageMenuItem(params)
    btnContentsize = button:getContentSize()
    button.actioning = false
    return button
end

function NormalButton.getContentSize( ... )
    return btnContentsize
end

return NormalButton
