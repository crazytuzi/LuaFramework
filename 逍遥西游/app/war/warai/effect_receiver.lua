if not EffectReceiver then
  EffectReceiver = {}
end
function EffectReceiver.extend(object)
  object.effects_ = {}
  function object:getEffects()
    return object.effects_
  end
  function object:setEffects(effects_)
    object.effects_ = effects_
  end
end
