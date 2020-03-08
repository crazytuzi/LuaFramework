local ProviderBase = class("ProviderBase")
local errors = import("..errors")
local events = import("..events")
local SDK_ERRORS = {}
SDK_ERRORS["1000"] = errors.SERVICE
SDK_ERRORS["1001"] = errors.NETWORK
SDK_ERRORS["1002"] = errors.SERVICE
SDK_ERRORS["1003"] = errors.NETWORK
SDK_ERRORS["1004"] = errors.SERVICE
SDK_ERRORS["1005"] = errors.SERVICE
SDK_ERRORS["1006"] = errors.NETWORK
SDK_ERRORS["1007"] = errors.NO_MORE_AD
SDK_ERRORS["1008"] = errors.NETWORK
SDK_ERRORS["1009"] = errors.NETWORK
SDK_ERRORS["1010"] = errors.SERVICE
SDK_ERRORS["1011"] = errors.VERSION
SDK_ERRORS["1012"] = errors.SERVICE
SDK_ERRORS["1013"] = errors.NETWORK
SDK_ERRORS["1014"] = errors.NETWORK
SDK_ERRORS["1015"] = errors.SERVICE
SDK_ERRORS["2000"] = errors.NETWORK
SDK_ERRORS["2002"] = errors.NETWORK
SDK_ERRORS["2003"] = errors.VERSION
SDK_ERRORS["2004"] = errors.NETWORK
SDK_ERRORS["2005"] = errors.SERVICE
SDK_ERRORS["2006"] = errors.SERVICE
SDK_ERRORS["2007"] = errors.SERVICE
SDK_ERRORS["2008"] = errors.SERVICE
SDK_ERRORS["2009"] = errors.SERVICE
SDK_ERRORS["2010"] = errors.NETWORK
SDK_ERRORS["9999"] = errors.UNKNOWN
function ProviderBase:ctor(interface, options)
  self.interface_ = interface
  self.options_ = options
end
function ProviderBase:callback_(event)
  event, errcode = unpack(string.split(string.lower(event), ","))
  printInfo("cc.ad.punchbox CALLBACK, event %s", event)
  local evt = {
    provider = "ad.PunchBox"
  }
  if event == "received" then
    evt.name = events.RECEIVED
  elseif event == "present" then
    evt.name = events.PRESENT
  elseif event == "dismiss" then
    evt.name = events.DISMISS
  elseif event == "failed" then
    evt.name = events.FAILED
    evt.error = SDK_ERRORS[errcode] or errors.UNKNOWN
    evt.errorCode = errcode
  else
    evt.name = string.upper(event)
  end
  self.interface_:dispatchEvent(evt)
end
function ProviderBase:doCommand(args)
  if args.command == "banner" or args.command == "interstitial" or args.command == "moregame" then
    self:show(args.command, args.args)
  else
    printError("cc.ad.punchbox.ProviderBase:doCommand() - invaild command:" .. args.command)
  end
end
return ProviderBase
