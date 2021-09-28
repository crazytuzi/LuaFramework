local NumberScaleChanger = class("")

function NumberScaleChanger:ctor(targetContainer, sourceValue, targetValue, setValueFunc)
    self._setValueFunc = setValueFunc
    self._targetValue = targetValue
    self._targetContainer = targetContainer
    if  sourceValue ==  targetValue then
        self:stop()
        return
    end  


    local delayAction =  CCDelayTime:create(0.4)

    local sequence = transition.sequence({
        delayAction,
        CCCallFunc:create(
            function()
                --一边放大, 一边变化数字, 然后缩回去
                local scaleToAction = CCScaleTo:create(tonum(0.2), 1.3, 1.3)
                targetContainer:runAction(scaleToAction)


                local delta = math.floor( (targetValue - sourceValue) / 15 )
                --print("delta-" .. delta)


                if math.abs(delta) >= 1 then                   
                    self._timer = GlobalFunc.addTimer(0.03, function() 
                        sourceValue = sourceValue + delta
                        local arrived = false

                        if delta > 0 and sourceValue >= targetValue then
                            arrived = true
                            sourceValue = targetValue
                        elseif delta < 0 and sourceValue <= targetValue then
                            arrived = true
                            sourceValue = targetValue
                        end

                        setValueFunc(sourceValue)
                        if arrived then
                            self:_stopTimer()

                            local scaleBackAction = CCScaleTo:create(tonum(0.1), 1, 1)
                            targetContainer:stopAllActions()
                            local sequence2 = transition.sequence(
                                {
                                    scaleBackAction,
                                    CCCallFunc:create(function() 
                                        self:stop()
                                    end)
                                }   
                            )
                            targetContainer:runAction(sequence2)

                        end

                     end)
                else
                    self:stop()
                end

            end

        )
        
    })

    targetContainer:runAction(sequence)
end




function NumberScaleChanger:_stopTimer()
    if self._timer ~= nil then
        GlobalFunc.removeTimer(self._timer)
        self._timer  = nil
    end
end

function NumberScaleChanger:stop()
    self:_stopTimer()
    if self._targetContainer then
        self._targetContainer:stopAllActions()
        self._targetContainer:setScale(1)

    end
    
    if self._setValueFunc then
        self._setValueFunc(self._targetValue)
    end

    
    self._setValueFunc = nil
    self._targetContainer = nil
end


return NumberScaleChanger


