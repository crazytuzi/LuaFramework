local testMemoryLeaks = {}
function testMemoryLeaks.detect()
  local testMemoryLeaks = require("testScripts.testMemoryLeaks")
  testMemoryLeaks.start()
end
