local testMapRender = {}
local allShapeIds = {}
local testPlayerId = 100000000
function testMapRender.loadOneRole()
  if #allShapeIds == 0 then
    for sId, v in pairs(data_Shape) do
      allShapeIds[#allShapeIds + 1] = sId
    end
  end
  local mapView = g_MapMgr:getMapViewIns()
  if mapView then
    local localRole = mapView.m_LocalRole
    if localRole then
      local x, y = localRole:getPosition()
      local hw = math.floor(display.width / 2)
      local hh = math.floor(display.height / 2)
      local x = x + math.random(-hw, hw)
      local y = y + math.random(-hh, hh)
      local roleTypeId = allShapeIds[math.random(1, #allShapeIds)]
      testPlayerId = testPlayerId + 1
      local role = MapPlayerShape.new(testPlayerId, roleTypeId, handler(mapView, mapView.RolePosChanged))
      mapView:addChild(role, mapView.m_ZOrder.role)
      mapView:createNameForShape(role, string.format("test:%d", testPlayerId), ccc3(225, 255, 0), 0)
      role:setPosition(ccp(x, y))
    end
  end
end
return testMapRender
