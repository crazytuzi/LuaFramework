

function LogErr(msg)
	if SDXL.Errors > SDXL.GetSDXLLogger():getLoggingLevel() then return end
	SDXL.GetSDXLLogger():logLuaEvent(SDXL.Errors,msg)
end

function LogWar(msg)
	if SDXL.Warnings > SDXL.GetSDXLLogger():getLoggingLevel() then return end
	SDXL.GetSDXLLogger():logLuaEvent(SDXL.Warnings,msg)
end

function LogStd(msg)
	if SDXL.Standard > SDXL.GetSDXLLogger():getLoggingLevel() then return end
	SDXL.GetSDXLLogger():logLuaEvent(SDXL.Standard,msg)
end

function LogInfo(msg)
	if SDXL.Informative > SDXL.GetSDXLLogger():getLoggingLevel() then return end
	SDXL.GetSDXLLogger():logLuaEvent(SDXL.Informative,msg)
end

function LogInsane(msg)
	if SDXL.Insane> SDXL.GetSDXLLogger():getLoggingLevel() then return end
	SDXL.GetSDXLLogger():logLuaEvent(SDXL.Insane,msg)
end

function LogInsaneFormat(format, ...)
	local msg = string.format(format, ...)
	print(msg)
end

function LogFlurryEvent(msg)
	SDXL.Logger:flurryEvent(msg)
end