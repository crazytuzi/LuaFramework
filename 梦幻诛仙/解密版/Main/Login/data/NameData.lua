local NameData = {}
local NAME_RES_PATH = "data/luacfg/name.lua"
function NameData.LoadData()
  if NameData.data == nil then
    NameData.data = assert(loadfile(NAME_RES_PATH))()
  end
end
function NameData.ClearData()
  NameData.data = nil
end
function NameData.GetRandomMaleName()
  NameData.LoadData()
  local familyName = NameData.GenRandomFamilyName()
  local maleName = NameData.GenRandomMaleName()
  return familyName .. maleName
end
function NameData.GetRandomFemaleName()
  NameData.LoadData()
  local familyName = NameData.GenRandomFamilyName()
  local femaleName = NameData.GenRandomFemaleName()
  return familyName .. femaleName
end
function NameData.GenRandomFamilyName(rootStruct)
  local nameListName = NameData.GenRandomNameListName()
  local familyNameList = NameData.data.familyname[nameListName]
  local familyNameListSize = #familyNameList
  local randomNameIndex = math.random(1, familyNameListSize)
  local value = familyNameList[randomNameIndex]
  return value
end
function NameData.GenRandomMaleName(rootStruct)
  local nameListName = NameData.GenRandomNameListName()
  local maleNameList = NameData.data.name.male[nameListName]
  local maleNameListSize = #maleNameList
  local randomNameIndex = math.random(1, maleNameListSize)
  local value = maleNameList[randomNameIndex]
  return value
end
function NameData.GenRandomFemaleName(rootStruct)
  local nameListName = NameData.GenRandomNameListName()
  local femaleNameList = NameData.data.name.female[nameListName]
  local femaleNameListSize = #femaleNameList
  local randomNameIndex = math.random(1, femaleNameListSize)
  local value = femaleNameList[randomNameIndex]
  return value
end
function NameData.GenRandomNameListName()
  if math.random(1, 2) == 1 then
    return "single"
  else
    return "multiple"
  end
end
return NameData
