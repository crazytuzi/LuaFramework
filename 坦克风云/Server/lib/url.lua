module(...,package.seeall)
local url = {
   url_escape = url_escape,
   url_unescape = url_unescape,
   parse_url = parse_url,
   parse_str = parse_str
}
function url:url_escape(str)
   local pattern = "^A-Za-z0-9%-%._~"
   str = str:gsub("[" .. pattern .. "]",function(c) return string.format("%%%02X",string.byte(c)) end)
   return str
end

function url:url_unescape(str)
   str = str:gsub("%%(%x%x)",function(x) return string.char(tonumber(x,16)) end)
   return str
end

function url:parse_url(url)
   local tb = {}
   local dot = string.find(url,":")
   tb['scheme'] = string.sub(url,1,dot)
   local slash = string.find(url,"/",dot+3)
   local userinfo = string.find(url,"@",dot,slash)
   
   if userinfo ~= nil then
       userinfo = string.sub(url,dot+3,userinfo-1)
       local user,pass = string.match(userinfo,"([^:]*):([^:]*)")
       tb['user'] = user
       tb['pass'] = pass
   end
   
   local name = string.sub(url,dot+3,slash-1)
   local host,port
   host,port = string.match(name,"([%w%.]+):?([%d]*)")
   tb['host'] = host
   port = tonumber(port)
   if port ~= nil then tb['port'] = port end
   local question = string.find(url,"?")
   if question ~= nil then
      local path = string.sub(url,slash,question-1)
      tb['path'] = path
      local fragment = string.find(url,"#")
      if fragment ~= nil then
          tb['query'] = string.sub(url,question+1,fragment-1)
          tb['fragment'] = string.sub(url,fragment+1)
      end
   end
   return tb
end

function url:parse_str(str)
   assert(type(str)=="string","url must be a string")
   local tb = {}
   local pos = 1
   local s = string.find(str,"&",pos)
   while true do
      local kv = string.sub(str,1,s-1)
      local k,v = string.match(kv,"([^=]*)=([^=]*)")
      tb[k] = v
      pos = s+1
      s=string.find(str,"&",pos)
      if s == nil then
         kv = string.sub(str,pos)
	 k,v = string.match(kv,"([^=]*)=([^=]*)")
	 tb[k] = v
	 break 
      end
   end
   return tb
end

function url:http_build_query(tb)
   assert(type(tb)=="table","tb must be a table")
   local t = {}
   for k,v in pairs(tb) do
       table.insert(t,self.url_escape(tostring(k)) .. "=" .. self.url_escape(tostring(v))) 
   end
   return table.concat(t,'&')
end

function url:encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

return url
