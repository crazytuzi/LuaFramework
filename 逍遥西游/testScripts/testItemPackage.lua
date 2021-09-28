local CTestItemPackage = class("CTestItemPackage")
function CTestItemPackage:ctor()
  PackageExtend.extend(self)
end
g_TestItemPackage = CTestItemPackage.new()
g_TempNum = 0
function getOneId()
  g_TempNum = g_TempNum + 1
  return g_TempNum
end
function createMyDrug()
  for itemId, itemNum in pairs({
    [10001] = 8,
    [10002] = 10,
    [10003] = 10,
    [10004] = 10,
    [10005] = 10,
    [10006] = 10
  }) do
    local tempId = getOneId()
    g_TestItemPackage:SetOneItem(tempId, itemId, {})
    local item = g_TestItemPackage:GetOneItem(tempId)
    item:setProperty(ITEM_PRO_NUM, itemNum)
  end
end
