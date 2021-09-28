function testProperties(object)
  Properties.extend(object)
  local protable = {}
  for i, v in ipairs(PROPERTY_LEVEL_1) do
    protable[v] = i * 1000
  end
  for i, v in ipairs(PROPERTY_LEVEL_2) do
    protable[v] = i * 1000
  end
  print("\n")
  print("-------------- 属性值 ------------")
  for i, v in ipairs(PROPERTY_LEVEL_1) do
    print(v, object:getProperty(v))
  end
  for i, v in ipairs(PROPERTY_LEVEL_2) do
    print(v, object:getProperty(v))
  end
  print("GG:", object:getProperty(PROPERTY_GenGu))
  print("LX:", object:getProperty(PROPERTY_Lingxing))
  print("LL:", object:getProperty(PROPERTY_LiLiang))
  print("MJ:", object:getProperty(PROPERTY_MinJie))
  print("HP:", object:getProperty(PROPERTY_HP))
  print("MP:", object:getProperty(PROPERTY_MP))
  print("AP:", object:getProperty(PROPERTY_AP))
  print("SP:", object:getProperty(PROPERTY_SP))
  print("---------------------------------\n")
  print("====setProperty(PROPERTY_HP,===")
  local hp = object:getProperty(PROPERTY_HP)
  hp = hp - 100
  object:setProperty(PROPERTY_HP, hp)
  print("hp:", object:getProperty(PROPERTY_HP), object.pro_HP)
  object:setProperty(PROPERTY_HP, hp + 1000)
  print("hp:", object:getProperty(PROPERTY_HP), object.pro_HP)
  print("===============================")
  print("生产一个roleai")
  local hero = CHeroAI.new()
  print("id:", hero:getId())
  print("type:", hero:getType())
  print("hp:", hero:getProperty(PROPERTY_HP))
  hero:setProperty(PROPERTY_HP, 5000)
  print("hp:", hero:getProperty(PROPERTY_HP))
  print("===============================\n")
  print("----------------------------------")
  print("Name", hero:getProperty(PROPERTY_NAME), hero.pro_NAME, hero.pro_NAME)
  hero:setProperty(PROPERTY_NAME, "大神呀呀")
  print("Name", hero:getProperty(PROPERTY_NAME), hero.pro_NAME, hero.pro_NAME)
  print("----------------------------------")
end
