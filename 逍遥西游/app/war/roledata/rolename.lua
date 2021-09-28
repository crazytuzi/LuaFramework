local GetRandomName = function(xingList, mingList)
  local rd_Xing = xingList[math.random(1, #xingList)]
  local rd_Ming = mingList[math.random(1, #mingList)]
  local name = rd_Xing .. rd_Ming
  name = string.gsub(name, " ", "")
  return name
end
function GetRandomName_Male()
  return GetRandomName(data_Name.xing, data_Name.ming_nan)
end
function GetRandomName_Female()
  return GetRandomName(data_Name.xing, data_Name.ming_nv)
end
