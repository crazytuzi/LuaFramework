local rtn = {}

local math = math
local os = os
local coroutine = coroutine
local string = string
local table = table
local io = io

function rtn.getSandbox()
  local env = {}
  env.assert = assert
  env.error = error
  env.ipairs = ipairs
  env.next      = next
  env.pairs     = pairs
  env.pcall     = pcall
  env.print     = print
  env.select    = select
  env.tonumber  = tonumber
  env.tostring  = tostring
  env.type      = type
  env.unpack    = unpack
  env._VERSION  = _VERSION
  env.xpcall    = xpcall

  env.coroutine = {}
  env.coroutine.create = coroutine.create
  env.coroutine.resume = coroutine.resume
  env.coroutine.running = coroutine.running
  env.coroutine.status = coroutine.status
  env.coroutine.wrap = coroutine.wrap
  env.coroutine.yield = coroutine.yield

  env.string = {}
  env.string.byte = string.byte
  env.string.char = string.char
  env.string.find =   string.find
  env.string.format  = string.format 
  env.string.gmatch  = string.gmatch 
  env.string.gsub  = string.gsub 
  env.string.len  = string.len 
  env.string.lower  = string.lower 
  env.string.match  = string.match 
  env.string.rep  = string.rep 
  env.string.reverse  = string.reverse 
  env.string.sub  = string.sub 
  env.string.upper  = string.upper 

  env.table  = {}
  env.table.insert = table.insert
  env.table.maxn = table.maxn
  env.table.remove = table.remove
  env.table.sort = table.sort
  env.table.concat = table.concat
  env.table.len = table.len

  env.math  = {}
  env.math.abs  = math.abs 
  env.math.acos  = math.acos 
  env.math.asin  = math.asin 
  env.math.atan  = math.atan 
  env.math.atan2  = math.atan2 
  env.math.cos  = math.cos 
  env.math.cosh  = math.cosh 
  env.math.deg  = math.deg 
  env.math.exp  = math.exp 
  env.math.floor = function(d)
    return math.floor(d+0.000001)
  end
  env.math.ceil = function(d)
    return math.ceil(d-0.000001)
  end
  env.math.fmod  = math.fmod 
  env.math.frexp = math.frexp
  env.math.huge  = math.huge 
  env.math.ldexp  = math.ldexp 
  env.math.log  = math.log 
  env.math.log10  = math.log10 
  env.math.max  = math.max 
  env.math.min  = math.min 
  env.math.modf  = math.modf
  env.math.pi  = math.pi 
  env.math.pow  = math.pow 
  env.math.rad  = math.rad 
  env.math.random  = math.random 
  env.math.randomseed  = math.randomseed 
  env.math.sin  = math.sin 
  env.math.sinh  = math.sinh 
  env.math.sqrt  = math.sqrt
  env.math.tan  = math.tan
  env.math.tanh  = math.tanh
  env.math.round  = Mathf.Round
  env.math.clamp  = Mathf.Clamp

  env.io  =  {}
  env.io.read   = io.read
  env.io.popen  = io.popen
  env.io.write   = io.write 
  env.io.flush   = io.flush
  env.io.type   = io.type
  env.io.open   = io.open

  env.os = {}
  env.os.clock  = os.clock 
  env.os.difftime  = os.difftime 
  env.os.time  = os.time
  env.os.date  = os.date
  env.os.execute = os.execute

  return env
end

return rtn
