local warchase = {}
function warchase.extend(object)
  function object:isChasing()
    return object.m_ChasingFlag
  end
  function object:startChasing()
    if object.m_ChasingFlag ~= true then
      print("---->>> 恢复标志位异常 startChasing")
      return
    end
    print("<chasing> startChasing")
    object:chaseWarUiTime()
  end
  function object:endChasing()
    print("<chasing> endChasing")
    object.m_ChasingFlag = false
    object.m_ChasingTime = 0
    object.m_ChasingRound = nil
  end
  function object:revertLocalWar()
    print("<chasing> revertLocalWar")
    RevertWarWithLocalData(self.m_WarDataCache)
  end
  function object:chaseWarUiTime()
    if object.m_ChasingFlag ~= true then
      print("---->>> 恢复标志位异常 chaseWarUiTime")
      return
    end
    print("<chasing> chaseWarUiTime", object.m_CurrRound, object.m_ChasingRound, object.m_ChasingTime, PerRoundTime)
    if object.m_CurrRound < object.m_ChasingRound then
      print("<chasing> 直接跳过")
      object:chaseNextRound()
    elseif object.m_EndRestSequenceWhenUiShow ~= true then
      if object.m_ChasingTime < PerRoundTime then
        print("<chasing> StartOneRoundFightSetting")
        object:SendOneRoundAnalyzeFinishToAI(object:getWarID(), object:getSingleWarFlag(), object.m_CurrRound)
        object.m_WaruiObj:StartOneRoundFightSetting(object.m_CurrRound + 1, object.m_ChasingTime)
        object:endChasing()
      else
        print("<chasing> EndOneRoundFightSetting")
        object:SendOneRoundAnalyzeFinishToAI(object:getWarID(), object:getSingleWarFlag(), object.m_CurrRound)
        object.m_WaruiObj:SetRoundNum(object.m_CurrRound + 1)
        object.m_WaruiObj:EndOneRoundFightSetting(true)
        object:endChasing()
      end
    else
      object.m_EndRestSequenceWhenUiShow = false
      object:endChasing()
    end
  end
  function object:chaseNextRound()
    if object.m_ChasingFlag ~= true then
      print("---->>> 恢复标志位异常 chaseNextRound")
      return
    end
    print("<chasing> chaseNextRound", object.m_CurrRound, object.m_ChasingRound)
    if object.m_CurrRound >= object.m_ChasingRound then
      print("<chasing> chaseNextRound 结束")
      return
    end
    if object.m_CurrRound == object.m_ChasingRound - 1 then
      print("<chasing> chaseNextRound object.m_Chasing_Force = true")
      object.m_Chasing_Force = false
    else
      print("<chasing> chaseNextRound object.m_Chasing_Force = false")
      object.m_Chasing_Force = true
    end
    if object.m_CurrRound > 0 and object.m_CurrRound % 10 == 0 then
      object:runAction(transition.sequence({
        CCDelayTime:create(0),
        CCCallFunc:create(function()
          object:readyNextRound()
        end)
      }))
    else
      object:readyNextRound()
    end
  end
end
return warchase
