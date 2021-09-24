local kafka = require('kafka_lua')
  
--local broker_list = '127.0.0.1:9092';
local broker_list = '192.168.8.209:9092';
  
local function init_kafka(server,port)
    local broker_list = server..':'..port

    -- config
    local ret = kafka.conf_set('metadata.broker.list', broker_list)
    if ret ~= 'ok' then
            return ret
    end

    -- none\gzip\snappy
    ret = kafka.conf_set('compression.codec', 'gzip')
    if ret ~= 'ok' then
            return ret
    end

    -- init producer handle
    ret = kafka.init_producer("game_server")
    if ret ~= 'ok' then
      return ret
    end

    return 'ok'
end

local function produce(data,appId)
  if type(data) == 'table' then    
    return kafka.produce(json.encode(data),appId);
  end
end

-- call this when server shutdown
local function destroyed(ts)
  kafka.wait_destroyed(ts)
end

local methods = {
  produce = produce,
  destroyed=destroyed,
}

local new = function(server, port)
  assert(init_kafka(server,port) == 'ok')
  return setmetatable({}, {__index = methods})
end

return {
  new = new,
}
