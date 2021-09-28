local count = 10000000
local id_ins = 0
function getInsId(lType)
  id_ins = (id_ins + 1) % count
  return lType * count + id_ins
end
function setIdInsZero()
  id_ins = 0
end
